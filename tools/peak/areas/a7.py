"""
A7 LOS RISCOS DEL VIENTO: the windy cliffs, the first area outside.
  python tools/peak/areas/a7.py

The picture: EL ARCO. A pierced rock tower (LA TORRE, x -210..-204) stands on El Balcon's
east end, and a natural arch joins it to the face. Under the arch is the amphitheatre
over the Balcon (7.1 to 7.4: a miss lands on the Balcon). The tower's east side hangs
over La Garganta (7.5, 7.8: a miss is the whole mountain). On top of the arch a slick V
(the boulder gully and its counter-slope) pours through EL OJO, a hole in the arch's
crown, 52 m down onto the Balcon (7.6, 7.7).

Where falls go:
  x -232..-210 (under the arch)       -> El Balcon (A)
  the arch's top, the gully, the burros -> the slick V -> El Ojo (x -228..-224) -> El Balcon (A)
  x > -204 (the tower's east side)    -> La Garganta (X). One shrub on the Balcon's lip.
  the chimney (7.9), the scaffold (7.10) -> the shaft / the old catwalk -> R7, 7.8's start (B)
East of x -194 nothing of ours stands but the horn (x -185..-182): the fall line from
the cableway down to La Garganta is open.
"""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from peaklib import Area, box_pts, ngon, fling_speed
from shapely.geometry import Polygon, box as sbox

A = Area("a7", "cliffs")
SL = "wet"  # the slick of the cliffs: dark, rain-glossed rock


def cut(base, holes, kind=SL):
    """base minus holes (shapely), written as simple solids."""
    g = base
    for h in holes:
        g = g.difference(h)
    for p in (g.geoms if hasattr(g, "geoms") else [g]):
        assert not p.interiors, "a hole inside a solid"
        A.solid(list(p.exterior.coords)[:-1], kind)


def nubs(pts, kind="rock", r=0.22):
    for x, y in pts:
        A.hold(x, y, r, kind)


def chain(pts):
    """Reach moves hold to hold along pts."""
    return [["reach", list(pts[i]), list(pts[i + 1])] for i in range(len(pts) - 1)]


# ================================================================ EL BALCON (the catch, cost A)
# A rock shelf 5 m deep, top y 578, x -232..-204. Grip on top from the door to the tower's
# foot; slick underneath and on its east lip (the tower's east face runs straight down it).
A.solid([(-232, 577.5), (-204, 577.5), (-204, 575.0), (-212, 573.0), (-232, 573.0)], SL)
A.ledge(-232.0, -209.9, 578.0, "rock", t=0.6)
A.solid([(-210.0, 577.4), (-204.0, 577.4), (-204.0, 578.05), (-210.0, 578.05)], SL)  # under the tower: the lip stays slick
A.box(-213.0, 578.03, 1.0, 0.1, SL)  # the unease: a seep of wet across the boards of rock
# The designed mercy: one shrub on the east lip, 0.5 m of root over 180 m of throat.
A.hold(-203.7, 577.3, 0.28, "root")
A.deco("shrub_dry", -203.6, 577.4, z=0.0, size=(0.9, 0.7, 0.6), tone="root")

# ================================================================ THE EAST FACE (our stretch)
# Going UP the face, rock on the left (west). The door from the chimney (a6) is the first
# edge: x -230, y 578..586, left open. a6's sill is at y 580; the Balcon is 2 m under it.
FACE = [(-230.0, 578.0), (-230.0, 586.0),  # 0 the door (None)
        (-230.0, 590.0),  # 1 the lintel
        (-238.0, 600.0),  # 2 a 51 degree slab (built by hand below: its back must not sag into a6)
        (-243.0, 600.0),  # 3 R2, the nest ledge (grip)
        (-243.0, 604.6),  # 4 its back wall
        (-239.5, 608.5),  # 5 its roof
        (-238.5, 626.0),  # 6 the wall under the arch's west springing
        (-244.0, 647.6),  # 7 hidden behind the gully's rock
        (-249.5, 647.6),  # 8 R6, the gully's head (grip)
        (-249.5, 653.0),  # 9 its back wall
        (-250.2, 658.8),  # 10 hidden behind R6's roof
        (-251.0, 684.0)]  # 11 the bare face up to the station
