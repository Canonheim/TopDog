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

A = Area("a3", "crystal")

VIOLET, WHITE, CYAN = "#C9B4FF", "#F2ECFF", "#9FE8F5"


# ---------------------------------------------------------------- helpers
def root(pts):
    """The pieces of this hall hang in the air: they are crystals growing out of the far
    wall toward the camera. Two cards behind each one draw the rest of it, going back."""
    cx = sum(p[0] for p in pts) / len(pts)
    cy = sum(p[1] for p in pts) / len(pts)
    for k, dx, dy, z, tone in ((1.22, -0.25, -0.35, -1.5, "rock2"), (1.5, -0.6, -0.9, -2.6, "back")):
        A.card([(cx + (x - cx) * k + dx, cy + (y - cy) * k + dy) for x, y in pts], z=z, tone=tone)


def rest(x0, x1, top, h=1.6, slick="", square="", root_=True):
    """A rest crystal: a broken crystal end seen from the side. Glass body, a frosted
    cap on top (grip), a bevelled lip at each end. A lip named in `slick` ("w", "e")
    stays glass: the drip on the edge that keeps a rest from being quite safe. An end
    named in `square` is cut plumb instead (a needle stands on it)."""
    bw, bh, u = 0.45, 0.55, 0.5
    yt, yb = top - 0.15, top - h
    west = [(x0, yt), (x0, yb)] if "w" in square else [(x0 + bw, yt), (x0, yt - bh), (x0 + u, yb)]
    east = [(x1, yb), (x1, yt)] if "e" in square else [(x1 - u, yb), (x1, yt - bh), (x1 - bw, yt)]
    A.solid(west + east, "glass")
    if root_:
        root(west + east)
    A.ledge(x0 if "w" in square else x0 + bw - 0.05, x1 if "e" in square else x1 - bw + 0.05, top, "crystal", t=0.3)
    if "w" not in slick and "w" not in square:
        A.patch((x0, yt - bh), (x0 + bw, yt), "crystal", t=0.3)
    if "e" not in slick and "e" not in square:
        A.patch((x1 - bw, yt), (x1, yt - bh), "crystal", t=0.3)


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


def needle(x, tip, length, w=1.1, tip_h=1.3, flat_base=False, frost=""):
    """A needle spire: a glass shaft, a frosted point (grip). Floating ones are pointed
    at both ends (their roots run back into the wall). frost: "w"/"e" frosts a side of
    the shaft so it can be climbed."""
    by = tip - length
    if flat_base:
        A.solid([(x - w / 2, by), (x + w / 2, by), (x + w / 2, tip - tip_h), (x - w / 2, tip - tip_h)], "glass")
    else:
        A.solid([(x, by), (x + w / 2, by + tip_h), (x + w / 2, tip - tip_h), (x - w / 2, tip - tip_h),
                 (x - w / 2, by + tip_h)], "glass")
        root([(x, by), (x + w / 2, by + tip_h), (x + w / 2, tip - tip_h), (x, tip), (x - w / 2, tip - tip_h),
              (x - w / 2, by + tip_h)])
    A.solid([(x - w / 2, tip - tip_h), (x + w / 2, tip - tip_h), (x, tip)], "crystal")
    if "w" in frost:
        A.patch((x - w / 2, by + 0.1), (x - w / 2, tip - tip_h), "crystal", t=0.3)
    if "e" in frost:
        A.patch((x + w / 2, by + 0.1), (x + w / 2, tip - tip_h), "crystal", t=0.3)


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
A.cave(AIR, {0: "rock", 1: None, 2: "rock", 5: "rock", 7: None}, default="glass", thick=3.0)
A.opening(-456, 173, -449, 179)   # the hole in the floor: A2's rungs come up it
A.opening(-309, 264, -305, 278)   # the door: the horn sticks out through it into the well
A.box(-307.5, 279.5, 3.0, 3.0, "glass")  # the roof slab carried on, flush with the well
A.box(-448.7, 176.3, 0.5, 0.6, "crystal")  # a kerb east of the hole: what rolls along the floor stops here

# ---------------------------------------------------------------- 3.1 Primer Destello
# Six hexagonal columns, end-on, climbing WEST from the slope's foot back over the floor
# you walked in on. Tops and shoulders grip, the under-facets are glass. The first is
# taken from the floor by its west shoulder. Each fling is 2.7 m across and 2.23 m up,
# from a top's west corner to the next top's east corner.
STEPS = [(-412.6, 178.35), (-417.5, 180.58), (-422.4, 182.81), (-427.3, 185.04), (-432.2, 187.27)]
for cx, top in STEPS:
    hexstep(cx, top)
