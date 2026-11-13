# Las Aguas Negras: its areas, one dict each, in the order you meet them. Format: see ../build.py.
import math


def R(x0, y0, x1, y1, st=None):
    return ["rect", x0, y0, x1, y1] + ([{"style": st}] if st else [])


def L(x0, y0, x1, y1, st=None):
    return ["line", x0, y0, x1, y1] + ([{"style": st}] if st else [])


def C(x, y, r, st=None):
    return ["circle", x, y, r] + ([{"style": st}] if st else [])


def P(pts, st=None):
    return ["poly", [list(p) for p in pts]] + ([{"style": st}] if st else [])


def arch(x0, x1, y0, ys, st=None, n=8):
    """A round-arched opening: straight sides from y0 up to the springing at ys, then a half circle."""
    r, cx = (x1 - x0) / 2.0, (x0 + x1) / 2.0
    pts = [[x0, y0], [x0, ys]]
    pts += [[round(cx - r * math.cos(math.pi * i / n), 2), round(ys + r * math.sin(math.pi * i / n), 2)] for i in range(1, n)]
    pts += [[x1, ys], [x1, y0]]
    return P(pts, st)


# ------------------------------------------------------------------ 2.1 El Borde
EL_BORDE = {
    "id": "2.1", "slug": "2_1_el_borde", "title": "El Borde", "kind": "challenge",
    "window": [-260.0, 84.0, -224.0, 98.5], "screen": [-240.5, 92.0], "cut_y": 94.5, "climber": [-229.0, 90.0],
    "place": ("This is the tail of the works: the brick tunnel that carries the river its last stretch to the weir, where it goes over "
              "into the mine as the great waterfall. The company ran an iron water main under the tunnel's roof, from the wheel pit "
              "above to the dry shaft, to send wash water down to the mine. It is bracketed to the back wall and it is the only way "
              "across. Two lengths of it have rusted through. Just upstream of the weir hangs the chain that once held a boom across "
              "the river to catch driftwood: it is the last thing you can grab before the lip."),
    "keep": [
        "The main exactly where it is: up from the ledge, then 19.5 m level at 94.5 m, with its two rusty lengths (note 16).",
        "The one chain, its length, and how far its end hangs over the water.",
        "The weir's slot, the pier with its peaked top, the lip ledge, the landing and the ladder up.",
    ],
    "background": [
        {"name": "The tunnel's back wall", "z": [-3.2, -2.6], "tag": [-240.0, 95.4], "top": True,
         "text": "Slate-grey brick, 6 m tall, with a brick rib every 6 m. Upstream of the weir, round culvert mouths open at the waterline with black water going back under them. On the ledge there is one arch, bricked up.",
         "draw": [R(-260.0, 90.0, -226.0, 96.0)] + [R(x, 90.0, x + 0.6, 96.0, "pale") for x in (-252.6, -246.6, -232.6)]
                 + [arch(-257.3, -254.3, 90.0, 91.2, "dark"), arch(-251.3, -248.3, 90.0, 91.2, "dark"), arch(-231.3, -228.7, 90.0, 91.6, "line")]},
        {"name": "The weir, carried on behind", "z": [-6.0, -1.2], "style": "mark", "tag": [-241.0, 87.5],
         "text": "The weir is as wide as the tunnel. Behind the slot you fall through, the same stone lip and the same white sheet of water run back into the scene, so the slot is the near end of a real weir.",
         "draw": [L(-243.2, 84.0, -243.2, 90.8), L(-241.4, 84.0, -241.4, 90.8), L(-239.6, 84.0, -239.6, 90.8), R(-244.6, 90.55, -243.8, 91.0, "pale")]},
        {"name": "The main's brackets and its two ends", "z": [-2.6, -1.2], "style": "pale", "tag": [-248.0, 95.5],
         "text": "A cast bracket from the back wall under the main every few metres, and a bigger one where the chain hangs. At the west end the main turns up through the roof to the wheel pit. At the east end it turns straight back to the wall. From there on it is scenery: it runs flat along the back wall, 2.6 m behind you, and goes down the dry shaft. Every length of it that is in the play space is a length you can hold.",
         "draw": [R(x - 0.12, 94.0, x + 0.12, 95.3) for x in (-251.0, -248.0, -246.6, -241.0, -236.0, -234.2)]
                 + [R(-253.15, 94.5, -252.85, 96.0), L(-229.5, 92.0, -229.5, 91.1, "line"), L(-229.5, 91.1, -234.0, 91.1, "line"), L(-234.0, 91.1, -234.0, 84.0, "line")]},
        {"name": "What the landing hangs from", "z": [-2.6, -1.2], "style": "pale", "tag": [-254.5, 91.7],
         "text": "Three iron beams out of the back wall carry the brick landing over the river. You see their ends under it.",
         "draw": [R(-256.7, 92.1, -256.4, 92.5), R(-254.6, 92.1, -254.3, 92.5), R(-252.5, 92.1, -252.2, 92.5)]},
        {"name": "The head of the dry shaft", "z": [-2.4, -1.4], "style": "pale", "tag": [-234.0, 92.2],
         "text": "The last timber set of the mine, standing against the first brick of the works. It belongs to the join from the mine and is drawn here only so the two pages agree.",
         "draw": [R(-235.9, 86.0, -235.6, 91.3), R(-232.4, 86.0, -232.1, 91.3), R(-236.0, 91.3, -232.0, 91.6)]},
        {"name": "The first works lantern", "z": [-2.5, -2.2], "style": "light", "tag": [-227.6, 94.1],
         "text": "On a wall bracket over the ledge, greenish and steady. It is the first cold light after the mine's amber.",
         "draw": [C(-227.6, 93.4, 0.17)]},
    ],
    "play": [
        {"name": "The two rusted lengths", "z": [-0.2, 0.2], "style": "mark", "tag": [-238.25, 93.7],
         "text": "Already in the game (note 16): brown, cracked, a corner gone. They are drawn here so the page shows the place as it is.",
         "draw": [R(-239.0, 94.33, -237.5, 94.67), R(-244.0, 94.33, -242.5, 94.67)]},
        {"name": "Flanged joints on the main", "z": [-0.2, 0.2], "style": "pale", "tag": [-250.0, 93.8],
         "text": "A bolted flange every 3 m and at each end of a rusted length, drawn on the main. They say it is a pipe and not a girder.",
         "draw": [R(x - 0.08, 94.28, x + 0.08, 94.72) for x in (-250.0, -247.0, -241.0, -236.0)]},
        {"name": "The weir's stone lip", "z": [-1.2, 1.2], "style": "pale", "tag": [-245.3, 90.3],
         "text": "A pale stone coping on the edge the river goes over, with white water breaking on it. The pier's peaked top stays black and wet.",
         "draw": [R(-244.45, 90.7, -244.0, 91.0)]},
    ],
    "foreground": [
        {"name": "A pipe at the frame's east edge", "z": [1.3, 1.6], "tag": [-225.35, 96.5],
         "text": "One riser pipe with an elbow, in front of the solid rock east of the ledge. It stands in front of the play space, so it is scenery, and it never crosses open space.",
         "draw": [R(-225.5, 84.0, -225.2, 98.5)]},
        {"name": "The near bank's brick lip", "z": [1.3, 2.0], "style": "dark", "tag": [-252.0, 86.6],
         "text": "A low broken run of brick along the bottom of the frame, below the river's bed. It stops short of the weir, so nothing stands in front of the water or the fall.",
         "draw": [P([[-260.0, 86.1], [-260.0, 87.0], [-255.0, 87.25], [-250.0, 86.9], [-244.7, 87.1], [-244.7, 86.1]])]},
    ],
    "explains": [
        ["The main you cross on", "The works' wash-water main to the mine", "Its brackets on the back wall, and both its ends: up through the roof, and down the dry shaft"],
        ["The two rusted lengths", "Places where the main has rotted through", "The river, right under them, to take the pieces"],
        ["The chain", "The old boom chain, on its hanger", "The big bracket it hangs from"],
        ["The lip ledge", "The dry end of the weir", "The bricked-up arch, the lantern, the head of the dry shaft"],
        ["The landing and the ladder", "A brick landing on iron beams, and the rungs up to the wheel pit", "The beam ends under it"],
    ],
    "pieces": [
        ["Brick wall bay with a round arch: open at the waterline, bricked up", "3 m arch in a 6 m bay", "2 open, 1 bricked up", "Background", "kit: brick wall bay with a round arch"],
        ["Brick rib", "0.6 m wide, 6 m tall", "3", "Background", "kit: brick pier and buttress"],
        ["Wall bracket for the main", "0.25 m wide, 1.3 m", "6", "Background", "kit: iron_bracket"],
        ["Pipe run with elbows, far part of the main", "0.3 m across", "12 m", "Background", "kit: pipe_verdigris"],
        ["Flanged joint", "0.5 m", "4", "Play space (drawn on)", "kit: pipe run, rust orange"],
        ["Stone coping for the weir's lip", "0.45 m by 0.3 m", "1 in play, 1 run behind", "Play space, background", "kit: brick pier and buttress with stone coping"],
        ["Falling sheet, foam line, mist", "6 m wide, 7 m tall", "1", "All", "kit: water pieces (note 22)"],
        ["Works lantern on a wall bracket", "0.4 m", "1", "Background", "kit: lantern on a wall bracket (added below)"],
        ["Riser pipe with an elbow", "0.3 m across", "1", "Foreground", "kit: pipe_verdigris"],
        ["Near bank lip", "15 m long, 1 m tall", "1", "Foreground", "kit: near bank lip (added below)"],
    ],
    "effects": [
        "Drips from the bricked-up arch on to the lip ledge, as today.",
        "Mist standing over the slot, behind the main, never in front of it.",
        "A rusted length sheds flakes before it goes, and its pieces splash.",
    ],
    "notes": [
        "Note 16 (done): the two dark stretches are rusty breakable lengths.",
        "Note 22: the river bends over the weir's lip and becomes the fall. It is not a box that stops.",
    ],
}

# ------------------------------------------------------------------ 2.2 La Rueda
_WH = (-251.3, 100.8)
_paddles = []
for _k in range(6):
    _a = math.radians(60 * _k)
    _ex, _ey = _WH[0] + 2.0 * math.cos(_a), _WH[1] + 2.0 * math.sin(_a)
    _paddles.append(L(round(_ex + 0.35 * math.sin(_a), 2), round(_ey - 0.35 * math.cos(_a), 2),
                      round(_ex - 0.35 * math.sin(_a), 2), round(_ey + 0.35 * math.cos(_a), 2)))

LA_RUEDA = {
    "id": "2.2", "slug": "2_2_la_rueda", "title": "La Rueda", "kind": "challenge",
    "window": [-260.0, 91.0, -241.0, 109.0], "screen": [-250.5, 100.5], "cut_y": 100.8, "climber": [-254.4, 98.6],
    "place": ("The wheel pit. The race runs through the bottom of the mill and turns a water wheel, and the wheel turned everything "
              "else: it is one of a pair on the same axle, and the axle runs back through the wall to the mill's gearing. The mill "
              "is flooded and nothing is geared to it any more, but the race still runs, so the wheel still turns. You come up the "
              "wheelwright's ladder well, step on to his landing, and ride a paddle up."),
    "keep": [
        "The wheel: 4 m across, six spokes, where it is and turning as it turns today.",
        "The landing beside it and the ladder up the well.",
        "The race under it: fall off and it carries you east to the drain and back to the lip ledge.",
    ],
    "background": [
        {"name": "The pit's back wall and the wheel arch", "z": [-5.0, -2.4], "tag": [-245.0, 105.6], "top": True,
         "text": "Brick to the roof. Behind the wheel a round arch 5.4 m wide opens in it, with the race coming out of the dark under it. This is where the race's water comes from.",
         "draw": [R(-255.4, 96.8, -241.0, 107.4), arch(-254.0, -248.6, 96.8, 100.0, "dark")]},
        {"name": "The second wheel", "z": [-4.6, -3.8], "style": "line", "tag": [-252.9, 102.6], "top": True,
         "text": "The same wheel again, 4 m further back on the same axle, turning with yours in the dark of the arch. It is greyer and wetter than the one you ride. On the sketch it is the ring round your wheel's spokes.",
         "draw": [C(-251.3, 100.8, 2.0), C(-251.3, 100.8, 0.6)]},
        {"name": "The wheel's frame", "z": [-2.2, -1.4], "style": "line", "tag": [-253.4, 97.6],
         "text": "A cast-iron frame standing in the race just behind the wheel, with the axle's bearing at its top. Nothing stands in front of the wheel.",
         "draw": [L(-253.7, 96.8, -251.3, 100.8), L(-248.9, 96.8, -251.3, 100.8), L(-252.8, 98.3, -249.8, 98.3)]},
        {"name": "The ladder well's lining", "z": [-2.0, -1.2], "style": "pale", "tag": [-256.3, 104.5],
         "text": "A round brick well cut in half, 1.8 m across, with the iron rungs you climb let into it and a cast ring where it opens at the landing.",
         "draw": [R(-257.2, 95.9, -255.4, 107.4)]},
        {"name": "A works lantern", "z": [-2.5, -2.2], "style": "light", "tag": [-253.6, 105.5],
         "text": "On a wall bracket over the arch. Steady: nothing in this biome's light pulses (note 17). The moving light here is the slow shimmer the race throws up on the underside of the arch.",
         "draw": [C(-253.6, 104.8, 0.17)]},
    ],
    "play": [
        {"name": "Paddle boards and the hub", "z": [-0.6, 0.6], "style": "line", "tag": [-249.0, 103.2],
         "text": "Each spoke ends in a paddle board, drawn on its end, and the hub gets an iron boss with the company's pug cast in it. The boards lift water and drop it as they come round.",
         "draw": _paddles},
        {"name": "The landing's coping", "z": [-1.2, 1.2], "style": "pale", "tag": [-254.45, 97.9],
         "text": "A pale stone coping on the brick landing, like every place you stand in the works.",
         "draw": [R(-255.4, 98.45, -253.5, 98.6)]},
    ],
    "foreground": [],
    "explains": [
        ["The wheel", "The front one of two water wheels on one axle", "The second wheel in the arch, the frame and the bearing"],
        ["The landing", "The wheelwright's landing", "The ladder well opening on to it"],
        ["The ladder", "Iron rungs in a brick well", "The well's lining"],
        ["The race", "The mill's race", "The arch it comes out of"],
    ],
    "pieces": [
        ["Brick wall bay with a big round arch, open", "5.4 m arch", "1", "Background", "kit: brick wall bay with a round arch"],
        ["Second water wheel", "4 m across", "1", "Background", "kit: mill_wheel, greyed"],
        ["Water wheel frame", "to suit a 4 m wheel", "1", "Background", "kit: water_wheel_frame"],
        ["Ladder well lining", "1.8 m across, 11.5 m tall", "1", "Background", "new, this area only"],
        ["Paddle board; hub boss with the cast pug", "0.7 m board; 0.9 m boss", "6 boards, 1 boss", "Play space (drawn on)", "kit: mill_wheel, pug_stamp"],
        ["Stone coping", "1.9 m", "1", "Play space", "kit: brick pier and buttress with stone coping"],
        ["Works lantern on a wall bracket", "0.4 m", "1", "Background", "kit: lantern on a wall bracket (added below)"],
    ],
    "effects": [
        "Water lifted by each paddle and dropped from the top of the turn.",
        "A slow pale shimmer on the underside of the arch. No pulse.",
    ],
    "notes": [
        "Note 17: the lantern is steady and the only moving light is the water's shimmer.",
        "Note 22: the race comes out of the arch as moving water with streaks. The wheel sheds water.",
    ],
}

