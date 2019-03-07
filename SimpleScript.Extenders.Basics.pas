unit SimpleScript.Extenders.Basics;

interface

uses
	SimpleScript.Core, SimpleScript.Exceptions, SimpleScript.Utils,
   Classes, Contnrs, SysUtils, Windows, StrUtils, Math;

type

	TStringArgsFunctionCallProc = function (Args: array of String): String of object;

   TStringArgsFunction = class(TSimpleScriptExtension)
		strict private
      	FName: String;
    		FCallProc: TStringArgsFunctionCallProc;
      public
      	constructor Create(AOwner: TSimpleScriptExtender; const AName: String; ACallProc: TStringArgsFunctionCallProc); reintroduce;
         property Name: String read FName write FName;
         property CallProc: TStringArgsFunctionCallProc read FCallProc write FCallProc;
         function NameIs(const AValue: String): Boolean;
   end;

   TConst = class(TSimpleScriptExtension)
       strict private
          FName: String;
          FValue: String;
       public
          constructor Create(AOwner: TSimpleScriptExtender; const AName, AValue: String); reintroduce;
          property Name: String read FName write FName;
          property Value: String read FValue write FValue;
          function NameIs(const AValue: String): Boolean;
   end;

   TConstParser = class(TExtensionParser)
      public
         const
            CP_OPEN_CONST: String = '{$';
            CP_CLOSE_CONST: String = '}';
            CP_NSPACE_DIV: String = '.';
      strict private
         FActive: Boolean;
      strict protected
         FFuncList: TSimpleScriptExtensionList;
         function GetConstByName(const AName: String): TConst;
         function GetActive: Boolean; override;
      public
         procedure Parse(const Input: String; out Output: String; const Extra: Integer = 0); override;
   end;

   TFScriptParser = class(TExtensionParser)
   	public
      	const
         	BPSC_OPEN_TAG: String = '[[';
            BPSC_CLOSE_TAG: String = ']]';
            BPSC_OPEN_LIT: String = '"';
            BPSC_CLOSE_LIT: String = '"';
            BPSC_LINE_DIV: String = ';';
            BPSC_OPEN_FUNC: String = '(';
            BPSC_CLOSE_FUNC: String = ')';
            BPSC_PARAM_DIV: String = ',';
            BPSC_NSPACE_DIV: String = '.';
            BPSC_OPEN_CMMT: String = '/*';
            BPSC_CLOSE_CMMT: String = '*/';
            BPSC_CODEBLOCK_OPEN: String = '[';
            BPSC_CODEBLOCK_CLOSE: String = ']';
            PA_NATIVE_CODE: Integer = 256;

         type
            TFsFuncParameter = class(TObject)
               strict private
                  FIsCall: Boolean;
                  FLiteralValue: String;
                  FCallID: Integer;
               public
                  property IsCall: Boolean read FIsCall write FIsCall;
                  property LiteralValue: String read FLiteralValue write FLiteralValue;
                  property CallID: Integer read FCallID write FCallID;
            end;

            TFsCallStack = class;

            TFsFuncCall = class(TObject)
               strict private
               	FFunctionRef: TStringArgsFunction;
                  FParameters: TObjectList;
                  FExecResult: String;
                  FID: Integer;
                  FOwner: TFsCallStack;
               public
               	constructor Create(ACallStack: TFsCallStack);
                  destructor Destroy; override;
                  property FunctionRef: TStringArgsFunction read FFunctionRef write FFunctionRef;
                  property Parameters: TObjectList read FParameters;
                  property ExecResult: String read FExecResult write FExecResult;
                  property ID: Integer read FID write FID;
                  property Owner: TFsCallStack read FOwner;
                  procedure Execute;
            end;

            TFsCallStack = class(TObject)
               strict private
               	FCallList: TObjectList;
                  FNextID: Integer;
                  FOwner: TFScriptParser;
                  function GetExecResult: String;
               public
                  constructor Create(AOwner: TFScriptParser);
                  destructor Destroy; override;
                  property Owner: TFScriptParser read FOwner;
                  property CallList: TObjectList read FCallList;
                  function GetCallByID(const AID: Integer): TFsFuncCall;
                  property NextID: Integer read FNextID;
                  property ExecResult: String read GetExecResult;
                  procedure GoNextID;
                  procedure Execute;
            end;
      strict private
         FActive: Boolean;
         FConstParser: TConstParser;
      strict protected
         FFuncList: TSimpleScriptExtensionList;

         procedure ParseCalls(const Input: String; var CallStack: TFsCallStack); virtual;
         function GetFuncByName(const AName: String): TStringArgsFunction;
         function IsFunctionSignature(const Str: String): Boolean;
         procedure SplitCall(const Str: String; out Name, Params: String);
         procedure TrimLiteral(var Str: String);
         procedure SplitParams(const Str: String; var Params: TStrings);
         procedure BreakLines(const Str: String; var Lines: TStrings);
         procedure RemoveComments(const Input: String; out Output: String);
         function GetActive: Boolean; override;
      public
         constructor Create(AOwner: TSimpleScriptExtender); override;
         destructor Destroy; override;
         procedure Parse(const Input: String; out Output: String; const Extra: Integer = 0); override;
         procedure AddLineTags(var Str: String);
         procedure RemoveLineTags(var TaggedStr: String);
         procedure SetTagCurrentLine(TaggedStr: String);
   end;

   TBasicExtenderBase = class(TSimpleScriptExtender)
      strict protected
      	procedure PublishExtensions; virtual; abstract;
         procedure IssueExtensionError(const Code, Description: String; const Args: array of const; const Kind: TContextErrorKind = ekError);
      public
      	constructor Create(AOwner: TSimpleScriptContext); override;
         function Notify(const Msg: Integer): Integer; override;
   end;

   TBasicExtender = class(TBasicExtenderBase)
   	strict protected
      	function GetNamespace: String; override;
         procedure PublishExtensions; override;

      strict protected
         function fn_FScript(Args: array of String): String;
      	//*** Tempo ***//

         {FUNC: Data e hora; PARAMS: <nenhum>; RESULT: Data e hora no formato do sistema}
         function fn_Now(Args: array of String): String;
         {FUNC: Data; PARAMS: <nenhum>; RESULT: Data no formato do sistema}
         function fn_Date(Args: array of String): String;
         {FUNC: Hora; PARAMS: <nenhum>; RESULT: Hora no formato do sistema}
         function fn_Time(Args: array of String): String;
         {FUNC: Formatar data e/ou hora; PARAMS: 1=Data/Hora, 2=Formato igual Delphi; RESULT: Data e/ou hora formatados}
         function fn_FormatDateTime(Args: array of String): String;

         //*** Strings ***//

         {FUNC: Unir strings; PARAMS: array de strings; RESULT: União de todos as parâmetros}
         function fn_Concat(Args: array of String): String;
         {FUNC: Retro-compatibilidade, ver Concat; PARAMS: -; RESULT: -}
         function fn_Concatenate(Args: array of String): String;
         {FUNC: Retorna uma substring; PARAMS: 1=String, 2=Índice, [3=Comprimento]; RESULT: Substring}
         function fn_Cut(Args: array of String): String;
         {FUNC: Retorna uma substring à esquerda; PARAMS: 1=String, 2=Comprimento; RESULT: Substring}
         function fn_CutLeft(Args: array of String): String;
         {FUNC: Retorna uma substring à direita; PARAMS: 1=String, 2=Comprimento; RESULT: Substring}
         function fn_CutRight(Args: array of String): String;
         {FUNC: Substitui uma substring por outra em uma string;
         PARAMS: 1=String, 2=Substring procurada, 3=Substring de substituição, 4=Flag para substituir tudo, 5=Flag para ignorar case;
         RESULT: Nova string}
         function fn_Replace(Args: array of String): String;
         {FUNC: Tornar as primeiras letras das palavras em maiúsculas; PARAMS: 1=String; RESULT: Nova string}
         function fn_Captalize(Args: array of String): String;
         {FUNC: Retro-compatibilidade, ver Captalize; PARAMS: -; RESULT: -}
         function fn_FirstUpperCase(Args: array of String): String;
         {FUNC: Torna os caracters de uma string em minúsculos; PARAMS: 1=String; RESULT: Nova string}
         function fn_LowerCase(Args: array of String): String;
         {FUNC: Torna os caracteres de ums string em maiúsculos; PARAMS: 1=String; RESULT: Nova string}
         function fn_UpperCase(Args: array of String): String;
         {FUNC: Formata uma string contra uma máscara (Ex. (__) ____-____); PARAMS: 1=String, 2=Máscara; RESULT: Nova string formatada}
         function fn_Mask(Args: array of String): String;
         {}
         function fn_Char(Args: array of String): String;
         {}
         function fn_NewLine(Args: array of String): String;
         {}
         function fn_Length(Args: array of String): String;
         {}
         function fn_Pos(Args: array of String): String;

         //*** Matemática ***//

         {FUNC: Formata um número para representar moeda;
         PARAMS: 1=Valor, 2=Formato (Ex. ##,000.##), 3=Separador decimal, 4=Separador milhar;
         RESULT: String do valor formatado}
         function fn_Currency(Args: array of String): String;
         {FUNC: Torna um número decimal em inteiro; PARAMS: Número decimal; RESULT: Número truncado para inteiro}
         function fn_Int(Args: array of String): String;
         {FUNC: Arredonda um número decimal; PARAMS: 1=Número decimal, [2=Arredondamento de base 10]; RESULT: Número arredondado}
         function fn_RoundTo(Args: array of String): String;
         {FUNC: Subtração; PARAMS: 1=minuendo, 2=subtraendo; RESULT: Diferença}
         function fn_Minus(Args: array of String): String;
         {FUNC: Multiplicação; PARAMS: 1=multiplicando, 2=multiplicador; RESULT: Produto}
         function fn_Multiply(Args: array of String): String;
         {FUNC: Divisão; PARAMS: 1=dividendo, 2=divisor; RESULT: Quociente}
         function fn_Divide(Args: array of String): String;
         {FUNC: Adição; PARAMS: 1=termo 1, 2=termo 2; RESULT: Soma}
         function fn_Plus(Args: array of String): String;
         {FUNC: Retorna a parte decimal de um número decimal; PARAMS: 1=número decimal; RESULT: Número decimal}
         function fn_Frac(Args: array of String): String;
         {}
         function fn_Power(Args: array of String): String;
         {}
         function fn_Sqrt(Args: array of String): String;
      public
      	constructor Create(AOwner: TSimpleScriptContext); override;
         destructor Destroy; override;
   end;

implementation

{ TFScriptParser }

constructor TFScriptParser.Create(AOwner: TSimpleScriptExtender);
begin
   inherited;
   FConstParser := TConstParser.Create(AOwner);
end;

destructor TFScriptParser.Destroy;
begin
   FreeAndNil(FConstParser);
   inherited;
end;

function TFScriptParser.GetActive: Boolean;
begin
   Result := FActive;
end;

function TFScriptParser.GetFuncByName(const AName: String): TStringArgsFunction;
var
	fNamespace, fName: String;
   nspdiv_pos: Integer;
   curExt: TSimpleScriptExtension;
   curFunc: TStringArgsFunction;
begin
	Result := nil;

   fNamespace := '';
   nspdiv_pos := Pos(BPSC_NSPACE_DIV, AName);

   if nspdiv_pos > 0 then
      fNamespace := Copy(AName, 1, nspdiv_pos-1);

   fName := Copy(AName, nspdiv_pos+1, Length(AName)-Length(fNamespace));

   if nspdiv_pos <= 0 then
   	fNamespace := Self.Owner.Owner.DefaultNamespace;

   for curExt in FFuncList do begin
   	curFunc := TStringArgsFunction(curExt);
      if curFunc.NameIs(fName) and curFunc.Owner.NamespaceIs(fNamespace) then begin
      	Result := curFunc;
         break;
      end;
   end;
end;

function TFScriptParser.IsFunctionSignature(const Str: String): Boolean;
begin
   Result := not (
   	(Copy(Str, 1, Length(BPSC_OPEN_LIT)) = BPSC_OPEN_LIT) and
    (Copy(Str, Length(Str)-Length(BPSC_CLOSE_LIT)+1, Length(BPSC_CLOSE_LIT)) = BPSC_CLOSE_LIT)
   );

   if Result then begin
      Result := not (
        (Copy(Str, 1, Length(BPSC_CODEBLOCK_OPEN)) = BPSC_CODEBLOCK_OPEN) and
        (Copy(Str, Length(Str)-Length(BPSC_CODEBLOCK_CLOSE)+1, Length(BPSC_CODEBLOCK_CLOSE)) = BPSC_CODEBLOCK_CLOSE)
      );
   end;
   
   if Result then
		Result := (Pos(BPSC_OPEN_FUNC, Str) > 0) or (Pos(BPSC_CLOSE_FUNC, Str) > 0);
end;

procedure TFScriptParser.AddLineTags(var Str: String);
var
   taggedStr: String;
   I, Line: Integer;
   C: Char;
begin
   Line := 0;
   taggedStr := taggedStr + #1 + IntToStr(Line) + #1;
   for I := 1 to Length(Str) do begin
      C := Str[I];
      taggedStr := taggedStr + C;
      if C = #10 then begin
         Inc(Line);
         taggedStr := taggedStr + #1 + IntToStr(Line) + #1;
      end;
   end;
   Str := taggedStr;
end;

procedure TFScriptParser.RemoveLineTags(var TaggedStr: String);
var
   I: Integer;
   Str: String;
   C: Char;
   inTag: Boolean;
begin
   inTag := False;
   for I := 1 to Length(TaggedStr) do begin
      C := TaggedStr[I];
      if C = #1 then
         inTag := not inTag
      else if not inTag then
         Str := Str + C;
   end;
   TaggedStr := Str;
end;

procedure TFScriptParser.SetTagCurrentLine(TaggedStr: String);
var
   I: Integer;
   C: Char;
   tagBegin, tagEnd: Boolean;
   sLine: String;
begin
   sLine := '';
   tagBegin := False;
   tagEnd := False;
   for I := 1 to Length(TaggedStr) do begin
      C := TaggedStr[I];
      
      if (C = #1) and (not tagBegin) then
         tagBegin := True
      else if (C = #1) and (tagBegin) then
         tagEnd := True;
      
      if (C <> #1) and (tagBegin) and (not tagEnd) then
         sLine := sLine + C;
      if tagBegin and tagEnd and (sLine <> '') then begin
         Self.CurrentLine := StrToIntDef(sLine, 0);
         Self.CurrentColumn := 0;
         sLine := '';
         tagBegin := False;
         tagEnd := False;
      end;
   end;
end;

procedure TFScriptParser.Parse(const Input: String; out Output: String; const Extra: Integer);
var
   scriptBroker: TTagStringBroker;
   I, L: Integer;
   funcListOwner, rootParse: Boolean;
   callStack: TFsCallStack;
   curBrkStr, curBrkStrLine, ncCurStr, ConstOutput: String;
   linesList: TStrings;
begin
   //if (Input = '') then exit;
   if (Input = '') or (Self.Owner.Owner.Status = csTerminating) then exit;

   FConstParser.Parse(Input, ConstOutput);

   if (Extra and PA_NATIVE_CODE) = PA_NATIVE_CODE then
      	ConstOutput := BPSC_OPEN_TAG + ConstOutput + BPSC_CLOSE_TAG;

   rootParse := ((Extra and PA_ROOT_PARSE) = PA_ROOT_PARSE);
   if rootParse then
      Self.AddLineTags(ConstOutput);

   funcListOwner := not Assigned(FFuncList);
   if funcListOwner then begin
   	FFuncList := Self.Owner.Owner.GetTypedExtensionList(TStringArgsFunction);
      FActive := True;
   end;

   scriptBroker := TTagStringBroker.Create;
   try
      scriptBroker.InputString := ConstOutput;

      scriptBroker.OpenTag := BPSC_OPEN_TAG;
      scriptBroker.CloseTag := BPSC_CLOSE_TAG;
      scriptBroker.OpenLiteralMark := BPSC_OPEN_LIT;
      scriptBroker.CloseLiteralMark := BPSC_CLOSE_LIT;
      {$IFDEF VER210}
      scriptBroker.TagMode := TTagStringBroker.TTagMode.tmInnerString;
      {$ELSE}
      scriptBroker.TagMode := tmInnerString;
      {$ENDIF}
      scriptBroker.UseLiteralMarks := True;
      scriptBroker.CaseSensitive := False;
      scriptBroker.Break;

      for I := 0 to Length(scriptBroker.BrokenStrings) - 1 do begin
         if Self.Owner.Owner.Status = csTerminating then break;

         curBrkStr := scriptBroker.BrokenStrings[I].Str;
         
         {$IFDEF VER210}
         if scriptBroker.BrokenStrings[I].Typ = TTagStringBroker.TTagStringPartType.ptLiteralString then
         {$ELSE}
         if scriptBroker.BrokenStrings[I].Typ = ptLiteralString then begin
         {$ENDIF}
            if rootParse then
               Self.RemoveLineTags(curBrkStr);
            Output := Output + curBrkStr
         end else begin
            if curBrkStr = '' then continue;

            Self.RemoveComments(curBrkStr, ncCurStr);
            
            linesList := TStringList.Create;
            try
               Self.BreakLines(ncCurStr, linesList);

               for L := 0 to linesList.Count - 1 do begin
                  if Self.Owner.Owner.Status = csTerminating then break;
                  
                  curBrkStrLine := linesList.Strings[L];

                  Self.SetTagCurrentLine(curBrkStrLine);
                  if rootParse then Self.RemoveLineTags(curBrkStrLine);
                  curBrkStrLine := Trim(curBrkStrLine);

                  if curBrkStrLine = '' then continue;
                  callStack := TFsCallStack.Create(Self);
                  try
                     Self.ParseCalls(curBrkStrLine, callStack);
                     try
                     	callStack.Execute;
                     except
                     	{$WARN SYMBOL_DEPRECATED OFF}
                     	on E: Exception do begin
                           if E is EStackOverflow then begin
                           	Self.Owner.Owner.SetParseReturnValue(PRET_STKOVERFLOW_TERMINATION);
                           	Exit;
                           end else
                           	Self.Owner.Owner.Errors.New(SSEX_GENERIC_Unhandled_COD, SSEX_GENERIC_Unhandled, ekError);
                        end;
                        {$WARN SYMBOL_DEPRECATED ON}
                     end;
                        
                     Output := Output + callStack.ExecResult;
                  finally
                     callStack.Free;
                  end;
               end;

            finally
                linesList.Free;
            end;

         end;
      end;

   finally
   	scriptBroker.Free;
      if funcListOwner then begin
         if Assigned(FFuncList) then begin
            FFuncList.Free;
            FFuncList := nil;
         end;
         FActive := False;
      end;
   end;
end;

procedure TFScriptParser.ParseCalls(const Input: String; var CallStack: TFsCallStack);
var
   params: TStrings;
   callName, callParams, curBrkStr: String;
   newCall: TFsFuncCall;
   P: Integer;
   newCallFunc: TStringArgsFunction;
   newCallParam: TFsFuncParameter;
begin
   if Input = '' then exit;
   
	SplitCall(Input, callName, callParams);

   Self.CurrentColumn := Pos(callName, Input)-1;

   params := TStringList.Create;
   try
      newCall := TFsFuncCall.Create(CallStack);
      newCall.ID := CallStack.NextID;
      CallStack.CallList.Insert(0, newCall);

      CallStack.GoNextID;

      newCallFunc := Self.GetFuncByName(callName);
      if newCallFunc <> nil then
         newCall.FunctionRef := newCallFunc
      else begin
         Self.Owner.Owner.Errors.New(
            SSEX_EXTENSION_FunctionNotExists_COD,
            Format(SSEX_EXTENSION_FunctionNotExists, [callName], Self.Owner.Owner.LocalFormatSettings),
            ekError,
            Self.Owner.Owner.ActiveParser.CurrentLine,
            Self.Owner.Owner.ActiveParser.CurrentColumn,
            Self.Owner.Owner.ActiveParser.CurrentFile
         );
      end;

      if callParams <> '' then begin
         SplitParams(callParams, params);

         for P := 0 to params.Count - 1 do begin
            curBrkStr := params.Strings[P];

            newCallParam := TFsFuncParameter.Create;
            newCall.Parameters.Add(newCallParam);

            if Self.IsFunctionSignature(curBrkStr) then begin
               newCallParam.IsCall := True;
               newCallParam.CallID := CallStack.NextID;

               Self.ParseCalls(curBrkStr, CallStack);
            end else begin
               Self.TrimLiteral(curBrkStr);
               newCallParam.LiteralValue := curBrkStr;
            end;
         end;
      end;

   finally
      Self.CurrentColumn := Self.CurrentColumn + Length(callName);
   	params.Free;
   end;
end;

procedure TFScriptParser.RemoveComments(const Input: String; out Output: String);
var
	cmmBroker: TTagStringBroker;
   I: Integer;
begin
	cmmBroker := TTagStringBroker.Create;
   cmmBroker.InputString := Input;
	cmmBroker.OpenTag := BPSC_OPEN_CMMT;
   cmmBroker.CloseTag := BPSC_CLOSE_CMMT;
   cmmBroker.OpenLiteralMark := BPSC_OPEN_LIT;
   cmmBroker.CloseLiteralMark := BPSC_CLOSE_LIT;
   {$IFDEF VER210}
   cmmBroker.TagMode := TTagStringBroker.TTagMode.tmInnerString;
   {$ELSE}
   cmmBroker.TagMode := tmInnerString;
   {$ENDIF}
   cmmBroker.UseLiteralMarks := True;
   cmmBroker.CaseSensitive := False;
   cmmBroker.Break;

   for I := 0 to Length(cmmBroker.BrokenStrings) -1 do begin
      {$IFDEF VER210}
      if (cmmBroker.BrokenStrings[I].Typ = TTagStringBroker.TTagStringPartType.ptLiteralString) then begin
      {$ELSE}
      if (cmmBroker.BrokenStrings[I].Typ = ptLiteralString) then begin
      {$ENDIF}
         Output := Output + cmmBroker.BrokenStrings[I].Str;
      end;
   end;

   cmmBroker.Free;
end;

procedure TFScriptParser.SplitCall(const Str: String; out Name, Params: String);
var
   C, left, right: Integer;
   cchar: String;
begin
   left := Pos(BPSC_OPEN_FUNC, Str);
   Name := Trim(Copy(Str, 1, left-1));

   right := Length(Str);
   for C := Length(Str) downto 1 do begin
   	cchar := Copy(Str, C, Length(BPSC_CLOSE_FUNC));
      if cchar = BPSC_CLOSE_FUNC then begin
   		right := C;
   		break;
   	end;
   end;

   Params := Copy(Str, left+1, right-left-1);
end;

procedure TFScriptParser.SplitParams(const Str: String; var Params: TStrings);
var
   tmp: String;
   I, fOpen, bOpen: Integer;
   isStr, isSubCodeBlock: boolean;
begin
   Params.Clear;
   isStr := False;
   //isSubCodeBlock := False;
   fOpen := 0;
   bOpen := 0;

	I := 1;
   while I <= Length(Str) do begin
      if (Copy(Str, I, Length(BPSC_CLOSE_LIT)) = BPSC_CLOSE_LIT) and isStr then
         isStr := False
      else if (Copy(Str, I, Length(BPSC_OPEN_LIT)) = BPSC_OPEN_LIT) and (not isStr) then
         isStr := True;

      if (Copy(Str, I, Length(BPSC_CODEBLOCK_CLOSE)) = BPSC_CODEBLOCK_CLOSE) and (not isStr) then //isSubCodeBlock then
         Dec(bOpen) //isSubCodeBlock := False
      else if (Copy(Str, I, Length(BPSC_CODEBLOCK_OPEN)) = BPSC_CODEBLOCK_OPEN) and (not isStr) then //(not isSubCodeBlock) then
         Inc(bOpen); //isSubCodeBlock := True;

      isSubCodeBlock := (bOpen > 0);

      //checar pelos delimitadores de função
      if (Copy(Str, I, Length(BPSC_OPEN_FUNC)) = BPSC_OPEN_FUNC) and (not isStr) and (not isSubCodeBlock) then
      	fOpen := fOpen + 1
      else if (Copy(Str, I, Length(BPSC_CLOSE_FUNC)) = BPSC_CLOSE_FUNC) and (not isStr) and (not isSubCodeBlock) then
      	fOpen := fOpen - 1;

      if (Copy(Str, I, Length(BPSC_PARAM_DIV)) = BPSC_PARAM_DIV) and (not isStr) and (not isSubCodeBlock) and (fOpen = 0) then begin
         Params.Append(Trim(tmp));
         tmp := '';
         Inc(I, Length(BPSC_PARAM_DIV)-1);
      end else
      	 tmp := tmp + Copy(Str, I, 1);

      {if (Copy(Str, I, Length(BPSC_CLOSE_LIT)) = BPSC_CLOSE_LIT) then
         isStr := False;

      if (Copy(Str, I, Length(BPSC_CODEBLOCK_CLOSE)) = BPSC_CODEBLOCK_CLOSE) then
         isSubCodeBlock := False;}

      Inc(I);
   end;
   Params.Append(Trim(tmp));
end;

procedure TFScriptParser.BreakLines(const Str: String; var Lines: TStrings);
var
   tmp: String;
   I, litOpen, codeOpen: Integer;
   //isStr, isSubCodeBlock: boolean;
begin
   Lines.Clear;
   
   litOpen := 0;
   codeOpen := 0;

   I := 1;
   while I <= Length(Str) do begin
      //checar pelo delimitador de sub-bloco de código
      if (Copy(Str, I, Length(BPSC_CODEBLOCK_CLOSE)) = BPSC_CODEBLOCK_CLOSE) and (codeOpen > 0) then
         Dec(codeOpen)
      else if Copy(Str, I, Length(BPSC_CODEBLOCK_OPEN)) = BPSC_CODEBLOCK_OPEN then
         Inc(codeOpen);

   	  //checar pelo delimitador de string
      if (Copy(Str, I, Length(BPSC_CLOSE_LIT)) = BPSC_CLOSE_LIT) and (litOpen > 0) then
         Dec(litOpen)
      else if Copy(Str, I, Length(BPSC_OPEN_LIT)) = BPSC_OPEN_LIT then
         Inc(litOpen);

      if (Copy(Str, I, Length(BPSC_LINE_DIV)) = BPSC_LINE_DIV) and (litOpen = 0) and (codeOpen = 0) then begin
         Lines.Append(tmp);
         tmp := '';
         Inc(I, Length(BPSC_LINE_DIV)-1);
      end else
      	tmp := tmp + Copy(Str, I, 1);

      {if Copy(Str, I, Length(BPSC_CLOSE_LIT)) = BPSC_CLOSE_LIT then
         Dec(litOpen);

      if Copy(Str, I, Length(BPSC_CODEBLOCK_CLOSE)) = BPSC_CODEBLOCK_CLOSE then
         Dec(codeOpen);}

      Inc(I);
   end;
   Lines.Append(tmp);
end;

procedure TFScriptParser.TrimLiteral(var Str: String);
var
   openLitLen, closeLitLen: Integer;
   openCodeLen, closeCodeLen: Integer;
begin
   openLitLen := Length(BPSC_OPEN_LIT);
   closeLitLen := Length(BPSC_CLOSE_LIT);

   if (Copy(Str, 1, openLitLen) = BPSC_OPEN_LIT) and
   (Copy(Str, Length(Str) - closeLitLen + 1, closeLitLen) = BPSC_CLOSE_LIT) then
      Str := Copy(Str, openLitLen + 1, Length(Str) - closeLitLen - openLitLen);

   openCodeLen := Length(BPSC_CODEBLOCK_OPEN);
   closeCodeLen := Length(BPSC_CODEBLOCK_CLOSE);

   if (Copy(Str, 1, openCodeLen) = BPSC_CODEBLOCK_OPEN) and
   (Copy(Str, Length(Str) - closeCodeLen + 1, closeCodeLen) = BPSC_CODEBLOCK_CLOSE) then
      Str := Copy(Str, openCodeLen + 1, Length(Str) - closeCodeLen - openCodeLen);
end;

{ TBasicExtender }

constructor TBasicExtender.Create(AOwner: TSimpleScriptContext);
begin
	inherited Create(AOwner);
end;

destructor TBasicExtender.Destroy;
begin
	inherited;
end;

//--------------------------------------

function TBasicExtender.fn_Captalize(Args: array of String): String;
var
	tmp, cchar: String;
	I: Integer;
begin
	if Length(Args) < 1 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Captalize', 1]);
      exit;
   end;

   tmp := LowerCase(Args[0]);
   for I := 1 to Length(tmp) do begin
   	cchar := Copy(tmp, I, 1);
      if I = 1 then
         Result := UpperCase(cchar)
      else if (Copy(Result, Length(Result)) = #32) then
         Result := Result + UpperCase(cchar)
      else
         Result := Result + cchar;
   end;
end;

function TBasicExtender.fn_Char(Args: array of String): String;
var
    charCode: Integer;
begin
   if Length(Args) < 1 then begin
      Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Char', 1]);
      exit;
   end;
   if (not TryStrToInt(Args[0], charCode)) or (not InRange(charCode, 0, 255)) then begin
   	  Self.IssueExtensionError(SSEX_EXTENSION_InvalidByte_COD, SSEX_EXTENSION_InvalidByte, [Args[0], 'Char']);
      exit;
   end;

   Result := Chr(charCode);
end;

function TBasicExtender.fn_Concat(Args: array of String): String;
var
	I: Integer;
begin
   Result := '';
   for I := Low(Args) to High(Args) do
   	Result := Result + Args[I];
end;

function TBasicExtender.fn_Concatenate(Args: array of String): String;
begin
   Self.IssueExtensionError(
   	SSEX_EXTENSION_FunctionDeprecated_COD,
      SSEX_EXTENSION_FunctionDeprecated,
      ['@ (ou &)', 'Concat'],
      ekInfo
   );
	Result := Self.fn_Concat(Args);
end;

function TBasicExtender.fn_Currency(Args: array of String): String;
var
   outCurr: Currency;
   FormatFmt: TFormatSettings;
begin
	if Length(Args) < 4 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Currency', 4]);
      exit;
   end;

   if Args[2] = '' then begin
      Self.IssueExtensionError(SSEX_EXTENSION_EmptyString_COD, SSEX_EXTENSION_EmptyString, [3, 'Currency']);
      exit;
   end;
   if Args[3] = '' then begin
      Self.IssueExtensionError(SSEX_EXTENSION_EmptyString_COD, SSEX_EXTENSION_EmptyString, [4, 'Currency']);
      exit;
   end;

   {GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, FormatFmt);}
   FormatFmt := Self.Owner.LocalFormatSettings;
   FormatFmt.DecimalSeparator := Args[2][1];
   FormatFmt.ThousandSeparator := Args[3][1];

   if ((TryStrToCurr(Args[0], outCurr, FixedFormatSettings)) or (TryStrToCurr(Args[0], outCurr, Self.Owner.LocalFormatSettings))) then
   	Result := FormatCurr(Args[1], outCurr, FormatFmt)
   else
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[0], 'Currency']);
end;

function TBasicExtender.fn_Cut(Args: array of String): String;
var
	index, count: Integer;
begin
	count := 0;

   if Length(Args) < 2 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Cut', 2]);
      exit;
   end;

   if not TryStrToInt(Args[1], index) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidInteger_COD, SSEX_EXTENSION_InvalidInteger, [Args[1], 'Cut']);
      exit;
   end;
   if (Length(Args) > 2) and (not TryStrToInt(Args[2], count)) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidInteger_COD, SSEX_EXTENSION_InvalidInteger, [Args[2], 'Cut']);
      exit;
   end;

   Result := Copy(Args[0], index, count);
