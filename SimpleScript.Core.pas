unit SimpleScript.Core;

interface

uses
	SimpleScript.Exceptions,
   Classes, Contnrs, SysUtils, Windows;

const
	EFLAG_USER: Integer = 1024;
   NMSG_USER: Integer = 1024;
   PRET_USER: Integer = 1024;

   NMSG_PARSE_START: Integer = 2;
   NMSG_PARSE_FINISH: Integer = 4;

   PRET_STKOVERFLOW_TERMINATION: Integer = 666;

   PA_ROOT_PARSE: Integer = 2;

   MAX_ERROR_COUNT: Integer = 99; //0 = no max

type

	{Forward...}
   TSimpleScriptExtender = class;

   {Classe de extensão de script, tem vários propósitos}
	TSimpleScriptExtension = class(TObject)
  		strict private
    		FOwner: TSimpleScriptExtender;
         FFlags: Integer;
      public
      	{Construtor, recebe obrigatóriamente um TSimpleScriptExtender como Owner}
      	constructor Create(AOwner: TSimpleScriptExtender); virtual;
         {Owner é Extensor (TSimpleScriptExtender) ao qual essa extensão pertence}
         property Owner: TSimpleScriptExtender read FOwner;
         {Flags}
         property Flags: Integer read FFlags write FFlags;
   end;

   {Referência de classe de extensão (TSimpleScriptExtension)}
   TSimpleScriptExtensionClass = class of TSimpleScriptExtension;

   {Forward...}
   TSimpleScriptExtensionList = class;

   {Enumerador de iteração da classe TSimpleScriptExtensionList}
   TSimpleScriptExtensionListEnumerator = class(TObject)
      private
         FIndex: Integer;
         FList: TSimpleScriptExtensionList;
      public
         constructor Create(AList: TSimpleScriptExtensionList);
         function GetCurrent: TSimpleScriptExtension; inline;
         function MoveNext: Boolean;
         property Current: TSimpleScriptExtension read GetCurrent;
   end;

   {Classe que representa uma lista de extensões (objetos TSimpleScriptExtension)}
   TSimpleScriptExtensionList = class(TObjectList)
		protected
			function GetItem(Index: Integer): TSimpleScriptExtension; inline;
			procedure SetItem(Index: Integer; AObject: TSimpleScriptExtension); inline;
      public
         function GetEnumerator: TSimpleScriptExtensionListEnumerator;
         function Add(AObject: TSimpleScriptExtension): Integer; inline;
         function Extract(Item: TSimpleScriptExtension): TSimpleScriptExtension; inline;
         function Remove(AObject: TSimpleScriptExtension): Integer; overload; inline;
         {$IFDEF VER210}
         function ExtractItem(Item: TSimpleScriptExtension; Direction: TList.TDirection): TSimpleScriptExtension; inline;
         function RemoveItem(AObject: TSimpleScriptExtension; ADirection: TList.TDirection): Integer; inline;
         function IndexOfItem(AObject: TSimpleScriptExtension; ADirection: TList.TDirection): Integer; inline;
         {$ENDIF}
         function IndexOf(AObject: TSimpleScriptExtension): Integer; inline;
         function First: TSimpleScriptExtension; inline;
         function Last: TSimpleScriptExtension; inline;
         {Retorna uma outra lista de extensões somente com o tipo especificado pelo parâmetro AType}
         function GetTypedList(AType: TSimpleScriptExtensionClass): TSimpleScriptExtensionList; inline;
         procedure Insert(Index: Integer; AObject: TSimpleScriptExtension); inline;
         property Items[Index: Integer]: TSimpleScriptExtension read GetItem write SetItem; default;
   end;

   {Forward...}
   TSimpleScriptContext = class;

   {Classe de extensor de script, cada extensor publica e mantém dados de diferentes extensões}
   TSimpleScriptExtender = class(TObject)
      strict private
    		FExtensions: TSimpleScriptExtensionList;
         FOwner: TSimpleScriptContext;
      strict protected
      	function GetNamespace: String; virtual; abstract;
      public
      	{Construtor, recebe obrigatóriamente o contexto de execução de script ao qual este extensor será inserido}
      	constructor Create(AOwner: TSimpleScriptContext); virtual;
         {Destrutor da classe}
         destructor Destroy; override;
         {Namespace é um conjunto lógico ao qual as extensões deste extensor pertencem}
      	property Namespace: String read GetNamespace;
         {Contexto ao qual este extensor está inserido}
         property Owner: TSimpleScriptContext read FOwner;
         {Lista de extensões deste extensor}
         property Extensions: TSimpleScriptExtensionList read FExtensions;
         {Checa se o namespace passado em Value é o mesmo deste extensor ou se Value é um nome/caracter coringa,
         retornando sempre True caso seja mas só se AllowWildcard for True}
         function NamespaceIs(const Value: String; const AllowWildcard: Boolean = True): Boolean;
         {}
         function Notify(const Msg: Integer): Integer; virtual; abstract;
   end;

   {Referência de classe de extensor (TSimpleScriptExtender)}
   TSimpleScriptExtenderClass = class of TSimpleScriptExtender;

   {Forward...}
   TSimpleScriptExtenderList = class;

   {Enumerador de iteração da lista de extensores (TSimpleScriptExtenderList)}
   TSimpleScriptExtenderListEnumerator = class(TObject)
      private
         FIndex: Integer;
         FList: TSimpleScriptExtenderList;
      public
         constructor Create(AList: TSimpleScriptExtenderList);
         function GetCurrent: TSimpleScriptExtender; inline;
         function MoveNext: Boolean;
         property Current: TSimpleScriptExtender read GetCurrent;
   end;

   {Classe que representa uma lista de extensores (objetos TSimpleScriptExtender)}
   TSimpleScriptExtenderList = class(TObjectList)
   	protected
			function GetItem(Index: Integer): TSimpleScriptExtender; inline;
			procedure SetItem(Index: Integer; AObject: TSimpleScriptExtender); inline;
      public
         function GetEnumerator: TSimpleScriptExtenderListEnumerator;
         {Adiciona uma classe de extensor à lista. O próprio método instancia o objeto com base em AClass}
         function AddClass(AClass: TSimpleScriptExtenderClass; AOwner: TSimpleScriptContext): Integer; inline;
         function Add(AObject: TSimpleScriptExtender): Integer; inline;
         function Extract(Item: TSimpleScriptExtender): TSimpleScriptExtender; inline;
         {$IFDEF VER210}
         function ExtractItem(Item: TSimpleScriptExtender; Direction: TList.TDirection): TSimpleScriptExtender; inline;
         function RemoveItem(AObject: TSimpleScriptExtender; ADirection: TList.TDirection): Integer; inline;
         function IndexOfItem(AObject: TSimpleScriptExtender; ADirection: TList.TDirection): Integer; inline;
         {$ENDIF}
         function Remove(AObject: TSimpleScriptExtender): Integer; overload; inline;
         function IndexOf(AObject: TSimpleScriptExtender): Integer; inline;
         function First: TSimpleScriptExtender; inline;
         function Last: TSimpleScriptExtender; inline;
         procedure Insert(Index: Integer; AObject: TSimpleScriptExtender); inline;
         property Items[Index: Integer]: TSimpleScriptExtender read GetItem write SetItem; default;
   end;

   {Tipo de erro no contexto de execução de script}
   TContextErrorKind = (ekInfo, ekWarning, ekError);

   {Registro que define as propriedades de um erro no contexto de execução de script}
   TSimpleScriptContextError = record
   	{Tipo de erro}
      Kind: TContextErrorKind;
      {Código de identidifação do erro}
      Code: String;
      {Descrição do erro}
      Description: String;
      {Linha onde ocorreu o erro}
      Line: Integer;
      {Caracter/coluna onde ocorreu o erro}
      Column: Integer;
      {Arquivo no qual ocorreu o erro}
      FileName: String;
   end;

   {Array de registros de erros de contexto de execução de script}
   TSimpleScriptContextErrorArray = array of TSimpleScriptContextError;

   {Evento de novo erro adiconado}
   TNewErrorEvent = procedure(const Error: TSimpleScriptContextError) of object;

   {Classe que representa uma lista de erros de contexto (TSimpleScriptContextError)}
   TSimpleScriptContextErrorList = class(TObject)
   	strict private
         FErrors: TSimpleScriptContextErrorArray;
         FCount: Integer;
         FCountInfo: Integer;
         FCountWarning: Integer;
         FCountError: Integer;
         FOnNewError: TNewErrorEvent;
    		function GetError(Index: Integer): TSimpleScriptContextError;
    		procedure SetError(Index: Integer; const Value: TSimpleScriptContextError);
         procedure DoOnNewError(const Error: TSimpleScriptContextError);
      public
      	{Construtor da classe}
      	constructor Create;
         {Destrutor da classe}
         destructor Destroy; override;
         {Itens da lista acessados por seu índice de base 0}
         property Items[Index: Integer]: TSimpleScriptContextError read GetError write SetError; default;
         {Quantidade de itens na lista}
         property Count: Integer read FCount;
         {Quantidade de itens na lista do tipo ekInfo}
         property CountInfo: Integer read FCountInfo;
         {Quantidade de itens na lista do tipo ekWarning}
         property CountWarning: Integer read FCountWarning;
         {Quantidade de itens na lista do tipo ekError}
         property CountError: Integer read FCountError;
         {Cria e insere um novo registro de erro na lista}
         function New(const Code, Description: String; Kind: TContextErrorKind; const Line: Integer = 0;
            const Column: Integer = 0; const FileName: String = ''): TSimpleScriptContextError;
         {Remove todos os registros de erro da lista}
         procedure Clear;
         {Evento de novo erro adicionado}
         property OnNewError: TNewErrorEvent read FOnNewError write FOnNewError;
   end;

   {Classe base de extensão de script do tipo Parser}
   TExtensionParser = class(TSimpleScriptExtension)
      strict private
         FCurrentLine: Integer;
         FCurrentColumn: Integer;
         FCurrentFile: String;
      strict protected
         function GetCurrentColumn: Integer; virtual;
         function GetCurrentFile: String; virtual;
         function GetCurrentLine: Integer; virtual;
         procedure SetCurrentColumn(const Value: Integer); virtual;
         procedure SetCurrentFile(const Value: String); virtual;
         procedure SetCurrentLine(const Value: Integer); virtual;
         function GetActive: Boolean; virtual; abstract;
      public
      	{Recebe uma string com um script em Input e retorna o resultado do processo em Output.
         Extra é um parâmetro opcional de flags.}
         procedure Parse(const Input: String; out Output: String; const Extra: Integer = 0); virtual; abstract;
         property Active: Boolean read GetActive;
         property CurrentLine: Integer read GetCurrentLine write SetCurrentLine;
         property CurrentColumn: Integer read GetCurrentColumn write SetCurrentColumn;
         property CurrentFile: String read GetCurrentFile write SetCurrentFile;
   end;

   {Classe responsável por registrar o tempo gasto em uma execução de um método}
   TPerformanceCounter = class(TObject)
      private
      	FPerfFreq,
         FOverhead, FOverhead_St, FOverhead_Sp,
         FPerfStart, FPerfStop: Int64;
         FEllapsedTime: Extended;
      public
      	{Inicia a contagem}
         procedure Start;
         {Pára a contagem}
         procedure Stop;
         {Registra o tempo decorrido entre as chamadas aos métodos Start e Stop em milissegundos}
         property EllapsedTime: Extended read FEllapsedTime;
   end;

   {}
   TContextExecStatus = (csIdle, csRunning, csSuspended, csTerminating);

   {}
   TContextExecThread = class(TThread)
      strict private
      	FOwnerContext: TSimpleScriptContext;
         FInput: String;
         FOutput: String;
      protected
      	procedure Execute; override;
      public
      	constructor Create(AContext: TSimpleScriptContext); reintroduce;
         property OwnerContext: TSimpleScriptContext read FOwnerContext;
         property Input: String read FInput write FInput;
         property Output: String read FOutput;
   end;

   {Classe de contexto de execução de script}
   TSimpleScriptContext = class(TObject)
      strict private
    		FExtenders: TSimpleScriptExtenderList;
    		FDefaultNamespace: String;
         FErrors: TSimpleScriptContextErrorList;
         FActiveParser: TExtensionParser;
         FPerfCounter: TPerformanceCounter;
         FLocalFormatSettings: TFormatSettings;

         FExecThread: TContextExecThread;
         FOnParseComplete: TNotifyEvent;
         FStatus: TContextExecStatus;
         FInput: String;
         FOutput: String;
         FlagIgnoreOnNewErr: Boolean;
         FMaxErrorCount: Integer;

         procedure DoOnParseComplete;
         procedure OnThreadExecTerminate(Sender: TObject);
         procedure OnNewError(const Error: TSimpleScriptContextError);
      public
      	{Construtor da classe}
      	constructor Create;
         {Destrutor da classe}
         destructor Destroy; override;
         {Copia os membros de um contexto (Source) para este contexto, inclusive os extensores}
         procedure Assign(Source: TSimpleScriptContext);
         {Lista de extensores inseridos neste contexto}
         property Extenders: TSimpleScriptExtenderList read FExtenders;
         {Namespace padrão usado por algumas extensões}
         property DefaultNamespace: String read FDefaultNamespace write FDefaultNamespace;
         {Lista de erros deste contexto}
         property Errors: TSimpleScriptContextErrorList read FErrors;
         {Extensão do tipo Parser atualmente sendo utilizada}
         property ActiveParser: TExtensionParser read FActiveParser write FActiveParser;
         {Contador de perfomance usado para contar o tempo de excução}
         property PerformanceCounter: TPerformanceCounter read FPerfCounter;
         {Configurações de formato de data, hora, moeda etc... usadas em algumas extensões}
         property LocalFormatSettings: TFormatSettings read FLocalFormatSettings;
         {Retorna uma lista de extensões somente do tipo AType e que pertençam ao namespace especificado}
         function GetTypedExtensionList(AType: TSimpleScriptExtensionClass; ANamespace: String = ''): TSimpleScriptExtensionList; inline;
         {}
         property MaxErrorCount: Integer read FMaxErrorCount write FMaxErrorCount;
         {}
         procedure Parse;
         {}
         property Input: String read FInput write FInput;
         {}
         property Output: String read FOutput;
         {}
         property OnParseComplete: TNotifyEvent read FOnParseComplete write FOnParseComplete;
         {}
         property Status: TContextExecStatus read FStatus;
         {}
         procedure SetParseReturnValue(const Value: Integer);
         {}
         procedure StopParse;
   end;

   {Classe principal do SimpleScript.Core, responsável por manusear contextos de execução de script}
   {$IFNDEF VER210}
   TMain = class sealed(TObject)
   {$ELSE}
   Main = class sealed(TObject)
   {$ENDIF}
      strict private
      	class var
    			FDefaultContext: TSimpleScriptContext;

         class procedure FreeDefaultContext; static; inline;
    		class procedure SetDefaultContext(const Value: TSimpleScriptContext); static;
      public
        {$IFDEF VER210}
        class constructor Create;
        class destructor Destroy;
        {$ELSE}
        constructor Create;
        destructor Destroy; override;
        {$ENDIF}
         {Contexto de execução padrão já instaciado pela classe Main}
         class property DefaultContext: TSimpleScriptContext read FDefaultContext write SetDefaultContext;
         {Retorna uma cópia do contexto de execuação padrão}
         class function GetContext: TSimpleScriptContext;
         {Retorna um novo contexto de execução em branco (sem os extensores)}
         class function GetBlankContext: TSimpleScriptContext;
         {Adicona uma classe de extensor ao contexto padrão, o próprio método instancia o objeto com base
         na referência AClass}
         class procedure AddDefaultContextExtenderClass(AClass: TSimpleScriptExtenderClass);
   end;

