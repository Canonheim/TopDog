# The mine's areas, one dict each. Format: see ../build.py.
# 1.10 El Derrumbe is the worked example the other areas follow.

# ------------------------------------------------------------------ 1.10 El Derrumbe
_STUBS = [("E", 63.0), ("E", 64.3), ("W", 65.2), ("W", 66.5), ("W", 67.8), ("E", 68.7), ("E", 70.0), ("W", 70.9)]
_SETS = [63.0, 64.3, 65.2, 66.5, 67.8, 68.7, 70.0, 70.9, 72.2, 73.5, 74.8, 76.1]

_back_wall = [["rect", -222.1, 61.7, -218.5, 77.0, {"style": "solid"}]]
_back_wall += [["rect", -222.1, y - 0.16, -218.5, y, {"style": "pale"}] for y in _SETS]
_back_wall += [["rect", -220.9, 71.2, -219.2, 71.63, {"style": "dark"}], ["rect", -221.6, 73.8, -220.4, 74.23, {"style": "dark"}]]
_back_wall += [["line", -220.4, 77.0, -220.4, 62.2, {"style": "mark"}], ["line", -220.2, 77.0, -220.2, 62.2, {"style": "mark"}]]

_ladderway = []
for _side, _top in _STUBS:
    _ladderway.append(["rect", -220.1, _top - 0.34, -218.5, _top - 0.2] if _side == "E" else ["rect", -222.1, _top - 0.34, -220.5, _top - 0.2])
_ladderway += [["ladder", -219.0, 62.2, 64.0], ["ladder", -221.6, 65.1, 67.5], ["ladder", -219.0, 68.5, 69.3], ["ladder", -221.6, 70.8, 71.9]]

_sawn = []
for _side, _top in _STUBS:
    _x = -222.85 if _side == "W" else -218.1
    _sawn.append(["rect", _x, _top - 0.3, _x + 0.3, _top])

EL_DERRUMBE = {
    "id": "1.10", "slug": "1_10_el_derrumbe", "title": "El Derrumbe", "kind": "challenge",
    "window": [-232.0, 54.5, -211.5, 81.5], "screen": [-220.3, 69.4], "cut_y": 66.4, "climber": [-221.75, 66.5],
    "place": ("This was the miners' way between two levels of the mine: a timber-lined shaft, 3.6 m wide and 15 m tall, with a hoist in the "
              "front half to haul ore up and a ladder way in the back half for the men. Then the roof came in. The falling rock went down "
              "the middle of the shaft and snapped every cross-beam on its way. What is left sticking out of the two walls are the broken "
              "ends of those beams, and they are your holds. The ladders behind are still mostly there, out of reach. The roof is still coming down."),
    "keep": [
        "The eight timber stubs, each exactly where it is: two on the east wall, three on the west, two on the east, one on the west.",
        "The shaft's width, its slick walls, the rubble slope and the fallen beam at its foot.",
        "The two lines the rocks fall down, 20 cm apart in the middle of the shaft, and their rhythm (note 11).",
    ],
    "background": [
        {"name": "The chimney", "z": [-2.6, -1.2], "style": "dark", "tag": [-220.3, 79.6], "over": True,
         "text": "The hole in the roof the rocks fall out of, black inside, with snapped roof timbers and torn planking hanging round its mouth (note 12).",
         "draw": [["poly", [[-221.3, 77.0], [-219.3, 77.0], [-219.5, 81.2], [-221.0, 81.2]]]]},
        {"name": "The hoist's wheel", "z": [-2.2, -1.8], "style": "line", "tag": [-219.35, 75.2],
         "text": "Knocked crooked at the head of the shaft. It says what this shaft was for. No cable hangs from it: a hanging line reads as something to hold. The cable is down at the bottom.",
         "draw": [["circle", -219.35, 76.0, 0.55], ["line", -219.9, 76.75, -218.6, 75.4]]},
        {"name": "The shaft's back wall", "z": [-2.7, -2.4], "tag": [-220.3, 72.6], "top": True,
         "text": "Plank lining held by a timber frame every 1.3 m, some planks gone with dark rock showing. Two pale scars run down its middle where the rocks scrape it: they mark the two lines the rocks fall down, before you have seen a rock.",
         "draw": _back_wall},
        {"name": "A lantern left on a landing", "z": [-1.9, -1.6], "style": "light", "tag": [-220.9, 68.3],
         "text": "Today a lantern hangs in the very middle of the shaft, in the path of the rocks. It moves here, where it lights the back wall so a falling rock shows up dark against it.",
         "draw": [["circle", -221.75, 68.05, 0.17]]},
        {"name": "The ladder way", "z": [-2.4, -1.3], "style": "pale", "tag": [-221.6, 66.0],
         "text": "In the back half of the shaft: a half landing behind every stub, and short ladders between them, one snapped. You can see the easy way up the miners had, and you can't get to it.",
         "draw": _ladderway},
        {"name": "The foot of the fall", "z": [-2.6, -1.2], "tag": [-222.9, 59.3],
         "text": "The rubble heap carries on back into the scene behind the slope you walk up. Half buried in it: the hoist's crushed bucket and its cable in a heap.",
         "draw": [["poly", [[-225.4, 57.4], [-223.6, 58.7], [-221.6, 60.4], [-219.4, 62.0], [-218.5, 62.3], [-218.5, 57.4]]],
                  ["circle", -222.9, 58.35, 0.5, {"style": "line"}], ["circle", -224.6, 57.62, 0.3, {"style": "line"}]]},
        {"name": "The lower level's back wall", "z": [-2.8, -1.4], "tag": [-225.7, 58.6],
         "text": "Timber frames along the gallery, and a side tunnel boarded shut with two planks nailed across.",
         "draw": [["rect", -229.17, 57.4, -228.83, 61.7], ["rect", -227.07, 57.4, -226.73, 61.7], ["rect", -224.57, 57.4, -224.23, 61.7],
                  ["rect", -230.0, 61.55, -222.1, 61.85],
                  ["poly", [[-226.6, 57.4], [-226.6, 59.6], [-225.7, 60.3], [-224.8, 59.6], [-224.8, 57.4]], {"style": "dark"}],
                  ["line", -226.6, 57.6, -224.8, 59.5], ["line", -226.6, 59.5, -224.8, 57.6]]},
        {"name": "A warning sign", "z": [-1.5, -1.3], "style": "pale", "tag": [-223.45, 60.2],
         "text": "Beside the rubble: the mine's skull-pug diamond, for falling rock. The kit has it.",
         "draw": [["poly", [[-223.9, 59.2], [-223.45, 59.65], [-223.0, 59.2], [-223.45, 58.75]]], ["line", -223.45, 57.4, -223.45, 58.75]]},
        {"name": "The upper level", "z": [-2.6, -1.4], "tag": [-223.5, 74.1],
         "text": "Timber frames, and the hand winch that worked the hoist, standing at the shaft's edge with its handle in the air.",
         "draw": [["rect", -229.17, 72.0, -228.83, 75.8], ["rect", -226.77, 72.0, -226.43, 75.8], ["rect", -230.0, 75.65, -222.1, 75.95],
                  ["rect", -224.3, 72.0, -222.7, 72.35], ["circle", -223.5, 73.0, 0.6, {"style": "line"}], ["line", -223.5, 73.0, -224.5, 73.7]]},
    ],
    "play": [
        {"name": "The rock between the two levels", "z": [1.15, 1.2], "tag": [-226.4, 66.9],
         "text": "The biggest thing on the screen, and today a blank brown face. It gets a slanting seam of gold ore and a few old drill holes, drawn on its face.",
         "draw": [["poly", [[-229.6, 63.2], [-229.2, 63.0], [-222.6, 70.2], [-223.0, 70.5]]]]},
        {"name": "Sawn ends", "z": [1.1, 1.2], "style": "pale", "tag": [-223.25, 64.6],
         "text": "Each stub's beam runs on into the rock, and its square sawn end shows on the rock's face beside it. You can read where the holds are from the row of little squares up each wall.",
         "draw": _sawn + [["rect", -218.1, y - 0.3, -217.8, y] for y in (72.2, 73.5, 74.8)]},
        {"name": "Splintered ends and empty sockets", "z": [-0.2, 0.2], "style": "mark", "tag": [-221.0, 62.6],
         "text": "The stubs get splintered ends, and the walls get an empty socket wherever a beam is gone altogether. The three long lunges across the shaft are at exactly those places.",
         "draw": [["line", -221.35, 65.05, -219.3, 65.05], ["line", -221.35, 68.55, -219.3, 68.55], ["line", -221.35, 70.75, -219.2, 70.75]]},
    ],
    "foreground": [
        {"name": "The shaft's two front posts", "z": [1.2, 1.5], "tag": [-217.8, 66.6], "top": True,
         "text": "Thin, each broken in two or three places. They stand in front of the rock at the edges of the shaft, never in front of the open shaft, so they frame the climb and cover nothing you need to see.",
         "draw": [["rect", -222.42, 62.0, -222.12, 64.6], ["rect", -222.42, 65.9, -222.12, 69.3], ["rect", -222.42, 70.3, -222.12, 71.7],
                  ["rect", -218.48, 61.9, -218.18, 63.4], ["rect", -218.48, 65.0, -218.18, 68.0], ["rect", -218.48, 70.6, -218.18, 74.2], ["rect", -218.48, 75.2, -218.18, 77.0]]},
        {"name": "A low lip of rubble", "z": [1.3, 2.0], "style": "dark", "tag": [-226.0, 55.0],
         "text": "Along the very bottom of the frame, below the gallery's floor. It covers nothing you can stand on.",
         "draw": [["poly", [[-232, 54.5], [-232, 55.2], [-228.5, 55.45], [-224.0, 55.1], [-219.0, 55.4], [-214.0, 55.05], [-211.5, 55.3], [-211.5, 54.5]]]]},
    ],
    "explains": [
        ["The eight stubs", "The stumps of the shaft's cross-beams, snapped by the fall", "The half landing each beam carried, and its sawn end in the rock beside it"],
        ["The three long lunges", "Places where a whole beam was torn out", "Two empty sockets, one in each wall, and a ladder that ends in the air"],
        ["The slick walls", "Wet rock where the plank lining was stripped off", "The lining still in place on the back wall, to show what is missing here"],
        ["The rubble slope and the beam on it", "The roof, on the floor", "More rubble, the crushed bucket and the cable"],
        ["The falling rocks", "The roof, still coming", "The chimney above, the scars down the back wall"],
        ["The snapped board", "A plank off the lining, lying on the heap", "The gap in the back wall it came from"],
    ],
    "pieces": [
        ["Plank lining with its frame: whole, planks missing, smashed", "3.6 m wide, 1.3 m tall", "12", "Background", "kit: lining panel (mine), three looks"],
        ["Half landing, left and right", "1.6 m by 1 m", "8", "Background", "kit: half landing (mine)"],
        ["Ladder: whole, snapped, hanging by one rail", "0.5 m wide, 1.3 to 2.6 m", "4", "Background", "kit: ladder (mine)"],
        ["The chimney's mouth: hanging timbers and torn planks", "3.6 m wide, 2 m tall", "1", "Background", "new, this area only"],
        ["Hoist wheel on a bent bracket", "1.1 m across", "1", "Background", "kit: hoist wheel (mine), new bent bracket"],
        ["Hand winch", "1.6 m by 1.4 m", "1", "Background", "kit: hand winch (mine)"],
        ["Big rubble heap with the crushed bucket and cable heap", "5 m by 2.5 m, 3.5 m deep", "1", "Background", "kit: rubble heap, ore bucket, rope coil (mine)"],
        ["Boarded-up side tunnel", "1.8 m by 2.9 m", "1", "Background", "kit: boarded tunnel (mine)"],
        ["Timber frames along the gallery and the drift", "posts 0.35 m, 4 m tall", "5 posts, 2 caps", "Background", "kit: timber frame (mine)"],
        ["Skull-pug warning sign", "1 m by 2.2 m", "1", "Background", "kit: sign_pug_skull"],
        ["Splintered end for a stub; empty socket for a wall", "0.3 m", "8 ends, 6 sockets", "Play space", "kit: splintered end, socket (mine)"],
        ["Sawn beam end on the rock face; ore seam; drill holes", "0.3 m squares; a 10 m seam", "11 ends, 1 seam", "Play space (drawn on)", "kit: sawn end, ore seam (mine)"],
        ["Front post, in broken lengths", "0.3 m wide, 1.4 to 3.6 m", "7 lengths", "Foreground", "kit: timber frame post (mine), cut"],
    ],
    "effects": [
        "A trickle of dust out of the chimney just before each rock: the warning you can see, to go with the one you hear.",
        "A puff of dust where a rock hits the fallen beam.",
        "A few motes of dust drifting close to the camera.",
    ],
    "notes": [
        "Note 9 (done): the rocks leave by a snapped board at the beam's foot and are thrown back into the dark.",
        "Note 10 (done): a rock's knock-out reach is 0.60 m.",
        "Note 11 (done): the two sources follow one written rhythm.",
        "Note 12 (parked): the dark chimney the rocks fall out of. It is item 1 here.",
    ],
}

# ------------------------------------------------------------------ shorthand for the other areas' shapes
def _r(x0, y0, x1, y1, st=None):
    return ["rect", x0, y0, x1, y1] + ([{"style": st}] if st else [])


def _post(x, y0, y1, st=None, w=0.35):
    return _r(round(x - w / 2, 2), y0, round(x + w / 2, 2), y1, st)


def _ln(x0, y0, x1, y1, st=None):
    return ["line", x0, y0, x1, y1] + ([{"style": st}] if st else [])


def _c(x, y, r, st=None):
    return ["circle", x, y, r] + ([{"style": st}] if st else [])


def _p(pts, st=None):
    return ["poly", [list(q) for q in pts]] + ([{"style": st}] if st else [])


def _fall(y0, y1):
    """The great waterfall where it crosses a window: x -244 to -238 in the course."""
    return [_r(-244.0, y0, -238.0, y1, "pale")] + [_ln(x, y1, x, y0, "mark") for x in (-242.6, -241.0, -239.4)]


# ------------------------------------------------------------------ 1.0 The Sump and the frog's cave
_CAVE = [(-248.0, -27.5), (-248.0, -25.4), (-249.2, -25.4), (-249.2, -24.8), (-253.4, -24.8), (-253.4, -27.5)]
_PILES = [-228.5, -219.0]

