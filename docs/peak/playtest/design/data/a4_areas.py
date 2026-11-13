# The mushroom garden's areas, one dict each. Format: see ../build.py.
# Everything is drawn at the course's own coordinates (stages/peak/course/a4.json).
#
# The garden's version of "the ladder and its rungs":
#   every cap that throws you has its stalk standing behind and below it, leaning forward;
#   every vine hangs from a root or a roof you can see; every shelf fungus grows from a wall.
# The far forest is the bell mushroom, the scenery kind (Parker, 11-13). Nothing orange is scenery, so an orange cap always means bounce.
# In the sketches: far things are "solid", near stalks and roots are "pale", holes are "dark".


# ------------------------------------------------------------------ shapes used again and again
def _stalk(x, y0, y1, w=1.0, foot=None):
    """A stalk from the side: thicker at the foot. `foot` is where it roots if it leans."""
    fx = x if foot is None else foot
    return ["poly", [[fx - w * 0.7, y0], [fx + w * 0.7, y0], [x + w * 0.4, y1], [x - w * 0.4, y1]]]


def _skirt(x, y, w=1.0):
    """The skirt-ring part way up a stalk."""
    return ["poly", [[x - w * 0.5, y + 0.15], [x + w * 0.5, y + 0.15], [x + w * 0.95, y - 0.3], [x - w * 0.95, y - 0.3]], {"style": "solid"}]


def _bell(x, y0, h, w):
    """One bell mushroom, the scenery kind: a thin stalk and a small bell-shaped cap. h is its height, w its cap's width."""
    sw = max(0.3, w * 0.2)
    top = y0 + h
    yc = top - w
    return ["poly", [[x - sw / 2, y0], [x + sw / 2, y0], [x + sw * 0.35, yc], [x + w * 0.55, yc - w * 0.1], [x + w * 0.45, yc + w * 0.3],
                     [x + w * 0.3, yc + w * 0.75], [x, top], [x - w * 0.3, yc + w * 0.75], [x - w * 0.45, yc + w * 0.3],
                     [x - w * 0.55, yc - w * 0.1], [x - sw * 0.35, yc]]]


def _stand(bells):
    """A stand of bell mushrooms: a list of (x, foot, height, cap width)."""
    return [_bell(x, y0, h, w) for x, y0, h, w in bells]


def _gills(x0, x1, y, drop=0.55):
    """The gills under a flat cap: a shallow fan from the rim in to the stalk."""
    cx = (x0 + x1) / 2.0
    return ["poly", [[x0 + 0.15, y], [x1 - 0.15, y], [cx + 0.45, y - drop], [cx - 0.45, y - drop]]]


def _snail(x, y, r=0.9, flip=1):
    """A snail asleep: shell and foot."""
    return [["circle", x, y + r, r, {"style": "pale"}], ["circle", x, y + r, r * 0.45, {"style": "line"}],
            ["poly", [[x - flip * r * 1.5, y], [x + flip * r * 1.1, y], [x + flip * r * 0.9, y + 0.3], [x - flip * r * 1.3, y + 0.35]], {"style": "pale"}]]


def _ramp(x):
    """The height of the slime ramp's face under x (it rises 0.70 m per metre from -255.1, 264)."""
    return 264.0 + (x + 255.1) * 0.70


# ------------------------------------------------------------------ 4.1 Sombreros
SOMBREROS = {
    "id": "4.1", "slug": "4_01_sombreros", "title": "Sombreros", "kind": "challenge",
    "window": [-299.5, 259.5, -262.5, 283.5], "screen": [-279.0, 270.0], "cut_y": 266.0, "climber": [-286.6, 267.2],
    "place": ("This is the foot of the garden's west hall, a room 100 m tall beside the well. You come in out of the air, from the first "
              "crossing, into a curtain of roots at the well's rim. One great root comes down the well's wall at the door, lies along the "
              "floor, and rears up as a broken stump. Where a root that size lies under moss, mushrooms come up along it in a row, and "
              "that is the challenge: four mushrooms of one family, each older and taller than the last. The first three are young and "
              "full of spring. The fourth is old: its cap has turned up like a saucer and gone dry, and it is the shelf you rest on. One "
              "more, older still, fell off its stalk long ago, and the moss has taken it: it is a soft green mound on the floor. A "
              "climber lay down on it and never got up."),
    "keep": [
        "The stump you step off, and the three caps exactly where they are, each wider than the last: 3.2 m, 4.0 m, 4.4 m.",
        "Each cap's throwing face, flat and at its angle. The first leans 13 degrees east, the other two are level.",
        "The shelf at 276 m, the soft mound on the floor with the frozen climber on it, and the moss floor that catches every fall in the west hall.",
        "The root beam at the door and its three hanging roots, which catch the fling from the crystal cave.",
    ],
    "background": [
        {"name": "The west hall, far back", "z": [-10.0, -6.0], "tag": [-283.5, 276.2],
         "text": "Two stands of bell mushrooms, the garden's scenery kind: thin stalks 6 to 13.5 m tall with small pale blue-green caps like bells, 6 to 10 m behind you. Rounded mossy boulders stand along the foot of the back wall. The orange scenery mushrooms that stand 2 m behind you today are gone. Nothing orange grows in the scenery, so an orange cap always means bounce (Parker, 11-13).",
         "draw": _stand([(-284.6, 264.0, 8.0, 1.6), (-283.5, 264.0, 13.5, 2.6), (-282.4, 264.0, 10.0, 2.0),
                         (-265.6, 264.0, 7.5, 1.6), (-264.5, 264.0, 10.0, 2.2), (-263.5, 264.0, 6.0, 1.4)]) +
                 [["poly", [[-291.0, 264.0], [-290.2, 265.6], [-288.4, 266.2], [-286.9, 265.2], [-284.6, 266.6], [-282.4, 265.4], [-279.8, 266.9],
                            [-277.2, 265.5], [-274.4, 266.4], [-272.0, 265.3], [-269.2, 266.8], [-266.4, 265.6], [-264.2, 266.5], [-262.5, 265.4], [-262.5, 264.0]]]]},
        {"name": "A snail, asleep", "z": [-7.0, -6.0], "tag": [-290.9, 268.0],
         "text": "On a boulder at the back, beside the door, shell 1.7 m across, drawn in. It is the first snail you see, long before the ones you climb.",
         "draw": _snail(-289.5, 265.9, 0.85)},
        {"name": "The great root", "z": [-3.0, -1.4], "style": "pale", "tag": [-271.3, 264.7], "top": True,
         "text": "As thick as a barrel. It comes down the back of the door at the well, and lies along the floor 2 m behind the path, half under moss, humping up and down. The knee and the stump you climb are its near end, broken off.",
         "draw": [["poly", [[-285.4, 264.0], [-285.4, 265.0], [-283.0, 265.5], [-281.0, 265.0], [-279.0, 265.6], [-276.5, 265.1], [-274.5, 265.7],
                            [-271.5, 265.2], [-269.0, 265.8], [-266.5, 265.0], [-264.6, 264.4], [-264.0, 264.0]]],
                  ["poly", [[-293.7, 264.0], [-292.8, 264.0], [-292.6, 272.0], [-292.9, 279.2], [-293.6, 279.2], [-293.4, 272.0]]],
                  ["poly", [[-292.3, 264.0], [-291.5, 264.0], [-291.3, 270.0], [-291.6, 276.0], [-292.2, 276.0], [-292.0, 270.0]]]]},
        {"name": "The four stalks", "z": [-2.6, -1.2], "style": "pale", "tag": [-274.5, 268.2], "top": True,
         "text": "One behind each cap and one behind the shelf. Each roots on the great root 2 m back and leans forward, so its cap hangs over the path and the floor under it stays clear. Cream, with a skirt part way up and gills under the cap. When a cap throws you, its stalk dips and rocks with it (note 36).",
         "draw": [_stalk(-284.2, 264.0, 264.75, 1.0), _stalk(-279.2, 264.0, 268.1, 1.0, -279.7), _stalk(-274.2, 264.0, 271.6, 1.1, -274.8),
                  _stalk(-267.5, 264.0, 275.4, 1.4, -268.2), _skirt(-279.3, 267.0, 1.0), _skirt(-274.4, 269.4, 1.1), _skirt(-267.8, 272.4, 1.4),
                  _gills(-281.2, -277.2, 268.1), _gills(-276.4, -272.0, 271.6), _gills(-270.5, -264.5, 275.4, 0.7)]},
        {"name": "Glow moss and two spore lanterns", "z": [-2.4, -1.3], "style": "light", "tag": [-268.9, 273.9],
         "text": "Moss glows green on the great root. Two lantern pods grow on the stalks, low down, so the caps are lit from underneath. Today a lantern floats in the air beside the shelf: it moves onto the shelf's stalk.",
         "draw": [["circle", -268.2, 273.9, 0.22], ["circle", -274.8, 268.3, 0.2], ["rect", -283.4, 265.45, -281.2, 265.6], ["rect", -270.8, 265.6, -268.4, 265.75]]},
    ],
    "play": [
        {"name": "Three caps, spotted", "z": [-1.2, 1.2], "style": "pale", "tag": [-279.2, 269.5],
         "text": "Orange with pale spots. No checks (note 37). The face you land on stays as flat as it is today. The roundness is in the rim, which rolls down all round, and in the cream gills underneath. Each cap sways a little at rest, squashes when you land and springs back taller, with a puff of spores from under the rim (note 36).",
         "draw": [["circle", -285.6, 265.3, 0.33], ["circle", -282.8, 264.65, 0.33], ["circle", -281.1, 268.45, 0.33], ["circle", -277.3, 268.45, 0.33],
                  ["circle", -276.3, 271.95, 0.33], ["circle", -272.1, 271.95, 0.33]]},
        {"name": "The shelf: an old cap turned up", "z": [-1.2, 1.2], "style": "mark", "tag": [-266.0, 276.7],
         "text": "Cream and dry, with its gills on top as fine lines running out from the middle. It has no orange left, so nobody expects it to throw them.",
         "draw": [["line", -270.3, 276.05, -264.7, 276.05]]},
        {"name": "The frozen climber, on a mound of moss", "z": [-0.6, 0.6], "style": "pale", "tag": [-276.5, 266.3],
         "text": "He lies where he is today. The old cap under him is orange in the course, and it does not throw. It becomes a low mound of green moss with a little grey-brown rot showing at its edges: no orange and no spots anywhere, so it can't be taken for a cap that throws (Parker, 11-13). The moss has grown on over his legs and one arm like a blanket, and three pale bell sprouts come up beside him.",
         "draw": [["poly", [[-280.4, 264.0], [-280.4, 265.4], [-279.4, 266.05], [-278.4, 265.85], [-276.8, 265.4], [-276.8, 264.0]]],
                  ["circle", -277.5, 265.6, 0.14], ["circle", -277.15, 265.55, 0.1], ["circle", -280.6, 265.3, 0.12]]},
    ],
    "foreground": [
        {"name": "Fern and one small bell mushroom", "z": [1.4, 2.2], "tag": [-265.5, 260.3], "top": True,
         "text": "At the bottom right corner, below the floor's edge: a fern clump and one small bell mushroom, both dark. Nothing else stands in front (note 40).",
         "draw": [["poly", [[-268.0, 259.5], [-267.4, 260.9], [-266.6, 259.9], [-265.8, 261.1], [-265.0, 259.9], [-264.3, 260.7], [-263.6, 259.5]]],
                  _bell(-263.1, 259.5, 1.5, 0.8)]},
    ],
    "explains": [
        ["The three caps", "Three young mushrooms of one family, growing in a row", "Each one's stalk, rooted on the great root and leaning forward to hold the cap out"],
        ["The stump and the root knee", "The broken end of a great root", "The same root coming down the back of the door, and lying along the floor behind the path"],
        ["The shelf at 276 m", "The family's eldest: an old cap turned up like a saucer", "Its stalk, the thickest of the four"],
        ["The soft mound and the frozen climber", "A cap that fell off its stalk and was taken by the moss, and the one who lay down on it", "The second cap's stalk, which came up where the old one stood"],
        ["The three hanging roots at the door", "Root ends hanging from the root beam", "Two thick roots down the back of the door: the beam is their branch"],
        ["The moss floor", "The floor of the hall", "Boulders, and two stands of bell mushrooms"],
    ],
    "pieces": [
        ["Spotted mushroom cap with rolled rim and gills, flat on top", "3.2 m, 4.0 m, 4.4 m", "3", "Play space", "kit: spotted mushroom, middle, re-made spotted (note 37)"],
        ["Leaning stalk with skirt", "1 m thick; 0.8 m, 4 m, 7.6 m tall", "3", "Background", "kit: spotted mushroom stalk"],
        ["Old cap turned up like a saucer, on a stalk 1.4 m thick", "6 m across, stalk 11.4 m", "1", "Play space, background", "kit: old cap turned up (rest shelf)"],
        ["Mound of moss over a rotted cap", "3.6 m by 1.4 m", "1", "Play space", "new, this area only"],
        ["Moss blanket and three bell sprouts for the frozen climber", "2 m", "1", "Play space (drawn on)", "new, this area only"],
        ["Great root, lying; great root, down a wall", "1.2 m thick; 21 m and 15 m", "1 lying, 2 down the door", "Background", "kit: thick root"],
        ["Bell mushroom", "6 to 13.5 m tall, caps 1.4 to 2.6 m", "6, in two stands", "Background, far", "kit: bell mushroom"],
        ["Mossy boulder", "1.5 to 3 m", "8", "Background, far", "kit: mossy boulder"],
        ["Giant snail, asleep", "1.8 m shell", "1", "Background, far", "kit: giant snail"],
        ["Glow moss patch; spore lantern", "2.4 m; 0.5 m", "2 and 2", "Background", "kit: glow moss patch; spore lantern"],
        ["Fern clump; one small bell mushroom", "4 m; 1.5 m", "1 and 1", "Foreground", "kit: fern clump; bell mushroom, small"],
    ],
    "effects": [
        "A puff of spores from under a cap's rim each time it throws you.",
        "Slow spores drifting up the whole hall, and a low mist on the floor.",
    ],
    "notes": [
        "Note 36 (not built yet): the caps squash, spring and sway, and their stalks rock with them.",
        "Note 37 (not built yet): the caps are spotted, not checked. Parker, 11-13: the scenery is a second kind, the bell mushroom, 6 to 10 m back.",
        "Course change, look only (Parker, 11-13): the soft old cap under the frozen climber is kind cap in the course, which paints it orange. It becomes a mossy kind, green. Its shape and where it is do not change.",
        "Note 40 (done): the front pieces are gone. One fern clump at a bottom corner is all that stands in front.",
    ],
}

