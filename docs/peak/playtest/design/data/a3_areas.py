# The crystal cave's areas, one dict each. Format: see ../build.py.
# Order: the frog's room beside the place you come in, then the ten challenges as you meet them.
#
# How the sketches are drawn in this file:
#   filled shapes   the near wall: rock ribs, the roots of the crystals you hold (within 3 m behind you)
#   outlines        far things: giant crystals and mirror faces (4 m and more behind you)
#   yellow dots     the bright crystals that light a place
import math


# ------------------------------------------------------------------ helpers for drawing
def _r(v):
    return round(v, 2)


def _spike(x, y, ang, length, w, st=None):
    """A pointed crystal from the side: its root at (x, y), pointing along ang degrees."""
    c, s = math.cos(math.radians(ang)), math.sin(math.radians(ang))
    nx, ny = -s, c
    sh = length * 0.72
    pts = [[_r(x - nx * w / 2), _r(y - ny * w / 2)], [_r(x + c * sh - nx * w / 2), _r(y + s * sh - ny * w / 2)],
           [_r(x + c * length), _r(y + s * length)], [_r(x + c * sh + nx * w / 2), _r(y + s * sh + ny * w / 2)],
           [_r(x + nx * w / 2), _r(y + ny * w / 2)]]
    return ["poly", pts, {"style": st}] if st else ["poly", pts]


def _fan(x, y, size, angs, st=None):
    """A cluster: one long point and shorter ones, fanned out from one root."""
    out = []
    for i, a in enumerate(angs):
        k = 1.0 if i == 0 else (0.62, 0.78, 0.55, 0.7)[i % 4]
        out.append(_spike(x, y, a, size * k, size * 0.24 * max(k, 0.7), st))
    return out


def _blob(cx, cy, rx, ry, seed=0.0, st=None):
    """A collar of rough rock: an uneven round shape."""
    pts = []
    for i in range(10):
        a = 2 * math.pi * i / 10
        k = 0.86 + 0.14 * math.sin(i * 2.3 + seed)
        pts.append([_r(cx + rx * k * math.cos(a)), _r(cy + ry * k * math.sin(a))])
    return ["poly", pts, {"style": st}] if st else ["poly", pts]


def _hexstep(cx, top, wt=2.2, w=3.4):
    """The outline of one step of Primer Destello, as the course has it."""
    yt = top - 0.15
    return [[cx - wt / 2, yt], [cx - w / 2, yt - 0.75], [cx - wt / 2, yt - 1.5], [cx + wt / 2, yt - 1.5], [cx + w / 2, yt - 0.75], [cx + wt / 2, yt]]


def _star(pts):
    """A crystal's point seen end-on: a line from each corner to the middle."""
    cx = sum(p[0] for p in pts) / len(pts)
    cy = sum(p[1] for p in pts) / len(pts)
    return [["line", _r(p[0]), _r(p[1]), _r(cx), _r(cy)] for p in pts]


def _arc(cx, cy, r, a0, a1, n=12, st="mark"):
    """Part of a circle, as short lines. Angles in degrees, measured from straight down."""
    out = []
    for i in range(n):
        ta, tb = math.radians(a0 + (a1 - a0) * i / n), math.radians(a0 + (a1 - a0) * (i + 1) / n)
        out.append(["line", _r(cx + r * math.sin(ta)), _r(cy - r * math.cos(ta)), _r(cx + r * math.sin(tb)), _r(cy - r * math.cos(tb)), {"style": st}])
    return out


# ------------------------------------------------------------------ 3.0 the frog's room
_HOLLOW = [[-459.0, 176.0], [-461.3, 176.0], [-461.75, 176.5], [-461.9, 177.3], [-461.7, 178.1], [-461.2, 178.6], [-460.5, 178.8],
           [-459.8, 178.7], [-459.3, 178.45], [-459.0, 178.2]]
_HC = (-460.4, 177.4)
_lining = []
for _p in _HOLLOW[1:]:
    _lining.append(["line", _p[0], _p[1], _r(_p[0] + (_HC[0] - _p[0]) * 0.33), _r(_p[1] + (_HC[1] - _p[1]) * 0.33)])
_rind = []
_out = [[_r(_HC[0] + (p[0] - _HC[0]) * 1.26), _r(max(176.0, _HC[1] + (p[1] - _HC[1]) * 1.26))] for p in _HOLLOW[1:]]
for _i in range(len(_out) - 1):
    _rind.append(["line", _out[_i][0], _out[_i][1], _out[_i + 1][0], _out[_i + 1][1]])

LA_GEODA_DE_LA_RANA = {
    "id": "3.0", "slug": "3_0_la_geoda_de_la_rana", "title": "La Geoda de la Rana", "kind": "rest",
    "window": [-467.0, 169.0, -444.0, 186.0], "screen": [-455.5, 179.0], "cut_y": 177.2, "climber": [-457.5, 176.0],
    "place": ("The frog's room. It is a geode: a hollow ball of stone, 3 m across inside, lined with crystal points, that sat whole inside "
              "the cave's west wall. At some time the face of the wall broke away here and took a slice off the geode's side. The slice lies "
              "on the floor behind. What is left in the wall is a round room with one side open, and the frog lives in it. The room is on the "
              "short piece of floor west of the hole you come up through: the side of the hole nobody has a reason to go to. You hear the frog "
              "croak as you come off the rungs."),
    "keep": [
        "The hole, the rungs up through it, and the two pieces of floor either side of it stay exactly as they are.",
        "The wall above the room stays glass that can't be held.",
        "The room adds one thing: a level floor 2.3 m long inside the wall, at the height of the floor outside, behind a way in 2.2 m tall. It is not on the way to anywhere.",
    ],
    "background": [
        {"name": "The inside of the geode", "z": [-3.0, -1.2], "style": "dark", "over": True, "tag": [-460.3, 177.75],
         "text": "A round hollow in the wall rock, 2.9 m across and 2.8 m tall, cut away at the front like every room you can walk into: floor, back and roof, no front wall. Its back is the far half of the same ball.",
         "draw": [["poly", _HOLLOW]]},
        {"name": "The lining", "z": [-2.8, -1.2], "style": "line", "over": True, "tag": [-461.45, 178.75],
         "text": "Short crystal points all round the inside, every one pointing at the middle. They are clear and deep violet, with a faint light of their own. The room is the only place in the cave where crystal is on every side of you.",
         "draw": _lining},
        {"name": "The frog", "z": [-2.2, -1.6], "style": "light", "over": True, "tag": [-460.3, 176.75],
         "text": "It sits on a stump of crystal at the back of the room and looks at itself in one clear face, 0.9 m tall (note 60). It breathes, blinks, turns to watch you, and croaks.",
         "draw": [["rect", -461.2, 176.0, -460.7, 176.36, {"style": "pale"}], ["circle", -460.95, 176.52, 0.16], ["line", -461.6, 176.45, -461.45, 177.35, {"style": "line"}]]},
        {"name": "The room's light", "z": [-2.4, -1.6], "style": "light", "over": True, "tag": [-459.75, 178.3],
         "text": "One bright white point hanging from the top of the hollow. There is no lantern: the frog's lamp is a crystal, like every light in the cave.",
         "draw": [["circle", -460.4, 178.42, 0.15]]},
        {"name": "The rind", "z": [-3.0, -1.2], "style": "mark", "over": True, "tag": [-462.3, 178.9],
         "text": "The geode's shell shows on the wall's face as rings of banded stone round the way in, dark blue-grey, the way a cut geode shows its rings. It tells you from across the hole that this is a geode and not a cave mouth.",
         "draw": _rind},
        {"name": "The slice that broke off", "z": [-2.8, -1.4], "tag": [-457.5, 176.95],
         "text": "The side of the geode, lying hollow side up on the back edge of the short floor like a dish 2.4 m across, lined with the same points. It is why the room is open. It replaces the cluster that stands here today.",
         "draw": [["poly", [[-458.7, 176.0], [-456.3, 176.0], [-456.15, 176.75], [-456.75, 176.3], [-458.25, 176.3], [-458.85, 176.75]]]]},
        {"name": "A mirror face over the hole", "z": [-4.6, -4.3], "style": "line", "tag": [-452.8, 182.6],
         "text": "A clear face 4 m wide on the hall's back wall, straight behind the top of the rungs. The first thing the cave shows you is yourself, small, climbing out of the floor. The game has this face today.",
         "draw": [["poly", [[-454.9, 179.6], [-451.0, 179.2], [-450.6, 185.4], [-454.4, 185.7]]], ["line", -454.2, 181.0, -451.4, 184.4]]},
        {"name": "A giant, far back", "z": [-8.0, -5.0], "style": "line", "tag": [-448.2, 183.5],
         "text": "One of the cave's far crystals, bigger than a house, dim and blue, standing on the hall floor well behind everything. It is there today.",
         "draw": [["poly", [[-449.6, 176.0], [-445.2, 176.0], [-446.2, 186.0], [-449.9, 186.0]]]]},
    ],
    "play": [
        {"name": "The room's floor", "z": [-1.2, 1.2], "style": "pale", "tag": [-460.1, 175.6],
         "text": "New. Crystal has filled the bottom of the geode level, and its top is frosted and pale like the floor outside, so it reads as somewhere to stand. It is the only new thing to stand on in the whole biome, and only the room needs it.",
         "draw": [["rect", -461.3, 175.85, -459.0, 176.0]]},
        {"name": "The way in", "z": [-1.2, 1.2], "style": "line", "tag": [-458.6, 177.6],
         "text": "Where the wall's face cuts the geode: an opening 2.2 m tall, so you walk in upright. Its edge is the broken rind, rough and pale for a hand's width, then the wall's dark glass above.",
         "draw": [["line", -459.0, 176.0, -459.0, 178.2]]},
        {"name": "The kerb by the hole", "z": [-0.4, 0.4], "style": "line", "tag": [-448.0, 177.2],
         "text": "Today a small white box on the east edge of the hole. It becomes a short rough point of pale crystal, the same size, standing up out of the floor.",
         "draw": [["rect", -448.95, 176.0, -448.45, 176.6]]},
    ],
    "foreground": [],
    "explains": [
        ["The short floor west of the hole", "The hall's frosted floor, cut off from the rest by the hole", "The slice of the geode lying on its back edge"],
        ["The room's floor", "Crystal that has filled the bottom of the geode level", "The hollow, lined with points, and the frog on its stump"],
        ["The way in", "Where the geode's side broke away with the face of the wall", "The rind's rings round the opening, and the slice on the floor outside"],
    ],
    "pieces": [
        ["The frog's room: the inside of a split geode, cut away at the front, with its floor", "2.9 m across, 2.8 m tall, 2.4 m deep", "1", "Background, with its floor in the play space", "kit: the frog, and its room"],
        ["The frog, on a crystal stump", "frog 0.3 m; stump 0.5 m", "1", "Background", "kit: the frog"],
        ["Rings of banded stone round the way in", "0.4 m wide", "1", "Background", "new, this area only"],
        ["Geode slice, lying hollow side up", "2.4 m across, 0.8 m tall", "1", "Background", "new, this area only"],
        ["Bright white point, hanging", "0.5 m", "1", "Background", "kit: roof points, the smallest, lit"],
        ["Clear face the frog looks in", "0.9 m tall", "1", "Background", "kit: mirror face, a small one"],
        ["Mirror face over the hole", "4 m by 6 m", "1", "Background", "kit: mirror face"],
        ["Far crystal", "4.5 m wide, 24 m tall", "1", "Background", "kit: giant far crystal"],
        ["Short rough point for the kerb", "0.5 m by 0.6 m", "1", "Play space", "kit: wall point, the smallest, standing upright"],
    ],
    "effects": [
        "The frog's croak, heard from the top of the rungs and from anywhere on the hall floor near the hole.",
        "A few motes of glitter turning slowly in the room's light.",
        "The frog's reflection in its clear face moves when the frog does.",
    ],
    "notes": [
        "Note 60: one frog hidden in every biome, in a small room you can walk into. This is the crystal cave's.",
        "Note 60's first idea for this biome had the frog admiring itself in a clear face. It still does, inside the geode.",
    ],
    "ask": [
        "The frog's room is in the cave's west wall, on the short floor west of the hole you come up through. To reach it you fling 7 m back across the hole from the top of the rungs, and a miss drops you about 10 m into the lake behind the dam. Is that the right place for it?",
    ],
}

# ------------------------------------------------------------------ 3.1 Primer Destello
_STEPS = [(-412.6, 178.35, 2.2, 3.4), (-417.5, 180.58, 2.2, 3.4), (-422.4, 182.81, 2.2, 3.4), (-427.3, 185.04, 2.2, 3.4),
          (-432.2, 187.27, 2.2, 3.4), (-437.5, 189.5, 3.0, 4.2)]
_STEP_FANS = [[125, 50, 205, -28], [118, 44, 212, -35], [130, 58, 200, -22], [122, 48, 208, -30], [128, 54, 203, -26], [40, 112, -30, 150]]

_rib31 = [["poly", [[-409.5, 176.0], [-409.5, 177.8], [-442.5, 192.55], [-442.5, 189.15], [-413.2, 176.0]]],
          ["line", -409.5, 176.06, -442.5, 190.85, {"style": "mark"}]]
_roots31, _ends31 = [], []
for (_cx, _top, _wt, _w), _angs in zip(_STEPS, _STEP_FANS):
    _roots31 += _fan(_cx, _top - 0.9, 2.9 if _w < 4 else 3.3, _angs)
    _ends31 += _star(_hexstep(_cx, _top, _wt, _w))

# the giant clear crystal whose top face is the mirror of 3.2: it stands on the hall floor behind the stair
_MIRROR_GIANT_FOOT = [[-436.23, 176.0], [-429.93, 176.0], [-437.57, 194.0], [-443.87, 194.0]]