SUMP = {
    "id": "1.0", "slug": "1_0_the_sump", "title": "The Sump and the frog's cave", "kind": "rest",
    "window": [-256.0, -37.0, -212.0, -15.0], "screen": [-246.0, -25.0], "cut_y": -27.3, "climber": [-250.4, -27.5],
    "place": ("This is the bottom level of the mine, and it is under water. When the mine worked, a watchman and a line of buckets kept this "
              "level dry, and a timber staging crossed it on piles. Then the water won. What is left above the surface is the heads of the "
              "piles, the caps of the drowned timber sets along the back wall, and the foot of the great waterfall, which lands here white "
              "and loud. Everything that falls far, from anywhere on the mountain, ends in this pool. At its west end, past the foot of the "
              "fall where nobody would think to swim, a doorway in the rock leads to the watchman's little room. It is dry, a lantern is lit "
              "in it, and the mine's frog lives there now."),
    "keep": [
        "The pool, its water level and its floor, and the piles, each where it is.",
        "The falling water's push, and the 6 m of calm under it just above the pool.",
        "The way out is still the long swim east to the landing stage. The cave leads nowhere.",
        "The only new things you can touch are the doorstep and the cave's floor, both from note 71.",
    ],
    "background": [
        {"name": "The frog's cave", "z": [-3.6, -1.2], "style": "dark", "tag": [-250.6, -24.0], "over": True, "top": True,
         "text": "A dry room cut in the rock behind the west wall: 4.2 m wide and 2.7 m tall, with a doorway 1.2 m deep and 2.1 m high. Its "
                 "floor and doorway come forward through the play space so you can walk in, and its front is cut away. Further back in it: "
                 "a little stove with a kettle, an upturned ore bucket with the frog sitting on it, a shelf of boots and masks that the "
                 "water has brought in, and one lit lantern, the only warm light at the bottom of the mine. Scratched up the door post are "
                 "the watchman's marks of the water rising. The last one is level with the doorstep.",
         "draw": [_p(_CAVE),
                  _r(-253.1, -27.5, -252.5, -26.8, "pale"), _c(-252.8, -26.62, 0.16, "pale"),
                  _r(-251.9, -27.5, -251.3, -27.08, "pale"), _c(-251.6, -26.9, 0.17, "pale"),
                  _r(-252.3, -25.75, -250.1, -25.65, "pale"), _c(-252.0, -25.5, 0.12, "line"), _c(-251.5, -25.5, 0.12, "line"),
                  _r(-251.0, -25.65, -250.8, -25.4, "pale"), _r(-250.6, -25.65, -250.4, -25.4, "pale"),
                  _c(-249.7, -25.3, 0.17, "light"),
                  _ln(-249.1, -27.3, -248.8, -27.3, "mark"), _ln(-249.1, -26.9, -248.8, -26.9, "mark"), _ln(-249.1, -26.5, -248.8, -26.5, "mark")]},
        {"name": "The rock the cave is cut in", "z": [-4.0, -1.2], "tag": [-254.6, -20.5],
         "text": "The course's west wall is a skin of rock 4 m thick with nothing behind it. The room needs rock all round it, so the wall "
                 "is carried on to the west and back. It is black and running with the fall's spray.",
         "draw": [_r(-256.0, -33.0, -252.0, -15.0)]},
        {"name": "The foot of the waterfall", "z": [-3.0, -1.2], "tag": [-241.0, -18.5], "top": True,
         "text": "The fall lands here after 113 m. From the pool it is a white column 6 m wide going up out of sight, and it is the "
                 "brightest thing in the picture. Where it hits, the water is white and the mist hides the west wall, so you find the "
                 "cave's doorway by its warm light. The sheet of water itself comes forward through the play space: you swim through its foot.",
         "draw": _fall(-28.0, -15.0) + [_c(-242.6, -27.8, 0.6, "pale"), _c(-241.0, -27.6, 0.8, "pale"), _c(-239.4, -27.8, 0.6, "pale")]},
        {"name": "The drowned level", "z": [-4.5, -3.0], "tag": [-233.6, -26.6], "top": True,
         "text": "Along the back wall, 3 to 4 m behind you: the timber sets of the bottom level, under water to their caps, and a side tunnel "
                 "boarded shut that you see through the water. A barrel from the works above is wedged against one cap. What goes over the "
                 "fall ends up here.",
         "draw": [_post(x, -33.0, -27.75) for x in (-236.6, -234.0, -231.4, -226.2, -223.6, -221.0)] +
                 [_r(-237.0, -27.75, -231.0, -27.45, "pale"), _r(-226.6, -27.75, -220.6, -27.45, "pale"),
                  _p([(-216.6, -33.0), (-216.6, -30.9), (-215.7, -30.2), (-214.8, -30.9), (-214.8, -33.0)], "dark"),
                  _ln(-216.6, -32.8, -214.8, -31.0), _ln(-216.6, -31.0, -214.8, -32.8), _c(-224.8, -27.0, 0.45, "line")]},
        {"name": "Carts on the bottom", "z": [-3.0, -1.4], "style": "line", "tag": [-238.9, -31.4],
         "text": "Lying on the floor of the pool behind you, seen through the water: three old ore carts, one on its side. The cart from El "
                 "Carrito Loco sinks here every time it goes over, so it has company.",
         "draw": [_r(-237.8, -33.0, -236.2, -32.1), _r(-233.6, -33.0, -232.0, -32.1),
                  _p([(-235.6, -33.0), (-234.3, -33.0), (-234.0, -31.7), (-235.3, -31.4)])]},
        {"name": "The staging's back row", "z": [-2.6, -2.0], "tag": [-227.4, -29.6],
         "text": "Behind each pile you can hold stands its twin, with a stub of the deck beam that joined them. The staging was a walkway two "
                 "piles wide. Its deck is gone.",
         "draw": [_post(x + 0.75, -33.0, -27.3, None, 0.4) for x in _PILES] + [_r(x + 0.2, -27.55, x + 0.95, -27.3, "pale") for x in _PILES]},
        {"name": "The way out", "z": [-2.1, -2.0], "style": "pale", "tag": [-217.4, -25.7],
         "text": "The mine's pug arrow, nailed to a back pile and pointing east along the piles. It is the only thing down here that tells "
                 "you which way to swim. The kit has it.",
         "draw": [_r(-218.45, -27.3, -218.05, -26.1, "solid"), _p([(-218.7, -26.95), (-217.7, -26.95), (-217.2, -26.6), (-217.7, -26.25), (-218.7, -26.25)])]},
    ],
    "play": [
        {"name": "The doorstep", "z": [-1.2, 1.2], "style": "pale", "tag": [-247.0, -29.2],
         "text": "New, from note 71: a rock step at the doorway, 0.8 m out from the wall, its top half a metre above the water and worn "
                 "hollow in the middle. It is pale dry rock, so it reads as a thing to hold, and it is how you pull yourself out. The "
                 "cave's floor behind it is the same pale rock.",
         "draw": [_r(-248.0, -28.3, -247.2, -27.5)]},
        {"name": "The piles", "z": [-0.2, 0.2], "style": "mark", "tag": [-229.6, -26.4],
         "text": "Each pile gets a dark stain up to the old high water mark and a rusted iron band round its head, so it reads as the leg of "
                 "something built and not as a pole in the water.",
         "draw": [_ln(x - 0.35, -27.5, x + 0.35, -27.5) for x in _PILES]},
    ],
    "foreground": [
        {"name": "The near bank", "z": [1.3, 3.2], "style": "dark", "tag": [-232.0, -35.4],
         "text": "A low lip of black wet rock along the bottom of the frame, below the pool's floor. It is the front card that is there "
                 "today, kept, because it covers only rock.",
         "draw": [_p([(-256.0, -37.0), (-256.0, -33.8), (-246.0, -33.5), (-236.0, -33.9), (-226.0, -33.6), (-218.0, -33.9), (-212.0, -33.6), (-212.0, -37.0)])]},
    ],
    "explains": [
        ["The piles", "The legs of the staging that crossed the bottom level", "Each pile's twin, and the stub of the deck beam between them"],
        ["The water", "The flooded bottom level of the mine", "The drowned timber sets, the boarded tunnel, the carts on the floor"],
        ["The doorstep and the cave's floor (new, note 71)", "The step and the floor of the watchman's room", "The room itself: stove, shelf, lantern and frog"],
        ["The falling water", "The foot of the great waterfall", "The white column going up out of the frame, and the mist at its foot"],
    ],
    "pieces": [
        ["The frog's cave room: floor, back wall and roof, front cut away", "4.2 m by 2.7 m; doorway 1.2 m by 2.1 m", "1", "Background and play space", "kit: the frog's cave room (mine). Drawn bigger than the sheet's 3 m by 2.5 m"],
        ["The frog, on an upturned ore bucket", "frog 0.3 m; bucket 0.9 m", "1", "Background", "kit: the frog, ore bucket (mine)"],
        ["Stove with a kettle; shelf of lost boots and masks; towel on a peg", "stove 0.6 m; shelf 2.2 m", "1 of each", "Background", "new, this area only"],
        ["Lantern, lit", "0.4 m", "1", "Background", "kit: lantern_hang"],
        ["Rock doorstep, worn", "0.8 m by 0.8 m", "1", "Play space", "new, this area only (note 71)"],
        ["Timber set, drowned to its cap", "posts 0.35 m; caps 6 m", "6 posts, 2 caps", "Background", "kit: timber set (mine)"],
        ["Boarded side tunnel", "1.8 m by 2.9 m", "1", "Background", "kit: boarded tunnel (mine)"],
        ["Ore cart, sunk", "1.6 m", "3", "Background", "kit: minecart"],
        ["Barrel", "0.9 m", "1", "Background", "from the black waters' kit: barrel"],
        ["Staging pile with a stub of deck beam", "0.4 m square, 5.7 m tall", "2", "Background", "kit: timber set post (mine)"],
        ["Pug arrow sign", "1 m", "1", "Background", "kit: sign_pug_arrow"],
        ["Iron band and water stain for a pile", "0.4 m", "4", "Play space (drawn on)", "kit: iron strap (mine, added by these pages)"],
        ["Waterfall: the sheet, the white water and the mist at its foot", "6 m wide", "1", "Background", "kit: waterfall pieces (the water overhaul, note 22)"],
        ["Low lip of wet rock", "44 m by 1 m", "1", "Foreground", "there today"],
    ],
    "effects": [
        "Warm light from the doorway lying on the water and in the mist. It is how the cave is found.",
        "The frog's croak, heard from about a screen away.",
        "Rings spreading on the water from the drips off the roof, 80 m up.",
    ],
    "notes": [
        "Note 71 (not built): the frog's cave. It is items 1 and 8 here. The doorway is in the west wall just above the water, as the note has it.",
        "Note 4: the note's first idea of a towel on a line becomes a towel on a peg. A line would be one more thing that looks like a rope.",
        "Note 6 (done): the cart falls for real and sinks here.",
        "Note 5 (done): the wind streaks are inside the waterfall's column, where the wind is.",
    ],
    "ask": [
        "The room is drawn 4.2 m wide. The sheet says 3 m and note 71 says about 5 m. Is 4.2 m right?",
    ],
}

# ------------------------------------------------------------------ 1.1 La Galería
_CAPS = [-155.4, -156.7, -158.0, -164.6, -165.9]
_SUNK_POSTS = [(-158.9, -12.0), (-160.3, -12.2), (-161.9, -12.0), (-163.5, -12.2)]

LA_GALERIA = {
    "id": "1.1", "slug": "1_1_la_galeria", "title": "La Galería", "kind": "challenge",
    "window": [-166.6, -18.6, -146.5, -5.5], "screen": [-158.5, -10.6], "cut_y": -10.6, "climber": [-154.0, -12.6],
    "place": ("This was the mine's main road: the gallery the ore carts ran along to the tunnel and out to the station. It is 5 m tall and "
              "timbered in two storeys, with a set of posts every 1.3 m because the miners knew this stretch was bad ground. They were "
              "right. Mud burst through the back wall, took 10 m of the floor down with it, and the lower posts of four sets went down too. "
              "What you cross on is what stayed up: the cross pieces of the sets either side of the hole, hanging from their upper posts, "
              "and the heads of the four sunk posts standing in the mud. It is the first place the mine asks you to tell honey-coloured "
              "timber from black mud."),
    "keep": [
        "The five low beams and the four posts in the mud, each exactly where it is.",
        "The pit: its two slick slopes, its depth, and the pale floor at its bottom that the two middle posts climb out of.",
        "The floor either side, and the door from the cart tunnel.",
    ],
    "background": [
        {"name": "The gallery's back wall", "z": [-1.6, -1.3], "tag": [-161.3, -8.2], "top": True,
         "text": "Plank lining from floor to roof, held by the timber sets. A long tie timber runs along it at head height, at exactly the "
                 "height of the beams you hold: they are one row. Over the pit the lining has burst outward and the tie is gone. That "
                 "black hole is where the mud came from.",
         "draw": [_r(-166.6, -12.6, -152.0, -7.5),
                  _r(-158.2, -10.78, -152.0, -10.42, "pale"), _r(-166.6, -10.78, -164.4, -10.42, "pale"), _r(-166.6, -7.85, -152.0, -7.5, "pale"),
                  _p([(-163.9, -12.6), (-163.6, -10.2), (-162.2, -9.3), (-160.4, -9.5), (-159.0, -10.4), (-158.7, -12.6)], "dark")]},
        {"name": "The back posts", "z": [-1.55, -1.2], "style": "pale", "tag": [-156.7, -8.6],
         "text": "Behind every beam stands its back post, with an iron strap where the beam is let into it. Over the pit the lower halves of "
                 "the posts are gone and the beams hang from the upper halves. Where four sets went down altogether, two stubs are left "
                 "under the roof. Today a post in hold-coloured timber hangs in the middle of the play space above each beam. It moves "
                 "back to the wall and goes grey.",
         "draw": [_post(x, -12.6, -7.85) for x in (-155.4, -165.9)] + [_post(x, -10.42, -7.85) for x in (-156.7, -158.0, -164.6)] +
                 [_post(x, -8.7, -7.85) for x in (-159.3, -163.2)]},
        {"name": "The slump and the cart", "z": [-3.0, -1.3], "tag": [-161.1, -13.6],
         "text": "The pit carries on back behind you as a tongue of black mud coming down out of the burst wall. In it, half sunk: an ore "
                 "cart on its side, and the bent ends of the rails, which stop at the brink on both sides. The cart is in the play space "
                 "today, in iron's own colour. It moves back and goes grey.",
         "draw": [_p([(-165.3, -12.9), (-163.4, -13.9), (-161.2, -14.3), (-158.8, -13.9), (-155.7, -12.9), (-160.0, -17.2), (-162.0, -17.2)]),
                  _p([(-162.0, -15.2), (-160.5, -14.6), (-160.2, -15.5), (-161.7, -16.1)], "line"),
                  _ln(-155.6, -12.75, -157.0, -13.6, "line"), _ln(-165.4, -12.75, -164.3, -13.4, "line")]},
        {"name": "The ore chute", "z": [-3.0, -1.3], "style": "pale", "tag": [-152.8, -8.5],
         "text": "High in the back wall by the door: a dark hole, and a timber chute coming down out of it on two wall brackets, to fill the "
                 "carts that stood on the rails below. It says what the rails are for, and why there is a cart in the mud.",
         "draw": [_r(-153.3, -9.0, -152.3, -8.0, "dark"), _p([(-152.9, -8.7), (-152.6, -9.15), (-154.6, -10.35), (-154.9, -9.9)])]},
        {"name": "A warning sign", "z": [-1.35, -1.3], "style": "pale", "tag": [-153.6, -11.95],
         "text": "The mine's skull-pug diamond, nailed to the lining at the brink of the pit. It is the first one you meet. The kit has it.",
         "draw": [_p([(-154.0, -11.3), (-153.6, -10.9), (-153.2, -11.3), (-153.6, -11.7)])]},
        {"name": "Two lanterns", "z": [-1.5, -1.3], "style": "light", "tag": [-154.6, -8.3],
         "text": "Where they hang today, one over each brink, but hung from the roof timber at the back wall and not in the play space. "
                 "Between them the pit is the darkest part of the gallery.",
         "draw": [_c(-154.0, -8.6, 0.17), _c(-166.3, -8.6, 0.17)]},
    ],
    "play": [
        {"name": "The door's timber set (there today)", "z": [-1.3, 1.3], "style": "line", "tag": [-151.4, -9.2],
         "text": "The last set of the cart tunnel and the first of the mine: a back post, a front post and a cap, and you walk between the "
                 "posts. It stays. It is grey and wet, as the tunnel's sets have become by here.",
         "draw": [_r(-152.3, -12.6, -151.95, -7.5)]},
        {"name": "The four sunk posts", "z": [-0.3, 0.3], "style": "pale", "tag": [-164.05, -11.75],
         "text": "Each post standing in the mud keeps the cut tongue on its head where a beam once sat, and is black with mud up to a tide "
                 "line. You can see they are the lower posts of the four missing sets, gone down 2 m with the floor.",
         "draw": [_r(x - 0.1, y, x + 0.1, y + 0.15) for x, y in _SUNK_POSTS]},
        {"name": "The beams' torn ends", "z": [1.1, 1.2], "style": "pale", "tag": [-157.35, -11.3],
         "text": "Each of the five beams shows its end to the camera, splintered where its front post tore away. The front posts are in the pit.",
         "draw": [_r(x - 0.11, -10.71, x + 0.11, -10.49) for x in _CAPS]},
        {"name": "The mud", "z": [-1.2, 1.2], "style": "mark", "tag": [-157.2, -15.3],
         "text": "Black, glossy and wet from brink to bottom, with slide marks and pale drips, and nothing pale drawn anywhere on it, so the "
                 "pit reads as a pit (note 52). The floor at the bottom is a slab of the old gallery floor, dry and pale, with a sleeper still on it.",
         "draw": [_ln(-155.7, -13.2, -159.8, -17.1), _ln(-165.3, -13.2, -162.2, -17.1)]},
    ],
    "foreground": [
        {"name": "A low lip of rubble", "z": [1.3, 2.0], "style": "dark", "tag": [-150.5, -17.2],
         "text": "Mud-caked rubble and a length of bent rail along the bottom of the frame, below the floor and below the pit. It stands in "
                 "front of rock only.",
         "draw": [_p([(-166.6, -18.6), (-166.6, -15.6), (-165.0, -15.9), (-163.6, -16.9), (-162.4, -18.1), (-159.6, -18.1), (-157.2, -16.6),
                      (-155.5, -15.6), (-151.0, -15.9), (-146.5, -15.5), (-146.5, -18.6)])]},
    ],
    "explains": [
        ["The five low beams", "The cross pieces of the gallery's timber sets, seen end-on. They are the lower storey's, so they sit at head height", "Each beam's back post, and the long tie timber along the wall at the same height"],
        ["The four posts in the mud", "The lower posts of the four sets that went down with the floor", "The gap in the timbering above them, with two stubs left under the roof"],
        ["The mud pit", "Bad ground: the mud burst through the back wall and took 10 m of floor", "The burst lining, the tongue of mud, the cart and the bent rails"],
        ["The floor by the door", "The loading place, where the carts were filled", "The ore chute in the back wall, and the rails that end at the brink"],
        ["The pit's floor", "A slab of the old gallery floor, 4.3 m down", "The same mud all round it"],
    ],
    "pieces": [
        ["Plank lining with its frame: whole, smashed", "1.3 m wide, 2.5 m tall", "22 whole, 4 smashed", "Background", "kit: lining panel (mine)"],
        ["Back post: full height, upper half, stub", "0.35 m square; 4.75 m, 2.6 m, 0.85 m", "2, 3 and 2", "Background", "kit: timber set post (mine), cut"],
        ["Tie timber and roof timber along the wall", "0.35 m square, 2.6 m lengths", "9", "Background", "kit: mine_beam"],
        ["Iron strap where a beam meets its post", "0.3 m", "5", "Background", "kit: iron strap (mine, added by these pages)"],
        ["Tongue of mud coming out of the wall", "10 m wide, 4.5 m tall, 1.7 m deep", "1", "Background", "new, this area only"],
        ["Ore cart, on its side, half sunk", "1.6 m", "1", "Background", "kit: minecart"],
        ["Broken rail, bent down", "2 m", "2", "Background", "kit: rail_broken"],
        ["Ore chute on wall brackets, with its dark hole", "1 m wide, 2.4 m long", "1", "Background", "kit: ore chute, dark hole (mine)"],
        ["Skull-pug warning sign", "1 m", "1", "Background", "kit: sign_pug_skull"],
        ["Hanging lantern", "0.4 m", "2", "Background", "kit: lantern_hang"],
        ["Door set: two posts and a cap", "0.6 m wide, 5 m tall, 2.6 m deep", "1", "Play space (there today)", "kit: mine_frame"],
        ["Cut tongue for a post's head; splintered end for a beam", "0.2 m; 0.3 m", "4 and 5", "Play space (drawn on)", "kit: splintered end (mine); the tongue is new"],
        ["Low lip of rubble with a bent rail", "20 m by 1 m, in two heaps", "1", "Foreground", "kit: rubble heap, rail_broken"],
    ],
    "effects": [
        "A slow bubble now and then in the mud at the back of the pit.",
        "One drip from the roof onto the pit's floor.",
        "Cold blue light and a little mist at the far west end of the gallery, where it opens on the cavern.",
    ],
    "notes": [
        "Note 52: this pit already can't be climbed out of by its sides. They are slick mud. The design keeps every pale mark off them.",
        "Note 40: nothing stands in front of the gallery but the low lip under the floor.",
    ],
}

