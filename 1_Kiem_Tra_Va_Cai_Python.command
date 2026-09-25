#!/usr/bin/env bash
# ================================================================
#  Bước 1: Kiểm tra & Cài đặt Python 3.11 cho macOS
# ================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo -e "${BLUE}========================================================${NC}"
echo -e "${BLUE}   [BƯỚC 1/4] KIỂM TRA & CÀI ĐẶT PYTHON 3.11 (MACOS)    ${NC}"
echo -e "${BLUE}========================================================${NC}"
echo ""

find_compatible_python() {
    for cmd in \
        python3.11 \
        python3.10 \
        python3.12 \
        /opt/homebrew/bin/python3.11 \
        /opt/homebrew/bin/python3.10 \
        /opt/homebrew/bin/python3 \
        /usr/local/bin/python3.11 \
        /usr/local/bin/python3.10 \
        /usr/local/bin/python3 \
        /Library/Frameworks/Python.framework/Versions/3.11/bin/python3 \
        /Library/Frameworks/Python.framework/Versions/3.10/bin/python3 \
        python3
    do
        if command -v "$cmd" >/dev/null 2>&1 || [ -x "$cmd" ]; then
            local ver
            ver=$("$cmd" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null || true)
            local major=$(echo "$ver" | cut -d. -f1)
            local minor=$(echo "$ver" | cut -d. -f2)
            if [ "$major" -eq 3 ] && [ "$minor" -ge 10 ] && [ "$minor" -le 12 ]; then
                echo "$cmd"
                return 0
            fi
        fi
    done
    return 1
}

echo "🔍 Đang kiểm tra phiên bản Python trên máy..."
PY_CMD=$(find_compatible_python || true)

if [ -n "$PY_CMD" ]; then
    PY_VER=$("$PY_CMD" --version)
    echo ""
    echo -e "${GREEN}✓ MÁY ĐÃ CÓ SẴN PYTHON PHÙ HỢP!${NC}"
    echo -e "  - Phiên bản : ${GREEN}$PY_VER${NC}"
    echo -e "  - Đường dẫn : ${BLUE}$PY_CMD${NC}"
    echo ""
    echo -e "${GREEN}🎉 Bước 1 đã hoàn tất! Bạn không cần phải cài đặt lại Python.${NC}"
    echo -e "👉 Bạn có thể chuyển sang Bước 2 hoặc Bước 3."
else
    SYS_VER=$(python3 --version 2>/dev/null || echo "Chưa có")
    echo -e "${YELLOW}⚠️  Phiên bản hiện tại ($SYS_VER) không tương thích!${NC}"
    echo -e "${YELLOW}Mô hình AI OmniVoice yêu cầu Python >= 3.10 (khuyên dùng Python 3.11).${NC}"
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
        echo -e "${YELLOW}Đang cài đặt Python 3.11 qua Homebrew...${NC}"
        "$BREW_CMD" install python@3.11
    else
        echo -e "${YELLOW}Đang tải bộ cài đặt Python 3.11 chính thức (.pkg) từ python.org...${NC}"
        PKG_PATH="/tmp/python-3.11.9-macos11.pkg"
        curl -L -o "$PKG_PATH" "https://www.python.org/ftp/python/3.11.9/python-3.11.9-macos11.pkg"
        
        echo -e "${GREEN}✓ Đã tải xong! Đang mở trình cài đặt...${NC}"
        echo -e "${YELLOW}👉 Vui lòng nhấn 'Tiếp tục' (Continue) và 'Cài đặt' (Install) trên cửa sổ vừa hiện ra.${NC}"
        open -W "$PKG_PATH"
        rm -f "$PKG_PATH"
    fi

    PY_CMD=$(find_compatible_python || true)
    if [ -z "$PY_CMD" ]; then
        echo -e "${RED}[ERROR] Vẫn chưa tìm thấy Python >= 3.10 sau khi cài đặt.${NC}"
        echo -e "Vui lòng kiểm tra lại quá trình cài đặt Python."
        exit 1
    fi
    PY_VER=$("$PY_CMD" --version)
    echo ""
    echo -e "${GREEN}✓ CÀI ĐẶT THÀNH CÔNG: $PY_VER${NC}"
fi

echo ""
read -p "Nhấn Enter để kết thúc bước 1..."
