"""Builds the Peak's design pages: one sheet per biome, one page per area, one per join.

    python docs/peak/playtest/design/build.py          # everything
    python docs/peak/playtest/design/build.py a1 a2    # only these biomes
    python docs/peak/playtest/design/build.py a1 --no-index --png DIR
                                                       # also a PNG of each side sketch into DIR, to look at
    python docs/peak/playtest/design/build.py --look a1 x0 y0 x1 y1 out.png
    python docs/peak/playtest/design/build.py --look a3+a4 x0 y0 x1 y1 out.png   (two biomes at once)
                                                       # the course as it is today in that window, with a grid

DESIGN ONLY. Nothing here changes the game. The pages are for Parker to judge and for
the makers to build from later.

Data lives in docs/peak/playtest/design/data/:
    aN_biome.py   BIOME = {...}     the biome's sheet (written by the Second Director)
    aN_areas.py   AREAS = [...]     one dict per area of that biome
    joins.py      AREAS = [...]     the joins between biomes (each has "biome": "aN")

An AREA dict (all coordinates are the course's own metres, x negative into the mountain):
    "id": "1.10"               "slug": "1_10_el_derrumbe"       "title": "El Derrumbe"
    "kind": "challenge" | "rest" | "join"
    "window": [x0, y0, x1, y1]   what the side sketch shows (keep it under about 30 m wide)
    "screen": [cx, cy]           optional: centre of one screen of the close camera (19.5 x 11 m)
    "cut_y": 66.5                optional: the height the from-above sketch is cut at
    "also": ["a4"]               optional: draw a neighbour biome's course too (a well crossing, a join).
                                 The mountain's shared structure (the well, the east face) is always drawn.
    "climber": [x, y]            optional: a 1.8 m figure standing at that point, for scale
    "place": "..."               the place in one paragraph
    "keep": ["...", ...]         what must not change about the play
    "background": [ITEM, ...]    "play": [ITEM, ...]    "foreground": [ITEM, ...]
    "explains": [["what you touch", "what it is in the scene", "what stands behind it"], ...]
    "pieces": [["piece", "size", "how many", "layer", "kit: name | new"], ...]
    "effects": ["...", ...]      optional: small effects, no models
    "notes": ["...", ...]        optional: tonight's playtest notes folded in
    "ask": ["...", ...]          optional: questions for Parker

An ITEM:
    "name": "The ladder way"     "text": "one or two plain sentences"
    "z": [z_back, z_front]       metres from the play plane; the play space is -1.2 .. 1.2,
                                 background is below -1.2, foreground above 1.2
    "draw": [PRIM, ...]          how it shows on the side sketch
    "tag": [x, y]                optional: where its number sits (default: middle of what it draws)
    "top": True                  optional: force it onto the from-above sketch
    "over": True                 optional (background only): draw it over today's rock, for a hole
                                 or a room cut into rock that is solid in the course today
    "style": "solid"             solid | pale | dark | line | mark | light   (default solid)

A PRIM (a trailing {"style": "..."} overrides the item's style for that one shape):
    ["rect", x0, y0, x1, y1]     ["poly", [[x, y], ...]]     ["line", x0, y0, x1, y1]
    ["circle", x, y, r]          ["ladder", x, y0, y1]       ["text", x, y, "words"]
"""
import importlib.util, io, json, os, re, sys, html

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
COURSE = os.path.join(ROOT, "stages", "peak", "course")
DATA = os.path.join(HERE, "data")
META = json.load(open(os.path.join(COURSE, "_meta.json"), encoding="utf-8"))
BIOMES = ["a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8", "a9", "a10", "a11"]
WARN = []


def esc(t):
    return html.escape(str(t), quote=False)


def load(name):
    p = os.path.join(DATA, name + ".py")
    if not os.path.exists(p):
        return None
    spec = importlib.util.spec_from_file_location("design_" + name, p)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def course(aid):
    return json.load(open(os.path.join(COURSE, aid + ".json"), encoding="utf-8"))