# ------------------------------------------------------------------ 1.1b The frozen climber's camp
_TALLY = [_ln(round(-167.5 + 0.14 * k, 2), -11.72, round(-167.5 + 0.14 * k, 2), -11.1) for k in range(9) if k != 5]

THE_CAMP = {
    "id": "1.1b", "slug": "1_1b_the_camp", "title": "The frozen climber's camp", "kind": "rest",
    "window": [-177.5, -15.0, -163.5, -5.5], "cut_y": -11.6,
    "place": ("The west end of the gallery, between the mud pit and the mouth that opens on the cavern. The ladder shaft comes down "
              "through the roof here, so this was where the miners waited their turn to climb: there is a bench cut into the back wall for "
              "them. Long after they left, somebody who came to climb the Peak made camp on that bench, at the foot of the first hard "
              "climb. He tried the ladder, came back, scratched a mark, and tried again. He is still here, sitting against the post with "
              "his lantern gone cold."),
    "keep": [
        "The frozen climber, seated exactly where he is.",
        "The floor, the foot of the ladder, and the mouth onto the incline.",
    ],
    "background": [
        {"name": "The gallery's back wall", "z": [-1.6, -1.2], "tag": [-172.9, -9.6],
         "text": "The same plank lining and timber sets as the rest of the gallery, on good ground here, so the posts are 2 m apart or more "
                 "and all of them stand.",
         "draw": [_r(-176.0, -12.6, -163.5, -7.5), _r(-176.0, -7.85, -163.5, -7.5, "pale"), _r(-166.4, -10.78, -163.5, -10.42, "pale")] +
                 [_post(x, -12.6, -7.85, "pale") for x in (-165.9, -167.75, -170.3, -173.6, -175.95)]},
        {"name": "The miners' waiting room", "z": [-2.5, -1.3], "style": "dark", "tag": [-169.0, -10.1], "top": True,
         "text": "A shallow room cut into the back wall, 2.1 m wide and 1.2 m deep, with a plank bench. The climber's bedroll is laid out "
                 "on the bench. Above it is a rail of wooden pegs with one miner's lamp still on it. Today the bedroll lies in the play "
                 "space at his feet. It moves back onto the bench.",
         "draw": [_r(-170.1, -12.6, -167.95, -10.5), _r(-170.1, -12.25, -167.95, -12.1, "pale"), _r(-169.9, -12.1, -168.4, -11.86, "pale"),
                  _r(-169.9, -10.95, -168.2, -10.87, "pale"), _c(-169.5, -11.12, 0.1, "line")]},
        {"name": "His things", "z": [-1.5, -1.25], "style": "line", "tag": [-165.4, -11.9],
         "text": "Against the wall beside him: his lantern, cold, with no light on it. A coil of rope lying flat. A pickaxe leaning on the "
                 "post. They are the kit's camp pieces, set a little further back than today so that nothing lies where you walk.",
         "draw": [_c(-166.2, -12.38, 0.17), _c(-166.65, -12.45, 0.14), _ln(-167.62, -12.6, -167.3, -11.8), _ln(-167.5, -11.85, -167.1, -11.8)]},
        {"name": "The tally marks", "z": [-1.32, -1.3], "style": "mark", "tag": [-166.9, -10.7],
         "text": "Scratched into the lining above his shoulder, in fives: the count he kept. Pale scratches on grey planks, the brightest "
                 "marks on the wall. The last row stops part way along.",
         "draw": _TALLY},
        {"name": "The lantern that still burns", "z": [-1.5, -1.3], "style": "light", "tag": [-166.3, -8.0],
         "text": "The miners' lantern above him is lit, as it is today. His own is not. The one pool of amber light at this end of the "
                 "gallery falls on him and on the marks.",
         "draw": [_c(-166.3, -8.6, 0.17)]},
        {"name": "The bunting", "z": [-1.5, -1.4], "style": "mark", "tag": [-174.0, -8.0],
         "text": "The miners' bunting from town, torn, strung high between the mouth and the shaft. Today it runs 8 m along the gallery and "
                 "passes behind the foot of the ladder. It is shortened to 3.5 m, so that no line crosses behind the rungs.",
         "draw": [_ln(-175.8, -8.1, -174.0, -8.65), _ln(-174.0, -8.65, -172.3, -8.05)]},
        {"name": "The winch at the head of the incline", "z": [-2.9, -1.3], "style": "dark", "tag": [-174.8, -10.5], "top": True,
         "text": "In a second cut by the mouth: the hand winch that hauled ore up the incline from the bottom level. Its drum is bare. It "
                 "tells you that the slope outside was a track, and that the timbers you walk up it on were its sleepers.",
         "draw": [_r(-175.7, -12.6, -173.9, -10.9), _r(-175.5, -12.6, -174.1, -12.3, "pale"), _c(-174.8, -11.75, 0.5, "line"), _ln(-174.8, -11.75, -174.2, -11.2, "line")]},
        {"name": "The cavern, first seen", "z": [-6.5, -6.0], "style": "pale", "tag": [-176.8, -9.0],
         "text": "Through the mouth: the cavern's far wall, cold grey-violet, and mist. You can't see the waterfall from here, because the "
                 "pillar stands in the way. You hear it, and its blue-white light lies on the mouth's west post and along the floor.",
         "draw": [_r(-177.5, -13.4, -176.0, -5.5)]},
    ],
    "play": [
        {"name": "A worn path", "z": [-0.3, 0.3], "style": "mark", "tag": [-169.2, -13.0],
         "text": "The floor between where he sits and the foot of the ladder is worn pale, a track one boot wide. It is drawn on the floor "
                 "and changes nothing you stand on.",
         "draw": [_ln(-170.9, -12.52, -167.5, -12.52)]},
    ],
    "foreground": [
        {"name": "A low lip of rubble", "z": [1.3, 2.0], "style": "dark", "tag": [-170.5, -14.6],
         "text": "Along the bottom of the frame, below the floor, in front of rock only.",
         "draw": [_p([(-175.8, -15.0), (-175.8, -14.3), (-172.0, -14.5), (-168.5, -14.2), (-165.9, -14.4), (-165.9, -15.0)])]},
    ],
    "explains": [
        ["The floor", "The gallery's west end, at the foot of the ladder shaft", "The waiting room cut in the wall, and the winch by the mouth"],
        ["The frozen climber", "One who tried. He camped at the foot of the first hard climb and kept count", "His bedroll on the miners' bench, his cold lantern, the tally marks"],
        ["The mouth", "The head of the incline down to the Sump", "The winch, and the cavern beyond"],
    ],
    "pieces": [
        ["Plank lining with its frame, whole", "2 to 2.6 m wide, 2.5 m tall", "10", "Background", "kit: lining panel (mine)"],
        ["Back post and roof timber", "0.35 m square, 4.75 m tall", "5 posts", "Background", "kit: timber set (mine)"],
        ["Cut in the back wall with a plank bench and a peg rail", "2.1 m by 2.1 m, 1.2 m deep", "1", "Background", "kit: dark hole for a cove (mine); the bench and pegs are new"],
        ["Climber's camp: bedroll, cold lantern, rope coil, pickaxe, tally marks", "small", "1 of each", "Background", "kit: climber's camp (mine)"],
        ["Hanging lantern, lit", "0.4 m", "1", "Background", "kit: lantern_hang"],
        ["Miners' bunting, torn", "3.5 m", "1", "Background", "kit: papel_tatters"],
        ["Hand winch in its own cut", "winch 1.6 m by 1.4 m", "1", "Background", "kit: hand winch, dark hole (mine)"],
        ["Low lip of rubble", "10 m by 0.7 m", "1", "Foreground", "kit: rubble heap"],
    ],
    "effects": [
        "The lit lantern flickers. The cold one never does.",
        "Mist drifting in at the mouth, along the floor.",
    ],
    "notes": [
        "Note 71: the mine's frog is in the cave at the Sump, not at this camp, which was the first idea.",
        "Note 4: the bunting is the only line in this picture, and it is kept away from the ladder.",
    ],
}

# ------------------------------------------------------------------ 1.2 Escalera Rota
_SHAFT_SETS = [-7.5, -6.2, -4.9, -3.6, -2.3, -1.0, 0.3, 1.6, 2.9, 4.2, 5.5]
_LANDINGS = [-8.6, -4.66, -0.45]
_GAPS = [(-9.35, -7.85), (-5.6, -3.72), (-1.47, 0.58)]

ESCALERA_ROTA = {
    "id": "1.2", "slug": "1_2_escalera_rota", "title": "Escalera Rota", "kind": "challenge",
    "window": [-178.5, -14.0, -167.3, 10.0], "cut_y": -4.7, "climber": [-170.6, -12.6],
    "place": ("The men's way up from the gallery to the workings above: a ladder shaft 4 m wide and 13 m tall, lined with planks. It was "
              "always the wet shaft, because the water that gets into the mine runs down its east side, so the ladder in it is iron where "
              "every other ladder in the mine is wood. It was built in four lengths, with a timber landing between each length and the "
              "next. The iron lasted. The landings did not. Each one rotted, fell, and tore out the ladder's joint as it went, and those "
              "are the three gaps you lunge across."),
    "keep": [
        "Every rung where it is, and the three gaps: 1.5 m, 1.88 m and 2.05 m.",
        "The slick east wall, and the ledge at the head of the ladder.",
    ],
    "background": [
        {"name": "The shaft's back wall", "z": [-2.7, -2.4], "tag": [-169.4, 3.6], "top": True,
         "text": "Plank lining on a timber frame every 1.3 m, the same as every shaft in the mine. Here it is whole, but black with wet and "
                 "green at the seams, with two planks gone.",
         "draw": [_r(-172.0, -7.6, -168.0, 5.8)] + [_r(-172.0, y - 0.16, -168.0, y, "pale") for y in _SHAFT_SETS] +
                 [_r(-170.6, -2.1, -169.0, -1.67, "dark"), _r(-171.0, 3.1, -169.8, 3.53, "dark")]},
        {"name": "Three rotted landings", "z": [-2.4, -1.3], "style": "pale", "tag": [-168.9, -5.3], "top": True,
         "text": "Behind each gap in the ladder: what is left of a timber landing, its east half still in place and its west half hanging "
                 "down. Each length of ladder went from one landing to the next. The three gaps are the three landings.",
         "draw": [_r(-169.8, y - 0.14, -168.0, y) for y in _LANDINGS] +
                 [_p([(-169.8, y), (-170.5, y - 0.5), (-170.42, y - 0.62), (-169.8, y - 0.14)]) for y in _LANDINGS]},
        {"name": "A lantern on the top landing", "z": [-1.9, -1.6], "style": "light", "tag": [-168.6, 0.3],
         "text": "Today it hangs in the middle of the shaft. It stands on what is left of the top landing, so the longest gap is the best lit.",
         "draw": [_c(-169.0, -0.27, 0.17)]},
        {"name": "The frame at the head of the shaft", "z": [-1.6, -1.3], "style": "pale", "tag": [-170.0, 9.2],
         "text": "Two posts and a cap at the back, 2.6 m tall, round the top of the shaft. You see it from the foot of the ladder, and it "
                 "marks where the climb ends.",
         "draw": [_post(-172.2, 6.0, 8.4), _post(-167.8, 5.95, 8.4), _r(-172.5, 8.4, -167.5, 8.75)]},
        {"name": "A pug arrow sign", "z": [-1.4, -1.3], "style": "pale", "tag": [-174.9, 8.1],
         "text": "On the ledge at the head of the ladder, pointing west along the catwalk. The kit has it.",
         "draw": [_p([(-173.4, 7.0), (-174.2, 7.0), (-174.7, 7.3), (-174.2, 7.6), (-173.4, 7.6)]), _ln(-173.9, 6.0, -173.9, 7.0, "line")]},
        {"name": "The cavern", "z": [-6.5, -6.0], "tag": [-177.3, 2.0],
         "text": "West of the rock the shaft is cut in, the cavern opens: 20 m of air down to the Sump's beach, and the far wall a long way "
                 "back, cold grey-violet. At the head of the ladder you step out into it. The waterfall is still out of sight behind the "
                 "pillar, but its light is on everything to the west.",
         "draw": [_r(-178.5, -13.4, -176.0, 10.0)]},
    ],
    "play": [
        {"name": "Torn rail ends", "z": [-0.2, 0.2], "style": "mark", "tag": [-170.4, -8.6],
         "text": "At each gap the ladder's two iron rails end in torn, rusted points, above and below, and one bent rung hangs by an end "
                 "(it is there today, drawn only). The ladder is plainly one ladder with three pieces missing.",
         "draw": [_ln(-172.0, g0 + 0.2, -171.1, g0 + 0.2) for g0, g1 in _GAPS] + [_ln(-172.0, g1 - 0.2, -171.1, g1 - 0.2) for g0, g1 in _GAPS]},
        {"name": "Empty sockets", "z": [1.1, 1.2], "style": "pale", "tag": [-173.0, -4.9],
         "text": "In the rock beside the two upper gaps: the square socket the landing's beam sat in, empty. From below you can read where "
                 "the gaps are by the sockets.",
         "draw": [_r(-172.32, y - 0.45, -172.02, y - 0.15) for y in _LANDINGS[1:]]},
        {"name": "The wet east wall", "z": [-1.2, 1.2], "style": "mark", "tag": [-167.75, -1.0],
         "text": "The wall you can't hold: glossy black with pale drips, because the water that comes down the slope at the top runs down "
                 "this side. Nothing pale is drawn on it.",
         "draw": [_ln(-167.95, 5.6, -167.95, -7.4)]},
    ],
    "foreground": [
        {"name": "The shaft's two front posts", "z": [1.2, 1.5], "tag": [-172.3, 3.0], "top": True,
         "text": "Thin, each in three broken lengths, in front of the rock at the two edges of the shaft and never in front of the shaft "
                 "itself. The same piece as El Derrumbe's.",
         "draw": [_r(-172.45, -7.3, -172.15, -5.4), _r(-172.45, -3.9, -172.15, -1.3), _r(-172.45, 1.6, -172.15, 5.4),
                  _r(-167.9, -7.4, -167.6, -5.0), _r(-167.9, -3.4, -167.6, 1.4), _r(-167.9, 2.8, -167.6, 5.4)]},
    ],
    "explains": [
        ["The four runs of rungs", "Four lengths of the miners' iron ladder, each bolted to the wall, each as long as the climb from one landing to the next", "The lined back wall, and the landing each length reached"],
        ["The three gaps", "Where a landing rotted and fell, and tore the ladder's joint out", "The half of each landing that still hangs behind, and its empty socket in the rock"],
        ["The slick east wall", "Where the water gets into the mine", "The wet slope above it, and the lining that was never put back"],
        ["The ledge at the top", "The head of the shaft", "The timber frame round it, and the pug arrow pointing along the catwalk"],
    ],
    "pieces": [
        ["Plank lining with its frame: whole, planks missing", "4 m wide, 1.3 m tall", "10", "Background", "kit: lining panel (mine)"],
        ["Half landing, rotted, with a hanging plank", "1.8 m by 1 m", "3", "Background", "kit: half landing (mine)"],
        ["Standing lantern", "0.4 m", "1", "Background", "kit: lantern_mine"],
        ["Timber frame for the shaft's head", "posts 0.35 m, 2.4 m tall; cap 5 m", "2 posts, 1 cap", "Background", "kit: timber set (mine)"],
        ["Pug arrow sign", "1 m", "1", "Background", "kit: sign_pug_arrow"],
        ["Torn end for an iron ladder rail; bent rung", "0.2 m; 0.9 m", "12 ends, 3 rungs", "Play space (drawn on)", "the rung is in the kit: fit_ladder_rung_bent; the torn end is new"],
        ["Empty socket", "0.3 m", "2", "Play space (drawn on)", "kit: empty socket (mine)"],
        ["Front post, in broken lengths", "0.3 m wide, 1.9 to 4.8 m", "6 lengths", "Foreground", "kit: timber set post (mine), cut"],
    ],
    "effects": [
        "Water running down the east wall, and a slow drip off each hanging landing.",
        "Rust flakes falling from a rail end when you take the rung under it.",
    ],
    "notes": [
        "No note from the playtest was about this challenge. The ladder was remade before it, with real rails and missing rungs.",
    ],
}

