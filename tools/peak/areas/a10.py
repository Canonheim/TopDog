"""
A10 LA CRESTA DE LA TORMENTA: the storm ridge, 884 to 966 m. Outside. Every miss costs X.
  python tools/peak/areas/a10.py

THE SHAPE. The ridge is one slick slate face from (-307, 884) to (-334, 962), 71 degrees,
rock to the west. Nothing on it grips below the headwall, so whatever touches it slides
to the bottom. The bottom is roofed by EL ALERO, a slick 40-degree prow over a9's entry
ledge: its brink (-300, 892) throws every slider east of the ledge, out of the region at
about (-300, 884), onto a9's glacier slide. The lowest wind band blows east only.

THE GENDARMES stand in the air east of the face, their feet in the cloud (front cards).
In this cross-section a tower rooted in the flank would make a pocket on its uphill side,
so every tower's solid ends in a slick point above the slide, at least 3.5 m clear of the
face: a body passes under and behind every one of them. Their tops are grip or a spire.

THE ROUTE (x):  ledge -306 > El Filo -296 > prayer lines west > the station -310 > the
mast > the vane -303 > slung east > La Torre -289 > kites > the needle's top -286 >
three flings west (10, 12, 14 m) > the buttress -326.7 > the cloud > the balloon -321.5 >
the headwall > the exit ledge (-340..-332, 964).
"""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from peaklib import Area, box_pts, ngon, ccw, fling_speed

A = Area("a10", "storm")


def F(y):
    """The ridge face's x at height y (the straight line between the two fixed points)."""
    return -307.0 - 27.0 * (y - 884.0) / 78.0


def gust(phase, on=2.0, off=3.5, warn=0.8):
    return {"on": on, "off": off, "phase": phase, "warn": warn}


def tower(x0, x1, y_foot, y_body, y_top, kind="wet"):
    """A gendarme: a slick shaft x0..x1 from y_body to y_top on a pointed foot at y_foot."""
    xm = (x0 + x1) / 2
    return A.solid([(xm, y_foot), (x1, y_body), (x1, y_top), (x0, y_top), (x0, y_body)], kind)


def cloud(x0, x1, y, h=3.0, z=3.0, tone="#59616E"):
    """A cloud card across a tower's foot (in front of the climb)."""
    A.card([(x0, y - h * 0.5), (x0 + 1.2, y - h), (x1 - 1.0, y - h), (x1, y - h * 0.4), (x1 - 0.8, y + h * 0.3),
            ((x0 + x1) / 2, y + h * 0.5), (x0 + 0.9, y + h * 0.25)], z=z, tone=tone, edge=False)


# ================================================================ the ridge and the fall line
# The face: one slick slab, bottom to top. Rock on the left (west), 8 m of it.
A.wall([(F(884), 884), (F(962), 962)], default="wet", thick=8.0, rock_on="left")
# El Alero: the prow over the entry ledge. Cap 40 degrees, slick; brink at (-300, 892).
A.solid([(-300.0, 892.0), (-314.4, 904.1), (-318.0, 904.1), (-318.0, 894.6), (-311.6, 894.6), (-300.0, 891.7)], "wet")
# The exit ledge (a11 starts on it). It sits on the face's top and overhangs it 2 m.
A.solid([(-340, 962), (-332, 962), (-332, 964), (-340, 964)], "rock")

