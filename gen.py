import json
import os
from collections import defaultdict
from zipfile import ZipFile, ZIP_STORED

RAW_DIR = './raw'
packages = defaultdict(list)

for board_dir, _, files in os.walk(RAW_DIR):
    if files := [f for f in files if not f.startswith('.')]:
        a, _, arch, board = board_dir.split('/')
        os.makedirs(arch, exist_ok=True)
        print(f"Compressing {board} for {arch}")

        zipfile_name = os.path.join(arch, f"{board}.autoconf")
        with ZipFile(zipfile_name, mode="w", compression=ZIP_STORED, allowZip64=False, compresslevel=None,
                     strict_timestamps=True) as myzip:
            for file in files:
                filepath = os.path.join(board_dir, file)
                myzip.write(filepath, file)
        packages[arch].append(board)


for arch, packages_list in packages.items():
    with open(f"{arch}_manifest.json", "w") as manifest:
        json.dump({"files": sorted(packages_list)}, manifest, indent=None, separators=(",", ":"))
