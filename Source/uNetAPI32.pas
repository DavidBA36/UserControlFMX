unit uNetAPI32;

interface

uses System.Variants, System.SysUtils, Winapi.Windows, System.Classes, System.Win.COMObj, System.Generics.Collections;

const
  netapi32lib = 'netapi32.dll';
  HEAP_ZERO_MEMORY = $00000008;
  SID_REVISION = 1; // Current revision level
  MAX_PREFERRED_LENGTH = -1;

type
  _NET_DISPLAY_GROUP = packed record
    grpi3_name: LPWSTR;
    grpi3_comment: LPWSTR;
    grpi3_group_id: DWORD;
    grpi3_attributes: DWORD;
    grpi3_next_index: DWORD;
  end;

  P_NET_DISPLAY_GROUP = ^_NET_DISPLAY_GROUP;

  TGrupo = packed record
    Nombre: string;
    SID: string;
    Descripcion: string;
  end;

  TListaGrupo = TList<TGrupo>;

  GROUP_INFO_1 = packed record
    grpi1_name: LPWSTR;
    grpi1_comment: LPWSTR;
  end;

  PGROUP_INFO_1 = ^GROUP_INFO_1;

  WKSTA_INFO_100 = Record
    wki100_platform_id: DWORD;
    wki100_computername: LPWSTR;
    wki100_langroup: LPWSTR;
    wki100_ver_major: DWORD;
    wki100_ver_minor: DWORD;
  End;

  LPWKSTA_INFO_100 = ^WKSTA_INFO_100;

  PGroupUsersInfo0 = ^TGroupUsersInfo0;

  _GROUP_USERS_INFO_0 = record
    grui0_name: LPWSTR;
  end;

  TGroupUsersInfo0 = _GROUP_USERS_INFO_0;
  GROUP_USERS_INFO_0 = _GROUP_USERS_INFO_0;

  _USER_INFO_0 = record
    usri0_name: LPWSTR;
  end;

  TUserInfo0 = _USER_INFO_0;

  // function DomainGroupGetUsers(const sGroup: WideString; const UserList: TStrings; const sLogonServer: WideString): boolean;
function GetDomainName: String;
procedure NetGetUsers(Users: TStringList; AServer: string);
procedure NetGetGroups(Groups: TListaGrupo; AServer: string);

implementation

function NetApiBufferFree(Buffer: Pointer): DWORD; stdcall; external netapi32lib;
function NetGroupGetUsers(servername: LPCWSTR; groupname: LPCWSTR; level: DWORD; var bufptr: LPBYTE; prefmaxlen: DWORD; var entriesread: DWORD; var totalentries: DWORD;
  ResumeHandle: PDWORD): DWORD; stdcall; external netapi32lib;

Function NetWkstaGetInfo(servername: LPWSTR; level: DWORD; bufptr: Pointer): Longint; Stdcall; external netapi32lib Name 'NetWkstaGetInfo';
function NetApiBufferAllocate(ByteCount: DWORD; var Buffer: Pointer): DWORD; stdcall; external netapi32lib;
function NetGetDCName(servername: LPCWSTR; domainname: LPCWSTR; bufptr: Pointer): DWORD; stdcall; external netapi32lib;
function NetUserEnum(servername: LPCWSTR; level: DWORD; filter: DWORD; var bufptr: Pointer; prefmaxlen: DWORD; var entriesread: DWORD; var totalentries: DWORD;
  resume_handle: PDWORD): DWORD; stdcall; external netapi32lib;
function NetQueryDisplayInformation(servername: PWideChar; level, Index, EntriesRequested, PreferredMaximumLength: Cardinal; var ReturnedEntryCount: Cardinal;
  var SortedBuffer: Pointer): DWORD; stdcall; external netapi32lib;
function NetLocalGroupEnum(servername: LPCWSTR; level: DWORD; var bufptr: Pointer; prefmaxlen: DWORD; var entriesread: DWORD; var totalentries: DWORD; resume_handle: PDWORD)
  : DWORD; stdcall; external netapi32lib;

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

  dwSidSize := (15 + 12 + (12 * dwSubAuthorities) + 1) * SizeOf(Char);

  if (dwBufferLen < dwSidSize) then
  begin
    dwBufferLen := dwSidSize;
    SetLastError(ERROR_INSUFFICIENT_BUFFER);
    Exit;
  end;

  StrFmt(pszSidText, 'S-%u-', [dwSidRev]);

  if (psia.Value[0] <> 0) or (psia.Value[1] <> 0) then
    StrFmt(pszSidText + StrLen(pszSidText), '0x%.2x%.2x%.2x%.2x%.2x%.2x', [psia.Value[0], psia.Value[1], psia.Value[2], psia.Value[3], psia.Value[4], psia.Value[5]])
  else
    StrFmt(pszSidText + StrLen(pszSidText), '%u', [DWORD(psia.Value[5]) + DWORD(psia.Value[4] shl 8) + DWORD(psia.Value[3] shl 16) + DWORD(psia.Value[2] shl 24)]);

  dwSidSize := StrLen(pszSidText);

  for dwCounter := 0 to dwSubAuthorities - 1 do
  begin
    StrFmt(pszSidText + dwSidSize, '-%u', [GetSidSubAuthority(SID, dwCounter)^]);
    dwSidSize := StrLen(pszSidText);
  end;

  Result := True;
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
    ZeroMemory(@szSid, SizeOf(szSid));
    dwBufferLen := SizeOf(szSid);

    if ObtainTextSid(hAccessToken, szSid, dwBufferLen) then
      Result := szSid;
    CloseHandle(hAccessToken);
  end;