A.wall(FACE, kinds={0: None, 2: None, 3: "rock", 8: "rock"}, default=SL, thick=8.0, rock_on="left")
A.solid([(-230, 586), (-230, 590), (-238, 600), (-238.5, 599.5), (-246, 599.5), (-246, 586)], SL)  # lintel + slab
A.box(-239.2, 600.03, 0.9, 0.1, SL)  # R2's unease: guano, slick, by the lip
# The mountain behind the skin (wall() leaves wedges behind its corners: nothing reaches them, this hides them).
A.solid([(-244, 601), (-244, 605.5), (-240.5, 609), (-239.6, 626), (-245, 647), (-250.5, 647), (-250.5, 653.6),
         (-251.4, 659.2), (-252, 684), (-260, 684), (-260, 601)], SL)

# ================================================================ LA TORRE (x -210..-204, y 578..674)
# One rock tower with its alcoves and windows cut out. Its east face is one clean slick
# drop from the top to the Balcon's lip. Floors are laid in afterwards as grip.
TW, TE = -210.0, -204.0
tower = sbox(TW, 578.0, TE, 674.0)
holes = [
    sbox(TW, 589.8, -206.5, 594.2),  # R1: the alcove at the crack's top
    sbox(TW, 623.8, -205.5, 628.0), sbox(-205.5, 623.8, TE, 626.2),  # R4: the window (low lintel at its east mouth)
    Polygon([(TE, 637.0), (-207, 637.0), (-207, 638.2), (-208.5, 638.2), (-208.5, 639.4), (TW, 639.4),
             (TW, 644.0), (TE, 641.6)]),  # R5: the stair tunnel
    sbox(TW, 653.8, TE, 658.0),  # R7: the upper window
    sbox(-208.2, 658.0, -206.0, 674.0),  # the shaft, and the chimney above it (7.9)
    sbox(-206.0, 663.8, TE, 668.0),  # the porch (7.8 lands here)
    sbox(TW, 671.85, -208.2, 674.0),  # the west fin stops at 672: R9
]
cut(tower, holes)  # (each hole is cut 0.2 under its floor, so the grip floor stands proud of the slick)
A.solid([(-206.0, 665.7), (-205.5, 665.7), (-205.5, 668.0), (-206.0, 668.0)], SL)  # the tooth over the porch's inner end
A.solid([(-206.0, 674.0), (TE, 674.0), (-204.6, 676.5)], SL)  # the east fin's peak: nothing rests on it
# floors (grip)
A.ledge(TW, -206.5, 590.0, "rock", t=0.4)  # R1
A.ledge(TW, TE, 624.0, "rock", t=0.4)  # R4
A.ledge(-207.0, TE, 637.2, "rock", t=0.4)  # R5, three steps up to the west
A.ledge(-208.5, -207.0, 638.4, "rock", t=0.4)
A.ledge(TW, -208.5, 639.6, "rock", t=0.4)
A.ledge(-216.0, TE, 654.0, "rock", t=0.5)  # R7 and its west balcony
A.solid([(-216, 653.5), (-210, 653.5), (-210, 650.5)], SL)  # the balcony's corbel
A.ledge(-203.9, -202.8, 654.0, "plank", t=0.25)  # the perch plank out of R7's east mouth
A.ledge(-206.0, -202.5, 664.0, "rock", t=0.5)  # the porch: 3.5 m, 1.5 of it out over the throat
A.solid([(-204, 663.5), (-202.5, 663.5), (-204, 661.5)], SL)
A.ledge(TW, -208.2, 672.0, "rock", t=0.3)  # R9: the west fin's top
A.box(-205.0, 624.03, 1.0, 0.1, SL)  # R4's unease: wet at the east mouth
A.box(-211.5, 654.03, 1.0, 0.1, SL)  # R7's unease

# ================================================================ 7.1 EL BALCON (D2, S)
# Walk the Balcon east (22 m) to the tower's foot and climb its cracked west face: three
# lengths of crack with blank rock between (1.6, 1.7, 1.8 m reaches) to the alcove R1.
# The first gust blows WEST, off the wall, 1.5 s in every 5: it peels a loose climber
# back onto the Balcon. The streamers stand at the zone's two edges.
CR = [(579.4, 581.4), (583.0, 584.6), (586.3, 588.2)]
for y0, y1 in CR:
    A.patch((TW, y0), (TW, y1), "rock", t=0.3)
