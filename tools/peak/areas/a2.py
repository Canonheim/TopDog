"""
A2 LAS AGUAS NEGRAS: the flooded works, the underground river.
  python tools/peak/areas/a2.py

How this file is built. The area is a set of chambers cut out of solid rock: every
chamber's AIR is a polygon (air / airbox), and the rock is the region minus the air,
written as slick slabs at the very end (build_rock). Everything a climber can hold is
a separate grip solid laid on top of that rock (cap, slab) or hung in the air.

The river (flows EAST), top to bottom:
  lake 166.2 -> dam -> upper reach 151 -> Cascada Chica (15 m) -> its pool 136 ->
  the spill down the pipe hall (20 m) -> tail pool and flume 116 -> El Charco 115 (under
  the well) -> the first cascade (24 m) -> the fast lower river 91.0 -> the lip (x -244).
A 2D river cannot have a pillar standing in it (it would dam the swimmer), so every
ledge over water is a HANGING slab, 1.5 m clear of the surface, and every way out of
moving water is a chain.
"""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from peaklib import Area, box_pts, ngon
from shapely.geometry import Polygon, box as sbox
from shapely.ops import unary_union

A = Area("a2", "river")
TEAL = "#6FE0D0"
AIR = []


def air(pts):
    AIR.append(Polygon(pts))


def airbox(x0, y0, x1, y1):
    AIR.append(sbox(min(x0, x1), min(y0, y1), max(x0, x1), max(y0, y1)))


def cap(x0, x1, y, kind="stone", t=0.5):
    """A grip top on a rock floor (the air's floor is drawn 0.3 under y)."""
    A.ledge(x0, x1, y, kind, t=t)


def slab(x0, x1, y, kind="brick", t=0.7):
    """A hanging platform: a slick body with a grip top. Water runs under it."""
    A.solid([(x0, y - t), (x1, y - t), (x1, y - 0.2), (x0, y - 0.2)], "wet")
    A.ledge(x0, x1, y, kind, t=0.3)


def lamp(x, y, rng=10.0):
    A.deco("lantern_hang", x, y, z=-0.9, size=(0.3, 0.5, 0.3), tone="accent")
    A.light(x, y - 0.3, color=TEAL, rng=rng, energy=1.5, flicker=True)


# ================================================================ THE LOWER RIVER AND THE LIP
# A1's roof slab is y 86..90 under the lip, so the bed lies ON it: bed 90, surface 91.0.
# The slot (x -244..-238) and the dry shaft (x -236..-232) go down through that roof to A1.
RIV_B, RIV_S = 90.0, 91.0
T0C = 96.0  # the river tunnel's roof
air([(-288, RIV_B), (-244, RIV_B), (-244, 84), (-238, 84), (-238, 91.5), (-236, 91.5), (-236, 84), (-232, 84),
     (-232, 89.7), (-226, 89.7), (-226, T0C), (-288, T0C)])
A.opening(-244, 85, -238, 89)  # the waterfall's slot
A.opening(-236, 85, -232, 91)  # the dry shaft from the mine
A.solid([(-238, 91.5), (-236, 91.5), (-237, 92.2)], "wet")  # the pier's peaked top: sheds both ways
cap(-232, -226, 90.0)  # THE LIP LEDGE (entry). The pier keeps the river (1 m higher) off it
A.box(-231.75, 90.02, 0.5, 0.1, "wet")  # the drip that slicks its lip
A.water((-288, RIV_B, -252, RIV_S), RIV_S, flow=(2.2, 0.0))
A.water((-252, RIV_B, -244, RIV_S), RIV_S, flow=(2.4, 0.0))  # it quickens at the lip

# ---------------------------------------------------------------- 2.1 El Borde
PY = 94.5  # the pipes: a body hanging from them (2.1 m) clears the pier's peak
A.beam((-229.5, 92.0), (-233.5, PY), 0.3, "paint")  # up from the ledge
for x0, x1, k in ((-237.5, -233.5, "paint"), (-239.0, -237.5, "grease"), (-242.5, -239.0, "paint"),
                  (-244.0, -242.5, "grease"), (-253.0, -244.0, "paint")):
    A.beam((x0, PY), (x1, PY), 0.3, k)
