# The storm ridge's areas, one dict each. Format: see ../build.py.
# Order: the way in from the glacier (the join), the keeper's cabin on the first ledge (the rest), then the nine
# challenges, bottom to top. The exit ledge at 964 m is the summit's, and is designed in the summit's file.
import math


# ------------------------------------------------------------------ shorthand
def _r(x0, y0, x1, y1, st=None):
    return ["rect", x0, y0, x1, y1] + ([{"style": st}] if st else [])


def _ln(x0, y0, x1, y1, st=None):
    return ["line", x0, y0, x1, y1] + ([{"style": st}] if st else [])


def _c(x, y, r, st=None):
    return ["circle", x, y, r] + ([{"style": st}] if st else [])


def _p(pts, st=None):
    return ["poly", [list(q) for q in pts]] + ([{"style": st}] if st else [])


def _F(y):
    """The ridge face's x at height y: the course's own line from (-307, 884) to (-334, 962)."""
    return round(-307.0 - 27.0 * (y - 884.0) / 78.0, 2)


def _wind(segs, d, wave=1.6):
    """Wavy wind lines. segs: (x_from, x_to, y) for each line; d: +1 it blows east, -1 west."""
    out = []
    for k, (xa, xb, y) in enumerate(segs):
        a, b = min(xa, xb), max(xa, xb)
        x, up = a, (k % 2 == 0)
        while x < b - 0.3:
            xn = min(x + wave, b)
            out.append(_ln(round(x, 2), round(y + (0.2 if up else -0.2), 2), round(xn, 2), round(y + (-0.2 if up else 0.2), 2), "mark"))
            x, up = xn, not up
        tip = b if d > 0 else a
        out.append(_ln(tip, y, round(tip - d * 0.55, 2), round(y + 0.38, 2), "line"))
        out.append(_ln(tip, y, round(tip - d * 0.55, 2), round(y - 0.38, 2), "line"))
    return out


def _cloud(x0, x1, y0, y1, n=4, st="pale"):
    """A painted bank of cloud: round heads above, a scalloped underside."""
    w = (x1 - x0) / n
    hh = min(0.42 * (y1 - y0), w / 2)
    yb = y1 - hh
    pts = []
    for k in range(n):
        cx = x0 + (k + 0.5) * w
        ry = hh * (1.0 if k % 2 == 0 else 0.7)
        for a in (180, 150, 120, 90, 60, 30):
            pts.append((round(cx + (w / 2) * math.cos(math.radians(a)), 2), round(yb + ry * math.sin(math.radians(a)), 2)))
    pts.append((x1, round(yb, 2)))
    m = n * 2
    w2 = (x1 - x0) / m
    dd = min(0.2 * (y1 - y0), w2 / 2)
    for k in range(m):
        cx = x1 - (k + 0.5) * w2
        for a in (0, -45, -90, -135):
            pts.append((round(cx + (w2 / 2) * math.cos(math.radians(a)), 2), round(y0 + dd + dd * math.sin(math.radians(a)), 2)))
    pts.append((x0, round(y0 + dd, 2)))
    return _p(pts, st)


def _far(blades, y0):
    """A slice of the ridge's far towers: blades and needles as outlines. blades: (x, width, top)."""
    return [_p([(round(x - w / 2, 2), y0), (round(x - 0.4 * w, 2), round(t - 0.5 * w, 2)), (round(x - 0.1 * w, 2), t),
                (round(x + 0.45 * w, 2), round(t - 0.35 * w, 2)), (round(x + w / 2, 2), y0)], "line") for x, w, t in blades]


def _flank(y0, y1, reach=5.0, step=3.5):
    """The ridge's flank where it crosses a window: leaning slate ribs, from under the face out to a stepped edge."""
    pts = [(round(_F(y0) - 1.0, 2), y0), (round(_F(y0) + reach + 0.5, 2), y0)]
    y, k = y0, 0
    while y < y1 - 0.01:
        yn = min(y + step, y1)
        rr = reach + (0.5 if k % 2 == 0 else -0.5)
        last = yn >= y1 - 0.01
        ye = yn if last else yn - 0.7
        pts.append((round(_F(ye) + rr, 2), round(ye, 2)))
        if not last:
            pts.append((round(_F(yn) + reach + (-0.5 if k % 2 == 0 else 0.5), 2), round(yn, 2)))
        y, k = yn, k + 1
    pts.append((round(_F(y1) - 1.0, 2), y1))
    return [_p(pts)] + [_ln(round(_F(y0) + o, 2), y0, round(_F(y1) + o, 2), y1, "mark") for o in (1.7, 3.3)]


def _sock(x, y, d, stub=1.1):
    """A wind sock on a short timber stub standing at (x, y), streaming d (+1 east, -1 west)."""
    t = round(y + stub, 2)
    return [_r(round(x - 0.08, 2), y, round(x + 0.08, 2), t, "pale"),
            _p([(x, round(t + 0.05, 2)), (round(x + d * 1.5, 2), round(t - 0.1, 2)), (round(x + d * 1.5, 2), round(t - 0.3, 2)), (x, round(t - 0.45, 2))], "pale")]


def _arm_sock(x, y, d):
    """A wind sock on a timber arm that sticks out d-wards from a tower's body at (x, y)."""
    xe = round(x + d * 0.8, 2)
    return [_r(min(x, xe), round(y - 0.1, 2), max(x, xe), round(y + 0.1, 2), "pale"),
            _p([(xe, round(y + 0.25, 2)), (round(xe + d * 1.5, 2), round(y + 0.1, 2)), (round(xe + d * 1.5, 2), round(y - 0.1, 2)), (xe, round(y - 0.25, 2))], "pale")]


def _torn(x, y, d):
    """The torn end of a prayer line, tied at (x, y) and streaming d-wards."""
    return [_ln(x, y, round(x + d * 0.7, 2), round(y - 0.08, 2), "line"), _ln(round(x + d * 0.7, 2), round(y - 0.08, 2), round(x + d * 1.3, 2), round(y - 0.3, 2), "line"),
            _r(round(min(x + d * 0.25, x + d * 0.55), 2), round(y - 0.42, 2), round(max(x + d * 0.25, x + d * 0.55), 2), round(y - 0.1, 2), "pale")]


def _body(x0, x1, yt, yb):
    """A tower's body: the same rock 1 m wider on each side, from just under the tower's top down to yb."""
    return _p([(round(x0 - 1.4, 2), yb), (round(x0 - 1.0, 2), round(yt - 0.9, 2)), (round(x0 - 0.2, 2), round(yt - 0.3, 2)),
               (round(x1 + 0.2, 2), round(yt - 0.3, 2)), (round(x1 + 1.0, 2), round(yt - 0.7, 2)), (round(x1 + 1.6, 2), yb)])


# ------------------------------------------------------------------ shapes more than one area draws
# The keeper's cabin on the first ledge. 4.3 m wide, 2.5 m tall at its west end, 2.2 m deep.
_CAB_SHELL = [_p([(-307.4, 886.0), (-303.1, 886.0), (-303.1, 888.08), (-307.4, 888.5)], "dark"),
              _p([(-307.75, 888.5), (-302.8, 888.02), (-302.8, 888.26), (-307.75, 888.74)], "pale"),
              _r(-307.4, 886.0, -307.22, 888.5, "pale"), _r(-303.28, 886.0, -303.1, 888.08, "pale")]
_CAB_STOVE = [_r(-304.0, 886.0, -303.42, 886.72, "pale"), _c(-303.84, 886.85, 0.12, "pale"), _r(-303.6, 886.72, -303.46, 889.7, "pale")]
_CAB_SMOKE = [_ln(-303.53, 889.8, -302.6, 890.1, "mark"), _ln(-302.6, 890.1, -301.3, 890.0, "mark"), _ln(-301.3, 890.0, -300.0, 890.35, "mark")]
_CAB_TABLE = [_r(-305.25, 886.68, -304.25, 886.76, "pale"), _ln(-305.15, 886.0, -305.15, 886.68, "line"), _ln(-304.35, 886.0, -304.35, 886.68, "line"),
              _r(-304.68, 886.76, -304.36, 886.83, "pale")]
_CAB_FROG = [_c(-305.0, 886.92, 0.16, "pale")]
_CAB_LAMP = [_c(-304.75, 887.72, 0.14, "light")]
_CAB_BUNK = [_r(-307.15, 886.3, -305.62, 886.5, "pale"), _ln(-307.1, 886.0, -307.1, 886.3, "line"), _ln(-305.68, 886.0, -305.68, 886.3, "line"),
             _p([(-305.62, 887.75), (-305.36, 887.75), (-305.28, 886.98), (-305.72, 886.98)], "pale")]
_CAB_SLATE = [_r(-306.8, 887.2, -306.2, 888.0, "pale")]
_CABIN = _CAB_SHELL + _CAB_STOVE + _CAB_SMOKE + _CAB_TABLE + _CAB_FROG + _CAB_LAMP
_PRAYER_POLE = [_r(-307.68, 886.0, -307.52, 890.0, "pale"), _ln(-307.6, 889.9, -306.8, 889.8, "line"), _ln(-306.8, 889.8, -306.1, 889.5, "line"),
                _ln(-307.6, 889.3, -306.9, 889.15, "line")]
# The back wall of the nook under El Alero: the ridge's flank, 3.4 m back, where the cabin stands against it.
_NOOK = [_p([(-313.0, 884.2), (-301.5, 884.2), (-301.1, 886.8), (-300.6, 889.6), (-300.8, 891.9), (-313.0, 895.4)]),
         _ln(-305.2, 888.9, -306.3, 893.2, "mark"), _ln(-302.3, 888.7, -303.1, 892.4, "mark")]
_SNOW_LIP = [_p([(-307.6, 886.0), (-307.6, 886.2), (-305.8, 886.28), (-304.3, 886.18), (-303.0, 886.26), (-303.0, 886.0)])]
_SPAR = [_r(-302.05, 892.15, -301.65, 892.5, "pale")]
_LINE_PAPER = [_ln(-301.7, 891.6, -301.25, 891.5, "line"), _ln(-301.7, 890.6, -301.2, 890.5, "line"), _ln(-301.7, 889.6, -301.25, 889.5, "line"),
               _ln(-301.7, 888.6, -301.2, 888.5, "line")]
_NOSE = [_p([(-302.9, 886.0), (-302.9, 886.75), (-301.75, 886.0)], "line")]

# El Filo: its knobs, and its body behind.
_FILO_KNOBS = [(-295.55, 893.2), (-296.85, 894.4), (-295.55, 895.6), (-296.85, 896.8), (-295.55, 898.0), (-296.85, 899.2), (-295.55, 900.4), (-296.9, 901.55)]
_FILO_BODY = [_p([(-298.1, 885.0), (-297.7, 901.0), (-297.0, 901.6), (-295.4, 901.6), (-294.7, 901.3), (-294.1, 885.0)])]
_FILO_VEIN = [_ln(x, y, -294.75 if x > -296.2 else -297.65, round(y + 0.45, 2), "mark") for x, y in _FILO_KNOBS[:7]]

# The three prayer lines of Banderas, as the course has them.
_L1 = ((-296.2, 904.3), (-304.7, 905.2))
_L2 = ((-305.13, 906.8), (-296.2, 908.4))
_L3 = ((-296.2, 910.0), (-307.9, 913.6))

# The station tower's body: 3 m back, with the saw-toothed shoulder the vane's mast stands on.
_STATION_BODY = [_p([(-313.5, 904.8), (-313.2, 913.3), (-307.6, 913.3), (-306.9, 913.9), (-305.9, 912.9), (-305.2, 914.2), (-304.2, 913.1),
                     (-303.4, 913.5), (-302.2, 913.5), (-301.6, 914.3), (-301.2, 912.6), (-301.9, 909.8), (-303.4, 907.4), (-304.0, 904.8)])]
_VANE_SHOE = [_r(-303.4, 913.5, -302.2, 913.85, "pale")]


def _vane_mast(y0, y1):
    """The vane's banded mast, from y0 to y1."""
    out = [_r(-303.05, y0, -302.55, y1, "pale")]
    y = 914.6
    while y < y1 - 0.3:
        if y > y0:
            out.append(_r(-303.05, round(y, 2), -302.55, round(y + 0.75, 2), "solid"))
        y += 1.5
    return out


# The mast of El Rayo, as the course has it: where steel meets timber, and the steel itself.
_STACKS = [(915.18, 915.4), (917.2, 917.42), (919.18, 919.4), (921.2, 921.42), (923.18, 923.4), (925.2, 925.42), (927.18, 927.4)]
_RUNGS = [915.5, 916.6, 919.5, 920.6, 923.5, 924.6]
_HUT = [_r(-312.2, 913.5, -308.6, 915.6, "pale"), _p([(-312.45, 915.6), (-310.5, 915.6), (-310.9, 916.35), (-312.45, 916.1)]),
        _ln(-310.5, 915.6, -309.6, 916.1, "line"), _ln(-309.3, 915.6, -308.8, 915.95, "line"),
        _r(-312.0, 913.5, -311.35, 915.2, "dark")]
_BOLT_SIGN = [_r(-309.5, 914.55, -308.72, 915.5), _ln(-309.0, 915.4, -309.25, 915.0, "line"), _ln(-309.25, 915.0, -308.98, 915.05, "line"),
              _ln(-308.98, 915.05, -309.2, 914.65, "line")]

# La Torre: its body behind the shoulder and the needle, and the kite reels on the body's west edge.
_TORRE_TOP = [(-292.5, 941.2), (-292.2, 942.6), (-291.9, 943.3), (-291.4, 942.4), (-291.1, 941.0), (-290.0, 941.6), (-289.2, 940.8), (-288.5, 941.4),
              (-288.5, 943.0), (-284.6, 943.0), (-283.9, 942.2)]
_KITES = [(-291.9, 936.6), (-291.9, 939.2), (-291.7, 941.8)]


def _torre_body(y0):
    return [_p([(-292.6, y0)] + _TORRE_TOP + [(-283.6, y0)])]


_REELS = [_c(x, y, 0.4, "line") for x, y in _KITES] + [_c(x, y, 0.09, "pale") for x, y in _KITES]

# La Nube: the rib its knobs stand on (the east edge cut back 0.4 m near the top), the vein and the fault on it.
_NUBE_KNOBS = [(-325.6, 947.0), (-324.6, 948.0), (-323.6, 949.0), (-323.9, 950.6), (-322.9, 951.6)]
_RIB = [_p([(-327.0, 944.6), (-324.8, 946.0), (-322.4, 950.4), (-322.1, 952.5), (-324.4, 951.6), (-326.8, 948.0)], "dark"),
        _ln(-326.4, 946.2, -323.3, 949.3, "mark"), _ln(-324.3, 950.2, -322.6, 951.9, "mark"), _ln(-325.0, 949.3, -322.8, 950.0, "line")]
_NUBE_SHADOW = [_p([(-326.7, 940.5), (-323.8, 940.5), (-323.1, 944.5), (-321.3, 949.0), (-320.9, 952.0), (-322.2, 952.9), (-326.7, 953.1)])]

# The headwall's rest: what stands at its back. And the summit's rock cards, which stand behind the top of this biome.
_WINCH = [_r(-331.2, 955.5, -329.95, 955.72, "pale"), _r(-331.0, 955.72, -330.45, 956.22, "line"), _ln(-331.0, 955.98, -331.3, 956.42, "line"),
          _r(-330.15, 955.5, -329.95, 957.75, "pale")]
_WINCH_SOCK = [_p([(-329.95, 957.65), (-328.45, 957.5), (-328.45, 957.3), (-329.95, 957.15)], "pale")]
_CABLE = [_ln(-330.05, 957.75, -321.7, 962.3, "line")]
_ARROW_SIGN = [_p([(-330.45, 956.3), (-329.65, 956.3), (-329.65, 956.75), (-330.05, 957.05), (-330.45, 956.75)], "pale")]
# The summit's rock where it stands behind the top of this biome: two pillars (1.8 m back) and, in _teeth, three teeth (1.4 m back).
_PILLAR_W = [(-334.3, 953.4), (-325.9, 953.4)]
_PILLAR_E = [(-325.3, 953.4), (-318.3, 953.4)]


def _pillars(y_top):
    kw = round((y_top - 958.0) * 0.045, 2)
    ke = round((y_top - 958.0) * 0.05, 2)
    return [_p(_PILLAR_W + [(round(-326.0 - kw, 2), y_top), (round(-334.2 + kw, 2), y_top)]),
            _p(_PILLAR_E + [(round(-318.4 - ke, 2), y_top), (round(-325.2 + ke, 2), y_top)])]


_CIELO = [(957.0, False), (958.2, True), (959.9, False), (961.1, True)]


def _teeth(y_top):
    """The summit's three near teeth (1.4 m back), each carried down from 958 m to 953.4 m."""
    return [_p([(-326.95, 953.4), (-324.25, 953.4), (round(-324.35 - 0.85 * (y_top - 958.0) / 12.25, 2), y_top), (round(-326.85 + 0.85 * (y_top - 958.0) / 12.25, 2), y_top)], "line"),
            _p([(-329.95, 953.4), (-327.25, 953.4), (round(-327.35 - 0.85 * (y_top - 958.0) / 21.65, 2), y_top), (round(-329.85 + 0.85 * (y_top - 958.0) / 21.65, 2), y_top)], "line"),
            _p([(-323.4, 953.4), (-319.8, 953.4), (round(-319.9 - 1.3 * (y_top - 958.0) / 23.65, 2), y_top), (round(-323.3 + 1.3 * (y_top - 958.0) / 23.65, 2), y_top)], "line")]


_FAR_TEXT = ("The kit's one painted card, 14 m back: the ridge's other towers going away along the crest, with their feet in painted cloud "
             "and the back ones hazed to the storm's grey. ")
_BANK_TEXT = "A painted bank of cloud, 7 m back, with round heads and a scalloped underside, dark below and paler on top. "
_LIP_TEXT = ("Along the front of the first ledge, under 0.3 m tall, in front of the ledge's own snow. It is the only thing on the whole ridge "
             "that stands in front of the climb, and it covers nothing above your ankles.")


