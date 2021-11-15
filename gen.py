import json
import os
from collections import defaultdict
from zipfile import ZipFile, ZIP_STORED

RAW_DIR = './raw'
zips = defaultdict(list)

for board_dir, _, files in os.walk(RAW_DIR):
    if files := [f for f in files if not f.startswith('.')]:
        a, _, arch, board = board_dir.split('/')
        os.makedirs(arch, exist_ok=True)
        print(f"Compressing {board} for {arch}")

        zipfile_name = os.path.join(arch, f"{board}_autoconf.zip")
        with ZipFile(zipfile_name, mode="w", compression=ZIP_STORED, allowZip64=False, compresslevel=None,
                     strict_timestamps=True) as myzip:
            for file in files:
                filepath = os.path.join(board_dir, file)
                myzip.write(filepath, file)
        zips[arch].append(board)


for arch, zips_list in zips.items():
    with open(f"{arch}_manifest.json", 'w') as manifest:
        json.dump({"zip": sorted(zips_list)}, manifest, indent=None, separators=(',', ':'))
