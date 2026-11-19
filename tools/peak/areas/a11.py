"""
A11 LA CUMBRE v2: EL MONASTERIO DEL CIELO (note 148). The game's ending.
  python tools/peak/areas/a11.py

THE FIRST PASS (Parker 11-19, before bed: "It does not need final art, we just want stylized first pass, enough to
understand how it plays, we will do the full art pass on it later"). The design is
docs/peak/playtest/design/summit_148/SUMMIT_V2.md and its drawings (make_summit_layout_v2.py holds the geometry this
file grew from). Everything here is the course's own kinds, the fitted kit and plain stand-ins: no new kit models,
and none of the old summit's dress (a11_dress.py belongs to the v1 summit and is not called).

THE ONE RULE OUTSIDE: the mountain is one slick skin, x -330 .. -496, from the gate at 964 m to the court at 1032 m.
Every miss outside slides down the east face, off the prow and into the weather balloon's rope on the storm ridge
(a10), as the old dome did ("that was fine"). Nothing you climb outside is a shelf a slider lands on: the hanging
arches stand clear of the face, the terraces' lips stand off it with a gap behind them (their roots are drawn a layer
back), and the cleft's chute comes out of the face OVER the arches.

Bottom to top:
  11.1 La Puerta del Cielo and La Casa de Te: the gate behind a10's last ledge; the rest, INSIDE (the stove, the frog)
  11.2 La Escalera de los Monjes: the monks' stair inside, up to a door on the east face at 980
  11.3 El Claustro Colgante: three broken arches hung off a beam over the drop
  11.4 Los Molinos de Oracion: three prayer wheels that carry you up and throw you
  11.5 Las Terrazas: two lips in the gusts, to the library's door at 1012
  11.6 La Biblioteca: one tall hall inside, four galleries switching back, books and scrolls falling in waves
       down three gaps; reading niches; the hatch to the court. A fall inside stays inside.
  11.7 El Ring: the old championship ring on the high court, the summit's top
  11.8 El Ultimo Salto: from an iron ring on a broken arch, 20 m west and 2.7 m down to the bell rope
  11.9 El Campanario: up the rope to the bell, inside the belfry on its beams, out and up its little roof
  11.10 Top Dog: the belt on the spire
  After the belt: a cable slide from the tower's roof into a cave mouth on the west shoulder, down into the frogs'
  hot spring inside the mountain, lit through a crack in its roof; its slide leaves through the west face (st.py
  carries it down: FROG_SLIDE). All of that is a ride, not a fall.
"""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from peaklib import Area, box_pts, ngon

A = Area("a11", "summit")

STEP = {"type": "crumble", "t": 3.0, "respawn": 12.0}  # the step that leaves (v1's convention)
GHOST_BACK = (-1.15, -0.75)  # a drawn-only piece standing behind the climber (a root, a beam, a bracket, a chain)

# ================================================================ the mountain: one slick skin
# The east face, from the prow's lip to the court's east edge (the design's EAST).
EAST = [(-330.0, 968.6), (-338.0, 974.5), (-346.0, 981.0), (-354.0, 988.5), (-361.0, 996.5), (-367.0, 1005.0),
        (-372.0, 1013.0), (-375.5, 1022.0), (-377.0, 1031.0)]


def face_x(y):
    """The east face's x at height y."""
    for (x0, y0), (x1, y1) in zip(EAST, EAST[1:]):
        if y0 <= y <= y1:
            return x0 + (x1 - x0) * (y - y0) / (y1 - y0)
    return EAST[-1][0]


BOTTOM = 962.05  # the mass's underside, a hair over a10's mass top (962)
MASS = EAST + [
    (-408.0, 1031.0),                       # the court's west edge
    (-410.5, 1024.0), (-414.0, 1017.0),     # the cleft's east side
    (-420.0, 1014.0),                       # its bottom (the chute's mouth)
    (-427.0, 1017.5), (-434.8, 1021.2),     # its west side, up to the tower's foot (a slope: nothing rests on it)
    (-445.2, 1021.6), (-456.0, 1026.0),     # the tower's foot, the shoulder's hump
    (-468.0, 1023.0), (-478.0, 1010.0),     # the west shoulder
    (-488.0, 986.0), (-496.0, 962.0),       # the west flank
    (-498.0, 957.0), (-494.0, 957.0), (-494.0, BOTTOM),  # its last lip, down into the frogs' slide's mouth (st.py)
    (-330.0, BOTTOM)]

# What is cut out of it: the rooms, the doors, the chutes.
AIR = []


def air_box(x0, y0, x1, y1):
    AIR.append(("box", (x0, y0, x1, y1)))


def air_line(pts, half):
    AIR.append(("line", (pts, half)))


def air_poly(pts):
    AIR.append(("poly", pts))


