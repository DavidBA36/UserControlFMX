unit FMX.UCHelpers;

interface

uses system.UITypes, Data.DB, IdHashMessageDigest, system.SysUtils, system.Math, FMX.Forms, FMX.SpinBox, FMX.ListBox, FMX.Dialogs, FMX.Controls,
  FireDAC.Phys.FB, IdHash, IdCoderMIME, IdStack, idGlobal, FMX.TMSCustomGrid,
  FireDAC.Comp.UI, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FMX.StdCtrls, FireDAC.Phys.FBDef, FireDAC.Comp.ScriptCommands,
  FireDAC.Stan.Util, ShlObj, ComObj, ActiveX, FMX.TMSLiveGrid,
  FireDAC.Comp.Script, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, DCPrijndael, DCPbase64,
  FireDAC.Phys, system.Types, system.TypInfo, FireDAC.Comp.Client,
  Winapi.Windows, FMX.Menus, Data.DBCommon, system.Classes, Winapi.Messages,
  FMX.UcBase, system.Win.Registry,
  system.Variants;

type
  TItemArr = array of TMenuItem;

  PTokenUser = ^TTokenUser;

  TTokenUser = packed record
    User: TSidAndAttributes;
  end;

  TControlData = record
    Width: Single;
    Height: Single;
    Constructor Create(AWidth: Single; AHeight: Single);
  end;

const
  Codes64 = '0A1B2C3D4E5F6G7H89IjKlMnOPqRsTuVWXyZabcdefghijkLmNopQrStUvwxYz+/';
  C1 = 52845;
  C2 = 22719;
  HEAP_ZERO_MEMORY = $00000008;
  SID_REVISION = 1; // Current revision level

  // procedure SetGridColumnWidths(aDBGrid: TJvDBGrid);
  // procedure ReOrden(DBGridx: TJvDBGrid);
  // procedure GridTitleBtn(DBGridx: TJvDBGrid; ACol: Integer; VerC: boolean);
  // function CopyWordPos(Subs, Text: string): string;
  // procedure pintaCheck(DBCheckBoxx: TDBCheckBox; DBGridx: TJvDBGrid; const Rect: TRect);
  // procedure DBGridKeyDown(DBGridx: TJvDBGrid; var Key: Word; Shift: TShiftState);
function BoolToTF(B: boolean): String;
// procedure VerColG(VerC: boolean; DBGridx: TJvDBGrid);
function GetCurrentUserSid: string;
function AllItems(MainMenu: TMainMenu): TItemArr;
function GetKeyTUsuario(Clave: Integer; Login, Password: string; PassISCif: boolean = False): string;
function GetKeyTGrupo(Clave, ClaveEmpresa: Integer; Nombre: string): string;
function GetKeyTPermisos(Clave: Integer; Componente: string): string;
function GetKeyTUserGroup(ClaveUser, ClaveGroup: Integer): string;
function GetKeyTUserWin(Clave: Integer; SID, Login: string): string;
function GetKeyPassword(Pass: string): string;
function DateTimeToStrUs(dt: TDatetime): string;
function GetLocalComputerName: String;
function GetLocalUserName: String;
procedure CheckPermisos(Contenedor: TControl; FConn: TFDConnection; FDTran: TFDTransaction; UC: TFMXUserControl); overload;
procedure CheckPermisos(Contenedor: TForm; FConn: TFDConnection; FDTran: TFDTransaction; UC: TFMXUserControl); overload;
function CheckPermiso(ID: string; FConn: TFDConnection; FDTran: TFDTransaction; UC: TFMXUserControl): boolean;
function LogEvent(EventType, Category, EventID: Integer; Str: string): LongBool;
procedure SavePropertyOnReg(Key, Propiedad: String; Value: Variant);
function ReadPropertyFromReg(Key, Propiedad: String): Variant;
function Montar(S: string): string;
function Desmontar(S: string): string;
function Encode64(const S: string; const ByteEncoding: IIdTextEncoding = nil): string;
function Decode64(const S: string; const ByteEncoding: IIdTextEncoding = nil): string;
function CreateDesktopShellLink(const TargetName: string; Destination: String): boolean;
procedure SetArray(var A: array of Single; Value: Single);
procedure LoadGridPreferences(var GridColumnsWidth: array of Single; Grid: TTMSFMXCustomGrid; Root: string; Form: String);
procedure LoadControlPreferences(Control: TControl; Default: TControlData);
procedure SaveGridPreferences(Root: string; Form: String; Grid: TTMSFMXCustomGrid);
procedure SaveControlPreferences(Control: TControl);
function GeneratePass(iPassLength: Integer; iCompileType: Integer): string;

implementation

procedure SetArray(var A: array of Single; Value: Single);
var
  i: Integer;
begin
  for i := 0 to Length(A) - 1 do
    A[i] := Value;
end;

Constructor TControlData.Create(AWidth: Single; AHeight: Single);
begin
  Width := AWidth;
  Height := AHeight;
end;

function CreateDesktopShellLink(const TargetName: string; Destination: String): boolean;
var
  IObject: IUnknown;
  ISLink: IShellLink;
  IPFile: IPersistFile;
  PIDL: PItemIDList;
  LinkName: string;
  InFolder: array [0 .. MAX_PATH - 1] of Char;
