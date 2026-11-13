# The chimney's areas, one dict each. Format: see ../build.py.
# Order: the smith's hut on the forge floor (where every fall ends), then the nine challenges, bottom to top.
import math


# ------------------------------------------------------------------ shared shapes
def _fy(x):
    """The top of the forge floor at x (it dips to 478.0 at x -262)."""
    return round(480.0 - (x + 291.0) * 2.0 / 29.0 if x < -262.0 else 478.0 + (x + 262.0) * 1.2 / 26.0, 2)


def _pipe(x0, y0, x1, y1, step=1.6):
    """A fat iron pipe with rib bands, upright or level."""
    x0, x1, y0, y1 = min(x0, x1), max(x0, x1), min(y0, y1), max(y0, y1)
    out = [["rect", x0, y0, x1, y1, {"style": "pale"}]]
    if y1 - y0 >= x1 - x0:
        y = y0 + step / 2
        while y < y1 - 0.15:
            out.append(["rect", x0 - 0.1, round(y - 0.09, 2), x1 + 0.1, round(y + 0.09, 2), {"style": "solid"}])
            y += step
    else:
        x = x0 + step / 2
        while x < x1 - 0.15:
            out.append(["rect", round(x - 0.09, 2), y0 - 0.1, round(x + 0.09, 2), y1 + 0.1, {"style": "solid"}])
            x += step
    return out


def _wheel(cx, cy, r, n=6, turn=0.3):
    """An iron wheel seen face on: rim, spokes, hub."""
    out = [["circle", cx, cy, r, {"style": "line"}]]
    for i in range(n):
        a = turn + 2 * math.pi * i / n
        out.append(["line", cx, cy, round(cx + r * math.cos(a), 2), round(cy + r * math.sin(a), 2), {"style": "line"}])
    out.append(["circle", cx, cy, round(max(0.14, r * 0.14), 2), {"style": "pale"}])
    return out


def _arch(x0, y0, x1, y1, style="dark"):
    """The temple's stepped arch: two sides stepping in to a flat lintel."""
    s = round((x1 - x0) * 0.17, 2)
    return ["poly", [[x0, y0], [x0, y1 - 2 * s], [x0 + s, y1 - 2 * s], [x0 + s, y1 - s], [x0 + 2 * s, y1 - s], [x0 + 2 * s, y1],
                     [x1 - 2 * s, y1], [x1 - 2 * s, y1 - s], [x1 - s, y1 - s], [x1 - s, y1 - 2 * s], [x1, y1 - 2 * s], [x1, y0]], {"style": style}]


def _door(x0, y0, x1, y1):
    """A stair door: a stepped arch shut with an iron grille."""
    out = [_arch(x0, y0, x1, y1)]
    n = 3
    for i in range(1, n + 1):
        x = round(x0 + (x1 - x0) * i / (n + 1), 2)
        out.append(["line", x, y0, x, y1 - 0.75, {"style": "line"}])
    return out


def _jib(xp, y0, y1, xa, flip=False):
    """A wall jib: a post from y0 to y1 at xp, an arm out to xa, and a brace."""
    w = 0.15
    out = [["rect", xp - w, y0, xp + w, y1, {"style": "pale"}],
           ["rect", min(xp, xa), y1 - 0.3, max(xp, xa), y1, {"style": "pale"}]]
    d = (xa - xp) * 0.6
    out.append(["line", xp, round(y1 - 0.3 - abs(d), 2), round(xp + d, 2), y1 - 0.3, {"style": "line"}])
    return out


# The great furnace of 6.2: four tiers stepping back, and the three carved bands on them.
_FURNACE = [[-277.2, 478.6, -268.0, 490.0], [-276.6, 490.0, -268.4, 493.6], [-276.0, 493.6, -268.8, 496.1], [-275.4, 496.1, -269.6, 499.2]]
_BANDS = [[-277.2, 489.85, -268.0, 490.15], [-276.6, 493.45, -268.4, 493.75], [-276.0, 495.95, -268.8, 496.25]]


def _furnace(x_lo=-400.0, y_lo=0.0, y_hi=999.0):
    out = []
    for x0, y0, x1, y1 in _FURNACE:
        if y1 > y_lo and y0 < y_hi:
            out.append(["rect", max(x0, x_lo), max(y0, y_lo), x1, min(y1, y_hi), {"style": "pale"}])
    for x0, y0, x1, y1 in _BANDS:
        if y0 > y_lo and y1 < y_hi:
            out.append(["rect", max(x0, x_lo), y0, x1, y1, {"style": "solid"}])
    out.append(["poly", [[-268.8, 495.4], [-266.9, 495.4], [-268.8, 493.8]], {"style": "pale"}])   # the charging step's corbel
    return out


# The great iron mask of 6.1, redrawn so that what you hold belongs to it.
_MASK_FACE = [
    ["poly", [[-285.3, 494.9], [-283.9, 495.2], [-285.5, 492.7]], {"style": "solid"}],     # two small folded ears
    ["poly", [[-277.7, 494.9], [-279.1, 495.2], [-277.5, 492.7]], {"style": "solid"}],
    ["rect", -282.6, 494.0, -280.4, 494.15, {"style": "solid"}], ["rect", -282.3, 493.55, -280.7, 493.7, {"style": "solid"}],   # brow wrinkles
    ["circle", -283.5, 492.7, 0.7, {"style": "dark"}], ["circle", -279.5, 492.7, 0.7, {"style": "dark"}],
    ["poly", [[-282.2, 492.5], [-280.8, 492.5], [-281.5, 491.95]], {"style": "dark"}],
    ["poly", [[-283.6, 487.3], [-279.4, 487.3], [-279.9, 488.7], [-283.1, 488.7]], {"style": "dark"}],
    ["poly", [[-280.9, 487.5], [-279.6, 487.5], [-278.3, 486.0], [-280.3, 486.0]], {"style": "solid"}],     # the root of the tongue
]
_MASK = [["poly", [[-285.1, 487.2], [-285.5, 490.4], [-285.1, 493.6], [-283.7, 495.2], [-279.3, 495.2], [-277.9, 493.6], [-277.5, 490.4],
                   [-277.9, 487.2], [-279.6, 484.2], [-283.4, 484.2]], {"style": "pale"}]] + _MASK_FACE
_MASK_EAST = [["poly", [[-285.0, 487.0], [-285.0, 493.8], [-283.7, 495.2], [-279.3, 495.2], [-277.9, 493.6], [-277.5, 490.4],
                        [-277.9, 487.2], [-279.6, 484.2], [-283.4, 484.2]], {"style": "pale"}]] + _MASK_FACE[1:]

_KERB_TEXT = "A low lip of soot-black blocks along the very bottom of the frame, below the floor. The same kerb runs the whole length of the forge floor. It covers nothing you can stand on."


# ------------------------------------------------------------------ 6.0 the smith's hut
_HUT = {
    "id": "6.0", "slug": "6_0_the_smiths_hut", "title": "The smith's hut", "kind": "rest",
    "window": [-253.5, 475.5, -231.5, 488.5], "screen": [-243.0, 481.6], "cut_y": 480.2, "climber": [-242.6, 478.9],
    "place": ("The east end of the forge floor, at the very bottom of the chimney. Every fall in the chimney ends on this floor, and the "
              "floor slopes this way, so this corner is where you pick yourself up. Today it is bare: one small anvil, one frozen climber "
              "sitting on nothing, a torch on the wall. After note 59 it is the smith's hut. The last smith built a lean-to against the "
              "flue's east wall, out of the forge's own black stone and iron sheet, round his anvil and a small hearth. Only the frog "
              "lives in it now, and it has taken over the anvil. The frozen climber in his dog mask stays where the course has him, and the "
              "hut is built round him: he looks as if he came in to have a ring mended and sat down to wait. The hut "
              "is cut away at the front: floor, back wall and roof, no front wall, and you walk in along the floor. "
              "The light: this is the bottom of the journey. It is furnace red, low along the floor, from two banked furnace mouths in "
              "the back wall, with black shadow above. The hut's coals and its lamp are the one small warm spot in it."),
    "keep": [
        "The floor, its slope, and the slick east wall, exactly as they are.",
        "The frozen climber, sitting exactly where he sits today, facing the well.",
        "The walk back west along the floor to the first challenge stays clear. The hut is scenery, behind the play plane: nothing of it can be stood on or held.",
        "A falling climber is not caught by the hut: its roof is behind the play plane.",
    ],
    "background": [
        {"name": "The forge's back wall, with two banked furnace mouths", "z": [-4.6, -3.4], "tag": [-248.4, 486.6],
         "text": "Soot-black temple blocks in bays 4 m wide, with the temple's carved band worn nearly flat. This wall is the foot of the stepped pier that carries the three anvils of La Fragua, 44 m overhead. Two furnace mouths are banked low in it, each under a ribbed hood. Their red glow along the floor is the light of this place.",
         "draw": [["rect", -253.5, 476.5, -236.0, 488.5], ["rect", -253.5, 484.3, -236.0, 484.9, {"style": "pale"}],
                  _arch(-252.3, 478.45, -249.7, 481.6), _arch(-247.6, 478.65, -245.0, 481.8),
                  ["circle", -251.0, 479.3, 0.32, {"style": "light"}], ["circle", -246.3, 479.5, 0.32, {"style": "light"}],
                  ["poly", [[-252.8, 482.0], [-249.2, 482.0], [-249.9, 483.1], [-252.1, 483.1]], {"style": "pale"}],
                  ["poly", [[-248.1, 482.2], [-244.5, 482.2], [-245.2, 483.3], [-247.4, 483.3]], {"style": "pale"}]]},
        {"name": "The hut's back wall", "z": [-2.6, -2.3], "style": "pale", "tag": [-240.4, 481.5],
         "text": "Soot-black temple blocks, 4 m wide and 3 m tall, the same blocks as the forge wall. The hut is black stone and iron sheet, with no timber in it (Parker, 11-13). A rack of tongs hangs on it, and three wall rings on pegs, finished and half finished: the same rings you hold in Tiro de Chimenea, made here. They are black, not rust orange, and out of reach.",
         "draw": [["rect", -241.0, 478.97, -237.0, 482.0], ["rect", -240.8, 480.95, -239.4, 481.1, {"style": "solid"}],
                  ["rect", -240.6, 480.4, -240.5, 480.95, {"style": "solid"}], ["rect", -240.15, 480.4, -240.05, 480.95, {"style": "solid"}],
                  ["rect", -239.7, 480.4, -239.6, 480.95, {"style": "solid"}],
                  ["circle", -238.5, 481.3, 0.22, {"style": "solid"}], ["circle", -237.9, 481.3, 0.22, {"style": "solid"}],
                  ["circle", -237.4, 481.3, 0.22, {"style": "solid"}]]},
        {"name": "The roof and its two back posts", "z": [-2.6, -1.2], "style": "pale", "tag": [-239.2, 483.4],
         "text": "A lean-to of riveted iron sheet, sloping down from the east wall, on two iron posts. The hut is cut along the line just behind the climber. The roof stops 1.2 m behind the play plane, so somebody who falls here passes in front of it and lands on the floor.",
         "draw": [["poly", [[-241.6, 481.9], [-236.0, 482.75], [-236.0, 483.0], [-241.6, 482.15]]],
                  ["rect", -241.08, 478.97, -240.92, 481.95], ["rect", -237.08, 479.15, -236.92, 482.6]]},
        {"name": "The hearth", "z": [-2.4, -1.3], "tag": [-235.3, 480.6],
         "text": "A block of temple stone against the east wall with a bed of coals on it, a small iron hood over it, and a ribbed pipe that goes up the wall and out of sight. The coals are orange. With the lamp they are the only light on the floor that is not red.",
         "draw": [["rect", -237.0, 479.15, -236.0, 480.2, {"style": "pale"}], ["circle", -236.5, 480.32, 0.2, {"style": "light"}],
                  ["poly", [[-237.15, 481.0], [-236.0, 481.0], [-236.0, 481.5], [-236.8, 481.5]], {"style": "pale"}]] +
                 _pipe(-236.55, 483.0, -236.05, 488.5)},
        {"name": "The little bellows", "z": [-2.2, -1.5], "style": "pale", "tag": [-237.7, 480.5],
         "text": "Beside the hearth, on a stand: two boards, leather pleats and a nozzle, worked by a foot treadle and a rod. It is the great bellows of El Fuelle made small, and like every machine in the forge it shows what works it.",
         "draw": [["poly", [[-237.1, 479.6], [-238.1, 479.45], [-238.1, 480.1]]], ["line", -238.1, 479.5, -238.45, 479.2]]},
        {"name": "The small anvil", "z": [-1.9, -1.3], "style": "pale", "tag": [-240.9, 480.4],
         "text": "The anvil that stands here today, moved 0.6 m further back so that you walk in front of it. It stands on a stone footing with the iron pug's face on it, as every machine in the forge does. A wall ring lies on it, bent open: the job the frozen climber is waiting for.",
         "draw": [["rect", -240.3, 479.02, -239.7, 479.5], ["rect", -240.6, 479.5, -239.4, 479.92],
                  ["poly", [[-240.6, 479.92], [-241.05, 479.8], [-240.6, 479.6]]]]},
        {"name": "The frog", "z": [-1.8, -1.4], "style": "light", "tag": [-239.6, 480.6],
         "text": "0.3 m tall, sitting on the heel of the anvil in a leather apron, with a tiny hammer. It taps the anvil now and then and looks up when you come in (notes 59 and 60). It is friendly and nothing more.",
         "draw": [["circle", -239.75, 480.08, 0.16]]},
        {"name": "The lamp", "z": [-2.3, -2.1], "style": "light", "tag": [-239.0, 482.4],
         "text": "The torch that is on the east wall today, 5 m up, comes down under the roof and becomes the hut's lamp, on a bracket on the back wall. It is the last torch on the climb. There are none above the forge floor.",
         "draw": [["circle", -239.2, 481.6, 0.18]]},
        {"name": "Quenching trough and coal heap", "z": [-2.4, -1.4], "tag": [-243.3, 480.0],
         "text": "Outside the hut's west post: a stone trough of black water with a pair of tongs left in it. Further along, between the two furnace mouths, a heap of coal.",
         "draw": [["rect", -244.0, 478.82, -242.5, 479.4, {"style": "pale"}],
                  ["poly", [[-249.5, 478.57], [-247.8, 478.65], [-248.3, 479.4], [-249.0, 479.5]], {"style": "dark"}]]},
    ],
    "play": [
        {"name": "The frozen climber's seat", "top": True, "z": [-0.3, 0.3], "style": "pale", "tag": [-238.6, 477.9],
         "text": "He sits where the course has him, in his dog mask, facing the well. Today he sits on nothing. He gets an upturned iron bucket under him, 0.7 m wide and 0.42 m tall. It is in the play space, so it can be held and stood on like any sound iron, and its rim is rust orange. He does not live here: only the frog does (Parker, 11-13).",
         "draw": [["rect", -238.95, 479.08, -238.25, 479.5]]},
        {"name": "The swept floor", "z": [-1.2, 1.2], "style": "mark", "tag": [-241.8, 479.6],
         "text": "The forge's floor of temple slabs carries on into the hut. Inside it is swept paler, with a ring of scale and soot round the anvil. It is drawn onto the floor that is there: nothing is added to stand on.",
         "draw": [["line", -241.0, 479.02, -237.0, 479.2]]},
    ],
    "foreground": [
        {"name": "The hut's front sill", "top": True, "z": [1.2, 1.45], "tag": [-239.0, 478.45],
         "text": "A low sill of iron plate on the floor's front edge, with the stumps of the two front posts cut off level with the floor. It shows that the front of the hut was taken away. It sits below the top of the floor and covers nothing.",
         "draw": [["rect", -241.1, 478.2, -236.9, 478.7]]},
        {"name": "The floor's kerb", "top": True, "z": [1.3, 2.0], "style": "dark", "tag": [-247.0, 476.0],
         "text": _KERB_TEXT,
         "draw": [["poly", [[-253.5, 475.5], [-253.5, 476.3], [-248.0, 476.5], [-242.0, 476.3], [-236.5, 476.5], [-236.5, 475.5]]]]},
    ],
    "explains": [
        ["The forge floor", "Temple slabs, soot-black: the floor every fall in the chimney ends on", "The same slabs carrying on back into the hut, and to the furnace mouths in the wall"],
        ["The frozen climber", "One who tried, waiting in the smith's hut for a mended ring", "The hut built round him: the anvil with his ring on it, the lamp, the frog"],
        ["The east wall", "The flue's own rock, wet with soot", "The hearth built against it, and the hearth's pipe going up it"],
    ],
    "pieces": [
        ["The smith's hut: back wall, lean-to roof, two back posts", "4 m wide, 3 m tall, 1.4 m deep", "1", "Background", "kit: the smith's hut"],
        ["Front sill with two post stumps", "4.2 m by 0.5 m", "1", "Foreground", "new, this area only"],
        ["Hearth with a hood and a pipe", "1 m wide, 1.2 m tall; pipe 0.5 m across", "1", "Background", "new; the pipe is kit: vent_pipe"],
        ["Little bellows on a stand, with a treadle", "1 m", "1", "Background", "new, this area only"],
        ["Small anvil on a pug footing", "1.2 m by 0.9 m", "1", "Background", "kit: anvil, pug_mask_iron"],
        ["The frog, with an apron and a hammer", "0.3 m", "1", "Background", "kit: the frog"],
        ["Lamp on a bracket", "0.8 m", "1", "Background", "kit: torch_wall"],
        ["Tongs rack; wall rings on pegs", "2 m; 0.5 m", "1; 3", "Background", "kit: tongs_rack, wall ring on a pin"],
        ["Quenching trough; coal heap", "1.5 m; 1.9 m", "1; 1", "Background", "kit: quenching trough, coal heap"],
        ["Upturned bucket for a seat; bent ring on the anvil", "0.7 m by 0.42 m; 0.5 m", "1; 1", "Play space; background", "new, small; the bucket is a course change"],
        ["Forge wall bay with a furnace mouth and a hood", "4 m by 5 m", "4 bays, 2 with mouths", "Background", "kit: forge wall bay, forge_hood_ribs"],
        ["Floor kerb", "0.9 m tall", "17 m", "Foreground", "kit: floor kerb (added below)"],
    ],
    "effects": [
        "The red in the two furnace mouths swells and sinks slowly, like breathing.",
        "A thread of smoke from the hearth's pipe, and a spark each time the frog taps the anvil.",
        "The frog croaks when you are within a screen of it (note 60).",
        "Look straight up from here and the slit of sky is a pale thread, 100 m overhead.",
    ],
    "notes": [
        "Note 59 (not built yet): the smith's hut at the anvil corner. This is the corner in the note's picture.",
        "Parker, 11-13: only the frog lives in the hut. There is no real dog. The frozen climber in his dog mask stays where the course has him.",
        "Parker, 11-13: the hut is black stone and iron sheet, with no timber.",
        "Parker, 11-13: no torches above the forge floor. The hut's lamp is the last one on the climb.",
        "Note 60: this is the chimney's frog.",
        "Course change, something you touch is added: an upturned iron bucket, 0.7 m wide and 0.42 m tall, on the floor under the frozen climber at x -238.6. It is in the play space, so it can be held and stood on.",
        "Scenery moved out of the play space: the small anvil goes 0.6 m further back, and the east wall's torch comes down and back to be the hut's lamp. Neither is something you touch.",
    ],
}