# ================================================================ 11.1 La Puerta del Cielo / La Casa de Te
# The alcove under the prow (a10's last ledge, x -340 .. -332, top 964), and through the gate behind it, inside the
# mountain, the monks' old kitchen: the rest. (Parker 11-19: the tea house goes INSIDE, so no miss lands in it.)
FLOOR = 964.0
air_box(-340.0, 961.5, -328.0, 968.2)   # the alcove: the prow's underside at 968.2
air_box(-362.0, 963.0, -339.5, 971.0)   # the kitchen
A.ledge(-362.0, -340.0, FLOOR, "stone", t=1.0)  # its floor, one floor with a10's ledge
A.box(-357.25, FLOOR + 0.6, 1.5, 1.2, "wood")   # the tea frog's counter
A.deco("frog_sit", -357.25, FLOOR + 1.2, z=-0.3, scale=2.4, size=(0.62, 0.62, 0.65), tone="accent")  # the tea frog
A.solid(box_pts(-350.0, FLOOR + 1.2, 2.6, 2.4), "brick", ghost=True, z=(-1.2, -0.5))  # the great stove, at the back
A.solid(box_pts(-350.0, FLOOR + 0.7, 1.2, 0.7), "hot", ghost=True, z=(-0.55, -0.45))  # its fire door
A.solid(box_pts(-341.2, 967.0, 0.5, 6.0), "stone", ghost=True, z=GHOST_BACK)      # the gate's jamb (cut in the rock)
A.solid(box_pts(-338.0, 967.9, 6.0, 0.6), "stone", ghost=True, z=GHOST_BACK)      # and its lintel under the prow
A.light(-350.0, 966.0, color="#FF9A4A", rng=8.0, energy=2.2, z=0.6, flicker=True)   # the stove's glow
A.light(-357.0, 968.5, color="#FFC070", rng=6.0, energy=1.2, z=0.8, flicker=True)   # the frog's lamp
A.dark((-362.0, 963.0, -340.5, 971.0), level=0.35)
A.challenge("11.1", "La Casa de Té", (-345.0, FLOOR), 1, "X", moves=[
    ["reach", [-336.0, FLOOR], [-337.8, FLOOR]],
    ["reach", [-337.8, FLOOR], [-339.6, FLOOR]],
])
A.cam((-342.0, 962.0, -328.0, 970.0), half_h=5.5, bias=(-2.0, 1.0))   # the gate, from the balloon's side
A.cam((-362.0, 962.0, -342.0, 971.0), half_h=5.0, bias=(0.0, 0.5))    # the kitchen

# ================================================================ 11.2 La Escalera de los Monjes
# From the kitchen's west end the stair climbs east, free stone steps over the kitchen, then up its own tunnel to a
# door on the east face at 980.3. THE DOOR'S SILL IS UNDER THE ROCK: the last step stands back under the lintel, and
# the doorway's floor beyond it is the face's own slick rock, sloping out, so a body sliding down the face from the
# arches or the wheels drops past the step and slides on out (the drop probe, 11-19: a sill out on the face caught
# every slow miss from 984 to 1007 m).
S0 = (-361.0, 964.0)
SLOPE = 1.2311
STEP_W = 1.1
STAIR_TOP_X = -347.8


def stair_b(x):
    return S0[1] + SLOPE * (x - S0[0])


air_poly([(-361.6, 963.0), (S0[0], 963.0), (STAIR_TOP_X, stair_b(STAIR_TOP_X) - 1.0), (STAIR_TOP_X, stair_b(STAIR_TOP_X) + 3.0),
          (-361.6, stair_b(-361.6) + 3.0)])
air_poly([(-349.0, 980.3), (STAIR_TOP_X, 980.3), (-343.0, 978.55), (-343.0, 982.4), (-349.0, 982.4)])  # the door: its floor slopes out
STAIR = []
xa = S0[0]
while xa + STEP_W <= STAIR_TOP_X + 1e-6:
    xb = xa + STEP_W
    top = round(stair_b(xb) + 0.05, 3)
    A.solid([(xa, max(stair_b(xa) - 1.0, FLOOR)), (xb, max(stair_b(xb) - 1.0, FLOOR)), (xb, top), (xa, top)], "stone")
    STAIR.append((round(xb - 0.3, 2), top))
    xa = xb
DOOR_Y = STAIR[-1][1]
A.dark((-361.6, 971.0, -348.5, 982.0), level=0.4)
A.light(-353.0, 975.0, color="#FFC070", rng=6.0, energy=1.0, z=0.6, flicker=True)
A.challenge("11.2", "La Escalera de los Monjes", (-361.3, FLOOR), 1, "X", moves=(
    [["reach", [-361.3, FLOOR], list(STAIR[0])]] + [["reach", list(a), list(b)] for a, b in zip(STAIR, STAIR[1:])]
))
A.cam((-362.0, 964.0, -342.0, 984.0), half_h=6.5, bias=(1.0, 2.0))

# ================================================================ 11.3 El Claustro Colgante
# Three broken cloister arches, each hung on a chain from a beam slanting up off the face, 2.2 m out from it: a miss
# drops onto the face, not onto an arch, and slides on down. (4 m and more: at 2.6, and at 3.4, a limp body sliding the
# face from the wheels caught the third arch: the drop probe, 11-19.)
ARCHES = []
for y in (984.3, 987.8, 991.2):
    x = round(face_x(y) + {984.3: 4.9, 987.8: 4.0, 991.2: 4.4}[y], 2)  # (the first swung to from the sill, out of the door)
    ARCHES.append((x, y))
    A.solid(box_pts(x, y - 0.25, 1.6, 0.5), "stone")                       # the arch's broken crown
    A.solid(box_pts(x, y + 0.6, 0.09, 1.2), "iron", ghost=True, z=(-0.35, -0.25))  # its chain (on up to the beam)
A.beam((ARCHES[0][0] + 0.9, ARCHES[0][1] + 1.6), (ARCHES[2][0] - 1.2, ARCHES[2][1] + 3.6), t=0.35, kind="wood", ghost=True,
       z=GHOST_BACK)  # the cloister's roof beam
A.solid(box_pts((ARCHES[2][0] - 1.2 + face_x(ARCHES[2][1] + 3.6)) / 2, ARCHES[2][1] + 3.6,
                abs(ARCHES[2][0] - 1.2 - face_x(ARCHES[2][1] + 3.6)) + 0.4, 0.3), "iron", ghost=True, z=GHOST_BACK)  # its bracket
SILL = (-348.0, DOOR_Y)
A.challenge("11.3", "El Claustro Colgante", SILL, 3, "X", moves=[
    ["fling", list(SILL), list(ARCHES[0]), "F3"],
    ["fling", list(ARCHES[0]), list(ARCHES[1]), "F3"],
    ["fling", list(ARCHES[1]), list(ARCHES[2]), "F3"],
])
A.cam((-358.0, 978.0, -340.0, 995.0), half_h=8.0, bias=(1.5, 1.0))

