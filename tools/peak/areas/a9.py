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
import a9_dress  # the glacier's scenery (the modelling run's): decos only

A = Area("a9", "glacier")
ICE = "blackice"      # the glacier's body: blue-black, slick
BLUE = "#9FDDF2"      # the pale blue of ice you can hold for 2 s


def bone(x, y, r=0.17):
    """A frozen mitten or boot: the grip point of a statue, made solid so the route never
    depends on a pose's exact shape."""
    A.hold(x, y, r=r, kind="bone")


def encased(x, y, w=1.7, h=3.0):
    """The card of blue ice in FRONT of a frozen climber."""
    # (It stood in FRONT, z 1.5, and covered whoever climbed him. Nothing stands in front of
    # where a climber can be, Parker 11-12: the ice is at his back now.)
    A.card(box_pts(x, y + 0.15, w, h), z=-0.9, tone=BLUE, edge=False)


def climber(x, y, pose, flip=False, rot=0.0, grips=True, card=False):
    """One of the ones who tried, with his three grips: boots (y - 0.85), belt (y),
    mitten (y + 1.2). (x, y) is the pelvis. (card: the old ice card at his back; a9_dress item 4
    places the ice behind him now, so none is drawn.)"""
    A.statue(x, y, pose, rot=rot, flip=flip)
    if grips:
        for dy in (-0.85, 0.0, 1.2):
            bone(x, y + dy)
    if card:
        encased(x, y)


# ================================================================ THE ICE (the big masses)
# The mountain side and the bed.
A.solid([(-335, 780), (-281, 780), (-281, 784), (-282, 784), (-282, 785.4), (-335, 785.4)], ICE, skin="glaciar_bed")
A.solid([(-341, 780), (-331, 780), (-331, 886), (-341, 886)], ICE, skin="glaciar_west_wall")  # the west wall (rock under ice)
A.ledge(-331.0, -282.0, 786.0, "snow", t=0.7, skin="glaciar_floor_crack")  # the crevasse floor: firm snow, all of it

# The skin of the lower tongue and THE LIP (the slide's last ramp: 52 then 34 degrees).
LIP_TIP = (-271.5, 791.4)
A.solid([(-284.5, 790.8), (-271.5, 790.9), LIP_TIP, (-276.5, 794.8), (-280.5, 800.0), (-281.0, 829.9),
         (-284.5, 829.9)], ICE, skin="glaciar_tongue_low")

# The cave's floor slab (the passage runs under it) and its snow.
A.solid([(-305.5, 790.8), (-284.5, 790.8), (-284.5, 803.4), (-305.5, 803.4)], ICE, skin="glaciar_cave_slab")
A.ledge(-305.5, -284.5, 804.0, "snow", t=0.6, skin="glaciar_floor_cave")
# The roof of the lower crevasse = the cave's balcony.
A.solid([(-331, 809.5), (-303, 809.5), (-303, 811.4), (-331, 811.4)], ICE, skin="glaciar_crack_roof")
A.solid([(-305.5, 808.5), (-303, 808.5), (-303, 811.4), (-305.5, 811.4)], ICE, skin="glaciar_crack_roof")  # the door's lintel (one piece with the roof)
A.ledge(-331.0, -303.0, 812.0, "snow", t=0.6, skin="glaciar_balcony_snow")

# The upper level's floor pieces (their undersides are the balcony's roof, y 817).
A.solid([(-327.5, 817), (-322.8, 817), (-322.8, 831.5), (-327.5, 831.5)], ICE, skin="glaciar_serac_block")  # under R4
A.ledge(-327.5, -322.8, 832.0, "snow", t=0.5, skin="glaciar_brink_snow")  # R4 (the serac stands on its east end)
A.solid([(-322.8, 817), (-321.4, 817), (-321.4, 824.5), (-322.8, 825.5)], ICE, skin="glaciar_pit_funnel")  # the pit's west funnel
# The toboggan's mass: pit funnel, T's block, the ramp and the bowl (see 9.6).
# The ramp's profile (see 9.6): from T's east edge, each bend 10 degrees so a sliding body
# keeps its speed. (angle below the horizontal, length along the face)
RAMP = [(-310.46, 834.15)]
for _ang, _len in ((82, 5.93), (72, 0.9), (62, 0.9), (52, 0.9), (42, 0.9), (32, 0.8), (22, 0.8), (12, 0.8), (2, 0.7), (-10, 0.6)):
    RAMP.append((RAMP[-1][0] + math.cos(math.radians(_ang)) * _len, RAMP[-1][1] - math.sin(math.radians(_ang)) * _len))
