"""Copy the Top Dog Kit's finished models into the game (res://kit/models/).

The kit's models point their atlas at ../palette/house_atlas.png (the kit's own
folder layout); in the game they live two folders down from res://, so the uri is
rewritten to ../../palette/house_atlas.png, which resolves to the game's one atlas
(res://palette/house_atlas.png) and lets CelPass bind the shared sheet and masks.

Run: python tools/sync_kit.py   (from the repo root; prints what it copied)
"""
import glob
import json
import os
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
KIT = os.path.normpath(os.path.join(ROOT, "..", "Top Dog Kit", "models"))
DEST = os.path.join(ROOT, "kit", "models")
URI = "../../palette/house_atlas.png"


def patch(src, dst):
    b = open(src, "rb").read()
    n = struct.unpack_from("<I", b, 12)[0]
    j = json.loads(b[20:20 + n])
    rest = b[20 + n:]
    for im in j.get("images", []):
        if im.get("uri", "").endswith("house_atlas.png"):
            im["uri"] = URI
    js = json.dumps(j, separators=(",", ":")).encode()
    js += b" " * ((4 - len(js) % 4) % 4)
    out = b"glTF" + struct.pack("<II", 2, 12 + 8 + len(js) + len(rest)) + struct.pack("<I", len(js)) + b"JSON" + js + rest
    if os.path.exists(dst) and open(dst, "rb").read() == out:
        return False
    open(dst, "wb").write(out)
    return True


if __name__ == "__main__":
    os.makedirs(DEST, exist_ok=True)
    for f in sorted(glob.glob(os.path.join(KIT, "*.glb"))):
        name = os.path.basename(f)
        changed = patch(f, os.path.join(DEST, name))
        print(("copied  " if changed else "same    ") + name)
