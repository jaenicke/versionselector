{
  ***** BEGIN LICENSE BLOCK *****
  Version: MPL 1.1/GPL 2.0/LGPL 2.1

  The contents of this file are subject to the Mozilla Public License Version
  1.1 (the "License"); you may not use this file except in compliance with
  the License. You may obtain a copy of the License at
  http://www.mozilla.org/MPL/

  Software distributed under the License is distributed on an "AS IS" basis,
  WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
  for the specific language governing rights and limitations under the
  License.

  The Original Code is Delphi Version Selector.

  The Initial Developer of the Original Code is Sebastian Jänicke.
  Portions created by the Initial Developer are Copyright (C) 2013
  the Initial Developer. All Rights Reserved.

  Contributor(s):

  Alternatively, the contents of this file may be used under the terms of
  either the GNU General Public License Version 2 or later (the "GPL"), or
  the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
  in which case the provisions of the GPL or the LGPL are applicable instead
  of those above. If you wish to allow use of your version of this file only
  under the terms of either the GPL or the LGPL, and not to allow others to
  use your version of this file under the terms of the MPL, indicate your
  decision by deleting the provisions above and replace them with the notice
  and other provisions required by the GPL or the LGPL. If you do not delete
  the provisions above, a recipient may use your version of this file under
  the terms of any one of the MPL, the GPL or the LGPL.

  ***** END LICENSE BLOCK *****
}

unit VersionSelectionDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, DelphiVersionInfo, ShellAPI, Generics.Collections, DelphiProjectInfo;

type
  TfrmVersionSelectionDialog = class(TForm)
    lblHint: TLabel;
    lvDelphiVersions: TListView;
    btnStart: TButton;
    lblProjectFile: TLabel;
    chbDeleteDesktopFile: TCheckBox;
    cboProfileSelection: TComboBox;
    lblProfileSelection: TLabel;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvDelphiVersionsChange(Sender: TObject; Item: TListItem; Change: TItemChange);
  private
    FVersions: TList<TDelphiVersion>;
    FProjectInfo: TDelphiProject;
  public
  end;

var
  frmVersionSelectionDialog: TfrmVersionSelectionDialog;

implementation

{$R *.dfm}

procedure TfrmVersionSelectionDialog.btnStartClick(Sender: TObject);
var
  ProjectFile, StartParams: string;
begin
  if chbDeleteDesktopFile.Checked then
    DeleteFile(ChangeFileExt(lblProjectFile.Caption, '.dsk'));
  if lvDelphiVersions.ItemIndex >= 0 then
  begin
    ProjectFile := FVersions[lvDelphiVersions.ItemIndex].GetProjectFilename(lblProjectFile.Caption);
    StartParams := '"' + ProjectFile + '"';
    if (cboProfileSelection.Text <> '') and (cboProfileSelection.Text <> 'BDS (Standard)') then
      StartParams := StartParams + ' "-r' + cboProfileSelection.Text + '"';
    ShellExecute(Handle, 'open', PChar(lvDelphiVersions.Items[lvDelphiVersions.ItemIndex].SubItems[0]),
      PChar(StartParams), PChar(ExtractFilePath(lblProjectFile.Caption)), SW_SHOWNORMAL);
  end
  else
    ShellExecute(Handle, 'open', PChar('"' + ChangeFileExt(lblProjectFile.Caption, '.dpr') + '"'), nil,
      PChar(ExtractFilePath(lblProjectFile.Caption)), SW_SHOWNORMAL);
  Close;
end;

procedure TfrmVersionSelectionDialog.FormCreate(Sender: TObject);
begin
  FVersions := TList<TDelphiVersion>.Create;
end;

procedure TfrmVersionSelectionDialog.FormDestroy(Sender: TObject);
begin
  FVersions.Free;
end;

procedure TfrmVersionSelectionDialog.FormShow(Sender: TObject);
var
  CurrentDelphiVersion: TDelphiVersion;
  NewItem: TListItem;
  RecommendedIndex: Integer;
begin
  lblProjectFile.Caption := ParamStr(1);
  FProjectInfo.LoadFromFile(ParamStr(1));
  chbDeleteDesktopFile.Enabled := FileExists(ChangeFileExt(ParamStr(1), '.dsk'));
  RecommendedIndex := 0;
  for CurrentDelphiVersion in TDelphiVersions.Available do
  begin
    NewItem := lvDelphiVersions.Items.Add;
    NewItem.Caption := CurrentDelphiVersion.VersionName;
    if FProjectInfo.IsRecommendedVersion(CurrentDelphiVersion.ProductVersion) then
    begin
      NewItem.Caption := NewItem.Caption + ' (empfohlen)';
      RecommendedIndex := lvDelphiVersions.Items.Count - 1;
    end;
    NewItem.SubItems.Add(CurrentDelphiVersion.ApplicationExe);
    FVersions.Add(CurrentDelphiVersion);
  end;
  if lvDelphiVersions.Items.Count > 0 then
    lvDelphiVersions.ItemIndex := RecommendedIndex;
end;

procedure TfrmVersionSelectionDialog.lvDelphiVersionsChange(Sender: TObject; Item: TListItem; Change: TItemChange);
var
  BDSIndex: Integer;
begin
  cboProfileSelection.Text := '';
  cboProfileSelection.Enabled := (lvDelphiVersions.ItemIndex >= 0)
    and FVersions[lvDelphiVersions.ItemIndex].GetProfiles(cboProfileSelection.Items);
  BDSIndex := cboProfileSelection.Items.IndexOf('BDS');
  if BDSIndex >= 0 then
  begin
    cboProfileSelection.Items[BDSIndex] := 'BDS (Standard)';
    cboProfileSelection.ItemIndex := BDSIndex;
  end;
end;

end.