# ================================================================ 11.4 Los Molinos de Oracion
# Three prayer wheels on iron brackets out from the face. Each turns (counter-clockwise: its east side rising), so a
# hand on a spoke is carried up and west and thrown on.
WHEELS = [(round(face_x(y) + 3.4, 2), y) for y in (996.8, 1001.6, 1006.4)]  # (each 1.9 m clear of the face at its rim)
for k, (cx, cy) in enumerate(WHEELS):
    A.wheel("molino_%d" % (k + 1), (cx, cy), 1.5, 9.0, spokes=4, kind="wood", rim=0.0, spoke_t=0.24, hub=0.45,
            phase=round(k * 0.31, 2))
    A.solid(box_pts((cx + face_x(cy)) / 2, cy, abs(cx - face_x(cy)) + 0.4, 0.25), "iron", ghost=True, z=GHOST_BACK)  # its bracket
    A.solid(ngon(cx, cy, 1.55, 16), "paint", ghost=True, z=(-1.2, -1.15))  # its drum, painted behind the spokes
A.challenge("11.4", "Los Molinos de Oración", ARCHES[2], 3, "X", moves=[
    ["fling", list(ARCHES[2]), [WHEELS[0][0] + 1.06, WHEELS[0][1] - 1.06], "F3"],
    ["fling", [WHEELS[0][0] - 1.06, WHEELS[0][1] + 1.06], [WHEELS[1][0] + 1.06, WHEELS[1][1] - 1.06], "F2"],
    ["fling", [WHEELS[1][0] - 1.06, WHEELS[1][1] + 1.06], [WHEELS[2][0] + 1.06, WHEELS[2][1] - 1.06], "F2"],
])
A.cam((-368.0, 994.0, -354.0, 1008.0), half_h=7.5, bias=(0.0, 1.5))

# ================================================================ 11.5 Las Terrazas
# Two terrace lips, standing off the face with a gap behind (their roots drawn a layer back, so a slider passes
# behind the lip, between it and the face), in gusts that push east, off the mountain. The second lip is the
# library's doorstep.
TER1 = (round(face_x(1009.6) + 2.4, 2), round(face_x(1009.6) + 4.2, 2), 1009.6)  # (2.4 m off the face: a slider passes behind;
# at 1.6 a limp body off the court's east edge caught it: the drop probe, 11-19)
A.ledge(TER1[0], TER1[1], TER1[2], "stone", t=0.45)
A.solid([(face_x(TER1[2]) - 0.3, TER1[2] - 0.45), (TER1[0], TER1[2] - 0.45), (TER1[0], TER1[2]), (face_x(TER1[2]) - 0.3, TER1[2])],
        "stone", ghost=True, z=(-1.2, -0.6))  # its root, a layer back
A.box(TER1[1] - 0.15, TER1[2] + 1.0, 0.22, 2.0, "wood")  # the prayer-flag post
A.rope("banderas", (TER1[1] - 0.15, TER1[2] + 2.0), 7.6, kind="banner", to=(-373.3, 1014.8))  # its flag line, to the door's lintel
DOORSTEP = (-373.6, 1012.0)
# The library's door: as the stair's, its sill stands back under the lintel and its floor beyond is the face's slick
# rock sloping out (the drop probe, 11-19: a miss off the court's east edge came to rest on a doorstep out on the face).
air_poly([(-378.6, 1011.0), (DOORSTEP[0], 1011.0), (DOORSTEP[0], 1012.0), (-366.0, 1009.3), (-366.0, 1015.0), (-378.6, 1015.0)])
A.wind((-376.0, 1005.0, -362.0, 1017.0), (2.6, 0.0), gust={"on": 1.6, "off": 3.4, "phase": 0.0, "warn": 0.8})
A.challenge("11.5", "Las Terrazas", [WHEELS[2][0], WHEELS[2][1]], 2, "X", moves=[
    ["fling", [WHEELS[2][0] - 1.06, WHEELS[2][1] + 1.06], [TER1[1] - 0.4, TER1[2]], "F2"],
    ["fling", [TER1[0] + 0.2, TER1[2]], [DOORSTEP[0] - 0.2, DOORSTEP[1]], "F3"],
])
A.cam((-376.0, 1004.0, -362.0, 1016.0), half_h=7.0, bias=(1.0, 1.0))

# ================================================================ 11.6 La Biblioteca
# One tall hall inside the mountain. Four galleries switch back up it (walk west, east, west, east); a ladder at each
# gallery's end, in the shaft by the wall, and only the next ladder there: no gallery skipped. Books and scrolls tip
# off the broken top shelves in waves and fall down three gaps through every gallery: cross a gap between waves.
# Reading niches in the walls at the galleries' ends, lamp-lit, to sit in. The hatch at the east shaft's top opens onto
# the high court. A fall inside lands on a gallery or the floor: it stays inside (Parker 11-19).
LIB = (-405.0, 1011.0, -378.5, 1031.0)
LIB_FLOOR = 1012.0
air_box(*LIB)
A.ledge(LIB[0], DOORSTEP[0], LIB_FLOOR, "stone", t=1.0)  # its floor, out through the door to the sill under the lintel
GAL_X = (-402.6, -380.9)  # the galleries' ends: the shafts are the walls' last 2.4 m
COLS = [-397.6, -391.75, -385.9]  # the three gaps the books fall down
GAP = 1.4
GALS = [1015.5, 1019.5, 1023.5, 1027.5]
for y in GALS:
    edges = [GAL_X[0]] + [e for c in COLS for e in (c - GAP / 2, c + GAP / 2)] + [GAL_X[1]]
    for a, b in zip(edges[::2], edges[1::2]):
        A.ledge(a, b, y, "wood", t=0.3)
    for c in COLS:  # (the gaps' insides lined slick, as every pit's (note 52): a hand at the lip still holds)
        A.line_pit(c - GAP / 2, c + GAP / 2, y, depth=0.3)