# ------------------------------------------------------------------ the sketches
CSS = r'''
  :root { --bg:#f6f1e7; --card:#fffdf8; --ink:#1f1a17; --soft:#6b625a; --line:#d9cfbf; --red:#c8322b; --gold:#b7791f; --green:#2f7d4f; --blue:#2b6cb0; --quote:#f0e6d2; }
  @media (prefers-color-scheme: dark) { :root { --bg:#171412; --card:#211d1a; --ink:#f1eadf; --soft:#a99f94; --line:#3a332d; --red:#ef6b63; --gold:#e0a84a; --green:#6cc493; --blue:#7fb4ea; --quote:#2b2520; } }
  * { box-sizing: border-box; }
  body { margin:0; background:var(--bg); color:var(--ink); font:16px/1.55 "Segoe UI", system-ui, sans-serif; }
  main { max-width:1000px; margin:0 auto; padding:28px 22px 80px; }
  h1 { font-size:28px; margin:0 0 4px; } h2 { font-size:20px; margin:34px 0 8px; } h3 { font-size:16px; margin:18px 0 4px; }
  p { margin:6px 0; } .sub { color:var(--soft); } a { color:var(--blue); }
  ul, ol { margin:6px 0; padding-left:22px; } li { margin:3px 0; }
  table { border-collapse:collapse; width:100%; background:var(--card); border:1px solid var(--line); margin:8px 0; }
  th, td { text-align:left; padding:7px 10px; border-bottom:1px solid var(--line); vertical-align:top; }
  th { font-size:13px; letter-spacing:.05em; text-transform:uppercase; color:var(--soft); }
  .ask { border-left:4px solid var(--red); padding:8px 12px; margin:12px 0; background:var(--quote); border-radius:0 6px 6px 0; }
  .box { background:var(--card); border:1px solid var(--line); border-radius:10px; padding:12px 18px; margin:12px 0; }
  .tw { overflow-x:auto; } .tw table { min-width:520px; }
  figure { margin:12px 0; } figcaption { color:var(--soft); font-size:14px; margin-top:4px; }
  .sk { width:100%; height:auto; border:1px solid var(--line); border-radius:6px; display:block; background:#17120f; }
  .key { display:flex; flex-wrap:wrap; gap:6px 18px; font-size:14px; margin:6px 0 2px; }
  .key span { display:inline-block; width:14px; height:14px; border-radius:3px; vertical-align:-2px; margin-right:5px; }
  .num { display:inline-block; min-width:22px; height:22px; line-height:22px; text-align:center; border-radius:11px; background:var(--ink); color:var(--bg); font-size:12px; font-weight:700; margin-right:6px; }
  .void { fill:#17120f; }
  .ink { stroke:#0f0b08; stroke-width:1.4; }
  .bg-solid { fill:#4f6076; } .bg-pale { fill:#7f96b3; } .bg-dark { fill:#0b0d10; stroke:#4f6076; stroke-width:1; }
  .bg-line { stroke:#7f96b3; stroke-width:1.8; fill:none; } .bg-mark { stroke:#9fb4ce; stroke-width:1.2; stroke-dasharray:3 5; fill:none; }
  .bg-light { fill:#ffd36a; }
  .fg-solid { fill:#d05cc4; opacity:.85; stroke:#2a0f27; stroke-width:1; } .fg-pale { fill:#e9a6e2; opacity:.7; } .fg-dark { fill:#5c1f56; opacity:.85; }
  .fg-line { stroke:#d05cc4; stroke-width:2; fill:none; } .fg-mark { stroke:#d05cc4; stroke-width:1.2; stroke-dasharray:3 5; fill:none; } .fg-light { fill:#ffd36a; }
  .pl-solid { fill:#ffe08a; opacity:.75; stroke:#7a4b00; stroke-width:1; } .pl-pale { fill:#fff1c4; opacity:.7; stroke:#7a4b00; stroke-width:.8; }
  .pl-dark { fill:#0b0d10; stroke:#ffe08a; stroke-width:1; } .pl-line { stroke:#ffe08a; stroke-width:2; fill:none; }
  .pl-mark { stroke:#ffe08a; stroke-width:1.2; stroke-dasharray:3 5; fill:none; } .pl-light { fill:#ffd36a; }
  .deco { fill:none; stroke:#8a8178; stroke-width:1; stroke-dasharray:2 3; } .decot { fill:#8a8178; font:8px "Segoe UI", sans-serif; }
  .mover { stroke:#5fe0e0; stroke-width:1.6; stroke-dasharray:4 3; } .path { stroke:#5fe0e0; stroke-width:1.2; stroke-dasharray:2 5; fill:none; }
  .rope { stroke:#e8c27a; stroke-width:2.2; fill:none; } .water { fill:#2b6cb0; opacity:.38; } .wind { fill:none; stroke:#cfe6ff; stroke-width:1; stroke-dasharray:1 6; }
  .bounce { stroke:#9be24a; stroke-width:3; } .spawn { stroke:#ff8a70; stroke-width:1.2; stroke-dasharray:2 6; fill:none; }
  .frame { fill:none; stroke:#ffffff; stroke-width:1.2; stroke-dasharray:7 6; opacity:.55; }
  .lbl { fill:#f1eadf; font:12px "Segoe UI", sans-serif; opacity:.9; } .lbl2 { fill:#f1eadf; font:11px "Segoe UI", sans-serif; opacity:.85; }
  .tag circle { fill:#fffdf8; stroke:#1a1310; stroke-width:1.5; } .tag text { fill:#1a1310; font:bold 11px "Segoe UI", sans-serif; text-anchor:middle; }
  .man circle, .man line { stroke:#ffffff; stroke-width:2; fill:none; stroke-linecap:round; }
  .band_fg { fill:#d05cc41c; } .band_play { fill:#e39a3c1c; } .band_bg { fill:#6f86a326; } .band_far { fill:#0b0d10; }
'''

LAYERCLS = {"background": "bg", "play": "pl", "foreground": "fg"}
FALLBACK = {"wood": "#e39a3c", "wood2": "#c98a35", "rock": "#b98f5e", "rock2": "#a37747", "slick": "#3a2616", "iron": "#b5532a",
            "stone": "#c8b79a", "brick": "#b8674a", "bone": "#e9e2ce", "gold": "#e8b33a", "crystal": "#ede3ff", "gill": "#f0e3c2",
            "accent": "#e0b040", "root": "#a9825a", "snow": "#f4f7fa", "ice": "#9fddf2", "hot": "#f0541e", "weak": "#a99c86"}


def kind_fill(pal, kind):
    k = META["kinds"].get(kind, {})
    if not k.get("grip", True):
        return pal.get("slick", FALLBACK["slick"])
    tone = str(k.get("tone", kind))
    if kind in ("wood", "plank"):
        return FALLBACK["wood"]
    return pal.get(tone, FALLBACK.get(tone, "#b98f5e"))