PRIMER_DESTELLO = {
    "id": "3.1", "slug": "3_1_primer_destello", "title": "Primer Destello", "kind": "challenge",
    "window": [-450.0, 172.0, -407.0, 194.0], "screen": [-420.0, 180.5], "cut_y": 179.7, "climber": [-415.0, 176.0],
    "place": ("The foot of the great hall. You come up out of the hole onto a floor of frosted crystal and walk east along it, under a "
              "stair of six crystals, to where the floor ends against La Rampa: one face of glass, 35 degrees steep and 60 m high, the side "
              "of the biggest crystal in the cave. Everything that falls anywhere in the cave slides down that face and stops here. The stair "
              "climbs back west over your head. It follows a crack in the back wall where water once came through. Along the crack six fat "
              "crystals have grown straight out of the wall towards you, each a little higher than the last, and you stand on their ends. At "
              "the west end of the floor one climber stands frozen with an arm up, under the mirror he fell from."),
    "keep": [
        "The six places to stand, each exactly where it is and the size it is: five tops 2.2 m wide and the sixth 3 m wide, each with its two sloping shoulders. Each fling stays 2.7 m across and 2.2 m up.",
        "The tops and shoulders can be held. The three under-faces of each step can't, and neither can the sixth step's west shoulder.",
        "The floor, La Rampa's foot, and the frozen climber where he stands.",
    ],
    "background": [
        {"name": "The crack, and the rib of rock along it", "z": [-3.0, -1.6], "tag": [-429.75, 185.2], "top": True,
         "text": "A dark split in the back wall, rising west at the stair's own angle, with a ridge of rough dark rock standing 1.5 m out of the wall along it. Water came through here, and every crystal on the stair grew out of it. Tiny points fringe the crack all the way up. You can read where the stair goes from the crack before you see the steps.",
         "draw": _rib31},
        {"name": "The six roots", "z": [-3.0, -1.2], "style": "pale", "tag": [-424.6, 185.6], "top": True,
         "text": "Behind each step, where it breaks out of the rib: three or four smaller points fanned out round its root, up, down and to the sides, on a collar of rock. They are what makes a step read as a crystal and not a pod (note 26). They are 1.5 m and more behind you, bluer and dimmer than the step, and can't be reached.",
         "draw": _roots31},
        {"name": "The foot of the mirror crystal", "z": [-7.0, -4.0], "style": "line", "tag": [-436.0, 180.0],
         "text": "A clear crystal 6 m thick stands on the hall floor behind the top of the stair and leans west and out towards you as it rises. Its top is El Espejo, the next challenge. Down here it is far back, dim and blue.",
         "draw": [["poly", _MIRROR_GIANT_FOOT]]},
        {"name": "A second giant, further back", "z": [-8.0, -5.0], "style": "line", "tag": [-418.0, 186.5],
         "text": "Leaning the other way, with a faint light inside it. With the mirror crystal it makes the far wall of the hall. Both are there today.",
         "draw": [["poly", [[-424.0, 176.0], [-418.0, 176.0], [-412.6, 192.6], [-414.6, 194.0], [-418.6, 192.9]]]]},
        {"name": "The bright cluster under the stair", "z": [-2.8, -1.4], "style": "pale", "tag": [-428.9, 178.2],
         "text": "The one bright white crystal of this area: a cluster 5 m tall on the back edge of the floor, under the third and fourth steps. It lights the stair from below, so the glass under-faces of the steps glint and the frosted tops stay pale. Two small dim clusters stand further along the floor's back edge.",
         "draw": _fan(-427.0, 176.0, 4.8, [90, 68, 113, 47, 132]) + [["circle", -427.0, 178.4, 0.32, {"style": "light"}]] + _fan(-419.0, 176.0, 1.5, [90, 60, 120]) + _fan(-409.0, 176.0, 1.3, [95, 65])},
        {"name": "A mirror face behind the frozen climber", "z": [-3.6, -3.3], "style": "line", "tag": [-445.6, 181.9],
         "text": "A clear face 4.5 m wide on the back wall behind him. It shows his back, and it shows you, small, as you walk past him. It is the cave's first close look at your own reflection.",
         "draw": [["poly", [[-446.6, 176.0], [-442.0, 176.0], [-441.2, 182.6], [-445.6, 183.2]]], ["line", -445.4, 177.4, -442.4, 181.6]]},
        {"name": "His rope, and the broken glass", "z": [-2.4, -1.3], "style": "pale", "tag": [-441.3, 177.0],
         "text": "A coil of old rope on the floor behind his feet: the only rope in the cave. Round it lie long shards of clear glass, the sheared-off foot of the mirror 14 m overhead. He came down with it.",
         "draw": [["circle", -444.7, 176.3, 0.28, {"style": "line"}], ["poly", [[-443.0, 176.0], [-441.2, 176.0], [-441.9, 176.5]]], ["poly", [[-441.0, 176.0], [-439.8, 176.0], [-440.1, 176.7]]],
                  ["poly", [[-446.3, 176.0], [-445.3, 176.0], [-446.0, 176.45]]]]},
    ],
    "play": [
        {"name": "The six ends", "z": [-1.2, 1.2], "style": "line", "tag": [-417.5, 181.4],
         "text": "Each step becomes the end of a fat pale crystal that comes out of the wall at you and stops in a low blunt point, seen end-on (note 26). The top face and the two upper faces are rough pale lilac, frosted, and look like rock: they are where you stand and hold. The three under-faces are clear indigo glass. Same places, same sizes.",
         "draw": _ends31},
        {"name": "The one who tried", "z": [-0.4, 1.2], "style": "mark", "tag": [-443.4, 180.3],
         "text": "The frozen climber, where the course has him: standing on the floor straight under the mirror's foot, one arm reaching up at it. Clear crystal has grown up round him in a shell 3.6 m tall, and you see him through it. The shell is glass: it can't be held.",
         "draw": [["poly", [[-444.5, 176.0], [-442.3, 176.0], [-442.5, 178.6], [-443.4, 179.6], [-444.3, 178.6]]]]},
        {"name": "A drift of chips at La Rampa's foot", "z": [-1.2, 1.2], "style": "pale", "tag": [-411.6, 176.9],
         "text": "Drawn on the floor where the glass slope meets it: a low drift of crystal chips and glitter, swept down by everything that has ever fallen in the cave. Nothing to trip on. It marks the place a fall leaves you.",
         "draw": [["poly", [[-413.6, 176.0], [-410.3, 176.0], [-410.3, 176.3], [-411.6, 176.2]]]]},
    ],
    "foreground": [
        {"name": "Two dark points in the bottom corner", "z": [1.3, 2.2], "style": "dark", "tag": [-448.6, 172.8], "top": True,
         "text": "Rising from the bottom left corner of the frame, in front of the floor's own thickness, with their tips below the top of the floor. They cover nothing you walk on. They are the cave's only kind of foreground, and most areas above this one have none (note 40).",
         "draw": [_spike(-448.9, 172.0, 82, 3.4, 1.2), _spike(-447.0, 172.0, 100, 2.5, 0.9)]},
    ],
    "explains": [
        ["The six steps", "The ends of six fat crystals that grew out of one crack in the wall", "Each one's root on the rib, with its fan of smaller points, and the crack running through all six"],
        ["The floor", "The hall's own floor, frosted over", "Its back edge at the foot of the wall, with the bright cluster and two small ones standing on it"],
        ["La Rampa's foot", "The low end of one face of the biggest crystal in the cave", "The drift of chips where the face meets the floor"],
        ["The frozen climber", "One who tried: he fell from the mirror with the piece of it he was on", "His rope, the broken glass round his feet, the mirror face that shows his back, and the mirror crystal leaning overhead"],
    ],
    "pieces": [
        ["Wall point, rough lilac on top and clear below, ending in a blunt point", "3.4 m across, 1.5 m tall, 4 m long", "5", "Play space, rooted in the background", "kit: wall point (note 26)"],
        ["The same, wider", "4.2 m across, 1.5 m tall, 4 m long", "1", "Play space, rooted in the background", "kit: wall point, the largest"],
        ["Root fan: three or four small points on a rock collar", "3 m across", "6", "Background", "kit: cluster on a rock collar, grown sideways"],
        ["Crack with its rib of rock", "36 m long, rib 3.4 m wide", "1", "Background", "kit: seep crack (new, added to the kit)"],
        ["Bright cluster on the floor", "4 m by 5 m", "1", "Background", "kit: crystal_cluster_b, lit"],
        ["Small cluster on the floor", "1 m by 1.5 m", "2", "Background", "kit: crystal_cluster_c"],
        ["Mirror face", "4.5 m by 7 m", "1", "Background", "kit: mirror face"],
        ["Far crystal", "6 m thick, 20 to 30 m long", "2", "Background", "kit: giant far crystal"],
        ["The frozen climber in his shell of clear crystal", "shell 2.4 m by 3.6 m", "1", "Play space", "in the game today: the statue and crystal_shell_clear"],
        ["Coil of old rope", "0.6 m", "1", "Background", "new, this area only"],
        ["Shard of clear glass, lying flat", "1 to 2 m", "3", "Background", "new; also the foot of El Espejo"],
        ["Chip drift, drawn on the floor", "3.3 m long", "1", "Play space (drawn on)", "new, this area only"],
        ["Dark corner point", "0.9 to 1.2 m across, 2.5 to 3.4 m tall", "2", "Foreground", "kit: dark corner point (new, added to the kit)"],
    ],
    "effects": [
        "A slow glint that travels across the under-faces of the steps as you walk beneath them.",
        "A drip now and then from the crack onto the floor, with a small bright ring where it lands.",
        "Your reflection, and the frozen climber's back, in the mirror face behind him.",
    ],
    "notes": [
        "Note 26 (not built yet): the six hexagon steps become pointed crystals jutting out of the back wall. Shown here as they will be: same places to stand, new shape.",
        "Note 27 (done): the floor's flicker was the climber's own lamp, and it is steadied. Nothing here puts two faces in the same place.",
        "Note 40 (done): the big dark slabs that stood in front of this floor are behind the climb now. The only foreground kept is the two low points in the corner.",
    ],
}

# ------------------------------------------------------------------ 3.2 El Espejo
_MD = (-math.cos(math.radians(67)), math.sin(math.radians(67)))   # up the mirror's face
_MN = (math.sin(math.radians(67)), math.cos(math.radians(67)))    # out of the face, up and east
_MT = (-445.0, 198.7)
_MF = (_MT[0] - _MD[0] * 9.1, _MT[1] - _MD[1] * 9.1)


def _on_face(s, out=0.0):
    return [_r(_MF[0] + _MD[0] * s + _MN[0] * out), _r(_MF[1] + _MD[1] * s + _MN[1] * out)]


_NUBS32 = [_on_face(s, 0.1) for s in (0.5, 2.2, 3.95, 5.6, 7.4)]
_MIRROR_GIANT = [[-436.23, 176.0], [-429.93, 176.0], [-439.9, 199.5], [-444.6, 203.6], [-446.85, 201.0]]
_SHARDS = [["poly", [[-443.0, 176.0], [-441.2, 176.0], [-441.9, 176.5]]], ["poly", [[-441.0, 176.0], [-439.8, 176.0], [-440.1, 176.7]]],
           ["poly", [[-446.3, 176.0], [-445.3, 176.0], [-446.0, 176.45]]]]
_R2_FAN = _fan(-446.5, 197.4, 2.8, [150, 95, 215])
_R1_FAN = _fan(-437.5, 188.6, 3.3, [40, 112, -30, 150])

EL_ESPEJO = {
    "id": "3.2", "slug": "3_2_el_espejo", "title": "El Espejo", "kind": "challenge",
    "window": [-455.0, 174.0, -431.0, 204.5], "screen": [-442.5, 191.0], "cut_y": 194.0, "climber": [-438.2, 189.5],
    "place": ("A giant clear crystal stands on the hall floor behind the stair and leans west, and out towards you, as it rises. By the top "
              "of the stair its upper face has come forward into the climb. That face is the mirror: 9 m of indigo glass at 67 degrees, smooth "
              "enough to show you your own face. Glass can't be held. But five ribs of rough pale crystal have grown across the face, one above "
              "another like the rungs of a ladder laid on it, and their near ends are the five nubs you climb. The lower third of the face has "
              "sheared off, which is why its foot hangs out over nothing, 2.4 m from the last step. The piece that broke lies in shards on the "
              "hall floor 14 m below, round the feet of the climber who was on it."),
    "keep": [
        "The mirror slab: its place, its lean of 67 degrees, its length of 9.1 m, and that its face can't be held.",
        "The five nubs on the face and the loose nub before its foot, each exactly where it is. Every reach stays near the limit.",
        "The foot hangs 2.4 m out from the sixth step, over a 14 m drop to the hall floor.",
        "The two rests: the sixth step below, and the crystal at the top with its glass west lip. The mirror's broken top edge can be held.",
    ],
    "background": [
        {"name": "The mirror crystal", "z": [-6.0, -1.3], "tag": [-434.6, 183.0], "top": True,
         "text": "The whole of the giant: clear, six-sided, 6 m thick and 30 m long, rooted where the back wall meets the hall floor and ending in a point above the top rest. Far back and dim at its foot, close behind you at its top. The slab you climb is the one face of it that reaches the play space.",
         "draw": [["poly", _MIRROR_GIANT]]},
        {"name": "Its broad face, which shows you", "z": [-1.5, -1.3], "style": "pale", "tag": [-441.2, 196.6], "top": True,
         "text": "Beside the slab the giant turns a flat face 2.6 m wide towards the camera, just behind your back as you climb. It is a mirror too. Your reflection climbs beside you, a little smaller than you, the whole way up.",
         "draw": [["poly", [_on_face(0.3), _on_face(8.8), _on_face(8.8, 2.6), _on_face(0.3, 2.6)]]]},
        {"name": "The five ribs, running back", "z": [-2.6, -1.2], "style": "dark", "tag": [-442.0, 193.5], "top": True,
         "text": "Each nub is the near end of a rib of rough crystal 0.4 m thick that lies across the glass and runs 2.5 m back along the face, like a rung. From the side you see only its end. They are the mirror's version of the roots: the thing you hold carries on behind.",
         "draw": [["circle", p[0], p[1], 0.36] for p in _NUBS32]},
        {"name": "The roots of the two rests and the loose nub", "z": [-3.0, -1.2], "style": "pale", "tag": [-449.2, 199.4],
         "text": "The top rest and the sixth step are the ends of fat pale crystals like the stair's, each with its fan of smaller points on a rock collar where it leaves the wall. The loose nub is the tip of one thin point with a small collar of its own.",
         "draw": [_blob(-446.5, 197.3, 2.5, 1.9, 0.4, "solid")] + _R2_FAN + _R1_FAN + _fan(-440.5, 190.2, 1.1, [205, 255])},
        {"name": "The bright crystal that lights the face", "z": [-2.8, -1.6], "style": "pale", "tag": [-436.7, 199.6],
         "text": "One bright white cluster on the back wall, level with the top of the mirror and east of it. Its light rakes along the glass, so each rib throws a short shadow and stands out, and the glass itself shows one hard white glint.",
         "draw": _fan(-438.0, 197.6, 1.9, [80, 45, 115]) + [["circle", -438.0, 198.4, 0.3, {"style": "light"}]]},
        {"name": "The hall floor, 14 m down", "z": [-2.4, -1.3], "style": "pale", "tag": [-440.4, 177.6],
         "text": "Straight under the foot: the frozen climber, his coil of rope, and the shards of the piece that broke (all described in 3.1). The camera shows them at the bottom of the screen while you are on the lowest nubs, so you see what a slip costs and who paid it.",
         "draw": _SHARDS + [["circle", -444.7, 176.3, 0.28, {"style": "line"}]]},
        {"name": "The far hall", "z": [-8.0, -5.0], "style": "line", "tag": [-452.4, 188.0],
         "text": "One more giant, far back and blue, on the west side. It is there today.",
         "draw": [["poly", [[-455.0, 176.0], [-449.6, 176.0], [-449.0, 196.5], [-451.4, 199.8], [-454.6, 197.4]]]]},
    ],
    "play": [
        {"name": "The glass face", "z": [-1.2, 1.2], "style": "mark", "tag": [-444.9, 195.4],
         "text": "Deep indigo, mirror-smooth, with a white glint down its length. It is the cave's plainest picture of what can't be held, and it is 9 m of your route.",
         "draw": [["line"] + _on_face(0.2, 0.03) + _on_face(8.9, 0.03)]},
        {"name": "The five rungs and the loose nub", "z": [-1.2, 1.2], "style": "pale", "tag": [-443.2, 191.2],
         "text": "Each nub is drawn as the worn end of its rib: rough, frosted, pale lilac, six-sided, standing a hand's width proud of the glass. The loose nub before the foot is the same crystal, by itself.",
         "draw": [["circle", p[0], p[1], 0.24] for p in _NUBS32] + [["circle", -440.5, 190.2, 0.24]]},
        {"name": "The sheared foot", "z": [-1.2, 1.2], "style": "line", "tag": [-442.9, 189.3],
         "text": "The slab's lower end is a fresh break: flat, bright at the edge, a little stepped. Below it there is only air where the rest of the face used to be.",
         "draw": [["line", _r(_MF[0]), _r(_MF[1]), _r(_MF[0] - _MN[0] * 0.8), _r(_MF[1] - _MN[1] * 0.8)]]},
        {"name": "The top rest's wet lip", "z": [-1.2, 1.2], "style": "mark", "tag": [-449.0, 197.4],
         "text": "Water drips onto the west lip of the top rest from the roof crystal above, and the lip has a skin of new clear crystal: glass, where the rest of the top is frosted. It is why this rest is not quite safe.",
         "draw": [["circle", -447.8, 198.3, 0.42]]},
    ],
    "foreground": [],
    "explains": [
        ["The mirror slab", "One flat face of a giant clear crystal that leans out of the back of the hall", "The rest of the giant: 6 m thick, running down behind the stair to its root at the foot of the wall"],
        ["The five nubs", "The near ends of five rough ribs that lie across the glass like rungs", "Each rib running 2.5 m back along the face"],
        ["The loose nub", "The tip of one thin rough crystal", "Its small collar of rock on the wall"],
        ["The foot over nothing", "Where the lower third of the face sheared off", "The shards on the hall floor, 14 m down, round the frozen climber"],
        ["The sixth step and the top rest", "The ends of two fat pale crystals", "Their root fans on the wall; the top rest shares its collar with the mirror crystal's point"],
        ["The broken top edge", "Where the face stops against the top rest", "The mirror crystal's point, 5 m higher, behind"],
    ],
    "pieces": [
        ["The mirror crystal: clear, six-sided, with one face forward as the slab", "6 m thick, 30 m long", "1", "Background, its top face in the play space", "kit: giant far crystal, with a mirror face"],
        ["Rough rib across a clear face", "0.4 m thick, 2.5 m long", "5", "Play space, running back into the background", "kit: rough rib (new, added to the kit)"],
        ["Thin wall point for the loose nub", "0.4 m across, 3 m long", "1", "Play space, rooted in the background", "kit: wall point, the smallest"],
        ["Wall point for the top rest", "3 m across, 2.4 m tall", "1", "Play space, rooted in the background", "kit: wall point"],
        ["Root fan on a rock collar", "3 m across", "2", "Background", "kit: cluster on a rock collar, grown sideways"],
        ["Bright cluster on the wall", "2 m", "1", "Background", "kit: crystal_cluster_c, grown sideways, lit"],
        ["Shard of clear glass, lying flat", "1 to 2 m", "3", "Background", "new; shared with 3.1"],
        ["Far crystal", "5 m wide, 24 m tall", "1", "Background", "kit: giant far crystal"],
    ],
    "effects": [
        "Your reflection in the broad face behind you, climbing as you climb.",
        "A slow white glint that slides up the slab as the camera rises.",
        "The drip on the top rest's west lip, falling from the roof crystal above.",
    ],
    "notes": [
        "Notes 26 and 30 ask for the cave's holds to be the pale purple crystal that looks like rock. The nubs, the top edge and the two rests are drawn that way here.",
        "Note 40 (done): nothing stands in front of the mirror.",
    ],
}

