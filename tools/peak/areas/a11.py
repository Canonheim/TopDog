"""
A11 LA CUMBRE: the summit, above the clouds. The game's ending.
  python tools/peak/areas/a11.py

The whole summit is ONE slick snow dome that pours east, off a prow over the entry ledge
and down past A10's ridge. Everything you climb stands clear of it, so every miss is the
same fall: the dome, the prow, the mountain.

Two conventions used all through this file:

1. ROOTS ONE LAYER BACK. In a cross-section, a tooth standing in a bowl dams the bowl: a
   body sliding east stops against it. So the crown's teeth and the two horns are drawn as
   rock CARDS one layer behind the climbing plane, and only their tips (the holds) are
   solid. A faller slides past in front of the roots. Nothing holds a body.

2. THE STEP THAT LEAVES. A launch hold needs 2.3 m of clear air all round, but a hold can
   only be reached from something within 1.9 m. So each launch hold (a small round knob,
   a bar seen end-on) is reached from a pale grey BRITTLE step that breaks away 3 s after
   it is taken and grows back 12 s later. Land, reach up, and the step leaves you hanging
   in clear air.
"""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from peaklib import Area, box_pts, ngon

A = Area("a11", "summit")

STEP = {"type": "crumble", "t": 3.0, "respawn": 12.0}  # the step that leaves

# ================================================================ the summit's rock
# The dome's top line: 38.7 degrees off the prow, 35 degrees above. Convex, no pockets.
LIP = (-330.0, 968.6)  # the prow's lip: 2 m east of A10's ledge end, 4.6 m above it
D1 = (-340.0, 976.6)
D3 = (-358.6, 989.6)  # the foot of the summit block's east cliff


def dome_y(x):
    """The dome's surface height at x (for clearances)."""
    if x >= D1[0]:
        return LIP[1] + 0.8 * (LIP[0] - x)
    return D1[1] + 0.7 * (D1[0] - x)


# The dome block, all slick: tunnel roof, alcove roof, the prow, the dome, the summit
# block's east cliff, its apex (two 37 to 42 degree slopes: nothing rests), its west flank.
A.solid([(-366.5, 982.6), (-349.0, 970.4), (-341.0, 968.4), (-330.15, 968.2), LIP, D1, D3,
         (-359.0, 999.6), (-360.3, 1000.6), (-361.5, 999.5)], "blackice")

# The west, closed: a slick shoulder from the unseen wall (x -390) down to a slick tunnel
# that runs east under the dome at 34.8 degrees and pours onto the entry slab (grip).
# A body flung over the bell lands here and is back at the area's start.
A.solid([(-390.2, 962.0), (-349.0, 962.0), (-349.0, 966.0), (-372.0, 982.0), (-390.2, 996.0)], "blackice")

# ================================================================ 11.1 Sobre las Nubes
# The alcove under the prow: A10's ledge (top 964, x -340 to -332) and this slab behind it.
# Open to the east, the cloud sea at your feet, gold light coming in. Breathe.
# Its unease: the black tunnel mouth in the back wall, and the mountain's whole fall line
# pouring off the lip 4.6 m over your head.
A.solid([(-349.0, 962.0), (-340.0, 962.0), (-340.0, 964.0), (-349.0, 965.0)], "rock")
A.challenge("11.1", "Sobre las Nubes", (-344.5, 964.5), 1, "X")
A.cam((-350, 962, -330.6, 968.5), half_h=5.5, bias=(4.0, 1.5))

# ================================================================ 11.2 La Corona
# Out round the prow's lip and up a ring of five teeth: east low, two up the west side
# over the dome, back under the horns, east high. Each tooth is a gold knob (the launch)
# over a brittle collar (the landing, 1.6 m wide, 1.8 m under the knob).
# The first knob hangs under the lip, 3 m below the fall line: it is also the summit's
# ONE last chance for a body that dribbles off the prow slowly.
A.box(-331.1, 965.4, 0.8, 0.45, "brittle", hold=STEP)  # the nose: ledge end -> here -> the knob
L0 = (-329.8, 965.9)
A.hold(L0[0], L0[1], r=0.26, kind="iron")  # an old turnbuckle ring

