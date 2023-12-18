unit FMX.pUcFrame_Profile;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.UCBase, System.UIConsts, FMX.Platform.Win, Winapi.CommDlg,
  Winapi.Windows,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, Data.Bind.Controls, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.Client, Data.DB, FireDAC.Comp.DataSet,
  FMX.TMSBaseControl, FMX.TMSGridCell,
  FMX.TMSGridOptions, FMX.TMSGridData, FMX.TMSCustomGrid, FMX.TMSLiveGrid, FMX.Menus, FMX.Layouts, FMX.Bind.Navigator, FMX.Objects,
  FMX.Controls.Presentation, System.ImageList,
  FMX.ImgList, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.FMXUI.Wait, FMX.Edit,
  FMX.ListBox,
  FMX.TMSPageControl, FMX.TMSCustomControl, FMX.TMSTabSet, System.Rtti, System.Bindings.Outputs, FMX.Bind.Editors, Data.Bind.EngExt,
  FMX.Bind.DBEngExt, FMX.TMSLiveGridDataBinding,
  Data.Bind.Grid, Data.Bind.Components, Data.Bind.DBScope, FireDAC.Phys.IBWrapper, FMX.TMSTaskDialog;

type
  TFMXUcFrame_Profile = class(TFrame)
    ImageList1: TImageList;
    Panel2: TPanel;
    btnNuevo: TButton;
    btnCopiar: TButton;
    btnBorrar: TSpeedButton;
    PopupMenu1: TPopupMenu;
    StyleBook1: TStyleBook;
    FDProcCopiaGrupo: TFDStoredProc;
    FDMaster: TFDQuery;
    FDUMaster: TFDUpdateSQL;
    FDConnection1: TFDConnection;
    FDEmpresa: TFDQuery;
    btnColumnas: TSpeedButton;
    btnMiembros: TSpeedButton;
    btnPermisos: TSpeedButton;
    btnFiltro: TSpeedButton;
    btnBuscar: TSpeedButton;
    RectangleC: TRectangle;
    btnColor: TSpeedButton;
    TMSFMXPageControl1: TTMSFMXPageControl;
    Panel3: TPanel;
    BindNavigator1: TBindNavigator;
    TMSFMXPageControl1Page0: TTMSFMXPageControlContainer;
    GridPanelLayout1: TGridPanelLayout;
    Label2: TLabel;
    cbAmbito: TComboBox;
    Label4: TLabel;
    Edit2: TEdit;
    cbMaster: TCheckBox;
    Label13: TLabel;
    cbEmpresa: TComboBox;
    Label18: TLabel;
    Edit4: TEdit;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkControlToField1: TLinkControlToField;
    LinkControlToField2: TLinkControlToField;
    LinkControlToField3: TLinkControlToField;
    BindSourceDB2: TBindSourceDB;
    LinkFillControlToField1: TLinkFillControlToField;
    TMSFMXLiveGrid1: TTMSFMXLiveGrid;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    TaskDialog: TTMSFMXTaskDialog;
    procedure btnNuevoClick(Sender: TObject);
    procedure btnCopiarClick(Sender: TObject);
    procedure btnBorrarClick(Sender: TObject);
    procedure btnMiembrosClick(Sender: TObject);
    procedure btnPermisosClick(Sender: TObject);
    procedure TMSFMXLiveGrid1ColumnSized(Sender: TObject; ACol: Integer; NewWidth: Single);
    procedure btnColumnasClick(Sender: TObject);
    procedure TMSFMXLiveGrid1ColumnSorted(Sender: TObject; ACol: Integer; Direction: TSortDirection);
    procedure btnColorClick(Sender: TObject);
    procedure FDMasterAfterOpen(DataSet: TDataSet);
    procedure FDMasterAfterPost(DataSet: TDataSet);
    procedure FDMasterAfterScroll(DataSet: TDataSet);
    procedure FDMasterBeforePost(DataSet: TDataSet);
    procedure FDMasterPostError(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
    procedure cbAmbitoChange(Sender: TObject);
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

const
  MaxCustomColors = 16;

type
  TCustomColors = array [0 .. MaxCustomColors - 1] of Longint;

implementation

{$R *.fmx}

uses FMX.UcUsuariosGrupos, FMX.UCHelpers, FMX.uDialogoCopia, FMX.UserPermis_U, uSelectorColumnas, FMX.pUCGeral;

constructor TFMXUcFrame_Profile.CreateEx(AOwner: TComponent; ATrans: TFDTransaction; AConn: TFDConnection; UC: TFMXUserControl);
var
  i: Integer;
begin
  inherited Create(AOwner);
  try
    fFMXUserControl := UC;
    FConnection := AConn;
    FDTMaster := ATrans;

    cbAmbito.TagString := '5EE1CBB4-3ADD-4038-918B-4A0366F4F758';
    cbEmpresa.TagString := '77C077EF-4C70-4016-814F-A34FEE9CC9D8';
    btnNuevo.TagString := 'AF46491B-414B-42A0-B53C-3D10A4534EB7';
    btnBorrar.TagString := 'FD9B4AE6-45DC-40C9-9556-E2D1CF2BB51C';
    btnPermisos.TagString := 'DB8A3DDB-DEB0-43DE-846C-BFBC78307245';
    btnMiembros.TagString := '4F6206C7-7DD2-4F23-B7BE-B2420B017989';

    for i := 0 to (ComponentCount - 1) do
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

    CheckPermisos(Self, FConnection, FDTMaster, fFMXUserControl);

    // cbMaster.Enabled := fFMXUserControl.CurrentUser.EsMaster;
    // DBCheckBox5.Enabled := DBCheckBox1.Enabled;
    CambiarEmpresa := CheckPermiso('77C077EF-4C70-4016-814F-A34FEE9CC9D8', FConnection, FDTMaster, fFMXUserControl);
    CambiarAmbito := CheckPermiso('DB8A3DDB-DEB0-43DE-846C-BFBC78307245', FConnection, FDTMaster, fFMXUserControl);

    FDMaster.SQL.Clear;
    FDMaster.SQL.Add('SELECT A.*,IIF(A.UCAMBITO=''Local'',I.NOMBRE,NULL) AS EMPRESA FROM INT$UC_GROUPS A');
    FDMaster.SQL.Add('LEFT JOIN INT$ENTIDAD I ON I.CLAVE=A.CLAVE_EMPRESA ');
    if not fFMXUserControl.CurrentUser.EsMaster then // Si NO es dios el que todo lo ve
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
      end;
      if fFMXUserControl.CurrentUser.Ambito <> 'Global' then
      begin
        FDMaster.SQL.Add('AND A.CLAVE_EMPRESA=:PCLAVE_EMPRESA ');
        FDMaster.ParamByName('PCLAVE_EMPRESA').AsInteger := fFMXUserControl.CurrentUser.Empresa;
      end;
      if VerGlobales and VerLocales then
        FDMaster.ParamByName('PUCMASTER').AsString := 'FALSE';
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

destructor TFMXUcFrame_Profile.Destroy;
begin
  SaveGridPreferences(fFMXUserControl.FormStorageRegRoot + '\UserControl', Self.Name, TMSFMXLiveGrid1);
  if FDMaster.State in [dsEdit, dsInsert] then
    FDMaster.Post;
  if FDTMaster.Active then
    FDTMaster.CommitRetaining;
  inherited;
end;

procedure TFMXUcFrame_Profile.FDMasterAfterOpen(DataSet: TDataSet);
begin
  FDMaster.UpdateOptions.ReadOnly := FDMaster.RecordCount = 0;
  if CambiarEmpresa then
    cbEmpresa.Enabled := not FDMaster.UpdateOptions.ReadOnly;
  if CambiarAmbito then
    cbAmbito.Enabled := not FDMaster.UpdateOptions.ReadOnly;
end;

procedure TFMXUcFrame_Profile.FDMasterAfterPost(DataSet: TDataSet);
begin
  TFMXFormUserPerf(Self.Owner).Modificado := True;
end;

procedure TFMXUcFrame_Profile.FDMasterAfterScroll(DataSet: TDataSet);
begin
  if FDMaster.RecordCount = 0 then
    exit;

  if FDMaster.FieldByName('UC_COLOR').AsString <> '' then
  begin
    RectangleC.Fill.Color := StringToColor(FDMaster.FieldByName('UC_COLOR').AsString);
  end;

  if FDMaster.FieldByName('UCAMBITO').AsString = '' then
    cbAmbito.ItemIndex := 0
  else
    cbAmbito.ItemIndex := cbAmbito.Items.IndexOf(FDMaster.FieldByName('UCAMBITO').AsString);

  if CambiarEmpresa then
    cbEmpresa.Enabled := (not SameText(FDMaster.FieldByName('UC_NOMBRE').AsString, fFMXUserControl.Login.InitialLogin.GroupName) and
      (FDMaster.FieldByName('UCAMBITO').AsString <> 'Global'));

  if CambiarAmbito then
    cbAmbito.Enabled := (not SameText(FDMaster.FieldByName('UC_NOMBRE').AsString, fFMXUserControl.Login.InitialLogin.GroupName));
end;

procedure TFMXUcFrame_Profile.FDMasterBeforePost(DataSet: TDataSet);
begin
  with FDMaster do
  begin
    FieldByName('UKEY').AsString := GetKeyTGrupo(FieldByName('CLAVE').AsInteger, FieldByName('CLAVE_EMPRESA').AsInteger,
      FieldByName('UC_NOMBRE').AsString);
  end;
end;

procedure TFMXUcFrame_Profile.FDMasterPostError(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
var
  oExc: EFDDBEngineException;
begin
  if E is EIBNativeException then
  begin
    oExc := EFDDBEngineException(E);
    if oExc.Kind = ekUKViolated then
    begin
      TaskDialog.Title := 'Atencion';
      TaskDialog.InstructionText := 'Violación de restricción de clave única';
      TaskDialog.Content := 'El grupo ' + DataSet.FieldByName('UC_NOMBRE').AsString + ' ya se ha utilizado en esta empresa';
      TaskDialog.commonButtons := [TFMXCommonButton.OK];
      TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 9);
      TaskDialog.Show;
      Action := daAbort;
      FDMaster.Cancel;
    end;
  end;
end;

procedure TFMXUcFrame_Profile.TMSFMXLiveGrid1ColumnSized(Sender: TObject; ACol: Integer; NewWidth: Single);
begin
  GridColumnsWidth[ACol] := NewWidth;
end;

procedure TFMXUcFrame_Profile.TMSFMXLiveGrid1ColumnSorted(Sender: TObject; ACol: Integer; Direction: TSortDirection);
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

procedure TFMXUcFrame_Profile.btnBorrarClick(Sender: TObject);
var
  CanDelete: boolean;
  ErrorMsg: String;
begin
  if FDMaster.IsEmpty then
    exit;

  if (not fFMXUserControl.User.ProtectAdministrator) and (FDMaster.FieldByName('UC_NOMBRE').AsString = fFMXUserControl.Login.InitialLogin.GroupName)
  then
  begin
    TaskDialog.Title := 'Atencion';
    TaskDialog.Content := 'Grupo protegido. Operación no permitida';
    TaskDialog.commonButtons := [TFMXCommonButton.OK];
    TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 11);
    TaskDialog.Show;
    exit;
  end;

  // if MessageBox(handle, PChar(Format(fFMXUserControl.UserSettings.UsersProfile.PromptDelete, [FDMaster.FieldByName('UC_NOMBRE').AsString])),
  // PChar(fFMXUserControl.UserSettings.UsersProfile.PromptDelete_WindowCaption), MB_ICONQUESTION or MB_YESNO or MB_DEFBUTTON2) <> idYes then
  // exit;

  CanDelete := True;
  if Assigned(fFMXUserControl.onDeleteProfile) then
    fFMXUserControl.onDeleteProfile(TObject(Owner), FDMaster.FieldByName('CLAVE').AsInteger, CanDelete, ErrorMsg);
  if not CanDelete then
  begin
    TaskDialog.Title := 'Atencion';
    TaskDialog.InstructionText := ErrorMsg;
    TaskDialog.commonButtons := [TFMXCommonButton.OK];
    TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 11);
    TaskDialog.Show;
    exit;
  end;
  FDMaster.Delete;
  FDMaster.Refresh;
