"""The summit's proposed geometry, v2 (note 148, Parker 11-19), drawn in the design pages' own style.

    python docs/peak/playtest/design/summit_148/make_summit_layout_v2.py

DESIGN ONLY: nothing in the game changes. Parker's 11-19 calls on v1:
  - the falls were not dangerous: every miss landed on the tea shelf. The tea house goes INSIDE the mountain, the
    shelf goes, and every miss slides off the slick east face, off the prow, into the weather balloon's ropes on the
    storm ridge, as today's dome does ("that was fine");
  - the boulder stair becomes a shaft like the mine's El Derrumbe, and it is a LIBRARY all the way through: books
    and scrolls fall, you go back and forth and tuck into the walls;
  - the frogs' hot spring goes inside the mountain;
  - the summit can be bigger, and things can be rearranged.
Writes summit_v2_overview.png, summit_v2_lower.png, summit_v2_upper.png beside this file.
"""
import importlib.util, math, os

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("build", os.path.join(HERE, "..", "build.py"))
B = importlib.util.module_from_spec(spec)
spec.loader.exec_module(B)

S, M, R, Z, ST, CH, BG, FG, MOVES, NOTES, FALLS = [], [], [], [], [], [], [], [], [], [], []
ROOMS, INS, INZ, IBG = [], [], [], []  # rooms cut in the rock (drawn over the mass), and what stands inside them


def solid(pts, kind):
    S.append({"pts": [list(p) for p in pts], "kind": kind})


def box(x0, y0, x1, y1, kind):
    solid([(x0, y0), (x1, y0), (x1, y1), (x0, y1)], kind)


def room(x0, y0, x1, y1):
    ROOMS.append([(x0, y0), (x1, y0), (x1, y1), (x0, y1)])


def roomp(pts):
    ROOMS.append(list(pts))


def isolid(pts, kind):
    INS.append({"pts": [list(p) for p in pts], "kind": kind})


def ibox(x0, y0, x1, y1, kind):
    isolid([(x0, y0), (x1, y0), (x1, y1), (x0, y1)], kind)


def ibg_box(x0, y0, x1, y1, cls="bg-solid"):
    IBG.append(([(x0, y0), (x1, y0), (x1, y1), (x0, y1)], cls))


def bg(pts, cls="bg-solid"):
    BG.append((pts, cls))


def bgbox(x0, y0, x1, y1, cls="bg-solid"):
    bg([(x0, y0), (x1, y0), (x1, y1), (x0, y1)], cls)


def reach(a, b):
    MOVES.append(("reach", a, b))


def fling(a, b):
    MOVES.append(("fling", a, b))


def ring(cx, cy, r, n=14):
    return [(cx + r * math.cos(t / n * 2 * math.pi), cy + r * math.sin(t / n * 2 * math.pi)) for t in range(n)]


# ================================================================ the mountain: one slick skin, every miss slides east off the prow
EAST = [(-330.0, 968.6), (-338.0, 974.5), (-346.0, 981.0), (-354.0, 988.5), (-361.0, 996.5), (-367.0, 1005.0),
        (-372.0, 1013.0), (-375.5, 1022.0), (-377.0, 1031.0)]


def face_x(y):
    """The east face's x at height y."""
    for (x0, y0), (x1, y1) in zip(EAST, EAST[1:]):
        if y0 <= y <= y1:
            return x0 + (x1 - x0) * (y - y0) / (y1 - y0)
    return EAST[-1][0]


MASS = [(-330.0, 958.0)] + EAST + [(-408.0, 1031.0), (-410.5, 1024.0), (-414.0, 1017.0), (-420.0, 1014.0), (-426.0, 1017.0),
        (-428.0, 1020.0), (-442.0, 1020.0), (-456.0, 1026.0), (-468.0, 1023.0), (-478.0, 1009.0), (-488.0, 986.0),
        (-496.0, 962.0), (-496.0, 958.0)]
