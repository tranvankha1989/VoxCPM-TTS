#!/usr/bin/env bash
# ===================================================
#  OmniVoice TTS Launcher for macOS / Linux
# ===================================================

set -e
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo "==================================================="
echo "       Khởi động hệ thống OmniVoice TTS"
echo "==================================================="
echo ""
echo "  - Backend AI : http://localhost:8000"
echo "  - Giao diện  : http://localhost:5173"
echo ""
echo "Nhấn Ctrl+C để dừng toàn bộ hệ thống."
echo "==================================================="

# Hàm tìm Python >= 3.10
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

# Kiểm tra môi trường Python
if [ -d "backend/venv" ]; then
    CURRENT_VENV_VER=$(backend/venv/bin/python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null || echo "0.0")
    V_MAJ=$(echo "$CURRENT_VENV_VER" | cut -d. -f1)
    V_MIN=$(echo "$CURRENT_VENV_VER" | cut -d. -f2)
    if [ "$V_MAJ" -lt 3 ] || [ "$V_MIN" -lt 10 ]; then
        echo "⚠️ Virtualenv cũ sử dụng Python $CURRENT_VENV_VER (< 3.10). Đang tạo lại..."
        rm -rf backend/venv
    fi
fi

if [ ! -d "backend/venv" ]; then
    PY_CMD=$(find_compatible_python || true)
    if [ -z "$PY_CMD" ]; then
        echo "❌ Cần Python >= 3.10 để chạy OmniVoice AI!"
        echo "Vui lòng chạy file ./Cai_Dat_macOS.command trước để cài đặt đầy đủ."
        exit 1
    fi
    echo "📦 Đang tạo virtualenv cho Backend với $PY_CMD..."
    "$PY_CMD" -m venv backend/venv
    source backend/venv/bin/activate
    pip install --upgrade pip setuptools wheel
    ARCH=$(uname -m)
    if [ "$ARCH" = "arm64" ]; then
        pip install "torch>=2.4.0" "torchaudio>=2.4.0"
        pip install "omnivoice>=0.2.1"
    else
        pip install "torch==2.2.2" "torchaudio==2.2.2"
        pip install "omnivoice>=0.2.1" --no-deps
    fi
    if [ -f "backend/requirements-mac.txt" ]; then
        pip install -r backend/requirements-mac.txt
    else
        pip install -r backend/requirements.txt
    fi
else
    source backend/venv/bin/activate
fi

# Mở trình duyệt sau 3 giây (hỗ trợ lệnh open của macOS)
(
    sleep 3
    if command -v open > /dev/null; then
        open http://localhost:5173
    elif command -v xdg-open > /dev/null; then
        xdg-open http://localhost:5173
    fi
) &

# Khởi chạy đồng thời Backend và Frontend
cd "$ROOT_DIR/frontend"
pnpm exec concurrently --kill-others-on-fail \
  --names "BACKEND,FRONTEND" \
  --prefix-colors "blue,magenta" \
  "cd \"$ROOT_DIR/backend\" && \"$ROOT_DIR/backend/venv/bin/python\" -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload" \
  "pnpm dev"
