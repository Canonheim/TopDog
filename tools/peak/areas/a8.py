"""
A8 EL TELEFERICO: the broken cableway. Gondolas over a void.
  python tools/peak/areas/a8.py

The route, east then back west, always up:
  dock (688) -> line 1 -> line 2 -> the bare cable -> pylon 2 (landing 703, head 714.5)
  -> four chairs down to El Colmillo (703) -> the fang's overhang and slab to its top (725.4)
  -> the zipline west to the maintenance deck on pylon 2's roof (720)
  -> counterweights up to pylon 3's head (749) -> the dead gondola -> four express lines
  -> the high station's iced deck (786).

Outside, not sealed. Nothing here catches a fall: between the face and the fang is La
Garganta (X), east of the fang the bare slope (X and the cart ride).

THE TOWERS. A lattice tower drawn in this plane would be a wall (a 2D post can't be passed),
so every tower is a painted CARD behind the plane and only its fittings are solid: landings,
rungs, sheaves, heads. Pylon 2 alone has real legs, slick, below its landing (y 670..703),
so nobody climbs it from underneath.

THE CLOCKS. Lines 1 and 2 are the SAME loop (the same numbers), 12 m apart, half a lap of
exactly 12 m at 2 m/s, so they can never drift against each other. No `phase` is used
anywhere: a second car on a line gets the same loop written from the opposite corner, and
things that run against each other get their roads written from opposite ends.
"""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from peaklib import Area, box_pts, ngon, fling_speed

A = Area("a8", "cable")

STEEL = "#8E3A20"  # the towers' card paint (behind the plane: scenery)
WIRE = "#3A2A22"  # scenery cables


def rot_pts(pts, deg):
    c, s = math.cos(math.radians(deg)), math.sin(math.radians(deg))
    return [(x * c - y * s, x * s + y * c) for x, y in pts]


def wire(p0, p1, z=-0.5, t=0.09, tone=WIRE):
    """A scenery cable (a thin card): never solid."""
    dx, dy = p1[0] - p0[0], p1[1] - p0[1]
    L = math.hypot(dx, dy)
    nx, ny = -dy / L * t / 2, dx / L * t / 2
    A.card([(p0[0] + nx, p0[1] + ny), (p1[0] + nx, p1[1] + ny), (p1[0] - nx, p1[1] - ny), (p0[0] - nx, p0[1] - ny)],
           z=z, tone=tone, edge=False)


def tower(xw, xe, y0, y1, z=-1.2, bay=4.0, tone=STEEL):
    """A lattice tower as cards: two legs and a zigzag of braces. Scenery only."""
    for x in (xw, xe):
        A.card([(x - 0.16, y0), (x + 0.16, y0), (x + 0.16, y1), (x - 0.16, y1)], z=z, tone=tone, edge=False)
    y, flip = y0, False
    while y < y1 - 0.5:
        yt = min(y + bay, y1)
        a, b = ((xw, y), (xe, yt)) if flip else ((xe, y), (xw, yt))
        wire(a, b, z=z, t=0.14, tone=tone)
        y, flip = yt, not flip


# ---------------------------------------------------------------- the gondola
# The mover's point is the cable grip. The car hangs under it:
#   hanger 0 .. -1.5, roof rail at -1.5, a 1.0 m window, end walls -2.6 .. -3.7, floor at -3.7.
# 2.6 wide, 2.2 tall. A foot rail runs out past each end at floor level:
#   wr: the west rail (what you catch), eb: the east boom (what you launch from: its tip has
#   2.4 m of clear air round it but for the boom itself).
def car_shapes(wr=1.6, eb=2.4):
    sh = [
        (box_pts(0.0, -0.75, 0.12, 1.5), "iron"),  # hanger
        (box_pts(0.0, -1.5, 2.6, 0.14), "paint"),  # roof rail
        (box_pts(0.0, -3.7, 2.6, 0.16), "paint"),  # floor
        (box_pts(-1.23, -3.15, 0.14, 1.1), "paint"),  # end walls (the window is above them)
        (box_pts(1.23, -3.15, 0.14, 1.1), "paint"),
    ]
    if wr > 0:
        sh.append((box_pts(-1.3 - wr / 2, -3.7, wr, 0.1), "iron"))
    if eb > 0:
        sh.append((box_pts(1.3 + eb / 2, -3.7, eb, 0.1), "iron"))
    return sh


def gondola(mid, pts, speed, mode, wr=1.6, eb=2.4, wait=0.0):
    mo = {"type": "path", "pts": [list(p) for p in pts], "speed": speed, "mode": mode, "trigger": "none"}
    if wait:
        mo["wait"] = wait
    return A.mover(mid, pts[0], car_shapes(wr, eb), mo, model="gondola")