{$IFNDEF VER210}
var
    Main: TMain;
{$ENDIF}

implementation

{ TSimpleScriptExtensionListEnumerator }

constructor TSimpleScriptExtensionListEnumerator.Create(AList: TSimpleScriptExtensionList);
begin
	inherited Create;
  	FIndex := -1;
  	FList := AList;
end;

function TSimpleScriptExtensionListEnumerator.GetCurrent: TSimpleScriptExtension;
begin
	Result := FList[FIndex];
end;

function TSimpleScriptExtensionListEnumerator.MoveNext: Boolean;
begin
	Result := FIndex < FList.Count - 1;
  	if Result then
   	Inc(FIndex);
end;

{ TSimpleScriptExtensionList }

function TSimpleScriptExtensionList.Add(AObject: TSimpleScriptExtension): Integer;
begin
	Result := inherited Add(AObject);
end;

function TSimpleScriptExtensionList.Extract(Item: TSimpleScriptExtension): TSimpleScriptExtension;
begin
	Result := TSimpleScriptExtension(inherited Extract(Item));
end;

{$IFDEF VER210}
function TSimpleScriptExtensionList.ExtractItem(Item: TSimpleScriptExtension;
  Direction: TList.TDirection): TSimpleScriptExtension;
begin
	Result := TSimpleScriptExtension(inherited ExtractItem(Item, Direction));