BOWL_END = RAMP[-1]  # (-304.22, 824.50): the crack's west edge
A.solid([(-318.8, 817), (BOWL_END[0], 817)] + RAMP[::-1] + [(-312.96, 834.15), (-312.96, 828.5), (-318.8, 824.5)], ICE, skin="glaciar_tobogan")
A.ledge(-312.96, -310.46, 834.5, "snow", t=0.4, skin="glaciar_pillar_snow")  # T: the serac's landing, the toboggan's top

# The roof over the upper level, and everything above it up to the chute and the ridge's rock.
NOSE = (-278.8, 850.5)  # L: the avalanche chute's mouth, its lower lip
CH_A, CH_B = (-288.0, 861.46), (-296.0, 866.46)  # the chute: 50 degrees, then 32, then 62
CH_TOP = (-302.5, 878.7)  # where the chute meets the ridge's rock
A.solid([(-331, 842), (-311, 842), (-300, 834.7), (-285.5, 834.7), (-285.5, 850.0), (-278.8, 850.2), NOSE,
         CH_A, CH_B, CH_TOP, (-302.5, 884.6), (-331, 884.6)], ICE, skin="glaciar_upper_mass")
# The skin above the window: the brow B1 and the face of 9.7.
A.solid([(-285.5, 834.7), (-281.0, 834.7), (-279.5, 834.5), (-279.5, 834.75), (-282.5, 836.8), (-282.5, 845.7),
         (-285.5, 845.7)], ICE, skin="glaciar_brow")

# The exit: the storm ridge's foot. Rock, top y 886, x -312 .. -302.
A.ledge(-312.0, -302.0, 886.0, "rock", t=1.4, skin="tormenta_porch")  # (the porch: a10_dress's)
A.solid([(-341, 884.6), (-312, 884.6), (-312, 886.0), (-341, 886.0)], "rock", skin="tormenta_ridge_mass")  # the ridge's rock behind it
# Verglas on its nose: a lump of black ice, 33 degrees, that sheds a short landing.
A.solid([(-302.9, 886.0), (-302.9, 886.75), (-301.75, 886.0), (-301.75, 884.6), (-302.0, 884.6), (-302.0, 886.0)], ICE,
        skin="glaciar_verglas_nose")

# THE TOWER: the glacier's top, a mushroom of ice. Stem on the east, the cornice curling
# west over the rimaye. Its top slopes east at 33.7 degrees (nothing rests on it). Its tip
# stops at x -295.7 so the launch of 9.10 hangs clear of a10's knife edge (the slick
# pillar whose point is at (-296.2, 885.2)).
TIP = (-295.7, 881.0)
ROOF_Y = 871.8
A.solid([(-280, 859.2), (-280, 870.53), TIP, (-295.9, 880.7), (-295.9, 877.3), (-293.2, 877.3), (-293.2, 873.0),
         (-295.9, 873.0), (-295.9, ROOF_Y), (-283.5, ROOF_Y), (-283.5, 867.5), (-286.5, 867.5), (-286.5, 866.95)], ICE,
        skin="glaciar_tower")
A.ledge(-286.5, -283.5, 867.8, "snow", t=0.4, skin="glaciar_niche_snow")  # R8: the niche in the stem
A.ledge(-295.9, -293.2, 873.3, "snow", t=0.4, skin="glaciar_niche_snow_short")  # R9: the niche under the tip
A.ledge(-285.5, -282.5, 846.0, "snow", t=0.4, skin="glaciar_niche_snow")  # R7: the niche under the chute's mouth

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
        A.hold(x, y, r=0.24, kind="rock", skin="glaciar_stone")
    else:
        A.box(x, y, 0.66, 0.34, "ice", rot=(18 if i % 2 else -14), skin="glaciar_knuckle")
A.ledge(-331.0, -327.5, 798.5, "snow", t=0.6, skin="glaciar_corner_snow")  # R1
m91 = [["reach", list(H91[i]), list(H91[i + 1])] for i in range(len(H91) - 1)]
m91.append(["reach", list(H91[-1]), [-327.5, 798.5]])
A.challenge("9.1", "Hielo Azul", (-306.6, 786.0), 3, "B", moves=m91)

