#!/usr/bin/env bash
# ================================================================
#  Bộ Cài Đặt Tự Động 1-Click OmniVoice TTS cho macOS (Apple Silicon & Intel)
#  Tác giả: Tran Van Kha
# ================================================================

set -e

# Màu sắc thông báo
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo -e "${BLUE}========================================================${NC}"
echo -e "${BLUE}       CÀI ĐẶT OMNIVOICE TTS STUDIO CHO MACOS           ${NC}"
echo -e "${BLUE}========================================================${NC}"
echo ""

# 1. Kiểm tra Python 3
echo -e "${YELLOW}[1/4] Kiểm tra môi trường Python trên macOS...${NC}"
if command -v python3 >/dev/null 2>&1; then
    PY_VER=$(python3 --version)
    echo -e "${GREEN}✓ Đã tìm thấy: $PY_VER${NC}"
else
    echo -e "${RED}Chưa tìm thấy Python 3! Đang cài đặt thông qua Homebrew...${NC}"
    if ! command -v brew >/dev/null 2>&1; then
        echo -e "${YELLOW}Đang cài đặt Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install python@3.11
fi

# 2. Tạo Virtualenv và cài đặt thư viện
echo ""
echo -e "${YELLOW}[2/4] Thiết lập môi trường ảo và cài đặt thư viện AI...${NC}"
if [ ! -d "backend/venv" ]; then
    python3 -m venv backend/venv
fi

source backend/venv/bin/activate
pip install --upgrade pip
pip install -r backend/requirements.txt

# 3. Tạo Ứng Dụng Mac Native (OmniVoice TTS.app)
echo ""
echo -e "${YELLOW}[3/4] Đang tạo ứng dụng native OmniVoice TTS.app cho macOS...${NC}"
APP_DIR="/Applications/OmniVoice TTS.app"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Ghi file Info.plist
cat << 'EOF' > "$APP_DIR/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>launcher</string>
    <key>CFBundleIdentifier</key>
    <string>com.tranvankha.omnivoice</string>
    <key>CFBundleName</key>
    <string>OmniVoice TTS</string>
    <key>CFBundleIconFile</key>
    <string>app.icns</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>2.2.0</string>
</dict>
</plist>
EOF

# Ghi file thực thi launcher
cat << EOF > "$APP_DIR/Contents/MacOS/launcher"
#!/usr/bin/env bash
cd "$ROOT_DIR"
source backend/venv/bin/activate

# Mở trình duyệt sau 2 giây
(sleep 2 && open "http://localhost:8000") &

# Chạy server FastAPI
exec python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 --app-dir "$ROOT_DIR/backend"
EOF

chmod +x "$APP_DIR/Contents/MacOS/launcher"

# Sao chép icon nếu có
if [ -f "$ROOT_DIR/assets/app.png" ]; then
    cp "$ROOT_DIR/assets/app.png" "$APP_DIR/Contents/Resources/app.png" 2>/dev/null || true
fi

# Tạo shortcut ngoài màn hình Desktop của Mac
DESKTOP_SHORTCUT="$HOME/Desktop/OmniVoice TTS.app"
rm -rf "$DESKTOP_SHORTCUT"
ln -s "$APP_DIR" "$DESKTOP_SHORTCUT"

echo ""
echo -e "${GREEN}========================================================${NC}"
echo -e "${GREEN}[4/4] CÀI ĐẶT HOÀN TẤT THÀNH CÔNG TRÊN MACOS!          ${NC}"
echo -e "${GREEN}========================================================${NC}"
echo -e "✓ Ứng dụng đã được thêm vào: ${BLUE}/Applications/OmniVoice TTS.app${NC}"
echo -e "✓ Lối tắt đã tạo ngoài:      ${BLUE}Desktop (Màn hình chính)${NC}"
echo -e "Từ nay bạn chỉ cần bấm vào icon OmniVoice TTS để sử dụng!"
echo ""
read -p "Nhấn Enter để mở ứng dụng ngay..."
open "$APP_DIR"