# ------------------------------------------------------------------ 3.3 Candelabros
def _roof_w(x):
    """The underside of the roof over the start hall, as the course has it."""
    return 210.2 + 0.5333 * (x + 443.8)


_CHAND = [-443.8, -437.8, -431.8]
_R3_FAN = _fan(-425.75, 207.7, 2.8, [150, 95, -40])
_far_lamps = []
for _x in (-449.8, -440.8, -434.8):
    _far_lamps.append(["circle", _x, _r(_roof_w(_x) - 0.45), 0.45, {"style": "line"}])
for _x in (-440.8, -434.8):
    _far_lamps.append(["rect", _x - 0.8, _r(_roof_w(_x) - 2.2), _x + 0.8, _r(_roof_w(_x) - 0.95)])
    _far_lamps.append(["circle", _x, _r(_roof_w(_x) - 1.6), 0.28, {"style": "light"}])

CANDELABROS = {
    "id": "3.3", "slug": "3_3_candelabros", "title": "Candelabros", "kind": "challenge",
    "window": [-452.0, 195.0, -420.0, 222.5], "screen": [-437.8, 206.5], "cut_y": 208.0, "climber": [-446.2, 198.7],
    "place": ("The top of the start hall, under its sloping roof. The floor you walked in on is 23 to 30 m straight down. This is the first "
              "place in the cave where somebody has been before you. The people who built the temple higher up came down here for crystal, "
              "and they hung chandeliers under this roof to light the hall while they worked. Three are left on the line you cross. Each is a "
              "ring of bright crystal points on a bronze chain, and each chain hangs from a carved stone pug let into the roof. They still "
              "give light. Everything else in sight grew here."),
    "keep": [
        "Three chandeliers, 6 m apart, each hung 3.2 m higher than the last, on chains 8.7 m long from the roof.",
        "The chains and the chandeliers can be held. The roof and the knobs the chains hang from can't.",
        "The rest at each end: the crystal above the mirror, and the one before the geode with its frosted west face.",
        "The glass crystal hanging from the roof east of the last chandelier, which stops you flying over the geode.",
    ],
    "background": [
        {"name": "The lamp line, going back", "z": [-6.0, -3.5], "style": "pale", "tag": [-449.8, 204.9], "top": True,
         "text": "The same carved bosses carry on along the roof behind the three you use. Two still hold their chandeliers, hauled up tight under the roof so no chain shows, glowing white. One is an empty bronze ring. Nothing thin hangs behind the climb: a far chain would read as one more thing to catch.",
         "draw": _far_lamps},
        {"name": "A mirror face that doubles the lights", "z": [-4.6, -4.3], "style": "line", "tag": [-434.6, 201.4],
         "text": "A clear face 5 m wide on the back wall, below the second and third chandeliers. When a chandelier swings, its light swings in the face, and so do you.",
         "draw": [["poly", [[-437.4, 197.6], [-432.6, 198.2], [-432.0, 203.0], [-436.6, 202.4]]], ["line", -436.6, 198.6, -433.0, 202.0]]},
        {"name": "An offering niche at the top rest", "z": [-3.0, -2.6], "style": "dark", "tag": [-447.7, 200.9],
         "text": "A carved hollow 0.6 m tall in the back wall at head height, with a small crystal set in it and a ring of jade round the crystal. It is the first temple work you see close up. One stands beside every piece of temple work in the cave.",
         "draw": [["rect", -447.0, 199.9, -446.4, 200.6]]},
        {"name": "The roots of the two rests", "z": [-3.0, -1.2], "style": "pale", "tag": [-423.6, 206.0],
         "text": "Each rest is the end of a fat pale crystal, with its fan of smaller points on a rock collar where it leaves the wall, like the steps of the stair.",
         "draw": [_blob(-446.5, 197.3, 2.5, 1.9, 0.4, "solid"), _blob(-425.75, 207.6, 2.6, 1.9, 1.1, "solid")] + _R2_FAN + _R3_FAN},
        {"name": "The points of two giants, below", "z": [-8.0, -4.0], "style": "line", "tag": [-441.6, 196.4],
         "text": "The top of the mirror crystal, and one more further east. You are level with their points now. They are dim, blue and turned away from you.",
         "draw": [["poly", [[-446.85, 201.0], [-444.6, 203.6], [-439.9, 199.5], [-438.0, 195.0], [-444.3, 195.0]]],
                  ["poly", [[-431.0, 195.0], [-426.6, 195.0], [-427.2, 199.4], [-428.9, 201.6]]]]},
    ],
    "play": [
        {"name": "The three bosses", "z": [-0.6, 0.6], "style": "pale", "tag": [-438.9, 214.4],
         "text": "Today each chain hangs from a glass knob under the roof. Each knob becomes the temple's boss: a carved stone pug 0.9 m across holding a bronze ring in its mouth. Here the cave has grown a skin of clear crystal over the stone, so it is glossy and dark, and still reads as something you can't hold.",
         "draw": [["rect", _x - 0.45, _r(_roof_w(_x) - 0.35), _x + 0.45, _r(_roof_w(_x) + 0.55)] for _x in _CHAND]},
        {"name": "The chandeliers and their chains", "z": [-0.7, 0.7], "style": "pale", "tag": [-445.6, 201.6],
         "text": "As the game has them: a ring of crystal points on a bronze hoop, 1.2 m across, hung on bronze chain. The points are bright white, the brightest things in the hall. One small ring of jade sits where each chain meets its hoop. Chain in this cave always means you can hold it.",
         "draw": [["rect", _x - 0.7, _r(_roof_w(_x) - 0.3 - 8.7 - 1.2), _x + 0.7, _r(_roof_w(_x) - 0.3 - 8.7)] for _x in _CHAND] +
                 [["circle", _x, _r(_roof_w(_x) - 0.3 - 8.7 - 0.6), 0.26, {"style": "light"}] for _x in _CHAND]},
        {"name": "The far rest's frosted face", "z": [-1.2, 1.2], "style": "line", "tag": [-428.6, 207.2],
         "text": "The west face of the rest you land on is rough and pale under its lip, so a low catch still holds. It is the same rough lilac as every hold.",
         "draw": [["line", -427.5, 206.6, -427.5, 208.1]]},
    ],
    "foreground": [],
    "explains": [
        ["The three chandeliers", "Lamps the temple's people hung to light the hall while they worked", "More of the same line going back along the roof: two still lit, one empty ring"],
        ["The chains", "Bronze chain, the temple's", "The carved pug boss each one hangs from, let into the roof"],
        ["The rest you leave and the rest you land on", "The ends of two fat pale crystals", "Their root fans on the wall, and the offering niche beside the first"],
        ["The drop", "The whole height of the start hall", "The points of two giants below you, and your own small reflection among the lights"],
    ],
    "pieces": [
        ["Temple boss: carved stone pug with a bronze ring, under a skin of clear crystal", "0.9 m", "3 in the play space, 3 behind", "Play space, background", "kit: temple boss, glazed over (a new look, added to the kit)"],
        ["Crystal chandelier", "1.2 m across, 1.5 m tall", "3 to hold, 2 hauled up behind", "Play space, background", "kit: chandelier_crystal"],
        ["Bronze chain", "8.7 m", "3", "Play space", "kit: bronze chain"],
        ["Jade ring on a chain", "0.2 m", "3", "Play space (drawn on)", "new, small"],
        ["Offering niche", "0.6 m", "1", "Background", "kit: offering niche"],
        ["Mirror face", "5 m by 5 m", "1", "Background", "kit: mirror face"],
        ["Root fan on a rock collar", "3 m across", "2", "Background", "kit: cluster on a rock collar, grown sideways"],
        ["Far crystal's point", "6 m thick", "2", "Background", "kit: giant far crystal"],
    ],
    "effects": [
        "Each chandelier's light moves with it: the shadows of the roof crystals swing when it swings.",
        "A soft ring of glass notes when a chandelier is caught, like a wind chime.",
        "The start floor far below stays lit, so the drop can be read.",
    ],
    "notes": [
        "Note 40 (done): nothing stands in front of the chandeliers.",
        "The far chandeliers that hang behind this line today have chains. Here they are hauled up tight under the roof, so nothing that looks like a rope hangs behind the climb.",
    ],
}

# ------------------------------------------------------------------ 3.4 La Geoda
_GEO = (-420.4, 210.1)
_R4_FAN = _fan(-415.5, 213.6, 2.6, [20, -50, 80])
_geo_points = []
for _i in range(10):
    _a = math.radians(18 + 36 * _i)
    _geo_points.append(["line", _r(_GEO[0] + 2.4 * math.cos(_a)), _r(_GEO[1] + 2.4 * math.sin(_a)), _r(_GEO[0] + 1.75 * math.cos(_a)), _r(_GEO[1] + 1.75 * math.sin(_a)), {"style": "line"}])

