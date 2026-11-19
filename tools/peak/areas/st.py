"""
ST: the mountain's shared structure. The well (El Pozo), the great falls and their shaft up
to the glacier, the frogs' slide, the outer slope below the cliffs, El Colmillo's lower half,
La Garganta and La Boca, El Tobogan (the slide tube to the river), the world's edges, and the
mountain's own card.
  python tools/peak/areas/st.py
"""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from peaklib import Area, box_pts, save_meta

A = Area("st", "cliffs")

# The east face: (x, y) from the trailhead to the summit, and the west face back down.
EAST = [(-34, 5.5), (-60, 60), (-90, 150), (-130, 260), (-150, 322), (-174, 400), (-180, 400), (-230, 578),
        (-251, 684), (-281, 784), (-307, 884), (-334, 962), (-350, 1000)]
WEST = [(-372, 958), (-505, 958), (-512, 900), (-525, 800), (-545, 700), (-520, 550), (-620, 250), (-700, 0)]
# (the summit v2, note 148: the mountain's west side carried out under the monastery's west flank, x -496)


def tube(centre, width, kind="scree"):
    """A slick pipe of air along `centre`, open at both ends."""
    left, right = [], []
    n = len(centre)
    for i, p in enumerate(centre):
        a = centre[max(0, i - 1)]
        b = centre[min(n - 1, i + 1)]
        dx, dy = b[0] - a[0], b[1] - a[1]
        L = math.hypot(dx, dy)
        nx, ny = -dy / L, dx / L
        left.append((p[0] + nx * width / 2, p[1] + ny * width / 2))
        right.append((p[0] - nx * width / 2, p[1] - ny * width / 2))
    air = left + right[::-1]
    kinds = {n - 1: None, len(air) - 1: None}  # the two ends
    A.cave(air, kinds, default=kind, thick=3.0)


# ---------------------------------------------------------------- the frogs' slide (notes 102, 148 and 143)
# THE SUMMIT v2 (11-19): the hot spring is inside the west shoulder (a11), and its slide leaves through the west
# face at 1000 m and pours down the west flank. At the flank's foot (x -496 .. -498, y 957) this pipe takes it, and
# everything else that slides off the west side: its mouth is between the flank's last lip and a tall slick wall
# 2.6 m west of it, which stops a body thrown west off the flank. It runs east under the summit's mass to 920 m.
# NOTE 143 (Parker: "the frog waterslide should connect to the great falls"; part two of 11-19's night): from there it
# drops straight down the mountain's west side, x -372 (its slabs 5.7 m west of the storm ridge's mass and 26 m west
# of the glacier's wall: it crosses neither's play space), turns east at 780 m and runs under the glacier's meltwater
# pool (its roof under the pool's bed, a9's, 780), and pours its rider out of the great falls' shaft's west wall,
# 12.5 m under the falls' head (FALLS_HEAD): the celebratory drop, all the way down the falls to the Sump.
FROG_SLIDE = [(-499.3, 957.0), (-499.3, 953.0), (-497.2, 949.4), (-490.0, 946.4), (-385.0, 923.6), (-375.2, 920.2),
              (-373.0, 917.0), (-372.2, 913.0), (-372.0, 908.0), (-372.0, 850.0), (-372.0, 792.0), (-371.6, 787.0),
              (-370.4, 782.6), (-368.0, 779.2), (-364.5, 776.9), (-360.0, 775.7), (-345.0, 774.6), (-310.0, 771.5), (-306.02, 771.5)]
# (Under the pool it falls 5 degrees to the mouth, its last 4 m level: run flat, a limp rider came to rest in the mouth,
# the probe, 11-19.)
FROG_W = 2.6
FROG_MOUTH = (FROG_SLIDE[-1][1] - FROG_W / 2, FROG_SLIDE[-1][1] + FROG_W / 2)  # its mouth in the shaft's west wall
_n0 = len(A.solids)
tube(FROG_SLIDE, FROG_W)
# (its corner filler at the mouth's top corner stood 0.27 m into the shaft's wall, two faces in one place: out)
A.solids[_n0:] = [_s for _s in A.solids[_n0:] if min(p[0] for p in _s["pts"]) < -306.05]
A.solid([(-503.6, 957.02), (-500.6, 957.02), (-500.6, 1003.0), (-503.6, 1003.0)], "wet")  # the catch wall west of the mouth