# ---------------------------------------------------------------- the east face (our stretch)
# Slick scree, 8 m of rock behind it, from a7's last point to a9's first. Nothing is built
# within 11 m of it but the two stations: what falls from above keeps falling.
FACE = [(-251.0, 684.0), (-256.6, 704.0), (-263.6, 727.0), (-270.8, 752.0), (-281.0, 784.0)]
A.wall(FACE, default="scree", thick=8.0, rock_on="left")

# ---------------------------------------------------------------- the dock (a7 built the deck, top 688, x -250..-236)
A.ledge(-240.0, -236.7, 688.7, "plank", t=0.7)  # the boarding gangway, on the deck's east end
A.box(-239.85, 689.3, 0.14, 1.2, "iron")  # its one rail post
A.box(-237.6, 688.76, 0.5, 0.12, "grease")  # the unease: a smear of grease on the boards
A.challenge("8.1", "Abordar", (-238.6, 688.7), 2, "A",
            moves=[["reach", [-236.7, 688.7], [-236.6, 689.7]]])

# ---------------------------------------------------------------- 8.1 line 1: the dock to pylon 1 and back
# A loop: out low, up round the bull wheel, back high, down at the dock.
#   low leg (-234.4, 693.4) -> (-228.4, 694.8): 6 across, 1.4 up = 6.16 m. The rises are
#   12 - 6.16 = 5.84 m, so half a lap is exactly 12 m: at 2 m/s a lap is 12 s, and with two
#   cars at opposite corners ONE PASSES THE DOCK EVERY 6 s.
#   A car comes down the dock leg (2.9 s), its west rail tip stops 1.0 m over the gangway's
#   edge, at (-236.6, 689.7), and it leaves east at once. It is within 1.9 m of the edge for
#   1.1 s of every 6 (stepped through in time, not guessed). Miss it and you are still on
#   the dock (A).
#   These cars' rails are 0.9 m west and 2.4 m east: 5.9 m tip to tip, so the car going up
#   one end of the 6 m loop and the car coming down the other never touch.
#   The return car's boom passes 1.2 m over the low line: 0.9 m over a head on a roof.
RUN, RISE = 6.0, 1.4
VERT = 12.0 - math.hypot(RUN, RISE)  # 5.839
D_LO = (-234.4, 693.4)
D_HI = (D_LO[0], D_LO[1] + VERT)
E_LO = (D_LO[0] + RUN, D_LO[1] + RISE)
E_HI = (E_LO[0], E_LO[1] + VERT)
gondola("g1a", [E_LO, E_HI, D_HI, D_LO], 2.0, "loop", wr=0.9)  # t=0: at the foot of the east rise
gondola("g1b", [D_HI, D_LO, E_LO, E_HI], 2.0, "loop", wr=0.9)  # t=0: the opposite corner, half a lap on

# Pylon 1's head: the one static thing out here. A perch over the bull wheel, 1.06 m over
# the hangers' highest point, reached by climbing a car's hanger. The 8.2 warp stands here.
A.ledge(-229.6, -227.2, 702.0, "iron", t=0.3)
A.box(-229.5, 702.5, 0.12, 1.0, "iron")
tower(-229.9, -226.9, 664.0, 706.0)

# ---------------------------------------------------------------- 8.2 line 2: gondola to gondola
# Line 2 is the same loop (the same numbers, so the same lap to the last decimal: the two
# lines can never drift) 12 m east, turning the other way round: up its WEST end, east along
# the top, down its east end, back west along the bottom.
# THE WINDOW: at t = 0, 6, 12 ... a line 1 car starts up its east rise and a line 2 car starts
# up its west rise, both at 2 m/s, side by side for 2.9 s. Boom tip (-224.7) to rail tip
# (-218.6): 6.1 m, level, no relative motion. fling_speed(6.1, 0) = 4.1 m/s (F2).
# Then line 1 goes home west and line 2 carries you east. Between them: La Garganta.
W_LO = (E_LO[0] + 12.0, E_LO[1])
W_HI = (W_LO[0], W_LO[1] + VERT)
E2_HI = (W_HI[0] + RUN, W_HI[1] + RISE)  # (-210.4, 702.04)
E2_LO = (E2_HI[0], E2_HI[1] - VERT)  # (-210.4, 696.2)
gondola("g2a", [W_LO, W_HI, E2_HI, E2_LO], 2.0, "loop", wr=0.9)
gondola("g2b", [E2_HI, E2_LO, W_LO, W_HI], 2.0, "loop", wr=0.9)
A.challenge("8.2", "De Góndola a Góndola", (-228.4, 702.0), 4, "X",
            moves=[["fling", [-224.7, 694.0], [-218.6, 694.0], "F2"]])

