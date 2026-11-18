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
import a2_dress  # the black waters' scenery (the modelling run's): decos only

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


def slab(x0, x1, y, kind="stone", t=0.7, skin=None):
    """A hanging platform: a slick body with a grip top (a pale stone coping, like every
    place you stand in the works). Water runs under it. skin: the body's painted piece."""
    A.solid([(x0, y - t), (x1, y - t), (x1, y - 0.2), (x0, y - 0.2)], "wet", skin=skin)
    A.ledge(x0, x1, y, kind, t=0.3)
# (The works' lanterns are a2_dress's, on the walls, out of the play space; their steady
# lights are placed with the dress, at the end. Note 17: nothing in this biome's light pulses.)


# ================================================================ THE LOWER RIVER AND THE LIP
# A1's roof slab is y 86..90 under the lip, so the bed lies ON it: bed 90, surface 91.0.
# The slot (x -244..-238) and the dry shaft (x -236..-232) go down through that roof to A1.
RIV_B, RIV_S = 90.0, 91.0
T0C = 96.0  # the river tunnel's roof
air([(-288, RIV_B), (-244, RIV_B), (-244, 84), (-238, 84), (-238, 91.5), (-236, 91.5), (-236, 84), (-232, 84),
     (-232, 89.7), (-226, 89.7), (-226, T0C), (-288, T0C)])
A.opening(-244, 85, -238, 89)  # the waterfall's slot
A.opening(-236, 85, -232, 91)  # the dry shaft from the mine
A.solid([(-238, 91.5), (-236, 91.5), (-237, 92.2)], "wet", skin="aguas_borde_pier")  # the pier's peaked top: sheds both ways
cap(-232, -226, 90.0)  # THE LIP LEDGE (entry). The pier keeps the river (1 m higher) off it
# (The small slick patches that stood on this area's rest ledges are gone, every one. Parker 11-12: "remove them all they feel like bugs".)
A.water((-288, RIV_B, -252, RIV_S), RIV_S, flow=(2.2, 0.0))
A.water((-252, RIV_B, -244, RIV_S), RIV_S, flow=(2.4, 0.0))  # it quickens at the lip

# ---------------------------------------------------------------- 2.1 El Borde
PY = 94.5  # the pipes: a body hanging from them (2.1 m) clears the pier's peak
A.beam((-229.5, 92.0), (-233.5, PY), 0.3, "paint")  # up from the ledge
# (Parker 11-12: "make these dark parts breakable pieces". The two 1.5 m stretches were
# grease: dark, slick, a hand on them held nothing. Dark on a dark cave did not say
# "slippery". They are iron rusted through now: you can take one, and a second later it
# snaps and falls in the river, and is back 8 s after. So each is a stepping stone if you
# keep moving, and the 1.5 m lunge again if you break it and wait.)
for x0, x1, k in ((-237.5, -233.5, "paint"), (-239.0, -237.5, "rusty"), (-242.5, -239.0, "paint"),
                  (-244.0, -242.5, "rusty"), (-253.0, -244.0, "paint")):
    A.beam((x0, PY), (x1, PY), 0.3, k)
A.rope("last_chance", (-246.6, PY - 0.2), 2.5, kind="chain")  # THE ONE MERCY: its end 0.8 m over the water. (At 0.3 m a limp body drifting under it was caught without trying: tests/peak_drop. It has to be reached for.)
A.challenge("2.1", "El Borde", (-229.0, 90.0), 2, "X",
            moves=[["reach", [-229.5, 90.2], [-229.5, 92.0]],
                   ["reach", [-237.5, PY], [-239.0, PY]], ["reach", [-242.5, PY], [-244.0, PY]]])
slab(-257.2, -251.5, 92.9, "stone", t=0.4, skin="aguas_borde_landing")  # P1: the landing, hung from the works above
Q1Y = 98.6
A.beam((-257.0, 92.9), (-257.0, Q1Y + 0.8), 0.3, "iron")  # the ladder up the well to the race

# ================================================================ THE MILL (x -257..-226), three floors
RB, RS = 96.8, 98.2  # the race: bed, surface
L1C = 107.4
airbox(-257.2, T0C - 0.1, -255.4, L1C)  # the ladder well
air([(-255.4, Q1Y - 0.3), (-253.5, Q1Y - 0.3), (-253.5, RB), (-226, RB), (-226, L1C), (-255.4, L1C)])
airbox(-229, T0C - 0.1, -226, RB + 0.1)  # the race's drain: it drops you on the lip ledge
cap(-255.4, -253.5, Q1Y, "stone")  # Q1
A.water((-253.5, RB, -229, RS), RS, flow=(1.4, 0.0), look="race")

