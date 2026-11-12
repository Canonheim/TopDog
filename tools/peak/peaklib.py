"""
peaklib: how the Peak of DeGayo's course is written.

An area is a Python file in tools/peak/areas/ that builds an Area and calls save().
save() checks it and writes stages/peak/course/<id>.json, which the game loads
(stages/peak/peak.gd). The rules for authors are in docs/peak/AUTHORING.md.

Coordinates: metres, y up, x NEGATIVE into the mountain. Local (0, 0) is the trailhead.
"""
import json, math, os

_HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(_HERE, "..", ".."))
COURSE_DIR = os.path.join(ROOT, "stages", "peak", "course")
PREVIEW_DIR = os.path.join(ROOT, "docs", "peak", "preview")

G = 2.79  # gravity on a climber, m/s2 (tests/peak_probe)
REACH = 1.9  # the longest plain reach between two holds, m
FLING_SPEED = {"F1": 3.4, "F2": 4.8, "F3": 6.1, "F4": 7.6, "F5": 8.9}  # release speeds, m/s

# ---------------------------------------------------------------- the frame every area fits
# id: (name, region (x0, y0, x1, y1), entry, exit)
FRAME = {
    "a0": ("La Estación", (-150, -14, 12, 10), (6, 0), (-150, -12)),
    "a1": ("La Mina Vieja", (-292, -36, -146, 90), (-150, -12), (-232, 90)),
    "a2": ("Las Aguas Negras", (-462, 86, -226, 176), (-232, 90), (-452, 176)),
    "a3": ("La Gruta de Cristal", (-462, 176, -306, 276), (-452, 178), (-306, 270)),
    "a4": ("El Jardín de Hongos", (-294, 264, -182, 376), (-294, 270), (-294, 370)),
    "a5": ("El Templo del Primer Perro", (-440, 364, -306, 484), (-306, 372), (-306, 480)),
    "a6": ("La Chimenea", (-294, 476, -214, 588), (-294, 480), (-232, 582)),
    "a7": ("Los Riscos del Viento", (-262, 570, -160, 690), (-228, 580), (-244, 688)),
    "a8": ("El Teleférico", (-285, 684, -140, 790), (-244, 688), (-272, 786)),
    "a9": ("El Glaciar", (-335, 784, -250, 888), (-274, 788), (-306, 886)),
    "a10": ("La Cresta de la Tormenta", (-360, 884, -285, 966), (-306, 888), (-336, 964)),
    "a11": ("La Cumbre", (-380, 962, -320, 1010), (-336, 966), (-350, 1000)),
    "st": ("The mountain's structure", (-720, -40, 40, 1020), (0, 0), (0, 0)),
}
POZO = (-306.0, -294.0, 176.0, 480.0)  # x west, x east, y bottom, y top (the well)

