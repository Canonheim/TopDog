# The wind cliffs' areas, one dict each. Format: see ../build.py.
# Order: bottom to top. The tea cave (7.0) sits where you find it, between Desprendimiento and Los Burros.
# The last one is the join with the cableway at the low station.


# ------------------------------------------------------------------ shorthand
def _r(x0, y0, x1, y1, st=None):
    return ["rect", x0, y0, x1, y1] + ([{"style": st}] if st else [])


def _ln(x0, y0, x1, y1, st=None):
    return ["line", x0, y0, x1, y1] + ([{"style": st}] if st else [])


def _c(x, y, r, st=None):
    return ["circle", x, y, r] + ([{"style": st}] if st else [])


def _p(pts, st=None):
    return ["poly", [list(q) for q in pts]] + ([{"style": st}] if st else [])


def _flag(x, y, h, d):
    """A flag: a banded pole h tall standing at (x, y), its streamer blown d (+1 east, -1 west)."""
    return [_r(round(x - 0.08, 2), y, round(x + 0.08, 2), round(y + h, 2), "pale"),
            _ln(x, round(y + h - 0.15, 2), round(x + d * 0.8, 2), round(y + h - 0.05, 2), "line"),
            _ln(round(x + d * 0.8, 2), round(y + h - 0.05, 2), round(x + d * 1.5, 2), round(y + h - 0.4, 2), "line")]


def _wind(segs, d):
    """Wavy wind lines. segs: (x_from, x_to, y) for each line; d: +1 it blows east, -1 west."""
    out = []
    for k, (xa, xb, y) in enumerate(segs):
        a, b = min(xa, xb), max(xa, xb)
        x, up = a, (k % 2 == 0)
        while x < b - 0.3:
            xn = min(x + 1.6, b)
            out.append(_ln(round(x, 2), round(y + (0.22 if up else -0.22), 2), round(xn, 2), round(y + (-0.22 if up else 0.22), 2), "mark"))
            x, up = xn, not up
        tip = b if d > 0 else a
        out.append(_ln(tip, y, round(tip - d * 0.55, 2), round(y + 0.4, 2), "line"))
        out.append(_ln(tip, y, round(tip - d * 0.55, 2), round(y - 0.4, 2), "line"))
    return out


_SHOULDER_EDGE = [(570.0, -222.0), (585.0, -223.0), (600.0, -226.5), (615.0, -229.0), (630.0, -231.5),
                  (645.0, -235.0), (660.0, -238.5), (675.0, -241.0), (690.0, -243.5), (700.0, -245.5)]


def _sx(y):
    """The east edge of the mountain's shoulder at height y. It leans back with the face."""
    e = _SHOULDER_EDGE
    for (ya, xa), (yb, xb) in zip(e, e[1:]):
        if ya <= y <= yb:
            return xa + (xb - xa) * (y - ya) / (yb - ya)
    return e[0][1] if y < e[0][0] else e[-1][1]


def _shoulder(y0, y1, xl):
    """The mountain's shoulder where it crosses a window: one flat card, 12 m back, its edge cut in steps.
    Drawn as a dashed outline with its ledges, so that nothing standing in front of it is lost in the sketch."""
    pts, out, y, k = [(xl, y0)], [], y0, 0
    while y < y1 - 0.01:
        yn = min(y + 4.0, y1)
        x = round(_sx((y + yn) / 2) + (0.5 if k % 2 else -0.4), 2)
        pts += [(x, y), (x, yn)]
        if x - 3.0 > xl:
            out.append(_ln(round(x - 3.0, 2), y, x, y, "mark"))
        y, k = yn, k + 1
    pts.append((xl, y1))
    return [_p(pts, "mark")] + out


_SHOULDER_TEXT = ("The kit's flat cut-out card of the same cliff, 12 m back, hazed to a mid blue-grey, with ledges and one small dead tree "
                  "cut into its edge. It stands on the west of the frame only, so the face goes on behind you and never stops inside "
                  "the frame. East of its edge there is nothing of ours: sky, and the far view that is given. The sketch shows it as a dashed outline.")


def _nest(x, y, w=1.6):
    """A vulture's nest sitting on a ledge at (x, y)."""
    return _p([(x - w / 2, y), (x + w / 2, y), (round(x + w / 2 + 0.15, 2), y + 0.45), (round(x - w / 2 - 0.15, 2), y + 0.45)], "pale")


def _tp(s, off=0.0):
    """A point on the dead tree: s metres up the trunk from its root, off metres to its upper side."""
    return (round(-243.0 + 0.6 * s - 0.8 * off, 2), round(599.8 + 0.8 * s + 0.6 * off, 2))


def _roof_y(x):
    """The underside of La Cornisa at x."""
    return 626.2 + 0.1628 * (x + 204.0)


def _bp(s):
    """A point on the long brace of 7.10, s metres up it from its foot."""
    return (round(-229.0 - 6.8 * s / 12.176, 2), round(677.3 + 10.1 * s / 12.176, 2))


_WEST_NEST = [_nest(-241.6, 600.0), _c(-241.5, 600.62, 0.16, "light")]
_NEEDLES = [_p([(-236.2, 650.0), (-232.4, 650.0), (-232.0, 647.6), (-236.8, 648.6)]),
            _p([(-226.2, 652.2), (-222.4, 652.2), (-221.8, 645.4), (-226.8, 646.0)])]
_ARCH_TOP = [(-212.0, 645.6), (-212.0, 644.4), (-222.0, 645.4), (-222.0, 646.6), (-232.0, 647.6), (-232.0, 648.8), (-240.0, 649.6), (-245.0, 650.2)]
_RUBBLE = [_p([(-252.0, 658.8), (-249.2, 658.8), (-249.6, 660.0), (-250.6, 660.45), (-251.7, 660.2)]),
           _c(-250.5, 660.9, 0.5, "line"), _c(-249.5, 660.25, 0.45, "line")]
_SMOKE = [_ln(-241.8, 646.15, -241.55, 647.3, "mark"), _ln(-241.55, 647.3, -241.9, 648.6, "mark")]
_R7_NEST = [_nest(-205.0, 654.0, 1.3), _c(-206.2, 654.2, 0.2, "pale")]
_SOCK = [_r(-203.68, 664.0, -203.52, 666.4, "pale"), _p([(-203.6, 666.4), (-205.1, 666.2), (-205.1, 665.9), (-203.6, 665.9)], "pale")]
_STRUTS = [(-237.0, -236.5, 649.2), (-229.2, -226.5, 649.5), (-220.7, -222.2, 650.0), (-213.0, -211.3, 654.0)]   # post x at 663, foot x, foot y

# ------------------------------------------------------------------ 7.1 El Balcón
_CRACKS = [(579.4, 581.4), (583.0, 584.6), (586.3, 588.2)]
_HARD = [(581.4, 583.0), (584.6, 586.3)]

EL_BALCON = {
    "id": "7.1", "slug": "7_1_el_balcon", "title": "El Balcón", "kind": "challenge", "also": ["a6"],
    "window": [-235.5, 570.5, -201.0, 595.5], "screen": [-225.0, 580.3], "cut_y": 579.0, "climber": [-228.0, 578.0],
    "place": ("You come out of the mountain here. The chimney's crack ends at a door in the east face, and 2 m under it is El Balcón: one "
              "hard bed of chalk standing out of the cliff as a shelf 22 m long. It is the first open air since the station, and the first "
              "sight of the town, tiny in the valley below. The pack trail's drivers used the shelf as their yard. Everything for the "
              "cableway was unloaded here, and then hauled up the west face of the rock tower that stands on the shelf's east end, by a hoist "
              "of two lashed poles. The burros went up in slings. The hoist has fallen and the trail below the shelf is gone under the "
              "scree. What is left to climb is the tower's own rock: an upright joint in its west face that frost has opened in three "
              "lengths, with two hard beds between them where it is still shut. One climber got this far, sat down against the back wall "
              "to look at the town, and is still there. The wind starts here: a gust off the tower, shown by two flags."),
    "keep": [
        "The shelf, the door 2 m above its west end, and the walk east to the tower's foot.",
        "The three lengths of crack and the two blank lengths between them: reaches of 1.6, 1.7 and 1.8 m.",
        "The gust: it blows west, off the wall, for 1.5 seconds in every 5, from 9 m along the shelf to the tower.",
        "The slick lip under the tower, and the one shrub on the east lip, over the throat.",
    ],
    "background": [
        {"name": "The mountain's shoulder", "z": [-14.0, -12.0], "tag": [-229.0, 592.6],
         "text": _SHOULDER_TEXT,
         "draw": _shoulder(570.5, 595.5, -235.5)},
        {"name": "The shelf's back and its back wall", "z": [-4.2, -1.2], "tag": [-227.6, 584.6], "top": True,
         "text": "The shelf carries on 3 m behind you as floor, to a back wall of grey-tan cliff. The wall is tall by the door and comes "
                 "down in steps of one bed each to a low kerb, so the sky and the far view stay open behind most of the walk. The tops "
                 "of its steps are the same two hard beds that close the tower's crack: you can follow them across the whole picture.",
         "draw": [_p([(-235.5, 578.0), (-235.5, 595.5), (-231.0, 595.5), (-231.0, 590.0), (-229.0, 590.0), (-229.0, 586.3), (-226.6, 586.3),
                      (-226.6, 583.0), (-224.2, 583.0), (-224.2, 581.4), (-222.2, 581.4), (-222.2, 579.3), (-211.6, 579.3), (-211.6, 578.0)]),
                  _r(-229.0, 584.6, -226.6, 586.3, "pale"), _r(-226.6, 581.4, -224.2, 583.0, "pale")]},
        {"name": "The tower's body", "z": [-3.0, -1.5], "tag": [-203.3, 586.0],
         "text": "The tower you climb is the near edge of a bigger tower of grey-tan chalk that stands 1.5 m behind it and shows a "
                 "metre proud of it on both sides. It replaces today's flat tan card. The two hard beds run round it as two "
                 "darker bands that stand out as small ledges, with a nest's white streak under the upper one.",
         "draw": [_r(-211.6, 573.0, -202.6, 595.5)] + [_r(-211.6, y0, -202.6, y1, "pale") for y0, y1 in _HARD]},
        {"name": "The one who stopped to look", "z": [-2.6, -1.6], "style": "pale", "tag": [-223.3, 580.3], "top": True,
         "text": "The cliffs' frozen climber. He sits on the shelf's back floor with his back against the wall's lowest step, knees up, "
                 "facing the valley and the town. He is 1.6 m behind the walk, so you pass in front of him.",
         "draw": [_r(-223.7, 578.0, -223.0, 579.0), _c(-223.3, 579.2, 0.2)]},
        {"name": "The pug arrow", "z": [-1.5, -1.3], "style": "pale", "tag": [-226.5, 581.0],
         "text": "The trail's arrow sign, pointing east along the shelf. It stands where it does today, moved back out of the play space. The kit has it.",
         "draw": [_ln(-226.5, 578.0, -226.5, 579.4, "line"), _p([(-227.0, 579.4), (-226.2, 579.4), (-225.7, 579.75), (-226.2, 580.1), (-227.0, 580.1)])]},
        {"name": "The two flags", "z": [-1.6, -1.3], "tag": [-221.0, 582.0],
         "text": "One at each edge of the gust. The first is a pole 3 m tall at the back of the shelf, 9 m along it. The second is 2.2 m tall "
                 "and stands in the back corner of the alcove at the top of the crack. Each has a streamer 1.5 m long in the town's bunting "
                 "colours. When the gust comes both stream west, off the wall, and between gusts both hang slack.",
         "draw": _flag(-221.0, 578.0, 3.0, -1) + _flag(-209.5, 590.0, 2.2, -1)},
        {"name": "The fallen hoist", "z": [-3.8, -2.2], "style": "line", "tag": [-215.4, 579.9], "top": True,
         "text": "Lying at the tower's foot on the shelf's back floor: two poles 5.5 m long, still lashed together at the head, with the "
                 "pulley block on the lashing and no rope. Beside them is a stack of split planks that never went up. It says how "
                 "anything got up this wall, and that nothing does now.",
         "draw": [_ln(-218.4, 578.25, -212.9, 578.75), _ln(-218.2, 578.55, -212.9, 578.85), _c(-212.8, 578.95, 0.2), _r(-217.6, 578.0, -215.6, 578.2, "pale")]},
    ],
    "play": [
        {"name": "The crack's three lengths", "z": [-1.2, 1.2], "style": "line", "tag": [-209.2, 585.4],
         "text": "Each length is an open joint with lips of fresh white chalk, broken and matte. The two lengths between them are the hard "
                 "beds: shut tight, dark brown and rain-polished. The white tells you where a hand goes before you reach the wall.",
         "draw": [_ln(-210.15, y0, -210.15, y1) for y0, y1 in _CRACKS]},
        {"name": "The gust, drawn", "z": [-1.2, 1.2], "tag": [-215.5, 585.6],
         "text": "Notes 89 and 70. Long wavy white lines with an inked edge, across the gust's whole reach and nowhere else, moving west. They "
                 "start at the tower's face and stop at the first flag. A whistle comes one second before them.",
         "draw": _wind([(-221.0, -210.2, 580.4), (-221.0, -210.2, 584.0), (-221.0, -210.2, 587.6), (-221.0, -210.2, 590.9)], -1)},
        {"name": "The worn way", "z": [-0.4, 0.4], "style": "mark", "tag": [-217.5, 577.2],
         "text": "The shelf's top is dry white chalk, with a path trodden down its middle by the burros, from under the door to the foot "
                 "of the crack. It is drawn on the shelf and changes nothing you stand on.",
         "draw": [_ln(-230.0, 578.05, -210.4, 578.05)]},
        {"name": "The shrub", "z": [-0.3, 0.3], "style": "line", "tag": [-202.3, 576.6],
         "text": "The mercy. One dry shrub on the east lip, where it is today, with 0.5 m of root to catch. Below it is the whole mountain.",
         "draw": [_c(-203.7, 577.3, 0.3)]},
    ],
    "foreground": [
        {"name": "A chalk lip with a grass tuft", "z": [1.3, 2.2], "style": "dark", "tag": [-231.5, 573.0],
         "text": "At the bottom west corner, in front of solid rock and below the walk. Its top is under the door's sill.",
         "draw": [_p([(-235.5, 570.5), (-235.5, 579.2), (-233.0, 579.3), (-231.4, 577.0), (-229.6, 575.4), (-229.2, 572.8), (-228.6, 570.5)])]},
        {"name": "One trail post", "z": [1.25, 1.45], "tag": [-233.3, 583.0],
         "text": "A lashed pole 3 m tall standing on the lip beside the door, with a rag of bunting on it that tells you the wind before "
                 "you have reached the first flag. You pass behind it for one step as you come out of the door. It is the only thing on "
                 "the cliffs that stands in front of you where you walk.",
         "draw": [_r(-233.4, 579.3, -233.2, 582.3), _ln(-233.3, 582.1, -234.2, 581.7, "line")]},
    ],
    "explains": [
        ["The shelf", "One hard bed of chalk standing out of the face. The trail's unloading yard", "The same floor going back 3 m to its back wall, the fallen hoist, the stack of planks, the frozen climber"],
        ["The three lengths of crack", "An upright joint in the tower, opened by frost where the beds are soft", "The tower's body, with the joint running on up it"],
        ["The two blank lengths", "Two hard beds, where the joint is still shut", "The same two beds as bands round the tower's body and as the steps of the back wall"],
        ["The door", "The top of the chimney's crack, where the mountain's inside ends", "The tall end of the back wall, and the mountain's shoulder behind it"],
        ["The gust", "Wind coming round the tower", "A flag at each edge of it, and the rag on the trail post"],
        ["The shrub", "The last thing between you and the throat", "Nothing. Open sky and the valley"],
    ],
    "pieces": [
        ["The mountain's shoulder", "30 m wide, 25 m of its height", "1 section", "Background", "kit: the mountain's shoulder"],
        ["Cliff body: the shelf's back wall, in steps", "24 m long, 1.3 to 12 m tall", "3 sections", "Background", "kit: cliff body"],
        ["Cliff body: the tower", "9 m wide", "3 sections", "Background", "kit: cliff body, with hard beds (added below)"],
        ["Frozen climber, sitting", "1.2 m tall", "1", "Background", "kit: frozen climber, sitting"],
        ["Pug arrow sign", "1 m", "1", "Background", "kit: sign_pug_arrow"],
        ["Flag", "poles 3 m and 2.2 m", "2", "Background", "kit: flag (streamer_pole)"],
        ["Trail hoist, fallen; stack of split planks", "poles 5.5 m; stack 2 m", "1 and 1", "Background", "kit: trail hoist (added below); plank"],
        ["White lips for an open joint", "0.3 m wide; 2 m, 1.6 m and 1.9 m long", "3", "Play space (drawn on)", "new, small"],
        ["Dry shrub", "0.9 m", "1", "Play space", "kit: shrub_dry"],
        ["Chalk lip with a grass tuft", "7 m long", "1", "Foreground", "kit: chalk lip (added below); grass_tuft_dry"],
        ["Trail post with a rag of bunting", "0.2 m thick, 3 m tall", "1", "Foreground", "kit: trail post (added below)"],
    ],
    "effects": [
        "The gust's wavy lines, and the whistle one second before them (notes 89, 70).",
        "Grass tufts along the back wall's steps lean west in the gust and stand up again.",
        "The camera looks a little down along the shelf, so the town sits low in the frame, as the course has it.",
        "White dust blows out of the door behind you.",
    ],
    "notes": [
        "Note 89: the wind is drawn loudly. Wavy lines across the whole gust, and flags that stream.",
        "Note 70: the lines stop where the gust stops. There is no wind you cannot see.",
        "Scenery moved out of the play space, where it stands today: the first flag and the pug arrow go back behind the walk. Neither is something you touch.",
        "The second flag stands today 0.6 m west of the alcove's lip, on nothing. It moves 1.1 m east, to the alcove's back corner.",
        "Nothing you touch moves or is added.",
    ],
}

