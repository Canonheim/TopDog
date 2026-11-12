"""
Draw the course from its JSON, so an area can be judged without the game.

  python tools/peak/preview.py a1                 the whole area  -> docs/peak/preview/a1.png
  python tools/peak/preview.py a1 --at -200,40 --span 30    a 30 m window -> a1_at_-200_40.png
  python tools/peak/preview.py a1 --challenge 1.4           the window round that challenge
  python tools/peak/preview.py all                the whole mountain -> mountain.png
  python tools/peak/preview.py a1 --leak          also flood the air from the entry: where it gets out

Pale = grip. Near black = slick. Orange = hot, blue = ice, grey-tan = crumbles.
Outlined red = a mover (its path dashed). Green = rope. Blue box = water (arrow = flow).
Cyan box = wind. Magenta line = bounce. Yellow star = challenge anchor. Grey dashes = camera zone.
"""
import json, math, os, sys
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon as MPoly, Rectangle, Circle
from matplotlib.collections import PatchCollection

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from peaklib import COURSE_DIR, PREVIEW_DIR, KINDS, PALETTES, FRAME

ORDER = ["st", "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8", "a9", "a10", "a11"]


def load(aid):
    p = os.path.join(COURSE_DIR, aid + ".json")
    if not os.path.exists(p):
        return None
    return json.load(open(p, encoding="utf-8"))


def tone(pal, kind):
    if kind == "void":
        return "#FF00FF30"
    return PALETTES[pal].get(KINDS[kind]["tone"], "#FF00FF")


def rot(p, deg):
    c, s = math.cos(math.radians(deg)), math.sin(math.radians(deg))
    return (p[0] * c - p[1] * s, p[0] * s + p[1] * c)