end;

procedure TFMXUcFrame_Profile.btnColorClick(Sender: TObject);
var
  cc: TChooseColor;
  acrCustClr: TCustomColors;
begin
  FillChar(cc, sizeof(cc), #0);
  cc.lStructSize := sizeof(cc);
  cc.hwndOwner := FmxHandleToHWND(Tform(Self.Owner).Handle);
  cc.lpCustColors := @acrCustClr;
  cc.rgbResult := RGBtoBGR(RectangleC.Fill.Color);
  cc.Flags := CC_FULLOPEN OR CC_RGBINIT;
  if (ChooseColor(cc)) then
  begin
    RectangleC.Fill.Color := MakeColor(GetRValue(cc.rgbResult), GetGValue(cc.rgbResult), GetBValue(cc.rgbResult));
    FDMaster.Edit;
    FDMaster.FieldByName('UC_COLOR').AsString := ColorToString(RectangleC.Fill.Color);
    FDMaster.Post;
  end;
end;

procedure TFMXUcFrame_Profile.btnColumnasClick(Sender: TObject);
begin
  if not Assigned(FSelectorColumas) then
    FSelectorColumas := TFSelectorColumas.CreateWithGrid(Self, TMSFMXLiveGrid1);
  FSelectorColumas.Caption := 'Selector de columnas tabla: Pedidos Pendientes';
  FSelectorColumas.ShowModal;
end;

procedure TFMXUcFrame_Profile.btnCopiarClick(Sender: TObject);
begin
  if not Assigned(FMXUcDialogoCopia) then
    FMXUcDialogoCopia := TFMXUcDialogoCopia.Create(Self);
  try
    try
      FMXUcDialogoCopia.Caption := 'Copiar Grupo';
      FMXUcDialogoCopia.LbDesc.Text := 'Copiando el Grupo';
      FMXUcDialogoCopia.lbUser.Text := FDMaster.FieldByName('UC_NOMBRE').AsString;
      FMXUcDialogoCopia.ModoDialogo := 2;
      if FMXUcDialogoCopia.ShowModal = mrOk then
      begin
        FDProcCopiaGrupo.ParamByName('PCLAVE_GRUPO').AsInteger := FDMaster.FieldByName('CLAVE').AsInteger;
        FDProcCopiaGrupo.ParamByName('PNOMBRE').AsString := FMXUcDialogoCopia.edtNombre.Text;
        FDProcCopiaGrupo.ParamByName('PCOPIA_PERMISOS').AsString := BoolToTF(FMXUcDialogoCopia.ckbCopiaPer.isChecked);
        FDProcCopiaGrupo.ParamByName('PCOPIA_MIEMBROS').AsString := BoolToTF(FMXUcDialogoCopia.ckbCopiaMiem.isChecked);
        FDProcCopiaGrupo.ExecProc;
        if FDProcCopiaGrupo.Transaction.Active then
          FDProcCopiaGrupo.Transaction.CommitRetaining;
        FDMaster.Refresh;
        TFMXFormUserPerf(Self.Owner).Modificado := True;
      end;
    except
      on E: Exception do
      begin
        if FDProcCopiaGrupo.Transaction.Active then
          FDProcCopiaGrupo.Transaction.RollbackRetaining;
        TaskDialog.Title := 'Error';
        TaskDialog.InstructionText := E.Message;
        TaskDialog.commonButtons := [TFMXCommonButton.OK];
        TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 9);
        TaskDialog.Show;
      end;
    end;
  finally
    FreeAndNil(FMXUcDialogoCopia);
  end;
