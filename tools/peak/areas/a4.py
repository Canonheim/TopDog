"""
A4 EL JARDIN DE HONGOS: the mushroom garden. Bounce and breath.
  python tools/peak/areas/a4.py

The room in one look (x negative = west, the well is at the far left):

  y 378  roof .. [4.10 great cap at the west door] <- 4.9 dark ceiling <- 4.8 bridge <- 4.7 cap shaft
  y 334  THE TERRACE (top of the slime island): 4.6 the giant mushroom stands on it
  y 311  L4 and the snail wall (4.5) up the island's east face        EAST GARDEN (y 318): the catch
  y 295  L3 -> 4.4 cap, vine, wall cap          (all of 4.2-4.4 hangs over ONE slime ramp
  y 277  L1 -> 4.2 vines -> L2 -> 4.3 updraft    that pours west onto the floor of 4.1)
  y 264  entry door, 4.1's floor and caps (the foot of the west hall, 100 m tall)

Stalks are painted cards behind the climb: caps and shelves float in the physics plane, so the
ground under them stays open for fallers to slide and walk.
"""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from peaklib import Area, box_pts, ngon, G

A = Area("a4", "fungus")


# ---------------------------------------------------------------- helpers
# HOW A CAP THROWS (stages/peak/peak_zones.gd, _tick_bounce): the body's speed ALONG the cap's
# face is kept; its speed INTO the face is replaced by `power` out along the normal. So a cap
# does not throw "along its normal": a body that arrives moving sideways keeps moving sideways.
# Every arc below is worked from the speed the body arrives with.
def throw(v_in, dx, dy, T):
    """The cap that turns an arrival at v_in into a flight of dx across and dy up lasting T
    seconds. Returns (lean, power, v_land): lean in degrees off straight up (+ east, - west)."""
    w = (dx / T, dy / T + 0.5 * G * T)  # the leaving velocity that flight needs
    nx, ny = w[0] - v_in[0], w[1] - v_in[1]  # the cap can only add speed along its normal
    L = math.hypot(nx, ny)
    nx, ny = nx / L, ny / L
    return math.degrees(math.atan2(nx, ny)), w[0] * nx + w[1] * ny, (w[0], w[1] - G * T)


def leave(v_in, lean, power):
    """The velocity a body leaves a cap with (the engine's rule)."""
    th = math.radians(lean)
    n = (math.sin(th), math.cos(th))
    d = (math.cos(th), -math.sin(th))
    along = v_in[0] * d[0] + v_in[1] * d[1]
    return (n[0] * power + d[0] * along, n[1] * power + d[1] * along)


ARCS = []  # (name, lean, power, rise, v_land) for the table printed at the bottom


def cap(cx, cy, w, lean, power, thick=0.7, min_in=0.6, kind="cap", name=None, v_in=None):
    """A springy cap whose TOP face is centred on (cx, cy), w wide. lean > 0 tips it east,
    lean < 0 west (degrees off straight up). The bounce line lies on the top face, west end
    first, so its normal is the push."""
    th = math.radians(lean)
    n = (math.sin(th), math.cos(th))
    d = (math.cos(th), -math.sin(th))  # along the face, west to east
    A.box(cx - n[0] * thick / 2, cy - n[1] * thick / 2, w, thick, kind, rot=-lean)
    A.bounce((cx - d[0] * w / 2, cy - d[1] * w / 2), (cx + d[0] * w / 2, cy + d[1] * w / 2), power, min_in=min_in)
    if name and v_in:
        out = leave(v_in, lean, power)
        ARCS.append((name, lean, power, out))


# ---------------------------------------------------------------- the shell: the AIR's outline
# Counter-clockwise from the entry sill. Each row: (point, kind of the edge that STARTS there).
SLOPE_FOOT = (-255.1, 264.0)  # the slime ramp: 35.0 degrees (rise 0.70 per metre), foot on 4.1's grip floor
SLOPE_HEAD = (-215.2, 291.93)
SHELL = [
    ((-291.0, 264.0), "rock"),   # 4.1's floor: moss, grip. A fall from anywhere in the west hall ends here
    (SLOPE_FOOT, "slime"),       # the ramp under 4.2, 4.3 and 4.4: one slick slope, 48.7 m long
    (SLOPE_HEAD, "wet"),         # 4.4's far wall (the wall cap grows out of it)
    ((-215.2, 318.0), "rock"),   # the east garden's floor: the catch under 4.6
    ((-190.0, 318.0), "wet"),    # the east wall
    ((-190.0, 346.0), "wet"),    # the roof, climbing west
    ((-205.0, 358.0), "wet"),
    ((-228.0, 370.0), "wet"),
    ((-262.0, 370.0), "wet"),    # steps down: the low dark ceiling of 4.9
    ((-262.0, 365.0), "wet"),
    ((-268.9, 365.0), "wet"),    # the first dome (puff A throws you up into it)
    ((-268.9, 372.0), "wet"),
    ((-275.0, 372.0), "wet"),
    ((-275.0, 365.0), "wet"),
    ((-279.9, 365.0), "wet"),    # the high roof over the west rim and the great cap
    ((-279.9, 378.0), "wet"),
    ((-291.0, 378.0), None),     # EXIT DOOR: y 364 .. 378 in my slab (the well's own gap is 364 .. 380)
    ((-291.0, 364.0), "wet"),    # the west wall, 84 m of wet rock beside the well
    ((-291.0, 280.0), None),     # ENTRY DOOR: y 264 .. 280
]
A.cave([p for p, _ in SHELL], {i: k for i, (_, k) in enumerate(SHELL)}, default="wet", thick=3.0)
A.opening(-295, 262, -291, 280)  # the entry, onto El Pozo
A.opening(-295, 364, -291, 380)  # the exit, onto El Pozo

# ---------------------------------------------------------------- the entry: what a3's fling catches
# a3's horn tip is at about (-304.6, 271.5), 9 m across the well. Three root ropes hang in the
# well's east side from a root beam; the sill below them is grip.
A.beam((-291.4, 279.0), (-296.5, 279.0), t=0.45, kind="root")  # the root beam, out into the well
for i, x in enumerate((-296.0, -295.2, -294.4)):
    A.rope("root_in%d" % i, (x, 279.0), 12.0, kind="vine")  # y 267 .. 279
