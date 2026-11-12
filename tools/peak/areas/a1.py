"""
A1 LA MINA VIEJA: the old mine. The waterfall cavern, from the cart tunnel's door
(-152, -12.6) to the dry shaft in the roof (x -236..-232, y 86..90).
  python tools/peak/areas/a1.py

The room, east to west:
  - the EAST MASS (x -176..-152): the entry gallery (1.1) bored through it at y -12.6,
    the ladder shaft (1.2) up through it to its top at y 6;
  - the CATWALK (1.3) and the rope (1.4) at y 6, west over the Sump's east basin;
  - EL DIENTE, the pillar (x -208.9..-197.9), standing on an arch in the Sump: the lift
    (1.5) and the banded wall (1.6) go up its east face, the cart (1.7) runs off its top;
  - the open water west of it, under the chains, Las Vigas (1.8) and the fall;
  - the UPPER WORKS in the rock east of the fall's throat: the winding wheel (1.9), the
    upper gallery, the cave-in shaft (1.10), the top drift;
  - the THROAT (x -248..-230, y 55..86): the fall's last 30 m, and La Cortina (1.11).
The fall line (x -244..-238) is empty from the roof slot to the water.

How the rock is made here: the AIR is drawn (a handful of polygons), and the rock is
everything within 4 m of it that isn't air, cut into convex slabs of slick `wet`. Every
grip surface is a separate solid laid 0.3 m proud of that skin, so grip is only ever
where it was put on purpose.
"""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from peaklib import Area, box_pts, ngon

A = Area("a1", "mine")

# ================================================================ the air
FALL_X0, FALL_X1 = -244.0, -238.0  # the waterfall's line (the slot in the roof)
SUMP_Y = -28.0  # the Sump's surface
XF = -201.9  # the pillar's east face (the lift, the banded wall)

CHAMBER = [
    (-248.0, -33.0), (-192.0, -33.0),  # the Sump's floor
    (-188.0, -28.3),  # the beach's toe, under water
    (-176.0, -12.9),  # the bed of the walk of shame, up to the gallery's mouth
    (-176.0, 5.7),  # the east mass's west face
    (-168.0, 5.7),  # its top: the ledge at the ladder's head, then the shaft's mouth
    (-152.0, 17.3),  # a slick slope (36 deg) that pours back into the ladder shaft
    (-152.0, 30.0), (-180.0, 44.0), (-196.0, 55.0),  # the east wall and the roof coming down
    (-230.0, 55.0),  # the chamber's roof: Las Vigas hang under it
    (-230.0, 86.0), (-248.0, 86.0),  # the throat: its east wall, its roof
]
PILLAR = [(-208.9, -25.5), (-197.9, -25.5), (-197.9, 5.7), (XF, 5.7), (XF, 39.7), (-208.9, 39.7)]
GALLERY = [(-176.0, -12.9), (-165.5, -12.9), (-162.0, -17.2), (-160.0, -17.2), (-155.5, -12.9),
           (-152.0, -12.9), (-152.0, -7.5), (-176.0, -7.5)]  # 1.1, with its mud pit
SHAFT = [(-172.0, -7.6), (-168.0, -7.6), (-168.0, 5.8), (-172.0, 5.8)]  # 1.2
UPPER = [(-230.0, 57.1), (-218.5, 57.1), (-218.5, 77.0), (-222.1, 77.0), (-222.1, 62.0), (-230.0, 62.0)]  # upper gallery + 1.10
DRIFT = [(-230.0, 71.7), (-222.1, 71.7), (-222.1, 76.0), (-230.0, 76.0)]  # the top drift
DOOR = [(-152.0, -12.9), (-148.0, -12.9), (-148.0, -7.5), (-152.0, -7.5)]  # through the east wall, to A0
SLOT = [(FALL_X0, 86.0), (FALL_X1, 86.0), (FALL_X1, 90.0), (FALL_X0, 90.0)]  # the fall comes in here
EXIT = [(-236.0, 86.0), (-232.0, 86.0), (-232.0, 90.0), (-236.0, 90.0)]  # the dry shaft out, to A2
# A2's lip ledge (grip, top y 90, x -232..-226) lies on this roof. The roof is rebated 0.6 m
# under it and floored with grip of its own (top y 89.7, see 1.11), so A2's ledge never
# shares a face with slick, and the way out is grip even before A2's ledge is there.
LIP_REBATE = [(-232.0, 89.4), (-225.5, 89.4), (-225.5, 90.0), (-232.0, 90.0)]
THICK = 4.0  # so the roof slab is y 86..90, flush with A2's lip ledge
# Solid through and through (no hollow behind the skin): the east mass, the upper works.
FILLS = [[(-192.0, -37.0), (-148.0, -37.0), (-148.0, 21.3), (-176.0, 9.0), (-180.0, -8.0)],
         [(-234.0, 55.0), (-214.5, 55.0), (-214.5, 81.0), (-226.0, 90.0), (-234.0, 90.0)]]


