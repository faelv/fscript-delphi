unit SimpleScript.Extenders.Advanced;

interface

uses
   
   SimpleScript.Core, SimpleScript.Exceptions, SimpleScript.Extenders.Basics, SimpleScript.Utils,
   Classes, Contnrs, SysUtils, Windows, StrUtils, Math;

const
	BREAK_STR: String = #1#1#1;
   PARAM_MARK: String = '#';

type

   TAdvancedExtender = class(TBasicExtenderBase)
   	public
         type
            TStringArr = array of String;

            TNamedValue = record
               Name: String;
               Value: String;
               Extra: TStringArr;
            end;

            TNamedValues = array of TNamedValue;
      strict private
      	FVars: TNamedValues;
         FFuncs: TNamedValues;
         FFilePath: String;
         FFuncSignature: TStringArr;
   	strict protected
      	function GetNamespace: String; override;
         procedure PublishExtensions; override;

         function IndexOfVar(Name: String): Integer;
         function GetVar(const Name: String; out Value: String): Boolean;
         procedure SetVar(const Name, Value: String);
         procedure ClearVars(const All: Boolean);

         function GetFunc(const Name: String; out Func: TNamedValue): Boolean;
         procedure SetFunc(const Name, Value: String; const Params: array of String);
         procedure ClearFuncs;

         function MakeFilePath(const BasePath, FileName: String): String;

         function GetFuncSignature(var Sig: TStringArr): String;
         procedure DecFuncSignature(var Sig: TStringArr);
         procedure IncFuncSignature(var Sig: TStringArr; const Name: String);
         procedure ClearFuncSignature(var Sig: TStringArr);

         //*** Vars ***//
         {FUNC: remove todas as variaveis declaradas; PARAMS: -; RESULT: -}
         function fn_ClearVars(Args: array of String): String;
         {FUNC: Seta ou retorna uma variavel; PARAMS: 1=nome, [2=valor]; RESULT: Valor ou nada}
         function fn_Var(Args: array of String): String;
         {FUNC: Incrementa uma variavel; PARAMS: 1=nome, [2=valor]; RESULT: -}
         function fn_VarPlus(Args: array of String): String;
         {FUNC: Decrementa uma variavel; PARAMS: 1=nome, [2=valor]; RESULT: -}
         function fn_VarMinus(Args: array of String): String;

         //*** Funcs ***//
         {FUNC: Remove todas as funções declaradas; PARAMS: -; RESULT: -}
         function fn_ClearFunctions(Args: array of String): String;
         {FUNC: ; PARAMS: ; RESULT: }
         function fn_Function(Args: array of String): String;
         {FUNC: ; PARAMS: ; RESULT: }
         function fn_Call(Args: array of String): String;

         //*** Comparações ***//
         {FUNC: Comparação de igual; PARAMS: 1=termo, 2=termo; RESULT: bool}
         function fn_Equals(Args: array of String): String;
         {FUNC: Comparação de não igualdade; PARAMS: 1=termo, 2=termo; RESULT: bool}
         function fn_NotEquals(Args: array of String): String;
         {FUNC: Comparação de maior que; PARAMS: 1=termo, 2=termo; RESULT: bool}
         function fn_GreaterThan(Args: array of String): String;
         {FUNC: Comparação de menor que; PARAMS: 1=termo, 2=termo; RESULT: bool}
         function fn_LessThan(Args: array of String): String;
         {FUNC: Comparação de maior igual que; PARAMS: 1=termo, 2=termo; RESULT: bool}
         function fn_GreaterThanEquals(Args: array of String): String;
         {FUNC: Comparação de menor ou igual que; PARAMS: 1=termo, 2=termo; RESULT: bool}
         function fn_LessThanEquals(Args: array of String): String;
         {FUNC: Inversão booleana; PARAMS: 1=bool; RESULT: bool}
         function fn_Not(Args: array of String): String;
         {}
			function fn_And(Args: array of String): String;
         {}
         function fn_Or(Args: array of String): String;
         {}
         function fn_SetFilePath(Args: array of String): String;
         {}
         function fn_GetFilePath(Args: array of String): String;
         {}
         function fn_Include(Args: array of String): String;

         //*** Condições ***//
         {FUNC: Condição SE;
         PARAMS: 1=condição que retorne bool, 2=valor bool esperado, 3=expressão a ser executada;
         RESULT: resultado da expressão;
         OBS: aceita um numero infinito de parametros para condição SE-NÃO, em cunjuntos de 3 parametros}
         function fn_If(Args: array of String): String;
         {FUNC: Condição tipo CASE;
         PARAMS: 1=expressao qualquer q retorna uma string, 2=valor esperado, 3=expressão a ser executada;
         RESULT: resultado da expressão;
         OBS: aceita um numero infinito de parametros na condição, em cunjuntos de 2 parametros apos o primeiro}
         function fn_Case(Args: array of String): String;

         //*** Iterações ***//
         {FUNC: retorna uma string especial para interromper iterações; PARAMS: -; RESULT: BREAK_STR}
         function fn_Break(Args: array of String): String;
         {FUNC: Executa uma expressão N vezes; PARAMS: 1=N, 2=expressão; RESULT: resultado da expressao}
      	function fn_Repeat(Args: array of String): String;
         {FUNC: Executa uma expressão p2 enquanto uma expressao p1 retornar true;
         PARAMS: 1=expressão de condição, 2=expressão de excução;
         RESULT: Resultado de p2}
         function fn_While(Args: array of String): String;
         {FUNC: Executa uma expressão p2 até que uma expressão p1 retorne true;
         PARAMS: 1=expressão de condição, 2=expressão de excução;
         RESULT: Resultado de p2}
         function fn_Until(Args: array of String): String;
         {}
         function fn_For(Args: array of String): String;

         //*** Misc ***//
         {FUNC: Retorna true ou o valor bool passado; PARAMS: [1=bool]; RESULT: bool}
         function fn_Default(Args: array of String): String;
         {FUNC: converte um valor para bool; PARAMS: 1=string; RESULT: bool}
         function fn_Bool(Args: array of String): String;
         {FUNC: retorna o parametro direto; PARAMS: 1=string; RESULT: string p1}
         function fn_Echo(Args: array of String): String;
         {}
         function fn_Try(Args: array of String): String;
         {}
         function fn_LastError(Args: array of String): String;
         {}
         function fn_Terminate(Args: array of String): String;
      public
         constructor Create(AOwner: TSimpleScriptContext); override;
         function Notify(const Msg: Integer): Integer; override;
   end;

