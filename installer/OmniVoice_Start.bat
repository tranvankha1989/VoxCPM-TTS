@echo off
setlocal enabledelayedexpansion
title OmniVoice TTS Studio
cd /d "%~dp0\.."

set "APP_ROOT=%cd%"
set "BACKEND_DIR=%APP_ROOT%\backend"
set "PYTHON_EXE=%BACKEND_DIR%\venv\Scripts\python.exe"

:: Kiem tra neu chua cai dat moi truong
if not exist "%PYTHON_EXE%" (
    call "%APP_ROOT%\installer\setup_environment.bat"
    exit /b
)

:: Kiem tra xem uvicorn dang chay chua
netstat -ano | findstr ":8000" | findstr "LISTENING" >nul 2>&1
if !errorlevel! equ 0 (
    echo [INFO] Server OmniVoice da san sang. Dang mo trinh duyet...
    findstr /i /c:"USE_REMOTE_GPU=true" "%BACKEND_DIR%\.env" >nul 2>&1
    if !errorlevel! equ 0 (
        set "COLAB_LINK="
        for /f "tokens=1,* delims==" %%A in ('findstr /i /c:"COLAB_NOTEBOOK_URL" "%BACKEND_DIR%\.env"') do set "COLAB_LINK=%%B"
        if defined COLAB_LINK (start "" "!COLAB_LINK!") else (start "" "https://colab.research.google.com/drive/1QK4hoFRklcGQpgUkU_YNcDidA5y5kzgO")
    )
    start "" "http://localhost:8000"
    exit /b
)

echo ========================================================
echo        Khoi dong OmniVoice TTS Studio
echo ========================================================
echo.
echo   - Backend AI: http://localhost:8000
echo.
echo Trinh duyet web se tu dong mo sau 3 giay...
echo Nhan Ctrl+C de dung he thong.
echo ========================================================

:: Kiem tra va tu dong mo Google Colab neu dang bat Cloud GPU
findstr /i /c:"USE_REMOTE_GPU=true" "%BACKEND_DIR%\.env" >nul 2>&1
if !errorlevel! equ 0 (
    echo [INFO] Dang bat che do Cloud GPU. Dang tu dong mo Google Colab tren trinh duyet...
    set "COLAB_LINK="
    for /f "tokens=1,* delims==" %%A in ('findstr /i /c:"COLAB_NOTEBOOK_URL" "%BACKEND_DIR%\.env"') do (
        set "COLAB_LINK=%%B"
    )
    if defined COLAB_LINK (
        start "" "!COLAB_LINK!"
    ) else (
        start "" "https://colab.research.google.com/drive/1QK4hoFRklcGQpgUkU_YNcDidA5y5kzgO"
    )
)

echo [INFO] He thong dang cho ket noi AI Model / Cloud GPU...
echo [INFO] Trinh duyet Web se TU DONG MO ngay khi GPU san sang hoat dong!
echo.

:: Khoi chay luong ngam cho den khi GPU / Model san sang roi moi bat trinh duyet
start "" /b powershell -NoProfile -ExecutionPolicy Bypass -Command "$opened = $false; for ($i=0; $i -lt 300; $i++) { Start-Sleep -Seconds 2; try { $r = Invoke-RestMethod -Uri 'http://127.0.0.1:8000/api/health' -TimeoutSec 2 -ErrorAction Stop; if ($r.status -eq 'ok' -and $r.model_loaded -eq $true) { Start-Process 'http://localhost:8000'; $opened = $true; break } } catch {} }; if (-not $opened) { Start-Process 'http://localhost:8000' }"

cd /d "%BACKEND_DIR%"
"%PYTHON_EXE%" -m uvicorn main:app --host 0.0.0.0 --port 8000
