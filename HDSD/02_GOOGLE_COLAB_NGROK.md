# ☕ HƯỚNG DẪN SỬ DỤNG GPU CLOUD VỚI GOOGLE COLAB + NGROK (DOMAIN TĨNH VĨNH VIỄN)

Phương án này cực kỳ lý tưởng cho những ai sử dụng **laptop văn phòng, máy tính không có card đồ họa NVIDIA rời** hoặc muốn tận dụng sức mạnh của card **NVIDIA Tesla T4 (16GB VRAM)** hoàn toàn miễn phí từ Google.

Đặc biệt, giải pháp kết hợp **Ngrok Static Domain** cho phép bạn **cấu hình file `.env` trên máy đúng 1 lần duy nhất**, những ngày sau chỉ cần bấm nút **Play (▶️)** trên Colab là hệ thống tự động nhận diện và kết nối ngay lập tức!

---

## 1. Đăng Ký Tài Khoản Ngrok & Lấy Thông Tin (Mất 2 phút - Làm 1 lần duy nhất)

Ngrok là dịch vụ tạo đường hầm an toàn (Secure Tunnel) giúp kết nối Google Colab về máy tính của bạn. Ngrok tặng miễn phí cho mỗi tài khoản **1 Domain tĩnh cố định vĩnh viễn**.

### Bước 1.1: Tạo tài khoản Ngrok