# ================================================================ 9.2 Carámbanos
# Under the ice shelf (its top is R2). The five big icicles are holds for 0.7 s each;
# the rock tooth in the middle is the one breath. Small ones fall between them on timers
# (they tick first), down onto the line of 9.1 and the floor.
SH_Y = 802.6
A.solid([(-331, SH_Y), (-319, SH_Y), (-319, 803.5), (-331, 803.5)], ICE, skin="glaciar_shelf")
A.ledge(-331.0, -319.0, 804.0, "snow", t=0.5, skin="glaciar_shelf_snow")  # R2
ICI = [(-326.9, 800.0), (-325.5, 800.2), (-324.1, 800.0), None, (-321.3, 800.8), (-320.0, 801.5)]
for it, stem in zip([i for i in ICI if i], a9_dress.ICI_STEM):  # (the ringed ones: each its own, a9_dress item 5)
    A.solid([(it[0] - 0.3, SH_Y + 0.05), (it[0] + 0.3, SH_Y + 0.05), (it[0], it[1])], "icicle", skin=stem)
A.solid([(-323.0, SH_Y + 0.05), (-322.4, SH_Y + 0.05), (-322.7, 800.3)], "rock", skin="glaciar_stone_tooth")  # the rock tooth
A.hold(-318.85, 803.1, r=0.22, kind="rock", skin="glaciar_stone")  # on the shelf's nose
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
# (The lower crevasse's redesign, Parker 11-13: "Yes, that". As its design page lays them,
# read off its to-scale sketch: nine pieces 1.1 m long and 0.45 m thick, each bridge sagging
# 0.15 m in the middle, the stones moved east to suit, and 1.2 m of open air between the
# shelf's broken end (x -319.0) and the first piece: stepping over it is the first move.)
def bridge(x0, n=3, w=1.1, gap=0.04, sag=0.15):
    out = []
    for i in range(n):
        a = x0 + i * (w + gap)
        dy = -sag if i == n // 2 else 0.0
        A.solid([(a, 803.55 + dy), (a + w - 0.04, 803.55 + dy), (a + w - 0.04, 804.0 + dy), (a, 804.0 + dy)], "snowbridge",
                skin="glaciar_snow_bridge")  # (each piece wears its own skin: it goes and comes back with it)
        out.append((a + (w - 0.04) * 0.5, 804.0 + dy))
    return out
S93 = bridge(-317.78)
A.solid([(-314.5, 804.0), (-314.35, 803.2), (-313.75, 802.9), (-313.3, 803.3), (-313.3, 804.0)], "rock", skin="glaciar_wedged_stone_a")
S93 += [(-313.9, 804.0)] + bridge(-313.28)
A.solid([(-310.0, 804.0), (-310.0, 803.3), (-309.5, 802.8), (-308.9, 803.1), (-308.8, 804.0)], "rock", skin="glaciar_wedged_stone_b")
S93 += [(-309.4, 804.0)] + bridge(-308.78) + [(-305.2, 804.0)]
A.spawner("icicle", (-324.5, 809.2), period=10.0, phase=2.0, r=0.3, life=6.0, warn=1.2, mass=12.0)  # over R2
A.challenge("9.3", "Puente de Nieve", (-320.4, 804.0), 3, "B",
            moves=[["reach", [-319.2, 804.0], [-317.6, 804.0]], ["reach", [-317.6, 804.0], list(S93[0])]] +
                  [["reach", list(S93[i]), list(S93[i + 1])] for i in range(len(S93) - 1)])
# (No camera of its own: the close camera, as everywhere (Parker 11-13: "Keep the close camera as
# normal"; a9_dress item 6g). The arrow signs on the walls show the way instead.)