def carve():
    """The rock: everything within THICK of the air that isn't air, as convex slabs."""
    from shapely.geometry import Polygon, box
    from shapely.ops import unary_union
    main = unary_union([Polygon(CHAMBER).difference(Polygon(PILLAR))] +
                       [Polygon(p) for p in (GALLERY, SHAFT, UPPER, DRIFT)])
    assert main.geom_type == "Polygon", "the air is in pieces"
    hull = unary_union([main.buffer(THICK, join_style=2)] + [Polygon(p) for p in FILLS])
    hull = Polygon(hull.exterior)  # no pockets inside the rock
    rock = hull.difference(unary_union([main] + [Polygon(p) for p in (DOOR, SLOT, EXIT, LIP_REBATE)]))
    xs = sorted({round(x, 3) for g in getattr(rock, "geoms", [rock])
                 for ring in [g.exterior] + list(g.interiors) for x, _ in ring.coords})
    y0, y1 = rock.bounds[1] - 1, rock.bounds[3] + 1
    pieces = []
    for xa, xb in zip(xs, xs[1:]):
        if xb - xa < 1e-4:
            continue
        band = rock.intersection(box(xa, y0, xb, y1))
        for g in getattr(band, "geoms", [band]):
            if g.geom_type == "Polygon" and g.area > 1e-3:
                pieces.append(g)
    merged = True
    while merged:  # glue neighbours while the result stays convex
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
    for p in pieces:
        pts = list(p.simplify(1e-4).exterior.coords)[:-1]
        A.solid(pts, "wet")


carve()
A.opening(-153, -13, -151, -7)  # the door from the cart tunnel (A0)
A.opening(FALL_X0, 85, FALL_X1, 91)  # the waterfall's slot (A2's river pours through)
A.opening(-236, 85, -232, 91)  # the dry shaft out (A2's lip ledge is at its top)

# ================================================================ the fall and the Sump
A.water((-248.0, -33.0, -187.4, SUMP_Y), SUMP_Y, flow=(0.0, 0.0))
# The falling water beats a climber down. It stops 6 m over the pool so nobody is pinned under.
A.wind((FALL_X0, -22.0, FALL_X1, 90.0), (0.0, -6.0))
A.effect("waterfall", (FALL_X0, SUMP_Y, FALL_X1, 90.0))
A.effect("mist", (-250.0, -30.0, -230.0, -17.0), density=0.8)
A.effect("mist", (-240.0, 62.0, -230.5, 90.0), density=0.4)

# The walk of shame: a grip incline with sleepers, from the landing stage up to the gallery.
A.patch((-175.8, -12.64), (-189.4, -30.1), "rock2", t=0.7)
for y in (-14.8, -17.0, -19.2, -21.4, -23.6, -25.8):
    x = -176.0 - (-12.9 - y) / 1.2833
    A.box(x - 0.25, y + 0.42, 1.1, 0.3, "wood")
A.ledge(-190.4, -187.0, -27.7, "plank", t=0.3)  # the landing stage, a hand above the water
for x in (-228.5, -219.0, -211.0, -194.5):
    A.box(x, -30.1, 0.4, 5.8, "wood")  # old staging piles: something to hold on the long swim east

# ================================================================ 1.1 La Galeria
# Grip floor from the door; then the floor falls away into black mud. Over it: three low
# roof beams, four posts standing in the mud, two more beams. Slip and you are in the pit
# (grip bottom, 4.3 m down); posts P2 and P3 stand in it and climb back out.
A.ledge(-148.0, -155.5, -12.6, "rock2", t=0.5)  # (it runs through the door frame to meet A0's floor)
A.ledge(-165.5, -176.0, -12.6, "rock2", t=0.5)
A.ledge(-160.0, -162.0, -16.9, "rock2", t=0.5)  # the pit's bottom
BEAM_Y = -10.6
for x in (-155.4, -156.7, -158.0, -164.6, -165.9):
    A.box(x, BEAM_Y, 0.36, 0.36, "wood")  # roof beams, seen end-on, hung low on iron straps
    A.deco("strap_hanger", x, -9.0, z=-0.4, size=(0.08, 3.0, 0.08), tone="iron")
