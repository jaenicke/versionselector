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

unit DelphiVersionInfo;

interface

uses
  Windows, Classes, SysUtils, Registry;

type
  TDelphiVersion = record
    VersionName: string;
    ConditionalVersion: string;
    ProductVersion: Integer;
    RegKey, RegSubKey, RegVersion: string;
    function Available: Boolean;
    function ApplicationExe: string;
    function GetProjectFilename(const AFilename: string): string;
    function GetProfiles(const ATarget: TStrings): Boolean;
  end;

  TVersionEnumerator = class
  private
    var
      FIndex: Integer;
      FOnlyAvailable: Boolean;
    function GetCurrent: TDelphiVersion;
  public
    constructor Create(const AOnlyAvailable: Boolean);
    property Current: TDelphiVersion read GetCurrent;
    function MoveNext: Boolean;
  end;

  IDelphiVersions = interface
    function GetEnumerator: TVersionEnumerator;
  end;

  TDelphiVersions = class(TInterfacedObject, IDelphiVersions)
  private
    var
      FOnlyAvailable: Boolean;
    function GetEnumerator: TVersionEnumerator;
    procedure SetOnlyAvailable(const Value: Boolean);
  public
    constructor Create(const AOnlyAvailable: Boolean);
    class function All: IDelphiVersions;
    class function Available: IDelphiVersions;
    property OnlyAvailable: Boolean read FOnlyAvailable write SetOnlyAvailable;
  end;

implementation

