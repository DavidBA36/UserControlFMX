unit FMX.pUcFrame_User;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, FMX.UCBase, FireDAC.Phys.IBWrapper,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef,
  FireDAC.FMXUI.Wait, FMX.TMSPageControl, FMX.TMSCustomControl, FMX.TMSTabSet,
  FMX.TMSBaseControl, FMX.TMSGridCell, FMX.TMSGridOptions, FMX.TMSGridData,
  FMX.TMSCustomGrid,
  FMX.TMSLiveGrid, FMX.Controls.Presentation, System.ImageList, FMX.ImgList,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, Data.Bind.EngExt,
  FMX.Bind.DBEngExt,
  FMX.TMSLiveGridDataBinding, System.Rtti, System.Bindings.Outputs,
  FMX.Bind.Editors, Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope,
  FireDAC.Phys.IBBase, FMX.Layouts,
  FMX.EditBox, FMX.SpinBox, FMX.ListBox, FMX.Edit, Data.Bind.Controls,
  FMX.Bind.Navigator, FMX.TMSTaskDialog;

type
  TFMXUcFrame_User = class(TFrame)
    FDProcCopiaUsuario: TFDStoredProc;
    FDEmpresa: TFDQuery;
    FDMaster: TFDQuery;
    FDUMaster: TFDUpdateSQL;
    FDRelacion: TFDQuery;
    FDConnection1: TFDConnection;
    StyleBook1: TStyleBook;
    ImageList1: TImageList;
    Panel1: TPanel;
    btnNuevo: TButton;
    Button3: TButton;
    Button4: TButton;
    btnColumnas: TButton;
    btnWindows: TButton;
    btnGrupos: TButton;
    btnPermisos: TButton;
    btnPassword: TButton;
    btnBorrar: TButton;
    btnCopia: TButton;
    TMSFMXLiveGrid1: TTMSFMXLiveGrid;
    TMSFMXPageControl1: TTMSFMXPageControl;
    TMSFMXPageControl1Page0: TTMSFMXPageControlContainer;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    GridPanelLayout1: TGridPanelLayout;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    cbAmbito: TComboBox;
    ckbActivo: TCheckBox;
    Label4: TLabel;
    Edit2: TEdit;
    Label5: TLabel;
    cbMaster: TCheckBox;
    Label8: TLabel;
    Edit3: TEdit;
    Layout1: TLayout;
    Label9: TLabel;
    Label13: TLabel;
    cbEmpresa: TComboBox;
    Label18: TLabel;
    Edit4: TEdit;
    CheckBox2: TCheckBox;
    LinkControlToField1: TLinkControlToField;
    LinkControlToField2: TLinkControlToField;
    LinkControlToField3: TLinkControlToField;
    LinkFillControlToField2: TLinkFillControlToField;
    LinkControlToField4: TLinkControlToField;
    LinkControlToField5: TLinkControlToField;
    LinkControlToField6: TLinkControlToField;
    LinkControlToField8: TLinkControlToField;
    BindSourceDB2: TBindSourceDB;
    LinkFillControlToField1: TLinkFillControlToField;
    Panel2: TPanel;
    BindNavigator1: TBindNavigator;
    CheckBox3: TCheckBox;
    Label3: TLabel;
    LinkControlToField10: TLinkControlToField;
    spDiasExpira: TSpinBox;
    SpinBox2: TSpinBox;
    LinkControlToField7: TLinkControlToField;
    LinkControlToField9: TLinkControlToField;
    TaskDialog: TTMSFMXTaskDialog;
    procedure btnBorrarClick(Sender: TObject);
    procedure btnGruposClick(Sender: TObject);
    procedure btnWindowsClick(Sender: TObject);
    procedure btnCopiaClick(Sender: TObject);
    procedure btnPasswordClick(Sender: TObject);
    procedure btnPermisosClick(Sender: TObject);
    procedure btnNuevoClick(Sender: TObject);
    procedure btnColumnasClick(Sender: TObject);
    procedure cbAmbitoClosePopup(Sender: TObject);
    procedure FDMasterAfterScroll(DataSet: TDataSet);
    procedure FDMasterBeforePost(DataSet: TDataSet);
    procedure FDMasterPostError(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
    procedure TMSFMXLiveGrid1ColumnSized(Sender: TObject; ACol: Integer; NewWidth: Single);
    procedure TMSFMXLiveGrid1ColumnSorted(Sender: TObject; ACol: Integer; Direction: TSortDirection);
  private
    fFMXUserControl: TFMXUserControl;
    GridColumnsWidth: array of Single;
    FConnection: TFDConnection;
    FDTMaster: TFDTransaction;
    VerGlobales, VerLocales, CambiarAmbito, CambiarEmpresa: boolean;
  public
    destructor Destroy; override;
    constructor CreateEx(AOwner: TComponent; ATrans: TFDTransaction; AConn: TFDConnection; UC: TFMXUserControl);
  end;

implementation

{$R *.fmx}

uses
  FMX.UCMessages, uSelectorColumnas, FMX.UCHelpers, FMX.pUCGeral,
  FMX.uDialogoCopia,
  FMX.UcWindowsGroupUser, FMX.UcUsuariosGrupos, FMX.UcSenhaForm_U,
  FMX.UserPermis_U;

constructor TFMXUcFrame_User.CreateEx(AOwner: TComponent; ATrans: TFDTransaction; AConn: TFDConnection; UC: TFMXUserControl);
var
  i: Integer;
begin
  inherited Create(AOwner);
  fFMXUserControl := UC;
  FConnection := AConn;
  FDTMaster := ATrans;
  try
    cbAmbito.TagString := '5F5129FB-6EBD-4B5C-AE6E-AE2127D0A327';
    cbEmpresa.TagString := '7BA9145D-7A3A-49F9-9BE3-8E91DBA3C6AD';
    spDiasExpira.TagString := 'A1789FAA-B8B5-4EFA-862A-3BE0E3ECC3C7';
    ckbActivo.TagString := 'A70C8F59-DFA4-4737-B28E-7F85F8902EE1';
    btnNuevo.TagString := 'B02B8AF3-81BA-4924-84C2-9EDBD11E29AF';
    btnCopia.TagString := 'FF778863-F6FA-4852-9423-647915A466CE';
    btnBorrar.TagString := 'B129B1D9-2D53-4E8C-9DD3-F02AF4F3F583';
    btnPassword.TagString := 'ADACD432-ADF5-4D90-B5E2-BAB4748B45C3';
    btnPermisos.TagString := '38A6467C-A6A4-45AF-A69E-E1040F912F0E';
    btnGrupos.TagString := '4DCA8B65-6378-465D-99CD-88D6EC8794E0';
    btnWindows.TagString := 'F9F99820-F9E9-4821-99B6-1A6A2007F979';

    for i := 0 to (ComponentCount - 1) do
    begin
      If ((Components[i] Is TFDQuery)) Then
      begin
        TFDQuery(Components[i]).Transaction := FDTMaster;
        TFDQuery(Components[i]).UpdateTransaction := FDTMaster;
        TFDQuery(Components[i]).Connection := FConnection;
      end
      else if ((Components[i] Is TFDUpdateSQL)) then
        TFDUpdateSQL(Components[i]).Connection := FConnection
      else if ((Components[i] Is TFDStoredProc)) then
      begin
        TFDStoredProc(Components[i]).Connection := FConnection;
        TFDStoredProc(Components[i]).Transaction := FDTMaster;
        TFDStoredProc(Components[i]).UpdateTransaction := FDTMaster;
      end;
    end;

    CheckPermisos(Self, FConnection, FDTMaster, fFMXUserControl);

    CambiarEmpresa := CheckPermiso('7BA9145D-7A3A-49F9-9BE3-8E91DBA3C6AD', FConnection, FDTMaster, fFMXUserControl);
    CambiarAmbito := CheckPermiso('5F5129FB-6EBD-4B5C-AE6E-AE2127D0A327', FConnection, FDTMaster, fFMXUserControl);
    FDMaster.SQL.Clear;
    FDMaster.SQL.Add('SELECT A.*,I.NOMBRE AS EMPRESA FROM INT$UC_USERS A ');
    FDMaster.SQL.Add('LEFT JOIN INT$ENTIDAD I ON I.CLAVE=A.CLAVE_EMPRESA ');
    if not fFMXUserControl.CurrentUser.EsMaster then
    // Si es dios el que todo lo ve
    begin
      VerGlobales := CheckPermiso('3D843E9B-75FC-4C47-9825-6F6975B16DDA', FConnection, FDTMaster, fFMXUserControl);
      VerLocales := CheckPermiso('45F35A30-2F11-4E8E-B909-F715BD34905F', FConnection, FDTMaster, fFMXUserControl);
      if not VerGlobales and not VerLocales then
      begin
        FDMaster.SQL.Add('WHERE A.CLAVE=:PCLAVE');
        FDMaster.ParamByName('PCLAVE').AsInteger := fFMXUserControl.CurrentUser.UserID;
      end
      else
      begin
        FDMaster.SQL.Add('WHERE A.UCMASTER=:PUCMASTER  ');
        if VerGlobales and VerLocales then
          FDMaster.SQL.Add('AND A.UCAMBITO IN (' + QuotedStr('Global') + ',' + QuotedStr('Local') + ') ')
        else if VerGlobales then
          FDMaster.SQL.Add('AND A.UCAMBITO IN (' + QuotedStr('Global') + ') ')
        else
          FDMaster.SQL.Add('AND A.UCAMBITO IN (' + QuotedStr('Local') + ') ');
        if fFMXUserControl.CurrentUser.Ambito <> 'Global' then
        begin
          FDMaster.SQL.Add('AND A.CLAVE_EMPRESA=:PCLAVE_EMPRESA ');
          FDMaster.ParamByName('PCLAVE_EMPRESA').AsInteger := fFMXUserControl.CurrentUser.Empresa;
        end;
        FDMaster.ParamByName('PUCMASTER').AsString := 'FALSE';
      end;
    end;
    FDMaster.SQL.Add('!filtro');
    FDMaster.SQL.Add('!orden');
    FDMaster.Open;
    FDEmpresa.Open;
    SetLength(GridColumnsWidth, TMSFMXLiveGrid1.Columns.Count);
    SetArray(GridColumnsWidth, 68);
    LoadGridPreferences(GridColumnsWidth, TMSFMXLiveGrid1, fFMXUserControl.FormStorageRegRoot + '\UserControl', Self.Name);
  except
    on E: Exception do
      raise Exception.Create('Error conectando a Firebird');
  end;
end;

destructor TFMXUcFrame_User.Destroy;
begin
  SaveGridPreferences(fFMXUserControl.FormStorageRegRoot + '\UserControl', Self.Name, TMSFMXLiveGrid1);
  if FDMaster.State in [dsEdit, dsInsert] then
    FDMaster.Post;
  if FDTMaster.Active then
    FDTMaster.CommitRetaining;
  inherited;
end;

procedure TFMXUcFrame_User.btnBorrarClick(Sender: TObject);
var
  DAskAnyMore: boolean;
begin
  if FDMaster.RecordCount = 0 then
    exit;

  if (not fFMXUserControl.User.ProtectAdministrator) and (FDMaster.FieldByName('UCLOGIN').AsString = fFMXUserControl.Login.InitialLogin.User) then
  begin
    TaskDialog.Title := 'Atencion';
    TaskDialog.Content := 'Usuario protegido. Operación no permitida';
    TaskDialog.commonButtons := [TFMXCommonButton.OK];
    TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 12);
    TaskDialog.Show;
    exit;
  end;

  DAskAnyMore := boolean(ReadPropertyFromReg(fFMXUserControl.FormStorageRegRoot + '\UserControl\FUsuarios\Dialogs\OnDeleteUser\', 'NoAskAnyMore'));
  if not DAskAnyMore then
  begin
    TaskDialog.Title := 'Confirmación';
    TaskDialog.Content := Format(fFMXUserControl.UserSettings.UsersForm.PromptDelete, [FDMaster.FieldByName('UCLOGIN').AsString]);
    TaskDialog.VerificationText := 'No volver a preguntar';
    TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 13);
    TaskDialog.Show(
      procedure(ButtonID: Integer)
      begin
        case ButtonID of
          mrYes:
            begin
              FDMaster.Delete;
              FDMaster.Refresh;
            end;
        end;
        if TaskDialog.VerifyResult then
          SavePropertyOnReg(fFMXUserControl.FormStorageRegRoot + '\UserControl\FUsuarios\Dialogs\OnDeleteUser\', 'NoAskAnyMore', True);
      end);
  end
  else
  begin
    FDMaster.Delete;
    FDMaster.Refresh;
  end;
end;

procedure TFMXUcFrame_User.btnCopiaClick(Sender: TObject);
begin
  if not Assigned(FMXUcDialogoCopia) then
    FMXUcDialogoCopia := TFMXUcDialogoCopia.Create(Self);
  try
    try
      FMXUcDialogoCopia.Caption := 'Copiar Usuario';
      FMXUcDialogoCopia.LbDesc.Text := 'Copiando el Usuario';
      FMXUcDialogoCopia.lbUser.Text := FDMaster.FieldByName('UCLOGIN').AsString;
      FMXUcDialogoCopia.ModoDialogo := 1;
      if FMXUcDialogoCopia.ShowModal = mrOk then
      begin
        FDProcCopiaUsuario.ParamByName('PCLAVE_USUARIO').AsInteger := FDMaster.FieldByName('CLAVE').AsInteger;
        FDProcCopiaUsuario.ParamByName('PLOGIN').AsString := FMXUcDialogoCopia.edtNombre.Text;
        FDProcCopiaUsuario.ParamByName('PALIAS').AsString := FMXUcDialogoCopia.edtAlias.Text;
        FDProcCopiaUsuario.ParamByName('PPASSWORD').AsString := FMXUcDialogoCopia.edtPass.Text;
        FDProcCopiaUsuario.ParamByName('PCOPIA_PERMISOS').AsString := BoolToTF(FMXUcDialogoCopia.ckbCopiaPer.isChecked);
        FDProcCopiaUsuario.ParamByName('PCOPIA_MIEMBROS').AsString := BoolToTF(FMXUcDialogoCopia.ckbCopiaMiem.isChecked);
        FDProcCopiaUsuario.ParamByName('PCOPIA_WIN').AsString := BoolToTF(FMXUcDialogoCopia.ckbCopiaWin.isChecked);
        FDProcCopiaUsuario.ExecProc;
        if FDProcCopiaUsuario.Transaction.Active then
          FDProcCopiaUsuario.Transaction.CommitRetaining;
        FDMaster.Refresh;
        TFMXFormUserPerf(Self.Owner).Modificado := True;
      end;
    except
      on E: Exception do
      begin
        if FDProcCopiaUsuario.Transaction.Active then
          FDProcCopiaUsuario.Transaction.RollbackRetaining;
        TaskDialog.Title := 'Error grave';
        TaskDialog.Content := E.Message;
        TaskDialog.InstructionText := 'Se ha producido una excepción';
        TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 10);
        TaskDialog.Show();
      end;
    end;
  finally
    FreeAndNil(FMXUcDialogoCopia);
  end;
end;

procedure TFMXUcFrame_User.btnNuevoClick(Sender: TObject);
var
  DAskAnyMore: boolean;
begin
  DAskAnyMore := boolean(ReadPropertyFromReg(fFMXUserControl.FormStorageRegRoot + '\UserControl\FUsuarios\Dialogs\OnCreateUser\', 'NoAskAnyMore'));
  if not DAskAnyMore then
  begin
    TaskDialog.Title := 'Confirmación';
    TaskDialog.Content := '¿Seguro que deseas crear un nuevo usuario?';
    TaskDialog.VerificationText := 'No volver a preguntar';
    TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 13);
    TaskDialog.Show(
      procedure(ButtonID: Integer)
      begin
        case ButtonID of
          mrYes:
            begin
              FDMaster.UpdateOptions.ReadOnly := false;
              FDMaster.Append;
              FDMaster.FieldByName('UCUSERNAME').AsString := 'Nuevo Alias ' + IntToStr(FDMaster.RecordCount + 1);
              FDMaster.FieldByName('UCMASTER').AsString := 'FALSE';
              FDMaster.FieldByName('UCAMBITO').AsString := 'Global';
              FDMaster.FieldByName('UCINATIVE').AsString := 'TRUE';
              FDMaster.FieldByName('UCUSERDAYSSUN').AsInteger := 30;
              FDMaster.FieldByName('UCUSEREXPIRED').AsString := 'FALSE';
              FDMaster.FieldByName('UCNIVEL').AsInteger := 1;
              FDMaster.FieldByName('UCPASSLOCK').AsString := 'FALSE';
              FDMaster.FieldByName('UCPASSMUSTCHANGE').AsString := 'FALSE';
              FDMaster.Post;
              FDMaster.Refresh;
            end;
        end;
        if TaskDialog.VerifyResult then
          SavePropertyOnReg(fFMXUserControl.FormStorageRegRoot + '\UserControl\FUsuarios\Dialogs\OnCreateUser\', 'NoAskAnyMore', True);
      end);
  end
  else
  begin
    FDMaster.UpdateOptions.ReadOnly := false;
    FDMaster.Append;
    FDMaster.FieldByName('UCUSERNAME').AsString := 'Nuevo Alias ' + IntToStr(FDMaster.RecordCount + 1);
    FDMaster.FieldByName('UCMASTER').AsString := 'FALSE';
    FDMaster.FieldByName('UCAMBITO').AsString := 'Global';
    FDMaster.FieldByName('UCINATIVE').AsString := 'TRUE';
    FDMaster.FieldByName('UCUSERDAYSSUN').AsInteger := 30;
    FDMaster.FieldByName('UCUSEREXPIRED').AsString := 'FALSE';
    FDMaster.FieldByName('UCNIVEL').AsInteger := 1;
    FDMaster.FieldByName('UCPASSLOCK').AsString := 'FALSE';
    FDMaster.FieldByName('UCPASSMUSTCHANGE').AsString := 'FALSE';
    FDMaster.Post;
    FDMaster.Refresh;
  end;

  // if Assigned(fFMXUserControl.OnAddUser) then
  // fFMXUserControl.OnAddUser(Self, Login, Password, Name, Mail, Profile, Privuser);

end;

procedure TFMXUcFrame_User.btnColumnasClick(Sender: TObject);
begin
  if not Assigned(FSelectorColumas) then
    FSelectorColumas := TFSelectorColumas.CreateWithGrid(Self, TMSFMXLiveGrid1);
  FSelectorColumas.Caption := 'Selector de columnas tabla: Pedidos Pendientes';
  FSelectorColumas.ShowModal;
end;

procedure TFMXUcFrame_User.btnWindowsClick(Sender: TObject);
begin
  if FDMaster.IsEmpty then
    exit;

  if (not fFMXUserControl.User.ProtectAdministrator) and (FDMaster.FieldByName('UCLOGIN').AsString = fFMXUserControl.Login.InitialLogin.User) then
  begin
    TaskDialog.Title := 'Atención';
    TaskDialog.Content := 'Este es un usuario protegido, realize esta operación con cautela';
    TaskDialog.commonButtons := [TFMXCommonButton.OK];
    TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 12);
    TaskDialog.Show;
  end;

  if not Assigned(FMXUcWindowsGroupUser) then
    FMXUcWindowsGroupUser := TFMXUcWindowsGroupUser.CreateEx(Self, 'localhost', FDTMaster, FConnection, fFMXUserControl);
  FMXUcWindowsGroupUser.Clave := FDMaster.FieldByName('CLAVE').AsInteger;
  FMXUcWindowsGroupUser.Caption := 'Propiedades de: ' + FDMaster.FieldByName('UCLOGIN').AsString;
  FMXUcWindowsGroupUser.LbDescricao.Text := 'Usuarios de windows Vinculados a: ';
  FMXUcWindowsGroupUser.lbUser.Text := FDMaster.FieldByName('UCLOGIN').AsString;
  if FMXUcWindowsGroupUser.ShowModal = mrOk then
    TFMXFormUserPerf(Self.Owner).Modificado := True;
end;

procedure TFMXUcFrame_User.btnGruposClick(Sender: TObject);
begin
  if FDMaster.IsEmpty then
    exit;

  if (not fFMXUserControl.User.ProtectAdministrator) and (FDMaster.FieldByName('UCLOGIN').AsString = fFMXUserControl.Login.InitialLogin.User) then
  begin
    TaskDialog.Title := 'Atencion';
    TaskDialog.Content := 'Este es un usuario protegido, realize esta operación con cautela';
    TaskDialog.commonButtons := [TFMXCommonButton.OK];
    TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 12);
    TaskDialog.Show;
  end;

  if not Assigned(FMXUcUsuariosGrupos) then
    FMXUcUsuariosGrupos := TFMXUcUsuariosGrupos.CreateEx(Self, FDTMaster, FConnection, fFMXUserControl);
  FMXUcUsuariosGrupos.Clave := FDMaster.FieldByName('CLAVE').AsInteger;
  FMXUcUsuariosGrupos.Ambito := FDMaster.FieldByName('UCAMBITO').AsString;
  FMXUcUsuariosGrupos.Empresa := FDMaster.FieldByName('CLAVE_EMPRESA').AsInteger;
  FMXUcUsuariosGrupos.AMaster := (FDMaster.FieldByName('UCMASTER').AsString = 'TRUE');
  FMXUcUsuariosGrupos.Modo := 2;
  // 1 muestra usuarios --- 2 muestra grupos
  FMXUcUsuariosGrupos.Caption := 'Propiedades de: ' + FDMaster.FieldByName('UCLOGIN').AsString;
  FMXUcUsuariosGrupos.LbDescricao.Text := 'Grupos a los que pertenece el usuario: ';
  FMXUcUsuariosGrupos.lbUser.Text := FDMaster.FieldByName('UCLOGIN').AsString;
  FMXUcUsuariosGrupos.btnNuevo.Hint := 'Nuevo Grupo';
  FMXUcUsuariosGrupos.btnBorrar.Hint := 'Borrar Grupo';
  if FMXUcUsuariosGrupos.ShowModal = mrOk then
    TFMXFormUserPerf(Self.Owner).Modificado := True;
end;

procedure TFMXUcFrame_User.btnPermisosClick(Sender: TObject);
begin
  if not Assigned(FMXUserPermis) then
  begin
    FMXUserPermis := TFMXUserPermis.CreateEx(Self, FDTMaster, FConnection, fFMXUserControl);
    FMXUserPermis.IsGroup := false;
    FMXUserPermis.Caption := 'Gestión de permisos ';
    FMXUserPermis.LbDescricao.Text := 'Permisos aplicados al usuario: ';
  end;
  if FDMaster.FieldByName('UCUSERNAME').AsString = '' then
    FMXUserPermis.lbUser.Text := FDMaster.FieldByName('UCLOGIN').AsString
  else
    FMXUserPermis.lbUser.Text := FDMaster.FieldByName('UCUSERNAME').AsString;
  FMXUserPermis.Clave := FDMaster.FieldByName('CLAVE').AsInteger;
  if FMXUserPermis.ShowModal = mrOk then
    TFMXFormUserPerf(Self.Owner).Modificado := True;

end;

procedure TFMXUcFrame_User.btnPasswordClick(Sender: TObject);
begin
  if FDMaster.IsEmpty then
    exit;

  if (not fFMXUserControl.User.ProtectAdministrator) and (FDMaster.FieldByName('UCLOGIN').AsString = fFMXUserControl.Login.InitialLogin.User) then
  begin
    TaskDialog.Title := 'Atencion';
    TaskDialog.Content := 'Este es un usuario protegido, realize esta operación con cautela';
    TaskDialog.commonButtons := [TFMXCommonButton.OK];
    TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 12);
    TaskDialog.Show;
  end;

  FMXUcSenhaForm := TFMXUcSenhaForm.Create(Self);
  try
    FMXUcSenhaForm.Position := fFMXUserControl.UserSettings.WindowsPosition;
    FMXUcSenhaForm.fFMXUserControl := fFMXUserControl;

    FMXUcSenhaForm.Caption := Format(fFMXUserControl.UserSettings.ResetPassword.WindowCaption, [FDMaster.FieldByName('UCLOGIN').AsString]);
    if FMXUcSenhaForm.ShowModal = mrOk then
    Begin
      if FDMaster.FieldByName('UCEMAIL').AsString <> '' then
      begin
        if Assigned(fFMXUserControl.MailUserControl) then
          try
            fFMXUserControl.MailUserControl.EnviaEmailSenhaForcada(FDMaster.FieldByName('CLAVE').AsInteger, FMXUcSenhaForm.edtSenha.Text);
          except
            on E: Exception do
              fFMXUserControl.Log(E.Message, 0);
          end;
      end;
      ShowMessage('guardando contraseña ' + FMXUcSenhaForm.edtSenha.Text + 'usuario' + FDMaster.FieldByName('CLAVE').AsString);
      fFMXUserControl.ChangePassword(FDTMaster, FDMaster.FieldByName('CLAVE').AsInteger, FMXUcSenhaForm.edtSenha.Text);
      TFMXFormUserPerf(Self.Owner).Modificado := True;
    End;
  finally
    FreeAndNil(FMXUcSenhaForm);
  end;