solid(MASS, "blackice")
# A10's last ledge (the entry), under the prow
box(-340.0, 962.0, -332.0, 964.0, "rock")
# the weather balloon on the storm ridge below the prow, and its rope: where every miss lands (as today)
bg(ring(-318.5, 969.5, 3.2, 18), "bg-pale")
bgbox(-319.2, 962.6, -317.8, 964.0, "bg-solid")
R.append({"at": [-318.5, 962.6], "len": 9.0})
NOTES.append(((-336.0, 976.5), "the weather balloon (A10):"))
NOTES.append(((-336.0, 975.0), "every miss ends in its rope, as today"))

# ================================================================ 1  La Puerta del Cielo: the gate in the mountain's foot, behind A10's ledge
bgbox(-341.0, 964.0, -339.2, 971.5, "bg-pale"); bgbox(-341.0, 970.8, -335.0, 971.6, "bg-pale")  # the gate's jamb and lintel (cut in the rock)
CH.append(("1", "La Puerta del Cielo", (-336.0, 964.0)))

# ================================================================ 2  La Casa de Té (the rest): INSIDE, the monks' old kitchen behind the gate
room(-362.0, 964.0, -339.2, 971.0)  # the room, cut in the rock
ibox(-362.0, 963.0, -339.0, 964.0, "stone")  # its floor (level with A10's ledge)
ibg_box(-350.0, 964.0, -346.0, 968.0, "bg-light")  # the great stove's glow
ibg_box(-358.0, 964.0, -356.5, 967.5, "bg-solid")  # the tea frog's counter
reach((-336.0, 964.0), (-348.0, 964.0))
CH.append(("2", "La Casa de Té (rest, inside)", (-353.0, 964.0)))

# the monks' stair inside, from the kitchen up to a door high on the east face
STAIR = [(-360.0 + 1.25 * i, 964.6 + 1.05 * i) for i in range(13)]
roomp([(-361.5, 964.0), (-344.0, 978.4), (-344.0, 982.8), (-361.5, 968.6)])
for x, y in STAIR:
    ibox(x - 0.6, y - 0.35, x + 0.6, y, "stone")
for a, b in zip(STAIR[::2], STAIR[2::2]):
    reach(a, b)
DOOR = (-344.6, 980.4)
box(DOOR[0] - 0.6, DOOR[1] - 0.4, DOOR[0] + 1.6, DOOR[1], "stone")  # the doorstep, proud of the face (its root a layer back)
reach(STAIR[-1], DOOR)

# ================================================================ 3  El Claustro Colgante: the broken cloister's arches, hanging off the face over the drop
bg([(-343.0, 990.6), (-358.0, 1000.6), (-358.0, 1001.4), (-343.0, 991.4)], "bg-pale")  # its broken roof beam, slanting up along the face
ARCHES = [(-347.5, 984.6), (-351.5, 988.0), (-355.5, 991.4)]
for x, y in ARCHES:
    top = 990.6 + (x - -343.0) / (-15.0) * 10.0
    R.append({"at": [x, top], "len": top - y})
    box(x - 0.8, y - 0.5, x + 0.8, y, "stone")  # the hanging arch stone
fling((DOOR[0] - 0.4, DOOR[1]), ARCHES[0])
for a, b in zip(ARCHES, ARCHES[1:]):
    fling(a, b)
CH.append(("3", "El Claustro Colgante", (DOOR[0] + 1.0, DOOR[1])))

# ================================================================ 4  Los Molinos de Oración: prayer wheels on iron brackets out from the face
WHEELS = [(-358.5, 996.4), (-362.2, 1001.4), (-365.9, 1006.4)]
for (cx, cy) in WHEELS:
    hs = []
    for i in range(4):
        a = math.radians(45 + 90 * i)
        hx, hy = math.cos(a) * 1.5, math.sin(a) * 1.5
        hs.append({"pts": [[hx - 0.18, hy - 0.18], [hx + 0.18, hy - 0.18], [hx + 0.18, hy + 0.18], [hx - 0.18, hy + 0.18]], "kind": "iron"})
    hs.append({"pts": [[-0.35, -0.35], [0.35, -0.35], [0.35, 0.35], [-0.35, 0.35]], "kind": "metal"})
    M.append({"at": [cx, cy], "motion": {"type": "spin"}, "shapes": hs})
    bg(ring(cx, cy, 1.5, 12), "bg-mark")
    bg([(cx, cy - 0.1), (face_x(cy) - 0.2, cy - 0.1), (face_x(cy) - 0.2, cy + 0.1), (cx, cy + 0.1)], "bg-solid")  # its bracket back into the face