# ================================================================ 9.4 La Cueva de Hielo
# The door (x -305.5 .. -303, y 804 .. 808.5) opens on the cave floor. Two frozen
# climbers by the door are the way up to the balcony (812); the balcony runs west under
# the ice to the chimney (x -331 .. -327.5, 3.5 m wide, y 812 .. 832): three more of them
# and a few holds of ice. The last one is frozen reaching, his mitten 0.15 m under the
# lip he almost climbed out over: he is the last hold.
climber(-302.4, 806.9, "hang")
climber(-302.4, 809.8, "cling", flip=True)
climber(-329.9, 814.4, "hang")
A.box(-328.7, 816.9, 0.6, 0.34, "ice", rot=10, skin="glaciar_knuckle_short")
A.box(-329.9, 818.2, 0.6, 0.34, "ice", rot=-12, skin="glaciar_knuckle_short")
climber(-328.7, 820.2, "cling")
A.box(-329.9, 822.6, 0.6, 0.34, "ice", rot=12, skin="glaciar_knuckle_short")
A.hold(-328.8, 823.9, r=0.23, kind="rock", skin="glaciar_stone")
climber(-329.9, 826.0, "fall", flip=True)
A.box(-328.8, 828.4, 0.6, 0.34, "ice", rot=-10, skin="glaciar_knuckle_short")
climber(-328.2, 830.6, "reach")  # the saddest: mitten at (-328.2, 831.8), the lip at y 832
C94 = [(-302.4, 806.05), (-302.4, 806.9), (-302.4, 808.1), (-302.4, 808.95), (-302.4, 809.8), (-302.4, 811.0), (-303.0, 812.0)]
D94 = [(-329.9, 813.55), (-329.9, 814.4), (-329.9, 815.6), (-328.7, 816.9), (-329.9, 818.2), (-328.7, 819.35),
       (-328.7, 820.2), (-328.7, 821.4), (-329.9, 822.6), (-328.8, 823.9), (-329.9, 825.15), (-329.9, 826.0),
       (-329.9, 827.2), (-328.8, 828.4), (-328.2, 829.75), (-328.2, 830.6), (-328.2, 831.8), (-327.4, 832.0)]
A.challenge("9.4", "La Cueva de Hielo", (-300.5, 804.0), 3, "S",
            moves=[["reach", list(C94[i]), list(C94[i + 1])] for i in range(len(C94) - 1)] +
                  [["reach", list(D94[i]), list(D94[i + 1])] for i in range(len(D94) - 1)])
A.spawner("icicle", (-293.0, 834.0), period=11.0, phase=5.0, r=0.3, life=9.0, warn=1.4, mass=12.0)  # into the cave

# ================================================================ 9.5 El Serac
# A tower of ice 7.5 m tall standing on R4's east end, over the pit. Its west side is
# firm snow. Touch it and it tips east about its downhill foot, 75 degrees in 5 s
# (the engine's curve: angle = 75 x (t / 5) squared, so it creeps and then goes), and
# lies across the pit like a log until you are off it for 12 s.
#   The arc of its top east corner (radius 7.5 m about the pivot (-322.8, 832)):
#     standing (-322.8, 839.5) | 30 deg, t 3.2 s (-319.05, 838.5) | 45 deg, t 3.9 s
#     (-317.5, 837.3) | 60 deg, t 4.5 s (-316.3, 835.75) | down, 75 deg (-315.56, 833.94).
#   The jump goes to T: snow, x -312.96 .. -310.46, top y 834.5 (2.5 m wide). From the
#   resting tip that is 2.6 m of air and 0.56 m up: one arm too far to reach
#   (fling_speed(3.4, 0.56) = 3.3 m/s). Jumped as it falls (60 deg) it is 4.3 m and 1.25 m
#   DOWN (3.0 m/s), with the tip's own 3 m/s behind you. Miss: the pit, its funnel, the
#   slot (x -321.4 .. -318.8) and the balcony's snow at the foot of the statue chimney.
PIV = (-322.8, 832.0)
A.mover("serac", PIV,
        [(box_pts(-0.95, 3.55, 1.9, 7.1), ICE),         # the tower
         (box_pts(-2.19, 3.6, 0.6, 6.8), "snow"),       # the snow up its west side (0.6 m: a strip of 0.3 read as a white line)
         (box_pts(-1.25, 7.3, 2.5, 0.4), "snow"),       # its cap
         (ngon(0.12, 7.42, 0.22, 6), "rock")],          # a horn of rock at the top corner
        # (Note 88, Parker 11-13: "Make it fall all the way and then shatter in the hole so it
        # dumps you down there"; "the new serac needs to grow into place". Today's curve, on
        # through level at 5.5 s, shattering at 108 degrees (6.0 s); a new one grows in 3 s,
        # 3 s after.)
        # (a9_dress item 8: the bare tower shows while the next one grows, the stump while it is gone)
        {"type": "tip", "angle": -75.0, "time": 5.0, "trigger": "grab", "reset": 12.0,
         "shatter": -108.0, "regrow_wait": 3.0, "grow": 3.0, "bare": "glaciar_serac_bare", "stump": "glaciar_serac_stump"},
        model="serac")