# ---------------------------------------------------------------- 8.3 El Cable: 13 m of bare cable
# Line 2's car comes down its east leg (t = 0 .. 2.9 of every 6 s) with its boom tip at
# x -206.7, y 698.3 falling to 692.5. The cable's frayed end hangs stiff beside it, 0.64 m
# east, from 700.0 down to 695.6: in reach for the first 1.4 s of that fall.
A.box(-206.0, 697.8, 0.12, 4.4, "iron")  # the frayed end (stiff)
A.ledge(-206.5, -205.3, 700.3, "iron", t=0.25)  # the clamp plate over it: one breath, 1.2 m wide
C0, C1 = (-206.0, 700.0), (-194.0, 705.0)  # the cable: 12 across, 5 up = 13.0 m (23 degrees)


def on_cable(s):
    L = math.dist(C0, C1)
    return (C0[0] + (C1[0] - C0[0]) * s / L, C0[1] + (C1[1] - C0[1]) * s / L)


# hand over hand, the body hanging under it. Two greased stretches, 1.6 m each: a full reach.
for s0, s1, kind in ((0.0, 3.1, "iron"), (3.1, 4.7, "grease"), (4.7, 7.8, "iron"), (7.8, 9.4, "grease"), (9.4, 11.3, "iron")):
    A.beam(on_cable(s0), on_cable(s1), 0.12, kind)
# The solid cable stops at s = 11.3 (-195.6, 704.3), your legs already against pylon 2's landing;
# its last 1.7 m, up onto the sheave, is a scenery wire so nobody hangs in the spokes.
wire(on_cable(11.3), C1)
A.challenge("8.3", "El Cable", (-205.9, 700.3), 4, "X",
            moves=[["reach", [-206.7, 697.6], [-206.0, 697.8]],
                   ["reach", list(on_cable(3.05)), list(on_cable(4.75))],
                   ["reach", list(on_cable(7.75)), list(on_cable(9.45))]])

# ---------------------------------------------------------------- 8.4 El Pilon: pylon 2
# Real legs, slick, from below the frame up to the landing. Above it the tower is a card
# and you climb its fittings: a sheave, a brace, a sheave turning the other way, a rung, the head.
A.box(-194.0, 686.4, 0.3, 32.8, "scree")  # legs, y 670 .. 702.8
A.box(-191.0, 686.4, 0.3, 32.8, "scree")
A.ledge(-196.0, -190.6, 703.0, "iron", t=0.3)  # the landing, 5.4 m: the cable ends 1.6 m over its west end
A.box(-190.9, 703.06, 0.5, 0.12, "grease")  # the unease: oil dripped from the sheave above
tower(-194.0, -191.0, 703.0, 719.4)
A.wheel("sheave1", (-194.6, 705.8), 1.0, 9.0, spokes=4, kind="iron", rim=0.16, spoke_t=0.14, hub=0.28)  # counter-clockwise: its west side goes DOWN
A.beam((-193.8, 708.4), (-191.2, 707.6), 0.16, "iron")  # brace
A.wheel("sheave2", (-190.9, 710.3), 1.0, -9.0, spokes=4, kind="iron", rim=0.16, spoke_t=0.14, hub=0.28)  # clockwise: its east side goes DOWN
A.beam((-194.5, 712.8), (-191.9, 712.8), 0.16, "iron")  # rung
A.ledge(-194.8, -190.8, 714.5, "plank", t=0.3)  # the head: a 4 m rest under the station roof
A.box(-194.5, 714.56, 0.5, 0.12, "grease")  # the unease
A.challenge("8.4", "El Pilón", (-194.7, 703.0), 3, "X",
            moves=[["reach", [-194.6, 703.0], [-194.6, 704.8]],
                   ["reach", [-194.6, 706.8], [-193.8, 708.4]],
                   ["reach", [-191.2, 707.6], [-190.9, 709.3]],
                   ["reach", [-190.9, 711.3], [-191.9, 712.8]],
                   ["reach", [-194.5, 712.8], [-194.8, 714.35]]])

# The station roof over the head, and the maintenance deck on its ridge (8.7 lands there).
# The roof is slick and 35 degrees: what lands on it slides off into the void, and nobody
# climbs from the head to the deck through it.
RIDGE = (-193.0, 719.45)
A.beam(RIDGE, (-197.6, 716.2), 0.3, "grease")
A.beam(RIDGE, (-187.6, 715.9), 0.3, "grease")