# ------------------------------------------------------------------ 9 to 10: the gap
THE_GAP = {
    "id": "9 to 10", "slug": "9_to_10_the_gap", "title": "The gap: from the glacier to the storm ridge", "kind": "join", "also": ["a9"],
    "window": [-314.0, 871.0, -288.0, 897.0], "screen": [-300.5, 884.5], "cut_y": 886.6, "climber": [-304.2, 886.0],
    "place": ("The glacier does not reach the ridge. Its ice has pulled away from the rock and left a gap 6 m wide, and the gap drains down "
              "the chute onto the whole of the glacier's long slide. On the glacier's side stands the last of the ones who tried, frozen on "
              "the very top, leaning out with one mitten raised. On the ridge's side there is one ledge, under a prow of wet slate that "
              "roofs it, and on that ledge the weather keeper built his cabin, out of the rain. Its stove is still lit. So what you fling "
              "at is a small amber room in a grey picture, with smoke streaming east from its pipe. Within one screen the ice ends, the "
              "slate begins, and the first wind of the ridge is blowing in your face."),
    "keep": [
        "The fling of challenge 9.10: from the mitten, 7 m west and 3.4 m up, onto the ledge past its glazed first metre.",
        "The ledge, the prow over it, and the gap under the flight, each exactly where it is.",
        "The ridge's lowest wind. It blows east only, in gusts of 2 seconds with 3.5 seconds between, and the last of the flight is in it.",
        "The torn line where it hangs, and El Filo's point 2.8 m from the mitten.",
    ],
    "background": [
        {"name": "The ridge's far towers", "z": [-14.2, -14.0], "style": "line", "tag": [-290.0, 895.0],
         "text": _FAR_TEXT + "From the glacier's top you see their lowest ends east of El Filo. It is the first sight of what the ridge is made of.",
         "draw": _far([(-292.6, 3.0, 893.5), (-289.6, 2.4, 896.5)], 880.0)},
        {"name": "Cloud in the gap", "z": [-7.2, -7.0], "style": "mark", "tag": [-290.3, 890.3],
         "text": _BANK_TEXT + "It fills the open air between the prow and El Filo. Under it, at the foot of the picture, the valley shows as "
                 "one last strip. After this ledge there is only cloud until the summit.",
         "draw": [_cloud(-303.0, -288.0, 884.6, 893.2, 3, "mark")]},
        {"name": "The gap's far wall", "z": [-2.6, -2.4], "tag": [-298.3, 876.0],
         "text": "The ridge's own rock, bared where the ice pulled away: the ridge's flank, wet slate in leaning slabs, dull blue-grey, "
                 "2.4 m back, with long pale scrapes low down where the ice has dragged across it. It is the same piece as on the "
                 "glacier's page for El Rimaye. It is the first slate you see, and it is behind you and in shadow.",
         "draw": [_p([(-302.5, 878.7), (-298.4, 871.0), (-295.9, 871.0), (-295.9, 881.0), (-302.0, 884.6)]),
                  _ln(-300.9, 878.0, -297.4, 872.0, "mark"), _ln(-299.6, 881.6, -296.6, 876.2, "mark")]},
        {"name": "The glacier's side", "z": [-3.4, -1.2], "style": "line", "tag": [-293.0, 883.6], "over": True,
         "text": "From the glacier's own page for El Rimaye, drawn here so that the two pages agree: a horn of ice at the last "
                 "climber's back, the route's last cane on the tower's top with a lit lantern on it, and, in the ice under the ledge, "
                 "the dark hole that the snow slabs come out of (note 93). None of it is the ridge's.",
         "draw": [_p([(-296.45, 882.81), (-297.51, 881.75), (-295.95, 880.19), (-294.89, 881.25)]), _r(-304.5, 879.5, -302.5, 881.0, "dark"),
                  _ln(-294.3, 880.1, -294.3, 883.1), _c(-294.3, 881.9, 0.18, "light")]},
        {"name": "The nook under El Alero", "z": [-4.0, -3.4], "tag": [-309.3, 891.6], "top": True,
         "text": "The back wall of the space under the prow: the ridge's flank in leaning ribs of slate, dark and running with water. It "
                 "carries on east to under the prow's tip, so the ledge reads as the floor of a real hollow in a mountain.",
         "draw": _NOOK},
        {"name": "The keeper's cabin", "z": [-3.4, -1.2], "tag": [-305.3, 889.3], "top": True,
         "text": "On the ledge, against the nook's back wall, cut away at the front: plank walls, a slate roof, a lit stove and one lamp, and "
                 "the frog at the table. It is designed on its own page. From the glacier's top its amber room is the only warm colour "
                 "you can see, and it is exactly where you have to land (note 94).",
         "draw": _CABIN},
        {"name": "The prayer pole", "z": [-1.4, -1.2], "style": "pale", "tag": [-308.3, 890.6],
         "text": "The ridge's first prayer pole, 4 m tall, with the town's cut paper tied along its top. It stands at the cabin's west "
                 "corner. Its paper streams east in a gust and hangs slack between gusts.",
         "draw": _PRAYER_POLE},
        {"name": "El Filo's body, and the cloud at its foot", "z": [-3.8, -1.9], "tag": [-293.2, 886.3],
         "text": "Behind El Filo's blade stands its body: the same slate, 3 m wide and 3 m back, duller and greyer. A collar of painted "
                 "cloud, 11 m wide and 5 m tall, lies across the body's lower end, 2 m back. The blade's point hangs in front of it. This "
                 "collar takes the place of the flat grey card that stood in front of the last climber's mitten (note 92).",
         "draw": _FILO_BODY + [_cloud(-302.0, -291.0, 883.4, 888.3, 4, "pale")]},
    ],
    "play": [
        {"name": "The mitten", "z": [-0.3, 0.3], "style": "line", "tag": [-298.3, 883.4],
         "text": "The launch: the raised mitten of the last climber on the glacier. He belongs to the glacier's pages. What this page "
                 "asks of him is only that nothing stands in front of him, and that he is leaning at the cabin's light.",
         "draw": [_c(-297.17, 882.57, 0.3)]},
        {"name": "The porch", "z": [-1.2, 1.2], "style": "mark", "tag": [-306.6, 885.2],
         "text": "The ledge keeps its firm snow, white and matte, 5 m long. The wind has combed the snow into low ridges that all run "
                 "east. The glazed first metre is blue-black and glossy, the last piece of the glacier's ice, so it reads as the one "
                 "part of the porch that will not hold you.",
         "draw": [_ln(-307.5, 886.07, -303.0, 886.07)] + _NOSE},
        {"name": "The torn line and its spar", "z": [-0.3, 0.3], "style": "pale", "tag": [-302.6, 893.3],
         "text": "The way on, seen as you land. A square timber spar is let into the underside of the prow, and the torn half of a "
                 "prayer line hangs from it, 4.3 m of hemp rope with paper along all of it. Only the spar's end shows, flush in the "
                 "rock round the knot. It adds nothing to hold.",
         "draw": _SPAR + _LINE_PAPER},
        {"name": "The first wind, drawn", "z": [0.9, 1.2], "tag": [-292.0, 892.0],
         "text": "Note 89. The lowest wind fills the band from 884 to 893 m: long wavy white lines with an inked edge, moving east, across "
                 "the porch and the gap. They are thin and see-through, and they pass in front of you. In the 0.8 seconds before a gust a front of lines comes out from under the prow and a whistle "
                 "rises. Between gusts there are no lines.",
         "draw": _wind([(-300.5, -288.6, 885.0), (-313.0, -288.6, 889.2), (-299.6, -288.6, 891.4)], 1)},
    ],
    "foreground": [
        {"name": "A lip of drifted snow", "z": [1.2, 1.5], "tag": [-303.7, 885.3], "top": True, "text": _LIP_TEXT, "draw": _SNOW_LIP},
    ],
    "explains": [
        ["The mitten you leave from", "The last of the ones who tried, on the glacier's top", "The ice at his back. He is on the glacier's pages"],
        ["The gap under the flight", "Where the ice has pulled away from the ridge", "The bared, scraped slate of the ridge, 2.4 m back"],
        ["The ledge you land on", "The porch of the weather keeper's cabin", "The cabin itself: stove, lamp, table and frog, against the nook's slate wall"],
        ["The glazed first metre", "The last of the glacier's ice, frozen onto the porch's end", "The gap it came from, directly under it"],
        ["The prow overhead", "El Alero: the cabin's roof, and the brink that throws every fall out over the glacier", "The nook's back wall, which follows its underside"],
        ["The torn line", "The keeper's first line, which ran to El Filo, snapped", "The spar it hangs from, and El Filo standing in cloud across the gap"],
    ],
    "pieces": [
        ["The ridge's far towers", "70 m wide, 90 m tall", "1, shared by the whole ridge", "Background, far", "kit: the ridge's far towers"],
        ["Cloud bank", "15 m wide, 9 m tall", "1", "Background", "kit: cloud bank"],
        ["The ridge's flank: the gap's wall, with scrapes", "7 m wide, 14 m tall", "1", "Background", "kit: the ridge's flank, with scrape lines painted on"],
        ["The ridge's flank: the nook's back wall", "12 m wide, 11 m tall", "1", "Background", "kit: the ridge's flank"],
        ["The keeper's cabin, with the frog", "4.3 m wide, 2.5 m tall, 2.2 m deep", "1", "Background, cut away at the front", "kit: the keeper's cabin; the frog"],
        ["Prayer pole", "4 m", "1", "Background", "kit: prayer_pole"],
        ["Tower body for El Filo", "3.6 m wide, 18 m tall", "1", "Background", "kit: tower body"],
        ["Cloud collar", "11 m wide, 5 m tall", "1", "Background", "kit: cloud collar"],
        ["Firm snow cap, combed by the wind", "5 m", "1", "Play space", "kit: firm snow cap"],
        ["Torn line; its spar", "4.3 m; spar 0.35 m square, 3.4 m long", "1 of each", "Play space", "kit: torn line; the spar"],
        ["Lip of drifted snow", "4.6 m long, under 0.3 m tall", "1", "Foreground", "kit: the lip of drifted snow, from the sheet's foreground"],
    ],
    "effects": [
        "The cabin's smoke streams east in a gust and stands straight up between gusts. It is the first flag of the first wind, and you can read it from the mitten.",
        "Amber light from the cabin lies on the porch's snow and on the underside of the prow, as colour and not as glow.",
        "Rain runs down the prow's cap and falls off its brink in a thin broken line, 2 m east of the ledge's end. Under the prow it is dry.",
        "Snow blowing off the glacier's top, as on the glacier's side today.",
    ],
    "notes": [
        "Note 92: the flat grey cloud card that stood in front of the last climber goes. Cloud here is a painted collar 2 m behind El Filo's foot and a bank 7 m back.",
        "Note 94: the ledge is the keeper's cabin, with the frog. Its own page has the detail.",
        "Note 89: the lowest wind is drawn across its whole band, and the smoke, the pole's paper and the torn line's paper are its flags.",
        "Note 40: one thing stands in front, the snow lip, and it is under 0.3 m.",
        "Course change, scenery only: the prayer pole stands 1.4 m further east, at the cabin's west corner. Today it stands at x -309, behind the solid face, where most of it is hidden.",
        "The summit's sheet proposes that the frogs' water slide comes out as a steaming spout over this gap. It is not drawn here. That call is still open on the summit's sheet.",
        "Nothing you touch moves.",
    ],
}

# ------------------------------------------------------------------ 10.0 The keeper's cabin
_SLATE_ARROWS = []
for _i, _d in enumerate((1, -1, 1, -1, 1, -1, 1, 0, 1)):
    _y = round(887.27 + 0.08 * _i, 2)
    if _d:
        _SLATE_ARROWS.append(_ln(-306.7, _y, -306.3, _y, "line"))

THE_CABIN = {
    "id": "10.0", "slug": "10_0_the_keepers_cabin", "title": "The keeper's cabin", "kind": "rest", "also": ["a9"],
    "window": [-315.0, 882.5, -295.0, 896.5], "screen": [-304.6, 888.6], "cut_y": 887.0, "climber": [-302.95, 886.0],
    "place": ("The one sheltered place on the ridge. The weather station's keeper had to live somewhere, and the only dry spot above the "
              "glacier was the ledge under El Alero, where the prow keeps the rain off. He built a cabin there the cableway's way: square "
              "honey posts, thick planks, a roof of slate slabs pitched the way the prow pitches, with its back against the rock. He left "
              "the front open to the ledge, which was his porch, and he went to work from the porch's end along a line to El Filo. Nobody "
              "came to relieve him. The line has snapped and hangs from its spar. The stove is still lit, the kettle is on it, his coat is "
              "on its peg and his weather book is open on the table. The ridge's frog lives here now. It sits on the table under the lamp, "
              "in a small yellow rain hat, with a cup of tea, and watches the storm. The porch is still not a safe place to stand: the "
              "lowest wind blows straight along it and off its end."),
    "keep": [
        "The ledge: its length, its height, and its glazed first metre.",
        "The lowest wind, which blows east only, along the ledge and off its end.",
        "The torn line, a hand past the ledge's east end, and the prow overhead.",
        "The cabin is scenery. Nothing in it can be touched, and nothing is added to stand on or hold.",
    ],
    "background": [
        {"name": "The nook's back wall", "z": [-4.0, -3.4], "tag": [-310.5, 892.4],
         "text": "The ridge's flank where it passes under the prow: leaning ribs of wet slate, 3.4 m back. It fills the 4 m and more between the "
                 "cabin's roof and the prow's underside, and it is the darkest thing in the picture, so the cabin's light sits in the middle of it.",
         "draw": _NOOK},
        {"name": "The cabin's shell", "z": [-3.4, -1.2], "tag": [-305.6, 889.2], "top": True,
         "text": "A plank floor level with the ledge, a plank back wall, two end walls and a roof, with no front wall. It is 4.3 m wide and "
                 "2.2 m deep. The roof is slate slabs on honey rafters, 2.5 m up at the west end and 2.1 m at the east, the same pitch "
                 "as the prow above. The two front corner posts stand at the back edge of the ledge, with an iron pug plate at each foot. "
                 "The walls are amber inside, from the stove and the lamp. That is colour on the planks, not a glow.",
         "draw": _CAB_SHELL},
        {"name": "The stove, the kettle and the pipe", "z": [-2.6, -1.6], "style": "pale", "tag": [-302.6, 887.3],
         "text": "A small iron stove at the east end with the keeper's kettle on it: the same kettle as in the drivers' cave on the "
                 "cliffs and in the glacier's snow hole. Its pipe goes up through the roof and ends in a cowl 1.5 m above it. The smoke "
                 "is the first wind's flag: it streams east under the prow in a gust and stands up straight between gusts.",
         "draw": _CAB_STOVE + _CAB_SMOKE},
        {"name": "The table, the weather book, the lamp and the frog", "z": [-2.6, -1.6], "style": "pale", "tag": [-304.7, 885.3], "top": True,
         "text": "A plank table in the middle of the room with the weather book open on it. The one lamp hangs over it. The frog sits on "
                 "the table's west end, 0.3 m tall, in a small yellow rain hat, with a cup beside it, facing east toward the open end of "
                 "the porch and the storm. It turns its head to follow you along the ledge.",
         "draw": _CAB_TABLE + _CAB_FROG + _CAB_LAMP},
        {"name": "The bunk and the coat", "z": [-3.3, -2.2], "style": "pale", "tag": [-306.4, 885.3],
         "text": "A bunk along the west end with a folded blanket, and the keeper's oilskin coat on a peg at its foot. The coat is the "
                 "size of a luchador. The frog's hat is cut from the same yellow cloth.",
         "draw": _CAB_BUNK},
        {"name": "The wind slate", "z": [-3.4, -3.3], "style": "pale", "tag": [-306.5, 888.25],
         "text": "A roofing slate hung on the back wall over the bunk, with the keeper's chalk on it: nine rows of arrows, one above the "
                 "other, pointing east, west, east, all the way up. In the eighth row there are two arrows that point at each other. It "
                 "is his table of the ridge's winds, and it is true. A player who stops here can read the whole ridge off it.",
         "draw": _CAB_SLATE + _SLATE_ARROWS},
        {"name": "The prayer pole", "z": [-1.4, -1.2], "style": "pale", "tag": [-308.4, 890.5],
         "text": "At the cabin's west corner, 4 m tall, with the town's cut paper tied along its top. It is the first wind's second flag.",
         "draw": _PRAYER_POLE},
        {"name": "Cloud in the gap", "z": [-7.2, -7.0], "style": "mark", "tag": [-297.0, 893.6],
         "text": _BANK_TEXT + "It stands east of the prow's tip and hides the valley. It is on the join's page.",
         "draw": [_cloud(-303.0, -295.0, 884.6, 893.2, 2, "mark")]},
        {"name": "El Filo's cloud, across the gap", "z": [-2.1, -1.9], "style": "pale", "tag": [-298.4, 884.6],
         "text": "The collar of painted cloud that El Filo's body stands in, 2 m back. From the porch, the cloud and the torn line are "
                 "all you see of the way on.",
         "draw": [_cloud(-302.0, -295.0, 883.4, 888.3, 3, "pale")]},
    ],
    "play": [
        {"name": "The porch", "z": [-1.2, 1.2], "style": "mark", "tag": [-306.4, 883.6],
         "text": "The ledge's firm snow, white and matte, combed into low ridges that run east. A path one boot wide is trodden flat in "
                 "it, from the cabin's east post to the ledge's end, where the keeper stepped off onto his line. The glazed first metre "
                 "stays blue-black and glossy.",
         "draw": [_ln(-307.5, 886.07, -303.0, 886.07)] + _NOSE},
        {"name": "The torn line and its spar", "z": [-0.3, 0.3], "style": "pale", "tag": [-302.7, 893.4],
         "text": "A square honey spar is let into the underside of the prow and runs back to the nook's wall. Its end shows flush in the "
                 "rock, 0.35 m square, with an iron pug plate, and the torn line is knotted round it. The line is hemp with the town's "
                 "paper along all 4.3 m of it, wet and faded. Today the paper covers only 2.6 m of the rope.",
         "draw": _SPAR + _LINE_PAPER},
        {"name": "The first wind, drawn", "z": [0.9, 1.2], "tag": [-297.5, 891.0],
         "text": "Note 89. Long wavy white lines with an inked edge, moving east, across the whole band from 884 to 893 m. They cross the "
                 "porch at the height of your chest and carry on past its end, so you can see that the wind will take you the way the "
                 "ledge ends. A front of lines and a whistle come 0.8 seconds before each gust.",
         "draw": _wind([(-301.6, -295.4, 885.2), (-303.0, -295.4, 887.4), (-309.6, -295.4, 890.9)], 1)},
    ],
    "foreground": [
        {"name": "A lip of drifted snow", "z": [1.2, 1.5], "tag": [-304.2, 884.4], "top": True, "text": _LIP_TEXT, "draw": _SNOW_LIP},
    ],
    "explains": [
        ["The ledge", "The cabin's porch", "The cabin: floor, back wall and roof, with its front open onto the ledge"],
        ["The prow overhead", "El Alero, the only roof on the ridge. It is why the cabin is here", "The nook's back wall of leaning slate, up to the prow's underside"],
        ["The torn line", "The keeper's way to work, snapped", "The spar it hangs from, which runs back under the prow to the nook's wall"],
        ["The glazed first metre", "Ice from the gap, frozen onto the porch's end", "The gap, and the cloud in it"],
        ["The wind along the ledge", "The lowest of the ridge's winds", "The stove's smoke, the pole's paper, and the bottom row of the wind slate"],
    ],
    "pieces": [
        ["The ridge's flank: the nook's back wall", "12 m wide, 11 m tall", "1", "Background", "kit: the ridge's flank"],
        ["The keeper's cabin: floor, back wall, end walls, slate roof, two corner posts", "4.3 m wide, 2.5 m tall, 2.2 m deep", "1", "Background, cut away at the front", "kit: the keeper's cabin"],
        ["Stove with its pipe and cowl; kettle", "stove 0.6 m; pipe 3 m; kettle 0.25 m", "1 of each", "Background", "kit: the keeper's cabin. The kettle is the cliffs' tea cave's"],
        ["Table; weather book; cup", "table 1 m; book 0.3 m", "1 of each", "Background", "kit: the keeper's cabin"],
        ["Lamp, lit", "0.4 m", "1", "Background", "kit: lantern_hang"],
        ["The frog, in a yellow rain hat", "0.3 m", "1", "Background", "kit: the frog"],
        ["Bunk with a blanket; oilskin coat on a peg", "bunk 1.5 m; coat 0.8 m", "1 of each", "Background", "kit: the keeper's cabin"],
        ["The wind slate: a roofing slate with nine rows of chalk arrows", "0.6 m by 0.8 m", "1", "Background", "new, this area only"],
        ["Prayer pole", "4 m", "1", "Background", "kit: prayer_pole"],
        ["Cloud bank; cloud collar", "as on the join's page", "1 of each", "Background", "kit: cloud bank; cloud collar"],
        ["Iron plate with the pug's face", "0.3 m", "3", "Background; play space (drawn on)", "kit: iron eye bolt on a pug plate (added below)"],
        ["Firm snow cap with a trodden path", "5 m", "1", "Play space", "kit: firm snow cap"],
        ["Torn line; its spar", "4.3 m; spar 0.35 m square, 3.4 m long", "1 of each", "Play space", "kit: torn line; the spar"],
        ["Lip of drifted snow", "4.6 m long, under 0.3 m tall", "1", "Foreground", "kit: the lip of drifted snow, from the sheet's foreground"],
    ],
    "effects": [
        "The kettle steams. The lamp swings a little in each gust. The frog's cup steams too.",
        "The frog croaks when you land on the porch, and you can hear it from the glacier's top (note 60).",
        "The paper on the pole and on the torn line lifts 0.8 seconds before each gust and streams east in it.",
        "Rain falls off the prow's brink in a thin broken line, 2 m east of the ledge's end. It marks the brink that every fall on the ridge goes over.",
        "When lightning takes the mast far above, the whole picture goes pale for an instant, and the room's amber is the only colour that does not change.",
    ],
    "notes": [
        "Note 94: the first ledge is a little cabin with a frog in it. The cabin stands behind the ledge as scenery, cut away at the front, and the prow is its shelter.",
        "Note 60: this is the storm ridge's frog. The note's first idea, a frog under an overhang with a leaf for an umbrella, becomes the rain hat.",
        "Note 89: the lowest wind is drawn across the porch, with three flags: the smoke, the pole's paper and the torn line's paper.",
        "Note 40: nothing stands in front of the porch but the snow lip, which is under 0.3 m.",
        "The note's plan tied the prayer line to the cabin's porch post. Here it stays where the course hangs it, under the prow's tip, on a spar, as the sheet has it.",
        "Course changes, scenery only: the prayer pole stands 1.4 m further east, at the cabin's west corner, clear of the face. The paper on the torn line runs its whole 4.3 m.",
        "Nothing you touch moves.",
    ],
}