A.ledge(-295.0, -288.0, 264.0, "root", t=2.0)  # the sill: fills the wall's foot from y 262, 1 m into the well
A.cam((-300, 258, -287, 284), half_h=8.0, bias=(2.0, 0.0))

# ---------------------------------------------------------------- 4.1 Sombreros (D2, miss S)
# A root stump to drop from, then three caps like stairs, each wider than the last.
# You step off the stump and fall 1.9 m: you arrive on cap A at about (0, -3.2) m/s.
#   A (-284.2, 265.3), leans 13.2 E, power 5.28 -> leaves at (1.92, 4.97): rises 4.43, 5.0 across and
#     3.5 up in 2.6 s, lands on B at (1.92, -2.28)
#   B (-279.2, 268.8), FLAT, power 4.97 -> keeps the 1.92 sideways, the same hop again, lands on C
#   C (-274.2, 272.3), FLAT, power 5.33 -> rises 5.10, 5.6 across and 3.7 up in 2.92 s, onto L1
# Step off the stump with 0.5 m/s of sideways speed and every hop is 1.2 m longer: that is why the
# caps grow (3.2, 4.0, 4.4 m) and L1 is 6 m. (C stops at 4.4: wider, and the hop from B clips its west end.)
A.ledge(-289.6, -287.8, 265.3, "root", t=1.3)  # a root knee: the step up
A.box(-286.6, 265.6, 2.4, 3.2, "root")  # the stump, top y 267.2
V_DROP = (0.0, -3.2)
la, pa, v1 = throw(V_DROP, 5.0, 3.5, 2.6)
cap(-284.2, 265.3, 3.2, la, pa, name="4.1 A", v_in=V_DROP)
lb, pb, v2 = throw(v1, 5.0, 3.5, 2.6)
cap(-279.2, 268.8, 4.0, lb, pb, name="4.1 B", v_in=v1)
lc, pc, v3 = throw(v2, 5.6, 3.7, 5.6 / v2[0])
cap(-274.2, 272.3, 4.4, lc, pc, name="4.1 C", v_in=v2)
A.ledge(-270.5, -264.5, 276.0, "gill", t=0.6)  # L1: a flat shelf cap, the rest before the vines
A.patch((-270.5, 276.0), (-270.0, 276.0), "slime", t=0.16)  # its west lip drips
# The one who never stopped bouncing: a big old cap gone soft (no spring left), and him on it.
A.box(-278.6, 264.7, 3.6, 1.4, "cap")
A.statue(-278.6, 265.75, "star", rot=90.0)
A.challenge("4.1", "Sombreros", (-289.0, 264.0), 2, "S")
A.cam((-291, 262, -264, 284), half_h=8.0, bias=(0.0, 3.0))

# ---------------------------------------------------------------- the slime island
# One great slick mass in the middle of the room. Its underside is the ceiling of 4.2 and 4.3,
# its east face is 4.5's snail wall (leaning out 12 degrees), its top is the terrace of 4.6.
WALL_FOOT = (-229.5, 311.6)
WALL_TOP = (-225.0, 333.0)
A.solid([(-266.0, 288.0), (-246.0, 288.0), (-246.0, 301.5), (-229.5, 301.5), WALL_FOOT, WALL_TOP,
         (-266.0, 333.0)], "slime")
A.ledge(-266.0, -225.0, 333.6, "rock", t=0.6)  # THE TERRACE: moss, 41 m of it. The catch under 4.7 and 4.8

# ---------------------------------------------------------------- 4.2 Lianas (D3, miss S)
# Four vines 5 m apart under the island, over the foot of the ramp. A fall lands on 4.1's floor
# (vines 1 and 2) or slides down the ramp to it (3 and 4). L2 is a bracket shelf: the ramp runs on
# under it with 2.7 m to spare at its east end.
for i, x in enumerate((-263.3, -258.3, -253.3, -248.3)):
    A.rope("liana%d" % i, (x, 288.0), 9.5, kind="vine")  # y 278.5 .. 288
A.ledge(-244.5, -240.5, 277.5, "gill", t=0.6)  # L2
A.patch((-244.5, 277.5), (-244.0, 277.5), "slime", t=0.16)
A.challenge("4.2", "Lianas", (-266.5, 276.0), 3, "S",
            moves=[["reach", [-264.5, 277.6], [-263.3, 278.6]],
                   ["fling", [-248.3, 279.5], [-243.5, 277.5], "F2"]])
A.cam((-268, 262, -240, 290), half_h=9.0, bias=(0.0, -2.0))

# ---------------------------------------------------------------- 4.3 El Ascensor de Esporas (D2, miss B)
# Step off L2's east edge into the spores. Two wind boxes make a float, not a rocket:
#   y 277.3 .. 285.0: 3.70 up (0.91 more than gravity)
#   y 285.0 .. 292.5: 2.00 up (0.79 less than gravity)
# The engine tests your middle against each box grown by 0.4 m, so the two overlap for 0.8 m and add
# there. Worked with that: your middle starts at y 278.4 (standing on L2), passes y 285.4 at 4.0 m/s,
# leaves the top box (y 292.9) at 2.0 m/s and tops out at y 293.6: 15 m of float. Then it sinks and
# bobs about y 285. The three vines' ends are at y 291.5; L3's lip (y 295) is just out of reach
# without them. Drift out of the column and it's the ramp, all the way to 4.1.
A.wind((-240.3, 277.3, -235.7, 285.0), (0.0, 3.70), look="spores")
A.wind((-240.3, 285.0, -235.7, 292.5), (0.0, 2.00), look="spores")
for i, x in enumerate((-239.4, -237.9, -236.4)):
    A.rope("lift%d" % i, (x, 301.5), 10.0, kind="vine")  # y 291.5 .. 301.5
A.ledge(-235.5, -230.5, 295.0, "gill", t=0.6)  # L3
A.patch((-231.0, 295.0), (-230.5, 295.0), "slime", t=0.16)
A.challenge("4.3", "El Ascensor de Esporas", (-241.5, 277.5), 2, "B",
            moves=[["reach", [-236.4, 294.6], [-235.5, 295.0]]])