R1 = (-439.0, -436.0, 189.5)  # the sixth column: the rest before the mirror. Its west shoulder is glass
hexstep(-437.5, 189.5, wt=3.0, w=4.2, west_slick=True)
m31 = [["reach", [-414.2, 177.5], [-413.7, 178.35]]]
tops = STEPS + [(-437.5, 189.5)]
for i in range(5):
    east_corner = tops[i + 1][0] + (1.5 if i == 4 else 1.1)
    m31.append(["fling", [tops[i][0] - 1.1, tops[i][1]], [east_corner, tops[i + 1][1]], "F2"])
A.challenge("3.1", "Primer Destello", (-415.0, 176.0), 2, "S", moves=m31)
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
A.solid(MIRROR, "glass")
root(MIRROR)
NUBS = []
for s in (0.5, 2.2, 3.95, 5.6, 7.4):
    p = (M_F[0] + M_DIR[0] * s + M_N[0] * 0.1, M_F[1] + M_DIR[1] * s + M_N[1] * 0.1)
    NUBS.append(p)
    A.hold(p[0], p[1], r=0.2, kind="crystal")
rest(-448.0, -445.0, 198.7, h=2.4, slick="w")  # R2: the mirror's top. Its west lip is glass, over the hole
A.patch((M_T[0] - M_N[0] * 0.8, M_T[1] - M_N[1] * 0.8), M_T, "crystal", t=0.3)  # the mirror's broken top edge grips
NUB0 = (-440.5, 190.2)
A.hold(NUB0[0], NUB0[1], r=0.2, kind="crystal")
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
    A.solid(ngon(x, ay + 0.1, 0.45, 6, rot=30), "glass")  # the boss its chain hangs from
    A.rope("chand%d" % (i + 1), (x, ay - 0.3), L - 0.3, kind="chain", seg=0.5,
           bob={"w": 1.4, "h": 1.2, "mass": 30.0, "kind": "crystal"})
    A.light(x, ay - L - 0.6, color=WHITE, rng=9.0, energy=1.5, flicker=True)
rest(-427.5, -424.0, 208.8, h=2.0)  # R3
A.patch((-427.5, 206.6), (-427.5, 208.1), "crystal", t=0.3)  # a frosted face under its west lip
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
A.mover("geode", GEO, geo_shapes, {"type": "spin", "rpm": 2.0, "phase": 0.0}, model="geode_wheel")
A.box(-418.3, 214.05, 2.6, 0.7, "crystal")  # the spar: a broken shard, frosted all round, ending over the geode's crown
rest(-417.0, -413.5, 214.4, h=1.4, slick="w", square="e")  # R4: the first needle stands on its east end
GAP_EDGE = polar(GEO, 2.6, 60)
A.challenge("3.4", "La Geoda", (-425.0, 208.8), 3, "B", moves=[
    ["reach", [-424.0, 208.8], list(polar(GEO, 2.6, 210))],
    ["reach", list(GAP_EDGE), [-419.6, 213.7]]])
A.cam((-427.5, 206, -416, 216), 9.0, bias=(0.0, -3.0))

# ---------------------------------------------------------------- 3.5 Agujas
# Four needle tips: 7, 9 and 11 m apart, each a little higher. Under them nothing but
# La Rampa, 30 to 40 m down, and it pours you to the foot of 3.1.
TIPS = [(-414.1, 217.0), (-407.1, 220.5), (-398.1, 223.3), (-387.1, 224.5)]
needle(TIPS[0][0], TIPS[0][1], 2.6, w=1.2, flat_base=True, frost="we")  # stands on R4
needle(TIPS[1][0], TIPS[1][1], 6.5)
needle(TIPS[2][0], TIPS[2][1], 6.5)
needle(TIPS[3][0], TIPS[3][1], 2.2, w=1.1, tip_h=1.2, flat_base=True, frost="e")  # stands on R5
rest(-387.7, -383.2, 222.3, h=1.6, square="w")  # R5: the last needle stands on its west end
A.challenge("3.5", "Agujas", (-415.6, 214.4), 4, "A", moves=[
    ["reach", [-414.7, 215.6], list(TIPS[0])],
    ["fling", list(TIPS[0]), list(TIPS[1]), "F3"],
    ["fling", list(TIPS[1]), list(TIPS[2]), "F3"],
    ["fling", list(TIPS[2]), list(TIPS[3]), "F3"]])