# ------------------------------------------------------------------ 7.2 Nidos
NIDOS = {
    "id": "7.2", "slug": "7_2_nidos", "title": "Nidos", "kind": "challenge",
    "window": [-246.0, 586.5, -204.5, 611.0], "screen": [-226.0, 598.5], "cut_y": 600.4, "climber": [-208.5, 590.0],
    "place": ("Under the arch, between the tower and the face, there is a bay of still air 28 m wide, and the vultures have it. Two "
              "ledges face each other across it: the alcove at the top of the tower's crack, and a deeper ledge on the face, 10 m "
              "higher, at the head of a slick slab. There is a nest on each, and the two birds fly one round between them, low on the "
              "way out and high on the way back, half a lap apart. Nobody built anything here. The trail went another way. The only way "
              "across is the way the birds go: you take one by its pale legs as it passes over the alcove's lip and let go when your feet "
              "brush the far ledge. The frog found the far nest first, and sits in it among the sticks."),
    "keep": [
        "The two vultures' round, their speed, and one passing every 8.4 seconds.",
        "The alcove's lip, where a bird passes 2 m over it, and the nest ledge, where it passes 2.1 m over.",
        "The slick slab under the nest ledge, which tips an early drop onto El Balcón.",
        "Only the legs can be held. The dark body cannot.",
    ],
    "background": [
        {"name": "The mountain's shoulder", "z": [-14.0, -12.0], "tag": [-231.5, 608.6],
         "text": _SHOULDER_TEXT + " Here it stands behind the west third of the bay, so a bird flies from sky into cliff and you can read how far it has gone.",
         "draw": _shoulder(586.5, 611.0, -246.0)},
        {"name": "The colony's cliff", "z": [-3.0, -1.5], "tag": [-233.6, 594.2], "top": True,
         "text": "The face's body, grey-tan, showing 1.5 m proud of the slick slab all the way down it, and carrying the nest ledge on "
                 "behind you as a deeper shelf. On it: three more nests on small ledges, each with a white streak under it, and a bone "
                 "pile. The slab you can touch has none of this on it. It stays dark and bare.",
         "draw": [_p([(-246.0, 586.5), (-228.6, 586.5), (-228.6, 590.4), (-236.6, 600.4), (-236.6, 605.2), (-237.4, 606.6), (-237.0, 611.0), (-246.0, 611.0)]),
                  _nest(-234.65, 596.9, 1.1), _nest(-231.55, 593.0, 1.1), _nest(-236.4, 599.1, 1.0),
                  _ln(-234.4, 596.8, -233.6, 595.3, "mark"), _ln(-231.3, 592.9, -230.5, 591.4, "mark")]},
        {"name": "The far nest, and the frog in it", "z": [-2.3, -1.3], "tag": [-240.6, 598.7], "top": True,
         "text": "The nest that is on the nest ledge today, 1.6 m across, moved back to the ledge's back half. The second of the cliffs' "
                 "two frogs sits in it among the sticks, 0.3 m tall, and looks up as a bird goes over (notes 68 and 60).",
         "draw": _WEST_NEST},
        {"name": "The tower's body", "z": [-3.0, -1.5], "tag": [-205.3, 600.0],
         "text": "The same body as on El Balcón's page, carried on up. A long white streak runs down it from the alcove.",
         "draw": [_r(-211.6, 586.5, -204.5, 611.0), _ln(-210.8, 589.8, -210.9, 586.6, "mark")]},
        {"name": "The near nest and the larder", "z": [-2.6, -1.3], "style": "pale", "tag": [-207.0, 592.6], "top": True,
         "text": "The alcove goes back 1.4 m further than you can walk. In that back part sit the round's other nest and the bone pile "
                 "that is in the alcove today. Today this nest hangs at the height of the alcove's roof, inside the rock. It comes down onto the floor.",
         "draw": [_nest(-207.3, 590.0, 1.4), _c(-208.6, 590.2, 0.22)]},
        {"name": "The flag in the alcove", "z": [-1.6, -1.3], "tag": [-209.5, 593.2],
         "text": "The second flag of El Balcón's gust. From here it tells you when the gust below has stopped.",
         "draw": _flag(-209.5, 590.0, 2.2, -1)},
    ],
    "play": [
        {"name": "The whitewashed lips", "z": [-1.2, 1.2], "style": "line", "tag": [-212.6, 589.4],
         "text": "Where a bird passes lowest over a ledge it has whitened the lip. There are two such marks: 1.1 m of the alcove's lip, "
                 "which is where you stand to take the legs, and 1.5 m of the nest ledge's lip, which is where you let go. They are "
                 "painted on ledges you can already hold.",
         "draw": [_ln(-210.0, 590.06, -208.9, 590.06), _ln(-239.6, 600.06, -238.1, 600.06)]},
        {"name": "The legs", "z": [-0.2, 0.2], "style": "pale", "tag": [-213.0, 592.4],
         "text": "A vulture flies with its legs hanging straight down, pale and bare, 0.5 m long: the only pale thing on it. Its body "
                 "and wings are dark. The kit's vulture is drawn at the course's size.",
         "draw": [_r(-211.14, 591.5, -210.86, 592.0)]},
        {"name": "The slab", "z": [-1.2, 1.2], "style": "mark", "tag": [-233.0, 592.0],
         "text": "Dark brown, rain-streaked and glossy from the nest ledge's lip to the bottom, with nothing pale on it. It reads as a slide, and it is one.",
         "draw": [_ln(-237.6, 599.3, -230.5, 590.4)]},
    ],
    "foreground": [
        {"name": "A chalk lip with a grass tuft", "z": [1.3, 2.2], "style": "dark", "tag": [-242.0, 588.2],
         "text": "At the bottom west corner, in front of the solid rock under the slab. Nothing stands in front of the bay.",
         "draw": [_p([(-246.0, 586.5), (-246.0, 590.2), (-242.5, 590.6), (-239.0, 589.8), (-235.5, 588.6), (-233.5, 586.5)])]},
    ],
    "explains": [
        ["The vulture's legs", "A bird on its round between its two nests", "A nest at each end of the round: one in the alcove's back, one on the far ledge"],
        ["The alcove's lip", "The birds' take-off ledge, whitened where they pass", "The alcove's back, with the near nest and the larder"],
        ["The nest ledge", "The colony's main ledge, at the head of the slab", "The same ledge going on back, the far nest with the frog in it, and the colony's cliff with three more nests"],
        ["The slick slab", "Rain-polished rock under the colony", "The body of the face, proud of it, with the nests' white streaks on the body and none on the slab"],
    ],
    "pieces": [
        ["The mountain's shoulder", "30 m wide, 25 m of its height", "1 section", "Background", "kit: the mountain's shoulder"],
        ["Cliff body: the colony's cliff, with small ledges", "17 m wide, 25 m tall", "3 sections", "Background", "kit: cliff body"],
        ["Cliff body: the tower", "9 m wide", "3 sections", "Background", "kit: cliff body"],
        ["Vulture", "2.6 m wingspan; legs 0.5 m", "2", "Play space", "kit: vulture"],
        ["Vulture's nest", "1.6 m, 1.4 m, and three of 1 to 1.2 m", "5", "Background", "kit: vulture_nest"],
        ["Bone pile", "1 m", "2", "Background", "kit: bone_pile"],
        ["The frog, in a nest", "0.3 m", "1", "Background", "kit: the frog"],
        ["Flag", "pole 2.2 m", "1", "Background", "kit: flag (streamer_pole). The same one as El Balcón's second"],
        ["Whitewash on a ledge's lip", "1.1 m and 1.5 m", "2", "Play space (drawn on)", "kit: whitewash (added below)"],
        ["Chalk lip with a grass tuft", "12 m long", "1", "Foreground", "kit: chalk lip (added below)"],
    ],
    "effects": [
        "A vulture's shadow crosses the slab just before the bird crosses the ledge.",
        "A feather or two turning in the still air under the arch.",
        "The frog croaks when you land on the nest ledge (note 60).",
    ],
    "notes": [
        "Note 68: the cliffs keep both frogs. This is the one in the vulture's nest.",
        "Note 76's law: what is drawn is what can be touched. The vulture's legs are drawn at exactly the size that is held, 0.28 m by 0.5 m.",
        "Scenery moved out of the play space, where it stands today: both nests and the bone pile go to the back of their ledges.",
        "Nothing you touch moves or is added.",
    ],
}

# ------------------------------------------------------------------ 7.3 Árbol Seco
_STUB_S = [(8.8 + 1.4 * i, 0.5 if i % 2 == 0 else -0.5) for i in range(8)]
_STUBS = [_tp(s, o) for s, o in _STUB_S]
_FAR_BOUGHS = [_ln(_tp(s, o * 0.7)[0], _tp(s, o * 0.7)[1], _tp(s + 0.9, o * 3.6)[0], _tp(s + 0.9, o * 3.6)[1]) for s, o in _STUB_S]
_CROWN = [_ln(-228.6, 619.0, x, y) for x, y in ((-231.0, 620.6), (-230.6, 622.4), (-229.3, 623.0), (-227.7, 622.9), (-226.3, 622.2))] + \
         [_ln(-230.0, 621.4, -230.9, 621.9), _ln(-229.0, 621.9, -228.5, 622.9), _ln(-227.9, 621.6, -227.0, 621.4)]

ARBOL_SECO = {
    "id": "7.3", "slug": "7_3_arbol_seco", "title": "Árbol Seco", "kind": "challenge",
    "window": [-247.0, 596.5, -217.5, 628.5], "screen": [-231.5, 612.5], "cut_y": 611.0, "climber": [-240.5, 600.0],
    "place": ("One tree grew on this face. It rooted at the back of the vultures' ledge and leaned out from under the arch to get at "
              "the light, 24 m of trunk, until its crown was level with the keyhole in the arch's hanging fin. Then lightning ran down "
              "it. The strike killed it and left a black, glassy scar along the middle of the trunk, and the weather has bleached the "
              "rest silver white. The branches broke off short. Eight stubs are left across the scar, side to side, and they are the "
              "only way past it. At the top the last of the crown is still on: two long branches, split at the join, that reach "
              "almost to the keyhole's sill. They are the two that snap."),
    "keep": [
        "The trunk's lean and its three lengths: 8 m you can hold, 11.5 m of scar you cannot, 4.5 m you can.",
        "The eight stubs, each where it is, 1.72 m apart.",
        "The two breaking branches: the same length, place and angle, giving way after 1.2 and 0.8 seconds. The keyhole's sill is 1.35 m from the tip.",
    ],
    "background": [
        {"name": "The mountain's shoulder", "z": [-14.0, -12.0], "tag": [-233.6, 623.5],
         "text": _SHOULDER_TEXT + " The white tree and its black scar both read against its mid blue-grey.",
         "draw": _shoulder(596.5, 628.5, -247.0)},
        {"name": "The fin's body", "z": [-3.0, -1.4], "tag": [-219.0, 620.0],
         "text": "The hanging fin with the keyhole in it is the near edge of a thicker fin of grey-tan chalk. The body closes the back of "
                 "the keyhole, so it reads as a doorway into rock and not as a window.",
         "draw": [_r(-223.6, 613.0, -219.4, 628.5)]},
        {"name": "The tree's far boughs", "z": [-2.4, -1.3], "style": "line", "tag": [-239.2, 610.6],
         "text": "A tree has branches all round it. Behind each stub you hold, a longer dead bough goes off into the scene from the far "
                 "side of the trunk, grey-white and duller than the stubs. The stubs are the near ones, broken short.",
         "draw": _FAR_BOUGHS},
        {"name": "The crown", "z": [-2.0, -1.3], "style": "line", "tag": [-230.9, 623.6], "top": True,
         "text": "The kit's dead crown, 5 m wide, at the top of the trunk, moved back out of the play space. It is a fan of dead boughs. "
                 "The two branches you hold are the two nearest of them, so they belong to the tree.",
         "draw": _CROWN},
        {"name": "The nest and its frog", "z": [-2.3, -1.3], "tag": [-241.6, 598.5],
         "text": "At the tree's foot, as on the page for Nidos. The tree's roots go into the rock beside the nest.",
         "draw": _WEST_NEST},
    ],
    "play": [
        {"name": "The two breaking branches", "z": [-0.2, 0.2], "style": "line", "tag": [-225.2, 620.2],
         "text": "Note 65. They are real branches of this tree: bleached white, tapering, with twigs, each joined to the wood below it. "
                 "Each wears the cliffs' breakable look: split along the grain at the join, with a strip of bark hanging. The first "
                 "is 2.9 m long and the second 2.3 m. A branch creaks and dips when you take it, and it goes in splinters and twigs.",
         "draw": [_ln(-228.6, 619.0, -226.5, 621.0), _ln(-226.2, 621.3, -224.7, 623.0), _ln(-227.7, 619.9, -227.9, 620.8),
                  _ln(-225.6, 622.0, -225.0, 622.1), _ln(-228.5, 619.3, -228.1, 619.1, "mark"), _ln(-226.2, 621.6, -225.8, 621.4, "mark")]},
        {"name": "The scar", "z": [-0.4, 0.4], "style": "mark", "tag": [-233.4, 609.7],
         "text": "Black and glassy, with a forked, jagged edge at both ends, so it is plainly lightning. A split runs up its middle.",
         "draw": [_ln(-238.2, 606.2, -231.3, 615.4)]},
        {"name": "The eight stubs", "z": [-0.3, 0.3], "style": "line", "tag": [-238.9, 608.0],
         "text": "Each is the broken root of a branch, bleached white, with a ring of pale splintered wood at its end. They stand out of the scar on alternate sides.",
         "draw": [_c(x, y, 0.3) for x, y in _STUBS]},
        {"name": "The roots", "z": [-1.2, 0.4], "style": "line", "tag": [-244.0, 601.5],
         "text": "At its foot the trunk spreads into three roots that grip the back of the ledge. They are drawn on the trunk's first metre.",
         "draw": [_ln(-243.0, 599.95, -241.9, 600.05), _ln(-243.0, 600.1, -243.0, 601.2)]},
    ],
    "foreground": [],
    "explains": [
        ["The trunk", "A dead tree that leaned out from under the arch for light", "Its crown, its far boughs, and its roots in the ledge"],
        ["The scar", "Where the lightning ran down it", "Nothing behind it. It is the darkest thing in a pale picture"],
        ["The eight stubs", "The near branches, broken short", "The far branches, still long, going off behind the trunk"],
        ["The two breaking branches", "The last two boughs of the crown, split at the join", "The rest of the crown, a fan of dead boughs, 1.3 m behind them"],
        ["The keyhole's sill", "A doorway in the arch's hanging fin", "The fin's body, which closes its back"],
    ],
    "pieces": [
        ["The mountain's shoulder", "30 m wide, 32 m of its height", "1 section", "Background", "kit: the mountain's shoulder"],
        ["Cliff body: the fin", "4.2 m wide, 19 m tall", "2 sections", "Background", "kit: cliff body"],
        ["Dead tree: the trunk with its scar and eight stubs", "24 m", "1", "Play space", "kit: dead_tree"],
        ["Dead tree's crown", "5 m wide, 4 m tall", "1", "Background", "kit: dead_tree_crown"],
        ["Far bough, dead", "1.5 to 3 m", "8", "Background", "new, cut from the kit's dead tree"],
        ["Breaking branch", "2.9 m and 2.3 m long, 0.2 m thick", "2", "Play space", "kit: breaking branch (note 65)"],
        ["Splintered ring for a stub's end; roots for the trunk's foot", "0.4 m; 1.2 m", "8 and 1", "Play space (drawn on)", "new, small"],
        ["Vulture's nest with the frog", "1.6 m", "1", "Background", "the same piece as on the page for Nidos"],
    ],
    "effects": [
        "A branch creaks and dips the moment you take it. Then it goes in splinters, with a puff of grey dust (note 65).",
        "The broken branch grows back out from its join after 8 seconds, as the note allows.",
        "A vulture passes under the trunk on its round, 4 m below the first stubs.",
    ],
    "notes": [
        "Note 65 (not built): the two breaking branches become real branches of this tree, look ready to snap, and break like wood.",
        "Scenery moved out of the play space, where it stands today: the crown goes back 0.5 m, behind the two branches.",
        "This area has no foreground. The air under the tree is where you read the fall onto El Balcón.",
        "Nothing you touch moves or is added.",
    ],
}