E_SHAFT, W_SHAFT = -379.7, -403.8


def rungs(y0, y1, step=0.75):
    out, y = [], y0 + step
    while y < y1 - 0.6:
        out.append(round(y, 2))
        y += step
    return out + [round(y1 - 0.45, 2)]


LADDERS = [(E_SHAFT, LIB_FLOOR, GALS[0]), (W_SHAFT, GALS[0], GALS[1]), (E_SHAFT, GALS[1], GALS[2]),
           (W_SHAFT, GALS[2], GALS[3]), (E_SHAFT, GALS[3], 1031.7)]
for x, y0, y1 in LADDERS:
    A.ladder(x, rungs(y0, y1), w=0.8, kind="iron")
# The court's floor (the hall's roof) has its hatch over the east shaft.
COURT = 1032.0
A.ledge(-408.0, -380.9, COURT, "stone", t=1.0)
A.ledge(-378.5, -377.0, COURT, "stone", t=1.0)
# The niches: west at the first and third galleries, east at the second and fourth.
NICHES = [(-406.4, LIB[0], GALS[0]), (LIB[2], -377.3, GALS[1]), (-406.4, LIB[0], GALS[2]), (LIB[2], -377.3, GALS[3])]
for x0, x1, y in NICHES:
    air_box(x0, y - 0.4, x1, y + 2.4)
    A.ledge(x0, x1, y, "stone", t=0.4)
    A.light((x0 + x1) / 2, y + 1.6, color="#FFC070", rng=5.0, energy=1.4, z=0.3, flicker=True)
    A.deco("cold_lantern", (x0 + x1) / 2, y, z=-0.9, size=(0.3, 0.5, 0.3), tone="gold")
# THE FALLING BOOKS: a written rhythm over the three gaps, west (A), middle (B), east (C), as the mine's cave-in.
# Wave one sweeps west to east, wave two east to west, wave three the middle twice and the ends together; a rest of
# 3 s or more after each, long enough to cross a gap.
times, loop = A.rhythm([0.7, 0.7, 3.4, 0.6, 0.6, 3.6, 0.5, 0.01, 1.2, 3.8], "ABCCBABACB")
for who, x, kind in (("A", COLS[0], "book"), ("B", COLS[1], "scroll"), ("C", COLS[2], "book")):
    A.spawner(kind, (x, 1030.4), r=0.3, life=7.0, warn=1.0, mass=3.0, times=times[who], loop=loop)
# The hall's look: the shelf cases standing against the back wall, floor to ceiling, their books in rows.
import random as _rnd
_r = _rnd.Random(148)
SPINES = ["#7A2E24", "#2F4A6B", "#3E5E3A", "#8A5A22", "#5B3A5E", "#9C7A3C", "#C9B48E"]
for x in range(-404, -380, 3):
    A.card([(x + 0.2, LIB_FLOOR), (x + 2.8, LIB_FLOOR), (x + 2.8, 1030.8), (x + 0.2, 1030.8)], z=-1.7, tone="#4A2E1C")
    y = LIB_FLOOR + 0.3
    while y < 1030.0:
        xs = x + 0.35
        while xs < x + 2.6:
            w = _r.uniform(0.8, 1.3)
            xe = min(xs + w, x + 2.65)
            h = _r.uniform(0.7, 1.05)
            A.card([(xs, y), (xe, y), (xe, y + h), (xs, y + h)], z=-1.6, tone=_r.choice(SPINES), edge=False)
            xs = xe + 0.04
        y += 1.25
for x in COLS:  # the broken shelves the falls tip off, under the ceiling
    A.solid(box_pts(x, 1030.75, GAP + 1.6, 0.18), "wood", ghost=True, z=GHOST_BACK)
A.dark((LIB[0], LIB[1], LIB[2], LIB[3]), level=0.3)
for x, y in ((-399.0, 1017.5), (-386.0, 1021.5), (-399.0, 1025.5), (-386.0, 1029.5), (-392.0, 1013.6)):
    A.light(x, y, color="#FFD08A", rng=9.0, energy=1.2, z=0.8)
LIB_MOVES = [["reach", [DOORSTEP[0] - 1.8 * k, LIB_FLOOR], [DOORSTEP[0] - 1.8 * (k + 1), LIB_FLOOR]] for k in range(3)]     + [["reach", [DOORSTEP[0] - 5.4, LIB_FLOOR], [E_SHAFT, LIB_FLOOR]]]
for li, (x, y0, y1) in enumerate(LADDERS):
    rs = rungs(y0, y1)
    LIB_MOVES.append(["reach", [x, y0], [x, rs[0]]])
    LIB_MOVES += [["reach", [x, a], [x, b]] for a, b in zip(rs, rs[1:])]
    if li < len(GALS):
        y = GALS[li]
        LIB_MOVES.append(["reach", [x, rs[-1]], [x + (-1.3 if x == E_SHAFT else 1.3), y]])
        # across the gallery and its three gaps, to the next shaft
        walk = [x + (-1.3 if x == E_SHAFT else 1.3)]
        for c in (COLS[::-1] if x == E_SHAFT else COLS):
            side = 1 if x == E_SHAFT else -1
            walk += [c + side * (GAP / 2 + 0.2), c - side * (GAP / 2 + 0.2)]
        walk.append(W_SHAFT + 1.3 if x == E_SHAFT else E_SHAFT - 1.3)
        for a, b in zip(walk, walk[1:]):
            pa, pb = [a, y], [b, y]
            while abs(pb[0] - pa[0]) > 1.85:  # (a long walk, written as strides)
                mid = [pa[0] + math.copysign(1.8, pb[0] - pa[0]), y]
                LIB_MOVES.append(["reach", pa, mid])
                pa = mid
            LIB_MOVES.append(["reach", pa, pb])
        nxt = LADDERS[li + 1][0]
        LIB_MOVES.append(["reach", [walk[-1], y], [nxt, y]])
