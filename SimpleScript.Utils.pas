unit SimpleScript.Utils;

interface

uses
	SysUtils, Windows, Math;

const
   TRUE_STR: String = 'true';
   FALSE_STR: String = 'false';

type

	{Classe responsável por divir uma string em partes de acordo com substrings que servem de marcas (tags)}
   TTagStringBroker = class(TObject)
   	public
      	type
         	{Tipo de divisão efetuada, tmInnerString divide com base em strings que estão ou não delimitas por tags
            já tmSingleBreak divide a string quebrando-a em todas as tags de abertura}
         	TTagMode = (tmInnerString, tmSingleBreak);
            {Indica se a substring que já foi dividida estava delimitada por tags (ptTagString)
            ou não (ptLiteralString)}
            TTagStringPartType = (ptLiteralString, ptTagString);

            {Registro de uma substring}
            TTagStringPart = record
            	{Substring}
               Str: String;
               {Tipo}
               Typ: TTagStringPartType;
            end;

            {Array de partes de string (substrings) divididas}
            TTagStringParts = array of TTagStringPart;
      strict private
         FOpenTag: String;
         FCloseTag: String;
         FOpenLiteralMark: String;
         FCloseLiteralMark: String;
         FTagMode: TTagMode;
         FUseLiteralMarks: Boolean;
    		FBrokenStrings: TTagStringParts;
    		FInputString: String;
         FCaseSensitive: Boolean;

         function CompareStrToTag(const Str, Tag: String): Boolean;
      public
      	constructor Create;
      	destructor Destroy; override;
         {Tag de abertura}
         property OpenTag: String read FOpenTag write FOpenTag;
         {Tag de fechamento}
         property CloseTag: String read FCloseTag write FCloseTag;
         {Marca de abertura de um trecho literal}
         property OpenLiteralMark: String read FOpenLiteralMark write FOpenLiteralMark;
         {Marca de fechamento de um trecho literal}
         property CloseLiteralMark: String read FCloseLiteralMark write FCloseLiteralMark;
         {Modo de quebra ou divisão}
         property TagMode: TTagMode read FTagMode write FTagMode;
         {Usar ou não as marcas de literais}
         property UseLiteralMarks: Boolean read FUseLiteralMarks write FUseLiteralMarks;
         {String de entrada que contem o texto marcado}
         property InputString: String read FInputString write FInputString;
         {Substrings divididas/quebradas}
         property BrokenStrings: TTagStringParts read FBrokenStrings;
         {Indica se as tags/marcas devem corresponder também em maiúsculas e minúsculas}
         property CaseSensitive: Boolean read FCaseSensitive write FCaseSensitive;
         {Inicia o processo de quebra}
         procedure Break;
         {Reseta/limpa os mebros da classe}
         procedure Reset;
   end;

   {Retorna o número de vezes que um caracter ocorre em uma String}
   function StringCount(const Str: String; const Search: Char): Integer;
   {}
   function InternalStrToFloat(const Value: String): Extended;
   {}
   function InternalFloatToStr(const Value: Extended): String;
   {}
   function InternalBoolToStr(const Value: Boolean): String;
   {}
   function InternalStrToBool(const Value: String): Boolean;

var

   FixedFormatSettings: TFormatSettings;

implementation

function StringCount(const Str: String; const Search: Char): Integer;
var
	I: Integer;
begin
	Result := 0;
	for I := 1 to Length(Str) do
		if Str[I] = Search then Inc(Result);
end;

function InternalFloatToStr(const Value: Extended): String;
var
	fmt: TFormatSettings;
	I, D: Integer;
begin
	{GetLocaleFormatSettings(1033, fmt);
	fmt.ThousandSeparator := ',';
	fmt.DecimalSeparator := '.';}
   fmt := FixedFormatSettings;

	Result := FloatToStrF(Value, ffFixed, 15, 7, fmt);

	D := 0;
	for I := Length(Result) downto 1 do begin
		if Result[I] = '0' then
			Inc(D)
		else
		break;
	end;
	SetLength(Result, Length(Result)-D);
	if Pos('.', Result) = Length(Result) then
		SetLength(Result, Length(Result)-1);
end;

function InternalStrToFloat(const Value: String): Extended;
var
    fmt: TFormatSettings;
begin
    //GetLocaleFormatSettings(1033, fmt);
    fmt := FixedFormatSettings;

    if (StringCount(Value, ',') > 1) or (StringCount(Value, '.') = 1) then begin
        fmt.ThousandSeparator := ',';
        fmt.DecimalSeparator := '.';
    end
    else if (StringCount(Value, '.') > 1) or (StringCount(Value, ',') = 1) then begin
        fmt.ThousandSeparator := '.';
        fmt.DecimalSeparator := ',';
    end;

    Result := StrToFloatDef(Value, +NAN, fmt);
