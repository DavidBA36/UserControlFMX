{ -----------------------------------------------------------------------------
  Unit Name: UCMail
  Author:    QmD
  Date:      09-nov-2004
  Purpose: Send Mail messages (forget password, user add/change/password force/etc)
  History: included indy 10 support
  ----------------------------------------------------------------------------- }

unit FMX.UCMail;

interface

{ .$I 'UserControl.inc' }
{$DEFINE DEPURACION}

uses
  System.Classes, System.UITypes, System.SysUtils, FireDac.Stan.Param, FMX.StdCtrls, FMX.Dialogs, FMX.UcConsts_Language, IdSMTPBase, IdSMTP,
  IdMessage, IdSSL, IdSSLOpenSSL,
  IdGlobal, FMX.TMSTaskDialog,
  IdExplicitTLSClientServerBase, IdText, IdAttachmentFile, FMX.UCMessages, FireDac.Comp.Client, FireDac.Stan.Option, FMX.UCSettings;

type
  TUCMailStrings = class(TPersistent)
  private
    FEmailFallido: String;
    FMailEnviado: String;
    FMensageAuthFallido: string;
  protected
  public
  published
    property MensageAuthFallido: String read FMensageAuthFallido write FMensageAuthFallido;
    property MensageEmailFallido: String read FEmailFallido write FEmailFallido;
    property MensageEmailEnviado: String read FMailEnviado write FMailEnviado;
  end;

  TMessageTag = procedure(Tag: String; var ReplaceText: String) of object;

  TTipoContenido = (tcHTML, tcText, tcAdjunto);

  TTiposMensage = (tmPassOlvidado, tmPassForzado, tmPassCambiado, tmUserCambiado, tmUserAgregado);

  TTiposContenido = set of TTipoContenido;

  TFMXMailUserControl = class(TComponent)
  private
    fSMTPTimeout: Integer;
    fLanguage: TUCLanguage;
    FUserSettings: TUCUserSettings;
    FMailStrings: TUCMailStrings;
    TaskDialog: TTMSFMXTaskDialog;
    procedure onStatus(Status: String);
    function ParseMailMSG(Nome, Login, Senha, Email, Cargo, Empresa, txt: String): String;
    procedure SetfLanguage(const Value: TUCLanguage);
    procedure SetUserSettings(const Value: TUCUserSettings);
  protected
    function EnviaEmailTp(ClaveUsuario: Integer; USenha: string; TipoMensage: TTiposMensage): Boolean;
  public
    fUsercontrol: TComponent;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure EnviaEmailAdicionaUsuario(Nome, Login, Senha, Email: String; Key: Word);
    procedure EnviaEmailAlteraUsuario(Nome, Login, Senha, Email: String; Key: Word);
    procedure EnviaEmailSenhaForcada(Clave: Integer; Senha: String);
    procedure EnviaEmailSenhaTrocada(Clave: Integer; Senha: String);
    procedure EnviaPassOlvidado(Clave: Integer);
  published
    property SMTPTimeout: Integer read fSMTPTimeout write fSMTPTimeout default 1000;
    property Language: TUCLanguage read fLanguage write SetfLanguage;
    property UserSettings: TUCUserSettings read FUserSettings write SetUserSettings;
    property MailStrings: TUCMailStrings read FMailStrings write FMailStrings;
  end;

implementation

uses
  FMX.ucBase,
  FMX.UCEMailForm_U;

function GeneraPass(Digitos: Integer; Min: Boolean; Mai: Boolean; Num: Boolean): string;
const
  MinC = 'abcdef';
  MaiC = 'ABCDEF';
  NumC = '1234567890';
var
  p, q: Integer;
  Char, Senha: String;
begin
  Char := '';
  If Min then
    Char := Char + MinC;
  If Mai then
    Char := Char + MaiC;
  If Num then
    Char := Char + NumC;
  for p := 1 to Digitos do
  begin
    Randomize;
    q := Random(Length(Char)) + 1;
    Senha := Senha + Char[q];
  end;
  Result := Senha;