# ---------------------------------------------------------------- 8.5 Sillas Voladoras
# Four chairs on a line falling east to the fang: pivots 3.9 across and 2.6 down from each
# other (4.7 m). Hangers 3.2 m, swing 20 degrees each side (the seat moves 1.1 m each way),
# period 4 s. Phases 0, 1/2, 1/4, 3/4:
#   1 and 2, 3 and 4 swing against each other: seat edges close to 0.5 m and open to 4.9 m.
#   2 and 3 are a quarter out: 1.2 m to 4.2 m.
# Chair 1's seat edge comes to 0.6 m off the head (x -190.8). Chair 4's comes to 0.9 m off
# the fang's rib.
CHAIRS = [(-188.5, 716.5), (-184.6, 713.9), (-180.7, 711.3), (-176.8, 708.7)]
for i, (piv, ph) in enumerate(zip(CHAIRS, (0.0, 0.5, 0.25, 0.75))):
    A.pendulum("chair%d" % (i + 1), piv, 3.2, 20.0, 4.0, phase=ph, bob=(1.2, 0.25), kind="plank", rod=0.12, rod_kind="iron", model="chair")
A.challenge("8.5", "Sillas Voladoras", (-192.8, 714.5), 4, "X",
            moves=[["reach", [-190.8, 714.5], [-190.2, 713.4]],
                   ["reach", [-186.8, 713.4], [-185.5, 712.2]],
                   ["reach", [-175.15, 705.9], [-174.3, 705.9]]])

# ---------------------------------------------------------------- El Colmillo, from y 684 to its top
# Slick all over. Its west side leans out 3.6 m in 19 m (an 11 degree overhang) to a nose at
# (-176, 715), then a 38 degree slab runs back to the top. Its east side drops to the bare slope.
F_LO, F_HI = (-172.4, 696.0), (-176.0, 715.0)  # the overhang
S_LO, S_HI = (-174.8, 717.4), (-165.6, 725.0)  # the slab
A.solid([(-172.0, 684.0), (-158.0, 684.0), (-159.0, 698.0), (-161.5, 712.0), (-164.4, 725.0), S_HI, S_LO, F_HI, F_LO], "scree")


def on_face(y, out=0.0):
    """A point on the overhang at height y, `out` metres off the rock."""
    t = (y - F_LO[1]) / (F_HI[1] - F_LO[1])
    return (F_LO[0] + (F_HI[0] - F_LO[0]) * t - 0.982 * out, y - 0.186 * out)


def on_slab(s, out=0.0):
    L = math.dist(S_LO, S_HI)
    ux, uy = (S_HI[0] - S_LO[0]) / L, (S_HI[1] - S_LO[1]) / L
    return (S_LO[0] + ux * s - uy * out, S_LO[1] + uy * s + ux * out)


# ---------------------------------------------------------------- 8.6 El Colmillo: the overhang
A.ledge(-174.8, -173.5, 702.9, "rock", t=0.5)  # a foot ledge under the chairs: the only stance
A.patch(on_face(703.2), on_face(706.6), "rock", t=0.3)  # the rib chair 4 swings to: 3.4 m of grip
FANG_HOLDS = [on_face(y, 0.1) for y in (708.3, 710.1, 711.9, 713.7)]  # 1.83 m apart up the overhang
FANG_HOLDS.append((-176.15, 714.95))  # the nose
FANG_HOLDS.append((-175.43, 716.36))  # over it
FANG_HOLDS += [on_slab(s, 0.1) for s in (0.5, 2.3, 4.1, 5.9, 7.7, 9.5, 11.2)]  # the slab, 1.8 m apart
for hx, hy in FANG_HOLDS:
    A.hold(hx, hy, 0.2, "rock")
A.ledge(-166.6, -164.0, 725.4, "iron", t=0.4)  # the anchor plate on the top: 2.6 m
A.box(-164.25, 726.75, 0.2, 2.7, "iron")  # the zipline's anchor post
A.box(-166.35, 725.46, 0.4, 0.12, "grease")  # the unease: the plate's west lip is greased
_route = [list(on_face(706.6))] + [list(p) for p in FANG_HOLDS] + [[-166.6, 725.2]]
A.challenge("8.6", "El Colmillo", (-174.3, 702.9), 4, "X",
            moves=[["reach", _route[i], _route[i + 1]] for i in range(len(_route) - 1)])