# The wind: bands over the whole ridge, gusts alternating sides, each with a warning.
# W1 blows EAST only: it carries whatever leaves the Alero's brink away from a9's ledge.
WX0, WX1 = -346.0, -283.0
A.wind((WX0, 884, WX1, 893), (4.0, 0.0), gust(0.0))  # W1 east: El Filo's foot
A.wind((WX0, 893, WX1, 898), (-4.0, 0.0), gust(1.4))  # W2 west: El Filo's middle
A.wind((WX0, 898, WX1, 904), (4.0, 0.0), gust(2.8))  # W3 east: El Filo's top and its rest
A.wind((WX0, 904, WX1, 914), (-3.5, 0.0), gust(0.7))  # W4 west: the prayer lines
A.wind((WX0, 914, WX1, 926), (3.0, 0.0), gust(2.1))  # W5 east: the mast
A.wind((WX0, 926, WX1, 934), (-3.5, 0.0), gust(3.5))  # W6 west: the vane (a headwind on the sling)
A.wind((WX0, 934, WX1, 943.2), (3.0, 0.0), gust(1.0))  # W7 east: the kites
A.wind((-305.0, 943.2, WX1, 953), (-3.0, 0.0), gust(2.5))  # W8a west: flings 1 and 2 get a tailwind
A.wind((WX0, 943.2, -305.0, 953), (3.0, 0.0), gust(4.6))  # W8b east: fling 3 flies into it; the cloud
A.wind((WX0, 953, WX1, 968), (4.0, 0.0), gust(0.3, on=1.8, off=3.0))  # W9 east: the headwall (peels you off it)

# ================================================================ 10.1 El Filo (D3, X)
# Out from under the Alero on a torn prayer line, an F2 to the blade's foot, then up the
# blade: 13 m tall, 1 m thick, holds on alternate sides. The gust comes from the west
# low down, the east in the middle, the west again at the top.
A.rope("filo_line", (-301.85, 892.15), 4.3, kind="banner")  # hangs under the Alero's tip to y 887.85, a hand past the ledge's end
A.solid([(-296.2, 885.2), (-295.7, 888.6), (-295.7, 902.0), (-296.7, 902.0), (-296.7, 888.6)], "wet")  # the blade
# The landing: 2.5 m of grip on its west face. It sits ABOVE the line a slider leaves the
# brink on (y 889.2 here), so the fall line never meets it. The flight from the line
# passes 1.5 m under the Alero's tip: throw at 45 degrees or flatter (5.1 m/s at 45).
A.patch((-296.72, 889.6), (-296.72, 892.1), "rock", t=0.36)
FILO = [(-296.85, 892.0)]
for i, y in enumerate((893.2, 894.4, 895.6, 896.8, 898.0, 899.2, 900.4)):
    x = -295.55 if i % 2 == 0 else -296.85  # east, west, east ...
    A.hold(x, y, r=0.24)
    FILO.append((x, y))
A.solid([(-297.6, 902.0), (-294.8, 902.0), (-294.8, 902.6), (-297.6, 902.6)], "rock")  # its top: the rest, 2.8 m
A.box(-294.95, 902.75, 0.3, 0.3, "wet")  # a wet lip on the rest's east edge (law 4)
FILO.append((-296.9, 901.55))
A.hold(-296.9, 901.55, r=0.24)
A.challenge("10.1", "El Filo", (-304.0, 886.0), 3, "X", moves=(
    [["fling", [-301.85, 888.8], [-296.72, 890.9], "F2"]]
    + [["reach", list(FILO[i]), list(FILO[i + 1])] for i in range(len(FILO) - 1)]
    + [["reach", [-296.9, 901.55], [-297.6, 902.6]]]))
A.cam((-312, 884, -290, 896), half_h=6.5, bias=(2.0, -1.0))
A.cam((-300, 896, -290, 904), half_h=5.5)

# ================================================================ 10.2 Banderas (D4, X)
# Three slack prayer lines in a zigzag between El Filo's pole and the spire La Aguja.
# Line 1 west and up; reach 1.6 to line 2 at the spire; line 2 back east and up; reach
# 1.7 to line 3 at the pole; line 3 west over the spire to the weather station, 12.3 m.
# W4 gusts west at 3.5 m/s2: with you on line 1 and 3, against you on line 2.
A.box(-296.2, 906.45, 0.24, 7.7, "grease")  # El Filo's flag pole: slick, 902.6 to 910.3
tower(-306.3, -304.7, 900.8, 902.6, 905.2)  # La Aguja: its point is 4.2 m over the Alero's cap
A.solid([(-304.7, 905.2), (-305.3, 907.3), (-306.3, 905.2)], "wet")  # its spire
L1 = ((-296.2, 904.3), (-304.7, 905.2))
L2 = ((-305.13, 906.8), (-296.2, 908.4))
L3 = ((-296.2, 910.0), (-307.9, 913.6))
for i, (p, q) in enumerate((L1, L2, L3)):
    A.rope("banda%d" % (i + 1), p, math.dist(p, q), kind="banner", to=q, slack=1.09 if i < 2 else 1.05)