POSTS = [(-158.9, -16.6, -12.0), (-160.3, -17.3, -12.2), (-161.9, -17.3, -12.0), (-163.5, -16.0, -12.2)]
for x, yb, yt in POSTS:
    A.box(x, (yb + yt) / 2, 0.45, yt - yb, "wood")
A.challenge("1.1", "La Galería", (-154.0, -12.6), 1, "S", moves=[
    ["reach", [-155.5, -12.6], [-155.4, -10.78]], ["reach", [-155.4, -10.78], [-156.7, -10.78]],
    ["reach", [-156.7, -10.78], [-158.0, -10.78]], ["reach", [-158.0, -10.78], [-158.9, -12.0]],
    ["reach", [-158.9, -12.0], [-160.3, -12.2]], ["reach", [-160.3, -12.2], [-161.9, -12.0]],
    ["reach", [-161.9, -12.0], [-163.5, -12.2]], ["reach", [-163.5, -12.2], [-164.6, -10.78]],
    ["reach", [-164.6, -10.78], [-165.9, -10.78]]])

# ================================================================ 1.2 Escalera Rota
# Iron staples up the shaft's west wall, in four runs. The gaps: 1.5 m, 1.88 m, 2.05 m.
# (CHALLENGES asks 2.3 m for the last: hold to hold that is 3.6 m/s, over F1. 2.05 is F1's limit.)
RUNGS = [-11.6, -10.85, -10.1, -9.35, -7.85, -7.1, -6.35, -5.6, -3.72, -2.97, -2.22, -1.47,
         0.58, 1.33, 2.08, 2.83, 3.58, 4.33, 5.08]
for y in RUNGS:
    A.box(-171.55, y - 0.07, 1.1, 0.14, "iron")  # x -172.1 .. -171.0: 0.9 m of rung out of the wall
A.ledge(-176.0, -172.0, 6.0, "rock", t=0.5)  # the ladder's head: a rest, and the catwalk's east end
A.statue(-167.0, -12.28, "sit", flip=True)  # the one who kept count, by his cold lantern
A.deco("lantern_cold", -166.2, -12.6, z=-0.5, size=(0.3, 0.5, 0.3), tone="iron")
A.deco("tally_marks", -167.0, -10.9, z=-1.4, size=(1.6, 1.0, 0.02), tone="bone")
A.deco("ladder_rails_broken", -172.2, -3.0, z=-0.6, size=(1.0, 18.0, 0.1), tone="wood")
A.challenge("1.2", "Escalera Rota", (-170.6, -12.6), 1, "S", moves=[
    ["reach", [-171.2, -9.35], [-171.2, -7.85]], ["reach", [-171.2, -5.6], [-171.2, -3.72]],
    ["fling", [-171.2, -1.47], [-171.2, 0.58], "F1"], ["reach", [-171.2, 5.08], [-172.2, 6.0]]])

# ================================================================ 1.3 Los Tablones
# The catwalk, y 6, x -176 .. -192.8: over the walk of shame, the beach, then the water.
# The four short grey planks snap 1.2 s after they are taken; each can be stepped over
# (1.4 m edge to edge), except the pair in the middle, which has to be crossed at a run.
PLANKS = [(-176.0, 2.2, "plank", 6.0), (-178.3, 1.2, "rotten", 5.95), (-179.6, 2.0, "plank", 5.9),
          (-181.7, 1.2, "rotten", 5.8), (-183.0, 1.2, "rotten", 5.75), (-184.3, 2.0, "plank", 5.8),
          (-186.4, 1.2, "rotten", 5.9), (-187.7, 2.4, "plank", 5.95), (-190.2, 2.6, "plank", 6.0)]
for x_east, length, kind, top in PLANKS:
    A.ledge(x_east - length, x_east, top, kind, t=0.22)
for x in (-178.25, -181.65, -184.25, -187.65, -190.15, -192.8):
    A.deco("catwalk_bracket", x, 5.6, z=-0.9, size=(0.2, 1.4, 1.6), tone="wood")