A.cam((-416.5, 213, -386, 232), 14.0, bias=(0.0, -8.0))

# ---------------------------------------------------------------- 3.6 El Prisma
# Eight shelves up a 12 m diagonal, each gone 0.8 s after it's taken. They chime the
# scale of D as you go: the game rings them in this order.
E5, E6 = (-383.2, 222.3), (-377.2, 231.8)
SCALE = ["D4 (do)", "E4 (re)", "F#4 (mi)", "G4 (fa)", "A4 (sol)", "B4 (la)", "C#5 (ti)", "D5 (do)"]
SHELF = []
for i in range(8):
    f = (i + 1) / 9.0
    x = E5[0] + (E6[0] - E5[0]) * f + (0.4 if i % 2 == 0 else -0.4)
    y = E5[1] + (E6[1] - E5[1]) * f
    SHELF.append((x, y))
    # shelf i + 1 chimes SCALE[i]: D4, E4, F#4, G4, A4, B4, C#5, D5
    A.solid([(x - 0.5, y - 0.26), (x + 0.5, y - 0.26), (x + 0.38, y), (x - 0.38, y)], "brittle", tag="chime%d" % (i + 1))
rest(-377.2, -369.1, 231.8, h=1.6, slick="e")  # R6: the pendulum's side. Its east lip is glass
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
A.solid([PL_W, PL_E, (PL_E[0], PL_E[1] - 0.8), (PL_W[0], PL_W[1] - 0.8)], "glass")
root([PL_W, PL_E, (PL_E[0], PL_E[1] - 0.8), (PL_W[0], PL_W[1] - 0.8)])
RAFT = (-386.45, 212.0)
A.mover("balsa", RAFT, [
    (box_pts(0.0, -0.2, 4.3, 0.4), "rock"),       # its floor
    (box_pts(-2.35, 1.45, 0.4, 3.7), "crystal"),  # its back wall: stops what the plate throws at it
    (box_pts(2.05, 0.25, 0.2, 0.5), "crystal"),   # a kerb at its open end
], {"type": "sink", "to": [-24.0, -4.0], "speed": 3.5, "back": 3.0}, model="crystal_raft")
A.hold(-413.3, 212.4, r=0.22, kind="crystal")  # from the raft's wall to R4's face
A.patch((-413.5, 213.0), (-413.5, 214.3), "crystal", t=0.3)

# ---------------------------------------------------------------- 3.7 Pendulo de Cuarzo
# A 13 m quartz pendulum, 38 degrees each way, 6 s a swing: 16 m from R6's lip to R7's.
# The rod is glass; only the bob holds. Under it, 17 m of air and La Rampa.
PIV = (-359.96, 242.6)
A.solid([(PIV[0] - 0.7, 249.0), (PIV[0] + 0.7, 249.0), (PIV[0] + 0.35, PIV[1] - 0.1), (PIV[0] - 0.35, PIV[1] - 0.1)], "glass")
A.pendulum("pendulo", PIV, 13.0, 38.0, 6.0, phase=0.0, bob=(1.4, 0.6), kind="crystal", rod=0.16, rod_kind="glass",
           model="quartz_pendulum")
rest(-350.8, -340.8, 231.8, h=1.6)  # R7
A.box(-349.0, 232.4, 0.6, 1.2, "crystal")  # a broken stump on R7: what tumbles in from the east stops here
A.box(-349.0, 242.9, 0.6, 12.2, "glass")   # and a glass fin from the roof above it
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


A.solid([SL_L, SL_U, (SL_U[0], SL_U[1] - 1.0), (SL_L[0], SL_L[1] - 1.0)], "glass")
root([SL_L, SL_U, (SL_U[0], SL_U[1] - 1.0), (SL_L[0], SL_L[1] - 1.0)])
A.box(-342.1, under(-342.1) - 0.3, 0.36, 0.8, "crystal")  # a broken tooth under its lip: the first hold
TOOTH = (-342.1, under(-342.1) - 0.55)
A.patch((-340.9, under(-340.9)), (-339.3, under(-339.3)), "crystal", t=0.3)  # patch 1, the long one: a reach from the tooth
PATCH = [(-339.7, under(-339.7))]
for i in range(5):
    px = -337.085 + 2.64 * i
    PATCH.append((px, under(px)))
    A.patch((px - 0.425, under(px - 0.425)), (px + 0.425, under(px + 0.425)), "crystal", t=0.3)