# ---------------------------------------------------------------- 8.7 Tirolesa
# The trolley waits 2.7 m over the plate; its handle hangs 0.9 m under it (1.8 m over the plate).
# Grab it and it goes: 20 m west at 9 m/s (2.2 s), falling 3 m, and STOPS DEAD at (-186, 725.1),
# 4 m short of the maintenance deck (top 720, x -196..-190). The cable beyond is gone.
#   Let go AT the stop: feet at 722.1, moving (-8.9, -1.35): 0.84 s, 7.4 m, down at x -193.4.
#   Let go 0.3 s early: 2.7 m further back and 0.4 m higher: down at x -191.7.
#   Let go 0.45 s early: down at x -190.8, the east lip. Earlier is short: the slick roof,
#   then the void. So the window is the last 0.45 s of the ride.
#   Hold on past the stop and you are hanging 4 m short of the deck with the swing you
#   arrived with: one more chance, a 4 m fling. The trolley goes home 6 s later.
Z0, Z1 = (-166.2, 728.1), (-186.0, 725.1)
A.mover("zip", Z0, [(box_pts(0.0, 0.0, 0.5, 0.22), "iron"), (box_pts(0.0, -0.45, 0.06, 0.9), "iron"), (box_pts(0.0, -0.9, 0.7, 0.12), "paint")],
        {"type": "path", "pts": [list(Z0), list(Z1)], "speed": 9.0, "mode": "once", "trigger": "grab", "reset": 6.0, "accel": 30.0},
        model="zip_trolley")
A.ledge(-196.0, -190.0, 720.0, "plank", t=0.4)  # the maintenance deck: 6 m
A.box(-190.25, 720.06, 0.5, 0.12, "grease")  # the unease: its landing lip is greased
A.challenge("8.7", "Tirolesa", (-165.3, 725.4), 4, "X",
            moves=[["reach", [-166.2, 725.4], [-166.2, 727.2]],
                   ["fling", [-186.0, 724.2], [-193.4, 720.0], "F4"]])

# ---------------------------------------------------------------- 8.8 Contrapesos
# Four blocks (1.6 x 1.2) on two cables 3.2 m apart, west of the deck: a 1.6 m gap between
# the columns. Each rides 7 m at 1.75 m/s (4 s) and waits 1 s at each end; 10 s a round.
# The columns run against each other, and each block's top meets the next one's bottom:
#   A1 720.5 .. 727.5   B1 727.5 .. 734.5   A2 734.5 .. 741.5   B2 741.5 .. 748.5
# so twice a round two tops stand level for 1 s, 1.6 m apart. Step across then.
# A1 at its foot is 0.3 m off the deck and 0.5 m over it. B2 at its top is 0.4 m off pylon 3's head.
XA, XB = -197.1, -200.3
BLOCK = [(box_pts(0.0, -0.6, 1.6, 1.2), "paint"), (box_pts(0.0, 0.25, 0.1, 0.5), "iron")]
for mid, x, ya, yb in (("cw_a1", XA, 720.5, 727.5), ("cw_b1", XB, 734.5, 727.5), ("cw_a2", XA, 734.5, 741.5), ("cw_b2", XB, 748.5, 741.5)):
    A.mover(mid, (x, ya), BLOCK, {"type": "path", "pts": [[x, ya], [x, yb]], "speed": 1.75, "mode": "pingpong", "wait": 1.0, "trigger": "none"},
            model="counterweight_hung")
A.challenge("8.8", "Contrapesos", (-193.0, 720.0), 3, "X",
            moves=[["reach", [-196.0, 720.0], [-196.3, 720.5]],
                   ["reach", [XA - 0.8, 727.5], [XB + 0.8, 727.5]],
                   ["reach", [XB + 0.8, 734.5], [XA - 0.8, 734.5]],
                   ["reach", [XA - 0.8, 741.5], [XB + 0.8, 741.5]],
                   ["reach", [XB - 0.8, 748.5], [-201.5, 749.0]]])

# ---------------------------------------------------------------- pylon 3's head (a card tower; only the head is solid)
A.ledge(-205.6, -201.5, 749.0, "plank", t=0.4)  # 4.1 m: the rest before the dead gondola
A.box(-205.45, 749.6, 0.14, 1.2, "iron")  # the rail post you lean out from
A.box(-201.8, 749.06, 0.5, 0.12, "grease")  # the unease
A.beam((-202.0, 754.6), (-209.2, 754.6), 0.25, "iron")  # the crossarm the dead car hangs from (out of reach: 5.5 m up)
tower(-205.0, -202.4, 664.0, 754.6)

# ---------------------------------------------------------------- 8.9 La Gondola Rota
# A real body, 120 kg, on a hinge at its ONE hanger, which holds the roof's east corner: so it
# hangs crooked (about 30 degrees, west end low) and swings when you move on it. The shapes
# below are written at rest (centre of mass under the hinge) so it doesn't lurch at load.
# In by the east window (1 m high, facing the head), out by the roof hatch (0.9 m), down to
# the boom on its low west end, pump the car, and go: 4 m west and 0.6 m down to the boom of
# express line 1's car, which waits 1.5 s at its east end every 20 s. A grate hangs under
# that car's west rail for anyone who'd rather land on something still (9 m: F3).
HINGE = (-208.6, 754.2)
_dead = [
    (box_pts(0.0, -0.75, 0.12, 1.5), "iron"),  # the hanger, to the roof's east corner
    (box_pts(-0.4, -1.5, 0.8, 0.14), "paint"),  # roof, east piece
    (box_pts(-2.15, -1.5, 0.9, 0.14), "paint"),  # roof, west piece (the hatch is between)
    (box_pts(-1.3, -3.7, 2.6, 0.16), "paint"),  # floor
    (box_pts(-0.07, -3.15, 0.14, 1.1), "paint"),  # east end wall (the window is above it)
    (box_pts(-2.53, -3.15, 0.14, 1.1), "paint"),  # west end wall
    (box_pts(-3.4, -3.7, 1.6, 0.1), "iron"),  # the boom on the west end
]