# ---------------------------------------------------------------- 2.2 La Rueda
WHEEL = (-251.3, 100.8)
A.wheel("rueda", WHEEL, 2.0, -4.0, spokes=6, kind="wood", hub=0.45, model="mill_wheel")
A.challenge("2.2", "La Rueda", (-254.4, Q1Y), 2, "B")

# ---------------------------------------------------------------- 2.3 El Acueducto
CROWN = [(-249.1, -246.1, 101.4), (-243.1, -240.1, 101.8), (-236.3, -233.6, 102.2), (-228.5, -226.0, 102.6)]
for k, (x0, x1, y) in enumerate(CROWN):
    A.solid([(x0, y - 0.9), (x1, y - 0.9), (x1, y), (x0, y)], "brick", skin="aguas_trough_stump_%d" % (k + 1))
moves23 = []
for i, (x0, x1, y) in enumerate(CROWN[:3]):
    out = 1.6 if i < 2 else 1.3
    ra, rb = (x1 + 0.35, y + 1.95), (x1 + out, y + 2.3)  # the near ring, the launch ring
    A.hold(*ra, r=0.2, kind="iron", skin="aguas_ring_eyebolt")
    A.hold(*rb, r=0.22, kind="iron", skin="aguas_ring_eyebolt")
    for rr in (ra, rb):  # (a2_dress item 7: each ring on an eye bolt back to its plate, z -1.25; the ring 0.2 under the bolt)
        A.deco("aguas_ring_eyebolt", round(rr[0], 3), round(rr[1] + 0.2, 3), z=-1.25, size=(0.45, 0.45, 1.25), tone="iron", skin=True)
    # (note 18: the chains the rings hung on are gone)
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
cap(-230.8, -227.8, Q2Y, "stone")  # Q2
cap(-249.2, -246.6, Q3Y, "stone")  # Q3
A.water((-246.6, MB, -232.6, MS), MS, flow=(1.1, 0.0), look="race")
A.beam((-229.5, Q2Y + 2.0), (-236.6, Q2Y + 2.0), 0.3, "paint")  # hand over hand out over the drain, then drop in
for y in (MS + 0.5, MS + 1.3):
    A.hold(-246.5, y, r=0.2, kind="iron")  # "the ladder"
# Three drowned rungs under them, green and bent, under the water (page 2.4): held, as the
# ladder's are. They wear rung_iron_rusted (its origin the middle of its top, 0.83 wide).
for y in (109.5, 109.1, 108.7):
    A.beam((-246.6, y - 0.05), (-246.3, y - 0.05), 0.1, "iron", skin="rung_iron_rusted")
    A.deco("rung_iron_rusted", -246.45, y, z=0.0, size=(0.83, 0.57, 0.25), tone="iron", skin=True)
A.challenge("2.4", "Brazo de Molino", (-228.6, Q2Y), 3, "B")

# ---------------------------------------------------------------- 2.5 Las Compuertas
WINC = 128.6
GT, GH = 3.2, 3.4  # a gate's travel, its height
GATES = ((-250.28, Q3Y), (-252.4, Q3Y + 3.0), (-254.52, Q3Y + 6.0))  # centre x, top when down
Q4Y = GATES[2][1] + GT  # 121.0
air([(-255.6, GATES[2][1] - GH), (-253.45, GATES[2][1] - GH), (-253.45, GATES[1][1] - GH), (-251.35, GATES[1][1] - GH),
     (-251.35, MB), (-249.2, MB), (-249.2, WINC), (-255.6, WINC)])
