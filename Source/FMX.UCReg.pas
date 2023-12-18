unit FMX.UCReg;

interface

{ .$I 'UserControl.inc' }

uses
  Classes,
  FMX.Controls,
  DesignEditors,
  DesignIntf,
  ToolsAPI,
  TypInfo,
  FMX.UCBase,
  FMX.Dialogs,
  FMX.Forms,
  System.SysUtils,
  // FMX.UCAbout,
  FMX.UCIdle,
  FMX.UCObjSel_U,
  FMX.Types,
  System.UITypes,
  FMX.UCEditorForm_U,
  FMX.ActnList,
  FMX.Menus,
  FMX.StdCtrls,
  FMX.UCSettings,
  System.Variants,
  FMX.UcMail;

type
  TUCComponentsVarProperty = class(TStringProperty)
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
    function GetValue: String; override;
  end;

  TFMXUCControlsEditor = class(TComponentEditor)
    procedure Edit; override;

    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): String; override;
    function GetVerbCount: Integer; override;
  end;

  TFMXUserControlEditor = class(TComponentEditor)
    procedure Edit; override;
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): String; override;
    function GetVerbCount: Integer; override;
  end;

  TUCAboutVarProperty = class(TStringProperty)
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
    function GetValue: String; override;
  end;

procedure Register;
procedure ShowControlsEditor(Componente: TFMXUCControls);
procedure ShowUserControlsEditor(Componente: TFMXUserControl);

implementation

procedure Register;
begin
  RegisterComponents('UC Main', [TFMXUserControl, TFMXUCSettings, TFMXUCControls, TFMXUCApplicationMessage, TFMXUCIdle, TFMXMailUserControl]);
  RegisterPropertyEditor(TypeInfo(TUCAboutVar), TFMXUserControl, 'About', TUCAboutVarProperty);
  RegisterPropertyEditor(TypeInfo(TUCComponentsVar), TFMXUserControl, 'Components', TUCComponentsVarProperty);
  RegisterComponentEditor(TFMXUCControls, TFMXUCControlsEditor);
  RegisterComponentEditor(TFMXUserControl, TFMXUserControlEditor);
end;

{ TUCComponentsVarProperty }
procedure TUCComponentsVarProperty.Edit;
begin
  ShowControlsEditor(TFMXUCControls(GetComponent(0)));
end;

function TUCComponentsVarProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end;

function TUCComponentsVarProperty.GetValue: String;
begin
  Result := 'Components...';
end;

{ TUCAboutVarProperty }

procedure TUCAboutVarProperty.Edit;
begin
  { with TAboutForm.Create(nil) do
    begin
    ShowModal;
    Free;
    end; }
end;

function TUCAboutVarProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end;

function TUCAboutVarProperty.GetValue: String;
begin
  Result := 'Versao ' + UCVersion;
end;

procedure ShowUserControlsEditor(Componente: TFMXUserControl);
var
  Editor: IOTAEditor;
  Modulo: IOTAModule;
  FormEditor: IOTAFormEditor;
  I: Integer;
  Formulario: TUCEditorForm;
  UserControl: TFMXUserControl;
  Controle_Action, Controle_MainMenu, Controle_ActionManager, Controle_ActionMainMenuBar: String;
  UserActionMenuItem: String;
  UserProfileActionMenuItem: String;
  LogControlActionMeuItem: String;
  UserPasswordChangeActionMenuItem: String;
  FormularioDono: TForm;