A.challenge("10.2", "Banderas", (-296.6, 902.6), 4, "X", moves=[
    ["reach", [-304.4, 905.15], [-304.9, 906.75]],  # line 1 to line 2, at the spire
    ["reach", [-296.5, 908.35], [-296.5, 910.05]],  # line 2 to line 3, at the pole
])
A.cam((-309, 904, -292, 914), half_h=7.0, bias=(0.0, -1.5))

# ================================================================ 10.3 El Rayo (D4, X)
# The weather station's ruin: a deck on a gendarme, and the antenna mast, 12 m.
# The mast is metal (tag "rod"): spine and rungs. Lightning takes it every 6 s: 1.5 s
# of hum, then 0.4 s of strike. Between strikes there are 5.6 s (4.1 quiet + 1.5 hum).
# The insulators are WOOD: the deck, three crossarms 4 m apart, and a 1.9 m wooden
# sleeve on the spine above each (so a climber standing on wood touches only wood).
# One section = stand on wood, rung at +2.0, rung at +3.1, crossarm at +4.0, mantle:
# four pulls, about 4 s for a fluent climber. Leave as the strike ends and there are
# 1.6 s to spare; leave when the hum starts and you are on the rungs when it lands.
tower(-311.5, -308.0, 906.0, 909.5, 913.0)  # the station's gendarme
A.ledge(-311.8, -307.7, 913.5, "plank", t=0.5)  # the deck: the rest (4.1 m), in W4/W5's lanes
A.box(-307.85, 913.62, 0.3, 0.24, "wet")  # a wet board at its east lip, where line 3 lands (law 4)
MX = -310.0
P = [913.5, 917.5, 921.5, 925.5]  # the wood: deck, east crossarm, west crossarm, the nest
A.ledge(MX + 0.15, MX + 1.8, P[1], "wood", t=0.3)  # crossarm 1, east
A.ledge(MX - 1.8, MX - 0.15, P[2], "wood", t=0.3)  # crossarm 2, west
A.ledge(MX - 1.3, MX + 1.3, P[3], "wood", t=0.3)  # the nest, both sides
RAYO = []
for i in range(3):
    A.box(MX, P[i] + 0.95, 0.6, 1.9, "wood")  # the sleeve
    A.box(MX, (P[i] + 1.9 + P[i + 1] - 0.3) / 2, 0.3, P[i + 1] - 0.3 - P[i] - 1.9, "metal", tag="rod")  # bare spine
    for dy in (2.0, 3.1):
        A.box(MX, P[i] + dy, 1.6, 0.16, "metal", tag="rod")  # a rung
    side = (1 if i % 2 == 0 else -1) if i < 2 else 1  # which end of the rungs leads to the next crossarm
    arm_end = [MX + side * (1.8 if i < 2 else 1.3), P[i + 1]]
    RAYO += [["reach", [MX + side * 0.8, P[i] + 2.0], [MX + side * 0.8, P[i] + 3.1]],
             ["reach", [MX + side * 0.8, P[i] + 3.1], arm_end]]
A.box(MX, P[3] + 0.95, 0.6, 1.9, "wood")  # the nest's sleeve
A.box(MX, P[3] + 3.0, 0.2, 2.2, "metal", tag="rod")  # the tip the bolt takes, 927.4 to 929.6
A.strike("rod", period=6.0, warn=1.5, on=0.4, at=(-312.0, 960.0))
A.challenge("10.3", "El Rayo", (-308.9, 913.5), 4, "X", moves=RAYO)
A.cam((-314, 914, -306, 925.4), half_h=6.0, bias=(1.0, 0.0))