# EACH GATE IS A PISTON (note 19; page 2.5): a fixed iron housing, 1 m tall, black with oil and
# slick, on its step where the block rested; the head (the riveted plate you hold) on a ram as
# wide as it rises out of it and slams back. The mover is the head and its ram (aguas_ram_head);
# the housings wear aguas_ram_housing (placed here).
# THE RAM IS SOLID AS FAR AS IT IS DRAWN (note 113: its drawing is 5.6 m long and its solid was 3.4, so a
# raised ram's lowest 2.2 m could be walked into, and its slam left you inside it for good). The extra runs down
# into the housing, as the drawing does.
RAM = 5.6
for i, (cx, low) in enumerate(GATES):
    A.mover("compuerta%d" % (i + 1), (cx, low),
            [(box_pts(0, -RAM / 2, 2.05, RAM), "grease"), (box_pts(0, -0.12, 2.05, 0.24), "iron")],
            {"type": "cycle", "to": [0, GT], "t_out": 1.8, "hold_out": 2.0, "t_in": 0.4, "hold_in": 2.0,
             "phase": 3.1 if i == 1 else 0.0}, model="aguas_ram_head")
    step = low - GH
    A.solid([(cx - 1.025, step), (cx + 1.025, step), (cx + 1.025, step + 1.0), (cx - 1.025, step + 1.0)], "grease",
            skin="aguas_ram_housing")
    A.deco("aguas_ram_housing", cx, step, z=0.0, size=(2.05, 1.0, 2.0), tone="iron", skin=True)
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
cap(-258.2, -255.6, Q4Y, "stone")  # Q4
cap(-284, -271.2, Q4Y, "stone")  # Q5, the gallery

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
# NOTE 146: THE GREAT FALLS COME DOWN THROUGH THE HALL (one 6 m shaft, x -303 .. -297, from the well to the
# Sump: Parker 11-14). Where they hit, the reservoir's floor has broken and they pour on down a shaft cut
# through the black waters' floor, to La Esclusa and the mine. The pool is cut in two: its west half, fed by
# the flume from 2.8, runs east and pours over a sill into the falls; its east half is a basin under Q6
# that still runs to the old cascade and El Borde's river (a fall beside the falls lands in one or the other).
FALLS = (-303.0, -297.0)
airbox(FALLS[0], 83.0, FALLS[1], 113.2)  # the falls' shaft through the floor (the rock there is cut on purpose)
A.water((-320.5, 113, -306.0, CS), CS, flow=(1.0, 0.0), look="pool")       # the west pool, running east
A.water((-306.0, 113, -303.4, CS), CS, flow=(1.6, 0.0), look="pool")       # quicker at the sill (FIRST GUESS)
A.water((-296.6, 113, -288, CS), CS, flow=(1.0, 0.0), look="pool")         # the east basin, on to the old cascade
# (The two sills are slick: the pool is meant to make you swim at once, not hang on 0.3 m under the water. THE
# DIRECTOR'S CALL, 11-15, for Parker to reverse if he wants a last catch there.)
A.solid([(-303.4, 113.0), (-303.0, 113.0), (-303.0, CS - 0.3), (-303.4, CS - 0.3)], "wet")  # the pool's lip sill, on the falls
A.solid([(-297.0, 113.0), (-296.6, 113.0), (-296.6, CS - 0.3), (-297.0, CS - 0.3)], "wet")  # the east basin's sill
# Q6, carried 6 m west to the falls' edge on more iron beams: its west end THE LAUNCH LEDGE, flush with the
# falls (so the throw stays inside F2). Plain until its re-made skin: the old one was 7 m.
slab(-297.0, -284, 117.4)  # Q6, over the cascade's lip and the east basin
slab(-320.5, -314, 117.2, t=0.7, skin="aguas_charco_landing_west")  # Q7, the west bank (as today)
for _y in (115.45, 116.25):  # Q7's two rungs up out of the pool (the swim's end)
    A.solid([(-314.45, _y - 0.07), (-313.95, _y - 0.07), (-313.95, _y + 0.07), (-314.45, _y + 0.07)], "iron")
# The gantry's two chains over the west pool, their tails 0.6 m over the water: the swim's two holds.
A.rope("cadena_salto1", (-306.8, 121.8), 6.2, kind="chain")
A.rope("cadena_salto2", (-310.6, 121.8), 6.2, kind="chain")
# THE FROG'S ROOM (page 2.0; Parker 11-13, settled): a small room cut into the brick east
# of Q6, 3 m wide, its round vault 1.5 m over the floor's springing, its floor the ledge's
# coping running on as a worn sill. Its back, vault, door and things are the dress's.
_vault = [(-282.5 + 1.5 * math.cos(math.radians(a)), 118.5 + 1.5 * math.sin(math.radians(a))) for a in range(0, 181, 20)]
air([(-284.0, 117.1), (-281.0, 117.1)] + _vault)
cap(-284.2, -281.0, 117.4, "stone")