# ------------------------------------------------------------------ 10.1 El Filo
EL_FILO = {
    "id": "10.1", "slug": "10_1_el_filo", "title": "El Filo", "kind": "challenge", "also": ["a9"],
    "window": [-311.0, 883.5, -287.0, 906.5], "screen": [-298.5, 895.0], "cut_y": 895.6, "climber": [-304.0, 886.0],
    "place": ("The first of the ridge's towers, and the thinnest. El Filo is one slab of slate standing on end, 13 m tall, and you climb "
              "its cut edge, which is 1 m thick. The rest of the slab runs away behind you and down into cloud. A vein of white quartz "
              "crosses the slab from side to side as it rises, and wherever it comes out at the front it leaves a knob: one on the east "
              "side, then one on the west. The keeper came this way every day. His line from the cabin's spar ended at a pale scar on the "
              "blade's west side, where a flake had come away, and he went up the knobs to the slab's flat dry head, where his line pole "
              "stands. The line is torn now, so you swing on what is left of it and let go. Three winds lie across the blade, one above "
              "the other, and they take turns: east at its foot, west in its middle, east at its top."),
    "keep": [
        "The torn line, the fling to the scar, the eight knobs and the top, each exactly where it is.",
        "The blade's slick faces, and its point, which stands clear of the glacier's top.",
        "The three winds and their turns: east below 893 m, west from 893 to 898 m, east from 898 to 904 m.",
        "The fall line: the face, El Alero's cap and its brink.",
    ],
    "background": [
        {"name": "The ridge's far towers", "z": [-14.2, -14.0], "style": "line", "tag": [-288.6, 902.6],
         "text": _FAR_TEXT + "Two of them show east of the blade. They are blades too, so El Filo reads as the nearest of many.",
         "draw": _far([(-291.3, 2.8, 899.0), (-288.6, 2.2, 905.0)], 884.0)},
        {"name": "A cloud bank", "z": [-7.2, -7.0], "style": "mark", "tag": [-290.5, 895.6],
         "text": _BANK_TEXT + "It stands between the prow and the blade and behind the blade's lower half, so the knobs' side of the blade is seen against one plain grey.",
         "draw": [_cloud(-303.5, -287.0, 888.6, 898.2, 3, "mark")]},
        {"name": "The nook, and the cabin in it", "z": [-4.0, -1.2], "tag": [-309.4, 890.4],
         "text": "The start of the climb is the cabin's porch. The nook's slate wall, the cabin, its smoke and the prayer pole are on the cabin's own page.",
         "draw": _NOOK + _CABIN + _PRAYER_POLE},
        {"name": "El Filo's body", "z": [-3.8, -2.2], "tag": [-294.4, 891.0], "top": True,
         "text": "The slab the blade is the edge of: the same slate, 3.6 m wide, 3 m back, duller and greyer, in two leaning slabs. It "
                 "stops just under the blade's top and goes down into cloud. On it, in dull white paint, the quartz vein: a thin line "
                 "that runs out from behind each knob and across to the next, so you can see that the knobs are one thing. Nothing "
                 "else on the body is pale, so nothing on it can be taken for a second landing.",
         "draw": _FILO_BODY + _FILO_VEIN},
        {"name": "The cloud at its foot", "z": [-2.1, -1.9], "style": "pale", "tag": [-292.4, 885.3],
         "text": "A collar of painted cloud 11 m wide and 5 m tall, 2 m back, across the lower end of the body. The body sinks into it and "
                 "the blade's point hangs in front of it. It takes the place of the flat grey card that stood in front of the climb here (note 92).",
         "draw": [_cloud(-302.0, -291.0, 883.6, 888.3, 4, "pale")]},
        {"name": "Two wind socks", "z": [-2.4, -1.3], "style": "pale", "tag": [-300.4, 896.2],
         "text": "Note 89. The middle wind has no rest in it, so its flag is a canvas sock on a timber arm from the body's west side, at "
                 "895 m, 2.2 m back and more than a metre clear of the knobs. It streams west. The top wind's flag is a sock on a short stub at the "
                 "back of the blade's top. It streams east. The socks are plain grey canvas. They hang slack between gusts and lift 0.8 seconds before one.",
         "draw": _arm_sock(-297.7, 895.3, -1) + _sock(-295.15, 902.6, 1)},
        {"name": "The line pole's foot", "z": [-2.6, -1.3], "style": "pale", "tag": [-294.0, 905.3],
         "text": "The black pole on the top stands in a timber cradle bolted through an iron pug plate, and a square timber brace rakes "
                 "back from it to the body. The pole belongs to Banderas, above. From the blade you see that it is built, and that it is not rock.",
         "draw": [_r(-296.7, 902.6, -295.7, 902.95), _ln(-296.2, 905.8, -295.55, 902.95, "line")]},
    ],
    "play": [
        {"name": "The torn line and its spar", "z": [-0.3, 0.3], "style": "pale", "tag": [-302.7, 893.3],
         "text": "Hemp rope with the town's paper along all 4.3 m of it, hung from the spar under the prow's tip. The paper is the lowest "
                 "wind's flag at the very place you swing.",
         "draw": _SPAR + _LINE_PAPER},
        {"name": "The landing scar", "z": [-1.2, 1.2], "style": "line", "tag": [-298.2, 888.6],
         "text": "The 2.5 m of the blade's west side that holds: pale warm grey slate, dry and matte, broken in small square steps, with "
                 "a crisp edge all round where the flake came away. Everything else on the blade is blue-black and glossy with rain "
                 "running down it in thin white lines.",
         "draw": [_r(-296.95, 889.6, -296.5, 892.1)]},
        {"name": "The quartz knobs", "z": [-0.4, 0.4], "style": "line", "tag": [-294.6, 898.0],
         "text": "Eight knots of white quartz, each 0.5 m across and 0.3 m proud of the slate, dry and matte. Round each one the slate is "
                 "dry for a hand's width, so a knob never looks like a wet glint.",
         "draw": [_c(x, y, 0.34) for x, y in _FILO_KNOBS]},
        {"name": "The top", "z": [-1.2, 1.2], "style": "line", "tag": [-298.4, 902.3],
         "text": "The slab's flat head, 2.8 m wide: dry pale slate in square steps, the rest at the end of the climb. The top wind blows across it.",
         "draw": [_r(-297.6, 902.0, -294.8, 902.6)]},
        {"name": "Three winds, drawn", "z": [0.9, 1.2], "tag": [-290.0, 891.9],
         "text": "Note 89. Each wind is a stripe of long wavy white lines with an inked edge, exactly as tall as its band and as wide as "
                 "the screen, moving the way it blows. Here that is three stripes, one above the other, going east, west and east. The "
                 "rain leans the same way in each. Where the lines stop, the wind stops.",
         "draw": _wind([(-300.3, -287.6, 886.6), (-299.6, -287.6, 891.3)], 1) + _wind([(-302.3, -287.6, 894.2), (-305.5, -287.6, 897.1)], -1) +
                 _wind([(-308.0, -287.6, 899.0), (-310.6, -287.6, 901.2)], 1)},
    ],
    "foreground": [
        {"name": "A lip of drifted snow", "z": [1.2, 1.5], "tag": [-305.4, 884.6], "top": True, "text": _LIP_TEXT, "draw": _SNOW_LIP},
    ],
    "explains": [
        ["The torn line", "The keeper's line from the cabin to El Filo, snapped", "The spar it hangs from, and the cabin it came from"],
        ["The landing scar", "Where a flake came off the slab's west edge. The line was made fast here", "The slab's body behind it, with nothing pale on it"],
        ["The eight knobs", "A vein of white quartz, coming out at the front on one side and then the other", "The vein, painted on the body from knob to knob"],
        ["The blade's slick faces", "The cut edge of one slab of slate standing on end", "The slab's body, 3.6 m wide, going down into cloud"],
        ["The top", "The slab's dry head, and the foot of the keeper's line pole", "The pole's cradle and brace, and the top wind's sock"],
        ["The face and El Alero", "The fall line: whatever touches them slides to the brink and is thrown out over the glacier", "The nook's wall under the prow, and the cabin"],
    ],
    "pieces": [
        ["The ridge's far towers", "70 m wide, 90 m tall", "1, shared by the whole ridge", "Background, far", "kit: the ridge's far towers"],
        ["Cloud bank", "16 m wide, 9 m tall", "1", "Background", "kit: cloud bank"],
        ["Tower body for El Filo", "3.6 m wide, 18 m tall", "1", "Background", "kit: tower body"],
        ["Quartz vein, painted on the body", "0.1 m wide, 9 m of it", "1", "Background", "kit: quartz vein (added below)"],
        ["Cloud collar", "11 m wide, 5 m tall", "1", "Background", "kit: cloud collar"],
        ["Wind sock on a timber arm; on a stub", "sock 1.5 m; arm 0.8 m; stub 1.1 m", "1 of each", "Background", "kit: wind_sock; the arm and stub are added below"],
        ["Timber cradle and back brace for the line pole", "cradle 1 m; brace 3 m", "1 of each", "Background", "kit: timber back brace (added below)"],
        ["Rock tower: El Filo's blade, with its scar and its flat top", "1 m thick, 13 m tall; top 2.8 m", "1", "Play space", "kit: rock tower; dry scar"],
        ["Quartz knob", "0.5 m across", "8", "Play space", "kit: quartz knob"],
        ["Torn line; its spar", "4.3 m", "1 of each", "Play space", "kit: torn line; the spar"],
        ["The keeper's cabin; the nook; the prayer pole", "as on the cabin's page", "1 of each", "Background", "kit: the keeper's cabin; the ridge's flank; prayer_pole"],
        ["Lip of drifted snow", "4.6 m long", "1", "Foreground", "kit: the lip of drifted snow, from the sheet's foreground"],
    ],
    "effects": [
        "Wind lines in three stripes, each with its front and its whistle 0.8 seconds before the gust.",
        "Rain in three stripes: leaning east, leaning west, leaning east, and falling straight in a band that is resting.",
        "Rain running down the blade in thin white lines. It runs round each knob and leaves it dry.",
        "The torn line's paper streams east in a gust. You swing with it or against it.",
    ],
    "notes": [
        "Note 89: three winds cross this climb, and each is drawn across its whole band with its own flag: the torn line's paper and the cabin's smoke, a sock on the body, a sock on the top.",
        "Note 92: the flat grey cloud card in front of the blade's foot goes. A painted collar stands 2 m behind it.",
        "The tower's root card, which ends in the air at 880 m today, becomes the body, and the body ends inside the collar.",
        "The small slick patches that once stood on the rest ledges were taken out on 11-12. This design puts nothing on a rest that you can touch.",
        "Nothing you touch moves.",
    ],
}

# ------------------------------------------------------------------ 10.2 Banderas
_TIES = [_L1[0], _L1[1], _L2[0], _L2[1], _L3[0], _L3[1]]