end;

procedure TFMXUcFrame_Profile.btnMiembrosClick(Sender: TObject);
begin
  if FDMaster.IsEmpty then
    exit;

  if (not fFMXUserControl.User.ProtectAdministrator) and (FDMaster.FieldByName('UC_NOMBRE').AsString = fFMXUserControl.Login.InitialLogin.GroupName)
  then
  begin
    TaskDialog.Title := 'Precaución';
    TaskDialog.InstructionText := 'Operación vigilada...';
    TaskDialog.Content := 'Grupo especial. Realice esta operación con precaución';
    TaskDialog.commonButtons := [TFMXCommonButton.OK];
    TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 11);
    TaskDialog.Show;
  end;

  if not Assigned(FMXUcUsuariosGrupos) then
    FMXUcUsuariosGrupos := TFMXUcUsuariosGrupos.CreateEx(Self, FDTMaster, FConnection, fFMXUserControl);
  FMXUcUsuariosGrupos.Clave := FDMaster.FieldByName('CLAVE').AsInteger;
  FMXUcUsuariosGrupos.Ambito := FDMaster.FieldByName('UCAMBITO').AsString;
  FMXUcUsuariosGrupos.Empresa := FDMaster.FieldByName('CLAVE_EMPRESA').AsInteger;
  FMXUcUsuariosGrupos.AMaster := (FDMaster.FieldByName('UCMASTER').AsString = 'TRUE');
  FMXUcUsuariosGrupos.Modo := 1; // 1 muestra usuarios --- 2 muestra grupos
  FMXUcUsuariosGrupos.Caption := 'Propiedades de: ' + FDMaster.FieldByName('UC_NOMBRE').AsString;
  FMXUcUsuariosGrupos.LbDescricao.Text := 'Usuarios asociados al Grupo ';

  FMXUcUsuariosGrupos.lbUser.Text := FDMaster.FieldByName('UC_NOMBRE').AsString;
  FMXUcUsuariosGrupos.btnNuevo.Hint := 'Nuevo Usuario';
  FMXUcUsuariosGrupos.btnBorrar.Hint := 'Borrar Usuario';
  if FMXUcUsuariosGrupos.ShowModal = mrOk then
    TFMXFormUserPerf(Self.Owner).Modificado := True;
