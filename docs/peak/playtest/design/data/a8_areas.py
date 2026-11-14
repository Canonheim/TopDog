# The cableway's areas, one dict each. Format: see ../build.py.
# Order: the route, bottom to top. The frog's parked gondola (8.0) comes after 8.1, because line 1 is how you reach it.
# The low station is the cliffs' join and the high station is the glacier's: 8.1 and 8.11 show only our end of each.
import math


# ------------------------------------------------------------------ shorthand
def _r(x0, y0, x1, y1, st=None):
    return ["rect", round(x0, 2), round(y0, 2), round(x1, 2), round(y1, 2)] + ([{"style": st}] if st else [])


def _ln(x0, y0, x1, y1, st=None):
    return ["line", round(x0, 2), round(y0, 2), round(x1, 2), round(y1, 2)] + ([{"style": st}] if st else [])


def _c(x, y, r, st=None):
    return ["circle", round(x, 2), round(y, 2), r] + ([{"style": st}] if st else [])


def _p(pts, st=None):
    return ["poly", [[round(q[0], 2), round(q[1], 2)] for q in pts]] + ([{"style": st}] if st else [])


# ------------------------------------------------------------------ the course's own numbers (tools/peak/areas/a8.py)
_VERT = 12.0 - math.hypot(6.0, 1.4)                      # the loops' upright runs: 5.84 m
D_LO, D_HI = (-234.4, 693.4), (-234.4, 693.4 + _VERT)    # line 1, the station end
E_LO, E_HI = (-228.4, 694.8), (-228.4, 694.8 + _VERT)    # line 1, pylon 1
W_LO, W_HI = (-216.4, 694.8), (-216.4, 694.8 + _VERT)    # line 2, its west tower
E2_HI = (-210.4, W_HI[1] + 1.4)                          # line 2, its east tower
E2_LO = (-210.4, E2_HI[1] - _VERT)
CHAIRS = [(-188.5, 716.5), (-184.6, 713.9), (-180.7, 711.3), (-176.8, 708.7)]
EX_SLOPE = 22.5 / 47.5                                   # the express lines climb west
EX_E = [(-218.5, 752.1 + 5.1 * k) for k in range(4)]     # their east stops (the cable grip)
EX_W = [(-266.0, 774.6 + 5.1 * k) for k in range(4)]     # their west stops
ZIP_END = (-193.0, 723.0)                                # where the zip line ends after note 82
_FACE = [(-251.0, 684.0), (-256.6, 704.0), (-263.6, 727.0), (-270.8, 752.0), (-281.0, 784.0)]
_KNOBS = [(-174.83, 708.28), (-175.17, 710.08), (-175.51, 711.88), (-175.85, 713.68), (-176.15, 714.95), (-175.43, 716.36),
          (-174.48, 717.8), (-173.09, 718.94), (-171.7, 720.09), (-170.31, 721.23), (-168.93, 722.38), (-167.54, 723.53), (-166.23, 724.61)]
_HORN = [(-175.2, 716.6), (-174.0, 719.6), (-171.0, 722.6), (-168.0, 725.4), (-166.2, 727.4), (-164.6, 727.6), (-163.0, 725.4),
         (-161.2, 720.0), (-159.6, 711.0), (-157.9, 697.0), (-166.0, 697.0), (-166.0, 716.0)]


# ------------------------------------------------------------------ shared shapes
def _tower(xw, xe, y0, y1, bay=4.0):
    """A lattice tower the way the course's cards draw it: two legs and a zigzag of braces."""
    out = [_r(xw - 0.15, y0, xw + 0.15, y1), _r(xe - 0.15, y0, xe + 0.15, y1)]
    y, flip = y0, False
    while y < y1 - 0.5:
        yt = min(y + bay, y1)
        a, b = ((xw, y), (xe, yt)) if flip else ((xe, y), (xw, yt))
        out.append(_ln(a[0], a[1], b[0], b[1], "line"))
        y, flip = yt, not flip
    return out


def _girder(x0, x1, y0, y1, bay=2.0):
    """A lattice bay laid level."""
    out = [_r(x0, y0, x1, y0 + 0.14), _r(x0, y1 - 0.14, x1, y1)]
    x, flip = x0, False
    while x < x1 - 0.3:
        xt = min(x + bay, x1)
        out.append(_ln(x, y1 if flip else y0, xt, y0 if flip else y1, "line"))
        x, flip = xt, not flip
    return out


def _wheel(cx, cy, r, n=3, turn=0.3):
    """A scenery wheel seen face on: rim and spokes."""
    out = [_c(cx, cy, r, "line")]
    for i in range(n):
        a = turn + math.pi * i / n
        out.append(_ln(cx - r * math.cos(a), cy - r * math.sin(a), cx + r * math.cos(a), cy + r * math.sin(a), "line"))
    return out


def _engine(cx, cy, foot):
    """A wind engine: a cup wheel 5 m across on a mast."""
    out = [_r(cx - 0.12, foot, cx + 0.12, cy, "pale"), _c(cx, cy, 2.5, "line"), _c(cx, cy, 0.3, "pale")]
    for k in range(3):
        a = math.radians(105 + 120 * k)
        ex, ey = cx + 2.1 * math.cos(a), cy + 2.1 * math.sin(a)
        out += [_ln(cx, cy, ex, ey, "line"), _c(ex, ey, 0.42, "pale")]
    return out


def _belt(x0, y0, x1, y1, crossed=False, w=0.3):
    """A drive belt: two lines, crossed or not."""
    if crossed:
        return [_ln(x0 - w, y0, x1 + w, y1, "line"), _ln(x0 + w, y0, x1 - w, y1, "line")]
    return [_ln(x0 - w, y0, x1 - w, y1, "line"), _ln(x0 + w, y0, x1 + w, y1, "line")]


def _hanger(g):
    """A car's hanger arm: from the cable down to the back of the roof, with its carriage on the cable."""
    return [_ln(g[0], g[1], g[0], g[1] - 1.43, "line"), _r(g[0] - 0.3, g[1] - 0.08, g[0] + 0.3, g[1] + 0.18, "pale")]


def _ends(g, step, rack):
    """A car's boarding step (west) and freight rack (east), at floor level."""
    return [_r(g[0] - 1.3 - step, g[1] - 3.8, g[0] - 1.3, g[1] - 3.6), _r(g[0] + 1.3, g[1] - 3.8, g[0] + 1.3 + rack, g[1] - 3.6)]


def _pennants(x0, y0, x1, y1, every=1.5):
    """A pennant line: every pennant blown east."""
    out = [_ln(x0, y0, x1, y1, "mark")]
    n = int(math.hypot(x1 - x0, y1 - y0) / every)
    for i in range(1, n):
        px, py = x0 + (x1 - x0) * i / n, y0 + (y1 - y0) * i / n
        out.append(_p([(px, py), (px + 0.5, py - 0.12), (px + 0.3, py - 0.6)], "pale"))
    return out


def _streamer(x, y, h=3.0):
    return [_r(x - 0.08, y, x + 0.08, y + h, "pale"), _p([(x, y + h), (x + 1.5, y + h - 0.25), (x, y + h - 0.5)], "pale")]


def _sock(x, y, h=1.6):
    return [_r(x - 0.06, y, x + 0.06, y + h, "pale"), _p([(x, y + h), (x + 1.5, y + h - 0.15), (x + 1.5, y + h - 0.4), (x, y + h - 0.6)], "pale")]


def _loop(a, b, c, d):
    """One loop of cable through four corners, with a guide wheel 1 m across at each."""
    pts = [a, b, c, d]
    out = [_ln(pts[i][0], pts[i][1], pts[(i + 1) % 4][0], pts[(i + 1) % 4][1], "line") for i in range(4)]
    return out + [_c(q[0], q[1], 0.5, "line") for q in pts]


# The far line: the cableway's dead second line, 20 m back. Three towers, two slack spans, two stopped cars, one stopped chair.
_FAR_T = [(-238.5, 708.0), (-212.0, 732.0), (-153.0, 746.0)]
_FAR_SAG = [2.5, 6.0]
_FAR_HUNG = [(-231.0, "chair"), (-222.0, "car"), (-178.0, "car")]


def _far_y(x):
    for i in range(2):
        (xa, ya), (xb, yb) = _FAR_T[i], _FAR_T[i + 1]
        if xa <= x <= xb:
            t = (x - xa) / (xb - xa)
            return ya + (yb - ya) * t - 4 * _FAR_SAG[i] * t * (1 - t)
    return None


def _far(win):
    """What of the far line falls in a window, drawn dashed because it is hazed."""
    x0, y0, x1, y1 = win
    out = []
    for tx, ty in _FAR_T:
        if tx + 2 > x0 and tx - 2 < x1 and ty > y0:
            lo = math.floor((y0 - 1) / 6.0) * 6.0
            out += [_ln(tx - 2, lo, tx - 2, ty, "mark"), _ln(tx + 2, lo, tx + 2, ty, "mark"), _ln(tx - 2.6, ty, tx + 2.6, ty, "mark")]
            y, flip = lo, False
            while y < ty - 0.5:
                yt = min(y + 6.0, ty)
                out.append(_ln(tx + (-2 if flip else 2), y, tx + (2 if flip else -2), yt, "mark"))
                y, flip = yt, not flip
    x = float(math.floor(x0))
    while x < x1:
        ya, yb = _far_y(x), _far_y(x + 2.0)
        if ya is not None and yb is not None and min(ya, yb) < y1 and max(ya, yb) > y0:
            out.append(_ln(x, ya, x + 2.0, yb, "mark"))
        x += 2.0
    for hx, what in _FAR_HUNG:
        hy = _far_y(hx)
        if not (x0 < hx < x1) or hy is None:
            continue
        if what == "car" and y0 < hy - 2.6 < y1:
            out += [_ln(hx, hy, hx, hy - 1.5, "mark"), _r(hx - 1.3, hy - 3.7, hx + 1.3, hy - 1.5, "mark")]
        if what == "chair" and y0 < hy - 3.2 < y1:
            out += [_ln(hx, hy, hx, hy - 3.1, "mark"), _r(hx - 0.6, hy - 3.33, hx + 0.6, hy - 3.08, "mark")]
    return out


def _face_x(y):
    for (xa, ya), (xb, yb) in zip(_FACE, _FACE[1:]):
        if y <= yb or (xb, yb) == _FACE[-1]:
            return xa + (xb - xa) * (y - ya) / (yb - ya)


def _shoulder(win):
    """The mountain's shoulder where it shows in a window: a card whose ragged east edge stands 7 m east of the face."""
    x0, y0, x1, y1 = win
    edge, y, i = [], y0 - 1.0, 0
    while y < y1 + 3.0:
        edge.append((_face_x(y) + 7.0 + (0.9 if i % 2 else -0.6), y))
        y, i = y + 3.0, i + 1
    return [_p([(x0 - 1.0, y0 - 1.0)] + edge + [(x0 - 1.0, y1 + 3.0)])]


_PYLON1 = _tower(-229.9, -226.9, 680.0, 708.0)
_L2W = _tower(-217.9, -214.9, 680.0, 708.0)
_L2E = _tower(-211.9, -208.9, 680.0, 712.0) + [_r(-212.6, 712.0, -206.9, 712.3)]
_LINK = _girder(-229.9, -214.9, 708.0, 709.0)
_RUNG = [_ln(-228.0, 701.2, -227.2, 701.2), _ln(-228.0, 701.2, -228.0, 701.7), _ln(-227.2, 701.2, -227.2, 701.7)]
_FROG_CAR = [_r(-229.7, 702.0, -227.1, 704.2, "pale"), _r(-229.8, 704.1, -227.0, 704.3), _ln(-228.4, 704.3, -228.4, 705.5, "line"),
             _r(-231.4, 705.5, -226.4, 705.7), _r(-226.6, 705.1, -226.3, 706.0)]

# ------------------------------------------------------------------ 8.1 Abordar
_W81 = [-247.0, 683.0, -224.0, 712.0]

