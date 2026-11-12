"""Contact sheets of the tour's screenshots: docs/peak/shots/sheet_<area>.jpg
  python tools/peak/sheet.py [a3 a4 ...]
"""
import glob, json, os, sys
from PIL import Image, ImageDraw
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from peaklib import COURSE_DIR, ROOT
SH = os.path.join(ROOT, "docs", "peak", "shots")
want = sys.argv[1:]
# The tour saves PNGs; the showcase and git carry 960 px JPEGs.
for png in glob.glob(os.path.join(SH, "*_*.png")):
    Image.open(png).convert("RGB").resize((960, 540)).save(png[:-4] + ".jpg", quality=84)
    os.remove(png)
for path in sorted(glob.glob(os.path.join(COURSE_DIR, "a*.json"))):
    a = json.load(open(path, encoding="utf-8"))
    if want and a["id"] not in want:
        continue
    cs = [c for c in a["challenges"] if os.path.exists(os.path.join(SH, c["id"].replace(".", "_") + ".jpg"))]
    if not cs:
        continue
    cols = 4
    w, h = 480, 270
    rows = (len(cs) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * w, rows * h), "#201008")
    d = ImageDraw.Draw(sheet)
    for i, c in enumerate(cs):
        im = Image.open(os.path.join(SH, c["id"].replace(".", "_") + ".jpg")).convert("RGB").resize((w, h))
        x, y = (i % cols) * w, (i // cols) * h
        sheet.paste(im, (x, y))
        d.rectangle((x, y, x + 150, y + 16), fill="#000000")
        d.text((x + 4, y + 2), "%s %s" % (c["id"], c["name"][:20]), fill="#FFE080")
    out = os.path.join(SH, "sheet_%s.jpg" % a["id"])
    sheet.save(out, quality=82)
    print(out)