def _tube_air(centre, width):
    """The outline of a tube's air (as tube() lays it)."""
    left, right = [], []
    n = len(centre)
    for i, p in enumerate(centre):
        a, b = centre[max(0, i - 1)], centre[min(n - 1, i + 1)]
        L = math.hypot(b[0] - a[0], b[1] - a[1])
        nx, ny = -(b[1] - a[1]) / L, (b[0] - a[0]) / L
        left.append((round(p[0] + nx * width / 2, 3), round(p[1] + ny * width / 2, 3)))
        right.append((round(p[0] - nx * width / 2, 3), round(p[1] - ny * width / 2, 3)))
    return left + right[::-1]


# Its inside is dark (the tube's own back, 3 m behind the climb: the snow cap's white card stood behind its air).
A.card(_tube_air(FROG_SLIDE[3:], FROG_W + 0.4), z=-3.0, tone="#120F17", edge=False)
# THE OLD WAY OUT, FROZEN SHUT (note 143): the slide's old last leg, east through the storm ridge's foot (y 886.1 ..
# 888.7) onto the ridge's first ledge, is kept as it was where it lies inside the ridge's mass (a10 cuts its mass for it,
# and the mass's skin is made with the tunnel in it: a10_dress 7b; its slabs wear that skin), and a plug of black ice
# fills it 2.6 m in from its mouth. Nothing comes out of it any more, and nobody gets into it.
_OLD_LINE = [(-375.2, 920.2), (-370.0, 914.0), (-367.6, 906.0), (-367.0, 904.0), (-366.2, 896.0), (-365.4, 891.0),
             (-363.8, 888.2), (-361.0, 887.4), (-345.0, 887.4), (-330.0, 887.4), (-312.6, 887.4)]
_n0 = len(A.solids)
tube(_OLD_LINE, FROG_W)
A.solids[_n0:] = [_s for _s in A.solids[_n0:]
                  if min(p[0] for p in _s["pts"]) >= -361.5 and max(p[1] for p in _s["pts"]) <= 892.0]
for _s in A.solids[_n0:]:
    _s["skin"] = "tormenta_ridge_mass"
A.solid([(-318.0, 886.22), (-315.2, 886.22), (-315.2, 888.68), (-318.0, 888.68)], "blackice")  # the plug
# ("the celebratory drop all the way down": a ride, not a fall, wherever it lands)
A.ride((-505.0, 905.0, -360.0, 1004.0))  # down the summit's west flank and under it (12 degrees: the drop probe, 11-19)
A.ride((-381.0, 771.0, -360.0, 964.0))  # down the mountain's west side, behind the storm ridge and the glacier
A.ride((-372.0, 769.0, -303.0, 779.8))  # east under the glacier's pool, into the falls' shaft

# ---------------------------------------------------------------- THE GREAT FALLS (notes 142, 146 and 147)
# "The well (El Pozo del Diablo): a waterfall all the way from its top down to the black waters at the bottom" (note
# 142): one 6 m column, x -303 .. -297 (middle -300, the well's), down the well, through the black waters, La Esclusa
# and the mine to the Sump. NOTE 147 ("the great falls start at the glacier"; 11-19): its head is the glacier's
# meltwater pool (a9), which pours over its lip at x -303 into the column at 784 m; from there a shaft of its own,
# 6 m wide, carries it 286 m down through the mountain, west of the forge, the cliffs and the cableway, and through the
# well's cap at 494 m into the well. Drawn here, by the always-on area, so it shows from every area it passes, to its
# foot in the Sump (its surface -45, a1's water). `late`: the game builds it after every area, so it finds the Sump's
# water at its foot and churns it (st is built first).
FALLS_X = (-303.0, -297.0)
FALLS_HEAD = 784.0   # the meltwater pool's surface (a9.py POOL_S): the falls' head
FALLS_FOOT = -45.0   # the Sump's surface
A.effect("waterfall", (FALLS_X[0], FALLS_FOOT, FALLS_X[1], FALLS_HEAD), x=sum(FALLS_X) / 2, head=0.7, width=6.0, z=-0.6, late=True)
# A FALL DOWN THE COLUMN IS A RIDE (the Second Director, 11-19, on note 147's "ride down the falls"): whoever drops into
# it rides it to the bottom: no card, no fall counted, no cry. (So a miss at the well's crossings is a ride too, and so
# is a slip off La Pasarela Helada, or being carried over the pool's lip.) To 1.4 m over the head: under the bridge's
# boards (785.7), so whoever lands on the bridge has not passed through it.
A.ride((FALLS_X[0], FALLS_FOOT, FALLS_X[1], FALLS_HEAD + 1.4))
# AND IT PASSES THE CENSERS (a5's 5.11 swings them across the column under the well's cap): a rider coming down the
# shaft fast goes through them (peak_zones `through`; one in three lay on a bowl, the probes of 11-19). Slow bodies,
# 5.11's own climbers, meet them as ever.
A.zones.append({"type": "ride", "rect": [-303.5, 477.0, -296.5, 497.5], "through": ["sacrifice1", "sacrifice2"]})