# ------------------------------------------------------------------ 4.2 Lianas
_VINES42 = [-263.3, -258.3, -253.3, -248.3]

LIANAS = {
    "id": "4.2", "slug": "4_02_lianas", "title": "Lianas", "kind": "challenge",
    "window": [-272.5, 261.5, -238.5, 292.5], "screen": [-256.0, 280.5], "cut_y": 283.0, "climber": [-266.5, 276.0],
    "place": ("Over your head is the underside of the island: a spur of the mountain that sticks out of the back wall into the middle of the "
              "room, black with slime. Water seeps through it along four cracks, and where each crack opens in its belly a creeper has "
              "taken root and let one long vine down. Under the vines the floor tips up into a ramp of slime that runs all the way back to "
              "the floor of Sombreros. So this is a wet cave roof hung with creeper, over a chute. The four vines are the creeper's "
              "nearest strands, 5 m apart because the cracks are."),
    "keep": [
        "The four vines, 5 m apart, each 9.5 m long, hanging from the island's underside.",
        "The shelf you leave from and the shelf you land on.",
        "The slime ramp under the last two vines, which slides a fall back to the floor of Sombreros.",
    ],
    "background": [
        {"name": "The forest, far back", "z": [-10.0, -6.0], "tag": [-260.5, 274.6],
         "text": "Two stands of bell mushrooms, 6 to 10 m behind you: one on the floor and one on the back of the ramp. Thin stalks, small pale blue-green bell caps. Their tops stay below the vines' ends, so no far stalk is ever seen behind a vine.",
         "draw": _stand([(-261.6, 264.0, 9.0, 1.8), (-260.5, 264.0, 12.0, 2.4), (-259.6, 264.0, 7.0, 1.5),
                         (-251.3, 266.7, 8.5, 1.8), (-250.2, 267.4, 9.6, 2.2), (-249.2, 268.1, 6.5, 1.5)])},
        {"name": "The island's belly, going back", "z": [-6.0, -4.0], "tag": [-256.0, 286.6], "top": True,
         "text": "The roof you hang under carries on 6 m back, and from its far part hangs the rest of the creeper as one thick, dim mass. It is far enough back, and solid enough, that nobody takes it for a fifth vine.",
         "draw": [["poly", [[-266.0, 288.0], [-246.0, 288.0], [-246.0, 286.6], [-248.5, 285.9], [-251.0, 286.8], [-253.5, 285.6], [-256.5, 286.7],
                            [-259.0, 285.8], [-262.0, 286.9], [-264.5, 286.0], [-266.0, 286.8]]]]},
        {"name": "A snail, asleep on the slope", "z": [-7.0, -6.0], "tag": [-246.4, 272.6],
         "text": "Far back on the ramp, stuck where it stopped.",
         "draw": _snail(-246.4, 270.1, 0.85)},
        {"name": "Four leaf collars", "z": [-2.2, -1.2], "style": "pale", "tag": [-260.8, 287.2], "top": True,
         "text": "Where each crack opens in the roof, just behind each vine: a clump of leaves 1.8 m wide with a root as thick as an arm running back along the crack. Each vine is seen to grow out of one.",
         "draw": [["poly", [[x - 0.9, 288.0], [x + 0.9, 288.0], [x + 0.6, 287.3], [x, 287.0], [x - 0.6, 287.3]]] for x in _VINES42]},
        {"name": "The two shelves' stalks", "z": [-2.6, -1.2], "style": "pale", "tag": [-268.5, 270.0], "top": True,
         "text": "The shelf you leave stands on its thick stalk from the floor. The shelf you land on stands on a shorter one that roots in the ramp behind it.",
         "draw": [_stalk(-267.5, 264.0, 275.4, 1.4, -268.2), _skirt(-267.8, 272.4, 1.4), _gills(-270.5, -264.5, 275.4, 0.7),
                  _stalk(-242.5, 272.0, 276.9, 1.0, -242.9), _gills(-244.5, -240.5, 276.9, 0.5)]},
        {"name": "Glow from below", "z": [-2.4, -1.3], "style": "light", "tag": [-258.6, 265.2],
         "text": "Glow moss along the back of the floor, a lantern pod on the first shelf's stalk, and one spore pod glowing on the ramp. The vines are lit from underneath and show pale against the dark roof.",
         "draw": [["rect", -260.2, 264.3, -257.0, 264.5], ["circle", -268.2, 273.9, 0.22], ["circle", -245.8, 271.1, 0.3]]},
    ],
    "play": [
        {"name": "Seep cracks in the roof", "z": [1.1, 1.2], "style": "mark", "tag": [-255.6, 289.9],
         "text": "The island's face is a blank black sheet today. It gets four cracks drawn on it, one rising from each vine, with a line of moss in each and slime running from it.",
         "draw": [["line", x, 288.0, x + 0.5, 290.4] for x in _VINES42]},
        {"name": "Vine knots", "z": [-0.3, 0.3], "style": "pale", "tag": [-251.6, 287.8], "top": True,
         "text": "Each vine comes out of its crack in a knot with two leaves on it, so its top end is not just a line that stops at the rock.",
         "draw": [["circle", x, 287.82, 0.24] for x in _VINES42]},
        {"name": "The landing shelf: an old cap turned up", "z": [-1.2, 1.2], "style": "mark", "tag": [-240.6, 278.2],
         "text": "Cream and dry, gills on top, the same piece as the shelf you left.",
         "draw": [["line", -244.3, 277.55, -240.7, 277.55]]},
    ],
    "foreground": [
        {"name": "Fern", "z": [1.3, 1.9], "tag": [-270.4, 262.3], "top": True,
         "text": "One clump at the bottom left, in front of the floor's rock face and below where you walk.",
         "draw": [["poly", [[-272.5, 261.5], [-272.0, 263.2], [-271.2, 262.1], [-270.4, 263.5], [-269.6, 262.2], [-268.9, 263.0], [-268.3, 261.5]]]]},
    ],
    "explains": [
        ["The four vines", "The nearest strands of a creeper that roots in the roof's cracks", "A leaf collar at each vine's top, and the rest of the creeper as a far mass under the roof"],
        ["The roof they hang from", "The underside of the island", "The same roof going 6 m back"],
        ["The shelf you leave and the shelf you land on", "Two old caps turned up like saucers", "A stalk under each: one from the floor, one from the ramp"],
        ["The slime ramp", "Where the island's slime runs to", "The ramp's far side, with a stand of bell mushrooms and a sleeping snail on it"],
    ],
    "pieces": [
        ["Vine with leaves, with a knot at its top", "9.5 m", "4", "Play space", "kit: vine with leaves"],
        ["Leaf collar with an arm-thick root", "1.8 m wide", "4", "Background", "kit: vine with leaves; thick root"],
        ["Creeper mass, far", "20 m wide, 2 m deep", "1", "Background, far", "new, this area only"],
        ["Old cap turned up like a saucer, on its stalk", "6 m and 4 m across", "2", "Play space, background", "kit: old cap turned up (rest shelf)"],
        ["Bell mushroom", "6.5 to 12 m tall, caps 1.5 to 2.4 m", "6, in two stands", "Background, far", "kit: bell mushroom"],
        ["Giant snail, asleep", "1.8 m shell", "1", "Background, far", "kit: giant snail"],
        ["Glow moss patch; spore lantern; spore pod", "3 m; 0.5 m; 0.6 m", "1 each", "Background", "kit: glow moss patch; spore lantern; spore pod"],
        ["Seep crack with moss, drawn on the slime", "2.5 m", "4", "Play space (drawn on)", "kit: slime sheet with drips, plus a crack"],
        ["Fern clump", "4 m", "1", "Foreground", "kit: fern clump"],
    ],
    "effects": [
        "Slow drips of slime from the roof between the vines, falling to the ramp.",
        "A few leaves let go by the creeper, turning as they fall.",
    ],
    "notes": [
        "Note 37, and Parker, 11-13: the scenery is bell mushrooms, far back. Nothing orange is scenery.",
        "Note 39 (done): the scrap of mud on the landing shelf's lip is gone.",
    ],
}

# ------------------------------------------------------------------ 4.3 El Ascensor de Esporas
ASCENSOR = {
    "id": "4.3", "slug": "4_03_el_ascensor_de_esporas", "title": "El Ascensor de Esporas", "kind": "challenge",
    "window": [-248.5, 270.5, -226.5, 304.5], "screen": [-238.0, 286.0], "cut_y": 292.0, "climber": [-241.5, 277.5],
    "place": ("Half way up the slime ramp there is a hollow, and in the hollow grows a bed of spore pods, each as fat as a barrel. They "
              "breathe out in turn, one after another, and their breath is a column of warm air full of pale gold spores, going straight up "
              "for 15 m before it thins out. What is left drifts on up to the underside of the island, 9 m higher, where the spores "
              "have settled as gold fur. Three vines hang down out of that fur with dust on their ends, into the top of the column. "
              "So the lift has a bottom you can see making it, sides you can see, and a top you can see it reach for."),
    "keep": [
        "The column: 4.6 m wide, from 277 m to 292.5 m. Strong in its lower half, weak in its upper half.",
        "The three vines whose ends hang at 291.5 m, and the shelf at 295 m beside them.",
        "The ramp under it all: drift out of the column and you slide back to Sombreros.",
    ],
    "background": [
        {"name": "The dust shadow on the back wall", "z": [-6.5, -6.0], "tag": [-238.0, 296.8],
         "text": "Years of spores have stained the back wall pale gold in a stripe exactly as wide as the column, spreading out where it meets the roof. Even between puffs, you can see where the column is and how high it goes.",
         "draw": [["poly", [[-240.3, 276.6], [-235.7, 276.6], [-235.7, 299.3], [-233.2, 301.5], [-242.8, 301.5], [-240.3, 299.3]]]]},
        {"name": "The forest, far back", "z": [-10.0, -7.0], "tag": [-246.9, 283.2],
         "text": "One stand of three bell mushrooms on the back of the ramp, thin and pale blue-green, well to the west of the column.",
         "draw": _stand([(-247.9, 270.5, 11.5, 2.2), (-246.9, 270.5, 14.0, 2.6), (-246.0, 271.0, 9.0, 1.8)])},
        {"name": "The pod bed", "z": [-2.6, -1.3], "style": "pale", "tag": [-241.2, 275.2], "top": True,
         "text": "Five spore pods in a row on the ramp, just behind where you step in, under the whole width of the column. Each swells, then puffs a ball of spores upward, one after another, so the bed never stops. This is what makes the lift (note 38).",
         "draw": [["circle", x, _ramp(x) + 0.55, 0.55] for x in (-239.9, -238.9, -237.9, -236.9, -236.0)] +
                 [["line", x, _ramp(x) + 1.1, x, _ramp(x) + 1.5] for x in (-239.9, -238.9, -237.9, -236.9, -236.0)]},
        {"name": "The furred roof and the vines' root", "z": [-2.2, -1.2], "style": "pale", "tag": [-241.6, 300.6], "top": True,
         "text": "Above the column the island's underside is furred pale gold with settled spores. In the middle of the fur is a knot of root as big as a cart wheel, and the three vines hang from it.",
         "draw": [["poly", [[-240.9, 301.5], [-235.1, 301.5], [-236.0, 300.7], [-237.9, 300.35], [-239.8, 300.7]]]]},
        {"name": "The two shelves' stalks", "z": [-2.6, -1.2], "style": "pale", "tag": [-233.3, 286.5],
         "text": "The shelf you step off stands on a short stalk rooted in the ramp. The shelf you climb onto stands on a tall thin one, 15 m, also from the ramp, well clear of the column.",
         "draw": [_stalk(-242.5, 272.0, 276.9, 1.0, -242.9), _gills(-244.5, -240.5, 276.9, 0.5),
                  _stalk(-233.0, 279.0, 294.4, 1.1, -233.6), _skirt(-233.2, 290.8, 1.1), _gills(-235.5, -230.5, 294.4, 0.6)]},
        {"name": "A lantern pod", "z": [-2.2, -1.3], "style": "light", "tag": [-232.3, 292.2],
         "text": "On the tall stalk under the top shelf. With the glow of the pod bed below, the column is lit from both ends.",
         "draw": [["circle", -233.5, 292.2, 0.22], ["circle", -238.0, 276.6, 0.16]]},
    ],
    "play": [
        {"name": "The column, made visible", "z": [-1.2, 1.2], "style": "mark", "tag": [-238.0, 283.0],
         "text": "A thick stream of pale gold spores with soft edges, so you can see where to step in and where you would drop out. The spores rise fast and thick below 285 m and slow and thin above it, so you can see where the lift gives out. Small leaves and motes are carried up in it, and your climber's arms and legs drift upward while you are inside (note 38).",
         "draw": [["line", -240.3, 277.3, -240.3, 292.5], ["line", -235.7, 277.3, -235.7, 292.5], ["line", -240.3, 285.0, -235.7, 285.0]]},
        {"name": "Dusted vine ends", "z": [-0.3, 0.3], "style": "pale", "tag": [-241.3, 291.9],
         "text": "The last metre of each of the three vines is furred gold, the same as the roof. They are the first thing the spores reach.",
         "draw": [["circle", x, 291.75, 0.2] for x in (-239.4, -237.9, -236.4)]},
        {"name": "A dusted lip", "z": [-1.2, 1.2], "style": "pale", "tag": [-241.9, 278.2],
         "text": "The east lip of the shelf you step off is gold with spores for its last half metre. It marks the step in.",
         "draw": [["rect", -241.1, 277.5, -240.5, 277.64]]},
    ],
    "foreground": [],
    "explains": [
        ["The lift", "The breath of a bed of spore pods", "The pod bed at its foot, and its gold stain up the back wall"],
        ["The three vines at the top", "Vines hanging from a knot of root in the roof", "The root knot, and the spore fur all round it"],
        ["The shelf you step off", "An old cap turned up, on a short stalk", "Its stalk, rooted in the ramp"],
        ["The shelf at 295 m", "An old cap turned up, on a tall thin stalk", "Its stalk, 15 m, with a lantern pod under the cap"],
        ["The ramp", "The slime chute under the island", "The pod bed sitting in a hollow of it"],
    ],
    "pieces": [
        ["Spore pod bed: five pods that puff in turn", "4.6 m wide, pods 1.1 m", "1", "Background", "kit: spore pod bed"],
        ["Spore stain for the back wall", "4.6 m wide, 25 m tall", "1", "Background, far (painted)", "new, this area only"],
        ["Spore fur patch for a roof", "6 m", "1", "Play space (drawn on)", "new, this area only"],
        ["Root knot with three vines", "knot 1.2 m, vines 10 m", "1", "Play space, background", "kit: thick root; vine with leaves"],
        ["Old cap turned up like a saucer, on its stalk", "4 m and 5 m across", "2", "Play space, background", "kit: old cap turned up (rest shelf)"],
        ["Bell mushroom", "9 to 14 m tall, caps 1.8 to 2.6 m", "3, in one stand", "Background, far", "kit: bell mushroom"],
        ["Spore lantern", "0.5 m", "1", "Background", "kit: spore lantern"],
    ],
    "effects": [
        "The column of spores itself: dense and fast below, thin and slow above, with soft edges.",
        "Each pod swells for a moment before it puffs.",
        "A soft rushing sound that fades in as you enter the column and out as you leave it.",
        "Leaves caught in the column, going round and up.",
    ],
    "notes": [
        "Note 38 (not built yet): the updraught shows itself, shows what makes it, and shows where it weakens. The whole page is this note.",
        "Note 39 (done): the scrap of mud on the shelf's lip is gone.",
        "Parker, 11-13: the far forest is bell mushrooms. Nothing orange is scenery.",
        "The spores are pale gold, the colour of the pods' glow. Note 38's plan had them orange. Orange is kept for the caps that throw you, so a gold-dusted shelf or vine is never taken for one.",
    ],
}

