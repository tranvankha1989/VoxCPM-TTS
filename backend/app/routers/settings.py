import os
import re
import time
import httpx
from pathlib import Path
from typing import Optional
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv

import model_handler
from app.core.config import BASE_DIR, logger

router = APIRouter(prefix="/api/settings", tags=["Settings"])

ENV_FILE = BASE_DIR / ".env"


class HardwareSettingsResponse(BaseModel):
    use_remote_gpu: bool
    remote_gpu_url: str
    remote_concurrency: int = 2
    colab_notebook_url: Optional[str] = "https://colab.research.google.com/drive/1QK4hoFRklcGQpgUkU_YNcDidA5y5kzgO"
    local_device: str
    cuda_available: bool
    cuda_device_name: Optional[str] = None
    cuda_vram_gb: Optional[float] = None


class UpdateHardwareSettingsRequest(BaseModel):
    use_remote_gpu: bool
    remote_gpu_url: str
    remote_concurrency: Optional[int] = 2
    colab_notebook_url: Optional[str] = None


class TestRemoteGpuRequest(BaseModel):
    remote_gpu_url: str


class TestRemoteGpuResponse(BaseModel):
    ok: bool
    gpu_name: Optional[str] = None
    vram_total_gb: Optional[float] = None
    provider: Optional[str] = None
    ping_ms: Optional[int] = None
    error: Optional[str] = None


def _update_env_file(updates: dict[str, str]) -> None:
    """Cập nhật các biến trong file .env an toàn mà không làm mất comment hay cấu trúc khác."""
    env_path = ENV_FILE
    content = ""
    if env_path.exists():
        try:
            content = env_path.read_text(encoding="utf-8")
        except Exception:
            content = env_path.read_text(encoding="latin-1")

    for key, val in updates.items():
        pattern = rf"^{re.escape(key)}=.*$"
        replacement = f"{key}={val}"
        if re.search(pattern, content, flags=re.MULTILINE):
            content = re.sub(pattern, replacement, content, flags=re.MULTILINE)
        else:
            if content and not content.endswith("\n"):
                content += "\n"
            content += f"{replacement}\n"

    env_path.write_text(content, encoding="utf-8")
    load_dotenv(env_path, override=True)


@router.get("/hardware", response_model=HardwareSettingsResponse, summary="Lấy cấu hình phần cứng hiện tại")
async def get_hardware_settings():
    load_dotenv(ENV_FILE, override=True)
    use_remote = model_handler.is_remote_gpu_enabled()
    remote_url = model_handler.get_remote_gpu_url()
    remote_concurrency = int(os.getenv("REMOTE_CONCURRENCY", "2"))
    colab_url = os.getenv("COLAB_NOTEBOOK_URL", "https://colab.research.google.com/drive/1QK4hoFRklcGQpgUkU_YNcDidA5y5kzgO").strip()

    # pyrefly: ignore [missing-import]
    import torch
    cuda_ok = torch.cuda.is_available()
    dev_name = torch.cuda.get_device_name(0) if cuda_ok else None
    vram_gb = round(torch.cuda.get_device_properties(0).total_memory / (1024**3), 2) if cuda_ok else None
    local_dev = "cuda" if cuda_ok else "cpu"

    return HardwareSettingsResponse(
        use_remote_gpu=use_remote,
        remote_gpu_url=remote_url,
        remote_concurrency=remote_concurrency,
        colab_notebook_url=colab_url,
        local_device=local_dev,
        cuda_available=cuda_ok,
        cuda_device_name=dev_name,
        cuda_vram_gb=vram_gb,
    )