end;

function GetNetParam(AParam: integer): string;
Var
  PBuf: LPWKSTA_INFO_100;
  Res: Longint;
begin
  Result := '';
  Res := NetWkstaGetInfo(Nil, 100, @PBuf);
  If Res = 0 Then
  begin
    case AParam of
      0:
        Result := string(PBuf^.wki100_computername);
      1:
        Result := string(PBuf^.wki100_langroup);
    end;
  end;
end;

function GetDomainName: string;
begin
  Result := GetNetParam(1);
end;

// DomainGroupGetUsers ('Domain Users', UserList, GetEnvironmentVariable ('LOGONSERVER'));

{ function DomainGroupGetUsers(const sGroup: WideString; const UserList: TStrings; const sLogonServer: WideString): boolean;
  type
  TaUserGroup = array of TGroupUsersInfo0;
  const
  PREF_LEN = 1024;
  var
  pBuffer: PByte;
  i: integer;
  Res: DWORD;
  dwRead, dwTotal: DWORD;
  hRes: DWORD;
  begin
  Assert(sGroup <> '');
  Assert(sLogonServer <> '');
  Assert(UserList <> NIL);

  UserList.Clear;
  result := true;
  hRes := 0;

  repeat
  Res := NetGroupGetUsers(PWideChar(sLogonServer), PWideChar(sGroup), 0, pBuffer, PREF_LEN, dwRead, dwTotal, PDWORD(@hRes));

  if (Res = Error_Success) or (Res = ERROR_MORE_DATA) then
  begin
  if (dwRead > 0) then
  for i := 0 to dwRead - 1 do
  with TaUserGroup(pBuffer)[i] do
  UserList.Add(grui0_name);

  NetApiBufferFree(pBuffer);
  end
  else
  result := false;
  until (Res <> ERROR_MORE_DATA);
  end; }

// GetUsers(Users, 'localhost');
procedure NetGetUsers(Users: TStringList; AServer: string);
type
  TUserInfoArr = array [0 .. (MaxInt - 4) div SizeOf(TUserInfo0)] of TUserInfo0;
var
  UserInfo: Pointer;
  entriesread, totalentries, ResumeHandle: DWORD;
  Res: DWORD;
  i: integer;
  FServer: WideString;
  UserList: Variant;
begin
  FServer := AServer;
  ResumeHandle := 0;
  repeat
    Res := NetUserEnum(PWideChar(FServer), 2, 0, UserInfo, 64 * SizeOf(TUserInfo0), entriesread, totalentries, @ResumeHandle);
    if (Res = 0) or (Res = ERROR_MORE_DATA) then
    begin
      for i := 0 to entriesread - 1 do
        Users.Add(TUserInfoArr(UserInfo^)[i].usri0_name);
      NetApiBufferFree(UserInfo);
    end;
  until Res <> ERROR_MORE_DATA;

  { if Users.Count = 0 then
    begin
    try
    UserList := CreateOleObject('Shell.Users');
    for i := 0 to UserList.length - 1 do
    Users.Add(PChar(String(UserList.Item(i).Setting['LoginName'])));
    except
    end;
    end; }
end;

procedure NetGetGroups(Groups: TListaGrupo; AServer: string);
var
  pBuff: Pointer;
  GroupInfo: P_NET_DISPLAY_GROUP;
  Index, dwRec: Cardinal;
  Res: DWORD;
  i: integer;
  FServer: WideString;
  // GroupList: Variant;
  Grupo: TGrupo;
begin
  Index := 0;
  if Groups = nil then
    Exit;
  FServer := AServer;
  repeat
    Res := NetQueryDisplayInformation(PWideChar(FServer), 3, Index, 100, High(Cardinal), dwRec, pBuff);
    if (Res = 0) or (Res = ERROR_MORE_DATA) then
    begin
      GroupInfo := @pBuff^;
      for i := 0 to dwRec - 1 do
      begin
        Grupo.Nombre := GroupInfo^.grpi3_name;
        Grupo.SID := IntToStr(GroupInfo^.grpi3_group_id);
        Grupo.Descripcion := GroupInfo^.grpi3_comment;
        Groups.Add(Grupo);
        Index := GroupInfo^.grpi3_next_index;
        inc(GroupInfo);
      end;
      NetApiBufferFree(pBuff);
    end;
  until Res <> ERROR_MORE_DATA;

  { if Groups.Count = 0 then
    begin
    try
    GroupList := CreateOleObject('Shell.Users');
    for i := 0 to GroupList.length - 1 do
    Groups.Add(PChar(String(GroupList.Item(i).Setting['LoginName'])));
    except
    end;
    end; }
end;

end.