# ------------------------------------------------------------------ 7.4 Puente Roto
def _half(x):
    """One hanging half of the bridge, as the camera sees it: two side ropes 0.3 m apart, slats, the lowest board by one end."""
    out = [_ln(round(x - 0.15, 2), 623.7, round(x - 0.15, 2), 618.55), _ln(round(x + 0.15, 2), 623.7, round(x + 0.15, 2), 618.55)]
    for k, y in enumerate((623.2, 622.7, 622.2, 621.2, 620.7, 619.7, 619.2)):
        out.append(_ln(round(x - 0.15, 2), y, round(x + 0.15, 2), y))
    out.append(_ln(round(x - 0.6, 2), 618.25, round(x + 0.6, 2), 618.6))
    return out


PUENTE_ROTO = {
    "id": "7.4", "slug": "7_4_puente_roto", "title": "Puente Roto", "kind": "challenge",
    "window": [-229.0, 611.0, -202.5, 633.0], "screen": [-215.3, 622.0], "cut_y": 624.4, "climber": [-221.8, 624.0],
    "place": ("The pack trail crossed here. From the keyhole in the arch's hanging fin to the window in the tower there is a gap of "
              "10 m, with the arch for a roof and El Balcón 46 m below, and the drivers hung a rope bridge across it: a plank deck 1 m "
              "wide between two hand ropes, made fast to a pair of posts at each end. It is out. It parted in the middle, and each "
              "half fell back against its own wall, where it hangs now like a ladder with boards missing. The stubs of the deck are "
              "still on their bearers at both ends, and the back post of each pair still stands with its hand rope frayed off short. "
              "You go down the west half, swing it, and let go for the east half."),
    "keep": [
        "The keyhole's floor and sill, and the tower's window.",
        "The two stubs of deck, each 1.5 m.",
        "The two hanging halves: where each hangs, 5.3 m long, 7.1 m apart, and how they swing.",
        "The fling: 7.1 m, from the west half to the east half.",
    ],
    "background": [
        {"name": "The fin's body", "z": [-3.0, -1.4], "tag": [-221.5, 629.2],
         "text": "The body of the hanging fin, as on the page for Árbol Seco. It closes the back of the keyhole.",
         "draw": [_r(-223.6, 613.0, -219.4, 630.0)]},
        {"name": "The tower's body, and what is left in the window", "z": [-3.0, -1.3], "tag": [-207.6, 626.4], "top": True,
         "text": "The tower's body closes the back of the window, 1 m further back than you can walk. Against it: a stack of spare "
                 "deck boards and a pack saddle on a peg. Somebody meant to mend the bridge.",
         "draw": [_r(-211.6, 611.0, -202.6, 633.0), _r(-208.9, 624.0, -207.1, 624.5, "pale"), _c(-206.2, 625.3, 0.3, "line")]},
        {"name": "The west anchor", "z": [-1.7, -1.3], "style": "pale", "tag": [-221.0, 626.5], "top": True,
         "text": "The back post of the pair the bridge was made fast to: 1.6 m tall and 0.25 m thick, with the back hand rope still "
                 "knotted round it and frayed off after 0.6 m, like a tassel. Under the stub of deck is its back bearer, a pole out of "
                 "the rock with a strut under it. The front post of the pair is a stump: see the foreground.",
         "draw": [_r(-220.45, 624.0, -220.2, 625.6), _ln(-220.3, 625.4, -219.7, 625.0, "line"),
                  _r(-220.0, 623.45, -218.5, 623.62), _ln(-220.0, 622.2, -218.8, 623.45, "line")]},
        {"name": "The east anchor", "z": [-1.7, -1.3], "style": "pale", "tag": [-209.0, 626.5], "top": True,
         "text": "The same, at the tower's end: back post, frayed hand rope, bearer and strut.",
         "draw": [_r(-209.8, 624.0, -209.55, 625.6), _ln(-209.7, 625.4, -210.3, 625.0, "line"),
                  _r(-211.5, 623.45, -210.0, 623.62), _ln(-210.0, 622.2, -211.2, 623.45, "line")]},
        {"name": "Boards that fell", "z": [-1.7, -1.4], "style": "pale", "tag": [-212.6, 616.6],
         "text": "Two boards from the middle of the bridge, caught on the rock on their way down: one in a joint of the tower's body "
                 "and one on a ledge of the fin's body. Both are behind you and out of reach.",
         "draw": [_p([(-211.55, 617.7), (-210.4, 617.3), (-210.35, 617.45), (-211.5, 617.85)]), _p([(-223.55, 616.3), (-223.0, 616.7), (-223.05, 616.85), (-223.6, 616.45)])]},
        {"name": "La Cornisa's first flag", "z": [-1.6, -1.3], "tag": [-204.6, 626.8],
         "text": "At the back of the window's east mouth. You see it streaming east before you are across the bridge.",
         "draw": _flag(-204.6, 624.0, 2.0, 1)},
    ],
    "play": [
        {"name": "The west hanging half", "z": [-0.5, 0.5], "style": "line", "tag": [-217.2, 621.0],
         "text": "Note 66. Half a rope bridge, hanging down from the end of the stub: two side ropes with a ladder of boards between "
                 "them, three boards gone, and the lowest board hanging by one end. It hangs nearly edge on to the camera, so the two "
                 "ropes show 0.3 m apart. All of it is hemp and honey planks, and all of it can be held. Its length and where it "
                 "hangs are the course's.",
         "draw": _half(-218.55)},
        {"name": "The east hanging half", "z": [-0.5, 0.5], "style": "line", "tag": [-212.8, 621.0],
         "text": "The same, down the tower's wall. The board on its end is the one you catch.",
         "draw": _half(-211.45)},
        {"name": "The stubs' broken ends", "z": [-0.5, 0.5], "style": "mark", "tag": [-217.7, 624.7],
         "text": "Each stub of deck is three boards on its two bearers. The last board is snapped across, with splinters. Frayed "
                 "rope ends hang 0.3 m under it and sway.",
         "draw": [_ln(-218.5, 624.0, -218.5, 623.4), _ln(-211.5, 624.0, -211.5, 623.4)]},
    ],
    "foreground": [
        {"name": "Two post stumps", "z": [1.25, 1.5], "tag": [-220.3, 623.0], "top": True,
         "text": "The front post of each pair, snapped off 0.3 m above the floor when the bridge went. With the back posts they show you "
                 "that you are walking between the two posts of a bridge's end. They are too low to cover anything.",
         "draw": [_r(-220.45, 624.0, -220.2, 624.3), _r(-209.8, 624.0, -209.55, 624.3)]},
    ],
    "explains": [
        ["The two hanging halves", "A rope bridge that parted in the middle, each half fallen back against its wall", "The post it was made fast to, with the hand rope still knotted on"],
        ["The two stubs of deck", "The first boards of the bridge at each end", "Each stub's back bearer and its strut, out of the rock"],
        ["The keyhole", "The trail's way through the arch's fin", "The fin's body, closing its back"],
        ["The tower's window", "The trail's way into the tower", "The tower's body, with the spare boards and the saddle left against it"],
    ],
    "pieces": [
        ["Cliff body: the fin; the tower", "4.2 m wide; 9 m wide", "2 and 3 sections", "Background", "kit: cliff body"],
        ["Broken rope bridge, one hanging half", "5.3 m long, 1 m wide", "2", "Play space", "kit: broken rope bridge half (note 66)"],
        ["Bridge anchor: back post with a frayed hand rope", "1.6 m tall, 0.25 m thick", "2", "Background", "kit: bridge anchor"],
        ["Bridge anchor: front post, as a stump", "0.3 m tall, 0.25 m thick", "2", "Foreground", "kit: bridge anchor, cut short"],
        ["Bearer pole with a strut", "1.5 m", "2", "Background", "new, small"],
        ["Stub of deck with a snapped last board and frayed rope ends", "1.5 m", "2", "Play space", "kit: bridge anchor (the deck stub); plank"],
        ["Fallen board; stack of spare boards", "1.2 m; 1.8 m", "2 and 1", "Background", "kit: plank"],
        ["Pack saddle on a peg", "0.6 m", "1", "Background", "new, small"],
        ["Flag", "pole 2 m", "1", "Background", "kit: flag (streamer_pole). The same one as on the page for La Cornisa"],
    ],
    "effects": [
        "The frayed rope ends sway a little, always. There is no wind under the arch, so they never stream.",
        "A hanging half creaks on its knots when you put your weight on it.",
        "A board you kick loose falls a long time and you hear it land on El Balcón.",
    ],
    "notes": [
        "Note 66 (not built): this place looks like a rope bridge that is out and broken. It plays the same.",
        "Note 66 also says the swing should be judged again once the ropes swing properly (note 20). That still holds.",
        "Course change, a small one: what you can hold on each side becomes the whole hanging half, 0.3 m wide as the camera sees it, where today it is one rope. That brings the two halves 0.3 m nearer each other. The board on each rope's end is the same 1.2 m board.",
        "The two front posts are cut to stumps so that nothing stands in front of you at either end of the bridge.",
    ],
}

# ------------------------------------------------------------------ 7.5 La Cornisa
_ROOF = [(x, round(_roof_y(x) - 0.2, 2)) for x in (-203.0, -201.5, -200.0, -198.3, -196.8, -195.6)]
_PEGS = [(x, round(629.7 + 0.839 * (-195.0 - x), 2)) for x in (-196.3, -197.6, -198.9, -200.2, -201.5, -202.8)]