A.cam((-246, 270, -228, 304), half_h=11.0, bias=(0.0, 4.0))

# ---------------------------------------------------------------- 4.4 Rebote Doble (D4, miss B)
# Cap, vine, wall cap, ledge. Step off L3's east edge: you fall 2.7 m onto cap 1 (arriving at about
# (0, -3.7)). It throws you at a vine hung in mid-air; your own speed swings the vine east; let go at
# the end of that swing and you drop onto the cap that grows out of the far wall, which throws you
# back OVER the vine's root to L4.
#   cap 1 (-229.0, 292.3), leans 15.4 E, power 7.56 -> leaves at (2.96, 7.03): rises 8.85. It meets the
#     vine (x -221, 8 m on) after 2.7 s, 8.8 m up, just past the top of its arc, moving at (2.96, -0.5)
#   on the vine (hands about 6 m under its root) 2.96 m/s swings you out about 40 degrees: 3.8 m east
#   wall cap (-216.6, 299.2), leans 10.3 W, power 9.51 -> a body dropped on it at (0, -3.5) leaves at
#     (-2.33, 9.24): rises 15.3, clears the vine's root (y 308) by 4 m, and comes down on L4 (11.4
#     across, 11.8 up) after 4.9 s at (-2.33, -4.4)
# The D4: the wall cap keeps your sideways speed. Let go of the vine while it still swings east at
# 1 m/s and you leave at (-1.4, 9.1): 4.6 m short, into the ramp. Let go on the way back and you go long
# into the snail wall, which drops you on L4. And the wall cap is 2.6 m: its edges miss L4 (2.6 m).
# (The wall cap's face is tipped 10 degrees, not upright: an upright face would throw you flat,
# straight back into the vine you just left.)
V44 = (0.0, -3.7)
l1, p1, _v = throw(V44, 8.0, 8.8, 2.7)
cap(-229.0, 292.3, 3.0, l1, p1, name="4.4 cap", v_in=V44)
A.beam((-221.5, 308.2), (-220.7, 308.2), t=0.3, kind="root")  # the vine's root: a knot of wood in the air
A.rope("rebote", (-221.0, 308.05), 10.0, kind="vine")  # y 298 .. 308
VW = (0.0, -3.5)
lw, pw, _v = throw(VW, -11.4, 11.8, 4.9)
cap(-216.6, 299.2, 2.6, lw, pw, name="4.4 wall", v_in=VW)
A.solid([(-215.2, 297.0), (-215.2, 300.2), (-216.2, 298.6)], "wet")  # the bracket it grows on
A.ledge(-229.5, -226.7, 311.0, "gill", t=0.6)  # L4: 2.6 m, the snail wall at its back
A.challenge("4.4", "Rebote Doble", (-233.0, 295.0), 4, "B")
A.cam((-237, 282, -212, 320), half_h=14.0, bias=(2.0, 2.0))

# ---------------------------------------------------------------- 4.5 La Baba (D3, miss B)
# The island's east face: 21.9 m of slime leaning out 12 degrees over 4.4. Five snails crawl it, each
# 2.2 m up and 2.2 m down, resting 1.6 s at each end (13 s for the round). Odd and even snails are half
# a round apart, so when one rests at its top the next rests at its bottom, shell centres 2.3 m apart
# (a 1.3 m reach, shell to shell). The shell is the only grip. Fall from the first two and L4 is under
# you; fall from higher and the lean puts you past L4's edge: the ramp, and 4.1.
_u = ((WALL_TOP[0] - WALL_FOOT[0]) / 21.868, (WALL_TOP[1] - WALL_FOOT[1]) / 21.868)  # up the wall
_n = (_u[1], -_u[0])  # out of the wall
_tilt = math.degrees(math.atan2(_u[1], _u[0]))
SNAIL_ROUND = 2.0 * (2.2 / 0.45 + 1.6)
for i in range(5):
    s0 = 1.2 + 4.5 * i
    lo = (WALL_FOOT[0] + _u[0] * s0, WALL_FOOT[1] + _u[1] * s0)
    hi = (lo[0] + _u[0] * 2.2, lo[1] + _u[1] * 2.2)
    A.mover("snail%d" % (i + 1), lo, [
        (ngon(_n[0] * 0.7, _n[1] * 0.7, 0.5, 10), "shell"),  # the shell: the hold
        (box_pts(_n[0] * 0.17, _n[1] * 0.17, 1.9, 0.34, _tilt), "slime"),  # the foot, on the wall
        (ngon(_u[0] * 1.0 + _n[0] * 0.38, _u[1] * 1.0 + _n[1] * 0.38, 0.24, 6), "slime"),  # the head
    ], {"type": "path", "pts": [list(lo), list(hi)], "speed": 0.45, "mode": "pingpong", "wait": 1.6,
        "phase": (SNAIL_ROUND / 2.0) * (i % 2)}, model="snail_wall")
_s1 = (WALL_FOOT[0] + _u[0] * 3.4 + _n[0] * 0.7, WALL_FOOT[1] + _u[1] * 3.4 + _n[1] * 0.7)  # snail 1's shell, at its top
_s2 = (WALL_FOOT[0] + _u[0] * 5.7 + _n[0] * 0.7, WALL_FOOT[1] + _u[1] * 5.7 + _n[1] * 0.7)  # snail 2's, at its bottom
A.challenge("4.5", "La Baba", (-228.0, 311.0), 3, "B",
            moves=[["reach", [-228.4, 312.3], [-228.57, 313.1]],
                   ["reach", [_s1[0] + _u[0] * 0.5, _s1[1] + _u[1] * 0.5], [_s2[0] - _u[0] * 0.5, _s2[1] - _u[1] * 0.5]],
                   ["reach", [-224.3, 332.9], [-225.0, 333.6]]])
A.cam((-233, 308, -219, 337), half_h=8.0, bias=(1.0, 2.0))

# The east garden (y 318): where a fling off the giant mushroom's rim comes down if it goes wide.
# The way back is a root arm over its west lip: hang from its end and drop-fling to L4 (9.4 m across,
# 10.5 m down: 3.2 m/s).
A.ledge(-215.2, -212.0, 318.08, "rock", t=0.3)  # (the far wall's slab ends a hair above the floor: cover its top with moss)
A.box(-214.4, 319.9, 0.5, 3.8, "root")
A.beam((-214.4, 321.5), (-218.6, 321.5), t=0.36, kind="root")