LA_GEODA = {
    "id": "3.4", "slug": "3_4_la_geoda", "title": "La Geoda", "kind": "challenge",
    "window": [-431.0, 202.0, -409.0, 220.0], "screen": [-420.4, 210.5], "cut_y": 210.1, "climber": [-425.0, 208.8],
    "place": ("A geode is a hollow stone lined with crystal. This one is 6 m across. The temple's people cut it out of the back wall, sawed "
              "a notch in its side, and hung it on a stone axle so that it turns: three times a minute (note 29). Nobody knows what turns it, "
              "as nobody knows what turns the temple's machines. It is open towards you like a bowl on its side. You step in through the notch, "
              "walk its lining like the inside of a wheel, and step out through the notch when it comes round to the top, beside a broken spar "
              "of crystal that leads on. The round hole in the wall that the geode came out of is still there behind it."),
    "keep": [
        "The geode's place and size: 5 m across inside, with one gap 60 degrees wide.",
        "It turns the way it turns today, and after note 29 half as fast again: three turns a minute.",
        "Its rind can't be held. Its lining can.",
        "The spar over its crown, the rest beyond with its glass west lip, and the glass crystal hanging from the roof to the west.",
    ],
    "background": [
        {"name": "The socket it was cut from", "z": [-4.6, -3.0], "style": "dark", "tag": [-423.3, 213.1], "top": True,
         "text": "A round hollow in the back wall, 7.5 m across, a little bigger than the geode and straight behind it, like a cupped hand. Its inside is dark and lined with the stumps of points. You see it as a dark ring round the geode. It says the geode grew here and was taken out by somebody.",
         "draw": [["circle", _GEO[0], _GEO[1], 3.75]]},
        {"name": "The geode's back", "z": [-1.8, -1.2], "tag": [-420.4, 208.6], "top": True,
         "text": "The far half of the bowl, close behind you as you walk inside it: the same short points as the lining you stand on, bluer and dimmer, all pointing in at the middle. It turns with the rest.",
         "draw": [["circle", _GEO[0], _GEO[1], 2.45]] + _geo_points},
        {"name": "The hub: a temple boss on the axle's end", "z": [-3.2, -1.3], "style": "pale", "tag": [-420.4, 211.3], "top": True,
         "text": "The geode turns on a stone axle that runs back into the wall between two carved stone cheeks. From the front the geode hides them. What you see is the axle's end in the middle of the geode's back: a carved pug boss 0.9 m across with a bronze cap, going round with it. The pug turning over tells you how fast the geode turns and which way.",
         "draw": [["rect", -421.4, 209.4, -421.0, 210.8, {"style": "solid"}], ["rect", -419.8, 209.4, -419.4, 210.8, {"style": "solid"}], ["circle", _GEO[0], _GEO[1], 0.45]]},
        {"name": "An offering niche", "z": [-3.0, -2.6], "style": "dark", "tag": [-425.4, 211.9],
         "text": "In the back wall above the rest you start from, at head height: a carved hollow with a small crystal and a jade ring, the same as the one at the chandeliers.",
         "draw": [["rect", -425.0, 210.4, -424.4, 211.1]]},
        {"name": "The roots of the two rests and the spar", "z": [-3.0, -1.2], "style": "pale", "tag": [-413.0, 215.6],
         "text": "The rest you leave, the rest you reach and the spar between are the ends of pale crystals from the wall, each with its root fan. The spar is a thin flat one, snapped off short over the geode's crown.",
         "draw": [_blob(-425.75, 207.6, 2.6, 1.9, 1.1, "solid"), _blob(-415.6, 213.5, 2.6, 1.8, 2.0, "solid")] + _R3_FAN + _R4_FAN + _fan(-418.3, 214.05, 1.6, [95, 60])},
        {"name": "The bright crystal over the way out", "z": [-2.8, -1.6], "style": "pale", "tag": [-416.4, 218.1],
         "text": "One bright white cluster on the wall above the spar. The way out is the brightest place in the frame, so your eye goes to it while you wait for the gap to come round.",
         "draw": _fan(-417.6, 215.9, 1.9, [85, 50, 120]) + [["circle", -417.6, 216.7, 0.3, {"style": "light"}]]},
        {"name": "A mirror face under the geode", "z": [-4.6, -4.3], "style": "line", "tag": [-413.6, 205.6],
         "text": "A clear face on the back wall, low and to the east. It shows the geode's underside going round. It is there today, a little higher.",
         "draw": [["poly", [[-416.4, 202.6], [-411.6, 203.0], [-411.2, 208.0], [-416.0, 207.6]]], ["line", -415.6, 203.4, -412.2, 207.0]]},
    ],
    "play": [
        {"name": "The geode's two skins", "z": [-1.2, 1.2], "style": "mark", "tag": [-418.2, 207.4],
         "text": "Outside, the rind: smooth banded stone in dark blue-grey rings, glossy, which can't be held. Inside, the lining: a crust of short rough points in pale lilac, which can. The front edge is sawn flat and shows both skins as rings, like a cut geode on a shelf.",
         "draw": [["circle", _GEO[0], _GEO[1], 3.25], ["circle", _GEO[0], _GEO[1], 2.35]]},
        {"name": "The notch's two sawn lips", "z": [-1.2, 1.2], "style": "line", "tag": [-424.0, 209.9],
         "text": "The gap is not a break: it is cut. Its two ends are flat and straight, with saw marks, so it reads as a doorway somebody made. The lining's pale edge shows on each lip.",
         "draw": [["line", -422.48, 211.3, -423.17, 211.7], ["line", -422.48, 208.9, -423.17, 208.5]]},
        {"name": "The spar's broken end, and the far rest's wet lip", "z": [-1.2, 1.2], "style": "mark", "tag": [-419.4, 215.2],
         "text": "The spar ends in a rough pale break you can hold all round. The west lip of the rest beyond it is glass under a drip, like the lip above the mirror.",
         "draw": [["line", -419.6, 213.7, -419.6, 214.4], ["circle", -416.8, 213.95, 0.38]]},
    ],
    "foreground": [],
    "explains": [
        ["The geode", "A hollow stone the temple's people cut loose and hung on an axle", "The round socket in the wall it came out of, showing as a dark ring behind it"],
        ["The lining you walk on", "The crust of short points that lines every geode", "The geode's back, lined the same way, turning behind you"],
        ["The turning", "A stone axle in two carved cheeks, temple work", "The carved pug on the axle's end, going round in the middle of the geode's back"],
        ["The gap", "A notch sawn in the rind", "The two flat sawn lips; the offering niche that says who did it"],
        ["The spar and the two rests", "The ends of pale crystals from the wall", "Their root fans, and the bright cluster over the spar"],
    ],
    "pieces": [
        ["The geode: a bowl open at the front, banded rind, pale lining, one sawn notch", "6.1 m across, 2.4 m deep", "1", "Play space; its back is background", "in the game today: geode_wheel, to be given a back and a cut front edge"],
        ["Temple axle mount: two stone cheeks and a stone axle", "1.4 m", "1", "Background", "kit: temple axle mount"],
        ["Temple boss as the hub's cap", "0.9 m", "1", "Background", "kit: temple boss"],
        ["Socket in the wall", "7.5 m across, 1.5 m deep", "1", "Background", "new, this area only"],
        ["Offering niche", "0.6 m", "1", "Background", "kit: offering niche"],
        ["Thin flat wall point, snapped off, for the spar", "2.6 m by 0.7 m", "1", "Play space, rooted in the background", "kit: wall point, flat"],
        ["Root fan on a rock collar", "3 m across", "2", "Background", "kit: cluster on a rock collar, grown sideways"],
        ["Bright cluster on the wall", "2 m", "1", "Background", "kit: crystal_cluster_c, grown sideways, lit"],
        ["Mirror face", "5 m by 5 m", "1", "Background", "kit: mirror face"],
    ],
    "effects": [
        "A faint glow from the lining, so the inside of the geode is lighter than the wall round it.",
        "A low grinding from the axle, and a click each time the notch passes the top.",
        "A few grains of glitter shaken off the lining as it turns.",
    ],
    "notes": [
        "Note 29 (not built yet): the geode turns half as fast again, three turns a minute. The wait from stepping in to the gap reaching the top drops from 22 seconds to about 15.",
    ],
}

# ------------------------------------------------------------------ 3.5 Agujas
def _slot_y(x):
    """The sled's slot in the back wall: it follows the sled's own line, 24 m west and 4 m down."""
    return 211.8 + (x + 386.45) / 6.0


_R5_FAN = _fan(-385.5, 221.4, 2.6, [160, 220, 100])
_RIB35_TOP = [[-419.0, 213.6], [-415.3, 215.1], [-407.1, 218.75], [-398.1, 221.55], [-385.5, 222.9], [-380.0, 224.1]]
_RIB35_LOW = [[-380.0, 221.1], [-385.5, 219.9], [-398.1, 218.55], [-407.1, 215.75], [-415.3, 212.1], [-419.0, 210.6]]
_CRACK35 = [[-419.0, 212.1], [-415.3, 213.6], [-407.1, 217.25], [-398.1, 220.05], [-385.5, 221.4], [-380.0, 222.6]]
_rib35 = [["poly", _RIB35_TOP + _RIB35_LOW]]
for _i in range(len(_CRACK35) - 1):
    _rib35.append(["line", _CRACK35[_i][0], _CRACK35[_i][1], _CRACK35[_i + 1][0], _CRACK35[_i + 1][1], {"style": "mark"}])
_TIPS = [(-414.1, 217.0, 1.2, 1.3), (-407.1, 220.5, 1.1, 1.3), (-398.1, 223.3, 1.1, 1.3), (-387.1, 224.5, 1.1, 1.2)]
_SLOT35 = [["line", -384.0, _r(_slot_y(-384.0)), -412.8, _r(_slot_y(-412.8))], ["line", -384.0, _r(_slot_y(-384.0) - 0.35), -412.8, _r(_slot_y(-412.8) - 0.35)],
           ["rect", -413.4, 206.9, -412.8, 208.1, {"style": "pale"}]]

AGUJAS = {
    "id": "3.5", "slug": "3_5_agujas", "title": "Agujas", "kind": "challenge",
    "window": [-419.0, 204.0, -380.0, 238.0], "screen": [-410.6, 217.5], "cut_y": 217.2, "climber": [-415.6, 214.4],
    "place": ("The widest gap in the cave. Past the geode the back wall falls away into a bay so deep that it is dark, and the only things "
              "between you and the far side are four needles of crystal: 7, 9 and 11 m apart, each a little higher than the last. The first "
              "stands on the rest you are on and the last on the rest you are going to. The two in the middle have nothing under them. Each of "
              "those is one crystal crossed with another: the upright one you see, pointed at both ends, and a second that runs straight back "
              "from its waist into the wall and holds it up. Only a needle's point can be held: the top 1.3 m, rough and pale (note 30). Under "
              "the needles there is nothing but La Rampa, 30 to 40 m down, and it carries you back to the foot of the first stair."),
    "keep": [
        "The four needle tips where they are: 7, 9 and 11 m apart, each a little higher than the last.",
        "Only the point of each needle can be held, the top 1.3 m. The shafts are glass. The first needle's two sides and the last needle's east side stay frosted, as today.",
        "The two rests, and the nub and frosted face under the first rest that are the way back up from the sled's berth.",
        "Nothing under the needles but La Rampa.",
    ],
    "background": [
        {"name": "The crack, and the rib of rock along it", "z": [-3.0, -1.6], "tag": [-392.0, 220.9], "top": True,
         "text": "The same crack as the stair's, higher up the wall now and climbing east under the roof. The rib of dark rock along it is the only part of the back wall that is near you here. Both rests and both middle needles root in it.",
         "draw": _rib35},
        {"name": "The two cross arms", "z": [-3.0, -1.2], "style": "pale", "tag": [-405.4, 216.4], "top": True,
         "text": "Behind the waist of each middle needle: a second crystal as thick as the needle, running 3 m straight back into the rib, with a small fan of points where it enters the rock. From the front you see its six-sided end as a knot on the needle's waist. It is what holds a needle up in the air.",
         "draw": [["poly", [[_r(-407.1 + 0.8 * math.cos(math.radians(60 * k))), _r(217.25 + 0.8 * math.sin(math.radians(60 * k)))] for k in range(6)]],
                  ["poly", [[_r(-398.1 + 0.8 * math.cos(math.radians(60 * k))), _r(220.05 + 0.8 * math.sin(math.radians(60 * k)))] for k in range(6)]]] +
                 _fan(-407.1, 217.25, 1.9, [205, 150, -20]) + _fan(-398.1, 220.05, 1.9, [200, 25, -35])},
        {"name": "The roots of the two rests", "z": [-3.0, -1.2], "style": "pale", "tag": [-383.2, 219.5],
         "text": "The rest at each end is the end of a fat pale crystal with its fan of points, as on the stair. The first and last needles are points that have grown up out of those two crystals.",
         "draw": _R4_FAN + _R5_FAN},
        {"name": "Three giants in the bay", "z": [-8.0, -5.0], "style": "line", "tag": [-402.4, 206.0],
         "text": "Far crystals standing on La Rampa, well back, with their points coming up level with your feet between the needles. They are big, blue and dim, and their points lean away from you, so none of them reads as a place to land. Each has a faint light inside. They are there today.",
         "draw": [["poly", [[-413.0, 204.0], [-408.4, 204.0], [-409.5, 208.6], [-411.2, 210.2]]], ["poly", [[-405.5, 204.0], [-399.5, 204.0], [-401.0, 213.0], [-403.2, 215.6]]],
                  ["poly", [[-396.0, 204.0], [-389.0, 204.0], [-390.2, 213.4], [-392.6, 216.4]]]]},
        {"name": "The sled's slot", "z": [-1.8, -1.3], "style": "line", "tag": [-394.5, 210.3],
         "text": "Far below your feet, a straight groove cut in the back wall and shod with bronze, running 24 m west and 4 m down to a stone stop under the first rest. It is temple work: the crystal sled of El Prisma rides in it. From up here it is a thin bright line that tells you people worked this wall.",
         "draw": _SLOT35},
        {"name": "A mirror face between the middle needles", "z": [-4.6, -4.3], "style": "line", "tag": [-402.0, 213.4],
         "text": "A clear face 5 m wide on the back wall of the bay, below the line of your second fling. It shows you crossing, very small. It is there today.",
         "draw": [["poly", [[-404.6, 209.6], [-400.0, 210.3], [-399.4, 216.0], [-403.8, 215.4]]], ["line", -403.8, 210.6, -400.4, 215.0]]},
        {"name": "Two bright crystals, one at each end", "z": [-2.8, -1.6], "style": "pale", "tag": [-417.4, 220.6],
         "text": "A bright white cluster on the wall above each rest. The two ends of the crossing are lit and the middle is the dimmest stretch of the route, so the pale points of the needles are the brightest things in it.",
         "draw": _fan(-417.0, 217.7, 1.9, [85, 50, 120]) + [["circle", -417.0, 218.5, 0.3, {"style": "light"}]] +
                 _fan(-383.4, 224.6, 1.9, [95, 60, 130]) + [["circle", -383.4, 225.4, 0.3, {"style": "light"}]]},
    ],
    "play": [
        {"name": "The four points", "z": [-0.6, 0.6], "style": "pale", "tag": [-408.9, 220.9],
         "text": "Each needle's point becomes rough pale lilac crystal that looks like rock: frosted, six-sided, a little chipped, lighter towards the tip (note 30). It is the same crystal as the steps of the stair. Same size, same place.",
         "draw": [["poly", [[_r(x - w / 2), _r(tip - th)], [_r(x + w / 2), _r(tip - th)], [x, tip]]] for x, tip, w, th in _TIPS]},
        {"name": "The shafts", "z": [-0.6, 0.6], "style": "mark", "tag": [-396.4, 218.6],
         "text": "Below its point each needle is clear indigo glass, mirror-smooth, with one white glint down its length. No black: the shaft is plainly the same crystal as the point, but polished where the point is rough. Glass can't be held.",
         "draw": [["line", -407.1, 219.2, -407.1, 215.3], ["line", -398.1, 222.0, -398.1, 218.1]]},
        {"name": "The frosted sides, and the way back up", "z": [-1.2, 1.2], "style": "line", "tag": [-412.3, 213.2],
         "text": "The first needle's two sides, the last needle's east side, and the nub and face under the first rest are rough pale lilac like the points. They are the places a hand can stop, and they are the only way back up from the sled's berth.",
         "draw": [["line", -414.7, 214.5, -414.7, 215.7], ["line", -413.5, 214.5, -413.5, 215.7], ["line", -386.55, 222.4, -386.55, 223.3],
                  ["circle", -413.3, 212.4, 0.3], ["line", -413.5, 213.0, -413.5, 214.3]]},
    ],
    "foreground": [],
    "explains": [
        ["The two middle needles", "Each is two crystals grown through each other like a cross", "The second crystal, running back from the needle's waist into the rib of rock"],
        ["The first and last needles", "Points that have grown up out of the two rest crystals", "The rests' own roots on the wall"],
        ["The needle points", "Rough pale crystal, the only part of a needle that is not polished", "The bright cluster at each end that lights them"],
        ["The gap", "A bay where the back wall falls away", "Three far giants standing on La Rampa, and your own small reflection crossing"],
        ["The nub and face under the first rest", "The same rough crystal, on the rest's east side", "The stone stop of the sled's slot just below them"],
    ],
    "pieces": [
        ["Needle spire: rough lilac point on a clear indigo shaft, pointed at both ends", "1.1 m across, 6.5 m tall", "2", "Play space", "kit: needle spire (note 30)"],
        ["Short needle, standing on a rest", "1.1 to 1.2 m across, 2.2 to 2.6 m tall", "2", "Play space", "kit: needle spire, cut short"],
        ["Cross arm: a crystal from the needle's waist back into the wall", "1.1 m across, 3 m long", "2", "Background", "kit: wall point, clear"],
        ["Root fan on a rock collar", "2 to 3 m across", "4", "Background", "kit: cluster on a rock collar, grown sideways"],
        ["Crack with its rib of rock", "40 m long, rib 3 m wide", "1", "Background", "kit: seep crack (new, added to the kit)"],
        ["Far crystal", "5 to 7 m thick, 30 to 40 m tall", "3", "Background", "kit: giant far crystal"],
        ["Sled slot, bronze shod, with a stone stop", "24 m long, 0.35 m wide", "1", "Background", "kit: sled slot (new, added to the kit)"],
        ["Mirror face", "5 m by 6 m", "1", "Background", "kit: mirror face"],
        ["Bright cluster on the wall", "2 m", "2", "Background", "kit: crystal_cluster_c, grown sideways, lit"],
    ],
    "effects": [
        "La Rampa stays lit far below, so the drop under each fling can be read.",
        "A faint ring from a needle when you land on its point, each needle a different note.",
        "Slow glitter falling through the bay, to show how much air there is.",
    ],
    "notes": [
        "Note 30 (not built yet): the needles you grab are pale purple crystals that look like actual rock. Shown here as they will be: the point is rough and pale, the shaft is clear indigo glass and not black.",
        "Note 30's open question, whether the whole shaft should be something you can hold, is not decided here. The design keeps the point only, as the course has it.",
        "Note 40 (done): the dark slab that stood in front of the needles is behind them now.",
    ],
}

