"""
A9 EL GLACIAR: the glacier (784 to 888 m). Ice that lets go, snow that falls in, the slide.
  python tools/peak/areas/a9.py

THE SHAPE. The glacier is a tongue of ice standing on the mountain's east face. Its own
east face is a cliff at about x -281 (the slide: whatever comes off the upper route or
down from the storm ridge falls along it, hits the lower lip's ramps and is thrown off
the lip's tip at (-271.5, 791.4), clear of the high station's deck, into the throat).
Inside the ice, west of that skin, is the crevasse system:
  the alcove under the lip -> the passage -> THE LOWER CREVASSE (9.1, 9.2, 9.3: a miss
  drops to its snow floor at 786, the foot of 9.1) -> a door -> LA CUEVA DE HIELO (9.4:
  its floor at 804, its balcony at 812, the statue chimney up to 832) -> the upper
  level (9.5 the serac, 9.6 the toboggan, both OVER the cave: a miss lands on the cave's
  snow, at the foot of 9.4) -> the rope -> the window in the skin at 830.
From the window on the route is outside (9.7 to 9.10): every miss is the slide.
"""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from peaklib import Area, box_pts, ngon, fling_speed, G

A = Area("a9", "glacier")
ICE = "blackice"      # the glacier's body: blue-black, slick
BLUE = "#9FDDF2"      # the pale blue of ice you can hold for 2 s


def bone(x, y, r=0.17):
    """A frozen mitten or boot: the grip point of a statue, made solid so the route never
    depends on a pose's exact shape."""
    A.hold(x, y, r=r, kind="bone")


def encased(x, y, w=1.7, h=3.0):
    """The card of blue ice in FRONT of a frozen climber."""
    A.card(box_pts(x, y + 0.15, w, h), z=1.5, tone=BLUE, edge=False)


def climber(x, y, pose, flip=False, rot=0.0, grips=True, card=True):
    """One of the ones who tried, with his three grips: boots (y - 0.85), belt (y),
    mitten (y + 1.2). (x, y) is the pelvis."""
    A.statue(x, y, pose, rot=rot, flip=flip)
    if grips:
        for dy in (-0.85, 0.0, 1.2):
            bone(x, y + dy)
    if card:
        encased(x, y)


# ================================================================ THE ICE (the big masses)
# The mountain side and the bed.
A.solid([(-335, 780), (-281, 780), (-281, 784), (-282, 784), (-282, 785.4), (-335, 785.4)], ICE)
A.solid([(-341, 780), (-331, 780), (-331, 886), (-341, 886)], ICE)  # the west wall (rock under ice)
A.ledge(-331.0, -282.0, 786.0, "snow", t=0.7)  # the crevasse floor: firm snow, all of it

# The skin of the lower tongue and THE LIP (the slide's last ramp: 52 then 34 degrees).
LIP_TIP = (-271.5, 791.4)
A.solid([(-284.5, 790.8), (-271.5, 790.9), LIP_TIP, (-276.5, 794.8), (-280.5, 800.0), (-281.0, 830.2),
         (-284.5, 830.2)], ICE)

# The cave's floor slab (the passage runs under it) and its snow.
A.solid([(-305.5, 790.8), (-284.5, 790.8), (-284.5, 803.4), (-305.5, 803.4)], ICE)
A.ledge(-305.5, -284.5, 804.0, "snow", t=0.6)
# The roof of the lower crevasse = the cave's balcony.
A.solid([(-331, 809.5), (-303, 809.5), (-303, 811.4), (-331, 811.4)], ICE)
A.solid([(-305.5, 808.5), (-303, 808.5), (-303, 811.4), (-305.5, 811.4)], ICE)  # the door's lintel
A.ledge(-331.0, -303.0, 812.0, "snow", t=0.6)

# The upper level's floor pieces (their undersides are the balcony's roof, y 817).
A.solid([(-327.5, 817), (-322.8, 817), (-322.8, 831.5), (-327.5, 831.5)], ICE)  # under R4
A.ledge(-327.5, -322.8, 832.0, "snow", t=0.5)  # R4 (the serac stands on its east end)
A.solid([(-322.8, 817), (-321.4, 817), (-321.4, 824.5), (-322.8, 825.5)], ICE)  # the pit's west funnel
# The toboggan's mass: pit funnel, T's block, the ramp and the bowl (see 9.6).
RAMP = [(-310.46, 834.5), (-309.62, 828.5), (-308.92, 827.29), (-308.12, 826.40), (-307.31, 825.81),
        (-306.49, 825.44), (-305.61, 825.25), (-304.81, 825.25), (-304.02, 825.39)]
A.solid([(-318.8, 817), (-304.02, 817)] + RAMP[::-1] + [(-312.96, 834.5), (-312.96, 828.5), (-318.8, 824.5)], ICE)
A.ledge(-312.96, -310.46, 834.5, "snow", t=0.4)  # T: the serac's landing, the toboggan's top

