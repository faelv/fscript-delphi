unit SimpleScript.Extenders.DB;

interface

uses
   SimpleScript.Core, SimpleScript.Exceptions, SimpleScript.Extenders.Basics, SimpleScript.Utils,
   Classes, Contnrs, SysUtils, Windows, StrUtils, Math, SqlExpr, WideStrings, DB, Variants, DBXCommon;

const
    SSEX_EXTENSION_ConnectionNotFound_COD: String = 'DB-0001';
    SSEX_EXTENSION_ConnectionAlreadyExists_COD: String = 'DB-0002';
    SSEX_EXTENSION_DataBaseError_COD: String = 'DB-0003';
    SSEX_EXTENSION_ConnectionClosed_COD: String = 'DB-0004';
    SSEX_EXTENSION_QueryAlreadyExists_COD: String = 'DB-0007';
    SSEX_EXTENSION_QueryNotFound_COD: String = 'DB-0008';
    SSEX_EXTENSION_TransactionsNotSupported_COD: String = 'DB-0009';
    SSEX_EXTENSION_TransactionNotFound_COD: String = 'DB-0010';
    SEX_EXTENSION_TransactionAlreadyExists_COD: String = 'DB-0011';

    FIELD_NULL_STR: String = '';
    FIELD_UNKNOWN_STR: String = '';

resourcestring
    SSEX_EXTENSION_ConnectionNotFound =
       'Erro na função %s, a conexão "%s" não foi encontrada';
    SSEX_EXTENSION_ConnectionAlreadyExists =
       'Erro na função %s, uma conexão chamada "%s" já existe';
    SSEX_EXTENSION_DataBaseError =
       'O banco de dados retornou o seguinte o erro durante a função %s: "%s"';
    SSEX_EXTENSION_ConnectionClosed =
       'A função %s não pode ser executada na conexão "%s" pois ela não está aberta';
    SSEX_EXTENSION_QueryAlreadyExists =
      'Erro na função %s, uma consulta chamada "%s" já existe';
    SSEX_EXTENSION_QueryNotFound =
      'Erro na função %s, a consulta "%s" não foi encontrada';
    SSEX_EXTENSION_TransactionsNotSupported =
      'A conexão "%s" não suporta transações';
    SSEX_EXTENSION_TransactionNotFound =
      'Erro na função %s, não há transação para a conexão "%s"';
    SEX_EXTENSION_TransactionAlreadyExists =
      'Erro na função "%s", uma transação já existe para a conexão "%s"';