# ---------------------------------------------------------------- 2.7 El Salto de la Cascada (note 146)
# (The barrels moved to 1.12 Los Barriles, in La Esclusa under the black waters, running west.) From the
# launch ledge, hanging by your hands, swing out and let go over the falling water into the west pool:
# 6.6 to 9.0 m across, 2.4 m down, F2. The moment you land you swim, or it takes you back over the sill.
A.challenge("2.7", "El Salto de la Cascada", (-287.0, 117.4), 3, "X", moves=[
    ["fling", [-297.0, 117.4], [-304.6, CS], "F2"],
    ["swim", [-306.8, 115.8], [-310.6, 115.8]], ["swim", [-310.6, 115.8], [-314.2, 116.25]],  # (swims: against 1 m/s, as today's two)
    ["reach", [-314.2, 116.25], [-314.5, 117.2]]])

# ================================================================ THE FLUME AND THE PIPE HALL
FS = 116.0  # flume and tail pool surface (bed 114.5)
airbox(-346, 114.5, -320.5, 122.5)  # the flume
airbox(-380, 114.5, -346, 142)  # the pipe hall, over the tail pool
slab(-325, -320.5, 118.0, t=0.5, skin="aguas_flume_landing")  # Q8: the way in, over the flume's foot
A.water((-380, 114.5, -346, FS), FS, flow=(1.4, 0.0))  # the tail pool
A.water((-346, 114.5, -320.5, FS), FS, flow=(1.5, 0.0), look="flume")  # the flume: hard (the swim tops out at 2.0 m/s: tests/peak_swim_probe)
# The eddies behind the three pillars. Not quite still (0.3 m/s): rest, but keep a hand moving.
PILLARS = (-325.0, -330.5, -336.0)
for px in PILLARS:
    A.water((px - 2.5, 114.5, px, FS), FS, flow=(0.3, 0.0), look="eddy")
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
# (the pipe between the joints is the dress's lagged steam pipe, at the back)

# ================================================================ LA CASCADA CHICA
PS = 136.0
airbox(-392, 134.5, -380, 158)  # the pool's hall
A.water((-392, 134.5, -380, PS), PS, flow=(1.0, 0.0), look="pool")
slab(-385, -378, 138.0, t=0.5, skin="aguas_cascada_landing")  # Q10, over the spill's lip
WET = [(-385.6, 139.4), (-386.7, 140.5), (-387.9, 141.5), (-388.8, 142.8), (-388.0, 150.0), (-389.2, 151.1), (-390.4, 152.2)]
for i, p in enumerate(WET):
    A.hold(p[0], p[1], r=0.24, kind="rock", skin="aguas_tread_end",
           hold={"type": "wet", "on": 1.6, "off": 3.4, "phase": (i * 1.0) % 5.0})
    # (a2_dress item 7: the free end of a stone tread; its root running back into the wall is the dress's)
    A.deco("aguas_tread_end", p[0], p[1], z=0.0, size=(0.55, 0.4, 0.3), tone="stone", skin=True)
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
# MOSTLY BREAKABLE FLOOR (Parker 11-12: "make this area out of mostly breakable floor.
# There is only one breakable thing here"). It was five slabs of solid iron and one plank
# that broke: 2 m in 34. Now 22 m of it breaks, in pieces about 2 m long, rusted through.
# What stays solid: a landing at each end and two rest plates. The three 1.3 m gaps stay.
# A piece gives way FLOOR_T after the first hand or foot is on it and is back 8 s later.
# FLOOR_T is from a measurement, not a guess: a climber crawls a level floor at up to
# 1.1 m/s and is about 1.6 m from leading hand to trailing foot, so it is wholly off a
# 2.1 m piece 3.3 s after first touching it. 3.4 s: move briskly and you are across; stop
# and it drops you in the river, which runs back to the lip of La Cascada Chica.
FLOOR_T = 3.4


def weak(x0, x1):
    A.ledge(x0, x1, 153.0, "rusty", t=0.3, hold={"type": "crumble", "t": FLOOR_T, "respawn": 8.0})


slab(-393.5, -391.5, 153.0, "iron", t=0.4)                  # the landing at the top of the cascade
for k in range(5):
    weak(-404.0 + 2.1 * k, -404.0 + 2.1 * (k + 1))          # x -404 .. -393.5
slab(-407.3, -405.3, 153.0, "iron", t=0.4)                  # a rest plate
weak(-409.3, -407.3)                                        # (it was the one plank that creaked)
weak(-411.5, -409.3)
slab(-414.8, -412.8, 153.0, "iron", t=0.4)                  # a rest plate
weak(-416.65, -414.8)
weak(-418.5, -416.65)
weak(-421.7, -419.8)
weak(-423.6, -421.7)
slab(-425.5, -423.6, 153.0, "iron", t=0.4)                  # the landing on the dam's apron