# ---------------------------------------------------------------- THE FALLS' SHAFT (note 147)
# From the well's cap (498) up to the glacier's bed (780, a9's from there): two slick walls, each 3 m thick, the
# column's own width apart; the frogs' slide comes in through the west wall. Nothing in it grips, so nobody climbs it
# from the well. Behind it the well's black slot, and the shaft's dark rock either side of its walls, where the
# mountain's flat card stood (it showed between the areas, grey: the reviewer on the well's frames, 11-19).
SHAFT_TOP = 780.0
for (x0, x1), spans in (((-306.0, -303.0), [(498.0, FROG_MOUTH[0]), (FROG_MOUTH[1], SHAFT_TOP)]),
                        ((-297.0, -294.0), [(498.0, SHAFT_TOP)])):
    for y0, y1 in spans:
        A.solid([(x0, y0), (x1, y0), (x1, y1), (x0, y1)], "wet")
# (its back at z -1.21, just behind the play space: from 690 up the cableway's face body, a8_dress's, stands at z -1.25
# behind the shaft and showed through the falls, tan)
A.card([(-306.0, 499.5), (-294.0, 499.5), (-294.0, 781.1), (-306.0, 781.1)], z=-1.21, tone="#0B0A10", edge=False)


def _dark_rock(x0, y0, x1, y1, seed):
    """The well's and the shaft's dark rock, painted: a dark card with long wavy bands across it, a step lighter and a
    step darker by turns (in place of the mountain's flat card where no area stands beside the well)."""
    import random as _r
    rr = _r.Random(seed)
    A.card([(x0, y0), (x1, y0), (x1, y1), (x0, y1)], z=-6.6, tone="#1C1823", edge=False)
    y, k = y0 + rr.uniform(1.0, 3.0), 0
    while y < y1 - 1.5:
        h = rr.uniform(0.5, 1.2)
        tilt = rr.uniform(-1.2, 1.2) / (x1 - x0)  # (at most 1.2 m of fall across the card)
        n = max(2, int((x1 - x0) / 6.0))
        xs = [x0 + (x1 - x0) * i / n for i in range(n + 1)]
        bot = [(x, max(y0, y + tilt * (x - x0) + rr.uniform(-0.15, 0.15))) for x in xs]
        top = [(x, min(y1, y + h + tilt * (x - x0) + rr.uniform(-0.15, 0.15))) for x in xs[::-1]]
        A.card([(round(a, 3), round(b, 3)) for a, b in bot + top], z=-6.55,
               tone=("#262030" if k % 2 == 0 else "#15121A"), edge=False)
        y, k = y + h + rr.uniform(2.5, 6.0), k + 1


_dark_rock(-345.0, 498.0, -306.0, SHAFT_TOP, 21)    # west of the shaft
_dark_rock(-294.0, 544.5, -280.3, 701.5, 22)        # east of it, over the forge's roof, to the mountain card's open edge
_dark_rock(-294.0, 702.0, -282.0, SHAFT_TOP, 26)    # and on up beside the cableway (its face body stands in front)
_dark_rock(-380.0, 284.5, -311.0, 361.5, 23)        # beside the well: west, between the crystal cave and the temple
_dark_rock(-289.0, 188.5, -232.0, 257.5, 24)        # east, between the black waters and the garden
_dark_rock(-289.0, 384.5, -238.0, 469.5, 25)        # east, between the garden and the forge

