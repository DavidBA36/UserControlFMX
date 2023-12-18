{
  -----------------------------------------------------------------------------
  Unit Name: UCBase
  Author:    QmD
  changed:   06-dez-2004
  Purpose:   Main Unit
  History:   included delphi 2005 support
  ----------------------------------------------------------------------------- }

(*

  Vesões do Delphi

  VER120 = Delphi4
  VER130 = Delphi5
  VER140 = Delphi6
  VER150 = Delphi7
  VER160 = Delphi8
  VER170 = BDS2005
  VER180 = BDS2006

*)

{$DEFINE DEPURACION}
unit FMX.UCBase;

interface

{$I 'UserControl.inc'}

uses
  FMX.ActnList, FMX.Types, FMX.Forms, FMX.Platform.Win, System.Types, System.DateUtils, System.Classes, FMX.Controls, Data.DB, FMX.Graphics,
  FMX.Menus, FMX.StdCtrls, FMX.TMSTaskDialog,
  System.SysUtils, FireDAC.Comp.Client, System.Variants, Winapi.Windows, System.UITypes,
  FireDAC.Stan.Param, FireDAC.Comp.Script, FMX.ExtCtrls, System.Math, FMX.Grid, FMX.Dialogs, FMX.EventLog,
  FMX.UcConsts_Language, FMX.UCDataInfo, FMX.UCSettings, FMX.UCMessages, FMX.UCMail,
  FireDAC.Stan.Option, FireDAC.Phys.FB, FireDAC.Stan.Error;

// Version
const
  UCVersion = '2.31 RC4';
  llBaixo = 0;
  llNormal = 1;
  llMedio = 2;
  llCritico = 3;

{$WARNINGS OFF}

type

  // Pensando em usar GUID para gerar a chave das tabelas !!!!
  TUCGUID = class
    // Creates and returns a new globally unique identifier
    class function NovoGUID: TGUID;
    // sometimes we need to have an "empty" value, like NULL
    class function EmptyGUID: TGUID;
    // Checks whether a Guid is EmptyGuid
    class function IsEmptyGUID(GUID: TGUID): Boolean;
    // Convert to string
    class function ToString(GUID: TGUID): String;
    // convert to quoted string
    class function ToQuotedString(GUID: TGUID): String;
    // return a GUID from string
    class function FromString(Value: String): TGUID;
    // Indicates whether two TGUID values are the same
    class function EqualGUIDs(GUID1, GUID2: TGUID): Boolean;
    // Creates and returns a new globally unique identifier string
    class function NovoGUIDString: String;
  end;
{$WARNINGS ON}

  TUCAboutVar = String;

  // classe para armazenar usuario logado = currentuser
  TUCCurrentUser = class(TComponent)
  private
  public
    UserID: Integer;
    Profile: Integer;
    Empresa: Integer;
    SelectedEmpresa: Integer;
    UserIDOld: Integer;
    NombreEmpresa: String;
    IdLogon: String;
    Ambito: String;
    UserName: String;
    UserLogin: String;
    WinLogin: string;
    UserDomain: string;
    UserSID: String;
    Password: String;
    PassLivre: String;
    Email: String;
    DateExpiration: TDateTime;
    EsMaster: Boolean;
    UserExpired: string;
    UserDaysExpired: Integer;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TUCUser = class(TPersistent) // armazenar menuitem ou action responsavel pelo controle de usuarios
  private
    FAction: TAction;
    FMenuItem: TMenuItem;
    FUsePrivilegedField: Boolean;
    FProtectAdministrator: Boolean;
    procedure SetAction(const Value: TAction);
    procedure SetMenuItem(const Value: TMenuItem);
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Action: TAction read FAction write SetAction;
    property MenuItem: TMenuItem read FMenuItem write SetMenuItem;
    property UsePrivilegedField: Boolean read FUsePrivilegedField write FUsePrivilegedField default False;
    property ProtectAdministrator: Boolean read FProtectAdministrator write FProtectAdministrator default True;
  end;

  TUCUserProfile = class(TPersistent) // armazenar menuitem ou action responsavel pelo Perfil de usuarios
  private
    FAtive: Boolean;
    FAction: TAction;
    FMenuItem: TMenuItem;
    procedure SetAction(const Value: TAction);
    procedure SetMenuItem(const Value: TMenuItem);
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Active: Boolean read FAtive write FAtive default True;
    property Action: TAction read FAction write SetAction;
    property MenuItem: TMenuItem read FMenuItem write SetMenuItem;
  end;

  TUCUserPasswordChange = class(TPersistent) // armazenar menuitem ou action responsavel pelo Form trocar senha
  private
    FForcePassword: Boolean;
    FMinPasswordLength: Integer;
    FAction: TAction;
    FMenuItem: TMenuItem;
    procedure SetAction(const Value: TAction);
    procedure SetMenuItem(const Value: TMenuItem);
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Action: TAction read FAction write SetAction;
    property MenuItem: TMenuItem read FMenuItem write SetMenuItem;
    property ForcePassword: Boolean read FForcePassword write FForcePassword default False;
    property MinPasswordLength: Integer read FMinPasswordLength write FMinPasswordLength default 0;
  end;

  TUCUserLogoff = class(TPersistent) // armazenar menuitem ou action responsavel pelo logoff
  private
    FAction: TAction;
    FMenuItem: TMenuItem;
    procedure SetAction(const Value: TAction);
    procedure SetMenuItem(const Value: TMenuItem);
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Action: TAction read FAction write SetAction;
    property MenuItem: TMenuItem read FMenuItem write SetMenuItem;
  end;

  TUCAutoLogin = class(TPersistent) // armazenar configuracao de Auto-Logon
  private
    FActive: Boolean;
    FUser: String;
    FPassword: String;
    FMessageOnError: Boolean;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Active: Boolean read FActive write FActive default False;
    property User: String read FUser write FUser;
    property Password: String read FPassword write FPassword;
    property MessageOnError: Boolean read FMessageOnError write FMessageOnError default True;
  end;

  TUCInitialLogin = class(TPersistent) // armazenar Dados do Login que sera criado na primeira execucao do programa.
  private
    FGroupName: String;
    FAlias: String;
    FUser: String;
    FPassword: String;
    FInitialRights: TStrings;
    FEmail: String;
    procedure SetInitialRights(const Value: TStrings);
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property GroupName: String read FGroupName write FGroupName;
    property Alias: String read FAlias write FAlias;
    property User: String read FUser write FUser;
    property Email: String read FEmail write FEmail;
    property Password: String read FPassword write FPassword;
    property InitialRights: TStrings read FInitialRights write SetInitialRights;
  end;

  TUCGetLoginName = (lnNone, lnUserName, lnMachineName);

  TUCLogin = class(TPersistent)
  private
    FAutoLogin: TUCAutoLogin;
    FMaxLoginAttempts: Integer;
    FInitialLogin: TUCInitialLogin;
    FGetLoginName: TUCGetLoginName;
    fCharCaseUser: TEditCharCase;
    fCharCasePass: TEditCharCase;
    fDateExpireActive: Boolean;
    fDaysOfSunExpired: Word;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property AutoLogin: TUCAutoLogin read FAutoLogin write FAutoLogin;
    property InitialLogin: TUCInitialLogin read FInitialLogin write FInitialLogin;
    property MaxLoginAttempts: Integer read FMaxLoginAttempts write FMaxLoginAttempts;
    property GetLoginName: TUCGetLoginName read FGetLoginName write FGetLoginName default lnNone;
    property CharCaseUser: TEditCharCase read fCharCaseUser write fCharCaseUser default TEditCharCase.ecNormal;
    property CharCasePass: TEditCharCase read fCharCasePass write fCharCasePass default TEditCharCase.ecNormal;
    property ActiveDateExpired: Boolean read fDateExpireActive write fDateExpireActive default False;
    property DaysOfSunExpired: Word read fDaysOfSunExpired write fDaysOfSunExpired default 30;
  end;

  TUCNotAllowedItems = class(TPersistent) // Ocultar e/ou Desabilitar os itens que o usuario nao tem acesso
  private
    FMenuVisible: Boolean;
    FActionVisible: Boolean;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property MenuVisible: Boolean read FMenuVisible write FMenuVisible default True;
    property ActionVisible: Boolean read FActionVisible write FActionVisible default True;
  end;

  TUCLogControl = class(TPersistent) // Responsavel pelo Controle de Log
  private
    FActive: Boolean;
    FTableLog: String;
    FAction: TAction;
    FMenuItem: TMenuItem;
    procedure SetAction(const Value: TAction);
    procedure SetMenuItem(const Value: TMenuItem);
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Active: Boolean read FActive write FActive default True;
    property TableLog: String read FTableLog write FTableLog;
    property Action: TAction read FAction write SetAction;
    property MenuItem: TMenuItem read FMenuItem write SetMenuItem;
  end;

  TUCControlRight = class(TPersistent) // Menu / ActionList/ActionManager ou ActionMainMenuBar a serem Controlados
  private
    FActionList: TActionList;
    FMainMenu: TMainMenu;
    procedure SetActionList(const Value: TActionList);
    procedure SetMainMenu(const Value: TMainMenu);
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property ActionList: TActionList read FActionList write SetActionList;
    property MainMenu: TMainMenu read FMainMenu write SetMainMenu;
  end;

  TOnAfterLogin = procedure(Sender: TObject; ClaveEmpresa, ClaveSelectedEmpresa: Integer) of object;
  TOnLogin = procedure(Sender: TObject; var User, Password: String) of object;
  TOnLoginSucess = procedure(Sender: TObject; IdUser: Integer; Usuario, Nome, Senha, Email: String; Privileged: Boolean) of object;
  TOnLoginError = procedure(Sender: TObject; Usuario, Senha: String) of object;
  TOnApplyRightsMenuItem = procedure(Sender: TObject; MenuItem: TMenuItem) of object;
  TOnApllyRightsActionItem = procedure(Sender: TObject; Action: TAction) of object;
  TCustomUserForm = procedure(Sender: TObject; var CustomForm: TCustomForm) of object;
  TCustomUserProfileForm = procedure(Sender: TObject; var CustomForm: TCustomForm) of object;
  TCustomLoginForm = procedure(Sender: TObject; var CustomForm: TCustomForm) of object;
  TCustomUserPasswordChangeForm = procedure(Sender: TObject; var CustomForm: TCustomForm) of object;
  TCustomLogControlForm = procedure(Sender: TObject; var CustomForm: TCustomForm) of object;
  TCustomInitialMessage = procedure(Sender: TObject; var CustomForm: TCustomForm; var Msg: TStrings) of object;
  TCustomUserLoggedForm = procedure(Sender: TObject; var CustomForm: TCustomForm) of object; // Cesar: 13/07/2005
  TOnAddUser = procedure(Sender: TObject; var Login, Password, Name, Mail: String; var Profile: Integer; var Privuser: Boolean) of object;
  TOnChangeUser = procedure(Sender: TObject; IdUser: Integer; var Login, Name, Mail: String; var Profile: Integer; var Privuser: Boolean) of object;
  TOnDeleteUser = procedure(Sender: TObject; IdUser: Integer; var CanDelete: Boolean; var ErrorMsg: String) of object;
  TOnAddProfile = procedure(Sender: TObject; var Profile: String) of object;
  TOnDeleteProfile = procedure(Sender: TObject; IDProfile: Integer; var CanDelete: Boolean; var ErrorMsg: String) of object;
  TOnChangePassword = procedure(Sender: TObject; IdUser: Integer; Login, CurrentPassword, NewPassword: String) of object;
  TOnLogoff = procedure(Sender: TObject; IdUser: Integer) of object;
  TOnDebug = procedure(DebugMessage: string) of object;

  TUCExtraRights = class;
  TUCExecuteThread = class;
  TFMXUCApplicationMessage = class;
  TFMXUCControls = class;
  TUCUsersLogged = class; // Cesar: 12/07/2005

  TUCLoginMode = (lmActive, lmPassive);
  TUCCriptografia = (cPadrao, cMD5);

  TFMXUserControl = class(TComponent) // Classe principal
  private
    FCurrentUser: TUCCurrentUser;
    TaskDialog: TTMSFMXTaskDialog;
    FUserSettings: TUCUserSettings;
    FApplicationID: String;
    FNotAllowedItems: TUCNotAllowedItems;
    FOnLogin: TOnLogin;
    FOnStartApplication: TNotifyEvent;
    FOnLoginError: TOnLoginError;
    FOnLoginSucess: TOnLoginSucess;
    FOnApplyRightsActionIt: TOnApllyRightsActionItem;
    FOnApplyRightsMenuIt: TOnApplyRightsMenuItem;
    FLogControl: TUCLogControl;
    FEncrytKey: Word;
    FUser: TUCUser;
    FLogin: TUCLogin;
    FUserProfile: TUCUserProfile;
    FUserPasswordChange: TUCUserPasswordChange;
    FControlRight: TUCControlRight;
    FOnCustomCadUsuarioForm: TCustomUserForm;
    FCustomLogControlForm: TCustomLogControlForm;
    FCustomLoginForm: TCustomLoginForm;
    FCustomPerfilUsuarioForm: TCustomUserProfileForm;
    FCustomTrocarSenhaForm: TCustomUserPasswordChangeForm;
    FOnAddProfile: TOnAddProfile;
    FOnAddUser: TOnAddUser;
    FOnChangePassword: TOnChangePassword;
    FOnChangeUser: TOnChangeUser;
    FOnDeleteProfile: TOnDeleteProfile;
    FOnDeleteUser: TOnDeleteUser;
    FOnLogoff: TOnLogoff;
    FCustomInicialMsg: TCustomInitialMessage;
    FAbout: TUCAboutVar;
    FFormStorageRegRoot: string;
    FExtraRights: TUCExtraRights;
    FThUCRun: TUCExecuteThread;
    FDebug: TOnDebug;
    FAutoStart: Boolean;
    FTableRights: TUCTableRights;
    FTableUsers: TUCTableUsers;
    FLoginMode: TUCLoginMode;
    FControlList: TList;
    FConnection: TFDConnection;
    FUserPreferencesConnection: TFDConnection;
    FLoginMonitorList: TList;
    FAfterLogin: TOnAfterLogin;
    FCheckValidationKey: Boolean;
    FCriptografia: TUCCriptografia;
    FUsersLogged: TUCUsersLogged;
    FTableUsersLogged: TUCTableUsersLogged;
    FUsersLogoff: TUCUserLogoff;
    FFormParent: TForm;
    fLanguage: TUCLanguage;
    FMailUserControl: TFMXMailUserControl;
    FMasterTransaccion: TFDTransaction;
    procedure SetExtraRights(Value: TUCExtraRights);
    procedure ActionCadUser(Sender: TObject);
    procedure ActionTrocaSenha(Sender: TObject);
    procedure ActionOKLogin(Sender: TObject);
    procedure TestaFecha(Sender: TObject; var CanClose: Boolean);
    procedure ApplySettings(SourceSettings: TFMXUCSettings);
    procedure UnlockEX(FormObj: TCustomForm; ObjName: String);
    procedure LockEX(FormObj: TCustomForm; ObjName: String; naInvisible: Boolean);
    procedure SetConnection(const AValue: TFDConnection);
    procedure SetUserPreferencesConnection(const AValue: TFDConnection);
    procedure SetfLanguage(const Value: TUCLanguage);
    procedure SetFMailUserControl(const Value: TFMXMailUserControl);
    procedure ActionOlvidaPassword(Sender: TObject);
    procedure ActionAsistenteUsuario(Sender: TObject);
  protected
    FRetry: Integer;
    // Formulários
    FFormTrocarSenha: TCustomForm;

    // -----

    procedure Loaded; override;
    // Criar Formulários
    procedure CriaFormTrocarSenha; dynamic;
    // -----

    procedure ActionLogoff(Sender: TObject); dynamic;
    procedure ActionTSBtGrava(Sender: TObject);
    procedure SetUserSettings(const Value: TUCUserSettings);
    procedure SetfrmLoginWindow(Form: TCustomForm);
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    procedure RegistraCurrentUser(User: Integer; Granted: Boolean);
    // procedure ApplyRightsObj(ADataset: TDataSet; FProfile: Boolean = False);
    procedure ShowLogin;

    // Criar Tabelas
    procedure CriaTabelaLog;
    procedure CriaTabelaRights(ExtraRights: Boolean = False);
    procedure CriaTabelaUsuarios(TableExists: Boolean);
    procedure CriaTabelaMsgs(const TableName: String);
    // -----

    // Atualiza Versao
    // procedure AtualizarVersao;
    // --------
    // procedure TryAutoLogon;
    procedure AddUCControlMonitor(UCControl: TFMXUCControls);
    procedure DeleteUCControlMonitor(UCControl: TFMXUCControls);
    procedure ApplyRightsUCControlMonitor;
    procedure LockControlsUCControlMonitor;
    procedure AddLoginMonitor(UCAppMessage: TFMXUCApplicationMessage);
    procedure DeleteLoginMonitor(UCAppMessage: TFMXUCApplicationMessage);
    procedure NotificationLoginMonitor;
    procedure ShowNewConfig;

  public
    procedure SetAjustesMailPorDefecto;
    procedure ComprobarMaster;
    procedure Logoff;
    procedure Execute;
    procedure StartLogin;
    procedure ShowChangePassword;
    procedure WriteAccessAction(Accion: string);
    procedure ChangePassword(FDTMaster: TFDTransaction; IdUser: Integer; NewPassword: String);
    procedure HideField(Sender: TField; var Text: String; DisplayText: Boolean);
    procedure Log(Msg: String; Level: Integer = llNormal);
    function VerificaLogin(User, Password: String; Empresa: Integer; SetteaPass: Boolean = True): Integer; // Boolean;
    procedure ApplyRights;
    procedure SendDebug(const asunto, s: String);
    property CurrentUser: TUCCurrentUser read FCurrentUser write FCurrentUser;
    property UserSettings: TUCUserSettings read FUserSettings write SetUserSettings;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property About: TUCAboutVar read FAbout write FAbout;
    property Criptografia: TUCCriptografia read FCriptografia write FCriptografia default cPadrao;
    property AutoStart: Boolean read FAutoStart write FAutoStart default False;
    property ApplicationID: String read FApplicationID write FApplicationID;
    property ControlRight: TUCControlRight read FControlRight write FControlRight;
    // Controle dos formularios
    property User: TUCUser read FUser write FUser;
    property UserProfile: TUCUserProfile read FUserProfile write FUserProfile;
    property UserPasswordChange: TUCUserPasswordChange read FUserPasswordChange write FUserPasswordChange;
    property UsersLogged: TUCUsersLogged read FUsersLogged write FUsersLogged;
    property UsersLogoff: TUCUserLogoff read FUsersLogoff write FUsersLogoff;
    property LogControl: TUCLogControl read FLogControl write FLogControl;
    property OnDebug: TOnDebug read FDebug write FDebug;
    property MailUserControl: TFMXMailUserControl read FMailUserControl write SetFMailUserControl;
    property FormStorageRegRoot: string read FFormStorageRegRoot write FFormStorageRegRoot;

    property Language: TUCLanguage read fLanguage write SetfLanguage;

    property EncryptKey: Word read FEncrytKey write FEncrytKey;
    property NotAllowedItems: TUCNotAllowedItems read FNotAllowedItems write FNotAllowedItems;
    property Login: TUCLogin read FLogin write FLogin;
    property ExtraRights: TUCExtraRights read FExtraRights write SetExtraRights;
    property LoginMode: TUCLoginMode read FLoginMode write FLoginMode default lmActive;
    // Tabelas
    property TableUserGroups: TUCTableUsers read FTableUsers write FTableUsers;
    property TableGroups: TUCTableUsers read FTableUsers write FTableUsers;
    property TableUsers: TUCTableUsers read FTableUsers write FTableUsers;
    property TableRights: TUCTableRights read FTableRights write FTableRights;
    property TableUsersLogged: TUCTableUsersLogged read FTableUsersLogged write FTableUsersLogged;
    property Connection: TFDConnection read FConnection write SetConnection;
    property UserPreferencesConnection: TFDConnection read FUserPreferencesConnection write SetUserPreferencesConnection;
    property CheckValidationKey: Boolean read FCheckValidationKey write FCheckValidationKey default False;
    // Eventos
    property OnLogin: TOnLogin read FOnLogin write FOnLogin;
    property OnStartApplication: TNotifyEvent read FOnStartApplication write FOnStartApplication;
    property OnLoginSucess: TOnLoginSucess read FOnLoginSucess write FOnLoginSucess;
    property OnLoginError: TOnLoginError read FOnLoginError write FOnLoginError;
    property OnApplyRightsMenuIt: TOnApplyRightsMenuItem read FOnApplyRightsMenuIt write FOnApplyRightsMenuIt;
    property OnApplyRightsActionIt: TOnApllyRightsActionItem read FOnApplyRightsActionIt write FOnApplyRightsActionIt;
    property OnCustomUsersForm: TCustomUserForm read FOnCustomCadUsuarioForm write FOnCustomCadUsuarioForm;
    property OnCustomUsersProfileForm: TCustomUserProfileForm read FCustomPerfilUsuarioForm write FCustomPerfilUsuarioForm;
    property OnCustomLoginForm: TCustomLoginForm read FCustomLoginForm write FCustomLoginForm;
    property OnCustomChangePasswordForm: TCustomUserPasswordChangeForm read FCustomTrocarSenhaForm write FCustomTrocarSenhaForm;
    property OnCustomLogControlForm: TCustomLogControlForm read FCustomLogControlForm write FCustomLogControlForm;
    property OnCustomInitialMsg: TCustomInitialMessage read FCustomInicialMsg write FCustomInicialMsg;
    property OnCustomUserLoggedForm: TCustomUserForm read FOnCustomCadUsuarioForm write FOnCustomCadUsuarioForm; // Cesar: 13/07/2005
    property OnAddUser: TOnAddUser read FOnAddUser write FOnAddUser;
    property OnChangeUser: TOnChangeUser read FOnChangeUser write FOnChangeUser;
    property OnDeleteUser: TOnDeleteUser read FOnDeleteUser write FOnDeleteUser;
    property OnAddProfile: TOnAddProfile read FOnAddProfile write FOnAddProfile;
    property OnDeleteProfile: TOnDeleteProfile read FOnDeleteProfile write FOnDeleteProfile;
    property OnChangePassword: TOnChangePassword read FOnChangePassword write FOnChangePassword;
    property OnLogoff: TOnLogoff read FOnLogoff write FOnLogoff;
    property OnAfterLogin: TOnAfterLogin read FAfterLogin write FAfterLogin;
  end;

  TUCExtraRightsItem = class(TCollectionItem)
  private
    FFormName: String;
    FCompName: String;
    FCaption: String;
    FGroupName: String;
    procedure SetFormName(const Value: String);
    procedure SetCompName(const Value: String);
    procedure SetCaption(const Value: String);
    procedure SetGroupName(const Value: String);
  protected
    function GetDisplayName: String; override;
  public
  published
    property Formulario: String read FFormName write SetFormName;
    property Componente: String read FCompName write SetCompName;
    property Caption: String read FCaption write SetCaption;
    property GroupName: String read FGroupName write SetGroupName;
  end;

  TUCExtraRights = class(TCollection)
  private
    FUCBase: TFMXUserControl;
    function GetItem(Index: Integer): TUCExtraRightsItem;
    procedure SetItem(Index: Integer; Value: TUCExtraRightsItem);
  protected
    function GetOwner: TPersistent; override;
  public
    constructor Create(UCBase: TFMXUserControl);
    function Add: TUCExtraRightsItem;
    procedure Sort;
    property Items[Index: Integer]: TUCExtraRightsItem read GetItem write SetItem; default;
  end;

  TUCVerificaMensagemThread = class(TThread)
  private
    FAOwner: TComponent;
    procedure VerNovaMansagem;
  public
    constructor Create(CreateSuspended: Boolean; AOwner: TComponent);
    destructor Destroy; override;
  protected
    procedure Execute; override;

  end;

  TUCExecuteThread = class(TThread)
  private
    FAOwner: TComponent;
    procedure UCStart;
  public
    constructor Create(CreateSuspended: Boolean; AOwner: TComponent);
    destructor Destroy; override;
  protected
    procedure Execute; override;
  end;

  TFMXUCApplicationMessage = class(TComponent)
  private
    FActive: Boolean;
    FReady: Boolean;
    FInterval: Integer;
    FUserControl: TFMXUserControl;
    FVerifThread: TUCVerificaMensagemThread;
    FTableMessages: String;
    procedure SetActive(const Value: Boolean);
    procedure SeTFMXUserControl(const Value: TFMXUserControl);
  protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ShowMessages(Modal: Boolean = True);
    procedure SendAppMessage(ToUser: Integer; Subject, Msg: String);
    procedure DeleteAppMessage(IdMsg: Integer);
    procedure CheckMessages;
  published
    property Active: Boolean read FActive write SetActive;
    property Interval: Integer read FInterval write FInterval;
    property TableMessages: String read FTableMessages write FTableMessages;
    property UserControl: TFMXUserControl read FUserControl write SeTFMXUserControl;
  end;

  TUCComponentsVar = String;

  TUCNotAllowed = (naInvisible, naDisabled);

  TFMXUCControls = class(TComponent)
  private
    FGroupName: String;
    FComponents: TUCComponentsVar;
    FUserControl: TFMXUserControl;
    FNotAllowed: TUCNotAllowed;
    function GetAccessType: String;
    function GetActiveForm: String;
    procedure SetGroupName(const Value: String);
    procedure SeTFMXUserControl(const Value: TFMXUserControl);
  protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
  public
    destructor Destroy; override;
    procedure ApplyRights;
    procedure LockControls;
    procedure ListComponents(Form: String; List: TStringList);
  published
    property AccessType: String read GetAccessType;
    property ActiveForm: String read GetActiveForm;
    property GroupName: String read FGroupName write SetGroupName;
    property UserControl: TFMXUserControl read FUserControl write SeTFMXUserControl;
    property Components: TUCComponentsVar read FComponents write FComponents;
    property NotAllowed: TUCNotAllowed read FNotAllowed write FNotAllowed default naInvisible;
  end;

  TUCUsersLogged = class(TPersistent)
    // Cesar: 12/07/2005: classe que armazena os usuarios logados no sistema
  private
    FUserControl: TFMXUserControl;
    FAtive: Boolean;
    procedure AddCurrentUser;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure DelCurrentUser;
    procedure CriaTableUserLogado;
    function UsuarioJaLogado(ID: Integer): Boolean;
  published
    property Active: Boolean read FAtive write FAtive default True;
  end;

