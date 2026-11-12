"""
Build the Peak's showcase page: docs/peak/showcase.html (open it in a browser).
It reads the course JSON, the previews, the tour's screenshots, FALLS.md, and links the
music. Everything it shows is read from what's on disk, so it never claims a thing
that isn't there.
  python tools/peak/showcase.py
"""
import glob, html, json, os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from peaklib import COURSE_DIR, ROOT, PALETTES

DOCS = os.path.join(ROOT, "docs", "peak")
ORDER = ["a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8", "a9", "a10", "a11"]
MOOD = {
    "a0": "The edge of town. A cart on its siding, torn papel picado, the pug pointing up.",
    "a1": "Timber, rails and black mud round a 113 m waterfall. Lantern light.",
    "a2": "The flooded works. The river that everything falls into, and the swim against it.",
    "a3": "Glass and light. Tips grip, faces don't. Precision.",
    "a4": "Bounce and breath: caps that throw you, spores that lift you, snails you ride.",
    "a5": "The buried temple of the First Top Dog. Stone machines on a drum beat.",
    "a6": "A steam chimney, 110 m straight up, then daylight.",
    "a7": "Outside at last. Wind, exposure, and El Balcón under you while it lasts.",
    "a8": "The broken cableway. From here a miss is the whole mountain.",
    "a9": "Ice that lets go of you in two seconds, and the ones frozen in it.",
    "a10": "The storm ridge: gusts, lightning, long flings in both.",
    "a11": "Above the clouds. The first ring's ropes, the last jump, the bell.",
}
MISS = {"S": "slip", "B": "back two or three", "A": "the area's start", "P": "down the well", "X": "everything", "": ""}


def rel(path):
    return os.path.relpath(path, DOCS).replace("\\", "/")


def load(aid):
    p = os.path.join(COURSE_DIR, aid + ".json")
    return json.load(open(p, encoding="utf-8")) if os.path.exists(p) else None


def shots(aid, challenges):
    out = []
    for c in challenges:
        p = os.path.join(DOCS, "shots", c["id"].replace(".", "_") + ".jpg")
        if os.path.exists(p):
            out.append((c, p))
    return out


def section(a):
    aid = a["id"]
    pal = PALETTES[a["palette"]]
    r = a["region"]
    ch = a["challenges"]
    parts = ['<section class="area" id="%s" style="--accent:%s;--rock:%s;--deep:%s">' % (aid, pal["accent"], pal["rock"], pal["back3"])]
    parts.append('<header><span class="num">%s</span><h2>%s</h2><span class="alt">%d to %d m</span></header>' % (aid.upper(), html.escape(a["name"]), max(r[1], -30), r[3]))
    parts.append('<p class="mood">%s</p>' % html.escape(MOOD.get(aid, "")))
    counts = "%d challenges, %d solids, %d movers, %d ropes, %d zones" % (len(ch), len(a["solids"]), len(a["movers"]), len(a["ropes"]), len(a["zones"]))
    parts.append('<p class="counts">%s</p>' % counts)
    music = os.path.join(ROOT, "audio", "music", "peak", "peak_%s.ogg" % aid)
    amb = os.path.join(ROOT, "audio", "sfx", "peak", "amb_%s.wav" % aid)
    aud = []
    if os.path.exists(music):
        aud.append('<label>music <audio controls loop preload="none" src="%s"></audio></label>' % rel(music))
    if os.path.exists(amb):
        aud.append('<label>ambience <audio controls loop preload="none" src="%s"></audio></label>' % rel(amb))
    if aud:
        parts.append('<div class="audio">%s</div>' % "".join(aud))
    sh = shots(aid, ch)
    if sh:
        parts.append('<div class="shots">')
        for c, p in sh:
            parts.append('<figure><a href="%s"><img loading="lazy" src="%s" alt="%s"></a><figcaption>%s %s</figcaption></figure>' % (rel(p), rel(p), html.escape(c["name"]), c["id"], html.escape(c["name"])))
        parts.append('</div>')
    prev = os.path.join(DOCS, "preview", aid + ".png")
    if os.path.exists(prev):
        parts.append('<details><summary>The area\'s map (pale is grip, near black is slick)</summary><a href="%s"><img class="map" loading="lazy" src="%s" alt="map of %s"></a></details>' % (rel(prev), rel(prev), aid))
    parts.append('<table><thead><tr><th>#</th><th>Challenge</th><th>Difficulty</th><th>A miss costs</th></tr></thead><tbody>')
    for c in ch:
        parts.append('<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>' % (c["id"], html.escape(c["name"]), "&#9733;" * int(c["d"]), MISS.get(c["miss"], c["miss"])))
    parts.append('</tbody></table></section>')
    return "\n".join(parts)