const
  cDelphiVersions: array[0..25] of TDelphiVersion = (
//reWritten from scratch by KodeZwerg

{   // other Versions that have a ConditionalVersion
    (VersionName: 'Turbo Pascal 4.0'; ConditionalVersion: 'VER40'; ProductVersion: 1; RegKey: ''; RegSubKey: ''; RegVersion: ''),
    (VersionName: 'Turbo Pascal 5.0'; ConditionalVersion: 'VER50'; ProductVersion: 1; RegKey: ''; RegSubKey: ''; RegVersion: ''),
    (VersionName: 'Turbo Pascal 5.5'; ConditionalVersion: 'VER55'; ProductVersion: 1; RegKey: ''; RegSubKey: ''; RegVersion: ''),
    (VersionName: 'Turbo Pascal 6.0'; ConditionalVersion: 'VER60'; ProductVersion: 1; RegKey: ''; RegSubKey: ''; RegVersion: ''),
    (VersionName: 'Turbo Pascal für Windows 1.0'; ConditionalVersion: 'VER10'; ProductVersion: 1; RegKey: ''; RegSubKey: ''; RegVersion: ''),
    (VersionName: 'Turbo Pascal für Windows 1.5'; ConditionalVersion: 'VER15'; ProductVersion: 1; RegKey: ''; RegSubKey: ''; RegVersion: ''),
    (VersionName: 'Turbo Pascal 7.0'; ConditionalVersion: 'VER70'; ProductVersion: 1; RegKey: ''; RegSubKey: ''; RegVersion: ''),
}
    (VersionName: 'Delphi 1'; ConditionalVersion: 'VER80'; ProductVersion: 1; RegKey: 'Software\Borland\'; RegSubKey: 'Delphi\'; RegVersion: '1.0\'),
    (VersionName: 'Delphi 2'; ConditionalVersion: 'VER90'; ProductVersion: 2; RegKey: 'Software\Borland\'; RegSubKey: 'Delphi\'; RegVersion: '2.0\'),
//    (VersionName: 'C++Builder 1'; ConditionalVersion: 'VER93'; ProductVersion: 1; RegKey: ''; RegSubKey: ''; RegVersion: ''),
    (VersionName: 'Delphi 3'; ConditionalVersion: 'VER100'; ProductVersion: 3; RegKey: 'Software\Borland\'; RegSubKey: 'Delphi\'; RegVersion: '3.0\'),
//    (VersionName: 'C++Builder 3'; ConditionalVersion: 'VER110'; ProductVersion: 1; RegKey: ''; RegSubKey: ''; RegVersion: ''),
    (VersionName: 'Delphi 4'; ConditionalVersion: 'VER120'; ProductVersion: 4; RegKey: 'Software\Borland\'; RegSubKey: 'Delphi\'; RegVersion: '4.0\'),
//    (VersionName: 'C++Builder 4'; ConditionalVersion: 'VER125'; ProductVersion: 1; RegKey: ''; RegSubKey: ''; RegVersion: ''),
    (VersionName: 'Delphi 5'; ConditionalVersion: 'VER130'; ProductVersion: 5; RegKey: 'Software\Borland\'; RegSubKey: 'Delphi\'; RegVersion: '5.0\'),
    (VersionName: 'Delphi 6'; ConditionalVersion: 'VER140'; ProductVersion: 6; RegKey: 'Software\Borland\'; RegSubKey: 'Delphi\'; RegVersion: '6.0\'),
    (VersionName: 'Delphi 7'; ConditionalVersion: 'VER150'; ProductVersion: 7; RegKey: 'Software\Borland\'; RegSubKey: 'Delphi\'; RegVersion: '7.0\'),
    (VersionName: 'Delphi 8 (.Net)'; ConditionalVersion: 'VER160'; ProductVersion: 8; RegKey: 'Software\Borland\'; RegSubKey: 'BDS\'; RegVersion: '2.0\'),
    (VersionName: 'Delphi 2005'; ConditionalVersion: 'VER170'; ProductVersion: 9; RegKey: 'Software\Borland\'; RegSubKey: 'BDS\'; RegVersion: '3.0\'),
    (VersionName: 'Delphi 2006'; ConditionalVersion: 'VER180'; ProductVersion: 10; RegKey: 'Software\Borland\'; RegSubKey: 'BDS\'; RegVersion: '4.0\'),
    (VersionName: 'Delphi 2007 für Win32'; ConditionalVersion: 'VER185'; ProductVersion: 11; RegKey: 'Software\Borland\'; RegSubKey: 'BDS\'; RegVersion: '5.0\'),
    (VersionName: 'Delphi 2007 für .Net'; ConditionalVersion: 'VER190'; ProductVersion: 12; RegKey: 'Software\Borland\'; RegSubKey: 'BDS\'; RegVersion: '5.0\'),
    (VersionName: 'Delphi 2009'; ConditionalVersion: 'VER200'; ProductVersion: 13; RegKey: 'Software\CodeGear\'; RegSubKey: 'BDS\'; RegVersion: '6.0\'),
    (VersionName: 'Delphi 2010'; ConditionalVersion: 'VER210'; ProductVersion: 14; RegKey: 'Software\CodeGear\'; RegSubKey: 'BDS\'; RegVersion: '7.0\'),
    (VersionName: 'Delphi XE'; ConditionalVersion: 'VER220'; ProductVersion: 15; RegKey: 'Software\Embarcadero\'; RegSubKey: 'BDS\'; RegVersion: '8.0\'),
    (VersionName: 'Delphi XE2'; ConditionalVersion: 'VER230'; ProductVersion: 16; RegKey: 'Software\Embarcadero\'; RegSubKey: 'BDS\'; RegVersion: '9.0\'),
    (VersionName: 'Delphi XE3'; ConditionalVersion: 'VER240'; ProductVersion: 17; RegKey: 'Software\Embarcadero\'; RegSubKey: 'BDS\'; RegVersion: '10.0\'),
    (VersionName: 'Delphi XE4'; ConditionalVersion: 'VER250'; ProductVersion: 18; RegKey: 'Software\Embarcadero\'; RegSubKey: 'BDS\'; RegVersion: '11.0\'),
    (VersionName: 'Delphi XE5'; ConditionalVersion: 'VER260'; ProductVersion: 19; RegKey: 'Software\Embarcadero\'; RegSubKey: 'BDS\'; RegVersion: '12.0\'),
    (VersionName: 'Delphi AppMethod 1.13'; ConditionalVersion: 'VER265'; ProductVersion: 20; RegKey: 'Software\Embarcadero\'; RegSubKey: 'BDS\'; RegVersion: '13.0\'),
    (VersionName: 'Delphi XE6'; ConditionalVersion: 'VER270'; ProductVersion: 21; RegKey: 'Software\Embarcadero\'; RegSubKey: 'BDS\'; RegVersion: '14.0\'),
    (VersionName: 'Delphi XE7'; ConditionalVersion: 'VER280'; ProductVersion: 22; RegKey: 'Software\Embarcadero\'; RegSubKey: 'BDS\'; RegVersion: '15.0\'),
    (VersionName: 'Delphi XE8'; ConditionalVersion: 'VER290'; ProductVersion: 23; RegKey: 'Software\Embarcadero\'; RegSubKey: 'BDS\'; RegVersion: '16.0\'),
    (VersionName: 'Delphi 10 Seattle'; ConditionalVersion: 'VER300'; ProductVersion: 24; RegKey: 'Software\Embarcadero\'; RegSubKey: 'BDS\'; RegVersion: '17.0\'),
    (VersionName: 'Delphi 10.1 Berlin'; ConditionalVersion: 'VER310'; ProductVersion: 25; RegKey: 'Software\Embarcadero\'; RegSubKey: 'BDS\'; RegVersion: '18.0\'),
    (VersionName: 'Delphi 10.2 Tokyo'; ConditionalVersion: 'VER320'; ProductVersion: 26; RegKey: 'Software\Embarcadero\'; RegSubKey: 'BDS\'; RegVersion: '19.0\')
  );

{ TDelphiVersions }

class function TDelphiVersions.Available: IDelphiVersions;
begin
  Result := TDelphiVersions.Create(True);
end;

constructor TDelphiVersions.Create(const AOnlyAvailable: Boolean);
begin
  FOnlyAvailable := AOnlyAvailable;
end;

class function TDelphiVersions.All: IDelphiVersions;
begin
  Result := TDelphiVersions.Create(False);
end;

function TDelphiVersions.GetEnumerator: TVersionEnumerator;
begin
  Result := TVersionEnumerator.Create(FOnlyAvailable);
end;

procedure TDelphiVersions.SetOnlyAvailable(const Value: Boolean);
begin
  FOnlyAvailable := Value;
end;

{ TVersionEnumerator }

constructor TVersionEnumerator.Create(const AOnlyAvailable: Boolean);
begin
  FIndex := -1;
  FOnlyAvailable := AOnlyAvailable;
end;

function TVersionEnumerator.GetCurrent: TDelphiVersion;
begin
  Result := cDelphiVersions[FIndex];
end;

function TVersionEnumerator.MoveNext: Boolean;
begin
  repeat
    Inc(FIndex);
    Result := FIndex <= High(cDelphiVersions);
  until not Result or not FOnlyAvailable or cDelphiVersions[FIndex].Available;
end;

{ TDelphiVersion }

function TDelphiVersion.ApplicationExe: string;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(RegKey + RegSubKey + RegVersion, False) then
    begin
      Result := Reg.ReadString('App');
      Reg.CloseKey();
    end
    else
      Result := '';
  finally
    Reg.Free();
  end;
end;

function TDelphiVersion.Available: Boolean;
begin
  Result := FileExists(ApplicationExe);
end;

function TDelphiVersion.GetProfiles(const ATarget: TStrings): Boolean;
var
  Reg: TRegistry;
  KeysToCheck: TStringList;
  CurrentKey: string;
begin
  ATarget.Clear;
  if ProductVersion < 9 then
    Result := False
  else
  begin
    Reg := TRegistry.Create(KEY_READ);
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey(RegKey, False) then
      begin
        KeysToCheck := TStringList.Create;
        try
          Reg.GetKeyNames(KeysToCheck);
          for CurrentKey in KeysToCheck do
            if Reg.KeyExists(CurrentKey + '\' + RegVersion) then
              ATarget.Add(CurrentKey);
        finally
          KeysToCheck.Free;
        end;
        Reg.CloseKey();
        Result := ATarget.Count > 0;
      end
      else
        Result := False;
    finally
      Reg.Free();
    end;
  end;
end;

function TDelphiVersion.GetProjectFilename(const AFilename: string): string;
var
  BestExtension, BestExtensionFilename: string;
begin
  case ProductVersion of
    1..7:
      BestExtension := '.dpr';
    9, 10:
      BestExtension := '.bdsproj';
  else
    BestExtension := '.dproj';
  end;
  BestExtensionFilename := ChangeFileExt(AFilename, BestExtension);
  if (ExtractFileExt(AFilename) <> BestExtension) and FileExists(BestExtensionFilename) then
    Result := BestExtensionFilename
  else
    Result := AFilename;
end;

end.
