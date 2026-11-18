"""
THE SWEEPS (the quality run's phase 0; docs/peak/QUALITY_TO_9_PLAN.md part 4): five checks over the course
as the game draws it, run on every course build (peaklib.Area.save prints that area's counts) and over the
whole mountain by hand:
  python tools/peak/sweeps.py            -> docs/peak/quality/SWEEPS.md (every hit, by biome)
  python tools/peak/sweeps.py a2 a3      -> those areas only, printed

Every drawn piece is placed in the course's metres (x, y) and depth (z) as the game draws it:
  - a solid: its prism (z -1.2 .. 1.2; the slim-bar rule's -0.2 .. 0.2 and -0.3 .. 0.3; a ghost's
    -0.26 .. -0.14), unless a landed skin is its look;
  - a deco whose model has landed: the model's own mesh (from its .glb), scaled and turned as the game
    does (peak.gd _deco: a size more than a quarter off rescales it), mirrored if flipped;
  - a deco whose model has not landed: its stand-in card (none in front of the play space or 10 m back);
  - a card: a plane at its z.
The five sweeps:
  1. ZFIGHT   two pieces' flat faces in one plane, facing the same way (both at the camera, both up, or both down),
              overlapping: they flicker (notes 109, 119). Read from the meshes' own faces.
  2. DEPTH    a real thing near the climb (a model, z -2.6 .. 1.3, under 30 m2) that overlaps another piece
              on screen and comes within a metre of it in depth, but touches nothing there (note 115: drawn
              as if only seen from the front).
  3. SKIN     a solid's drawing against its collision: a skin, or a mover's model, more than SKIN_TOL off its
              solid's outline (notes 113, 124, 129, 133).
  4. STANDIN  a plain stand-in drawn in the game, and a solid with no drawing at all (note 104: a solid whose
              landed skin has no deco near it to wear).
  5. CARD     a blank or flat card: one tone over CARD_AREA m2, in the set (z -11 .. +3: the interiors' dark
              backstops at -11.6 are meant flat).
A model's bounds stand for it in sweeps 2 and 3: a hit there is a place to look, and the frame decides.
"""
import json, math, os, struct, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
COURSE = os.path.join(ROOT, "stages", "peak", "course")
MODELS = os.path.join(ROOT, "kit", "models")
REPORT = os.path.join(ROOT, "docs", "peak", "quality", "SWEEPS.md")
AREAS = ["a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8", "a9", "a10", "a11"]
HALF = 1.2
PLANE = 0.004       # m: faces this close are one plane
OVERLAP = 0.02      # m2: a shared face must overlap this much to flicker
SKIN_TOL = 0.3      # m: a skin's edge further than this from its solid's is a mismatch
CARD_AREA = 6.0     # m2
FALLBACK = {"vulture_flying": "vulture", "tele_gondola_express": "gondola", "bellows_forja": "bellows",
            "slag_raft_forja": "slag_raft", "drop_hammer_forja": "drop_hammer", "anvil_forja": "anvil",
            "anvil_great_forja": "anvil_great", "bull_wheel_76": "bull_wheel", "gondola_tele": "gondola",
            "gondola_dead_tele": "gondola_dead", "chair_tele": "chair", "zip_trolley_tele": "zip_trolley",
            "counterweight_hung_tele": "counterweight_hung", "cable_station_low_tele": "cable_station_low",
            "tormenta_vane": "anemometer", "tormenta_kite": "kite", "tormenta_balloon": "weather_balloon",
            "tormenta_wind_sock": "wind_sock", "cumbre_bell": "summit_bell"}
STRETCH = {"hanger_chain", "counterweight_chain", "balloon_tether", "forja_drive_rod"}
_glb, _bounds, _faces = {}, {}, {}


def _path(name):
    p = os.path.join(MODELS, name + ".glb")
    if os.path.exists(p):
        return p
    alt = FALLBACK.get(name) or (name[:-5] if name.endswith("_jade") else None)
    return _path(alt) if alt else None