JEWELS = [(-325.6, 970.4), (-332.6, 976.6), (-339.6, 981.8), (-328.6, 979.8), (-321.6, 981.8)]
for i, (jx, jy) in enumerate(JEWELS):
    A.hold(jx, jy, r=0.26, kind="gold", n=8)
    if i < 4:
        A.box(jx, jy - 2.05, 1.6, 0.5, "brittle", hold=STEP)  # the collar: top 1.8 m under the knob
# The fifth tooth is the rest before the ropes: a real shelf (2.6 m) with a brittle
# boulder on it. Stand on the boulder to reach the knob; then it is gone.
SHELF = 979.2
A.ledge(-322.9, -320.3, SHELF, "rock", t=0.6)
A.box(-321.6, SHELF + 0.4, 1.0, 0.8, "brittle", hold=STEP)
# Its iced belly: a body flung straight up at it from below (a skip from the first tooth)
# meets ice, not an edge to grab.
A.solid([(-322.9, SHELF - 0.5), (-320.3, SHELF - 0.5), (-320.3, SHELF - 1.8), (-321.6, SHELF - 2.3)], "blackice")
C = [(x, y - 1.8) for x, y in JEWELS]  # collar tops
A.challenge("11.2", "La Corona", (-333.0, 964.0), 4, "X", moves=[
    ["reach", [-332.0, 964.0], [-331.1, 965.4]],
    ["reach", [-331.1, 965.4], list(L0)],
    ["fling", list(L0), list(C[0]), "F2"],  # 4.2 across, 2.7 up: 4.6 m/s
    ["reach", list(C[0]), list(JEWELS[0])],
    ["fling", list(JEWELS[0]), list(C[1]), "F3"],  # 7.0 across, 4.4 up: 5.95 m/s
    ["reach", list(C[1]), list(JEWELS[1])],
    ["fling", list(JEWELS[1]), list(C[2]), "F3"],  # 7.0 across, 3.4 up: 5.6 m/s
    ["reach", list(C[2]), list(JEWELS[2])],
    ["fling", list(JEWELS[2]), list(C[3]), "F3"],  # 11 across, 3.8 DOWN: throw it FLAT, under the west horn's foot
    ["reach", list(C[3]), list(JEWELS[3])],
    ["fling", list(JEWELS[3]), [-321.6, SHELF], "F2"],  # 7.0 across, 0.6 down, onto the shelf
])
A.cam((-349, 968.6, -319, 983.9), half_h=9.0, bias=(0.0, -1.0))
A.cam((-330.6, 962, -319, 968.6), half_h=9.0, bias=(2.0, 3.0))  # the first knob, under the lip

