unit FMX.UCEditorForm_U;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.UCBase,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls, FMX.ListBox,
  FMX.Edit, FMX.Layouts, FMX.TabControl, System.Actions, FMX.ActnList, FMX.Menus,
  FMX.Controls.Presentation, Winapi.Windows, Winapi.ShellAPI, FMX.EditBox, FMX.SpinBox, FMX.ScrollBox, FMX.Memo;

type
  TUCEditorForm = class(TForm)
    PageControl: TTabControl;
    Panel1: TPanel;
    ActionList1: TActionList;
    OpenDialog1: TOpenDialog;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    TabItem4: TTabItem;
    TabItem5: TTabItem;
    TabItem6: TTabItem;
    TabItem7: TTabItem;
    GridPanelLayout1: TGridPanelLayout;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    GroupBox1: TGroupBox;
    edtApplicationID: TEdit;
    edtTableRights: TEdit;
    edtTabelaPermissoesEX: TEdit;
    edtTableUsers: TEdit;
    cbCriptografia: TComboBox;
    cbLoginMode: TComboBox;
    ckAutoStart: TCheckBox;
    ckValidationKey: TCheckBox;
    btnTabelasPadrao: TButton;
    ckMenuVisible: TCheckBox;
    ckActionVisible: TCheckBox;
    acVisualizarTelaLogin: TAction;
    acCarregarFigura: TAction;
    spedtEncryptKey: TSpinBox;
    ImageControl1: TImageControl;
    Label8: TLabel;
    GridPanelLayout3: TGridPanelLayout;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    cbActionList: TComboBox;
    cbActionManager: TComboBox;
    cbMainMenu: TComboBox;
    cbActionMainMenuBar: TComboBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    GridPanelLayout4: TGridPanelLayout;
    Label9: TLabel;
    Label14: TLabel;
    cbUserAction: TComboBox;
    cbUserMenuItem: TComboBox;
    ckUserProtectAdministrator: TCheckBox;
    ckUserUsePrivilegedField: TCheckBox;
    GridPanelLayout5: TGridPanelLayout;
    Label15: TLabel;
    Label16: TLabel;
    cbUserProfileAction: TComboBox;
    cbUserProfileMenuItem: TComboBox;
    ckUserProfileActive: TCheckBox;
    GridPanelLayout6: TGridPanelLayout;
    Label17: TLabel;
    Label18: TLabel;
    cbUserPasswordChangeAction: TComboBox;
    cbUserPasswordChangeMenuItem: TComboBox;
    ckUserPassowrdChangeForcePassword: TCheckBox;
    Label19: TLabel;
    spedtUserPasswordChangeMinPasswordLength: TSpinBox;
    GridPanelLayout7: TGridPanelLayout;
    Label20: TLabel;
    Label21: TLabel;
    cbLogControlAction: TComboBox;
    cbLogControlMenuItem: TComboBox;
    ckLogControlActive: TCheckBox;
    Label22: TLabel;
    edtLogControlTableLog: TEdit;
    GridPanelLayout2: TGridPanelLayout;
    GridPanelLayout8: TGridPanelLayout;
    GridPanelLayout9: TGridPanelLayout;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    lblInitialRights: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    edtInitialLoginAlias: TEdit;
    edtLoginAutoLoginUser: TEdit;
    edtInitialLoginPassword: TEdit;
    edtLoginAutoLoginPassword: TEdit;
    edtInitialLoginGroupName: TEdit;
    edtInitialLoginEmail: TEdit;
    mmInitialRights: TMemo;
    Label32: TLabel;
    edtInitialLoginUser: TEdit;
    ckLoginAutologinActive: TCheckBox;
    ckLoginAutoLoginMessageOnError: TCheckBox;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    cbGetLoginName: TComboBox;
    spedtMaxLoginAttempts: TSpinBox;
    ComboBox2: TComboBox;
    Button5: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure edtTabelaPermissoesEXChange(Sender: TObject);
    procedure cbComboRightsChange(Sender: TObject);
    procedure ComboActionMenuItem(Sender: TObject);
    procedure btnTabelasPadraoClick(Sender: TObject);
  private
    FUserControl: TFMXUserControl;
  public
    constructor Create(AOwner: TComponent; UserControl: TFMXUserControl); reintroduce;
  end;

