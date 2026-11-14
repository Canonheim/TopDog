"""The summit's proposed geometry (note 148), drawn in the design pages' own style.

    python docs/peak/playtest/design/summit_148/make_summit_layout.py

DESIGN ONLY: a proposed course for biome 11, in the course's own metres, drawn with
build.py's sketch (so it reads like every other design page). Nothing in the game changes.
Writes summit_overview.png, summit_lower.png, summit_upper.png beside this file.
"""
import importlib.util, math, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location("build", os.path.join(HERE, "..", "build.py"))
B = importlib.util.module_from_spec(spec)
spec.loader.exec_module(B)

G = 2.79  # the Peak's gravity

S, M, R, Z, ST, CH, BG, FG, MOVES, NOTES = [], [], [], [], [], [], [], [], [], []


def solid(pts, kind):
    S.append({"pts": [list(p) for p in pts], "kind": kind})


def box(x0, y0, x1, y1, kind):
    solid([(x0, y0), (x1, y0), (x1, y1), (x0, y1)], kind)


def bg(pts, cls="bg-solid"):
    BG.append((pts, cls))


def bgbox(x0, y0, x1, y1, cls="bg-solid"):
    bg([(x0, y0), (x1, y0), (x1, y1), (x0, y1)], cls)


def reach(a, b):
    MOVES.append(("reach", a, b))


def fling(a, b):
    MOVES.append(("fling", a, b))


# ------------------------------------------------------------------ the summit's mass (slick: every miss slides east to the prow)
solid([(-332, 962), (-330.0, 968.6), (-340.0, 976.6), (-358.6, 989.6), (-372, 997.4), (-384, 1004.0), (-400, 1008.5),
       (-412, 1010.0), (-424, 1006), (-436, 990), (-440, 962)], "blackice")
# the storm ridge's last ledge (10.9's exit; today's tea floor): where the summit starts
box(-349.0, 962.0, -332.0, 965.0, "rock")

# ------------------------------------------------------------------ 1  La Puerta del Cielo: the broken gate stairs, east up a buttress
solid([(-332.0, 962.0), (-321.0, 962.0), (-321.0, 971.0), (-324.0, 971.0), (-332.0, 965.5)], "blackice")  # the buttress under the stair (slick)
STEPS = [(-331.0, 966.0), (-329.7, 967.0), None, (-327.1, 969.0), (-325.8, 970.0), None]
for s in STEPS:
    if s:
        box(s[0] - 0.55, s[1] - 0.45, s[0] + 0.55, s[1], "stone")
bgbox(-325.0, 972.0, -324.2, 978.4, "bg-pale"); bgbox(-322.0, 972.0, -321.2, 978.4, "bg-pale"); bgbox(-325.4, 977.6, -320.8, 978.6, "bg-pale")  # the gate
reach((-333.5, 965.0), (-331.0, 966.0)); reach((-331.0, 966.0), (-329.7, 967.0)); reach((-329.7, 967.0), (-327.1, 969.0))
reach((-327.1, 969.0), (-325.8, 970.0)); reach((-325.8, 970.0), (-323.4, 972.0))
CH.append(("1", "La Puerta del Cielo", (-334.0, 965.0)))

# ------------------------------------------------------------------ 2  La Casa de Té (the rest): the gate landing and the tea house
box(-324.0, 971.0, -302.5, 972.0, "stone")
solid([(-324.0, 971.0), (-302.5, 971.0), (-304.5, 962.0), (-321.0, 962.0)], "blackice")  # the landing's rock under it
bgbox(-320.5, 972.0, -309.5, 979.0, "bg-solid"); bg([(-321.3, 979.0), (-315.0, 982.0), (-308.7, 979.0)], "bg-pale")  # the tea house
bgbox(-318.5, 972.0, -315.5, 976.6, "bg-light")  # its lit door
CH.append(("2", "La Casa de Té (rest)", (-316.0, 972.0)))

# ------------------------------------------------------------------ 3  Los Molinos de Oración: four great prayer wheels up the cliff edge
WHEELS = [(-306.0, 975.9, -1), (-310.0, 979.6, 1), (-314.0, 983.3, -1), (-318.0, 987.0, 1)]
for k, (cx, cy, d) in enumerate(WHEELS):
    hs = []
    for i in range(4):
        a = math.radians(45 + 90 * i)
        hx, hy = math.cos(a) * 1.5, math.sin(a) * 1.5
        hs.append({"pts": [[hx - 0.18, hy - 0.18], [hx + 0.18, hy - 0.18], [hx + 0.18, hy + 0.18], [hx - 0.18, hy + 0.18]], "kind": "iron"})
    hs.append({"pts": [[-0.35, -0.35], [0.35, -0.35], [0.35, 0.35], [-0.35, 0.35]], "kind": "metal"})
    M.append({"at": [cx, cy], "motion": {"type": "spin"}, "shapes": hs})
    bg([(cx + 1.5 * math.cos(t / 12 * 2 * math.pi), cy + 1.5 * math.sin(t / 12 * 2 * math.pi)) for t in range(12)], "bg-mark")
