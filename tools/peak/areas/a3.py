"""
A3 LA GRUTA DE CRISTAL: glass and light. 176 to 276 m, west of the well.
  python tools/peak/areas/a3.py

The plan (x negative = west, y up):

  One great hall. Its floor in the west is the start (grip, y 176, round the hole from
  A2). East of x -410 the hall's floor is LA RAMPA: one glass slope, 35 degrees, 60 m
  high, that pours everything that falls on it back to the start floor, at the foot of
  the first stair. Everything else in the hall hangs in the air over that floor: crystal
  ends growing out of the back wall (two cards behind each one draw its root), chains from
  the roof, turning crystal.

  The route folds once. From the hole you walk east under the stair to its foot, climb
  the hexagon stair back WEST (3.1), go up the mirror (3.2), then cross the top of the
  start hall EAST on the chandeliers (3.3), and from there on it runs east and up:
  geode (3.4), needles (3.5), the prism (3.6), the quartz pendulum (3.7), the glass
  ceiling (3.8), the ringed column (3.9), the horn and the well (3.10).

What a miss costs:
  3.1 S   the floor under the stair.
  3.2 B   off the mirror's foot, past R1, to the start floor.
  3.3 A   the start hall itself is the chasm.
  3.4 B   out of the geode's gap (or off its crown) to the start floor or a stair top.
  3.5 A   La Rampa, to the stair's foot.
  3.6 B   the glass plate under the shelves, the raft, and back to the first needle.
  3.7 A   La Rampa.
  3.8 A   La Rampa.
  3.9 B   the top of 3.8's glass plate, which slides you back to R7: 3.8 and 3.9 again.
  3.10 P  the well.

Kinds here: "glass" = a flat crystal face, slick. "crystal" = a tip, a broken end or a
frosted facet, grip. "rock" = the frosted floor, grip. "brittle" = a chiming shelf.
"""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from peaklib import Area, box_pts, ngon
import a3_dress  # the crystal cave's scenery (the modelling run's): decos only

A = Area("a3", "crystal")

VIOLET, WHITE, CYAN = "#C9B4FF", "#F2ECFF", "#9FE8F5"


# ---------------------------------------------------------------- helpers
def root(pts):
    """The pieces of this hall hang in the air: they are crystals growing out of the far
    wall toward the camera. Two cards behind each one draw the rest of it, going back."""
    # (a3_dress places every crystal's body going back; root() draws no cards now)
    return


def rest(x0, x1, top, h=1.6, slick="", square="", root_=True, skin=None):
    """A rest crystal: a broken crystal end seen from the side. Glass body, a frosted
    cap on top (grip), a bevelled lip at each end. A lip named in `slick` ("w", "e")
    stays glass: the drip on the edge that keeps a rest from being quite safe. An end
    named in `square` is cut plumb instead (a needle stands on it)."""
    bw, bh, u = 0.45, 0.55, 0.5
    yt, yb = top - 0.15, top - h
    west = [(x0, yt), (x0, yb)] if "w" in square else [(x0 + bw, yt), (x0, yt - bh), (x0 + u, yb)]
    east = [(x1, yb), (x1, yt)] if "e" in square else [(x1 - u, yb), (x1, yt - bh), (x1 - bw, yt)]
    A.solid(west + east, "glass", skin=skin)
    if root_:
        root(west + east)
    A.ledge(x0 if "w" in square else x0 + bw - 0.05, x1 if "e" in square else x1 - bw + 0.05, top, "crystal", t=0.3, skin=skin)
    if "w" not in slick and "w" not in square:
        A.patch((x0, yt - bh), (x0 + bw, yt), "crystal", t=0.3, skin=skin)
    if "e" not in slick and "e" not in square:
        A.patch((x1 - bw, yt), (x1, yt - bh), "crystal", t=0.3, skin=skin)


def hexstep(cx, top, wt=2.2, w=3.4, west_slick=False):
    """A hexagonal column seen end-on: the flat top and its two shoulders are frosted
    (grip), the lower facets are glass."""
    yt = top - 0.15
    hexa = [(cx - wt / 2, yt), (cx - w / 2, yt - 0.75), (cx - wt / 2, yt - 1.5), (cx + wt / 2, yt - 1.5),
            (cx + w / 2, yt - 0.75), (cx + wt / 2, yt)]
    A.solid(hexa, "glass")
    root(hexa)
    A.ledge(cx - wt / 2, cx + wt / 2, top, "crystal", t=0.3)
    if not west_slick:
        A.patch((cx - w / 2, yt - 0.75), (cx - wt / 2, yt), "crystal", t=0.3)
    A.patch((cx + wt / 2, yt), (cx + w / 2, yt - 0.75), "crystal", t=0.3)


