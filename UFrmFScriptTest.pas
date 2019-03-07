unit UFrmFScriptTest;

interface

uses
  SimpleScript.Core, SimpleScript.Utils,
  SimpleScript.Extenders.Basics,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, ToolWin, Menus;

type
  TFrmFScriptTest = class(TForm)
    redtInput: TRichEdit;
    redtOutput: TRichEdit;
    tbCommands: TToolBar;
    Splitter1: TSplitter;
    tbtnExecute: TToolButton;
    lsbMessages: TListBox;
    Splitter2: TSplitter;
    tbtnStop: TToolButton;
    procedure tbtnExecuteClick(Sender: TObject);
    procedure tbtnStopClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    procedure OnTerminateExec(Sender: TObject);
  public
    { Public declarations }
  end;

var
  FrmFScriptTest: TFrmFScriptTest;

implementation

{$R *.dfm}

procedure TFrmFScriptTest.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
	CanClose := SimpleScript.Core.Main.DefaultContext.Status = csIdle;
end;

procedure TFrmFScriptTest.OnTerminateExec(Sender: TObject);
var
	aux, errorKindStr: String;
   I: Integer;
   curError: TSimpleScriptContextError;
begin
	redtOutput.Lines.Text := SimpleScript.Core.Main.DefaultContext.Output;

   if SimpleScript.Core.Main.DefaultContext.PerformanceCounter.EllapsedTime < 1000 then
   	aux := Format('Tempo de execução: %.3f ms',[SimpleScript.Core.Main.DefaultContext.PerformanceCounter.EllapsedTime])
   else
   	aux := Format('Tempo de execução: %.3f segundos',[SimpleScript.Core.Main.DefaultContext.PerformanceCounter.EllapsedTime / 1000]);

   lsbMessages.Items.Append(aux);

   lsbMessages.Items.Append(
      Format(
      	'Erros: %d; Avisos: %d; Dicas: %d', [
      	SimpleScript.Core.Main.DefaultContext.Errors.CountError,
         SimpleScript.Core.Main.DefaultContext.Errors.CountWarning,
         SimpleScript.Core.Main.DefaultContext.Errors.CountInfo
      ])
   );

   if SimpleScript.Core.Main.DefaultContext.Errors.Count > 0 then begin
   	lsbMessages.Items.Append(#32);
      for I := 0 to SimpleScript.Core.Main.DefaultContext.Errors.Count - 1 do begin
      	curError := SimpleScript.Core.Main.DefaultContext.Errors[I];
      	case curError.Kind of
         	ekError: errorKindStr := 'Erro';
            ekWarning: errorKindStr := 'Aviso';
            ekInfo: errorKindStr := 'Dica';
         end;
         lsbMessages.Items.Append(
      		Format('%s: (%s) %s.', [errorKindStr, curError.Code, curError.Description])
         );
      end;
   end;

   tbtnExecute.Enabled := True;
   tbtnStop.Enabled := False;
end;

procedure TFrmFScriptTest.tbtnExecuteClick(Sender: TObject);
var
	input: String;
begin
	redtOutput.Lines.Clear;
	lsbMessages.Clear;

	input := Copy(redtInput.Lines.Text, 1, Length(redtInput.Lines.Text)-2);

   tbtnExecute.Enabled := False;
   tbtnStop.Enabled := True;

   SimpleScript.Core.Main.DefaultContext.Input := input;
   SimpleScript.Core.Main.DefaultContext.OnParseComplete := Self.OnTerminateExec;
   SimpleScript.Core.Main.DefaultContext.Parse;
end;

procedure TFrmFScriptTest.tbtnStopClick(Sender: TObject);
begin
	SimpleScript.Core.Main.DefaultContext.StopParse;
   tbtnStop.Enabled := False;
   lsbMessages.Items.Append('Execução interrompida pelo usuário. Os dados abaixo podem estar incompletos.');
end;

end.
