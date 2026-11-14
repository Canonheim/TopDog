# The glacier's areas, one dict each. Format: see ../build.py. Drawn from a9_biome.py.
# The lower crack (9.1, 9.2, 9.3) is redone at Parker's word (note 86): each of those three says what moves, in metres.
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


_K = math.tan(math.radians(10.0))


def _bands(x0, y0, x1, y1, step=3.2, first=1.4):
    """The ice's layers across a back wall: lines tilted ten degrees down to the east."""
    out, ya = [], y0 + first
    while ya < y1 + _K * (x1 - x0):
        xa, xb = max(x0, x0 + (ya - y1) / _K), min(x1, x0 + (ya - y0) / _K)
        if xb - xa > 1.0:
            out.append(_ln(round(xa, 2), round(ya - _K * (xa - x0), 2), round(xb, 2), round(ya - _K * (xb - x0), 2), "mark"))
        ya += step
    return out


def _wall(x0, y0, x1, y1, step=3.2, first=1.4):
    return [_r(x0, y0, x1, y1)] + _bands(x0, y0, x1, y1, step, first)


def _deep(x, y, rot):
    """One of the ones who tried, deep in the ice: a small flat figure, any way up."""
    a = math.radians(rot)
    ux, uy = -math.sin(a), math.cos(a)
    return [_c(round(x + ux * 0.75, 2), round(y + uy * 0.75, 2), 0.2, "line"),
            _ln(round(x - ux * 0.9, 2), round(y - uy * 0.9, 2), round(x + ux * 0.55, 2), round(y + uy * 0.55, 2), "line"),
            _ln(round(x + ux * 0.3 - uy * 0.45, 2), round(y + uy * 0.3 + ux * 0.45, 2),
                round(x + ux * 0.3 + uy * 0.45, 2), round(y + uy * 0.3 - ux * 0.45, 2), "line")]


def _cane(x, y, d=1, h=3.0, sky=False):
    """A route cane with its paper flag. d is the way the flag streams: 1 east, -1 west. sky: it stands against the pale sky."""
    flag = [(x, y + h), (x + d * 0.9, y + h - 0.22), (x, y + h - 0.45)]
    if sky:
        return [_r(round(x - 0.04, 2), y, round(x + 0.04, 2), round(y + h, 2), "dark"), _p(flag, "solid")]
    return [_ln(x, y, x, round(y + h, 2), "line"), _p(flag, "pale")]


def _wavy(x0, x1, y, amp=0.16, wl=1.6):
    n = max(2, int(abs(x1 - x0) / (wl / 2)))
    pts = [(x0 + (x1 - x0) * i / n, y + amp * (1 if i % 2 else -1)) for i in range(n + 1)]
    return [_ln(round(a[0], 2), round(a[1], 2), round(b[0], 2), round(b[1], 2), "mark") for a, b in zip(pts, pts[1:])]


def _back(x, y):
    """The slab of dull ice at the back of a frozen climber you can hold. (x, y) is his belt."""
    return _r(round(x - 0.85, 2), round(y - 1.35, 2), round(x + 0.85, 2), round(y + 1.65, 2), "pale")


def _tusk(x, y_top, y_tip):
    return _p([(x - 0.3, y_top), (x + 0.3, y_top), (x, y_tip)], "mark")


# ------------------------------------------------------------------ the lower crack, shared by 9.1, 9.2 and 9.3
# The fifteen holds of Hielo Azul, from the course. Numbers 2, 6 and 11 are the three stones.
_H91 = [(-308.16, 787.51), (-309.20, 788.83), (-310.87, 789.00), (-311.90, 790.32), (-313.58, 790.48), (-314.61, 791.81),
        (-316.28, 791.97), (-317.32, 793.29), (-318.99, 793.45), (-320.03, 794.78), (-321.70, 794.94), (-322.74, 796.26),
        (-324.41, 796.43), (-325.45, 797.75), (-327.12, 797.91)]
_NUBS = [_H91[2], _H91[6], _H91[11]]
_SEAM = [_p([(-307.18, 787.64), (-327.48, 798.77), (-327.72, 798.33), (-307.42, 787.20)], "pale"),
         _p([(-327.75, 798.5), (-327.25, 798.5), (-327.05, 802.6), (-327.55, 802.6)], "pale")]


def _dirt_layers(x_lo, x_hi):
    """The three layers of stones that the three stone holds ride in, as they show on the far wall."""
    out = []
    for nx, ny in _NUBS:
        out.append(_ln(x_lo, round(ny - _K * (x_lo - nx), 2), x_hi, round(ny - _K * (x_hi - nx), 2), "mark"))
        for dx in (-19.0, -15.0, -11.0, -7.5, -4.5, 4.5, 8.0, 12.0, 16.0):
            x = nx + dx
            if x_lo + 0.6 < x < x_hi - 0.6:
                out.append(_c(round(x, 2), round(ny - _K * dx, 2), 0.2, "pale"))
    return out


_DOOR = [_p([(-305.5, 804.0), (-305.5, 809.5), (-310.4, 809.5), (-312.8, 806.6), (-310.0, 804.0)], "pale"),
         _r(-305.5, 804.0, -303.0, 808.5, "pale")]
_LIT_GAP = [_p([(-319.0, 802.6), (-317.8, 802.6), (-317.3, 809.5), (-319.5, 809.5)], "pale")]
_SIGN = [_ln(-330.3, 798.5, -330.3, 799.9, "line"), _p([(-330.8, 799.9), (-329.9, 799.9), (-329.4, 800.25), (-329.9, 800.6), (-330.8, 800.6)], "pale")]
_BLOCKS = [_p([(-317.7, 786.0), (-317.3, 787.5), (-315.4, 787.9), (-314.6, 786.0)], "line"),
           _p([(-314.2, 786.0), (-313.9, 786.9), (-312.6, 786.7), (-312.4, 786.0)], "line")]
_FELL = _deep(-312.5, 798.6, 160.0)

# The snow bridges as they are redone: nine pieces 1.1 m long, two wedged stones, a 1.2 m gap at the shelf's end.
_BR_X = [-317.8, -316.7, -315.6, -313.3, -312.2, -311.1, -308.8, -307.7, -306.6]
_STONE1 = [(-315.25, 804.0), (-315.1, 803.2), (-314.5, 802.9), (-314.05, 803.3), (-314.05, 804.0)]
_STONE2 = [(-310.3, 804.0), (-310.3, 803.3), (-309.8, 802.8), (-309.2, 803.1), (-309.1, 804.0)]
_NEW_BRIDGES = ([_r(-318.99, 803.5, -305.5, 804.04, "dark"), _r(-315.3, 802.85, -314.0, 803.5, "dark"), _r(-310.35, 802.75, -309.05, 803.5, "dark")] +
                [_r(round(a + 0.02, 2), 803.55, round(a + 1.08, 2), 804.0, "solid") for a in _BR_X] +
                [_p([(x + 0.75, y) for x, y in _STONE1], "pale"), _p([(x + 0.3, y) for x, y in _STONE2], "pale")])
_BRIDGE_TEXT = ("The three bridges and the two wedged stones as they are redone, in yellow, drawn over a black strip that blanks out where they "
                "are today. Nine pieces, each 1.1 m long, and 1.2 m of open air between the shelf's broken end and the first piece. The page "
                "for Puente de Nieve says what moves.")

_ICI = [-326.9, -325.5, -324.1, -321.3, -320.0]          # the five that hold
_DRIP = [-326.2, -324.8, -322.0, -320.65]                # the four that fall, under the shelf

# ------------------------------------------------------------------ 8 to 9: under the lip
_FRINGE = []
for _i, _x in enumerate([-283.6 + 0.8 * k for k in range(15)]):
    _FRINGE.append(_p([(_x - 0.22, 790.85), (_x + 0.22, 790.85), (_x, 790.85 - (0.6, 1.1, 0.8, 1.2, 0.7)[_i % 5])], "pale"))

UNDER_THE_LIP = {
    "id": "8 to 9", "slug": "8_to_9_under_the_lip", "title": "Under the lip: from the cableway to the glacier", "kind": "join", "also": ["a8"],
    "window": [-309.0, 779.5, -265.0, 801.5], "screen": [-288.0, 790.0], "cut_y": 788.4, "climber": [-288.6, 786.0],
    "place": ("The cableway's last deck stands against the face at 786 m, and the glacier has come down on top of it. The ice's lip hangs "
              "over the west half of the deck, 4.8 m above the planks, with a fringe of icicles under it, and the ice lies on the station "
              "house's roof. Whatever comes off the glacier's skin slides down the top of the lip and is thrown off its tip, over your head "
              "and clear of the deck. So nobody goes up the outside from here. Under the lip there is an alcove, and from the back of the "
              "alcove a tunnel runs west along the glacier's bed. It is the way the melt water left in warmer years. It is dry now, 21 m "
              "long and 4.8 m high, with a floor of firm snow. The ones who came to climb marked it with a cane and a paper flag and hung a "
              "lantern inside its mouth. You walk out of gold light into blue shadow, and at the far end the tunnel opens into the lower crack."),
    "keep": [
        "The deck, as the cableway's file has it: its ice, its three dry patches, its length.",
        "The lip over the deck: 4.8 m of head room, its two ramps on top, and the tip that throws a falling body clear of the deck.",
        "The tunnel: 21 m long, 4.8 m high, firm snow all the way, nothing to climb and nothing that falls.",
    ],
    "background": [
        {"name": "The valley and the sky", "z": [-8.0, -7.8], "style": "pale", "tag": [-266.2, 797.6],
         "text": "East of the lip's tip the picture is the one that is given: the painted valley far below with the tiny town, the two painted "
                 "ranges, the cloud banks above. Nothing of this biome stands in it here. It is the last you see of it until the window at 830 m.",
         "draw": [_r(-271.4, 779.5, -265.0, 801.5)]},
        {"name": "The station house, with the ice on it", "z": [-4.0, -2.5], "style": "line", "tag": [-269.6, 787.4], "top": True,
         "text": "The cableway's piece, 2.5 m back, as that biome's sheet has it. It is drawn here for the one thing this biome adds: the "
                 "glacier lies on its roof, has pushed in its west end, and fills its west window with blue ice.",
         "draw": [_r(-279.0, 786.0, -268.0, 791.6), _ln(-279.0, 788.7, -268.0, 788.7), _r(-275.6, 786.0, -274.2, 788.4), _r(-272.4, 789.2, -271.2, 790.5)]},
        {"name": "The alcove's back wall", "z": [-3.0, -2.4], "tag": [-282.0, 788.4], "top": True,
         "text": "Where the house ends, the ice begins: the glacier's own body, mid blue and dull, in bands that tilt down to the east. "
                 "It comes down over the house's west end like a poured thing that set. This is the first of the back wall that runs "
                 "behind every room from here to the window.",
         "draw": [_p([(-284.5, 786.0), (-279.0, 786.0), (-278.2, 788.2), (-279.2, 790.9), (-284.5, 790.9)])] + _bands(-284.5, 786.0, -279.2, 790.9, 2.0, 1.2)},
        {"name": "The icicle fringe", "z": [-1.8, -1.3], "style": "pale", "tag": [-277.6, 789.2],
         "text": "A row of small icicles under the lip, 12 m long, hanging thickest over the deck's two western patches of ice: the ice on "
                 "the planks is what dripped from them. None of them falls and none can be reached. Today the row hangs inside the play "
                 "space. It moves 1.3 m back.",
         "draw": _FRINGE},
        {"name": "The tunnel's back wall", "z": [-3.0, -2.4], "tag": [-296.0, 789.7], "top": True,
         "text": "Banded ice, scooped by the old water into shallow dishes a metre across, with stones standing out of the bands. "
                 "It never stops inside the frame. It is the same mid blue from end to end, so the tunnel is the darkest part of the walk in.",
         "draw": _wall(-305.5, 786.0, -284.5, 790.8, 2.0, 1.0) + [_c(-301.2, 788.2, 0.22, "pale"), _c(-297.6, 789.4, 0.3, "pale"), _c(-293.1, 787.6, 0.2, "pale"),
                                                                   _c(-289.4, 788.9, 0.26, "pale")]},
        {"name": "The first cane and its flag", "z": [-1.7, -1.4], "tag": [-284.2, 787.3],
         "text": "A bamboo cane 3 m tall, stuck in the snow at the back of the alcove, with a paper flag in the town's colours. It is the "
                 "first of the canes that mark the route. In here, out of the wind, its flag hangs almost slack and leans toward the tunnel.",
         "draw": _cane(-283.4, 786.0, -1)},
        {"name": "A lantern inside the tunnel's mouth", "z": [-1.6, -1.4], "style": "light", "tag": [-287.2, 789.7],
         "text": "A candle lantern on a hook cut from an axe shaft, 1.5 m inside the mouth and above head height. Every lamp on the "
                 "cableway is cold. This is the first one alight since the frog's car, and it hangs on the side you go through.",
         "draw": [_c(-286.1, 789.7, 0.2)]},
        {"name": "The last pennant line", "z": [-2.2, -2.0], "style": "mark", "tag": [-267.6, 791.7],
         "text": "The cableway's last line of pennants comes in from the east, 5 m above the deck, and its end is frozen into the lip's "
                 "tip. Its last four pennants are stiff with ice and do not move. It is the town's paper handing over to the canes.",
         "draw": [_ln(-265.0, 790.2, -271.3, 791.6)]},
        {"name": "The lower crack, ahead", "z": [-3.0, -2.4], "style": "pale", "tag": [-307.4, 794.0],
         "text": "At the tunnel's west end the roof goes up out of sight and the wall is paler: the lower crack. From inside the tunnel "
                 "it is a tall pale slot at the end of a dark passage.",
         "draw": [_r(-309.0, 786.0, -305.5, 801.5)]},
    ],
    "play": [
        {"name": "Boot prints", "z": [-0.4, 0.4], "style": "mark", "tag": [-300.0, 787.0],
         "text": "The tunnel's snow floor has a line of old boot prints going west, a blue hollow every few metres, and low ridges where "
                 "the draught has combed it. All of it is drawn on the snow and changes nothing you stand on.",
         "draw": [_ln(-283.0, 786.1, -305.2, 786.1)]},
        {"name": "Where the planks end", "z": [-1.2, 1.2], "style": "line", "tag": [-281.2, 787.4],
         "text": "The deck's west end and the glacier's snow meet at one line. East of it: steel, cream paint, planks, the deck's ice. "
                 "West of it nothing is built. The plank ends are drawn broken off under the snow's edge.",
         "draw": [_ln(-282.0, 785.5, -282.0, 786.9)]},
    ],
    "foreground": [
        {"name": "The snow fringe on the lip", "z": [1.2, 1.5], "tag": [-277.4, 796.6],
         "text": "A strip of snow along the top edge of the lip, in front of the lip's own ice. Today's strip sits just outside the ice, "
                 "over the ramp that a sliding body comes down. It moves 0.5 m in, so it covers ice and nothing else.",
         "draw": [_p([(-280.5, 799.9), (-276.5, 794.7), (-271.6, 791.35), (-271.9, 791.05), (-276.9, 794.4), (-280.9, 799.4)])]},
    ],
    "explains": [
        ["The deck (the cableway's)", "The last made floor on the mountain", "The station house, with the glacier lying on its roof"],
        ["The ice on the deck", "Melt water off the lip, frozen on the planks", "The icicle fringe straight above it"],
        ["The tunnel's snow floor", "The bed of the glacier's old melt-water tunnel", "Its scooped and banded back wall, the cane at its mouth, the lantern inside"],
        ["The lip over your head (it cannot be held)", "The end of the slide: the last ramp of the glacier's skin", "The snow fringe along its edge, and the frozen pennant line in its tip"],
    ],
    "pieces": [
        ["Station house, half under the ice", "14 m wide, 6 m tall", "1", "Background", "the cableway's kit: station house; the ice on its roof and in its window is new, this join only"],
        ["Back wall bay", "4 m wide, 5 m tall", "7", "Background", "kit: back wall bay; the scooped dishes are a second painting of it"],
        ["Icicle fringe", "12 m by 1.2 m", "1", "Background", "kit: icicle fringe (icicle_row)"],
        ["Route cane with a paper flag", "3 m", "1", "Background", "kit: route cane (streamer_pole)"],
        ["Candle lantern on a hook", "0.5 m", "1", "Background", "kit: candle lantern (lantern_hang)"],
        ["Pennant line, frozen stiff", "6 m", "1", "Background", "the cableway's kit: pennant_line, with ice on it"],
        ["Paler wall bay", "4 m wide, 5 m tall", "1", "Background", "kit: paler wall bay (added below)"],
        ["Firm snow cap, with boot prints", "21 m long, 0.7 m thick", "1", "Play space", "kit: firm snow cap"],
        ["Snow fringe for the lip", "11 m long, 0.5 m wide", "1", "Foreground", "there today, moved 0.5 m in"],
    ],
    "effects": [
        "Gold light on the deck's east end, blue shadow from the lip's edge west. The line between them lies across the planks.",
        "One slow drip from the fringe onto each patch of ice on the deck.",
        "The lantern's amber on the snow just inside the tunnel, and nowhere else.",
        "A long way off and overhead, now and then: the rumble of something coming down the slide and going over the tip.",
    ],
    "notes": [
        "Note 84: the deck's ice is the first ice on the climb. It lets go after 2 seconds, and the tell is the same one: the button mark on the holding limb shivers.",
        "In the play space today, and moved out of it: the icicle row under the lip (1.3 m back, item 4). The snow strip on the lip moves 0.5 m in, to sit in front of ice only (item 12).",
        "The deck, the station house and its lamp belong to the cableway's pages. This page draws them only so the two agree.",
        "Nothing you touch moves.",
    ],
}

