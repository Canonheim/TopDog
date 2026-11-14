# The summit's areas, one dict each. Format: see ../build.py.
# Every area is drawn from the sheet in a11_biome.py. Numbers are the course's own (tools/peak/areas/a11.py).
import math


# ------------------------------------------------------------------ shorthand for shapes
def _r(x0, y0, x1, y1, st=None):
    return ["rect", x0, y0, x1, y1] + ([{"style": st}] if st else [])


def _ln(x0, y0, x1, y1, st=None):
    return ["line", x0, y0, x1, y1] + ([{"style": st}] if st else [])


def _c(x, y, r, st=None):
    return ["circle", x, y, r] + ([{"style": st}] if st else [])


def _p(pts, st=None):
    return ["poly", [[round(q[0], 2), round(q[1], 2)] for q in pts]] + ([{"style": st}] if st else [])


def _t(x, y, words):
    return ["text", x, y, words]


def _band(a, b, w, st=None):
    """A straight band w metres thick from a to b."""
    dx, dy = b[0] - a[0], b[1] - a[1]
    n = math.hypot(dx, dy)
    ox, oy = -dy / n * w / 2, dx / n * w / 2
    return _p([(a[0] + ox, a[1] + oy), (b[0] + ox, b[1] + oy), (b[0] - ox, b[1] - oy), (a[0] - ox, a[1] - oy)], st)


def _swag(a, b, sag, st=None, n=8):
    """A hanging line from a to b that dips sag metres in the middle."""
    pts = [(round(a[0] + (b[0] - a[0]) * k / n, 2), round(a[1] + (b[1] - a[1]) * k / n - 4 * sag * (k / n) * (1 - k / n), 2)) for k in range(n + 1)]
    return [_ln(pts[k][0], pts[k][1], pts[k + 1][0], pts[k + 1][1], st) for k in range(n)]


def _outline(x0, y0, x1, y1, pad=0.12, st="line"):
    return _r(round(x0 - pad, 2), round(y0 - pad, 2), round(x1 + pad, 2), round(y1 + pad, 2), st)


# ------------------------------------------------------------------ the course's numbers, used by every area
_JEWELS = [(-325.6, 970.4), (-332.6, 976.6), (-339.6, 981.8), (-328.6, 979.8), (-321.6, 981.8)]   # the five gold bosses
_COLLARS = [(jx - 0.8, jy - 2.3, jx + 0.8, jy - 1.8) for jx, jy in _JEWELS[:4]]                       # the rime collars
_NOSE = (-331.5, 965.175, -330.7, 965.625)
_BLOCK = (-322.1, 979.2, -321.1, 980.0)
_RING0 = (-329.8, 965.9)        # the ring under the prow's lip
_RING4 = (-335.7, 998.2)        # the ring west of the corner post, after note 99 (996.3 today)
_ROPES_W = [((-329.86, 987.8), (-327.34, 984.2)), ((-329.86, 991.4), (-327.34, 987.8)), ((-329.86, 995.0), (-327.34, 991.4))]
_ROPES_E = [((-323.46, 985.7), (-320.94, 989.3)), ((-323.46, 989.3), (-320.94, 992.9)), ((-323.46, 992.9), (-320.94, 996.5))]
_HORN_W = [(-327.503, 984.085), (-330.024, 987.685), (-327.503, 987.685), (-330.024, 991.285), (-327.503, 991.285), (-330.024, 994.885), (-330.024, 994.7), (-332.2, 994.7), (-332.2, 984.685), (-331.6, 984.085)]   # its outer foot loses a corner
_HORN_E = [(-318.6, 985.585), (-318.6, 997.9), (-319.0, 998.5), (-320.2, 998.5), (-320.6, 999.9), (-320.776, 996.385), (-323.297, 992.785), (-320.776, 992.785), (-323.297, 989.185), (-320.776, 989.185), (-323.297, 985.585)]   # outer face moved 1.6 m east

# where the paper is tied, in the design
_HORN_STAFF = (-332.0, 1001.5)   # top of the staff behind the west post's timber head: the rope 3.3 m above the pad, the lowest flag 2.5 m
_BELL_STAFF = (-360.3, 1011.2)   # top of the staff behind the bell frame's post: the lowest flag 2.5 m over the beam's east end
_WEST_STAFF = (-382.0, 1002.65)  # top of a staff on the peak's back above the west shoulder, off the west edge
_EAST_POST = (-319.4, 1001.5)    # top of the east post's timber head, where it stands in the design


def _dome_y(x):
    return 968.6 + 0.8 * (-330.0 - x) if x >= -340.0 else 976.6 + 0.7 * (-340.0 - x)


def _tooth(i, ylo, st="pale"):
    """A tooth's needle as the course's card has it, cut off at the window's foot."""
    jx, jy = _JEWELS[i]
    w = 1.7 if i == 4 else 1.25
    base = _dome_y(jx) - 1.0 if jx < -330.0 else 958.0
    top = jy - 0.15
    if base < ylo:
        w = w + (0.4 - w) * (ylo - base) / (top - base)
        base = ylo
    return _p([(jx - w, base), (jx + w, base), (jx + 0.4, top), (jx - 0.4, top)], st)


def _fifth_tooth(ylo, st="pale"):
    """The fifth tooth: the course's needle, swelling under the shelf into a head whose top is a step."""
    if ylo <= 975.5:
        foot = [(-323.3 + (ylo - 958.0) / 23.65 * 1.3, ylo), (-319.9 - (ylo - 958.0) / 23.65 * 1.3, ylo), (-320.86, 975.5)]
        back = [(-322.34, 975.5)]
    else:
        f = (ylo - 975.5) / 2.5
        foot = [(-322.34 - 1.26 * f, ylo), (-320.86 + 1.46 * f, ylo)]
        back = []
    return _p(foot + [(-319.4, 978.0), (-319.4, 979.2), (-320.9, 979.2), (-321.2, 981.65), (-322.0, 981.65), (-322.4, 979.2), (-323.6, 979.2), (-323.6, 978.0)] + back, st)


_SPUR = [_p([(-329.5, 963.6), (-330.3, 965.0), (-330.05, 965.75), (-329.55, 965.75), (-329.4, 965.2)], "pale"), _ln(-329.8, 965.75, -329.8, 966.1, "line")]
_FALLEN_POST = [_r(-321.0, 979.2, -318.8, 979.6, "pale"), _r(-319.05, 979.2, -318.8, 979.6, "solid"), _c(-319.2, 979.77, 0.16, "light")]


def _splinter(ylo):
    """The splinter that carries the second ring: it splits off the west pillar's flank at 976.5 m and leans west to 998.05 m."""
    if ylo <= 976.5:
        foot = [(-333.08, 976.5), (-332.72, 982.5)]
    else:
        foot = [(-333.08 - (ylo - 976.5) / 21.55 * 2.87, ylo), (-332.72 - (ylo - 982.5) / 15.55 * 2.73, ylo)]
    return [_p(foot + [(-335.45, 998.05), (-335.95, 998.05)], "pale"), _ln(-335.7, 998.05, -335.7, 998.45, "line")]
_BELL = [_p([(-356.8, 1002.2), (-354.6, 1002.2), (-354.75, 1002.7), (-355.15, 1004.3), (-355.3, 1004.8), (-356.1, 1004.8), (-356.25, 1004.3), (-356.65, 1002.7)], "pale"),
         _c(-355.7, 1002.3, 0.17, "solid")]
_STRUT = [_ln(-360.3, 1004.0, -362.4, 1000.8, "line")]
_RIB = [_p([(-359.6, 988.0), (-357.6, 988.0), (-356.7, 998.2), (-356.7, 998.7), (-359.6, 998.7)], "pale")]


def _leap_line(st="mark"):
    return _swag(_HORN_STAFF, _BELL_STAFF, 0.4, st, 12)


def _west_line(st="mark"):
    return _swag(_BELL_STAFF, _WEST_STAFF, 0.4, st, 8)


def _horn_line(st="mark"):
    return _swag(_HORN_STAFF, _EAST_POST, 0.3, st, 6)


def _rope(a, b):
    return [_band(a, b, 0.3, "pale"), _c(a[0], a[1], 0.25, "solid"), _c(b[0], b[1], 0.25, "solid")]