class Sketch:
    def __init__(self, win, maxw=760.0):
        self.x0, self.y0, self.x1, self.y1 = [float(v) for v in win]
        self.s = min(30.0, maxw / max(1.0, self.x1 - self.x0))
        self.w, self.h = (self.x1 - self.x0) * self.s, (self.y1 - self.y0) * self.s
        self.out = ['<rect x="0" y="0" width="%.1f" height="%.1f" class="void"/>' % (self.w, self.h)]
        self.ops = []

    def X(self, x): return round((x - self.x0) * self.s, 1)
    def Y(self, y): return round((self.y1 - y) * self.s, 1)

    def hits(self, xs, ys):
        return max(xs) > self.x0 and min(xs) < self.x1 and max(ys) > self.y0 and min(ys) < self.y1

    def poly(self, pts, cls="", style=""):
        self.ops.append(("poly", [(self.X(x), self.Y(y)) for x, y in pts], cls, style))
        self.out.append('<polygon points="%s" class="%s" style="%s"/>' % (" ".join("%s,%s" % (self.X(x), self.Y(y)) for x, y in pts), cls, style))

    def line(self, x0, y0, x1, y1, cls="", style=""):
        self.ops.append(("line", [(self.X(x0), self.Y(y0)), (self.X(x1), self.Y(y1))], cls, style))
        self.out.append('<line x1="%s" y1="%s" x2="%s" y2="%s" class="%s" style="%s"/>' % (self.X(x0), self.Y(y0), self.X(x1), self.Y(y1), cls, style))

    def circle(self, x, y, r, cls="", style=""):
        self.ops.append(("circle", [(self.X(x), self.Y(y))], cls, style, max(1.5, r * self.s)))
        self.out.append('<circle cx="%s" cy="%s" r="%.1f" class="%s" style="%s"/>' % (self.X(x), self.Y(y), max(1.5, r * self.s), cls, style))

    def text(self, x, y, t, cls="lbl2", anchor="start"):
        self.ops.append(("text", [(self.X(x), self.Y(y))], cls, str(t)))
        self.out.append('<text x="%s" y="%s" class="%s" text-anchor="%s">%s</text>' % (self.X(x), self.Y(y), cls, anchor, esc(t)))

    def tag(self, n, x, y):
        self.ops.append(("tag", [(self.X(x), self.Y(y))], "", str(n)))
        self.out.append('<g class="tag"><circle cx="%s" cy="%s" r="9"/><text x="%s" y="%s">%s</text></g>' % (self.X(x), self.Y(y), self.X(x), self.Y(y) + 4, n))

    def man(self, x, y):
        k = self.s / 24.0
        self.ops.append(("man", [(self.X(x), self.Y(y))], "", ""))
        self.out.append('<g class="man" transform="translate(%s,%s) scale(%.2f)"><circle cx="0" cy="-39" r="5"/><line x1="0" y1="-34" x2="0" y2="-14"/><line x1="0" y1="-14" x2="-5" y2="0"/><line x1="0" y1="-14" x2="5" y2="0"/><line x1="0" y1="-29" x2="-9" y2="-36"/><line x1="0" y1="-29" x2="8" y2="-22"/></g>' % (self.X(x), self.Y(y), k))

    def svg(self, label):
        return '<svg viewBox="0 0 %.1f %.1f" class="sk" role="img" aria-label="%s">%s</svg>' % (self.w, self.h, esc(label), "".join(self.out))


def prim_bbox(prims):
    xs, ys = [], []
    for p in prims:
        t = p[0]
        if t == "rect":
            xs += [p[1], p[3]]; ys += [p[2], p[4]]
        elif t == "poly":
            xs += [q[0] for q in p[1]]; ys += [q[1] for q in p[1]]
        elif t == "line":
            xs += [p[1], p[3]]; ys += [p[2], p[4]]
        elif t == "circle":
            xs += [p[1] - p[3], p[1] + p[3]]; ys += [p[2] - p[3], p[2] + p[3]]
        elif t == "ladder":
            xs += [p[1] - 0.25, p[1] + 0.25]; ys += [p[2], p[3]]
        elif t == "text":
            xs += [p[1]]; ys += [p[2]]
    return (min(xs), min(ys), max(xs), max(ys)) if xs else None


def draw_item(sk, layer, item):
    base = LAYERCLS[layer]
    for p in item.get("draw", []):
        st = item.get("style", "solid")
        if isinstance(p[-1], dict):
            st = p[-1].get("style", st)
            p = p[:-1]
        t = p[0]
        cls = "%s-%s" % (base, st)
        if t == "rect":
            x0, y0, x1, y1 = min(p[1], p[3]), min(p[2], p[4]), max(p[1], p[3]), max(p[2], p[4])
            if st in ("line", "mark"):
                sk.poly([(x0, y0), (x1, y0), (x1, y1), (x0, y1)], cls)
            else:
                sk.poly([(x0, y0), (x1, y0), (x1, y1), (x0, y1)], cls)
        elif t == "poly":
            sk.poly(p[1], cls)
        elif t == "line":
            sk.line(p[1], p[2], p[3], p[4], "%s-%s" % (base, "mark" if st == "mark" else "line"))
        elif t == "circle":
            sk.circle(p[1], p[2], p[3], cls)
        elif t == "ladder":
            x, y0, y1 = p[1], min(p[2], p[3]), max(p[2], p[3])
            lc = "%s-line" % base
            sk.line(x - 0.22, y0, x - 0.22, y1, lc); sk.line(x + 0.22, y0, x + 0.22, y1, lc)
            y = y0 + 0.3
            while y < y1 - 0.05:
                sk.line(x - 0.22, y, x + 0.22, y, lc)
                y += 0.32
        elif t == "text":
            sk.text(p[1], p[2], p[3])