end;

procedure TFMXUcFrame_User.cbAmbitoClosePopup(Sender: TObject);
var
  i: Integer;
begin
  i := cbAmbito.ItemIndex;
  if FDMaster.FieldByName('UCAMBITO').AsString <> cbAmbito.Selected.Text then
  begin
    FDRelacion.Close;
    FDRelacion.ParamByName('PCLAVE').AsInteger := FDMaster.FieldByName('CLAVE').AsInteger;
    FDRelacion.Open;
    if FDRelacion.RecordCount > 0 then
    begin
      TaskDialog.Title := 'Atencion';
      TaskDialog.Content := 'El usuario tiene grupos asignados no se puede cambiar el ambito mientras no elimine las asignaciones';
      TaskDialog.commonButtons := [TFMXCommonButton.OK];
      TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 12);
      TaskDialog.Show;
      cbAmbito.ItemIndex := i;
      exit;
    end;
  end;
  if CambiarEmpresa then
    cbEmpresa.Enabled := (cbAmbito.ItemIndex = 1);
end;

procedure TFMXUcFrame_User.FDMasterAfterScroll(DataSet: TDataSet);
begin
  if FDMaster.FieldByName('UCAMBITO').AsString = '' then
    cbAmbito.ItemIndex := 0
  else
    cbAmbito.ItemIndex := cbAmbito.Items.IndexOf(FDMaster.FieldByName('UCAMBITO').AsString);

  if CambiarAmbito then
    cbAmbito.Enabled := FDMaster.FieldByName('UCMASTER').AsString = 'FALSE';

  if (FDMaster.FieldByName('UCAMBITO').AsString = 'Global') or (FDMaster.FieldByName('UCMASTER').AsString = 'TRUE') then
  begin
    Label13.Text := 'Empresa Inicial';
    LinkFillControlToField1.FieldName := 'UCEMPRESA_INICIAL';

  end
  else
  begin
    Label13.Text := 'Empresa';
    LinkFillControlToField1.FieldName := 'CLAVE_EMPRESA';
  end;