LIB_MOVES.append(["reach", [E_SHAFT, rungs(*LADDERS[-1][1:])[-1]], [-380.6, COURT]])
A.challenge("11.6", "La Biblioteca", (-375.0, LIB_FLOOR), 4, "X", moves=LIB_MOVES)
A.cam((LIB[0] - 1.6, LIB[1], LIB[2], LIB[3]), half_h=7.5, bias=(0.0, 1.0))
A.cam((-379.0, 1010.0, -368.0, 1016.0), half_h=6.0, bias=(-3.0, 1.0))  # the door

# ================================================================ 11.7 El Ring
# The old championship ring on the high court: a red apron, its canvas, a corner post at each end you climb over (as
# a luchador climbs the turnbuckle), and on each post's inner face the ropes that throw you back across.
APRON = (-399.0, -389.0)
CANVAS = 1033.6
A.solid(box_pts(-394.0, (COURT + CANVAS - 0.25) / 2, 10.0, CANVAS - 0.25 - COURT), "paint")  # the apron (red)
A.ledge(APRON[0], APRON[1], CANVAS, "gill", t=0.25)  # the canvas
A.ledge(-389.0, -387.6, COURT + 0.8, "stone", t=0.8)  # the ring steps
POST_T = 1036.0
WPOST, EPOST = (-399.0, -398.4), (-389.6, -389.0)
A.solid([(WPOST[0], CANVAS), (WPOST[1], CANVAS), (WPOST[1], POST_T), (WPOST[0], POST_T)], "wood")
A.solid([(EPOST[0], CANVAS), (EPOST[1], CANVAS), (EPOST[1], POST_T), (EPOST[0], POST_T)], "wood")
for y in (1034.3, 1034.95, 1035.6):  # the ring's ropes, post to post, a layer back
    A.solid(box_pts(-394.0, y, 9.4, 0.07), "paint", ghost=True, z=(-0.95, -0.85))
# the ropes that throw: on each post's inner face, leaning 28 degrees, so a body flung into one goes back up and over
A.bounce((WPOST[1], POST_T - 0.2), (WPOST[1] + 1.0, CANVAS + 0.3), power=1.6, gain=0.7, look="rope", model="ring_rope_red", model_scale=0.5)
A.bounce((EPOST[0] - 1.0, CANVAS + 0.3), (EPOST[0], POST_T - 0.2), power=1.6, gain=0.7, look="rope", model="ring_rope_red", model_scale=0.5)
for x in (-406.0, -402.6, -386.0, -383.4):  # the stone seats round it, a layer back
    A.solid(box_pts(x, COURT + 0.5, 2.0, 1.0), "stone", ghost=True, z=(-1.2, -0.9))
A.challenge("11.7", "El Ring", (-380.0, COURT), 2, "X", moves=[
    ["reach", [-380.6, COURT], [-382.4, COURT]], ["reach", [-382.4, COURT], [-384.2, COURT]],
    ["reach", [-384.2, COURT], [-386.0, COURT]], ["reach", [-386.0, COURT], [-387.6, COURT + 0.8]],
    ["reach", [-387.6, COURT + 0.8], [-388.5, CANVAS + 0.2]], ["reach", [-388.5, CANVAS + 0.2], [-389.0, CANVAS + 1.4]],
    ["reach", [-389.0, CANVAS + 1.4], [-389.3, POST_T]],
    ["reach", [-389.3, POST_T], [-389.9, CANVAS + 0.8]], ["reach", [-389.9, CANVAS + 0.8], [-390.4, CANVAS]],
    ["reach", [-390.4, CANVAS], [-392.0, CANVAS]],
    ["reach", [-392.0, CANVAS], [-393.8, CANVAS]], ["reach", [-393.8, CANVAS], [-395.6, CANVAS]],
    ["reach", [-395.6, CANVAS], [-397.4, CANVAS]], ["reach", [-397.4, CANVAS], [-398.3, CANVAS + 1.2]],
    ["reach", [-398.3, CANVAS + 1.2], [-398.7, POST_T]],
])
A.light(-394.0, 1038.0, color="#FFE9A8", rng=14.0, energy=1.4)
A.cam((-410.0, 1031.0, -376.0, 1040.0), half_h=7.5, bias=(-1.0, 2.0))

# ================================================================ 11.8 El Ultimo Salto
# Off the west post (or along the broken arch out of the court's west edge) to the iron ring on the arch's broken end,
# then the leap: 20 m west, 2.7 m down, over the cleft to the bell rope. A miss falls into the cleft; its chute runs
# down through the mountain under the library and throws you out of the east face over the arches, on to the prow.
A.solid(box_pts(-408.3, COURT + 1.3, 0.6, 2.6), "stone")  # the arch's last pier, on the court's west edge
A.ledge(-411.9, -408.0, COURT + 3.0, "stone", t=0.4)    # its broken span, out over the cleft
L4 = (-412.15, COURT + 2.8)  # (hung off the span's broken end, in clear air)
A.hold(L4[0], L4[1], r=0.22, kind="iron")
air_line([(-421.0, 1017.0), (-420.0, 1014.0), (-414.0, 1008.0), (-400.0, 1004.6), (-385.0, 999.4), (-372.0, 994.6),
          (-364.0, 993.4), (-350.0, 993.4)], 1.2)  # the cleft's chute: out of the face level at 993.4, over the arches