def draw_course(sk, c, pal):
    """The play space as the course file has it today."""
    for z in c.get("zones", []):
        if z.get("type") == "water":
            r = z["rect"]
            if sk.hits([r[0], r[2]], [r[1], r[3]]):
                sk.poly([(r[0], r[1]), (r[2], r[1]), (r[2], z.get("surface", r[3])), (r[0], z.get("surface", r[3]))], "water")
    for s in c.get("solids", []):
        pts = s["pts"]
        if not sk.hits([q[0] for q in pts], [q[1] for q in pts]):
            continue
        hold = s.get("hold", META["kinds"].get(s["kind"], {}).get("hold"))
        extra = ""
        if isinstance(hold, dict):
            extra = {"crumble": "stroke:#ffffff;stroke-dasharray:3 2;", "wet": "stroke:#7fd0ff;", "timed": "stroke:#ff5a3c;stroke-width:2;"}.get(hold.get("type"), "")
        sk.poly(pts, "ink", "fill:%s;%s" % (kind_fill(pal, s["kind"]), extra))
    for b in c.get("bodies", []):
        ax, ay = b["at"]
        for sh in b.get("shapes", []):
            pts = [(ax + q[0], ay + q[1]) for q in sh["pts"]]
            if sk.hits([q[0] for q in pts], [q[1] for q in pts]):
                sk.poly(pts, "mover", "fill:%s" % kind_fill(pal, sh["kind"]))
    for m in c.get("movers", []):
        ax, ay = m["at"]
        mo = m.get("motion", {})
        for sh in m.get("shapes", []):
            pts = [(ax + q[0], ay + q[1]) for q in sh["pts"]]
            if sk.hits([q[0] for q in pts], [q[1] for q in pts]):
                sk.poly(pts, "mover", "fill:%s" % kind_fill(pal, sh["kind"]))
        if mo.get("type") == "path" and len(mo.get("pts", [])) > 1:
            pp = mo["pts"]
            for i in range(len(pp) - 1):
                if sk.hits([pp[i][0], pp[i + 1][0]], [pp[i][1], pp[i + 1][1]]):
                    sk.line(pp[i][0], pp[i][1], pp[i + 1][0], pp[i + 1][1], "path")
        elif mo.get("type") in ("cycle", "sink", "crank") and "to" in mo:
            if sk.hits([ax, ax + mo["to"][0]], [ay, ay + mo["to"][1]]):
                sk.line(ax, ay, ax + mo["to"][0], ay + mo["to"][1], "path")
    for r in c.get("ropes", []):
        ax, ay = r["at"]
        bx, by = r.get("to", [ax, ay - r["len"]])
        if sk.hits([ax, bx], [ay, by]):
            sk.line(ax, ay, bx, by, "rope")
    for z in c.get("zones", []):
        t = z.get("type")
        if t == "wind":
            r = z["rect"]
            if sk.hits([r[0], r[2]], [r[1], r[3]]):
                sk.poly([(r[0], r[1]), (r[2], r[1]), (r[2], r[3]), (r[0], r[3])], "wind")
        elif t == "bounce":
            if sk.hits([z["a"][0], z["b"][0]], [z["a"][1], z["b"][1]]):
                sk.line(z["a"][0], z["a"][1], z["b"][0], z["b"][1], "bounce")
        elif t == "geyser":
            x, y = z["at"]
            if sk.hits([x - z["w"], x + z["w"]], [y, y + z["height"]]):
                sk.poly([(x - z["w"] / 2, y), (x + z["w"] / 2, y), (x + z["w"] / 2, y + z["height"]), (x - z["w"] / 2, y + z["height"])], "wind")
        elif t == "puff":
            x, y = z["at"]
            if sk.hits([x - 1, x + 1], [y - 1, y + 1]):
                sk.circle(x, y, z.get("r", 0.6), "", "fill:#f5f2d0;stroke:#0f0b08")
    for sp in c.get("spawners", []):
        x, y = sp["at"]
        if sk.hits([x - 1, x + 1], [y - 12, y]):
            sk.line(x, y, x, y - 12, "spawn")
    for st in c.get("statues", []):
        x, y = st["at"]
        if sk.hits([x - 1, x + 1], [y - 1, y + 1]):
            sk.man(x, y - 0.85)
    for d in c.get("decos", []):
        x, y = d["at"][0], d["at"][1]
        w, h = (d.get("size") or [0.6, 0.6, 0.3])[:2]
        k = float(d.get("scale", 1.0))
        if sk.hits([x - w / 2, x + w / 2], [y, y + h]) and max(w, h) * k < 20:
            sk.poly([(x - w * k / 2, y), (x + w * k / 2, y), (x + w * k / 2, y + h * k), (x - w * k / 2, y + h * k)], "deco")
            sk.text(x - w * k / 2, y + h * k + 0.12, d["model"], "decot")


def draw_all(sk, a, c, pal):
    """Today's course in the window: the mountain's shared structure, any neighbour asked for, then the biome itself."""
    draw_course(sk, course("st"), pal)
    for other in a.get("also", []):
        oc = course(other)
        draw_course(sk, oc, META["palettes"].get(oc.get("palette", ""), pal))
    draw_course(sk, c, pal)


def side_sketch(a, c, pal, numbered):
    sk = Sketch(a["window"])
    for n, layer, item in numbered:
        if layer == "background" and not item.get("over"):
            draw_item(sk, layer, item)
    draw_all(sk, a, c, pal)
    for n, layer, item in numbered:
        if layer == "background" and item.get("over"):
            draw_item(sk, layer, item)
    for n, layer, item in numbered:
        if layer == "play":
            draw_item(sk, layer, item)
    for n, layer, item in numbered:
        if layer == "foreground":
            draw_item(sk, layer, item)
    if a.get("screen"):
        cx, cy = a["screen"]
        sk.out.append('<rect x="%s" y="%s" width="%.1f" height="%.1f" class="frame"/>' % (sk.X(cx - 9.75), sk.Y(cy + 5.5), 19.5 * sk.s, 11.0 * sk.s))
        sk.ops.append(("poly", [(sk.X(cx - 9.75), sk.Y(cy + 5.5)), (sk.X(cx + 9.75), sk.Y(cy + 5.5)), (sk.X(cx + 9.75), sk.Y(cy - 5.5)), (sk.X(cx - 9.75), sk.Y(cy - 5.5))], "frame", ""))
    if a.get("climber"):
        sk.man(a["climber"][0], a["climber"][1])
    for n, layer, item in numbered:
        bb = prim_bbox(item.get("draw", []))
        if item.get("tag"):
            sk.tag(n, item["tag"][0], item["tag"][1])
        elif bb:
            sk.tag(n, (bb[0] + bb[2]) / 2, (bb[1] + bb[3]) / 2)
    if PNG_DIR:
        render_png(sk, os.path.join(PNG_DIR, a["slug"] + ".png"))
    return sk.svg("Side view of %s, to scale" % a["title"])