# ================================================================ 11.3 Las Cuerdas del Campeon
# The first ring's ropes on the inner faces of the two horns. Each rope lies on a slick
# 55 degree facet and throws along its normal, 35 degrees above level, at
#     speed out = power + gain x speed in = 1.2 + 1.0 x speed in      (gravity 2.79)
# Rope midlines are 6.4 m apart (x -328.6 and -322.2). One crossing at speed v, thrown at 35 degrees:
#     t = 6.4 / (v cos35),  rise = 6.4 tan35 - 1.395 t^2,  speed in = sqrt(v^2 - 2 x 2.79 x rise)
# Entering west at 4.0 m/s onto the west horn's bottom rope (stepped through with those three lines):
#     hit  1  W  y 985.4   out 5.7   rise 2.0
#     hit  2  E  y 987.4   out 5.9   rise 2.0
#     hit  3  W  y 989.4   out 6.0   rise 2.2
#     hit  4  E  y 991.6   out 6.1   rise 2.2
#     hit  5  W  y 993.8   out 6.3   rise 2.2
#     hit  6  E  y 996.0   out 6.4   thrown west over the west horn's top (995.2), into its corner post
# 985.4 to 996.0: 10.6 m gained. Gain 1.0 makes the speed settle (toward 6.5 m/s) instead of
# running away, and the three ropes on each horn tile its whole face (3.6 m of height each),
# so a body that arrives a metre high or low still meets rope. Entries from 3.25 to 5 m/s top out.
TH = math.radians(35.0)
H = 3.6  # the height each rope covers
HX = H * math.tan(TH)  # and how far its foot stands out from the face
XW, XE = -328.6, -322.2
YW0, YE0 = 984.2, 985.7
OFF = 0.2  # the rope stands this far proud of its facet
wn = (math.cos(TH), math.sin(TH))  # the west horn's ropes throw east and up
en = (-math.cos(TH), math.sin(TH))  # the east horn's throw west and up
west_face, east_face = [], []
for k in range(3):
    top = (XW - HX / 2, YW0 + (k + 1) * H)  # at the face
    foot = (XW + HX / 2, YW0 + k * H)  # standing out
    A.bounce(top, foot, power=1.2, gain=1.0, look="rope")
    west_face += [(foot[0] - wn[0] * OFF, foot[1] - wn[1] * OFF), (top[0] - wn[0] * OFF, top[1] - wn[1] * OFF)]
    foot = (XE - HX / 2, YE0 + k * H)
    top = (XE + HX / 2, YE0 + (k + 1) * H)
    A.bounce(foot, top, power=1.2, gain=1.0, look="rope")
    east_face += [(foot[0] - en[0] * OFF, foot[1] - en[1] * OFF), (top[0] - en[0] * OFF, top[1] - en[1] * OFF)]
# The horns: slick all over (you cannot cling to a horn or hold a rope).
WTOP = 995.2
A.solid(west_face + [(west_face[-1][0], WTOP - 0.5), (-332.2, WTOP - 0.5), (-332.2, west_face[0][1])], "blackice")
A.solid(east_face + [(-320.6, 999.9), (-320.2, 998.5), (-320.2, east_face[0][1])], "blackice")
J5 = JEWELS[4]
A.challenge("11.3", "Las Cuerdas del Campeón", (-321.0, SHELF), 4, "X", moves=[
    ["reach", [-321.6, SHELF + 0.8], list(J5)],
    ["fling", list(J5), [-328.4, 985.6], "F3"],  # 6.8 across, 3.8 up: 5.7 m/s; thrown flat at 6 it arrives at about 4
])
A.cam((-328.2, 984.0, -319, 1001), half_h=9.0, bias=(-1.0, 2.0))

# ================================================================ 11.4 El Ultimo Salto
# The west horn's top: grip, 2.6 m, with the old ring's corner post at its west end (the
# backstop for the last rope's throw, and the turnbuckle a luchador climbs before the leap).
# Beyond the post: a rotten plank, an iron ring, and 20 m of air to the bell rope.
A.ledge(-332.2, -329.6, WTOP, "rock", t=0.5)
A.box(-332.0, WTOP + 1.5, 0.4, 3.0, "wood")  # the corner post
A.ledge(-334.4, -332.2, WTOP, "rotten", t=0.25, hold=STEP)  # the last plank of the old apron
L4 = (-335.7, 996.3)
A.hold(L4[0], L4[1], r=0.26, kind="iron")
ROPE_X = -355.7
A.challenge("11.4", "El Último Salto", (-330.4, WTOP), 5, "X", moves=[
    ["reach", [-334.4, WTOP], list(L4)],
    ["fling", list(L4), [ROPE_X, 995.5], "F4"],  # 20.0 across, 0.8 down: 7.3 m/s
])
A.cam((-352.5, 989.5, -328.3, 1004.5), half_h=14.0, bias=(-8.0, -3.0))

