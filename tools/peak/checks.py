"""
Checks over the whole course that came out of the 11-12 playtest (docs/peak/playtest/).
They read stages/peak/course/*.json and the kit's models; they change nothing.
  python tools/peak/checks.py fronts   # note 40 / 47: what stands in FRONT of where a climber can be
  python tools/peak/checks.py backs    # note 51: places a climber can be with no painted layer behind
  python tools/peak/checks.py pits     # note 52: narrow slots between two holdable blocks, with a drop under
  python tools/peak/checks.py all

"Where a climber can be" is worked out, not drawn: the air within 2.3 m of anything that
can be held (grip rock, a mover, a rope), plus the line of every written move. It is a
fair guess, not the truth: a long fall or a throw goes outside it.
"""
import glob, json, math, os, struct, sys
from shapely.geometry import Polygon, Point, LineString, box
from shapely.ops import unary_union

_HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(_HERE, "..", ".."))
COURSE = os.path.join(ROOT, "stages", "peak", "course")
KIT = os.path.join(ROOT, "kit", "models")
ORDER = ["a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8", "a9", "a10", "a11", "st"]
META = json.load(open(os.path.join(COURSE, "_meta.json"), encoding="utf-8"))
KINDS = META["kinds"]
CLIMBER_FRONT = 0.5  # the climber's body reaches about this far toward the camera
LINE_UNITS = {"papel_string", "papel_tatters", "papel_line", "pennant_line", "marigold_garland"}


def load(aid):
    return json.load(open(os.path.join(COURSE, aid + ".json"), encoding="utf-8"))


def poly(pts):
    return Polygon(pts).buffer(0)


def space(a):
    """(where a climber can be, every solid) for an area."""
    solids = [poly(s["pts"]) for s in a["solids"] if not s.get("ghost")]
    solid_u = unary_union(solids) if solids else Point(0, 0).buffer(0.001)
    holds = [poly(s["pts"]) for s in a["solids"] if KINDS[s["kind"]]["grip"] and not s.get("ghost")]
    near = [unary_union(holds).buffer(2.3)] if holds else []
    for c in a["challenges"]:
        near.append(Point(c["anchor"]).buffer(2.3))
        for m in c["moves"]:
            near.append(LineString([m[1], m[2]]).buffer(2.3))
    for r in a["ropes"]:
        x, y = r["at"]
        end = r.get("to", [x, y - r["len"]])
        near.append(LineString([[x, y], end]).buffer(2.6))
    for m in a["movers"]:
        x, y = m["at"]
        mo = m["motion"]
        pts = [[x, y]]
        if mo["type"] == "path":
            pts = mo["pts"]
        elif mo["type"] in ("cycle", "sink", "crank"):
            pts = [[x, y], [x + mo["to"][0], y + mo["to"][1]]]
        reach = max(max(abs(p[0]), abs(p[1])) for sh in m["shapes"] for p in sh["pts"]) + 2.3
        near.append((LineString(pts) if len(pts) > 1 else Point(pts[0])).buffer(reach))
    for z in a["zones"]:
        if z["type"] == "water":
            near.append(box(*z["rect"]).buffer(1.0))
    sp = unary_union(near).difference(solid_u) if near else Point(0, 0).buffer(0.001)
    return sp, solid_u