A.patch((-324.3, 239.5), (-324.3, 241.45), "crystal", t=0.3)  # the landing's frosted face
A.ledge(-324.3, -320.3, 241.62, "crystal", t=0.3)             # and its frosted lip
m38 = [["reach", [-341.9, 231.8], list(TOOTH)], ["reach", list(TOOTH), [-340.9, under(-340.9)]]]
for i in range(5):
    m38.append(["fling", list(PATCH[i]), list(PATCH[i + 1]), "F2"])
m38.append(["fling", list(PATCH[5]), [-324.3, 241.62], "F2"])
A.challenge("3.8", "Techo de Vidrio", (-342.6, 231.8), 4, "A", moves=m38)
A.cam((-343.5, 231.5, -324.5, 245), 10.0, bias=(0.0, -5.0))

# ---------------------------------------------------------------- the landing, the chimney, R8
A.box(-324.0, 246.8, 0.6, 3.2, "glass")  # closes the slot between the plate's head and R8
A.solid([(-324.3, 248.4), (-312.5, 248.4), (-312.5, 249.25), (-324.3, 249.25)], "glass")  # R8's slab
A.ledge(-324.3, -312.5, 249.4, "crystal", t=0.3)
for hx, hy in ((-310.0, 243.2), (-311.6, 244.3), (-310.0, 245.5), (-311.6, 246.7), (-311.7, 248.2)):
    A.hold(hx, hy, r=0.22, kind="crystal")  # the chimney: a breath

# ---------------------------------------------------------------- 3.9 La Columna
# The column stands behind the climbing plane (a card). It wears three rings, each 6 m
# across, glass, with crystal studs: the studs are the only holds. Ring 1 turns counter-
# clockwise, ring 2 clockwise, ring 3 counter-clockwise, and their studs mesh like gear
# teeth every 5 s: ring 1's top stud meets ring 2's bottom stud, 0.9 m apart, both going
# west; ring 2's top meets ring 3's bottom going east. Up the east side of ring 1, the
# west side of ring 2, the east side of ring 3, and off onto R9.
COL_X = -328.0


def ring(mid, cy, rpm, studs, stud0):
    shapes = chords(2.75, 0.5, "glass")
    for k in range(studs):
        a = math.radians(stud0 + k * 360.0 / studs)
        c, s = math.cos(a), math.sin(a)
        shapes.append(([(2.8 * c + 0.26 * s, 2.8 * s - 0.26 * c), (3.45 * c, 3.45 * s), (2.8 * c - 0.26 * s, 2.8 * s + 0.26 * c)], "crystal"))
    # (crystal_ring_4 has its studs at 0, 90, 180, 270; crystal_ring_4x at 45, 135, 225, 315)
    A.mover(mid, (COL_X, cy), shapes, {"type": "spin", "rpm": rpm, "phase": 0.0}, model="crystal_ring_%d%s" % (studs, "x" if studs == 4 and stud0 % 90.0 else ""))


RING_Y = (250.9, 258.7, 266.5)
ring("anillo1", RING_Y[0], 3.0, 4, 90.0)   # a stud at its top at t = 0, 5, 10 ...
ring("anillo2", RING_Y[1], -4.0, 3, 270.0)  # a stud at its bottom at t = 0, 5 ...; at its top at t = 2.5, 7.5 ...
ring("anillo3", RING_Y[2], 3.0, 4, 45.0)   # a stud at its bottom at t = 2.5, 7.5 ...
A.challenge("3.9", "La Columna", (-322.5, 249.4), 4, "B", moves=[
    ["reach", [-324.3, 249.4], [COL_X + 3.45, RING_Y[0]]],
    ["reach", [COL_X, RING_Y[0] + 3.45], [COL_X, RING_Y[1] - 3.45]],
    ["reach", [COL_X, RING_Y[1] + 3.45], [COL_X, RING_Y[2] - 3.45]],
    ["reach", [COL_X + 3.45, RING_Y[2]], [-324.3, 266.0]]])
A.cam((-333, 247, -322, 272), 11.0, bias=(-4.0, -3.0))