box(-323.5, 988.2, -319.6, 989.0, "rock")  # the gallery's top ledge (E1)
reach((-305.0, 972.0), (-305.0, 974.8))
for (ax, ay, _), (bx, by, _) in zip(WHEELS, WHEELS[1:]):
    fling((ax - 1.06, ay + 1.06), (bx + 1.06, by - 1.06))
reach((-319.06, 988.06), (-320.0, 989.0))
CH.append(("3", "Los Molinos de Oración", (-305.0, 972.0)))

# ------------------------------------------------------------------ 4  El Claustro Colgante: the broken cloister's arches hanging on chains
bgbox(-352.0, 999.8, -324.5, 1000.6, "bg-pale")  # the cloister's roof beam, out over the drop (background)
for x in (-353.0, -345.0, -337.0, -329.0):
    bgbox(x - 0.4, 1000.6, x + 0.4, 1004.0, "bg-solid")  # what is left of its piers above
ARCH_X = [-327.5, -333.0, -338.5, -344.0]
for x in ARCH_X:
    R.append({"at": [x, 999.8], "len": 7.4})
    box(x - 0.8, 991.9, x + 0.8, 992.4, "stone")  # the hanging arch stone (the rope's bob)
box(-352.0, 991.5, -346.5, 992.5, "stone")  # T0, the first terrace
fling((-321.0, 989.0), (-327.5, 992.4))
for a, b in zip(ARCH_X, ARCH_X[1:]):
    fling((a, 992.4), (b, 992.4))
fling((-344.0, 992.4), (-347.0, 992.5))
CH.append(("4", "El Claustro Colgante", (-321.5, 989.0)))

# ------------------------------------------------------------------ 5  Las Terrazas: the monks' terraces, gusts and prayer-flag lines
TER = [(-352.0, -346.5, 992.5), (-358.0, -352.0, 994.5), (-364.0, -358.0, 996.5), (-370.0, -364.0, 998.5), (-376.0, -370.0, 1000.5)]
for x0, x1, y in TER[1:]:
    solid([(x0, y), (x1, y), (x1, y - 2.0), (x0 + 0.6, y - 2.6)], "stone")
for (a0, a1, ay), (b0, b1, by) in zip(TER, TER[1:]):
    R.append({"at": [a0 + 0.2, ay + 3.0], "to": [b0 + 0.6, by + 3.0], "len": 6.2})  # a prayer-flag line, post to post
    bgbox(a0 + 0.05, ay, a0 + 0.35, ay + 3.0, "bg-pale")  # its post
    reach((a0 + 0.6, ay), (b1 - 0.5, by))
Z.append({"type": "wind", "rect": [-377.0, 992.5, -346.0, 1004.0]})
for x0, x1, y in TER:
    bgbox(x0 + 0.8, y, x0 + 1.3, y + 0.9, "bg-pale")  # stone lanterns
bgbox(-378.0, 1000.5, -360.0, 1007.0, "bg-dark")  # the monastery's dormitory behind, roof fallen
CH.append(("5", "Las Terrazas", (-349.0, 992.5)))

# ------------------------------------------------------------------ 6  Las Piedras de los Monjes: the carved stair, and boulders rolling down it
STAIR = []
for i in range(17):
    x = -369.0 + 1.3 * i
    y = 1001.25 + 0.75 * i
    STAIR.append((x, y))
SHELTER = (6, 12)  # two dips with a kicker lip just uphill: a boulder flies over the dip
for i, (x, y) in enumerate(STAIR):
    yy = y - (1.2 if i in SHELTER else 0.0)
    box(x - 0.65, yy - 0.5, x + 0.65, yy, "stone")
    if i - 1 in SHELTER:
        solid([(x - 0.65, y), (x + 0.65, y), (x + 0.65, y + 0.35)], "stone")  # the kicker lip
solid([(-370.0, 1000.0), (-347.0, 1012.5), (-347.0, 1006.0), (-370.0, 998.0)], "blackice")  # the cliff under the stair
# the gully the boulders come out of: hidden above the stair's top, its mouth behind a rock nose
box(-348.2, 1016.5, -347.6, 1021.0, "rock"); box(-344.6, 1016.5, -344.0, 1021.0, "rock")  # (its walls start over head height: you pass under its mouth to the library door)
FG.append(([(-349.0, 1016.5), (-343.6, 1016.5), (-343.6, 1022.0), (-349.0, 1022.0)], "fg-solid"))  # the rock nose over the gully's mouth (out of reach)
SP = (-346.1, 1020.0)
ST.append({"at": list(SP)})
for (a, b) in zip(STAIR[::2], STAIR[2::2]):
    reach((a[0], a[1]), (b[0], b[1]))