end;
{$ENDIF}

function TSimpleScriptExtensionList.First: TSimpleScriptExtension;
begin
	Result := TSimpleScriptExtension(inherited First);
end;

function TSimpleScriptExtensionList.GetEnumerator: TSimpleScriptExtensionListEnumerator;
begin
	Result := TSimpleScriptExtensionListEnumerator.Create(Self);
end;

function TSimpleScriptExtensionList.GetItem(Index: Integer): TSimpleScriptExtension;
begin
	Result := TSimpleScriptExtension(inherited Items[Index]);
end;

function TSimpleScriptExtensionList.GetTypedList(
  AType: TSimpleScriptExtensionClass): TSimpleScriptExtensionList;
var
   curExtension: TSimpleScriptExtension;
begin
   Result := TSimpleScriptExtensionList.Create;
   Result.OwnsObjects := False;

   for curExtension in Self do begin
      if not(curExtension is AType) then continue;
      Result.Add(curExtension);
   end;
end;

function TSimpleScriptExtensionList.IndexOf(AObject: TSimpleScriptExtension): Integer;
begin
	Result := inherited IndexOf(AObject);
end;

{$IFDEF VER210}
function TSimpleScriptExtensionList.IndexOfItem(AObject: TSimpleScriptExtension; ADirection: TList.TDirection): Integer;
begin
	Result := inherited IndexOfItem(AObject, ADirection);
