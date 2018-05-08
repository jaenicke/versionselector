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

unit DelphiProjectInfo;

interface

uses
  XmlDoc, XMLIntf, adomxmldom, SysUtils, IniFiles;

type
  TDelphiProject = record
  private
    function GetProductVersionFromDProj(const AFilename: string): TArray<Integer>;
    function GetProductVersionFromBdsProj(const AFilename: string): TArray<Integer>;
    function GetProductVersionFromDpr(const AFilename: string): TArray<Integer>;
  public
    ProductVersion: TArray<Integer>;
    procedure LoadFromFile(const AFilename: string);
    function IsRecommendedVersion(const AVersionNumber: Integer): Boolean;
  end;

implementation

{ TDelphiProject }

function TDelphiProject.GetProductVersionFromBdsProj(const AFilename: string): TArray<Integer>;
begin
  Result := TArray<Integer>.Create(9, 10);
end;

function TDelphiProject.GetProductVersionFromDpr(const AFilename: string): TArray<Integer>;
var
  DofFilename, DofFileVersion: string;
  DofIni: TMemIniFile;
  DofVersionNumber: Integer;
begin
  DofFilename := ChangeFileExt(AFilename, '.dof');
  if FileExists(DofFilename) then
  begin
    DofIni := TMemIniFile.Create(DofFilename);
    try
      DofFileVersion := DofIni.ReadString('FileVersion', 'Version', '');
      if (DofFileVersion <> '') and TryStrToInt(DofFileVersion[1], DofVersionNumber) then
        Result := TArray<Integer>.Create(DofVersionNumber)
      else
        Result := TArray<Integer>.Create(5);
    finally
      DofIni.Free;
    end;
  end
  else
    Result := TArray<Integer>.Create(1, 2, 3, 4, 5, 6, 7);
end;

function TDelphiProject.GetProductVersionFromDProj(const AFilename: string): TArray<Integer>;
var
  ProjectFileXml: IXMLDocument;
  VersionValue: string;
  VersionNode: IXMLNode;
  ProjectVersion: Double;
begin
  ProjectFileXml := LoadXMLDocument(AFilename);
  VersionNode := ProjectFileXml.DocumentElement.ChildNodes['PropertyGroup'].ChildNodes['ProjectVersion'];
  if Assigned(VersionNode) and VersionNode.IsTextElement then
  begin
    VersionValue := VersionNode.NodeValue;
    ProjectVersion := StrToFloatDef(StringReplace(VersionValue, '.', FormatSettings.DecimalSeparator, []), 0);
    if ProjectVersion <= 12.1 then
      Result := TArray<Integer>.Create(12, 14)
    else if ProjectVersion < 13 then
      Result := TArray<Integer>.Create(15)
    else if ProjectVersion < 14 then
      Result := TArray<Integer>.Create(16)
    else if ProjectVersion <= 14.5 then
      Result := TArray<Integer>.Create(17)
    else
      Result := TArray<Integer>.Create(18);
  end
  else
    Result := TArray<Integer>.Create(11);
 end;

function TDelphiProject.IsRecommendedVersion(const AVersionNumber: Integer): Boolean;
var
  CurrentVersion: Integer;
begin
  Result := False;
  for CurrentVersion in ProductVersion do
    if CurrentVersion = AVersionNumber then
      Exit(True);
end;

procedure TDelphiProject.LoadFromFile(const AFilename: string);
var
  DprFilename, DprojFilename, BdsProjFilename: string;
begin
  DprFilename := ChangeFileExt(AFilename, '.dpr');
  DprojFilename := ChangeFileExt(AFilename, '.dproj');
  BdsProjFilename := ChangeFileExt(AFilename, '.bdsproj');
  if FileExists(DprojFilename) then
    ProductVersion := GetProductVersionFromDProj(DprojFilename)
  else if FileExists(BdsProjFilename) then
    ProductVersion := GetProductVersionFromBdsProj(BdsProjFilename)
  else if FileExists(DprFilename) then
    ProductVersion := GetProductVersionFromDpr(DprFilename)
  else
    ProductVersion := TArray<Integer>.Create(0);
end;

end.