def needle(x, tip, length, w=1.1, tip_h=1.3, flat_base=False, frost="", skin=None):
    """A needle spire: a glass shaft, a frosted point (grip). Floating ones are pointed
    at both ends (their roots run back into the wall). frost: "w"/"e" frosts a side of
    the shaft so it can be climbed."""
    by = tip - length
    if flat_base:
        A.solid([(x - w / 2, by), (x + w / 2, by), (x + w / 2, tip - tip_h), (x - w / 2, tip - tip_h)], "glass", skin=skin)
    else:
        A.solid([(x, by), (x + w / 2, by + tip_h), (x + w / 2, tip - tip_h), (x - w / 2, tip - tip_h),
                 (x - w / 2, by + tip_h)], "glass", skin=skin)
        root([(x, by), (x + w / 2, by + tip_h), (x + w / 2, tip - tip_h), (x, tip), (x - w / 2, tip - tip_h),
              (x - w / 2, by + tip_h)])
    A.solid([(x - w / 2, tip - tip_h), (x + w / 2, tip - tip_h), (x, tip)], "crystal", skin=skin)
    if "w" in frost:
        A.patch((x - w / 2, by + 0.1), (x - w / 2, tip - tip_h), "crystal", t=0.3, skin=skin)
    if "e" in frost:
        A.patch((x + w / 2, by + 0.1), (x + w / 2, tip - tip_h), "crystal", t=0.3, skin=skin)


def chords(r_vertex, t, kind, skip=(), n=12):
    """A ring of n chord boxes (as Area.wheel lays its rim), relative to a mover's centre."""
    out = []
    for i in range(n):
        if i in skip:
            continue
        a0, a1 = math.radians(i * 360.0 / n), math.radians((i + 1) * 360.0 / n)
        p0 = (math.cos(a0) * r_vertex, math.sin(a0) * r_vertex)
        p1 = (math.cos(a1) * r_vertex, math.sin(a1) * r_vertex)
        out.append((box_pts((p0[0] + p1[0]) / 2, (p0[1] + p1[1]) / 2, math.dist(p0, p1) + 0.05, t,
                            math.degrees(math.atan2(p1[1] - p0[1], p1[0] - p0[0]))), kind))
    return out


def polar(c, r, deg):
    return (c[0] + r * math.cos(math.radians(deg)), c[1] + r * math.sin(math.radians(deg)))


# ---------------------------------------------------------------- the hall (its air)
SLIDE_FOOT = (-410.3, 176.0)
SLIDE_K = 0.70  # 35 degrees


def slide_y(x):
    return 176.0 + SLIDE_K * (x - SLIDE_FOOT[0])


def roof_w(x):
    """The roof over the start hall: the chandeliers hang from this line."""
    return 210.2 + 0.5333 * (x + 443.8)


AIR = [
    (-459.0, 176.0),            # 0  the floor, west of the hole
    (-456.0, 176.0),            # 1  THE HOLE from A2 (open)
    (-449.0, 176.0),            # 2  the start floor
    SLIDE_FOOT,                 # 3  La Rampa: glass, 35 degrees
    (-324.3, slide_y(-324.3)),  # 4  the wall under the ceiling's landing
    (-324.3, 241.5),            # 5  the landing's floor (3.8 ends here)
    (-309.0, 241.5),            # 6  the east wall, beside the well
    (-309.0, 264.0),            # 7  THE DOOR to the well (open)
    (-309.0, 278.0),            # 8  the roof, east to west from here on
    (-332.0, 278.0),            # 9
    (-340.0, 262.0),            # 10
    (-348.0, 248.5),            # 11 over the pendulum
    (-372.0, 248.5),            # 12
    (-378.0, 240.0),            # 13
    (-388.0, 236.0),            # 14 over the needles
    (-400.0, 234.0),            # 15
    (-412.0, 229.0),            # 16
    (-424.0, roof_w(-424.0)),   # 17 the chandelier roof
    (-459.0, roof_w(-459.0)),   # 18 the west wall
]
# (a3_dress item 6f: the hall's east wall from the landing to the door, edge 6, is the shared
# well's west wall (st.py, x -310 .. -306): no slab of ours there now, and no roof slab carried
# on over the door. Every other slab wears its stretch's painted piece: SHELL_SKINS.)
_n_before = len(A.solids)
A.cave(AIR, {0: "rock", 1: None, 2: "rock", 5: "rock", 6: None, 7: None}, default="glass", thick=3.0,
       skins=a3_dress.SHELL_SKINS)
A.opening(-456, 173, -449, 179)   # the hole in the floor: A2's rungs come up it
A.opening(-309, 264, -305, 278)   # the door: the horn sticks out through it into the well
A.box(-448.7, 176.3, 0.5, 0.6, "crystal", skin="aguas_shaft_rim")  # a kerb east of the hole: what rolls along the floor stops here
# THE FROG'S ROOM (page 3.0; note 60, Parker 11-13: the place is right): a hollow cut into the
# west wall's glass, open at the wall's face 2.2 m tall, a frosted floor at 176.0. The wall
# above stays glass. Its back, lining, frog and things are the dress's.
HOLLOW = [(-459.0, 176.0), (-461.3, 176.0), (-461.75, 176.5), (-461.9, 177.3), (-461.7, 178.1), (-461.2, 178.6),
          (-460.5, 178.8), (-459.8, 178.7), (-459.3, 178.45), (-459.0, 178.2)]


def _cut_hollow():
    from shapely.geometry import Polygon, box
    hollow = Polygon(HOLLOW).buffer(0.0)
    keep = []
    for s in A.solids[_n_before:]:
        p = Polygon(s["pts"])
        if not p.intersects(hollow) or p.intersection(hollow).area < 1e-4:
            keep.append(s)
            continue
        rest_ = p.difference(hollow)
        # cut what is left into convex pieces: horizontal bands at the hollow's own heights
        ys = sorted({round(y, 3) for _, y in HOLLOW} | {round(rest_.bounds[1], 3), round(rest_.bounds[3], 3)})
        for ya, yb in zip(ys, ys[1:]):
            band = rest_.intersection(box(rest_.bounds[0] - 1, ya, rest_.bounds[2] + 1, yb))
            for g in getattr(band, "geoms", [band]):
                if g.geom_type == "Polygon" and g.area > 1e-3:
                    q = dict(s)
                    q["pts"] = [[round(x, 3), round(y, 3)] for x, y in list(g.convex_hull.exterior.coords)[:-1]]
                    keep.append(q)
    A.solids[_n_before:] = keep