var
  UCEditorForm: TUCEditorForm;

implementation

{$R *.fmx}

uses
  FMX.LoginWindow_U,
  FMX.UcConsts_Language,
  FMX.UCMessages;

procedure TUCEditorForm.btnTabelasPadraoClick(Sender: TObject);
begin
  edtTableUsers.Text := RetornaLingua(FUserControl.Language, 'Const_TableUsers_TableName');
  edtTableRights.Text := RetornaLingua(FUserControl.Language, 'Const_TableRights_TableName');
end;

procedure TUCEditorForm.Button1Click(Sender: TObject);
begin
  Case TButton(Sender).Tag of
    0:
      cbActionList.ItemIndex := -1;
    1:
      cbActionMainMenuBar.ItemIndex := -1;
    2:
      cbActionManager.ItemIndex := -1;
    3:
      cbMainMenu.ItemIndex := -1;
  end;
end;

procedure TUCEditorForm.Button5Click(Sender: TObject);
var
  frmLogin: TfrmLoginWindow;
begin
  try
    frmLogin := TfrmLoginWindow.Create(nil);
    with frmLogin do
    begin
      FUserControl := Self.FUserControl;
      btOK.onClick := BotoesClickVisualizacao;
      BtCancela.onClick := BotoesClickVisualizacao;
      Caption := Self.FUserControl.UserSettings.Login.WindowCaption;
      LbUsuario.Text := Self.FUserControl.UserSettings.Login.LabelUser;
      LbPass.Text := Self.FUserControl.UserSettings.Login.LabelPassword;
      // imgTop.Picture := Self.imgTop.Picture;
      // imgLeft.Picture := Self.imgLeft.Picture;
      // imgBottom.Picture := Self.imgBottom.Picture;
      btOK.Text := Self.FUserControl.UserSettings.Login.btOK;
      BtCancela.Text := Self.FUserControl.UserSettings.Login.BtCancel;
      Position := Self.FUserControl.UserSettings.WindowsPosition;
      ShowModal;
    end;
  finally
    FreeAndNil(frmLogin);
  end;
end;

procedure TUCEditorForm.cbComboRightsChange(Sender: TObject);
begin
  if Sender = cbActionList then
    if cbActionList.ItemIndex >= 0 then
    begin
      cbActionMainMenuBar.ItemIndex := -1;
      cbActionManager.ItemIndex := -1;
      cbMainMenu.ItemIndex := -1;
    end;

  if Sender = cbActionMainMenuBar then
    if cbActionMainMenuBar.ItemIndex >= 0 then
    begin
      cbActionList.ItemIndex := -1;
      cbActionManager.ItemIndex := -1;
      cbMainMenu.ItemIndex := -1;
    end;

  if Sender = cbActionManager then
    if cbActionManager.ItemIndex >= 0 then
    begin
      cbActionList.ItemIndex := -1;
      cbActionMainMenuBar.ItemIndex := -1;
      cbMainMenu.ItemIndex := -1;
    end;

  if Sender = cbMainMenu then
    if cbMainMenu.ItemIndex >= 0 then
    begin
      cbActionList.ItemIndex := -1;
      cbActionMainMenuBar.ItemIndex := -1;
      cbActionManager.ItemIndex := -1;
    end;
end;

procedure TUCEditorForm.ComboActionMenuItem(Sender: TObject);
begin
  // Combo USER
  if (Sender = cbUserAction) and (cbUserAction.ItemIndex >= 0) then
    cbUserMenuItem.ItemIndex := -1;

  if (Sender = cbUserMenuItem) and (cbUserMenuItem.ItemIndex >= 0) then
    cbUserAction.ItemIndex := -1;

  // Combo USERPROFILE
  if (Sender = cbUserProfileAction) and (cbUserProfileAction.ItemIndex >= 0) then
    cbUserProfileMenuItem.ItemIndex := -1;

  if (Sender = cbUserProfileMenuItem) and (cbUserProfileMenuItem.ItemIndex >= 0) then
    cbUserProfileAction.ItemIndex := -1;

  // Combo USERPASSWORDCHANGE
  if (Sender = cbUserPasswordChangeAction) and (cbUserPasswordChangeAction.ItemIndex >= 0) then
    cbUserPasswordChangeMenuItem.ItemIndex := -1;

  if (Sender = cbUserPasswordChangeMenuItem) and (cbUserPasswordChangeMenuItem.ItemIndex >= 0) then
    cbUserPasswordChangeAction.ItemIndex := -1;

  // Combo LOGCONTROL
  if (Sender = cbLogControlAction) and (cbLogControlAction.ItemIndex >= 0) then
    cbLogControlMenuItem.ItemIndex := -1;

  if (Sender = cbLogControlMenuItem) and (cbLogControlMenuItem.ItemIndex >= 0) then
    cbLogControlAction.ItemIndex := -1;