A.wind((-221, 578, TW, 592), (-2.5, 0.0), gust={"on": 1.5, "off": 3.5, "phase": 0.0, "warn": 1.0})
A.deco("streamer_pole", -221.0, 578.0, z=-0.6, size=(0.15, 3.0, 0.15), tone="accent")
A.deco("streamer_pole", -210.6, 590.0, z=-0.6, size=(0.15, 2.2, 0.15), tone="accent")
A.challenge("7.1", "El Balcón", (-228.0, 578.0), 2, "S",
            moves=[["reach", [TW, 581.4], [TW, 583.0]], ["reach", [TW, 584.6], [TW, 586.3]],
                   ["reach", [TW, 588.2], [TW, 590.0]]])
A.cam((-232, 574, -204, 588), half_h=6.0, bias=(3.0, -1.5))  # the town below, low in the frame

# ================================================================ 7.2 NIDOS (D3, A)
# Two vultures fly one closed round, half a lap apart (67 m at 4 m/s: one every 8.4 s).
# Stand on R1's lip, take the legs as they pass 2 m over it, hang for 28 m of gap, and
# let go when your feet brush R2 (the bird passes 2.1 m over the nest ledge, under the
# dead tree's trunk). Let go early: the slab under you is slick and tips you onto the Balcon.
VLOOP = [(-211.0, 592.0), (-217.0, 594.8), (-226.0, 599.0), (-233.0, 601.6), (-239.0, 602.1),
         (-237.6, 603.9), (-229.0, 607.5), (-219.0, 605.0), (-212.6, 597.5), (-211.0, 592.0)]
VSHAPES = [(box_pts(0.0, -0.25, 0.28, 0.5), "bone"),  # the legs: the only grip
           (box_pts(0.0, 0.4, 1.1, 0.6), SL)]  # the body: dark, no hold


def vulture(mid, pts, phase, mode="loop", wait=0.0):
    A.mover(mid, pts[0], VSHAPES, {"type": "path", "pts": [list(p) for p in pts], "speed": 4.0, "mode": mode,
                                   "phase": phase, "wait": wait, "trigger": "none"}, model="vulture")


vulture("vulture1", VLOOP, 0.0)
vulture("vulture2", VLOOP, 8.4)
A.challenge("7.2", "Nidos", (-208.5, 590.0), 3, "A")
A.cam((-245, 588, TW, 611), half_h=11.5, bias=(0.0, -2.0))
A.deco("vulture_nest", -241.6, 600.0, z=-0.7, size=(1.6, 0.6, 1.2), tone="root")
A.deco("vulture_nest", -208.0, 594.2, z=-0.9, size=(1.4, 0.5, 1.0), tone="root")

# ================================================================ 7.3 ARBOL SECO (D3, A)
# A dead tree rooted at R2's back, leaning 37 degrees off plumb out over the Balcon: 24 m
# of trunk. Its lower 8 m is bleached grip. The middle 11.5 m is a lightning scar, black
# and glossy: eight branch stubs cross it, side to side (1.72 m apart). The top is grip
# again, and then the last two branches: the first is rotten (1.2 s), the second brittle
# (0.8 s), and from its tip the keyhole's sill is 1.35 m away.
TR, TD = (-243.0, 599.8), (0.6, 0.8)


def tp(s, off=0.0):
    return (TR[0] + TD[0] * s - TD[1] * off, TR[1] + TD[1] * s + TD[0] * off)


A.beam(tp(0.0), tp(8.0), 0.7, "bone")
A.beam(tp(8.0), tp(19.5), 0.7, SL)
A.beam(tp(19.5), tp(24.0), 0.7, "bone")
STUBS = [tp(8.8 + 1.4 * i, 0.5 if i % 2 == 0 else -0.5) for i in range(8)]
nubs(STUBS, "bone")
A.beam(tp(24.0), (-226.5, 621.0), 0.22, "rotten")
A.beam((-226.2, 621.3), (-224.7, 623.0), 0.2, "brittle")
A.challenge("7.3", "Árbol Seco", (-240.5, 600.0), 3, "A",
            moves=chain([tp(8.0)] + STUBS + [tp(19.6)]) + [["reach", [-226.5, 621.0], [-226.2, 621.3]],
                                                             ["reach", [-224.7, 623.0], [-223.8, 624.0]]])
A.deco("dead_tree_crown", tp(24.0)[0], tp(24.0)[1], z=-0.8, size=(5.0, 4.0, 0.3), tone="bone")

