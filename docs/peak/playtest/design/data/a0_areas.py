# La Estación's areas, one dict each, in the order the player meets them. Format: see ../build.py.
# The station, then the ride in three stretches, then the join with the mine.

# ------------------------------------------------------------------ the tunnel's own numbers
# The rail bed (the tunnel's floor) as the course has it. The roof is 5 m above it all the way.
_BED = [(-36.0, 2.2), (-46.0, 0.75), (-62.0, -3.45), (-78.0, -4.65), (-90.0, -2.65),
        (-104.0, -6.95), (-120.0, -10.05), (-136.0, -11.65), (-152.0, -12.0)]


def _fy(x):
    """The bed's height at x."""
    for (xa, ya), (xb, yb) in zip(_BED, _BED[1:]):
        if xb <= x <= xa:
            return round(ya + (yb - ya) * (x - xa) / (xb - xa), 2)
    return _BED[0][1] if x > _BED[0][0] else _BED[-1][1]


def _ry(x):
    """The roof's height at x."""
    return round(_fy(x) + 5.0, 2)


# A timber set every 2.6 m from the mouth: 44 of them (number 0 is the mouth), then one wide
# bay with the buffer in it, then the door set at x -152, which the mine shares.
_SET_X = [round(-36.0 - 2.6 * k, 1) for k in range(44)]


def _wall(x_east, x_west):
    """The tunnel's back wall between two x: the shape of its air."""
    xs = [x_east] + [p[0] for p in _BED if x_west < p[0] < x_east] + [x_west]
    return ["poly", [[x, _fy(x)] for x in xs] + [[x, _ry(x)] for x in reversed(xs)]]


def _back_sets(ks):
    """The back post and the cap's end of each set."""
    out = []
    for k in ks:
        x = _SET_X[k]
        out.append(["rect", x - 0.15, _fy(x), x + 0.15, _fy(x) + 4.7])
        out.append(["rect", x - 0.22, _fy(x) + 4.7, x + 0.22, _fy(x) + 5.0])
    return out


def _front_posts(ks):
    out = []
    for k in ks:
        x = _SET_X[k]
        out.append(["rect", x - 0.15, _fy(x), x + 0.15, _fy(x) + 5.0])
    return out


_FRONT_TEXT = ("The front post of every fourth set, so one every 10.4 m. Each is 0.3 m wide and plain. At the cart's speed one sweeps "
               "past about every 1.2 seconds, and there are never more than two on screen. The back post of the same set stands "
               "behind it, so you pass between the two. All the other sets have a back post and a cap only.")

# ------------------------------------------------------------------ 0.1 and 0.2: the station
_house = [["rect", 2.6, 0.0, 8.6, 3.0],
          ["poly", [[2.2, 3.0], [9.0, 3.0], [8.4, 4.2], [2.8, 4.2]], {"style": "pale"}],
          ["rect", 3.3, 0.0, 4.3, 2.1, {"style": "dark"}],                       # the door
          ["rect", 7.0, 1.1, 8.2, 2.1, {"style": "dark"}],                       # the ticket window
          ["rect", 6.9, 1.0, 8.3, 1.1, {"style": "pale"}],                       # its sill
          ["rect", 4.9, 1.1, 6.5, 2.3, {"style": "pale"}],                       # the board of the ones who tried
          ["line", 5.1, 1.3, 5.5, 1.7, {"style": "mark"}], ["line", 5.1, 1.7, 5.5, 1.3, {"style": "mark"}],
          ["line", 5.9, 1.7, 6.3, 2.1, {"style": "mark"}], ["line", 5.9, 2.1, 6.3, 1.7, {"style": "mark"}],
          ["line", 2.6, 2.75, 2.0, 2.75, {"style": "line"}], ["circle", 2.0, 2.5, 0.2, {"style": "line"}]]   # the bell

_far = [["poly", [[-18.5, 0.0], [-18.5, 7.2], [-15.6, 9.4], [-14.9, 9.7], [-14.2, 9.3], [-11.5, 6.3], [-8.5, 4.3], [-4.5, 2.8], [-0.5, 1.7], [2.6, 1.2], [2.6, 0.0]]],
        ["circle", -14.9, 9.75, 0.12, {"style": "light"}],
        ["rect", 9.0, 0.0, 10.1, 1.5, {"style": "pale"}], ["rect", 10.1, 0.0, 11.5, 2.1, {"style": "pale"}],
        ["poly", [[8.9, 1.5], [10.2, 1.5], [9.55, 2.0]], {"style": "pale"}]]

_dock_back = [["rect", -10.15, 0.0, -9.85, 1.75], ["rect", -18.15, 0.0, -17.85, 1.75],
              ["rect", -6.5, 2.2, -6.3, 3.2], ["rect", -12.4, 2.2, -12.2, 3.2], ["rect", -18.3, 2.2, -18.1, 3.2],
              ["line", -18.5, 3.2, -6.3, 3.2, {"style": "line"}]]

_crane = [["rect", -5.75, 2.2, -5.45, 5.2, {"style": "pale"}],
          ["line", -5.6, 4.9, -2.8, 5.5], ["line", -5.6, 3.5, -4.2, 5.2],
          ["circle", -5.6, 3.1, 0.3],
          ["rect", -2.95, 5.05, -2.65, 5.45, {"style": "pale"}]]

_bunting = [["line", 2.8, 4.2, -1.4, 4.4], ["line", -1.4, 4.4, -5.6, 5.2],
            ["line", -5.6, 5.2, -9.5, 4.6], ["line", -9.5, 4.6, -13.4, 5.4], ["line", -13.4, 5.4, -18.5, 4.7],
            ["rect", -13.5, 2.2, -13.3, 5.4, {"style": "pale"}]]