end;

{ TFMXMailUserControl }

procedure TFMXMailUserControl.SetfLanguage(const Value: TUCLanguage);
begin
  fLanguage := Value;
  Self.UserSettings.Language := Value;
  FMX.UCSettings.AlterLanguage(Self.UserSettings);
  if Assigned(MailStrings) then
  begin
    MailStrings.MensageEmailFallido := RetornaLingua(fLanguage, 'Const_Log_LbEsqueciSenha');
    MailStrings.MensageEmailEnviado := RetornaLingua(fLanguage, 'Const_Log_MsgMailSend');
    MailStrings.MensageAuthFallido := RetornaLingua(fLanguage, 'Const_Log_MsgMailSend');
  end;
end;

procedure TFMXMailUserControl.SetUserSettings(const Value: TUCUserSettings);
begin
  UserSettings := Value;
end;

constructor TFMXMailUserControl.Create(AOwner: TComponent);
begin
  inherited;
  FUserSettings := TUCUserSettings.Create(Self);
  fLanguage := ucSpanish;
  fSMTPTimeout := 1000;
  MailStrings := TUCMailStrings.Create;
  TaskDialog := TTMSFMXTaskDialog.Create(Self);
  if csDesigning in ComponentState then
  begin
    MailStrings.MensageEmailFallido := RetornaLingua(fLanguage, 'Const_Log_LbEsqueciSenha');
    MailStrings.MensageEmailEnviado := RetornaLingua(fLanguage, 'Const_Log_MsgMailSend');
    MailStrings.MensageAuthFallido := RetornaLingua(fLanguage, 'Const_Log_MsgMailSend');
  end;
end;

destructor TFMXMailUserControl.Destroy;
begin
  MailStrings.Free;
  FUserSettings.Free;
  TaskDialog.Free;
  inherited;
end;

procedure TFMXMailUserControl.EnviaEmailAdicionaUsuario(Nome, Login, Senha, Email: String; Key: Word);
begin
  // Senha := TrataSenha(Senha, Key, False, 0);
  // EnviaEmailTp(Nome, Login, Senha, Email, AgregoUsuario);
end;

procedure TFMXMailUserControl.EnviaEmailAlteraUsuario(Nome, Login, Senha, Email: String; Key: Word);
begin
  // Senha := TrataSenha(Senha, Key, False, 0);
  // EnviaEmailTp(Nome, Login, Senha, Email, ModificoUsuario);
end;

procedure TFMXMailUserControl.EnviaEmailSenhaForcada(Clave: Integer; Senha: String);
begin
  EnviaEmailTp(Clave, Senha, tmPassForzado);
end;

procedure TFMXMailUserControl.EnviaEmailSenhaTrocada(Clave: Integer; Senha: String);
begin
  EnviaEmailTp(Clave, Senha, tmPassCambiado);
end;

function TFMXMailUserControl.ParseMailMSG(Nome, Login, Senha, Email, Cargo, Empresa, txt: String): String;
begin
  txt := StringReplace(txt, ':nombre', Nome, [rfReplaceAll]);
  txt := StringReplace(txt, ':login', Login, [rfReplaceAll]);
  txt := StringReplace(txt, ':password', Senha, [rfReplaceAll]);
  txt := StringReplace(txt, ':email', Email, [rfReplaceAll]);
  txt := StringReplace(txt, ':empresa', Empresa, [rfReplaceAll]);
  if TFMXUserControl(fUsercontrol).CurrentUser.EsMaster then
    txt := StringReplace(txt, ':cargo', 'master principal', [rfReplaceAll])
  else
    txt := StringReplace(txt, ':cargo', Cargo, [rfReplaceAll]);
  txt := StringReplace(txt, ':user', TFMXUserControl(fUsercontrol).CurrentUser.UserName, [rfReplaceAll]);
  Result := txt;