# ------------------------------------------------------------------ 3.6 El Prisma
_LEAVES = []
for _i in range(8):
    _f = (_i + 1) / 9.0
    _LEAVES.append((_r(-383.2 + 6.0 * _f + (0.4 if _i % 2 == 0 else -0.4)), _r(222.3 + 9.5 * _f)))
_R6_FAN = _fan(-373.2, 230.9, 2.8, [30, -30, 90])
_leaf_backs = [["poly", [[-385.4, 221.4], [-382.0, 221.4], [-375.4, 232.0], [-378.8, 232.0]]]]
for _x, _y in _LEAVES:
    _leaf_backs.append(["rect", _r(_x - 0.8), _r(_y - 0.24), _r(_x + 0.8), _r(_y - 0.04), {"style": "pale"}])
for _i in range(7):
    _leaf_backs.append(["line", _LEAVES[_i][0], _r(_LEAVES[_i][1] - 0.13), _LEAVES[_i + 1][0], _r(_LEAVES[_i + 1][1] - 0.13), {"style": "mark"}])
_PRISM = [[-384.6, 213.96], [-376.2, 219.84], [-374.22, 219.64], [-374.71, 217.71], [-383.11, 211.83]]

EL_PRISMA = {
    "id": "3.6", "slug": "3_6_el_prisma", "title": "El Prisma", "kind": "challenge",
    "window": [-392.0, 206.0, -366.0, 236.5], "screen": [-380.5, 227.0], "cut_y": 226.5, "climber": [-384.6, 222.3],
    "place": ("The Prism is the long clear crystal that lies under this stair: six-sided, 10 m long, on its side at La Rampa's own angle. A "
              "bright crystal behind it shines through it, and the light comes out split into colours, the way glass splits light. Above it the "
              "crack in the back wall climbs steeply, and out of the crack have grown eight thin leaves of crystal, like slates sticking out of "
              "a wall, in two rows. They are your steps. They are old and full of cracks, and each one snaps off 1.3 seconds after you take it "
              "and rings as it goes: eight leaves, eight notes, one scale (note 31). If you fall, the Prism's top face slides you west into a "
              "crystal sled. The sled is temple work. It sinks away under your weight along a slot in the wall and leaves you below the first "
              "needle, with the needles and the leaves to do again."),
    "keep": [
        "Eight leaves up a 12 m diagonal, each where it is, each gone 1.3 seconds after it is taken and back 8 seconds later, each ringing its own note in order.",
        "The glass face under them that pours a faller west, and the sled that catches him and sinks 24 m west to its berth, then comes home empty.",
        "The rest at each end. The upper rest's east lip is glass.",
    ],
    "background": [
        {"name": "The crack, and the leaves' far halves", "z": [-3.0, -1.2], "tag": [-378.2, 226.6], "top": True,
         "text": "The crack climbs the wall here at 58 degrees with its rib of dark rock. Each leaf you step on is the last half metre of a plate 3 m long and 0.26 m thick that grew out of the crack edge-on. The plates stand in two rows, one each side of the crack, which is why the steps go left, right, left, right.",
         "draw": _leaf_backs},
        {"name": "The Prism", "z": [-4.0, -1.2], "tag": [-379.0, 215.6], "top": True,
         "text": "One clear six-sided crystal, 10 m long and 2.6 m thick, lying along the wall on its side, with a point at its upper end. The glass plate that catches a faller today is its top face. It is rooted in the wall along its whole back.",
         "draw": [["poly", _PRISM]]},
        {"name": "The colours on the wall", "z": [-3.2, -3.0], "style": "mark", "tag": [-382.6, 227.6],
         "text": "Light goes through the Prism and comes out as a fan of faint colours up the back wall behind the leaves, red lowest and violet highest, roughly one band behind each leaf. They are the only colours in the cave that are not violet or white. They are dim, they are on the wall and never on a hold, and they do not move.",
         "draw": [["line", -376.4, 220.4, -383.9, 223.3], ["line", -376.4, 220.4, -383.3, 225.4], ["line", -376.4, 220.4, -382.2, 227.6],
                  ["line", -376.4, 220.4, -380.9, 229.7], ["line", -376.4, 220.4, -379.6, 231.4]]},
        {"name": "The bright crystal behind the Prism", "z": [-5.0, -4.0], "style": "pale", "tag": [-377.2, 214.0],
         "text": "The one bright white cluster of this area, on the wall under the Prism's lower side and behind it. You see it through the Prism as a blur of white. It is what throws the colours.",
         "draw": _fan(-378.8, 212.4, 2.0, [95, 60, 130]) + [["circle", -378.8, 213.2, 0.32, {"style": "light"}]]},
        {"name": "The sled's slot, its wheel and its weight", "z": [-1.8, -1.3], "style": "line", "tag": [-391.0, 212.2],
         "text": "The groove the sled rides in starts here and runs west out of sight, shod with bronze. At its head is a stone wheel on a carved boss. A bronze chain runs from the sled over the wheel to a stone weight, and chain and weight both sit in a second groove cut straight down the wall, so nothing hangs free. The weight is what brings the sled home when it is empty.",
         "draw": [["line", -384.0, _r(_slot_y(-384.0)), -392.0, _r(_slot_y(-392.0))], ["line", -384.0, _r(_slot_y(-384.0) - 0.35), -392.0, _r(_slot_y(-392.0) - 0.35)],
                  ["circle", -383.4, 212.6, 0.45], ["rect", -383.75, 206.2, -383.05, 212.1, {"style": "dark"}], ["rect", -383.7, 207.3, -383.1, 208.3, {"style": "pale"}]]},
        {"name": "An offering niche by the sled", "z": [-3.0, -2.6], "style": "dark", "tag": [-390.3, 214.9],
         "text": "A carved hollow with a small crystal and a jade ring, in the wall above the sled's home. One stands beside every piece of temple work in the cave.",
         "draw": [["rect", -390.6, 213.5, -390.0, 214.2]]},
        {"name": "The roots of the two rests", "z": [-3.0, -1.2], "style": "pale", "tag": [-370.4, 229.2],
         "text": "The rest at each end is the end of a fat pale crystal with its fan of points on the rib, as everywhere on the route.",
         "draw": _R5_FAN + _R6_FAN},
        {"name": "A mirror face, and a giant behind it", "z": [-8.0, -4.3], "style": "line", "tag": [-370.8, 224.6],
         "text": "East of the leaves, a clear face on the back wall that shows the stair from the side: you can watch the leaves break behind you in it. Below it, the point of one far giant. Both are there today.",
         "draw": [["poly", [[-373.4, 221.6], [-369.0, 222.2], [-368.6, 227.6], [-373.0, 227.0]]], ["line", -372.6, 222.6, -369.4, 226.6],
                  ["poly", [[-372.5, 206.0], [-367.2, 206.0], [-368.4, 214.0], [-370.4, 216.6]]]]},
    ],
    "play": [
        {"name": "The eight leaves", "z": [-0.6, 0.6], "style": "mark", "tag": [-383.6, 224.4],
         "text": "As the game has them since note 31: thin plates of pale crystal, a little see-through, crazed all over with fine white cracks, each with a corner already gone. The missing corner swaps sides from leaf to leaf. They are the cave's one picture of a thing that will break.",
         "draw": [["line", _r(x - 0.38), y, _r(x + 0.5), _r(y - 0.26)] for x, y in _LEAVES]},
        {"name": "The Prism's top face", "z": [-1.2, 1.2], "style": "line", "tag": [-381.6, 217.2],
         "text": "Clear indigo glass with a white glint, and long pale scratches down it from everything that has slid here. The scratches all run west, towards the sled, so the face tells you where it will send you.",
         "draw": [["line", -384.3, 214.2, -376.5, 219.66]]},
        {"name": "The sled", "z": [-1.0, 1.0], "style": "mark", "tag": [-386.4, 213.6],
         "text": "A tray cut from one flat crystal, frosted on top, with a tall back of rough crystal bound by two bronze bands and a low kerb at its open end. A stone arm at its back reaches into the slot. It hangs level, an arm's length under the Prism's low end.",
         "draw": [["rect", -389.0, 211.6, -384.3, 215.3]]},
        {"name": "The two wet lips", "z": [-1.2, 1.2], "style": "mark", "tag": [-368.3, 232.4],
         "text": "A drip from the roof falls on the lower rest beside the last needle, and the east lip of the upper rest is glass. Neither rest is quite safe.",
         "draw": [["circle", -369.3, 231.3, 0.4], ["circle", -387.4, 222.5, 0.4]]},
    ],
    "foreground": [],
    "explains": [
        ["The eight leaves", "The tips of thin crystal plates that grew out of a crack, in two rows", "The rest of each plate running back to the crack, and the crack itself climbing the wall"],
        ["A leaf breaking", "An old plate, already crazed, snapping at the wall", "The mirror face to the east, where you can see them go"],
        ["The glass face that catches you", "The top face of the Prism", "The Prism's whole body under it, and the bright crystal seen through it"],
        ["The sled", "The temple's crystal tray, carried on a stone arm", "The bronze-shod slot it rides in, the stone wheel, and the weight in its groove that brings it home"],
        ["The two rests", "The ends of two fat pale crystals", "Their root fans on the rib"],
    ],
    "pieces": [
        ["Crazed plate", "1 m by 0.26 m, 3 m long", "8", "Play space, running back into the background", "kit: crazed plate (note 31)"],
        ["Crack with its rib of rock", "12 m long, rib 3.4 m wide", "1", "Background", "kit: seep crack (new, added to the kit)"],
        ["The Prism: a clear six-sided crystal lying on its side", "10 m long, 2.6 m thick, 5 m deep", "1", "Background, its top face in the play space", "kit: giant far crystal, the smallest, with a mirror face"],
        ["The sled: crystal tray with a tall back, two bronze bands and a stone arm", "4.3 m long, 3.7 m tall", "1", "Play space", "in the game today: crystal_raft, to be given its bands and arm"],
        ["Sled slot, bronze shod", "24 m long, 0.35 m wide", "1", "Background", "kit: sled slot (new, added to the kit)"],
        ["Stone wheel on a temple boss", "0.9 m", "1", "Background", "kit: temple boss"],
        ["Stone weight on bronze chain, in its own groove", "weight 0.6 m by 1 m; groove 6 m", "1", "Background", "the temple's kit: counterweight_chain"],
        ["Offering niche", "0.6 m", "1", "Background", "kit: offering niche"],
        ["Bright cluster on the wall", "2 m", "1", "Background", "kit: crystal_cluster_c, grown sideways, lit"],
        ["Root fan on a rock collar", "3 m across", "2", "Background", "kit: cluster on a rock collar, grown sideways"],
        ["Mirror face", "4.5 m by 5.5 m", "1", "Background", "kit: mirror face"],
        ["Far crystal's point", "5 m thick", "1", "Background", "kit: giant far crystal"],
    ],
    "effects": [
        "The fan of faint colours on the back wall.",
        "The cracks in a leaf spreading and brightening once it is taken, then shards and glitter (note 31).",
        "The eight notes, in order, one to a leaf.",
        "A rattle of bronze chain when the sled moves.",
    ],
    "notes": [
        "Note 31 (done): the leaves are crazed crystal plates that hold for 1.3 seconds and ring a rising scale in order. The design keeps them as built.",
        "Note 31 says the pieces that fall are still chunks and not shards. The design wants shards.",
    ],
    "ask": [
        "A faint fan of colours on the wall behind the eight leaves, thrown by the Prism: the only colours in the cave that are not violet or white. Keep it?",
    ],
}

# ------------------------------------------------------------------ 3.7 Pendulo de Cuarzo
_PIV = (-359.96, 242.6)
_R7_FAN = _fan(-345.8, 230.9, 3.0, [150, 210, 60])
_niches = []
for _a in (-33, -22, -11, 0, 11, 22, 33):
    _nx, _ny = _PIV[0] + 14.2 * math.sin(math.radians(_a)), _PIV[1] - 14.2 * math.cos(math.radians(_a))
    _niches.append(["rect", _r(_nx - 0.3), _r(_ny - 0.3), _r(_nx + 0.3), _r(_ny + 0.3), {"style": "dark"}])