# ------------------------------------------------------------------ 11.1 Sobre las Nubes: the tea shop under the prow
SOBRE_LAS_NUBES = {
    "id": "11.1", "slug": "11_1_sobre_las_nubes", "title": "Sobre las Nubes: the tea shop under the prow", "kind": "challenge", "also": ["a10"],
    "window": [-353.0, 957.0, -323.5, 973.5], "screen": [-336.0, 966.4], "cut_y": 965.3, "climber": [-342.0, 964.22],
    "place": ("The ledge where the storm ridge ends and the summit begins: 17 m of rock at 964 m, roofed by the prow of the summit's dome, 4 to "
              "5 m overhead, and open to the east with the cloud at your feet. It is the last flat place on the mountain and the first one "
              "above the weather, so it is where anybody who gets this far stops. A frog saw that, and keeps a tea shop here. The shop is a "
              "recess in the ledge's back wall, 6 m wide, with a counter, a small stove, and the same pot, cups and kettle as the tea cave "
              "on the wind cliffs. The frog hangs the town's paper fresh across its mouth for an awning. A warm spout runs in the shop's "
              "wall, and nobody asks where the water comes from. The ledge is still not quite safe: the whole dome pours off the lip over your head. And at its west end is the black mouth of "
              "the tunnel, with a cold draught coming out of it. It is the far end of the way home from the frogs' spring, and one day "
              "you come out of it yourself."),
    "keep": [
        "The floor: 17 m, with the slab's gentle rise to the west. The prow's underside and its lip.",
        "The tunnel's mouth at the west end, and the 1 m drop from it onto the floor. It is the teahouse chute, the way home from the frogs' spring.",
        "The storm ridge's way up: its last rungs, and the east end of the ledge that you pull up onto.",
        "The nose and the iron ring off the east end, which start La Corona.",
        "Nothing in the shop can be touched. All of it stands 1.3 m or more behind you.",
    ],
    "background": [
        {"name": "The ledge's back wall", "z": [-3.8, -1.3], "tag": [-345.2, 967.5],
         "text": "The summit's own rock, closing the back of the alcove 1.3 m behind you, from the floor to the prow's underside. Today the "
                 "nearest thing behind the ledge is the peak's back, 3 m away, with one pool of lamp light on it. The wall is tan, a step "
                 "duller than the floor: one painted piece, its bedding long wavy lines of three tans, with no blocks. One little outcrop "
                 "by the tunnel carries a cushion of pink-flowered moss. The prow's black ice comes down onto its top in a glazed edge.",
         "draw": [_p([(-349.0, 965.0), (-340.0, 964.0), (-331.9, 964.0), (-331.3, 968.22), (-341.0, 968.4), (-349.0, 970.4)])]},
        {"name": "The tea shop's room", "z": [-3.8, -1.3], "style": "dark", "tag": [-332.7, 965.2], "top": True,
         "text": "Cut into the back wall under the paper: 6 m wide, 2.6 m tall and 2.5 m deep, with its front open, so you look straight in. "
                 "A plank floor, plank walls, and warm amber on every surface from the lantern and the stove, to its back, so it is a lit room and never a dark slot. A shelf of tea tins runs "
                 "along its back wall. It is the one warm room above the storm, and it is the first thing you see as your head comes over "
                 "the ledge's end.",
         "draw": [_r(-339.5, 964.0, -333.5, 966.6),
                  _r(-337.9, 965.92, -335.9, 966.0, "pale")] + [_r(x, 966.0, round(x + 0.2, 2), 966.24, "pale") for x in (-337.7, -337.3, -336.9, -336.5, -336.1)]},
        {"name": "The counter, the frog and two stools", "z": [-2.4, -1.35], "style": "pale", "tag": [-336.4, 963.3],
         "text": "A plank counter 2.4 m long under a striped cloth, set 0.5 m inside the room, with a row of cups along it and one cup set "
                 "out at its east end, for you. The frog stands behind it on an upturned crate, in an apron, so that its head and hands "
                 "show over the top. Now and then it pours a cup. Two stools stand at the counter's ends, just inside the recess. Nothing "
                 "here is within reach: the nearest stool is 1.35 m behind you.",
         "draw": [_r(-337.6, 964.0, -335.2, 964.9)] + [_ln(x, 964.0, x, 964.9, "line") for x in (-337.2, -336.8, -336.4, -336.0, -335.6)] +
                 [_r(x, 964.9, round(x + 0.12, 2), 965.03) for x in (-337.45, -337.15, -336.85, -335.55)] +
                 [_c(-336.4, 965.1, 0.16), _r(-338.2, 964.0, -337.8, 964.5), _r(-335.0, 964.0, -334.6, 964.5)]},
        {"name": "The stove, the kettle and the tin pipe", "z": [-3.4, -1.4], "style": "pale", "tag": [-334.1, 963.3],
         "text": "A small iron stove in the east corner, with the cliffs' kettle on it, steaming. Its tin pipe goes up through the recess's "
                 "roof and comes out of the wall as a cowl, 3.4 m above the floor. The smoke runs east along the prow's underside and out "
                 "past the lip. From the storm ridge's last rungs you see that thread of smoke before you see the ledge.",
         "draw": [_r(-334.4, 964.0, -333.8, 964.75, "solid"), _c(-334.1, 964.9, 0.15), _r(-334.18, 965.05, -334.02, 967.4), _ln(-334.4, 967.4, -333.8, 967.4, "line")]},
        {"name": "The warm spout", "z": [-3.8, -3.0], "style": "pale", "tag": [-338.95, 963.3],
         "text": "In the west corner: a stone spout in the wall, running a thread of warm water into a stone basin, with steam on it. This is "
                 "the frogs' spring. Its water has come down through the mountain from their pool, 33 m to the west and 6 m higher. It is a "
                 "hint for a player who looks. The frog fills the kettle here.",
         "draw": [_r(-339.35, 964.0, -338.55, 964.45), _ln(-339.5, 965.2, -339.05, 965.2, "line"), _ln(-339.05, 965.2, -339.0, 964.45, "mark")]},
        {"name": "The lantern and the sign", "z": [-1.6, -1.3], "style": "light", "tag": [-337.75, 967.05],
         "text": "A lit lantern on an iron hook under the lintel, in place of the cold lantern that stands on the floor today. Over the "
                 "lintel hangs a board with a painted cup and a curl of steam. It has no words.",
         "draw": [_c(-338.55, 966.25, 0.17), _r(-337.0, 966.8, -336.2, 967.4, "pale")]},
        {"name": "The awning", "z": [-2.1, -2.0], "style": "mark", "tag": [-341.2, 967.75],
         "text": "The town's paper, whole and bright, on thick old ring rope: 9 m long, tied to two iron eyes in the back wall, 2 m behind "
                 "you, with its lowest flag 3 m above the floor. It hangs across the mouth of the shop like an awning. It is the line "
                 "that is there today, moved 1 m further back and 0.9 m down, so that its flags hang clear of the prow. Today the prow "
                 "cuts them in half. The second line, which hangs at the height of your head today, is taken down.",
         "draw": _swag((-340.5, 968.0), (-331.5, 968.0), 0.2)},
        {"name": "The teahouse chute's east end", "z": [-3.0, -1.4], "style": "dark", "tag": [-351.2, 970.0],
         "text": "At the west end the floor ends against a black opening 4.4 m tall: the foot of the tunnel under the dome, the teahouse "
                 "chute. Its back wall is dark blue-violet ice, 2 m behind, in long painted bands, going up out of sight. It is the way "
                 "home from the frogs' spring: you come out of it 1 m above the floor and slide out onto the slab. Beside its mouth, on the "
                 "back wall 1.4 m behind you, the frog has hung a painted board: a frog in a pool under a curl of steam. When somebody "
                 "breaks the frost wall far up the tunnel, pieces of frost come sliding out of the mouth and melt on the floor.",
         "draw": [_p([(-349.0, 966.0), (-349.0, 970.4), (-353.0, 973.19), (-353.0, 968.78)]), _r(-348.4, 967.6, -347.7, 968.3, "pale")]},
        {"name": "East of the ledge", "z": [-3.4, -1.4], "tag": [-325.6, 962.3],
         "text": "The peak's own back carries on east behind the open air, tan and dull. In front of it stand the first and fourth teeth of "
                 "the crown, each a needle of rock one layer back. The fourth tooth has a spur on its west flank, level with your head, and "
                 "the iron ring hangs from the spur's tip. They are designed on La Corona's page.",
         "draw": [_p([(-331.9, 957.0), (-323.5, 957.0), (-323.5, 972.4), (-324.0, 973.0), (-324.86, 973.5), (-331.9, 973.5)]),
                  _p([(-326.9, 957.0), (-324.3, 957.0), (-325.2, 970.25), (-326.0, 970.25)], "pale"),
                  _p([(-329.9, 957.0), (-327.3, 957.0), (-327.96, 973.5), (-329.24, 973.5)], "pale")] + _SPUR},
    ],
    "play": [
        {"name": "The floor: one rock", "z": [-1.2, 1.2], "style": "mark", "tag": [-344.6, 963.2],
         "text": "All 17 m of the floor is the summit's rock: warm cream, rounded and dry. Today its east 8 m is drawn in the storm "
                 "ridge's grey slate, in square blocks, and butts against the cream slab at x -340. It becomes one floor. The slate "
                 "ends below it, in a line at 962 m along the ledge's underside, as the storm ridge's last page has it. In front of the "
                 "tunnel's mouth lies a woven mat 2 m long, where the tunnel puts you out: the tea frog's doormat, painted flush on the "
                 "floor so it can't be held or tripped on.",
         "draw": [_ln(-340.0, 962.06, -332.0, 962.06), _r(-348.9, 964.9, -346.9, 965.05, "line")]},
        {"name": "The prow overhead", "z": [-1.2, 1.2], "style": "mark", "tag": [-336.0, 968.95],
         "text": "Black ice in flat planes with a hard white glint, as the sheet has it. It gets no icicles: on the glacier an icicle is a "
                 "hold. The lantern's amber lies on its facets over the shop, and a little snow smokes off the lip.",
         "draw": [_ln(-349.0, 970.28, -341.0, 968.28), _ln(-341.0, 968.28, -330.2, 968.08)]},
        {"name": "The way on", "z": [-1.2, 1.2], "style": "line", "tag": [-330.6, 966.95],
         "text": "Off the ledge's east end: the rime nose and the iron ring. Today they are a carved stone block and a ring in the air. They "
                 "are designed on La Corona's page.",
         "draw": [_outline(*_NOSE), _c(_RING0[0], _RING0[1], 0.4)]},
    ],
    "foreground": [
        {"name": "The dome's snow cap (there today)", "z": [2.0, 2.05], "tag": [-342.5, 971.9],
         "text": "The white cap on the dome's back, 2 m in front of you. Its foot is set 1.5 m up from the prow's underside, so the ice shows "
                 "below it as a dark rim. It stands in front of solid ice everywhere, and it stays.",
         "draw": [_p([(-333.5, 969.9), (-337.75, 973.5), (-350.94, 973.5), (-349.0, 972.0), (-341.0, 969.9)])]},
    ],
    "explains": [
        ["The floor", "The doorstep of the highest tea shop on the mountain: the summit's own cream rock, standing on the storm ridge's last slate", "The back wall, and the shop cut into it"],
        ["The prow overhead", "The lip of the summit's dome. It is the shop's roof, and it is the line that everything falls down", "The back wall it comes down onto, and the stove's smoke running out under it"],
        ["The tunnel's mouth and the drop from it", "The east end of the teahouse chute: the way home from the frogs' spring", "The tunnel's dark back wall, the frog's sign beside it and the mat in front of it"],
        ["The east end, the nose and the ring", "The foot of the crown", "The fourth tooth and its spur, on La Corona's page"],
    ],
    "pieces": [
        ["Back wall for the alcove: summit rock, one painted piece with wavy bedding lines", "17 m long, 4 to 5 m tall", "1", "Background", "new, this area only; its rock is the kit's summit rock, duller"],
        ["Summit plant on a little outcrop", "0.4 m", "1", "Background", "kit: the summit's plants"],
        ["The frog's sign: a frog in a pool; woven mat", "0.7 m square; 2 m by 1 m", "1 and 1", "Background; play space (drawn on)", "kit: the frog's sign for the spring; the mat is new, this area only"],
        ["Tea shop: room with plank lining, counter with a striped cloth, crate, two stools, shelf of tins, stove with tin pipe and cowl, sign board, stone spout and basin", "room 6 m by 2.6 m, 2.5 m deep; counter 2.4 m", "1", "Background, cut away at the front", "kit: the tea shop"],
        ["Kettle, pot and cups", "small", "1 kettle, 1 pot, 7 cups", "Background", "kit: the tea shop (the wind cliffs' tea cave pieces)"],
        ["The frog, in an apron", "0.3 m", "1", "Background", "kit: the frog, in an apron"],
        ["Hanging lantern, lit, on an iron hook", "0.4 m", "1", "Background", "kit: the tea shop (lantern_hang)"],
        ["Line of paper on thick rope, with two iron eyes", "9 m", "1", "Background", "kit: line of paper (papel_string)"],
        ["Tunnel back wall: dark ice", "to suit", "1", "Background", "there today, a flat card"],
        ["Cream rock for the whole floor; scrape marks", "17 m", "1", "Play space (drawn on)", "kit: the summit's body (rock)"],
        ["Snow cap", "about 35 m by 30 m", "1", "Foreground", "kit: the summit's body (snow cap), there today"],
    ],
    "effects": [
        "Steam off the kettle and off the spout. Smoke from the cowl, running east under the prow.",
        "Amber from the lantern and the stove on the room's walls, on the floor in front of it and on the prow above. It is colour on the surfaces, not a glow.",
        "The frog's croak and the kettle's lid ticking, heard from the storm ridge's last rungs.",
        "The awning's paper lifts a little toward the east in the summit's slow air.",
        "When somebody breaks the frost wall far up the tunnel, pieces of frost slide out of the mouth and melt on the floor, with a breath of steam after them.",
    ],
    "notes": [
        "Note 97: the ledge becomes a little tea shop with a frog. The shop stands behind the climb as scenery, cut away at the front, as the note's plan has it. It is the same pot, cups and kettle as the tea cave on the wind cliffs.",
        "Note 60: this biome's frog is the one behind the counter.",
        "Note 40: no cloud stands in front of the ledge. The summit's own low cloud is behind the climb and below the floor.",
        "Note 89, and Parker's answer: no wind on the tea shop's doorstep. In the course today the storm ridge's top wind reaches this ledge: its band runs from 953 to 968 m and from x -346 east, and it blows east for 1.8 seconds in every 4.8. Its top comes down to 962 m, the ledge's underside, so nothing on the floor, the nose or the first ring is pushed, and no wavy lines are drawn here. That is a change to the storm ridge's course, for its own page to draw.",
        "Note 102: the tunnel is the teahouse chute, the way home from the frogs' spring. Today a body thrown over the apex slides out of it; in the design that body goes to the spring first, and comes out here only through the frost wall.",
        "Scenery put right. The cold lantern on the floor at x -346.5, 0.8 m behind you, goes: the lit lantern in the tea shop takes its place. The summit's paper line moves from 1 m behind you to 2 m behind, and 0.9 m down, so its lowest flag is 3 m above the floor and none is hidden by the prow. The storm ridge's paper line, 8 m long, 1 m behind you, with its flags 1.4 to 2.4 m above the floor, is taken down.",
        "The lamp light that lies on the back wall today, centred at x -343, moves 6.5 m east, into the tea shop.",
        "The floor's east 8 m belongs to the storm ridge's file in the course and is drawn in its grey slate. It is drawn as the summit's cream rock, to match the sheet and the storm ridge's last page. Its shape does not change.",
        "Nothing you touch moves.",
    ],
}

# ------------------------------------------------------------------ 11.2 La Corona
_G1 = _swag((-325.6, 967.4), (-332.6, 973.6), 1.5)
_G2 = _swag((-332.6, 973.6), (-339.6, 978.8), 1.2)
_G3 = _swag((-339.6, 977.0), (-328.6, 974.8), 2.2)
_G4 = _swag((-328.6, 976.8), (-321.6, 976.4), 1.3)


def _rime(box):
    """A rime step: its outline, its crack, and the east corner that is gone."""
    x0, y0, x1, y1 = box
    return [_outline(x0, y0, x1, y1, 0.1), _p([(x1 - 0.3, y1), (x1, y1), (x1, y1 - 0.22)], "dark"),
            _ln(round(x0 + 0.35 * (x1 - x0), 2), y1, round(x0 + 0.5 * (x1 - x0), 2), y0, "mark")]


