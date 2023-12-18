unit FMX.UcWindowsGroupUser;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.UcBase, FireDAC.Phys.IBWrapper,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.FMXUI.Wait,
  FireDAC.Comp.Client, Data.DB, FireDAC.Comp.DataSet, FMX.Layouts, FMX.TreeView, Data.Bind.Controls, FMX.Bind.Navigator, FMX.Objects, FMX.StdCtrls, System.ImageList, FMX.ImgList,
  FMX.TMSBaseControl, FMX.TMSGridCell, FMX.TMSGridOptions, FMX.TMSGridData, FMX.TMSCustomGrid, FMX.TMSLiveGrid, FMX.Controls.Presentation,
  FMX.TMSTaskDialog;

type
  TFMXUcWindowsGroupUser = class(TForm)
    FDExisteRegistro: TFDQuery;
    FDWinUsers: TFDQuery;
    FDConnection1: TFDConnection;
    FDUMaster: TFDUpdateSQL;
    FDMaster: TFDQuery;
    Panel1: TPanel;
    TMSFMXLiveGrid1: TTMSFMXLiveGrid;
    Panel3: TPanel;
    TreeTodo: TTreeView;
    Panel2: TPanel;
    Button1: TButton;
    Button5: TButton;
    Button10: TButton;
    ImageList1: TImageList;
    StyleBook1: TStyleBook;
    Label1: TLabel;
    Rectangle1: TRectangle;
    Splitter1: TSplitter;
    PArbol: TLayout;
    Image1: TImage;
    LbDescricao: TLabel;
    lbUser: TLabel;
    Panel4: TPanel;
    Button2: TButton;
    Button3: TButton;
    BindNavigator1: TBindNavigator;
    TaskDialog: TTMSFMXTaskDialog;
    procedure FDMasterPostError(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
    procedure FDMasterAfterPost(DataSet: TDataSet);
    procedure FDMasterAfterOpen(DataSet: TDataSet);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    fUserControl: TFMXUserControl;
    FConnection: TFDConnection;
    FDTMaster: TFDTransaction;
    procedure ConstruyeArbol;
  public
    Clave: Integer;
    constructor CreateEx(AOwner: TComponent; Server: string; ATrans: TFDTransaction; AConn: TFDConnection; UC: TFMXUserControl);
  end;

var
  FMXUcWindowsGroupUser: TFMXUcWindowsGroupUser;

implementation

{$R *.fmx}

uses FMX.pUCGeral;

constructor TFMXUcWindowsGroupUser.CreateEx(AOwner: TComponent; Server: string; ATrans: TFDTransaction; AConn: TFDConnection; UC: TFMXUserControl);
var
  i: Integer;
begin
  inherited Create(AOwner);
  fUserControl := UC;
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
  except
    on E: Exception do
      raise Exception.Create('Error conectando a Firebird');
  end;
end;

procedure TFMXUcWindowsGroupUser.FDMasterAfterOpen(DataSet: TDataSet);
begin
  FDMaster.UpdateOptions.ReadOnly := FDMaster.RecordCount = 0;
end;

procedure TFMXUcWindowsGroupUser.FDMasterAfterPost(DataSet: TDataSet);
begin
  TFMXFormUserPerf(Self.Owner).Modificado := True;
end;

procedure TFMXUcWindowsGroupUser.FDMasterPostError(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
var
  oExc: EFDDBEngineException;
begin
  if E is EIBNativeException then
  begin
    oExc := EFDDBEngineException(E);
    if oExc.Kind = ekUKViolated then
    begin
      // MessageDlg('El Usuario: ' + DataSet.FieldByName('NOMBRE').AsString + ' con SID: ' + DataSet.FieldByName('SID').AsString + ' ya esta asignado', mtError, [TMsgDlgBtn.mbOK], 0);
      Action := daAbort;
      FDMaster.Cancel;
    end;
  end;
end;

procedure TFMXUcWindowsGroupUser.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TFMXUcWindowsGroupUser.FormDestroy(Sender: TObject);
begin
  FMXUcWindowsGroupUser := nil;
end;

procedure TFMXUcWindowsGroupUser.FormShow(Sender: TObject);
begin
  FDMaster.Close;
  FDMaster.ParamByName('PCLAVE_USER').AsInteger := Clave;
  FDMaster.Open;
  ConstruyeArbol;
end;

procedure TFMXUcWindowsGroupUser.ConstruyeArbol;
var
  WinUser: string;
  ClaveUser, ClaveEmpresa: Integer;
  PadreWinUser, Item, PadreUser: TTreeViewItem;
begin
  PadreWinUser := nil;
  PadreUser := nil;
  FDWinUsers.Close;
  FDWinUsers.Open;
  TreeTodo.Clear;
  ClaveUser := 0;
  ClaveEmpresa := 0;
  while not FDWinUsers.Eof do
  begin
    if FDWinUsers.FieldByName('CLAVE_EMPRESA').IsNull then
    begin
      PadreUser := TTreeViewItem.Create(TreeTodo);
      PadreUser.Text := 'Usuarios Maestros';
      PadreUser.Parent := TreeTodo;
    end
    else if ClaveEmpresa <> FDWinUsers.FieldByName('CLAVE_EMPRESA').AsInteger then
    begin
      PadreUser := TTreeViewItem.Create(TreeTodo);
      PadreUser.Text := FDWinUsers.FieldByName('EMPRESA').AsString;
      PadreUser.Parent := TreeTodo;
      ClaveEmpresa := FDWinUsers.FieldByName('CLAVE_EMPRESA').AsInteger;
    end;
    if ClaveUser <> FDWinUsers.FieldByName('CLAVE').AsInteger then
    begin
      PadreWinUser := TTreeViewItem.Create(TreeTodo);
      PadreWinUser.Text := FDWinUsers.FieldByName('UCLOGIN').AsString;
      PadreWinUser.Parent := PadreUser;
      ClaveUser := FDWinUsers.FieldByName('CLAVE').AsInteger
    end;
    if FDWinUsers.FieldByName('SID').AsString <> '' then
    begin
      WinUser := FDWinUsers.FieldByName('DOMINIO').AsString + '\' + FDWinUsers.FieldByName('NOMBRE').AsString + ' - [' + FDWinUsers.FieldByName('SID').AsString + ']';
      Item := TTreeViewItem.Create(TreeTodo);
      Item.Text := WinUser;
      Item.Parent := PadreWinUser;
    end;
    FDWinUsers.Next;
  end;
end;

end.