end;

function TBasicExtender.fn_CutLeft(Args: array of String): String;
var
	count: Integer;
begin
   if Length(Args) < 2 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['CutLeft', 2]);
      exit;
   end;

   if not TryStrToInt(Args[1], count) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidInteger_COD, SSEX_EXTENSION_InvalidInteger, [Args[1], 'CutLeft']);
      exit;
   end;

   Result := Copy(Args[0], 1, count);
end;

function TBasicExtender.fn_CutRight(Args: array of String): String;
var
	count: Integer;
begin
   if Length(Args) < 2 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['CutRight', 2]);
      exit;
   end;

   if not TryStrToInt(Args[1], count) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidInteger_COD, SSEX_EXTENSION_InvalidInteger, [Args[1], 'CutRight']);
      exit;
   end;

   Result := Copy(Args[0], Length(Args[0]) - count + 1, count);
end;

function TBasicExtender.fn_Date(Args: array of String): String;
begin
	Result := DateToStr(Date, Self.Owner.LocalFormatSettings);
end;

function TBasicExtender.fn_Divide(Args: array of String): String;
var
	op1, op2: Extended;
begin
   if Length(Args) < 2 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['%', 2]);
      exit;
   end;

   op1 := InternalStrToFloat(Args[0]);
   if IsNan(op1) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[0], '%']);
      exit;
   end;

   op2 := InternalStrToFloat(Args[1]);
   if IsNan(op2) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[1], '%']);
      exit;
   end;

   Result := InternalFloatToStr(op1 / op2);