LA_CORONA = {
    "id": "11.2", "slug": "11_2_la_corona", "title": "La Corona", "kind": "challenge",
    "window": [-344.5, 961.5, -316.5, 985.5], "cut_y": 979.6, "climber": [-325.6, 968.6],
    "place": ("The crown. East of the dome, five needles of rock stand up out of the cloud in a ring, and the people who built the temple "
              "pinned an eight-sided boss of gold to the tip of each one: a crown for the First Top Dog's mountain, set just under his "
              "ring. You go round it as the gold goes. Out under the prow's lip to the first tooth. Up the west side, over the dome, on the "
              "second and third. Back east under the horns to the fourth. Across to the fifth, which has a shelf. The gold is what you "
              "swing from. Under each boss the west wind has built a collar of rime on the needle, and that is what you land on: it holds "
              "for 3 seconds and then leaves you hanging from the gold in clear air. The needles stand one layer back, so a body that lets "
              "go passes in front of them and meets nothing until the dome. The first launch is an old iron ring under the prow's lip. It is "
              "also the summit's one last chance, for a body that comes off the prow slowly."),
    "keep": [
        "The iron ring, the nose, the five gold bosses, the four collars, the shelf, its block and its iced belly: each exactly where it is, at its size.",
        "Every rime step's timing: it holds for 3 seconds and is back 12 seconds later.",
        "The five flings as they are. The fourth is thrown flat, 11 m across and 3.8 m down.",
        "Nothing on the east side stops a fall. Every needle stands one layer back, and a body passes in front of it.",
    ],
    "background": [
        {"name": "The peak's own back", "z": [-3.4, -3.0], "tag": [-342.7, 981.3],
         "text": "Warm tan rock, 3 m behind you, behind the dome and west of the teeth: one painted piece in big slanted planes, its bedding long wavy lines of three tans, with a little outcrop here and there carrying a cushion of moss. East of it is open sky. Today its "
                 "east edge is a straight cut at x -318 and its foot is a straight cut at 960 m, and the camera at the first tooth reaches "
                 "down to 959 m. Its east edge becomes a broken buttress. Its foot meets the storm ridge's slate in a line at 962 m, as the "
                 "storm ridge's last page has it, and east of the slate it goes down to 953 m with the teeth.",
         "draw": [_p([(-344.5, 961.5), (-318.0, 961.5), (-318.0, 966.0), (-324.0, 973.0), (-336.0, 980.0), (-344.5, 985.41)])]},
        {"name": "The pillars under the ring's posts", "z": [-2.2, -1.8], "tag": [-330.9, 983.0],
         "text": "The two pillars the ring's corner posts stand on: tan rock 1.8 m back, 26 m tall, going down into the cloud, each one "
                 "painted piece with wavy bedding lines. From the crown they are the biggest things in the sky, with the ring's apron "
                 "hanging between their tops, and they show you where the climb goes next. Like the teeth, they end today in a "
                 "straight cut at 958 m, in the air. The storm ridge's pages ask that each is carried down to 953 m, behind the top of the "
                 "storm's cloud, so that the crown stands out of the storm. This design does the same.",
         "draw": [_p([(-333.99, 961.5), (-326.16, 961.5), (-327.2, 984.4), (-332.6, 984.4)]), _p([(-324.99, 961.5), (-318.58, 961.5), (-319.8, 985.5), (-323.5, 985.5)]),
                  _ln(-333.99, 961.5, -332.6, 984.4, "line"), _ln(-326.16, 961.5, -327.2, 984.4, "line"),
                  _ln(-324.99, 961.5, -323.5, 985.5, "line"), _ln(-318.58, 961.5, -319.8, 985.5, "line")]},
        {"name": "Four marigold garlands", "z": [-2.2, -2.0], "style": "mark", "tag": [-336.3, 976.3],
         "text": "Four swags of the town's marigolds, 0.5 m thick, hung from tooth to tooth round the crown. Today each runs straight from "
                 "gold to gold, 1.2 m behind you and 1.2 m under the line you fly, and it reads as a rope to the next hold (note 98). Each "
                 "is now tied to the backs of two needles, 2 m behind you and 3 m or more under their gold, and hangs lower in between. "
                 "None passes behind a boss or a collar. Where a garland crosses a needle it goes behind the needle.",
         "draw": _G1 + _G2 + _G3 + _G4},
        {"name": "The five teeth", "z": [-1.9, -1.4], "style": "pale", "tag": [-328.6, 969.0], "top": True,
         "text": "Five needles of the summit's rock, 1.4 m back and 2.5 to 3.4 m wide at the foot. Each is one painted piece in two or three slanted planes, with long wavy bedding lines and a leaning, notched outline, and one or two little outcrops carrying a tuft of gold grass or a silver star-flower, below its collar. Three stand in the open with their feet "
                 "in the cloud. The second and third stand up from behind the dome. Each ends in a blunt tip just under its gold. The fifth "
                 "is stouter than the rest, and at 979.2 m its body makes a step 4.2 m wide. The shelf you stand on is that step's front edge.",
         "draw": [_tooth(i, 961.5) for i in range(4)] + [_fifth_tooth(961.5)]},
        {"name": "The fourth tooth's spur", "z": [-1.9, -1.4], "style": "pale", "tag": [-328.5, 964.6],
         "text": "On the west flank of the fourth tooth, 14 m under its gold: a knuckle of rock with an iron eye bolt in its tip. The first "
                 "ring hangs from that bolt. Today the ring is in the air with nothing carrying it. So you launch from the foot of the "
                 "tooth whose top you reach four flings later.",
         "draw": _SPUR},
        {"name": "The fallen post and the second frog", "z": [-1.7, -1.3], "tag": [-318.2, 980.5],
         "text": "On the fifth tooth's step, 1.5 m behind the shelf: the ring's third corner post, fallen, with a frog sitting on its end. "
                 "They are designed on the next page, with the ring's floor beam and its apron overhead.",
         "draw": _FALLEN_POST + [_r(-329.4, 983.6, -322.6, 984.0, "pale")]},
    ],
    "play": [
        {"name": "Rime, where there are carved stone blocks today", "z": [-1.2, 0.0], "style": "line", "tag": [-331.1, 964.45],
         "text": "The nose, the four collars and the block on the shelf are all the summit's rime: grey-white frost feathers, pale and "
                 "matte, cracked across, with the east corner gone, each grown toward the west. A collar wraps its needle and comes forward "
                 "to you. The nose grows off the spur toward the ledge. Each is drawn at exactly the size that holds.",
         "draw": [p for box in [_NOSE] + _COLLARS + [_BLOCK] for p in _rime(box)]},
        {"name": "The five gold bosses", "z": [-0.26, 0.26], "style": "line", "tag": [-333.6, 977.5],
         "text": "Eight-sided, 0.52 m across, brushed and matte. Each sits on a short bronze neck that comes forward from the tip of its "
                 "tooth. Each one is in view from the one before it.",
         "draw": [_c(jx, jy, 0.42) for jx, jy in _JEWELS]},
        {"name": "The first ring", "z": [-0.3, 0.3], "style": "line", "tag": [-330.75, 966.75],
         "text": "Rust-orange iron, 0.52 m across, hanging from the eye bolt in the spur, 2.3 m under the prow's lip. It is the launch for "
                 "the crown, and the one last chance for a body that comes off the prow slowly.",
         "draw": [_c(_RING0[0], _RING0[1], 0.42)]},
        {"name": "The shelf and its iced belly", "z": [-1.2, 1.2], "style": "mark", "tag": [-319.6, 977.9],
         "text": "The shelf's top is warm dry rock, 2.6 m wide. Its underside is glazed black, so a body thrown up at it from below meets "
                 "ice and not an edge. No pale mark is drawn on the belly.",
         "draw": [_p([(-321.6, 976.9), (-320.3, 977.4), (-320.3, 978.7), (-322.9, 978.7)])]},
    ],
    "foreground": [
        {"name": "The dome's snow cap (there today)", "z": [2.0, 2.05], "tag": [-341.3, 973.9],
         "text": "The white cap on the dome's back, set about 1 m in from the line a body slides on. It is 3 m or more from the nearest "
                 "collar, and it covers only solid ice. It stays.",
         "draw": [_p([(-333.5, 969.9), (-340.0, 975.4), (-344.5, 978.54), (-344.5, 970.82), (-341.0, 969.9)])]},
    ],
    "explains": [
        ["The first ring", "An old turnbuckle ring, bolted to the rock by the people who carried the First Top Dog's ring up here in pieces", "The spur on the fourth tooth's flank that the bolt is in"],
        ["The rime nose", "Frost that the west wind has built on the spur", "The spur, and the fourth tooth it belongs to"],
        ["The five gold bosses", "The crown: the gold that the temple's people pinned on the five teeth", "The needle under each one, going down into the cloud"],
        ["The four rime collars", "Frost built on each needle under its gold", "The needle each one wraps"],
        ["The shelf", "The front edge of a step in the fifth tooth's body", "The step, carried on 1 m further back, with the fallen post on it"],
        ["The rime block", "Frost built on the shelf, on the windward side of the fifth needle", "The fifth needle behind it"],
    ],
    "pieces": [
        ["Tooth of the crown: needle", "2.5 to 3.4 m wide at the foot; tips at 970 to 982 m", "5; the fifth with a step 4.2 m wide", "Background", "kit: tooth of the crown; the step is the rock step in the kit below"],
        ["Gold boss on a bronze neck", "0.52 m across", "5", "Play space", "kit: tooth of the crown (the boss)"],
        ["Rime collar; rime nose; rime block", "1.6 m by 0.5 m; 0.8 m by 0.45 m; 1 m by 0.8 m", "4, 1 and 1", "Play space", "kit: rime"],
        ["Iron ring on an eye bolt, in a spur of the fourth tooth", "ring 0.52 m; spur 2.2 m tall", "1", "Play space; the spur behind", "kit: iron ring on an eye bolt"],
        ["Marigold garland", "about 8, 9, 10 and 12 m long, 0.5 m thick", "4", "Background", "kit: marigold garland"],
        ["Pillar under a corner post", "5.4 m and 3.7 m wide at the top, 26 m tall", "2", "Background", "kit: corner post of the ring (the pillar)"],
        ["Summit plants on little outcrops", "0.3 to 0.6 m", "about 8", "Background", "kit: the summit's plants"],
        ["The peak's own back, with a broken east edge", "74 m wide, 40 m tall; 7 m taller at its east end", "1", "Background", "kit: behind everything"],
        ["Fallen corner post; the second frog", "2.2 m; 0.3 m", "1 and 1", "Background", "kit: timber head of a corner post (ring_post), grey finish; the frog that shows the move"],
        ["Iced belly for the shelf", "2.6 m wide", "1", "Play space", "kit: the summit's body (black ice), there today"],
        ["Snow cap", "about 35 m by 30 m", "1", "Foreground", "kit: the summit's body (snow cap), there today"],
    ],
    "effects": [
        "Rime in its last second: it ticks, sheds frost dust, and its crack opens. Growing back, feathers come out from the needle toward the west.",
        "Gold dust in the air. A little snow smoking off the prow's lip above the first ring.",
        "The garlands and the dust drift a little toward the east. Nothing here pushes you above 968 m.",
    ],
    "notes": [
        "Note 98, the garlands. Each of the four moves from 1.2 m behind you to 2 m behind, and down. First to second tooth: tied 3 m under each boss, 1.8 m lower than today, hanging 1.5 m. Second to third: the same ties, hanging 1.2 m. Third to fourth: tied 4.8 m under the third boss and 5 m under the fourth, hanging 2.2 m, so that it passes 0.7 m under the second tooth's collar and behind its needle. Today that one passes 2.7 m over the second boss, along the flat fling. Fourth to fifth: tied 3 m under the fourth boss and 5.4 m under the fifth, below the shelf's belly.",
        "The first ring floated with nothing carrying it. It now hangs from an eye bolt in a spur of the fourth tooth, whose needle already stands 0.25 m east of it, one layer back.",
        "Confirmed by Parker: the steps that break away are rime frost.",
        "Five of the six rime steps float today, as carved stone blocks in the air. Each collar now wraps its needle, and the nose grows off the spur. The sixth, the block, stands on the shelf as it does today.",
        "The fallen post on the shelf moves back out of the play space. It is on the next page.",
        "Note 40: no cloud in front. The three teeth that stand in the open, the two roots and the east end of the peak's back are carried down from 958 m and 960 m to 953 m, behind the top of the storm ridge's cloud, as the storm ridge's pages ask. Today they stop in a straight cut in the air.",
        "Nothing you touch moves.",
    ],
}

# ------------------------------------------------------------------ 11.3 Las Cuerdas del Campeón
# Where the course's own table says a body meets each rope, for an entry at 4 m/s: the path the frog shows.
_FROG_PATH = [(-319.2, 979.9), (-328.18, 985.4), (-322.27, 987.4), (-328.46, 989.4), (-321.85, 991.6), (-329.02, 993.8), (-321.29, 996.0), (-331.0, 995.6)]
_BANDS = ([_ln(-332.2, y, -330.02, y, "mark") for y in (987.8, 991.4)] + [_ln(-320.78, y, -318.6, y, "mark") for y in (989.3, 992.9, 996.5)])
_EAST_HEAD = [_r(-319.6, 998.5, -319.2, 1001.5), _r(-319.65, 1001.2, -319.15, 1001.5, "solid")]


def _plant(x, y):
    """A cushion plant on a little outcrop: the outcrop, and the plant's flat card."""
    return [_p([(x - 0.5, y - 0.35), (x + 0.45, y - 0.35), (x + 0.3, y), (x - 0.4, y)], "pale"), _c(x - 0.12, y + 0.18, 0.2, "light"), _c(x + 0.15, y + 0.14, 0.14, "light")]


