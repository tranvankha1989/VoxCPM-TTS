' ===================================================
' OmniVoice TTS - Silent Background Launcher (Windows)
' Không hiển thị cửa sổ đen console CMD
' ===================================================

Set WshShell = CreateObject("WScript.Shell")
strPath = WScript.ScriptFullName
strFolder = Left(strPath, InStrRev(strPath, "\"))
WshShell.CurrentDirectory = strFolder

' Khởi chạy FastAPI Backend ẩn hoàn toàn (0 = Hide window)
cmd = """" & strFolder & "backend\venv\Scripts\python.exe"" -m uvicorn main:app --host 0.0.0.0 --port 8000 --app-dir """ & strFolder & "backend"""
WshShell.Run cmd, 0, False

' Chờ 2 giây để server sẵn sàng
WScript.Sleep 2000

' Mở trình duyệt giao diện OmniVoice TTS
WshShell.Run "http://localhost:8000"