A.challenge("1.3", "Los Tablones", (-174.5, 6.0), 2, "A", moves=[
    ["reach", [-178.2, 6.0], [-179.6, 5.9]], ["reach", [-186.3, 5.8], [-187.7, 5.95]]])

# ================================================================ 1.4 La Cuerda del Minero
# The gap: x -192.8 .. -197.9, 34 m over the water. The rope hangs 1.3 m out, from a
# greased iron rod under the hoist's arm (the rod is why the rope can't be climbed to the arm).
A.box(-194.1, 12.6, 0.12, 2.4, "grease")
A.rope("cuerda_minero", (-194.1, 11.4), 4.8, kind="rope")
A.ledge(-201.9, -197.9, 6.0, "rock", t=0.5)  # the landing on the pillar's shoulder: 4 m
A.challenge("1.4", "La Cuerda del Minero", (-191.5, 6.0), 2, "A", moves=[
    ["reach", [-192.8, 6.0], [-194.1, 7.3]], ["fling", [-196.0, 7.6], [-199.4, 6.0], "F1"]])

# ================================================================ 1.5 El Cubo
# Staples up the pillar to the hoist's arm; out along the arm, back over the gap; the
# counterweight hangs a step past its tip. Grab it: 12 m up in 7.5 s, 2.5 s at the top,
# then it goes home. Step off west onto the station deck. Fall off and you land on the
# catwalk, before the rope.
for y in (7.1, 8.3, 9.5, 10.7, 11.9, 13.1, 14.3):
    A.box(XF + 0.4, y - 0.07, 1.0, 0.14, "iron")
# The arm: top y 14.2. Its west end stands 1.5 m off the wall (a beam built into the wall
# would roof the staples in), so the staples pass it and you step across onto its end.
A.beam((-200.4, 14.0), (-191.5, 14.0), 0.4, "wood")
A.mover("cubo_peso", (-190.2, 15.3),
        [(box_pts(0.0, 0.0, 1.0, 1.2), "iron"), (box_pts(0.0, 0.78, 0.5, 0.36), "iron")],
        {"type": "path", "pts": [[-190.2, 15.3], [-190.2, 27.3]], "speed": 1.6, "mode": "once",
         "trigger": "grab", "reset": 2.5},
        model="lift_counterweight")
A.mover("cubo", (-187.7, 27.0),
        [(box_pts(0.0, -0.45, 1.1, 0.14), "iron"), (box_pts(-0.5, 0.0, 0.12, 1.0), "iron"), (box_pts(0.5, 0.0, 0.12, 1.0), "iron")],
        {"type": "link", "to": "cubo_peso", "scale": -1.0}, model="ore_bucket")  # the bucket comes down as you go up
A.ledge(-199.8, -191.6, 26.2, "plank", t=0.3)  # the station deck. It stops 2.1 m short of the wall
A.deco("pulley_wheel", -188.95, 31.6, z=-0.5, size=(1.6, 1.6, 0.3), tone="iron")
A.deco("lift_cable", -190.2, 23.5, z=-0.5, size=(0.06, 16.0, 0.06), tone="iron")
A.deco("lift_cable", -187.7, 23.5, z=-0.5, size=(0.06, 16.0, 0.06), tone="iron")
A.deco("timber_brace", -197.0, 12.2, z=-0.7, rot=-28.0, size=(0.3, 6.0, 0.3), tone="wood")
A.deco("timber_brace", -196.0, 24.6, z=-0.7, rot=-30.0, size=(0.3, 6.5, 0.3), tone="wood")
A.challenge("1.5", "El Cubo", (-200.0, 6.0), 2, "B", moves=[
    ["reach", [-201.3, 6.0], [-201.2, 7.1]], ["reach", [-201.2, 14.3], [-200.4, 14.2]],
    ["reach", [-191.5, 14.2], [-190.7, 15.0]]])

# ================================================================ 1.6 Vetas de Lodo
# The pillar's east face, y 26 .. 40: black mud with eight pale ribs. Stretches of 1.6 m,
# and two lunges of 1.95 m to the two wide ribs. Come off and you drop through the gap
# between deck and wall onto the hoist's arm, 12 m down (or catch a rib on the way).
RIBS = [(27.0, 0.6), (28.6, 0.9), (30.2, 0.6), (32.15, 1.2), (33.75, 0.6), (35.35, 0.9), (37.3, 1.2), (38.8, 0.6)]
for top, proud in RIBS:
    A.solid([(XF - 0.3, top - 0.42), (XF + proud, top - 0.34), (XF + proud, top), (XF - 0.3, top)], "rock")