fling(ARCHES[-1], (WHEELS[0][0] + 1.06, WHEELS[0][1] - 1.06))
for a, b in zip(WHEELS, WHEELS[1:]):
    fling((a[0] - 1.06, a[1] + 1.06), (b[0] + 1.06, b[1] - 1.06))
CH.append(("4", "Los Molinos de Oración", (WHEELS[0][0] + 1.6, WHEELS[0][1] - 2.2)))

# ================================================================ 5  Las Terrazas: two narrow terrace lips with prayer-flag lines, up to the library's door
TER = [(-369.4, -367.6, 1009.6), (-372.6, -370.6, 1012.4)]
for x0, x1, y in TER:
    box(x0, y - 0.4, x1, y, "stone")  # a lip standing proud of the face (its root a layer back: a slide passes in front)
R.append({"at": [-367.6, 1013.0], "to": [-370.6, 1015.6], "len": 4.4})  # a prayer-flag line, post to post
Z.append({"type": "wind", "rect": [-375.0, 1004.0, -360.0, 1018.0]})
fling((WHEELS[-1][0] - 1.06, WHEELS[-1][1] + 1.06), (TER[0][1] - 0.4, TER[0][2]))
reach((TER[0][0] + 0.4, TER[0][2]), (TER[1][1] - 0.4, TER[1][2]))
LDOOR = (-374.0, 1013.0)
reach((TER[1][0] + 0.4, TER[1][2]), LDOOR)
CH.append(("5", "Las Terrazas", (TER[0][1], TER[0][2])))

# ================================================================ 6  La Biblioteca: the library, ALL THE WAY UP inside the mountain; books and scrolls fall
LIB = (-405.0, 1012.0, -376.0, 1031.0)
room(*LIB)
roomp([(LIB[2], 1012.0), (-372.6, 1012.0), (-372.6, 1015.0), (LIB[2], 1015.0)])  # its door through the east face
ibox(LIB[0], 1011.0, LIB[2], 1012.0, "stone")  # its floor (the door's sill on its east side)
# the shelf stacks: tall cases against the back wall (background), their tops and galleries the climb
for x in range(-404, -377, 3):
    ibg_box(x + 0.2, 1012.0, x + 2.6, 1030.6, "bg-solid")
# the galleries: shelf-top walks switching back and forth up the hall
GAL = [(-393.0, -377.0, 1015.5), (-404.0, -388.0, 1019.5), (-393.0, -377.0, 1023.5), (-404.0, -388.0, 1027.5)]
for x0, x1, y in GAL:
    ibox(x0, y - 0.35, x1, y, "wood")
# the reading niches: alcoves cut in the hall's walls at every gallery's end (tuck in: the falls pass you by)
NICHES = [(-376.0, 1015.5, 1), (-405.0, 1019.5, -1), (-376.0, 1023.5, 1), (-405.0, 1027.5, -1)]
for x, y, side in NICHES:
    nx = x + 0.0
    room(min(nx, nx + 1.6 * side), y, max(nx, nx + 1.6 * side), y + 2.4)
    ibg_box(min(nx, nx + 1.6 * side), y, max(nx, nx + 1.6 * side), y + 2.4, "bg-light")  # a lamp-lit niche
# the falls: books and scrolls tip off the top galleries' broken shelves in waves, down the open gaps between the galleries
for x in (-399.0, -390.0, -381.0):
    ST.append({"at": [x, 1030.4]})
    IBG.append(([(x - 0.15, 1013.0), (x + 0.15, 1013.0), (x + 0.15, 1030.0), (x - 0.15, 1030.0)], "bg-mark"))