LA_ESTACION = {
    "id": "0.1-0.2", "slug": "0_1_0_2_el_primer_paso_y_subete", "title": "El Primer Paso and Súbete", "kind": "challenge",
    "window": [-18.5, -3.2, 11.5, 10.2], "screen": [-3.0, 3.3], "cut_y": 1.0, "climber": [4.0, 0.0],
    "place": ("This is where the town stops and the mine's ground starts. The road ends at the station house, a small plastered building "
              "with a ticket window and a tiled roof. West of it stands the ore dock: a timber platform 2.2 m high and 31 m long that runs "
              "from the road to the tunnel mouth, with a siding along it. Ore came out of the mountain in carts, was swung down off the "
              "dock's end by a hand crane, and went into town by wagon. The last load is still sitting where the crane put it down, under "
              "the crane's arm. Its crates are your first steps. One cart is left on the siding with its brake on, and somebody still oils it."),
    "keep": [
        "The three crates as steps: one, then two stacked against the dock's end. Each step is 1.1 m.",
        "The dock: its deck 2.2 m up, its east end at x -4.6, its legs where they are.",
        "The cart on the siding at x -9, with its low sides, and that it rolls once you have been in it a moment.",
        "The red lever beside the cart, at x -7.6.",
        "The start: on the road at x 6, 8 m east of the crates, facing the mountain.",
    ],
    "background": [
        {"name": "The Peak and the town, far off", "z": [-40.0, -12.0], "tag": [-14.2, 7.0],
         "text": "Far cut-outs, the plaza's own. The Peak stands whole in the west half of the sky with the tiny bell on its top: the only "
                 "time you see all of it until the ending. Low in the east, the town's roofs. Both are flat and sun-bleached, so nothing near is mistaken for them.",
         "draw": _far},
        {"name": "The station house", "z": [-4.6, -2.2], "tag": [5.7, 3.6],
         "text": "Cream plaster, a terracotta roof, a painted door, a ticket window, and a small bell on a bracket at its corner. It stands on "
                 "the road right behind where you start. On its wall, between the door and the window, hangs the board of the ones who tried: "
                 "rows of small painted masks, most crossed out. The biome's sheet asks whether you want the board.",
         "draw": _house},
        {"name": "The frog", "z": [-2.4, -2.2], "style": "light", "tag": [7.6, 0.55], "top": True,
         "text": "Asleep on the sill of the ticket window, 1.1 m above the road, in plain sight. It is the first frog, so it is not hidden: "
                 "it teaches you there are frogs to find (note 60).",
         "draw": [["circle", 7.6, 1.26, 0.16]]},
        {"name": "The rest of the load", "z": [-3.2, -1.4], "style": "pale", "tag": [-0.1, 1.25],
         "text": "A barrel and a heap of ore sacks on the road beside the crates, 1.4 m further back. They say the crates are a load that "
                 "was set down, not a staircase somebody built. Greyer than the crates, and too low to look like another step.",
         "draw": [["rect", -1.7, 0.0, -0.8, 0.9], ["line", -1.7, 0.3, -0.8, 0.3], ["line", -1.7, 0.6, -0.8, 0.6],
                  ["poly", [[-0.6, 0.0], [1.0, 0.0], [0.7, 0.45], [0.2, 0.75], [-0.4, 0.45]]]]},
        {"name": "The hand crane", "z": [-3.0, -2.3], "style": "line", "tag": [-4.3, 6.0], "top": True,
         "text": "On the dock's back corner, 3 m tall, its arm swung out over the crates. The hook block is wound right up under the arm's "
                 "tip, so nothing hangs from it. It is what put the crates there.",
         "draw": _crane},
        {"name": "The dock's back half", "z": [-3.8, -1.3], "style": "pale", "tag": [-10.0, 0.9],
         "text": "The dock is 5 m deep and you climb only its front edge. Behind it runs the rest: a second row of posts, set between "
                 "the front legs so both rows show, and a rail along the back edge.",
         "draw": _dock_back},
        {"name": "The second cart", "z": [-3.4, -2.2], "style": "pale", "tag": [-15.7, 3.95], "top": True,
         "text": "On blocks at the back of the dock, its wheels gone. The cart you ride has been kept running with parts from this one. "
                 "Its own brake lever stands beside it, rusted, with the same rod and chock: the dead one shows you how the red one works.",
         "draw": [["rect", -16.9, 2.5, -14.5, 3.3], ["rect", -16.6, 2.2, -16.2, 2.5], ["rect", -15.2, 2.2, -14.8, 2.5],
                  ["line", -14.1, 2.2, -14.1, 3.1, {"style": "line"}], ["line", -14.1, 2.3, -14.6, 2.3, {"style": "line"}]]},
        {"name": "The bunting", "z": [-2.6, -2.3], "style": "mark", "tag": [-9.5, 5.3], "top": True,
         "text": "Torn papel picado from the station's roof to the crane's head, then from pole to pole along the dock's back rail, all "
                 "the way to the tunnel. It points the way before the sign does. It is high, it is 2.3 m behind you, and its flags are 0.5 m deep, so it can't be taken for a rope.",
         "draw": _bunting},
        {"name": "The pug arrow sign", "z": [-1.6, -1.4], "style": "pale", "tag": [1.2, 3.3],
         "text": "Where it stands today, moved 0.4 m further back so it is clear of the play space.",
         "draw": [["rect", 1.0, 1.4, 2.0, 2.2], ["line", 1.5, 0.0, 1.5, 1.4]]},
    ],
    "play": [
        {"name": "Stencils on the crates", "z": [1.15, 1.2], "style": "line", "tag": [-2.6, 1.6],
         "text": "Each crate gets the mine's pug stencilled on its face and iron straps at its corners. The top edges are scuffed pale where hands and boots go.",
         "draw": [["circle", -2.6, 0.55, 0.28], ["circle", -3.9, 0.55, 0.28], ["circle", -3.9, 1.65, 0.28]]},
        {"name": "Sawn ends along the deck's edge", "z": [1.15, 1.2], "style": "pale", "tag": [-12.0, 1.2],
         "text": "The deck's cross-beams show as a row of square sawn ends along its face, one every 2 m. They say the deck carries on back. The mine uses the same mark on its rock.",
         "draw": [["rect", x - 0.1, 1.86, x + 0.1, 2.06] for x in (-5.4, -7.4, -9.4, -11.4, -13.4, -15.4, -17.4)]},
        {"name": "The brake rod", "z": [-0.9, -0.6], "style": "line", "tag": [-6.9, 3.0],
         "text": "The lever is red, and so is the band round the cart: here, red means it does something. A short iron rod runs along the "
                 "deck from the lever's foot to a wooden chock under the cart's wheel, so you can see what the lever holds.",
         "draw": [["line", -7.6, 2.3, -8.2, 2.3], ["poly", [[-8.5, 2.2], [-8.2, 2.2], [-8.2, 2.42]], {"style": "pale"}]]},
    ],
    "foreground": [
        {"name": "A fence post with a tail of bunting", "z": [1.8, 2.0], "tag": [10.3, -1.6], "top": True,
         "text": "The last post of the town's fence, at the right edge of the first screen, with a torn tail of bunting tied to it. It stands "
                 "on the low ground in front of the road, and its top comes only 0.3 m above the road, so it never covers you.",
         "draw": [["rect", 10.2, -1.1, 10.4, 0.3], ["line", 10.3, 0.2, 9.5, -0.3, {"style": "mark"}], ["line", 9.5, -0.3, 9.1, -0.9, {"style": "mark"}]]},
        {"name": "An agave clump", "z": [1.6, 2.4], "style": "dark", "top": True,
         "text": "On the low ground at the bottom of the frame, in front of the road's face. It is below your feet wherever you stand.",
         "draw": [["poly", [[-9.7, -2.7], [-9.5, -1.7], [-9.2, -2.2], [-8.9, -1.4], [-8.6, -2.2], [-8.2, -1.6], [-8.0, -2.7]]]]},
    ],
    "explains": [
        ["The road", "The end of the town's road, where the wagons turned", "The station house with its door and ticket window, and the town's roofs beyond"],
        ["The three crates", "The front of the last load the crane set down, never collected", "The crane's arm over them, the barrel and the ore sacks beside them"],
        ["The dock's deck and legs", "The front edge of the mine's ore dock", "Its back half: the second row of posts, the back rail, the bunting poles"],
        ["The cart", "The one cart somebody still oils, on the siding", "The second cart on blocks, robbed of its wheels to keep this one going"],
        ["The red lever", "The brake: a rod to a chock under the cart's wheel", "The second cart's own lever at the back of the dock, rusted, with the same rod and chock"],
        ["The rails", "The siding, running west along the dock to the tunnel", "The bunting, which runs the same way and gets there first"],
    ],
    "pieces": [
        ["Station house front: plaster wall, door, ticket window, tiled roof, bell on a bracket", "6 m wide, 4.2 m tall", "1", "Background", "kit: station house front"],
        ["The board of the ones who tried", "1.6 m by 1.2 m", "1", "Background", "kit: the board"],
        ["The frog, asleep", "0.3 m", "1", "Background", "kit: the frog"],
        ["Hand crane, hook wound up", "3 m tall, arm 3 m", "1", "Background", "kit: hand crane"],
        ["Barrel; heap of ore sacks", "0.9 m; 1.6 m by 0.75 m", "1 of each", "Background", "kit: barrel, ore sacks"],
        ["Dock back post; back rail", "post 0.3 m, 1.75 m tall; rail 1 m high", "2 posts, 12 m of rail", "Background", "kit: loading platform back posts and rail"],
        ["Cart body on two blocks, no wheels; a rusted brake lever", "2.4 m long; lever 1 m", "1 of each", "Background", "kit: minecart, wheels taken off; brake_lever, unpainted"],
        ["Bunting, torn; bunting pole", "strings of 8 m; pole 3.2 m", "3 strings, 1 pole", "Background", "kit: papel_tatters; pole new, in the list below"],
        ["Pug arrow sign", "1 m by 2.2 m", "1", "Background", "kit: sign_pug_arrow"],
        ["The Peak; the town's roofs", "the whole sky", "1 of each", "Background, far", "kit: the plaza's cut-outs"],
        ["Ore crate with pug stencil and corner straps", "1.2 m by 1.1 m", "3", "Play space", "kit: crate_ore; the stencil is new paint"],
        ["Sawn beam end", "0.2 m square", "7", "Play space (drawn on)", "kit: sawn beam end (mine)"],
        ["Brake rod and wheel chock", "rod 0.6 m; chock 0.3 m", "1", "Play space", "new, this area only; with kit: brake_lever"],
        ["Fence post with a tail of bunting", "1.4 m", "1", "Foreground", "kit: fence post"],
        ["Agave clump", "1.7 m by 1.3 m", "1", "Foreground", "kit: agave clump"],
    ],
    "effects": [
        "The frog croaks now and then, loud enough to hear from the start. It does not wake.",
        "The bunting stirs. Nothing else moves until you do.",
        "Short hard shadows under the dock and the crates: the noon sun is straight overhead.",
    ],
    "notes": [
        "Note 60: the frog. It sleeps on the sill of the station's ticket window, in plain sight.",
    ],
    "ask": [
        "The challenge list says grabbing the red lever lets the cart roll. In the course today the lever is scenery, and only sitting in the cart starts it. Should the lever work?",
    ],
}

