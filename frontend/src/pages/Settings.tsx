import { useState, useEffect } from "react";
import {
  Cpu,
  Server,
  CloudLightning,
  CheckCircle2,
  AlertTriangle,
  ExternalLink,
  Wifi,
  Sparkles,
  Layers,
  Save,
  Loader2,
  HardDrive,
  Cloud,
  RefreshCw,
  BookOpen,
  Sliders,
} from "lucide-react";
import { toast } from "sonner";
import { useTTSStore, type TestGpuResult } from "@/store/useTTSStore";

export default function Settings() {
  const {
    hardwareConfig,
    fetchHardwareSettings,
    updateHardwareSettings,
    testRemoteGpuConnection,
    isLoadingHardware,
    syncStatus,
    checkStorageStatus,
    isSyncing,
  } = useTTSStore();

  const [activeTab, setActiveTab] = useState<"hardware" | "guide" | "sync" | "studio">("hardware");
  const [useRemoteGpu, setUseRemoteGpu] = useState(false);
  const [remoteUrl, setRemoteUrl] = useState("");
  const [concurrency, setConcurrency] = useState(2);
  const [colabUrl, setColabUrl] = useState("https://colab.research.google.com/drive/1QK4hoFRklcGQpgUkU_YNcDidA5y5kzgO");
  const [isTesting, setIsTesting] = useState(false);
  const [testResult, setTestResult] = useState<TestGpuResult | null>(null);
  const [isSaving, setIsSaving] = useState(false);

  // Default studio model params stored in localStorage
  const [defaultCfg, setDefaultCfg] = useState(() => {
    try {
      const cur = JSON.parse(localStorage.getItem("tts_model_config") || "{}");
      return cur.cfg_value || 2.0;
    } catch {
      return 2.0;
    }
  });
  const [defaultFormat, setDefaultFormat] = useState<"mp3" | "wav">(() => {
    return (localStorage.getItem("tts_audio_format") as "mp3" | "wav") || "mp3";
  });

  useEffect(() => {
    fetchHardwareSettings();
    checkStorageStatus();
  }, [fetchHardwareSettings, checkStorageStatus]);

  useEffect(() => {
    if (hardwareConfig) {
      setUseRemoteGpu(hardwareConfig.use_remote_gpu);
      setRemoteUrl(hardwareConfig.remote_gpu_url || "");
      setConcurrency(hardwareConfig.remote_concurrency || 2);
      if (hardwareConfig.colab_notebook_url) {
        setColabUrl(hardwareConfig.colab_notebook_url);
      }
    }
  }, [hardwareConfig]);

  const handleRunPingTest = async () => {
    const trimmed = remoteUrl.trim();
    if (!trimmed) {
      toast.error("Vui lòng nhập đường dẫn Cloud GPU URL trước khi kiểm tra!");
      return;
    }

    setIsTesting(true);
    setTestResult(null);
    try {
      const res = await testRemoteGpuConnection(trimmed);
      setTestResult(res);
      if (res.ok) {
        toast.success(
          `Kết nối thành công tới ${res.provider || "Cloud GPU"} (${res.gpu_name})!`
        );
      } else {
        toast.error(res.error || "Không thể kết nối tới Cloud GPU.");
      }
    } catch (err: any) {
      setTestResult({ ok: false, error: err.message || "Lỗi kiểm tra" });
      toast.error("Kiểm tra kết nối thất bại.");
    } finally {
      setIsTesting(false);
    }
  };

  const handleSaveHardware = async () => {
    if (useRemoteGpu && !remoteUrl.trim()) {
      toast.error("Vui lòng nhập đường dẫn URL của Cloud GPU Worker!");
      return;
    }

    setIsSaving(true);
    try {
      const success = await updateHardwareSettings({
        use_remote_gpu: useRemoteGpu,
        remote_gpu_url: remoteUrl.trim(),
        remote_concurrency: concurrency,
        colab_notebook_url: colabUrl.trim(),
      });

      if (success) {
        toast.success(
          useRemoteGpu
            ? "Đã lưu và kích hoạt chế độ Cloud GPU (Tesla T4)!"
            : "Đã lưu và kích hoạt chế độ GPU Cục Bộ (GTX 1650)!"
        );
      } else {
        toast.error("Không thể lưu cấu hình vào file .env.");
      }
    } catch (err: any) {
      toast.error(`Lỗi: ${err.message}`);
    } finally {
      setIsSaving(false);
    }
  };

  const handleSaveStudioDefaults = () => {
    try {
      const config = {
        cfg_value: defaultCfg,
        speed: 1.0,
      };
      localStorage.setItem("tts_model_config", JSON.stringify(config));
      localStorage.setItem("tts_audio_format", defaultFormat);
      toast.success("Đã lưu thiết lập phòng thu mặc định!");
    } catch (err: any) {
      toast.error(`Lỗi: ${err.message}`);
    }
  };

  return (
    <div className="max-w-5xl mx-auto space-y-6 pb-12">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-white/10 pb-6">
        <div>
          <h1 className="text-2xl font-black tracking-tight text-on-surface flex items-center gap-3">
            <Cpu className="w-7 h-7 text-primary" />
            Cài Đặt Hệ Thống & Bộ Xử Lý GPU
          </h1>
          <p className="text-sm text-on-surface-variant mt-1">
            Quản lý phần cứng tính toán AI, chuyển đổi linh hoạt giữa GPU máy tính và GPU đám mây.
          </p>
        </div>

        {/* Status Badge */}
        <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-surface-variant/40 border border-white/10 text-xs text-on-surface font-mono w-fit">
          <span
            className={`w-2 h-2 rounded-full ${
              hardwareConfig.use_remote_gpu
                ? "bg-amber-400 animate-pulse"
                : "bg-emerald-400"
            }`}
          />
          {hardwareConfig.use_remote_gpu ? (
            <span>Cloud GPU: {hardwareConfig.remote_gpu_url || "Chưa nhập URL"}</span>
          ) : (
            <span>
              Local GPU:{" "}
              {hardwareConfig.cuda_device_name || "NVIDIA GTX 1650 (4GB)"}
            </span>
          )}
        </div>
      </div>

      {/* Tabs Navigation */}
      <div className="flex items-center gap-2 border-b border-white/10 pb-2 overflow-x-auto">
        <button
          onClick={() => setActiveTab("hardware")}
          className={`flex items-center gap-2 px-4 py-2.5 rounded-xl font-medium text-xs md:text-sm transition-all cursor-pointer whitespace-nowrap ${
            activeTab === "hardware"
              ? "bg-primary text-black font-semibold shadow-md shadow-primary/20"
              : "text-on-surface-variant hover:text-on-surface hover:bg-white/5"
          }`}
        >
          <Cpu className="w-4 h-4" />
          Bộ Xử Lý & GPU
        </button>

        <button
          onClick={() => setActiveTab("guide")}
          className={`flex items-center gap-2 px-4 py-2.5 rounded-xl font-medium text-xs md:text-sm transition-all cursor-pointer whitespace-nowrap ${
            activeTab === "guide"
              ? "bg-primary text-black font-semibold shadow-md shadow-primary/20"
              : "text-on-surface-variant hover:text-on-surface hover:bg-white/5"
          }`}
        >
          <BookOpen className="w-4 h-4" />
          Hướng Dẫn Google Colab & Cloud
        </button>

        <button
          onClick={() => setActiveTab("sync")}
          className={`flex items-center gap-2 px-4 py-2.5 rounded-xl font-medium text-xs md:text-sm transition-all cursor-pointer whitespace-nowrap ${
            activeTab === "sync"
              ? "bg-primary text-black font-semibold shadow-md shadow-primary/20"
              : "text-on-surface-variant hover:text-on-surface hover:bg-white/5"
          }`}
        >
          <Cloud className="w-4 h-4" />
          Đồng Bộ Đám Mây & Dữ Liệu
        </button>

        <button
          onClick={() => setActiveTab("studio")}
          className={`flex items-center gap-2 px-4 py-2.5 rounded-xl font-medium text-xs md:text-sm transition-all cursor-pointer whitespace-nowrap ${
            activeTab === "studio"
              ? "bg-primary text-black font-semibold shadow-md shadow-primary/20"
              : "text-on-surface-variant hover:text-on-surface hover:bg-white/5"
          }`}
        >
          <Sliders className="w-4 h-4" />
          Mặc Định Phòng Thu
        </button>
      </div>

      {/* Tab 1: Bộ Xử Lý & GPU */}
      {activeTab === "hardware" && (
        <div className="space-y-6">
          {/* Card chọn Engine */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Option 1: GPU Cục Bộ */}
            <div
              onClick={() => setUseRemoteGpu(false)}
              className={`p-5 rounded-3xl border transition-all cursor-pointer relative flex flex-col justify-between ${
                !useRemoteGpu
                  ? "bg-primary/10 border-primary/50 shadow-xl shadow-primary/5 ring-1 ring-primary/20"
                  : "bg-surface-variant/30 hover:bg-surface-variant/50 border-white/5 opacity-75 hover:opacity-100"
              }`}
            >
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div
                      className={`w-10 h-10 rounded-2xl flex items-center justify-center ${
                        !useRemoteGpu
                          ? "bg-primary text-black font-bold shadow-md shadow-primary/20"
                          : "bg-white/10 text-on-surface"
                      }`}
                    >
                      <Server className="w-5 h-5" />
                    </div>
                    <div>
                      <h3 className="font-bold text-on-surface text-base flex items-center gap-2">
                        GPU Cục Bộ (Máy Tính)
                        <span className="text-[10px] uppercase font-mono px-2 py-0.5 rounded-full bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">
                          Offline 100%
                        </span>
                      </h3>
                      <p className="text-xs text-on-surface-variant">
                        {hardwareConfig.cuda_device_name || "NVIDIA GeForce GTX 1650 (4GB)"}
                      </p>
                    </div>
                  </div>
                  {!useRemoteGpu && (
                    <span className="w-2.5 h-2.5 rounded-full bg-primary animate-pulse" />
                  )}
                </div>

                <ul className="text-xs text-on-surface-variant space-y-1.5 pt-2">
                  <li className="flex items-center gap-2">
                    <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" />
                    Chạy hoàn toàn ngoại tuyến, không cần mạng Internet.
                  </li>
                  <li className="flex items-center gap-2">
                    <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" />
                    Không phụ thuộc vào Google Colab hay đường truyền mạng.
                  </li>
                  <li className="flex items-center gap-2">
                    <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" />
                    Sử dụng card rời NVIDIA GTX 1650 4GB VRAM.
                  </li>
                </ul>
              </div>

              <div className="mt-4 pt-3 border-t border-white/5 flex items-center justify-between text-[11px] text-on-surface-variant">
                <span>Trạng thái:</span>
                <span className="font-mono text-emerald-400">
                  {hardwareConfig.cuda_available
                    ? `CUDA Sẵn Sàng (${hardwareConfig.cuda_vram_gb || 4} GB VRAM)`
                    : "CPU Mode"}
                </span>
              </div>
            </div>

            {/* Option 2: Cloud GPU */}
            <div
              onClick={() => setUseRemoteGpu(true)}
              className={`p-5 rounded-3xl border transition-all cursor-pointer relative flex flex-col justify-between ${
                useRemoteGpu
                  ? "bg-primary/10 border-primary/50 shadow-xl shadow-primary/5 ring-1 ring-primary/20"
                  : "bg-surface-variant/30 hover:bg-surface-variant/50 border-white/5 opacity-75 hover:opacity-100"
              }`}
            >
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div
                      className={`w-10 h-10 rounded-2xl flex items-center justify-center ${
                        useRemoteGpu
                          ? "bg-primary text-black font-bold shadow-md shadow-primary/20"
                          : "bg-white/10 text-on-surface"
                      }`}
                    >
                      <CloudLightning className="w-5 h-5" />
                    </div>
                    <div>
                      <h3 className="font-bold text-on-surface text-base flex items-center gap-2">
                        Cloud GPU Từ Xa
                        <span className="text-[10px] uppercase font-mono px-2 py-0.5 rounded-full bg-primary/20 text-primary border border-primary/30">
                          Tesla T4 / A100
                        </span>
                      </h3>
                      <p className="text-xs text-on-surface-variant">
                        Google Colab GPU (16GB VRAM) hoặc Hugging Face ZeroGPU
                      </p>
                    </div>
                  </div>
                  {useRemoteGpu && (
                    <span className="w-2.5 h-2.5 rounded-full bg-primary animate-pulse" />
                  )}
                </div>

                <ul className="text-xs text-on-surface-variant space-y-1.5 pt-2">
                  <li className="flex items-center gap-2">
                    <CheckCircle2 className="w-3.5 h-3.5 text-primary" />
                    Tận dụng card Tesla T4 (16GB VRAM) miễn phí từ Google Colab.
                  </li>
                  <li className="flex items-center gap-2">
                    <CheckCircle2 className="w-3.5 h-3.5 text-primary" />
                    Máy tính của bạn hoàn toàn mát mẻ, không tốn tài nguyên.
                  </li>
                  <li className="flex items-center gap-2">
                    <CheckCircle2 className="w-3.5 h-3.5 text-primary" />
                    Tốc độ xử lý chuẩn Studio 32 steps siêu mượt mà.
                  </li>
                </ul>
              </div>

              <div className="mt-4 pt-3 border-t border-white/5 flex items-center justify-between text-[11px] text-on-surface-variant">
                <span>Yêu cầu:</span>
                <span className="font-mono text-primary">Cần mạng & Bật Colab</span>
              </div>
            </div>
          </div>

          {/* Cấu hình chi tiết Cloud GPU */}
          {useRemoteGpu && (
            <div className="p-6 rounded-3xl bg-surface-variant/20 border border-white/10 space-y-5">
              <div>
                <h3 className="text-sm font-bold text-on-surface flex items-center gap-2">
                  <Wifi className="w-4 h-4 text-primary" />
                  Cấu Hình Đường Dẫn Cloud GPU Worker (Public URL)
                </h3>
                <p className="text-xs text-on-surface-variant mt-0.5">
                  Nhập đường link Ngrok Static Domain, Cloudflare Tunnel hoặc Hugging Face Space của bạn.
                </p>
              </div>

              <div className="flex flex-col sm:flex-row gap-3">
                <input
                  type="text"
                  value={remoteUrl}
                  onChange={(e) => setRemoteUrl(e.target.value)}
                  placeholder="https://tipper-semantic-dropper.ngrok-free.dev"
                  className="flex-1 bg-surface-container-lowest/80 border border-white/10 rounded-2xl px-4 py-3 text-xs sm:text-sm text-on-surface font-mono placeholder:text-on-surface-variant/40 focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/40 transition-all"
                />

                <button
                  type="button"
                  onClick={handleRunPingTest}
                  disabled={isTesting || !remoteUrl.trim()}
                  className="px-6 py-3 rounded-2xl bg-primary/20 hover:bg-primary/30 border border-primary/40 text-primary font-semibold text-xs sm:text-sm flex items-center justify-center gap-2 shrink-0 transition-all disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer shadow-md"
                >
                  {isTesting ? (
                    <>
                      <Loader2 className="w-4 h-4 animate-spin" />
                      Đang kiểm tra...
                    </>
                  ) : (
                    <>
                      <Wifi className="w-4 h-4" />
                      Kiểm tra kết nối
                    </>
                  )}
                </button>
              </div>

              {/* Tùy chọn Sổ tay Google Colab (Hỗ trợ cả GitHub & Custom Google Drive) */}
              <div className="pt-4 border-t border-white/10 space-y-3">
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2">
                  <div>
                    <h4 className="text-xs font-bold text-on-surface flex items-center gap-1.5">
                      <Sparkles className="w-3.5 h-3.5 text-primary" />
                      Cấu Hình Sổ Tay Google Colab Tự Động Mở:
                    </h4>
                    <p className="text-[11px] text-on-surface-variant">
                      Trình duyệt sẽ tự động mở sổ tay này mỗi khi bạn khởi động ứng dụng để bạn bấm Play (Run).
                    </p>
                  </div>

                  {/* Nút chuyển đổi nhanh */}
                  <div className="flex items-center gap-2">
                    <button
                      type="button"
                      onClick={() => setColabUrl("https://colab.research.google.com/github/tranvankha1989/self-tts/blob/main/notebooks/OmniVoice_Colab_T4.ipynb")}
                      className={`px-3 py-1.5 rounded-xl text-xs font-medium border transition-all cursor-pointer ${
                        colabUrl.includes("github.com/tranvankha1989")
                          ? "bg-primary/20 border-primary text-primary"
                          : "bg-surface-variant/30 border-white/10 text-on-surface-variant hover:text-on-surface"
                      }`}
                    >
                      Dùng bản GitHub
                    </button>
                    <button
                      type="button"
                      onClick={() => setColabUrl("https://colab.research.google.com/drive/1QK4hoFRklcGQpgUkU_YNcDidA5y5kzgO")}
                      className={`px-3 py-1.5 rounded-xl text-xs font-medium border transition-all cursor-pointer ${
                        colabUrl.includes("drive/1QK4hoFRklcGQpgUkU_YNcDidA5y5kzgO")
                          ? "bg-primary/20 border-primary text-primary"
                          : "bg-surface-variant/30 border-white/10 text-on-surface-variant hover:text-on-surface"
                      }`}
                    >
                      Dùng bản Google Drive
                    </button>
                  </div>
                </div>

                {/* Input link tuỳ chỉnh */}
                <div className="space-y-1.5">
                  <div className="flex items-center justify-between">
                    <label className="text-[11px] font-semibold text-on-surface-variant">
                      Đường dẫn URL sổ tay đang kích hoạt:
                    </label>
                    <a
                      href={colabUrl.trim() || "https://colab.research.google.com/drive/1QK4hoFRklcGQpgUkU_YNcDidA5y5kzgO"}
                      target="_blank"
                      rel="noreferrer"
                      className="inline-flex items-center gap-1 text-xs text-primary hover:text-primary-hover underline underline-offset-4 font-semibold transition-colors"
                    >
                      <span>Mở ngay trên trình duyệt</span>
                      <ExternalLink className="w-3 h-3" />
                    </a>
                  </div>
                  <input
                    type="text"
                    value={colabUrl}
                    onChange={(e) => setColabUrl(e.target.value)}
                    placeholder="Dán link Google Drive hoặc GitHub vào đây..."
                    className="w-full bg-surface-container-lowest/80 border border-white/10 rounded-2xl px-4 py-2.5 text-xs sm:text-sm text-on-surface font-mono placeholder:text-on-surface-variant/40 focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/40 transition-all"
                  />
                </div>

                {/* 2 Thẻ Preset rõ ràng để bấm mở ngay */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5 pt-1">
                  {/* Option 1: GitHub */}
                  <div className="p-3 rounded-2xl bg-surface-container-lowest/60 border border-white/5 flex items-center justify-between">
                    <div className="space-y-0.5">
                      <div className="flex items-center gap-1.5 text-xs font-semibold text-on-surface">
                        <span className="w-2 h-2 rounded-full bg-blue-400"></span>
                        1. Sổ tay GitHub Repo
                      </div>
                      <p className="text-[11px] text-on-surface-variant truncate max-w-[180px]">
                        tranvankha1989/self-tts
                      </p>
                    </div>
                    <a
                      href="https://colab.research.google.com/github/tranvankha1989/self-tts/blob/main/notebooks/OmniVoice_Colab_T4.ipynb"
                      target="_blank"
                      rel="noreferrer"
                      className="px-2.5 py-1.5 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 text-xs text-primary font-medium flex items-center gap-1 transition-all"
                    >
                      Mở GitHub <ExternalLink className="w-3 h-3" />
                    </a>
                  </div>

                  {/* Option 2: Google Drive */}
                  <div className="p-3 rounded-2xl bg-surface-container-lowest/60 border border-white/5 flex items-center justify-between">
                    <div className="space-y-0.5">
                      <div className="flex items-center gap-1.5 text-xs font-semibold text-on-surface">
                        <span className="w-2 h-2 rounded-full bg-emerald-400"></span>
                        2. Sổ tay Google Drive
                      </div>
                      <p className="text-[11px] text-on-surface-variant truncate max-w-[180px]">
                        Lưu riêng trên Drive của bạn
                      </p>
                    </div>
                    <a
                      href="https://colab.research.google.com/drive/1QK4hoFRklcGQpgUkU_YNcDidA5y5kzgO"
                      target="_blank"
                      rel="noreferrer"
                      className="px-2.5 py-1.5 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 text-xs text-emerald-400 font-medium flex items-center gap-1 transition-all"
                    >
                      Mở Drive <ExternalLink className="w-3 h-3" />
                    </a>
                  </div>
                </div>
              </div>

              {/* Banner Kết quả Test Ping */}
              {testResult && (
                <div
                  className={`p-4 rounded-2xl border flex items-start gap-3 text-xs sm:text-sm animate-in fade-in duration-200 ${
                    testResult.ok
                      ? "bg-emerald-500/10 border-emerald-500/30 text-emerald-300"
                      : "bg-rose-500/10 border-rose-500/30 text-rose-300"
                  }`}
                >
                  {testResult.ok ? (
                    <CheckCircle2 className="w-5 h-5 text-emerald-400 shrink-0 mt-0.5" />
                  ) : (
                    <AlertTriangle className="w-5 h-5 text-rose-400 shrink-0 mt-0.5" />
                  )}
                  <div className="flex-1 space-y-1">
                    <div className="font-bold flex items-center justify-between">
                      <span>{testResult.ok ? "🎉 Máy chủ Cloud GPU đang trực tuyến & sẵn sàng!" : "❌ Không thể kết nối tới máy chủ"}</span>
                      {testResult.ping_ms && (
                        <span className="font-mono text-xs px-2 py-0.5 rounded-md bg-white/10">
                          Ping: {testResult.ping_ms} ms
                        </span>
                      )}
                    </div>
                    {testResult.ok ? (
                      <p className="text-xs opacity-90 font-mono">
                        {testResult.provider} — Card: {testResult.gpu_name} ({testResult.vram_total_gb} GB VRAM)
                      </p>
                    ) : (
                      <p className="text-xs opacity-90">{testResult.error}</p>
                    )}
                  </div>
                </div>
              )}

              {/* Tùy chọn Số luồng song song */}
              <div className="pt-2 flex flex-col sm:flex-row sm:items-center justify-between gap-3 text-xs border-t border-white/5">
                <div>
                  <span className="text-on-surface font-semibold flex items-center gap-2">
                    <Layers className="w-4 h-4 text-primary" />
                    Số luồng tổng hợp song song (Concurrency):
                  </span>
                  <p className="text-[11px] text-on-surface-variant mt-0.5">
                    Số đoạn câu gửi đồng thời lên GPU T4 (mặc định 2 luồng là tối ưu nhất).
                  </p>
                </div>

                <div className="flex items-center gap-2">
                  {[1, 2, 3, 4].map((n) => (
                    <button
                      key={n}
                      type="button"
                      onClick={() => setConcurrency(n)}
                      className={`w-9 h-9 rounded-xl text-xs font-mono font-bold transition-all cursor-pointer ${
                        concurrency === n
                          ? "bg-primary text-black shadow-md shadow-primary/20 scale-105"
                          : "bg-surface-container-lowest/80 text-on-surface-variant hover:text-on-surface hover:bg-white/10 border border-white/5"
                      }`}
                    >
                      {n}
                    </button>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* Action Bar Lưu Thay Đổi */}
          <div className="flex items-center justify-between pt-4 border-t border-white/10">
            <span className="text-xs text-on-surface-variant font-mono">
              {isLoadingHardware ? "Đang đồng bộ..." : "Tự động cập nhật file backend/.env khi lưu"}
            </span>

            <button
              type="button"
              onClick={handleSaveHardware}
              disabled={isSaving}
              className="px-8 py-3 rounded-2xl bg-primary hover:bg-primary-hover text-black font-bold text-sm flex items-center gap-2 shadow-xl shadow-primary/25 transition-all disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer"
            >
              {isSaving ? (
                <>
                  <Loader2 className="w-4 h-4 animate-spin" />
                  Đang lưu cấu hình...
                </>
              ) : (
                <>
                  <Save className="w-4 h-4" />
                  Lưu & Áp Dụng Thay Đổi
                </>
              )}
            </button>
          </div>
        </div>
      )}

      {/* Tab 2: Hướng Dẫn Google Colab & Cloud */}
      {activeTab === "guide" && (
        <div className="space-y-6">
          {/* Card 1: Hướng dẫn Google Colab + Ngrok Static Domain */}
          <div className="p-6 rounded-3xl bg-surface-variant/20 border border-white/10 space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="text-base font-bold text-on-surface flex items-center gap-2">
                <Sparkles className="w-5 h-5 text-primary" />
                Cách 1: Google Colab T4 GPU + Ngrok Static Domain (Khuyên Dùng)
              </h3>
              <span className="text-xs px-2.5 py-1 rounded-full bg-primary/15 text-primary border border-primary/30 font-medium">
                Cấu hình 1 lần - Dùng mãi mãi
              </span>
            </div>

            <p className="text-xs sm:text-sm text-on-surface-variant leading-relaxed">
              Giải pháp tối ưu nhất cho Google Colab: Đăng ký miễn phí 1 tên miền cố định từ Ngrok để không bao giờ phải sửa lại đường link nữa!
            </p>

            <div className="space-y-3 text-xs sm:text-sm">
              <div className="p-3.5 rounded-2xl bg-black/30 border border-white/5 space-y-1">
                <span className="font-semibold text-primary block">Bước 1: Đăng ký tài khoản Ngrok miễn phí</span>
                <p className="text-on-surface-variant text-xs">
                  Truy cập{" "}
                  <a
                    href="https://dashboard.ngrok.com"
                    target="_blank"
                    rel="noreferrer"
                    className="text-primary underline inline-flex items-center gap-1"
                  >
                    dashboard.ngrok.com <ExternalLink className="w-3 h-3" />
                  </a>
                  {" "}đăng nhập bằng Google trong 10 giây.
                </p>
              </div>

              <div className="p-3.5 rounded-2xl bg-black/30 border border-white/5 space-y-1">
                <span className="font-semibold text-primary block">Bước 2: Lấy Authtoken & Tên miền tĩnh</span>
                <p className="text-on-surface-variant text-xs">
                  Vào mục <strong>Your Authtoken</strong> copy mã token. Sau đó vào mục <strong>Cloud Edge ➔ Domains</strong> bấm nhận 1 domain tĩnh miễn phí (ví dụ: <code className="text-primary font-mono">tipper-semantic-dropper.ngrok-free.dev</code>).
                </p>
              </div>

              <div className="p-3.5 rounded-2xl bg-black/30 border border-white/5 space-y-1">
                <span className="font-semibold text-primary block">Bước 3: Chạy Notebook trên Google Colab</span>
                <p className="text-on-surface-variant text-xs">
                  Mở file notebook <code className="text-primary font-mono">notebooks/OmniVoice_Colab_T4.ipynb</code> trên Google Colab. Nhập Authtoken và Static Domain rồi bấm <strong>Play (▶️)</strong>.
                </p>
              </div>

              <div className="p-3.5 rounded-2xl bg-black/30 border border-white/5 space-y-1">
                <span className="font-semibold text-primary block">Bước 4: Điền vào ô Cloud GPU URL ở Tab 1</span>
                <p className="text-on-surface-variant text-xs">
                  Dán link domain Ngrok của bạn (ví dụ: <code className="text-primary font-mono">https://tipper-semantic-dropper.ngrok-free.dev</code>) vào ô URL ở Tab 1 và bấm <strong>Lưu & Áp Dụng</strong>. Từ nay về sau mỗi lần dùng chỉ việc mở Colab bấm Play!
                </p>
              </div>
            </div>
          </div>

          {/* Card 2: Hugging Face ZeroGPU */}
          <div className="p-6 rounded-3xl bg-surface-variant/20 border border-white/10 space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="text-base font-bold text-on-surface flex items-center gap-2">
                <Cloud className="w-5 h-5 text-emerald-400" />
                Cách 2: Hugging Face Spaces (ZeroGPU A100) — Chạy 24/7 Không Cần Treo Tab
              </h3>
              <span className="text-xs px-2.5 py-1 rounded-full bg-emerald-500/15 text-emerald-400 border border-emerald-500/30 font-medium">
                Chạy 24/7
              </span>
            </div>

            <p className="text-xs sm:text-sm text-on-surface-variant leading-relaxed">
              Tạo một Space miễn phí trên Hugging Face bằng các file có sẵn trong thư mục <code className="text-primary font-mono">hf_space/</code> của dự án.
              Khi Space chạy, bạn copy đường link Space dán vào ô URL để dùng mọi lúc mọi nơi mà không cần treo máy.
            </p>
          </div>
        </div>
      )}

      {/* Tab 3: Đồng Bộ & Dữ Liệu */}
      {activeTab === "sync" && (
        <div className="space-y-6">
          <div className="p-6 rounded-3xl bg-surface-variant/20 border border-white/10 space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-base font-bold text-on-surface flex items-center gap-2">
                  <Cloud className="w-5 h-5 text-primary" />
                  Trạng Thái Đồng Bộ Đám Mây (Cloud Sync)
                </h3>
                <p className="text-xs text-on-surface-variant mt-0.5">
                  Đồng bộ lịch sử âm thanh, dự án và từ điển phát âm giữa nhiều máy tính qua MongoDB Atlas & Cloudflare R2.
                </p>
              </div>

              <button
                type="button"
                onClick={() => checkStorageStatus()}
                disabled={isSyncing}
                className="px-4 py-2 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 text-xs font-medium flex items-center gap-1.5 cursor-pointer"
              >
                <RefreshCw className={`w-3.5 h-3.5 ${isSyncing ? "animate-spin" : ""}`} />
                Kiểm tra lại
              </button>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 pt-2">
              <div className="p-4 rounded-2xl bg-black/20 border border-white/5 space-y-1">
                <span className="text-xs text-on-surface-variant">Cơ sở dữ liệu (MongoDB Atlas):</span>
                <div className="flex items-center gap-2 font-bold text-sm">
                  {syncStatus.mongo_connected ? (
                    <span className="text-emerald-400 flex items-center gap-1.5">
                      <CheckCircle2 className="w-4 h-4" /> Đã kết nối MongoDB Cloud
                    </span>
                  ) : (
                    <span className="text-on-surface-variant flex items-center gap-1.5">
                      <HardDrive className="w-4 h-4" /> Chế độ Cục Bộ (LocalStorage)
                    </span>
                  )}
                </div>
              </div>

              <div className="p-4 rounded-2xl bg-black/20 border border-white/5 space-y-1">
                <span className="text-xs text-on-surface-variant">Lưu trữ Audio (Cloudflare R2):</span>
                <div className="flex items-center gap-2 font-bold text-sm">
                  {syncStatus.r2_connected ? (
                    <span className="text-emerald-400 flex items-center gap-1.5">
                      <CheckCircle2 className="w-4 h-4" /> Đã kết nối Cloudflare R2
                    </span>
                  ) : (
                    <span className="text-on-surface-variant flex items-center gap-1.5">
                      <HardDrive className="w-4 h-4" /> Lưu cục bộ trong /outputs
                    </span>
                  )}
                </div>
              </div>
            </div>

            <p className="text-xs text-on-surface-variant pt-2 border-t border-white/5">
              💡 Để bật đồng bộ đám mây, chỉ cần điền <code className="text-primary font-mono">MONGODB_URI</code> và thông tin Cloudflare R2 vào file <code className="text-primary font-mono">backend/.env</code>.
            </p>
          </div>
        </div>
      )}

      {/* Tab 4: Mặc Định Phòng Thu */}
      {activeTab === "studio" && (
        <div className="space-y-6">
          <div className="p-6 rounded-3xl bg-surface-variant/20 border border-white/10 space-y-4">
            <h3 className="text-base font-bold text-on-surface flex items-center gap-2">
              <Sliders className="w-5 h-5 text-primary" />
              Thiết Lập Mặc Định Khi Khởi Tạo Studio
            </h3>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-2">
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-on-surface">
                  Độ Bám Văn Bản Mặc Định (CFG Guidance):
                </label>
                <div className="flex items-center gap-3">
                  <input
                    type="range"
                    min="1.0"
                    max="5.0"
                    step="0.1"
                    value={defaultCfg}
                    onChange={(e) => setDefaultCfg(parseFloat(e.target.value))}
                    className="flex-1 accent-primary cursor-pointer"
                  />
                  <span className="text-xs font-mono font-bold w-10 text-right text-primary">
                    {defaultCfg.toFixed(1)}
                  </span>
                </div>
                <p className="text-[11px] text-on-surface-variant">
                  Mặc định 2.0 cho giọng nói tự nhiên, truyền cảm nhất.
                </p>
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-on-surface">
                  Định Dạng Âm Thanh Xuất Mặc Định:
                </label>
                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    onClick={() => setDefaultFormat("mp3")}
                    className={`px-4 py-2 rounded-xl text-xs font-semibold transition-all cursor-pointer ${
                      defaultFormat === "mp3"
                        ? "bg-primary text-black shadow-md shadow-primary/20"
                        : "bg-surface-container-lowest/80 text-on-surface-variant hover:text-on-surface border border-white/5"
                    }`}
                  >
                    MP3 (Nén nhẹ, tải nhanh)
                  </button>
                  <button
                    type="button"
                    onClick={() => setDefaultFormat("wav")}
                    className={`px-4 py-2 rounded-xl text-xs font-semibold transition-all cursor-pointer ${
                      defaultFormat === "wav"
                        ? "bg-primary text-black shadow-md shadow-primary/20"
                        : "bg-surface-container-lowest/80 text-on-surface-variant hover:text-on-surface border border-white/5"
                    }`}
                  >
                    WAV (Chuẩn Studio 24kHz nguyên bản)
                  </button>
                </div>
              </div>
            </div>

            <div className="pt-4 border-t border-white/10 flex justify-end">
              <button
                type="button"
                onClick={handleSaveStudioDefaults}
                className="px-6 py-2.5 rounded-xl bg-primary hover:bg-primary-hover text-black font-bold text-xs sm:text-sm flex items-center gap-2 shadow-lg shadow-primary/20 transition-all cursor-pointer"
              >
                <Save className="w-4 h-4" />
                Lưu Thiết Lập Phòng Thu
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