type

	TDBExtender = class(TBasicExtenderBase)
      public
         const
            KEY_DATABASE: String = 'Database';
            KEY_USERNAME: String = 'User_Name';
            KEY_PASSWORD: String = 'Password';
            COLUMN_ALIAS: String = 'COLUMN_NAME';
            KEY_DRIVERNAME: String = 'DriverName';
         type
            TDBConnection = class(TObject)
                strict private
                    FSQLConnection: TSQLConnection;
                    FSQLQueryDirect: TSQLQuery;
                    FName: String;
                    FOpenedSQLQueries: TObjectList;
                public
                    constructor Create(const AName: String);
                    destructor Destroy; override;
                    property SQLConnection: TSQLConnection read FSQLConnection;
                    property SQLQueryDirect: TSQLQuery read FSQLQueryDirect;
                    property Name: String read FName;
                    property OpenedSQLQueries: TObjectList read FOpenedSQLQueries;
            end;

            TDBTransaction = class(TObject)
               private
                  FName: String;
                  FDBXTransaction: TDBXTransaction;
               public
                  constructor Create(const AName: String; ADbxTransaction: TDBXTransaction);
                  property Name: String read FName;
                  property DBXTransaction: TDBXTransaction read FDBXTransaction;
            end;

            TFieldType = record
                Code: Integer;
                Name: String;
            end;

         const
            FieldTypes: array[ftUnknown..ftOraInterval] of TFieldType = (
                (Code:  0; Name: 'unknow'),      (Code:  1; Name: 'string'),       (Code:  2; Name: 'smallint'),
                (Code:  3; Name: 'integer'),     (Code:  4; Name: 'word'),         (Code:  5; Name: 'boolean'),
                (Code:  6; Name: 'float'),       (Code:  7; Name: 'currency'),     (Code:  8; Name: 'bcd'),
                (Code:  9; Name: 'date'),        (Code: 10; Name: 'time'),         (Code: 11; Name: 'datetime'),
                (Code: 12; Name: 'bytes'),       (Code: 13; Name: 'varbytes'),     (Code: 14; Name: 'autoinc'),
                (Code: 15; Name: 'blob'),        (Code: 16; Name: 'memo'),         (Code: 17; Name: 'graphic'),
                (Code: 18; Name: 'fmtmemo'),     (Code: 19; Name: 'paradoxole'),   (Code: 20; Name: 'dbaseole'),
                (Code: 21; Name: 'typedbinary'), (Code: 22; Name: 'cursor'),       (Code: 23; Name: 'fixedchar'),
                (Code: 24; Name: 'widestring'),  (Code: 25; Name: 'largeint'),     (Code: 26; Name: 'adt'),
                (Code: 27; Name: 'array'),       (Code: 28; Name: 'reference'),    (Code: 29; Name: 'dataset'),
                (Code: 30; Name: 'orablob'),     (Code: 31; Name: 'oraclob'),      (Code: 32; Name: 'variant'),
                (Code: 33; Name: 'interface'),   (Code: 34; Name: 'idispatch'),    (Code: 35; Name: 'guid'),
                (Code: 36; Name: 'timestamp'),   (Code: 37; Name: 'fmtbcd'),       (Code: 38; Name: 'fixedwidechar'),
                (Code: 39; Name: 'widememo'),    (Code: 40; Name: 'oratimestamp'), (Code: 41; Name: 'orainterval')
            );
         
      strict private
         FConns: TObjectList;
         FTransactions: TObjectList;
         FConnIncID: Integer;
      strict protected
         function GetNamespace: String; override;
         procedure PublishExtensions; override;
         
         function GetConnection(const AName: String): TDBConnection;
         function CreateConnection(const AName: String; const Schema: String = ''): Boolean;
         function OpenConnection(const AName: String): Boolean;
         function CloseConnection(const AName: String): Boolean;
         function DisposeConnection(const AName: String): Boolean;
         function SetConnectionParams(const AName, Database, UserName, Password: String; Params: array of String): Boolean;
         function SetConnectionDriver(const AName, GetDriverFunc, LibraryName, VendorLib: String): Boolean;

         function GetTransaction(const AName: String): TDBTransaction;
         function StartTransaction(const AName: String; out Supported: Boolean): Boolean;
         function CommitTransaction(const AName: String): Boolean;
         function RollbackTransaction(const AName: String): Boolean;

         function GetOpenedQuery(Conn: TDBConnection; const AName: String): TSQLQuery;
         function CreateQuery(Conn: TDBConnection; const AName: String): TSQLQuery;
         function DisposeQuery(Conn: TDBConnection; const AName: String): Boolean;

         {FUNC: Cria um objeto de conexão; PARAMS: 1=nome, [2=schema]; RESULT: bool}
         function fn_CreateConnection(Args: array of String): String;
         {FUNC: Abre uma conexão, conecta; PARAMS: 1=nome; RESULT: bool}
         function fn_OpenConnection(Args: array of String): String;
         {FUNC: Fecha uma conexão, desconecta; PARAMS: 1=nome; RESULT: bool}
         function fn_CloseConnection(Args: array of String): String;
         {FUNC: Libera um objeto conexão; PARAMS: 1=nome; RESULT: bool}
         function fn_DisposeConnection(Args: array of String): String;
         {FUNC: Seta os parametros da conexão;
         PARAMS: 1=nome, 2=database, 3=username, 4=password, [5=array de nome=valor];
         RESULT: -}
         function fn_SetConnectionParams(Args: array of String): String;
         {FUNC: Seta as propriedades do driver de db da conexão;
         PARAMS: 1=nome, 2=GetDriverFunc, 3=LibraryName, 4=VendorLib;
         RESULT: -}
         function fn_SetConnectionDriver(Args: array of String): String;
         {FUNC: Retorna os nomes das tabelas do bd; PARAMS: 1=nome da conexao; RESULT: lista crlf}
         function fn_TableNames(Args: array of String): String;
         {FUNC: Retorna os nomes de campos de uma tabela;
         PARAMS: 1=nome da conexao, 2=nome da tabela, [3=bool, flag tipo do campo];
         RESULT: lista crlf com nome=valor caso p3 seja true}
         function fn_FieldNames(Args: array of String): String;
         {FUNC: Executa uma consulta SQL no banco de dados da conexão
         PARAMS: 1=nome, 2=sql
         RESULT: Número de registros afetados}
         function fn_QueryExecute(Args: array of String): String;
         {FUNC: Executa uma consulta sql que retorne um conjunto de registros
         PARAMS: 1=nome, 2=sql, 3=nome query
         RESULT: bool}
         function fn_QueryOpen(Args: array of String): String;
         {FUNC: Fecha libera da memória uma consulta criada com QueryOpen
         PARAMS: 1=nome, 2=nome query
         RESULT:}
         function fn_QueryClose(Args: array of String): String;
         {FUNC: Vai para o próximo registro em um conjunto de dados
         PARAMS: 1=nome, 2=nome query, [3=qtde de registros a avançar], [4=(bool)retornar a qtde de reistros movidos ou nao]
         RESULT: se p4 for true retorna q qtde de registros avançados/movidos, senao nao retorna nada}
         function fn_QueryNext(Args: array of String): String;
         {FUNC: Retorna um valor de campo
         PARAMS: 1=nome, 2=nome query, 3=nome campo
         RESULT: valor do campo}
         function fn_FieldValue(Args: array of String): String;
         {FUNC: Indica se o registro atual é o último do conjunto
         PARAMS: 1=nome, 2=nome query
         RESULT: bool}
         function fn_QueryEOF(Args: array of String): String;
         {FUNC: Indica se o registro atual é o primeiro do conjunto
         PARAMS: 1=nome, 2=nome query
         RESULT: bool}
         function fn_QueryBOF(Args: array of String): String;
         {}
         function fn_TransactionStart(Args: array of String): String;
         {}
         function fn_TransactionCommit(Args: array of String): String;
         {}
         function fn_TransactionRollback(Args: array of String): String;
      public
         constructor Create(AOwner: TSimpleScriptContext); override;
         destructor Destroy; override;
         function Notify(const Msg: Integer): Integer; override;
   end;