# ------------------------------------------------------------------ 9.1 Hielo Azul
HIELO_AZUL = {
    "id": "9.1", "slug": "9_1_hielo_azul", "title": "Hielo Azul", "kind": "challenge",
    "window": [-333.5, 783.5, -302.0, 811.8], "cut_y": 794.9, "climber": [-306.6, 786.0],
    "place": ("The lower crack is one tall slot in the ice: 25.5 m wide and 23.5 m high, under a dark roof. You come into it at the foot "
              "of its east side, and the way out is a lit door at the top of the same side, 18 m straight above you. The slot is climbed "
              "as one zigzag: west up the far wall, then back east along the top. This page is the first leg. A seam of old blue ice "
              "crosses the wall from the floor by the tunnel to a snow ledge in the west corner, 19.5 m along and 10.7 m up. It is a crack "
              "that healed, and it is harder than the ice round it, so it stands proud of the wall in knuckles. The glacier's own layers "
              "cross it on a gentler slant, and three of those layers carry stones. Where a layer of stones meets the seam there is a "
              "grey stone to hold. Ice lets go of you after two seconds. A stone never does."),
    "keep": [
        "All fifteen holds exactly where they are: twelve knuckles of blue ice and three stones, in runs of two, three, four and three.",
        "Blue ice holds for 2 seconds and then that hand cannot grip for a moment. The stones hold for good.",
        "The corner ledge at 798.5 m, the snow floor, and the fall: a miss lands on the floor, at the foot of this climb.",
        "The four places where icicles fall onto the top third of the line, and their timing.",
    ],
    "background": [
        {"name": "The crack's far wall", "z": [-3.0, -2.4], "tag": [-313.5, 807.2], "top": True,
         "text": "Mid blue and dull, 2.4 m behind you, in bands that tilt ten degrees down to the east. It fills the frame from the floor "
                 "to the roof. Its closed corners are the deepest blue: the top west corner over the shelf, and the foot of the west wall.",
         "draw": _wall(-331.0, 786.0, -305.5, 809.5)},
        {"name": "The blue seam", "z": [-2.5, -2.4], "tag": [-312.3, 788.7],
         "text": "A band of pale old ice half a metre wide, flush in the far wall, on the same line as the holds. Each knuckle is the "
                 "near end of a tooth of this seam, and the seam is what you read the route from. At the corner it turns and climbs "
                 "straight up to the underside of the shelf. Today a pale card 3 m wide lies here and looks like a ramp. It goes (note 84).",
         "draw": _SEAM},
        {"name": "Three layers of stones", "z": [-2.5, -2.4], "tag": [-319.8, 791.3],
         "text": "Grey-brown stones riding in three of the wall's bands. Each line of stones runs through one of the three stones you "
                 "hold. So before you start you can see where the seam will let you stop: where a line of stones crosses it.",
         "draw": _dirt_layers(-331.0, -305.5)},
        {"name": "The door, lit", "z": [-3.0, -2.4], "tag": [-308.4, 807.2], "top": True,
         "text": "The palest thing in the slot, high on the east side: the door of the ice cave, with frost round its edge and the wall "
                 "round it two steps paler than anywhere else. You see it from the floor the moment you step out of the tunnel. A "
                 "lantern burns just inside it.",
         "draw": _DOOR + [_c(-303.6, 807.7, 0.2, "light")]},
        {"name": "The light down the gap", "z": [-3.0, -2.4], "tag": [-318.4, 807.4],
         "text": "A paler stripe on the far wall, straight above the shelf's broken end. It is the same light as the door's, coming along "
                 "the top of the slot and down past the end of the shelf. It marks the one place where you can get up past the shelf.",
         "draw": _LIT_GAP},
        {"name": "The shelf's other half", "z": [-2.3, -1.3], "tag": [-315.4, 788.6], "top": True,
         "text": "Two blocks of ice on the floor, under the shelf's broken end and behind where you walk. The bigger is 3 m long. They are "
                 "the piece of the shelf that broke off, and they are why the shelf reads as a thing with an end.",
         "draw": _BLOCKS},
        {"name": "Two blue ribs", "z": [-2.4, -2.0], "style": "pale", "tag": [-329.6, 791.0],
         "text": "Leaning slabs of bluer ice in the far wall. Today two stand right behind the line of holds and look like part of it. "
                 "They move: one to the foot of the west wall under the corner ledge, one to the east wall under the door.",
         "draw": [_p([(-330.6, 786.0), (-329.2, 786.0), (-328.7, 797.6), (-330.1, 797.6)]),
                  _p([(-308.2, 793.2), (-306.9, 793.2), (-306.3, 802.4), (-307.6, 802.4)])]},
        {"name": "One who fell", "z": [-2.6, -2.4], "tag": [-313.8, 799.4],
         "text": "One of the ones who tried, deep in the far wall, head down, a flat blue shape with no warm colour on him. He is under "
                 "the middle snow bridge, 5 m from any hold. Today he stands 1.5 m from the line of holds.",
         "draw": _FELL},
        {"name": "The pug arrow sign", "z": [-1.6, -1.3], "tag": [-331.7, 800.3],
         "text": "On a post at the back of the corner ledge, pointing east (note 85). It is the only sign on the glacier. You see it from the floor.",
         "draw": _SIGN},
    ],
    "play": [
        {"name": "Knuckles and stones", "z": [-0.4, 0.4], "style": "mark", "tag": [-317.6, 790.9],
         "text": "Each knuckle is pale blue ice, frosted and matte, 0.66 m long, with white frost along its top edge. The three stones "
                 "are grey-brown and dry with no frost on them: they are ringed here. Nothing else in the slot is either colour.",
         "draw": [_c(x, y, 0.5) for x, y in _NUBS]},
        {"name": "Boot prints and splinters", "z": [-0.4, 0.4], "style": "mark", "tag": [-323.5, 787.0],
         "text": "Drawn on the snow floor: boot prints from the tunnel's mouth to the first knuckle, and a ring of ice splinters under "
                 "each place where an icicle falls. The splinters tell you where not to stand before anything has fallen.",
         "draw": [_ln(-305.6, 786.1, -307.9, 786.1)] + [_ln(x - 0.5, 786.1, x + 0.5, 786.1) for x in _DRIP]},
        {"name": "The bridges, redone", "z": [-1.2, 1.2], "tag": [-312.0, 805.0],
         "text": _BRIDGE_TEXT,
         "draw": _NEW_BRIDGES},
    ],
    "foreground": [],
    "explains": [
        ["The twelve knuckles", "The teeth of a seam of old hard ice: a crack that healed", "The seam itself, half a metre wide in the far wall, on the same line"],
        ["The three stones", "Stones the glacier carries, where a layer of them meets the seam", "The line of stones in the far wall that each one belongs to"],
        ["The corner ledge", "Snow lying on the seam where it turns upward", "The seam going on up the corner to the shelf, and the arrow sign"],
        ["The snow floor", "The crack's floor, where everything that falls in here ends up", "The shelf's other half, lying in blocks"],
        ["The falling icicles", "Melt water dripping through the shelf", "The dark wet cracks they hang from, and the splinters under each"],
    ],
    "pieces": [
        ["Back wall bay", "4 m wide, 5 m tall", "30", "Background", "kit: back wall bay"],
        ["Paler wall bay", "4 m wide, 5 m tall", "3", "Background", "kit: paler wall bay (added below)"],
        ["Blue ice seam", "0.5 m wide; 22 m and 4 m", "2 lengths", "Background", "kit: blue ice seam"],
        ["Blue ice knuckle", "0.66 m by 0.34 m", "12", "Play space", "kit: blue ice seam and its holds"],
        ["Stone in the ice", "0.5 m", "3 held, 24 in the wall", "Play space and background", "kit: stone in the ice"],
        ["Blue rib", "1.4 m wide; 11.6 m and 9.2 m tall", "2", "Background", "kit: blue rib"],
        ["Fallen block of ice", "3 m and 1.8 m", "2", "Background", "kit: what they carried (ice_block), at two sizes"],
        ["Frozen climber deep in the ice", "0.9 m by 1.9 m", "1", "Background", "kit: frozen climber deep in the ice"],
        ["Pug arrow sign on a post", "1 m by 2.2 m", "1", "Background", "kit: pug arrow sign"],
        ["Frost rim for the door; candle lantern", "door 2.5 m by 4.5 m; lantern 0.5 m", "1 and 1", "Background", "kit: frost rim (added below); candle lantern"],
        ["Firm snow cap, with boot prints", "25.5 m floor; 3.5 m ledge", "2", "Play space", "kit: firm snow cap"],
        ["Splinters under a falling icicle", "1 m", "4", "Play space (drawn on)", "kit: falling icicle, its crack and its splinters"],
    ],
    "effects": [
        "The button mark on the limb that holds ice shivers, harder and harder, for the two seconds (note 84).",
        "A falling icicle ticks, drops, and bursts into splinters on whatever it lands on: a knuckle, the floor, you (note 86).",
        "Snow sifting down from the bridges, 18 m up, all the time.",
    ],
    "notes": [
        "Note 86: this room is redone. It is as hard as it was. What changes is that the whole zigzag can be read from the floor: the seam, the corner, the shelf's broken end with light coming down past it, the bridges, the door.",
        "Course change on this leg: none to anything you hold. All fifteen holds, the corner ledge and the floor are where they are.",
        "Scenery that moves: the pale card behind the holds (3 m wide, from the floor to the corner) goes, and a seam 0.5 m wide takes its place (note 84). The two ribs at x -316.5 and x -311.2 move to x -330.6 and x -308.2. The frozen climber in the wall moves from (-318.5, 795.0) to (-312.5, 798.6).",
        "Scenery that is new: the two fallen blocks on the floor, 1.3 m and more behind you; the arrow sign on the corner ledge (note 85); the paler wall round the door.",
        "Note 86: the falling icicles grow before they fall and shatter where they land. Their four places over this line do not move.",
        "Nothing stands in front of this room.",
    ],
    "ask": [
        "The whole lower crack on one screen. To see the door from the floor the camera has to pull back to about 24 m tall for all three challenges, which makes the climber half the size he is on the close camera. Yes, or keep the close camera?",
    ],
}

# ------------------------------------------------------------------ 9.2 Carámbanos
CARAMBANOS = {
    "id": "9.2", "slug": "9_2_carambanos", "title": "Carámbanos", "kind": "challenge",
    "window": [-333.0, 794.5, -313.0, 811.5], "cut_y": 801.2, "climber": [-328.4, 798.5],
    "place": ("The second leg of the zigzag. A shelf of hard ice sticks out of the west wall over the corner ledge, 12 m long and 1.4 m "
              "thick, and its east end is broken off. The rest of it lies in blocks on the floor of the slot. The blue seam you climbed "
              "carries on up the corner and along the underside of the shelf, and from it hang five big icicles of the same old ice: "
              "ringed like a stack of cups, each with a white collar of frost. They are the way. You go east from one to the next, with "
              "one stone tooth in the middle where you can stop, to a stone on the shelf's broken end. There the roof over you ends, "
              "light comes down the gap, and you climb up through the gap onto the shelf's top. Between the big icicles the shelf drips. "
              "A clear icicle grows from each of four dark wet cracks, shivers, and falls."),
    "keep": [
        "The five big icicles, the stone tooth and the stone on the shelf's nose, each where it is, 1.4 m apart.",
        "A big icicle snaps off after you take it and grows back. How long it holds is note 85's to change, and nothing else about it.",
        "The four places under the shelf where icicles fall, the one over the corner ledge, and the one over the shelf's top.",
        "The corner ledge and the shelf, as they are.",
    ],
    "background": [
        {"name": "The crack's far wall", "z": [-3.0, -2.4], "tag": [-320.5, 797.6], "top": True,
         "text": "The same banded wall. Above the shelf, in the closed west corner, it is the deepest blue in the room: nothing is up there.",
         "draw": _wall(-331.0, 794.5, -313.0, 809.5)},
        {"name": "The seam, turning the corner", "z": [-2.5, -2.4], "tag": [-328.4, 801.45],
         "text": "The pale seam from Hielo Azul comes up to the corner ledge and climbs straight on to the underside of the shelf, beside "
                 "the first big icicle. It is flush in the far wall. It shows that the icicles are the next piece of the same line.",
         "draw": _SEAM},
        {"name": "The scar, and the stones in it", "z": [-2.5, -2.4], "tag": [-315.6, 801.3],
         "text": "East of the shelf's end the far wall has a pale scar at the shelf's height, as long as the piece that fell, with stones "
                 "standing out of it. The stone tooth, the stone on the nose and the two stones wedged between the bridges all came out "
                 "of this one layer.",
         "draw": [_ln(-319.0, 802.6, -313.0, 802.6, "mark"), _c(-317.0, 802.25, 0.22, "pale"), _c(-315.5, 802.05, 0.26, "pale"), _c(-313.9, 802.3, 0.2, "pale")]},
        {"name": "The light down the gap", "z": [-3.0, -2.4], "tag": [-318.4, 807.0], "top": True,
         "text": "A paler stripe on the far wall above the shelf's broken end, 1.2 m wide, with frost on the broken edge. Everything "
                 "else over your head is dark. This is the answer to the question the room used to leave open: you do not go through "
                 "the shelf, you go round its end, here.",
         "draw": _LIT_GAP},
        {"name": "The pug arrow sign", "z": [-1.6, -1.3], "tag": [-331.7, 800.3], "top": True,
         "text": "On a post at the back of the corner ledge, 2.2 m tall, pointing east along the row of big icicles (note 85). It is the "
                 "kit's sign, turned round.",
         "draw": _SIGN},
    ],
    "play": [
        {"name": "The five that hold", "z": [-0.3, 0.3], "style": "pale", "tag": [-323.4, 803.2],
         "text": "Each big icicle is thick, ringed, pale blue and matte, with a white frost collar where it joins the shelf, and the seam "
                 "runs from collar to collar along the shelf's underside. They hang in a row in the play space, and nothing else here does.",
         "draw": [_c(x, 802.5, 0.36) for x in _ICI] + [_ln(-327.3, 802.6, -319.6, 802.6, "line")]},
        {"name": "The four that fall", "z": [-0.3, 0.3], "style": "dark", "tag": [-329.4, 801.7],
         "text": "Each hangs from a dark wet crack in the shelf, 0.8 m long, with no collar. It is smooth, clear and sharp, and darker "
                 "than the ones that hold. You watch it grow from a nub to full length, then it shivers, ticks and drops (note 86). "
                 "A fifth crack is over the corner ledge.",
         "draw": [_r(round(x - 0.4, 2), 802.6, round(x + 0.4, 2), 802.78) for x in _DRIP + [-329.4]]},
        {"name": "The broken end and its stone", "z": [-1.2, 1.2], "style": "line", "tag": [-320.0, 803.3],
         "text": "The shelf's east end is a rough broken face, frosted white, with a grey stone standing out of it at 803.1 m. The stone "
                 "is the last hold of this leg. Today the first snow bridge lies over it. Now there is open air above it.",
         "draw": [_ln(-319.0, 802.6, -318.8, 803.0), _ln(-318.8, 803.0, -319.1, 803.4), _ln(-319.1, 803.4, -318.95, 804.0)]},
        {"name": "The bridges, redone", "z": [-1.2, 1.2], "tag": [-315.6, 805.0],
         "text": _BRIDGE_TEXT,
         "draw": _NEW_BRIDGES},
        {"name": "The crack in the roof", "z": [-0.3, 0.3], "style": "dark", "tag": [-324.5, 810.4],
         "text": "One dark wet crack in the roof over the shelf's top, with one falling icicle. The rest of the roof is dark, glossy and "
                 "unbroken from wall to wall, with nothing hanging from it.",
         "draw": [_r(-324.9, 809.5, -324.1, 809.68)]},
    ],
    "foreground": [],
    "explains": [
        ["The five big icicles", "Old hard ice, hanging from the seam where it runs under the shelf", "The seam coming up the corner of the far wall to the first of them"],
        ["The stone tooth and the stone on the nose", "Stones from the shelf's own layer", "The scar on the far wall where the shelf's other half was, with the same stones in it"],
        ["The icicles that fall", "This year's melt water, dripping through cracks in the shelf", "The dark wet crack each one grows from"],
        ["The shelf (it cannot be held)", "A plate of hard ice left sticking out when the softer ice under it fell away", "Its broken end, the light coming down past it, and its other half on the floor"],
        ["The corner ledge", "Where the seam turns from the wall to the shelf", "The arrow sign"],
    ],
    "pieces": [
        ["Back wall bay", "4 m wide, 5 m tall", "14", "Background", "kit: back wall bay"],
        ["Paler wall bay, cut to a stripe", "1.2 m wide, 7 m tall", "1", "Background", "kit: paler wall bay (added below)"],
        ["Blue ice seam", "0.5 m wide; 4 m up the corner, 8 m under the shelf", "2 lengths", "Background and play space (drawn on)", "kit: blue ice seam"],
        ["Holding icicle: ringed, with a frost collar", "0.6 m across, 1.1 to 2.6 m long", "5", "Play space", "kit: holding icicle"],
        ["Falling icicle in its growing stages; its roof crack", "0.6 m across full grown; crack 0.8 m", "6", "Play space", "kit: falling icicle"],
        ["Stone in the ice", "0.5 m", "2 held, 3 in the scar", "Play space and background", "kit: stone in the ice"],
        ["Broken end for the shelf, frosted", "1.4 m tall", "1", "Play space (drawn on)", "new, this room only"],
        ["Pug arrow sign on a post", "1 m by 2.2 m", "1", "Background", "kit: pug arrow sign"],
        ["Ice in pieces: an icicle's", "pieces 0.2 m", "as they fall", "Play space", "kit: ice in pieces"],
    ],
    "effects": [
        "A big icicle creaks while you hang on it and snaps off clean at the collar. A new one grows down from the collar in plain view.",
        "A falling one: a drip, a nub, full length, a shiver, a tick, the drop, the burst.",
        "Frost dust falling through the lit gap.",
    ],
    "notes": [
        "Note 85: the big icicles hold longer than today's 0.7 seconds. The note's first try is 1.5 seconds, to be set by play. They look different from the ones that fall: thick, ringed and collared against smooth, clear and hanging from a wet crack.",
        "Note 85: the arrow sign on the corner ledge, pointing east.",
        "Note 86: the icicles that fall are seen growing first, and shatter where they land.",
        "Note 86, the redesign. Course change on this leg: the shelf, its five icicles, the stone tooth and the stone on its nose do not move. What changes at the nose is above it. Today the first snow bridge piece lies over the nose stone, 0.23 m above it, so the way up onto the shelf goes through the end of a bridge. The bridges move east and leave 1.2 m of open air there (see Puente de Nieve).",
        "The seam under the shelf and the frost collars are drawn on things that are there. Nothing new can be held.",
    ],
}