def _centroid(shapes):
    sa = sx = sy = 0.0
    for pts, _ in shapes:
        a = abs(sum(pts[i][0] * pts[(i + 1) % 4][1] - pts[(i + 1) % 4][0] * pts[i][1] for i in range(4))) / 2
        sa += a
        sx += a * sum(p[0] for p in pts) / 4
        sy += a * sum(p[1] for p in pts) / 4
    return sx / sa, sy / sa


_cx, _cy = _centroid(_dead)
DEAD_TILT = math.degrees(math.atan2(_cx, _cy)) - 180.0 if _cy > 0 else math.degrees(math.atan(_cx / _cy))
A.body("dead_gondola", HINGE, [(rot_pts(p, DEAD_TILT), k) for p, k in _dead], mass=120.0, hinge=HINGE, limits=(-55.0, 55.0), damp=0.3,
       model="gondola_dead")


def dead_pt(x, y):
    p = rot_pts([(x, y)], DEAD_TILT)[0]
    return [round(HINGE[0] + p[0], 2), round(HINGE[1] + p[1], 2)]


A.challenge("8.9", "La Góndola Rota", (-203.5, 749.0), 4, "X",
            moves=[["reach", [-205.45, 750.2], dead_pt(0.0, -3.7)],
                   ["fling", dead_pt(-4.2, -3.7), [-214.8, 748.4], "F2"]])

# ---------------------------------------------------------------- 8.10 Via Rapida: four express lines
# Four parallel lines, 5.1 m one over the next, each 47.5 across and 22.5 up (52.56 m), from
# x -218.5 to x -266. One car on each, 6 m/s (8.8 s a run), 1.5 s at each end: 20.5 s a round.
# Lines 1 and 3 start at their east ends, 2 and 4 at their west ends: so every 10.3 s each
# car passes the car of the line above it, mid-span, at 12 m/s between them.
# THE TRANSFER. The lines climb west, so an upper car's lowest point as it goes over a lower
# car is its short WEST rail (0.6 m): its tip clears the lower car's cable grip by 0.43 m.
# A climber standing on the lower roof beside the hanger has their head 0.13 m under that and
# their raised hand 0.2 m over it. Stand tall, hand up, and the rail takes you (or go up the
# hanger and take the floor behind it, 0.25 m higher). Three times: 1 to 2, 2 to 3, 3 to 4.
# After each you have 10 s to get from the rail to the roof. Then ride 4 to its west end.
EX_GAP = 5.1
EX_E, EX_W = (-218.5, 752.1), (-266.0, 774.6)  # line 1; line k is 5.1 (k - 1) higher
EX_SLOPE = (EX_W[1] - EX_E[1]) / (EX_E[0] - EX_W[0])
for k in range(4):
    e, w = (EX_E[0], EX_E[1] + EX_GAP * k), (EX_W[0], EX_W[1] + EX_GAP * k)
    gondola("ex%d" % (k + 1), [e, w] if k % 2 == 0 else [w, e], 6.0, "pingpong", wr=0.6, eb=2.4, wait=1.5)
A.ledge(-221.0, -219.4, 746.5, "iron", t=0.25)  # the grate under line 1's west rail at its east stop (the 8.10 warp)
_mid = ((EX_E[0] + EX_W[0]) / 2, (EX_E[1] + EX_W[1]) / 2)
A.challenge("8.10", "Vía Rápida", (-220.2, 746.5), 5, "X",
            moves=[["reach", [-220.2, 746.5], [-220.2, 748.35]]] +
                  [["reach", [_mid[0], _mid[1] + EX_GAP * k - 0.3], [_mid[0], _mid[1] + EX_GAP * k + 0.45]] for k in range(3)])

# ---------------------------------------------------------------- 8.11 La Estacion Alta: the first ice
# The deck: top 786, x -282 .. -268, against the face. ICE (it holds 2 s, then lets go, and
# takes you again 0.6 s later) with three dry patches. Line 4's car stops for 1.5 s with its
# west rail tip (-267.9, 786.2) on the deck's east edge and 0.15 m above it.
for x0, x1, kind in ((-271.0, -268.0, "ice"), (-272.6, -271.0, "plank"), (-276.4, -272.6, "ice"), (-277.6, -276.4, "rock"),
                     (-280.6, -277.6, "ice"), (-282.0, -280.6, "rock")):
    A.ledge(x0, x1, 786.0, kind, t=0.6)