LAS_CUERDAS = {
    "id": "11.3", "slug": "11_3_las_cuerdas_del_campeon", "title": "Las Cuerdas del Campeón", "kind": "challenge",
    "window": [-337.5, 976.0, -314.5, 1003.0], "cut_y": 986.6, "climber": [-320.75, 979.2],
    "place": ("The ring. Two horns of rock stand 6 m apart, and the temple's people cut them square to be the corner posts of the First Top "
              "Dog's ring: a shaft of dark glazed rock 2.2 m thick for each, with three turnbuckle blocks standing out of its inner face, one "
              "above the other, and a timber head with a red pad on its top. They strung the ring's three ropes round the posts, red, cream "
              "and jade, and laid its floor and canvas between them. The weather has taken the floor and most of the ropes. What it could not "
              "take is the corners. Along the sloping face of each block a rope is still strung tight between two iron eyes, with a fat "
              "cushion over the turnbuckle at each end. Red at the bottom, cream in the middle, jade at the top: each colour is a matched pair, "
              "one on each post, facing across the gap. They are still lively. Throw yourself into a corner and it throws you back out, harder "
              "than you came in, at the other corner. Six ropes up, you come over the top of the west post and into its timber head. Behind the "
              "gap the jade rope's back run still spans the top, carrying the town's paper. The red and cream back runs hang snapped down the "
              "backs of the posts. One beam of the floor spans between the pillars with the canvas hanging off it as an apron. You start from "
              "the shelf below, where the third post lies fallen, and look up through the place where the ring's floor was."),
    "keep": [
        "The six bouncing lines exactly where they are, and what they do: each throws you up and across, a little harder than you came in.",
        "The inner faces of both posts, the west post's top and the east post's ice tip at 999.9 m. No part of a post or a rope can be held.",
        "The fifth gold boss, the rime block under it, and the fling from the boss into the west post's lowest rope: 6.8 m across and 3.8 m up.",
        "The west post's top and its timber head, which stops the last rope's throw.",
        "One move only, listed in the notes: the east post's outer face goes 1.6 m east.",
    ],
    "background": [
        {"name": "The pillars under the posts", "z": [-2.3, -1.5], "tag": [-330.0, 980.6], "top": True,
         "text": "Each post stands on a pillar of tan rock 1.8 m back, going down into the cloud. Each pillar is one painted piece in two "
                 "or three slanted planes, its bedding long wavy lines of three tans, with a leaning, notched outline. The builders cut "
                 "the top 2 m of each square as a plinth for its post, and that cut edge is chipped. Behind the east post the pillar "
                 "carries on up as a thin back blade. Two little outcrops on the west pillar and one on the east carry the summit's "
                 "plants: a cushion of pink-flowered moss and a tuft of gold grass, each a flat painted card.",
         "draw": [_p([(-333.11, 976.0), (-326.82, 976.0), (-327.2, 984.4), (-332.6, 984.4)]), _p([(-324.1, 976.0), (-319.31, 976.0), (-319.8, 985.8), (-323.5, 985.8)]),
                  _p([(-321.0, 985.8), (-318.9, 985.8), (-319.1, 996.5), (-320.9, 996.5)]),
                  _ln(-333.0, 982.4, -326.9, 982.4, "line"), _ln(-324.0, 983.8, -319.6, 983.8, "line"),
                  _ln(-332.9, 979.4, -330.0, 979.9, "mark"), _ln(-330.0, 979.9, -327.0, 979.2, "mark"), _ln(-323.9, 980.6, -321.6, 981.0, "mark")] +
                 _plant(-333.6, 978.6) + _plant(-326.3, 977.4) + _plant(-318.8, 984.2)},
        {"name": "The ring's last floor beam and its apron", "z": [-2.4, -2.2], "tag": [-325.9, 981.4], "top": True,
         "text": "One beam of the ring's floor still spans from pillar to pillar, 2.3 m behind you, at 984 m, with the broken stubs of "
                 "five joists standing up off it. The canvas is folded over it and hangs down 1.7 m as a torn apron: cream, with a faded "
                 "pug's face. The timber is weathered grey, so it can't be taken for a bar, and the fling from the fifth boss passes in "
                 "front of it. From the shelf it is the first thing that says this was a ring: a ring seen from underneath, its floor gone "
                 "and its apron left. It takes the place of the canvas strip of the first design.",
         "draw": [_r(-329.4, 983.6, -322.6, 984.0, "solid")] + [_ln(x, 984.0, x, 984.35, "line") for x in (-328.5, -327.0, -325.5, -324.0, -323.0)] +
                 [_p([(-328.6, 983.6), (-323.2, 983.6), (-323.2, 982.3), (-324.3, 982.0), (-325.3, 981.6), (-326.6, 982.1), (-327.6, 981.8), (-328.6, 982.2)], "pale"),
                  _c(-325.9, 982.75, 0.42, "line")]},
        {"name": "The fifth tooth's step, the fallen post and the frog", "z": [-2.3, -1.3], "style": "pale", "tag": [-318.2, 980.6], "top": True,
         "text": "The shelf is the front edge of a step in the fifth tooth's body, and the step carries on 1 m further back. On it lies "
                 "the ring's third corner post, broken off at 2.2 m, grey, with its red pad out over the drop. Today that post stands "
                 "upright on the shelf itself, in the play space, where it can't be held. A frog sits on the post's end, looking up at "
                 "the ropes. It shows the move. The first time your feet are on the shelf it croaks and jumps into the west post's red "
                 "rope, and it is thrown from post to post up all six. After that it goes again about every 25 seconds, but only while "
                 "you are standing on the shelf or its block, or hanging from the fifth boss: never while you are in the air. It is never "
                 "solid. At the top it hops over the timber head and off the back of the post, and next it is sitting on the fallen post "
                 "again.",
         "draw": [_fifth_tooth(976.0)] + _FALLEN_POST},
        {"name": "The east post's timber head", "z": [-1.7, -1.3], "style": "pale", "tag": [-317.8, 1000.4],
         "text": "Square timber 3 m tall with its three iron eyes and its red pad: the fellow of the west post's head. It stands on the "
                 "back of the east shaft's top, 1.5 m behind the climb, in weathered grey. Today a post 3.4 m tall stands 0.4 m behind you "
                 "inside the horn's ice tip, where it looks like a thing to catch. It moves 1.2 m east, 1.1 m back and 2 m up, onto the "
                 "widened shaft. With the west head, it gives the ring its two red pads at first sight.",
         "draw": _EAST_HEAD},
        {"name": "The back runs of the ropes, the flagstaff and the paper", "z": [-2.3, -1.3], "style": "mark", "tag": [-326.0, 1001.9],
         "text": "Behind the gap: what is left of the ropes that went round the back of the ring, faded, matte and 0.3 m thick, 2.2 m "
                 "behind you. The jade one, the top rope, still spans from post to post. The frog has re-tied its west end to a flagstaff "
                 "lashed to the back of the west head, so that it rises 3.3 m above the pad, and the town's paper hangs on it: 12.5 m, "
                 "whole and bright, its lowest flag 2.5 m above the pad you stand on. The red and the cream back runs have snapped. Their "
                 "frayed ends, 1.2 to 2 m long, hang down the backs of the two posts. None hangs across the gap you fly through, so each "
                 "colour reads as one rope that went round the ring.",
         "draw": [_ln(-332.0, 998.2, -332.0, 1001.5, "line")] + _horn_line() +
                 [_ln(-330.3, 987.7, -329.8, 985.9), _ln(-330.3, 991.3, -329.7, 989.5), _ln(-320.7, 989.2, -321.3, 987.5), _ln(-320.7, 992.8, -321.4, 991.0)]},
        {"name": "The splinter that carries the second ring", "z": [-1.9, -1.4], "tag": [-334.05, 987.4],
         "text": "A splinter splits off the west pillar's flank and stands up west of the post, leaning into the wind. It carries the "
                 "iron ring of the last leap, which anchored the post's stay. It is designed on the next page.",
         "draw": _splinter(976.0)},
    ],
    "play": [
        {"name": "The two corner posts", "z": [-1.2, 1.2], "style": "mark", "tag": [-331.3, 989.6], "top": True,
         "text": "Each horn is cut square as a corner post: a shaft of dark rock glazed with black ice, 2.2 m thick, with its three "
                 "turnbuckle blocks standing out of its inner face. The face is painted: long wavy bands of blue-black in three tones, "
                 "white glints, and an iron band painted round the shaft at each rope's eye (the dashed lines). Nothing pale is drawn on "
                 "a post, and nothing on it can be held. The east shaft is 0.6 m thick today. Its outer face moves 1.6 m east, from x "
                 "-320.2 to x -318.6, so the two posts match. Its inner face, its ropes and its ice tip stay. The west post's outer foot "
                 "loses a corner, 0.6 m, where nobody goes.",
         "draw": [_p(_HORN_W), _p(_HORN_E)] + _BANDS},
        {"name": "The six ring ropes, three matched pairs, and the move shown", "z": [-0.15, 0.15], "tag": [-324.9, 990.2], "top": True,
         "text": "Each rope is a band 0.3 m thick and 4.4 m long, wound in glossy tape, lying exactly along its bouncing line and 0.2 m "
                 "proud of the ice. On each post the lowest is red, the middle one cream and the top one jade, so the pairs face each other "
                 "across the gap in the order of a ring's three ropes. A fat cushion covers the turnbuckle at each end, and the cushions "
                 "throw you too. At rest each rope quivers a little. When you hit one it squashes in, springs back and hums. Between them "
                 "the three ropes cover the whole inner face of a post. Today none of this is drawn (note 98). The dashed line is the "
                 "frog's path and yours: six throws, 2 m higher each time, and the last one carries you west over the post's top.",
         "draw": [p for a, b in _ROPES_W + _ROPES_E for p in _rope(a, b)] +
                 [_t(-327.0, 985.2, "red"), _t(-327.0, 988.8, "cream"), _t(-327.0, 992.4, "jade"), _t(-325.0, 987.6, "red"), _t(-325.3, 991.2, "cream"), _t(-325.0, 994.8, "jade")] +
                 [_ln(_FROG_PATH[k][0], _FROG_PATH[k][1], _FROG_PATH[k + 1][0], _FROG_PATH[k + 1][1], "mark") for k in range(len(_FROG_PATH) - 1)]},
        {"name": "The west post's top and its timber head", "z": [-1.2, 1.2], "style": "line", "tag": [-333.1, 996.6],
         "text": "The top is 2.6 m of warm dry rock. At its west end stands the post's timber head: square honey timber 0.4 m thick and "
                 "3 m tall, with three iron turnbuckle eyes up its east face and a red pad on top. It is the only timber in the ring you "
                 "can hold. The sixth rope throws you over the top and into it.",
         "draw": [_outline(-332.2, 994.7, -329.6, 995.2, 0.1), _outline(-332.2, 995.2, -331.8, 998.2, 0.1), _r(-332.25, 997.9, -331.75, 998.2, "solid")] +
                 [_c(-331.68, y, 0.1) for y in (996.0, 996.9, 997.8)]},
        {"name": "The fifth boss and its rime block", "z": [-0.4, 0.4], "style": "line", "tag": [-323.0, 980.6],
         "text": "The launch. Stand on the block to reach the gold, and the block leaves. Both are as on La Corona's page.",
         "draw": _rime(_BLOCK) + [_c(_JEWELS[4][0], _JEWELS[4][1], 0.42)]},
    ],
    "foreground": [],
    "explains": [
        ["The six ropes", "The ring's three ropes, red, cream and jade, still strung tight on the two standing corners: a matched pair of each", "Their back runs: the jade one spanning the top with the paper on it, the red and cream ones hanging snapped"],
        ["The two posts", "The ring's two corner posts, cut square out of the horns, each with its three turnbuckle blocks", "The pillar each one stands on, cut square at the top as a plinth, going down into the cloud"],
        ["The west post's top", "The corner's top, where the ring's builders stood", "The flagstaff behind the timber head, with the paper running east and west from it"],
        ["The west post's timber head", "The one timber head still standing where a luchador can reach it", "Its two fellows: one on the east post, one fallen on the step below"],
        ["The fifth boss, the shelf and the block", "The top of the crown, under the place where the ring's floor was", "The last floor beam and its apron overhead, the fifth tooth's step, the fallen post and the frog"],
    ],
    "pieces": [
        ["Ring rope with a turnbuckle cushion and an iron eye at each end: red, cream, jade", "4.4 m long, 0.3 m thick; cushions 0.5 m", "6: a matched pair of each colour", "Play space", "kit: ring rope"],
        ["Corner post: glazed dark shaft with three turnbuckle blocks and painted iron bands", "2.2 m thick; west top at 995.2 m, east tip at 999.9 m", "2", "Play space", "kit: corner post of the ring"],
        ["Pillar with a squared plinth; the east pillar's back blade", "pillars 26 m tall; blade 2 m wide, 10.7 m tall", "2 and 1", "Background", "kit: corner post of the ring (the pillar); the blade is new, this area only"],
        ["Timber head, honey", "0.4 m thick, 3 m tall", "1", "Play space", "kit: timber head of a corner post (ring_post)"],
        ["Timber head, weathered grey: standing, and fallen and broken", "3 m; 2.2 m", "1 and 1", "Background", "kit: timber head of a corner post (ring_post), grey finish"],
        ["The ring's floor: last beam, joist stubs, canvas apron", "beam 6.8 m; apron 5.4 m by 1.7 m", "1", "Background", "kit: the ring's floor"],
        ["Back run of a ring rope: the jade span, and four snapped ends", "12.5 m; 1.2 to 2 m", "1 and 4", "Background", "kit: back run of a ring rope"],
        ["The frog that shows the move", "0.3 m", "1", "Background, then play space in passing", "kit: the frog that shows the move"],
        ["Fifth tooth with its step", "step 4.2 m wide, 1 m deep behind the shelf", "1", "Background", "kit: tooth of the crown; the rock step in the kit below"],
        ["Flagstaff, lashed to the west head's back", "6.3 m", "1", "Background", "kit: line of paper (the flagstaff)"],
        ["Line of paper, hung on the jade back run", "12.5 m", "1", "Background", "kit: line of paper (papel_string)"],
        ["Summit plants on little outcrops", "0.3 to 0.6 m", "3", "Background", "kit: the summit's plants"],
        ["Rime block", "1 m by 0.8 m", "1", "Play space", "kit: rime"],
    ],
    "effects": [
        "A rope squashes where you hit it, springs back and hums. Its cushions puff a little dust.",
        "The apron stirs toward the east. The paper on the jade rope lifts the same way, and the snapped ends sway.",
        "The frog's croak on the fallen post, a moment before it jumps. It is how you know to look.",
    ],
    "notes": [
        "Parker, 11-13, late, on the summit's story: right, but the summit does not yet look like the ruin of a ring. What now makes it read as one at first sight: the horns are cut square as two matching corner posts with three turnbuckle blocks each and painted iron bands; each post has a timber head with a red pad; the six ropes are three matched pairs in a ring's order; the jade rope's back run spans the top and the red and cream ones hang snapped; one floor beam spans the pillars with the canvas apron hanging off it; the third post lies fallen below; and the bell stands at the ringside as the timekeeper's.",
        "Move in the play space: the east post's outer face, from x -320.2 to x -318.6, from 985.6 m to 998.5 m, with its top cut level at 998.5 m from x -318.6 to x -320.2. Its inner face, its three bouncing lines and its ice tip at x -320.6, 999.9 m, do not move. The west post's outer foot loses a corner 0.6 m on a side, at x -332.2, 984.1 m. Nothing else you touch moves.",
        "Note 98, the ropes are drawn. In the game the six ring ropes had no model at all. Each now has one, lying exactly along its bouncing line, and it squashes and springs when it throws you. No bouncing line moves.",
        "Note 98, the view from the shelf. Today, standing on the shelf, the camera leans 1 m down, and the frame tops out at about 988 m, level with the top of the west post's lowest rope. In the design, while you stand on the shelf the camera leans 3 m up and 3 m west. The frame then runs from 974 to 992 m, and it holds both red ropes whole, the west cream rope, the apron and the frog.",
        "Note 98, the move shown, confirmed by Parker: a frog bounces up the ropes now and then. It starts from the fallen post, behind the shelf; the first time when your feet are first on the shelf, then about every 25 seconds while you are on the shelf, its block or the fifth boss, never while you are in the air. It is never solid, it is always ahead of you, and it leaves off the back of the west post.",
        "Scenery moved out of the play space. The east post's head: 1.2 m east, 1.1 m back and 2 m up, onto the widened shaft, 1.5 m behind you. The fallen post: from standing upright on the shelf, 0.9 m behind you, to lying on the tooth's step, 1.5 m behind. The paper from post to post: from 1 m behind you, with its flags 1.2 m above the timber head's top, to the jade back run 2 m behind, with its lowest flag 2.5 m above the pad.",
    ],
}

# ------------------------------------------------------------------ 11.4 El Último Salto
EL_ULTIMO_SALTO = {
    "id": "11.4", "slug": "11_4_el_ultimo_salto", "title": "El Último Salto", "kind": "challenge",
    "window": [-364.0, 984.0, -326.0, 1012.0], "cut_y": 998.2, "climber": [-332.0, 998.2],
    "place": ("The top of the ring's west post, at 995 m: 2.6 m of dry rock with the post's timber head at its west end. It is the highest "
              "place the ring's builders stood, and the end of everything they made except the bell. From here the bell is in plain view, "
              "24 m to the west and 8 m up, across the open back of the dome, and its rope hangs down to below your feet. Between you and "
              "it there is one thing: an iron ring on the tip of a splinter of rock, 3.7 m west of the post and level with its top. The "
              "ring anchored the post's stay, the tie that held the corner against the pull of the ropes, and that is why it is level with "
              "the post's top. So the last leap is made the way a luchador makes it. Climb the post's timber head by its three turnbuckle eyes. "
              "Stand on the pad. Jump to the ring, swing, and let go. It is the worst fall in the game: a miss lands on the dome, and the "
              "dome ends at the prow."),
    "keep": [
        "The post's top and its timber head, each where it is. The timber head is held all over.",
        "The ring's distance from the post: 3.7 m. Only its height changes (note 99).",
        "The bell rope where it hangs, and the last leap: 20 m across from the ring.",
        "The camera pulls back for the leap, so the rope and the dome under it are both on screen before you jump.",
        "Nothing breaks the fall. Under the ring there is 25 m of air, then the dome.",
    ],
    "background": [
        {"name": "The peak's own back", "z": [-3.4, -3.0], "tag": [-352.0, 987.6],
         "text": "Tan rock, 3 m behind you, standing 4 to 5 m above the dome's white back and ending at the very top, behind the foot of the "
                 "bell frame. Everything above it and east of it is sky. This is the widest view of open sky on the summit, and nothing "
                 "is put into it.",
         "draw": [_p([(-342.29, 984.0), (-347.0, 987.0), (-357.0, 992.5), (-358.0, 1000.8), (-362.6, 1000.8), (-364.0, 996.76), (-364.0, 984.0)])]},
        {"name": "The splinter that carries the ring", "z": [-1.9, -1.4], "tag": [-334.3, 989.0], "top": True,
         "text": "A splinter of the west horn's pillar, one layer back. It splits off the pillar's west flank at 977 m and stands 21 m, "
                 "leaning 3 m to the west, into the wind. It comes to a point too narrow to stand on, 0.15 m under the ring. An iron eye "
                 "bolt in the point comes forward to you, and the ring hangs from it. Today the ring floats in the air with nothing "
                 "carrying it.",
         "draw": _splinter(984.0)},
        {"name": "The flagstaff behind the timber head", "z": [-2.0, -1.3], "style": "line", "tag": [-330.9, 1000.4],
         "text": "A staff 6.3 m tall, lashed to the back of the timber head and raked back. From the side it is hidden by the head until it "
                 "rises above the red pad. It also carries the west end of the jade rope's back run, with the paper from post to post. Its top is 2 m behind you and 3.3 m above the pad you stand on, so the lowest flag of the "
                 "paper tied to it is 2.5 m above the pad, out of any hand's reach.",
         "draw": [_ln(-332.0, 998.2, -332.0, 1001.5)]},
        {"name": "The paper over the leap", "z": [-2.1, -2.0], "style": "mark", "tag": [-346.0, 1006.1],
         "text": "The town's paper on thick old ring rope, whole and bright, from the flagstaff's top to the top of the bell staff: 30 m, "
                 "rising 10 m, with flags 0.8 m tall like the tea shop's. It runs over the line of the leap and shows you where the leap goes. Its flags pass 3.6 m over the ring "
                 "and 2.5 m over the beam of the bell frame. Today it is tied to the timber head's top, 1.2 m behind you, at the height "
                 "of your hands when you stand on the post.",
         "draw": _leap_line() + _horn_line() + _west_line()},
        {"name": "At the bell", "z": [-3.0, -1.3], "style": "pale", "tag": [-361.5, 1009.6],
         "text": "On the far side of the gap: the bell staff rising 4.8 m above the belt's post, the frame's back strut, and the rib of rock "
                 "that the perch is the top of. They are designed on La Campana's page.",
         "draw": [_ln(-360.3, 1006.4, -360.3, 1011.2, "line")] + _STRUT + _RIB},
    ],
    "play": [
        {"name": "The timber head, climbed", "z": [-0.2, 0.2], "style": "line", "tag": [-330.6, 997.3],
         "text": "Square honey timber, 0.4 m thick and 3 m tall. Its three iron turnbuckle eyes stand out of its east face 0.9 m apart, "
                 "like rungs, and its top is a red pad. You climb it and stand on the pad, 3 m above the horn's top.",
         "draw": [_outline(-332.2, 995.2, -331.8, 998.2, 0.1), _r(-332.25, 997.9, -331.75, 998.2, "solid")] + [_c(-331.68, y, 0.1) for y in (996.0, 996.9, 997.8)]},
        {"name": "The iron ring, moved up", "z": [-0.3, 0.3], "style": "line", "tag": [-337.0, 998.9],
         "text": "Rust-orange iron, 0.52 m across. It moves up 1.9 m, from 996.3 m to 998.2 m, level with the post's top. It does not move "
                 "sideways. The cross marks where it is today.",
         "draw": [_c(_RING4[0], _RING4[1], 0.42), _ln(-335.95, 996.05, -335.45, 996.55, "mark"), _ln(-335.95, 996.55, -335.45, 996.05, "mark")]},
        {"name": "The plank that goes", "z": [-1.2, 1.2], "style": "mark", "tag": [-333.4, 993.9],
         "text": "The rotten plank west of the post, 2.2 m long, is taken away. Nothing stands between the post and the ring but 3.7 m of air.",
         "draw": [_r(-334.4, 994.95, -332.2, 995.2), _ln(-334.4, 994.8, -332.2, 995.35), _ln(-334.4, 995.35, -332.2, 994.8)]},
        {"name": "The catch", "z": [-1.1, 1.1], "tag": [-354.2, 995.5],
         "text": "The bell rope, with its wooden toll handle at 992 m. The leap is aimed 3.3 m above the handle. Above it hangs the bell, "
                 "which is solid in the design and tolls when you land on the rope. Both are on La Campana's page.",
         "draw": _BELL + [_r(-355.95, 991.9, -355.45, 992.2, "pale"), _ln(-356.2, 995.5, -355.2, 995.5, "mark")]},
    ],
    "foreground": [
        {"name": "The dome's snow cap (there today)", "z": [2.0, 2.05], "tag": [-359.8, 990.8],
         "text": "The white cap on the dome's back and on the summit's east cliff, in front of solid ice. The leap passes high above it "
                 "and ends at the rope, 3 m short of it. It stays.",
         "draw": [_p([(-352.31, 984.0), (-358.9, 988.6), (-359.6, 999.2), (-360.3, 999.8), (-361.0, 999.0), (-364.0, 988.95), (-364.0, 984.0)])]},
    ],
    "explains": [
        ["The post's top", "The top of the ring's west corner post", "The flagstaff behind the post, and the paper going out over the gap"],
        ["The timber head", "The head of the first ring's west corner post, climbed by its turnbuckle eyes", "Nothing stands behind it but its own staff: it is the last made thing before the bell"],
        ["The iron ring", "The anchor of the post's stay. The stay is gone", "The splinter of rock it is bolted to"],
        ["The bell rope", "The rope of the bell that started and ended a bout", "The bell, the frame and the perch, on La Campana's page"],
        ["The dome below", "The mountain's fall line", "The peak's own back, standing above the snow"],
    ],
    "pieces": [
        ["Timber head with three iron eyes and a red pad", "0.4 m thick, 3 m tall", "1", "Play space", "kit: timber head of a corner post (ring_post)"],
        ["Iron ring on an eye bolt", "0.52 m", "1", "Play space", "kit: iron ring on an eye bolt"],
        ["Rock splinter", "1.1 m wide at 984 m; 21 m tall, leaning 3 m", "1", "Background", "kit: iron ring on an eye bolt (its spur)"],
        ["Flagstaff, lashed to the timber head's back", "6.3 m", "1", "Background", "kit: line of paper (the flagstaff)"],
        ["Bell staff", "8.2 m", "1", "Background", "the bell staff in the kit below"],
        ["Line of paper on thick rope", "30 m; and the 12.5 m and 23 m lines, which leave the picture", "3", "Background", "kit: line of paper (papel_string)"],
        ["The peak's own back", "to suit", "1", "Background", "kit: behind everything"],
        ["Snow cap", "about 35 m by 30 m", "1", "Foreground", "kit: the summit's body (snow cap), there today"],
    ],
    "effects": [
        "The paper over the leap lifts toward the east, back the way you came.",
        "Gold dust in the low sun. The ring creaks on its bolt when you swing.",
        "As the camera pulls back, the bell's bronze catches the sun.",
    ],
    "notes": [
        "Note 99: the breaking plank goes. It is 2.2 m of rotten plank west of the post, from x -334.4 to x -332.2, at 995.2 m. Nothing replaces it.",
        "Note 99: the iron ring moves up 1.9 m, from 996.3 m to 998.2 m, level with the top of the timber head. It stays at x -335.7, 3.7 m west of the post's middle. You climb the post and jump 3.7 m on the level to the ring.",
        "Note 99, to measure when it is built: the last leap from the higher ring, and what a miss of the first jump does. Under the ring there is nothing for 25 m, and then the dome.",
        "The ring floated with nothing carrying it. It now hangs from an eye bolt in the tip of a rock splinter that stands 1.4 m or more behind you.",
        "The paper along the leap was tied to the post's top at 998.2 m, 1.2 m behind you: at hand height, now that you stand on the post. Its east end moves up 3.3 m, to the flagstaff's top at 1,001.5 m, and back to 2 m behind you, so that its lowest flag is 2.5 m above the pad. Its west end moves from the beam's east end, at 1,005.5 m, to the bell staff's top, at 1,011.2 m.",
        "The area's own sun, the pale disc behind the bell, stays out. The far view's sun is the only one.",
        "Taken as settled with Parker's answers: a tall staff behind the bell frame's post carries the far end of the paper over the leap.",
        "Nothing else you touch moves.",
    ],
}

