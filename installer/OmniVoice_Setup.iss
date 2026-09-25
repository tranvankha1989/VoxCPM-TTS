; ================================================================
; Inno Setup Script: OmniVoice TTS Studio (Windows Installer)
; Tác giả: Tran Van Kha
; ================================================================

#define MyAppName "OmniVoice TTS Studio"
#define MyAppVersion "2.2.0"
#define MyAppPublisher "Tran Van Kha"
#define MyAppURL "https://github.com/tranvankha1989/self-tts"
#define MyAppExeName "OmniVoice_Start.bat"

[Setup]
AppId={{C7829910-E577-492B-864B-8E407BFDD89B}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={localappdata}\OmniVoice-TTS
DisableDirPage=no
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=..\dist_installer
OutputBaseFilename=OmniVoice_TTS_Windows_Setup_v{#MyAppVersion}
SetupIconFile=..\assets\app.ico
Compression=lzma2/fast
SolidCompression=no
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=lowest

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
; 1. Backend mã nguồn (không đóng gói venv nặng 3GB, máy sẽ tự cài qua mạng)
Source: "..\backend\*"; DestDir: "{app}\backend"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "__pycache__,*.pyc,outputs\*,venv\*"

; 2. Frontend phân phối tĩnh (đã build sẵn)
Source: "..\frontend\dist\*"; DestDir: "{app}\frontend\dist"; Flags: ignoreversion recursesubdirs createallsubdirs

; 3. Icons và tài nguyên
Source: "..\assets\*"; DestDir: "{app}\assets"; Flags: ignoreversion recursesubdirs createallsubdirs

; 4. Trình khởi chạy và cài đặt môi trường
Source: "OmniVoice_Start.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "OmniVoice_Start.bat"; DestDir: "{app}\installer"; Flags: ignoreversion
Source: "setup_environment.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "setup_environment.bat"; DestDir: "{app}\installer"; Flags: ignoreversion

; 5. File tài liệu
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\installer\{#MyAppExeName}"; IconFilename: "{app}\assets\app.ico"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\installer\{#MyAppExeName}"; IconFilename: "{app}\assets\app.ico"; Tasks: desktopicon

[Run]
Filename: "{app}\installer\setup_environment.bat"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: postinstall skipifsilent nowait