A.rope("last_chance", (-246.6, PY - 0.2), 3.0, kind="chain")  # THE ONE MERCY: its end 0.3 m over the water
A.challenge("2.1", "El Borde", (-229.0, 90.0), 2, "X",
            moves=[["reach", [-229.5, 90.2], [-229.5, 92.0]],
                   ["reach", [-237.5, PY], [-239.0, PY]], ["reach", [-242.5, PY], [-244.0, PY]]])
slab(-257.2, -251.5, 92.9, "brick", t=0.4)  # P1: the landing, hung from the works above
Q1Y = 98.6
A.beam((-257.0, 92.9), (-257.0, Q1Y + 0.8), 0.3, "iron")  # the ladder up the well to the race

# ================================================================ THE MILL (x -257..-226), three floors
RB, RS = 96.8, 98.2  # the race: bed, surface
L1C = 107.4
airbox(-257.2, T0C - 0.1, -255.4, L1C)  # the ladder well
air([(-255.4, Q1Y - 0.3), (-253.5, Q1Y - 0.3), (-253.5, RB), (-226, RB), (-226, L1C), (-255.4, L1C)])
airbox(-229, T0C - 0.1, -226, RB + 0.1)  # the race's drain: it drops you on the lip ledge
cap(-255.4, -253.5, Q1Y, "brick")  # Q1
A.water((-253.5, RB, -229, RS), RS, flow=(1.4, 0.0), look="race")

# ---------------------------------------------------------------- 2.2 La Rueda
WHEEL = (-251.3, 100.8)
A.wheel("rueda", WHEEL, 2.0, -4.0, spokes=6, kind="wood", hub=0.45, model="mill_wheel")
A.challenge("2.2", "La Rueda", (-254.4, Q1Y), 2, "B")

# ---------------------------------------------------------------- 2.3 El Acueducto
CROWN = [(-249.1, -246.1, 101.4), (-243.1, -240.1, 101.8), (-236.3, -233.6, 102.2), (-228.5, -226.0, 102.6)]
for x0, x1, y in CROWN:
    A.solid([(x0, y - 0.9), (x1, y - 0.9), (x1, y), (x0, y)], "brick")
moves23 = []
for i, (x0, x1, y) in enumerate(CROWN[:3]):
    out = 1.6 if i < 2 else 1.3
    ra, rb = (x1 + 0.35, y + 1.95), (x1 + out, y + 2.3)  # the near ring, the launch ring
    A.hold(*ra, r=0.2, kind="iron")
    A.hold(*rb, r=0.22, kind="iron")
    for r in (ra, rb):
        A.deco("hanger_chain", r[0], (r[1] + L1C) / 2, z=-0.3, size=(0.08, L1C - r[1], 0.08), tone="iron")
    nx0, nx1, ny = CROWN[i + 1]
    moves23 += [["reach", list(ra), list(rb)], ["fling", list(rb), [(nx0 + nx1) / 2, ny], "F2"]]
A.challenge("2.3", "El Acueducto", (-247.6, CROWN[0][2]), 2, "B", moves=moves23)
Q2Y, Q3Y = 110.3, 111.8
A.beam((-226.2, CROWN[3][2]), (-226.2, Q2Y + 1.0), 0.3, "iron")  # the hatch ladder up the east wall

# ---------------------------------------------------------------- 2.4 Brazo de Molino
MB, MS = 108.4, 109.8  # the mill channel: bed, surface
L2C = 115.6
air([(-249.2, Q3Y - 0.3), (-246.6, Q3Y - 0.3), (-246.6, MB), (-230.8, MB), (-230.8, Q2Y - 0.3), (-226, Q2Y - 0.3),
     (-226, L2C), (-249.2, L2C)])