NOTES.append(((-404.0, 1008.8), "books and scrolls fall in waves: cross the hall, tuck into the niches"))
# the climb: zig-zag up the galleries, ladders between them at the ends
reach(LDOOR, (-377.5, 1012.0))
reach((-377.5, 1012.0), (-378.0, 1015.5))
reach((-392.5, 1015.5), (-393.5, 1019.5))
reach((-388.5, 1019.5), (-387.5, 1023.5))
reach((-392.5, 1023.5), (-393.5, 1027.5))
reach((-403.5, 1027.5), (-404.0, 1031.0))  # the hatch up onto the high court
for x0, x1, y in GAL:
    reach((x1 - 0.5, y), (x0 + 0.5, y)) if x1 > -385 else reach((x0 + 0.5, y), (x1 - 0.5, y))
CH.append(("6", "La Biblioteca (books and scrolls fall)", (-379.0, 1012.0)))

# ================================================================ 7  El Ring: the old championship ring on the high court, the summit's top
box(-408.0, 1031.0, -377.0, 1032.0, "stone")  # the high court's floor (the library's roof)
box(-399.0, 1032.0, -389.0, 1033.6, "paint")  # the apron (red)
box(-399.0, 1033.35, -389.0, 1033.6, "gill")  # the canvas
box(-389.0, 1032.0, -387.6, 1032.8, "stone")  # the ring steps
box(-399.2, 1033.6, -398.6, 1035.4, "wood"); box(-389.4, 1033.6, -388.8, 1035.4, "wood")  # the corner posts
for yy in (1034.2, 1034.7, 1035.2):
    bg([(-398.6, yy), (-389.4, yy - 0.15), (-389.4, yy - 0.05), (-398.6, yy + 0.1)], "bg-line")
Z.append({"type": "bounce", "a": [-398.5, 1033.8], "b": [-398.5, 1035.4]})
Z.append({"type": "bounce", "a": [-389.5, 1033.8], "b": [-389.5, 1035.4]})
for k in range(6):
    bgbox(-407.0 + k * 5.0, 1032.0, -404.6 + k * 5.0, 1033.0, "bg-pale")  # the stone seats
L4 = (-411.6, 1035.4)
box(-412.3, 1031.0, -411.6, 1035.0, "stone")  # a broken arch stub at the court's west edge, out over the cleft
solid([(L4[0] - 0.22, L4[1] - 0.22), (L4[0] + 0.22, L4[1] - 0.22), (L4[0] + 0.22, L4[1] + 0.22), (L4[0] - 0.22, L4[1] + 0.22)], "iron")
reach((-404.0, 1031.0), (-387.6, 1032.8))
reach((-387.6, 1032.8), (-389.8, 1033.6))
fling((-389.5, 1034.4), (-398.6, 1034.6)); fling((-398.5, 1034.6), (-389.6, 1034.9)); fling((-389.6, 1034.9), (-398.9, 1035.4))
fling((-398.9, 1035.4), L4)
CH.append(("7", "El Ring", (-386.0, 1032.0)))

# ================================================================ the massive leap, 20 m west over the cleft to the bell rope
ROPE_X = -431.6
fling(L4, (ROPE_X, 1032.7))
NOTES.append(((-424.0, 1038.0), "EL ULTIMO SALTO: 20 m across, 2.7 m down"))
NOTES.append(((-430.0, 1004.5), "a miss from the leap: down the cleft, a slick chute out onto the east face"))
FALLS.append([(-420.0, 1016.0), (-405.0, 1009.0), (-378.0, 1004.0), (-366.0, 999.0)])  # the cleft's chute (inside), out onto the face