# ================================================================ 10.4 Veleta (D4, X)
# The anemometer: three slick arms, a painted cup on each at r = 5.0 m, 12 rpm clockwise.
# Tip speed = 2 x pi x 5.0 x 12 / 60 = 6.28 m/s. A cup passes the nest's east end going
# UP every 1.67 s. Take it, ride an eighth of a turn (0.63 s), let go at 45 degrees:
#   the hand leaves (-306.3, 930.5) at 6.28 m/s: level range v2/g = 14.1 m; it meets
#   La Torre's west face (x -291, 15.3 m out) at y 929.2.
#   the body rides about 1 m outside the cup (7.5 m/s from (-307.0, 931.2)): it comes
#   in at y 934.5, over the shoulder, into the needle's slick base, and drops on the rest.
# So the catch is the face band 928.6 to 932.5 and the 3.5 m shoulder above it. Let go a
# fifth of a second late (14 degrees flatter) and you pass under the band. W6 is a
# headwind: 2 s of it takes 7 m off the flight, so go in the lull.
HUB = (-302.8, 927.0)
vane = A.wheel("veleta", HUB, 4.7, -12.0, spokes=3, kind="grease", spoke_t=0.3, hub=0.6, phase=0.0, model="anemometer")
for k in range(3):
    a = k * 120.0
    c, s = math.cos(math.radians(a)), math.sin(math.radians(a))
    vane["shapes"].append({"pts": [[round(v, 3) for v in p] for p in ccw(box_pts(c * 5.0, s * 5.0, 0.8, 0.7, a))], "kind": "paint"})
# La Torre del Este: a block with a shoulder (the rest) and a needle on its east half.
A.solid([(-288.0, 920.5), (-285.0, 924.5), (-285.0, 932.5), (-291.0, 932.5), (-291.0, 924.5)], "wet")
A.patch((-291.02, 928.6), (-291.02, 932.5), "rock", t=0.36)  # the catch band on its west face, 3.9 m
A.ledge(-291.0, -287.5, 932.5, "rock", t=0.4)  # the shoulder: the rest (3.5 m), in W6's lane
A.box(-290.85, 932.62, 0.3, 0.24, "wet")  # its west lip is wet (law 4)
A.solid([(-287.5, 932.5), (-285.0, 932.5), (-285.0, 943.5), (-287.5, 943.5)], "wet")  # the needle, 11 m
A.challenge("10.4", "Veleta", (-309.25, 925.5), 4, "X")
A.cam((-312, 925.4, -284, 934), half_h=10.0, bias=(4.0, -2.0))

# ================================================================ 10.5 El Papalote (D5, X)
# Three kites beside the needle, each flying a figure-eight at 3 m/s (one lap 13 m,
# 4.4 s), each trailing a 6 m tail of papel picado. Kite 1's tail sweeps the shoulder.
# Kite 2 flies the same eight the other way, 2.6 m higher: the tails cross twice a lap
# (every 2.2 s, at the eight's middle, closing at 6 m/s).
# Kite 3 is higher again, and its east turn brings its tail within 1.4 m of the needle's
# west face, where a 3 m band of grip and two holds lead to the needle's top.
def eight(cx, cy, a, b, rev=False, n=16):
    pts = [(cx + a * math.sin(t), cy + b * math.sin(2 * t)) for t in (i * math.tau / n for i in range(n))]
    return [pts[0]] + pts[:0:-1] if rev else pts


kite_shape = [(ngon(0, 0, 0.6, 4, sy=1.2), "paint")]
for kid, cx, cy, a, rev in (("papalote1", -291.9, 936.6, 2.5, False), ("papalote2", -291.9, 939.2, 2.5, True),
                            ("papalote3", -291.7, 941.8, 2.8, False)):
    pts = eight(cx, cy, a, 0.9, rev)
    A.mover(kid, pts[0], kite_shape, {"type": "path", "pts": [list(p) for p in pts], "speed": 3.0, "mode": "loop"}, model="kite")
    A.rope(kid + "_cola", (pts[0][0], pts[0][1] - 0.72), 6.0, kind="banner", anchor=kid)