# ------------------------------------------------------------------ 9.3 Puente de Nieve
PUENTE_DE_NIEVE = {
    "id": "9.3", "slug": "9_3_puente_de_nieve", "title": "Puente de Nieve", "kind": "challenge",
    "window": [-322.0, 797.5, -300.0, 812.5], "cut_y": 803.8, "climber": [-320.4, 804.0],
    "place": ("The third leg, along the top of the slot. This crack once had a lid of snow at 804 m, from wall to wall. The shelf's top, "
              "the door's sill and the ice cave's floor are all at that height, and between the shelf and the door three pieces of the "
              "lid still hang across the crack. Each one sags in the middle and has 18 m of air under it. Two stones that came down "
              "when the shelf broke are wedged between the crack's walls and keep the three pieces apart. You step from the shelf's "
              "broken end across 1.2 m of open air onto the first bridge, and each piece of a bridge falls in a second after you take "
              "it. At the far end is the door of the ice cave: the palest thing in the slot, with a lantern burning inside it and one "
              "of the ones who tried hanging in its light."),
    "keep": [
        "Three bridges of three pieces each. A piece falls in 1 second after it is taken and comes back after 10.",
        "The two wedged stones between them: the only places to stop.",
        "The door, its sill at 804 m, and the cave's floor beyond.",
        "The fall: 18 m to the snow floor, at the foot of Hielo Azul.",
    ],
    "background": [
        {"name": "The crack's far wall", "z": [-3.0, -2.4], "tag": [-316.4, 800.2], "top": True,
         "text": "The same banded wall, running on past the door into the cave. Along it at 804 m, behind the bridges, is a thin white "
                 "frost line where the old lid met the wall. It is a mark and not a ledge: flush, and no wider than a hand.",
         "draw": _wall(-322.0, 797.5, -300.0, 812.5)},
        {"name": "The door, lit", "z": [-3.0, -2.4], "tag": [-307.0, 807.4], "top": True,
         "text": "A doorway 4.5 m tall and 2.5 m deep through the slot's east wall, with white frost round its edge. The far wall "
                 "round it is two steps paler than anywhere else in the slot, and the paler wall reaches 7 m back along the bridges.",
         "draw": _DOOR},
        {"name": "The lantern inside the door", "z": [-1.6, -1.4], "style": "light", "tag": [-300.7, 808.6],
         "text": "A candle lantern on a hook, on the cave's side of the door, beside the first of the ones who tried. From the bridges "
                 "you see its amber through the doorway, on him and on the snow of the sill.",
         "draw": [_c(-301.3, 807.7, 0.2)]},
        {"name": "The first of the ones who tried", "z": [-2.4, -1.2], "tag": [-301.4, 805.0],
         "text": "Seen through the door: a slab of dull ice with a frozen climber at its front, his boots at hand height and one mitten "
                 "raised. He belongs to La Cueva de Hielo. He is drawn here because he is what you are walking toward.",
         "draw": [_back(-302.4, 806.9)]},
        {"name": "The light down the gap", "z": [-3.0, -2.4], "tag": [-318.4, 807.4],
         "text": "The paler stripe above the shelf's broken end. From up here it is the gap you just climbed through, and the first step of this leg is across it.",
         "draw": _LIT_GAP},
        {"name": "One who fell", "z": [-2.6, -2.4], "tag": [-313.8, 799.4],
         "text": "Deep in the far wall under the middle bridge, head down: one of the ones who tried, a flat blue shape. He says what "
                 "the bridges do before you step on one.",
         "draw": _FELL},
    ],
    "play": [
        {"name": "The bridges, redone", "z": [-1.2, 1.2], "tag": [-312.0, 805.0],
         "text": "Nine pieces of snow lid, each 1.1 m long and 0.45 m thick, in three bridges, with the two wedged stones between them. "
                 "The yellow shapes are where they go. The black strip blanks out where they are today. Each bridge sags 0.15 m in the "
                 "middle, is thinner than firm snow, and has open air under it. The stones are grey-brown and dry, each wedged from the "
                 "far wall to the near one, with a dark drip mark down the far wall under it.",
         "draw": _NEW_BRIDGES},
        {"name": "The breakable look", "z": [-0.5, 0.5], "style": "mark", "tag": [-316.7, 802.6],
         "text": "Every piece is cracked across and has a corner gone: the mountain's one look for a thing that will break. Snow sifts "
                 "from each one all the time, so the three bridges hang over three thin curtains of falling snow.",
         "draw": [_ln(round(a + 0.5, 2), 803.5, round(a + 0.66, 2), 804.05) for a in _BR_X]},
        {"name": "The step across", "z": [-0.5, 0.5], "style": "line", "tag": [-318.4, 805.0],
         "text": "The 1.2 m of open air between the shelf's broken end and the first piece. It is the gap you came up through. "
                 "Stepping over it is the first move of this leg.",
         "draw": [_ln(-319.0, 804.25, -317.8, 804.25)]},
        {"name": "The sill", "z": [-0.5, 0.5], "style": "mark", "tag": [-304.3, 803.2],
         "text": "Firm snow, flat on top with a square front edge and ice under it: the first thing since the shelf that will not fall. "
                 "Boot prints cross it into the cave.",
         "draw": [_ln(-305.4, 804.1, -303.1, 804.1)]},
    ],
    "foreground": [],
    "explains": [
        ["The nine bridge pieces", "What is left of the snow lid that once roofed this crack", "The frost line along the far wall at the same height, where the lid met it"],
        ["The two wedged stones", "Stones out of the shelf's layer, jammed between the crack's two walls", "The scar they came from, and the drip mark under each"],
        ["The shelf's top, where you start", "A piece of the lid that has ice under it", "The broken end, and the light coming down the gap"],
        ["The door's sill", "The same snow, on the ice cave's floor", "The lit doorway, the lantern, and the first frozen climber"],
        ["The air under you", "The whole depth of the crack", "One who fell, deep in the wall below the middle bridge"],
    ],
    "pieces": [
        ["Back wall bay", "4 m wide, 5 m tall", "14", "Background", "kit: back wall bay"],
        ["Paler wall bay", "4 m wide, 5 m tall", "3", "Background", "kit: paler wall bay (added below)"],
        ["Frost rim for the door", "2.5 m by 4.5 m", "1", "Background", "kit: frost rim (added below)"],
        ["Snow bridge piece, cracked, a corner gone", "1.1 m long, 0.45 m thick", "9", "Play space", "kit: snow bridge piece, cut 0.15 m shorter"],
        ["Wedged stone", "1.2 m", "2", "Play space, running back to the far wall", "kit: wedged stone"],
        ["Firm snow cap, with boot prints", "the sill, 2.5 m", "1", "Play space", "kit: firm snow cap"],
        ["Candle lantern on a hook", "0.5 m", "1", "Background", "kit: candle lantern (lantern_hang)"],
        ["Frozen climber deep in the ice", "0.9 m by 1.9 m", "1", "Background", "kit: frozen climber deep in the ice"],
    ],
    "effects": [
        "Snow sifting from every bridge piece, and more of it from the one you are on.",
        "A piece that falls drops whole, turns over, and bursts on the floor 18 m down. A new one grows across from the far wall in plain view.",
        "The lantern's amber on the sill, seen from the first bridge.",
    ],
    "notes": [
        "Note 86, the redesign. Course change on this leg, in metres. The nine bridge pieces are each 1.1 m long (today six are 1.25 m and three are 1.2 m). The first bridge starts at x -317.8 (today -319.0), which leaves 1.2 m of open air at the shelf's broken end. The first wedged stone moves 0.75 m east, to x -314.5 to -313.3. The second moves 0.3 m east, to x -310.0 to -308.8. The second bridge runs x -313.3 to -310.0 and the third x -308.8 to -305.5. Heights, thickness, the one second, the door and the sill do not change.",
        "Why: today the first piece lies over the stone on the shelf's nose, and the bridges and the shelf make one white line across the whole slot, which reads as a lid. With the gap, the shelf has an end you can see past.",
        "Is it as hard: the crumbling snow is 1.2 m shorter in all, and there is one new step of 1.2 m over open air to start it. The two rests are as wide as they were.",
        "The lantern that hangs dead on the door's lintel today, inside the play space, is lit and moves to a hook 1.4 m back on the cave's side of the door.",
        "Note 86: the icicle that falls onto the shelf's top grows first and shatters. Its place does not move.",
    ],
}

# ------------------------------------------------------------------ 9.4 La Cueva de Hielo
_C94 = [(-302.4, 806.9), (-302.4, 809.8), (-329.9, 814.4), (-328.7, 820.2), (-329.9, 826.0), (-328.2, 830.6)]   # their belts