# ================================================================ 7.4 PUENTE ROTO (D4, A)
# A fin of rock hangs from the arch's crown (x -223..-220). The keyhole through it is R3.
# The bridge ran from the keyhole to the tower's window (R4), 10 m: it was cut in the
# middle and its two halves hang down the two walls, 1.5 m off each, 7.1 m apart, each
# 5.3 m of rope with its last board still tied on. Down the west half, swing it, let go:
# 7.1 m across (still air, from a dead hang: 4.6 m/s, F2; a swung rope asks less).
A.solid([(-223, 623.7), (-220, 623.7), (-220, 617.0), (-221.5, 614.0), (-223, 617.0)], SL)  # the fin under the keyhole
A.ledge(-223.8, -220.0, 624.0, "rock", t=0.4)  # R3: the keyhole's floor and its sill
A.ledge(-220.0, -218.5, 624.0, "plank", t=0.25)  # what is left of the deck, west
A.ledge(-211.5, TW, 624.0, "plank", t=0.25)  # ... and east
A.box(-221.0, 624.03, 0.8, 0.1, SL)  # R3's unease
BOB = {"w": 1.2, "h": 0.14, "mass": 3.0, "kind": "plank"}
A.rope("bridge_w", (-218.55, 623.7), 5.3, kind="rope", bob=dict(BOB))
A.rope("bridge_e", (-211.45, 623.7), 5.3, kind="rope", bob=dict(BOB))
A.challenge("7.4", "Puente Roto", (-221.8, 624.0), 4, "A",
            moves=[["fling", [-218.55, 619.0], [-211.45, 619.6], "F2"]])
A.cam((-245, 611, TW, 630), half_h=11.0, bias=(0.0, -3.0))

# ================================================================ 7.5 LA CORNISA (D4, X)
# Out of R4's east mouth, past the Balcon's edge. A cornice juts 9 m east from the tower:
# seven knobs under its roof (1.5 to 1.7 m apart), hand over hand, with a crosswind
# blowing OUT (3.5 m/s2, 2.2 s on, 2.3 off) that swings your legs to the east. Round the
# nose by its grip knob, then six iron pegs up the cornice's slick 40 degree back to R5.
# Under all of it: 47 m of air, the shrub, and La Garganta.
def roof_y(x):
    return 626.2 + 0.1628 * (x + 204.0)


A.solid([(TE, 626.2), (-195.4, roof_y(-195.4)), (-194.7, 628.4), (-195.0, 629.6), (TE, 637.15)], SL)
A.solid([(-195.9, 627.5), (-194.6, 627.8), (-194.3, 628.8), (-195.0, 629.85), (-196.1, 629.4)], "rock")  # the nose knob
A.box(-204.5, 625.95, 0.4, 0.5, "rock")  # the first knob, hanging in the mouth
ROOF = [(x, roof_y(x) - 0.2) for x in (-203.0, -201.5, -200.0, -198.3, -196.8, -195.6)]
nubs(ROOF)
PEGS = [(x, 629.7 + 0.839 * (-195.0 - x)) for x in (-196.3, -197.6, -198.9, -200.2, -201.5, -202.8)]
nubs(PEGS, "iron", r=0.2)
A.wind((TE, 616, -190, 640), (3.5, 0.0), gust={"on": 2.2, "off": 2.3, "phase": 0.0, "warn": 0.8})
A.deco("streamer_pole", -204.4, 624.0, z=-0.6, size=(0.15, 2.0, 0.15), tone="accent")
A.deco("streamer_pole", -195.2, 629.8, z=-0.6, size=(0.15, 2.4, 0.15), tone="accent")
A.challenge("7.5", "La Cornisa", (-207.0, 624.0), 4, "X",
            moves=chain([(-204.3, 624.0), (-204.5, 625.8)] + ROOF + [(-194.45, 628.6), (-195.1, 629.8)] + PEGS
                        + [(TE, 637.2)]))
A.cam((TE, 612, -186, 646), half_h=13.0, bias=(2.0, -5.0))

