unit FMX.pUcFrame_Accesos;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.UCBase,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, Data.Bind.Controls, FMX.TMSBaseControl, FMX.TMSGridCell, FMX.TMSGridOptions, FMX.TMSGridData,
  FMX.TMSCustomGrid, FMX.TMSLiveGrid, FMX.Menus, FMX.Layouts, FMX.Bind.Navigator, FMX.Objects, FMX.Controls.Presentation, System.ImageList, FMX.ImgList, FireDAC.Stan.Intf,
  FireDAC.Stan.Param, FireDAC.Phys.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.FMXUI.Wait, Data.Bind.EngExt,
  FMX.Bind.DBEngExt, FMX.TMSLiveGridDataBinding, System.Rtti, System.Bindings.Outputs, FMX.Bind.Editors, Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope,
  FMX.TMSTaskDialog;

type
  TFMXUcFrame_Accesos = class(TFrame)
    ImageList1: TImageList;
    Panel2: TPanel;
    btnNuevo: TButton;
    btnBorrar: TButton;
    SpeedButton1: TSpeedButton;
    Panel4: TPanel;
    BindNavigator1: TBindNavigator;
    PopupMenu1: TPopupMenu;
    StyleBook1: TStyleBook;
    TMSFMXLiveGrid1: TTMSFMXLiveGrid;
    FDUMaster: TFDUpdateSQL;
    FDMaster: TFDQuery;
    MenuItem1: TMenuItem;
    FDBorraTodo: TFDQuery;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    FDConnection1: TFDConnection;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    TaskDialog: TTMSFMXTaskDialog;
    procedure TMSFMXLiveGrid1ColumnSized(Sender: TObject; ACol: Integer; NewWidth: Single);
    procedure TMSFMXLiveGrid1ColumnSorted(Sender: TObject; ACol: Integer; Direction: TSortDirection);
  private
    fFMXUserControl: TFMXUserControl;
    GridColumnsWidth: array of Single;
    FConnection: TFDConnection;
    FDTMaster: TFDTransaction;
  public
    destructor Destroy; override;
    constructor CreateEx(AOwner: TComponent; ATrans: TFDTransaction; AConn: TFDConnection; UC: TFMXUserControl);
  end;

implementation

{$R *.fmx}

uses FMX.UcHelpers;

constructor TFMXUcFrame_Accesos.CreateEx(AOwner: TComponent; ATrans: TFDTransaction; AConn: TFDConnection; UC: TFMXUserControl);
var
  i: Integer;
begin
  inherited Create(AOwner);
  try
    fFMXUserControl := UC;
    FConnection := AConn;
    FDTMaster := ATrans;
    for i := 0 to (ComponentCount - 1) do
      If ((Components[i] Is TFDQuery)) Then
      begin
        TFDQuery(Components[i]).Transaction := FDTMaster;
        TFDQuery(Components[i]).UpdateTransaction := FDTMaster;
        TFDQuery(Components[i]).Connection := FConnection;
      end
      else if ((Components[i] Is TFDUpdateSQL)) then
        TFDUpdateSQL(Components[i]).Connection := FConnection;

    CheckPermisos(Self, FConnection, FDTMaster, fFMXUserControl);

    with FDMaster do
    begin
      SQL.Clear;
      SQL.Add('SELECT A.*,B.UCUSERNAME AS ALIAS,B.UCLOGIN AS USUARIO,B.UCAMBITO AS AMBITO,B.UCMASTER AS MASTER,I.NOMBRE AS EMPRESA ');
      SQL.Add('FROM INT$UC_ACCESOS A ');
      SQL.Add('LEFT OUTER JOIN INT$UC_USERS B ON A.CLAVE_USER=B.CLAVE ');
      SQL.Add('LEFT JOIN INT$ENTIDAD I ON I.CLAVE=B.CLAVE_EMPRESA ');
      SQL.Add('WHERE A.APPLICATIONID=:PAPPLICATIONID ');
      if not(fFMXUserControl.CurrentUser.EsMaster) or (fFMXUserControl.CurrentUser.Ambito = 'Local') then
        SQL.Add('AND B.CLAVE_EMPRESA=:PCLAVE_EMPRESA ');
      SQL.Add('!filtro');
      SQL.Add('!orden');
    end;
    if not(fFMXUserControl.CurrentUser.EsMaster) or (fFMXUserControl.CurrentUser.Ambito = 'Local') then
      FDMaster.ParamByName('PCLAVE_EMPRESA').AsInteger := fFMXUserControl.CurrentUser.Empresa;
    FDMaster.ParamByName('PAPPLICATIONID').AsString := fFMXUserControl.ApplicationID;
    FDMaster.Open;
    SetLength(GridColumnsWidth, TMSFMXLiveGrid1.Columns.Count);
    SetArray(GridColumnsWidth, 68);
    LoadGridPreferences(GridColumnsWidth, TMSFMXLiveGrid1, fFMXUserControl.FormStorageRegRoot + '\UserControl', Self.Name);
  except
    on E: Exception do
      raise Exception.Create('Error conectando a Firebird');
  end;
end;

destructor TFMXUcFrame_Accesos.Destroy;
begin
  SaveGridPreferences(fFMXUserControl.FormStorageRegRoot + '\UserControl', Self.Name, TMSFMXLiveGrid1);
  if FDMaster.State in [dsEdit, dsInsert] then
    FDMaster.Post;
  if FDTMaster.Active then
    FDTMaster.CommitRetaining;
  inherited;
end;

procedure TFMXUcFrame_Accesos.TMSFMXLiveGrid1ColumnSized(Sender: TObject; ACol: Integer; NewWidth: Single);
begin
  GridColumnsWidth[ACol] := NewWidth;
end;

procedure TFMXUcFrame_Accesos.TMSFMXLiveGrid1ColumnSorted(Sender: TObject; ACol: Integer; Direction: TSortDirection);
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