# ---------------------------------------------------------------- surface kinds
# grip: can a hand or foot stick. tone: the palette slot it's painted with.
# hold: what holding it does (None = it just holds).
KINDS = {
    # ---- grip (pale, matte, dry)
    "rock": {"grip": True, "tone": "rock"},
    "rock2": {"grip": True, "tone": "rock2"},
    "wood": {"grip": True, "tone": "wood"},
    "plank": {"grip": True, "tone": "wood2"},
    "iron": {"grip": True, "tone": "iron"},
    "stone": {"grip": True, "tone": "stone"},
    "brick": {"grip": True, "tone": "brick"},
    "crystal": {"grip": True, "tone": "crystal"},
    "root": {"grip": True, "tone": "root"},
    "shell": {"grip": True, "tone": "accent"},
    "gill": {"grip": True, "tone": "gill"},
    "cap": {"grip": True, "tone": "accent"},
    "snow": {"grip": True, "tone": "snow"},
    "bone": {"grip": True, "tone": "bone"},
    "gold": {"grip": True, "tone": "gold"},
    "paint": {"grip": True, "tone": "accent"},  # painted steel, gondolas
    # ---- slick (dark, glossy, wet): never grips
    "mud": {"grip": False, "tone": "slick"},
    "wet": {"grip": False, "tone": "slick"},
    "slime": {"grip": False, "tone": "slick"},
    "glass": {"grip": False, "tone": "slick"},
    "grease": {"grip": False, "tone": "slick"},
    "blackice": {"grip": False, "tone": "slick"},
    "scree": {"grip": False, "tone": "slick"},
    "slag": {"grip": False, "tone": "slick"},
    # ---- special holds (bright, unmistakable)
    "hot": {"grip": True, "tone": "hot", "hold": {"type": "timed", "t": 1.2, "rearm": 0.8}},
    "hotpipe": {"grip": True, "tone": "hot", "hold": {"type": "timed", "t": 1.5, "rearm": 0.8}},
    "ice": {"grip": True, "tone": "ice", "hold": {"type": "timed", "t": 2.0, "rearm": 0.6}},
    "icicle": {"grip": True, "tone": "ice", "hold": {"type": "crumble", "t": 0.7, "respawn": 9.0}},
    "rotten": {"grip": True, "tone": "weak", "hold": {"type": "crumble", "t": 1.2, "respawn": 8.0}},
    "brittle": {"grip": True, "tone": "weak", "hold": {"type": "crumble", "t": 0.8, "respawn": 8.0}},
    "snowbridge": {"grip": True, "tone": "snow", "hold": {"type": "crumble", "t": 1.0, "respawn": 10.0}},
    "metal": {"grip": True, "tone": "iron"},  # lightning takes it (see strike zones)
    "void": {"grip": False, "tone": "none"},  # an unseen wall at the world's edge (the structure only)
}

# ---------------------------------------------------------------- palettes (one per area)
# rock/rock2: grip rock. slick: the dark wet no. back/back2/back3: the card layers behind.
# sun/amb/sky: the light. Colours are sRGB hex.
_COMMON = {"wood": "#C9903F", "wood2": "#B07A32", "iron": "#B5532A", "root": "#A9825A", "bone": "#E9E2CE",
           "gold": "#E8B33A", "snow": "#F4F7FA", "ice": "#9FDDF2", "hot": "#F0541E", "weak": "#A99C86",
           "edge": "#8A6A45", "drip": "#BFD8E6", "stone": "#C8B79A", "brick": "#B8674A", "gill": "#F0E3C2",
           "crystal": "#EDE3FF"}