A.patch((-287.52, 937.5), (-287.52, 940.5), "rock", t=0.36)  # the needle's catch band
A.hold(-287.65, 941.6, r=0.24)
A.hold(-287.65, 942.7, r=0.24)
A.ledge(-287.5, -285.0, 943.5, "rock", t=0.4)  # the needle's top: the rest (2.5 m), in W8a's lane
A.challenge("10.5", "El Papalote", (-289.5, 932.5), 5, "X", moves=[
    ["reach", [-287.52, 940.5], [-287.65, 941.6]], ["reach", [-287.65, 941.6], [-287.65, 942.7]],
    ["reach", [-287.65, 942.7], [-287.5, 943.5]]])
A.cam((-299, 934, -284, 943.4), half_h=9.0, bias=(-2.0, 1.0))

# ================================================================ 10.6 Gendarmes (D5, X)
# Three towers west of the needle, gaps 10, 12 and 14 m (face to face), each with a
# 2.5 m flag post on its west corner: the post's top is the launch hold (clear circle
# 2.3 m). Still-air release speeds (peaklib.fling_speed, post top to landing):
#   1. needle (-287.35, 946.0) > tower B's top (-298.3, 944.0): 10.95 m across, 2 down: 5.05 m/s, F3
#   2. B's post (-298.95, 946.5) > tower C's top (-311.9, 944.5): 12.95 across, 2 down: 5.57 m/s, F3
#   3. C's post (-312.55, 947.0) > the buttress band (-326.72, 945.15): 14.17 across, 1.85 down: 5.89 m/s
# The crosswind (3 m/s2, 2 s on, 3.5 s off; a flight lasts about 3 s):
#   1. W8a blows west, WITH you: a full gust carries you 6 m long, clean over B. Go in the lull.
#   2. W8a for the first 6 m (with you), then W8b from x -305 (against you): the tail gust
#      helps the launch, the head gust stops you short of C. The two are out of step by 2.1 s:
#      leave as the western gust ends.
#   3. W8b all the way, AGAINST you: a full gust takes 6 m off and you meet the face under
#      the band. In the lull it is an F3 at 5.9 m/s; started late it needs 7 or more: F4.
# Landings: B = its 1.6 m top and 2 m of its east face. C = its top and 1.5 m of face.
# The buttress = a 1.5 m band on a wall over a 1 m foothold, nothing else.
A.box(-287.35, 944.75, 0.3, 2.5, "wood")  # the needle's post
tower(-299.1, -297.5, 938.3, 940.0, 943.6)  # tower B (its foot clears the vane's sling by 2 m)
A.ledge(-299.1, -297.5, 944.0, "rock", t=0.4)
A.patch((-297.48, 942.0), (-297.48, 944.0), "rock", t=0.36)
A.box(-298.95, 945.25, 0.3, 2.5, "wood")  # B's post
tower(-312.7, -311.1, 936.5, 938.5, 944.1)  # tower C
A.ledge(-312.7, -311.1, 944.5, "rock", t=0.4)
A.patch((-311.08, 943.0), (-311.08, 944.5), "rock", t=0.36)
A.box(-312.55, 945.75, 0.3, 2.5, "wood")  # C's post
# El Contrafuerte: the buttress, the last gendarme, leaning on the ridge. Slick cap at
# 37 degrees to its brink (-326.7, 952.5); the headwall's rest ledge is its top step.
A.solid([(-326.7, 941.5), (-326.7, 952.5), (-328.9, 954.16), (-328.9, 955.0), (-334.5, 955.0), (-334.5, 941.5)], "wet")
A.patch((-326.72, 944.4), (-326.72, 945.9), "rock", t=0.36)  # the landing band, 1.5 m
A.ledge(-326.7, -325.7, 944.4, "rock", t=0.4)  # and a foothold under it: the only perch before the cloud
A.challenge("10.6", "Gendarmes", (-286.2, 943.5), 5, "X", moves=[
    ["fling", [-287.35, 946.0], [-298.3, 944.0], "F3"],
    ["fling", [-298.95, 946.5], [-311.9, 944.5], "F3"],
    ["fling", [-312.55, 947.0], [-326.72, 945.15], "F4"]])