# The roof over the upper level, and everything above it up to the chute and the ridge's rock.
NOSE = (-278.8, 850.5)  # L: the avalanche chute's mouth, its lower lip
CH_A, CH_B = (-288.0, 861.46), (-296.0, 866.46)  # the chute: 50 degrees, then 32, then 62
CH_TOP = (-302.5, 878.7)  # where the chute meets the ridge's rock
A.solid([(-331, 842), (-311, 842), (-300, 834.7), (-285.5, 834.7), (-285.5, 850.0), (-278.8, 850.2), NOSE,
         CH_A, CH_B, CH_TOP, (-302.5, 884.6), (-331, 884.6)], ICE)
# The skin above the window: the brow B1 and the face of 9.7.
A.solid([(-285.5, 834.7), (-281.0, 834.7), (-279.5, 834.5), (-279.5, 834.75), (-282.5, 836.8), (-282.5, 846.3),
         (-285.5, 846.3)], ICE)

# The exit: the storm ridge's foot. Rock, top y 886, x -312 .. -302.
A.ledge(-312.0, -302.0, 886.0, "rock", t=1.4)
A.solid([(-331, 884.6), (-312, 884.6), (-312, 886.0), (-331, 886.0)], "rock")  # the ridge's rock behind it
A.solid([(-302.62, 885.2), (-301.9, 884.9), (-301.9, 886.12), (-302.62, 886.12)], ICE)  # verglas on its nose

# THE TOWER: the glacier's top, a mushroom of ice. Stem on the east, the cornice curling
# west over the rimaye. Its top slopes east at 33.7 degrees (nothing rests on it). Its tip
# stops at x -295.7 so the launch of 9.10 hangs clear of a10's knife edge (the slick
# pillar whose point is at (-296.2, 885.2)).
TIP = (-295.7, 881.0)
ROOF_Y = 871.8
A.solid([(-280, 858.5), (-280, 870.53), TIP, (-295.9, 880.7), (-295.9, 877.3), (-293.2, 877.3), (-293.2, 873.3),
         (-295.9, 873.3), (-295.9, ROOF_Y), (-283.5, ROOF_Y), (-283.5, 867.8), (-286.5, 867.8), (-286.5, 866.25)], ICE)
A.ledge(-286.5, -283.5, 867.8, "snow", t=0.4)  # R8: the niche in the stem
A.ledge(-295.9, -293.2, 873.3, "snow", t=0.4)  # R9: the niche under the tip
A.ledge(-285.5, -282.5, 846.3, "snow", t=0.4)  # R7: the niche under the chute's mouth

# ================================================================ 9.1 Hielo Azul
# The blue wall of the lower crevasse: a rising line of holds from the passage's mouth
# to R1, 19.5 m west and 10.7 m up. Pale blue ice lets go after 2 s; the grey rock nubs
# do not. Three rock nubs: the runs of ice between them are 2, 3 and 4 holds, then 3 more.
P1A, P1B = (-308.0, 787.8), (-327.5, 798.5)
K91 = ["ice", "ice", "rock", "ice", "ice", "ice", "rock", "ice", "ice", "ice", "ice", "rock", "ice", "ice", "ice"]
H91 = []
for i, k in enumerate(K91):
    f = i / 14.4
    zig = 0.33 if i % 2 else -0.33
    x = P1A[0] + (P1B[0] - P1A[0]) * f + zig * 0.48
    y = P1A[1] + (P1B[1] - P1A[1]) * f + zig * 0.88
    H91.append((x, y))
    if k == "rock":
        A.hold(x, y, r=0.24, kind="rock")
    else:
        A.box(x, y, 0.66, 0.34, "ice", rot=(18 if i % 2 else -14))
A.ledge(-331.0, -327.5, 798.5, "snow", t=0.6)  # R1
m91 = [["reach", list(H91[i]), list(H91[i + 1])] for i in range(len(H91) - 1)]
m91.append(["reach", list(H91[-1]), [-327.5, 798.5]])
A.challenge("9.1", "Hielo Azul", (-306.6, 786.0), 3, "B", moves=m91)

# ================================================================ 9.2 Carámbanos
# Under the ice shelf (its top is R2). The five big icicles are holds for 0.7 s each;
# the rock tooth in the middle is the one breath. Small ones fall between them on timers
# (they tick first), down onto the line of 9.1 and the floor.
SH_Y = 802.6
A.solid([(-331, SH_Y), (-319, SH_Y), (-319, 803.5), (-331, 803.5)], ICE)
A.ledge(-331.0, -319.0, 804.0, "snow", t=0.5)  # R2
ICI = [(-326.9, 800.0), (-325.5, 800.2), (-324.1, 800.0), None, (-321.3, 800.8), (-320.0, 801.5)]
for it in ICI:
    if it:
        A.solid([(it[0] - 0.3, SH_Y + 0.05), (it[0] + 0.3, SH_Y + 0.05), (it[0], it[1])], "icicle")
A.solid([(-323.0, SH_Y + 0.05), (-322.4, SH_Y + 0.05), (-322.7, 800.3)], "rock")  # the rock tooth
A.hold(-318.85, 803.1, r=0.22, kind="rock")  # on the shelf's nose
G92 = [(-326.9, 800.4), (-325.5, 800.6), (-324.1, 800.4), (-322.7, 800.7), (-321.3, 801.2), (-320.0, 801.9),
       (-318.85, 803.1), (-319.05, 804.0)]