PALETTES = {
    "town": {"rock": "#D9C7A2", "rock2": "#C7A77A", "slick": "#241A14", "accent": "#D8262E",
             "back": "#C9B48E", "back2": "#B29A72", "back3": "#9C8460", "sky": "#8FD0FF", "sun": 1.25, "amb": "#D9D7DA", "inside": 0.0},
    "mine": {"rock": "#B98F5E", "rock2": "#A37747", "slick": "#1A120D", "accent": "#E0B040",
             "back": "#4A3423", "back2": "#33241A", "back3": "#1F1611", "sky": "#120C08", "sun": 0.28, "amb": "#6E5236", "inside": 1.0},
    "river": {"rock": "#9FB0A8", "rock2": "#86988F", "slick": "#0E161C", "accent": "#4FB7A6", "brick": "#8C7B6C",
              "back": "#2C4047", "back2": "#1E2E35", "back3": "#131F25", "sky": "#0A1216", "sun": 0.26, "amb": "#4C6E78", "inside": 1.0},
    "crystal": {"rock": "#CDB6F2", "rock2": "#B59BE6", "slick": "#170F3A", "accent": "#7FE3F0",
                "back": "#3A2A6E", "back2": "#281C52", "back3": "#190F38", "sky": "#0E0824", "sun": 0.34, "amb": "#7C68B8", "inside": 1.0},
    "fungus": {"rock": "#B7C98C", "rock2": "#9DB274", "slick": "#0F1E10", "accent": "#F28A1E",
               "back": "#2F4A2C", "back2": "#21371F", "back3": "#142414", "sky": "#0A160B", "sun": 0.32, "amb": "#5E8A52", "inside": 1.0},
    "temple": {"rock": "#D2A070", "rock2": "#BE8858", "slick": "#1C1210", "accent": "#2FA58A", "stone": "#D8BE94",
               "back": "#5A3A26", "back2": "#40291C", "back3": "#281912", "sky": "#140C08", "sun": 0.30, "amb": "#8A5E36", "inside": 1.0},
    "chimney": {"rock": "#B8A092", "rock2": "#A08878", "slick": "#170E0C", "accent": "#F2A21E",
                "back": "#5A2A1E", "back2": "#3E1C14", "back3": "#26110C", "sky": "#1C0A06", "sun": 0.36, "amb": "#9A4A2E", "inside": 1.0},
    "cliffs": {"rock": "#E6DCC6", "rock2": "#D2C4A6", "slick": "#232830", "accent": "#D8262E",
               "back": "#B9C4CE", "back2": "#9FB0C0", "back3": "#8AA0B6", "sky": "#58A8F0", "sun": 1.3, "amb": "#D5DCE6", "inside": 0.0},
    "cable": {"rock": "#E2D2B4", "rock2": "#CDB893", "slick": "#22262C", "accent": "#D8262E", "iron": "#C4502C",
              "back": "#D9C6A6", "back2": "#C3AC8C", "back3": "#A9927A", "sky": "#F2B66A", "sun": 1.2, "amb": "#E6D2B8", "inside": 0.0},
    "glacier": {"rock": "#C9D6DE", "rock2": "#AEBFCB", "slick": "#0B1826", "accent": "#3F8FD0",
                "back": "#A8C8E0", "back2": "#8DB4D2", "back3": "#789FC2", "sky": "#9CCBEF", "sun": 1.35, "amb": "#C8DCEC", "inside": 0.0},
    "storm": {"rock": "#A9AEB8", "rock2": "#8E949F", "slick": "#12151B", "accent": "#E0287A",
              "back": "#5C6470", "back2": "#474E5A", "back3": "#343A45", "sky": "#3A414E", "sun": 0.55, "amb": "#7E8794", "inside": 0.0},
    "summit": {"rock": "#EBD9A8", "rock2": "#D9C084", "slick": "#2A2420", "accent": "#F28A1E",
               "back": "#FFE2A0", "back2": "#F6C877", "back3": "#EFAE5C", "sky": "#FFCF7A", "sun": 1.4, "amb": "#F2E2C0", "inside": 0.0},
}
for _p in PALETTES.values():
    for _k, _v in _COMMON.items():
        _p.setdefault(_k, _v)


def _f(v):
    return round(float(v), 3)


def _pt(p):
    return [_f(p[0]), _f(p[1])]


def _pts(pts):
    return [_pt(p) for p in pts]


def box_pts(cx, cy, w, h, rot=0.0):
    """A box's four corners (counter-clockwise), centre (cx, cy), turned rot degrees."""
    c, s = math.cos(math.radians(rot)), math.sin(math.radians(rot))
    out = []
    for dx, dy in ((-w / 2, -h / 2), (w / 2, -h / 2), (w / 2, h / 2), (-w / 2, h / 2)):
        out.append((cx + dx * c - dy * s, cy + dx * s + dy * c))
    return out


def ngon(cx, cy, r, n=8, rot=0.0, sx=1.0, sy=1.0):
    return [(cx + math.cos(math.radians(rot) + i * math.tau / n) * r * sx,
             cy + math.sin(math.radians(rot) + i * math.tau / n) * r * sy) for i in range(n)]


def _area2(pts):
    return sum(pts[i][0] * pts[(i + 1) % len(pts)][1] - pts[(i + 1) % len(pts)][0] * pts[i][1] for i in range(len(pts)))


def ccw(pts):
    pts = list(pts)
    return pts if _area2(pts) > 0 else pts[::-1]


def fling_speed(dx, dy):
    """The slowest release that carries a body dx across and dy up (ballistic, m/s)."""
    return math.sqrt(G * (dy + math.hypot(dx, dy)))