# ------------------------------------------------------------------ 2.3 El Acueducto
_CROWN = [(-249.1, -246.1, 101.4), (-243.1, -240.1, 101.8), (-236.3, -233.6, 102.2), (-228.5, -226.0, 102.6)]
_RINGS = [(-245.75, 103.35), (-244.5, 103.7), (-239.75, 103.75), (-238.5, 104.1), (-233.25, 104.15), (-232.3, 104.5)]
_BAYS = [(-246.6, -242.6, 98.9), (-240.6, -235.95, 98.95), (-233.95, -228.25, 98.85)]

EL_ACUEDUCTO = {
    "id": "2.3", "slug": "2_3_el_acueducto", "title": "El Acueducto", "kind": "challenge",
    "window": [-252.0, 95.0, -223.5, 113.5], "screen": [-239.0, 102.5], "cut_y": 101.35, "climber": [-247.6, 101.4],
    "place": ("The aqueduct was the wheel's feed: a brick trough on round arches, sloping gently down from the east wall to the top "
              "of the wheel. It was built two arches thick. The back half still stands whole. The front half, the half with the "
              "trough on it, has lost three spans into the race, and what is left of it is four pier tops with a stump of trough on "
              "each. On the wall above every span is a pair of iron rings: the masons' lifting rings, for the tackle that took the "
              "trough's plates out for cleaning."),
    "keep": [
        "The four pier tops and the three gaps of 3, 4 and 5 m, each a little higher than the last.",
        "The six rings, each exactly where it is. They do not move.",
        "The race under the gaps and the hatch ladder up the east wall.",
    ],
    "background": [
        {"name": "The standing arcade", "z": [-2.4, -1.3], "tag": [-237.8, 106.3], "top": True,
         "text": "The aqueduct's back half: the same four piers, with the three round arches still whole between them, and plain brick above the arches up to the roof. It shows what each gap was. The piers under your pier tops are its piers.",
         "draw": [R(-252.0, 96.8, -226.0, 107.4), arch(-254.0, -248.6, 96.8, 100.0, "dark")]
                 + [arch(x0, x1, 96.8, ys, "dark") for x0, x1, ys in _BAYS]},
        {"name": "Black water going back", "z": [-8.0, -2.4], "style": "line", "tag": [-238.3, 99.6],
         "text": "Through each arch: the race going back under a second, further arcade, lit only by the shimmer off the water.",
         "draw": [arch(-245.6, -243.6, 98.2, 98.9), arch(-239.5, -237.0, 98.2, 99.0), arch(-232.6, -229.6, 98.2, 99.0)]},
        {"name": "The fallen spans", "z": [-2.2, -1.3], "style": "pale", "tag": [-238.3, 97.3],
         "text": "Heaps of brick under the water at the foot of each gap, behind where you swim. You can't stand on them.",
         "draw": [P([[-245.8, 96.8], [-244.6, 97.5], [-243.4, 96.8]]), P([[-239.8, 96.8], [-238.3, 97.6], [-236.8, 96.8]]), P([[-233.0, 96.8], [-231.0, 97.7], [-229.0, 96.8]])]},
        {"name": "The hatch", "z": [-2.0, -1.2], "style": "pale", "tag": [-226.9, 108.7],
         "text": "The ladder up the east wall goes through the roof by a brick-lined hatch with a cast iron rim.",
         "draw": [R(-227.8, 107.4, -226.0, 110.0)]},
        {"name": "Ring pads and plates", "z": [-1.9, -1.2], "style": "pale", "tag": [-237.4, 104.6],
         "text": "Note 18: the six chains are gone. Behind each ring, a short brick pad built out from the arcade's wall with a riveted iron plate on its face, the way a mooring ring sits on a quay. The pad stops at the back edge of the play space. It is scenery because of where it stands.",
         "draw": [R(x - 0.4, y - 0.4, x + 0.4, y + 0.4) for x, y in _RINGS]},
        {"name": "Two works lanterns", "z": [-1.6, -1.3], "style": "light", "tag": [-241.6, 105.6],
         "text": "On brackets on the arcade's piers, not hung in the air between the rings. Steady.",
         "draw": [C(-241.6, 104.9, 0.17), C(-227.4, 105.0, 0.17)]},
    ],
    "play": [
        {"name": "The rings' eye bolts", "z": [-1.2, 0.2], "style": "line", "tag": [-246.7, 104.3],
         "text": "Each ring stands on a short eye bolt that points straight at you from its plate. From the side the bolt is hidden behind its own ring, so nothing new shows in the play space and nothing new can be held. Nothing hangs above a ring.",
         "draw": [C(x, y, 0.3) for x, y in _RINGS]},
        {"name": "Broken ends", "z": [-1.2, 1.2], "style": "mark", "tag": [-242.0, 100.4],
         "text": "Each pier top shows the trough's section on its broken end, and under it the first few bricks of the arch that sprang from it, drawn on.",
         "draw": [L(-246.1, 100.5, -245.5, 99.9), L(-243.1, 100.9, -243.7, 100.3), L(-240.1, 100.9, -239.5, 100.3),
                  L(-236.3, 101.3, -236.9, 100.7), L(-233.6, 101.3, -233.0, 100.7), L(-228.5, 101.7, -229.1, 101.1)]},
        {"name": "Copings", "z": [-1.2, 1.2], "style": "pale", "tag": [-234.95, 102.7],
         "text": "The pale stone rim of the trough along the top of each pier top. It is what you land on.",
         "draw": [R(x0, y - 0.15, x1, y) for x0, x1, y in _CROWN]},
    ],
    "foreground": [],
    "explains": [
        ["The four pier tops", "Stumps of the aqueduct's trough", "The standing arcade's piers, right behind them"],
        ["The three gaps", "Fallen spans", "The same three arches, whole, in the standing arcade, and the brick heaps in the race"],
        ["The six rings", "Lifting rings on eye bolts, fixed to the wall", "A brick pad and an iron plate behind each one, on the arcade's wall"],
        ["The race below", "The mill's race", "Black water going back through the arches"],
        ["The hatch ladder", "Iron rungs up the east wall", "The hatch's brick lining"],
    ],
    "pieces": [
        ["Arcade bay: pier, round arch, wall above", "4 to 5.7 m arch, 10.6 m tall", "3 bays", "Background", "kit: brick wall bay with a round arch; brick pier"],
        ["Far arcade", "2 to 3 m arches", "3", "Background, far", "kit: brick wall bay with a round arch"],
        ["Fallen brick heap", "2.4 to 4 m", "3", "Background", "new"],
        ["Wall ring on a plate, on a brick pad", "0.8 m plate, pad 0.7 m deep", "6", "Play space (the ring), background (plate and pad)", "kit: wall ring on a plate (note 18)"],
        ["Trough stump with a broken end and an arch springer", "3 m long, 0.9 m tall", "4", "Play space", "kit: brick pier and buttress with stone coping, broken end new"],
        ["Hatch lining with an iron rim", "1.8 m by 2.6 m", "1", "Background", "new, this area only"],
        ["Works lantern on a wall bracket", "0.4 m", "2", "Background", "kit: lantern on a wall bracket (added below)"],
    ],
    "effects": [
        "The mill channel's drain falling into the race between the third and fourth pier tops.",
        "Shimmer from the race on the undersides of the standing arches.",
    ],
    "notes": [
        "Note 18: the rings are bolted to the wall behind.",
        "Course change, scenery only: the six drawn chains go. No ring moves.",
        "Note 17: this is the place of the pulsing light. Lanterns here are steady and on the wall.",
        "Note 22: the race is one body of moving water, and the drain pours into it.",
    ],
}

# ------------------------------------------------------------------ 2.4 Brazo de Molino
BRAZO = {
    "id": "2.4", "slug": "2_4_brazo_de_molino", "title": "Brazo de Molino", "kind": "challenge",
    "window": [-251.0, 105.5, -224.0, 117.5], "screen": [-238.0, 111.3], "cut_y": 110.0, "climber": [-228.6, 110.3],
    "place": ("The wash house, one floor above the wheel. Ore was washed here in a long brick channel, the mill arm, with a steady "
              "stream sent down it from a culvert at the west end. Along the far bank stand the round tanks the washed ore settled "
              "in. A filler pipe comes out of the wall over the landing, runs out over the channel's drain and ends in an open "
              "spout, still dribbling. The washers got out of the channel by iron rungs in the west wall: the top two are left."),
    "keep": [
        "The channel: 14 m, its steady current east, and the drain at its east end that drops you to the race.",
        "The filler pipe you go out along, hand over hand, before you drop in.",
        "The two rungs at the west end and the two landings.",
    ],
    "background": [
        {"name": "The wash house's back wall", "z": [-5.0, -4.4], "tag": [-241.0, 114.6], "top": True,
         "text": "Brick, with two round arches barred with iron. The far background, blue-black, shows through the bars.",
         "draw": [R(-249.2, 108.4, -226.0, 115.6), arch(-243.2, -240.6, 110.0, 111.6, "dark"), arch(-239.4, -236.8, 110.0, 111.6, "dark")]},
        {"name": "The inlet culvert", "z": [-4.4, -1.2], "style": "dark", "tag": [-245.1, 111.6],
         "text": "A round arch at the waterline at the west end, with a rack of iron bars across it. The channel's water slides out of it. It is where the current comes from.",
         "draw": [arch(-246.3, -243.9, 108.4, 109.9), L(-245.5, 108.4, -245.5, 110.9, "line"), L(-244.7, 108.4, -244.7, 110.9, "line")]},
        {"name": "The far bank and the settling tanks", "z": [-4.2, -1.6], "style": "pale", "tag": [-233.3, 111.0], "top": True,
         "text": "A stone-coped bank just above the water, and on it two round iron tanks, 2.5 m across, riveted, dull blue-grey. A green pipe goes from each tank up into the roof.",
         "draw": [R(-243.6, 109.75, -230.8, 109.95), R(-235.8, 109.95, -233.3, 111.9), R(-232.9, 109.95, -230.9, 111.9),
                  L(-234.55, 111.9, -234.55, 115.6, "line"), L(-231.9, 111.9, -231.9, 115.6, "line")]},
        {"name": "The filler pipe's wall end", "z": [-4.4, -1.2], "style": "line", "tag": [-229.0, 113.2],
         "text": "Over the landing the pipe turns back into the wall through a teal valve wheel. Two wall brackets carry it out over the drain.",
         "draw": [C(-229.5, 112.3, 0.32), R(-232.2, 112.3, -232.0, 113.4, "pale"), R(-235.0, 112.3, -234.8, 113.4, "pale")]},
        {"name": "A works lantern", "z": [-4.4, -4.1], "style": "light", "tag": [-246.0, 114.4],
         "text": "On a wall bracket at the west end, over the rungs you are swimming for. Steady.",
         "draw": [C(-246.0, 113.7, 0.17)]},
    ],
    "play": [
        {"name": "The spout", "z": [-0.2, 0.2], "style": "pale", "tag": [-237.5, 113.0],
         "text": "The pipe's west end is drawn as a flared open mouth turned down, with a thin dribble of water falling from it. It marks the place to let go.",
         "draw": [P([[-236.6, 112.45], [-236.6, 112.15], [-237.0, 112.0], [-237.0, 112.5]])]},
        {"name": "Drowned rungs", "z": [-0.2, 0.2], "style": "mark", "tag": [-247.4, 109.0],
         "text": "Under the two rungs you can hold, three more show below the waterline, green and bent. The two are the top of a ladder.",
         "draw": [L(-246.6, 109.5, -246.3, 109.5), L(-246.6, 109.1, -246.3, 109.1), L(-246.6, 108.7, -246.3, 108.7)]},
        {"name": "Copings", "z": [-1.2, 1.2], "style": "pale", "tag": [-247.9, 112.4],
         "text": "Pale stone copings on both landings.",
         "draw": [R(-249.2, 111.65, -246.6, 111.8), R(-230.8, 110.15, -227.8, 110.3)]},
    ],
    "foreground": [
        {"name": "The channel's near wall, cut down", "z": [1.3, 1.8], "style": "dark", "tag": [-240.0, 107.75],
         "text": "One broken course of brick along the bottom, below the channel's bed and in front of solid rock. It says the channel has a near side. It is lower than the water's bed, so the whole swim is in clear view.",
         "draw": [P([[-246.6, 107.45], [-246.6, 107.95], [-242.0, 108.1], [-237.0, 107.9], [-232.9, 108.05], [-232.9, 107.45]])]},
    ],
    "explains": [
        ["The pipe you go out along", "The channel's filler pipe", "Its valve wheel and brackets on the wall, and its open spout"],
        ["The channel you swim", "The ore-washing channel", "The inlet culvert it runs from, the far bank and the tanks"],
        ["The two rungs", "The top of the washers' ladder", "The drowned rungs under them"],
        ["The landings", "Brick piers with stone copings", "The wash house's back wall"],
        ["The drain", "Where the channel spills down to the race", "The fall you saw from below, in El Acueducto"],
    ],
    "pieces": [
        ["Brick wall bay with a round arch, barred", "2.6 m arch", "2", "Background", "kit: brick wall bay with a round arch"],
        ["Culvert mouth with a bar rack", "2.4 m", "1", "Background", "kit: barrel cove, with bars"],
        ["Tank", "2.5 m", "2", "Background", "kit: tank"],
        ["Stone-coped bank", "13 m", "1", "Background", "kit: brick pier and buttress with stone coping"],
        ["Valve wheel, teal; wall brackets", "0.6 m; 1.1 m", "1 wheel, 2 brackets", "Background", "kit: valve_wheel, iron_bracket"],
        ["Spout end for the pipe", "0.5 m", "1", "Play space (drawn on)", "new, this area only"],
        ["Pipe run, verdigris", "0.2 m across", "2", "Background", "kit: pipe_verdigris"],
        ["Near bank lip", "13.7 m long, 0.6 m tall", "1", "Foreground", "kit: near bank lip (added below)"],
        ["Works lantern on a wall bracket", "0.4 m", "1", "Background", "kit: lantern on a wall bracket (added below)"],
    ],
    "effects": [
        "A dribble from the spout and its rings on the water.",
        "Streaks on the surface sliding east, and white water where the channel goes over its edge into the drain.",
    ],
    "notes": [
        "Note 22: the channel pours over its east edge into the drain. Its current is drawn as sliding streaks.",
        "Note 2: going in off the pipe throws the full splash.",
    ],
}