BANDERAS = {
    "id": "10.2", "slug": "10_2_banderas", "title": "Banderas", "kind": "challenge",
    "window": [-315.0, 899.5, -290.0, 917.5], "screen": [-301.5, 908.2], "cut_y": 905.0, "climber": [-296.6, 902.6],
    "place": ("The keeper's rope way from El Filo to his station. The station's deck is 11 m higher than El Filo's top and 12 m to the "
              "west, too steep for one rope. So he strung it in three laps, like a path up a hillside: from a pole on El Filo out to the "
              "spire called La Aguja, back to the pole higher up, and out again over the spire to the corner of his deck. The ropes' "
              "upper ends ride on iron rings that he hauled up the pole after every storm, and he kept the pole black with grease so the "
              "rings would run and ice would not hold on it. That is why the pole cannot be climbed. The town tied its cut paper along all "
              "three ropes so he could find them in cloud, and it has gone on doing so: each paper now is a prayer for somebody who went "
              "up. One wind blows along the whole rope way, toward the station. It is with you on the first lap and the third, and "
              "against you on the second."),
    "keep": [
        "The three lines, their ends and their slack, and the two reaches between them: 1.6 m at the spire and 1.7 m at the pole.",
        "The pole and the spire. Neither can be held.",
        "The wind from 904 to 914 m, which blows west.",
        "The station deck's east corner, where the third line ends.",
    ],
    "background": [
        {"name": "The ridge's far towers", "z": [-14.2, -14.0], "style": "line", "tag": [-291.4, 915.6],
         "text": _FAR_TEXT + "Two show east of the pole, with a torn line painted between them.",
         "draw": _far([(-293.6, 2.6, 914.0), (-291.0, 2.0, 910.6)], 899.5) + [_ln(-293.4, 912.6, -291.2, 910.2, "mark")]},
        {"name": "A cloud bank", "z": [-7.2, -7.0], "style": "mark", "tag": [-299.3, 902.0],
         "text": _BANK_TEXT + "It lies behind the lower two lines, between El Filo and the spire, so the brightest paper on the mountain hangs against plain grey.",
         "draw": [_cloud(-304.0, -292.0, 900.2, 909.6, 3, "mark")]},
        {"name": "The ridge's flank", "z": [-3.6, -3.0], "tag": [-311.8, 909.6],
         "text": "The mountain behind the open air just east of the face: leaning ribs and gullies of slate, dull blue-grey, 3 m back. The "
                 "face is its near edge.",
         "draw": _flank(899.5, 917.5)},
        {"name": "La Aguja's body, and the cloud at its foot", "z": [-3.8, -1.9], "tag": [-308.4, 900.6],
         "text": "The spire's body, 3.6 m wide and 3 m back, sinks into a collar of cloud 8 m wide. The spire's point hangs in front of the collar.",
         "draw": [_p([(-307.7, 900.2), (-307.3, 904.3), (-306.5, 904.9), (-304.5, 904.9), (-303.7, 904.5), (-303.1, 900.2)]),
                  _cloud(-309.5, -301.5, 898.2, 903.0, 3, "pale")]},
        {"name": "The station tower's body, and the cloud at its foot", "z": [-3.8, -1.9], "tag": [-302.4, 911.2], "top": True,
         "text": "The station's tower is the near edge of a bigger body of rock, 12 m wide at the top, 3 m back. Its top is a shoulder that "
                 "reaches 6 m east of the deck, and the vane's mast stands on that shoulder. The shoulder's top is a row of leaning slab "
                 "ends, saw-toothed, wet and dark. It is never level for more than half a metre, so it cannot be taken for a floor beside "
                 "the deck. The body's lower end sinks into a collar of cloud 12.5 m wide, and La Aguja's spire stands up in front of that collar.",
         "draw": _STATION_BODY + [_cloud(-316.0, -303.5, 902.6, 907.6, 4, "pale")]},
        {"name": "The foot of the vane's mast", "z": [-2.8, -2.3], "style": "pale", "tag": [-301.6, 916.3],
         "text": "The vane's banded mast stands in a timber shoe in a notch of the shoulder, bolted through iron pug plates. Today it "
                 "stands on nothing. It is 2.5 m back, and the third line passes in front of it.",
         "draw": _VANE_SHOE + _vane_mast(913.85, 917.5)},
        {"name": "The station", "z": [-3.4, -1.4], "style": "pale", "tag": [-313.0, 915.0],
         "text": "The burnt hut behind the deck, where the third line ends. It is on El Rayo's page.",
         "draw": _HUT},
        {"name": "The pole's cradle, brace and torn end", "z": [-2.6, -1.3], "style": "pale", "tag": [-294.3, 906.6],
         "text": "The pole's foot is in a timber cradle on El Filo's top, and a square timber brace rakes back from the pole to El Filo's "
                 "body. From the pole's top a torn end of an older line streams west, 1 m long. It is the flag at the top of the rope "
                 "way. It moves from 0.3 m behind you to 1.3 m behind, out of the play space.",
         "draw": [_r(-296.7, 902.6, -295.7, 902.95), _ln(-296.2, 907.2, -295.4, 902.95, "line")] + _torn(-296.2, 910.3, -1) +
                 _sock(-295.15, 902.6, 1)},
    ],
    "play": [
        {"name": "Six iron rings", "z": [-0.3, 0.3], "style": "line", "tag": [-306.4, 908.3],
         "text": "Each line ends in an iron ring on a square plate with the pug's face. There are three on the pole, one above the other, "
                 "two on the spire, and one on a bollard at the corner of the station's deck. They are small and dark. They show that the lines are "
                 "made fast, and where one lap ends and the next begins.",
         "draw": [_c(x, y, 0.2) for x, y in _TIES]},
        {"name": "The paper", "z": [-0.4, 0.4], "style": "mark", "tag": [-300.5, 906.2],
         "text": "Cut paper in the town's colours at their loudest, hung along the whole of each rope, 0.9 m deep. A whole prayer line is "
                 "always a hold. The papers are the wind's flags here: they hang slack between gusts, lift 0.8 seconds before one, and "
                 "stream west in it, toward the station.",
         "draw": [_ln(p[0], round(p[1] - 0.75, 2), q[0], round(q[1] - 0.75, 2)) for p, q in (_L1, _L2, _L3)]},
        {"name": "The pole", "z": [-0.2, 0.2], "style": "mark", "tag": [-295.4, 909.0],
         "text": "Black greased steel, 7.7 m tall and as thick as a wrist, glossy, with rain beading on it. It is the first black "
                 "greased thing on the ridge. Everything black and greased from here up cannot be held.",
         "draw": [_ln(-296.05, 902.7, -296.05, 910.2)]},
        {"name": "The wind, drawn", "z": [0.9, 1.2], "tag": [-292.0, 912.6],
         "text": "Note 89. One stripe of long wavy white lines from 904 to 914 m, moving west along the rope way. The top wind of El "
                 "Filo shows under it, going east, and the mast's wind shows over it, going east.",
         "draw": _wind([(-312.6, -290.6, 905.9), (-314.2, -290.6, 909.3), (-306.6, -290.6, 912.9)], -1) + _wind([(-308.6, -290.6, 901.2)], 1) +
                 _wind([(-307.2, -290.6, 915.9)], 1)},
    ],
    "foreground": [],
    "explains": [
        ["The three lines", "The keeper's rope way to his station, in three laps, with the town's prayers tied along it", "The pole with its brace, the spire's two bolts, and the station's deck at the top"],
        ["The reach at the spire", "Where the first lap ends and the second begins", "Two iron rings on La Aguja, one above the other"],
        ["The reach at the pole", "Where the second lap ends and the third begins", "The pole's upper two rings"],
        ["The pole, which cannot be held", "The hauling pole for the lines' rings, kept greased", "Its timber cradle and brace on El Filo's top"],
        ["La Aguja, which cannot be held", "A spire of wet slate, the turning post of the rope way", "Its body, going down into cloud"],
        ["The deck's corner", "The end of the rope way: the weather station", "The burnt hut, and the tower's body with the vane's mast on its shoulder"],
    ],
    "pieces": [
        ["The ridge's far towers", "70 m wide, 90 m tall", "1, shared by the whole ridge", "Background, far", "kit: the ridge's far towers"],
        ["Cloud bank", "12 m wide, 9 m tall", "1", "Background", "kit: cloud bank"],
        ["The ridge's flank", "12 m wide, 12 m tall", "2 sections", "Background", "kit: the ridge's flank"],
        ["Tower body: La Aguja's; the station tower's, with its shoulder", "3.6 m wide; 12 m wide at the shoulder", "1 of each", "Background", "kit: tower body"],
        ["Cloud collar", "8 m and 12.5 m wide, 5 m tall", "2", "Background", "kit: cloud collar"],
        ["Timber shoe for the vane's mast", "1.2 m by 0.35 m", "1", "Background", "new, this area and Veleta"],
        ["Timber cradle and back brace for the pole", "cradle 1 m; brace 4.5 m", "1 of each", "Background", "kit: timber back brace (added below)"],
        ["Torn end", "1 m", "1", "Background", "kit: torn end on a post (prayer_flag)"],
        ["Prayer line", "8.5 m, 9.1 m, 12.2 m", "3", "Play space", "kit: prayer line (papel_line)"],
        ["Iron ring on a pug plate", "plate 0.3 m; ring 0.2 m", "6", "Play space (drawn on)", "kit: iron eye bolt on a pug plate (added below)"],
        ["Line pole", "7.7 m tall, 0.24 m thick", "1", "Play space", "kit: line pole"],
        ["Rock tower: La Aguja", "1.6 m wide, 6.5 m tall", "1", "Play space", "kit: rock tower"],
    ],
    "effects": [
        "The papers snap in a gust, and you hear them.",
        "Each rope sags and swings west in a gust. The paper shows it before you feel it.",
        "Rain leaning west across the whole band, and straight when the band rests.",
    ],
    "notes": [
        "Note 89: the papers on the three lines are this wind's flags, and the wind is drawn across its whole band.",
        "Note 92: the two flat grey cloud cards in front of La Aguja and the station's tower go. Painted collars stand 2 m behind their feet.",
        "The sheet found that the vane's mast stands on nothing. Here it stands on a shoulder of the station tower's body. The shoulder's top is saw-toothed so it cannot be read as a ledge beside the deck.",
        "Course change, scenery only: the torn end on the pole's top moves back 1 m, from 0.3 m behind you to 1.3 m behind.",
        "Nothing you touch moves.",
    ],
}

# ------------------------------------------------------------------ 10.3 El Rayo
_MX = -310.0
_STEEL = [_r(-310.8, round(y - 0.08, 2), -309.2, round(y + 0.08, 2), "line") for y in _RUNGS] + [_r(-310.1, 927.4, -309.9, 929.6, "line")]
_SPARKS = []
for _y in _RUNGS:
    _SPARKS += [_ln(-310.8, _y, -311.1, round(_y + 0.25, 2), "mark"), _ln(-309.2, _y, -308.9, round(_y + 0.25, 2), "mark")]
_BOLT = [_ln(-311.3, 934.0, -310.5, 932.3, "line"), _ln(-310.5, 932.3, -309.6, 931.1, "line"), _ln(-309.6, 931.1, -310.0, 929.6, "line"),
         _ln(-310.5, 932.3, -311.4, 931.4, "line")]

EL_RAYO = {
    "id": "10.3", "slug": "10_3_el_rayo", "title": "El Rayo", "kind": "challenge",
    "window": [-320.0, 904.5, -299.0, 934.0], "screen": [-309.5, 919.5], "cut_y": 914.6, "climber": [-308.2, 913.5],
    "place": ("The town's weather station, on a tower of its own. The hut stands on the tower's body and its floor runs forward as a "
              "plank deck. In front of the hut stands the mast that was built to take the lightning, so that nothing else would be "
              "struck: a spine of bare steel 16 m tall with a rod on its tip, built like a telegraph pole, with three timber crossarms "
              "that carried the station's instruments. The keeper had to climb it, so he boxed the steel in timber wherever he had to "
              "stand, and put white porcelain between the timber and the steel. It worked, and it still works. Lightning burnt half the "
              "hut's roof off years ago and takes the mast every 6 seconds. One of the ones who tried sits on the deck with his back to "
              "the hut and his hand on the first timber sleeve, looking up at the tip. He was waiting for it to stop. The way up is from "
              "timber to timber, two steel rungs at a time, between strikes."),
    "keep": [
        "Every piece of the mast where it is: the deck, four timber sleeves, three timber crossarms, the bare steel spine, six steel rungs, and the tip.",
        "The lightning: every 6 seconds, with 1.5 seconds of warning, live for 0.4 seconds. It takes steel only, and timber is safe.",
        "The frozen climber, seated where he is.",
        "The wind from 914 to 926 m, which blows east.",
    ],
    "background": [
        {"name": "The ridge's far towers", "z": [-14.2, -14.0], "style": "line", "tag": [-300.4, 931.0],
         "text": _FAR_TEXT + "Behind them the storm's own deck is at its darkest over the mast. The mast's steel is seen against that dark.",
         "draw": _far([(-300.6, 2.4, 929.5), (-304.6, 2.2, 912.0)], 904.5)},
        {"name": "The ridge's flank", "z": [-3.6, -3.0], "tag": [-316.6, 916.0],
         "text": "Leaning ribs of slate behind the open air just east of the face, 3 m back. It runs off the west of the frame.",
         "draw": _flank(904.5, 934.0)},
        {"name": "The station tower's body, and the cloud at its foot", "z": [-3.8, -1.9], "tag": [-305.6, 909.6],
         "text": "The body the tower is the near edge of, 12 m wide at the top, with the saw-toothed shoulder the vane's mast stands on. "
                 "Its lower end sinks into a collar of cloud. The tower's slick point hangs in front of the collar.",
         "draw": _STATION_BODY + [_cloud(-316.0, -303.5, 902.6, 907.6, 4, "pale")]},
        {"name": "The hut", "z": [-3.4, -1.4], "style": "pale", "tag": [-313.0, 915.0], "top": True,
         "text": "The kit's ruined hut, 3.6 m wide and 2.6 m tall, on the tower's body. The deck is its floor carried forward. The east "
                 "half of its roof, the half beside the mast, is burnt away: bare black rafter ends, and every burnt edge is black. The "
                 "west half still has its slates. It is weathered grey, a step duller than the deck.",
         "draw": _HUT},
        {"name": "The bolt sign", "z": [-1.42, -1.3], "tag": [-307.1, 915.9],
         "text": "Note 95. The mine's skull-pug board with one change: a white lightning bolt painted across it. It hangs on the hut's "
                 "wall between the mast and the corner where you arrive, at head height, facing you. You read it before you touch the mast.",
         "draw": _BOLT_SIGN},
        {"name": "The rain gauge and the cold lantern", "z": [-1.7, -1.3], "style": "line", "tag": [-307.1, 914.3],
         "text": "The station's small things, against the hut's east corner: the brass rain gauge on its stand, and a storm lantern on "
                 "the eave, dead and dented. The gauge stands in the play space today. It moves back 0.5 m, out of it.",
         "draw": [_r(-308.48, 913.5, -308.22, 914.4, "pale"), _c(-308.75, 915.78, 0.14)]},
        {"name": "What the crossarms carried", "z": [-2.6, -1.4], "style": "pale", "tag": [-312.7, 920.6], "top": True,
         "text": "Each crossarm is the front end of a timber yard that runs 2.4 m back, and an instrument still hangs under each yard's "
                 "far end. Behind the first: a small louvred box for the thermometer, grey slats. Behind the second: a storm cone of "
                 "black canvas, point down, the signal the station flew to warn the cableway of wind. It has been up for years. Behind "
                 "the third, the nest: a plank stage 1.2 m deep with a burnt hole in it, the keeper's top landing. None of them is "
                 "steel, and no spark ever crawls on them.",
         "draw": [_r(-308.72, 916.5, -308.24, 917.1), _p([(-312.05, 921.1), (-311.35, 921.1), (-311.7, 920.2)], "solid"),
                  _r(-311.6, 925.02, -308.4, 925.2)]},
        {"name": "The vane's mast, and two socks", "z": [-2.8, -2.3], "style": "pale", "tag": [-301.0, 920.4],
         "text": "Note 89. The vane's banded mast stands on the body's shoulder, 7 m east of the lightning mast and 2.5 m back. The "
                 "mast's wind has its flags here, clear of the climb: two grey canvas socks on the vane's mast, at 916 and 919 m, "
                 "below the vane's sweep. They stream east. Nothing that flaps is put on the lightning mast itself.",
         "draw": _VANE_SHOE + _vane_mast(913.85, 927.0) +
                 [_p([(-302.55, 916.65), (-301.05, 916.5), (-301.05, 916.3), (-302.55, 916.15)]), _p([(-302.55, 919.85), (-301.05, 919.7), (-301.05, 919.5), (-302.55, 919.35)])]},
    ],
    "play": [
        {"name": "Timber", "z": [-1.2, 1.2], "style": "mark", "tag": [-311.4, 918.5],
         "text": "Note 95. Everything safe is honey timber: the deck, the four sleeves and the three crossarms. It is thick and square, "
                 "0.6 m across on the sleeves, with grain, pegs and split ends, and it is warm in a cold picture. A sleeve is a "
                 "box of four planks round the spine, so you can see that the steel is inside it and that your hands are not on it.",
         "draw": [_ln(-310.42, y, -310.42, round(y + 1.9, 2)) for y in (913.5, 917.5, 921.5, 925.5)]},
        {"name": "Steel", "z": [-0.3, 0.3], "style": "line", "tag": [-308.4, 920.0],
         "text": "Note 95. Everything the lightning takes is bare steel: the six rungs, the three bare lengths of the spine, and the rod "
                 "on the tip. It is pale blue-grey, cold and matte, thin and round, half as thick as the timber, with rivet heads, and "
                 "scorched black at every joint. It holds, and it kills on the strike. Timber and steel differ in colour, in "
                 "thickness and in shape, so the mast still reads with the colour taken away.",
         "draw": _STEEL},
        {"name": "Porcelain", "z": [0.2, 0.6], "style": "pale", "tag": [-311.1, 927.3],
         "text": "Note 95. A stack of white ribbed porcelain at each of the seven places where steel meets timber: the top of each sleeve "
                 "and the underside of each crossarm. Each stack is drawn on the timber's side of the joint. So a hand on white is a hand "
                 "on timber, and the steel begins exactly where the white ends. There are three stacks today.",
         "draw": [_r(-310.36, a, -309.64, b) for a, b in _STACKS]},
        {"name": "The burnt star", "z": [-1.2, 1.2], "style": "mark", "tag": [-310.6, 912.5],
         "text": "A black star 2 m across, burnt into the deck's planks round the mast's foot. It says what the mast does before the first strike.",
         "draw": [_ln(-311.0, 913.52, -309.0, 913.52), _ln(-310.7, 913.7, -310.35, 913.52), _ln(-309.3, 913.7, -309.65, 913.52)]},
        {"name": "The warning and the strike, drawn", "z": [-0.3, 0.3], "tag": [-308.3, 931.6],
         "text": "Note 95. For the 1.5 seconds before a strike, blue-white sparks start at the deck and crawl up the steel to the tip, "
                 "faster and thicker, and a brush of sparks stands on both ends of every rung. A hum rises with them. The button mark on "
                 "any limb of yours that is on steel buzzes. Then the bolt: forked, white with an inked edge. It starts in the dark "
                 "cloud far behind the ridge and comes forward as it comes down, so it passes behind the two lone towers above and "
                 "behind anyone in the air between them, and reaches the play space only in its last 3 m, at the tip. The steel is "
                 "white and covered in sparks for the 0.4 seconds it is live. All of it is colour and sparks, never glow.",
         "draw": _SPARKS + _BOLT},
        {"name": "The one who waited", "z": [-0.4, 0.4], "style": "line", "tag": [-312.3, 913.0],
         "text": "The frozen climber sits where the course has him, on the deck with his back to the hut. One hand rests on the first "
                 "timber sleeve and his mask is turned up to the tip. His hand is on timber. That is the lesson, and he is right about it.",
         "draw": [_ln(-311.0, 914.55, -310.3, 914.7)]},
        {"name": "The winds, drawn", "z": [0.9, 1.2], "tag": [-316.0, 923.6],
         "text": "Note 89. The mast's wind, from 914 to 926 m, as long wavy white lines moving east. The rope way's wind shows below it going "
                 "west, and the vane's wind above it going west. The wind lines are white and long, and the sparks are blue-white, short "
                 "and only on steel, so the two are never taken for each other.",
         "draw": _wind([(-316.6, -299.6, 918.3), (-318.0, -299.6, 922.4)], 1) + _wind([(-314.6, -299.6, 908.4), (-315.6, -299.6, 911.4)], -1) +
                 _wind([(-320.0, -299.6, 928.3), (-320.0, -299.6, 932.9)], -1)},
    ],
    "foreground": [],
    "explains": [
        ["The deck", "The floor of the weather station's hut, carried forward", "The hut itself, half its roof burnt off"],
        ["The steel rungs, spine and tip", "A lightning mast, built to be struck", "The storm's darkest cloud above it, and the burnt hut beside it"],
        ["The timber sleeves", "Where the keeper boxed the steel in so that he could stand and wait", "The frozen climber, with his hand on the first one"],
        ["The three crossarms", "The yards that carried the station's instruments", "The thermometer box, the storm cone and the plank stage behind them"],
        ["The gaps of bare steel", "The lengths he had to climb fast", "The bolt sign on the hut's wall, and the burnt star at the mast's foot"],
        ["The wind on the mast", "The fifth of the ridge's winds", "Two socks on the vane's mast, 7 m east"],
    ],
    "pieces": [
        ["The ridge's far towers", "70 m wide, 90 m tall", "1, shared by the whole ridge", "Background, far", "kit: the ridge's far towers"],
        ["The ridge's flank", "12 m wide, 12 m tall", "3 sections", "Background", "kit: the ridge's flank"],
        ["Tower body: the station tower's, with its shoulder", "12 m wide at the top, 12 m tall", "1", "Background", "kit: tower body"],
        ["Cloud collar", "12.5 m wide, 5 m tall", "1", "Background", "kit: cloud collar"],
        ["Hut, with its burnt roof", "3.6 m wide, 2.6 m tall", "1", "Background", "kit: station_hut_ruin; the burnt roof"],
        ["Pug sign with a lightning bolt", "1 m board", "1", "Background", "kit: pug sign with a lightning bolt"],
        ["Rain gauge; cold lantern", "0.9 m; 0.5 m", "1 of each", "Background", "kit: rain_gauge, lantern_cold"],
        ["Instrument yard with a thermometer box; with a storm cone; plank stage", "yards 2.4 m; box 0.5 m; cone 0.9 m; stage 3.2 m by 1.2 m", "1 of each", "Background", "new. The stage shows again on Veleta's page"],
        ["The vane's mast and its shoe", "13.5 m", "1", "Background", "kit: vane_mast; the shoe is Banderas's"],
        ["Wind sock, on the vane's mast", "1.5 m", "2", "Background", "kit: wind_sock"],
        ["The mast: sleeves, crossarms, spine, rungs, tip", "16 m from deck to tip", "1", "Play space", "kit: the mast"],
        ["Porcelain stack", "0.7 m wide, 0.22 m tall", "7", "Play space", "kit: insulator, made shorter"],
        ["The station's deck, with the burnt star", "4.1 m; star 2 m", "1", "Play space", "kit: the station; the burnt star"],
        ["Frozen climber, sitting, one hand out", "1.2 m tall", "1", "Play space", "kit: frozen climber, sitting"],
        ["Sparks; the drawn bolt", "effects", "1 of each", "Play space; the bolt comes from behind", "kit: sparks on the steel; the drawn bolt"],
    ],
    "effects": [
        "The whole picture goes pale for an instant at each strike and everything throws a hard black shadow. It is a change of colour, never a glow.",
        "A wisp of smoke from the tip and from the burnt star after each strike.",
        "Thunder with the strike, at once. This is the one place on the ridge where they come together.",
        "Rain leaning east across the mast's band.",
        "The frozen climber's mask is lit white by each strike. He does not move.",
    ],
    "notes": [
        "Note 95, all five parts: steel looks like steel and timber like timber; sparks crawl up the steel for the 1.5 seconds of warning; the bolt is drawn and the steel stays lit while it is live; the button mark on a limb on steel buzzes; a pug sign with a bolt hangs on the hut, and the frozen climber shows where a hand is safe.",
        "The note's plan put the frozen climber's hand on the first rung. The first rung is 2 m above the deck and is steel. As the sheet has it, his hand rests on the timber sleeve.",
        "The sheet lists the frozen climber as scenery behind the deck. In the course he is a real thing in the play space that can be held, and this design leaves him there.",
        "The bolt: the course draws it from a point above and west of the mast. A straight line from there to the tip passes 0.1 m from the top of the second lone tower, where a climber stands. Here the bolt comes from far behind and reaches the play space only at the tip, so what is drawn touches only what it strikes.",
        "Note 89: the mast's wind is drawn across its whole band, and its flags stand on the vane's mast, not on the lightning mast.",
        "Course changes, scenery only: the rain gauge moves back 0.5 m, out of the play space. Seven porcelain stacks in place of three, each on the timber's side of its joint.",
        "Nothing you touch moves.",
    ],
}

