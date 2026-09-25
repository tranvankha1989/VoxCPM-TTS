@echo off
chcp 65001 >nul
set PYTHONUTF8=1
set PYTHONIOENCODING=utf-8
title OmniVoice Launcher (TTS 24kHz)
cd /d "%~dp0"

echo ===================================================
echo        Khoi dong he thong OmniVoice TTS (24kHz)
echo ===================================================
echo.
echo - Backend AI : http://localhost:8000
echo - Giao dien  : http://localhost:5173
echo.
echo Trinh duyet se TU DONG MO khi AI Model san sang!
echo Nhan Ctrl+C de dung toan bo he thong.
echo ===================================================
:: Tu dong tao Shortcut ngoai Desktop neu chua co
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\create_desktop_shortcut.ps1" -Silent >nul 2>&1

:: Kiem tra moi truong Python venv
if not exist "%~dp0backend\venv\Scripts\python.exe" (
    echo [KIEM TRA] Chua tim thay thu muc backend\venv...
    where python >nul 2>nul
    if %errorlevel% equ 0 (
        echo [OK] Phat hien may da co san Python. Dang tao moi truong ao backend\venv tu Python co san...
        python -m venv "%~dp0backend\venv"
        call "%~dp0backend\venv\Scripts\activate.bat"
        python -m pip install --upgrade pip
        pip install -r "%~dp0backend\requirements.txt"
    ) else (
        echo [ERROR] Khong tim thay Python tren may! Vui long cai Python 3.10 hoac 3.11.
        pause
        exit /b 1
    )
)

cd /d "%~dp0frontend"
call pnpm exec concurrently --kill-others-on-fail --names "BACKEND,FRONTEND,TRAY" --prefix-colors "blue,magenta,cyan" "cd /d \"%~dp0backend\" && \"%~dp0backend\venv\Scripts\python.exe\" -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload" "call pnpm dev" "powershell -NoProfile -ExecutionPolicy Bypass -File \"%~dp0scripts\tray_manager.ps1\""

if %errorlevel% neq 0 pause