implementation

{ TAdvancedExtender }

procedure TAdvancedExtender.IncFuncSignature(var Sig: TStringArr; const Name: String);
var
   len: Integer;
begin
   len := Length(Sig);
   SetLength(Sig, len + 1);
   Sig[len] := LowerCase(Name);
end;

procedure TAdvancedExtender.DecFuncSignature(var Sig: TStringArr);
var
   len: Integer;
begin
   len := Length(Sig);
   if len > 0 then
      SetLength(Sig, len - 1);
end;

procedure TAdvancedExtender.ClearFuncSignature(var Sig: TStringArr);
begin
   SetLength(Sig, 0);
end;

function TAdvancedExtender.GetFuncSignature(var Sig: TStringArr): String;
var
   I: Integer;
begin
   Result := '';
   
   for I := 0 to High(Sig) do
      Result := Result + Sig[I] + #2;

   if Result <> '' then
      SetLength(Result, Length(Result)-1);
end;

procedure TAdvancedExtender.ClearVars(const All: Boolean);
var
   newVars: TNamedValues;
   I, len: Integer;
begin
   if All then
	   SetLength(FVars, 0)
   else begin //apenas do escopo/assinatura
      len := 0;
      for I := 0 to High(FVars) do begin
         if GetFuncSignature(FVars[I].Extra) = GetFuncSignature(FFuncSignature) then continue;
         SetLength(newVars, len+1);
         newVars[len] := FVars[I];
         Inc(len);
      end;
      SetLength(FVars, Length(newVars));
      FVars := Copy(newVars, 0, Length(newVars));
   end;
end;

constructor TAdvancedExtender.Create(AOwner: TSimpleScriptContext);
begin
	inherited;
   Self.ClearVars(True);
end;

procedure TAdvancedExtender.ClearFuncs;
begin
	SetLength(FFuncs, 0);
end;

function TAdvancedExtender.fn_And(Args: array of String): String;
var
   expCode, output: String;
   expResult: Boolean;
   I: Integer;
begin
	Result := FALSE_STR;

	if Length(Args) < 2 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['And', 2]);
      exit;
   end;

   for I := 0 to Length(Args) - 1 do begin
      expCode := Trim(Args[I]);
      Self.Owner.ActiveParser.Parse(expCode, output, TFScriptParser.PA_NATIVE_CODE);
   	expResult := InternalStrToBool(output);
      if not expResult then
      	exit;
   end;

   Result := TRUE_STR;
end;

function TAdvancedExtender.fn_Or(Args: array of String): String;
var
   expCode, output: String;
   expResult: Boolean;
   I: Integer;
begin
	Result := FALSE_STR;

	if Length(Args) < 2 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Or', 2]);
      exit;
   end;

   for I := 0 to Length(Args) - 1 do begin
      expCode := Trim(Args[I]);
      Self.Owner.ActiveParser.Parse(expCode, output, TFScriptParser.PA_NATIVE_CODE);
   	expResult := InternalStrToBool(output);
      if expResult then begin
      	Result := TRUE_STR;
      	exit;
      end;
   end;
