#!/usr/bin/env bash
# ================================================================
#  Bước 4: Tạo ứng dụng Native OmniVoice TTS.app & Lối tắt Desktop
# ================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo -e "${BLUE}========================================================${NC}"
echo -e "${BLUE}   [BƯỚC 4/4] TẠO BIỂU TƯỢNG ỨNG DỤNG (MACOS .APP)       ${NC}"
echo -e "${BLUE}========================================================${NC}"
echo ""

APP_DIR="/Applications/OmniVoice TTS.app"
DESKTOP_SHORTCUT="$HOME/Desktop/OmniVoice TTS.app"

# Đảm bảo các file script chạy được
chmod +x "$ROOT_DIR"/*.command 2>/dev/null || true
chmod +x "$ROOT_DIR"/*.sh 2>/dev/null || true

echo "🚀 Đang tạo ứng dụng native OmniVoice TTS.app..."
rm -rf "$APP_DIR" "$DESKTOP_SHORTCUT"

# Sử dụng osacompile của chính Apple để tạo app bundle chuẩn Mach-O
# Cách này tương thích 100% với macOS Sonoma (macOS 14), Sequoia (macOS 15), không bị lỗi launchd spawn
if command -v osacompile >/dev/null 2>&1; then
    osacompile -o "$APP_DIR" -e 'tell application "Terminal"
        activate
        do script "cd \"'"$ROOT_DIR"'\" && ./start.command"
    end tell'
else
    # Fallback thủ công nếu không có osacompile
    mkdir -p "$APP_DIR/Contents/MacOS"
    mkdir -p "$APP_DIR/Contents/Resources"
    cat << EOF > "$APP_DIR/Contents/MacOS/launcher"
#!/usr/bin/env bash
cd "$ROOT_DIR"
(sleep 2 && open "http://localhost:8000") &
exec "$ROOT_DIR/backend/venv/bin/python" -m uvicorn main:app --host 0.0.0.0 --port 8000 --app-dir "$ROOT_DIR/backend"
EOF
    chmod +x "$APP_DIR/Contents/MacOS/launcher"
fi

# Tạo Icon chuẩn macOS (.icns) từ file png
if [ -f "$ROOT_DIR/assets/app.png" ] && command -v sips >/dev/null 2>&1 && command -v iconutil >/dev/null 2>&1; then
    ICONSET_DIR="/tmp/app_$$.iconset"
    mkdir -p "$ICONSET_DIR"
    sips -z 16 16     "$ROOT_DIR/assets/app.png" --out "$ICONSET_DIR/icon_16x16.png" >/dev/null 2>&1 || true
    sips -z 32 32     "$ROOT_DIR/assets/app.png" --out "$ICONSET_DIR/icon_16x16@2x.png" >/dev/null 2>&1 || true
    sips -z 32 32     "$ROOT_DIR/assets/app.png" --out "$ICONSET_DIR/icon_32x32.png" >/dev/null 2>&1 || true
    sips -z 64 64     "$ROOT_DIR/assets/app.png" --out "$ICONSET_DIR/icon_32x32@2x.png" >/dev/null 2>&1 || true
    sips -z 128 128   "$ROOT_DIR/assets/app.png" --out "$ICONSET_DIR/icon_128x128.png" >/dev/null 2>&1 || true
    sips -z 256 256   "$ROOT_DIR/assets/app.png" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null 2>&1 || true
    sips -z 256 256   "$ROOT_DIR/assets/app.png" --out "$ICONSET_DIR/icon_256x256.png" >/dev/null 2>&1 || true
    sips -z 512 512   "$ROOT_DIR/assets/app.png" --out "$ICONSET_DIR/icon_256x256@2x.png" >/dev/null 2>&1 || true
    sips -z 512 512   "$ROOT_DIR/assets/app.png" --out "$ICONSET_DIR/icon_512x512.png" >/dev/null 2>&1 || true
    sips -z 1024 1024 "$ROOT_DIR/assets/app.png" --out "$ICONSET_DIR/icon_512x512@2x.png" >/dev/null 2>&1 || true
    
    iconutil -c icns "$ICONSET_DIR" -o "$APP_DIR/Contents/Resources/applet.icns" 2>/dev/null || true
    cp "$APP_DIR/Contents/Resources/applet.icns" "$APP_DIR/Contents/Resources/app.icns" 2>/dev/null || true
    rm -rf "$ICONSET_DIR"
fi

# Gỡ bỏ cờ kiểm dịch của macOS và ký số nội bộ (ad-hoc codesign)
xattr -cr "$APP_DIR" 2>/dev/null || true
if command -v codesign >/dev/null 2>&1; then
    codesign --force --deep --sign - "$APP_DIR" 2>/dev/null || true
fi

# Tạo shortcut ra ngoài Desktop
ln -s "$APP_DIR" "$DESKTOP_SHORTCUT"

echo ""
echo -e "${GREEN}========================================================${NC}"
echo -e "${GREEN}✓ ĐÃ TẠO THÀNH CÔNG ỨNG DỤNG NATIVE CHO MACOS!          ${NC}"
echo -e "${GREEN}========================================================${NC}"
echo -e "✓ Ứng dụng đã thêm vào : ${BLUE}/Applications/OmniVoice TTS.app${NC}"
echo -e "✓ Lối tắt ngoài        : ${BLUE}Màn hình Desktop${NC}"
echo ""
echo -e "💡 ${YELLOW}MẸO:${NC} Ngoài ra, bạn cũng có thể mở nhanh ứng dụng bằng cách"
echo -e "nhấp đúp trực tiếp vào file: ${BLUE}$ROOT_DIR/start.command${NC}"
echo ""
read -p "Nhấn Enter để mở ứng dụng ngay..."
open "$APP_DIR" || bash "$ROOT_DIR/start.command"