# ================================================================ EL ARCO and EL OJO
# The arch in two masses with a 4 m hole between them (El Ojo, x -228..-224). West of
# the hole its top is the boulder gully (three slick treads at 35 degrees, two undercut
# risers); east of it a slick counter-slope (33 degrees) falls from the tower's stair
# tunnel. Both pour into the hole: whatever slides ends on the Balcon, 52 m down.
G0 = (-228.0, 631.2)  # the gully's foot: the hole's west lip
TDX, TDY, RISE = 5.333, 3.733, 2.6
F1 = (G0[0] - TDX, G0[1] + TDY)  # foot of riser 1 = floor of nook 1
L1 = (F1[0], F1[1] + RISE)  # lip 1
F2 = (L1[0] - TDX, L1[1] + TDY)
L2 = (F2[0], F2[1] + RISE)
GT = (-244.0, 647.6)  # the gully's top = R6's lip
west = [(-238.5, 626.0), (-234.0, 628.2), (-228.0, 628.9), G0]
for F, L in ((F1, L1), (F2, L2)):
    west += [F, (F[0] - 1.67, F[1]), (F[0] - 1.67, F[1] + 2.3), (F[0], F[1] + 2.0), L]  # tread top, nook floor, back, roof, nose
west += [GT]
A.solid(west, SL)
A.solid([(-224.0, 630.5), (TW, 639.6), (TW, 628.6), (-215.0, 629.4), (-219.9, 629.4), (-219.9, 628.0),
         (-223.1, 628.0), (-223.1, 628.9), (-224.0, 628.9)], SL)  # the east mass: counter-slope over, keyhole's roof under
# R6's roof: the boulders run down its back and drop off its lip, past the ledge.
A.solid([(-249.5, 653.0), (-243.8, 653.8), (-243.6, 654.4), (-250.2, 658.8), (-253.0, 658.8), (-253.0, 653.0)], SL)
A.box(-244.6, 647.63, 0.8, 0.1, SL)  # R6's unease: grit on the lip

# ================================================================ 7.6 DESPRENDIMIENTO (D4, A)
# Boulders come down in waves of three every 9 s (a rumble 1.2 s before): off R6's roof,
# down the three treads, over the two lips, across El Ojo into the counter-slope and back
# into the hole. CROSS it: from R5's west mouth, hand over hand down an old rock-fence
# rail (three timbers, 1.5 m gaps) that hangs 2.8 m over the counter-slope and out over
# the hole, where your feet are in the boulders' road. CLIMB it: knobs up each tread
# (1.6 m apart), and under each lip a pocket (grip floor, 2 m of roof) the boulders jump.
RAIL = [((-210.4, 641.3), (-216.5, 638.2)), ((-217.9, 637.4), (-222.6, 634.3)), ((-224.0, 633.9), (-228.7, 633.5))]
for p0, p1 in RAIL:
    A.beam(p0, p1, 0.25, "wood")


def tread(top_east, n=4):
    """Knobs up a tread from its east (low) end."""
    return [(top_east[0] - 1.2 - 1.3 * i, top_east[1] + 0.7 * (1.2 + 1.3 * i) + 0.1) for i in range(n)]


T1, T2, T3 = tread(G0, 3), tread(L1, 3), tread(L2, 3)
route = [(-210.2, 639.6), RAIL[0][0]]
moves76 = chain(route) + [["reach", list(RAIL[0][1]), list(RAIL[1][0])], ["reach", list(RAIL[1][1]), list(RAIL[2][0])]]
moves76 += chain([RAIL[2][1]] + T1 + [(F1[0] + 0.3, F1[1] + 0.1)])
for F, L, T, end in ((F1, L1, T2, (F2[0] + 0.3, F2[1] + 0.1)), (F2, L2, T3, GT)):
    A.ledge(F[0] - 1.67, F[0] + 0.2, F[1] + 0.1, "rock", t=0.3)  # the pocket's floor
    A.box(F[0] + 0.2, F[1] + 0.1, 0.6, 0.7, "rock")  # a step at its mouth (top + 0.45)
    A.hold(F[0] + 0.02, F[1] + 2.25, 0.25, "rock")  # the lip's nose
    moves76 += chain([(F[0] + 0.2, F[1] + 0.45), (F[0] + 0.02, F[1] + 2.25)] + T + [end])
nubs(T1 + T2 + T3)
for ph in (0.0, 0.8, 1.6):
    A.spawner("boulder", (-249.2, 660.3), 9.0, vel=(2.0, -1.0), phase=ph, r=0.55, life=9.0, warn=1.2, mass=40.0)