A.ledge(-208.9, XF, 40.0, "rock", t=0.5)  # the pillar's top: the track
A.challenge("1.6", "Vetas de Lodo", (-198.0, 26.2), 2, "B", moves=[
    ["reach", [-199.8, 26.2], [-201.3, 27.0]], ["reach", [-201.3, 27.0], [-201.0, 28.6]],
    ["reach", [-201.0, 28.6], [-201.3, 30.2]], ["fling", [-201.3, 30.2], [-200.7, 32.15], "F1"],
    ["reach", [-200.7, 32.15], [-201.3, 33.75]], ["reach", [-201.3, 33.75], [-201.0, 35.35]],
    ["fling", [-201.0, 35.35], [-200.7, 37.3], "F1"], ["reach", [-200.7, 37.3], [-201.3, 38.8]],
    ["reach", [-201.3, 38.8], [-201.9, 40.0]]])

# ================================================================ 1.7 El Carrito Loco
# The cart sits on the pillar's top. Board it: it runs west, off the broken trestle
# (x -211.6), and down through the fall into the Sump. Two chains hang 2.6 and 4.2 m past
# the trestle's end (too far to reach from it), their tails at chest height over the cart's
# road: put a hand up and take one as you go under.
A.ledge(-211.6, -208.5, 40.0, "wood", t=0.4)  # the trestle's stub
# 2.3 s from boarding to the trestle's end, at 4.5 m/s there. Past the end its road is the
# arc of a thing thrown off, into the waterfall. (3.4 m of the top is left east of the cart to rest on.)
TRACK = [(-206.5, 40.45), (-211.6, 40.45), (-214.6, 40.1), (-217.6, 39.05), (-220.6, 37.3), (-223.6, 34.87),
         (-227.6, 30.5), (-231.6, 24.95), (-235.6, 18.1), (-239.5, 8.0), (-241.5, -10.0), (-242.0, -31.0)]
A.mover("carrito", TRACK[0],
        [(box_pts(0.0, 0.0, 2.4, 0.2), "plank"), (box_pts(-1.12, 0.35, 0.16, 0.9), "iron"), (box_pts(1.12, 0.35, 0.16, 0.9), "iron")],
        {"type": "path", "pts": [list(p) for p in TRACK], "speed": 5.0, "mode": "once", "trigger": "board",
         "reset": 12.0, "tilt": True, "accel": 2.0},
        model="minecart")
A.deco("sign_pug_skull", -202.5, 40.0, z=-1.0, size=(1.0, 2.2, 0.1), tone="bone")  # the warning, before the cart
A.deco("rail_track", -207.7, 40.05, z=-0.3, size=(7.8, 0.12, 1.0), tone="iron")
A.deco("trestle_broken", -211.0, 36.5, z=-0.8, size=(4.0, 7.0, 2.0), tone="wood")
A.challenge("1.7", "El Carrito Loco", (-203.6, 40.0), 3, "A")

# ================================================================ 1.8 Las Vigas
# Four beams under the chamber's roof (y 55), 4.6 m apart, stepped up and down, 78 m over
# the water. The chains hang from the first: climb one (8.5 m) and stand on the beam.
BEAMS = [(-218.3, -213.9, 50.5), (-222.8, -220.8, 52.0), (-227.3, -225.3, 50.8), (-231.8, -229.8, 52.3)]
for x0, x1, top in BEAMS:
    A.ledge(x0, x1, top, "wood", t=0.4)
    A.deco("strap_hanger", (x0 + x1) / 2, (top + 55.0) / 2, z=-0.4, size=(0.08, 55.0 - top, 0.08), tone="iron")
A.rope("cadena_a", (-214.2, 50.1), 8.6, kind="chain")
A.rope("cadena_b", (-215.8, 50.1), 9.0, kind="chain")
A.challenge("1.8", "Las Vigas", (-216.5, 50.5), 3, "A", moves=[
    ["fling", [-218.1, 50.1], [-221.8, 52.0], "F2"], ["fling", [-222.6, 51.6], [-226.3, 50.8], "F2"],
    ["fling", [-227.1, 50.4], [-230.8, 52.3], "F2"], ["reach", [-231.8, 52.3], [-232.2, 54.0]]])

