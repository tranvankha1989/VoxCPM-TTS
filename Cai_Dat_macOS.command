#!/usr/bin/env bash
# ================================================================
#  Bộ Cài Đặt Tự Động & Quản Lý Các Bước Cài Đặt OmniVoice TTS (macOS)
#  Tác giả: Tran Van Kha
# ================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

chmod +x "$ROOT_DIR"/*.command 2>/dev/null || true
chmod +x "$ROOT_DIR"/*.sh 2>/dev/null || true

run_step1() {
    bash "$ROOT_DIR/1_Kiem_Tra_Va_Cai_Python.command"
}

run_step2() {
    bash "$ROOT_DIR/2_Cai_Dat_FFmpeg.command"
}

run_step3() {
    bash "$ROOT_DIR/3_Cai_Dat_Thu_Vien_AI.command"
}

run_step4() {
    bash "$ROOT_DIR/4_Tao_Icon_Ung_Dung.command"
}

run_all() {
    echo ""
    echo -e "${GREEN}>>> BẮT ĐẦU QUY TRÌNH CÀI ĐẶT TỰ ĐỘNG (KIỂM TRA TỪNG BƯỚC) <<<${NC}"
    echo ""
    
    echo -e "${BLUE}────────────────────────────────────────${NC}"
    run_step1
    
    echo -e "${BLUE}────────────────────────────────────────${NC}"
    run_step2
    
    echo -e "${BLUE}────────────────────────────────────────${NC}"
    run_step3
    
    echo -e "${BLUE}────────────────────────────────────────${NC}"
    run_step4
}

clear 2>/dev/null || true
echo -e "${BLUE}========================================================${NC}"
echo -e "${BLUE}       CÀI ĐẶT OMNIVOICE TTS STUDIO CHO MACOS           ${NC}"
echo -e "${BLUE}  (Hỗ trợ cả Apple Silicon M1-M4 & Intel Mac / Máy ảo)  ${NC}"
echo -e "${BLUE}========================================================${NC}"
echo ""
echo "Hệ thống đã tách nhỏ các bước cài đặt độc lập."
echo "Mỗi bước đều TỰ ĐỘNG KIỂM TRA, nếu máy đã có sẵn thì sẽ bỏ qua."
echo ""
echo -e "  ${GREEN}[A]${NC} TỰ ĐỘNG CHẠY TẤT CẢ (Khuyên dùng cho người mới)"
echo -e "  ${YELLOW}[1]${NC} Bước 1: Kiểm tra & Cài đặt Python 3.11"
echo -e "  ${YELLOW}[2]${NC} Bước 2: Kiểm tra & Cài đặt FFmpeg (Xử lý âm thanh)"
echo -e "  ${YELLOW}[3]${NC} Bước 3: Thiết lập môi trường ảo & Cài thư viện AI"
echo -e "  ${YELLOW}[4]${NC} Bước 4: Tạo ứng dụng Native OmniVoice TTS.app"
echo -e "  ${RED}[U]${NC} Gỡ cài đặt OmniVoice TTS khỏi máy Mac"
echo -e "  ${RED}[0]${NC} Thoát"
echo ""
read -p "Nhập lựa chọn của bạn [Nhấn Enter chọn A]: " CHOICE
CHOICE=${CHOICE:-A}

case "$CHOICE" in
    1)
        run_step1
        ;;
    2)
        run_step2
        ;;
    3)
        run_step3
        ;;
    4)
        run_step4
        ;;
    [Uu])
        bash "$ROOT_DIR/Go_Cai_Dat_macOS.command"
        ;;
    [Aa])
        run_all
        ;;
    0)
        echo "Tạm biệt!"
        exit 0
        ;;
    *)
        echo -e "${RED}Lựa chọn không hợp lệ, đang chạy toàn bộ quy trình...${NC}"
        run_all
        ;;
esac