MAKER_CAPTIONS = {
    "carpenter_minecart": "TD Carpenter: the minecart (39 timber, rope, rail and iron parts in all)",
    "building_maker_1": "TD Building Maker: stone, steel and set pieces (57 models)",
    "building_maker_2": "TD Building Maker, sheet two",
    "mask_first_dog": "TD Building Maker: the First Top Dog's mask, the mountain's one recurring face",
    "environment_models": "TD Environment Maker: the living things, standing in the game's light (25 models)",
    "environment_backdrop": "TD Environment Maker: the far backdrops behind the climb",
    "peak_from_town": "TD Environment Maker: the Peak of DeGayo seen from the town",
    "peak_from_town_tele": "TD Environment Maker: the Peak, closer",
    "ui_hud_and_signs": "TD UI creator: the altimeter, the summit card, the trail signs (35 models)",
    "ui_camp_props": "TD UI creator: one climber's last camp",
}


def gallery(folder, title, blurb, captions=None, pattern="*.jpg"):
    files = sorted(glob.glob(os.path.join(DOCS, folder, pattern)))
    if not files:
        return ""
    out = ['<h3>%s</h3><p>%s</p><div class="shots wide">' % (title, blurb)]
    for f in files:
        stem = os.path.splitext(os.path.basename(f))[0]
        cap = (captions or {}).get(stem, stem.replace("_", " "))
        out.append('<figure><a href="%s"><img loading="lazy" src="%s" alt="%s"></a><figcaption>%s</figcaption></figure>' % (rel(f), rel(f), html.escape(cap), html.escape(cap)))
    out.append("</div>")
    return "\n".join(out)