# ------------------------------------------------------------------ 2.5 Las Compuertas
_GATES = [(-250.28, 108.4, 111.8), (-252.4, 111.4, 114.8), (-254.52, 114.4, 117.8)]  # centre x, floor, top when down

_frames = []
for _cx, _fl, _top in _GATES:
    _frames += [R(_cx - 1.0, _fl, _cx + 1.0, _top + 4.6, "line"), R(_cx - 0.85, _fl, _cx + 0.85, _top + 0.9, "dark"),
                C(_cx + 0.7, _top + 4.2, 0.3, "line")]

COMPUERTAS = {
    "id": "2.5", "slug": "2_5_las_compuertas", "title": "Las Compuertas", "kind": "challenge",
    "window": [-260.5, 106.0, -243.0, 130.5], "screen": [-252.4, 116.5], "cut_y": 113.0, "climber": [-247.9, 111.8],
    "place": ("The gate hall. Three sluice gates stand in the back wall, one above the next like a flight of locks, and each let water "
              "on to one floor of the mill. A gate is too heavy to wind up by hand, so the company stood a water-pressure ram in "
              "front of each one. The works' regulator still runs them: pressure from the lake lifts a ram slowly, holds it, then "
              "the valve dumps and the gate's own weight slams it shut. What you ride is the head of a ram."),
    "keep": [
        "Three heads, each 2 m wide, on the three steps, rising 3.2 m and slamming, on today's timing.",
        "Only the riveted top of a head can be held. Everything under it is slick.",
        "The landing above them at 121 m.",
    ],
    "background": [
        {"name": "The gate hall's back wall", "z": [-3.0, -2.4], "tag": [-250.6, 127.4], "top": True,
         "text": "Brick, 20 m tall, wet and black low down where the gates leak, paler above.",
         "draw": [R(-255.6, 108.4, -249.2, 128.6)]},
        {"name": "The three gates", "z": [-2.4, -1.3], "style": "line", "tag": [-252.4, 118.3], "top": True,
         "text": "Behind each ram: a sluice gate in a cast-iron frame, with the pug cast in the frame's head and a rack and gear, seized, beside it. The gate's leaf is yoked to the ram's head and goes up and down with it. While a gate is up you see black water moving behind it.",
         "draw": _frames},
        {"name": "The regulator and its pipes", "z": [-2.4, -1.6], "style": "pale", "tag": [-252.4, 125.9],
         "text": "A riveted valve chest high on the wall, and a fat pipe from it down to each ram, all of it flat on the back wall, well behind the play space. This is what drives them, and you can see it.",
         "draw": [R(-253.3, 123.9, -251.5, 125.2), L(-250.4, 124.5, -250.4, 116.6, "line"), L(-252.4, 123.9, -252.4, 119.6, "line"),
                  L(-254.6, 124.5, -254.6, 122.6, "line"), L(-253.3, 124.5, -254.6, 124.5, "line"), L(-251.5, 124.5, -250.4, 124.5, "line")]},
        {"name": "A works lantern", "z": [-2.4, -2.1], "style": "light", "tag": [-251.0, 122.4],
         "text": "On a wall bracket beside the regulator. Steady.",
         "draw": [C(-251.0, 121.7, 0.17)]},
    ],
    "play": [
        {"name": "Housing, ram and head", "z": [-1.0, 1.0], "style": "mark", "tag": [-250.28, 110.0],
         "text": "Note 19: each rising block is redrawn as a machine piston, the same size and with the same top. A fixed iron housing stands on the step where the block rests today. A broad ram, as wide as the head, comes up out of it carrying the head. Housing and ram stand in the play space but are black with oil and running wet, so they plainly can't be held.",
         "draw": [R(_cx - 1.02, _fl, _cx + 1.02, _top - 0.24) for _cx, _fl, _top in _GATES]},
        {"name": "The heads", "z": [-1.0, 1.0], "style": "pale", "tag": [-256.3, 118.3],
         "text": "The part you hold: a thick riveted plate in rust orange with a raised rim, drawn on today's top.",
         "draw": [R(_cx - 1.02, _top - 0.24, _cx + 1.02, _top) for _cx, _fl, _top in _GATES]},
    ],
    "foreground": [
        {"name": "The regulator's supply pipe", "z": [1.3, 1.6], "tag": [-248.55, 122.0],
         "text": "One riser pipe in front of the solid rock east of the hall. It stands in front of the play space, so it is scenery, and it never crosses the hall.",
         "draw": [R(-248.7, 116.0, -248.4, 128.6)]},
    ],
    "explains": [
        ["The three heads you ride", "The heads of three water-pressure rams", "The gate each ram lifts, and the regulator that feeds it"],
        ["The slow rise and the slam", "Pressure lifts, weight slams", "The valve chest and its pipes"],
        ["The steps they stand on", "The sills of three gates, one above the next", "The three gate frames in the wall"],
        ["The landing at the top", "The gate keeper's landing", "The head of the top gate's frame"],
    ],
    "pieces": [
        ["Machine piston: housing, ram and head", "2.05 m wide, 3.4 m tall, 3.2 m of travel", "3", "Play space", "kit: machine piston (note 19), made to this size"],
        ["Sluice gate in an iron frame with a rack and gear", "2 m wide, 8 m tall", "3", "Background", "kit: sluice gate in an iron frame, narrow"],
        ["Valve chest", "1.8 m by 1.3 m", "1", "Background", "new, this area only"],
        ["Pipe run, verdigris", "0.5 m across", "3 drops, 1 riser", "Background, foreground", "kit: pipe_verdigris"],
        ["Cast pug", "0.6 m", "3, one on each frame", "Background", "kit: pug_stamp"],
        ["Works lantern on a wall bracket", "0.4 m", "1", "Background", "kit: lantern on a wall bracket (added below)"],
    ],
    "effects": [
        "A hiss and a jet of white spray at the housing as a ram rises.",
        "A clang, a shake and a burst of spray when it slams. The slam is the loud half.",
        "A thin leak down the back wall under each gate.",
    ],
    "notes": [
        "Note 19: the three rising gates are machine pistons. The housing stands where the block rests today, and the ram fills the space under the head as it rises, as the note's plan asks.",
        "Parker, 11-13: the name Las Compuertas stays. Each ram lifts a sluice gate that stands behind it.",
    ],
}

# ------------------------------------------------------------------ 2.6 Cadenas
CADENAS = {
    "id": "2.6", "slug": "2_6_cadenas", "title": "Cadenas", "kind": "challenge",
    "window": [-276.0, 108.0, -252.5, 132.0], "screen": [-264.5, 121.5], "cut_y": 120.8, "climber": [-257.0, 121.0],
    "place": ("The catch chamber of El Desague, the works' great drain. A riveted iron pipe 5 m across comes down through the roof, "
              "and under it an iron hopper funnels whatever falls into a wider pipe that drops to the river. The company opened the "
              "chamber for repairs: they lifted plates out of the hopper with three chain hoists on a crane beam, and stacked the "
              "plates in the gallery. Then the works flooded and nobody came back. The three chains still hang, over the hole."),
    "keep": [
        "The three chains, where they hang and how long they are.",
        "The slick hopper under them and the pipe below it: a miss goes down to the fast river.",
        "The landing you leave from and the gallery you land on.",
    ],
    "background": [
        {"name": "The chamber's back wall", "z": [-4.2, -3.6], "tag": [-268.0, 126.2], "top": True,
         "text": "Brick, with one round arch barred with iron high on the west side. The wall carries on down behind the hopper and the lower pipe.",
         "draw": [P([[-276.0, 120.7], [-271.2, 120.7], [-265.5, 114.0], [-265.5, 108.0], [-258.2, 108.0], [-258.2, 120.7], [-255.6, 120.7],
                     [-255.6, 128.6], [-272.0, 128.6], [-272.0, 125.6], [-276.0, 125.6]]), arch(-271.4, -268.6, 122.6, 124.0, "dark")]},
        {"name": "The hopper's back half", "z": [-3.6, -1.2], "style": "pale", "tag": [-262.0, 115.2], "top": True,
         "text": "Riveted iron plates, dull green-black and wet, sloping down to the lower pipe. Two plates are missing and brick shows through. The play space cuts the hopper in half: this is the half behind you.",
         "draw": [P([[-271.2, 120.7], [-265.5, 114.0], [-258.2, 114.0], [-258.2, 120.7]]), R(-263.4, 116.2, -261.6, 118.0, "dark"), R(-260.6, 118.4, -259.0, 120.0, "dark")]},
        {"name": "The upper pipe's mouth", "z": [-3.6, -1.2], "style": "pale", "tag": [-262.0, 129.4],
         "text": "A heavy bolted flange round the hole in the roof, with the company's pug cast in it. The back half of the ring shows.",
         "draw": [R(-264.5, 128.6, -259.5, 132.0, "solid"), R(-264.9, 128.2, -259.1, 128.6)]},
        {"name": "The crane beam and its three hoists", "z": [-1.7, -1.3], "style": "pale", "tag": [-267.3, 127.0],
         "text": "An iron beam under the roof, from wall to wall, with a hoist block on it over each chain. Each chain you hold comes down from its block. No other chain or loop hangs from the beam.",
         "draw": [R(-272.0, 127.7, -255.6, 128.1), C(-258.9, 127.9, 0.35, "line"), C(-265.3, 127.9, 0.35, "line"), C(-269.3, 127.9, 0.35, "line")]},
        {"name": "The lifted plates", "z": [-2.4, -1.4], "style": "pale", "tag": [-274.6, 124.0],
         "text": "Three curved hopper plates leaning against the gallery's back wall, where the fitters left them.",
         "draw": [P([[-275.6, 121.0], [-275.0, 121.0], [-274.6, 123.3], [-275.2, 123.3]]), P([[-274.8, 121.0], [-274.2, 121.0], [-273.8, 123.1], [-274.4, 123.1]])]},
        {"name": "A works lantern", "z": [-3.6, -3.3], "style": "light", "tag": [-256.7, 126.3],
         "text": "On a wall bracket over the landing. Today a lantern hangs in the air between the chains: it moves to the wall, so the only things hanging in this room are the three chains.",
         "draw": [C(-256.7, 125.6, 0.17)]},
    ],
    "play": [
        {"name": "The hopper's cut edge", "z": [1.1, 1.2], "style": "mark", "tag": [-269.6, 117.4],
         "text": "The slope you can see is the hopper cut through: a line of rivets and a plate seam along it, black and greased, drawn on.",
         "draw": [L(-271.0, 120.3, -265.6, 114.0), L(-258.3, 114.2, -258.3, 120.5)]},
        {"name": "Shackles", "z": [-0.2, 0.2], "style": "pale", "tag": [-257.9, 129.3],
         "text": "Each chain ends at the top in a big shackle on its hoist's hook, drawn at the roof. It hangs from a thing, not from the rock.",
         "draw": [R(-259.05, 128.2, -258.75, 128.6), R(-265.45, 128.2, -265.15, 128.6), R(-269.45, 128.2, -269.15, 128.6)]},
    ],
    "foreground": [],
    "explains": [
        ["The three chains", "Three hoist chains", "The crane beam and a hoist block over each one"],
        ["The slick slope under you", "The drain's iron hopper, cut through", "Its back half, with two plates out"],
        ["The landing you leave", "The gate keeper's landing", "The lantern on its wall"],
        ["The gallery you land on", "The fitters' gallery", "The lifted plates stacked on it"],
    ],
    "pieces": [
        ["Brick wall bay with a round arch, barred", "2.8 m arch", "1", "Background", "kit: brick wall bay with a round arch"],
        ["Hopper back half: riveted plates, two missing", "13 m by 6.7 m", "1", "Background", "new, this area only"],
        ["Pipe mouth flange with a cast pug", "5.8 m across", "1", "Background", "new; pug_stamp from the kit"],
        ["Crane beam", "16.4 m long, 0.4 m deep", "1", "Background", "new, this area only"],
        ["Hoist block", "0.7 m", "3", "Background", "kit: pulley (the mine's), in iron"],
        ["Chain on a hanger, with a shackle", "6.5 to 7.5 m", "3", "Play space", "kit: hanger_chain"],
        ["Loose hopper plate", "0.6 m by 2.3 m", "3", "Background", "new, this area only"],
        ["Works lantern on a wall bracket", "0.4 m", "1", "Background", "kit: lantern on a wall bracket (added below)"],
    ],
    "effects": [
        "A steady drip out of the upper pipe, falling straight through the room and down the hopper.",
        "A faint draught of mist up out of the lower pipe.",
    ],
    "notes": [
        "Note 20: the chains are real chains you swing on. Nothing here is a drawn chain.",
        "Note 18 applies here too: nothing thin that is only scenery hangs in this room.",
        "Course change, scenery only: the lantern that hangs in the air between the chains moves to the wall.",
    ],
}

