unit FMX.UCIdle;

interface

uses Classes, FMX.UCBase, FMX.Dialogs, Windows, FMX.Forms, FMX.ExtCtrls, Messages, SysUtils;

type

  TFMXUCIdle = class;
  TFMXUCIdleTimeLeft = procedure(TimeLeft: Integer) of Object;

  TThUCIdle = class(TThread)
  private
    procedure DoIdle;
    procedure TimeLeftSinc;
  protected
    procedure Execute; override;
  public
    CurrentMilisec: Integer;
    UCIdle: TFMXUCIdle;
  end;

  TFMXUCIdle = class(TComponent)
  private
    FThIdle: TThUCIdle;
    FTimeOut: Integer;
    FOnIdle: TNotifyEvent;
    FUserControl: TFMXUserControl; // changed from FUCComp to FUserControl
   // FOnAppMessage: TMessageEvent;
    FTimeLeftNotify: TFMXUCIdleTimeLeft;
    procedure UCAppMessage(var Msg: TMsg; var Handled: Boolean);
    procedure SeTFMXUserControl(const Value: TFMXUserControl);
  protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override; // added by fduenas
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DoIdle;
  published
    property UserControl: TFMXUserControl read FUserControl write SeTFMXUserControl; // changed by fduenas
    property OnIdle: TNotifyEvent read FOnIdle write FOnIdle;
    property OnTimeLeftNotify: TFMXUCIdleTimeLeft read FTimeLeftNotify write FTimeLeftNotify;
    property Timeout: Integer read FTimeOut write FTimeOut;
  end;

implementation

{ TFMXUCIdle }

constructor TFMXUCIdle.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TFMXUCIdle.Destroy;
begin
  FreeAndNil(FThIdle);
  inherited;
end;

procedure TFMXUCIdle.DoIdle;
begin
  if Assigned(UserControl) and (UserControl.CurrentUser.UserID <> 0) then
  begin
    UserControl.WriteAccessAction('Cierre de sesión por timeout');
    UserControl.Logoff;
  end;
  if Assigned(OnIdle) then
    OnIdle(Self);
end;

procedure TFMXUCIdle.Loaded;
begin
  inherited;
  if not(csDesigning in ComponentState) then
    if (Assigned(UserControl)) or (Assigned(OnIdle)) then
    begin
     // if Assigned(Application.OnMessage) then
    //    FOnAppMessage := Application.OnMessage;
    //  Application.OnMessage := UCAppMessage;
      FThIdle := TThUCIdle.Create(True);
      FThIdle.CurrentMilisec := 0;
      FThIdle.UCIdle := Self;
      FThIdle.Start;
    end;
end;

procedure TFMXUCIdle.Notification(AComponent: TComponent; AOperation: TOperation);
begin
  If AOperation = opRemove then
    If AComponent = FUserControl then
      FUserControl := nil;
  inherited Notification(AComponent, AOperation);

end;

procedure TFMXUCIdle.SeTFMXUserControl(const Value: TFMXUserControl);
begin
  FUserControl := Value;
  if Value <> nil then
    Value.FreeNotification(Self);
end;

procedure TFMXUCIdle.UCAppMessage(var Msg: TMsg; var Handled: Boolean);
begin
  if (Msg.message = wm_mousemove) or (Msg.message = wm_keydown) then
    FThIdle.CurrentMilisec := 0;

  //if Assigned(FOnAppMessage) then
   // FOnAppMessage(Msg, Handled);
end;

{ TThUCIdle }


procedure TThUCIdle.DoIdle;
begin
  UCIdle.DoIdle;
end;

procedure TThUCIdle.TimeLeftSinc;
begin
  if Assigned(UCIdle.OnTimeLeftNotify) then
    UCIdle.OnTimeLeftNotify(UCIdle.Timeout - CurrentMilisec);
end;

procedure TThUCIdle.Execute;
begin
 while not Terminated do
  begin
    Sleep(1000);
    if UCIdle.Timeout <= CurrentMilisec then
    begin
      CurrentMilisec := 0;
      Synchronize(DoIdle);
    end
    else
    begin
      Inc(CurrentMilisec, 1000);
      Synchronize(TimeLeftSinc);
    end;
  end;
end;



end.