end;

function TAdvancedExtender.fn_Bool(Args: array of String): String;
begin
	if Length(Args) < 1 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Bool', 1]);
      exit;
   end;
	Result := InternalBoolToStr(InternalStrToBool(Args[0]));
end;

function TAdvancedExtender.fn_Break(Args: array of String): String;
begin
   Result := BREAK_STR;
end;

function TAdvancedExtender.fn_Call(Args: array of String): String;
var
	Func: TNamedValue;
   CallValue, ParamName, ParamValue: String;
   FuncParams: array of String;
   I: Integer;
begin
	if Length(Args) < 1 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Call', 1]);
      exit;
   end;

   if not Self.GetFunc(Args[0], Func) then
      Self.IssueExtensionError(SSEX_EXTENSION_UndeclaredFunction_COD, SSEX_EXTENSION_UndeclaredFunction, ['Call', Args[0]])
   else begin
      CallValue := Func.Value;
      
      if Length(Args) > 1 then begin
         SetLength(FuncParams, Length(Args)-1);
         for I := 1 to High(Args) do
            FuncParams[I-1] := Args[I];

         if Length(FuncParams) < Length(Func.Extra) then begin
            Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Call', Length(Func.Extra)+1]);
            exit;
         end;

         for I := Low(Func.Extra) to High(Func.Extra) do begin
            ParamName := PARAM_MARK + Func.Extra[I];
            ParamValue := TFScriptParser.BPSC_OPEN_LIT + FuncParams[I] + TFScriptParser.BPSC_CLOSE_LIT;
            CallValue := StringReplace(CallValue, ParamName, ParamValue, [rfReplaceAll, rfIgnoreCase]);
         end;

      end;

      Self.IncFuncSignature(FFuncSignature, Args[0]);

      Self.Owner.ActiveParser.Parse(CallValue, Result, TFScriptParser.PA_NATIVE_CODE);
      
      Self.ClearVars(False);
      Self.DecFuncSignature(FFuncSignature);
   end;
end;

function TAdvancedExtender.fn_ClearFunctions(Args: array of String): String;
begin
	Self.ClearFuncs;
end;

function TAdvancedExtender.fn_ClearVars(Args: array of String): String;
begin
   Self.ClearVars(True);
end;

function TAdvancedExtender.fn_Default(Args: array of String): String;
begin
   if Length(Args) > 0 then
      Result := InternalBoolToStr(InternalStrToBool(Args[0]))
   else
      Result := InternalBoolToStr(True);
end;

function TAdvancedExtender.fn_Echo(Args: array of String): String;
begin
	if Length(Args) < 1 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Echo', 1]);
      exit;
   end;
	Result := Args[0];
end;

function TAdvancedExtender.fn_Equals(Args: array of String): String;
var
	bResult: Boolean;
   op1, op2: Extended;
begin
	if Length(Args) < 2 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['=', 2]);
      exit;
   end;

   bResult := (Args[0] = Args[1]);
   if (not bResult) then begin //testar numerico
      op1 := InternalStrToFloat(Args[0]);
      op2 := InternalStrToFloat(Args[1]);
      bResult := ( (not IsNAN(op1)) and (not IsNAN(op2)) and (op1 = op2) );
   end;

   Result := InternalBoolToStr(bResult);
end;

function TAdvancedExtender.fn_Function(Args: array of String): String;
var
   PArr: array of String;
   I: Integer;
begin
	Result := '';
	if Length(Args) < 2 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Function', 2]);
      exit;
   end;

   if Length(Args) >= 3 then begin
      SetLength(PArr, Length(Args)-2);
      for I := 2 to High(Args) do begin
         PArr[I-2] := Args[I];
      end;
   end;

   Self.SetFunc(Args[0], Args[1], PArr);
end;

function TAdvancedExtender.fn_GetFilePath(Args: array of String): String;
begin
   Result := FFilePath;
end;

function TAdvancedExtender.fn_GreaterThan(Args: array of String): String;
var
	op1, op2: Extended;
begin
	if Length(Args) < 2 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['>', 2]);
      exit;
   end;

   op1 := InternalStrToFloat(Args[0]);
	if IsNan(op1) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[0], '>']);
      exit;
   end;

   op2 := InternalStrToFloat(Args[1]);
	if IsNan(op2) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[1], '>']);
      exit;
   end;

   Result := InternalBoolToStr((op1 > op2));
end;

function TAdvancedExtender.fn_GreaterThanEquals(Args: array of String): String;
var
	op1, op2: Extended;
