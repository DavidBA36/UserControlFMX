unit uSelectorColumnas;

interface

uses
  System.SysUtils, System.Types, FMX.TMSLiveGrid, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TMSBaseControl, FMX.TMSBaseGroup, FMX.TMSCheckGroup, FMX.StdCtrls, FMX.Controls.Presentation;

type
  TFSelectorColumas = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    TMSFMXCheckGroup1: TTMSFMXCheckGroup;

    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
  private
    Grid: TTMSFMXLiveGrid;
  public
    constructor CreateWithGrid(AOwner: TComponent; aGrid: TTMSFMXLiveGrid);
  end;

var
  FSelectorColumas: TFSelectorColumas;

implementation

{$R *.fmx}

procedure TFSelectorColumas.Button1Click(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to TMSFMXCheckGroup1.Items.Count - 1 do
  begin
    if not TMSFMXCheckGroup1.IsChecked[i] then
      Grid.HideColumn(i)
    else
      Grid.UnHideColumn(i);
  end;
  CloseModal;
end;

procedure TFSelectorColumas.Button2Click(Sender: TObject);
begin
  CloseModal;
end;

Constructor TFSelectorColumas.CreateWithGrid(AOwner: TComponent; aGrid: TTMSFMXLiveGrid);
var
  i: Integer;
begin
  inherited Create(AOwner);
  Grid := aGrid;
  for i := 0 to aGrid.Columns.Count - 1 do
  begin
    TMSFMXCheckGroup1.Items.Add;
    TMSFMXCheckGroup1.Items[i].Text := Grid.Columns.Items[i].Name;
    TMSFMXCheckGroup1.IsChecked[i] := not Grid.IsHiddenColumn(i);
  end;

end;

procedure TFSelectorColumas.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TFSelectorColumas.FormDestroy(Sender: TObject);
begin
  FSelectorColumas := nil;
end;

end.