def _read(name):
    """(the glb's json, its bytes, where its binary chunk starts), or None if the model has not landed."""
    if name in _glb:
        return _glb[name]
    p = _path(name)
    r = None
    if p:
        try:
            b = open(p, "rb").read()
            n = struct.unpack("<I", b[12:16])[0]
            r = (json.loads(b[20:20 + n]), b, 20 + n + 8)
        except Exception:
            r = None
    _glb[name] = r
    return r


def model_bounds(name):
    """(min xyz, max xyz) of a kit model's meshes, or None if it has not landed."""
    if name not in _bounds:
        g = _read(name)
        res = None
        if g:
            j = g[0]
            lo, hi = [1e9] * 3, [-1e9] * 3
            for m in j.get("meshes", []):
                for p in m["primitives"]:
                    a = j["accessors"][p["attributes"]["POSITION"]]
                    for k in range(3):
                        lo[k] = min(lo[k], a["min"][k])
                        hi[k] = max(hi[k], a["max"][k])
            res = (lo, hi) if lo[0] < 1e8 else None
        _bounds[name] = res
    return _bounds[name]


def model_faces(name):
    """A model's flat faces that can flicker: {("z", plane): [triangles (x, y)], ("y", plane): [triangles (x, z)]},
    the faces whose normal points at the camera (+z) or up (+y), by plane (to 5 mm)."""
    if name in _faces:
        return _faces[name]
    out = {}
    g = _read(name)
    if g:
        j, b, bin0 = g
        try:
            def acc(i):
                a = j["accessors"][i]
                bv = j["bufferViews"][a["bufferView"]]
                off = bin0 + bv.get("byteOffset", 0) + a.get("byteOffset", 0)
                ct = {5126: ("f", 4), 5123: ("H", 2), 5125: ("I", 4), 5121: ("B", 1)}[a["componentType"]]
                nc = {"SCALAR": 1, "VEC2": 2, "VEC3": 3}[a["type"]]
                stride = bv.get("byteStride", ct[1] * nc)
                return [struct.unpack_from("<" + ct[0] * nc, b, off + k * stride) for k in range(a["count"])]
            for m in j.get("meshes", []):
                for p in m["primitives"]:
                    V = acc(p["attributes"]["POSITION"])
                    I = [q[0] for q in acc(p["indices"])] if "indices" in p else list(range(len(V)))
                    for t in range(0, len(I) - 2, 3):
                        A, B, C = V[I[t]], V[I[t + 1]], V[I[t + 2]]
                        ux, uy, uz = B[0] - A[0], B[1] - A[1], B[2] - A[2]
                        vx, vy, vz = C[0] - A[0], C[1] - A[1], C[2] - A[2]
                        nx, ny, nz = uy * vz - uz * vy, uz * vx - ux * vz, ux * vy - uy * vx
                        L = math.sqrt(nx * nx + ny * ny + nz * nz)
                        if L < 1e-9:
                            continue
                        if nz / L > 0.995:
                            out.setdefault(("z", round(A[2] / 0.005) * 0.005), []).append(((A[0], A[1]), (B[0], B[1]), (C[0], C[1])))
                        elif ny / L > 0.995:
                            out.setdefault(("y", round(A[1] / 0.005) * 0.005), []).append(((A[0], A[2]), (B[0], B[2]), (C[0], C[2])))
                        elif ny / L < -0.995:  # (an underside: seen from below, under a roof, it flickers too: q8 at 1.13)
                            out.setdefault(("-y", round(A[1] / 0.005) * 0.005), []).append(((A[0], A[2]), (B[0], B[2]), (C[0], C[2])))
        except Exception:
            out = {}
    _faces[name] = out
    return out


class Piece:
    __slots__ = ("kind", "name", "x0", "x1", "y0", "y1", "z0", "z1", "where", "grip", "card", "faces")

    def __init__(self, kind, name, x0, x1, y0, y1, z0, z1, where, grip=False, card=False):
        self.kind, self.name, self.where, self.grip, self.card = kind, name, where, grip, card
        self.x0, self.x1, self.y0, self.y1, self.z0, self.z1 = x0, x1, y0, y1, z0, z1
        self.faces = []  # [(axis "z" | "y", the plane's world value, its shape in world: (x, y) or (x, z))]

    def label(self):
        return "%s `%s`" % (self.kind, self.name)


