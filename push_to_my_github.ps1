# Script day toan bo du an len GitHub
$projectDir = (Get-Item $PSScriptRoot).FullName
Set-Location $projectDir

Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host "  DANG DAY TOAN BO DU AN LEN GITHUB:" -ForegroundColor Cyan
Write-Host "  https://github.com/tranvankha1989/VoxCPM-TTS-tts.git" -ForegroundColor Cyan
Write-Host "===================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Neu trinh duyet bat len hop thoai dang nhap GitHub, ban chi can" -ForegroundColor Yellow
Write-Host "bam nut: 'Sign in with your browser' de xac nhan 1 lan duy nhat." -ForegroundColor Yellow
Write-Host ""

git push -u origin main --force

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "===================================================================" -ForegroundColor Green
    Write-Host "  [THANH CONG 100%] Toan bo ma nguon da duoc day len GitHub:" -ForegroundColor Green
    Write-Host "  https://github.com/tranvankha1989/VoxCPM-TTS-tts" -ForegroundColor Green
    Write-Host "===================================================================" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "===================================================================" -ForegroundColor Red
    Write-Host "  [THAT BAI] Khong the day len GitHub!" -ForegroundColor Red
    Write-Host "  Vui long kiem tra quyen truy cap hoac xac nhan dang nhap tren trinh duyet." -ForegroundColor Red
    Write-Host "===================================================================" -ForegroundColor Red
}

Write-Host ""
Write-Host "Nhan phim bat ky de thoat..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
