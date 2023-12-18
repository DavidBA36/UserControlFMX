unit FMX.UCObjSel_U;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.UCBase, FMX.UcConsts_Language, FMX.TMSLiveGrid, FMX.TMSCustomGrid,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Rtti, FMX.Grid.Style, FMX.Objects, FMX.ListBox, FMX.Grid, FMX.StdCtrls, System.ImageList, FMX.ImgList,
  FMX.Layouts, FMX.ScrollBox, FMX.Controls.Presentation, FMX.Menus, Data.DB, FMX.ActnList, FMX.Edit, FMX.TMSBaseControl, FMX.TMSGridCell, FMX.TMSGridOptions, FMX.TMSGridData,
  FMX.TMSGrid;

type
  TUCObjSel = class(TForm)
    Panel1: TPanel;
    Splitter1: TSplitter;
    GridPanelLayout1: TGridPanelLayout;
    btsellall: TButton;
    btsel: TButton;
    btunsel: TButton;
    btunselall: TButton;
    ImageList1: TImageList;
    StyleBook1: TStyleBook;
    GridPanelLayout2: TGridPanelLayout;
    lbCompSel: TLabel;
    lbCompDisp: TLabel;
    cbFilter: TComboBox;
    BtOK: TButton;
    btCancela: TButton;
    Panel2: TPanel;
    Image1: TImage;
    GridPanelLayout3: TGridPanelLayout;
    lbtitle: TLabel;
    lbform: TLabel;
    lbgrupo_title: TLabel;
    lbgrupo_valor: TLabel;
    ListaCompsDisponiveis: TTMSFMXGrid;
    ListaCompsSelecionados: TTMSFMXGrid;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbFilterClick(Sender: TObject);
    procedure cbFilterKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure BtOKClick(Sender: TObject);
    procedure btCancelaClick(Sender: TObject);
    procedure btunselallClick(Sender: TObject);
    procedure btselClick(Sender: TObject);
    procedure btsellallClick(Sender: TObject);
    procedure btunselClick(Sender: TObject);
    procedure cbFilterClosePopup(Sender: TObject);
  private
    FListaBotoes: TStringList;
    FListaLabelsEdits: TStringList;
    procedure MakeDispItems;
  public
    FForm: TCustomForm;
    FUserControl: TFMXUserControl;
    FInitialObjs: TStringList;
  end;

var
  UCObjSel: TUCObjSel;

implementation

{$R *.fmx}

procedure TUCObjSel.btCancelaClick(Sender: TObject);
begin
  Close;
end;

procedure TUCObjSel.BtOKClick(Sender: TObject);
var
  Contador: Integer;
begin
  if FUserControl.ExtraRights.Count > 0 then
  begin
    Contador := 0;
    while Contador <= Pred(FUserControl.ExtraRights.Count) do
      if UpperCase(FUserControl.ExtraRights[Contador].Formulario) = UpperCase(FForm.Name) then
        FUserControl.ExtraRights.Delete(Contador)
      else
        Inc(Contador);
  end;

  for Contador := 1 to Pred(ListaCompsSelecionados.RowCount) do
    with FUserControl.ExtraRights.Add do
    begin
      Caption := ListaCompsSelecionados.Cells[0, Contador];
      Componente := ListaCompsSelecionados.Cells[1, Contador];
      Formulario := FForm.Name;
      GroupName := lbgrupo_valor.Text;
    end;
  Close;
end;

procedure TUCObjSel.btselClick(Sender: TObject);
var
  Contador: Integer;
begin
  for Contador := 1 to Pred(ListaCompsDisponiveis.RowCount) do
    if ListaCompsDisponiveis.RowSelect[Contador] then
    begin
      FInitialObjs.Add(ListaCompsDisponiveis.Cells[1, Contador]);

      ListaCompsSelecionados.RowCount := ListaCompsSelecionados.RowCount + 1;
      ListaCompsSelecionados.Cells[0, ListaCompsSelecionados.RowCount - 1] := ListaCompsDisponiveis.Cells[0, Contador];
      ListaCompsSelecionados.Cells[1, ListaCompsSelecionados.RowCount - 1] := ListaCompsDisponiveis.Cells[1, Contador];
      ListaCompsSelecionados.Cells[2, ListaCompsSelecionados.RowCount - 1] := ListaCompsDisponiveis.Cells[2, Contador];

    end;

  Contador := 0;
  while Contador <= Pred(ListaCompsDisponiveis.RowCount) do
    if ListaCompsDisponiveis.RowSelect[Contador] then
      ListaCompsDisponiveis.DeleteRow(Contador)
    else
      Inc(Contador);