# ------------------------------------------------------------------ 10.4 Veleta
_HUB = (-302.8, 927.0)
_CUPS = [[(4.6, -0.35), (5.4, -0.35), (5.4, 0.35), (4.6, 0.35)], [(-1.997, 4.159), (-2.397, 4.852), (-3.003, 4.502), (-2.603, 3.809)],
         [(-2.603, -3.809), (-3.003, -4.502), (-2.397, -4.852), (-1.997, -4.159)]]

VELETA = {
    "id": "10.4", "slug": "10_4_veleta", "title": "Veleta", "kind": "challenge",
    "window": [-315.0, 916.5, -282.0, 938.0], "screen": [-302.0, 927.5], "cut_y": 927.0, "climber": [-309.25, 925.5],
    "place": ("The station's wind vane, as big as a house. The cableway runs on wind, so the town built its biggest wind engine here to "
              "count it: three arms of greased black steel, 4.7 m long, with a cup on the end of each, painted the cableway's red with "
              "a cream band. It turns on a banded mast that stands on the shoulder of the station tower's body, and a box under its "
              "hub still counts every turn on a dial. It has not stopped since the keeper left: once round in 5 seconds. The top of the "
              "lightning mast, the nest, was his stage for it, and a cup comes up past the nest's east end every 1.7 seconds. East of the "
              "vane there is 15 m of air, and then La Torre, the tower where he flew his kites. The line he crossed on is gone. So you take "
              "a cup as it rises and let it throw you. The wind in this band blows west, against the throw, so you go when it rests. The "
              "camera pulls back here to show the whole throw and the fall under it."),
    "keep": [
        "The vane: its hub, its three arms, its three cups and its speed. Only the cups are held.",
        "The nest you leave from, and La Torre's scar and shoulder that catch you.",
        "The wind from 926 to 934 m, which blows west, against the throw.",
        "The needle's slick base above the shoulder, and the open air under the throw.",
    ],
    "background": [
        {"name": "The ridge's far towers", "z": [-14.2, -14.0], "style": "line", "tag": [-294.6, 933.6],
         "text": _FAR_TEXT + "Two stand in the gap you are thrown across, far back, and give the gap its size.",
         "draw": _far([(-296.6, 3.0, 928.0), (-294.2, 2.2, 932.6)], 916.5)},
        {"name": "A cloud bank", "z": [-7.2, -7.0], "style": "mark", "tag": [-298.6, 920.0],
         "text": _BANK_TEXT + "It lies under the throw, between the vane and La Torre. The fall is seen against it, and the face and El Alero show to its west.",
         "draw": [_cloud(-301.5, -290.0, 916.9, 925.3, 3, "mark")]},
        {"name": "The vane's mast and its counting box", "z": [-2.8, -2.3], "style": "pale", "tag": [-304.2, 921.6], "top": True,
         "text": "The kit's banded mast, 13.5 m tall, 2.5 m back, standing on the shoulder of the station tower's body. It is banded like "
                 "the cableway's masts, but dulled and greyed, because it is scenery. An axle 2.5 m long runs back from the hub to the "
                 "mast's head, so the wheel turns out in front of its mast, as the cableway's wind engines do. Under the head is a "
                 "timber box with a white dial on it, 0.6 m across, and a hand that goes round with the vane. Two socks lower on the "
                 "mast belong to the wind below.",
         "draw": _vane_mast(916.5, 927.0) + [_r(-303.3, 925.2, -302.3, 926.15, "solid"), _c(-302.8, 925.68, 0.3, "line"),
                                             _p([(-302.55, 919.85), (-301.05, 919.7), (-301.05, 919.5), (-302.55, 919.35)])]},
        {"name": "The head sock", "z": [-2.8, -2.3], "style": "pale", "tag": [-304.3, 929.9],
         "text": "Note 89. This wind's flag at the place you leave from: a grey canvas sock on a short staff on the mast's head, behind "
                 "the hub. It streams west, toward you on the nest, when the wind is against the throw, and hangs slack when it is safe to go.",
         "draw": [_r(-302.88, 927.0, -302.72, 928.9), _p([(-302.8, 928.9), (-304.3, 928.75), (-304.3, 928.55), (-302.8, 928.4)])]},
        {"name": "The nest's stage", "z": [-2.6, -1.4], "style": "pale", "tag": [-312.4, 925.1],
         "text": "Behind the nest: the plank stage the keeper stood on to tend the vane, 1.2 m deep, with a burnt hole in it. It is on El Rayo's page.",
         "draw": [_r(-311.6, 925.02, -308.4, 925.2)]},
        {"name": "La Torre's body, and the cloud at its foot", "z": [-3.8, -1.9], "tag": [-284.3, 926.4], "top": True,
         "text": "La Torre is the near edge of a body of slate 9 m wide, 3 m back. The body rises behind the shoulder as its back wall, and "
                 "it goes down past the block's slick point into a collar of cloud 14 m wide. Nothing on the body is pale: the scar is "
                 "the only pale thing on the tower's west side, so the place to land cannot be mistaken.",
         "draw": _torre_body(920.2) + [_cloud(-296.0, -282.0, 918.2, 923.3, 5, "pale")]},
        {"name": "The kite stand", "z": [-2.6, -1.3], "style": "pale", "tag": [-293.3, 936.6],
         "text": "On the wall behind the shoulder: the lowest of the kites' three reels, and this wind's flag at the place you land, a sock "
                 "on a stub at the back of the shoulder. It streams west. The reels are on El Papalote's page.",
         "draw": [_REELS[0], _REELS[3]] + _sock(-288.1, 932.5, -1)},
    ],
    "play": [
        {"name": "The cups", "z": [-0.4, 0.4], "style": "pale", "tag": [-296.6, 927.0],
         "text": "Three deep cups, each drawn at exactly the size that is held: 0.8 m by 0.7 m. They are red with a cream band, dry "
                 "and matte. That is the cableway's mark for a hold on a thing that moves, and you have known it since the cableway.",
         "draw": [_p([(round(_HUB[0] + x, 2), round(_HUB[1] + y, 2)) for x, y in cup]) for cup in _CUPS]},
        {"name": "The arms and the hub", "z": [-0.4, 0.4], "style": "line", "tag": [-301.7, 928.5],
         "text": "The three arms are black greased steel, glossy, 0.3 m thick, like the line pole on El Filo. They cannot be held, and "
                 "they are exactly as long and as thick as what is solid. The hub is an iron boss 1.2 m across with the pug's face on "
                 "it, greased black as well. The kit's vane has four arms and the course has three: the model follows the course.",
         "draw": [_c(_HUB[0], _HUB[1], 0.6)]},
        {"name": "The scar and the shoulder", "z": [-1.2, 1.2], "style": "line", "tag": [-292.4, 930.4],
         "text": "What catches you: 3.9 m of La Torre's west side where a flake came away, pale warm grey, dry and stepped, and above "
                 "it the shoulder's flat dry top, 3.5 m wide. Below the scar and above the shoulder the tower is blue-black and glossy.",
         "draw": [_r(-291.25, 928.6, -290.8, 932.5), _r(-291.0, 932.1, -287.5, 932.5)]},
        {"name": "The winds, drawn", "z": [0.9, 1.2], "tag": [-286.0, 929.3],
         "text": "Note 89. The vane's wind is one stripe from 926 to 934 m, as wide as the pulled-back screen, in long wavy white lines "
                 "moving west. You are thrown into those lines. Between gusts the stripe is empty, and that is when to go. The mast's "
                 "wind shows below it going east, and the kites' wind above it going east.",
         "draw": _wind([(-314.4, -282.6, 929.4), (-314.4, -282.6, 933.0)], -1) + _wind([(-314.4, -282.6, 923.3)], 1) + _wind([(-314.4, -282.6, 936.0)], 1)},
    ],
    "foreground": [],
    "explains": [
        ["The nest you leave from", "The keeper's top stage on the lightning mast", "The plank stage behind it"],
        ["The cups", "The wind cups of the town's biggest wind engine", "The hub's axle, the counting box and its dial, and the banded mast on the tower's shoulder"],
        ["The arms and the hub, which cannot be held", "Greased steel, so that ice never loads the wheel", "The same black as the line pole below"],
        ["La Torre's scar", "Where a flake came off the tower's west side", "The tower's body behind it, 9 m wide, with nothing pale on it"],
        ["The shoulder", "The keeper's kite stand", "The body's wall behind it, with a kite reel and a sock"],
        ["The air under the throw", "The fall line", "The cloud bank, and the far towers standing in it"],
    ],
    "pieces": [
        ["The ridge's far towers", "70 m wide, 90 m tall", "1, shared by the whole ridge", "Background, far", "kit: the ridge's far towers"],
        ["Cloud bank", "11.5 m wide, 8.5 m tall", "1", "Background", "kit: cloud bank"],
        ["The vane's mast, on its shoe", "13.5 m", "1", "Background", "kit: vane_mast"],
        ["Axle; counting box with a dial", "axle 2.5 m; box 1 m; dial 0.6 m", "1 of each", "Background", "new, this area only"],
        ["Wind sock: on the mast's head, on the shoulder's stub", "1.5 m", "2", "Background", "kit: wind_sock; the stub is added below"],
        ["Tower body for La Torre", "9 m wide, 26 m tall", "1", "Background", "kit: tower body"],
        ["Cloud collar", "14 m wide, 5 m tall", "1", "Background", "kit: cloud collar"],
        ["The vane: hub, three arms, three cups", "10.8 m across; cups 0.8 m by 0.7 m", "1", "Play space", "kit: the vane (anemometer), with three arms"],
        ["Rock tower: La Torre, with its scar and its shoulder", "6 m wide, 12 m tall; scar 3.9 m; shoulder 3.5 m", "1", "Play space", "kit: rock tower; dry scar"],
    ],
    "effects": [
        "The arms hum as they pass, and each cup whistles. You hear the rhythm before you see it.",
        "The dial's hand goes round once for each turn of the vane.",
        "Rain is thrown off each cup in a short arc as it comes over the top.",
        "The vane does not change speed in a gust. The sock and the lines tell you about the wind. The vane tells you only when a cup is coming.",
    ],
    "notes": [
        "Notes 76 and 77, what is drawn is what can be touched: the cups, the arms and the hub are modelled at exactly the course's sizes.",
        "Note 89: the vane's wind is drawn across its whole band, with a sock at the place you leave from and a sock at the place you land.",
        "Note 92: the flat grey cloud card in front of La Torre's foot goes. A painted collar stands 2 m behind it.",
        "The sheet found that the vane's mast stands on nothing. It stands on the station tower's shoulder, in a timber shoe.",
        "Course change, scenery only: the vane's mast moves 0.2 m east, to stand exactly under the hub, and back from 1.3 m behind you to 2.5 m behind.",
        "Nothing you touch moves.",
    ],
}

# ------------------------------------------------------------------ 10.5 El Papalote
_KITE = [(0.6, 0.0), (0.0, 0.72), (-0.6, 0.0), (0.0, -0.72)]