A.cam((-318, 943.4, -284, 950), half_h=12.0, bias=(-4.0, -3.0))
A.cam((-328, 943.4, -318, 946.4), half_h=12.0, bias=(2.0, -3.0))

# ================================================================ 10.7 La Nube (D4, X)
# Through the cloud (it is BEHIND the climb now: the blind version, dark 0.9 with a flash
# every 4 s, "feels like a bug", Parker 11-12). Five stones stand on a rib of dark rock (a
# back card): from the band, each one 1.0 east and 1.0 up of the last. The fourth is NOT there: it sits 0.3 back west and 1.6 up. Then the rule
# resumes, and the last stone is a reach from the balloon's ladder.
NUBE = [(-326.72, 945.9), (-325.6, 947.0), (-324.6, 948.0), (-323.6, 949.0), (-323.9, 950.6), (-322.9, 951.6)]
for x, y in NUBE[1:]:
    A.hold(x, y, r=0.28)
A.challenge("10.7", "La Nube", (-326.2, 944.4), 4, "X",
            moves=[["reach", list(NUBE[i]), list(NUBE[i + 1])] for i in range(len(NUBE) - 1)]
            + [["reach", [-322.9, 951.6], [-321.8, 951.0]]])
A.cam((-330, 946.4, -318, 953.2), half_h=6.0, bias=(2.0, 1.0))

# ================================================================ 10.8 El Globo (D4, X)
# The weather balloon on its tether, bobbing 2 m (961 to 963) at 0.5 m/s. Its ladder is
# two 12 m ropes, 0.6 m apart: their feet swing between y 949 and 951. Up it, out of the
# cloud, then pump a swing and let go west: 8.6 m across and 2 down to the headwall's
# rest (4.4 m/s, F2). Long is safe (the face drops you on the ledge). Short is the cap.
# Its envelope is solid and slick (it's a balloon): whatever falls on it from the summit
# slides off its side, clear of the ropes under it. Without it a missed last jump was
# caught by these ropes every time (tests/peak_drop).
A.mover("globo", (-321.5, 961.0), [(box_pts(0, 0.3, 1.6, 0.6), "wood"), (ngon(0, 3.9, 2.1, 10, sy=1.15), "wet")],
        {"type": "path", "pts": [[-321.5, 961.0], [-321.5, 963.0]], "speed": 0.5, "mode": "pingpong", "wait": 0.6}, model="weather_balloon")
A.rope("globo_a", (-321.8, 961.0), 12.0, kind="rope", anchor="globo")
A.rope("globo_b", (-321.2, 961.0), 12.0, kind="rope", anchor="globo")
A.challenge("10.8", "El Globo", (-322.9, 951.9), 4, "X", moves=[["fling", [-321.8, 957.5], [-330.4, 955.5], "F2"]])
A.cam((-328.4, 953.2, -316, 962), half_h=8.0, bias=(-3.0, -1.0))

# ================================================================ 10.9 Escalera al Cielo (D4, X)
# The headwall: what is left of the iron ladder. Rung, ROTTEN rung (1.2 s), a gap of 1.7
# where two are gone, rung, ROTTEN rung, then out round the exit ledge's east end.
# W9 gusts east at 4 m/s2: off the wall.
A.ledge(-332.4, -328.9, 955.5, "rock", t=0.5)  # the rest (2.85 m of it clear of the face), in W9's lane
A.box(-329.05, 955.62, 0.3, 0.24, "wet")  # its lip
CIELO = []
for y, kind in ((957.0, "iron"), (958.2, "rotten"), (959.9, "iron"), (961.1, "rotten")):
    A.beam((F(y) - 0.1, y), (F(y) + 0.8, y), t=0.16, kind=kind)
    CIELO.append([round(F(y) + 0.55, 2), y])
A.challenge("10.9", "Escalera al Cielo", (-330.8, 955.5), 4, "X", moves=(
    [["reach", CIELO[i], CIELO[i + 1]] for i in range(3)]
    + [["reach", CIELO[3], [-332.0, 962.4]], ["reach", [-332.0, 962.4], [-332.0, 964.0]]]))