implementation

{ TDBExtender }

function TDBExtender.DisposeQuery(Conn: TDBConnection; const AName: String): Boolean;
var
   query: TSQLQuery;
begin
   Result := False;
   query := GetOpenedQuery(Conn, AName);
   if query <> nil then begin
      if query.Active then query.Close;
      Conn.OpenedSQLQueries.Remove(query);
      Result := True;
   end;
end;

constructor TDBExtender.Create(AOwner: TSimpleScriptContext);
begin
	inherited;
    FConns := TObjectList.Create;
    FConns.OwnsObjects := True;

    FTransactions := TObjectList.Create;
    FTransactions.OwnsObjects := True;

    FConnIncID := 0;
end;

destructor TDBExtender.Destroy;
begin
   if Assigned(FConns) then
      FConns.Free;
   if assigned(FTransactions) then
      FTransactions.Free;
   inherited;
end;

function TDBExtender.CreateConnection(const AName: String; const Schema: String): Boolean;
var
    newConn: TDBConnection;
begin
    Result := (Self.GetConnection(AName) = nil);
    if Result then begin
        newConn := TDBConnection.Create(AName);
        newConn.SQLQueryDirect.SchemaName := Schema;
        FConns.Add(newConn);
    end;
end;

function TDBExtender.CloseConnection(const AName: String): Boolean;
var
    conn: TDBConnection;
begin
    Result := False;
    conn := Self.GetConnection(AName);
    if (conn <> nil) then begin
        if conn.SQLConnection.Connected then
            conn.SQLConnection.Close;
        Result := not conn.SQLConnection.Connected;
    end;
end;

function TDBExtender.DisposeConnection(const AName: String): Boolean;
var
    conn: TDBConnection;
begin
    Result := False;
    conn := Self.GetConnection(AName);
    if conn <> nil then begin
        Result := (FConns.Remove(conn) >= 0);
    end;
end;

function TDBExtender.OpenConnection(const AName: String): Boolean;
var
    conn: TDBConnection;
begin
    Result := False;
    conn := Self.GetConnection(AName);
    if conn <> nil then begin
        conn.SQLConnection.Open;
        Result := conn.SQLConnection.Connected;
    end;
end;

function TDBExtender.CreateQuery(Conn: TDBConnection; const AName: String): TSQLQuery;
var
   query: TSQLQuery;
begin
   Result := nil;
   if (GetOpenedQuery(Conn, AName) = nil) then begin
      query := TSQLQuery.Create(nil);
      query.Name := AName;
      query.SQLConnection := Conn.SQLConnection;
      query.SchemaName := Conn.SQLQueryDirect.SchemaName;

      Conn.OpenedSQLQueries.Add(query);

      Result := query;
   end;
end;

function TDBExtender.GetConnection(const AName: String): TDBConnection;
var
    curObj: Pointer;
    curObjConn: TDBConnection;
begin
    Result := nil;
    for curObj in FConns do begin
        curObjConn := TDBConnection(curObj);
        if LowerCase(curObjConn.Name) = LowerCase(AName) then begin
            Result := curObjConn;
            break;
        end;
    end;
end;

function TDBExtender.GetNamespace: String;
begin
	Result := 'DB';
end;

function TDBExtender.GetOpenedQuery(Conn: TDBConnection;
  const AName: String): TSQLQuery;
var
   curPtr: Pointer;
   curQuery: TSQLQuery;
begin
   Result := nil;
   for curPtr in Conn.OpenedSQLQueries do begin
      curQuery := TSQLQuery(curPtr);
      if LowerCase(curQuery.Name) = LowerCase(AName) then begin
         Result := curQuery;
         break;
      end;
   end;
end;

function TDBExtender.GetTransaction(const AName: String): TDBTransaction;
var
   curPtr: Pointer;
begin
   Result := nil;
   for curPtr in FTransactions do begin
      if LowerCase(TDBTransaction(curPtr).Name) = LowerCase(AName) then begin
         Result := TDBTransaction(curPtr);
         break;
      end;
   end;
end;

function TDBExtender.Notify(const Msg: Integer): Integer;
begin
    Result := inherited Notify(Msg);
end;

