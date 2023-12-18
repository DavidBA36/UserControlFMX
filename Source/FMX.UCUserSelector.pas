unit FMX.UCUserSelector;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.UcBase, System.JSON,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, Data.Bind.Controls, FMX.StdCtrls, FMX.TMSBaseControl, FMX.TMSGridCell, FMX.TMSGridOptions, FMX.TMSGridData,
  FMX.TMSCustomGrid, FMX.TMSLiveGrid, FMX.Menus, FMX.Layouts, FMX.Bind.Navigator, FMX.Objects, FMX.Controls.Presentation, System.ImageList, FMX.ImgList,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  FMX.TMSGrid, Data.Bind.EngExt, FMX.Bind.DBEngExt, FMX.TMSLiveGridDataBinding, System.Rtti, System.Bindings.Outputs, FMX.Bind.Editors, Data.Bind.Components, Data.Bind.Grid,
  FireDAC.Phys.IBBase, Data.Bind.DBScope, FMX.TMSTaskDialog;

type
  TFMXUcUserSelector = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    LbDescricao: TLabel;
    Panel4: TPanel;
    Button2: TButton;
    Button3: TButton;
    PopupMenu1: TPopupMenu;
    DbGridPerf: TTMSFMXLiveGrid;
    FDMaster: TFDQuery;
    GridUsuarios: TTMSFMXGrid;
    MenuItem1: TMenuItem;
    AniIndicator1: TAniIndicator;
    ImageList1: TImageList;
    StyleBook1: TStyleBook;
    BindSourceDB1: TBindSourceDB;
    FDConnection1: TFDConnection;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    TaskDialog: TTMSFMXTaskDialog;
    procedure FormShow(Sender: TObject);
    procedure GridUsuariosDblClick(Sender: TObject);
    procedure DbGridPerfDblClick(Sender: TObject);
    procedure GridUsuariosColumnSorted(Sender: TObject; ACol: Integer; Direction: TSortDirection);
    procedure GridUsuariosColumnSized(Sender: TObject; ACol: Integer; NewWidth: Single);
    procedure DbGridPerfColumnSized(Sender: TObject; ACol: Integer; NewWidth: Single);
    procedure DbGridPerfColumnSorted(Sender: TObject; ACol: Integer; Direction: TSortDirection);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    fFMXUserControl: TFMXUserControl;
    Grid1ColumnsWidth: array of Single;
    Grid2ColumnsWidth: array of Single;
    FConnection: TFDConnection;
    FDTMaster: TFDTransaction;
    procedure ShowDataOnGrid(JsonString: string);
  public
    Modo: Integer;
    Empresa: Integer;
    Ambito: String;
    EsMaster: boolean;
    constructor CreateEx(AOwner: TComponent; ATrans: TFDTransaction; AConn: TFDConnection; UC: TFMXUserControl);
  end;

var
  FMXUcUserSelector: TFMXUcUserSelector;

implementation

{$R *.fmx}

uses FMX.UCHelpers, FMX.UserPermis_U;

constructor TFMXUcUserSelector.CreateEx(AOwner: TComponent; ATrans: TFDTransaction; AConn: TFDConnection; UC: TFMXUserControl);
var
  i: Integer;
begin
  inherited Create(AOwner);
  fFMXUserControl := UC;
  FConnection := AConn;
  FDTMaster := ATrans;
  GridUsuarios.ColumnCount := 0;
  GridUsuarios.RowCount := 0;
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
  except
    on E: Exception do
      raise Exception.Create('Error conectando a Firebird');
  end;
  SetLength(Grid1ColumnsWidth, GridUsuarios.Columns.Count);
  SetArray(Grid1ColumnsWidth, 68);
  LoadGridPreferences(Grid1ColumnsWidth, GridUsuarios, fFMXUserControl.FormStorageRegRoot + '\UserControl', self.Name);
  SetLength(Grid2ColumnsWidth, DbGridPerf.Columns.Count);
  SetArray(Grid2ColumnsWidth, 68);
  LoadGridPreferences(Grid2ColumnsWidth, DbGridPerf, fFMXUserControl.FormStorageRegRoot + '\UserControl', self.Name);
  GridUsuarios.Align := TAlignLayout.Client;
  DbGridPerf.Align := TAlignLayout.Client;