begin
	if Length(Args) < 2 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['>=', 2]);
      exit;
   end;

   op1 := InternalStrToFloat(Args[0]);
	if IsNan(op1) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[0], '>=']);
      exit;
   end;

   op2 := InternalStrToFloat(Args[1]);
	if IsNan(op2) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[1], '>=']);
      exit;
   end;

   Result := InternalBoolToStr((op1 >= op2));
end;

function TAdvancedExtender.fn_LastError(Args: array of String): String;
var
   lastError: TSimpleScriptContextError;
   found: Boolean;
   I: Integer;
   info: String;
begin
   Result := '';
   
   info := '';
   if Length(Args) > 0 then
      info := LowerCase(Args[0]);

   found := False;
   for I := Self.Owner.Errors.Count - 1 downto 0 do begin
      if Self.Owner.Errors.Items[I].Kind <> ekError then continue;
      lastError := Self.Owner.Errors.Items[I];
      found := True;
      break;
   end;

   if found then begin
      if info = 'descr' then
         Result := lastError.Description
      else if info = 'file' then
         Result := lastError.FileName
      else
         Result := UpperCase(lastError.Code);
   end;
end;

function TAdvancedExtender.fn_LessThan(Args: array of String): String;
var
	op1, op2: Extended;
begin
	if Length(Args) < 2 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['<', 2]);
      exit;
   end;

   op1 := InternalStrToFloat(Args[0]);
	if IsNan(op1) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[0], '<']);
      exit;
   end;

   op2 := InternalStrToFloat(Args[1]);
	if IsNan(op2) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[1], '<']);
      exit;
   end;

   Result := InternalBoolToStr((op1 < op2));
end;

function TAdvancedExtender.fn_LessThanEquals(Args: array of String): String;
var
	op1, op2: Extended;
begin
	if Length(Args) < 2 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['<=', 2]);
      exit;
   end;

   op1 := InternalStrToFloat(Args[0]);
	if IsNan(op1) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[0], '<=']);
      exit;
   end;

   op2 := InternalStrToFloat(Args[1]);
	if IsNan(op2) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[1], '<=']);
      exit;
   end;

   Result := InternalBoolToStr((op1 <= op2));
end;

function TAdvancedExtender.fn_Not(Args: array of String): String;
begin
	if Length(Args) < 1 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Not', 1]);
      exit;
   end;
	Result := InternalBoolToStr(not InternalStrToBool(Args[0]));
end;

function TAdvancedExtender.fn_NotEquals(Args: array of String): String;
var
	bResult: Boolean;
   op1, op2: Extended;
begin
	if Length(Args) < 2 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['!=', 2]);
      exit;
   end;

   bResult := (Args[0] <> Args[1]);
   if (not bResult) then begin //testar numerico
      op1 := InternalStrToFloat(Args[0]);
      op2 := InternalStrToFloat(Args[1]);
      bResult := ( (not IsNAN(op1)) and (not IsNAN(op2)) and (op1 <> op2) );
   end;

   Result := InternalBoolToStr(bResult);
end;

function TAdvancedExtender.fn_Case(Args: array of String): String;
var
	argsLen, needsLen, setsLen, I: Integer;
   conditionExpression, matchResult, matchCodeExp: String;
   match: Boolean;
   conditionExpressionNum, matResNum: Extended;
begin
   Result := '';
   argsLen := Length(Args);
   setsLen := argsLen-1;
   if (argsLen = 0) or (setsLen <= 0) or ((setsLen mod 2) <> 0) then begin
		needsLen := setsLen + (2 - (setsLen mod 2)) + 1;
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Case', needsLen]);
      exit;
   end;

   conditionExpression := Args[0];
   conditionExpressionNum := InternalStrToFloat(conditionExpression);

   I := 1;
   while I < argsLen do begin
   	matchResult := Args[I];
      matchCodeExp := Args[I+1];

      match := (conditionExpression = matchResult) or (LowerCase(matchResult) = LowerCase(TRUE_STR));
      if (not match) and (not IsNAN(conditionExpressionNum)) then begin //testar numerico
      	matResNum := InternalStrToFloat(matchResult);
         match := ((not IsNAN(matResNum)) and (conditionExpressionNum = matResNum));
      end;

      if match then begin
      	Self.Owner.ActiveParser.Parse(matchCodeExp, Result, TFScriptParser.PA_NATIVE_CODE);
         break;
      end;

      Inc(I, 2);
   end;
end;

function TAdvancedExtender.fn_If(Args: array of String): String;
var
	conditionExpression, codeExpression, output: String;
	conditionResult, desiredResult: Boolean;
   argsLen, needsLen, I: Integer;