ABORDAR = {
    "id": "8.1", "slug": "8_1_abordar", "title": "Abordar", "kind": "challenge",
    "window": _W81, "screen": [-235.5, 692.5], "cut_y": 694.5, "climber": [-238.6, 688.7], "also": ["a7"],
    "place": ("The low station's boarding stage. The cableway's first line is a short loop of cable between the station and pylon 1: "
              "out low, up at the pylon, back high, down at the station. It carries two gondolas and it never stops, so the town "
              "built a raised gangway on the end of the deck and put a boarding step on the end of every car: as a car came "
              "down past the gangway you took the step and it carried you off. That is still how you leave the mountain. A car "
              "comes down to the gangway every six seconds, stops for no one, and goes out east over La Garganta. The wind engine "
              "on the station's end frame is what turns the loop, and it has not stopped since the town left."),
    "keep": [
        "A car passes the gangway every six seconds. Its step comes down to 1.0 m above the gangway's east lip and leaves east at once. It is in reach for about one second of every six.",
        "The gangway: 3.3 m of planks, 0.7 m above the deck, with one rail post. A miss leaves you standing on the deck.",
        "The loop and both cars exactly as the course has them: 6 m across, a lap of 12 seconds, the cars at opposite corners.",
        "Pylon 1's perch, 2.4 m of iron at 702.0 m, over the loop's east end.",
    ],
    "background": [
        {"name": "The far line's first tower", "z": [-20.5, -20.0], "style": "mark", "tag": [-238.5, 699.0],
         "text": "20 m back, a flat cut-out hazed toward the sky: the first tower of the cableway's second line, rising behind the station house, with a slack cable going out east. That line is dead. Nothing else of ours stands between you and the far view.",
         "draw": _far(_W81)},
        {"name": "The express lines' middle tower", "z": [-2.8, -2.5], "tag": [-244.0, 700.0],
         "text": "It stands on the station and goes up out of the frame: the first sight of the lines you will ride at the top. Today it is a card 1.6 m back. It goes to 2.5 m.",
         "draw": _tower(-245.5, -242.5, 692.0, 716.0)},
        {"name": "The low station's house, east end", "z": [-5.5, -2.5], "style": "pale", "tag": [-243.6, 690.4],
         "text": "The cliffs' join designs the station. What matters here is where it stands: 2.5 m back, with its striped roof over the house and not over the deck, and with the pug sign, the cold lantern and the ticket booth on its wall (note 77). Nothing of it comes within reach.",
         "draw": [_r(-247.0, 688.0, -236.2, 692.4), _p([(-247.0, 692.4), (-235.7, 692.4), (-236.6, 694.0), (-247.0, 694.0)], "solid"),
                  _r(-241.5, 689.6, -240.1, 691.0, "dark"), _r(-238.6, 688.0, -237.5, 690.3, "dark"), _r(-246.6, 690.6, -244.6, 691.8, "line")]},
        {"name": "The station's end frame and line 1's bull wheel", "z": [-2.8, -2.0], "tag": [-232.2, 696.3], "top": True,
         "text": "A lattice frame on the station's east end, 2.5 m back, rising from the scaffold below. On it, 2 m back, is the greyed bull wheel that line 1's cable is driven by: 4.4 m across, no cream on it. Today that wheel stands 1.1 m back, inside the play space. It moves 5.0 m east and 2.9 m down to sit inside the loop, and back to 2 m.",
         "draw": _tower(-235.9, -232.9, 680.0, 703.5) + [_r(-236.3, 703.5, -232.5, 703.8)] + _wheel(-232.2, 696.3, 2.2)},
        {"name": "The station's wind engine", "z": [-3.4, -3.0], "tag": [-234.4, 706.2],
         "text": "A cup wheel 5 m across on a mast on the end frame, 3 m back, turning in the wind off the glacier. A belt runs down from it to the bull wheel. It is why a car comes every six seconds whether anybody is waiting or not.",
         "draw": _engine(-234.4, 706.2, 703.8) + _belt(-234.4, 706.2, -232.2, 696.3, w=0.2)},
        {"name": "The cliffs' haul cable", "z": [-2.4, -2.2], "style": "line", "tag": [-229.0, 685.6],
         "text": "The thick black cable from the cliffs' bull wheel comes up under the loop to a pulley at the foot of the end frame, and on up the frame to the engine. The same wind turns both.",
         "draw": [_ln(-225.2, 683.0, -233.0, 688.6), _c(-233.0, 688.6, 0.4), _ln(-233.2, 688.9, -234.3, 703.6)]},
        {"name": "Line 1's cable and its guide wheels", "z": [-2.15, -2.0], "style": "line", "tag": [-231.4, 700.4],
         "text": "One loop of black greased cable, 0.15 m thick, 2 m behind you, with a greyed guide wheel 1 m across at each corner. The whole road of both cars is on screen, so a car that comes is seen coming. Today the loop is two thin wires 0.5 m back, inside the play space.",
         "draw": _loop(D_LO, E_LO, E_HI, D_HI)},
        {"name": "The cars' hanger arms", "z": [-2.1, -1.2], "style": "line", "tag": [-233.6, 698.4],
         "text": "Each car hangs by one arm that comes down from a carriage on the cable and cranks forward to the back of its roof. The arm is scenery: greyed, behind you, and no longer solid.",
         "draw": _hanger(E_LO) + _hanger(D_HI)},
        {"name": "Pylon 1", "z": [-2.8, -2.5], "tag": [-228.4, 689.0],
         "text": "The first tower: two legs 3 m apart and zigzag braces, rising from below the frame. Today it is a card 1.2 m back, at the edge of the play space. It goes to 2.5 m. Behind its perch stands the frog's parked gondola, which has its own page.",
         "draw": _PYLON1 + _FROG_CAR},
        {"name": "Pennants and a streamer", "z": [-2.6, -2.0], "tag": [-239.0, 705.0],
         "text": "A line of pennants from the middle tower to the end frame, 2 m back and more than 3 m above the highest hand, and a streamer on pylon 1's top. They all point east. The wind here does not push you: it turns the engine, and the pennants show it.",
         "draw": _pennants(-242.5, 704.6, -235.9, 703.8) + _streamer(-229.9, 708.0)},
    ],
    "play": [
        {"name": "The step and the rack on every car", "z": [-0.5, 0.5], "style": "pale", "tag": [-225.6, 690.5],
         "text": "Every car has a boarding step out of its west end, 0.9 m long, and a freight rack out of its east end, 2.4 m long. Both are solid today and neither is drawn (note 77). They are modelled at exactly those lengths, in rust-orange iron with a cream band along the top. The roof's edge and the floor's edge get the same band: cream is the edge you take.",
         "draw": _ends(E_LO, 0.9, 2.4) + _ends(D_HI, 0.9, 2.4)},
        {"name": "Warning stripes on the deck's end", "z": [-1.2, 1.2], "tag": [-236.35, 687.2],
         "text": "East of the gangway the deck runs on for 0.7 m at 688.0 m. A car's step comes down to 1.65 m above that, which is less than your height. So the deck's end wears the slanted yellow and black stripes (note 78): stand on the gangway, not down here.",
         "draw": [_r(-236.7, 687.5, -236.0, 688.0)]},
        {"name": "The rung under pylon 1's perch", "z": [-0.3, 0.3], "style": "line", "tag": [-226.5, 701.2],
         "text": "The perch is reached today by climbing a car's hanger. With every hanger now scenery, one iron rung hangs under the perch's east end: 0.8 m long, on two straps, 0.5 m under the grating, at 701.2 m. From a car's roof at the top of its rise it is 2.0 m up: stand tall with a hand up. A body fits between the roof and the rung, so it is not a pinch.",
         "draw": _RUNG},
    ],
    "foreground": [],
    "explains": [
        ["The gangway and its rail post", "The station's boarding stage, raised so a car's step stops 1 m above its lip", "The station house 2.5 m back, and the end frame the cars come down in front of"],
        ["A car's step", "The boarding step, on the end of the car that faces the station", "The car's hanger arm, the loop of cable, the bull wheel and the wind engine that turns it"],
        ["A car's roof, floor and low end walls", "A gondola, open toward you", "Its hanger arm and the cable, 2 m back"],
        ["A car's rack", "The freight rack: the town's crates went up on it", "The loop's guide wheels on pylon 1, where the car turns back"],
        ["The perch and its rung", "The greaser's landing on pylon 1, and his step up from a car's roof", "Pylon 1's tower and the parked gondola"],
        ["The deck's striped end", "The platform's edge, marked the way the cliffs' warning sign is", "The end frame, with a car coming down in front of it"],
    ],
    "pieces": [
        ["Gondola with its step, rack and cranked hanger arm", "2.6 m wide, 2.2 m tall; step 0.9 m; rack 2.4 m", "2", "Play space; the arm behind", "kit: gondola"],
        ["Lattice bays: the station's end frame, pylon 1, the middle tower", "3 m wide, bays 4 m tall", "3 towers", "Background", "kit: lattice tower"],
        ["Bull wheel, greyed", "4.4 m across", "1", "Background", "kit: bull wheel, as scenery"],
        ["Guide wheel, greyed", "1 m across", "4", "Background", "kit: guide wheel (added)"],
        ["Wind engine with its belt", "5 m across; belt 10 m", "1", "Background", "kit: wind engine"],
        ["Cable: line 1's loop; the haul cable", "0.15 m thick; 24 m; 25 m", "2", "Background", "kit: cable"],
        ["Iron grating perch with one rail post", "2.4 m; post 1 m", "1", "Play space", "kit: tower fittings"],
        ["Iron rung on two straps", "0.8 m; straps 0.5 m", "1", "Play space", "kit: iron rung (added)"],
        ["Pennant line; streamer pole", "7 m; 3 m", "1 each", "Background", "kit: pennant line, streamer pole"],
        ["Station house, pug sign, ticket booth, cold lantern", "house 14 m wide, 6 m tall", "1", "Background", "kit: station house (placed by the cliffs' join)"],
        ["Warning stripes", "paint, 0.7 m", "1", "Play space (drawn on)", "kit: warning stripes"],
        ["Far tower and slack cable", "tower 4 m wide", "1", "Background, 20 m back", "kit: the far line"],
    ],
    "effects": [
        "The bull wheel, the four guide wheels and the wind engine turn at the cars' own pace, all the time.",
        "Gold dust in the low sun, and the car's long shadow sliding over the station wall as it comes down.",
        "A creak from the step as it takes your weight.",
    ],
    "notes": [
        "Note 77: every car's step (0.9 m) and rack (2.4 m) are drawn. Neither moves: they are where the course has them.",
        "Note 77: the station house stands 2.5 m back. Today it is 1.2 m back and 3 m deep, so its front half is in the play space. The peaked roof card that hangs 1 m back over the deck, 18.5 m wide, goes. The pug sign moves from 1.0 m back onto the house's wall, the ticket booth from 1.4 m back to against it, and the lit lantern beside the sign goes cold.",
        "The sheet's call from note 80: the two cars' hanger arms, 1.5 m tall and 0.12 m thick, stop being solid and go behind. One iron rung is added under the east end of pylon 1's perch, 0.8 m long at 701.2 m. That is the one new thing to hold in this area.",
        "Note 78: one pinch is kept and striped: the deck's last 0.7 m, east of the gangway, under a car's step.",
        "Note 76: what is drawn is what is touched. The scenery bull wheel is greyed, has no cream and stands 2 m back, so it is not taken for the cliffs' wheel that you ride.",
        "Scenery that moves out of the play space: line 1's two wires (0.5 m back) become one cable loop 2 m back. Of its two bull wheels (1.1 m back), one moves to the end frame as said above and the one on pylon 1 becomes two guide wheels. Pylon 1's tower card goes from 1.2 m back to 2.5 m. The 6 m pennant line inside the loop (0.6 m back) goes up to 704 m and back to 2 m.",
        "Also in this frame, from the cliffs' file: a pennant line 26 m long that hangs 1 m back at head height, from the deck out past pylon 1. It goes up onto the station house's eave and back with the house.",
        "Note 89: the pennants and the streamer point east and the engine turns. No wavy wind lines here, because this wind does not push.",
    ],
}

# ------------------------------------------------------------------ 8.0 The frog's gondola (rest)
_W80 = [-236.0, 695.0, -220.0, 713.0]

FROG = {
    "id": "8.0", "slug": "8_0_the_frogs_gondola", "title": "The frog's gondola", "kind": "rest",
    "window": _W80, "cut_y": 702.8, "climber": [-229.0, 702.0],
    "place": ("Pylon 1's head. When the cableway worked, this was where the greaser stood to oil the wheels the first line turns back "
              "over, and where a spare car was kept: a short siding rail runs out from the tower's top, and one gondola is parked on it "
              "against a buffer. The car is still there. Its lantern is lit, the only lit lamp on the whole cableway, and the frog "
              "sits inside on the bench with a ticket in its hand and a small suitcase beside it: the last passenger, waiting for a "
              "car that left years ago. You stand on the perch in front of the open car. It is off the route. Nothing sends you up "
              "here but the wish to stop for a moment with something under your feet."),
    "keep": [
        "The perch: 2.4 m of iron grating at 702.0 m, with one rail post. It is the only still thing between the low station and pylon 2.",
        "Challenge 8.2 starts from here.",
        "A car's roof comes up to 2.5 m under the perch every six seconds and goes away west. Nothing here stops the cars.",
    ],
    "background": [
        {"name": "A stopped chair on the far line", "z": [-20.5, -20.0], "style": "mark", "tag": [-232.2, 710.6],
         "text": "20 m back and hazed: the dead second line's slack cable, with one chair hanging on it where it stopped.",
         "draw": _far(_W80)},
        {"name": "Pylon 1's head", "z": [-2.8, -2.5], "tag": [-228.4, 697.6],
         "text": "The top of the first tower, 2.5 m back: two legs, zigzag braces, and a pug plate at every joint. An oil can and a rag sit on the plate beside the upper guide wheel.",
         "draw": _tower(-229.9, -226.9, 692.0, 708.0) + [_r(-227.4, 700.9, -227.1, 701.3, "pale")]},
        {"name": "The siding", "z": [-1.9, -1.7], "tag": [-231.0, 705.6],
         "text": "A short rail, 5 m long, hung from the tower's top between the cable and you, with a buffer on its east end. Cars were taken off the line here to be mended.",
         "draw": [_r(-231.4, 705.5, -226.4, 705.7), _r(-226.6, 705.1, -226.3, 706.0), _ln(-230.6, 705.7, -229.9, 707.6, "line"), _ln(-227.0, 705.7, -226.9, 707.6, "line")]},
        {"name": "Line 1's turn", "z": [-2.15, -2.0], "style": "line", "tag": [-231.5, 699.5],
         "text": "The loop's cable comes up the tower over two greyed guide wheels, 1 m across, and goes back west toward the station. The cars turn back here, 2 m behind you and under your feet.",
         "draw": [_ln(E_LO[0], 695.0, E_HI[0], E_HI[1]), _c(E_HI[0], E_HI[1], 0.5), _ln(E_HI[0], E_HI[1], D_HI[0], D_HI[1]), _ln(D_HI[0], D_HI[1], D_LO[0], 695.0),
                  _c(D_HI[0], D_HI[1], 0.5)]},
        {"name": "The link girder and its belt", "z": [-2.9, -2.3], "tag": [-222.5, 708.5],
         "text": "A lattice girder goes out east from the tower's top to line 2's tower, with pennants under it. A belt brings the first line's turn up to the shaft on it. It belongs to challenge 8.2.",
         "draw": _girder(-229.9, -220.0, 708.0, 709.0) + _belt(-227.9, 700.9, -227.6, 708.0, w=0.15) + _pennants(-229.9, 708.0, -220.0, 708.0)},
        {"name": "A streamer", "z": [-2.6, -2.5], "style": "pale", "tag": [-230.6, 711.0],
         "text": "On the tower's top, 3 m tall, in the town's bunting colours, streaming east.",
         "draw": _streamer(-229.9, 709.0)},
        {"name": "The parked gondola", "z": [-2.3, -1.2], "style": "pale", "tag": [-227.7, 703.4], "top": True,
         "text": "The same car as the ones you ride, standing still, its floor level with the perch and its open side toward you: back wall, roof, floor, a bench, and a peeling pug crest on the back wall. Its step and rack are unbolted and gone, so nothing sticks out of it that looks like a hold.",
         "draw": [_r(-229.7, 702.0, -227.1, 704.2), _r(-229.8, 704.1, -227.0, 704.3, "solid"), _r(-229.5, 702.45, -228.2, 702.6, "solid"),
                  _ln(-228.4, 704.3, -228.4, 705.5, "line"), _c(-227.6, 703.3, 0.35, "line")]},
        {"name": "The lit lantern", "z": [-1.8, -1.6], "style": "light", "tag": [-229.3, 704.0],
         "text": "It hangs from the car's roof. Amber, shown as colour on the car's walls and on the frog. Every other lantern on the cableway is cold.",
         "draw": [_c(-228.95, 703.75, 0.18)]},
        {"name": "The frog", "z": [-1.9, -1.5], "style": "pale", "tag": [-228.75, 702.25],
         "text": "0.3 m tall, sitting on the bench and looking out at the valley. It holds a paper ticket. A small suitcase with a pug sticker stands beside it, and a timetable card is pinned to the wall behind, bleached blank by the sun.",
         "draw": [_c(-228.95, 702.78, 0.17), _r(-228.6, 702.6, -228.25, 702.9, "solid")]},
    ],
    "play": [
        {"name": "The rung", "z": [-0.3, 0.3], "style": "line", "tag": [-226.5, 701.2],
         "text": "One iron rung under the perch's east end: 0.8 m long, on two straps, at 701.2 m. It is the way up from a car's roof now that the cars' hanger arms are scenery. It is new, and it is the only thing added to hold.",
         "draw": _RUNG},
        {"name": "The perch's grating", "z": [-1.2, 1.2], "style": "mark", "tag": [-230.3, 701.85],
         "text": "Open iron grating, rust orange and dry, with the one rail post on its west end. Through it you see the cars come up under your boots.",
         "draw": [_r(-229.6, 701.7, -227.2, 702.0), _r(-229.56, 702.0, -229.44, 703.0)]},
    ],
    "foreground": [],
    "explains": [
        ["The perch", "The greaser's landing, and the platform of the siding", "The parked car, level with it, and the siding rail above"],
        ["The rail post", "The landing's one rail post", "The tower's west leg behind it"],
        ["The rung", "The greaser's step up from a car's roof", "Its two straps go up to the perch's frame, and the tower stands behind"],
    ],
    "pieces": [
        ["Gondola, parked: no step, no rack, a bench inside", "2.6 m wide, 2.2 m tall", "1", "Background, open at the front", "kit: gondola"],
        ["Lit lantern", "0.5 m", "1", "Background", "kit: the frog's room (lantern_station)"],
        ["The frog, with a ticket; small suitcase; timetable card", "frog 0.3 m; suitcase 0.35 m", "1 each", "Background", "kit: the frog; the suitcase and card are new, this area only"],
        ["Siding rail with a buffer and two hangers", "5 m", "1", "Background", "new, this area only"],
        ["Lattice tower head; guide wheels", "3 m wide; wheels 1 m", "1; 2", "Background", "kit: lattice tower, guide wheel (added)"],
        ["Iron grating perch with one rail post; iron rung", "2.4 m; rung 0.8 m", "1 each", "Play space", "kit: tower fittings, iron rung (added)"],
        ["Link girder with pennants; streamer pole", "girder 15 m; pole 3 m", "1 each", "Background", "kit: link girder (added), pennant line, streamer pole"],
        ["Oil can and rag", "0.4 m", "1", "Background", "kit: oil can"],
    ],
    "effects": [
        "The lantern's amber on the car's walls, steady. It is the one warm light for 100 m of climb.",
        "The frog blinks, and turns its head to watch each car go by.",
        "The grating hums a little each time a car turns under it.",
    ],
    "notes": [
        "Note 60: a frog in every biome. Here it is the last passenger, in a parked gondola behind pylon 1's perch, as the sheet places it.",
        "The sheet's call from note 80: the perch gets one iron rung under its east end, because the hanger arm that was climbed to reach it is now scenery.",
        "Pylon 1's tower card goes from 1.2 m back to 2.5 m, and the bull wheel that stands 1.1 m back behind the perch today becomes two guide wheels 2 m back.",
    ],
}

# ------------------------------------------------------------------ 8.2 De Góndola a Góndola
_W82 = [-236.0, 686.0, -204.0, 713.0]