end;

procedure TFMXMailUserControl.onStatus(Status: String);
begin
  if not Assigned(UCEMailForm) then
    Exit;
  UCEMailForm.lbStatus.Text := Status;
  // UCEMailForm.Update;
end;

Function TFMXMailUserControl.EnviaEmailTp(ClaveUsuario: Integer; USenha: string; TipoMensage: TTiposMensage): Boolean;
var
  Correo: TIdSMTP;
  MailMessage: TIdMessage;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
  q: TFDQuery;
  Cuerpo: String;
begin
  Result := False;
  q := TFDQuery.Create(nil);
  SSL := TIdSSLIOHandlerSocketOpenSSL.Create(Self);
  Correo := TIdSMTP.Create(Self);
  UCEMailForm := TUCEMailForm.Create(Self);
  MailMessage := TIdMessage.Create(Self);
  try
    try
      with q do
      begin
        Connection := TFMXUserControl(fUsercontrol).Connection;
        SQL.Text := 'SELECT A.* FROM INT$UC_EMAIL A';
        Open;
        if FieldByName('ACTIVO').AsString = 'F' then
          Exit;
        Correo.IOHandler := nil;
        Correo.UseTLS := TIdUseTLS.utNoTLSSupport;
        if FieldByName('USA_STARTTLS').AsString = 'T' then
        begin
          SSL.Host := FieldByName('SERVIDOR').AsString;
          SSL.Port := FieldByName('PUERTO').AsInteger;
          SSL.ReuseSocket := rsTrue;
          SSL.SSLOptions.Method := sslvSSLv23;
          SSL.SSLOptions.Mode := sslmClient;
          SSL.Destination := FieldByName('SERVIDOR').AsString + ':' + FieldByName('PUERTO').AsString;
          Correo.IOHandler := SSL;
          Correo.UseTLS := TIdUseTLS.utUseExplicitTLS;
        end;
        Correo.AuthType := satDefault;

        UCEMailForm.lbStatus.Text := '';
        UCEMailForm.Show;
        // UCEMailForm.Update;

        Correo.Host := FieldByName('SERVIDOR').AsString;
        Correo.Port := FieldByName('PUERTO').AsInteger;
        Correo.UserName := FieldByName('USER_LOGIN').AsString;
        Correo.Password := FieldByName('PASS').AsString;

        MailMessage.From.Address := FieldByName('REMITENTE').AsString;

        case TipoMensage of
          tmPassOlvidado:
            begin
              MailMessage.Subject := FieldByName('PASS_OLVIDADO_ASUNTO').AsString;
              Cuerpo := FieldByName('PASS_OLVIDADO_BODY').AsString;
            end;
          tmPassForzado:
            begin
              MailMessage.Subject := FieldByName('PASS_FORZADO_ASUNTO').AsString;
              Cuerpo := FieldByName('PASS_FORZADO_BODY').AsString;
            end;
          tmPassCambiado:
            begin
              MailMessage.Subject := FieldByName('PASS_CAMBIADO_ASUNTO').AsString;
              Cuerpo := FieldByName('PASS_CAMBIADO_BODY').AsString;
            end;
          tmUserCambiado:
            begin
              MailMessage.Subject := FieldByName('USER_CAMBIADO_ASUNTO').AsString;
              Cuerpo := FieldByName('USER_CAMBIADO_BODY').AsString;
            end;
          tmUserAgregado:
            begin
              MailMessage.Subject := FieldByName('USER_AGREGADO_ASUNTO').AsString;
              Cuerpo := FieldByName('USER_AGREGADO_BODY').AsString;
            end;
        end;
        Close;
        SQL.Clear;
        SQL.Add('SELECT A.*,I.NOMBRE AS EMPRESA ');
        SQL.Add('FROM INT$UC_USERS A ');
        SQL.Add('LEFT OUTER JOIN INT$ENTIDAD I ON I.CLAVE=A.CLAVE_EMPRESA ');
        SQL.Add('WHERE A.CLAVE=:PCLAVE');
        ParamByName('PCLAVE').AsInteger := ClaveUsuario;
        Open;

        MailMessage.Recipients.EMailAddresses := FieldByName('UCEMAIL').AsString;
        with TIdText.Create(MailMessage.MessageParts, nil) do
        begin
          Body.Text := ParseMailMSG(FieldByName('UCUSERNAME').AsString, FieldByName('UCLOGIN').AsString, USenha, FieldByName('UCEMAIL').AsString, '',
            FieldByName('EMPRESA').AsString, Cuerpo);
          ContentType := 'text/html';
        end;
        Correo.ConnectTimeout := fSMTPTimeout;
        Correo.Connect;
        if Correo.Authenticate then
        begin
          Correo.Send(MailMessage);
          Result := True;
        end
        else
          TFMXUserControl(fUsercontrol).Log(MailStrings.MensageAuthFallido, 3);
      end;
      // UCEMailForm.Update;
    except
      on e: Exception do
      begin
        if Correo.Connected then
          Correo.Disconnect;
        UCEMailForm.Close;
        TFMXUserControl(fUsercontrol).Log(e.Message, 3);
{$IFDEF DEPURACION}
        TFMXUserControl(fUsercontrol).SendDebug('TFMXUserControl.ActionLogoff exception ', e.Message);
{$ENDIF}
      end;
    end;
  finally
    if Correo.Connected then
      Correo.Disconnect;
    FreeAndNil(UCEMailForm);
    Correo.Free;
    MailMessage.Free;
    SSL.Free;
    q.Free;
  end;