LA_CUEVA = {
    "id": "9.4", "slug": "9_4_la_cueva_de_hielo", "title": "La Cueva de Hielo", "kind": "challenge",
    "window": [-333.0, 802.5, -296.0, 834.5], "screen": [-303.0, 808.6], "cut_y": 814.4, "climber": [-300.5, 804.0],
    "place": ("Through the door is the ice cave: a hollow 18 m wide and 30 m high, the biggest room in the glacier, floored with snow "
              "that has drifted down from a window high in its east wall. Nobody could climb its walls. The ones who tried are the way. "
              "Two of them are frozen one above the other on the face of ice over the door, and their boots, belts and mittens take you "
              "8 m up to a snow balcony. The balcony runs 28 m west under a low roof to the foot of a chimney: a round shaft that melt "
              "water bored down through the ice, 3.5 m wide and 20 m tall. Four more of them are in the chimney, with four knuckles of "
              "blue ice and one stone between them. The last one's mitten is a hand's width under the lip he almost climbed out over."),
    "keep": [
        "The six frozen climbers, each exactly where he is, and the three grips on each: boots, belt, mitten.",
        "The four knuckles of blue ice and the one stone in the chimney.",
        "The balcony, the chimney's width, and the lip at 832 m.",
        "The fall: from the door's two onto the cave's floor, from the chimney onto the balcony.",
    ],
    "background": [
        {"name": "The far wall of the cave and the balcony", "z": [-3.0, -2.4], "tag": [-299.4, 820.0], "top": True,
         "text": "Banded ice, mid blue, deeper blue than the lower crack because there is more ice between it and the day. It runs "
                 "behind the cave, the balcony and the chimney without a break.",
         "draw": _wall(-331.0, 804.0, -296.0, 834.5, 3.6, 2.0)},
        {"name": "The door you came by", "z": [-3.0, -2.4], "style": "pale", "tag": [-304.25, 805.3],
         "text": "Seen from inside: a pale doorway with frost round it, and the lower crack beyond.",
         "draw": [_r(-305.5, 804.0, -303.0, 808.5)]},
        {"name": "The ice at their backs", "z": [-2.4, -1.2], "tag": [-300.9, 810.9], "top": True,
         "text": "Behind each of the six: a slab of dull mid-blue ice 1.7 m wide and 3 m tall that runs back to the far wall. He is "
                 "frozen to its front and stands whole out of it, in the play space, with nothing in front of him (note 87). The slab "
                 "is why he is there: the crack opened right beside where he was held. Today it is a pale card inside the play space.",
         "draw": [_back(x, y) for x, y in _C94]},
        {"name": "Two lanterns", "z": [-1.6, -1.4], "style": "light", "tag": [-300.4, 807.3],
         "text": "One beside the first climber at the door, and one beside the first climber at the foot of the chimney. Each hangs "
                 "on a hook 1.4 m back and lights him, not the wall. Wherever a group of them starts, there is a light on the first.",
         "draw": [_c(-301.3, 807.7, 0.2), _c(-328.6, 814.6, 0.2)]},
        {"name": "The balcony's lip, lit", "z": [-3.0, -2.4], "style": "pale", "tag": [-300.3, 813.4],
         "text": "A paler patch on the far wall above the two at the door, where the balcony begins. Seen from the door, it is the "
                 "palest thing in reach, and they are between you and it.",
         "draw": [_p([(-303.6, 811.3), (-300.6, 811.3), (-299.8, 814.0), (-303.2, 815.2)])]},
        {"name": "The chimney", "z": [-3.0, -2.4], "tag": [-332.1, 827.0], "top": True,
         "text": "The melt shaft's far wall: fluted in upright grooves by the water that bored it, and paler in its upper half, where "
                 "the ice is thin. From the balcony's east end it is a tall pale stripe at the far end of a dark gallery.",
         "draw": [_r(-331.0, 822.0, -327.5, 832.0, "pale")] + [_ln(x, 812.2, x, 831.8, "mark") for x in (-330.55, -329.3, -328.05)]},
        {"name": "The heap under the pit", "z": [-2.6, -1.4], "style": "line", "tag": [-320.2, 814.7],
         "text": "Against the far wall, under the slot that comes down through the balcony's roof: a heap of old broken ice. The slot "
                 "is the foot of the pit under El Serac. The heap says that things come down here.",
         "draw": [_p([(-322.2, 812.0), (-321.4, 813.4), (-320.3, 813.9), (-319.0, 813.2), (-318.2, 812.0)])]},
        {"name": "One lying in the wall", "z": [-2.6, -2.4], "tag": [-312.0, 816.0],
         "text": "Half way along the balcony, deep in the far wall and lying on his side: a flat blue shape, with no warm colour on him.",
         "draw": _deep(-312.0, 814.6, 80.0)},
        {"name": "The tally marks", "z": [-2.42, -2.4], "style": "mark", "tag": [-332.0, 813.5],
         "text": "Scratched in the far wall at the chimney's foot, in fives. Somebody counted his tries. Today they are 0.9 m back, "
                 "inside the play space. They move to the wall.",
         "draw": [_ln(round(-330.75 + 0.15 * k, 2), 813.1, round(-330.75 + 0.15 * k, 2), 813.75) for k in range(4)]},
        {"name": "On the cave's floor", "z": [-2.6, -1.3], "style": "line", "tag": [-298.9, 806.7],
         "text": "A block of ice 2 m across that came off the roof, and a frozen glove beside it. Both are behind where you walk.",
         "draw": [_r(-299.9, 804.0, -297.9, 806.0), _c(-300.3, 804.14, 0.12)]},
    ],
    "play": [
        {"name": "The ones who tried", "z": [-0.3, 0.3], "style": "line", "tag": [-301.3, 809.9],
         "text": "Each is frost grey, body and mask. His boots, belt and mitten are warm: honey leather, hemp rope, bone-white wool, "
                 "each a lump 0.35 m across and exactly the size of its grip. One mitten is always raised, and it points at the next "
                 "hold: the yellow lines show where each one points. The first at the door has his boots at hand height.",
         "draw": [_ln(-302.4, 811.0, -303.0, 812.0), _ln(-329.9, 815.6, -328.7, 816.9), _ln(-328.7, 821.4, -329.9, 822.6),
                  _ln(-329.9, 827.2, -328.8, 828.4), _ln(-328.2, 831.8, -327.4, 832.0)]},
        {"name": "Four knuckles and a stone", "z": [-0.3, 0.3], "style": "mark", "tag": [-327.9, 824.4],
         "text": "Between the four in the chimney: four knuckles of pale blue ice, which let go after two seconds, and one grey stone, "
                 "ringed here, which does not. They are the same pieces as in Hielo Azul.",
         "draw": [_c(-328.8, 823.9, 0.45)]},
        {"name": "The balcony's snow", "z": [-0.5, 0.5], "style": "mark", "tag": [-312.0, 810.5],
         "text": "Firm snow, 28 m of it, with a line of boot prints going west, blue hollows, and a pocked patch under the pit's slot. "
                 "All drawn on. It tells you which way to walk when the chimney is still off the screen.",
         "draw": [_ln(-303.6, 812.1, -327.2, 812.1)]},
        {"name": "The lip", "z": [-0.5, 0.5], "style": "line", "tag": [-326.6, 833.2],
         "text": "The snow edge of the upper level, 0.2 m above the last one's mitten. His arm is at full stretch. You use it, and go over.",
         "draw": [_ln(-327.5, 831.5, -327.5, 832.0), _ln(-327.5, 832.0, -326.9, 832.0)]},
    ],
    "foreground": [],
    "explains": [
        ["The two frozen climbers at the door", "Two of the ones who tried, one above the other on the ice over the door", "The slab of ice at each one's back, the lantern beside the first, the paler wall above them"],
        ["The four in the chimney", "A party that went up the melt shaft and got no further", "Their slabs, the lantern at the foot, the tally marks, the fluted wall"],
        ["The knuckles and the stone", "A seam of blue ice crossing the shaft, with one stone in it", "The same pale seam in the fluted wall behind"],
        ["The balcony", "The roof of the lower crack, snowed over", "Boot prints west, the heap under the pit's slot, one lying in the wall"],
        ["The cave's floor", "Snow drifted down from the window, 26 m up", "The fallen block, the glove, and at the east end the frog's snow hole"],
    ],
    "pieces": [
        ["Back wall bay", "4 m wide, 5 m tall", "34", "Background", "kit: back wall bay"],
        ["Paler wall bay", "4 m wide, 5 m tall", "1", "Background", "kit: paler wall bay (added below)"],
        ["Fluted bay for the chimney", "3.5 m wide, 5 m tall", "4, the upper 2 paler", "Background", "new, this area only: the back wall bay with upright grooves"],
        ["Frozen climber you can hold: hanging, clinging, falling, reaching", "1.8 m; each grip 0.35 m", "6", "Play space", "kit: frozen climber you can hold"],
        ["Ice at a frozen climber's back", "1.7 m wide, 3 m tall, 1.2 m deep", "6", "Background", "kit: ice at a frozen climber's back (added below)"],
        ["Candle lantern on a hook", "0.5 m", "2", "Background", "kit: candle lantern (lantern_hang)"],
        ["Blue ice knuckle; stone in the ice", "0.6 m by 0.34 m; 0.5 m", "4 and 1", "Play space", "kit: blue ice seam and its holds; stone in the ice"],
        ["Firm snow cap, with boot prints", "28 m balcony; 21 m floor", "2", "Play space", "kit: firm snow cap"],
        ["Ice in pieces, as a heap", "4 m wide, 1.9 m tall", "1", "Background", "kit: ice in pieces"],
        ["Frozen climber deep in the ice", "0.9 m by 1.9 m", "1", "Background", "kit: frozen climber deep in the ice"],
        ["Tally marks; frozen glove; fallen block", "0.8 m; 0.25 m; 2 m", "1 of each", "Background", "kit: what they carried"],
    ],
    "effects": [
        "Each lantern flickers. Its amber lies on one frozen climber and on the snow under him.",
        "The button mark shivers on a limb that holds a knuckle. It does not shiver on a boot, a belt or a mitten.",
        "A cold draught along the balcony, going west: a little snow moves along the floor the way you are going.",
    ],
    "notes": [
        "Note 87: nothing stands in front of any of them. The ice is at their backs, and it stops at the back edge of the play space.",
        "Note 87: they read as the way up at first sight because of three things. Their grips are the only warm, dry colour in the room. The first one at the door has his boots at hand height and a lit lantern beside him. Each one's raised mitten points at the next hold.",
        "In the play space today, and moved out of it: the pale card behind each of the six (it becomes the slab, from 1.2 m back to the wall), the dead lantern on the door's lintel (lit, on a hook 1.4 m back), the tally marks (to the far wall), the frozen glove (1.3 m back).",
        "The sheet allows no icicle fringe in a room where an icicle falls. One icicle falls into this cave, so the row of small icicles on the cave's roof comes out.",
        "Nothing you touch moves.",
    ],
}

# ------------------------------------------------------------------ 9.0 the frog's snow hole
_BANK = [_p([(-289.8, 804.0), (-289.2, 805.5), (-287.8, 806.5), (-285.8, 806.7), (-284.5, 806.4), (-284.5, 804.0)], "pale"),
         _p([(-288.7, 804.0), (-288.5, 805.2), (-287.5, 806.0), (-286.3, 806.0), (-285.5, 805.3), (-285.3, 804.0)], "dark")]
_FROG = [_c(-286.7, 804.2, 0.15, "pale"), _p([(-287.2, 804.0), (-286.9, 804.32), (-286.5, 804.32), (-286.2, 804.0)], "line"),
         _c(-287.8, 804.22, 0.16, "line"), _c(-286.0, 805.35, 0.17, "light")]

SNOW_HOLE = {
    "id": "9.0", "slug": "9_0_the_frogs_snow_hole", "title": "The frog's snow hole", "kind": "rest",
    "window": [-306.5, 800.5, -281.5, 815.5], "screen": [-293.0, 808.2], "cut_y": 804.9, "climber": [-294.6, 804.0],
    "place": ("The east end of the ice cave's floor, 20 m under the long flight from the slide to the rope. Snow that comes in at the "
              "window far above has drifted against the east wall into a bank, and somebody dug a round hole in the bank: 3 m wide and "
              "2 m high, the kind of hole a climber digs to sit out a night. A lantern is lit in it and a kettle is on. The glacier's "
              "frog lives here, wrapped in a blanket. From the slide you see its light far below you. If you miss the rope, this is "
              "where you land, and the frog watches you get up. The way back up is at the other end of the floor: the two at the door."),
    "keep": [
        "The cave's floor: firm snow from the door to the east wall, flat, 21 m long.",
        "The rope overhead ends 9.3 m above the floor. It cannot be reached from here.",
        "The one icicle that falls into the cave, at x -293, and its timing.",
        "The frog's hole is behind the floor. Nothing new can be stood on or held.",
    ],
    "background": [
        {"name": "The cave's far wall", "z": [-3.0, -2.4], "tag": [-296.0, 809.6], "top": True,
         "text": "The same deep blue banded ice. It never stops inside the frame, and it gets darker toward the east wall, away from the door.",
         "draw": _wall(-306.5, 804.0, -284.5, 815.5, 3.6, 2.0) + [_r(-306.5, 800.5, -305.5, 804.0)]},
        {"name": "The snow bank and the hole", "z": [-3.6, -1.2], "tag": [-286.6, 807.3], "top": True,
         "text": "A bank of drifted snow against the east wall, 5.3 m long and 2.7 m high, standing behind the floor you walk on. The "
                 "hole in it is round, 3 m wide and 2 m high, with a smooth domed roof and a step of packed snow at its mouth. Its "
                 "front is open to you. Its mouth is at the back edge of the play space, so you stand at its door on the cave's own floor.",
         "draw": _BANK},
        {"name": "The frog, and what is in the hole", "z": [-3.2, -1.6], "tag": [-290.4, 805.2],
         "text": "The frog sits on a folded bedroll, wrapped in a striped blanket with only its face showing. Beside it a kettle "
                 "steams on a tiny spirit stove. A candle lantern hangs from an axe driven into the roof. Its amber fills the hole "
                 "and lies on the snow in front of it. A short string of the town's paper flags is pinned along the back.",
         "draw": _FROG},
        {"name": "The way back up", "z": [-2.4, -1.2], "tag": [-301.0, 809.7],
         "text": "At the west end of the floor: the door, pale, and beside it the first of the ones who tried, with his lantern. "
                 "They belong to La Cueva de Hielo. From the frog's door they are the only other light in the cave.",
         "draw": [_r(-305.5, 804.0, -303.0, 808.5, "pale"), _back(-302.4, 806.9), _c(-301.3, 807.7, 0.2, "light")]},
        {"name": "The fallen block and the glove", "z": [-2.6, -1.3], "style": "line", "tag": [-298.9, 806.7],
         "text": "A block of ice 2 m across, off the roof, and a frozen glove beside it. Behind where you walk.",
         "draw": [_r(-299.9, 804.0, -297.9, 806.0), _c(-300.3, 804.14, 0.12)]},
        {"name": "One in the wall", "z": [-2.6, -2.4], "tag": [-294.7, 812.9],
         "text": "Deep in the far wall, 8 m up, leaning: one of the ones who tried, a flat blue shape. He is level with the end of the rope.",
         "draw": _deep(-296.0, 812.5, -20.0)},
    ],
    "play": [
        {"name": "Where people have landed", "z": [-0.6, 0.6], "style": "line", "tag": [-296.2, 803.2],
         "text": "Drawn on the snow: two shallow dents the size of a body, old ones, half snowed over. They say what this floor is "
                 "before you have fallen onto it. They have no depth and change nothing you stand on.",
         "draw": [_p([(-296.9, 804.02), (-296.2, 803.78), (-295.5, 804.02)]), _p([(-291.5, 804.02), (-290.8, 803.78), (-290.1, 804.02)])]},
        {"name": "Boot prints", "z": [-0.6, 0.6], "style": "mark", "tag": [-302.6, 803.2],
         "text": "Two lines of prints on the snow. One comes in at the door and goes to the first frozen climber. The other goes from "
                 "each dent back west to him. A third, very small, with webbed toes, goes from the hole to the nearer dent and back.",
         "draw": [_ln(-305.3, 804.1, -289.9, 804.1)]},
        {"name": "Splinters", "z": [-0.6, 0.6], "style": "line", "tag": [-293.0, 805.0],
         "text": "A ring of ice splinters on the snow under the one icicle that falls into the cave. It grows at a dark crack in the "
                 "roof, 30 m up, and bursts here (note 86).",
         "draw": [_ln(-293.5, 804.1, -292.5, 804.1)]},
        {"name": "The rope's tail", "z": [-0.3, 0.3], "style": "mark", "tag": [-285.4, 813.4],
         "text": "The frayed end of the rope you slide to, 9.3 m above the floor and 2 m in from the east wall. It is there today. "
                 "Looking up from the frog's door you see the whole rope, the window's light above it, and how far you fell.",
         "draw": [_c(-286.59, 813.35, 0.3)]},
    ],
    "foreground": [],
    "explains": [
        ["The cave's floor", "Snow drifted down from the window, 26 m up", "The bank it has piled into at the east wall"],
        ["Nothing here is new to hold", "The frog's hole is scenery you stand in front of", "The hole, the frog, the kettle, the lantern"],
        ["The rope overhead", "The rope of Tobogán Helado, hung from the window's sill", "The paler light at the top of the east wall, where the window is"],
        ["The falling icicle", "Melt water through the cave's roof", "Its dark crack, far above, and the splinters where it lands"],
    ],
    "pieces": [
        ["The frog's snow hole: bank, round hollow, step", "bank 5.3 m by 2.7 m; hollow 3 m by 2 m", "1", "Background, cut away at the front", "kit: the frog's snow hole"],
        ["The frog, wrapped in a blanket", "0.3 m", "1", "Background", "kit: the frog"],
        ["Bedroll; kettle on a spirit stove; candle lantern on an axe; a string of paper flags", "bedroll 1 m; kettle 0.3 m; lantern 0.5 m; flags 1.5 m", "1 of each", "Background", "kit: camp_bedroll, lantern_hang, ice_axe; the kettle and stove are the cliffs' tea things; the flags are papel_tatters cut short"],
        ["Back wall bay", "4 m wide, 5 m tall", "12", "Background", "kit: back wall bay"],
        ["Firm snow cap, with boot prints and landing dents", "21 m long, 0.6 m thick", "1", "Play space", "kit: firm snow cap; the dents are new paint on it"],
        ["Fallen block; frozen glove", "2 m; 0.25 m", "1 and 1", "Background", "kit: what they carried"],
        ["Frozen climber deep in the ice", "0.9 m by 1.9 m", "1", "Background", "kit: frozen climber deep in the ice"],
        ["Splinters under a falling icicle", "1 m", "1", "Play space (drawn on)", "kit: falling icicle, its crack and its splinters"],
    ],
    "effects": [
        "The frog's croak, heard from about a screen away, and its amber light on the snow.",
        "Steam from the kettle, rising straight: there is no wind down here.",
        "The frog turns its head to follow you. When you land near it, it blinks.",
        "A few snowflakes coming down the whole height of the cave from the window.",
    ],
    "notes": [
        "Note 60: this biome's frog, in the snow hole the sheet proposes. Finding it is never needed: it is at the dead end of the floor, where a miss on the slide puts you.",
        "Note 86: the icicle that falls into the cave is seen growing and shatters on the floor, so it cannot pin anybody who has just landed.",
        "The kettle is the same one as in the drivers' cave on the cliffs and in the keeper's cabin on the storm ridge.",
        "The cave's floor is 21 m of snow. So that no 4 m of it is blank: the boot prints, the two dents, the splinters, blue hollows, and the lantern's light.",
        "Nothing you touch moves.",
    ],
}

# ------------------------------------------------------------------ 9.5 El Serac
_PIV = (-322.8, 832.0)
_ARC = [(round(_PIV[0] + 7.5 * math.sin(math.radians(a)), 2), round(_PIV[1] + 7.5 * math.cos(math.radians(a)), 2)) for a in range(0, 141, 10)]