def draw_area(ax, a, labels=True, light=False):
    pal = a["palette"]
    if not light:
        for c in a["cards"]:
            col = c["tone"] if c["tone"].startswith("#") else PALETTES[pal].get(c["tone"], "#888888")
            ax.add_patch(MPoly(c["pts"], closed=True, fc=col, ec="none", alpha=0.35, zorder=0))
    patches, cols = [], []
    for s in a["solids"]:
        patches.append(MPoly(s["pts"], closed=True))
        cols.append(tone(pal, s["kind"]))
    if patches:
        ax.add_collection(PatchCollection(patches, facecolors=cols, edgecolors="#00000055", linewidths=0.3, zorder=2))
    for z in a["zones"]:
        t = z["type"]
        if t == "water":
            r = z["rect"]
            ax.add_patch(Rectangle((r[0], r[1]), r[2] - r[0], z["surface"] - r[1], fc="#2A7FD0", ec="#1560B0", alpha=0.45, zorder=1))
            f = z["flow"]
            if abs(f[0]) + abs(f[1]) > 0.01:
                cx, cy = (r[0] + r[2]) / 2, z["surface"] - 0.6
                ax.annotate("", xy=(cx + f[0] * 1.5, cy + f[1] * 1.5), xytext=(cx, cy), arrowprops=dict(arrowstyle="->", color="white", lw=1.2), zorder=6)
        elif t == "wind":
            r = z["rect"]
            ax.add_patch(Rectangle((r[0], r[1]), r[2] - r[0], r[3] - r[1], fc="#40E0E0", ec="#20A0A0", alpha=0.13, ls="--", zorder=1))
            f = z["accel"]
            cx, cy = (r[0] + r[2]) / 2, (r[1] + r[3]) / 2
            ax.annotate("", xy=(cx + f[0] * 0.6, cy + f[1] * 0.6), xytext=(cx, cy), arrowprops=dict(arrowstyle="->", color="#108080", lw=1.2), zorder=6)
        elif t == "geyser":
            x, y = z["at"]
            ax.add_patch(Rectangle((x - z["w"] / 2, y), z["w"], z["height"], fc="#FFFFFF", ec="#F08020", alpha=0.25, zorder=1))
        elif t == "bounce":
            ax.plot([z["a"][0], z["b"][0]], [z["a"][1], z["b"][1]], color="#E020C0", lw=2.2, zorder=7)
            mx, my = (z["a"][0] + z["b"][0]) / 2, (z["a"][1] + z["b"][1]) / 2
            dx, dy = z["b"][0] - z["a"][0], z["b"][1] - z["a"][1]
            L = math.hypot(dx, dy) or 1
            ax.annotate("", xy=(mx - dy / L * 1.2, my + dx / L * 1.2), xytext=(mx, my), arrowprops=dict(arrowstyle="->", color="#E020C0", lw=1), zorder=7)
        elif t == "puff":
            ax.add_patch(Circle(z["at"], z["r"], fc="#F0A0F0", ec="#C040C0", alpha=0.7, zorder=7))
        elif t == "dark":
            r = z["rect"]
            ax.add_patch(Rectangle((r[0], r[1]), r[2] - r[0], r[3] - r[1], fc="#000000", ec="none", alpha=0.18, zorder=1))
        elif t == "finish":
            r = z["rect"]
            ax.add_patch(Rectangle((r[0], r[1]), r[2] - r[0], r[3] - r[1], fc="#FFD700", ec="#B08000", alpha=0.6, zorder=7))
    for m in a["movers"]:
        ox, oy = m["at"]
        mo = m["motion"]
        for sh in m["shapes"]:
            ax.add_patch(MPoly([(ox + p[0], oy + p[1]) for p in sh["pts"]], closed=True, fc=tone(pal, sh["kind"]), ec="#E02020", lw=0.9, zorder=4))
        if mo["type"] == "path":
            ax.plot([p[0] for p in mo["pts"]], [p[1] for p in mo["pts"]], color="#E02020", lw=0.7, ls="--", zorder=3)
        elif mo["type"] == "cycle":
            ax.plot([ox, ox + mo["to"][0]], [oy, oy + mo["to"][1]], color="#E02020", lw=0.7, ls="--", zorder=3)
        elif mo["type"] == "swing":
            for sg in (-1, 1):
                for sh in m["shapes"][-1:]:
                    ax.add_patch(MPoly([(ox + rot(p, sg * mo["amp"])[0], oy + rot(p, sg * mo["amp"])[1]) for p in sh["pts"]], closed=True, fc="none", ec="#E02020", lw=0.5, ls=":", zorder=3))
        elif mo["type"] == "spin":
            rr = max(math.hypot(p[0], p[1]) for sh in m["shapes"] for p in sh["pts"])
            ax.add_patch(Circle((ox, oy), rr, fc="none", ec="#E02020", lw=0.5, ls=":", zorder=3))
        if labels:
            ax.text(ox, oy, m["id"], fontsize=4, color="#A00000", zorder=9)
    for b in a["bodies"]:
        ox, oy = b["at"]
        for sh in b["shapes"]:
            ax.add_patch(MPoly([(ox + p[0], oy + p[1]) for p in sh["pts"]], closed=True, fc=tone(pal, sh["kind"]), ec="#8020E0", lw=0.9, zorder=4))
        if "hinge" in b:
            ax.plot([b["hinge"][0]], [b["hinge"][1]], "o", color="#8020E0", ms=3, zorder=8)
    for r in a["ropes"]:
        x, y = r["at"]
        if "to" in r:
            tx, ty = r["to"]
            sag = max(0.0, r["len"] * r["slack"] - math.dist((x, y), (tx, ty))) * 0.6 + 0.2
            xs = [x + (tx - x) * i / 10 for i in range(11)]
            ys = [y + (ty - y) * i / 10 - sag * 4 * (i / 10) * (1 - i / 10) for i in range(11)]
            ax.plot(xs, ys, color="#20A040", lw=1.6, zorder=5)
        else:
            ax.plot([x, x], [y, y - r["len"]], color="#20A040", lw=1.4, zorder=5)
            if "bob" in r:
                ax.add_patch(Rectangle((x - r["bob"]["w"] / 2, y - r["len"] - r["bob"]["h"]), r["bob"]["w"], r["bob"]["h"], fc="#80D090", ec="#20A040", zorder=5))
    for s in a["spawners"]:
        ax.plot([s["at"][0]], [s["at"][1]], "x", color="#D03030", ms=5, zorder=8)
        ax.annotate("", xy=(s["at"][0] + s["vel"][0] * 0.4, s["at"][1] + s["vel"][1] * 0.4 - 1.5), xytext=tuple(s["at"]), arrowprops=dict(arrowstyle="->", color="#D03030", lw=0.8), zorder=8)
    for st in a["statues"]:
        ax.plot([st["at"][0]], [st["at"][1]], marker="$\\dag$", color="#806040", ms=7, zorder=8)
    if not light:
        for c in a["cams"]:
            r = c["rect"]
            ax.add_patch(Rectangle((r[0], r[1]), r[2] - r[0], r[3] - r[1], fc="none", ec="#808080", lw=0.5, ls="--", zorder=1))
        for l in a["lights"]:
            ax.add_patch(Circle((l["at"][0], l["at"][1]), 0.35, fc=l["color"], ec="#806000", lw=0.4, zorder=8))
        for d in a["decos"]:
            ax.plot([d["at"][0]], [d["at"][1]], ".", color="#606060", ms=2, zorder=8)
    for c in a["challenges"]:
        ax.plot([c["anchor"][0]], [c["anchor"][1]], marker="*", color="#FFD000", mec="#604000", ms=9 if labels else 5, zorder=10)
        if labels:
            ax.text(c["anchor"][0] + 0.5, c["anchor"][1] + 0.6, "%s %s" % (c["id"], c["name"]), fontsize=5.5, color="#201000", zorder=11,
                    bbox=dict(fc="#FFF6D0", ec="#806000", lw=0.3, pad=0.8))
        for mv in c["moves"]:
            if mv[0] in ("reach", "fling"):
                ax.annotate("", xy=tuple(mv[2]), xytext=tuple(mv[1]), arrowprops=dict(arrowstyle="->", color="#FF8000" if mv[0] == "fling" else "#40A000", lw=0.8, ls="-"), zorder=9)
    for name, p, col in (("IN", a["entry"], "#00A000"), ("OUT", a["exit"], "#D00000")):
        ax.plot([p[0]], [p[1]], "D", color=col, ms=5, zorder=10)
        if labels:
            ax.text(p[0], p[1] - 1.6, name, fontsize=6, color=col, ha="center", zorder=10)