_cut_hollow()
A.ledge(-461.3, -459.0, 176.0, "rock", t=0.3)  # the frog's room's frosted floor

# ---------------------------------------------------------------- 3.1 Primer Destello
# (Note 26, Parker 11-13: "truly slanted pointed shafts, with sloping tops, and the six flings
# re-laid to suit".) As the design page draws it (design/a3/3_1_primer_destello.html): five
# six-sided shafts 1.1 m thick, leaning 30 degrees, each pointing high and to the west. In the
# play space each is a top face 2 m long and a point 0.9 m long, both rough (grip); its
# under-face is glass. You walk up a top, hang from its point, swing and let go: from each
# point the low end of the next top is 2.2 m across and 1.3 m up. The sixth is snapped:
# thicker (1.4 m), nearly level (0.8 m up in 3.4 m), its west end a glassy break that can't
# be held, and that west end exactly where today's rest before the mirror ends (-439.0,
# 189.5), so El Espejo's first reach is unchanged. (Laid back from that end, the first top
# starts 0.73 m above the floor, where the page said 1 m.)
SH_U = (-math.cos(math.radians(30)), math.sin(math.radians(30)))  # up a top, west
SH_D = (-0.5, -math.sin(math.radians(60)))  # down through the shaft, square to its top


def shaft(lo, top=2.0, point=0.9, thick=1.1):
    """One slanted shaft from the low end of its top face; returns its point (the tip)."""
    tt = (lo[0] + SH_U[0] * top, lo[1] + SH_U[1] * top)
    tip = (tt[0] + SH_U[0] * point + SH_D[0] * thick / 2, tt[1] + SH_U[1] * point + SH_D[1] * thick / 2)
    ut = (tt[0] + SH_D[0] * thick, tt[1] + SH_D[1] * thick)
    ul = (lo[0] + SH_D[0] * thick, lo[1] + SH_D[1] * thick)
    body = [lo, tt, ut, ul]
    A.solid(body, "glass", skin="gruta_wall_point")
    root([lo, tt, tip, ut, ul])  # (its body going back into the far wall, in order round it)
    A.patch(lo, tt, "crystal", t=0.3, skin="gruta_wall_point")  # the sloping top
    A.solid([tt, tip, ut], "crystal", skin="gruta_wall_point")  # the point, all of it
    return tip


R1 = (-439.0, -436.0, 189.5)  # (the rest before the mirror: its west end is fixed)
S6_W = (-439.0, 189.5)
S6_RUN = math.sqrt(3.4 ** 2 - 0.8 ** 2)
S6_L = (S6_W[0] + S6_RUN, S6_W[1] - 0.8)
STEP = (-2.2, 1.3)  # from a point to the next top's low end
# one shaft's own step from its low end to its point
_tt = (SH_U[0] * 2.0, SH_U[1] * 2.0)
TIP_OFF = (_tt[0] + SH_U[0] * 0.9 + SH_D[0] * 0.55, _tt[1] + SH_U[1] * 0.9 + SH_D[1] * 0.55)
PER = (TIP_OFF[0] + STEP[0], TIP_OFF[1] + STEP[1])
LO5_TIP = (S6_L[0] + 1.5, S6_L[1] - 1.9)  # the fifth point: the sixth's low end is 1.5 m across and 1.9 m up
LO1 = (LO5_TIP[0] - TIP_OFF[0] - 4 * PER[0], LO5_TIP[1] - TIP_OFF[1] - 4 * PER[1])
TIPS = []
for k in range(5):
    TIPS.append(shaft((LO1[0] + k * PER[0], LO1[1] + k * PER[1])))
# the sixth, snapped: thick, nearly level, its west end a glassy break
s6d = (-0.8 / 3.4, -S6_RUN / 3.4)  # square to its top, downward
S6 = [S6_L, S6_W, (S6_W[0] + s6d[0] * 1.4, S6_W[1] + s6d[1] * 1.4), (S6_L[0] + s6d[0] * 1.4, S6_L[1] + s6d[1] * 1.4)]
A.solid(S6, "glass", skin="gruta_wall_point_snapped")
root(S6)
A.patch(S6_L, S6_W, "crystal", t=0.3, skin="gruta_wall_point_snapped")  # its top, to the break
m31 = [["reach", [LO1[0] + 0.85, 177.4], list(LO1)]]  # (from the floor beside the first shaft's low end)
for k in range(4):
    m31.append(["fling", list(TIPS[k]), [LO1[0] + (k + 1) * PER[0], LO1[1] + (k + 1) * PER[1]], "F2"])
m31.append(["fling", list(TIPS[4]), list(S6_L), "F2"])
A.challenge("3.1", "Primer Destello", (LO1[0] + 0.85, 176.0), 2, "S", moves=m31)
A.cam((-446, 176, -409, 193), 7.0, bias=(-2.0, 2.0))