# (the cold draught drawn up through the mountain blows the other way: down the chute it carries a faller out flat at
# about 7 m/s, clear over the arches and the prow, to the balloon. The drop probe, 11-19: without it a faller came
# out at 4 m/s and caught the third arch.)
A.wind((-392.0, 996.5, -366.0, 1004.6), (1.8, 0.4), look="wind")  # (inside the mountain: none on the wheels outside)
A.wind((-366.0, 992.0, -356.6, 995.0), (1.8, 0.4), look="wind")   # its level end, under the first wheel
ROPE_X = -431.6
A.challenge("11.8", "El Último Salto", (-408.3, COURT), 5, "X", moves=[
    ["reach", [-408.0, COURT], [-408.3, COURT + 1.6]], ["reach", [-408.3, COURT + 1.6], [-408.3, COURT + 3.0]],
    ["reach", [-408.3, COURT + 3.0], [-410.0, COURT + 3.0]], ["reach", [-410.0, COURT + 3.0], [-411.5, COURT + 3.0]],
    ["reach", [-411.5, COURT + 3.0], list(L4)],
    ["fling", [-398.7, POST_T], list(L4), "F3"],  # (or off the post's top: 12.9 m across)
    ["fling", list(L4), [ROPE_X, COURT + 0.7], "F4"],  # 20 m across, 2.7 m down
])
A.cam((-436.0, 1018.0, -408.0, 1044.0), half_h=12.0, bias=(-6.0, 0.0))

# ================================================================ 11.9 El Campanario / 11.10 Top Dog
# The bell tower on the west spur. Its lower walls are wet stone (a miss off the leap that meets the east wall slides
# down it into the cleft, it doesn't climb it). The bell hangs off a beam out of the belfry's door; its rope hangs 16 m.
# Up the rope to the bell, its hanger, the beam, in at the door; up the belfry's beams (west, east, west); out over
# the east wall's top, up the iron rungs outside to the roof, up the roof to the spire. The belt hangs on the spire.
TW, TE = (-445.0, -444.0), (-436.0, -435.0)
A.solid([(TW[0], 1020.6), (TE[1], 1020.6), (TE[1], 1051.0), (TW[0], 1051.0)], "wet")  # the tower's base, under the belfry
A.solid([(TW[0], 1052.0), (TW[1], 1052.0), (TW[1], 1063.5), (TW[0], 1063.5)], "stone")  # the belfry's walls
A.solid([(TE[0], 1054.5), (TE[1], 1054.5), (TE[1], 1061.5), (TE[0], 1061.5)], "stone")
A.ledge(TW[0], TE[1], 1052.0, "wood", t=1.0)  # the belfry's floor
A.ledge(TE[1], -430.6, 1051.7, "wood", t=0.4)  # the beam out to the bell
BELL_PIN = (ROPE_X, 1051.1)
A.box(ROPE_X, 1051.1, 0.5, 0.4, "iron")  # the bell's hanger, under the beam
A.mover("campana", BELL_PIN, [([(-0.55, -0.35), (0.55, -0.35), (1.1, -2.95), (-1.1, -2.95)], "iron")],
        {"type": "still"}, model="cumbre_bell")  # (the old summit bell; the game swings it with its rope)
MOUTH = round(BELL_PIN[1] - 2.95, 2)
bell_rope = A.rope("bell_rope", (ROPE_X, MOUTH), 15.6, kind="rope", seg=0.5,
                   bob={"w": 0.5, "h": 0.3, "mass": 3.0, "kind": "wood", "model": "cumbre_toll_handle"})
bell_rope["bell"] = "cumbre_bell"
bell_rope["bell_mover"] = "campana"
BEAMS = [(-441.0, -436.0, 1053.8), (-444.0, -439.0, 1055.6), (-441.0, -436.0, 1057.4), (-444.0, -439.0, 1059.2),
         (-441.0, -436.0, 1061.0)]
for x0, x1, y in BEAMS:
    A.ledge(x0, x1, y, "wood", t=0.3)
RUNGS_OUT = [1062.0, 1062.75, 1063.5, 1064.25, 1065.0, 1065.75, 1066.4]
A.ladder(-434.4, RUNGS_OUT, w=0.6, kind="iron")
ROOF = [(-446.0, 1065.4), (-440.45, 1068.2), (-434.9, 1065.4)]
A.solid(ROOF, "rock")  # the little roof
SPIRE = (-440.45, 1069.2)
A.solid([(SPIRE[0] - 0.25, 1068.0), (SPIRE[0] + 0.25, 1068.0), (SPIRE[0] + 0.25, SPIRE[1]), (SPIRE[0] - 0.25, SPIRE[1])], "wood")
A.statue(-442.5, 1052.6, pose="sit")  # the last of the ones who tried, in the belfry
A.challenge("11.9", "El Campanario", [ROPE_X, 1033.5], 3, "X", moves=(
    [["reach", [ROPE_X, 1033.5 + 1.8 * k], [ROPE_X, 1033.5 + 1.8 * (k + 1)]] for k in range(7)]
    + [["reach", [ROPE_X, 1046.1], [ROPE_X, MOUTH - 0.3]], ["reach", [ROPE_X, MOUTH - 0.3], [ROPE_X - 0.9, MOUTH + 1.3]],
       ["reach", [ROPE_X - 0.9, MOUTH + 1.3], [-432.4, BELL_PIN[1] - 0.4]], ["reach", [-432.4, BELL_PIN[1] - 0.4], [-432.0, 1051.7]],
       ["reach", [-432.0, 1051.7], [-433.8, 1051.7]], ["reach", [-433.8, 1051.7], [-435.4, 1052.0]],
       ["reach", [-435.4, 1052.0], [-436.5, 1052.0]], ["reach", [-436.5, 1052.0], [-436.5, 1053.8]]]
    + [["reach", [-439.6 if i % 2 == 0 else -439.4, BEAMS[i][2]], [-439.6 if i % 2 == 0 else -439.4, BEAMS[i + 1][2]]] for i in range(4)]
    + [["reach", [-436.4, 1061.0], [-435.5, 1061.5]], ["reach", [-435.5, 1061.5], [-434.4, RUNGS_OUT[0]]]]
    + [["reach", [-434.4, a], [-434.4, b]] for a, b in zip(RUNGS_OUT, RUNGS_OUT[1:])]
    + [["reach", [-434.4, RUNGS_OUT[-1]], [-435.6, 1065.75]], ["reach", [-435.6, 1065.75], [-437.2, 1066.55]],
       ["reach", [-437.2, 1066.55], [-438.8, 1067.35]], ["reach", [-438.8, 1067.35], [-440.0, 1068.0]]]))