end;

function TBasicExtender.fn_FirstUpperCase(Args: array of String): String;
begin
   Self.IssueExtensionError(
   	SSEX_EXTENSION_FunctionDeprecated_COD,
      SSEX_EXTENSION_FunctionDeprecated,
      ['FirstUpperCase', 'Captalize'],
      ekInfo
   );
	Result := Self.fn_Captalize(Args);
end;

function TBasicExtender.fn_FormatDateTime(Args: array of String): String;
var
	baseDate: TDateTime;
begin
   if Length(Args) < 2 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['FormatDateTime', 2]);
      exit;
   end;

   if not TryStrToDateTime(Args[0], baseDate) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDate_COD, SSEX_EXTENSION_InvalidDate, [Args[0], 'FormatDateTime']);
      exit;
   end;

   DateTimeToString(Result, Args[1], baseDate, Self.Owner.LocalFormatSettings);
end;

function TBasicExtender.fn_Frac(Args: array of String): String;
var
    outFloat: Extended;
begin
    if Length(Args) < 1 then begin
        Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Frac', 1]);
        exit;
    end;

    outFloat := InternalStrToFloat(Args[0]);
    if IsNaN(outFloat) then begin
    	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[0], 'Frac']);
      exit;
    end;

    Result := InternalFloatToStr(Frac(outFloat));