# ------------------------------------------------------------------ 6.1 Primer Vapor
_PRIMER = {
    "id": "6.1", "slug": "6_1_primer_vapor", "title": "Primer Vapor", "kind": "challenge", "also": ["a5"],
    "window": [-299.0, 474.5, -271.0, 497.5], "screen": [-281.5, 485.5], "cut_y": 486.2, "climber": [-287.8, 479.78],
    "place": ("The forge's door and its first breath. The temple's smiths found a vent here, in the floor at the foot of the flue, "
              "where the mountain blows steam every few seconds, and they built their forge round it. They put a grate over the vent "
              "and cast a face for it: an iron pug as tall as a house, fixed to the back wall, breathing the vent's steam. The ring in "
              "its nose, the chain on the ring and the tongue hanging out of its mouth are what you hold. "
              "The light: you come in from the temple's torch gold. One last torch burns at the door. Two steps on, the light is furnace "
              "red and comes from below, up through the grating, and from the great furnace to the east. This is the red end of the journey."),
    "keep": [
        "The grate and its vent, the ring, the chain and the iron ledge, each exactly where it is.",
        "Note 63: the vent is about 10% stronger. Nothing in the design depends on how high it throws.",
        "Nothing stands in front of the vent.",
    ],
    "background": [
        {"name": "The forge's back wall", "z": [-4.6, -3.6], "tag": [-288.2, 494.0],
         "text": "The same wall as the temple across the well: big fitted blocks, a sloped base, the carved band at the temple's own heights. Here it is black with soot and the carving is worn nearly away. It fills the frame from the door to the great furnace.",
         "draw": [["rect", -291.0, 476.5, -271.0, 497.5], ["rect", -291.0, 484.0, -285.7, 484.6, {"style": "pale"}],
                  ["rect", -291.0, 490.0, -285.7, 490.6, {"style": "pale"}]]},
        {"name": "The door, a small pug over it, and the last torch", "z": [-2.2, -1.3], "tag": [-288.6, 488.4],
         "text": "The stepped arch you came through, seen from inside, with a small iron pug mask over it. One torch burns beside it. It is the last of the temple's torches: east of it the light is red and comes from below.",
         "draw": [["rect", -291.0, 487.2, -289.8, 488.0, {"style": "pale"}], ["rect", -291.0, 488.0, -289.2, 488.8, {"style": "pale"}],
                  ["circle", -290.0, 489.7, 0.75, {"style": "line"}], ["circle", -290.4, 486.4, 0.2, {"style": "light"}]]},
        {"name": "The great iron mask", "z": [-1.9, -1.3], "tag": [-284.2, 490.4],
         "text": "An iron pug's face 8 m wide and 11 m tall, cast in plates and riveted, fixed to a pier of the back wall with its chin 5 m above the floor. It is the forge's own copy of the temple's great mask. By Parker's leave to arrange things (11-13) it is remade taller, so that what you hold belongs to it: the ring is in its nose, the chain hangs from the ring down over its mouth, and its tongue lolls out of the east corner of its mouth and flattens into the plate you land on. It is black iron, set back, and it can't be mistaken for a wall to climb.",
         "draw": _MASK},
        {"name": "The breath pipe", "top": True, "z": [-2.4, -1.3], "tag": [-282.8, 482.0],
         "text": "A fat ribbed pipe comes up out of the floor behind the grate and goes into the mask's chin. The grate is the open end of the same steam, so when the vent blows the mask breathes out through its nostrils and its mouth as well. Wisps come from the nostrils first, then the blast.",
         "draw": _pipe(-281.8, 479.4, -281.2, 484.2)},
        {"name": "The strip of grating, with the fire under it", "z": [-2.4, -1.2], "style": "light", "over": True, "tag": [-279.0, 478.5],
         "text": "The grate you stand on is the front bay of a strip of grating that runs back across the floor to the foot of the pipe. Red light comes up through all of it. This is where the red light from below takes over from the torches.",
         "draw": [["rect", -282.6, 479.05, -280.4, 479.3]]},
        {"name": "Anvil, tongs rack and quenching trough by the door", "z": [-2.4, -1.3], "style": "pale", "tag": [-288.6, 483.0],
         "text": "The work place nearest the door: the small anvil that stands here today, a rack of tongs on the wall over it, and a stone trough. The rack hangs 3 m up the west wall today. It comes down to where a smith could reach it.",
         "draw": [["rect", -286.8, 479.69, -286.2, 480.15], ["rect", -287.1, 480.15, -285.9, 480.55],
                  ["rect", -289.7, 481.9, -287.7, 482.1], ["rect", -289.4, 481.2, -289.3, 481.9], ["rect", -288.9, 481.2, -288.8, 481.9],
                  ["rect", -288.4, 481.2, -288.3, 481.9], ["rect", -289.6, 479.87, -287.9, 480.4]]},
        {"name": "The great furnace's corner", "z": [-3.2, -1.3], "tag": [-273.6, 488.4],
         "text": "The west corner of the furnace of Piedra Caliente, 1 m east of the tongue's tip. Its fire is the red on the right side of everything here.",
         "draw": _furnace(y_hi=497.5)},
    ],
    "play": [
        {"name": "The landing slab", "z": [-1.2, 1.2], "style": "mark", "tag": [-293.2, 480.7],
         "text": "The ledge the censer drops you on is temple stone, soot-black on its face and worn pale on top, where it can be held. Its edge carries the temple's carved band one last time.",
         "draw": [["line", -295.4, 479.95, -291.0, 479.95]]},
        {"name": "The grate's rim", "top": True, "z": [-0.75, 0.75], "style": "pale", "tag": [-284.0, 480.1],
         "text": "The kit's steam grate: square iron bars in a raised rim, rust orange where feet have worn it. Every vent on the climb wears this same grate, so after this one you know what a grate does. The rim is drawn onto the grate that is there: where you stand does not change.",
         "draw": [["rect", -283.1, 479.5, -279.9, 479.62]]},
        {"name": "The tongue's rolled tip", "z": [-0.6, 0.6], "style": "pale", "tag": [-275.7, 486.5],
         "text": "The plate you land on is the mask's tongue: riveted iron, rust orange on top, curled under at its east tip. The curl stays inside the ledge's own outline, and it points at the furnace, where the climb goes next.",
         "draw": [["circle", -276.4, 485.75, 0.26]]},
    ],
    "foreground": [
        {"name": "The floor's kerb", "top": True, "z": [1.3, 2.0], "style": "dark", "tag": [-281.0, 475.2],
         "text": _KERB_TEXT,
         "draw": [["poly", [[-291.0, 474.5], [-291.0, 475.9], [-285.0, 476.1], [-279.0, 475.8], [-271.0, 475.6], [-271.0, 474.5]]]]},
    ],
    "explains": [
        ["The landing ledge", "The forge's doorstep: temple stone, sooted", "The stepped arch of the door, with the last torch and a small iron pug over it"],
        ["The grate", "The front bay of a strip of grating in the forge floor", "The rest of the strip, the red light under it, and the pipe that takes the same steam up into the mask"],
        ["The blast", "The mask breathing out", "The mask's nostrils and mouth, which smoke first and blow at the same moment"],
        ["The ring and the chain", "The pug's nose ring", "The mask's nose"],
        ["The iron ledge", "The pug's tongue, lolling out of the corner of its mouth", "The mask's mouth and the root of the tongue"],
        ["The floor", "Temple slabs", "The back wall's sloped base; the anvil, the trough and the tongs"],
    ],
    "pieces": [
        ["Forge wall bay, plain", "4 m by 5 m", "5 bays, 4 courses", "Background", "kit: forge wall bay"],
        ["The great iron mask, remade taller, with a tongue root and a nose that takes the ring", "8 m wide, 11 m tall", "1", "Background", "kit: pug_mask_iron, remade taller (Parker, 11-13)"],
        ["Breath pipe", "0.6 m across, 4.8 m", "1", "Background", "kit: vent_pipe"],
        ["Strip of grating", "2.2 m wide, 1.2 m deep", "1", "Background", "kit: steam_grate"],
        ["Steam grate with a rim", "3 m", "1", "Play space", "kit: steam_grate"],
        ["Tongue plate with a rolled tip", "3.9 m by 0.5 m", "1", "Play space", "new: the near end of the mask"],
        ["Door lintel blocks; small iron pug mask; torch", "2 m; 1.5 m; 0.8 m", "1 each", "Background", "kit: forge wall bay, pug_mask_iron, torch_wall"],
        ["Small anvil; tongs rack; quenching trough", "1.2 m; 2 m; 1.7 m", "1 each", "Background", "kit: anvil, tongs_rack, quenching trough"],
        ["Floor kerb", "0.9 m tall", "20 m", "Foreground", "kit: floor kerb (added below)"],
    ],
    "effects": [
        "Wisps from the mask's nostrils and a brighter red in the grate's bars for the 1.2 s before each blast, with the gurgle.",
        "The torch's flame leans into the hall: the forge draws air in through the door.",
        "Embers rising slowly through the whole frame.",
    ],
    "notes": [
        "Note 63 (not built yet): this vent is about 10% stronger.",
        "Parker, 11-13: the great iron mask is remade taller, 8 m by 11 m, so that its nose takes the ring and its mouth is over the iron ledge. Nothing you touch moves: the ring, the chain and the ledge stay where the course has them.",
        "Scenery moved out of the play space: the mask, the small anvil, the tongs rack and the door's torch each reach into the play space today. All four now stand at least 1.3 m behind you.",
        "Nothing you touch moves or is added.",
    ],
}