end;

procedure TUCObjSel.btsellallClick(Sender: TObject);
var
  Contador: Integer;
begin
  ListaCompsSelecionados.RowCount := 1;
  for Contador := 1 to Pred(ListaCompsDisponiveis.RowCount) do
  begin
    FInitialObjs.Add(ListaCompsDisponiveis.Cells[1, Contador]);
    ListaCompsSelecionados.RowCount := ListaCompsSelecionados.RowCount + 1;
    ListaCompsSelecionados.Cells[0, ListaCompsSelecionados.RowCount - 1] := ListaCompsDisponiveis.Cells[0, Contador];
    ListaCompsSelecionados.Cells[1, ListaCompsSelecionados.RowCount - 1] := ListaCompsDisponiveis.Cells[1, Contador];
    ListaCompsSelecionados.Cells[2, ListaCompsSelecionados.RowCount - 1] := ListaCompsDisponiveis.Cells[2, Contador];
  end;
  ListaCompsDisponiveis.RowCount := 1;
end;

procedure TUCObjSel.btunselallClick(Sender: TObject);

begin
  ListaCompsSelecionados.RowCount := 1;
  FInitialObjs.Clear;
  MakeDispItems;

end;

procedure TUCObjSel.btunselClick(Sender: TObject);
var
  Contador: Integer;
  Componente: TComponent;
  idx: Integer;
begin
  for Contador := 1 to Pred(ListaCompsSelecionados.RowCount) do
    if ListaCompsSelecionados.RowSelect[Contador] then
    begin
      idx := FInitialObjs.IndexOf(ListaCompsSelecionados.Cells[1, Contador]);
      if idx > 0 then
        FInitialObjs.Delete(idx);
      Componente := FForm.FindComponent(ListaCompsSelecionados.Cells[1, Contador]);
      ListaCompsDisponiveis.RowCount := ListaCompsDisponiveis.RowCount + 1;
      ListaCompsDisponiveis.Cells[1, ListaCompsDisponiveis.RowCount - 1] := ListaCompsSelecionados.Cells[1, Contador];
      ListaCompsDisponiveis.Cells[2, ListaCompsDisponiveis.RowCount - 1] := ListaCompsSelecionados.Cells[2, Contador];
      if Componente is TMenuItem then
        ListaCompsDisponiveis.Cells[0, ListaCompsDisponiveis.RowCount - 1] := StringReplace(TMenuItem(Componente).Text, '&', '', [rfReplaceAll])
      else if Componente is TCustomAction then
        ListaCompsDisponiveis.Cells[0, ListaCompsDisponiveis.RowCount - 1] := StringReplace(TCustomAction(Componente).Text, '&', '', [rfReplaceAll])
      else if Componente is TField then
        ListaCompsDisponiveis.Cells[0, ListaCompsDisponiveis.RowCount - 1] := TField(Componente).DisplayName
      else if Componente is TCustomButton then
        ListaCompsDisponiveis.Cells[0, ListaCompsDisponiveis.RowCount - 1] := StringReplace(TCustomButton(Componente).Text, '&', '', [rfReplaceAll])
      else if Componente is TCustomEdit then
        ListaCompsDisponiveis.Cells[0, ListaCompsDisponiveis.RowCount - 1] := StringReplace(TCustomEdit(Componente).Text, '&', '', [rfReplaceAll])
      else if Componente is TLabel then
        ListaCompsDisponiveis.Cells[0, ListaCompsDisponiveis.RowCount - 1] := StringReplace(TLabel(Componente).Text, '&', '', [rfReplaceAll])
      else if Componente is TCheckBox then
        ListaCompsDisponiveis.Cells[0, ListaCompsDisponiveis.RowCount - 1] := StringReplace(TCheckBox(Componente).Text, '&', '', [rfReplaceAll])
     // else
      //  ListaCompsDisponiveis.Cells[0, ListaCompsDisponiveis.RowCount - 1] := StringReplace(Componente.Name, '&', '', [rfReplaceAll]);
    end;

  Contador := 1;
  while Contador <= Pred(ListaCompsSelecionados.RowCount) do
    if ListaCompsSelecionados.RowSelect[Contador] then
      ListaCompsSelecionados.DeleteRow(Contador)
    else
      Inc(Contador);