LA_CORNISA = {
    "id": "7.5", "slug": "7_5_la_cornisa", "title": "La Cornisa", "kind": "challenge",
    "window": [-213.0, 613.0, -187.0, 644.0], "screen": [-198.5, 627.5], "cut_y": 630.8, "climber": [-207.0, 624.0],
    "place": ("Out of the east mouth of the tower's window you are past the edge of El Balcón, and for the first time there is "
              "nothing under you but La Garganta. One hard bed of chalk juts 9 m east from the tower here, like the brim of a "
              "hat: La Cornisa. Its underside is a seam of flints, and the flints that hang lowest are the knobs you go along, hand over "
              "hand, while a crosswind blows out from the wall and swings your legs toward the valley. The trail's drivers did not go "
              "under it. They went over: they hammered a stair of iron pegs and plank treads up its sloping back, from its nose to the "
              "tunnel above. The treads are gone and the back row of pegs is bare. The front row is your way up. Just under "
              "the window's floor, where the tower's edge becomes the whole mountain's edge, a yellow sign sticks out over the drop."),
    "keep": [
        "The first knob in the window's mouth, the six knobs under the roof and the knob on the nose, each where it is.",
        "The six iron pegs up the back, and the slick slope between them.",
        "The crosswind: it blows out, east, for 2.2 seconds in every 4.5, with 0.8 seconds of warning.",
        "The drop: 47 m of air to the shrub, and then the throat.",
    ],
    "background": [
        {"name": "The tower's body", "z": [-3.0, -1.5], "tag": [-203.3, 617.0],
         "text": "The tower's body, showing a metre proud of its east face all the way down. Nothing else of ours stands on this side: "
                 "east of it is the sky and the far view.",
         "draw": [_r(-211.6, 613.0, -202.6, 644.0)]},
        {"name": "The cornice's body, and the flint seam", "z": [-3.0, -1.5], "tag": [-203.2, 639.6], "top": True,
         "text": "The cornice is the near edge of a thicker bed. Behind you its underside hangs 0.5 m lower than the roof you hold, "
                 "and the seam of flints runs along it: a row of grey knobs with the six white ones in front of them. Above the "
                 "sloping back it stands 2 m higher than the slope, as a step, and that step is where the trail's leavings are.",
         "draw": [_p([(-204.0, 625.7), (-195.4, 627.1), (-194.3, 628.2), (-194.2, 630.6), (-197.3, 634.6), (-200.6, 638.2), (-204.0, 641.0)])] +
                 [_c(x, round(_roof_y(x) - 0.3, 2), 0.16, "pale") for x in (-202.3, -200.8, -199.2, -197.5)]},
        {"name": "The stair's back row", "z": [-1.7, -1.3], "style": "pale", "tag": [-199.2, 635.2],
         "text": "Behind each iron peg is its twin, driven into the step, in dull brown rust. A plank tread lay across each pair. Two "
                 "treads are still on, broken short, and both are behind you. So the six pegs read as the front row of a stair, "
                 "and not as six pegs put there for a climber.",
         "draw": [_c(x, round(y + 0.4, 2), 0.12) for x, y in _PEGS] +
                 [_r(-199.25, 633.45, -198.55, 633.57), _r(-201.85, 635.63, -201.15, 635.75)]},
        {"name": "The warning sign", "z": [-1.6, -1.4], "style": "pale", "tag": [-200.6, 621.2], "top": True,
         "text": "Note 67. A yellow diamond 0.9 m across with a black exclamation mark and no words, hung on a rust-orange iron bracket that "
                 "sticks 1.2 m straight out from the tower's body, just under the window's floor. It is weathered and a little bent. "
                 "It swings and creaks in the crosswind. It is scenery, behind you.",
         "draw": [_ln(-202.6, 622.9, -201.4, 622.9, "line"), _ln(-201.6, 622.9, -201.6, 622.55, "line"),
                  _p([(-202.05, 622.1), (-201.6, 622.55), (-201.15, 622.1), (-201.6, 621.65)])]},
        {"name": "The two flags", "z": [-1.6, -1.3], "tag": [-193.6, 632.9],
         "text": "One at the back of the window's east mouth, 2 m tall. One on the body's step above the nose, 2.4 m tall. Both stream "
                 "east, out from the wall, when the crosswind blows.",
         "draw": _flag(-204.6, 624.0, 2.0, 1) + _flag(-195.6, 630.5, 2.4, 1)},
    ],
    "play": [
        {"name": "The knobs under the roof", "z": [-0.4, 0.4], "style": "line", "tag": [-199.2, 624.9],
         "text": "Flints in their white rind, each the size of two fists: the same knobs as in the crack you came out of the mountain "
                 "by. Dry, white and matte against the dark roof. The first one hangs in the window's mouth.",
         "draw": [_c(x, y, 0.3) for x, y in _ROOF] + [_r(-204.7, 625.95, -204.3, 626.45)]},
        {"name": "The nose", "z": [-1.2, 1.2], "style": "mark", "tag": [-193.3, 628.9],
         "text": "The cornice's tip is one great boss of white flint, 1.8 m across. It is how you get round from the underside to the back.",
         "draw": [_c(-195.2, 628.7, 1.0)]},
        {"name": "The six pegs", "z": [-0.4, 0.4], "style": "line", "tag": [-200.6, 632.4],
         "text": "Rust-orange iron, 0.4 m long, each with a square hammered head and a ring of white chalk dust where it was driven "
                 "in. The slope between them is dark brown and polished.",
         "draw": [_ln(x, y, round(x + 0.25, 2), round(y + 0.3, 2)) for x, y in _PEGS]},
        {"name": "The crosswind, drawn", "z": [-1.2, 1.2], "tag": [-191.4, 619.0],
         "text": "Notes 89 and 70. Long wavy white lines moving east, across the crosswind's whole reach: from the tower's face out to "
                 "4 m past the nose, under the cornice and over it. Where they curl and stop, the wind stops.",
         "draw": _wind([(-203.8, -190.0, 615.6), (-203.8, -190.0, 618.6), (-203.8, -190.0, 621.4), (-203.8, -190.0, 624.2),
                        (-193.6, -190.0, 628.6), (-196.4, -190.0, 632.6), (-201.4, -190.0, 637.4)], 1)},
    ],
    "foreground": [],
    "explains": [
        ["The knobs under the roof", "The lowest flints of a seam in the cornice's underside", "The rest of the seam: a row of grey flints along the body's underside, behind them"],
        ["The nose", "The seam's biggest flint, at the cornice's tip", "The body's nose behind it, with a flag on its step"],
        ["The six pegs", "The front row of the trail's peg stair up the cornice's back", "The back row of pegs in the body's step, and two broken treads"],
        ["The crosswind", "Wind pouring off the face and out over the throat", "A flag at the window's mouth and one over the nose, and the sign swinging"],
        ["The edge", "Where El Balcón stops catching you", "The warning sign, out over the drop"],
    ],
    "pieces": [
        ["Cliff body: the tower; the cornice, with a flint seam under it and a step on its back", "9 m wide; 10 m long, 15 m tall", "4 and 2 sections", "Background", "kit: cliff body"],
        ["Flint knob in a white rind", "0.4 m; the nose 1.8 m", "7 and 1", "Play space", "kit: flint knob (added below)"],
        ["Flint knob, grey", "0.3 m", "8", "Background", "kit: flint knob (added below)"],
        ["Iron peg", "0.4 m", "6", "Play space", "kit: iron peg"],
        ["Peg stub, dull rust; broken plank tread", "0.3 m; 0.7 m", "6 and 2", "Background", "kit: iron peg (peg stubs); plank"],
        ["Warning sign on an iron bracket", "diamond 0.9 m; bracket 1.2 m", "1", "Background", "kit: warning sign (note 67)"],
        ["Flag", "poles 2 m and 2.4 m", "2", "Background", "kit: flag (streamer_pole)"],
    ],
    "effects": [
        "The crosswind's wavy lines, and its whistle 0.8 seconds before (notes 89, 70).",
        "The sign creaks and swings on its bracket when the crosswind blows, and hangs still between (note 67).",
        "Chalk dust and one dead leaf go past you with each gust, out and down.",
        "At the window's mouth the camera pulls back and looks down, as the course has it, so the drop is on screen before you go out.",
    ],
    "notes": [
        "Note 67 (settled, not built): the warning sign, with only the mark on it. It is item 4 here.",
        "Note 89: wavy lines and streaming flags. Note 70: the lines fill the wind's whole reach and stop where it stops.",
        "Scenery moved out of the play space, where it stands today: both flags. The one on the nose stands today on the nose's own knob. It moves back onto the body's step.",
        "This area has no foreground. Everything in front of the cornice is open air, and the air is where you read the fall.",
        "Nothing you touch moves or is added.",
    ],
}

# ------------------------------------------------------------------ 7.6 Desprendimiento
_RAIL = [((-210.4, 641.3), (-216.5, 638.2)), ((-217.9, 637.4), (-222.6, 634.3)), ((-224.0, 633.9), (-228.7, 633.5))]
_TREADS = [(-229.2, 632.14), (-230.5, 633.05), (-231.8, 633.96), (-234.53, 638.47), (-235.83, 639.38), (-237.13, 640.29),
           (-239.87, 644.81), (-241.17, 645.72), (-242.47, 646.63)]


def _wall_top(x):
    """The height of the gully's far wall at x: it steps up toward the west."""
    prof = [(-200.0, 646.3)] + _ARCH_TOP + [(-262.0, 650.2)]
    for (xa, ya), (xb, yb) in zip(prof, prof[1:]):
        if xb < x <= xa:
            return round(ya + (yb - ya) * (xa - x) / (xa - xb), 2)
    return 650.2


def _wall(x0, x1, y0):
    """The gully's far wall (the arch's body) where it crosses a window from x0 to x1, down to y0."""
    return _p([(x0, y0), (x1, y0), (x1, _wall_top(x1))] + [q for q in _ARCH_TOP if x0 < q[0] < x1] + [(x0, _wall_top(x0))])


DESPRENDIMIENTO = {
    "id": "7.6", "slug": "7_6_desprendimiento", "title": "Desprendimiento", "kind": "challenge",
    "window": [-252.5, 628.5, -207.5, 662.0], "screen": [-228.0, 640.0], "cut_y": 641.5, "climber": [-209.3, 639.6],
    "place": ("The top of the arch is a gully, and the gully is where the mountain throws its loose rock away. Boulders gather in a "
              "rubble pile at the gully's head, come down three slick treads in waves of three, and go through El Ojo, the hole in the "
              "arch's crown, to El Balcón 52 m below. The trail had to cross this. The drivers built a rock fence along the east slope: "
              "leaning timber posts, a top rail, and rope netting to stop the small stuff. The boulders went through it. The netting is "
              "torn out, and the top rail hangs in three lengths from the posts. You cross hand over hand along those three lengths, with "
              "your feet in the boulders' road over the hole. Then you climb the gully itself, on the flints that stand out of each tread. "
              "Under each of the two lips the soft bed is worn back into a pocket. The drivers sat out the rockfalls in them, and so do you."),
    "keep": [
        "The three lengths of rail, each where it hangs, and the 1.5 m gaps between them.",
        "The gully: three treads, two lips, the nine knobs, the two pockets with their steps and their lips' noses.",
        "The boulders: waves of three every 9 seconds, a rumble 1.2 seconds before, down the roof, the treads and the hole.",
        "El Ojo. Whatever slides goes through it onto El Balcón.",
    ],
    "background": [
        {"name": "The mountain's shoulder", "z": [-14.0, -12.0], "tag": [-241.6, 656.5],
         "text": _SHOULDER_TEXT + " Here it shows above the gully's far wall, in the west of the frame.",
         "draw": _shoulder(628.5, 662.0, -252.5)},
        {"name": "The gully's far wall", "z": [-3.0, -1.5], "tag": [-219.0, 642.6], "top": True,
         "text": "The arch's body. Behind you it stands higher than the gully's bed all the way along: by 15 m at El Ojo, and by 3 m "
                 "at the gully's head. So the gully is a trough, and El Ojo reads as a well, not a window. It replaces today's flat "
                 "tan card. A paler grey band is rubbed along it 0.8 m above each tread: the line the boulders take, drawn before a boulder comes.",
         "draw": [_wall(-252.5, -207.5, 628.5), _ln(-243.9, 648.5, -239.0, 645.1, "mark"), _ln(-238.4, 642.2, -233.6, 638.8, "mark"),
                  _ln(-233.0, 635.7, -228.3, 632.4, "mark")]},
        {"name": "The two needles", "z": [-3.0, -1.3], "tag": [-234.3, 648.9],
         "text": "Two stalks of the cliff's body standing on the far wall. They carry the two burro ledges of Los Burros. Today each is a flat tan card.",
         "draw": _NEEDLES},
        {"name": "The rock fence's posts and netting", "z": [-1.8, -1.3], "style": "pale", "tag": [-213.6, 637.2], "top": True,
         "text": "Four timber posts stand on the slope behind you, leaning downhill, one at each end of each rail. Each rail hangs "
                 "from its posts by rope lashings. What is left of the rope netting hangs in two torn pieces under the first rail and "
                 "lies in a heap at the fence's foot. Over the hole there is none. The kit's fence frame is moved back to stand here.",
         "draw": [_p([(-210.55, 639.3), (-210.3, 639.3), (-210.15, 641.8), (-210.4, 641.8)]), _p([(-217.5, 634.8), (-217.25, 634.8), (-217.05, 638.3), (-217.3, 638.3)]),
                  _p([(-223.6, 630.9), (-223.35, 630.9), (-223.15, 634.6), (-223.4, 634.6)]), _p([(-229.2, 631.9), (-228.95, 631.9), (-228.75, 634.1), (-229.0, 634.1)]),
                  _ln(-211.0, 640.8, -213.4, 637.5, "mark"), _ln(-212.6, 640.0, -215.4, 636.2, "mark"), _ln(-214.4, 639.0, -216.6, 635.4, "mark")]},
        {"name": "Where the boulders start", "z": [-2.6, -1.3], "tag": [-248.3, 661.0],
         "text": "The kit's rubble pile, 3 m wide, on the roof over the gully's head, moved back out of the play space, with the next "
                 "three boulders sitting on it. Before each wave it shakes and a puff of dust comes off it.",
         "draw": _RUBBLE},
        {"name": "The driver's bench", "z": [-1.9, -1.3], "style": "pale", "tag": [-236.0, 636.2],
         "text": "The lower pocket goes back 0.7 m further than you can stand. At its back is a short plank on two iron pegs, where a "
                 "driver sat out a rockfall.",
         "draw": [_r(-234.9, 635.5, -233.9, 635.62), _ln(-234.7, 635.5, -234.7, 635.2, "line"), _ln(-234.1, 635.5, -234.1, 635.2, "line")]},
        {"name": "The tea cave's door", "z": [-1.45, -1.25], "style": "light", "tag": [-241.3, 642.5],
         "text": "At the back of the upper pocket: a doorway with a striped blanket tied back, and warm light on the pocket's floor. It "
                 "is the drivers' shelter, and it has its own page.",
         "draw": [_c(-240.1, 642.4, 0.25)]},
        {"name": "The tower's body", "z": [-3.0, -1.5], "tag": [-210.8, 648.0],
         "text": "At the east edge of the frame, closing the back of the stair tunnel you come out of.",
         "draw": [_r(-211.6, 628.5, -207.5, 662.0)]},
    ],
    "play": [
        {"name": "The rails' lashings", "z": [-0.3, 0.3], "style": "line", "tag": [-220.2, 637.6],
         "text": "Each rail is a round timber of the fence, honey coloured, 0.25 m thick, with a hemp lashing at each end where it hangs "
                 "from its post. The ends that face a gap are splintered. The three gaps are where a post's top was knocked off.",
         "draw": [_ln(round(x - 0.1, 2), round(y - 0.3, 2), round(x + 0.1, 2), round(y + 0.3, 2)) for pair in _RAIL for x, y in pair]},
        {"name": "The treads' knobs", "z": [-0.4, 0.4], "style": "line", "tag": [-230.2, 634.6],
         "text": "Flints in their white rind, standing out of the slick treads, three to a tread. The treads themselves are dark "
                 "brown and polished by the boulders, with dull grey scuffs and nothing white on them.",
         "draw": [_c(x, y, 0.3) for x, y in _TREADS]},
        {"name": "The two pockets", "z": [-1.2, 1.2], "style": "mark", "tag": [-236.2, 642.4],
         "text": "Each pocket has a floor and a step of dry white chalk, and the nose of the lip above it is a white knob. Their roofs and back walls stay dark.",
         "draw": [_ln(-235.0, 635.08, -233.1, 635.08), _ln(-240.3, 641.42, -238.5, 641.42)]},
    ],
    "foreground": [
        {"name": "A chalk lip with a grass tuft", "z": [1.3, 2.2], "style": "dark", "tag": [-249.3, 630.4],
         "text": "At the bottom west corner, in front of the solid rock of the face. Nothing stands in front of the gully or the hole.",
         "draw": [_p([(-252.5, 628.5), (-252.5, 632.2), (-249.0, 632.7), (-246.3, 631.3), (-244.8, 628.5)])]},
    ],
    "explains": [
        ["The three rails", "The top rail of the trail's rock fence, hanging in three lengths", "The fence's four leaning posts, and the torn netting under the first rail"],
        ["The gully's treads and lips", "The chute the mountain's loose rock comes down", "Its far wall, with the band the boulders have rubbed along it"],
        ["The knobs", "Flints standing out of the worn treads", "The same grey-tan chalk in the far wall"],
        ["The two pockets", "A soft bed worn back under each hard lip. The drivers' refuges", "The bench at the back of the lower one, and the tea cave's door at the back of the upper one"],
        ["The boulders", "The mountain's loose rock, on its way down", "The rubble pile at the gully's head, with the next three sitting on it"],
        ["El Ojo", "A hole worn through the arch's crown", "The far wall going down past it"],
    ],
    "pieces": [
        ["The mountain's shoulder", "30 m wide", "1 section", "Background", "kit: the mountain's shoulder"],
        ["Cliff body: the gully's far wall; the two needles; the tower", "45 m long, up to 22 m tall; 4 m wide; 9 m wide", "6, 2 and 4 sections", "Background", "kit: cliff body"],
        ["Rock fence: four leaning posts, torn netting", "posts 2.2 to 3.7 m tall; fence 19 m long", "1", "Background", "kit: rock_fence_frame"],
        ["Rock fence rail with rope lashings", "6.8 m, 5.6 m and 4.7 m long, 0.25 m thick", "3", "Play space", "kit: rock fence (the rails)"],
        ["Boulder; rubble pile", "1.1 m; 3 m", "3 at a time; 1", "Play space; background", "kit: boulder, rubble_pile"],
        ["Flint knob in a white rind", "0.4 m", "9 on the treads, 2 for the lips' noses", "Play space", "kit: flint knob (added below)"],
        ["Plank bench on two pegs", "1 m", "1", "Background", "kit: plank, iron peg"],
        ["Chalk lip with a grass tuft", "7 m long", "1", "Foreground", "kit: chalk lip (added below)"],
    ],
    "effects": [
        "Before each wave: a rumble, the rubble pile shakes, and a puff of dust comes off it. Then the boulders roll into view down the roof before they drop.",
        "Dust hangs in the gully after a wave, as the course has it.",
        "A boulder that goes through El Ojo is heard landing on El Balcón, a long time later.",
    ],
    "notes": [
        "No note from the playtest is about this challenge. The cliffs' sheet asks that the broken fence show the road the boulders take: it does, and the far wall's rubbed band repeats it.",
        "Scenery moved out of the play space, where it stands today: the fence's frame and the rubble pile.",
        "The start ledge, in the tower's stair tunnel, is just off the east edge of this picture, which is already 45 m wide.",
        "Nothing you touch moves or is added.",
    ],
}