A.challenge("9.5", "El Serac", (-326.4, 832.0), 4, "B",
            moves=[["fling", [-315.56, 833.94], [-312.2, 834.5], "F1"]])
A.cam((-327.6, 829, -310, 842), half_h=9.5, bias=(3.0, -4.0))

# ================================================================ 9.6 Tobogan Helado
# From T the ramp falls east: 82 degrees for 5.9 m, then it bends ten degrees at a time
# (72, 62, 52, 42, 32, 22, 12, 2) into the bowl and up to +10, then a 1.1 m crack, then
# the kicker: a flake of ice wedged in the crevasse's mouth, its face 1.8 m long at +32
# degrees, lip at (-301.59, 825.21).
#   Height dropped, T to the lip: 834.5 - 825.21 = 9.29 m.
#   v = sqrt(2 x 2.79 x 9.29) = 7.20 m/s; at 85 per cent: 6.12 m/s, leaving at 32 degrees.
#   The rope hangs 15.0 m east of the lip, at x -286.59. At that x the flight is at
#     y = 825.21 + 15 tan 32 - 2.79 x 15^2 / (2 x 6.12^2 x cos^2 32) = 825.21 + 9.37 - 11.65
#       = 822.9  (2.3 m below the lip, 2.9 s in the air).
#   The rope is 16 m long, y 829.35 down to 813.35: it catches anything from 4.55 m/s
#   (63 per cent: y 813.5, its last metre) up to 8.4 m/s (y 828.4).
#   A dead ball slid down this profile in a scratch check (no bounce; the engine's slick
#   friction is 0.02): lip speed 4.8 m/s without the draught, 6.4 m/s with it; it crosses
#   the rope's line at y 816.3 and 824.1. With friction 0.10 as well: 5.2 m/s, y 818.4.
#   With 0.15: 4.4 m/s, and it falls just short. So a clean slide takes the rope's
#   upper half, and a tumbled one its tail.
#   Short or long, a miss falls 20 m to the cave's snow floor (804), at the foot of 9.4.
# The bowl's four shallow faces would hold a body that came in too slowly (slick under
# 30 degrees is a trap), so a steady draught (3.6 m/s2) blows east across it and the
# crack is its drain: a stalled body is pushed into the crack and drops past the flake
# onto the balcony's snow (checked from three places in the bowl and from the flake).
# The draught also gives a good slide about 1.5 m/s more.
_fx, _fy = BOWL_END[0] + 1.1, BOWL_END[1] - 0.25
LIP = (_fx + 1.8 * math.cos(math.radians(32)), _fy + 1.8 * math.sin(math.radians(32)))
A.solid([(_fx, _fy), LIP, (LIP[0], LIP[1] - 0.8), (_fx + 0.5, _fy - 1.55), (_fx, _fy - 1.55)], ICE, skin="glaciar_kicker")  # the flake
# The draught stops 0.3 m short of the crack (the engine's zones reach 0.4 m past their
# rect): it must push a stalled body INTO the crack, never across it onto the flake.
A.wind((-307.2, BOWL_END[1] - 0.4, BOWL_END[0] - 0.7, BOWL_END[1] + 2.9), (3.6, 0.0))
A.rope("rope96", (-286.59, 829.35), 16.0, kind="rope")
A.ledge(-286.6, -281.0, 830.2, "snow", t=0.8, skin="glaciar_window_sill")  # R6: the rope's ledge and the window's floor
A.challenge("9.6", "Tobogán Helado", (-311.6, 834.5), 4, "B",
            moves=[["fling", list(LIP), [-286.59, 822.9], "F3"], ["reach", [-286.59, 829.3], [-286.5, 830.2]]])
A.cam((-313.5, 816, -284.5, 836), half_h=13.0, bias=(5.0, -6.0))

