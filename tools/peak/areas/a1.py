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
  - the UPPER WORKS in the rock east of the fall's throat: the winding wheel (1.9, at the
    throat's foot), the upper gallery, the cave-in shaft (1.10), the top drift;
  - the THROAT (x -248..-230, y 55..86): the fall's last 30 m, and La Cortina (1.11).
The fall line (x -244..-238) is empty from the roof slot to the water.

How the rock is made here: the AIR is drawn (a handful of polygons), and the rock is
everything within 4 m of it that isn't air, cut into convex slabs of slick `wet`. Every
grip surface is a separate solid laid 0.3 m proud of that skin, so grip is only ever
where it was put on purpose. Props are the kit's names (docs/peak/PARTS.md); their
(x, y) is the middle of their base.
"""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from peaklib import Area, box_pts, ngon
import a1_dress  # the mine's scenery (the modelling run's): decos only

A = Area("a1", "mine")
# THE MINE MOVED (note 146; Parker 11-14: "move the mine over to line up it's big fall with the falls"):
# 59 m west and 17 m down, not widened, so its waterfall cavern stands under the well and the great falls
# come down through it in one 6 m shaft. Everything this file and a1_dress place, down to the end of
# the dress, is written in today's numbers and moved as one at save (peaklib begin_shift / end_shift).
# La Esclusa, the new section above it (1.12, 1.13), is written where it stands.
MOVE = (-59.0, -17.0)
A.begin_shift(*MOVE)

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
# The frog's cave off the Sump's west shore (note 71; page 1.0): a low room, its doorway on the
# chamber's west wall. And the chimney the cave-in's rocks fall out of (page 1.10), carved up
# out of the shaft's top where nobody can reach it.
FROG_CAVE = [(-248.0, -27.5), (-248.0, -25.4), (-249.2, -25.4), (-249.2, -24.8), (-253.4, -24.8), (-253.4, -27.5)]
CHIMNEY = [(-221.3, 76.9), (-219.3, 76.9), (-219.5, 81.2), (-221.0, 81.2)]
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
                       [Polygon(p) for p in (GALLERY, SHAFT, UPPER, DRIFT, FROG_CAVE, CHIMNEY)])
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
    from shapely.geometry import Point
    regions = [(stem, Polygon(poly)) for stem, poly in a1_dress.SKIN_REGIONS.items()]
    for p in pieces:
        pts = list(p.simplify(1e-4).exterior.coords)[:-1]
        pts = [q for k, q in enumerate(pts) if math.dist(q, pts[k - 1]) > 0.02]  # (a sliver of a point the chimney leaves)
        mid = p.centroid
        skin = next((stem for stem, poly in regions if poly.contains(Point(mid.x, mid.y))), None)
        A.solid(pts, "wet", skin=skin)  # (a1_dress FOR THE AREA FILE item 5: each mass one painted piece)


carve()
A.opening(-153, -13, -151, -7)  # the door from the cart tunnel (A0)
A.opening(FALL_X0, 85, FALL_X1, 91)  # the waterfall's slot (A2's river pours through)
A.opening(-236, 85, -232, 91)  # the dry shaft out (A2's lip ledge is at its top)

# ================================================================ the fall and the Sump
A.water((-248.0, -33.0, -187.4, SUMP_Y), SUMP_Y, flow=(0.0, 0.0))
# The falling water beats a climber down (2.2 g; a floating body's lift tops out at 2.2 g
# too). It stops 6 m over the pool, so nobody who lands under it is held under.
A.wind((FALL_X0, -22.0, FALL_X1, 90.0), (0.0, -6.0))
# (It is the black waters' river, come over its lip. a2 draws it down to y 84, where it
# is 1.68 m east of the slot's west side and a quarter of a metre thick; this is the
# rest of it, on the same line.)
# THE GREAT FALLS (note 146; Parker: "the great falls goes to the bottom"): one 6 m column from the well's foot
# (y 176) down through the black waters, La Esclusa and the mine to the Sump: for now this waterfall, stretched
# to the column's full width and height (its top written 193, moved to 176), drawn just behind the climb.
# (Note 111's 3D falls come later.)
A.effect("waterfall", (FALL_X0, SUMP_Y, FALL_X1, 193.0), x=(FALL_X0 + FALL_X1) / 2, head=0.0, width=6.0, z=-0.6)
A.effect("mist", (-250.0, -30.0, -230.0, -17.0), density=0.8)
A.effect("mist", (-240.0, 62.0, -230.5, 90.0), density=0.4)

# The walk of shame: a grip incline with sleepers, from the landing stage up to the gallery.
A.patch((-175.8, -12.64), (-189.4, -30.1), "rock", t=0.7)
for y in (-14.8, -17.0, -19.2, -21.4, -23.6, -25.8):
    x = -176.0 - (-12.9 - y) / 1.2833
    A.box(x - 0.25, y + 0.42, 1.1, 0.3, "wood")
A.ledge(-190.4, -187.0, -27.7, "plank", t=0.3)  # the landing stage, a hand above the water
# (note 109: these two drew their own dark boxes with their tops in the throat skin's plane, and flickered.
# They wear the throat's skin now: its top is the floor.)
A.ledge(-253.4, -248.0, -27.5, "rock", t=0.5, skin="mine_throat_west")  # the frog's cave's floor (grip; page 1.0)
A.solid([(-248.0, -28.3), (-247.2, -28.3), (-247.2, -27.5), (-248.0, -27.5)], "rock", skin="mine_throat_west")  # its doorstep, out of the water
for x in (-228.5, -219.0, -211.0, -194.5):
    A.box(x, -30.1, 0.4, 5.8, "wood")  # old staging piles: something to hold on the long swim east

# ================================================================ 1.1 La Galeria
# Grip floor from the door; then the floor falls away into black mud. Over it: three low
# roof beams, four posts standing in the mud, two more beams. Slip and you are in the pit
# (grip bottom, 4.3 m down); the two posts that stand in it climb back out.
A.ledge(-148.0, -155.5, -12.6, "rock", t=0.5)  # (it runs through the door frame to meet A0's floor)
A.ledge(-165.5, -176.0, -12.6, "rock", t=0.5)
A.ledge(-160.0, -162.0, -16.9, "rock", t=0.5)  # the pit's bottom
BEAM_Y = -10.6
for x in (-155.4, -156.7, -158.0, -164.6, -165.9):
    A.box(x, BEAM_Y, 0.36, 0.36, "wood")  # roof beams, seen end-on, hung low on posts from the roof
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
# A real ladder (Parker 11-12): rails drawn, only the rungs solid, rungs missing in three stretches.
A.ladder(-171.55, RUNGS, w=0.9, kind="iron", crooked={2: -8.0, 6: 7.0, 9: -10.0, 13: 6.0})  # rusted iron, bracket rungs, some sagging
A.ledge(-176.0, -172.0, 6.0, "rock", t=0.5)  # the ladder's head: a rest, and the catwalk's east end
A.statue(-167.0, -12.28, "sit", flip=True)  # the one who kept count, by his cold lantern
# (his camp's things are a1_dress's, out of the play space)
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
# counterweight comes down to a step past its tip, waits 2.5 s, goes up 12 m (7.5 s),
# waits 2.5 s at the top by the station deck, and comes back down. Step off west at the
# top, or ride it down again. Fall off and you land on the catwalk, before the rope.
for y in (7.1, 8.3, 9.5, 10.7, 11.9, 13.1, 14.3):
    A.box(XF + 0.4, y - 0.07, 1.0, 0.14, "iron")
# The arm: top y 14.2. Its west end stands 1.5 m off the wall (a beam built into the wall
# would roof the staples in), so the staples pass it and you step across onto its end.
A.beam((-200.4, 14.0), (-191.5, 14.0), 0.4, "wood")
LIFT = {"type": "path", "pts": [[-190.2, 14.7], [-190.2, 26.7]], "speed": 1.6, "mode": "pingpong", "wait": 2.5}
A.mover("cubo_peso", (-190.2, 14.7), [(box_pts(0.0, 0.6, 1.6, 1.2), "iron")], LIFT, model="counterweight")
# (Parker 11-12: "does not have stickyness for some reason and its collision is wrong".
# The kit's bucket is 1.04 tall with its zero at its middle; this collision's zero is its
# floor. So the model is lifted 0.52 onto the floor and the walls stop at its rim. The
# bail over the top is drawn only: solid, it would shut the bucket's mouth.)
_cubo = A.mover("cubo", (-187.7, 26.5),
        [(box_pts(0.0, 0.06, 1.2, 0.12), "iron"), (box_pts(-0.54, 0.52, 0.12, 1.04), "iron"), (box_pts(0.54, 0.52, 0.12, 1.04), "iron")],
        {"type": "link", "to": "cubo_peso", "scale": -1.0}, model="ore_bucket")  # the bucket comes down as you go up
_cubo["model_at"] = [0.0, 0.52]
A.ledge(-199.8, -191.9, 26.2, "plank", t=0.3)  # the station deck. It stops 2.1 m short of the wall
# The lift's two cables are gone (Parker 11-12: "remove these track things and replace them
# with something else. They look like the ropes you grab later"): a thin hanging line in
# this mine is a rope or a chain, and those are held. The lift's "track" is now the
# HOISTWAY: the headframe, `mina_hoist_headframe` (a1_dress, the quality run's E6), behind the climb:
# the gallows on the station deck, the guide rails the bucket and the counterweight run in front of, and
# the back-stay, in one piece. (It took the place of the two flat cards painted in the back wall's grey:
# the gallows and the broken back boards. Dark, flat and broad stays this mine's word for "behind you,
# not for hands": no rungs, no lattice, no line.)
# (Thrown out: three stacked station_scaffold models, which in the game were a bright
# orange cross-braced tower in the colour of every timber you hold, a climbing frame; and
# the gallows alone, which left the bucket and the counterweight afloat in the dark.)
A.challenge("1.5", "El Cubo", (-200.0, 6.0), 2, "B", moves=[
    ["reach", [-201.3, 6.0], [-201.2, 7.1]], ["reach", [-201.2, 14.3], [-200.4, 14.2]],
    ["reach", [-191.5, 14.2], [-191.0, 15.0]]])

# ================================================================ 1.6 Vetas de Lodo
# The pillar's east face, y 26 .. 40: black mud with eight pale ribs. Stretches of 1.6 m,
# and two lunges of 1.95 m to the two wide ribs. Come off and you drop through the gap
# between deck and wall, past the arm's end, to the shoulder at the foot of the staples,
# 20 m down (or catch a rib on the way).
RIBS = [(27.0, 0.6), (28.6, 0.9), (30.2, 0.6), (32.15, 1.2), (33.75, 0.6), (35.35, 0.9), (37.3, 1.2), (38.8, 0.6)]
for top, proud in RIBS:
    A.solid([(XF - 0.3, top - 0.42), (XF + proud, top - 0.34), (XF + proud, top), (XF - 0.3, top)], "rock",
            skin={0.6: "mine_rib_short", 0.9: "mine_rib", 1.2: "mine_rib_wide"}[proud])
A.ledge(-208.9, XF, 40.0, "rock", t=0.5)  # the pillar's top: the track
A.challenge("1.6", "Vetas de Lodo", (-198.0, 26.2), 2, "B", moves=[
    ["reach", [-199.8, 26.2], [-201.3, 27.0]], ["reach", [-201.3, 27.0], [-201.0, 28.6]],
    ["reach", [-201.0, 28.6], [-201.3, 30.2]], ["fling", [-201.3, 30.2], [-200.7, 32.15], "F1"],
    ["reach", [-200.7, 32.15], [-201.3, 33.75]], ["reach", [-201.3, 33.75], [-201.0, 35.35]],
    ["fling", [-201.0, 35.35], [-200.7, 37.3], "F1"], ["reach", [-200.7, 37.3], [-201.3, 38.8]],
    ["reach", [-201.3, 38.8], [-201.9, 40.0]]])

# ================================================================ 1.7 El Carrito Loco
# THE CART ROOM, REWORKED (note 103; the redone pages 1.7 and 1.8, 11-14). The cart sits on
# the pillar's top. Stand in it 0.7 s and it runs west, over the edge of the stub, down a
# 72 degree drop, through a dip 12 m under the track and up a 45 degree rise to a lip that
# throws it, up and west at the waterfall. Off the lip it is let loose and falls for real.
# Near the top of its arc it passes one chain, 9 m long, hanging from an iron ring in the
# rib of the back wall: put a hand up and take it. The cart is the only way to the chain.
# Up the chain, then ring to ring, to the underside of Las Vigas's first beam.
# The stub's deck stays solid to x -213.2 (Parker 11-12, note 6).
A.ledge(-213.2, -208.5, 40.0, "wood", t=0.4)
# The road: the rail from the stub's end (-213.2, 40.0) over a crest of 2.2 m radius, down
# at 72 degrees, round a dip of 2.5 m radius whose lowest point is (-220.51, 28.0), and up
# at 45 degrees to the lip (-223.0, 29.45): the page's own line (_road in a1_areas.py).
ROAD = [(-213.2, 40.0)]
for _i in range(1, 9):
    _a = math.radians(72.0 * _i / 8)
    ROAD.append((-213.2 - 2.2 * math.sin(_a), 37.8 + 2.2 * math.cos(_a)))
for _i in range(0, 14):
    _a = math.radians(-72.0 + 117.0 * _i / 13)
    ROAD.append((-220.51 - 2.5 * math.sin(_a), 30.5 - 2.5 * math.cos(_a)))
ROAD.append((-223.0, 29.45))
ROAD = [(round(x, 3), round(y, 3)) for x, y in ROAD]


def _up(i):
    """The road's top side at point i (the cart's side): its tangent turned a quarter."""
    ax, ay = ROAD[max(i - 1, 0)]
    bx, by = ROAD[min(i + 1, len(ROAD) - 1)]
    d = math.hypot(bx - ax, by - ay)
    return ((by - ay) / d, -(bx - ax) / d)


# It is solid: 0.4 m of timber under the rail, held and stood on like the stub, one piece
# per stretch, wearing the road's painted piece (a1_dress places mine_cart_road).
for _i in range(len(ROAD) - 1):
    (x0, y0), (x1, y1) = ROAD[_i], ROAD[_i + 1]
    n0, n1 = _up(_i), _up(_i + 1)
    A.solid([(x0, y0), (x0 - 0.4 * n0[0], y0 - 0.4 * n0[1]), (x1 - 0.4 * n1[0], y1 - 0.4 * n1[1]), (x1, y1)], "wood",
            skin="mine_cart_road")
# 2.3 s from rolling to the trestle's end, at 4.5 m/s there. (3.4 m of the top is left east
# of the cart to rest on.)
# IT FALLS FOR REAL (Parker 11-12: "the mine cart that falls here falls too slow and should
# instead have physics a little after it falls"). Its road used to be drawn all the way to
# the Sump, 75 m of curve at 5 m/s: a 15 s glide. Now the road is only the rails and the
# first dip off their end; a cart's length past the end of the boards (x -213.2) it is let
# LOOSE: a 140 kg thing with the speed and the lean it had, that tips, falls at a rock's
# gravity (about 5 s to the water), bangs on what it meets and sinks to the Sump's floor.
# Hold on and you go with it. It is back on the rails 12 s later, once you are clear of it.
# The cart's own line runs 0.45 m over the rail, as before. Its speed is set stretch by
# stretch (note 103: "the cart needs a speed for each stretch of its road"): 5 m/s over the
# crest, gaining as it drops (as if by 4.96 m/s2 of fall) to 12 in the dip, losing on the
# rise to 10 at the lip. It is let loose at the lip, with the lean and the speed it has.
TRACK = [(-206.5, 40.45), (-211.6, 40.45)] + [(round(x + 0.45 * _up(i)[0], 3), round(y + 0.45 * _up(i)[1], 3))
                                              for i, (x, y) in enumerate(ROAD)]
_low = min(range(len(TRACK)), key=lambda i: TRACK[i][1])
SPEEDS = []
for _i, (x, y) in enumerate(TRACK):
    if _i <= _low:
        SPEEDS.append(round(math.sqrt(25.0 + 2.0 * 4.958 * max(0.0, 40.45 - y)), 2))
    else:
        f = (y - TRACK[_low][1]) / (TRACK[-1][1] - TRACK[_low][1])
        SPEEDS.append(round(12.0 + (10.0 - 12.0) * f, 2))
_total = sum(math.dist(a, b) for a, b in zip(TRACK, TRACK[1:]))
CART_LOOSE = round(_total - 0.02, 3)  # let loose at the lip
A.mover("cart1", TRACK[0],
        [(box_pts(0.0, 0.0, 2.4, 0.2), "plank"), (box_pts(-1.12, 0.35, 0.16, 0.9), "iron"), (box_pts(1.12, 0.35, 0.16, 0.9), "iron")],
        {"type": "path", "pts": [list(p) for p in TRACK], "speed": 5.0, "speeds": SPEEDS, "mode": "once", "trigger": "board",
         "reset": 12.0, "tilt": True, "tilt_rate": 30.0, "accel": 2.0, "loose": CART_LOOSE, "mass": 140.0,
         "chock": [-1.42, -0.45]},  # the chock under its west wheel, on the rail (a1_dress item 7: mine_chock)
        model="minecart")
for x in (-204.35, -207.85):
    A.deco("rail_straight", x, 39.9, z=0.0, scale=0.875, size=(4.0, 0.25, 1.2), tone="iron")
# (the warning sign, the stub's broken rail and the trestle leg are gone from here: a1_dress
# places the sign 0.4 m back and struts at the back; the broken stop is now at the lip)
# The chain, and the three rings in the rib (stand-in rings; their look is iron_ring_pin_long,
# a ring on a pin 1.6 m out of the rib: its origin where the pin meets the rock, the ring's
# middle 0.22 under the pin).
RINGS = [(-230.6, 44.2), (-226.2, 46.2), (-221.8, 48.2)]
for x, y in RINGS:
    A.hold(x, y, r=0.25, kind="iron", skin="iron_ring_pin_long")
    A.deco("iron_ring_pin_long", x, round(y + 0.22, 2), z=-1.6, size=(0.5, 0.55, 1.65), tone="iron", skin=True)
A.rope("cadena", RINGS[0], 9.0, kind="chain")  # its tail at 35.2
A.challenge("1.7", "El Carrito Loco", (-203.6, 40.0), 3, "A", moves=[
    ["ride", list(TRACK[0]), list(TRACK[-1])],
    ["fling", list(RINGS[0]), list(RINGS[1]), "F2"], ["fling", list(RINGS[1]), list(RINGS[2]), "F2"],
    ["fling", list(RINGS[2]), [-218.1, 50.1], "F2"]])

# ================================================================ 1.8 Las Vigas
# Four beams under the chamber's roof (y 55), 4.6 m apart, stepped up and down, 78 m over
# the water. You come to the first from below, off the last ring, and take its underside.
# (Note 103: the two chains on the first beam are gone. The spray has turned the undersides
# of the other three black and slick, their lowest 0.1 m the whole length: from the second
# beam on you hold tops and ends only, swinging from a splintered west end.)
BEAMS = [(-218.3, -213.9, 50.5), (-222.8, -220.8, 52.0), (-227.3, -225.3, 50.8), (-231.8, -229.8, 52.3)]
for k, (x0, x1, top) in enumerate(BEAMS):
    if k == 0:
        A.ledge(x0, x1, top, "wood", t=0.4)
    else:
        A.ledge(x0, x1, top, "wood", t=0.3)
        A.ledge(x0, x1, round(top - 0.3, 2), "wet", t=0.1)  # the black underside
A.challenge("1.8", "Las Vigas", (-216.5, 50.5), 3, "A", moves=[
    ["fling", [-218.1, 50.1], [-221.8, 52.0], "F2"], ["fling", [-222.8, 51.8], [-226.3, 50.8], "F2"],
    ["fling", [-227.3, 50.6], [-230.8, 52.3], "F2"], ["reach", [-231.8, 52.3], [-232.2, 52.45]]])

# ================================================================ 1.9 La Polea Grande
# The winding wheel at the throat's foot: 6 m across (the kit's winding_wheel), turning
# clockwise, 20 s a turn. Under it the staging (its west plank is wet in turn). Take the
# rim at the bottom: it carries you up the fall's side, over the top, and down to the porch
# of the upper gallery on its east. Hold on too long and it takes you round again.
WHEEL = (-234.2, 57.4)
# One staging (Parker 11-12: "make this part just part of the larger bridge to the
# right"): its west 1.2 m was a plank of its own that the spray wet in turn, drawn dark.
A.ledge(-237.2, -232.2, 52.45, "plank", t=0.2)
A.ledge(-237.2, -232.2, 52.25, "wet", t=0.1)  # its underside slick too (Parker's drawing; note 103)
_w = A.wheel("polea_grande", WHEEL, 3.0, -3.0, spokes=6, kind="wood", rim=0.18, model="winding_wheel")
_w["model_scale"] = 6.0 / 3.2  # (the Carpenter's wheel is 3.2 across; this one is 6)
A.ledge(-230.6, -229.6, 57.4, "plank", t=0.4)  # the porch, half a metre clear of the rim
A.ledge(-230.0, -218.5, 57.4, "rock", t=0.5)  # the upper gallery's floor
# The awning: a slick roof over the wheel. Whoever comes off La Cortina lands on it and is
# slid west off its tip (x -237.8) into the fall, and so to the Sump.
A.solid([(-229.9, 68.2), (-237.8, 62.22), (-237.8, 61.67), (-229.9, 67.65)], "wet")
A.challenge("1.9", "La Polea Grande", (-232.6, 52.45), 2, "B", moves=[
    ["reach", [-234.2, 52.45], [-234.2, 54.31]]])

# ================================================================ 1.10 El Derrumbe
# The cave-in shaft, x -222.1 .. -218.5, from the rubble at its foot to the top drift
# (y 72). Stubs of broken timber on the two walls; the route changes wall three times,
# each time a 2.3 m lunge across the middle, and the middle is where the rocks come down
# (two sources on one written rhythm; they leave by the broken board at the beam's foot).
A.solid([(-223.2, 57.4), (-218.4, 57.4), (-218.4, 61.7)], "rock")  # the rubble slope
A.beam((-222.9, 57.75), (-218.75, 61.75), 0.36, "wood")  # a fallen cap beam lying on it
STUBS = [("E", 63.0, 0.75), ("E", 64.3, 0.75), ("W", 65.2, 0.75), ("W", 66.5, 0.6), ("W", 67.8, 0.75),
         ("E", 68.7, 0.75), ("E", 70.0, 0.6), ("W", 70.9, 0.75)]
for side, top, length in STUBS:
    if side == "E":
        A.solid([(-218.3, top - 0.3), (-218.3, top), (-218.5 - length, top), (-218.5 - length, top - 0.22)], "wood",
                skin="mine_stub" if length == 0.75 else "mine_stub_short")
    else:
        A.solid([(-222.3, top - 0.3), (-222.1 + length, top - 0.22), (-222.1 + length, top), (-222.3, top)], "wood",
                skin="mine_stub" if length == 0.75 else "mine_stub_short")
# THE ROCKS' RHYTHM IS WRITTEN OUT (Parker 11-12: "this part needs a longer delay between
# rocks ... like a one second more delay, not a hugely longer delay", then "after the
# double rock fall, there is an extra .5 seconds along with the extra one second we added",
# and "just the 0.4 ones count as doubles"). The two sources were free-running timers,
# every 4.0 s (from second 0) and every 5.6 s (from second 3.6): a 28 s pattern of 12
# rocks with two doubles 0.4 s apart. Stretching the timers would have moved the doubles,
# so the pattern itself is the data now: that same pattern with one second added to every
# gap, one and a half to the gap straight after a double, the doubles left at 0.4. 39 s,
# 12 rocks, each from the source it always fell from.
ROCK_GAPS = [4.6, 0.4, 5.5, 2.2, 3.8, 3.8, 2.2, 5.0, 0.4, 5.1, 3.0, 3.0]
ROCK_ORDER = "ABAABABAABAB"  # A is the west source (was every 4.0 s), B the east (every 5.6 s)
_rock_times, _rock_loop = Area.rhythm(ROCK_GAPS, ROCK_ORDER)
# ("make the hitbox on the boulder here a little smaller": a knock-out was the rock's
# middle within 0.74 m of your head, chest or hips; now 0.60.)
# life: a rock leaves by the board below, never by the clock. 12 s is only the net under
# one that somehow never got there (it breaks up where it lies).
A.spawner("rock", (-220.4, 76.3), times=_rock_times["A"], loop=_rock_loop, r=0.42, life=12.0, warn=1.2, hit=0.6)
A.spawner("rock", (-220.2, 76.3), times=_rock_times["B"], loop=_rock_loop, r=0.42, life=12.0, warn=1.2, hit=0.6)
# THE BOARD THEY LEAVE BY ("the rocks shouldnt despawn, they should bounce into the
# background off a little messed up board"): a snapped catwalk board at the fallen beam's
# foot, propped on a heap of rubble. A rock coming off the beam runs onto it and is thrown
# up and back, into the dark behind the gallery; it drops out of sight behind the
# gallery's own floor and is gone there (the floor's top is y 57.4, the rock under it 2 m
# deep). They used to blink out 3 s after they fell, wherever they were.
A.board((-223.25, 57.47), (-224.6, 58.03), p2=(-225.15, 57.93), throw=(-1.4, 5.2, -3.3), depth=-2.3, gone=56.5)
A.deco("rubble_pile", -224.55, 57.4, z=0.1, size=(1.1, 0.58, 0.36), tone="rock2")  # its prop (the size sets its scale)
A.effect("dust", (-222.1, 61.0, -218.5, 77.0), density=0.5)
A.ledge(-230.0, -222.1, 72.0, "rock", t=0.5)  # the top drift
A.ledge(-233.2, -229.6, 72.0, "plank", t=0.35)  # its balcony into the throat
A.challenge("1.10", "El Derrumbe", (-225.5, 57.4), 3, "B", moves=[
    ["reach", [-218.9, 61.4], [-219.25, 63.0]], ["reach", [-219.25, 63.0], [-219.25, 64.3]],
    ["fling", [-219.25, 64.3], [-221.35, 65.2], "F1"], ["reach", [-221.35, 65.2], [-221.5, 66.5]],
    ["reach", [-221.5, 66.5], [-221.35, 67.8]], ["fling", [-221.35, 67.8], [-219.25, 68.7], "F1"],
    ["reach", [-219.25, 68.7], [-219.1, 70.0]], ["fling", [-219.1, 70.0], [-221.35, 70.9], "F1"],
    ["reach", [-221.35, 70.9], [-222.1, 72.0]]])

# ================================================================ 1.11 La Cortina
# Fourteen rows of two holds, from the balcony to the top of the dry shaft.
# THE WET IS A DRIP YOU CAN WATCH (Parker 11-12, in order: "if these are going in and out
# of the wall, give them an in and out animation" ... "actually we will have it be wet
# drippy like it is, but make it so there is more of an indication of what is going on",
# and "maybe like a slow moving water drip you can watch fall down and get them wet").
# The holds never moved: the spray soaked each in turn and all that showed was a hold
# going near-black on a dark wall. Now a fat drip runs slowly down each column, 1 m/s, one
# every 7 m. A hold goes wet as the drip reaches it, stays wet 2 s, and is dry for 5
# (it was wet 2.6, dry 3.4, the wet coming down at 1.8 m/s with nothing to see). The two
# columns are half a turn apart, so one hold of every pair is always dry. Wet, a hold is a
# shiny blue-grey and drips. FIRST-TRY NUMBERS: the speed, the gap, the 2 s.
# And five holds never get wet (from "make some of them not go in and out and make them a
# differnt color"): pale bone, one in every third row, swapping sides: the rests.
ROW0_Y, ROW_DY, ROWS = 73.3, 1.25, 14
DRIP_SPEED, DRIP_GAP, DRIP_WET = 1.0, 7.0, 2.0
DRIP_TOP_Y, DRIP_FOOT_Y = 89.9, 72.4            # from the lip, where the fall's curtain spills, to under the bottom row
ALWAYS_DRY = {1: 0, 4: 1, 7: 0, 10: 1, 13: 0}   # row -> which side (0 west, 1 east)


def _col_x(y, side):
    return -235.6 + 0.11 * (y - ROW0_Y) / ROW_DY + 1.3 * side


CORTINA = []
# Their looks (a1_dress item 8): iron staples whose feet are in the throat's back wall (its face
# at z -1.6), five of them bent; the five dry rests bound in pale cord. A wet one shows its wet
# on the staple. (The five bent: my pick, spread up the climb.)
BENT = {(2, 1), (5, 0), (8, 1), (11, 0), (12, 1)}
for side in (0, 1):
    _top = (_col_x(DRIP_TOP_Y, side), DRIP_TOP_Y)
    A.drips(_top, (_col_x(DRIP_FOOT_Y, side), DRIP_FOOT_Y), speed=DRIP_SPEED, gap=DRIP_GAP, phase=3.5 * side)
    for r in range(ROWS):
        y = ROW0_Y + ROW_DY * r
        x = _col_x(y, side)
        look = "mine_staple_bound" if ALWAYS_DRY.get(r) == side else ("iron_staple_bent" if (r, side) in BENT else "iron_staple")
        if ALWAYS_DRY.get(r) == side:
            A.hold(x, y, r=0.26, kind="bone", skin=look)
        else:
            A.hold(x, y, r=0.24, kind="rock", skin=look, hold={
                "type": "wet", "on": DRIP_WET, "off": DRIP_GAP / DRIP_SPEED - DRIP_WET, "look": "water",
                "phase": Area.drip_phase(_top, (x, y), DRIP_SPEED, DRIP_GAP, 3.5 * side)})
        A.deco(look, round(x, 3), round(y, 3), z=-1.6, size=(0.4, 0.1, 0.25), tone="iron", skin=True)
for r in range(ROWS):
    y = ROW0_Y + ROW_DY * r
    CORTINA.append((_col_x(y, 0), _col_x(y, 1), y))
cortina_moves = [["reach", [-233.2, 72.0], [round(CORTINA[0][1], 2), CORTINA[0][2]]]]
for r in range(ROWS - 1):  # the lint's line: up the right-hand holds (any zigzag is shorter than 1.9 too)
    cortina_moves.append(["reach", [round(CORTINA[r][1], 2), CORTINA[r][2]], [round(CORTINA[r + 1][1], 2), CORTINA[r + 1][2]]])
cortina_moves.append(["reach", [round(CORTINA[-1][1], 2), CORTINA[-1][2]], [-232.0, 89.7]])  # the lip
# (MINE_PASS F-C5: moved under La Esclusa, its east 3.5 m ran on under the section's rock in a 0.3 m slot. Trimmed to
# the alcove, x -291 .. -288 after the move.)
A.ledge(-232.0, -229.0, 89.7, "rock", t=0.5)  # the alcove's floor at La Cortina's top (was the roof's grip under A2's lip ledge)
# A ROPE FROM THE TOP, TO HALF WAY (Parker 11-12: "make a rope hanging about half way down
# this challenge", and of a short rope in the middle or a long one from the lip: "b").
# It hangs from an iron bracket under the lip, a hand east of the east column, 8 m long:
# its tail is by rows 6 and 7. From there the upper half can be climbed on the rope, which
# never gets wet, and the lip is a short step from its top.
ROPE_X = -232.42
A.box(ROPE_X + 0.2, 89.52, 0.5, 0.12, "iron")   # the bracket, out of the shaft's east wall
A.rope("cuerda_cortina", (ROPE_X, 89.4), 8.0, kind="rope")
A.challenge("1.11", "La Cortina", (-231.4, 72.0), 3, "A", moves=cortina_moves)
# A LIFE RING AT THE FOOT OF THE WET SLAB (Parker 11-12: "add a bouncy lifesaver here that
# lunches you back at least to the ledge on the right"). Whoever comes off the balcony or
# the first rows lands on the awning, slides to its foot and went into the fall: the whole
# mine. Del Mar's life ring is propped there now, facing up and east. It throws a body
# the same way however it arrives: up 10 m and back onto the balcony.
RING_THROW = (1.9, 8.6)   # m/s. FIRST TRY, set by dropping a climber on it (see the work log)
# (MINE_PASS F-C8: 0.4 m east, so the block no longer stands 0.35 m into the great falls' column; the throw is the same.)
A.bounce((-237.85, 63.3), (-236.45, 62.95), 8.8, look="ring", throw=RING_THROW, model="float_lifesaver", model_scale=1.45)
A.solid([(-237.95, 62.0), (-237.35, 62.0), (-237.35, 62.3), (-237.8, 63.05), (-237.95, 63.05)], "wet")  # the block it is propped on

# ================================================================ cameras (the smallest zone you are in wins)
A.cam((-178.0, -19.0, -148.0, -6.0), 4.6)  # the gallery
A.cam((-173.0, -8.0, -167.0, 6.5), 5.5)  # the ladder shaft
A.cam((-200.0, 3.0, -176.0, 12.0), 9.0, bias=(0.0, -4.0))  # catwalk and rope: the drop
A.cam((-203.0, 12.0, -186.0, 30.0), 8.0, bias=(0.0, -2.0))  # the hoist
A.cam((-204.0, 26.0, -198.0, 40.0), 8.0, bias=(2.0, -3.0))  # the banded wall
A.cam((-234.0, 26.0, -200.0, 50.0), 12.5, bias=(-8.0, -4.0))  # the cart: its road, the lip and the chain (note 103)
A.cam((-233.0, 46.0, -212.0, 55.0), 13.0, bias=(0.0, -7.0))  # Las Vigas: the whole drop
A.cam((-238.5, 51.0, -229.0, 62.5), 7.0, bias=(0.0, 1.0))  # the wheel
A.cam((-223.0, 57.0, -218.0, 78.0), 7.0, bias=(0.0, 2.5))  # the cave-in: look up
A.cam((-238.0, 70.0, -229.0, 91.0), 10.0, bias=(-2.0, -3.0))  # La Cortina
A.cam((-248.0, -34.0, -186.0, -20.0), 8.0, bias=(0.0, 4.0))  # in the Sump: look up at what you lost

# ================================================================ lanterns
LANTERNS = [(-154.0, -8.6), (-166.5, -8.6), (-170.0, -1.0), (-174.6, 9.2), (-184.5, 9.0), (-200.3, 9.4),
            (-196.5, 16.6), (-196.5, 28.8), (-200.2, 34.0), (-203.8, 43.4), (-210.8, 43.4), (-216.1, 53.2),
            (-226.3, 53.6), (-232.0, 60.6), (-226.0, 60.4), (-220.3, 66.8), (-226.0, 75.0), (-231.3, 80.0),
            (-188.6, -24.4)]
# (The lanterns themselves are a1_dress's now, out of the play space; their 21 lights follow
# them: a1_dress.LANTERN_LIGHTS, filled when it dresses the area, below.)
for x, y in ((-241.0, -24.0), (-225.0, -26.0), (-212.0, -26.0), (-241.0, 40.0), (-241.0, 82.0)):
    A.light(x, y, color="#9FD0FF", rng=14.0, energy=0.9, z=2.2)  # the water's own cold light: the drop is lit

# ================================================================ the picture
A.card([(-256, -40), (-146, -40), (-146, -8), (-178, 2), (-206, -6), (-232, 6), (-256, 0)], z=-14.0, tone="back3")
A.card([(-150, 94), (-150, 26), (-168, 40), (-190, 44), (-204, 58), (-226, 62), (-226, 94)], z=-10.0, tone="back3")
A.card([(-256, 94), (-256, 20), (-250, 34), (-247, 60), (-249, 94)], z=-4.0, tone="back")  # behind the fall
A.card([(-178, -8), (-150, -8), (-150, 8), (-170, 7), (-178, 4)], z=-3.0, tone="back")
A.card([(-196, 56), (-190, 44), (-186, 49), (-181, 41), (-176, 43), (-170, 35), (-164, 38), (-158, 30), (-150, 32), (-150, 60)], z=3.0, tone="slick")  # stalactites, in front
A.card([(-256, -40), (-146, -40), (-146, -33), (-200, -35), (-256, -33)], z=4.0, tone="slick")
A.card([(-150, 6), (-150, 30), (-158, 26), (-160, 14), (-166, 12), (-168, 6)], z=-4.0, tone="back")  # old stopes, far side
A.deco("station_scaffold", -160.0, 12.5, z=-4.6, scale=1.5, size=(4.0, 6.0, 2.0), tone="wood")  # workings nobody reaches now
A.deco("lantern_hang", -162.0, 19.4, z=-4.4, size=(0.3, 0.5, 0.3), tone="gold")
A.light(-162.0, 18.9, color="#FFB860", rng=8.0, energy=0.9, z=-3.0, flicker=True)
for x, y, m in ((-209.0, 55.0, "stalactite_a"), (-203.0, 55.0, "stalactite_b"),
                (-190.0, 50.9, "stalactite_a"), (-172.0, 40.0, "stalactite_b"), (-160.0, 34.0, "stalactite_a")):
    A.deco(m, x, y, z=-1.7, size=(0.8, 3.0, 0.8) if m.endswith("_a") else (1.5, 6.0, 1.5), tone="slick")
A.deco("papel_tatters", -226.0, 74.6, z=-1.4, scale=0.85, size=(8.0, 1.0, 0.05), tone="accent")
A.deco("mine_frame", -152.0, -12.6, z=0.0, size=(0.6, 5.0, 2.6), tone="wood")  # the door's timber set (a0_dress item 9: mine_frame_broken when it lands)
A.deco("mine_frame", -176.0, -12.6, z=0.0, size=(0.6, 5.0, 2.6), tone="wood")  # the gallery's mouth
A.deco("mine_frame", -230.0, 72.0, z=0.0, scale=0.8, size=(0.6, 5.0, 2.6), tone="wood")  # the top drift's mouth
for x in (-150.0, -153.6):
    A.deco("rail_straight", x, -12.7, z=0.0, scale=0.9, size=(4.0, 0.25, 1.2), tone="iron")  # the rails end at the mud
A.effect("drips", (-176.0, 6.0, -172.0, 12.0))  # every rest has its unease
A.effect("drips", (-201.9, 6.0, -197.9, 13.0))
A.effect("drips", (-199.8, 26.2, -191.9, 32.0))
A.effect("drips", (-208.9, 40.0, -201.9, 48.0))
A.effect("drips", (-237.2, 52.5, -232.2, 56.0))
A.effect("drips", (-233.2, 72.0, -222.1, 76.0))

# ================================================================ the dress (the modelling run's)
a1_dress.dress(A)
# (MINE_PASS F-C4, the Director: the join's foreground post, timber below and brick above, stood in front of the
# climber at 1.12's start once the mine moved: out. a1_dress places it; it is taken out here.)
A.decos[:] = [d for d in A.decos if not (abs(d["at"][0] + 237.025) < 0.4 and d["at"][2] > 1.2 and 85.5 < d["at"][1] < 90.0)]
# (a1_dress item 9: the water wheel behind La Polea Grande turns with the winding wheel; the
# pulley over the hoistway turns, stops and turns back with the lift's counterweight)
A.follow("water_wheel", (-234.2, 57.4), "polea_grande", "spin")
A.follow("pulley", (-188.95, 31.4), "cubo_peso", "roll", r=0.4)
for x, y in a1_dress.LANTERN_LIGHTS:
    A.light(x, y, color="#FFB860", rng=10.0, energy=1.5, flicker=True)

# THE PITS' INSIDES CAN'T BE HELD (note 52; Parker 11-13: all the slots the check finds,
# `python tools/peak/checks.py pits`): each inside face lined slick under its lip.
A.line_pit(-201.00, -200.40, 14.20)
A.line_pit(-232.20, -231.80, 52.30)


# THE INSIDE'S OWN DARK (the Director, 11-14): the mountain's body card is cut away over this biome
# (st.py BODY_WINDOWS); behind the far wall a backstop in this biome's darkest tone, so no gap shows
# the body's grey-tan, or the sky.
A.card([(-298, -42), (-142, -42), (-142, 96), (-298, 96)], z=-11.6, tone="back3", edge=False)

A.end_shift()  # (everything above is moved by MOVE at save; La Esclusa, below, stands where it is written)

# ================================================================ LA ESCLUSA (note 146): the new section, x -303 .. -222, y 73 .. 90
# Between the moved mine's roof (73) and the black waters' floor, under their east end: the keepers'
# ladder straight up beside the great falls, 1.12 Los Barriles (the flume, the barrels running west to a
# kicker that throws them into the background), and 1.13 La Esclusa (the lock that floats you up to El
# Borde). Every number from the design pages (design/rearrange_146/make_rearrange.py, final at 35c3f2e).
# Scenery: plain stand-ins until the makers come.
from shapely.geometry import Polygon as _Poly, box as _sbox
from shapely.ops import unary_union as _union

FALLS = (-303.0, -297.0)        # the great falls' shaft: 6 m, the same all the way down (middle x -300, the well's)
MINE_TOP = 73.0                 # the moved mine's roof: the floor at La Cortina's top
STRIP_E = -295.0                # the strip the ladder stands in, beside the falls
LADDER_X = -295.4
LADDER_RUNGS = [73.8, 74.55, 75.3, 76.8, 77.55, 79.05]   # every 0.75 m, two gone: 1.5 m reaches
LIP_ROOM = (-295.0, 73.0, -288.0, 75.2)   # the low room under the platform; its east end (x -291 .. -288) the alcove
BED = 75.7                      # the flume's bed; its water's bottom
S = 77.2                        # the flume's surface
FLUME = (-290.5, -258.5)
CEIL_W, CEIL_E = 83.0, 86.0     # the black waters' rock starts here: west and east of x -292
LANDING = 79.4                  # the landings' tops
WEST_LANDING = (-295.0, -290.5) # the platform on the flume's west end
EAST_LANDING = (-260.4, -258.5)
QUAY = (-258.5, -245.0)
WHIRL = (-287.6, -285.4)        # the whirlpool, 1 m east of the kicker
PIPE = [(-287.05, 75.7), (-285.95, 75.7), (-285.95, 74.0), (-287.0, 73.1), (-288.0, 73.1), (-288.0, 74.2), (-287.05, 74.6)]
KICKER = [(-287.6, 77.05), (-290.4, 78.25)]   # the tipping ramp: barrels run up it and are thrown up and back
KICK_THROW = (-0.6, 4.5, -3.5)                # FIRST GUESS (note 91's kind)
CHUTE = (-291.4, -286.4, 78.6, 82.2)          # the waste chute's mouth in the back wall, where they go
GATE = (-245.0, -244.0)         # the lock's lower gate (its wicket 79.4 .. 81.9)
LOCK = (-244.0, -228.0)         # the chamber, 16 m; the slot (where the river comes in) at its west end
LOCK_FLOOR, LOCK_CEIL = 75.7, 89.0
LOCK_LOW, LOCK_HIGH = 77.2, 88.5
RISE, HOLD, DRAIN = 6.0, 3.0, 5.0           # 14 s, no pause at the bottom (Parker: "keep it 14 s")
CYCLE = RISE + HOLD + DRAIN
SLOT = (-244.0, -238.0)         # the black waters' slot (as today)
PIER = (-238.0, -236.0)
DRY = (-236.0, -232.0)          # the old dry shaft, up to El Borde's lip ledge
L0 = (-244.0, -242.6, 79.4)     # the wicket's sill, into the lock
L1 = (-239.6, -238.2, 83.0)
L2 = (-229.6, -228.0, 81.0)
DRY_RUNGS = [(-228.25, 84.8), (-228.25, 85.8), (-228.25, 86.8)]
BARREL_SPEED = 0.55             # the barrels: speed, spacing, road and count as today (a2.py), now running WEST
BARREL_GAPS = [3.0, 3.4, 2.9, 5.8, 3.1, 3.5, 2.9, 6.2]
KICK_X = -288.6                 # the end of their line
ROAD = 26.8
COVE_X = round(KICK_X + ROAD, 2)  # -261.8: born in the tunnel at the flume's head
BARREL_Y = round(S + 0.3, 2)
ARCH = (-264.55, -259.05)       # the tunnel's mouth at the flume's head
BARREL = [(-0.9, -0.3), (-0.6, -0.55), (0.6, -0.55), (0.9, -0.3), (0.9, 0.3), (0.6, 0.55), (-0.6, 0.55), (-0.9, 0.3)]


def _box(x0, y0, x1, y1, kind, **kw):
    A.solid([(x0, y0), (x1, y0), (x1, y1), (x0, y1)], kind, **kw)


def _hanging(x0, x1, y, kind="stone", t=0.7):
    """A slick body with a pale grip coping on top (a2's slab)."""
    _box(x0, y - t, x1, y - 0.2, "wet")
    _box(x0, y - 0.3, x1, y, kind)


def _section_rock():
    air = _union([_sbox(FALLS[0], MINE_TOP, STRIP_E, CEIL_W), _sbox(*LIP_ROOM),
                  _sbox(WEST_LANDING[0], LANDING, FLUME[0], CEIL_W), _sbox(FLUME[0], BED, FLUME[1], CEIL_W),
                  _sbox(FLUME[1], LANDING, GATE[0], CEIL_E), _sbox(GATE[1], LOCK_FLOOR, LOCK[1], LOCK_CEIL),
                  _sbox(GATE[0], LANDING, GATE[1], LANDING + 2.5),
                  _sbox(SLOT[0], 84.0, SLOT[1], 89.4), _sbox(DRY[0], 84.0, DRY[1], 89.4), _Poly(PIPE)])
    shell = _Poly([(-307.0, MINE_TOP), (-222.0, MINE_TOP), (-222.0, 89.4), (-252.0, 89.4), (-252.0, CEIL_E),
                   (-292.0, CEIL_E), (-292.0, CEIL_W), (-307.0, CEIL_W)])
    rock = shell.difference(air)
    todo = list(getattr(rock, "geoms", [rock]))
    while todo:
        p = todo.pop()
        if p.geom_type != "Polygon" or p.area < 0.05:
            continue
        if len(p.interiors):  # (a solid has no holes: split through the first)
            x0, y0, x1, y1 = p.bounds
            cx = p.interiors[0].centroid.x
            for half in (_sbox(x0 - 1, y0 - 1, cx, y1 + 1), _sbox(cx, y0 - 1, x1 + 1, y1 + 1)):
                g = p.intersection(half)
                todo.extend(getattr(g, "geoms", [g]))
            continue
        A.solid([(round(x, 3), round(y, 3)) for x, y in list(p.simplify(0.005).exterior.coords)[:-1]], "wet")


_section_rock()
_box(PIER[0], LOCK_CEIL, PIER[1], 89.4, "wet")              # the pier's foot between the slot and the dry shaft
_box(-297.0, MINE_TOP - 0.29, -295.0, MINE_TOP + 0.01, "stone")  # the pier's top, coped: the ladder's foot, 1.12's start (1 cm proud of the mine's roof: no shared plane)
# ---------------------------------------------------------------- 1.12 Los Barriles
# Up the keepers' ladder beside the falls (6.4 m, 1.6 m from their edge, in their spray) to the platform;
# down onto the barrels coming at you from the east, barrel to barrel against the current, and up onto the
# east landing and the quay. A fall in: the current takes you west into the whirlpool by the kicker, down
# its pipe, and out in the alcove at La Cortina's top, 4 m from the ladder (Parker, 11-14).
A.ladder(LADDER_X, LADDER_RUNGS, w=0.5, kind="iron")
_box(WEST_LANDING[0], LANDING - 0.3, WEST_LANDING[1], LANDING, "stone")   # the platform's coping
_hanging(EAST_LANDING[0], EAST_LANDING[1], LANDING)                         # the east landing, over the flume's head
_box(QUAY[0], LANDING - 0.3, QUAY[1], LANDING, "stone")                     # the quay, on to the lock's gate
A.water((FLUME[0], BED, FLUME[1], S), S, flow=(-1.0, 0.0), look="flume")    # the flume: it runs WEST, 1 m a second
_loop = sum(BARREL_GAPS)
_t = 0.0
for i in range(8):
    A.mover("esclusa_barril%d" % (i + 1), (COVE_X, BARREL_Y), [(BARREL, "wood")],  # (ids are the mountain's: a2 had barril1 ..)
            {"type": "path", "pts": [[COVE_X, BARREL_Y], [KICK_X, BARREL_Y]], "speed": BARREL_SPEED, "mode": "wrap",
             "wait": round((_loop - ROAD) / BARREL_SPEED, 3), "phase": round(_t / BARREL_SPEED, 3), "trigger": "none",
             "loose": round(COVE_X - (KICK_X + 1.35), 3), "mass": 60.0, "push": 1.3, "tip": 1.5,
             "emerge": {"depth": -6.0, "over": 2.4}}, model="aguas_barrel")  # (note 114, MINE_PASS F-C9: born deep in the dark)
    _t += BARREL_GAPS[i]
# THE KICKER: a loose barrel runs up the tipping ramp and is thrown up and back into the waste chute's mouth
# in the back wall (never into the falls, 8 m west). The game kicks a loose barrel that meets a board.
# (MINE_PASS F-C2: not a step: slick and dark, not the red-orange of a hold; its model made to the board.)
A.board(KICKER[0], KICKER[1], throw=KICK_THROW, depth=-3.0, gone=79.6, t=0.22, model="esclusa_tipping_ramp",
        made=round(math.dist(KICKER[0], KICKER[1]), 2), kind="grease")
# THE WHIRLPOOL AND ITS PIPE: a body under the water here goes down the pipe and out of its mouth in the
# alcove's east wall (x -288, y 73.1 .. 74.2), onto the alcove's floor, as a ride, not a fall.
A.zones.append({"type": "pipe", "rect": [WHIRL[0], BED, WHIRL[1], S + 0.3], "to": [-289.2, 73.75], "vel": [-1.4, 0.4]})  # (a floating body's middle rides at the surface)
A.ride((-291.0, 72.6, WHIRL[1], S + 0.4))
A.effect("mist", (WHIRL[0], S - 0.2, WHIRL[1], S + 0.5), density=0.6)
A.challenge("1.12", "Los Barriles", (-296.0, 73.0), 3, "B", moves=(
    [["reach", [LADDER_X, LADDER_RUNGS[i]], [LADDER_X, LADDER_RUNGS[i + 1]]] for i in range(len(LADDER_RUNGS) - 1)]
    + [["reach", [LADDER_X, LADDER_RUNGS[-1]], [WEST_LANDING[0], LANDING]]]))
# ---------------------------------------------------------------- 1.13 La Esclusa
# The lock: 14 s, 6 rising, 3 held, 5 draining, no rest at the bottom. In through the wicket while the water
# is under its sill (2.1 s of each cycle), catch the rise on the sill, swim across as it lifts you (10.3 m
# in 8.1 s), out of the old dry shaft onto El Borde's lip ledge at the top. The river comes down the back
# wall without pushing.
_box(GATE[0], LANDING - 0.3, L0[1], LANDING, "stone")       # the wicket's sill, running in as the lowest ledge (L0)
_box(GATE[0], LANDING + 2.5, GATE[1], LOCK_CEIL, "grease")  # the lower gate above the wicket
_box(GATE[0], LOCK_FLOOR, GATE[1], LANDING - 0.3, "grease") # and below it
for x0, x1, y in (L1, L2):
    _box(x0, y - 0.55, x1, y - 0.25, "wet")
    _box(x0, y - 0.3, x1, y, "stone")
for x, y in DRY_RUNGS:
    _box(x - 0.25, y - 0.07, x + 0.25, y + 0.07, "iron")
A.water((LOCK[0], LOCK_FLOOR, LOCK[1], LOCK_HIGH), LOCK_LOW, flow=(0.0, 0.0), look="lock")
A.zones[-1]["lock"] = {"low": LOCK_LOW, "high": LOCK_HIGH, "rise": RISE, "hold": HOLD, "drain": DRAIN, "low_hold": 0.0, "phase": 0.0,
                       "warn": 1.0, "lever": [-253.5, LANDING]}  # (the keeper hauls his lever 1 s before each fill: his booth on the quay;
                                                              # `esclusa_keeper_lever`, frog and lever, drops in when made: MINE_PASS F-C1)
# The wicket: open (up into the gate) while the water is under its sill, from 13.03 s to 1.17 s of the
# next cycle: shut 11.86 s, opening and shutting in 0.2 s.
_open_at = CYCLE - (79.4 - LOCK_LOW) / (LOCK_HIGH - LOCK_LOW) * DRAIN    # 13.03 s: the drain under the sill
_shut_at = (79.4 - LOCK_LOW) / (LOCK_HIGH - LOCK_LOW) * RISE                      # 1.17 s: the rise over it
_open_for = CYCLE - _open_at + _shut_at
A.mover("portillo", (-244.5, 80.65), [(box_pts(0.0, 0.0, 0.9, 2.5), "grease")],
        {"type": "cycle", "to": [0.0, 2.5], "t_out": 0.2, "hold_out": round(_open_for - 0.4, 3), "t_in": 0.2,
         "hold_in": round(CYCLE - _open_for, 3), "phase": round(CYCLE - (_open_at - 0.1), 3)})
# The flap gate across the slot's foot: shut it holds the river off (a slick plate: what falls from El Borde
# waits on it), open through each rise it lets the river and whoever is in it down into the lock.
A.mover("compuerta", (-241.0, 89.175), [(box_pts(0.0, 0.0, 6.0, 0.35), "grease")],
        {"type": "cycle", "to": [-6.2, 0.0], "t_out": 0.4, "hold_out": RISE - 0.8, "t_in": 0.4,
         "hold_in": HOLD + DRAIN, "phase": 0.0})
A.effect("waterfall", (SLOT[0], LOCK_LOW, SLOT[0] + 1.8, LOCK_CEIL), z=-1.9, through=True)  # the river down the back wall
A.challenge("1.13", "La Esclusa", (-249.3, 79.4), 3, "B", moves=[["reach", [-233.0, 88.6], [-232.0, 90.0]]])
# ---------------------------------------------------------------- the section's cameras, light and stand-ins
A.cam((-297.5, 72.5, -290.0, 80.5), 5.5, bias=(1.0, 1.0))     # the ladder beside the falls
A.cam((-290.0, 75.0, -258.0, 82.8), 6.0, bias=(0.0, 0.5))     # the flume
A.cam((-258.0, 75.0, -226.0, 89.6), 7.5, bias=(0.0, 1.0))     # the lock
# (MINE_PASS F-C7: the seven stood in front of the play space and glared white on the roof and the gate: each under
# its lantern now, behind the climb.)
for x, y in ((-292.5, 81.5), (-277.9, 81.5), (-265.1, 81.5), (-259.5, 81.9)):  # the crane's post, two piers, the east landing
    A.light(x, y, color="#9FD0FF", rng=10.0, energy=1.1, z=-1.9)
for x, y in ((-253.5, 81.3), (-240.0, 84.7), (-228.8, 83.5)):  # the booth, by L1, over L2
    A.light(x, y, color="#6FE0D0", rng=9.0, energy=1.0, z=-1.9)   # the lock's three teal lanterns, steady
# The section's back wall (stand-in), cut away behind the falls (MINE_PASS F-C6: nothing between the column and the
# painted cavern far behind it).
_bw = _Poly([(-307.0, MINE_TOP), (-222.0, MINE_TOP), (-222.0, 89.4), (-252.0, 89.4), (-252.0, CEIL_E), (-292.0, CEIL_E),
             (-292.0, CEIL_W), (-307.0, CEIL_W)]).difference(_sbox(FALLS[0], MINE_TOP - 1.0, FALLS[1], CEIL_W + 1.0))
for _g in getattr(_bw, "geoms", [_bw]):
    A.card([(round(x, 3), round(y, 3)) for x, y in list(_g.exterior.coords)[:-1]], z=-2.4, tone="back", edge=False)
A.card([(CHUTE[0], CHUTE[2]), (CHUTE[1], CHUTE[2]), (CHUTE[1], CHUTE[3]), (CHUTE[0], CHUTE[3])], z=-2.3, tone="back3", edge=False)  # the waste chute's mouth
A.card([(ARCH[0], S - 0.1), (ARCH[1], S - 0.1), (ARCH[1], S + 2.6), ((ARCH[0] + ARCH[1]) / 2, S + 3.4), (ARCH[0], S + 2.6)],
       z=-2.3, tone="back3", edge=False)                                                       # the barrels' tunnel mouth
A.card([(-308.0, 72.0), (-221.0, 72.0), (-221.0, 90.5), (-308.0, 90.5)], z=-18.0, tone="back3", edge=False)  # its own dark, behind the cavern's painted far wall (MINE_PASS F-C6)

if __name__ == "__main__":
    A.save()