airbox(-227.8, L1C - 0.1, -226, Q2Y - 0.2)  # the hatch
airbox(-232.6, L1C - 0.1, -230.8, MB + 0.1)  # the channel's drain: down to the race
cap(-230.8, -227.8, Q2Y, "brick")  # Q2
cap(-249.2, -246.6, Q3Y, "brick")  # Q3
A.water((-246.6, MB, -232.6, MS), MS, flow=(1.1, 0.0), look="race")
A.beam((-229.5, Q2Y + 2.0), (-236.6, Q2Y + 2.0), 0.3, "paint")  # hand over hand out over the drain, then drop in
for y in (MS + 0.5, MS + 1.3):
    A.hold(-246.5, y, r=0.2, kind="iron")  # "the ladder"
A.challenge("2.4", "Brazo de Molino", (-228.6, Q2Y), 3, "B")

# ---------------------------------------------------------------- 2.5 Las Compuertas
WINC = 128.6
GT, GH = 3.2, 3.4  # a gate's travel, its height
GATES = ((-250.28, Q3Y), (-252.4, Q3Y + 3.0), (-254.52, Q3Y + 6.0))  # centre x, top when down
Q4Y = GATES[2][1] + GT  # 121.0
air([(-255.6, GATES[2][1] - GH), (-253.45, GATES[2][1] - GH), (-253.45, GATES[1][1] - GH), (-251.35, GATES[1][1] - GH),
     (-251.35, MB), (-249.2, MB), (-249.2, WINC), (-255.6, WINC)])
for i, (cx, low) in enumerate(GATES):
    A.mover("compuerta%d" % (i + 1), (cx, low),
            [(box_pts(0, -GH / 2, 2.05, GH), "grease"), (box_pts(0, -0.12, 2.05, 0.24), "iron")],
            {"type": "cycle", "to": [0, GT], "t_out": 1.8, "hold_out": 2.0, "t_in": 0.4, "hold_in": 2.0,
             "phase": 3.1 if i == 1 else 0.0}, model="mill_gate")
A.challenge("2.5", "Las Compuertas", (-247.9, Q3Y), 3, "B")

# ================================================================ EL DESAGUE: the Tobogan's drain
# The slide tube's outlet is walled all the way to the river: 5 m wide above, with ONE
# broken-out window where the chains hang, then a funnel and 7.3 m wide below. What the
# tube drops can only land in the fast river, 14 to 21 m upstream of the lip.
FUN = 114.0
airbox(-264.5, WINC - 0.1, -259.5, 181)  # the upper pipe
A.opening(-266, 175, -258, 181)
airbox(-265.5, T0C - 0.1, -258.2, FUN + 0.1)  # the lower pipe: it opens in the river tunnel's roof
air([(-284, Q4Y - 0.3), (-271.2, Q4Y - 0.3), (-265.5, FUN), (-258.2, FUN), (-258.2, Q4Y - 0.3), (-255.6, Q4Y - 0.3),
     (-255.6, WINC), (-272, WINC), (-272, Q4Y + 4.6), (-284, Q4Y + 4.6)])  # the window, and the gallery west of it
cap(-258.2, -255.6, Q4Y, "brick")  # Q4
cap(-284, -271.2, Q4Y, "brick")  # Q5, the gallery
A.box(-271.45, Q4Y + 0.02, 0.5, 0.1, "wet")

# ---------------------------------------------------------------- 2.6 Cadenas
A.rope("cadena1", (-258.9, WINC), 6.6, kind="chain")
A.rope("cadena2", (-265.3, WINC), 7.5, kind="chain")
A.rope("cadena3", (-269.3, WINC), 6.5, kind="chain")
A.challenge("2.6", "Cadenas", (-257.0, Q4Y), 3, "X",
            moves=[["fling", [-258.9, Q4Y + 3.0], [-265.3, Q4Y + 1.5], "F2"],
                   ["fling", [-265.3, Q4Y + 2.5], [-269.3, Q4Y + 1.5], "F2"],
                   ["fling", [-269.3, Q4Y + 2.0], [-272.6, Q4Y], "F2"]])