# ------------------------------------------------------------------ 7.0 The tea cave
TEA_CAVE = {
    "id": "7.0", "slug": "7_0_the_tea_cave", "title": "The tea cave", "kind": "rest",
    "window": [-250.5, 636.5, -233.5, 651.0], "cut_y": 642.4, "climber": [-240.95, 641.37],
    "place": ("The drivers' shelter. When the trail worked, a burro driver caught on the gully by a rockfall got into the upper pocket "
              "and waited. Somebody got tired of waiting in the wind, and dug the pocket's back wall out into a room: 5 m wide, "
              "2.4 m tall, in the solid rock under the first burro's ledge. The drivers are gone. The frog lives in it now, and "
              "keeps a pot of tea going. It sits at a low table with a cup, and a second cup is set out for you. "
              "Outside is wind, falling rock and the whole mountain's drop. In here the wind's sound falls away, the light is amber "
              "from a small lantern and a brazier, and nothing can hurt you. The room is cut away at the front: floor, back wall and roof. "
              "It leads nowhere."),
    "keep": [
        "The upper pocket, its step, and the lip's nose above it: the route up the gully is the same.",
        "The boulders still jump the pocket. None can come into the room.",
        "The first burro's ledge above, and the rock between.",
        "The only new things you touch are the doorway and the room's floor, both from note 68.",
    ],
    "background": [
        {"name": "The gully's far wall", "z": [-3.0, -1.5], "tag": [-236.2, 646.6],
         "text": "The arch's body behind the gully, as on the page for Desprendimiento.",
         "draw": [_wall(-244.0, -233.5, 636.5)]},
        {"name": "The room", "z": [-3.4, -1.2], "style": "dark", "over": True, "top": True, "tag": [-246.2, 643.2],
         "text": "One snug room dug in the rock, 5 m wide, 2.4 m tall and 2.2 m deep behind the line you walk. Its walls are pale chalk "
                 "with the pick marks still on them, lit amber. The roof is black with smoke over the brazier.",
         "draw": [_r(-245.4, 641.37, -240.34, 643.8)]},
        {"name": "The rug and two cushions", "z": [-2.9, -1.4], "style": "pale", "over": True, "top": True, "tag": [-244.9, 640.6],
         "text": "A woven rug in the town's colours, 2.6 m long, on the back half of the floor, with a cushion at each end of it.",
         "draw": [_r(-244.6, 641.37, -242.0, 641.44), _r(-244.5, 641.44, -243.9, 641.64), _r(-242.7, 641.44, -242.1, 641.64)]},
        {"name": "The table, the pot and two cups", "z": [-2.4, -1.7], "style": "pale", "over": True, "tag": [-243.3, 642.6],
         "text": "A low table, 0.8 m wide, in the middle of the rug. On it are a pot that steams and two cups. The cup at the east "
                 "end, nearest the door, is yours.",
         "draw": [_r(-243.7, 641.44, -242.9, 641.8), _c(-243.3, 641.94, 0.13, "line"), _r(-243.62, 641.8, -243.5, 641.9), _r(-243.08, 641.8, -242.96, 641.9)]},
        {"name": "The frog", "z": [-2.3, -1.9], "style": "light", "over": True, "top": True, "tag": [-244.2, 642.4],
         "text": "0.3 m tall, sitting on the west cushion with its cup. It blinks at you, and now and then it sips (notes 68 and 60).",
         "draw": [_c(-244.2, 641.82, 0.16)]},
        {"name": "The shelf and the pegs", "z": [-3.4, -3.1], "style": "pale", "over": True, "tag": [-244.4, 643.4],
         "text": "On the back wall: a shelf cut into the rock with a row of tins and cups, and beside it three iron pegs with a pack "
                 "saddle and a folded burro blanket hanging on them. The pegs say whose room this was.",
         "draw": [_r(-245.2, 642.9, -243.6, 642.98), _r(-245.0, 642.98, -244.8, 643.2), _r(-244.6, 642.98, -244.4, 643.16), _r(-244.2, 642.98, -244.0, 643.2),
                  _c(-241.9, 643.1, 0.25, "line")]},
        {"name": "The brazier, the kettle and the crack", "z": [-2.6, -1.6], "style": "pale", "over": True, "tag": [-241.2, 640.6],
         "text": "A small iron brazier on three legs by the door, with a kettle on it and orange coals under. A thread of smoke goes "
                 "up into a crack in the roof. The crack comes out on the gully's top tread, between two knobs, and the smoke is "
                 "the first sign of the room that you see from outside.",
         "draw": [_r(-241.75, 641.37, -241.35, 641.75), _c(-241.55, 641.9, 0.13, "line"), _c(-241.55, 641.6, 0.08, "light"),
                  _ln(-241.55, 643.8, -241.8, 646.1, "mark")]},
        {"name": "The lantern", "z": [-3.2, -3.0], "style": "light", "over": True, "tag": [-242.9, 644.4],
         "text": "A small lantern on a peg under the roof at the back. With the brazier it is the only warm light on the cliffs.",
         "draw": [_c(-242.9, 643.45, 0.13)]},
        {"name": "The door blanket", "z": [-1.45, -1.25], "style": "pale", "over": True, "tag": [-240.6, 644.35],
         "text": "A striped burro blanket, hung as a door curtain and tied back to a peg on the far side of the doorway. From the "
                 "gully it is the one patch of bright colour in the rock, and it is how you find the door.",
         "draw": [_r(-240.5, 641.9, -240.36, 643.5)]},
    ],
    "play": [
        {"name": "The doorway", "z": [-1.2, 1.2], "style": "dark", "tag": [-239.7, 642.9],
         "text": "New, from note 68. The upper pocket's back wall is opened from floor to roof: a doorway 2.2 m tall. Its jambs "
                 "are dry white chalk.",
         "draw": [_r(-240.5, 641.37, -240.34, 643.57)]},
        {"name": "The room's floor", "z": [-1.2, 1.2], "style": "pale", "tag": [-246.2, 641.0],
         "text": "New, from note 68. 5 m of floor, level with the pocket's floor, in dry white chalk worn smooth. You walk in and stand anywhere on it.",
         "draw": [_r(-245.4, 641.17, -240.34, 641.37)]},
    ],
    "foreground": [
        {"name": "The cut edge", "z": [1.2, 1.5], "top": True, "tag": [-243.0, 640.2],
         "text": "A low lip of rock along the front edge of the floor, below the floor's top, to show that the room's front was "
                 "taken away. It covers nothing.",
         "draw": [_r(-245.6, 640.75, -240.2, 641.15)]},
    ],
    "explains": [
        ["The upper pocket", "The drivers' refuge from the rockfalls", "The doorway they dug out of its back wall, with a blanket tied back"],
        ["The doorway and the room's floor (new, note 68)", "The drivers' shelter", "The room: rug, cushions, table, pot, shelf, pegs, brazier, lantern"],
        ["The pocket's step and the lip's nose", "The way on up the gully, as it is today", "The gully's far wall"],
    ],
    "pieces": [
        ["The tea cave: floor, back wall and roof, front cut away", "5 m wide, 2.4 m tall, 4.6 m from its cut front to its back wall; doorway 2.2 m tall", "1", "Background and play space", "kit: the tea cave"],
        ["Low table, pot, two cups", "table 0.8 m", "1 set", "Background", "kit: the tea cave (its furniture)"],
        ["Woven rug; cushion", "2.6 m; 0.6 m", "1 and 2", "Background", "kit: the tea cave (its furniture)"],
        ["Shelf of tins and cups", "1.6 m", "1", "Background", "kit: the tea cave (its furniture)"],
        ["Brazier with a kettle; small lantern", "0.4 m; 0.25 m", "1 and 1", "Background", "kit: the tea cave (its furniture)"],
        ["The frog, with a cup", "0.3 m", "1", "Background", "kit: the frog"],
        ["Pack saddle and folded blanket on three pegs", "1 m", "1", "Background", "new, small; the saddle is the same piece as Puente Roto's"],
        ["Door blanket, tied back", "0.9 m wide, 1.6 m tall", "1", "Background", "new, from the burro's striped blanket"],
        ["Cut edge of rock", "5.4 m by 0.4 m", "1", "Foreground", "new, this area only"],
        ["Cliff body: the gully's far wall", "to suit", "2 sections", "Background", "kit: cliff body"],
    ],
    "effects": [
        "Steam from the pot, and the thread of smoke from the brazier into the crack and out on the tread above.",
        "Warm light on the pocket's floor outside the door.",
        "Inside, the wind's sound falls away. You hear the kettle, and the boulders going over as a far-off knocking.",
        "The frog croaks when you come within a screen of the door (note 60).",
    ],
    "notes": [
        "Note 68 (settled, not built): the little cave with a tea corner and a frog. The doorway is where the note's picture has the climber, in the upper pocket, and the room runs back into the rock the note circles.",
        "Note 68 also saw a pale block covered in dark patches in that rock. It is the first burro's ledge: the course gives the ledge a block of holdable rock 8 m deep, and it lies inside the dark rock of the face. The room is cut through both.",
        "Note 60: this is the cliffs' frog in a room. The second frog is in the vulture's nest (Nidos).",
        "Course change, from note 68: a doorway 2.2 m tall is cut through the upper pocket's back wall, and behind it are 5 m of new floor to stand on. Nothing else you touch moves.",
    ],
}

# ------------------------------------------------------------------ 7.7 Los Burros
_BURROS = [(-247.6, 647.6), (-233.3, 650.0), (-223.3, 652.2)]

LOS_BURROS = {
    "id": "7.7", "slug": "7_7_los_burros", "title": "Los Burros", "kind": "challenge",
    "window": [-252.0, 643.5, -208.5, 663.0], "screen": [-230.0, 652.5], "cut_y": 650.6, "climber": [-245.2, 647.6],
    "place": ("The last three burros of the pack trail. Each was swung up by the drivers' hoist, in a sling, to the ledge it "
              "stands on: one at the back of the ledge at the gully's head, and one on the top of each of two rock needles that stand "
              "out of the arch, with nothing but air round them. Each had a load for the cableway beside it. Then the trail failed "
              "under them, and nobody came back. They are still there, and they are in a bad mood: ears back, a hind leg cocked. "
              "Take hold of one and it kicks you east, up and over the gully, to the next. The third one kicks you onto the balcony of the "
              "tower's upper window. Above them all, the first painted timber of the cableway's scaffold comes down to stand on the "
              "needles, so you know where their loads were going."),
    "keep": [
        "The three burros, each where it stands, and each one's kick.",
        "The two needle ledges and the tower's balcony. Each kick lands 1.7 m short of the next burro.",
        "The first kick's low line, which passes under the roof over the gully's head.",
        "A miss lands in the gully or on the counter-slope, and goes through El Ojo.",
    ],
    "background": [
        {"name": "The mountain's shoulder", "z": [-14.0, -12.0], "tag": [-240.6, 660.6],
         "text": _SHOULDER_TEXT,
         "draw": _shoulder(643.5, 663.0, -252.0)},
        {"name": "The top of the gully's far wall", "z": [-3.0, -1.5], "tag": [-217.0, 644.4],
         "text": "The arch's body, along the bottom of the frame, as on the page for Desprendimiento.",
         "draw": [_wall(-252.0, -208.5, 643.5)]},
        {"name": "The two needles", "z": [-3.0, -1.3], "tag": [-234.4, 648.7], "top": True,
         "text": "Each burro ledge is the near edge of the flat top of a needle of grey-tan chalk, 4 m wide, that stands on the "
                 "arch's body. The top goes back 2 m behind the ledge you land on. Today each needle is a flat tan card.",
         "draw": _NEEDLES},
        {"name": "The three loads", "z": [-2.6, -1.4], "style": "pale", "tag": [-237.0, 651.4], "top": True,
         "text": "Behind each burro, on the back of its ledge, is the load it carried, and an iron hitching peg with a frayed end "
                 "of halter. Behind the first: four paint tins, two in the cableway's red and two in its yellow ochre. Behind "
                 "the second: a bundle of sawn posts, painted ochre. Behind the third: a coil of grey haul cable, 0.15 m thick. "
                 "They are the first things on the climb that belong to the cableway.",
         "draw": [_r(-249.2, 647.6, -248.85, 648.05), _r(-248.75, 647.6, -248.4, 648.05), _r(-235.7, 650.0, -233.9, 650.4),
                  _c(-225.2, 652.65, 0.45, "line"), _ln(-246.6, 647.6, -246.6, 648.3, "line"), _ln(-232.9, 650.0, -232.9, 650.7, "line"),
                  _ln(-222.9, 652.2, -222.9, 652.9, "line")]},
        {"name": "The standing hoist", "z": [-2.8, -2.0], "style": "line", "tag": [-218.3, 658.4],
         "text": "On the back of the tower's balcony, at its west end: the same hoist as the one that lies on El Balcón, still "
                 "standing. Two lashed poles lean out west over the gap, toward the second needle, with a pulley block at the head "
                 "and no rope. It is how a burro got onto a needle.",
         "draw": [_ln(-215.6, 654.0, -217.4, 657.8), _ln(-215.0, 654.0, -217.4, 657.8), _c(-217.5, 657.55, 0.2)]},
        {"name": "The scaffold's feet", "z": [-2.6, -1.4], "style": "line", "tag": [-229.0, 659.6],
         "text": "The low station's scaffold starts 9 m overhead. Its four legs come down to the rock here as raking struts, "
                 "0.3 m square, painted yellow ochre, each ending in an iron shoe: one into the side of the first needle, two into "
                 "the sides of the second, one onto the back of the tower's balcony. The three on the needles meet the rock under "
                 "the ledges, so nothing stands on a ledge you land on. Today the scaffold stops at its lowest walkway and stands on air.",
         "draw": [_ln(xp, 663.0, xf, yf) for xp, xf, yf in _STRUTS]},
        {"name": "Smoke from the tea cave", "z": [-1.5, -1.3], "tag": [-242.6, 648.2],
         "text": "A thread of smoke rising from a crack in the gully's top tread, just east of the first burro's ledge.",
         "draw": _SMOKE},
        {"name": "Where the boulders start", "z": [-2.6, -1.3], "tag": [-248.3, 661.0],
         "text": "The rubble pile on the roof over the first burro, as on the page for Desprendimiento.",
         "draw": _RUBBLE},
    ],
    "play": [
        {"name": "The burros", "z": [-0.4, 0.4], "style": "line", "tag": [-231.4, 651.9],
         "text": "Each stands facing west with its ears flat back and its near hind leg cocked, so it reads as a kick waiting to "
                 "happen. By the law of note 76, the burro that is drawn is the burro you can touch: head, neck, barrel with "
                 "its striped blanket, four legs. Today only the barrel and two legs are solid.",
         "draw": [_ln(round(x - 0.65, 2), round(y + 1.05, 2), round(x - 1.1, 2), round(y + 1.55, 2)) for x, y in _BURROS] +
                 [_c(round(x - 1.2, 2), round(y + 1.6, 2), 0.18) for x, y in _BURROS]},
        {"name": "Straw", "z": [-0.6, 0.6], "style": "mark", "tag": [-227.4, 651.7],
         "text": "On each ledge's west end, and on the balcony, a scatter of dry straw from the burro's feed lies exactly where a "
                 "kick lands you. It is drawn on the ledge and changes nothing you stand on.",
         "draw": [_ln(-235.7, 650.06, -234.2, 650.06), _ln(-225.7, 652.26, -224.2, 652.26), _ln(-214.1, 654.06, -212.6, 654.06)]},
    ],
    "foreground": [],
    "explains": [
        ["The three burros", "The trail's last pack animals, left on the ledges the hoist put them on", "Each one's load and its hitching peg, on the back of its ledge"],
        ["The two needle ledges", "The flat tops of two rock needles", "The needles' bodies, going down to the arch, with the scaffold's struts footed in their sides"],
        ["The ledge at the gully's head", "The first burro's stall", "Paint tins behind it, the rubble pile on the roof above, and the tea cave's smoke beside it"],
        ["The tower's balcony", "Where the hoist stood that swung each burro out to its ledge", "The hoist, still standing at the balcony's back, and the scaffold's east leg coming down beside it"],
    ],
    "pieces": [
        ["The mountain's shoulder", "30 m wide", "1 section", "Background", "kit: the mountain's shoulder"],
        ["Cliff body: the two needles; the top of the gully's far wall", "4 m wide, 2 to 7 m showing; 43 m long", "2 and 6 sections", "Background", "kit: cliff body"],
        ["Burro with a striped blanket", "1.8 m long", "3", "Play space", "kit: burro"],
        ["Burro load: paint tins; bundle of ochre posts; coil of haul cable", "0.4 m each; 1.8 m; 0.9 m", "4; 1; 1", "Background", "kit: burro load (added below)"],
        ["Hitching peg with a frayed halter end", "0.7 m", "3", "Background", "kit: burro load (added below); iron peg"],
        ["Trail hoist, standing", "poles 4.3 m", "1", "Background", "kit: trail hoist (added below)"],
        ["Scaffold strut with an iron shoe", "0.3 m square, 9 to 14 m", "4", "Background", "kit: scaffold strut (added below)"],
        ["Straw scatter", "1.5 m", "3", "Play space (drawn on)", "new, paint only"],
        ["Rubble pile", "3 m", "1", "Background", "kit: rubble_pile. The same one as Desprendimiento's"],
    ],
    "effects": [
        "A burro flicks an ear and stamps when you come within 3 m of it.",
        "The kick: a bray, a puff of dust and straw, and you are in the air.",
        "The boulders go on coming down the gully underneath you the whole time.",
    ],
    "notes": [
        "No note from the playtest is about this challenge. Note 68's tea cave is under the first burro's ledge and has its own page.",
        "Note 76's law, what is drawn is what can be touched: the kit's burro is 1.8 m long and the solid shape the course gives it is 1.3 m. The two are made to agree, either way. If the head and neck become solid, that is a small course change: 0.5 m more burro to take hold of on its west side.",
        "The burros are in the play space and can be held. So can everything else in it. The loads, the pegs and the hoist are all on the backs of the ledges, behind you.",
        "This area has no foreground. Every kick flies through open air.",
    ],
    "ask": [
        "The scaffold needs something to stand on. May its four legs come down behind this challenge, as struts onto the two needles and the balcony? Yes, or keep the sky here clear and hang the scaffold off the face instead.",
    ],
}