PENDULO_DE_CUARZO = {
    "id": "3.7", "slug": "3_7_pendulo_de_cuarzo", "title": "Péndulo de Cuarzo", "kind": "challenge",
    "window": [-378.0, 221.0, -338.0, 252.0], "screen": [-360.0, 233.5], "cut_y": 232.2, "climber": [-371.0, 231.8],
    "place": ("A great block of quartz hangs here on a clear crystal rod 13 m long, and swings: 38 degrees each way, six seconds a swing, "
              "from the lip of one rest to the lip of the next, 16 m apart. The temple's people hung it. Its pivot is a bronze pin through the "
              "tip of a roof crystal, held between two carved stone cheeks. On the back wall behind it they cut a curve of seven small niches "
              "that follows the swing, each with a crystal that brightens as the quartz passes over it. It is a clock, or it counts something. "
              "Under it there are 17 m of air and then La Rampa. On the far rest, where there is a small white block today, stands a tiny "
              "crystal tree (note 32)."),
    "keep": [
        "The pendulum: 13 m long, 38 degrees each way, 6 seconds a swing. Only the quartz at its end can be held. The rod can't.",
        "The two rests, 16 m apart. The near one's east lip is glass.",
        "The small upright thing on the far rest stays where it is and the size it is, and can be held. It stops whatever rolls along the ledge.",
        "The glass fin that hangs from the roof above it.",
    ],
    "background": [
        {"name": "The curve of niches", "z": [-3.2, -2.8], "style": "mark", "tag": [-364.0, 227.4], "top": True,
         "text": "Seven offering niches cut in the back wall on a curve just under the path of the quartz, from one rest to the other. Each holds a small crystal with a jade ring. A niche glows as the quartz passes over it and fades after, so you can read how far the swing reaches and where it is now without watching the quartz itself.",
         "draw": _arc(_PIV[0], _PIV[1], 14.2, -36, 36, 12) + _niches},
        {"name": "The stone mount at the pivot", "z": [-2.6, -1.2], "style": "pale", "tag": [-357.9, 242.6],
         "text": "Two carved stone cheeks stand out from the back wall either side of the roof crystal's tip, with a bronze pin through all three. A pug's face is carved on each cheek. This is the temple's way of holding anything that swings, and the same piece holds the geode.",
         "draw": [["rect", -360.95, 241.9, -360.45, 243.3], ["rect", -359.47, 241.9, -358.97, 243.3], ["circle", _PIV[0], _PIV[1], 0.24, {"style": "line"}]]},
        {"name": "The roof crystals, carrying back", "z": [-3.0, -1.2], "tag": [-362.6, 245.4],
         "text": "The crystal the pendulum hangs from, and the long fin east of it, are thick roof points of clear glass that carry on back to the wall. Each is wider behind than the part that crosses the play space, so it reads as a root and not a blade.",
         "draw": [["poly", [[-361.9, 249.0], [-358.0, 249.0], [-358.8, 243.6], [-361.1, 243.6]]], ["poly", [[-350.1, 249.0], [-347.9, 249.0], [-348.3, 238.2], [-349.7, 238.2]]]]},
        {"name": "A mirror face under the swing", "z": [-4.6, -4.3], "style": "line", "tag": [-359.8, 224.6],
         "text": "A clear face 5.5 m wide on the back wall below the lowest point of the swing. It shows the quartz going over, and you on it. It is there today, a little higher.",
         "draw": [["poly", [[-362.6, 221.8], [-357.2, 222.4], [-356.6, 227.2], [-362.0, 226.8]]], ["line", -361.8, 222.6, -357.6, 226.4]]},
        {"name": "The roots of the two rests", "z": [-3.0, -1.2], "style": "pale", "tag": [-343.6, 228.8],
         "text": "Each rest is the end of a fat pale crystal, with its fan of smaller points on a collar of rock.",
         "draw": [_blob(-373.2, 230.8, 4.4, 1.7, 0.7, "solid"), _blob(-345.8, 230.8, 5.4, 1.7, 1.9, "solid")] + _R6_FAN + _R7_FAN},
        {"name": "The bright crystal by the mount", "z": [-2.8, -1.6], "style": "pale", "tag": [-365.0, 246.6],
         "text": "One bright white cluster hanging from the roof just west of the pivot. It lights the mount and the top of the rod, and throws the quartz's shadow across the back wall as it swings.",
         "draw": _fan(-363.4, 248.5, 2.0, [270, 245, 295]) + [["circle", -363.4, 247.4, 0.3, {"style": "light"}]]},
        {"name": "A spire on La Rampa, far below", "z": [-7.0, -5.0], "style": "line", "tag": [-352.0, 222.4],
         "text": "The point of one far crystal standing on the glass slope, 6 m under the east rest. It tells you how high you are. It is there today.",
         "draw": [["poly", [[-353.2, 221.0], [-350.8, 221.0], [-351.3, 224.6], [-352.0, 226.0], [-352.7, 224.6]]]]},
    ],
    "play": [
        {"name": "The quartz", "z": [-0.6, 0.6], "style": "pale", "tag": [-360.0, 230.7],
         "text": "A block of rough pale quartz 1.4 m long, hung crosswise like the head of a hammer in a bronze stirrup with one jade stud. It is frosted and matte, the palest thing in the frame. The two dashed outlines are the ends of its swing.",
         "draw": [["rect", -360.66, 229.3, -359.26, 229.9],
                  ["poly", [[-351.22, 232.55], [-351.59, 233.02], [-352.69, 232.16], [-352.32, 231.69]], {"style": "mark"}],
                  ["poly", [[-368.7, 232.55], [-368.33, 233.02], [-367.23, 232.16], [-367.6, 231.69]], {"style": "mark"}]]},
        {"name": "The rod", "z": [-0.3, 0.3], "style": "mark", "tag": [-364.6, 237.6],
         "text": "One long clear needle of indigo glass, not a chain. Chain in this cave means you can hold it, and you can't hold this.",
         "draw": [["line", _PIV[0], _PIV[1], -367.96, 232.36], ["line", _PIV[0], _PIV[1], -351.96, 232.36]]},
        {"name": "The crystal bonsai", "z": [-0.5, 0.5], "style": "pale", "tag": [-347.9, 233.6],
         "text": "Where the white block stands today (note 32): a tiny tree of crystal, 1.2 m tall. It has a short twisted trunk of rough pale lilac and three flat pads of small points for a crown. It is the size of the block, it still stops what rolls along the ledge, and you can still hold it. What you touch is the trunk and the pads you see.",
         "draw": [["poly", [[-349.15, 231.8], [-348.85, 231.8], [-348.8, 232.45], [-348.55, 232.7], [-348.7, 233.0], [-349.3, 233.0], [-349.45, 232.6], [-349.2, 232.4]]]]},
        {"name": "The near rest's wet lip", "z": [-1.2, 1.2], "style": "mark", "tag": [-369.6, 233.0],
         "text": "The east lip of the rest you leave from is glass under a drip from the roof crystal above. You take the quartz from the frosted top, not from the lip.",
         "draw": [["circle", -369.3, 231.3, 0.4]]},
    ],
    "foreground": [],
    "explains": [
        ["The quartz you ride", "A block of rough quartz the temple's people hung as a pendulum", "The curve of seven niches behind it that lights as it passes"],
        ["The swing", "A bronze pin through the tip of a roof crystal", "The two carved stone cheeks that hold the pin, and the roof crystal carrying back to the wall"],
        ["The rod", "A single clear needle, not a chain", "Its shadow and the quartz's, thrown on the back wall by the bright cluster"],
        ["The two rests", "The ends of two fat pale crystals", "Their root fans on collars of rock"],
        ["The little tree", "A crystal that grew like a bonsai on the ledge", "The glass fin hanging from the roof above it"],
    ],
    "pieces": [
        ["Quartz block in a bronze stirrup, on a clear needle rod", "block 1.4 m by 0.6 m; rod 13 m", "1", "Play space", "in the game today: quartz_pendulum, to be given its stirrup"],
        ["Temple axle mount: two stone cheeks and a bronze pin", "1.4 m", "1", "Background", "kit: temple axle mount"],
        ["Offering niche, with a crystal that can glow", "0.6 m", "7", "Background", "kit: offering niche"],
        ["Roof crystal, clear, carrying back to the wall", "1.4 to 4 m across, 6 to 12 m long", "2", "Play space, background", "kit: roof points, the largest, clear"],
        ["Crystal bonsai tree", "0.6 m across the trunk, 1.2 m tall", "1", "Play space", "kit: crystal bonsai tree (note 32), at the size of the block it replaces"],
        ["Root fan on a rock collar", "3 m across", "2", "Background", "kit: cluster on a rock collar, grown sideways"],
        ["Bright cluster hanging from the roof", "2 m", "1", "Background", "kit: roof points, rough, lit"],
        ["Mirror face", "5.5 m by 5 m", "1", "Background", "kit: mirror face"],
        ["Far spire", "2 m across, 10 m tall", "1", "Background", "kit: crystal_spire"],
    ],
    "effects": [
        "Each niche glows as the quartz passes over it, then fades.",
        "A low hum from the rod, loudest at the bottom of the swing.",
        "The quartz's shadow sweeping the back wall.",
    ],
    "notes": [
        "Note 32 (not built yet): the little white block on the far rest becomes a tiny crystal bonsai tree. Shown here as it will be.",
        "The biome sheet lists the bonsai at 0.5 m and in the background. It is drawn here at the block's own size, 1.2 m, in the play space, so that it keeps the block's job.",
    ],
}

# ------------------------------------------------------------------ 3.8 Techo de Vidrio
def _under(x):
    """The underside of the glass slab, as the course has it."""
    return 245.2 + 0.625 * (x + 324.3)


_PATCHES = [(-340.9, -339.3)] + [(_r(-337.085 + 2.64 * i - 0.425), _r(-337.085 + 2.64 * i + 0.425)) for i in range(5)]
_crusts_back, _crusts = [], []
for _a, _b in _PATCHES:
    _crusts_back.append(["poly", [[_r(_a - 0.25), _r(_under(_a - 0.25))], [_r(_b + 0.25), _r(_under(_b + 0.25))], [_r(_b + 0.25), _r(_under(_b + 0.25) - 0.6)], [_r(_a - 0.25), _r(_under(_a - 0.25) - 0.6)]]])
    _crusts.append(["poly", [[_a, _r(_under(_a))], [_b, _r(_under(_b))], [_b, _r(_under(_b) - 0.3)], [_a, _r(_under(_a) - 0.3)]]])

TECHO_DE_VIDRIO = {
    "id": "3.8", "slug": "3_8_techo_de_vidrio", "title": "Techo de Vidrio", "kind": "challenge",
    "window": [-347.0, 226.0, -318.0, 252.0], "screen": [-333.5, 237.5], "cut_y": 239.0, "climber": [-342.6, 231.8],
    "place": ("One great flat crystal, 21 m long and 1 m thick, grew out of the back wall here and leans across the hall like a lean-to "
              "roof, from just above the pendulum's far rest up to a landing of rock. You cross underneath it. Its underside is clear glass. "
              "Six crusts of rough pale crystal have grown across the underside, each a band that runs back to the wall, like the mirror's "
              "rungs turned upside down, and they are the only things you can hang from (note 33). The first is reached from a broken tooth "
              "of crystal that hangs under the slab's low edge. La Rampa is 7 to 8 m below your feet the whole way. The slab's top face is "
              "polished smooth: it is where anyone who falls off the ring column above slides back down."),
    "keep": [
        "The glass slab: its place, its tilt of 32 degrees, and that neither of its faces can be held.",
        "Six patches of grip on its underside, each where it is: the long first one, then five that are 1 m long with 2.1 m of glass between one and the next.",
        "The broken tooth under its low edge, which is the first hold.",
        "The landing's frosted face and lip at the top.",
        "The slab's top face slides whatever lands on it back down to the pendulum's far rest.",
    ],
    "background": [
        {"name": "The slab's root on the wall", "z": [-3.2, -1.2], "tag": [-338.0, 239.6], "top": True,
         "text": "The slab carries straight back to the wall at the same thickness. Where it enters the rock there is a seam of rough dark rock and small points along both its faces, for its whole length. It reads as one crystal growing out of the wall, not a sheet of glass hung in the air.",
         "draw": [["poly", [[-343.3, 235.23], [-323.6, 247.54], [-323.6, 244.74], [-343.3, 232.43]]]]},
        {"name": "The six crusts, running back", "z": [-3.0, -1.2], "style": "pale", "tag": [-335.6, 236.6], "top": True,
         "text": "Each patch you hang from is the near end of a band of rough crystal 2.5 m long that lies across the underside of the slab and joins the seam at the wall. From the side you see each band's end, a little wider and deeper than the patch in front of it.",
         "draw": _crusts_back},
        {"name": "The column, standing behind the slab", "z": [-2.9, -1.3], "style": "line", "tag": [-328.0, 236.6],
         "text": "The great clear column of the next challenge stands on La Rampa behind the slab and goes on up past it. Its foot hangs in the air at 240 m today. Here it goes down to the slope, so it reads as standing on something.",
         "draw": [["rect", -329.3, 233.6, -326.7, 252.0]]},
        {"name": "A mirror face under the slab", "z": [-4.6, -4.3], "style": "line", "tag": [-335.6, 231.8],
         "text": "A clear face 5 m wide on the back wall, below the middle of the crossing. It shows you hanging from the ceiling, small. One is there today, near the start.",
         "draw": [["poly", [[-338.2, 228.8], [-333.4, 229.4], [-332.9, 235.0], [-337.6, 234.5]]], ["line", -337.4, 229.8, -333.8, 234.0]]},
        {"name": "A bright cluster on La Rampa", "z": [-5.0, -3.5], "style": "pale", "tag": [-329.2, 232.6],
         "text": "The one bright white crystal of this area stands on the glass slope under the slab, well back. It lights the underside from below, so each crust throws a long shadow up the glass and is easy to find, and it lights the slope, so you see what a miss costs.",
         "draw": _fan(-331.0, 231.5, 2.6, [90, 68, 113]) + [["circle", -331.0, 232.9, 0.32, {"style": "light"}]]},
        {"name": "The roots of the rest, and the landing's back", "z": [-3.0, -1.3], "style": "pale", "tag": [-320.4, 244.2],
         "text": "The rest you start from is the end of a fat pale crystal with its fan of points. The landing at the top is the hall's own rock, frosted over, and it runs back to the wall with a few small clusters standing on its back edge.",
         "draw": [_blob(-345.8, 230.8, 5.4, 1.7, 1.9, "solid")] + _R7_FAN + _fan(-320.6, 241.5, 2.0, [90, 62, 118])},
    ],
    "play": [
        {"name": "The six crusts", "z": [-1.2, 1.2], "style": "pale", "tag": [-331.8, 239.4],
         "text": "Each flat pale plate becomes a low crust of small rough points in the cave's pale lilac, clinging to the underside of the glass, lighter at its edges (note 33). Same size and place. Pale lilac on dark glass: they still stand out at a glance, because finding them is the challenge.",
         "draw": _crusts},
        {"name": "The broken tooth", "z": [-0.4, 0.4], "style": "line", "tag": [-343.4, 234.6],
         "text": "A short rough point of the same pale crystal, snapped off, hanging under the slab's low edge. It is the first thing you take.",
         "draw": [["rect", -342.28, 233.38, -341.92, 234.18]]},
        {"name": "The slab's two faces", "z": [-1.2, 1.2], "style": "mark", "tag": [-334.6, 241.6],
         "text": "The underside is clear indigo glass with a white glint, and it shows a dim reflection of the slope below. The top face is the same glass, scored with long straight scratches that all run downhill, so you can read where it will send you if you land on it.",
         "draw": [["line", -342.3, 234.95, -324.5, 246.08]]},
        {"name": "The landing's frosted face and lip", "z": [-1.2, 1.2], "style": "line", "tag": [-322.4, 240.0],
         "text": "The last catch is the landing's west face and the lip above it. Both are rough pale lilac for 2 m, where the rest of that wall is glass.",
         "draw": [["line", -324.3, 239.5, -324.3, 241.45], ["line", -324.3, 241.62, -320.3, 241.62]]},
    ],
    "foreground": [],
    "explains": [
        ["The glass ceiling", "One great flat crystal growing out of the wall at a lean", "Its root along the wall: a seam of rough rock and small points on both faces"],
        ["The six patches", "The near ends of six bands of rough crystal across the underside", "Each band running 2.5 m back to the seam"],
        ["The tooth", "A small roof point that hangs from the slab's edge, snapped short", "The slab's edge carrying back to the wall"],
        ["The landing", "A shelf of the hall's own rock, frosted over", "Its back edge at the wall, with small clusters, and the great column rising behind"],
        ["The slope under you", "La Rampa", "The bright cluster standing on it, and your reflection in the mirror face"],
    ],
    "pieces": [
        ["The glass slab: one flat clear crystal", "21 m long, 1 m thick, 4 m deep", "1", "Play space, rooted in the background", "kit: mirror face, the largest, as a slab"],
        ["Rough rib across a clear face, as a crust", "1 m and 1.9 m long on the glass, 0.3 m deep, running 2.5 m back", "6", "Play space, running back into the background", "kit: rough rib (new, added to the kit)"],
        ["Small rough roof point, snapped", "0.36 m by 0.8 m", "1", "Play space", "kit: roof points, the smallest"],
        ["Seam of rough rock and small points", "21 m long, 0.9 m wide", "2", "Background", "kit: seep crack's rib (new, added to the kit)"],
        ["Bright cluster on the slope", "2.5 m", "1", "Background", "kit: crystal_cluster_a, lit"],
        ["Mirror face", "5 m by 5.5 m", "1", "Background", "kit: mirror face"],
        ["Root fan on a rock collar", "3 m across", "1", "Background", "kit: cluster on a rock collar, grown sideways"],
        ["Small cluster on the landing", "1.5 to 2 m", "2", "Background", "kit: crystal_cluster_c"],
        ["The column's lower length", "2.6 m across, 10 m more", "1", "Background", "kit: crystal_column, made longer"],
    ],
    "effects": [
        "A long shadow up the glass from each crust, thrown by the cluster below.",
        "Your reflection, dim, in the underside of the slab as you hang from it.",
        "A hiss and a line of glitter when something slides down the slab's top face.",
    ],
    "notes": [
        "Note 33 (not built yet): the flat ceiling crystals become the same pale purple as the cave's other crystals. Shown here as they will be.",
    ],
}