# ------------------------------------------------------------------ 2.0 the frog's room
FROG = {
    "id": "2.0", "slug": "2_0_the_frogs_valve_chamber", "title": "The frog's valve chamber", "kind": "rest",
    "window": [-296.0, 111.0, -270.0, 129.0], "screen": [-284.0, 119.5], "cut_y": 118.6, "climber": [-288.5, 117.4],
    "place": ("A dry valve chamber, cut in the brick under the fitters' gallery. The keeper of the pool worked the outlet valve from "
              "here. It is a round brick vault 3 m wide and 2.6 m tall, and you walk into it from the east end of the ledge where "
              "El Charco del Pozo starts. Its round iron door was left ajar. You walk the gallery above without knowing it is "
              "there. When you drop to the ledge and turn round, the door is behind you. The frog lives in it."),
    "keep": [
        "Nothing on the route changes. The ledge, the drop on to it and the start of El Charco del Pozo stay as they are.",
        "The room is new floor: 3 m of it, level with the ledge, east of the ledge's end. Today that is solid.",
        "The frog is friendly only. Nothing to press, nothing gained (note 60).",
    ],
    "background": [
        {"name": "The pool hall's east wall and the gallery's wall", "z": [-3.4, -2.8], "tag": [-289.5, 125.5],
         "text": "The brick these two places already have behind them, drawn so you can see where the room sits: under the gallery, beside the ledge.",
         "draw": [R(-296.0, 113.0, -284.0, 128.0), R(-284.0, 120.7, -270.0, 125.6)]},
        {"name": "The room", "z": [-2.6, -1.2], "style": "dark", "over": True, "tag": [-281.6, 120.3], "top": True,
         "text": "Cut into brick that is solid today. Floor, back wall and a round barrel vault. No front wall: you see into it. Dry pale brick, the only dry room in the biome.",
         "draw": [arch(-284.0, -281.0, 117.4, 118.5)]},
        {"name": "The round iron door", "z": [-2.4, -1.3], "style": "line", "tag": [-285.0, 120.0],
         "text": "A riveted round door 1.9 m across with the pug cast in its middle and a hand wheel. It is hinged on the back jamb and stands half open against the pool hall's wall, out of your way. Its cast ring frame is set in the wall's end.",
         "draw": [C(-285.0, 118.4, 0.95), C(-285.0, 118.4, 0.25)]},
        {"name": "The outlet valve", "z": [-2.4, -1.6], "style": "line", "over": True, "tag": [-280.5, 118.5],
         "text": "Against the room's back wall, behind where you walk: a fat pipe up through the floor and into the east wall, with a big valve wheel on it at chest height and a round gauge above.",
         "draw": [C(-281.7, 118.5, 0.45), L(-281.7, 117.4, -281.7, 119.3), C(-281.7, 119.45, 0.14)]},
        {"name": "The frog", "z": [-2.0, -1.5], "style": "light", "over": True, "tag": [-283.1, 116.6],
         "text": "Sitting on the keeper's upturned bucket, 0.3 m tall, in a tiny oilskin hat. It breathes, blinks, watches you and croaks. You can hear it from the gallery above.",
         "draw": [R(-283.35, 117.4, -282.85, 117.65, "pale"), C(-283.1, 117.8, 0.15)]},
        {"name": "The keeper's lantern", "z": [-2.4, -2.1], "style": "light", "over": True, "tag": [-282.6, 119.5],
         "text": "A works lantern on a hook in the vault, lit. A patch of greenish light falls out of the door on to the ledge: that is how you find the room.",
         "draw": [C(-282.6, 119.0, 0.12)]},
    ],
    "play": [
        {"name": "The door's sill", "z": [-1.2, 1.2], "style": "pale", "over": True, "tag": [-281.0, 116.7],
         "text": "The ledge's stone coping runs on through the door's ring as a worn sill, level, with no step. The room's floor is dry pale brick.",
         "draw": [R(-284.2, 117.25, -281.0, 117.4)]},
    ],
    "foreground": [],
    "explains": [
        ["The ledge's east wall", "The end wall of a valve chamber, with its door", "The round door standing open against the back wall"],
        ["The room's floor", "The valve chamber's floor", "The valve, the gauge, the bucket and the frog"],
        ["The gallery above", "The chamber's roof", "The same brick, 0.7 m thick, between your feet and the frog"],
    ],
    "pieces": [
        ["The frog's room: a dry barrel-vaulted valve chamber", "3 m wide, 2.6 m tall, 1.4 m deep", "1", "Background", "kit: the frog, and its room"],
        ["Round iron door in a cast ring, with a cast pug", "1.9 m across", "1", "Background", "kit: the frog, and its room; pug_stamp"],
        ["Valve wheel, teal, on a pipe", "0.9 m wheel", "1", "Background", "kit: valve_wheel, pipe_verdigris"],
        ["Gauge; bucket", "0.3 m; 0.5 m", "1 each", "Background", "new, small"],
        ["The frog, in an oilskin hat", "0.3 m", "1", "Background", "kit: the frog (note 60)"],
        ["Works lantern", "0.4 m", "1", "Background", "kit: lantern_hang, re-tinted, on a hook inside the vault"],
    ],
    "effects": [
        "A croak when you are within a screen of it.",
        "The lantern's light on the ledge outside the door.",
    ],
    "notes": [
        "Note 60: one frog in every biome. The note's first idea was a barrel or the barrels' cove. This room is at the same pool, at its other end, and you can walk into it.",
        "Parker, 11-13: the room's place is settled.",
        "Course change: a room is cut in brick that is solid today, from x -284 to -281 and from 117.4 to 120 m, with 3 m of new floor level with the ledge.",
    ],
}

# ------------------------------------------------------------------ 2.7 El Charco del Pozo
CHARCO = {
    "id": "2.7", "slug": "2_7_el_charco_del_pozo", "title": "El Charco del Pozo", "kind": "challenge",
    "window": [-323.0, 108.0, -280.0, 141.0], "screen": [-300.0, 119.2], "cut_y": 117.0, "climber": [-287.0, 117.4],
    "place": ("The foot of El Pozo del Diablo. The well was here long before the company: a round shaft of black rock, 12 m across, "
              "that goes up through the whole mountain. The company built a brick hall round its foot and used the pool under it "
              "as a reservoir, and floated barrels across it from a store in the west wall. So the hall is brick on both sides and "
              "bare wet rock in the middle, where the well comes down. Stand under it and look up: the shaft goes up out of sight, "
              "and at the very end of it is one dot of light. You will cross this shaft three times higher up, and everything that "
              "falls from those crossings lands here. This is the place the mountain sends you back to."),
    "keep": [
        "The pool, the two ledges, and the lip the pool goes over at its east end.",
        "The barrels as note 21 has them: eight, unevenly spaced, out of the cove, drifting east, over the lip and down the fall. Two of the eight gaps are too wide to step across and have to be swum (Parker, 11-13).",
        "The well's mouth in the roof: 12 m wide, from x -306 to -294, and the camera's lean upward here.",
    ],
    "background": [
        {"name": "The hall's two brick flanks", "z": [-6.5, -5.5], "tag": [-316.0, 125.5], "top": True,
         "text": "Brick, 15 m tall, west and east of the well, each ending in a brick pier against the rock. A bricked-up round arch stands in the east flank. Each ledge sits on iron beams out of its flank: you see the beam ends under it.",
         "draw": [R(-320.5, 113.0, -306.5, 128.0), R(-293.5, 113.0, -284.0, 128.0), R(-307.1, 113.0, -306.5, 128.0, "pale"), R(-293.5, 113.0, -292.9, 128.0, "pale"),
                  arch(-292.3, -287.1, 115.0, 119.4, "line"), R(-290.5, 116.3, -290.2, 116.7, "pale"), R(-286.0, 116.3, -285.7, 116.7, "pale"),
                  R(-319.8, 116.1, -319.5, 116.5, "pale"), R(-315.0, 116.1, -314.7, 116.5, "pale")]},
        {"name": "The well's own rock", "z": [-6.5, -1.2], "style": "dark", "tag": [-303.6, 134.5], "top": True,
         "text": "Between the two flanks there is no brick: black wet rock, the back of the well, from the water up through the roof and on up. Where the hall's roof meets it there is a ring of pale stone, the collar the company put round the well's mouth. The well keeps this width, 12 m, at every place you will meet it.",
         "draw": [R(-306.5, 113.0, -293.5, 128.0), R(-306.0, 128.0, -294.0, 141.0), R(-306.8, 127.5, -305.6, 128.3, "pale"), R(-294.4, 127.5, -293.2, 128.3, "pale")]},
        {"name": "The throat", "z": [-8.0, -2.0], "style": "line", "tag": [-304.9, 122.0], "top": True,
         "text": "The look up the well, built the way a paper diorama builds a tunnel: five rings of black rock cut out of card, each smaller, further back and higher than the last. The first is 12 m across and touches the roof. The last is under 2 m. Each ring has a thin pale edge on its upper side, lit from above. Today this is one flat black shape. The rings make it a shaft.",
         "draw": [C(-300.0, 122.0, 6.0), C(-300.0, 123.2, 4.2), C(-300.0, 124.2, 2.8), C(-300.0, 125.0, 1.7), C(-300.0, 125.5, 0.9)]},
        {"name": "The dot of light", "z": [-8.0, -7.9], "style": "light", "tag": [-300.0, 127.2],
         "text": "Behind the last ring: one small pale dot, the top of the well, 365 m up. It is the only thing in the biome that is daylight. It does not flicker.",
         "draw": [C(-300.0, 125.9, 0.2)]},
        {"name": "What has fallen", "z": [-5.0, -3.4], "style": "pale", "tag": [-301.0, 114.0],
         "text": "On a shelf of rock at the back of the pool, under the well, far behind the barrels: a broken crystal point, a rotted mushroom cap as big as a table, a carved stone block with a pug's face, and a coil of rope. One thing from each place above where the well is crossed. All of it grey-blue and dim, like the rest of the scenery.",
         "draw": [P([[-305.5, 115.0], [-304.8, 115.5], [-297.2, 115.6], [-296.2, 115.0]], "solid"), P([[-304.2, 115.5], [-303.4, 115.5], [-303.0, 117.2]]),
                  P([[-302.4, 115.55], [-300.6, 115.55], [-300.9, 116.3], [-302.0, 116.4]]), R(-299.6, 115.6, -298.6, 116.4), C(-297.7, 115.9, 0.3, "line")]},
        {"name": "The barrels' cove", "z": [-4.4, -1.3], "style": "dark", "tag": [-312.7, 119.0],
         "text": "Note 21: a round brick arch at the waterline in the west flank, black inside, where the barrel store's slipway meets the pool. Each barrel floats forward out of the dark. It can't be touched until it is in your own plane.",
         "draw": [P([[-314.12, 114.4], [-311.28, 114.4], [-311.28, 116.3], [-311.7, 117.3], [-312.7, 117.75], [-313.7, 117.3], [-314.12, 116.3]]),
                  arch(-314.5, -310.9, 114.4, 116.3, "line")]},
        {"name": "The frog's door", "z": [-2.6, -1.2], "style": "dark", "over": True, "tag": [-282.5, 119.3],
         "text": "At the east end of the ledge you start from: the round iron door of the valve chamber, left ajar, and the room behind it. It has its own page.",
         "draw": [arch(-284.0, -281.0, 117.4, 118.5), C(-285.0, 118.4, 0.95, "line")]},
        {"name": "Two works lanterns", "z": [-5.5, -5.2], "style": "light", "tag": [-317.5, 122.2],
         "text": "One on each flank, on wall brackets, greenish and steady. There is no lantern under the well. The middle of the hall is lit only by the pale light that comes down the shaft.",
         "draw": [C(-317.5, 121.4, 0.17), C(-289.6, 122.6, 0.17)]},
    ],
    "play": [
        {"name": "The lip", "z": [-1.2, 1.2], "style": "pale", "tag": [-289.3, 114.0],
         "text": "A worn stone sill where the pool goes over into the fall, with white water breaking on it. A barrel tips on it before it goes.",
         "draw": [R(-288.25, 114.7, -287.85, 115.0)]},
        {"name": "Copings on the two ledges", "z": [-1.2, 1.2], "style": "pale", "tag": [-317.2, 118.0],
         "text": "Pale stone copings, as everywhere you stand in the works.",
         "draw": [R(-291.0, 117.25, -284.0, 117.4), R(-320.5, 117.05, -314.0, 117.2)]},
        {"name": "Hoops and brands", "z": [-0.9, 0.9], "style": "pale", "tag": [-310.2, 116.4],
         "text": "Each barrel gets two iron hoops and the company's pug branded on its end, drawn on. They are the mine's barrels: timber here is only ever a left-over from below.",
         "draw": [R(-313.25, 114.95, -313.0, 115.65), R(-312.2, 114.95, -311.95, 115.65)]},
    ],
    "foreground": [],
    "explains": [
        ["The barrels", "The mine's barrels, loose from the company's store", "The cove they come out of, and the fall they go over"],
        ["The ledge you start from", "A brick landing on iron beams, beside a valve chamber", "The beam ends, the round door, the bricked-up arch"],
        ["The west ledge", "The barrel store's landing", "The cove's arch beside it"],
        ["The pool", "The reservoir at the foot of the well", "The rock shelf at its back, and what has fallen on to it"],
        ["The lip", "The pool's stone sill", "The fall beyond it"],
        ["The hole in the roof", "The foot of El Pozo del Diablo", "Its own rock, its stone collar, the throat and the dot of light"],
    ],
    "pieces": [
        ["Brick wall bay, plain and with a bricked-up round arch", "5.2 m arch", "2 flanks", "Background", "kit: brick wall bay with a round arch"],
        ["Brick pier", "0.6 m wide, 15 m tall", "2", "Background", "kit: brick pier and buttress"],
        ["Well rock: wet black rock wall", "13 m wide, 15 m tall in the hall, and on up", "1", "Background", "from the mountain's shared structure: the well's wall"],
        ["Stone collar for the well's mouth", "1.2 m sections", "the back half of a 12 m ring", "Background", "new, this area only"],
        ["Throat rings", "12 m, 8.4 m, 5.6 m, 3.4 m, 1.8 m", "5", "Background, far", "new, this area only"],
        ["Dot of light", "0.4 m", "1", "Background, far", "in the course today as a card"],
        ["Barrel cove: a brick culvert mouth", "2.8 m across", "1", "Background", "kit: barrel cove (note 21)"],
        ["Fallen things: crystal point, mushroom cap, carved block, rope coil", "1 to 2 m each", "1 each", "Background", "borrowed from the kits of biomes 3, 4 and 5, greyed; rope coil from the mine's kit"],
        ["Iron beam end", "0.3 m", "4", "Background", "kit: iron_bracket"],
        ["Stone sill; copings", "0.4 m; 7 m and 6.5 m", "1 sill, 2 copings", "Play space", "kit: brick pier and buttress with stone coping"],
        ["Barrel with hoops and a branded pug", "1.8 m", "8", "Play space", "kit: barrel_float, pug_stamp"],
        ["Works lantern on a wall bracket", "0.4 m", "2", "Background", "kit: lantern on a wall bracket (added below)"],
    ],
    "effects": [
        "One slow drip down the middle of the well, landing in the pool with a ring. It has fallen a long way.",
        "A few pale motes drifting down the shaft, the same ones the well has all the way up.",
        "A faint pale light on the water under the well, and nothing brighter.",
        "A barrel going over the lip tumbles down the fall and splashes in the river below.",
    ],
    "notes": [
        "Note 21: the barrels come out of a modelled cove, eight of them, unevenly spaced, and go over the fall.",
        "Note 22: the pool bends over its lip into the fall. Foam where barrels and ledges meet the water.",
        "Note 60: the frog is not on a barrel or in the cove. It is in the valve chamber at the ledge's east end.",
        "Parker, 11-13: the three fallen things under the well stay: a crystal point, a mushroom cap, a carved temple block.",
        "Note 2 (Parker, 11-13): the water keeps its own tint in each cave. Here it is black where it is deep.",
    ],
}