1. Truy cập trang đăng ký: [https://dashboard.ngrok.com/signup](https://dashboard.ngrok.com/signup)
2. Bấm chọn **Continue with Google** để đăng nhập trực tiếp bằng tài khoản Gmail.

### Bước 1.2: Lấy Authtoken

1. Ở thanh menu bên trái, nhìn vào nhóm **Getting Started** ➔ Bấm vào **[Your Authtoken](https://dashboard.ngrok.com/get-started/your-authtoken)**.
2. Tại khung hiển thị token, bấm nút **Copy** (Token là một chuỗi ký tự dài, ví dụ: `2tA9xK...`).

### Bước 1.3: Lấy Domain tĩnh miễn phí (Static Domain)

1. Ở menu bên trái, cuộn xuống nhóm **Network** ➔ Bấm vào **[Domains](https://dashboard.ngrok.com/cloud-edge/domains)**.
2. Nếu trang hiển thị sẵn một domain (có chữ `dev domain` hoặc `free domain`), bạn copy tên domain đó.
3. Nếu chưa có, bạn bấm nút **+ New Domain** (hoặc _Create Domain_). Ngrok sẽ cấp cho bạn một domain tĩnh miễn phí dạng:
   `xxxx-xxxx-xxxx.ngrok-free.app` (hoặc `.ngrok-free.dev`).
   _(Ví dụ: `smarty-kenia-lawlessly.ngrok-free.dev`)_.

---

## 2. Cấu Hình File `backend/.env` Trên Máy Bạn (Chỉ Làm 1 Lần)

Mở file `backend/.env` trong thư mục dự án trên máy tính của bạn và chỉnh sửa 2 dòng sau:

```env
# ==============================================================================
# CHẾ ĐỘ MÁY CHỦ GPU TỪ XA (REMOTE WORKER)
# ==============================================================================
USE_REMOTE_GPU=true

# Điền chính xác domain tĩnh từ Bước 1.3 (bắt buộc có https:// ở đầu)
REMOTE_GPU_URL=https://smarty-kenia-lawlessly.ngrok-free.dev
```

> **LƯU Ý:** Thay `smarty-kenia-lawlessly.ngrok-free.dev` bằng chính xác domain của bạn. Lưu file lại. **Từ nay về sau bạn không bao giờ phải mở file `.env` ra sửa lại nữa!**

---

## 3. Khởi Động GPU Worker Trên Google Colab

Mỗi ngày khi muốn làm việc với app, bạn chỉ cần thực hiện 4 bước đơn giản sau trên Colab:

### Bước 3.1: Mở Google Colab và tải sổ tay lên

1. Mở trực tiếp bằng liên kết: [![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/tranvankha1989/VoxCPM-TTS/blob/main/notebooks/OmniVoice_Colab_T4.ipynb)
   * Hoặc truy cập link trực tiếp: [https://colab.research.google.com/github/tranvankha1989/VoxCPM-TTS/blob/main/notebooks/OmniVoice_Colab_T4.ipynb](https://colab.research.google.com/github/tranvankha1989/VoxCPM-TTS/blob/main/notebooks/OmniVoice_Colab_T4.ipynb)
2. Nếu mở thủ công: Truy cập [Google Colab](https://colab.research.google.com/) ➔ Chọn tab **Upload (Tải lên)** ➔ Tải file [OmniVoice_Colab_T4.ipynb](file:///d:/Program%20File/AI/self-tts/notebooks/OmniVoice_Colab_T4.ipynb) trong thư mục `notebooks/` của dự án.

### Bước 3.2: Bật GPU T4

1. Trên thanh menu trên cùng của Colab, chọn: **Runtime (Thời gian chạy)** ➔ **Change runtime type (Thay đổi loại thời gian chạy)**.
2. Tại mục _Hardware accelerator (Phần cứng tăng tốc)_, chọn **T4 GPU**.
3. Bấm nút **Save (Lưu)**.

### Bước 3.3: Nhập cấu hình vào Form

Tại ô code đầu tiên có tiêu đề: **⚡ Khởi Động OmniVoice GPU Worker & Đường Hầm Tunnel**:

- **`TUNNEL_METHOD`**: Chọn `ngrok`
- **`NGROK_AUTHTOKEN`**: Dán mã token lấy ở Bước 1.2
- **`NGROK_STATIC_DOMAIN`**: Dán tên domain lấy ở Bước 1.3 (ví dụ: `smarty-kenia-lawlessly.ngrok-free.dev`)

_(Lưu ý: Không nhập ở bảng Secrets 🔑 bên cột trái mà nhập trực tiếp vào ô form ở giữa màn hình)_.

### Bước 3.4: Bấm Chạy

1. Bấm vào nút hình tròn **Play (▶️)** ở góc trái ô code đó (hoặc bấm `Ctrl + Enter`).
2. Colab sẽ tự động cài đặt thư viện và tải mô hình OmniVoice lên GPU Tesla T4 (chỉ mất 1 - 2 phút).
3. Khi màn hình xuất hiện thông báo màu xanh:
   ```text
   ============================================================
   🚀 NGROK TUNNEL READY: https://smarty-kenia-lawlessly.ngrok-free.dev
   👉 Hãy đảm bảo REMOTE_GPU_URL trong backend/.env khớp với link trên!
   ============================================================
   ```
   👉 **GPU Worker đã sẵn sàng 100%!**

---

## 4. Khởi Động Ứng Dụng Trên Máy Tính Của Bạn

Bây giờ bạn mở 2 terminal trên máy tính để chạy web:

```bash
# Terminal 1: Chạy Backend
cd backend
venv\Scripts\activate
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# Terminal 2: Chạy Frontend
cd frontend
pnpm dev
```

Mở trình duyệt tại `http://localhost:5173`. Mỗi khi bạn bấm tạo âm thanh, Backend sẽ tự động đẩy yêu cầu lên Google Colab T4 xử lý và trả file âm thanh về máy trong vòng 1-2 giây.

---

## 5. Phương Án Dự Phòng: Cloudflare Tunnel (Không Cần Tài Khoản)

Nếu bạn chưa kịp đăng ký tài khoản Ngrok hoặc tài khoản Ngrok gặp sự cố, bạn có thể chuyển sang dùng **Cloudflare Tunnel**:

1. Trên Form Colab, chọn `TUNNEL_METHOD = "cloudflare"`.
2. Để trống ô `NGROK_AUTHTOKEN` và `NGROK_STATIC_DOMAIN`.
3. Bấm **Play (▶️)**. Colab sẽ sinh ra một đường link ngẫu nhiên dạng:
   `https://xxxx-xxxx-xxxx.trycloudflare.com`
4. Copy link đó dán vào `REMOTE_GPU_URL` trong file `backend/.env` là xong.

---

## 6. Mẹo & Những Điều Cần Biết Khi Dùng Google Colab

1. **Thời gian sử dụng:** Google Colab Free cho phép bạn dùng GPU liên tục từ **4 đến 12 tiếng** mỗi ngày.
2. **Khi dùng xong:** Bạn nên vào menu **Runtime ➔ Disconnect and delete runtime (Ngắt kết nối và xóa thời gian chạy)** để bảo toàn hạn mức GPU miễn phí cho ngày hôm sau.
3. **Tránh treo máy:** Giữ tab Google Colab mở trong trình duyệt trong suốt quá trình bạn đang tạo audio để Google không ngắt kết nối vì nhàn rỗi.