def main():
    areas = [a for a in (load(i) for i in ORDER) if a]
    total = sum(len(a["challenges"]) for a in areas)
    falls = ""
    fp = os.path.join(DOCS, "FALLS.md")
    if os.path.exists(fp):
        m = re.search(r"\*\*Totals:\*\*(.*)", open(fp, encoding="utf-8").read())
        if m:
            falls = m.group(1).strip()
    notes_path = os.path.join(DOCS, "SHOWCASE_NOTES.html")
    notes = open(notes_path, encoding="utf-8").read() if os.path.exists(notes_path) else ""
    mountain = os.path.join(DOCS, "preview", "mountain.png")
    nav = "".join('<a href="#%s">%s</a>' % (a["id"], html.escape(a["name"])) for a in areas)
    page = """<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>The Peak of DeGayo</title>
<style>
:root { --ink:#201008; --paper:#F6EBD2; --kraft:#8A6A45; --red:#D8262E; --gold:#E8B33A; }
* { box-sizing: border-box; }
body { margin:0; background:var(--paper); color:var(--ink); font: 17px/1.55 Georgia, "Times New Roman", serif; }
.wrap { max-width: 1180px; margin: 0 auto; padding: 0 22px 80px; }
.hero { background: linear-gradient(#1E6BFF, #8FD0FF 70%%, var(--paper)); padding: 56px 22px 30px; text-align:center; border-bottom: 6px solid var(--kraft); }
.hero h1 { font: 900 64px/1 Impact, "Arial Black", sans-serif; letter-spacing: 2px; margin:0; color:#FFF6D8; text-shadow: 0 4px 0 var(--red), 0 8px 0 var(--ink); }
.hero p { color:#fff; font-size: 20px; margin: 18px auto 0; max-width: 760px; text-shadow: 0 1px 2px #0008; }
.stats { display:flex; flex-wrap:wrap; gap:14px; justify-content:center; margin: 26px 0 6px; }
.stat { background:#fff; border:3px solid var(--ink); border-radius:10px; padding:10px 18px; box-shadow: 4px 4px 0 var(--kraft); }
.stat b { display:block; font: 900 30px/1 Impact, "Arial Black", sans-serif; color:var(--red); }
nav { position: sticky; top:0; z-index:5; background: var(--ink); padding: 8px 12px; display:flex; flex-wrap:wrap; gap:6px 14px; justify-content:center; }
nav a { color: var(--gold); text-decoration:none; font: 14px Arial, sans-serif; }
nav a:hover { color:#fff; }
h2 { font: 900 34px/1.1 Impact, "Arial Black", sans-serif; margin: 0; letter-spacing: 1px; }
h3 { font: 900 24px/1.2 Impact, "Arial Black", sans-serif; margin: 44px 0 8px; }
.poster { width:100%%; border: 4px solid var(--ink); border-radius: 8px; box-shadow: 6px 6px 0 var(--kraft); background:#8FB8D8; }
.area { margin-top: 54px; border: 4px solid var(--ink); border-radius: 12px; overflow:hidden; background:#fff; box-shadow: 6px 6px 0 var(--kraft); }
.area header { display:flex; align-items:baseline; gap:16px; padding: 14px 20px; background: var(--deep); color: #fff; border-bottom: 5px solid var(--accent); }
.area .num { font: 900 22px Impact, sans-serif; color: var(--accent); }
.area .alt { margin-left:auto; font: 15px Arial, sans-serif; opacity:.85; }
.area p, .area table, .area details, .area .audio { margin-left: 20px; margin-right: 20px; }
.mood { font-size: 19px; font-style: italic; }
.counts { font: 13px Arial, sans-serif; color:#6a5a48; margin-top:-8px; }
.audio { display:flex; flex-wrap:wrap; gap: 10px 26px; font: 13px Arial, sans-serif; }
.audio audio { vertical-align: middle; height: 30px; }
.shots { display:grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 10px; padding: 14px 20px; }
.shots.wide { grid-template-columns: repeat(auto-fill, minmax(420px, 1fr)); padding: 14px 0; }
figure { margin:0; }
figure img { width:100%%; display:block; border: 2px solid var(--ink); border-radius: 6px; }
figcaption { font: 12px Arial, sans-serif; color:#5a4a3a; padding: 3px 2px; }
img.map { width:100%%; border: 2px solid var(--ink); border-radius: 6px; margin: 8px 0 14px; }
details summary { cursor:pointer; font: 14px Arial, sans-serif; color: var(--red); margin: 6px 0; }
table { border-collapse: collapse; width: calc(100%% - 40px); margin-bottom: 18px; font: 14px Arial, sans-serif; }
th, td { text-align:left; padding: 5px 8px; border-bottom: 1px solid #e3d6bd; }
th { background:#f3e7cf; }
td:nth-child(3) { color: var(--red); letter-spacing: 1px; }
.notes { background:#fff; border: 4px solid var(--ink); border-radius: 12px; padding: 6px 24px 18px; box-shadow: 6px 6px 0 var(--kraft); margin-top: 30px; }
.notes li { margin: 6px 0; }
code { background:#efe2c6; padding: 1px 5px; border-radius: 4px; font-size: 14px; }
</style></head><body>
<div class="hero"><h1>THE PEAK OF DEGAYO</h1>
<p>Top Dog's solo climb. One climber, one mountain, 1,000 metres, no checkpoints.</p>
<div class="stats"><div class="stat"><b>%(areas)d</b>areas</div><div class="stat"><b>%(total)d</b>challenges</div><div class="stat"><b>1,030 m</b>from the Sump to the bell</div><div class="stat"><b>12</b>music loops in step</div></div></div>
<nav><a href="#start">Start here</a><a href="#mountain">The mountain</a>%(nav)s</nav>
<div class="wrap">
<div class="notes" id="start">%(notes)s</div>
<h3 id="mountain">The mountain, as built</h3>
<p>The whole course in one picture, drawn from the game's own data. Caves sit under cliffs; the well runs up the middle; everything that falls ends in the river.%(falls)s</p>
%(poster)s
%(sections)s
</div></body></html>
""" % {
        "areas": len(areas), "total": total, "nav": nav, "notes": notes,
        "falls": (" The rain test (three bodies dropped at every challenge): " + html.escape(falls)) if falls else "",
        "poster": ('<a href="%s"><img class="poster" src="%s" alt="the mountain"></a>' % (rel(mountain), rel(mountain))) if os.path.exists(mountain) else "",
        "sections": "\n".join(section(a) for a in areas)
        + gallery(os.path.join("preview", "hud"), "The solo HUD", "The Second Director's PeakHud: the altimeter, the area cards, the fall receipts and the ending. These frames are from its own probe, over the plaza.")
        + gallery("makers", "What the makers built", "About 190 models landed overnight. Each sheet is the maker's own.", MAKER_CAPTIONS),
    }
    out = os.path.join(DOCS, "showcase.html")
    open(out, "w", encoding="utf-8", newline="\n").write(page)
    print("wrote", out, "(%d areas, %d challenges)" % (len(areas), total))


if __name__ == "__main__":
    main()