begin
  Result := False;

  IObject := CreateComObject(CLSID_ShellLink);
  ISLink := IObject as IShellLink;
  IPFile := IObject as IPersistFile;

  with ISLink do
  begin
    SetDescription('Description ...');
    SetPath(PChar(TargetName));
    SetWorkingDirectory(PChar(ExtractFilePath(TargetName)));
  end;

  SHGetSpecialFolderLocation(0, CSIDL_DESKTOPDIRECTORY, PIDL);
  SHGetPathFromIDList(PIDL, InFolder);

  LinkName := IncludeTrailingPathDelimiter(Destination);
  LinkName := LinkName + ExtractFileName(TargetName) + '.lnk';

  if not FileExists(LinkName) then
    if IPFile.Save(PWideChar(LinkName), False) = S_OK then
      Result := True;
end;

function Montar(S: string): string;
const
  Churro: array [0 .. 15] of byte = ($20, $5A, $CB, $A5, $B6, $F4, $FD, $FE, $23, $04, $88, $99, $00, $8F, $4D, $1E);
var
  Buf: TBytes;
  Input: array [0 .. 15] of byte;
  Output: array [0 .. 15] of byte;
  Len, Nbytes, Resto, Lineas, i, j, k: Integer;
  Cif: TDCP_rijndael;
