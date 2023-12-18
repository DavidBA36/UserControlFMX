unit FMX.UcSenhaForm_U;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.UcBase, System.Math,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.StdCtrls, System.ImageList, FMX.ImgList, FMX.Edit,
  FMX.Controls.Presentation, FMX.Layouts, FMX.TMSTaskDialog;

type
  TFMXUcSenhaForm = class(TForm)
    GridPanelLayout1: TGridPanelLayout;
    LabelSenha: TLabel;
    LabelConfirma: TLabel;
    edtConfirmaSenha: TEdit;
    edtSenha: TEdit;
    GridPanelLayout3: TGridPanelLayout;
    btnOK: TButton;
    BtCancel: TButton;
    ImageList1: TImageList;
    Panel1: TPanel;
    lbDescripcion: TLabel;
    Image1: TImage;
    StyleBook1: TStyleBook;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Button1: TButton;
    TaskDialog: TTMSFMXTaskDialog;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    function CompararSenhas(Senha, ConfirmaSenha: String): Boolean;
  public
    fFMXUserControl: TFMXUserControl;
  end;

var
  FMXUcSenhaForm: TFMXUcSenhaForm;

implementation

{$R *.fmx}

uses FMX.UCHelpers;

procedure TFMXUcSenhaForm.Button1Click(Sender: TObject);
begin
  edtSenha.Text := GeneratePass(8, RandomRange(1, 3));
  edtConfirmaSenha.Text := edtSenha.Text;
  TaskDialog.Title := 'Informacion';
  TaskDialog.Content := 'Se ha generado una contraseña aleatoria, Tómese un tiempo para anotarla y asi poder iniciar sesión.';
  TaskDialog.commonButtons := [TFMXCommonButton.OK];
  TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 2);
  TaskDialog.Show;
end;

function TFMXUcSenhaForm.CompararSenhas(Senha, ConfirmaSenha: String): Boolean;
begin
  Result := False;
  With fFMXUserControl do
  begin
    TaskDialog.Title := 'Advertencia';
    TaskDialog.Bitmap := ImageList1.Bitmap(TSizeF.Create(32, 32), 3);
    TaskDialog.commonButtons := [TFMXCommonButton.OK];
    if (Senha = '') or (ConfirmaSenha = '') then
    begin
      TaskDialog.Content := 'No se admiten contraseñas en blanco';
      TaskDialog.Show;
    end
    else if (UserPasswordChange.ForcePassword) and (Senha = '') then
    begin
      TaskDialog.Content := UserSettings.CommonMessages.ChangePasswordError.PasswordRequired;
      TaskDialog.Show;
    end
    else if Length(Senha) < UserPasswordChange.MinPasswordLength then
    begin
      TaskDialog.Content := Format(UserSettings.CommonMessages.ChangePasswordError.MinPasswordLength, [UserPasswordChange.MinPasswordLength]);
      TaskDialog.Show;
    end
    else if Pos(LowerCase(Senha), 'abcdeasdfqwerzxcv1234567890321654987teste' + LowerCase(CurrentUser.UserName) + LowerCase(CurrentUser.UserLogin)) > 0
    then
    begin
      TaskDialog.Content := UserSettings.CommonMessages.ChangePasswordError.InvalidNewPassword;
      TaskDialog.Show;
    end
    else if (Senha <> ConfirmaSenha) then
    begin
      TaskDialog.Content := UserSettings.CommonMessages.ChangePasswordError.NewPasswordError;
      TaskDialog.Show;
    end
    else
      Result := True;
  end;
end;

procedure TFMXUcSenhaForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if not(ModalResult = mrCancel) then
  begin
    CanClose := CompararSenhas(edtSenha.Text, edtConfirmaSenha.Text);
    if not CanClose then
      edtSenha.SetFocus;
  end;
end;

procedure TFMXUcSenhaForm.FormCreate(Sender: TObject);
begin
  edtSenha.Text := '';
  edtConfirmaSenha.Text := '';
end;

procedure TFMXUcSenhaForm.FormShow(Sender: TObject);
begin
  // edtSenha.CharCase := fUserControl.Login.CharCasePass;
  // edtConfirmaSenha.CharCase := fUserControl.Login.CharCasePass;
  LabelSenha.Text := fFMXUserControl.UserSettings.Login.LabelPassword;
  LabelConfirma.Text := fFMXUserControl.UserSettings.ChangePassword.LabelConfirm;
  btnOK.Text := fFMXUserControl.UserSettings.Login.BtOk;
  BtCancel.Text := fFMXUserControl.UserSettings.Login.BtCancel;
end;

procedure TFMXUcSenhaForm.SpeedButton1Click(Sender: TObject);
begin
  Timer1.Enabled := True;
  edtSenha.Password := False;
end;

procedure TFMXUcSenhaForm.SpeedButton2Click(Sender: TObject);
begin
  Timer1.Enabled := True;
  edtConfirmaSenha.Password := False;
end;

procedure TFMXUcSenhaForm.Timer1Timer(Sender: TObject);
begin
  if not SpeedButton1.IsPressed then
  begin
    Timer1.Enabled := False;
    edtSenha.Password := True;
  end;
  if not SpeedButton2.IsPressed then
  begin
    Timer1.Enabled := False;
    edtConfirmaSenha.Password := True;
  end;
end;

end.