end;

procedure TFMXUcFrame_User.FDMasterBeforePost(DataSet: TDataSet);
begin
  with FDMaster do
    FieldByName('UCKEY').AsString := GetKeyTUsuario(FieldByName('CLAVE').AsInteger, FieldByName('UCLOGIN').AsString,
      FieldByName('UCPASSWORD').AsString, True);
end;

procedure TFMXUcFrame_User.FDMasterPostError(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
var
  oExc: EFDDBEngineException;
begin
  if E is EIBNativeException then
  begin
    oExc := EFDDBEngineException(E);
    if oExc.Kind = ekUKViolated then
    begin
      if DataSet.FieldByName('CLAVE_EMPRESA').IsNull then
      begin
        TaskDialog.Title := 'Atencion';
        TaskDialog.InstructionText := 'El Usuario ' + DataSet.FieldByName('UCLOGIN').AsString + ' ya existe.';
        TaskDialog.commonButtons := [TFMXCommonButton.OK];
        TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 12);
        TaskDialog.Show;
      end
      else
      begin
        TaskDialog.Title := 'Atencion';
        TaskDialog.InstructionText := 'El Usuario ' + DataSet.FieldByName('UCLOGIN').AsString + ' ya existe para la empresa ' +
          FDEmpresa.FieldByName('NOMBRE').AsString + '.';
        TaskDialog.commonButtons := [TFMXCommonButton.OK];
        TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 12);
        TaskDialog.Show;
      end;
      Action := daAbort;
      FDMaster.Cancel;
    end;
  end;
end;

procedure TFMXUcFrame_User.TMSFMXLiveGrid1ColumnSized(Sender: TObject; ACol: Integer; NewWidth: Single);
begin
  GridColumnsWidth[ACol] := NewWidth;
end;

procedure TFMXUcFrame_User.TMSFMXLiveGrid1ColumnSorted(Sender: TObject; ACol: Integer; Direction: TSortDirection);
var
  Direccion, Field: String;
  i: Integer;
begin
  if Direction = TSortDirection.sdAscending then
    Direccion := ' ASC'
  else
    Direccion := ' DESC';
  Field := LinkGridToDataSourceBindSourceDB1.Columns.Items[ACol].MemberName;
  FDMaster.MacroByName('orden').AsRaw := 'ORDER BY ' + Field + Direccion;
  FDMaster.Open;
  for i := 0 to TTMSFMXLiveGrid(Sender).Columns.Count - 1 do
  begin
    TTMSFMXLiveGrid(Sender).Columns.Items[i].Width := GridColumnsWidth[i];
  end;
end;

end.