# ------------------------------------------------------------------ 11.5 La Campana
LA_CAMPANA = {
    "id": "11.5", "slug": "11_5_la_campana", "title": "La Campana", "kind": "challenge",
    "window": [-367.0, 988.0, -347.0, 1012.5], "cut_y": 1003.4, "climber": [-357.5, 998.7],
    "place": ("The bell. The temple's people hung it on the very top to start and to end a bout: a bronze bell 2.2 m across, with the First "
              "Top Dog's face cast on it, in an iron yoke under the east end of a timber frame. Its rope hangs 10 m down the summit's east "
              "cliff with a wooden toll handle on its end, and that rope is what the last leap catches. The frame stands at the ringside, "
              "where a ring's timekeeper sits. Nobody has rung it for a very long time. The last of the ones who tried sits in the "
              "timekeeper's seat, a perch of rock 4 m under the bell, looking up at it, with marigolds laid "
              "beside him. There is nobody above him. When your weight comes onto the rope the bell tips toward you, the clapper strikes, "
              "and the whole summit hears that somebody has arrived. Then you climb the rope, into the sound."),
    "keep": [
        "The rope: where it hangs, its 10 m, and the toll handle on its end.",
        "The perch and the one who sits on it. The frame's post, beam and brace.",
        "The way up: the rope, then the bell and its yoke, then the beam.",
    ],
    "background": [
        {"name": "The peak's own back", "z": [-3.4, -3.0], "tag": [-362.6, 993.6],
         "text": "The summit's rock behind its ice, 3 m back, ending in a blunt head at 1,000.8 m behind the foot of the frame's post. The "
                 "post is footed in the mountain, and this shows it.",
         "draw": [_p([(-348.82, 988.0), (-357.0, 992.5), (-358.0, 1000.8), (-362.6, 1000.8), (-366.0, 991.0), (-367.0, 991.38), (-367.0, 988.0)])]},
        {"name": "The rib under the perch, and his marigolds", "z": [-2.2, -1.3], "style": "pale", "tag": [-357.9, 994.0], "top": True,
         "text": "A rib of warm rock comes forward out of the peak's back, 1.3 m behind you, and the perch is its top. So the perch is a "
                 "place on the mountain, and not a block stuck on a wall of ice. The rib's top carries on 1 m behind the perch. The "
                 "marigolds lie there, beside the one who sits, on the side the rope is on. Today the pile lies in the play space, where "
                 "it can't be held.",
         "draw": _RIB + [_c(-357.4, 998.9, 0.2, "light"), _c(-357.05, 998.87, 0.17, "light"), _c(-357.22, 999.08, 0.15, "light")]},
        {"name": "The frame's back strut", "z": [-3.0, -1.3], "style": "line", "tag": [-362.9, 1002.6],
         "text": "A square timber from the back of the post down to the head of the peak's back, 3 m behind. It holds the frame against "
                 "the pull of the bell, and it is why a frame with one post still stands.",
         "draw": _STRUT},
        {"name": "The bell staff", "z": [-2.0, -1.3], "style": "line", "tag": [-361.4, 1009.6],
         "text": "A staff 8.2 m tall, lashed to the back of the frame's post and raked back, like the one behind the corner post. From the "
                 "side it is hidden by the post until it rises above the belt. Its top is 4.8 m above the post's top. It carries the far "
                 "ends of the two long lines of paper.",
         "draw": [_ln(-360.3, 1006.4, -360.3, 1011.2)]},
        {"name": "The two lines of paper", "z": [-2.1, -2.0], "style": "mark", "tag": [-351.0, 1008.2],
         "text": "From the bell staff's top one line runs east, down over the leap to the west horn, and one runs west, down to a staff on "
                 "the peak's back above the west shoulder. Both are 2 m behind you. Over the beam their lowest flags are 2.5 m up or more, and "
                 "over the post's top 4 m. Today one is tied to the beam's east end, at the height of your hands, and the other ends in the air 1.1 m "
                 "under the beam's west end.",
         "draw": _leap_line() + _west_line()},
    ],
    "play": [
        {"name": "The bell, solid, and its clapper", "z": [-1.1, 1.1], "tag": [-353.6, 1003.4], "top": True,
         "text": "Bronze, matte, 2.2 m across and 2.6 m tall, with the First Top Dog's face cast on the side that faces you. It hangs "
                 "mouth down under the beam's east end, and the rope comes out of its mouth from the clapper. It is solid wherever it "
                 "is drawn, and it can be held. When your weight comes onto the rope it tips toward you, the clapper shows under its lip "
                 "and strikes, and it rocks back. The dashed lines show how far it swings. Bell, clapper and rope move as one thing.",
         "draw": _BELL + [_ln(-355.7, 1005.3, -356.5, 1002.3, "mark"), _ln(-355.7, 1005.3, -354.9, 1002.3, "mark")]},
        {"name": "The iron yoke", "z": [-0.4, 0.4], "style": "line", "tag": [-354.3, 1005.05],
         "text": "Rust-orange iron: a hanger from the beam, a pin, and a fork that holds the bell by its crown. The pin is the hinge the "
                 "bell swings on, and you can see it turn. All of it can be held.",
         "draw": [_r(-356.25, 1004.8, -355.15, 1005.0), _ln(-355.7, 1005.0, -355.7, 1005.3), _c(-355.7, 1005.15, 0.1)]},
        {"name": "The bell rope and the toll handle", "z": [-0.2, 0.2], "style": "pale", "tag": [-354.6, 992.1],
         "text": "Hemp, 10 m long, with a wooden toll handle 0.5 m wide on its end. The leap arrives 3.3 m above the handle. Every hard "
                 "swing or tug tolls the bell again. Hang still and it rocks to rest.",
         "draw": [_r(-355.95, 991.9, -355.45, 992.2), _ln(-356.2, 995.5, -355.2, 995.5, "mark")]},
        {"name": "The perch and the last of the ones who tried", "z": [-1.2, 1.2], "style": "line", "tag": [-357.9, 997.3],
         "text": "Warm dry rock, 2.1 m wide: the timekeeper's seat, and the last place on the mountain where you stand on stone. He sits "
                 "at its back with his mask turned up to the bell. He is the game's climber model, posed sitting: nothing is modelled for "
                 "him, and the new climber model takes his place when it comes. He stays exactly where he is.",
         "draw": [_p([(-359.1, 997.9), (-357.0, 998.35), (-357.0, 998.7), (-359.1, 998.7)])]},
        {"name": "The marigolds on the frame", "z": [0.2, 0.3], "style": "mark", "tag": [-361.3, 1002.0],
         "text": "A garland wound up the post and laid along the beam. Today it hangs 0.4 m in front of the timber, 0.5 m thick. It is "
                 "pressed flat onto the post's face and the beam's front face, so it is part of the timber and is held with it.",
         "draw": [_ln(-360.55, 1000.3, -360.05, 1001.2), _ln(-360.55, 1001.6, -360.05, 1002.5), _ln(-360.55, 1002.9, -360.05, 1003.8), _ln(-360.55, 1004.2, -360.05, 1005.1),
                  _ln(-361.4, 1005.5, -355.0, 1005.5)]},
    ],
    "foreground": [
        {"name": "The summit's snow cap (there today)", "z": [2.0, 2.05], "tag": [-361.5, 991.0],
         "text": "The white cap on the summit block, in front of solid ice. Its east edge runs up the cliff 0.4 m west of the perch's back, "
                 "and it covers nothing you stand on. It stays.",
         "draw": [_p([(-358.04, 988.0), (-358.9, 988.6), (-359.6, 999.2), (-360.3, 999.8), (-361.0, 999.0), (-364.28, 988.0)])]},
    ],
    "explains": [
        ["The bell rope and its handle", "The rope of the bell that started and ended a bout", "The bell above it, which swings and tolls with it"],
        ["The bell and its yoke", "The bell, hung under the frame's beam", "The frame's back strut, and the peak's back that the frame is footed in"],
        ["The post, the beam and the brace", "The bell frame: the biggest thing the ring's builders made", "The back strut, and the bell staff rising behind the post"],
        ["The perch", "The timekeeper's seat at the ringside: the top of a rib of the mountain's own rock", "The rib, going down behind the ice, and the marigolds on its top"],
        ["The one who sits", "The last of the ones who tried", "His marigolds, laid beside him by the frog that keeps the tea shop"],
    ],
    "pieces": [
        ["The bell with its clapper, solid, swinging on its yoke", "bell 2.2 m across, 2.6 m tall; yoke 3.1 m from pin to mouth", "1", "Play space", "kit: the bell, its clapper, its iron yoke"],
        ["Bell rope with a wooden toll handle", "rope 10 m; handle 0.5 m by 0.3 m", "1", "Play space", "kit: the bell rope"],
        ["Bell frame: post, beam, brace", "post 0.5 m thick, 6.6 m tall; beam 6.8 m; brace 4 m", "1", "Play space", "kit: bell frame"],
        ["Back strut for the frame", "0.3 m thick, 4.9 m long", "1", "Background", "the back strut in the kit below"],
        ["Bell staff", "8.2 m", "1", "Background", "the bell staff in the kit below"],
        ["Line of paper on thick rope", "30 m and 23 m", "2", "Background", "kit: line of paper (papel_string)"],
        ["Rock rib under the perch", "2 to 2.9 m wide, 10.7 m tall", "1", "Background", "the rock step in the kit below"],
        ["The last of the ones who tried, sitting; his marigolds", "1.2 m tall; pile 0.8 m", "1 and 1", "Play space; the marigolds behind", "kit: the last of the ones who tried (marigold_pile)"],
        ["Marigold garland, pressed flat on timber", "5.5 m and 6.5 m", "2", "Play space (drawn on)", "kit: marigold garland"],
        ["Snow cap", "about 35 m by 30 m", "1", "Foreground", "kit: the summit's body (snow cap), there today"],
    ],
    "effects": [
        "The catch at the end of the last leap is the loudest toll. Each toll after it is as loud as the tug that made it.",
        "A little dust falls from the yoke's pin at the first toll: it has not turned for a long time.",
        "Marigold petals come loose from the frame when the bell rings.",
    ],
    "notes": [
        "Note 100: the rope rings the bell, and the bell and its clapper swing with it. The bell tips when your weight comes onto the rope, tolls at every hard swing or tug, and rocks to rest when you hang still. The three tolls at the belt stay as the finish.",
        "Course change: the bell becomes a solid thing that swings. Today the only solid there is its hanger, an iron bar 0.18 m wide from 1,002.2 to 1,005.3 m, and the bell's model does not move. The bell is 2.2 m across and 2.6 m tall. Its mouth is at 1,002.2 m, where the rope's top is today, and its crown is at 1,004.8 m, 0.5 m under the beam. It hangs from the yoke's pin under the beam and is drawn tipping 15 degrees either way, which moves the rope's top 0.8 m either side. How far it tips is settled when it is built.",
        "So the way up changes a little. Today you climb from the rope straight up a bare iron bar to the beam. In the design you climb from the rope onto the bell's flank, up the bell, and onto the yoke and the beam.",
        "In the course today the bell's model hangs from a point at 1,006.3 m, which is 0.6 m above the beam's top. By those numbers the bell hangs through the beam, and its mouth is 1.5 m above the top of the rope.",
        "Scenery put right. The marigold pile moves from 0.5 m behind you to 1.5 m behind and 1.7 m east, onto the rib's top. The two garlands on the frame move from 0.4 m in front of the timber to flat on it. The two lines of paper move up to the bell staff's top, at 1,011.2 m, 2 m behind you: one from the beam's east end, and one from a loose end in the air 1.1 m under the beam's west end.",
        "Confirmed by Parker: the bell is solid. It can be held and stood on.",
        "Parker: a new climber model is coming very soon. The one who sits is the game's climber model, posed; nothing bespoke is made for him.",
        "Nothing else you touch moves: the rope's place and length, the handle, the perch, the frame.",
    ],
}