# ------------------------------------------------------------------ 4.4 Rebote Doble
REBOTE = {
    "id": "4.4", "slug": "4_04_rebote_doble", "title": "Rebote Doble", "kind": "challenge",
    "window": [-238.5, 285.5, -211.5, 316.5], "screen": [-223.0, 301.0], "cut_y": 299.3, "climber": [-233.0, 295.0],
    "place": ("This is the pocket at the head of the slime ramp, where it runs into the room's east wall under the island's corner. There is "
              "no floor here, only slime, so nothing can grow up from below except on a long stalk. One mushroom did: its cap stands out "
              "over the pit on 10 m of stalk. One could not, and grew sideways out of the east wall on a bent stalk, tied to the rock "
              "with a web of white mycelium. Between them a root from the frog's garden above reaches out over the pit and lets one "
              "vine down. Cap, vine, wall cap: three living things that happen to stand in a line across a hole."),
    "keep": [
        "The first cap, where it is and leaning as it does. The vine and the knot it hangs from. The wall cap, 2.6 m, tipped 10 degrees.",
        "The small shelf at 311 m that the wall cap throws you back to, 2.8 m wide with the snail wall at its back.",
        "The pit: a miss goes down the ramp to Sombreros.",
    ],
    "background": [
        {"name": "The pocket's back wall and a stand of bell mushrooms", "z": [-10.0, -6.0], "tag": [-224.4, 298.4],
         "text": "Rounded mossy rock closes the pocket 6 m back, with slime running down it and boulders where it meets the ramp. Three bell mushrooms stand on the back of the ramp, thin and pale blue-green. They stand to one side of the vine and stop below its end, never behind it.",
         "draw": _stand([(-225.6, 285.5, 11.5, 2.2), (-224.4, 285.6, 12.2, 2.6), (-223.4, 286.2, 9.0, 1.8)]) +
                 [["poly", [[-226.5, 285.5], [-224.5, 287.2], [-222.6, 287.0], [-220.6, 289.4], [-218.4, 289.2], [-216.6, 291.6], [-215.2, 291.9], [-215.2, 285.5]]]]},
        {"name": "The first cap's stalk", "z": [-2.6, -1.2], "style": "pale", "tag": [-229.9, 286.4], "top": True,
         "text": "10 m of cream stalk from the ramp, rooted 2 m back and leaning forward, with its skirt near the top. It dips and rocks when the cap throws you (note 36).",
         "draw": [_stalk(-229.0, 281.8, 291.6, 0.9, -229.7), _skirt(-229.1, 289.3, 0.9), _gills(-230.4, -227.6, 291.75, 0.5)]},
        {"name": "The root from the frog's garden", "z": [-2.4, -1.2], "style": "pale", "tag": [-218.0, 312.9], "top": True,
         "text": "As thick as your body where it leaves the east wall, under the garden's lip. It arches out 6 m over the pit, a little behind you, and its tip turns forward and ends in the knot. The vine hangs from a root you can follow back to the wall with your eye.",
         "draw": [["poly", [[-215.2, 313.35], [-217.5, 312.65], [-219.55, 311.2], [-220.85, 309.4], [-221.35, 308.35],
                            [-220.85, 308.35], [-220.35, 309.1], [-219.0, 310.6], [-217.1, 311.95], [-215.2, 312.6]]]]},
        {"name": "The wall cap's bent stalk", "z": [-2.0, -1.2], "style": "pale", "tag": [-217.2, 296.4],
         "text": "A short thick stalk that comes out of the wall below the cap and bends up to it. The wet bracket you see today becomes its elbow.",
         "draw": [["poly", [[-215.2, 295.6], [-215.2, 297.0], [-216.2, 298.3], [-217.4, 298.55], [-216.4, 296.9]]]]},
        {"name": "The two shelves, from behind", "z": [-2.6, -1.2], "style": "pale", "tag": [-233.9, 289.5],
         "text": "The shelf you step off stands on its tall stalk from the ramp. The shelf you are thrown to is a shelf fungus growing from the snail wall, and two smaller shelves grow under it in steps, further back.",
         "draw": [_stalk(-233.0, 285.5, 294.4, 1.1, -233.4), _skirt(-233.2, 290.8, 1.1), _gills(-235.5, -230.5, 294.4, 0.6),
                  ["rect", -229.5, 309.45, -227.6, 309.8], ["rect", -229.5, 308.4, -228.3, 308.72]]},
        {"name": "Three lights", "z": [-2.4, -1.3], "style": "light", "tag": [-218.9, 310.0],
         "text": "A lantern pod on the root above the knot, one on the first cap's stalk, and glow moss where the ramp meets the east wall. The vine's top, the first cap's underside and the wall cap are the lit things.",
         "draw": [["circle", -219.6, 311.9, 0.22], ["circle", -229.5, 290.0, 0.22], ["rect", -217.6, 290.6, -215.3, 290.8]]},
    ],
    "play": [
        {"name": "The two caps, spotted", "z": [-1.2, 1.2], "style": "pale", "tag": [-227.0, 293.2],
         "text": "Both orange with pale spots, rolled rims and cream gills, flat on the face that throws (note 37). The wall cap is the garden's sideways cap: its rim rolls further on the low side. Both squash and spring (note 36).",
         "draw": [["circle", -230.35, 292.38, 0.3], ["circle", -227.65, 291.6, 0.3], ["circle", -217.8, 298.65, 0.28], ["circle", -215.45, 299.08, 0.28]]},
        {"name": "The knot", "z": [-0.3, 0.3], "style": "pale", "tag": [-222.3, 308.9], "top": True,
         "text": "The root's tip, a fist of wood with the vine grown out of it. Today it is a short bar in the air with nothing holding it.",
         "draw": [["circle", -221.1, 308.2, 0.38]]},
        {"name": "Mycelium web on the east wall", "z": [1.1, 1.2], "style": "mark", "tag": [-214.3, 301.6],
         "text": "A white web spread flat on the rock round the wall cap's stalk, 6 m tall. It ties the cap to the wall, and it is the pale patch that shows you from across the pit where the wall cap is.",
         "draw": [["poly", [[-215.2, 295.4], [-214.2, 296.6], [-213.9, 299.0], [-214.3, 301.2], [-215.2, 302.2]]]]},
    ],
    "foreground": [],
    "explains": [
        ["The first cap", "A mushroom that grew out over the pit", "Its 10 m stalk from the ramp"],
        ["The vine and its knot", "A vine hanging from the tip of a root", "The root, arching out from the east wall under the frog's garden"],
        ["The wall cap", "A mushroom that grew sideways out of the wall", "Its bent stalk, and the web that ties it to the rock"],
        ["The shelf at 311 m", "A shelf fungus on the snail wall", "Two smaller shelves under it, in steps"],
        ["The shelf you step off", "An old cap turned up", "Its tall stalk from the ramp"],
    ],
    "pieces": [
        ["Spotted mushroom cap with rolled rim and gills, flat on top", "3.0 m", "1", "Play space", "kit: spotted mushroom, middle"],
        ["Leaning stalk with skirt", "0.9 m thick, 10 m tall", "1", "Background", "kit: spotted mushroom stalk"],
        ["Sideways cap on a bent stalk", "2.6 m", "1", "Play space, background", "kit: sideways cap growing from a wall"],
        ["Mycelium web, flat on a wall", "1.3 m by 6 m", "1", "Play space (drawn on)", "kit: mycelium net"],
        ["Thick root arching from a wall, with a knot at its tip", "0.7 m thick, 8 m long", "1", "Background, play space", "kit: thick root"],
        ["Vine with leaves", "10 m", "1", "Play space", "kit: vine with leaves"],
        ["Shelf fungus", "2.8 m, 1.9 m, 1.2 m", "3", "Play space, background", "kit: shelf fungus"],
        ["Old cap turned up like a saucer, on its stalk", "5 m across", "1", "Play space, background", "kit: old cap turned up (rest shelf)"],
        ["Bell mushroom; mossy boulders", "9 to 12.2 m tall; 2 m", "3 and 4", "Background, far", "kit: bell mushroom; mossy boulder"],
        ["Spore lantern; glow moss patch", "0.5 m; 2.3 m", "2 and 1", "Background", "kit: spore lantern; glow moss patch"],
    ],
    "effects": [
        "A puff of spores from each cap as it throws you.",
        "The vine's leaves shake when you catch it.",
    ],
    "notes": [
        "Note 36 (not built yet): both caps squash and spring.",
        "Note 37 (not built yet): both caps are spotted. Parker, 11-13: the only scenery mushrooms are bell mushrooms, far back.",
        "Note 39 (done): no scraps of mud on the rest shelves.",
    ],
}

# ------------------------------------------------------------------ 4.5 La Baba
_WF = (-229.5, 311.6)                 # the snail wall's foot
_WU = (0.2058, 0.9786)                # one metre up the wall
_WN = (0.9786, -0.2058)               # one metre out of the wall


def _on_wall(s, out=0.0):
    return [_WF[0] + _WU[0] * s + _WN[0] * out, _WF[1] + _WU[1] * s + _WN[1] * out]


_PATCH = [1.2 + 4.5 * i for i in range(5)]   # where each snail's patch starts, in metres up the wall

