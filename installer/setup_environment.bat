@echo off
chcp 65001 >nul
set PYTHONUTF8=1
set PYTHONIOENCODING=utf-8
title OmniVoice TTS Studio - Thiet Lap Moi Truong AI
cd /d "%~dp0\.."

set "APP_ROOT=%cd%"
set "BACKEND_DIR=%APP_ROOT%\backend"
set "VENV_DIR=%BACKEND_DIR%\venv"
set "PYTHON_EXE=%VENV_DIR%\Scripts\python.exe"

echo ========================================================
echo      THIẾT LẬP MÔI TRƯỜNG OMNIVOICE TTS STUDIO (WINDOWS)
echo ========================================================
echo.
echo Hệ thống sẽ tự động kiểm tra và cài đặt các thành phần cần thiết.
echo Nếu máy bạn đã có sẵn thành phần nào, bước đó sẽ được BỎ QUA.
echo.

:: ---------------------------------------------------------
:: BƯỚC 1: KIỂM TRA PYTHON TRÊN WINDOWS
:: ---------------------------------------------------------
echo [1/4] Kiểm tra môi trường Python...
set "SYS_PYTHON="

for %%P in (python.exe python3.exe py.exe) do (
    if not defined SYS_PYTHON (
        where %%P >nul 2>nul
        if %errorlevel% equ 0 (
            %%P -c "import sys; sys.exit(0 if sys.version_info >= (3, 10) and sys.version_info < (3, 13) else 1)" >nul 2>nul
            if %errorlevel% equ 0 (
                set "SYS_PYTHON=%%P"
            )
        )
    )
)

if defined SYS_PYTHON (
    for /f "delims=" %%V in ('%SYS_PYTHON% --version') do echo   ✓ Đã có sẵn: %%V (%SYS_PYTHON%)
) else (
    echo   ⚠️ Chưa tìm thấy Python 3.10 - 3.12 trên máy.
    echo   Đang tự động tải bộ cài Python 3.11.9 từ python.org qua curl...
    set "PY_INSTALLER=%TEMP%\python-3.11.9-amd64.exe"
    curl.exe -L -o "%PY_INSTALLER%" "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe"
    
    if exist "%PY_INSTALLER%" (
        echo   Đang tiến hành cài đặt Python 3.11 (tự động thêm vào PATH)...
        "%PY_INSTALLER%" /quiet InstallAllUsers=0 PrependPath=1 Include_test=0 SimpleInstall=1
        del "%PY_INSTALLER%" >nul 2>nul
        set "SYS_PYTHON=python.exe"
        echo   ✓ Đã cài đặt xong Python 3.11!
    ) else (
        echo   [ERROR] Không thể tải Python. Vui lòng cài đặt Python 3.11 từ python.org rồi chạy lại.
        pause
        exit /b 1
    )
)

:: ---------------------------------------------------------
:: BƯỚC 2: KIỂM TRA CÔNG CỤ FFMPEG
:: ---------------------------------------------------------
echo.
echo [2/4] Kiểm tra công cụ xử lý âm thanh FFmpeg...
set "HAS_FFMPEG=0"
where ffmpeg >nul 2>nul
if %errorlevel% equ 0 set "HAS_FFMPEG=1"
if exist "%BACKEND_DIR%\ffmpeg.exe" set "HAS_FFMPEG=1"