def leak(a, res=0.4):
    """Flood the air from the entry. Returns the points where it leaves the region other
    than through a declared opening."""
    import numpy as np
    import shapely
    from shapely.geometry import Polygon
    from shapely.ops import unary_union
    x0, y0, x1, y1 = a["region"]
    pad = 8.0
    xs = np.arange(x0 - pad, x1 + pad, res)
    ys = np.arange(y0 - pad, y1 + pad, res)
    gx, gy = np.meshgrid(xs, ys)
    rock = unary_union([Polygon(s["pts"]).buffer(0.02) for s in a["solids"]])
    solid = shapely.contains_xy(rock, gx, gy)
    # A declared opening is a door to somewhere else: the flood stops at it.
    for o in a["openings"]:
        solid |= (gx >= o[0] - 0.3) & (gx <= o[2] + 0.3) & (gy >= o[1] - 0.3) & (gy <= o[3] + 0.3)
    h, w = solid.shape
    seen = np.zeros_like(solid, dtype=bool)
    # Flood from every challenge's start (the entry point itself may lie in the area before).
    starts = [c["anchor"] for c in a["challenges"]] or [a["entry"]]
    stack = [(int((p[1] + 1.2 - (y0 - pad)) / res), int((p[0] - (x0 - pad)) / res)) for p in starts]
    out = []
    while stack:
        j, i = stack.pop()
        if j < 0 or i < 0 or j >= h or i >= w or seen[j, i] or solid[j, i]:
            continue
        seen[j, i] = True
        x, y = xs[i], ys[j]
        if x < x0 - pad + 1 or x > x1 + pad - 1 or y < y0 - pad + 1 or y > y1 + pad - 1:
            out.append((round(float(x), 1), round(float(y), 1)))
            continue
        stack.extend(((j + 1, i), (j - 1, i), (j, i + 1), (j, i - 1)))
    return out, seen, (xs, ys)