# ================================================================ EL CHARCO DEL POZO
CS = 115.0
airbox(-288, T0C - 0.1, -284, 113.1)  # the first cascade's shaft
airbox(-320.5, 113, -284, 128)  # the pool's hall
airbox(-306, 127.9, -294, 181)  # the well comes down through the rock to its roof
A.opening(-306, 175, -294, 181)
A.water((-320.5, 113, -288, CS), CS, flow=(1.0, 0.0), look="pool")
slab(-291, -284, 117.4)  # Q6, over the cascade's lip
slab(-320.5, -314, 117.2, t=0.7)  # Q7, the west bank
A.box(-291.2 + 0.45, 117.42, 0.5, 0.1, "wet")

# ---------------------------------------------------------------- 2.7 the barrels
BARREL = [(-0.9, -0.3), (-0.6, -0.55), (0.6, -0.55), (0.9, -0.3), (0.9, 0.3), (0.6, 0.55), (-0.6, 0.55), (-0.9, 0.3)]
for i in range(13):
    A.mover("barril%d" % (i + 1), (-319.6, 115.3), [(BARREL, "wood")],
            {"type": "path", "pts": [[-319.6, 115.3], [-285.8, 115.3]], "speed": 0.55, "mode": "wrap",
             "phase": round(i * 2.6 / 0.55, 3), "trigger": "none"}, model="barrel_float")
A.challenge("2.7", "El Charco del Pozo", (-287.0, 117.4), 3, "X")

# ================================================================ THE FLUME AND THE PIPE HALL
FS = 116.0  # flume and tail pool surface (bed 114.5)
airbox(-346, 114.5, -320.5, 122.5)  # the flume
airbox(-380, 114.5, -346, 142)  # the pipe hall, over the tail pool
slab(-325, -320.5, 118.0, t=0.5)  # Q8: the way in, over the flume's foot
A.water((-380, 114.5, -346, FS), FS, flow=(1.4, 0.0))  # the tail pool
A.water((-346, 114.5, -320.5, FS), FS, flow=(1.5, 0.0), look="flume")  # the flume: hard (the swim tops out at 2.0 m/s: tests/peak_swim_probe)
# The eddies behind the three pillars. Not quite still (0.3 m/s): rest, but keep a hand moving.
PILLARS = (-325.0, -330.5, -336.0)
for px in PILLARS:
    A.water((px - 2.5, 114.5, px, FS), FS, flow=(0.3, 0.0), look="eddy")
    A.deco("flume_pillar", px + 0.4, 117.5, z=-1.3, size=(0.9, 7.0, 0.9), tone="brick")  # behind the lane
slab(-349, -344.5, 118.2, "iron", t=0.5)  # Q9: the grating at the flume's head
A.rope("flume_out", (-344.45, 117.6), 1.2, kind="chain")  # the way out: its end is 0.4 m over the water, so only a raised arm takes it
A.challenge("2.8", "Contracorriente", (-323.0, 118.0), 4, "B")

# ---------------------------------------------------------------- 2.9 Tuberia
COOL = [(-349.3, 120.0), (-377.6, 136.6)]
HOT = [(-350.2, 121.2), (-351.0, 122.4), (-351.9, 123.6), (-360.0, 125.6), (-360.7, 126.9), (-361.6, 128.1),
       (-362.3, 129.3), (-370.0, 131.1), (-370.7, 132.4), (-371.6, 133.6), (-372.3, 134.7)]
RUNS = [(-359.0, -352.6, 124.6), (-369.0, -363.0, 130.1), (-377.3, -372.9, 135.4)]
for p in COOL:
    A.hold(p[0], p[1], r=0.24, kind="paint", n=8)
for p in HOT:
    A.hold(p[0], p[1], r=0.26, kind="hotpipe", n=8)
for x0, x1, y in RUNS:
    A.beam((x0, y), (x1, y), 0.3, "paint")
route29 = [(-349.0, 118.2), COOL[0]] + HOT[0:3] + [(-352.6, 124.6), (-359.0, 124.6)] + HOT[3:7] + \
          [(-363.0, 130.1), (-369.0, 130.1)] + HOT[7:11] + [(-372.9, 135.4), (-377.3, 135.4), COOL[1], (-378.0, 138.0)]