# ================================================================ 9.7 Ventisca
# Out of the window (floor y 830.2) and up the tongue's face to R7 under the chute's
# mouth. Ice all the way (2 s a hold), one rock nub. The wind takes it from the west for
# 2.2 s (it peels you off the face), then from the east (it pins you), on a 6 s clock.
A.solid([(-280.9, 834.68), (-280.3, 834.6), (-280.6, 831.6)], "ice", skin="glaciar_tusk")  # the fang under the brow
H97 = [(-280.6, 832.0), (-280.6, 833.4), (-279.9, 835.1), (-281.2, 835.99), (-282.2, 836.67), (-282.25, 837.8),
       (-282.25, 839.3), (-282.25, 840.8), (-282.25, 842.3), (-282.25, 843.8), (-282.25, 845.2)]
for i, (x, y) in enumerate(H97[5:]):
    A.hold(x, y, r=0.24, kind=("rock" if i == 2 else "ice"), skin=("glaciar_stone" if i == 2 else "glaciar_nub"))
for x, y in H97[2:5]:  # three plates of ice lying on the brow's 34 degree top
    A.patch((x + 0.3, y - 0.205 - 0.08), (x - 0.3, y + 0.205 - 0.08), "ice", t=0.2, skin="glaciar_plate")
A.wind((-285, 834.6, -275, 845.8), (4.5, 0.4), gust={"on": 2.2, "off": 3.8, "phase": 0.0, "warn": 0.8})
A.wind((-285, 834.6, -275, 845.8), (-4.5, 0.0), gust={"on": 2.2, "off": 3.8, "phase": 3.0, "warn": 0.8})
A.challenge("9.7", "Ventisca", (-283.0, 830.2), 4, "X",
            moves=[["reach", list(H97[i]), list(H97[i + 1])] for i in range(len(H97) - 1)] +
                  [["reach", list(H97[-1]), [-282.5, 846.0]]])
A.cam((-286, 829, -274, 847), half_h=10.0, bias=(3.0, -4.0))

# ================================================================ 9.8 La Avalancha
# The chute: the rimaye's drain, 50 degrees, roofed by the tower's foot from its mouth
# (the nose L) to the stem (x -286.5). Snow slabs let go under the ridge every 5.5 s and
# sweep it to the mouth and out over the slide. Two rock islands stand in it: each has a
# glazed ramp on its uphill side and over its top (slabs and fallers ride up it and fly
# over; nothing catches there) and bare rock only on its lee face and under its little
# roof: the shelter. Then up a frozen rope, above the slabs, to R8.
CU = (-math.cos(math.radians(50)), math.sin(math.radians(50)))  # up the chute
CN = (math.sin(math.radians(50)), math.cos(math.radians(50)))   # off its floor


def P(s, n=0.0):
    return (NOSE[0] + CU[0] * s + CN[0] * n, NOSE[1] + CU[1] * s + CN[1] * n)


def island(s0):
    # (both solids wear one skin: the long stone and its glaze, one piece for each island)
    A.solid([P(s0 + 3.4, -0.1), P(s0, -0.1), P(s0, 0.55), P(s0 - 0.6, 0.68), P(s0 - 0.6, 0.9), P(s0, 0.9)], "rock",
            skin="glaciar_long_stone")
    A.solid([P(s0 + 3.7, 0.0), P(s0 + 3.7, 0.12), P(s0 + 0.02, 1.04), P(s0 - 0.78, 1.04), P(s0 - 0.78, 0.64),
             P(s0 - 0.6, 0.64), P(s0 - 0.6, 0.88), P(s0, 0.88)], ICE, skin="glaciar_long_stone")




def GZ(s0, s):
    """How far off the chute's floor the surface is at s: the floor (0.1 for a patch's
    middle), or island s0's glazed ramp."""
    if s0 is None or s >= s0 + 3.7:
        return 0.1
    return 0.14 + (s0 + 3.7 - s) * (0.92 / 3.68)


island(3.6)
island(8.4)
A.solid([(-282.35, 850.1), (-281.85, 850.12), (-282.1, 847.7)], "ice", skin="glaciar_tusk_short")  # the fang under the nose
H98 = [(-282.1, 848.0), (-282.1, 849.4), (-280.7, 849.85), (-279.6, 849.95), (-278.62, 850.42),
       P(1.3, 0.1), P(2.5, 0.1), P(3.55, 0.35),
       P(4.4, GZ(3.6, 4.4)), P(5.8, GZ(3.6, 5.8)), P(7.2, GZ(3.6, 7.2)), P(8.35, 0.35),
       P(9.2, GZ(8.4, 9.2)), P(10.6, GZ(8.4, 10.6)), P(12.0, GZ(8.4, 12.0)),
       (-286.62, 861.6)]
