import os
import zipfile
from pathlib import Path

def package_macos():
    root_dir = Path(__file__).resolve().parent.parent
    dist_dir = root_dir / "dist_installer"
    dist_dir.mkdir(parents=True, exist_ok=True)
    zip_path = dist_dir / "OmniVoice_TTS_macOS_Setup_v2.2.0.zip"
    
    print("[*] Packaging macOS zip with POSIX executable permissions (chmod 0755)...")
    
    if zip_path.exists():
        zip_path.unlink()
        
    with zipfile.ZipFile(zip_path, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zipf:
        # 1. Cac file script o root
        for f in root_dir.glob("*.command"):
            add_file_with_perms(zipf, f, f.name, is_exec=True)
            print(f"  + Executable file (+x): {f.name}")
            
        for f in root_dir.glob("*.sh"):
            add_file_with_perms(zipf, f, f.name, is_exec=True)
            print(f"  + Executable file (+x): {f.name}")
            
        for f in ["HUONG_DAN_CAI_DAT_MAC.txt", "README.md"]:
            p = root_dir / f
            if p.exists():
                add_file_with_perms(zipf, p, f, is_exec=False)
                
        # 2. Thu muc assets
        assets_dir = root_dir / "assets"
        if assets_dir.exists():
            for root, _, files in os.walk(assets_dir):
                for file in files:
                    full_p = Path(root) / file
                    rel_p = full_p.relative_to(root_dir)
                    add_file_with_perms(zipf, full_p, str(rel_p).replace('\\', '/'), is_exec=False)
                    
        # 3. Thu muc frontend/dist
        fe_dist = root_dir / "frontend" / "dist"
        if fe_dist.exists():
            for root, _, files in os.walk(fe_dist):
                for file in files:
                    full_p = Path(root) / file
                    rel_p = full_p.relative_to(root_dir)
                    add_file_with_perms(zipf, full_p, str(rel_p).replace('\\', '/'), is_exec=False)

        # 4. Thu muc notebooks va HDSD
        for doc_dir_name in ["notebooks", "HDSD"]:
            doc_dir = root_dir / doc_dir_name
            if doc_dir.exists():
                for root, _, files in os.walk(doc_dir):
                    for file in files:
                        full_p = Path(root) / file
                        rel_p = full_p.relative_to(root_dir)
                        add_file_with_perms(zipf, full_p, str(rel_p).replace('\\', '/'), is_exec=False)
                    
        # 4. Thu muc backend (bo venv, outputs, __pycache__, scratch)
        be_dir = root_dir / "backend"
        if be_dir.exists():
            for root, dirs, files in os.walk(be_dir):
                dirs[:] = [d for d in dirs if d not in ('venv', '__pycache__', 'outputs') and not d.startswith('scratch')]
                for file in files:
                    if file.startswith('scratch') or file.endswith(('.pyc', '.pt')):
                        continue
                    full_p = Path(root) / file
                    rel_p = full_p.relative_to(root_dir)
                    is_exec = file.endswith(('.sh', '.command')) or file == 'ffmpeg'
                    add_file_with_perms(zipf, full_p, str(rel_p).replace('\\', '/'), is_exec=is_exec)

    print(f"[OK] Created package successfully: {zip_path}")
    print(f"     Size: {zip_path.stat().st_size / (1024*1024):.2f} MB")

def add_file_with_perms(zipf, filepath, arcname, is_exec=False):
    data = filepath.read_bytes()
    zinfo = zipfile.ZipInfo(arcname)
    zinfo.date_time = (2026, 9, 25, 12, 0, 0)
    zinfo.compress_type = zipfile.ZIP_DEFLATED
    # 0o100755 = regular file + rwxr-xr-x (0o755)
    # 0o100644 = regular file + rw-r--r-- (0o644)
    if is_exec:
        zinfo.external_attr = 0o100755 << 16
    else:
        zinfo.external_attr = 0o100644 << 16
    zipf.writestr(zinfo, data)

if __name__ == '__main__':
    package_macos()