begin
  Cif := TDCP_rijndael.Create(nil);
  try
    Resto := 0;
    Buf := TEncoding.ANSI.GetBytes(S);
    Len := Length(Buf);
    if Len < Length(Input) then
      Lineas := 1
    else
    begin
      Lineas := Len div Length(Input);
      Resto := Len mod Length(Input);
      if Resto <> 0 then
        Inc(Lineas);
    end;

    if Len > 0 then
    begin
      k := 0;
      for i := 0 to Lineas - 1 do
      begin
        FillChar(Input, Length(Input), #0);
        if Lineas = 1 then
          Nbytes := Len
        else if (Resto <> 0) and (i = Lineas - 1) then
          Nbytes := Resto
        else
          Nbytes := Length(Input);
        for j := 0 to Nbytes - 1 do
          Input[j] := Buf[k + j];
        Inc(k, Nbytes);
        Cif.Init(Churro, Sizeof(Churro) * 8, nil);
        Cif.EncryptECB(Input, Output);
        Cif.Burn;
        for j := 0 to Length(Output) - 1 do
          Result := Result + IntToHex(Output[j], 2);
      end;
      // result := Encode64(result);
    end;
  finally
    Cif.Free;
  end;
end;

function Desmontar(S: string): string;
const
  Churro: array [0 .. 15] of byte = ($20, $5A, $CB, $A5, $B6, $F4, $FD, $FE, $23, $04, $88, $99, $00, $8F, $4D, $1E);
var
  OutputSBuf, Buf: TBytes;
  Input: array [0 .. 15] of byte;
  Output: array [0 .. 15] of byte;
  Len, Lineas, i, j, k: Integer;
  Cif: TDCP_rijndael;
begin
  Cif := TDCP_rijndael.Create(nil);
  try
    // S := Decode64(EncodedS);
    SetLength(Buf, Length(S) div 2);
    HexToBin(PChar(S), Buf[0], Length(Buf));
    Len := Length(Buf);
    SetLength(OutputSBuf, Len);
    if Len > 0 then
    begin
      Lineas := Len div Length(Input);
      k := 0;
      for i := 0 to Lineas - 1 do
      begin
        for j := 0 to Length(Input) - 1 do
          Input[j] := Buf[k + j];
        Cif.Init(Churro, Sizeof(Churro) * 8, nil);
        Cif.DecryptECB(Input, Output);
        Cif.Burn;
        for j := 0 to Length(Output) - 1 do
          OutputSBuf[k + j] := Output[j];
        Inc(k, 16);
      end;
      Result := trim(TEncoding.ASCII.GetString(OutputSBuf));
    end;
  finally
    Cif.Free;
  end;
end;

function Encode64(const S: string; const ByteEncoding: IIdTextEncoding = nil): string;
begin
  Result := TIdEncoderMIME.EncodeString(S, ByteEncoding);
end;

function Decode64(const S: string; const ByteEncoding: IIdTextEncoding = nil): string;
begin
  Result := TIdDecoderMIME.DecodeString(S, ByteEncoding);
end;

function ReadPropertyFromReg(Key, Propiedad: String): Variant;
var
  Reg: TRegistry;
  Tipo: TRegDataType;
begin
  Result := False;
  Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(Key, False) then
    begin
      Tipo := Reg.GetDataType(Propiedad);
      if Tipo = rdInteger then
        Result := Reg.ReadInteger(Propiedad);
      if Tipo = rdString then
        Result := Reg.ReadString(Propiedad);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure SavePropertyOnReg(Key, Propiedad: String; Value: Variant);
var
  Reg: TRegistry;
  Tipo: Word;
begin
  Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(Key, True) then
    begin
      Tipo := VarType(Value) and varTypeMask;
      if Tipo = varBoolean then
        Reg.WriteBool(Propiedad, Value)
      else if Tipo = varInteger then
        Reg.WriteInteger(Propiedad, Value)
      else if (Tipo = varString) or (Tipo = varUString) then
        Reg.WriteString(Propiedad, Value);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure LoadGridPreferences(var GridColumnsWidth: array of Single; Grid: TTMSFMXCustomGrid; Root: string; Form: String);
var
  i: Integer;
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    // Reg.OpenKey('Software\Emite\GestionPedidos\FPrincipal\' + Grid.Name + '_Columns', True);
    // Reg.WriteInteger('Count', Grid.Columns.Count);

    for i := 0 to Grid.Columns.Count - 1 do
    begin
      if Reg.KeyExists(IncludeTrailingPathDelimiter(Root) + IncludeTrailingPathDelimiter(Form) + Grid.Name + '_Columns\Item' + IntToStr(i)) then
      begin
        Reg.OpenKey(IncludeTrailingPathDelimiter(Root) + IncludeTrailingPathDelimiter(Form) + Grid.Name + '_Columns\Item' + IntToStr(i), True);
        Grid.Columns.Items[i].Width := Reg.ReadFloat('Width');
        GridColumnsWidth[i] := Grid.Columns.Items[i].Width;
        if not Reg.ReadBool('Visible') then
          Grid.HideColumn(i);
        Reg.CloseKey;
      end;
    end;
  finally
    Reg.Free;
  end;
end;

procedure LoadControlPreferences(Control: TControl; Default: TControlData);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    Control.Width := Default.Width;
    Control.Height := Default.Height;
    if Reg.KeyExists('Software\Emite\GestionPedidos\FPrincipal\' + Control.Name) then
    begin
      Reg.OpenKey('Software\Emite\GestionPedidos\FPrincipal\' + Control.Name, True);
      Control.Width := Reg.ReadFloat('Width');
      Control.Height := Reg.ReadFloat('Height');
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure SaveGridPreferences(Root: string; Form: String; Grid: TTMSFMXCustomGrid);
var
  i: Integer;
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.OpenKey(IncludeTrailingPathDelimiter(Root) + IncludeTrailingPathDelimiter(Form) + Grid.Name + '_Columns', True);
    Reg.WriteInteger('Count', Grid.Columns.Count);
    Reg.CloseKey;
    for i := 0 to Grid.Columns.Count - 1 do
    begin
      Reg.OpenKey(IncludeTrailingPathDelimiter(Root) + IncludeTrailingPathDelimiter(Form) + Grid.Name + '_Columns\Item' + IntToStr(i), True);
      Reg.WriteFloat('Width', Grid.Columns.Items[i].Width);
      Reg.WriteBool('Visible', not Grid.IsHiddenColumn(i));
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure SaveControlPreferences(Control: TControl);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.OpenKey('Software\Emite\GestionPedidos\FPrincipal\' + Control.Name, True);
    Reg.WriteFloat('Width', Control.Width);
    Reg.WriteFloat('Height', Control.Height);
    Reg.CloseKey;
  finally
    Reg.Free;
  end;
end;


function LogEvent(EventType, Category, EventID: Integer; Str: string): LongBool;
var
  EventLogger: THandle;
  P: PChar;
begin
  // Get a handle to the Event Log
  EventLogger := RegisterEventSource(nil, 'GVenaUserControl');
  if EventLogger <> 0 then
  begin
    // Cast the string as a PChar
    P := PChar(Str);
    // Write to the event log
    Result := ReportEvent(EventLogger, EventType, Category, EventID, nil, 1, 0, @P, nil);
  end
  else
    Result := False; // or raise an exception here
end;

function CheckPermiso(ID: string; FConn: TFDConnection; FDTran: TFDTransaction; UC: TFMXUserControl): boolean;
var
  Q: TFDQuery;
begin
  Result := True;
  if UC.CurrentUser.EsMaster then
    Exit;

  Q := TFDQuery.Create(nil);
  try
    with Q do
    begin
      Connection := FConn;
      Transaction := FDTran;
      SQL.Add('SELECT R.CLAVE_USER, R.CLAVE_GROUP, R.COMPONENTE, R."KEY" ');
      SQL.Add('FROM INT$UC_RIGHTS R ');
      SQL.Add('WHERE (R.CLAVE_USER = :PCLAVE OR (R.CLAVE_GROUP IN (SELECT G.CLAVE_GROUP ');
      SQL.Add('FROM INT$UC_USER_GROUP G  ');
      SQL.Add('WHERE G.CLAVE_USER = :PCLAVE ');
      SQL.Add('AND G.UKEY = UPPER(F_ENCRYPTMD5(G.CLAVE_USER || G.CLAVE_GROUP))))) ');
      SQL.Add('AND R.MODULO=:PMODULO ');
      SQL.Add('AND R.COMPONENTE=:PCOMPONENTE ');
      SQL.Add('AND R."KEY" = UPPER(F_ENCRYPTMD5(COALESCE(R.CLAVE_USER,R.CLAVE_GROUP) || R.COMPONENTE)) ');
      Close;
      ParamByName('PCLAVE').AsInteger := UC.CurrentUser.UserID;
      ParamByName('PMODULO').AsString := UC.ApplicationID;
      ParamByName('PCOMPONENTE').AsString := ID;
      Open;
      Result := not IsEmpty;
    end;
  finally
    Q.Free;
  end;
end;

procedure CheckPermisos(Contenedor: TControl; FConn: TFDConnection; FDTran: TFDTransaction; UC: TFMXUserControl);
var
  i: Integer;
begin
  if UC.CurrentUser.EsMaster then
    Exit;
  for i := 0 to Contenedor.ComponentCount - 1 do
  begin
    if (Contenedor.Components[i] Is TControl) and (TControl(Contenedor.Components[i]).TagString <> '') then
      TControl(Contenedor.Components[i]).Enabled := CheckPermiso(TControl(Contenedor.Components[i]).TagString, FConn, FDTran, UC)

    else if (Contenedor.Components[i] Is TCustomButton) and (TCustomButton(Contenedor.Components[i]).TagString <> '') then
      TCustomButton(Contenedor.Components[i]).Enabled := CheckPermiso(TCustomButton(Contenedor.Components[i]).TagString, FConn, FDTran, UC)

    else if (Contenedor.Components[i] Is TCustomComboBox) and (TCustomComboBox(Contenedor.Components[i]).TagString <> '') then
      TCustomComboBox(Contenedor.Components[i]).Enabled := CheckPermiso(TCustomComboBox(Contenedor.Components[i]).TagString, FConn, FDTran, UC)

    else if (Contenedor.Components[i] Is TCheckBox) and (TCheckBox(Contenedor.Components[i]).TagString <> '') then
      TCheckBox(Contenedor.Components[i]).Enabled := CheckPermiso(TCheckBox(Contenedor.Components[i]).TagString, FConn, FDTran, UC)

    else if (Contenedor.Components[i] Is TSpinBox) and (TSpinBox(Contenedor.Components[i]).TagString <> '') then
      TSpinBox(Contenedor.Components[i]).Enabled := CheckPermiso(TSpinBox(Contenedor.Components[i]).TagString, FConn, FDTran, UC)
  end;
end;

procedure CheckPermisos(Contenedor: TForm; FConn: TFDConnection; FDTran: TFDTransaction; UC: TFMXUserControl);
var
  i: Integer;
begin
  if UC.CurrentUser.EsMaster then
    Exit;

  for i := 0 to Contenedor.ComponentCount - 1 do
  begin
    if (Contenedor.Components[i] Is TControl) and (TControl(Contenedor.Components[i]).TagString <> '') then
      TControl(Contenedor.Components[i]).Enabled := CheckPermiso(TControl(Contenedor.Components[i]).TagString, FConn, FDTran, UC)

    else if (Contenedor.Components[i] Is TCustomButton) and (TCustomButton(Contenedor.Components[i]).TagString <> '') then
      TCustomButton(Contenedor.Components[i]).Enabled := CheckPermiso(TCustomButton(Contenedor.Components[i]).TagString, FConn, FDTran, UC)

    else if (Contenedor.Components[i] Is TCustomComboBox) and (TCustomComboBox(Contenedor.Components[i]).TagString <> '') then
      TCustomComboBox(Contenedor.Components[i]).Enabled := CheckPermiso(TCustomComboBox(Contenedor.Components[i]).TagString, FConn, FDTran, UC)

    else if (Contenedor.Components[i] Is TCheckBox) and (TCheckBox(Contenedor.Components[i]).TagString <> '') then
      TCheckBox(Contenedor.Components[i]).Enabled := CheckPermiso(TCheckBox(Contenedor.Components[i]).TagString, FConn, FDTran, UC)

    else if (Contenedor.Components[i] Is TSpinBox) and (TSpinBox(Contenedor.Components[i]).TagString <> '') then
      TSpinBox(Contenedor.Components[i]).Enabled := CheckPermiso(TSpinBox(Contenedor.Components[i]).TagString, FConn, FDTran, UC)
  end;
end;

function GeneratePass(iPassLength: Integer; iCompileType: Integer): string;
const
  arrLetters: array [1 .. 26] of Char = ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z');
  arrNumsAndSpecials: array [1 .. 18] of Char = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '@', '!', '#', '$', '%', '^', '&', '*');
  arrCapitals: array [1 .. 26] of Char = ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U',
    'V', 'W', 'X', 'Y', 'Z');
  iShifter = 4;

var
  iOdd, iEven: Integer;
  i: Integer;
  j: Integer;
  k: Integer;
  sPassword: string;
begin
  sPassword:='********';
  case iCompileType of
    1:
      begin
        for i := 1 to 4 do
        begin
          if i MOD 2 = 0 then
          begin
            sPassword[i] := arrLetters[RandomRange(1, 27)];
          end
          else
          begin
            sPassword[i] := arrNumsAndSpecials[RandomRange(1, 19)];
          end;
        end;
        for j := 5 to 8 do
        begin
          if j MOD 2 = 0 then
          begin
            sPassword[j] := arrCapitals[RandomRange(1, 27)];
          end
          else
          begin
            sPassword[j] := arrNumsAndSpecials[RandomRange(9, 19)];
          end;
        end;
        for k := 9 to 13 do
        begin
          if k MOD 2 = 0 then
          begin
            sPassword[k] := arrNumsAndSpecials[RandomRange(1, 19)];
          end
          else
          begin
            sPassword[k] := arrLetters[RandomRange(1, 27)];
          end;
        end;
      end;
    2:
      begin
        sPassword[1] := arrNumsAndSpecials[Ceil(RandomRange(1, 19) / 4)];
        sPassword[2] := arrNumsAndSpecials[RandomRange(10, 19)];
        iEven := 2;
        repeat
          iEven := iEven + 2;
          sPassword[iEven] := arrLetters[Ceil(RandomRange(1, 27) / 3.5)];
        until iEven = 8;
        iOdd := 3;
        repeat
          iOdd := iOdd + 2;
          sPassword[iOdd] := arrNumsAndSpecials[RandomRange(10, 19)];
        until (iOdd = 9);
        sPassword[10] := arrCapitals[RandomRange(1, 27)];
        sPassword[11] := arrNumsAndSpecials[RandomRange(1, 11)];
        sPassword[12] := arrCapitals[RandomRange(1, 27)];
      end;
  end;
  Result := sPassword;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'Criptografia'} {$ENDIF}

function MD5Sum(strValor: String): String;
begin
  With TIdHashMessageDigest5.Create do
  begin
    Result := HashStringAsHex(strValor);
    Free;
  end;
end;

function GetKeyTUsuario(Clave: Integer; Login, Password: string; PassISCif: boolean = False): string;
begin
  if PassISCif then
    Result := MD5Sum(IntToStr(Clave) + Login + Password)
  else
    Result := MD5Sum(IntToStr(Clave) + Login + GetKeyPassword(Password));

  { case UserControl.Criptografia of
    cPadrao:
    begin
    String1 := Decrypt(Q.FieldByName('KEY').AsString, UserControl.EncryptKey);
    String2 := Clave + Q.FieldByName('COMPONENTE').AsString;
    end;
    cMD5:
    begin
    String1 := Q.FieldByName('KEY').AsString;
    String2 := MD5Sum(Clave + Q.FieldByName('COMPONENTE').AsString);
    end;
    end; }

end;

function GetKeyTGrupo(Clave, ClaveEmpresa: Integer; Nombre: string): string;
begin
  Result := MD5Sum(IntToStr(Clave) + Nombre + IntToStr(ClaveEmpresa));
end;

function GetKeyTPermisos(Clave: Integer; Componente: string): string;
begin
  Result := MD5Sum(IntToStr(Clave) + Componente);
end;

function GetKeyTUserGroup(ClaveUser, ClaveGroup: Integer): string;
begin
  Result := MD5Sum(IntToStr(ClaveUser) + IntToStr(ClaveGroup));
end;

function GetKeyTUserWin(Clave: Integer; SID, Login: string): string;
begin
  Result := MD5Sum(IntToStr(Clave) + SID + Login);
end;

function GetKeyPassword(Pass: string): string;
begin
  Result := MD5Sum(Pass);
end;

function Decode(const S: ansistring): ansistring;

const
  Map: array [Ansichar] of byte = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 62, 0, 0, 0, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
    16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 0, 0, 0, 0, 0, 0, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
    48, 49, 50, 51, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

var
  i: longint;
begin
  case Length(S) of
    2:
      begin
        i := Map[S[1]] + (Map[S[2]] shl 6);
        SetLength(Result, 1);
        Move(i, Result[1], Length(Result));
      end;
    3:
      begin
        i := Map[S[1]] + (Map[S[2]] shl 6) + (Map[S[3]] shl 12);
        SetLength(Result, 2);
        Move(i, Result[1], Length(Result));
      end;
    4:
      begin
        i := Map[S[1]] + (Map[S[2]] shl 6) + (Map[S[3]] shl 12) + (Map[S[4]] shl 18);
        SetLength(Result, 3);
        Move(i, Result[1], Length(Result));
      end
  end;
end;

function Encode(const S: ansistring): ansistring;

const
  Map: array [0 .. 63] of Char = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

var
  i: longint;
begin
  i := 0;
  Move(S[1], i, Length(S));
  case Length(S) of
    1:
      Result := Map[i mod 64] + Map[(i shr 6) mod 64];
    2:
      Result := Map[i mod 64] + Map[(i shr 6) mod 64] + Map[(i shr 12) mod 64];
    3:
      Result := Map[i mod 64] + Map[(i shr 6) mod 64] + Map[(i shr 12) mod 64] + Map[(i shr 18) mod 64];
  end;
end;

function InternalDecrypt(const S: ansistring; Key: Word): ansistring;

var
  i: Word;
  Seed: int64;
begin
  Result := S;
  Seed := Key;
  for i := 1 to Length(Result) do
  begin
    Result[i] := Ansichar(byte(Result[i]) xor (Seed shr 8));
    Seed := (byte(S[i]) + Seed) * Word(C1) + Word(C2);
  end;
end;

function PreProcess(const S: ansistring): ansistring;

var
  SS: ansistring;
begin
  SS := S;
  Result := '';
  while SS <> '' do
  begin
    Result := Result + Decode(Copy(SS, 1, 4));
    Delete(SS, 1, 4);
  end;
end;

function Decrypt(const S: ansistring; Key: Word): ansistring;
begin
  Result := InternalDecrypt(PreProcess(S), Key);
end;

function PostProcess(const S: ansistring): ansistring;

var
  SS: ansistring;
begin
  SS := S;
  Result := '';
  while SS <> '' do
  begin
    Result := Result + Encode(Copy(SS, 1, 3));
    Delete(SS, 1, 3);
  end;
end;

function InternalEncrypt(const S: ansistring; Key: Word): ansistring;

var
  i: Word;
  Seed: int64;
begin
  Result := S;
  Seed := Key;
  for i := 1 to Length(Result) do
  begin
    Result[i] := Ansichar(byte(Result[i]) xor (Seed shr 8));
    Seed := (byte(Result[i]) + Seed) * Word(C1) + Word(C2);
  end;
end;

function Encrypt(const S: ansistring; Key: Word): ansistring;
begin
  Result := PostProcess(InternalEncrypt(S, Key));
end;

function AllItems(MainMenu: TMainMenu): TItemArr;

var
  i: Cardinal;
  procedure Parse(var Result: TItemArr; Item: TMenuItem);

  var
    i: Cardinal;
  begin
    SetLength(Result, SUCC(Length(Result)));
    Result[HIGH(Result)] := Item;
    for i := 1 to Item.ItemsCount do
      Parse(Result, Item.Items[Pred(i)])
  end;

begin
  if MainMenu = nil then
    Exit;

  SetLength(Result, 0);
  for i := 1 to MainMenu.ItemsCount DO
    Parse(Result, TMenuItem(MainMenu.Items[Pred(i)]))
end;

function BoolToTF(B: boolean): String;
begin
  Result := 'FALSE';
  if B then
    Result := 'TRUE';
end;

function ConvertSid(SID: PSID; pszSidText: PChar; var dwBufferLen: DWORD): BOOL;

var
  psia: PSIDIdentifierAuthority;
  dwSubAuthorities: DWORD;
  dwSidRev: DWORD;
  dwCounter: DWORD;
  dwSidSize: DWORD;
begin
  Result := False;

  dwSidRev := SID_REVISION;

  if not IsValidSid(SID) then
    Exit;

  psia := GetSidIdentifierAuthority(SID);

  dwSubAuthorities := GetSidSubAuthorityCount(SID)^;

  dwSidSize := (15 + 12 + (12 * dwSubAuthorities) + 1) * Sizeof(Char);

  if (dwBufferLen < dwSidSize) then
  begin
    dwBufferLen := dwSidSize;
    SetLastError(ERROR_INSUFFICIENT_BUFFER);
    Exit;
  end;

  StrFmt(pszSidText, 'S-%u-', [dwSidRev]);

  if (psia.Value[0] <> 0) or (psia.Value[1] <> 0) then
    StrFmt(pszSidText + StrLen(pszSidText), '0x%.2x%.2x%.2x%.2x%.2x%.2x', [psia.Value[0], psia.Value[1], psia.Value[2], psia.Value[3], psia.Value[4],
      psia.Value[5]])
  else
    StrFmt(pszSidText + StrLen(pszSidText), '%u', [DWORD(psia.Value[5]) + DWORD(psia.Value[4] shl 8) + DWORD(psia.Value[3] shl 16) +
      DWORD(psia.Value[2] shl 24)]);

  dwSidSize := StrLen(pszSidText);

  for dwCounter := 0 to dwSubAuthorities - 1 do
  begin
    StrFmt(pszSidText + dwSidSize, '-%u', [GetSidSubAuthority(SID, dwCounter)^]);
    dwSidSize := StrLen(pszSidText);
  end;

  Result := True;
end;

function GetLocalComputerName: String;
var
  Count: DWORD;
  Buffer: String;
begin
  Count := MAX_COMPUTERNAME_LENGTH + 1;
  SetLength(Buffer, Count);
  if GetComputerName(PChar(Buffer), Count) then
    SetLength(Buffer, StrLen(PChar(Buffer)))
  else
    Buffer := '';
  Result := Buffer;
end;

function GetLocalUserName: String;
var
  Count: DWORD;
  Buffer: String;
begin
  Count := 254;
  SetLength(Buffer, Count);
  if GetUserName(PChar(Buffer), Count) then
    SetLength(Buffer, StrLen(PChar(Buffer)))
  else
    Buffer := '';
  Result := Buffer;
end;

function DateTimeToStrUs(dt: TDatetime): string;
var
  us: string;
begin
  // Spit out most of the result: '20160802 11:34:36.'
  Result := FormatDateTime('dd/mm/yyyy hh":"nn":"ss"."', dt);

  // extract the number of microseconds
  dt := Frac(dt); // fractional part of day
  dt := dt * 24 * 60 * 60; // number of seconds in that day
  us := IntToStr(Round(Frac(dt) * 1000000));

  // Add the us integer to the end:
  // '20160801 11:34:36.' + '00' + '123456'
  Result := Result + StringOfChar('0', 6 - Length(us)) + us;
end;

function ObtainTextSid(hToken: THandle; pszSid: PChar; var dwBufferLen: DWORD): BOOL;

var
  dwReturnLength: DWORD;
  dwTokenUserLength: DWORD;
  tic: TTokenInformationClass;
  ptu: Pointer;
begin
  Result := False;
  dwReturnLength := 0;
  dwTokenUserLength := 0;
  tic := TokenUser;
  ptu := nil;

  if not GetTokenInformation(hToken, tic, ptu, dwTokenUserLength, dwReturnLength) then
  begin
    if GetLastError = ERROR_INSUFFICIENT_BUFFER then
    begin
      ptu := HeapAlloc(GetProcessHeap, HEAP_ZERO_MEMORY, dwReturnLength);
      if ptu = nil then
        Exit;
      dwTokenUserLength := dwReturnLength;
      dwReturnLength := 0;

      if not GetTokenInformation(hToken, tic, ptu, dwTokenUserLength, dwReturnLength) then
        Exit;
    end
    else
      Exit;
  end;

  if not ConvertSid((PTokenUser(ptu).User).SID, pszSid, dwBufferLen) then
    Exit;

  if not HeapFree(GetProcessHeap, 0, ptu) then
    Exit;

  Result := True;
end;

function GetCurrentUserSid: string;

var
  hAccessToken: THandle;
  bSuccess: BOOL;
  dwBufferLen: DWORD;
  szSid: array [0 .. 260] of Char;
begin
  Result := '';

  bSuccess := OpenThreadToken(GetCurrentThread, TOKEN_QUERY, True, hAccessToken);
  if not bSuccess then
  begin
    if GetLastError = ERROR_NO_TOKEN then
      bSuccess := OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, hAccessToken);
  end;
  if bSuccess then
  begin
    ZeroMemory(@szSid, Sizeof(szSid));
    dwBufferLen := Sizeof(szSid);

    if ObtainTextSid(hAccessToken, szSid, dwBufferLen) then
      Result := szSid;
    CloseHandle(hAccessToken);
  end;