EL_SERAC = {
    "id": "9.5", "slug": "9_5_el_serac", "title": "El Serac", "kind": "challenge",
    "window": [-332.0, 815.0, -306.5, 845.0], "cut_y": 835.0, "climber": [-326.4, 832.0],
    "place": ("Above the chimney is the upper level: a long low room under a dark roof. Its floor stops after 4.7 m at a pit 10 m "
              "across, and on the brink stands a tower of ice 7.1 m tall and 1.9 m thick, with firm snow up its west side and on its "
              "top. It is a slab that a crack has cut off the wall. The glacier is still pushing behind it, and it stands only until "
              "something touches it. Then it tips east over the pit, slowly and then fast, goes on through level and down into the "
              "pit, and breaks to pieces there. You go up its snow side as it turns, and jump from its top to a snow-topped pillar "
              "on the far side before it passes level. Where it stood, the push squeezes the next slab up out of the same crack: "
              "bare and dark first, then its snow, and then it can be climbed."),
    "keep": [
        "The tower's size and where it stands, its snow side 0.6 m wide, its snow cap, and the stone at its top corner.",
        "It starts to tip when it is touched, and it tips on today's curve: slowly, then fast.",
        "The jump to the pillar, and the pillar: snow, 2.5 m wide, at 834.5 m.",
        "The fall: the pit, its funnel, the slot, and out onto the balcony's snow at the foot of the chimney.",
    ],
    "background": [
        {"name": "The upper level's far wall", "z": [-3.0, -2.4], "tag": [-318.4, 830.6], "top": True,
         "text": "Banded ice, 2.4 m back, from the pit's floor to the roof. The roof is dark, glossy and unbroken from wall to wall: "
                 "nothing up there is a way out.",
         "draw": _wall(-331.0, 815.0, -306.5, 842.0, 3.4, 2.0)},
        {"name": "The wall the tower was cut from", "z": [-2.4, -1.6], "style": "pale", "tag": [-324.5, 840.9], "top": True,
         "text": "Behind the tower: its twin, a slab the same size still standing in the far wall, with the crack that will free it "
                 "drawn as a white line beside it. The tower you climb is the nearest of a row.",
         "draw": [_p([(-325.6, 832.0), (-323.7, 832.0), (-323.3, 842.0), (-325.2, 842.0)]), _ln(-322.8, 832.0, -322.3, 842.0, "mark")]},
        {"name": "Two that have started to lean", "z": [-2.4, -2.0], "style": "pale", "tag": [-318.2, 838.4],
         "text": "In the pit's far wall: two more slabs of bluer ice, both leaning east, the way this one will fall. They are flush "
                 "in the wall and come nowhere near the play space. They show which way the tower goes before you touch it.",
         "draw": [_p([(-321.2, 825.3), (-319.7, 825.3), (-317.7, 842.0), (-319.2, 842.0)]),
                  _p([(-316.6, 827.0), (-315.5, 827.0), (-314.0, 842.0), (-315.1, 842.0)])]},
        {"name": "Old towers, in pieces", "z": [-3.0, -1.4], "style": "line", "tag": [-320.4, 825.7],
         "text": "Jammed in the back of the pit's funnel: blocks of old dark ice, snow still on some of them. The towers that stood "
                 "here before. They are behind the funnel and block nothing: a body still falls through the slot.",
         "draw": [_p([(-322.4, 825.7), (-321.0, 827.0), (-319.3, 826.5), (-318.5, 825.0), (-319.6, 824.3), (-321.3, 824.6)])]},
        {"name": "The way on, paler", "z": [-3.0, -2.4], "style": "pale", "tag": [-309.4, 838.2],
         "text": "East of the pit, behind the pillar and beyond, the far wall is two steps paler: the window's daylight coming back "
                 "along the roof. From the brink it is the palest thing in the room, and the pillar stands against it.",
         "draw": [_p([(-313.4, 834.6), (-309.0, 834.6), (-306.5, 836.6), (-306.5, 839.0), (-311.0, 842.0), (-314.4, 842.0)])]},
        {"name": "An axe and a coil of rope", "z": [-1.8, -1.3], "style": "line", "tag": [-327.25, 833.35],
         "text": "At the back of the brink's snow, where the chimney comes up: an ice axe stuck in upright, and a coil of rope frozen "
                 "flat. The party in the chimney left them here. Today they lie inside the play space. They move 0.8 m back.",
         "draw": [_ln(-327.0, 832.0, -326.75, 832.7), _c(-326.2, 832.16, 0.22)]},
    ],
    "play": [
        {"name": "The fall, all the way", "z": [-0.5, 0.5], "style": "mark", "tag": [-318.6, 839.5],
         "text": "The path of the tower's top corner. It does not stop at 75 degrees as it does today. It goes on through level, "
                 "swings down into the pit and strikes the far slope, and there the tower shatters (note 88). The jump is made "
                 "from the top before level.",
         "draw": [_ln(_ARC[i][0], _ARC[i][1], _ARC[i + 1][0], _ARC[i + 1][1]) for i in range(len(_ARC) - 1)]},
        {"name": "The stump, and the next one growing", "z": [-1.2, 1.2], "style": "mark", "tag": [-323.75, 834.2],
         "text": "What is left when the tower has gone: a broken stump 0.6 m high. The next tower rises out of it over a few seconds, "
                 "bare and blue-black with no snow, and cannot be touched while it grows. Its snow side and cap come last. Only then "
                 "is it the tower again (note 88).",
         "draw": [_r(-324.7, 832.0, -322.8, 832.6), _r(-324.7, 832.0, -322.8, 835.5)]},
        {"name": "Bent layers under the foot", "z": [1.1, 1.2], "style": "mark", "tag": [-324.9, 829.6],
         "text": "Drawn on the face of the block the tower stands on: the ice's bands, bent upward into a peak under the tower's foot. "
                 "It is the push that raises the next one, shown where you can see it. A white crack runs along the foot itself.",
         "draw": [_ln(-326.9, 829.4, -323.8, 831.6), _ln(-322.9, 830.2, -323.8, 831.6), _ln(-326.9, 827.9, -323.8, 830.1), _ln(-322.9, 828.7, -323.8, 830.1)]},
        {"name": "The pillar's snow", "z": [-0.5, 0.5], "style": "mark", "tag": [-311.7, 835.5],
         "text": "Firm snow with old boot prints on it, all pointing east. It is the head of the slide.",
         "draw": [_ln(-312.9, 834.6, -310.5, 834.6)]},
        {"name": "Where the pieces go", "z": [-0.5, 0.5], "style": "mark", "tag": [-320.1, 820.4],
         "text": "The tower's pieces fall through the slot with whoever was still on it, and are gone in a moment. They hurt nobody.",
         "draw": [_c(-320.3, 822.6, 0.35), _c(-319.6, 821.4, 0.25), _c(-320.6, 818.9, 0.3)]},
    ],
    "foreground": [],
    "explains": [
        ["The tower", "A slab of the glacier that a crack has cut off, standing on the pit's brink", "Its twin still in the far wall, and the crack beside it"],
        ["The snow up its west side", "The side that faced the weather while it was part of the wall", "Bare dark ice on every tower that has not been out long: the growing one has none"],
        ["Its fall", "The glacier pushing it over the edge", "Two more slabs already leaning east in the pit's wall; the bent layers under its foot"],
        ["The pit", "Where every tower before it went", "Old towers in pieces, jammed in the back of the funnel"],
        ["The pillar you jump to", "The head of the old melt-water slide", "The paler wall behind it"],
    ],
    "pieces": [
        ["The tower of ice: standing, with its snow side and cap", "1.9 m by 7.1 m; snow side 0.6 m", "1", "Play space", "kit: the tower of ice (serac)"],
        ["The tower growing; its stump", "to 7.1 m; stump 0.6 m", "1 and 1", "Play space", "kit: the tower of ice, the growing one and the stump"],
        ["Ice in pieces: the tower's", "pieces 0.3 to 1 m", "about 12", "Play space; a jam of 8 more in the background", "kit: ice in pieces"],
        ["Blue rib, as a slab of the wall", "1.9 m and 1.5 m wide, 10 to 17 m tall", "3", "Background", "kit: blue rib"],
        ["Back wall bay", "4 m wide, 5 m tall", "22", "Background", "kit: back wall bay"],
        ["Paler wall bay", "4 m wide, 5 m tall", "2", "Background", "kit: paler wall bay (added below)"],
        ["Stone in the ice, for the tower's top corner", "0.45 m", "1", "Play space", "kit: stone in the ice"],
        ["Ice axe; frozen rope coil", "0.7 m; 0.6 m", "1 and 1", "Background", "kit: what they carried"],
        ["Bent layers; the crack at the foot", "paint, 4 m wide", "1", "Play space (drawn on)", "new, this area only"],
        ["Firm snow cap, with boot prints", "4.7 m brink; 2.5 m pillar", "2", "Play space", "kit: firm snow cap"],
    ],
    "effects": [
        "A creak when you first touch it, then a long groan that rises as it goes.",
        "Snow sliding off its cap as it tips, and a crack opening white along its foot.",
        "The shatter in the pit: one crash, a cloud of ice dust up out of the pit, pieces down the slot.",
        "The next one growing: a grinding from under the brink, and the bent layers creep.",
    ],
    "notes": [
        "Note 88: the tower falls all the way and shatters in the pit, so you cross it while it turns. Its speed starts from today's.",
        "Note 88: the next one grows into place and counts only when it is full height. It is the same law as the icicles: ice that comes is seen coming.",
        "The cliffs' and the cableway's rule that a moving thing shows what drives it: here that is the bent layers under the foot, the row of slabs in the far wall, and the old pieces in the pit.",
        "In the play space today, and moved out of it: the ice axe and the rope coil on the brink (0.8 m back, item 6).",
        "Nothing you touch moves, apart from what note 88 asks.",
    ],
}

# ------------------------------------------------------------------ 9.6 Tobogán Helado
_RAMP = [(-310.46, 834.15)]
for _ang, _len in ((82, 5.93), (72, 0.9), (62, 0.9), (52, 0.9), (42, 0.9), (32, 0.8), (22, 0.8), (12, 0.8), (2, 0.7), (-10, 0.6)):
    _RAMP.append((_RAMP[-1][0] + math.cos(math.radians(_ang)) * _len, _RAMP[-1][1] - math.sin(math.radians(_ang)) * _len))
_FX, _FY = _RAMP[-1][0] + 1.1, _RAMP[-1][1] - 0.25
_LIP = (_FX + 1.8 * math.cos(math.radians(32)), _FY + 1.8 * math.sin(math.radians(32)))
_FLAKE = [(_FX, _FY), _LIP, (_LIP[0], _LIP[1] - 0.8), (_FX + 0.5, _FY - 1.55), (_FX, _FY - 1.55)]
_FLIGHT = [(_LIP[0] + d, _LIP[1] + 0.6249 * d - 0.05179 * d * d) for d in (0, 1.5, 3, 4.5, 6, 7.5, 9, 10.5, 12, 13.5, 15)]
_GROOVES = []
for _dx, _dy in ((0.9, 0.55), (1.8, 1.1)):
    _g = [(x + _dx, y + _dy) for x, y in _RAMP[:-1]]
    _GROOVES += [_ln(round(a[0], 2), round(a[1], 2), round(b[0], 2), round(b[1], 2), "mark") for a, b in zip(_g, _g[1:])]
_WINDOW = [_r(-285.5, 830.2, -281.0, 834.7, "pale"), _ln(-284.5, 834.3, -281.5, 834.3, "mark"), _c(-282.2, 833.6, 0.2, "light")]