for i, (x, y) in enumerate(H98):
    if i in (0, 1, 7, 11) or i >= 5:
        continue  # the fang, the islands' lee faces, the flat patches (below), the rope
    A.hold(x, y, r=0.22, kind="ice", skin="glaciar_nub")
for s0, ss in ((None, (1.3, 2.5)), (3.6, (4.4, 5.8, 7.2)), (8.4, (9.2, 10.6, 12.0))):
    for sv in ss:
        A.patch(P(sv - 0.36, GZ(s0, sv - 0.36)), P(sv + 0.36, GZ(s0, sv + 0.36)), "ice", t=0.22, skin="glaciar_plate")
# The way out of the chute: a dead man's rope, frozen to a rock horn at the stem's corner,
# its frayed end 1.7 m over the chute's floor (slabs and bodies pass under it). It is also
# the glacier's ONE last chance: whatever comes down the rimaye passes beneath its end.
A.hold(-286.62, 867.0, r=0.2, kind="rock", skin="glaciar_stone")
A.rope("rope98", (-286.62, 866.9), 5.4, kind="rope")
A.spawner("slab", (-301.2, 880.4), period=5.5, vel=(1.2, -2.2), phase=0.0, r=0.5, life=9.0, warn=1.3, mass=30.0)
# THE KICKER (note 91, Parker 11-13: "They should get kicked out where I indicated"): a lip of
# ice on the chute's floor just above the rope's foot. Every slab that reaches it is thrown up
# and back into the cave behind the climb; none reaches the climb below. (Its look: the kicker's
# model, made to this board's 1.03 m; a plain ice stand-in until it lands.)
# NOTE 91: the thrown slab lands in THE HOLLOW behind the rope's foot (a9_dress: x -292.6 .. -287.6,
# y 864.2 .. 869.3, from the gap's card at z -2.4 back to -5.4; the card is cut round it below) and
# bursts there: it goes back to z -2.2, just in front of the card (at -4.0 it passed behind the card,
# unseen), and is gone in a burst of snow as it comes down to the hollow's floor.
A.board(P(15.2, 0.05), P(14.3, 0.55), throw=(0.6, 4.5, -3.6), depth=-2.2, gone=864.6, t=0.22,
        model="glaciar_kicker_chute", made=1.03, kind="ice", burst=["steam", "frost"])
A.challenge("9.8", "La Avalancha", (-284.0, 846.0), 4, "X",
            moves=[["reach", list(H98[i]), list(H98[i + 1])] for i in range(len(H98) - 1)] +
                  [["reach", [-286.62, 866.8], [-286.5, 867.8]]])
A.cam((-290, 845, -276, 870), half_h=10.0, bias=(2.0, -3.0))

# ================================================================ 9.9 Cornisa de Hielo
# The cornice's underside: 9.4 m of roof at y 871.8, from the niche R8 west to its lip,
# on holds 1.6 to 1.85 m apart that each last 2 s. Under it: 8 to 9 m of air, the
# chute, the mouth, the slide. Round the lip into the niche R9.
A.solid([(-287.15, ROOF_Y + 0.05), (-286.65, ROOF_Y + 0.05), (-286.9, 869.5)], "ice", skin="glaciar_tusk_short")  # the fang at R8's mouth
H99 = [(-286.9, 869.8), (-286.9, 870.6), (-288.5, 871.5), (-290.2, 871.5), (-291.9, 871.5), (-293.6, 871.5),
       (-295.2, 871.5), (-296.2, 872.6), (-295.8, 873.3)]
for x, y in H99[2:-1]:
    A.hold(x, y, r=0.25, kind="ice", skin="glaciar_nub")
A.challenge("9.9", "Cornisa de Hielo", (-285.2, 867.8), 5, "X",
            moves=[["reach", list(H99[i]), list(H99[i + 1])] for i in range(len(H99) - 1)])
A.cam((-297.5, 862, -283, 875), half_h=10.5, bias=(0.0, -5.5))