def top_sketch(a, c, pal, numbered):
    """From above: how far back each thing sits. x across, the camera at the bottom."""
    x0, _, x1, _ = a["window"]
    cut = a.get("cut_y")
    zf, zb = 3.2, -8.0
    s = min(30.0, 760.0 / max(1.0, x1 - x0))
    w, h = (x1 - x0) * s, (zf - zb) * s
    X = lambda x: round((x - x0) * s, 1)
    Z = lambda z: round((z - zb) * s, 1)      # far back at the top, the camera at the bottom
    o = ['<rect x="0" y="0" width="%.1f" height="%.1f" class="void"/>' % (w, h)]

    def band(z0, z1, cls):
        o.append('<rect x="0" y="%s" width="%.1f" height="%.1f" class="%s"/>' % (Z(z0), w, (z1 - z0) * s, cls))
    band(1.2, zf, "band_fg"); band(-1.2, 1.2, "band_play"); band(-3.0, -1.2, "band_bg"); band(zb, -3.0, "band_far")
    if cut is not None:
        sols = list(course("st").get("solids", [])) + list(c.get("solids", []))
        for other in a.get("also", []):
            sols += course(other).get("solids", [])
        for sol in sols:
            pts = sol["pts"]
            xs, ys = [q[0] for q in pts], [q[1] for q in pts]
            if min(ys) <= cut <= max(ys) and max(xs) > x0 and min(xs) < x1:
                o.append('<rect x="%s" y="%s" width="%.1f" height="%.1f" class="ink" style="fill:%s"/>' % (X(max(min(xs), x0)), Z(-1.2), (min(max(xs), x1) - max(min(xs), x0)) * s, 2.4 * s, kind_fill(pal, sol["kind"])))
    for n, layer, item in numbered:
        bb = prim_bbox(item.get("draw", []))
        zz = item.get("z")
        if not bb or not zz:
            continue
        if cut is not None and not item.get("top") and not (bb[1] - 0.6 <= cut <= bb[3] + 0.6):
            continue
        za, zc = max(zb, min(zz)), min(zf, max(zz))
        if zc - za < 0.12:
            zc = za + 0.12
        xa, xb = max(x0, bb[0]), min(x1, bb[2])
        if xb - xa < 0.15:
            xb = xa + 0.15
        st = item.get("style", "solid")
        cls = "%s-%s" % (LAYERCLS[layer], st if st in ("solid", "pale", "dark", "light") else "solid")
        o.append('<rect x="%s" y="%s" width="%.1f" height="%.1f" class="%s"/>' % (X(xa), Z(za), (xb - xa) * s, (zc - za) * s, cls))
        o.append('<g class="tag"><circle cx="%s" cy="%s" r="8"/><text x="%s" y="%s">%s</text></g>' % (X((xa + xb) / 2), Z((za + zc) / 2), X((xa + xb) / 2), Z((za + zc) / 2) + 4, n))
    for z, t in ((2.2, "FOREGROUND"), (0.0, "PLAY SPACE (1.2 m either side of you)"), (-2.1, "BACKGROUND, near"), (-5.5, "BACKGROUND, far")):
        o.append('<text x="6" y="%s" class="lbl2">%s</text>' % (Z(z) + 4, t))
    o.append('<text x="%.1f" y="%.1f" class="lbl2" text-anchor="end">the camera is at the bottom, looking up the page</text>' % (w - 6, h - 6))
    return '<svg viewBox="0 0 %.1f %.1f" class="sk" role="img" aria-label="%s from above">%s</svg>' % (w, h, esc(a["title"]), "".join(o))


# ------------------------------------------------------------------ PNG, for checking only
PNG_DIR = None
PNGCOL = {  # class: (fill, outline, width)
    "ink": (None, "#0f0b08", 2), "deco": (None, "#8a8178", 1), "mover": (None, "#5fe0e0", 2), "path": (None, "#5fe0e0", 1),
    "rope": (None, "#e8c27a", 3), "water": ("#2b6cb060", None, 0), "wind": (None, "#cfe6ff", 1), "bounce": (None, "#9be24a", 4),
    "spawn": (None, "#ff8a70", 1), "frame": (None, "#ffffff", 1), "grid": (None, "#3a332d", 1), "grid5": (None, "#6b625a", 1),
    "bg-solid": ("#4f6076", None, 0), "bg-pale": ("#7f96b3", None, 0), "bg-dark": ("#0b0d10", "#4f6076", 1), "bg-line": (None, "#7f96b3", 2),
    "bg-mark": (None, "#9fb4ce", 1), "bg-light": ("#ffd36a", None, 0),
    "fg-solid": ("#d05cc4d8", "#2a0f27", 1), "fg-pale": ("#e9a6e2b0", None, 0), "fg-dark": ("#5c1f56d8", None, 0), "fg-line": (None, "#d05cc4", 2),
    "fg-mark": (None, "#d05cc4", 1), "fg-light": ("#ffd36a", None, 0),
    "pl-solid": ("#ffe08ac0", "#7a4b00", 1), "pl-pale": ("#fff1c4b0", "#7a4b00", 1), "pl-dark": ("#0b0d10", "#ffe08a", 1), "pl-line": (None, "#ffe08a", 2),
    "pl-mark": (None, "#ffe08a", 1), "pl-light": ("#ffd36a", None, 0),
}


def render_png(sk, path, k=2.0):
    """A plain picture of a sketch, so whoever wrote the data can look at what it drew."""
    from PIL import Image, ImageDraw
    img = Image.new("RGB", (int(sk.w * k) + 1, int(sk.h * k) + 1), "#17120f")
    d = ImageDraw.Draw(img, "RGBA")
    P = lambda pts: [(x * k, y * k) for x, y in pts]
    for op in sk.ops:
        t, pts, cls, style = op[0], P(op[1]), op[2], op[3]
        fill, line, w = PNGCOL.get(cls, (None, None, 0))
        if t in ("poly", "circle", "line"):
            for bit in style.split(";"):
                if bit.startswith("fill:"):
                    fill = bit[5:]
                elif bit.startswith("stroke:"):
                    line, w = bit[7:], max(w, 2)
        if t == "poly":
            if len(pts) >= 3:
                d.polygon(pts, fill=fill, outline=line)
        elif t == "line":
            d.line(pts, fill=line or "#ffffff", width=max(1, w))
        elif t == "circle":
            r = op[4] * k
            x, y = pts[0]
            d.ellipse([x - r, y - r, x + r, y + r], fill=fill, outline=line or ("#0f0b08" if fill else "#ffffff"))
        elif t == "text":
            d.text(pts[0], style, fill="#b9b0a4" if cls == "decot" else "#f1eadf")
        elif t == "tag":
            x, y = pts[0]
            d.ellipse([x - 13, y - 13, x + 13, y + 13], fill="#fffdf8", outline="#1a1310")
            d.text((x - 3 * len(style), y - 6), style, fill="#1a1310")
        elif t == "man":
            x, y = pts[0]
            h = 1.8 * sk.s * k
            d.line([(x, y), (x, y - h * 0.8)], fill="#ffffff", width=3)
            d.ellipse([x - h * 0.1, y - h, x + h * 0.1, y - h * 0.8], outline="#ffffff", width=3)
    img.save(path)