# ------------------------------------------------------------------ 7.8 Viento a Favor
VIENTO_A_FAVOR = {
    "id": "7.8", "slug": "7_8_viento_a_favor", "title": "Viento a Favor", "kind": "challenge", "also": ["a8"],
    "window": [-211.0, 645.0, -170.0, 675.5], "screen": [-193.0, 659.5], "cut_y": 654.6, "climber": [-207.0, 654.0],
    "place": ("Everything here is east of the tower and over La Garganta. From the tower's upper window the trail's pegs once "
              "went on up the east face to a porch 10 m higher. They have all pulled out, and one plank is left sticking out of the "
              "window's mouth. 19 m out in the air stands El Cuerno, a lone horn of chalk on a stalk that comes up out of the throat, "
              "with 3 m of flat top and a dead snag on it. A third vulture has a nest on the horn and a nest in the window, and beats "
              "back and forth between them. So the way to the porch is there and back. Out on the bird. Up the snag: its stub, then "
              "a knot, then the end of its one bough. And back on the wind: every 7 seconds a gust comes off El Colmillo, the fang on "
              "the far side of the throat, and blows toward the tower. Let go of the bough as it starts and it carries you home. "
              "A wind sock on the porch shows you where home is."),
    "keep": [
        "The perch plank, the vulture's road and its one second of hovering at each end.",
        "The horn's flat top, and the snag's three holds: the stub, the knot, the bough's end 5.6 m over the top.",
        "The porch: 17.9 m back to the west and 4.4 m higher than the bough.",
        "The tail gust: toward the tower for 2.5 seconds in every 7, with a whistle one second before.",
        "The cableway's two pylon legs overhead, which stop a throw that goes too high. They are biome 8's.",
        "The puzzle, exactly as it is (note 69).",
    ],
    "background": [
        {"name": "The tower's body", "z": [-3.0, -1.5], "tag": [-203.3, 648.6],
         "text": "The tower's body, a metre proud of its east face. It closes the backs of the upper window and of the porch.",
         "draw": [_r(-211.0, 645.0, -202.6, 675.5)]},
        {"name": "Peg stubs up the east face", "z": [-1.6, -1.4], "style": "pale", "tag": [-201.6, 659.6],
         "text": "Up the body's east edge, from the plank to the porch: seven stubs of iron peg in dull brown rust, each snapped off "
                 "short, 1.4 m apart. They are the trail's way to the porch, gone. They show that the porch is where you are meant "
                 "to get to, and that there is no climbing to it.",
         "draw": [_r(-203.3, y, -202.9, round(y + 0.12, 2)) for y in (655.4, 656.8, 658.2, 659.6, 661.0, 662.4)] + [_r(-203.3, 654.2, -202.9, 654.32)]},
        {"name": "The window's nest", "z": [-2.6, -1.3], "style": "pale", "tag": [-205.6, 655.4], "top": True,
         "text": "One end of the third vulture's round: a nest and a bone pile in the back of the upper window's east mouth, "
                 "1 m further back than you can walk.",
         "draw": _R7_NEST},
        {"name": "The horn's stalk, and the horn's nest", "z": [-3.0, -1.5], "tag": [-183.5, 649.0], "top": True,
         "text": "The horn is the near edge of a stalk of grey-tan chalk that comes up from the throat, wider at the bottom. It is "
                 "the one thing of ours that stands east of the tower. On the back of its top is the round's other nest, with a "
                 "white streak down the stalk under it.",
         "draw": [_p([(-185.7, 653.6), (-181.3, 653.6), (-180.5, 645.0), (-186.7, 645.0)]), _nest(-184.3, 654.0, 1.2), _ln(-184.6, 653.5, -184.9, 650.6, "mark")]},
        {"name": "The snag's trunk", "z": [-2.4, -1.3], "style": "line", "tag": [-181.8, 659.4], "top": True,
         "text": "Above the stub the snag's trunk leans back, away from you, out of the play space, and goes on up to 6.4 m, grey-white. "
                 "The knot is a branch stub that points at the camera out of it. The bough comes forward from it and ends at the "
                 "camera, so what you hold is its end. Today the knot and the bough's end hang in the air with nothing drawn between them.",
         "draw": [_ln(-182.7, 656.7, -183.2, 658.0), _ln(-183.2, 658.0, -183.9, 659.4), _ln(-183.9, 659.4, -184.0, 660.4)]},
        {"name": "The wind sock on the porch", "z": [-1.6, -1.3], "tag": [-204.9, 667.2], "top": True,
         "text": "On a post at the back of the porch: a sock 1.5 m long in red and white bands. In the gust it fills and points "
                 "west, into the porch. Between gusts it hangs. It is the brightest thing on the tower, so your eye goes to "
                 "the porch from the horn. It stands where one of today's three flags is.",
         "draw": _SOCK},
        {"name": "Two flags", "z": [-1.6, -1.3], "tag": [-203.4, 657.4],
         "text": "One 2.4 m tall at the back of the window's mouth. One 1.6 m tall on the back of the horn's top, at its west end, "
                 "clear of the snag and of the place where the vulture hovers. Both stream west in the gust.",
         "draw": _flag(-203.4, 654.0, 2.4, -1) + _flag(-184.8, 654.0, 1.6, -1)},
    ],
    "play": [
        {"name": "The snag", "z": [-0.3, 0.3], "style": "line", "tag": [-186.0, 658.9],
         "text": "The kit's snag, from the dead tree: bleached silver white, with a strip of bark on the stub. The knot is a round "
                 "of pale end grain 0.4 m across. The bough's end is a bigger one, 0.5 m across, worn smooth.",
         "draw": [_c(-183.6, 658.2, 0.3), _c(-184.7, 659.6, 0.36), _ln(-182.55, 654.2, -182.8, 656.5, "mark")]},
        {"name": "The tail gust, drawn", "z": [-1.2, 1.2], "tag": [-176.0, 663.6],
         "text": "Notes 70 and 89. Long wavy white lines moving west, across the whole gap: they peel off the face of El Colmillo and "
                 "run to the tower. Today the wind stops in mid air 5 m east of the horn. Its east edge moves 4.8 m, to the fang's "
                 "face, so there is no strip of still air. In the second of warning, a front of lines crosses from the fang first.",
         "draw": _wind([(-180.9, -172.2, 648.0), (-203.3, -186.9, 648.0), (-180.6, -172.2, 651.6), (-203.3, -186.4, 651.6),
                        (-201.0, -172.2, 662.0), (-203.3, -172.2, 667.4), (-203.8, -172.2, 671.6)], -1)},
        {"name": "The perch plank", "z": [-0.5, 0.5], "style": "mark", "tag": [-201.6, 653.2],
         "text": "One honey plank, 1.1 m, sticking out of the window's mouth on a pole bearer, with a rope lashing. It is the first "
                 "tread of the trail's way round the tower, and the only one left.",
         "draw": [_ln(-203.9, 653.9, -202.8, 653.9)]},
    ],
    "foreground": [],
    "explains": [
        ["The perch plank", "The first tread of the trail's way up to the porch", "The line of snapped peg stubs up the tower's body, from the plank to the porch"],
        ["The vulture's legs", "A bird beating between its two nests", "A nest in the window's back and a nest on the horn's back"],
        ["The horn", "A lone stack of chalk, standing up out of the throat", "Its stalk, going down out of the frame"],
        ["The stub, the knot and the bough's end", "The near parts of a dead snag", "The snag's trunk, leaning back behind them and going on up"],
        ["The tail gust", "Wind coming off the fang and across the throat", "The sock on the porch, a flag in the window, a flag on the horn"],
        ["The porch", "The trail's next ledge, and the only way on", "The wind sock at its back, and the tower's body"],
    ],
    "pieces": [
        ["Cliff body: the tower; the horn's stalk", "9 m wide; 4.4 m wide at the top", "4 sections; 1 stalk", "Background", "kit: cliff body"],
        ["Vulture", "2.6 m wingspan", "1", "Play space", "kit: vulture"],
        ["Vulture's nest; bone pile", "1.3 m and 1.2 m; 1 m", "2 and 1", "Background", "kit: vulture_nest, bone_pile"],
        ["Snag: stub, knot, bough's end; and its trunk behind", "5.6 m to the bough; trunk 6.4 m", "1", "Play space; the trunk behind", "kit: snag"],
        ["Peg stub, dull rust", "0.3 m", "7", "Background", "kit: iron peg (peg stubs)"],
        ["Wind sock on a post", "post 2.4 m; sock 1.5 m", "1", "Background", "kit: wind_sock"],
        ["Flag", "poles 2.4 m and 1.6 m", "2", "Background", "kit: flag (streamer_pole)"],
        ["Perch plank on a pole bearer", "1.1 m", "1", "Play space", "kit: plank"],
    ],
    "effects": [
        "The tail gust's wavy lines from the fang to the tower, the whistle one second before, and in that second a front of lines that crosses first (notes 70, 89).",
        "Feathers and chalk dust carried west in the gust.",
        "The camera is pulled back for the whole of this challenge, as the course has it: plank, bird, horn and porch are all on screen at once.",
    ],
    "notes": [
        "Note 69 (answered): the puzzle stays as designed. Out by vulture, up the snag, back on the tail wind.",
        "Note 69 listed ways to make it readable and planned none. Two of them are in the cliffs' sheet and so are here: the porch is marked, by the wind sock, and the gust is drawn as help, by lines that blow from the horn toward the porch. A frozen climber on the bough is not added.",
        "Note 70 (one number): the tail wind's east edge moves from x -177 to the fang's face at x -172.2. Its strength, rhythm and whistle stay.",
        "Note 89: wavy lines and things that stream.",
        "Scenery moved out of the play space, where it stands today: the three flags. The one on the porch becomes the wind sock. The one on the horn stands today 0.1 m from the snag's stub. It moves 2.5 m west and is 1.6 m tall.",
        "The snag's trunk above the stub is behind the play space, so nothing new is solid near the bough you spin on. Nothing you touch moves or is added.",
    ],
}

# ------------------------------------------------------------------ 7.9 Chimenea de Roca
_EAST_BANDS = [665.75, 668.2, 670.7]
_WEST_BANDS = [666.8, 669.4]

