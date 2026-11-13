# Builds the test diorama page for challenge 1.10, El Derrumbe.
# Every play-space shape is drawn from the course file's own numbers (a1.json at HEAD).
import io, os

OUT = r"C:\Users\Parke\OneDrive\Desktop\Clod Things\TopDog-luchador\docs\peak\playtest\design\1_10_el_derrumbe.html"
os.makedirs(os.path.dirname(OUT), exist_ok=True)

# ------------------------------------------------------------------ elevation sketch
S = 24.0                      # px per metre
X0, X1, Y0, Y1 = -232.0, -211.5, 54.5, 81.5
W, H = (X1 - X0) * S, (Y1 - Y0) * S


def sx(x): return round((x - X0) * S, 1)
def sy(y): return round((Y1 - y) * S, 1)


def rect(x0, y0, x1, y1, cls, extra=""):
    return '<rect x="%s" y="%s" width="%s" height="%s" class="%s" %s/>' % (sx(x0), sy(y1), round((x1 - x0) * S, 1), round((y1 - y0) * S, 1), cls, extra)


def poly(pts, cls, extra=""):
    return '<polygon points="%s" class="%s" %s/>' % (" ".join("%s,%s" % (sx(x), sy(y)) for x, y in pts), cls, extra)


def line(x0, y0, x1, y1, cls, extra=""):
    return '<line x1="%s" y1="%s" x2="%s" y2="%s" class="%s" %s/>' % (sx(x0), sy(y0), sx(x1), sy(y1), cls, extra)


def circ(x, y, r, cls, extra=""):
    return '<circle cx="%s" cy="%s" r="%s" class="%s" %s/>' % (sx(x), sy(y), round(r * S, 1), cls, extra)


def tag(n, x, y):
    return ('<g class="tag"><circle cx="%s" cy="%s" r="9"/><text x="%s" y="%s">%s</text></g>'
            % (sx(x), sy(y), sx(x), sy(y) + 4, n))


e = []
e.append('<rect x="0" y="0" width="%s" height="%s" class="void"/>' % (W, H))

# ---- BACKGROUND (proposed), drawn first
# far wall of the gallery and of the top drift
e.append(rect(-230, 57.4, -222.1, 62.0, "bgwall"))
e.append(rect(-230, 72.0, -222.1, 76.0, "bgwall"))
# the shaft's back wall: plank lining, one timber frame every 1.3 m
e.append(rect(-222.1, 61.7, -218.5, 77.0, "bglag"))
yy = 61.9
while yy < 77.0:
    e.append(line(-222.1, yy, -218.5, yy, "bgplank"))
    yy += 0.43
SETS = [63.0, 64.3, 65.2, 66.5, 67.8, 68.7, 70.0, 70.9, 72.2, 73.5, 74.8, 76.1]
for y in SETS:
    e.append(rect(-222.1, y - 0.16, -218.5, y, "bgset"))
# back corner posts
e.append(rect(-222.1, 61.7, -221.85, 77.0, "bgset"))
e.append(rect(-218.75, 61.7, -218.5, 77.0, "bgset"))
# two planks missing, dark rock showing
e.append(rect(-220.9, 71.2, -219.2, 71.63, "bghole"))
e.append(rect(-221.6, 73.8, -220.4, 74.23, "bghole"))
# the chimney the rocks come from (note 12)
e.append(poly([(-221.3, 77.0), (-219.3, 77.0), (-219.5, 81.2), (-221.0, 81.2)], "chimney"))
# scars down the back wall where the rocks fall
e.append(line(-220.4, 77.0, -220.4, 62.2, "scar"))
e.append(line(-220.2, 77.0, -220.2, 62.2, "scar"))
# the ladder way behind: half landings behind each stub, and ladders
STUBS = [("E", 63.0, 0.75), ("E", 64.3, 0.75), ("W", 65.2, 0.75), ("W", 66.5, 0.6), ("W", 67.8, 0.75),
         ("E", 68.7, 0.75), ("E", 70.0, 0.6), ("W", 70.9, 0.75)]
for side, top, ln in STUBS:
    if side == "E":
        e.append(rect(-220.1, top - 0.34, -218.5, top - 0.2, "bgland"))
    else:
        e.append(rect(-222.1, top - 0.34, -220.5, top - 0.2, "bgland"))