end;
{$ENDIF}

procedure TSimpleScriptExtensionList.Insert(Index: Integer; AObject: TSimpleScriptExtension);
begin
	inherited Insert(Index, AObject);
end;

function TSimpleScriptExtensionList.Last: TSimpleScriptExtension;
begin
	Result := TSimpleScriptExtension(inherited Last);
end;

function TSimpleScriptExtensionList.Remove(AObject: TSimpleScriptExtension): Integer;
begin
	Result := inherited Remove(AObject);
end;

{$IFDEF VER210}
function TSimpleScriptExtensionList.RemoveItem(AObject: TSimpleScriptExtension; ADirection: TList.TDirection): Integer;
begin
	Result := inherited RemoveItem(AObject, ADirection);
end;
{$ENDIF}

procedure TSimpleScriptExtensionList.SetItem(Index: Integer; AObject: TSimpleScriptExtension);
begin
	inherited Items[Index] := AObject;
end;

{ TSimpleScriptExtenderListEnumerator }

constructor TSimpleScriptExtenderListEnumerator.Create(AList: TSimpleScriptExtenderList);
begin
	inherited Create;
  	FIndex := -1;
  	FList := AList;
end;

function TSimpleScriptExtenderListEnumerator.GetCurrent: TSimpleScriptExtender;
begin
	Result := FList[FIndex];