A.challenge("11.10", "Top Dog", [-440.0, 1068.0], 1, "", moves=[["reach", [-440.0, 1068.0], list(SPIRE)]])
A.finish((SPIRE[0] - 0.75, SPIRE[1] - 0.25, SPIRE[0] + 0.75, SPIRE[1] + 1.25))
A.deco("champion_belt", SPIRE[0], SPIRE[1] + 0.3, z=0.0, size=(1.2, 0.6, 0.2), tone="gold")
A.light(ROPE_X, 1049.0, color="#FFE9A8", rng=12.0, energy=1.6)
A.light(-440.0, 1066.0, color="#FFD98A", rng=12.0, energy=1.4)
A.light(-440.0, 1056.0, color="#FFC070", rng=8.0, energy=1.0, z=0.6)
A.cam((-438.0, 1030.0, -426.0, 1051.5), half_h=8.0, bias=(0.0, 2.0))   # the rope and the bell
A.cam((-447.0, 1050.0, -429.0, 1072.0), half_h=8.0, bias=(0.0, 1.5))   # the belfry, the roof, the belt

# ================================================================ after the belt: the cable down to the frogs' hot spring
# A trolley on a cable from the roof's west eave down to a cave mouth on the shoulder's hump: take its handle and it
# runs (and comes home 8 s after). At the bottom, let go: down the mouth into the frogs' pool, a warm grotto INSIDE
# the mountain, lit through a crack in its roof. Out of its west end the frogs' slide leaves through the west face
# (st.py's FROG_SLIDE carries it on down). The whole of it is a ride.
CABLE_TOP, CABLE_FOOT = (-446.8, 1065.2), (-457.0, 1028.4)
A.mover("cable_trolley", CABLE_TOP, [(box_pts(0.0, -0.7, 0.9, 0.12), "iron"), (box_pts(0.0, -0.35, 0.1, 0.6), "iron")],
        {"type": "path", "pts": [list(CABLE_TOP), list(CABLE_FOOT)], "speed": 6.0, "mode": "once", "trigger": "grab",
         "reset": 8.0})
_dx, _dy = CABLE_FOOT[0] - CABLE_TOP[0], CABLE_FOOT[1] - CABLE_TOP[1]
A.beam((CABLE_TOP[0] + 0.0, CABLE_TOP[1] + 0.05), (CABLE_FOOT[0], CABLE_FOOT[1] + 0.05), t=0.06, kind="iron", ghost=True,
       z=(-0.25, -0.15))  # the cable
A.solid(box_pts(CABLE_FOOT[0] - 0.9, 1027.4, 0.3, 2.4), "wood", ghost=True, z=GHOST_BACK)  # its anchor post at the mouth
air_box(-458.3, 1017.5, -455.7, 1027.5)  # the mouth, down into the grotto
GROTTO = (-470.0, 1006.0, -452.0, 1018.5)
air_box(*GROTTO)
air_box(-463.75, 1018.0, -463.4, 1025.0)  # the crack the daylight comes down
POOL_Y = 1008.2
A.ledge(-470.0, -466.0, 1008.4, "rock", t=2.4)   # the west bank
A.ledge(-466.0, -455.0, 1006.6, "rock", t=0.6)   # the pool's floor
A.ledge(-455.0, -452.0, 1008.4, "rock", t=2.4)   # the east bank
A.water((-466.0, 1006.6, -455.0, POOL_Y), POOL_Y, flow=(0.0, 0.0), look="pool")
A.zones[-1].update({"front": 1.1, "fade": 0.8, "dark": 0.2})  # (in its banks, not a glass tank before them: 2.7's way)
air_line([(-469.0, 1008.9), (-472.0, 1007.3), (-483.5, 999.7), (-486.2, 997.9)], 1.1)  # the slide out through the west face
for x in (-469.0, -461.5, -454.0):
    A.deco("frog_sit", x, 1008.4 if x != -461.5 else POOL_Y - 0.1, z=-1.0, scale=1.6, size=(0.42, 0.42, 0.43), tone="accent")
A.light(-463.6, 1016.5, color="#FFE6B0", rng=9.0, energy=1.8, z=0.5)  # the daylight down the crack
A.light(-459.0, 1010.0, color="#FFB070", rng=8.0, energy=1.6, z=0.8, flicker=True)  # warm
A.effect("steam", (-466.0, 1008.0, -455.0, 1014.0), density=0.8)
A.dark((GROTTO[0], GROTTO[1], GROTTO[2], GROTTO[3]), level=0.25)
A.ride((-504.0, 956.0, -444.0, 1066.5))  # the cable, the drop, the pool, the slide (st.py's ride carries on below)
A.challenge("11.11", "Los Baños de las Ranas", (-467.0, 1008.4), 1, "", moves=[])
A.cam((-460.0, 1026.0, -444.0, 1066.0), half_h=10.0, bias=(-2.0, -3.0))  # the cable
A.cam((-471.0, 1005.0, -451.0, 1027.0), half_h=6.5, bias=(0.0, 1.0))     # the spring
A.cam((-500.0, 955.0, -470.0, 1005.0), half_h=8.0, bias=(0.0, -2.0))     # the slide out