def render(aids, out, window=None, labels=True, px_per_m=10.0, show_leak=False):
    areas = [a for a in (load(i) for i in aids) if a]
    if not areas:
        print("nothing to draw")
        return
    if window:
        x0, y0, x1, y1 = window
    elif len(areas) > 2:
        x0, y0, x1, y1 = -480, -45, 30, 1025  # the whole mountain's climbed part
    else:
        x0 = min(a["region"][0] for a in areas if a["id"] != "st" or len(areas) == 1) - 6
        y0 = min(a["region"][1] for a in areas if a["id"] != "st" or len(areas) == 1) - 6
        x1 = max(a["region"][2] for a in areas if a["id"] != "st" or len(areas) == 1) + 6
        y1 = max(a["region"][3] for a in areas if a["id"] != "st" or len(areas) == 1) + 6
    w, h = (x1 - x0) * px_per_m / 100.0, (y1 - y0) * px_per_m / 100.0
    fig = plt.figure(figsize=(max(w, 3), max(h, 3)), dpi=100)
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_facecolor(PALETTES[areas[-1]["palette"]]["back2"] if len(areas) == 1 else "#8FB8D8")
    many = len(areas) > 2
    for a in areas:
        if many and a["id"] != "st":
            r = a["region"]
            ax.add_patch(Rectangle((r[0], r[1]), r[2] - r[0], r[3] - r[1], fc=PALETTES[a["palette"]]["back2"], ec="none", zorder=0))
        draw_area(ax, a, labels=labels and not many, light=many)
        if many and a["id"] != "st":
            r = a["region"]
            ax.text((r[0] + r[2]) / 2, r[3] - 6, a["name"], fontsize=11, color="white", ha="center", zorder=12,
                    bbox=dict(fc="#000000AA", ec="none", pad=2))
        if show_leak and a["id"] not in ("st",):
            pts, seen, (xs, ys) = leak(a)
            ax.imshow(seen, extent=(xs[0], xs[-1], ys[0], ys[-1]), origin="lower", cmap="Greens", alpha=0.25, zorder=1, aspect="auto")
            for p in pts[:400]:
                ax.plot([p[0]], [p[1]], "s", color="#FF0000", ms=3, zorder=12)
            print("%s leak: %d cells escape%s" % (a["id"], len(pts), (" near " + str(pts[:6])) if pts else ""))
    ax.set_xlim(x0, x1)
    ax.set_ylim(y0, y1)
    ax.set_aspect("equal")
    step = 10 if (x1 - x0) > 60 else (5 if (x1 - x0) > 25 else 1)
    ax.set_xticks([v for v in range(int(x0 // step) * step, int(x1) + 1, step)])
    ax.set_yticks([v for v in range(int(y0 // step) * step, int(y1) + 1, step)])
    ax.grid(True, color="#FFFFFF", alpha=0.18, lw=0.4)
    ax.tick_params(direction="in", labelsize=6, colors="#FFFFFF", pad=-14)
    os.makedirs(PREVIEW_DIR, exist_ok=True)
    fig.savefig(out, dpi=100)
    plt.close(fig)
    print("drew", os.path.relpath(out))


if __name__ == "__main__":
    args = sys.argv[1:]
    if not args:
        print(__doc__)
        sys.exit(0)
    which = args[0]
    opt = {args[i]: (args[i + 1] if i + 1 < len(args) and not args[i + 1].startswith("--") else "") for i in range(1, len(args)) if args[i].startswith("--")}
    if which == "all":
        render(ORDER, os.path.join(PREVIEW_DIR, "mountain.png"), labels=False, px_per_m=float(opt.get("--scale", 4)))
        sys.exit(0)
    a = load(which)
    if a is None:
        print("no course file for", which)
        sys.exit(1)
    window = None
    name = which
    span = float(opt.get("--span", 30))
    if "--challenge" in opt:
        c = next(c for c in a["challenges"] if c["id"] == opt["--challenge"])
        window = (c["anchor"][0] - span / 2, c["anchor"][1] - span * 0.35, c["anchor"][0] + span / 2, c["anchor"][1] + span * 0.65)
        name = "%s_c%s" % (which, opt["--challenge"].replace(".", "_"))
    elif "--at" in opt:
        x, y = [float(v) for v in opt["--at"].split(",")]
        window = (x - span / 2, y - span / 2, x + span / 2, y + span / 2)
        name = "%s_at_%d_%d" % (which, x, y)
    scale = float(opt.get("--scale", 40 if window else 10))
    render([which], os.path.join(PREVIEW_DIR, name + ".png"), window=window, px_per_m=scale, show_leak="--leak" in opt)