end;

function TSimpleScriptExtenderListEnumerator.MoveNext: Boolean;
begin
	Result := FIndex < FList.Count - 1;
  	if Result then
   	Inc(FIndex);
end;

{ TSimpleScriptExtenderList }

function TSimpleScriptExtenderList.Add(AObject: TSimpleScriptExtender): Integer;
begin
	Result := inherited Add(AObject);
end;

function TSimpleScriptExtenderList.AddClass(AClass: TSimpleScriptExtenderClass; AOwner: TSimpleScriptContext): Integer;
var
   ClassObj: TSimpleScriptExtender;
begin
	Result := -1;
	if AClass = nil then exit;

	ClassObj := AClass.Create(AOwner);
   Result := Self.Add(ClassObj);
end;

function TSimpleScriptExtenderList.Extract(Item: TSimpleScriptExtender): TSimpleScriptExtender;
begin
	Result := TSimpleScriptExtender(inherited Extract(Item));
end;

{$IFDEF VER210}
function TSimpleScriptExtenderList.ExtractItem(Item: TSimpleScriptExtender;
  Direction: TList.TDirection): TSimpleScriptExtender;
begin
	Result := TSimpleScriptExtender(inherited ExtractItem(Item, Direction));
end;
{$ENDIF}

function TSimpleScriptExtenderList.First: TSimpleScriptExtender;
begin
	Result := TSimpleScriptExtender(inherited First);
end;

function TSimpleScriptExtenderList.GetEnumerator: TSimpleScriptExtenderListEnumerator;
begin
	Result := TSimpleScriptExtenderListEnumerator.Create(Self);
end;

function TSimpleScriptExtenderList.GetItem(Index: Integer): TSimpleScriptExtender;
begin
	Result := TSimpleScriptExtender(inherited Items[Index]);
end;

function TSimpleScriptExtenderList.IndexOf(AObject: TSimpleScriptExtender): Integer;
begin
	Result := inherited IndexOf(AObject);
end;

{$IFDEF VER210}
function TSimpleScriptExtenderList.IndexOfItem(AObject: TSimpleScriptExtender; ADirection: TList.TDirection): Integer;
begin
	Result := inherited IndexOfItem(AObject, ADirection);
end;
{$ENDIF}

procedure TSimpleScriptExtenderList.Insert(Index: Integer; AObject: TSimpleScriptExtender);
begin
	inherited Insert(Index, AObject);
end;

function TSimpleScriptExtenderList.Last: TSimpleScriptExtender;
begin
	Result := TSimpleScriptExtender(inherited Last);