# ------------------------------------------------------------------ 11.6 Top Dog
TOP_DOG = {
    "id": "11.6", "slug": "11_6_top_dog", "title": "Top Dog", "kind": "challenge",
    "window": [-367.0, 998.5, -349.5, 1012.5], "cut_y": 1005.6, "climber": [-357.3, 1005.7],
    "place": ("The last 4 m of the mountain. From the bell you pull up onto the frame's beam, walk it west to the post, and step up onto the "
              "post's top, which stands 0.7 m above the beam. The belt is there, held up on two bronze pegs, with its plates toward you: "
              "gold on red leather, made in the chimney's forge 500 m below and carried up here by the people who built the ring. It has "
              "waited on this post ever since. Nothing here is hard. It is three reaches on dry timber, with the whole climb under you and "
              "nothing above you but a staff and the sky. Touch the belt and the climb is over."),
    "keep": [
        "The three reaches: from the bell onto the beam, along the beam, and up onto the post's top.",
        "The belt where it is, and the box round it that ends the climb when you touch it.",
        "The beam and the post are held all over.",
    ],
    "background": [
        {"name": "The head of the peak's back", "z": [-3.4, -3.0], "tag": [-362.3, 1000.0],
         "text": "The mountain's own rock, 3 m behind, coming to a blunt head at 1,000.8 m behind the post's foot. It is the top of the "
                 "mountain. Everything above it was carried up.",
         "draw": [_p([(-357.72, 998.5), (-358.0, 1000.8), (-362.6, 1000.8), (-363.4, 998.5)])]},
        {"name": "The frame's back strut", "z": [-3.0, -1.3], "style": "line", "tag": [-362.6, 1002.6],
         "text": "The timber that ties the post back to the rock, as on La Campana's page.",
         "draw": _STRUT},
        {"name": "The bell staff", "z": [-2.0, -1.3], "style": "line", "tag": [-361.4, 1009.6], "top": True,
         "text": "Behind the post, raked back, rising 4.8 m above its top. It is thin and honey-coloured, and it stands 2 m behind the belt, "
                 "so the belt is seen against the sky and not against the staff.",
         "draw": [_ln(-360.3, 1006.4, -360.3, 1011.2)]},
        {"name": "The two lines of paper", "z": [-2.1, -2.0], "style": "mark", "tag": [-354.0, 1009.2],
         "text": "They leave the staff's top to the east and to the west, falling away on both sides, so that the last thing you climb "
                 "toward is the place where all the town's paper meets. Nothing is tied to the beam or the post.",
         "draw": _leap_line() + _west_line()},
    ],
    "play": [
        {"name": "The belt on its pegs", "z": [-0.1, 0.1], "style": "pale", "tag": [-362.0, 1007.2],
         "text": "Gold plates on red leather, 1.2 m wide and 0.6 m tall, with the pug's face on its centre plate. It stands upright on two "
                 "bronze pegs 0.5 m tall in the post's top, its plates toward you. It is the forge's work, and nothing else up here looks like "
                 "it. Brushed gold, matte, like the crown's bosses: the last hold on the mountain.",
         "draw": [_r(-360.9, 1006.9, -359.7, 1007.5), _ln(-360.5, 1006.4, -360.5, 1006.9, "line"), _ln(-360.1, 1006.4, -360.1, 1006.9, "line")]},
        {"name": "The beam's top", "z": [-0.2, 0.2], "style": "mark", "tag": [-358.3, 1004.6],
         "text": "Honey timber, 0.4 m deep, squared with an adze, with the garland pressed flat along its front face. You come onto it at "
                 "its east end, beside the yoke, and walk 4 m to the post. West of the post it runs on 1.1 m: after the card, that end is "
                 "where you step off for the frogs' spring, under the frog's painted sign.",
         "draw": [_ln(-355.4, 1005.82, -360.05, 1005.82)]},
        {"name": "The post's head", "z": [-0.25, 0.25], "style": "line", "tag": [-359.2, 1006.2],
         "text": "The post stands 0.7 m above the beam, and its top is 0.5 m square: room for two feet. This is the last step.",
         "draw": [_outline(-360.55, 1005.7, -360.05, 1006.4, 0.08)]},
        {"name": "The bell you step off", "z": [-1.1, 1.1], "tag": [-353.6, 1003.4],
         "text": "The bell and its yoke, as on La Campana's page. You come up the bell's flank and the yoke onto the beam's east end.",
         "draw": _BELL + [_r(-356.25, 1004.8, -355.15, 1005.0, "line"), _ln(-355.7, 1005.0, -355.7, 1005.3, "line")]},
        {"name": "The box that ends the climb", "z": [-1.2, 1.2], "style": "mark", "tag": [-358.6, 1007.6],
         "text": "A hand anywhere in this box, 1.5 m square round the belt, ends the climb, as today. The ceremony starts here. It is on "
                 "the next page.",
         "draw": [_r(-361.05, 1006.15, -359.55, 1007.65)]},
    ],
    "foreground": [
        {"name": "The tip of the summit's snow cap (there today)", "z": [2.0, 2.05], "tag": [-360.3, 999.15],
         "text": "The top 1.3 m of the white cap, in front of the ice of the very top, under the post's foot. It covers nothing you touch.",
         "draw": [_p([(-359.55, 998.5), (-359.6, 999.2), (-360.3, 999.8), (-361.0, 999.0), (-361.15, 998.5)])]},
    ],
    "explains": [
        ["The beam", "The arm of the bell frame", "The back strut, and the staff behind the post"],
        ["The post's top", "The highest made thing on the mountain that you can stand on", "The head of the peak's back, which the post is footed in"],
        ["The belt", "The First Top Dog's belt, on the post since the ring was built", "The sky, and the place where the town's two lines of paper meet"],
    ],
    "pieces": [
        ["The belt on two bronze pegs", "belt 1.2 m by 0.6 m; pegs 0.5 m", "1", "Play space", "kit: the belt on the post (champion_belt); the pegs are new"],
        ["Bell frame: post, beam, brace", "post 0.5 m thick, 6.6 m tall; beam 6.8 m", "1", "Play space", "kit: bell frame"],
        ["Marigold garland, pressed flat on timber", "6.5 m", "1", "Play space (drawn on)", "kit: marigold garland"],
        ["Back strut for the frame", "0.3 m thick, 4.9 m long", "1", "Background", "the back strut in the kit below"],
        ["Bell staff", "8.2 m", "1", "Background", "the bell staff in the kit below"],
        ["Line of paper on thick rope", "30 m and 23 m", "2", "Background", "kit: line of paper (papel_string)"],
        ["The peak's own back", "to suit", "1", "Background", "kit: behind everything"],
        ["Snow cap", "about 35 m by 30 m", "1", "Foreground", "kit: the summit's body (snow cap), there today"],
    ],
    "effects": [
        "The bell behind you is still rocking, and tolls softly once as you step off it.",
        "Gold dust. The paper overhead lifts toward the east.",
        "The belt's plates catch the low sun as you come level with them. That is colour on the plates, not a glow.",
    ],
    "notes": [
        "Note 101: touching the belt starts the ceremony. It is designed on the next page. What you do to reach the belt does not change.",
        "Note 102: the way west to the frogs' spring is past the belt. You see its steam from the beam, and its sign hangs on the frame's back strut.",
        "The garland along the beam hangs 0.4 m in front of the timber today, in the play space, 0.5 m thick. It is pressed flat onto the beam's front face.",
        "The belt's model floats 0.5 m above the post's top today. It stays where it is and gets two bronze pegs to stand on.",
        "Nothing you touch moves.",
    ],
}

# ------------------------------------------------------------------ 11.6b The ceremony of the belt
_RAY_C = (-360.3, 1013.4)   # his chest, at the top of the rise
_RAYS = [(15, 30, 3.0), (58, 18, 1.5), (100, 24, 2.5), (142, 14, 1.2), (192, 28, 3.0), (236, 16, 1.5), (282, 22, 2.0), (328, 12, 1.0)]   # degrees, length, width at the far end


def _ray(deg, length, width):
    a = math.radians(deg)
    d = math.atan2(width / 2, length)
    return _p([(_RAY_C[0] + 1.3 * math.cos(a), _RAY_C[1] + 1.3 * math.sin(a)),
               (_RAY_C[0] + length * math.cos(a - d), _RAY_C[1] + length * math.sin(a - d)),
               (_RAY_C[0] + length * math.cos(a + d), _RAY_C[1] + length * math.sin(a + d))], "pale")


LA_CEREMONIA = {
    "id": "11.6b", "slug": "11_6b_the_ceremony", "title": "The ending: the ceremony of the belt", "kind": "rest",
    "window": [-378.0, 994.0, -342.0, 1022.0], "cut_y": 1013.0, "climber": [-360.3, 1012.4],
    "place": ("The top of the bell frame's post, at the moment your hand touches the belt. The climb is over and nothing more is asked of "
              "you. A ceremony plays on your climber. The belt comes off its pegs into your hands, and you lift it over your head with "
              "both arms. Holding it up, you turn slowly on the spot and rise off the post, 6 m into the air above the summit. Long flat "
              "rays fan out behind you and wheel round as you turn, in cream, yellow and the colours of the town's paper. An orchestra "
              "plays the mountain's four-note call, resolved at last, with the summit's mariachi and the bell in it, and the bell tolls "
              "three times on its own. Far below in the east the town's fireworks come up through the cloud. Then the TOP DOG card with "
              "your time and your falls, the confetti, and the wait for a button, as today. And then the game goes on: the button lifts "
              "the card and sets you down on the post's top with the clock stopped. West of you the steam stands up out of the notch, "
              "and the frogs' spring is a step off the end of the beam."),
    "keep": [
        "Touching the belt ends the climb, exactly as today. The ceremony asks for no button and no hold.",
        "After it: the TOP DOG card with your time and your falls, the confetti, the wait for a button, and your flag on the Peak behind the title screen.",
        "Then the button sets you down on the post's top, with your time kept and the clock stopped, free to go west to the frogs' spring (note 102).",
        "The three tolls of the bell at the finish.",
        "No glowing material anywhere. The rays are flat colour.",
    ],
    "background": [
        {"name": "The rays", "z": [-1.6, -1.5], "style": "pale", "tag": [-345.5, 1016.6], "top": True,
         "text": "Eight flat cut-out blades, each 12 to 30 m long and 1 to 3 m wide at its far end, fanned out from your climber's chest "
                 "and standing 1.5 m behind you. They are cream, yellow, and five of the town's paper colours, with the kit's inked cut "
                 "edge, bright against the sky. They open one after another as you leave the post, and they wheel round as you turn, the "
                 "same way and at the same speed. They pass behind the frame, the bell and the dome, and in front of the paper and the staff.",
         "draw": [_ray(*q) for q in _RAYS]},
        {"name": "The peak's own back", "z": [-3.4, -3.0], "tag": [-361.0, 996.6],
         "text": "The head of the mountain behind the frame, and its west flank rising away at the left edge. In the wide frame of the "
                 "ceremony it is small. The sky and the far view fill the rest.",
         "draw": [_p([(-357.18, 994.0), (-358.0, 1000.8), (-362.6, 1000.8), (-364.96, 994.0)]), _p([(-373.8, 994.0), (-378.0, 995.62), (-378.0, 994.0)])]},
        {"name": "The bell staff and the two lines of paper", "z": [-2.1, -1.3], "style": "mark", "tag": [-369.6, 1008.0],
         "text": "The staff's top is 1.2 m under your feet when you have risen. The two lines of paper fall away from it to the east and to "
                 "the west, so you hang over the place where they meet. Every paper lifts and flutters while the orchestra plays.",
         "draw": [_ln(-360.3, 1006.4, -360.3, 1011.2, "line")] + _leap_line() + _west_line()},
        {"name": "The town's fireworks", "z": [-8.0, -7.0], "style": "light", "tag": [-345.6, 1000.9],
         "text": "Far away in the east and far below, small cut-out bursts come up through the sea of cloud, a few at a time, in the "
                 "town's colours. The town is under the cloud and can't be seen from here. This is how you know that it saw you. They are "
                 "the far town's own fireworks, and they stand far behind everything of ours.",
         "draw": [_c(-344.6, 997.4, 0.7), _c(-347.3, 998.7, 0.5), _c(-343.6, 999.6, 0.45), _c(-349.4, 996.6, 0.4)]},
    ],
    "play": [
        {"name": "Your climber, turning, with the belt held up", "z": [-0.3, 0.3], "style": "pale", "tag": [-358.3, 1014.9], "top": True,
         "text": "Your climber is the game's climber model, posed: nothing bespoke is modelled, and the new climber model takes its place when "
                 "it comes. The belt is held by a hand on each strap end, its plates toward the camera, lifted right over the head. The climber turns "
                 "slowly on the spot, to the left, once in about 4 seconds, and rises 6 m in a straight line from the post's top. At the "
                 "top of the rise the climber stays there, still turning. The dashed line is the rise.",
         "draw": [_r(-360.9, 1014.55, -359.7, 1015.15), _ln(-360.3, 1006.5, -360.3, 1012.3, "mark")]},
        {"name": "The empty pegs", "z": [-0.1, 0.1], "style": "line", "tag": [-362.1, 1006.6],
         "text": "The belt is one thing: when it comes into your hands it is gone from the post, and the two bronze pegs stand bare.",
         "draw": [_ln(-360.5, 1006.4, -360.5, 1006.9), _ln(-360.1, 1006.4, -360.1, 1006.9)]},
        {"name": "The bell, tolling on its own", "z": [-1.1, 1.1], "tag": [-353.4, 1003.4],
         "text": "The bell swings itself for the three tolls, clapper showing, with nobody on the rope. The rope sways under it.",
         "draw": _BELL + [_ln(-355.7, 1005.3, -356.5, 1002.3, "mark"), _ln(-355.7, 1005.3, -354.9, 1002.3, "mark")]},
    ],
    "foreground": [
        {"name": "The TOP DOG card and the confetti", "z": [3.0, 3.2], "style": "mark", "tag": [-366.5, 1019.2],
         "text": "After the ceremony the card drops in front of everything, with your time and your falls, and the confetti falls, as "
                 "today. Behind the card your climber is still in the air, turning, with the rays wheeling. Nothing stands in front of "
                 "the climber until then.",
         "draw": [_r(-368.0, 1016.6, -352.6, 1021.4)]},
    ],
    "explains": [
        ["The belt", "The First Top Dog's belt, taken at last", "The rays, which start at the one who holds it"],
        ["The post's top", "The place you leave the mountain from", "The staff and the paper under your feet, and the bell tolling beside you"],
    ],
    "pieces": [
        ["The belt, held", "1.2 m by 0.6 m", "1", "Play space", "kit: the belt on the post; the belt held"],
        ["The climber's ceremony moves: take, lift, turn and rise", "a rise of 6 m; one turn in about 4 seconds", "1 set", "Play space", "new: poses of the game's climber model, in the climber's own code, which the party game shares (note 101); nothing modelled until the new climber model is here"],
        ["Ceremony ray", "12 to 30 m long, 1 to 3 m wide at the far end", "8", "Background", "kit: ceremony rays"],
        ["The ceremonious orchestra", "music, no model", "1 piece", "All", "kit: the ceremonious orchestra"],
        ["The bell tolling on its own", "as on La Campana's page", "3 tolls", "Play space", "kit: the bell, its clapper, its iron yoke"],
        ["Fireworks: small cut-out bursts", "2 to 3 m across as seen from here", "a few at a time", "Background, far", "kit: the rest of the ending (the far town's fireworks)"],
        ["TOP DOG card; confetti; the flag on the Peak", "the card as the kit's", "1 of each", "Foreground; the flag on the title screen", "kit: the rest of the ending (peak_summit_card, flag_top_dog, the house confetti)"],
        ["Bell staff; lines of paper", "8.2 m; 30 m and 23 m", "1 and 2", "Background", "the bell staff in the kit below; kit: line of paper"],
    ],
    "effects": [
        "The camera pulls back as you rise, to the width it has for the last leap, and centres 4 m above the post, so the whole fan of rays is on screen.",
        "Marigold petals lift off the frame and go up with you.",
        "Gold dust thickens round the climber. It is dust, not a glow.",
        "Every line of paper on the summit lifts and flutters while the orchestra plays.",
    ],
    "notes": [
        "Note 101: the ending is a ceremony played on the climber. Today nothing happens to the climber: the bell tolls three times with a short fanfare, the card drops in and the belt stays on the post.",
        "A first try at the order, about 10 seconds in all, which is the length the note's plan gives. At once: the first toll, the orchestra starts, and the belt comes off its pegs into both hands. By 1.5 seconds: the belt is over your head. From 1.5 to 9 seconds: you turn and rise 6 m, the rays open and wheel, the second and third tolls come, and the fireworks begin. At 10 seconds: the card and the confetti, with the climber still turning behind them. How long it runs and whether a button skips it are settled when it is built, as the sheet says.",
        "Note 100: the three tolls at the belt stay as the finish. In the design the bell is seen to make them.",
        "The area's own sun and its pale sky card stay out. The rays are seen against the far view's sky.",
        "Parker: a new climber model is coming very soon. The ceremony is the game's climber model, posed.",
        "Note 102 and the order of things. Touching the belt ends the run with the TOP DOG card, so for the frogs' spring to be the reward past the belt, the game goes on after the card: the button puts you back on the post and you can walk west. Your time is the time to the belt. The other way, taking the way west before the belt, would put the reward before the ending.",
        "Nothing you touch moves. The box round the belt that ends the climb is as it is today.",
    ],
    "ask": [
        "After the TOP DOG card the game goes on, and the button sets you down on the post so you can walk west to the frogs' spring. Keep it that way: yes or no?",
    ],
}