# ---------------------------------------------------------------- 3.2 El Espejo
# A mirror slab leaning 67 degrees against the big crystal R2. Five nubs on it, and one
# loose nub between R1 and its foot. The foot hangs 2.4 m out from R1's west edge, over
# nothing: slip, and you slide down the glass, off its foot, past R1's glass shoulder
# to the start floor, 14 m down.
M_T = (-445.0, 198.7)
M_DIR = (-math.cos(math.radians(67)), math.sin(math.radians(67)))  # up the face
M_N = (math.sin(math.radians(67)), math.cos(math.radians(67)))     # out of the face (up and east)
M_LEN = 9.1
M_F = (M_T[0] - M_DIR[0] * M_LEN, M_T[1] - M_DIR[1] * M_LEN)
MIRROR = [M_F, M_T, (M_T[0] - M_N[0] * 0.8, M_T[1] - M_N[1] * 0.8), (M_F[0] - M_N[0] * 0.8, M_F[1] - M_N[1] * 0.8)]
A.solid(MIRROR, "glass", skin="gruta_mirror_slab")
root(MIRROR)
NUBS = []
for s in (0.5, 2.2, 3.95, 5.6, 7.4):
    p = (M_F[0] + M_DIR[0] * s + M_N[0] * 0.1, M_F[1] + M_DIR[1] * s + M_N[1] * 0.1)
    NUBS.append(p)
    A.hold(p[0], p[1], r=0.2, kind="crystal", skin="gruta_nub")
rest(-448.0, -445.0, 198.7, h=2.4, slick="w", skin="gruta_rest_r2")  # R2: the mirror's top. Its west lip is glass, over the hole
A.patch((M_T[0] - M_N[0] * 0.8, M_T[1] - M_N[1] * 0.8), M_T, "crystal", t=0.3, skin="gruta_mirror_slab")  # the mirror's broken top edge grips
NUB0 = (-440.5, 190.2)
A.hold(NUB0[0], NUB0[1], r=0.2, kind="crystal", skin="gruta_nub")
m32 = [["reach", [R1[0], R1[2]], list(NUB0)], ["reach", list(NUB0), list(NUBS[0])]]
for i in range(4):
    m32.append(["reach", list(NUBS[i]), list(NUBS[i + 1])])
m32.append(["reach", list(NUBS[4]), [M_T[0], M_T[1]]])
A.challenge("3.2", "El Espejo", (-438.2, 189.5), 3, "B", moves=m32)
A.cam((-447, 189, -437, 199), 8.5, bias=(1.0, -4.0))
# The one who tried: reaching up at the mirror, grown over with clear crystal.
A.statue(-443.4, 176.95, "reach")
A.deco("crystal_shell_clear", -443.4, 176.0, z=0.4, size=(2.4, 3.6, 1.6), tone="accent")

# ---------------------------------------------------------------- 3.3 Candelabros
# Three chandeliers on chains, 6 m apart, each hung 3.2 m higher than the last, over the
# start hall: the chasm under them IS the area's start, 23 to 30 m down.
CH = [(-443.8, 9.0), (-437.8, 9.0), (-431.8, 9.0)]
for i, (x, L) in enumerate(CH):
    ay = roof_w(x)
    A.solid(ngon(x, ay + 0.1, 0.45, 6, rot=30), "glass", skin="gruta_worn_socket")  # the worn socket its thread hangs from
    # (page 3.3, look only: a grown thread of lilac crystal where the chain was, the same length,
    # swinging the same way; its chandelier is the cave's own, made at 1.2 x 1.5)
    A.rope("chand%d" % (i + 1), (x, ay - 0.3), L - 0.3, kind="thread", seg=0.5,
           bob={"w": 1.4, "h": 1.2, "mass": 30.0, "kind": "crystal", "model": "gruta_chandelier", "model_scale": 1.0})
    A.light(x, ay - L - 0.6, color=WHITE, rng=9.0, energy=1.5, flicker=True)
rest(-427.5, -424.0, 208.8, h=2.0, skin="gruta_rest_r3")  # R3
A.patch((-427.5, 206.6), (-427.5, 208.1), "crystal", t=0.3, skin="gruta_rest_r3")  # a frosted face under its west lip
A.challenge("3.3", "Candelabros", (-446.2, 198.7), 4, "A", moves=[
    ["reach", [-445.0, 198.7], [-444.5, 200.0]],
    ["fling", [-441.6, 203.0], [-437.8, 205.5], "F2"],
    ["fling", [-435.6, 206.2], [-431.8, 208.7], "F2"],
    ["fling", [-429.6, 209.6], [-427.3, 208.8], "F2"]])
A.cam((-448.5, 197, -423, 219), 14.0, bias=(0.0, -9.5))

# ---------------------------------------------------------------- 3.4 La Geoda
# A hollow geode, 5 m across inside, turning at 2 rpm. Its rind is glass, its lining is
# druse (grip). One gap, 60 degrees wide. It starts facing R3; it goes round by the
# BOTTOM (where it would drop you 30 m to the start floor) and comes to the top 22 s
# later, beside the end of the broken spar that leads on: out through the gap, onto
# the spar's end, along it to R4.
GEO = (-420.4, 210.1)
geo_shapes = chords(3.05, 0.3, "glass", skip=(5, 6)) + chords(2.75, 0.3, "crystal", skip=(5, 6))
# (Note 29, page 3.4: it turns half as fast again, 2 rpm -> 3. A first guess.)
A.mover("geode", GEO, geo_shapes, {"type": "spin", "rpm": 3.0, "phase": 0.0}, model="gruta_geode")
A.box(-418.3, 214.05, 2.6, 0.7, "crystal", skin="gruta_spar")  # the spar: a broken shard, frosted all round, ending over the geode's crown
rest(-417.0, -413.5, 214.4, h=1.4, slick="w", square="e", skin="gruta_rest_r4")  # R4: the first needle stands on its east end
GAP_EDGE = polar(GEO, 2.6, 60)
A.challenge("3.4", "La Geoda", (-425.0, 208.8), 3, "B", moves=[
    ["reach", [-424.0, 208.8], list(polar(GEO, 2.6, 210))],
    ["reach", list(GAP_EDGE), [-419.6, 213.7]]])