# ------------------------------------------------------------------ 1.3 Los Tablones
# (west end, east end, top) of the five nailed lengths and of the four loose boards
_SOUND = [(-178.2, -176.0, 6.0), (-181.6, -179.6, 5.9), (-186.3, -184.3, 5.8), (-190.1, -187.7, 5.95), (-192.8, -190.2, 6.0)]
_LOOSE = [(-179.5, -178.3, 5.95), (-182.9, -181.7, 5.8), (-184.2, -183.0, 5.75), (-187.6, -186.4, 5.9)]
_BEARERS = [(-177.95, 6.0), (-181.35, 5.9), (-179.85, 5.9), (-186.05, 5.8), (-184.55, 5.8), (-189.85, 5.95), (-187.95, 5.95), (-192.55, 6.0), (-190.45, 6.0)]


def _bearer(x, top):
    """A walk bearer seen end-on under a plank whose top is at `top`, with the strut under it."""
    u = round(top - 0.22, 2)
    return [_r(round(x - 0.15, 2), round(u - 0.3, 2), round(x + 0.15, 2), u, "pale"),
            _p([(round(x - 0.2, 2), round(u - 0.3, 2)), (round(x + 0.2, 2), round(u - 0.3, 2)),
                (round(x + 0.07, 2), round(u - 1.3, 2)), (round(x - 0.07, 2), round(u - 1.3, 2))], "pale")]


LOS_TABLONES = {
    "id": "1.3", "slug": "1_3_los_tablones", "title": "Los Tablones", "kind": "challenge",
    "window": [-195.0, -3.0, -171.0, 14.0], "screen": [-185.0, 5.0], "cut_y": 5.4, "climber": [-174.5, 6.0],
    "place": ("A plank walk along the cavern's wall, from the head of the ladder shaft towards the bucket lift on the pillar. It was built "
              "the mine's way: a square timber let into a socket in the rock every couple of metres, a strut under it, and "
              "planks nailed on top. Half way along it served a side tunnel. Five lengths of the planking are still nailed down and sound. "
              "In four places a timber has dropped out of the wall and the plank over it went too, and somebody later bridged each hole "
              "with a loose grey board that rests on nothing but its neighbours. Those four are the ones that break. Under the walk there "
              "is only air: 20 m down to the beach at the east end, 34 m to the water at the west."),
    "keep": [
        "All nine planks where they are, the sag in the middle, and which four break.",
        "The gaps between planks, and the ledge at the east end.",
    ],
    "background": [
        {"name": "The cavern's wall", "z": [-3.6, -2.9], "tag": [-181.0, 12.6],
         "text": "Hand-cut rock, flat and pick-marked, 1.7 m behind the walk. It is dry above the planks and dark with wet below them. "
                 "It is the wall the walk is fixed to. Today there is nothing behind the walk for 5 m, and its braces stand in the air.",
         "draw": [_r(-195.0, -3.0, -171.0, 14.0)]},
        {"name": "The bearers", "z": [-2.9, -1.2], "style": "pale", "tag": [-189.2, 4.0], "top": True,
         "text": "Under each end of each nailed length: a square timber coming out of the wall to the walk, seen end-on, with a short strut "
                 "under it. Nine of them. They take the place of today's slanting braces, which are in hold-coloured timber and lean across "
                 "the open air under the walk.",
         "draw": [q for x, top in _BEARERS for q in _bearer(x, top)]},
        {"name": "Four empty sockets", "z": [-3.05, -2.9], "style": "dark", "tag": [-183.0, 4.4], "top": True,
         "text": "Under the middle of each loose board: the square hole in the rock where its bearer was, empty, with a pale scar below "
                 "where the strut tore off. Before you step on a grey board you can see there is nothing under it.",
         "draw": [_r(x - 0.15, 5.2, x + 0.15, 5.5) for x in (-178.9, -182.3, -183.6, -187.0)]},
        {"name": "A boarded side tunnel", "z": [-4.6, -2.9], "style": "dark", "tag": [-185.3, 7.2],
         "text": "In the wall behind the walk's soundest length, with two planks nailed across it and the stub of a gangway at its foot. "
                 "It is what the walk was built to reach.",
         "draw": [_p([(-186.2, 5.8), (-186.2, 8.0), (-185.3, 8.7), (-184.4, 8.0), (-184.4, 5.8)]),
                  _ln(-186.2, 6.1, -184.4, 7.9, "line"), _ln(-186.2, 7.9, -184.4, 6.1, "line")]},
        {"name": "The lower walk that fell", "z": [-2.9, -1.9], "style": "dark", "tag": [-183.6, 0.9],
         "text": "Six metres down the same wall: a row of sockets, two bearers, and one 3 m length of an older walk still in place. It is "
                 "out of reach and leads nowhere. It tells you this wall sheds walks, and it gives the eye something to measure the drop by.",
         "draw": [_r(x - 0.15, -0.15, x + 0.15, 0.15) for x in (-178.6, -181.1, -183.6, -186.1)] +
                 [_r(x - 0.15, -0.15, x + 0.15, 0.15, "pale") for x in (-188.6, -191.1)] + [_r(-191.4, 0.15, -188.3, 0.32, "pale")]},
        {"name": "Two lanterns", "z": [-2.9, -2.7], "style": "light", "tag": [-175.5, 9.8],
         "text": "On iron hooks in the wall, 3 m above the planks: one over the head of the ladder, one over the tunnel's cap. Where they "
                 "hang today, but on the wall.",
         "draw": [_c(-174.6, 9.2, 0.17), _c(-185.3, 9.3, 0.17)]},
        {"name": "The miners' bunting", "z": [-2.9, -2.8], "style": "mark", "tag": [-180.0, 10.6],
         "text": "Torn, strung along the wall high over the middle of the walk, where it is today. It is 4.5 m above the planks, well out of reach.",
         "draw": [_ln(-188.5, 11.4, -184.5, 10.7), _ln(-184.5, 10.7, -180.5, 11.4)]},
    ],
    "play": [
        {"name": "Nail heads", "z": [-1.2, 1.2], "style": "mark", "tag": [-191.5, 7.0],
         "text": "Each nailed length shows two rows of iron nail heads, one over each bearer. The four grey boards show none. It is a second "
                 "way to tell them apart, for anyone who can't trust the colour.",
         "draw": [_ln(x0 + 0.15, round(top - 0.11, 2), x1 - 0.15, round(top - 0.11, 2)) for x0, x1, top in _SOUND]},
        {"name": "The four loose boards", "z": [-1.2, 1.2], "style": "line", "tag": [-183.6, 6.7],
         "text": "Grey and rotten, already cracked across, each with a corner gone: the game's one breakable look. They lie a little "
                 "crooked, because nothing holds them.",
         "draw": [_ln(x0 + 0.35, top, x0 + 0.55, round(top - 0.22, 2)) for x0, x1, top in _LOOSE]},
    ],
    "foreground": [],
    "explains": [
        ["The five sound lengths", "The walk's planking, still nailed to its bearers", "The bearer under each end, its strut, and the tunnel the walk served"],
        ["The four grey boards", "Loose boards laid across the holes where a bearer and its plank fell out", "The empty socket under each one"],
        ["The sag in the middle", "The bearers there have slipped in their sockets", "Bearers that sit a hand lower in the wall than their neighbours"],
        ["The ledge at the east end", "The head of the ladder shaft", "The pug arrow and the shaft's timber frame (see Escalera Rota)"],
    ],
    "pieces": [
        ["Rock wall, hand-cut: dry, wet", "24 m by 17 m", "1", "Background", "new, but plain: flat rock with pick marks"],
        ["Walk bearer with its strut", "0.3 m square, 1.7 m long; strut 1 m tall", "11", "Background", "kit: walk bearer (mine, added by these pages)"],
        ["Empty socket with a scar under it", "0.3 m", "8", "Background", "kit: empty socket (mine)"],
        ["Boarded side tunnel", "1.8 m by 2.9 m", "1", "Background", "kit: boarded tunnel (mine)"],
        ["Plank length for the lower walk", "3 m", "1", "Background", "kit: mine_beam, flat"],
        ["Hanging lantern on a wall hook", "0.4 m", "2", "Background", "kit: lantern_hang"],
        ["Miners' bunting, torn", "8 m", "1", "Background", "kit: papel_tatters"],
        ["Nail heads; crack and missing corner for a rotten board", "small", "10 rows; 4 boards", "Play space (drawn on)", "new, drawn on"],
    ],
    "effects": [
        "A grey board creaks and sheds dust the moment you take it, before it goes.",
        "A drip onto the east ledge, as today.",
    ],
    "notes": [
        "Note 1 (done): a broken board grows back in its own gap, not from the far side of the mine.",
        "Note 40: no foreground here. The walk hangs over open air from end to end and there is no rock to stand a post in front of.",
    ],
}

# ------------------------------------------------------------------ 1.4 La Cuerda del Minero and 1.5 El Cubo: shared shapes
_GALLOWS = [(-193.3, 26.2), (-192.7, 26.2), (-192.7, 29.6), (-190.2, 32.2), (-186.3, 32.2), (-186.3, 32.8), (-193.3, 32.8)]
_BOARDS = [(-191.3, 13.4), (-190.7, 13.4), (-190.7, 12.6), (-189.9, 12.6), (-189.9, 13.9), (-189.2, 13.9), (-189.2, 12.9),
           (-188.3, 12.9), (-188.3, 13.6), (-187.6, 13.6), (-187.6, 12.4), (-186.9, 12.4)]
_LOWER_STATION = [_r(-200.4, 13.8, -191.5, 14.2), _p([(-201.9, 9.0), (-201.9, 9.6), (-197.3, 13.8), (-197.9, 13.8)], "pale"),
                  _r(-201.9, 13.45, -200.2, 13.8, "pale")]
_PILLAR_POST = [(6.3, 9.2), (10.6, 13.6), (15.0, 20.5), (22.0, 25.6)]

LA_CUERDA = {
    "id": "1.4", "slug": "1_4_la_cuerda_del_minero", "title": "La Cuerda del Minero", "kind": "challenge",
    "window": [-204.0, -1.0, -186.0, 18.0], "screen": [-195.5, 8.0], "cut_y": 13.9, "climber": [-191.5, 6.0],
    "place": ("The plank walk used to go all the way to the pillar. Its last 5 m fell while the mine was still working, and the miners "
              "did not rebuild it. They tied a rope to the arm of the bucket lift, which sticks out over the gap, and swung across. That "
              "rope is still there. It hangs from an iron rod under the arm, greased so that its hook would turn, which is why you "
              "can't climb past the rope's top. On the far side is the pillar's shoulder, with the socket of the walk's last bearer "
              "still in its face. Below is 34 m of air and the water."),
    "keep": [
        "The rope, its length and where it hangs. The greased rod above it.",
        "The gap, the walk's end and the 4 m landing on the pillar's shoulder.",
    ],
    "background": [
        {"name": "The cavern's wall, and where the last span was", "z": [-3.6, -2.9], "tag": [-189.4, 1.6],
         "text": "The same wall as behind Los Tablones, carried on to the pillar. Across the gap, at the walk's height: three empty sockets "
                 "and one bearer snapped off short. The gap is plainly a piece of the walk that is missing.",
         "draw": [_p([(-201.9, 18.0), (-186.0, 18.0), (-186.0, -1.0), (-197.9, -1.0), (-197.9, 5.7), (-201.9, 5.7)])] +
                 [_r(x - 0.15, 5.2, x + 0.15, 5.5, "dark") for x in (-194.0, -195.3, -196.6)] + [_r(-197.75, 5.2, -197.45, 5.5, "pale")]},
        {"name": "The foot of the hoistway", "z": [-2.9, -2.4], "style": "dark", "tag": [-189.1, 16.7],
         "text": "Flat against the wall: the ragged bottom of the dark boards that the lift's weight and bucket run in front of. It is there today (note 4) and "
                 "belongs to El Cubo. From here it is a dark shape at the top right that says a machine is above you.",
         "draw": [_p(_BOARDS + [(-186.9, 18.0), (-191.3, 18.0)])]},
        {"name": "The arm's back half", "z": [-1.9, -1.3], "tag": [-199.3, 11.0], "top": True,
         "text": "The arm you will walk along is one of a pair. Its twin is straight behind it. A slanting brace carries the pair from the "
                 "pillar's face, and a cross timber ties them to the rock. Today the brace is in hold-coloured timber in the play space. "
                 "It moves back and goes grey.",
         "draw": _LOWER_STATION},
        {"name": "Two lanterns", "z": [-2.9, -1.3], "style": "light", "tag": [-199.5, 8.5],
         "text": "One on a hook in the wall over the pillar's shoulder, where it is today. One standing on the arm's back twin, moved down "
                 "from where it hangs in the air today.",
         "draw": [_c(-200.3, 9.4, 0.17), _c(-196.5, 14.42, 0.17)]},
        {"name": "A warning sign", "z": [-1.6, -1.3], "style": "pale", "tag": [-190.4, 8.3],
         "text": "The skull-pug diamond on a post at the back edge of the walk's broken end. The miners' own notice that the walk stops.",
         "draw": [_p([(-191.8, 7.5), (-191.4, 7.9), (-191.0, 7.5), (-191.4, 7.1)]), _ln(-191.4, 6.0, -191.4, 7.1, "line")]},
    ],
    "play": [
        {"name": "The rod's eye and strap", "z": [-0.2, 0.2], "style": "line", "tag": [-192.9, 12.4],
         "text": "The rope is knotted through an iron eye at the foot of the rod, and the rod hangs from an iron strap round the arm. So "
                 "you can see the whole chain of what holds you: arm, strap, rod, eye, rope. The rod is black and glossy with grease, with "
                 "a drip at its foot.",
         "draw": [_c(-194.1, 11.4, 0.14), _r(-194.3, 13.72, -193.9, 14.28)]},
        {"name": "The two broken ends", "z": [-1.2, 1.2], "style": "pale", "tag": [-195.4, 6.6],
         "text": "The walk's last plank ends in splinters. In the face of the pillar's shoulder, level with it, is the socket and the "
                 "stump of the bearer that carried the other end.",
         "draw": [_r(-193.0, 5.78, -192.8, 6.0), _r(-198.2, 5.2, -197.9, 5.5)]},
    ],
    "foreground": [
        {"name": "The lift frame's front post", "z": [1.2, 1.5], "tag": [-203.3, 12.2], "top": True,
         "text": "One thin post in broken lengths, in front of the pillar's rock beside the iron rungs. It never crosses the open air.",
         "draw": [_r(-202.75, a, -202.45, b) for a, b in _PILLAR_POST[:2]] + [_r(-202.75, 15.0, -202.45, 17.6)]},
    ],
    "explains": [
        ["The rope", "A rope the miners tied to the lift's arm when the last span of the walk fell", "The row of empty sockets where the span was"],
        ["The greased rod", "The arm's iron hook rod, greased so its hook would turn", "The arm's twin, its brace and its cross timber"],
        ["The walk's end, and the landing on the shoulder", "The two ends of the same walk", "The snapped bearer in the wall and the socket in the pillar"],
    ],
    "pieces": [
        ["Rock wall, hand-cut", "16 m by 19 m", "1", "Background", "the same piece as Los Tablones"],
        ["Empty socket; bearer snapped short", "0.3 m", "3 and 1", "Background", "kit: empty socket; walk bearer (mine, added by these pages)"],
        ["Hoistway boards, ragged at the foot", "4.4 m wide", "1", "Background", "there today"],
        ["Arm twin, brace and cross timber", "0.4 m thick; 8.9 m, 6.2 m and 1.7 m", "1 of each", "Background", "kit: mine_beam"],
        ["Lantern: hanging, standing", "0.4 m", "1 and 1", "Background", "kit: lantern_hang, lantern_mine"],
        ["Skull-pug warning sign", "1 m", "1", "Background", "kit: sign_pug_skull"],
        ["Iron eye and strap for the rod", "0.3 m", "1", "Play space (drawn on)", "kit: iron strap (mine, added by these pages)"],
        ["Splintered end; socket with a stump", "0.3 m", "1 and 1", "Play space (drawn on)", "kit: splintered end, empty socket (mine)"],
        ["Front post, in broken lengths", "0.3 m wide, 2.6 to 3 m", "3 lengths", "Foreground", "kit: timber set post (mine), cut"],
    ],
    "effects": [
        "The drop under the gap is lit cold from below, as it is today.",
        "One drip of grease, now and then, off the foot of the rod.",
    ],
    "notes": [
        "Note 4: the rope must be the only thin hanging line in the picture. Nothing in this background hangs.",
    ],
}