procedure TDBExtender.PublishExtensions;
begin
	with Self.Extensions do begin
      Add(TStringArgsFunction.Create(Self, 'CreateConnection', Self.fn_CreateConnection));
      Add(TStringArgsFunction.Create(Self, 'OpenConnection', Self.fn_OpenConnection));
      Add(TStringArgsFunction.Create(Self, 'CloseConnection', Self.fn_CloseConnection));
      Add(TStringArgsFunction.Create(Self, 'DisposeConnection', Self.fn_DisposeConnection));
      Add(TStringArgsFunction.Create(Self, 'SetConnectionParams', Self.fn_SetConnectionParams));
      Add(TStringArgsFunction.Create(Self, 'SetConnectionDriver', Self.fn_SetConnectionDriver));
      Add(TStringArgsFunction.Create(Self, 'TableNames', Self.fn_TableNames));
      Add(TStringArgsFunction.Create(Self, 'FieldNames', Self.fn_FieldNames));
      Add(TStringArgsFunction.Create(Self, 'QueryOpen', Self.fn_QueryOpen));
      Add(TStringArgsFunction.Create(Self, 'QueryClose', Self.fn_QueryClose));
      Add(TStringArgsFunction.Create(Self, 'QueryNext', Self.fn_QueryNext));
      Add(TStringArgsFunction.Create(Self, 'FieldValue', Self.fn_FieldValue));
      Add(TStringArgsFunction.Create(Self, 'QueryEOF', Self.fn_QueryEOF));
      Add(TStringArgsFunction.Create(Self, 'QueryBOF', Self.fn_QueryBOF));
      Add(TStringArgsFunction.Create(Self, 'QueryExecute', Self.fn_QueryExecute));

      Add(TStringArgsFunction.Create(Self, 'TransactionStart', Self.fn_TransactionStart));
      Add(TStringArgsFunction.Create(Self, 'TransactionCommit', Self.fn_TransactionCommit));
      Add(TStringArgsFunction.Create(Self, 'TransactionRollback', Self.fn_TransactionRollback));
   end;
end;

function TDBExtender.SetConnectionDriver(const AName, GetDriverFunc,
LibraryName, VendorLib: String): Boolean;
var
    conn: TDBConnection;
begin
    conn := Self.GetConnection(AName);
    Result := (conn <> nil);
    if not Result then exit;

    conn.SQLConnection.DriverName := AName + '_driver';
    conn.SQLConnection.GetDriverFunc := GetDriverFunc;
    conn.SQLConnection.LibraryName := LibraryName;
    conn.SQLConnection.VendorLib := VendorLib;
end;

function TDBExtender.SetConnectionParams(const AName, Database, UserName, Password: String;
Params: array of String): Boolean;
var
    conn: TDBConnection;
    paramsList: TWideStrings;
    I: Integer;
begin
    conn := Self.GetConnection(AName);
    Result := (conn <> nil);
    if not Result then exit;

    paramsList := TWideStringList.Create;
    paramsList.NameValueSeparator := '=';

    paramsList.Append(KEY_DATABASE + paramsList.NameValueSeparator + Database);
    paramsList.Append(KEY_USERNAME + paramsList.NameValueSeparator + UserName);
    paramsList.Append(KEY_PASSWORD + paramsList.NameValueSeparator + Password);

    for I := 0 to Length(Params) - 1 do begin
        paramsList.Append(Params[I]);
    end;
    
    Inc(FConnIncID);
    paramsList.Append(KEY_DRIVERNAME + paramsList.NameValueSeparator + 'drv' + IntToStr(FConnIncID));

    conn.SQLConnection.Params.Assign(paramsList);
    paramsList.Free;
end;

function TDBExtender.StartTransaction(const AName: String; out Supported: Boolean): Boolean;
var
   conn: TDBConnection;
   newTransaction: TDBTransaction;
   DbxTrans: TDBXTransaction;
begin
   Result := False;
   Supported := False;
   
   conn := Self.GetConnection(AName);
   if conn = nil then exit;

   Supported := conn.SQLConnection.TransactionsSupported;
   DbxTrans := conn.SQLConnection.BeginTransaction;

   Result := True;
   newTransaction := TDBTransaction.Create(AName, DbxTrans);
   FTransactions.Add(newTransaction);
end;

function TDBExtender.CommitTransaction(const AName: String): Boolean;
var
   conn: TDBConnection;
   Trans: TDBTransaction;
   DbxTrans: TDBXTransaction;
begin
   Result := False;

   conn := Self.GetConnection(AName);
   if conn = nil then exit;

   Trans := GetTransaction(AName);
   if Trans = nil then exit;
   
   DbxTrans := Trans.DBXTransaction;
   if DbxTrans <> nil then   
      conn.SQLConnection.CommitFreeAndNil(DbxTrans)
   else
      Result := True;

   FTransactions.Remove(Trans);
end;

function TDBExtender.RollbackTransaction(const AName: String): Boolean;
var
   conn: TDBConnection;
   Trans: TDBTransaction;
   DbxTrans: TDBXTransaction;
begin
   Result := False;

   conn := Self.GetConnection(AName);
   if conn = nil then exit;

   Trans := GetTransaction(AName);
   if Trans = nil then exit;
   
   DbxTrans := Trans.DBXTransaction;
   if DbxTrans <> nil then
      conn.SQLConnection.RollbackIncompleteFreeAndNil(DbxTrans)
   else
      Result := True;

   FTransactions.Remove(Trans);
end;

function TDBExtender.fn_CloseConnection(Args: array of String): String;
begin
   Result := FALSE_STR;
   
   if Length(Args) < 1 then begin
      Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['CloseConnection', 1]);
      exit;
   end;

   if Self.GetConnection(Args[0]) = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionNotFound_COD, SSEX_EXTENSION_ConnectionNotFound, ['CloseConnection', Args[0]]);
      exit;
   end;

   try
      Result := InternalBoolToStr(Self.CloseConnection(Args[0]));
   except
      on E: Exception do begin
          Self.IssueExtensionError(
             SSEX_EXTENSION_DataBaseError_COD, SSEX_EXTENSION_DataBaseError,
             ['CloseConnection', E.Message]
          );
      end;
   end;
