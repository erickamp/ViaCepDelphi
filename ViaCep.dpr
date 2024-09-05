program ViaCep;

uses
  Vcl.Forms,
  frmPrincipal in 'frmPrincipal.pas' {frPrincipal},
  Model in 'Model.pas',
  Controller in 'Controller.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrPrincipal, frPrincipal);
  Application.Run;
end.