implementation

{$R UCLock.res}
{$R MessageFile\MessageFile.res}

uses
  FMX.UCHelpers, FMX.LoginWindow_U, FMX.TrocaSenha_U, FMX.pUCGeral, FMX.UserPermis_U; // FMX.MsgRecForm_U, FMX.MsgsForm_U, , , , ;

{$IFDEF DELPHI9_UP} {$REGION 'TFMXUserControl'} {$ENDIF}
{ TFMXUserControl }

constructor TFMXUserControl.Create(AOwner: TComponent);
begin
  inherited;
  if AOwner is TForm then
    FFormParent := TForm(AOwner);
  TaskDialog := TTMSFMXTaskDialog.Create(Self);
  FCurrentUser := TUCCurrentUser.Create(Self);
  FControlRight := TUCControlRight.Create(Self);
  FLogin := TUCLogin.Create(Self);
  FLogControl := TUCLogControl.Create(Self);
  FUser := TUCUser.Create(Self);
  FUserProfile := TUCUserProfile.Create(Self);
  FUserPasswordChange := TUCUserPasswordChange.Create(Self);
  FUsersLogged := TUCUsersLogged.Create(Self);
  FUsersLogoff := TUCUserLogoff.Create(Self);
  FUserSettings := TUCUserSettings.Create(Self);
  FNotAllowedItems := TUCNotAllowedItems.Create(Self);
  FExtraRights := TUCExtraRights.Create(Self);
  FTableUsers := TUCTableUsers.Create(Self);
  FTableRights := TUCTableRights.Create(Self);
  FTableUsersLogged := TUCTableUsersLogged.Create(Self);
  FMasterTransaccion := TFDTransaction.Create(Self);

  // TEventLog.Source := 'GVenaUserControl';
  // TEventLog.AddEventSourceToRegistry;
  if csDesigning in ComponentState then
  begin
    with TableUsers do
    begin
      if TableName = '' then
        TableName := RetornaLingua(fLanguage, 'Const_TableUsers_TableName');
      if FieldUserID = '' then
        FieldUserID := RetornaLingua(fLanguage, 'Const_TableUsers_FieldUserID');
      if FieldUserName = '' then
        FieldUserName := RetornaLingua(fLanguage, 'Const_TableUsers_FieldUserName');
      if FieldLogin = '' then
        FieldLogin := RetornaLingua(fLanguage, 'Const_TableUsers_FieldLogin');
      if FieldPassword = '' then
        FieldPassword := RetornaLingua(fLanguage, 'Const_TableUsers_FieldPassword');
      if FieldEmail = '' then
        FieldEmail := RetornaLingua(fLanguage, 'Const_TableUsers_FieldEmail');
      if FieldPrivileged = '' then
        FieldPrivileged := RetornaLingua(fLanguage, 'Const_TableUsers_FieldPrivileged');
      if FieldTypeRec = '' then
        FieldTypeRec := RetornaLingua(fLanguage, 'Const_TableUsers_FieldTypeRec');
      if FieldProfile = '' then
        FieldProfile := RetornaLingua(fLanguage, 'Const_TableUsers_FieldProfile');
      if FieldKey = '' then
        FieldKey := RetornaLingua(fLanguage, 'Const_TableUsers_FieldKey');

      if FieldDateExpired = '' then
        FieldDateExpired := RetornaLingua(fLanguage, 'Const_TableUsers_FieldDateExpired');

      if FieldUserExpired = '' then
        FieldUserExpired := RetornaLingua(fLanguage, 'Const_TableUser_FieldUserExpired');

      if FieldUserDaysSun = '' then
        FieldUserDaysSun := RetornaLingua(fLanguage, 'Const_TableUser_FieldUserDaysSun');

      if FieldUserInative = '' then
        FieldUserInative := RetornaLingua(fLanguage, 'Const_TableUser_FieldUserInative');
    end;

    with TableRights do
    begin
      if TableName = '' then
        TableName := RetornaLingua(fLanguage, 'Const_TableRights_TableName');
      if FieldUserID = '' then
        FieldUserID := RetornaLingua(fLanguage, 'Const_TableRights_FieldUserID');
      if FieldModule = '' then
        FieldModule := RetornaLingua(fLanguage, 'Const_TableRights_FieldModule');
      if FieldComponentName = '' then
        FieldComponentName := RetornaLingua(fLanguage, 'Const_TableRights_FieldComponentName');
      if FieldFormName = '' then
        FieldFormName := RetornaLingua(fLanguage, 'Const_TableRights_FieldFormName');
      if FieldKey = '' then
        FieldKey := RetornaLingua(fLanguage, 'Const_TableRights_FieldKey');
    end;

    with TableUsersLogged do
    begin
      if TableName = '' then
        TableName := RetornaLingua(fLanguage, 'Const_TableUsersLogged_TableName');
      if FieldLogonID = '' then
        FieldLogonID := RetornaLingua(fLanguage, 'Const_TableUsersLogged_FieldLogonID');
      if FieldUserID = '' then
        FieldUserID := RetornaLingua(fLanguage, 'Const_TableUsersLogged_FieldUserID');
      if FieldApplicationID = '' then
        FieldApplicationID := RetornaLingua(fLanguage, 'Const_TableUsersLogged_FieldApplicationID');
      if FieldMachineName = '' then
        FieldMachineName := RetornaLingua(fLanguage, 'Const_TableUsersLogged_FieldMachineName');
      if FieldData = '' then
        FieldData := RetornaLingua(fLanguage, 'Const_TableUsersLogged_FieldData');
    end;

    if LogControl.TableLog = '' then
      LogControl.TableLog := 'UCLog';
    if ApplicationID = '' then
      ApplicationID := 'ProjetoNovo';
    if Login.InitialLogin.User = '' then
      Login.InitialLogin.User := 'admin';
    if Login.InitialLogin.Password = '' then
      Login.InitialLogin.Password := '123mudar';
    if Login.InitialLogin.Email = '' then
      Login.InitialLogin.Email := 'usercontrol@usercontrol.net';

    FLoginMode := lmActive;
    FCriptografia := cPadrao;
    FAutoStart := False;
    FUserProfile.Active := True;
    FLogControl.Active := True;
    FUser.UsePrivilegedField := False;
    FUser.ProtectAdministrator := True;
    FUsersLogged.Active := True;
    NotAllowedItems.MenuVisible := True;
    NotAllowedItems.ActionVisible := True;
  end
  else
  begin
    FControlList := TList.Create;
    FLoginMonitorList := TList.Create;
  end;

  FMX.UCSettings.IniSettings(UserSettings);
end;
{$WARNINGS OFF}