end;

function TDBExtender.fn_CreateConnection(Args: array of String): String;
var
   schema: String;
begin
   Result := FALSE_STR;
   
   if Length(Args) < 1 then begin
      Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['OpenConnection', 1]);
      exit;
   end;

   if Self.GetConnection(Args[0]) <> nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionAlreadyExists_COD, SSEX_EXTENSION_ConnectionAlreadyExists, ['OpenConnection', Args[0]]);
      exit;
   end;

   schema := '';
   if Length(Args) > 1 then
      schema := Args[1];

   try
      Result := InternalBoolToStr(Self.CreateConnection(Args[0], schema));
   except
      on E: Exception do begin
          Self.IssueExtensionError(
             SSEX_EXTENSION_DataBaseError_COD, SSEX_EXTENSION_DataBaseError,
             ['CreateConnection', E.Message]
          );
      end;
   end;
end;

function TDBExtender.fn_DisposeConnection(Args: array of String): String;
begin
   Result := FALSE_STR;
   
   if Length(Args) < 1 then begin
      Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['DisposeConnection', 1]);
      exit;
   end;

   if Self.GetConnection(Args[0]) = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionNotFound_COD, SSEX_EXTENSION_ConnectionNotFound, ['DisposeConnection', Args[0]]);
      exit;
   end;

   try
      Result := InternalBoolToStr(Self.DisposeConnection(Args[0]));
   except
      on E: Exception do begin
          Self.IssueExtensionError(
             SSEX_EXTENSION_DataBaseError_COD, SSEX_EXTENSION_DataBaseError,
             ['DisposeConnection', E.Message]
          );
      end;
   end;
end;

function TDBExtender.fn_OpenConnection(Args: array of String): String;
begin
   Result := FALSE_STR;
   
   if Length(Args) < 1 then begin
      Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['OpenConnection', 1]);
      exit;
   end;

   if Self.GetConnection(Args[0]) = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionNotFound_COD, SSEX_EXTENSION_ConnectionNotFound, ['OpenConnection', Args[0]]);
      exit;
   end;

   try
      Result := InternalBoolToStr(Self.OpenConnection(Args[0]));
   except
      on E: Exception do begin
          Self.IssueExtensionError(
             SSEX_EXTENSION_DataBaseError_COD, SSEX_EXTENSION_DataBaseError,
             ['OpenConnection', E.Message]
          );
      end;
   end;
end;

function TDBExtender.fn_QueryClose(Args: array of String): String;
var
    conn: TDBConnection;
    query: TSQLQuery;
begin
    Result := FALSE_STR;
   
   if Length(Args) < 2 then begin
      Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['QueryClose', 2]);
      exit;
   end;

   conn := Self.GetConnection(Args[0]);
   if conn = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionNotFound_COD, SSEX_EXTENSION_ConnectionNotFound, ['QueryClose', Args[0]]);
      exit;
   end;

   if not conn.SQLConnection.Connected then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionClosed_COD, SSEX_EXTENSION_ConnectionClosed, ['QueryClose', Args[0]]);
      exit;
   end;

   query := GetOpenedQuery(conn, Args[1]);
   if query = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_QueryNotFound_COD, SSEX_EXTENSION_QueryNotFound, ['QueryClose', Args[1]]);
      exit;
   end;

   if query.Active then query.Close;
   Result := InternalBoolToStr(not query.Active);

   DisposeQuery(conn, query.Name);
end;

function TDBExtender.fn_QueryEOF(Args: array of String): String;
var
    conn: TDBConnection;
    query: TSQLQuery;
begin
    //Result := FALSE_STR;
    Result := TRUE_STR;
   
   if Length(Args) < 2 then begin
      Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['QueryEOF', 2]);
      exit;
   end;

   conn := Self.GetConnection(Args[0]);
   if conn = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionNotFound_COD, SSEX_EXTENSION_ConnectionNotFound, ['QueryEOF', Args[0]]);
      exit;
   end;

   if not conn.SQLConnection.Connected then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionClosed_COD, SSEX_EXTENSION_ConnectionClosed, ['QueryEOF', Args[0]]);
      exit;
   end;
   
   query := GetOpenedQuery(conn, Args[1]);
   if query = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_QueryNotFound_COD, SSEX_EXTENSION_QueryNotFound, ['QueryEOF', Args[1]]);
      exit;
   end;

   Result := InternalBoolToStr(query.Eof);
end;

function TDBExtender.fn_QueryExecute(Args: array of String): String;
var
    conn: TDBConnection;
    sql: String;
    query: TSQLQuery;
begin
    Result := FALSE_STR;
   
   if Length(Args) < 2 then begin
      Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['QueryExecute', 2]);
      exit;
   end;

   conn := Self.GetConnection(Args[0]);
   if conn = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionNotFound_COD, SSEX_EXTENSION_ConnectionNotFound, ['QueryExecute', Args[0]]);
      exit;
   end;

   if not conn.SQLConnection.Connected then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionClosed_COD, SSEX_EXTENSION_ConnectionClosed, ['QueryExecute', Args[0]]);
      exit;
   end;

   sql := Trim(Args[1]);
   if sql = '' then begin
      Self.IssueExtensionError(SSEX_EXTENSION_EmptyString_COD, SSEX_EXTENSION_EmptyString, [2, 'QueryExecute']);
      exit;
   end;

   query := conn.SQLQueryDirect;
   if query <> nil then begin
      query.CommandText := sql;
      try
         Result := IntToStr(query.ExecSQL(True));
      except
         on E: Exception do begin
             Self.IssueExtensionError(
                SSEX_EXTENSION_DataBaseError_COD, SSEX_EXTENSION_DataBaseError,
                ['QueryExecute', E.Message]
             );
         end;
      end;
   end;