# ================================================================ 11.5 La Campana / 11.6 Top Dog
# The bell frame stands on the apex. Its beam reaches 5.5 m east; the bell hangs under the
# beam's end on an iron yoke, and the rope hangs 10 m from the bell, over the dome.
POST_X = -360.3
A.box(POST_X, 1003.1, 0.5, 6.6, "wood")  # the post, footed in the apex, top 1006.4
A.beam((-361.6, 1005.5), (-354.8, 1005.5), t=0.4, kind="wood")  # the beam
A.beam((POST_X, 1002.4), (-357.6, 1005.3), t=0.25, kind="wood")  # the brace
A.box(ROPE_X, 1003.75, 0.18, 3.1, "iron")  # the yoke the bell hangs on: rope top to beam
A.rope("bell_rope", (ROPE_X, 1002.2), 10.0, kind="rope", seg=0.5,
       bob={"w": 0.5, "h": 0.3, "mass": 3.0, "kind": "wood"})  # the toll handle on its end
# The last of the ones who tried: he sits on a perch in the cliff, 4 m under the bell, looking up.
A.solid([(-359.1, 997.9), (-357.0, 998.35), (-357.0, 998.7), (-359.1, 998.7)], "rock")
A.statue(-358.4, 999.0, pose="sit")
A.challenge("11.5", "La Campana", (-357.5, 998.7), 2, "X", moves=[
    ["reach", [-357.0, 999.9], [ROPE_X, 999.9]],
])
A.challenge("11.6", "Top Dog", (-356.4, 1005.7), 1, "", moves=[
    ["reach", [ROPE_X, 1005.2], [-357.3, 1005.7]],
    ["reach", [-357.3, 1005.7], [-358.9, 1005.7]],
    ["reach", [-358.9, 1005.7], [POST_X, 1006.4]],
])
A.finish((POST_X - 0.75, 1006.15, POST_X + 0.75, 1007.65))  # the belt, on the post's top
A.cam((-363, 989.5, -352.6, 1009), half_h=8.0, bias=(2.0, -1.5))

# ================================================================ the picture
# Sky, sun and the cloud sea.
A.card([(-420, 940), (-290, 940), (-290, 1040), (-420, 1040)], z=-40.0, tone="#FFE7B0", edge=False)
A.card(ngon(-352.0, 1003.0, 11.0, 24), z=-36.0, tone="#FFF6D8", edge=False)  # the sun, behind the bell
A.card([(-420, 940), (-290, 940), (-290, 961), (-305, 964), (-322, 961.5), (-341, 965.5), (-360, 962), (-380, 966), (-400, 962.5), (-420, 965)],
       z=-22.0, tone="#FFF1D6")
A.card([(-420, 940), (-290, 940), (-290, 958), (-312, 961.5), (-330, 958.5), (-352, 962.5), (-374, 959), (-396, 962), (-420, 958)],
       z=-10.0, tone="#FFFFFF")
# (This nearest bank of cloud stood IN FRONT of the plane, z 3: it hid the whole top of the storm
# ridge, 10.6 to 10.9, behind a white sheet. Behind the climb now.)
A.card([(-420, 940), (-290, 940), (-290, 957), (-318, 960.5), (-346, 957.5), (-372, 961), (-420, 957)], z=-5.0, tone="#FFFFFF")
A.effect("clouds", (-392, 952, -316, 966))
A.effect("dust", (-380, 966, -320, 1008), tone="gold", density=0.3)

# The mountain's far side: warm pale rock behind everything.
A.card([(-392, 960), (-318, 960), (-318, 966), (-324, 973), (-336, 980), (-347, 987), (-357, 992.5), (-358, 1000.8),
        (-362.6, 1000.8), (-366, 991), (-392, 1001)], z=-3.0, tone="rock2")
A.card([(-372, 982), (-366.5, 982.6), (-349, 970.4), (-349, 966)], z=-2.0, tone="#6E5236")  # the tunnel's dark
# Snow on the dome and the shoulder: white cards in front, set back from the surface so the
# black ice shows as a wet rim all along the line a body slides on.
A.card([(-333.5, 969.9), (-340.0, 975.4), (-358.9, 988.6), (-359.6, 999.2), (-360.3, 999.8), (-361.0, 999.0),
        (-365.3, 984.6), (-349.0, 972.0), (-341.0, 969.9)], z=2.0, tone="snow")