# ================================================================ 8  El Campanario: the bell tower on the west spur
box(-445.0, 1020.0, -444.0, 1044.0, "stone"); box(-436.0, 1020.0, -435.0, 1044.0, "stone")  # the tower's walls below the belfry
box(-445.0, 1052.0, -444.0, 1063.5, "stone"); box(-436.0, 1052.0, -435.0, 1063.5, "stone")
box(-445.0, 1051.0, -435.0, 1052.0, "wood")  # the belfry floor
solid([(-435.0, 1051.3), (-430.6, 1051.3), (-430.6, 1051.7), (-435.0, 1051.7)], "wood")  # the beam out to the bell
M.append({"at": [ROPE_X, 1051.2], "motion": {"type": "still"},
          "shapes": [{"pts": [[-0.55, -0.35], [0.55, -0.35], [1.1, -2.6], [-1.1, -2.6]], "kind": "iron"}]})  # the old summit bell
R.append({"at": [ROPE_X, 1048.6], "len": 16.0})
BEAMS = [(-439.5, -436.0, 1054.3), (-444.0, -440.5, 1056.6), (-439.5, -436.0, 1058.9), (-444.0, -440.5, 1061.2)]
for x0, x1, y in BEAMS:
    box(x0, y - 0.3, x1, y, "wood")
solid([(-446.2, 1065.5), (-440.0, 1068.2), (-433.8, 1065.5)], "rock")  # the crown's little roof
box(-440.25, 1068.2, -439.75, 1069.2, "wood")  # the spire post the belt hangs on
reach((ROPE_X, 1033.0), (ROPE_X, 1048.6)); reach((ROPE_X, 1048.6), (-431.0, 1051.3)); reach((-431.0, 1051.3), (-435.5, 1052.0))
for a, b in zip([(-436.0, 1052.0)] + [((s[0] if s[0] > -440 else s[1]), s[2]) for s in BEAMS], [((s[0] if s[0] > -440 else s[1]), s[2]) for s in BEAMS]):
    reach(a, b)
reach((-440.5, 1061.2), (-436.0, 1063.5)); reach((-436.0, 1063.5), (-433.9, 1065.6)); reach((-433.9, 1065.6), (-440.0, 1068.2))
CH.append(("8", "El Campanario", (ROPE_X, 1032.7)))
CH.append(("9", "Top Dog: the belt", (-440.0, 1069.2)))

# ================================================================ after the belt: the cable down into the mountain, to the frogs' hot spring INSIDE
room(-470.0, 1008.0, -452.0, 1018.5)  # the grotto, cut in the west shoulder
ibox(-470.0, 1007.0, -452.0, 1008.0, "rock")
INZ.append({"type": "water", "rect": [-466.0, 1008.0, -455.0, 1010.6], "surface": 1010.6})
ibg_box(-464.0, 1015.0, -462.5, 1018.5, "bg-light"); ibg_box(-458.0, 1016.0, -456.8, 1018.5, "bg-light")  # daylight down cracks in its roof
roomp([(-452.5, 1017.5), (-449.5, 1023.5), (-452.0, 1024.5), (-454.5, 1018.5)])  # its mouth on the shoulder, facing the tower
MOVES.append(("ride", (-446.2, 1065.5), (-451.0, 1022.0)))
NOTES.append(((-482.0, 1027.0), "the frogs' hot spring, inside (after the belt)"))
roomp([(-470.0, 1007.0), (-482.5, 999.0), (-483.0, 1001.2), (-470.0, 1009.2)])  # its slide out through the west face
NOTES.append(((-494.0, 997.0), "its slide, on to the great falls"))
MOVES.append(("ride", (-468.0, 1008.0), (-481.0, 1000.5)))

# ================================================================ every miss: down the slick east face, off the prow, into the balloon's rope
FALLS.append([(-352.0, 990.0), (-341.0, 978.0), (-331.0, 970.0), (-324.0, 966.0), (-319.5, 963.0)])
FALLS.append([(-370.0, 1012.0), (-361.0, 998.0), (-352.0, 988.0)])
FALLS.append([(-378.0, 1031.5), (-376.0, 1024.0), (-372.0, 1014.0)])