end;

function TDBExtender.fn_QueryBOF(Args: array of String): String;
var
    conn: TDBConnection;
    query: TSQLQuery;
begin
    //Result := FALSE_STR;
    Result := TRUE_STR;
   
   if Length(Args) < 2 then begin
      Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['QueryBOF', 2]);
      exit;
   end;

   conn := Self.GetConnection(Args[0]);
   if conn = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionNotFound_COD, SSEX_EXTENSION_ConnectionNotFound, ['QueryBOF', Args[0]]);
      exit;
   end;

   if not conn.SQLConnection.Connected then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionClosed_COD, SSEX_EXTENSION_ConnectionClosed, ['QueryBOF', Args[0]]);
      exit;
   end;

   query := GetOpenedQuery(conn, Args[1]);
   if query = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_QueryNotFound_COD, SSEX_EXTENSION_QueryNotFound, ['QueryBOF', Args[1]]);
      exit;
   end;

   Result := InternalBoolToStr(query.Bof);
end;

function TDBExtender.fn_QueryNext(Args: array of String): String;
var
    conn: TDBConnection;
    move, moved: Integer;
    wantResult: Boolean;
    query: TSQLQuery;
begin
    wantResult := False;
    if Length(Args) > 3 then
       wantResult := InternalStrToBool(Args[3]);

    if wantResult then
       Result := '0';
   
   if Length(Args) < 2 then begin
      Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['QueryNext', 2]);
      exit;
   end;

   conn := Self.GetConnection(Args[0]);
   if conn = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionNotFound_COD, SSEX_EXTENSION_ConnectionNotFound, ['QueryNext', Args[0]]);
      exit;
   end;

   if not conn.SQLConnection.Connected then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionClosed_COD, SSEX_EXTENSION_ConnectionClosed, ['QueryNext', Args[0]]);
      exit;
   end;

   query := GetOpenedQuery(conn, Args[1]);
   if query = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_QueryNotFound_COD, SSEX_EXTENSION_QueryNotFound, ['QueryNext', Args[1]]);
      exit;
   end;

   try
      if (Length(Args) > 2) and (TryStrToInt(Args[2], move)) then begin
         moved := query.MoveBy(move);
      end else begin
         query.Next;
         moved := 1;
      end;
      
      if wantResult then
         Result := IntToStr(moved);
   except
      on E: Exception do begin
          Self.IssueExtensionError(
             SSEX_EXTENSION_DataBaseError_COD, SSEX_EXTENSION_DataBaseError,
             ['QueryNext', E.Message]
          );
      end;
   end;
end;

function TDBExtender.fn_QueryOpen(Args: array of String): String;
var
    conn: TDBConnection;
    sql: String;
    query: TSQLQuery;
begin
    Result := FALSE_STR;
   
   if Length(Args) < 3 then begin
      Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['QueryOpen', 3]);
      exit;
   end;

   conn := Self.GetConnection(Args[0]);
   if conn = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionNotFound_COD, SSEX_EXTENSION_ConnectionNotFound, ['QueryOpen', Args[0]]);
      exit;
   end;

   if not conn.SQLConnection.Connected then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionClosed_COD, SSEX_EXTENSION_ConnectionClosed, ['QueryOpen', Args[0]]);
      exit;
   end;

   if GetOpenedQuery(conn, Args[2]) <> nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_QueryAlreadyExists_COD, SSEX_EXTENSION_QueryAlreadyExists, ['QueryOpen', Args[2]]);
      exit;
   end;

   sql := Trim(Args[1]);
   if sql = '' then begin
      Self.IssueExtensionError(SSEX_EXTENSION_EmptyString_COD, SSEX_EXTENSION_EmptyString, [2, 'QueryOpen']);
      exit;
   end;

   query := CreateQuery(conn, Args[2]);
   if query <> nil then begin
      query.CommandText := sql;
      try
         query.Open;
         query.First;
         Result := InternalBoolToStr(query.Active);
      except
         on E: Exception do begin
             Self.IssueExtensionError(
                SSEX_EXTENSION_DataBaseError_COD, SSEX_EXTENSION_DataBaseError,
                ['QueryOpen', E.Message]
             );
         end;
      end;
   end;
end;

function TDBExtender.fn_FieldValue(Args: array of String): String;
var
    conn: TDBConnection;
    fieldName: String;
    query: TSQLQuery;
    fieldValue: Variant;