TOBOGAN = {
    "id": "9.6", "slug": "9_6_tobogan_helado", "title": "Tobogán Helado", "kind": "challenge",
    "window": [-314.5, 802.0, -279.0, 838.0], "cut_y": 826.0, "climber": [-311.6, 834.5],
    "place": ("The pillar you landed on is the head of the glacier's old drain. Melt water ran off the upper level here for years: "
              "down a face of ice 6 m tall and nearly sheer, round a bend into a bowl, and out through a crack in the bowl's rim. The "
              "water polished all of it, and it is the slickest thing on the mountain. Since then a flake of ice has wedged in the "
              "crack and tilted up, and it makes a kicker. So you sit down on purpose. You slide, leave the kicker at 32 degrees, and "
              "fly 15 m across the top of the ice cave, 20 m above its floor, to a hemp rope that hangs from the sill of a window in "
              "the glacier's skin. The window is the first daylight since the cableway. It is the palest thing in the room from the "
              "moment you land on the pillar, and the rope hangs in front of it."),
    "keep": [
        "The slide's whole shape: the sheer face, the bend, the bowl, the 1.1 m crack, the kicker and its 32 degrees.",
        "The draught across the bowl, which pushes a body that has stalled into the crack.",
        "The rope: 16 m long, 15 m from the kicker's lip, hung from the sill's edge. And the sill.",
        "The fall: 20 m to the cave's snow floor, at the foot of La Cueva de Hielo.",
    ],
    "background": [
        {"name": "Outside", "z": [-8.0, -7.8], "style": "pale", "tag": [-279.9, 820.0],
         "text": "East of the glacier's skin: the far side of the glacier as one painted card, and behind it the valley, the ranges and "
                 "the cloud that are given. From inside you see only what shows through the window.",
         "draw": [_r(-281.0, 802.0, -279.0, 838.0)]},
        {"name": "The cave's far wall", "z": [-3.0, -2.4], "tag": [-296.5, 815.0], "top": True,
         "text": "Deep blue banded ice behind the whole flight, from the cave's floor to its roof. It is plain on purpose: against it "
                 "you see the rope, the window and yourself. It grows paler toward the window.",
         "draw": _wall(-314.5, 804.0, -284.5, 838.0, 4.0, 2.0)},
        {"name": "The window, the town's paper and a lantern", "z": [-3.0, -1.4], "tag": [-283.4, 832.3], "top": True,
         "text": "A gap in the skin 4.5 m wide and 4.5 m tall, full of white daylight, with frost round its edge. The town's torn "
                 "paper hangs along its top and blows outward. A lit lantern hangs on its outer side. Today the paper is inside the "
                 "play space. It moves 0.6 m back.",
         "draw": _WINDOW},
        {"name": "The water's grooves", "z": [-2.5, -2.4], "tag": [-307.0, 831.4],
         "text": "Two long grooves scoured in the far wall beside the slide, following its curve down the face and round into the bowl. "
                 "They are flush marks, not ledges. They show the whole line of the slide from the pillar before you sit down.",
         "draw": _GROOVES},
        {"name": "Two blue ribs", "z": [-2.4, -2.0], "style": "pale", "tag": [-297.0, 829.4],
         "text": "Leaning slabs of bluer ice in the far wall, as tall as the cave. Today one stands 2 m from the rope. Both move "
                 "west, so that the only upright thing near the rope is the rope.",
         "draw": [_p([(-299.6, 804.0), (-297.4, 804.0), (-295.4, 834.7), (-297.6, 834.7)]),
                  _p([(-293.6, 804.0), (-292.4, 804.0), (-291.3, 834.7), (-292.5, 834.7)])]},
        {"name": "Two in the wall", "z": [-2.6, -2.4], "tag": [-291.9, 819.8],
         "text": "Deep in the far wall under the flight, flat blue shapes: one leaning, one with his arms out. The one near the rope "
                 "moves 2 m west of where he is today, away from the rope's line.",
         "draw": _deep(-296.0, 812.5, -20.0) + _deep(-290.6, 818.4, 35.0)},
        {"name": "The rope's anchor", "z": [-1.8, -1.3], "style": "line", "tag": [-285.3, 831.8],
         "text": "At the back of the sill: an ice axe driven in to its head, with the rope's upper end knotted round it and two turns "
                 "of spare rope frozen flat. Somebody hung this rope from the window. They came in the way you will go out.",
         "draw": [_ln(-285.9, 830.2, -285.6, 831.0), _c(-285.1, 830.38, 0.2)]},
        {"name": "The frog's light, far below", "z": [-3.6, -1.2], "tag": [-287.0, 807.3],
         "text": "At the east end of the cave's floor, straight under the rope: the snow bank and the round hole with a lantern in "
                 "it. It is the only warm colour under the flight, and you see it as you fly. It has its own page.",
         "draw": _BANK + [_c(-286.0, 805.35, 0.17, "light")]},
    ],
    "play": [
        {"name": "The kicker", "z": [-1.2, 1.2], "style": "mark", "tag": [-302.3, 823.0],
         "text": "A flake of the glacier's dark ice wedged in the crack's mouth, its face 1.8 m long. It is glossy and slick like the "
                 "slide, with a white edge along its lip where it is chipped. Snow smokes off the lip in the draught.",
         "draw": [_p(_FLAKE)]},
        {"name": "The draught", "z": [-1.2, 1.2], "style": "mark", "tag": [-306.0, 827.9],
         "text": "Long wavy white lines with an inked edge across the bowl, going east (note 89). It is the cave's air being pulled "
                 "toward the window. The lines curl down into the crack at the bowl's rim, which is where a stalled body goes.",
         "draw": _wavy(-307.2, -304.9, 826.6) + _wavy(-307.2, -304.9, 825.7) + _wavy(-307.0, -304.9, 824.9)},
        {"name": "The flight", "z": [-0.3, 0.3], "style": "mark", "tag": [-295.6, 828.2],
         "text": "The line a clean slide flies, from the course's own numbers: off the lip at 6.1 m a second, 15 m across, meeting "
                 "the rope 2.3 m below the lip's height. It is drawn here only to show the place. Nothing marks it in the game.",
         "draw": [_ln(round(a[0], 2), round(a[1], 2), round(b[0], 2), round(b[1], 2)) for a, b in zip(_FLIGHT, _FLIGHT[1:])]},
        {"name": "The one icicle that falls", "z": [-0.3, 0.3], "style": "dark", "tag": [-293.0, 833.5],
         "text": "A dark wet crack in the cave's roof, with one clear icicle that grows, shivers and drops 30 m to the floor, where "
                 "it bursts (note 86). It is the only icicle in the cave. Its line crosses the flight.",
         "draw": [_r(-293.4, 834.52, -292.6, 834.7), _ln(-293.5, 804.1, -292.5, 804.1, "line")]},
        {"name": "The rope", "z": [-0.2, 0.2], "style": "mark", "tag": [-287.9, 813.4],
         "text": "Hemp, frozen stiff, pale and dry, with a frayed tail. It is the only thing in the upper half of the cave that is "
                 "a warm colour, and it hangs against the palest part of the wall.",
         "draw": [_c(-286.59, 813.35, 0.3)]},
        {"name": "The sill", "z": [-0.5, 0.5], "style": "mark", "tag": [-283.8, 829.3],
         "text": "Firm snow with boot prints going out through the window.",
         "draw": [_ln(-286.4, 830.3, -281.2, 830.3)]},
    ],
    "foreground": [],
    "explains": [
        ["The slide", "The glacier's old drain, polished by years of melt water", "The grooves the same water scoured in the far wall beside it"],
        ["The crack and the kicker", "The drain's outlet, with a flake of ice wedged in its mouth", "The draught going down the crack, and the heap under it on the balcony"],
        ["The pillar's snow, where you start", "The head of the drain", "The paler wall behind it, toward the window"],
        ["The rope", "A rope somebody hung from the window", "The axe it is tied to at the back of the sill, and the window's daylight"],
        ["The air under the flight", "The whole height of the ice cave", "Two of the ones who tried in the wall, and the frog's light on the floor"],
    ],
    "pieces": [
        ["Back wall bay", "4 m wide, 5 m tall", "40", "Background", "kit: back wall bay"],
        ["Paler wall bay", "4 m wide, 5 m tall", "4", "Background", "kit: paler wall bay (added below)"],
        ["Frost rim for the window", "4.5 m by 4.5 m", "1", "Background", "kit: frost rim (added below)"],
        ["The town's torn paper; candle lantern", "3 m; 0.5 m", "1 and 1", "Background", "kit: papel_tatters; candle lantern"],
        ["Scoured grooves", "paint, two lines 12 m long", "1", "Background", "new, this area only: painted on the back wall bays"],
        ["Blue rib", "2.2 m and 1.2 m wide, 30.7 m tall", "2", "Background", "kit: blue rib"],
        ["Frozen climber deep in the ice", "0.9 m by 1.9 m", "2", "Background", "kit: frozen climber deep in the ice"],
        ["Kicker: a flake of ice wedged in a crack", "face 1.8 m long", "1", "Play space", "kit: kicker"],
        ["Hemp rope, frozen stiff", "16 m", "1", "Play space", "kit: hemp rope"],
        ["Ice axe as the rope's anchor; frozen rope coil", "0.7 m; 0.6 m", "1 and 1", "Background", "kit: what they carried"],
        ["Falling icicle in its growing stages; its roof crack; splinters", "0.6 m across; crack 0.8 m", "1", "Play space", "kit: falling icicle"],
        ["Wind lines", "an effect", "the bowl", "All", "kit: wind lines"],
        ["Firm snow cap, with boot prints", "2.5 m pillar; 5.6 m sill", "2", "Play space", "kit: firm snow cap"],
    ],
    "effects": [
        "The draught: wavy lines across the bowl, and snow smoking east off the kicker's lip.",
        "A long hiss as you slide, and no sound at all while you fly.",
        "The rope creaks and swings when you take it, and frost falls off it.",
        "The town's paper at the window streaming outward.",
    ],
    "notes": [
        "Note 89: the bowl's draught is drawn the loud way, as wavy lines, and the snow off the lip shows it too.",
        "Note 86: the cave's one falling icicle grows first and shatters on the floor.",
        "The sheet allows no icicle fringe in a room where an icicle falls. The row of small icicles on the cave's roof, which hangs inside the play space today, comes out.",
        "Scenery that moves: the rib at x -290.5 goes to x -293.6 and the rib at x -297.0 to x -299.6. The frozen climber in the wall at (-288.5, 821.0) goes to (-290.6, 818.4). The town's paper at the window goes 0.6 m back.",
        "Nothing you touch moves.",
    ],
}

# ------------------------------------------------------------------ 9.7 Ventisca
_FAR_CARD = [(-282.5, 826.5), (-274.6, 826.5), (-273.6, 829.2), (-275.4, 831.6), (-272.8, 834.0), (-271.6, 838.4), (-273.6, 840.2),
             (-274.4, 844.0), (-276.4, 846.2), (-277.2, 850.5), (-282.5, 850.5)]
_FLANK = [_p([(-281.0, 826.5), (-279.6, 826.5), (-279.9, 830.2), (-279.5, 834.5), (-281.0, 834.7)], "dark"),
          _p([(-282.5, 836.8), (-279.5, 834.75), (-279.3, 838.0), (-280.1, 841.5), (-279.8, 845.0), (-280.5, 848.4), (-278.8, 850.2), (-282.5, 850.0)], "dark"),
          _p([(-281.5, 838.2), (-280.0, 838.0), (-280.1, 838.35), (-281.5, 838.5)], "pale"),
          _p([(-281.3, 843.1), (-280.0, 842.9), (-280.1, 843.25), (-281.3, 843.4)], "pale"),
          _r(-285.5, 846.0, -282.5, 850.0, "solid"), _c(-281.3, 840.63, 0.2, "pale"), _c(-280.5, 840.49, 0.16, "pale")]
_H97 = [(-282.25, 837.8), (-282.25, 839.3), (-282.25, 840.8), (-282.25, 842.3), (-282.25, 843.8), (-282.25, 845.2)]

VENTISCA = {
    "id": "9.7", "slug": "9_7_ventisca", "title": "Ventisca", "kind": "challenge",
    "window": [-291.0, 826.5, -268.0, 850.5], "cut_y": 840.8, "climber": [-283.0, 830.2],
    "place": ("Out of the window, and the glacier's outer skin is over you: steep, dark and smooth, with a brow of ice jutting over "
              "the window like an eyebrow. This is the side of the tongue that the slide runs down, and from here on every miss is "
              "the slide. The way goes out under the brow by a blunt tusk of blue ice, over the brow on three plates, and 9 m "
              "straight up a wall on nubs of blue ice with one stone among them, to a snow niche under the mouth of the avalanche "
              "chute. The wall stands in the wind. It blows from the west for two seconds and peels you off the ice. It rests. Then "
              "it blows from the east and pins you. The ones who came this way stuck canes with paper flags into the snow shelves "
              "of the ice behind the route, and the flags tell you which wind is coming."),
    "keep": [
        "The tusk under the brow, the three plates on the brow, and the six holds up the wall: five nubs of blue ice and one stone, each where it is.",
        "The two winds, their strength and their six-second clock, and the still air below the brow and in the niche.",
        "The window's sill and the niche at 846 m.",
        "The fall: the skin, the lip, the tip, the whole slide.",
    ],
    "background": [
        {"name": "The valley, the ranges, the cloud", "z": [-8.0, -7.8], "style": "pale", "tag": [-269.8, 846.0],
         "text": "What is given, and already made: the painted valley far below with the tiny town, the two painted ranges, the cloud "
                 "banks close above. This is the first place you see it since the cableway, and the town is very small.",
         "draw": [_r(-282.5, 826.5, -268.0, 850.5)]},
        {"name": "The glacier's far side", "z": [-8.0, -7.9], "tag": [-276.4, 829.0], "top": True,
         "text": "One flat painted card, 45 m back: the rest of the glacier going away along the face. It is 90 m wide and 100 m tall, "
                 "in three rows of broken ice, the back row hazed to the sky, with snow in drifts along the foot of each row. Its "
                 "edge shows 4 to 10 m east of the wall you climb, cut into four or five big leaning towers. Mid blues and greys, "
                 "nothing near white, so the wind's white lines show against it.",
         "draw": [_p(_FAR_CARD)]},
        {"name": "The room you left", "z": [-3.0, -2.4], "tag": [-288.6, 832.5],
         "text": "Through the window: the ice cave's far wall, deep blue. From outside the window is a dark hole in the skin with "
                 "the town's paper streaming out of it.",
         "draw": [_r(-291.0, 826.5, -281.0, 834.7)]},
        {"name": "The flank of the tongue", "z": [-3.0, -1.5], "tag": [-280.0, 847.6], "top": True,
         "text": "The glacier's own side, 1.5 to 3 m behind the climb: dark ice in flat planes, reaching 2 to 3 m further east than "
                 "the wall you are on. It has two small snow shelves, each sloping and no wider than 1.5 m. It is why the wall is "
                 "not a blade standing in the air, and it is dark, so the pale holds show in front of it. One of its bands carries stones, at the height of the one stone you hold. The niche's back is the same ice.",
         "draw": _FLANK},
        {"name": "Three canes with paper flags", "z": [-1.8, -1.5], "tag": [-279.4, 844.9], "top": True,
         "text": "Bamboo canes 3 m tall with paper flags in the town's colours: one on each snow shelf of the flank, 1.5 m behind "
                 "the route, and one at the back of the niche. They are the wind's flags (note 89). Before a gust they drop slack "
                 "and then lift the new way. In the gust they stream flat.",
         "draw": _cane(-280.9, 838.3, 1) + _cane(-280.6, 843.2, 1) + _cane(-285.0, 846.0, 1)},
        {"name": "The town's paper and the window's lantern", "z": [-1.8, -1.4], "tag": [-283.7, 833.2],
         "text": "Along the top of the window: 3 m of the town's torn paper, another flag. Under the brow on the outer side: the "
                 "lit lantern that marks this as the way through. They are the same two as on the page before.",
         "draw": [_ln(-284.5, 834.3, -281.5, 834.3, "mark"), _c(-282.2, 833.6, 0.2, "light")]},
    ],
    "play": [
        {"name": "The tusk", "z": [-0.3, 0.3], "tag": [-279.6, 832.6],
         "text": "The first hold outside: a blunt hanging point of blue ice 3 m long, frosted, with no rings and no collar. It is "
                 "blue ice and not an icicle. It lets go after two seconds like any blue ice, and it never snaps off.",
         "draw": [_tusk(-280.6, 834.66, 831.6)]},
        {"name": "The one stone", "z": [-0.3, 0.3], "style": "mark", "tag": [-283.5, 840.8],
         "text": "The third hold up the wall is a grey stone, ringed here. It is the only place on this climb where you can wait "
                 "out a gust. The three plates on the brow and the five nubs are pale blue ice with frost on their top edges.",
         "draw": [_c(-282.25, 840.8, 0.45)]},
        {"name": "The wind", "z": [-1.2, 1.2], "style": "mark", "tag": [-277.0, 842.3],
         "text": "Long wavy white lines, each with a dark inked edge, across the whole of the wind's reach: from the brow's top to "
                 "just under the niche, and 7 m out from the wall (note 89). They run the way the wind runs. Before the wind "
                 "changes sides a front of lines crosses from the side it is coming from. Where the lines stop, the wind stops: "
                 "they curl and die under the niche and at the brow.",
         "draw": (_wavy(-279.0, -275.2, 836.2) + _wavy(-282.0, -275.2, 838.5) + _wavy(-282.0, -275.2, 840.05) +
                  _wavy(-282.0, -275.2, 841.55) + _wavy(-282.0, -275.2, 843.05) + _wavy(-282.0, -275.2, 844.5))},
    ],
    "foreground": [
        {"name": "The snow fringe on the brow", "z": [1.2, 1.4], "tag": [-283.3, 835.7],
         "text": "A thin strip of snow along the brow, in front of the brow's own ice and under its top edge. Today's strip lies "
                 "along the top edge itself, in front of the three plates you hold. It drops 0.4 m, so it covers ice and no hold.",
         "draw": [_p([(-282.45, 836.7), (-279.6, 834.75), (-279.6, 834.55), (-282.45, 836.3)])]},
    ],
    "explains": [
        ["The tusk", "Blue ice hanging from the underside of the brow", "The dark flank behind it, which it shows against"],
        ["The three plates and the five nubs", "A seam of blue ice coming out of the skin, over the brow and up the wall", "The flank's dark planes behind, and the cane beside each stretch"],
        ["The one stone", "A stone the glacier carries, at the skin's surface", "Two more stones of the same layer in the dark flank beside it"],
        ["The wind", "The wind off the glacier, meeting the wind up the valley", "The three canes' flags, the town's paper, the snow smoking off the brow"],
        ["The niche", "A hollow the wind has scooped under the chute's mouth", "Its cane, at the back"],
    ],
    "pieces": [
        ["The glacier's far side: one painted card", "90 m wide, 100 m tall, 45 m back", "1", "Background, far", "kit: the glacier's far side"],
        ["Flank piece: dark ice in flat planes, with one small sloping snow shelf", "3 m wide, 5 m tall", "4", "Background", "new, this area only; the sheet's layers ask for it"],
        ["Route cane with a paper flag", "3 m", "3", "Background", "kit: route cane (streamer_pole)"],
        ["The town's torn paper; candle lantern", "3 m; 0.5 m", "1 and 1", "Background", "kit: papel_tatters; candle lantern"],
        ["Blue ice tusk", "0.6 m across, 3 m long", "1", "Play space", "kit: blue ice tusk"],
        ["Blue ice plate; nub", "0.7 m by 0.2 m; 0.5 m", "3 and 5", "Play space", "kit: blue ice seam and its holds"],
        ["Stone in the ice", "0.5 m", "1", "Play space", "kit: stone in the ice"],
        ["Firm snow cap", "5.6 m sill; 3 m niche", "2", "Play space", "kit: firm snow cap"],
        ["Wind lines", "an effect", "10 m wide, 11.2 m tall", "All", "kit: wind lines"],
        ["Snow fringe for the brow", "3.4 m long, 0.4 m wide", "1", "Foreground", "there today, moved 0.4 m down"],
    ],
    "effects": [
        "The wind's wavy lines, and snow carried in them.",
        "Snow smoking off the brow's edge and the niche's edge, the way the wind is going.",
        "Before each gust: the flags drop, a whistle rises, a front of lines crosses.",
        "The climber's own loose limbs trail downwind.",
    ],
    "notes": [
        "Note 89: wind is drawn loudly. Wavy lines across the whole reach of the wind, and flags: three canes, the town's paper, snow off every edge.",
        "Note 84: every hold here but the stone is blue ice, and the button mark shivers on the limb that holds it.",
        "The snow strip on the brow stands in front of the three plates today. It moves 0.4 m down, to sit in front of ice only (notes 87 and 92, and the sheet's rule).",
        "In the play space today, and moved out of it: the town's paper over the window (0.6 m back).",
        "Nothing you touch moves.",
    ],
}

# ------------------------------------------------------------------ 9.8 La Avalancha, and the gap it drains (shared with 9.9 and 9.10)
def _P(s, n=0.0):
    """A point on the chute: s metres up it from its mouth, n metres off its floor."""
    return (-278.8 - 0.6428 * s + 0.7660 * n, 850.5 + 0.7660 * s + 0.6428 * n)