def look(aid, win, path):
    """python build.py --look a1 x0 y0 x1 y1 out.png : the course as it is today in that window, with a metre grid."""
    import math
    ids = aid.split("+")
    c = course(ids[0])
    pal = META["palettes"].get(c.get("palette", ""), {})
    sk = Sketch(win, maxw=1100.0)
    draw_all(sk, {"also": ids[1:]}, c, pal)
    x = math.ceil(sk.x0)
    while x < sk.x1:
        sk.line(x, sk.y0, x, sk.y1, "grid5" if x % 5 == 0 else "grid")
        if x % 5 == 0:
            sk.text(x + 0.1, sk.y1 - 0.5, "x %d" % x)
        x += 1
    y = math.ceil(sk.y0)
    while y < sk.y1:
        sk.line(sk.x0, y, sk.x1, y, "grid5" if y % 5 == 0 else "grid")
        if y % 5 == 0:
            sk.text(sk.x0 + 0.1, y + 0.1, "y %d" % y)
        y += 1
    for ch in c.get("challenges", []):
        ax, ay = ch["anchor"]
        if sk.hits([ax - 0.1, ax + 0.1], [ay - 0.1, ay + 0.1]):
            sk.man(ax, ay)
            sk.text(ax + 0.3, ay + 2.0, "%s %s" % (ch["id"], ch["name"]))
    render_png(sk, path, k=1.6)
    print("wrote", path, "(grid lines every 1 m, brighter every 5 m)")


RULES = [
    "What you can hold is dry, pale and matte. What you can't is dark, glossy and wet. This is the mountain's first law and no design breaks it.",
    "Where a thing stands tells you more than its colour (Parker, 11-13). If it is in the play space you can generally hold it. Scenery stays out of the play space, behind or in front, and is greyer, darker and cooler than the things you climb.",
    "Everything you touch is the near end of something real that carries on behind it, like a ladder and its rungs.",
    "Nothing thin hangs in the background near the climb: it reads as a rope (notes 4 and 18). A hanging thing is a real rope, or thick, or far back.",
    "The foreground is sparse: thin posts and low lips, in front of solid rock or below the lowest floor, never over the open space you climb through (note 40).",
    "Every moving thing shows its machine: what drives it stands in the background (notes 19, 36, 57).",
    "Every danger shows where it comes from and warns before it acts (notes 12, 21, 23, 56).",
    "Every breakable thing wears the game's one breakable look: cracked already, with a corner gone (notes 16, 24, 31, 53, 64).",
    "The painted back wall never stops inside the frame, so there are no black holes (note 51). The insides of small pits can't be held (note 52).",
    "One frog is hidden in every biome (note 60), in a little room you can walk into. A room you can enter is cut away at the front: floor, back wall and roof, no front wall.",    "Far backgrounds are flat facade pieces (Parker, 11-13): one cut-out card standing well back, painted in a few broad rows that haze toward the horizon, with a few bold silhouettes cut into its ridge. Never modelled terrain, and never an empty plane running to a ruled horizon. The station's dry hills are the worked example.",
    "Open ground is designed, never one flat colour (Parker, 11-13): one painted slab with no height that runs off every edge of the screen, laid out as a real place in bands from the camera back (tufts and stones, a worn road with ruts, a trodden yard, paving where people built, patched open country, paler far bands), with real plants and rocks standing on its darker patches. No more than about 4 m of one flat colour on screen. The station's ground is the worked example.",
    "Walls and rock are painted, not built of blocks (Parker, 11-13: \"I like the painted look\"). A wall, a cliff or any mass you climb is a few big planes with a designed, uneven outline. Its layers and courses are flat painted colour on those planes, as long wavy lines and bands, with no ink inside a face and nothing that tapers to a point (no streaks or wedges: \"it does not need these random triangles ... just the painted lines look lovely\"). Only a few big breaks are real shape: an overhang, a deep recess, a ledge, a leaning slab. No repeated square panel, no long ruled edge. The holds and the tops you stand on stay exactly where the course has them. The mass's own body carries on behind it, duller, as one big form. Worked example: the split tower top of the wind cliffs (design/walls_example_before.jpg and walls_example_after.png).",
]

# ------------------------------------------------------------------ pages
def page(title, body):
    body = body.replace("<table>", '<div class="tw"><table>').replace("</table>", "</table></div>")
    return ('<!DOCTYPE html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n<meta name="viewport" content="width=device-width, initial-scale=1">\n'
            '<title>%s</title>\n<style>%s</style>\n</head>\n<body>\n<main>\n%s\n</main>\n</body>\n</html>\n' % (esc(title), CSS, body))


KEY = ('<div class="key"><div><span style="background:#4f6076"></span>Background (proposed)</div>'
       '<div><span style="background:#ffe08a"></span>Added to the play space (proposed, drawn on)</div>'
       '<div><span style="background:#d05cc4"></span>Foreground (proposed)</div>'
       '<div><span style="background:#e39a3c"></span>Play space as it is today, in its own colours</div>'
       '<div><span style="border:1px dashed #8a8178"></span>Scenery that is there today</div>'
       '<div><span style="border:2px dashed #5fe0e0"></span>Moves</div></div>')