def _rot_box(x0, x1, y0, y1, ang):
    if abs(ang) < 0.01:
        return x0, x1, y0, y1
    c, s = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    xs, ys = [], []
    for x, y in ((x0, y0), (x1, y0), (x1, y1), (x0, y1)):
        xs.append(x * c - y * s)
        ys.append(x * s + y * c)
    return min(xs), max(xs), min(ys), max(ys)


def deco_piece(d, aid, i):
    from shapely.geometry import box as sbox
    x, y, z = d["at"][0], d["at"][1], (d["at"][2] if len(d["at"]) > 2 else -0.8)
    s = float(d.get("scale", 1.0))
    size = d.get("size")
    b = model_bounds(d["model"])
    if b is None:
        if d.get("skin"):
            return None  # (a skin not landed: its solids are drawn)
        if z > HALF or z <= -10.0:
            return None  # (the game draws no stand-in in front of the play space or far back)
        w, h, dd = (size or [0.6, 0.6, 0.3])
        x0, x1, y0, y1 = _rot_box(-w / 2, w / 2, 0.0, h, float(d.get("rot", 0.0)))
        pc = Piece("standin", d["model"], x + x0, x + x1, y + y0, y + y1, z - min(dd, 0.12) / 2, z + min(dd, 0.12) / 2,
                   "%s deco %d" % (aid, i))
        pc.faces.append(("z", round(pc.z1, 3), sbox(pc.x0, pc.y0, pc.x1, pc.y1)))
        return pc
    lo, hi = b
    if size and not d.get("skin") and d["model"] not in STRETCH:
        bx, by = hi[0] - lo[0], hi[1] - lo[1]
        if bx > 0.05 and by > 0.05:
            wide = size[0] > size[1] * 2.0
            ratio = size[0] / bx if wide else size[1] / by
            if ratio > 1.3 or ratio < 0.75:
                s *= ratio
    mx0, mx1 = (lo[0] * s, hi[0] * s) if not d.get("flip") else (-hi[0] * s, -lo[0] * s)
    x0, x1, y0, y1 = _rot_box(mx0, mx1, lo[1] * s, hi[1] * s, float(d.get("rot", 0.0)))
    pc = Piece("deco", d["model"], x + x0, x + x1, y + y0, y + y1, z + lo[2] * s, z + hi[2] * s, "%s deco %d" % (aid, i))
    _deco_faces(pc, d, s, x, y, z)
    _cut(pc, d)
    return pc


def _cut(pc, d):
    """A model cut short in the game (peak.gd _cut_at): `cut_below` a height, `cut_west` an x. Its bounds and
    faces end at the cut (the cut's own closing face is left out: it faces down, or west)."""
    from shapely.geometry import box as sbox
    BIG = 1e5
    if "cut_west" in d:
        c = float(d["cut_west"])
        pc.x0 = max(pc.x0, c)
        keep = sbox(c, -BIG, BIG, BIG)  # (x >= c, in both the (x, y) and the (x, z) planes)
        pc.faces = [(a, pl, g.intersection(keep)) for a, pl, g in pc.faces]
    if "cut_below" in d:
        c = float(d["cut_below"])
        pc.y0 = max(pc.y0, c)
        keep = sbox(-BIG, c, BIG, BIG)
        pc.faces = [(a, pl, g.intersection(keep) if a == "z" else g) for a, pl, g in pc.faces if a == "z" or pl >= c - 1e-6]
    pc.faces = [f for f in pc.faces if f[2].area > 0.01]