LA_BABA = {
    "id": "4.5", "slug": "4_05_la_baba", "title": "La Baba", "kind": "challenge",
    "window": [-237.0, 306.5, -210.5, 338.5], "screen": [-226.0, 322.0], "cut_y": 322.0, "climber": [-228.0, 311.0],
    "place": ("This is the snails' wall, and the slime is theirs. Water seeps out from under the moss at the top of the island and runs "
              "down its east face, and five snails the size of carts live on that face and turn the water to slime. Each keeps to its own "
              "patch. It climbs 2.2 m to a patch of glowing moss, eats, rests, and goes back down to where the wet is. The wall leans out "
              "over the pit, and it curves round behind you into a cove where more snails sleep and where they keep their eggs. A snail's "
              "shell is the one dry thing on the wall."),
    "keep": [
        "The wall: 21.9 m of slime leaning out 12 degrees. The five snails, each crawling 2.2 m up and 2.2 m down and resting at each end.",
        "Their timing: odd and even snails half a round apart, so one rests at its top while the next rests at its bottom.",
        "The shell is the only hold. The foot and the head are slime.",
    ],
    "background": [
        {"name": "The forest, across the gap", "z": [-10.0, -7.0], "tag": [-212.2, 328.6],
         "text": "A stand of three bell mushrooms on the frog's garden, thin and pale blue-green, well behind the snails and to one side of them.",
         "draw": _stand([(-213.2, 318.0, 9.0, 2.0), (-212.2, 318.0, 12.0, 2.4), (-211.3, 318.0, 7.0, 1.6)])},
        {"name": "The cove", "z": [-6.0, -1.5], "tag": [-225.2, 310.3],
         "text": "The island's east face does not stop at the play space. It curves round to the east behind you and joins the back wall, so there is slick wall behind the snails all the way up, running with the same slime. Its top edge is the same mossy lip.",
         "draw": [["poly", [[-229.5, 306.5], [-229.5, 311.6], [-225.0, 333.0], [-220.8, 333.0], [-222.4, 325.0], [-224.0, 317.0], [-225.4, 311.0], [-225.8, 306.5]]],
                  ["poly", [[-225.0, 333.0], [-220.8, 333.0], [-220.6, 333.5], [-225.0, 333.6]], {"style": "pale"}]]},
        {"name": "Two more snails, asleep", "z": [-5.0, -3.5], "tag": [-221.9, 328.3],
         "text": "On the cove wall, 4 m back, drawn into their shells. They show that the five in front of you are part of a herd.",
         "draw": [["circle", -223.0, 328.2, 0.8, {"style": "pale"}], ["circle", -223.0, 328.2, 0.36, {"style": "line"}],
                  ["circle", -224.6, 314.6, 0.8, {"style": "pale"}], ["circle", -224.6, 314.6, 0.36, {"style": "line"}]]},
        {"name": "The eggs", "z": [-4.5, -3.5], "style": "light", "tag": [-222.2, 321.2],
         "text": "A clutch of snail eggs in a hollow of the cove wall, each the size of a football and glowing faintly green. They are the wall's lamp: the shells show dark and round against their light.",
         "draw": [["circle", -223.5, 321.9, 0.22], ["circle", -223.1, 321.6, 0.22], ["circle", -223.6, 321.4, 0.22], ["circle", -223.15, 322.15, 0.22], ["circle", -223.9, 321.75, 0.2]]},
        {"name": "The shelf's lower steps", "z": [-2.2, -1.2], "style": "pale", "tag": [-227.0, 309.0],
         "text": "The shelf you start from is the top one of three shelf fungi growing from the wall in steps. The lower two are smaller and further back.",
         "draw": [["rect", -229.5, 309.45, -227.6, 309.8], ["rect", -229.5, 308.4, -228.3, 308.72]]},
        {"name": "The root arm's root", "z": [-2.5, -1.2], "style": "pale", "tag": [-212.9, 319.8],
         "text": "Across the gap, on the lip of the frog's garden: the knee of root that the root arm grows up from.",
         "draw": [["poly", [[-214.9, 318.1], [-213.0, 318.1], [-213.3, 319.4], [-214.2, 320.5], [-214.9, 319.6]]]]},
    ],
    "play": [
        {"name": "Each snail's patch", "z": [-1.2, 1.2], "style": "mark", "tag": [-230.3, 318.6],
         "text": "A stripe of fresh slime on the wall, wetter and glossier than the rest, exactly as long as that snail's crawl. You can read where each snail goes, and where the gaps between them are, before any of them moves.",
         "draw": [["line"] + _on_wall(s - 0.9, -0.12) + _on_wall(s + 3.1, -0.12) for s in _PATCH]},
        {"name": "A patch of glow moss above each stripe", "z": [1.0, 1.2], "style": "light", "tag": [-229.0, 325.0],
         "text": "What each snail climbs for. It grows flat on the wall, drawn on like the stripe, small, green and glowing. It is not a thing that sticks out, so there is nothing to reach for. The top snail has none: it eats the moss of the lip.",
         "draw": [["circle"] + _on_wall(s + 3.45, 0.12) + [0.2] for s in _PATCH[:4]]},
        {"name": "The mossy lip", "z": [-1.2, 1.2], "style": "pale", "tag": [-226.8, 334.5],
         "text": "Thick moss hangs over the top edge of the wall, and the water comes out from under it. It is the dry edge you pull up onto.",
         "draw": [["poly", [[-226.0, 333.6], [-224.6, 333.6], [-224.75, 332.7], [-225.25, 333.05]]]]},
    ],
    "foreground": [],
    "explains": [
        ["The five shells", "Five giant snails, each grazing its own patch of wall", "More of the herd asleep in the cove behind, and their eggs"],
        ["The slime wall", "The island's east face, wet from a seep and slimed by the snails", "The same face curving round behind you as a cove"],
        ["Why each snail goes up and down", "It climbs to a patch of glow moss and goes back down to the wet", "The patch above each stripe, and the stripe of fresh slime"],
        ["The shelf you start from", "A shelf fungus on the wall", "Two smaller shelves under it"],
        ["The top edge", "The terrace's moss, hanging over", "The same lip along the top of the cove"],
    ],
    "pieces": [
        ["Giant snail on a wall: dry spiral shell, slimy foot and head", "shell 1 m, foot 1.9 m", "5", "Play space", "kit: giant snail"],
        ["Giant snail, asleep, drawn in", "shell 1.6 m", "2", "Background", "kit: giant snail"],
        ["Clutch of snail eggs, glowing", "eggs 0.4 m, clutch 1 m", "1", "Background", "new, this area only"],
        ["Cove wall: slime sheet, curved", "4 m wide, 27 m tall", "1", "Background", "kit: slime sheet with drips"],
        ["Stripe of fresh slime; patch of glow moss, flat", "4 m; 0.4 m", "5 and 4", "Play space (drawn on)", "kit: slime sheet with drips; glow moss patch"],
        ["Moss lip", "1.4 m, and 4 m along the cove", "2", "Play space, background", "new, shared with El Hongo Gigante's terrace"],
        ["Shelf fungus", "2.8 m, 1.9 m, 1.2 m", "3", "Play space, background", "kit: shelf fungus"],
        ["Bell mushroom", "7 to 12 m tall, caps 1.6 to 2.4 m", "3, in one stand", "Background, far", "kit: bell mushroom"],
    ],
    "effects": [
        "Slow drips down the wall and off each snail's foot.",
        "Each snail's eye stalks turn toward you when you are on its shell.",
    ],
    "notes": [
        "Note 39 (done): no scraps of mud on the rest shelves.",
        "Note 40 (done): nothing stands in front of the wall.",
        "Parker, 11-13: the far forest is bell mushrooms. The glow moss is drawn flat on the wall, so nothing that can't be held sticks out into the play space.",
    ],
}

# ------------------------------------------------------------------ 4.0 the frog's hut
_HX = -205.5   # the middle of the hut
# The roof: a low dome with eaves, hollow underneath so the room has 2.6 m of headroom.
_ROOF = ['poly', [[_HX - 2.4, 320.1], [_HX - 2.2, 321.0], [_HX - 1.44, 321.68], [_HX, 321.9], [_HX + 1.44, 321.68], [_HX + 2.2, 321.0],
                  [_HX + 2.4, 320.1], [_HX + 1.5, 320.6], [_HX - 1.5, 320.6]]]

LA_CHOZA = {
    "id": "4.0", "slug": "4_00_la_choza_de_la_rana", "title": "The frog's hut", "kind": "rest",
    "window": [-221.5, 313.5, -187.5, 333.5], "screen": [-205.5, 322.3], "cut_y": 318.6, "climber": [-206.1, 318.0],
    "place": ("East of the snail wall, across the gap, there is a quiet floor of moss at 318 m where nothing happens. It is where you land "
              "if you fly wide off the giant mushroom, and a root arm on its lip is the way back. It is also where the frog lives. The "
              "frog has hollowed out the stump of a fat old stalk and kept its cap on for a roof, and the moss has grown right over the "
              "cap. The side that faces you is open, like a doll's house: you walk in along the floor, and you are standing in its "
              "one room. The roof is solid: you can land on it, stand on it, and pull yourself up onto it by an eave. Behind the hut "
              "is a row of bell sprouts in a straight line, the only tidy thing in the garden. A snail sleeps beside it."),
    "keep": [
        "The floor, the lip, and the root arm with its 4.2 m reach over the gap: the way back to the shelf under the snail wall.",
        "Nothing here can hurt you or cost you height. It is a place to stop.",
        "The hut's walls and everything in it stay behind you. Only its roof is in the play space.",
    ],
    "background": [
        {"name": "The forest", "z": [-10.0, -6.0], "tag": [-201.2, 330.4],
         "text": "Three stands of bell mushrooms, thin and pale blue-green, 6 to 10 m back, with mossy boulders at their feet. The tallest stand is behind the hut, so the hut sits under a little wood. The big orange scenery mushroom and the two smaller ones that stand on this floor today are gone: nothing orange grows in the scenery (Parker, 11-13).",
         "draw": _stand([(-213.2, 318.0, 9.0, 2.0), (-212.2, 318.0, 12.0, 2.4), (-211.3, 318.0, 7.0, 1.6),
                         (-202.4, 318.0, 13.0, 2.6), (-201.2, 318.0, 14.0, 3.0), (-200.0, 318.0, 10.5, 2.2), (-199.0, 318.0, 12.5, 2.4), (-197.9, 318.0, 8.0, 1.8),
                         (-194.6, 318.0, 8.0, 1.8), (-193.6, 318.0, 9.6, 2.2), (-192.7, 318.0, 6.5, 1.6)]) +
                 [["poly", [[-215.2, 318.0], [-214.0, 319.2], [-211.8, 318.7], [-209.6, 319.5], [-203.0, 319.0], [-200.6, 319.7], [-197.2, 318.8],
                            [-194.6, 319.6], [-192.0, 318.9], [-190.0, 319.8], [-190.0, 318.0]]]]},
        {"name": "Shelf fungus up the east wall", "z": [-2.4, -1.4], "style": "pale", "tag": [-192.4, 330.3],
         "text": "Three brackets growing from the room's east wall in steps, 11 m up. Today one hangs there alone.",
         "draw": [["rect", -191.5, 329.6, -190.0, 329.9], ["rect", -191.0, 328.5, -190.0, 328.75], ["rect", -191.8, 330.9, -190.0, 331.2]]},
        {"name": "The frog's snail", "z": [-4.6, -3.4], "tag": [-196.2, 320.9],
         "text": "Asleep beside the hut, 4 m back, shell 1.8 m across. It is the one that stands here today.",
         "draw": _snail(-196.4, 318.0, 0.9)},
        {"name": "The frog's garden row", "z": [-3.4, -2.6], "style": "pale", "tag": [-201.4, 319.1],
         "text": "Six bell sprouts in a straight row behind the hut, knee high and pale blue-green, on a strip of turned moss. Somebody planted them.",
         "draw": [["circle", x, 318.22, 0.17] for x in (-202.6, -202.1, -201.6, -201.1, -200.6, -200.1)] + [["rect", -202.9, 318.0, -199.8, 318.07]]},
        {"name": "The hut's back wall", "z": [-2.7, -1.2], "style": "pale", "tag": [-206.3, 320.2], "top": True,
         "text": "The back half of a hollow stalk, 3 m wide and 2.6 m tall inside, cream, with a round window in it. A round door of bark stands open against it at the west end. This is the only made thing in the garden.",
         "draw": [["poly", [[_HX - 1.5, 318.0], [_HX + 1.5, 318.0], [_HX + 1.38, 320.6], [_HX - 1.38, 320.6]]],
                  ["circle", _HX + 0.45, 319.75, 0.38, {"style": "dark"}],
                  ["rect", _HX - 1.5, 318.0, _HX - 1.1, 319.9, {"style": "solid"}]]},
        {"name": "The roof's back half, and the chimney", "z": [-3.2, -1.2], "tag": [-207.9, 321.9], "top": True,
         "text": "The roof carries on 2 m back over the hut's back wall. All of it is green moss, shaggy at the eaves, with nothing orange showing: it is the colour of the garden's floors, which you stand on. A crooked chimney of hollow root comes out of the back half, behind the play space.",
         "draw": [_ROOF, ["poly", [[_HX + 1.0, 321.5], [_HX + 1.35, 321.4], [_HX + 1.55, 322.7], [_HX + 1.2, 322.75]], {"style": "pale"}]]},
        {"name": "The frog and its things", "z": [-2.2, -1.3], "style": "line", "tag": [-204.5, 319.2],
         "text": "The frog, 0.3 m, sits on a toadstool stool against the back wall. It breathes, blinks, watches you and croaks now and then. Beside it are a shelf with three jars and a small clay stove whose pipe is the chimney. A friendly thing, and nothing more (note 41).",
         "draw": [["circle", _HX + 0.55, 318.68, 0.17, {"style": "light"}], ["rect", _HX + 0.3, 318.0, _HX + 0.8, 318.5, {"style": "solid"}],
                  ["rect", _HX - 0.9, 319.45, _HX - 0.1, 319.53, {"style": "solid"}], ["rect", _HX + 1.0, 318.0, _HX + 1.4, 318.85, {"style": "solid"}],
                  ["line", _HX + 1.2, 318.85, _HX + 1.2, 320.6]]},
        {"name": "The lantern by the door", "z": [-1.6, -1.3], "style": "light", "tag": [-208.0, 320.3], "top": True,
         "text": "A spore pod on a hook of root at the west end of the back wall, glowing warm. It is the one warm light on this floor and you can see it from the snail wall.",
         "draw": [["circle", _HX - 1.75, 319.75, 0.2]]},
        {"name": "The root arm's root", "z": [-2.5, -1.2], "style": "pale", "tag": [-213.0, 320.0],
         "text": "A knee of root on the lip that the root arm grows up from, with the root running on back into the moss.",
         "draw": [["poly", [[-214.9, 318.1], [-213.0, 318.1], [-213.3, 319.4], [-214.2, 320.5], [-214.9, 319.6]]]]},
    ],
    "play": [
        {"name": "The roof: solid", "z": [-1.2, 1.2], "tag": [-203.3, 321.9], "top": True,
         "text": "The old stalk's cap, 4.8 m across, under a quilt of moss. It is a real thing in the play space (Parker, 11-13): a low dome you can land on and stand on. Its top is 3.9 m above the floor and nearly flat across the middle. Its eaves hang out 0.9 m past each end of the room and come down to 2.1 m above the floor, so you can reach one from outside the door and pull yourself up. It is hollow underneath: inside the room the ceiling is 2.6 m up, over your head.",
         "draw": [_ROOF]},
        {"name": "The rug", "z": [-1.0, 1.0], "style": "pale", "tag": [-205.3, 317.6],
         "text": "A round mat of woven mycelium on the garden's floor, 2.6 m across. It is the room's floor: there is no step and no sill.",
         "draw": [["rect", _HX - 1.3, 318.0, _HX + 1.3, 318.08]]},
        {"name": "Stepping stones", "z": [-0.8, 0.8], "style": "pale", "tag": [-210.5, 317.6],
         "text": "Five flat pebbles set in the moss from the root arm to the door, level with the floor.",
         "draw": [["rect", x - 0.3, 318.0, x + 0.3, 318.06] for x in (-213.0, -211.8, -210.6, -209.4, -208.2)]},
    ],
    "foreground": [
        {"name": "Fern", "z": [1.3, 1.9], "tag": [-190.6, 316.4], "top": True,
         "text": "One clump at the east corner, in front of the floor's rock face and below where you walk. Nothing stands in front of the hut: it has no front wall.",
         "draw": [["poly", [[-192.8, 315.4], [-192.3, 317.0], [-191.5, 316.0], [-190.7, 317.5], [-189.9, 316.1], [-189.2, 317.1], [-188.6, 315.4]]]]},
    ],
    "explains": [
        ["The floor you walk in on", "The frog's floor: a rug on the moss", "The hollow stalk's back wall, with its window, shelf and stove"],
        ["The roof you can stand on", "The old stalk's own cap, mossed over", "The back half of the same cap, and the chimney"],
        ["The frog", "The frog, at home", "Its snail asleep outside, and its row of bell sprouts"],
        ["The root arm", "An upright root that bends out over the gap", "The knee of root it grows from"],
        ["The moss floor", "A quiet corner of the garden", "Three stands of bell mushrooms, and shelf fungus up the east wall"],
    ],
    "pieces": [
        ["The frog's hut: half a hollow stalk with a round window and an open bark door", "3 m wide, 2.6 m tall inside", "1", "Background", "kit: the frog's hut"],
        ["The hut's roof: a mossed-over cap, solid", "4.8 m across, 1.8 m tall, 4.4 m front to back", "1", "Play space, carrying on into the background", "kit: the frog's hut"],
        ["The frog", "0.3 m", "1", "Background", "kit: the frog"],
        ["Toadstool stool; shelf with three jars; clay stove with a crooked root chimney", "0.5 m; 0.8 m; 0.85 m, chimney 3.8 m", "1 each", "Background", "new, this area only"],
        ["Woven mycelium rug; flat pebble", "2.6 m; 0.6 m", "1 and 5", "Play space (drawn on)", "new, this area only"],
        ["Spore lantern on a root hook", "0.5 m", "1", "Background", "kit: spore lantern"],
        ["Bell sprout", "0.4 m", "6", "Background", "kit: bell mushroom, as a sprout"],
        ["Giant snail, asleep", "1.8 m shell", "1", "Background", "kit: giant snail"],
        ["Root arm, and the knee it grows from", "post 3.8 m, arm 4.2 m", "1", "Play space, background", "kit: root arm"],
        ["Bell mushroom; mossy boulder", "6.5 to 14 m tall, caps 1.6 to 3 m; 2 m", "11, in three stands; 6", "Background, far", "kit: bell mushroom; mossy boulder"],
        ["Shelf fungus", "1 to 1.8 m", "3", "Background", "kit: shelf fungus"],
        ["Fern clump", "4 m", "1", "Foreground", "kit: fern clump"],
    ],
    "effects": [
        "A croak now and then, heard from about a screen away.",
        "A thin thread of smoke from the chimney.",
        "A low mist on the floor, as there is today.",
    ],
    "notes": [
        "Note 41 (not built yet): the hut you can go into, and the friendly frog in it. The floor at 318 m is the spot (Parker, 11-13).",
        "Course change (Parker, 11-13): the hut's roof is a new solid in the play space. It is a low dome 4.8 m wide, from 320.1 m at its eaves to 321.9 m at its top, centred on x -205.5. It can be held and stood on, and it does not throw.",
        "Parker, 11-13: the scenery is bell mushrooms. This floor's orange scenery mushrooms go, and the roof is moss green, so nothing orange here fails to throw you.",
        "Note 40 (done): the mushroom card that stood in front of this floor was moved behind it. In this design the bell mushrooms take its place.",
        "Note 60: this is the garden's frog.",
    ],
}

