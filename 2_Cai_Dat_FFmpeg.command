#!/usr/bin/env bash
# ================================================================
#  Bước 2: Kiểm tra & Cài đặt FFmpeg cho macOS
#  (Cần thiết để xuất âm thanh MP3/WAV và chạy Auto Caption Whisper)
# ================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo -e "${BLUE}========================================================${NC}"
echo -e "${BLUE}   [BƯỚC 2/4] KIỂM TRA & CÀI ĐẶT FFMPEG (MACOS)         ${NC}"
echo -e "${BLUE}========================================================${NC}"
echo ""

find_ffmpeg() {
    for cmd in \
        ffmpeg \
        /opt/homebrew/bin/ffmpeg \
        /usr/local/bin/ffmpeg \
        "$ROOT_DIR/backend/ffmpeg"
    do
        if command -v "$cmd" >/dev/null 2>&1 || [ -x "$cmd" ]; then
            echo "$cmd"
            return 0
        fi
    done
    return 1
}

echo "🔍 Đang kiểm tra FFmpeg trên macOS..."
FFMPEG_CMD=$(find_ffmpeg || true)

if [ -n "$FFMPEG_CMD" ]; then
    FF_VER=$("$FFMPEG_CMD" -version 2>/dev/null | head -n 1)
    echo ""
    echo -e "${GREEN}✓ MÁY ĐÃ CÓ SẴN FFMPEG!${NC}"
    echo -e "  - Thông tin : ${GREEN}$FF_VER${NC}"
    echo -e "  - Đường dẫn : ${BLUE}$FFMPEG_CMD${NC}"
    echo ""
    echo -e "${GREEN}🎉 Bước 2 đã hoàn tất! Bạn không cần phải cài đặt lại FFmpeg.${NC}"
    echo -e "👉 Bạn có thể chuyển sang Bước 3 (Cài thư viện AI)."
else
    echo -e "${YELLOW}⚠️ Chưa tìm thấy công cụ FFmpeg trên hệ thống.${NC}"
    echo -e "FFmpeg là công cụ chuyển đổi định dạng âm thanh (MP3, WAV) và trích xuất phụ đề tự động."
    echo ""

    BREW_CMD=""
    if command -v brew >/dev/null 2>&1; then
        BREW_CMD="brew"
    elif [ -x "/opt/homebrew/bin/brew" ]; then
        BREW_CMD="/opt/homebrew/bin/brew"
    elif [ -x "/usr/local/bin/brew" ]; then
        BREW_CMD="/usr/local/bin/brew"
    fi

    if [ -n "$BREW_CMD" ]; then
        echo -e "${YELLOW}Đang cài đặt FFmpeg tự động thông qua Homebrew...${NC}"
        "$BREW_CMD" install ffmpeg
    else
        echo -e "${YELLOW}Đang tải bản dựng FFmpeg static cho macOS...${NC}"
        mkdir -p /tmp/ffmpeg_dl
        # Tải static binary ffmpeg cho macOS
        curl -L -o /tmp/ffmpeg_dl/ffmpeg.zip "https://evermeet.cx/ffmpeg/getrelease/zip" 2>/dev/null || true
        if [ -f /tmp/ffmpeg_dl/ffmpeg.zip ]; then
            unzip -o -q /tmp/ffmpeg_dl/ffmpeg.zip -d "$ROOT_DIR/backend" 2>/dev/null || true
            chmod +x "$ROOT_DIR/backend/ffmpeg" 2>/dev/null || true
            rm -rf /tmp/ffmpeg_dl
        fi
    fi

    FFMPEG_CMD=$(find_ffmpeg || true)
    if [ -n "$FFMPEG_CMD" ]; then
        echo ""
        echo -e "${GREEN}✓ CÀI ĐẶT FFMPEG THÀNH CÔNG!${NC}"
    else
        echo ""
        echo -e "${YELLOW}ℹ️  Lưu ý: Nếu chưa có Homebrew, bạn có thể cài FFmpeg bằng lệnh: brew install ffmpeg${NC}"
        echo -e "Hoặc hệ thống vẫn có thể sử dụng các thư viện audio Python chuẩn (soundfile, librosa)."
    fi
fi

echo ""
read -p "Nhấn Enter để kết thúc bước 2..."