def _deco_faces(pc, d, s, x, y, z):
    from shapely.geometry import Polygon
    from shapely.ops import unary_union
    fx = -s if d.get("flip") else s
    ang = math.radians(float(d.get("rot", 0.0)))
    c, sn = math.cos(ang), math.sin(ang)
    for (axis, plane), tris in model_faces(d["model"]).items():
        polys = []
        for t in tris:
            if axis == "z":  # (turned about z, a face toward the camera stays one)
                pts = [(x + (u * fx) * c - (v * s) * sn, y + (u * fx) * sn + (v * s) * c) for u, v in t]
            elif abs(ang) < 0.01:
                pts = [(x + u * fx, z + w * s) for u, w in t]
            else:
                continue  # (a turned piece's tops are no longer level)
            g = Polygon(pts)
            if g.is_valid and g.area > 1e-5:
                polys.append(g)
        if polys:
            u = unary_union(polys)
            if u.area > 0.01:
                pc.faces.append((axis, round((z + plane * s) if axis == "z" else (y + plane * s), 3), u))


def solid_z(s):
    if "z" in s:
        return s["z"][0], s["z"][1]
    xs, ys = [p[0] for p in s["pts"]], [p[1] for p in s["pts"]]
    w, h = max(xs) - min(xs), max(ys) - min(ys)
    if s.get("ghost"):
        return -0.26, -0.14
    if min(w, h) <= 0.3 and max(w, h) <= 1.5:
        return -0.2, 0.2
    if max(w, h) <= 0.75:
        return -0.3, 0.3
    return -HALF, HALF


def load(aid):
    return json.load(open(os.path.join(COURSE, aid + ".json"), encoding="utf-8"))


def pieces_of(aid, c, grips):
    from shapely.geometry import Polygon, Point, box as sbox
    out = []
    for i, s in enumerate(c.get("solids", [])):
        if s["kind"] == "void":
            continue
        if s.get("skin") and model_bounds(s["skin"]) is not None:
            continue  # (its skin is its look: the deco stands for it)
        xs, ys = [p[0] for p in s["pts"]], [p[1] for p in s["pts"]]
        z0, z1 = solid_z(s)
        pc = Piece("solid", s["kind"], min(xs), max(xs), min(ys), max(ys), z0, z1, "%s solid %d" % (aid, i), grip=s["kind"] in grips)
        poly = Polygon(s["pts"]).buffer(0)
        if poly.area > 0.01:
            pc.faces.append(("z", round(z1, 3), poly))
            pts = s["pts"]
            for k in range(len(pts)):
                (ax, ay), (bx, by) = pts[k], pts[(k + 1) % len(pts)]
                if abs(ay - by) < 1e-3 and abs(ax - bx) > 0.05 and not poly.contains(Point((ax + bx) / 2, ay + 0.01)):
                    pc.faces.append(("y", round(ay, 3), sbox(min(ax, bx), z0, max(ax, bx), z1)))  # (an edge with air above it)
                elif abs(ay - by) < 1e-3 and abs(ax - bx) > 0.05 and not poly.contains(Point((ax + bx) / 2, ay - 0.01)):
                    pc.faces.append(("-y", round(ay, 3), sbox(min(ax, bx), z0, max(ax, bx), z1)))  # (an edge with air below it)
        out.append(pc)
    for i, d in enumerate(c.get("decos", [])):
        p = deco_piece(d, aid, i)
        if p is not None:
            out.append(p)
    for i, cd in enumerate(c.get("cards", [])):
        xs, ys = [p[0] for p in cd["pts"]], [p[1] for p in cd["pts"]]
        z = float(cd.get("z", -4.0))
        pc = Piece("card", cd.get("tone", "?"), min(xs), max(xs), min(ys), max(ys), z, z, "%s card %d" % (aid, i), card=True)
        g = Polygon(cd["pts"]).buffer(0)
        if g.area > 0.01:
            pc.faces.append(("z", round(z, 3), g))
        out.append(pc)
    return out


def _ov(a0, a1, b0, b1):
    return max(0.0, min(a1, b1) - max(a0, b0))