# Black ice under its east end: the deck can only be taken from above, off line 4.
# The face behind the deck's west end, where our wall's top meets a9's first slab: one plug of
# scree on the face's own line, so no crack is left under the boards.
A.solid([(-289.0, 782.0), (-280.4, 782.0), (-281.0, 784.0), (-281.4, 785.4), (-289.0, 785.4)], "scree")
A.solid([(-268.0, 785.42), (-268.0, 782.9), (-269.9, 785.42)], "blackice")
A.box(-267.93, 784.44, 0.14, 3.08, "blackice")  # and up its east edge, to 2 cm under the top
wire((-270.4, 785.3), (-279.4, 777.8), z=-0.7, t=0.3, tone=STEEL)  # its strut to the face: a card (a solid one would make a slick pocket against the face)
A.challenge("8.11", "La Estación Alta", (-268.8, 786.0), 3, "X",
            moves=[["reach", [-267.9, 786.2], [-268.3, 786.0]],
                   ["reach", [-269.4, 786.0], [-271.0, 786.0]]])

# ---------------------------------------------------------------- the picture (all scenery: cards and props)
# Late afternoon: far ranges going gold to violet, the valley and the tiny town under the void.
A.card([(-140, 676), (-140, 722), (-152, 731), (-166, 717), (-184, 738), (-204, 724), (-226, 744), (-246, 728), (-262, 742), (-290, 760), (-290, 676)],
       z=-30.0, tone="#C98F6A")
A.card([(-140, 676), (-140, 704), (-158, 712), (-176, 700), (-198, 716), (-222, 702), (-244, 712), (-290, 730), (-290, 676)], z=-22.0, tone="#A9785E")
A.card([(-140, 676), (-140, 690), (-170, 695), (-200, 688), (-232, 696), (-290, 700), (-290, 676)], z=-14.0, tone="#7E5E58")
A.deco("town_tiny", -196.0, 689.0, z=-13.5, size=(9.0, 2.2, 0.1), tone="rock")  # the town, the ring a dot
A.deco("sun_low", -150.0, 742.0, z=-34.0, size=(9.0, 9.0, 0.1), tone="gold")
A.effect("clouds", (-285, 676, -140, 700), density=0.5, tone="#F6D9B0")  # the void's floor is cloud
A.effect("dust", (-240, 690, -160, 730), density=0.2, tone="gold")  # gold motes in the low sun
A.effect("snow", (-285, 770, -262, 792), density=0.3)  # the first flakes at the high station

# The other towers.
tower(-217.9, -214.9, 664.0, 708.0)  # line 2's west tower
tower(-211.9, -208.9, 664.0, 708.0)  # line 2's east tower (the broken cable hangs off it)
tower(-245.5, -242.5, 688.0, 795.0, z=-1.6)  # the express lines' mid tower: it stands on the low station
tower(-198.6, -195.6, 719.4, 756.0, z=-1.4, tone="#7A3420")  # the counterweight frame over the roof

# Scenery cables: the lines the cars ride, the dead spans, the zipline.
for a, b in ((D_LO, E_LO), (D_HI, E_HI), (W_LO, E2_LO), (W_HI, E2_HI), (Z0, Z1), ((-164.25, 728.1), Z0)):
    wire(a, b)
for k in range(4):
    wire((EX_E[0] + 4.0, EX_E[1] + EX_GAP * k - 4.0 * EX_SLOPE), (EX_W[0] - 13.0, EX_W[1] + EX_GAP * k + 13.0 * EX_SLOPE))
wire(Z1, (-189.5, 722.6), t=0.07)  # the zipline's broken end, hanging
wire((-189.5, 722.6), (-190.2, 720.9), t=0.07)
wire((-188.5, 716.6), (-175.2, 707.7))  # the chairlift's cable, roof eave to the fang
for x in (XA, XB):
    wire((x, 721.0), (x, 755.8), z=-0.4, t=0.07)  # the counterweights' cables
wire((-196.0, 755.9), (-205.0, 755.9), t=0.2, tone=STEEL)  # the frame's top beam
wire(E2_HI, C0)  # line 2's old cable, running on as the bare one
wire(HINGE, (-209.0, 754.6), t=0.12, tone=STEEL)