def layer_list(numbered, layer):
    rows = [(n, it) for n, l, it in numbered if l == layer]
    if not rows:
        return "<p class=\"sub\">Nothing.</p>"
    out = ["<ul style=\"list-style:none;padding-left:0\">"]
    for n, it in rows:
        z = it.get("z")
        where = ""
        if z:
            lo, hi = min(z), max(z)
            if hi <= -1.2:
                where = " <span class=\"sub\">(%.1f to %.1f m behind you)</span>" % (-hi, -lo)
            elif lo >= 1.2:
                where = " <span class=\"sub\">(%.1f to %.1f m in front)</span>" % (lo, hi)
        out.append('<li><span class="num">%d</span><b>%s.</b> %s%s</li>' % (n, esc(it["name"]).rstrip("."), esc(it.get("text", "")), where))
    out.append("</ul>")
    return "".join(out)


def area_page(a, biome_id, biome, c, pal):
    numbered, n = [], 0
    for layer in ("background", "play", "foreground"):
        for it in a.get(layer, []):
            n += 1
            numbered.append((n, layer, it))
            z = it.get("z")
            if z:
                lo, hi = min(z), max(z)
                if layer == "background" and hi > -1.2 + 1e-6:
                    WARN.append("%s: background item '%s' comes nearer than 1.2 m behind (z %s)" % (a["id"], it["name"], z))
                if layer == "foreground" and lo < 1.2 - 1e-6:
                    WARN.append("%s: foreground item '%s' sits inside the play space (z %s)" % (a["id"], it["name"], z))
            else:
                WARN.append("%s: item '%s' has no z" % (a["id"], it["name"]))
            bb = prim_bbox(it.get("draw", []))
            if bb:
                w = a["window"]
                if bb[2] < w[0] or bb[0] > w[2] or bb[3] < w[1] or bb[1] > w[3]:
                    WARN.append("%s: item '%s' is drawn outside the window" % (a["id"], it["name"]))
            else:
                WARN.append("%s: item '%s' draws nothing" % (a["id"], it["name"]))
    b = []
    b.append('<p class="sub"><a href="index.html">%s</a> &middot; <a href="../../PLAYTEST_NOTES.html#design">Area and background design</a></p>' % esc(biome.get("name", biome_id)))
    kind = {"challenge": "Challenge", "rest": "Rest", "join": "Join"}.get(a.get("kind", "challenge"), "Area")
    b.append("<h1>%s %s: %s</h1>" % (kind, esc(a["id"]), esc(a["title"])))
    b.append('<p class="sub">Design only. Nothing here is built, and nothing is modelled until the whole mountain has been playtested.</p>')
    b.append("<h2>The place, in one paragraph</h2><p>%s</p>" % esc(a.get("place", "")))
    if a.get("keep"):
        b.append("<h2>What must not change</h2><ul>%s</ul>" % "".join("<li>%s</li>" % esc(k) for k in a["keep"]))
    b.append("<h2>The sketches</h2><p>Both are to scale and drawn from the course file's own numbers. The numbers match the lists below.</p>" + KEY)
    b.append("<figure>%s<figcaption>From the side, as the camera sees it.%s</figcaption></figure>" % (side_sketch(a, c, pal, numbered), " The dashed box is one screen with the close camera." if a.get("screen") else ""))
    b.append("<figure>%s<figcaption>From above%s: how far back each thing sits.</figcaption></figure>" % (top_sketch(a, c, pal, numbered), (", cut at %.1f m up" % a["cut_y"]) if a.get("cut_y") is not None else ""))
    b.append("<h2>The three layers</h2><h3>Background</h3>%s<h3>Play space</h3>%s<h3>Foreground (sparse)</h3>%s" % (layer_list(numbered, "background"), layer_list(numbered, "play"), layer_list(numbered, "foreground")))
    if a.get("explains"):
        b.append("<h2>How the background explains the play space</h2><table><tr><th>What you touch</th><th>What it is, in the scene</th><th>What stands behind it</th></tr>%s</table>" %
                 "".join("<tr>%s</tr>" % "".join("<td>%s</td>" % esc(x) for x in row) for row in a["explains"]))
    if a.get("pieces"):
        b.append("<h2>Pieces</h2><table><tr><th>Piece</th><th>Size</th><th>How many</th><th>Layer</th><th>From the biome's kit, or new</th></tr>%s</table>" %
                 "".join("<tr>%s</tr>" % "".join("<td>%s</td>" % esc(x) for x in row) for row in a["pieces"]))
    if a.get("effects"):
        b.append("<h3>Small effects, no models</h3><ul>%s</ul>" % "".join("<li>%s</li>" % esc(x) for x in a["effects"]))
    if a.get("notes"):
        b.append("<h2>Tonight's notes folded in</h2><ul>%s</ul>" % "".join("<li>%s</li>" % esc(x) for x in a["notes"]))
    if a.get("ask"):
        b.append('<div class="ask"><p><b>For Parker:</b></p><ul>%s</ul></div>' % "".join("<li>%s</li>" % esc(x) for x in a["ask"]))
    return page("%s %s: %s" % (kind, a["id"], a["title"]), "\n".join(b))


def table(head, rows):
    return "<table><tr>%s</tr>%s</table>" % ("".join("<th>%s</th>" % esc(h) for h in head), "".join("<tr>%s</tr>" % "".join("<td>%s</td>" % esc(x) for x in r) for r in rows))


