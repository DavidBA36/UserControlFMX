unit FMX.uDialogoCopia;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls, FMX.Edit, FMX.Layouts, System.ImageList, FMX.ImgList, FMX.Objects,
  FMX.Controls.Presentation, FMX.TMSTaskDialog;

type
  TFMXUcDialogoCopia = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    LbDesc: TLabel;
    lbUser: TLabel;
    ImageList1: TImageList;
    StyleBook1: TStyleBook;
    Panel4: TPanel;
    Button3: TButton;
    btnAceptar: TButton;
    GridPanelLayout1: TGridPanelLayout;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    edtNombre: TEdit;
    edtAlias: TEdit;
    edtPass: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    ckbCopiaPer: TCheckBox;
    ckbCopiaMiem: TCheckBox;
    ckbCopiaWin: TCheckBox;
    ckbManPass: TCheckBox;
    TaskDialog: TTMSFMXTaskDialog;
    procedure ckbManPassChange(Sender: TObject);
    procedure edtNombreChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnAceptarClick(Sender: TObject);
  private
    { Private declarations }
  public
    ModoDialogo: integer;
  end;

var
  FMXUcDialogoCopia: TFMXUcDialogoCopia;

implementation

{$R *.fmx}

procedure TFMXUcDialogoCopia.btnAceptarClick(Sender: TObject);
begin
  if edtNombre.Text = '' then
  begin
    TaskDialog.Title := 'Error';
    TaskDialog.Content := 'Debe Introducir un nombre valido';
    TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 7);
    TaskDialog.Show();
  end;
end;

procedure TFMXUcDialogoCopia.ckbManPassChange(Sender: TObject);
begin
  edtPass.Enabled := not ckbManPass.isChecked;
end;

procedure TFMXUcDialogoCopia.edtNombreChange(Sender: TObject);
begin
  if (btnAceptar.ModalResult <> mrok) and (Length(edtNombre.Text) > 0) then
    btnAceptar.ModalResult := mrok
end;

procedure TFMXUcDialogoCopia.FormShow(Sender: TObject);
begin
  Label2.Visible := (ModoDialogo = 1);
  edtAlias.Visible := (ModoDialogo = 1);
  Label3.Visible := (ModoDialogo = 1);
  edtPass.Visible := (ModoDialogo = 1);
  ckbManPass.Visible := (ModoDialogo = 1);
  ckbCopiaWin.Visible := (ModoDialogo = 1);
end;

end.
