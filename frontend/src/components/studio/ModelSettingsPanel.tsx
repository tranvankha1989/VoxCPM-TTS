import React, { useState } from "react";
import { Link } from "react-router-dom";
import { FolderPlus, Plus, X, Cpu, ExternalLink } from "lucide-react";
import { toast } from "sonner";
import { useTTSStore, type Project } from "../../store/useTTSStore";

interface ModelSettingsPanelProps {
  cfg_value: number;
  setCfgValue: (val: number) => void;
  speed: number;
  setSpeed: (val: number) => void;
  pitch: number;
  setPitch: (val: number) => void;
  audioFormat: "mp3" | "wav";
  setAudioFormat: (fmt: "mp3" | "wav") => void;
  enhanceAudio: boolean;
  setEnhanceAudio: (val: boolean) => void;
  selectedProjectId: string;
  setSelectedProjectId: (val: string) => void;
  projects: Project[];
  isLoading: boolean;
  onGenerate: () => void;
  onSaveConfig: () => void;
  configSaved: boolean;
}

export const ModelSettingsPanel: React.FC<ModelSettingsPanelProps> = ({
  cfg_value,
  setCfgValue,
  speed,
  setSpeed,
  pitch,
  setPitch,
  audioFormat,
  setAudioFormat,
  enhanceAudio,
  setEnhanceAudio,
  selectedProjectId,
  setSelectedProjectId,
  projects,
  isLoading,
  onGenerate,
  onSaveConfig,
  configSaved,
}) => {
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
  const [newProjectName, setNewProjectName] = useState("");
  const [newProjectDesc, setNewProjectDesc] = useState("");
  const addProject = useTTSStore((state) => state.addProject);

  const handleSelectChange = (val: string) => {
    if (val === "__NEW_PROJECT__") {
      setIsCreateModalOpen(true);
      return;
    }
    setSelectedProjectId(val);
  };

  const handleCreateProject = (e: React.FormEvent) => {
    e.preventDefault();
    const trimmed = newProjectName.trim();
    if (!trimmed) {
      toast.error("Vui lòng nhập tên dự án mới");
      return;
    }

    const created = addProject(trimmed, newProjectDesc.trim());
    setSelectedProjectId(created.id);
    toast.success(`Đã tạo dự án "${created.name}" thành công!`);

    setNewProjectName("");
    setNewProjectDesc("");
    setIsCreateModalOpen(false);
  };

  return (
    <div className="glass-card rounded-2xl p-6 2k:p-8 shadow-2xl border border-white/5 flex flex-col gap-8 2k:gap-9 relative overflow-hidden">
      <div className="absolute -top-12 -right-12 w-32 h-32 bg-primary/5 rounded-full blur-[40px] pointer-events-none"></div>

      <div className="flex items-center gap-2 border-b border-white/5 pb-4 2k:pb-5">
        <span className="material-symbols-outlined text-primary text-[20px] 2k:text-[24px]">
          tune
        </span>
        <h3 className="font-label-caps text-label-caps 2k:text-base text-on-surface">
          Cài đặt mô hình
        </h3>
        {/* Nút Lưu cấu hình */}
        <button
          type="button"
          onClick={onSaveConfig}
          title="Lưu CFG · Speed · Pitch · Format làm mặc định"
          className={`ml-auto flex items-center gap-1.5 px-3 py-1.5 rounded-lg font-label-caps text-[11px] 2k:text-xs transition-all duration-300 border
            ${
              configSaved
                ? "bg-primary/20 text-primary border-primary/30 shadow-[0_0_10px_rgba(245,158,11,0.15)]"
                : "bg-white/5 hover:bg-primary/10 text-on-surface-variant hover:text-primary border-white/10 hover:border-primary/30"
            }`}
        >
          <span
            className={`material-symbols-outlined text-[14px] transition-all ${configSaved ? "scale-110" : ""}`}
          >
            {configSaved ? "bookmark_added" : "bookmark"}
          </span>
          {configSaved ? "Đã lưu!" : "Lưu cấu hình"}
        </button>
      </div>

      <div className="flex flex-col gap-7 2k:gap-8">
        {/* Project Selection */}
        <div className="flex flex-col gap-3 2k:gap-3.5">
          <div className="flex items-center justify-between">
            <label className="font-label-caps text-sm 2k:text-base text-on-surface-variant flex items-center gap-2">
              <span className="material-symbols-outlined text-[16px] 2k:text-[18px]">
                workspaces
              </span>
              Lưu vào dự án
            </label>
            <button
              type="button"
              onClick={() => setIsCreateModalOpen(true)}
              className="text-[11px] 2k:text-xs text-primary hover:text-primary/80 flex items-center gap-1 font-label-caps transition-colors hover:underline cursor-pointer"
              title="Tạo nhanh dự án mới"
            >
              <Plus className="w-3.5 h-3.5" />
              Tạo dự án mới
            </button>
          </div>

          <select
            value={selectedProjectId}
            onChange={(e) => handleSelectChange(e.target.value)}
            className="bg-surface-dim border border-white/5 rounded-lg px-4 py-2.5 2k:py-3 text-sm 2k:text-base text-on-surface focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/50 transition-all font-body-md w-full cursor-pointer"
          >
            <option value="__NEW_PROJECT__" className="text-primary font-medium bg-[#1e1e1e]">
              ✨ + Tạo dự án mới...
            </option>
            <option value="" className="bg-[#1e1e1e]">-- Thư viện chung --</option>
            {projects.map((p) => (
              <option key={p.id} value={p.id} className="bg-[#1e1e1e]">
                📁 {p.name}
              </option>
            ))}
          </select>
        </div>

        {/* Format Selection */}
        <div className="flex flex-col gap-3 2k:gap-3.5">
          <label className="font-label-caps text-sm 2k:text-base text-on-surface-variant flex items-center gap-2">
            Định dạng tải về
          </label>
          <div className="inline-flex bg-surface-dim border border-white/5 rounded-lg p-1 w-full shadow-inner">
            <button
              type="button"
              className={`flex-1 py-1.5 2k:py-2 rounded-md font-label-caps text-xs 2k:text-sm transition-all duration-300 ${audioFormat === "mp3" ? "bg-primary/20 text-primary border border-primary/30 shadow-sm" : "text-on-surface-variant hover:text-on-surface hover:bg-white/5"}`}
              onClick={() => setAudioFormat("mp3")}
            >
              .MP3 (Mặc định)
            </button>
            <button
              type="button"
              className={`flex-1 py-1.5 2k:py-2 rounded-md font-label-caps text-xs 2k:text-sm transition-all duration-300 ${audioFormat === "wav" ? "bg-primary/20 text-primary border border-primary/30 shadow-sm" : "text-on-surface-variant hover:text-on-surface hover:bg-white/5"}`}
              onClick={() => setAudioFormat("wav")}
            >
              .WAV
            </button>
          </div>
        </div>

        {/* CFG Scale */}
        <div className="flex flex-col gap-3 2k:gap-3.5">
          <div className="flex justify-between items-center">
            <label
              className="font-label-caps text-sm 2k:text-base text-on-surface-variant flex items-center gap-2"
              htmlFor="cfg-scale"
            >
              Tỉ lệ hướng dẫn (CFG)
            </label>
            <span className="font-mono-data text-mono-data text-primary bg-primary/10 px-2 2k:px-3 py-0.5 2k:py-1 rounded border border-primary/20 shadow-inner text-sm 2k:text-base">
              {cfg_value.toFixed(1)}
            </span>
          </div>
          <input
            className="w-full accent-primary"
            id="cfg-scale"
            max="3.0"
            min="1.0"
            step="0.1"
            type="range"
            value={cfg_value}
            onChange={(e) => setCfgValue(parseFloat(e.target.value))}
          />
          <p className="text-[11px] 2k:text-xs text-on-surface-variant/70 leading-relaxed">
            Độ bám sát văn bản. Mặc định 2.0. Sử dụng 2.5 cho code-switching
            (tiếng Anh xen tiếng Việt).
          </p>
        </div>

        {/* Speed */}
        <div className="flex flex-col gap-3 2k:gap-3.5">
          <div className="flex justify-between items-center">
            <label
              className="font-label-caps text-sm 2k:text-base text-on-surface-variant flex items-center gap-2"
              htmlFor="speed"
            >
              Tốc độ (Speed)
            </label>
            <span className="font-mono-data text-mono-data text-primary bg-primary/10 px-2 2k:px-3 py-0.5 2k:py-1 rounded border border-primary/20 shadow-inner text-sm 2k:text-base">
              {speed.toFixed(2)}x
            </span>
          </div>
          <input
            className="w-full accent-primary"
            id="speed"
            max="2.0"
            min="0.5"
            step="0.05"
            type="range"
            value={speed}
            onChange={(e) => setSpeed(parseFloat(e.target.value))}
          />
          <p className="text-[11px] 2k:text-xs text-on-surface-variant/70 leading-relaxed">
            Tốc độ phát (0.5x - 2.0x). 1.0x là tốc độ bình thường.
          </p>
        </div>

        {/* Pitch */}
        <div className="flex flex-col gap-3 2k:gap-3.5">
          <div className="flex justify-between items-center">
            <label
              className="font-label-caps text-sm 2k:text-base text-on-surface-variant flex items-center gap-2"
              htmlFor="pitch"
            >
              Cao độ (Pitch)
            </label>
            <span className="font-mono-data text-mono-data text-primary bg-primary/10 px-2 2k:px-3 py-0.5 2k:py-1 rounded border border-primary/20 shadow-inner text-sm 2k:text-base">
              {pitch > 0 ? "+" : ""}
              {pitch.toFixed(1)}
            </span>
          </div>
          <input
            className="w-full accent-primary"
            id="pitch"
            max="12.0"
            min="-12.0"
            step="0.5"
            type="range"
            value={pitch}
            onChange={(e) => setPitch(parseFloat(e.target.value))}
          />
          <p className="text-[11px] 2k:text-xs text-on-surface-variant/70 leading-relaxed">
            Điều chỉnh tông giọng (bước âm - nửa cung). Tăng để giọng cao hơn,
            giảm để trầm hơn.
          </p>
        </div>

        {/* Studio Hi-Fi Vocal Enhancement */}
        <div className="flex flex-col gap-2 p-3.5 rounded-xl bg-surface-dim border border-white/10 hover:border-primary/30 transition-all shadow-inner">
          <div className="flex items-center justify-between">
            <label
              htmlFor="enhance-audio-toggle"
              className="font-label-caps text-xs 2k:text-sm text-on-surface flex items-center gap-2 cursor-pointer font-medium"
            >
              <span className="material-symbols-outlined text-primary text-[18px]">
                auto_fix_high
              </span>
              Bộ lọc Studio Hi-Fi (44.1kHz)
            </label>
            <button
              type="button"
              role="switch"
              id="enhance-audio-toggle"
              aria-checked={enhanceAudio}
              onClick={() => setEnhanceAudio(!enhanceAudio)}
              className={`relative inline-flex h-5 w-10 shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none ${
                enhanceAudio ? "bg-primary" : "bg-white/15"
              }`}
            >
              <span
                aria-hidden="true"
                className={`pointer-events-none inline-block h-4 w-4 transform rounded-full shadow-md ring-0 transition duration-200 ease-in-out ${
                  enhanceAudio
                    ? "translate-x-5 bg-black"
                    : "translate-x-0 bg-on-surface-variant"
                }`}
              />
            </button>
          </div>
          <p className="text-[11px] text-on-surface-variant/70 leading-relaxed">
            Cắt ù (Low-cut 75Hz), tăng độ sáng & âm xát (Air 9kHz), nén động học
            phát thanh và chuẩn hóa âm lượng.
          </p>
        </div>

        {/* Chuẩn âm lượng phát thanh (EBU R128 / ITU-R BS.1770) */}
        <div className="flex flex-col gap-2.5 p-3.5 rounded-xl bg-surface-dim border border-white/10 hover:border-primary/30 transition-all shadow-inner">
          <div className="flex items-center justify-between">
            <label className="font-label-caps text-xs 2k:text-sm text-on-surface flex items-center gap-2 font-medium">
              <span className="material-symbols-outlined text-primary text-[18px]">
                equalizer
              </span>
              Chuẩn âm lượng (Loudness)
            </label>
            <span className="text-[10px] 2k:text-xs font-mono font-bold text-primary/90 bg-primary/10 px-2 py-0.5 rounded border border-primary/20">
              {useTTSStore.getState().loudnessStandard === "ebu_r128"
                ? "-16 LUFS"
                : useTTSStore.getState().loudnessStandard === "youtube"
                  ? "-14 LUFS"
                  : "Peak"}
            </span>
          </div>

          <div className="grid grid-cols-3 gap-1.5 bg-surface-variant/40 p-1 rounded-lg border border-white/5 text-[11px] font-label-caps">
            <button
              type="button"
              onClick={() => useTTSStore.getState().setLoudnessStandard("ebu_r128")}
              className={`py-1.5 px-1 rounded text-center transition-all ${
                useTTSStore.getState().loudnessStandard === "ebu_r128"
                  ? "bg-primary text-black font-semibold shadow-sm"
                  : "text-on-surface-variant hover:text-on-surface hover:bg-white/5"
              }`}
              title="Chuẩn phát thanh quốc tế EBU R128 (-16 LUFS) cho Podcast, Sách nói & Radio"
            >
              Podcast (-16)
            </button>
            <button
              type="button"
              onClick={() => useTTSStore.getState().setLoudnessStandard("youtube")}
              className={`py-1.5 px-1 rounded text-center transition-all ${
                useTTSStore.getState().loudnessStandard === "youtube"
                  ? "bg-primary text-black font-semibold shadow-sm"
                  : "text-on-surface-variant hover:text-on-surface hover:bg-white/5"
              }`}
              title="Tối ưu cho YouTube, Facebook & Video Shorts (-14 LUFS)"
            >
              YouTube (-14)
            </button>
            <button
              type="button"
              onClick={() => useTTSStore.getState().setLoudnessStandard("peak")}
              className={`py-1.5 px-1 rounded text-center transition-all ${
                useTTSStore.getState().loudnessStandard === "peak"
                  ? "bg-primary text-black font-semibold shadow-sm"
                  : "text-on-surface-variant hover:text-on-surface hover:bg-white/5"
              }`}
              title="Chuẩn hóa theo đỉnh cao nhất (-1.0 dBFS Peak)"
            >
              Peak (-1dB)
            </button>
          </div>
          <p className="text-[10.5px] text-on-surface-variant/70 leading-relaxed">
            {useTTSStore.getState().loudnessStandard === "ebu_r128"
              ? "Chuẩn phát thanh ITU-R BS.1770-4 (-16 LUFS, True-Peak -1.5dB) giúp âm lượng đồng đều và êm ái trên mọi thiết bị."
              : useTTSStore.getState().loudnessStandard === "youtube"
                ? "Tối ưu mức năng lượng to rõ hơn (-14 LUFS) phù hợp video nền YouTube, TikTok & Reels."
                : "Chuẩn hóa theo đỉnh sóng cao nhất truyền thống (-1.0 dBFS)."}
          </p>
        </div>

        {/* Bộ xử lý GPU (Local / Cloud) */}
        <div className="flex items-center justify-between p-3.5 rounded-xl bg-surface-dim border border-white/10 hover:border-primary/30 transition-all">
          <div className="space-y-0.5">
            <span className="font-label-caps text-xs text-on-surface flex items-center gap-1.5 font-medium">
              <Cpu className="w-3.5 h-3.5 text-primary" />
              Bộ Xử Lý (Engine)
            </span>
            <p className="text-[10px] text-on-surface-variant font-mono">
              {useTTSStore.getState().hardwareConfig.use_remote_gpu
                ? "Cloud GPU (Tesla T4)"
                : useTTSStore.getState().hardwareConfig.cuda_device_name || "NVIDIA GTX 1650 (4GB)"}
            </p>
          </div>
          <Link
            to="/settings"
            className="text-[11px] px-2.5 py-1.5 rounded-lg bg-white/5 hover:bg-primary/20 border border-white/10 hover:border-primary/40 text-primary font-semibold flex items-center gap-1 transition-all"
            title="Mở cài đặt chuyển đổi GPU Local và Cloud GPU"
          >
            Đổi GPU
            <ExternalLink className="w-3 h-3" />
          </Link>
        </div>
      </div>

      {/* Action Button */}
      <div className="mt-4 2k:mt-6">
        <button
          type="button"
          id="generate-btn"
          className={`w-full py-4 2k:py-5 px-6 2k:px-8 font-label-caps text-label-caps 2k:text-base rounded-xl 2k:rounded-2xl flex items-center justify-center gap-2 overflow-hidden relative group transition-all duration-300 shadow-[0_4px_14px_0_rgba(245,158,11,0.2)] hover:shadow-[0_6px_20px_rgba(245,158,11,0.3)] hover:-translate-y-0.5 ${isLoading ? "bg-surface-variant text-on-surface-variant cursor-not-allowed shadow-none hover:translate-y-0" : "bg-primary text-on-primary glow-button"}`}
          onClick={onGenerate}
          disabled={isLoading}
        >
          <span
            className={`relative z-10 flex items-center gap-2 text-sm 2k:text-base font-bold ${isLoading ? "hidden" : ""}`}
          >
            <span className="material-symbols-outlined 2k:text-2xl">
              play_arrow
            </span>
            TẠO GIỌNG NÓI
          </span>
          <div
            className={`relative z-10 flex items-center gap-2 text-sm 2k:text-base ${isLoading ? "" : "hidden"}`}
          >
            <span className="material-symbols-outlined animate-spin 2k:text-2xl">
              sync
            </span>
            ĐANG XỬ LÝ...
          </div>
          {!isLoading && (
            <div className="absolute inset-0 bg-white/20 transform -translate-x-full group-hover:translate-x-full transition-transform duration-700 ease-in-out"></div>
          )}
        </button>
      </div>

      {/* Modal Tạo dự án mới nhanh */}
      {isCreateModalOpen && (
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4 animate-in fade-in">
          <div
            className="glass-card rounded-2xl max-w-md w-full p-6 border border-white/10 shadow-2xl flex flex-col gap-5 relative animate-in zoom-in-95 duration-200"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between border-b border-white/5 pb-4">
              <div className="flex items-center gap-2.5">
                <div className="w-9 h-9 rounded-xl bg-primary/10 border border-primary/20 flex items-center justify-center text-primary">
                  <FolderPlus className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="font-label-caps text-sm 2k:text-base text-on-surface font-semibold">
                    Tạo dự án mới
                  </h3>
                  <p className="text-[11px] 2k:text-xs text-on-surface-variant/70">
                    Khởi tạo nhanh dự án để quản lý các đoạn thoại & audio
                  </p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => {
                  setIsCreateModalOpen(false);
                  setNewProjectName("");
                  setNewProjectDesc("");
                }}
                className="p-1.5 rounded-lg hover:bg-white/10 text-on-surface-variant hover:text-on-surface transition-colors cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleCreateProject} className="flex flex-col gap-4">
              <div className="flex flex-col gap-2">
                <label className="text-xs font-label-caps text-on-surface-variant flex items-center gap-1">
                  Tên dự án <span className="text-primary">*</span>
                </label>
                <input
                  type="text"
                  value={newProjectName}
                  onChange={(e) => setNewProjectName(e.target.value)}
                  placeholder="Ví dụ: Báo cáo khảo sát, Video giới thiệu..."
                  className="w-full bg-surface-dim border border-white/10 rounded-xl px-4 py-2.5 text-sm text-on-surface placeholder:text-on-surface-variant/40 focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/50 transition-all font-body-md"
                  autoFocus
                />
              </div>

              <div className="flex flex-col gap-2">
                <label className="text-xs font-label-caps text-on-surface-variant">
                  Mô tả / Ghi chú <span className="text-[10px] text-on-surface-variant/60">(Tùy chọn)</span>
                </label>
                <textarea
                  value={newProjectDesc}
                  onChange={(e) => setNewProjectDesc(e.target.value)}
                  placeholder="Ghi chú ngắn về mục tiêu hoặc đối tượng..."
                  rows={2}
                  className="w-full bg-surface-dim border border-white/10 rounded-xl px-4 py-2 text-sm text-on-surface placeholder:text-on-surface-variant/40 focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/50 transition-all font-body-md resize-none"
                />
              </div>

              <div className="flex items-center justify-end gap-2.5 pt-2 border-t border-white/5">
                <button
                  type="button"
                  onClick={() => {
                    setIsCreateModalOpen(false);
                    setNewProjectName("");
                    setNewProjectDesc("");
                  }}
                  className="px-4 py-2 rounded-xl text-xs font-label-caps text-on-surface-variant hover:text-on-surface hover:bg-white/5 transition-colors cursor-pointer"
                >
                  Hủy
                </button>
                <button
                  type="submit"
                  className="px-5 py-2 rounded-xl bg-primary text-on-primary text-xs font-label-caps font-semibold shadow-lg shadow-primary/20 hover:brightness-110 active:scale-95 transition-all flex items-center gap-1.5 cursor-pointer"
                >
                  <FolderPlus className="w-4 h-4" />
                  Tạo dự án
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