end;
{
  procedure pintaCheck(DBCheckBoxx: TDBCheckBox; DBGridx: TJvDBGrid; const Rect: TRect);
  begin
  with DBCheckBoxx do
  begin
  Width := Rect.Right - Rect.Left;
  Height := Rect.Bottom - Rect.Top;
  Left := Rect.Left + DBGridx.Left + 2;
  // para que el check sea centrado hay que usar un check con cuadrado centrado
  Top := Rect.Top + DBGridx.Top + 2;
  Visible := True;
  end;
  end;

  procedure DBGridKeyDown(DBGridx: TJvDBGrid; var Key: Word; Shift: TShiftState);

  var
  Msg: TMsg;
  begin
  if Key = VK_DECIMAL then
  // Cambio la  pulsacion del . en teclado numerico por una ,
  begin
  PeekMessage(Msg, DBGridx.Handle, WM_KEYFIRST, WM_KEYLAST, PM_REMOVE);
  SendMessage(DBGridx.Handle, WM_CHAR, Ord(','), 0);
  end;

  if Key = VK_INSERT then
  // Si se intenta insertar con el teclado lo cambiamos por nada
  begin
  Key := 0;
  end;

  if (((Key = VK_DOWN) or (Key = VK_UP)) and (DBGridx.DataSource.DataSet.State in [dsEdit, dsInsert])) then
  DBGridx.DataSource.DataSet.Post;
  if ((Key = VK_DOWN) or ((Key = VK_TAB) and (DBGridx.SelectedIndex = DBGridx.Columns.Count - 1))) then
  begin
  DBGridx.DataSource.DataSet.DisableControls;
  DBGridx.DataSource.DataSet.Next;
  if DBGridx.DataSource.DataSet.EOF then
  Key := 0
  else
  DBGridx.DataSource.DataSet.Prior;
  DBGridx.DataSource.DataSet.EnableControls;
  end;
  end;

  procedure SetGridColumnWidths(aDBGrid: TJvDBGrid);

  const
  DEFBORDER = 10;

  var
  i, temp, n: Integer;
  lmax: array [0 .. 50] of Integer;
  begin
  if aDBGrid.DataSource.DataSet.RecordCount > 0 then
  try
  aDBGrid.DataSource.DataSet.DisableControls;
  aDBGrid.Canvas.Font := aDBGrid.Font;
  for n := 0 to aDBGrid.Columns.Count - 1 do
  lmax[n] := aDBGrid.Canvas.TextWidth(aDBGrid.Fields[n].FieldName) + DEFBORDER;
  aDBGrid.DataSource.DataSet.First;
  i := 0;
  while not aDBGrid.DataSource.DataSet.EOF do
  begin
  i := i + 1;
  for n := 0 to aDBGrid.Columns.Count - 1 do
  begin
  temp := aDBGrid.Canvas.TextWidth(trim(aDBGrid.Columns[n].Field.DisplayText)) + DEFBORDER;
  if temp > lmax[n] then
  lmax[n] := temp;
  end;
  if i > 1000 then
  aDBGrid.DataSource.DataSet.Last;
  aDBGrid.DataSource.DataSet.Next;
  end;
  aDBGrid.DataSource.DataSet.First;
  for n := 0 to aDBGrid.Columns.Count - 1 do
  if lmax[n] > 0 then
  aDBGrid.Columns[n].Width := lmax[n];
  finally
  aDBGrid.DataSource.DataSet.EnableControls;
  end;
  end; }
{
  procedure GridTitleBtn(DBGridx: TJvDBGrid; ACol: Integer; VerC: boolean);
  begin
  if VerC then
  begin
  if DBGridx.Columns[ACol].Title.Font.Color = clWindowText then
  begin
  DBGridx.Columns[ACol].Title.Font.Color := clblue;
  DBGridx.Columns[ACol].Title.Font.Style := DBGridx.Columns[ACol].Title.Font.Style - [fsBold] - [fsItalic];
  end
  else
  DBGridx.Columns[ACol].Title.Font.Color := clWindowText;
  end
  else
  begin
  DBGridx.SortMarker := jvDBGrid.smNone;
  if (DBGridx.DataSource.DataSet.State in [dsEdit, dsInsert]) then
  begin
  DBGridx.DataSource.DataSet.Post;
  DBGridx.DataSource.DataSet.Refresh;
  end;
  if not(fsBold in DBGridx.Columns[ACol].Title.Font.Style) then
  DBGridx.Columns[ACol].Title.Font.Style := DBGridx.Columns[ACol].Title.Font.Style + [fsBold]
  else if (fsItalic in DBGridx.Columns[ACol].Title.Font.Style) then
  DBGridx.Columns[ACol].Title.Font.Style := DBGridx.Columns[ACol].Title.Font.Style - [fsBold] - [fsItalic]
  else
  DBGridx.Columns[ACol].Title.Font.Style := DBGridx.Columns[ACol].Title.Font.Style + [fsItalic];
  if (fsItalic in DBGridx.Columns[ACol].Title.Font.Style) then
  DBGridx.SortMarker := jvDBGrid.smDown
  else if (fsBold in DBGridx.Columns[ACol].Title.Font.Style) then
  DBGridx.SortMarker := jvDBGrid.smUP;
  ReOrden(DBGridx);
  end;
  end;

  procedure VerColG(VerC: boolean; DBGridx: TJvDBGrid);

  var
  i: Integer;
  begin
  if VerC then
  for i := 0 to (DBGridx.Columns.Count - 1) do
  DBGridx.Columns[i].Visible := True
  else
  for i := 0 to (DBGridx.Columns.Count - 1) do
  if DBGridx.Columns[i].Title.Font.Color = clblue then
  DBGridx.Columns[i].Visible := False
  else
  DBGridx.Columns[i].Visible := True;
  end;

  procedure ReOrden(DBGridx: TJvDBGrid);

  var
  VOrden, VTabla: string;
  i: Integer;
  DSet: TFDQuery;
  begin
  DSet := TFDQuery(DBGridx.DataSource.DataSet);
  VTabla := GetTableNameFromQuery(DSet.SQL.Text);
  VOrden := ' ORDER BY ';
  for i := 0 to (DBGridx.Columns.Count - 1) do
  begin
  if (fsBold in DBGridx.Columns[i].Title.Font.Style) then
  begin

  if (TFDQuery(DBGridx.DataSource.DataSet).Name = 'FDUsuarios') then
  begin
  if (DBGridx.Columns[i].FieldName = 'NOMBRE') then
  VOrden := VOrden + 'U.UCLOGIN'
  else if (DBGridx.Columns[i].FieldName = 'DESCRIPCION') then
  VOrden := VOrden + 'U.UCDESCRIPCION'
  else
  VOrden := VOrden + 'A.' + DBGridx.Columns[i].FieldName;
  end
  else if (TFDQuery(DBGridx.DataSource.DataSet).Name = 'FDGrupos') then
  begin
  if (DBGridx.Columns[i].FieldName = 'NOMBRE') then
  VOrden := VOrden + 'G.UC_NOMBRE'
  else if (DBGridx.Columns[i].FieldName = 'DESCRIPCION') then
  VOrden := VOrden + 'G.UC_DESCRIPCION'
  else
  VOrden := VOrden + 'A.' + DBGridx.Columns[i].FieldName;
  end

  else if (TFDQuery(DBGridx.DataSource.DataSet).Name = 'FDMaster') then
  begin
  if (DBGridx.Columns[i].FieldName = 'NOMBRE') and ((VTabla = 'INT$UC_USERS') or (VTabla = 'INT$UC_GROUPS')) then
  begin
  if VTabla = 'INT$UC_USERS' then
  VOrden := VOrden + 'A.UCLOGIN'
  else if VTabla = 'INT$UC_GROUPS' then
  VOrden := VOrden + 'A.UC_NOMBRE'
  end
  else if (DBGridx.Columns[i].FieldName = 'DESCRIPCION') and ((VTabla = 'INT$UC_USERS') or (VTabla = 'INT$UC_GROUPS')) then
  begin
  if VTabla = 'INT$UC_USERS' then
  VOrden := VOrden + 'A.UCDESCRIPCION'
  else if VTabla = 'INT$UC_GROUPS' then
  VOrden := VOrden + 'A.UC_DESCRIPCION'
  end
  else if (DBGridx.Columns[i].FieldName = 'EMPRESA') then
  VOrden := VOrden + 'I.NOMBRE'
  else if (DBGridx.Columns[i].FieldName = 'ALIAS') then
  VOrden := VOrden + 'B.UCUSERNAME'
  else if (DBGridx.Columns[i].FieldName = 'USUARIO') then
  VOrden := VOrden + 'B.UCLOGIN'
  else if (DBGridx.Columns[i].FieldName = 'AMBITO') then
  VOrden := VOrden + 'B.UCAMBITO'
  else if (DBGridx.Columns[i].FieldName = 'MASTER') then
  VOrden := VOrden + 'B.UCMASTER'
  else
  VOrden := VOrden + 'A.' + DBGridx.Columns[i].FieldName;
  end
  else
  VOrden := VOrden + 'A.' + DBGridx.Columns[i].FieldName;

  if (fsItalic in DBGridx.Columns[i].Title.Font.Style) then
  VOrden := VOrden + ' DESC, '
  else
  VOrden := VOrden + ' ASC, ';
  end;
  end;

  with DSet do
  begin
  SQL.Text := CopyWordPos('ORDER', SQL.Text) + VOrden + ' A.CLAVE';
  // RefreshSQL.Text := CopyWordPos('ORDER', RefreshSQL.Text) + VOrden + ' A.CLAVE';
  if State = dsInactive then
  Open;
  Refresh;
  end;
  end;

  function CopyWordPos(Subs, Text: string): string;

  var
  s: string;
  P: Integer;

  function WordPos(const AWord, AString: string): Integer;

  const
  Identifiers = ['a' .. 'z', 'A' .. 'Z', '0' .. '9', '_', '#', '$', '.', '"', '@'];

  var
  s: string;
  i, P: Integer;
  begin
  s := ' ' + AString + ' ';
  for i := 1 to Length(s) do
  if not CharInSet(s[i], Identifiers) then
  s[i] := ' ';
  P := pos(' ' + AWord + ' ', s);
  Result := P;
  end;

  begin
  if Subs = '' then
  begin
  P := WordPos('WHERE', Text);
  // if there is no where clause
  if P = 0 then
  begin
  // hasWhere := false;
  P := WordPos('GROUP', Text);
  if P = 0 then
  P := WordPos('HAVING', Text);
  if P = 0 then
  P := WordPos('ORDER', Text);
  if P = 0 then
  P := Length(Text);
  end;
  end
  else
  P := pos(Subs, Text);
  s := Text;
  if P > 0 then
  Result := trim(Copy(s, 0, P - 1))
  else
  Result := trim(s);
  end; }

end.
