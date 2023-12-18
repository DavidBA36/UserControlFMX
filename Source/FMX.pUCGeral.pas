unit FMX.pUCGeral;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.UcBase, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Stan.Error,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls, FMX.Objects, FireDAC.Stan.Intf, FireDAC.Comp.Client, System.ImageList,
  FMX.ImgList,
  FMX.Controls.Presentation, Data.DB, FireDAC.Phys.IBWrapper, FMX.TMSTaskDialog;

type
  TFMXFormUserPerf = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    ImageList1: TImageList;
    FDTransaction: TFDTransaction;
    Panel3: TPanel;
    Image1: TImage;
    LbDescricao: TLabel;
    btnUser: TButton;
    StyleBook1: TStyleBook;
    btnExit: TButton;
    btnSettings: TButton;
    btnAccess: TButton;
    btnOnline: TButton;
    btnLog: TButton;
    btnGrupo: TButton;
    TaskDialog: TTMSFMXTaskDialog;
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Panel3Resize(Sender: TObject);
    procedure btnUserClick(Sender: TObject);
    procedure btnGrupoClick(Sender: TObject);
    procedure btnLogClick(Sender: TObject);
    procedure btnOnlineClick(Sender: TObject);
    procedure btnAccessClick(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
  protected
    FrmFrame: TFrame;
    procedure SetModificado(AValue: Boolean);
  private
    FConnection: TFDConnection;
    FModificado: Boolean;
  public
    FFMXUsercontrol: TFMXUserControl;
    property Modificado: Boolean read FModificado write SetModificado;
    constructor CreateEx(AOwner: TComponent; AConn: TFDConnection; UC: TFMXUserControl);
  end;

var
  FMXFormUserPerf: TFMXFormUserPerf;

implementation

{$R *.fmx}

uses
  FMX.pUCFrame_Log,
  FMX.pUcFrame_Profile,
  FMX.pUcFrame_User,
  FMX.pUcFrame_UserLogged,
  FMX.pUcFrame_Accesos,
  FMX.pUCFrame_Ajustes,
  FMX.UCMessages,
  FMX.UCHelpers;

procedure TFMXFormUserPerf.btnAccessClick(Sender: TObject);
begin
  Image1.Bitmap := nil;
  Image1.Bitmap := ImageList1.Bitmap(TsizeF.Create(32, 32), TButton(Sender).ImageIndex);

  if FrmFrame is TFMXUcFrame_Accesos then
    exit;

  if assigned(FrmFrame) then
    FreeAndNil(FrmFrame);

  FrmFrame := TFMXUcFrame_Accesos.CreateEx(Self, FDTransaction, FConnection, FFMXUsercontrol);
  LbDescricao.Text := FFMXUsercontrol.UserSettings.UsersLogged.LabelDescricao;
  TFMXUcFrame_Accesos(FrmFrame).Height := Panel3.Height;
  TFMXUcFrame_Accesos(FrmFrame).Width := Panel3.Width;
  FrmFrame.Parent := Panel3;
end;

procedure TFMXFormUserPerf.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFMXFormUserPerf.btnGrupoClick(Sender: TObject);
begin
  Image1.Bitmap := nil;
  Image1.Bitmap := ImageList1.Bitmap(TsizeF.Create(32, 32), TButton(Sender).ImageIndex);
  if FrmFrame is TFMXUcFrame_Profile then
    exit;

  if assigned(FrmFrame) then
    FrmFrame.Free;

  FrmFrame := TFMXUcFrame_Profile.CreateEx(Self, FDTransaction, FConnection, FFMXUsercontrol);
  TFMXUcFrame_Profile(FrmFrame).Height := Panel3.Height;
  TFMXUcFrame_Profile(FrmFrame).Width := Panel3.Width;
  LbDescricao.Text := FFMXUsercontrol.UserSettings.UsersProfile.LabelDescription;
  FrmFrame.Parent := Panel3;
end;

procedure TFMXFormUserPerf.btnLogClick(Sender: TObject);
begin
  Image1.Bitmap := nil;
  Image1.Bitmap := ImageList1.Bitmap(TsizeF.Create(32, 32), TButton(Sender).ImageIndex);
  if FrmFrame is TFMXUcFrame_Log then
    exit;

  if assigned(FrmFrame) then
    FreeAndNil(FrmFrame);

  FrmFrame := TFMXUcFrame_Log.CreateEx(Self, FDTransaction, FConnection, FFMXUsercontrol);
  LbDescricao.Text := FFMXUsercontrol.UserSettings.Log.LabelDescription;
  TFMXUcFrame_Log(FrmFrame).SetWindow;
  TFMXUcFrame_Log(FrmFrame).Height := Panel3.Height;
  TFMXUcFrame_Log(FrmFrame).Width := Panel3.Width;
  FrmFrame.Parent := Panel3;
end;

procedure TFMXFormUserPerf.btnOnlineClick(Sender: TObject);
begin
  Image1.Bitmap := nil;
  Image1.Bitmap := ImageList1.Bitmap(TsizeF.Create(32, 32), TButton(Sender).ImageIndex);

  if FrmFrame is TFMXUCFrame_UsersLogged then
    exit;

  if assigned(FrmFrame) then
    FreeAndNil(FrmFrame);

  FrmFrame := TFMXUCFrame_UsersLogged.CreateEx(Self, FDTransaction, FConnection, FFMXUsercontrol);
  LbDescricao.Text := FFMXUsercontrol.UserSettings.UsersLogged.LabelDescricao;
  TFMXUCFrame_UsersLogged(FrmFrame).Height := Panel3.Height;
  TFMXUCFrame_UsersLogged(FrmFrame).Width := Panel3.Width;
  FrmFrame.Parent := Panel3;
end;

procedure TFMXFormUserPerf.btnSettingsClick(Sender: TObject);
begin
  Image1.Bitmap := nil;
  Image1.Bitmap := ImageList1.Bitmap(TsizeF.Create(32, 32), TButton(Sender).ImageIndex);

  if FrmFrame is TFMXUCFrame_Ajustes then
    exit;

  if assigned(FrmFrame) then
    FreeAndNil(FrmFrame);

  FrmFrame := TFMXUCFrame_Ajustes.CreateEx(Self, FDTransaction, FConnection, FFMXUsercontrol);
  LbDescricao.Text := FFMXUsercontrol.UserSettings.UsersLogged.LabelDescricao;
  TFMXUCFrame_Ajustes(FrmFrame).Height := Panel3.Height;
  TFMXUCFrame_Ajustes(FrmFrame).Width := Panel3.Width;
  FrmFrame.Parent := Panel3;
end;

procedure TFMXFormUserPerf.btnUserClick(Sender: TObject);
begin
  Image1.Bitmap := nil;
  Image1.Bitmap := ImageList1.Bitmap(TsizeF.Create(32, 32), TButton(Sender).ImageIndex);

  if FrmFrame is TFMXUCFrame_User then
    exit;

  if assigned(FrmFrame) then
    FreeAndNil(FrmFrame);

  FrmFrame := TFMXUCFrame_User.CreateEx(Self, FDTransaction, FConnection, FFMXUsercontrol);
  TFMXUCFrame_User(FrmFrame).Height := Panel3.Height;
  TFMXUCFrame_User(FrmFrame).Width := Panel3.Width;
  LbDescricao.Text := FFMXUsercontrol.UserSettings.UsersForm.LabelDescription;
  FrmFrame.Parent := Panel3;
end;

constructor TFMXFormUserPerf.CreateEx(AOwner: TComponent; AConn: TFDConnection; UC: TFMXUserControl);
var
  i: integer;
begin
  inherited Create(AOwner);
  FFMXUsercontrol := UC;
  FConnection := AConn;
  Modificado := False;
  try

    for i := 0 to (ComponentCount - 1) do
    begin
      if ((Components[i] Is TFDUpdateSQL)) then
        TFDUpdateSQL(Components[i]).Connection := FConnection
      else if ((Components[i] Is TFDTransaction)) then
        TFDTransaction(Components[i]).Connection := FConnection;
    end;
    if not(FDTransaction.Active) then
      FDTransaction.StartTransaction;

    CheckPermisos(Self, FConnection, FDTransaction, FFMXUsercontrol);

    btnLog.Visible := FFMXUsercontrol.LogControl.Active;

    btnOnline.Visible := FFMXUsercontrol.UsersLogged.Active;

    if btnUser.Enabled then
      btnUserClick(btnUser);

    Caption := FFMXUsercontrol.UserSettings.UsersForm.WindowCaption;
    btnUser.Text := FFMXUsercontrol.UserSettings.Log.ColUser;
    btnGrupo.Text := FFMXUsercontrol.UserSettings.UsersProfile.ColProfile;
    btnOnline.Text := FFMXUsercontrol.UserSettings.UsersLogged.LabelDescricao;
    btnExit.Text := FFMXUsercontrol.UserSettings.UsersProfile.BtClose;
  except
    on E: Exception do
      raise Exception.Create('Error conectando a Firebird');
  end;

end;

procedure TFMXFormUserPerf.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FFMXUsercontrol.ApplyRights;
  Action := TCloseAction.caFree;
end;

procedure TFMXFormUserPerf.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  oExc: EFDDBEngineException;
begin
  try
    if (FrmFrame is TFMXUcFrame_Profile) and (TFMXUcFrame_Profile(FrmFrame).FDMaster.State in [dsEdit, dsInsert]) then
      TFMXUcFrame_Profile(FrmFrame).FDMaster.Post
    else if (FrmFrame is TFMXUCFrame_User) and (TFMXUCFrame_User(FrmFrame).FDMaster.State in [dsEdit, dsInsert]) then
      TFMXUCFrame_User(FrmFrame).FDMaster.Post
    else if (FrmFrame is TFMXUCFrame_Ajustes) and (TFMXUCFrame_Ajustes(FrmFrame).FDMaster.State in [dsEdit, dsInsert]) then
      TFMXUCFrame_Ajustes(FrmFrame).FDMaster.Post
    else if (FrmFrame is TFMXUcFrame_Log) and (TFMXUcFrame_Log(FrmFrame).FDMaster.State in [dsEdit, dsInsert]) then
      TFMXUcFrame_Log(FrmFrame).FDMaster.Post
    else if (FrmFrame is TFMXUcFrame_Accesos) and (TFMXUcFrame_Accesos(FrmFrame).FDMaster.State in [dsEdit, dsInsert]) then
      TFMXUcFrame_Accesos(FrmFrame).FDMaster.Post;
    if Modificado then
    begin
      TaskDialog.Title := 'Confirmación';
      TaskDialog.Content := '¿Deseas guardar los cambios?';
      TaskDialog.Bitmap := ImageList1.Bitmap(TsizeF.Create(32, 32), 7);
      TaskDialog.Show(
        procedure(ButtonID: integer)
        begin
          case ButtonID of
            mrYes:
              begin
                if FDTransaction.Active then
                  FDTransaction.Commit;
              end;
            mrNo:
              begin
                if FDTransaction.Active then
                  FDTransaction.Rollback;
              end;
          end;
        end);
      Modificado := False;
    end;
    CanClose := True;
  except
    on E: Exception do
    begin
      if E is EIBNativeException then
      begin
        oExc := EFDDBEngineException(E);
        if oExc.Kind = ekRecordLocked then
          oExc.Message := 'El registro que intenta modificar esta bloqueado en este momento por otro usuario. Intentelo mas tarde';
      end;
    end;
  end;
end;

procedure TFMXFormUserPerf.FormDestroy(Sender: TObject);
begin
  if assigned(FrmFrame) then
    FrmFrame.Free;
  FMXFormUserPerf := nil;
end;

procedure TFMXFormUserPerf.Panel3Resize(Sender: TObject);
begin
  if not assigned(FrmFrame) then
    exit;
  if FrmFrame is TFMXUcFrame_Profile then
  begin
    TFMXUcFrame_Profile(FrmFrame).Height := Panel3.Height;
    TFMXUcFrame_Profile(FrmFrame).Width := Panel3.Width;
  end
  else if FrmFrame is TFMXUCFrame_User then
  begin
    TFMXUCFrame_User(FrmFrame).Height := Panel3.Height;
    TFMXUCFrame_User(FrmFrame).Width := Panel3.Width;
  end
  else if FrmFrame is TFMXUcFrame_Log then
  begin
    TFMXUcFrame_Log(FrmFrame).Height := Panel3.Height;
    TFMXUcFrame_Log(FrmFrame).Width := Panel3.Width;
  end
  else if FrmFrame is TFMXUCFrame_UsersLogged then
  begin
    TFMXUCFrame_UsersLogged(FrmFrame).Height := Panel3.Height;
    TFMXUCFrame_UsersLogged(FrmFrame).Width := Panel3.Width;
  end
  else if FrmFrame is TFMXUcFrame_Accesos then
  begin
    TFMXUcFrame_Accesos(FrmFrame).Height := Panel3.Height;
    TFMXUcFrame_Accesos(FrmFrame).Width := Panel3.Width;
  end
  else if FrmFrame is TFMXUCFrame_Ajustes then
  begin
    TFMXUCFrame_Ajustes(FrmFrame).Height := Panel3.Height;
    TFMXUCFrame_Ajustes(FrmFrame).Width := Panel3.Width;
  end;
end;

procedure TFMXFormUserPerf.SetModificado(AValue: Boolean);
begin
  // StatusBar1.Panels[0].Text := '';
  FModificado := AValue;
  if FModificado then
    // StatusBar1.Panels[0].Text := 'Modificado';
end;

end.