# ================================================================ LA PRESA
# (Note 25, Parker 11-13: "replace this area with one elevator platform and the spiney which is
# attached to it so you have to stand in the elevator and spin the winch"; settled: it goes
# straight up in a shaft, and it always sinks when you stop winding.) The design page
# (design/a2/2_11_la_presa.html): a gallery through the dam's foot from the apron, 7.8 m
# long and 2.6 m tall, to a shaft 2.6 m wide straight up inside the dam to the hall's roof;
# in it one cage, its deck 2 m wide, its winch on its back frame 1.5 m over the deck. It
# rises from the apron's level (152.2) to the crest's (167.0) while you wind, and sinks when
# you stop. The spillway's steps stay, without their platforms and cranks: nobody climbs
# them now. (The cage and the winch are plain stand-ins until their models land.)
X1, R1, STEP, RISE = -429.6, 152.5, 2.6, 2.9
dam = [(-425.5, 151.9), (X1, 151.9)]
for k in range(1, 5):
    dam += [(X1 - (k - 1) * STEP, R1 - 0.3 + k * RISE), (X1 - k * STEP, R1 - 0.3 + k * RISE)]
dam += [(-440, 166.7), (-449, 166.7), (-449, 163), (-459, 163), (-459, 173), (-440, 173), (-440, 170), (-425.5, 170)]
air(dam)
airbox(-456, 172.9, -449, 181)  # the exit
SHAFT_X0, SHAFT_X1 = -440.0, -437.4
airbox(SHAFT_X1, 151.9, X1, 154.8)  # the inspection gallery, through the dam's foot
airbox(SHAFT_X0, 151.9, SHAFT_X1, 170.0)  # the lift shaft, straight up inside the dam
A.opening(-456, 175, -449, 181)
cap(X1, -425.5, 152.2)  # Q11, the apron
cap(SHAFT_X1, X1, 152.2)  # the gallery's floor: the apron's coping, on into the dam
A.box(SHAFT_X1 + 0.3, (160.9 + 170.0) / 2, 0.6, 170.0 - 160.9, "wet", skin="aguas_shaft_wall")  # the shaft's east wall, from the third step to the roof
cap(-449, -440, 167.0)  # the dam's crest
A.water((-459, 163, -449, 166.2), 166.2, flow=(0.0, 0.0), look="lake")
A.beam((-449.5, 168.6), (-449.5, 178.2), 0.35, "iron")  # the rungs out, up through the roof
# The cage: its deck (its top at the mover's point) and its top bar, 2.2 m up, both held as
# they are in the play space. 0.6 m a turn: about 25 turns from the apron to the crest.
CAGE_X = (SHAFT_X0 + SHAFT_X1) / 2
A.winch_lift("jaula", (CAGE_X, 152.2), [(box_pts(0, -0.1, 2.0, 0.2), "plank"), (box_pts(0, 2.2, 2.0, 0.12), "iron")],
             rise=(0.0, 167.0 - 152.2), winch_at=(0.45, 1.5), r=0.35, per_turn=0.6, fall=0.3, model="aguas_winch_cage")
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
# (The far wall, the tunnel's brick strips, the aqueduct's pier cards and arches, El Desague's
# card and window, the well's slot and dot, the pool hall's arches, the dam's flank, the
# wheel's frame, P1's bracket, the dam's stamp, the boiler and the bunting are gone: the
# dress places what takes their places, out of the play space.)
A.deco("valve_wheel", -349.3, 120.0, z=-0.4, size=(0.9, 0.9, 0.2), tone="accent")  # the first cool joint's look
A.deco("valve_wheel", -377.6, 136.6, z=-0.4, size=(0.9, 0.9, 0.2), tone="accent")  # and the last's (page 2.9)
A.light(-300, 121.0, color="#DDF2EC", rng=14.0, energy=0.9, z=-2.0)  # the well's far daylight on the pool
A.effect("waterfall", (-244, 89.4, -238, RIV_S), through=True)  # over the lip, onto the lock's flap (La Esclusa, a1, carries it on down its back wall)
A.effect("waterfall", (-232.6, RS, -230.8, MS), density=0.6)  # the mill channel's drain, into the race (note 22)
A.effect("waterfall", (-229.0, 90.0, -226.0, RS), density=0.5)  # the race's drain, onto the lip ledge
A.effect("waterfall", (-320.5, 115.0, -318.6, 116.0))  # the flume spills a metre into the pool (El Charco del Pozo)
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
    # THE SEAM WITH A1: a1's roof slab is solid from y 86 to 90 under the lip, the pier and the
    # bed's east end; this shell overlapped it, two areas' slabs and skins on one strip. The
    # strip under 89.4 (a1's roof rebate) is a1's now.
    rock = rock.difference(sbox(-252.0, 86.0, -223.0, 89.4))
    # The skins (a2_dress FOR THE AREA FILE item 5): the rock cut by SKIN_REGIONS in order, a
    # part taken once, each part split as before and every slab of it wearing that region's piece.
    taken = None
    for stem, poly in a2_dress.SKIN_REGIONS + [(None, None)]:
        if stem is None:
            part = rock.difference(taken)
            if part.area > 0.05:
                print("  note: %.2f m2 of rock outside the dress's regions (no skin)" % part.area)
        else:
            reg = Polygon(poly)
            part = rock.intersection(reg) if taken is None else rock.intersection(reg).difference(taken)
            taken = reg if taken is None else taken.union(reg)
        _cut(part, stem)