# ------------------------------------------------------------------ 1.5 El Cubo
EL_CUBO = {
    "id": "1.5", "slug": "1_5_el_cubo", "title": "El Cubo", "kind": "challenge",
    "window": [-204.0, 4.0, -184.0, 35.0], "screen": [-194.5, 20.5], "cut_y": 26.0, "climber": [-200.0, 6.0],
    "place": ("The bucket lift, built up the side of the pillar between the walk's level and the station 12 m above it. An ore bucket "
              "hangs on one side of a pulley and an iron weight on the other. The miners made it work itself. A trough brings a trickle "
              "of water from a seep in the wall and pours it into the bucket at the top. When the bucket is full it is heavier than the "
              "weight, so it goes down and the weight comes up. At the bottom a peg knocks open a flap in the bucket's floor, the water "
              "runs out, and the weight pulls the bucket back up. The seep has never stopped, so the lift has gone up and down by itself "
              "for eighty years. You ride the weight."),
    "keep": [
        "The iron rungs, the arm, and the station deck with its 2.1 m gap from the wall.",
        "The weight's road and its timing: 2.5 s at the foot, 7.5 s up, 2.5 s at the top. The bucket moves the other way.",
        "No cables (note 4).",
    ],
    "background": [
        {"name": "The cavern's wall", "z": [-3.6, -2.9], "tag": [-199.0, 19.0],
         "text": "The same hand-cut wall as behind the plank walk, carried on up. The lift is built against it.",
         "draw": [_p([(-201.9, 35.0), (-184.0, 35.0), (-184.0, 4.0), (-197.9, 4.0), (-197.9, 5.7), (-201.9, 5.7)])]},
        {"name": "The hoistway", "z": [-2.9, -2.4], "style": "dark", "tag": [-189.1, 21.5], "top": True,
         "text": "There today, and kept exactly: a dark frame on the station deck with an arm over the pulley, and the broad dark boards "
                 "the weight and the bucket run in front of. It is dark, flat and broad, with no rungs and no thin lines, so it does not "
                 "read as something to climb (note 4).",
         "draw": [_p(_GALLOWS), _p(_BOARDS + [(-186.9, 32.2), (-191.3, 32.2)])]},
        {"name": "The trough", "z": [-2.9, -1.4], "style": "pale", "tag": [-185.6, 30.5],
         "text": "A timber trough on two wall brackets, from a dark seep hole in the wall down to a lip over the bucket's top place. A "
                 "thin run of water falls half a metre from the lip into the bucket while it waits there. This is what drives the lift.",
         "draw": [_r(-184.6, 29.3, -184.0, 30.1, "dark"), _p([(-184.2, 29.6), (-184.2, 29.25), (-187.3, 28.15), (-187.3, 28.5)])]},
        {"name": "The peg at the foot", "z": [-2.4, -1.3], "style": "pale", "tag": [-185.9, 13.9],
         "text": "A stout timber peg bolted to the foot of the boards, just under where the bucket stops. It knocks the flap in the "
                 "bucket's floor open, and the water falls away below for as long as the bucket waits.",
         "draw": [_r(-187.0, 13.2, -186.55, 14.6)]},
        {"name": "The pulley", "z": [-2.4, -2.0], "style": "line", "tag": [-188.95, 30.4],
         "text": "On the frame's arm, where it is today, but set back against the hoistway and grey. It turns one way, stops, and turns back.",
         "draw": [_c(-188.95, 31.4, 0.4)]},
        {"name": "The station's back half", "z": [-2.9, -1.3], "style": "pale", "tag": [-196.9, 28.6], "top": True,
         "text": "The deck you land on carries on back to the wall on two bearers, seen end-on under it, with a slanting brace from the "
                 "pillar. On its back half: three ore crates and a spare bucket on its side. This is where ore from the pillar's top "
                 "was sent down. Today the brace is in hold-coloured timber in the play space. It moves back and goes grey.",
         "draw": [_r(-198.95, 25.6, -198.65, 25.9), _r(-193.15, 25.6, -192.85, 25.9),
                  _p([(-201.9, 21.6), (-201.9, 22.2), (-197.6, 25.9), (-198.2, 25.9)]),
                  _r(-197.7, 26.2, -196.9, 27.0), _r(-196.8, 26.2, -196.0, 27.0), _r(-197.25, 27.0, -196.45, 27.8), _c(-194.6, 26.65, 0.45, "line")]},
        {"name": "The lower station's back half", "z": [-1.9, -1.3], "tag": [-199.3, 11.0],
         "text": "The arm's twin behind it, the brace that carries them both and the cross timber that ties them to the rock. The same "
                 "pieces as on La Cuerda del Minero's page.",
         "draw": _LOWER_STATION},
        {"name": "Two lanterns", "z": [-1.7, -1.3], "style": "light", "tag": [-195.4, 15.3],
         "text": "One standing on the arm's twin, one standing on the top crate. Today both hang in the open air with nothing above them.",
         "draw": [_c(-196.5, 14.42, 0.17), _c(-196.85, 28.02, 0.17)]},
    ],
    "play": [
        {"name": "The weight", "z": [-0.6, 0.6], "style": "line", "tag": [-192.0, 16.6],
         "text": "A riveted iron box of scrap and rock with a lifting eye on top, rust orange. It is the thing you hold, so it is the "
                 "brightest thing on the lift.",
         "draw": [_r(-191.0, 14.7, -189.4, 15.9)]},
        {"name": "The bucket", "z": [-0.6, 0.6], "style": "line", "tag": [-187.7, 25.6],
         "text": "It matches what you touch now (note 3). It gets a flap in its floor, a wet shine inside, and a drip from the flap as it "
                 "climbs. Its handle over the top stays drawn only.",
         "draw": [_r(-188.3, 26.5, -187.1, 27.54)]},
        {"name": "The deck's west end", "z": [-1.2, 1.2], "style": "mark", "tag": [-200.6, 26.9],
         "text": "The deck stops 2.1 m short of the pillar. Its end is drawn as a finished edge with a trimmer across it, not a break: the "
                 "gap was the hatch that the ore went down, and it is the gap you fall through from Vetas de Lodo.",
         "draw": [_ln(-199.8, 25.8, -199.8, 26.5)]},
    ],
    "foreground": [
        {"name": "The lift frame's front post", "z": [1.2, 1.5], "tag": [-203.3, 18.0], "top": True,
         "text": "One thin post in four broken lengths, in front of the pillar's rock beside the iron rungs. It stops below the station, "
                 "so it is nowhere near the ribs of Vetas de Lodo.",
         "draw": [_r(-202.75, a, -202.45, b) for a, b in _PILLAR_POST]},
    ],
    "explains": [
        ["The iron rungs", "The lift men's ladder up the pillar", "The front and back posts of the lift's frame, either side of them"],
        ["The arm", "The lower station's loading arm, out over the gap", "Its twin behind it, the brace and the cross timber"],
        ["The weight", "The lift's counterweight. It rises when the bucket is full of water", "The hoistway boards behind it, and the pulley above"],
        ["The bucket", "The lift's ore bucket, now filled by the trough and emptied by the peg", "The trough at the top, the peg at the foot"],
        ["The station deck", "The upper station, where ore was loaded", "Its bearers and brace, the crates, the spare bucket"],
    ],
    "pieces": [
        ["Rock wall, hand-cut", "18 m by 31 m", "1", "Background", "the same piece as Los Tablones"],
        ["Hoistway: frame with an arm, and back boards", "7 m by 6.6 m; 4.4 m by 20 m", "1", "Background", "there today"],
        ["Water trough on wall brackets, with its seep hole", "0.5 m wide, 3.3 m long", "1", "Background", "kit: water trough (mine, added by these pages); dark hole (mine)"],
        ["Trip peg", "0.45 m by 1.4 m", "1", "Background", "kit: timber set post (mine), cut"],
        ["Pulley", "0.8 m", "1", "Background", "kit: pulley"],
        ["Walk bearer; slanting brace", "0.3 m square; 5.9 m", "2 and 1", "Background", "kit: walk bearer (mine, added by these pages); mine_beam"],
        ["Ore crate; ore bucket", "0.8 m; 0.9 m", "3 and 1", "Background", "kit: crate_ore; ore bucket (mine)"],
        ["Arm twin, brace and cross timber", "0.4 m thick", "1 of each", "Background", "the same pieces as La Cuerda del Minero"],
        ["Standing lantern", "0.4 m", "2", "Background", "kit: lantern_mine"],
        ["Flap for the bucket's floor; lifting eye for the weight", "0.4 m", "1 and 1", "Play space (drawn on)", "kit: iron strap (mine, added by these pages)"],
        ["Front post, in broken lengths", "0.3 m wide, 2.9 to 5.5 m", "4 lengths", "Foreground", "kit: timber set post (mine), cut"],
    ],
    "effects": [
        "A thin run of water from the trough's lip into the bucket for the 2.5 s it waits at the top.",
        "Water falling from the bucket's floor for the 2.5 s it waits at the foot.",
        "The pulley creaks as the lift starts. The drips on the station deck stay as they are.",
    ],
    "notes": [
        "Note 3 (done): the bucket you see is the bucket you touch.",
        "Note 4 (third try in the game, not yet judged): the two cables are gone and the dark hoistway stands in their place. This design keeps it.",
    ],
    "ask": [
        "The lift shown as worked by water, with a trickle filling the bucket at the top and running out at the foot: yes or no?",
    ],
}

# ------------------------------------------------------------------ 1.6 Vetas de Lodo
_RIBS = [27.0, 28.6, 30.2, 32.15, 33.75, 35.35, 37.3, 38.8]
_RISE = 0.179   # the seams climb this much for every metre east


def _stope(xa, xb, t):
    """A worked-out slot along the far wall's seam, with three props in it."""
    ya, yb = round(t + (xa + 201.9) * _RISE, 2), round(t + (xb + 201.9) * _RISE, 2)
    out = [_p([(xa, ya), (xb, yb), (xb, round(yb + 1.15, 2)), (xa, round(ya + 1.15, 2))], "dark")]
    for k in (0.16, 0.48, 0.8):
        x = round(xa + (xb - xa) * k, 2)
        y = round(t + (x + 201.9) * _RISE, 2)
        out.append(_post(x, y, round(y + 1.15, 2), "pale", 0.18))
    return out


VETAS_DE_LODO = {
    "id": "1.6", "slug": "1_6_vetas_de_lodo", "title": "Vetas de Lodo", "kind": "challenge",
    "window": [-212.0, 23.0, -190.0, 44.0], "screen": [-200.5, 33.0], "cut_y": 32.0, "climber": [-198.0, 26.2],
    "place": ("The east face of El Diente, the pillar of rock the miners left standing to hold up the roof. The gold in this mine lies in "
              "thin slanting seams of hard pale rock with soft wet clay between them, and eight of those seams cross the pillar. On this "
              "face the clay has washed out as black mud, and the hard seams stand proud of it as ribs, 0.6 to 1.2 m out. You climb the "
              "ends of the seams. The miners dug along the very same seams in the cavern's wall, and their workings are there "
              "behind you, at the same heights."),
    "keep": [
        "The eight ribs, each at its height and its length, and the black face between them.",
        "The two long lunges to the two wide ribs.",
        "The fall from here: through the gap beside the station deck, to the pillar's shoulder 20 m down.",
    ],
    "background": [
        {"name": "The cavern's wall", "z": [-3.6, -2.9], "tag": [-191.4, 25.2],
         "text": "The same wall as behind the lift, cold grey-violet. The same eight seams cross it, climbing to the east at the same "
                 "slant as on the pillar. They are faint lines, greyer than the rock, so that none of them reads as a ledge.",
         "draw": [_r(-201.9, 23.0, -190.0, 44.0)] + [_ln(-201.9, t, -190.0, round(t + 11.9 * _RISE, 2), "mark") for t in _RIBS]},
        {"name": "Two old workings", "z": [-4.6, -2.9], "tag": [-195.9, 36.6],
         "text": "Where the miners followed the two richest seams into the wall: a dark slot 1.1 m high along each, with short timber "
                 "props wedged in it. They are level with the two wide ribs, so each long lunge has a dark slot behind its target.",
         "draw": _stope(-197.0, -192.0, 32.15) + _stope(-198.5, -193.5, 37.3)},
        {"name": "A lantern in the lower working", "z": [-3.4, -3.0], "style": "light", "tag": [-193.3, 35.5],
         "text": "It lights the face from the side, so every rib throws a shadow under itself. Today a lantern hangs about a metre from "
                 "the ribs, where it could be taken for a hold. That one goes.",
         "draw": [_c(-194.4, 34.75, 0.17)]},
        {"name": "The station below", "z": [-2.9, -1.3], "style": "dark", "tag": [-194.9, 28.8],
         "text": "El Cubo's station: the dark frame of the hoistway, and the crates on the back of the deck you start from.",
         "draw": [_p([(-193.3, 26.2), (-192.7, 26.2), (-192.7, 29.6), (-190.2, 32.2), (-190.0, 32.2), (-190.0, 32.8), (-193.3, 32.8)]),
                  _r(-197.7, 26.2, -196.9, 27.0, "pale"), _r(-196.8, 26.2, -196.0, 27.0, "pale"), _r(-197.25, 27.0, -196.45, 27.8, "pale")]},
    ],
    "play": [
        {"name": "The seams across the pillar", "z": [1.15, 1.2], "style": "mark", "tag": [-206.2, 30.5],
         "text": "Drawn on the pillar's blank face: each rib's seam, a pale slanting band 0.4 m thick, running back across the whole "
                 "pillar from the rib's root. You read the ribs as the ends of eight bands, not as eight shelves stuck on a wall.",
         "draw": [_ln(-208.9, round(t - 1.45, 2), -202.2, round(t - 0.25, 2)) for t in _RIBS]},
        {"name": "The two wide ribs", "z": [-1.2, 1.2], "style": "line", "tag": [-199.9, 32.6],
         "text": "The two you lunge for get a row of old drill holes along their edge. The miners started on these two and stopped. All "
                 "eight ribs are pale, chalky and dry, with a broken edge.",
         "draw": [_r(-202.2, 31.73, -200.7, 32.15), _r(-202.2, 36.88, -200.7, 37.3)]},
        {"name": "The mud between", "z": [-1.2, 1.2], "style": "mark", "tag": [-202.9, 34.6],
         "text": "Black, glossy clay with pale drips, oozing from under each rib. Nothing pale is drawn on it between one rib and the next.",
         "draw": [_ln(-201.8, round(t - 0.5, 2), -201.8, round(t - 1.1, 2)) for t in _RIBS[1:]]},
    ],
    "foreground": [],
    "explains": [
        ["The eight ribs", "The hard ends of eight gold seams, standing proud where the clay between them has washed out", "The same seams drawn across the pillar's face, and again across the wall behind"],
        ["The two wide ribs", "The two richest seams, which the miners began to cut", "A dark working along each of them in the wall behind, at the same height"],
        ["The black face", "Wet clay, washing out of the pillar", "The dark, wet look of everything under each rib"],
        ["The station deck you start from", "The lift's upper station", "The hoistway's frame and the crates"],
    ],
    "pieces": [
        ["Rock wall, hand-cut, with eight faint seams", "12 m by 21 m", "1", "Background", "the same piece as Los Tablones; kit: ore seam (mine)"],
        ["Worked-out slot with timber props", "5 m long, 1.1 m high", "2", "Background", "new; the props are kit: timber set post (mine), cut"],
        ["Standing lantern", "0.4 m", "1", "Background", "kit: lantern_mine"],
        ["Hoistway frame; ore crates", "as El Cubo", "1 and 3", "Background", "there today; kit: crate_ore"],
        ["Ore seam across the pillar; drill holes", "0.4 m thick, 7 m long; holes 5 cm", "8 seams, 2 rows of holes", "Play space (drawn on)", "kit: ore seam and drill holes (mine)"],
    ],
    "effects": [
        "A slow ooze of mud from under each rib, and a drip off the tip of the two wide ones.",
        "The lantern's flicker moves the ribs' shadows a little.",
    ],
    "notes": [
        "Note 5 (done): the streaks of wind that crossed this wall are gone. The only wind in the mine is inside the waterfall.",
        "Note 40: no foreground here. You climb the edge of the rock with open air beside you.",
    ],
}

# ------------------------------------------------------------------ 1.7 El Carrito Loco and 1.8 Las Vigas: shared shapes
_BEAMS = [(-218.3, -213.9, 50.5), (-222.8, -220.8, 52.0), (-227.3, -225.3, 50.8), (-231.8, -229.8, 52.3)]
_HANGERS = [(-216.1, 50.5), (-221.8, 52.0), (-226.3, 50.8), (-230.8, 52.3)]
_ROOF_GEAR = [_r(-232.0, 54.25, -213.5, 54.6, "pale")] + [_post(x, top, 55.0) for x, top in _HANGERS]

