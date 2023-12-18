unit FMX.LoginWindow_U;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.UCBase,
  FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client,
  System.ImageList, FMX.ImgList, FMX.StdCtrls, FMX.Objects, FMX.ListBox, FMX.Edit, FMX.Controls.Presentation, FMX.Layouts, FireDAC.Comp.DataSet,
  FMX.Types, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, Data.Bind.EngExt, FMX.Bind.DBEngExt, System.Rtti, System.Bindings.Outputs, FMX.Bind.Editors, Data.Bind.Components,
  Data.Bind.DBScope, FireDAC.Phys.IBBase;

type
  TfrmLoginWindow = class(TForm)
    FDMaster: TFDQuery;
    GridPanelLayout1: TGridPanelLayout;
    StatusBar: TStatusBar;
    LbEmpresa: TLabel;
    LbUsuario: TLabel;
    LbPass: TLabel;
    lbEsqueci: TLabel;
    EditPass: TEdit;
    EditUsuario: TEdit;
    ComboBox1: TComboBox;
    LbIntentosStr: TLabel;
    Rectangle1: TRectangle;
    LbIntentos: TLabel;
    Rectangle2: TRectangle;
    LbLimiteStr: TLabel;
    Rectangle3: TRectangle;
    LbLimiteIntentos: TLabel;
    GridPanelLayout2: TGridPanelLayout;
    GridPanelLayout3: TGridPanelLayout;
    cbRecordar: TCheckBox;
    cbAutoLogin: TCheckBox;
    cbAutoIniciar: TCheckBox;
    btOK: TButton;
    BtCancela: TButton;
    ImageList1: TImageList;
    StyleBook1: TStyleBook;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    FDConnection1: TFDConnection;
    Panel1: TPanel;
    Image1: TImage;
    lbtitle: TLabel;
    SpeedButton1: TSpeedButton;
    Timer1: TTimer;
    lbAsistenteUser: TLabel;
    LinkFillControlToField1: TLinkFillControlToField;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure BtCancelaClick(Sender: TObject);
    procedure EditUsuarioChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure btOKClick(Sender: TObject);
    procedure BotoesClickVisualizacao(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure cbAutoLoginChange(Sender: TObject);
    procedure cbAutoIniciarChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FUserControl: TFMXUserControl;
    FConnection: TFDConnection;
  public
    constructor CreateEx(AOwner: TComponent; AConn: TFDConnection; UC: TFMXUserControl);
  end;

var
  frmLoginWindow: TfrmLoginWindow;

implementation

{$R *.fmx}

Uses
  FMX.UCHelpers;

procedure TfrmLoginWindow.BtCancelaClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmLoginWindow.btOKClick(Sender: TObject);
begin
  // Aqui nao faz nada.Mas não apague.
end;

procedure TfrmLoginWindow.cbAutoIniciarChange(Sender: TObject);
var
  Path, LinkName: String;
begin
  Path := GetEnvironmentVariable('APPDATA') + '\Microsoft\Windows\Start Menu\Programs\Startup';
  LinkName := IncludeTrailingPathDelimiter(Path) + ExtractFileName(ChangeFileExt(ParamStr(0), '')) + '.lnk';
  if cbAutoIniciar.IsChecked then
    CreateDesktopShellLink(ChangeFileExt(ParamStr(0), ''), Path)
  else if FileExists(LinkName) then
    DeleteFile(LinkName);
end;

procedure TfrmLoginWindow.cbAutoLoginChange(Sender: TObject);
begin
  if cbAutoLogin.IsChecked then
  begin
    cbRecordar.IsChecked := True;
  end;
  cbRecordar.Enabled := not cbAutoLogin.IsChecked;
end;

procedure TfrmLoginWindow.BotoesClickVisualizacao(Sender: TObject);
begin
  Self.ModalResult := mrOk;
end;

constructor TfrmLoginWindow.CreateEx(AOwner: TComponent; AConn: TFDConnection; UC: TFMXUserControl);
begin
  try
    inherited Create(AOwner);
    FUserControl := UC;
    FConnection := AConn;
    FDMaster.Connection := FConnection;
    FDMaster.Open;
    FDMaster.Locate('CLAVE', FUserControl.UserSettings.Login.Empresa);
    ComboBox1.ItemIndex := ComboBox1.Items.IndexOfName(FDMaster.FieldByName('NOMBRE').AsString)
    // DBLookupComboBox1.KeyValue := FDMaster.FieldByName('CLAVE').AsInteger;
    // JvAppRegistryStorage1.Root := FUserControl.FormStorageRegRoot;
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TfrmLoginWindow.EditUsuarioChange(Sender: TObject);
begin
  lbEsqueci.Enabled := Length(EditUsuario.Text) > 0;
end;

procedure TfrmLoginWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TfrmLoginWindow.FormDestroy(Sender: TObject);
begin
  frmLoginWindow := nil;
end;

procedure TfrmLoginWindow.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  Begin
    Key := 0;
    Self.ModalResult := mrOk;
    // Perform(WM_NEXTDLGCTL,0,0);
  End;
end;

procedure TfrmLoginWindow.FormShow(Sender: TObject);
begin
  If FUserControl.Login.MaxLoginAttempts > 0 then
  Begin
    LbIntentosStr.Text := FUserControl.UserSettings.Login.LabelTentativa;
    LbLimiteStr.Text := FUserControl.UserSettings.Login.LabelTentativas;
  End;

  { if FUserControl.Login.GetLoginName = lnUserName then
    EditUsuario.Text := GetLocalUserName;
    if FUserControl.Login.GetLoginName = lnMachineName then
    EditUsuario.Text := GetLocalComputerName; }
  Position := Self.FUserControl.UserSettings.WindowsPosition;
  EditUsuario.CharCase := Self.FUserControl.Login.CharCaseUser;
  EditPass.CharCase := Self.FUserControl.Login.CharCasePass;
  EditUsuario.SetFocus;

end;

procedure TfrmLoginWindow.SpeedButton1Click(Sender: TObject);
begin
  EditPass.Password := False;
  Timer1.Enabled := True;
end;

procedure TfrmLoginWindow.Timer1Timer(Sender: TObject);
begin
  if not SpeedButton1.IsPressed then
  begin
    Timer1.Enabled := False;
    EditPass.Password := True;
  end;
end;

end.