A.cam((-427.5, 206, -416, 216), 9.0, bias=(0.0, -3.0))

# ---------------------------------------------------------------- 3.5 Agujas
# Four needle tips: 7, 9 and 11 m apart, each a little higher. Under them nothing but
# La Rampa, 30 to 40 m down, and it pours you to the foot of 3.1.
TIPS = [(-414.1, 217.0), (-407.1, 220.5), (-398.1, 223.3), (-387.1, 224.5)]
needle(TIPS[0][0], TIPS[0][1], 2.6, w=1.2, flat_base=True, frost="we", skin="gruta_needle_first")  # stands on R4
needle(TIPS[1][0], TIPS[1][1], 6.5, skin="gruta_needle")
needle(TIPS[2][0], TIPS[2][1], 6.5, skin="gruta_needle")
needle(TIPS[3][0], TIPS[3][1], 2.2, w=1.1, tip_h=1.2, flat_base=True, frost="e", skin="gruta_needle_last")  # stands on R5
rest(-387.7, -383.2, 222.3, h=1.6, square="w", skin="gruta_rest_r5")  # R5: the last needle stands on its west end
A.challenge("3.5", "Agujas", (-415.6, 214.4), 4, "A", moves=[
    ["reach", [-414.7, 215.6], list(TIPS[0])],
    ["fling", list(TIPS[0]), list(TIPS[1]), "F3"],
    ["fling", list(TIPS[1]), list(TIPS[2]), "F3"],
    ["fling", list(TIPS[2]), list(TIPS[3]), "F3"]])
A.cam((-416.5, 213, -386, 232), 14.0, bias=(0.0, -8.0))

# ---------------------------------------------------------------- 3.6 El Prisma
# Eight shelves up a 12 m diagonal, each gone 1.3 s after it's taken (Parker 11-12: "I
# think these are supposed to be breakable crystals, make that more obvious. Make them
# take .5 seconds longer to break"; it was 0.8). They are cracked crystal plates now (kind
# "crazed"), not tan blocks. They chime the scale of D as you go: the game rings them in
# this order (it used to pick one of the eight notes at random).
E5, E6 = (-383.2, 222.3), (-377.2, 231.8)
SCALE = ["D4 (do)", "E4 (re)", "F#4 (mi)", "G4 (fa)", "A4 (sol)", "B4 (la)", "C#5 (ti)", "D5 (do)"]
SHELF = []
for i in range(8):
    f = (i + 1) / 9.0
    x = E5[0] + (E6[0] - E5[0]) * f + (0.4 if i % 2 == 0 else -0.4)
    y = E5[1] + (E6[1] - E5[1]) * f
    SHELF.append((x, y))
    # shelf i + 1 chimes SCALE[i]: D4, E4, F#4, G4, A4, B4, C#5, D5
    A.solid([(x - 0.5, y - 0.26), (x + 0.5, y - 0.26), (x + 0.38, y), (x - 0.38, y)], "crazed", tag="chime%d" % (i + 1),
            skin="gruta_crazed_plate")  # (its skin goes with it when it breaks: peak.gd wears a held solid's skin)
rest(-377.2, -369.1, 231.8, h=1.6, slick="e", skin="gruta_rest_r6")  # R6: the pendulum's side. Its east lip is glass
m36 = [["reach", list(E5), list(SHELF[0])]]
for i in range(7):
    m36.append(["reach", list(SHELF[i]), list(SHELF[i + 1])])
m36.append(["reach", list(SHELF[7]), list(E6)])
A.challenge("3.6", "El Prisma", (-384.6, 222.3), 3, "B", moves=m36)
A.cam((-384.5, 221, -377, 233), 9.0, bias=(-3.0, -4.0))
# The catch (cost B): a glass plate under the shelves pours a faller into a crystal raft
# that hangs under R5. The raft sinks west under its rider, 24 m, to a berth below R4:
# from there the only way on is up R4's frosted east face to the first needle, so 3.5
# and 3.6 are both to do again. Left empty, the raft goes home.
PL_E, PL_W = (-376.2, 219.84), (-384.6, 219.84 - 0.7 * 8.4)
A.solid([PL_W, PL_E, (PL_E[0], PL_E[1] - 0.8), (PL_W[0], PL_W[1] - 0.8)], "glass", skin="gruta_prism_face")
root([PL_W, PL_E, (PL_E[0], PL_E[1] - 0.8), (PL_W[0], PL_W[1] - 0.8)])
RAFT = (-386.45, 212.0)
A.mover("balsa", RAFT, [
    (box_pts(0.0, -0.2, 4.3, 0.4), "rock"),       # its floor
    (box_pts(-2.35, 1.45, 0.4, 3.7), "crystal"),  # its back wall: stops what the plate throws at it
    (box_pts(2.05, 0.25, 0.2, 0.5), "crystal"),   # a kerb at its open end
], {"type": "sink", "to": [-24.0, -4.0], "speed": 3.5, "back": 3.0}, model="gruta_raft")
A.hold(-413.3, 212.4, r=0.22, kind="crystal", skin="gruta_nub")  # from the raft's wall to R4's face
A.patch((-413.5, 213.0), (-413.5, 214.3), "crystal", t=0.3, skin="gruta_rest_r4")