# ------------------------------------------------------------------ 2.8 Contracorriente
_PIL = (-324.6, -330.1, -335.6)   # the pillars' middles

CONTRA = {
    "id": "2.8", "slug": "2_8_contracorriente", "title": "Contracorriente", "kind": "challenge",
    "window": [-352.0, 110.5, -317.5, 126.0], "screen": [-334.0, 117.5], "cut_y": 117.7, "climber": [-323.0, 118.0],
    "place": ("The flume: the brick tunnel that carries the river from the boiler house's tail pool down to the pool under the well. "
              "It is 25 m long and 8 m tall, with a row of brick pillars along its back holding up the vault. Beside each pillar a "
              "side culvert opens in the back wall, and in the mouth of each one the water lies almost still. The river comes "
              "hard down the middle. You swim it the wrong way."),
    "keep": [
        "The flume's length, its hard current east, and the three patches of still water.",
        "The ledge you start from, the iron grating at the far end, and the short chain that is the only way out.",
        "The three pillars stay behind the water. Nothing stands in the swim.",
    ],
    "background": [
        {"name": "The flume's back wall and its side culverts", "z": [-4.0, -2.2], "tag": [-341.5, 120.6], "top": True,
         "text": "Brick, black and wet to a tide line 1 m above the water. Three round culvert mouths at the waterline, one beside each pillar. The still water you rest in lies in front of each mouth.",
         "draw": [R(-346.0, 114.5, -320.5, 122.5), arch(-328.0, -325.2, 114.5, 116.6, "dark"), arch(-333.5, -330.7, 114.5, 116.6, "dark"), arch(-339.0, -336.2, 114.5, 116.6, "dark")]},
        {"name": "The three pillars", "z": [-2.2, -1.3], "style": "pale", "tag": [-330.1, 121.6], "top": True,
         "text": "Brick, 0.9 m wide, from the bed to the vault, each with a pale stone band at the waterline and a pointed stone nose facing the current. They mark where the still water is, from the far end of the flume.",
         "draw": [R(x - 0.45, 114.5, x + 0.45, 122.5) for x in _PIL]},
        {"name": "Through the culverts", "z": [-8.0, -4.0], "style": "line", "tag": [-326.6, 118.6],
         "text": "Black water going back to a second row of pillars, lit by the shimmer off the river.",
         "draw": [arch(-327.4, -325.8, 116.0, 116.5), arch(-332.9, -331.3, 116.0, 116.5), arch(-338.4, -336.8, 116.0, 116.5)]},
        {"name": "A depth gauge", "z": [-1.35, -1.3], "style": "dark", "tag": [-330.1, 119.4],
         "text": "A painted board on the middle pillar, marked in half metres, with the water well over the company's red line.",
         "draw": [R(-330.35, 115.2, -329.85, 118.6)]},
        {"name": "What the ledge and the grating hang from", "z": [-2.2, -1.2], "style": "pale", "tag": [-350.2, 117.2],
         "text": "Iron beams out of the back wall under each. You see their ends.",
         "draw": [R(-348.6, 117.3, -348.3, 117.7), R(-345.3, 117.3, -345.0, 117.7), R(-324.0, 117.1, -323.7, 117.5), R(-321.4, 117.1, -321.1, 117.5)]},
        {"name": "Two works lanterns", "z": [-1.6, -1.3], "style": "light", "tag": [-335.6, 121.4],
         "text": "On brackets on the first and third pillars, high, so the water under them is lit and nothing hangs over the swim.",
         "draw": [C(-335.6, 120.6, 0.17), C(-324.6, 120.9, 0.17)]},
    ],
    "play": [
        {"name": "The grating and the ledge", "z": [-1.2, 1.2], "style": "pale", "tag": [-346.8, 119.0],
         "text": "The far landing is drawn as an iron grating with water showing through it. The near ledge gets a stone coping.",
         "draw": [R(-349.0, 118.05, -344.5, 118.2, "mark"), R(-325.0, 117.85, -320.5, 118.0)]},
        {"name": "The chain's shackle", "z": [-0.2, 0.2], "style": "pale", "tag": [-343.4, 117.6],
         "text": "The way out hangs from a shackle on the grating's edge beam, drawn at its top.",
         "draw": [R(-344.6, 117.45, -344.3, 117.75)]},
    ],
    "foreground": [
        {"name": "The flume's near wall, cut down", "z": [1.3, 1.8], "style": "dark", "tag": [-333.0, 111.0],
         "text": "One broken course of brick along the bottom of the frame, a full 3 m below the water's bed. Nothing at all stands in front of the water.",
         "draw": [P([[-346.0, 110.5], [-346.0, 111.3], [-340.0, 111.55], [-333.0, 111.25], [-326.0, 111.5], [-320.5, 111.3], [-320.5, 110.5]])]},
    ],
    "explains": [
        ["The hard current", "The river in its flume", "The tunnel's back wall and its tide line"],
        ["The three still patches", "Slack water in the mouths of three side culverts", "The culvert mouths, and a pillar beside each one"],
        ["The ledge you start from", "A brick landing on iron beams", "The beam ends, the first pillar"],
        ["The grating at the far end", "The stoker's grating of the boiler house", "The beam ends under it"],
        ["The short chain", "A chain on a shackle", "The grating's edge beam"],
    ],
    "pieces": [
        ["Brick wall bay with a round arch, open at the waterline", "2.8 m arch", "3", "Background", "kit: brick wall bay with a round arch"],
        ["Flume pillar with a stone nose", "0.9 m wide, 8 m tall", "3, and 3 more far back", "Background", "kit: flume_pillar"],
        ["Depth gauge board", "0.5 m by 3.4 m", "1", "Background", "new, this area only"],
        ["Iron beam end", "0.3 m", "4", "Background", "kit: iron_bracket"],
        ["Grated catwalk plate", "4.5 m", "1", "Play space", "kit: grated catwalk"],
        ["Chain on a hanger, with a shackle", "1.2 m", "1", "Play space", "kit: hanger_chain"],
        ["Near bank lip", "25.5 m long, 1 m tall", "1", "Foreground", "kit: near bank lip (added below)"],
        ["Works lantern on a wall bracket", "0.4 m", "2", "Background", "kit: lantern on a wall bracket (added below)"],
    ],
    "effects": [
        "Long white streaks sliding east down the middle. Slow swirls in the three still patches.",
        "A foam line where the current parts on each pillar's nose.",
    ],
    "notes": [
        "Note 22: the river and its still patches are one body of water with no boxes. The current is read from streaks, the still water from swirls.",
        "Note 2: splashes going in and coming out.",
    ],
}

# ------------------------------------------------------------------ 2.9 Tuberia
_ROUTE = [(-349.3, 120.0), (-350.2, 121.2), (-351.0, 122.4), (-351.9, 123.6), (-352.6, 124.6), None,
          (-359.0, 124.6), (-360.0, 125.6), (-360.7, 126.9), (-361.6, 128.1), (-362.3, 129.3), (-363.0, 130.1), None,
          (-369.0, 130.1), (-370.0, 131.1), (-370.7, 132.4), (-371.6, 133.6), (-372.3, 134.7), (-372.9, 135.4), None,
          (-377.3, 135.4), (-377.6, 136.6), (-378.0, 138.0)]
_steam = [L(a[0], a[1], b[0], b[1]) for a, b in zip(_ROUTE, _ROUTE[1:]) if a and b]
_RUNS = [(-359.0, -352.6, 124.6), (-369.0, -363.0, 130.1), (-377.3, -372.9, 135.4)]