# ------------------------------------------------------------------ 4.6 El Hongo Gigante
_GILLS46 = [(-230.2, 340.83), (-228.8, 340.53), (-227.4, 340.24), (-226.0, 339.94), (-224.6, 339.64), (-223.2, 339.35)]  # each gill's x and top

HONGO_GIGANTE = {
    "id": "4.6", "slug": "4_06_el_hongo_gigante", "title": "El Hongo Gigante", "kind": "challenge",
    "window": [-246.0, 330.0, -215.5, 350.0], "screen": [-227.0, 339.2], "cut_y": 337.0, "climber": [-227.0, 333.6],
    "place": ("The biggest mushroom in the garden stands on the island's mossy top. Its cap is 19 m across and reaches out past the "
              "terrace's edge, over the gap. It is the same kind as every other mushroom here: stalk, skirt, cap and gills, orange with "
              "pale spots. But it is very old, and an old cap here sweats slime: its stalk and its whole cap are wet and can't be "
              "held, and under the slime its orange has gone to a dark rust, nearly black. Three things on it stay dry. The gills under its east half hang in the open air over the gap. The rim on that side "
              "has rolled up into a dry brim. And when the cap opened, the veil that covered its gills tore: most of it is the skirt on "
              "the stalk, and one shred still hangs from the east rim with a dried knob on its end. You go out along the gills, swing on "
              "the knob, and come up round the rim."),
    "keep": [
        "The cap's outline exactly, and what is slick on it: everything but the gills, the brim, the knob and the little mushrooms.",
        "The six gills, 1.4 m apart, the last one dry only at its foot. The knob 1 m outside the rim. The brim, 1.6 m.",
        "The terrace's floor is open from end to end under the cap: the stalk stands behind you and is not solid.",
    ],
    "background": [
        {"name": "The terrace's far side", "z": [-10.0, -6.0], "tag": [-243.4, 337.4],
         "text": "A stand of three young bell mushrooms on the terrace, thin and pale blue-green, and mossy boulders along the back. A snail sleeps on one of them. The orange scenery mushrooms that stand on the terrace today are gone (Parker, 11-13).",
         "draw": _stand([(-244.5, 333.6, 4.2, 1.2), (-243.4, 333.6, 5.0, 1.4), (-242.4, 333.6, 3.8, 1.1)]) +
                 [["poly", [[-246.0, 333.6], [-245.0, 334.6], [-243.0, 334.2], [-240.5, 334.9], [-238.0, 334.3], [-236.0, 334.8], [-228.0, 334.4], [-226.2, 334.9], [-225.0, 333.6]]]] +
                 _snail(-239.3, 334.8, 0.7)},
        {"name": "The stalk", "z": [-4.6, -1.3], "style": "pale", "tag": [-232.0, 335.3], "top": True,
         "text": "A real stalk, 5 m thick at the foot and 3 m at the top, standing behind the play space so the terrace stays open in front of it. It is wet and dark green, with runs of slime, so nobody reaches for it. Its skirt hangs 4 m up: a torn frill, the rest of the veil.",
         "draw": [["poly", [[-234.6, 333.6], [-229.4, 333.6], [-230.5, 341.0], [-233.5, 341.0]]],
                  ["poly", [[-234.4, 337.9], [-229.9, 337.9], [-229.0, 337.25], [-235.3, 337.25]], {"style": "solid"}]]},
        {"name": "The gill plates, running back", "z": [-5.5, -1.2], "tag": [-227.6, 338.9], "top": True,
         "text": "Under the cap, the gills are plates that run from the rim back to the stalk, 5 m deep, cream and dry on this side. Each gill you hold is the front end of one. The underside is lit from below, so the plates show as a pleated ceiling.",
         "draw": [["poly", [[-231.0, 341.0], [-222.5, 339.2], [-223.3, 338.5], [-226.0, 338.2], [-229.0, 338.5], [-230.7, 339.3]]]] +
                 [["line", gx, top - 0.15, -230.7, 339.7, {"style": "mark"}] for gx, top in _GILLS46[1:]]},
        {"name": "The wet gills of the west half", "z": [-5.5, -1.2], "style": "dark", "tag": [-237.6, 339.4],
         "text": "Under the west half the gills are slimed black and stuck together in sheets. You can see at a glance which half of the underside to use.",
         "draw": [["poly", [[-241.5, 339.2], [-233.0, 341.0], [-233.4, 340.1], [-236.0, 339.1], [-239.0, 338.4], [-241.3, 338.5]]]]},
        {"name": "A lantern pod and glow moss", "z": [-2.4, -1.3], "style": "light", "tag": [-230.5, 334.3],
         "text": "A lantern pod low on the stalk's east side and a patch of glow moss on the terrace. The cap is lit on its underside, which is where the route is.",
         "draw": [["circle", -229.75, 335.1, 0.22], ["rect", -243.0, 333.75, -240.4, 333.9]]},
    ],
    "play": [
        {"name": "A real cap: dark, wet, and plainly a mushroom", "z": [-1.2, 1.2], "style": "line", "tag": [-234.2, 342.2],
         "text": "Today it is drawn as brown faceted rock. It becomes a real mushroom cap, rounded, made to the same outline (note 42). It is not the bright orange of the caps that throw you. Under its slime the orange has gone to a dark rust, nearly black where the slime is thick, with a wet green-yellow sheen and slow drips from the rim. Its spots show only as faint ghosts under the wet. Dark, glossy and wet says it can't be held, and nothing about it says bounce (Parker, 11-13). Only raised, dry, cream things on it can be held.",
         "draw": [["circle", -227.4, 340.9, 0.4], ["circle", -230.2, 342.6, 0.5], ["circle", -235.5, 343.4, 0.5], ["circle", -238.2, 341.2, 0.4], ["circle", -232.3, 344.9, 0.4]]},
        {"name": "The crown: dry and cream", "z": [-1.2, 1.2], "style": "pale", "tag": [-232.0, 347.4],
         "text": "The flat top of the cap, where the slime has run off and the skin has dried and cracked into pale scales. It is orange in the course today and it does not throw. It becomes cream, the same dry cream as the gills and the brim, so the three dry places on the giant are one colour and the crown reads as a place to stand.",
         "draw": [["rect", -234.0, 346.2, -230.0, 346.5]]},
        {"name": "The brim", "z": [-1.2, 1.2], "style": "pale", "tag": [-222.0, 341.2], "top": True,
         "text": "The east rim's edge, rolled up and dry, cream like the gills. It is the pale lip you are aiming for when you let go.",
         "draw": [["rect", -224.1, 340.0, -222.5, 340.25], ["circle", -222.45, 340.1, 0.22]]},
        {"name": "The veil's shred and its knob", "z": [-0.3, 0.3], "style": "pale", "tag": [-220.4, 337.2],
         "text": "A strip of the torn veil hanging from the rim, wet and dark, with its end dried into a firm cream knob as big as two fists. The knob is the one thing on it you can hold, and it looks like it.",
         "draw": [["line", -222.5, 339.5, -221.55, 336.9], ["circle", -221.5, 336.6, 0.34]]},
        {"name": "Two little mushrooms on the shoulder", "z": [-0.4, 0.4], "style": "line", "tag": [-226.6, 344.4],
         "text": "Two small cream mushrooms, dry, standing on the slick shoulder: the second and the fourth of the five that are there today. The other three go (note 44). That leaves three gaps of about 2.8 m, 3.0 m and 2.8 m, each a short lunge up the slime.",
         "draw": [["circle", -225.96, 342.10, 0.45], ["circle", -228.03, 344.27, 0.45]]},
    ],
    "foreground": [
        {"name": "Fern and one small bell mushroom", "z": [1.3, 2.0], "tag": [-243.6, 331.3], "top": True,
         "text": "At the bottom left, in front of the island's rock and below the terrace's floor: a fern clump and one small bell mushroom, both dark.",
         "draw": [["poly", [[-245.8, 330.0], [-245.3, 331.9], [-244.5, 330.8], [-243.7, 332.5], [-242.9, 331.0], [-242.2, 332.0], [-241.6, 330.0]]],
                  _bell(-240.6, 330.0, 1.7, 0.8)]},
    ],
    "explains": [
        ["The six gills", "The front ends of the giant's gill plates", "The plates running 5 m back under the cap to the stalk"],
        ["The knob on its strand", "A shred of the torn veil, with a dried end", "The skirt on the stalk: the rest of the same veil"],
        ["The brim", "The rim's dry rolled edge", "The rim going on round behind, and the pleated underside it belongs to"],
        ["The two little mushrooms", "Two small mushrooms that have rooted on the giant's shoulder", "The bare slick shoulder going back, with nothing else on it. There are only two on purpose"],
        ["The dry crown", "The top of the cap, where the slime has run off and the skin has dried to cream scales", "The cap's far side falling away behind it, and the stalactite that hangs over it"],
        ["The slick cap", "The giant's cap, under its own slime", "Its wet dark stalk, and the slimed gills of its west half"],
        ["The terrace", "The island's mossy top", "Boulders, a stand of bell mushrooms and a sleeping snail"],
    ],
    "pieces": [
        ["The giant mushroom: cap to today's outline, dark rust under slime; stalk; torn skirt", "cap 19 m, stalk 5 m thick and 7.4 m tall", "1", "Play space, background", "kit: the giant mushroom, re-made (note 42)"],
        ["Dry scaled crown, cream", "4 m", "1", "Play space", "kit: the giant mushroom"],
        ["Gill plate, dry cream", "0.2 m thick, 3.5 to 5.5 m tall at the front, 5 m deep", "6", "Play space, running into the background", "kit: the giant mushroom"],
        ["Slimed gill sheet", "8 m", "1", "Background", "kit: slime sheet with drips"],
        ["Dry brim; veil shred with a dried knob", "1.6 m; 2.8 m with a 0.5 m knob", "1 each", "Play space", "kit: the giant mushroom"],
        ["Small cream mushroom for the shoulder", "0.5 m", "2", "Play space", "kit: spotted mushroom, small, in the hold's cream"],
        ["Bell mushroom, young; mossy boulder", "3.8 to 5 m tall, caps 1.1 to 1.4 m; 2 m", "3, in one stand; 5", "Background, far", "kit: bell mushroom; mossy boulder"],
        ["Giant snail, asleep", "1.4 m shell", "1", "Background, far", "kit: giant snail"],
        ["Spore lantern; glow moss patch", "0.5 m; 2.6 m", "1 each", "Background", "kit: spore lantern; glow moss patch"],
        ["Fern clump; one small bell mushroom", "4 m; 1.7 m", "1 each", "Foreground", "kit: fern clump; bell mushroom, small"],
    ],
    "effects": [
        "Slow drips of slime off the cap's rim onto the terrace.",
        "A wet sheen that moves a little on the cap as the camera moves.",
        "The knob's strand stretches and shakes when you swing on it.",
    ],
    "notes": [
        "Note 42 (not built yet): the giant is a real, readable mushroom. The route is the line of dry cream things on it.",
        "Parker, 11-13: an orange cap always means bounce. So the giant is not bright orange, as the note's plan had it: it is dark rust under slime.",
        "Course change, look only (Parker, 11-13): the crown is kind cap in the course, which paints it orange. It becomes a dry cream kind. Its shape and where it is do not change.",
        "Note 44 (not built yet): two little mushrooms on the shoulder, not five. This is a course change: three holds go.",
        "Note 37, and Parker, 11-13: the terrace's scenery is bell mushrooms, well back.",
    ],
}

# ------------------------------------------------------------------ 4.7 Trampolín en Cadena
_WEB47 = [(-235.9, 345.6), (-241.9, 347.6), (-237.1, 351.6), (-241.9, 355.1), (-237.1, 358.6), (-242.8, 361.0)]