end;

procedure TUCObjSel.cbFilterClick(Sender: TObject);
begin
  MakeDispItems;
end;

procedure TUCObjSel.cbFilterClosePopup(Sender: TObject);
begin
  MakeDispItems;
end;

procedure TUCObjSel.cbFilterKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  MakeDispItems;
end;

procedure TUCObjSel.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TUCObjSel.FormCreate(Sender: TObject);
begin
  cbFilter.ItemIndex := 0;
  FListaBotoes := TStringList.Create;
  FListaBotoes.CommaText := 'TButton,TSpeedButton,TBitBtn,TRxSpeedButton,' + 'TRxSpinButton,TRxSwitch,TLMDButton,TLMDMMButton,TLMDShapeButton,' +
    'TLMD3DEffectButton,TLMDWndButtonShape,TJvHTButton,TJvBitBtn,TJvImgBtn,' + 'TJvArrowButton,TJvTransparenftButton,TJvTransparentButton2,TJvSpeedButton';
  FListaBotoes.Text := UpperCase(FListaBotoes.Text);
  FListaLabelsEdits := TStringList.Create;
  FListaLabelsEdits.CommaText := 'TEdit,TLabel,TStaticText,TLabeledEdit,' + 'TRxLabel,TComboEdit,TFileNamefEdit,TDirectoryEdit,TDateEdit,' +
    'TDateTimePicker,TRxCalcEdit,TCurrencyEdit,TRxSpinEdit';
  FListaLabelsEdits.Text := UpperCase(FListaLabelsEdits.Text);

  ListaCompsDisponiveis.Cells[0, 0] := 'Descripcion';
  ListaCompsDisponiveis.Cells[1, 0] := 'Nombre';
  ListaCompsDisponiveis.Cells[2, 0] := 'Clase';
  ListaCompsSelecionados.Cells[0, 0] := 'Descripcion';
  ListaCompsSelecionados.Cells[1, 0] := 'Nombre';
  ListaCompsSelecionados.Cells[2, 0] := 'Clase';
end;

procedure TUCObjSel.FormShow(Sender: TObject);
var
  Contador: Integer;
  Componente: TComponent;
begin
  lbform.Text := FForm.Name;
  FInitialObjs.Text := UpperCase(FInitialObjs.Text);
  ListaCompsSelecionados.RowCount := 1;
  MakeDispItems;
  /// /Tirei do onActivate, By Cleilson Sousa.

  for Contador := 0 to FUserControl.ExtraRights.Count - 1 do
    if UpperCase(FUserControl.ExtraRights[Contador].Formulario) = UpperCase(FForm.Name) then
    begin
      Componente := FForm.FindComponent(FUserControl.ExtraRights[Contador].Componente);
      if Componente <> nil then
      begin
        ListaCompsSelecionados.RowCount := ListaCompsSelecionados.RowCount + 1;
        ListaCompsSelecionados.Cells[0, ListaCompsSelecionados.RowCount - 1] := FUserControl.ExtraRights[Contador].Caption;
        ListaCompsSelecionados.Cells[1, ListaCompsSelecionados.RowCount - 1] := FUserControl.ExtraRights[Contador].Componente;
        ListaCompsSelecionados.Cells[2, ListaCompsSelecionados.RowCount - 1] := Componente.ClassName;
      end;
    end;
  lbtitle.Text := RetornaLingua(FUserControl.Language, 'Const_Contr_TitleLabel');
  lbgrupo_title.Text := RetornaLingua(FUserControl.Language, 'Const_Contr_GroupLabel');
  lbCompDisp.Text := RetornaLingua(FUserControl.Language, 'Const_Contr_CompDispLabel');
  lbCompSel.Text := RetornaLingua(FUserControl.Language, 'Const_Contr_CompSelLabel');
  ListaCompsSelecionados.Cells[0, 0] := RetornaLingua(FUserControl.Language, 'Const_Contr_DescCol');
  btCancela.Text := RetornaLingua(FUserControl.Language, 'Const_Contr_BTCancel');
  BtOK.Text := RetornaLingua(FUserControl.Language, 'Const_Inc_BtGravar');

  // Lines Bellow added by fduenas
  btsellall.Hint := RetornaLingua(FUserControl.Language, 'Const_Contr_BtSellAllHint');
  btsel.Hint := RetornaLingua(FUserControl.Language, 'Const_Contr_BtSelHint');
  btunsel.Hint := RetornaLingua(FUserControl.Language, 'Const_Contr_BtUnSelHint');
  btunselall.Hint := RetornaLingua(FUserControl.Language, 'Const_Contr_BtUnSelAllHint');
