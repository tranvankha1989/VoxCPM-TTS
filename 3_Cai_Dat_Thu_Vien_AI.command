#!/usr/bin/env bash
# ================================================================
#  Bước 3: Thiết lập môi trường ảo & Cài đặt thư viện AI cho macOS
#  (Tự động hỗ trợ tối ưu cả Apple Silicon M1-M4 & Intel x86_64)
# ================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo -e "${BLUE}========================================================${NC}"
echo -e "${BLUE}   [BƯỚC 3/4] THIẾT LẬP MÔI TRƯỜNG & THƯ VIỆN AI        ${NC}"
echo -e "${BLUE}========================================================${NC}"
echo ""

# 1. Tìm Python phù hợp
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

PY_CMD=$(find_compatible_python || true)

if [ -z "$PY_CMD" ]; then
    echo -e "${RED}❌ Chưa tìm thấy Python >= 3.10 trên máy!${NC}"
    echo -e "👉 Vui lòng chạy file ${YELLOW}1_Kiem_Tra_Va_Cai_Python.command${NC} trước để cài đặt Python 3.11."
    echo ""
    read -p "Nhấn Enter để thoát..."
    exit 1
fi

echo -e "🔍 Sử dụng Python: ${BLUE}$PY_CMD${NC} ($($PY_CMD --version))"

# 2. Kiểm tra virtualenv hiện có
if [ -d "backend/venv" ]; then
    CURRENT_VENV_VER=$(backend/venv/bin/python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null || echo "0.0")
    V_MAJ=$(echo "$CURRENT_VENV_VER" | cut -d. -f1)
    V_MIN=$(echo "$CURRENT_VENV_VER" | cut -d. -f2)
    if [ "$V_MAJ" -lt 3 ] || [ "$V_MIN" -lt 10 ]; then
        echo -e "${YELLOW}⚠️ Virtualenv cũ sử dụng Python $CURRENT_VENV_VER (< 3.10). Đang làm mới virtualenv...${NC}"
        rm -rf backend/venv
    fi
fi

# 3. Kiểm tra xem thư viện AI đã được cài đặt đầy đủ chưa
IS_INSTALLED=false
if [ -d "backend/venv" ]; then
    source backend/venv/bin/activate
    if python -c "import torch, torchaudio, omnivoice, fastapi, soundfile" 2>/dev/null; then
        IS_INSTALLED=true
    fi
fi

if [ "$IS_INSTALLED" = true ]; then
    TORCH_VER=$(python -c "import torch; print(torch.__version__)")
    OMNI_VER=$(python -c "import omnivoice; print(getattr(omnivoice, '__version__', '0.2.1'))")
    DEV_TYPE=$(python -c 'import torch; print("Apple Metal (MPS GPU)" if hasattr(torch.backends, "mps") and torch.backends.mps.is_available() else "CPU")')
    
    echo ""
    echo -e "${GREEN}✓ MÁY ĐÃ CÀI ĐẶT ĐẦY ĐỦ TẤT CẢ CÁC THƯ VIỆN AI TỪ TRƯỚC!${NC}"
    echo -e "  - PyTorch   : ${GREEN}$TORCH_VER${NC}"
    echo -e "  - OmniVoice : ${GREEN}$OMNI_VER${NC}"
    echo -e "  - Thiết bị  : ${BLUE}$DEV_TYPE${NC}"
    echo ""
    read -p "Bạn có muốn cài đặt đè / cập nhật lại không? (y/N) [Mặc định: N]: " REINSTALL
    if [[ ! "$REINSTALL" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}🎉 Bước 3 đã hoàn tất! Chuyển sang Bước 4 (Tạo ứng dụng .app).${NC}"
        echo ""
        read -p "Nhấn Enter để kết thúc..."
        exit 0
    fi
fi

# 4. Tiến hành tạo venv & cài đặt thư viện
if [ ! -d "backend/venv" ]; then
    echo "📦 Đang khởi tạo môi trường ảo (virtualenv) tại backend/venv..."
    "$PY_CMD" -m venv backend/venv
fi

source backend/venv/bin/activate
echo "Đang nâng cấp pip, setuptools, wheel..."
pip install --upgrade pip setuptools wheel

# 5. Nhận diện kiến trúc CPU
ARCH=$(uname -m)
echo ""
echo -e "🖥️  Nhận diện kiến trúc vi xử lý macOS: ${BLUE}$ARCH${NC}"

if [ "$ARCH" = "arm64" ]; then
    echo -e "${GREEN}🍎 Kiến trúc: Apple Silicon (M1/M2/M3/M4 - ARM64)${NC}"
    echo "Đang cài đặt PyTorch phiên bản mới hỗ trợ Apple Metal GPU (MPS)..."
    pip install "torch>=2.4.0" "torchaudio>=2.4.0"
    pip install "omnivoice>=0.2.1"
else
    echo -e "${YELLOW}⚡ Kiến trúc: Intel x86_64 (Intel Mac hoặc Giả lập macOS)${NC}"
    echo "Đang cài đặt PyTorch phiên bản tương thích tối ưu cho chip Intel macOS..."
    pip install "torch==2.2.2" "torchaudio==2.2.2"
    pip install "omnivoice>=0.2.1" --no-deps
fi

if [ -f "backend/requirements-mac.txt" ]; then
    echo "Cài đặt các gói thư viện bổ trợ cho macOS..."
    pip install -r backend/requirements-mac.txt
else
    echo "Cài đặt thư viện từ requirements.txt..."
    pip install -r backend/requirements.txt
fi

# 6. Kiểm tra lại sau khi cài
echo ""
echo "🔍 Đang kiểm tra tính hợp lệ của các thư viện..."
if python -c "import torch, torchaudio, omnivoice, fastapi, soundfile" 2>/dev/null; then
    TORCH_VER=$(python -c "import torch; print(torch.__version__)")
    echo -e "${GREEN}✓ KIỂM TRA THÀNH CÔNG! Toàn bộ thư viện AI đã sẵn sàng hoạt động.${NC}"
    echo -e "  - PyTorch: $TORCH_VER"
else
    echo -e "${YELLOW}⚠️ Đã hoàn tất cài đặt. Vui lòng kiểm tra log nếu có lỗi phát sinh.${NC}"
fi

echo ""
read -p "Nhấn Enter để kết thúc bước 3..."