end;

function TBasicExtender.fn_FScript(Args: array of String): String;
begin
   Result := '~ FScript don'#39't means fuck script !!! ~';
end;

function TBasicExtender.fn_Int(Args: array of String): String;
var
	outFloat: Extended;
begin
	if Length(Args) < 1 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Int', 1]);
      exit;
   end;

	outFloat := InternalStrToFloat(Args[0]);
	if IsNan(outFloat) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[0], 'Int']);
      exit;
   end;

	Result := IntToStr(Trunc(outFloat));
end;

function TBasicExtender.fn_Length(Args: array of String): String;
begin
   if Length(Args) < 1 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Length', 1]);
      exit;
   end;

   Result := IntToStr(Length(Args[0]));
end;

function TBasicExtender.fn_LowerCase(Args: array of String): String;
begin
	if Length(Args) < 1 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['LowerCase', 1]);
      exit;
   end;

   Result := LowerCase(Args[0]);
end;

function TBasicExtender.fn_Mask(Args: array of String): String;
var
   mask, value: String;
   L, delay: Integer;
   cV, cM: Char;
const
	NC: Char = '_';
begin
   if Length(Args) < 2 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Mask', 2]);
      exit;
   end;

   mask := Args[1];
   value := Args[0];

   if mask = '' then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_EmptyString_COD, SSEX_EXTENSION_EmptyString, [1, 'Mask']);
      exit;
   end;

   L := 1;
   delay := 0;
   while L <= (Length(value) + delay) do begin
      if L <= Length(mask) then
      	cM := mask[L]
      else
      	cM := NC;

      cV := value[L-delay];

      if cM = NC then
      	Result := Result + cV
      else begin
      	Result := Result + cM;
      	Inc(delay);
      end;

      Inc(L);
   end;