TRAMPOLIN = {
    "id": "4.7", "slug": "4_07_trampolin_en_cadena", "title": "Trampolín en Cadena", "kind": "challenge",
    "window": [-252.5, 338.0, -225.5, 367.5], "screen": [-239.5, 352.5], "cut_y": 352.0, "climber": [-232.0, 346.5],
    "place": ("Over the giant's west shoulder the roof comes down in two masses of rock, both black with slime: a broad stalactite on the "
              "east, and on the west a spur that sticks out of the back wall. Between them is a slot 6.8 m wide with rock at its back. "
              "Nothing can root in slime, but mycelium can cling to it, and a white web has spread up the slot's back wall. Its fruit "
              "are four mushrooms that grow sideways out of the two walls, one above another, each on the wall the last one left in "
              "shade. A fifth sits low on the giant's shoulder. The web's thick cords run from cap to cap in the same zigzag you bounce."),
    "keep": [
        "The five caps, each where it is and leaning as it does. Each keeps the sideways speed you bring.",
        "The three root ends under the stalactite, and the drop from the last one onto the first cap.",
        "The two slick walls, and the mossy ledge on top of the spur.",
    ],
    "background": [
        {"name": "A stand of bell mushrooms", "z": [-10.0, -7.0], "tag": [-250.1, 340.4],
         "text": "Three bell mushrooms on the terrace below the spur, their pale blue-green caps just under it. Everything else behind this challenge is rock.",
         "draw": _stand([(-251.2, 338.0, 5.0, 2.0), (-250.1, 338.0, 5.9, 2.4), (-249.0, 338.0, 4.0, 1.7)])},
        {"name": "The slot's back wall", "z": [-3.4, -2.6], "tag": [-239.4, 364.6],
         "text": "Rounded wet rock that joins the stalactite to the spur 3 m behind you. It closes the slot, so there is no black gap behind the caps.",
         "draw": [["poly", [[-242.8, 344.5], [-236.0, 346.6], [-236.0, 367.5], [-242.8, 367.5]]]]},
        {"name": "The web", "z": [-3.0, -2.6], "style": "line", "tag": [-239.5, 361.6],
         "text": "White mycelium spread flat on the back wall. Its thick cords run from cap to cap, so the zigzag of the route is drawn on the wall behind it. Thinner strands fill in between. Three knots in it glow green and light the caps from behind.",
         "draw": [["line", _WEB47[i][0], _WEB47[i][1], _WEB47[i + 1][0], _WEB47[i + 1][1]] for i in range(5)] +
                 [["line", -242.8, 350.4, -236.0, 354.2, {"style": "mark"}], ["line", -236.0, 356.6, -242.8, 358.4, {"style": "mark"}],
                  ["line", -242.8, 363.6, -236.0, 362.2, {"style": "mark"}], ["line", -236.0, 365.6, -242.8, 366.6, {"style": "mark"}],
                  ["circle", -239.5, 349.6, 0.2, {"style": "light"}], ["circle", -239.5, 353.4, 0.2, {"style": "light"}], ["circle", -239.5, 356.9, 0.2, {"style": "light"}]]},
        {"name": "Four bent stalks", "z": [-1.9, -1.2], "style": "pale", "tag": [-235.2, 357.4], "top": True,
         "text": "Each sideways cap stands on a short thick stalk that comes out of the wall below it and bends up, with its foot in the web. The first cap needs none you can see: it grows straight out of the giant's shoulder.",
         "draw": [["poly", [[-242.8, 346.0], [-242.8, 347.1], [-241.6, 347.2], [-241.9, 346.6]]],
                  ["poly", [[-242.8, 353.5], [-242.8, 354.6], [-241.6, 354.7], [-241.9, 354.1]]],
                  ["poly", [[-236.0, 350.6], [-236.0, 351.6], [-237.2, 351.4], [-237.0, 350.8]]],
                  ["poly", [[-236.0, 357.2], [-236.0, 358.3], [-237.3, 358.2], [-237.0, 357.6]]]]},
        {"name": "The root down the stalactite", "z": [-2.0, -1.2], "style": "pale", "tag": [-228.5, 360.0],
         "text": "A root as thick as a leg comes down the stalactite's east face from the roof and goes in under its foot. The three root ends you hold are where it comes out again.",
         "draw": [["poly", [[-230.0, 367.5], [-229.2, 367.5], [-229.4, 358.0], [-229.1, 352.4], [-229.6, 350.6], [-230.0, 350.5]]]]},
        {"name": "Mossy stalactites under the spur", "z": [-2.4, -1.4], "style": "pale", "tag": [-246.2, 342.2],
         "text": "Two short thick ones, hanging over the giant's west rim. They make the spur's underside a roof and not a flat cut.",
         "draw": [["poly", [[-248.2, 344.5], [-246.8, 344.5], [-247.5, 342.3]]], ["poly", [[-245.6, 344.5], [-244.2, 344.5], [-244.9, 341.7]]]]},
        {"name": "A boulder and a lantern on the top ledge", "z": [-2.4, -1.2], "style": "pale", "tag": [-246.0, 363.3],
         "text": "A mossy boulder at the back of the ledge with a lantern pod on it. It is the light you bounce up toward.",
         "draw": [["poly", [[-248.9, 361.0], [-246.6, 361.0], [-246.9, 362.3], [-247.8, 362.7], [-248.7, 362.2]]],
                  ["circle", -246.75, 362.6, 0.22, {"style": "light"}]]},
    ],
    "play": [
        {"name": "Five caps, spotted", "z": [-1.2, 1.2], "style": "pale", "tag": [-239.5, 346.8],
         "text": "All five orange with pale spots, rolled rims and cream gills, flat on the face that throws (note 37). Each squashes toward its wall and springs back, and its stalk rocks (note 36). The tilt of each is easy to read because the spots tilt with it.",
         "draw": [["circle", -236.6, 344.65, 0.28], ["circle", -240.75, 347.15, 0.28], ["circle", -238.3, 351.15, 0.28], ["circle", -240.7, 354.7, 0.28], ["circle", -238.2, 358.0, 0.28]]},
        {"name": "Three root ends", "z": [-0.3, 0.3], "style": "pale", "tag": [-233.9, 347.7], "top": True,
         "text": "Tan, dry and knobbed at the tip, each a little lower than the last. They come out of a crack along the stalactite's foot, which is drawn on.",
         "draw": [["circle", -232.6, 348.5, 0.2], ["circle", -233.9, 349.0, 0.2], ["circle", -235.2, 349.5, 0.2], ["line", -235.6, 350.5, -232.2, 350.5]]},
        {"name": "Slime sheets on both walls", "z": [1.1, 1.2], "style": "mark", "tag": [-244.6, 352.0],
         "text": "The two walls are blank today. They get glossy black sheets with pale runs and slow drips, and a wet ring round the foot of each cap's stalk.",
         "draw": [["line", -242.95, 345.0, -242.95, 360.2], ["line", -235.85, 351.0, -235.85, 367.0]]},
    ],
    "foreground": [],
    "explains": [
        ["The four caps on the walls", "Mushrooms that grew sideways out of the slime walls", "A bent stalk under each, and the web on the back wall that they are the fruit of"],
        ["The first cap", "A mushroom that rooted on the giant's shoulder", "The giant's cap going back under it, and the web's lowest cord reaching down to it"],
        ["The three root ends", "The ends of a root that comes down through the stalactite", "The same root, thick, on the stalactite's east face"],
        ["The two slick walls", "A stalactite and a spur of rock", "The back wall that joins them, and the stalactites under the spur"],
        ["The ledge at the top", "The spur's mossy top", "A boulder with a lantern pod on it"],
    ],
    "pieces": [
        ["Sideways cap on a bent stalk", "2.4 m", "4", "Play space, background", "kit: sideways cap growing from a wall"],
        ["Spotted mushroom cap, flat on top, no stalk", "2.4 m", "1", "Play space", "kit: spotted mushroom, middle"],
        ["Mycelium web, flat on a wall, with thick cords and three glowing knots", "6.8 m wide, 22 m tall", "1", "Background", "kit: mycelium net"],
        ["Root end, knobbed", "1.2 to 2.2 m", "3", "Play space", "kit: vine with leaves; root"],
        ["Thick root down a rock face", "0.8 m thick, 17 m", "1", "Background", "kit: thick root"],
        ["Mossy stalactite, short", "1.4 m wide, 2.5 m long", "2", "Background", "kit: mossy stalactite"],
        ["Mossy boulder; spore lantern", "2.3 m; 0.5 m", "1 each", "Background", "kit: mossy boulder; spore lantern"],
        ["Slime sheet with drips", "15 m and 17 m tall", "2", "Play space (drawn on)", "kit: slime sheet with drips"],
        ["Bell mushroom", "8.4 to 10.3 m tall, caps 1.7 to 2.4 m", "3, in one stand", "Background, far", "kit: bell mushroom"],
    ],
    "effects": [
        "A puff of spores from each cap as it throws you, so a good run leaves five puffs hanging in the slot.",
        "The web's glowing knots pulse slowly, one after another, from the bottom up.",
    ],
    "notes": [
        "Note 36 (not built yet): the five caps squash and spring.",
        "Note 37 (not built yet): the five caps are spotted. Parker, 11-13: the only scenery mushrooms are bell mushrooms, far back.",
    ],
}

# ------------------------------------------------------------------ 4.8 Puente de Micelio
_L8_ROOT = ["poly", [[-263.75, 365.0], [-263.05, 365.0], [-263.1, 361.0], [-263.9, 361.0]]]

PUENTE = {
    "id": "4.8", "slug": "4_08_puente_de_micelio", "title": "Puente de Micelio", "kind": "challenge",
    "window": [-269.5, 350.5, -240.0, 372.5], "screen": [-256.0, 361.0], "cut_y": 361.6, "climber": [-246.0, 361.0],
    "place": ("Between the spur's top and a loop of root that hangs from the low roof to the west, a curtain of mycelium hangs from the "
              "roof like a net left to dry. Nobody built the bridge. It is the curtain's bottom edge, grown thick: two cords as thick as "
              "your wrist, with small shelf fungi along them for treads. Just under the middle, in a pouch of the curtain, sits a nest of "
              "spore pods. Two of them are fat. One points east and one points up and west, and they blow in turn. The curtain bellies "
              "out a moment before each one blows, so you see a gust coming before it reaches you. Under all of it is 27 m of air and "
              "the terrace."),
    "keep": [
        "The bridge: 14 m, sagging about 2 m, with its fifteen treads.",
        "The two gusts and their rhythm. The east half shoves you back east. The west half lifts you and pushes west. Each warns for 0.8 seconds.",
        "The ledge you leave and the root shelf you reach.",
    ],
    "background": [
        {"name": "A ledge of bell mushrooms, below", "z": [-10.0, -8.0], "tag": [-257.0, 351.2],
         "text": "A ledge on the far back wall, 8 m under the bridge, with two stands of young bell mushrooms on it, pale blue-green. You look down on their caps, which tells you how high the bridge is. Under the ledge the wall drops away to the terrace.",
         "draw": [["poly", [[-266.0, 350.5], [-266.0, 351.4], [-262.0, 351.9], [-257.0, 351.5], [-252.0, 352.0], [-247.5, 351.4], [-246.0, 350.5]]]] +
                 _stand([(-263.6, 351.6, 3.4, 1.2), (-262.5, 351.8, 4.6, 1.5), (-261.5, 351.8, 2.9, 1.1),
                         (-252.7, 351.9, 4.0, 1.4), (-251.6, 351.9, 4.8, 1.6), (-250.6, 351.8, 3.2, 1.2)])},
        {"name": "The curtain", "z": [-3.0, -1.2], "tag": [-252.2, 366.2], "top": True,
         "text": "A net of mycelium with holes as wide as your hand, hanging from the roof's stalactites to the bridge. It leans back, 3 m behind you at the top and touching the bridge at the bottom. It is dim grey-green and plainly a sheet, not a line. Before a gust it bellies the way the gust will blow.",
         "draw": [["poly", [[-262.0, 370.0], [-249.0, 370.0], [-249.0, 361.3], [-251.0, 360.5], [-254.0, 359.6], [-254.8, 357.0], [-257.4, 357.0],
                            [-258.0, 359.6], [-261.0, 360.5], [-263.0, 361.3], [-263.0, 365.0], [-262.0, 365.0]]],
                  ["line", -261.0, 370.0, -252.0, 360.2, {"style": "mark"}], ["line", -256.0, 370.0, -249.2, 362.6, {"style": "mark"}],
                  ["line", -250.5, 370.0, -260.0, 360.3, {"style": "mark"}], ["line", -256.5, 370.0, -262.8, 363.4, {"style": "mark"}]]},
        {"name": "Roof stalactites", "z": [-3.2, -1.6], "style": "pale", "tag": [-252.2, 369.0],
         "text": "Four short mossy ones along the roof. The curtain is draped from their tips. The two long ones that hang here today are replaced by these.",
         "draw": [["poly", [[x - 0.6, 370.0], [x + 0.6, 370.0], [x, 368.0]]] for x in (-250.6, -254.2, -257.8, -261.2)]},
        {"name": "The pod nest", "z": [-2.2, -1.3], "style": "pale", "tag": [-256.1, 356.2], "top": True,
         "text": "Two fat spore pods and a few small ones in a pouch of the curtain under the bridge's middle. The east one swells and blows east. Then the west one swells and blows up and west. They are what the gusts come from (note 38).",
         "draw": [["circle", -256.75, 358.1, 0.6], ["circle", -255.4, 358.1, 0.6], ["circle", -256.05, 357.3, 0.4],
                  ["line", -254.9, 358.3, -253.9, 358.5], ["line", -257.2, 358.5, -257.9, 359.3]]},
        {"name": "The root loop", "z": [-2.2, -1.2], "style": "pale", "tag": [-264.6, 363.0], "top": True,
         "text": "The shelf you reach is the bottom of a loop of root that comes down out of the low roof, as thick as a leg. It hangs from the roof by this root and is not on a stalk 27 m tall, as it is drawn today.",
         "draw": [_L8_ROOT]},
        {"name": "The bridge's east anchor", "z": [-2.4, -1.2], "style": "pale", "tag": [-247.0, 363.4],
         "text": "A mossy boulder at the back of the ledge, with the two cords wound round it and a lantern pod on top.",
         "draw": [["poly", [[-248.9, 361.0], [-246.6, 361.0], [-246.9, 362.3], [-247.8, 362.7], [-248.7, 362.2]]],
                  ["circle", -246.75, 362.6, 0.22, {"style": "light"}]]},
    ],
    "play": [
        {"name": "The bridge, grown and not built", "z": [-0.5, 0.5], "style": "line", "tag": [-252.6, 358.8],
         "text": "Two white cords of mycelium, with fifteen small flat shelf fungi along them as treads, cream and dry. No planks and no rope. The sketch shows its sag, which the course's own line does not.",
         "draw": [["line", -249.0, 361.0, -252.5, 359.9], ["line", -252.5, 359.9, -256.0, 359.2], ["line", -256.0, 359.2, -259.5, 359.9], ["line", -259.5, 359.9, -263.0, 361.0]]},
        {"name": "The gusts, made visible", "z": [-1.2, 1.2], "style": "mark", "tag": [-259.6, 364.6],
         "text": "Each gust is a burst of pale gold spores from its pod, thick enough to see its edges and which way it blows. A small puff comes first as the warning (note 38).",
         "draw": [["line", -255.2, 358.7, -250.0, 359.8], ["line", -256.9, 358.9, -261.6, 364.6]]},
        {"name": "The two tied ends", "z": [-0.5, 0.5], "style": "pale", "tag": [-264.2, 360.3],
         "text": "At the west end the cords are grown round the root loop. At the east end they run back to the boulder.",
         "draw": [["circle", -263.05, 361.05, 0.26], ["circle", -248.95, 361.05, 0.26]]},
    ],
    "foreground": [],
    "explains": [
        ["The bridge", "The thick bottom edge of a curtain of mycelium", "The curtain, hanging from the roof's stalactites behind it"],
        ["The gusts", "Two spore pods blowing in turn", "The pod nest under the bridge's middle, and the curtain bellying before each gust"],
        ["The shelf you reach", "The bottom of a loop of root", "The root, coming down out of the low roof"],
        ["The ledge you leave", "The spur's mossy top", "The boulder the bridge is tied to"],
        ["The drop", "27 m of air over the terrace", "A ledge of bell mushrooms on the far wall, seen from above"],
    ],
    "pieces": [
        ["Mycelium bridge: two cords with shelf-fungus treads", "14 m, treads 0.8 m", "1", "Play space", "kit: mycelium net; shelf fungus"],
        ["Mycelium curtain", "13 m wide, 9 to 13 m tall", "1", "Background", "kit: mycelium net, as one large piece"],
        ["Spore pod nest: two fat pods and three small", "2.6 m wide, fat pods 1.2 m", "1", "Background", "kit: spore pod bed"],
        ["Mossy stalactite, short", "1.2 m wide, 2 m long", "4", "Background", "kit: mossy stalactite"],
        ["Loop of thick root from a roof", "0.7 m thick, 4 m", "1", "Play space, background", "kit: thick root"],
        ["Mossy boulder; spore lantern", "2.3 m; 0.5 m", "1 each", "Background", "kit: mossy boulder; spore lantern"],
        ["Bell mushroom, young; far ledge of mossy rock", "2.9 to 4.8 m tall, caps 1.1 to 1.6 m; 20 m", "6, in two stands; 1", "Background, far", "kit: bell mushroom; mossy boulder"],
    ],
    "effects": [
        "Each gust as a burst of pale gold spores, with a small puff 0.8 seconds before it.",
        "The curtain bellying with each gust, and the bridge's treads lifting in the west one.",
        "A rushing sound for each gust, louder inside it.",
    ],
    "notes": [
        "Note 38 (not built yet): the gusts show themselves and show what makes them, the same way as the lift of El Ascensor de Esporas.",
        "Note 39 (done): no scraps of mud on the ledges.",
        "Parker, 11-13: the far forest is bell mushrooms. The gusts' spores are pale gold, not orange.",
        "Course change, look only: the bridge's planks and rope become shelf-fungus treads on mycelium cords. Where they are and how they move do not change.",
    ],
}