def ladder(x, y0, y1, broken=False):
    out = [line(x - 0.22, y0, x - 0.22, y1, "bgladder"), line(x + 0.22, y0, x + 0.22, y1, "bgladder")]
    y = y0 + 0.3
    while y < y1 - 0.1:
        if not (broken and (y1 - y) < (y1 - y0) * 0.45):
            out.append(line(x - 0.22, y, x + 0.22, y, "bgladder"))
        y += 0.32
    return "".join(out)


e.append(ladder(-219.0, 62.2, 64.0))
e.append(ladder(-221.6, 65.1, 67.5))
e.append(ladder(-219.0, 68.5, 69.7, broken=True))
e.append(ladder(-221.6, 70.8, 71.9))
# a lantern left on a landing (moved out of the rocks' way)
e.append(circ(-221.75, 68.05, 0.17, "lamp"))
# the hoist's wheel, knocked crooked, at the shaft's head
e.append(circ(-219.35, 76.0, 0.55, "bgwheel"))
e.append(line(-219.9, 76.75, -218.6, 75.4, "bgladder"))
# rubble spilling back, a crushed bucket and its coiled cable
e.append(poly([(-225.4, 57.4), (-223.6, 58.7), (-221.6, 60.4), (-219.4, 62.0), (-218.5, 62.3), (-218.5, 57.4)], "bgrubble"))
e.append(circ(-222.9, 58.35, 0.5, "bgwheel"))
e.append(circ(-224.6, 57.62, 0.3, "bgwheel"))
# lower station: timber frames along the gallery's back wall, a boarded side tunnel, a warning sign
for x in (-229.0, -226.9, -224.4):
    e.append(rect(x - 0.17, 57.4, x + 0.17, 61.7, "bgset"))
e.append(rect(-230, 61.55, -222.1, 61.85, "bgset"))
e.append(poly([(-226.6, 57.4), (-226.6, 59.6), (-225.7, 60.3), (-224.8, 59.6), (-224.8, 57.4)], "bghole"))
e.append(line(-226.6, 57.6, -224.8, 59.5, "bgladder"))
e.append(line(-226.6, 59.5, -224.8, 57.6, "bgladder"))
e.append(poly([(-223.9, 59.2), (-223.45, 59.65), (-223.0, 59.2), (-223.45, 58.75)], "bgsign"))
e.append(line(-223.45, 57.4, -223.45, 58.75, "bgladder"))
# upper station: frames, the hand winch that served the shaft
for x in (-229.0, -226.6):
    e.append(rect(x - 0.17, 72.0, x + 0.17, 75.8, "bgset"))
e.append(rect(-230, 75.65, -222.1, 75.95, "bgset"))
e.append(rect(-224.3, 72.0, -222.7, 72.35, "bgset"))
e.append(circ(-223.5, 73.0, 0.6, "bgwheel"))
e.append(line(-223.5, 73.0, -224.5, 73.7, "bgladder"))
# cut faces of the rock: an ore vein and the sawn ends of the frames
e_face = []

# ---- PLAY SPACE (as it is in the course today)
e.append(rect(-230, 55.0, -218.5, 57.1, "slick"))                      # under the gallery
e.append(rect(-230, 56.9, -218.5, 57.4, "rockfloor"))                  # the gallery floor
e.append(rect(-230.6, 57.0, -229.6, 57.4, "wood"))                     # porch plank
e.append(rect(-230, 62.0, -222.1, 71.7, "slick"))                      # the rock between the two levels
e.append(rect(-230, 71.5, -222.1, 72.0, "rockfloor"))                  # the top drift's floor
e.append(rect(-232, 71.65, -229.6, 72.0, "wood"))                      # its balcony (runs on west)
e.append(poly([(-218.5, 84.13), (-218.5, 55.0), (-214.5, 55.0), (-214.5, 81.0)], "slick"))   # east wall
e.append(rect(-214.5, 55.0, -211.5, 59.0, "slick"))
e.append(poly([(-218.5, 77.0), (-218.5, 81.5), (-219.3, 81.5), (-219.3, 77.0)], "slick"))    # roof, east of the chimney
e.append(poly([(-222.1, 77.0), (-221.3, 77.0), (-221.3, 81.5), (-222.1, 81.5)], "slick"))    # roof, west of it
e.append(rect(-225.5, 76.0, -222.1, 81.5, "slick"))
e.append(rect(-230, 76.0, -225.5, 81.5, "slick"))
e.append(poly([(-223.2, 57.4), (-218.4, 57.4), (-218.4, 61.7)], "rockfloor"))                # rubble slope
e.append(poly([(-222.78, 57.62), (-218.62, 61.62), (-218.88, 61.88), (-223.03, 57.88)], "wood"))  # fallen cap beam
for side, top, ln in STUBS:
    if side == "E":
        e.append(rect(-218.5 - ln, top - 0.3, -218.3, top, "wood"))
    else:
        e.append(rect(-222.3, top - 0.3, -222.1 + ln, top, "wood"))
