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
   	'Exceção não tratada';

   SSEX_GENERIC_StackOverflowTermination =
   	'Ocorreu uma falha grave de estouro de pilha, provavelmente devido à uma recursão infinita. O estado da aplicação é incerto';

   SSEX_EXTENSION_FunctionDeprecated =
   	'A função "%s" é obsoleta, utilize a função "%s"';

   SSEX_EXTENSION_InvalidInteger =
   	'O parâmetro "%s" da função %s não é um número inteiro válido';

   SSEX_EXTENSION_InsuficientParams =
   	'Parâmetros insuficientes. A função %s espera ao menos %d';

   SSEX_EXTENSION_FunctionNotExists =
   	'A função "%s" não é uma função válida';

   SSEX_EXTENSION_EmptyString =
   	'O parâmetro %d da função %s não pode ser uma cadeia de caracteres vazia';

   SSEX_EXTENSION_InvalidDecimal =
   	'O parâmetro "%s" da função %s não é um número decimal válido';

   SSEX_EXTENSION_InvalidDate =
   	'O parâmetro "%s" da função %s não é uma data válida';

   SSEX_EXTENSION_UndeclaredVariable =
   	'A variável "%s" foi usada sem ser declarada anteriormente';

   SSEX_EXTENSION_VariableNotNumeric =
   	'Erro na função %s, a variável "%s" deveria conter um valor numérico';

   SSEX_EXTENSION_UndeclaredFunction =
   	'Erro na função %s, a função de usuário "%s" não foi declarada';

   SSEX_EXTENSION_ConstantNotExists =
      'A constante "%s" não é uma constante válida';

   SSEX_EXTENSION_InvalidByte =
      'O parâmetro "%s" da função %s não é um valor de byte válido, deveria estar entre 0 e 255';

   SSEX_GENERIC_TooManyErros =
      'Muitos erros durante a execução. Execução interrompida';

   SSEX_EXTENSION_FileNotFound =
      'Erro na função "%s", o arquivo "%s" não foi encontrado';

   SSEX_EXTENSION_FileError =
      'Erro de arquivo na função "%s": %s';

   SSEX_EXTENSION_ConstDeprecated =
      'A constante "%s" é obsoleta, utilize "%s"';

implementation

end.
