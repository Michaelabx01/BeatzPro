[Setup]
AppId=B9F6E402-0CAE-4045-BDE6-14BD6C39C4EA
AppVersion=1.10.0+16
AppName=BeatzPro
AppPublisher=anandnet
AppPublisherURL=https://github.com/anandnet/Harmony-Music
AppSupportURL=https://github.com/anandnet/Harmony-Music
AppUpdatesURL=https://github.com/anandnet/Harmony-Music
DefaultDirName={autopf}\BeatzPro
DisableProgramGroupPage=yes
OutputDir=.
OutputBaseFilename=harmonymusicv1.10.0
Compression=lzma
SolidCompression=yes
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
WizardStyle=modern
PrivilegesRequired=lowest
LicenseFile=..\..\LICENSE
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\..\build\windows\x64\runner\Release\BeatzPro.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\BeatzPro"; Filename: "{app}\BeatzPro.exe"
Name: "{autodesktop}\BeatzPro"; Filename: "{app}\BeatzPro.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\BeatzPro.exe"; Description: "{cm:LaunchProgram,{#StringChange('BeatzPro', '&', '&&')}}"; Flags: nowait postinstall skipifsilent