A.challenge("7.6", "Desprendimiento", (-205.5, 637.2), 4, "A", moves=moves76)
A.cam((-250, 630, TW, 647), half_h=10.5, bias=(0.0, -1.0))
A.effect("dust", (-250, 630, -222, 660), density=0.5)

# ================================================================ 7.7 LOS BURROS (D3, A)
# Three burros: one at the back of R6, two on ledges that hang over the gully with nothing
# under them. Grabbing one throws you at its kick velocity. K2 and K3 top out 2.0 m above
# where they land and come down at about 45 degrees; K1 is flatter (1.0 m, 27 degrees) to
# pass under R6's roof lip. Each lands 1.7 m short of the next burro (which is the
# backstop: overshoot into it and it kicks you on).
#   K1 from (-247.4, 648.7), v (5.19, 4.36): apex 652.1 at x -239.3, lands (-234.9, 651.1) after 2.41 s
#   K2 from (-233.1, 651.1), v (2.80, 4.84): apex 655.3 at x -228.2, lands (-224.9, 653.3) after 2.93 s
#   K3 from (-223.1, 653.3), v (3.44, 4.61): apex 657.1 at x -217.4, lands (-213.3, 655.1) after 2.85 s
# (points are the climber's middle, 1.1 m over the floor). K1 passes R6's roof lip with
# its middle 2.7 m under it. A miss lands in the gully or the counter-slope: El Ojo, El Balcon.
BURRO = [(box_pts(0.0, 0.85, 1.3, 0.7), "wood"), (box_pts(-0.45, 0.25, 0.2, 0.5), "wood"), (box_pts(0.45, 0.25, 0.2, 0.5), "wood")]


def kick_v(p0, p1, over=2.0):
    vy = math.sqrt(2 * 2.79 * (p1[1] - p0[1] + over))
    t = vy / 2.79 + math.sqrt(2 * over / 2.79)
    return [round((p1[0] - p0[0]) / t, 2), round(vy, 2)]


for i, (at, p0, p1, over) in enumerate((((-247.6, 647.6), (-247.4, 648.7), (-234.9, 651.1), 1.0),
                                        ((-233.3, 650.0), (-233.1, 651.1), (-224.9, 653.3), 2.0),
                                        ((-223.3, 652.2), (-223.1, 653.3), (-213.3, 655.1), 2.0))):
    A.mover("burro%d" % (i + 1), at, BURRO, {"type": "still"}, hold={"type": "kick", "v": kick_v(p0, p1, over)}, model="burro")
for x0, x1, y in ((-236.0, -232.6, 650.0), (-226.0, -222.6, 652.2)):
    A.ledge(x0, x1, y, "rock", t=0.5)
    A.solid([(x0, y - 0.5), (x1, y - 0.5), ((x0 + x1) / 2, y - 3.5)], SL)
A.challenge("7.7", "Los Burros", (-245.2, 647.6), 3, "A")
A.cam((-250, 647, TW, 662), half_h=11.0, bias=(3.0, -2.0))

# ================================================================ 7.8 VIENTO A FAVOR (D4, X)
# Everything here is east of the tower, over La Garganta. From R7's east mouth a perch
# plank; a third vulture beats back and forth (pingpong, 1 s hovering at each end: 2 m over
# the plank, then 2.3 m over the horn; 7.2 again, over nothing; it is also the way back)
# to EL CUERNO, a horn of rock 19 m out with 3 m of flat top. On the horn a snag: its
# stub, one knot, and a bough end 5.6 m over the top to spin on. Then back WEST to the
# porch, a 3.5 m ledge 4.4 m higher than the bough:
#   the gap: 17.9 m across, 4.4 m up (hold to the porch's lip).
#   still air: 8.0 m/s at 51 degrees (an F5 fling; the arc tops 6.9 m over the bough).
#   with the gust (3.0 m/s2 toward the tower, on 2.5 s in every 7, a whistle 1 s before),
#   letting go as it starts: 5.9 m/s at 73 degrees (F3). With 1 s of gust left: 6.6 m/s.
# The cableway's pylon legs (a8) hang down to y 670 at x -194 and -191: a lob that tops
# 10 m over the bough hits them. Short, long or blown: La Garganta.
PERCH = [(-203.2, 656.0), (-198.0, 657.6), (-190.0, 657.4), (-183.5, 656.3)]
vulture("vulture3", PERCH, 0.0, mode="pingpong", wait=1.0)
A.solid([(-185.2, 653.5), (-181.8, 653.5), (-182.3, 648.0), (-183.5, 642.0), (-184.6, 648.0)], SL)  # the horn
A.ledge(-185.0, -182.0, 654.0, "rock", t=0.6)
A.beam((-182.4, 654.0), (-182.7, 656.7), 0.3, "bone")  # the snag's stub
A.hold(-183.6, 658.2, 0.2, "bone")  # a knot
BOUGH, PORCH = (-184.7, 659.6), (-202.6, 664.0)
A.hold(BOUGH[0], BOUGH[1], 0.25, "bone")  # the bough, end on: the launch hold
A.wind((-203.5, 648, -177, 672), (-3.0, 0.0), gust={"on": 2.5, "off": 4.5, "phase": 0.0, "warn": 1.0})
for x, y in ((-203.2, 654.0), (-182.3, 654.0), (-202.8, 664.0)):
    A.deco("streamer_pole", x, y, z=-0.6, size=(0.15, 2.4, 0.15), tone="accent")
