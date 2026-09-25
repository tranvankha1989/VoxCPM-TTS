import { useEffect } from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { MainLayout } from "./layouts/MainLayout";
import Studio from "./pages/Studio";
import Library from "./pages/Library";
import Projects from "./pages/Projects";
import ProjectDetail from "./pages/ProjectDetail";

import CloningVoice from "./pages/CloningVoice";
import AutoCaption from "./pages/AutoCaption";
import Settings from "./pages/Settings";

export default function App() {
  useEffect(() => {
    // Xac dinh Backend API host tuong ung
    const apiHost = window.location.port === "5173" ? "http://localhost:8000" : "";
    const heartbeatUrl = `${apiHost}/api/system/heartbeat`;

    const sendHeartbeat = () => {
      fetch(heartbeatUrl, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
      }).catch(() => {});
    };

    // Gui heartbeat ngay khi mo tab
    sendHeartbeat();

    // Gui dinh ky moi 2.5 giay
    const intervalId = setInterval(sendHeartbeat, 2500);

    const handleUnload = () => {
      if (navigator.sendBeacon) {
        navigator.sendBeacon(`${apiHost}/api/system/tab-closed`);
      }
    };

    window.addEventListener("beforeunload", handleUnload);
    window.addEventListener("pagehide", handleUnload);

    return () => {
      clearInterval(intervalId);
      window.removeEventListener("beforeunload", handleUnload);
      window.removeEventListener("pagehide", handleUnload);
    };
  }, []);
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<MainLayout />}>
          <Route index element={<Studio />} />
          <Route path="library" element={<Library />} />
          <Route path="projects" element={<Projects />} />
          <Route path="projects/:id" element={<ProjectDetail />} />
          <Route path="cloning-voice" element={<CloningVoice />} />
          <Route path="autocaption" element={<AutoCaption />} />
          <Route path="caption" element={<AutoCaption />} />
          <Route path="settings" element={<Settings />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}