A.cam((-340, 955.4, -326, 966), half_h=6.0, bias=(1.0, -1.0))

# ================================================================ the west side, closed
# The mountain's mass behind the face, so nothing gets round the ridge. Its top (y 962,
# under a11's own wall) is grip, level with the exit ledge's foot: never a slick flat.
A.solid([(-314.0, 880.0), (-362.0, 880.0), (-362.0, 961.6), (-339.9, 961.6)], "wet")
A.solid([(-333.9, 962.0), (-362.0, 962.0), (-362.0, 961.6), (-339.9, 961.6), (-341.6, 959.4)], "rock2")

# ================================================================ the picture
# Sky: storm grey, darker low, with the cloud thinning to warm light at the very top.
A.card([(-362, 878), (-279, 878), (-279, 930), (-362, 930)], z=-30.0, tone="back3", edge=False)
A.card([(-362, 930), (-279, 930), (-279, 956), (-362, 956)], z=-30.0, tone="back2", edge=False)
A.card([(-362, 956), (-279, 956), (-279, 970), (-362, 970)], z=-30.0, tone="#C9A46A", edge=False)  # the warm break
A.card([(-362, 951), (-345, 955), (-325, 952.5), (-304, 956.5), (-279, 953), (-279, 961), (-300, 963), (-322, 960), (-345, 963.5), (-362, 960)],
       z=-24.0, tone="#E9C27E", edge=False)  # gold under-lit cloud, far off
# Thunderheads behind, three layers.
A.card([(-362, 884), (-340, 889), (-322, 886), (-300, 893), (-279, 888), (-279, 912), (-296, 918), (-318, 913), (-338, 919), (-362, 914)],
       z=-20.0, tone="back2", edge=False)
A.card([(-362, 912), (-336, 922), (-310, 917), (-290, 925), (-279, 921), (-279, 940), (-300, 946), (-326, 941), (-362, 947)],
       z=-14.0, tone="back", edge=False)
A.card([(-300, 884), (-279, 884), (-279, 902), (-286, 906), (-294, 901)], z=-10.0, tone="back3", edge=False)
# The ridge's own cards: the far crest behind the face, and the gendarmes' roots drawn
# behind the slide (the solid towers end in a point; the card carries them down to rock).
A.card([(F(884) + 2, 880), (-362, 880), (-362, 966), (F(962) - 3, 966), (F(962) + 1.5, 962)], z=-4.0, tone="back3")
for x0, x1, yt, yb in ((-296.9, -295.5, 889.0, 880.0), (-306.5, -304.5, 903.0, 893.0), (-311.8, -307.7, 910.0, 898.0),
                       (-291.4, -284.6, 925.0, 906.0), (-299.4, -297.2, 940.5, 926.0), (-313.0, -310.8, 939.0, 924.0)):
    A.card([(x0, yt), (x1, yt), (x1 + 1.6, yb), (x0 - 2.4, yb)], z=-2.5, tone="back3")
# Cloud across every tower's foot, in front.
cloud(-301.0, -291.0, 886.5, h=3.6)
cloud(-309.5, -301.5, 900.4, h=3.0)
cloud(-315.0, -304.5, 906.2, h=3.4)
cloud(-295.0, -281.0, 921.0, h=4.4)
cloud(-303.0, -293.5, 938.2, h=3.0)
cloud(-317.0, -307.0, 936.6, h=3.2)
# La Nube: the cloud itself, and the rib its stones stand on (a shadow you see in the flash).
A.card([(-327.0, 944.6), (-324.8, 946.0), (-322.0, 950.6), (-321.6, 952.6), (-324.4, 951.6), (-326.8, 948.0)], z=-1.2, tone="back3")
A.card([(-330, 946.0), (-325, 944.8), (-318.5, 946.4), (-316.5, 950.0), (-318.5, 953.4), (-325, 954.0), (-330, 952.4)], z=-2.0, tone="#2B303A", edge=False)
A.card([(-329, 951.6), (-323, 950.8), (-317.5, 952.0), (-318.5, 954.0), (-325, 954.6), (-329.5, 953.6)], z=-1.6, tone="#59616E", edge=False)  # (behind the climb: it hid the last two stones)