end;

function TBasicExtender.fn_Minus(Args: array of String): String;
var
	op1, op2: Extended;
begin
   if Length(Args) < 2 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['-', 2]);
      exit;
   end;

   op1 := InternalStrToFloat(Args[0]);
   if IsNan(op1) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[0], '-']);
      exit;
   end;

   op2 := InternalStrToFloat(Args[1]);
   if IsNan(op2) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[1], '-']);
      exit;
   end;

   Result := InternalFloatToStr(op1 - op2);
end;

function TBasicExtender.fn_Multiply(Args: array of String): String;
var
	op1, op2: Extended;
begin
   if Length(Args) < 2 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['*', 2]);
      exit;
   end;

   op1 := InternalStrToFloat(Args[0]);
   if IsNan(op1) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[0], '*']);
      exit;
   end;

   op2 := InternalStrToFloat(Args[1]);
   if IsNan(op2) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[1], '*']);
      exit;
   end;

   Result := InternalFloatToStr(op1 * op2);
end;

function TBasicExtender.fn_NewLine(Args: array of String): String;
var
   nlCount: Integer;
begin
   nlCount := 1;
   if Length(Args) > 0 then begin
      if not TryStrToInt(Args[0], nlCount) then begin
   	   Self.IssueExtensionError(SSEX_EXTENSION_InvalidInteger_COD, SSEX_EXTENSION_InvalidInteger, [Args[0], 'NewLine']);
         exit;
      end;
   end;

   nlCount := Max(nlCount, 1);
   Result := DupeString(#13#10, nlCount);
end;

function TBasicExtender.fn_Now(Args: array of String): String;
begin
   Result := DateTimeToStr(Now, Self.Owner.LocalFormatSettings);
end;

function TBasicExtender.fn_Plus(Args: array of String): String;
var
    op1, op2: Extended;
begin
    if Length(Args) < 2 then begin
        Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['+', 2]);
        exit;
    end;

    op1 := InternalStrToFloat(Args[0]);
    if IsNaN(op1) then begin
    	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[0], '+']);
      exit;
    end;

    op2 := InternalStrToFloat(Args[1]);
    if IsNaN(op2) then begin
    	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[1], '+']);
      exit;
    end;

    Result := InternalFloatToStr(op1 + op2);