DE_GONDOLA = {
    "id": "8.2", "slug": "8_2_de_gondola_a_gondola", "title": "De Góndola a Góndola", "kind": "challenge",
    "window": _W82, "cut_y": 697.0, "climber": [-228.4, 702.0],
    "place": ("Two loops of cable stand side by side over La Garganta, 12 m apart. The first comes from the station and turns back at "
              "pylon 1. The second goes on east. When the cableway worked you changed from one to the other on a landing that hung "
              "between the two towers: you stepped off a car of the first loop as it rose past, and onto a car of the second. "
              "The landing fell in the winter the cable snapped, and its two broken brackets still reach toward each other. What is "
              "left is what the landing was built round. Every six seconds a car of each loop starts up its tower at the same moment, "
              "and the two rise side by side for 2.9 seconds, 6.1 m apart, rack toward step. One shaft turns both loops, which is why "
              "they never fall out of step. The camera stands back here: it shows both loops and 22 m of the drop."),
    "keep": [
        "Both loops and all four cars, with the course's own numbers: 12 m apart, the same lap, turning opposite ways.",
        "The window: every six seconds a car of line 1 starts up its east end as a car of line 2 starts up its west end. They rise side by side for 2.9 seconds.",
        "The gap: 6.1 m, level, from the tip of line 1's rack to the tip of line 2's step. A miss is La Garganta.",
        "Pylon 1's perch, where the challenge starts.",
    ],
    "background": [
        {"name": "The far line", "z": [-20.5, -20.0], "style": "mark", "tag": [-212.0, 710.6],
         "text": "20 m back and hazed toward the sky: the dead second line's second tower, behind line 2's loop, its slack cable, and one stopped chair. No part of it stands behind the gap you jump.",
         "draw": _far(_W82)},
        {"name": "Pylon 1 and line 2's two towers", "z": [-2.8, -2.5], "tag": [-216.4, 689.0],
         "text": "Three lattice towers rising from below the frame, flat cut-outs in the greyed red, 2.5 m back. Today they are cards 1.2 m back, at the edge of the play space.",
         "draw": _PYLON1 + _FROG_CAR + _L2W + _L2E},
        {"name": "The two loops of cable and their wheels", "z": [-2.3, -2.0], "style": "line", "tag": [-214.2, 697.7], "top": True,
         "text": "Each loop is one black greased cable, 0.15 m thick, 2 m behind you, with a greyed guide wheel 1 m across at each corner and one greyed bull wheel, 4.4 m across, inside its driven end. The whole road of all four cars is on screen. Today the cables are thin wires 0.5 m back and the wheels stand 1.1 m back, all inside the play space.",
         "draw": _loop(D_LO, E_LO, E_HI, D_HI) + _loop(W_LO, E2_LO, E2_HI, W_HI) + _wheel(-232.2, 696.3, 2.2) + _wheel(-214.2, 697.72, 2.2)},
        {"name": "The link girder and its shaft", "z": [-2.9, -2.3], "tag": [-222.4, 708.5],
         "text": "A lattice girder between the tops of pylon 1 and line 2's west tower: 15 m long at 708 m, 3.9 m above the highest hand. A shaft runs along it. A belt brings the turn up from line 1, and a crossed belt takes it down to line 2's bull wheel. The crossed belt is why line 2 turns the other way. The one shaft is why the two loops can never drift apart.",
         "draw": _LINK + _belt(-227.9, 700.9, -227.6, 708.0, w=0.15) + _belt(-216.3, 708.0, -214.2, 697.72, crossed=True, w=0.35)},
        {"name": "The cars' hanger arms", "z": [-2.1, -1.2], "style": "line", "tag": [-209.6, 701.0],
         "text": "One arm for each car, down from a carriage on the cable to the back of the roof. Scenery: greyed, behind you, no longer solid.",
         "draw": _hanger(E_LO) + _hanger(D_HI) + _hanger(W_LO) + _hanger(E2_HI)},
        {"name": "The fallen change landing", "z": [-2.8, -2.5], "tag": [-225.6, 692.6],
         "text": "Two broken bracket arms, one on each tower at 694 m, each 1.7 m long and torn off short. They held the landing where passengers changed lines. They are 2.5 m back and greyed, and they mark the height and the width of the jump. Nothing hangs from them.",
         "draw": [_p([(-226.9, 693.9), (-225.2, 693.9), (-225.0, 693.6), (-226.9, 692.3)]), _p([(-217.9, 693.9), (-219.6, 693.9), (-219.8, 693.6), (-217.9, 692.3)])]},
        {"name": "Pennants, a streamer and a wind sock", "z": [-2.6, -2.0], "tag": [-222.4, 707.2],
         "text": "A line of pennants under the girder, 2 m back and 3.2 m above the highest hand. A streamer on pylon 1's top and a wind sock on line 2's west tower. All point east, the way you are about to jump.",
         "draw": _pennants(-229.9, 708.0, -214.9, 708.0) + _streamer(-229.9, 709.0) + _sock(-214.9, 709.0)},
        {"name": "The snapped cable's end", "z": [-2.15, -2.0], "style": "line", "tag": [-206.4, 710.6],
         "text": "On the east tower's arm, high out of reach: the frayed end of the cable that went on to pylon 2. It belongs to challenge 8.3, and so do the cable, the clamp plate and the stiff end drawn in rust at the right of this sketch: all three go.",
         "draw": [_ln(-207.4, 712.0, -206.8, 709.0), _ln(-206.8, 709.0, -207.1, 708.6), _ln(-206.8, 709.0, -206.5, 708.6)]},
    ],
    "play": [
        {"name": "Rack and step, drawn", "z": [-0.5, 0.5], "style": "pale", "tag": [-221.6, 690.2],
         "text": "The two things this jump is made of are solid today and not drawn (note 77): line 1's rack, 2.4 m, and line 2's step, 0.9 m. Both are modelled at those lengths with a cream band, and each ends in a cream knuckle, so the two tips show level across the gap the whole way up.",
         "draw": _ends(E_LO, 0.9, 2.4) + _ends(D_HI, 0.9, 2.4) + _ends(W_LO, 0.9, 2.4) + _ends(E2_HI, 0.9, 2.4)},
        {"name": "The rung under the perch", "z": [-0.3, 0.3], "style": "line", "tag": [-226.4, 701.2],
         "text": "One iron rung, 0.8 m long, under the perch's east end at 701.2 m: the way onto the perch from a car's roof, now that the hanger arms are scenery.",
         "draw": _RUNG},
    ],
    "foreground": [],
    "explains": [
        ["Line 1's rack, which you leave from", "The freight rack on a car of the station's loop", "Its hanger arm, its cable, and the shaft on the girder above"],
        ["Line 2's step, which you catch", "The boarding step on a car of the second loop", "Its cable round line 2's bull wheel, and the crossed belt that turns it the other way"],
        ["The 6.1 m between them", "Where the change landing hung", "Its two broken brackets, one on each tower, at the height of the jump"],
        ["The two cars rising together", "Two loops turned by one shaft", "The link girder between the tower tops"],
        ["Pylon 1's perch", "The greaser's landing", "Pylon 1 and the frog's parked gondola"],
    ],
    "pieces": [
        ["Gondola with its step, rack and cranked hanger arm", "2.6 m wide, 2.2 m tall; step 0.9 m; rack 2.4 m", "4", "Play space; the arm behind", "kit: gondola"],
        ["Lattice tower", "3 m wide, bays 4 m tall", "3", "Background", "kit: lattice tower"],
        ["Link girder with its shaft, one belt and one crossed belt", "15 m long, 1 m deep", "1", "Background", "kit: link girder (added)"],
        ["Bull wheel, greyed", "4.4 m across", "2", "Background", "kit: bull wheel, as scenery"],
        ["Guide wheel, greyed", "1 m across", "8", "Background", "kit: guide wheel (added)"],
        ["Cable loop", "0.15 m thick, 24 m round", "2", "Background", "kit: cable"],
        ["Broken landing bracket", "1.7 m", "2", "Background", "new, this area only"],
        ["Pennant line; streamer pole; wind sock", "15 m; 3 m; 1.5 m", "1 each", "Background", "kit: pennant line, streamer pole, wind sock"],
        ["Far tower, slack cable, stopped chair", "tower 4 m wide", "1", "Background, 20 m back", "kit: the far line"],
    ],
    "effects": [
        "Both bull wheels and the shaft turn all the time, the two wheels opposite ways.",
        "Gold dust drifting east through the gap.",
        "The town, tiny, straight under the gap in the painted valley.",
    ],
    "notes": [
        "Note 77: the rack and the step are drawn, on all four cars. Neither moves.",
        "The sheet's call from note 80: the four cars' hanger arms, 1.5 m tall and 0.12 m thick, stop being solid and go behind.",
        "Note 83: when you hold line 1's rack and line 2's step at once, you keep the one more of your limbs are on, or the higher. A rule of play. Nothing is drawn for it.",
        "Note 78: no pinch is kept here. One place to check when the crunch rule is built: inside each loop, the rack of the car going down and the step of the car going up pass 0.1 m apart.",
        "Scenery that moves out of the play space: line 2's wires (0.5 m back) become one cable loop 2 m back. Line 2's west bull wheel (1.1 m back) moves 2.2 m east and 3.4 m down to sit inside the loop, 2 m back. Its east bull wheel becomes two guide wheels. The 6 m pennant line inside line 2's loop (0.6 m back) goes up under the girder. The three tower cards go from 1.2 m back to 2.5 m. Pylon 1's top goes from 706 m to 708 m to carry the girder, and line 2's east tower from 708 m to 712 m to carry the snapped cable's arm.",
        "Note 89: pennants, streamer and wind sock point east. No wavy wind lines, because this wind does not push.",
    ],
}

# ------------------------------------------------------------------ pylon 2, shared by 8.3 to 8.8
_PYLON2 = _tower(-194.0, -191.0, 683.0, 719.4)
_SNAP1 = [_ln(-207.4, 712.0, -206.8, 709.0, "line"), _ln(-206.8, 709.0, -207.1, 708.6, "line"), _ln(-206.8, 709.0, -206.5, 708.6, "line")]
_SPAN_ARM = [_r(-199.5, 715.0, -194.0, 715.3), _ln(-194.0, 713.2, -198.2, 715.0, "line"),
             _ln(-199.3, 715.0, -198.7, 712.0, "line"), _ln(-198.7, 712.0, -199.0, 711.6, "line"), _ln(-198.7, 712.0, -198.4, 711.6, "line")] + _sock(-199.5, 715.3)
_SHED = [_r(-195.0, 714.5, -190.6, 717.3, "pale"), _p([(-195.0, 717.3), (-190.6, 717.3), (-193.0, 719.2)], "pale"), _r(-194.4, 714.95, -192.9, 715.1, "solid"),
         _c(-191.4, 715.4, 0.55, "line"), _ln(-191.4, 715.4, -190.9, 716.1, "line"), _c(-193.0, 718.2, 0.6, "line"), _c(-194.0, 716.6, 0.15, "solid")]
_BELTS = ([_c(-192.5, 713.0, 0.4, "line")] + _belt(-192.5, 713.0, -194.6, 705.8, w=0.2) + _belt(-192.5, 713.0, -190.9, 710.3, crossed=True, w=0.25))
_CHAIR_CABLE = [_ln(-189.4, 717.1, -175.3, 707.7, "line"), _c(-189.4, 717.1, 0.5, "line"), _c(-175.3, 707.7, 0.5, "line"), _ln(-189.4, 717.1, -191.4, 715.4, "line")]
_POLES = []
for _px, _py in CHAIRS:
    _POLES += [_ln(_px, _py, _px, _py - 3.08, "line"), _r(_px - 0.2, _py - 0.1, _px + 0.2, _py + 0.12, "pale")]
_BUFFER = [_r(-193.7, 720.0, -193.45, 722.7, "pale"), _ln(-193.45, 722.95, -193.3, 723.15, "line"), _ln(-193.3, 723.15, -193.15, 722.85, "line"), _ln(-193.15, 722.85, -193.0, 723.0, "line")]
_ZIP_LINE = [_ln(-164.25, 728.1, -166.2, 728.1, "line"), _ln(-166.2, 728.1, ZIP_END[0], ZIP_END[1], "line")]
_FANG_TOP = [_ln(-164.25, 728.1, -162.2, 724.6, "line"), _r(-165.3, 725.4, -164.7, 725.8, "pale"), _c(-165.0, 726.0, 0.15, "pale")] + _streamer(-166.0, 727.5)

# ------------------------------------------------------------------ 8.3 El Cable
_W83 = [-214.0, 688.0, -187.0, 718.0]