begin
	Result := '';
	argsLen := Length(Args);
   if (argsLen = 0) or ((argsLen mod 3) <> 0) then begin
      needsLen := argsLen + (3 - (argsLen mod 3));
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['If', needsLen]);
      exit;
   end;

   I := 0;
   while I < argsLen do begin
   	conditionExpression := Args[I];
      desiredResult := InternalStrToBool(Args[I+1]);
      codeExpression := Args[I+2];

      Self.Owner.ActiveParser.Parse(conditionExpression, output, TFScriptParser.PA_NATIVE_CODE);
   	conditionResult := InternalStrToBool(output);

      if conditionResult = desiredResult then begin
      	Self.Owner.ActiveParser.Parse(codeExpression, Result, TFScriptParser.PA_NATIVE_CODE);
         break;
      end;

      Inc(I, 3);
   end;
end;

function TAdvancedExtender.fn_Include(Args: array of String): String;
var
   fileName, filePath, fileContent: String;
   fileSize, retFileSize: Int64;
   fileStream: TFileStream;
   oldFileName: String;
   //oldLine, oldColumn: Integer;
begin
   Result := '';
   if (Self.Owner.Status = csTerminating) then exit;
   
   if Length(Args) < 1 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Include', 1]);
      exit;
   end;

   fileName := Trim(Args[0]);
   filePath := Self.MakeFilePath(FFilePath, fileName);

   if not FileExists(filePath) then begin
      Self.IssueExtensionError(SSEX_EXTENSION_FileNotFound_COD, SSEX_EXTENSION_FileNotFound, ['Include', filePath]);
      exit;
   end;

   oldFileName := Self.Owner.ActiveParser.CurrentFile;
   {oldLine := Self.Owner.ActiveParser.CurrentLine;
   oldColumn := Self.Owner.ActiveParser.CurrentColumn;}

   Self.Owner.ActiveParser.CurrentFile := fileName;
   fileStream := nil;
   try
      try
         fileStream := TFileStream.Create(filePath, fmOpenRead or fmShareDenyNone);
         fileStream.Position := 0;
         fileSize := fileStream.Size;

         if fileSize > 0 then begin
            SetLength(fileContent, fileSize);
            retFileSize := fileStream.Read(Pointer(fileContent)^, fileSize);
         
            if retFileSize < fileSize then
               SetLength(fileContent, retFileSize);

            if Assigned(fileStream) then
               FreeAndNil(fileStream);

            Self.Owner.ActiveParser.Parse(fileContent, Result, PA_ROOT_PARSE);
         end;
      except
         on E: Exception do begin
            Self.IssueExtensionError(SSEX_EXTENSION_FileError_COD, SSEX_EXTENSION_FileError, ['Include', E.Message]);
         end;
      end;
   finally
      Self.Owner.ActiveParser.CurrentFile := oldFileName;
      {Self.Owner.ActiveParser.CurrentLine := oldLine;
      Self.Owner.ActiveParser.CurrentColumn := oldColumn;}

      if Assigned(fileStream) then
         fileStream.Free;
   end;
end;

function TAdvancedExtender.fn_Repeat(Args: array of String): String;
var
	num: Integer;
   code, output: String;
   R: Integer;
begin
	if Length(Args) < 2 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Repeat', 2]);
      exit;
   end;

	if not TryStrToInt(Args[0], num) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidInteger_COD, SSEX_EXTENSION_InvalidInteger, [Args[0], 'Repeat']);
      exit;
   end;

   code := Trim(Args[1]);
   for R := 1 to num do begin
      if (Self.Owner.Status = csTerminating) then break;

   	Self.Owner.ActiveParser.Parse(code, output, TFScriptParser.PA_NATIVE_CODE);
      Result := Result + output;
      if Pos(BREAK_STR, output) > 0 then begin
      	Result := StringReplace(Result, BREAK_STR, '', [rfReplaceAll, rfIgnoreCase]);
         break;
      end;
   end;
end;

function TAdvancedExtender.fn_SetFilePath(Args: array of String): String;
begin
   Result := '';
   if Length(Args) < 1 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['SetFilePath', 1]);
      exit;
   end;

   FFilePath := Trim(Args[0]);
end;

function TAdvancedExtender.fn_Terminate(Args: array of String): String;
begin
   Result := '';
   if Length(Args) > 0 then Result := Args[0];
   
   Self.Owner.StopParse;
end;

function TAdvancedExtender.fn_Try(Args: array of String): String;
var
   lastErrorCount: Integer;
   tryBlock, exceptBlock, tryResult, exceptResult: String;
begin
   Result := '';
   if Length(Args) < 2 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Try', 2]);
      exit;
   end;
   
   lastErrorCount := Self.Owner.Errors.CountError;
   tryBlock := Args[0];
   exceptBlock := Args[1];
   tryResult := '';
   exceptResult := '';

   Self.Owner.ActiveParser.Parse(tryBlock, tryResult, TFScriptParser.PA_NATIVE_CODE);
   Result := Result + tryResult;
   
   if Self.Owner.Errors.CountError <> lastErrorCount then begin
      Self.Owner.ActiveParser.Parse(exceptBlock, exceptResult, TFScriptParser.PA_NATIVE_CODE);
      Result := Result + exceptResult;
   end;