A.card([(-389.5, 963), (-351, 963), (-351, 966.0), (-372, 980.6), (-389.5, 994.2)], z=2.0, tone="snow")

# The crown's teeth and the horns' roots: rock one layer back (see the note at the top).
for i, (jx, jy) in enumerate(JEWELS):
    base = dome_y(jx) - 1.0 if jx < LIP[0] else 958.0
    w = 1.7 if i == 4 else 1.25
    A.card([(jx - w, base), (jx + w, base), (jx + 0.4, jy - 0.15), (jx - 0.4, jy - 0.15)], z=-1.4, tone="rock")
A.card([(-332.6, 984.4), (-327.2, 984.4), (-326.0, 958.0), (-334.2, 958.0)], z=-1.8, tone="rock")  # west horn's root
A.card([(-323.5, 985.8), (-319.8, 985.8), (-318.4, 958.0), (-325.2, 958.0)], z=-1.8, tone="rock")  # east horn's root

# The story: the town's colours, whole and bright.
A.deco("summit_bell", ROPE_X, 1003.6 + 2.7, z=0.0, tone="gold")  # (the bell's origin is its hanging point)
# (the bell has the First Top Dog's face cast on it)
A.deco("champion_belt", POST_X, 1006.9, z=0.0, size=(1.2, 0.6, 0.2), tone="gold")
A.deco("ring_post", -332.0, WTOP, z=0.0, size=(0.4, 3.0, 0.4), tone="accent")
A.deco("ring_post", -320.6, 996.5, z=-0.4, size=(0.4, 3.4, 0.4), tone="accent")
A.deco("ring_post", -321.0, SHELF, z=-0.9, size=(0.4, 2.2, 0.4), tone="accent")  # a fallen third, on the shelf
A.deco("papel_string", -326.2, 999.4, z=-1.0, size=(11.5, 1.0, 0.05), tone="accent")  # horn to horn
A.deco("papel_string", -343.4, 1001.85, z=-1.2, rot=-17.7, size=(23.9, 1.2, 0.05), tone="accent")  # horn to bell: the line of the leap
A.deco("papel_string", -372.0, 1000.6, z=-1.2, rot=19.0, size=(22.0, 1.2, 0.05), tone="accent")  # bell to the west shoulder
A.deco("papel_string", -336.0, 967.9, z=-1.0, size=(9.0, 0.8, 0.05), tone="accent")  # across the alcove's mouth
for (ax, ay), (bx, by) in zip(JEWELS[:-1], JEWELS[1:]):
    A.deco("marigold_garland", (ax + bx) / 2, (ay + by) / 2 - 1.2, z=-1.2,
           rot=math.degrees(math.atan2(by - ay, bx - ax)), size=(math.dist((ax, ay), (bx, by)), 0.5, 0.2), tone="accent")
A.deco("marigold_garland", POST_X, 1003.0, z=0.4, rot=90.0, size=(5.5, 0.5, 0.2), tone="accent")  # wound up the post
A.deco("marigold_garland", -358.0, 1005.5, z=0.4, size=(6.5, 0.5, 0.2), tone="accent")  # along the beam
A.deco("marigold_pile", -358.9, 998.7, z=-0.5, size=(0.8, 0.4, 0.6), tone="accent")  # left beside the one who sits
A.deco("cold_lantern", -346.5, 964.8, z=-0.8, size=(0.3, 0.5, 0.3), tone="iron")  # in the alcove: someone waited here
A.light(-343.0, 967.0, color="#FFD98A", rng=10.0, energy=1.2)
A.light(-332.0, 978.0, color="#FFD98A", rng=12.0, energy=1.0)
A.light(-325.4, 991.0, color="#FFD98A", rng=10.0, energy=1.0)
A.light(ROPE_X, 1001.0, color="#FFE9A8", rng=12.0, energy=1.6)

if __name__ == "__main__":
    A.save()