# ------------------------------------------------------------------ 6.2 Piedra Caliente
_HOT = [(-276.2, 487.5, "hot"), (-275.3, 488.3, "hot"), (-275.6, 489.4, "hot"), (-274.6, 490.0, "rock"),
        (-273.7, 490.8, "hot"), (-274.0, 491.9, "hot"), (-273.0, 492.5, "hot"), (-272.9, 493.6, "rock"),
        (-273.7, 494.4, "hot"), (-272.8, 495.0, "hot"), (-273.0, 496.1, "rock"), (-272.2, 496.9, "hot")]
_crack = [["line", _HOT[i][0], _HOT[i][1], _HOT[i + 1][0], _HOT[i + 1][1]] for i in range(len(_HOT) - 1)]

_PIEDRA = {
    "id": "6.2", "slug": "6_2_piedra_caliente", "title": "Piedra Caliente", "kind": "challenge",
    "window": [-285.0, 476.5, -262.0, 501.0], "screen": [-274.0, 491.5], "cut_y": 490.0, "climber": [-278.5, 486.0],
    "place": ("The forge's great furnace. It is a tower of soot-black temple blocks standing on the floor, 9 m wide, stepping back "
              "three times as it rises, the way every temple wall does. It has burned for so long that its face has cracked, and the "
              "climb goes up the crack. The hot holds are the ends of through stones: long blocks laid right through the wall with "
              "their far ends in the fire. The three cool holds are on the furnace's three carved bands, which stand clear of the "
              "fire. The ledge at the top is its charging step. "
              "The light: the deepest red on the climb. It comes from the furnace's mouth, straight below you, and from the hot stones "
              "themselves. Everything above the top band is black."),
    "keep": [
        "The twelve holds, each exactly where it is: nine hot, three cool.",
        "Note 56, already built: the face is burnt black along the line of the holds, and the hot holds pulse, steam and show their time running out.",
        "Nothing under the climb but the floor.",
    ],
    "background": [
        {"name": "The forge's back wall", "z": [-4.6, -3.6], "tag": [-264.2, 488.6],
         "text": "Black temple blocks with the worn band, running on behind the furnace on both sides.",
         "draw": [["rect", -285.0, 477.0, -262.0, 501.0], ["rect", -268.0, 484.0, -262.0, 484.6, {"style": "pale"}]]},
        {"name": "The iron mask's cheek", "z": [-1.9, -1.3], "tag": [-281.6, 490.3],
         "text": "From Primer Vapor: the east side of the great mask. The iron ledge you start on is its tongue.",
         "draw": _MASK_EAST},
        {"name": "The great furnace", "z": [-3.2, -1.3], "tag": [-269.6, 487.6],
         "text": "Four tiers of temple blocks, 9.2 m wide at the foot and 20 m tall. A carved band runs round the top of each of the first three tiers, 490.0, 493.6 and 496.1 m up. The iron tongue you start on stops 1 m short of its west corner. The ledge at the top is its charging step, carried on a stone corbel, and its crown is open and glowing.",
         "draw": _furnace() + [["circle", -272.5, 499.3, 0.3, {"style": "light"}]]},
        {"name": "The furnace mouth and its hood", "top": True, "z": [-2.6, -1.3], "tag": [-276.5, 482.4],
         "text": "Low in the furnace's face, straight below the climb: a stepped arch 3 m wide with the fire in it, under a ribbed iron hood. This is the light of the challenge. It is deep red and it comes from below, so the undersides of the holds are lit.",
         "draw": [_arch(-275.6, 478.7, -272.4, 482.6), ["circle", -274.0, 479.6, 0.45, {"style": "light"}],
                  ["poly", [[-276.2, 483.0], [-271.8, 483.0], [-272.6, 484.5], [-275.4, 484.5]], {"style": "solid"}]]},
        {"name": "The crack", "z": [-1.4, -1.3], "style": "mark", "tag": [-276.6, 491.6],
         "text": "A heat crack runs up the face along the line of the holds, and the stone is burnt black for a metre either side of it (note 56, built). The fire shows in the crack as a thin red line.",
         "draw": _crack},
        {"name": "The air pipe", "z": [-3.0, -2.0], "tag": [-275.8, 500.3],
         "text": "A ribbed pipe comes out of the wall above the furnace and down into its crown. It carries the air from the three small bellows of El Fuelle, 13 m overhead. The furnace is what all the bellows are for.",
         "draw": _pipe(-274.8, 499.2, -274.2, 501.0, step=1.0)},
        {"name": "Coal heap and rake", "z": [-2.6, -1.5], "tag": [-270.2, 480.4],
         "text": "On the floor by the mouth: a heap of coal, and a long iron rake leaning on the furnace.",
         "draw": [["poly", [[-272.0, 478.7], [-269.6, 478.55], [-270.2, 479.5], [-271.2, 479.7]], {"style": "dark"}],
                  ["rect", -269.3, 478.6, -269.18, 481.0, {"style": "solid"}]]},
    ],
    "play": [
        {"name": "The three cool bosses", "z": [-0.3, 0.3], "style": "line", "tag": [-275.6, 490.6],
         "text": "Each cool hold sits exactly on one of the furnace's three carved bands. It is the one boss of the band's carving that has not worn away: a small pug's head in grey stone, plainly cold, with a wisp of steam where damp runs along the band onto it.",
         "draw": [["circle", -274.6, 490.0, 0.5], ["circle", -272.9, 493.6, 0.5], ["circle", -273.0, 496.1, 0.5]]},
        {"name": "The nine hot stones", "z": [-0.3, 0.3], "style": "mark", "tag": [-271.9, 492.3],
         "text": "Each hot hold is the square end of a through stone, and it glows, pulses and steams as the game shows it today. The joint round it glows too, so you can see it is a different stone from the wall.",
         "draw": [["rect", x - 0.36, y - 0.36, x + 0.36, y + 0.36] for x, y, k in _HOT if k == "hot"]},
        {"name": "The charging step", "z": [-1.2, 1.2], "style": "mark", "tag": [-267.6, 497.0],
         "text": "The ledge at the top is a slab of temple stone with a worn carved edge. The grate of the next challenge is set in it.",
         "draw": [["line", -271.4, 495.95, -266.9, 495.95]]},
    ],
    "foreground": [
        {"name": "The floor's kerb", "top": True, "z": [1.3, 2.0], "style": "dark", "tag": [-272.0, 476.9],
         "text": _KERB_TEXT,
         "draw": [["poly", [[-285.0, 476.5], [-285.0, 477.1], [-278.0, 477.3], [-270.0, 477.0], [-262.0, 477.1], [-262.0, 476.5]]]]},
    ],
    "explains": [
        ["The nine hot holds", "The ends of through stones: blocks that go right through the furnace wall into the fire", "The furnace, and the fire seen in the mouth below and in the crack"],
        ["The three cool holds", "The last unworn pug's head on each of the furnace's three carved bands", "The band running round the furnace at that height"],
        ["The burnt strip", "Stone scorched black round a heat crack", "The crack's red line, and the unburnt blocks either side"],
        ["The ledge at the top", "The furnace's charging step", "The corbel under it, and the furnace's open crown glowing behind it"],
        ["The iron ledge you leave from", "The iron mask's tongue", "The mask's cheek, at the left of the frame"],
    ],
    "pieces": [
        ["Furnace tower in four stepped tiers", "9.2 m wide at the foot, 20.6 m tall", "1", "Background", "new, from the forge wall bay's blocks"],
        ["Carved band, worn, with one whole pug boss", "0.3 m tall, to suit", "3", "Background; the boss is the play space", "new: the temple's frieze strip, worn"],
        ["Furnace mouth: a stepped arch with fire in it", "3.2 m wide, 3.9 m tall", "1", "Background", "kit: forge wall bay's furnace mouth"],
        ["Forge hood with ribs", "4.4 m", "1", "Background", "kit: forge_hood_ribs"],
        ["Through-stone end with a glowing joint", "0.45 m square", "9", "Play space", "kit: hot rock face"],
        ["Air pipe", "0.6 m across", "1", "Background", "kit: vent_pipe"],
        ["Corbel", "1.9 m by 1.6 m", "1", "Background", "new, small"],
        ["Coal heap; rake", "2.4 m; 2.4 m", "1; 1", "Background", "kit: coal heap; the rake is new, small"],
        ["Forge wall bay, plain", "4 m by 5 m", "6 bays, 5 courses", "Background", "kit: forge wall bay"],
        ["Floor kerb", "0.9 m tall", "23 m", "Foreground", "kit: floor kerb (added below)"],
    ],
    "effects": [
        "The fire in the mouth and the red line in the crack brighten and dim together, slowly.",
        "Heat shimmer over the whole face. Sparks drift up out of the crown.",
        "A wisp of steam at each cool boss.",
        "A few sparks drifting close to the camera.",
    ],
    "notes": [
        "Note 56 (built): hot holds glow and warn, and the face is burnt black behind them. The design keeps all of it and gives it a cause.",
        "Nothing you touch moves or is added. The furnace's face is 1.3 m behind you, and only the twelve holds stand out of it into the play space.",
    ],
}

# The three stepping bellows of 6.4 and what works them (6.3 sees the first two).
_SMALL = [(-270.0, 512.8), (-273.4, 514.8), (-276.8, 516.8)]      # the three stepping bellows: the top board's middle, folded
_CAMS, _pleats = [], []
for _bx, _by in _SMALL:
    _base = round(_by - 1.55, 2)
    _CAMS.append(["rect", _bx - 1.1, _base - 0.3, _bx + 1.1, _base, {"style": "pale"}])
    _CAMS += _wheel(_bx, round(_base - 1.45, 2), 1.0, n=4)
    _pleats += [["line", _bx - 0.9, _by - 0.75, _bx + 0.9, _by - 0.75], ["line", _bx - 0.9, _by - 1.15, _bx + 0.9, _by - 1.15]]
_CAMS += [["line", -269.5, 510.3, -276.3, 514.3, {"style": "line"}], ["line", -276.3, 514.3, -286.7, 509.6, {"style": "line"}]]

# ------------------------------------------------------------------ 6.3 Géiseres Gemelos
_JIB_L3 = _jib(-263.9, 512.0, 515.4, -261.7)
_DOOR_L3 = _door(-267.0, 512.0, -265.0, 515.0)