# ------------------------------------------------------------------ 3.9 La Columna
_RINGS = [(-328.0, 250.9, (90, 180, 270, 0)), (-328.0, 258.7, (270, 30, 150)), (-328.0, 266.5, (45, 135, 225, 315))]
_CHIM = [(-310.0, 243.2), (-311.6, 244.3), (-310.0, 245.5), (-311.6, 246.7), (-311.7, 248.2)]
_mounts, _sockets = [], []
for _cx, _cy, _studs in _RINGS:
    _mounts += [["rect", _cx - 0.7, _cy - 0.55, _cx - 0.3, _cy + 0.55], ["rect", _cx + 0.3, _cy - 0.55, _cx + 0.7, _cy + 0.55], ["circle", _cx, _cy, 0.22, {"style": "line"}]]
    for _a in _studs:
        _sockets.append(["circle", _r(_cx + 2.8 * math.cos(math.radians(_a))), _r(_cy + 2.8 * math.sin(math.radians(_a))), 0.4])
_chimney = [["circle", x, y, 0.36, {"style": "dark"}] for x, y in _CHIM]
for _i in range(4):
    _chimney.append(["line", _CHIM[_i][0], _CHIM[_i][1], _CHIM[_i + 1][0], _CHIM[_i + 1][1]])

LA_COLUMNA = {
    "id": "3.9", "slug": "3_9_la_columna", "title": "La Columna", "kind": "challenge",
    "window": [-338.0, 238.0, -305.0, 281.0], "screen": [-326.5, 258.5], "cut_y": 258.7, "climber": [-322.5, 249.4],
    "place": ("The cave's tallest single crystal: a clear six-sided column that stands on La Rampa behind the glass ceiling and goes up 44 m "
              "to the roof. The temple's people made it the heart of their shrine. They fixed three crystal wheels to its face, one above "
              "another, each 6 m across and each turning on its own bronze pin in a stone mount. The wheels turn against each other like "
              "gears. Their rims are glass. The only holds are the pale spikes that stand out of the rims, eleven in all, and each spike "
              "slides into its rim and out again (note 34). You go up the east side of the first wheel, the west side of the second, the east "
              "side of the third, and off onto a shelf of crystal at the top. If you fall you land on the glass ceiling's top face, and it "
              "slides you back to the pendulum's far rest. Below the wheels is a landing of the hall's own rock, and from its east end five "
              "nubs lead up the corner beside the well's wall to the shelf where the column starts."),
    "keep": [
        "Three rings, each 6 m across, where they are. The first and third turn one way at three turns a minute and the second the other way at four. A spike on one ring meets a spike on the next every 5 seconds.",
        "Eleven spikes: four, three and four. They are the only holds on the rings.",
        "After note 34 each spike slides in and out on a rhythm, with a shake first. The note's plan keeps the two spikes that meet at a crossing out at that moment, so the climb can always be done.",
        "The landing, the five nubs up to the lower shelf, and the two shelves.",
        "A fall lands on the glass ceiling's top face and slides back to the pendulum's far rest.",
    ],
    "background": [
        {"name": "The column", "z": [-2.9, -1.3], "tag": [-328.0, 262.6], "top": True,
         "text": "One clear six-sided crystal 2.6 m across, floor to roof, with a dim light running up inside it. It does not turn. It is natural: nobody cut it. The game has it today.",
         "draw": [["rect", -329.3, 238.0, -326.7, 278.0]]},
        {"name": "The column's cap", "z": [-3.0, -1.3], "style": "pale", "tag": [-331.0, 277.0],
         "text": "Where the column meets the roof the temple's people set a collar of carved pale stone 4 m wide, with a pug's face on its front and jade eyes. It is the largest piece of temple work in the cave, and the camera shows it as you reach the third wheel.",
         "draw": [["rect", -330.0, 276.2, -326.0, 278.0]]},
        {"name": "Three clear wheel backs", "z": [-1.5, -1.25], "style": "line", "tag": [-329.9, 257.2], "top": True,
         "text": "Each ring is the rim of a crystal wheel. Behind the rim the wheel has a back of clear glass 5 m across, like a plate, turning with it. The back is what joins the rim to its pin, so the ring is not a hoop hanging in the air. It is behind you, mirror-smooth, and shows you a small reflection as you go round.",
         "draw": [["circle", cx, cy, 2.28] for cx, cy, _s in _RINGS]},
        {"name": "Three stone mounts on the column's face", "z": [-2.2, -1.5], "style": "pale", "tag": [-326.6, 252.0], "top": True,
         "text": "At the middle of each wheel: two carved stone cheeks fixed to the column, 1.4 m across, with a bronze pin between them and a jade ring round the pin. You see each one through the clear back of its wheel. They are the same piece that holds the geode and the pendulum.",
         "draw": _mounts},
        {"name": "An offering niche at the lower shelf", "z": [-3.0, -2.6], "style": "dark", "tag": [-320.2, 251.6],
         "text": "A carved hollow with a small crystal and a jade ring, in the back wall at head height where you stand before the first wheel.",
         "draw": [["rect", -321.3, 250.3, -320.7, 251.0]]},
        {"name": "The roots of the two shelves", "z": [-3.0, -1.2], "style": "pale", "tag": [-315.4, 246.9],
         "text": "Each shelf is one wide flat crystal that grew out of the wall like a balcony, frosted on top and clear below. Under each, where it leaves the wall, there is a fan of smaller points.",
         "draw": _fan(-318.4, 248.6, 2.4, [205, 250, 320]) + _fan(-319.0, 264.6, 2.4, [210, 258, 325])},
        {"name": "The chimney's crack", "z": [-3.0, -1.3], "style": "mark", "tag": [-312.9, 245.4],
         "text": "The crack again, climbing the corner beside the well's wall. Each of the five nubs is the tip of a thin rough crystal growing out of it, and the crack's zigzag is why the nubs go left and right.",
         "draw": _chimney},
        {"name": "The bright cluster on the landing", "z": [-2.8, -1.4], "style": "pale", "tag": [-318.0, 243.6],
         "text": "A cluster 3 m tall on the back edge of the landing, bright white. It lights the landing and the foot of the chimney, and from below it lights the first wheel. It is there today.",
         "draw": _fan(-316.0, 241.5, 2.9, [90, 65, 115, 45]) + [["circle", -316.0, 243.2, 0.32, {"style": "light"}]]},
        {"name": "A mirror face east of the column", "z": [-4.6, -4.3], "style": "line", "tag": [-318.8, 257.0],
         "text": "A clear face 5 m wide on the back wall between the two shelves. It shows the wheels turning, and you on them, from the side you can't see.",
         "draw": [["poly", [[-321.6, 252.6], [-316.8, 253.2], [-316.3, 261.2], [-321.0, 260.6]]], ["line", -320.8, 253.8, -317.2, 260.0]]},
    ],
    "play": [
        {"name": "The eleven spikes and their sockets", "z": [-0.5, 0.5], "style": "line", "tag": [-324.0, 253.3],
         "text": "Each spike is a point of rough pale lilac crystal 0.65 m long, sitting in a socket in the rim with a bronze lip. It trembles for half a second, slides in until it is flush, and later snaps out again with a click and a ring of glitter (note 34). When it is in, only the bronze lip shows, and there is nothing to hold.",
         "draw": _sockets},
        {"name": "The three rims", "z": [-0.5, 0.5], "style": "mark", "tag": [-332.0, 260.6],
         "text": "Twelve flat faces of clear indigo glass, as today, with a white glint that goes round with the wheel so you can read the turn. Glass can't be held, inside or out.",
         "draw": [["circle", cx, cy, 3.3] for cx, cy, _s in _RINGS]},
        {"name": "The chimney's five nubs", "z": [-0.4, 0.4], "style": "pale", "tag": [-308.9, 247.0],
         "text": "Rough pale lilac, six-sided, a hand's width proud: the same crystal as the mirror's nubs.",
         "draw": [["circle", x, y, 0.24] for x, y in _CHIM]},
    ],
    "foreground": [
        {"name": "Two dark points in the bottom corner", "z": [1.3, 2.2], "style": "dark", "tag": [-306.6, 239.0], "top": True,
         "text": "Rising from the bottom right corner of the frame, in front of the landing's own rock and the well's wall, with their tips below the landing's floor. They cover nothing you stand on or hold.",
         "draw": [_spike(-309.2, 238.0, 100, 3.0, 1.1), _spike(-307.4, 238.0, 85, 2.2, 0.9)]},
    ],
    "explains": [
        ["The three rings", "The rims of three crystal wheels the temple's people fixed to the column", "Each wheel's clear back, and the stone mount and bronze pin at its middle, on the column's face"],
        ["The spikes", "Rough crystal points set in sockets in the rims", "The bronze lip of each socket, which stays when the spike is in"],
        ["The column", "The tallest crystal in the cave, used as the post of a shrine", "Its carved stone cap at the roof, and the offering niche at the shelf"],
        ["The two shelves", "Wide flat crystals grown out of the wall like balconies", "The fan of points under each"],
        ["The five nubs", "Tips of thin crystals growing out of the crack", "The crack zigzagging up the corner"],
        ["The landing", "The hall's own rock, frosted over", "The bright cluster on its back edge"],
    ],
    "pieces": [
        ["Crystal wheel: a twelve-sided glass rim on a clear back, with sockets", "6 m across, back 5 m across", "3", "Play space; the back is background", "in the game today: crystal_ring_4, crystal_ring_3, crystal_ring_4x, to be given backs and sockets"],
        ["Ring spike, sliding, with a bronze-lipped socket", "0.65 m long, 0.5 m across", "11", "Play space", "kit: ring spike, sliding (note 34)"],
        ["Temple axle mount: two stone cheeks and a bronze pin, with a jade ring", "1.4 m", "3", "Background", "kit: temple axle mount"],
        ["The column", "2.6 m across, 44 m tall", "1", "Background", "kit: crystal_column, made longer"],
        ["Carved stone cap with a pug's face and jade eyes", "4 m wide, 1.8 m tall", "1", "Background", "new, this area only; the temple's stone"],
        ["Offering niche", "0.6 m", "1", "Background", "kit: offering niche"],
        ["Shelf crystal: wide, flat, frosted on top", "11 to 12 m long, 1 to 1.9 m thick", "2", "Play space, rooted in the background", "kit: wall point, flat and wide"],
        ["Root fan", "2.4 m across", "2", "Background", "kit: cluster on a rock collar, grown sideways"],
        ["Thin wall point for a nub", "0.4 m across, 3 m long", "5", "Play space, rooted in the background", "kit: wall point, the smallest"],
        ["Crack up the corner", "6 m", "1", "Background", "kit: seep crack (new, added to the kit)"],
        ["Bright cluster on the landing", "2 m by 3 m", "1", "Background", "kit: crystal_cluster_a, lit"],
        ["Mirror face", "5 m by 8 m", "1", "Background", "kit: mirror face"],
        ["Dark corner point", "0.9 to 1.1 m across, 2.2 to 3 m tall", "2", "Foreground", "kit: dark corner point (new, added to the kit)"],
    ],
    "effects": [
        "A spike's shake before it goes in, and a click and a ring of glitter when it comes out (note 34).",
        "A glint that travels round each rim with the wheel.",
        "A slow grind of stone from the three mounts, each at its own pitch.",
    ],
    "notes": [
        "Note 34 (not built yet): the spikes on the rings pop in and out. Shown here as they will be: each spike has a socket, and the socket's bronze lip stays in sight when the spike is in.",
        "Note 34's open question, whether a spike may go in under you or only where you are not, is not decided here.",
        "The biome sheet lists spikes under things that hurt you. In the course these spikes are the holds, and the design treats them as holds.",
    ],
    "ask": [
        "The three rings drawn as crystal wheels pinned to the face of the column, each on its own stone mount, with the column itself standing still: is that how you see them?",
    ],
}

