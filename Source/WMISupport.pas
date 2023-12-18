unit WMISupport;

interface

uses WbemScripting_TLB, System.Classes, System.Json, System.SysUtils, System.Variants, System.Win.ComObj, System.Generics.Collections, Winapi.ActiveX;

type
  TWMIQueryRes = procedure(msg: string) of object;

  TWMIQueryThread = class(TThread)
  private
    Success: HResult;
    FTextRecord: string;
    FClase, FNameSpace, FWQL: string;
    FOnFinish: TWMIQueryRes;
    FOnError: TWMIQueryRes;
    procedure DoOnFinish;
    procedure DoOnError;
  public
    constructor Create(Clase, NameSpace, WQL: string; OnError, OnFinish: TWMIQueryRes); overload;
    destructor Destroy; override;
    procedure Execute; override;
  end;

procedure OpenQuery(WQL, Clase: string; OnError, OnFinish: TWMIQueryRes);

var
  FThread: TWMIQueryThread;

implementation

constructor TWMIQueryThread.Create(Clase, NameSpace, WQL: string; OnError, OnFinish: TWMIQueryRes);
begin
  inherited Create(false);
  FreeOnTerminate := True;
  FOnFinish := OnFinish;
  FOnError := OnError;
  FClase := Clase;
  FNameSpace := NameSpace;
  FWQL := WQL;
end;

destructor TWMIQueryThread.Destroy;
begin
  inherited;
end;

procedure TWMIQueryThread.DoOnFinish;
begin
  FOnFinish(FTextRecord);
end;

procedure TWMIQueryThread.DoOnError;
begin
  FOnError(FTextRecord);
end;

function GetExceptMess(ExceptObject: TObject): string;
var
  MsgPtr: PChar;
  MsgEnd: PChar;
  MsgLen: integer;
  MessEnd: String;
begin
  MsgPtr := '';
  MsgEnd := '';
  if ExceptObject is Exception then
  begin
    MsgPtr := PChar(Exception(ExceptObject).Message);
    MsgLen := StrLen(MsgPtr);
    if (MsgLen <> 0) and (MsgPtr[MsgLen - 1] <> '.') then
      MsgEnd := '.';
  end;
  result := Trim(MsgPtr);
  MessEnd := Trim(MsgEnd);
  if Length(MessEnd) > 5 then
    result := result + ' - ' + MessEnd;
end;

function GetPropStr(wmiProp: ISWbemProperty): string;
var
  I: integer;
begin
  result := '';
  if VarIsNull(wmiProp.Get_Value) then
    result := 'NULL'
  else
  begin
    case wmiProp.CimType of
      wbemCimtypeSint8, wbemCimtypeUint8, wbemCimtypeSint16, wbemCimtypeUint16, wbemCimtypeSint32, wbemCimtypeUint32, wbemCimtypeSint64:
        if VarIsArray(wmiProp.Get_Value) then
        begin
          for I := 0 to VarArrayHighBound(wmiProp.Get_Value, 1) do
          begin
            if I > 0 then
              result := result + '|';
            result := result + IntToStr(wmiProp.Get_Value[I]);
          end;
        end
        else
          result := IntToStr(wmiProp.Get_Value);

      wbemCimtypeReal32, wbemCimtypeReal64:
        result := FloatToStr(wmiProp.Get_Value);

      wbemCimtypeBoolean:
        if Boolean(wmiProp.Get_Value) then
          result := 'True'
        else
          result := 'False';

      wbemCimtypeString, wbemCimtypeUint64:
        if VarIsArray(wmiProp.Get_Value) then
        begin
          for I := 0 to VarArrayHighBound(wmiProp.Get_Value, 1) do
          begin
            if I > 0 then
              result := result + '|';
            result := result + wmiProp.Get_Value[I];
          end;
        end
        else
          result := wmiProp.Get_Value;

      wbemCimtypeDatetime:
        result := wmiProp.Get_Value;

      wbemCimtypeReference:
        begin
          result := wmiProp.Get_Value;
          // Services.Get(result, 0, nil).GetObjectText_(0));  another query
        end;

      wbemCimtypeChar16:
        result := '<16-bit character>';

      wbemCimtypeObject:
        result := '<CIM Object>';
    end;
  end;
end;

procedure TWMIQueryThread.Execute;
var
  wmiLocator: TSWbemLocator;
  wmiServices: ISWbemServices;
  wmiObjectSet: ISWbemObjectSet;
  wmiObject: ISWbemObject;
  propSet: ISWbemPropertySet;
  wmiProp: ISWbemProperty;
  propEnum, Enum: IEnumVariant;
  ovVar1, ovVar2: OleVariant; // 5.2
  lwValue: LongWord;

  errinfo: string;
  instances: integer;


  JQuery: TJSONObject;
  JArrayVal: TJSONArray;
begin
  Success := CoInitializeEx(nil, COINIT_MULTITHREADED); // CoInitialize(nil); //CoInitializeEx(nil, COINIT_MULTITHREADED);
  JArrayVal := TJSONArray.Create;
  errinfo := '';
  VarClear(ovVar1); // 5.2
  VarClear(ovVar2); // 5.2
  wmiLocator := TSWbemLocator.Create(Nil);
  try
    try
      wmiServices := wmiLocator.ConnectServer('localhost', FNameSpace, '', '', '', '', 0, nil);
      wmiObjectSet := wmiServices.ExecQuery(FWQL, 'WQL', wbemFlagReturnImmediately, nil);
      instances := wmiObjectSet.Count;
      if instances = 0 then
        exit;
      Enum := (wmiObjectSet._NewEnum) as IEnumVariant;
      while (Enum.Next(1, ovVar1, lwValue) = S_OK) do // 5.2
      begin
        wmiObject := IUnknown(ovVar1) as SWBemObject; // 5.2
        propSet := wmiObject.Properties_;
        propEnum := (propSet._NewEnum) as IEnumVariant;
        JQuery := TJSONObject.Create;
        while (propEnum.Next(1, ovVar2, lwValue) = S_OK) do
        begin
          wmiProp := IUnknown(ovVar2) as SWBemProperty;
          JQuery.AddPair(TJSONPair.Create(wmiProp.Name, TJSONString.Create(GetPropStr(wmiProp))));
          VarClear(ovVar2); // avoid mem leaks
        end;
        JArrayVal.AddElement(JQuery);
        VarClear(ovVar1);
      end;
      FTextRecord := JArrayVal.ToJSON;
      Synchronize(DoOnFinish);
    except
      VarClear(ovVar1);
      VarClear(ovVar2);
      FTextRecord := GetExceptMess(ExceptObject);
      Synchronize(DoOnError);
    end;
  finally
    JArrayVal.Free;
    wmiLocator.Free;
    case Success of
      S_OK, S_FALSE:
        CoUninitialize;
    end;
  end;
end;

procedure OpenQuery(WQL, Clase: string; OnError, OnFinish: TWMIQueryRes);
begin
  FThread := TWMIQueryThread.Create(Clase, 'root\CIMV2', WQL, OnError, OnFinish);
end;

end.
