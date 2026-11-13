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

AREAS = [EL_DERRUMBE]