# ---------------------------------------------------------------- 3.7 Pendulo de Cuarzo
# A 13 m quartz pendulum, 38 degrees each way, 6 s a swing: 16 m from R6's lip to R7's.
# The rod is glass; only the bob holds. Under it, 17 m of air and La Rampa.
PIV = (-359.96, 242.6)
A.solid([(PIV[0] - 0.7, 249.0), (PIV[0] + 0.7, 249.0), (PIV[0] + 0.35, PIV[1] - 0.1), (PIV[0] - 0.35, PIV[1] - 0.1)], "glass",
        skin="gruta_pivot_crystal")
A.pendulum("pendulo", PIV, 13.0, 38.0, 6.0, phase=0.0, bob=(1.4, 0.6), kind="crystal", rod=0.16, rod_kind="glass",
           model="gruta_quartz_pendulum")
rest(-350.8, -340.8, 231.8, h=1.6, skin="gruta_rest_r7")  # R7
# (Note 32, page 3.7: the stump is the bonsai's trunk and crown, still crystal, still held, still
# a stop for what rolls along the ledge.)
A.solid([(-349.15, 231.8), (-348.85, 231.8), (-348.8, 232.45), (-348.55, 232.7), (-348.7, 233.0), (-349.3, 233.0),
         (-349.45, 232.6), (-349.2, 232.4)], "crystal", skin="gruta_bonsai")
A.box(-349.0, 242.9, 0.6, 12.2, "glass", skin="gruta_roof_fin")   # and a glass fin from the roof above it
A.challenge("3.7", "Péndulo de Cuarzo", (-371.0, 231.8), 3, "A", moves=[
    ["reach", [-369.6, 231.8], [-368.4, 232.5]],
    ["reach", [-351.5, 232.5], [-350.3, 231.8]]])
A.cam((-372, 226, -349.5, 246), 12.5, bias=(0.0, -6.0))

# ---------------------------------------------------------------- 3.8 Techo de Vidrio
# A great glass plate tilted 32 degrees. You cross UNDER it on six frosted patches, each
# a metre long and 2.1 m of glass from the next, rising 10 m. Under you is La Rampa.
# Its TOP is the catch for 3.9: what falls off the rings slides down it to R7.
SL_U, SL_L = (-324.3, 246.2), (-342.5, 246.2 - 0.625 * 18.2)


def under(x):
    return SL_U[1] - 1.0 + 0.625 * (x - SL_U[0])


A.solid([SL_L, SL_U, (SL_U[0], SL_U[1] - 1.0), (SL_L[0], SL_L[1] - 1.0)], "glass", skin="gruta_ceiling_slab")
root([SL_L, SL_U, (SL_U[0], SL_U[1] - 1.0), (SL_L[0], SL_L[1] - 1.0)])
A.box(-342.1, under(-342.1) - 0.3, 0.36, 0.8, "crystal", skin="gruta_tooth")  # a broken tooth under its lip: the first hold
TOOTH = (-342.1, under(-342.1) - 0.55)
A.patch((-340.9, under(-340.9)), (-339.3, under(-339.3)), "crystal", t=0.3, skin="gruta_crust_long")  # patch 1, the long one: a reach from the tooth
PATCH = [(-339.7, under(-339.7))]
for i in range(5):
    px = -337.085 + 2.64 * i
    PATCH.append((px, under(px)))
    A.patch((px - 0.425, under(px - 0.425)), (px + 0.425, under(px + 0.425)), "crystal", t=0.3, skin="gruta_crust")
A.patch((-324.3, 239.5), (-324.3, 241.45), "crystal", t=0.3, skin="gruta_landing")  # the landing's frosted face
A.ledge(-324.3, -320.3, 241.62, "crystal", t=0.3, skin="gruta_landing")             # and its frosted lip
m38 = [["reach", [-341.9, 231.8], list(TOOTH)], ["reach", list(TOOTH), [-340.9, under(-340.9)]]]
for i in range(5):
    m38.append(["fling", list(PATCH[i]), list(PATCH[i + 1]), "F2"])
m38.append(["fling", list(PATCH[5]), [-324.3, 241.62], "F2"])
A.challenge("3.8", "Techo de Vidrio", (-342.6, 231.8), 4, "A", moves=m38)
A.cam((-343.5, 231.5, -324.5, 245), 10.0, bias=(0.0, -5.0))

# ---------------------------------------------------------------- the landing, the chimney, R8
A.box(-324.0, 246.8, 0.6, 3.2, "glass", skin="gruta_shelf_r8")  # closes the slot between the plate's head and R8
A.solid([(-324.3, 248.4), (-312.5, 248.4), (-312.5, 249.25), (-324.3, 249.25)], "glass", skin="gruta_shelf_r8")  # R8's slab
A.ledge(-324.3, -312.5, 249.4, "crystal", t=0.3, skin="gruta_shelf_r8")
for hx, hy in ((-310.0, 243.2), (-311.6, 244.3), (-310.0, 245.5), (-311.6, 246.7), (-311.7, 248.2)):
    A.hold(hx, hy, r=0.22, kind="crystal", skin="gruta_nub")  # the chimney: a breath