def _cut(rock, skin):
    todo = list(rock.geoms) if hasattr(rock, "geoms") else [rock]
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
        A.solid(list(p.simplify(0.005).exterior.coords)[:-1], "wet", skin=skin)


build_rock()

# THE PITS' INSIDES CAN'T BE HELD (note 52; Parker 11-13: all the slots the check finds,
# `python tools/peak/checks.py pits`): each inside face lined slick under its lip.
A.line_pit(-405.30, -404.00, 153.00)
A.line_pit(-412.80, -411.50, 153.00)
A.line_pit(-419.80, -418.50, 153.00)

# Each chain ends at the top in a shackle (a2_dress item 7).
for x, y in ((-258.9, WINC), (-265.3, WINC), (-269.3, WINC), (-344.45, 117.6), (-246.6, PY - 0.2)):
    A.deco("aguas_chain_shackle", x, y, z=0.0, size=(0.3, 0.4, 0.3), tone="iron")

# ================================================================ the dress (the modelling run's)
a2_dress.dress(A)
# (note 146: the barrels' cove and Q6's old 7 m skin go with the barrels: Q6 is 13 m now, plain until re-made)
A.decos[:] = [d for d in A.decos if d["model"] not in ("aguas_barrel_cove", "aguas_charco_landing_east")]
# (the quality run's clean-up: the worst 30's plain beam ends, nothing needs them)
A.drop_decos({"aguas_beam_end", "aguas_beam_end_long"})
# (11-18, La Esclusa's floor maker: the pier and the east wall were made down to y 86, the old mine's roof; since note
# 146 their last 3.4 m hung into the lock under them and hid its top rung. Cut level at their solids' foot, y 89.4.)
for _d in A.decos:
    if _d["model"] in ("aguas_borde_pier", "aguas_east_wall"):
        _d["cut_below"] = 89.4
# (a2_dress item 8: the grey wheel behind La Rueda turns with it on the same axle; each gate's
# leaf rides with its ram)
A.follow("aguas_mill_wheel_grey", WHEEL, "rueda", "spin")
for i, (cx, low) in enumerate(GATES):
    A.follow("aguas_gate_leaf", (cx, low - GH), "compuerta%d" % (i + 1), "ride")
for x, y in a2_dress.LANTERN_LIGHTS:  # every lantern's steady light (note 17)
    A.light(x, y, color=TEAL, rng=10.0, energy=1.5, flicker=False)
A.light(-452.5, 175.0, color="#B6A2E6", rng=8.0, energy=0.9)  # the join: soft violet, down the exit shaft
A.light(-442.0, 172.6, color="#F2F6FF", rng=6.0, energy=1.0)  # the bright crystal over the crest


# THE INSIDE'S OWN DARK (the Director, 11-14): the mountain's body card is cut away over this biome
# (st.py BODY_WINDOWS); behind the far wall a backstop in this biome's darkest tone, so no gap shows
# the body's grey-tan, or the sky.
A.card([(-472, 76), (-216, 76), (-216, 194), (-472, 194)], z=-11.6, tone="back3", edge=False)

if __name__ == "__main__":
    A.save()