EL_PAPALOTE = {
    "id": "10.5", "slug": "10_5_el_papalote", "title": "El Papalote", "kind": "challenge",
    "window": [-301.5, 929.5, -281.5, 948.5], "screen": [-291.5, 938.5], "cut_y": 939.2, "climber": [-289.5, 932.5],
    "place": ("La Torre's shoulder was the keeper's kite stand. To measure the air higher than his mast he flew three kites from here, "
              "one above the other, each on its own reel, and the reels are still bolted to the rock wall behind the shoulder. He cut "
              "the kites from the town's paper, with the pug's face in each, and gave each one a tail of the same cut paper, 6 m long. "
              "A tail is a prayer line that flies. The storm has kept all three in the air ever since. Each flies the same figure of "
              "eight, over and over, beside the needle that stands on the tower's east half. You go up them tail to tail. The top one "
              "swings its tail to within a reach of a pale scar on the needle, and two quartz knobs lead from the scar to the needle's "
              "flat top. The wind here blows east, toward the needle."),
    "keep": [
        "The three kites, their figures of eight, their speed, and their 6 m tails.",
        "The needle's scar, its two knobs and its top, and the post on the top.",
        "The wind from 934 to 943.2 m, which blows east.",
        "The shoulder you start from. The first kite's tail sweeps it.",
    ],
    "background": [
        {"name": "The ridge's far towers", "z": [-14.2, -14.0], "style": "line", "tag": [-282.6, 947.3],
         "text": _FAR_TEXT + "One shows past the needle, to the east.",
         "draw": _far([(-282.8, 1.8, 946.4)], 929.5)},
        {"name": "A cloud bank", "z": [-7.2, -7.0], "style": "mark", "tag": [-296.0, 944.6],
         "text": _BANK_TEXT + "It stands behind the west half of the kites' flight. The kites are the brightest things in the picture, against grey.",
         "draw": [_cloud(-299.5, -291.5, 936.6, 945.6, 2, "mark")]},
        {"name": "La Torre's body", "z": [-3.8, -2.2], "tag": [-286.4, 935.0], "top": True,
         "text": "The body behind the shoulder and the needle, 9 m wide, 3 m back. It is the shoulder's back wall. It stops in a "
                 "saw-toothed top at about 941 m, 2.5 m below the needle's top, with one sharp spike on its west corner, so it cannot "
                 "be taken for a way up. The quartz vein of the needle's two knobs is painted on it in dull white. The kites fly half "
                 "in front of this wall and half in front of cloud.",
         "draw": _torre_body(929.5) + [_ln(-287.9, 941.3, -288.5, 940.9, "mark"), _ln(-287.9, 942.4, -288.5, 942.0, "mark")]},
        {"name": "The three reels", "z": [-2.6, -2.2], "style": "line", "tag": [-293.4, 937.9], "top": True,
         "text": "Three timber reels, each 0.8 m across, bolted to the west edge of the body on iron pug plates, one above the other. "
                 "Each reel is directly behind the middle of its kite's figure of eight. A kite's string is a dark thread no thicker "
                 "than a finger. It runs from the kite's back to its reel, 2.4 m behind, so from the front it is a short dark stroke "
                 "behind the kite, and nothing hangs under a kite but its tail. Each reel turns a little, back and forth, as its kite "
                 "flies. There is no post or pole here: nothing upright stands behind a hanging tail.",
         "draw": _REELS},
        {"name": "The shoulder's sock", "z": [-1.5, -1.3], "style": "pale", "tag": [-288.6, 934.6],
         "text": "The vane's wind, below 934 m, blows west across the shoulder. Its flag is a grey canvas sock on a stub at the back of the shoulder.",
         "draw": _sock(-288.1, 932.5, -1)},
        {"name": "The first lone tower's body, and its cloud", "z": [-3.8, -1.9], "tag": [-300.3, 933.6],
         "text": "At the west edge of the frame: the body of the first of the two lone towers, and the collar of cloud across its lower "
                 "end. The west turns of the kites pass in front of the collar's east end.",
         "draw": [_p([(-300.7, 937.6), (-300.1, 943.0), (-296.5, 943.3), (-296.1, 937.6)]), _cloud(-303.0, -293.5, 935.6, 940.6, 4, "pale")]},
        {"name": "Two torn ends", "z": [-1.4, -1.3], "style": "line", "tag": [-289.2, 946.6],
         "text": "On the top of the needle's post and on the first lone tower's post: the torn end of the keeper's high line, 1 m of "
                 "hemp and paper. Both stream west. They belong to the wind above, and they show the way on.",
         "draw": _torn(-287.35, 946.0, -1) + _torn(-298.95, 946.5, -1)},
    ],
    "play": [
        {"name": "The kites", "z": [-0.3, 0.3], "style": "pale", "tag": [-290.4, 940.5],
         "text": "Three paper diamonds, each drawn at exactly the size that is held: 1.2 m by 1.44 m. They are cut paper in the town's "
                 "colours on a split cane cross, with the pug's face cut out of the middle, dry and matte. The kit's kite is 2.5 m "
                 "across and is re-made at this size.",
         "draw": [_p([(round(cx + x, 2), round(cy + y, 2)) for x, y in _KITE]) for cx, cy in _KITES]},
        {"name": "The tails", "z": [-0.3, 0.3], "style": "mark", "tag": [-293.2, 931.0],
         "text": "Each tail is 6 m of hemp cord with cut paper along all of it, the same as a prayer line, and it is a hold from end to "
                 "end. It hangs from the kite's lowest point. The tails are this wind's flags: in a gust all three lean east together, "
                 "toward the needle.",
         "draw": [_ln(-292.3, 935.7, -292.3, 930.1), _ln(-291.5, 935.7, -291.5, 930.1)]},
        {"name": "The needle's scar and knobs", "z": [-1.2, 1.2], "style": "line", "tag": [-286.2, 939.0],
         "text": "On the needle's west side: 3 m of pale dry slate where a flake came away, and above it two knobs of white quartz. "
                 "The rest of the needle is blue-black and glossy from the shoulder to the top.",
         "draw": [_r(-287.75, 937.5, -287.3, 940.5), _c(-287.65, 941.6, 0.34), _c(-287.65, 942.7, 0.34)]},
        {"name": "The needle's top and its post", "z": [-1.2, 1.2], "style": "line", "tag": [-285.4, 944.6],
         "text": "The needle's flat dry top, 2.5 m wide, with a line post on its west corner: a square honey timber 2.5 m tall and 0.3 m "
                 "thick, pegged, on an iron pug plate. The post is the first of the keeper's high line and the start of Gendarmes.",
         "draw": [_r(-287.5, 943.1, -285.0, 943.5), _r(-287.5, 943.5, -287.2, 946.0)]},
        {"name": "The winds, drawn", "z": [0.9, 1.2], "tag": [-283.2, 937.9],
         "text": "Note 89. The kites' wind is one stripe from 934 to 943.2 m, in long wavy white lines moving east, across the kites and on "
                 "to the needle. The vane's wind shows below it going west, and the wind of the first flights above it going west.",
         "draw": _wind([(-301.0, -282.0, 937.9), (-301.0, -282.0, 940.5)], 1) + _wind([(-301.0, -282.0, 931.6)], -1) + _wind([(-301.0, -282.0, 947.4)], -1)},
    ],
    "foreground": [],
    "explains": [
        ["The shoulder you start from", "The keeper's kite stand", "The body's wall behind it, with three reels bolted to it"],
        ["The kites", "His three weather kites, cut from the town's paper, still flying", "A reel behind the middle of each one's figure of eight, and a dark string straight back to it"],
        ["The tails", "The town's prayers, tied in a string and flown", "The same paper as the prayer lines below"],
        ["The needle's scar", "Where a flake came off the needle", "The needle's body, which stops below the top"],
        ["The two knobs", "A quartz vein coming out at the front", "The vein, painted on the body"],
        ["The needle's top and its post", "The first post of the keeper's high line to the buttress", "The torn end on the post, streaming west, toward the next tower"],
    ],
    "pieces": [
        ["The ridge's far towers", "70 m wide, 90 m tall", "1, shared by the whole ridge", "Background, far", "kit: the ridge's far towers"],
        ["Cloud bank", "8 m wide, 9 m tall", "1", "Background", "kit: cloud bank"],
        ["Tower body for La Torre", "9 m wide, 26 m tall", "1", "Background", "kit: tower body"],
        ["Quartz vein, painted on the body", "0.1 m wide, 1.5 m of it", "1", "Background", "kit: quartz vein (added below)"],
        ["Kite reel on an iron pug plate", "reel 0.8 m; plate 0.3 m", "3", "Background", "kit: the kite's reel; iron eye bolt on a pug plate (added below)"],
        ["Wind sock on a stub", "sock 1.5 m; stub 1.1 m", "1", "Background", "kit: wind_sock; the stub is added below"],
        ["Tower body and cloud collar for the first lone tower", "3.6 m wide; collar 9.5 m wide", "1 of each", "Background", "kit: tower body; cloud collar"],
        ["Torn end on a post", "1 m", "2", "Background", "kit: torn end on a post (prayer_flag)"],
        ["Kite, with its tail", "1.2 m by 1.44 m; tail 6 m", "3", "Play space", "kit: kite, re-made at this size"],
        ["Rock tower: the needle, with its scar and top", "2.5 m wide, 11 m tall; scar 3 m", "1", "Play space", "kit: rock tower; dry scar"],
        ["Quartz knob", "0.5 m across", "2", "Play space", "kit: quartz knob"],
        ["Line post", "2.5 m tall, 0.3 m thick", "1", "Play space", "kit: line post"],
    ],
    "effects": [
        "Each kite's paper rattles, and louder as it turns at the ends of its figure of eight.",
        "The tails lift 0.8 seconds before a gust and lean east in it.",
        "Rain leaning east in the kites' band.",
    ],
    "notes": [
        "Notes 76 and 77, what is drawn is what can be touched: each kite is drawn at the size that is solid, and the whole of each tail is a hold.",
        "Notes 4 and 18, nothing thin hangs behind the climb: a kite's string runs straight back to a reel 2.4 m behind it, and nothing hangs under a kite but its tail.",
        "Note 89: the kites' wind is drawn across its whole band, and the three tails are its flags.",
        "Course change, scenery only: the torn end on the needle's post moves back 1 m, out of the play space.",
        "Nothing you touch moves.",
    ],
}

# ------------------------------------------------------------------ 10.6 Gendarmes
_POSTS = [(-287.5, -287.2, 943.5, 946.0), (-299.1, -298.8, 944.0, 946.5), (-312.7, -312.4, 944.5, 947.0)]
_NUBE_BANK_G = [_cloud(-327.5, -315.4, 941.6, 953.4, 4, "pale")]

GENDARMES = {
    "id": "10.6", "slug": "10_6_gendarmes", "title": "Gendarmes", "kind": "challenge",
    "window": [-329.0, 934.0, -284.0, 952.5], "cut_y": 945.0, "climber": [-286.2, 943.5],
    "place": ("The keeper's high line. From the needle on La Torre he strung one long line west, to the buttress that leans on the ridge, "
              "where the balloon's winch and the foot of the summit ladder are. It crossed 40 m of air in three spans, and to carry it he "
              "stood a square timber post on the needle and on each of the two lone towers between. The towers are thin: the top of each "
              "is 1.6 m wide. All three spans have snapped. What is left is the posts, each with a torn end of line streaming from its top, "
              "and the pale scars on the towers where flakes have come away. So you go the way the line went, through the air: from a "
              "post's top to the next tower, 10 m, then 12 m, then 14 m. Two winds meet here. East of the gap between the lone towers the "
              "wind blows west, and west of it the wind blows east. The camera pulls far back, to about 43 m across, to show a whole "
              "flight and the fall under it."),
    "keep": [
        "The three posts, and the three flights from their tops: 10 m, 12 m and 14 m.",
        "The landings: each lone tower's top and the scar on its east side, and the buttress's 1.5 m scar over its 1 m foothold.",
        "The two winds from 943.2 to 953 m: west on the east side, east on the west side, meeting at x -305.",
        "The towers' slick shafts and points. A body that misses passes under and behind every one of them.",
    ],
    "background": [
        {"name": "The ridge's far towers", "z": [-14.2, -14.0], "style": "line", "tag": [-306.6, 951.5],
         "text": _FAR_TEXT + "With the camera pulled back this is where the card shows best: a row of blades and needles in every gap, "
                 "the same shape as the three you are on, with a few torn lines painted between them.",
         "draw": _far([(-292.4, 2.8, 950.0), (-306.4, 3.0, 950.6), (-318.6, 2.6, 949.0), (-303.2, 2.0, 944.6)], 934.0) +
                 [_ln(-305.8, 949.6, -303.4, 944.2, "mark")]},
        {"name": "Three cloud banks", "z": [-7.2, -7.0], "style": "mark", "tag": [-305.4, 936.0],
         "text": "Painted banks 7 m back, one in each gap, with their heads just under the line of the flights. Each flight is seen "
                 "against open storm, and the fall under it against cloud.",
         "draw": [_cloud(-297.0, -288.8, 934.3, 942.0, 2, "mark"), _cloud(-310.6, -299.8, 934.3, 941.6, 3, "mark"), _cloud(-325.0, -313.4, 934.3, 941.0, 3, "mark")]},
        {"name": "The ridge's flank", "z": [-3.6, -3.0], "tag": [-322.6, 938.6],
         "text": "Under the buttress, the mountain behind the open air east of the face: leaning ribs of slate, 3 m back. The buttress is "
                 "the only tower that leans on it.",
         "draw": _flank(934.0, 941.6)},
        {"name": "La Nube's cloud and rib", "z": [-1.6, -1.2], "style": "pale", "tag": [-318.6, 950.6],
         "text": "East of the buttress, the cloud that sits on its shoulder: one bank 1.5 m back, with the rib of dark rock and its five "
                 "knobs standing in front of it. It is designed on La Nube's page. The third flight ends against it, so the buttress's "
                 "pale scar is seen against plain cloud.",
         "draw": _NUBE_BANK_G + _RIB},
        {"name": "The towers' bodies", "z": [-3.8, -2.2], "tag": [-314.6, 941.6], "top": True,
         "text": "Behind each lone tower, its body: the same slate, 3.6 m wide, 3 m back, duller and greyer, stopping just under the "
                 "tower's top. La Torre's body stands behind the needle at the east edge.",
         "draw": [_p([(-300.7, 937.6), (-300.1, 943.0), (-296.5, 943.3), (-296.1, 937.6)]), _p([(-314.3, 936.2), (-313.7, 943.5), (-310.1, 943.8), (-309.7, 936.2)]),
                  _p([(-288.6, 934.0), (-288.5, 943.0), (-284.6, 943.0), (-284.0, 942.2), (-284.0, 934.0)])]},
        {"name": "Two cloud collars", "z": [-2.1, -1.9], "style": "pale", "tag": [-301.6, 937.9],
         "text": "Across the lower end of each lone tower's body, 2 m back: a collar of painted cloud, 9.5 m and 10 m wide. Each tower's "
                 "slick point hangs in front of its collar. They take the place of the two flat grey cards that stood in front of the towers' feet (note 92).",
         "draw": [_cloud(-303.0, -293.5, 935.6, 940.6, 4, "pale"), _cloud(-317.0, -307.0, 934.1, 939.1, 4, "pale")]},
        {"name": "Three torn ends", "z": [-1.4, -1.3], "style": "line", "tag": [-310.6, 947.6],
         "text": "Note 89. The three whole paper lines that hang behind the flights today become what the story says they are: a torn end "
                 "on each post's top, 1 m of hemp and paper. They are the two winds' flags. The needle's and the first tower's stream "
                 "west. The second tower's streams east. So the two on the lone towers point at each other across the gap where the winds meet.",
         "draw": _torn(-287.35, 946.0, -1) + _torn(-298.95, 946.5, -1) + _torn(-312.55, 947.0, 1)},
        {"name": "Braces", "z": [-2.4, -1.3], "style": "line", "tag": [-296.6, 945.4],
         "text": "Each post is held by a square timber brace that rakes back from it to the tower's body, and by an iron pug plate at its "
                 "foot. A post that carried 40 m of line needed both.",
         "draw": [_ln(-287.35, 945.3, -286.5, 943.5), _ln(-298.95, 945.8, -298.1, 944.0), _ln(-312.55, 946.3, -311.7, 944.5)]},
    ],
    "play": [
        {"name": "The three posts", "z": [-0.3, 0.3], "style": "line", "tag": [-313.4, 948.0],
         "text": "Square honey timber, 2.5 m tall and 0.3 m thick, pegged, with a split top. The top is where you launch from. The torn "
                 "end streams from just behind it.",
         "draw": [_r(a, c, b, d) for a, b, c, d in _POSTS]},
        {"name": "The landings", "z": [-1.2, 1.2], "style": "line", "tag": [-296.4, 942.0],
         "text": "Each lone tower has a flat dry top and a pale scar on its east side: 2 m tall on the first, 1.5 m on the second. The "
                 "buttress has one scar, 1.5 m tall, over a foothold 1 m wide. Each is pale warm grey, dry and stepped, with a crisp "
                 "edge, on a tower that is otherwise blue-black and glossy. Seen from the post before, each landing is the only pale thing on its tower.",
         "draw": [_r(-297.7, 942.0, -297.25, 944.0), _r(-311.3, 943.0, -310.85, 944.5), _r(-326.95, 944.4, -326.5, 945.9), _r(-326.7, 944.0, -325.7, 944.4)]},
        {"name": "Two winds that meet, drawn", "z": [0.9, 1.2], "tag": [-305.0, 948.0],
         "text": "Note 89. From 943.2 to 953 m there are two stripes side by side. East of x -305 the long wavy white lines move west. West "
                 "of it they move east. Where they meet, between the two lone towers, the lines of both curl upward and die. You can "
                 "see the join from the first post. The first flight goes with its wind. The second starts with one and ends against the "
                 "other. The third is against its wind all the way. The kites' wind shows below, going east.",
         "draw": _wind([(-304.6, -284.6, 946.0), (-304.6, -284.6, 950.0)], -1) + _wind([(-328.4, -305.4, 948.0), (-325.6, -305.4, 951.4)], 1) +
                 [_ln(-304.6, 946.0, -305.0, 947.0), _ln(-305.4, 948.0, -305.0, 949.0), _ln(-304.6, 950.0, -305.0, 951.0), _ln(-305.4, 951.4, -305.0, 952.3)] +
                 _wind([(-324.6, -284.6, 942.3)], 1)},
    ],
    "foreground": [],
    "explains": [
        ["A post's top", "The head of a post that carried the keeper's high line", "Its brace to the tower's body, and the torn end of the span that snapped"],
        ["The first lone tower's top and scar", "A thin tower's dry head, and the place a flake came off it", "Its body, going down into a collar of cloud"],
        ["The second lone tower's top and scar", "The same", "Its body and its collar"],
        ["The buttress's scar and foothold", "The end of the high line: the last tower, leaning on the ridge", "The cloud on its shoulder, and the rib of knobs that goes up through it"],
        ["The air of the three flights", "The three snapped spans", "The far towers, with torn lines painted between them"],
        ["The towers' slick shafts", "Wet slate. A miss passes under and behind them", "The bodies, the collars, and the cloud banks under the flights"],
    ],
    "pieces": [
        ["The ridge's far towers", "70 m wide, 90 m tall", "1, shared by the whole ridge", "Background, far", "kit: the ridge's far towers"],
        ["Cloud bank", "8 to 12 m wide, 7 m tall", "3", "Background", "kit: cloud bank"],
        ["The ridge's flank", "12 m wide, 8 m of its height", "1 section", "Background", "kit: the ridge's flank"],
        ["Tower body", "3.6 m wide, 14 m tall", "2, and La Torre's", "Background", "kit: tower body"],
        ["Cloud collar", "9.5 m and 10 m wide, 5 m tall", "2", "Background", "kit: cloud collar"],
        ["Torn end on a post", "1 m", "3", "Background", "kit: torn end on a post (prayer_flag)"],
        ["Timber back brace; iron pug plate", "brace 2 m; plate 0.3 m", "3 of each", "Background", "kit: timber back brace; iron eye bolt on a pug plate (both added below)"],
        ["Line post", "2.5 m tall, 0.3 m thick", "3", "Play space", "kit: line post"],
        ["Rock tower: the two lone towers and the buttress, with their scars", "1.6 m wide, 6 to 8 m tall; the buttress 7.8 m wide", "3", "Play space", "kit: rock tower; dry scar"],
        ["La Nube's cloud bank and rib", "as on La Nube's page", "1 of each", "Background", "kit: cloud bank"],
    ],
    "effects": [
        "The torn ends lift 0.8 seconds before a gust. The two on the lone towers lift at different times, because the two winds are out of step.",
        "Rain leaning west on the east side and east on the west side, with a seam of straight rain where they meet.",
        "The far cloud flickers pale now and then, small and silent.",
        "The lightning's bolt, when it comes, is behind these towers and behind you. It does not cross the flights.",
    ],
    "notes": [
        "Note 89: both winds are drawn across their whole reach, their meeting is drawn, and each post carries a flag.",
        "Note 92: the two flat grey cloud cards in front of the lone towers' feet go. Painted collars stand 2 m behind them, and the towers' root cards, which end in the air today, become bodies that end inside the collars.",
        "Notes 4 and 18: the three whole paper lines behind the flights go. A whole prayer line is always a hold, and these were not. They become torn ends on the posts, as the sheet has it.",
        "Course changes, scenery only: three paper lines removed. The three torn ends move back 1 m, from 0.3 m behind you to 1.3 m behind.",
        "Nothing you touch moves.",
    ],
}

# ------------------------------------------------------------------ 10.7 La Nube
_NUBE_BANK = [_p([(-336.0, 940.5), (-314.0, 940.5), (-314.0, 951.2), (-336.0, 951.2)], "pale")]
_NUBE_TOP = [_cloud(-336.0, -314.0, 950.4, 954.6, 5, "pale")]

