@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo ========================================================
echo   BO CONG CU DONG GOI OMNIVOICE TTS (WINDOWS & MACOS)
echo ========================================================
echo.

set "ISCC=C:\Users\%USERNAME%\AppData\Local\Programs\Inno Setup 6\ISCC.exe"
if not exist "%ISCC%" (
    where iscc >nul 2>nul
    if %errorlevel% equ 0 (
        set "ISCC=iscc"
    ) else (
        echo [ERROR] Khong tim thay Inno Setup 6!
        pause
        exit /b 1
    )
)

echo [1/3] Kiem tra Frontend Build...
if not exist "frontend\dist\index.html" (
    echo Dang bien dich Frontend...
    cd frontend && call pnpm build && cd ..
)

echo.
echo [2/3] Dong goi bo cai dat cho macOS (ZIP Bundle)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$staging = '%~dp0dist_installer\OmniVoice_TTS_macOS_Setup'; if (Test-Path $staging) { Remove-Item $staging -Recurse -Force }; New-Item -ItemType Directory -Path $staging | Out-Null; Copy-Item '%~dp0Cai_Dat_macOS.command' $staging; Copy-Item '%~dp0start.command' $staging; Copy-Item '%~dp0start.sh' $staging; Copy-Item '%~dp0HUONG_DAN_CAI_DAT_MAC.txt' $staging; Copy-Item '%~dp0README.md' $staging; Copy-Item '%~dp0assets' $staging -Recurse; New-Item -ItemType Directory -Path \"$staging\frontend\" | Out-Null; Copy-Item '%~dp0frontend\dist' \"$staging\frontend\dist\" -Recurse; New-Item -ItemType Directory -Path \"$staging\backend\" | Out-Null; Get-ChildItem '%~dp0backend' -Exclude 'venv', 'outputs', '__pycache__', 'scratch*' | Copy-Item -Destination \"$staging\backend\" -Recurse; $zipPath = '%~dp0dist_installer\OmniVoice_TTS_macOS_Setup_v2.2.0.zip'; if (Test-Path $zipPath) { Remove-Item $zipPath -Force }; Compress-Archive -Path \"$staging\*\" -DestinationPath $zipPath -CompressionLevel Optimal; Remove-Item $staging -Recurse -Force; Write-Host '✓ Da tao xong ban cai dat macOS!'"

echo.
echo [3/3] Dong goi file cai dat Windows (.exe) bang Inno Setup...
echo Dang chay: "%ISCC%" "installer\OmniVoice_Setup.iss"
"%ISCC%" "installer\OmniVoice_Setup.iss"

if %errorlevel% equ 0 (
    echo.
    echo ========================================================
    echo   HOAN TAT DONG GOI CHO CA WINDOWS & MACOS!
    echo ========================================================
    echo   1. Windows Setup : dist_installer\OmniVoice_TTS_Windows_Setup_v2.2.0.exe
    echo   2. macOS Setup   : dist_installer\OmniVoice_TTS_macOS_Setup_v2.2.0.zip
    echo ========================================================
) else (
    echo.
    echo [ERROR] Co loi xay ra trong qua trinh dong goi Windows!
)
pause