# ------------------------------------------------------------------ 11.0 The frogs' hot spring (west of the belt)
# Its numbers, in the course's metres. The shoulder's slope today runs from (-390.2, 996) to (-372, 982) and on to (-349, 966).
_EAVE = [(-365.2, 987.0), (-369.6, 983.0), (-369.6, 982.6), (-366.5, 982.6)]      # the face's last 4.4 m, turned out west
_SINK = [(-372.9, 982.69), (-371.4, 981.4), (-371.4, 974.0), (-368.4, 974.0), (-368.4, 978.3)]
_DOOR = (-368.4, 977.9, -366.5, 978.3)                                             # the doorstep, cut level at 978.3 m
_FROST = [(-366.5, 978.3), (-365.6, 977.67), (-365.6, 981.97), (-366.5, 982.6)]    # under the dome's west corner
_CAVE = [(-379.6, 968.6), (-377.4, 968.6), (-377.4, 969.8), (-368.2, 969.8), (-368.2, 971.0), (-364.0, 971.0), (-364.0, 973.2), (-365.2, 974.0),
         (-371.4, 974.0), (-374.2, 974.9), (-377.2, 974.8), (-379.0, 974.1), (-379.6, 973.0)]
_WARM = [(-380.6, 966.8), (-363.0, 966.8), (-363.0, 974.4), (-364.6, 975.2), (-367.4, 975.2), (-367.4, 977.5), (-368.4, 978.2), (-372.9, 982.6),
         (-373.6, 982.2), (-372.4, 980.6), (-372.4, 975.6), (-376.0, 975.9), (-379.2, 975.3), (-380.6, 973.8)]
_TUBE = [(-379.6, 970.9), (-377.4, 970.9), (-377.4, 968.4), (-375.5, 966.5), (-375.5, 964.2), (-377.0, 962.0), (-379.2, 962.0), (-377.5, 964.6), (-377.5, 965.7), (-379.6, 967.8)]
_STEAM = [(-372.9, 982.7), (-369.8, 980.6), (-368.4, 992.0), (-366.4, 1001.0), (-365.4, 1008.6), (-368.8, 1009.0), (-370.4, 1001.0), (-372.6, 992.0)]
_WAY_DOWN = [(-361.6, 1005.7), (-362.0, 1004.0), (-362.15, 997.3), (-365.2, 987.0), (-369.6, 983.0), (-370.2, 978.0), (-370.4, 970.6)]
_SPRING_FROGS = ([(round(-376.4 + 0.95 * k, 2), 970.75) for k in range(9)] + [(round(-375.6 + 0.9 * k, 2), 972.75) for k in range(7)] +
                 [(-367.6, 971.15), (-366.9, 971.15), (-364.6, 971.15)])