TUBERIA = {
    "id": "2.9", "slug": "2_9_tuberia", "title": "Tubería", "kind": "challenge",
    "window": [-386.0, 112.5, -342.5, 143.5], "screen": [-360.0, 126.0], "cut_y": 124.6, "climber": [-347.0, 118.2],
    "place": ("The boiler house. The boiler stands at the bottom, behind the stoker's grating, with its fire still in. Its steam "
              "pipe climbs the hall in three flights to the pump engine at the top, which lifted water back up to the works. The "
              "hall's floor is the tail pool, so everything stands on three brick piers, each a storey taller than the last, like "
              "a giant's stair. The steam pipe itself runs up the piers behind you, wrapped in lagging. At each joint a short bare stub comes forward "
              "off it and ends in a bolted flange, and those flanges are hot. Along the top of each pier runs a cold feed pipe, out in "
              "front where you can reach it: those are the three level runs where you can rest."),
    "keep": [
        "The eleven hot joints and the two cool ones, each exactly where it is, and how long a hot joint holds you (note 23).",
        "The three level runs, hand over hand.",
        "The tail pool under the whole climb, and the grating you start from.",
    ],
    "background": [
        {"name": "The boiler house's back wall", "z": [-6.0, -5.2], "tag": [-358.0, 138.0], "top": True,
         "text": "Brick, 27 m tall, sooty above the boiler and wet at the west end, where the pool above spills down it.",
         "draw": [R(-380.0, 114.5, -346.0, 142.0), L(-379.7, 116.0, -379.7, 136.0, "mark"), L(-379.2, 116.0, -379.2, 136.0, "mark")]},
        {"name": "The three piers", "z": [-5.2, -1.3], "style": "pale", "tag": [-366.0, 121.5], "top": True,
         "text": "Brick, standing in the tail pool, with a pale stone coping on each and a round arch through each at the waterline. Their tops are at 124, 129.5 and 135 m. The level runs are bracketed along their tops and the steam flights climb past their corners.",
         "draw": [R(-359.4, 114.5, -352.2, 124.1), R(-369.4, 114.5, -362.6, 129.6), R(-377.7, 114.5, -372.5, 134.9),
                  arch(-357.4, -354.2, 114.5, 116.4, "dark"), arch(-367.6, -364.4, 114.5, 116.4, "dark"), arch(-376.7, -373.5, 114.5, 116.4, "dark")]},
        {"name": "The boiler", "z": [-4.4, -1.4], "style": "line", "tag": [-351.6, 117.6], "top": True,
         "text": "End on, 3 m across, on a brick setting behind the grating. Its fire door glows orange with the pug cast on it: the warmest thing in the biome. The first cool joint is its stop valve, and the first hot joints are on the pipe leaving its top. A flue goes up the east wall.",
         "draw": [R(-351.3, 114.5, -347.9, 118.3, "pale"), C(-349.6, 119.7, 1.5), R(-349.95, 118.45, -349.2, 119.05, "light"),
                  R(-347.6, 120.6, -346.9, 142.0, "pale")]},
        {"name": "The steam pipe, lagged", "z": [-2.2, -1.7], "style": "line", "tag": [-361.9, 127.3],
         "text": "The steam pipe stands half a metre and more behind the play space, on the piers' faces, wrapped in lagging with wire bands. It is scenery because of where it stands. At each joint a bare stub comes straight forward off it to the flange you hold, hidden from the side behind its own flange. Today the pipe between the joints is drawn inside the play space and can't be held. By Parker's rule of 11-13 that is wrong, so it moves back.",
         "draw": _steam},
        {"name": "The pump engine", "z": [-4.6, -2.0], "style": "line", "tag": [-374.9, 140.2],
         "text": "On the top pier, where the steam pipe ends: a bed, a cylinder and a flywheel 3.2 m across, stopped. It is where the pipe was going.",
         "draw": [R(-377.2, 134.9, -373.2, 136.2, "pale"), C(-374.9, 137.8, 1.6), C(-374.9, 137.8, 0.3), L(-374.9, 137.8, -376.9, 136.4)]},
        {"name": "The feed tank", "z": [-4.6, -2.4], "style": "line", "tag": [-367.2, 132.8],
         "text": "A riveted iron tank on the middle pier, 2.5 m across, with the cold feed pipe going into its foot.",
         "draw": [R(-368.6, 129.6, -365.8, 132.0)]},
        {"name": "The works' bunting", "z": [-5.2, -5.0], "style": "mark", "tag": [-357.0, 141.0],
         "text": "One string of the town's paper flags, rotted, high under the roof and flat against the back wall. It is the only bunting in the biome. It is far from anything you hold.",
         "draw": [L(-362.0, 140.8, -352.0, 139.6)]},
        {"name": "Three lanterns and a warning plate", "z": [-1.6, -1.3], "style": "light", "tag": [-355.8, 122.4],
         "text": "A lantern on the face of each pier, under its level run. Beside the first hot joint, a cast plate: a hand and a flame (note 23).",
         "draw": [C(-355.8, 123.3, 0.17), C(-366.0, 128.8, 0.17), C(-375.1, 134.1, 0.17), R(-348.55, 121.5, -347.95, 122.1, "pale")]},
    ],
    "play": [
        {"name": "Straps on the level runs", "z": [-1.2, 0.2], "style": "mark", "tag": [-355.8, 125.5],
         "text": "Each level run is held by two iron straps on arms that go straight back to its pier. From the side an arm is hidden behind the run, so the run looks fixed and nothing new shows that you could take for a hold. A strap is part of its run: you hold it like the rest.",
         "draw": [s for x0, x1, y in _RUNS for s in (R(x0 + 0.5, y - 0.2, x0 + 0.8, y + 0.2), R(x1 - 0.8, y - 0.2, x1 - 0.5, y + 0.2))]},
        {"name": "The two cool joints", "z": [-0.4, 0.2], "style": "line", "tag": [-348.3, 120.6],
         "text": "Valve wheels with the pug cast in the hub, on the first joint and the last. A wheel is cool and a bare flange is hot: the shape tells you, and the glow. The eleven hot joints keep the glow, shimmer and flare the game already draws.",
         "draw": [C(-349.3, 120.0, 0.45), C(-377.6, 136.6, 0.45)]},
    ],
    "foreground": [
        {"name": "A riser at the frame's east edge", "z": [1.3, 1.6], "tag": [-345.45, 133.0],
         "text": "One riser pipe in front of the solid rock above the flume. It stands in front of the play space, so it is scenery, and it never crosses the hall or the pool.",
         "draw": [R(-345.6, 123.0, -345.3, 143.5)]},
    ],
    "explains": [
        ["The eleven hot joints", "Bare flanges on stubs off a live steam pipe", "The lagged pipe behind them, the boiler it leaves and the engine it reaches"],
        ["The two cool joints", "The boiler's stop valve and the engine's", "The boiler, and the pump engine"],
        ["The three level runs", "The cold feed pipe, strapped to its piers", "The pier behind each one, and the feed tank"],
        ["The grating you start from", "The stoker's grating", "The boiler's fire door, right behind it"],
        ["The pool under you", "The boiler house's tail pool", "The piers standing in it, with an arch through each"],
    ],
    "pieces": [
        ["Brick pier with stone coping and an arch through it", "5 to 7 m wide; 9.6, 15.1 and 20.4 m tall", "3", "Background", "kit: brick pier and buttress with stone coping"],
        ["Boiler, end on, with a glowing door and a cast pug", "3 m across", "1", "Background", "kit: boiler, pug_stamp"],
        ["Flue", "0.7 m across, 21 m", "1", "Background", "new, this area only"],
        ["Lagged steam pipe, with a bare stub at each joint", "0.5 m across; stubs 1 m long", "3 flights; 11 stubs", "Background", "new: pipe_verdigris, wrapped"],
        ["Hot joint: glowing flange", "0.5 m", "11", "Play space", "kit: hot joint"],
        ["Valve wheel, teal", "0.9 m", "2", "Play space", "kit: valve_wheel"],
        ["Pipe run, rust orange, with straps on arms", "0.3 m across; 6.4, 6 and 4.4 m", "3 runs, 6 straps", "Play space", "kit: pipe run, rust orange; strap and arm new"],
        ["Pump engine with a flywheel", "4 m", "1", "Background", "kit: pump engine"],
        ["Tank", "2.5 m", "1", "Background", "kit: tank"],
        ["Bunting", "10 m", "1", "Background", "kit: papel_tatters (the mine's)"],
        ["Warning plate: a hand and a flame", "0.6 m", "1", "Background", "new, this area only"],
        ["Riser pipe", "0.3 m across", "1", "Foreground", "kit: pipe_verdigris"],
        ["Works lantern on a wall bracket", "0.4 m", "3", "Background", "kit: lantern on a wall bracket (added below)"],
    ],
    "effects": [
        "Steam leaking from the lagging here and there, behind the pipe, never across a hold.",
        "The fire door's glow on the grating.",
        "The white spill down the west wall into the tail pool, with mist at its foot.",
    ],
    "notes": [
        "Note 23 (done): the hot joints glow, shimmer and flare before they let go. The cool joints are teal valve wheels.",
        "Note 22: the spill down the west wall is water pouring off the pool above.",
        "Parker, 11-13: a pipe that is in the play space can be held, so no scenery pipe stands in it.",
        "Course change, scenery only: the drawn pipe between the joints moves from inside the play space to half a metre behind it. No hold moves.",
    ],
}

# ------------------------------------------------------------------ 2.10 La Cascada Chica
_WET = [(-385.6, 139.4), (-386.7, 140.5), (-387.9, 141.5), (-388.8, 142.8), (-388.0, 150.0), (-389.2, 151.1), (-390.4, 152.2)]

CASCADA = {
    "id": "2.10", "slug": "2_10_la_cascada_chica", "title": "La Cascada Chica", "kind": "challenge",
    "window": [-397.0, 132.0, -374.0, 160.5], "screen": [-386.5, 145.0], "cut_y": 137.8, "climber": [-381.5, 138.0],
    "place": ("The weir hall. The upper reach ends here and goes over a stone-coped weir, 15 m down into a pool. The keepers had a way "
              "up beside the fall: a flight of stone treads built into the back wall, then an iron ladder up the wall, then a second "
              "flight to the catwalk. Each tread is a long stone with one end in the wall, and it is the free ends you hold. The "
              "ladder between the two flights has rusted away to stumps. Someone who came to climb the Peak hung a rope there instead, "
              "from the lifting beam under the roof. The fall's spray wets the treads in turn."),
    "keep": [
        "The seven holds, where they are, and the order the spray wets them in.",
        "The one rope: where it hangs, and that its end is where it is.",
        "The pool under the climb and the ledge you start from.",
    ],
    "background": [
        {"name": "The weir hall's back wall", "z": [-3.6, -2.6], "tag": [-382.4, 147.0], "top": True,
         "text": "Brick, 23 m tall, black and streaming at the west end beside the fall, drier to the east. A round culvert mouth at the pool and a round barred eye high up.",
         "draw": [R(-392.0, 134.5, -380.0, 158.0), arch(-388.6, -385.8, 134.5, 136.2, "dark"), C(-383.4, 153.6, 1.1, "dark")]},
        {"name": "The keepers' stair", "z": [-2.6, -1.2], "style": "pale", "tag": [-390.2, 144.4], "top": True,
         "text": "On the back wall behind your holds: the stone string of the lower flight, with each tread running back into it, then the two rails of the dead iron ladder with a stump where every rung was, then the string of the upper flight. You can see the whole way up the keepers had. Only its tread ends are left to you.",
         "draw": [P([[-385.3, 139.0], [-385.0, 139.3], [-388.9, 143.3], [-389.2, 143.0]]), P([[-387.5, 149.4], [-387.2, 149.7], [-390.9, 153.0], [-391.2, 152.7]]),
                  L(-388.65, 143.4, -388.65, 149.5, "mark"), L(-388.2, 143.4, -388.2, 149.5, "mark")]},
        {"name": "The weir, carried on behind", "z": [-6.0, -1.2], "style": "mark", "tag": [-390.7, 146.6],
         "text": "The weir's stone lip and the white sheet of the fall run back into the scene for the hall's whole depth. The fall you climb beside is its near edge.",
         "draw": [L(-391.5, 136.0, -391.5, 151.0), L(-390.7, 136.0, -390.7, 151.0), L(-390.0, 136.0, -390.0, 151.0), R(-392.4, 150.7, -391.6, 151.1, "pale")]},
        {"name": "The lifting beam", "z": [-2.6, -1.2], "style": "pale", "tag": [-384.2, 158.7],
         "text": "An iron beam under the roof with a ring on it, once used to lift the weir's boards. The rope is tied to the ring. It is a climber's rope, pale and dry, not the works' iron.",
         "draw": [R(-388.8, 157.3, -384.4, 157.8), C(-386.6, 157.55, 0.25, "line")]},
        {"name": "Two works lanterns", "z": [-2.6, -2.3], "style": "light", "tag": [-381.0, 142.1],
         "text": "On wall brackets: one over the ledge you start from, one high on the east side. Steady, and haloed by the mist.",
         "draw": [C(-381.0, 141.3, 0.17), C(-381.3, 156.0, 0.17)]},
    ],
    "play": [
        {"name": "Tread ends", "z": [-1.2, 0.3], "style": "mark", "tag": [-384.4, 140.3],
         "text": "Each hold is drawn as the squared end of a stone tread, 0.55 m wide, pale, with a worn nosing. While the spray is on it, it goes dark and shines.",
         "draw": [R(x - 0.28, y - 0.2, x + 0.28, y + 0.2) for x, y in _WET]},
        {"name": "The ledge's coping", "z": [-1.2, 1.2], "style": "pale", "tag": [-379.0, 137.2],
         "text": "A pale stone coping on the ledge over the pool.",
         "draw": [R(-385.0, 137.85, -378.0, 138.0)]},
    ],
    "foreground": [],
    "explains": [
        ["The seven wet holds", "The free ends of stone stair treads", "The stair's string on the back wall, and each tread running back into it"],
        ["The gap in the middle", "Where an iron ladder joined the two flights", "The ladder's two rails and its rusted stumps"],
        ["The rope", "A climber's rope", "The lifting beam and the ring it is tied to"],
        ["The ledge you start from", "A brick landing with a stone coping", "The lantern over it"],
        ["The pool and the fall", "The weir's pool and the weir", "The weir carrying on behind, and the culvert the pool drains by"],
    ],
    "pieces": [
        ["Brick wall bay with a round arch, open at the waterline; round barred eye", "2.8 m arch; 2.2 m eye", "1 each", "Background", "kit: brick wall bay with a round arch; eye new"],
        ["Stone stair tread, built into the wall", "0.55 m by 0.4 m, 2.5 m long", "7", "Play space, rooted in the background", "new"],
        ["Stair string, stone", "0.4 m band; 5.6 m and 5 m", "2", "Background", "new, this area only"],
        ["Dead ladder: two rails and rung stumps", "0.45 m wide, 6.1 m", "1", "Background", "new, this area only"],
        ["Stone coping for the weir's lip", "0.8 m", "1 run", "Background", "kit: brick pier and buttress with stone coping"],
        ["Lifting beam with a ring", "4.4 m", "1", "Background", "kit: wall ring on a plate; beam shared with Cadenas"],
        ["Falling sheet, foam line, mist", "2.5 m wide in the play space, 15 m tall", "1", "All", "kit: water pieces (note 22)"],
        ["Works lantern on a wall bracket", "0.4 m", "2", "Background", "kit: lantern on a wall bracket (added below)"],
    ],
    "effects": [
        "Spray drifting off the fall across the treads, in the order they get wet.",
        "Mist over the pool, thin enough to see the water through.",
        "Drips off the rope's end.",
    ],
    "notes": [
        "Note 22: the upper reach bends over the weir's lip and becomes the fall, and churns where it lands.",
        "Note 20: the rope is a real rope and swings as the fixed ropes will.",
    ],
}

