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
echo [2/3] Dong goi bo cai dat cho macOS (ZIP Bundle voi quyen POSIX 755)...
python "%~dp0scripts\package_macos.py"

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