# ================================================================ 9.10 El Rimaye
# The gap between the ice and the ridge's rock: 6.3 m at the top. A climber is frozen on
# the tower's tip, leaning west at 45 degrees, reaching for the ledge he never got to.
# His pelvis is at (-296.32, 881.72); his boots are in the ice of the tip (-295.7, 881.0);
# his mitten, the launch, is at H = (-297.17, 882.57).
#   The 2.3 m circle round H: clear of everything except his own body and the last
#   0.15 m of the tip under his boots (2.15 m away, to the east-south-east: the back of
#   the swing). a10's knife edge points down at (-296.2, 885.2): 2.80 m from H. The
#   ledge's nose is 4.8 m west. So the swing is open below, to the west and above.
#   The fling: H to (-304.2, 886.0) on the ledge, 7.0 m across and 3.4 m up:
#   fling_speed = 5.6 m/s (F3). The ledge's nose (0.9 m) is a lump of verglas: land past it.
#   Miss: the rimaye, the chute (62, 32, 50 degrees), the mouth, the slide, the lip.
A.solid([(-296.0, 877.35), (-295.5, 877.35), (-295.75, 874.95)], "ice", skin="glaciar_tusk_short")  # the fang at R9's mouth
A.hold(-296.2, 878.6, r=0.23, kind="ice", skin="glaciar_nub")
A.hold(-296.2, 879.9, r=0.23, kind="ice", skin="glaciar_nub")
HAND = (-297.17, 882.57)
A.statue(-296.32, 881.72, "reach", rot=45.0)
bone(-295.74, 881.14)
bone(-296.32, 881.72)
bone(HAND[0], HAND[1], r=0.18)
# (The ice at his back is a9_dress's horn now, from z -1.25 back: note 87.)
H910 = [(-295.75, 875.35), (-295.75, 876.9), (-296.2, 878.6), (-296.2, 879.9), (-295.74, 881.14), (-296.32, 881.72), HAND]
A.challenge("9.10", "El Rimaye", (-294.4, 873.3), 4, "X",
            moves=[["reach", list(H910[i]), list(H910[i + 1])] for i in range(len(H910) - 1)] +
                  [["fling", list(HAND), [-304.2, 886.0], "F3"]])
A.cam((-299, 873, -292.5, 886), half_h=12.0, bias=(-4.0, -4.0))

# ================================================================ the picture
# (a9_dress places the glacier's look; a10_dress the gap's far wall, cut round the slab hollow and
# the slab mouth, and the ridge's first prayer pole at the cabin's west corner.)

# Light: cold lamps of sky coming through the ice inside, one about every 12 m of route.
for x, y in ((-286.0, 788.4), (-298.0, 788.6), (-309.5, 792.5), (-320.0, 796.5), (-327.0, 801.2), (-312.5, 806.5),
             (-300.0, 807.0), (-294.0, 814.0), (-315.0, 815.0), (-329.2, 820.0), (-329.2, 829.0), (-319.0, 836.0),
             (-308.5, 836.5), (-294.0, 829.0), (-286.0, 832.4)):
    A.light(x, y, color="#9FD8FF", rng=10.0, energy=1.3)
A.light(-328.3, 831.3, color="#FFE6B0", rng=4.0, energy=0.9)  # a warmer glint on the one below the lip
A.light(-291.0, 866.0, color="#BFE3FF", rng=10.0, energy=1.1)  # under the cornice
# The sheet's only warm light: a candle lantern at each door on the side you go through, the frog's,
# and the last climber's (on the last cane: it takes the place of the light on his reaching arm).
for x, y, z in a9_dress.LANTERN_LIGHTS:
    A.light(x, y, color="#FFB860", rng=3.5, energy=0.9, z=z, flicker=True)
A.dark((-331, 786, -284.5, 842), level=0.3)  # inside the ice: blue shadow

A.effect("snow", (-300, 830, -250, 888), density=0.5)
A.effect("mist", (-331, 786, -305.5, 792), density=0.5, tone="ice")
A.effect("mist", (-303, 804, -284.5, 809), density=0.4, tone="ice")
A.effect("drips", (-290, 786, -272, 791), density=0.5)
A.effect("snow", (-302, 862, -286, 884), density=0.9, speed=2.0)  # spindrift down the rimaye
# (No clouds: "never a sheet of ice, an icicle or a cloud in front of the climb"; the banks are given.)

a9_dress.dress(A)
A.drop_decos({"glaciar_window"})  # (the quality run's clean-up: an unlit white box in the game)

if __name__ == "__main__":
    A.save()