end;

procedure TFMXMailUserControl.EnviaPassOlvidado(Clave: Integer);
Var
  Pass: String;
  FDTrans: TFDTransaction;
  q: TFDQuery;
begin
  FDTrans := TFDTransaction.Create(nil);
  q := TFDQuery.Create(nil);
  try
    try
      with FDTrans do
      begin
        Connection := TFMXUserControl(fUsercontrol).Connection;
        Options.AutoStart := False;
        Options.AutoCommit := False;
        Options.AutoStop := False;
        Options.DisconnectAction := xdRollback;
      end;
      with q do
      begin
        Connection := TFMXUserControl(fUsercontrol).Connection;
        SQL.Add('SELECT * ');
        SQL.Add('FROM INT$UC_USERS ');
        SQL.Add('WHERE CLAVE=:PCLAVE');
        ParamByName('PCLAVE').AsInteger := Clave;
        Open;
        if FieldByName('UCEMAIL').AsString = '' then
          Exit;

        Pass := GeneraPass(20, True, True, True);
        If EnviaEmailTp(Clave, Pass, tmPassOlvidado) = True then
        Begin
          TFMXUserControl(fUsercontrol).ChangePassword(FDTrans, Clave, Pass);
          TaskDialog.Title := 'Aviso';
          TaskDialog.InstructionText := 'instruccion';
          TaskDialog.Content := MailStrings.MensageEmailEnviado;
          TaskDialog.commonButtons := [TFMXCommonButton.OK];
          TaskDialog.Show();

          if FDTrans.Active then
            FDTrans.Commit;
        end
        else
        begin
          TaskDialog.Title := 'Aviso';
          TaskDialog.InstructionText := 'instruccion';
          TaskDialog.Content := MailStrings.MensageEmailFallido;
          TaskDialog.commonButtons := [TFMXCommonButton.OK];
          TaskDialog.Show();
        end;

      end;
    except
      On e: Exception do
      begin
        if FDTrans.Active then
          FDTrans.Rollback;
      end;
    end;
  finally
    FDTrans.Free;
    q.Free;
  end;
end;

end.