CHIMENEA_DE_ROCA = {
    "id": "7.9", "slug": "7_9_chimenea_de_roca", "title": "Chimenea de Roca", "kind": "challenge", "also": ["a8"],
    "window": [-214.5, 652.0, -199.5, 679.0], "cut_y": 668.4, "climber": [-204.6, 664.0],
    "place": ("The top of the tower is split. An upright joint runs through it from west to east, and the east half has slipped down "
              "along the joint by a little over a metre, leaving a chimney 2.2 m wide between two fins of rock. Rain runs down both "
              "walls, so they are dark and polished. But the tower is made of level beds, and its three hardest beds stand out of "
              "each wall as a white band 0.4 m tall. Because the east half has slipped, the same bed is a metre lower on the east "
              "wall than on the west, and the bands come in turn: east, west, east, west, east. You go up wall to wall. The chimney "
              "has no floor. Under it the shaft drops 10 m into the upper window. At the top you come out on the west fin, and the "
              "first painted timber of the cableway is standing on it."),
    "keep": [
        "The two walls, 2.2 m apart, and the five bands, each where it is.",
        "The tooth over the porch's inner end, with the first band on it.",
        "Five lunges of 2.2 m across and 1.0 to 1.4 m up. No floor: a fall goes down the shaft into the upper window.",
        "The west fin's top, where you come out.",
    ],
    "background": [
        {"name": "The tower's body", "z": [-3.0, -1.5], "tag": [-203.3, 660.6],
         "text": "The tower's body, a metre proud of the tower on both sides, with the east fin's peak standing behind the peak you see.",
         "draw": [_r(-211.6, 652.0, -202.6, 674.3), _p([(-206.4, 674.3), (-203.4, 674.3), (-204.5, 677.4)])]},
        {"name": "The split's back wall", "z": [-1.8, -1.3], "tag": [-207.1, 673.4], "top": True,
         "text": "The chimney's back wall, 1.3 m behind you, is where you see what happened to the tower. The joint runs up its "
                 "middle as a dark line. The three hard beds cross it as three pale bands, and each band steps down by a metre at "
                 "the joint. Every band you hold is the end of one of these.",
         "draw": [_r(-208.2, 658.0, -206.0, 676.0)] + [_r(-208.2, y, -207.1, y + 0.4, "pale") for y in _WEST_BANDS + [671.9]] +
                 [_r(-207.1, y, -206.0, y + 0.4, "pale") for y in _EAST_BANDS] + [_ln(-207.1, 658.0, -207.1, 676.0, "mark")]},
        {"name": "The pylon head, over the fin", "z": [-2.4, -1.3], "style": "line", "tag": [-212.4, 678.0],
         "text": "On the west fin's top stands the cableway's low pylon head: a frame of red painted timber with two sheaves on it. "
                 "From the chimney you see its top over the fin, with the sky behind. It is drawn on the page for La Estación Baja.",
         "draw": [_r(-214.5, 672.0, -208.4, 676.3), _c(-213.4, 676.9, 0.6), _c(-211.0, 676.9, 0.6)]},
        {"name": "Seen from here", "z": [-2.6, -1.3], "style": "pale", "tag": [-206.4, 655.6],
         "text": "Below, in the upper window: the vulture's nest and the flag. Beside you, on the porch: the wind sock. All three "
                 "are on the page for Viento a Favor.",
         "draw": _R7_NEST + _flag(-203.4, 654.0, 2.4, -1) + _SOCK},
    ],
    "play": [
        {"name": "The five bands", "z": [-1.2, 1.2], "style": "line", "tag": [-209.3, 668.3],
         "text": "Each band is the edge of a hard bed: dry white chalk, standing 0.24 m out of the dark wall, with a flat top and a "
                 "row of small flints under it. They are the only pale things in the chimney.",
         "draw": [_r(-206.24, y, -205.76, y + 0.45) for y in _EAST_BANDS] + [_r(-208.44, y, -207.96, y + 0.4) for y in _WEST_BANDS]},
        {"name": "The walls", "z": [-1.2, 1.2], "style": "mark", "tag": [-209.0, 662.0],
         "text": "Dark brown, rain-streaked and glossy, with the streaks running straight down. Nothing pale is drawn on them between the bands.",
         "draw": [_ln(-208.3, 671.6, -208.3, 658.2), _ln(-205.9, 673.8, -205.9, 668.8)]},
        {"name": "The west fin's top", "z": [-1.2, 1.2], "style": "line", "tag": [-209.1, 673.0],
         "text": "The top of the third hard bed, on the west side: 1.8 m of dry white chalk, level. It is the last chalk you climb. The next step is a plank.",
         "draw": [_ln(-210.0, 672.05, -208.2, 672.05)]},
    ],
    "foreground": [],
    "explains": [
        ["The five bands", "The edges of the tower's three hard beds, on both walls of a split", "The same beds crossing the split's back wall, stepping down a metre at the joint"],
        ["The two slick walls", "The faces of the joint, washed by rain", "The joint itself, a dark line up the back wall"],
        ["The tooth", "A corner of the east fin that hangs over the porch", "The east fin's body behind it"],
        ["The west fin's top", "The top of the third hard bed, on the west side of the split", "The cableway's pylon head, standing on the fin's body"],
        ["The shaft underneath", "The same split, going down into the upper window", "The back wall going down with it"],
    ],
    "pieces": [
        ["Cliff body: the tower, with its two fins", "9 m wide, 25 m tall", "3 sections", "Background", "kit: cliff body"],
        ["The split's back wall, with three stepped beds and the joint", "2.2 m wide, 18 m tall", "1", "Background", "kit: cliff body, with hard beds (added below)"],
        ["White band for a hard bed's edge", "0.4 m tall, 0.24 m proud", "5", "Play space (drawn on)", "kit: hard bed (added below)"],
        ["Pylon head", "8 m wide, 5 m tall", "1", "Background", "kit: pylon_head_low. The same one as La Estación Baja's"],
    ],
    "effects": [
        "A thin run of water down each wall, and a drip from each band.",
        "The wind is loud outside the porch and stops as you step under the tooth.",
        "A strip of sky straight overhead between the two fins, with a gondola crossing it now and then.",
    ],
    "notes": [
        "No note from the playtest is about this challenge.",
        "This is the thinnest design in the biome. The place is two walls and a slit of sky, and the design adds one idea: the slipped beds, shown on the back wall.",
        "This area has no foreground. The chimney is 2.2 m wide and anything in front of it would cover a band.",
        "Nothing you touch moves or is added.",
    ],
}

# ------------------------------------------------------------------ 7.10 La Estación Baja
_POSTS = [-237.0, -229.2, -220.7, -213.0]
_SCAFFOLD = [_r(round(x - 0.17, 2), 663.0, round(x + 0.17, 2), 688.0, "pale") for x in _POSTS] + \
            [_r(-237.2, 662.35, -212.8, 662.65, "pale"), _r(-237.2, 676.35, -220.5, 676.65, "pale"), _r(-220.9, 671.35, -208.4, 671.65, "pale"),
             _r(-237.2, 682.3, -212.8, 682.6, "pale"), _r(-237.2, 687.35, -212.8, 687.65, "pale"),
             _ln(-237.0, 663.0, -229.2, 676.3, "mark"), _ln(-229.2, 663.0, -237.0, 676.3, "mark"),
             _ln(-229.2, 663.0, -220.7, 671.0, "mark"), _ln(-220.7, 663.0, -229.2, 671.0, "mark"),
             _ln(-220.7, 663.0, -213.0, 671.3, "mark"), _ln(-213.0, 663.0, -220.7, 671.3, "mark"),
             _ln(-220.7, 682.6, -213.0, 687.3, "mark"), _ln(-213.0, 682.6, -220.7, 687.3, "mark"),
             _ln(-229.2, 682.6, -220.7, 687.3, "mark"), _ln(-220.7, 682.6, -229.2, 687.3, "mark")] + \
            [_c(x, y, 0.22, "light") for x in _POSTS for y in (662.5, 682.45, 687.5)] + \
            [_ln(xp, 663.0, round(xp + (xf - xp) * 2.5 / (663.0 - yf), 2), 660.5, "line") for xp, xf, yf in _STRUTS]

LA_ESTACION_BAJA = {
    "id": "7.10", "slug": "7_10_la_estacion_baja", "title": "La Estación Baja", "kind": "challenge", "also": ["a8"],
    "window": [-241.5, 660.5, -205.5, 691.0], "screen": [-222.0, 676.5], "cut_y": 675.0, "climber": [-209.2, 672.0],
    "place": ("The chalk ends here and the town's work begins. Above the tower the face is loose scree that nothing can be fixed "
              "to, so the cableway's builders stood their low station out from the cliff on a timber scaffold, 24 m wide and 25 m "
              "tall. It is the first sawn and painted timber since the town: square posts in yellow ochre, braces in the cableway's "
              "red, an iron plate with the pug's face at every joint. Its feet are on the two needles and on the tower's balcony. "
              "Its lowest level is the pack trail's old catwalk, in bare honey planks, and that is where a fall puts you. The "
              "way up is the machine itself. From the tower's west fin a plank platform with a board missing leads to the bull "
              "wheel: a red wheel 7.6 m across with cream spokes, turning once in 24 seconds because the haul cable runs round a drum "
              "on its axle. You ride its rim over the top, step off onto a stage, and climb the scaffold's long brace to the station's "
              "deck. The brace is rotten in the middle."),
    "keep": [
        "The platform's two lengths and the 1.4 m gap where a board is missing.",
        "The bull wheel: where it is, 7.6 m across, one turn in 24 seconds, its east side rising. Rim, spokes and hub can all be held.",
        "The stage, and the long brace: 12 m at 56 degrees, with 2.6 m of it rotten, giving way after 1.2 seconds.",
        "The old catwalk, 9 to 14 m below, which catches a fall. Its east end drops to the tower's balcony.",
    ],
    "background": [
        {"name": "The mountain's shoulder", "z": [-14.0, -12.0], "tag": [-240.4, 668.0],
         "text": _SHOULDER_TEXT + " Here it is a strip at the west edge of the frame, seen through the scaffold's west bay.",
         "draw": _shoulder(660.5, 691.0, -241.5)},
        {"name": "The scaffold", "z": [-2.8, -1.4], "tag": [-233.2, 669.4], "top": True,
         "text": "The kit's scaffold frame, moved back out of the play space: four posts 0.35 m square in yellow ochre, a ledger "
                 "under every plank you stand on, red braces crossed in the bays, and a pug plate at every joint. No brace crosses "
                 "behind the wheel or behind the long brace. Under the catwalk the four posts go on down as struts to the needles and "
                 "the balcony. Each plank deck is the near edge of a floor that goes back 1.4 m onto its ledger.",
         "draw": _SCAFFOLD},
        {"name": "The wheel's backboard, drum and axle", "z": [-2.8, -1.8], "tag": [-216.4, 679.0], "top": True,
         "text": "The wheel's bay is closed at the back with plain ochre boards, 10 m square, so the red rim reads against one "
                 "flat colour. In front of the boards, on the same axle as the wheel and 2 m behind it, is a plain grey drum 5 m "
                 "across. The haul cable runs round the drum. That is why the wheel turns. The axle sits in an iron bearing on the "
                 "scaffold's third post, under a pug plate.",
         "draw": [_r(-225.2, 670.4, -215.2, 679.6), _c(-220.2, 675.0, 2.5, "line"), _r(-220.7, 674.6, -219.7, 675.4, "pale")]},
        {"name": "The haul cable", "z": [-2.2, -1.9], "style": "line", "tag": [-224.6, 688.6],
         "text": "Black, greased, 0.15 m thick and taut, 2 m behind you: it is not taken for a rope. It comes down from the "
                 "station's wheel, over one sheave of the pylon head, round the drum, back over the other sheave and up again. "
                 "Both long runs pass at least 6 m over the stage and the brace, and the two short ones at least 2.5 m over the platform.",
         "draw": [_ln(-220.0, 677.5, -213.4, 677.5), _ln(-220.0, 672.5, -211.4, 676.5), _ln(-213.4, 677.5, -228.1, 691.0), _ln(-211.0, 677.5, -231.7, 691.0)]},
        {"name": "The pylon head", "z": [-2.4, -1.3], "style": "line", "tag": [-209.6, 678.4],
         "text": "The kit's low pylon head, moved back out of the play space, standing on the body of the tower's west fin: a red "
                 "timber frame 8 m wide and 5 m tall with two grey sheaves on its top. The platform's planks lie on its lowest rail.",
         "draw": [_r(-216.0, 672.0, -208.4, 676.3), _ln(-216.0, 672.0, -208.4, 676.3), _ln(-208.4, 672.0, -216.0, 676.3),
                  _c(-213.4, 676.9, 0.6), _c(-211.0, 676.9, 0.6)]},
        {"name": "The old catwalk's back", "z": [-2.2, -1.4], "style": "pale", "tag": [-231.6, 664.9],
         "text": "Along the back of the catwalk: the trail's handrail of lashed poles, 1.1 m high, unpainted, with one rag of "
                 "bunting. Against it is a stack of ochre posts that were carried up and never used. It is the last of the trail.",
         "draw": [_r(-236.6, 664.05, -213.4, 664.15)] + [_ln(x, 663.0, x, 664.05, "line") for x in (-236.4, -232.8, -225.2, -217.0, -213.6)] +
                 [_r(-228.4, 663.0, -225.6, 663.45)]},
        {"name": "The low station", "z": [-5.5, -2.5], "tag": [-239.6, 689.8],
         "text": "The station house, at the top west corner. It is on the page for the join.",
         "draw": [_r(-241.5, 688.0, -236.0, 691.0)]},
    ],
    "play": [
        {"name": "The bull wheel", "z": [-0.2, 0.2], "style": "line", "tag": [-224.9, 672.4],
         "text": "Note 76. The kit's wheel is made again at the course's size, 7.6 m across, so the red rim that is drawn is exactly "
                 "the rim you hold, and nothing solid lies outside it. Six cream spokes, and the pug on the hub.",
         "draw": [_c(-220.2, 675.0, 3.8), _c(-220.2, 675.0, 0.5)]},
        {"name": "The long brace", "z": [-0.2, 0.2], "style": "mark", "tag": [-230.4, 682.6],
         "text": "It is one of the scaffold's own braces, 0.3 m thick, in the cableway's red, matte, worn to bare honey wood along "
                 "its top where hands have gone. The rotten 2.6 m wears the cliffs' breakable look: the paint is gone, the wood is "
                 "grey and split along the grain, and a corner is missing. It creaks and dips before it goes, and it goes in splinters.",
         "draw": [_ln(_bp(4.2)[0], _bp(4.2)[1], _bp(6.8)[0], _bp(6.8)[1]), _ln(-231.8, 680.9, -232.3, 681.3, "line")]},
        {"name": "The missing board", "z": [-0.5, 0.5], "style": "mark", "tag": [-212.3, 670.9],
         "text": "In the 1.4 m gap you see the platform's two bearers with nail holes in them, and the board itself lying on the catwalk below.",
         "draw": [_ln(-213.0, 671.9, -211.6, 671.9), _ln(-214.6, 663.12, -213.3, 663.12, "line")]},
    ],
    "foreground": [
        {"name": "One front post", "z": [1.25, 1.55], "tag": [-238.4, 675.0], "top": True,
         "text": "The scaffold's front west post, 0.3 m thick, from the catwalk's level up to the underside of the station's deck. "
                 "It stands at the west edge of the frame, in front of air that nobody climbs through, 1.4 m clear of the brace's head.",
         "draw": [_r(-237.55, 663.0, -237.25, 687.4)]},
    ],
    "explains": [
        ["The platform's planks", "A walkway from the tower's fin to the scaffold", "The pylon head's lowest rail, which carries them, and the two bearers in the gap"],
        ["The bull wheel", "The flywheel on the cableway's bottom axle", "The grey drum behind it on the same axle, with the haul cable round it, and the axle's bearing on the scaffold's post"],
        ["The stage", "One of the scaffold's working floors", "Its ledger and the two posts that carry it"],
        ["The long brace", "One of the scaffold's own red braces", "The scaffold's west bay: its posts, its ledgers, and the pug plates the brace is bolted through at foot and head"],
        ["The old catwalk", "The top of the pack trail, which the scaffold was built on", "The trail's lashed handrail, and the stack of posts that were never used"],
    ],
    "pieces": [
        ["The mountain's shoulder", "30 m wide", "1 section", "Background", "kit: the mountain's shoulder"],
        ["Station scaffold: posts, ledgers, crossed braces, pug plates", "24 m wide, 25 m tall", "1", "Background", "kit: scaffold_frame"],
        ["Scaffold strut with an iron shoe", "0.3 m square, 9 to 14 m", "4", "Background", "kit: scaffold strut (added below)"],
        ["Bull wheel, red with six cream spokes", "7.6 m across", "1", "Play space", "kit: bull_wheel, made again at 7.6 m (note 76)"],
        ["Backboard of ochre boards; grey drum; axle bearing with a pug plate", "10 m square; 5 m across; 1 m", "1 of each", "Background", "kit: bull wheel (its axle frame); the backboard and drum are new, this area only"],
        ["Haul cable", "0.15 m thick; about 60 m in this picture", "1", "Background", "kit: bull wheel (the haul cable)"],
        ["Pylon head with two sheaves", "8 m wide, 5 m tall", "1", "Background", "kit: pylon_head_low"],
        ["Long brace, sound lengths and the rotten length", "12.2 m; the rotten part 2.6 m", "1", "Play space", "kit: long brace with a rotten middle"],
        ["Plank: platform, stage, catwalk", "1.6 m, 3.2 m, 4.7 m, and three of about 8 m", "6", "Play space", "kit: plank"],
        ["Lashed-pole handrail; stack of ochre posts; fallen board", "23 m; 2.8 m; 1.3 m", "1 of each", "Background", "kit: trail post and rail (added below); burro load (added below); plank"],
        ["Front post", "0.3 m thick, 24.4 m tall", "1", "Foreground", "kit: scaffold_frame (one post)"],
    ],
    "effects": [
        "The cable runs. You see it move round the drum and over the sheaves, and the wheel turns with it.",
        "The whole scaffold ticks and creaks, and the catwalk's planks knock when you land on them.",
        "The daylight has started to turn gold on the scaffold's west side.",
    ],
    "notes": [
        "Note 76 (cause found, not fixed): the wheel that is drawn and the wheel you touch become the same size. The model is made again at the course's 7.6 m, so no reach changes.",
        "Scenery moved out of the play space, where it stands today: the scaffold's frame and the pylon head.",
        "The cableway's own towers (biome 8's) stand in this picture today as flat red cards, from the catwalk's height upward. They belong to that biome's pages and are not drawn here.",
        "The cable's road is chosen to keep it away from every place you stand. No part of it comes within 2.5 m of a plank or within 6 m of the brace.",
        "The scaffold's four legs, down to the needles and the balcony, are new. They are asked about on the page for Los Burros, because that is where they show.",
        "Nothing you touch moves or is added.",
    ],
}