begin
  UserControl := Componente;
  FormularioDono := TForm(UserControl.Owner);
  try
    Formulario := TUCEditorForm.Create(nil, UserControl);

    if Formulario.ShowModal = mrOk then
    begin
      with UserControl do
      begin
        ApplicationID := Formulario.edtApplicationID.Text;
        AutoStart := Formulario.ckAutoStart.isChecked;
        CheckValidationKey := Formulario.ckValidationKey.isChecked;
        EncryptKey := Round(Formulario.spedtEncryptKey.Value);
        TableRights.TableName := Formulario.edtTableRights.Text;
        TableUsers.TableName := Formulario.edtTableUsers.Text;
        NotAllowedItems.ActionVisible := Formulario.ckActionVisible.isChecked;
        NotAllowedItems.MenuVisible := Formulario.ckMenuVisible.isChecked;
        Criptografia := TUCCriptografia(Formulario.cbCriptografia.ItemIndex);
        LoginMode := TUCLoginMode(Formulario.cbLoginMode.ItemIndex);

        if Formulario.cbActionList.ItemIndex >= 0 then
          Controle_Action := Formulario.cbActionList.Selected.Text;

        if Formulario.cbActionMainMenuBar.ItemIndex >= 0 then
          Controle_ActionMainMenuBar := Formulario.cbActionMainMenuBar.Selected.Text;

        if Formulario.cbActionManager.ItemIndex >= 0 then
          Controle_ActionManager := Formulario.cbActionManager.Selected.Text;

        if Formulario.cbMainMenu.ItemIndex >= 0 then
          Controle_MainMenu := Formulario.cbMainMenu.Selected.Text;

        if Formulario.cbUserAction.ItemIndex >= 0 then
          UserActionMenuItem := Formulario.cbUserAction.Selected.Text;

        if Formulario.cbUserMenuItem.ItemIndex >= 0 then
          UserActionMenuItem := Formulario.cbUserMenuItem.Selected.Text;

        if Formulario.cbUserProfileAction.ItemIndex >= 0 then
          UserProfileActionMenuItem := Formulario.cbUserProfileAction.Selected.Text;
        if Formulario.cbUserProfileMenuItem.ItemIndex >= 0 then
          UserProfileActionMenuItem := Formulario.cbUserProfileMenuItem.Selected.Text;

        if Formulario.cbLogControlAction.ItemIndex >= 0 then
          LogControlActionMeuItem := Formulario.cbLogControlAction.Selected.Text;
        if Formulario.cbLogControlMenuItem.ItemIndex >= 0 then
          LogControlActionMeuItem := Formulario.cbLogControlMenuItem.Selected.Text;

        if Formulario.cbUserPasswordChangeAction.ItemIndex >= 0 then
          UserPasswordChangeActionMenuItem := Formulario.cbUserPasswordChangeAction.Selected.Text;
        if Formulario.cbUserPasswordChangeMenuItem.ItemIndex >= 0 then
          UserPasswordChangeActionMenuItem := Formulario.cbUserPasswordChangeMenuItem.Selected.Text;

        for I := 0 to FormularioDono.ComponentCount - 1 do
        begin
          if (FormularioDono.Components[I].Name = Controle_Action) and (Formulario.cbActionList.ItemIndex >= 0) then
            ControlRight.ActionList := TActionList(FormularioDono.Components[I]);

          { if (FormularioDono.Components[I].Name = Controle_ActionMainMenuBar) and (Formulario.cbActionMainMenuBar.ItemIndex >= 0) then
            ControlRight.ActionMainMenuBar := TActionMainMenuBar(UserControl.Owner.Components[I]);

            if (FormularioDono.Components[I].Name = Controle_ActionManager) and (Formulario.cbActionManager.ItemIndex >= 0) then
            ControlRight.ActionManager := TActionManager(FormularioDono.Components[I]); }

          if (FormularioDono.Components[I].Name = Controle_MainMenu) and (Formulario.cbMainMenu.ItemIndex >= 0) then
            ControlRight.MainMenu := TMainMenu(FormularioDono.Components[I]);

          if (FormularioDono.Components[I].Name = UserActionMenuItem) and (Formulario.cbUserAction.ItemIndex >= 0) then
            User.Action := TAction(FormularioDono.Components[I]);
          if (FormularioDono.Components[I].Name = UserActionMenuItem) and (Formulario.cbUserMenuItem.ItemIndex >= 0) then
            User.MenuItem := TMenuItem(FormularioDono.Components[I]);
          if (FormularioDono.Components[I].Name = UserPasswordChangeActionMenuItem) and (Formulario.cbUserPasswordChangeAction.ItemIndex >= 0) then
            UserPasswordChange.Action := TAction(FormularioDono.Components[I]);
          if (FormularioDono.Components[I].Name = UserPasswordChangeActionMenuItem) and (Formulario.cbUserPasswordChangeMenuItem.ItemIndex >= 0) then
            UserPasswordChange.MenuItem := TMenuItem(FormularioDono.Components[I]);
        end;

        User.UsePrivilegedField := Formulario.ckUserUsePrivilegedField.isChecked;
        User.ProtectAdministrator := Formulario.ckUserProtectAdministrator.isChecked;
        UserProfile.Active := Formulario.ckUserProfileActive.isChecked;
        UserPasswordChange.ForcePassword := Formulario.ckUserPassowrdChangeForcePassword.isChecked;
        UserPasswordChange.MinPasswordLength := Round(Formulario.spedtUserPasswordChangeMinPasswordLength.Value);

        LogControl.TableLog := Formulario.edtLogControlTableLog.Text;
        LogControl.Active := Formulario.ckLogControlActive.isChecked;

        // Login.MaxLoginAttempts           := Formulario.spedtMaxLoginAttempts.Value;
        Login.GetLoginName := TUCGetLoginName(Formulario.cbGetLoginName.ItemIndex);
        Login.InitialLogin.User := Formulario.edtInitialLoginUser.Text;
        Login.InitialLogin.Password := Formulario.edtInitialLoginPassword.Text;
        Login.InitialLogin.Email := Formulario.edtInitialLoginEmail.Text;
        Login.InitialLogin.InitialRights := Formulario.mmInitialRights.Lines;
        Login.InitialLogin.Alias := Formulario.edtInitialLoginAlias.Text;
        Login.InitialLogin.GroupName := Formulario.edtInitialLoginGroupName.Text;

        Login.AutoLogin.Active := Formulario.ckLoginAutologinActive.isChecked;
        Login.AutoLogin.User := Formulario.edtLoginAutoLoginUser.Text;
        Login.AutoLogin.Password := Formulario.edtLoginAutoLoginPassword.Text;
        Login.AutoLogin.MessageOnError := Formulario.ckLoginAutoLoginMessageOnError.isChecked;
        // UserSettings.Login.TopImage := Formulario.imgTop.Picture;
        // UserSettings.Login.LeftImage := Formulario.imgLeft.Picture;
        // UserSettings.Login.BottomImage := Formulario.imgBottom.Picture;
      end;

      Modulo := (BorlandIDEServices as IOTAModuleServices).CurrentModule;
      for I := 0 to Modulo.GetModuleFileCount - 1 do
      begin
        Editor := Modulo.GetModuleFileEditor(I);
        Editor.QueryInterface(IOTAFormEditor, FormEditor);
        if FormEditor <> nil then
        begin
          FormEditor.MarkModified;
          Break;
        end;
      end;
    end;
  finally
    FreeAndNil(Formulario);
  end;