LA_NUBE = {
    "id": "10.7", "slug": "10_7_la_nube", "title": "La Nube", "kind": "challenge",
    "window": [-336.0, 940.5, -314.0, 956.5], "screen": [-324.2, 948.6], "cut_y": 948.0, "climber": [-326.2, 944.4],
    "place": ("One cloud never leaves the buttress. It sits on the buttress's east shoulder, between the last tower and the balloon, and "
              "the way up goes through the middle of it. The cloud is behind you, close: a wall of painted grey 1.5 m back, with the far "
              "view gone. Out of it stands a rib of dark rock, and up the rib runs a vein of white quartz that has left five knobs, each "
              "one a step east and a step up from the last. The rib is cracked across two thirds of the way up, and the rock above the "
              "crack has slipped: so the fourth knob is not where the first three say it will be. It is higher, and back to the west. "
              "You can see all of this. Nothing here is hidden, and the only test is whether you look before you reach. From the fifth "
              "knob the balloon's rope hangs within reach, and it goes up out of the top of the cloud into gold light."),
    "keep": [
        "The five knobs, each exactly where it is. The fourth stays out of line.",
        "The buttress's scar and foothold, where you start, and the reach from the fifth knob to the rope's foot.",
        "The wind from 943.2 to 953 m, which blows east here, away from the buttress.",
        "The cloud stays behind the climb. Nothing hides you or a hold.",
    ],
    "background": [
        {"name": "The cloud", "z": [-1.6, -1.5], "style": "pale", "tag": [-317.0, 945.0], "top": True,
         "text": "One painted bank, 24 m wide and 11 m tall, 1.5 m back. It fills the frame from side to side and from the bottom up "
                 "to 951 m. It is painted as cloud: big soft billows in three rows, darkest at the foot, in mid greys and slate blues, "
                 "with nothing near white, and no straight edge anywhere. It does not move across you. The two dark cards that stand "
                 "here today are replaced by it.",
         "draw": _NUBE_BANK},
        {"name": "The buttress's shoulder, seen through the cloud", "z": [-1.52, -1.5], "tag": [-322.0, 943.0],
         "text": "Painted on the bank, one tone darker than the cloud: the shape of the buttress's body, rising behind the rib. The "
                 "rib is the near edge of it. It has no outline and no detail. It is rock seen through cloud, and it says that the "
                 "knobs are on a mountain and not on a card.",
         "draw": _NUBE_SHADOW},
        {"name": "The summit's teeth, standing out of the cloud", "z": [-1.8, -1.4], "style": "line", "tag": [-320.6, 955.6],
         "text": "Above the cloud's top, the lowest ends of the rock teeth of the summit's crown, 1.4 m back. They are the summit's "
                 "pieces and are designed on its pages. Today each one stops square at 958 m, in the air, and the summit's pages "
                 "carry them down. This design asks that they stop at 953 m, behind the cloud's top, so that the crown stands out of "
                 "the storm and nothing of it comes down across this climb.",
         "draw": _teeth(956.5)},
        {"name": "The cloud's top", "z": [-1.36, -1.34], "style": "pale", "tag": [-316.6, 953.2],
         "text": "The top 4 m of the cloud is its own strip: a row of round heads, their tops between 953 and 954.6 m, standing 1.3 m "
                 "back, a hand in front of the bank. Above it the rain stops and the light is gold. It is a separate piece so that it "
                 "can stand in front of the feet of the summit's teeth, which are 1.4 m back.",
         "draw": _NUBE_TOP},
        {"name": "The rib", "z": [-1.3, -1.2], "style": "dark", "tag": [-326.0, 949.6], "top": True,
         "text": "A fin of dark wet slate just behind the play space, 2 m wide, rising from the foothold to the top of the cloud. It is "
                 "the darkest thing in the picture, and the white knobs stand on it. Painted on it in white: the quartz vein, a straight "
                 "line through the first three knobs. Then a clean black crack across the rib. Then the vein again, moved 1.3 m to the west "
                 "and 0.6 m up, through the last two knobs. The break in the vein points at the fourth knob. The rib's east edge is cut "
                 "back 0.4 m near its top, so no rock stands directly behind the balloon's rope.",
         "draw": _RIB},
        {"name": "A wind sock at the foothold", "z": [-1.3, -1.2], "style": "pale", "tag": [-324.0, 945.4],
         "text": "Note 89. This wind's flag where you start: a grey canvas sock on a short stub at the back of the foothold. It streams "
                 "east, away from the buttress, 1.3 m below the first knob.",
         "draw": _sock(-326.05, 944.4, 1, 1.0)},
        {"name": "The winch", "z": [-2.5, -1.3], "style": "pale", "tag": [-330.4, 956.0],
         "text": "At the top of the frame, on the buttress's top step: the balloon's winch. It is on El Globo's page.",
         "draw": _WINCH},
    ],
    "play": [
        {"name": "The five knobs", "z": [-0.4, 0.4], "style": "line", "tag": [-322.6, 947.4],
         "text": "Knots of white quartz, 0.56 m across and 0.3 m proud, dry and matte. They are the palest things in the picture. On the "
                 "dark rib each one shows from the foothold.",
         "draw": [_c(x, y, 0.36) for x, y in _NUBE_KNOBS]},
        {"name": "The scar and the foothold", "z": [-1.2, 1.2], "style": "line", "tag": [-328.0, 944.0],
         "text": "Where the third flight of Gendarmes lands: 1.5 m of pale dry slate on the buttress's east side, over a foothold 1 m "
                 "wide. It is the only perch before the cloud. The buttress above and below it is blue-black and glossy.",
         "draw": [_r(-326.95, 944.4, -326.5, 945.9), _r(-326.7, 944.0, -325.7, 944.4)]},
        {"name": "The rope's foot", "z": [-0.3, 0.3], "style": "pale", "tag": [-320.4, 949.4],
         "text": "The end of the balloon's one rope, with a small sandbag on it. It comes down out of the cloud's top and swings between "
                 "949 and 951 m as the balloon bobs. In a gust it leans east, away from the fifth knob, so it is the wind's flag at "
                 "the last reach. The rope is on El Globo's page.",
         "draw": [_ln(-321.5, 956.5, -321.5, 949.9, "line"), _c(-321.5, 949.7, 0.22)]},
        {"name": "The wind, drawn", "z": [0.9, 1.2], "tag": [-315.6, 947.6],
         "text": "Note 89. Long wavy white lines with an inked edge, moving east, from the buttress's side to the edge of the screen. "
                 "They show plainly against the cloud because of their inked edge. The headwall's wind shows above 953 m, going east as well.",
         "draw": _wind([(-326.4, -314.6, 947.6), (-326.4, -314.6, 950.1)], 1) + _wind([(-328.6, -314.6, 955.2)], 1)},
    ],
    "foreground": [],
    "explains": [
        ["The five knobs", "A vein of white quartz in a rib of the buttress", "The rib, the vein painted on it, and the buttress's shoulder showing through the cloud"],
        ["The fourth knob, out of line", "The rock above a crack has slipped, and the vein has gone with it", "The black crack across the rib, and the vein starting again higher and to the west"],
        ["The scar and the foothold", "Where a flake came off the buttress", "The rib's foot, and a wind sock at the foothold's back"],
        ["The rope's foot", "The balloon's rope, coming down through the cloud's top", "The cloud's top, and gold light above it"],
        ["The buttress's slick side and cap", "Wet slate. The fall line", "The cloud, which stays behind all of it"],
    ],
    "pieces": [
        ["Cloud bank, to fill the frame", "24 m wide, 11 m tall", "1", "Background", "kit: cloud bank"],
        ["The buttress's shoulder, painted on the bank", "6 m wide, 12 m tall", "1", "Background", "new paint on the cloud bank"],
        ["The rib: a fin of dark slate", "2 m wide, 9 m long, 0.1 m thick", "1", "Background", "a flat card today; the model is new"],
        ["Quartz vein, painted on the rib, with its crack", "0.1 m wide, 7 m of it", "1", "Background", "kit: quartz vein (added below)"],
        ["The cloud's top: a strip of round heads", "24 m wide, 4 m tall", "1", "Background", "kit: the cloud's top (added below)"],
        ["Wind sock on a stub", "sock 1.5 m; stub 1 m", "1", "Background", "kit: wind_sock; the stub is added below"],
        ["Quartz knob", "0.56 m across", "5", "Play space", "kit: quartz knob"],
        ["Dry scar and foothold on the buttress", "scar 1.5 m; foothold 1 m", "1", "Play space", "kit: dry scar"],
    ],
    "effects": [
        "Rain falls straight through the picture up to 952 m and leans east in a gust.",
        "The cloud goes pale for an instant when lightning takes the mast, far to the east and below. The rib and the knobs do not change.",
        "Sound is close and dull inside the cloud. The wind's whistle is the clearest thing in it.",
        "Thin wisps drift along the face of the bank, behind you. None of them ever crosses in front of you.",
    ],
    "notes": [
        "Note 92: cloud is painted as cloud and stands behind the climb. Note 40: nothing stands in front of where a climber can be.",
        "The blind version of this climb, with the scene dimmed and a flash every 4 seconds, was taken out on 11-12 and its cloud moved behind the climb. This design keeps that. The line for 10.7 in the list of challenges still describes the blind version.",
        "Note 89: the wind is drawn across the climb, and it has a flag at each end: a sock at the foothold and the rope's sandbag at the last reach.",
        "The fourth knob is the whole challenge. With nothing hidden it could pass unnoticed, so the rib says it out loud: a crack, and the vein stepping over.",
        "Course changes, scenery only: one painted bank in place of the two dark cards. The rib's east edge is cut back 0.4 m near its top. The top 4 m of the cloud stands 1.3 m back.",
        "Nothing you touch moves.",
    ],
}

# ------------------------------------------------------------------ 10.8 El Globo
EL_GLOBO = {
    "id": "10.8", "slug": "10_8_el_globo", "title": "El Globo", "kind": "challenge", "also": ["a11"],
    "window": [-337.0, 943.5, -312.0, 972.5], "screen": [-324.5, 957.5], "cut_y": 961.3, "climber": [-322.9, 951.9],
    "place": ("The station's weather balloon, still up. The keeper flew it from the buttress to measure the air above the storm: a skin "
              "of dark rubber as big as a room, a timber basket for the instruments under it, and a drag rope of hemp hanging from the "
              "basket with a bag of sand on its end. He wound it in and out with a hand winch on the buttress's top step, on a black "
              "greased cable. He left it out. It has ridden at the end of its cable ever since, bobbing 2 m, with its rope's foot "
              "inside the cloud and its skin in the sun. You take the rope from the last knob of La Nube and climb it. Part way up you "
              "come out of the top of the storm. The rain stops and the light turns gold. The feet of the summit's crown stand out of "
              "the cloud beside you. Then you swing the rope, let go to the west, and land beside the winch."),
    "keep": [
        "The balloon, its basket, and its bob of 2 m.",
        "The climb of 12 m up the rope, and the fling from it: about 9 m west and 2 m down to the buttress's top step.",
        "The skin is solid and slick. Whatever falls on it from the summit slides off its side.",
        "The headwall's wind, above 953 m, which blows east, against the fling.",
    ],
    "background": [
        {"name": "The cloud", "z": [-1.6, -1.5], "style": "pale", "tag": [-316.0, 947.0],
         "text": "La Nube's bank, from its own page. It fills the frame below 951 m, 1.5 m back. The rope's foot hangs inside it, in "
                 "rain and grey.",
         "draw": [_p([(-337.0, 943.5), (-312.0, 943.5), (-312.0, 951.2), (-337.0, 951.2)], "pale")]},
        {"name": "The summit's rock, standing out of the cloud", "z": [-3.4, -1.4], "tag": [-318.9, 966.0], "top": True,
         "text": "Above the cloud's top, what stands behind you is the summit's: three of its rock teeth 1.4 m back, the two pillars "
                 "that its horns stand on 1.8 m back, and its tan back 3 m back. They are designed on the summit's pages, which carry "
                 "them down below the summit's own frames. Today every one of them stops square at 958 m, in the air behind the rope. "
                 "Seen from the ridge they have to end somewhere. This design asks that the teeth stop at 953 m, behind our cloud's "
                 "top. The pillars and the back can go on down, because our cloud bank hides them. So the ridge's slate ends inside "
                 "the cloud, and you come up out of the storm with warm rock rising round you. The west pillar is the back wall of "
                 "the step you land on. The dark skin and the pale rope both show against it.",
         "draw": _pillars(972.5) + _teeth(972.5)},
        {"name": "The cloud's top", "z": [-1.36, -1.34], "style": "pale", "tag": [-314.4, 953.0],
         "text": "A strip of round heads, 1.3 m back, with their tops between 953 and 954.6 m, from La Nube's page. It stands in "
                 "front of the summit's rock: the feet of the teeth and the pillars go down behind it. You climb out through this "
                 "line. Above it nothing of the storm's stands behind you.",
         "draw": [_cloud(-337.0, -312.0, 950.4, 954.6, 5, "pale")]},
        {"name": "The rib and the last knob", "z": [-1.3, -1.2], "style": "dark", "tag": [-325.6, 949.0],
         "text": "La Nube's rib, from its own page. Its east edge is cut back so that the rope hangs against cloud and not against rock.",
         "draw": _RIB},
        {"name": "The winch and the arrow", "z": [-1.75, -1.3], "style": "pale", "tag": [-331.9, 956.2], "top": True,
         "text": "At the back of the buttress's top step, where the fling lands: a hand winch on a timber frame, 1.2 m wide and only "
                 "0.45 m deep, with a crank and a full drum, bolted down through iron pug plates. It is shallow so that it stands in "
                 "front of the summit's pillar. A guide post 2.2 m tall stands at its east end with an iron block at its head. The "
                 "kit's pug arrow board is nailed to the post, pointing up at the rungs. This is the machine that the balloon bobs "
                 "on. It is grey and wet, a step duller than the step you land on.",
         "draw": _WINCH + _ARROW_SIGN},
        {"name": "The cable", "z": [-1.4, -1.3], "style": "line", "tag": [-325.4, 960.6],
         "text": "Note 96 and the sheet. One cable of black greased steel, 0.15 m thick, from the block on the guide post up to an iron "
                 "ring under the back of the skin. About 9.5 m of it is in the air, and the rest of its 24 m is on the drum. It slants "
                 "at 30 degrees, it is black and glossy like the line pole and the vane's arms, and it is 1.3 m behind you. So it is "
                 "never taken for the rope, which is pale and hangs straight. It also points from the balloon to the place you land. "
                 "The thin tether that hangs straight down behind the ropes today goes.",
         "draw": _CABLE},
        {"name": "The landing's wind sock", "z": [-1.4, -1.3], "style": "pale", "tag": [-327.6, 958.3],
         "text": "Note 89. The headwall's wind has its flag at the place you are flinging to: a grey canvas sock under the block on "
                 "the guide post. It streams east, toward you on the rope, when the wind is against the fling, and hangs slack when it is safe to go.",
         "draw": _WINCH_SOCK},
    ],
    "play": [
        {"name": "The one rope", "z": [-0.2, 0.2], "style": "line", "tag": [-320.3, 955.0],
         "text": "Note 96. One hemp rope, 12 m long, hung from the middle of the basket's underside, in place of the two that hang 0.6 m "
                 "apart today. It is pale, dry and matte, and as thick as a wrist. On its end is a small canvas bag of sand, the weight "
                 "that the note proposes, so the wind does not carry the rope's foot away from La Nube's last knob. The bag is to be tested.",
         "draw": [_ln(-321.5, 961.0, -321.5, 949.9), _c(-321.5, 949.7, 0.22)]},
        {"name": "The basket", "z": [-0.5, 0.5], "style": "line", "tag": [-319.6, 961.3],
         "text": "A crate of honey timber, 1.6 m wide and 0.6 m tall, pegged, with an iron pug plate on its side. It is drawn at exactly "
                 "the size that is held. Nothing sticks out of it: the instruments are inside.",
         "draw": [_r(-322.3, 961.0, -320.7, 961.6)]},
        {"name": "The neck", "z": [-0.3, 0.3], "style": "pale", "tag": [-323.0, 962.2],
         "text": "Between the basket and the skin the course has 1 m of nothing. Something has to be drawn there, and what is drawn must "
                 "be what can be touched. So the basket hangs from a short neck of the same wet rubber, 0.5 m wide and 1 m tall, and "
                 "the design asks for the neck to be solid and slick like the skin. It would be the one new solid on this page, and "
                 "it is put to Parker below.",
         "draw": [_r(-321.75, 961.6, -321.25, 962.6)]},
        {"name": "The skin", "z": [-1.2, 1.2], "style": "mark", "tag": [-321.5, 965.2],
         "text": "Dark red-brown rubber, shining wet, 4.2 m across and 4.8 m tall, with two paler patches glued on and a seam round its "
                 "middle. It is drawn at exactly the size that is solid. Nothing on it is matte or dry. It reads as the one thing "
                 "above the cloud that you cannot hold.",
         "draw": [_c(-321.5, 964.9, 2.1)]},
        {"name": "The step you land on", "z": [-1.2, 1.2], "style": "line", "tag": [-331.6, 954.4],
         "text": "The buttress's top step: pale dry slate in square steps, 3.5 m long, the rest at the foot of the headwall. Below it the "
                 "buttress's cap is blue-black and glossy and slopes at 37 degrees to its brink. A fling that falls short lands on the cap.",
         "draw": [_r(-332.4, 955.0, -328.9, 955.5)]},
        {"name": "The winds, drawn", "z": [0.9, 1.2], "tag": [-314.0, 958.6],
         "text": "Note 89. Below 953 m: La Nube's wind, long wavy white lines moving east. Above it: the headwall's wind, also moving "
                 "east, in shorter and quicker gusts. Its lines cross the rope, the balloon and the landing. The fling goes against them, so "
                 "you go when the stripe is empty.",
         "draw": _wind([(-326.4, -312.6, 948.2)], 1) + _wind([(-331.0, -312.6, 954.3), (-331.4, -312.6, 958.6), (-333.2, -312.6, 963.3)], 1)},
    ],
    "foreground": [],
    "explains": [
        ["The rope", "The balloon's drag rope, with its bag of sand", "The basket it hangs from, and the cloud it comes down into"],
        ["The basket", "The crate that carried the station's instruments up", "The winch that let it out, on the buttress"],
        ["The skin and the neck, which cannot be held", "Wet rubber", "The cable from the ring under its back, slanting down to the winch"],
        ["The balloon's bob", "A balloon riding at the end of its cable in a gusting wind", "The cable, the block on the guide post, the full drum"],
        ["The step you land on", "The keeper's winding stage, and the foot of the summit ladder", "The winch, its guide post with the arrow and the sock, and the summit's west pillar behind them"],
        ["The air above 953 m", "The top of the storm", "The cloud's top below you, and the summit's teeth and pillars standing out of it"],
    ],
    "pieces": [
        ["Cloud bank; the cloud's top", "25 m wide", "1 of each", "Background", "kit: cloud bank; the cloud's top (added below)"],
        ["Hand winch with a guide post and block", "1.2 m wide, 0.45 m deep; post 2.2 m", "1", "Background", "kit: the balloon tether's hand winch; the guide post is new"],
        ["Pug arrow board, on the guide post", "0.8 m", "1", "Background", "kit: sign_pug_arrow, the board without its own post"],
        ["Black greased cable", "0.15 m thick, 24 m, 9.5 m of it in the air", "1", "Background", "kit: balloon tether, a black cable"],
        ["Wind sock, on the guide post", "1.5 m", "1", "Background", "kit: wind_sock"],
        ["Iron ring on a pug plate", "0.3 m", "3", "Background; play space (drawn on)", "kit: iron eye bolt on a pug plate (added below)"],
        ["Weather balloon: skin, neck, basket", "skin 4.2 m by 4.8 m; neck 0.5 m by 1 m; basket 1.6 m by 0.6 m", "1", "Play space", "kit: weather balloon; the neck is new"],
        ["Hemp rope with a sandbag", "12 m; bag 0.4 m", "1", "Play space", "kit: weather balloon's one rope"],
        ["The summit's teeth, pillars and back", "as on the summit's pages", "3 teeth, 2 pillars, 1 back", "Background", "the summit's kit: tooth of the crown; horn's root; the peak's own back"],
    ],
    "effects": [
        "The moment your head comes out of the cloud's top, the rain stops, the sound opens out, and the light on you turns from grey to gold.",
        "The skin creaks. Rain runs off it below the cloud's top, and above it the skin steams a little in the sun.",
        "The cable goes tight and slack with each bob, and the drum's pawl clicks.",
        "The sandbag swings east in a gust, a moment before the rope does.",
    ],
    "notes": [
        "Note 96: the balloon has one rope, hung from the middle of the basket. The fling is measured again from that one rope: its line moves 0.3 m. The last reach of La Nube is aimed at it.",
        "Note 96 also asks whether the light rope wants a weight on its end. The sandbag is that weight, shown here and still to be tested.",
        "The sheet found that the balloon's thin tether hangs straight down behind the rope and reads as more rope. It becomes one thick black cable, slanting to a winch.",
        "The sheet puts the cable 2 m back. The summit's teeth stand 1.4 m back in the same place, and its pillars 1.8 m back, and they would hide it. So the cable, the winch and its post stand 1.3 m back, in front of them.",
        "The join with the summit: its teeth, pillars and back stand behind everything above the cloud's top. The summit's pages carry them down. This page asks only that the teeth stop at 953 m, behind our cloud's top, so that none comes down across La Nube. The ridge's own flank ends inside the cloud.",
        "Notes 76 and 77, what is drawn is what can be touched: the skin and the basket are drawn at the size that is solid, and the neck is asked for so that it can be too.",
        "Note 89: both winds are drawn, and the headwall's wind has a flag at the place you fling to.",
        "Course changes: one rope at x -321.5 in place of two at x -321.8 and x -321.2, with a sandbag on its end. Asked below: one new slick solid, the neck, 0.5 m wide and 1 m tall, between the basket and the skin. Scenery: the thin tether is replaced by the slanting cable, a winch is added behind the top step, and the arrow sign's board moves onto the winch's guide post.",
    ],
    "ask": [
        "The balloon's neck, between the basket and the skin: may it be a new solid, slick like the skin, so that every drawn part of the balloon can be touched? Yes or no.",
    ],
}