# ================================================================ 1.9 La Polea Grande
# The staging under the wheel (its west plank is wet in turn), the wheel (3 m, clockwise,
# 12 s a turn: up the fall's side, over the top), the porch of the upper gallery east of it.
A.ledge(-236.6, -235.4, 54.0, "plank", t=0.3, hold={"type": "wet", "on": 1.5, "off": 4.5, "phase": 0.0})
A.ledge(-235.4, -232.2, 54.0, "plank", t=0.3)
A.wheel("polea_grande", (-234.4, 57.4), 1.5, -5.0, spokes=6, kind="wood", rim=0.18, model="winding_wheel")
A.ledge(-232.4, -229.6, 57.4, "plank", t=0.4)  # the porch, half a metre clear of the rim
A.ledge(-230.0, -218.5, 57.4, "rock2", t=0.5)  # the upper gallery's floor
A.box(-229.2, 57.65, 0.3, 0.5, "wood")  # a sill: it stops most of the rocks that roll out of 1.10
# The awning: a slick roof over the wheel. Whoever comes off La Cortina lands on it and is
# slid west off its tip (x -237.2) into the fall, and so to the Sump.
A.solid([(-229.9, 66.5), (-237.2, 61.0), (-237.2, 60.5), (-229.9, 65.9)], "wet")
A.deco("staging_hangers", -234.4, 56.0, z=-0.8, size=(4.4, 4.0, 0.1), tone="iron")
A.challenge("1.9", "La Polea Grande", (-232.9, 54.0), 2, "B", moves=[
    ["reach", [-234.4, 54.0], [-234.4, 55.85]]])

# ================================================================ 1.10 El Derrumbe
# The cave-in shaft, x -222.1 .. -218.5, from the rubble at its foot to the top drift
# (y 72). Stubs of broken timber on the two walls; the route changes wall three times,
# each time a 2.3 m lunge across the middle, and the middle is where the rocks come down.
A.solid([(-223.2, 57.4), (-218.4, 57.4), (-218.4, 61.7)], "rock2")  # the rubble slope
A.beam((-222.9, 57.75), (-218.75, 61.75), 0.36, "wood")  # a fallen cap beam lying on it
STUBS = [("E", 63.0, 0.75), ("E", 64.3, 0.75), ("W", 65.2, 0.75), ("W", 66.5, 0.6), ("W", 67.8, 0.75),
         ("E", 68.7, 0.75), ("E", 70.0, 0.6), ("W", 70.9, 0.75)]
for side, top, length in STUBS:
    if side == "E":
        A.solid([(-218.3, top - 0.3), (-218.3, top), (-218.5 - length, top), (-218.5 - length, top - 0.22)], "wood")
    else:
        A.solid([(-222.3, top - 0.3), (-222.1 + length, top - 0.22), (-222.1 + length, top), (-222.3, top)], "wood")
A.spawner("rock", (-220.4, 76.3), 4.0, phase=0.0, r=0.42, life=6.0, warn=1.2)
A.spawner("rock", (-220.2, 76.3), 5.6, phase=2.0, r=0.42, life=6.0, warn=1.2)
A.effect("dust", (-222.1, 61.0, -218.5, 77.0), density=0.5)
A.ledge(-230.0, -222.1, 72.0, "rock2", t=0.5)  # the top drift
A.ledge(-233.2, -229.6, 72.0, "plank", t=0.35)  # its balcony into the throat
A.challenge("1.10", "El Derrumbe", (-225.5, 57.4), 3, "B", moves=[
    ["reach", [-218.9, 61.4], [-219.25, 63.0]], ["reach", [-219.25, 63.0], [-219.25, 64.3]],
    ["fling", [-219.25, 64.3], [-221.35, 65.2], "F1"], ["reach", [-221.35, 65.2], [-221.5, 66.5]],
    ["reach", [-221.5, 66.5], [-221.35, 67.8]], ["fling", [-221.35, 67.8], [-219.25, 68.7], "F1"],
    ["reach", [-219.25, 68.7], [-219.1, 70.0]], ["fling", [-219.1, 70.0], [-221.35, 70.9], "F1"],
    ["reach", [-221.35, 70.9], [-222.2, 72.0]]])