moves29 = [["reach", list(a), list(b)] for a, b in zip(route29, route29[1:])
           if not (a[1] == b[1] and abs(a[0] - b[0]) > 2)]  # the cool runs are hand over hand
A.challenge("2.9", "Tubería", (-347.0, 118.2), 3, "B", moves=moves29)
for a, b in zip(route29[1:], route29[2:]):  # the pipes themselves are a picture behind the holds
    A.deco("pipe_verdigris", (a[0] + b[0]) / 2, (a[1] + b[1]) / 2, z=-0.5,
           rot=math.degrees(math.atan2(b[1] - a[1], b[0] - a[0])), size=(math.dist(a, b), 0.22, 0.22), tone="slick")

# ================================================================ LA CASCADA CHICA
PS = 136.0
airbox(-392, 134.5, -380, 158)  # the pool's hall
A.water((-392, 134.5, -380, PS), PS, flow=(1.0, 0.0), look="pool")
slab(-385, -378, 138.0, t=0.5)  # Q10, over the spill's lip
WET = [(-385.6, 139.4), (-386.7, 140.5), (-387.9, 141.5), (-388.8, 142.8), (-388.0, 150.0), (-389.2, 151.1), (-390.4, 152.2)]
for i, p in enumerate(WET):
    A.hold(p[0], p[1], r=0.24, kind="rock", hold={"type": "wet", "on": 1.6, "off": 3.4, "phase": (i * 1.0) % 5.0})
A.rope("cuerda_niebla", (-386.6, 158.0), 13.6, kind="rope")
A.challenge("2.10", "La Cascada Chica", (-381.5, 138.0), 4, "B",
            moves=[["reach", [-385.0, 138.0], list(WET[0])], ["reach", list(WET[0]), list(WET[1])],
                   ["reach", list(WET[1]), list(WET[2])], ["reach", list(WET[2]), list(WET[3])],
                   ["fling", list(WET[3]), [-386.6, 145.0], "F2"], ["reach", [-386.6, 149.5], list(WET[4])],
                   ["reach", list(WET[4]), list(WET[5])], ["reach", list(WET[5]), list(WET[6])],
                   ["reach", list(WET[6]), [-391.5, 153.0]]])

# ---------------------------------------------------------------- the upper reach and its catwalk
US = 151.0
airbox(-425.5, 149.5, -392, 158)
A.water((-425.5, 149.5, -392, US), US, flow=(1.2, 0.0))
slab(-404, -391.5, 153.0, "iron", t=0.4)
slab(-407.3, -405.3, 153.0, "iron", t=0.4)
A.ledge(-409.3, -407.3, 153.0, "rotten", t=0.3)  # the plank that creaks
slab(-411.5, -409.3, 153.0, "iron", t=0.4)
slab(-418.5, -412.8, 153.0, "iron", t=0.4)
slab(-425.5, -419.8, 153.0, "iron", t=0.4)

# ================================================================ LA PRESA
# Five lifts up the stepped face of the dam. Each rises 1.0 m while its crank is wound
# and sinks when it isn't; the next lift's deck is 1.9 m above the top of the one before.
X1, R1, STEP, RISE = -429.6, 152.5, 2.6, 2.9
dam = [(-425.5, 151.9), (X1, 151.9)]
for k in range(1, 5):
    dam += [(X1 - (k - 1) * STEP, R1 - 0.3 + k * RISE), (X1 - k * STEP, R1 - 0.3 + k * RISE)]