CH.append(("6", "Las Piedras de los Monjes", (-372.5, 1000.5)))

# ------------------------------------------------------------------ 7  La Biblioteca: the roofless library tower, shelf beams up its inside
box(-345.0, 1015.8, -344.0, 1027.5, "stone")  # its west wall (the door under it, from the stair's top)
box(-336.0, 1011.0, -335.0, 1027.5, "stone")  # its east wall
box(-345.0, 1012.25, -336.0, 1013.25, "stone")  # its floor, level with the stair's top
SH = [(-339.5, -336.0, 1015.3), (-344.0, -340.5, 1017.3), (-339.5, -336.0, 1019.3), (-344.0, -340.5, 1021.3), (-339.5, -336.0, 1023.3),
      (-344.0, -340.5, 1025.3)]
for x0, x1, y in SH:
    box(x0, y - 0.3, x1, y, "wood")
for a, b in zip([(-345.5, 1013.25)] + [((s[0] if s[0] > -340 else s[1]), s[2]) for s in SH], [((s[0] if s[0] > -340 else s[1]), s[2]) for s in SH]):
    reach(a, b)
reach((-340.5, 1025.3), (-344.5, 1027.5))
bgbox(-344.0, 1013.25, -336.0, 1027.5, "bg-dark")
CH.append(("7", "La Biblioteca", (-346.0, 1013.25)))

# ------------------------------------------------------------------ 8  El Ring: the old championship ring in the high court
box(-372.0, 1027.0, -344.0, 1028.0, "stone")  # the high court's floor
box(-364.0, 1028.0, -354.0, 1029.6, "paint")  # the ring's apron (red)
box(-364.0, 1029.35, -354.0, 1029.6, "gill")  # its canvas
box(-354.0, 1028.0, -352.6, 1028.8, "stone")  # the ring steps
box(-364.2, 1029.6, -363.6, 1031.4, "wood"); box(-354.4, 1029.6, -353.8, 1031.4, "wood")  # the corner posts, turnbuckle pads up them
for k, yy in enumerate((1030.2, 1030.7, 1031.2)):
    bg([(-363.6, yy), (-354.4, yy - 0.15), (-354.4, yy - 0.05), (-363.6, yy + 0.1)], "bg-line")  # the near ropes (a picture of them)
Z.append({"type": "bounce", "a": [-363.5, 1029.8], "b": [-363.5, 1031.4]})  # the west side ropes: throw east and up
Z.append({"type": "bounce", "a": [-354.5, 1029.8], "b": [-354.5, 1031.4]})  # the east side ropes: throw west and up
for k in range(6):
    bgbox(-371.0 + k * 4.6, 1028.0, -368.6 + k * 4.6, 1029.0, "bg-pale")  # the ring of stone seats
L4 = (-367.6, 1031.4)
box(-368.3, 1028.0, -367.6, 1031.0, "stone")  # a broken arch stub at the court's west edge
solid([(L4[0] - 0.22, L4[1] - 0.22), (L4[0] + 0.22, L4[1] - 0.22), (L4[0] + 0.22, L4[1] + 0.22), (L4[0] - 0.22, L4[1] + 0.22)], "iron")  # THE iron ring
reach((-344.5, 1027.5), (-352.6, 1028.8)); reach((-352.6, 1028.8), (-354.8, 1029.6))
fling((-354.5, 1030.4), (-363.6, 1030.6)); fling((-363.5, 1030.6), (-354.6, 1030.9)); fling((-354.6, 1030.9), (-363.9, 1031.4))
fling((-363.9, 1031.4), L4)
CH.append(("8", "El Ring", (-352.0, 1028.0)))

# ------------------------------------------------------------------ the massive leap: from the iron ring, 20 m west across the gap to the bell rope
ROPE_X = -387.6
fling(L4, (ROPE_X, 1028.7))
NOTES.append(((-379.0, 1033.5), "EL ULTIMO SALTO: 20 m across, 2.7 m down"))