# ---------------------------------------------------------------- 4.6 El Hongo Gigante (D4, miss B)
# It stands on the terrace: a slick stalk (painted, behind you), a cap 19 m across. Only three things on it grip: the cream
# gills hanging under the east half, the pale brim of the east rim, and the warts up its shoulder.
# Hand over hand out along the gills (1.4 m apart), past the terrace's edge, to a knot on the end of
# a slime strand that droops 1 m outside the rim. Swing on the knot and let go on the way UP: out
# round the rim and back in onto the brim (1.6 m of grip). Then the warts, 1.5 m apart up a 46 degree
# slime shoulder, to the dry crown.
#   the fling: knot (-221.5, 336.6) to the brim (-223.4, 340.25): 1.9 across, 3.65 up: 4.65 m/s (F2).
#   Worked: let go 1.25 m east of the knot moving (-1.5, 5.0): the body passes the rim's tip at
#   y 341.3 and tops out at 341.5 over the brim.
# Let go late and you fly east: the east garden catches you (y 318), or nothing does.
A.solid([(-241.5, 339.2), (-233.0, 341.0), (-231.0, 341.0), (-222.5, 339.2), (-222.5, 340.0), (-224.1, 340.0),
         (-230.0, 346.2), (-234.0, 346.2), (-241.5, 340.0)], "slime")  # the cap: wet, but for what follows
# (Its stalk is a dark wet CARD behind the climb, not a solid: a solid stalk would wall the terrace
# in two and strand anyone the terrace catches west of it.)
A.ledge(-234.0, -230.0, 346.5, "cap", t=0.3)  # the crown: dry, orange, the rest after the fling
A.ledge(-224.1, -222.5, 340.25, "gill", t=0.25)  # the brim: the landing
GILLS = [(-230.2, 335.5), (-228.8, 335.9), (-227.4, 336.3), (-226.0, 336.6), (-224.6, 336.8), (-223.2, 336.9)]
for gx, gy in GILLS:
    top = 341.0 - (gx + 231.0) * (1.8 / 8.5)
    if gx > -224.0:  # the last gill grips only at its foot (1.1 m): from higher a hand could go round the rim
        A.box(gx, gy + 0.55, 0.2, 1.1, "gill")
        A.box(gx, (gy + 1.1 + top) / 2 + 0.05, 0.12, top - gy - 1.0, "slime")
        continue
    A.box(gx, (gy + top) / 2 + 0.1, 0.2, top - gy + 0.2, "gill")  # a gill: a hanging cream slat
A.beam((-222.5, 339.5), (-221.55, 336.9), t=0.14, kind="slime")  # the strand
A.hold(-221.5, 336.6, r=0.26, kind="gill")  # the knot: the launch
_sh = (-0.689, 0.724)  # up the east shoulder, from the brim to the crown (8.56 m)
WARTS = [(-224.1 + _sh[0] * s + 0.07, 340.0 + _sh[1] * s + 0.07) for s in (1.3, 2.8, 4.3, 5.8, 7.2)]
for wx, wy in WARTS:
    A.hold(wx, wy, r=0.27, kind="gill")
A.challenge("4.6", "El Hongo Gigante", (-229.0, 333.6), 4, "B",
            moves=[["reach", list(GILLS[0]), list(GILLS[1])], ["reach", list(GILLS[4]), list(GILLS[5])],
                   ["reach", list(GILLS[5]), [-221.5, 336.6]],
                   ["fling", [-221.5, 336.6], [-223.4, 340.25], "F2"],
                   ["reach", [-224.1, 340.25], list(WARTS[0])], ["reach", list(WARTS[0]), list(WARTS[1])],
                   ["reach", list(WARTS[3]), list(WARTS[4])], ["reach", list(WARTS[4]), [-230.0, 346.5]]])
A.cam((-236, 330, -212, 350), half_h=11.0, bias=(3.0, -3.0))

# ---------------------------------------------------------------- 4.7 Trampolin en Cadena (D4, miss B)
# A shaft between two hanging masses of slime, over the giant's west shoulder. Three roots hang under
# the east mass: go out along them from the crown and DROP from the last (2.2 m: you arrive on cap 1
# at about (0, -3.5)). Then five caps, wall to wall:
#   1 (-235.6, 345.3) leans 18.3 W, power 4.98 -> (-2.61, 4.38): rises 3.44, 6.0 across 2.7 up in 2.3 s
#   2 (-241.6, 348.0) leans 31.0 E, power 5.23 -> (+1.68, 5.09): rises 4.64, 4.2 across 4.0 up in 2.5 s
#   3 (-237.4, 352.0) leans 27.1 W, power 5.08 -> (-1.75, 4.81): rises 4.15, 4.2 across 3.5 up in 2.4 s
#   4 (-241.6, 355.5) leans 27.6 E, power 5.07 -> (+1.75, 4.81): the same, mirrored
#   5 (-237.4, 359.0) leans 35.8 W, power 5.62 -> (-3.03, 4.74): rises 4.03, 8.8 across 2.0 up in 2.9 s,
#     over the west mass's corner with 2.9 m to spare, onto L7
# Each cap keeps the sideways speed you bring and adds its own: land 0.5 m off the middle of one and
# you are 0.5 m off the next; slide onto cap 1 off the crown instead of dropping and you go 3 m long.
# A miss falls on the west shoulder (39.6 degrees of slime), off the rim and onto the terrace.
A.box(-233.0, 360.5, 6.0, 20.0, "slime")  # the east mass: x -236 .. -230, from y 350.5 into the roof
A.box(-245.9, 352.45, 6.2, 15.9, "slime")  # the west mass: x -249 .. -242.8, y 344.5 .. 360.4
A.ledge(-249.0, -242.8, 361.0, "rock", t=0.6)  # L7, on its top
A.patch((-243.3, 361.0), (-242.8, 361.0), "slime", t=0.16)
ROOTS47 = [(-232.6, 348.4), (-233.9, 348.9), (-235.2, 349.4)]  # the last is 2.2 m by hand from cap 3: out of reach
for rx, ry in ROOTS47:
    A.box(rx, (ry + 350.6) / 2, 0.2, 350.6 - ry, "root")