_GEMELOS = {
    "id": "6.3", "slug": "6_3_geiseres_gemelos", "title": "Géiseres Gemelos", "kind": "challenge",
    "window": [-276.0, 490.0, -252.0, 518.5], "screen": [-265.5, 503.5], "cut_y": 501.5, "climber": [-270.4, 496.0],
    "place": ("The quench pipe. The slag pan of Escoria hangs 26 m above this spot, and its waste runs off its east lip and falls. "
              "The smiths stood a great iron standpipe on the forge floor to catch it, with a hopper on top. The slag drops into the "
              "water in the pipe and the pipe blows steam: that is the second vent. A branch of the same pipe comes up through the "
              "furnace's charging step: that is the first. They are twins because they are one pipe with two mouths, and they take "
              "turns because the pressure can only be in one place at a time. Above them is the lip of the bellows loft, with the "
              "smiths' hoist standing on it. "
              "The light: red going to orange. It comes from the furnace's open crown, below and to the left, and from the falling "
              "slag, which is the first bright orange thing on the climb."),
    "keep": [
        "Both vents, the draught between them, the two slick plates, the chain and the top ledge, exactly as they are.",
        "Nothing to stand on at the second vent.",
        "Note 63: both vents are about 10% stronger. Nothing in the design depends on how high they throw.",
        "Nothing stands in front of either vent.",
    ],
    "background": [
        {"name": "The forge's back wall", "z": [-4.6, -3.6], "tag": [-255.0, 509.5],
         "text": "The forge's back wall goes on up, black, with one worn band. It is lit from the left and below.",
         "draw": [["rect", -276.0, 490.0, -252.0, 518.5], ["rect", -261.0, 505.0, -252.0, 505.6, {"style": "pale"}]]},
        {"name": "The furnace's crown", "z": [-3.2, -1.3], "tag": [-273.6, 497.6],
         "text": "The top of the furnace of Piedra Caliente. The ledge you stand on is its charging step. Its crown is open and glowing, and the air pipe from the bellows loft comes out of the wall and down into it.",
         "draw": _furnace(x_lo=-276.0, y_lo=490.0) + [["circle", -272.5, 499.3, 0.35, {"style": "light"}]] + _pipe(-274.8, 499.2, -274.2, 503.0, step=1.2) +
                 [["rect", -274.9, 503.0, -274.1, 503.5, {"style": "pale"}]]},
        {"name": "The quench pipe", "top": True, "z": [-3.0, -1.3], "tag": [-263.0, 492.6],
         "text": "A standpipe 2.2 m across that comes up from the forge floor, 21 m below, strapped to the wall. It stands here today as scenery. It stays, and it gets its straps and its reason.",
         "draw": _pipe(-264.1, 490.0, -261.9, 500.8, step=3.0) + [["rect", -264.4, 500.4, -261.6, 500.8, {"style": "pale"}]]},
        {"name": "The hopper's back half", "z": [-2.6, -1.2], "tag": [-262.7, 501.9],
         "text": "The two slick plates you can't stand on are the front edge of a round iron hopper on top of the pipe. Its back half stands behind, lopsided like the plates: short on the west, long on the east, to catch the falling slag. Inside it is black and glassy with splashed slag.",
         "draw": [["poly", [[-265.7, 502.06], [-258.8, 503.3], [-261.8, 500.8], [-264.2, 500.8]], {"style": "pale"}],
                  ["poly", [[-264.8, 501.85], [-260.2, 502.6], [-261.9, 501.0], [-264.1, 501.0]], {"style": "dark"}]]},
        {"name": "The branch pipe", "z": [-2.4, -1.3], "tag": [-266.0, 492.8],
         "text": "A thinner pipe leaves the standpipe and runs under the ledge to the first grate. The two vents are one pipe with two mouths, which is why they take turns.",
         "draw": _pipe(-268.3, 493.4, -264.1, 494.0, step=1.4) + [["rect", -268.3, 494.0, -267.7, 495.4, {"style": "pale"}]]},
        {"name": "The falling slag", "z": [-3.4, -3.0], "style": "mark", "tag": [-264.7, 516.8],
         "text": "Slag falls from the lip of the pan above into the hopper. Today it is drawn as one thin bright strip, 1.5 m from the chain you have to catch, and it could be taken for a second chain. It becomes separate bright drops, set well back. A bigger gob falls 1 s before the second vent blows: the warning you can see.",
         "draw": [["line", -263.6, 518.5, -263.6, 502.1]]},
        {"name": "The hoist", "top": True, "z": [-1.8, -1.3], "tag": [-262.7, 516.3],
         "text": "An iron post, arm and brace standing on the east end of the loft's lip: the smiths' hoist for lowering things to the hopper. The ring is the eye at the end of its arm and the chain is its chain. Today the ring hangs in the air.",
         "draw": _JIB_L3},
        {"name": "The stair door", "z": [-3.6, -3.2], "tag": [-266.0, 516.0],
         "text": "In the back wall behind the top ledge: a stepped arch shut with an iron grille. The smiths had a stair inside the wall. You can see how they came up, and you can't use it.",
         "draw": _DOOR_L3},
        {"name": "The stepping bellows' cam wheels", "z": [-2.4, -1.6], "tag": [-271.8, 508.4],
         "text": "From El Fuelle, at the top left: the first two of the three stepping bellows, each on its iron brackets with its cam wheel under it, and the coupling rod that joins the wheels. Today the bellows hang in the air.",
         "draw": _CAMS},
    ],
    "play": [
        {"name": "The first grate's rim", "z": [-0.75, 0.75], "style": "pale", "tag": [-268.0, 497.1],
         "text": "The same grate as the first one, set in the charging step.",
         "draw": [["rect", -269.05, 496.05, -266.95, 496.16]]},
        {"name": "The slick plates", "z": [-1.2, 1.2], "style": "mark", "tag": [-258.2, 503.9],
         "text": "The two plates are in the play space and can't be held, because the challenge needs nothing to stand on at the second vent. So they are made plainly dark and wet: black greased iron, with runs of glassy slag frozen down them. They are the darkest and shiniest things in the frame.",
         "draw": [["line", -264.3, 501.05, -265.75, 502.3], ["line", -261.7, 501.05, -258.75, 503.5]]},
        {"name": "The loft's lip", "z": [-1.2, 1.2], "style": "mark", "tag": [-266.9, 511.0],
         "text": "The ledge that ends the challenge is the lip of the bellows loft: a temple slab, sooted on its face and worn pale on top.",
         "draw": [["line", -267.5, 511.95, -263.6, 511.95]]},
    ],
    "foreground": [],
    "explains": [
        ["The first grate", "A branch of the quench pipe, coming up through the furnace's charging step", "The branch pipe under the ledge, joined to the standpipe"],
        ["The drift east", "Hot air off the furnace's crown, drawn towards the big pipe", "The crown glowing behind you, and the falling slag, which leans the same way"],
        ["The second vent", "The mouth of the quench pipe: slag drops in, steam blows out", "The standpipe, the hopper's back half, and the slag falling from the pan above"],
        ["The two slick plates", "The front edge of the hopper", "The rest of the hopper"],
        ["The chain and its ring", "The smiths' hoist", "The post, arm and brace standing on the loft's lip"],
        ["The ledge at the top", "The lip of the bellows loft", "The stair door in the wall behind it"],
    ],
    "pieces": [
        ["Standpipe with straps", "2.2 m across, 21 m", "1", "Background", "kit: vent_pipe (there today)"],
        ["Hopper, back half", "6.9 m across, 2.5 m tall", "1", "Background", "new, this area only"],
        ["Branch pipe with an elbow", "0.6 m across, 5.6 m", "1", "Background", "kit: vent_pipe"],
        ["Steam grate with a rim", "2 m", "1", "Play space", "kit: steam_grate"],
        ["Wall jib: post, arm, brace, hook ring", "post 3.4 m, arm 2.2 m", "1", "Background", "kit: wall jib (added below)"],
        ["Stair door with a grille", "2 m by 3 m", "1", "Background", "kit: stair door (added below)"],
        ["Furnace crown, charging step and air pipe", "as in Piedra Caliente", "1", "Background", "shared with 6.2"],
        ["Stepping bellows on brackets, cam wheels and coupling rod", "as in El Fuelle", "2 in the frame", "Background", "shared with 6.4"],
        ["Forge wall bay, plain", "4 m by 5 m", "6 bays, 6 courses", "Background", "kit: forge wall bay"],
    ],
    "effects": [
        "The falling slag: bright drops, with a bigger gob 1 s before the second vent blows.",
        "The hopper's rim glows for a moment where a drop lands.",
        "Steam from the first grate leans east as it rises, which shows the draught.",
    ],
    "notes": [
        "Note 63 (not built yet): both vents are about 10% stronger.",
        "Scenery moved out of the play space: the quench pipe is 2.2 m across and today its front is 0.3 m behind you. It moves back until its front is 1.3 m behind. The falling slag moves back to 3 m behind and becomes separate drops.",
        "The two slick plates stay in the play space and can't be held. They are plainly dark and wet.",
        "Nothing you touch moves or is added.",
    ],
}

# ------------------------------------------------------------------ 6.4 El Fuelle
_FUELLE = {
    "id": "6.4", "slug": "6_4_el_fuelle", "title": "El Fuelle", "kind": "challenge",
    "window": [-292.0, 506.5, -262.5, 527.5], "screen": [-277.0, 516.5], "cut_y": 515.0, "climber": [-266.2, 512.0],
    "place": ("The bellows loft, the upper half of the forge hall. The furnace below needs air, and this is where the air is made. "
              "The great bellows stands on a stone shelf on the west wall. Three small box bellows step up towards it on iron "
              "brackets, each one's pipe going back into the wall and down to the furnace. One steam wheel under the shelf works "
              "all of it: a crank and a rod open and shut the great bellows, and a long rod turns three cam wheels that push the "
              "small bellows up and let them down. You climb the small bellows as steps, into the great bellows' blast, onto its "
              "deck, and up four iron rungs in a stone pier to the slag pan's shore. One of the rungs is not a rung. "
              "The light: orange. It comes from above and to the right, off the slag pan, so the tops of the bellows are lit and the "
              "furnace's red is left on their undersides."),
    "keep": [
        "The three stepping bellows: where they are, how far their tops travel (1.8 m), and their timing.",
        "The gust: where it blows, how hard, and its 1.4 s on and 2.6 s off.",
        "The deck you land on does not move, so the last reach is unchanged.",
        "The four rungs' places. Note 58 makes the second from the top a stick of dynamite, the same size and in the same place.",
    ],
    "background": [
        {"name": "The loft's back wall", "z": [-4.5, -3.6], "tag": [-264.6, 519.0],
         "text": "The same black temple wall, here lit orange from above. It fills the frame.",
         "draw": [["rect", -291.0, 506.5, -262.5, 527.5]]},
        {"name": "The stone shelf", "top": True, "z": [-3.4, -1.3], "style": "pale", "tag": [-289.6, 511.7],
         "text": "A shelf of temple blocks built out from the west wall on stepped corbels. The great bellows stands on it. Today the bellows hangs on the wall with nothing under it.",
         "draw": [["poly", [[-291.0, 513.2], [-283.4, 513.2], [-283.4, 512.3], [-284.6, 512.3], [-284.6, 511.6], [-286.4, 511.6], [-286.4, 510.9], [-291.0, 510.9]]]]},
        {"name": "The great bellows", "z": [-3.4, -1.3], "tag": [-287.7, 516.9],
         "text": "Two boards, leather pleats and an iron nozzle box with the pug's face on it, 6 m long, hinged at the nozzle like a real bellows and opening at the west end. After note 57 it moves. Through the 2.6 s of quiet its top board lifts and the pleats spread, so you can read how long you have. Then a stone weight on the top board slams it shut over the 1.4 s of the gust, and the jet comes out of the nozzle along the line the wind blows. It is drawn open. The dashed line is the top board when shut. The deck you land on is a fixed timber deck on the bellows' iron frame, above the moving board.",
         "draw": [["rect", -290.7, 513.2, -284.3, 513.5, {"style": "pale"}],
                  ["poly", [[-284.4, 513.5], [-290.6, 513.5], [-290.6, 518.2], [-284.4, 514.1]], {"style": "dark"}],
                  ["line", -284.4, 513.8, -290.6, 514.6], ["line", -284.4, 513.85, -290.6, 515.5], ["line", -284.4, 513.9, -290.6, 516.4],
                  ["line", -284.4, 513.95, -290.6, 517.3],
                  ["poly", [[-284.4, 514.1], [-290.7, 518.2], [-290.7, 518.5], [-284.4, 514.4]], {"style": "pale"}],
                  ["line", -284.4, 514.1, -290.6, 514.9, {"style": "mark"}],
                  ["rect", -284.4, 513.3, -283.3, 514.8, {"style": "pale"}], ["circle", -283.85, 514.05, 0.38, {"style": "solid"}],
                  ["poly", [[-283.3, 513.65], [-282.5, 513.85], [-282.5, 514.25], [-283.3, 514.45]], {"style": "pale"}],
                  ["rect", -283.75, 514.8, -283.55, 518.9, {"style": "pale"}], ["line", -283.5, 513.3, -279.7, 518.9]]},
        {"name": "The steam wheel, its crank and its rod", "z": [-2.8, -1.6], "tag": [-285.3, 508.0],
         "text": "What works the great bellows. Under the shelf an iron paddle wheel 3 m across sits in stone cheeks. A pipe comes up the west wall and ends in a nozzle that kicks the wheel round with steam. A crank on the wheel's axle pulls a rod, and the rod goes up through the shelf to the free end of the bellows' top board. Wheel, crank and rod turn once for every gust.",
         "draw": _wheel(-287.6, 509.0, 1.5) + _pipe(-290.9, 506.5, -290.3, 508.2, step=1.0) +
                 [["poly", [[-290.3, 507.6], [-289.3, 507.9], [-290.3, 508.2]], {"style": "pale"}],
                  ["circle", -288.5, 509.5, 0.16, {"style": "pale"}], ["line", -288.5, 509.5, -290.3, 514.8]]},
        {"name": "The long rod and the three cam wheels", "z": [-2.4, -1.6], "tag": [-281.6, 511.2],
         "text": "What works the three stepping bellows. Each one sits on a pair of iron brackets from the wall, and under it turns an iron cam wheel 2 m across. As the wheel turns, its cam pushes the bellows' top board up 1.8 m and lets it down again. One coupling rod joins the three wheels, each a third of a turn behind the last, which is why the three bellows swell one after another. A long rod runs from the third wheel down to the steam wheel. One wheel works everything in the loft. Today the three bellows hang in the air.",
         "draw": _CAMS},
        {"name": "The rung pier", "top": True, "z": [-1.9, -1.3], "style": "pale", "tag": [-287.6, 521.6],
         "text": "A pier of temple blocks from the deck up to the iron shore. The rungs are iron staples driven into it. Today they hang in the air.",
         "draw": [["rect", -286.8, 519.5, -285.2, 524.6]]},
        {"name": "The shore's brackets", "z": [-3.0, -1.3], "style": "pale", "tag": [-282.6, 523.5],
         "text": "The iron shore at the top is the front edge of the slag pan's tapping floor: a riveted iron gallery on brackets, which carries on behind you to the smelter of Escoria.",
         "draw": [["poly", [[-285.0, 524.6], [-283.6, 524.6], [-285.0, 523.2]]], ["poly", [[-282.0, 524.6], [-280.4, 524.6], [-280.4, 523.0]]]]},
        {"name": "The open box of dynamite", "z": [-1.9, -1.4], "style": "pale", "tag": [-284.3, 520.6],
         "text": "A small open box on the deck behind the rungs, with the mine's skull pug stencilled on it and three more red sticks showing. It tells you what the red rung is before you touch it, and how it got here. Parker, 11-13: yes to the box.",
         "draw": [["rect", -284.6, 519.5, -284.0, 519.95]]},
        {"name": "The loft's lip, with the hoist and the stair door", "z": [-3.6, -1.3], "tag": [-264.4, 516.6],
         "text": "From Géiseres Gemelos: the ledge you start on is the lip of the loft, with the smiths' hoist on its east end and the grilled stair door in the wall behind it.",
         "draw": _JIB_L3 + _DOOR_L3},
    ],
    "play": [
        {"name": "Pleats on the three stepping bellows", "z": [-0.9, 0.9], "style": "mark", "tag": [-271.9, 512.0],
         "text": "Each stepping bellows is a small box bellows: a timber top board with a pug's face on its edge, and leather pleats under it that open as it swells and close as it folds (note 57). Its base stays still on its brackets. Only the top board and the pleats move, and the top board's travel is exactly today's. The pleated body is in the play space and can't be held, so it is plainly dark and wet: black greased leather, under a pale dry board that can.",
         "draw": _pleats},
        {"name": "The stick of dynamite", "z": [-0.4, 0.4], "style": "light", "tag": [-284.7, 523.4],
         "text": "Note 58. The second rung from the top is a stick of dynamite: a fat red stick with a fuse curling off its east end, lying in the two bent stubs of a rung that has snapped off. The pier behind it is scorched in a star from the last time.",
         "draw": [["rect", -286.4, 522.97, -285.6, 523.23], ["line", -285.6, 523.1, -285.25, 523.45, {"style": "line"}]]},
    ],
    "foreground": [],
    "explains": [
        ["The three stepping bellows", "The furnace's own small box bellows, on brackets from the loft wall", "A cam wheel under each, joined by one coupling rod"],
        ["The gust", "The great bellows slamming shut", "The bellows itself, opening slowly and shutting fast, and the jet from its nozzle"],
        ["The deck you land on", "A fixed timber deck on the great bellows' iron frame", "The bellows working under it, its frame and strut, and the stone shelf it stands on"],
        ["The rungs", "Iron staples in a stone pier", "The pier, from the deck up to the shore"],
        ["The dynamite rung", "A stick laid in the stubs of a snapped rung", "The scorched star on the pier, and the open box of dynamite on the deck"],
        ["The iron shore", "The front edge of the slag pan's tapping floor", "Its brackets, and the gallery carrying on back"],
        ["The ledge you start on", "The lip of the loft", "The hoist and the stair door"],
    ],
    "pieces": [
        ["The great bellows, cut into parts that move: lower board, top board, pleats, nozzle box, stone weight", "6.3 m long, opens to 4.7 m", "1", "Background", "kit: bellows_great, remade in parts (note 57)"],
        ["Bellows frame: posts, strut and fixed deck", "deck 8.8 m by 2.4 m", "1", "Background; the deck's front edge is the play space", "new"],
        ["Stone shelf on stepped corbels", "7.6 m wide, 2.3 m tall", "1", "Background", "new, from the forge wall bay's blocks"],
        ["Steam wheel with a crank", "3 m", "1", "Background", "kit: steam wheel (added below)"],
        ["Vent pipe with a nozzle", "0.6 m across", "1", "Background", "kit: vent_pipe"],
        ["Drive rods: crank rod, coupling rod, long rod", "5.6 m; 7.9 m; 11.4 m", "1 each", "Background", "kit: drive rod (added below)"],
        ["Cam wheel on wall brackets", "2 m", "3", "Background", "kit: steam wheel (added below), with a cam"],
        ["Stepping bellows: top board, pleats, base", "2.2 m wide, 1.55 m folded, 3.35 m open", "3", "Play space", "kit: bellows (there today), remade in parts (note 57)"],
        ["Rung pier", "1.6 m wide, 5.1 m tall", "1", "Background", "new, from the forge wall bay's blocks"],
        ["Iron staple rung", "0.8 m", "3", "Play space", "shapes today; a model is new"],
        ["Dynamite stick with a fuse, in two bent rung stubs", "0.8 m long", "1", "Play space", "kit: dynamite stick"],
        ["Open box of dynamite", "0.6 m", "1", "Background", "kit: open box of dynamite"],
        ["Shore bracket", "1.5 m", "2", "Background", "new, small"],
        ["Wall jib; stair door", "as in Géiseres Gemelos", "1; 1", "Background", "kit: wall jib, stair door (added below)"],
    ],
    "effects": [
        "The jet: steam and sparks out of the nozzle along the line the wind blows, for the 1.4 s of the gust.",
        "The pug on the nozzle box puffs its cheeks. Soot shakes off the frame. A creak on the draw and a thump on the blow.",
        "A puff at the steam wheel's nozzle each time it kicks the wheel.",
        "The fuse: a hiss and a bright spitting spark that runs along it.",
    ],
    "notes": [
        "Note 57 (not built yet): the great bellows moves like a bellows and shows what works it. The three stepping bellows open and close their pleats.",
        "Note 58 (not built yet): the second rung from the top is a stick of dynamite that lights and blows.",
        "Parker, 11-13: yes to the open box of dynamite behind the rungs. It is scenery, 1.4 m behind you.",
        "Course change, from note 58: one rung becomes the dynamite stick, the same size and in the same place. Nothing else you touch moves.",
        "Scenery moved out of the play space: the great bellows is 2.5 m deep and today its front stands in front of you. It moves back until its front is 1.3 m behind, under the fixed deck. Of the great bellows, only the deck's front edge and the jet are in the play space.",
        "The pleated bodies of the three stepping bellows stay in the play space and can't be held. They are plainly dark and wet.",
    ],
}

