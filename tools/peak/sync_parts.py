"""Bring in the kit models the makers landed for the Peak (and nothing else):
every .glb in Top Dog Kit/models changed since the night the Peak was begun.
  python tools/peak/sync_parts.py      then run Godot with --import
"""
import datetime, glob, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
import sync_kit as k

SINCE = datetime.datetime(2026, 11, 11, 22, 0).timestamp()
new = []
for src in sorted(glob.glob(os.path.join(k.KIT, "*.glb"))):
    if os.path.getmtime(src) < SINCE:
        continue
    name = os.path.basename(src)
    if k.patch(src, os.path.join(k.DEST, name)):
        new.append(name)
print("%d synced: %s" % (len(new), " ".join(n[:-4] for n in new)))