EL_CABLE = {
    "id": "8.3", "slug": "8_3_el_cable", "title": "El Cable", "kind": "challenge",
    "window": _W83, "cut_y": 702.9, "climber": [-195.0, 703.0],
    "place": ("This was the long span: one cable from line 2's east tower up to pylon 2, 13 m of it, that carried the cars across. It "
              "snapped in the winter the ice came. A short frayed end hangs from each tower, high out of reach, and between them there "
              "is only air. So where the cable was, you jump: off the freight rack of line 2's car as it reaches the top of its loop, "
              "10.7 m across and 4.7 m up, to the west end of pylon 2's landing. The car is moving east at that moment, which helps. "
              "Under the jump is La Garganta, and under that the town."),
    "keep": [
        "It is one jump, with nothing to hold between the car and the landing (note 79).",
        "Where it starts: the tip of the rack on line 2's car, at the top of the loop's east end, 698.3 m up.",
        "Where it ends: the west end of pylon 2's landing, 5.4 m of iron grating at 703.0 m. The landing does not move.",
        "Pylon 2's two legs under the landing stay slick, so nobody who falls short climbs the pylon from below.",
    ],
    "background": [
        {"name": "The far line's second tower", "z": [-20.5, -20.0], "style": "mark", "tag": [-212.0, 715.5],
         "text": "20 m back and hazed, behind line 2's tower: the dead second line. It is not behind the jump.",
         "draw": _far(_W83)},
        {"name": "Line 2's east tower", "z": [-2.8, -2.5], "tag": [-210.4, 692.0],
         "text": "A lattice tower 2.5 m back, with an arm on its top where the long span left it. Today it is a card 1.2 m back and 4 m shorter.",
         "draw": _L2E},
        {"name": "Line 2's cable and guide wheels", "z": [-2.15, -2.0], "style": "line", "tag": [-212.6, 698.6],
         "text": "The east end of line 2's loop, 2 m behind you: the cable comes in along the top, turns down over a greyed guide wheel 1 m across, and goes back west along the bottom over another. You see the car come along the top toward you before it turns down.",
         "draw": [_ln(-214.0, 701.2, E2_HI[0], E2_HI[1]), _ln(E2_HI[0], E2_HI[1], E2_LO[0], E2_LO[1]), _ln(E2_LO[0], E2_LO[1], -214.0, 695.36),
                  _c(E2_HI[0], E2_HI[1], 0.5), _c(E2_LO[0], E2_LO[1], 0.5)]},
        {"name": "The car's hanger arm", "z": [-2.1, -1.2], "style": "line", "tag": [-209.5, 701.2],
         "text": "Scenery: greyed, behind you, no longer solid.",
         "draw": _hanger(E2_HI)},
        {"name": "The snapped end on line 2's tower", "z": [-2.15, -2.0], "style": "line", "tag": [-206.0, 710.4],
         "text": "3 m of black cable, 0.15 m thick, hanging from the tower's arm with its strands frayed open and blown a little east. Its lowest point is 6 m above a hand held up from the car's roof.",
         "draw": _SNAP1},
        {"name": "Pylon 2, behind its legs", "z": [-2.8, -2.5], "tag": [-192.5, 694.0],
         "text": "Pylon 2 is the one tower that stands in the climb. Its two near legs are in the play space, black with grease. Its far legs and all its braces are a flat cut-out 2.5 m back, in the greyed red. An oil can stands at the back of the landing: somebody was mending it.",
         "draw": _PYLON2 + [_r(-191.75, 703.0, -191.45, 703.4, "pale")]},
        {"name": "The long span's arm on pylon 2", "z": [-2.6, -2.0], "tag": [-197.0, 716.2], "top": True,
         "text": "A crossarm 5.5 m long at 715 m, out to the west of the tower, 2.5 m back: where the long span came in. The cable's other frayed end hangs 3 m from its tip, 4 m and more from any hand. A wind sock stands on the tip and points east, toward the tower: the wind is with your jump.",
         "draw": _SPAN_ARM},
    ],
    "play": [
        {"name": "Taken out: the cable, its stiff end, its clamp plate", "z": [-0.2, 0.2], "style": "mark", "tag": [-200.6, 703.4],
         "text": "The cable's five stretches, from (-206.0, 700.0) up to (-195.6, 704.3): 11.3 m of it solid, with two greased lengths of 1.6 m. Its stiff frayed end, 4.4 m tall, at x -206.0. The clamp plate over it, 1.2 m wide, at 700.3 m. The last 1.7 m of scenery wire onto the lower wheel. All of it goes (note 79). The sketch still shows them in rust, as the course has them today.",
         "draw": [_ln(-206.0, 700.0, -195.6, 704.3), _ln(-206.0, 695.6, -206.0, 700.0), _r(-206.6, 699.95, -205.2, 700.4)]},
        {"name": "The rack you jump from", "z": [-0.5, 0.5], "style": "pale", "tag": [-206.2, 697.4],
         "text": "The freight rack on line 2's car: 2.4 m of rust-orange iron with a cream band and a cream knuckle on its tip, drawn at the length it is (note 77). Its tip is the last thing under your hands for 10.7 m.",
         "draw": _ends(E2_HI, 0.9, 2.4)},
        {"name": "The landing's west end", "z": [-1.2, 1.2], "style": "pale", "tag": [-196.6, 702.2],
         "text": "Open iron grating, rust orange and dry. Its west end is the whole target, so its lip is rolled and worn bright: the palest thing on the pylon, and it shows from the car. Nothing is added to stand on or to hold.",
         "draw": [_r(-196.0, 702.7, -194.6, 703.0)]},
        {"name": "Pylon 2's two legs", "z": [-0.15, 0.15], "style": "dark", "tag": [-189.9, 697.0],
         "text": "Black greased steel, glossy, 0.3 m thick, from below the frame up to the landing. The only steel in the play space that you cannot hold.",
         "draw": [_r(-194.15, 688.0, -193.85, 702.7), _r(-191.15, 688.0, -190.85, 702.7)]},
    ],
    "foreground": [],
    "explains": [
        ["The rack you leave from", "The freight rack of line 2's car", "Its hanger arm, the loop of cable and the guide wheels on line 2's east tower"],
        ["The 10.7 m of air", "Where the long span's cable ran", "A snapped end on each tower, and the empty arm on pylon 2"],
        ["The landing", "Pylon 2's landing, where cars off the long span set down", "The tower's lattice, the oil can, and the wind sock on the arm above"],
        ["The two slick legs", "The pylon's own near legs", "Its far legs and braces, 2.5 m back"],
    ],
    "pieces": [
        ["Gondola with its step, rack and cranked hanger arm", "2.6 m wide, 2.2 m tall; rack 2.4 m", "1 here", "Play space; the arm behind", "kit: gondola"],
        ["Snapped cable end, frayed", "3 m long, 0.15 m thick", "2", "Background", "kit: snapped cable end"],
        ["Lattice tower: line 2's east tower with its arm; pylon 2 behind its legs", "3 m wide, bays 4 m tall; arms 5.5 m", "2", "Background", "kit: lattice tower and crossarm"],
        ["Guide wheel, greyed", "1 m across", "2", "Background", "kit: guide wheel (added)"],
        ["Pylon 2's legs, black greased steel", "0.3 m thick, 33 m tall", "2", "Play space", "kit: pylon 2's legs"],
        ["Iron grating landing with a rolled lip", "5.4 m", "1", "Play space", "kit: tower fittings"],
        ["Wind sock", "1.5 m", "1", "Background", "kit: wind sock"],
        ["Oil can", "0.4 m", "1", "Background", "kit: oil can"],
        ["Far tower", "4 m wide", "1", "Background, 20 m back", "kit: the far line"],
    ],
    "effects": [
        "The two frayed ends stir in the wind, slowly. They are thick and stiff, and they do not swing like a rope.",
        "Gold dust drifting east across the gap, the way you jump.",
        "The camera stands back for the jump and shows the whole drop under it.",
    ],
    "notes": [
        "Note 79: the cable comes out, with its stiff end and its clamp plate, as listed in the play space above. What is left is one jump from the rack's tip at (-206.7, 698.3) to the landing's west end at (-196.0, 703.0): 10.7 m across and 4.7 m up. The landing has not been moved. The note gives leave to bring it west or down a little if the jump proves too far when it is built.",
        "Note 79: the cable has snapped. A frayed end 3 m long hangs from each tower, on line 2's tower from 712 m and on pylon 2 from 715 m, both out of reach.",
        "Note 78: the pinch at the lower wheel was the cable's end, 0.8 m from the rim. With the cable gone there is none: the rim is 1.7 m above the landing and nothing else is near it.",
        "The challenge's start mark stands on the clamp plate today. With the plate gone it needs a new place when this is built. Pylon 1's perch is the nearest still thing.",
        "Its difficulty is 4 today. It is now one long jump from a moving car, and is to be rated again.",
        "Scenery that moves out of the play space: line 2's east bull wheel (1.1 m back) becomes two guide wheels 2 m back. The 10 m pennant line along the cable (0.6 m back) and the wire that ran on from the loop's top corner to the cable's foot (0.5 m back) go with the cable. The two tower cards go from 1.2 m back to 2.5 m. The oil can on the landing goes from 0.7 m back to 1.3 m.",
    ],
}

# ------------------------------------------------------------------ 8.4 El Pilón
_W84 = [-204.0, 699.0, -183.0, 724.0]

EL_PILON = {
    "id": "8.4", "slug": "8_4_el_pilon", "title": "El Pilón", "kind": "challenge",
    "window": _W84, "cut_y": 714.3, "climber": [-194.7, 703.0],
    "place": ("Pylon 2 is the cableway's big tower, the one everything else is hung from. The long span came in on its west side, the "
              "chair line leaves from its east, the zip line comes home to its roof, and the counterweights ride above it. You climb "
              "it by its fittings. From the landing you take the lower wheel, which is turning, and let it throw you up and east to "
              "the upper wheel, which turns the other way. That one throws you up onto the head: 4 m of planks under a tarred tin "
              "roof, where people once waited for a chair. A wind engine high on the tower turns both wheels through belts. With the "
              "long span gone the wheels carry no cable at all. They turn because nobody stopped them."),
    "keep": [
        "The landing at 703.0 m, the head at 714.5 m, and the two wheels where they are: the lower one's hub at (-194.6, 705.8), the upper one's at (-190.9, 710.3).",
        "Both wheels are 2 m across and turn 9 times a minute, opposite ways: the lower one goes up on its east side, the upper one on its west.",
        "After note 81 there is nothing else to hold: 3.7 m of air from rim to rim, and 2.8 m from the top of the upper rim to the underside of the head.",
        "The tarred roof over the head stays slick, so nobody climbs from the head to the maintenance deck through it.",
    ],
    "background": [
        {"name": "Pylon 2's lattice", "z": [-2.8, -2.5], "tag": [-192.5, 701.0],
         "text": "Two legs 3 m apart and zigzag braces, a flat cut-out in the greyed red. Today it is a card 1.2 m back, at the edge of the play space: it goes to 2.5 m. Where the brace and the rung were bolted on, two pug plates are left with empty bolt holes.",
         "draw": _PYLON2 + [_r(-192.7, 707.8, -192.3, 708.2, "pale"), _r(-193.4, 712.6, -193.0, 713.0, "pale")]},
        {"name": "The shaft and the two belts", "z": [-2.5, -2.3], "style": "line", "tag": [-192.5, 711.4], "top": True,
         "text": "Each wheel's axle runs back to a bracket on the tower. On the tower's centre line at 713 m sits a short shaft with a pulley, and the wind engine's belt comes straight down the inside of the tower to it. From the shaft one belt goes down to the lower wheel and a crossed belt to the upper one, which is why they turn opposite ways. Every belt runs inside the tower's width, over the lattice, so none hangs in open air beside a hold.",
         "draw": _BELTS + _belt(-192.5, 713.4, -192.5, 724.0, w=0.12)},
        {"name": "The chair shed", "z": [-2.6, -1.9], "style": "pale", "tag": [-192.2, 716.3],
         "text": "Under the tarred roof, 2.5 m back: a board wall, red below cream, with a bench against it, a cold lantern, the peeling pug crest on the gable, and the hand winch that wound the chair line. The crest and the lantern are 0.9 and 0.8 m back today, inside the play space, and the lantern is lit. Both go to the wall, and the lantern goes cold.",
         "draw": _SHED},
        {"name": "The long span's arm and its snapped end", "z": [-2.6, -2.0], "tag": [-197.2, 716.3], "top": True,
         "text": "A crossarm out to the west at 715 m, 2.5 m back, with 3 m of frayed cable hanging from its tip and a wind sock on it. It is what is left of challenge 8.3's cable, and it is 4 m and more from any hand.",
         "draw": _SPAN_ARM},
        {"name": "The chair line leaving", "z": [-2.15, -1.3], "style": "line", "tag": [-187.4, 716.9],
         "text": "East of the shed: the chair line's cable going down toward the fang over a greyed guide wheel under the eave, and the first chair's pole. They belong to challenge 8.5.",
         "draw": [_ln(-189.4, 717.1, -183.0, 712.83), _c(-189.4, 717.1, 0.5), _ln(-189.4, 717.1, -191.4, 715.4), _ln(-188.5, 716.5, -188.5, 713.4)]},
        {"name": "An oil can and a grease pot", "z": [-1.6, -1.25], "style": "pale", "tag": [-190.0, 703.7],
         "text": "At the back of the landing, under the lower wheel's bracket. Somebody was mending it. The oil can is 0.7 m back today: it goes to 1.3 m.",
         "draw": [_r(-191.75, 703.0, -191.45, 703.4), _r(-192.4, 703.0, -192.0, 703.3)]},
    ],
    "play": [
        {"name": "The two wheels, drawn at the size they are", "z": [-0.15, 0.15], "style": "line", "tag": [-196.5, 706.9],
         "text": "Each is a red wheel 2 m across with four cream spokes and the pug on its hub. All of it is held, rim and spokes, and the model is made at exactly that size, so what is drawn is what you touch (note 76).",
         "draw": [_c(-194.6, 705.8, 1.08), _c(-190.9, 710.3, 1.08)]},
        {"name": "Taken out: the brace and the rung", "z": [-0.1, 0.1], "style": "mark", "tag": [-195.7, 710.6],
         "text": "The brace: an iron bar 2.7 m long, from (-193.8, 708.4) down to (-191.2, 707.6). The rung: a level iron bar 2.6 m long at 712.8 m, from x -194.5 to x -191.9. Both go (note 81). The sketch still shows them in rust.",
         "draw": [_ln(-193.8, 708.4, -191.2, 707.6), _ln(-194.5, 712.8, -191.9, 712.8)]},
        {"name": "The tarred roof", "z": [-1.2, 1.2], "style": "mark", "tag": [-196.6, 718.1],
         "text": "Black tarred tin, glossy: two slopes over the head, 5.6 m and 6.5 m long. It is in the play space and it cannot be held, so it is the blackest thing on the tower.",
         "draw": [_ln(-193.0, 719.75, -197.7, 716.45), _ln(-193.0, 719.75, -187.5, 716.15)]},
    ],
    "foreground": [],
    "explains": [
        ["The landing", "The long span's landing on pylon 2", "The tower's lattice, the oil can and the grease pot"],
        ["The lower wheel", "The sheave the long span's cable ran onto", "Its axle bracket, and its belt down from the shaft"],
        ["The upper wheel", "The sheave that sent the cable on up the tower", "Its crossed belt from the same shaft"],
        ["The head", "The floor of the chair shed", "The shed's wall, its bench and the chair line's hand winch"],
        ["The slick roof", "The shed's tarred tin roof", "The shed's gable with the pug crest, under it"],
    ],
    "pieces": [
        ["Sheave: red, four cream spokes, the pug on its hub", "2 m across", "2", "Play space", "kit: sheave"],
        ["Lattice tower: pylon 2", "3 m wide, bays 4 m tall", "1", "Background", "kit: lattice tower"],
        ["Axle bracket; shaft with pulley; belt; crossed belt", "bracket 2.5 m; belts 7.5 m and 3.2 m", "2 brackets, 1 shaft, 3 belts", "Background", "kit: sheave (its bracket and belt)"],
        ["Chair shed: board wall, bench, hand winch", "4.4 m wide, 2.8 m tall", "1", "Background", "kit: chair shed (added)"],
        ["Peeling pug crest; cold lantern; oil can; grease pot", "1.6 m; 0.5 m; 0.4 m; 0.4 m", "1 each", "Background", "kit: pug crest, cold lantern, oil can"],
        ["Crossarm with a snapped cable end and a wind sock", "arm 5.5 m; end 3 m", "1", "Background", "kit: crossarm, snapped cable end, wind sock"],
        ["Iron grating landing; plank head", "5.4 m; 4 m", "1 each", "Play space", "kit: tower fittings"],
        ["Tarred tin roof", "slopes 5.6 m and 6.5 m", "1", "Play space", "kit: pylon 2's roof"],
        ["Empty pug plate", "0.4 m", "2", "Background", "kit: lattice tower (its joint plate)"],
    ],
    "effects": [
        "The belts run and the shaft turns, all the time, and each wheel's cream spokes show which way it is going.",
        "Flakes of red paint come off the lower wheel's rim when you take it.",
        "A dry squeal from the upper wheel once in every turn.",
    ],
    "notes": [
        "Note 81: the brace and the rung come out, as listed in the play space above. The climb is landing, lower wheel, upper wheel, head. Rim to rim is 3.7 m of air, and from the top of the upper rim to the underside of the head is 2.8 m. To measure when it is built: that 9 turns a minute gives enough throw for both. Its difficulty goes up from 3 and is to be rated again.",
        "Note 78: a crunch knocks you out. Nothing solid now stands near enough to either wheel to crush you against: the cable's end, which made the pinch, went with note 79. So no warning stripes are needed on this tower.",
        "Note 76: each wheel is modelled at exactly 2 m, rim and spokes. Nothing solid lies outside what is drawn.",
        "Note 79: no cable runs onto the lower wheel any more. The wheels are turned by belts from the wind engine, so they still have a reason to turn.",
        "Scenery that moves out of the play space: the tower card goes from 1.2 m back to 2.5 m. The pug crest (0.9 m back) and the lantern (0.8 m back, lit) go to the shed's wall, 2.5 m back, and the lantern goes cold. The oil can goes from 0.7 m back to 1.3 m.",
    ],
}

# ------------------------------------------------------------------ 8.5 Sillas Voladoras
_W85 = [-198.0, 698.0, -170.0, 724.0]

