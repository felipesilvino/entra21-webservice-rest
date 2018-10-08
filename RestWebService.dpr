program RestWebService;

uses
  Forms,
  formMain in 'formMain.pas' {frmMain},
  Themes,
  ServerUtils in 'ServerUtils.pas',
  SysTypes in 'SysTypes.pas',
  ServerMethodsUnit1 in 'ServerMethodsUnit1.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