e.append(poly([(-225.1, 57.42), (-223.95, 57.95), (-223.9, 57.82), (-225.05, 57.3)], "wood"))  # the snapped board (note 9)
e.append(circ(-220.4, 73.6, 0.42, "rock"))
e.append(circ(-220.2, 65.9, 0.42, "rock"))
# gallery and drift mouths (the kit's frames, already there)
for y in (57.4, 72.0):
    e.append(rect(-230.15, y, -229.85, y + 4.1, "wood"))
# a climber for scale (1.8 m), on the 66.5 stub
e.append('<g class="man" transform="translate(%s,%s)"><circle cx="0" cy="-39" r="5"/><line x1="0" y1="-34" x2="0" y2="-14"/><line x1="0" y1="-14" x2="-5" y2="0"/><line x1="0" y1="-14" x2="5" y2="0"/><line x1="0" y1="-29" x2="-9" y2="-36"/><line x1="0" y1="-29" x2="8" y2="-22"/></g>' % (sx(-221.75), sy(66.5)))

# ---- on the rock's cut faces (flush with the play space, cover nothing)
e.append(poly([(-229.6, 63.2), (-229.2, 63.0), (-222.6, 70.2), (-223.0, 70.5)], "vein"))
for side, top, ln in STUBS:
    xx = -222.85 if side == "W" else -218.1
    e.append(rect(xx, top - 0.3, xx + 0.3, top, "butt"))
for y in (72.2, 73.5, 74.8):
    e.append(rect(-218.1, y - 0.3, -217.8, y, "butt"))

# ---- FOREGROUND (proposed, sparse): the shaft's two front posts, standing over rock only
for y0, y1 in ((62.0, 64.6), (65.9, 69.3), (70.3, 71.7)):
    e.append(rect(-222.42, y0, -222.12, y1, "fg"))
for y0, y1 in ((61.9, 63.4), (65.0, 68.0), (70.6, 74.2), (75.2, 77.0)):
    e.append(rect(-218.48, y0, -218.18, y1, "fg"))
e.append(poly([(-232, 54.5), (-232, 55.2), (-228.5, 55.45), (-224.0, 55.1), (-219.0, 55.4), (-214.0, 55.05), (-211.5, 55.3), (-211.5, 54.5)], "fg", 'style="opacity:.55"'))
for x, y in ((-227.2, 66.4), (-216.3, 70.2), (-213.2, 63.0), (-225.3, 74.4), (-221.0, 79.3)):
    e.append(circ(x, y, 0.07, "mote"))

# ---- what the screen shows with the close camera (11 m of height)
e.append('<rect x="%s" y="%s" width="%s" height="%s" class="frame"/>' % (sx(-230.05), sy(74.9), round(19.5 * S, 1), round(11.0 * S, 1)))
e.append('<text x="%s" y="%s" class="lbl">what the screen shows (close camera)</text>' % (sx(-229.9), sy(74.9) - 5))

# ---- numbered tags
TAGS = [(1, -220.3, 79.6), (2, -219.35, 75.2), (3, -220.3, 72.6), (4, -220.75, 68.55), (5, -221.6, 66.0),
        (6, -222.9, 59.2), (7, -225.7, 58.6), (8, -223.45, 60.15), (9, -223.5, 74.0), (10, -226.4, 66.9),
        (11, -222.9, 64.6), (12, -217.85, 66.6), (13, -221.0, 62.55)]
for n, x, y in TAGS:
    e.append(tag(n, x, y))

ELEV = '<svg viewBox="0 0 %s %s" class="sk" role="img" aria-label="Side view of the cave-in shaft, to scale, with the three layers in three colours">%s</svg>' % (W, H, "".join(e))

# ------------------------------------------------------------------ depth sketch (seen from above)
DS = 34.0
DX0, DX1 = -225.5, -215.0
Z_FRONT, Z_BACK = 3.2, -7.2
DW, DH = (DX1 - DX0) * DS, (Z_FRONT - Z_BACK) * DS


