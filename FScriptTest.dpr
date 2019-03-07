program FScriptTest;

uses
  Forms,
  UFrmFScriptTest in 'UFrmFScriptTest.pas' {FrmFScriptTest},
  SimpleScript.Core in 'SimpleScript.Core.pas',
  SimpleScript.Exceptions in 'SimpleScript.Exceptions.pas',
  SimpleScript.Extenders.Advanced in 'SimpleScript.Extenders.Advanced.pas',
  SimpleScript.Extenders.Basics in 'SimpleScript.Extenders.Basics.pas',
  SimpleScript.Extenders.DB in 'SimpleScript.Extenders.DB.pas',
  SimpleScript.Utils in 'SimpleScript.Utils.pas',
  SimpleScriptTest in 'SimpleScriptTest.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmFScriptTest, FrmFScriptTest);
  Application.Run;
end.