# ================================================================ 1.11 La Cortina
# Fourteen rows of two holds, from the balcony to the top of the dry shaft. In every row
# the left hold and the right are wet half a turn apart (wet 2.6 s, dry 3.4 s), and each
# row runs 0.7 s behind the one under it: one hold of every pair is always dry, and no
# hold stays dry for long.
ROW0_Y, ROW_DY, ROWS = 73.3, 1.25, 14
CORTINA = []
for r in range(ROWS):
    y = ROW0_Y + ROW_DY * r
    xl = -235.6 + 0.11 * r
    for x, ph in ((xl, 0.0), (xl + 1.3, 3.0)):
        A.hold(x, y, r=0.24, kind="rock", hold={"type": "wet", "on": 2.6, "off": 3.4, "phase": round((0.7 * r + ph) % 6.0, 2)})
    CORTINA.append((xl, xl + 1.3, y))
cortina_moves = [["reach", [-233.2, 72.0], [round(CORTINA[0][1], 2), CORTINA[0][2]]]]
for r in range(ROWS - 1):  # the lint's line: up the right-hand holds (any zigzag is shorter than 1.9 too)
    cortina_moves.append(["reach", [round(CORTINA[r][1], 2), CORTINA[r][2]], [round(CORTINA[r + 1][1], 2), CORTINA[r + 1][2]]])
cortina_moves.append(["reach", [round(CORTINA[-1][1], 2), CORTINA[-1][2]], [-232.0, 89.7]])  # the lip
A.ledge(-232.0, -225.5, 89.7, "rock", t=0.5)  # the roof's own grip under A2's lip ledge (which tops it at y 90)
A.challenge("1.11", "La Cortina", (-231.4, 72.0), 3, "A", moves=cortina_moves)

# ================================================================ cameras
A.cam((-178.0, -19.0, -148.0, -6.0), 4.6)  # the gallery
A.cam((-173.0, -8.0, -167.0, 6.5), 5.5)  # the ladder shaft
A.cam((-200.0, 3.0, -176.0, 12.0), 9.0, bias=(0.0, -4.0))  # catwalk and rope: the drop
A.cam((-203.0, 12.0, -186.0, 30.0), 8.0, bias=(0.0, -2.0))  # the hoist
A.cam((-204.0, 26.0, -198.0, 40.0), 8.0, bias=(2.0, -3.0))  # the banded wall
A.cam((-220.0, 39.5, -200.0, 50.0), 11.0, bias=(-5.0, -2.0))  # the cart, the trestle, the chains
A.cam((-233.0, 46.0, -212.0, 55.0), 13.0, bias=(0.0, -7.0))  # Las Vigas: the whole drop
A.cam((-238.0, 53.0, -229.0, 62.0), 6.0)  # the wheel
A.cam((-223.0, 57.0, -218.0, 78.0), 7.0, bias=(0.0, 2.5))  # the cave-in: look up
A.cam((-238.0, 70.0, -229.0, 91.0), 10.0, bias=(-2.0, -3.0))  # La Cortina
A.cam((-248.0, -34.0, -186.0, -20.0), 8.0, bias=(0.0, 4.0))  # in the Sump: look up at what you lost

# ================================================================ lanterns
LANTERNS = [(-154.0, -8.6), (-166.5, -8.6), (-170.0, -1.0), (-174.6, 9.2), (-184.5, 9.0), (-200.3, 9.4),
            (-196.5, 16.6), (-196.5, 28.8), (-200.2, 34.0), (-203.8, 43.4), (-210.8, 43.4), (-216.1, 53.2),
            (-226.3, 53.6), (-234.4, 60.2), (-226.0, 60.4), (-220.3, 66.8), (-226.0, 75.0), (-231.3, 80.0),
            (-188.6, -24.4)]
for x, y in LANTERNS:
    A.deco("lantern_mine", x, y + 0.4, z=-1.0, size=(0.3, 0.5, 0.3), tone="gold")
    A.light(x, y, color="#FFB860", rng=10.0, energy=1.5, flicker=True)
for x, y in ((-241.0, -24.0), (-225.0, -26.0), (-212.0, -26.0), (-241.0, 40.0), (-241.0, 82.0)):
    A.light(x, y, color="#9FD0FF", rng=14.0, energy=0.9, z=2.2)  # the water's own cold light: the drop is lit