procedure TFMXUserControl.SendDebug(const asunto, s: String);
begin
  if Assigned(FDebug) then
    FDebug(#13#10 + asunto + ':' + s);
end;

procedure TFMXUserControl.SetConnection(const AValue: TFDConnection);
begin
  if FConnection <> AValue then
  begin
    FConnection := AValue;
    with FMasterTransaccion do
    begin
      Connection := FConnection;
      Options.AutoStart := False;
      Options.AutoCommit := False;
      Options.AutoStop := False;
      Options.DisconnectAction := xdRollback;
    end;
  end;
end;

procedure TFMXUserControl.SetUserPreferencesConnection(const AValue: TFDConnection);
begin
  if FUserPreferencesConnection <> AValue then
    FUserPreferencesConnection := AValue;
end;

procedure TFMXUserControl.SetAjustesMailPorDefecto;
var
  Q: TFDQuery;
const

  PassOlvidado = '<html>' + #10 + #9 + '<head>' + #10 + #9 + #9 + '<title>Cambio de contrase&ntilde;a</title>' + #10 + #9 + '</head>' + #10 + #9 +
    '<body>' + #10 + #9 + #9 +
    '<p>Antenci&oacute;n:<br><br>Ha solicitado un cambio de su contrase&ntilde;a olvidada. Su contrase&ntilde;a fue cambiada por la que se indica a continuaci&oacute;n:</p>'
    + #10 + #9 + #9 + '<table width="100%" border="0" cellspacing="2" cellpadding="0">' + #10 + #9 + #9 + #9 + '<tr>' + #10 + #9 + #9 + #9 + #9 +
    '<td width="15%" align="right"><strong>Nombre ..:&nbsp;</strong></td>' + #10 + #9 + #9 + #9 + #9 + '<td>:nombre</td>' + #10 + #9 + #9 + #9 +
    '</tr><tr>' + #10 + #9 + #9 + #9 + #9 + '<td align="right"><strong>Login ..:&nbsp;</strong></td>' + #10 + #9 + #9 + #9 + #9 + '<td>:login</td>' +
    #10 + #9 + #9 + #9 + '</tr><tr>' + #10 + #9 + #9 + #9 + #9 + '<td align="right"><strong>Nueva Contrase&ntilde;a ..:&nbsp;</strong></td>' + #10 +
    #9 + #9 + #9 + #9 + '<td>:password</td>' + #10 + #9 + #9 + #9 + '</tr><tr>' + #10 + #9 + #9 + #9 + #9 +
    '<td align="right"><strong>Email ..:&nbsp;</strong></td>' + #10 + #9 + #9 + #9 + #9 + '<td>:email</td>' + #10 + #9 + #9 + #9 + '</tr><tr>' + #10 +
    #9 + #9 + #9 + #9 + '<td align="right"><strong>Empresa ..:&nbsp;</strong></td>' + #10 + #9 + #9 + #9 + #9 + '<td>:empresa</td>' + #10 + #9 + #9 +
    #9 + '</tr>' + #10 + #9 + #9 + '</table>' + #10 + #9 + #9 +
    '<p>Esta contrase&ntilde;a es temporal y debe cambiarla, ya que caducar&aacute; pasadas 24 horas naturales. </p>' + #10 + #9 + #9 +
    '<p>Atentamente,</p>' + #10 + #9 + #9 + '<p>Administrador del sistema</p>' + #10 + #9 + '</body>' + #10 + '</html>';

  PassForzado = '<html>' + #10 + #9 + '<head>' + #10 + #9 + #9 + '<title>Cambio de contrase&ntilde;a forzoso</title>' + #10 + #9 + '</head>' + #10 +
    #9 + '<body>' + #10 + #9 + #9 +
    '<p>Atenci&oacute;n:<br><br>El usuario :user(:cargo) ha cambiado su contrase&ntilde;a. Fue cambiada por la que sigue:</p>' + #10 + #9 + #9 +
    '<table width="100%" border="0" cellspacing="2" cellpadding="0">' + #10 + #9 + #9 + #9 + '<tr>' + #10 + #9 + #9 + #9 + #9 +
    '<td width="10%" align="right"><strong>Nome ..:&nbsp;</strong></td>' + #10 + #9 + #9 + #9 + #9 + '<td>:nombre</td>' + #10 + #9 + #9 + #9 +
    '</tr><tr>' + #10 + #9 + #9 + #9 + #9 + '<td align="right"><strong>Login ..:&nbsp;</strong></td>' + #10 + #9 + #9 + #9 + #9 + '<td>:login</td>' +
    #10 + #9 + #9 + #9 + '</tr><tr>' + #10 + #9 + #9 + #9 + #9 + '<td align="right"><strong>Nueva Contrase&ntilde;a ..:&nbsp;</strong></td>' + #10 +
    #9 + #9 + #9 + #9 + '<td>:password</td>' + #10 + #9 + #9 + #9 + '</tr><tr>' + #10 + #9 + #9 + #9 + #9 +
    '<td align="right"><strong>Email ..:&nbsp;</strong></td>' + #10 + #9 + #9 + #9 + #9 + '<td>:email</td>' + #10 + #9 + #9 + #9 + '</tr><tr>' + #10 +
    #9 + #9 + #9 + #9 + '<td align="right"><strong>Empresa ..:&nbsp;</strong></td>' + #10 + #9 + #9 + #9 + #9 + '<td>:empresa</td>' + #10 + #9 + #9 +
    #9 + '</tr>' + #10 + #9 + #9 + '</table>' + #10 + #9 + #9 + '<p>Atentatmente</p>' + #10 + #9 + #9 + '<p>Administrador del sistema</p>' + #10 + #9
    + '</body>' + #10 + '</html>';

  PassCambiado = '<html>' + #10 + #9 + '<head>' + #10 + #9 + #9 + '<title>Cambio de contrase&ntilde;a</title>' + #10 + #9 + '</head>' + #10 + #9 +
    '<body>' + #10 + #9 + #9 + '<p>Atenci&oacute;n:<br><br>Tu petici&oacute;n de cambio de constraseña se ha procesado correctamente:</p>' + #10 + #9
    + #9 + '<table width="100%" border="0" cellspacing="2" cellpadding="0">' + #10 + #9 + #9 + #9 + '<tr>' + #10 + #9 + #9 + #9 + #9 +
    '<td width="10%" align="right"><strong>Nombre ..:&nbsp;</strong></td>' + #10 + #9 + #9 + #9 + #9 + '<td>:nombre</td>' + #10 + #9 + #9 + #9 +
    '</tr><tr>' + #10 + #9 + #9 + #9 + #9 + '<td align="right"><strong>Login ..:&nbsp;</strong></td>' + #10 + #9 + #9 + #9 + #9 + '<td>:login</td>' +
    #10 + #9 + #9 + #9 + '</tr><tr>' + #10 + #9 + #9 + #9 + #9 + '<td align="right"><strong>Nueva Contrase&ntilde;a ..:&nbsp;</strong></td>' + #10 +
    #9 + #9 + #9 + #9 + '<td>:password</td>' + #10 + #9 + #9 + #9 + '</tr><tr>' + #10 + #9 + #9 + #9 + #9 +
    '<td align="right"><strong>Email ..:&nbsp;</strong></td>' + #10 + #9 + #9 + #9 + #9 + '<td>:email</td>' + #10 + #9 + #9 + #9 + '</tr><tr>' + #10 +
    #9 + #9 + #9 + #9 + '<td align="right"><strong>Empresa ..:&nbsp;</strong></td>' + #10 + #9 + #9 + #9 + #9 + '<td>:empresa</td>' + #10 + #9 + #9 +
    #9 + '</tr>' + #10 + #9 + #9 + '</table>' + #10 + #9 + #9 + '<p>Atentatmente</p>' + #10 + #9 + #9 + '<p>Administrador del sistema</p>' + #10 + #9
    + '</body>' + #10 + '</html>';
begin
{$IFDEF DEPURACION}
  SendDebug('SetAjustesMailPorDefecto', 'started at ' + DateTimeToStrUs(now));
{$ENDIF}
  Q := TFDQuery.Create(nil);
  try
    try
      Q.Connection := FConnection;
      Q.Transaction := FMasterTransaccion;
      if not Q.Transaction.Active then
        Q.Transaction.StartTransaction;
      with Q do
      begin
        // GRUPO MASTER
        SQL.Clear;
        SQL.Add('INSERT INTO INT$UC_EMAIL ');
        SQL.Add('(PASS_OLVIDADO_BODY,PASS_FORZADO_BODY,PASS_CAMBIADO_BODY,USER_CAMBIADO_BODY,USER_AGREGADO_BODY,REMITENTE,SERVIDOR,USER_LOGIN,PASS,PASS_OLVIDADO_ASUNTO,');
        SQL.Add('PASS_FORZADO_ASUNTO,PASS_CAMBIADO_ASUNTO,USER_CAMBIADO_ASUNTO,USER_AGREGADO_ASUNTO,ACTIVO,USA_STARTTLS,PUERTO) ');

        SQL.Add('VALUES (:PASS_OLVIDADO_BODY,:PASS_FORZADO_BODY,:PASS_CAMBIADO_BODY,:USER_CAMBIADO_BODY,:USER_AGREGADO_BODY,');
        SQL.Add(':REMITENTE,:SERVIDOR,:USER_LOGIN,:PASS,:PASS_OLVIDADO_ASUNTO,:PASS_FORZADO_ASUNTO,:PASS_CAMBIADO_ASUNTO,');
        SQL.Add(':USER_CAMBIADO_ASUNTO,:USER_AGREGADO_ASUNTO,:ACTIVO,:USA_STARTTLS,:PUERTO)');

        ParamByName('PASS_OLVIDADO_BODY').AsString := PassOlvidado;
        ParamByName('PASS_FORZADO_BODY').AsString := PassForzado;
        ParamByName('PASS_CAMBIADO_BODY').AsString := PassCambiado;
        ParamByName('USER_CAMBIADO_BODY').AsString := '';
        ParamByName('USER_AGREGADO_BODY').AsString := '';
        ParamByName('REMITENTE').AsString := 'gvena.notificaciones@emite.net';
        ParamByName('SERVIDOR').AsString := 'smtp.emite.net';
        ParamByName('USER_LOGIN').AsString := '';
        ParamByName('PASS').AsString := '';
        ParamByName('PASS_OLVIDADO_ASUNTO').AsString := 'Recuperación de contraseña';
        ParamByName('PASS_FORZADO_ASUNTO').AsString := 'Cambio de contraseña forzoso';
        ParamByName('PASS_CAMBIADO_ASUNTO').AsString := 'Cambio de contraseña';
        ParamByName('USER_CAMBIADO_ASUNTO').AsString := '';
        ParamByName('USER_AGREGADO_ASUNTO').AsString := '';
        ParamByName('ACTIVO').AsString := 'TRUE';
        ParamByName('USA_STARTTLS').AsString := 'TRUE';
        ParamByName('PUERTO').AsInteger := 25;
        ExecSQL;
        if Q.Transaction.Active then
          Q.Transaction.Commit;
      end;
    except
      on e: Exception do
      begin
        SendDebug('TFMXUserControl.SetAjustesMailPorDefecto exception', e.Message);
        if Q.Transaction.Active then
          Q.Transaction.Rollback;
      end;
    end;
  finally
    Q.Free;
{$IFDEF DEPURACION}
    SendDebug('SetAjustesMailPorDefecto', 'done at ' + DateTimeToStrUs(now));
{$ENDIF}
  end;
end;

procedure TFMXUserControl.ComprobarMaster;
var
  Q: TFDQuery;
  CGrupo, CUser, i: Integer;
  MI: TMenuItem;
begin
{$IFDEF DEPURACION}
  SendDebug('ComprobarMaster', 'started at ' + DateTimeToStrUs(now));
{$ENDIF}
  Q := TFDQuery.Create(nil);
  try
    try
      Q.Connection := FConnection;
      Q.Transaction := FMasterTransaccion;
      if not Q.Transaction.Active then
        Q.Transaction.StartTransaction;
      with Q do
      begin
        // GRUPO MASTER
        SQL.Clear;
        SQL.Add('UPDATE OR INSERT INTO INT$UC_GROUPS ');
        SQL.Add('(UC_NOMBRE,UC_DESCRIPCION,UC_COLOR) ');
        SQL.Add('VALUES(:UC_NOMBRE,:UC_DESCRIPCION,:UC_COLOR) ');
        SQL.Add('MATCHING (UC_NOMBRE) ');
        SQL.Add('RETURNING CLAVE ');
        ParamByName('UC_NOMBRE').AsString := Self.Login.InitialLogin.GroupName;
        ParamByName('UC_DESCRIPCION').AsString := 'Grupo para la gestión de funciones basicas';
        ParamByName('UC_COLOR').AsString := 'clLime';
        Open;
        CGrupo := FieldByName('CLAVE').AsInteger;
        Close;
        // SETEA KEY
        SQL.Clear;
        SQL.Add('UPDATE INT$UC_GROUPS ');
        SQL.Add('SET UKEY = :VUCKEY ');
        SQL.Add('WHERE CLAVE = :PCLAVE ');
        ParamByName('PCLAVE').AsInteger := CGrupo;
        ParamByName('VUCKEY').AsString := GetKeyTGrupo(CGrupo, 0, Self.Login.InitialLogin.GroupName);
        ExecSQL;
        // PERMISOS MENUS
        SQL.Clear;
        SQL.Add('UPDATE OR INSERT INTO INT$UC_RIGHTS ');
        SQL.Add('(CLAVE_GROUP,MODULO,COMPONENTE,KEY) ');
        SQL.Add('VALUES(:CLAVE_GROUP,:MODULO,:COMPONENTE,:KEY) ');
        SQL.Add('MATCHING (CLAVE_GROUP,MODULO,COMPONENTE) ');
        for MI in AllItems(ControlRight.MainMenu) do
        begin
          ParamByName('CLAVE_GROUP').AsInteger := CGrupo;
          ParamByName('MODULO').AsString := ApplicationID;
          ParamByName('COMPONENTE').AsString := MI.Name;
          ParamByName('KEY').AsString := GetKeyTPermisos(CGrupo, MI.Name);
          ExecSQL;
        end;
        // PERMISOS EXTRA
        SQL.Clear;
        SQL.Add('UPDATE OR INSERT INTO INT$UC_RIGHTSEX ');
        SQL.Add('(CLAVE_GROUP,MODULO,COMPONENTE,FORMULARIO,KEY) ');
        SQL.Add('VALUES(:CLAVE_GROUP,:MODULO,:COMPONENTE,:FORMULARIO,:KEY) ');
        SQL.Add('MATCHING (CLAVE_GROUP,MODULO,COMPONENTE,FORMULARIO) ');
        for i := 0 to ExtraRights.Count - 1 do
        begin
          ParamByName('CLAVE_GROUP').AsInteger := CGrupo;
          ParamByName('MODULO').AsString := ApplicationID;
          ParamByName('FORMULARIO').AsString := ExtraRights.Items[i].Formulario;
          ParamByName('COMPONENTE').AsString := ExtraRights.Items[i].Componente;
          ParamByName('KEY').AsString := GetKeyTPermisos(CGrupo, ExtraRights.Items[i].Componente);
          ExecSQL;
        end;
        // USUARIO MASTER
        SQL.Clear;
        SQL.Add('UPDATE OR INSERT INTO INT$UC_USERS ');
        SQL.Add('(UCUSERNAME,UCLOGIN,UCPASSWORD,UCUSEREXPIRED,UCUSERDAYSSUN,UCMASTER,UCINATIVE,UCDESCRIPCION) ');
        SQL.Add('VALUES(:UCUSERNAME,:UCLOGIN,:UCPASSWORD,:UCUSEREXPIRED,:UCUSERDAYSSUN,:UCMASTER,:UCINATIVE,:UCDESCRIPCION)');
        SQL.Add('MATCHING (UCLOGIN) ');
        SQL.Add('RETURNING CLAVE ');
        ParamByName('UCUSERNAME').AsString := Self.Login.InitialLogin.Alias;
        ParamByName('UCLOGIN').AsString := Self.Login.InitialLogin.User;
        ParamByName('UCUSEREXPIRED').AsString := 'FALSE';
        ParamByName('UCUSERDAYSSUN').AsInteger := Login.DaysOfSunExpired;
        ParamByName('UCMASTER').AsString := 'TRUE';
        ParamByName('UCINATIVE').AsString := 'TRUE';
        ParamByName('UCDESCRIPCION').AsString := 'Cuenta maestra por defecto';
        Open;
        CUser := FieldByName('CLAVE').AsInteger;
        Close;
        // RELACION CON EL GRUPO
        SQL.Clear;
        SQL.Add('UPDATE OR INSERT INTO INT$UC_USER_GROUP ');
        SQL.Add('(CLAVE_USER, CLAVE_GROUP,UKEY) ');
        SQL.Add('VALUES(:CLAVE_USER,:CLAVE_GROUP,:UKEY) ');
        SQL.Add('MATCHING (CLAVE_USER,CLAVE_GROUP)');
        ParamByName('UKEY').AsString := GetKeyTUserGroup(CUser, CGrupo);
        ParamByName('CLAVE_USER').AsInteger := CUser;
        ParamByName('CLAVE_GROUP').AsInteger := CGrupo;
        ExecSQL;
        // SETEA PASSWORD Y KEY
        if Q.Transaction.Active then
          Q.Transaction.CommitRetaining;
        RegistraCurrentUser(CUser, False);
        ChangePassword(FMasterTransaccion, CUser, Self.Login.InitialLogin.Password);
      end;
      if Q.Transaction.Active then
        Q.Transaction.Commit;
    except
      on e: Exception do
      begin
        SendDebug('TFMXUserControl.CreaAdministrador exception', e.Message);
        if Q.Transaction.Active then
          Q.Transaction.Rollback;
      end;
    end;
  finally
    Q.Free;
{$IFDEF DEPURACION}
    SendDebug('ComprobarMaster', 'done at ' + DateTimeToStrUs(now));
{$ENDIF}
  end;
end;

procedure TFMXUserControl.Loaded;
var
  Contador: Integer;
begin
  inherited;
  if not(csDesigning in ComponentState) then
  begin
    If UpperCase(Owner.ClassParent.ClassName) = UpperCase('TDataModule') then
      raise Exception.Create('El Componente "TFMXUserControl" no puede ser definido en un "TDataModule"');

    if ApplicationID = '' then
      raise Exception.Create(RetornaLingua(fLanguage, 'MsgExceptAppID'));

    if not Assigned(ControlRight.ActionList) and not Assigned(ControlRight.MainMenu) then
      raise Exception.Create(Format(RetornaLingua(fLanguage, 'MsgExceptPropriedade'), ['ControlRight']));

    for Contador := 0 to Pred(Owner.ComponentCount) do
      if Owner.Components[Contador] is TFMXUCSettings then
      begin
        Language := TFMXUCSettings(Owner.Components[Contador]).Language;
        // torna a linguage do UCSETTINGS como padrão
        FUserSettings.BancoDados := TFMXUCSettings(Owner.Components[Contador]).BancoDados;
        ApplySettings(TFMXUCSettings(Owner.Components[Contador]));
      end;

    if Assigned(User.MenuItem) and (not Assigned(User.MenuItem.OnClick)) then
      User.MenuItem.OnClick := ActionCadUser;

    if Assigned(User.Action) and (not Assigned(User.Action.OnExecute)) then
      User.Action.OnExecute := ActionCadUser;

    if ((not Assigned(User.Action)) and (not Assigned(User.MenuItem))) then
      raise Exception.Create(Format(RetornaLingua(fLanguage, 'MsgExceptPropriedade'), ['User']));

    if Assigned(UserPasswordChange.MenuItem) and (not Assigned(UserPasswordChange.MenuItem.OnClick)) then
      UserPasswordChange.MenuItem.OnClick := ActionTrocaSenha;

    if Assigned(UserPasswordChange.Action) and (not Assigned(UserPasswordChange.Action.OnExecute)) then
      UserPasswordChange.Action.OnExecute := ActionTrocaSenha;

    if Assigned(UsersLogoff.MenuItem) and (not Assigned(UsersLogoff.MenuItem.OnClick)) then
      UsersLogoff.MenuItem.OnClick := ActionLogoff;

    if Assigned(UsersLogoff.Action) and (not Assigned(UsersLogoff.Action.OnExecute)) then
      UsersLogoff.Action.OnExecute := ActionLogoff;

    if ((not Assigned(UserPasswordChange.Action)) and (not Assigned(UserPasswordChange.MenuItem))) then
      raise Exception.Create(Format(RetornaLingua(fLanguage, 'MsgExceptPropriedade'), ['UserPasswordChange']));

    if ((not Assigned(UsersLogoff.Action)) and (not Assigned(UsersLogoff.MenuItem))) then
      raise Exception.Create(Format(RetornaLingua(fLanguage, 'MsgExceptPropriedade'), ['UsersLogoff']));

    with TableUsers do
    begin
      if TableName = '' then
        Exception.Create(RetornaLingua(fLanguage, 'MsgExceptUsersTable'));
      if FieldUserID = '' then
        Exception.Create(RetornaLingua(fLanguage, 'MsgExceptUsersTable') + #13 + #10 + 'FieldUserID***');
      if FieldUserName = '' then
        Exception.Create(RetornaLingua(fLanguage, 'MsgExceptUsersTable') + #13 + #10 + 'FieldUserName***');
      if FieldLogin = '' then
        Exception.Create(RetornaLingua(fLanguage, 'MsgExceptUsersTable') + #13 + #10 + 'FieldLogin***');
      if FieldPassword = '' then
        Exception.Create(RetornaLingua(fLanguage, 'MsgExceptUsersTable') + #13 + #10 + 'FieldPassword***');
      if FieldEmail = '' then
        Exception.Create(RetornaLingua(fLanguage, 'MsgExceptUsersTable') + #13 + #10 + 'FieldEmail***');
      if FieldPrivileged = '' then
        Exception.Create(RetornaLingua(fLanguage, 'MsgExceptUsersTable') + #13 + #10 + 'FieldPrivileged***');
      if FieldTypeRec = '' then
        Exception.Create(RetornaLingua(fLanguage, 'MsgExceptUsersTable') + #13 + #10 + 'FieldTypeRec***');
      if FieldKey = '' then
        Exception.Create(RetornaLingua(fLanguage, 'MsgExceptUsersTable') + #13 + #10 + 'FieldKey***');
      if FieldProfile = '' then
        Exception.Create(RetornaLingua(fLanguage, 'MsgExceptUsersTable') + #13 + #10 + 'FieldProfile***');

      if FieldDateExpired = '' then
        Exception.Create(RetornaLingua(fLanguage, 'MsgExceptUsersTable') + #13 + #10 + 'FieldDateExpired***');

      if FieldUserExpired = '' then
        Exception.Create(RetornaLingua(fLanguage, 'MsgExceptUsersTable') + #13 + #10 + 'FieldUserExpired***');

      if FieldUserDaysSun = '' then
        Exception.Create(RetornaLingua(fLanguage, 'MsgExceptUsersTable') + #13 + #10 + 'FieldUserDaysSun***');

      if FieldUserInative = '' then
        Exception.Create(RetornaLingua(fLanguage, 'MsgExceptUsersTable') + #13 + #10 + 'FieldUserInative***');

    end;

    with TableRights do
    begin
      if TableName = '' then
        Exception.Create(RetornaLingua(fLanguage, 'MsgExceptRightsTable'));
      if FieldUserID = '' then
        Exception.Create(RetornaLingua(fLanguage, 'MsgExceptRightsTable') + #13 + #10 + 'FieldProfile***');
      if FieldModule = '' then
        Exception.Create(RetornaLingua(fLanguage, 'MsgExceptRightsTable') + #13 + #10 + 'FieldModule***');
      if FieldComponentName = '' then
        Exception.Create(RetornaLingua(fLanguage, 'MsgExceptRightsTable') + #13 + #10 + 'FieldComponentName***');
      if FieldFormName = '' then
        Exception.Create(RetornaLingua(fLanguage, 'MsgExceptRightsTable') + #13 + #10 + 'FieldFormName***');
      if FieldKey = '' then
        Exception.Create(RetornaLingua(fLanguage, 'MsgExceptRightsTable') + #13 + #10 + 'FieldKey***');
    end;

    if Assigned(OnStartApplication) then
      OnStartApplication(Self);

    // desviar para thread monitorando conexao ao banco qmd 30/01/2004
    if FAutoStart then
    begin
      FThUCRun := TUCExecuteThread.Create(True, Self);
      FThUCRun.Start;
    end;
  end;
end;

procedure TFMXUserControl.ActionCadUser(Sender: TObject);
begin
  ShowNewConfig;
end;

procedure TFMXUserControl.ActionOlvidaPassword(Sender: TObject);
var
  Q: TFDQuery;
begin
  if frmLoginWindow.EditUsuario.Text = Login.FInitialLogin.FUser then
  begin
    MessageDlg('¡El usuario ' + frmLoginWindow.EditUsuario.Text + ' no puede realizar esta acción!', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
    exit;
  end;

  Q := TFDQuery.Create(nil);
  try
    try
      with Q do
      begin
        Q.Connection := FConnection;
        Q.Transaction := FMasterTransaccion;
        Q.SQL.Add('SELECT * FROM INT$UC_USERS');
        Q.SQL.Add('WHERE UCLOGIN=:PUCLOGIN');
        Q.SQL.Add('AND CLAVE_EMPRESA=:PCLAVE_EMPRESA');
        Q.ParamByName('PUCLOGIN').AsString := frmLoginWindow.EditUsuario.Text;
        Q.ParamByName('PCLAVE_EMPRESA').AsInteger := frmLoginWindow.FDMaster.FieldByName('CLAVE').AsInteger;
        if not Q.Transaction.Active then
          Q.Transaction.StartTransaction;
        Q.Open;
        if Q.RecordCount > 0 then
        begin
          MailUserControl.EnviaPassOlvidado(FieldByName('CLAVE').AsInteger);
          if Q.Transaction.Active then
            Q.Transaction.Commit;
        end
        else
          MessageDlg(UserSettings.CommonMessages.InvalidLogin, TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
      end;
    except
      on e: Exception do
      begin
{$IFDEF DEPURACION}
        SendDebug('TFMXUserControl.ActionOlvidaPassword Exception', e.Message);
{$ENDIF}
        if Q.Transaction.Active then
          Q.Transaction.Rollback;
      end;
    end;
  finally
    Q.Free;
  end;
end;

procedure TFMXUserControl.ActionAsistenteUsuario(Sender: TObject);
var
  Q: TFDQuery;
begin
  if frmLoginWindow.EditUsuario.Text = Login.FInitialLogin.FUser then
  begin
    MessageDlg('¡El usuario ' + frmLoginWindow.EditUsuario.Text + ' no puede realizar esta acción!', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
    exit;
  end;

  Q := TFDQuery.Create(nil);
  try
    try
      with Q do
      begin
        Q.Connection := FConnection;
        Q.Transaction := FMasterTransaccion;
        Q.SQL.Add('SELECT * FROM INT$UC_USERS');
        Q.SQL.Add('WHERE UCLOGIN=:PUCLOGIN');
        Q.SQL.Add('AND CLAVE_EMPRESA=:PCLAVE_EMPRESA');
        Q.ParamByName('PUCLOGIN').AsString := frmLoginWindow.EditUsuario.Text;
        Q.ParamByName('PCLAVE_EMPRESA').AsInteger := frmLoginWindow.FDMaster.FieldByName('CLAVE').AsInteger;
        if not Q.Transaction.Active then
          Q.Transaction.StartTransaction;
        Q.Open;
        if Q.RecordCount > 0 then
        begin
          MailUserControl.EnviaPassOlvidado(FieldByName('CLAVE').AsInteger);
          if Q.Transaction.Active then
            Q.Transaction.Commit;
        end
        else
          MessageDlg(UserSettings.CommonMessages.InvalidLogin, TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
      end;
    except
      on e: Exception do
      begin
{$IFDEF DEPURACION}
        SendDebug('TFMXUserControl.ActionOlvidaPassword Exception', e.Message);
{$ENDIF}
        if Q.Transaction.Active then
          Q.Transaction.Rollback;
      end;
    end;
  finally
    Q.Free;
  end;
end;

procedure TFMXUserControl.ActionTrocaSenha(Sender: TObject);
begin
  if Assigned(OnCustomChangePasswordForm) then
    OnCustomChangePasswordForm(Self, FFormTrocarSenha);

  if FFormTrocarSenha = nil then
    CriaFormTrocarSenha;

  FFormTrocarSenha.ShowModal;
  FreeAndNil(FFormTrocarSenha);
end;

procedure TFMXUserControl.CriaFormTrocarSenha;
begin
  FFormTrocarSenha := TTrocaSenha.Create(Self);
  with Self.UserSettings.ChangePassword do
  begin
    TTrocaSenha(FFormTrocarSenha).FUserControl := Self;
    TTrocaSenha(FFormTrocarSenha).Caption := WindowCaption;
    TTrocaSenha(FFormTrocarSenha).lbDescripcion.Text := LabelDescription;
    TTrocaSenha(FFormTrocarSenha).lbPassActual.Text := LabelCurrentPassword;
    TTrocaSenha(FFormTrocarSenha).lbPassNuevo.Text := LabelNewPassword;
    TTrocaSenha(FFormTrocarSenha).lbConfirma.Text := LabelConfirm;
    TTrocaSenha(FFormTrocarSenha).btOK.Text := BtSave;
    TTrocaSenha(FFormTrocarSenha).BtCancela.Text := btCancel;
    TTrocaSenha(FFormTrocarSenha).ForcarTroca := False;
  end;
  // TTrocaSenha(FFormTrocarSenha).JvAppRegistryStorage1.Root := FormStorageRegRoot;
  TTrocaSenha(FFormTrocarSenha).BtCancela.OnClick := ActionTSBtGrava;
  if CurrentUser.Password = '' then
    TTrocaSenha(FFormTrocarSenha).EditPassActual.Enabled := False;
end;

procedure TFMXUserControl.ActionTSBtGrava(Sender: TObject);
begin
  if CurrentUser.Password <> GetKeyPassword(TTrocaSenha(FFormTrocarSenha).EditPassActual.Text) then
  begin
    MessageDlg(UserSettings.CommonMessages.ChangePasswordError.InvalidCurrentPassword, TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
    TTrocaSenha(FFormTrocarSenha).EditPassActual.SetFocus;
    exit;
  end;

  if TTrocaSenha(FFormTrocarSenha).EditPassNuevo.Text <> TTrocaSenha(FFormTrocarSenha).EditPassConfirma.Text then
  begin
    MessageDlg(UserSettings.CommonMessages.ChangePasswordError.InvalidNewPassword, TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
    TTrocaSenha(FFormTrocarSenha).EditPassNuevo.SetFocus;
    exit;
  end;

  if GetKeyPassword(TTrocaSenha(FFormTrocarSenha).EditPassNuevo.Text) = CurrentUser.Password then
  begin
    MessageDlg(UserSettings.CommonMessages.ChangePasswordError.NewEqualCurrent, TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
    TTrocaSenha(FFormTrocarSenha).EditPassNuevo.SetFocus;
    exit;
  end;

  if (UserPasswordChange.ForcePassword) and (TTrocaSenha(FFormTrocarSenha).EditPassNuevo.Text = '') then
  begin
    MessageDlg(UserSettings.CommonMessages.ChangePasswordError.PasswordRequired, TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
    TTrocaSenha(FFormTrocarSenha).EditPassNuevo.Text;
    exit;
  end;

  if Length(TTrocaSenha(FFormTrocarSenha).EditPassNuevo.Text) < UserPasswordChange.MinPasswordLength then
  begin
    MessageDlg(Format(UserSettings.CommonMessages.ChangePasswordError.MinPasswordLength, [UserPasswordChange.MinPasswordLength]),
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
    TTrocaSenha(FFormTrocarSenha).EditPassNuevo.SetFocus;
    exit;
  end;

  if Pos(LowerCase(TTrocaSenha(FFormTrocarSenha).EditPassNuevo.Text), 'abcdeasdfqwerzxcv1234567890321654987teste' + LowerCase(CurrentUser.UserName) +
    LowerCase(CurrentUser.UserLogin)) > 0 then
  begin
    MessageDlg(UserSettings.CommonMessages.ChangePasswordError.InvalidNewPassword, TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
    TTrocaSenha(FFormTrocarSenha).EditPassNuevo.SetFocus;
    exit;
  end;

  if Assigned(OnChangePassword) then
    OnChangePassword(Self, CurrentUser.UserID, CurrentUser.UserLogin, CurrentUser.Password, TTrocaSenha(FFormTrocarSenha).EditPassNuevo.Text);

  ChangePassword(FMasterTransaccion, CurrentUser.UserID, TTrocaSenha(FFormTrocarSenha).EditPassNuevo.Text);

  CurrentUser.Password := GetKeyPassword(TTrocaSenha(FFormTrocarSenha).EditPassNuevo.Text);

  if CurrentUser.Password = '' then
    MessageDlg(Format(UserSettings.CommonMessages.BlankPassword, [CurrentUser.UserLogin]), TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], 0)
  else
    MessageDlg(UserSettings.CommonMessages.PasswordChanged, TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], 0);

  if TTrocaSenha(FFormTrocarSenha).ForcarTroca = True then
    TTrocaSenha(FFormTrocarSenha).ForcarTroca := False;

  if Assigned(FMailUserControl) then
    with CurrentUser do
    begin
      try
        FMailUserControl.EnviaEmailSenhaTrocada(UserID, TTrocaSenha(FFormTrocarSenha).EditPassNuevo.Text);
      except
        on e: Exception do
          Log(e.Message, 2);
      end;
    end;
  CurrentUser.PassLivre := TTrocaSenha(FFormTrocarSenha).EditPassNuevo.Text;
  TTrocaSenha(FFormTrocarSenha).Close;
end;

procedure TFMXUserControl.SetUserSettings(const Value: TUCUserSettings);
begin
  UserSettings := Value;
end;

procedure TFMXUserControl.SetfrmLoginWindow(Form: TCustomForm);
begin

end;

procedure TFMXUserControl.Notification(AComponent: TComponent; AOperation: TOperation);
begin
  if (AOperation = opRemove) then
  begin
    if AComponent = User.MenuItem then
      User.MenuItem := nil;
    if AComponent = User.Action then
      User.Action := nil;
    if AComponent = UserPasswordChange.Action then
      UserPasswordChange.Action := nil;
    if AComponent = UserPasswordChange.MenuItem then
      UserPasswordChange.MenuItem := nil;

    if AComponent = UsersLogoff.Action then
      UsersLogoff.Action := nil;
    if AComponent = UsersLogoff.MenuItem then
      UsersLogoff.MenuItem := nil;

    if AComponent = ControlRight.MainMenu then
      ControlRight.MainMenu := nil;
    if AComponent = ControlRight.ActionList then
      ControlRight.ActionList := nil;
    { .$ENDIF }

    if AComponent = CurrentUser then // se borra el usuario actual
    begin
      if CurrentUser.UserID <> 0 then
        UsersLogged.DelCurrentUser;
    end;

    if AComponent = FMailUserControl then
      FMailUserControl := nil;
  end;
  inherited Notification(AComponent, AOperation);
end;

procedure TFMXUserControl.ActionLogoff(Sender: TObject);
begin
  WriteAccessAction('Cierre de sesion manual');
  Self.Logoff;
end;

procedure TFMXUserControl.Log(Msg: String; Level: Integer);
var
  Q: TFDQuery;
begin
  if not LogControl.Active then
    exit;

  Q := TFDQuery.Create(nil);
  try
    try
      Q.Connection := FConnection;
      Q.Transaction := FMasterTransaccion;
      if not Q.Transaction.Active then
        Q.Transaction.StartTransaction;
      with Q do
      begin
        SQL.Add('INSERT INTO ' + LogControl.TableLog + ' ');
        SQL.Add('(CLAVE_USER, UCAPPLICATIONID, UCMSG, UCFECHA_HORA, UCNIVEL)');
        SQL.Add('VALUES (:CLAVE_USER, :UCAPPLICATIONID, :UCFECHA_HORA, :UCDATA, :UCNIVEL) ');
        ParamByName('CLAVE_USER').AsInteger := CurrentUser.UserID;
        ParamByName('UCAPPLICATIONID').AsString := Self.ApplicationID;
        ParamByName('UCMSG').AsString := Copy(Msg, 1, 250);
        ParamByName('UCDATA').AsDateTime := now;
        ParamByName('UCNIVEL').AsInteger := Level;
        ExecSQL;
      end;
      if Q.Transaction.Active then
        Q.Transaction.Commit;
    except
      on e: Exception do
      begin
{$IFDEF DEPURACION}
        SendDebug('TFMXUserControl.ActionLogoff exception', e.Message);
{$ENDIF}
        if Q.Transaction.Active then
          Q.Transaction.RollbackRetaining;
      end;
    end;
  finally
    Q.Free;
  end;
end;
{
  procedure TFMXUserControl.TryAutoLogon;
  begin
  if VerificaLogin(Login.AutoLogin.User, Login.AutoLogin.Password, 0) <> 0 then
  begin
  if Login.AutoLogin.MessageOnError then
  MessageDlg(UserSettings.CommonMessages.AutoLogonError, TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
  ShowLogin;
  end;
  end; }

procedure TFMXUserControl.Logoff;
begin
  if Assigned(OnLogoff) then
    OnLogoff(Self, CurrentUser.UserID);

  LockControlsUCControlMonitor;
  UsersLogged.DelCurrentUser;
  CurrentUser.UserID := 0;

  // if LoginMode = lmActive then
  ShowLogin;
  ApplyRights;
end;

procedure TFMXUserControl.ChangePassword(FDTMaster: TFDTransaction; IdUser: Integer; NewPassword: String);
var
  AUlogin: String;
  Q: TFDQuery;
begin
  inherited;
  Q := TFDQuery.Create(nil);
  try
    try
      Q.Connection := FConnection;
      Q.Transaction := FDTMaster;
      if not Q.Transaction.Active then
        Q.Transaction.StartTransaction;

      { case Self.Login.CharCasePass of
        ecNormal:
        ;
        ecUpperCase:
        NewPassword := UpperCase(NewPassword);
        ecLowerCase:
        NewPassword := LowerCase(NewPassword);
        end; }
      with Q do
      begin
        SQL.Add('SELECT * FROM INT$UC_USERS '); // necesitamos los datos de usuario para modificar la firma del registro
        SQL.Add('WHERE CLAVE=:PCLAVE');
        ParamByName('PCLAVE').AsInteger := IdUser;
        Open;
        AUlogin := FieldByName('UCLOGIN').AsString;
        Close;
        if uppercase(CurrentUser.UserExpired) = 'FALSE' then
        begin
          SavePropertyOnReg(FormStorageRegRoot + '\UserControl\UCBase\Dialogs\PasswordExpired\', 'NoAskAnyMore', False);
          SQL.Clear;
          SQL.Add('UPDATE INT$UC_USERS SET UCPASSWORD=:PUCPASSWORD,');
          SQL.Add('UCKEY=:PUCKEY,');
          SQL.Add('UCPASSEXPIRED=:PUCPASSEXPIRED ');
          SQL.Add('WHERE CLAVE=:PCLAVE');
          ParamByName('PUCPASSWORD').AsString := GetKeyPassword(NewPassword);
          ParamByName('PUCKEY').AsString := GetKeyTUsuario(IdUser, AUlogin, NewPassword);
          ParamByName('PUCPASSEXPIRED').AsDateTime := IncDay(now, FCurrentUser.UserDaysExpired);
          ParamByName('PCLAVE').AsInteger := IdUser;
          ExecSQL;
        end


      end;
      if Q.Transaction.Active then
        Q.Transaction.CommitRetaining;
      // if Assigned(OnChangePassword) then
      // OnChangePassword(Self, IdUser, Login, GetKeyPassword(NewPassword), NewPassword);
    except
      on e: Exception do
      begin
        SendDebug('ChangePassword Exception', e.Message);
        if Q.Transaction.Active then
          Q.Transaction.RollbackRetaining;
      end;
    end;
  finally
    Q.Free;
  end;
end;

procedure TFMXUserControl.CriaTabelaMsgs(const TableName: String);
begin
  //
end;

destructor TFMXUserControl.Destroy;
begin
  FCurrentUser.Free;
  FControlRight.Free;
  FLogin.Free;
  FLogControl.Free;
  FUser.Free;
  FUserProfile.Free;
  FUserPasswordChange.Free;
  FUsersLogoff.Free;
  FUsersLogged.Free;
  FUserSettings.Free;
  FNotAllowedItems.Free;
  FExtraRights.Free;
  FTableUsers.Free;
  FTableRights.Free;
  FTableUsersLogged.Free;
  FMasterTransaccion.Free;
  TaskDialog.Free;
  if Assigned(FControlList) then
    FControlList.Free;

  if Assigned(FLoginMonitorList) then
    FLoginMonitorList.Free;

  inherited Destroy;
end;

procedure TFMXUserControl.SetExtraRights(Value: TUCExtraRights);
begin

end;

procedure TFMXUserControl.HideField(Sender: TField; var Text: String; DisplayText: Boolean);
begin
  Text := '(Campo Bloqueado)';
end;

procedure TFMXUserControl.StartLogin;
begin
  CurrentUser.UserID := 0;
  ShowLogin;
  ApplyRights;
end;

procedure TFMXUserControl.Execute;
var
  Q: TFDQuery;

  // procedure MuestraLogin;
  // begin
  // if (LoginMode = lmActive) and (not Login.AutoLogin.Active) then
  // ShowLogin
  // end;

begin
  Login.AutoLogin.Active := Boolean(ReadPropertyFromReg(FormStorageRegRoot + '\UserControl\UCBase\Login\', 'AutoLoginActive'));
  Login.AutoLogin.User := String(ReadPropertyFromReg(FormStorageRegRoot + '\UserControl\UCBase\Login\', 'AutoLoginUser'));
  Login.AutoLogin.Password := String(Desmontar(ReadPropertyFromReg(FormStorageRegRoot + '\UserControl\UCBase\Login\', 'AutoLoginPass')));
  UserSettings.Login.Recordar := Boolean(ReadPropertyFromReg(FormStorageRegRoot + '\UserControl\UCBase\Login\', 'Recordar'));
  UserSettings.Login.AutoIniciar := Boolean(ReadPropertyFromReg(FormStorageRegRoot + '\UserControl\UCBase\Login\', 'AutoIniciar'));
  UserSettings.Login.Empresa := Integer(ReadPropertyFromReg(FormStorageRegRoot + '\UserControl\UCBase\Login\', 'Empresa'));

  if Assigned(FThUCRun) then
    FThUCRun.Terminate;

  if not Assigned(FConnection) then
    exit;

  // TEventLog.WriteInfo('start');

{$IFDEF DEPURACION}
  SendDebug('UC Base', 'UCExecute at ' + DateTimeToStrUs(now));
{$ENDIF}
  Q := TFDQuery.Create(nil);
  try
    try
      with Q do
      begin
        Connection := FConnection;
        // SI NO HAY NADA CREAMOS EL MASTER
        SQL.Clear;
        SQL.Add('SELECT * FROM INT$UC_USERS');
        Open;
        if IsEmpty then
        begin
          Close;
          ComprobarMaster;
        end;

        SQL.Clear;
        SQL.Add('SELECT * FROM INT$UC_EMAIL');
        Open;
        if IsEmpty then
        begin
          Close;
          SetAjustesMailPorDefecto;
        end;
        Close;
        if Login.AutoLogin.Active then
        begin
          SQL.Clear;
          SQL.Add('SELECT FIRST 1 A.*,U.SID,U.NOMBRE,U.DOMINIO ');
          SQL.Add('FROM INT$UC_USERS  A ');
          SQL.Add('LEFT OUTER JOIN INT$UC_USER_WIN U ON U.CLAVE_USER=A.CLAVE ');
          SQL.Add('WHERE U.SID=:PSID ');
          SQL.Add('AND U.UKEY=UPPER(F_ENCRYPTMD5(A.CLAVE || U.SID || A.UCLOGIN))');
          ParamByName('PSID').AsString := GetCurrentUserSid;
          Open;
          if not IsEmpty then
          begin
            CurrentUser.UserSID := FieldByName('SID').AsString;
            CurrentUser.WinLogin := FieldByName('NOMBRE').AsString;
            CurrentUser.UserDomain := FieldByName('DOMINIO').AsString;
            if VerificaLogin(FieldByName('UCLOGIN').AsString, FieldByName('UCPASSWORD').AsString, FieldByName('CLAVE_EMPRESA').AsInteger, False) <> 0
            then
              ShowLogin
            else
            begin
              Application.MainForm.Visible := True;
              TForm(Self.Owner).WindowState := TWindowState.wsNormal;
              TForm(Self.Owner).Visible := True;
              SetWindowPos(FmxHandleToHWND(TForm(Self.Owner).Handle), HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
              SetWindowPos(FmxHandleToHWND(TForm(Self.Owner).Handle), HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
              SetWindowPos(FmxHandleToHWND(TForm(Self.Owner).Handle), HWND_NOTOPMOST, 0, 0, 0, 0, SWP_SHOWWINDOW or SWP_NOMOVE or SWP_NOSIZE);
              if Assigned(FOnLoginSucess) then
                OnLoginSucess(Self, CurrentUser.UserID, CurrentUser.UserLogin, CurrentUser.UserName, CurrentUser.Password, CurrentUser.Email,
                  CurrentUser.EsMaster);
            end;
          end
          else
          begin
            if VerificaLogin(Login.AutoLogin.User, Login.AutoLogin.Password, UserSettings.Login.Empresa) <> 0 then
              ShowLogin
            else
            begin
              Application.MainForm.Visible := True;
              TForm(Self.Owner).WindowState := TWindowState.wsNormal;
              TForm(Self.Owner).Visible := True;
              SetWindowPos(FmxHandleToHWND(TForm(Self.Owner).Handle), HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
              SetWindowPos(FmxHandleToHWND(TForm(Self.Owner).Handle), HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
              SetWindowPos(FmxHandleToHWND(TForm(Self.Owner).Handle), HWND_NOTOPMOST, 0, 0, 0, 0, SWP_SHOWWINDOW or SWP_NOMOVE or SWP_NOSIZE);
              if Assigned(FOnLoginSucess) then
                OnLoginSucess(Self, CurrentUser.UserID, CurrentUser.UserLogin, CurrentUser.UserName, CurrentUser.Password, CurrentUser.Email,
                  CurrentUser.EsMaster);
            end;
          end;
        end
        else
          ShowLogin;
      end;
    except
      on e: Exception do
      begin
        ShowMessage('Se ha producido una excepción controlada con el mensaje: ' + e.Message + ' Informe al desarrollador, la aplicación finalizará.');
        Application.Terminate;
      end;
      // MuestraLogin;
    end;
  finally
    Q.Free;
    ApplyRights;
  end;
end;

procedure TFMXUserControl.ShowChangePassword;
begin
  ActionTrocaSenha(Self);
end;

procedure TFMXUserControl.ShowNewConfig;
begin
  try
    with TFMXFormUserPerf.CreateEx(Application, FConnection, Self) do
    begin
      FormStyle := TFormStyle.fsNormal;
      Left := 0;
      Top := 0;
      Show;
    end;
  except
    on e: Exception do
      SendDebug('TFMXUserControl.ShowNewConfig exception', e.Message);
  end;
end;

procedure TFMXUserControl.AddUCControlMonitor(UCControl: TFMXUCControls);
begin
  FControlList.Add(UCControl);
end;

procedure TFMXUserControl.ApplyRightsUCControlMonitor;
var
  Contador: Integer;
begin
  for Contador := 0 to Pred(FControlList.Count) do
    TFMXUCControls(FControlList.Items[Contador]).ApplyRights;
end;

procedure TFMXUserControl.DeleteUCControlMonitor(UCControl: TFMXUCControls);
var
  Contador: Integer;
  SLControls: TStringList;
begin
  if not Assigned(FControlList) then
    exit;
  SLControls := TStringList.Create;
  for Contador := 0 to Pred(FControlList.Count) do
    if TFMXUCControls(FControlList.Items[Contador]) = UCControl then
      SLControls.Add(IntToStr(Contador));

  for Contador := 0 to Pred(SLControls.Count) do
    FControlList.Delete(StrToInt(SLControls[Contador]));

  FreeAndNil(SLControls);
end;

procedure TFMXUserControl.LockControlsUCControlMonitor;
var
  Contador: Integer;
begin
  for Contador := 0 to Pred(FControlList.Count) do
    TFMXUCControls(FControlList.Items[Contador]).LockControls;
end;

procedure TFMXUserControl.AddLoginMonitor(UCAppMessage: TFMXUCApplicationMessage);
begin
  FLoginMonitorList.Add(UCAppMessage);
end;

procedure TFMXUserControl.DeleteLoginMonitor(UCAppMessage: TFMXUCApplicationMessage);
var
  Contador: Integer;
  SLControls: TStringList;
begin
  SLControls := TStringList.Create;
  if Assigned(FLoginMonitorList) then
    for Contador := 0 to Pred(FLoginMonitorList.Count) do
      if TFMXUCApplicationMessage(FLoginMonitorList.Items[Contador]) = UCAppMessage then
        SLControls.Add(IntToStr(Contador));
  if Assigned(SLControls) then
    for Contador := 0 to Pred(SLControls.Count) do
      FLoginMonitorList.Delete(StrToInt(SLControls[Contador]));
  SLControls.Free;
end;

procedure TFMXUserControl.NotificationLoginMonitor;
var
  Contador: Integer;
begin
  for Contador := 0 to Pred(FLoginMonitorList.Count) do
    TFMXUCApplicationMessage(FLoginMonitorList.Items[Contador]).CheckMessages;
end;

procedure TFMXUserControl.ShowLogin;
var
  OwnerMenu: TComponent;
begin

  Application.MainForm.Visible := False;
  TForm(Self.Owner).WindowState := TWindowState.wsMinimized;
  TForm(Self.Owner).Visible := False;

  if Assigned(ControlRight.MainMenu) then
  begin
    OwnerMenu := ControlRight.MainMenu.Owner;
    // TForm(OwnerMenu).Menu := nil;
  end;

  FRetry := 0;
  // if Assigned(OnCustomLoginForm) then
  // OnCustomLoginForm(Self, frmLoginWindow);

  if not Assigned(frmLoginWindow) then
  begin
    frmLoginWindow := TfrmLoginWindow.CreateEx(Application, FConnection, Self);
    Login.AutoLogin.Active := Boolean(ReadPropertyFromReg(FormStorageRegRoot + '\UserControl\UCBase\Login\', 'AutoLoginActive'));
    Login.AutoLogin.User := String(ReadPropertyFromReg(FormStorageRegRoot + '\UserControl\UCBase\Login\', 'AutoLoginUser'));
    Login.AutoLogin.Password := String(Desmontar(ReadPropertyFromReg(FormStorageRegRoot + '\UserControl\UCBase\Login\', 'AutoLoginPass')));
    UserSettings.Login.Recordar := Boolean(ReadPropertyFromReg(FormStorageRegRoot + '\UserControl\UCBase\Login\', 'Recordar'));
    UserSettings.Login.AutoIniciar := Boolean(ReadPropertyFromReg(FormStorageRegRoot + '\UserControl\UCBase\Login\', 'AutoIniciar'));
    UserSettings.Login.Empresa := Integer(ReadPropertyFromReg(FormStorageRegRoot + '\UserControl\UCBase\Login\', 'Empresa'));

    with UserSettings.Login, frmLoginWindow do
    begin
      Caption := Self.ApplicationID;
      LbUsuario.Text := LabelUser;
      LbPass.Text := LabelPassword;
      // lbtitle.Text := Self.ApplicationID + ' - ' + 'User Login';
      lbEsqueci.Text := LabelForgetPassword;
      lbEsqueci.OnClick := ActionOlvidaPassword;
      btOK.Text := UserSettings.Login.btOK;
      btOK.OnClick := ActionOKLogin;
      cbRecordar.IsChecked := Recordar;
      cbRecordar.Enabled := not Login.AutoLogin.Active;
      cbAutoLogin.IsChecked := Login.AutoLogin.Active;
      if UserSettings.Login.Recordar then
      begin
        EditUsuario.Text := Login.AutoLogin.User;
        EditPass.Text := Login.AutoLogin.Password;
      end;
      cbAutoIniciar.IsChecked := AutoIniciar;
      BtCancela.Text := btCancel;
      StatusBar.Visible := Login.FMaxLoginAttempts > 0;
      LbIntentos.Text := '0';
      LbLimiteIntentos.Text := IntToStr(Login.FMaxLoginAttempts);
      onCloseQuery := TestaFecha;
      lbAsistenteUser.OnClick := ActionAsistenteUsuario;
      if Assigned(FMailUserControl) then
      begin
        lbEsqueci.Visible := True;
        lbEsqueci.Text := 'Olvido Contraseña' // FMailUserControl.OlvidoPassword.LabelLoginForm;
      end;
    end;
  end;
  frmLoginWindow.ShowModal;
end;

procedure TFMXUserControl.ActionOKLogin(Sender: TObject);
var
  TempUser: String;
  TempPassword: String;
  TempEmpresa: Integer;
  retorno: Integer;
begin
  frmLoginWindow.btOKClick(nil); { By Cleilson Sousa }
  TempUser := frmLoginWindow.EditUsuario.Text;
  TempPassword := frmLoginWindow.EditPass.Text;
  TempEmpresa := frmLoginWindow.FDMaster.FieldByName('Clave').AsInteger;
  Login.AutoLogin.Active := frmLoginWindow.cbAutoLogin.IsChecked;
  if Login.AutoLogin.Active then
  begin
    Login.AutoLogin.User := TempUser;
    Login.AutoLogin.Password := Montar(TempPassword);
  end;

  UserSettings.Login.Recordar := frmLoginWindow.cbRecordar.IsChecked;
  UserSettings.Login.AutoIniciar := frmLoginWindow.cbAutoIniciar.IsChecked;
  UserSettings.Login.Empresa := TempEmpresa;

  retorno := VerificaLogin(TempUser, TempPassword, TempEmpresa);

  if retorno = 0 then
  begin
    frmLoginWindow.Close;
    Application.MainForm.Visible := True;
    TForm(Self.Owner).WindowState := TWindowState.wsNormal;
    TForm(Self.Owner).Visible := True;
    TForm(Self.Owner).BringToFront;

    SavePropertyOnReg(FormStorageRegRoot + '\UserControl\UCBase\Login\', 'Empresa', UserSettings.Login.Empresa);
    SavePropertyOnReg(FormStorageRegRoot + '\UserControl\UCBase\Login\', 'Recordar', UserSettings.Login.Recordar);
    SavePropertyOnReg(FormStorageRegRoot + '\UserControl\UCBase\Login\', 'AutoIniciar', UserSettings.Login.AutoIniciar);
    if UserSettings.Login.Recordar then
    begin
      SavePropertyOnReg(FormStorageRegRoot + '\UserControl\UCBase\Login\', 'AutoLoginUser', TempUser);
      SavePropertyOnReg(FormStorageRegRoot + '\UserControl\UCBase\Login\', 'AutoLoginPass', Montar(TempPassword));
    end;
    // SavePropertyOnReg(FormStorageRegRoot + '\UserControl\UCBase\Login\', 'LocalUser', UserSettings.Login.LocalUser);
    if Login.AutoLogin.Active then
    begin

      SavePropertyOnReg(FormStorageRegRoot + '\UserControl\UCBase\Login\', 'AutoLoginActive', Login.AutoLogin.Active);
    end;
    WriteAccessAction('Incio de manual');
    if Assigned(FOnLoginSucess) then
      OnLoginSucess(Self, CurrentUser.UserID, CurrentUser.UserLogin, CurrentUser.UserName, CurrentUser.Password, CurrentUser.Email,
        CurrentUser.EsMaster);

  end
  else
  begin
    frmLoginWindow.EditPass.Text := '';
    if retorno = 1 then
      MessageDlg(UserSettings.CommonMessages.InvalidLogin, TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0)

    else if retorno = 2 then
      MessageDlg(UserSettings.CommonMessages.InactiveLogin, TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);

    Inc(FRetry);
    if frmLoginWindow.StatusBar.Visible then
      frmLoginWindow.LbIntentos.Text := IntToStr(FRetry);

    if (Login.MaxLoginAttempts > 0) and (FRetry = Login.MaxLoginAttempts) then
    begin
      MessageDlg(Format(UserSettings.CommonMessages.MaxLoginAttemptsError, [Login.MaxLoginAttempts]), TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
      Application.Terminate;
    end;
  end;
end;

function TFMXUserControl.VerificaLogin(User, Password: String; Empresa: Integer; SetteaPass: Boolean = True): Integer; // Boolean;
var
  Pass: String;
  VerifKey: String;
  Q: TFDQuery;
  Horas: Integer;
begin
  SendDebug('VerificaLogin', 'Iniciando verificacion');
  Q := TFDQuery.Create(nil);
  try
    try
      Q.Connection := FConnection;
      Pass := Password;
      if SetteaPass then // para el login windows
        Pass := GetKeyPassword(Password);
      with Q do
      begin
        SQL.Clear;
        SQL.Add('SELECT * FROM ' + TableUsers.TableName + ' ');
        SQL.Add('WHERE UCLOGIN=:PLOGIN ');
        SQL.Add('AND UCPASSWORD=:PPASSWORD ');
        if User = Login.InitialLogin.User then // si es el master pasamos de la empresa
          SQL.Add('AND CLAVE_EMPRESA IS NULL')
        else
          SQL.Add('AND (UCAMBITO=:PUCAMBITO OR CLAVE_EMPRESA=:PCLAVE_EMPRESA)');
        ParamByName('PLOGIN').AsString := User;

        ParamByName('PPASSWORD').AsString := Pass;
        if User <> Login.InitialLogin.User then
        begin
          ParamByName('PCLAVE_EMPRESA').AsInteger := Empresa;
          ParamByName('PUCAMBITO').AsString := 'Global';
        end;
        Open;
        if not IsEmpty then
        begin
          VerifKey := GetKeyTUsuario(FieldByName('CLAVE').AsInteger, FieldByName('UCLOGIN').AsString, FieldByName('UCPASSWORD').AsString, True);
          if FieldByName('UCKEY').AsString <> VerifKey then
          begin
            Result := 1;
            SendDebug('VerificaLogin', 'las firmas no coinciden');
            if Assigned(OnLoginError) then
              OnLoginError(Self, User, Password);
          end
          else
          begin
            if (FieldByName('UCINATIVE').AsString = 'TRUE') then
            begin
              RegistraCurrentUser(FieldByName('CLAVE').AsInteger, False);
              if (FieldByName('UCUSEREXPIRED').AsString = 'FALSE') then
              begin
                Horas := HoursBetween(FieldByName('UCPASSEXPIRED').AsDateTime, now);
                if (Horas < 72) and (Horas > 0) then
                begin
                  if not Boolean(ReadPropertyFromReg(FormStorageRegRoot + '\UserControl\UCBase\Dialogs\PasswordExpired\', 'NoAskAnyMore')) then
                  begin
                    TaskDialog.Title := 'Advertencia';
                    TaskDialog.InstructionText := 'Caducidad de contraseña';
                    TaskDialog.Content := Format('Su contraseña caducará en las próximas %d Hora(s). ¿Desea cambiarla en este momento?', [Horas]);
                    TaskDialog.VerificationText := 'No volver a mostrar';
                    TaskDialog.Tag := 0;
                    TaskDialog.Show(
                      procedure(ButtonID: Integer)
                      begin
                        case ButtonID of
                          mrYes:
                            begin
                              frmLoginWindow.EditPass.Text := '';
                              ActionTrocaSenha(nil);
                              TaskDialog.Tag := 3;
                              exit;
                            end;
                        end;

                        if TaskDialog.VerifyResult then
                          SavePropertyOnReg(FormStorageRegRoot + '\UserControl\UCBase\Dialogs\PasswordExpired\', 'NoAskAnyMore', True);
                      end);
                    if TaskDialog.Tag = 3 then
                      Result := 3;
                  end;
                end
                else if Horas = 0 then
                begin

                  TaskDialog.Title := 'Advertencia';
                  TaskDialog.InstructionText := 'Caducidad de contraseña';
                  TaskDialog.Content := 'Su contraseña actual ha expirado. Para poder acceder al sistema debe cambiarla.';
                  TaskDialog.commonButtons := [TFMXCommonButton.OK];
                  TaskDialog.Show();
                  frmLoginWindow.EditPass.Text := '';
                  // UserSettings.CommonMessages.PasswordExpired
                  ActionTrocaSenha(nil);
                  Result := 4;
                  exit;
                end;
              end;
              RegistraCurrentUser(FieldByName('CLAVE').AsInteger, True);
              SendDebug('VerificaLogin', 'usuario activo');
              Result := 0;
            end
            else
            begin
              Result := 2;
              SendDebug('VerificaLogin', 'usuario inactivo');
            end;
          end;
        end
        else
        begin
          Result := 1;
          SendDebug('VerificaLogin', 'usuario no existe');
          if Assigned(OnLoginError) then
            OnLoginError(Self, User, Password);
        end;
      end;
    except
      on e: Exception do
        SendDebug('VerificaLogin Exception', e.Message);
    end;
  finally
    Q.Free;
  end;
end;

procedure TFMXUserControl.WriteAccessAction(Accion: string);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    try
      with Q do
      begin
        Q.Connection := FConnection;
        Q.Transaction := FMasterTransaccion;
        SQL.Add('INSERT INTO INT$UC_ACCESOS ');
        SQL.Add('(CLAVE_EMPRESA, CLAVE_USER, ACCION, FECHA_HORA, WINLOGIN, MACHINE, APPLICATIONID) ');
        SQL.Add('VALUES(:CLAVE_EMPRESA, :CLAVE_USER, :ACCION, :FECHA_HORA, :WINLOGIN, :MACHINE, :APPLICATIONID)');
        ParamByName('CLAVE_EMPRESA').AsInteger := CurrentUser.Empresa;
        ParamByName('CLAVE_USER').AsInteger := CurrentUser.UserID;
        ParamByName('ACCION').AsString := Accion;
        ParamByName('FECHA_HORA').AsDateTime := now;
        ParamByName('CLAVE_EMPRESA').AsInteger := CurrentUser.Empresa;
        ParamByName('WINLOGIN').AsString := CurrentUser.UserDomain + '\' + CurrentUser.WinLogin;
        ParamByName('MACHINE').AsString := GetLocalComputerName;
        ParamByName('APPLICATIONID').AsString := ApplicationID;
        if not Q.Transaction.Active then
          Q.Transaction.StartTransaction;
        ExecSQL;
        if Q.Transaction.Active then
          Q.Transaction.Commit;
      end;
    except
      on e: Exception do
      begin
        if Q.Transaction.Active then
          Q.Transaction.Rollback;
        SendDebug('TFMXUserControl.WriteAccessAction Exception', e.Message);
      end;
    end;
  finally
    Q.Free;
  end;
end;

procedure TFMXUserControl.RegistraCurrentUser(User: Integer; Granted: Boolean);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    try
      with Q do
      begin
        Connection := FConnection;
        SQL.Add('SELECT A.*,E.NOMBRE AS N_EMPRESA FROM ' + TableUsers.TableName + ' A ');
        SQL.Add('LEFT JOIN INT$ENTIDAD E ON E.CLAVE=A.CLAVE_EMPRESA');
        SQL.Add('WHERE A.CLAVE=:PCLAVE');
        ParamByName('PCLAVE').AsInteger := User;
        Open;
        CurrentUser.UserID := User;
        CurrentUser.EsMaster := FieldByName('UCMASTER').AsBoolean;
        if not CurrentUser.EsMaster then
        begin
          CurrentUser.Empresa := FieldByName('CLAVE_EMPRESA').AsInteger;
          CurrentUser.NombreEmpresa := FieldByName('N_EMPRESA').AsString;
          CurrentUser.Ambito := FieldByName('UCAMBITO').AsString;
        end;
        CurrentUser.UserName := FieldByName(TableUsers.FieldUserName).AsString;
        CurrentUser.UserLogin := FieldByName('UCLOGIN').AsString;
        CurrentUser.Password := FieldByName('UCPASSWORD').AsString;
        CurrentUser.DateExpiration := FieldByName('UCPASSEXPIRED').AsDateTime;
        CurrentUser.UserExpired := FieldByName('UCUSEREXPIRED').AsString;
        CurrentUser.UserDaysExpired := FieldByName('UCUSERDAYSSUN').AsInteger;
        CurrentUser.Email := FieldByName('UCEMAIL').AsString;
        if Granted then
        begin

          if (CurrentUser.UserID <> 0) then
            UsersLogged.AddCurrentUser;

          ApplyRightsUCControlMonitor;
          NotificationLoginMonitor;
        end;
      end;
    except
      on e: Exception do
        SendDebug('RegistraCurrentUser Exception', e.Message);
    end;
  finally
    Q.Free;
  end;
end;

procedure TFMXUserControl.TestaFecha(Sender: TObject; var CanClose: Boolean);
begin
  if frmLoginWindow.ModalResult = mrOk then
    CanClose := (CurrentUser.UserID > 0);
end;

procedure TFMXUserControl.ApplyRights;
var
  OwnerMenu: TComponent;
  Q: TFDQuery;
  MI: TMenuItem;
begin
  if CurrentUser.UserID <> 0 then
  begin
    Q := TFDQuery.Create(nil);
    try
      try
        with Q do
        begin
          Connection := FConnection;
          SQL.Add('SELECT R.CLAVE_USER, R.CLAVE_GROUP, R.COMPONENTE, R."KEY" ');
          SQL.Add('FROM INT$UC_RIGHTS R ');
          SQL.Add('WHERE (R.CLAVE_USER = :PCLAVE OR (R.CLAVE_GROUP IN (SELECT G.CLAVE_GROUP ');
          SQL.Add('FROM INT$UC_USER_GROUP G  ');
          SQL.Add('WHERE G.CLAVE_USER = :PCLAVE ');
          SQL.Add('AND G.UKEY = UPPER(F_ENCRYPTMD5(G.CLAVE_USER || G.CLAVE_GROUP))))) ');
          SQL.Add('AND R.MODULO=:PMODULO ');
          SQL.Add('AND R.COMPONENTE=:PCOMPONENTE ');
          SQL.Add('AND R."KEY" = UPPER(F_ENCRYPTMD5(COALESCE(R.CLAVE_USER,R.CLAVE_GROUP) || R.COMPONENTE)) ');
          { Empezamos con los permisos del menu }
          if Assigned(ControlRight.MainMenu) then
          begin
            OwnerMenu := ControlRight.MainMenu.Owner;
            // TForm(OwnerMenu).Menu := nil;
            UsersLogoff.MenuItem.Visible := True;
            // UsersLogoff.MenuItem.Parent.Visible := True;
            for MI in AllItems(ControlRight.MainMenu) do
            begin
              if (MI.Name <> UsersLogoff.MenuItem.Name) and (MI.Name <> UsersLogoff.MenuItem.Parent.Name) then
              begin
                Close;
                ParamByName('PCLAVE').AsInteger := CurrentUser.UserID;
                ParamByName('PMODULO').AsString := ApplicationID;
                ParamByName('PCOMPONENTE').AsString := MI.Name;
                Open;
                if RecordCount > 0 then
                  MI.Visible := True
                else
                  MI.Visible := NotAllowedItems.MenuVisible;
                if Assigned(OnApplyRightsMenuIt) then
                  OnApplyRightsMenuIt(Self, MI);
              end;
            end;
            // TForm(OwnerMenu).Menu := ControlRight.MainMenu;
          end;
          { permisos de acciones }

          if Assigned(FAfterLogin) then
            FAfterLogin(Self, CurrentUser.Empresa, CurrentUser.SelectedEmpresa);
        end;
      except
        on e: Exception do
          SendDebug('ApplyRights Exception', e.Message);
      end;
    finally
      Q.Free;
    end;
  end;

  // Permissao de Actions
  { if (Assigned(ControlRight.ActionList)) or (Assigned(ControlRight.ActionManager)) then
    begin
    if Assigned(ControlRight.ActionList) then
    ObjetoAction := ControlRight.ActionList

    else
    ObjetoAction := ControlRight.ActionManager

    for Contador := 0 to TActionList(ObjetoAction).ActionCount - 1 do begin
    if not FProfile then
    begin
    Encontrado := ADataset.Locate('ObjName', TActionList(ObjetoAction).Actions[Contador].Name, []);
    KeyField := ADataset.FindField('UCKey').AsString;
    // verifica key
    if Encontrado then
    case Self.Criptografia of
    cPadrao:
    Encontrado := (KeyField = Encrypt(ADataset.FieldByName('UserID').AsString + ADataset.FieldByName('ObjName').AsString, EncryptKey));
    cMD5:
    Encontrado := (KeyField = MD5Sum(ADataset.FieldByName('UserID').AsString + ADataset.FieldByName('ObjName').AsString));
    end;

    TAction(TActionList(ObjetoAction).Actions[Contador]).Enabled := Encontrado;

    if not Encontrado then
    TAction(TActionList(ObjetoAction).Actions[Contador]).Visible := NotAllowedItems.ActionVisible
    else
    TAction(TActionList(ObjetoAction).Actions[Contador]).Visible := True;
    end
    else if ADataset.Locate('ObjName', TActionList(ObjetoAction).Actions[Contador].Name, []) then
    begin
    KeyField := ADataset.FindField('UCKey').AsString;
    case Self.Criptografia of
    cPadrao:
    Encontrado := (KeyField = Encrypt(ADataset.FieldByName('UserID').AsString + ADataset.FieldByName('ObjName').AsString, EncryptKey));
    cMD5:
    Encontrado := (KeyField = MD5Sum(ADataset.FieldByName('UserID').AsString + ADataset.FieldByName('ObjName').AsString));
    end;
    TAction(TActionList(ObjetoAction).Actions[Contador]).Enabled := Encontrado;
    TAction(TActionList(ObjetoAction).Actions[Contador]).Visible := Encontrado;
    end;

    if Assigned(OnApplyRightsActionIt) then
    OnApplyRightsActionIt(Self, TAction(TActionList(ObjetoAction).Actions[Contador]));
    end;
    end; // Fim das permissões de Actions

    if Assigned(ControlRight.ActionMainMenuBar) then
    for Contador := 0 to ControlRight.ActionMainMenuBar.ActionClient.Items.Count - 1 do
    begin
    Temp := IntToStr(Contador);
    if ControlRight.ActionMainMenuBar.ActionClient.Items[StrToInt(Temp)].Items.Count > 0 then
    begin
    if Self.Criptografia = cPadrao then
    ControlRight.ActionMainMenuBar.ActionClient.Items[StrToInt(Temp)].Visible :=
    (ADataset.Locate('ObjName', #1 + 'G' + ControlRight.ActionMainMenuBar.ActionClient.Items[StrToInt(Temp)].Caption, [])) and
    (ADataset.FieldByName('UCKey').AsString = Encrypt(ADataset.FieldByName('UserID').AsString + ADataset.FieldByName('ObjName').AsString, EncryptKey));

    if Self.Criptografia = cMD5 then
    ControlRight.ActionMainMenuBar.ActionClient.Items[StrToInt(Temp)].Visible :=
    (ADataset.Locate('ObjName', #1 + 'G' + ControlRight.ActionMainMenuBar.ActionClient.Items[StrToInt(Temp)].Caption, [])) and
    (ADataset.FieldByName('UCKey').AsString = MD5Sum(ADataset.FieldByName('UserID').AsString + ADataset.FieldByName('ObjName').AsString));

    TrataActMenuBarIt(ControlRight.ActionMainMenuBar.ActionClient.Items[StrToInt(Temp)], ADataset);
    end;
    end;


    end; }
end;

procedure TFMXUserControl.UnlockEX(FormObj: TCustomForm; ObjName: String);
begin
  if FormObj.FindComponent(ObjName) = nil then
    exit;

  if FormObj.FindComponent(ObjName) is TControl then
  begin
    TControl(FormObj.FindComponent(ObjName)).Enabled := True;
    TControl(FormObj.FindComponent(ObjName)).Visible := True;
  end;

  if FormObj.FindComponent(ObjName) is TMenuItem then // TMenuItem
  begin
    TMenuItem(FormObj.FindComponent(ObjName)).Enabled := True;
    TMenuItem(FormObj.FindComponent(ObjName)).Visible := True;
    // chama evento OnApplyRightsMenuIt
    if Assigned(OnApplyRightsMenuIt) then
      OnApplyRightsMenuIt(Self, FormObj.FindComponent(ObjName) as TMenuItem);
  end;

  if FormObj.FindComponent(ObjName) is TAction then // TAction
  begin
    TAction(FormObj.FindComponent(ObjName)).Enabled := True;
    TAction(FormObj.FindComponent(ObjName)).Visible := True;
    // chama evento OnApplyRightsMenuIt
    if Assigned(OnApplyRightsActionIt) then
      OnApplyRightsActionIt(Self, FormObj.FindComponent(ObjName) as TAction);
  end;

  if FormObj.FindComponent(ObjName) is TField then // TField
  begin
    TField(FormObj.FindComponent(ObjName)).ReadOnly := False;
    TField(FormObj.FindComponent(ObjName)).Visible := True;
    TField(FormObj.FindComponent(ObjName)).onGetText := nil;
  end;
end;

procedure TFMXUserControl.LockEX(FormObj: TCustomForm; ObjName: String; naInvisible: Boolean);
begin
  if FormObj.FindComponent(ObjName) = nil then
    exit;

  if FormObj.FindComponent(ObjName) is TControl then
  begin
    TControl(FormObj.FindComponent(ObjName)).Enabled := False;
    TControl(FormObj.FindComponent(ObjName)).Visible := not naInvisible;
  end;

  if FormObj.FindComponent(ObjName) is TMenuItem then // TMenuItem
  begin
    TMenuItem(FormObj.FindComponent(ObjName)).Enabled := False;
    TMenuItem(FormObj.FindComponent(ObjName)).Visible := not naInvisible;
    // chama evento OnApplyRightsMenuIt
    if Assigned(OnApplyRightsMenuIt) then
      OnApplyRightsMenuIt(Self, FormObj.FindComponent(ObjName) as TMenuItem);
  end;

  if FormObj.FindComponent(ObjName) is TAction then // TAction
  begin
    TAction(FormObj.FindComponent(ObjName)).Enabled := False;
    TAction(FormObj.FindComponent(ObjName)).Visible := not naInvisible;
    // chama evento OnApplyRightsMenuIt
    if Assigned(OnApplyRightsActionIt) then
      OnApplyRightsActionIt(Self, FormObj.FindComponent(ObjName) as TAction);
  end;

  if FormObj.FindComponent(ObjName) is TField then // TField
  begin
    TField(FormObj.FindComponent(ObjName)).ReadOnly := True;
    TField(FormObj.FindComponent(ObjName)).Visible := not naInvisible;
    TField(FormObj.FindComponent(ObjName)).onGetText := HideField;
  end;
end;

{ .$ENDIF }

procedure TFMXUserControl.CriaTabelaRights(ExtraRights: Boolean = False);
begin
  //
end;

procedure TFMXUserControl.CriaTabelaLog;
begin
  //
end;

{ .$ENDIF }

procedure TFMXUserControl.CriaTabelaUsuarios(TableExists: Boolean);
begin
  //
end;

procedure TFMXUserControl.SetfLanguage(const Value: TUCLanguage);
begin
  fLanguage := Value;
  Self.UserSettings.Language := Value;
  FMX.UCSettings.AlterLanguage(Self.UserSettings);
end;

procedure TFMXUserControl.SetFMailUserControl(const Value: TFMXMailUserControl);
begin
  FMailUserControl := Value;
  FMailUserControl.FUserControl := Self;
  if Value <> nil then
    Value.FreeNotification(Self);
end;

procedure TFMXUserControl.ApplySettings(SourceSettings: TFMXUCSettings);
begin
  with UserSettings.CommonMessages do
  begin
    BlankPassword := SourceSettings.CommonMessages.BlankPassword;
    PasswordChanged := SourceSettings.CommonMessages.PasswordChanged;
    InitialMessage.Text := SourceSettings.CommonMessages.InitialMessage.Text;
    MaxLoginAttemptsError := SourceSettings.CommonMessages.MaxLoginAttemptsError;
    InvalidLogin := SourceSettings.CommonMessages.InvalidLogin;
    InactiveLogin := SourceSettings.CommonMessages.InactiveLogin;
    AutoLogonError := SourceSettings.CommonMessages.AutoLogonError;
    UsuarioExiste := SourceSettings.CommonMessages.UsuarioExiste;
    PasswordExpired := SourceSettings.CommonMessages.PasswordExpired;
    ForcaTrocaSenha := SourceSettings.CommonMessages.ForcaTrocaSenha;
  end;

  with UserSettings.Login do
  begin
    btCancel := SourceSettings.Login.btCancel;
    btOK := SourceSettings.Login.btOK;
    LabelPassword := SourceSettings.Login.LabelPassword;
    LabelUser := SourceSettings.Login.LabelUser;
    LabelForgetPassword := SourceSettings.Login.LabelForgetPassword;
    WindowCaption := SourceSettings.Login.WindowCaption;
    LabelTentativa := SourceSettings.Login.LabelTentativa;
    LabelTentativas := SourceSettings.Login.LabelTentativas;

    { if Assigned(SourceSettings.Login.LeftImage.Bitmap) then
      LeftImage.Bitmap := SourceSettings.Login.LeftImage.Bitmap
      else
      LeftImage.Bitmap := nil;

      if Assigned(SourceSettings.Login.TopImage.Bitmap) then
      TopImage.Bitmap := SourceSettings.Login.TopImage.Bitmap
      else
      TopImage.Bitmap := nil;

      if Assigned(SourceSettings.Login.BottomImage.Bitmap) then
      BottomImage.Bitmap := SourceSettings.Login.BottomImage.Bitmap
      else
      BottomImage.Bitmap := nil; }
  end;

  with UserSettings.UsersForm do
  begin
    WindowCaption := SourceSettings.UsersForm.WindowCaption;
    LabelDescription := SourceSettings.UsersForm.LabelDescription;
    ColName := SourceSettings.UsersForm.ColName;
    ColLogin := SourceSettings.UsersForm.ColLogin;
    ColEmail := SourceSettings.UsersForm.ColEmail;
    BtAdd := SourceSettings.UsersForm.BtAdd;
    BtChange := SourceSettings.UsersForm.BtChange;
    BtDelete := SourceSettings.UsersForm.BtDelete;
    BtRights := SourceSettings.UsersForm.BtRights;
    BtPassword := SourceSettings.UsersForm.BtPassword;
    BtClose := SourceSettings.UsersForm.BtClose;
    PromptDelete := SourceSettings.UsersForm.PromptDelete;
    PromptDelete_WindowCaption := SourceSettings.UsersForm.PromptDelete_WindowCaption; // added by fduenas
  end;

  with UserSettings.UsersProfile do
  begin
    WindowCaption := SourceSettings.UsersProfile.WindowCaption;
    LabelDescription := SourceSettings.UsersProfile.LabelDescription;
    ColProfile := SourceSettings.UsersProfile.ColProfile;
    BtAdd := SourceSettings.UsersProfile.BtAdd;
    BtChange := SourceSettings.UsersProfile.BtChange;
    BtDelete := SourceSettings.UsersProfile.BtDelete;
    BtRights := SourceSettings.UsersProfile.BtRights; // added by fduenas
    BtClose := SourceSettings.UsersProfile.BtClose;
    PromptDelete := SourceSettings.UsersProfile.PromptDelete;
    PromptDelete_WindowCaption := SourceSettings.UsersProfile.PromptDelete_WindowCaption; // added by fduenas
  end;

  with UserSettings.AddChangeUser do
  begin
    WindowCaption := SourceSettings.AddChangeUser.WindowCaption;
    LabelAdd := SourceSettings.AddChangeUser.LabelAdd;
    LabelChange := SourceSettings.AddChangeUser.LabelChange;
    LabelName := SourceSettings.AddChangeUser.LabelName;
    LabelLogin := SourceSettings.AddChangeUser.LabelLogin;
    LabelEmail := SourceSettings.AddChangeUser.LabelEmail;
    CheckPrivileged := SourceSettings.AddChangeUser.CheckPrivileged;
    BtSave := SourceSettings.AddChangeUser.BtSave;
    btCancel := SourceSettings.AddChangeUser.btCancel;
    CheckExpira := SourceSettings.AddChangeUser.CheckExpira;
    Day := SourceSettings.AddChangeUser.Day;
    ExpiredIn := SourceSettings.AddChangeUser.ExpiredIn;
  end;

  with UserSettings.AddChangeProfile do
  begin
    WindowCaption := SourceSettings.AddChangeProfile.WindowCaption;
    LabelAdd := SourceSettings.AddChangeProfile.LabelAdd;
    LabelChange := SourceSettings.AddChangeProfile.LabelChange;
    LabelName := SourceSettings.AddChangeProfile.LabelName;
    BtSave := SourceSettings.AddChangeProfile.BtSave;
    btCancel := SourceSettings.AddChangeProfile.btCancel;
  end;

  with UserSettings.Rights do
  begin
    WindowCaption := SourceSettings.Rights.WindowCaption;
    LabelUser := SourceSettings.Rights.LabelUser;
    LabelProfile := SourceSettings.Rights.LabelProfile;
    PageMenu := SourceSettings.Rights.PageMenu;
    PageActions := SourceSettings.Rights.PageActions;
    PageControls := SourceSettings.Rights.PageControls;
    BtUnlock := SourceSettings.Rights.BtUnlock;
    BtLock := SourceSettings.Rights.BtLock;
    BtSave := SourceSettings.Rights.BtSave;
    btCancel := SourceSettings.Rights.btCancel;
  end;

  with UserSettings.ChangePassword do
  begin
    WindowCaption := SourceSettings.ChangePassword.WindowCaption;
    LabelDescription := SourceSettings.ChangePassword.LabelDescription;
    LabelCurrentPassword := SourceSettings.ChangePassword.LabelCurrentPassword;
    LabelNewPassword := SourceSettings.ChangePassword.LabelNewPassword;
    LabelConfirm := SourceSettings.ChangePassword.LabelConfirm;
    BtSave := SourceSettings.ChangePassword.BtSave;
    btCancel := SourceSettings.ChangePassword.btCancel;
  end;

  with UserSettings.CommonMessages.ChangePasswordError do
  begin
    InvalidCurrentPassword := SourceSettings.CommonMessages.ChangePasswordError.InvalidCurrentPassword;
    NewPasswordError := SourceSettings.CommonMessages.ChangePasswordError.NewPasswordError;
    NewEqualCurrent := SourceSettings.CommonMessages.ChangePasswordError.NewEqualCurrent;
    PasswordRequired := SourceSettings.CommonMessages.ChangePasswordError.PasswordRequired;
    MinPasswordLength := SourceSettings.CommonMessages.ChangePasswordError.MinPasswordLength;
    InvalidNewPassword := SourceSettings.CommonMessages.ChangePasswordError.InvalidNewPassword;
  end;

  with UserSettings.ResetPassword do
  begin
    WindowCaption := SourceSettings.ResetPassword.WindowCaption;
    LabelPassword := SourceSettings.ResetPassword.LabelPassword;
  end;

  with UserSettings.Log do
  begin
    WindowCaption := SourceSettings.Log.WindowCaption;
    LabelDescription := SourceSettings.Log.LabelDescription;
    LabelUser := SourceSettings.Log.LabelUser;
    LabelDate := SourceSettings.Log.LabelDate;
    LabelLevel := SourceSettings.Log.LabelLevel;
    ColLevel := SourceSettings.Log.ColLevel;
    ColMessage := SourceSettings.Log.ColMessage;
    ColUser := SourceSettings.Log.ColUser;
    ColDate := SourceSettings.Log.ColDate;
    BtFilter := SourceSettings.Log.BtFilter;
    BtDelete := SourceSettings.Log.BtDelete;
    BtClose := SourceSettings.Log.BtClose;
    PromptDelete := SourceSettings.Log.PromptDelete;
    PromptDelete_WindowCaption := SourceSettings.Log.PromptDelete_WindowCaption; // added by fduenas
    OptionUserAll := SourceSettings.Log.OptionUserAll; // added by fduenas
    OptionLevelLow := SourceSettings.Log.OptionLevelLow; // added by fduenas
    OptionLevelNormal := SourceSettings.Log.OptionLevelNormal; // added by fduenas
    OptionLevelHigh := SourceSettings.Log.OptionLevelHigh; // added by fduenas
    OptionLevelCritic := SourceSettings.Log.OptionLevelCritic; // added by fduenas
    DeletePerformed := SourceSettings.Log.DeletePerformed; // added by fduenas
  end;

  with UserSettings.AppMessages do
  begin
    MsgsForm_BtNew := SourceSettings.AppMessages.MsgsForm_BtNew;
    MsgsForm_BtReplay := SourceSettings.AppMessages.MsgsForm_BtReplay;
    MsgsForm_BtForward := SourceSettings.AppMessages.MsgsForm_BtForward;
    MsgsForm_BtDelete := SourceSettings.AppMessages.MsgsForm_BtDelete;
    MsgsForm_BtClose := SourceSettings.AppMessages.MsgsForm_BtClose; // added by fduenas
    MsgsForm_WindowCaption := SourceSettings.AppMessages.MsgsForm_WindowCaption;
    MsgsForm_ColFrom := SourceSettings.AppMessages.MsgsForm_ColFrom;
    MsgsForm_ColSubject := SourceSettings.AppMessages.MsgsForm_ColSubject;
    MsgsForm_ColDate := SourceSettings.AppMessages.MsgsForm_ColDate;
    MsgsForm_PromptDelete := SourceSettings.AppMessages.MsgsForm_PromptDelete;
    MsgsForm_PromptDelete_WindowCaption := SourceSettings.AppMessages.MsgsForm_PromptDelete_WindowCaption;
    // added by fduenas
    MsgsForm_NoMessagesSelected := SourceSettings.AppMessages.MsgsForm_NoMessagesSelected; // added by fduenas
    MsgsForm_NoMessagesSelected_WindowCaption := SourceSettings.AppMessages.MsgsForm_NoMessagesSelected_WindowCaption; // added by fduenas

    MsgRec_BtClose := SourceSettings.AppMessages.MsgRec_BtClose;
    MsgRec_WindowCaption := SourceSettings.AppMessages.MsgRec_WindowCaption;
    MsgRec_Title := SourceSettings.AppMessages.MsgRec_Title;
    MsgRec_LabelFrom := SourceSettings.AppMessages.MsgRec_LabelFrom;
    MsgRec_LabelDate := SourceSettings.AppMessages.MsgRec_LabelDate;
    MsgRec_LabelSubject := SourceSettings.AppMessages.MsgRec_LabelSubject;
    MsgRec_LabelMessage := SourceSettings.AppMessages.MsgRec_LabelMessage;
    MsgSend_BtSend := SourceSettings.AppMessages.MsgSend_BtSend;
    MsgSend_BtCancel := SourceSettings.AppMessages.MsgSend_BtCancel;
    MsgSend_WindowCaption := SourceSettings.AppMessages.MsgSend_WindowCaption;
    MsgSend_Title := SourceSettings.AppMessages.MsgSend_Title;
    MsgSend_GroupTo := SourceSettings.AppMessages.MsgSend_GroupTo;
    MsgSend_RadioUser := SourceSettings.AppMessages.MsgSend_RadioUser;
    MsgSend_RadioAll := SourceSettings.AppMessages.MsgSend_RadioAll;
    MsgSend_GroupMessage := SourceSettings.AppMessages.MsgSend_GroupMessage;
    MsgSend_LabelSubject := SourceSettings.AppMessages.MsgSend_LabelSubject; // added by fduenas
    MsgSend_LabelMessageText := SourceSettings.AppMessages.MsgSend_LabelMessageText; // added by fduenas
  end;

  { with UserSettings.TypeFieldsDB do
    begin
    Type_VarChar   := SourceSettings.Type_VarChar;
    Type_Char      := SourceSettings.Type_Char;
    Type_Int       := SourceSettings.Type_Int;
    end;  atenção mudar aqui }

  UserSettings.WindowsPosition := SourceSettings.WindowsPosition;
end;

procedure TUCAutoLogin.Assign(Source: TPersistent);
begin
  if Source is TUCAutoLogin then
  begin
    Self.Active := TUCAutoLogin(Source).Active;
    Self.User := TUCAutoLogin(Source).User;
    Self.Password := TUCAutoLogin(Source).Password;
  end
  else
    inherited;
end;

constructor TUCAutoLogin.Create(AOwner: TComponent);
begin
  inherited Create;
  Self.Active := False;
  Self.MessageOnError := True;
end;

destructor TUCAutoLogin.Destroy;
begin
  inherited Destroy;
end;

procedure TUCNotAllowedItems.Assign(Source: TPersistent);
begin
  if Source is TUCNotAllowedItems then
  begin
    Self.MenuVisible := TUCNotAllowedItems(Source).MenuVisible;
    Self.ActionVisible := TUCNotAllowedItems(Source).ActionVisible; // Consertado Luiz Benvenuto
  end
  else
    inherited;
end;

constructor TUCNotAllowedItems.Create(AOwner: TComponent);
begin
  inherited Create;
  Self.MenuVisible := True;
  Self.ActionVisible := True;
end;

destructor TUCNotAllowedItems.Destroy;
begin
  inherited Destroy;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TLogControl'} {$ENDIF}
{ TLogControl }

constructor TUCLogControl.Create(AOwner: TComponent);
begin
  inherited Create;
  Self.Active := True;
end;

destructor TUCLogControl.Destroy;
begin
  inherited Destroy;
end;

procedure TUCLogControl.Assign(Source: TPersistent);
begin
  if Source is TUCLogControl then
  begin
    Self.Active := TUCLogControl(Source).Active;
    Self.TableLog := TUCLogControl(Source).TableLog;
  end
  else
    inherited;
end;

procedure TUCLogControl.SetAction(const Value: TAction);
begin
  FAction := Value;
  if Value <> nil then
  begin
    Self.FMenuItem := nil;
    Value.FreeNotification(Self.Action);
  end;
end;

procedure TUCLogControl.SetMenuItem(const Value: TMenuItem);
begin
  FMenuItem := Value;
  if Value <> nil then
  begin
    Self.Action := nil;
    Value.FreeNotification(Self.MenuItem);
  end;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TCadastroUsuarios'} {$ENDIF}
{ TCadastroUsuarios }

procedure TUCUser.Assign(Source: TPersistent);
begin
  if Source is TUCUser then
  begin
    Self.MenuItem := TUCUser(Source).MenuItem;
    Self.Action := TUCUser(Source).Action;
  end
  else
    inherited;
end;

constructor TUCUser.Create(AOwner: TComponent);
begin
  inherited Create;
  Self.FProtectAdministrator := True;
  Self.FUsePrivilegedField := False;
end;

destructor TUCUser.Destroy;
begin
  inherited Destroy;
end;

procedure TUCUser.SetAction(const Value: TAction);
begin
  FAction := Value;
  if Value <> nil then
  begin
    Self.FMenuItem := nil;
    Value.FreeNotification(Self.Action);
  end;
end;

procedure TUCUser.SetMenuItem(const Value: TMenuItem);
begin
  FMenuItem := Value;
  if Value <> nil then
  begin
    Self.Action := nil;
    Value.FreeNotification(Self.MenuItem);
  end;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TLogin'} {$ENDIF}
{ TLogin }

constructor TUCLogin.Create(AOwner: TComponent);
begin
  inherited Create;
  AutoLogin := TUCAutoLogin.Create(nil);
  InitialLogin := TUCInitialLogin.Create(nil);
  if not AutoLogin.MessageOnError then
    AutoLogin.MessageOnError := True;

  fDateExpireActive := False;
  fDaysOfSunExpired := 30;
end;

destructor TUCLogin.Destroy;
begin
  Self.FAutoLogin.Free;
  Self.FInitialLogin.Free;
  inherited Destroy;
end;

procedure TUCLogin.Assign(Source: TPersistent);
begin
  if Source is TUCLogin then
    Self.MaxLoginAttempts := TUCLogin(Source).MaxLoginAttempts
  else
    inherited;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TPerfilUsuarios'} {$ENDIF}
{ TPerfilUsuarios }

constructor TUCUserProfile.Create(AOwner: TComponent);
begin
  inherited Create;
  Self.Active := True;
end;

destructor TUCUserProfile.Destroy;
begin
  inherited Destroy;
end;

procedure TUCUserProfile.Assign(Source: TPersistent);
begin
  if Source is TUCUserProfile then
    Self.Active := TUCUserProfile(Source).Active
  else
    inherited;
end;

procedure TUCUserProfile.SetAction(const Value: TAction);
begin
  FAction := Value;
  if Value <> nil then
  begin
    Self.FMenuItem := nil;
    Value.FreeNotification(Self.Action);
  end;
end;

procedure TUCUserProfile.SetMenuItem(const Value: TMenuItem);
begin
  FMenuItem := Value;
  if Value <> nil then
  begin
    Self.Action := nil;
    Value.FreeNotification(Self.MenuItem);
  end;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TTrocarSenha'} {$ENDIF}
{ TTrocarSenha }

procedure TUCUserPasswordChange.Assign(Source: TPersistent);
begin
  if Source is TUCUserPasswordChange then
  begin
    Self.MenuItem := TUCUserPasswordChange(Source).MenuItem;
    Self.Action := TUCUserPasswordChange(Source).Action;
    Self.ForcePassword := TUCUserPasswordChange(Source).ForcePassword;
    Self.MinPasswordLength := TUCUserPasswordChange(Source).MinPasswordLength;
  end
  else
    inherited;
end;

constructor TUCUserPasswordChange.Create(AOwner: TComponent);
begin
  inherited Create;
  Self.ForcePassword := False;
end;

destructor TUCUserPasswordChange.Destroy;
begin
  inherited Destroy;
end;

procedure TUCUserPasswordChange.SetAction(const Value: TAction);
begin
  FAction := Value;
  if Value <> nil then
  begin
    Self.MenuItem := nil;
    Value.FreeNotification(Self.Action);
  end;
end;

procedure TUCUserPasswordChange.SetMenuItem(const Value: TMenuItem);
begin
  FMenuItem := Value;
  if Value <> nil then
  begin
    Self.Action := nil;
    Value.FreeNotification(Self.MenuItem);
  end;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TInitialLogin'} {$ENDIF}
{ TInitialLogin }

procedure TUCInitialLogin.Assign(Source: TPersistent);
begin
  if Source is TUCInitialLogin then
  begin
    Self.User := TUCInitialLogin(Source).User;
    Self.Password := TUCInitialLogin(Source).Password;
  end
  else
    inherited;
end;

constructor TUCInitialLogin.Create(AOwner: TComponent);
begin
  inherited Create;
  FInitialRights := TStringList.Create;
end;

destructor TUCInitialLogin.Destroy;
begin
  if Assigned(Self.FInitialRights) then
    Self.InitialRights.Free;
  inherited Destroy;
end;

procedure TUCInitialLogin.SetInitialRights(const Value: TStrings);
begin
  FInitialRights.Assign(Value);
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TUCControlRight'} {$ENDIF}
{ TUCControlRight }

procedure TUCControlRight.Assign(Source: TPersistent);
begin
  if Source is TUCControlRight then
    Self.ActionList := TUCControlRight(Source).ActionList
    { .$IFDEF UCACTMANAGER }
    { .$ENDIF }
  else
    inherited;
end;

constructor TUCControlRight.Create(AOwner: TComponent);
begin
  inherited Create;
end;

destructor TUCControlRight.Destroy;
begin
  inherited Destroy;
end;

procedure TUCControlRight.SetActionList(const Value: TActionList);
begin
  FActionList := Value;
  if Value <> nil then
    Value.FreeNotification(Self.ActionList);
end;

procedure TUCControlRight.SetMainMenu(const Value: TMainMenu);
begin
  FMainMenu := Value;
  if Value <> nil then
    Value.FreeNotification(Self.MainMenu);
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TUCAppMessage'} {$ENDIF}
{ TUCAppMessage }

procedure TFMXUCApplicationMessage.CheckMessages;

  function FmtDtHr(dt: String): String;
  begin
    Result := Copy(dt, 7, 2) + '/' + Copy(dt, 5, 2) + '/' + Copy(dt, 1, 4) + ' ' + Copy(dt, 9, 2) + ':' + Copy(dt, 11, 2);
  end;

begin
  { if not FReady then
    exit;

    with Self.UserControl.DataConnector.UCGetSQLDataset('SELECT UCM.IdMsg, ' + 'UCC.' + Self.UserControl.TableUsers.FieldUserName + ' AS De, ' + 'UCC_1.' +
    Self.UserControl.TableUsers.FieldUserName + ' AS Para, ' + 'UCM.Subject, ' + 'UCM.Msg, ' + 'UCM.DtSend, ' + 'UCM.DtReceive ' + 'FROM (' + Self.TableMessages +
    ' UCM INNER JOIN ' + Self.UserControl.TableUsers.TableName + ' UCC ON UCM.UsrFrom = UCC.' + Self.UserControl.TableUsers.FieldUserID + ') INNER JOIN ' +
    Self.UserControl.TableUsers.TableName + ' UCC_1 ON UCM.UsrTo = UCC_1.' + Self.UserControl.TableUsers.FieldUserID + ' where UCM.DtReceive is NULL and  UCM.UsrTo = ' +
    IntToStr(Self.UserControl.CurrentUser.UserID)) do
    begin
    while not Eof do
    begin
    MsgRecForm := TMsgRecForm.Create(Self);
    MsgRecForm.stDe.Caption := FieldByName('De').AsString;
    MsgRecForm.stData.Caption := FmtDtHr(FieldByName('DtSend').AsString);
    MsgRecForm.stAssunto.Caption := FieldByName('Subject').AsString;
    MsgRecForm.MemoMsg.Text := FieldByName('msg').AsString;
    if Assigned(Self.UserControl.DataConnector) then
    Self.UserControl.DataConnector.UCExecSQL('Update ' + Self.TableMessages + ' set DtReceive =  ' + QuotedStr(FormatDateTime('YYYYMMDDhhmm', now)) + ' Where  idMsg = ' +
    FieldByName('idMsg').AsString);
    MsgRecForm.Show;
    Next;
    end;
    Close;
    Free;
    end; }
end;

constructor TFMXUCApplicationMessage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FReady := False;
  if csDesigning in ComponentState then
  begin
    if Self.TableMessages = '' then
      Self.TableMessages := 'UCTABMESSAGES';
    Interval := 60000;
    Active := True;
  end;
  FVerifThread := TUCVerificaMensagemThread.Create(True, Self);
  FVerifThread.Start;
end;

destructor TFMXUCApplicationMessage.Destroy;
begin
  if not(csDesigning in ComponentState) then
    if Assigned(UserControl) then
      UserControl.DeleteLoginMonitor(Self);
  // Self.FVerifThread.Terminate;
  // if Assigned(Self.FVerifThread) then
  // FVerifThread.Free;
  inherited Destroy;
end;

procedure TFMXUCApplicationMessage.DeleteAppMessage(IdMsg: Integer);
begin
  { if MessageDlg(FUserControl.UserSettings.AppMessages.MsgsForm_PromptDelete, mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    exit;
    if Assigned(UserControl.DataConnector) then
    UserControl.DataConnector.UCExecSQL('Delete from ' + TableMessages + ' where IdMsg = ' + IntToStr(IdMsg)); }
end;

procedure TFMXUCApplicationMessage.Loaded;
begin
  { inherited;
    if not Active then
    exit;
    if not(csDesigning in ComponentState) then
    begin
    if not Assigned(FUserControl) then
    raise Exception.Create('Component UserControl not defined!');
    UserControl.AddLoginMonitor(Self);
    if not FUserControl.DataConnector.UCFindTable(TableMessages) then
    FUserControl.CriaTabelaMsgs(TableMessages);
    end;
    FReady := True; }
end;

procedure TFMXUCApplicationMessage.Notification(AComponent: TComponent; AOperation: TOperation);
begin
  if AOperation = opRemove then
    if AComponent = FUserControl then
      FUserControl := nil;
  inherited Notification(AComponent, AOperation);
end;

procedure TFMXUCApplicationMessage.SendAppMessage(ToUser: Integer; Subject, Msg: String);
begin
  { with UserControl.DataConnector.UCGetSQLDataset('Select Max(idMsg) as nr from ' + TableMessages) do
    begin
    UltId := FieldByName('nr').AsInteger + 1;
    Close;
    Free;
    end;
    if Assigned(UserControl.DataConnector) then
    UserControl.DataConnector.UCExecSQL('Insert into ' + TableMessages + '( idMsg, UsrFrom, UsrTo, Subject, Msg, DtSend) Values (' + IntToStr(UltId) + ', ' +
    IntToStr(UserControl.CurrentUser.UserID) + ', ' + IntToStr(ToUser) + ', ' + QuotedStr(Subject) + ', ' + QuotedStr(Msg) + ', ' +
    QuotedStr(FormatDateTime('YYYYMMDDHHMM', now)) + ')'); }

end;

procedure TFMXUCApplicationMessage.SetActive(const Value: Boolean);
begin
  { FActive := Value;
    if (csDesigning in ComponentState) then
    exit;
    if FActive then
    FVerifThread.Resume
    else
    FVerifThread.Suspend;

    if Active then
    begin
    if not(csDesigning in ComponentState) then
    begin
    if not Assigned(FUserControl) then
    raise Exception.Create('Component UserControl not defined!');
    UserControl.AddLoginMonitor(Self);
    if not FUserControl.DataConnector.UCFindTable(TableMessages) then
    FUserControl.CriaTabelaMsgs(TableMessages);
    end;
    FReady := True;
    end; }
end;

procedure TFMXUCApplicationMessage.SeTFMXUserControl(const Value: TFMXUserControl);
begin
  FUserControl := Value;
  if Value <> nil then
    Value.FreeNotification(Self);
end;

procedure TFMXUCApplicationMessage.ShowMessages;
begin
  { try
    MsgsForm := TMsgsForm.Create(Self);
    with FUserControl.UserSettings.AppMessages do
    begin
    MsgsForm.Caption := MsgsForm_WindowCaption;
    MsgsForm.btnova.Caption := MsgsForm_BtNew;
    MsgsForm.btResponder.Caption := MsgsForm_BtReplay;
    MsgsForm.btEncaminhar.Caption := MsgsForm_BtForward;
    MsgsForm.btExcluir.Caption := MsgsForm_BtDelete;
    MsgsForm.BtClose.Caption := MsgsForm_BtClose;

    MsgsForm.ListView1.Columns[0].Caption := MsgsForm_ColFrom;
    MsgsForm.ListView1.Columns[1].Caption := MsgsForm_ColSubject;
    MsgsForm.ListView1.Columns[2].Caption := MsgsForm_ColDate;
    end;

    MsgsForm.DSMsgs := UserControl.DataConnector.UCGetSQLDataset('SELECT UCM.IdMsg, UCM.UsrFrom, UCC.' + Self.UserControl.TableUsers.FieldUserName + ' AS De, UCC_1.' +
    Self.UserControl.TableUsers.FieldUserName + ' AS Para, UCM.Subject, UCM.Msg, UCM.DtSend, UCM.DtReceive ' + 'FROM (' + TableMessages + ' UCM INNER JOIN ' +
    UserControl.TableUsers.TableName + ' UCC ON UCM.UsrFrom = UCC.' + Self.UserControl.TableUsers.FieldUserID + ') ' + ' INNER JOIN ' + UserControl.TableUsers.TableName +
    ' UCC_1 ON UCM.UsrTo = UCC_1.' + Self.UserControl.TableUsers.FieldUserID + ' WHERE UCM.UsrTo = ' + IntToStr(UserControl.CurrentUser.UserID) + ' ORDER BY UCM.DtReceive DESC');
    MsgsForm.DSMsgs.Open;
    MsgsForm.DSUsuarios := UserControl.DataConnector.UCGetSQLDataset('SELECT ' + UserControl.TableUsers.FieldUserID + ' as idUser, ' + UserControl.TableUsers.FieldLogin +
    ' as Login, ' + UserControl.TableUsers.FieldUserName + ' as Nome, ' + UserControl.TableUsers.FieldPassword + ' as Senha, ' + UserControl.TableUsers.FieldEmail + ' as Email, '
    + UserControl.TableUsers.FieldPrivileged + ' as Privilegiado, ' + UserControl.TableUsers.FieldTypeRec + ' as Tipo, ' + UserControl.TableUsers.FieldProfile + ' as Perfil ' +
    ' FROM ' + UserControl.TableUsers.TableName + ' WHERE ' + UserControl.TableUsers.FieldUserID + ' <> ' + IntToStr(UserControl.CurrentUser.UserID) + ' AND ' +
    UserControl.TableUsers.FieldTypeRec + ' = ' + QuotedStr('U') + ' ORDER BY ' + UserControl.TableUsers.FieldUserName);
    MsgsForm.DSUsuarios.Open;

    MsgsForm.Position := Self.FUserControl.UserSettings.WindowsPosition;
    MsgsForm.ShowModal;
    finally
    end; }
end;

{ TVerifThread }

constructor TUCVerificaMensagemThread.Create(CreateSuspended: Boolean; AOwner: TComponent);
begin
  inherited Create(CreateSuspended);
  FAOwner := AOwner;
  FreeOnTerminate := True;
end;

destructor TUCVerificaMensagemThread.Destroy;
begin
  inherited Destroy;
end;

procedure TUCVerificaMensagemThread.Execute;
begin
  if (Assigned(TFMXUCApplicationMessage(FAOwner).UserControl)) and (TFMXUCApplicationMessage(FAOwner).UserControl.CurrentUser.UserID <> 0) then
    Synchronize(VerNovaMansagem);
  Sleep(TFMXUCApplicationMessage(FAOwner).Interval);
end;

procedure TUCVerificaMensagemThread.VerNovaMansagem;
begin
  TFMXUCApplicationMessage(FAOwner).CheckMessages;
end;

{ TUCCollectionItem }

function TUCExtraRightsItem.GetDisplayName: String;
begin
  Result := FFormName + '.' + FCompName;
  if Result = '' then
    Result := inherited GetDisplayName;
end;

procedure TUCExtraRightsItem.SetFormName(const Value: String);
begin
  if FFormName <> Value then
    FFormName := Value;
end;

procedure TUCExtraRightsItem.SetCompName(const Value: String);
begin
  if FCompName <> Value then
    FCompName := Value;
end;

procedure TUCExtraRightsItem.SetCaption(const Value: String);
begin
  if FCaption <> Value then
    FCaption := Value;
end;

procedure TUCExtraRightsItem.SetGroupName(const Value: String);
begin
  if FGroupName <> Value then
    FGroupName := Value;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TUCCollection'} {$ENDIF}
{ TUCCollection }

constructor TUCExtraRights.Create(UCBase: TFMXUserControl);
begin
  inherited Create(TUCExtraRightsItem);
  FUCBase := UCBase;
end;

function TUCExtraRights.Add: TUCExtraRightsItem;
begin
  Result := TUCExtraRightsItem(inherited Add);
end;

function TUCExtraRights.GetItem(Index: Integer): TUCExtraRightsItem;
begin
  Result := TUCExtraRightsItem(inherited GetItem(Index));
end;

procedure TUCExtraRights.SetItem(Index: Integer; Value: TUCExtraRightsItem);
begin
  inherited SetItem(Index, Value);
end;

function TUCExtraRights.GetOwner: TPersistent;
begin
  Result := FUCBase;
end;

procedure TUCExtraRights.Sort;
var
  i, Limit: Integer;
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    for i := Self.Count - 1 downto 0 do
      SL.AddObject(Items[i].FGroupName, Pointer(Items[i].ID));
    SL.Sort;
    Limit := SL.Count - 1;
    for i := 0 to Limit do
      Self.FindItemID(Integer(SL.Objects[i])).Index := i;
  finally
    SL.Free;
  end;
end;

{ TUCRun }

constructor TUCExecuteThread.Create(CreateSuspended: Boolean; AOwner: TComponent);
begin
  inherited Create(CreateSuspended);
  FAOwner := AOwner;
  FreeOnTerminate := True;
end;

destructor TUCExecuteThread.Destroy;
begin
  inherited Destroy;
end;

procedure TUCExecuteThread.Execute;
begin
  while not Self.Terminated do
  begin
    Synchronize(UCStart);
    Sleep(50);
  end;
end;

procedure TUCExecuteThread.UCStart;
begin
  TFMXUserControl(FAOwner).Execute;
end;

{ TFMXUCControls }

function TFMXUCControls.GetActiveForm: String;
begin
  Result := Owner.Name;
end;

function TFMXUCControls.GetAccessType: String;
begin
  if not Assigned(UserControl) then
    Result := ''
  else
    Result := UserControl.ClassName;
end;

procedure TFMXUCControls.ListComponents(Form: String; List: TStringList);
var
  Contador: Integer;
begin
  if not Assigned(List) then
    exit;
  if not Assigned(UserControl) then
    exit;
  List.Clear;
  for Contador := 0 to UserControl.ExtraRights.Count - 1 do
  begin
    if UpperCase(UserControl.ExtraRights[Contador].Formulario) = UpperCase(Form) then
      List.Add(UserControl.ExtraRights[Contador].Componente); // List.Append
  end;
end;

procedure TFMXUCControls.ApplyRights;
var
  FListObj: TStringList;
  i: Integer;
  Q: TFDQuery;
begin
  if not Assigned(UserControl) then
    exit;
  Q := TFDQuery.Create(nil);
  FListObj := TStringList.Create;
  try
    try
      with Q do
      begin
        Connection := FUserControl.FConnection;
        SQL.Add('SELECT R.CLAVE_USER, R.CLAVE_GROUP, R.COMPONENTE, R."KEY" ');
        SQL.Add('FROM INT$UC_RIGHTSEX R ');
        SQL.Add('WHERE (R.CLAVE_USER = :PCLAVE OR (R.CLAVE_GROUP IN (SELECT G.CLAVE_GROUP ');
        SQL.Add('FROM INT$UC_USER_GROUP G  ');
        SQL.Add('WHERE G.CLAVE_USER = :PCLAVE ');
        SQL.Add('AND G.UKEY = UPPER(F_ENCRYPTMD5(G.CLAVE_USER || G.CLAVE_GROUP))))) ');
        SQL.Add('AND R.MODULO=:PMODULO ');
        SQL.Add('AND R.COMPONENTE=:PCOMPONENTE ');
        SQL.Add('AND R.FORMULARIO=:PFORMULARIO ');
        SQL.Add('AND R."KEY" = UPPER(F_ENCRYPTMD5(COALESCE(R.CLAVE_USER,R.CLAVE_GROUP) || R.COMPONENTE)) ');
        if (UserControl.LoginMode = lmActive) and (UserControl.CurrentUser.UserID = 0) then
          exit;
        ListComponents(Self.Owner.Name, FListObj);
        for i := 0 to FListObj.Count - 1 do
        begin
          UserControl.UnlockEX(TCustomForm(Self.Owner), FListObj[i]);
          Close;
          ParamByName('PMODULO').AsString := UserControl.ApplicationID;
          ParamByName('PFORMULARIO').AsString := Self.Owner.Name;
          ParamByName('PCLAVE').AsInteger := UserControl.CurrentUser.UserID;
          ParamByName('PCOMPONENTE').AsString := FListObj[i];
          Open;
          if IsEmpty then
            UserControl.LockEX(TCustomForm(Self.Owner), FListObj[i], NotAllowed = naInvisible);
        end;
      end;
    except
      on e: Exception do
        FUserControl.SendDebug('TFMXUCControls.ApplyRights Exception', e.Message);
    end;
  finally
    FListObj.Free;
    Q.Free;
  end;
end;
{$WARNINGS ON}

procedure TFMXUCControls.LockControls;
var
  Contador: Integer;
  FListObj: TStringList;
begin
  FListObj := TStringList.Create;
  try
    Self.ListComponents(Self.Owner.Name, FListObj);
    for Contador := 0 to Pred(FListObj.Count) do
      UserControl.LockEX(TCustomForm(Self.Owner), FListObj[Contador], NotAllowed = naInvisible);
  finally
    FListObj.Free;
  end;
end;

procedure TFMXUCControls.Loaded;
begin
  inherited;
  if not(csDesigning in ComponentState) then
  begin
    ApplyRights;
    UserControl.AddUCControlMonitor(Self);
  end;
end;

procedure TFMXUCControls.SetGroupName(const Value: String);
var
  Contador: Integer;
begin
  if FGroupName = Value then
    exit;
  FGroupName := Value;
  if Assigned(UserControl) then
    for Contador := 0 to Pred(UserControl.ExtraRights.Count) do
      if UpperCase(UserControl.ExtraRights[Contador].Formulario) = UpperCase(Owner.Name) then
        UserControl.ExtraRights[Contador].GroupName := Value;
end;

destructor TFMXUCControls.Destroy;
begin
  if not(csDesigning in ComponentState) then
    if Assigned(UserControl) then
      UserControl.DeleteUCControlMonitor(Self);

  inherited Destroy;
end;

procedure TFMXUCControls.SeTFMXUserControl(const Value: TFMXUserControl);
begin
  FUserControl := Value;
  if Value <> nil then
    Value.FreeNotification(Self.UserControl);
end;

procedure TFMXUCControls.Notification(AComponent: TComponent; AOperation: TOperation);
begin
  if AOperation = opRemove then
    if AComponent = FUserControl then
      FUserControl := nil;

  inherited Notification(AComponent, AOperation);
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TUCGUID'} {$ENDIF}
{ TUCGUID }

class function TUCGUID.EmptyGUID: TGUID;
begin
  Result := FromString('{00000000-0000-0000-0000-000000000000}');
end;

class function TUCGUID.EqualGUIDs(GUID1, GUID2: TGUID): Boolean;
begin
  Result := IsEqualGUID(GUID1, GUID2);
end;

class function TUCGUID.FromString(Value: String): TGUID;
begin
  Result := StringToGuid(Value);
end;

class function TUCGUID.IsEmptyGUID(GUID: TGUID): Boolean;
begin
  Result := EqualGUIDs(GUID, EmptyGUID);
end;

class function TUCGUID.NovoGUID: TGUID;
var
  GUID: TGUID;
begin
  CreateGUID(GUID);
  Result := GUID;
end;

class function TUCGUID.NovoGUIDString: String;
begin
  Result := ToString(NovoGUID);
end;

class function TUCGUID.ToQuotedString(GUID: TGUID): String;
begin
  Result := QuotedStr(ToString(GUID));
end;

class function TUCGUID.ToString(GUID: TGUID): String;
begin
  Result := GuidToString(GUID);
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TUSERLOGGED'} {$ENDIF}
{ TUserLogged }

procedure TUCUsersLogged.AddCurrentUser;
var
  Q: TFDQuery;
  SGUID: String;
begin
  if not Active then
    exit;

  Q := TFDQuery.Create(nil);
  try
    try
      with Q, FUserControl do
      begin
        Q.Connection := FConnection;
        Q.Transaction := FMasterTransaccion;
        SGUID := TUCGUID.NovoGUIDString;
        CurrentUser.IdLogon := SGUID;
        SQL.Add('INSERT INTO INT$UC_USERSLOGGED');
        SQL.Add(' (CLAVE_USER,USER_SID,WINLOGIN,IDLOGON,APPLICATIONID,MACHINE,FECHA_HORA) ');
        SQL.Add('VALUES(:PCLAVE_USER,:PUSER_SID,:PWINLOGIN,:PIDLOGON,:PAPPLICATIONID,:PMACHINE,:PFECHA_HORA)');
        ParamByName('PCLAVE_USER').AsInteger := CurrentUser.UserID;
        ParamByName('PUSER_SID').AsString := CurrentUser.UserSID;
        ParamByName('PWINLOGIN').AsString := CurrentUser.UserDomain + '\' + CurrentUser.WinLogin;
        ParamByName('PIDLOGON').AsString := SGUID;
        ParamByName('PAPPLICATIONID').AsString := ApplicationID;
        ParamByName('PMACHINE').AsString := GetLocalComputerName;
        ParamByName('PFECHA_HORA').AsDateTime := now;
        if not Q.Transaction.Active then
          Q.Transaction.StartTransaction;
        ExecSQL;
        if Q.Transaction.Active then
          Q.Transaction.Commit;
      end;
    except
      on e: Exception do
      begin
        if Q.Transaction.Active then
          Q.Transaction.Rollback;
        FUserControl.SendDebug('TUCUsersLogged.AddCurrentUser Exception', e.Message);
      end;
    end;
  finally
    Q.Free;
  end;
end;

procedure TUCUsersLogged.Assign(Source: TPersistent);
begin
  if Source is TUCUsersLogged then
  begin
    Self.Active := TUCUsersLogged(Source).Active;
  end
  else
    inherited;
end;

constructor TUCUsersLogged.Create(AOwner: TComponent);
begin
  inherited Create;
  FUserControl := TFMXUserControl(AOwner);
  Self.FAtive := True;
end;

procedure TUCUsersLogged.CriaTableUserLogado;
begin
  //
end;

procedure TUCUsersLogged.DelCurrentUser;
var
  Q: TFDQuery;
begin
  if not Active then
    exit;
  Q := TFDQuery.Create(nil);
  try
    try
      with FUserControl do
      begin
        Q.Connection := FConnection;
        Q.Transaction := FMasterTransaccion;
        Q.SQL.Add('DELETE FROM INT$UC_USERSLOGGED ');
        Q.SQL.Add(' WHERE IDLOGON=:PIDLOGON');
        Q.ParamByName('PIDLOGON').AsString := CurrentUser.IdLogon;
        if not Q.Transaction.Active then
          Q.Transaction.StartTransaction;
        Q.ExecSQL;
        if Q.Transaction.Active then
          Q.Transaction.Commit;
      end;
    except
      on e: Exception do
      begin
        if Q.Transaction.Active then
          Q.Transaction.Rollback;
        FUserControl.SendDebug('TUCUsersLogged.DelCurrentUser Exception', e.Message);
      end;
    end;
  finally
    Q.Free;
  end;
end;

destructor TUCUsersLogged.Destroy;
begin
  inherited Destroy;
end;

function TUCUsersLogged.UsuarioJaLogado(ID: Integer): Boolean;
var
  SQLstmt: String;
begin
  Result := False;
  // if Assigned(FUserControl.DataConnector) = False then
  // exit;

  with FUserControl do
  begin
    SQLstmt := Format('SELECT * FROM %s WHERE %s = %s', [TableUsersLogged.TableName, TableUsersLogged.FieldUserID, QuotedStr(IntToStr(ID))]);

    { if Assigned(DataConnector) then
      begin
      FDataset := DataConnector.UCGetSQLDataset(SQLstmt);
      Result := not(FDataset.IsEmpty);
      end; }
  end;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TUCUserLogoff'} {$ENDIF}
{ TUCUserLogoff }

procedure TUCUserLogoff.Assign(Source: TPersistent);
begin
  if Source is TUCUserLogoff then
  begin
    Self.MenuItem := TUCUserLogoff(Source).MenuItem;
    Self.Action := TUCUserLogoff(Source).Action;
  end
  else
    inherited;
end;

constructor TUCUserLogoff.Create(AOwner: TComponent);
begin
  inherited Create;
end;

destructor TUCUserLogoff.Destroy;
begin
  inherited Destroy;
end;

procedure TUCUserLogoff.SetAction(const Value: TAction);
begin
  FAction := Value;
  if Value <> nil then
  begin
    Self.MenuItem := nil;
    Value.FreeNotification(Self.Action);
  end;
end;

procedure TUCUserLogoff.SetMenuItem(const Value: TMenuItem);
begin
  FMenuItem := Value;
  if Value <> nil then
  begin
    Self.Action := nil;
    Value.FreeNotification(Self.MenuItem);
  end;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}
{$IFDEF DELPHI9_UP} {$REGION 'TUCCurrentUser'} {$ENDIF}
{ TUCCurrentUser }

constructor TUCCurrentUser.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TUCCurrentUser.Destroy;
begin
  inherited;
end;

{$IFDEF DELPHI9_UP} {$ENDREGION} {$ENDIF}

end.