# ------------------------------------------------------------------ 6.5 Escoria
def _sy(x):
    """The slag's surface at x."""
    return round(524.6 - (x + 280.3) * 2.3 / 16.7, 2)


_ESCORIA = {
    "id": "6.5", "slug": "6_5_escoria", "title": "Escoria", "kind": "challenge",
    "window": [-287.0, 517.0, -254.0, 534.0], "screen": [-271.0, 525.0], "cut_y": 525.0, "climber": [-282.6, 525.2],
    "place": ("The slag pan. Above the loft the smiths smelted their iron in a round-bellied furnace on an iron tapping floor, and "
              "the waste, the slag, ran out of it down a long tilted iron pan to cool. The pan hangs from the hall's roof in two "
              "cradles. To keep the slag running they raked it: three iron rakes, their handles worked to and fro by three cranks on "
              "one steam wheel at the head of the pan, like oars. The rafts you ride are the heads of the rakes. At the pan's low end "
              "the slag runs off a lip and falls to the quench pipe, and the smiths' second hoist reaches over the lip. "
              "The light: bright orange, the brightest in the forge, and the slag itself is the lamp. It lights everything from "
              "underneath and throws the rakes' shadows up the wall. It is the last place where the light comes from under your feet."),
    "keep": [
        "The pan, its tilt, and the slag's throw, exactly as they are.",
        "The three rafts: their tracks, speeds and waits.",
        "The two dead crusts, the chain at the lip, and the ledge beyond it.",
    ],
    "background": [
        {"name": "The hall's back wall", "z": [-4.6, -3.6], "tag": [-257.0, 527.4],
         "text": "The same black wall, lit bright orange from below, with the roof above it left in black.",
         "draw": [["rect", -287.0, 517.0, -254.0, 534.0]]},
        {"name": "The smelter and its spout", "z": [-3.2, -1.3], "tag": [-284.4, 529.0],
         "text": "A round-bellied furnace of temple stone with the iron pug on its front, standing on the tapping floor behind the iron shore. A stone spout runs from its tap hole to the head of the pan. The slag comes from here, and you can see it pour.",
         "draw": [["poly", [[-286.3, 525.2], [-282.3, 525.2], [-281.9, 527.0], [-282.6, 529.2], [-283.7, 530.0], [-284.9, 530.0], [-286.0, 529.2], [-286.7, 527.0]], {"style": "pale"}],
                  ["circle", -284.3, 527.3, 0.7, {"style": "solid"}],
                  ["poly", [[-282.0, 526.3], [-280.2, 525.6], [-280.2, 525.35], [-282.1, 525.8]], {"style": "light"}]]},
        {"name": "The pan's back half, its cradles and chains", "z": [-3.0, -1.2], "tag": [-272.0, 531.6],
         "text": "The pan is 3 m from front to back, and you ride its front edge. It lies in two iron cradles, and each cradle hangs from the hall's roof on a pair of chains with links as thick as an arm. The chains rise behind the two dead crusts, where nobody stands, and well back, so they can't be taken for the chain you want. Today the pan hangs in the air.",
         "draw": [["line", -280.3, 525.4, -263.6, 523.1],
                  ["rect", -275.5, 522.2, -274.5, 522.77, {"style": "pale"}], ["rect", -269.5, 521.35, -268.5, 521.94, {"style": "pale"}],
                  ["rect", -275.25, 524.9, -274.75, 534.0, {"style": "pale"}], ["rect", -269.25, 524.1, -268.75, 534.0, {"style": "pale"}]]},
        {"name": "The rake wheel and the three rake handles", "z": [-2.6, -1.5], "tag": [-279.0, 529.0],
         "text": "What moves the rafts. Each raft is the head of a slag rake. Its long iron handle runs back up the pan to a crank on one wheel at the pan's head, beside the smelter, and a steam nozzle kicks the wheel round. Three cranks, three handles, three rafts going to and fro. The handles pass through eyes on the cradles' hangers.",
         "draw": _wheel(-280.7, 527.3, 1.2) + _pipe(-281.2, 517.0, -280.6, 524.6, step=1.8) +
                 [["line", -280.3, 526.5, -278.8, 525.6], ["line", -280.3, 526.7, -273.2, 524.85], ["line", -280.3, 526.9, -267.2, 524.05]]},
        {"name": "The lip and the falling slag", "top": True, "z": [-3.4, -3.0], "style": "mark", "tag": [-264.7, 518.6],
         "text": "At the pan's low east end the slag runs off a lip and falls, in separate bright drops, 22 m into the hopper of Géiseres Gemelos.",
         "draw": [["line", -263.6, 522.2, -263.6, 517.0]]},
        {"name": "The second hoist", "z": [-1.8, -1.3], "tag": [-260.4, 530.7],
         "text": "The same hoist as on the loft's lip, standing on the next ledge with its arm reaching back over the pan's lip. The ring is the eye at the end of its arm and the chain is its chain.",
         "draw": _jib(-258.8, 523.0, 529.9, -262.7)},
        {"name": "The foot of the hammer pier", "z": [-3.4, -1.3], "style": "pale", "tag": [-255.6, 519.6],
         "text": "The ledge at the far side is the first landing of the stepped stone pier that carries the three anvils of La Fragua. The pier comes up from the forge floor, 44 m below.",
         "draw": [["rect", -257.2, 517.0, -254.0, 522.0], ["rect", -257.2, 522.0, -256.2, 522.4],
                  ["poly", [[-257.2, 522.4], [-259.1, 522.4], [-257.2, 520.6]]]]},
    ],
    "play": [
        {"name": "The pan's front plate", "z": [1.1, 1.2], "style": "mark", "tag": [-277.4, 523.0],
         "text": "The front of the pan is black riveted plate with slag frozen in runs over its rim. The slag's surface is bright yellow-orange in the middle of each gap and skinned dark red at its edges, so you can see that it is live.",
         "draw": [["line", -280.2, 523.9, -263.7, 521.6]]},
        {"name": "The rafts' eyes", "z": [-1.1, 1.1], "style": "line", "tag": [-273.0, 525.9],
         "text": "Each raft is a thick iron plate with a turned-up edge and an eye at its west end, where the rake's handle hooks on. Its top is rust orange. Its sides are black and crusted where they sit in the slag.",
         "draw": [["circle", -279.7, 525.3, 0.18], ["circle", -274.1, 524.53, 0.18], ["circle", -268.1, 523.71, 0.18]]},
        {"name": "The two dead crusts", "z": [-0.6, 0.6], "style": "line", "tag": [-272.0, 522.4],
         "text": "Black glassy teeth of slag that has spat up and frozen round the cradles' hangers. They are in the play space and can't be held, so they are plainly dark and wet: they shine, and nothing about them says stand here.",
         "draw": [["circle", -275.0, 524.15, 0.62], ["circle", -269.0, 523.32, 0.62]]},
    ],
    "foreground": [],
    "explains": [
        ["The iron shore", "The smelter's tapping floor", "The smelter and its spout, pouring into the head of the pan"],
        ["The slag", "The smelter's waste, running down a tilted pan to its lip", "The pan's back half, its cradles and chains, and the drops falling off the lip"],
        ["The three rafts", "The heads of three slag rakes", "The rake handles, running back to three cranks on one steam wheel"],
        ["The two dead crusts", "Slag frozen round the cradles' hangers", "The hangers and their heavy chains, rising behind them"],
        ["The chain and its ring", "A hoist over the pan's lip", "The post, arm and brace standing on the next ledge"],
        ["The ledge at the end", "The first landing of the hammer pier", "The pier's stonework under it"],
    ],
    "pieces": [
        ["Slag pan, full depth", "16.9 m long, 3 m deep, 1.1 m tall", "1", "Play space, background", "kit: slag_pan_chains"],
        ["Pan cradle with a hanger and a pair of heavy chains", "cradle 1 m wide; chains 0.5 m across, 17 m", "2", "Background", "kit: slag_pan_chains, remade as two cradles"],
        ["Smelter with a spout and the pug's face", "4.8 m wide, 4.8 m tall", "1", "Background", "new; the face is kit: pug_mask_iron"],
        ["Steam wheel with three cranks", "2.4 m", "1", "Background", "kit: steam wheel (added below)"],
        ["Rake handle", "1.7 m, 7.3 m, 13.4 m", "3", "Background", "kit: drive rod (added below)"],
        ["Vent pipe with a nozzle", "0.6 m across", "1", "Background", "kit: vent_pipe"],
        ["Slag raft with an eye", "2.2 m by 0.5 m", "3", "Play space", "kit: slag_raft"],
        ["Dead crust", "0.8 m wide, 0.7 m tall", "2", "Play space", "new, small"],
        ["Wall jib", "post 6.9 m, arm 3.9 m", "1", "Background", "kit: wall jib (added below)"],
        ["Pier landing block and corbel", "3 m", "1", "Background", "kit: forge wall bay's blocks"],
        ["Forge wall bay, plain", "4 m by 5 m", "8 bays, 4 courses", "Background", "kit: forge wall bay"],
    ],
    "effects": [
        "The slag pours from the spout in a slow bright rope and spreads down the pan.",
        "A burst of sparks wherever the slag throws something back.",
        "Embers thick over the pan, a few of them close to the camera. The rakes' shadows move on the wall.",
        "A puff at the rake wheel's nozzle each time it kicks.",
    ],
    "notes": [
        "Scenery moved out of the play space: the pan's hanging chains stand about 1 m behind you today, inside the play space. They become two pairs of heavy chains at the back of the pan, 2 to 3 m behind.",
        "The slag and the two dead crusts stay in the play space and can't be held. Neither looks like a hold: the slag glows, and the crusts are black, glassy and shining.",
        "Nothing you touch moves or is added.",
    ],
}

# ------------------------------------------------------------------ 6.6 La Fragua
_HX, _HY, _STEP = (-253.5, -249.3, -245.1), (523.6, 527.6, 531.6), (522.0, 526.0, 530.0)