# ================================================================ the picture
A.card([(-256, -40), (-146, -40), (-146, 94), (-256, 94)], z=-6.0, tone="back2")  # the room's back wall
A.card([(-256, -40), (-146, -40), (-146, -8), (-178, 2), (-206, -6), (-232, 6), (-256, 0)], z=-14.0, tone="back3")
A.card([(-150, 94), (-150, 26), (-168, 40), (-190, 44), (-204, 58), (-226, 62), (-226, 94)], z=-10.0, tone="back3")
A.card([(-256, 94), (-256, 20), (-250, 34), (-247, 60), (-249, 94)], z=-4.0, tone="back")  # behind the fall
A.card([(-211, -34), (-196, -34), (-197, -25), (-199, 4), (-203, 6), (-204, 38), (-208, 38), (-210, -20)], z=-2.0, tone="back")  # the pillar's root, behind its arch
A.card([(-178, -8), (-150, -8), (-150, 8), (-170, 7), (-178, 4)], z=-3.0, tone="back")
A.card([(-232, 55), (-214, 55), (-214, 80), (-222, 88), (-232, 88)], z=-3.0, tone="back")  # the upper works
A.card([(-196, 56), (-190, 44), (-186, 49), (-181, 41), (-176, 43), (-170, 35), (-164, 38), (-158, 30), (-150, 32), (-150, 60)], z=3.0, tone="slick")  # stalactites, in front
A.card([(-256, -40), (-146, -40), (-146, -33), (-200, -35), (-256, -33)], z=4.0, tone="slick")
A.card([(-150, 6), (-150, 30), (-158, 26), (-160, 14), (-166, 12), (-168, 6)], z=-4.0, tone="back")  # old stopes, far side
A.deco("scaffold_old", -160.0, 12.5, z=-4.5, size=(9.0, 12.0, 0.4), tone="wood")  # workings nobody reaches now
A.deco("papel_miners", -184.0, 12.6, z=-2.5, size=(14.0, 0.9, 0.05), tone="accent")  # bunting over the catwalk
A.deco("lantern_mine", -162.0, 19.0, z=-4.4, size=(0.3, 0.5, 0.3), tone="gold")
A.light(-162.0, 18.6, color="#FFB860", rng=8.0, energy=0.9, z=-3.0, flicker=True)
A.deco("mine_frame", -152.0, -12.6, z=0.0, size=(0.6, 5.1, 2.6), tone="wood")  # the door's timber set
A.deco("mine_frame", -176.0, -12.6, z=0.0, size=(0.6, 5.1, 2.6), tone="wood")  # the gallery's mouth
A.deco("papel_miners", -170.5, -8.2, z=-1.5, size=(9.0, 0.8, 0.05), tone="accent")  # the miners' bunting
A.deco("rail_track", -152.8, -12.55, z=-0.3, size=(5.0, 0.12, 1.0), tone="iron")  # the rails end at the mud
A.deco("ore_cart_wreck", -161.0, -16.4, z=-0.9, size=(2.2, 1.2, 1.2), tone="iron")  # what the mud took
A.deco("pick_and_helmet", -174.8, 6.0, z=-0.8, size=(0.9, 0.6, 0.4), tone="iron")
A.deco("mine_frame", -230.0, 57.4, z=0.0, size=(0.6, 4.0, 2.6), tone="wood")  # the upper gallery's mouth
A.deco("mine_frame", -230.0, 72.0, z=0.0, size=(0.6, 4.0, 2.6), tone="wood")  # the top drift's mouth
A.deco("papel_miners", -226.0, 75.4, z=-1.5, size=(7.0, 0.8, 0.05), tone="accent")
A.deco("sign_pug_arrow", -224.6, 72.0, z=-1.0, size=(1.0, 2.2, 0.1), tone="wood", flip=True)  # up, to the water
A.deco("timber_set", -220.3, 59.6, z=-1.2, size=(3.6, 4.0, 0.3), tone="wood")
A.effect("drips", (-176.0, 6.0, -172.0, 12.0))  # every rest has its unease
A.effect("drips", (-201.9, 6.0, -197.9, 13.0))
A.effect("drips", (-199.8, 26.2, -191.3, 32.0))
A.effect("drips", (-208.9, 40.0, -201.9, 48.0))
A.effect("drips", (-233.2, 72.0, -222.1, 76.0))

if __name__ == "__main__":
    A.save()