EL_MANANTIAL = {
    "id": "11.0", "slug": "11_0_the_frogs_spring", "title": "The frogs' hot spring: west of the belt", "kind": "rest",
    "window": [-382.0, 966.5, -352.0, 1009.5], "screen": [-371.8, 972.0], "cut_y": 971.2, "climber": [-366.0, 971.0],
    "place": ("The reward for the climb. West of the bell frame the summit falls away into a notch between its west face and the shoulder, "
              "and a column of steam stands up out of the notch, leaning east at its top, in plain view from the beam. Under the notch the "
              "mountain is warm. A hot spring rises in a cave of ochre rock inside the shoulder, and its breath comes up a round shaft, the "
              "sink, which opens in the notch's floor. Whoever has the belt can step off the west end of the bell frame's beam: the west face "
              "takes them down, its eave turns them off over the sink, and they drop into a warm pool full of frogs, by candle light. The "
              "frogs have kept the place to themselves. It is cozy and nothing in it can hurt you: there is a bank to sit on, a low table "
              "with a pot and cups, folded towels. There are two ways on. On the far left, over a low rim wreathed in marigolds, is the "
              "spring's overflow: a water slide that carries you down inside the mountain to the long fall line, and so all the way down to "
              "the Sump, the celebratory drop. Or climb the frogs' stair, a rope up the side of the sink, to a doorstep under the eave and a "
              "wall of frost. Break the frost, and behind it is the tunnel under the dome, the teahouse chute, which slides you east and puts "
              "you out at the tea shop."),
    "keep": [
        "The tunnel under the dome as it is, from the frost wall east and down to the tea ledge.",
        "The bell frame, its beam's west end and the summit's apex.",
        "The shoulder's slope west of the sink: a body that lands on it slides east into the sink.",
        "Everything else on this page is new (note 102).",
    ],
    "background": [
        {"name": "The steam column", "z": [-2.4, -2.2], "style": "pale", "tag": [-367.6, 1004.6],
         "text": "Thick white steam, 3 m wide, standing up out of the sink 2.2 m behind the climb, and leaning east at its top, where "
                 "the summit's slow west air takes it. It rises 26 m, to above the bell frame's beam, so it is in the frame of the close "
                 "camera at the post and at the bell. It is how you guess the place is there. It is always behind the climb, never in "
                 "front of it.",
         "draw": [_p(_STEAM)]},
        {"name": "The peak's back above the shoulder, the staff and the paper", "z": [-3.4, -1.2], "style": "line", "tag": [-379.4, 1001.2],
         "text": "The peak's own back, 3 m behind, tan, one painted piece with long wavy bedding lines, ending in an uneven skyline. A "
                 "little outcrop on it carries a cushion of pink-flowered moss and a tuft of gold grass. A flagstaff stands on it above "
                 "the shoulder, and the town's paper runs to it from the bell staff, over the notch and the steam, 2 m behind the climb. "
                 "The line that was there today ends in the air. Now it goes somewhere.",
         "draw": [_ln(-382.0, 996.85, -366.0, 991.0, "line"), _ln(-366.0, 991.0, -362.6, 1000.8, "line"),
                  _ln(-382.0, 993.0, -370.0, 990.0, "mark"), _ln(-381.0, 989.0, -371.0, 986.6, "mark"),
                  _ln(-381.9, 997.2, -381.9, 1002.65, "line")] + _plant(-376.6, 995.4) + _west_line()},
        {"name": "The frog's sign on the back strut", "z": [-1.6, -1.5], "style": "pale", "tag": [-363.2, 1002.0],
         "text": "A painted board 0.7 m square on the bell frame's back strut, under the beam's west end: a frog in a pool under a curl "
                 "of steam, and no words. It is the tea shop's sign's fellow, and it faces you as you walk the beam to the belt.",
         "draw": _STRUT + [_r(-361.95, 1001.65, -361.25, 1002.35)]},
        {"name": "Warm rock round the cave and the sink", "z": [-3.0, -1.2], "tag": [-380.0, 967.6], "over": True,
         "text": "The shoulder's black ice is a skin. Under it, round the spring, the mountain's rock is warm and bare: ochre and cream, "
                 "crusted with pale mineral, painted in long wavy bands like every mass up here. Where the cave and the sink are cut "
                 "away to the camera you see the skin of ice outside and a band of warm rock about 1 m thick inside it.",
         "draw": [_p(_WARM)]},
        {"name": "The spring's cave", "z": [-3.0, -1.2], "style": "dark", "tag": [-374.6, 973.9], "over": True, "top": True,
         "text": "A cave inside the shoulder, under the notch: 15.6 m wide and 3 to 4 m tall, with its back wall 3 m behind you and its "
                 "front cut away. Its walls and roof above the steam are dark and wet, and can't be held. Along the back wall, 2 m above "
                 "the water, runs a ledge 6 m long for frogs. A painted board over the slide's mouth shows a frog on a slide. A rill "
                 "leaves by a crack in the east wall: it goes down to the spout in the tea shop's wall.",
         "draw": [_p(_CAVE), _ln(-376.0, 972.6, -370.0, 972.6, "line"), _r(-379.1, 972.9, -378.5, 973.5, "pale"), _r(-364.0, 971.0, -363.6, 971.4)]},
        {"name": "The sink", "z": [-1.5, -1.2], "style": "dark", "tag": [-370.6, 975.4], "over": True,
         "text": "A round hole 4.5 m across in the notch's floor, and the shaft under it, 3 m across, of smooth wet warm rock. It is 4.3 m "
                 "deep on its east side, under the doorstep, and 8.7 m on its west. It opens in the cave's roof over the deep end of the "
                 "pool. It is cut away to the camera, so you see yourself go down it. Its steam is the column above.",
         "draw": [_p(_SINK)]},
        {"name": "The water slide", "z": [-1.5, -1.2], "style": "dark", "tag": [-376.6, 963.4], "over": True,
         "text": "The spring's overflow, at the pool's far west end: a smooth wet tube 2 m across with warm water running down it. It "
                 "drops from its mouth, bends east under the pool, and goes on down into the mountain. It leaves this biome's region "
                 "through its floor, at 962 m, between x -379.2 and x -377. Where it comes out is for the storm ridge's and the glacier's "
                 "designs: the sheet proposes a steaming spout over the gap at the top of the glacier, at about 886 m.",
         "draw": [_p(_TUBE)]},
        {"name": "The pool's back half, and the frogs", "z": [-3.0, -1.3], "style": "pale", "tag": [-372.2, 970.0], "over": True, "top": True,
         "text": "The pool runs back 3 m behind you, milky blue-green, under thick white steam. About thirty frogs are here, all the same "
                 "little frog as every biome's: in the water to their eyes, along the back rim, on the back wall's ledge, and on the back "
                 "of the bank. A few have brought what their own biome's frog has: a teacup, a blanket, a ticket. They watch you drop in, "
                 "and then they go back to sitting. Now and then one goes over the rim and down the slide on a tea tray. Every one of them "
                 "is 1.3 m or more behind you.",
         "draw": [_r(-377.0, 969.8, -368.2, 970.6)] + [_c(x, y, 0.13, "dark" if y < 971 else "pale") for x, y in _SPRING_FROGS]},
        {"name": "The lanterns, the low table, the towels", "z": [-2.8, -1.4], "style": "light", "tag": [-365.6, 972.4], "over": True,
         "text": "Three candle lanterns hung from the roof at the back. They and the daylight down the sink are the cave's light, shown "
                 "as amber on the steam and the walls. At the back of the bank, 1.4 m behind you: a low table with the tea cave's pot and "
                 "two cups, one of them set out for you, and a pile of folded towels.",
         "draw": [_c(-377.0, 973.9, 0.17), _c(-373.8, 974.3, 0.17), _c(-365.6, 973.4, 0.17),
                  _r(-366.6, 971.0, -365.2, 971.45, "pale"), _c(-366.2, 971.6, 0.12), _r(-364.8, 971.0, -364.2, 971.5, "pale")]},
    ],
    "play": [
        {"name": "The way down from the beam", "z": [-1.2, 1.2], "style": "mark", "tag": [-360.4, 996.0],
         "text": "After the TOP DOG card you are on the post's top (see the ceremony's page). Step down to the beam's west end and off it. "
                 "You drop about 8 m onto the summit's west face, slide 17 m down it, are turned off the eave's lip over the sink, and "
                 "fall 12 m down the sink into the deep end of the pool. There is nothing to catch and nothing to miss: from the beam's "
                 "end every way down goes into the water.",
         "draw": [_ln(_WAY_DOWN[k][0], _WAY_DOWN[k][1], _WAY_DOWN[k + 1][0], _WAY_DOWN[k + 1][1]) for k in range(len(_WAY_DOWN) - 1)]},
        {"name": "The summit's west face and its eave", "z": [-1.2, 1.2], "style": "pale", "tag": [-367.0, 985.6],
         "text": "Black ice, one painted piece with the dome: a few big planes, long wavy bands of blue-black, white glints. Its last "
                 "4.4 m is turned out 3.1 m to the west as an eave, 42 degrees steep, whose lip is over the sink. It turns a sliding body "
                 "off over the sink and clear of the doorstep, and it roofs the doorstep and the frost wall. It can't be held.",
         "draw": [_p(_EAVE), _ln(-362.6, 995.2, -364.4, 989.4, "mark"), _ln(-365.9, 986.0, -368.6, 983.6, "mark")]},
        {"name": "The frogs' stair", "z": [-0.3, 0.3], "style": "line", "tag": [-369.9, 976.3],
         "text": "A real little climb in the summit's own kit. From the bank, take the wooden toll handle of a hemp rope hanging down the "
                 "sink's east side: the bell rope's kind. Climb the rope 4.5 m to the iron ring it hangs from, the summit's kind, set in "
                 "the shaft's wall. Then pull up 0.9 m onto the doorstep. From the bank to the doorstep is 7.3 m. A body falling down the "
                 "sink can catch the rope too, and then it is already on the stair.",
         "draw": [_c(-368.75, 977.4, 0.3), _ln(-368.75, 977.1, -368.75, 973.1), _r(-369.0, 972.9, -368.5, 973.1, "pale")]},
        {"name": "The doorstep", "z": [-1.2, 1.2], "style": "line", "tag": [-367.4, 979.4],
         "text": "Warm dry summit rock, 1.9 m wide, cut level into the slope at 978.3 m, under the eave, with 4.3 m of headroom. You stand "
                 "on it to take the frost wall. Two frog prints are worn into it.",
         "draw": [_outline(*_DOOR, pad=0.08), _p([(-368.4, 978.3), (-366.5, 978.3), (-368.4, 979.5)], "dark")]},
        {"name": "The frost wall", "z": [-1.2, 1.2], "style": "pale", "tag": [-364.6, 980.4], "top": True,
         "text": "Hoarfrost across the top of the tunnel, 0.9 m thick and about 4.3 m tall, under the dome's west corner: the place of "
                 "the arrow in note 102. It has the rime's look: grey-white and matte, cracked across, with a corner gone at its foot, "
                 "which is the tea frog's own door. From the spring's side: take it, it holds for 3 seconds, ticks, sheds frost dust and "
                 "its crack opens, then it breaks away in pieces that go sliding down the tunnel ahead of you. Step through and slide. "
                 "From the tunnel's side the pieces come sliding out onto the tea ledge, with a breath of steam. Twelve seconds later the "
                 "wall has grown back from its edges, and the door is shut.",
         "draw": [_p(_FROST), _ln(-366.2, 981.6, -365.9, 979.6, "mark"), _p([(-366.5, 978.3), (-366.15, 978.06), (-366.5, 978.75)], "dark")]},
        {"name": "The pool, the bank and the rim stones", "z": [-1.2, 1.2], "style": "line", "tag": [-366.0, 969.6],
         "text": "The pool is 8.8 m wide and 0.8 m deep, and you land in its deep end, under the sink. At its east end three rounded rim "
                 "stones, and then 4.2 m of dry bank: pale mineral crust, the place to climb out and sit. Bank and stones can be held. "
                 "Nothing in the cave can hurt you.",
         "draw": [_ln(-377.0, 970.6, -368.2, 970.6), _c(-368.0, 971.15, 0.3), _c(-367.45, 971.2, 0.26), _c(-366.95, 971.15, 0.24), _ln(-368.2, 971.0, -364.0, 971.0)]},
        {"name": "The slide's rim and its marigolds", "z": [-1.2, 1.2], "style": "pale", "tag": [-378.6, 972.0],
         "text": "At the pool's far west end a low rim of rounded stone stands 0.3 m out of the water, and the slide's mouth is behind "
                 "it, 2.2 m wide, wreathed in the town's marigolds. You go over the rim on purpose: the slide is a choice, not a current "
                 "that takes you. The rim can be held and stood on, and from its top the slide is a step down.",
         "draw": [_r(-377.4, 969.8, -377.0, 970.9), _c(-379.4, 971.2, 0.2, "light"), _c(-378.5, 971.35, 0.2, "light"), _c(-377.6, 971.2, 0.2, "light")]},
        {"name": "The teahouse chute", "z": [-1.2, 1.2], "style": "mark", "tag": [-357.6, 973.6],
         "text": "Behind the frost wall: the tunnel under the dome, as it is today. Black ice, 3.6 m across, 21 m long. It slides you "
                 "east and puts you out at the west end of the tea ledge, 1 m above its floor, by the tea shop. It is drawn on the tea "
                 "shop's page.",
         "draw": [_ln(-365.6, 977.67, -352.0, 968.08), _t(-363.4, 976.7, "to the tea shop")]},
    ],
    "foreground": [
        {"name": "The shoulder's snow cap, cut back", "z": [2.0, 2.05], "tag": [-380.9, 980.4],
         "text": "Today one white card covers the whole face of the shoulder from 963 m up, 2 m in front. It would hide the cave, the "
                 "sink and the stair. What is left stands in front of solid ice only: set 1.3 m back from the slope, west of x -375.2 and "
                 "above 976.4 m, and west of x -380.6 below that.",
         "draw": [_p([(-382.0, 988.4), (-375.2, 983.2), (-375.2, 976.4), (-380.6, 976.4), (-380.6, 966.5), (-382.0, 966.5)])]},
        {"name": "The dome's snow cap (there today)", "z": [2.0, 2.05], "tag": [-356.4, 982.8],
         "text": "The white cap on the dome's back and the summit's west face, in front of solid ice. Its foot is 2 m above the frost wall "
                 "and it covers nothing you touch. It stays.",
         "draw": [_p([(-352.0, 983.78), (-358.9, 988.6), (-359.6, 999.2), (-360.3, 999.8), (-361.0, 999.0), (-365.3, 984.6), (-352.0, 974.32)])]},
    ],
    "explains": [
        ["The west face and its eave", "The summit's last slope, which takes whoever steps off the beam down to the notch", "The steam column standing up beside it, and the paper going west over it"],
        ["The sink", "The spring's breath-hole, worn round by warm air and water", "The steam column above it"],
        ["The pool", "The frogs' hot spring", "Its back half, 3 m into the scene, full of frogs"],
        ["The bank and the rim stones", "Mineral crust that the spring has laid down, where the frogs climb out", "The low table, the towels, the lanterns"],
        ["The rim and the slide", "The spring's overflow: where the water leaves the cave", "The wet tube going down into the mountain, and the frog-on-a-slide board"],
        ["The rope, the ring and the doorstep", "The frogs' stair: how the tea frog goes to work", "The shaft's wall, and the frost wall over the doorstep"],
        ["The frost wall", "Hoarfrost grown across the tunnel's top where the spring's breath meets the tunnel's cold", "The tunnel behind it, going down to the tea shop"],
    ],
    "pieces": [
        ["The eave on the summit's west face", "4.4 m of face turned out 3.1 m", "1", "Play space", "kit: the eave"],
        ["The sink: mouth and shaft", "mouth 4.5 m; shaft 3 m across, 4.3 to 8.7 m deep", "1", "Play space, cut away at the front", "kit: the sink"],
        ["Spring cave: floor, back wall and roof in warm painted rock, with a back ledge and a crack in the east wall", "15.6 m wide, 3 to 4 m tall, back wall 3 m behind", "1", "Play space and background, cut away at the front", "kit: the frogs' hot spring"],
        ["Pool of warm water; steam", "8.8 m wide, 0.8 m deep", "1", "Play space and background", "kit: the frogs' hot spring; the water is the game's"],
        ["Rim stone; dry bank of mineral crust", "stones 0.5 m; bank 4.2 m", "3 and 1", "Play space", "kit: the frogs' hot spring"],
        ["Hemp rope with a wooden toll handle; iron ring; doorstep", "rope 4.5 m; ring 0.52 m; step 1.9 m", "1 of each", "Play space", "kit: the frogs' stair"],
        ["Frost wall: whole, breaking, and growing back", "0.9 m thick, about 4.3 m tall", "1", "Play space", "kit: frost wall"],
        ["The frog", "0.3 m", "about 30", "Background", "kit: the frogs of the spring"],
        ["Teacup, blanket, ticket, tea tray and other small things the frogs brought", "small", "about 6", "Background", "kit: the frogs of the spring; each is its own biome's piece"],
        ["Low table, pot and two cups, folded towels", "table 1.4 m", "1 set", "Background", "kit: the frogs' hot spring; pot and cups are the tea cave's"],
        ["Candle lantern, hung", "0.4 m", "3", "Background", "kit: the frogs' hot spring (lantern_hang)"],
        ["Water slide: tube, stone rim, marigold wreath", "2 m across; rim 0.3 m high", "1", "Play space, cut away at the front", "kit: water slide"],
        ["Painted signs: a frog in a pool; a frog on a slide", "0.7 m square", "2", "Background", "kit: the frog's sign for the spring"],
        ["Steam column", "3 m wide, 26 m tall", "1", "Background", "kit: gold dust, blown snow, steam (an effect)"],
        ["Band of warm rock for the cut edge of the shoulder", "about 1 m thick, round the cave and the sink", "1", "Background", "new, this area only"],
        ["Flagstaff on the peak's back; line of paper", "5.5 m; 23 m", "1 and 1", "Background", "kit: line of paper"],
        ["Summit plant on a little outcrop", "0.3 to 0.6 m", "1", "Background", "kit: the summit's plants"],
        ["Snow cap for the shoulder, cut back", "about 7 m by 22 m in this window", "1", "Foreground", "kit: the summit's body (snow cap), re-cut"],
    ],
    "effects": [
        "The steam column, always: thick at the sink, thinning upward, leaning east at the top. It is there from the first time you look west from the bell.",
        "Thick white steam over the pool, thinning toward the roof. The frogs' eyes show through it.",
        "Many croaks at once, heard faintly from the beam's west end, and loudly as you fall.",
        "A ring of ripples where you land. The nearest frogs bob on it.",
        "When the frost wall breaks, the cold air from the tunnel makes the steam over the doorstep swirl for a moment.",
    ],
    "notes": [
        "Note 102, as Parker corrected it (11-13, late): you reach the spring by going west off the summit, past the belt. It is the reward for the climb, with the celebratory drop down the slide. From it you can slide, or climb to the breakable wall that leads to the teahouse chute. The first design, with the frost wall in the tunnel hiding the spring, is gone.",
        "When: after the TOP DOG card, the game goes on and you are set down on the post's top. That is the one open question, on the ceremony's page.",
        "The way there, in metres: from the beam's west end, x -361.6 at 1,005.7 m, a drop of about 8 m onto the summit's west face, a slide of 17 m down it, off the eave's lip at x -369.6, 983 m, and a fall of 12 m down the sink into the pool at 970.6 m.",
        "Course change, the eave: the dome block's west corner, today at (-366.5, 982.6), gets a lip. Its face runs from (-361.5, 999.5) to (-365.2, 987.0), then out to (-369.6, 983.0), down to (-369.6, 982.6) and back to (-366.5, 982.6). All black ice.",
        "Course change, the sink and the doorstep: a hole in the shoulder from x -372.9 (982.7 m) to x -368.4 at its surface, and a shaft 3 m wide, from x -371.4 to x -368.4, down to the cave's roof at 974 m. The doorstep is the shoulder cut level at 978.3 m from x -368.4 to x -366.5, in grip rock.",
        "Course change, the frost wall: a solid that breaks 3 seconds after it is taken and is back 12 seconds later, like all the summit's rime, from x -366.5 to x -365.6, from the tunnel's floor to its roof (978.3 to 982.6 m at its west face). It is the door between the doorstep and the tunnel, and it is broken from the doorstep.",
        "Course change, the stair: an iron ring at (-368.75, 977.4) with a rope 4.5 m long hanging from it, its toll handle at 972.9 m, 0.55 m west of the bank's edge.",
        "Course change, the cave: a room in the shoulder from x -379.6 to x -364.0, its roof at 974 to 974.9 m. A pool from x -377.0 to x -368.2, its surface at 970.6 m and its floor at 969.8 m; three rim stones; a bank from x -368.2 to x -364.0 at 971 m; a rim from x -377.4 to x -377.0, its top at 970.9 m.",
        "Course change, the slide: a tube 2 m across from a mouth at x -379.6 to x -377.4. It leaves the region through its floor at 962 m, between x -379.2 and x -377.0. Today the course has nothing under the shoulder below 962 m west of x -362, so the mountain's body has to be carried down there for the slide to run in.",
        "What changes for a miss. The course's own comment: a body flung over the bell lands on the shoulder and is back at the area's start. Now that body slides into the sink and lands in the spring, and its way back is the stair and the frost wall, to the same tea ledge. So it costs the same as today. It is the one way into the spring that does not pass the belt, and it needs a throw clean over the very top.",
        "Everything stays inside the biome's region except the slide's lower end, and the snow cap's west part, which is outside it today.",
        "Note 60: the spring holds about thirty of the one frog. The tea frog goes to work through the corner of the frost wall and down the tunnel, and the spout in the tea shop's wall is this spring's water.",
        "Nothing else you touch moves: the tunnel, the dome and the bell frame are as they are.",
    ],
}

# ------------------------------------------------------------------ pieces more than one area uses, added to the summit's kit
KIT_MORE = [
    ["Bell staff: a second, taller flagstaff, lashed to the back of the bell frame's post and raked back", "8.2 m; its top at 1,011.2 m, 4.8 m above the post's top", "carries the far ends of the two long lines of paper, 2 m behind the climb, with their lowest flags 2.5 m over the beam and 4 m over the post's top. The flagstaff behind the west post's timber head is 6.3 m for the same reason", "Background", "new, the sheet's flagstaff made longer"],
    ["Back strut for the bell frame: a square timber from the post's back down to the head of the peak's back", "0.3 m thick, 4.9 m long", "behind the bell frame, so that a frame with one post is seen to be held", "Background", "new"],
    ["Rock step one layer back: the summit's rock carried on behind a place you stand, at the same height", "1 m deep; 2.9 to 4.2 m wide", "the fifth tooth's step behind the shelf, with the fallen post on it; the top of the rib behind the perch, with the marigolds on it", "Background", "new"],
]

AREAS = [SOBRE_LAS_NUBES, LA_CORONA, LAS_CUERDAS, EL_ULTIMO_SALTO, LA_CAMPANA, TOP_DOG, LA_CEREMONIA, EL_MANANTIAL]