# ------------------------------------------------------------------ 0.3a: the dock, the mouth, the first drop
_hill = [["poly", [[-36.0, 0.0], [-29.5, 0.0], [-31.2, 2.8], [-34.0, 5.5], [-36.0, 9.7]]]]

_dock_back_west = [["rect", -26.15, 0.0, -25.85, 1.75],
                   ["line", -24.5, 3.2, -30.6, 3.2, {"style": "line"}], ["rect", -30.7, 2.2, -30.5, 3.2],
                   ["poly", [[-33.8, 4.6], [-31.0, 4.6], [-31.6, 3.0], [-33.2, 3.0]]],                 # the hopper
                   ["rect", -33.5, 2.2, -33.3, 3.0], ["rect", -31.5, 2.2, -31.3, 3.0],
                   ["poly", [[-31.4, 3.0], [-30.8, 3.0], [-27.6, 0.9], [-27.9, 0.6]]],                 # its chute
                   ["rect", -27.4, 2.2, -26.0, 2.6]]                                                   # the trough

_bunting_in = [["rect", -29.5, 2.2, -29.3, 5.4, {"style": "pale"}],
               ["line", -24.5, 4.7, -29.4, 5.4], ["line", -29.4, 5.4, -31.8, 5.9], ["line", -31.8, 5.9, -34.2, 7.25],
               ["line", -36.2, 6.9, -41.0, 5.6], ["line", -41.0, 5.6, -46.4, 5.4]]

_bricks = [["rect", -56.4, -1.6, -54.6, 1.3], ["line", -56.4, -0.9, -54.6, -0.9, {"style": "mark"}],
           ["line", -56.4, -0.2, -54.6, -0.2, {"style": "mark"}], ["line", -56.4, 0.5, -54.6, 0.5, {"style": "mark"}]]