end;

function TSimpleScriptExtenderList.Remove(AObject: TSimpleScriptExtender): Integer;
begin
	Result := inherited Remove(AObject);
end;

{$IFDEF VER210}
function TSimpleScriptExtenderList.RemoveItem(AObject: TSimpleScriptExtender; ADirection: TList.TDirection): Integer;
begin
	Result := inherited RemoveItem(AObject, ADirection);
end;
{$ENDIF}

procedure TSimpleScriptExtenderList.SetItem(Index: Integer; AObject: TSimpleScriptExtender);
begin
	inherited Items[Index] := AObject;
end;

{ TSimpleScriptExtender }

constructor TSimpleScriptExtender.Create(AOwner: TSimpleScriptContext);
begin
	if not Assigned(AOwner) then
      raise SimpleScript.Exceptions.ExtenderException.Create(SSEX_EXTENDER_NoOwner);

   FOwner := AOwner;
   FExtensions := TSimpleScriptExtensionList.Create;
end;

destructor TSimpleScriptExtender.Destroy;
begin
	if Assigned(FExtensions) then
   	FExtensions.Free;

	inherited;
end;

function TSimpleScriptExtender.NamespaceIs(const Value: String; const AllowWildcard: Boolean): Boolean;
begin
   if AllowWildcard and (Value = '') then begin
      Result := True;
      exit;
   end;

   Result := (LowerCase(Self.Namespace) = LowerCase(Value));
end;

{ TSimpleScriptContext }

procedure TSimpleScriptContext.Assign(Source: TSimpleScriptContext);
var
	SourceExtender: TSimpleScriptExtender;
begin
	if not Assigned(Source) then
   	raise SimpleScript.Exceptions.ContextException.Create(SSEX_CONTEXT_AssignNilParam);

   Self.DefaultNamespace := Source.DefaultNamespace;
   FLocalFormatSettings := Source.LocalFormatSettings;

   Self.Extenders.Clear;
   for SourceExtender in Source.Extenders do begin
      Self.Extenders.AddClass(TSimpleScriptExtenderClass(SourceExtender.ClassType), Self);
   end;
end;

constructor TSimpleScriptContext.Create;
begin
	GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, FLocalFormatSettings);
	FPerfCounter := TPerformanceCounter.Create;
	FExtenders := TSimpleScriptExtenderList.Create;

   FErrors := TSimpleScriptContextErrorList.Create;
   FErrors.OnNewError := Self.OnNewError;

   FlagIgnoreOnNewErr := False;
   FMaxErrorCount := MAX_ERROR_COUNT;
end;

destructor TSimpleScriptContext.Destroy;
begin
	if Assigned(FExtenders) then
   	FExtenders.Free;

   if Assigned(FErrors) then
   	FErrors.Free;

   if Assigned(FPerfCounter) then
   	FPerfCounter.Free;

	inherited;
end;

procedure TSimpleScriptContext.DoOnParseComplete;
begin
	if Assigned(FOnParseComplete) then
   	FOnParseComplete(Self);
end;

function TSimpleScriptContext.GetTypedExtensionList(AType: TSimpleScriptExtensionClass; ANamespace: String = ''): TSimpleScriptExtensionList;
var
   curExtender: TSimpleScriptExtender;
   partialList: TSimpleScriptExtensionList;
begin
	Result := TSimpleScriptExtensionList.Create;

	for curExtender in Self.Extenders do begin
   	if not curExtender.NamespaceIs(ANamespace) then continue;

   	partialList := curExtender.Extensions.GetTypedList(AType);
      partialList.OwnsObjects := False;
      Result.Assign(partialList, laXor);
      partialList.Free;
   end;

   Result.OwnsObjects := False;
end;

procedure TSimpleScriptContext.OnNewError(const Error: TSimpleScriptContextError);
begin
   if FlagIgnoreOnNewErr then exit;
   
   if (FMaxErrorCount > 0) and (Self.Errors.CountError >= FMaxErrorCount) then begin
      FlagIgnoreOnNewErr := True;
      Self.Errors.New(SSEX_GENERIC_TooManyErros_COD, SSEX_GENERIC_TooManyErros, ekError);
      //FlagIgnoreOnNewErr := False;
      Self.StopParse;
   end;
end;

procedure TSimpleScriptContext.OnThreadExecTerminate(Sender: TObject);
var
	extender: TSimpleScriptExtender;