# ------------------------------------------------------------------ 7 to 8: the low station
THE_LOW_STATION = {
    "id": "7 to 8", "slug": "7_to_8_the_low_station", "title": "The low station: from the cliffs to the cableway", "kind": "join", "also": ["a8"],
    "window": [-257.0, 679.5, -227.0, 699.5], "screen": [-242.0, 690.0], "cut_y": 688.6, "climber": [-244.0, 688.0],
    "place": ("The top of the cliffs, 688 m up, and the bottom of the cableway. The long brace brings you up over the east end of a "
              "deck of honey planks 14 m long. Its west end rests on the last white chalk of the face. Its east end is carried by the "
              "scaffold. Behind the deck, 2.5 m back, is the town's low station house: board walls, red below and cream above, a "
              "striped tin roof, dark windows, a cold lantern by the door. Nobody is here. Within this one screen everything changes "
              "hands. Chalk gives way to scree above you. Lashed poles and hemp give way to sawn timber and paint, and then to "
              "steel and cable. The gusts that pushed you about on the cliffs become one steady wind, and the sock on the deck's back "
              "corner points east and stays there. The light has turned from blue toward gold. At the deck's east end is the boarding "
              "gangway, and every six seconds a car comes down to it. From there on it is biome 8."),
    "keep": [
        "The deck: 14 m long, its top at 688 m, and the plug of chalk at its west end.",
        "The head of the long brace, at the deck's east end.",
        "Biome 8's gangway on the deck's east end, 0.7 m higher, with its one rail post, and the cars that come down to it.",
        "The face above the deck: slick scree with nothing on it.",
    ],
    "background": [
        {"name": "The mountain's shoulder", "z": [-14.0, -12.0], "tag": [-248.6, 697.6],
         "text": "The cliffs' flat cut-out card, 12 m back, carried on up behind the station house. Above the deck's height its chalk "
                 "gives way to dark scree, as biome 8's sheet has it.",
         "draw": _shoulder(679.5, 699.5, -257.0)},
        {"name": "The station house", "z": [-5.5, -2.5], "tag": [-247.0, 692.2], "top": True,
         "text": "The kit's low station house, 14 m wide and 6 m tall, moved back to stand 2.5 m behind you, with no roof and no post "
                 "over the deck. So nothing within reach looks like something to hold (note 77). The deck's planks carry on back to "
                 "its door. Its ticket booth, its pug sign and its wind engine are biome 8's and are on that biome's pages.",
         "draw": [_r(-250.0, 688.0, -236.0, 694.0), _p([(-250.6, 694.0), (-235.4, 694.0), (-236.2, 695.3), (-249.8, 695.3)], "pale"),
                  _r(-244.7, 688.0, -243.5, 690.3, "dark"), _r(-241.6, 690.0, -240.2, 691.4, "dark"), _r(-239.2, 690.0, -237.8, 691.4, "dark")]},
        {"name": "The cold lantern", "z": [-2.5, -2.2], "style": "pale", "tag": [-243.0, 689.6],
         "text": "The lantern that stands on the deck today, moved back to hang on a bracket beside the house's door. It is not lit. "
                 "The last lit lantern was in the tea cave.",
         "draw": [_c(-243.0, 689.0, 0.2)]},
        {"name": "The wind sock", "z": [-2.5, -2.1], "tag": [-248.0, 692.0],
         "text": "On a post 3 m tall at the deck's back west corner: the same red and white sock as on the tower's porch. Here it "
                 "points east and stays there, full. It is the first thing that tells you the wind has changed its ways.",
         "draw": [_r(-249.28, 688.0, -249.12, 691.0, "pale"), _p([(-249.2, 691.0), (-247.7, 690.8), (-247.7, 690.5), (-249.2, 690.5)], "pale")]},
        {"name": "The line of pennants", "z": [-2.3, -2.0], "style": "mark", "tag": [-233.6, 696.0],
         "text": "The kit's pennant line, 26 m of the town's bunting, from the house's east gable out to a pole on the scaffold's far "
                 "corner. Today it hangs at head height along the deck, inside the play space. It goes 2 m back and up to 5 m "
                 "above the deck, over every hand. All its pennants point east.",
         "draw": [_ln(-243.0, 695.3, -235.0, 694.2), _ln(-235.0, 694.2, -227.0, 693.5)]},
        {"name": "Under the deck", "z": [-2.6, -1.4], "style": "pale", "tag": [-246.0, 683.0], "top": True,
         "text": "What carries the deck: a ledger under its planks, the scaffold's west post under its east end, and two raking "
                 "struts in yellow ochre from the ledger down to iron shoes in the face. A pug plate is at each strut's head.",
         "draw": [_r(-250.0, 687.05, -236.0, 687.35), _r(-237.17, 679.5, -236.83, 687.35), _ln(-244.0, 687.05, -250.8, 681.4, "line"),
                  _ln(-239.0, 687.05, -247.6, 679.5, "line"), _c(-244.0, 687.2, 0.22, "light"), _c(-239.0, 687.2, 0.22, "light")]},
        {"name": "The haul cable, going up", "z": [-2.2, -1.9], "style": "line", "tag": [-231.0, 691.6],
         "text": "The two runs of the cliffs' haul cable come up from the bull wheel, 2 m behind you, and go round the wheel over "
                 "the dock. That wheel is biome 8's, a flat greyed bull wheel 4.4 m across, and the station's wind engine turns "
                 "it. So the wheel you rode below is turned from here.",
         "draw": [_ln(-227.0, 690.0, -236.4, 698.6), _ln(-227.0, 687.9, -238.9, 695.7), _c(-237.2, 697.0, 2.2)]},
    ],
    "play": [
        {"name": "The last chalk", "z": [-1.2, 1.2], "style": "line", "tag": [-253.6, 689.0],
         "text": "The plug at the deck's west end is the cliffs' last white chalk: dry, matte, with a grass tuft on it. The deck's "
                 "first plank is cut to fit against it. Above it the face is dark scree.",
         "draw": [_r(-253.0, 686.0, -250.0, 688.0)]},
        {"name": "The deck's planks", "z": [-1.2, 1.2], "style": "mark", "tag": [-246.0, 686.2],
         "text": "Honey planks laid across the deck, 0.3 m wide, with two rows of nail heads. They are the same planks as the old "
                 "catwalk's, but new, sawn square and nailed, not lashed. The joints are drawn on the deck that is there.",
         "draw": [_ln(x, 688.0, x, 687.6) for x in (-248.0, -246.0, -244.0, -242.0, -240.0, -238.0)]},
        {"name": "The brace's head", "z": [-0.3, 0.3], "style": "line", "tag": [-234.6, 686.4],
         "text": "The long brace is bolted to the deck's end beam through an iron plate with the pug's face on it. The plate is the "
                 "last of the scaffold.",
         "draw": [_c(-236.0, 687.5, 0.3)]},
        {"name": "Where the cableway begins", "z": [-1.2, 1.2], "style": "mark", "tag": [-240.4, 690.2],
         "text": "The step up onto the gangway. The deck's planks are bare. The gangway's edge is painted with the cableway's "
                 "cream band, the first of that biome's marks for a hold. One step, and the paint changes.",
         "draw": [_ln(-240.0, 688.0, -240.0, 688.7)]},
    ],
    "foreground": [
        {"name": "One scaffold post", "z": [1.25, 1.55], "tag": [-249.45, 683.0],
         "text": "One painted post, 0.3 m thick, in front of the deck's west end, from below the frame up to just under the deck's "
                 "top. It stands in front of the air under the deck, where nobody is. Biome 8's sheet counts on it.",
         "draw": [_r(-249.6, 679.5, -249.3, 687.9)]},
    ],
    "explains": [
        ["The deck", "The low station's platform, half on the cliff and half on the scaffold", "The station house 2.5 m behind it, with the planks carrying on back to its door"],
        ["The plug of chalk", "The cliffs' last ledge", "The mountain's shoulder, where the chalk gives way to scree"],
        ["The brace's head", "The top of the scaffold", "The scaffold's west post and the struts under the deck"],
        ["The gangway and its rail post", "Biome 8's: where you board", "Biome 8's cars, and the haul cable going up to the wheel over the dock"],
        ["The steady wind", "The wind that drives the cableway", "The wind sock, the pennant line, all pointing east"],
    ],
    "pieces": [
        ["The mountain's shoulder", "30 m wide", "1 section", "Background", "kit: the mountain's shoulder; carried on by biome 8's kit"],
        ["Station house", "14 m wide, 6 m tall, 3 m deep", "1", "Background", "kit: the low station (cable_station_low)"],
        ["Plank deck", "14 m long; 3.7 m from front to the house's door", "1", "Play space; its back half behind", "kit: the low station (the deck); plank"],
        ["Cold lantern on a bracket", "0.5 m", "1", "Background", "kit: lantern_cold"],
        ["Wind sock on a post", "post 3 m; sock 1.5 m", "1", "Background", "kit: wind_sock"],
        ["Pennant line", "26 m", "1", "Background", "kit: pennant_line"],
        ["Ledger; scaffold post; pug plate", "14 m; 0.35 m square; 0.4 m", "1; 1; 3", "Background", "kit: scaffold_frame"],
        ["Scaffold strut with an iron shoe", "0.3 m square, 9 m and 15.5 m", "2", "Background", "kit: scaffold strut (added below)"],
        ["Haul cable", "0.15 m thick", "2 runs", "Background", "kit: bull wheel (the haul cable)"],
        ["Chalk plug with a grass tuft", "3 m by 2 m", "1", "Play space", "the course builds it; grass_tuft_dry"],
        ["Front post", "0.3 m thick, 8.4 m showing", "1", "Foreground", "kit: scaffold_frame (one post)"],
    ],
    "effects": [
        "The wind sock and the pennants point east without a break. No wavy lines here: this wind does not push you (biome 8's sheet).",
        "Gold light on the house's west wall, and long shadows across the deck.",
        "A car comes down to the gangway every six seconds. You hear its grip rattle on the cable before you are over the deck's edge.",
    ],
    "notes": [
        "Note 77 is biome 8's, but it lands on a piece in the cliffs' kit: the station house looked holdable and was not, and its front half stood inside the play space. It moves 2.5 m back, with no roof over the deck.",
        "Note 89: flags first. Here the sock and the pennants are the whole of the wind.",
        "Scenery moved out of the play space, where it stands today: the station house, the pennant line and the cold lantern.",
        "Our end of the join is the deck, what carries it, the house, the sock, the pennants and the cable. Biome 8's end is the gangway, the cars, the wheel over the dock, the booth, the sign and the wind engine.",
        "Nothing you touch moves or is added.",
    ],
}

# ------------------------------------------------------------------ pieces more than one area uses, added to the cliffs' kit
KIT_MORE = [
    ["Hard bed: a band of harder chalk that stands out of a wall as a small ledge. White where you hold its edge, a darker band where it is behind you", "0.4 to 1.7 m tall", "the two blank lengths of El Balcón's crack and the steps of its back wall; the five bands of Chimenea de Roca and the stepped beds on its back wall", "Background; drawn on in the play space", "new, a look of the cliff body"],
    ["Flint knob in a white rind; the same knob in grey", "0.4 m; one of 1.8 m", "the knobs under La Cornisa's roof, its nose, and the knobs up the gully's treads; grey ones in the seam behind", "Play space; background", "new, the same knob as the chimney's La Luz"],
    ["Chalk lip with a grass tuft", "7 to 12 m long, up to 4 m tall", "a bottom west corner of El Balcón, Nidos and Desprendimiento, always in front of solid rock", "Foreground", "new"],
    ["Whitewash: a vulture's white wash on a ledge's lip", "paint, 1.1 to 1.5 m", "where a bird passes lowest over a ledge: the place to take it and the place to let go", "Play space (drawn on)", "new, paint only"],
    ["Trail hoist: two lashed poles with a pulley block and no rope, standing or fallen", "poles 4.3 to 5.5 m", "fallen on El Balcón's back; standing on the tower's balcony at Los Burros", "Background", "new"],
    ["Trail post with a rag of bunting; lashed-pole rail on posts", "post 0.2 m thick, 3 m tall; rail 1.1 m high", "the door onto El Balcón; the old catwalk's handrail", "Foreground (the one post); background", "new"],
    ["Burro load: paint tins, a bundle of ochre posts, a coil of haul cable; a hitching peg with a frayed halter end", "0.4 to 2.8 m", "behind each burro; stacked on the old catwalk", "Background", "new"],
    ["Scaffold strut with an iron shoe", "0.3 m square, 9 to 16 m long", "the scaffold's four legs down to the needles and the balcony; the two struts under the station's deck", "Background", "new, from the kit's scaffold_frame"],
]

AREAS = [EL_BALCON, NIDOS, ARBOL_SECO, PUENTE_ROTO, LA_CORNISA, DESPRENDIMIENTO, TEA_CAVE, LOS_BURROS, VIENTO_A_FAVOR,
         CHIMENEA_DE_ROCA, LA_ESTACION_BAJA, THE_LOW_STATION]
