@echo off
setlocal
cd /d "%~dp0"

echo ===================================================================
echo   DANG DAY TOAN BO DU AN LEN GITHUB:
echo   https://github.com/tranvankha1989/self-tts.git
echo ===================================================================
echo.
echo Neu trinh duyet bat len hop thoai dang nhap GitHub, ban chi can
echo bam nut: "Sign in with your browser" de xac nhan.
echo.

git push -u origin main --force

if errorlevel 1 (
    echo.
    echo ===================================================================
    echo   [THAT BAI] CHUA THE DAY LEN GITHUB!
    echo   1. Hay kiem tra xem ban da dang nhap GitHub tren trinh duyet chua.
    echo   2. Kiem tra lai ket noi mang va repo tren GitHub.
    echo ===================================================================
) else (
    echo.
    echo ===================================================================
    echo   [THANH CONG 100%%]
    echo   Toan bo ma nguon da duoc day len GitHub cua ban:
    echo   https://github.com/tranvankha1989/self-tts
    echo ===================================================================
)

echo.
pause