LA_BOCA = {
    "id": "0.3a", "slug": "0_3a_el_descenso_the_mouth", "title": "El Descenso, part one: the dock, the tunnel mouth and the first drop", "kind": "challenge",
    "window": [-64.5, -7.0, -24.5, 11.0], "screen": [-41.0, 3.0], "cut_y": 2.0, "climber": [-41.0, 1.48],
    "place": ("The ride starts in the open. The cart runs 27 m west along the dock, in the sun, with the Peak's foot coming up to meet it, "
              "and goes into the mountain through the tunnel mouth. The mouth is the mine's first timber set, the same two posts and a cap "
              "as every set inside, whitewashed here because this end belongs to the town. Inside, the tunnel tips downhill at once. For "
              "the first 26 m the sets and the plank lining are still white, the first lantern is bright, and one last string of bunting "
              "follows you in and stops. This was the haulage way. Full carts were hauled up it by mule to the dock, and the empties ran "
              "down by their own weight, as yours does."),
    "keep": [
        "The track's line: level along the dock to x -34, then down at 7 degrees to x -46, then down at 15 degrees to x -62.",
        "The cart's speed: it is at its full 9 m a second by the time it reaches the mouth.",
        "The mouth at x -36, 5 m tall. The roof stays 5 m above the bed all the way down.",
        "The bed grips, so you can get out and walk the tunnel.",
        "The lantern lights at x -46 and x -62.",
    ],
    "background": [
        {"name": "The mountain's foot", "z": [-6.0, -1.7], "tag": [-33.6, 1.0],
         "text": "Pale dry rock coming down to the road behind the dock's last 6 m. Above the mouth it becomes the Peak's east face, "
                 "which the course already has. It is what the dock runs into.",
         "draw": _hill},
        {"name": "The dock's back half, the ore hopper and the mules' trough", "z": [-4.4, -1.3], "style": "pale", "tag": [-32.4, 3.9], "top": True,
         "text": "The back posts and the back rail carry on from the station. Against the hill stands a timber hopper on legs, where carts "
                 "were tipped, with a chute down behind the dock to where the wagons stood. Beside it is a water trough, for the mules that hauled the full carts up.",
         "draw": _dock_back_west},
        {"name": "The pug over the mouth", "z": [-1.6, -1.3], "style": "pale", "tag": [-33.2, 8.9], "top": True,
         "text": "A round painted board, 1.2 m across, on an iron bracket above the cap, turned to face the camera like a shop sign. "
                 "A pug painted flat over the cap would face the town, and from the side you would see only its edge.",
         "draw": [["circle", -34.1, 7.95, 0.6], ["line", -36.0, 7.25, -34.1, 7.25, {"style": "line"}]]},
        {"name": "The tunnel's back wall", "z": [-2.0, -1.7], "tag": [-50.0, 1.4],
         "text": "Plank lining, limewashed white as far as the second lantern. The planks are nailed on level while the floor falls "
                 "away under them, so the wall itself shows you how steep the track is.",
         "draw": [_wall(-36.0, -64.5)]},
        {"name": "A bricked-up side passage", "z": [-2.6, -1.7], "style": "pale", "tag": [-55.5, 1.9],
         "text": "Between two sets, 19 m in. Bricked up and whitewashed, which is town work. Further down, a closed passage is boarded, which is the mine's way.",
         "draw": _bricks},
        {"name": "The timber sets, whitewashed", "z": [-1.7, -1.3], "style": "pale", "tag": [-59.4, 0.3],
         "text": "A set every 2.6 m: a back post against the lining and a cap across the roof, posts 0.3 m square. Eleven in this "
                 "stretch, counting the mouth, all whitewashed, the wash a little thinner on each one.",
         "draw": _back_sets(range(0, 11))},
        {"name": "Two lanterns", "z": [-1.5, -1.3], "style": "light", "tag": [-47.6, 4.1], "top": True,
         "text": "Each hangs under a set's cap at a place where the track changes slope, so a lantern always marks a bend in the grade. "
                 "The first is nearly white. Each one after it is a little dimmer and more amber.",
         "draw": [["circle", -46.0, 4.95, 0.25], ["circle", -62.0, 0.75, 0.25]]},
        {"name": "The bunting's end", "z": [-2.4, -1.4], "style": "mark", "tag": [-42.6, 4.8], "top": True,
         "text": "From the last pole on the dock to the pug's bracket, and one string more inside, from the mouth's cap to the cap by "
                 "the first lantern. There it stops. The town comes 10 m into the mountain and no further.",
         "draw": _bunting_in},
    ],
    "play": [
        {"name": "Whitewash on the roof", "z": [-1.2, 1.2], "style": "pale", "tag": [-42.5, 7.4],
         "text": "The rock roof is limewashed for the first 10 m, fading out. It is paint on dry rock, so it is still pale and matte.",
         "draw": [["poly", [[-36.0, 7.2], [-46.0, 5.75], [-46.0, 6.0], [-36.0, 7.45]]]]},
        {"name": "The sill", "z": [-1.2, 1.2], "style": "pale", "tag": [-37.6, 0.9],
         "text": "Where the dock's deck meets the rock: a timber sill shod with iron, worn hollow in the middle by wheels.",
         "draw": [["rect", -36.3, 1.75, -35.9, 2.2]]},
    ],
    "foreground": [
        {"name": "Three front posts", "z": [1.3, 1.6], "tag": [-46.4, -0.5], "top": True,
         "text": _FRONT_TEXT + " Here: the mouth's own post and two inside, all whitewashed.",
         "draw": _front_posts((0, 4, 8))},
    ],
    "explains": [
        ["The dock's deck (the first 27 m of the ride)", "The ore dock, from the road to the mouth", "Its back half, the hopper where carts were tipped, and the chute"],
        ["The mouth", "The mine's first timber set, in the town's paint", "The pug's board over it, the hill it is cut into, the bunting running into it"],
        ["The tunnel's floor", "The haulage way's rock bed, cut on a grade", "The level planks of the lining, which show the grade"],
        ["The tunnel's roof", "Rock, held up by a timber set every 2.6 m", "The back posts and caps, and the front post of every fourth set"],
        ["The cart, rolling", "An empty, running down by its own weight", "The trough of the mules that hauled the full ones back up"],
    ],
    "pieces": [
        ["Tunnel timber set, whitewashed: back post and cap", "post 0.3 m square, 4.7 m tall; cap 3.2 m", "11", "Background", "kit: tunnel timber set, whitewashed"],
        ["Front post, whitewashed", "0.3 m square, 5 m tall", "3", "Foreground", "kit: tunnel timber set, whitewashed"],
        ["Plank lining panel, limewashed", "one set wide, 1.3 m tall", "10 bays", "Background", "kit: lining panel (mine); the limewash is new paint"],
        ["Painted pug board on an iron bracket", "1.2 m across", "1", "Background", "kit: tunnel mouth (the paint is new)"],
        ["Tunnel lantern", "0.4 m", "2", "Background", "kit: lantern_mine"],
        ["Bunting, torn; bunting pole", "strings of 5 to 10 m; pole 3.2 m", "4 strings, 1 pole", "Background", "kit: papel_tatters; pole in the list below"],
        ["Ore hopper on legs, with its chute", "hopper 2.8 m by 2.4 m; chute 1 m wide, 4 m long", "1", "Background", "kit: ore chute (mine); the hopper is new, this area only"],
        ["Mules' water trough", "1.4 m by 0.4 m", "1", "Background", "new, this area only"],
        ["Dock back post; back rail", "post 0.3 m; rail 1 m high", "1 post, 6 m of rail", "Background", "kit: loading platform back posts and rail"],
        ["Bricked-up passage, whitewashed", "1.8 m by 2.9 m", "1", "Background", "new, this area only"],
        ["The hill's foot", "6.5 m wide, 10 m tall", "1", "Background", "new: one painted card, like the mountain's own"],
        ["Limewash on the roof; the iron-shod sill", "10 m of wash; sill 0.4 m by 0.45 m", "1 of each", "Play space (drawn on)", "new, this area only"],
    ],
    "effects": [
        "A patch of daylight on the bed just inside the mouth, which slides back off the cart as you go in.",
        "The cart's wheels change their sound at the sill: boards, then rock.",
        "The last flags of the bunting flick as the cart goes under them.",
    ],
}

# ------------------------------------------------------------------ 0.3b: the dip, the crest, the banked drop
_rib = [["poly", [[-94.6, _fy(-94.6)], [-91.8, _fy(-91.8)], [-87.2, _ry(-87.2)], [-90.0, _ry(-90.0)]]],
        ["circle", -91.6, -1.4, 0.08, {"style": "dark"}], ["circle", -90.4, 0.3, 0.08, {"style": "dark"}], ["circle", -92.4, -2.2, 0.08, {"style": "dark"}]]