# ---------------------------------------------------------------- El Pozo del Diablo
# Its walls where no area stands beside it, with the six doors left open.
for x0, x1, spans in (
    (-310.0, -306.0, [(176, 264), (278, 362), (382, 474), (488, 498)]),  # west wall
    (-294.0, -290.0, [(176, 262), (280, 364), (380, 474), (488, 498)]),  # east wall
):
    for y0, y1 in spans:
        # (beside the mushroom garden, y 280 .. 364, the east wall stood 1 m into the garden's hall,
        # x -291 .. -290: it stops at the garden's own wall line there. a4_dress 7a.)
        xe = -291.0 if (x0, y0) == (-294.0, 280) else x1
        # (beside the temple, y 382 .. 474, the west wall reached 1 m into the temple's air and lay
        # on the temple's own east slab: two faces in one place. The temple's slab is that wall
        # now (its skin templo_east_wall). a5_dress 7a.)
        if (x0, y0) == (-310.0, 382):
            continue
        # (and above the forge's door, y 488 .. 498, it lay on the forge's own west slab and reached
        # 1 m into the forge's air: the forge's slab is that wall now. a6_dress 7a.)
        if (x0, y0) == (-294.0, 488):
            continue
        A.solid([(x0, y0), (xe, y0), (xe, y1), (x0, y1)], "wet")
# The cap over the well room (to the forge's wall line, x -291), open for the falls' shaft (note 147) through a THROAT,
# x -299.8 .. -297.8, 10 m deep (494 .. 504), with a slick chamfer down to it from each of the shaft's walls. A body
# sliding down a wall is turned into it, meets one of its sides and leaves it falling straight down, its middle at
# x -299.5 .. -298.1: the well's one clear band (the temple's banner beam reaches x -300.9 at 380, the garden's root
# ledge x -296.5 at 279), between the censers' pivots (a5's 5.11, under the cap at x -303 and -297.1). (The probes of
# 11-19: down the east wall a rider landed on censer 2's chain; turned in by a short chamfer he went on west across the
# well and lay on the banner beam; leaving along the shaft's east wall he drifted onto the root ledge.)
A.solid([(-310, 494), (-299.8, 494), (-299.8, 498), (-310, 498)], "wet")
A.solid([(-297.8, 494), (-291, 494), (-291, 498), (-297.8, 498)], "wet")
A.solid([(-303.0, 498.0), (-299.8, 498.0), (-299.8, 504.0), (-303.0, 504.0)], "wet")  # the throat's sides
A.solid([(-297.8, 498.0), (-297.0, 498.0), (-297.0, 504.0), (-297.8, 504.0)], "wet")
A.solid([(-303.0, 504.0), (-299.8, 504.0), (-303.0, 510.0)], "wet")  # the chamfers
A.solid([(-297.8, 504.0), (-297.0, 504.0), (-297.0, 506.0)], "wet")
# AND IT LEAVES STRAIGHT: whoever reaches the throat's last 3 m leaves it at its foot, in the middle of the clear band,
# falling straight down at 16 m/s, with a burst of spray (peak_zones' pipe, as the flume's whirlpool takes a body; here
# it moves him 4.4 m at most). Bodies bounce in a slick throat: one went in at the east side and left it moving west
# onto the banner beam (the watch, 11-19).
A.zones.append({"type": "pipe", "rect": [-299.8, 494.0, -297.8, 497.0], "to": [-298.8, 492.6], "vel": [0.0, -16.0]})
A.card([(-312, 170), (-288, 170), (-288, 500), (-312, 500)], z=-5.0, tone="#0B0A10")
# THE WELL'S DARK IS MEANT, AND LOOKS IT (Parker 11-12, of flat black beside the garden's
# great cap: "another one of those weird black spots"). The well had one flat near-black
# card: it read as a piece missing. Now its sides step back into the depth, lighter near
# you and darker further in, ragged like old masonry, with a slot of black down the
# middle and a few far glints in it.
import random as _rnd
_w = _rnd.Random(11)
for _z, _tone, _reach in ((-3.2, "#2B2634", 2.0), (-4.1, "#1B1722", 3.3)):
    for _side in (-1, 1):
        _wall = -306.0 if _side < 0 else -294.0
        _pts = [(_wall + (-6.0 if _side < 0 else 6.0), 172.0)]
        _y = 172.0
        _in = []
        while _y < 498.0:
            _in.append((_wall - _side * (_reach + _w.uniform(-0.5, 0.5)), _y))
            _y += _w.uniform(5.0, 11.0)
            _in.append((_wall - _side * (_reach + _w.uniform(-0.5, 0.5)), min(_y, 498.0)))
        _pts += _in + [(_wall + (-6.0 if _side < 0 else 6.0), 498.0)]
        A.card(_pts, z=_z, tone=_tone, edge=False)