end;

procedure TFMXUcUserSelector.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveGridPreferences(fFMXUserControl.FormStorageRegRoot + '\UserControl', self.Name, GridUsuarios);
  SaveGridPreferences(fFMXUserControl.FormStorageRegRoot + '\UserControl', self.Name, DbGridPerf);
  Action := TCloseAction.caFree;
end;

procedure TFMXUcUserSelector.FormDestroy(Sender: TObject);
begin
  FMXUcUserSelector := nil;
end;

procedure TFMXUcUserSelector.FormShow(Sender: TObject);
begin
  GridUsuarios.Visible := (Modo = 3);
  DbGridPerf.Visible := (Modo <> 3);
  AniIndicator1.Visible := (Modo = 3);
  case Modo of
    1:
      begin
        Caption := 'Selector de usuarios';
        LbDescricao.Text := 'Selecciona uno o varios usuarios para agregar';
        FDMaster.Close;
        FDMaster.SQL.Clear;
        FDMaster.SQL.Add('SELECT A.CLAVE,A.UCLOGIN AS NOMBRE, A.UCDESCRIPCION AS DESCRIPCION,IIF(A.UCAMBITO=''Local'',I.NOMBRE,NULL) AS EMPRESA,A.UCAMBITO');
        FDMaster.SQL.Add('FROM INT$UC_USERS A ');
        FDMaster.SQL.Add('LEFT OUTER JOIN INT$ENTIDAD I ON I.CLAVE=A.CLAVE_EMPRESA ');
        if EsMaster then
          FDMaster.SQL.Add('WHERE A.UCMASTER=''TRUE''')
        else
        begin
          FDMaster.SQL.Add('WHERE A.UCMASTER=''FALSE'' AND A.UCAMBITO=' + QuotedStr(Ambito));
          if Ambito = 'Local' then
          begin
            FDMaster.SQL.Add('AND A.CLAVE_EMPRESA=:PCLAVE_EMPRESA');
            FDMaster.ParamByName('PCLAVE_EMPRESA').AsInteger := Empresa;
          end;
        end;
        FDMaster.Open;
      end;
    2:
      begin
        Caption := 'Selector de Grupos';
        LbDescricao.Text := 'Selecciona uno o varios grupos para agregar';
        FDMaster.Close;
        FDMaster.SQL.Clear;
        FDMaster.SQL.Add('SELECT A.CLAVE,A.UC_NOMBRE AS NOMBRE, A.UC_DESCRIPCION AS DESCRIPCION,IIF(A.UCAMBITO=''Local'',I.NOMBRE,NULL) AS EMPRESA,A.UCAMBITO');
        FDMaster.SQL.Add('FROM INT$UC_GROUPS A ');
        FDMaster.SQL.Add('LEFT OUTER JOIN INT$ENTIDAD I ON I.CLAVE=A.CLAVE_EMPRESA ');
        if EsMaster then
          FDMaster.SQL.Add('WHERE A.UCMASTER=''TRUE''')
        else
        begin
          FDMaster.SQL.Add('WHERE A.UCMASTER=''FALSE'' AND A.UCAMBITO=' + QuotedStr(Ambito));
          if Ambito = 'Local' then
          begin
            FDMaster.SQL.Add('AND A.CLAVE_EMPRESA=:PCLAVE_EMPRESA');
            FDMaster.ParamByName('PCLAVE_EMPRESA').AsInteger := Empresa;
          end;
        end;
        FDMaster.Open;
      end;
    3:
      begin
        Caption := 'Selector de usuarios de Windows';
        LbDescricao.Text := 'Selecciona uno o varios usuarios para agregar';
        AniIndicator1.Enabled := TRue;
        GridUsuarios.RowCount := 2;
        // OpenQuery('select * from Win32_UserAccount', 'Win32_UserAccount', WMIQueryError, ShowDataOnGrid);
        ShowDataOnGrid('');
      end;
  end;
end;