_wall_b = [_wall(-62.5, -105.5)]
for _x in (-97.0, -99.7, -102.3):
    _wall_b.append(["rect", _x - 0.8, _fy(_x) + 1.3, _x + 0.8, _fy(_x) + 2.6, {"style": "dark"}])

_shrine = [["poly", [[-74.5, -3.6], [-72.9, -3.6], [-72.9, -2.0], [-73.7, -1.5], [-74.5, -2.0]], {"style": "pale"}],
           ["poly", [[-74.2, -3.4], [-73.2, -3.4], [-73.2, -2.2], [-73.7, -1.9], [-74.2, -2.2]], {"style": "dark"}],
           ["circle", -73.7, -3.15, 0.12, {"style": "light"}]]

_pump = [["rect", -79.3, _fy(-79.1), -78.9, _fy(-79.1) + 1.4], ["line", -79.1, -3.3, -80.0, -2.7, {"style": "line"}],
         ["line", -79.3, -3.9, -90.0, -1.95, {"style": "line"}], ["line", -90.0, -1.95, -104.0, -6.3, {"style": "line"}],
         ["line", -104.0, -6.3, -105.5, -6.6, {"style": "line"}]]

EL_BADEN = {
    "id": "0.3b", "slug": "0_3b_el_descenso_the_dip", "title": "El Descenso, part two: the dip, the crest and the banked drop", "kind": "challenge",
    "window": [-105.5, -10.5, -62.5, 6.5], "screen": [-86.0, -1.0], "cut_y": -3.0, "climber": [-83.0, -3.82],
    "place": ("The miners drove this tunnel along a soft seam of rock, and the seam wandered. So the track runs down to a low point 42 m "
              "in, climbs 2 m over a rib of hard rock that was not worth cutting through, and then drops down the far side at 17 degrees, "
              "the steepest grade of the ride. Water gathers at the low point, so a hand pump stands there. The rib needs no timber, so "
              "for two sets' length the roof is bare rock. Just past the crest one rail has snapped. This stretch is also where the town "
              "lets go. The whitewash has stopped, and a small shrine in the wall at the bottom of the dip is the last thing in the town's paint."),
    "keep": [
        "The track's line: down at 4 degrees to the low point at x -78, up at 9 degrees to the crest at x -90, then down at 17 degrees to x -104.",
        "The cart's speed and its path. Today the cart never leaves the track.",
        "The lantern lights at x -78, -90 and -104.",
        "The bed grips all the way: dry and pale, even at the low point.",
    ],
    "background": [
        {"name": "The tunnel's back wall", "z": [-2.0, -1.7], "tag": [-68.5, -1.2],
         "text": "Bare plank lining, the limewash gone. On the drop beyond the crest the first planks are missing and wet rock shows in "
                 "the gaps: three dark patches, the first wet you see on the ride.",
         "draw": _wall_b},
        {"name": "The hard rib", "z": [-1.9, -1.7], "style": "pale", "tag": [-90.8, -0.4], "top": True,
         "text": "A slanting band of harder, bluer rock, 3 m wide, crossing the back wall at the crest. It has old drill holes in it and "
                 "no timber on it: two sets are left out here, because this rock holds itself up. It is why the track climbs.",
         "draw": _rib},
        {"name": "The timber sets, bare", "z": [-1.7, -1.3], "style": "pale", "tag": [-85.4, -0.6],
         "text": "Bare wood, dull and dry, greyer than anything you can hold. At the low point the feet of three posts are stained dark "
                 "to knee height. Past the crest the wood starts to go grey.",
         "draw": _back_sets(list(range(11, 21)) + list(range(23, 27)))},
        {"name": "The shrine", "z": [-2.3, -1.7], "tag": [-73.7, -0.9],
         "text": "A small arched niche in the back wall at the bottom of the dip, whitewashed, with candle stubs in it and a scrap of "
                 "papel picado over it. The miners touched it on the way in. From here down, nothing is painted.",
         "draw": _shrine},
        {"name": "The hand pump and its trough", "z": [-1.7, -1.3], "style": "pale", "tag": [-80.6, -2.3],
         "text": "At the low point, against the back wall: an iron hand pump, 1.4 m tall, with its handle up. A wooden trough runs from "
                 "it along the foot of the back wall, up over the crest and on down the tunnel. It is why the dip is not a pond.",
         "draw": _pump},
        {"name": "Three lanterns", "z": [-1.5, -1.3], "style": "light", "tag": [-76.6, -0.3], "top": True,
         "text": "Where the course has its lights: at the low point, at the crest and at the foot of the drop. The one on the crest "
                 "hangs from an iron spike driven into the rib, since there is no cap there.",
         "draw": [["circle", -78.0, -0.45, 0.25], ["circle", -90.0, 1.55, 0.25], ["circle", -104.0, -2.75, 0.25]]},
    ],
    "play": [
        {"name": "The broken rail", "z": [0.2, 0.6], "style": "mark", "tag": [-91.6, -4.2],
         "text": "Just past the crest the near rail has snapped and 2 m of it is gone. The broken end is bent down. The far rail and the "
                 "sleepers are whole. The kit has the piece.",
         "draw": [["line", -90.4, -2.62, -92.6, -3.3], ["line", -92.6, -3.3, -93.2, -3.75, {"style": "line"}]]},
        {"name": "Banked sleepers", "z": [-0.6, 0.6], "style": "pale", "tag": [-99.0, -6.4],
         "text": "On the steep drop the track is laid banked: the far rail 0.2 m higher than the near one, so the tops of the sleepers "
                 "show. It reads as a track built to be run fast. The bed under your feet is unchanged.",
         "draw": [["poly", [[-94.0, _fy(-94.0)], [-104.0, _fy(-104.0)], [-104.0, _fy(-104.0) + 0.22], [-94.0, _fy(-94.0) + 0.22]]]]},
    ],
    "foreground": [
        {"name": "Four front posts", "z": [1.3, 1.6], "tag": [-77.6, -5.4], "top": True,
         "text": _FRONT_TEXT + " Here: four, in bare wood, and none on the rib.",
         "draw": _front_posts((12, 16, 20, 24))},
    ],
    "explains": [
        ["The dip and the climb out of it", "The tunnel following a soft seam down, then up over hard rock", "The hard rib itself, crossing the back wall at the crest"],
        ["The low point", "Where the tunnel's water gathers", "The hand pump, its trough, and the dark stain on the feet of the posts"],
        ["The crest and the broken rail", "The hardest place on the line to lay track, and the first place it failed", "The rib, the bare roof where two sets were left out, the lantern on a spike"],
        ["The banked drop", "The steepest grade, laid banked for speed", "The lining with its first planks gone and wet rock showing"],
        ["The tunnel's roof", "Rock, held by a set every 2.6 m except on the rib", "The back posts and caps, in bare wood"],
    ],
    "pieces": [
        ["Tunnel timber set, bare: back post and cap", "post 0.3 m square, 4.7 m tall; cap 3.2 m", "14", "Background", "kit: tunnel timber set, bare"],
        ["Front post, bare", "0.3 m square, 5 m tall", "4", "Foreground", "kit: tunnel timber set, bare"],
        ["Plank lining panel: whole, planks missing", "one set wide, 1.3 m tall", "13 bays, 3 with planks missing", "Background", "kit: lining panel (mine)"],
        ["The hard rib: a band of blue rock with drill holes", "3 m wide, 5.5 m tall, slanting", "1", "Background", "new, this area only; the drill holes are kit (mine)"],
        ["Shrine niche: whitewashed arch, candle stubs, a scrap of papel picado", "1.6 m by 2.1 m", "1", "Background", "new, this area only"],
        ["Hand pump", "0.4 m by 1.4 m", "1", "Background", "new, this area only"],
        ["Water trough along the wall's foot", "0.2 m square, in 2 m lengths", "26 m", "Background", "new, in the list below"],
        ["Tunnel lantern; one iron spike", "0.4 m", "3 lanterns, 1 spike", "Background", "kit: lantern_mine"],
        ["Broken rail", "4 m piece with 2 m gone", "1", "Play space", "kit: rail_broken"],
        ["Banked sleepers", "10 m of track", "1", "Play space (drawn on)", "kit: rail_straight, laid tilted"],
    ],
    "effects": [
        "The candle in the shrine is the one small warm light between two lanterns.",
        "A clank and a shake of the camera as the cart crosses the broken rail.",
        "The first drips, falling past the dark patches on the drop.",
    ],
    "ask": [
        "The challenge list says the cart jumps a broken rail. In the course today the cart's path has no break in it. Should the cart "
        "get a small hop just past the crest, or is the broken rail only for show?",
    ],
}

