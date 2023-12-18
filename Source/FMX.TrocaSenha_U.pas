unit FMX.TrocaSenha_U;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.UCBase,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.StdCtrls, System.ImageList, FMX.ImgList, FMX.Edit,
  FMX.Controls.Presentation, FMX.Layouts, FMX.TMSTaskDialog;

type
  TTrocaSenha = class(TForm)
    GridPanelLayout1: TGridPanelLayout;
    lbPassNuevo: TLabel;
    lbPassActual: TLabel;
    lbConfirma: TLabel;
    EditPassConfirma: TEdit;
    EditPassNuevo: TEdit;
    GridPanelLayout3: TGridPanelLayout;
    btOK: TButton;
    BtCancela: TButton;
    ImageList1: TImageList;
    StyleBook1: TStyleBook;
    EditPassActual: TEdit;
    Panel1: TPanel;
    lbDescripcion: TLabel;
    Image1: TImage;
    TaskDialog: TTMSFMXTaskDialog;
    procedure BtCancelaClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    fUsercontrol: TFMXUserControl;
    ForcarTroca: Boolean;
  end;

var
  TrocaSenha: TTrocaSenha;

implementation

{$R *.fmx}

procedure TTrocaSenha.BtCancelaClick(Sender: TObject);
begin
  Close;
end;

procedure TTrocaSenha.FormActivate(Sender: TObject);
begin
  // EditAtu.CharCase      := Self.FUserControl.Login.CharCasePass;
  // EditNova.CharCase     := Self.FUserControl.Login.CharCasePass;
  // EditConfirma.CharCase := Self.FUserControl.Login.CharCasePass; { Por Vicente Barros Leonel }
end;

procedure TTrocaSenha.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TTrocaSenha.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  If ForcarTroca = True then
  Begin
    CanClose := False;
    TaskDialog.Title := 'Advetencia';
    TaskDialog.Content := fUsercontrol.UserSettings.CommonMessages.ForcaTrocaSenha;
    TaskDialog.commonButtons := [TFMXCommonButton.OK];
    TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 2);
    TaskDialog.Show;
  End;
end;

procedure TTrocaSenha.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  Begin
    Key := 0;
    Self.ModalResult := mrOk;
    // Perform(WM_NEXTDLGCTL,0,0);
  End;
end;

end.