# ------------------------------------------------------------------ 4.9 Los Ojos
_EYES = [(-267.9, 359.5), (-278.8, 359.5), (-276.4, 361.5), (-270.8, 369.6), (-271.6, 363.2), (-281.6, 361.8), (-264.6, 364.3)]
_KNOTS49 = [(-267.5, 364.85), (-275.7, 364.85), (-277.0, 364.85), (-278.3, 364.85)]

LOS_OJOS = {
    "id": "4.9", "slug": "4_09_los_ojos", "title": "Los Ojos", "kind": "challenge",
    "window": [-288.0, 353.0, -259.5, 380.5], "screen": [-273.0, 363.5], "cut_y": 362.0, "climber": [-264.5, 361.0],
    "place": ("West of the bridge the roof comes down low, and behind you it comes down lower still: a brow of rock that hangs over the top "
              "of the west hall like the brow over an eye. It is the dimmest place in the garden, because the brow shuts out the glow "
              "from both ends. The brow's face is full of round hollows, and in each hollow a puffball grows on a short neck, straight "
              "out toward you: pale, round and faintly lit from inside. Seven eyes in seven sockets. Roots as thick as legs come through "
              "the roof here and run down the brow between the sockets. Their thin ends are the roots you hang from and their knuckles "
              "are the knots you hold. Under you there is nothing for 100 m."),
    "keep": [
        "The seven puffballs exactly where they are, each throwing you straight away from its middle, each growing back after 4 seconds.",
        "The four root knots on the ceiling and the seven hanging roots.",
        "It is dim, not black, and the puffballs are the brightest things in it (note 45).",
    ],
    "background": [
        {"name": "A far ledge of bell mushrooms", "z": [-10.0, -8.0], "tag": [-273.0, 353.4],
         "text": "Along the bottom of the screen: a ledge on the hall's far wall with three small stands of young bell mushrooms, pale blue-green and dim. It is the only thing under you. Below it the hall goes down 90 m.",
         "draw": [["poly", [[-288.0, 353.0], [-288.0, 353.6], [-282.0, 354.0], [-276.0, 353.5], [-270.0, 354.1], [-264.0, 353.6], [-259.5, 353.9], [-259.5, 353.0]]]] +
                 _stand([(-286.6, 353.6, 3.8, 1.4), (-285.5, 353.7, 5.0, 1.6), (-284.5, 353.8, 3.0, 1.2),
                         (-280.0, 353.9, 1.9, 1.0), (-279.0, 353.8, 2.3, 1.1), (-278.0, 353.6, 1.7, 0.9),
                         (-268.6, 354.0, 2.1, 1.0), (-267.6, 353.9, 1.6, 0.9), (-266.7, 353.8, 2.4, 1.1)])},
        {"name": "The brow", "z": [-3.4, -2.2], "tag": [-273.9, 358.5], "top": True,
         "text": "The back wall under the low roof: rounded dark rock that hangs down to about 357 m, with a ragged lower edge. It carries on up into the dome in the roof. With it there, the dark place has a back, and the puffballs have something to grow from.",
         "draw": [["poly", [[-283.2, 365.0], [-262.0, 365.0], [-262.0, 357.8], [-264.0, 356.6], [-267.0, 357.3], [-270.0, 356.2], [-273.5, 357.4],
                            [-277.0, 356.3], [-280.5, 357.5], [-283.2, 358.8]]],
                  ["rect", -275.0, 365.0, -268.9, 372.0]]},
        {"name": "The way out", "z": [-6.0, -3.0], "tag": [-284.2, 374.4],
         "text": "Past the brow the roof goes up again and the back wall is far and mossy, with the garden's green glow on it. One mossy stalactite hangs clear of the two roots you catch there. It is the light you travel toward.",
         "draw": [["poly", [[-288.0, 364.0], [-283.2, 364.0], [-283.2, 365.0], [-279.9, 365.0], [-279.9, 378.0], [-288.0, 378.0]]],
                  ["poly", [[-282.3, 378.0], [-280.9, 378.0], [-281.6, 375.4]], {"style": "pale"}],
                  ["rect", -287.6, 364.05, -285.2, 364.2, {"style": "light"}]]},
        {"name": "Seven sockets", "z": [-3.2, -1.2], "style": "dark", "tag": [-279.6, 362.2], "top": True,
         "text": "A round hollow in the brow behind each puffball, 1.9 m across, with the puffball's neck coming out of its middle toward you. A puffball that seems to float in the air today sits in a socket. When one bursts, its neck stays, and the new one swells on it.",
         "draw": [["circle", x, y, 0.95] for x, y in _EYES]},
        {"name": "Roots down the brow", "z": [-2.6, -1.3], "style": "pale", "tag": [-271.1, 360.0],
         "text": "Thick roots that come through the roof and run down the brow's face between the sockets, flat against the rock. One hangs free as a loop: its bottom is the shelf you start from. In the dome, a knot of root as big as a cart wheel is what the two roots there hang from.",
         "draw": [["poly", [[-270.35, 365.0], [-269.65, 365.0], [-269.75, 361.0], [-270.1, 357.0], [-270.75, 356.6], [-270.5, 361.0]]],
                  _L8_ROOT,
                  ["poly", [[-274.9, 372.0], [-272.6, 372.0], [-272.9, 370.4], [-273.8, 369.7], [-274.7, 370.5]]],
                  ["poly", [[-286.9, 378.0], [-286.1, 378.0], [-286.2, 371.0], [-286.0, 364.0], [-286.9, 364.0], [-287.0, 371.0]]]]},
    ],
    "play": [
        {"name": "The puffballs, as eyes", "z": [-0.6, 0.6], "style": "dark", "tag": [-266.4, 358.6],
         "text": "Each is round, pale and tight as a drum, 1.2 m across, breathing slowly, with one small dark pore on its face like a pupil. Each lights a pale pool round itself, and the light goes out when it bursts (note 45, done). All seven look alike: the two you need are not marked.",
         "draw": [["circle", x + 0.12, y + 0.1, 0.16] for x, y in _EYES]},
        {"name": "Root knots", "z": [-0.3, 0.3], "style": "line", "tag": [-277.0, 363.7],
         "text": "The four knots on the ceiling are knuckles of root, tan and dry, each with a root's line drawn on the ceiling running back from it.",
         "draw": [["circle", x, y, 0.36] for x, y in _KNOTS49]},
        {"name": "Where the dim place begins and ends", "z": [-1.2, 1.2], "style": "mark", "tag": [-282.9, 369.6],
         "text": "These two lines are the edges of the dim place in the course file. The light fades over the last 7 m on each side of them and never snaps (note 45, done).",
         "draw": [["line", -262.0, 355.5, -262.0, 364.8], ["line", -282.0, 356.0, -282.0, 373.0]]},
    ],
    "foreground": [],
    "explains": [
        ["The seven puffballs", "Puffballs growing out of the back wall on short necks", "A round socket in the brow behind each one"],
        ["The four root knots", "Knuckles of root on the ceiling", "Thick roots running down the brow between the sockets"],
        ["The roots you slide down and catch", "The thin ends of the same roots", "A knot of root in the dome, and a thick root down the far wall under the high roof"],
        ["The shelf you start from", "The bottom of a loop of root", "The loop, coming down out of the low roof"],
        ["The low ceiling", "The underside of a rock overhang", "The brow: the same rock, hanging lower behind you"],
        ["The drop", "The whole height of the west hall", "A ledge of bell mushrooms on the hall's far wall, and nothing under it"],
    ],
    "pieces": [
        ["Puffball on a short neck, with a dark pore", "1.2 m", "7", "Play space", "kit: puffball"],
        ["Brow wall with round sockets", "21 m wide, 8 m tall; sockets 1.9 m", "1 wall, 7 sockets", "Background", "new, this area only"],
        ["Thick root, flat on rock", "0.7 m thick, 8 to 14 m", "2", "Background", "kit: thick root"],
        ["Knot of root for a roof, with two hanging roots", "2.3 m", "1", "Background, play space", "kit: thick root; vine with leaves"],
        ["Root knuckle for a ceiling", "0.5 m", "4", "Play space", "kit: thick root"],
        ["Loop of thick root from a roof", "0.7 m thick, 4 m", "1", "Play space, background", "kit: thick root"],
        ["Mossy stalactite; glow moss patch", "1.4 m wide, 2.6 m long; 2.4 m", "1 each", "Background", "kit: mossy stalactite; glow moss patch"],
        ["Bell mushroom, young; far ledge of mossy rock", "1.6 to 5 m tall, caps 0.9 to 1.6 m; 28 m", "9, in three stands; 1", "Background, far", "kit: bell mushroom; mossy boulder"],
    ],
    "effects": [
        "Each puffball's pore turns slowly to face you, so the eyes seem to follow you.",
        "A burst is a cloud of pale spores, and the socket is dark until the next one grows.",
        "A few spores drifting up out of the hall below, lit as they pass a puffball.",
    ],
    "notes": [
        "Note 45 (done): the place is dim, the light fades in and out, and each puffball casts a pool of light.",
        "Note 40 (done): nothing stands in front.",
        "Parker, 11-13: the far forest is bell mushrooms.",
    ],
}

