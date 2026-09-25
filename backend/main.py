"""
main.py  —  OmniVoice TTS API Server
────────────────────────────────────
Khởi chạy:
    uvicorn main:app --host 0.0.0.0 --port 8000 --reload

Swagger UI:
    http://localhost:8000/docs
"""

from pathlib import Path
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.core.config import OUTPUTS_DIR, PRESETS_DIR, logger
from app.core.database import connect_db, close_db
from app.routers import api_router
from model_handler import load_model


import os
import threading
import time
import webbrowser


def _open_browser_tabs():
    """Tự động mở tab trình duyệt Web App và Google Colab GPU khi khởi động server."""
    time.sleep(1.2)
    # 1. Mở Web App local
    try:
        webbrowser.open("http://localhost:8000")
    except Exception as e:
        logger.warning(f"Không thể mở trình duyệt Web App: {e}")

    # 2. Nếu đang bật USE_REMOTE_GPU thì tự động mở Google Colab T4
    use_remote = os.getenv("USE_REMOTE_GPU", "false").lower() == "true"
    remote_url = os.getenv("REMOTE_GPU_URL", "").lower()
    colab_url = os.getenv("COLAB_NOTEBOOK_URL", "https://colab.research.google.com/drive/1QK4hoFRklcGQpgUkU_YNcDidA5y5kzgO").strip()

    if use_remote and ("hf.space" not in remote_url and "huggingface" not in remote_url):
        time.sleep(1.0)
        logger.info(f"⚡ Phát hiện Cloud GPU đang bật — Tự động mở Google Colab trên trình duyệt: {colab_url}")
        try:
            webbrowser.open(colab_url)
        except Exception as e:
            logger.warning(f"Không thể mở Google Colab: {e}")


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Load mô hình OmniVoice và kết nối cơ sở dữ liệu nếu có cấu hình."""
    logger.info("🚀 Server đang khởi động — nạp mô hình OmniVoice (24kHz) …")
    load_model()
    await connect_db()

    # Tự động mở trình duyệt Web App & Google Colab GPU trong luồng nền
    threading.Thread(target=_open_browser_tabs, daemon=True).start()

    yield
    await close_db()
    logger.info("🛑 Server đang tắt.")


app = FastAPI(
    title="OmniVoice TTS API",
    description=(
        "Text-to-Speech đa ngôn ngữ chất lượng cao 24kHz sử dụng OmniVoice (k2-fsa). "
        "Hỗ trợ Cloud Sync MongoDB & Cloudflare R2 với Fallback LocalStorage."
    ),
    version="2.2.0",
    lifespan=lifespan,
)

# ─── CORS Middleware ──────────────────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── Static Files (Audio Outputs & Presets) ──────────────────────────────────
app.mount("/outputs", StaticFiles(directory=str(OUTPUTS_DIR)), name="outputs")
app.mount("/presets", StaticFiles(directory=str(PRESETS_DIR)), name="presets")

# ─── Include API Routers ──────────────────────────────────────────────────────
app.include_router(api_router)

# ─── Phục vụ Frontend Build (SPA Production Mode) ──────────────────────────────
FRONTEND_DIST = Path(__file__).resolve().parent.parent / "frontend" / "dist"
if (FRONTEND_DIST / "assets").exists():
    app.mount("/assets", StaticFiles(directory=str(FRONTEND_DIST / "assets")), name="assets")

@app.get("/{full_path:path}", include_in_schema=False)
async def serve_spa(full_path: str):
    """Phục vụ SPA Router hoặc fallback index.html khi chạy chế độ độc lập."""
    target_file = FRONTEND_DIST / full_path
    if full_path and target_file.is_file():
        return FileResponse(target_file)
    index_file = FRONTEND_DIST / "index.html"
    if index_file.is_file():
        return FileResponse(index_file)
    return {"message": "OmniVoice TTS API đang chạy (Chưa build frontend/dist)"}

