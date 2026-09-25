#!/usr/bin/env bash
# ================================================================
#  Bộ Gỡ Cài Đặt Tự Động OmniVoice TTS Studio cho macOS
#  Tác giả: Tran Van Kha
# ================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

clear 2>/dev/null || true
echo -e "${RED}========================================================${NC}"
echo -e "${RED}       GỠ CÀI ĐẶT OMNIVOICE TTS STUDIO TRÊN MACOS       ${NC}"
echo -e "${RED}========================================================${NC}"
echo ""
echo "Công cụ này sẽ giúp bạn dọn dẹp và gỡ bỏ OmniVoice TTS khỏi máy Mac."
echo ""
echo -e "Vui lòng chọn mức độ gỡ cài đặt:"
echo -e "  ${YELLOW}[1] Gỡ bỏ tiêu chuẩn (Khuyên dùng):${NC}"
echo "      - Dừng các tiến trình server đang chạy ngầm"
echo "      - Xóa ứng dụng /Applications/OmniVoice TTS.app"
echo "      - Xóa biểu tượng lối tắt ngoài màn hình Desktop"
echo "      (Giữ lại môi trường AI và file âm thanh đã tạo)"
echo ""
echo -e "  ${RED}[2] Gỡ bỏ sạch sẽ toàn bộ (Giải phóng dung lượng ổ cứng ~5-8GB):${NC}"
echo "      - Toàn bộ các mục ở lựa chọn [1]"
echo "      - Xóa thư mục môi trường ảo backend/venv"
echo "      - Tùy chọn xóa bộ nhớ đệm cache mô hình AI HuggingFace"
echo ""
echo -e "  ${BLUE}[0] Hủy bỏ và Thoát${NC}"
echo ""
read -p "Nhập lựa chọn của bạn [0/1/2, Mặc định: 0]: " CHOICE
CHOICE=${CHOICE:-0}

if [ "$CHOICE" != "1" ] && [ "$CHOICE" != "2" ]; then
    echo ""
    echo -e "${GREEN}Đã hủy thao tác gỡ cài đặt. Không có thay đổi nào được thực hiện.${NC}"
    exit 0
fi

echo ""
echo -e "${YELLOW}>>> Đang tiến hành gỡ cài đặt...${NC}"

# 1. Dừng các tiến trình đang chạy
echo "1. Đang kiểm tra và đóng các tiến trình OmniVoice đang chạy..."
pkill -f "uvicorn.*main:app.*8000" 2>/dev/null || true
pkill -f "OmniVoice TTS" 2>/dev/null || true
echo -e "   ${GREEN}✓ Đã dừng các tiến trình ngầm.${NC}"

# 2. Xóa biểu tượng Desktop và trong Applications
echo "2. Đang xóa biểu tượng ứng dụng..."
APP_DIR="/Applications/OmniVoice TTS.app"
DESKTOP_SHORTCUT="$HOME/Desktop/OmniVoice TTS.app"

if [ -e "$APP_DIR" ] || [ -d "$APP_DIR" ]; then
    rm -rf "$APP_DIR"
    echo -e "   ${GREEN}✓ Đã gỡ bỏ: $APP_DIR${NC}"
else
    echo -e "   ℹ️ Không tìm thấy: $APP_DIR (Đã xóa từ trước)"
fi

if [ -e "$DESKTOP_SHORTCUT" ] || [ -L "$DESKTOP_SHORTCUT" ]; then
    rm -rf "$DESKTOP_SHORTCUT"
    echo -e "   ${GREEN}✓ Đã xóa lối tắt ngoài Desktop.${NC}"
else
    echo -e "   ℹ️ Không tìm thấy lối tắt ngoài Desktop."
fi

# 3. Nếu chọn mức 2: Gỡ bỏ triệt để
if [ "$CHOICE" = "2" ]; then
    echo "3. Đang dọn dẹp môi trường ảo backend/venv..."
    if [ -d "$ROOT_DIR/backend/venv" ]; then
        rm -rf "$ROOT_DIR/backend/venv"
        echo -e "   ${GREEN}✓ Đã xóa sạch thư mục backend/venv (Giải phóng ~3-5GB).${NC}"
    else
        echo -e "   ℹ️ Không có thư mục backend/venv."
    fi

    echo ""
    read -p "Bạn có muốn xóa cả bộ nhớ đệm Cache tải mô hình AI OmniVoice (~3.8GB) không? (y/N) [Mặc định: N]: " DEL_CACHE
    if [[ "$DEL_CACHE" =~ ^[Yy]$ ]]; then
        HF_CACHE="$HOME/.cache/huggingface/hub/models--k2-fsa--OmniVoice"
        if [ -d "$HF_CACHE" ]; then
            rm -rf "$HF_CACHE"
            echo -e "   ${GREEN}✓ Đã xóa bộ nhớ đệm mô hình tại: $HF_CACHE${NC}"
        else
            echo -e "   ℹ️ Không tìm thấy cache mô hình tại: $HF_CACHE"
        fi
    fi
fi

echo ""
echo -e "${GREEN}========================================================${NC}"
echo -e "${GREEN}✓ QUÁ TRÌNH GỠ CÀI ĐẶT ĐÃ HOÀN TẤT THÀNH CÔNG!          ${NC}"
echo -e "${GREEN}========================================================${NC}"
echo "Ứng dụng OmniVoice TTS đã được gỡ bỏ khỏi hệ thống macOS của bạn."
echo ""
read -p "Nhấn Enter để kết thúc..."