V47 = (0.0, -3.5)
lean, power, v = throw(V47, -6.0, 2.7, 2.3)
cap(-235.6, 345.3, 2.4, lean, power, name="4.7 c1", v_in=V47)
CHAIN = [((-241.6, 348.0), 4.2, 4.0, 2.5), ((-237.4, 352.0), -4.2, 3.5, 2.4), ((-241.6, 355.5), 4.2, 3.5, 2.4),
         ((-237.4, 359.0), -8.8, 2.0, 2.9)]
for i, (at, dx, dy, T) in enumerate(CHAIN):
    v_arrive = v
    lean, power, v = throw(v_arrive, dx, dy, T)
    cap(at[0], at[1], 2.4, lean, power, name="4.7 c%d" % (i + 2), v_in=v_arrive)
A.challenge("4.7", "Trampolín en Cadena", (-232.0, 346.5), 4, "B",
            moves=[["reach", list(ROOTS47[0]), list(ROOTS47[1])], ["reach", list(ROOTS47[1]), list(ROOTS47[2])]])
A.cam((-251, 336, -229, 368), half_h=14.0, bias=(-2.0, 2.0))

# ---------------------------------------------------------------- 4.8 Puente de Micelio (D3, miss B)
# 14 m of mycelium rope and boards from L7 to a root shelf (L8), hung 6% slack: it sags about 2 m.
# Two gust boxes, out of step: the east half shoves you back toward L7, the west half lifts you off
# the boards (3.4 up beats gravity by 0.6) and pushes on west. Hold on through each; move between.
# Under all of it is the terrace, 27 m down: the start of 4.6.
A.rope("puente", (-249.0, 361.0), 14.0, kind="rope", to=(-263.0, 361.0), planks=15, slack=1.06)
A.wind((-256.0, 356.5, -249.5, 366.0), (4.0, 0.8), gust={"on": 1.6, "off": 3.2, "phase": 0.0, "warn": 0.8}, look="spores")
A.wind((-262.5, 356.5, -256.0, 366.0), (-3.0, 3.4), gust={"on": 1.6, "off": 3.2, "phase": 2.4, "warn": 0.8}, look="spores")
A.ledge(-266.0, -263.0, 361.0, "root", t=0.6)  # L8
A.patch((-263.5, 361.0), (-263.0, 361.0), "slime", t=0.16)
A.challenge("4.8", "Puente de Micelio", (-246.0, 361.0), 3, "B")
A.cam((-267, 350, -244, 368), half_h=10.0, bias=(0.0, -4.0))

# ---------------------------------------------------------------- 4.9 Los Ojos (D4, miss A)
# The low dark ceiling over the west hall: 100 m of air under it, 4.1's floor at the bottom. Root knots
# on the ceiling, hanging roots, and seven puffballs that glow like eyes. A puff throws you straight
# away from its centre (peak_zones.gd: from the puff to your middle, every piece of you at `power`),
# so what it does depends on where you are when you touch it. Five are in the way. Two you need,
# because each hangs 4 m BELOW where you have to get to:
#   EYE A (-267.9, 359.5): slide down the root that hangs from the ceiling's edge (x -268.5, its end
#     at y 361.7). Your feet find the eye with your middle 0.6 m west and 1.3 m above its centre: thrown
#     25 degrees west of straight up at 7.2 -> (-2.9, 6.6): up 7.8 m into the dome, through the two
#     roots that hang there (x -273.4, -274.2, y 364.5 .. 372) at y 368, still rising.
#     Anything from 15 to 30 degrees crosses them (y 369.4 to 366.8). Flatter (35 and more) and your
#     feet meet the eye in the dome's mouth; straighter than 10 and it is the roof's edge.
#   EYE B (-278.8, 359.5): the same from the last root (x -279.4), at 7.0 -> (-2.9, 6.4): over the end
#     of the exit's sill (x -283.2, y 364) with 1.8 m to spare, topping out at y 368 under the diving
#     board, down onto the sill by the post. Two roots hang over the sill's end for a hand to find.
# Without the eyes: a fling from a dangling root's end, 5 m across and 3.5 m up (A) or 3.8 across and
# 4.3 up (B): 5 m/s off a rope, in the dark. The eyes are the way.
A.dark((-282.0, 355.0, -262.0, 373.0), level=0.85)
A.rope("ojo_v0", (-266.5, 365.0), 2.4, kind="vine")  # the way up off L8
KNOTS = [(-267.5, 364.85), (-275.7, 364.85), (-277.0, 364.85), (-278.3, 364.85)]
for kx, ky in KNOTS:
    A.hold(kx, ky, r=0.26, kind="root")
A.rope("ojo_ra", (-268.5, 365.0), 3.3, kind="vine")  # down to y 361.7: the root over eye A
A.rope("ojo_ca0", (-273.4, 372.0), 7.5, kind="vine")  # the catch in the dome, y 364.5 .. 372
A.rope("ojo_ca1", (-274.2, 372.0), 7.5, kind="vine")
A.rope("ojo_rb", (-279.4, 365.0), 3.3, kind="vine")  # down to y 361.7: the root over eye B
A.rope("ojo_cb0", (-283.8, 378.0), 11.5, kind="vine")  # over the sill's end, y 366.5 .. 378
A.rope("ojo_cb1", (-284.6, 378.0), 11.5, kind="vine")
EYES = [(-267.9, 359.5, 7.2), (-278.8, 359.5, 7.0),  # A and B: the two you need
        (-276.4, 361.5, 5.0),  # under the second run of knots: let your legs hang and it finds you
        (-270.8, 369.6, 5.0),  # in the dome's roof: a throw that goes too straight up meets it
        (-271.6, 363.2, 5.0),  # in the dome's mouth: a flat throw meets it
        (-281.6, 361.8, 5.0),  # past eye B: the same (a 45 degree throw; a 25 degree one clears it by 1.3 m)
        (-264.6, 364.3, 4.0)]  # over L8: it only watches
