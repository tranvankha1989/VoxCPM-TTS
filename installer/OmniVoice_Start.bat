@echo off
chcp 65001 >nul
set PYTHONUTF8=1
set PYTHONIOENCODING=utf-8
title OmniVoice TTS Studio
cd /d "%~dp0\.."

set "APP_ROOT=%cd%"
set "BACKEND_DIR=%APP_ROOT%\backend"
set "PYTHON_EXE=%BACKEND_DIR%\venv\Scripts\python.exe"
set "PYTHONW_EXE=%BACKEND_DIR%\venv\Scripts\pythonw.exe"

:: Kiểm tra nếu chưa cài đặt môi trường
if not exist "%PYTHON_EXE%" (
    call "%APP_ROOT%\installer\setup_environment.bat"
    exit /b
)

:: Kiểm tra xem uvicorn đang chạy chưa
netstat -ano | findstr ":8000" | findstr "LISTENING" >nul 2>nul
if %errorlevel% equ 0 (
    echo [INFO] Server OmniVoice da san sang. Dang mo trinh duyet...
    start "" "http://localhost:8000"
    exit /b
)

echo ========================================================
echo        Khởi động OmniVoice TTS Studio (24kHz)
echo ========================================================
echo.
echo   - Backend AI: http://localhost:8000
echo.
echo Trình duyệt web sẽ tự động mở sau 3 giây...
echo Nhấn Ctrl+C để dừng hệ thống.
echo ========================================================

start "" "http://localhost:8000"
cd /d "%BACKEND_DIR%"
"%PYTHON_EXE%" -m uvicorn main:app --host 0.0.0.0 --port 8000