# ================================================================ the misses
# A miss outside slides down the east face, off the prow, into the balloon's rope (a10). The faces have cameras that
# look east and down, at where you are going.
A.cam((-380.0, 1012.0, -360.0, 1031.0), half_h=8.0, bias=(3.0, -2.0))   # the face above the terraces
A.cam((-422.0, 1012.0, -408.0, 1031.0), half_h=8.0, bias=(2.0, -2.0))   # the cleft
A.cam((-500.0, 1005.0, -456.0, 1026.0), half_h=8.0, bias=(-2.0, -2.0))  # the west shoulder

# ================================================================ the mass, cut
def _convex_pieces(solid_poly):
    """Cut a polygon into convex slabs (vertical strips glued while they stay convex: a1's way)."""
    from shapely.geometry import box
    xs = sorted({round(x, 3) for g in getattr(solid_poly, "geoms", [solid_poly])
                 for ring in [g.exterior] + list(g.interiors) for x, _ in ring.coords})
    y0, y1 = solid_poly.bounds[1] - 1, solid_poly.bounds[3] + 1
    pieces = []
    for xa, xb in zip(xs, xs[1:]):
        if xb - xa < 1e-4:
            continue
        band = solid_poly.intersection(box(xa, y0, xb, y1))
        for g in getattr(band, "geoms", [band]):
            if g.geom_type == "Polygon" and g.area > 1e-3:
                pieces.append(g)
    merged = True
    while merged:
        merged = False
        for i in range(len(pieces)):
            for j in range(i + 1, len(pieces)):
                a, b = pieces[i], pieces[j]
                if a.bounds[2] < b.bounds[0] - 1e-6 or b.bounds[2] < a.bounds[0] - 1e-6:
                    continue
                if a.bounds[3] < b.bounds[1] - 1e-6 or b.bounds[3] < a.bounds[1] - 1e-6:
                    continue
                u = a.union(b)
                if u.geom_type == "Polygon" and not u.interiors and u.convex_hull.area - u.area < 1e-4:
                    pieces[i] = u.convex_hull
                    del pieces[j]
                    merged = True
                    break
            if merged:
                break
    out = []
    for p in pieces:
        pts = list(p.simplify(1e-4).exterior.coords)[:-1]
        out.append([q for k, q in enumerate(pts) if math.dist(q, pts[k - 1]) > 0.02])
    return out


def _mass():
    from shapely.geometry import Polygon, LineString, box
    from shapely.ops import unary_union
    cuts = []
    for kind, v in AIR:
        if kind == "box":
            cuts.append(box(*v))
        elif kind == "poly":
            cuts.append(Polygon(v))
        else:
            pts, half = v
            cuts.append(LineString(pts).buffer(half, cap_style=2, join_style=2))
    rock = Polygon(MASS).buffer(0).difference(unary_union(cuts))
    n = 0
    for pts in _convex_pieces(rock):
        if len(pts) >= 3:
            A.solid(pts, "blackice")
            n += 1
    return n


_mass()
# Behind the rooms: their back walls, so nothing inside shows the sky. (The mass is one solid skin; the rooms are
# holes through it, and these are what you see at their backs.)
def _back_cards():
    """Every hole cut through the mass gets a back wall: the rooms their own tones, every tunnel and chute one dark
    card behind them all, each cut to the mountain's outline (a card standing outside the face showed as a brown
    block in the sky: the first frames, 11-19)."""
    from shapely.geometry import Polygon, LineString, box
    from shapely.ops import unary_union
    mass = Polygon(MASS).buffer(0)

    def card(geom, z, tone):
        for g in getattr(geom, "geoms", [geom]):
            if g.geom_type != "Polygon" or g.area < 0.05:
                continue
            parts = [g]
            if g.interiors:  # (a card has no holes: halve it through the first hole)
                cx = g.interiors[0].centroid.x
                parts = [g.intersection(box(-1e4, -1e4, cx, 1e4)), g.intersection(box(cx, -1e4, 1e4, 1e4))]
            for q in parts:
                for h in getattr(q, "geoms", [q]):
                    if h.geom_type == "Polygon" and h.area >= 0.05:
                        A.card([(round(x, 3), round(y, 3)) for x, y in list(h.simplify(0.01).exterior.coords)[:-1]],
                               z=z, tone=tone, edge=False)
    for room, tone in (((-362.5, 962.5, -339.0, 971.5), "#3A2A22"), ((-407.0, 1010.5, -376.5, 1031.5), "#20160F"),
                       ((-471.0, 1005.5, -451.0, 1019.0), "#2C2A30")):
        card(box(*room).intersection(mass), -2.2, tone)
    cuts = []
    for kind, v in AIR:
        if kind == "box":
            cuts.append(box(*v))
        elif kind == "poly":
            cuts.append(Polygon(v))
        else:
            cuts.append(LineString(v[0]).buffer(v[1], cap_style=2, join_style=2))
    card(unary_union(cuts).buffer(0.4).intersection(mass), -2.45, "#1B1719")


_back_cards()

# ================================================================ the picture
# The clouds drift behind the climb (note 40), a thin layer 6 m back; gold dust in the light.
A.effect("clouds", (-500, 952, -316, 966), z=-6.0)
A.effect("dust", (-460, 1020, -330, 1070), tone="gold", density=0.3)
A.light(-335.0, 975.0, color="#FFD98A", rng=12.0, energy=1.0)
A.light(-352.0, 990.0, color="#FFD98A", rng=12.0, energy=1.0)
A.light(-368.0, 1006.0, color="#FFD98A", rng=12.0, energy=1.0)

if __name__ == "__main__":
    A.save()