# ------------------------------------------------------------------ 0.3c: the lower tunnel and the gap
_GAP = [[-124.0, 0.35, 0], [-124.3, 2.5, 0], [-123.8, 0, -0.5], [-126.5, 0, -0.2], [-129.5, 0, -0.3], [-132.2, 0, -0.6],
        [-131.8, 2.2, 0], [-132.3, 0.5, 0], [-130.0, 0.9, 0], [-127.5, 0.5, 0], [-125.5, 0.8, 0]]
_gap = [["poly", [[x, (_fy(x) + up) if up else (_ry(x) + down)] for x, up, down in _GAP]]]

_cavern = [["rect", -128.9, _fy(-128.5) + 0.75, -128.1, _ry(-128.5) - 0.3, {"style": "pale"}],                   # the fall
           ["poly", [[-129.6, _fy(-129.0) + 0.8], [-127.5, _fy(-128.0) + 0.6], [-128.0, _fy(-128.0) + 1.5], [-129.1, _fy(-129.0) + 1.6]], {"style": "solid"}],   # mist
           ["line", -131.2, -9.4, -129.4, -9.4], ["line", -127.4, -8.0, -125.0, -8.0], ["line", -126.2, -8.0, -126.2, -6.3]]
_cavern += [["circle", x, y, 0.1, {"style": "light"}] for x, y in ((-130.9, -9.1), (-129.8, -9.1), (-127.0, -7.7), (-125.4, -7.7), (-126.2, -6.4))]

_streak = [["poly", [[-112.95, _ry(-112.95)], [-112.45, _ry(-112.45)], [-111.8, _fy(-111.8)], [-113.6, _fy(-113.6)]]]]

_boarded = [["poly", [[-116.2, -9.15], [-116.2, -6.9], [-115.3, -6.2], [-114.4, -6.9], [-114.4, -8.95]]],
            ["line", -116.2, -8.9, -114.4, -7.0, {"style": "line"}], ["line", -116.2, -7.0, -114.4, -8.9, {"style": "line"}]]

_sets_c = _back_sets(list(range(27, 36)) + [37, 38])
_sets_c.append(["rect", -135.45, _fy(-135.3), -135.2, _fy(-135.3) + 4.7])      # the extra prop under the cracked cap