@router.post("/hardware", response_model=HardwareSettingsResponse, summary="Cập nhật cấu hình phần cứng (.env)")
async def update_hardware_settings(req: UpdateHardwareSettingsRequest):
    url_cleaned = req.remote_gpu_url.strip().rstrip("/")
    updates = {
        "USE_REMOTE_GPU": "true" if req.use_remote_gpu else "false",
        "REMOTE_GPU_URL": url_cleaned,
        "REMOTE_CONCURRENCY": str(req.remote_concurrency or 2),
    }
    if req.colab_notebook_url is not None:
        updates["COLAB_NOTEBOOK_URL"] = req.colab_notebook_url.strip()

    try:
        _update_env_file(updates)
        model_handler.is_remote_gpu_enabled()
        model_handler.get_remote_gpu_url()
        logger.info(f"⚙️ Đã cập nhật cấu hình GPU: USE_REMOTE_GPU={req.use_remote_gpu}, URL='{url_cleaned}'")
    except Exception as e:
        logger.error(f"Lỗi khi ghi file .env: {e}")
        raise HTTPException(status_code=500, detail=f"Không thể ghi cấu hình vào .env: {e}")

    return await get_hardware_settings()


@router.post("/hardware/test", response_model=TestRemoteGpuResponse, summary="Kiểm tra kết nối tới Cloud GPU Worker")
async def test_remote_gpu(req: TestRemoteGpuRequest):
    base_url = req.remote_gpu_url.strip().rstrip("/")
    if not base_url:
        return TestRemoteGpuResponse(ok=False, error="Vui lòng nhập đường dẫn URL của Cloud GPU Worker.")

    endpoint = f"{base_url}/api/remote/health"
    if "hf.space" in base_url.lower():
        endpoint = f"{base_url}/gradio_api/remote/health"
    elif "/remote/" in base_url:
        endpoint = f"{base_url}/health"

    headers = {
        "ngrok-skip-browser-warning": "1",
        "User-Agent": "OmniVoice/1.0",
    }

    start_time = time.time()
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            resp = await client.get(endpoint, headers=headers)
            elapsed_ms = int((time.time() - start_time) * 1000)

            if resp.status_code == 200:
                try:
                    data = resp.json()
                    gpu_name = data.get("gpu_name", "GPU Sẵn sàng")
                    vram = float(data.get("vram_total_gb", 0)) if data.get("vram_total_gb") else None
                    provider = data.get("provider", "Cloud GPU Worker")
                    return TestRemoteGpuResponse(
                        ok=True,
                        gpu_name=gpu_name,
                        vram_total_gb=vram,
                        provider=provider,
                        ping_ms=elapsed_ms,
                    )
                except Exception:
                    return TestRemoteGpuResponse(
                        ok=True,
                        gpu_name="Cloud Worker",
                        provider="Cloud GPU",
                        ping_ms=elapsed_ms,
                    )
            elif resp.status_code == 404:
                body_sample = resp.text[:300]
                if "ERR_NGROK_3200" in body_sample or "ngrok" in body_sample.lower():
                    return TestRemoteGpuResponse(
                        ok=False,
                        error="Mã lỗi ERR_NGROK_3200: Đường hầm Ngrok chưa mở hoặc Google Colab chưa được bấm chạy Run!",
                        ping_ms=elapsed_ms,
                    )
                return TestRemoteGpuResponse(
                    ok=False,
                    error=f"Máy chủ trả về mã HTTP 404 (Không tìm thấy endpoint). Vui lòng kiểm tra lại đường dẫn!",
                    ping_ms=elapsed_ms,
                )
            elif resp.status_code in (502, 503, 504):
                return TestRemoteGpuResponse(
                    ok=False,
                    error=f"Máy chủ Cloud GPU đang khởi động hoặc chưa sẵn sàng (HTTP {resp.status_code}). Vui lòng chờ 30 giây rồi thử lại!",
                    ping_ms=elapsed_ms,
                )
            else:
                return TestRemoteGpuResponse(
                    ok=False,
                    error=f"Máy chủ trả về mã HTTP {resp.status_code}: {resp.text[:150]}",
                    ping_ms=elapsed_ms,
                )
    except httpx.ConnectError as ce:
        return TestRemoteGpuResponse(
            ok=False,
            error=f"Không thể kết nối đến máy chủ ({ce}). Hãy kiểm tra xem tab Google Colab có đang chạy không!",
        )
    except httpx.TimeoutException:
        return TestRemoteGpuResponse(
            ok=False,
            error="Quá thời gian chờ (Timeout 10s). Máy chủ không phản hồi.",
        )
    except Exception as e:
        return TestRemoteGpuResponse(
            ok=False,
            error=f"Lỗi kết nối: {str(e)}",
        )