# The stations.
A.card([(-252, 696.5), (-243, 701.0), (-233.5, 696.0), (-233.5, 695.4), (-243, 700.2), (-252, 695.9)], z=-1.0, tone="accent")  # the low station's roof
A.deco("bull_wheel", -237.2, 697.0, z=-1.1, size=(4.4, 4.4, 0.3), tone="iron")
A.deco("bull_wheel", -228.4, 698.9, z=-1.1, size=(4.4, 4.4, 0.3), tone="iron")
A.deco("bull_wheel", -216.4, 698.9, z=-1.1, size=(4.4, 4.4, 0.3), tone="iron")
A.deco("bull_wheel", -210.4, 701.4, z=-1.1, size=(4.4, 4.4, 0.3), tone="iron")
A.card([(-284, 793.5), (-275, 797.5), (-265, 792.5), (-265, 791.9), (-275, 796.7), (-284, 792.9)], z=-1.0, tone="accent")  # the high station's roof
A.deco("station_sign_pug", -246.0, 692.4, z=-1.0, size=(2.4, 1.4, 0.1), tone="accent")
A.deco("station_sign_pug", -277.0, 790.2, z=-1.0, size=(2.4, 1.4, 0.1), tone="accent")
A.deco("icicle_row", -275.0, 791.8, z=-0.9, size=(12.0, 1.2, 0.2), tone="ice")
A.deco("pug_crest_peeling", -193.0, 717.4, z=-0.9, size=(1.6, 1.6, 0.05), tone="accent")  # on the roof's gable
A.deco("pug_crest_peeling", -203.5, 752.0, z=-1.0, size=(1.4, 1.4, 0.05), tone="accent")
A.deco("toolbox_open", -191.0, 720.0, z=-0.7, size=(0.8, 0.4, 0.4), tone="accent")  # somebody was mending it
A.deco("oil_can", -191.6, 703.0, z=-0.7, size=(0.3, 0.4, 0.3), tone="iron")
A.deco("ticket_booth", -247.5, 688.0, z=-1.4, size=(2.2, 3.0, 1.2), tone="wood")
A.deco("glove_frozen", -279.0, 786.0, z=-0.6, size=(0.3, 0.2, 0.2), tone="accent")
# Pennants: the town's papel picado, come up the mountain on the cables.
for x, y, w, r in ((-231.4, 697.6, 6.0, 22.6), (-213.4, 703.2, 6.0, 22.6), (-200.0, 703.9, 10.0, 15.4), (-182.0, 713.0, 12.0, -33.7),
                   (-176.0, 727.0, 16.0, 8.6), (-241.75, 770.0, 40.0, -25.8), (-241.75, 783.2, 40.0, -25.8)):
    A.deco("pennant_line", x, y, z=-0.6, rot=r, size=(w, 0.7, 0.05), tone="accent")
for x, y in ((-246.5, 691.6), (-192.8, 717.6), (-193.0, 722.6), (-203.5, 752.4), (-275.0, 789.6)):
    A.deco("lantern_station", x, y, z=-0.8, size=(0.35, 0.55, 0.35), tone="gold")
    A.light(x, y, color="#FFC46A", rng=9.0, energy=1.2, flicker=True)
A.light(-165.3, 727.6, color="#FFD890", rng=10.0, energy=1.0)  # the fang's top catches the last sun

# ---------------------------------------------------------------- the camera: show the drop
A.cam((-262, 684, -236, 702), half_h=6.5, bias=(3.0, 0.0))  # the dock
A.cam((-236, 684, -206.5, 712), half_h=11.0, bias=(2.0, -3.5))  # lines 1 and 2: both cars and the void
A.cam((-206.5, 690, -190.4, 719), half_h=9.0, bias=(2.0, -3.0))  # the cable and pylon 2
A.cam((-190.4, 696, -177.0, 719), half_h=10.0, bias=(2.0, -3.5))  # the chairs
A.cam((-177.0, 696, -158.0, 722), half_h=8.0, bias=(-2.0, -2.0))  # the fang
A.cam((-190.0, 722, -158.0, 736), half_h=13.0, bias=(-10.0, -3.0))  # the top and the zipline: the deck is in frame
A.cam((-207.0, 719, -190.0, 746.0), half_h=9.0, bias=(-2.0, -2.0))  # the deck and the counterweights
A.cam((-216.0, 746.0, -200.0, 762), half_h=9.0, bias=(-5.0, -2.0))  # pylon 3 and the dead gondola
A.cam((-268.0, 742, -216.0, 796), half_h=14.0, bias=(0.0, -3.0))  # the express lines
A.cam((-285.0, 782, -268.0, 796), half_h=7.0, bias=(-2.0, 1.0))  # the high station

if __name__ == "__main__":
    print("dead gondola hangs at %.1f deg; 8.9 fling needs %.2f m/s" % (
        DEAD_TILT, fling_speed(abs(-214.8 - dead_pt(-4.2, -3.7)[0]), 748.4 - dead_pt(-4.2, -3.7)[1])))
    A.save()