end;

function TBasicExtender.fn_Pos(Args: array of String): String;
var
   offset: Integer;
begin
   if Length(Args) < 2 then begin
      Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Pos', 2]);
      exit;
   end;

   offset := 1;
   if Length(Args) > 2 then begin
      if not TryStrToInt(Args[2], offset) then begin
         Self.IssueExtensionError(SSEX_EXTENSION_InvalidInteger_COD, SSEX_EXTENSION_InvalidInteger, [Args[2], 'Pos']);
         exit;
      end;
   end;

   Result := IntToStr(PosEx(Args[0], Args[1], offset));
end;

function TBasicExtender.fn_Power(Args: array of String): String;
var
	base, exponent: Extended;
begin
   if Length(Args) < 2 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Power', 2]);
      exit;
   end;

   base := InternalStrToFloat(Args[0]);
   if IsNan(base) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[0], 'Power']);
      exit;
   end;

   exponent := InternalStrToFloat(Args[1]);
   if IsNan(exponent) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[1], 'Power']);
      exit;
   end;

   Result := InternalFloatToStr(Power(base, exponent));
end;

function TBasicExtender.fn_Replace(Args: array of String): String;
var
   rf: TReplaceFlags;
begin
   rf := [];
   if Length(Args) < 5 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Replace', 5]);
      exit;
   end;

   if InternalStrToBool(Args[3]) then rf := rf + [rfReplaceAll];
   if InternalStrToBool(Args[4]) then rf := rf + [rfIgnoreCase];

   Result := StringReplace(Args[0], Args[1], Args[2], rf);