def dx(x): return round((x - DX0) * DS, 1)
def dz(z): return round((z - Z_BACK) * DS, 1)        # camera at the bottom


def drect(x0, z0, x1, z1, cls, extra=""):
    zt, zb = min(dz(z0), dz(z1)), max(dz(z0), dz(z1))
    return '<rect x="%s" y="%s" width="%s" height="%s" class="%s" %s/>' % (dx(x0), zt, round((x1 - x0) * DS, 1), round(zb - zt, 1), cls, extra)


d = ['<rect x="0" y="0" width="%s" height="%s" class="void"/>' % (DW, DH)]
# bands
d.append(drect(DX0, 1.2, DX1, Z_FRONT, "band_fg"))
d.append(drect(DX0, -1.2, DX1, 1.2, "band_play"))
d.append(drect(DX0, -2.7, DX1, -1.2, "band_bg"))
d.append(drect(DX0, Z_BACK, DX1, -2.7, "band_far"))
# rock either side of the shaft, all the way back
d.append(drect(DX0, -2.7, -222.1, 1.2, "slick"))
d.append(drect(-218.5, -2.7, DX1, 1.2, "slick"))
# back wall of planks, back posts
d.append(drect(-222.1, -2.7, -218.5, -2.5, "bglag"))
d.append(drect(-222.1, -2.5, -221.85, -2.25, "bgset"))
d.append(drect(-218.75, -2.5, -218.5, -2.25, "bgset"))
# the ladder way: a half landing on the west, a ladder against the back wall
d.append(drect(-222.1, -2.45, -220.5, -1.35, "bgland"))
d.append(drect(-221.85, -2.45, -221.35, -2.15, "bgladderbox"))
d.append('<circle cx="%s" cy="%s" r="5" class="lamp"/>' % (dx(-221.75), dz(-1.7)))
# the divider that broke: its west stub is the hold
d.append(drect(-222.3, -0.17, -221.5, 0.17, "wood"))
d.append('<line x1="%s" y1="%s" x2="%s" y2="%s" class="ghost"/>' % (dx(-221.5), dz(0), dx(-218.5), dz(0)))
# rocks' lanes
d.append('<circle cx="%s" cy="%s" r="%s" class="rock"/>' % (dx(-220.4), dz(0.05), round(0.42 * DS, 1)))
# front posts over the rock
d.append(drect(-222.42, 1.2, -222.12, 1.5, "fg"))
d.append(drect(-218.48, 1.2, -218.18, 1.5, "fg"))
# sawn ends on the cut faces
d.append(drect(-222.85, 1.1, -222.55, 1.2, "butt"))
# far layers
d.append('<line x1="0" y1="%s" x2="%s" y2="%s" class="bgplank"/>' % (dz(-3.0), DW, dz(-3.0)))
d.append('<line x1="0" y1="%s" x2="%s" y2="%s" class="bgplank"/>' % (dz(-6.0), DW, dz(-6.0)))
# labels: the bands are named in a gutter on the right, the pieces from the rock either side
GUT = 232
lab = [
    (dz(2.2), "FOREGROUND", "two thin posts, over the rock"),
    (dz(0.0), "PLAY SPACE", "1.2 m either side of you"),
    (dz(-1.95), "BACKGROUND, near", "the ladder way, 1.2 to 2.7 m back"),
    (dz(-4.9), "BACKGROUND, far", "painted layers 3, 6 and 10 m back"),
]
for y, t1, t2 in lab:
    d.append('<text x="%s" y="%s" class="lbl" style="font-weight:700">%s</text>' % (DW + 12, y - 3, t1))
    d.append('<text x="%s" y="%s" class="lbl2">%s</text>' % (DW + 12, y + 12, t2))