SILLAS = {
    "id": "8.5", "slug": "8_5_sillas_voladoras", "title": "Sillas Voladoras", "kind": "challenge",
    "window": _W85, "cut_y": 714.0, "climber": [-192.8, 714.5],
    "place": ("The chair line: four plank benches on one cable, from the shed on pylon 2's head down to the foot ledge on El Colmillo, "
              "16 m away and 12 m lower. It was the linesmen's way out to the fang, and it was wound by hand from the shed. Nobody "
              "winds it now, so the chairs hang where they stopped, and the wind off the glacier swings them, each a little out of "
              "step with the next. You cross on the seats. Their poles are behind you: each is fixed to the back of its seat and "
              "goes up to the cable 2 m back. Under the chairs is the whole of La Garganta."),
    "keep": [
        "Four chairs, each on a pole of 3.2 m, swinging 20 degrees each way every 4 seconds, out of step with each other as the course has them.",
        "The seats: 1.2 m wide and 0.25 m thick. After note 80 they are the only things to hold.",
        "The three reaches: from the head's east end to the first seat, seat to seat, and from the fourth seat to the fang's rib.",
        "The foot ledge on the fang, 1.3 m wide, is the only stance on the far side.",
    ],
    "background": [
        {"name": "The chair line's cable", "z": [-2.15, -2.0], "style": "line", "tag": [-182.6, 713.4],
         "text": "One black greased cable, 0.15 m thick, 2 m behind you, from a greyed guide wheel under the shed's eave down to another on the fang. From the eave it runs back into the shed to the hand winch. It does not move. Today it is a thin wire 0.5 m back.",
         "draw": _CHAIR_CABLE},
        {"name": "The four poles", "z": [-2.1, -1.3], "style": "line", "tag": [-179.9, 709.4],
         "text": "Each pole is 3.2 m long and 0.12 m thick. Today it is solid: it can be held, and a pole swinging past can bat you. It becomes scenery (note 80). It is fixed to the back edge of its seat, cranks back out of the play space, and rises to the cable 2 m behind you, in the greyed red. You pass in front of it.",
         "draw": _POLES},
        {"name": "The chair shed on pylon 2", "z": [-2.8, -1.9], "tag": [-192.9, 716.0],
         "text": "Where the chairs were boarded: a board wall 2.5 m back under the tarred roof, with a bench, the hand winch that wound the line, a cold lantern and the pug crest. The tower's lattice is behind it.",
         "draw": _tower(-194.0, -191.0, 695.0, 719.4) + _SHED},
        {"name": "The cable's anchor on the fang", "z": [-2.3, -1.9], "tag": [-176.6, 706.6],
         "text": "An iron arm bolted into the fang's body, 2 m back, with the guide wheel and a pug plate. The cable is made fast here, 5 m above the foot ledge.",
         "draw": [_r(-175.9, 707.3, -174.3, 707.55), _r(-174.6, 707.0, -174.2, 708.0, "pale")]},
        {"name": "Pennants on the chair cable", "z": [-2.1, -2.0], "tag": [-186.4, 714.4],
         "text": "The 12 m pennant line stays on the chair cable and goes back with it, from 0.6 m behind you to 2 m. The pennants hang 0.7 m, which leaves them clear of a hand held up from a seat. They blow east, toward the fang.",
         "draw": _pennants(-188.0, 716.17, -177.0, 708.83)},
        {"name": "The zip line's buffer, above", "z": [-2.2, -2.0], "style": "pale", "tag": [-194.6, 721.6],
         "text": "At the back of the maintenance deck on the roof's ridge: the post the zip line comes home to. It belongs to challenge 8.7.",
         "draw": _BUFFER + [_ln(ZIP_END[0], ZIP_END[1], -187.75, 724.0, "line")]},
    ],
    "play": [
        {"name": "The four seats", "z": [-0.5, 0.5], "style": "pale", "tag": [-183.2, 710.4],
         "text": "A plank bench with a cream front edge, no back and no arms, modelled at exactly 1.2 m by 0.25 m. The seat is all of the chair that you can touch.",
         "draw": [_r(px - 0.6, py - 3.33, px + 0.6, py - 3.08) for px, py in CHAIRS]},
        {"name": "The rib and the foot ledge", "z": [-1.2, 1.2], "style": "mark", "tag": [-172.6, 705.0],
         "text": "White chalk, dry and matte, on the fang's dark rock: a rib 3.4 m tall that the fourth chair swings to, and a ledge 1.3 m wide under it. They are the only pale things on this side of the fang below the knobs.",
         "draw": [_r(-174.75, 703.1, -173.45, 706.7), _r(-174.95, 702.3, -173.4, 703.0)]},
    ],
    "foreground": [],
    "explains": [
        ["The head's east end", "The doorstep of the chair shed", "The shed's wall, bench and hand winch"],
        ["The four seats", "The chair line's benches", "Each seat's pole, the cable it hangs from, and the winch that wound it"],
        ["The rib and the foot ledge", "Where the chairs set the linesmen down on the fang", "The cable's anchor arm in the rock, 5 m above the ledge"],
    ],
    "pieces": [
        ["Flying chair: a plank bench with a cream front edge; its cranked pole", "seat 1.2 m wide, 0.25 m thick; pole 3.2 m", "4", "Play space (the seat); the pole behind", "kit: flying chair"],
        ["Cable", "0.15 m thick, 17 m", "1", "Background", "kit: cable"],
        ["Guide wheel, greyed", "1 m across", "2", "Background", "kit: guide wheel (added)"],
        ["Chair shed: board wall, bench, hand winch", "4.4 m wide, 2.8 m tall", "1", "Background", "kit: chair shed (added)"],
        ["Anchor arm with a pug plate", "1.6 m", "1", "Background", "kit: crossarm, cut short"],
        ["Pennant line", "12 m", "1", "Background", "kit: pennant line"],
        ["Chalk rib; chalk foot ledge", "3.4 m tall; 1.3 m wide", "1 each", "Play space", "kit: El Colmillo"],
    ],
    "effects": [
        "The chairs are the wind's tell here: they swing because it blows, and their pennants stream east.",
        "Each seat creaks at the end of its swing.",
        "Gold dust drifting through the chairs, and the town in the valley straight under the second one.",
    ],
    "notes": [
        "Note 80: the four poles, each 3.2 m long and 0.12 m thick, stop being solid and go behind the climb. The seats do not change: the three reaches of this challenge are measured between seats and stand as they are. A seat is now the only thing to catch on a miss.",
        "Note 83: seat to seat, you keep the seat more of your limbs are on, or the higher one. A rule of play. Nothing is drawn for it.",
        "Note 78: no pinch is kept here. One place to check when the crunch rule is built: the seats of chairs 1 and 2, and of 3 and 4, close to 0.5 m of each other at the ends of their swings, where they are almost still.",
        "Scenery that moves out of the play space: the chair line's wire (0.5 m back) becomes a cable 2 m back, and its 12 m pennant line (0.6 m back) goes with it.",
        "Note 89: the swinging chairs and their pennants show the wind. No wavy lines, because this wind does not push you.",
    ],
}

# ------------------------------------------------------------------ 8.6 El Colmillo
_W86 = [-184.0, 697.0, -150.0, 733.0]

EL_COLMILLO = {
    "id": "8.6", "slug": "8_6_el_colmillo", "title": "El Colmillo", "kind": "challenge",
    "window": _W86, "cut_y": 725.2, "climber": [-174.3, 702.9],
    "place": ("El Colmillo is a fang of the cliffs' own rock standing by itself in the open air, 14 m across at this height, dark and "
              "polished by rain. The cableway never built on it. It only tied itself to it: the chair line is anchored in its west "
              "side and the zip line to its top. The linesmen who kept those anchors went up it the way you do, on the white chalk "
              "knobs that stick out of the dark rock: up the overhang, round the nose at 715 m, and up the slab to the iron plate on "
              "top. From the foot ledge to the plate it is 22 m, with no place to stand on the way."),
    "keep": [
        "The rock's outline: the overhang, the nose at (-176, 715), the slab, the top.",
        "The thirteen knobs, each where it is, about 1.8 m apart, and the rock slick everywhere else.",
        "The foot ledge and the rib at the bottom. The anchor plate and the post on top.",
    ],
    "background": [
        {"name": "The far line's last tower", "z": [-20.5, -20.0], "style": "mark", "tag": [-153.0, 712.0],
         "text": "20 m back and hazed, in the open air east of the fang: the third tower of the dead second line, with its slack cable and one stopped car high up on the west.",
         "draw": _far(_W86)},
        {"name": "The fang's far horn", "z": [-4.0, -1.5], "tag": [-159.6, 716.0], "top": True,
         "text": "The fang is thicker than the slice of it you climb. Its far horn stands 1.5 to 4 m back: the same dark rock, a step duller and greyer, rising 2 to 3 m above the slab and up to 2 m wider on the east. It never shows west of the overhang, so the overhang keeps a clean edge against the sky. It is why the fang reads as a rock and not as a card.",
         "draw": [_p(_HORN)]},
        {"name": "The chair line's anchor", "z": [-2.3, -1.3], "tag": [-177.6, 706.4],
         "text": "On the fang's west side, 2 m back: the iron arm and guide wheel where the chair line's cable is made fast, with the fourth chair's pole hanging from the cable beside it.",
         "draw": [_r(-175.9, 707.3, -174.3, 707.55), _c(-175.3, 707.7, 0.5, "line"), _ln(-175.3, 707.7, -184.0, 713.5, "line"), _ln(-176.8, 708.7, -176.8, 705.62, "line")]},
        {"name": "The top's fittings", "z": [-2.6, -1.3], "style": "pale", "tag": [-162.6, 727.2],
         "text": "Behind the plate: the post's back stay, a thick iron rod down to an eye bolt in the horn; a linesman's box and a cold lantern; and a streamer pole on the horn's tip, pointing east.",
         "draw": _FANG_TOP},
        {"name": "The zip line, leaving", "z": [-2.15, -2.0], "style": "line", "tag": [-175.0, 727.4],
         "text": "The zip line goes out west from the back of the post, 2 m behind you. It belongs to challenge 8.7.",
         "draw": [_ln(-164.25, 728.1, -166.2, 728.1), _ln(-166.2, 728.1, -184.0, 724.71), _r(-166.5, 728.0, -165.9, 728.3, "pale")]},
    ],
    "play": [
        {"name": "The chalk knobs", "z": [-0.3, 0.3], "style": "line", "tag": [-177.6, 711.0],
         "text": "Thirteen white chalk knobs, each 0.4 m across and modelled at the size of its grip, standing 0.1 m out of the dark rock. White and matte against black and glossy: they are the only holds on the fang, and nothing else on it is pale. Four up the overhang, one on the nose, one over it, seven up the slab.",
         "draw": [_c(x, y, 0.36) for x, y in _KNOBS]},
        {"name": "The foot ledge and the rib", "z": [-1.2, 1.2], "style": "mark", "tag": [-176.4, 703.6],
         "text": "White chalk: the ledge is the lip of a level bed of chalk that runs through the fang, and the rib is the same bed's broken edge, turned up. The fourth chair sets you down here.",
         "draw": [_r(-174.95, 702.3, -173.4, 703.0), _r(-174.75, 703.1, -173.45, 706.7)]},
        {"name": "Rain lines on the dark rock", "z": [1.15, 1.2], "style": "mark", "tag": [-168.4, 712.0],
         "text": "The rock is rain-polished and glossy, with thin white drip lines running down the overhang and the east side. No ledge, no crack and no pale patch that is not a knob.",
         "draw": [_ln(-173.8, 712.5, -173.0, 707.4), _ln(-171.6, 716.0, -170.4, 708.0), _ln(-168.6, 719.0, -167.4, 708.5), _ln(-164.8, 720.0, -163.4, 706.0), _ln(-162.6, 712.0, -161.6, 700.0)]},
        {"name": "The anchor plate and the post", "z": [-0.4, 0.4], "style": "mark", "tag": [-167.9, 726.4],
         "text": "An iron plate 2.6 m long on the fang's top, and the zip line's post, 2.7 m tall, at its east end. Rust-orange iron, dry: both are held.",
         "draw": [_r(-166.6, 725.0, -164.0, 725.4), _r(-164.4, 725.4, -164.1, 728.1)]},
    ],
    "foreground": [],
    "explains": [
        ["The thirteen knobs", "Lumps of chalk in the dark rock, the linesmen's way up", "The fang's far horn, and at each end of the climb an anchor they went up to keep"],
        ["The foot ledge and the rib", "The lip of a chalk bed, where the chair line set down", "The cable's anchor arm 2 m back, 5 m above the ledge"],
        ["The plate and the post", "The zip line's anchor", "The back stay down to the horn, the linesman's box, the line going out west"],
    ],
    "pieces": [
        ["Chalk knob", "0.4 m across", "13", "Play space", "kit: El Colmillo (the knob model)"],
        ["The fang's rock: overhang, nose, slab", "14 m across, 41 m of it in the course", "1", "Play space", "kit: El Colmillo"],
        ["The fang's far horn", "20 m wide, 31 m tall in this frame, 2.5 m deep", "1", "Background", "kit: the fang's far horn (added)"],
        ["Anchor plate; anchor post with a back stay", "plate 2.6 m; post 2.7 m; stay 4.5 m", "1 each", "Play space; the stay behind", "kit: the zip line's two ends; the stay is new"],
        ["Anchor arm with a guide wheel and a pug plate", "1.6 m; wheel 1 m", "1", "Background", "kit: crossarm, cut short; guide wheel (added)"],
        ["Linesman's box; cold lantern; streamer pole", "0.6 m; 0.5 m; 3 m", "1 each", "Background", "kit: toolbox, cold lantern, streamer pole"],
        ["Far tower, slack cable, stopped car", "tower 4 m wide; car 2.6 m", "1", "Background, 20 m back", "kit: the far line"],
    ],
    "effects": [
        "The fang's top catches the last sun: the plate and the post are in gold light while the overhang is in blue shadow. The course has this light today.",
        "A little chalk dust from a knob as a hand takes it.",
    ],
    "notes": [
        "No playtest note changes this challenge. It plays exactly as the course has it.",
        "Notes 76 and 77, the rule they made: each knob is modelled at the size of its grip, 0.4 m, so nothing can be held that is not drawn.",
        "Scenery that moves out of the play space: the chair line's wire, which ends on the fang 0.5 m back, becomes a cable 2 m back on an anchor arm.",
        "This is the plainest area of the biome: one rock, its knobs and two anchors. The sheet asks for nothing more on the fang.",
    ],
}

# ------------------------------------------------------------------ pylon 3, the frame and the express tower, shared by 8.7 to 8.10
_FRAME = _tower(-198.6, -195.6, 719.4, 754.6)
_PYLON3 = _tower(-205.0, -202.4, 716.0, 758.4)
_EXTOWER = _tower(-221.7, -218.7, 740.0, 772.0)
for _g in EX_E:                                           # an arm, a buffer and a guide wheel at each line's east end
    _EXTOWER += [_r(-218.7, _g[1] - 0.65, -216.9, _g[1] - 0.45), _c(-217.5, _g[1] - 0.47, 0.5, "line")]
_ENGINE2 = _engine(-192.5, 730.0, 719.4)
_ENGINE3 = _engine(-203.7, 761.6, 758.4) + _belt(-203.7, 761.6, -203.7, 755.8, w=0.12)
_FROZEN = [_r(-202.65, 749.0, -202.0, 749.9, "pale"), _c(-202.3, 750.12, 0.22, "pale")]
_BLOCKS = [(-197.1, 720.5), (-200.3, 734.5), (-197.1, 734.5), (-200.3, 748.5)]     # where each block's top starts
_LEVELS = [720.5, 727.5, 734.5, 741.5, 748.5]
_DEAD_RACK = [(-210.68, 748.97), (-209.24, 749.68), (-209.3, 749.8), (-210.74, 749.09)]

# ------------------------------------------------------------------ 8.7 Tirolesa
_W87 = [-200.0, 712.0, -159.0, 737.0]