begin
    Result := FALSE_STR;
   
   if Length(Args) < 3 then begin
      Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['FieldValue', 3]);
      exit;
   end;

   conn := Self.GetConnection(Args[0]);
   if conn = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionNotFound_COD, SSEX_EXTENSION_ConnectionNotFound, ['FieldValue', Args[0]]);
      exit;
   end;

   if not conn.SQLConnection.Connected then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionClosed_COD, SSEX_EXTENSION_ConnectionClosed, ['FieldValue', Args[0]]);
      exit;
   end;

   query := GetOpenedQuery(conn, Args[1]);
   if query = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_QueryNotFound_COD, SSEX_EXTENSION_QueryNotFound, ['FieldValue', Args[1]]);
      exit;
   end;

   fieldName := Trim(Args[2]);
   if fieldName = '' then begin
      Self.IssueExtensionError(SSEX_EXTENSION_EmptyString_COD, SSEX_EXTENSION_EmptyString, [3, 'FieldValue']);
      exit;
   end;

   try
      fieldValue := query.FieldValues[fieldName];
      if VarIsType(fieldValue, varNull) then
         Result := FIELD_NULL_STR
      else if VarIsType(fieldValue, varUnknown) then
         Result := FIELD_UNKNOWN_STR
      else
         Result := String(fieldValue);
   except
      on E: Exception do begin
          Self.IssueExtensionError(
             SSEX_EXTENSION_DataBaseError_COD, SSEX_EXTENSION_DataBaseError,
             ['FieldValue', E.Message]
          );
      end;
   end;
end;

function TDBExtender.fn_SetConnectionDriver(Args: array of String): String;
begin
   if Length(Args) < 4 then begin
      Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['SetConnectionDriver', 4]);
      exit;
   end;

   if Self.GetConnection(Args[0]) = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionNotFound_COD, SSEX_EXTENSION_ConnectionNotFound, ['SetConnectionDriver', Args[0]]);
      exit;
   end;

   Self.SetConnectionDriver(Args[0], Args[1], Args[2], Args[3]);
end;

function TDBExtender.fn_SetConnectionParams(Args: array of String): String;
var
    params: array of String;
    argsLen, I: Integer;
begin
   argsLen := Length(Args);
   
   if argsLen < 4 then begin
      Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['SetConnectionParams', 4]);
      exit;
   end;

   if Self.GetConnection(Args[0]) = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionNotFound_COD, SSEX_EXTENSION_ConnectionNotFound, ['SetConnectionParams', Args[0]]);
      exit;
   end;

   SetLength(params, argsLen-4);
   for I := 4 to argsLen-1 do
      params[I-4] := Args[I];

   Self.SetConnectionParams(Args[0], Args[1], Args[2], Args[3], params);
end;

function TDBExtender.fn_TableNames(Args: array of String): String;
var
    conn: TDBConnection;
    tableList: TStrings;
    I: Integer;
begin
   if Length(Args) < 1 then begin
      Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['TableNames', 1]);
      exit;
   end;

   conn := Self.GetConnection(Args[0]);
   if conn = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionNotFound_COD, SSEX_EXTENSION_ConnectionNotFound, ['TableNames', Args[0]]);
      exit;
   end;

   if not conn.SQLConnection.Connected then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionClosed_COD, SSEX_EXTENSION_ConnectionClosed, ['TableNames', Args[0]]);
      exit;
   end;

   tableList := TStringList.Create;
   conn.SQLConnection.GetTableNames(tableList, conn.SQLQueryDirect.SchemaName);
    
   for I := 0 to tableList.Count - 1 do
      Result := Result + tableList.Strings[I] + #13#10;

   if tableList.Count > 0 then
      SetLength(Result, Length(Result)-2);
   
   tableList.Free;
end;

function TDBExtender.fn_TransactionCommit(Args: array of String): String;
begin
   Result := FALSE_STR;
   
   if Length(Args) < 1 then begin
      Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['TransactionCommit', 1]);
      exit;
   end;

   if Self.GetConnection(Args[0]) = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionNotFound_COD, SSEX_EXTENSION_ConnectionNotFound, ['TransactionCommit', Args[0]]);
      exit;
   end;

   if Self.GetTransaction(Args[0]) = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_TransactionNotFound_COD, SSEX_EXTENSION_TransactionNotFound, ['TransactionCommit', Args[0]]);
      exit;
   end;

   try
      Result := InternalBoolToStr(Self.CommitTransaction(Args[0]));
   except
      on E: Exception do begin
          Self.IssueExtensionError(
             SSEX_EXTENSION_DataBaseError_COD, SSEX_EXTENSION_DataBaseError,
             ['TransactionCommit', E.Message]
          );
      end;
   end;
end;

function TDBExtender.fn_TransactionRollback(Args: array of String): String;
begin
   Result := FALSE_STR;
   
   if Length(Args) < 1 then begin
      Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['TransactionRollback', 1]);
      exit;
   end;

   if Self.GetConnection(Args[0]) = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionNotFound_COD, SSEX_EXTENSION_ConnectionNotFound, ['TransactionRollback', Args[0]]);
      exit;
   end;

   if Self.GetTransaction(Args[0]) = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_TransactionNotFound_COD, SSEX_EXTENSION_TransactionNotFound, ['TransactionRollback', Args[0]]);
      exit;
   end;

   try
      Result := InternalBoolToStr(Self.RollbackTransaction(Args[0]));
   except
      on E: Exception do begin
          Self.IssueExtensionError(
             SSEX_EXTENSION_DataBaseError_COD, SSEX_EXTENSION_DataBaseError,
             ['TransactionRollback', E.Message]
          );
      end;
   end;