# ------------------------------------------------------------------ 10.9 Escalera al Cielo
_HOLES = [956.4, 957.6, 958.77, 959.33, 960.5, 961.65]
_STREAKS = []
for _y in _HOLES:
    _STREAKS += [_c(round(_F(_y) - 0.22, 2), _y, 0.07, "line"), _ln(round(_F(_y) - 0.22, 2), _y, round(_F(_y - 0.8) - 0.22, 2), round(_y - 0.8, 2), "mark")]
_SOUND = [_r(round(_F(y) - 0.1, 2), round(y - 0.08, 2), round(_F(y) + 0.8, 2), round(y + 0.08, 2), "line") for y, rot in _CIELO if not rot]
_ROTTEN = [_r(round(_F(y) - 0.1, 2), round(y - 0.08, 2), round(_F(y) + 0.8, 2), round(y + 0.08, 2), "pale") for y, rot in _CIELO if rot]

ESCALERA = {
    "id": "10.9", "slug": "10_9_escalera_al_cielo", "title": "Escalera al Cielo", "kind": "challenge", "also": ["a11"],
    "window": [-345.0, 951.5, -322.0, 970.5], "screen": [-333.5, 960.2], "cut_y": 957.0, "climber": [-329.4, 955.5],
    "place": ("The last of the ridge, and the last thing the town built on the mountain. From the buttress's top step an iron ladder went "
              "up the headwall to the summit's ledge: a row of thick iron rungs driven into the slate, each one sticking straight out "
              "from the face, with a rail joining their outer ends. It was made by the same hands as the cableway, of the same "
              "rust-orange iron as every rung since the mine. The storm has had it for years. The rail is gone and most of the rungs with it. Four are left. Two are "
              "sound. Two are eaten through and hold for a moment. Up the face between them runs a line of empty bolt holes, each with a "
              "rust streak under it, so you can see where every missing rung was. You are above the storm here. The cloud's top is under "
              "your feet, no rain falls, and gold light comes down the wall from the summit. But the ridge's last wind is its hardest. "
              "It blows straight off the face, and a fall from these rungs is the whole mountain. At the top you go out round the end of "
              "the summit's ledge and onto it."),
    "keep": [
        "The four rungs, each where it is: sound, rusted, a gap of 1.7 m, sound, rusted. A rusted rung holds for 1.2 seconds.",
        "The last two reaches: to the east end of the summit's ledge at 962.4 m, and up onto its top at 964 m.",
        "The wind above 953 m, which blows east, off the wall, in gusts of 1.8 seconds with 3 seconds between.",
        "The buttress's top step, where you start. The face itself cannot be held.",
    ],
    "background": [
        {"name": "The summit's west pillar", "z": [-3.4, -1.4], "tag": [-327.3, 964.6], "top": True,
         "text": "The back wall of the headwall's air is not the ridge's. It is the pillar that the summit's west horn stands on: warm "
                 "tan rock, 8 m wide, 1.8 m back, with one of the crown's teeth standing in front of it and the summit's tan back "
                 "behind. They are the summit's pieces and are on its pages. Our side of it: the ridge's slate flank ends below you, "
                 "inside the cloud, and from the top step up the only slate left is the face under your hands. That change, from "
                 "blue-grey rock behind you to warm rock behind you, is the join.",
         "draw": [_pillars(970.5)[0], _p([(-329.95, 953.4), (-327.25, 953.4), (-327.85, 970.5), (-329.35, 970.5)], "line")]},
        {"name": "The top of the storm", "z": [-1.6, -1.34], "style": "pale", "tag": [-324.2, 952.6],
         "text": "East of the buttress and below you: the round heads of the cloud's top, at 953 to 954.6 m, 1.3 m back. The foot of "
                 "the pillar goes down behind it. It is the last cloud of ours that you see. Past it and far below is the storm's own deck.",
         "draw": [_cloud(-329.0, -322.0, 950.4, 954.6, 2, "pale")]},
        {"name": "The winch, the arrow and the sock", "z": [-1.75, -1.3], "style": "pale", "tag": [-331.0, 958.3],
         "text": "At the back of the top step: the balloon's winch, from El Globo's page, with its cable going off to the east. The "
                 "kit's pug arrow board is nailed to the winch's guide post and points up at the rungs. Today the board stands on a "
                 "post of its own directly behind the first rung, inside the play space. The sock under the post's block is the "
                 "headwall's flag as well as the balloon's. It streams east, off the wall, and you can see it from every rung.",
         "draw": _WINCH + _ARROW_SIGN + _WINCH_SOCK + [_ln(-330.05, 957.75, -322.0, 962.15, "line")]},
        {"name": "Two fallen rungs", "z": [-1.7, -1.3], "style": "line", "tag": [-329.0, 954.6],
         "text": "Lying at the back of the step, east of the winch: two iron rungs that came out whole, rusted dark, one bent. "
                 "They are the two that are missing from the long gap. They lie flat and dull, behind you, and are not holds.",
         "draw": [_ln(-329.8, 955.58, -329.0, 955.58), _ln(-329.7, 955.72, -329.05, 955.62)]},
        {"name": "The ledge above", "z": [-2.1, -2.0], "style": "mark", "tag": [-338.0, 966.6],
         "text": "The ledge at 964 m is designed on the summit's pages, as a tea shop. This page gives it nothing. What you see of it "
                 "from the rungs is its underside, a thread of steam from the shop's pipe, and the summit's line of whole, bright, dry "
                 "paper under the prow. The ridge's own paper line there, which hangs only 1.4 m over the floor, is taken down on the summit's page.",
         "draw": [_ln(-340.5, 967.9, -331.5, 967.9)]},
    ],
    "play": [
        {"name": "Two sound rungs", "z": [-0.5, 0.5], "style": "line", "tag": [-334.3, 956.7],
         "text": "Each is a straight iron bar 0.9 m long and 0.16 m thick, standing out from the face, rust-orange, dry and matte. A "
                 "square iron plate with two bolts holds it to the slate, and its outer end has a round eye where the rail was bolted. "
                 "A sound rung is thick, straight and bolted at both ends.",
         "draw": _SOUND},
        {"name": "Two rusted rungs", "z": [-0.5, 0.5], "style": "pale", "tag": [-334.8, 958.2],
         "text": "The mountain's one breakable look: cracked already, with a corner gone. A rusted rung is eaten to half its thickness, "
                 "pale and scabbed, cracked through beside its plate, with one of the plate's two bolts missing, so its outer end has "
                 "dropped by a hand's width. It sheds flakes of rust all the time. It is drawn inside the shape that is held. It holds "
                 "for 1.2 seconds, then its inner end tears out and it swings down on its last bolt and hangs flat against the wet "
                 "face, dark, inside its own rust streak. Eight seconds later a gust lifts it, and it knocks back into its socket with a "
                 "clank and a puff of rust. Only then can it be held again.",
         "draw": _ROTTEN},
        {"name": "Where the ladder was", "z": [1.1, 1.2], "tag": [-335.8, 960.4],
         "text": "Painted on the face, up the line the ladder took: a pair of dark bolt holes at each place a rung is gone, six places, "
                 "with a long rust streak running down the slate from each. In the long gap, where two rungs came out together, each "
                 "pair of holes keeps a black nub of iron no longer than a thumb. The stub that is there today is 0.35 m long, in a "
                 "hold's own colour, and cannot be held. It is cut down to one of these nubs.",
         "draw": _STREAKS},
        {"name": "The top step", "z": [-1.2, 1.2], "style": "line", "tag": [-333.4, 954.9],
         "text": "Pale dry slate in square steps, 3.5 m long. It is the last slate you stand on.",
         "draw": [_r(-332.4, 955.0, -328.9, 955.5)]},
        {"name": "The ledge's end", "z": [-1.2, 1.2], "style": "line", "tag": [-331.0, 963.0],
         "text": "The last two reaches are on the east end of the ledge, which overhangs the face by 2 m. This end of the ledge is "
                 "the ridge's last slab of slate: dry, pale warm grey, in square steps, the same as every tower's top, and the only "
                 "pale rock on the wall. Two old bolt holes with rust under them show where the ladder's top bracket was. The summit's "
                 "page has this slab leaning on the summit's cream rock 8 m to the west. The top of the ledge is the summit's to design.",
         "draw": [_r(-332.3, 962.0, -332.0, 964.0)]},
        {"name": "The last wind, drawn", "z": [0.9, 1.2], "tag": [-325.0, 963.6],
         "text": "Note 89. One stripe of long wavy white lines from 953 m to above the ledge, moving east, starting at the face itself. "
                 "The lines come off the wall where your hands are. Its gusts are shorter and come more often than any other on the "
                 "ridge. The flakes of rust from the two bad rungs fly east in it, and so does the paper over the ledge.",
         "draw": _wind([(-331.2, -322.6, 957.6), (-332.4, -322.6, 960.5), (-331.8, -322.6, 963.6), (-339.6, -322.6, 966.8)], 1)},
    ],
    "foreground": [],
    "explains": [
        ["The top step", "The buttress's top: the keeper's winding stage and the ladder's foot", "The winch with the arrow on its post, and two fallen rungs"],
        ["The two sound rungs", "What is left of the town's iron ladder to the summit", "The line of bolt holes and rust streaks up the face, above and below them"],
        ["The two rusted rungs", "The same ladder, eaten through", "The rust they shed, blowing east"],
        ["The long reach in the middle", "Two rungs gone together", "Two pairs of holes with black nubs, and the two rungs themselves lying on the step"],
        ["The end of the ledge", "The ridge's last slab of dry slate, lying on the summit: the ladder's head", "The summit's west pillar behind it, and the prow of the snow dome over it"],
        ["The face, which cannot be held", "Wet slate to the very top", "Warm rock, not slate: the summit's pillar, 1.8 m back"],
    ],
    "pieces": [
        ["The cloud's top", "7 m of its width", "1", "Background", "kit: the cloud's top (added below)"],
        ["Hand winch, guide post, sock and cable", "as on El Globo's page", "1", "Background", "kit: the balloon tether's hand winch"],
        ["Pug arrow board, on the guide post", "0.8 m", "1", "Background", "kit: sign_pug_arrow, the board without its own post"],
        ["Fallen rung, lying; bent", "0.9 m", "2", "Background", "kit: iron rung, rusted dark"],
        ["Iron rung, sound, with its plate and eye", "0.9 m long, 0.16 m thick", "2", "Play space", "kit: iron rung, sound"],
        ["Iron rung, rusted through: whole, hanging, and knocking back", "0.9 m long", "2", "Play space", "kit: rung, rusted through"],
        ["Bolt holes with a rust streak; with a nub", "holes 0.1 m; streak 0.8 m; nub under 0.1 m", "6 pairs, 2 with nubs", "Play space (drawn on)", "kit: the bolt holes and rust streaks; rung_stub, cut down"],
        ["The summit's west pillar, a tooth, and the ledge", "as on the summit's pages", "1 of each", "Background; play space", "the summit's kit: horn's root; tooth of the crown"],
    ],
    "effects": [
        "Gold light from above on everything that faces up. Your shadow falls down the wall.",
        "Water runs down the face in thin bright lines from the snow above. The face is wet, though no rain falls here.",
        "A rusted rung groans when a hand takes it, and flakes fall from it faster.",
        "Rust flakes and the sock on the winch lift 0.8 seconds before each gust.",
        "Far below, to the east, the storm flickers. You are looking down on it.",
    ],
    "notes": [
        "The sheet's way out: the slate and the rain end below you, the top of the storm is under your feet, and the light is gold from above. Here the slate behind you ends inside the cloud, and the slate under your hands ends at the ledge. Note 97, the tea shop on the ledge, is on the summit's pages.",
        "Note 89: the last wind is drawn from the face out, with three flags: the winch's sock, the rust flakes and the paper over the ledge.",
        "The second playtest's law: what is drawn is what can be touched, and a thing that comes is seen coming. A rusted rung is drawn inside the shape that is held, and it comes back where you can watch it.",
        "The sheet's rusted rung hangs by one bolt with its other end dropped. Here the end drops by a hand's width only, so the drawing stays on the solid.",
        "The join with the summit: the back of the headwall is the summit's west pillar, on the summit's pages. The exit ledge's east 8 m is the ridge's last slab of slate, as the summit's page for the ledge has it.",
        "Course changes, scenery only: the arrow sign's board moves 1.5 m east and 0.3 m back, onto the winch's guide post, out of the play space and out from behind the first rung. The rung stub in the play space is cut down to a nub, and a second nub is added. The ridge's paper line over the exit ledge is taken down, on the summit's page.",
        "Nothing you touch moves.",
    ],
    "ask": [
        "A rusted rung comes back 8 seconds after it breaks. Here it swings down on its last bolt, hangs, and a gust knocks it back up. Is that how it should come back: yes or no?",
    ],
}

# ------------------------------------------------------------------ pieces more than one area uses, added to the ridge's kit
KIT_MORE = [
    ["Sock stub and sock arm: a short square timber for a wind sock, standing or bolted to a tower's body", "stub 1.1 m; arm 0.8 m", "a flag at standing height on a rest, or on a tower's body in the middle of a wind, where a 4 m pole would reach into the wind above. The sock is plain grey canvas", "Background", "new; the sock is in the kit: wind_sock"],
    ["Iron eye bolt on a square plate with the pug's face", "plate 0.3 m; eye 0.2 m", "wherever a line, a brace, a post or a cable is made fast: the six ties of Banderas, the foot of every post and of the line pole, the winch, the cabin's posts", "Play space (drawn on), background", "new"],
    ["Quartz vein, painted on a tower's body or on the rib", "0.1 m wide, to suit", "behind every row of quartz knobs: El Filo, the needle, La Nube. A knob is where the vein comes out at the front", "Background", "new, paint"],
    ["Timber back brace: a square raking strut", "0.25 m thick, 2 to 4.5 m long", "from the line pole and from each line post, back to the tower's body", "Background", "new"],
    ["The cloud's top: a strip of round heads", "24 m wide, 4 m tall", "1.3 m back, along the top of La Nube's bank at 953 m, in front of the feet of the summit's teeth", "Background", "new; the cloud bank's top row as its own piece"],
]

AREAS = [THE_GAP, THE_CABIN, EL_FILO, BANDERAS, EL_RAYO, VELETA, EL_PAPALOTE, GENDARMES, LA_NUBE, EL_GLOBO, ESCALERA]