procedure TFMXUcUserSelector.GridUsuariosColumnSized(Sender: TObject; ACol: Integer; NewWidth: Single);
begin
  Grid1ColumnsWidth[ACol] := NewWidth;
end;

procedure TFMXUcUserSelector.GridUsuariosColumnSorted(Sender: TObject; ACol: Integer; Direction: TSortDirection);
var
  Direccion: String;
  i: Integer;
begin
  if Direction = TSortDirection.sdAscending then
    Direccion := ' ASC'
  else
    Direccion := ' DESC';
  // Field := LinkGridToDataSourceBindSourceDB3.Columns.Items[ACol].MemberName;
  // FDataset.MacroByName('orden').AsRaw := 'ORDER BY ' + Field + Direccion;
  // FDataset.Open;
  for i := 0 to TTMSFMXLiveGrid(Sender).Columns.Count - 1 do
  begin
    TTMSFMXLiveGrid(Sender).Columns.Items[i].Width := Grid1ColumnsWidth[i];
  end;

end;

procedure TFMXUcUserSelector.GridUsuariosDblClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TFMXUcUserSelector.ShowDataOnGrid(JsonString: string);
var
  Datos: TJSONArray;
  Val: TJSONValue;
  ValObject: TJSONObject;
  i, r: Integer;
begin
  Datos := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(JsonString), 0) as TJSONArray;
  if Datos = nil then
    exit;
  try
    r := 1;
    with GridUsuarios do
    begin
      ColumnCount := 11;
      RowCount := Datos.Count + 1;
      HideColumn(0);
      for i := 1 to GridUsuarios.ColumnCount - 1 do
        GridUsuarios.ColumnWidths[i] := Integer(ReadPropertyFromReg(fFMXUserControl.FormStorageRegRoot + '\UserControl\FSelector\GridUsuarios\', 'Item' + IntToStr(i)));

      Cells[0, 0] := 'SID';
      Cells[1, 0] := 'Nombre';
      Cells[2, 0] := 'Dominio';
      Cells[3, 0] := 'Cuenta Local';
      Cells[4, 0] := 'Cuenta Bloqueada';
      Cells[5, 0] := 'Habilitada';
      Cells[6, 0] := 'Tiene Contraseña';
      Cells[7, 0] := 'Contraseña Cambiable';
      Cells[8, 0] := 'Contraseña Expirable';
      Cells[9, 0] := 'Estado';
      Cells[10, 0] := 'Descripción';

      for Val in Datos do
      begin
        ValObject := Val as TJSONObject;
        Cells[0, r] := ValObject.GetValue('SID').Value;
        Cells[1, r] := ValObject.GetValue('Name').Value;
        Cells[2, r] := ValObject.GetValue('Domain').Value;
        Cells[3, r] := ValObject.GetValue('LocalAccount').Value;
        Cells[4, r] := ValObject.GetValue('Lockout').Value;
        Cells[5, r] := ValObject.GetValue('Disabled').Value;
        Cells[6, r] := ValObject.GetValue('PasswordRequired').Value;
        Cells[7, r] := ValObject.GetValue('PasswordChangeable').Value;
        Cells[8, r] := ValObject.GetValue('PasswordExpires').Value;
        Cells[9, r] := ValObject.GetValue('Status').Value;
        if ValObject.GetValue('Description') <> nil then
          Cells[10, r] := ValObject.GetValue('Description').Value;
        inc(r);
      end;
      FixedRows := 1;
    end;
  finally
    if Datos <> nil then
      Datos.Free;
    AniIndicator1.Enabled := False;
  end;
end;

procedure TFMXUcUserSelector.DbGridPerfColumnSized(Sender: TObject; ACol: Integer; NewWidth: Single);
begin
  Grid2ColumnsWidth[ACol] := NewWidth;
end;

procedure TFMXUcUserSelector.DbGridPerfColumnSorted(Sender: TObject; ACol: Integer; Direction: TSortDirection);
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
    TTMSFMXLiveGrid(Sender).Columns.Items[i].Width := Grid1ColumnsWidth[i];
  end;
end;

procedure TFMXUcUserSelector.DbGridPerfDblClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

end.