end;

function TAdvancedExtender.fn_While(Args: array of String): String;
var
	output, code, condition: String;
   condResult: Boolean;
begin
	if Length(Args) < 2 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['While', 2]);
      exit;
   end;

   condition := Trim(Args[0]);
   code := Trim(Args[1]);

   Self.Owner.ActiveParser.Parse(condition, output, TFScriptParser.PA_NATIVE_CODE);
   condResult := InternalStrToBool(output);

   while condResult do begin
   	if (Self.Owner.Status = csTerminating) then break;

   	Self.Owner.ActiveParser.Parse(code, output, TFScriptParser.PA_NATIVE_CODE);
   	Result := Result + output;
      if Pos(BREAK_STR, output) > 0 then begin
      	Result := StringReplace(Result, BREAK_STR, '', [rfReplaceAll, rfIgnoreCase]);
         break;
      end;

      Self.Owner.ActiveParser.Parse(condition, output, TFScriptParser.PA_NATIVE_CODE);
   	condResult := InternalStrToBool(output);
   end;
end;

function TAdvancedExtender.fn_Until(Args: array of String): String;
var
	output, code, condition: String;
   condResult: Boolean;
begin
	if Length(Args) < 2 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Until', 2]);
      exit;
   end;

   condition := Trim(Args[0]);
   code := Trim(Args[1]);
   condResult := False;

   while not condResult do begin
   	if (Self.Owner.Status = csTerminating) then break;

   	Self.Owner.ActiveParser.Parse(code, output, TFScriptParser.PA_NATIVE_CODE);
   	Result := Result + output;
      if Pos(BREAK_STR, output) > 0 then begin
      	Result := StringReplace(Result, BREAK_STR, '', [rfReplaceAll, rfIgnoreCase]);
         break;
      end;

      Self.Owner.ActiveParser.Parse(condition, output, TFScriptParser.PA_NATIVE_CODE);
   	condResult := InternalStrToBool(output);
   end;
end;

function TAdvancedExtender.fn_For(Args: array of String): String;
var
   initExp, incExp, condExp, codeExp, output: String;
   condExpResult: Boolean;
begin
	if Length(Args) < 4 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['For', 4]);
      exit;
   end;

   initExp := Trim(Args[0]);
   condExp := Trim(Args[1]);
   incExp := Trim(Args[2]);
   codeExp := Trim(Args[3]);

   Self.Owner.ActiveParser.Parse(initExp, output, TFScriptParser.PA_NATIVE_CODE);

   Self.Owner.ActiveParser.Parse(condExp, output, TFScriptParser.PA_NATIVE_CODE);
   condExpResult := InternalStrToBool(output);

   while condExpResult do begin
   	if (Self.Owner.Status = csTerminating) then break;

   	Self.Owner.ActiveParser.Parse(codeExp, output, TFScriptParser.PA_NATIVE_CODE);
   	Result := Result + output;
      if Pos(BREAK_STR, output) > 0 then begin
      	Result := StringReplace(Result, BREAK_STR, '', [rfReplaceAll, rfIgnoreCase]);
         break;
      end;

      Self.Owner.ActiveParser.Parse(incExp, output, TFScriptParser.PA_NATIVE_CODE);

      Self.Owner.ActiveParser.Parse(condExp, output, TFScriptParser.PA_NATIVE_CODE);
   	condExpResult := InternalStrToBool(output);
   end;
end;

function TAdvancedExtender.fn_Var(Args: array of String): String;
begin
	if Length(Args) < 1 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['Var', 1]);
      exit;
   end;

   if Length(Args) > 1 then
   	Self.SetVar(Args[0], Args[1])
   else begin
   	if not Self.GetVar(Args[0], Result) then
      Self.IssueExtensionError(SSEX_EXTENSION_UndeclaredVariable_COD, SSEX_EXTENSION_UndeclaredVariable, [Args[0]], ekWarning);
   end;
end;

function TAdvancedExtender.fn_VarMinus(Args: array of String): String;
var
	strVarValue: String;
   extVarValue, decrement: Extended;
begin
	if Length(Args) < 1 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['--', 1]);
      exit;
   end;

  	decrement := 1;
   if (Length(Args) > 1) then
		decrement := InternalStrToFloat(Args[1]);

   if IsNAN(decrement) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[1], '--']);
      exit;
   end;

   Self.GetVar(Args[0], strVarValue);
   extVarValue := InternalStrToFloat(strVarValue);

   if IsNAN(extVarValue) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_VariableNotNumeric_COD, SSEX_EXTENSION_VariableNotNumeric, ['--', Args[0]]);
      exit;
   end;

   Self.SetVar(Args[0], InternalFloatToStr(extVarValue - decrement));