TIROLESA = {
    "id": "8.7", "slug": "8_7_tirolesa", "title": "Tirolesa", "kind": "challenge",
    "window": _W87, "cut_y": 723.5, "climber": [-165.3, 725.4],
    "place": ("The zip line was the linesmen's way home from the fang: one cable from the post on El Colmillo's top down to the "
              "maintenance deck on pylon 2's roof, with a trolley on it and a handle bar under the trolley. You reach up from the "
              "plate, take the bar, and it goes: 27 m west over La Garganta in three seconds, with the town straight under your boots. "
              "The line used to end in the air, 4 m short of the deck. It is whole again. It runs all the way, and the trolley comes "
              "to rest against a sprung buffer over the middle of the deck, where you let go and stand. The camera stands well back "
              "for this: the fang, the whole line and the deck are in one frame."),
    "keep": [
        "The trolley waits 2.7 m over the plate with its bar 1.8 m over it. It goes when you take the bar, runs at 9 m a second, and goes home 6 seconds after you leave it.",
        "The plate and the post on the fang's top, and the maintenance deck: 6 m of planks at 720.0 m.",
        "Nothing is under the ride.",
    ],
    "background": [
        {"name": "The far line", "z": [-20.5, -20.0], "style": "mark", "tag": [-186.0, 732.6],
         "text": "20 m back and hazed: the dead second line's slack cable crossing high behind the ride, with one stopped car on it, 4 m above the zip line.",
         "draw": _far(_W87)},
        {"name": "The fang's far horn and the top's fittings", "z": [-4.0, -1.3], "tag": [-162.2, 721.4],
         "text": "The fang's body, 1.5 to 4 m back, rising 2 m behind the plate. On it: the post's back stay, the linesman's box, a cold lantern, and a streamer pointing east. The cream bar hangs in front of dark rock, so it shows.",
         "draw": [_p(_HORN)] + _FANG_TOP},
        {"name": "The zip line", "z": [-2.15, -2.0], "style": "line", "tag": [-180.0, 726.6],
         "text": "A black greased cable 0.15 m thick, 2 m behind you, from the back of the post on the fang to the buffer over the deck: 26.8 m across and 5.1 m down. The trolley's wheels run on it and are scenery. A stem cranks forward from them to the bar you hold.",
         "draw": _ZIP_LINE + [_r(-166.5, 728.0, -165.9, 728.3, "pale")]},
        {"name": "The sprung buffer", "z": [-2.2, -2.0], "style": "pale", "tag": [-194.6, 721.4], "top": True,
         "text": "A post 2.7 m tall at the back of the deck, with a coil spring on its top pointing up the line. The trolley slows over the deck's east half and stops against it with the bar at 722.1 m, so your boots are at the planks.",
         "draw": _BUFFER},
        {"name": "Pylon 2's wind engine", "z": [-3.4, -3.0], "tag": [-190.4, 731.6],
         "text": "A cup wheel 5 m across on a mast over the roof, 3 m back, turning. Its belt goes down inside the tower to the two wheels of challenge 8.4. You come in under it.",
         "draw": _ENGINE2},
        {"name": "The counterweight frame's foot", "z": [-2.8, -2.0], "tag": [-197.1, 731.0],
         "text": "West of the deck, 2.5 m back: the lattice frame that the counterweights ride, and their first cable. They belong to challenge 8.8.",
         "draw": _tower(-198.6, -195.6, 719.4, 739.4) + [_ln(-197.1, 721.0, -197.1, 737.0, "line")]},
        {"name": "The deck's back", "z": [-1.6, -1.25], "style": "pale", "tag": [-189.4, 720.7],
         "text": "An open toolbox and a cold lantern at the back of the deck's east end. The toolbox is 0.7 m back today, where your boots come in: it goes to 1.3 m. The lantern is lit today and 0.8 m back: it goes cold and goes back with it.",
         "draw": [_r(-191.4, 720.0, -190.6, 720.4), _c(-190.3, 720.25, 0.15)]},
        {"name": "Under the deck: the chair shed", "z": [-2.8, -1.9], "style": "pale", "tag": [-196.6, 714.6],
         "text": "The shed of challenges 8.4 and 8.5, under the tarred roof that the deck stands on.",
         "draw": _SHED},
    ],
    "play": [
        {"name": "The handle bar", "z": [-0.35, 0.35], "style": "pale", "tag": [-167.6, 727.0],
         "text": "A cream bar 0.7 m wide on a stem 0.9 m long. The bar and the stem are held. Nothing else of the trolley is: its body, 0.5 m by 0.22 m and solid today, goes back to the line and is scenery.",
         "draw": [_r(-166.55, 727.12, -165.85, 727.28), _ln(-166.2, 727.28, -166.2, 728.1, "line")]},
        {"name": "The bar's new road", "z": [-0.1, 0.1], "style": "mark", "tag": [-188.4, 722.2],
         "text": "Today the trolley stops dead at (-186.0, 725.1), 4 m short of the deck. Its road now runs on 7.0 m further west, to (-193.0, 723.0), over the middle of the deck (note 82). The whole line is hung a little steeper to end there: where it used to stop, it is 0.8 m lower than it was. The thin broken end that hangs 4 m off the old stop goes.",
         "draw": [_ln(-166.2, 727.2, ZIP_END[0], ZIP_END[1] - 0.9), _r(ZIP_END[0] - 0.35, ZIP_END[1] - 0.98, ZIP_END[0] + 0.35, ZIP_END[1] - 0.82)]},
        {"name": "Where you step off", "z": [-1.2, 1.2], "style": "pale", "tag": [-193.0, 719.2],
         "text": "The planks under the buffer are worn pale by years of boots, 2 m of them. The place to let go is drawn on the deck.",
         "draw": [_r(-194.0, 719.85, -192.0, 720.0)]},
    ],
    "foreground": [],
    "explains": [
        ["The bar", "The zip trolley's handle", "The trolley's wheels on the line 2 m back, and the whole line from the post to the buffer"],
        ["The plate and the post", "The zip line's anchor on the fang", "The back stay and the fang's far horn"],
        ["The deck", "The maintenance deck on pylon 2's roof, where the line comes home", "The buffer post, the wind engine on its mast, the counterweight frame"],
    ],
    "pieces": [
        ["Zip trolley: a cream handle bar on a stem; its wheels", "bar 0.7 m; stem 0.9 m", "1", "Play space; the wheels behind", "kit: zip trolley"],
        ["Cable: the zip line", "0.15 m thick, 29 m", "1", "Background", "kit: cable"],
        ["Anchor post with a back stay; sprung buffer post", "posts 2.7 m; stay 4.5 m", "1 each", "Play space (the anchor post); the rest behind", "kit: the zip line's two ends"],
        ["The fang's far horn", "20 m wide, 2.5 m deep", "1", "Background", "kit: the fang's far horn (added)"],
        ["Wind engine on a mast", "5 m across; mast 10 m", "1", "Background", "kit: wind engine"],
        ["Plank deck with a worn patch", "6 m; patch 2 m", "1", "Play space", "kit: tower fittings"],
        ["Open toolbox; cold lantern; linesman's box; streamer pole", "0.8 m; 0.5 m; 0.6 m; 3 m", "1 each", "Background", "kit: toolbox, cold lantern, streamer pole"],
        ["Far cable and a stopped car", "car 2.6 m", "1", "Background, 20 m back", "kit: the far line"],
    ],
    "effects": [
        "The trolley's wheels sing on the cable, rising as it speeds up and falling as it slows over the deck.",
        "The buffer's spring gives 0.3 m and comes back, with a clank.",
        "The town, tiny, passing straight under your boots in the painted valley.",
    ],
    "notes": [
        "Note 82: the zip line goes all the way. The trolley's road is 7.0 m longer and ends at (-193.0, 723.0), against a sprung buffer over the middle of the deck. There is no timed let-go: you ride, it slows, you stand.",
        "Note 82: what is left as the challenge is the catch, the ride and stepping off. Its difficulty is 4 today and comes down. It is to be rated again.",
        "To measure when it is built: that your boots clear the deck's east lip. With the bar at 722.7 m there, a hanging body has about 0.5 m to spare.",
        "Note 77, the rule: only the bar and the stem are solid, and both are drawn. The trolley's body stops being solid.",
        "Scenery that moves out of the play space: the zip wire (0.5 m back) becomes a cable 2 m back. The 16 m pennant line along it (0.6 m back) goes, because a trolley runs there. The lit lantern over the deck (0.8 m back) goes cold and the toolbox (0.7 m back) goes to 1.3 m.",
    ],
    "ask": [
        "With the timed let-go gone, Tirolesa is a catch and a ride. Is that enough, or should the ride ask one thing of you on the way in, such as lifting your legs over a rail on the deck's east end? This design has the plain ride.",
    ],
}

# ------------------------------------------------------------------ 8.8 Contrapesos
_W88 = [-210.0, 716.0, -186.0, 765.0]

CONTRAPESOS = {
    "id": "8.8", "slug": "8_8_contrapesos", "title": "Contrapesos", "kind": "challenge",
    "window": _W88, "cut_y": 735.0, "climber": [-193.0, 720.0],
    "place": ("Above pylon 2's roof a steel frame climbs 36 m to pylon 3. A wheel sits on its top, and one cable hangs over that wheel "
              "and down both sides with two counterweight blocks on each side: cream blocks with red bands and the pug on the face, "
              "each as big as a wardrobe. They are the express lines' counterweights. The wheel is on the same shaft that hauls the "
              "express cars, so while those cars run one way the wheel turns one way, and when they come back it turns back. One "
              "side rises 7 m as the other falls 7 m, they wait a second, and they go back. Twice a round two block tops stand "
              "level, 1.6 m apart. That second is the stair: you step from block to block, four times, from the maintenance deck to "
              "pylon 3's head."),
    "keep": [
        "Four blocks, 1.6 m wide and 1.2 m tall, in two columns 1.6 m apart. Each rides 7 m in 4 seconds and waits 1 second at each end. The columns run against each other.",
        "Two tops stand level at 727.5 m, at 734.5 m and at 741.5 m, for one second each time.",
        "The first block's top comes down to 0.5 m over the deck, 0.3 m off its end. The last block's top comes up to 0.5 m under pylon 3's head, 0.4 m off its end.",
        "Pylon 3's head: 4.1 m of planks at 749.0 m, with one rail post.",
    ],
    "background": [
        {"name": "The far line", "z": [-20.5, -20.0], "style": "mark", "tag": [-188.0, 732.2],
         "text": "20 m back and hazed: the dead second line's slack cable, crossing level behind the frame at 731 m.",
         "draw": _far(_W88)},
        {"name": "The frame and the long girder", "z": [-2.9, -2.5], "tag": [-197.1, 746.0],
         "text": "A lattice frame 2.5 m back, standing on pylon 2's roof, with the long girder across its top to pylon 3. Today the frame is a card 1.4 m back and its top beam is 0.5 m back, inside the play space. Both go to 2.5 m.",
         "draw": _FRAME + _girder(-210.0, -195.6, 754.6, 755.8)},
        {"name": "The top wheel", "z": [-2.3, -2.0], "style": "line", "tag": [-198.7, 757.4],
         "text": "A greyed wheel 3.2 m across on top of the girder: exactly as wide as the two columns are apart. One cable goes over it and down both sides, so when one column rises the other must fall. It turns one way, stops, and turns back.",
         "draw": _wheel(-198.7, 757.4, 1.6)},
        {"name": "The two cables and the blocks' arms", "z": [-2.15, -1.2], "style": "line", "tag": [-200.3, 725.0],
         "text": "Black greased cable, 0.15 m thick, 2 m behind you. Today the two cables are thin dark lines 0.4 m back, inside the play space, where they read as ropes to hold. They go back to 2 m. A short arm cranks forward from the cable to the back of each block.",
         "draw": [_ln(-197.1, 721.0, -197.1, 757.4), _ln(-200.3, 728.0, -200.3, 757.4)] + [_r(x - 0.25, y + 0.5, x + 0.25, y + 0.72, "pale") for x, y in _BLOCKS]},
        {"name": "Level plates on the frame", "z": [-2.5, -2.4], "style": "pale", "tag": [-198.7, 738.0], "top": True,
         "text": "On the frame's west leg, which shows in the gap between the two columns: a plate 1 m wide at each height where two block tops stand level, and at the foot and the top of the ride. You can see where a block will stop before it gets there.",
         "draw": [_r(-199.2, y - 0.15, -198.2, y + 0.15) for y in _LEVELS]},
        {"name": "Pylon 3", "z": [-2.8, -2.5], "tag": [-203.7, 728.0],
         "text": "The third tower, 2.5 m back, rising from below the frame to carry the head, with the peeling pug crest under it. Today it is a card 1.2 m back.",
         "draw": _PYLON3 + [_c(-203.7, 752.4, 0.7, "line")]},
        {"name": "Pylon 3's wind engine", "z": [-3.4, -3.0], "tag": [-206.4, 763.6],
         "text": "A cup wheel 5 m across on a mast on pylon 3's top, 3 m back. Its belt comes down to the shaft in the long girder. It hauls the express lines, and through them it works these weights.",
         "draw": _ENGINE3},
        {"name": "Pylon 2's wind engine and the deck's back", "z": [-3.4, -1.25], "tag": [-190.2, 731.4],
         "text": "Behind the deck you start from: the engine that turns pylon 2's wheels, the zip line's buffer post, an open toolbox and a cold lantern.",
         "draw": _ENGINE2 + _BUFFER + [_r(-191.4, 720.0, -190.6, 720.4, "pale")]},
        {"name": "The one who tried", "z": [-1.7, -1.3], "style": "pale", "tag": [-203.3, 750.6],
         "text": "A frozen climber, sitting at the back of pylon 3's head with his back to the tower, looking west at the dead gondola. He got this far. He is right behind the place where you step off the last block.",
         "draw": _FROZEN},
        {"name": "A streamer on pylon 3's head", "z": [-1.7, -1.5], "style": "pale", "tag": [-206.4, 751.6],
         "text": "A streamer pole at the back of the head's west end, 3 m tall, pointing east.",
         "draw": _streamer(-205.2, 749.0)},
    ],
    "play": [
        {"name": "The four blocks", "z": [-0.6, 0.6], "style": "pale", "tag": [-194.9, 733.9],
         "text": "Cream with two red bands and the pug on the face, 1.6 m wide and 1.2 m tall, with an iron lifting eye 0.5 m tall on top. The block and its eye are held, and the model is made at exactly that size. The whole block is cream: all of it is yours to take.",
         "draw": [_r(x - 0.8, y - 1.2, x + 0.8, y) for x, y in _BLOCKS]},
        {"name": "Pylon 3's head", "z": [-1.2, 1.2], "style": "mark", "tag": [-207.0, 748.2],
         "text": "Honey planks on steel, 4.1 m, with the rail post you lean out from on its west end. Its east end is where the last block sets you down.",
         "draw": [_r(-205.6, 748.6, -201.5, 749.0), _r(-205.52, 749.0, -205.38, 750.2)]},
    ],
    "foreground": [],
    "explains": [
        ["The maintenance deck", "The linesmen's deck on pylon 2's roof", "The zip line's buffer, the wind engine on its mast, the toolbox"],
        ["The four blocks", "The express lines' counterweights", "The cable over the top wheel, the arm behind each block, the frame they ride"],
        ["The second when two tops stand level", "The ends of the weights' ride", "A level plate on the frame's leg at each of those heights"],
        ["Pylon 3's head", "The head of the third tower", "Pylon 3, the pug crest, and the one who tried"],
    ],
    "pieces": [
        ["Counterweight: a cream block with red bands, the pug, a lifting eye; its arm", "1.6 m wide, 1.2 m tall; eye 0.5 m", "4", "Play space; the arm behind", "kit: counterweight"],
        ["Lattice frame; pylon 3", "3 m and 2.6 m wide, bays 4 m tall", "1 each", "Background", "kit: lattice tower"],
        ["Long girder with its shaft", "23 m long, 1.2 m deep", "1", "Background", "kit: link girder (added)"],
        ["Top wheel, greyed", "3.2 m across", "1", "Background", "kit: counterweight (the top wheel)"],
        ["Cable", "0.15 m thick; 36 m and 29 m", "2", "Background", "kit: cable"],
        ["Level plate", "1 m by 0.3 m", "5", "Background", "new, this area only"],
        ["Wind engine on a mast", "5 m across", "2 in this frame", "Background", "kit: wind engine"],
        ["Frozen climber, sitting", "1.2 m tall", "1", "Background", "kit: frozen climber"],
        ["Plank head with one rail post; plank deck", "4.1 m; 6 m", "1 each", "Play space", "kit: tower fittings"],
        ["Peeling pug crest; streamer pole; toolbox; cold lantern", "1.4 m; 3 m; 0.8 m; 0.5 m", "1 each", "Background", "kit: pug crest, streamer pole, toolbox, cold lantern"],
    ],
    "effects": [
        "The top wheel turns, stops and turns back, and the two cables run opposite ways past the level plates.",
        "A soft clunk when a block reaches a plate.",
        "Frost on the frozen climber's mask. No frost on anything else here.",
    ],
    "notes": [
        "Note 83: this is where the rule is felt most. Two tops stand level, one about to rise and one about to fall. Held between them, you keep the block more of your limbs are on, or the higher one. A rule of play. Nothing is drawn for it.",
        "Notes 76 and 77, the rule: each block is modelled at exactly 1.6 m by 1.2 m with its eye, and nothing else of it is solid.",
        "Scenery that moves out of the play space: the two cables (0.07 m thick, 0.4 m back) become 0.15 m thick and go 2 m back. The frame's card goes from 1.4 m back to 2.5 m, its top beam from 0.5 m back to 2.5 m, pylon 3's card from 1.2 m back to 2.5 m. The pug crest (1.0 m back) and the lantern under the head (0.8 m back, lit) go to the tower, and the lantern goes cold.",
        "Note 78: no pinch is kept. The first block passes the deck's end 0.3 m to its side and the last passes the head's end 0.4 m to its side. Neither closes on anything. To check when the crunch rule is built.",
        "To settle when it is built: the weights take 10 seconds a round and the express cars 10.25 seconds a run. If the two are to look joined, as this page says they are, the times should match.",
    ],
}

# ------------------------------------------------------------------ 8.9 La Góndola Rota
_W89 = [-226.0, 741.0, -198.0, 766.0]