A.challenge("7.8", "Viento a Favor", (-207.0, 654.0), 4, "X",
            moves=chain([(-182.7, 656.7), (-183.6, 658.2), BOUGH]) + [["fling", list(BOUGH), list(PORCH), "F5"]])
A.cam((TE, 646, -175, 672), half_h=13.0, bias=(0.0, -4.0))

# ================================================================ 7.9 CHIMENEA DE ROCA (D3, B)
# The tower's top is split: two walls 2.2 m apart (x -208.2 and -206), slick, with pale
# bands 0.4 m tall. No band is within 2 m of the next on the same wall, so it is wall to
# wall: five lunges of 2.2 m across and 1.0 to 1.4 m up (3.1 to 3.4 m/s, F1). The chimney
# has no floor: under it the shaft drops 10 m into R7, where 7.8 starts.
EB = [(665.75, 666.2), (668.2, 668.6), (670.7, 671.1)]  # east wall bands (the first is on the tooth)
WB = [(666.8, 667.2), (669.4, 669.8)]  # west wall bands
for y0, y1 in EB:
    A.patch((-206.0, y0), (-206.0, y1), "rock", t=0.24)
for y0, y1 in WB:
    A.patch((-208.2, y0), (-208.2, y1), "rock", t=0.24)
CH = [(-206.0, 666.0), (-208.2, 667.0), (-206.0, 668.4), (-208.2, 669.6), (-206.0, 670.9), (-208.2, 672.0)]
A.challenge("7.9", "Chimenea de Roca", (-204.6, 664.0), 3, "B",
            moves=[["reach", [-206.0, 664.0], [-206.0, 665.85]]] + [["fling", list(CH[i]), list(CH[i + 1]), "F1"] for i in range(5)])
A.cam((TW, 658, TE, 676), half_h=7.0)

# ================================================================ 7.10 LA ESTACION BAJA (D3, B)
# From the fin's top (R9): the pylon platform with a board missing (1.4 m), the bull
# wheel (3.8 m, one turn in 24 s, its east side rising: take the rim at the platform's
# end, ride it over the top, step off west onto the stage at 677), then the scaffold's
# long brace up to the dock: 12 m at 56 degrees, its middle 2.6 m rotten (1.2 s).
# Under all of it the old catwalk (y 663): a fall lands there, and its east end is a
# 9 m drop onto R7's balcony. Back to 7.8.
A.ledge(-211.6, TW, 672.0, "plank", t=0.25)
A.ledge(-216.2, -213.0, 672.0, "plank", t=0.25)
A.wheel("bullwheel", (-220.2, 675.0), 3.8, 2.5, spokes=6, kind="wood", rim=0.25, model="bull_wheel")
A.ledge(-229.0, -224.3, 677.0, "plank", t=0.25)
B0, B1 = (-229.0, 677.3), (-235.8, 687.4)
BL = math.dist(B0, B1)


def bp(s):
    return (B0[0] + (B1[0] - B0[0]) * s / BL, B0[1] + (B1[1] - B0[1]) * s / BL)


A.beam(bp(0.0), bp(4.2), 0.3, "wood")
A.beam(bp(4.2), bp(6.8), 0.3, "rotten")
A.beam(bp(6.8), bp(BL), 0.3, "wood")
for x0, x1 in ((-237.0, -229.5), (-228.9, -221.0), (-220.4, -213.0)):
    A.ledge(x0, x1, 663.0, "plank", t=0.25)  # the old catwalk: the catch