for ex, ey, ep in EYES:
    A.puff(ex, ey, 0.6, ep, respawn=4.0)
    A.light(ex, ey, color="#D8FF7A", rng=3.5, energy=0.9, z=0.9)
A.challenge("4.9", "Los Ojos", (-264.5, 361.0), 4, "A",
            moves=[["reach", [-266.5, 364.6], list(KNOTS[0])], ["reach", list(KNOTS[0]), [-268.5, 364.5]],
                   ["reach", [-274.2, 364.7], list(KNOTS[1])], ["reach", list(KNOTS[1]), list(KNOTS[2])],
                   ["reach", list(KNOTS[2]), list(KNOTS[3])], ["reach", list(KNOTS[3]), [-279.4, 364.5]]])
A.cam((-286, 350, -262, 376), half_h=13.0, bias=(-2.0, -4.0))

# ---------------------------------------------------------------- 4.10 El Salto del Pozo II (D5, miss P)
# The exit door's sill (y 364), a root post up to a diving board (L9, y 370.5), and under the board's
# lip the great cap, its west lip hanging in the well. a5 (areas/a5.py) hangs two banner chains at
# x -303.0 and -301.5, y 368 .. 380, from a beam at y 380; its sill is a stone block, top y 366, that
# reaches x -304.
#
# THE WORKING (gravity 2.79). The engine's cap keeps the speed you bring ALONG its face and replaces
# the speed INTO it with `power` out along its normal: so the arc is worked from how you arrive.
#   Hang from the board's lip (-292.0, 370.5) and swing west as you let go. Your feet fall 2.2 m to the
#   cap in 1.26 s; to come down on the MIDDLE (-293.3, 366.2), 1.3 m west of the lip, you bring 1.0 m/s
#   of sideways speed. You arrive at (-1.0, -3.6), your middle at (-293.3, 367.1).
#   Wanted: through (-302.3, 374.0), 9.0 across and 6.9 up, and coming DOWN steeply there, so that a
#   body that catches nothing does not sail on into the temple's door. Take 1.9 m/s across:
#     time to the chains   = 9.0 / 1.9 = 4.74 s
#     up speed at leaving  = (6.9 + 1.395 x 4.74^2) / 4.74 = 8.06 m/s      -> LEAVE at (-1.90, +8.06)
#     the top of the arc   = 8.06^2 / 5.58 = 11.6 m up (y 378.7), 2.89 s out, over x -298.8
#   The cap can only add speed along its normal, so the normal lies along (leave - arrive) =
#   (-0.90, 11.66): 4.4 degrees west of straight up. power = (leave) . (normal) = 8.18 m/s.
#   (Thrown from rest along the normal, 8.18 rises 8.18^2 / 5.58 = 12.0 m.)
#   Check: the body comes down through the near chain (x -301.5) at y 375.9 falling at 4.0 m/s and the
#   far one (x -303.0) at y 371.9 falling at 6.2 m/s, and through (-302.3, 374.0) between them. Catch neither and it comes
#   down on the outer 0.3 m of a5's sill, or past it.
#   WHY IT IS A D5:
#     - the sideways speed you bring is the throw's range. Arrive at -0.5 m/s instead of -1.0 and you
#       leave at -1.42 across: the near chain's END (y 368) is where you cross it. Slower is the well.
#       Faster is safe: at -2.0 you cross both chains at y 378 and go on into the door.
#     - the middle is 1.0 m of a dome. EAST FLANK (1.9 m, leans 12 E, power 5.0): a dead drop off the
#       lip lands here and leaves at (+1.77, +4.73), back under the board. Nothing lost but the try.
#       WEST FLANK (1.5 m, the lip in the well, leans 40 W, power 3.0): arrive at (-1.0, -3.6), leave at
#       (-4.29, +0.32): under the chains (y 363.3 at x -301.5) and into the well's wall at y 360.3, 1.7 m
#       under the foot of a5's sill. That is the long one, and it is the well.
A.ledge(-294.0, -283.2, 364.0, "root", t=0.8)  # the sill, and the floor the roots of eye B let you down to
A.box(-288.7, 367.0, 0.4, 6.0, "root")  # the post: climb it
A.ledge(-292.0, -287.5, 370.5, "root", t=0.5)  # L9, the diving board. Its lip is the launch
A.patch((-288.0, 370.5), (-287.5, 370.5), "slime", t=0.16)
V410 = (-1.0, -3.6)
lean_c, power_c, _v = throw(V410, -9.0, 6.9, 9.0 / 1.9)
_th = math.radians(lean_c)
_d = (math.cos(_th), -math.sin(_th))
C_MID = (-293.3, 366.2)
C_W = (C_MID[0] - _d[0] * 0.5, C_MID[1] - _d[1] * 0.5)
C_E = (C_MID[0] + _d[0] * 0.5, C_MID[1] + _d[1] * 0.5)
F_E = (C_E[0] + 1.9 * math.cos(math.radians(12.0)), C_E[1] - 1.9 * math.sin(math.radians(12.0)))
F_W = (C_W[0] - 1.5 * math.cos(math.radians(40.0)), C_W[1] - 1.5 * math.sin(math.radians(40.0)))
A.solid([F_W, (F_W[0] + 0.4, 364.3), (-294.0, 364.0), (F_E[0], 364.0), F_E, C_E, C_W], "cap", skin="shroom_great_cap")  # the great cap
A.deco("shroom_great_cap", C_MID[0], C_MID[1], z=0.0, skin=True)  # (the Building Maker's, made to these seven points about C_MID)
A.bounce(C_W, C_E, power_c)  # the middle: listed first, so a body over both it and a flank gets the true throw
A.bounce(C_E, F_E, 5.0)  # the east flank
A.bounce(F_W, C_W, 3.0)  # the west flank
ARCS.append(("4.10 mid", lean_c, power_c, leave(V410, lean_c, power_c)))
ARCS.append(("4.10 east", 12.0, 5.0, leave((0.0, -3.6), 12.0, 5.0)))
ARCS.append(("4.10 west", -40.0, 3.0, leave(V410, -40.0, 3.0)))
A.challenge("4.10", "El Salto del Pozo II", (-289.8, 370.5), 5, "P",
            moves=[["fling", [-292.0, 370.5], [-293.3, 366.2], "F1"]])
