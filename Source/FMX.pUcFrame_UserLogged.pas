unit FMX.pUcFrame_UserLogged;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.UCBase,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, Data.Bind.Controls, FMX.TMSBaseControl, FMX.TMSGridCell,
  FMX.TMSGridOptions, FMX.TMSGridData,
  FMX.TMSCustomGrid, FMX.TMSLiveGrid, FMX.Menus, FMX.Layouts, FMX.Bind.Navigator, FMX.Objects, FMX.Controls.Presentation, System.ImageList,
  FMX.ImgList,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.FMXUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Data.Bind.EngExt, FMX.Bind.DBEngExt, FMX.TMSLiveGridDataBinding, System.Rtti, System.Bindings.Outputs, FMX.Bind.Editors, Data.Bind.Components,
  Data.Bind.Grid, Data.Bind.DBScope,
  FMX.TMSTaskDialog;

type
  TFMXUCFrame_UsersLogged = class(TFrame)
    ImageList1: TImageList;
    Panel2: TPanel;
    btnMensage: TButton;
    btnBorrar: TButton;
    SpeedButton1: TSpeedButton;
    Panel4: TPanel;
    BindNavigator1: TBindNavigator;
    PopupMenu1: TPopupMenu;
    StyleBook1: TStyleBook;
    TMSFMXLiveGrid1: TTMSFMXLiveGrid;
    FDMaster: TFDQuery;
    Button1: TButton;
    Button2: TButton;
    FDConnection1: TFDConnection;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    TaskDialog: TTMSFMXTaskDialog;
    procedure TMSFMXLiveGrid1ColumnSized(Sender: TObject; ACol: Integer; NewWidth: Single);
    procedure TMSFMXLiveGrid1ColumnSorted(Sender: TObject; ACol: Integer; Direction: TSortDirection);
    procedure btnMensageClick(Sender: TObject);
  private
    fUserControl: TFMXUserControl;
    GridColumnsWidth: array of Single;
    FConnection: TFDConnection;
    FDTMaster: TFDTransaction;
    UCMes: TFMXUCApplicationMessage;
  public
    destructor Destroy; override;
    constructor CreateEx(AOwner: TComponent; ATrans: TFDTransaction; AConn: TFDConnection; UC: TFMXUserControl);
  end;

implementation

{$R *.fmx}

uses FMX.UCHelpers;

procedure TFMXUCFrame_UsersLogged.btnMensageClick(Sender: TObject);
begin
  if Assigned(UCMes) then
  begin
    TaskDialog.Title := 'Enviar mensaje';
    TaskDialog.InstructionText := fUserControl.UserSettings.UsersLogged.InputCaption;
    TaskDialog.InputSettings.InputType := TFMXInputType.Edit;
    TaskDialog.commonButtons := [TFMXCommonButton.OK];
    TaskDialog.Show(
      procedure(ButtonID: Integer)
      begin
        case ButtonID of
          mrOK:
            UCMes.SendAppMessage(FDMaster.FieldByName('CLAVE').AsInteger, fUserControl.UserSettings.UsersLogged.MsgSystem,
              TaskDialog.InputSettings.Text);
        end;
      end);
  end;
end;

constructor TFMXUCFrame_UsersLogged.CreateEx(AOwner: TComponent; ATrans: TFDTransaction; AConn: TFDConnection; UC: TFMXUserControl);
var
  i: Integer;
  Form: TForm;
begin
  inherited Create(AOwner);
  try
    UCMes := nil;
    Form := TForm(Application.MainForm);
    for i := 0 to Form.ComponentCount - 1 do
      if (Form.Components[i] is TFMXUCApplicationMessage) then
        UCMes := TFMXUCApplicationMessage(Form.Components[i]);
    btnMensage.Enabled := UCMes <> nil;

    fUserControl := UC;
    FConnection := AConn;
    FDTMaster := ATrans;
    with fUserControl.UserSettings.UsersLogged do
    begin
      // Text := LabelCaption;
      // DbGrid.Columns[0].Title.Caption := ColName;
      // DbGrid.Columns[1].Title.Caption := ColLogin;
      // DbGrid.Columns[2].Title.Caption := ColComputer;
      // DbGrid.Columns[3].Title.Caption := ColData;
    end;

    // Label1.Caption := 'Current user ID:' + fUserControl.CurrentUser.IdLogon;

    for i := 0 to (ComponentCount - 1) do
      If ((Components[i] Is TFDQuery)) Then
      begin
        TFDQuery(Components[i]).Transaction := FDTMaster;
        TFDQuery(Components[i]).UpdateTransaction := FDTMaster;
        TFDQuery(Components[i]).Connection := FConnection;
      end
      else if ((Components[i] Is TFDUpdateSQL)) then
        TFDUpdateSQL(Components[i]).Connection := FConnection;

    CheckPermisos(Self, FConnection, FDTMaster, fUserControl);

    with FDMaster do
    begin
      SQL.Clear;
      SQL.Add('SELECT A.*,B.UCUSERNAME AS ALIAS,B.UCLOGIN AS USUARIO,B.UCAMBITO AS AMBITO,B.UCMASTER AS MASTER,I.NOMBRE AS EMPRESA ');
      SQL.Add('FROM INT$UC_USERSLOGGED A ');
      SQL.Add('LEFT OUTER JOIN INT$UC_USERS B ON A.CLAVE_USER=B.CLAVE ');
      SQL.Add('LEFT JOIN INT$ENTIDAD I ON I.CLAVE=B.CLAVE_EMPRESA ');
      SQL.Add('WHERE A.APPLICATIONID=:PAPPLICATIONID ');
      if not(fUserControl.CurrentUser.EsMaster) or (fUserControl.CurrentUser.Ambito = 'Local') then
        SQL.Add('AND B.CLAVE_EMPRESA=:PCLAVE_EMPRESA ');
      SQL.Add('!filtro');
      SQL.Add('!orden');
    end;
    if not(fUserControl.CurrentUser.EsMaster) or (fUserControl.CurrentUser.Ambito = 'Local') then
      FDMaster.ParamByName('PCLAVE_EMPRESA').AsInteger := fUserControl.CurrentUser.Empresa;

    FDMaster.ParamByName('PAPPLICATIONID').AsString := fUserControl.ApplicationID;
    FDMaster.Open;
    SetLength(GridColumnsWidth, TMSFMXLiveGrid1.Columns.Count);
    SetArray(GridColumnsWidth, 68);
    LoadGridPreferences(GridColumnsWidth, TMSFMXLiveGrid1, fUserControl.FormStorageRegRoot + '\UserControl', Self.Name);
  except
    on E: Exception do
      raise Exception.Create('Error conectando a Firebird');
  end;
end;

destructor TFMXUCFrame_UsersLogged.Destroy;
begin
  FreeAndNil(UCMes);
  SaveGridPreferences(fUserControl.FormStorageRegRoot + '\UserControl', Self.Name, TMSFMXLiveGrid1);
  inherited;
end;

procedure TFMXUCFrame_UsersLogged.TMSFMXLiveGrid1ColumnSized(Sender: TObject; ACol: Integer; NewWidth: Single);
begin
  GridColumnsWidth[ACol] := NewWidth;
end;

procedure TFMXUCFrame_UsersLogged.TMSFMXLiveGrid1ColumnSorted(Sender: TObject; ACol: Integer; Direction: TSortDirection);
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