# ---------------------------------------------------------------- kit model bounds
def _mat(nd):
    if "matrix" in nd:
        m = nd["matrix"]
        return [[m[c * 4 + r] for c in range(4)] for r in range(4)]
    t = nd.get("translation", [0, 0, 0]); s = nd.get("scale", [1, 1, 1]); x, y, z, w = nd.get("rotation", [0, 0, 0, 1])
    R = [[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
         [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
         [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)]]
    return [[R[r][0] * s[0], R[r][1] * s[1], R[r][2] * s[2], t[r]] for r in range(3)] + [[0, 0, 0, 1]]


_BOUNDS = {}


def model_bounds(name):
    """(lo, hi) of a kit model in its own metres, or None if it has not landed."""
    if name in _BOUNDS:
        return _BOUNDS[name]
    p = os.path.join(KIT, name + ".glb")
    out = None
    if os.path.exists(p):
        b = open(p, "rb").read()
        n = struct.unpack("<I", b[12:16])[0]
        j = json.loads(b[20:20 + n])
        lo = [1e9] * 3; hi = [-1e9] * 3

        def walk(i, M):
            nd = j["nodes"][i]
            A = _mat(nd)
            M2 = [[sum(M[r][k] * A[k][c] for k in range(4)) for c in range(4)] for r in range(4)]
            if "mesh" in nd:
                for pr in j["meshes"][nd["mesh"]]["primitives"]:
                    acc = j["accessors"][pr["attributes"]["POSITION"]]
                    for cx in (acc["min"][0], acc["max"][0]):
                        for cy in (acc["min"][1], acc["max"][1]):
                            for cz in (acc["min"][2], acc["max"][2]):
                                v = [M2[r][0] * cx + M2[r][1] * cy + M2[r][2] * cz + M2[r][3] for r in range(3)]
                                for k in range(3):
                                    lo[k] = min(lo[k], v[k]); hi[k] = max(hi[k], v[k])
            for c in nd.get("children", []):
                walk(c, M2)
        I = [[1 if r == c else 0 for c in range(4)] for r in range(4)]
        for sc in j.get("scenes", [{"nodes": list(range(len(j["nodes"])))}]):
            for i in sc["nodes"]:
                walk(i, I)
        out = (lo, hi)
    _BOUNDS[name] = out
    return out


def deco_scale(d):
    """The scale the game draws a deco at (peak.gd _deco: far from its asked size, it is fitted to it)."""
    s = float(d.get("scale", 1.0))
    b = model_bounds(d["model"])
    if b is None or d["model"] in LINE_UNITS:
        return s, b
    if "size" in d and not d.get("skin"):
        bw, bh = b[1][0] - b[0][0], b[1][1] - b[0][1]
        ww, wh = d["size"][0], d["size"][1]
        if bw > 0.05 and bh > 0.05:
            ratio = (ww / bw) if ww > wh * 2.0 else (wh / bh)
            if ratio > 1.3 or ratio < 0.75:
                s *= ratio
    return s, b


# ---------------------------------------------------------------- the checks
def fronts():
    print("== FRONTS: cards and models in front of where a climber can be")
    for aid in ORDER:
        a = load(aid)
        sp, _ = space(a)
        for i, c in enumerate(a["cards"]):
            if c["z"] <= CLIMBER_FRONT:
                continue
            p = poly(c["pts"])
            over = p.intersection(sp).area
            x0, y0, x1, y1 = p.bounds
            print("%s card %d  z %.1f  %s  %.0f x %.0f m at (%.0f, %.0f)..(%.0f, %.0f): %s" % (
                aid, i, c["z"], c["tone"], x1 - x0, y1 - y0, x0, y0, x1, y1,
                "COVERS %.0f m2 of climbing space" % over if over > 0.5 else "clear of the climb"))
        for d in a["decos"]:
            s, b = deco_scale(d)
            if b is None:
                continue
            front = d["at"][2] + b[1][2] * s
            if front <= CLIMBER_FRONT:
                continue
            x, y = d["at"][0], d["at"][1]
            foot = box(x + b[0][0] * s, y + b[0][1] * s, x + b[1][0] * s, y + b[1][1] * s)
            over = foot.intersection(sp).area
            if over > 0.3 and (b[1][1] - b[0][1]) * s > 0.5:
                print("%s model %s at (%.1f, %.1f, z %.1f) scale %.2f: its front is at z %.2f, over %.1f m2 of climbing space (%.1f m tall)" % (
                    aid, d["model"], x, y, d["at"][2], s, front, over, (b[1][1] - b[0][1]) * s))
        for m in a["movers"]:
            if "model" not in m:
                continue
            b = model_bounds(m["model"])
            if b is None:
                continue
            s = float(m.get("model_scale", 1.0))
            off = m.get("model_at", [0, 0, 0])
            front = (off[2] if len(off) > 2 else 0.0) + b[1][2] * s
            top_solid = max(p[1] for sh in m["shapes"] for p in sh["pts"])
            if front > CLIMBER_FRONT + 0.25 and (b[1][1] * s + off[1]) > top_solid + 0.3:
                print("%s mover %s (%s): its model's front is at z %.2f and stands %.2f m above what you stand on" % (
                    aid, m["id"], m["model"], front, b[1][1] * s + off[1] - top_solid))


def backs():
    print("== BACKS: inside the mountain, places a climber can be with no painted layer behind them")
    for aid in ORDER:
        a = load(aid)
        if aid == "st" or float(META["palettes"][a["palette"]].get("inside", 0.0)) < 0.5:
            continue
        sp, _ = space(a)
        cards = [poly(c["pts"]) for c in a["cards"] + load("st")["cards"] if c["z"] < 0]  # (the structure paints the well)
        covered = unary_union(cards) if cards else Point(0, 0).buffer(0.001)
        bare = sp.difference(covered).buffer(-0.25).buffer(0.25)
        parts = [g for g in getattr(bare, "geoms", [bare]) if g.area > 1.0]
        if not parts:
            print("%s: none" % aid)
        for g in sorted(parts, key=lambda g: -g.area):
            x0, y0, x1, y1 = g.bounds
            print("%s: %.0f m2 bare, x %.1f..%.1f, y %.1f..%.1f" % (aid, g.area, x0, x1, y0, y1))


def pits():
    print("== PITS: a slot up to 2 m wide between two holdable blocks, floors level, a drop of 3 m or more under it")
    for aid in ORDER:
        a = load(aid)
        holds = []
        for s in a["solids"]:
            if s.get("ghost") or not KINDS[s["kind"]]["grip"]:
                continue
            xs = [p[0] for p in s["pts"]]; ys = [p[1] for p in s["pts"]]
            if max(xs) - min(xs) >= 1.0:
                holds.append((min(xs), min(ys), max(xs), max(ys)))
        allp = unary_union([poly(s["pts"]) for s in a["solids"] if not s.get("ghost")] or [Point(0, 0).buffer(0.001)])
        seen = set()
        for l in holds:
            for r in holds:
                gap = r[0] - l[2]
                if not (0.3 <= gap <= 2.0) or abs(l[3] - r[3]) > 0.6:
                    continue
                top = min(l[3], r[3])
                key = (round(l[2], 1), round(r[0], 1), round(top, 1))
                if key in seen:
                    continue
                seen.add(key)
                shaft = box(l[2] + 0.05, top - 3.0, r[0] - 0.05, top - 0.02)
                if shaft.intersection(allp).area > 0.02 * shaft.area:
                    continue  # (something floors it: a step, not a pit)
                wall_l = box(l[2] - 0.02, max(l[1], top - 3.0), l[2] + 0.12, top - 0.06)
                wall_r = box(r[0] - 0.12, max(r[1], top - 3.0), r[0] + 0.02, top - 0.06)
                lined = 0
                for s in a["solids"]:
                    if s.get("ghost") or KINDS[s["kind"]]["grip"]:
                        continue
                    p = poly(s["pts"])
                    lined += p.intersection(wall_l).area > 0.5 * wall_l.area * 0.4
                    lined += p.intersection(wall_r).area > 0.5 * wall_r.area * 0.4
                print("%s: slot x %.2f..%.2f (%.2f m wide), floors at y %.2f: sides holdable for %.2f m and %.2f m%s" % (
                    aid, l[2], r[0], gap, top, top - max(l[1], top - 3.0), top - max(r[1], top - 3.0),
                    "  [lined slick]" if lined >= 2 else ""))


if __name__ == "__main__":
    what = sys.argv[1] if len(sys.argv) > 1 else "all"
    if what in ("fronts", "all"):
        fronts()
    if what in ("backs", "all"):
        backs()
    if what in ("pits", "all"):
        pits()