d.append('<text x="%s" y="%s" class="lbl2" text-anchor="end">the stub you hold</text>' % (dx(-222.45), dz(0) + 4))
d.append('<text x="%s" y="%s" class="lbl2">the rest: gone</text>' % (dx(-218.35), dz(0) + 4))
d.append('<text x="%s" y="%s" class="lbl2" text-anchor="end">its landing, still there</text>' % (dx(-222.25), dz(-1.9) + 4))
d.append('<text x="%s" y="%s" class="lbl2">back wall of planks</text>' % (dx(-218.35), dz(-2.6) + 4))
d.append('<text x="%s" y="%s" class="lbl2" text-anchor="end">front post</text>' % (dx(-222.55), dz(1.55) + 4))
d.append('<line x1="%s" y1="%s" x2="%s" y2="%s" class="arrow"/>' % (DW / 2, DH + 24, DW / 2, DH + 6))
d.append('<polygon points="%s,%s %s,%s %s,%s" fill="#f1eadf"/>' % (DW / 2, DH + 2, DW / 2 - 5, DH + 11, DW / 2 + 5, DH + 11))
d.append('<text x="%s" y="%s" class="lbl2">the camera looks this way</text>' % (DW / 2 + 12, DH + 21))
DEPTH = '<svg viewBox="0 0 %s %s" class="sk" role="img" aria-label="The shaft seen from above, showing how far back each layer sits">%s</svg>' % (DW + GUT, DH + 30, "".join(d))