EL_CARRITO = {
    "id": "1.7", "slug": "1_7_el_carrito_loco", "title": "El Carrito Loco", "kind": "challenge",
    "window": [-246.0, 31.0, -201.0, 56.5], "screen": [-211.0, 43.5], "cut_y": 40.2, "climber": [-203.6, 40.0],
    "place": ("The top of El Diente was the mine's high road. Ore came down from the upper works to this track and was pushed east along "
              "it to the bucket lift. West of the pillar the track crossed 20 m of open cavern on a deck slung by chains from a long beam "
              "under the roof. That deck has fallen and taken the track with it. What is left is the cart on its siding, held by one "
              "wooden chock, a stub of track on two slanting struts with boards nailed across its end, and the last two chains, hanging "
              "where the deck used to be. The track points straight at the waterfall, and that is where the cart goes."),
    "keep": [
        "The cart, its 0.7 s wait, its speed, and that it falls for real a cart's length past the boards (note 6).",
        "The two chains, each where it hangs, and the first roof beam they hang from.",
        "The 3.4 m of pillar top east of the cart, to rest on.",
    ],
    "background": [
        {"name": "The waterfall", "z": [-3.0, -1.2], "tag": [-241.0, 44.0], "top": True,
         "text": "For the first time you see it side-on and whole: a white column 30 m to the west, from the roof down past the bottom of "
                 "the picture. The track is aimed at its middle. The sheet itself comes forward through the play space, and the cart "
                 "falls through it.",
         "draw": _fall(31.0, 56.5)},
        {"name": "Two slanting struts", "z": [-1.7, -1.3], "style": "pale", "tag": [-212.2, 36.4],
         "text": "From the pillar's west face up to the underside of the track's stub: they are what holds it out over the drop. Today the "
                 "kit's 6 m trestle leg is placed here, and by the course's numbers its feet are in the air. The struts take its place.",
         "draw": [_p([(-208.9, 35.0), (-208.9, 35.6), (-212.5, 39.6), (-213.1, 39.6)]), _p([(-208.9, 37.2), (-208.9, 37.75), (-210.5, 39.6), (-211.0, 39.6)])]},
        {"name": "The beam under the roof", "z": [-1.9, -1.2], "tag": [-223.9, 53.4],
         "text": "What the chains hang from. The first of Las Vigas has a hanger post behind it, up to the roof, and behind that runs a "
                 "second long beam that never broke. No chain hangs from the back beam: a hanging chain in the background would look like "
                 "one to take. It has empty iron eyes where they were.",
         "draw": _ROOF_GEAR},
        {"name": "A second cart, off the rails", "z": [-2.8, -1.6], "style": "line", "tag": [-204.2, 41.7],
         "text": "On the back of the pillar's top, tipped against the wall behind the siding, grey: a cart that never made its last run. "
                 "With it, the back rail of the track, which is whole.",
         "draw": [_p([(-205.0, 40.0), (-203.5, 40.0), (-203.3, 41.0), (-204.9, 41.2)]), _ln(-208.9, 40.12, -201.9, 40.12)]},
        {"name": "Two lamp posts", "z": [-1.6, -1.3], "tag": [-210.8, 44.5],
         "text": "The two lanterns here hang in the open air today, 3.4 m over the track, from nothing. Each gets a thin timber post at "
                 "the back of the track to hang from.",
         "draw": [_post(-203.8, 40.0, 43.5, "pale", 0.2), _post(-210.8, 40.0, 43.5, "pale", 0.2), _c(-203.8, 43.7, 0.2, "light"), _c(-210.8, 43.7, 0.2, "light")]},
        {"name": "The warning sign", "z": [-1.4, -1.3], "style": "pale", "tag": [-201.8, 42.6],
         "text": "The skull-pug diamond before the cart, where it is today.",
         "draw": [_p([(-203.05, 41.6), (-202.6, 42.05), (-202.15, 41.6), (-202.6, 41.15)]), _ln(-202.6, 40.0, -202.6, 41.15, "line")]},
    ],
    "play": [
        {"name": "Boards across the track's end", "z": [-1.2, 1.2], "style": "line", "tag": [-213.9, 38.9],
         "text": "There today (note 6): the miners' own stop, three boards nailed across the last 1.6 m of rail, with the rails' ends bent "
                 "down past them. A track that ends in the air always gets these.",
         "draw": [_r(-213.2, 40.0, -211.6, 40.25)]},
        {"name": "The chock", "z": [-0.6, 0.6], "style": "pale", "tag": [-208.4, 41.3],
         "text": "A wooden wedge under the cart's west wheel, with a short pull chain lying on the sleepers. Your weight in the cart rocks "
                 "it off the wedge. It is why the cart waits, and why it goes.",
         "draw": [_p([(-208.15, 40.0), (-207.7, 40.0), (-207.7, 40.32)])]},
        {"name": "The chains' iron eyes", "z": [-0.2, 0.2], "style": "line", "tag": [-212.9, 50.9],
         "text": "Each chain hangs from an iron eye bolted through the first beam, with a rust streak under it. A chain always shows what "
                 "it hangs from.",
         "draw": [_c(-214.2, 50.1, 0.2), _c(-215.8, 50.1, 0.2)]},
    ],
    "foreground": [
        {"name": "A front strut's foot", "z": [1.2, 1.5], "tag": [-207.6, 34.5],
         "text": "The front twin of the back struts is gone. What is left is its lower end in two short lengths, in front of the pillar's "
                 "rock and nowhere else.",
         "draw": [_r(-208.6, 33.2, -208.3, 35.6), _r(-208.6, 36.6, -208.3, 38.2)]},
    ],
    "explains": [
        ["The cart", "An ore cart on the pillar's siding, held by one chock", "The second cart off the rails behind it, and the back rail"],
        ["The stub of track, and its boards", "The first 4 m of the crossing, with the miners' stop nailed across its end", "The two slanting struts that carry it from the pillar"],
        ["The two chains", "The last two of the chains the track's deck hung from", "The beam they hang from, its hanger post, and the unbroken beam behind with its empty eyes"],
        ["The way the cart goes", "Off the end, down, and through the waterfall to the Sump", "The waterfall, whole, straight ahead"],
    ],
    "pieces": [
        ["Waterfall: the sheet, seen side-on", "6 m wide, the full height of the picture", "1", "Background", "kit: waterfall pieces (the water overhaul, note 22)"],
        ["Slanting strut", "0.35 m square; 5.4 m and 2.9 m", "2", "Background", "kit: mine_beam"],
        ["Long beam under the roof, with iron eyes", "0.35 m square, 18.5 m", "1", "Background", "kit: mine_beam; iron eye (mine, added by these pages)"],
        ["Hanger post", "0.35 m square, 2.7 to 4.5 m", "4", "Background", "kit: mine_post"],
        ["Ore cart, tipped", "1.6 m", "1", "Background", "kit: minecart"],
        ["Rail, straight", "2 m lengths", "4", "Background", "kit: rail_straight"],
        ["Lamp post with a hanging lantern", "post 0.2 m by 3.5 m", "2", "Background", "kit: mine_post, thin; lantern_hang"],
        ["Skull-pug warning sign", "1 m", "1", "Background", "kit: sign_pug_skull"],
        ["Boards across the rails; bent rail ends", "1.6 m", "1", "Play space (there today)", "kit: rail_broken; the boards are in the game"],
        ["Chock with a pull chain; iron eye for a chain", "0.45 m; 0.3 m", "1 and 2", "Play space (drawn on)", "new; kit: iron eye (mine, added by these pages)"],
        ["Front strut's foot, in two lengths", "0.3 m wide, 1.6 and 2.4 m", "1", "Foreground", "kit: mine_beam, cut"],
    ],
    "effects": [
        "The chock jumps out and skitters off the edge when the cart starts.",
        "The chains sway a little and clink. Nothing else in the picture moves but the waterfall.",
        "A white burst in the waterfall where the cart goes through it.",
    ],
    "notes": [
        "Note 6 (done): the boards across the rails' end are solid to the end of the drawn rail, and the cart falls for real a cart's length past them.",
        "Note 6, still open: with the boards solid, the first chain can be taken from the boards without riding the cart.",
        "Note 4: only the two real chains hang in this picture.",
    ],
}

# ------------------------------------------------------------------ 1.8 Las Vigas
LAS_VIGAS = {
    "id": "1.8", "slug": "1_8_las_vigas", "title": "Las Vigas", "kind": "challenge",
    "window": [-246.0, 40.0, -210.0, 60.0], "screen": [-222.5, 50.0], "cut_y": 51.9, "climber": [-216.5, 50.5],
    "place": ("Under the flat roof of the cavern, 78 m above the water, the miners hung one long beam on four posts bolted into the roof. "
              "It ran from above the track's end to the landing under the winding wheel, and the deck of the track's long crossing hung "
              "from it on chains. When the deck fell, its weight snapped the beam in three places. The four pieces are still there, each "
              "on its own post, each sagging to a different height, with 2.5 m of air between one splintered end and the next. A second "
              "beam at the back never broke, and shows the line the first one had. You go along what is left the only way there is: "
              "swing under a piece, let go, land on the next. The waterfall is in front of you the whole way."),
    "keep": [
        "The four beams: where each hangs, how long it is, how high.",
        "The two chains on the first, and the staging you land on at the end.",
        "Nothing between you and the water.",
    ],
    "background": [
        {"name": "The waterfall", "z": [-3.0, -1.2], "tag": [-241.0, 46.0], "top": True,
         "text": "Straight ahead, 6 m past the last beam, and you fling towards it three times. From here it is a sheet 6 m wide, white, "
                 "with the winding wheel turning slowly in its spray at the top left. It lights the beams from in front.",
         "draw": _fall(40.0, 60.0)},
        {"name": "The back beam", "z": [-1.9, -1.5], "tag": [-219.4, 53.6], "top": True,
         "text": "The twin of the beam you are crossing, close under the roof and all in one piece, 18.5 m long. It shows what the four "
                 "pieces were. Along it are the empty iron eyes the other chains hung from. No chain hangs from any of them.",
         "draw": [_r(-232.0, 54.25, -213.5, 54.6, "pale")] + [_c(x, 54.12, 0.13, "line") for x in (-219.6, -224.0, -228.4)]},
        {"name": "Four hanger posts", "z": [-1.55, -1.2], "tag": [-222.6, 53.6],
         "text": "One behind the middle of each piece, from the piece up to the roof. Today a post in hold-coloured timber stands in the "
                 "middle of the play space on top of each beam. It moves to the back and goes grey, so the top of a beam is clear to land on.",
         "draw": [_post(x, top, 55.0) for x, top in _HANGERS]},
        {"name": "Two lanterns", "z": [-1.5, -1.3], "style": "light", "tag": [-227.2, 54.0],
         "text": "On the hanger posts of the first and third pieces, where they hang today.",
         "draw": [_c(-216.1, 53.2, 0.17), _c(-226.3, 53.6, 0.17)]},
        {"name": "Stalactites, kept off the route", "z": [-1.9, -1.5], "tag": [-211.6, 53.0],
         "text": "The roof's stalactites hang only east of the first beam. By the course's numbers a 6 m one is placed at the roof between "
                 "the second and third beams today. That one goes: nothing may hang in the air you fling through.",
         "draw": [_p([(-212.6, 55.0), (-211.4, 55.0), (-212.0, 52.0)]), _p([(-211.2, 55.0), (-210.4, 55.0), (-210.8, 53.4)])]},
    ],
    "play": [
        {"name": "Splintered ends", "z": [-1.2, 1.2], "style": "mark", "tag": [-224.05, 50.0],
         "text": "Every end that faces a gap is splintered. The two outer ends are sawn square. So the four read as one beam, broken in "
                 "three places.",
         "draw": [_ln(-218.3, 49.9, -218.3, 50.7), _ln(-220.8, 51.4, -220.8, 52.2), _ln(-222.8, 51.4, -222.8, 52.2),
                  _ln(-225.3, 50.2, -225.3, 51.0), _ln(-227.3, 50.2, -227.3, 51.0), _ln(-229.8, 51.7, -229.8, 52.5)]},
        {"name": "Iron stirrups", "z": [-1.2, 1.2], "style": "line", "tag": [-217.2, 49.4],
         "text": "A rust-orange iron stirrup round each piece where its hanger post takes it. It is what the piece hangs in, and it is the "
                 "one spot on each beam that looks strong.",
         "draw": [_r(round(x - 0.25, 2), round(top - 0.45, 2), round(x + 0.25, 2), round(top + 0.05, 2)) for x, top in _HANGERS]},
        {"name": "Bolt plates in the roof", "z": [-1.2, 1.2], "style": "pale", "tag": [-228.6, 55.9],
         "text": "Drawn on the roof above each post: an iron plate with four bolt heads.",
         "draw": [_r(round(x - 0.35, 2), 55.0, round(x + 0.35, 2), 55.18) for x, top in _HANGERS]},
    ],
    "foreground": [],
    "explains": [
        ["The four beams", "Four pieces of one long beam that hung under the roof", "The back beam, whole, and a hanger post behind each piece"],
        ["The gaps", "Where the beam snapped when the deck fell", "The splintered ends, and the unbroken line of the back beam above"],
        ["The two chains", "The last two of the chains the deck hung from", "The empty iron eyes along the back beam"],
        ["The staging at the far end", "The landing under the winding wheel", "The wheel and its frame (see La Polea Grande)"],
    ],
    "pieces": [
        ["Waterfall: the sheet", "6 m wide, 20 m of it in the picture", "1", "Background", "kit: waterfall pieces (the water overhaul, note 22)"],
        ["Long beam under the roof, with iron eyes", "0.35 m square, 18.5 m", "1", "Background", "the same piece as El Carrito Loco"],
        ["Hanger post", "0.35 m square, 2.7 to 4.5 m", "4", "Background", "kit: mine_post"],
        ["Hanging lantern", "0.4 m", "2", "Background", "kit: lantern_hang"],
        ["Stalactite", "0.8 and 1.2 m across", "2", "Background", "kit: stalactite_a, stalactite_b"],
        ["Splintered end for a beam", "0.4 m", "6", "Play space (drawn on)", "kit: splintered end (mine)"],
        ["Iron stirrup; bolt plate", "0.5 m; 0.7 m", "4 and 4", "Play space (drawn on)", "kit: iron stirrup (mine, added by these pages)"],
    ],
    "effects": [
        "A piece dips and creaks on its post when you land on it. It does not break.",
        "Spray drifting in from the waterfall across the last gap.",
    ],
    "notes": [
        "No note from the playtest was about this challenge.",
        "Note 4: the two chains on the first beam are the only things that hang here.",
        "Note 40: no foreground. There is no rock in this picture to stand anything in front of but the roof.",
    ],
}

# ------------------------------------------------------------------ 1.9 La Polea Grande
_ED = {it["name"]: it["draw"] for it in EL_DERRUMBE["background"]}
_FALL_TROUGH = _p([(-238.6, 61.75), (-238.6, 61.4), (-233.6, 60.7), (-233.6, 61.05)], "pale")