EL_BOQUETE = {
    "id": "0.3c", "slug": "0_3c_el_descenso_the_gap", "title": "El Descenso, part three: the wet tunnel and the gap", "kind": "challenge",
    "window": [-140.5, -15.5, -102.5, -0.5], "screen": [-127.5, -7.8], "cut_y": -9.0, "climber": [-121.5, -10.2],
    "place": ("The lower tunnel runs along the edge of the waterfall cavern, and the cavern's water is getting in. The sets are grey, the "
              "lining has planks missing, and a seep of black mud has come through the back wall. It is the first slick thing in the game, "
              "shown where you can't touch it. Then, for 8 m, the back wall is gone. It fell out into the cavern and took one timber set "
              "with it. Through the hole you get one look at where you are going: the far wall of a very big room, the long white line of "
              "the waterfall, and a few lantern specks on the workings beside it. Then the wall closes again."),
    "keep": [
        "The track's line: down at 11 degrees to x -120, then at 6 degrees to x -136.",
        "The cart's speed and its path.",
        "The lantern lights at x -120 and -136.",
        "The bed grips: it stays dry, pale and matte however wet the wall behind it is.",
    ],
    "background": [
        {"name": "The tunnel's back wall, wet", "z": [-2.0, -1.7], "tag": [-106.2, -6.0],
         "text": "Grey plank lining with planks missing and wet rock behind. The trough along its foot carries the water on down. Drips fall from the caps.",
         "draw": [_wall(-102.5, -140.5),
                  ["line", -102.5, _fy(-102.5) + 0.4, -120.0, _fy(-120.0) + 0.4, {"style": "line"}],
                  ["line", -120.0, _fy(-120.0) + 0.4, -123.8, _fy(-123.8) + 0.4, {"style": "line"}],
                  ["line", -132.4, _fy(-132.4) + 0.4, -136.0, _fy(-136.0) + 0.4, {"style": "line"}],
                  ["line", -136.0, _fy(-136.0) + 0.4, -140.5, _fy(-140.5) + 0.4, {"style": "line"}]]},
        {"name": "The gap", "z": [-2.6, -1.7], "style": "dark", "tag": [-124.9, -6.6], "top": True,
         "text": "8 m of the back wall broken out, with a ragged edge and a low sill of rubble. One whole set went with it, so the roof "
                 "is bare there. The back posts of two other sets still stand in the opening, dark against the view. At the cart's speed "
                 "the gap is on screen for about 3 seconds.",
         "draw": _gap},
        {"name": "The waterfall cavern", "z": [-40.0, -14.0], "style": "line", "tag": [-130.3, -7.6], "top": True,
         "text": "Seen through the gap, 14 m back and more: the cold grey-violet far wall, the waterfall as one pale line from above the "
                 "frame to below it, mist at its foot, and five lantern specks on the workings beside it. It is a far cut-out, like the "
                 "Peak at the station. It is the only cool light on the ride.",
         "draw": _cavern},
        {"name": "The black streak", "z": [-1.75, -1.7], "style": "dark", "tag": [-112.7, -7.0], "top": True,
         "text": "A seep of glossy black mud down the back wall between two sets, 2 m wide at the floor, with pale drips on it. The "
                 "lanterns either side light it. It is on the back wall only, never on the bed.",
         "draw": _streak},
        {"name": "A boarded side tunnel", "z": [-2.8, -1.7], "style": "dark", "tag": [-115.3, -5.6],
         "text": "The mine's way of closing a passage: two planks nailed across a dark opening. The mine's kit has it.",
         "draw": _boarded},
        {"name": "The timber sets, grey", "z": [-1.7, -1.3], "style": "pale", "tag": [-134.8, -8.2],
         "text": "Grey and wet, some leaning a little. One cap just below the gap is cracked and held up by an extra prop. From here on these are the mine's sets.",
         "draw": _sets_c},
        {"name": "Two lanterns", "z": [-1.5, -1.3], "style": "light", "tag": [-118.6, -5.2], "top": True,
         "text": "Amber now, and dim. The gap sits half way between them, so their light does not fight the view. The second is the "
                 "tunnel's seventh and last.",
         "draw": [["circle", -120.0, -5.85, 0.25], ["circle", -136.0, -7.45, 0.25]]},
    ],
    "play": [
        {"name": "The dry bed", "z": [-1.2, 1.2], "style": "mark", "tag": [-126.0, -12.2],
         "text": "With all this wet behind it, the bed and the rails are drawn dry: pale rock, rust-orange rails, dry sleepers. "
                 "Nothing dark or glossy is put on the floor here, because the floor grips.",
         "draw": [["line", -104.0, _fy(-104.0) + 0.12, -120.0, _fy(-120.0) + 0.12], ["line", -120.0, _fy(-120.0) + 0.12, -136.0, _fy(-136.0) + 0.12],
                  ["line", -136.0, _fy(-136.0) + 0.12, -140.5, _fy(-140.5) + 0.12]]},
    ],
    "foreground": [
        {"name": "Two front posts and a stump", "z": [1.3, 1.6], "tag": [-119.2, -11.0], "top": True,
         "text": _FRONT_TEXT + " Here: two, in grey wood, and the one that would stand in front of the gap is a 0.5 m stump. It went "
                 "when the wall did. So from x -119 to x -140 nothing stands in front of you: the longest clear stretch of the ride, placed where the look is.",
         "draw": _front_posts((28, 32)) + [["rect", -129.75, _fy(-129.6), -129.45, _fy(-129.6) + 0.5]]},
    ],
    "explains": [
        ["The lower tunnel's floor and roof", "The same haulage way, now beside the cavern, with water getting in", "Grey sets, lining with planks gone, the trough at the wall's foot"],
        ["The black streak (seen, not touched)", "Mud seeping through the back wall", "It is the back wall: the lesson about dark and wet is given where it costs nothing"],
        ["The look through the gap", "The back wall fell out into the cavern here", "The far wall, the fall, and the lanterns of the climb you are about to make"],
        ["The clear stretch at the gap", "One whole timber set went with the wall", "A bare roof, one back post left standing, and a stump where the front post was"],
    ],
    "pieces": [
        ["Tunnel timber set, grey and wet: back post and cap", "post 0.3 m square, 4.7 m tall; cap 3.2 m", "11, one with a cracked cap and a prop", "Background", "kit: tunnel timber set, grey and wet"],
        ["Front post, grey; stump", "0.3 m square, 5 m tall; stump 0.5 m", "2 posts, 1 stump", "Foreground", "kit: tunnel timber set, grey and wet"],
        ["Plank lining panel: planks missing, smashed", "one set wide, 1.3 m tall", "11 bays", "Background", "kit: lining panel (mine)"],
        ["The gap's ragged edge and rubble sill", "8 m wide, 4.5 m tall", "1", "Background", "kit: the gap; rubble heap (mine)"],
        ["The waterfall cavern as a far cut-out: far wall, fall, mist, five lantern specks", "9 m wide, 6 m tall", "1", "Background, far", "new, this area only; the fall is the water overhaul's"],
        ["Black mud streak with drips", "0.5 m wide at the roof, 2 m at the floor", "1", "Background", "new, this area only"],
        ["Boarded side tunnel", "1.8 m by 2.9 m", "1", "Background", "kit: boarded side tunnel (mine)"],
        ["Water trough along the wall's foot", "0.2 m square, in 2 m lengths", "30 m, broken by the gap", "Background", "new, in the list below"],
        ["Tunnel lantern", "0.4 m", "2", "Background", "kit: lantern_mine"],
    ],
    "effects": [
        "Cold blue-white light falls across the bed and the cart for the length of the gap, and the sound of the fall comes in with it.",
        "A breath of mist drifts in through the gap.",
        "Drips from the caps, and a slow shine moving on the black streak.",
    ],
}

# ------------------------------------------------------------------ the join: the end of the line
_GALLERY = [["poly", [[-164.5, -14.13], [-162.0, -17.2], [-160.0, -17.2], [-155.5, -12.9], [-152.0, -12.9], [-152.0, -7.5], [-164.5, -7.5]]]]

_sets_j = _back_sets(range(39, 44))
_sets_j.append(["rect", -143.25, _fy(-143.1), -143.0, _fy(-143.1) + 4.7])       # the prop under the cracked cap

_pegs = [["rect", -147.4, -10.3, -145.6, -10.15], ["poly", [[-146.95, -10.3], [-146.45, -10.3], [-146.55, -10.75], [-146.85, -10.75]]],
         ["circle", -145.9, -10.5, 0.14, {"style": "line"}]]