# ------------------------------------------------------------------ draw
COURSE = {"solids": S, "movers": M, "ropes": R, "zones": Z, "spawners": ST, "decos": [], "bodies": [], "statues": []}
PAL = B.META["palettes"].get("summit", {})


def arc(a, b, n=24):
    (x0, y0), (x1, y1) = a, b
    d = abs(x1 - x0)
    lift = max(0.6, min(4.5, d * 0.22))
    top = max(y0, y1) + lift
    pts = []
    for i in range(n + 1):
        t = i / n
        x = x0 + (x1 - x0) * t
        y = (1 - t) ** 2 * y0 + 2 * (1 - t) * t * (2 * top - (y0 + y1) / 2) + t ** 2 * y1
        pts.append((x, y))
    return pts


def draw(win, path, maxw, k, grid=True, labels=True):
    sk = B.Sketch(win, maxw=maxw)
    sk.poly([(win[0], win[1]), (win[2], win[1]), (win[2], 961.5), (win[0], 961.5)], "bg-pale")
    for pts, cls in BG:
        if sk.hits([p[0] for p in pts], [p[1] for p in pts]):
            sk.poly(pts, cls)
    B.draw_course(sk, COURSE, PAL)
    for pts in ROOMS:  # the rooms cut in the rock, over the mass
        sk.poly(pts, "bg-dark")
    for pts, cls in IBG:
        sk.poly(pts, cls)
    B.draw_course(sk, {"solids": INS, "movers": [], "ropes": [], "zones": INZ, "spawners": [], "decos": [], "bodies": [], "statues": []}, PAL)
    for pts, cls in FG:
        sk.poly(pts, cls)
    if grid:
        x = math.ceil(sk.x0)
        while x < sk.x1:
            if x % 5 == 0:
                sk.line(x, sk.y0, x, sk.y1, "grid")
                sk.text(x + 0.15, sk.y0 + 0.4, "x %d" % x)
            x += 1
        y = math.ceil(sk.y0)
        while y < sk.y1:
            if y % 5 == 0:
                sk.line(sk.x0, y, sk.x1, y, "grid")
                sk.text(sk.x0 + 0.15, y + 0.15, "y %d" % y)
            y += 1
    for kind, a, b in MOVES:
        if kind == "reach":
            sk.line(a[0], a[1], b[0], b[1], "path", "stroke:#ffffff;stroke-dasharray:2 3")
        elif kind == "fling":
            p = arc(a, b)
            for u, v in zip(p, p[1:]):
                sk.line(u[0], u[1], v[0], v[1], "rope" if abs(b[0] - a[0]) > 15 else "path")
        elif kind == "ride":
            sk.line(a[0], a[1], b[0], b[1], "path", "stroke:#7fd0ff;stroke-dasharray:6 4")
    for pts in FALLS:  # every miss, in red
        for u, v in zip(pts, pts[1:]):
            sk.line(u[0], u[1], v[0], v[1], "path", "stroke:#ff5a4a;stroke-width:2;stroke-dasharray:5 3")
    for (x, y), t in NOTES:
        if labels and sk.hits([x - 0.1, x + 0.1], [y - 0.1, y + 0.1]):
            sk.text(x, y, t)
    for n, name, (x, y) in CH:
        if sk.hits([x - 0.1, x + 0.1], [y - 0.1, y + 0.1]):
            sk.man(x, y)
            sk.tag(n, x, y + 2.6)
            if labels:
                sk.text(x + 0.8, y + 2.4, name)
    B.render_png(sk, path, k=k)
    print("wrote", path)


draw((-500, 956, -306, 1074), os.path.join(HERE, "summit_v2_overview.png"), 1300.0, 1.3, grid=True, labels=True)
draw((-382, 958, -306, 1020), os.path.join(HERE, "summit_v2_lower.png"), 1100.0, 1.6)
draw((-500, 1004, -372, 1072), os.path.join(HERE, "summit_v2_upper.png"), 1100.0, 1.5)
