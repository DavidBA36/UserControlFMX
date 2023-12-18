unit FMX.pUCFrame_Ajustes;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.UcBase, FireDAC.Phys.IBWrapper,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, Data.Bind.Controls, FireDAC.Stan.Intf, FireDAC.Stan.Param, FireDAC.Phys.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.FMXUI.Wait, System.Rtti, System.Bindings.Outputs, FMX.Bind.Editors, Data.Bind.EngExt, FMX.Bind.DBEngExt, FMX.Menus, Data.Bind.Components,
  Data.Bind.DBScope, FMX.TMSMemo, FMX.TMSMemoStyles, FireDAC.Phys.IBBase, FMX.Edit, Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, FMX.Layouts, FMX.TMSBaseControl,
  FMX.TabControl, System.ImageList, FMX.ImgList, FMX.Objects, FMX.Bind.Navigator, FMX.Controls.Presentation, Data.Bind.ObjectScope, FMX.TMSTaskDialog;

type
  TFMXUcFrame_Ajustes = class(TFrame)
    StyleBook1: TStyleBook;
    Panel4: TPanel;
    BindNavigator1: TBindNavigator;
    ImageList1: TImageList;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    DBAdvMemo1: TTMSFMXMemo;
    GridPanelLayout1: TGridPanelLayout;
    GroupBox1: TGroupBox;
    PopupMenu2: TPopupMenu;
    FDUMaster: TFDUpdateSQL;
    FDMaster: TFDQuery;
    DSMaster: TDataSource;
    FDConnection1: TFDConnection;
    GroupBox2: TGroupBox;
    Edit1: TEdit;
    Label1: TLabel;
    GroupBox3: TGroupBox;
    rbCambiado: TRadioButton;
    rbNuevoUser: TRadioButton;
    rbModUser: TRadioButton;
    rbOlvidado: TRadioButton;
    rbForzado: TRadioButton;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    Label2: TLabel;
    Edit2: TEdit;
    GridPanelLayout2: TGridPanelLayout;
    Edit3: TEdit;
    Label3: TLabel;
    Edit4: TEdit;
    Label4: TLabel;
    Edit5: TEdit;
    Label5: TLabel;
    Edit6: TEdit;
    Label6: TLabel;
    cbtls: TCheckBox;
    cbActivo: TCheckBox;
    TMSFMXMemoHTMLStyler1: TTMSFMXMemoHTMLStyler;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkControlToField1: TLinkControlToField;
    LinkControlToField2: TLinkControlToField;
    LinkControlToField3: TLinkControlToField;
    LinkControlToField4: TLinkControlToField;
    LinkControlToField5: TLinkControlToField;
    LinkControlToField6: TLinkControlToField;
    LinkControlToField7: TLinkControlToField;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    LinkControlToField8: TLinkControlToField;
    LinkPropertyToField1: TLinkPropertyToField;
    AdapterBindSource1: TAdapterBindSource;
    DataGeneratorAdapter1: TDataGeneratorAdapter;
    TaskDialog: TTMSFMXTaskDialog;
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure FDMasterAfterPost(DataSet: TDataSet);
    procedure RadioButtonClick(Sender: TObject);
  private
    fFMXUserControl: TFMXUserControl;
    FConnection: TFDConnection;
    FDTMaster: TFDTransaction;
    LastChecked: TRadioButton;
  public
    destructor Destroy; override;
    constructor CreateEx(AOwner: TComponent; ATrans: TFDTransaction; AConn: TFDConnection; UC: TFMXUserControl);
  end;

implementation

{$R *.fmx}

uses FMX.pUcGeral, FMX.UserPermis_U, FMX.UcHelpers;

constructor TFMXUcFrame_Ajustes.CreateEx(AOwner: TComponent; ATrans: TFDTransaction; AConn: TFDConnection; UC: TFMXUserControl);
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
        TFDUpdateSQL(Components[i]).Connection := FConnection
      else if ((Components[i] Is TFDStoredProc)) then
      begin
        TFDStoredProc(Components[i]).Connection := FConnection;
        TFDStoredProc(Components[i]).Transaction := FDTMaster;
        TFDStoredProc(Components[i]).UpdateTransaction := FDTMaster;
      end;
    CheckPermisos(Self, FConnection, FDTMaster, fFMXUserControl);
    FDMaster.Open;
  except
    on E: Exception do
      raise Exception.Create('Error conectando a Firebird');
  end;
end;

destructor TFMXUcFrame_Ajustes.Destroy;
begin
  FDMaster.FieldByName(LinkControlToField8.FieldName).AsString := DBAdvMemo1.Lines.Text;
  if FDMaster.State in [dsEdit, dsInsert] then
    FDMaster.Post;
  if FDTMaster.Active then
    FDTMaster.CommitRetaining;
  inherited;
end;

procedure TFMXUcFrame_Ajustes.FDMasterAfterPost(DataSet: TDataSet);
begin
  TFMXFormUserPerf(Self.Owner).Modificado := True;
end;

procedure TFMXUcFrame_Ajustes.MenuItem1Click(Sender: TObject);
begin
  DBAdvMemo1.CutToClipBoard;
  DBAdvMemo1.DeleteSelection;
end;

procedure TFMXUcFrame_Ajustes.MenuItem2Click(Sender: TObject);
begin
  DBAdvMemo1.CopyToClipBoard;
end;

procedure TFMXUcFrame_Ajustes.MenuItem3Click(Sender: TObject);
begin
  DBAdvMemo1.PasteFromClipBoard;
end;

procedure TFMXUcFrame_Ajustes.MenuItem4Click(Sender: TObject);
begin
  DBAdvMemo1.DeleteSelection;
end;

procedure TFMXUcFrame_Ajustes.MenuItem5Click(Sender: TObject);
begin
  DBAdvMemo1.SelectAll;
end;

procedure TFMXUcFrame_Ajustes.RadioButtonClick(Sender: TObject);
begin
  if TRadioButton(Sender) <> LastChecked then
  begin
    FDMaster.FieldByName(LinkControlToField8.FieldName).AsString := DBAdvMemo1.Lines.Text;
    if FDMaster.State in [dsEdit, dsInsert] then
      FDMaster.Post;
    if rbOlvidado.isChecked then
    begin
      LinkPropertyToField1.FieldName := 'PASS_OLVIDADO_BODY';
      LinkControlToField8.FieldName := 'PASS_OLVIDADO_ASUNTO';
    end
    else if rbForzado.isChecked then
    begin
      LinkPropertyToField1.FieldName := 'PASS_FORZADO_BODY';
      LinkControlToField8.FieldName := 'PASS_FORZADO_ASUNTO';
    end
    else if rbCambiado.isChecked then
    begin
      LinkPropertyToField1.FieldName := 'PASS_CAMBIADO_BODY';
      LinkControlToField8.FieldName := 'PASS_CAMBIADO_ASUNTO';
    end
    else if rbModUser.isChecked then
    begin
      LinkPropertyToField1.FieldName := 'USER_CAMBIADO_BODY';
      LinkControlToField8.FieldName := 'USER_CAMBIADO_ASUNTO';
    end
    else if rbNuevoUser.isChecked then
    begin
      LinkPropertyToField1.FieldName := 'USER_AGREGADO_BODY';
      LinkControlToField8.FieldName := 'USER_AGREGADO_ASUNTO';
    end;
    LastChecked := TRadioButton(Sender);
  end;
end;

end.
