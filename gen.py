#!/usr/bin/env python3
"""
Tasmota Autoconf Builder
Builds .autoconf zip files from raw board directories and generates per-arch manifest JSON files.
"""

import json
import os
import shutil
from collections import defaultdict
from pathlib import Path
from zipfile import ZipFile, ZipInfo, ZIP_STORED

RAW_DIR = Path('./raw')

# Fixed timestamp for reproducible zips (year, month, day, hour, min, sec)
FIXED_TIMESTAMP = (2025, 1, 1, 0, 0, 0)

packages = defaultdict(list)

# Walk only one level deep: raw/<arch>/<board>/
for arch_dir in sorted(RAW_DIR.iterdir()):
    if not arch_dir.is_dir() or arch_dir.name.startswith('.'):
        continue

    arch = arch_dir.name
    os.makedirs(arch, exist_ok=True)

    for board_dir in sorted(arch_dir.iterdir()):
        if not board_dir.is_dir() or board_dir.name.startswith('.'):
            continue

        # Collect non-hidden files directly in this board directory (non-recursive)
        files = [f for f in board_dir.iterdir() if f.is_file() and not f.name.startswith('.')]
        if not files:
            continue

        board = board_dir.name
        print(f"Compressing {board} for {arch}")

        zipfile_name = os.path.join(arch, f"{board}.autoconf")
        with ZipFile(zipfile_name, mode="w", compression=ZIP_STORED, allowZip64=False) as myzip:
            for filepath in sorted(files):
                zip_info = ZipInfo(filename=filepath.name)
                zip_info.date_time = FIXED_TIMESTAMP
                zip_info.compress_type = ZIP_STORED
                with open(filepath, 'rb') as f:
                    myzip.writestr(zip_info, f.read())

        packages[arch].append(board)

for arch, packages_list in packages.items():
    with open(f"{arch}_manifest.json", "w") as manifest:
        json.dump({"files": sorted(packages_list, key=str.casefold)}, manifest, indent=None, separators=(",", ":"))

shutil.copytree("esp32", "esp32solo1", dirs_exist_ok=True)
shutil.copy2("esp32_manifest.json", "esp32solo1_manifest.json")