end;

constructor TUCEditorForm.Create(AOwner: TComponent; UserControl: TFMXUserControl);
begin
  inherited Create(AOwner);
  FUserControl := UserControl;
end;

procedure TUCEditorForm.edtTabelaPermissoesEXChange(Sender: TObject);
begin
  edtTabelaPermissoesEX.Text := edtTableRights.Text + 'EX';
end;

procedure TUCEditorForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TUCEditorForm.FormCreate(Sender: TObject);
var
  I: Integer;
  Formulario: TForm;
begin
  lblInitialRights.Text := 'Initial  ' + #13 + 'Rights :';
  PageControl.ActiveTab := TabItem1;

  with FUserControl do
  begin
    edtApplicationID.Text := ApplicationID;
    ckAutoStart.isChecked := AutoStart;
    ckValidationKey.isChecked := CheckValidationKey;
    spedtEncryptKey.Value := EncryptKey;
    edtTableRights.Text := TableRights.TableName;
    edtTableUsers.Text := TableUsers.TableName;
    ckActionVisible.isChecked := NotAllowedItems.ActionVisible;
    ckMenuVisible.isChecked := NotAllowedItems.MenuVisible;
    cbCriptografia.ItemIndex := Integer(Criptografia);
    cbLoginMode.ItemIndex := Integer(LoginMode);
  end;

  Formulario := TForm(FUserControl.Owner);

  for I := 0 to Formulario.ComponentCount - 1 do
  begin
    if Formulario.Components[I] is TAction then
    begin
      cbUserAction.Items.Add(TAction(Formulario.Components[I]).Name);
      cbUserProfileAction.Items.Add(TAction(Formulario.Components[I]).Name);
      cbLogControlAction.Items.Add(TAction(Formulario.Components[I]).Name);
      cbUserPasswordChangeAction.Items.Add(TAction(Formulario.Components[I]).Name);
    end;

    if Formulario.Components[I] is TMenuItem then
    begin
      cbUserMenuItem.Items.Add(Formulario.Components[I].Name);
      cbUserProfileMenuItem.Items.Add(Formulario.Components[I].Name);
      cbLogControlMenuItem.Items.Add(Formulario.Components[I].Name);
      cbUserPasswordChangeMenuItem.Items.Add(Formulario.Components[I].Name);
    end;

    // Adicionar os valores dos "ControlRights"
    if Formulario.Components[I] is TActionList then
      cbActionList.Items.Add(Formulario.Components[I].Name);

    { if Formulario.Components[I] is TActionMainMenuBar then
      cbActionMainMenuBar.Items.Add(Formulario.Components[I].Name);

      if Formulario.Components[I] is TActionManager then
      cbActionManager.Items.Add(Formulario.Components[I].Name); }

    if Formulario.Components[I] is TMainMenu then
      cbMainMenu.Items.Add(Formulario.Components[I].Name);
  end;

  with FUserControl.ControlRight do
  begin
    if Assigned(ActionList) then
      cbActionList.ItemIndex := (cbActionList.Items.IndexOf(ActionList.Name));

    if Assigned(MainMenu) then
      cbMainMenu.ItemIndex := (cbMainMenu.Items.IndexOf(MainMenu.Name));

    { if Assigned(ActionMainMenuBar) then
      cbActionMainMenuBar.ItemIndex := (cbActionMainMenuBar.Items.IndexOf(ActionMainMenuBar.Name));

      if Assigned(ActionManager) then
      cbActionManager.ItemIndex := (cbActionManager.Items.IndexOf(ActionManager.Name)); }
  end;

  // Action e MenuItem USER
  if Assigned(FUserControl.User.Action) then
    cbUserAction.ItemIndex := (cbUserAction.Items.IndexOf(FUserControl.User.Action.Name));

  if Assigned(FUserControl.User.MenuItem) then
    cbUserMenuItem.ItemIndex := (cbUserMenuItem.Items.IndexOf(FUserControl.User.MenuItem.Name));

  // Action e MenuItem USERPROFILE
  if Assigned(FUserControl.UserProfile.Action) then
    cbUserProfileAction.ItemIndex := (cbUserProfileAction.Items.IndexOf(FUserControl.UserProfile.Action.Name));

  if Assigned(FUserControl.UserProfile.MenuItem) then
    cbUserProfileMenuItem.ItemIndex := (cbUserProfileMenuItem.Items.IndexOf(FUserControl.UserProfile.MenuItem.Name));

  // Action e MenuItem USERPASSWORDCHANGE
  if Assigned(FUserControl.UserPasswordChange.Action) then
    cbUserPasswordChangeAction.ItemIndex := (cbUserPasswordChangeAction.Items.IndexOf(FUserControl.UserPasswordChange.Action.Name));

  if Assigned(FUserControl.UserPasswordChange.MenuItem) then
    cbUserPasswordChangeMenuItem.ItemIndex := (cbUserPasswordChangeMenuItem.Items.IndexOf(FUserControl.UserPasswordChange.MenuItem.Name));

  // Action e MenuItem LOGCONTROL
  if Assigned(FUserControl.LogControl.Action) then
    cbLogControlAction.ItemIndex := (cbLogControlAction.Items.IndexOf(FUserControl.LogControl.Action.Name));

  if Assigned(FUserControl.LogControl.MenuItem) then
    cbLogControlMenuItem.ItemIndex := (cbLogControlMenuItem.Items.IndexOf(FUserControl.LogControl.MenuItem.Name));

  ckUserProtectAdministrator.isChecked := FUserControl.User.ProtectAdministrator;
  ckUserUsePrivilegedField.isChecked := FUserControl.User.UsePrivilegedField;

  ckUserProfileActive.isChecked := FUserControl.UserProfile.Active;

  ckUserPassowrdChangeForcePassword.isChecked := FUserControl.UserPasswordChange.ForcePassword;
  spedtUserPasswordChangeMinPasswordLength.Value := FUserControl.UserPasswordChange.MinPasswordLength;

  edtLogControlTableLog.Text := FUserControl.LogControl.TableLog;
  ckLogControlActive.isChecked := FUserControl.LogControl.Active;

  // Login
  spedtMaxLoginAttempts.Value := FUserControl.Login.MaxLoginAttempts;
  cbGetLoginName.ItemIndex := Integer(FUserControl.Login.GetLoginName);
  // login inicial
  edtInitialLoginUser.Text := FUserControl.Login.InitialLogin.User;
  edtInitialLoginPassword.Text := FUserControl.Login.InitialLogin.Password;
  edtInitialLoginEmail.Text := FUserControl.Login.InitialLogin.Email;
  edtInitialLoginGroupName.Text := FUserControl.Login.InitialLogin.GroupName;
  edtInitialLoginAlias.Text := FUserControl.Login.InitialLogin.Alias;

  mmInitialRights.Lines := FUserControl.Login.InitialLogin.InitialRights;
  // AutoLogin
  edtLoginAutoLoginUser.Text := FUserControl.Login.AutoLogin.User;
  edtLoginAutoLoginPassword.Text := FUserControl.Login.AutoLogin.Password;
  ckLoginAutologinActive.isChecked := FUserControl.Login.AutoLogin.Active;
  ckLoginAutoLoginMessageOnError.isChecked := FUserControl.Login.AutoLogin.MessageOnError;
  // Figuras
  // imgTop.Picture.Bitmap := FUserControl.UserSettings.Login.TopImage.Bitmap;
  // imgLeft.Picture.Bitmap := FUserControl.UserSettings.Login.LeftImage.Bitmap;
  // imgBottom.Picture.Bitmap := FUserControl.UserSettings.Login.BottomImage.Bitmap;
end;

end.