# ------------------------------------------------------------------ 3.10 El Salto del Pozo I
_HORN_BANDS = [["line", -316.66, 266.63, -316.97, 267.48], ["line", -313.84, 267.66, -314.15, 268.5], ["line", -311.02, 268.68, -311.33, 269.53],
               ["line", -308.2, 269.71, -308.51, 270.56]]

EL_SALTO_DEL_POZO_I = {
    "id": "3.10", "slug": "3_10_el_salto_del_pozo_i", "title": "El Salto del Pozo I", "kind": "challenge", "also": ["a4"],
    "window": [-326.0, 255.0, -282.0, 286.0], "screen": [-300.0, 270.5], "cut_y": 270.0, "climber": [-322.0, 266.0],
    "place": ("The end of the cave, and the way into the mushroom garden. The well, El Pozo del Diablo, runs up through the mountain just "
              "east of here, and at this height its wall has split open: a breach 14 m tall, the cave's door. The longest rough crystal in "
              "the cave has grown out through it: a horn 16 m long, rising at 20 degrees from the last shelf, with its tip 1.4 m out over the "
              "shaft. From here the well is black. Its walls are wet and slick, there is no bottom to see, and far overhead there is one small "
              "dot of light. Across it the far wall is broken open too, and that side is not crystal. A thick root has pushed "
              "out into the shaft above the far door, and three thinner roots hang from it like a curtain, 9 m from the horn's tip. You go up the horn, fling from its "
              "tip, and catch a root. Behind the roots there is moss, a green glow and the first mushroom. The temple's people came into the "
              "cave this way, down the well: their last carved pug is over the door."),
    "keep": [
        "The horn: 16 m long, rising 20 degrees, its tip 1.4 m into the well and 7 m above the sill. All of it can be held.",
        "The shelf and the sill it leaves from.",
        "The well: 12 m wide, slick on both walls, with nothing to catch between the horn's tip and the roots.",
        "The far side: the root that sticks 2.5 m out into the well, the three hanging roots 12 m long, and the sill of roots under them.",
        "A miss goes down the well.",
    ],
    "background": [
        {"name": "The well's far wall", "z": [-8.0, -6.0], "style": "dark", "tag": [-300.0, 262.0], "top": True,
         "text": "The shaft is round, and its far side curves behind the crossing: black rock, wet, with thin white runs of water and no ledges. It is the darkest thing in the cave. Below the frame it goes on down with no floor in sight, only a little mist. The cave's violet reaches one arm's length into it and stops.",
         "draw": [["rect", -306.0, 255.0, -294.0, 286.0]]},
        {"name": "The dot of light", "z": [-7.0, -6.0], "style": "light", "tag": [-298.6, 284.2], "top": True,
         "text": "Far up the shaft, at the top of the frame when the camera pulls back for the jump: one small pale dot, the well's mouth, 210 m above. A faint grey light comes down the middle of the shaft from it and is gone before it reaches you. It is the same dot you saw from the river.",
         "draw": [["circle", -300.0, 284.9, 0.28], ["line", -300.0, 284.3, -300.0, 275.0, {"style": "mark"}]]},
        {"name": "The horn's root", "z": [-3.0, -1.2], "style": "pale", "tag": [-322.6, 268.6],
         "text": "The horn's thick end is buried in a collar of dark rock and small points that stands out from the back wall across the shelf. It grew from there towards the well, as if towards the air. The shelf's own fan of points is under it.",
         "draw": [_blob(-320.4, 266.7, 2.3, 1.7, 0.9, "solid")] + _fan(-320.2, 266.3, 2.4, [160, 110, 205, 62]) + _fan(-319.0, 264.6, 2.4, [210, 258, 325])},
        {"name": "The breach, carrying on behind", "z": [-4.0, -1.3], "tag": [-307.5, 275.4],
         "text": "Behind the doorway the well's wall is whole again: the door is a split a little over 2 m deep. On the cave side its broken edges are crusted with small pale points. On the well side they are bare black rock. The line between the two is where the cave ends.",
         "draw": [["rect", -309.0, 264.25, -306.0, 278.0]]},
        {"name": "The temple's ring over the door", "z": [-2.4, -1.3], "style": "pale", "tag": [-313.6, 277.2],
         "text": "High on the back wall beside the top of the door: a carved stone pug with an empty bronze ring in its mouth, under a skin of clear crystal, and an offering niche next to it. It is where the temple's people made fast when they came down the well. No chain hangs from it now. It is the last temple work in the cave, and the same stone, bronze and jade as the temple two biomes up.",
         "draw": [["rect", -311.2, 276.0, -310.3, 276.9], ["circle", -310.75, 275.7, 0.24, {"style": "line"}], ["rect", -312.6, 276.1, -312.0, 276.8, {"style": "dark"}]]},
        {"name": "The bright crystal at the door", "z": [-2.8, -1.6], "style": "pale", "tag": [-313.4, 272.8],
         "text": "One bright white cluster on the back wall above the horn. It lights the horn from behind, so the horn is a pale spear against the well's black, and it is the last white light before the garden's green.",
         "draw": _fan(-311.6, 273.9, 1.9, [262, 232, 292]) + [["circle", -311.6, 273.1, 0.3, {"style": "light"}]]},
        {"name": "East rim: the great root and the curtain behind", "z": [-4.0, -1.3], "tag": [-292.4, 271.6], "top": True,
         "text": "The root that sticks out into the well is the end of a root as thick as a man's body that runs back along the top of the far door. Behind the three roots you catch hang three more, each as thick as a thigh, too thick to take for a rope, with moss on them. Together they are the curtain: you fly into its front edge.",
         "draw": [["rect", -296.5, 278.55, -289.0, 279.75], ["rect", -293.75, 264.0, -293.3, 278.6], ["rect", -292.6, 265.4, -292.15, 278.6], ["rect", -291.45, 264.0, -291.0, 278.6]]},
        {"name": "East rim: the garden through the door", "z": [-3.0, -1.5], "style": "pale", "tag": [-289.0, 268.6],
         "text": "Past the roots: glowing moss on the rock, a spore lantern's green light, and the first spotted mushroom, a small one, orange with pale spots. At the foot of the curtain one last small cluster of crystal stands dull and grey with roots grown round it. Green light falls on the east wall of the well and stops at its edge, as the violet does on the west.",
         "draw": [["rect", -289.3, 264.0, -288.7, 266.2], ["poly", [[-290.8, 266.2], [-287.2, 266.2], [-287.9, 267.2], [-289.0, 267.6], [-290.1, 267.2]]],
                  ["circle", -290.6, 269.6, 0.28, {"style": "light"}]] + _fan(-292.6, 264.0, 1.3, [90, 60, 120])},
    ],
    "play": [
        {"name": "The horn", "z": [-0.6, 0.6], "style": "line", "tag": [-312.6, 267.0],
         "text": "Rough pale lilac from end to end, six-sided, 0.9 m thick, with growth rings across it every few metres and a clean point. It is the palest and longest thing in the cave, and the only crystal that grew sideways along your path and not out of the wall at you.",
         "draw": _HORN_BANDS},
        {"name": "The well's two walls", "z": [-1.2, 1.2], "style": "mark", "tag": [-304.9, 258.6],
         "text": "Black, wet and glossy from top to bottom on both sides, with white drips. Nothing on them can be held. The frosted sill stops dead at the well's edge, and the black starts.",
         "draw": [["line", -306.0, 255.0, -306.0, 264.0], ["line", -294.0, 255.0, -294.0, 262.0], ["line", -306.0, 278.0, -306.0, 286.0], ["line", -294.0, 280.0, -294.0, 286.0]]},
        {"name": "The three roots", "z": [-0.6, 0.6], "style": "mark", "tag": [-297.6, 272.4],
         "text": "Tan, hairy and dry, each as thick as a wrist: the garden's own picture of something you can hold. They hang 12 m from the root above. The dashed ring is where the fling from the horn's tip arrives.",
         "draw": [["circle", -296.0, 270.0, 0.6]]},
        {"name": "The root sill", "z": [-1.2, 1.2], "style": "line", "tag": [-291.6, 262.9],
         "text": "A mat of roots and moss 2 m thick that fills the foot of the far door and stands 1 m out into the well. Dry and tan on top. It is where you step off the roots.",
         "draw": [["line", -295.0, 264.0, -288.0, 264.0]]},
    ],
    "foreground": [
        {"name": "West: one dark crystal point", "z": [1.3, 2.2], "style": "dark", "tag": [-308.2, 257.4], "top": True,
         "text": "Standing in front of the well's west wall below the sill, in front of solid rock. Its tip stops 2.7 m under the sill. It is the cave's last piece of foreground.",
         "draw": [_spike(-308.0, 255.0, 92, 6.5, 1.4)]},
        {"name": "East: a clump of fern", "z": [1.3, 2.0], "tag": [-285.6, 261.9], "top": True,
         "text": "At the bottom right corner, in front of the garden floor's own rock, with its tips below the floor's top. It is the garden's first piece of foreground. One side of the frame has crystal in front and the other has green.",
         "draw": _fan(-285.5, 261.2, 2.2, [95, 68, 122, 50])},
    ],
    "explains": [
        ["The horn", "The longest rough crystal in the cave, grown east towards the well", "Its thick end buried in a collar of rock and points on the shelf's back wall"],
        ["The shelf and the sill", "A wide flat crystal, and the frosted floor of the door", "The fan of points under the shelf; the breach's crusted edge"],
        ["The door", "A split in the well's wall, 14 m tall", "The well's wall whole again behind it, and the temple's carved pug and ring above"],
        ["The well", "A round shaft through the mountain", "Its black far wall curving behind you, and the dot of light far overhead"],
        ["The three roots", "Roots from the garden, hanging in the shaft", "The great root they hang from, running back over the far door, and three thicker roots behind them"],
        ["The root sill", "A mat of roots and moss in the foot of the far door", "The garden's floor behind it, the moss, the lantern's light and the first mushroom"],
    ],
    "pieces": [
        ["The horn: one rough lilac crystal with growth rings and a point", "16 m long, 0.9 m thick", "1", "Play space", "kit: wall point, the longest, laid along the path"],
        ["Collar of rock with a fan of points", "4.5 m across", "1", "Background", "kit: cluster on a rock collar"],
        ["Crust of small pale points for the breach's edges", "14 m tall, 0.5 m wide", "2", "Background", "kit: seep crack's fringe (new, added to the kit)"],
        ["Temple boss with an empty bronze ring, under a skin of clear crystal", "0.9 m", "1", "Background", "kit: temple boss, glazed over (a new look, added to the kit)"],
        ["Offering niche", "0.6 m", "1", "Background", "kit: offering niche"],
        ["Bright cluster on the wall", "2 m", "1", "Background", "kit: crystal_cluster_c, grown sideways, lit"],
        ["The well's far wall: curved black wet rock", "12 m wide, to suit", "1", "Background", "the mountain's shared structure; new as a model"],
        ["The dot of light, with a faint grey shaft of light under it", "dot 0.5 m", "1", "Background", "new; shared by all three crossings and the river"],
        ["Great root", "0.9 m thick, 7.5 m long", "1", "Background, its end in the play space", "the garden's kit: thick root"],
        ["Thick hanging root, mossy", "0.45 m thick, 13 to 14.6 m long", "3", "Background", "the garden's kit: thick root"],
        ["Root to catch", "12 m", "3", "Play space", "the garden's kit: vine with leaves; root"],
        ["Small spotted mushroom; spore lantern; glow moss", "mushroom 3.6 m cap; lantern 0.5 m; moss 3 m", "1 of each", "Background", "the garden's kit: spotted mushroom, spore lantern, glow moss patch"],
        ["Small dull cluster, wrapped in roots", "1.3 m", "1", "Background", "kit: crystal_cluster_c, greyed"],
        ["Dark corner point", "1.4 m across, 6.5 m tall", "1", "Foreground", "kit: dark corner point (new, added to the kit)"],
        ["Fern clump", "2 m", "1", "Foreground", "the garden's kit: fern clump"],
    ],
    "effects": [
        "Mist turning slowly in the well below the sill, lit violet on the west side and green on the east.",
        "White drips falling down both walls of the well, with no sound of landing.",
        "A few green spores drifting west across the shaft: the first green thing you see is one landing on the horn.",
        "The roots sway a little by themselves, and more when one is caught.",
    ],
    "notes": [
        "Note 40 (done): nothing stands in front of the horn or the well. The only foreground is one low point on each rim, in front of solid rock.",
        "Note 37 belongs to the garden: its mushrooms are all the spotted kind, so the first one seen from here is too.",
    ],
}

AREAS = [LA_GEODA_DE_LA_RANA, PRIMER_DESTELLO, EL_ESPEJO, CANDELABROS, LA_GEODA, AGUJAS, EL_PRISMA, PENDULO_DE_CUARZO, TECHO_DE_VIDRIO,
         LA_COLUMNA, EL_SALTO_DEL_POZO_I]

# ------------------------------------------------------------------ pieces these areas add to the biome's kit
KIT_MORE = [
    ["Seep crack: a dark split in the back wall with a rib of rough rock along it, fringed with tiny points", "crack 0.3 m wide; rib 3 m wide, standing 1.5 m out of the wall",
     "the line an area's holds grow from: the stair, the needles, the leaves, the glass ceiling's seam, the chimney", "Background", "new"],
    ["Rough rib across a clear face: a band of rough lilac crystal lying on glass", "0.4 m thick, 0.4 to 1.6 m wide, 2.5 m long",
     "the mirror's rungs and the glass ceiling's crusts (note 33)", "Play space, running back into the background", "new"],
    ["Temple work, glazed over: a temple piece under a skin of clear crystal", "to suit",
     "temple stone that must not look like a hold: the chandeliers' bosses, the ring over the door", "Play space, background", "new look for pieces already in the kit"],
    ["Sled slot: a groove in the back wall shod with bronze, with a stone stop", "0.35 m wide, 24 m long",
     "what El Prisma's crystal sled rides in, seen from Agujas and El Prisma", "Background", "new, shared with the temple's slot and sliding block"],
    ["Dark corner point", "0.9 to 1.4 m across, 2 to 6.5 m tall",
     "the cave's only foreground: a bottom corner of the frame, in front of solid rock", "Foreground", "new"],
]