def sweep_zfight(P):
    """Two pieces' flat faces in one plane, facing the same way, overlapping."""
    hits = []
    P = sorted([p for p in P if p.faces], key=lambda p: p.x0)
    for i, a in enumerate(P):
        for b in P[i + 1:]:
            if b.x0 > a.x1 + 0.01:
                break
            if a.kind == "solid" and b.kind == "solid":
                continue  # (the area's own rock mesh is one piece: its faces are welded)
            if _ov(a.y0 - 0.01, a.y1 + 0.01, b.y0, b.y1) <= 0 or b.z0 > a.z1 + 0.01 or a.z0 > b.z1 + 0.01:
                continue
            best = None
            for fa in a.faces:
                for fb in b.faces:
                    if fa[0] != fb[0] or abs(fa[1] - fb[1]) > PLANE:
                        continue
                    ov = fa[2].intersection(fb[2]).area
                    if ov > OVERLAP and (best is None or ov > best[1]):
                        best = (fa, ov)
            if best:
                (axis, plane, _), ov = best
                hits.append((a, b, "%s both at %s %.2f, overlapping %.2f m2" % ({"z": "front faces", "y": "tops", "-y": "undersides"}[axis], axis.lstrip("-"), plane, ov)))
    return hits


def sweep_depth(P):
    hits = []
    real = [p for p in P if p.kind == "deco" and -2.6 <= p.z0 and p.z1 <= 1.3 and (p.x1 - p.x0) * (p.y1 - p.y0) < 30.0]
    others = sorted([p for p in P if not p.card], key=lambda p: p.x0)
    for a in real:
        near, touch = None, False
        for b in others:
            if b is a:
                continue
            if b.x0 > a.x1:
                break
            if _ov(a.x0, a.x1, b.x0, b.x1) * _ov(a.y0, a.y1, b.y0, b.y1) < 0.05:
                continue
            gap = max(b.z0 - a.z1, a.z0 - b.z1)
            if gap <= 0.05:
                touch = True
                break
            if gap < 1.0 and (near is None or gap < near[1]):
                near = (b, gap)
        if near and not touch:
            hits.append((a, near[0], "%.2f m apart in depth, overlapping on screen" % near[1]))
    return hits


def sweep_skin(aid, c):
    hits = []
    groups = {}
    for i, s in enumerate(c.get("solids", [])):
        if s.get("skin"):
            groups.setdefault(s["skin"], []).append((i, s))
    decos = [(i, d) for i, d in enumerate(c.get("decos", [])) if d.get("skin")]
    for stem, sols in groups.items():
        if model_bounds(stem) is None:
            continue
        for i, d in [(i, d) for i, d in decos if d["model"] == stem]:
            p = deco_piece(d, aid, i)
            if p is None:
                continue
            near = [s for _, s in sols if _ov(p.x0 - 1.0, p.x1 + 1.0, min(q[0] for q in s["pts"]), max(q[0] for q in s["pts"])) > 0
                    and _ov(p.y0 - 1.0, p.y1 + 1.0, min(q[1] for q in s["pts"]), max(q[1] for q in s["pts"])) > 0]
            if not near:
                continue
            xs = [q[0] for s in near for q in s["pts"]]
            ys = [q[1] for s in near for q in s["pts"]]
            off = max(abs(p.x0 - min(xs)), abs(p.x1 - max(xs)), abs(p.y0 - min(ys)), abs(p.y1 - max(ys)))
            if off > SKIN_TOL:
                hits.append((p, None, "drawn %.1f .. %.1f x %.1f .. %.1f, its solid %.1f .. %.1f x %.1f .. %.1f (%.2f m off)" % (
                    p.x0, p.x1, p.y0, p.y1, min(xs), max(xs), min(ys), max(ys), off)))
    for m in c.get("movers", []) + c.get("bodies", []):
        b = model_bounds(m.get("model", "")) if m.get("model") else None
        if b is None or m.get("model_scale") or m.get("model_at"):
            continue
        xs = [q[0] for sh in m["shapes"] for q in sh["pts"]]
        ys = [q[1] for sh in m["shapes"] for q in sh["pts"]]
        lo, hi = b
        off = max(abs(lo[0] - min(xs)), abs(hi[0] - max(xs)), abs(lo[1] - min(ys)), abs(hi[1] - max(ys)))
        if off > max(SKIN_TOL, 0.15 * max(hi[0] - lo[0], hi[1] - lo[1])):
            hits.append((Piece("mover", m["model"], m["at"][0] + lo[0], m["at"][0] + hi[0], m["at"][1] + lo[1], m["at"][1] + hi[1],
                               lo[2], hi[2], "%s mover %s" % (aid, m["id"])), None,
                         "model %.1f .. %.1f x %.1f .. %.1f against its shapes %.1f .. %.1f x %.1f .. %.1f (%.2f m off)" % (
                             lo[0], hi[0], lo[1], hi[1], min(xs), max(xs), min(ys), max(ys), off)))
    return hits