for sx, ph in ((-326.2, 0.0), (-324.8, 1.6), (-322.0, 3.1), (-320.65, 0.8)):
    A.spawner("icicle", (sx, SH_Y - 0.5), period=4.6, phase=ph, r=0.3, life=7.0, warn=1.0, mass=12.0)
A.spawner("icicle", (-329.4, SH_Y - 0.5), period=9.0, phase=4.0, r=0.3, life=5.0, warn=1.2, mass=12.0)  # over R1
A.challenge("9.2", "Carámbanos", (-328.4, 798.5), 4, "B",
            moves=[["reach", list(G92[i]), list(G92[i + 1])] for i in range(len(G92) - 1)])

# ================================================================ 9.3 Puente de Nieve
# Three snow bridges from R2 to the cave's door, each of three pieces that fall in 1 s
# after they are taken, with two chockstones wedged between the bridges.
def bridge(x0, n, w):
    out = []
    for i in range(n):
        a = x0 + i * w
        A.solid([(a + 0.02, 803.55), (a + w - 0.02, 803.55), (a + w - 0.02, 804.0), (a + 0.02, 804.0)], "snowbridge")
        out.append((a + w * 0.5, 804.0))
    return out
S93 = bridge(-319.0, 3, 1.25)
A.solid([(-315.25, 804.0), (-315.1, 803.2), (-314.5, 802.9), (-314.05, 803.3), (-314.05, 804.0)], "rock")
S93 += [(-314.65, 804.0)] + bridge(-314.05, 3, 1.25)
A.solid([(-310.3, 804.0), (-310.3, 803.3), (-309.8, 802.8), (-309.2, 803.1), (-309.1, 804.0)], "rock")
S93 += [(-309.7, 804.0)] + bridge(-309.1, 3, 1.2) + [(-305.2, 804.0)]
A.spawner("icicle", (-324.5, 809.2), period=10.0, phase=2.0, r=0.3, life=6.0, warn=1.2, mass=12.0)  # over R2
A.challenge("9.3", "Puente de Nieve", (-320.4, 804.0), 3, "B",
            moves=[["reach", [-319.3, 804.0], list(S93[0])]] +
                  [["reach", list(S93[i]), list(S93[i + 1])] for i in range(len(S93) - 1)])
A.cam((-321, 800, -305, 809), half_h=9.5, bias=(0.0, -5.0))

# ================================================================ 9.4 La Cueva de Hielo
# The door (x -305.5 .. -303, y 804 .. 808.5) opens on the cave floor. Two frozen
# climbers by the door are the way up to the balcony (812); the balcony runs west under
# the ice to the chimney (x -331 .. -327.5, 3.5 m wide, y 812 .. 832): three more of them
# and a few holds of ice. The last one is frozen reaching, his mitten 0.15 m under the
# lip he almost climbed out over: he is the last hold.
climber(-302.4, 806.9, "hang")
climber(-302.4, 809.8, "cling", flip=True)
climber(-329.9, 814.4, "hang")
A.box(-328.7, 816.9, 0.6, 0.34, "ice", rot=10)
A.box(-329.9, 818.2, 0.6, 0.34, "ice", rot=-12)
climber(-328.7, 820.2, "cling")
A.box(-329.9, 822.6, 0.6, 0.34, "ice", rot=12)
A.hold(-328.8, 823.9, r=0.23, kind="rock")
climber(-329.9, 826.0, "fall", flip=True)
A.box(-328.8, 828.4, 0.6, 0.34, "ice", rot=-10)
climber(-328.2, 830.6, "reach")  # the saddest: mitten at (-328.2, 831.8), the lip at y 832
C94 = [(-302.4, 806.05), (-302.4, 806.9), (-302.4, 808.1), (-302.4, 808.95), (-302.4, 809.8), (-302.4, 811.0), (-303.0, 812.0)]
D94 = [(-329.9, 813.55), (-329.9, 814.4), (-329.9, 815.6), (-328.7, 816.9), (-329.9, 818.2), (-328.7, 819.35),
       (-328.7, 820.2), (-328.7, 821.4), (-329.9, 822.6), (-328.8, 823.9), (-329.9, 825.15), (-329.9, 826.0),
       (-329.9, 827.2), (-328.8, 828.4), (-328.2, 829.75), (-328.2, 830.6), (-328.2, 831.8), (-327.4, 832.0)]
A.challenge("9.4", "La Cueva de Hielo", (-300.5, 804.0), 3, "S",
            moves=[["reach", list(C94[i]), list(C94[i + 1])] for i in range(len(C94) - 1)] +
                  [["reach", list(D94[i]), list(D94[i + 1])] for i in range(len(D94) - 1)])
A.spawner("icicle", (-293.0, 834.0), period=11.0, phase=5.0, r=0.3, life=9.0, warn=1.4, mass=12.0)  # into the cave