def _hood(x):
    """The top of the hood's slick slab at x."""
    return 531.0 + (x + 258.5) * 0.7


_towers, _lift, _nozz, _faces, _strike = [], [], [], [], []
for _i in range(3):
    _X, _Y = _HX[_i], _HY[_i]
    _top = round(_hood(_X) - 1.2, 2)
    _towers.append(["rect", _X - 0.7, _STEP[_i], _X + 0.7, _top, {"style": "pale"}])
    _towers.append(["rect", _X - 0.3, _Y + 0.4, _X + 0.3, round(_top - 0.4, 2), {"style": "dark"}])
    _lift += _wheel(_X, round(_Y + 3.7, 2), 2.2, n=8, turn=0.2 + 0.7 * _i)
    _lift.append(["circle", round(_X + 1.1, 2), round(_Y + 3.7 - 1.9, 2), 0.2, {"style": "pale"}])
    _nx = _X - 1.6
    _pb = round(_hood(_nx) - 1.6, 2)
    _nozz.append(["rect", round(_nx - 0.15, 2), round(_pb - 0.9, 2), round(_nx + 0.15, 2), _pb, {"style": "pale"}])
    _faces.append(["line", _X - 1.0, _Y + 0.05, _X + 1.0, _Y + 0.05])
    _strike.append(["rect", _X - 1.0, _Y + 0.8, _X + 1.0, _Y + 0.92])
_main = [["poly", [[-258.3, round(_hood(-258.3) - 1.6, 2)], [-241.8, round(_hood(-241.8) - 1.6, 2)], [-241.8, round(_hood(-241.8) - 1.0, 2)],
                   [-258.3, round(_hood(-258.3) - 1.0, 2)]], {"style": "pale"}]]
_DOOR_L6 = _door(-239.8, 535.6, -237.8, 538.4)

_FRAGUA = {
    "id": "6.6", "slug": "6_6_la_fragua", "title": "La Fragua", "kind": "challenge",
    "window": [-262.0, 518.0, -233.0, 545.0], "screen": [-249.5, 529.5], "cut_y": 528.0, "climber": [-257.6, 523.0],
    "place": ("The hammer shop. A stepped pier of temple stone rises from the forge floor through the whole hall, each step 4.2 m "
              "wide and 4 m tall, like a stair for a giant. One great anvil stands on each of three steps, and over each anvil hangs "
              "a drop hammer. Behind each hammer is the wheel that lifts it: a peg on the wheel's rim hooks under the hammer's tail, "
              "carries it up and lets it go. A steam pipe under the forge's hood turns the wheels. The chain you climb hangs from the "
              "hammer's own lug, so it is only up there while the hammer is. This is the last of the temple's stone and the heaviest "
              "of its iron. "
              "The light: orange going to gold. The slag's light now comes from behind you and below, and every hammer blow throws "
              "white-gold sparks. The hood is a lid over this room, so there is still no daylight in it."),
    "keep": [
        "The three anvils, the three hammers and their timing, and the three chains, exactly as they are.",
        "To cross an anvil you walk under its hammer.",
        "The slick hood above, which sheds fallers from the flue down into the hall.",
    ],
    "background": [
        {"name": "The hall's back wall", "z": [-4.6, -3.6], "tag": [-259.6, 536.0],
         "text": "The same black wall, here lit orange from the left and below, with sparks on it.",
         "draw": [["rect", -262.0, 518.0, -236.0, 545.0]]},
        {"name": "The stepped pier", "z": [-3.4, -1.3], "tag": [-239.6, 526.6],
         "text": "Soot-black temple blocks in three giant steps and a head, with the iron pug on each riser. One anvil stands on each step. The ledge you start on is the pier's first landing, and the ledge at the top is its head. Today the anvils hang in the air.",
         "draw": [["poly", [[-257.2, 518.0], [-257.2, 522.0], [-251.6, 522.0], [-251.6, 526.0], [-247.4, 526.0], [-247.4, 530.0], [-243.2, 530.0],
                            [-243.2, 535.0], [-236.0, 535.0], [-236.0, 518.0]], {"style": "pale"}],
                  ["rect", -257.2, 522.0, -256.2, 522.4, {"style": "pale"}], ["poly", [[-257.2, 522.4], [-259.1, 522.4], [-257.2, 520.6]], {"style": "pale"}],
                  ["circle", -255.8, 520.4, 0.6, {"style": "solid"}], ["circle", -250.4, 524.4, 0.6, {"style": "solid"}],
                  ["circle", -246.2, 528.4, 0.6, {"style": "solid"}]]},
        {"name": "The slotted towers", "z": [-2.2, -1.3], "tag": [-248.0, 535.6],
         "text": "Behind each hammer a narrow stone tower rises from the step to the hood, with a dark slot down its middle. The hammer's tail runs in the slot. It is the temple's rule, kept in the forge: every block that moves has a slot it slides in.",
         "draw": _towers},
        {"name": "The three lifting wheels", "z": [-2.0, -1.4], "tag": [-256.2, 528.4],
         "text": "What lifts the hammers. On each tower's axle turns an iron wheel 4.4 m across, with paddles on its rim and one peg. The peg hooks under the hammer's tail, carries it up 4.2 m and lets it go at the top. You can read each hammer's time from its wheel: when the peg comes round to the bottom, that hammer is about to rise.",
         "draw": _lift},
        {"name": "The steam pipe under the hood", "top": True, "z": [-3.0, -1.5], "tag": [-252.4, 533.7],
         "text": "The slanting black slab over the hammers is the forge's great hood, ribbed with iron underneath. A fat steam pipe runs up under it, and a nozzle drops from the pipe towards each wheel and kicks it round. A puff at the nozzle comes just before each hammer starts up. The same pipe goes on up into the flue and feeds the three vents of El Último Aliento.",
         "draw": _main + _nozz},
        {"name": "The scorched bunting", "z": [-4.2, -4.0], "style": "mark", "tag": [-260.6, 541.7],
         "text": "High in the corner where the hall's roof meets the flue: one scorched string of the town's cut paper, with three flags left on it. It hangs there today, nearer. It moves to the far back, where a hanging thing can't be taken for a rope.",
         "draw": [["line", -262.0, 540.9, -257.2, 540.3],
                  ["poly", [[-261.2, 540.8], [-260.6, 540.7], [-260.9, 540.0]], {"style": "pale"}],
                  ["poly", [[-259.8, 540.6], [-259.2, 540.5], [-259.5, 539.9]], {"style": "pale"}],
                  ["poly", [[-258.4, 540.45], [-257.8, 540.4], [-258.1, 539.8]], {"style": "pale"}]]},
        {"name": "The second hoist", "z": [-1.8, -1.3], "tag": [-260.6, 528.4],
         "text": "From Escoria: the hoist on the pier's first landing, reaching back over the slag pan's lip.",
         "draw": _jib(-258.8, 523.0, 529.9, -262.0)},
        {"name": "The last stair door", "z": [-3.6, -3.2], "tag": [-238.8, 539.3],
         "text": "In the wall behind the top ledge: the last of the grilled stair doors. Above it nobody built in stone.",
         "draw": _DOOR_L6},
    ],
    "play": [
        {"name": "The anvils' bright faces", "z": [-0.6, 0.6], "style": "mark", "tag": [-255.7, 524.4],
         "text": "Each anvil's face is polished bright in the middle, where the hammer lands, and sooty at its two ends. The bright patch is exactly as wide as the hammer. The anvil's foot carries the iron pug.",
         "draw": _faces},
        {"name": "The hammers' striking faces", "z": [-0.6, 0.6], "style": "pale", "tag": [-247.4, 533.4],
         "text": "Each hammer is a block of black greased iron with a peaked top and the pug's face cast on its front. Its striking face is a band of bright worn steel, the only pale thing on it, so you can see which edge will hit you. The lug on its east side, where the chain hangs, is rust orange.",
         "draw": _strike},
    ],
    "foreground": [],
    "explains": [
        ["The three anvils", "Great anvils on the steps of a stone pier", "The stepped pier, with the iron pug on each riser"],
        ["The three hammers", "Drop hammers, each lifted by a peg on a wheel and let go", "The lifting wheel behind each, the slotted tower its tail runs in, and the steam nozzle that turns the wheel"],
        ["The three chains", "Each hangs from its hammer's lug", "The hammer, and the wheel behind it, whose turning tells you when the chain will rise and fall"],
        ["The ledge you start on", "The pier's first landing", "The pier, and the hoist standing on the landing"],
        ["The ledge at the top", "The pier's head", "The last stair door"],
    ],
    "pieces": [
        ["Stepped pier", "three steps 4.2 m wide and 4 m tall; head 7.2 m wide", "1", "Background", "new, from the forge wall bay's blocks"],
        ["Great anvil", "2.6 m by 1.6 m", "3", "Play space", "kit: anvil_great"],
        ["Iron pug mask", "1.2 m", "3 on the risers, 3 on the hammers, 3 on the anvils' feet", "Background, play space", "kit: pug_mask_iron"],
        ["Drop hammer: head, tail, lug, bright striking face", "head 2 m wide, 2.2 m tall", "3", "Play space", "kit: drop hammer's head and chain"],
        ["Slotted tower", "1.4 m wide, 9.2 to 11.3 m tall", "3", "Background", "new"],
        ["Lifting wheel with paddles and a peg", "4.4 m", "3", "Background", "kit: steam wheel (added below), large; this is the sheet's wheel and cam"],
        ["Forge hood with ribs", "17.5 m", "1", "Background", "kit: forge_hood_ribs"],
        ["Steam pipe under the hood, with three drop nozzles", "0.6 m across, 20 m", "1", "Background", "kit: vent_pipe"],
        ["Scorched bunting", "5 m, three flags", "1", "Background", "in the kit: papel_tatters"],
        ["Wall jib; stair door", "as in Escoria; 2 m by 2.8 m", "1; 1", "Background", "kit: wall jib, stair door (added below)"],
    ],
    "effects": [
        "A spray of white-gold sparks and a ring of dust at each blow.",
        "A puff of steam at each wheel's nozzle just before its hammer starts to rise.",
        "Each chain swings a little when its hammer lands.",
    ],
    "notes": [
        "The hammers, the anvils' waists and the hood are in the play space and can't be held. They are plainly dark and wet: black greased iron on the hammers, a black glassy crust of slag on the waists, soot-wet plate on the hood. What can be held on them is rust orange: each hammer's lug, each chain and each anvil's face.",
        "Scenery moved out of the play space: nothing here was in it. The bunting moves from 1.6 m behind to 4 m behind.",
        "Nothing you touch moves or is added.",
    ],
}

# ------------------------------------------------------------------ 6.7 Tiro de Chimenea
_KEPT = [(-236.3, 541.6), (-236.3, 547.3), (-237.6, 548.2), (-240.1, 549.3)]
_GONE = [(-236.3, 538.6), (-236.3, 544.3), (-238.9, 548.8)]

