unit FMX.UcUsuariosGrupos;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.UCBase, FireDAC.Phys.IBWrapper,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, Data.Bind.Controls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FMX.Menus, FireDAC.Comp.Client, Data.DB, FireDAC.Comp.DataSet,
  FMX.TMSBaseControl, FMX.TMSGridCell,
  FMX.TMSGridOptions, FMX.TMSGridData, FMX.TMSCustomGrid, FMX.TMSLiveGrid, FMX.Layouts, FMX.Bind.Navigator, FMX.StdCtrls, FMX.Objects,
  FMX.Controls.Presentation, System.ImageList,
  FMX.ImgList, FireDAC.Phys.FBDef, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.FMXUI.Wait,
  FireDAC.Phys.IBBase,
  Data.Bind.Components, Data.Bind.DBScope, Data.Bind.EngExt, FMX.Bind.DBEngExt, FMX.TMSLiveGridDataBinding, System.Rtti, System.Bindings.Outputs,
  FMX.Bind.Editors, Data.Bind.Grid,
  FMX.TMSTaskDialog;

type
  TFMXUcUsuariosGrupos = class(TForm)
    ImageList1: TImageList;
    Panel1: TPanel;
    Image1: TImage;
    LbDescricao: TLabel;
    lbUser: TLabel;
    Panel2: TPanel;
    btnNuevo: TButton;
    Button5: TButton;
    btnBorrar: TButton;
    Panel4: TPanel;
    Button3: TButton;
    StyleBook1: TStyleBook;
    FDGrupos: TFDQuery;
    FDUGruposUsuarios: TFDUpdateSQL;
    FDUUsuariosGrupos: TFDUpdateSQL;
    FDUsuarios: TFDQuery;
    FDExisteRegistro: TFDQuery;
    PopupMenu1: TPopupMenu;
    BindNavigator1: TBindNavigator;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    FDConnection1: TFDConnection;
    Button2: TButton;
    BindSourceDB2: TBindSourceDB;
    BindSourceDB3: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB3: TLinkGridToDataSource;
    TMSFMXLiveGrid1: TTMSFMXLiveGrid;
    TaskDialog: TTMSFMXTaskDialog;
    procedure btnNuevoClick(Sender: TObject);
    procedure FDUsuariosPostError(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnBorrarClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure TMSFMXLiveGrid1ColumnSized(Sender: TObject; ACol: Integer; NewWidth: Single);
    procedure TMSFMXLiveGrid1ColumnSorted(Sender: TObject; ACol: Integer; Direction: TSortDirection);
  private
    fFMXUserControl: TFMXUserControl;
    GridColumnsWidth: array of Single;
    FConnection: TFDConnection;
    FDTMaster: TFDTransaction;
    FDataset: TFDQuery;
    FNombre: String;
    ClaveUser, ClaveGrupo: Integer;
  public
    Clave: Integer;
    Modo: Integer;
    Ambito: string;
    Empresa: Integer;
    AMaster: boolean;
    constructor CreateEx(AOwner: TComponent; ATrans: TFDTransaction; AConn: TFDConnection; UC: TFMXUserControl);
  end;

var
  FMXUcUsuariosGrupos: TFMXUcUsuariosGrupos;

implementation

{$R *.fmx}

uses FMX.UCHelpers, FMX.UserPermis_U, FMX.UcUserSelector, uSelectorColumnas;

constructor TFMXUcUsuariosGrupos.CreateEx(AOwner: TComponent; ATrans: TFDTransaction; AConn: TFDConnection; UC: TFMXUserControl);
var
  i: Integer;
begin
  inherited Create(AOwner);
  fFMXUserControl := UC;
  FConnection := AConn;
  FDTMaster := ATrans;
  try
    for i := 0 to (ComponentCount - 1) do
      If ((Components[i] Is TFDQuery)) Then
      begin
        TFDQuery(Components[i]).Transaction := FDTMaster;
        TFDQuery(Components[i]).UpdateTransaction := FDTMaster;
        TFDQuery(Components[i]).Connection := FConnection;
      end
      else if ((Components[i] Is TFDUpdateSQL)) then
        TFDUpdateSQL(Components[i]).Connection := FConnection;
    SetLength(GridColumnsWidth, TMSFMXLiveGrid1.Columns.Count);
    SetArray(GridColumnsWidth, 68);
    LoadGridPreferences(GridColumnsWidth, TMSFMXLiveGrid1, fFMXUserControl.FormStorageRegRoot + '\UserControl', self.Name);
  except
    on E: Exception do
      raise Exception.Create('Error conectando a Firebird');
  end;
end;

procedure TFMXUcUsuariosGrupos.FDUsuariosPostError(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
var
  oExc: EFDDBEngineException;
begin
  if E is EIBNativeException then
  begin
    oExc := EFDDBEngineException(E);
    if oExc.Kind = ekUKViolated then
    begin
      TaskDialog.Title := 'Advertencia';
      TaskDialog.Content := 'El Login ' + FNombre + ' ya se utilizado en esta empresa';
      TaskDialog.InstructionText := 'Violación de restricción de clave única';
      TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 0);
      TaskDialog.Show();
      Action := daAbort;
      DataSet.Cancel;
    end;
  end;
end;

procedure TFMXUcUsuariosGrupos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveGridPreferences(fFMXUserControl.FormStorageRegRoot + '\UserControl', self.Name, TMSFMXLiveGrid1);
  Action := TCloseAction.caFree;
end;

procedure TFMXUcUsuariosGrupos.FormDestroy(Sender: TObject);
begin
  FMXUcUsuariosGrupos := nil;
end;

procedure TFMXUcUsuariosGrupos.FormShow(Sender: TObject);
begin
  case Modo of
    1:
      begin
        ClaveGrupo := Clave;
        FDataset := FDUsuarios;
        LinkGridToDataSourceBindSourceDB3.DataSource := BindSourceDB3;
        BindNavigator1.DataSource := BindSourceDB3;
      end;
    2:
      begin
        ClaveUser := Clave;
        FDataset := FDGrupos;
        LinkGridToDataSourceBindSourceDB3.DataSource := BindSourceDB2;
        BindNavigator1.DataSource := BindSourceDB2;
      end;
  end;
  FDataset.Close;
  FDataset.ParamByName('PCLAVE').AsInteger := Clave;
  FDataset.Open;

end;

procedure TFMXUcUsuariosGrupos.TMSFMXLiveGrid1ColumnSized(Sender: TObject; ACol: Integer; NewWidth: Single);
begin
  GridColumnsWidth[ACol] := NewWidth;
end;

procedure TFMXUcUsuariosGrupos.TMSFMXLiveGrid1ColumnSorted(Sender: TObject; ACol: Integer; Direction: TSortDirection);
var
  Direccion, Field: String;
  i: Integer;
begin
  if Direction = TSortDirection.sdAscending then
    Direccion := ' ASC'
  else
    Direccion := ' DESC';
  Field := LinkGridToDataSourceBindSourceDB3.Columns.Items[ACol].MemberName;
  FDataset.MacroByName('orden').AsRaw := 'ORDER BY ' + Field + Direccion;
  FDataset.Open;
  for i := 0 to TTMSFMXLiveGrid(Sender).Columns.Count - 1 do
  begin
    TTMSFMXLiveGrid(Sender).Columns.Items[i].Width := GridColumnsWidth[i];
  end;
end;

procedure TFMXUcUsuariosGrupos.btnBorrarClick(Sender: TObject);
begin
  if FDataset.RecordCount > 0 then
  begin
    FDataset.Delete;
    FDataset.Refresh;
  end;
end;

procedure TFMXUcUsuariosGrupos.btnNuevoClick(Sender: TObject);
var
  i: Integer;

  procedure GetData;
  begin
    case Modo of
      1:
        begin
          FNombre := 'El Usuario ' + FMXUcUserSelector.FDMaster.FieldByName('NOMBRE').AsString;
          ClaveUser := FMXUcUserSelector.FDMaster.FieldByName('CLAVE').AsInteger;
        end;
      2:
        begin
          FNombre := 'El Grupo ' + FMXUcUserSelector.FDMaster.FieldByName('NOMBRE').AsString;
          ClaveGrupo := FMXUcUserSelector.FDMaster.FieldByName('CLAVE').AsInteger;
        end;
    end;

    FDExisteRegistro.Close;
    FDExisteRegistro.ParamByName('PCLAVE_USER').AsInteger := ClaveUser;
    FDExisteRegistro.ParamByName('PCLAVE_GROUP').AsInteger := ClaveGrupo;
    FDExisteRegistro.ParamByName('PUKEY').AsString := GetKeyTUserGroup(ClaveUser, ClaveGrupo);
    FDExisteRegistro.Open;
    if FDExisteRegistro.RecordCount = 0 then
    begin

      FDataset.Append;
      FDataset.FieldByName('CLAVE_USER').AsInteger := ClaveUser;
      FDataset.FieldByName('CLAVE_GROUP').AsInteger := ClaveGrupo;
      FDataset.FieldByName('UKEY').AsString := GetKeyTUserGroup(ClaveUser, ClaveGrupo);
      FDataset.Post;
    end;
  end;

begin
  FMXUcUserSelector := TFMXUcUserSelector.CreateEx(self, FDTMaster, FConnection, fFMXUserControl);
  try
    FMXUcUserSelector.Modo := Modo;
    FMXUcUserSelector.Empresa := Empresa;
    FMXUcUserSelector.Ambito := Ambito;
    FMXUcUserSelector.EsMaster := AMaster;
    if (FMXUcUserSelector.ShowModal = mrOk) then
    begin
      for i := 0 to FMXUcUserSelector.DbGridPerf.RowSelectionCount - 1 do
      begin
        FMXUcUserSelector.DbGridPerf.Cells[1, FMXUcUserSelector.DbGridPerf.SelectedRow[i]];

        // GotoBookmark(Pointer(FMXUcUserSelector.DbGridPerf.SelectedRows.Items[i]));
        // GetData;
      end;

      // else
      // GetData;
      FDataset.Refresh;
    end;
  finally
    FreeAndNil(FMXUcUserSelector);
  end;
end;

procedure TFMXUcUsuariosGrupos.Button2Click(Sender: TObject);
begin
  if FDataset.State in [dsEdit, dsInsert] then
    FDataset.Post;

  if FDTMaster.Active then
    FDTMaster.CommitRetaining;
end;

procedure TFMXUcUsuariosGrupos.Button3Click(Sender: TObject);
begin
  if FDTMaster.Active then
    FDTMaster.RollbackRetaining;
end;

procedure TFMXUcUsuariosGrupos.Button5Click(Sender: TObject);
begin
  if not Assigned(FSelectorColumas) then
    FSelectorColumas := TFSelectorColumas.CreateWithGrid(self, TMSFMXLiveGrid1);
  FSelectorColumas.Caption := 'Selector de columnas tabla: Pedidos Pendientes';
  FSelectorColumas.ShowModal;
end;

end.