# ---------------------------------------------------------------- R9, the sill, the horn: 3.10
A.solid([(-324.3, 264.0), (-313.5, 264.0), (-313.5, 265.85), (-324.3, 265.85)], "glass")  # R9's slab
A.ledge(-324.3, -313.4, 266.0, "crystal", t=0.3)
A.solid([(-314.0, 262.0), (-309.0, 262.0), (-309.0, 264.0), (-314.0, 264.0)], "glass")   # the step down to the door
A.ledge(-313.5, -306.0, 264.25, "crystal", t=0.5)  # the door's sill: frosted, to the well's edge
# The horn: a frosted crystal 16 m long, rising 20 degrees out through the door. Its
# tip hangs 1.4 m into the well, 7 m over the sill and 95 m over the river.
HORN_TIP = (-304.6, 271.5)
HU = (math.cos(math.radians(20)), math.sin(math.radians(20)))
HN = (-HU[1], HU[0])
H0 = (HORN_TIP[0] - HU[0] * 16.0, HORN_TIP[1] - HU[1] * 16.0)
HQ = (HORN_TIP[0] - HU[0] * 1.5, HORN_TIP[1] - HU[1] * 1.5)
A.beam(H0, HQ, t=0.9, kind="crystal")
A.solid([(HQ[0] - HN[0] * 0.45, HQ[1] - HN[1] * 0.45), HORN_TIP, (HQ[0] + HN[0] * 0.45, HQ[1] + HN[1] * 0.45)], "crystal")
A.challenge("3.10", "El Salto del Pozo I", (-322.0, 266.0), 4, "P", moves=[
    ["fling", list(HORN_TIP), [-296.0, 270.0], "F3"]])
A.cam((-322, 264, -300, 280), 13.5, bias=(7.0, -6.0))  # the horn, the roots across the well, the dark drop

# ---------------------------------------------------------------- the picture
# Behind: the hall's far wall, then crystals bigger than houses, then facets that give
# you back your own reflection. In front: dark shards along the floor and the roof.
A.card([(-466, 168), (-300, 168), (-300, 284), (-466, 284)], z=-10.0, tone="back3", edge=False)
A.card(AIR, z=-6.0, tone="back2")


def prism_card(x, y, w, h, lean, z, tone):
    """A leaning hexagonal prism, as a card."""
    c, s = math.cos(math.radians(lean)), math.sin(math.radians(lean))
    raw = [(-w / 2, 0), (w / 2, 0), (w / 2, h - w * 0.6), (0, h), (-w / 2, h - w * 0.6)]
    A.card([(x + px * c - py * s, y + px * s + py * c) for px, py in raw], z=z, tone=tone)


for x, y, w, h, lean, z, tone in (
    (-452, 176, 7, 24, -8, -4.5, "back"), (-436, 176, 10, 30, 12, -5.0, "back"), (-421, 176, 6, 20, -18, -4.0, "back"),
    (-404, 184, 9, 34, 20, -5.0, "back"), (-388, 196, 7, 30, -10, -4.2, "back"), (-372, 204, 11, 38, 14, -5.0, "back"),
    (-354, 216, 8, 28, -16, -4.4, "back"), (-338, 226, 10, 44, 8, -5.0, "back"), (-318, 240, 7, 36, -6, -4.2, "back"),
    (-446, 176, 4, 16, 22, -3.0, "#4A3A86"), (-410, 180, 5, 22, -24, -3.0, "#4A3A86"), (-380, 200, 4, 26, 26, -3.0, "#4A3A86"),
    (-346, 220, 5, 24, -22, -3.0, "#4A3A86"), (-326, 236, 4, 30, 18, -3.0, "#4A3A86"),
):
    prism_card(x, y, w, h, lean, z, tone)
# The column of 3.9, behind its rings.
A.card([(-329.3, 240.5), (-326.7, 240.5), (-326.7, 277.5), (-328.0, 279.0), (-329.3, 277.5)], z=-1.4, tone="rock2")
A.deco("crystal_column", COL_X, 240.5, z=-1.6, size=(2.6, 38.0, 2.6), tone="rock2")
# Reflections: pale facets close behind the route that give the climber back to himself.
for x, y, rot, sc in ((-443.2, 190.0, 23.0, 1.2), (-452.5, 182.0, -12.0, 1.0), (-430.0, 192.0, 15.0, 1.1), (-420.0, 204.5, -8.0, 0.9),
                      (-401.0, 212.0, -20.0, 1.2), (-381.0, 219.0, 12.0, 1.0), (-373.0, 231.0, 10.0, 1.0), (-358.0, 226.0, -6.0, 1.3),
                      (-345.5, 234.0, -8.0, 0.9), (-318.5, 266.0, 6.0, 1.2), (-312.0, 248.0, -6.0, 1.0)):
    A.deco("mirror_facet", x, y, z=-1.9, rot=rot, scale=sc, size=(4.0, 7.0, 0.1), tone="accent")