class Area:
    def __init__(self, aid, palette):
        assert aid in FRAME, aid
        self.id = aid
        self.name, self.region, self.entry, self.exit = FRAME[aid]
        assert palette in PALETTES, palette
        self.palette = palette
        self.solids, self.movers, self.ropes, self.bodies = [], [], [], []
        self.zones, self.spawners, self.cards, self.decos = [], [], [], []
        self.lights, self.cams, self.fx, self.statues, self.challenges = [], [], [], [], []
        self.openings = []  # [x0, y0, x1, y1]: where this area's shell is open on purpose
        self._ids = set()
        self.warnings = []

    # ------------------------------------------------------------ static rock
    def solid(self, pts, kind="rock", hold=None, z=None, tag=None):
        """Any simple polygon of solid stuff."""
        assert kind in KINDS, kind
        pts = ccw(pts)
        assert len(pts) >= 3
        s = {"pts": _pts(pts), "kind": kind}
        if hold is not None:
            s["hold"] = hold
        if z is not None:
            s["z"] = [_f(z[0]), _f(z[1])]
        if tag:
            s["tag"] = tag
        self.solids.append(s)
        return s

    def box(self, cx, cy, w, h, kind="rock", rot=0.0, **kw):
        return self.solid(box_pts(cx, cy, w, h, rot), kind, **kw)

    def ledge(self, x0, x1, y, kind="rock", t=0.6, **kw):
        """A platform whose TOP is at y, from x0 to x1, t thick."""
        a, b = min(x0, x1), max(x0, x1)
        return self.solid([(a, y - t), (b, y - t), (b, y), (a, y)], kind, **kw)

    def beam(self, p0, p1, t=0.3, kind="wood", **kw):
        """A straight bar from p0 to p1, t thick (a beam, a pipe, a rung, a branch)."""
        dx, dy = p1[0] - p0[0], p1[1] - p0[1]
        L = math.hypot(dx, dy)
        return self.box((p0[0] + p1[0]) / 2, (p0[1] + p1[1]) / 2, L, t, kind, math.degrees(math.atan2(dy, dx)), **kw)

    def hold(self, x, y, r=0.22, kind="rock", n=6, **kw):
        """A small nub to grab."""
        return self.solid(ngon(x, y, r, n, rot=30), kind, **kw)

    def patch(self, p0, p1, kind="rock", t=0.3, **kw):
        """A strip of another surface lying ON a wall, from p0 to p1 along it (t thick,
        centred on the line, so it covers the wall's skin and stands t/2 proud)."""
        return self.beam(p0, p1, t, kind, **kw)

    def cave(self, pts, kinds=None, default="wet", thick=3.0):
        """A room: `pts` is the closed outline of the AIR. Every edge gets a slab of rock
        `thick` deep behind it. kinds: {edge index: kind}; edge i runs pts[i] -> pts[i+1].
        Edges not named are `default` (slick). Returns the outline, counter-clockwise."""
        kinds = kinds or {}
        flipped = _area2(pts) < 0
        n = len(pts)
        if flipped:
            # keep the author's edge numbers: edge i is still pts[i] -> pts[i+1]
            order = [(pts[(i + 1) % n], pts[i], kinds.get(i, default)) for i in range(n)]
        else:
            order = [(pts[i], pts[(i + 1) % n], kinds.get(i, default)) for i in range(n)]
        for a, b, kind in order:
            if kind is None:
                continue  # an opening: no slab
            self._slab(a, b, kind, thick)
        # Corner fillers: where two slabs turn away from each other they leave a wedge
        # behind the corner. Fill it (with the slick default, or the edges' own kind when
        # both sides agree).
        m = len(order)
        for i in range(m):
            a0, b0, k0 = order[i - 1]
            a1, b1, k1 = order[i]
            if k0 is None or k1 is None:
                continue
            n0, n1 = self._normal(a0, b0), self._normal(a1, b1)
            if n0 is None or n1 is None:
                continue
            v = a1
            tri = [v, (v[0] + n0[0] * thick, v[1] + n0[1] * thick), (v[0] + n1[0] * thick, v[1] + n1[1] * thick)]
            if abs(_area2(tri)) > 0.05 and (n0[0] * n1[1] - n0[1] * n1[0]) > 0:
                self.solid(tri, k0 if k0 == k1 else (default or "wet"))
        return ccw(pts)

    @staticmethod
    def _normal(a, b):
        dx, dy = b[0] - a[0], b[1] - a[1]
        L = math.hypot(dx, dy)
        return None if L < 1e-6 else (dy / L, -dx / L)

    def wall(self, pts, kinds=None, default="wet", thick=3.0, rock_on="left"):
        """An open run of wall (the outside faces). Rock lies on `rock_on` of the direction
        of travel pts[0] -> pts[-1]."""
        kinds = kinds or {}
        for i in range(len(pts) - 1):
            kind = kinds.get(i, default)
            if kind is None:
                continue
            a, b = pts[i], pts[i + 1]
            if rock_on == "left":
                a, b = b, a
            self._slab(a, b, kind, thick)

    def _slab(self, a, b, kind, thick):
        # air is on the LEFT of a -> b (counter-clockwise outline): rock goes to the right.
        dx, dy = b[0] - a[0], b[1] - a[1]
        L = math.hypot(dx, dy)
        if L < 1e-6:
            return
        nx, ny = dy / L, -dx / L  # right-hand normal
        ex, ey = dx / L * 0.02, dy / L * 0.02  # a hair of overlap along the run
        self.solid([(a[0] - ex, a[1] - ey), (a[0] - ex + nx * thick, a[1] - ey + ny * thick),
                    (b[0] + ex + nx * thick, b[1] + ey + ny * thick), (b[0] + ex, b[1] + ey)], kind)

    def opening(self, x0, y0, x1, y1):
        """Say where the shell is open on purpose (a door to the next area, a chute)."""
        self.openings.append([_f(min(x0, x1)), _f(min(y0, y1)), _f(max(x0, x1)), _f(max(y0, y1))])

    # ------------------------------------------------------------ moving things
    def _id(self, i):
        assert i not in self._ids, "duplicate id " + i
        self._ids.add(i)
        return i

    def mover(self, mid, at, shapes, motion, hold=None, model=None, ko=False, tag=None):
        """A body that moves by itself. shapes: [(pts relative to `at`, kind), ...].
        motion: see AUTHORING.md (path / spin / swing / cycle / sink / link / tip / crank)."""
        m = {"id": self._id(mid), "at": _pt(at), "motion": motion,
             "shapes": [{"pts": _pts(ccw(p)), "kind": k} for p, k in shapes]}
        for _, k in shapes:
            assert k in KINDS, k
        if hold is not None:
            m["hold"] = hold
        if model:
            m["model"] = model
        if ko:
            m["ko"] = True  # it knocks out a climber it hits hard
        if tag:
            m["tag"] = tag
        self.movers.append(m)
        return m

    def wheel(self, mid, at, r, rpm, spokes=6, kind="wood", rim=0.0, spoke_t=0.28, hub=0.5, phase=0.0, **kw):
        """A turning wheel of spokes (and a rim of `rim` thickness if > 0, as 12 chords)."""
        shapes = [(ngon(0, 0, hub, 8), kind)]
        for i in range(spokes):
            a = i * 360.0 / spokes
            shapes.append((box_pts(math.cos(math.radians(a)) * r / 2, math.sin(math.radians(a)) * r / 2, r, spoke_t, a), kind))
        if rim > 0:
            for i in range(12):
                a0, a1 = math.radians(i * 30), math.radians(i * 30 + 30)
                p0 = (math.cos(a0) * r, math.sin(a0) * r)
                p1 = (math.cos(a1) * r, math.sin(a1) * r)
                shapes.append((box_pts((p0[0] + p1[0]) / 2, (p0[1] + p1[1]) / 2, math.dist(p0, p1) + 0.05, rim,
                                       math.degrees(math.atan2(p1[1] - p0[1], p1[0] - p0[0]))), kind))
        return self.mover(mid, at, shapes, {"type": "spin", "rpm": _f(rpm), "phase": _f(phase)}, **kw)

    def pendulum(self, mid, pivot, length, amp, period, phase=0.0, bob=(1.2, 0.5), kind="iron", rod=0.14, rod_kind=None, **kw):
        """A swinging arm hung from `pivot`: a rod `length` long with a bob (w, h) at its end.
        amp in degrees each side of straight down, period in seconds, phase 0..1."""
        shapes = [(box_pts(0, -length / 2, rod, length), rod_kind or kind),
                  (box_pts(0, -length, bob[0], bob[1]), kind)]
        return self.mover(mid, pivot, shapes, {"type": "swing", "amp": _f(amp), "period": _f(period), "phase": _f(phase)}, **kw)

    def rope(self, rid, at, length, kind="rope", seg=0.5, bob=None, to=None, planks=0, anchor=None, slack=1.03):
        """A physics rope hung from `at`. kind: rope | chain | vine | cable | banner.
        bob: {"w":, "h":, "mass":, "kind":} a weight on its end (a chandelier, a bell).
        to: its other end, if both ends are tied (a bridge; planks > 0 lays boards on it).
        anchor: a mover's id, if its top rides a mover (a chair, a kite, a balloon)."""
        r = {"id": self._id(rid), "at": _pt(at), "len": _f(length), "kind": kind, "seg": _f(seg), "slack": _f(slack)}
        if bob:
            r["bob"] = bob
        if to is not None:
            r["to"] = _pt(to)
            r["planks"] = int(planks)
        if anchor:
            r["anchor"] = anchor
        self.ropes.append(r)
        return r

    def body(self, bid, at, shapes, mass=20.0, hinge=None, limits=None, damp=0.4, model=None, tag=None):
        """A free rigid body (it obeys physics). hinge: a world point it turns about
        (a crank, a seesaw, a dangling gondola), or None to be loose."""
        b = {"id": self._id(bid), "at": _pt(at), "mass": _f(mass), "damp": _f(damp),
             "shapes": [{"pts": _pts(ccw(p)), "kind": k} for p, k in shapes]}
        if hinge is not None:
            b["hinge"] = _pt(hinge)
        if limits is not None:
            b["limits"] = [_f(limits[0]), _f(limits[1])]
        if model:
            b["model"] = model
        if tag:
            b["tag"] = tag
        self.bodies.append(b)
        return b

    # ------------------------------------------------------------ zones
    def _rect(self, r):
        return [_f(min(r[0], r[2])), _f(min(r[1], r[3])), _f(max(r[0], r[2])), _f(max(r[1], r[3]))]

    def water(self, rect, surface, flow=(0.0, 0.0), look="river"):
        """Water in rect, its surface at y = surface, flowing at `flow` m/s."""
        self.zones.append({"type": "water", "rect": self._rect(rect), "surface": _f(surface), "flow": _pt(flow), "look": look})

    def wind(self, rect, accel, gust=None, look="wind"):
        """A push on climbers in rect: accel (ax, ay) m/s2 (gravity is 2.79: ay above that
        lifts). gust: {"on": s, "off": s, "phase": s, "warn": s} or None for steady."""
        z = {"type": "wind", "rect": self._rect(rect), "accel": _pt(accel), "look": look}
        if gust:
            z["gust"] = gust
        self.zones.append(z)

    def geyser(self, x, y, w, height, speed, period, on=1.0, phase=0.0, warn=1.0):
        """A vent at (x, y), w wide. Every `period` s it blows for `on` s: a climber in the
        column (up to `height`) is carried up at up to `speed` m/s. It gurgles `warn` s before."""
        self.zones.append({"type": "geyser", "at": _pt((x, y)), "w": _f(w), "height": _f(height), "speed": _f(speed),
                           "period": _f(period), "on": _f(on), "phase": _f(phase), "warn": _f(warn)})

    def bounce(self, p0, p1, power, look="cap", min_in=0.6, gain=0.0, ko=False):
        """A springy surface from p0 to p1 (a mushroom cap's top, a ring rope). It throws
        whatever hits it off along its normal (the LEFT of p0 -> p1) at `power` m/s, plus
        `gain` x the speed it was hit with. Not solid by itself: lay it on a solid for a cap."""
        self.zones.append({"type": "bounce", "a": _pt(p0), "b": _pt(p1), "power": _f(power), "look": look,
                           "min_in": _f(min_in), "gain": _f(gain), "ko": bool(ko)})

    def puff(self, x, y, r, power, respawn=4.0):
        """A puffball: touch it and it bursts, throwing you straight away from its centre."""
        self.zones.append({"type": "puff", "at": _pt((x, y)), "r": _f(r), "power": _f(power), "respawn": _f(respawn)})

    def strike(self, tag, period, warn=1.5, on=0.4, phase=0.0, at=None):
        """Lightning on every solid / mover tagged `tag`: every `period` s, after `warn` s of
        hum, anyone holding it is knocked out. at: where the bolt is drawn from."""
        z = {"type": "strike", "tag": tag, "period": _f(period), "warn": _f(warn), "on": _f(on), "phase": _f(phase)}
        if at is not None:
            z["at"] = _pt(at)
        self.zones.append(z)

    def dark(self, rect, level=0.85, flash=None):
        """A dark or fogged box (0 clear .. 1 black). flash: {"period": s, "on": s} lights it."""
        z = {"type": "dark", "rect": self._rect(rect), "level": _f(level)}
        if flash:
            z["flash"] = flash
        self.zones.append(z)

    def spawner(self, kind, at, period, vel=(0.0, 0.0), phase=0.0, r=0.45, life=8.0, warn=1.2, mass=30.0):
        """Things that fall or roll on a timer. kind: rock | icicle | boulder | slab.
        A hit at speed knocks a climber out."""
        self.spawners.append({"kind": kind, "at": _pt(at), "period": _f(period), "vel": _pt(vel), "phase": _f(phase),
                              "r": _f(r), "life": _f(life), "warn": _f(warn), "mass": _f(mass)})

    def finish(self, rect):
        self.zones.append({"type": "finish", "rect": self._rect(rect)})

    # ------------------------------------------------------------ looks
    def card(self, pts, z=-4.0, tone="back", edge=True):
        """A painted cardboard layer, behind (z < 0) or in front of (z > 0) the climb.
        tone: a palette slot (back, back2, back3, rock, slick, accent ...) or "#RRGGBB"."""
        self.cards.append({"pts": _pts(pts), "z": _f(z), "tone": tone, "edge": bool(edge)})

    def deco(self, model, x, y, z=-0.8, rot=0.0, scale=1.0, size=None, tone=None, flip=False):
        """A prop. `model` is a kit model's name (docs/peak/PARTS.md); until it lands the
        game draws a stand-in. size (w, h, d) and tone help the stand-in."""
        d = {"model": model, "at": [_f(x), _f(y), _f(z)], "rot": _f(rot), "scale": _f(scale)}
        if size:
            d["size"] = [_f(v) for v in size]
        if tone:
            d["tone"] = tone
        if flip:
            d["flip"] = True
        self.decos.append(d)

    def light(self, x, y, color="#FFC070", rng=9.0, energy=1.6, z=1.6, flicker=False):
        self.lights.append({"at": [_f(x), _f(y), _f(z)], "color": color, "range": _f(rng), "energy": _f(energy), "flicker": bool(flicker)})

    def cam(self, rect, half_h, bias=(0.0, 0.0)):
        """Inside rect the camera shows half_h metres above and below (default 4.2) and
        leans `bias` metres toward what matters."""
        self.cams.append({"rect": self._rect(rect), "half_h": _f(half_h), "bias": _pt(bias)})

    def effect(self, kind, rect, **params):
        """A drawn effect in rect: waterfall | mist | drips | spores | snow | steam | embers |
        dust | rain | clouds. Extra params pass through (density, speed, tone)."""
        e = {"type": kind, "rect": self._rect(rect)}
        e.update(params)
        self.fx.append(e)

    def statue(self, x, y, pose="reach", rot=0.0, flip=False, tone="bone"):
        """One of the ones who tried: a frozen climber, solid and grippable. (x, y) is its
        pelvis. pose: stand | reach | hang | sit | star | cling | fall | bridge."""
        self.statues.append({"at": _pt((x, y)), "pose": pose, "rot": _f(rot), "flip": bool(flip), "tone": tone})

    def challenge(self, cid, name, anchor, d, miss, moves=None):
        """Mark a challenge. anchor: where a climber stands to start it (feet), used by the
        warp keys. moves: the intended route, for the lint (AUTHORING.md)."""
        self.challenges.append({"id": cid, "name": name, "anchor": _pt(anchor), "d": int(d), "miss": miss, "moves": moves or []})

    # ------------------------------------------------------------ checks and save
    def check(self):
        from shapely.geometry import Polygon
        errs = []
        x0, y0, x1, y1 = self.region
        m = 6.0
        def poly_ok(pts, what):
            p = Polygon(pts)
            if not p.is_valid or p.area < 1e-4:
                errs.append("%s: bad polygon %s" % (what, pts[:3]))
        for i, s in enumerate(self.solids):
            poly_ok(s["pts"], "solid %d (%s)" % (i, s["kind"]))
            for p in s["pts"]:
                if not (x0 - m <= p[0] <= x1 + m and y0 - m <= p[1] <= y1 + m) and self.id != "st":
                    self.warnings.append("solid %d (%s) leaves the region at %s" % (i, s["kind"], p))
                    break
        for mv in self.movers:
            for sh in mv["shapes"]:
                poly_ok(sh["pts"], "mover " + mv["id"])
            assert mv["motion"]["type"] in ("path", "spin", "swing", "cycle", "sink", "link", "tip", "crank", "still"), mv["id"]
        for b in self.bodies:
            for sh in b["shapes"]:
                poly_ok(sh["pts"], "body " + b["id"])
        want = {c["id"] for c in self.challenges}
        for c in self.challenges:
            ax, ay = c["anchor"]
            if not (x0 - m <= ax <= x1 + m and y0 - m <= ay <= y1 + m):
                errs.append("challenge %s anchor outside the region" % c["id"])
            for mv in c["moves"]:
                if mv[0] == "reach":
                    dist = math.dist(mv[1], mv[2])
                    if dist > REACH:
                        errs.append("challenge %s: a reach of %.2f m (limit %.1f)" % (c["id"], dist, REACH))
                elif mv[0] == "fling":
                    v = fling_speed(abs(mv[2][0] - mv[1][0]), mv[2][1] - mv[1][1])
                    if v > FLING_SPEED[mv[3]]:
                        errs.append("challenge %s: a %s fling needing %.1f m/s (limit %.1f)" % (c["id"], mv[3], v, FLING_SPEED[mv[3]]))
        return errs

    def to_json(self):
        return {"id": self.id, "name": self.name, "palette": self.palette, "region": list(self.region),
                "entry": list(self.entry), "exit": list(self.exit), "openings": self.openings,
                "solids": self.solids, "movers": self.movers, "ropes": self.ropes, "bodies": self.bodies,
                "zones": self.zones, "spawners": self.spawners, "cards": self.cards, "decos": self.decos,
                "lights": self.lights, "cams": self.cams, "fx": self.fx, "statues": self.statues,
                "challenges": self.challenges}

    def save(self):
        errs = self.check()
        os.makedirs(COURSE_DIR, exist_ok=True)
        path = os.path.join(COURSE_DIR, self.id + ".json")
        with open(path, "w", encoding="utf-8", newline="\n") as f:
            json.dump(self.to_json(), f, separators=(",", ":"))
        print("%s: %d solids, %d movers, %d ropes, %d bodies, %d zones, %d spawners, %d cards, %d decos, %d challenges -> %s" % (
            self.id, len(self.solids), len(self.movers), len(self.ropes), len(self.bodies), len(self.zones),
            len(self.spawners), len(self.cards), len(self.decos), len(self.challenges), os.path.relpath(path, ROOT)))
        for w in self.warnings[:12]:
            print("  warning:", w)
        for e in errs:
            print("  ERROR:", e)
        return not errs


def save_meta():
    """The tables the game needs: the frame, the kinds, the palettes."""
    os.makedirs(COURSE_DIR, exist_ok=True)
    with open(os.path.join(COURSE_DIR, "_meta.json"), "w", encoding="utf-8", newline="\n") as f:
        json.dump({"frame": {k: {"name": v[0], "region": list(v[1]), "entry": list(v[2]), "exit": list(v[3])} for k, v in FRAME.items()},
                   "order": ["st", "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8", "a9", "a10", "a11"],
                   "pozo": list(POZO), "kinds": KINDS, "palettes": PALETTES, "gravity": G}, f, indent=1)