A.cam((-300, 358, -284, 380), half_h=14.0, bias=(-6.0, 3.0))

# ---------------------------------------------------------------- the picture
# A garden with no sun: mushrooms as trees, a soft green glow, orange caps, spores adrift.
# Cards behind the climb never use a pale tone: pale means grip here, and a card can't be held.
def floor_under(x):
    """Where a stalk under x would root: the terrace, the garden, the ramp or the floor."""
    if -266.0 <= x <= -225.0:
        return 333.6
    if x > -215.2:
        return 318.0
    if x > SLOPE_FOOT[0]:
        return 264.0 + (x - SLOPE_FOOT[0]) * 0.70
    return 264.0


def stalk(x, top, w=0.9, base=None, z=-2.4, tone="back"):
    """A mushroom's stalk as a card, from the ground up to the cap or shelf it carries."""
    y0 = floor_under(x) if base is None else base
    A.card([(x - w * 0.75, y0), (x + w * 0.75, y0), (x + w * 0.42, top), (x - w * 0.42, top)], z=z, tone=tone)


def tree(x, y0, h, capw, z=-10.0, tone="back3", lean=0.0):
    """A far mushroom, stalk and cap in one silhouette."""
    sw = capw * 0.11
    cx = x + lean
    A.card([(x - sw, y0), (x + sw, y0), (cx + sw * 0.7, y0 + h * 0.8), (cx + capw / 2, y0 + h * 0.8),
            (cx + capw * 0.36, y0 + h * 0.93), (cx, y0 + h), (cx - capw * 0.36, y0 + h * 0.93),
            (cx - capw / 2, y0 + h * 0.8), (cx - sw * 0.7, y0 + h * 0.8)], z=z, tone=tone)


A.card([p for p, _ in SHELL], z=-6.0, tone="back2")  # the room's back wall: no sky in here
A.card([(-294, 258), (-184, 258), (-184, 382), (-294, 382)], z=-14.0, tone="back3", edge=False)  # behind everything, my side of the well only
# far trees (z -10) and nearer ones (z -4): the west hall, the ramp room, the east garden, the top
for x, y0, h, capw, lean in ((-284.0, 264, 58, 17, 1.5), (-272.5, 264, 86, 21, -1.0), (-281.0, 264, 34, 12, 0.0),
                             (-205.0, 318, 30, 20, 1.0), (-195.0, 318, 21, 13, -0.8), (-219.0, 286, 40, 15, 0.5),
                             (-254.0, 333.6, 30, 18, -1.0), (-239.0, 264, 30, 16, 0.0)):
    tree(x, y0, h, capw, z=-10.0, tone="back3", lean=lean)
for x, y0, h, capw, lean in ((-288.5, 264, 22, 8, 0.6), (-262.0, 264, 9, 6, 0.0), (-200.0, 318, 14, 9, 0.5),
                             (-209.5, 318, 9, 6, -0.4), (-258.0, 333.6, 13, 8, 0.4), (-247.5, 333.6, 6, 4.5, 0.0)):
    tree(x, y0, h, capw, z=-4.0, tone="back", lean=lean)
# the stalks of everything that floats on the route
for x, top, w in ((-284.2, 264.7, 1.0), (-279.2, 268.1, 1.0), (-274.2, 271.6, 1.1), (-267.5, 275.4, 1.4),
                  (-242.5, 276.9, 1.0), (-233.0, 294.4, 1.1), (-229.0, 291.6, 0.9), (-221.1, 308.0, 0.7),
                  (-264.5, 360.4, 1.0)):
    stalk(x, top, w)
A.card([(-216.3, 298.4), (-215.2, 296.6), (-215.2, 299.8)], z=-1.6, tone="back")  # the wall cap's bracket
# the giant's stalk: dark and wet, so nobody reaches for it
A.card([(-234.2, 333.6), (-229.8, 333.6), (-230.6, 341.0), (-233.4, 341.0)], z=-1.5, tone="slick")
# a front layer, only where nobody climbs: the east garden's far corner and the hall's foot
tree(-192.5, 318, 16, 9, z=3.5, tone="back3", lean=-0.6)
A.card([(-291, 264), (-286, 264), (-287.2, 265.0), (-289.6, 265.3), (-291, 265.1)], z=3.0, tone="back3")