end;

function TBasicExtender.fn_RoundTo(Args: array of String): String;
var
	outFloat: Double;
	toDigit: Integer;
begin
	if Length(Args) < 1 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['RoundTo', 1]);
      exit;
   end;

	outFloat := InternalStrToFloat(Args[0]);
	if IsNan(outFloat) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[0], 'RoundTo']);
      exit;
   end;

   if Length(Args) > 1 then begin
      if not TryStrToInt(Args[1], toDigit) then begin
         Self.IssueExtensionError(SSEX_EXTENSION_InvalidInteger_COD, SSEX_EXTENSION_InvalidInteger, [Args[1], 'RoundTo']);
         exit;
      end;
   end else
      toDigit := 0;

	Result := InternalFloatToStr(RoundTo(outFloat, Math.EnsureRange(toDigit, -37, 37)));
end;

function TBasicExtender.fn_Sqrt(Args: array of String): String;
var
	op: Extended;
begin
   if Length(Args) < 1 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Sqrt', 1]);
      exit;
   end;

   op := InternalStrToFloat(Args[0]);
   if IsNan(op) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[0], 'Sqrt']);
      exit;
   end;

   Result := InternalFloatToStr(Sqrt(op));
end;

function TBasicExtender.fn_Time(Args: array of String): String;
begin
	Result := TimeToStr(Time, Self.Owner.LocalFormatSettings);
end;

function TBasicExtender.fn_UpperCase(Args: array of String): String;
begin
	if Length(Args) < 1 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['UpperCase', 1]);
      exit;
   end;

   Result := UpperCase(Args[0]);
end;

//--------------------------------------

function TBasicExtender.GetNamespace: String;
begin
   Result := 'Base';
end;