_GAP = [(-302.5, 878.7), (-296.0, 866.5), (-288.0, 861.5), (-286.5, 866.95), (-286.5, 871.8), (-295.9, 871.8), (-295.9, 881.0), (-302.0, 884.6)]
_HOLE = [_r(-304.5, 879.5, -302.5, 881.0, "dark")]
_HOLLOW = [_p([(-292.6, 865.6), (-292.2, 868.2), (-290.6, 869.3), (-288.6, 868.6), (-287.6, 866.6), (-288.2, 864.3), (-290.4, 864.2)], "dark"),
           _p([(-291.6, 865.4), (-290.6, 866.3), (-289.4, 865.9), (-288.6, 865.0), (-290.2, 864.6)], "pale")]
_KICKER = [(-290.8, 863.21), (-289.05, 863.45), (-289.05, 862.12)]
_SLAB_PATH = [_ln(-302.4, 880.2, -301.3, 879.8), _ln(-301.3, 879.8, -295.6, 867.0), _ln(-295.6, 867.0, -290.6, 863.9), _ln(-290.6, 863.9, -290.2, 866.4)]
_OUT_CARD = [(-282.5, 844.0), (-276.4, 844.0), (-275.2, 848.0), (-276.8, 852.0), (-275.0, 857.0), (-276.2, 862.0), (-274.8, 868.0),
             (-276.6, 874.0), (-275.4, 880.0), (-277.0, 887.5), (-282.5, 887.5)]
_ICE_BACKS = [_p([(-278.8, 850.5), (-288.0, 861.46), (-286.5, 866.95), (-280.0, 859.2)]), _r(-285.5, 846.0, -282.5, 850.0),
              _r(-286.5, 867.8, -283.5, 871.8), _r(-295.9, 873.3, -293.2, 877.3)]
_REST1, _REST2 = _P(3.55, 0.35), _P(8.35, 0.35)

LA_AVALANCHA = {
    "id": "9.8", "slug": "9_8_la_avalancha", "title": "La Avalancha", "kind": "challenge", "also": ["a10"],
    "window": [-306.0, 844.0, -274.0, 887.5], "cut_y": 862.6, "climber": [-284.0, 846.0],
    "place": ("Over the niche is the mouth of the chute: the drain of the gap between the glacier and the ridge. It is a trough of "
              "ice 50 degrees steep, roofed for its first 12 m by the foot of the glacier's top tower. Snow slabs let go under the "
              "ridge every five and a half seconds. They come out of a hole in the ice wall at the very top, slide down the open "
              "part of the chute, and at the foot of an old rope a flake of ice throws each one sideways into a hollow in the back "
              "wall, where it bursts. None comes further. What comes down the roofed part, where you climb, is the snow dust of "
              "each burst. The climb is the chute's floor: plates of blue ice, and two long stones frozen into the floor with ice "
              "glazed over their backs. Under the downhill end of each stone the rock is bare, and those are the two places to "
              "rest. Then the rope: 5.4 m of frozen hemp that somebody left, up to a niche in the tower's stem."),
    "keep": [
        "The tusk under the chute's mouth, the three nubs round the nose, and the eight plates of blue ice up the floor, each where it is.",
        "The two long stones, with the glaze over their backs and the bare rock under their downhill ends.",
        "The old rope, its stone horn, and the niche in the stem at 867.8 m.",
        "The slabs' timing: one every 5.5 seconds, with its warning. Notes 91 and 93 change where a slab starts and where it ends, and nothing else.",
        "The fall: down the chute, out of its mouth, the slide.",
    ],
    "background": [
        {"name": "The cloud and the valley", "z": [-8.0, -7.8], "style": "pale", "tag": [-275.2, 884.4],
         "text": "What is given. From 860 m up the cloud is close overhead and the light is flat and grey. Between the tower's tip "
                 "and the ridge it is all cloud.",
         "draw": [_r(-306.0, 844.0, -274.0, 887.5)]},
        {"name": "The glacier's far side", "z": [-8.0, -7.9], "tag": [-276.8, 866.0],
         "text": "The same painted card as behind Ventisca, 45 m back, its edge of leaning towers showing east of the chute's mouth and the tower's stem.",
         "draw": [_p(_OUT_CARD)]},
        {"name": "The ridge's rock, across the gap", "z": [-4.0, -2.4], "tag": [-293.6, 870.3], "top": True,
         "text": "Behind the open part of the chute: the mountain itself, 2.4 m back. Dark wet slate in long leaning slabs, dull "
                 "blue-grey, with rain marks. It is the first rock since the cableway, and it is the storm ridge's own piece. "
                 "Today a flat grey card stands here.",
         "draw": [_p(_GAP)]},
        {"name": "The ice behind the roofed chute and the niches", "z": [-3.0, -2.4], "tag": [-284.6, 862.6],
         "text": "Behind the roofed part of the chute and behind each niche: the glacier's banded ice, dark, because the tower's "
                 "foot is over it. Against it the pale plates of the climb show plainly. A scatter of smaller stones stands in it "
                 "behind the two long ones: they are the biggest of one layer of stones.",
         "draw": _ICE_BACKS + [_c(-282.0, 856.2, 0.2, "pale"), _c(-283.3, 857.6, 0.26, "pale"), _c(-284.4, 860.0, 0.2, "pale"), _c(-285.5, 860.7, 0.22, "pale")]},
        {"name": "The slab hole", "z": [-3.4, -1.2], "over": True, "tag": [-305.3, 880.25], "top": True,
         "text": "A dark mouth 1.4 m across in the ice wall at the top of the chute, under the ridge's ledge, with a lip of packed "
                 "snow (note 93). It is the end of the crack that runs along the foot of the ridge, where the ridge's snow piles "
                 "up. You see each slab in it before it comes.",
         "draw": _HOLE},
        {"name": "The hollow the slabs are thrown into", "z": [-5.4, -2.4], "tag": [-290.4, 870.5], "top": True,
         "text": "A hollow 4 m wide and 3 m deep in the back wall, beside the foot of the rope, where a slab of the slate has fallen "
                 "out (note 91). Each snow slab is thrown up into it and bursts there. A heap of broken snow lies in its floor, "
                 "and a white fan of burst marks covers its back.",
         "draw": _HOLLOW},
        {"name": "A cane in each niche", "z": [-1.8, -1.5], "tag": [-286.3, 847.6],
         "text": "At the back of the niche under the chute's mouth and of the niche in the stem: a cane with a paper flag. In the "
                 "niches the flags hang slack, and that is how you know a niche is out of the wind.",
         "draw": _cane(-285.0, 846.0, 1) + _cane(-284.3, 867.8, 1)},
        {"name": "The rest of the rope", "z": [-1.8, -1.3], "style": "line", "tag": [-285.6, 870.0],
         "text": "At the back of the stem's niche: a coil of the same hemp frozen flat, and an ice axe. Whoever left the rope sat here.",
         "draw": [_c(-285.4, 868.0, 0.22), _ln(-285.95, 867.8, -285.7, 868.55)]},
    ],
    "play": [
        {"name": "The kicker at the rope's foot", "z": [-1.2, 1.2], "tag": [-290.0, 861.6],
         "text": "New, from note 91: a flake of the glacier's dark ice wedged across the chute 2.4 m uphill of the rope, its face "
                 "1.8 m long and turned toward the back wall. Every slab rides up it and is thrown into the hollow. It is glossy "
                 "and slick, the same piece as the slide's kicker, and it is above the last hold of the climb.",
         "draw": [_p(_KICKER)]},
        {"name": "A slab's whole road", "z": [-0.6, 0.6], "style": "mark", "tag": [-299.5, 875.2],
         "text": "A slab shows in the hole's mouth, creeps out during its warning, tips onto the chute, slides 20 m down the open "
                 "part, hits the kicker and is thrown up and back. All of it is in view from the climb. The dashed line is that road.",
         "draw": _SLAB_PATH},
        {"name": "A slab in the mouth", "z": [-0.6, 0.6], "style": "pale", "tag": [-300.7, 881.5],
         "text": "A block of white snow 1 m across, exactly the size that is solid, with a square broken edge.",
         "draw": [_r(-302.5, 879.75, -301.5, 880.75)]},
        {"name": "The two rests", "z": [-0.4, 0.4], "style": "mark", "tag": [-279.7, 854.7],
         "text": "Ringed: the bare rock under the downhill end of each long stone. It is grey-brown and dry, under a little roof of "
                 "its own stone. With no slab coming down this far, these are plain rests: the two places on the climb where a "
                 "hand can stay. The stones' backs keep their glaze, and the plates on them are still blue ice.",
         "draw": [_c(round(_REST1[0], 2), round(_REST1[1], 2), 0.5), _c(round(_REST2[0], 2), round(_REST2[1], 2), 0.5)]},
        {"name": "The tusk under the mouth", "z": [-0.3, 0.3], "tag": [-281.1, 848.1],
         "text": "The first hold out of the niche: a blunt hanging point of blue ice, the same piece as at the window.",
         "draw": [_tusk(-282.1, 850.1, 847.7)]},
        {"name": "The old rope", "z": [-0.2, 0.2], "style": "mark", "tag": [-285.4, 861.6],
         "text": "Hemp, frozen stiff, tied to a horn of grey stone at the stem's corner. Its frayed end hangs 1.7 m above the "
                 "chute's floor and streams in whatever wind there is: another flag.",
         "draw": [_c(-286.62, 861.5, 0.3)]},
    ],
    "foreground": [],
    "explains": [
        ["The plates of blue ice up the chute", "A seam of blue ice in the chute's floor", "The dark ice behind the roofed chute, which they show against"],
        ["The two long stones", "The two biggest stones the glacier carries, frozen into the drain's floor", "The smaller stones of the same layer, in the dark ice behind them"],
        ["The snow slabs", "The ridge's snow, pushed out of the crack at the ridge's foot", "The hole they come out of, and the hollow they burst in"],
        ["The kicker (new, note 91)", "A flake of ice wedged across the drain", "The hollow in the slate behind it, white with burst snow"],
        ["The old rope", "A rope somebody left", "Its coil and an axe at the back of the niche above"],
        ["The two niches", "Hollows the wind has scooped in the ice", "A cane with a slack flag in each"],
    ],
    "pieces": [
        ["The ridge's flank: leaning slate slabs, dull blue-grey", "sections 12 m wide, 12 m tall", "2", "Background", "the storm ridge's kit: the ridge's flank"],
        ["Back wall bay, dark, with stones", "4 m wide, 5 m tall", "6", "Background", "kit: back wall bay"],
        ["Slab hole, with a snow lip", "1.4 m across, 2 m deep", "1", "Background, cut into the wall", "kit: slab hole (note 93)"],
        ["The hollow the slabs are kicked into, with its heap", "4 m wide, 3 m back", "1", "Background", "kit: the hollow (note 91)"],
        ["Snow slab", "1 m", "one at a time", "Play space", "kit: snow slab"],
        ["Kicker: a flake of ice wedged in a crack", "face 1.8 m long", "1", "Play space", "kit: kicker"],
        ["Ice in pieces: a slab's", "pieces 0.2 to 0.5 m", "as they burst", "Background", "kit: ice in pieces"],
        ["Long stone with a glazed back", "3.4 m long, 1 m thick", "2", "Play space", "new, this area only: the kit's stone at its biggest; the course builds them today"],
        ["Blue ice tusk; nub; plate", "tusk 2.4 m long; nub 0.45 m; plate 0.72 m", "1, 3 and 8", "Play space", "kit: blue ice tusk; blue ice seam and its holds"],
        ["Hemp rope, frozen stiff, on a stone horn", "5.4 m", "1", "Play space", "kit: hemp rope; stone in the ice"],
        ["Frozen rope coil; ice axe", "0.6 m; 0.7 m", "1 and 1", "Background", "kit: what they carried"],
        ["Route cane with a paper flag", "3 m", "2", "Background", "kit: route cane (streamer_pole)"],
        ["The glacier's far side: one painted card", "90 m wide, 100 m tall, 45 m back", "1", "Background, far", "kit: the glacier's far side"],
    ],
    "effects": [
        "A slab coming: a creak in the hole and a tick, the slab creeping out, a hiss down the chute, a thump on the kicker, a burst in the hollow.",
        "After each burst, snow dust pours down the roofed chute past you and out of its mouth. It pushes nothing. It is the avalanche you climb under.",
        "Fine snow blowing down the whole gap all the time.",
        "The rope's frayed end and the niches' flags.",
    ],
    "notes": [
        "Note 93: the slabs come out of a hole in the wall at the top of the chute, and each is seen in the hole before it comes.",
        "Note 91: a kicker at the rope's foot throws each slab into the background, into a hollow where it bursts. No slab reaches the climb below.",
        "Course change, as those two notes ask: one new slick flake on the chute's floor, from x -290.8 to x -289.05, 2.4 m uphill of where the rope hangs and above the last hold. The slabs start at the wall, 1.3 m west of where they start today.",
        "Note 91: the two long stones shelter you from nothing now, so they are plain rests. They do not move and are not made bigger.",
        "The name: the avalanche is still here to see and hear. It comes down the open chute in view, bursts beside the rope, and its dust comes down over the climb.",
        "Note 84: the button mark shivers on a limb that holds blue ice. It does not on the stones or the rope.",
    ],
    "ask": [
        "The two long stones: bare rock only under their downhill ends, as today, so the climb between them stays on cold ice. Or bare on their backs too, which is easier? This design keeps them as today.",
    ],
}

# ------------------------------------------------------------------ 9.9 Cornisa de Hielo
_N99 = [-288.5, -290.2, -291.9, -293.6, -295.2]