LA_POLEA = {
    "id": "1.9", "slug": "1_9_la_polea_grande", "title": "La Polea Grande", "kind": "challenge",
    "window": [-248.0, 47.0, -221.0, 71.0], "screen": [-234.0, 57.5], "cut_y": 57.2, "climber": [-232.6, 52.45],
    "place": ("The mine's biggest machine, at the foot of the throat the waterfall comes down. It is a winding wheel 6 m across that "
              "hauled the big ore buckets up from the bottom level, 85 m below. It was never turned by hand. A trough catches the edge of "
              "the fall and tips it onto a water wheel on the same axle, just behind, and the water wheel turns the winding wheel. The "
              "water has not stopped, so neither has the wheel: one slow turn every 20 seconds, with nothing left on it to wind. The "
              "planks under it are the landing where the buckets were unhooked. The black sloping roof over it kept spray and falling "
              "rock off the machine. You take the rim at the bottom, and it lifts you up the side nearest the fall, over the top, and "
              "down to the porch of the upper gallery."),
    "keep": [
        "The wheel: its size, its place, its speed and the way it turns.",
        "The staging under it as one run of planks (note 8), the porch, and the gallery floor.",
        "The slick roof over the wheel, and the life ring at its foot (note 15).",
    ],
    "background": [
        {"name": "The waterfall", "z": [-3.0, -1.2], "tag": [-241.0, 50.0], "top": True,
         "text": "Right beside you. The wheel's rim passes within a metre of it, and for a quarter of the ride you are going up with the "
                 "water coming down at your shoulder. It is white, loud, and the brightest thing here by far.",
         "draw": _fall(47.0, 71.0)},
        {"name": "The water wheel", "z": [-2.5, -1.7], "style": "line", "tag": [-235.6, 58.5], "top": True,
         "text": "On the same axle, a metre and a half behind the wheel you ride: a wheel with buckets round its rim, 5 m across, running "
                 "with water. It turns with the front wheel, so you can see that one drives the other.",
         "draw": [_c(-234.2, 57.4, 2.55), _c(-234.2, 57.4, 2.1)]},
        {"name": "The trough from the fall", "z": [-2.5, -1.5], "tag": [-236.2, 62.0],
         "text": "A timber trough from the edge of the waterfall to just past the top of the water wheel, under the sloping roof. Water "
                 "runs along it and falls onto the wheel's east side. That is why the wheel turns the way it does.",
         "draw": [_FALL_TROUGH]},
        {"name": "The frame that carries it", "z": [-1.7, -1.3], "tag": [-231.3, 55.7], "top": True,
         "text": "Two long bearers run out from the rock under the axle, on a slanting strut. The staging hangs under them on two posts, "
                 "and the porch you step off onto is their near end. Today the staging's brace is a hold-coloured timber in the play "
                 "space. It goes.",
         "draw": [_r(-237.8, 56.95, -230.0, 57.3, "pale"), _p([(-230.0, 54.0), (-230.0, 54.6), (-233.3, 56.95), (-234.1, 56.95)], "pale"),
                  _post(-236.9, 52.45, 56.95), _post(-232.5, 52.45, 56.95)]},
        {"name": "The roof's posts", "z": [-1.7, -1.3], "tag": [-232.2, 63.3],
         "text": "Two posts at the back, from the bearers up to the sloping roof. They show that the black slab over the wheel is a roof "
                 "on a frame, not a loose rock.",
         "draw": [_post(-236.9, 57.3, 62.3), _post(-233.0, 57.3, 65.2)]},
        {"name": "The upper gallery", "z": [-2.8, -1.4], "tag": [-225.7, 60.4],
         "text": "The same back wall as on El Derrumbe's page: timber frames along the gallery and a side tunnel boarded shut. The ore "
                 "crate that stands in the play space today, where it looks like a step, moves to the back wall.",
         "draw": _ED["The lower level's back wall"] + [_r(-228.65, 57.4, -227.55, 58.5, "pale")]},
        {"name": "A lantern at the gallery's mouth", "z": [-1.6, -1.3], "style": "light", "tag": [-228.4, 60.9],
         "text": "Today it hangs just outside the wheel's rim, where you come down. It moves onto the back post of the mouth's timber set.",
         "draw": [_c(-229.35, 60.5, 0.17)]},
    ],
    "play": [
        {"name": "The hub", "z": [-0.3, 0.3], "style": "line", "tag": [-233.3, 56.5],
         "text": "An iron-banded hub with the square end of the axle showing in its middle. The axle is the one thing that goes from the "
                 "wheel you hold back to the wheel that drives it.",
         "draw": [_c(-234.2, 57.4, 0.42)]},
        {"name": "The staging", "z": [-1.2, 1.2], "style": "line", "tag": [-238.2, 51.6],
         "text": "One run of planks, as it is now (note 8), with two rows of nail heads where the hanging posts take it.",
         "draw": [_r(-237.2, 52.15, -232.2, 52.45)]},
        {"name": "The sloping roof and the life ring", "z": [-1.2, 1.2], "style": "mark", "tag": [-233.6, 66.3],
         "text": "The roof is black wet boards with pale drips running down to its lower edge, which spills into the fall. Propped at its "
                 "foot is the red and white life ring (note 15). It belongs to La Cortina's page.",
         "draw": [_ln(-237.8, 62.3, -229.9, 68.28), _c(-237.55, 63.12, 0.5, "line")]},
    ],
    "foreground": [
        {"name": "The mouth's front post", "z": [1.2, 1.5], "tag": [-229.0, 64.6],
         "text": "In two lengths, one below the gallery's floor and one above its roof, both in front of rock. The length between them, "
                 "which would stand in front of the doorway, is gone.",
         "draw": [_r(-229.9, 55.1, -229.6, 57.0), _r(-229.9, 62.3, -229.6, 66.8)]},
    ],
    "explains": [
        ["The wheel", "The mine's winding wheel, on one axle with a water wheel", "The water wheel behind it, and the trough that feeds it from the fall"],
        ["The staging", "The landing where the ore buckets were unhooked", "The two posts it hangs on, and the bearers above them"],
        ["The porch", "The near end of the bearers that carry the axle", "The bearers and their strut"],
        ["The slick roof", "The machine's roof, to keep spray and rock off it", "The two posts that hold it up"],
        ["The gallery floor", "The upper gallery, where El Derrumbe starts", "Its timber frames and the boarded tunnel"],
    ],
    "pieces": [
        ["Waterfall: the sheet, and a wet shine on the rock beside it", "6 m wide", "1", "Background", "kit: waterfall pieces (the water overhaul, note 22)"],
        ["Water wheel with buckets", "5 m across", "1", "Background", "new, this area only. The works' kit has a wheel frame it could share"],
        ["Water trough on wall brackets", "0.5 m wide, 5 m long", "1", "Background", "kit: water trough (mine, added by these pages)"],
        ["Bearer, slanting strut, hanging post", "0.35 m square; 7.8 m, 4.5 m, 4.5 m", "2, 1 and 2", "Background", "kit: mine_beam, mine_post"],
        ["Roof post", "0.35 m square; 5 m and 7.9 m", "2", "Background", "kit: mine_post"],
        ["Gallery frames and boarded tunnel", "as El Derrumbe", "3 posts, 1 cap, 1 tunnel", "Background", "the same pieces as El Derrumbe"],
        ["Ore crate", "1.1 m", "1", "Background", "kit: crate_ore"],
        ["Hanging lantern", "0.4 m", "1", "Background", "kit: lantern_hang"],
        ["Iron band and axle end for the hub", "0.8 m", "1", "Play space (drawn on)", "kit: iron strap (mine, added by these pages)"],
        ["Front post, in two lengths", "0.3 m wide, 1.9 and 4.5 m", "1", "Foreground", "kit: timber set post (mine), cut"],
    ],
    "effects": [
        "Water running in the trough and pouring onto the back wheel. Drops flying off the back wheel as it turns.",
        "The roof's lower edge drips into the fall.",
        "The axle groans once a turn.",
    ],
    "notes": [
        "Note 8 (done): the staging is one run of planks. The dark plank at its west end is gone.",
        "Note 15 (done): the life ring at the foot of the roof.",
    ],
}

# ------------------------------------------------------------------ 1.11 La Cortina
def _peg(row, side):
    return (round(-235.6 + 0.11 * row + 1.3 * side, 2), round(73.3 + 1.25 * row, 2))


_DRY = [(1, 0), (4, 1), (7, 0), (10, 1), (13, 0)]


def _drip_board(row, side):
    x, y = _peg(row, side)
    lo, hi = (0.4, 0.62) if side == 0 else (0.62, 0.4)   # it slants away from the other column
    return _p([(round(x - 0.42, 2), round(y + lo, 2)), (round(x + 0.42, 2), round(y + hi, 2)),
               (round(x + 0.42, 2), round(y + hi + 0.09, 2)), (round(x - 0.42, 2), round(y + lo + 0.09, 2))], "pale")


LA_CORTINA = {
    "id": "1.11", "slug": "1_11_la_cortina", "title": "La Cortina", "kind": "challenge", "also": ["a2"],
    "window": [-249.0, 60.0, -221.0, 93.0], "screen": [-234.5, 80.5], "cut_y": 79.55, "climber": [-231.4, 72.0],
    "place": ("The last climb in the mine: 17 m up the back wall of the throat, right beside the top of the waterfall, to the "
              "dry shaft that goes up through the roof into the works above. The miners went up it on pegs. They drilled two rows of "
              "holes in the rock, 1.3 m apart, drove a round timber peg into each, and climbed them like a ladder with no sides. The pegs "
              "are still there, 14 pairs of them, and what you see of each is its round end. The spray wets them in turn, one slow drip "
              "down each row. Five have a little board nailed over them to turn the water aside. Someone who came later hung a rope from "
              "the lip, and someone carried a life ring all the way up here and left it at the foot of the slope below."),
    "keep": [
        "All 28 holds where they are, the two slow drips, and the five holds that never get wet (note 13).",
        "The rope from the lip to half way down (note 14), and the life ring's throw back to the balcony (note 15).",
        "The balcony you start from and the lip you finish on.",
    ],
    "background": [
        {"name": "The throat's back wall", "z": [-1.7, -1.3], "tag": [-246.4, 80.0],
         "text": "The wall the pegs are driven into: black rock, polished and running with water, straight behind you. The holds float in "
                 "the dark today. With the wall drawn, they are plainly on something. Inside the dry shaft at the top it is lined with "
                 "planks on three timber frames, the same as every shaft in the mine.",
         "draw": [_r(-248.0, 60.0, -230.0, 86.0), _r(-236.0, 86.0, -232.0, 90.0)] + [_r(-236.0, y - 0.16, -232.0, y, "pale") for y in (86.3, 87.6, 88.9)]},
        {"name": "The top of the waterfall", "z": [-3.0, -1.2], "tag": [-241.0, 66.0], "top": True,
         "text": "You are level with its top now. It comes through a slot in the roof as one smooth dark sheet and turns white a few "
                 "metres down. It is 2.5 m from the west row of pegs at the bottom and 4 m at the top, and the drips that wet the pegs are "
                 "its spray.",
         "draw": _fall(60.0, 90.4)},
        {"name": "Drip boards", "z": [-1.3, -1.2], "tag": [-236.6, 82.6],
         "text": "Over four of the five pegs that never get wet: a short board nailed to the wall at a slant, grey, 0.8 m long. The drip "
                 "runs down to it, along it and off its low end. The fifth dry peg is the top one, inside the dry shaft. The boards are "
                 "why those pegs stay dry, and you can see it happen.",
         "draw": [_drip_board(r, s) for r, s in _DRY[:4]]},
        {"name": "The top drift", "z": [-2.6, -1.4], "tag": [-225.2, 74.9],
         "text": "Behind the balcony: the same timber frames and hand winch as on El Derrumbe's page.",
         "draw": _ED["The upper level"]},
        {"name": "An empty camp", "z": [-2.2, -1.4], "style": "pale", "tag": [-227.7, 73.1],
         "text": "Against the drift's back wall: a bedroll, a cold lantern and a pickaxe, and nobody. Whoever it was got this far, looked "
                 "at the last wall, and is not here. It is the second and last camp in the mine.",
         "draw": [_r(-228.5, 72.0, -227.0, 72.24), _c(-226.2, 72.2, 0.15, "line"), _ln(-228.75, 72.0, -228.6, 73.0, "line")]},
        {"name": "A lantern by the east wall", "z": [-1.6, -1.3], "style": "light", "tag": [-230.9, 78.6],
         "text": "Today it hangs between the rope and the wall, like a third thing to take. It moves 0.8 m east onto a hook at the back, "
                 "against the wall.",
         "draw": [_c(-230.5, 79.6, 0.17)]},
        {"name": "The wheel's roof, from above", "z": [-2.5, -1.3], "tag": [-232.2, 62.4],
         "text": "Under the slope you slide down if you fall: the two posts that hold it up and the trough from the fall, as on La Polea "
                 "Grande's page.",
         "draw": [_post(-236.9, 60.0, 62.3), _post(-233.0, 60.0, 65.2), _FALL_TROUGH]},
    ],
    "play": [
        {"name": "The pegs", "z": [-1.2, 0.3], "style": "line", "tag": [-237.0, 74.6],
         "text": "Every hold is the round end of a timber peg, honey-coloured, with its rings showing, and with the drilled hole's rim "
                 "round it. Wet, it is a shiny blue-grey and drips, as it does now. The five dry ones (ringed here) are paler, as they "
                 "are now.",
         "draw": [_c(_peg(r, s)[0], _peg(r, s)[1], 0.4) for r, s in _DRY]},
        {"name": "The rope and its bracket", "z": [-0.2, 0.2], "style": "line", "tag": [-231.3, 84.6],
         "text": "There today (note 14): 8 m of rope from an iron bracket under the lip. The bracket gets a strap back to the shaft's "
                 "last timber frame, so you can see what the rope hangs from.",
         "draw": [_r(-232.5, 89.4, -231.9, 89.62), _c(-232.42, 81.4, 0.18)]},
        {"name": "The life ring", "z": [-1.2, 1.2], "style": "line", "tag": [-239.0, 64.4],
         "text": "There today (note 15), propped at the foot of the wet slope. It is the one painted thing in the mine, red and white, "
                 "from the town: the town follows you up.",
         "draw": [_c(-237.55, 63.12, 0.55)]},
        {"name": "The balcony", "z": [-1.2, 1.2], "style": "line", "tag": [-231.4, 70.9],
         "text": "The drift's floor timbers, carried out 3.6 m into the throat. Their sawn ends show at its west edge.",
         "draw": [_r(-233.2, 71.65, -229.6, 72.0)]},
    ],
    "foreground": [
        {"name": "A front post on the east wall", "z": [1.2, 1.5], "tag": [-228.9, 83.4],
         "text": "In four broken lengths, in front of the rock east of the throat. It is 2.5 m from the rope and never in front of the pegs.",
         "draw": [_r(-229.9, 62.4, -229.6, 66.6), _r(-229.9, 68.8, -229.6, 71.4), _r(-229.9, 76.4, -229.6, 80.0), _r(-229.9, 81.6, -229.6, 85.4)]},
    ],
    "explains": [
        ["The 28 holds", "Round timber pegs driven into the rock: the miners' way up beside the fall", "The wet back wall they are driven into, and the lined shaft they lead up into"],
        ["The five holds that stay dry", "Four pegs with a board nailed over them, and one inside the dry shaft", "The drip boards"],
        ["The wet", "The waterfall's spray, running down each row as one slow drip", "The top of the waterfall, 2.5 to 4 m away"],
        ["The rope", "A later climber's rope, from the lip", "Its bracket, strapped to the shaft's last timber frame"],
        ["The balcony", "The end of the top drift's floor", "The drift, its winch, and the empty camp"],
        ["The life ring and the wet slope", "The roof over the winding wheel, and a ring from the town", "The roof's posts and the trough under it"],
    ],
    "pieces": [
        ["Wet rock wall", "18 m by 26 m", "1", "Background", "new, but plain: black polished rock with pale drips"],
        ["Plank lining with its frame", "4 m wide, 1.3 m tall", "3", "Background", "kit: lining panel (mine)"],
        ["Waterfall: the dark sheet at the slot, turning white", "6 m wide", "1", "Background", "kit: waterfall pieces (the water overhaul, note 22)"],
        ["Drip board", "0.85 m by 0.1 m", "4", "Background", "new, this area only"],
        ["Drift frames and hand winch", "as El Derrumbe", "2 posts, 1 cap, 1 winch", "Background", "the same pieces as El Derrumbe"],
        ["Climber's camp, empty: bedroll, cold lantern, pickaxe", "small", "1 of each", "Background", "kit: climber's camp (mine)"],
        ["Hanging lantern", "0.4 m", "1", "Background", "kit: lantern_hang"],
        ["Roof post; water trough", "as La Polea Grande", "2 and 1", "Background", "the same pieces as La Polea Grande"],
        ["Round peg end with its drilled rim", "0.5 m across", "28", "Play space (drawn on)", "new, this area only"],
        ["Strap for the rope's bracket", "0.5 m", "1", "Play space (drawn on)", "kit: iron strap (mine, added by these pages)"],
        ["Front post, in broken lengths", "0.3 m wide, 2.6 to 4.2 m", "4 lengths", "Foreground", "kit: timber set post (mine), cut"],
    ],
    "effects": [
        "The two slow drips, as built (note 13). At each drip board the drip runs along the board and falls off its low end.",
        "Mist drifting east from the fall across the lower rows.",
        "The lit lantern is the last amber light. Above the lip the light is cold teal.",
    ],
    "notes": [
        "Note 13 (done, first-try numbers): the wet is a slow drip you can watch, and five holds never get wet.",
        "Note 14 (done): the rope from the lip to half way down.",
        "Note 15 (done, first-try throw): the life ring at the foot of the wet slope.",
    ],
    "ask": [
        "The holds drawn as the round ends of timber pegs, with a small board over the dry ones: yes or no? Today they are rock knobs.",
    ],
}

# ------------------------------------------------------------------ 1 to 2: the lip
def _arch(cx, cy, r0, r1, st=None, n=10):
    """A round arch seen from the front: a half ring that springs at height cy."""
    import math
    outer = [(round(cx + r1 * math.cos(math.pi * k / n), 2), round(cy + r1 * math.sin(math.pi * k / n), 2)) for k in range(n + 1)]
    inner = [(round(cx + r0 * math.cos(math.pi * k / n), 2), round(cy + r0 * math.sin(math.pi * k / n), 2)) for k in range(n, -1, -1)]
    return _p(outer + inner, st)