# ------------------------------------------------------------------ the catwalk over the upper reach
_SOLID = [(-393.5, -391.5), (-407.3, -405.3), (-414.8, -412.8), (-425.5, -423.6)]
_BRK = [-393.2, -391.8, -407.0, -405.6, -414.5, -413.1, -425.2, -423.9, -402.95, -400.85, -398.75, -396.65, -394.55, -408.3, -410.4, -415.7, -417.6, -420.75, -422.65]

PASARELA = {
    "id": "2.10b", "slug": "2_10b_the_catwalk", "title": "The catwalk over the upper reach", "kind": "rest",
    "window": [-428.0, 146.5, -389.0, 160.0], "screen": [-409.0, 153.5], "cut_y": 152.9, "climber": [-406.3, 153.0],
    "place": ("Not a challenge: the walk between La Cascada Chica and the dam. The upper reach is a straight brick channel, and the "
              "keepers' catwalk runs along its back wall on iron brackets, 2 m over the water, from the weir to the dam's apron. "
              "It was a floor of iron grating in 2 m lengths with a hand rail. Most of the lengths have rusted through. Four are "
              "still sound: one at each end and two between. The river under it runs back to the weir."),
    "keep": [
        "The catwalk as note 24 made it: four sound plates, eleven rusted lengths that give way, and the three 1.3 m gaps.",
        "The river under it, running east to the top of La Cascada Chica.",
    ],
    "background": [
        {"name": "The channel's back wall", "z": [-3.4, -2.2], "tag": [-400.0, 158.9], "top": True,
         "text": "Brick, with round culvert mouths at the waterline every 6 or 7 m and black water going back under them.",
         "draw": [R(-425.5, 149.5, -392.0, 158.0)] + [arch(c - 1.4, c + 1.4, 149.5, 150.8, "dark") for c in (-396.5, -402.3, -408.6, -415.6, -422.4)]},
        {"name": "The catwalk's brackets", "z": [-2.2, -1.2], "style": "pale", "tag": [-406.3, 151.4], "top": True,
         "text": "A cast bracket out of the back wall under every length: two under each sound plate, one, bent, under each rusted one. At each gap a bracket stands empty.",
         "draw": [R(x - 0.08, 151.9, x + 0.08, 152.65) for x in _BRK] + [R(x - 0.08, 152.2, x + 0.08, 152.65) for x in (-404.6, -412.1, -419.1)]},
        {"name": "The back hand rail", "z": [-2.0, -1.7], "style": "line", "tag": [-398.0, 154.8],
         "text": "On the wall side only, 1.1 m up and half a metre behind the play space, so it is scenery and not a hold. Whole over the sound plates, bent or missing over the rest. There is no rail on the camera's side.",
         "draw": [L(-425.5, 154.1, -423.6, 154.1), L(-414.8, 154.1, -412.8, 154.1), L(-407.3, 154.1, -405.3, 154.1), L(-393.5, 154.1, -391.5, 154.1),
                  L(-423.6, 154.1, -421.0, 153.6, "mark"), L(-404.0, 153.7, -399.0, 154.0, "mark"), L(-411.5, 153.6, -409.0, 154.0, "mark")]},
        {"name": "The dam's main", "z": [-2.2, -1.8], "style": "line", "tag": [-417.0, 157.1],
         "text": "A fat pipe flat on the back wall under the roof, from the dam to the boiler house. It is 2 m behind the catwalk and 3 m above it: scenery.",
         "draw": [L(-425.5, 156.4, -392.0, 156.4)]},
        {"name": "Two works lanterns", "z": [-2.2, -1.9], "style": "light", "tag": [-409.9, 155.9],
         "text": "On wall brackets over the two rest plates, so the sound places are the lit places.",
         "draw": [C(-406.3, 155.3, 0.17), C(-413.8, 155.3, 0.17)]},
    ],
    "play": [
        {"name": "The gaps' edges", "z": [-1.0, 1.0], "style": "dark", "tag": [-404.65, 153.7],
         "text": "Note 52 (Parker, 11-13: all eight pits): the cut edge of the plate on each side of a gap can't be held. It is drawn black, greased and wet for its whole 0.3 m depth. The plates' tops, right up to the edge, hold as before.",
         "draw": [R(-405.3, 152.7, -405.2, 153.0), R(-404.1, 152.7, -404.0, 153.0), R(-412.8, 152.7, -412.7, 153.0), R(-411.6, 152.7, -411.5, 153.0),
                  R(-419.8, 152.7, -419.7, 153.0), R(-418.6, 152.7, -418.5, 153.0)]},
        {"name": "Sound plates", "z": [-1.0, 1.0], "style": "pale", "tag": [-413.8, 152.2],
         "text": "The four sound plates keep whole rust-orange grating with a riveted edge. The rusted lengths keep the breakable look they have today.",
         "draw": [R(x0, 152.85, x1, 153.0) for x0, x1 in _SOLID]},
    ],
    "foreground": [],
    "explains": [
        ["The four sound plates", "Catwalk lengths that are still whole", "Two brackets under each, the rail behind it, a lantern over the two in the middle"],
        ["The eleven rusted lengths", "Catwalk lengths rusted through", "One bent bracket under each, and the rail gone behind it"],
        ["The three gaps", "Lengths that have already fallen", "An empty bracket at each"],
        ["The river", "The upper reach, between the dam and the weir", "The culvert mouths along the back wall"],
    ],
    "pieces": [
        ["Brick wall bay with a round arch, open at the waterline", "2.8 m arch", "5", "Background", "kit: brick wall bay with a round arch"],
        ["Grated catwalk on brackets, with a railing: sound, rusted through", "1 m wide, 2 m lengths", "4 sound, 11 rusted", "Play space, background", "kit: grated catwalk"],
        ["Catwalk bracket: straight, bent, empty", "0.75 m", "8 straight, 11 bent, 3 empty", "Background", "kit: iron_bracket"],
        ["Pipe run, verdigris", "0.5 m across, 33.5 m", "1", "Background", "kit: pipe_verdigris"],
        ["Works lantern on a wall bracket", "0.4 m", "2", "Background", "kit: lantern on a wall bracket (added below)"],
    ],
    "effects": [
        "A rusted length sheds flakes and creaks before it goes, and its pieces splash.",
        "Streaks on the river sliding east.",
    ],
    "notes": [
        "Note 24 (done): the catwalk is mostly breakable floor.",
        "Note 52 (Parker, 11-13): all eight small pits get insides that can't be held. Three of them are these gaps.",
        "Course change: the six cut edges of the plates at the three gaps become slick.",
        "Note 22: the river is one moving body from the dam's apron to the weir.",
    ],
}

# ------------------------------------------------------------------ 2.11 La Presa
PRESA = {
    "id": "2.11", "slug": "2_11_la_presa", "title": "La Presa", "kind": "challenge",
    "window": [-462.0, 147.0, -422.0, 176.0], "screen": [-436.0, 159.5], "cut_y": 153.0, "climber": [-426.3, 152.2],
    "place": ("The dam: a wall of brick 15 m tall with the works' lake behind it. Its downstream side comes down in great steps, and "
              "those steps are its spillway: when the lake is high, water runs down them to the upper reach. The keeper did not climb "
              "the spillway. He walked into the dam. A low brick gallery goes in through the dam's foot to a lift shaft, and the shaft "
              "goes straight up inside the dam to its crest. In the shaft is one small iron cage with a hand winch on board. You stand "
              "in it and wind, and the winch's pinion climbs a toothed rack on the shaft's back wall. Stop winding and the cage sinks. "
              "The dam is cut open at the front, so you see the gallery, the shaft and the cage in section."),
    "keep": [
        "Note 25: one lift in place of the five platforms and five cranks. It travels the whole height they cover today, from the apron's level at 152.2 m to the crest's at 167 m, and it rises only while you wind.",
        "Parker, 11-13: the lift goes straight up in a shaft, and it always sinks when you stop winding. There is no catch.",
        "The apron you start from, the crest you step off on to, the lake behind it and the rungs out through the roof, all where they are today.",
    ],
    "background": [
        {"name": "The dam hall's back wall", "z": [-7.0, -6.0], "tag": [-430.5, 167.6], "top": True,
         "text": "Brick, far back, blue-black. The hall is wide: the dam runs a long way back into the scene.",
         "draw": [R(-440.0, 151.9, -425.5, 170.0), R(-459.0, 163.0, -440.0, 173.0)]},
        {"name": "The spillway, carried on behind", "z": [-6.0, -1.4], "style": "mark", "tag": [-432.9, 162.6], "top": True,
         "text": "The same steps run back into the scene for the dam's whole width. A round spill arch stands at their head, and white water comes down them behind you: a thin fall on each riser and a sheet on each tread. On the lowest riser the fall comes down beside the gallery's mouth, not across it.",
         "draw": [arch(-436.4, -435.0, 160.9, 162.0, "dark"), L(-434.65, 158.1, -434.65, 160.8), L(-432.05, 155.2, -432.05, 157.9), L(-429.45, 152.6, -429.45, 155.0)]},
        {"name": "The inspection gallery", "z": [-2.6, -1.2], "style": "dark", "over": True, "tag": [-434.6, 153.5], "top": True,
         "text": "Cut through brick that is solid today: a round barrel vault 7.8 m long and 2.6 m tall, from the apron to the foot of the shaft. Its back wall is brick streaked white where the dam seeps. Floor, back wall and roof, no front wall. Its mouth on the apron is a round arch with the pug cast on its keystone.",
         "draw": [R(-437.4, 151.9, -429.6, 154.5)]},
        {"name": "The lift shaft", "z": [-2.6, -1.2], "style": "dark", "over": True, "tag": [-438.7, 158.6], "top": True,
         "text": "Brick, 2.6 m wide, straight up from the gallery to the hall's roof: 18 m. The lower 12 m of it is cut in brick that is solid today. Its back wall is dry and pale near the top and black and wet at the foot.",
         "draw": [R(-440.0, 151.9, -437.4, 170.0)]},
        {"name": "Guide rails and the rack", "z": [-1.5, -1.25], "style": "line", "over": True, "tag": [-438.7, 164.6],
         "text": "On the shaft's back wall, just behind the play space: two iron guide rails the cage runs on, and between them a toothed rack that the winch's pinion climbs. They are scenery because of where they stand: flat on the back wall, behind the cage, where no hand reaches. The shaft's two side walls are bare.",
         "draw": [L(-439.6, 152.2, -439.6, 169.5), L(-437.8, 152.2, -437.8, 169.5), L(-438.7, 152.2, -438.7, 169.5, "mark")]},
        {"name": "The shaft's head and foot", "z": [-2.6, -1.2], "style": "pale", "over": True, "tag": [-438.7, 171.0],
         "text": "At the top, a buffer beam across the shaft under the roof. At the foot, a spring buffer in a shallow pit. They say where the cage's travel ends.",
         "draw": [R(-440.0, 169.5, -437.4, 169.8), R(-439.2, 151.9, -438.2, 152.15)]},
        {"name": "Three works lanterns", "z": [-2.4, -2.1], "style": "light", "over": True, "tag": [-433.5, 154.9],
         "text": "On wall brackets: one over the apron, one in the gallery, one over the crest. The one in the gallery is what you see first: a pool of teal light inside the dam. They are the last of the works' lanterns but one.",
         "draw": [C(-426.6, 156.4, 0.17), C(-433.5, 154.0, 0.14), C(-446.0, 170.6, 0.17)]},
    ],
    "play": [
        {"name": "The gallery's floor", "z": [-1.2, 1.2], "style": "pale", "over": True, "tag": [-431.0, 151.2],
         "text": "New floor: the apron's stone coping runs on into the dam, level, 7.8 m to the shaft's foot. The gallery's roof is 2.6 m up, black and wet.",
         "draw": [R(-437.4, 152.05, -429.6, 152.2)]},
        {"name": "The cage", "z": [-1.0, 1.0], "style": "pale", "over": True, "tag": [-441.0, 153.9],
         "text": "Note 25: a level deck 2 m wide with an open iron cage 2.2 m tall, no front and no sides at deck height, so you walk in from the gallery and out on to the crest. The winch stands on the cage's back frame with its crank facing you, 1.5 m above the deck. Its shaft goes straight back to the pinion on the rack. Drawn at the shaft's foot, and dashed at the crest where you step off. The crank, the deck and the cage's top bar can be held, as they are in the play space.",
         "draw": [R(-439.7, 152.2, -437.7, 152.4), C(-438.7, 153.7, 0.34, "line"), R(-439.7, 152.4, -437.7, 154.4, "mark"),
                  R(-439.7, 167.0, -437.7, 167.2, "mark"), R(-439.7, 167.2, -437.7, 169.2, "mark")]},
        {"name": "The shaft's east wall, carried up", "z": [-1.2, 1.2], "style": "dark", "tag": [-435.6, 165.6],
         "text": "New wall: today the shaft's east side would be open above the third step. A brick wall 0.6 m thick closes it from that step to the roof, black and wet. The cage stays in a shaft the whole way up.",
         "draw": [R(-437.4, 160.9, -436.8, 170.0)]},
        {"name": "The spillway steps", "z": [-1.2, 1.2], "style": "mark", "tag": [-431.0, 156.3],
         "text": "The steps that are in the play space today stay where they are, without their platforms and cranks: black wet stone with a film of water, each riser 2.9 m. They are the spillway's near edge. Nobody climbs them.",
         "draw": [L(-432.2, 155.1, -429.6, 155.1), L(-434.8, 158.0, -432.2, 158.0), L(-436.8, 160.9, -434.8, 160.9)]},
        {"name": "The cast pug", "z": [1.15, 1.2], "style": "line", "tag": [-444.5, 158.3],
         "text": "On the dam's cut face, between the lake and the shaft, where it is today: the First Top Dog, 3 m across, cast in iron and let into the brick. The brick round it gets drawn courses.",
         "draw": [C(-444.5, 160.5, 1.5)]},
    ],
    "foreground": [],
    "explains": [
        ["The cage's deck", "The dam keeper's lift", "The shaft it runs in, and the two guide rails on the shaft's back wall"],
        ["The winch handle", "The lift's own hand winch", "The toothed rack its pinion climbs, right behind it"],
        ["The gallery you walk in by", "The dam's inspection gallery", "Its seeping back wall, its lantern, its arch on the apron"],
        ["The big wet steps", "The near edge of the dam's spillway", "The same steps running back, the spill arch at their head and the water on them"],
        ["The apron", "The spillway's foot", "The lowest fall coming down beside the gallery's mouth"],
        ["The crest", "The top of the dam", "The shaft's head with its buffer beam, and the lake"],
    ],
    "pieces": [
        ["Winch lift: a cage with a hand winch on board", "2 m by 2.2 m", "1", "Play space", "kit: winch lift (note 25)"],
        ["Lift shaft: brick, with guide rails and a rack", "2.6 m wide, 18 m tall", "1", "Background", "kit: lift shaft"],
        ["Buffer beam; spring buffer", "2.6 m; 1 m", "1 each", "Background", "new, small"],
        ["Inspection gallery: a barrel vault with a round-arched mouth", "7.8 m long, 2.6 m tall, 2.4 m deep", "1", "Background", "kit: brick wall bay with a round arch, made long"],
        ["Shaft wall, black wet brick", "0.6 m thick, 9.1 m tall", "1", "Play space", "kit: brick pier and buttress, without a coping"],
        ["Spillway steps with stone copings", "2.6 m treads, 2.9 m risers", "3 in the play space, and the same behind", "Play space, background", "kit: brick pier and buttress with stone coping"],
        ["Spill arch", "1.4 m", "1", "Background", "kit: barrel cove, small"],
        ["Cast pug: large, and one on the gallery's keystone", "3 m; 0.6 m", "1 each", "Play space (drawn on), background", "kit: pug_stamp"],
        ["Spill off an edge; thin falling sheet", "2.9 m falls", "3 behind", "Background", "kit: water pieces (note 22)"],
        ["Works lantern on a wall bracket", "0.4 m", "3", "Background", "kit: lantern on a wall bracket (added below)"],
    ],
    "effects": [
        "A tick from the pinion for every tooth you gain, and a slow whirr from the winch's governor while the cage sinks.",
        "A boom from the buffer beam when the cage reaches the top, and a soft thump from the spring buffer if you let it sink to the foot.",
        "Water on the spillway behind, and its sound through the gallery's wall.",
    ],
    "notes": [
        "Note 25 and Parker, 11-13: one lift with its winch on board, straight up a shaft, 14.8 m, always sinking when you stop.",
        "Course change: the five lift platforms and the five wall cranks go. One cage with its crank on board takes their place.",
        "Course change: a shaft is cut in the dam from x -440 to -437.4, from 151.9 m up to where the top step is today at 163.8 m. The top step goes.",
        "Course change: a gallery is cut through the dam's foot from the apron to the shaft, x -437.4 to -429.6, 2.6 m tall, with its floor at the apron's height.",
        "Course change: a new slick wall, 0.6 m thick, closes the shaft's east side from the third step at 160.9 m to the roof at 170 m.",
        "The other three steps stay where they are, bare. They become the spillway's near edge.",
        "Note 22: the dam's leak is the spillway's water, pouring step by step behind you. It is not a slab of water beside the dam.",
    ],
}

