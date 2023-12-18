unit FMX.UserPermis_U;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.UcBase, FireDAC.Comp.Client, FMX.ActnList,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, Data.Bind.Controls, FMX.TMSBaseControl, FMX.TMSTreeViewBase, FMX.TMSTreeViewData,
  FMX.TMSCustomTreeView,
  FMX.TMSTreeView, FMX.TMSCheckedTreeView, FMX.TabControl, System.ImageList, FMX.ImgList, FMX.StdCtrls, FMX.Objects, FMX.Layouts, FMX.Bind.Navigator,
  FMX.Controls.Presentation,
  FMX.Menus, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Stan.StorageBin, FireDAC.Stan.StorageJSON, Data.DB, FireDAC.Comp.DataSet, FMX.ScrollBox, FMX.Memo,
  FMX.Memo.Types, FMX.TMSTaskDialog;

type
  TFMXUserPermis = class(TForm)
    StyleBook1: TStyleBook;
    PopupMenu1: TPopupMenu;
    Panel4: TPanel;
    btnAceptar: TButton;
    Button2: TButton;
    BindNavigator1: TBindNavigator;
    Panel2: TPanel;
    btnNuevo: TButton;
    btnBorrar: TButton;
    Panel1: TPanel;
    Image1: TImage;
    LbDescricao: TLabel;
    lbUser: TLabel;
    ImageList1: TImageList;
    PC: TTabControl;
    PageMenu: TTabItem;
    PageAction: TTabItem;
    PageControls: TTabItem;
    PageAplicacion: TTabItem;
    TreeInterno: TTMSFMXCheckedTreeView;
    TreeControls: TTMSFMXCheckedTreeView;
    TreeAction: TTMSFMXCheckedTreeView;
    TreeMenu: TTMSFMXCheckedTreeView;
    FDPermisos: TFDQuery;
    FDBuscaGruposComp: TFDQuery;
    FDBuscaGruposCompEx: TFDQuery;
    FDMemTable1: TFDMemTable;
    FDStanStorageJSONLink1: TFDStanStorageJSONLink;
    btnHerencia: TSpeedButton;
    TabItem1: TTabItem;
    Memo1: TMemo;
    TaskDialog: TTMSFMXTaskDialog;
    procedure BtCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnBloquearAllClick(Sender: TObject);
    procedure btnReleaseAllClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure PCChange(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure TreeInternoAfterCheckNode(Sender: TObject; ANode: TTMSFMXTreeViewVirtualNode; AColumn: Integer);
    procedure TreeInternoAfterUnCheckNode(Sender: TObject; ANode: TTMSFMXTreeViewVirtualNode; AColumn: Integer);
    procedure TreeMenuAfterCheckNode(Sender: TObject; ANode: TTMSFMXTreeViewVirtualNode; AColumn: Integer);
    procedure TreeMenuAfterUnCheckNode(Sender: TObject; ANode: TTMSFMXTreeViewVirtualNode; AColumn: Integer);
    procedure TreeControlsBeforeDrawNodeText(Sender: TObject; ACanvas: TCanvas; ARect: TRectF; AColumn: Integer; ANode: TTMSFMXTreeViewVirtualNode;
      AText: string; var AAllow: Boolean);
  private
    FInternalEdit: Boolean;
    FMenu: TMainMenu;
    FDTMaster: TFDTransaction;
    FActions: TObject;
    FExtraRights: TUCExtraRights;
    FUserControl: TFMXUserControl;
    FConnection: TFDConnection;
    Tree: TTMSFMXCheckedTreeView;
    CheckStates: TTMSFMXTreeViewNodeCheckStates;
    // procedure CrearNodo(IT: TActionClientItem; Node: TTMSFMXTreeViewNode); overload;
    procedure CrearNodo(IT: TMenuItem; Node: TTMSFMXTreeViewNode); overload;
    procedure CrearNodo(Padre: Integer; Arbol: TTMSFMXTreeView; NodoPadre: TTMSFMXTreeViewNode); overload;
    procedure CargaTreeviews;
    procedure CambiaCheckAllChild(Tree: TTMSFMXCheckedTreeView; Check: Boolean; ANodo: TTMSFMXTreeViewNode);
    procedure CambiaCheckAllParents(Tree: TTMSFMXCheckedTreeView; ANodo: TTMSFMXTreeViewNode);
    procedure BorraComponente(Nodo: TTMSFMXTreeViewNode);
    procedure RegistraComponente(Nodo: TTMSFMXTreeViewNode);

  public
    IsGroup: Boolean;
    Clave: Integer;
    constructor CreateEx(AOwner: TComponent; ATrans: TFDTransaction; AConn: TFDConnection; UC: TFMXUserControl);
    procedure RevisaPermisosGrupo(ATree: TTMSFMXCheckedTreeView; Todos: Boolean = False);
    procedure RevisaPermisosUsuario(ATree: TTMSFMXCheckedTreeView);
  end;

var
  FMXUserPermis: TFMXUserPermis;

implementation

{$R *.fmx}

uses FMX.UCHelpers;

constructor TFMXUserPermis.CreateEx(AOwner: TComponent; ATrans: TFDTransaction; AConn: TFDConnection; UC: TFMXUserControl);
var
  i: Integer;
begin
  inherited Create(AOwner);
  FInternalEdit := False;
  FUserControl := UC;
  FConnection := AConn;
  FDTMaster := ATrans;
  try
    with FUserControl.UserSettings.Rights do
    begin
      Self.Caption := WindowCaption;
      Self.LbDescricao.Text := LabelUser;
      Self.PageMenu.Text := PageMenu;
      Self.PageAction.Text := PageActions;
      Self.PageControls.Text := PageControls;
      Self.Position := FUserControl.UserSettings.WindowsPosition;
    end;

    for i := 0 to (ComponentCount - 1) do
      If ((Components[i] Is TFDQuery)) Then
      begin
        TFDQuery(Components[i]).Transaction := FDTMaster;
        TFDQuery(Components[i]).UpdateTransaction := FDTMaster;
        TFDQuery(Components[i]).Connection := FConnection;
      end
      else if ((Components[i] Is TFDUpdateSQL)) then
        TFDUpdateSQL(Components[i]).Connection := FConnection
      else if ((Components[i] Is TFDTransaction)) then
        TFDTransaction(Components[i]).Connection := FConnection;
  except
    on E: Exception do
      raise Exception.Create('Error conectando a Firebird');
  end;
  CargaTreeviews;
  SetLength(CheckStates, 1);
end;

procedure TFMXUserPermis.CrearNodo(IT: TMenuItem; Node: TTMSFMXTreeViewNode);
var
  i: Integer;
  Nodo: TTMSFMXTreeViewNode;
begin
  for i := 0 to IT.ItemsCount - 1 do
  begin
    if IT.Items[i].Text <> '-' then
    begin
      if IT.Items[i].ItemsCount > 0 then
      begin
        Nodo := TreeMenu.AddNode(Node);
        Nodo.Text[0] := StringReplace(IT.Items[i].Text, '&', '', [rfReplaceAll]);
        Nodo.Text[1] := IT.Items[i].Name;
        Nodo.Checked[0] := False;
        TreeMenu.UnCheckNode(Nodo, 0, False);
        Nodo.CheckTypes[1] := tvntNone;
        if not IsGroup then
          Nodo.CheckTypes[2] := tvntNone;
        CrearNodo(IT.Items[i], Nodo);
      end
      else
      begin
        Nodo := TreeMenu.AddNode(Node);
        Nodo.Text[0] := StringReplace(IT.Items[i].Text, '&', '', [rfReplaceAll]);
        Nodo.Text[1] := IT.Items[i].Name;
        Nodo.Checked[0] := False;
        TreeMenu.UnCheckNode(Nodo, 0, False);
        Nodo.CheckTypes[1] := tvntNone;
        if not IsGroup then
          Nodo.CheckTypes[2] := tvntNone;
      end;
    end;
  end;
end;
{
  procedure TFMXUserPermis.CrearNodo(IT: T; Node: TTMSFMXTreeViewNode);
  var
  i: Integer;
  Nodo: TTMSFMXTreeViewNode;
  begin
  for i := 0 to IT.Items.Count - 1 do
  begin
  if IT.Items[i].Caption <> '-' then
  begin
  if IT.Items[i].Items.Count > 0 then
  begin
  // Nodo := TreeMenu.Items.AddChild(Node, StringReplace(IT.Items[i].Caption, '&', '', [rfReplaceAll]));
  // TCustomTreeNode(Nodo).MenuName := #1 + 'G' + IT.Items[i].Caption;
  // CrearNodo(IT.Items[i], Nodo);
  end
  else
  begin
  // Nodo := TreeMenu.Items.AddChild(Node, StringReplace(IT.Items[i].Caption, '&', '', [rfReplaceAll]));
  // TCustomTreeNode(Nodo).MenuName := IT.Items[i].Action.Name;
  end;
  end;
  end;
  end; }

procedure TFMXUserPermis.CrearNodo(Padre: Integer; Arbol: TTMSFMXTreeView; NodoPadre: TTMSFMXTreeViewNode);
var
  Nodo: TTMSFMXTreeViewNode;
  i: Integer;
begin
  i := 0;
  FDMemTable1.First;
  while not FDMemTable1.Eof do
  begin
    if FDMemTable1.FieldByName('Padre').AsInteger = Padre then
    begin
      Nodo := TreeInterno.AddNode(NodoPadre); // el procedimento ya se encarga de comprobar si en nil para geerar un rootlevel
      Nodo.Text[0] := FDMemTable1.FieldByName('Nombre').AsString;
      Nodo.Text[1] := FDMemTable1.FieldByName('GUID').AsString;
      Nodo.Checked[0] := False;
      Nodo.CheckTypes[0] := tvntCheckBox;
      TreeInterno.UnCheckNode(Nodo, 0, False);
      Nodo.CheckTypes[1] := tvntNone;
      if not IsGroup then
        Nodo.CheckTypes[2] := tvntNone;
      CrearNodo(FDMemTable1.FieldByName('Clave').AsInteger, Arbol, Nodo); // llamamos recursivamente para cada hijo
    end;
    inc(i);
    FDMemTable1.First;
    FDMemTable1.MoveBy(i);
  end;
end;

procedure TFMXUserPermis.CargaTreeviews;
var
  i: Integer;
  Nodo, NodoPadre: TTMSFMXTreeViewNode;

  Grupo: String;
begin
  PC.ActiveTab := PageMenu;

  FMenu := FUserControl.ControlRight.MainMenu;
  // FActionMainMenuBar := FUserControl.ControlRight.ActionMainMenuBar;
  if Assigned(FUserControl.ControlRight.ActionList) then
    FActions := FUserControl.ControlRight.ActionList;
  FExtraRights := FUserControl.ExtraRights;

  TreeInterno.BeginUpdate;
  TreeInterno.Columns.Clear;
  TreeInterno.Nodes.Clear;
  TreeInterno.Columns.Add.Text := 'Permisos';
  TreeInterno.Columns.Add.Text := 'GUID';
  if not IsGroup then
    TreeInterno.Columns.Add.Text := 'Grupos';
  TreeInterno.Columns.Items[1].Visible := False;
  FDMemTable1.Open;
  CrearNodo(0, TreeInterno, nil);
  // TreeInterno.Perform(WM_VSCROLL, SB_TOP, 0);
  TreeInterno.CollapseAll;
  TreeInterno.EndUpdate;

  if Assigned(FMenu) then
  begin
    TreeMenu.BeginUpdate;
    TreeMenu.Columns.Clear;
    TreeMenu.Nodes.Clear;
    TreeMenu.Columns.Add.Text := 'Menus';
    TreeMenu.Columns.Add.Text := 'NombresMenus';
    if not IsGroup then
      TreeMenu.Columns.Add.Text := 'Grupos';
    TreeMenu.Columns.Items[1].Visible := False;
    for i := 0 to FMenu.ItemsCount - 1 do
      if FMenu.Items[i].ChildrenCount > 0 then
      begin
        Nodo := TreeMenu.AddNode;
        // Nodo.Text[0] := StringReplace(FMenu.Items[i].Text, '&', '', [rfReplaceAll]);
        Nodo.Text[1] := FMenu.Items[i].Name;
        Nodo.Checked[0] := False;
        TreeMenu.UnCheckNode(Nodo, 0, False);
        Nodo.CheckTypes[1] := tvntNone;
        if not IsGroup then
          Nodo.CheckTypes[2] := tvntNone;
        // CrearNodo(FMenu.Items[i], Nodo);
      end
      else if FMenu.Items[i].ClassName <> '-' then
      begin
        Nodo := TreeMenu.AddNode;
        // Nodo.Text[0] := StringReplace(FMenu.Items[i].Text, '&', '', [rfReplaceAll]);
        Nodo.Text[1] := FMenu.Items[i].Name;
        Nodo.Checked[0] := False;
        TreeMenu.UnCheckNode(Nodo, 0, False);
        Nodo.CheckTypes[1] := tvntNone;
        if not IsGroup then
          Nodo.CheckTypes[2] := tvntNone;
      end;
    // TreeAction.FullCollapse;
    // TreeMenu.Perform(WM_VSCROLL, SB_TOP, 0);
    TreeMenu.EndUpdate;
  end;

  { if Assigned(FActionMainMenuBar) then
    begin
    TreeMenu.Items.Clear;
    for i := 0 to FActionMainMenuBar.ActionClient.Items.Count - 1 do
    begin
    Temp := IntToStr(i);
    if FActionMainMenuBar.ActionClient.Items[StrToInt(Temp)].Items.Count > 0 then
    begin
    Nodo := TreeMenu.Items.Add(nil, StringReplace(FActionMainMenuBar.ActionClient.Items[StrToInt(Temp)].Caption, '&', '', [rfReplaceAll]));
    TCustomTreeNode(Nodo).MenuName := #1 + 'G' + FActionMainMenuBar.ActionClient.Items[StrToInt(Temp)].Caption;
    CrearNodo(FActionMainMenuBar.ActionClient.Items[StrToInt(Temp)], Nodo);
    end
    else
    begin
    if FActionMainMenuBar.ActionClient.Items[StrToInt(Temp)].Items.Count > 0 then
    begin
    Nodo := TreeMenu.Items.Add(nil, StringReplace(FActionMainMenuBar.ActionClient.Items[StrToInt(Temp)].Caption, '&', '', [rfReplaceAll]));
    TCustomTreeNode(Nodo).MenuName := FActionMainMenuBar.ActionClient.Items[StrToInt(Temp)].Action.Name;
    end;
    end;
    TreeAction.FullCollapse;
    TreeMenu.Perform(WM_VSCROLL, SB_TOP, 0);
    end;
    end; }

  if Assigned(FActions) then
  begin
    TreeAction.BeginUpdate;
    TreeAction.Columns.Clear;
    TreeAction.Nodes.Clear;
    TreeAction.Columns.Add.Text := 'acciones';
    TreeAction.Columns.Add.Text := 'hint';
    // if not IsGroup then
    // TreeAction.Columns.Add.Text := 'Grupos';
    // TreeAction.Columns.Items[1].Visible := False;
    for i := 0 to TActionList(FActions).ActionCount - 1 do
    begin
      Nodo := TreeAction.AddNode;
      Nodo.Text[0] := StringReplace(TAction(TActionList(FActions).Actions[i]).Caption, '&', '', [rfReplaceAll]);
      Nodo.Text[1] := StringReplace(TAction(TActionList(FActions).Actions[i]).Hint, '&', '', [rfReplaceAll]);
      // Nodo.Text[1] := StringReplace(TActionList(FActions).Actions[i].Name, '&', '', [rfReplaceAll]);

      Nodo.Checked[0] := False;
      TreeAction.UnCheckNode(Nodo, 0, False);
      Nodo.CheckTypes[0] := tvntCheckBox;
      Nodo.CheckTypes[1] := tvntNone;
      // if not IsGroup then
      // Nodo.CheckTypes[2] := tvntNone;
      // CrearNodo(TActionList(FActions).Actions[i], Nodo);
    end;
    TreeAction.CollapseAll;
    TreeAction.EndUpdate;
  end;

  { FTempLista := TStringList.Create;
    try
    for i := 0 to TActionList(FActions).ActionCount - 1 do
    FTempLista.Append(TActionList(FActions).Actions[i].Category + #1 + TActionList(FActions).Actions[i].Name + #2 + TAction(TActionList(FActions).Actions[i]).Caption);
    FTempLista.Sort;
    Temp := #1;
    for i := 0 to FTempLista.Count - 1 do
    begin
    if Temp <> Copy(FTempLista[i], 1, Pos(#1, FTempLista[i]) - 1) then
    begin
    Nodo := TreeAction.Items.Add(nil, StringReplace(Copy(FTempLista[i], 1, Pos(#1, FTempLista[i]) - 1), '&', '', [rfReplaceAll]));
    TCustomTreeNode(Nodo).Grupo := True;
    TCustomTreeNode(Nodo).MenuName := 'Grupo';
    Nodo.SelectedIndex := 2;
    Temp := Copy(FTempLista[i], 1, Pos(#1, FTempLista[i]) - 1);
    end;
    Temp2 := FTempLista[i];
    Delete(Temp2, 1, Pos(#1, Temp2));
    Nodo := TreeAction.Items.Add(nil, StringReplace(Temp2, '&', '', [rfReplaceAll]));
    TCustomTreeNode(Nodo).Grupo := False;
    TCustomTreeNode(Nodo).MenuName := Copy(Temp2, 1, Pos(#2, Temp2) - 1);
    Delete(Temp2, 1, Pos(#2, Temp2));
    end;
    TreeAction.FullCollapse;
    TreeAction.Perform(WM_VSCROLL, SB_TOP, 0);
    finally
    FTempLista.Free;
    end;
    end; }

  { ExtraRights }
  if Self.FExtraRights.Count > 0 then
  begin
    TreeControls.BeginUpdate;
    TreeControls.Columns.Clear;
    TreeControls.Nodes.Clear;
    TreeControls.Columns.Add.Text := 'Controles';
    TreeControls.Columns.Add.Text := 'CompName';
    TreeControls.Columns.Add.Text := 'FormName';
    TreeControls.Columns.Add.Text := 'Grupo';
    TreeControls.Columns.Add.Text := 'Tipo';
    TreeControls.Columns[4].EditorType := tcetComboBox;
    TreeControls.Columns[4].EditorItems.Add('Solo lectura');
    TreeControls.Columns[4].EditorItems.Add('Lectura y escritura total');
    TreeControls.Columns[4].EditorItems.Add('Lectura y escritura a nivel');
    TreeControls.Columns[4].EditorItems.Add('Lectura y escritura a nivel superior');
    TreeControls.Columns.Items[1].Visible := False;
    TreeControls.Columns.Items[2].Visible := False;
    FExtraRights.Sort;
    Grupo := '';
    NodoPadre := nil;
    for i := 0 to FExtraRights.Count - 1 do
    begin
      if Grupo <> FExtraRights.Items[i].GroupName then
      begin
        NodoPadre := TreeControls.AddNode;
        with NodoPadre do
        begin
          Text[0] := FExtraRights.Items[i].GroupName;
          Text[1] := '';
          Text[2] := '';
          Text[3] := '';
          Text[4] := '';
          CheckTypes[0] := tvntNone;
          CheckTypes[1] := tvntNone;
          CheckTypes[2] := tvntNone;
          CheckTypes[3] := tvntNone;
          CheckTypes[4] := tvntNone;
        end;
      end;
      if NodoPadre <> nil then
      begin
        Nodo := TreeControls.AddNode(NodoPadre);
        Nodo.Text[0] := FExtraRights.Items[i].Caption;
        Nodo.Text[1] := FExtraRights.Items[i].Componente;
        Nodo.Text[2] := FExtraRights.Items[i].Formulario;
        Nodo.Text[3] := '';
        Nodo.Text[4] := 'Solo lectura';
        Nodo.CheckTypes[0] := tvntCheckBox;
        Nodo.CheckTypes[1] := tvntNone;
        Nodo.CheckTypes[2] := tvntNone;
        Nodo.CheckTypes[3] := tvntNone;
        Nodo.CheckTypes[4] := tvntNone;
        Nodo.Checked[0] := False;
        TreeControls.UnCheckNode(Nodo, 0, False);
      end;
      Grupo := FExtraRights.Items[i].GroupName;
    end;
    // TreeAction.FullCollapse;
    // TreeControls.Perform(WM_VSCROLL, SB_TOP, 0);
    TreeControls.EndUpdate;
  end;
  PageMenu.Visible := Assigned(FMenu);
  PageAction.Visible := Assigned(FActions);
  PageControls.Visible := (Assigned(FExtraRights) and (FExtraRights.Count > 0));
end;

procedure TFMXUserPermis.BtCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFMXUserPermis.btnBloquearAllClick(Sender: TObject);
var
  Node: TTMSFMXTreeViewNode;
begin
  FInternalEdit := True;
  Node := Tree.Nodes.Items[0];
  while Node <> nil do
  begin
    if not Node.Checked[0] then
    begin
      Node.Checked[0] := True;
      Tree.CheckNode(Node, 0, False);
      RegistraComponente(Node);
    end;
    Node := Node.GetNext;
  end;
  FInternalEdit := False;
end;

procedure TFMXUserPermis.btnReleaseAllClick(Sender: TObject);
var
  KeyField: string;
  Node: TTMSFMXTreeViewNode;
begin
  try
    FInternalEdit := True;
    FDPermisos.Close;
    KeyField := 'CLAVE_USER';
    if IsGroup then
      KeyField := 'CLAVE_GROUP';
    FDPermisos.SQL.Clear;
    case PC.TabIndex of
      0, 1, 3:
        FDPermisos.SQL.Add('DELETE FROM INT$UC_RIGHTS WHERE MODULO=:PMODULO AND ' + KeyField + '=:PCLAVE');
      2:
        FDPermisos.SQL.Add('DELETE FROM INT$UC_RIGHTSEX WHERE MODULO=:PMODULO AND ' + KeyField + '=:PCLAVE');
    end;
    FDPermisos.ParamByName('PCLAVE').AsInteger := Clave;
    FDPermisos.ParamByName('PMODULO').AsString := FUserControl.ApplicationID;
    FDPermisos.ExecSQL;
    btnAceptar.ModalResult := mrOk;
    Node := Tree.Nodes.Items[0];
    while Node <> nil do
    begin
      if Node.Enabled then
      begin
        Node.Checked[0] := False;
        Tree.UnCheckNode(Node, 0, False);
      end;
      Node := Node.GetNext;
    end;
    FInternalEdit := False;
  except
    on E: Exception do
    begin
      TaskDialog.Title := 'Error grave';
      TaskDialog.Content := E.Message;
      TaskDialog.InstructionText := 'Se ha producido una excepción';
      TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 0);
      TaskDialog.Show();
    end;
  end;
end;

procedure TFMXUserPermis.PCChange(Sender: TObject);
begin
  case PC.TabIndex of
    0:
      Tree := TreeMenu;
    1:
      Tree := TreeAction;
    2:
      Tree := TreeControls;
    3:
      Tree := TreeInterno;
  end;
end;

procedure TFMXUserPermis.RevisaPermisosGrupo(ATree: TTMSFMXCheckedTreeView; Todos: Boolean = False);
var
  Node: TTMSFMXTreeViewNode;
  FDBusca: TFDQuery;
  Index: Integer;
  Temp: string;
begin
  ATree.BeginUpdate;
  FDPermisos.Close;
  FDPermisos.SQL.Clear;
  FDBusca := FDBuscaGruposComp;
  Index := 2;
  if ATree.Name = 'TreeControls' then
  begin
    FDBusca := FDBuscaGruposCompEx;
    Index := 3;
  end;

  if Todos then
  begin
    FDPermisos.SQL.Add('SELECT A.* ');
    FDPermisos.SQL.Add('FROM INT$UC_USER_GROUP A ');
    if ATree.Name = 'TreeControls' then
      FDPermisos.SQL.Add('LEFT JOIN INT$UC_RIGHTSEX R ON A.CLAVE_GROUP=R.CLAVE_GROUP ')
    else
      FDPermisos.SQL.Add('LEFT JOIN INT$UC_RIGHTS R ON A.CLAVE_GROUP=R.CLAVE_GROUP ');
    FDPermisos.SQL.Add('WHERE A.CLAVE_USER=:PCLAVE ');
    FDPermisos.SQL.Add('AND R.MODULO=:PMODULO ');
    FDPermisos.SQL.Add('AND R.COMPONENTE=:PCOMPONENTE');
    if ATree.Name = 'TreeControls' then
      FDPermisos.SQL.Add('AND R.FORMULARIO=:PFORMULARIO');
  end
  else
  begin
    if ATree.Name = 'TreeControls' then
      FDPermisos.SQL.Text :=
        'SELECT * FROM INT$UC_RIGHTSEX WHERE MODULO=:PMODULO AND FORMULARIO=:PFORMULARIO AND COMPONENTE=:PCOMPONENTE AND CLAVE_GROUP=:PCLAVE'
    else
      FDPermisos.SQL.Text := 'SELECT * FROM INT$UC_RIGHTS WHERE MODULO=:PMODULO AND COMPONENTE=:PCOMPONENTE AND CLAVE_GROUP=:PCLAVE';
  end;

  Node := ATree.Nodes.Items[0];
  while Node <> nil do
  begin
    FDPermisos.Close;
    FDPermisos.ParamByName('PCLAVE').AsInteger := Clave;
    FDPermisos.ParamByName('PMODULO').AsString := FUserControl.ApplicationID;
    FDPermisos.ParamByName('PCOMPONENTE').AsString := Node.Text[1];
    if ATree.Name = 'TreeControls' then
      FDPermisos.ParamByName('PFORMULARIO').AsString := Node.Text[2];
    FDPermisos.Open;

    if FDPermisos.RecordCount > 0 then
    begin
      Node.Checked[0] := True;
      ATree.CheckNode(Node, 0, False);
      if (not IsGroup) and (Node.CheckTypes[0] <> tvntNone) then
      begin
        FDBusca.Close;
        FDBusca.ParamByName('PCLAVE').AsInteger := Clave;
        FDBusca.ParamByName('PMODULO').AsString := FUserControl.ApplicationID;
        FDBusca.ParamByName('PCOMPONENTE').AsString := Node.Text[1];
        if ATree.Name = 'TreeControls' then
          FDBusca.ParamByName('PFORMULARIO').AsString := Node.Text[2];
        FDBusca.Open;
        Node.Text[Index] := '';
        while not FDBusca.Eof do
        begin
          Node.Text[Index] := Node.Text[Index] + FDBusca.FieldByName('UC_NOMBRE').AsString + ',';
          FDBusca.Next;
        end;
        Temp := Node.Text[Index];
        Delete(Temp, Length(Temp), 1);
        Node.Text[Index] := Temp;
        Node.Expanded := True;
        Node.Enabled := False;
      end;
    end;
    Memo1.Lines.Add('Componente ' + Node.Text[1] + ' Estado: ');
    Node.Checked[0] := not FDPermisos.IsEmpty;
    Node.Enabled := (IsGroup or FDPermisos.IsEmpty);
    Node := Node.GetNext;
  end;
  ATree.EndUpdate;
end;

procedure TFMXUserPermis.RevisaPermisosUsuario(ATree: TTMSFMXCheckedTreeView);
var
  Node: TTMSFMXTreeViewNode;
begin
  Node := ATree.Nodes.Items[0];
  FDPermisos.Close;
  FDPermisos.SQL.Clear;
  if ATree.Name = 'TreeControls' then
    FDPermisos.SQL.Text :=
      'SELECT * FROM INT$UC_RIGHTSEX WHERE CLAVE_USER=:PCLAVE AND FORMULARIO=:PFORMULARIO AND MODULO=:PMODULO AND COMPONENTE=:PCOMPONENTE'
  else
    FDPermisos.SQL.Text := 'SELECT * FROM INT$UC_RIGHTS WHERE CLAVE_USER=:PCLAVE AND MODULO=:PMODULO AND COMPONENTE=:PCOMPONENTE';
  while Node <> nil do
  begin
    FDPermisos.Close;
    FDPermisos.ParamByName('PCLAVE').AsInteger := Clave;
    FDPermisos.ParamByName('PMODULO').AsString := FUserControl.ApplicationID;
    FDPermisos.ParamByName('PCOMPONENTE').AsString := Node.Text[1];
    if ATree.Name = 'TreeControls' then
      FDPermisos.ParamByName('PFORMULARIO').AsString := Node.Text[2];
    FDPermisos.Open;
    if FDPermisos.RecordCount > 0 then
    begin
      Node.Checked[0] := True;
      ATree.CheckNode(Node, 0, False);
    end;
    Node := Node.GetNext;
  end;
end;

procedure TFMXUserPermis.FormShow(Sender: TObject);
begin
  Tree := TreeMenu;
  if IsGroup then
  begin
    if PageMenu.Visible then
      RevisaPermisosGrupo(TreeMenu);
    if PageAction.Visible then
      RevisaPermisosGrupo(TreeAction);
    if PageControls.Visible then
      RevisaPermisosGrupo(TreeControls);
    if PageAplicacion.Visible then
      RevisaPermisosGrupo(TreeInterno);
  end
  else
  begin
    if PageMenu.Visible then
    begin
      RevisaPermisosGrupo(TreeMenu, True);
      RevisaPermisosUsuario(TreeMenu);
    end;
    if PageAction.Visible then
    begin
      RevisaPermisosGrupo(TreeAction, True);
      RevisaPermisosUsuario(TreeAction);
    end;
    if PageControls.Visible then
    begin
      RevisaPermisosGrupo(TreeControls, True);
      RevisaPermisosUsuario(TreeControls);
    end;
    if PageAplicacion.Visible then
    begin
      RevisaPermisosGrupo(TreeInterno, True);
      RevisaPermisosUsuario(TreeInterno);
    end;
  end;
end;

procedure TFMXUserPermis.CambiaCheckAllChild(Tree: TTMSFMXCheckedTreeView; Check: Boolean; ANodo: TTMSFMXTreeViewNode);
var
  NextNode: TTMSFMXTreeViewNode;
begin
  if ANodo <> nil then
  begin
    NextNode := ANodo.GetFirstChild;
    while NextNode <> nil do
    begin
      NextNode.Checked[0] := Check;
      if Check then
        Tree.CheckNode(NextNode, 0, False)
      else
        Tree.UnCheckNode(NextNode, 0, False);
      if Check then
        RegistraComponente(NextNode)
      else
        BorraComponente(NextNode);
      CambiaCheckAllChild(Tree, Check, NextNode);
      NextNode := NextNode.GetNextSibling;
    end;
  end;
end;

procedure TFMXUserPermis.CambiaCheckAllParents(Tree: TTMSFMXCheckedTreeView; ANodo: TTMSFMXTreeViewNode);
var
  NextNode: TTMSFMXTreeViewNode;
begin
  if ANodo <> nil then
  begin
    NextNode := ANodo.GetParent;
    while NextNode <> nil do
    begin
      if not NextNode.Checked[0] then
      begin
        NextNode.Checked[0] := True;
        Tree.CheckNode(NextNode, 0, False);
        RegistraComponente(NextNode);
      end;
      NextNode := NextNode.GetParent;
    end;
  end;
end;

procedure TFMXUserPermis.ToolButton1Click(Sender: TObject);
begin

  FDMemTable1.Append;
  FDMemTable1.FieldByName('nombre').AsString := 'hola';
  FDMemTable1.FieldByName('clave').AsInteger := 122;
  FDMemTable1.FieldByName('padre').AsInteger := 12;
  FDMemTable1.FieldByName('GUID').AsString := 'fsfsdfsdfsdfsfsdfsd';
  FDMemTable1.Post;

end;

procedure TFMXUserPermis.ToolButton2Click(Sender: TObject);
begin
  // FDMemTable1.SaveToFile('S:\Test.json', TFDStorageFormat.sfJSON);
end;

procedure TFMXUserPermis.TreeControlsBeforeDrawNodeText(Sender: TObject; ACanvas: TCanvas; ARect: TRectF; AColumn: Integer;
  ANode: TTMSFMXTreeViewVirtualNode; AText: string; var AAllow: Boolean);
begin
  //
end;

procedure TFMXUserPermis.TreeMenuAfterCheckNode(Sender: TObject; ANode: TTMSFMXTreeViewVirtualNode; AColumn: Integer);
begin
  if not FInternalEdit then
  begin
    try
      RegistraComponente(ANode.Node);
      if (btnHerencia.IsPressed) then
      begin
        FInternalEdit := True;
        CambiaCheckAllChild(TTMSFMXCheckedTreeView(Sender), True, ANode.Node);
        CambiaCheckAllParents(TTMSFMXCheckedTreeView(Sender), ANode.Node);
        FInternalEdit := False;
      end;
    except
      on E: Exception do
      begin
        TaskDialog.Title := 'Error grave';
        TaskDialog.Content := E.Message;
        TaskDialog.InstructionText := 'Se ha producido una excepción';
        TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 0);
        TaskDialog.Show();
      end;
    end;
  end;
end;

procedure TFMXUserPermis.TreeMenuAfterUnCheckNode(Sender: TObject; ANode: TTMSFMXTreeViewVirtualNode; AColumn: Integer);
begin
  if not FInternalEdit then
  begin
    try
      BorraComponente(ANode.Node);
      if (btnHerencia.IsPressed) then
      begin
        FInternalEdit := True;
        CambiaCheckAllChild(TTMSFMXCheckedTreeView(Sender), False, ANode.Node);
        FInternalEdit := False;
      end;
      TreeMenu.EndUpdate;
    except
      on E: Exception do
      begin
        TaskDialog.Title := 'Error grave';
        TaskDialog.Content := E.Message;
        TaskDialog.InstructionText := 'Se ha producido una excepción';
        TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 0);
        TaskDialog.Show();
      end;
    end;
  end;
end;

procedure TFMXUserPermis.TreeInternoAfterCheckNode(Sender: TObject; ANode: TTMSFMXTreeViewVirtualNode; AColumn: Integer);
begin
  { FDPermisos.SQL.Clear;
    case PC.TabIndex of
    0, 1:
    begin
    FDPermisos.SQL.Add('INSERT INTO INT$UC_RIGHTS (CLAVE,CLAVE_USER,CLAVE_GROUP,MODULO,COMPONENTE,KEY) ');
    FDPermisos.SQL.Add('VALUES(:CLAVE,:CLAVE_USER,:CLAVE_GROUP,:MODULO,:COMPONENTE,:KEY)');
    end;
    2:
    begin
    FDPermisos.SQL.Add('INSERT INTO INT$UC_RIGHTSEX (CLAVE,CLAVE_USER,CLAVE_GROUP,FORMULARIO,MODULO,COMPONENTE,KEY) ');
    FDPermisos.SQL.Add('VALUES(:CLAVE,:CLAVE_USER,:CLAVE_GROUP,:FORMULARIO,:MODULO,:COMPONENTE,:KEY)');
    FDPermisos.ParamByName('FORMULARIO').AsString := ANode.Text[2];
    end;
    end;

    if IsGroup then
    FDPermisos.ParamByName('CLAVE_GROUP').AsInteger := Clave
    else
    FDPermisos.ParamByName('CLAVE_USER').AsInteger := Clave;

    FDPermisos.ParamByName('MODULO').AsString := FUserControl.ApplicationID;
    FDPermisos.ParamByName('COMPONENTE').AsString := ANode.Text[1];
    FDPermisos.ParamByName('KEY').AsString := GetKeyTPermisos(Clave, ANode.Text[1]);
    FDPermisos.ExecSQL;
    Button1.ModalResult := mrOk; }

end;

procedure TFMXUserPermis.TreeInternoAfterUnCheckNode(Sender: TObject; ANode: TTMSFMXTreeViewVirtualNode; AColumn: Integer);
begin
  { try
    FDPermisos.Close;
    KeyField := 'CLAVE_USER';
    if IsGroup then
    KeyField := 'CLAVE_GROUP';
    FDPermisos.SQL.Clear;
    case PC.TabIndex of
    0, 1:
    FDPermisos.SQL.Add('DELETE FROM INT$UC_RIGHTS WHERE COMPONENTE=:PCOMPONENTE AND MODULO=:PMODULO AND ' + KeyField + '=:PCLAVE');
    2:
    begin
    FDPermisos.SQL.Add('DELETE FROM INT$UC_RIGHTSEX WHERE FORMULARIO=:PFORMULARIO AND COMPONENTE=:PCOMPONENTE AND MODULO=:PMODULO AND ' + KeyField + '=:PCLAVE');
    FDPermisos.ParamByName('PFORMULARIO').AsString := ANode.Text[2];
    end;
    end;
    FDPermisos.ParamByName('PCLAVE').AsInteger := Clave;
    FDPermisos.ParamByName('PMODULO').AsString := FUserControl.ApplicationID;
    FDPermisos.ParamByName('PCOMPONENTE').AsString := ANode.Text[1];
    FDPermisos.ExecSQL;
    Button1.ModalResult := mrOk;
    except
    on E: Exception do
    MessageDlg(E.Message, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
    end; }
end;

procedure TFMXUserPermis.BorraComponente(Nodo: TTMSFMXTreeViewNode);
var
  KeyField: string;
begin
  try
    FDPermisos.Close;
    KeyField := 'CLAVE_USER';
    if IsGroup then
      KeyField := 'CLAVE_GROUP';
    FDPermisos.SQL.Clear;
    case PC.TabIndex of
      0, 1, 3:
        FDPermisos.SQL.Add('DELETE FROM INT$UC_RIGHTS WHERE COMPONENTE=:PCOMPONENTE AND MODULO=:PMODULO AND ' + KeyField + '=:PCLAVE');
      2:
        begin
          FDPermisos.SQL.Add('DELETE FROM INT$UC_RIGHTSEX WHERE FORMULARIO=:PFORMULARIO AND COMPONENTE=:PCOMPONENTE AND MODULO=:PMODULO AND ' +
            KeyField + '=:PCLAVE');
          FDPermisos.ParamByName('PFORMULARIO').AsString := Nodo.Text[2];
        end;
    end;
    FDPermisos.ParamByName('PCLAVE').AsInteger := Clave;
    FDPermisos.ParamByName('PMODULO').AsString := FUserControl.ApplicationID;
    FDPermisos.ParamByName('PCOMPONENTE').AsString := Nodo.Text[1];
    FDPermisos.ExecSQL;
    btnAceptar.ModalResult := mrOk;
  except
    on E: Exception do
    begin
      TaskDialog.Title := 'Error grave';
      TaskDialog.Content := E.Message;
      TaskDialog.InstructionText := 'Se ha producido una excepción';
      TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 0);
      TaskDialog.Show();
    end;
  end;
end;

procedure TFMXUserPermis.RegistraComponente(Nodo: TTMSFMXTreeViewNode);
begin

  FDPermisos.SQL.Clear;
  case PC.TabIndex of
    0, 1, 3:
      begin
        FDPermisos.SQL.Add('INSERT INTO INT$UC_RIGHTS (DESC,CLAVE_USER,CLAVE_GROUP,MODULO,COMPONENTE,KEY) ');
        FDPermisos.SQL.Add('VALUES(:DESC,:CLAVE_USER,:CLAVE_GROUP,:MODULO,:COMPONENTE,:KEY)');
        FDPermisos.ParamByName('DESC').AsString := Nodo.Text[0];
      end;
    2:
      begin
        FDPermisos.SQL.Add('INSERT INTO INT$UC_RIGHTSEX (CLAVE_USER,CLAVE_GROUP,FORMULARIO,MODULO,COMPONENTE,KEY) ');
        FDPermisos.SQL.Add('VALUES(:CLAVE_USER,:CLAVE_GROUP,:FORMULARIO,:MODULO,:COMPONENTE,:KEY)');
        FDPermisos.ParamByName('FORMULARIO').AsString := Nodo.Text[2];
      end;
  end;

  if IsGroup then
    FDPermisos.ParamByName('CLAVE_GROUP').AsInteger := Clave
  else
    FDPermisos.ParamByName('CLAVE_USER').AsInteger := Clave;
  FDPermisos.ParamByName('MODULO').AsString := FUserControl.ApplicationID;
  FDPermisos.ParamByName('COMPONENTE').AsString := Nodo.Text[1];
  FDPermisos.ParamByName('KEY').AsString := GetKeyTPermisos(Clave, Nodo.Text[1]);
  FDPermisos.ExecSQL;
  btnAceptar.ModalResult := mrOk;
end;

procedure TFMXUserPermis.Button1Click(Sender: TObject);
begin
  if FDTMaster.Active then
    FDTMaster.CommitRetaining;
end;

procedure TFMXUserPermis.Button2Click(Sender: TObject);
begin
  if FDTMaster.Active then
    FDTMaster.RollbackRetaining;
end;

procedure TFMXUserPermis.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TFMXUserPermis.FormDestroy(Sender: TObject);
begin
  FMXUserPermis := nil;
end;

end.