FIN_DE_LA_VIA = {
    "id": "0 to 1", "slug": "0_to_1_the_end_of_the_line", "title": "The station to the mine: the end of the line", "kind": "join",
    "also": ["a1"],
    "window": [-164.5, -19.0, -136.5, -4.0], "screen": [-150.5, -9.6], "cut_y": -11.8, "climber": [-144.0, -11.83],
    "place": ("The end of the line. The tunnel levels out for its last 16 m and stops at a buffer, 2 m short of the door into the mine. "
              "By here everything the town sent in has dropped away. The bunting stopped 10 m in, the whitewash at 26 m, the shrine in "
              "the dip was the last paint, and the daylight is long gone. What is left is the mine's: grey wet timber, smashed lining, "
              "amber light. The door is one timber set that belongs to both places. The first thing beyond it is honey-coloured timber you "
              "can hold, the first since the dock, and under that timber is the first black mud you can touch."),
    "keep": [
        "The buffer where it is, at x -150.3, and its size: 0.6 m by 0.8 m.",
        "Where the cart stops: with its front end 0.4 m short of the buffer.",
        "The door at x -152, and the gallery beyond it exactly as the mine's own page has it.",
        "The mine's first lantern at x -154.",
    ],
    "background": [
        {"name": "The tunnel's back wall, the last 16 m", "z": [-2.0, -1.7], "tag": [-139.0, -9.0],
         "text": "The lining is smashed here and the rock behind it is wet. This is the same back wall the mine's galleries have.",
         "draw": [_wall(-136.5, -152.0)]},
        {"name": "The mine's first gallery", "z": [-2.8, -1.7], "tag": [-158.5, -9.3],
         "text": "Drawn here only so the two back walls meet at the door. What is in the gallery is on the mine's own page, 1.1 La Galería: "
                 "the mud pit, the posts over it, the cart the mud took.",
         "draw": _GALLERY},
        {"name": "The last five sets", "z": [-1.7, -1.3], "style": "pale", "tag": [-145.2, -8.3],
         "text": "Grey, wet and rotten, 2.6 m apart. One cap is cracked and held by a prop. After the fifth comes one wide bay, 4.2 m, with the buffer in it.",
         "draw": _sets_j},
        {"name": "The door set", "z": [-1.7, -1.3], "style": "pale", "tag": [-152.0, -6.6], "top": True,
         "text": "The timber set at the door, which the course already has. It is the tunnel's last set and the mine's first: the same "
                 "posts and cap, no whitewash, nothing painted.",
         "draw": [["rect", -152.15, -12.6, -151.85, -7.8], ["rect", -152.22, -7.8, -151.78, -7.5]]},
        {"name": "The buffer's braces", "z": [-1.7, -1.3], "style": "line", "tag": [-151.1, -10.6], "top": True,
         "text": "The buffer is a timber baulk laid right across the track. Its far end is held by two braces that rake back to the "
                 "floor against the back wall. What you see in the play space is the near end of it.",
         "draw": [["line", -150.5, -11.25, -151.6, -12.0], ["line", -150.5, -11.6, -151.2, -12.0]]},
        {"name": "The miners' pegs", "z": [-1.75, -1.6], "style": "pale", "tag": [-146.5, -9.6], "top": True,
         "text": "A board of six pegs on the back wall, where the men hung their lamps and coats when they got out of the carts. Five "
                 "pegs are empty. One still has a hat on it, and a dead lamp.",
         "draw": _pegs},
        {"name": "The trough's end", "z": [-1.7, -1.4], "style": "mark", "tag": [-153.6, -13.6], "top": True,
         "text": "The trough along the wall's foot ends at the door, and its water runs over the sill and on towards the gallery's "
                 "mud pit. The tunnel's water is what made the mine's first mud.",
         "draw": [["line", -136.5, _fy(-136.5) + 0.3, -152.0, -11.7], ["line", -152.0, -11.7, -152.3, -12.5], ["line", -152.3, -12.5, -155.5, -12.75]]},
        {"name": "The mine's first lantern", "z": [-1.5, -1.3], "style": "light", "tag": [-153.1, -8.9], "top": True,
         "text": "Where the course has it, just inside the door. The tunnel's last lantern, 18 m back up the track, is the same amber "
                 "and just as dim, so the light does not change at the door.",
         "draw": [["circle", -154.0, -8.0, 0.2]]},
    ],
    "play": [
        {"name": "The buffer's iron face", "z": [-0.6, 0.6], "style": "pale", "tag": [-149.3, -10.7],
         "text": "The iron block becomes the near end of the timber baulk, faced with an iron plate that is dented where carts have hit it. It keeps its size.",
         "draw": [["rect", -150.08, -11.9, -149.94, -11.3]]},
        {"name": "The sill at the door", "z": [-1.2, 1.2], "style": "pale", "tag": [-153.0, -11.5],
         "text": "The tunnel's floor is 0.6 m higher than the gallery's, and today it ends in a bare step. The step gets a worn "
                 "timber sill along its edge, so it reads as the end of a loading floor.",
         "draw": [["rect", -152.12, -12.22, -151.8, -12.0]]},
    ],
    "foreground": [
        {"name": "The last front post, and the door's broken one", "z": [1.3, 1.6], "tag": [-140.0, -13.1], "top": True,
         "text": "One whole front post, at x -140. The door set's front post is broken in the middle: a length hanging from the cap "
                 "and a stump on the floor. The gap between them is where the cart throws you, so nothing covers you as you land.",
         "draw": _front_posts((40,)) + [["rect", -152.15, -9.0, -151.85, -7.5], ["rect", -152.15, -12.6, -151.85, -12.2]]},
    ],
    "explains": [
        ["The last 16 m of track", "The foot of the haulage way, nearly level", "The last five sets, the smashed lining, the trough"],
        ["The buffer", "The near end of a baulk laid across the track", "Its braces against the back wall, and the pegs where everyone got out"],
        ["The step down at the door", "The edge of the tunnel's floor, with a sill", "The door set, shared with the mine, and the trough's water running over the sill"],
        ["The gallery beyond", "The mine", "See 1.1 La Galería"],
    ],
    "pieces": [
        ["Tunnel timber set, grey and wet: back post and cap", "post 0.3 m square, 4.7 m tall; cap 3.2 m", "5, one with a cracked cap and a prop", "Background", "kit: tunnel timber set, grey and wet"],
        ["Front post, grey", "0.3 m square, 5 m tall", "1", "Foreground", "kit: tunnel timber set, grey and wet"],
        ["The door's timber set, its front post broken in two", "0.6 m by 5 m by 2.6 m", "1", "Background, foreground", "kit: mine_frame, front post cut"],
        ["Plank lining panel, smashed", "one set wide, 1.3 m tall", "6 bays", "Background", "kit: lining panel (mine)"],
        ["Buffer stop: baulk, iron face plate, two braces", "baulk 0.6 m by 0.8 m, 3.2 m long", "1", "Play space, background", "kit: buffer stop"],
        ["Peg board with a hat and a dead lamp", "1.8 m long", "1", "Background", "new, this area only; the lamp is lantern_mine"],
        ["Water trough along the wall's foot", "0.2 m square, in 2 m lengths", "16 m", "Background", "new, in the list below"],
        ["Timber sill for the step", "0.3 m by 0.2 m", "1", "Play space (drawn on)", "new, this area only"],
        ["Hanging lantern", "0.4 m", "1", "Background", "kit: lantern_hang"],
    ],
    "effects": [
        "The bang of the cart on the buffer, and dust shaken down from the cracked cap.",
        "Water running over the sill at the door: a thin bright thread on the back wall, not on the floor.",
        "The first sound of the mine through the door: the waterfall, far off and low.",
    ],
    "ask": [
        "The tunnel's floor is 0.6 m higher than the gallery's at the door. Keep the step, dressed with a sill? Or should the two floors be made level, which is a change to the course?",
    ],
}

AREAS = [LA_ESTACION, LA_BOCA, EL_BADEN, EL_BOQUETE, FIN_DE_LA_VIA]

# New pieces that more than one of these areas uses. Same five columns as the sheet's kit.
KIT_MORE = [
    ["Bunting pole", "0.2 m thick, 3.2 m tall", "on the dock's back rail, one every 8 m, from the station to the mouth", "Background", "new"],
    ["Water trough along the wall's foot", "0.2 m square, in 2 m lengths", "the tunnel's back wall, from the pump in the dip to the door", "Background", "new"],
]