# ---------------------------------------------------------------- 3.9 La Columna
# (Notes 74 and 34. Parker 11-13, of the side-on diagram: "Yes, build that"; and "harder": a
# spike can go in under your hand.) As the design page draws it (design/a3/3_9_la_columna.html):
# three collars hang askew round the column, behind the climb, edge-on to you (the collars
# themselves are the dress's). Each carries four pairs of spikes; a spike's tip slides out
# of the collar's low end into the play space, crosses the front of the column on a slant,
# 6 m across and 3.8 m up in 10 s, and slides back in at the high end. The next pair
# follows 12.7 s behind (a turn in 50.8 s). The two spikes of a pair, 1.3 m apart, take
# turns to shake for half a second and go in for a second and a half: when yours shakes,
# move to the other. Each collar's crossing starts 1 m above where the one below ends, and
# its pair slides out 2 s before the one below goes in for good: change there (the page
# said 1.5 s; 2 s, with the slide-out taking 0.4 s, leaves about 1.4 s to change). Collar 1
# runs up and west from beside the lower shelf (R8), 2 up and east, 3 up and west, and a
# new west horn 1.2 m over its end takes you east onto the upper shelf (R9). Every number
# is a first try. (The spikes are plain stand-ins until their models land.)
COL_X = -328.0
CROSS = [((-325.0, 250.9), (-331.0, 254.7)), ((-331.0, 255.7), (-325.0, 259.5)), ((-325.0, 260.5), (-331.0, 264.3))]
SPIKE_SPEED = math.dist(*CROSS[0]) / 10.0  # 10 s a crossing
PAIR_GAP_S, TURN_S, COLLAR_LAG_S = 12.7, 4 * 12.7, 8.0
TRAIL_S = 1.3 / SPIKE_SPEED  # the pair's second spike, 1.3 m behind the first
for c, (lo, hi) in enumerate(CROSS):
    for p in range(4):
        # Blink phases (each on the spike's own clock): the leading spike is in at 2.0-3.5 s and
        # 6.5-8.0 s of its crossing, never in its first 2 s or its last 2 s, so the hand-off at
        # each corner (this collar's leading spike near its end, the next collar's leading
        # spike just out 1 m above) has both out for about 1.4 s; the trailing spike is in
        # when the leader is out, half a cycle on in the leader's time.
        for k, (lag, blink) in enumerate(((0.0, 1.0), (TRAIL_S, round((1.0 - 2.25 - TRAIL_S) % 4.5, 3)))):
            start = c * COLLAR_LAG_S + p * PAIR_GAP_S + lag
            A.mover("pua%d_%d%s" % (c + 1, p + 1, "ab"[k]), lo, [(ngon(0, 0, 0.22, 6), "crystal")],
                    {"type": "path", "pts": [list(lo), list(hi)], "speed": round(SPIKE_SPEED, 4), "mode": "wrap",
                     "wait": round(TURN_S - 10.0, 3), "phase": round(-start, 3),
                     "emerge": {"over": 0.35, "depth": -1.2, "back": True},
                     # in for 1.5 s of every 4.5 (after 0.5 s of shaking); the pair's two
                     # spikes half a cycle apart, so one of them is always out
                     "blink": {"period": 4.5, "in": 1.5, "warn": 0.5, "phase": blink}},
                    model="gruta_collar_spike")  # (its tip the hold, running back into its collar)
# The west horn: a rough pale shaft 7.7 m long and 0.7 m thick, level, from the root of the
# great horn on R9 west over the front of the column to a point, 1.2 m over collar 3's end.
WH_Y = CROSS[2][1][1] + 1.2 + 0.35
A.beam((-324.3, WH_Y), (-331.2, WH_Y), t=0.7, kind="crystal", skin="gruta_west_horn")
A.solid([(-331.2, WH_Y - 0.35), (-332.0, WH_Y), (-331.2, WH_Y + 0.35)], "crystal", skin="gruta_west_horn")
A.challenge("3.9", "La Columna", (-322.5, 249.4), 4, "B", moves=[
    ["reach", [-324.3, 249.4], list(CROSS[0][0])],
    ["ride", list(CROSS[0][0]), list(CROSS[0][1])],
    ["reach", list(CROSS[0][1]), list(CROSS[1][0])],
    ["ride", list(CROSS[1][0]), list(CROSS[1][1])],
    ["reach", list(CROSS[1][1]), list(CROSS[2][0])],
    ["ride", list(CROSS[2][0]), list(CROSS[2][1])],
    ["reach", list(CROSS[2][1]), [CROSS[2][1][0], WH_Y - 0.35]],
    ["reach", [-326.0, WH_Y + 0.35], [-324.3, 266.0]]])
A.cam((-334.5, 247, -322, 272), 11.0, bias=(-5.5, -3.0))  # (page 3.9: 1.5 m further west, for the column moved back)