end;

procedure ShowControlsEditor(Componente: TFMXUCControls);
var
  FUCControl: TFMXUCControls;
  FEditor: IOTAEditor;
  FModulo: IOTAModule;
  FFormEditor: IOTAFormEditor;
  I: Integer;
begin
  FUCControl := Componente;
  if not Assigned(FUCControl.UserControl) then
  begin
    ShowMessage('A propriedade UserControl tem que ser informada e o componente ' + #13 + #10 + 'tem que estar visível!');
    Exit;
  end;

  with TUCObjSel.Create(nil) do
  begin
    FForm := TCustomForm(FUCControl.Owner);
    FUserControl := FUCControl.UserControl;
    FInitialObjs := TStringList.Create;
    FUCControl.ListComponents(FForm.Name, FInitialObjs);
    lbgrupo_valor.Text := FUCControl.GroupName; // TFMXUCControls(Componente).GroupName;
    Show;
  end;

  try
    FModulo := (BorlandIDEServices as IOTAModuleServices).FindFormModule(FUCControl.UserControl.Owner.Name);
  except
    FModulo := Nil;
  end;

  if FModulo = nil then
  begin
    ShowMessage('Modulo ' + FUCControl.UserControl.Owner.Name + ' no encontrado!');
    Exit;
  end
  else
    for I := 0 to FModulo.GetModuleFileCount - 1 do
    begin
      FEditor := FModulo.GetModuleFileEditor(I);
      FEditor.QueryInterface(IOTAFormEditor, FFormEditor);
      if FFormEditor <> nil then
      begin
        FFormEditor.MarkModified;
        Break;
      end;
    end;
end;

{ TFMXUCControlsEditor }

procedure TFMXUCControlsEditor.Edit;
begin
  ShowControlsEditor(TFMXUCControls(Component));
end;

procedure TFMXUCControlsEditor.ExecuteVerb(Index: Integer);
begin
  Edit;
end;

function TFMXUCControlsEditor.GetVerb(Index: Integer): String;
begin
  Result := '&Selecionar Componentes...';
end;

function TFMXUCControlsEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

{ TFMXUserControlEditor }

procedure TFMXUserControlEditor.Edit;
begin
  ShowUserControlsEditor(TFMXUserControl(Component));
end;

procedure TFMXUserControlEditor.ExecuteVerb(Index: Integer);
begin
  Edit;
end;

function TFMXUserControlEditor.GetVerb(Index: Integer): String;
begin
  Result := 'Configurar...';
end;

function TFMXUserControlEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

end.