THE_LIP = {
    "id": "1 to 2", "slug": "1_to_2_the_lip", "title": "The lip: from the mine to the black waters", "kind": "join", "also": ["a2"],
    "window": [-250.0, 82.0, -220.0, 99.0], "screen": [-234.0, 90.5], "cut_y": 89.6, "climber": [-229.0, 90.0],
    "place": ("The top of the dry shaft, where the mine stops and the works begin. The miners' shaft came up through the roof here into "
              "a river cave. A generation later the company built its water works along that river and laid brick straight on top of "
              "the mine: a weir across the river's end, a pier to keep the water out of the old shaft, and a brick arch over the shaft's "
              "mouth, standing on the miners' last timber set because it was there. So within one screen everything changes hands. Posts "
              "and planks give way to brick and stone, rust-orange pipe appears overhead, the amber lantern is below your feet and the "
              "next one is greenish. And you find out what the waterfall is: the works' river, black and fast, going over the edge 6 m "
              "from where you stand."),
    "keep": [
        "The lip ledge, the dry shaft, the pier with its peaked top, and the slot the river falls through.",
        "The last rows of La Cortina and the rope's bracket below the lip. The first pipe of El Borde above it.",
        "The river's level and its pull towards the edge.",
    ],
    "background": [
        {"name": "The mine's side: the throat's back wall", "z": [-1.7, -1.3], "tag": [-246.6, 84.0],
         "text": "Below the roof: the wet black rock of La Cortina, and the plank lining inside the dry shaft. This is the last of the "
                 "mine's way of building.",
         "draw": [_r(-248.0, 82.0, -230.0, 86.0), _r(-244.0, 86.0, -238.0, 90.0), _r(-236.0, 86.0, -232.0, 90.0)] +
                 [_r(-236.0, y - 0.16, -232.0, y, "pale") for y in (86.3, 87.6, 88.9)]},
        {"name": "The river going over", "z": [-3.0, -1.2], "tag": [-241.0, 84.6], "top": True,
         "text": "At the back, a brick sill with a stone coping holds the river 1 m deep. The water slides over it, bends, and drops into "
                 "the slot as one dark sheet. Nothing here is a block of water with a flat end (note 22). From the ledge you look "
                 "straight across the top of the fall you have climbed beside since the mine's first room.",
         "draw": _fall(82.0, 90.3) + [_r(-244.5, 90.0, -244.0, 90.85, "pale"), _p([(-244.6, 91.0), (-244.0, 91.0), (-243.1, 90.2), (-244.0, 90.0)], "pale")]},
        {"name": "The works' side: a brick wall in bays", "z": [-1.9, -1.3], "tag": [-246.0, 94.9],
         "text": "Above the roof: the back wall of the river tunnel, in slate-grey brick, divided by flat piers every 4 m, with a round "
                 "arch bricked up in each bay. It is the first brick in the game, and round arches are only ever the works'.",
         "draw": [_r(-250.0, 90.0, -226.0, 96.0)] + [_r(x - 0.3, 90.0, x + 0.3, 96.0, "pale") for x in (-248.0, -244.0, -240.0, -236.0, -232.0, -228.0)] +
                 [_arch(cx, 92.6, 1.45, 1.7, "pale") for cx in (-246.0, -242.0, -230.0)]},
        {"name": "The last timber set, and the first arch on top of it", "z": [-1.7, -1.3], "style": "pale", "tag": [-234.0, 92.9], "top": True,
         "text": "In the mouth of the dry shaft stands the mine's last set: two grey posts and a cap. The works' first arch springs "
                 "straight off that cap, brick on timber, with a cast iron pug in its middle. It is lower than every other arch on the "
                 "wall, because the shaft was here first. This one object is the join.",
         "draw": [_post(-235.75, 86.0, 89.55), _post(-232.25, 86.0, 89.55), _r(-236.0, 89.55, -232.0, 89.9),
                  _arch(-234.0, 89.9, 1.5, 1.95), _c(-234.0, 90.75, 0.3, "line")]},
        {"name": "Two lanterns", "z": [-1.6, -1.3], "style": "light", "tag": [-228.4, 94.2],
         "text": "The mine's last, amber, on the west post of the timber set, lighting the shaft from inside. The works' first, greenish, "
                 "hung high over the ledge where the works have it today. Climbing out of the shaft you pass from one into the other.",
         "draw": [_c(-235.35, 88.3, 0.17), _c(-229.4, 94.7, 0.17)]},
    ],
    "play": [
        {"name": "The lip ledge", "z": [-1.2, 1.2], "style": "line", "tag": [-228.0, 88.9],
         "text": "Two layers, and they should look like two. Below: the miners' rock ledge, pale and pick-marked. On top of it: a course "
                 "of pale stone coping, the first of the copings you stand on all through the works. The ledge's west end, where your "
                 "hand first lands, shows five courses of dry pale brick under the coping.",
         "draw": [_r(-232.0, 89.2, -225.5, 89.7), _r(-232.0, 89.7, -226.0, 90.0)]},
        {"name": "The pier", "z": [-1.2, 1.2], "style": "line", "tag": [-237.0, 93.0],
         "text": "Between the slot and the shaft: a brick pier with a peaked stone cap, black and slimy with the river's spray. Wet "
                 "brick is the works' way of saying you can't hold it. Its foot, inside the mine's roof, is rock.",
         "draw": [_r(-238.0, 86.0, -236.0, 91.5)]},
        {"name": "The rope's bracket", "z": [-0.2, 0.2], "style": "line", "tag": [-231.2, 88.0],
         "text": "The mine's last piece of iron (note 14), strapped back to the last timber set.",
         "draw": [_r(-232.5, 89.4, -231.9, 89.62)]},
    ],
    "foreground": [
        {"name": "One post, timber below and brick above", "z": [1.2, 1.6], "tag": [-237.9, 88.0],
         "text": "In front of the pier's rock and nowhere else: a grey timber post up to the roof line, and on top of it a brick pier "
                 "half a metre wide. It is the foreground's own version of the join.",
         "draw": [_r(-237.2, 86.2, -236.85, 89.3), _r(-237.3, 89.3, -236.75, 91.3, "pale")]},
    ],
    "explains": [
        ["The lip ledge", "A stone coping the works laid along the top of the miners' rock ledge", "The brick wall of the river tunnel, in bays, behind it"],
        ["The last pegs and the rope's bracket", "The end of the mine's way up", "The last timber set, with the first brick arch standing on it"],
        ["The pier", "A brick pier that keeps the river out of the old shaft", "The brick sill the river slides over, just beyond it"],
        ["The slot and the falling water", "The river, going over the edge", "The sill and the bend of the water at the back"],
        ["The first pipe overhead", "The works' iron, coming down to the ledge", "It is designed on El Borde's page, in the black waters"],
    ],
    "pieces": [
        ["Plank lining with its frame", "4 m wide, 1.3 m tall", "3", "Background", "kit: lining panel (mine)"],
        ["Timber set: two posts and a cap, grey and wet", "posts 0.35 m, 3.55 m tall; cap 4 m", "1", "Background", "kit: timber set (mine)"],
        ["Brick wall bay with a round arch, bricked up", "4 m wide, 6 m tall", "6", "Background", "the black waters' kit: brick wall bay"],
        ["Round brick arch, low, to sit on the timber cap", "4 m wide, 2 m tall", "1", "Background", "the black waters' kit: brick wall bay, the arch alone"],
        ["Cast pug", "0.6 m", "1", "Background", "the black waters' kit: cast pug"],
        ["Brick sill with stone coping", "0.5 m wide, 0.85 m tall", "1", "Background", "the black waters' kit: pier with stone coping"],
        ["Water: the bend over the sill, the dark sheet", "6 m wide", "1", "Background", "the water overhaul (note 22)"],
        ["Hanging lantern, amber; works lantern, greenish", "0.4 m", "1 and 1", "Background", "kit: lantern_hang; the black waters' kit: works lantern"],
        ["Stone coping; dry brick courses for the ledge's end", "6 m; 0.5 m", "1 and 1", "Play space (drawn on)", "the black waters' kit: pier with stone coping"],
        ["Peaked stone cap and wet brick for the pier", "2 m wide", "1", "Play space (drawn on)", "the black waters' kit: pier with stone coping"],
        ["Front post: timber length and brick length", "0.35 m by 3.1 m; 0.55 m by 2 m", "1", "Foreground", "kit: timber set post (mine); the black waters' kit: pier"],
    ],
    "effects": [
        "The light changes as you climb out: warm on your back from the shaft, cold teal on your face from the tunnel.",
        "A pale shimmer off the river on the undersides of the arches. It moves but it does not pulse.",
        "The fall's roar drops to a hiss the moment your head is above the roof.",
    ],
    "notes": [
        "Note 14 (done): the rope's bracket under the lip.",
        "Note 22: the river's end is a bend of water over a sill, never a block.",
        "Note 17: nothing in the works' light pulses.",
    ],
}

# ------------------------------------------------------------------ 1.0b The landing stage and the incline
def _slope_y(x):
    """The incline's surface: from the gallery's mouth down to the water."""
    return round(-12.64 + 1.2838 * (x + 175.8), 2)


_WINCH = [_r(-175.7, -12.6, -173.9, -10.9, "dark"), _r(-175.5, -12.6, -174.1, -12.3, "pale"), _c(-174.8, -11.75, 0.5, "line"), _ln(-174.8, -11.75, -174.2, -11.2, "line")]

THE_LANDING = {
    "id": "1.0b", "slug": "1_0b_the_landing", "title": "The landing stage and the incline", "kind": "rest",
    "window": [-212.0, -36.0, -172.0, -6.0], "screen": [-186.0, -24.0], "cut_y": -27.5, "climber": [-188.4, -27.7],
    "place": ("The east end of the Sump, and the way back up. When the bottom level was dry, ore was hauled from it to the main gallery "
              "up a steep track, by a hand winch at the top. The rails are gone, but the sleepers are still spiked to the slope, and they "
              "are your steps. At the foot is the landing stage, the one dry plank at the water's edge, where the miners tied up the flat "
              "boat they used once the water had come. To reach it you swim under El Diente, through what was the bottom level's tunnel "
              "through the foot of the pillar. Everyone who falls into the Sump comes out here. The waterfall is 50 m behind you by now: "
              "a noise, and a cold light on the water."),
    "keep": [
        "The incline, its six sleepers and its steepness. The landing stage and the last pile.",
        "The swim under the pillar, with 2.5 m of air over the water.",
    ],
    "background": [
        {"name": "The cavern's wall", "z": [-3.6, -2.9], "tag": [-192.0, -12.0],
         "text": "The same hand-cut wall as behind Los Tablones, 20 to 34 m below the walk. Down here it is black and wet, and the lower "
                 "walk's row of empty sockets is far overhead.",
         "draw": [_r(-197.9, -33.0, -172.0, -6.0)]},
        {"name": "The tunnel through the pillar's foot", "z": [-2.0, -1.3], "tag": [-203.6, -26.9], "top": True,
         "text": "The space you swim through under El Diente was cut by the miners: the bottom level's road, 11 m long, with four timber "
                 "sets. Their posts stand in the water and their caps are just under the rock. So the pillar stands on a timbered "
                 "tunnel, not on a gap.",
         "draw": [_r(-208.9, -33.0, -197.9, -25.5), _r(-208.9, -25.9, -197.9, -25.55, "pale")] + [_post(x, -33.0, -25.9, "pale") for x in (-207.6, -205.0, -202.4, -199.3)]},
        {"name": "The back rail, and a cart left on it", "z": [-2.6, -1.4], "style": "line", "tag": [-185.9, -20.9],
         "text": "Behind the sleepers one rail of the old track is still spiked down, from the water to the gallery's mouth, and a grey "
                 "ore cart sits on it a third of the way up, where the winch let it stop.",
         "draw": [_ln(-188.6, -28.62, -176.2, -12.7), _p([(-184.4, -23.23), (-183.42, -21.97), (-184.13, -21.42), (-185.11, -22.68)])]},
        {"name": "The winch at the head of the incline", "z": [-2.9, -1.3], "tag": [-174.8, -10.3],
         "text": "In its cut beside the gallery's mouth, as on the camp's page. Its drum is bare.",
         "draw": _WINCH},
        {"name": "The drowned level", "z": [-2.9, -2.0], "style": "pale", "tag": [-192.3, -26.5], "top": True,
         "text": "The bottom level's timber sets, carried on east of the pillar along the wall, under water to their caps.",
         "draw": [_post(x, -33.0, -27.75) for x in (-196.4, -193.2, -190.6)] + [_r(-196.8, -27.75, -190.2, -27.45, "pale")]},
        {"name": "A lamp post and the pug arrow", "z": [-1.6, -1.3], "tag": [-189.7, -23.5],
         "text": "At the back of the landing stage. The lantern that hangs in the air here today gets a post to hang from. Under it "
                 "the mine's arrow sign points up the incline.",
         "draw": [_post(-188.6, -27.7, -24.2, "pale", 0.2), _c(-188.6, -24.0, 0.2, "light"),
                  _p([(-188.45, -26.3), (-187.6, -26.3), (-187.15, -25.95), (-187.6, -25.6), (-188.45, -25.6)], "pale")]},
        {"name": "The miners' boat", "z": [-2.4, -1.4], "style": "line", "tag": [-192.5, -29.6],
         "text": "A flat boat 3 m long, sunk at its mooring behind the landing stage, with one end still out of the water.",
         "draw": [_p([(-193.9, -28.5), (-191.0, -28.5), (-190.7, -27.85), (-194.2, -28.2)])]},
    ],
    "play": [
        {"name": "Spike plates and rust lines", "z": [-1.2, 1.2], "style": "mark", "tag": [-180.5, -20.6],
         "text": "Each sleeper gets two iron plates where the rails were spiked, and the slope between gets two faint rust lines. The "
                 "slope reads as a track with its rails taken up.",
         "draw": [_ln(-188.9, round(_slope_y(-188.9) + 0.12, 2), -176.3, round(_slope_y(-176.3) + 0.12, 2))]},
        {"name": "The landing stage", "z": [-1.2, 1.2], "style": "line", "tag": [-188.7, -29.0],
         "text": "A plank deck on two short piles, with an iron mooring ring at its end.",
         "draw": [_r(-190.4, -28.0, -187.0, -27.7)]},
    ],
    "foreground": [
        {"name": "The near bank", "z": [1.3, 3.2], "style": "dark", "tag": [-200.0, -35.1],
         "text": "The same low lip of black wet rock as at the Sump's west end, along the bottom of the frame and below the pool's floor.",
         "draw": [_p([(-212.0, -36.0), (-212.0, -33.6), (-204.0, -33.9), (-196.0, -33.5), (-191.5, -33.8), (-186.0, -33.4), (-180.0, -33.8), (-172.0, -33.5), (-172.0, -36.0)])]},
    ],
    "explains": [
        ["The incline and its sleepers", "The bottom level's haulage track, with the rails taken up", "The one rail still down behind it, the cart on it, the winch at the top"],
        ["The landing stage", "Where the miners' boat tied up after the water came", "The sunk boat, the lamp post and the arrow"],
        ["The water under the pillar", "The bottom level's tunnel through the pillar's foot", "Its four timber sets, standing in the water"],
        ["The last pile", "The east end of the staging that crossed the bottom level", "The drowned timber sets along the back wall"],
    ],
    "pieces": [
        ["Timber set, drowned", "posts 0.35 m; caps to suit", "7 posts, 2 caps", "Background", "kit: timber set (mine)"],
        ["Rail, straight", "2 m lengths", "10", "Background", "kit: rail_straight"],
        ["Ore cart", "1.6 m", "1", "Background", "kit: minecart"],
        ["Hand winch in its own cut", "winch 1.6 m by 1.4 m", "1", "Background", "the same piece as the camp's"],
        ["Lamp post with a hanging lantern", "post 0.2 m by 3.5 m", "1", "Background", "the same piece as El Carrito Loco's"],
        ["Pug arrow sign", "1 m", "1", "Background", "kit: sign_pug_arrow"],
        ["Flat boat, sunk", "3 m by 0.7 m", "1", "Background", "new, this area only"],
        ["Spike plate; mooring ring", "0.3 m", "12 and 1", "Play space (drawn on)", "kit: iron strap (mine, added by these pages)"],
        ["Low lip of wet rock", "40 m by 1 m", "1", "Foreground", "there today"],
    ],
    "effects": [
        "Water running off you onto the landing stage's planks.",
        "The lantern's light on the water under the pillar, so the tunnel's mouth can be found from the west.",
    ],
    "notes": [
        "No note from the playtest was about this place. It is here because every great fall ends with this walk.",
    ],
}

# ------------------------------------------------------------------ pieces more than one area uses, added to the mine's kit
KIT_MORE = [
    ["Iron strap, stirrup, eye and plate", "0.2 to 0.7 m", "wherever timber hangs from timber, and wherever a chain or a rope is made fast", "Play space (drawn on), background", "new"],
    ["Walk bearer: a square timber in a wall socket, with a strut under it", "0.3 m square, 1.7 m long", "under every plank walk and deck that is fixed to a wall", "Background", "new"],
    ["Water trough on wall brackets", "0.5 m wide, 3 to 5 m long", "carries water to a machine: the bucket lift, the winding wheel", "Background", "new, cut from the ore chute"],
]

AREAS = [SUMP, THE_LANDING, LA_GALERIA, THE_CAMP, ESCALERA_ROTA, LOS_TABLONES, LA_CUERDA, EL_CUBO, VETAS_DE_LODO,
         EL_CARRITO, LAS_VIGAS, LA_POLEA, EL_DERRUMBE, LA_CORTINA, THE_LIP]