# ------------------------------------------------------------------ the page
PAGE = r'''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Diorama 1.10: El Derrumbe (test design)</title>
<style>
  :root { --bg:#f6f1e7; --card:#fffdf8; --ink:#1f1a17; --soft:#6b625a; --line:#d9cfbf; --red:#c8322b; --gold:#b7791f; --green:#2f7d4f; --blue:#2b6cb0; --quote:#f0e6d2; }
  @media (prefers-color-scheme: dark) { :root { --bg:#171412; --card:#211d1a; --ink:#f1eadf; --soft:#a99f94; --line:#3a332d; --red:#ef6b63; --gold:#e0a84a; --green:#6cc493; --blue:#7fb4ea; --quote:#2b2520; } }
  * { box-sizing: border-box; }
  body { margin:0; background:var(--bg); color:var(--ink); font:16px/1.55 "Segoe UI", system-ui, sans-serif; }
  main { max-width:1000px; margin:0 auto; padding:28px 22px 80px; }
  h1 { font-size:28px; margin:0 0 4px; } h2 { font-size:20px; margin:34px 0 8px; } h3 { font-size:16px; margin:18px 0 4px; }
  p { margin:6px 0; } .sub { color:var(--soft); }
  ul, ol { margin:6px 0; padding-left:22px; } li { margin:3px 0; }
  table { border-collapse:collapse; width:100%; background:var(--card); border:1px solid var(--line); margin:8px 0; }
  th, td { text-align:left; padding:7px 10px; border-bottom:1px solid var(--line); vertical-align:top; }
  th { font-size:13px; letter-spacing:.05em; text-transform:uppercase; color:var(--soft); }
  blockquote { margin:10px 0; padding:10px 14px; background:var(--quote); border-left:4px solid var(--gold); border-radius:0 6px 6px 0; }
  .ask { border-left:4px solid var(--red); padding:8px 12px; margin:12px 0; background:var(--quote); border-radius:0 6px 6px 0; }
  .two { display:grid; grid-template-columns: minmax(0, 1.25fr) minmax(0, 1fr); gap:22px; align-items:start; }
  @media (max-width: 860px) { .two { grid-template-columns: 1fr; } }
  figure { margin:10px 0; } figcaption { color:var(--soft); font-size:14px; margin-top:4px; }
  .sk { width:100%; height:auto; border:1px solid var(--line); border-radius:6px; display:block; background:#17120f; }
  .key span { display:inline-block; width:14px; height:14px; border-radius:3px; vertical-align:-2px; margin-right:5px; }
  .key { display:flex; flex-wrap:wrap; gap:6px 18px; font-size:14px; margin:6px 0 2px; }
  /* sketch styles: one colour family per layer */
  .void { fill:#17120f; }
  .slick { fill:#3a2616; stroke:#0f0b08; stroke-width:1.5; }
  .rockfloor { fill:#a37747; stroke:#0f0b08; stroke-width:1.5; }
  .wood { fill:#e39a3c; stroke:#0f0b08; stroke-width:1.5; }
  .rock { fill:#d8b98a; stroke:#0f0b08; stroke-width:1.5; }
  .bgwall { fill:#262b33; }
  .bglag { fill:#2f3742; }
  .bgplank { stroke:#46536380; stroke-width:1; }
  .bgset { fill:#4f6076; }
  .bgland { fill:#6f86a3; }
  .bgladder { stroke:#6f86a3; stroke-width:1.6; fill:none; }
  .bgladderbox { fill:#6f86a3; }
  .bgwheel { fill:none; stroke:#6f86a3; stroke-width:2.2; }
  .bgrubble { fill:#3b4553; }
  .bghole { fill:#0d0f12; stroke:#4f6076; stroke-width:1; }
  .bgsign { fill:#6f86a3; }
  .chimney { fill:#050505; stroke:#4f6076; stroke-width:1; }
  .scar { stroke:#8fa4be; stroke-width:1; stroke-dasharray:3 5; }
  .lamp { fill:#ffd36a; }
  .vein { fill:#e0b040; opacity:.55; }
  .butt { fill:#e39a3c; opacity:.7; stroke:#0f0b08; stroke-width:.8; }
  .fg { fill:#d05cc4; opacity:.85; stroke:#2a0f27; stroke-width:1; }
  .mote { fill:#d05cc4; }
  .frame { fill:none; stroke:#ffffff; stroke-width:1.2; stroke-dasharray:7 6; opacity:.6; }
  .lbl { fill:#f1eadf; font:12px "Segoe UI", sans-serif; opacity:.9; }
  .lbl2 { fill:#f1eadf; font:11px "Segoe UI", sans-serif; opacity:.85; }
  .tag circle { fill:#fffdf8; stroke:#1a1310; stroke-width:1.5; } .tag text { fill:#1a1310; font:bold 11px "Segoe UI", sans-serif; text-anchor:middle; }
  .man circle, .man line { stroke:#ffffff; stroke-width:2.2; fill:none; stroke-linecap:round; }
  .band_fg { fill:#d05cc41c; } .band_play { fill:#e39a3c1c; } .band_bg { fill:#6f86a326; } .band_far { fill:#0b0d10; }
  .ghost { stroke:#e39a3c; stroke-width:1.5; stroke-dasharray:4 5; opacity:.8; }
  .arrow { stroke:#f1eadf; stroke-width:2; marker-end:none; }
</style>
</head>
<body>
<main>

<p class="sub"><a href="../PLAYTEST_NOTES.html#design">Back to the playtest page, "Area and background design"</a></p>
<h1>Diorama 1.10: El Derrumbe</h1>
<p class="sub">The mine, the cave-in shaft with the falling rocks. A test of what one area's design looks like. Design only: nothing here has been built, and nothing is modelled until the whole mountain has been playtested.</p>

<h2>The place, in one paragraph</h2>
<p>This was the miners' way between two levels of the mine: a timber-lined shaft, 3.6 m wide and 15 m tall, with a hoist in the front half to haul ore up and a ladder way in the back half for the men. Then the roof came in. The falling rock went down the middle of the shaft and snapped every cross-beam on its way. What is left sticking out of the two walls are the broken ends of those beams, and they are your holds. The ladders behind are still mostly there, out of reach. The roof is still coming down.</p>

<h2>What must not change</h2>
<p>The play is right, so the design is built round it and moves none of it.</p>
<ul>
  <li>The eight timber stubs, each exactly where it is: two on the east wall, three on the west, two on the east, one on the west.</li>
  <li>The shaft's width, its slick walls, the rubble slope and the fallen beam at its foot.</li>
  <li>The two lines the rocks fall down, 20 cm apart in the middle of the shaft, and their rhythm (note 11).</li>
  <li>Tonight's notes are folded in: the rocks leave by the snapped board (note 9, done), their smaller hit (note 10, done), and the dark chimney they come out of (note 12, sent to the thread).</li>
</ul>

<h2>The sketches</h2>
<p>Both are to scale and drawn from the course file's own numbers. Everything orange and brown is the play space as it is in the game today. Everything blue-grey and everything pink is proposed.</p>
<div class="key">
  <div><span style="background:#6f86a3"></span>Background (proposed)</div>
  <div><span style="background:#e39a3c"></span>Play space: wood you hold (as it is)</div>
  <div><span style="background:#3a2616;border:1px solid #777"></span>Play space: slick rock (as it is)</div>
  <div><span style="background:#d05cc4"></span>Foreground (proposed)</div>
</div>
<div class="two">
  <figure>
    __ELEV__
    <figcaption>From the side, as the camera sees it. The dashed box is one screen with the close camera of note 7. The stick figure is a climber, 1.8 m, on a west stub. Numbers match the lists below.</figcaption>
  </figure>
  <figure>
    __DEPTH__
    <figcaption>From above, cut through the shaft at one stub. This is the part a side view can't show: how far back each thing sits. The stub you hold is the stump of a beam; the half of the shaft behind it is the ladder way.</figcaption>
  </figure>
</div>

<h2>The three layers</h2>

<h3>Background</h3>
<ol>
  <li value="1"><b>The chimney.</b> The hole in the roof the rocks fall out of, black inside, with snapped roof timbers and torn planking hanging round its mouth. (Note 12.)</li>
  <li value="2"><b>The hoist's wheel,</b> knocked crooked at the head of the shaft. It says what this shaft was for. No cable hangs from it: a hanging line reads as something to hold (notes 4 and 18). The cable is down at the bottom, see 6.</li>
  <li value="3"><b>The shaft's back wall:</b> plank lining held by a timber frame every 1.3 m, some planks gone with dark rock showing. Two pale scars run down its middle where the rocks have been scraping it. Those scars are the warning: they mark the two lines the rocks fall down, before you have seen a rock.</li>
  <li value="4"><b>A lantern left on a landing.</b> Today a lantern hangs in the very middle of the shaft, in the path of the rocks. It moves here, behind the play space, where it lights the back wall so a falling rock shows up dark against it.</li>
  <li value="5"><b>The ladder way.</b> In the back half of the shaft: a half landing behind every stub, and short ladders between them, one snapped. You can see the easy way up that the miners had, and you can't get to it.</li>
  <li value="6"><b>The foot of the fall.</b> The rubble heap carries on back into the scene behind the slope you walk up. Half buried in it: the hoist's crushed bucket (the kit's ore bucket) and its cable in a heap.</li>
  <li value="7"><b>The lower level's back wall:</b> timber frames along the gallery, and a side tunnel boarded shut with two planks nailed across.</li>
  <li value="8"><b>A warning sign</b> beside the rubble: the mine's skull-pug diamond, for falling rock. The kit has it.</li>
  <li value="9"><b>The upper level:</b> timber frames, and the hand winch that worked the hoist, standing at the shaft's edge with its handle in the air.</li>
</ol>

<h3>Play space</h3>
<ol>
  <li value="10"><b>The rock between the two levels</b> is the biggest thing on the screen and today it is a blank brown face. It gets a slanting seam of gold ore and a few old drill holes, drawn on its face.</li>
  <li value="11"><b>Sawn ends.</b> Each stub's beam runs on into the rock. Where it does, its square sawn end shows on the rock's face, right beside the stub. So you can read where the holds are from the row of little squares up each wall, and the stubs plainly belong to the walls.</li>
  <li value="13"><b>The stubs themselves</b> get splintered ends, and the two walls get an empty socket wherever a beam is gone altogether. The three long lunges across the shaft are at exactly those places, so the gaps in the pattern show you where the hard moves are.</li>
</ol>

<h3>Foreground (sparse)</h3>
<ol>
  <li value="12"><b>The shaft's two front posts,</b> thin, each broken in two or three places. They stand in front of the rock at the edges of the shaft, never in front of the open shaft, so they frame the climb and cover nothing you need to see. This is your mine arch: a post behind, a post in front, and you between.</li>
</ol>
<ul>
  <li>A low lip of dark rubble along the very bottom of the frame, below the gallery's floor.</li>
  <li>A few motes of dust drifting close to the camera.</li>
  <li>Nothing else. No slabs, and nothing wider than a post.</li>
</ul>

<h2>How the background explains the play space</h2>
<table>
  <tr><th>What you touch</th><th>What it is, in the scene</th><th>What stands behind it</th></tr>
  <tr><td>The eight stubs</td><td>The stumps of the shaft's cross-beams, snapped by the fall</td><td>The half landing each beam carried, and its sawn end in the rock beside it</td></tr>
  <tr><td>The three long lunges</td><td>Places where a whole beam was torn out</td><td>Two empty sockets, one in each wall, and a ladder that ends in the air</td></tr>
  <tr><td>The slick walls</td><td>Wet rock where the plank lining was stripped off</td><td>The lining still in place on the back wall, to show what is missing here</td></tr>
  <tr><td>The rubble slope and the beam on it</td><td>The roof, on the floor</td><td>More rubble, the crushed bucket and the cable</td></tr>
  <tr><td>The falling rocks</td><td>The roof, still coming</td><td>The chimney above, the scars down the back wall</td></tr>
  <tr><td>The snapped board</td><td>A plank off the lining, lying on the heap</td><td>The gap in the back wall it came from</td></tr>
</table>

<h2>Three rules this design uses</h2>
<p>I'd use these in every diorama. Say if any is wrong.</p>
<ol>
  <li><b>Background wood must not look like wood you can hold.</b> Play-space timber keeps its bright orange. The same timber in the background is pushed well toward the mine's dark grey-blue, with a thinner outline. Notes 4, 18 and 37 were all scenery that read as part of the play.</li>
  <li><b>Nothing in the background hangs as a thin line</b> near where you climb. Cables, ropes and chains lie on the ground, coiled, or are simply not there.</li>
  <li><b>Foreground is posts and lips only,</b> and only over solid rock or below the lowest floor (note 40). A thin post you pass behind at a doorway is the one exception.</li>
</ol>

<h2>Pieces to model, later</h2>
<table>
  <tr><th>Piece</th><th>Size</th><th>How many</th><th>Layer</th><th>New or kit</th></tr>
  <tr><td>Back wall section: planks, a frame, two back posts. Three looks: whole, planks missing, smashed</td><td>3.6 m wide, 1.3 m tall</td><td>12</td><td>Background</td><td>New</td></tr>
  <tr><td>Half landing, left and right</td><td>1.6 m by 1 m</td><td>8</td><td>Background</td><td>New</td></tr>
  <tr><td>Ladder: whole, snapped, hanging by one rail</td><td>0.5 m wide, 1.3 to 2.6 m</td><td>4</td><td>Background</td><td>New</td></tr>
  <tr><td>The chimney's mouth: hanging timbers and torn planks</td><td>3.6 m wide, 2 m tall</td><td>1</td><td>Background</td><td>New (with note 12)</td></tr>
  <tr><td>Hoist wheel on a bent bracket</td><td>1.1 m across</td><td>1</td><td>Background</td><td>Kit wheel, new bracket</td></tr>
  <tr><td>Hand winch</td><td>1.6 m by 1.4 m</td><td>1</td><td>Background</td><td>New</td></tr>
  <tr><td>Big rubble heap with the crushed bucket and cable heap</td><td>5 m by 2.5 m, 3.5 m deep</td><td>1</td><td>Background</td><td>New heap; kit bucket and rope coil</td></tr>
  <tr><td>Boarded-up side tunnel</td><td>1.8 m by 2.9 m</td><td>1</td><td>Background</td><td>New</td></tr>
  <tr><td>Gallery and drift timber frames</td><td>posts 0.35 m, 4 m tall</td><td>5 posts, 2 caps</td><td>Background</td><td>Kit (mine post, mine beam)</td></tr>
  <tr><td>Skull-pug warning sign</td><td>1 m by 2.2 m</td><td>1</td><td>Background</td><td>Kit</td></tr>
  <tr><td>Splintered end for a stub; empty socket for a wall</td><td>0.3 m</td><td>8 ends, 6 sockets</td><td>Play space</td><td>New, small</td></tr>
  <tr><td>Sawn beam end on the rock face; ore seam; drill holes</td><td>0.3 m squares; a 10 m seam</td><td>11 ends, 1 seam</td><td>Play space (drawn on)</td><td>New, flat</td></tr>
  <tr><td>Front post, in broken lengths</td><td>0.3 m wide, 1.4 to 3.6 m</td><td>7 lengths</td><td>Foreground</td><td>Kit (mine post), cut</td></tr>
</table>
<p>Also three small effects, no models: a trickle of dust out of the chimney just before each rock (the warning you can see, to go with the one you hear), a puff where a rock hits the beam, and the drifting motes.</p>

<div class="ask">
  <p><b>Three things for Parker, since this is the test:</b></p>
  <ol>
    <li>Is this the right amount for one place: the paragraph, the two sketches, the three layers, the table of pieces? More, or less?</li>
    <li>Are the three rules right, especially muting the background's wood so it can't be mistaken for a hold?</li>
    <li>The front posts stand over rock at the shaft's edges. Do you want anything in front of the open shaft itself, or is "cover nothing" the rule?</li>
  </ol>
</div>

</main>
</body>
</html>
'''
PAGE = PAGE.replace("__ELEV__", ELEV).replace("__DEPTH__", DEPTH)
io.open(OUT, "w", encoding="utf-8", newline="\n").write(PAGE)
print("wrote", OUT, len(PAGE))
