import os
from pathlib import Path
from fastapi import APIRouter, HTTPException
from fastapi.responses import FileResponse

from app.core.config import OUTPUTS_DIR
from app.schemas.common import HealthResponse

router = APIRouter(tags=["System"])


@router.get(
    "/api/health",
    response_model=HealthResponse,
    summary="Kiểm tra trạng thái máy chủ và mô hình",
)
@router.get(
    "/health",
    response_model=HealthResponse,
    summary="Kiểm tra trạng thái máy chủ và mô hình (hỗ trợ Tray Manager)",
)
async def health_check():
    """Kiểm tra server đang hoạt động và OmniVoice đã sẵn sàng (local Model nạp xong HOẶC Remote GPU online)."""
    import model_handler
    is_ready = model_handler.is_system_ai_ready()
    return HealthResponse(
        status="ok",
        model_loaded=is_ready,
    )


@router.get(
    "/api/download/{filename}",
    summary="Tải trực tiếp file âm thanh",
)
async def download_file(filename: str):
    """
    Tải file âm thanh (mp3/wav) về máy từ thư mục outputs/.
    Header Content-Disposition: attachment sẽ kích hoạt popup lưu file trên trình duyệt.
    """
    safe_filename = os.path.basename(filename)
    file_path = OUTPUTS_DIR / safe_filename

    if not file_path.exists() or not file_path.is_file():
        raise HTTPException(status_code=404, detail="File không tồn tại")

    ext = file_path.suffix.lower()
    media_types = {
        ".mp3": "audio/mpeg",
        ".wav": "audio/wav",
        ".ogg": "audio/ogg",
        ".m4a": "audio/mp4",
        ".srt": "text/plain; charset=utf-8",
    }
    media_type = media_types.get(ext, "application/octet-stream")

    return FileResponse(
        path=str(file_path),
        media_type=media_type,
        filename=safe_filename,
    )


@router.get(
    "/api/tts/engines",
    summary="Danh sách các mô hình TTS được hỗ trợ",
    tags=["TTS"],
)
@router.get(
    "/api/engines",
    summary="Danh sách các mô hình TTS (alias)",
    tags=["TTS"],
)
async def get_tts_engines():
    """Trả về danh sách các engine TTS khả dụng trong hệ thống."""
    return [
        {
            "id": "omnivoice",
            "name": "OmniVoice 24kHz",
            "tagline": "Đa năng & Tự thiết kế giọng",
            "provider": "k2-fsa",
            "sample_rate": 24000,
            "supported_modes": ["clone", "design", "auto"],
            "description": "Mô hình đa năng hỗ trợ cả sao chép giọng mẫu và tự thiết kế độ tuổi, giới tính, phong cách qua prompt.",
        },
    ]