end;

function TAdvancedExtender.fn_VarPlus(Args: array of String): String;
var
	strVarValue: String;
   extVarValue, increment: Extended;
begin
	if Length(Args) < 1 then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InsuficientParams_COD, SSEX_EXTENSION_InsuficientParams, ['++', 1]);
      exit;
   end;

  	increment := 1;
   if (Length(Args) > 1) then
		increment := InternalStrToFloat(Args[1]);

   if IsNAN(increment) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_InvalidDecimal_COD, SSEX_EXTENSION_InvalidDecimal, [Args[1], '++']);
      exit;
   end;

   Self.GetVar(Args[0], strVarValue);
   extVarValue := InternalStrToFloat(strVarValue);

   if IsNAN(extVarValue) then begin
   	Self.IssueExtensionError(SSEX_EXTENSION_VariableNotNumeric_COD, SSEX_EXTENSION_VariableNotNumeric, ['++', Args[0]]);
      exit;
   end;

   Self.SetVar(Args[0], InternalFloatToStr(extVarValue + increment));
end;

function TAdvancedExtender.GetNamespace: String;
begin
	Result := 'Base';
end;

function TAdvancedExtender.Notify(const Msg: Integer): Integer;
begin
   Result := inherited Notify(Msg);
   if (Msg = NMSG_PARSE_START) or (Msg = NMSG_PARSE_FINISH) then begin
   	Self.ClearVars(True);
      Self.ClearFuncs;
   end;
end;

function TAdvancedExtender.GetFunc(const Name: String; out Func: TNamedValue): Boolean;
var
	I: Integer;
begin
	//Value := '';
	Result := True;
	for I := 0 to Length(FFuncs) - 1 do begin
      if LowerCase(FFuncs[I].Name) = LowerCase(Name) then begin
         Func := FFuncs[I];
         exit;
      end;
   end;
   Result := False;
end;

procedure TAdvancedExtender.SetFunc(const Name, Value: String; const Params: array of String);
var
	I, F, FuncLen: Integer;
begin
	FuncLen := Length(FFuncs);
	F := -1;
	for I := 0 to FuncLen - 1 do begin
      if LowerCase(FFuncs[I].Name) = LowerCase(Name) then begin
         F := I;
         break;
      end;
   end;

   if F < 0 then begin
      SetLength(FFuncs, FuncLen + 1);
      F := FuncLen;
   end;

   FFuncs[F].Name := Name;
   FFuncs[F].Value := Value;

   SetLength(FFuncs[F].Extra, Length(Params));
   for I := Low(Params) to High(Params) do
      FFuncs[F].Extra[I] := Params[I];
end;

function TAdvancedExtender.GetVar(const Name: String; out Value: String): Boolean;
var
	I: Integer;
begin
	Value := '0';
   
   I := IndexOfVar(Name);
   Result := (I >= 0);
   if Result then
      Value := FVars[I].Value;
   
	{Result := True;
	for I := 0 to Length(FVars) - 1 do begin
      if FVars[I].Name = LowerCase(Name) then begin
         Value := FVars[I].Value;
         exit;
      end;
   end;
   Result := False;}
end;

function TAdvancedExtender.IndexOfVar(Name: String): Integer;
var
   I: Integer;
   CSig: TStringArr;
   lcName: String;
   sigCount: Integer;
begin
   Result := -1;
   if Length(FVars) = 0 then exit;

   SetLength(CSig, Length(FFuncSignature));
   sigCount := Length(CSig);
   if Length(FFuncSignature) > 0 then CSig := Copy(FFuncSignature, 0, Length(CSig));

   lcName := LowerCase(Name);
   repeat
   
      for I := 0 to Length(FVars) - 1 do begin
         if (FVars[I].Name = lcName) and (GetFuncSignature(FVars[I].Extra) = GetFuncSignature(CSig)) then begin
            Result := I;
            exit;
         end;
      end;
      DecFuncSignature(CSig);
      Dec(sigCount);

   until sigCount < 0;
end;

function TAdvancedExtender.MakeFilePath(const BasePath, FileName: String): String;
var
   fName, fPath, lvStr: String;
   upLevels, I, C: Integer;
   CR: Char;