for _i in range(46):
    _gx, _gy, _gs = _w.uniform(-301.6, -298.4), _w.uniform(180.0, 492.0), _w.uniform(0.07, 0.16)
    A.card([(_gx - _gs, _gy), (_gx, _gy - _gs * 1.6), (_gx + _gs, _gy), (_gx, _gy + _gs * 1.6)], z=-4.9, tone="#7E789C", edge=False)

# ---------------------------------------------------------------- the outer slope, slick scree
# Below La Boca's east rim: the bare slope down to the trailhead (a body flung far east ends there).
A.wall([(-150, 322), (-130, 260), (-90, 150), (-60, 60), (-34, 5.5)], default="scree", thick=5.0, rock_on="right")
# The last slab's inner corner (-38.5, 3.3) stood inside the tunnel's air, 1.1 m over the cart's
# floor and 2.5 m in from the mouth: a rider's head met it (the modelling run's designer, 11-14).
# Lifted to the tunnel roof's underside, so the slab's foot runs above the mouth.
for s in A.solids:
    s["pts"] = [[-36.0, 7.4] if abs(q[0] + 38.504) < 0.05 and abs(q[1] - 3.329) < 0.05 else q for q in s["pts"]]
# The face from El Balcon's foot down into La Garganta.
A.wall([(-230, 574), (-180, 400)], default="scree", thick=5.0, rock_on="right")
# El Colmillo's lower half: the fang standing on the slope. Its west side is the throat's other wall.
A.solid([(-174, 400), (-150, 322), (-158, 684), (-172, 684)], "scree")

# ---------------------------------------------------------------- La Boca and El Tobogan
# The mouth at the throat's foot, x -180 to -174, and the tube down to the river's roof.
tube([(-177, 399), (-177, 380), (-174, 330), (-171, 280), (-172, 252), (-262, 178), (-262, 174)], 5.0)

# ---------------------------------------------------------------- the world's edges (unseen)
A.box(-116.0, 675.0, 4.0, 690.0, "void")  # the sky's east wall, above the slope
A.box(-300.0, 1080.0, 420.0, 4.0, "void")  # the lid (over the summit v2's spire, 1069)
A.box(-508.0, 990.0, 4.0, 260.0, "void")  # behind the summit (west of its catch wall)

# ---------------------------------------------------------------- the mountain itself, as one great card
body = EAST + WEST + [(-700, -40), (-34, -40)]
# A WINDOW BEHIND 0.3c's GAP (a0, x -124 .. -132: the tunnel's back walls are broken there and
# the far cavern, a0_dress's dsc_cavern_far at z -16, shows through): this card stood in front
# of it. It is cut away behind the gap; a card has no holes, so the body is drawn as two
# pieces either side of x -128 (their faces meet flush).
# AND THE CRYSTAL CAVE'S SPAN (the Director, 11-14: through the gaps behind the giants at 3.1, behind
# La Columna and at 3.10's west edge it showed as flat grey-tan, in front of the cave's own far wall,
# a3_dress's gruta_far_wall at z -10.25, x -466 .. -300, y 168 .. 284): cut away there too. Each
# window has a split through it, so no piece has a hole.
# AND EVERY INSIDE BIOME (the Director, 11-14: "inside the mountain the body card should not show"): the
# mine, the black waters, the garden, the temple and the forge too. Each interior keeps a backstop of
# its own darkest tone behind its far wall (its area file, z -11.6), so a gap shows the inside's dark.
# The climb in the open air (0, 7 to 11) keeps the body card.
# BUT FROM THE CLIFFS UP IT STANDS WEST OF THE CLIMB (the Director, 11-14: on the open east face the
# mountain's shoulder is on the WEST of the frame only, the far painted cards 12 m back, riscos_ and
# tele_shoulder_a..d; east of them is sky and the given far view). Above y 560 the body's east edge is
# OPEN_EDGE: the shoulders' west edges (x -280 by the cliffs, -310 by the cableway), then 15 to 20 m west
# of the route up the glacier and the storm ridge, and nothing above 950 m. The snow cap with it.
OPEN_EDGE = [(-224.0, 560.0), (-280.0, 566.0), (-280.0, 702.0), (-310.0, 702.0), (-310.0, 804.0), (-318.0, 886.0),
             (-330.0, 915.0), (-345.0, 940.0), (-372.0, 950.0), (-372.0, 1100.0)]