LA_GONDOLA_ROTA = {
    "id": "8.9", "slug": "8_9_la_gondola_rota", "title": "La Góndola Rota", "kind": "challenge",
    "window": _W89, "cut_y": 754.6, "climber": [-203.5, 749.0],
    "place": ("Pylon 3 is the junction. The line from the valley ends on its head, and the four express lines to the high station start "
              "16 m to the west, at their own tower. Between the two ran a shuttle: one gondola on a rail under the long girder, to "
              "and fro. One of its two arms broke. The car now hangs from the other by a corner of its roof, crooked, west end low, "
              "with its back door hanging open, and it swings when anything moves on it. It is still the only way across. In by the "
              "east window, out by the roof hatch, down to the rack on its low end, swing it, and jump: 4 m west to the rack of the "
              "first express car, which waits there for a second and a half."),
    "keep": [
        "The dead car is a real hanging body of 120 kg on one hinge. It hangs about 30 degrees off level and swings only when you move on it.",
        "The way through it: the east window, 1 m high. The roof hatch, 0.9 m. The rack on its low west end, 1.6 m.",
        "The jump: 4.1 m west and 0.6 m down, to the rack of express line 1's car, which waits 1.5 seconds at its east end every 20 seconds.",
        "The grate under that car, 1.6 m of iron at 746.5 m, for anyone who would sooner land on something still.",
        "Pylon 3's head and the rail post you lean out from.",
    ],
    "background": [
        {"name": "Pylon 3 and the express tower", "z": [-2.8, -2.5], "tag": [-220.2, 743.6],
         "text": "Two lattice towers 2.5 m back. Pylon 3 is a card 1.2 m back today. The express tower is new: today the four express cables end in the air at x -214.5, with nothing holding them and nothing under the grate. It stands under the grate, with an arm, a buffer and a greyed guide wheel at the end of each line.",
         "draw": _PYLON3 + _EXTOWER},
        {"name": "The long girder: the shuttle's rail", "z": [-2.9, -2.0], "tag": [-214.0, 756.6], "top": True,
         "text": "A lattice girder 2.5 m back at 754.6 m, 23 m long, from the express tower across pylon 3 to the counterweight frame. The shuttle ran on a rail under it, between a buffer at each end. A shaft inside it carries the wind engine's turn to a winding drum on the express tower. A 7.2 m length of it, over the dead car, is a solid iron beam in the play space today. That is 5.5 m above the head and out of reach, so nothing changes in the play when it goes back with the rest.",
         "draw": _girder(-218.7, -198.0, 754.6, 755.8) + [_r(-202.6, 754.1, -202.3, 754.6), _r(-218.6, 754.1, -218.3, 754.6), _c(-220.2, 755.2, 0.9, "line")]},
        {"name": "The arm that held, and the arm that broke", "z": [-2.1, -1.2], "style": "line", "tag": [-212.3, 753.4],
         "text": "Both of the car's arms went up to carriages on the rail. The east one still holds: it is scenery now, greyed and behind you. The west carriage is still on the rail, with a sheared stub of arm 0.7 m long under it.",
         "draw": [_ln(-208.6, 754.2, -207.93, 752.86), _r(-208.9, 754.25, -208.3, 754.55, "pale"), _r(-211.5, 754.25, -210.9, 754.55, "pale"), _ln(-211.2, 754.25, -211.3, 753.55)]},
        {"name": "The car's back door", "z": [-1.4, -1.2], "style": "pale", "tag": [-208.2, 751.0],
         "text": "On the car's back wall, 1.2 m behind you: a door with the peeling pug crest, hanging open by its top hinge. It is the back of the car, seen through the open side, and it is never in your way.",
         "draw": [_p([(-208.75, 750.15), (-207.95, 750.55), (-208.55, 751.95), (-209.35, 751.55)])]},
        {"name": "Express lines 1 to 3, and the car's arm", "z": [-2.15, -1.2], "style": "line", "tag": [-224.0, 757.6],
         "text": "Three of the four express cables, 2 m behind you, going up west out of the frame from the tower's arms. The first express car hangs from the lowest by its arm, which is scenery.",
         "draw": [_ln(-217.5, g[1] - 0.47, -226.0, g[1] + 7.5 * EX_SLOPE) for g in EX_E[:3]] + _hanger(EX_E[0])},
        {"name": "The one who tried", "z": [-1.7, -1.3], "style": "pale", "tag": [-201.2, 750.4],
         "text": "A frozen climber sitting at the back of the head, with his back to the tower, looking at the dead gondola. He is the only one on the cableway.",
         "draw": _FROZEN},
        {"name": "Pylon 3's wind engine and a streamer", "z": [-3.4, -1.5], "tag": [-200.6, 762.8],
         "text": "Above the girder, 3 m back: the cup wheel that hauls the express lines, its belt coming down to the girder's shaft. At the back of the head, a streamer pole pointing east.",
         "draw": _ENGINE3 + _streamer(-205.2, 749.0)},
    ],
    "play": [
        {"name": "The dead car, every solid part drawn", "z": [-0.6, 0.6], "style": "pale", "tag": [-211.6, 748.4],
         "text": "It is the same car as the ones that run, and the model shows every part you can touch at its true size: the roof in two pieces with the hatch between, the floor, the two low end walls, and the rack on its west end, 1.6 m long, which is solid today and not drawn (note 77). Cream bands on the roof's edges, the hatch's rim, the floor's edge and the rack.",
         "draw": [_p(_DEAD_RACK)]},
        {"name": "No longer solid: the car's arm and the crossarm", "z": [-0.1, 0.1], "style": "mark", "tag": [-206.2, 753.6],
         "text": "The car's one arm, 1.5 m long and 0.12 m thick, and the crossarm it hangs from, an iron beam 7.2 m long at 754.6 m. Both are solid today. Both become scenery. Nothing in the route uses either.",
         "draw": [_ln(-208.6, 754.2, -207.93, 752.86), _ln(-209.2, 754.6, -202.0, 754.6)]},
        {"name": "Warning stripes on the head's west end", "z": [-1.2, 1.2], "tag": [-206.3, 749.5],
         "text": "The car's east corner hangs 1.4 m from the rail post, and a hard swing brings it in over the head's edge. So the post and the last 0.6 m of the head wear the slanted yellow and black stripes (note 78).",
         "draw": [_r(-205.6, 748.6, -205.0, 749.0), _r(-205.52, 749.0, -205.38, 750.2)]},
        {"name": "The express car's rack and step", "z": [-0.5, 0.5], "style": "pale", "tag": [-215.4, 747.6],
         "text": "The rack you jump to, 2.4 m, and the short step on the car's far end, 0.6 m: both drawn at the length they are, with a cream band (note 77).",
         "draw": _ends(EX_E[0], 0.6, 2.4)},
    ],
    "foreground": [],
    "explains": [
        ["The head and its rail post", "Pylon 3's head: the shuttle's east platform", "Pylon 3, the buffer on the girder's rail, the one who tried"],
        ["The dead car", "The shuttle's car", "The rail under the long girder, the arm that holds, the stub of the one that broke"],
        ["The window, the hatch, the rack", "A gondola's window, the linesmen's roof hatch, its freight rack", "The back door hanging open behind them"],
        ["The express car's rack", "Express line 1's car at its east stop", "The express tower, its arm and guide wheel, the cable going up west"],
        ["The grate", "The express tower's landing", "The express tower it is bolted to"],
    ],
    "pieces": [
        ["Dead gondola with its rack, back door and one arm", "2.6 m wide, 2.2 m tall; rack 1.6 m", "1", "Play space; the arm and door behind", "kit: dead gondola"],
        ["Long girder with its rail, two buffers, a shaft and a winding drum", "23 m long; drum 1.8 m across", "1", "Background", "kit: link girder (added); the drum is new"],
        ["Rail carriage; sheared arm stub", "0.6 m; 0.7 m", "2; 1", "Background", "kit: gondola (its hanger)"],
        ["Lattice tower: pylon 3; the express tower with four arms", "2.6 m and 3 m wide, bays 4 m tall; arms 1.8 m", "1 each", "Background", "kit: lattice tower and crossarm"],
        ["Guide wheel, greyed", "1 m across", "4", "Background", "kit: guide wheel (added)"],
        ["Gondola with its step, rack and cranked hanger arm", "2.6 m wide, 2.2 m tall; step 0.6 m; rack 2.4 m", "1 here", "Play space; the arm behind", "kit: gondola"],
        ["Iron grate; plank head with one rail post", "1.6 m; 4.1 m", "1 each", "Play space", "kit: tower fittings"],
        ["Frozen climber, sitting", "1.2 m tall", "1", "Background", "kit: frozen climber"],
        ["Wind engine; streamer pole", "5 m across; 3 m", "1 each", "Background", "kit: wind engine, streamer pole"],
        ["Warning stripes", "paint, 0.6 m and the post", "1", "Play space (drawn on)", "kit: warning stripes"],
    ],
    "effects": [
        "The car groans on its one arm when you land on it, and the open door swings a beat behind the car.",
        "Flakes of paint and a little rust fall from the carriage each time the car swings.",
        "The camera stands back as you reach the rack, and shows the drop under the jump.",
    ],
    "notes": [
        "Note 77: the dead car's rack, 1.6 m, is drawn. So are the express car's rack and step.",
        "The sheet's call from note 80: the dead car's arm (1.5 m long, 0.12 m thick) and the crossarm above it (7.2 m long, 0.25 m thick, at 754.6 m) stop being solid and go behind. Nothing in the route uses either.",
        "Note 78: one pinch is kept and striped: the head's west end and its rail post, where the car's east corner can swing in.",
        "To check when the crunch rule is built: a climber standing on the grate has 2 cm of headroom under the express car's step when it stops. The route asks you to stand there and reach up, so it is not striped.",
        "Scenery that moves out of the play space: pylon 3's card goes from 1.2 m back to 2.5 m. The express lines' wires (0.5 m back) become cables 2 m back and end on the new express tower. The lantern under the head goes cold.",
    ],
}

# ------------------------------------------------------------------ 8.10 Vía Rápida
_W810 = [-268.0, 746.0, -216.0, 792.0]
_MID_ARMS = []
for _g in EX_E:
    _ya = _g[1] + 25.5 * EX_SLOPE                         # each cable's height where it crosses the middle tower
    _MID_ARMS += [_r(-246.3, _ya - 0.15, -241.7, _ya + 0.15, "pale"), _c(-244.0, _ya, 0.4, "line")]

VIA_RAPIDA = {
    "id": "8.10", "slug": "8_10_via_rapida", "title": "Vía Rápida", "kind": "challenge",
    "window": _W810, "cut_y": 765.0, "climber": [-220.2, 746.5],
    "place": ("The express lines: four cables, one over the next, 5.1 m apart, climbing 47.5 m west and 22.5 m up from the express "
              "tower to the high station. One car on each. They were the fast way to the glacier, and they run in pairs, so as one "
              "car goes up the next one comes down and they pass in the middle. The middle is marked by the tall tower that carries "
              "all four cables. Every ten seconds, in front of that tower, each car passes the car of the line above it, at 12 m a "
              "second between them. Standing on a car's roof with a hand up, the short step on the end of the car above takes you. "
              "Three times, and the fourth car carries you to the high station. The camera stands far back here: it shows 28 m of "
              "height, so both cars' whole roads are in sight. This sketch is 52 m wide for the same reason."),
    "keep": [
        "Four lines, 5.1 m one over the next, each 47.5 m across and 22.5 m up. One car on each at 6 m a second, waiting 1.5 seconds at each end. Lines 1 and 3 start at the east end, lines 2 and 4 at the west.",
        "The transfer: the step on the upper car, 0.6 m long, clears the lower car's cable by 0.43 m. Standing on the lower roof your head is just under it and your raised hand is 0.2 m over it.",
        "Three transfers, in the middle of the span, then the ride on line 4 to its west end.",
        "The grate at 746.5 m, where the challenge starts.",
    ],
    "background": [
        {"name": "The mountain's shoulder", "z": [-14.0, -12.0], "tag": [-266.4, 752.0],
         "text": "On the west of the frame, 12 m back: the flat cut-out of the mountain that began on the cliffs, carried on up. Here it is dark scree with snow lying in its gullies. It is the only thing of ours behind the lines. East of it there is the far view and nothing else.",
         "draw": _shoulder(_W810)},
        {"name": "The four cables", "z": [-2.15, -2.0], "style": "line", "tag": [-256.0, 781.6],
         "text": "Black greased cable, 0.15 m thick, 2 m behind you, from the express tower's arms up to the high station. Today they are thin wires 0.5 m back, inside the play space, and they stop in the air at both ends.",
         "draw": [_ln(-217.5, g[1] - 0.47, -268.0, g[1] + 49.5 * EX_SLOPE) for g in EX_E]},
        {"name": "The middle tower", "z": [-2.8, -2.5], "tag": [-244.0, 754.0], "top": True,
         "text": "It stands on the low station far below and comes up through this frame, exactly behind the place where the cars pass. It has four arms, one for each cable, each with a saddle wheel, and a pug crest. A car's arm goes by in front of an arm of the tower at the moment of the transfer, so you know where to be ready before a car is anywhere near. Today it is a card 1.6 m back. It goes to 2.5 m.",
         "draw": _tower(-245.5, -242.5, 744.0, 792.0) + _MID_ARMS + [_c(-244.0, 759.4, 0.7, "line")]},
        {"name": "The express tower", "z": [-2.8, -2.0], "tag": [-220.2, 770.0],
         "text": "At the lines' east end, 2.5 m back: a lattice tower with the grate on its side, an arm, a buffer and a greyed guide wheel for each line, and the winding drum on the end of the long girder that the wind engine on pylon 3 turns. It is new. Today nothing holds the cables' east ends.",
         "draw": _EXTOWER + _girder(-218.7, -216.0, 754.6, 755.8) + [_c(-220.2, 755.2, 0.9, "line")]},
        {"name": "The cars' hanger arms", "z": [-2.1, -1.2], "style": "line", "tag": [-264.6, 779.0],
         "text": "One arm for each car, from its carriage on the cable down to the back of its roof. Scenery: greyed, behind you, and no longer solid. On the roof you stand in front of it.",
         "draw": _hanger(EX_E[0]) + _hanger(EX_W[1]) + _hanger(EX_E[2]) + _hanger(EX_W[3])},
        {"name": "One line of pennants, above the top cable", "z": [-2.1, -2.0], "tag": [-240.0, 784.4],
         "text": "Today two lines of pennants, each 40 m long, hang 0.6 m back, inside the play space. The lower one runs between lines 2 and 3, exactly where a hand goes up for a step. It goes. The upper one already runs 4.5 m above the top cable, where no hand comes. It stays there and goes back to 2 m. It streams east, down the lines.",
         "draw": _pennants(-259.75, 791.9, -223.75, 774.5, every=2.5)},
    ],
    "play": [
        {"name": "Step and rack on all four cars", "z": [-0.5, 0.5], "style": "pale", "tag": [-261.4, 787.6],
         "text": "Each express car has a short step out of its west end, 0.6 m, and a rack out of its east end, 2.4 m. Both are solid today and neither is drawn (note 77). The step is the whole transfer, so it is modelled at exactly 0.6 m with a cream band on its top and a cream lip underneath, where a raised hand meets it.",
         "draw": _ends(EX_E[0], 0.6, 2.4) + _ends(EX_W[1], 0.6, 2.4) + _ends(EX_E[2], 0.6, 2.4) + _ends(EX_W[3], 0.6, 2.4)},
        {"name": "The roof you stand on", "z": [-0.6, 0.6], "style": "pale", "tag": [-218.5, 749.6],
         "text": "A car's flat roof, 2.6 m long, with a cream band along both long edges. Stand tall on it with a hand up.",
         "draw": [_r(g[0] - 1.3, g[1] - 1.6, g[0] + 1.3, g[1] - 1.4) for g in (EX_E[0], EX_W[1], EX_E[2], EX_W[3])]},
        {"name": "The grate", "z": [-1.2, 1.2], "style": "mark", "tag": [-222.2, 746.4],
         "text": "Open iron grating, 1.6 m, on the express tower's side, under the place where the first car's step stops.",
         "draw": [_r(-221.0, 746.25, -219.4, 746.5)]},
    ],
    "foreground": [],
    "explains": [
        ["The roof you stand on", "A gondola's roof", "Its hanger arm and its cable, 2 m back"],
        ["The step that takes you", "The boarding step of the car on the next line up", "That line's cable, 5.1 m above yours"],
        ["The place where they pass", "The middle of every span", "The middle tower, right behind it, with an arm for each cable"],
        ["The grate", "The express tower's landing", "The express tower, and the winding drum on the girder's end"],
        ["The fourth car's ride", "The top line's car going home", "Its cable going up into the high station, under the one line of pennants"],
    ],
    "pieces": [
        ["Gondola with its step, rack and cranked hanger arm", "2.6 m wide, 2.2 m tall; step 0.6 m; rack 2.4 m", "4", "Play space; the arm behind", "kit: gondola"],
        ["Cable", "0.15 m thick, 53 m in this frame", "4", "Background", "kit: cable"],
        ["Lattice tower: the middle tower, with four arms and saddle wheels", "3 m wide, bays 4 m tall; arms 4.6 m", "1", "Background", "kit: lattice tower and crossarm"],
        ["Lattice tower: the express tower, with four arms and buffers", "3 m wide; arms 1.8 m", "1", "Background", "kit: lattice tower and crossarm"],
        ["Guide wheel, greyed", "1 m across", "4", "Background", "kit: guide wheel (added)"],
        ["Winding drum on the girder's end", "1.8 m across", "1", "Background", "new, with 8.9"],
        ["Pennant line", "40 m", "1", "Background", "kit: pennant line"],
        ["Iron grate", "1.6 m", "1", "Play space", "kit: tower fittings"],
        ["The mountain's shoulder", "sections 30 m tall", "2 in this frame", "Background, 12 m back", "kit: the mountain's shoulder"],
    ],
    "effects": [
        "A rising hum on the cable before a car comes into the frame, and a clack as each car's carriage crosses the middle tower's saddle wheel.",
        "The first snowflakes begin above 770 m and thicken toward the high station. The course has them today.",
        "Gold light on the cars' east ends, blue shadow on their west ends.",
    ],
    "notes": [
        "Note 77: the step (0.6 m) and the rack (2.4 m) are drawn on all four express cars. Neither moves.",
        "The sheet's call from note 80: the four cars' hanger arms, 1.5 m tall and 0.12 m thick, stop being solid and go behind. The course allows a second way to transfer, up the lower car's hanger to the upper car's floor. That way goes with the hangers. The step is the transfer.",
        "Note 83: when you hold your own car and the step of the car above at once, you keep the one more of your limbs are on, or the higher. The higher is the car you want.",
        "Note 78: no pinch is kept. A car passing over a roof clears a standing head by 0.06 m, which is the challenge itself, and a hit at that speed already knocks you out.",
        "Scenery that moves out of the play space: the four wires (0.5 m back) become cables 2 m back. Of the two 40 m pennant lines (0.6 m back), the lower one, between lines 2 and 3, goes. The upper one stays 4.5 m above the top cable and goes back to 2 m. The middle tower's card goes from 1.6 m back to 2.5 m. The express tower is added, 2.5 m back.",
        "Note 89: the pennants stream east. No wavy wind lines, because this wind does not push.",
    ],
}