begin
   fName := StringReplace(FileName, '/', '\', [rfReplaceAll]);
   if Pos(':', fName) > 0 then begin
      Result := fName;
      exit;
   end;

   fPath := StringReplace(BasePath, '/', '\', [rfReplaceAll]);
   while fPath[Length(fPath)] = '\' do
      SetLength(fPath, Length(fPath)-1);

   lvStr := '';
   upLevels := 0;
   C := 0;
   for I := 1 to Length(fName) do begin
      lvStr := lvStr + fName[I];
      if ContainsText(lvStr, '..\') then begin
         C := C + Length(lvStr);
         Inc(upLevels);
         lvStr := '';
      end;
   end;
   
   fName := RightStr(fName, Length(fName) - C);
   
   for I := (Length(fPath)) downto 1 do begin
      CR := fPath[I];
      if (CR = '\') then
         Dec(upLevels);
      if upLevels <= 0 then
         break;
   end;

   fPath := LeftStr(fPath, I);

   Result := fPath + '\' + fName;

   while Pos('\\', Result) > 0 do
      Result := StringReplace(Result, '\\', '\', [rfReplaceAll]);
end;

procedure TAdvancedExtender.SetVar(const Name, Value: String);
var
	I, len: Integer;
begin
	{VarLen := Length(FVars);
	V := -1;
	for I := 0 to VarLen - 1 do begin
      if FVars[I].Name = LowerCase(Name) then begin
         V := I;
         break;
      end;
   end;}

   I := IndexOfVar(Name);
   if I >= 0 then //já existe
      FVars[I].Value := Value
   else begin //não existe
      len := Length(FVars);
		SetLength(FVars, len + 1);
      FVars[len].Name := LowerCase(Name);
      FVars[len].Value := Value;
      FVars[len].Extra := Copy(FFuncSignature, 0, Length(FFuncSignature));
   end;
end;

procedure TAdvancedExtender.PublishExtensions;
begin
   with Self.Extensions do begin
      Add(TStringArgsFunction.Create(Self, 'ClearVars', Self.fn_ClearVars));
      Add(TStringArgsFunction.Create(Self, 'Var', Self.fn_Var));
      Add(TStringArgsFunction.Create(Self, '++', Self.fn_VarPlus));
      Add(TStringArgsFunction.Create(Self, '--', Self.fn_VarMinus));

      Add(TStringArgsFunction.Create(Self, 'ClearFunctions', Self.fn_ClearFunctions));
      Add(TStringArgsFunction.Create(Self, 'Function', Self.fn_Function));
      Add(TStringArgsFunction.Create(Self, 'Call', Self.fn_Call));

      Add(TStringArgsFunction.Create(Self, '=', Self.fn_Equals));
      Add(TStringArgsFunction.Create(Self, '!=', Self.fn_NotEquals));
      Add(TStringArgsFunction.Create(Self, '>', Self.fn_GreaterThan));
      Add(TStringArgsFunction.Create(Self, '<', Self.fn_LessThan));
      Add(TStringArgsFunction.Create(Self, '>=', Self.fn_GreaterThanEquals));
      Add(TStringArgsFunction.Create(Self, '<=', Self.fn_LessThanEquals));
      Add(TStringArgsFunction.Create(Self, 'Not', Self.fn_Not));
      Add(TStringArgsFunction.Create(Self, '!', Self.fn_Not));
      Add(TStringArgsFunction.Create(Self, 'And', Self.fn_And));
      Add(TStringArgsFunction.Create(Self, 'Or', Self.fn_Or));

      Add(TStringArgsFunction.Create(Self, 'If', Self.fn_If));
      Add(TStringArgsFunction.Create(Self, 'Case', Self.fn_Case));

      Add(TStringArgsFunction.Create(Self, 'Break', Self.fn_Break));
      Add(TStringArgsFunction.Create(Self, 'Repeat', Self.fn_Repeat));
      Add(TStringArgsFunction.Create(Self, 'While', Self.fn_While));
      Add(TStringArgsFunction.Create(Self, 'Until', Self.fn_Until));
      Add(TStringArgsFunction.Create(Self, 'For', Self.fn_For));

      Add(TStringArgsFunction.Create(Self, 'Default', Self.fn_Default));
      Add(TStringArgsFunction.Create(Self, 'Bool', Self.fn_Bool));
      Add(TStringArgsFunction.Create(Self, 'Echo', Self.fn_Echo));

      Add(TStringArgsFunction.Create(Self, 'SetFilePath', Self.fn_SetFilePath));
      Add(TStringArgsFunction.Create(Self, 'GetFilePath', Self.fn_GetFilePath));
      Add(TStringArgsFunction.Create(Self, 'Include', Self.fn_Include));

      Add(TStringArgsFunction.Create(Self, 'Try', Self.fn_Try));
      Add(TStringArgsFunction.Create(Self, 'LastError', Self.fn_LastError));
      Add(TStringArgsFunction.Create(Self, 'Terminate', Self.fn_Terminate));
   end;
end;

initialization

	with SimpleScript.Core.Main do begin
   	AddDefaultContextExtenderClass(TAdvancedExtender);
   end;

finalization

end.