end;

procedure TFMXUcFrame_Profile.btnNuevoClick(Sender: TObject);
var
  DAskAnyMore: boolean;
begin
  DAskAnyMore := boolean(ReadPropertyFromReg(fFMXUserControl.FormStorageRegRoot + '\UserControl\FProfile\Dialogs\OnCreateGroup\', 'NoAskAnyMore'));
  if not DAskAnyMore then
  begin
    TaskDialog.Title := 'Confirmación';
    TaskDialog.Content := '¿Seguro que deseas crear un nuevo grupo? ';
    TaskDialog.VerificationText := 'No volver a preguntar';
    TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 13);
    TaskDialog.Show(
      procedure(ButtonID: Integer)
      begin
        case ButtonID of
          mrYes:
            begin
              FDMaster.UpdateOptions.ReadOnly := False;
              if CambiarEmpresa then
                cbEmpresa.Enabled := not FDMaster.UpdateOptions.ReadOnly;
              if CambiarAmbito then
                cbAmbito.Enabled := not FDMaster.UpdateOptions.ReadOnly;
              FDMaster.Append;
              FDMaster.FieldByName('UC_NOMBRE').AsString := 'Nuevo Grupo ' + IntToStr(FDMaster.RecordCount + 1);
              FDMaster.FieldByName('UCMASTER').AsString := 'FALSE';
              FDMaster.FieldByName('UCAMBITO').AsString := 'Global';
              FDMaster.Post;
              FDMaster.Refresh;
            end;
        end;
        if TaskDialog.VerifyResult then
          SavePropertyOnReg(fFMXUserControl.FormStorageRegRoot + '\UserControl\FProfile\Dialogs\OnCreateGroup\', 'NoAskAnyMore', True);
      end);
  end
  else
  begin
    FDMaster.UpdateOptions.ReadOnly := False;
    if CambiarEmpresa then
      cbEmpresa.Enabled := not FDMaster.UpdateOptions.ReadOnly;
    if CambiarAmbito then
      cbAmbito.Enabled := not FDMaster.UpdateOptions.ReadOnly;
    FDMaster.Append;
    FDMaster.FieldByName('UC_NOMBRE').AsString := 'Nuevo Grupo ' + IntToStr(FDMaster.RecordCount + 1);
    FDMaster.FieldByName('UCMASTER').AsString := 'FALSE';
    FDMaster.FieldByName('UCAMBITO').AsString := 'Global';
    FDMaster.Post;
    FDMaster.Refresh;
  end;
end;

procedure TFMXUcFrame_Profile.btnPermisosClick(Sender: TObject);
begin
  if (not fFMXUserControl.User.ProtectAdministrator) and (FDMaster.FieldByName('UC_NOMBRE').AsString = fFMXUserControl.Login.InitialLogin.GroupName)
  then
  begin
    TaskDialog.Title := 'Precaución';
    TaskDialog.InstructionText := 'Operación vigilada...';
    TaskDialog.Content := 'Grupo especial.Modificar los permisos podría limitar el acceso a funciones vitales, ¿Esta seguro de querer continuar?';
    TaskDialog.commonButtons := [TFMXCommonButton.Yes, TFMXCommonButton.No];
    TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 11);
    TaskDialog.Show(
      procedure(ButtonID: Integer)
      begin
        case ButtonID of
          mrNo:
            begin
              exit;
            end;
        end;
      end);
  end;

  if not Assigned(FMXUserPermis) then
  begin
    FMXUserPermis := TFMXUserPermis.Create(Self);
    FMXUserPermis := TFMXUserPermis.CreateEx(Self, FDTMaster, FConnection, fFMXUserControl);
    FMXUserPermis.IsGroup := True;

    // if UseExternalMode then
    // FMXUserPermis.lbUser.Caption := GridGrupos.Cells[1, GridGrupos.Row];
    // SetWindowProfile;
    // FMXUserPermis.lbUser.Caption := FDataSetPerfilUsuario.FieldByName('Nome').AsString;
    // ActionBtPermissProfileDefault;
  end;
  // if UseExternalMode then
  // FMXUserPermis.FSID := GridGrupos.Cells[0, GridGrupos.Row];
  FMXUserPermis.Clave := FDMaster.FieldByName('CLAVE').AsInteger;
  if FMXUserPermis.ShowModal = mrOk then
    TFMXFormUserPerf(Self.Owner).Modificado := True
end;

procedure TFMXUcFrame_Profile.cbAmbitoChange(Sender: TObject);
begin
  // i := cbAmbito.ItemIndex;
  if FDMaster.FieldByName('UCAMBITO').AsString <> cbAmbito.Selected.Text then
  begin
    // FDRelacion.Close;
    // FDRelacion.ParamByName('PCLAVE').AsInteger := FDMaster.FieldByName('CLAVE').AsInteger;
    // FDRelacion.Open;
    // if FDRelacion.RecordCount > 0 then
    // begin
    // MessageDlg('El usuario tiene grupos asignados no se puede cambiar el ambito mientras no elimine las asignaciones', mtError, [mbOK], 0);
    // cbAmbito.ItemIndex := i;
    // exit;
    // end;
  end;
  FDMaster.Edit;
  FDMaster.FieldByName('UCAMBITO').AsString := cbAmbito.Selected.Text;
  FDMaster.Post;
  if CambiarEmpresa then
    cbEmpresa.Enabled := (cbAmbito.ItemIndex = 1);
end;

end.
