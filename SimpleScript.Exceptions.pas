unit SimpleScript.Exceptions;

interface

uses
	SysUtils;

const
   SSEX_GENERIC_Unhandled_COD: String = 'GN-0001';
   SSEX_GENERIC_StackOverflowTermination_COD: String = 'GN-0002';
   SSEX_GENERIC_TooManyErros_COD: String = 'GN-0003';

   SSEX_EXTENSION_FunctionNotExists_COD: String = 'EN-0001';
   SSEX_EXTENSION_InsuficientParams_COD: String = 'EN-0002';
   SSEX_EXTENSION_InvalidInteger_COD: String = 'EN-0003';
   SSEX_EXTENSION_FunctionDeprecated_COD: String = 'EN-0004';
   SSEX_EXTENSION_EmptyString_COD: String = 'EN-0005';
   SSEX_EXTENSION_InvalidDecimal_COD: String = 'EN-0006';
   SSEX_EXTENSION_InvalidDate_COD: String = 'EN-0007';
   SSEX_EXTENSION_UndeclaredVariable_COD: String = 'EN-0008';
   SSEX_EXTENSION_VariableNotNumeric_COD: String = 'EN-0009';
   SSEX_EXTENSION_UndeclaredFunction_COD: String = 'EN-0010';
   SSEX_EXTENSION_ConstantNotExists_COD: String = 'EN-0011';
   SSEX_EXTENSION_InvalidByte_COD: String = 'EN-0012';
   SSEX_EXTENSION_FileNotFound_COD: String = 'EN-0013';
   SSEX_EXTENSION_FileError_COD: String = 'EN-0014';
   SSEX_EXTENSION_ConstDeprecated_COD: String = 'EN-0015';

type

	BaseException = class(Exception);

   ExtensionException = class(BaseException);
   ExtensionListException = class(BaseException);
   ExtenderException = class(BaseException);
   ExtenderListException = class(BaseException);
   ContextException = class(BaseException);
   ContextExecThreadException = class(BaseException);
   MainException = class(BaseException);

resourcestring
	SSEX_MAIN_DefContexNil =
   	'Core.Main DefaultContext property is not assigned';

   SSEX_CONTEXT_AssignNilParam =
   	'Cannot assign a nil source.';

   SSEX_EXTENDERLIST_AddClassNilParam =
   	'The AddClass method cannot receive a nil class reference';

   SSEX_EXTENSION_NoOwner =
   	'The TSimpleScriptExtension Owner cannot be nil';

   SSEX_EXTENDER_NoOwner =
   	'The TSimpleScriptExtender Owner cannot be nil';

   SSEX_EXECTHREAD_NoOwner =
   	'The TContextExecThread Owner cannot be nil';

   SSEX_GENERIC_Unhandled =
   	'Exce��o n�o tratada';

   SSEX_GENERIC_StackOverflowTermination =
   	'Ocorreu uma falha grave de estouro de pilha, provavelmente devido � uma recurs�o infinita. O estado da aplica��o � incerto';

   SSEX_EXTENSION_FunctionDeprecated =
   	'A fun��o "%s" � obsoleta, utilize a fun��o "%s"';

   SSEX_EXTENSION_InvalidInteger =
   	'O par�metro "%s" da fun��o %s n�o � um n�mero inteiro v�lido';

   SSEX_EXTENSION_InsuficientParams =
   	'Par�metros insuficientes. A fun��o %s espera ao menos %d';

   SSEX_EXTENSION_FunctionNotExists =
   	'A fun��o "%s" n�o � uma fun��o v�lida';

   SSEX_EXTENSION_EmptyString =
   	'O par�metro %d da fun��o %s n�o pode ser uma cadeia de caracteres vazia';

   SSEX_EXTENSION_InvalidDecimal =
   	'O par�metro "%s" da fun��o %s n�o � um n�mero decimal v�lido';

   SSEX_EXTENSION_InvalidDate =
   	'O par�metro "%s" da fun��o %s n�o � uma data v�lida';

   SSEX_EXTENSION_UndeclaredVariable =
   	'A vari�vel "%s" foi usada sem ser declarada anteriormente';

   SSEX_EXTENSION_VariableNotNumeric =
   	'Erro na fun��o %s, a vari�vel "%s" deveria conter um valor num�rico';

   SSEX_EXTENSION_UndeclaredFunction =
   	'Erro na fun��o %s, a fun��o de usu�rio "%s" n�o foi declarada';

   SSEX_EXTENSION_ConstantNotExists =
      'A constante "%s" n�o � uma constante v�lida';

   SSEX_EXTENSION_InvalidByte =
      'O par�metro "%s" da fun��o %s n�o � um valor de byte v�lido, deveria estar entre 0 e 255';

   SSEX_GENERIC_TooManyErros =
      'Muitos erros durante a execu��o. Execu��o interrompida';

   SSEX_EXTENSION_FileNotFound =
      'Erro na fun��o "%s", o arquivo "%s" n�o foi encontrado';

   SSEX_EXTENSION_FileError =
      'Erro de arquivo na fun��o "%s": %s';

   SSEX_EXTENSION_ConstDeprecated =
      'A constante "%s" � obsoleta, utilize "%s"';

implementation

end.