# ------------------------------------------------------------------ the join: the black waters to the crystal cave
JOIN_3 = {
    "id": "2 to 3", "slug": "2_to_3_the_dams_crest", "title": "The dam's crest", "kind": "join", "also": ["a3"],
    "window": [-463.0, 160.0, -436.0, 187.0], "screen": [-449.5, 173.0], "cut_y": 172.0, "climber": [-445.5, 167.0],
    "place": ("The top of the works, and the end of everything anyone built until the temple. The crest is the dam's walkway, with the "
              "lake on its far side under a brick vault. An iron ladder goes up from the crest through a brick shaft in the roof. "
              "But the roof is giving way to what is above it: crystals have grown down through the top courses of the brick and "
              "split them. The lake is not black. It is clear, and it is lit from below by crystals on its bed, because this water "
              "comes from the cave. Teal lantern light reaches as far as the foot of the ladder. Violet light comes down the shaft "
              "to meet it. Two steps above the shaft's rim, the brick is gone."),
    "keep": [
        "The crest, the lake and the rungs, exactly as they are.",
        "The way out: up the rungs, through the roof, on to the cave's first floor.",
    ],
    "background": [
        {"name": "The lake's brick vault", "z": [-6.0, -4.0], "tag": [-456.5, 170.6], "top": True,
         "text": "Slate-grey brick over the lake, in round-arched bays. Its top three courses are cracked, and pale light shows in the cracks.",
         "draw": [R(-459.0, 163.0, -440.0, 173.0), arch(-458.2, -454.6, 166.2, 168.2, "line"), arch(-453.6, -450.0, 166.2, 168.2, "line")]},
        {"name": "The shaft's lining", "z": [-2.4, -1.2], "tag": [-451.6, 175.2],
         "text": "Brick, in a round shaft cut in half, from the hall's roof up to the cave's floor. Sound at the bottom, split open by crystal at the top.",
         "draw": [R(-456.0, 172.9, -449.0, 176.0), L(-456.0, 174.4, -449.0, 174.4, "line"), L(-456.0, 175.6, -449.0, 175.6, "line")]},
        {"name": "Crystals grown down through the brick", "z": [-3.0, -1.3], "style": "pale", "over": True, "tag": [-445.2, 172.4], "top": True,
         "text": "Rough points of the cave's crystal, deep blue-violet because they are scenery, coming down out of the roof and through the shaft's lining, each with split and shouldered-aside brick round its root. One of them, over the crest, is bright white and is the first of the cave's lights.",
         "draw": [P([[-447.7, 174.5], [-446.5, 174.5], [-446.9, 170.9]]), P([[-444.4, 174.0], [-443.5, 174.0], [-443.7, 171.6]]),
                  P([[-456.6, 175.8], [-456.6, 174.6], [-453.8, 173.7]]), P([[-456.9, 173.6], [-455.6, 173.6], [-455.9, 171.2]]),
                  P([[-442.4, 173.6], [-441.6, 173.6], [-441.9, 172.0]], "light")]},
        {"name": "The lake's bed", "z": [-5.0, -2.0], "style": "pale", "tag": [-454.6, 162.2],
         "text": "Clear water, and through it small crystal points on the bed at the back, glowing faintly. They light the lake from below. They are behind where anyone would swim.",
         "draw": [P([[-457.8, 163.0], [-457.0, 163.0], [-457.2, 164.4]]), P([[-455.2, 163.0], [-454.2, 163.0], [-454.9, 164.9]]), P([[-452.0, 163.0], [-451.3, 163.0], [-451.5, 164.1]])]},
        {"name": "Violet light down the shaft", "z": [-2.0, -1.3], "style": "mark", "tag": [-452.5, 179.6],
         "text": "A soft violet light falls down the shaft and lies on the lake under it. Where it meets the last lantern's teal, on the crest, the brick is lit in both colours.",
         "draw": [L(-453.2, 181.0, -453.2, 166.2), L(-451.8, 181.0, -451.8, 166.2)]},
        {"name": "The last lantern and the last pug", "z": [-4.0, -1.4], "style": "line", "tag": [-447.3, 169.2],
         "text": "On the crest, far back: the dam's sluice wheel on its spindle, with the pug cast in its hub and a crust of crystal on its rim. Over it, the last works lantern. After this there is no iron, no brick and no lantern until the temple.",
         "draw": [C(-447.3, 168.0, 0.5), L(-447.3, 167.0, -447.3, 167.5), C(-443.0, 170.4, 0.17, "light")]},
        {"name": "The head of the lift shaft", "z": [-1.5, -1.25], "style": "line", "over": True, "tag": [-438.7, 171.0],
         "text": "At the crest's east end: the top of the dam's lift shaft, with its two guide rails and its buffer beam. It belongs to La Presa's page and is drawn here only so the two agree.",
         "draw": [L(-439.6, 160.0, -439.6, 169.5), L(-437.8, 160.0, -437.8, 169.5), R(-440.0, 169.5, -437.4, 169.8, "pale")]},
        {"name": "The cave's first crystals", "z": [-4.0, -1.4], "style": "pale", "tag": [-457.6, 180.2],
         "text": "Above the roof: the clusters that stand on the cave's first floor today. They belong to the crystal cave's own pages and are drawn here only so the two agree.",
         "draw": [P([[-458.8, 176.0], [-456.4, 176.0], [-457.4, 179.2]]), P([[-447.2, 176.0], [-446.0, 176.0], [-446.4, 177.6]])]},
    ],
    "play": [
        {"name": "Crusted rungs", "z": [-0.3, 0.3], "style": "pale", "tag": [-448.2, 177.3],
         "text": "The ladder is rust-orange iron from the crest up to the cave's floor. Its last 2 m, above the floor, are crusted with rough pale lilac crystal. It is the same ladder and the same hold. The works' way of saying you can hold it hands over to the cave's way on one rung.",
         "draw": [R(-449.75, 176.0, -449.25, 178.2)]},
        {"name": "Split copings", "z": [-1.2, 1.2], "style": "mark", "tag": [-444.9, 166.0],
         "text": "The crest's stone coping is cracked in two places, with a thin seam of crystal in each crack, drawn on. Nothing sticks up: the walk is as flat as today.",
         "draw": [L(-446.6, 167.0, -446.3, 166.4), L(-443.2, 167.0, -443.5, 166.4)]},
        {"name": "The shaft's rim", "z": [-1.2, 1.2], "style": "pale", "tag": [-447.6, 175.3],
         "text": "Where the ladder comes out on the cave's floor: half a ring of the works' pale stone, and the other half already crystal. Today a small pale block stands here.",
         "draw": [R(-449.0, 175.7, -448.4, 176.5)]},
    ],
    "foreground": [],
    "explains": [
        ["The crest", "The dam's walkway", "The sluice wheel on it, and the lake's vault beyond"],
        ["The rungs", "The keeper's ladder up the shaft", "The shaft's brick lining, split by crystal"],
        ["The lake", "The works' lake, fed from the cave", "Its lit bed, and the vault over it"],
        ["The cave's first floor", "The roof of the works, seen from above", "The shaft's rim, half stone and half crystal"],
    ],
    "pieces": [
        ["Brick wall bay with a round arch, bricked up", "3.6 m arch", "2", "Background", "kit: brick wall bay with a round arch"],
        ["Shaft lining: sound, split", "7 m wide, 3.1 m tall", "1", "Background", "new, this join only"],
        ["Wall point, as scenery: a crystal through brick, with a broken-brick collar", "0.9 to 1.2 m across, 2.2 to 3.6 m long", "5, one of them bright", "Background", "kit of biome 3: wall point; the broken-brick collar is new"],
        ["Small crystal point for the lake's bed", "0.7 to 1 m", "3", "Background", "kit of biome 3: cluster on a rock collar"],
        ["Valve wheel with a cast pug, crusted", "1 m", "1", "Background", "kit: valve_wheel, pug_stamp"],
        ["Crystal crust for the top rungs", "0.5 m wide, 2.2 m", "1", "Play space (drawn on)", "new, this join only"],
        ["Shaft rim: half stone, half crystal", "0.6 m by 0.8 m", "1", "Play space", "new, this join only"],
        ["Works lantern on a wall bracket", "0.4 m", "1", "Background", "kit: lantern on a wall bracket (added below)"],
    ],
    "effects": [
        "Clear water: you can see the bed, and the lake has no black in it.",
        "A slow glitter drifting down the shaft, the first of the cave's.",
        "No drips and no steam here. The works' noise stops at the crest.",
    ],
    "notes": [
        "Note 22: the lake is still water with a moving surface, and it is the one clear water in the biome.",
        "Note 2 (Parker, 11-13): the water keeps its own tint in each cave. The lake is the black waters' tint at its thinnest, clear enough to see the bed.",
        "The cave's note 26 starts above: the first steps of Primer Destello are pointed crystals out of the back wall.",
    ],
}

KIT_MORE = [
    ["Near bank lip: a low broken run of brick", "to suit, 0.6 to 1 m tall", "the near side of a channel, along the bottom of the frame and below the water's bed", "Foreground", "new"],
    ["Works lantern on a wall bracket", "0.4 m lantern on a 0.6 m arm", "every lantern in the biome: none hangs in the air near a climb", "Background", "in the kit: lantern_hang and iron_bracket, put together"],
]

AREAS = [EL_BORDE, LA_RUEDA, EL_ACUEDUCTO, BRAZO, COMPUERTAS, CADENAS, FROG, CHARCO, CONTRA, TUBERIA, CASCADA, PASARELA, PRESA, JOIN_3]