procedure TBasicExtender.PublishExtensions;
begin
	with Self.Extensions do begin
      Add(TFScriptParser.Create(Self));
      //-----------------------------

      Add(TStringArgsFunction.Create(Self, 'FScript', Self.fn_FScript));

      Add(TStringArgsFunction.Create(Self, 'Now', Self.fn_Now));
      Add(TStringArgsFunction.Create(Self, 'Date', Self.fn_Date));
      Add(TStringArgsFunction.Create(Self, 'Time', Self.fn_Time));
      Add(TStringArgsFunction.Create(Self, 'FormatDateTime', Self.fn_FormatDateTime));

      Add(TStringArgsFunction.Create(Self, 'Concat', Self.fn_Concat));
      Add(TStringArgsFunction.Create(Self, '@', Self.fn_Concatenate));
      Add(TStringArgsFunction.Create(Self, '&', Self.fn_Concatenate));
      Add(TStringArgsFunction.Create(Self, 'Cut', Self.fn_Cut));
      Add(TStringArgsFunction.Create(Self, 'CutLeft', Self.fn_CutLeft));
      Add(TStringArgsFunction.Create(Self, 'CutRight', Self.fn_CutRight));
      Add(TStringArgsFunction.Create(Self, 'Replace', Self.fn_Replace));
      Add(TStringArgsFunction.Create(Self, 'Captalize', Self.fn_Captalize));
      Add(TStringArgsFunction.Create(Self, 'FirstUpperCase', Self.fn_FirstUpperCase));
      Add(TStringArgsFunction.Create(Self, 'LowerCase', Self.fn_LowerCase));
      Add(TStringArgsFunction.Create(Self, 'UpperCase', Self.fn_UpperCase));
      Add(TStringArgsFunction.Create(Self, 'Mask', Self.fn_Mask));
      Add(TStringArgsFunction.Create(Self, 'Char', Self.fn_Char));
      Add(TStringArgsFunction.Create(Self, 'NewLine', Self.fn_NewLine));
      Add(TStringArgsFunction.Create(Self, 'Length', Self.fn_Length));
      Add(TStringArgsFunction.Create(Self, 'Pos', Self.fn_Pos));

      Add(TStringArgsFunction.Create(Self, 'Currency', Self.fn_Currency));
      Add(TStringArgsFunction.Create(Self, 'Int', Self.fn_Int));
      Add(TStringArgsFunction.Create(Self, 'RoundTo', Self.fn_RoundTo));
      Add(TStringArgsFunction.Create(Self, '-', Self.fn_Minus));
      Add(TStringArgsFunction.Create(Self, '*', Self.fn_Multiply));
      Add(TStringArgsFunction.Create(Self, '%', Self.fn_Divide));
      Add(TStringArgsFunction.Create(Self, '+', Self.fn_Plus));
      Add(TStringArgsFunction.Create(Self, 'Frac', Self.fn_Frac));
      Add(TStringArgsFunction.Create(Self, 'Power', Self.fn_Power));
      Add(TStringArgsFunction.Create(Self, 'Sqrt', Self.fn_Sqrt));

      //----------------------------------

      Add(TConst.Create(Self, 'NULL', ''));
      Add(TConst.Create(Self, 'EMPTY', ''));
      Add(TConst.Create(Self, 'CRLF', #13#10));
      Add(TConst.Create(Self, 'OPART', '40'));
      Add(TConst.Create(Self, 'CPART', '41'));
      Add(TConst.Create(Self, 'OBRKT', '91'));
      Add(TConst.Create(Self, 'CBRKT', '93'));
      Add(TConst.Create(Self, 'DQT', '34'));
   end;
end;

{ TStringArgsFunction }

constructor TStringArgsFunction.Create(AOwner: TSimpleScriptExtender; const AName: String;
  ACallProc: TStringArgsFunctionCallProc);
begin
   inherited Create(AOwner);
   Self.Name := AName;
   Self.CallProc := ACallProc;
end;

function TStringArgsFunction.NameIs(const AValue: String): Boolean;
begin
   Result := (LowerCase(Self.Name) = LowerCase(AValue));
end;

{ TFScriptParser.TFsCallStack }

constructor TFScriptParser.TFsCallStack.Create(AOwner: TFScriptParser);
begin
   FOwner := AOwner;
	FCallList := TObjectList.Create;
   FCallList.OwnsObjects := True;
   FNextID := 0;
end;

destructor TFScriptParser.TFsCallStack.Destroy;
begin
   if Assigned(FCallList) then
   	FCallList.Free;

	inherited;
end;

procedure TFScriptParser.TFsCallStack.Execute;
var
	pCurObj: Pointer;
begin
	for pCurObj in Self.CallList do begin
   	TFsFuncCall(pCurObj).Execute;
      if Self.Owner.Owner.Owner.Status = csTerminating then break;
   end;
end;

function TFScriptParser.TFsCallStack.GetCallByID(const AID: Integer): TFsFuncCall;
var
	pCurObj: Pointer;
begin
	Result := nil;
	for pCurObj in Self.CallList do begin
      if TFsFuncCall(pCurObj).ID = AID then begin
      	Result := TFsFuncCall(pCurObj);
         break;
      end;
   end;
end;

function TFScriptParser.TFsCallStack.GetExecResult: String;
begin
   Result := '';
   if FCallList.Last <> nil then
   	Result := TFsFuncCall(FCallList.Last).ExecResult;
end;

procedure TFScriptParser.TFsCallStack.GoNextID;
begin
	Inc(FNextID);
end;

{ TFScriptParser.TFsFuncCall }

constructor TFScriptParser.TFsFuncCall.Create(ACallStack: TFsCallStack);
begin
   FParameters := TObjectList.Create;
   FParameters.OwnsObjects := True;

   FID := -1;
   FOwner := ACallStack;
end;

destructor TFScriptParser.TFsFuncCall.Destroy;
begin
   if Assigned(FParameters) then
   	FParameters.Free;

	inherited;
end;

procedure TFScriptParser.TFsFuncCall.Execute;
var
    pArgs: array of String;
    P: Integer;
    curParam: TFsFuncParameter;
    innerCall: TFsFuncCall;
begin
   SetLength(pArgs, Parameters.Count);

   for P := 0 to Parameters.Count - 1 do begin
     curParam := TFsFuncParameter(Parameters.Items[P]);
     if curParam.IsCall then begin
         innerCall := Self.Owner.GetCallByID(curParam.CallID);
         if innerCall <> nil then
             pArgs[P] := innerCall.ExecResult;
     end else
         pArgs[P] := curParam.LiteralValue;
   end;

   if Assigned(FunctionRef) then begin
     Self.ExecResult := FunctionRef.CallProc(pArgs);
   end;
end;

{ TBasicExtenderBase }

constructor TBasicExtenderBase.Create(AOwner: TSimpleScriptContext);
begin
	inherited;
   Self.PublishExtensions;
end;

procedure TBasicExtenderBase.IssueExtensionError(const Code, Description: String; const Args: array of const; const Kind: TContextErrorKind = ekError);
var
	err: TSimpleScriptContextError;
begin
	err := Self.Owner.Errors.New(
      Code,
      Format(Description, Args, Self.Owner.LocalFormatSettings),
      Kind,
      Self.Owner.ActiveParser.CurrentLine,
      Self.Owner.ActiveParser.CurrentColumn,
      Self.Owner.ActiveParser.CurrentFile
   );
end;

function TBasicExtenderBase.Notify(const Msg: Integer): Integer;
begin
   Result := 0;
end;

{ TConstParser }

function TConstParser.GetActive: Boolean;
begin
   Result := FActive;
end;

function TConstParser.GetConstByName(const AName: String): TConst;
var
   cNamespace, cName: String;
   nspdiv_pos: Integer;
   curExt: TSimpleScriptExtension;
   curConst: TConst;
begin
	Result := nil;

   cNamespace := '';
   nspdiv_pos := Pos(CP_NSPACE_DIV, AName);

   if nspdiv_pos > 0 then
      cNamespace := Copy(AName, 1, nspdiv_pos-1);

   cName := Copy(AName, nspdiv_pos+1, Length(AName)-Length(cNamespace));

   if nspdiv_pos <= 0 then
   	cNamespace := Self.Owner.Owner.DefaultNamespace;

   for curExt in FFuncList do begin
      curConst := TConst(curExt);
      if curConst.NameIs(cName) and curConst.Owner.NamespaceIs(cNamespace) then begin
         Result := curConst;
         break;
      end;
   end;
end;

procedure TConstParser.Parse(const Input: String; out Output: String; const Extra: Integer);
var
   constBroker: TTagStringBroker;
   funcListOwner: Boolean;
   foundConst: TConst;
   I: Integer;
   curBrkStr: String;
begin
   //if Input = '' then exit;
   if (Input = '') or (Self.Owner.Owner.Status = csTerminating) then exit;
   
   funcListOwner := not Assigned(FFuncList);
   if funcListOwner then begin
      FActive := True;
      FFuncList := Self.Owner.Owner.GetTypedExtensionList(TConst);
   end;

   constBroker := TTagStringBroker.Create;
   constBroker.InputString := Input;
   constBroker.OpenTag := CP_OPEN_CONST;
   constBroker.CloseTag := CP_CLOSE_CONST;
   constBroker.TagMode := tmInnerString;
   constBroker.OpenLiteralMark := '/';
   constBroker.CloseLiteralMark := '/';
   constBroker.UseLiteralMarks := False;
   constBroker.CaseSensitive := False;
   constBroker.Break;

   for I := 0 to (Length(constBroker.BrokenStrings)-1) do begin
      curBrkStr := constBroker.BrokenStrings[I].Str;
      
      if constBroker.BrokenStrings[I].Typ = ptLiteralString then
         Output := Output + curBrkStr
      else begin
          foundConst := Self.GetConstByName(curBrkStr);

          if foundConst = nil then begin
             Self.Owner.Owner.Errors.New(
                SSEX_EXTENSION_ConstantNotExists_COD,
                Format(SSEX_EXTENSION_ConstantNotExists, [curBrkStr], Self.Owner.Owner.LocalFormatSettings),
                ekError,
                Self.Owner.Owner.ActiveParser.CurrentLine,
                Self.Owner.Owner.ActiveParser.CurrentColumn,
                Self.Owner.Owner.ActiveParser.CurrentFile
             );
          end else begin
            if foundConst.Name = 'CRLF' then begin
               Self.Owner.Owner.Errors.New(
                SSEX_EXTENSION_ConstDeprecated_COD,
                Format(SSEX_EXTENSION_ConstDeprecated, [foundConst.Name, 'NewLine()'], Self.Owner.Owner.LocalFormatSettings),
                ekInfo,
                Self.Owner.Owner.ActiveParser.CurrentLine,
                Self.Owner.Owner.ActiveParser.CurrentColumn,
                Self.Owner.Owner.ActiveParser.CurrentFile
             );
            end;

            Output := Output + foundConst.Value;
          end;
      end;
   end;

   constBroker.Free;
   if funcListOwner then begin
      if Assigned(FFuncList) then begin
         FFuncList.Free;
         FFuncList := nil;
      end;
      FActive := False;
   end;
end;

{ TConst }

constructor TConst.Create(AOwner: TSimpleScriptExtender; const AName, AValue: String);
begin
    inherited Create(AOwner);
    FName := AName;
    FValue := AValue; 
end;

function TConst.NameIs(const AValue: String): Boolean;
begin
    Result := (LowerCase(Name) = LowerCase(AValue));
end;

initialization

	with SimpleScript.Core.Main do begin
   	AddDefaultContextExtenderClass(TBasicExtender);
   end;

finalization

end.
