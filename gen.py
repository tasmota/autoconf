import os
import json
from zipfile import *

dir_src = os.path.join((os.path.dirname(os.path.realpath(__file__))), "raw")    # dir of this script
dir_dst = os.path.abspath(dir_src + '/..')

# print(f"dir_src={dir_src}")
# print(f"dir_dst={dir_dst}")

def zip_one(from_path, arch, from_name, to_dir):
	zip_name = os.path.join(to_dir, from_name + "_autoconf.zip")
	# print(f"zip_one({from_path}, {from_name}, {to_dir}), zip_name={zip_name}")
	os.chdir(from_path)
	print(f"Compressing {arch}/{from_name}")
	with ZipFile(zip_name, mode="w", compression=ZIP_STORED, allowZip64=False, compresslevel=None, strict_timestamps=True) as myzip:
		files = os.listdir(from_path)
		for f in files:
			if not f.startswith('.'):
				myzip.write(f)
				# print(f"Compressed: {f}")

# scan a subdir like 'raw/esp32' and zip each directory
def zip_all(from_dir, arch, to_dir):
	zips = []
	for d in sorted(os.listdir(from_dir)):
		if os.path.isdir(os.path.join(from_dir, d)):
			zip_one(os.path.join(from_dir, d), arch, d, to_dir)
			zips.append(d)
	with open(to_dir + "_manifest.json", "w", encoding='utf-8') as f:
		json.dump({'zip':zips}, f, indent=None, separators=(',', ':'))


for d in os.listdir(dir_src):
	if os.path.isdir(os.path.join(dir_src, d)):
		print(f"Compressing {d}")
		zip_all(os.path.join(dir_src, d), d, os.path.join(dir_dst, d))
	  #print(os.path.join(dir_src, d))