dam += [(-440, 166.7), (-449, 166.7), (-449, 163), (-459, 163), (-459, 173), (-440, 173), (-440, 170), (-425.5, 170)]
air(dam)
airbox(-456, 172.9, -449, 181)  # the exit
A.opening(-456, 175, -449, 181)
cap(X1, -425.5, 152.2)  # Q11, the apron
cap(-449, -440, 167.0)  # the dam's crest
A.water((-459, 163, -449, 166.2), 166.2, flow=(0.0, 0.0), look="lake")
A.beam((-449.5, 168.6), (-449.5, 178.2), 0.35, "iron")  # the rungs out, up through the roof
for k in range(5):
    x, y = X1 - k * STEP, R1 + k * RISE
    hub = (x + 0.45, y + 1.8)
    A.body("manivela%d" % (k + 1), hub, [(ngon(0, 0, 0.34, 8), "iron"), (ngon(0.42, 0, 0.13, 6), "iron")],
           mass=6.0, hinge=hub, damp=0.6, model="crank_small")
    A.mover("alza%d" % (k + 1), (x + 1.2, y), [(box_pts(0, -0.15, 2.4, 0.3), "plank")],
            {"type": "crank", "to": [0, 1.0], "body": "manivela%d" % (k + 1), "per_turn": 0.3 if k < 3 else 0.25,
             "fall": 0.3 if k < 2 else 0.45}, model="dam_lift")
A.challenge("2.11", "La Presa", (-426.3, 152.2), 3, "B")

# ================================================================ CAMERAS (the drop under every fling)
A.cam((-256, 86, -226, T0C), 5.0, bias=(-2.0, -1.0))  # the lip: the slot is in frame
A.cam((-258, T0C, -226, L1C), 6.5)  # the wheel and the aqueduct, down to the race
A.cam((-250, L1C, -226, L2C), 5.0)
A.cam((-256, L1C, -249, WINC), 6.5, bias=(0.0, 1.5))  # the gates
A.cam((-273, 113, -256, WINC), 9.0, bias=(0.0, -3.0))  # the chains: the drain's throat under them
A.cam((-321, 113, -284, 128), 8.5, bias=(0.0, 2.0))  # the Charco: look up the well
A.cam((-346, 114, -321, 122.5), 5.0, bias=(-2.0, 0.0))
A.cam((-380, 114.5, -346, 142), 8.0, bias=(-2.0, -1.0))  # the pipe hall: the tail pool under you
A.cam((-392, 134.5, -380, 158), 10.0)  # the cascade, top to pool
A.cam((-426, 149.5, -392, 158), 5.0)
A.cam((-459, 150, -426, 176), 7.0, bias=(-1.5, 2.0))  # the dam

# ================================================================ THE PICTURE
A.card([(-466, 82), (-222, 82), (-222, 182), (-466, 182)], z=-6.0, tone="back2")  # the far wall
for x in range(-286, -226, 12):  # the river tunnel's brick vault
    A.card([(x, RIV_B), (x + 1.2, RIV_B), (x + 1.2, T0C), (x, T0C)], z=-2.0, tone="brick")
for x0, x1, y in CROWN:  # the aqueduct's piers stand BEHIND the race, so the water runs past them
    xm = (x0 + x1) / 2
    A.card([(xm - 1.0, RB), (xm + 1.0, RB), (xm + 1.0, y - 0.6), (xm - 1.0, y - 0.6)], z=-1.2, tone="brick")
    A.deco("brick_arch", xm, y - 0.5, z=-1.2, size=(3.4, 1.4, 1.0), tone="brick")
A.deco("water_wheel_frame", WHEEL[0], WHEEL[1], z=-1.0, size=(4.6, 6.0, 0.6), tone="wood")
A.deco("iron_bracket", -254.3, 92.4, z=-0.6, size=(5.7, 0.5, 0.4), tone="iron")  # what P1 hangs from
A.card([(-268, T0C), (-256, T0C), (-256, 176), (-268, 176)], z=-1.5, tone="#2F5F5A")  # El Desague, a verdigris pipe as wide as a house
A.card([(-266.5, FUN), (-257.2, FUN), (-257.2, WINC), (-266.5, WINC)], z=-1.4, tone="back3")  # its broken window
# The Charco's back card: the well read as endless. A tall dark slot and one small pale dot.
A.card([(-305, 115), (-295, 115), (-296.5, 128), (-303.5, 128)], z=-5.0, tone="#04070A")
A.card([(-303.5, 128), (-296.5, 128), (-297.5, 176), (-302.5, 176)], z=-5.0, tone="#04070A")
A.card([(-300.25, 125.6), (-299.75, 125.6), (-299.75, 126.1), (-300.25, 126.1)], z=-4.9, tone="#DDF2EC", edge=False)
for x in (-316, -308, -292):  # the pool hall's arches
    A.deco("brick_arch", x, 124.5, z=-2.5, size=(7.0, 7.0, 1.0), tone="brick")