end;

function TDBExtender.fn_TransactionStart(Args: array of String): String;
var
   supported: Boolean;
begin
   Result := FALSE_STR;
   
   if Length(Args) < 1 then begin
      Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['TransactionStart', 1]);
      exit;
   end;

   if Self.GetConnection(Args[0]) = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionNotFound_COD, SSEX_EXTENSION_ConnectionNotFound, ['TransactionStart', Args[0]]);
      exit;
   end;

   if Self.GetTransaction(Args[0]) <> nil then begin
      Self.IssueExtensionError(SEX_EXTENSION_TransactionAlreadyExists_COD, SEX_EXTENSION_TransactionAlreadyExists, ['TransactionStart', Args[0]]);
      exit;
   end;

   try
      Result := InternalBoolToStr(Self.StartTransaction(Args[0], supported));
      if not supported then begin
         Self.IssueExtensionError(
            SSEX_EXTENSION_TransactionsNotSupported_COD, SSEX_EXTENSION_TransactionsNotSupported,
            [Args[0]], ekWarning
         );
      end;
   except
      on E: Exception do begin
          Self.IssueExtensionError(
             SSEX_EXTENSION_DataBaseError_COD, SSEX_EXTENSION_DataBaseError,
             ['TransactionStart', E.Message]
          );
      end;
   end;
end;

function TDBExtender.fn_FieldNames(Args: array of String): String;
var
    conn: TDBConnection;
    fieldList: TStrings;
    I: Integer;
    tableName, fieldName: String;
    field: TField;
    wantTypes: Boolean;
    wFName: WideString;
    wC: WideChar;
begin
   if Length(Args) < 2 then begin
      Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['FieldNames', 2]);
      exit;
   end;

   conn := Self.GetConnection(Args[0]);
   if conn = nil then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionNotFound_COD, SSEX_EXTENSION_ConnectionNotFound, ['FieldNames', Args[0]]);
      exit;
   end;

   if not conn.SQLConnection.Connected then begin
      Self.IssueExtensionError(SSEX_EXTENSION_ConnectionClosed_COD, SSEX_EXTENSION_ConnectionClosed, ['FieldNames', Args[0]]);
      exit;
   end;

   tableName := Trim(Args[1]);
   if tableName = '' then begin
      Self.IssueExtensionError(SSEX_EXTENSION_EmptyString_COD, SSEX_EXTENSION_EmptyString, [2, 'FieldNames']);
      exit;
   end;

   wantTypes := False;
   if Length(Args) > 2 then
      wantTypes := InternalStrToBool(Args[2]);

   fieldList := TStringList.Create;

   conn.SQLQueryDirect.SetSchemaInfo(stColumns, tableName, '');
   conn.SQLQueryDirect.Open;

   while not conn.SQLQueryDirect.Eof do begin
      field := conn.SQLQueryDirect.Fields.FieldByName(COLUMN_ALIAS);
      wFName := field.AsWideString;

      fieldName := '';
      for I := 1 to Length(wFName) do begin
         wC := wFName[I];
         if Ord(wC) > 255 then
            break;
         fieldName := fieldName + String(wC);
      end;
      //fieldName := field.AsString;

      if wantTypes then
        fieldName := fieldName + fieldList.NameValueSeparator + FieldTypes[field.DataType].Name;

      fieldList.Append(fieldName);
      conn.SQLQueryDirect.Next;
   end;
   
   conn.SQLQueryDirect.Close;

   for I := 0 to fieldList.Count - 1 do
      Result := Result + fieldList.Strings[I] + #13#10;

   if fieldList.Count > 0 then
      SetLength(Result, Length(Result)-2);

   conn.SQLQueryDirect.SetSchemaInfo(stNoSchema, '', '');
   fieldList.Free;
end;

{ TDBExtender.TDBConnection }

constructor TDBExtender.TDBConnection.Create(const AName: String);
begin
    FName := AName;
    FSQLConnection := TSQLConnection.Create(nil);
    FSQLConnection.LoginPrompt := False;

    FSQLQueryDirect := TSQLQuery.Create(nil);
    FSQLQueryDirect.SQLConnection := FSQLConnection;

    FSQLConnection.ConnectionName := AName;

    FOpenedSQLQueries := TObjectList.Create;
    FOpenedSQLQueries.OwnsObjects := True;
end;

destructor TDBExtender.TDBConnection.Destroy;
begin
    if Assigned(FSQLConnection) then begin
        if FSQLConnection.Connected then
            FSQLConnection.Close;
        FSQLConnection.Free;
    end;

    if Assigned(FSQLQueryDirect) then SQLQueryDirect.Free;

    if Assigned(FOpenedSQLQueries) then FOpenedSQLQueries.Free;
    
    inherited;
end;

{ TDBExtender.TDBTransaction }

constructor TDBExtender.TDBTransaction.Create(const AName: String; ADbxTransaction: TDBXTransaction);
begin
   FDBXTransaction := ADbxTransaction;
   FName := AName;
end;

initialization

   with SimpleScript.Core.Main do begin
      AddDefaultContextExtenderClass(TDBExtender);
   end;

finalization

end.
