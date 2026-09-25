@echo off
setlocal enabledelayedexpansion
title OmniVoice TTS Studio - Thiet Lap Moi Truong AI
cd /d "%~dp0\.."

set "APP_ROOT=%cd%"
set "BACKEND_DIR=%APP_ROOT%\backend"
set "VENV_DIR=%BACKEND_DIR%\venv"
set "PYTHON_EXE=%VENV_DIR%\Scripts\python.exe"

echo ========================================================
echo      THIET LAP MOI TRUONG OMNIVOICE TTS STUDIO (WINDOWS)
echo ========================================================
echo.
echo He thong se tu dong kiem tra va cai dat cac thanh phan can thiet.
echo Neu may ban da co san thanh phan nao, buoc do se duoc BO QUA.
echo.

:: ---------------------------------------------------------
:: BUOC 1: KIEM TRA PYTHON TREN WINDOWS
:: ---------------------------------------------------------
echo [1/4] Kiem tra moi truong Python...
set "SYS_PYTHON="

for %%P in (python.exe python3.exe py.exe) do (
    if not defined SYS_PYTHON (
        where %%P >nul 2>nul
        if !errorlevel! equ 0 (
            %%P -c "import sys; sys.exit(0 if sys.version_info >= (3, 10) and sys.version_info < (3, 13) else 1)" >nul 2>nul
            if !errorlevel! equ 0 (
                set "SYS_PYTHON=%%P"
            )
        )
    )
)

if defined SYS_PYTHON (
    for /f "delims=" %%V in ('!SYS_PYTHON! --version') do echo   [OK] Da co san: %%V (!SYS_PYTHON!)
) else (
    echo   [!] Chua tim thay Python 3.10 - 3.12 tren may.
    echo   Dang tu dong tai bo cai Python 3.11.9 tu python.org...
    set "PY_INSTALLER=%TEMP%\python-3.11.9-amd64.exe"
    curl.exe -L -o "!PY_INSTALLER!" "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe"
    
    if exist "!PY_INSTALLER!" (
        echo   Dang tien hanh cai dat Python 3.11 (tu dong them vao PATH)...
        "!PY_INSTALLER!" /quiet InstallAllUsers=0 PrependPath=1 Include_test=0 SimpleInstall=1
        del "!PY_INSTALLER!" >nul 2>nul
        set "SYS_PYTHON=python.exe"
        echo   [OK] Da cai dat xong Python 3.11!
    ) else (
        echo   [ERROR] Khong the tai Python. Vui long cai dat Python 3.11 tu python.org roi chay lai.
        pause
        exit /b 1
    )
)

:: ---------------------------------------------------------
:: BUOC 2: KIEM TRA CONG CU FFMPEG
:: ---------------------------------------------------------
echo.
echo [2/4] Kiem tra cong cu xu ly am thanh FFmpeg...
set "HAS_FFMPEG=0"
where ffmpeg >nul 2>nul
if %errorlevel% equ 0 set "HAS_FFMPEG=1"
if exist "%BACKEND_DIR%\ffmpeg.exe" set "HAS_FFMPEG=1"

if "!HAS_FFMPEG!"=="1" (
    echo   [OK] Da co san FFmpeg tren he thong.
) else (
    echo   Dang tai FFmpeg cong cu xu ly audio cho Windows...
    curl.exe -L -o "%TEMP%\ffmpeg.zip" "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
    if exist "%TEMP%\ffmpeg.zip" (
        echo   Dang giai nen FFmpeg...
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%TEMP%\ffmpeg.zip' -DestinationPath '%TEMP%\ffmpeg_ext' -Force"
        for /r "%TEMP%\ffmpeg_ext" %%F in (ffmpeg.exe) do (
            if exist "%%F" copy /y "%%F" "%BACKEND_DIR%\ffmpeg.exe" >nul 2>nul
        )
        del /f /q "%TEMP%\ffmpeg.zip" >nul 2>nul
        rmdir /s /q "%TEMP%\ffmpeg_ext" >nul 2>nul
        if exist "%BACKEND_DIR%\ffmpeg.exe" (
            echo   [OK] Da cau hinh xong FFmpeg vao backend!
        ) else (
            echo   [INFO] Bo qua FFmpeg (He thong se dung module audio Python mac dinh).
        )
    ) else (
        echo   [INFO] Bo qua FFmpeg (He thong se dung module audio Python mac dinh).
    )
)

:: ---------------------------------------------------------
:: BUOC 3: THIET LAP MOI TRUONG AO VENV VA CAI DAT THU VIEN AI
:: ---------------------------------------------------------
echo.
echo [3/4] Kiem tra moi truong ao va thu vien AI...

set "LIBS_READY=0"
if exist "%PYTHON_EXE%" (
    "%PYTHON_EXE%" -c "import torch, omnivoice, fastapi, transformers, soundfile" >nul 2>nul
    if !errorlevel! equ 0 set "LIBS_READY=1"
)

if "!LIBS_READY!"=="1" (
    for /f "delims=" %%V in ('"%PYTHON_EXE%" -c "import torch; print(torch.__version__)"') do set "TORCH_VER=%%V"
    echo   [OK] Moi truong ao va toan bo thu vien AI da duoc cai dat day du!
    echo   - Phien ban PyTorch: !TORCH_VER!
) else (
    if not exist "%PYTHON_EXE%" (
        echo   Dang tao moi truong ao doc lap (virtualenv) tai backend\venv...
        if exist "%VENV_DIR%" rmdir /s /q "%VENV_DIR%" >nul 2>nul
        !SYS_PYTHON! -m venv "%VENV_DIR%"
    )
    
    echo   Dang nang cap pip...
    "%PYTHON_EXE%" -m pip install --upgrade pip setuptools wheel >nul 2>nul
    
    echo   Dang nhan dien phan cung GPU / CPU...
    set "HAS_CUDA=0"
    where nvidia-smi >nul 2>nul
    if !errorlevel! equ 0 (
        set "HAS_CUDA=1"
        echo   [OK] Phat hien card do hoa NVIDIA GPU! Dang cai dat CUDA 12.4...
        "%PYTHON_EXE%" -m pip install -r "%BACKEND_DIR%\requirements.txt"
    ) else (
        echo   [!] Khong phat hien card NVIDIA. Dang cai dat phien ban CPU nhe...
        "%PYTHON_EXE%" -m pip install torch torchaudio --index-url https://download.pytorch.org/whl/cpu
        "%PYTHON_EXE%" -m pip install -r "%BACKEND_DIR%\requirements.txt" --extra-index-url https://download.pytorch.org/whl/cpu
    )
    
    echo   [OK] Da cai dat xong toan bo thu vien AI!
)

:: ---------------------------------------------------------
:: BUOC 4: HOAN TAT VA KHOI CHAY UNG DUNG
:: ---------------------------------------------------------
echo.
echo ========================================================
echo   [OK] HOAN TAT THIET LAP OMNIVOICE TTS STUDIO!
echo ========================================================
echo   Dang khoi dong he thong...
echo.

:: Kiem tra va tu dong mo Google Colab neu dang bat Cloud GPU
findstr /i /c:"USE_REMOTE_GPU=true" "%BACKEND_DIR%\.env" >nul 2>nul
if !errorlevel! equ 0 (
    echo [INFO] Dang bat che do Cloud GPU. Dang mo Google Colab tren trinh duyet...
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

:: Mo trinh duyet Web App
start "" "http://localhost:8000"

:: Khoi chay backend
cd /d "%BACKEND_DIR%"
"%PYTHON_EXE%" -m uvicorn main:app --host 0.0.0.0 --port 8000