def _open_cut():
    from shapely.geometry import Polygon
    return Polygon(OPEN_EDGE + [(-100.0, 1100.0), (-100.0, 560.0)])


BODY_WINDOWS = [((-134.0, -13.0, -122.5, -4.0), -128.0),   # a0, 0.3c's gap
                ((-351.0, -53.0, -207.0, 73.0), -279.0),    # a1, the mine (moved 59 m west and 17 m down: note 146)
                ((-307.0, 73.0, -222.0, 90.0), -265.0),     # a1, La Esclusa above it (note 146)
                ((-207.0, -42.0, -148.0, 25.0), -178.0),    # a1, where the mine was, over the ride's incline (11-18)
                ((-466.0, 82.0, -222.0, 188.0), -344.0),    # a2, the black waters (its far wall's span)
                ((-466.0, 168.0, -300.0, 284.0), -383.0),   # a3, the crystal cave
                ((-294.0, 258.0, -186.0, 384.0), -240.0),   # a4, the garden (its far wall's span)
                ((-380.0, 362.0, -305.0, 488.0), -343.0),   # a5, the temple
                ((-297.0, 470.0, -236.0, 577.0), -265.0)]   # a6, the forge (to its east wall, under the crack)


def _body_with_window():
    from shapely.geometry import Polygon, box
    whole = Polygon(body).buffer(0).difference(_open_cut())
    for w, _ in BODY_WINDOWS:
        whole = whole.difference(box(*w))
    x0, y0, x1, y1 = whole.bounds
    xs = [x0 - 1] + sorted(sp for _, sp in BODY_WINDOWS) + [x1 + 1]
    for xa, xb in zip(xs, xs[1:]):
        part = whole.intersection(box(xa, y0 - 1, xb, y1 + 1))
        for g in getattr(part, "geoms", [part]):
            if g.geom_type == "Polygon" and g.area > 1.0:
                assert not g.interiors, "a body piece with a hole"
                A.card([(round(x, 3), round(y, 3)) for x, y in list(g.exterior.coords)[:-1]], z=-9.0, tone="#8C8273", edge=True)


_body_with_window()


def _snow_cap():
    from shapely.geometry import Polygon
    cap = Polygon([(-281, 784), (-307, 884), (-334, 962), (-350, 1000), (-372, 950), (-430, 800), (-380, 770), (-330, 800)])
    part = cap.difference(_open_cut())
    for g in getattr(part, "geoms", [part]):
        if g.geom_type == "Polygon" and g.area > 1.0:
            assert not g.interiors
            A.card([(round(x, 3), round(y, 3)) for x, y in list(g.exterior.coords)[:-1]], z=-8.8, tone="#F4F7FA")


_snow_cap()

# ---------------------------------------------------------------- the sky outside: cardboard clouds, far and near
import random
_r = random.Random(7)
for i in range(34):
    y = 540 + i * 14 + _r.uniform(-5, 5)
    face_x = -230 - (y - 578) * 0.27  # roughly where the east face is at this height
    x = face_x + _r.uniform(20, 130)
    _z, _s = -_r.uniform(26, 80), _r.uniform(1.4, 3.2)
    if y >= 560.0:
        continue  # (none from the wind cliffs to the summit: "no cloud of our own" there; the far layers carry the banks. a7_dress 7b, a8_dress 7c, a9_dress 7a, a11_dress 7c)
    A.deco("cloud_" + "abcde"[i % 5], x, y, z=_z, scale=_s, size=(8, 3, 0.2), tone="#FFFFFF")

if __name__ == "__main__":
    save_meta()
    A.save()
