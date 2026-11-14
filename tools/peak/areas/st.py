"""
ST: the mountain's shared structure. The well (El Pozo), the outer slope below the
cliffs, El Colmillo's lower half, La Garganta and La Boca, El Tobogan (the slide tube to
the river), the world's edges, and the mountain's own card.
  python tools/peak/areas/st.py
"""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from peaklib import Area, box_pts, save_meta

A = Area("st", "cliffs")

# The east face: (x, y) from the trailhead to the summit, and the west face back down.
EAST = [(-34, 5.5), (-60, 60), (-90, 150), (-130, 260), (-150, 322), (-174, 400), (-180, 400), (-230, 578),
        (-251, 684), (-281, 784), (-307, 884), (-334, 962), (-350, 1000)]
WEST = [(-372, 950), (-430, 800), (-520, 550), (-620, 250), (-700, 0)]


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


# ---------------------------------------------------------------- the frogs' slide (note 102)
# The hot spring's slide (a11, page 11.0) leaves the summit through its floor at 962 m between
# x -379.2 and -377.0. Where it joins the fall line below is not designed yet; for now (the
# Second Director, 11-14: "end it on the glacier's slide or the gap at 886 m, whichever the
# course makes simplest") it drops down the mountain's west side, turns east at 887 m through
# the storm ridge's foot (a10 cuts its mass there) and lets you out on the ridge's first
# ledge at 886 m (a9's), where the start of 10.1 is. A 2.2 m slick pipe.
FROG_SLIDE = [(-378.1, 963.5), (-378.1, 955.0), (-376.5, 944.0), (-372.5, 930.0), (-369.0, 916.0), (-367.0, 904.0),
              (-366.2, 896.0), (-365.4, 891.0), (-363.8, 888.2), (-361.0, 887.4), (-345.0, 887.4), (-330.0, 887.4),
              (-312.6, 887.4)]
_n0 = len(A.solids)
tube(FROG_SLIDE, 2.2)
# (Its slabs through the storm ridge's foot lie inside the ridge's mass, their fronts on the mass's front:
# they wear the mass's skin, which is made with the tunnel in it. a10_dress 7b.)
for _s in A.solids[_n0:]:
    if min(p[0] for p in _s["pts"]) >= -361.5 and max(p[1] for p in _s["pts"]) <= 892.0:
        _s["skin"] = "tormenta_ridge_mass"
# ("the celebratory drop all the way down": a ride, not a fall, wherever it lands)
A.ride((-381.0, 886.0, -360.0, 964.0))  # down the mountain's west side
A.ride((-366.5, 885.5, -313.0, 890.0))  # east through the storm ridge's foot

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
A.solid([(-310, 494), (-291, 494), (-291, 498), (-310, 498)], "wet")  # the cap over the well room (to the forge's wall line, x -291)
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
A.box(-240.0, 1032.0, 300.0, 4.0, "void")  # the lid
A.box(-392.0, 950.0, 4.0, 200.0, "void")  # behind the summit

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
                ((-292.0, -36.0, -148.0, 90.0), -220.0),    # a1, the mine
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
    if 560.0 <= y <= 890.0:
        continue  # (none over the wind cliffs, the cableway or the glacier: "no cloud of our own" there; the far layers carry the banks. a7_dress 7b, a8_dress 7c, a9_dress 7a)
    A.deco("cloud_" + "abcde"[i % 5], x, y, z=_z, scale=_s, size=(8, 3, 0.2), tone="#FFFFFF")

if __name__ == "__main__":
    save_meta()
    A.save()