CORNISA = {
    "id": "9.9", "slug": "9_9_cornisa_de_hielo", "title": "Cornisa de Hielo", "kind": "challenge", "also": ["a10"],
    "window": [-300.0, 859.0, -277.0, 884.0], "cut_y": 871.4, "climber": [-285.4, 867.8],
    "place": ("The glacier ends at the top in a tower shaped like a mushroom: a stem on the east, and a cornice that curls 12 m west "
              "over the gap. This is the cornice's underside: a flat roof of dark ice, 9.4 m from the niche to its lip, with 8 m of "
              "air under it, then the chute, then the slide. The cornice has cracked through in five places, and each crack has "
              "healed with blue ice. Where each seam comes out underneath there is a nub. The five nubs, 1.7 m apart, are the only "
              "holds, and each lets go after two seconds, so you cannot stop. Under you the snow slabs come down the chute and "
              "burst in their hollow. At the far end you go round the lip and into a second niche, under the tower's tip."),
    "keep": [
        "The tusk at the niche's mouth, the five nubs under the roof, and the one on the lip, each where it is.",
        "Every one of them is blue ice and lets go after 2 seconds. There is no stone on this roof.",
        "The two niches, at 867.8 m and 873.3 m.",
        "The fall: 8 m of air, the chute, its mouth, the slide.",
    ],
    "background": [
        {"name": "The cloud", "z": [-8.0, -7.8], "style": "pale", "tag": [-278.2, 880.6],
         "text": "What is given: cloud close overhead, grey, and under it the valley very far down. The light here is flat, with almost no shadow.",
         "draw": [_r(-300.0, 859.0, -277.0, 884.0)]},
        {"name": "The glacier's far side", "z": [-8.0, -7.9], "tag": [-279.0, 862.2],
         "text": "The painted card 45 m back, east of the stem. From here you see only its top row of towers, hazed to the sky.",
         "draw": [_p([(-282.5, 859.0), (-277.8, 859.0), (-278.5, 864.0), (-277.3, 869.0), (-278.6, 875.0), (-277.5, 880.0), (-278.8, 884.0), (-282.5, 884.0)])]},
        {"name": "The ridge's rock, across the gap", "z": [-4.0, -2.4], "tag": [-296.4, 868.9], "top": True,
         "text": "Behind the air under the cornice: the storm ridge's wet slate in leaning slabs, dull blue-grey, 2.4 m back. It is "
                 "darker than the cloud and duller than the ice, so the five pale nubs and the climber show against it.",
         "draw": [_p(_GAP)]},
        {"name": "The ice behind the niches", "z": [-3.0, -2.4], "tag": [-284.4, 864.0],
         "text": "Behind each niche and behind the roofed part of the chute: banded ice, dark.",
         "draw": _ICE_BACKS},
        {"name": "Five seams through the cornice", "z": [-2.4, -1.2], "style": "pale", "over": True, "tag": [-290.2, 874.9], "top": True,
         "text": "Five pale bands, half a metre wide, seen through the dark ice of the cornice: the healed cracks. Each comes "
                 "straight down to one of the nubs. From the niche you can count the holds by counting the bands, and you can see "
                 "that the cornice is six blocks stuck together.",
         "draw": [_r(x - 0.25, 871.8, x + 0.25, (873.0 if x < -293.2 else 875.4)) for x in _N99]},
        {"name": "The hollow, and the slabs bursting", "z": [-5.4, -2.4], "tag": [-293.6, 867.4],
         "text": "Below and behind: the hollow in the slate that the snow slabs are thrown into, 6 m under the roof. A slab bursts "
                 "in it every five and a half seconds while you cross. It cannot reach you. It is La Avalancha's, drawn here "
                 "because it is what is under your feet.",
         "draw": _HOLLOW},
        {"name": "A cane in each niche", "z": [-1.8, -1.5], "tag": [-292.6, 876.0],
         "text": "A cane with a paper flag at the back of each niche. You leave one flag and cross to the other.",
         "draw": _cane(-284.0, 867.8, 1) + _cane(-293.6, 873.3, -1)},
    ],
    "play": [
        {"name": "The tusk at the niche's mouth", "z": [-0.3, 0.3], "tag": [-287.9, 870.2],
         "text": "A blunt hanging point of blue ice 2.4 m long: the way from the niche's floor up to the roof. The same piece as at the window.",
         "draw": [_tusk(-286.9, 871.85, 869.5)]},
        {"name": "The five nubs", "z": [-0.3, 0.3], "style": "mark", "tag": [-289.35, 870.5],
         "text": "Pale blue ice, frosted, half a metre across, each standing 0.3 m down out of the roof at the foot of its seam. "
                 "They are the palest things under the cornice.",
         "draw": [_c(x, 871.5, 0.42) for x in _N99]},
        {"name": "The lip", "z": [-0.3, 0.3], "style": "mark", "tag": [-297.3, 872.3],
         "text": "One more nub on the cornice's west edge, 1.1 m above the roof. It turns you round the lip and onto the snow of the second niche.",
         "draw": [_c(-296.2, 872.6, 0.42)]},
    ],
    "foreground": [
        {"name": "The snow fringe on the tower's top", "z": [1.2, 1.5], "tag": [-286.5, 874.62],
         "text": "A strip of snow along the tower's sloping top, in front of the tower's own ice and under its top edge. Today's "
                 "strip runs all the way up to the tip, in front of the last frozen climber's boots, and the snow cornice model "
                 "sits inside the play space. The strip is cut back to end 4 m short of the tip, and both move to sit in front of ice only.",
         "draw": [_p([(-291.5, 878.2), (-280.3, 870.73), (-280.3, 870.2), (-291.5, 877.7)])]},
    ],
    "explains": [
        ["The five nubs under the roof", "The lower ends of five healed cracks in the cornice", "The five pale seams going up through the dark ice above them"],
        ["The tusk, and the nub on the lip", "The same blue ice, where a seam comes out at an edge", "The dark ice round them"],
        ["The roof (it cannot be held)", "The underside of the glacier's top tower", "The ridge's slate behind the air under it"],
        ["The two niches", "Hollows the wind has scooped in the stem and under the tip", "A cane with a flag in each"],
        ["The air under you", "The gap between the glacier and the ridge", "The chute, and the hollow where the slabs burst"],
    ],
    "pieces": [
        ["The ridge's flank: leaning slate slabs, dull blue-grey", "sections 12 m wide, 12 m tall", "2", "Background", "the storm ridge's kit: the ridge's flank"],
        ["Back wall bay, dark", "4 m wide, 5 m tall", "4", "Background", "kit: back wall bay"],
        ["Blue ice seam, seen through the cornice", "0.5 m wide, 1.2 to 3.6 m tall", "5", "Background", "kit: blue ice seam"],
        ["Blue ice nub", "0.5 m", "6", "Play space", "kit: blue ice seam and its holds"],
        ["Blue ice tusk", "0.5 m across, 2.4 m long", "1", "Play space", "kit: blue ice tusk"],
        ["Route cane with a paper flag", "3 m", "2", "Background", "kit: route cane (streamer_pole)"],
        ["Firm snow cap", "3 m and 2.7 m", "2", "Play space", "kit: firm snow cap"],
        ["Snow cornice; snow fringe", "6 m; 11 m long, 0.5 m wide", "1 and 1", "Foreground, in front of solid ice", "kit: snow cornice; the fringe is there today, cut back"],
        ["The glacier's far side: one painted card", "90 m wide, 100 m tall, 45 m back", "1", "Background, far", "kit: the glacier's far side"],
    ],
    "effects": [
        "The button mark shivers on each hand in turn: you watch two of them at once.",
        "Frost falling from a nub as it lets go.",
        "Under you: a slab's hiss, thump and burst, and its dust blowing down the chute.",
        "Fine snow streaming off the cornice's lip.",
    ],
    "notes": [
        "Note 84: this is the climb the shiver is for. Five holds of two seconds each, and nothing else to tell you how long you have.",
        "Notes 91 and 93: the slabs now end in the hollow under this roof, so the whole road of a slab is in view from here.",
        "Notes 87 and 92: the snow on the tower's top is cut back from the tip and sits in front of ice only. The snow cornice model is inside the play space today, 0.8 m in front. It moves to 1.2 m.",
        "The rope coil and the axe in the first niche are on La Avalancha's page.",
        "Nothing you touch moves.",
    ],
}

# ------------------------------------------------------------------ 9.10 El Rimaye
_HORN = [(-296.45, 882.81), (-297.51, 881.75), (-295.95, 880.19), (-294.89, 881.25)]

EL_RIMAYE = {
    "id": "9.10", "slug": "9_10_el_rimaye", "title": "El Rimaye", "kind": "challenge", "also": ["a10"],
    "window": [-314.0, 868.5, -288.0, 892.5], "cut_y": 881.7, "climber": [-294.4, 873.3],
    "place": ("The top of the glacier. Between the ice and the ridge's rock there is a gap, 6.3 m wide at the top, where the ice has "
              "pulled away from the mountain as it creeps downhill. Its floor is the chute, and the hole the snow slabs come out of "
              "is in its far wall. From the niche you go up the last 8 m of ice, on a tusk and two nubs, to the tower's tip. One of "
              "the ones who tried is there. He is frozen leaning out over the gap, his boots in the ice of the tip, one mitten "
              "stretched toward the ledge he never reached. His mitten is the last hold on the glacier, and the launch: one fling, "
              "7 m across and 3.4 m up, onto the storm ridge. What you fly at is a cabin with a lamp in it."),
    "keep": [
        "The tusk, the two nubs, and the frozen climber with his three grips, each exactly where it is.",
        "The fling from his mitten: 7 m west and 3.4 m up, to the ledge at 886 m. The first metre of the ledge is glazed.",
        "Nothing within 2.3 m of his mitten but his own body and the tip under his boots: the swing is open below, west and above.",
        "The fall: the gap, the chute, the mouth, the slide, the lip.",
    ],
    "background": [
        {"name": "The cloud", "z": [-8.0, -7.8], "style": "pale", "tag": [-290.0, 889.8],
         "text": "What is given: grey cloud, close, filling the frame above the glacier's top. The storm cloud card that stood in "
                 "front of this place is gone (note 92). All cloud here is behind you.",
         "draw": [_r(-302.5, 868.5, -288.0, 892.5)]},
        {"name": "The ridge's rock, across the gap", "z": [-4.0, -2.4], "tag": [-298.6, 874.6], "top": True,
         "text": "The mountain, 2.4 m back, behind the whole gap: wet slate in leaning slabs. It is the storm ridge's piece, and it "
                 "runs on up behind the ledge.",
         "draw": [_p(_GAP)]},
        {"name": "The slab hole", "z": [-3.4, -1.2], "over": True, "tag": [-305.4, 880.25], "top": True,
         "text": "In the ice wall under the ledge you are flinging to: the dark mouth the snow slabs come out of (note 93). One "
                 "shows in it every five and a half seconds, 6 m under your flight.",
         "draw": _HOLE},
        {"name": "The horn at his back", "z": [-2.4, -1.2], "tag": [-297.75, 881.0], "top": True,
         "text": "The last frozen climber has ice at his back like the others: a horn of the cornice, dull mid blue, leaning out "
                 "over the gap at the angle he leans. It stops at the back edge of the play space. Nothing is in front of him. "
                 "Today it is a pale card 0.9 m back.",
         "draw": [_p(_HORN), _p(_HORN, "line")]},
        {"name": "The last cane, and his lantern", "z": [-1.8, -1.4], "tag": [-293.2, 882.7],
         "text": "On the tower's top behind him: the last cane of the route, its paper flag streaming, and a lit candle lantern "
                 "hung on it at head height. The lantern lights him and his mitten. From the niche below, that light is where you are going.",
         "draw": _cane(-294.3, 880.1, -1, sky=True) + [_c(-294.3, 881.9, 0.2, "light")]},
        {"name": "The second niche", "z": [-3.0, -1.5], "tag": [-292.4, 875.3],
         "text": "Banded ice at the back of the niche under the tip, and the cane you crossed the cornice to.",
         "draw": [_r(-295.9, 873.3, -293.2, 877.3)] + _cane(-293.6, 873.3, -1)},
        {"name": "On the ledge: the storm ridge's prayer pole and cabin", "z": [-3.4, -1.2], "tag": [-310.2, 888.7],
         "text": "The ridge's rock under its prow, and on the ledge the first prayer pole, 4 m tall, its paper streaming. The pole is "
                 "there today. The storm ridge's sheet puts the keeper's cabin beside it, 4.3 m wide, with one lamp and a frog "
                 "(note 94). Both are that ridge's. The cabin is outlined here only so the two pages agree: its lamp is what you fling toward.",
         "draw": [_r(-312.0, 886.0, -302.5, 892.5, "solid"), _r(-308.8, 886.0, -304.5, 888.6, "line"), _c(-306.0, 887.7, 0.18, "light"),
                  _ln(-309.0, 886.0, -309.0, 890.0, "line"), _p([(-309.0, 890.0), (-307.9, 889.75), (-309.0, 889.5)], "pale"),
                  _p([(-309.0, 889.3), (-308.0, 889.05), (-309.0, 888.8)], "pale")]},
    ],
    "play": [
        {"name": "His mitten", "z": [-0.3, 0.3], "style": "mark", "tag": [-298.4, 883.4],
         "text": "Bone-white wool, a lump 0.35 m across, at the end of an arm at full stretch. It points at the ledge. His body and "
                 "mask are frost grey. His boots and belt are warm like the mitten. He is the same piece as the six in the cave.",
         "draw": [_c(-297.17, 882.57, 0.42)]},
        {"name": "The fling", "z": [-0.3, 0.3], "style": "mark", "tag": [-300.9, 887.9],
         "text": "The line of the fling, from the course's own numbers. It is drawn here only to show the place. Under it is the "
                 "gap, lit grey to its floor, so you see what a miss costs before you let go.",
         "draw": [_ln(-297.17, 882.57, -299.0, 885.3), _ln(-299.0, 885.3, -300.9, 886.9), _ln(-300.9, 886.9, -302.6, 887.0), _ln(-302.6, 887.0, -304.2, 886.0)]},
        {"name": "The tusk and two nubs", "z": [-0.3, 0.3], "tag": [-297.0, 876.2],
         "text": "A blunt tusk of blue ice at the niche's mouth, 2.4 m long, and two nubs on the face above it. The last blue ice on the mountain.",
         "draw": [_tusk(-295.75, 877.35, 874.95), _c(-296.2, 878.6, 0.4, "mark"), _c(-296.2, 879.9, 0.4, "mark")]},
        {"name": "The glazed nose of the ledge", "z": [-1.2, 1.2], "style": "line", "tag": [-302.3, 888.0],
         "text": "The first metre of the ledge is a lump of clear ice over rock: dark and glossy with a white glint, the mountain's "
                 "look for a thing you cannot hold. The firm snow starts behind it. You land past it.",
         "draw": [_ln(-302.9, 886.75, -301.75, 886.0)]},
    ],
    "foreground": [],
    "explains": [
        ["The last frozen climber", "One of the ones who tried, on the glacier's very top, reaching for the ridge", "The horn of ice at his back, and the cane and lantern behind him"],
        ["His mitten, the launch", "The end of his reach", "The ledge it points at, 7 m off, and the cabin's lamp on it"],
        ["The tusk and two nubs", "Blue ice where a seam comes out on the tower's west face", "The dark ice of the tip"],
        ["The gap under the fling", "Where the ice has pulled away from the mountain", "The ridge's slate behind it, and the hole the slabs come out of"],
        ["The ledge you land on (the storm ridge's)", "The foot of the ridge", "Its prayer pole, and in that ridge's design the keeper's cabin"],
    ],
    "pieces": [
        ["Frozen climber you can hold: reaching, leaned 45 degrees", "1.8 m; each grip 0.35 m", "1", "Play space", "kit: frozen climber you can hold"],
        ["Ice at a frozen climber's back, as a leaning horn", "1.5 m wide, 2.2 m tall, 1.2 m deep", "1", "Background", "kit: ice at a frozen climber's back (added below)"],
        ["Route cane with a paper flag; candle lantern", "3 m; 0.5 m", "2 canes, 1 lantern", "Background", "kit: route cane; candle lantern"],
        ["Blue ice tusk; nub", "0.5 m across, 2.4 m long; 0.46 m", "1 and 2", "Play space", "kit: blue ice tusk; blue ice seam and its holds"],
        ["The ridge's flank: leaning slate slabs", "sections 12 m wide, 12 m tall", "2", "Background", "the storm ridge's kit: the ridge's flank"],
        ["Slab hole, with a snow lip", "1.4 m across", "1", "Background, cut into the wall", "kit: slab hole (note 93)"],
        ["Back wall bay, dark", "4 m wide, 5 m tall", "1", "Background", "kit: back wall bay"],
        ["Clear ice over the ledge's nose", "1.2 m", "1", "Play space", "kit: glacier body; the course builds it today"],
        ["Prayer pole; the keeper's cabin", "4 m; 4.3 m wide", "1 and 1", "Background", "the storm ridge's kit: prayer_pole, the keeper's cabin"],
    ],
    "effects": [
        "His lantern flickers. Its amber is on him and nowhere else.",
        "The last cane's flag and the prayer pole's paper stream the same way.",
        "A slab leaving the hole under you as you hang from his mitten.",
        "On the far side: the cabin's lamp and its smoke, the storm ridge's.",
    ],
    "notes": [
        "Note 92: nothing stands in front of the last frozen climber or his mitten. The storm cloud card goes, and the snow strip on the tower's top is cut back 4 m from the tip (see Cornisa de Hielo).",
        "Note 87: the ice is at his back. The pale card behind him today is inside the play space. It becomes the horn, from 1.2 m back.",
        "Note 94: the ledge becomes the keeper's cabin with a frog in it. That is the storm ridge's design, and its sheet says the cabin's light is seen from here.",
        "Note 93: the slab hole is in this picture, under the ledge.",
        "New scenery: the last cane and the lantern on it, 1.5 m behind the tip.",
        "Nothing you touch moves.",
    ],
}

AREAS = [UNDER_THE_LIP, HIELO_AZUL, CARAMBANOS, PUENTE_DE_NIEVE, LA_CUEVA, SNOW_HOLE, EL_SERAC, TOBOGAN, VENTISCA, LA_AVALANCHA, CORNISA, EL_RIMAYE]

# ------------------------------------------------------------------ pieces these areas add to the biome's kit
KIT_MORE = [
    ["Paler wall bay: the back wall bay painted two steps paler, for where daylight comes through", "4 m wide, 5 m tall",
     "round every way out: the door of the ice cave, the gap at the shelf's broken end, the balcony's lip, the chimney, the window", "Background", "new, a second painting of the back wall bay"],
    ["Frost rim: a band of white frost round a way out", "0.3 m wide, cut to suit",
     "the door of the ice cave and the window in the skin", "Background", "new"],
    ["Ice at a frozen climber's back: a slab of dull mid-blue ice that runs back to the far wall", "1.7 m wide, 3 m tall, 1.2 m deep",
     "behind each of the seven you can hold, in place of the pale card the game stands there today (note 87)", "Background", "new"],
]