# The prayer lines: papel picado, the town's colours at their loudest.
for i, (p, q) in enumerate((L1, L2, L3)):
    A.deco("papel_line", (p[0] + q[0]) / 2, (p[1] + q[1]) / 2 - 0.9, z=-0.4, size=(abs(p[0] - q[0]), 0.9, 0.05),
           rot=math.degrees(math.atan2(q[1] - p[1], q[0] - p[0])) % 180.0, tone="accent")
A.deco("papel_tatters", -301.85, 890.4, z=-0.5, size=(1.2, 2.6, 0.05), tone="accent")  # the torn one under the Alero
A.deco("papel_line", -293.0, 946.6, z=-1.4, rot=-10.0, size=(10.5, 0.9, 0.05), tone="accent")  # post to post, behind the flights
A.deco("papel_line", -305.6, 947.0, z=-1.4, rot=-2.0, size=(12.8, 0.9, 0.05), tone="accent")
A.deco("papel_line", -319.6, 949.5, z=-1.4, rot=-21.0, size=(15.0, 0.9, 0.05), tone="accent")  # up to the buttress's brink
A.deco("papel_line", -336.0, 965.4, z=-1.0, size=(8.0, 1.0, 0.05), tone="accent")  # whole and bright at the exit
for x, y in ((-296.2, 910.3), (-287.35, 946.0), (-298.95, 946.5), (-312.55, 947.0)):
    A.deco("prayer_flag", x - 0.5, y + 0.1, z=-0.3, size=(1.0, 0.7, 0.05), tone="accent")
# The weather station.
A.deco("station_hut_ruin", -310.4, 913.5, z=-1.4, size=(3.6, 2.6, 2.0), tone="wood")
A.deco("rain_gauge", -308.4, 913.5, z=-0.9, size=(0.4, 0.9, 0.4), tone="iron")
A.deco("insulator", -310.0, 917.6, z=0.4, size=(0.7, 0.5, 0.7), tone="bone")
A.deco("insulator", -310.0, 921.6, z=0.4, size=(0.7, 0.5, 0.7), tone="bone")
A.deco("insulator", -310.0, 925.6, z=0.4, size=(0.7, 0.5, 0.7), tone="bone")
A.deco("vane_mast", -303.0, 913.5, z=-1.3, size=(0.5, 13.5, 0.5), tone="iron")  # the vane's own pole, behind
# (the balloon mover's own model, weather_balloon, carries the envelope)
A.deco("balloon_tether", -321.5, 949.0, z=-1.0, size=(0.08, 24.0, 0.08), tone="wood")
A.deco("rung_stub", F(959.05) + 0.2, 959.05, z=0.0, size=(0.35, 0.12, 0.3), tone="iron")
A.deco("sign_pug_arrow", -331.6, 955.5, z=-1.0, size=(0.8, 1.8, 0.1), tone="wood")
A.statue(-311.25, 914.05, pose="sit", flip=True)  # one of them, in the lee of the hut, facing the mast
# Light: cold on the rests, white on the mast, warm at the top.
for x, y in ((-304.5, 889.5), (-296.2, 904.6), (-309.0, 915.6), (-289.3, 934.6), (-286.2, 945.6), (-298.3, 946.2),
             (-311.9, 946.6), (-330.4, 957.6)):
    A.light(x, y, color="#C9D8F0", rng=9.0, energy=1.3)
A.light(-310.0, 930.0, color="#FFFFFF", rng=14.0, energy=2.2, flicker=True)
A.light(-323.5, 949.5, color="#DDE8FF", rng=7.0, energy=0.5)
A.light(-335.0, 966.5, color="#FFC878", rng=14.0, energy=2.4)
A.effect("rain", (-346, 884, -283, 952), density=0.8, tone="drip")
A.effect("clouds", (-346, 940, -283, 956), density=0.7)
A.effect("mist", (-330, 944, -316, 954), density=1.0)

if __name__ == "__main__":
    A.save()
