program Game2048;

uses
  Forms,
  fMain in 'fMain.pas' {Form6},
  u2048Game in 'u2048Game.pas',
  u2048GameRenderer in 'u2048GameRenderer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := '2048';
  Application.CreateForm(TForm6, Form6);
  Application.Run;
end.
