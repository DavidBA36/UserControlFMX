unit FMX.pUCFrame_Log;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.UCBase,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, Data.Bind.Controls, FMX.TMSBaseControl, FMX.TMSGridCell, FMX.TMSGridOptions, FMX.TMSGridData,
  FMX.TMSCustomGrid, FMX.TMSLiveGrid, FMX.Menus, FMX.Layouts, FMX.Bind.Navigator, FMX.Objects, FMX.Controls.Presentation, System.ImageList, FMX.ImgList, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.FMXUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, Data.Bind.EngExt,
  FMX.Bind.DBEngExt, FMX.TMSLiveGridDataBinding, System.Rtti, System.Bindings.Outputs, FMX.Bind.Editors, Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope,
  FMX.TMSTaskDialog;

type
  TFMXUcFrame_Log = class(TFrame)
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
    FDMaster: TFDQuery;
    FDUMaster: TFDUpdateSQL;
    FDConnection1: TFDConnection;
    FDBorraTodo: TFDQuery;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
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
    procedure SetWindow;
    constructor CreateEx(AOwner: TComponent; ATrans: TFDTransaction; AConn: TFDConnection; UC: TFMXUserControl);
    destructor Destroy; override;
  end;

implementation

{$R *.fmx}

uses
  FMX.UcHelpers, FMX.pUcGeral;

constructor TFMXUcFrame_Log.CreateEx(AOwner: TComponent; ATrans: TFDTransaction; AConn: TFDConnection; UC: TFMXUserControl);
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

    CheckPermisos(Self, FConnection, FDTMaster, fFMXUserControl);
    FDMaster.Open;
  except
    on E: Exception do
      raise Exception.Create('Error conectando a Firebird');
  end;
  SetLength(GridColumnsWidth, TMSFMXLiveGrid1.Columns.Count);
  SetArray(GridColumnsWidth, 68);
  LoadGridPreferences(GridColumnsWidth, TMSFMXLiveGrid1, fFMXUserControl.FormStorageRegRoot + '\UserControl', Self.Name);
end;

destructor TFMXUcFrame_Log.Destroy;
begin
  SaveGridPreferences(fFMXUserControl.FormStorageRegRoot + '\UserControl', Self.Name, TMSFMXLiveGrid1);
  inherited;
end;

procedure TFMXUcFrame_Log.SetWindow;
begin
  //
end;

procedure TFMXUcFrame_Log.TMSFMXLiveGrid1ColumnSized(Sender: TObject; ACol: Integer; NewWidth: Single);
begin
  GridColumnsWidth[ACol] := NewWidth;
end;

procedure TFMXUcFrame_Log.TMSFMXLiveGrid1ColumnSorted(Sender: TObject; ACol: Integer; Direction: TSortDirection);
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