# ---------------------------------------------------------------- R9, the sill, the horn: 3.10
A.solid([(-324.3, 264.0), (-313.5, 264.0), (-313.5, 265.85), (-324.3, 265.85)], "glass", skin="gruta_shelf_r9")  # R9's slab
A.ledge(-324.3, -313.4, 266.0, "crystal", t=0.3, skin="gruta_shelf_r9")
A.solid([(-314.0, 262.0), (-309.0, 262.0), (-309.0, 264.0), (-314.0, 264.0)], "glass", skin="gruta_door_sill")   # the step down to the door
A.ledge(-313.5, -306.0, 264.25, "crystal", t=0.5, skin="gruta_door_sill")  # the door's sill: frosted, to the well's edge
# The horn: a frosted crystal 16 m long, rising 20 degrees out through the door. Its
# tip hangs 1.4 m into the well, 7 m over the sill and 95 m over the river.
HORN_TIP = (-304.6, 271.5)
HU = (math.cos(math.radians(20)), math.sin(math.radians(20)))
HN = (-HU[1], HU[0])
H0 = (HORN_TIP[0] - HU[0] * 16.0, HORN_TIP[1] - HU[1] * 16.0)
HQ = (HORN_TIP[0] - HU[0] * 1.5, HORN_TIP[1] - HU[1] * 1.5)
A.beam(H0, HQ, t=0.9, kind="crystal", skin="gruta_horn")
A.solid([(HQ[0] - HN[0] * 0.45, HQ[1] - HN[1] * 0.45), HORN_TIP, (HQ[0] + HN[0] * 0.45, HQ[1] + HN[1] * 0.45)], "crystal",
        skin="gruta_horn")
A.challenge("3.10", "El Salto del Pozo I", (-322.0, 266.0), 4, "P", moves=[
    ["fling", list(HORN_TIP), [-296.0, 270.0], "F3"]])
A.cam((-322, 264, -300, 280), 13.5, bias=(7.0, -6.0))  # the horn, the roots across the well, the dark drop

# ---------------------------------------------------------------- the picture
# Behind: the hall's far wall, then crystals bigger than houses, then facets that give
# you back your own reflection. In front: dark shards along the floor and the roof.
# (The far card, the air card, the fourteen prism cards, the column, the mirror facets and
# the dark shards are gone: a3_dress places the cave's far wall, back wall, giants, column
# (on La Rampa), mirror faces and points, all out of the play space.)


def roof_y(x):
    for i in range(8, 18):
        (xa, ya), (xb, yb) = AIR[i], AIR[i + 1]
        if xb <= x <= xa:
            return ya + (yb - ya) * (x - xa) / (xb - xa)


# Glass prisms hanging from the roof: big flat faces, slick, out of the route's reach.
# The one at x -426 is a curtain: it shuts the high line from the last chandelier straight to the spar,
# so the geode can't be flown over.
for k, (x, w, drop) in enumerate(((-453.5, 2.6, 6.0), (-426.0, 2.4, 6.2), (-393.0, 2.4, 3.2), (-368.5, 2.2, 3.0),
                                   (-353.5, 2.0, 2.6), (-318.5, 2.2, 3.0))):
    ry = roof_y(x)
    A.solid([(x - w / 2, ry + 1.2), (x + w / 2, ry + 1.2), (x + w / 2, ry - drop + w * 0.7), (x, ry - drop),
             (x - w / 2, ry - drop + w * 0.7)], "glass", skin="gruta_roof_prism_" + "abcded"[k])
# (The clusters, the far chandeliers, the stalactites and the spires are a3_dress's now.)
# Light: violet and cyan, about one every 12 m of route (the white ones are the bright
# crystals' own, placed with the dress below).
for x, y, col in ((-452.5, 180.5, VIOLET), (-436.0, 180.0, VIOLET), (-420.0, 180.5, CYAN), (-425.8, 211.5, VIOLET),
                  (-402.5, 224.0, VIOLET), (-392.5, 226.5, CYAN), (-374.0, 235.5, VIOLET), (-346.0, 236.5, VIOLET),
                  (-334.0, 243.5, CYAN), (-322.0, 253.5, VIOLET), (-320.0, 269.5, VIOLET)):
    A.light(x, y, color=col, rng=10.0, energy=1.5)
for x in (-400.0, -375.0, -350.0, -332.0):
    A.light(x, slide_y(x) + 2.5, color=CYAN, rng=11.0, energy=1.1)  # the slope is lit: you see what a miss costs
A.light(-307.0, 265.5, color=VIOLET, rng=14.0, energy=1.3)  # and the well's mouth
# Effects: glitter in the air, a drip on three rests.
A.effect("dust", (-459, 176, -309, 278), density=0.5, tone=WHITE)
A.effect("drips", (-448.2, 198.7, -447.4, 208.0), tone=CYAN)
A.effect("drips", (-369.8, 231.8, -369.0, 246.0), tone=CYAN)
A.effect("drips", (-387.8, 222.3, -387.0, 235.0), tone=CYAN)
A.effect("mist", (-309, 262, -304, 280), density=0.4)
A.cam((-459, 176, -447.5, 184), 9.0, bias=(7.0, 5.0))  # coming up out of the hole: the whole hall

# ================================================================ the dress (the modelling run's)
a3_dress.dress(A)
for x, y in a3_dress.BRIGHT_LIGHTS:  # each place lit by its bright white crystals, steady
    A.light(x, y, color=WHITE, rng=8.0, energy=1.5)
A.light(a3_dress.GARDEN_LIGHT[0], a3_dress.GARDEN_LIGHT[1], color="#8FE07A", rng=6.0, energy=1.0)  # the spore lantern through the far door

if __name__ == "__main__":
    A.save()