begin
	if Assigned(FExecThread) then begin
      FOutput := FExecThread.Output;

      if FExecThread.ReturnValue = PRET_STKOVERFLOW_TERMINATION then
         Self.Errors.New(SSEX_GENERIC_StackOverflowTermination_COD, SSEX_GENERIC_StackOverflowTermination, ekError);

      FExecThread := nil;
   end;

   for extender in Self.Extenders do
   	extender.Notify(NMSG_PARSE_FINISH);

   FStatus := csIdle;

   DoOnParseComplete;
end;

procedure TSimpleScriptContext.Parse;
var
	extender: TSimpleScriptExtender;
begin
   if Self.Status <> csIdle then exit;

	FStatus := csRunning;
   FlagIgnoreOnNewErr := False;

   Self.Errors.Clear;
   FOutput := '';

   for extender in Self.Extenders do
   	extender.Notify(NMSG_PARSE_START);

   FExecThread := TContextExecThread.Create(Self);
   FExecThread.Input := Self.Input;
   FExecThread.OnTerminate := Self.OnThreadExecTerminate;

   {$IFDEF VER210}
   FExecThread.Start;
   {$ELSE}
   FExecThread.Resume;
   {$ENDIF}
end;

procedure TSimpleScriptContext.SetParseReturnValue(const Value: Integer);
begin
   if Assigned(FExecThread) then
   	FExecThread.ReturnValue := Value;
end;

procedure TSimpleScriptContext.StopParse;
begin
   if Assigned(FExecThread) and (Self.Status = csRunning) then begin
   	FStatus := csTerminating;
   	FExecThread.Terminate;
   end;
end;

{ Main } //---------------------------------------------------------------------

{$IFDEF VER210}
class procedure Main.AddDefaultContextExtenderClass(AClass: TSimpleScriptExtenderClass);
{$ELSE}
class procedure TMain.AddDefaultContextExtenderClass(AClass: TSimpleScriptExtenderClass);
{$ENDIF}
begin
   DefaultContext.Extenders.AddClass(AClass, DefaultContext);
end;

{$IFDEF VER210}
class constructor Main.Create;
{$ELSE}
constructor TMain.Create;
{$ENDIF}
begin
	FDefaultContext := GetBlankContext;
end;

{$IFDEF VER210}
class destructor Main.Destroy;
{$ELSE}
destructor TMain.Destroy;
{$ENDIF}
begin
	FreeDefaultContext;
    {$IFNDEF VER210}
    inherited;
    {$ENDIF}
end;

{$IFDEF VER210}
class procedure Main.FreeDefaultContext;
{$ELSE}
class procedure TMain.FreeDefaultContext;
{$ENDIF}
begin
   if Assigned(FDefaultContext) then
   	FDefaultContext.Free;
   FDefaultContext := nil;
end;

{$IFDEF VER210}
class function Main.GetBlankContext: TSimpleScriptContext;
{$ELSE}
class function TMain.GetBlankContext: TSimpleScriptContext;
{$ENDIF}
begin
   Result := TSimpleScriptContext.Create;
end;

{$IFDEF VER210}
class function Main.GetContext: TSimpleScriptContext;
{$ELSE}
class function TMain.GetContext: TSimpleScriptContext;
{$ENDIF}
begin
	if not Assigned(DefaultContext) then
   	raise SimpleScript.Exceptions.MainException.Create(SSEX_MAIN_DefContexNil);

	Result := GetBlankContext;
   Result.Assign(DefaultContext);
end;

{$IFDEF VER210}
class procedure Main.SetDefaultContext(const Value: TSimpleScriptContext);
{$ELSE}
class procedure TMain.SetDefaultContext(const Value: TSimpleScriptContext);
{$ENDIF}
begin
	FreeDefaultContext;

   if not Assigned(Value) then
   	raise SimpleScript.Exceptions.MainException.Create(SSEX_MAIN_DefContexNil);

	FDefaultContext := Value;
end;

//------------------------------------------------------------------------------

{ TSimpleScriptExtension }

constructor TSimpleScriptExtension.Create(AOwner: TSimpleScriptExtender);
begin
	if not Assigned(AOwner) then
      raise SimpleScript.Exceptions.ExtensionException.Create(SSEX_EXTENSION_NoOwner);

	FOwner := AOwner;
end;

{ TSimpleScriptContextErrorList }

procedure TSimpleScriptContextErrorList.Clear;
begin
   SetLength(FErrors, 0);
   FCount := 0;
   FCountInfo := 0;
   FCountWarning := 0;
   FCountError := 0;
end;

constructor TSimpleScriptContextErrorList.Create;
begin
   Self.Clear;
end;