A.card([(-449.5, 150), (-425, 150), (-425, 152), (-440, 167), (-449.5, 167)], z=-1.0, tone="brick")  # the dam's flank
A.deco("pug_stamp", -444.5, 160.0, z=-0.9, size=(3.0, 3.0, 0.1), tone="accent")  # the First Top Dog, cast in the dam
A.deco("valve_wheel", -349.3, 120.0, z=-0.4, size=(0.9, 0.9, 0.2), tone="accent")
A.deco("boiler", -353.0, 119.0, z=-2.2, size=(5.0, 6.0, 3.0), tone="iron")
A.deco("papel_tatters", -278.0, 125.0, z=-1.0, size=(10.0, 0.8, 0.05), tone="accent")  # the works' bunting, rotted
for x, y, r in ((-229, 94.4, 9), (-248, 93.2, 9), (-272, 94.6, 11), (-254.5, 101.5, 9), (-240, 105.6, 10), (-228, 105.2, 9),
                (-239, 113.9, 10), (-252.5, 124.0, 10), (-262, 126.5, 11), (-278, 124.6, 10), (-289, 121.0, 11),
                (-317.5, 121.0, 11), (-333, 120.8, 10), (-347, 121.5, 10), (-356, 127.5, 11), (-366, 133.0, 11),
                (-376, 139.5, 10), (-382, 141.5, 10), (-389.5, 155.5, 11), (-408, 156.5, 11), (-422, 156.5, 10),
                (-431, 160.0, 10), (-438.5, 168.0, 10), (-447, 171.0, 11)):
    lamp(x, y, r)
A.light(-300, 121.0, color="#DDF2EC", rng=14.0, energy=0.9, z=-2.0)  # the well's far daylight on the pool
A.effect("waterfall", (-244, 84, -238, RIV_S))  # over the lip
A.effect("waterfall", (-288, RIV_S, -284.5, 115))  # the first cascade
A.effect("waterfall", (-380.6, 116, -379, 136))  # the spill into the pipe hall
A.effect("waterfall", (-392, 136, -389.5, 151))  # LA CASCADA CHICA
A.effect("waterfall", (-430, 152, -425.5, 166), density=0.4)  # the dam's leak
A.effect("mist", (-392, 134.5, -380, 156))
A.effect("mist", (-292, 89, -280, 98))
A.effect("mist", (-250, 86, -234, 94))
A.effect("drips", (-232, 90, -226, T0C))  # the race's drain drips on the lip ledge
A.effect("drips", (-320, 115, -286, 128))
A.effect("steam", (-378, 118, -348, 140), density=0.5)


# ================================================================ THE ROCK: the region minus the air
def build_rock():
    shell = Polygon([(-465, 83), (-292, 83), (-292, 86), (-223, 86), (-223, 176), (-465, 176)])
    rock = shell.difference(unary_union(AIR))
    todo = list(rock.geoms) if rock.geom_type == "MultiPolygon" else [rock]
    done = []
    while todo:
        p = todo.pop()
        if p.geom_type != "Polygon" or p.area < 0.05:
            continue
        x0, y0, x1, y1 = p.bounds
        cx = None
        if len(p.interiors):
            cx = round(p.interiors[0].centroid.x, 1)
        elif x1 - x0 > 30.0:
            cx = round((x0 + x1) / 2, 0)
        if cx is None or not (x0 + 0.05 < cx < x1 - 0.05):
            done.append(p)
            continue
        for half in (sbox(x0 - 1, y0 - 1, cx, y1 + 1), sbox(cx, y0 - 1, x1 + 1, y1 + 1)):
            g = p.intersection(half)
            todo.extend(g.geoms if hasattr(g, "geoms") else [g])
    for p in done:
        A.solid(list(p.simplify(0.005).exterior.coords)[:-1], "wet")


build_rock()

if __name__ == "__main__":
    A.save()