# ------------------------------------------------------------------ 4.10 El Salto del Pozo II
SALTO_II = {
    "id": "4.10", "slug": "4_10_el_salto_del_pozo_ii", "title": "El Salto del Pozo II", "kind": "challenge", "also": ["a5"],
    "window": [-314.0, 355.5, -280.5, 384.5], "screen": [-297.5, 370.0], "cut_y": 365.6, "climber": [-289.8, 370.5],
    "place": ("The second crossing of the well, and the place where the garden stops. On the east rim is the garden's last door, a cave "
              "mouth of rounded mossy rock. A root arm stands in it like a diving board, and under the board's lip the garden's "
              "grandest mushroom has grown out over the drop. On the west rim, 12 m away, is cut stone: the doorstep of the temple of "
              "the First Top Dog. A stone beam sticks out 5 m over the well above it, and two bronze chains hang from the beam, each with a "
              "long banner of cut paper behind it. Between the rims the well goes down out of sight. The garden has started across: "
              "roots have crept round the back of the shaft, and there is moss and a bell sprout or two in the joints of the temple's "
              "first blocks. Green light on one side, torch gold on the other."),
    "keep": [
        "The great cap's three throwing faces, exactly as they are: the middle 1 m, the east flank, and the west flank that hangs in the well.",
        "The root sill, the post, and the diving board whose lip is the launch.",
        "The two chains at 1.5 m apart, their ends 2 m above the temple's doorstep, and the doorstep's 2 m reach into the well. The beam above them grows; the chains do not move.",
        "You see what a miss costs before you jump: both rims and the drop are lit.",
    ],
    "background": [
        {"name": "The well's back wall", "z": [-7.0, -2.0], "tag": [-299.8, 358.2],
         "text": "The shaft is round, so behind the crossing its wall curves from one rim to the other, 7 m back at the middle. Slick black rock with pale runs, lit green from the east and gold from the west so that it shows. Today there is only black here (note 46).",
         "draw": [["rect", -306.0, 355.5, -294.0, 384.5]]},
        {"name": "Roots round the back of the shaft", "z": [-7.0, -5.0], "style": "pale", "tag": [-299.4, 364.2], "top": True,
         "text": "A band of thick roots that leaves the garden's rim, follows a crack round the back of the well, and reaches the temple's doorstep. Three small bell mushrooms grow on it, pale blue-green. It is far back and below the chains' ends, and it is how the garden got across.",
         "draw": [["poly", [[-294.0, 364.6], [-296.5, 363.4], [-299.5, 362.9], [-302.5, 363.2], [-306.0, 364.4], [-306.0, 363.6], [-302.5, 362.4],
                            [-299.5, 362.1], [-296.5, 362.6], [-294.0, 363.8]]],
                  ["circle", -297.6, 363.5, 0.22], ["circle", -300.6, 363.3, 0.22], ["circle", -303.6, 363.8, 0.22]]},
        {"name": "The garden's last wall", "z": [-6.0, -3.0], "tag": [-284.4, 375.6],
         "text": "Rounded mossy rock behind the cave mouth, with shelf fungus in three steps and a patch of glow moss at the floor. Nothing here is cut.",
         "draw": [["rect", -294.0, 364.0, -280.5, 378.0],
                  ["rect", -287.4, 367.1, -286.0, 367.4, {"style": "pale"}], ["rect", -287.0, 368.2, -285.4, 368.5, {"style": "pale"}], ["rect", -286.4, 369.3, -285.2, 369.6, {"style": "pale"}],
                  ["rect", -287.9, 364.05, -285.6, 364.2, {"style": "light"}]]},
        {"name": "The great cap's stalk", "z": [-3.4, -1.2], "style": "pale", "tag": [-296.4, 361.0], "top": True,
         "text": "Short and very thick, 1.8 m. It grows out of a crack in the well's wall 4 m below the rim, behind the play space, and leans out and forward to hold the cap over the drop. Skirt, and gills fanning out under the cap's west lip. Today the cap has no stalk at all.",
         "draw": [["poly", [[-296.2, 360.0], [-294.0, 359.2], [-294.0, 363.9], [-294.9, 364.4], [-295.9, 363.0]]],
                  ["poly", [[-296.9, 362.75], [-294.0, 362.3], [-294.0, 361.9], [-296.6, 362.2]]]]},
        {"name": "The diving board's mother root", "z": [-2.4, -1.3], "style": "pale", "tag": [-290.6, 375.8], "top": True,
         "text": "A root as thick as a barrel that comes down from the roof at the back of the cave mouth and spreads into the sill. The post and the board are one branch of it, turned toward the well. A lantern pod grows on it above the board.",
         "draw": [["poly", [[-290.0, 378.0], [-289.1, 378.0], [-289.3, 371.0], [-289.2, 364.0], [-290.3, 364.0], [-290.2, 371.0]]],
                  ["circle", -289.65, 373.4, 0.22, {"style": "light"}]]},
        {"name": "The temple's first hall", "z": [-7.0, -6.0], "tag": [-311.4, 374.4],
         "text": "Inside the door: a back wall of big pale blocks, 6 m back and in brown shadow, with the temple's carved band along it at two heights and one torch in a bronze bracket. It is drawn as the temple's own page for La Puerta has it, and shown here only as far as you can see from the garden.",
         "draw": [["rect", -314.0, 366.0, -309.0, 384.5],
                  ["rect", -314.0, 371.0, -309.0, 371.8, {"style": "pale"}], ["rect", -314.0, 376.8, -309.0, 377.6, {"style": "pale"}],
                  ["circle", -311.5, 369.0, 0.22, {"style": "light"}]]},
        {"name": "The door's side", "z": [-3.0, -1.2], "style": "pale", "tag": [-307.4, 374.4], "top": True,
         "text": "The side of the doorway through the well's wall: pale fitted blocks, stepping out at the head in three steps under the banner beam. The steps are what carries the beam so far out over the well.",
         "draw": [["poly", [[-309.0, 366.0], [-305.8, 366.0], [-305.8, 376.6], [-305.0, 376.6], [-305.0, 377.7], [-304.0, 377.7], [-304.0, 378.7],
                            [-302.8, 378.7], [-302.8, 379.7], [-309.0, 379.7]]]]},
        {"name": "The two banners", "z": [-1.5, -1.3], "style": "mark", "tag": [-300.0, 374.0], "top": True,
         "text": "A banner of cut paper hangs behind each chain, 1.1 m wide and 11 m long, whole and bright in the town's colours with the pug's paw on it. Today they hang inside the play space, 0.4 m behind the chains. They move back to just behind it, so that what is in the play space is the chain you catch and nothing else. With the well's wall lit behind them they are the brightest things across the drop: the target.",
         "draw": [["rect", -303.55, 368.5, -302.45, 379.5], ["rect", -302.05, 368.5, -300.95, 379.5]]},
        {"name": "Corbels under the doorstep", "z": [-2.2, -1.2], "style": "pale", "tag": [-304.6, 360.4],
         "text": "Three stepped stone brackets that carry the doorstep out over the well, with moss in their joints. The doorstep is the front of a stone landing, not a block stuck on a wall.",
         "draw": [["poly", [[-306.0, 362.0], [-304.2, 362.0], [-304.2, 361.3], [-304.9, 361.3], [-304.9, 360.5], [-305.5, 360.5], [-305.5, 359.7], [-306.0, 359.7]]]]},
    ],
    "play": [
        {"name": "The great cap, as a mushroom", "z": [-1.2, 1.2], "style": "pale", "tag": [-292.6, 367.3],
         "text": "Today it is a cream wedge with an orange band. It becomes the brightest spotted cap in the garden, with a fat rolled rim that droops over the well and cream gills under it. It is 4 m across the screen, as now, and about 6 m from front to back, most of that behind you. The three faces you land on keep their angles exactly. It squashes deepest of all the caps and springs highest (notes 36, 37, 46).",
         "draw": [["poly", [[-294.95, 365.2], [-294.55, 364.3], [-295.35, 364.0], [-295.6, 364.8]]],
                  ["circle", -293.3, 365.75, 0.2], ["circle", -292.1, 365.6, 0.16], ["circle", -294.2, 365.35, 0.16]]},
        {"name": "The beam, made longer", "z": [-1.2, 1.2], "tag": [-299.9, 380.9], "top": True,
         "text": "The temple's stone beam is real stone in the play space, and today it stops at x -303.5, short of both chains. It is made 2.6 m longer, to x -300.9, so both chains hang from it (Parker, 11-13). Under it, at the head of each chain, is a carved pug boss with a bronze ring. The new length can be held like the rest. The throw off the great cap tops out under it and passes below its end: to be checked again when it is built.",
         "draw": [["rect", -303.5, 379.7, -300.9, 380.3], ["circle", -303.0, 379.45, 0.28, {"style": "line"}], ["circle", -301.5, 379.45, 0.28, {"style": "line"}]]},
        {"name": "The garden on the temple's doorstep", "z": [0.9, 1.2], "style": "line", "tag": [-307.6, 364.2],
         "text": "Drawn onto the stone: one root across the doorstep's face, moss in the joints of its first blocks, and three pale bell sprouts no bigger than a hand. Nothing orange.",
         "draw": [["line", -304.0, 364.3, -306.4, 365.3], ["line", -306.4, 365.3, -308.9, 364.5],
                  ["circle", -305.2, 365.1, 0.14], ["circle", -307.4, 365.2, 0.12], ["circle", -308.4, 364.9, 0.12]]},
        {"name": "The doorstep's carved edge", "z": [1.0, 1.2], "style": "pale", "tag": [-303.2, 365.4],
         "text": "The well side of the doorstep gets the temple's carved band, deep and pale: pug faces, belts and bones. Deep pale carving is the temple's sign for stone you can hold.",
         "draw": [["rect", -304.4, 363.2, -304.0, 365.8]]},
    ],
    "foreground": [
        {"name": "Fern on the garden's rock", "z": [1.3, 1.9], "tag": [-292.0, 358.4], "top": True,
         "text": "One tuft growing from a crack, in front of the solid rock under the garden's sill. Nothing stands in front of the well, the chains or either rim.",
         "draw": [["poly", [[-293.6, 357.2], [-293.1, 358.9], [-292.4, 357.9], [-291.7, 359.4], [-291.0, 358.0], [-290.5, 358.8], [-290.2, 357.2]]]]},
    ],
    "explains": [
        ["The great cap", "The garden's grandest mushroom, grown out over the well", "Its thick stalk, growing from a crack in the well's wall and leaning out"],
        ["The sill, the post and the diving board", "One branch of a great root, turned toward the well", "The mother root, coming down from the roof at the back of the cave mouth"],
        ["The two chains", "Bronze chains hung from the temple's banner beam", "The stepped head of the door's side, which carries the beam, and a banner behind each chain"],
        ["The doorstep", "The front of the temple's stone landing", "Stepped corbels under it, and the first hall behind it"],
        ["The well", "The round shaft, between its second pair of doors", "Its back wall curving from rim to rim, with roots creeping round it"],
    ],
    "pieces": [
        ["The great cap: spotted, with a rolled rim, gills, and the three faces of today's outline", "4 m across, 6 m deep", "1", "Play space", "kit: the great cap at the well, re-made (note 46)"],
        ["Stalk for the great cap, short, leaning, with skirt", "1.8 m thick, 5 m", "1", "Background", "kit: the great cap at the well"],
        ["Root arm, with its sill", "post 6 m, board 4.5 m, sill 10.8 m", "1", "Play space", "kit: root arm"],
        ["Great root down a wall", "1 m thick, 14 m", "1", "Background", "kit: thick root"],
        ["Shelf fungus; glow moss patch; spore lantern", "1.2 to 1.6 m; 2.3 m; 0.5 m", "3, 1 and 1", "Background", "kit: shelf fungus; glow moss patch; spore lantern"],
        ["Well wall, curved, slick, with pale runs", "12 m wide, as tall as the screen", "1", "Background", "new, shared by the three well crossings"],
        ["Root band with three small bell mushrooms", "12 m long, 0.8 m thick", "1", "Background, far", "kit: thick root; bell mushroom, small"],
        ["Door side with a stepped head", "3.2 m wide, 13.7 m tall", "1", "Background", "the temple's kit: wall bay, cut to a door side"],
        ["Banner beam, stone, made longer", "9.1 m long, 0.6 m thick", "1", "Play space", "the temple's kit: wall bay stone; today's beam plus 2.6 m"],
        ["Chain boss: carved pug with a bronze ring", "0.9 m", "2", "Play space (under the beam)", "the temple's kit: chain boss"],
        ["Bronze chain", "12 m", "2", "Play space", "the temple's kit: bronze chain"],
        ["Banner of cut paper", "1.1 m by 11 m", "2", "Background, just behind the play space", "the temple's kit: banner"],
        ["Wall bay with carved band; torch", "5 m wide; 0.8 m", "2 and 1", "Background, far", "the temple's kit: wall bay, carved frieze strip, torch"],
        ["Stepped corbel; carved band for the doorstep", "1.8 m; 2.6 m", "1 each", "Background, play space (drawn on)", "the temple's kit: carved frieze strip"],
        ["Fern tuft", "3 m", "1", "Foreground", "kit: fern clump"],
    ],
    "effects": [
        "The great cap's deep squash and spring, with the biggest puff of spores in the garden.",
        "The banners stir, and swing when you catch a chain.",
        "Spores drift out of the garden's door over the well and stop half way. Torch smoke drifts out of the temple's.",
        "Drips falling down the well, lit as they pass each door.",
    ],
    "notes": [
        "Note 46 (not built yet): the great cap is a real mushroom, the grandest in the garden, and the well beside it is lit so you can see across and down.",
        "Note 36 (not built yet): it squashes and springs. Note 37 (not built yet): it is spotted.",
        "Note 45 (done): the dim place stops about 11 m east of the cap, so the jump is in the garden's full light.",
        "Course change (Parker, 11-13): the temple's stone beam is made 2.6 m longer, from x -303.5 to x -300.9 at the same height, so it reaches both chains. The new length is solid stone and can be held. The chains do not move. This is in the temple's course file.",
        "Scenery move: the two banners go from 0.4 m behind the chains to just behind the play space. Nothing you touch changes.",
        "Parker, 11-13: nothing orange grows in the scenery. The garden's reach into the temple is roots, moss and pale bell sprouts.",
    ],
}

AREAS = [SOMBREROS, LIANAS, ASCENSOR, REBOTE, LA_BABA, LA_CHOZA, HONGO_GIGANTE, TRAMPOLIN, PUENTE, LOS_OJOS, SALTO_II]

# New pieces that more than one area uses. The builder adds them to the biome's kit.
KIT_MORE = [
    ["Old cap turned up like a saucer, gills on top, on its own stalk", "3 to 6 m across", "every rest shelf from Sombreros to Rebote Doble", "Play space, on a background stalk", "new"],
    ["Spore pod bed: pods that puff in turn", "2 to 4.6 m wide", "the foot of El Ascensor de Esporas; the nest under Puente de Micelio", "Background", "new, made of spore_pod"],
    ["Root arm: an upright root that bends flat at its top", "post 4 to 6 m, arm 4 m", "the way back from the frog's garden; the diving board at the well", "Play space, rooted in the background", "new"],
]