end;

procedure TUCObjSel.MakeDispItems;
var
  Componente: TComponent;
  Contador: Integer;

  procedure AddToGrid;
  begin
    ListaCompsDisponiveis.RowCount := ListaCompsDisponiveis.RowCount + 1;
    ListaCompsDisponiveis.Cells[1, ListaCompsDisponiveis.RowCount - 1] := Componente.Name;
    ListaCompsDisponiveis.Cells[2, ListaCompsDisponiveis.RowCount - 1] := Componente.ClassName;
    if Componente is TMenuItem then
      ListaCompsDisponiveis.Cells[0, ListaCompsDisponiveis.RowCount - 1] := StringReplace(TMenuItem(Componente).Text, '&', '', [rfReplaceAll])
    else if Componente is TCustomAction then
      ListaCompsDisponiveis.Cells[0, ListaCompsDisponiveis.RowCount - 1] := StringReplace(TCustomAction(Componente).Text, '&', '', [rfReplaceAll])
    else if Componente is TField then
      ListaCompsDisponiveis.Cells[0, ListaCompsDisponiveis.RowCount - 1] := TField(Componente).DisplayName
    else if Componente is TCustomButton then
      ListaCompsDisponiveis.Cells[0, ListaCompsDisponiveis.RowCount - 1] := StringReplace(TCustomButton(Componente).Text, '&', '', [rfReplaceAll])
    else if Componente is TCustomEdit then
      ListaCompsDisponiveis.Cells[0, ListaCompsDisponiveis.RowCount - 1] := StringReplace(TCustomEdit(Componente).Text, '&', '', [rfReplaceAll])
    else if Componente is TLabel then
      ListaCompsDisponiveis.Cells[0, ListaCompsDisponiveis.RowCount - 1] := StringReplace(TLabel(Componente).Text, '&', '', [rfReplaceAll])
    else if Componente is TCheckBox then
      ListaCompsDisponiveis.Cells[0, ListaCompsDisponiveis.RowCount - 1] := StringReplace(TCheckBox(Componente).Text, '&', '', [rfReplaceAll])
   // else
   //   ListaCompsDisponiveis.Cells[0, ListaCompsDisponiveis.RowCount - 1] := StringReplace(Componente.Name, '&', '', [rfReplaceAll]);

  end;

begin
  {
    All       0
    Buttons   1
    Fields    2
    Edits     3
    Labels    4
    MenuItems 5
    Actions   6
  }
  ListaCompsDisponiveis.RowCount := 1;
  for Contador := 1 to FForm.ComponentCount - 1 do
  begin
    Componente := FForm.Components[Contador];
    if FInitialObjs.IndexOf(UpperCase(Componente.Name)) = -1 then
    begin
      case cbFilter.ItemIndex of
        0:
          begin
            if (Componente is TCheckBox) or (Componente is TCustomButton) or (Componente is TMenuItem) or (Componente is TCustomAction) or (Componente is TLabel) or
              (Componente is TCustomEdit) or (Componente is TTMSFMXBaseControl) then
              AddToGrid;
          end;
        1:
          begin
            if Componente is TCustomButton then
              AddToGrid;
          end;

        2:
          begin
            if Componente is TField then
              AddToGrid;

          end;
        3:
          begin
            if Componente is TCustomEdit then
              AddToGrid;
          end;
        4:
          begin
            if Componente is TLabel then
              AddToGrid;
          end;
        5:
          begin
            if Componente is TMenuItem then
              AddToGrid;
          end;
        6:
          begin
            if Componente is TCustomAction then
              AddToGrid;
          end;
        7:
          begin
            if Componente is TTMSFMXBaseControl then
              AddToGrid;
          end;
      end;
    end;
  end;
end;

end.
