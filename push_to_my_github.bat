@echo off
chcp 65001 >nul
title Day code de len GitHub (tranvankha1989/self-tts)
cd /d "%~dp0"

echo ===================================================================
echo   DANG DAY TOAN BO DU AN DE LEN GITHUB CUA BAN:
echo   https://github.com/tranvankha1989/self-tts.git
echo ===================================================================
echo.
echo Neu trinh duyet bat len hop thoai dang nhap GitHub, ban chi can
echo bam nut: "Sign in with your browser" de xac nhan 1 lan duy nhat.
echo.

git push -u origin main --force

echo.
if %errorlevel% equ 0 (
    echo ===================================================================
    echo   🎉 THANH CONG 100%!
    echo   Toan bo ma nguon da duoc day va ghi de len GitHub cua ban:
    echo   👉 https://github.com/tranvankha1989/self-tts
    echo ===================================================================
) else (
    echo ===================================================================
    echo   ❌ CO LOI XAY RA:
    echo   1. Hay kiem tra xem ban da tao repo 'self-tts' tren GitHub chua.
    echo   2. Xac nhan dang nhap tren trinh duyet neu duoc hoi.
    echo ===================================================================
)
echo.
pause
