#!/usr/bin/env bash
# ===================================================
#  OmniVoice TTS Launcher for macOS / Linux
# ===================================================

set -e
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo "==================================================="
echo "       Khởi động hệ thống OmniVoice TTS (macOS)"
echo "==================================================="
echo ""
echo "  - Backend AI : http://localhost:8000"
echo "  - Giao diện  : http://localhost:5173"
echo ""
echo "Nhấn Ctrl+C để dừng toàn bộ hệ thống."
echo "==================================================="

# Kiểm tra môi trường Python
if [ ! -d "backend/venv" ]; then
    echo "📦 Đang tạo virtualenv cho Backend..."
    python3 -m venv backend/venv
    source backend/venv/bin/activate
    pip install --upgrade pip
    pip install -r backend/requirements.txt
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
  "cd \"$ROOT_DIR/backend\" && python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload" \
  "pnpm dev"