# ------------------------------------------------------------------ 8.11 La Estación Alta
_W811 = [-289.0, 777.0, -259.0, 800.0]
_ICE = [(-271.0, -268.0), (-276.4, -272.6), (-280.6, -277.6)]
_DRY = [(-272.6, -271.0), (-277.6, -276.4), (-282.0, -280.6)]

LA_ESTACION_ALTA = {
    "id": "8.11", "slug": "8_11_la_estacion_alta", "title": "La Estación Alta", "kind": "challenge", "also": ["a9"],
    "window": _W811, "screen": [-275.0, 788.5], "cut_y": 786.0, "climber": [-268.8, 786.0],
    "place": ("The high station, at 786 m: the top of the cableway and the last made floor on the mountain. It is the same station as "
              "the one below, a board house under a striped tin roof, with the pug's sign, a ticket window and a deck of honey "
              "planks 14 m long. Then one winter the glacier came down over it. The ice lies on its roof and has buried its west "
              "half. It has filled the docks under the deck, where the two lower express lines came in, and it has put out a tongue "
              "across the deck itself. The wind engine on its roof is frozen still and white with frost. The fourth express car "
              "still stops at the deck's east end for a second and a half. You step off onto ice: the first ice on the climb, which "
              "holds you for two seconds and then lets go."),
    "keep": [
        "The deck: 14 m at 786.0 m, against the face. Three sheets of ice, 3.0 m, 3.8 m and 3.0 m long, and three dry patches, 1.6 m, 1.2 m and 1.4 m.",
        "Ice holds for 2 seconds, lets go, and takes you again 0.6 seconds later.",
        "The fourth car stops for 1.5 seconds with the tip of its step at the deck's east edge, 0.15 m above it.",
        "Black ice under the deck's east end and up its east edge, so the deck is only taken from above, off the car.",
    ],
    "background": [
        {"name": "The swallowed docks", "z": [-6.0, -1.3], "style": "dark", "tag": [-272.4, 782.6],
         "text": "Under the deck the station had two more docks, for the lower pair of express lines. The glacier has filled them: a mass of blue-black ice, glossy, from the face out to the deck's east end, 1.3 m and more behind you. The two lower cables run straight into it through frost-rimmed holes they have sawn for themselves. The black ice under the deck's east end in the play space is the near edge of this.",
         "draw": [_p([(-289.0, 777.0), (-274.0, 777.0), (-271.0, 779.2), (-269.2, 781.4), (-268.2, 783.4), (-268.2, 785.4), (-289.0, 785.4)]),
                  _c(-270.2, 781.7, 0.5, "line"), _c(-273.0, 777.9, 0.5, "line")]},
        {"name": "The deck's brackets", "z": [-2.8, -2.5], "style": "line", "tag": [-277.0, 779.4],
         "text": "Two lattice brackets from under the deck back to the face, half sunk in the ice. The deck's strut is a card 0.7 m back today, inside the play space. It goes to 2.5 m.",
         "draw": [_ln(-270.4, 785.3, -279.4, 777.8), _ln(-274.9, 785.3, -279.9, 781.1)]},
        {"name": "The station house, half buried", "z": [-5.5, -2.5], "style": "pale", "tag": [-270.0, 788.0],
         "text": "The same house as at the low station, 14 m wide and 6 m tall, standing 2.5 m back, with no roof and no post over the deck (note 77). Board walls, red below cream. Dark windows, the pug sign on the wall, a cold lantern by the ticket window. Snow is drifted against its west half up to the eaves, and the glacier's lip lies on its roof. Today its peaked roof is a card 1 m back, in the play space and inside the glacier's lip. It goes.",
         "draw": [_r(-282.0, 786.0, -268.3, 790.4), _p([(-282.6, 790.4), (-267.7, 790.4), (-268.6, 792.0), (-282.6, 792.0)], "solid"),
                  _r(-275.6, 787.2, -274.4, 788.4, "dark"), _r(-278.4, 788.7, -276.2, 789.9, "solid"), _c(-273.9, 788.6, 0.15, "solid"),
                  _p([(-282.0, 786.0), (-282.0, 789.8), (-279.6, 789.0), (-277.4, 787.4), (-275.8, 786.4), (-274.6, 786.0)], "solid")]},
        {"name": "The express cables coming in", "z": [-2.15, -2.0], "style": "line", "tag": [-262.4, 783.6],
         "text": "The four cables, 2 m behind you. The upper pair comes in over the deck to the bull wheel on the front of the house. The lower pair goes under the deck into the ice.",
         "draw": [_ln(-259.0, 786.58, -271.0, 792.27), _ln(-259.0, 781.48, -272.0, 787.64), _ln(-259.0, 776.38, -270.2, 781.69), _ln(-271.07, 777.0, -273.0, 777.9)]},
        {"name": "The upper pair's bull wheel", "z": [-2.3, -2.0], "style": "line", "tag": [-271.5, 789.95], "top": True,
         "text": "Lines 3 and 4 are one loop of cable, and it turns back here over a greyed bull wheel 4.4 m across on the front of the house, at its east end, 2 m back. It still turns, one way and then the other, as the cars come and go, and a little frost falls from it each time.",
         "draw": [_c(-271.5, 789.95, 2.2, "solid")] + _wheel(-271.5, 789.95, 2.2)},
        {"name": "The frozen wind engine", "z": [-3.4, -3.0], "tag": [-266.4, 797.6],
         "text": "On the roof's east end, 3 m back: the same cup wheel as on the towers below, stopped, white with frost, with snow in its cups. It is the only engine on the cableway that does not turn.",
         "draw": _engine(-269.5, 796.0, 792.0)},
        {"name": "The car's hanger arm", "z": [-2.1, -1.2], "style": "line", "tag": [-265.0, 789.2],
         "text": "Scenery: greyed, behind you, no longer solid.",
         "draw": _hanger(EX_W[3])},
        {"name": "The last pennants, frozen stiff", "z": [-2.1, -2.0], "tag": [-264.0, 794.2],
         "text": "A last line of pennants, 10 m long, from the end of the express lines' pennants to the frozen engine's mast. It is white with frost and does not move. It still points east.",
         "draw": _pennants(-259.75, 791.9, -269.5, 794.6)},
    ],
    "play": [
        {"name": "The tongue of ice", "z": [-1.2, 1.2], "style": "pale", "tag": [-274.5, 784.6],
         "text": "Pale blue ice, frosted and matte, lying over the planks in three sheets with a white frost edge. It is the glacier's own ice and it looks the way every hold that lets go will look in the next biome. Between the sheets the planks show.",
         "draw": [_r(a, 786.0, b, 786.14) for a, b in _ICE]},
        {"name": "Three dry patches", "z": [-1.2, 1.2], "style": "mark", "tag": [-279.0, 784.6],
         "text": "Bare honey planks with boot scuffs: the only places on the deck that hold you for good. The course gives two of them the rock's colour today. All three are plank.",
         "draw": [_r(a, 785.4, b, 786.0) for a, b in _DRY]},
        {"name": "The fourth car's step", "z": [-0.5, 0.5], "style": "pale", "tag": [-267.6, 784.9],
         "text": "0.6 m of iron with a cream band, drawn at the length it is (note 77). It stops 0.15 m above the deck's east edge.",
         "draw": _ends(EX_W[3], 0.6, 2.4)},
        {"name": "A frozen glove", "z": [-0.6, 0.6], "style": "line", "tag": [-279.0, 787.0],
         "text": "On the ice near the deck's west end: one glove, frozen to the planks. Somebody held on here for two seconds. It is 0.6 m back today and stays there.",
         "draw": [_c(-279.0, 786.14, 0.16)]},
    ],
    "foreground": [
        {"name": "One platform post", "z": [1.3, 1.6], "tag": [-281.4, 794.0],
         "text": "A square station post in the cableway's red, 0.3 m wide, in front of the deck's west end, where the planks meet the rock. It matches the scaffold post in front of the low deck's west end. It covers a strip 0.3 m wide, at a place where nothing has to be read.",
         "draw": [_r(-281.55, 779.0, -281.25, 790.6)]},
        {"name": "A lip of drifted snow", "z": [1.2, 1.7], "style": "pale", "tag": [-284.0, 786.6], "top": True,
         "text": "Along the deck's front edge, under 0.3 m tall, so it hides no more than the soles of your boots. It stops 3.5 m short of the east end, where you come off the car.",
         "draw": [_r(-282.0, 786.0, -271.5, 786.25)]},
    ],
    "explains": [
        ["The car's step, which you leave", "The boarding step of the top line's car, at its west stop", "Its cable going in over the deck to the bull wheel on the front of the house"],
        ["The three sheets of ice", "The glacier's tongue, lying across the station's deck", "The glacier's lip on the station's roof, and the docks under the deck full of the same ice"],
        ["The three dry patches", "The station's own planks, where the ice has not reached", "The house's wall, its ticket window and its sign"],
        ["The black edge and underside", "The near edge of the ice that fills the lower docks", "The mass of blue-black ice under the deck, with two cables running into it"],
        ["The frozen glove", "What one of the ones who tried left behind", "The cold lantern and the dark ticket window"],
    ],
    "pieces": [
        ["Iced deck: planks with three sheets of ice", "14 m", "1", "Play space", "kit: iced deck"],
        ["Frozen glove", "0.3 m", "1", "Play space", "kit: iced deck (glove_frozen)"],
        ["Gondola with its step, rack and cranked hanger arm", "2.6 m wide, 2.2 m tall; step 0.6 m", "1 here", "Play space; the arm behind", "kit: gondola"],
        ["Station house, half buried, with pug sign and cold lantern", "14 m wide, 6 m tall; snow drift 8 m", "1", "Background", "kit: station house (the snow is new)"],
        ["Wind engine, frozen: white with frost, snow in its cups", "5 m across", "1", "Background", "kit: wind engine"],
        ["Bull wheel, greyed and frosted", "4.4 m across", "1", "Background", "kit: bull wheel, as scenery"],
        ["Ice in the lower docks, with two frost-rimmed holes", "13 m wide, 8 m tall", "1", "Background", "new, this area only: made the way the glacier's body is"],
        ["Lattice bracket", "11 m and 6 m", "2", "Background", "kit: lattice tower (a bay, cut)"],
        ["Cable", "0.15 m thick", "4", "Background", "kit: cable"],
        ["Pennant line, frosted", "10 m", "1", "Background", "kit: pennant line"],
        ["Platform post; snow lip", "0.3 m wide, 11 m tall; 10.5 m long, under 0.3 m tall", "1 each", "Foreground", "new, this area only: the high deck's post and snow lip from the sheet's layers"],
    ],
    "effects": [
        "The first snowflakes, falling straight. The course has them today.",
        "The deck is in the mountain's blue shadow. Behind you the towers are still in gold light.",
        "The mark on the limb that holds the ice shivers harder and harder until it lets go: the glacier's tell, first seen here.",
        "Frost falls from the bull wheel each time it turns back.",
    ],
    "notes": [
        "Note 77: the station house stands 2.5 m back with no roof over the deck. Its peaked roof card, 19 m wide and 1 m back, goes. The pug sign moves from 1.0 m back onto the house's wall. The car's step is drawn.",
        "The sheet: no icicles on the cableway. The 12 m row of icicles that hangs 0.9 m back over the deck goes. The lit lantern goes cold.",
        "The deck's strut card goes from 0.7 m back to 2.5 m, as two lattice brackets.",
        "The sheet's call from note 80: the car's hanger arm stops being solid and goes behind.",
        "The glacier's lip over the deck's west end, its own fringe of icicles and the passage west are the next biome's, and are designed on its pages. This page stops where the planks meet the rock.",
        "Note 89: nothing blows you here. The frozen pennants point east.",
    ],
}

# ------------------------------------------------------------------ pieces more than one area uses, added to the cableway's kit
KIT_MORE = [
    ["Guide wheel, as scenery: greyed, no cream", "1 m across", "where a cable only bends: the four corners of each loop, under the chair shed's eave, on the fang, on the express tower's arms", "Background, 2 m back", "new"],
    ["Link girder: a lattice bay laid level, with a shaft along it and a belt down at each end", "1 m deep; 15 m and 23 m long", "between pylon 1 and line 2's west tower, where its crossed belt is why the two loops turn opposite ways and in step; and from the express tower across pylon 3 to the counterweight frame, where it is also the dead gondola's rail", "Background, 2.5 m back", "new, from the tower's bay"],
    ["Iron rung on two straps", "0.8 m long; straps 0.5 m", "under the east end of pylon 1's perch: the way up from a car's roof, now that hanger arms are scenery", "Play space", "new"],
    ["Chair shed: a board wall with a bench and a hand winch", "4.4 m wide, 2.8 m tall", "behind pylon 2's head, under the tarred roof: where the chair line was boarded and wound", "Background, 2.5 m back", "new, from the station house's boards"],
    ["The fang's far horn: dark rock, a step duller than the fang", "20 m wide, 2.5 m deep", "behind El Colmillo's slab and east side, never west of the overhang", "Background, 1.5 to 4 m back", "new"],
]

AREAS = [ABORDAR, FROG, DE_GONDOLA, EL_CABLE, EL_PILON, SILLAS, EL_COLMILLO, TIROLESA, CONTRAPESOS, LA_GONDOLA_ROTA, VIA_RAPIDA, LA_ESTACION_ALTA]