def biome_page(bid, B, areas):
    b = ['<p class="sub"><a href="../../PLAYTEST_NOTES.html#design">Area and background design</a></p>']
    b.append("<h1>Biome %s: %s</h1>" % (bid[1:], esc(B["name"])))
    b.append('<p class="sub">%s</p>' % esc(B.get("line", "")))
    b.append('<p class="sub">Design only. This sheet comes first: every area in the biome is drawn from it.</p>')
    for head, key in (("What this place is", "story"), ("How it is built", "built"), ("Colour and light", "light")):
        v = B.get(key)
        if not v:
            continue
        b.append("<h2>%s</h2>" % head)
        b.append("".join("<p>%s</p>" % esc(p) for p in v) if isinstance(v, list) and key == "story" else ("<ul>%s</ul>" % "".join("<li>%s</li>" % esc(p) for p in v) if isinstance(v, list) else "<p>%s</p>" % esc(v)))
    if B.get("looks"):
        b.append("<h2>How it tells you what a thing is</h2>" + table(["What it is", "How it looks here"], B["looks"]))
    if B.get("layers"):
        b.append("<h2>The three layers in this biome</h2>" + table(["Layer", "What goes in it here"], B["layers"]))
    if B.get("kit"):
        b.append("<h2>The shared kit</h2><p>Every area in the biome is built from these, and reuses them. An area adds a piece of its own only when it truly needs one.</p>" +
                 table(["Piece", "Size", "Used for", "Layer", "In the kit today, or new"], B["kit"]))
    if B.get("arrive") or B.get("leave"):
        b.append("<h2>How you come in, and how you leave</h2>")
        if B.get("arrive"):
            b.append("<p><b>Coming in:</b> %s</p>" % esc(B["arrive"]))
        if B.get("leave"):
            b.append("<p><b>Leaving:</b> %s</p>" % esc(B["leave"]))
    if B.get("motifs"):
        b.append("<h2>Running through it</h2><ul>%s</ul>" % "".join("<li>%s</li>" % esc(m) for m in B["motifs"]))
    if B.get("notes"):
        b.append("<h2>Tonight's notes that change this biome</h2><ul>%s</ul>" % "".join("<li>%s</li>" % esc(m) for m in B["notes"]))
    if areas:
        rows = "".join('<tr><td>%s</td><td><a href="%s.html">%s</a></td><td>%s</td></tr>' % (esc(a["id"]), a["slug"], esc(a["title"]), {"challenge": "Challenge", "rest": "Rest", "join": "Join"}.get(a.get("kind", "challenge"), "")) for a in areas)
        b.append("<h2>Its areas</h2><table><tr><th>Id</th><th>Area</th><th>Kind</th></tr>%s</table>" % rows)
    else:
        b.append('<h2>Its areas</h2><p class="sub">Not designed yet.</p>')
    if B.get("ask"):
        b.append('<div class="ask"><p><b>For Parker:</b></p><ul>%s</ul></div>' % "".join("<li>%s</li>" % esc(x) for x in B["ask"]))
    b.append('<h2>Rules that hold on the whole mountain</h2><ol>%s</ol>' % "".join("<li>%s</li>" % esc(r) for r in RULES))
    return page("Biome %s: %s" % (bid[1:], B["name"]), "\n".join(b))


def main():
    global PNG_DIR
    argv = sys.argv[1:]
    if argv and argv[0] == "--look":
        return look(argv[1], [float(v) for v in argv[2:6]], argv[6])
    if "--png" in argv:
        PNG_DIR = argv[argv.index("--png") + 1]
        os.makedirs(PNG_DIR, exist_ok=True)
    no_index = "--no-index" in argv
    want = [a for a in argv if a in BIOMES] or BIOMES
    joins = load("joins")
    summary = []
    for bid in BIOMES:
        bm = load(bid + "_biome")
        if bm is None:
            continue
        try:
            am = load(bid + "_areas")
        except Exception as e:      # a file somebody is still writing
            print("SKIPPED %s_areas.py: %s" % (bid, e))
            am = None
        areas = list(getattr(am, "AREAS", [])) if am else []
        if am and getattr(am, "KIT_MORE", None):
            bm.BIOME["kit"] = list(bm.BIOME.get("kit", [])) + [list(r) for r in am.KIT_MORE]
        if joins:
            areas += [j for j in joins.AREAS if j.get("biome") == bid]
        summary.append((bid, bm.BIOME, areas))
        if bid not in want:
            continue
        out = os.path.join(HERE, bid)
        os.makedirs(out, exist_ok=True)
        c = course(bid)
        pal = META["palettes"].get(c.get("palette", ""), {})
        io.open(os.path.join(out, "index.html"), "w", encoding="utf-8", newline="\n").write(biome_page(bid, bm.BIOME, areas))
        for a in areas:
            cc = course(a["course"]) if a.get("course") else c
            io.open(os.path.join(out, a["slug"] + ".html"), "w", encoding="utf-8", newline="\n").write(area_page(a, bid, bm.BIOME, cc, pal))
        print("%s: sheet + %d areas" % (bid, len(areas)))
    # the index inside the playtest page
    notes = os.path.join(HERE, "..", "PLAYTEST_NOTES.html")
    s = io.open(notes, encoding="utf-8").read()
    a, z = "<!--DESIGN-INDEX-START-->", "<!--DESIGN-INDEX-END-->"
    if a in s and z in s and not no_index:
        rows = ""
        for bid, B, ar in summary:
            links = " &middot; ".join('<a href="design/%s/%s.html">%s %s</a>' % (bid, x["slug"], esc(x["id"]), esc(x["title"])) for x in ar)
            rows += '<tr><td>%s</td><td><a href="design/%s/index.html"><b>%s</b></a><br><span class="sub">the biome\'s sheet</span></td><td>%s</td></tr>' % (bid[1:], bid, esc(B["name"]), links or "none yet")
        tbl = "<table><tr><th>Biome</th><th>Sheet</th><th>Its areas (%d designed)</th></tr>%s</table>" % (sum(len(ar) for _, _, ar in summary), rows)
        qs = ""
        for bid, B, ar in summary:
            for q in B.get("ask", []):
                qs += '<li><a href="design/%s/index.html">%s</a>: %s</li>' % (bid, esc(B["name"]), esc(q))
            for x in ar:
                for q in x.get("ask", []):
                    qs += '<li><a href="design/%s/%s.html">%s %s</a>: %s</li>' % (bid, x["slug"], esc(x["id"]), esc(x["title"]), esc(q))
        if qs:
            tbl += '\n<details class="box"><summary><b>Every question the designs ask you, in one list</b></summary><ul>%s</ul></details>' % qs
        s = s[:s.index(a) + len(a)] + "\n" + tbl + "\n" + s[s.index(z):]
        io.open(notes, "w", encoding="utf-8", newline="\n").write(s)
    for w in WARN:
        print("WARN", w)
    print("warnings:", len(WARN))


if __name__ == "__main__":
    main()
