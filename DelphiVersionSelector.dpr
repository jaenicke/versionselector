program DelphiVersionSelector;

uses
  Forms,
  VersionSelectionDialog in 'VersionSelectionDialog.pas' {frmVersionSelectionDialog},
  DelphiVersionInfo in 'DelphiVersionInfo.pas',
  DelphiProjectInfo in 'DelphiProjectInfo.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Delphi Version Selector';
  Application.CreateForm(TfrmVersionSelectionDialog, frmVersionSelectionDialog);
  Application.Run;
end.