destructor TSimpleScriptContextErrorList.Destroy;
begin
   Self.Clear;
	inherited;
end;

procedure TSimpleScriptContextErrorList.DoOnNewError(const Error: TSimpleScriptContextError);
begin
   if Assigned(FOnNewError) then
      FOnNewError(Error);
end;

function TSimpleScriptContextErrorList.New(const Code, Description: String; Kind: TContextErrorKind;
   const Line, Column: Integer; const FileName: String): TSimpleScriptContextError;
var
   newError: TSimpleScriptContextError;
begin
	newError.Kind := Kind;
   newError.Code := Code;
   newError.Description := Description;

   newError.Line := Line;
   newError.Column := Column;
   newError.FileName := FileName;

   Inc(FCount);
   SetLength(FErrors, FCount);
   FErrors[FCount-1] := newError;

   case Kind of
   	ekInfo: Inc(FCountInfo);
      ekWarning: Inc(FCountWarning);
      ekError: Inc(FCountError);
   end;

   Result := newError;

   Self.DoOnNewError(newError);
end;

function TSimpleScriptContextErrorList.GetError(Index: Integer): TSimpleScriptContextError;
begin
   Result := FErrors[Index];
end;

procedure TSimpleScriptContextErrorList.SetError(Index: Integer; const Value: TSimpleScriptContextError);
begin
	FErrors[index] := Value;
end;

{ TPerformanceCounter }

procedure TPerformanceCounter.Start;
begin
	FEllapsedTime := -1;

	QueryPerformanceFrequency(FPerfFreq);

   QueryPerformanceCounter(FOverhead_St);
   QueryPerformanceCounter(FOverhead_Sp);
   FOverhead := FOverhead_Sp - FOverhead_St;

   QueryPerformanceCounter(FPerfStart);
end;

procedure TPerformanceCounter.Stop;
begin
	QueryPerformanceCounter(FPerfStop);
   FEllapsedTime := ((FPerfStop - FPerfStart - FOverhead) * 1000) / FPerfFreq;
end;

{ TContextExecThread }

constructor TContextExecThread.Create(AContext: TSimpleScriptContext);
begin
	if not Assigned(AContext) then
   	raise ContextExecThreadException.Create(SSEX_EXECTHREAD_NoOwner);

   inherited Create(True);
   Self.FreeOnTerminate := True;

   FOwnerContext := AContext;
end;

procedure TContextExecThread.Execute;
var
	parserList: TSimpleScriptExtensionList;
   curExtension: TSimpleScriptExtension;
   tmpInput, tmpOutput: String;
begin
   Self.OwnerContext.PerformanceCounter.Start;

   parserList := Self.OwnerContext.GetTypedExtensionList(TExtensionParser, Self.OwnerContext.DefaultNamespace);

   tmpInput := Input;
   try
      for curExtension in parserList do begin
         if Self.Terminated then break;

         Self.OwnerContext.ActiveParser := TExtensionParser(curExtension);
         try
            Self.OwnerContext.ActiveParser.Parse(tmpInput, tmpOutput, PA_ROOT_PARSE);
         except
            on E: Exception do begin
               Self.OwnerContext.Errors.New(
                  SimpleScript.Exceptions.SSEX_GENERIC_Unhandled_COD,
                  SimpleScript.Exceptions.SSEX_GENERIC_Unhandled + ': ' + E.Message,
                  ekError
               );
            end;
         end;
         tmpInput := tmpOutput;
      end;
   finally
   	FOutput := tmpOutput;
   	Self.OwnerContext.ActiveParser := nil;

      if Assigned(parserList) then
      	parserList.Free;
      
      Self.OwnerContext.PerformanceCounter.Stop;
   end;
end;

{ TExtensionParser }

function TExtensionParser.GetCurrentColumn: Integer;
begin
   Result := FCurrentColumn;
end;

function TExtensionParser.GetCurrentFile: String;
begin
   Result := FCurrentFile;
end;

function TExtensionParser.GetCurrentLine: Integer;
begin
   Result := FCurrentLine;
end;

procedure TExtensionParser.SetCurrentColumn(const Value: Integer);
begin
   FCurrentColumn := Value;
end;

procedure TExtensionParser.SetCurrentFile(const Value: String);
begin
   FCurrentFile := Value;
end;

procedure TExtensionParser.SetCurrentLine(const Value: Integer);
begin
   FCurrentLine := Value;
end;

{$IFNDEF VER210}
initialization
    Main := TMain.Create;

finalization
    if Assigned(Main) then Main.Free;
{$ENDIF}

end.