# The low station's deck (a8 starts from it): top 688, x -250..-236, and a plug behind it.
A.ledge(-250.0, -236.0, 688.0, "plank", t=0.5)
A.solid([(-253.0, 686.0), (-250.0, 686.0), (-250.0, 688.0), (-253.0, 688.0)], "rock")
A.box(-237.0, 688.03, 0.8, 0.1, "grease")  # the deck's unease
A.challenge("7.10", "La Estación Baja", (-209.2, 672.0), 3, "B",
            moves=[["reach", [-211.6, 672.0], [-213.0, 672.0]], ["reach", [-216.2, 672.0], [-217.16, 672.72]],
                   ["reach", list(bp(4.2)), list(bp(5.5))], ["reach", list(bp(5.5)), list(bp(6.8))]])
A.cam((-240, 662, TW, 690), half_h=9.0, bias=(-2.0, -1.0))

# ================================================================ the picture
# Hard blue daylight after the dark. The valley and the town, tiny, low in the Balcon's frame.
A.deco("town_far", -186.0, 571.0, z=-60.0, size=(40.0, 8.0, 1.0), tone="accent")
A.card([(-262, 556), (-150, 556), (-150, 592), (-176, 604), (-205, 590), (-232, 600), (-262, 596)], z=-30.0, tone="back3")
A.card([(-262, 556), (-150, 556), (-150, 578), (-185, 586), (-220, 576), (-262, 584)], z=-18.0, tone="back2")
A.effect("clouds", (-262, 560, -150, 610), density=0.3)
ROCKC = "#B9AC90"  # rock a step behind the climbing plane
A.card([(-211, 573), (-203, 573), (-203, 677), (-211, 677)], z=-1.5, tone=ROCKC)  # the tower: its windows are alcoves
A.card([(-240, 624), (-203, 624), (-203, 646), (-245, 650)], z=-1.6, tone=ROCKC)  # the arch: El Ojo is a well, not a window
A.card([(-223.4, 613), (-219.6, 613), (-219.6, 632), (-223.4, 632)], z=-1.4, tone=ROCKC)  # the fin's root
A.card([(-185.6, 654), (-181.4, 654), (-179.5, 560), (-188.5, 560)], z=-1.5, tone=ROCKC)  # the horn's stalk, up from the throat
for x0, x1, y in ((-236.0, -232.6, 650.0), (-226.0, -222.6, 652.2)):
    A.card([(x0 + 0.6, y), (x1 - 0.6, y), (x1 + 0.4, y - 16), (x0 - 0.4, y - 16)], z=-1.3, tone=ROCKC)  # the burros' needles
A.card([(-262, 570), (-232, 570), (-232, 600), (-240, 628), (-246, 652), (-252, 690), (-262, 690)], z=-2.5, tone="back")
A.deco("rock_fence_frame", -219.5, 636.5, z=-0.9, rot=-33.0, size=(19.0, 3.0, 0.3), tone="wood")  # what holds 7.6's rail
A.deco("scaffold_frame", -225.0, 663.0, z=-1.0, size=(24.0, 25.0, 0.5), tone="wood")  # the station's legs, catwalk to dock
A.deco("pylon_head_low", -212.0, 672.0, z=-0.9, size=(8.0, 5.0, 1.0), tone="iron")
A.deco("cable_station_low", -243.0, 688.0, z=-1.2, size=(14.0, 6.0, 3.0), tone="accent")
A.deco("pennant_line", -230.0, 689.0, z=-1.0, size=(26.0, 1.2, 0.05), tone="accent")
A.deco("sign_pug_arrow", -226.5, 578.0, z=-1.0, size=(1.0, 2.2, 0.1), tone="wood", flip=True)
A.deco("lantern_cold", -244.0, 688.0, z=-0.8, size=(0.3, 0.5, 0.3), tone="gold")
A.deco("rubble_pile", -250.6, 659.4, z=-0.7, size=(3.0, 1.6, 1.0), tone="rock2")  # where the boulders start
A.deco("bone_pile", -207.5, 590.0, z=-0.8, size=(1.0, 0.4, 0.6), tone="bone")  # a vulture's larder in R1

if __name__ == "__main__":
    A.save()