# props (docs/peak/PARTS.md: the living mountain). Scenery only: all of it stands behind the climb.
for name, x, y, z, size in (
        ("mushroom_giant", -202.0, 318.0, -5.0, (16, 22, 8)),
        ("mushroom_cap_l", -194.0, 318.0, -2.6, (7, 4, 5)),
        ("mushroom_cap_m", -209.0, 318.0, -2.2, (4, 2.5, 4)),
        ("mushroom_cap_s", -206.0, 318.0, -1.6, (2, 1.5, 2)),
        ("mushroom_cap_m", -289.0, 264.0, -2.2, (4, 2.5, 4)),
        ("mushroom_cap_s", -272.0, 264.0, -1.6, (2, 1.5, 2)),
        ("mushroom_cap_s", -260.5, 264.0, -1.8, (2, 1.5, 2)),
        ("mushroom_cap_l", -256.0, 333.6, -2.8, (7, 4, 5)),
        ("mushroom_cap_m", -247.0, 333.6, -2.0, (4, 2.5, 4)),
        ("mushroom_cap_s", -262.5, 333.6, -1.6, (2, 1.5, 2)),
        ("mushroom_cap_s", -237.5, 333.6, -1.8, (2, 1.5, 2)),
        ("giant_snail", -198.5, 318.0, -3.2, (2.4, 1.8, 1.2)),  # one more, far back, asleep
        ("glow_moss", -283.0, 264.0, -1.3, (3.0, 0.3, 1.0)), ("glow_moss", -268.0, 264.0, -1.3, (3.0, 0.3, 1.0)),
        ("glow_moss", -252.0, 333.6, -1.3, (3.0, 0.3, 1.0)), ("glow_moss", -241.0, 333.6, -1.3, (3.0, 0.3, 1.0)),
        ("glow_moss", -203.0, 318.0, -1.3, (3.0, 0.3, 1.0)), ("glow_moss", -287.0, 364.0, -1.3, (3.0, 0.3, 1.0)),
        ("spore_pod", -238.0, 276.0, -1.4, (0.8, 1.0, 0.8)), ("spore_pod", -237.2, 275.4, -1.8, (0.8, 1.0, 0.8)),
        ("spore_pod", -259.0, 357.5, -1.6, (0.8, 1.0, 0.8)), ("spore_pod", -252.5, 357.8, -1.6, (0.8, 1.0, 0.8)),
        ("vine_leaf", -263.3, 287.6, -0.9, (1.2, 0.8, 0.2)), ("vine_leaf", -253.3, 287.6, -0.9, (1.2, 0.8, 0.2)),
        ("vine_leaf", -237.9, 301.1, -0.9, (1.2, 0.8, 0.2)), ("vine_leaf", -295.2, 279.4, -0.9, (1.2, 0.8, 0.2)),
        ("stalactite_b", -250.0, 370.0, -1.8, (1.5, 6, 1.5)), ("stalactite_a", -256.5, 370.0, -1.5, (0.8, 3, 0.8)),
        ("stalactite_a", -212.0, 362.0, -1.8, (0.8, 3, 0.8)), ("stalactite_b", -198.0, 351.5, -2.2, (1.5, 6, 1.5)),
        ("stalactite_a", -284.0, 378.0, -1.6, (0.8, 3, 0.8)),
        # invented (listed in the report): a bracket fungus for the walls, a pod that carries a light
        ("shelf_fungus", -290.6, 300.0, -1.0, (3.0, 0.8, 2.0)), ("shelf_fungus", -290.6, 322.0, -1.0, (3.0, 0.8, 2.0)),
        ("shelf_fungus", -290.6, 344.0, -1.0, (3.0, 0.8, 2.0)), ("shelf_fungus", -190.4, 330.0, -1.0, (3.0, 0.8, 2.0)),
        ("shelf_fungus", -265.6, 310.0, -1.2, (3.0, 0.8, 2.0)),
        ("spore_lantern", -272.5, 277.6, -1.2, (0.6, 0.8, 0.6)), ("spore_lantern", -233.0, 298.6, -1.2, (0.6, 0.8, 0.6)),
        ("spore_lantern", -246.0, 364.2, -1.2, (0.6, 0.8, 0.6)), ("spore_lantern", -288.7, 373.2, -1.2, (0.6, 0.8, 0.6))):
    A.deco(name, x, y, z=z, size=size, tone="accent" if name.startswith(("mushroom", "shelf")) else None,
           flip=name == "shelf_fungus" and x > -200)

# light: green from the moss and the spores, orange where a cap matters. About one per 12 m of route.
GREEN, ORANGE = "#A6FF9A", "#FFB45E"
for x, y, col, rng, en in (
        (-293.0, 273.0, GREEN, 9, 1.4), (-283.0, 269.5, ORANGE, 9, 1.5), (-273.0, 276.5, ORANGE, 9, 1.4),
        (-266.5, 279.5, GREEN, 8, 1.3), (-255.5, 282.0, GREEN, 10, 1.2), (-245.5, 281.0, GREEN, 9, 1.3),
        (-238.0, 287.0, "#C8FFB0", 9, 1.5), (-233.0, 298.0, GREEN, 8, 1.4), (-228.5, 295.0, ORANGE, 8, 1.4),
        (-221.0, 303.5, GREEN, 9, 1.2), (-217.2, 302.0, ORANGE, 8, 1.5), (-227.8, 314.0, GREEN, 8, 1.4),
        (-224.5, 323.0, GREEN, 9, 1.2), (-228.0, 336.2, GREEN, 9, 1.3), (-221.5, 338.6, ORANGE, 8, 1.4),
        (-232.0, 349.0, ORANGE, 8, 1.4), (-239.5, 352.0, ORANGE, 10, 1.5), (-246.0, 364.0, GREEN, 8, 1.4),
        (-256.0, 364.5, GREEN, 9, 1.1), (-288.0, 366.5, GREEN, 8, 1.3), (-293.4, 369.0, ORANGE, 9, 1.7),
        (-250.0, 336.0, GREEN, 11, 1.1), (-262.0, 336.0, GREEN, 9, 1.0), (-205.0, 322.0, GREEN, 12, 1.2),
        (-194.0, 323.0, ORANGE, 10, 1.1), (-281.0, 300.0, GREEN, 12, 0.8), (-281.0, 332.0, GREEN, 12, 0.8),
        (-240.0, 270.0, GREEN, 10, 1.0), (-226.0, 284.0, GREEN, 10, 0.9)):
    A.light(x, y, color=col, rng=rng, energy=en)
# the well side of both doors is lit, so the drop is seen before the jump
A.light(-295.5, 268.0, color="#BFE8C0", rng=10.0, energy=1.2)
A.light(-296.5, 367.0, color="#BFE8C0", rng=12.0, energy=1.4)

A.effect("spores", (-291, 264, -266, 364), density=0.35)  # the west hall: slow, all the way up
A.effect("spores", (-240.3, 276, -235.7, 294), density=1.6, speed=2.0)  # the lift: a rising column of them
A.effect("spores", (-262.5, 355, -249.5, 367), density=1.2, speed=3.0)  # the bridge's gusts
A.effect("spores", (-266, 264, -215, 301), density=0.4)
A.effect("spores", (-266, 334, -190, 370), density=0.3)
A.effect("drips", (-266, 264, -246, 288), density=0.5)  # off the island's underside onto the vines
A.effect("drips", (-229.5, 292, -224, 333), density=0.6)  # down the snail wall
A.effect("drips", (-241.5, 333.6, -222.5, 340), density=0.3)  # off the giant's rim onto the terrace
A.effect("mist", (-291, 264, -256, 267), density=0.5)
A.effect("mist", (-215, 318, -190, 320.5), density=0.4)

if __name__ == "__main__":
    A.save()
    for name, lean, power, out in ARCS:
        print("  %-9s lean %+6.1f  power %5.2f  leaves (%+.2f, %+.2f)  rises %.2f" % (name, lean, power, out[0], out[1], out[1] ** 2 / (2 * G)))