_TIRO = {
    "id": "6.7", "slug": "6_7_tiro_de_chimenea", "title": "Tiro de Chimenea", "kind": "challenge",
    "window": [-251.0, 532.0, -231.0, 553.0], "screen": [-240.5, 542.5], "cut_y": 544.6, "climber": [-241.9, 535.6],
    "place": ("The updraught shaft: the forge's own chimney. The great hood over the hammers gathers the whole forge's heat and "
              "pours it in here, under the foot of an iron baffle, and it goes up between the baffle and the flue's east wall. That "
              "is the wind that carries you. Half way up the baffle has a window with an iron flap, and every few seconds the "
              "draught snatches the flap open and sucks sideways through it. The rings on the wall are where the smiths hung their "
              "chains to sweep the shaft. An iron grille once capped it: one bar is left, and the last rings are on that bar. "
              "This is where the made things stop. The ledge you start on is the last cut stone. Above it the wall is the "
              "mountain's own basalt, and the baffle is the last big piece of iron. "
              "The light: dusty gold. The red still comes from below, on the underside of everything, and for the first time a pale "
              "light comes down from above, down the pipe over the shaft's head."),
    "keep": [
        "The steady draught, the cross gust, its window and its timing, exactly as they are.",
        "Note 61: seven rings become four. Two stay on the east wall, just under and just over the gust band. Two stay across the top, the first and the last.",
        "The baffle and the east wall can't be climbed.",
    ],
    "background": [
        {"name": "The flue's far wall", "z": [-4.4, -3.2], "tag": [-248.6, 551.4],
         "text": "Above the pier's head the temple stone stops. From here up the wall is basalt: grey-brown, in rough blocky steps, split by heat. Low in the shaft the cracks still show a dull red.",
         "draw": [["rect", -251.0, 532.0, -236.0, 553.0],
                  ["line", -240.6, 537.0, -240.9, 539.6, {"style": "mark"}], ["line", -238.2, 541.0, -238.9, 543.0, {"style": "mark"}],
                  ["line", -237.6, 542.6, -238.3, 546.4, {"style": "mark"}], ["line", -248.0, 546.2, -246.8, 548.0, {"style": "mark"}]]},
        {"name": "The pier's head, the last door and the last pug", "z": [-3.6, -1.3], "tag": [-240.6, 533.5],
         "text": "The ledge you start on is the head of the hammer pier: the last cut stone on the climb. Behind it is the last grilled stair door, and over the door the last iron pug. Above this nothing has a face.",
         "draw": [["rect", -243.2, 532.0, -236.0, 535.0, {"style": "pale"}]] + _DOOR_L6 + [["circle", -238.8, 539.3, 0.55, {"style": "line"}]]},
        {"name": "The hood's top end and the steam pipe", "z": [-3.0, -1.5], "tag": [-247.6, 536.4],
         "text": "The top end of the forge's hood, and the steam pipe that runs up under it. The pipe comes through the hood, goes up the wall and turns in under the next ledge, where it feeds the first vent of El Último Aliento. The hood is what pours the forge's heat into this shaft.",
         "draw": [["poly", [[-251.0, round(_hood(-251.0) - 1.6, 2)], [-243.6, round(_hood(-243.6) - 1.6, 2)], [-243.6, round(_hood(-243.6) - 1.0, 2)],
                            [-251.0, round(_hood(-251.0) - 1.0, 2)]], {"style": "pale"}]] +
                 _pipe(-244.2, 540.2, -243.6, 548.0, step=1.5) + [["rect", -244.9, 547.6, -243.6, 548.2, {"style": "pale"}]]},
        {"name": "The flap", "z": [-2.2, -1.3], "style": "pale", "tag": [-243.0, 545.4],
         "text": "The window in the baffle has an iron flap, hinged at the top on the far side. It hangs slack while the air is quiet. It starts to rattle and lift 0.9 s before the gust, and it is flung wide open while the gust blows. It is the warning you can see, to go with the whistle.",
         "draw": [["poly", [[-241.5, 546.0], [-241.75, 546.05], [-242.6, 543.75], [-242.35, 543.7]]]]},
        {"name": "Two chain stubs", "z": [-3.2, -2.8], "style": "pale", "tag": [-239.2, 541.6],
         "text": "The bare flue's only dressing: two short thick stubs of chain on pins in the far wall, three links each. The lower one stands straight up in the steady draught, so you see the wind before you step into it. The upper one is in the gust band, and it lies over to the west when the gust comes.",
         "draw": [["rect", -240.35, 541.2, -240.05, 541.9], ["circle", -240.2, 541.15, 0.13],
                  ["rect", -239.9, 544.85, -239.2, 545.15], ["circle", -239.2, 545.0, 0.13]]},
        {"name": "The cap grille's last bars", "top": True, "z": [-2.4, -1.3], "style": "line", "tag": [-238.3, 550.2],
         "text": "An iron grille once capped the shaft. One bar of it is left whole, slanting from the east wall up to the top ledge, and two more are snapped off behind it. The rings across the shaft's head are eyes on short pins from the whole bar. Today they hang in the air.",
         "draw": [["line", -236.0, 547.5, -241.0, 549.6], ["line", -236.0, 548.5, -237.5, 549.15], ["line", -239.9, 550.6, -241.0, 551.05]]},
        {"name": "The pale light down the pipe", "z": [-3.2, -3.0], "style": "mark", "tag": [-238.2, 552.1],
         "text": "Straight above the shaft is the slick pipe that comes down from under the chockstone of La Luz, and daylight comes down it. It is the first daylight on the climb: a pale dusty column in the top of the shaft that fades before it reaches the window.",
         "draw": [["line", -239.7, 553.0, -239.85, 550.4], ["line", -236.5, 553.0, -236.4, 549.2]]},
    ],
    "play": [
        {"name": "The sockets of the three rings that go", "z": [-0.3, 0.3], "style": "dark", "tag": [-237.4, 538.0],
         "text": "Note 61 takes three rings away: the lowest on the wall, the one inside the gust band, and the middle one across the top. Each of the two on the wall leaves an empty square socket with a rust streak under it: dark, flat, and plainly nothing to hold. The one across the top leaves a snapped pin on the bar. The sketch draws the three over today's rings.",
         "draw": [["rect", x - 0.3, y - 0.3, x + 0.3, y + 0.3] for x, y in _GONE]},
        {"name": "The four rings that stay", "z": [-0.3, 0.3], "style": "line", "tag": [-237.5, 541.6],
         "text": "The kit's wall ring: a round iron ring 0.5 m across on a pin, rust orange, worn bright inside where hands have been. With half of them gone, the four are the only orange things in the shaft.",
         "draw": [["circle", x, y, 0.48] for x, y in _KEPT]},
        {"name": "The baffle's window", "z": [-1.2, 1.2], "style": "mark", "tag": [-242.4, 547.3],
         "text": "The baffle is a wall of black riveted iron plate, greased with soot. The edges of its window are scraped bright by everything the gust has pulled through.",
         "draw": [["line", -241.5, 543.1, -241.0, 543.4], ["line", -241.5, 546.0, -241.0, 546.0]]},
    ],
    "foreground": [
        {"name": "A heavy chain's last links", "top": True, "z": [1.3, 1.6], "style": "line", "tag": [-233.4, 551.5],
         "text": "The last three links of a heavy chain hang into the top corner of the frame, in front of the solid east wall. They lift a little in the draught. They are in front of rock, never in front of the shaft.",
         "draw": [["circle", -234.6, 552.3, 0.35], ["circle", -234.6, 551.6, 0.35], ["circle", -234.6, 550.9, 0.35]]},
    ],
    "explains": [
        ["The steady draught", "The forge's heat, gathered by the hood and poured into the shaft", "The hood's top end coming in under the baffle, and the chain stub that stands straight up"],
        ["The cross gust and its window", "A flap in the baffle, sucked open", "The flap, which rattles first, and the upper chain stub lying over"],
        ["The two rings on the east wall", "Wall rings on pins, where the smiths hung chains to sweep the shaft", "The empty sockets of the rings that are gone, and the chain stubs on the far wall"],
        ["The two rings across the top", "Eyes on the last whole bar of the shaft's cap grille", "The bar, and two snapped bars behind it"],
        ["The ledge you start on", "The head of the hammer pier", "The pier's stonework, the last door and the last pug"],
        ["The ledge at the top", "A shelf of basalt on the baffle's head: the first ledge nobody cut", "The steam pipe turning in under it"],
    ],
    "pieces": [
        ["Basalt wall: rough steps, heat cracks", "to suit", "15 m by 18 m", "Background", "kit: basalt wall"],
        ["Wall ring on a pin", "0.5 m", "4", "Play space", "kit: wall ring on a pin (note 61: four, not seven)"],
        ["Empty ring socket with a rust streak; snapped pin", "0.3 m", "2; 1", "Play space (drawn on)", "new, small"],
        ["Baffle plate with a window; flap", "0.5 m thick, 8.4 m tall; flap 2.5 m", "1; 1", "Play space; the flap is background", "new"],
        ["Old chain stub on a wall pin", "0.6 m", "2", "Background", "kit: old chain stub"],
        ["Cap grille bar: whole; snapped", "5.4 m; 1.5 m", "1; 2", "Background", "new, this area only"],
        ["Steam pipe: slant, riser and elbow", "0.6 m across", "1", "Background", "kit: vent_pipe"],
        ["Hood's top end, with ribs", "as in La Fragua", "1", "Background", "kit: forge_hood_ribs"],
        ["Pier head; stair door; small iron pug", "7.2 m; 2 m by 2.8 m; 1.1 m", "1 each", "Background", "kit: forge wall bay's blocks, stair door (added below), pug_mask_iron"],
        ["Heavy chain, last three links", "links 0.7 m", "1", "Foreground", "new, small"],
    ],
    "effects": [
        "Steam and soot streaming straight up the shaft, and sideways out of the window while the gust blows.",
        "The flap rattles for 0.9 s, then bangs open.",
        "Dust in the pale column at the shaft's head.",
    ],
    "notes": [
        "Note 61 (not built yet): half as many rings. The design shows four, as the note plans, and marks the three that go.",
        "Course change, from note 61: three rings go. Nothing else you touch moves or is added.",
        "The baffle, the hood and the east wall are in the play space and can't be held. They are plainly dark and wet: black greased plate and soot-wet rock. The flap, the chain stubs and the grille's bars are scenery, at least 1.3 m behind you.",
    ],
}

# ------------------------------------------------------------------ 6.8 El Último Aliento
_ALIENTO = {
    "id": "6.8", "slug": "6_8_el_ultimo_aliento", "title": "El Último Aliento", "kind": "challenge",
    "window": [-262.0, 546.0, -238.5, 577.0], "screen": [-247.0, 561.0], "cut_y": 557.6, "climber": [-242.2, 549.0],
    "place": ("The bare flue, and the forge's last three breaths. Above the shaft the flue opens out into a tall leaning cleft of "
              "basalt with nothing built in it. One thing of the forge's comes this high: the steam pipe that ran up under the "
              "hood. It climbs the far wall in three flights, and at the end of each flight an elbow comes forward and ends in a "
              "grate. The steam climbs the pipe, so the three vents blow one after another from the bottom up. The rings are the "
              "eyes of the pipe's clamps. Above the third grate there is one ring on a spike, and then only rock. "
              "The light: gold going pale. The forge's red reaches about as high as the second grate. A shaft of daylight comes "
              "in at the crack and slants down across the flue, and the third grate sits in it. Each breath is lit paler than the "
              "one before."),
    "keep": [
        "The three vents and their timing, the three rings, and both ledges, exactly as they are.",
        "Note 63: the vents are about 10% stronger, so the top of each flight comes out just above its ring.",
        "Note 62: the two high grates can be held and stood on, and must look it.",
        "Nothing stands in front of a vent.",
    ],
    "background": [
        {"name": "The flue's far wall", "z": [-4.4, -3.2], "tag": [-252.0, 571.0],
         "text": "Bare basalt. It gets paler and drier as it climbs: grey-brown and cracked at the bottom ledge, with a dull red still in the lowest cracks, and a dry pale grey by the top ledge. Nothing is built on it.",
         "draw": [["rect", -262.0, 546.0, -238.5, 577.0],
                  ["line", -252.0, 548.0, -251.0, 551.4, {"style": "mark"}], ["line", -251.0, 551.4, -252.2, 554.0, {"style": "mark"}],
                  ["line", -256.2, 551.6, -255.4, 554.6, {"style": "mark"}]]},
        {"name": "The steam pipe, in three flights", "z": [-3.0, -1.3], "tag": [-242.9, 552.6],
         "text": "The forge's steam pipe climbs the far wall: up, across, up, across, and a capped stub. Each grate sits on the end of one flight, where an elbow comes forward to the play plane. After note 62 the two high grates are plainly held up, and plainly part of one machine. The first ring is the eye of a clamp on the second riser. The second ring is on the capped stub.",
         "draw": [["rect", -244.9, 547.6, -243.6, 548.2, {"style": "pale"}]] + _pipe(-244.2, 549.0, -243.6, 556.8, step=1.5) +
                 [["rect", -246.9, 556.2, -243.6, 556.8, {"style": "pale"}]] + _pipe(-245.55, 556.8, -244.95, 565.0, step=1.5) +
                 [["rect", -248.7, 564.4, -244.95, 565.0, {"style": "pale"}], ["rect", -247.35, 565.0, -246.75, 566.5, {"style": "pale"}],
                  ["rect", -247.5, 566.5, -246.6, 566.72, {"style": "pale"}],
                  ["poly", [[-246.3, 556.2], [-245.5, 556.2], [-245.5, 555.4]], {"style": "pale"}],
                  ["poly", [[-248.1, 564.4], [-247.3, 564.4], [-247.3, 563.6]], {"style": "pale"}]]},
        {"name": "The shaft of daylight", "z": [-4.0, -3.8], "style": "mark", "tag": [-251.4, 561.4],
         "text": "Daylight comes in at the crack and slants down across the flue to the west wall. It is painted there today. Low down it turns dusty gold and dies into the red. The third grate and the second ring sit inside it: they are the first things on the climb that daylight touches, and the brightest things above you.",
         "draw": [["line", -240.75, 577.0, -249.0, 566.0], ["line", -249.0, 566.0, -254.0, 552.0],
                  ["line", -238.5, 575.1, -250.5, 562.0], ["line", -250.5, 562.0, -254.6, 550.0]]},
        {"name": "Two old chain stubs", "z": [-3.2, -2.8], "style": "pale", "tag": [-252.6, 549.5],
         "text": "Two short stubs of chain on pins, both below the second grate. Above it the wall has no iron on it but the pipe.",
         "draw": [["rect", -251.65, 549.9, -251.35, 550.5], ["circle", -251.5, 549.85, 0.13],
                  ["rect", -255.15, 555.5, -254.85, 556.1], ["circle", -255.0, 555.45, 0.13]]},
        {"name": "The last ring's spike", "top": True, "z": [-1.6, -1.2], "style": "pale", "tag": [-249.2, 574.4],
         "text": "The last ring is on a single iron spike driven into the far wall beside the top ledge. It is the highest made thing inside the mountain.",
         "draw": [["rect", -248.15, 573.35, -247.75, 573.65]]},
    ],
    "play": [
        {"name": "The two high grates, made plain", "z": [-0.75, 0.75], "style": "pale", "tag": [-248.6, 558.2],
         "text": "Note 62. The second and third grates wear the same raised rim and red grille as the one in the ledge. Each sits on the end of the pipe's elbow, and the elbow stops just behind the play plane, so nothing new is put in the play space under a grate. Steam seeps from them between blasts. The second grate, which daylight does not reach, has a dull red glow in its bars from the steam below, so it is never a dark box in the dark.",
         "draw": [["rect", -247.3, 557.2, -245.9, 557.32], ["rect", -249.1, 565.4, -247.7, 565.52]]},
        {"name": "The top ledge", "z": [-1.2, 1.2], "style": "mark", "tag": [-245.0, 571.6],
         "text": "The crack's doorstep: natural basalt, dry and pale, with daylight on it. The frozen climber of La Luz stands on it with one arm raised. From below he is the last thing on the skyline, with light on his hand.",
         "draw": [["line", -247.3, 572.45, -243.5, 572.45]]},
    ],
    "foreground": [
        {"name": "A fin of basalt", "z": [1.2, 1.8], "tag": [-241.8, 556.0],
         "text": "A rough fin of basalt standing in front of the foot of the pillar on the right. It covers only solid rock.",
         "draw": [["poly", [[-243.3, 554.0], [-240.2, 554.0], [-240.6, 557.4], [-242.0, 558.8], [-243.0, 556.9]]]]},
    ],
    "explains": [
        ["The first grate, in the ledge", "The first mouth of the forge's steam pipe", "The pipe coming in under the ledge from the hood"],
        ["The second and third grates", "The next two mouths of the same pipe", "The pipe's flights up the far wall, with an elbow under each grate"],
        ["The first two rings", "The eyes of the pipe's clamps", "The riser and the capped stub they are clamped to"],
        ["The last ring", "A ring on a spike in bare rock", "The spike, and nothing else"],
        ["The top ledge", "A shelf of dry basalt at the foot of the crack", "The daylight on it, and the frozen climber"],
        ["The bottom ledge", "A shelf of basalt on the baffle's head", "The red cracks in the wall behind it"],
    ],
    "pieces": [
        ["Basalt wall: rough steps, heat cracks, in three tones from grey-brown to pale grey", "to suit", "23 m by 31 m", "Background", "kit: basalt wall"],
        ["Steam pipe: risers, level runs, elbows, clamps and a cap", "0.6 m across, 26 m in all", "1", "Background", "kit: vent_pipe"],
        ["Steam grate with a rim", "1.6 m; 1.2 m", "1; 2", "Play space", "kit: steam_grate (note 62)"],
        ["Wall ring on a pin", "0.5 m", "3", "Play space", "kit: wall ring on a pin"],
        ["Old chain stub on a wall pin", "0.6 m", "2", "Background", "kit: old chain stub"],
        ["Shaft of daylight", "2.5 m wide, 40 m long", "1", "Background", "there today as a painted card"],
        ["Basalt fin", "3.1 m wide, 4.8 m tall", "1", "Foreground", "kit: basalt fin (added below)"],
    ],
    "effects": [
        "Steam seeping from the second and third grates between blasts, lit gold at the second and white at the third.",
        "Each blast's steam is lit paler than the one below it.",
        "Dust motes in the shaft of daylight.",
    ],
    "notes": [
        "Note 62 (not built yet): the high grates sit on the pipe, seep steam and are lit, so they read as the next step.",
        "Note 63 (not built yet): all three vents are about 10% stronger.",
        "Nothing you touch moves or is added. The pipe, its elbows and its clamps stay at least 1.2 m behind you. Only the grates and the rings come forward into the play space.",
        "The pillar on the right is in the play space and can't be held. It is plainly dark and wet: black, soot-wet basalt.",
    ],
}