# In front of the route: dark shards along the floor and the roof.
for x, w, h, lean in ((-458, 3, 7, 10), (-431, 2.5, 5, -14), (-399, 3, 6, 16), (-366, 3, 7, -12), (-336, 2.5, 6, 12)):
    prism_card(x, max(176.0, slide_y(x)) - 1.0, w, h, lean, 3.0, "back3")
for x, y, w, h in ((-455, 204.3, 3, 6), (-415, 226.5, 3.5, 7), (-394, 235.0, 3, 6), (-360, 248.5, 2.5, 5), (-322, 278, 3, 6)):
    A.card([(x - w / 2, y + 0.8), (x + w / 2, y + 0.8), (x + w * 0.3, y - h * 0.6), (x, y - h), (x - w * 0.3, y - h * 0.6)], z=3.5, tone="back3")


def roof_y(x):
    for i in range(8, 18):
        (xa, ya), (xb, yb) = AIR[i], AIR[i + 1]
        if xb <= x <= xa:
            return ya + (yb - ya) * (x - xa) / (xb - xa)


# Glass prisms hanging from the roof: big flat faces, slick, out of the route's reach.
# The one at x -426 is a curtain: it shuts the high line from the last chandelier straight to the spar,
# so the geode can't be flown over.
for x, w, drop in ((-453.5, 2.6, 6.0), (-426.0, 2.4, 6.2), (-393.0, 2.4, 3.2), (-368.5, 2.2, 3.0), (-353.5, 2.0, 2.6),
                   (-318.5, 2.2, 3.0)):
    ry = roof_y(x)
    A.solid([(x - w / 2, ry + 1.2), (x + w / 2, ry + 1.2), (x + w / 2, ry - drop + w * 0.7), (x, ry - drop),
             (x - w / 2, ry - drop + w * 0.7)], "glass")
# Props (names from PARTS.md where it has them).
for x, y, m, sz in ((-457.6, 176, "crystal_cluster_a", (2, 3, 2)), (-446.6, 176, "crystal_cluster_c", (1, 1.5, 1)),
                    (-427.0, 176, "crystal_cluster_b", (4, 5, 3)), (-419.0, 176, "crystal_cluster_c", (1, 1.5, 1)),
                    (-316.0, 241.5, "crystal_cluster_a", (2, 3, 2)), (-311.0, 264.25, "crystal_cluster_c", (1, 1.5, 1))):
    A.deco(m, x, y, z=-1.7, size=sz, tone="rock")
for x in (-452.0, -409.0, -364.0, -343.0, -314.0):
    A.deco("chandelier_crystal", x, roof_y(x), z=-2.4, size=(2, 2.5, 2), tone="crystal")  # far chandeliers, behind the climb
for x in (-440.0, -403.0, -383.0, -346.0, -329.5):
    A.deco("stalactite_b", x, roof_y(x), z=-1.8, size=(1.5, 6, 1.5), tone="rock2")
for x in (-405.0, -378.0, -352.0):
    A.deco("crystal_spire", x, slide_y(x) - 1.0, z=-2.2, size=(2, 10, 2), tone="rock2")  # spires behind the slope
# Light: violet and ice-white, about one every 12 m of route.
for x, y, col in ((-452.5, 180.5, VIOLET), (-436.0, 180.0, VIOLET), (-420.0, 180.5, CYAN), (-427.0, 187.5, WHITE),
                  (-442.5, 194.5, WHITE), (-425.8, 211.5, VIOLET), (-415.0, 218.5, WHITE), (-402.5, 224.0, VIOLET),
                  (-392.5, 226.5, CYAN), (-385.0, 226.0, WHITE), (-374.0, 235.5, VIOLET), (-360.0, 240.0, WHITE),
                  (-346.0, 236.5, VIOLET), (-334.0, 243.5, CYAN), (-318.0, 245.0, WHITE), (-322.0, 253.5, VIOLET),
                  (-334.0, 259.0, WHITE), (-320.0, 269.5, VIOLET), (-311.0, 268.5, WHITE)):
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

if __name__ == "__main__":
    A.save()