# ------------------------------------------------------------------ 9  El Campanario: the bell tower on its spur
solid([(-406.0, 1008.0), (-386.0, 1003.5), (-386.0, 1012.0), (-406.0, 1012.0)], "rock")  # the spur
box(-401.0, 1012.0, -400.0, 1040.0, "stone"); box(-392.0, 1012.0, -391.0, 1040.0, "stone")  # the tower's walls below the belfry
box(-401.0, 1048.0, -400.0, 1059.5, "stone"); box(-392.0, 1048.0, -391.0, 1059.5, "stone")  # above it
box(-401.0, 1047.0, -391.0, 1048.0, "wood")  # the belfry's floor
solid([(-391.0, 1047.3), (-386.6, 1047.3), (-386.6, 1047.7), (-391.0, 1047.7)], "wood")  # the beam out east to the bell
M.append({"at": [ROPE_X, 1047.2], "motion": {"type": "still"},
          "shapes": [{"pts": [[-0.55, -0.35], [0.55, -0.35], [1.1, -2.6], [-1.1, -2.6]], "kind": "iron"}]})  # the old summit bell (solid, swings)
R.append({"at": [ROPE_X, 1044.6], "len": 16.0})  # its rope, down over the gap
BEAMS = [(-395.5, -392.0, 1050.3), (-401.0 + 1.0, -396.5, 1052.6), (-395.5, -392.0, 1054.9), (-400.0, -396.5, 1057.2)]
for x0, x1, y in BEAMS:
    box(x0, y - 0.3, x1, y, "wood")
box(-400.9, 1059.5, -400.1, 1061.5, "wood"); box(-391.9, 1059.5, -391.1, 1061.5, "wood")  # the canopy's two posts on the wall tops
solid([(-402.2, 1061.5), (-396.0, 1064.2), (-389.8, 1061.5)], "rock")  # the open crown's little roof (you climb out over its edge)
box(-396.25, 1064.2, -395.75, 1065.2, "wood")  # the spire post the belt hangs on
reach((ROPE_X, 1029.0), (ROPE_X, 1044.6)); reach((ROPE_X, 1044.6), (-387.0, 1047.3)); reach((-387.0, 1047.3), (-391.5, 1048.0))
for a, b in zip([(-392.0, 1048.0)] + [((s[0] if s[0] > -396 else s[1]), s[2]) for s in BEAMS], [((s[0] if s[0] > -396 else s[1]), s[2]) for s in BEAMS]):
    reach(a, b)
reach((-396.5, 1057.2), (-392.0, 1059.5)); reach((-392.0, 1059.5), (-391.5, 1061.5)); reach((-391.5, 1061.5), (-389.9, 1061.6))
reach((-389.9, 1061.6), (-396.0, 1064.2))
CH.append(("9", "El Campanario", (ROPE_X, 1028.7)))
CH.append(("10", "Top Dog: the belt", (-396.0, 1065.2)))

# ------------------------------------------------------------------ after the belt: west, down to the frogs' hot spring, and its slide
Z.append({"type": "water", "rect": [-428.0, 1018.0, -412.0, 1021.0], "surface": 1021.0})
solid([(-430.0, 1016.0), (-410.0, 1016.0), (-410.0, 1021.5), (-412.0, 1021.5), (-412.0, 1018.0), (-428.0, 1018.0), (-428.0, 1021.5), (-430.0, 1021.5)], "rock")
bgbox(-427.0, 1021.0, -414.0, 1026.0, "bg-dark")  # the spring's cave
NOTES.append(((-431.0, 1028.0), "the frogs' hot spring (after the belt)"))
NOTES.append(((-438.0, 1012.0), "its slide, on to the great falls"))
MOVES.append(("ride", (-402.2, 1061.5), (-414.0, 1021.5)))

# ------------------------------------------------------------------ draw
COURSE = {"solids": S, "movers": M, "ropes": R, "zones": Z, "spawners": ST, "decos": [], "bodies": [], "statues": []}
PAL = B.META["palettes"].get("summit", {})


def arc(a, b, n=24):
    """A throw's path from a to b, as the Peak's low gravity draws it (a rough apex 1 m over the higher end for a short
    hop, more for a long one)."""
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
    # the painted backdrop's sea of cloud, below the summit
    sk.poly([(win[0], win[1]), (win[2], win[1]), (win[2], 961.5), (win[0], 961.5)], "bg-pale")
    for pts, cls in BG:
        if sk.hits([p[0] for p in pts], [p[1] for p in pts]):
            sk.poly(pts, cls)
    B.draw_course(sk, COURSE, PAL)
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


draw((-442, 958, -298, 1068), os.path.join(HERE, "summit_overview.png"), 1100.0, 1.4, grid=True, labels=True)
draw((-380, 960, -298, 1015), os.path.join(HERE, "summit_lower.png"), 1100.0, 1.6)
draw((-412, 1008, -330, 1066), os.path.join(HERE, "summit_upper.png"), 1100.0, 1.6)