end;

function InternalBoolToStr(const Value: Boolean): String;
begin
	Result := FALSE_STR;
   if Value then
      Result := TRUE_STR;
end;

function InternalStrToBool(const Value: String): Boolean;
var
	notTry, tryOut: Boolean;
begin
	Result := False;

	notTry := False;
	if LowerCase(Value) = LowerCase(TRUE_STR) then begin
   	Result := True;
      notTry := True;
   end
   else if LowerCase(Value) = LowerCase(FALSE_STR) then begin
      Result := False;
      notTry := True;
   end;

   if not notTry then begin
   	if TryStrToBool(Value, tryOut) then
      	Result := tryOut;
   end;
end;

{ TTagStringBroker }

procedure TTagStringBroker.Break;
var
   I, stringsLen, inputLen: Integer;
   C: Char;
   TagFlag, LitFlag: Boolean;

   openTagLen, closeTagLen: Integer;
   openLitLen, closeLitLen: Integer;

   openTagMatch, closeTagMatch: Boolean;
   openLitMatch, closeLitMatch: Boolean;

   procedure IncBrokenStrings;
   begin
      stringsLen := stringsLen + 1;
      SetLength(FBrokenStrings, stringsLen);
      FBrokenStrings[stringsLen-1].Str := '';
   end;

begin
	stringsLen := 1;
	SetLength(FBrokenStrings, stringsLen);
   FBrokenStrings[stringsLen-1].Typ := ptLiteralString;

   inputLen := Length(FInputString);

   openTagLen := Length(FOpenTag);
   closeTagLen := Length(FCloseTag);
   openLitLen := Length(FOpenLiteralMark);
   closeLitLen := Length(FCloseLiteralMark);

   TagFlag := False;
   LitFlag := False;

   I := 1;
   while I <= inputLen do begin
   	openTagMatch := CompareStrToTag(Copy(FInputString, I, openTagLen), FOpenTag);
      closeTagMatch := CompareStrToTag(Copy(FInputString, I, closeTagLen), FCloseTag);

      openLitMatch := CompareStrToTag(Copy(FInputString, I, openLitLen), FOpenLiteralMark);
      closeLitMatch := CompareStrToTag(Copy(FInputString, I, closeLitLen), FCloseLiteralMark);

      if LitFlag and closeLitMatch and UseLiteralMarks then
      	LitFlag := False
      else if (not LitFlag) and openLitMatch and UseLiteralMarks then
         LitFlag := True;


      C := FInputString[I];

      if (not TagFlag) and openTagMatch and (not LitFlag) and (Self.TagMode = tmInnerString) then begin
         TagFlag := True;
         if I > 1 then IncBrokenStrings;
         Inc(I, (openTagLen-1));

         FBrokenStrings[stringsLen-1].Typ := ptTagString;
      end
      else if TagFlag and closeTagMatch and (not LitFlag) and (Self.TagMode = tmInnerString) then begin
         TagFlag := False;
         Inc(I, (closeTagLen-1));

         IncBrokenStrings;
         FBrokenStrings[stringsLen-1].Typ := ptLiteralString;
      end
      else if openTagMatch and (not LitFlag) and (Self.TagMode = tmSingleBreak) then begin
         Inc(I, (openTagLen-1));

         IncBrokenStrings;
         FBrokenStrings[stringsLen-1].Typ := ptLiteralString;
      end
      else begin
         FBrokenStrings[stringsLen-1].Str := FBrokenStrings[stringsLen-1].Str + C;
      end;

      Inc(I);
   end;
end;

function TTagStringBroker.CompareStrToTag(const Str, Tag: String): Boolean;
begin
   Result := (
      ((Str = Tag) and CaseSensitive) or
      ((LowerCase(Str) = LowerCase(Tag)) and not CaseSensitive)
   );
end;

constructor TTagStringBroker.Create;
begin
	Self.Reset;
end;

destructor TTagStringBroker.Destroy;
begin
	Self.Reset;
	inherited;
end;

procedure TTagStringBroker.Reset;
begin
   SetLength(FBrokenStrings, 0);
   FOpenTag := '';
   FCloseTag := '';
   FOpenLiteralMark := '';
   FCloseLiteralMark := '';
   {$IFDEF VER210}
   FTagMode := TTagMode.tmInnerString;
   {$ELSE}
   FTagMode := tmInnerString;
   {$ENDIF}
   FUseLiteralMarks := False;
   FInputString := '';
   FCaseSensitive := False;
end;

initialization
   GetLocaleFormatSettings(1033, FixedFormatSettings);
   FixedFormatSettings.DecimalSeparator := '.';
   FixedFormatSettings.ThousandSeparator := ',';

finalization

end.