# ------------------------------------------------------------------ 6.9 La Luz
_LUZ = {
    "id": "6.9", "slug": "6_9_la_luz", "title": "La Luz", "kind": "challenge",
    "window": [-250.5, 568.0, -227.5, 590.0], "screen": [-239.5, 579.5], "cut_y": 576.6, "climber": [-245.2, 572.5],
    "place": ("The crack to daylight, and the way out of the mountain. At its top the flue narrows to a crack where the basalt of "
              "the inside meets the pale chalk of the outside. Nothing here is made: no iron, no cut stone, no soot. Two shelves of "
              "basalt step up to a gap, and a block of chalk that fell from the roof is jammed across the gap. Chalk is weak. The "
              "block is cracked through and it gives way under you. A band of flint knobs in the chalk is the way over when it has "
              "gone. Beyond it is a sill of white chalk, and the opening. One frozen climber stands on the doorstep with his hand "
              "up toward the light. "
              "The light: this is the top of the journey. It is blue-white daylight, coming level through the opening on the right, "
              "and there is no red left in it. The design stops at the opening."),
    "keep": [
        "The doorstep, the two steps, the three nubs and the sill, exactly as they are.",
        "The chockstone's size, wedge shape and timing: it gives way after 1.2 s and is back in 8 s.",
        "The gap under it drops to the updraught shaft, two challenges back.",
        "The frozen climber, exactly where he stands today.",
    ],
    "background": [
        {"name": "The crack's back wall", "z": [-1.8, -1.2], "tag": [-247.0, 570.2],
         "text": "The crack is narrow. Its back wall is only 1.2 m behind you: the first time on this climb that a back wall is within reach. West of a slanting line it is the flue's basalt, grey-brown and dry. East of the line, for the last few metres to the opening, it is pale chalk: the mountain's outside.",
         "draw": [["rect", -250.5, 568.0, -234.0, 590.0],
                  ["poly", [[-243.6, 590.0], [-243.6, 579.2], [-240.4, 575.2], [-236.0, 570.0], [-234.0, 570.0], [-234.0, 590.0]], {"style": "pale"}]]},
        {"name": "The gap's black wall", "top": True, "z": [-1.8, -1.2], "style": "dark", "tag": [-238.6, 571.6],
         "text": "Under the chockstone the gap between the two walls drops away to the updraught shaft, 26 m below. Its back and its sides are black and glassy, worn smooth by the draught, with nothing on them to catch. It reads as a drop, and it is one.",
         "draw": [["poly", [[-240.0, 568.0], [-236.5, 568.0], [-237.2, 571.0], [-237.2, 575.6], [-240.0, 575.5]]]]},
        {"name": "The flint band", "z": [-1.4, -1.2], "style": "mark", "tag": [-235.2, 582.3],
         "text": "A band of flint runs up through the chalk: a line of knobs in their white rind, slanting from the second step to the opening. The three nubs over the gap are three knobs of this band that stand out far enough to hold. The band goes on past them, so the way out is drawn on the wall before the chockstone ever drops.",
         "draw": [["line", -241.0, 575.87, -234.3, 581.6]]},
        {"name": "The split in the roof", "z": [-2.4, -1.2], "style": "dark", "over": True, "tag": [-240.6, 585.0],
         "text": "Right above the chockstone the roof has a split, packed with blocks of chalk that have not fallen yet. The chockstone came out of it. When the stone gives way under you, the next block drops out of the split with a thud and a puff of white dust, and wedges where the last one was (note 64). You can see the next one waiting.",
         "draw": [["poly", [[-239.7, 582.5], [-237.5, 584.2], [-237.9, 585.9], [-240.1, 584.4]]],
                  ["circle", -238.9, 584.1, 0.45, {"style": "pale"}], ["circle", -238.5, 585.05, 0.33, {"style": "pale"}]]},
        {"name": "The edge of daylight", "z": [-1.6, -1.3], "style": "mark", "tag": [-241.9, 579.6],
         "text": "The daylight comes in under the roof, and its lowest edge reaches the frozen climber's raised hand and the top of his mask. The rest of him is in the pillar's shadow.",
         "draw": [["line", -234.0, 585.6, -246.25, 575.05]]},
        {"name": "The sky through the opening", "top": True, "z": [-8.0, -6.0], "style": "light", "tag": [-230.4, 583.4],
         "text": "What you see through the opening, and all you see of the next place. Sky first: a hard clear blue, the first since the station. Under it the far side of the valley, pale and hazy, and at its foot the town, tiny, with the ring a dot of colour in its plaza. One vulture turns a long way off. The opening is 6 m tall and you walk out along the sill.",
         "draw": [["rect", -234.0, 580.0, -227.5, 590.0],
                  ["poly", [[-231.0, 580.0], [-230.2, 581.0], [-229.2, 580.6], [-228.2, 581.6], [-227.5, 581.3], [-227.5, 580.0]], {"style": "solid"}],
                  ["rect", -229.95, 580.05, -229.8, 580.22, {"style": "pale"}], ["rect", -229.7, 580.05, -229.5, 580.3, {"style": "pale"}],
                  ["line", -229.9, 585.3, -229.4, 585.0, {"style": "line"}], ["line", -229.4, 585.0, -228.9, 585.3, {"style": "line"}]]},
    ],
    "play": [
        {"name": "The cracked chockstone", "z": [-1.2, 1.2], "style": "mark", "tag": [-236.3, 576.4],
         "text": "Note 64. The chockstone is a real stone: a rough block of chalk jammed between the two walls, the same size and wedge shape as the stand-in, so the step across plays the same. It wears the mountain's one breakable look: cracked right through, with a corner gone. Grit trickles from under it, and it shifts when you first touch it. It breaks into rough chunks that drop down the gap with white dust.",
         "draw": [["line", -239.3, 577.0, -238.9, 576.4], ["line", -238.9, 576.4, -238.2, 576.3], ["line", -238.2, 576.3, -237.9, 575.98],
                  ["poly", [[-237.15, 576.2], [-237.75, 576.06], [-237.15, 576.6]], {"style": "dark"}]]},
        {"name": "The three flint nubs", "z": [-1.2, -0.6], "style": "line", "tag": [-240.4, 578.2],
         "text": "Three knobs of flint in their white rind, each the size of two fists, standing 0.4 m out of the chalk. Dry, pale and matte. They are natural, and they lie on the flint band's line.",
         "draw": [["circle", -239.5, 577.15, 0.38], ["circle", -238.4, 578.1, 0.38], ["circle", -237.45, 578.9, 0.38]]},
        {"name": "The one who nearly had it", "top": True, "z": [-0.3, 0.3], "style": "mark", "tag": [-248.4, 574.6],
         "text": "The second of the chimney's frozen climbers stands on the doorstep exactly where he is today, 1.35 m from the last ring, with one arm raised toward the light. His raised hand and the top of his mask are in daylight. Nothing is put beside him, because nothing was ever made up here: he is the only thing in the frame that is not rock. He got out of the forge, and stopped one easy challenge short of the sky.",
         "draw": [["rect", -247.15, 572.5, -246.05, 575.4]]},
        {"name": "The sill", "z": [-1.2, 1.2], "style": "mark", "tag": [-235.6, 580.7],
         "text": "The two steps are the last of the basalt. The sill is the first of the chalk: white, dry and gritty, with wind-blown dust on it. You change rock as you climb out.",
         "draw": [["line", -237.1, 580.0, -234.1, 580.0]]},
    ],
    "foreground": [
        {"name": "A fin of basalt", "z": [1.2, 1.8], "tag": [-241.8, 569.7],
         "text": "The same rough fin as in El Último Aliento, in front of the pillar under the steps. It covers only solid rock.",
         "draw": [["poly", [[-243.3, 568.0], [-240.2, 568.0], [-240.5, 571.0], [-242.2, 572.3], [-243.1, 570.4]]]]},
        {"name": "A chalk overhang", "top": True, "z": [1.3, 2.0], "style": "dark", "tag": [-236.2, 587.3],
         "text": "A dark overhang in front of the roof at the top right, over the opening. With the fin below, it makes the opening the brightest shape in the frame. It covers only solid rock.",
         "draw": [["poly", [[-237.2, 584.8], [-234.6, 586.9], [-234.6, 588.0], [-236.2, 588.9], [-237.6, 587.0]]]]},
    ],
    "explains": [
        ["The doorstep and the two steps", "Shelves of basalt at the top of the flue", "The basalt of the back wall, up to the line where the chalk begins"],
        ["The chockstone", "A block of chalk fallen from the roof and jammed in the crack", "The split in the roof it came from, with the next blocks waiting in it"],
        ["The three nubs", "Knobs of flint standing out of the chalk", "The flint band, running on along the back wall to the opening"],
        ["The gap", "The top of the pipe down to the updraught shaft", "Its black, glassy back wall"],
        ["The sill", "The lip of the mountain's outside: chalk", "The sky, the far side of the valley and the town, through the opening"],
        ["The frozen climber", "One who nearly had it", "The edge of daylight that reaches his hand"],
    ],
    "pieces": [
        ["Basalt wall, pale and dry", "to suit", "10 m by 20 m", "Background", "kit: basalt wall"],
        ["Chalk wall with a flint band", "to suit", "10 m by 20 m", "Background", "new: the cliffs' rock, first used here"],
        ["Cracked chockstone, and its broken chunks", "2.9 m wide, 0.8 to 1.5 m thick", "1", "Play space", "kit: cracked chockstone (note 64)"],
        ["Flint knob", "0.4 m", "3 to hold, 8 flush in the band", "Play space, background", "new, small"],
        ["Roof split with waiting blocks", "2.6 m by 3.4 m", "1", "Background", "new, this area only"],
        ["Glassy gap wall", "3.5 m by 7.5 m", "1", "Background", "kit: basalt wall, polished black"],
        ["Sky, far valley side, tiny town with the ring, one vulture", "a painted backdrop", "1", "Background, far", "shared with the cliffs, the next biome"],
        ["Basalt fin", "3.1 m wide, 4.3 m tall", "1", "Foreground", "kit: basalt fin (added below)"],
        ["Chalk overhang", "3 m by 4 m", "1", "Foreground", "new, this area only"],
    ],
    "effects": [
        "White dust blowing in through the opening on the wind, lit.",
        "Grit trickling from under the chockstone, and a puff of white dust when the next block lands.",
        "The frozen climber's long shadow, pointing back down the flue.",
        "The forge's rumble fades here and the wind takes over.",
    ],
    "notes": [
        "Note 64 (not built yet): the breakable stone is a proper cracked stone, breaks like stone, and comes back by a fresh block dropping from the roof.",
        "Course change, from note 64: the chockstone becomes a cracked block of chalk of the same size and wedge shape. Nothing else you touch moves or is added.",
        "The pillar, the walls of the gap and the rock under the sill are in the play space and can't be held. They are plainly dark and wet: black and glassy. Everything pale in the play space can be held.",
    ],
}

AREAS = [_HUT, _PRIMER, _PIEDRA, _GEMELOS, _FUELLE, _ESCORIA, _FRAGUA, _TIRO, _ALIENTO, _LUZ]

# Pieces that more than one area here uses and the biome's sheet does not list yet.
KIT_MORE = [
    ["Steam wheel: an iron paddle wheel in stone cheeks, kicked round by a steam nozzle. Three kinds: with a crank, with a cam, with a lifting peg", "2 m, 2.4 m, 3 m, 4.4 m", "what works the great bellows, the stepping bellows, the slag rakes and the drop hammers", "Background", "new"],
    ["Drive rod: a flat iron rod with an eye at each end", "1.7 to 13.4 m", "crank rods, coupling rods, rake handles", "Background", "new"],
    ["Wall jib: an iron post, arm and brace with a hook ring", "arm 2.2 to 3.9 m", "the hoists that carry the chains of Géiseres Gemelos and Escoria", "Background", "new"],
    ["Stair door: a stepped arch shut with an iron grille", "2 m wide, 3 m tall", "the smiths' way up, behind the loft's lip and the pier's head", "Background", "new, from the temple's stepped arch"],
    ["Floor kerb: a low lip of soot-black blocks", "0.9 m tall, in 4 m lengths", "the front edge of the forge floor", "Foreground", "new; a flat card today"],
    ["Basalt fin", "3 m wide, 4 to 5 m tall", "in front of the pillar, at El Último Aliento and La Luz", "Foreground", "new"],
]