if "%HAS_FFMPEG%"=="1" (
    echo   ✓ Đã có sẵn FFmpeg trên hệ thống.
) else (
    echo   Đang tải FFmpeg công cụ xử lý audio độc lập cho Windows...
    curl.exe -L -o "%TEMP%\ffmpeg.zip" "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip"
    if exist "%TEMP%\ffmpeg.zip" (
        mkdir "%TEMP%\ffmpeg_ext" 2>nul
        tar.exe -xf "%TEMP%\ffmpeg.zip" -C "%TEMP%\ffmpeg_ext" 2>nul
        for /r "%TEMP%\ffmpeg_ext" %%F in (ffmpeg.exe) do (
            copy /y "%%F" "%BACKEND_DIR%\ffmpeg.exe" >nul 2>nul
        )
        del /f /q "%TEMP%\ffmpeg.zip" >nul 2>nul
        rmdir /s /q "%TEMP%\ffmpeg_ext" >nul 2>nul
        if exist "%BACKEND_DIR%\ffmpeg.exe" (
            echo   ✓ Đã cấu hình xong FFmpeg vào thư mục backend!
        ) else (
            echo   ℹ️ Bỏ qua FFmpeg (Hệ thống sẽ dùng module audio Python mặc định).
        )
    ) else (
        echo   ℹ️ Bỏ qua FFmpeg (Hệ thống sẽ dùng module audio Python mặc định).
    )
)

:: ---------------------------------------------------------
:: BƯỚC 3: THIẾT LẬP MÔI TRƯỜNG ẢO VENV & CÀI ĐẶT THƯ VIỆN AI
:: ---------------------------------------------------------
echo.
echo [3/4] Kiểm tra môi trường ảo và thư viện AI...

set "LIBS_READY=0"
if exist "%PYTHON_EXE%" (
    "%PYTHON_EXE%" -c "import torch, omnivoice, fastapi, transformers, soundfile" >nul 2>nul
    if %errorlevel% equ 0 set "LIBS_READY=1"
)

if "%LIBS_READY%"=="1" (
    for /f "delims=" %%V in ('"%PYTHON_EXE%" -c "import torch; print(torch.__version__)"') do set "TORCH_VER=%%V"
    echo   ✓ Môi trường ảo và toàn bộ thư viện AI đã được cài đặt đầy đủ từ trước!
    echo   - Phiên bản PyTorch: %TORCH_VER%
) else (
    if not exist "%PYTHON_EXE%" (
        echo   Đang tạo môi trường ảo độc lập (virtualenv) tại backend\venv...
        %SYS_PYTHON% -m venv "%VENV_DIR%"
    )
    
    echo   Đang nâng cấp pip...
    "%PYTHON_EXE%" -m pip install --upgrade pip setuptools wheel >nul 2>nul
    
    echo   Đang nhận diện phần cứng GPU / CPU...
    set "HAS_CUDA=0"
    where nvidia-smi >nul 2>nul
    if %errorlevel% equ 0 (
        set "HAS_CUDA=1"
        echo   ✓ Đã phát hiện card đồ họa NVIDIA GPU! Đang cài đặt thư viện tăng tốc CUDA 12.4...
        "%PYTHON_EXE%" -m pip install -r "%BACKEND_DIR%\requirements.txt"
    ) else (
        echo   ⚡ Không phát hiện card NVIDIA. Đang cài đặt phiên bản tối ưu cho CPU (dung lượng nhẹ hơn)...
        "%PYTHON_EXE%" -m pip install torch torchaudio --index-url https://download.pytorch.org/whl/cpu
        "%PYTHON_EXE%" -m pip install -r "%BACKEND_DIR%\requirements.txt" --extra-index-url https://download.pytorch.org/whl/cpu
    )
    
    echo   ✓ Đã cài đặt xong toàn bộ thư viện AI!
)

:: ---------------------------------------------------------
:: BƯỚC 4: HOÀN TẤT & KHỞI CHẠY ỨNG DỤNG
:: ---------------------------------------------------------
echo.
echo ========================================================
echo   ✓ HOÀN TẤT THIẾT LẬP OMNIVOICE TTS STUDIO!
echo ========================================================
echo   Đang khởi động hệ thống...
echo.

:: Mở trình duyệt sau 3 giây
start "" "http://localhost:8000"

:: Khởi chạy backend
cd /d "%BACKEND_DIR%"
"%PYTHON_EXE%" -m uvicorn main:app --host 0.0.0.0 --port 8000