def sweep_standin(aid, c, P):
    hits = [(p, None, "a plain stand-in card %.1f x %.1f m" % (p.x1 - p.x0, p.y1 - p.y0)) for p in P if p.kind == "standin"]
    drawn = {}  # skin -> the drawn boxes of its decos
    for i, d in enumerate(c.get("decos", [])):
        if d.get("skin") and model_bounds(d["model"]) is not None:
            p = deco_piece(d, aid, i)
            if p is not None:
                drawn.setdefault(d["model"], []).append(p)
    boxes = {}
    for i, s in enumerate(c.get("solids", [])):
        stem = s.get("skin")
        if not stem or model_bounds(stem) is None or s["kind"] == "void":
            continue
        xs, ys = [q[0] for q in s["pts"]], [q[1] for q in s["pts"]]
        boxes.setdefault(stem, []).append((min(xs), max(xs), min(ys), max(ys)))
        cx, cy = (min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2
        if not any(p.x0 - 0.5 <= cx <= p.x1 + 0.5 and p.y0 - 0.5 <= cy <= p.y1 + 0.5 for p in drawn.get(stem, [])):
            hits.append((Piece("solid", s["kind"], min(xs), max(xs), min(ys), max(ys), -HALF, HALF, "%s solid %d" % (aid, i)), None,
                         "INVISIBLE: its skin `%s` has landed, so the solid is not drawn, and no deco of it covers it" % stem))
    for stem, ps in drawn.items():
        for p in ps:
            if not any(_ov(p.x0, p.x1, b[0], b[1]) > 0 and _ov(p.y0, p.y1, b[2], b[3]) > 0 for b in boxes.get(stem, [])):
                hits.append((p, None, "DRAWN, NOT SOLID: a skin with no solid of it under it (it looks like something to hold)"))
    return hits


def sweep_card(aid, c):
    from shapely.geometry import Polygon
    hits = []
    for i, cd in enumerate(c.get("cards", [])):
        z = float(cd.get("z", -4.0))
        if not (-11.0 < z <= 3.0):
            continue
        a = Polygon(cd["pts"]).buffer(0).area
        if a >= CARD_AREA:
            xs, ys = [p[0] for p in cd["pts"]], [p[1] for p in cd["pts"]]
            hits.append((Piece("card", cd.get("tone", "?"), min(xs), max(xs), min(ys), max(ys), z, z, "%s card %d" % (aid, i), card=True),
                         None, "a flat card of one tone, %.0f m2, at z %.1f" % (a, z)))
    return hits


def resolve(aid, c, grips, keep_decos=False):
    """THE BUILD'S OWN FIXES (peaklib.Area.save calls this): two pieces flickering in one plane are parted, the
    smaller deco moved 1.5 cm toward the camera (front faces), up (tops) or down (undersides: it sinks 1.2 cm into
    what it stands on, rather than leaving a gap under it; the q8 undersides went unparted till 11-18), a card moved 2 cm back; a solid whose
    landed skin has no deco to wear draws its own shape again. keep_decos: list the decos' hits, move none (the
    mine's scenery is landing remade models all night: its hits go to the Director). Returns what it did."""
    did = []

    def index(p):
        return int(p.where.rsplit(" ", 1)[1])
    for p, _, why in sweep_standin(aid, c, []):
        if why.startswith("INVISIBLE"):
            s = c["solids"][index(p)]
            did.append("drew %s itself again (its skin `%s` covers it nowhere)" % (p.where, s.pop("skin", "")))
    moved = set()
    for _pass in range(2):
        P = pieces_of(aid, c, grips)
        for a, b, why in sweep_zfight(P):
            movable = [p for p in (a, b) if p.kind in ("deco", "standin") and not keep_decos]
            cards = [p for p in (a, b) if p.kind == "card"]
            if movable:
                p = min(movable, key=lambda q: (q.x1 - q.x0) * (q.y1 - q.y0))
                if p.where in moved and _pass == 0:
                    continue
                moved.add(p.where)
                d = c["decos"][index(p)]
                if why.startswith("tops"):
                    d["at"][1] = round(d["at"][1] + 0.012, 3)
                elif why.startswith("undersides"):
                    d["at"][1] = round(d["at"][1] - 0.012, 3)
                else:
                    d["at"][2] = round((d["at"][2] if len(d["at"]) > 2 else -0.8) + 0.015, 3)
                did.append("moved %s off %s (%s)" % (p.label(), (b if p is a else a).label(), why))
            elif len(cards) == 2 or (cards and not keep_decos):
                p = cards[-1]
                if p.where in moved and _pass == 0:
                    continue
                moved.add(p.where)
                cd = c["cards"][index(p)]
                cd["z"] = round(float(cd.get("z", -4.0)) - 0.02, 3)
                did.append("moved %s back 2 cm off %s" % (p.label(), (b if p is a else a).label()))
    return did


def run_data(aid, c, grips):
    P = pieces_of(aid, c, grips)
    return {"ZFIGHT": sweep_zfight(P), "DEPTH": sweep_depth(P), "SKIN": sweep_skin(aid, c),
            "STANDIN": sweep_standin(aid, c, P), "CARD": sweep_card(aid, c)}


def run(areas):
    meta = json.load(open(os.path.join(COURSE, "_meta.json"), encoding="utf-8"))
    grips = {k for k, v in meta["kinds"].items() if v.get("grip")}
    return {aid: run_data(aid, load(aid), grips) for aid in areas}


def counts(r):
    return ", ".join("%s %d" % (k, len(v)) for k, v in r.items())


def _row(h):
    a, b, why = h
    return "| %s | %s | %.1f, %.1f (z %.1f .. %.1f) | %s |" % (a.where, a.label() + ((" with %s (%s)" % (b.label(), b.where)) if b else ""),
                                                          (a.x0 + a.x1) / 2, (a.y0 + a.y1) / 2, a.z0, a.z1, why)


def write_report(res, path=REPORT, head=""):
    names = {}
    try:
        meta = json.load(open(os.path.join(COURSE, "_meta.json"), encoding="utf-8"))
        names = {k: v["name"] for k, v in meta["frame"].items()}
    except Exception:
        pass
    L = ["# The sweeps", "", "Written by `python tools/peak/sweeps.py` (the five sweeps of QUALITY_TO_9_PLAN part 4) over the course "
         "as built. A hit is a place to look; the frame decides. The tool's docstring says what each sweep means.", ""]
    if head:
        L += [head, ""]
    L += ["| Biome | " + " | ".join(next(iter(res.values())).keys()) + " |", "|---|" + "---|" * 5]
    for aid, r in res.items():
        L.append("| %s %s | " % (aid, names.get(aid, "")) + " | ".join(str(len(v)) for v in r.values()) + " |")
    L.append("")
    for aid, r in res.items():
        L += ["## %s %s" % (aid, names.get(aid, "")), ""]
        for k, hits in r.items():
            if not hits:
                continue
            L += ["### %s (%d)" % (k, len(hits)), "", "| Where | Pieces | Position | Why |", "|---|---|---|---|"]
            L += [_row(h) for h in hits]
            L.append("")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    open(path, "w", encoding="utf-8", newline="\n").write("\n".join(L) + "\n")


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if not a.startswith("-")]
    res = run(args or AREAS)
    for aid, r in res.items():
        print("%s: %s" % (aid, counts(r)))
    if not args:
        write_report(res)
        print("->", os.path.relpath(REPORT, ROOT))
