# The temple's areas, one dict each, in the order you meet them. Format: see ../build.py.
# Every area is drawn from the biome's sheet (a5_biome.py).


# ------------------------------------------------------------------ shared shapes
def _arch(cx, y, w=3.0, h=4.5, style="dark"):
    """A stepped arch doorway: two sides stepping in to a flat lintel. Never round."""
    a, b, c = w / 2.0, w / 3.0, w / 6.0
    return ["poly", [[cx - a, y], [cx - a, y + h * 0.62], [cx - b, y + h * 0.62], [cx - b, y + h * 0.82], [cx - c, y + h * 0.82], [cx - c, y + h],
                     [cx + c, y + h], [cx + c, y + h * 0.82], [cx + b, y + h * 0.82], [cx + b, y + h * 0.62], [cx + a, y + h * 0.62], [cx + a, y]],
            {"style": style}]


def _torch(x, y):
    """A torch in a bronze bracket, its foot at (x, y)."""
    return [["line", x, y, x, y + 0.6, {"style": "pale"}], ["circle", x, y + 0.85, 0.24, {"style": "light"}]]


def _torches(pts):
    out = []
    for x, y in pts:
        out += _torch(x, y)
    return out


def _frieze(x0, x1, top):
    """The carved band, 0.8 m tall."""
    return ["rect", x0, top - 0.8, x1, top, {"style": "pale"}]


def _banner(x, top):
    """A cut-paper banner, 1.2 m by 3 m, hung from its top edge."""
    return ["rect", x - 0.6, top - 3.0, x + 0.6, top, {"style": "pale"}]


def _column(x, y0, y1, w=1.2):
    """A square carved column with a pug capital."""
    return [["rect", x - w / 2, y0, x + w / 2, y1, {"style": "pale"}], ["rect", x - w / 2 - 0.25, y1 - 0.6, x + w / 2 + 0.25, y1, {"style": "pale"}]]


# ------------------------------------------------------------------ 5.1 La Puerta
_TIERS = [(-332.0, 368.5), (-335.0, 371.0), (-338.0, 373.5), (-341.0, 376.0), (-344.0, 378.5)]   # each tier's east edge and its top
_FALSE = [(-335.0, 371.0), (-341.0, 376.0), (-344.0, 378.5)]                                         # the three that slide

_platform = [["poly", [[-332.0, 366.0], [-332.0, 368.5], [-335.0, 368.5], [-335.0, 371.0], [-338.0, 371.0], [-338.0, 373.5], [-341.0, 373.5],
                       [-341.0, 376.0], [-344.0, 376.0], [-344.0, 378.5], [-347.0, 378.5], [-347.0, 381.0], [-350.5, 381.0], [-350.5, 371.5], [-342.0, 366.0]]]]
_platform += [["line", x - 3.0, top - 1.8, x, top - 1.8, {"style": "mark"}] for x, top in _TIERS]
_slots = [["rect", x - 5.7, top - 1.1, x, top + 0.05] for x, top in _FALSE]

LA_PUERTA = {
    "id": "5.1", "slug": "5_1_la_puerta", "title": "La Puerta", "kind": "challenge",
    "window": [-350.5, 361.5, -305.5, 386.5], "screen": [-338.0, 371.5], "cut_y": 368.0, "climber": [-322.0, 366.0],
    "place": ("This is the temple's front door and the hall inside it. You come through a doorway 16 m tall, cut through the well's wall, onto "
              "33 m of fitted paving. At the far end the floor meets the great stepped platform that the First Top Dog's mask sits on: five "
              "tiers, each 2.5 m high and 3 m deep, built for someone much bigger than you. The tiers are the first test. Three of them are "
              "false: each is a slab on bronze shoes in a slot, and when weight comes onto it, it draws back under the tier above. Under the "
              "platform runs the chute, a slope of polished black stone. The temple was built with a way back down from every test, and they "
              "all end on this floor."),
    "keep": [
        "The five tiers and the landing, each exactly where it is, and which three slide: the second, the fourth and the fifth.",
        "How a false tier moves: 2.6 m west under the tier above, half gone in a second, back after 4 seconds.",
        "The chute under the upper tiers, and the open floor in front of the door.",
        "Nothing stands in front of the tiers or the floor above the level of the paving.",
    ],
    "background": [
        {"name": "The entry hall's back wall", "z": [-7.0, -6.0], "tag": [-311.0, 384.6], "top": True,
         "text": "Wall bays of pale fitted blocks, 4 m wide and 5 m tall, one row above another, with the carved band between the rows. It runs the whole width of the frame and out of its top, so there is no black behind anything (note 51). It is 6 m back, in brown shadow.",
         "draw": [["rect", -350.5, 366.0, -309.0, 386.5], _frieze(-332.0, -309.0, 371.8), _frieze(-332.0, -309.0, 377.6), _frieze(-341.0, -309.0, 383.4)]},
        {"name": "Two doorways", "z": [-7.0, -6.0], "style": "dark", "tag": [-327.5, 367.6],
         "text": "Two stepped arch doorways in the back wall, dark inside, each with a small stone pug plaque over it and a cut-paper banner high above. The hall goes on behind you. Today one mask 6 m across hangs on this wall. It goes: the first big face you see should be the great mask at the top of the tiers.",
         "draw": [_arch(-327.5, 366.0), _arch(-321.5, 366.0), ["circle", -327.5, 373.3, 0.75, {"style": "line"}], ["circle", -321.5, 373.3, 0.75, {"style": "line"}],
                  _banner(-327.5, 382.2), _banner(-321.5, 382.2)]},
        {"name": "The fall strip", "z": [-6.0, -5.6], "style": "pale", "tag": [-315.5, 380.0],
         "text": "A carved strip 5 m wide runs up the back wall and out of the frame, behind the place where the great hall's drain comes down. Small carved figures fall down it, head first, all the way from the top. You walk past it on your way in, before you know what it is for.",
         "draw": [["rect", -318.0, 366.0, -313.0, 386.5], ["line", -316.5, 386.5, -316.5, 366.4, {"style": "mark"}], ["line", -314.5, 386.5, -314.5, 366.4, {"style": "mark"}]]},
        {"name": "The platform the mask sits on", "z": [-5.5, -1.3], "style": "pale", "tag": [-345.5, 374.2], "top": True,
         "text": "The body of the stepped platform, right behind the tiers you climb. Each tier you touch is the front edge of a terrace that runs 4 m back into the scene. On the platform's face under each tier, a carved band shows small figures climbing the tiers, and one of them being scraped off.",
         "draw": _platform},
        {"name": "Three slots", "z": [-2.4, -1.2], "style": "dark", "tag": [-339.7, 370.4],
         "text": "Each false tier rides in a slot cut along the platform's face and lined with bronze. The slot is 5.7 m long: the 3 m the tier fills, and 2.6 m of empty channel to the west of it. The empty channel shows you, before you step, that this tier moves and how far it goes. The true tiers have no slot.",
         "draw": _slots},
        {"name": "The door through the well's wall", "z": [-3.0, -1.2], "style": "pale", "tag": [-307.2, 375.0],
         "text": "The side of the doorway: the same pale blocks, with the wall stepping in above your head. The mushroom garden has reached this far: thick roots lie in the joints of the first few blocks, and three small orange mushrooms grow at the foot of the wall.",
         "draw": [["rect", -309.0, 366.0, -305.5, 382.0], ["circle", -306.3, 366.35, 0.3, {"style": "line"}], ["circle", -307.2, 366.25, 0.22, {"style": "line"}],
                  ["circle", -308.1, 366.3, 0.25, {"style": "line"}], ["line", -305.5, 369.5, -308.6, 367.2, {"style": "mark"}]]},
        {"name": "Torches", "z": [-6.0, -5.7], "style": "light", "tag": [-324.5, 371.0],
         "text": "Four on the back wall along the floor and one on the platform's face. The floor and the tiers are warm and clear, and the wall above them falls away into brown.",
         "draw": _torches([(-324.5, 369.0), (-311.5, 369.0), (-319.0, 371.0), (-330.0, 369.0), (-336.5, 368.0)])},
    ],
    "play": [
        {"name": "A jade band and a bronze shoe on each false tier", "z": [-1.2, 1.2], "style": "pale", "tag": [-334.6, 372.0],
         "text": "The temple's mark for a thing that moves. Each false tier has a jade stripe down its front face and bronze along its bottom edge. It shakes and grinds for a moment before it goes.",
         "draw": [["rect", x - 0.3, top - 1.0, x, top] for x, top in _FALSE]},
        {"name": "Deep carving on the true tiers", "z": [-1.2, 1.2], "style": "mark", "tag": [-331.6, 369.4],
         "text": "The front faces of the first and third tiers and the landing are carved deep and pale, with pug faces and belts. They are bonded into the platform, with no joint under them.",
         "draw": [["line", -332.0, 367.5, -332.0, 368.5], ["line", -338.0, 372.5, -338.0, 373.5], ["line", -347.0, 380.0, -347.0, 381.0]]},
        {"name": "Polish and wear", "z": [-1.2, 1.2], "style": "mark", "tag": [-315.5, 366.6],
         "text": "Drawn onto what is there. The chute is polished black with pale runs down it. Where the drain lands, the paving is worn into a shallow dish 5 m across, scuffed pale.",
         "draw": [["line", -318.0, 366.0, -313.0, 366.0], ["line", -342.6, 366.7, -350.0, 371.5]]},
    ],
    "foreground": [
        {"name": "A low balustrade", "z": [1.3, 1.6], "tag": [-326.0, 365.3], "top": True,
         "text": "Along the front edge of the paving, 0.8 m tall. It stands a step down from the floor, so its top is below the level you walk on and it covers no part of you. It stops before the first tier.",
         "draw": [["rect", -331.0, 364.9, -311.0, 365.7]]},
    ],
    "explains": [
        ["The five tiers and the landing", "The stepped platform under the great mask", "The platform's body, and each tier's terrace running back"],
        ["The three false tiers", "Slabs on bronze shoes, set as a trap", "The slot each one rides in, with its empty 2.6 m showing"],
        ["The entry floor", "The paving of the temple's first hall", "The back wall, two doorways, and the strip the falls come down"],
        ["The chute", "The temple's way back down", "It comes out from under the platform, polished by everyone who slid it"],
        ["The doorstep", "The sill of the door through the well's wall", "The doorway's side, with the garden's roots in its joints"],
    ],
    "pieces": [
        ["Wall bay", "4 m wide, 5 m tall", "about 20", "Background", "kit: wall bay"],
        ["Carved band", "0.8 m tall", "3 runs", "Background", "kit: carved frieze strip"],
        ["Stepped arch doorway with a banner", "3 m wide, 4.5 m tall", "2", "Background", "kit: stepped arch doorway; banner"],
        ["Stone pug plaque", "1.5 m", "2", "Background", "kit: pug mask plaque"],
        ["Platform body with terraces, carved under each tier", "22 m long, 15 m tall, 4 m deep", "1", "Background", "new, this area only"],
        ["Slot with bronze lining", "5.7 m long, 1.1 m tall", "3", "Background", "kit: slot and bronze-shod sliding block"],
        ["False tier: jade stripe, bronze shoe", "3 m by 1 m", "3", "Play space", "kit: slot and bronze-shod sliding block"],
        ["True tier and landing: deep carved front", "3 m and 7 m by 1 m", "3", "Play space", "new, this area only"],
        ["Fall strip: a carved panel of falling figures", "5 m wide, to the roof", "1", "Background", "kit: fall strip (added below)"],
        ["Doorway side with roots and three small mushrooms", "3.5 m wide, 16 m tall", "1", "Background", "kit: wall bay; roots and small caps from the garden's kit"],
        ["Torch", "0.8 m", "5", "Background", "kit: torch in a bronze bracket"],
        ["Low balustrade", "20 m long, 0.8 m tall", "1", "Foreground", "kit: low balustrade"],
    ],
    "effects": [
        "A false tier shakes and drops a line of dust from its slot before it draws back.",
        "A puff of dust on the worn dish whenever something lands from the drain.",
        "A few of the garden's spores drift in through the door and die out by the first torch.",
    ],
    "notes": [
        "Note 51: the back wall runs the whole frame. There is no black behind the floor or the tiers.",
        "Note 48, the part about these steps: they slide into open air under the next tier, not into a wall, so nothing here pins a hand. The slot is in the platform behind them.",
    ],
}

# ------------------------------------------------------------------ 5.2 La Mascara
_face = [["poly", [[-364.5, 380.2], [-351.8, 380.2], [-350.15, 384.0], [-350.15, 397.0], [-351.5, 401.2], [-354.0, 399.5], [-362.3, 399.5],
                   [-364.8, 401.2], [-366.15, 397.0], [-366.15, 384.0]]]]

LA_MASCARA = {
    "id": "5.2", "slug": "5_2_la_mascara", "title": "La Máscara", "kind": "challenge",
    "window": [-371.5, 376.5, -344.5, 404.5], "screen": [-358.0, 388.5], "cut_y": 389.0, "climber": [-350.5, 381.0],
    "place": ("The west end of the entry hall is one carved face: the First Top Dog in his mask, 16 m wide and 21 m tall, standing on top of the "
              "stepped platform. It was made to be climbed. The face itself is a wall, set back behind you and painted in terracotta and jade. "
              "The things you hold stand out from it a full metre: the jaw, the fangs, the lip and its teeth, the nostrils, the cheek studs, the "
              "lower lids of the eyes and the brow. They are bone white with gold tips, and nothing else on the face is. The jaw is a block that "
              "rides up and down in two slots. Behind the open mouth is the gullet, which leads down to the chute."),
    "keep": [
        "Every hold where it is today, until the mask's features are measured and the route is laid again on the carving (note 47).",
        "The jaw's ride: 4.5 m up, the wait at the bottom and the top, and the 2.1 m of room it leaves when it shuts.",
        "The flat face stays behind you everywhere. You are never behind any part of the mask (note 47).",
        "Nothing stands in front of the mask.",
    ],
    "background": [
        {"name": "The hall's end wall", "z": [-7.0, -6.0], "tag": [-346.0, 402.5],
         "text": "The same wall bays as the rest of the hall, rising out of the frame. Beside the mask the carved band shows small figures riding a jaw and climbing from tooth to nose to eye.",
         "draw": [["rect", -371.5, 376.5, -344.5, 404.5], _frieze(-350.1, -344.5, 386.8)]},
        {"name": "The mask's face", "z": [-5.0, -1.3], "style": "pale", "tag": [-352.2, 398.6], "top": True,
         "text": "The carved face, kept as it looks today: terracotta, jade and cream, with the ears and the crown above the brow. It is scenery. Its flat cheeks and forehead are out of reach behind you, so they are never mistaken for holds. Its colours are a shade browner than the bone white of the holds.",
         "draw": _face},
        {"name": "The gullet", "z": [-5.0, -2.0], "style": "dark", "tag": [-358.15, 383.3],
         "text": "The open mouth, black inside, with a stepped throat going back and down to the chute. Far back in it, the jaw's counterweight, a 1 m stone block on a thick bronze chain, goes down as the jaw comes up.",
         "draw": [["rect", -360.5, 380.2, -355.8, 388.6], ["rect", -358.6, 385.4, -357.7, 386.4, {"style": "pale"}], ["line", -358.15, 386.4, -358.15, 388.6, {"style": "pale"}]]},
        {"name": "The jaw's two slots", "z": [-2.0, -1.2], "style": "dark", "tag": [-361.6, 384.2],
         "text": "One either side of the mouth, cut into the face and lined with bronze, 6.5 m tall. The jaw's ends ride in them. You can see how high the jaw will go before it moves.",
         "draw": [["rect", -361.0, 379.8, -360.55, 386.3], ["rect", -355.75, 379.8, -355.3, 386.3]]},
        {"name": "The eye sockets", "z": [-3.5, -1.3], "style": "dark", "tag": [-352.0, 394.5],
         "text": "Two deep sockets, each with an eye of inlaid jade lit from inside. The ledge you stand on under each is the eye's lower lid.",
         "draw": [["poly", [[-363.6, 393.6], [-360.8, 393.6], [-360.6, 395.0], [-363.9, 395.2]]], ["poly", [[-355.6, 393.6], [-352.8, 393.6], [-352.5, 395.2], [-355.8, 395.0]]],
                  ["circle", -362.2, 394.4, 0.35, {"style": "light"}], ["circle", -354.2, 394.4, 0.35, {"style": "light"}]]},
        {"name": "The nostril pits", "z": [-2.5, -1.3], "style": "dark", "tag": [-359.9, 390.3],
         "text": "Two round black pits in the nose. The pale ring round each pit is what you hold.",
         "draw": [["circle", -358.9, 391.1, 0.5], ["circle", -357.5, 391.1, 0.5]]},
        {"name": "Torches", "z": [-6.0, -5.7], "style": "light", "tag": [-348.6, 392.0],
         "text": "Two on the wall east of the mask and one west of it. They light the face from the sides, so every hold throws a shadow onto the face behind it.",
         "draw": _torches([(-348.6, 384.0), (-348.6, 393.0), (-368.6, 391.0)])},
    ],
    "play": [
        {"name": "Bone white and gold on every hold", "z": [-1.2, 1.2], "style": "line", "tag": [-361.3, 392.6],
         "text": "The rule for the mask: if it is bone white with a gold tip or a gold rim, you can hold it. The three teeth and the two fangs have gold tips. The nostril rings and the cheek studs have gold rims. The lower lids and the brow have a gold line along their front edge. Each hold stands out from the face on a stem you can see, with a gap of shadow behind it.",
         "draw": [["circle", -358.9, 391.1, 0.5], ["circle", -357.5, 391.1, 0.5], ["circle", -356.1, 392.3, 0.5], ["circle", -360.3, 392.3, 0.5],
                  ["line", -355.4, 393.6, -353.0, 393.6], ["line", -363.4, 393.6, -361.0, 393.6], ["line", -359.7, 388.6, -356.7, 388.6]]},
        {"name": "A jade band on the jaw", "z": [-1.2, 1.2], "style": "pale", "tag": [-354.9, 379.8],
         "text": "The jaw moves, so it wears the jade band along its lip, between the two fangs, and bronze shoes at its two ends where it meets the slots. It shakes before it rises.",
         "draw": [["rect", -360.1, 380.75, -356.2, 381.0]]},
        {"name": "The brow", "z": [-1.2, 1.2], "style": "mark", "tag": [-365.0, 397.2],
         "text": "The brow ridge is the mask's own brow. It carries on west past the edge of the face as a cornice, and that is your walk to the pistons.",
         "draw": [["line", -366.5, 396.4, -354.2, 396.4]]},
    ],
    "foreground": [],
    "explains": [
        ["The jaw", "The mask's lower jaw, a block on a counterweight", "Its two slots in the face, and the counterweight going down in the gullet"],
        ["The two fangs on the jaw", "The lower fangs", "The jaw they grow from"],
        ["The lip and its three teeth", "The upper gum and teeth", "The dark of the gullet behind them, so they stand out white"],
        ["The two nostril holds", "The raised rims of the nostrils", "The black pit inside each rim"],
        ["The two cheek studs", "The mask's cheek rivets", "Each on a stone stem out of the cheek"],
        ["The two eye ledges", "The lower lids", "The sockets and the lit jade eyes"],
        ["The brow", "The brow ridge, and a cornice west of it", "The forehead and the crown above"],
    ],
    "pieces": [
        ["The great mask's face", "16 m wide, 21 m tall", "1", "Background", "kit: the great mask"],
        ["Hold on a stem: tooth, fang, nostril ring, cheek stud", "0.5 m", "3 teeth, 2 fangs, 2 rings, 2 studs", "Play space", "kit: the great mask, its holds"],
        ["Lower lid; upper lip; brow ridge", "2.4 m; 3 m; 12.3 m", "2, 1, 1", "Play space", "kit: the great mask, its holds"],
        ["Jaw with jade band and bronze shoes", "4.7 m wide", "1", "Play space", "kit: the great mask, its jaw"],
        ["Slot with bronze lining, upright", "0.45 m wide, 6.5 m tall", "2", "Background", "kit: slot and bronze-shod sliding block"],
        ["Counterweight block on a thick chain", "1 m block", "1", "Background", "kit: counterweight and chain"],
        ["Gullet: stepped throat", "4.7 m wide, 8 m tall, 3 m deep", "1", "Background", "new, this area only"],
        ["Jade eye, lit", "0.7 m", "2", "Background", "new, this area only"],
        ["Wall bay; carved band", "4 m by 5 m; 0.8 m tall", "to fill; 1 run", "Background", "kit: wall bay; carved frieze strip"],
        ["Torch", "0.8 m", "3", "Background", "kit: torch in a bronze bracket"],
    ],
    "effects": [
        "A slow drip from the upper teeth into the gullet.",
        "The jade eyes dim and brighten a little, slowly.",
        "Dust falls from the two slots just before the jaw starts up.",
    ],
    "notes": [
        "Note 47, first half (done): the face is set back so you are always in front of it. This design keeps the whole flat face in the background and brings only the holds forward.",
        "Note 47, second half (not built): what you can hold has to be plain. Here the holds are the carved features themselves, they are the only bone white and gold on the face, and each stands out on a stem.",
        "When the mask's features are measured, the holds move to where the carving is. If a gap is then too far, one more carved stud goes on the face, in the same bone white and gold.",
    ],
}

# ------------------------------------------------------------------ 5.3 Los Pistones
_PW = [401.2, 403.6, 406.0, 408.4, 410.8]   # tops of the west wall's pistons
_PE = [402.4, 404.8, 407.2, 409.6]          # tops of the east wall's
_tracks = [["rect", -372.0, t - 0.95, -368.8, t + 0.05] for t in _PW] + [["rect", -369.7, t - 0.95, -366.5, t + 0.05] for t in _PE]
_tracks += [["rect", -368.8, t - 0.95, -368.55, t + 0.05, {"style": "pale"}] for t in _PW] + [["rect", -369.95, t - 0.95, -369.7, t + 0.05, {"style": "pale"}] for t in _PE]
_sockets = [["rect", -373.25, t - 0.94, -372.0, t + 0.04] for t in _PW] + [["rect", -366.5, t - 0.94, -365.25, t + 0.04] for t in _PE]

LOS_PISTONES = {
    "id": "5.3", "slug": "5_3_los_pistones", "title": "Los Pistones", "kind": "challenge",
    "window": [-381.0, 390.0, -354.0, 416.0], "screen": [-369.2, 404.0], "cut_y": 403.3, "climber": [-362.0, 396.4],
    "place": ("Past the mask's brow the walk goes under a great stone pier and ends at a shaft, 5.5 m wide and 16 m tall, that goes up into the "
              "temple's works. The shaft is a machine. A plunger in its floor lifts you to where the walls begin, and then nine stone bolts, "
              "each 3.4 m long, slide out of the two walls in turn, bottom to top, like the bolts of a great lock being thrown one "
              "after another. The walls themselves are polished black. The only way up is on the bolts, and each bolt, as it comes out, "
              "pushes off whoever is still standing in front of it. West of the plunger the floor is missing: that is the throat that "
              "drops to the chute."),
    "keep": [
        "The nine pistons: which wall each is in, their heights 1.2 m apart, how far they come out, and their order and timing.",
        "The plunger's 3.6 m lift, and the open throat west of it.",
        "The walls can't be held, and a piston that is in sits 0.33 m inside the wall's face (note 48).",
        "The shaft is narrow and you read both walls at once, so nothing stands in front of it.",
    ],
    "background": [
        {"name": "The shaft's back wall", "z": [-2.7, -2.2], "tag": [-369.2, 392.0], "top": True,
         "text": "Fitted blocks, a shade browner than the bolts, 2.2 m behind you. It carries on down behind the throat into the dark, east under the pier behind the walk, and up into the gear room, so there is no black anywhere in the frame (note 51).",
         "draw": [["rect", -372.0, 390.0, -366.5, 412.0], ["rect", -366.5, 396.4, -354.0, 400.0], ["rect", -374.5, 412.0, -360.2, 416.0], ["rect", -366.5, 390.0, -354.0, 395.2]]},
        {"name": "Nine tracks", "z": [-2.2, -1.2], "style": "dark", "tag": [-370.6, 409.2],
         "text": "Each piston is the near end of a long bolt, and its back half runs in a track cut across the back wall and lined with bronze. Five tracks reach out from the west wall and four from the east. Each ends in a bronze stop exactly where that piston's tip stops. You can read the whole ladder, and how far every step will come, before anything moves.",
         "draw": _tracks},
        {"name": "The plunger's guide", "z": [-2.2, -1.2], "style": "dark", "tag": [-367.65, 398.8],
         "text": "A slot up the back wall behind the plunger, 3.6 m taller than the plunger itself. The empty part above it is the height it will lift you.",
         "draw": [["rect", -368.3, 392.4, -367.0, 400.1]]},
        {"name": "The carved band", "z": [-2.7, -2.2], "style": "pale", "tag": [-360.5, 399.6],
         "text": "Along the top of the wall under the pier, where you read it as you walk to the plunger: small figures stepping from bolt to bolt, left wall then right wall, and one being pushed off.",
         "draw": [_frieze(-366.3, -354.0, 400.0)]},
        {"name": "An offering niche", "z": [-2.7, -2.2], "style": "dark", "tag": [-364.2, 397.9],
         "text": "Beside the plunger, at head height: a small square niche holding a bone and a jade bead. The temple's people left one beside every machine.",
         "draw": [["rect", -365.6, 397.6, -365.0, 398.2]]},
        {"name": "Torches", "z": [-2.3, -2.0], "style": "light", "tag": [-370.4, 398.6],
         "text": "One over the throat, one under the pier, one at the head of the shaft. None sits between the tracks, so nothing bright is behind a piston.",
         "draw": _torches([(-370.4, 396.8), (-359.0, 397.2), (-370.6, 412.6)])},
    ],
    "play": [
        {"name": "Nine sockets", "z": [1.15, 1.2], "style": "dark", "tag": [-373.9, 405.5],
         "text": "On the face of each wall, the mouth each piston lives in: a dark square in a carved frame. The game draws these today (note 48). A socket with nothing in it is plainly not a hold.",
         "draw": _sockets},
        {"name": "Polished black walls", "z": [1.15, 1.2], "style": "mark", "tag": [-375.9, 402.0],
         "text": "Both walls are polished black from the plunger's top to the head of the shaft, with pale runs of damp down them. Nothing on them is pale except the pistons.",
         "draw": [["line", -374.4, 399.8, -374.4, 411.0], ["line", -363.2, 400.2, -363.2, 411.0], ["line", -361.0, 400.2, -361.0, 411.0]]},
        {"name": "Bronze faces and jade bands", "z": [-1.2, 1.2], "style": "pale", "tag": [-367.65, 394.4],
         "text": "Each piston's end is shod in dark bronze, the temple's mark for what hurts: that is the face that shoves you. Its top is pale stone with a jade band. The plunger wears the same band round its top.",
         "draw": [["rect", -368.8, 396.1, -366.5, 396.4]]},
    ],
    "foreground": [],
    "explains": [
        ["The nine pistons", "The bolts of a great lock, thrown in turn", "The track each one runs in across the back wall, with a stop at its tip"],
        ["A piston's end", "The bronze face that shoves you", "The socket on the wall it comes out of"],
        ["The plunger", "The shaft's lift", "Its guide slot, with the empty 3.6 m above it"],
        ["The two walls", "Polished black stone, wet", "The back wall, dry and carved, to show what the side walls are not"],
        ["The walk under the pier", "The mask's brow, carried on as a cornice", "The carved band that shows the shaft being climbed"],
    ],
    "pieces": [
        ["Shaft back wall", "5.5 m wide, 16 m tall", "1", "Background", "kit: wall bay, cut to width"],
        ["Track with bronze lining and a stop", "3.2 m long, 1 m tall", "9", "Background", "kit: slot and bronze-shod sliding block"],
        ["Piston: bronze end, jade band", "3.4 m by 0.9 m", "9", "Play space", "kit: slot and bronze-shod sliding block"],
        ["Socket frame on the wall's face", "1.25 m by 1 m", "9", "Play space (drawn on)", "kit: slot and bronze-shod sliding block"],
        ["Plunger with jade band; its guide slot", "2.3 m by 4 m; slot 1.3 m by 7.7 m", "1 each", "Play space, background", "kit: slot and bronze-shod sliding block"],
        ["Carved band", "0.8 m tall, 12 m long", "1", "Background", "kit: carved frieze strip"],
        ["Offering niche", "0.6 m", "1", "Background", "kit: offering niche"],
        ["Torch", "0.8 m", "3", "Background", "kit: torch in a bronze bracket"],
    ],
    "effects": [
        "A grind and a puff of dust at a socket half a second before its piston starts back in (note 48).",
        "A line of dust falls from a track's stop when the piston hits it.",
        "Grit trickles down the throat now and then, so you see it is a hole.",
    ],
    "notes": [
        "Note 48 (done): the pistons sit a third of a metre inside the wall when in, the walls can't be held, a hand on a piston going in is let go at the wall's face, and the socket warns before it moves. The sockets are item 7 here.",
        "Note 48 asked that the walls read as walls you can't hold. Here they are the only polished black in the shaft, and the back wall is plainly different stone.",
    ],
}

# ------------------------------------------------------------------ 5.4 Engranajes
_GEARS = [(-364.6, 416.4), (-368.56, 420.36), (-364.6, 424.32), (-368.56, 428.28)]

ENGRANAJES = {
    "id": "5.4", "slug": "5_4_engranajes", "title": "Engranajes", "kind": "challenge",
    "window": [-380.5, 408.5, -352.5, 437.0], "screen": [-366.6, 422.5], "cut_y": 420.4, "climber": [-362.0, 412.0],
    "place": ("Above the piston shaft is the gear room: the place where the temple's turning comes from, as far as anyone can tell. Four stone "
              "wheels, each 6 m across with its cogs, stand one above another in a zigzag and turn against each other. They are built the way "
              "a mill's wheels are built: the wheel is one greased disc, and each of its twelve cogs is a separate block set into a socket "
              "in the rim and pinned with bronze. The wheels hang on two tall stone posts on the back wall, two wheels to a post. Nobody "
              "knows what turns them. The room is 14 m wide and 22 m tall, and it opens at its top corner onto the balcony of the great hall."),
    "keep": [
        "The four gears: where each is, its size, its twelve cogs, and that each turns against the one below.",
        "The disc can't be held. Only cogs can.",
        "Parker has still to choose how the gears get harder (note 49). Nothing here depends on which way he chooses.",
        "Open air under the second and fourth gears, down to the piston shaft.",
    ],
    "background": [
        {"name": "The gear room's back wall", "z": [-3.4, -2.8], "tag": [-373.2, 432.6], "top": True,
         "text": "Wall bays, 2.8 m behind you, browner than the cogs. At the top right the room is open to the great hall, and the hall's own back wall carries on behind the balcony.",
         "draw": [["rect", -374.5, 408.5, -360.2, 434.0], ["rect", -366.0, 430.0, -352.5, 437.0]]},
        {"name": "Two posts", "z": [-2.6, -1.3], "style": "pale", "tag": [-368.56, 414.6], "top": True,
         "text": "Two square carved posts stand against the back wall from floor to roof, each with a pug capital. The east post carries the first and third wheels and the west post the second and fourth. Each wheel's axle runs back into its post between two carved cheeks. You see the posts above, below and between the wheels, so each wheel is plainly hung on something.",
         "draw": [["rect", -369.16, 412.6, -367.96, 434.0], ["rect", -365.2, 412.0, -364.0, 434.0],
                  ["poly", [[-369.6, 412.6], [-367.5, 412.6], [-367.9, 411.9], [-369.2, 411.9]]],
                  ["rect", -369.5, 433.3, -367.6, 434.0], ["rect", -365.55, 433.3, -363.65, 434.0]]},
        {"name": "The carved band", "z": [-3.4, -2.8], "style": "pale", "tag": [-373.2, 417.4],
         "text": "At three heights on the back wall: small figures riding cogs round, stepping from one wheel to the next, and one figure caught where two wheels meet. It is the only warning the room gives about the mesh.",
         "draw": [_frieze(-374.5, -360.2, 417.8), _frieze(-374.5, -360.2, 423.6), _frieze(-374.5, -360.2, 429.4)]},
        {"name": "The grease shelf", "z": [-3.4, -2.8], "style": "dark", "tag": [-373.3, 413.0],
         "text": "Low in the west corner: an offering niche, and beside it a stone trough of black grease with a long ladle. Black runs of grease go down both posts from every axle. It says why the discs can't be held.",
         "draw": [["rect", -373.9, 413.4, -373.3, 414.0], ["rect", -372.9, 413.4, -371.3, 413.8, {"style": "pale"}],
                  ["line", -368.56, 418.0, -368.56, 412.8, {"style": "mark"}], ["line", -364.6, 414.0, -364.6, 412.1, {"style": "mark"}]]},
        {"name": "Torches", "z": [-3.0, -2.7], "style": "light", "tag": [-373.5, 425.2],
         "text": "One on each side of the room, in the gaps the wheels leave, and one by the way out. The cogs catch the light and the discs do not.",
         "draw": _torches([(-373.5, 423.9), (-361.0, 419.9), (-362.5, 431.2)])},
    ],
    "play": [
        {"name": "Cogs set into the rim", "z": [-1.2, 1.2], "style": "line", "tag": [-361.9, 414.6],
         "text": "Each cog is its own block in its own socket, with a bronze pin through it. A cog you can hold is pale dry stone. A cog you can't is black and greased like the disc. Today all twelve on each wheel are pale. If Parker picks fewer (note 49), the others are swapped for black ones and nothing else changes. If the mesh is made to bite, every cog's two side faces get a dark bronze shoe, and its outer end stays pale.",
         "draw": [["circle", x, y, 2.3] for x, y in _GEARS]},
        {"name": "Running dogs round each disc", "z": [-1.2, 1.2], "style": "mark", "tag": [-364.6, 422.9],
         "text": "A ring of small carved dogs runs round each disc's face, nose to tail, in shallow relief under the grease. They show which way a wheel turns and how fast, at any speed. If the wheels are made to stop and turn back, the dogs are seen to stop first.",
         "draw": [["circle", x, y, 1.5] for x, y in _GEARS]},
        {"name": "A pug boss at each hub", "z": [-1.2, 1.2], "style": "pale", "tag": [-368.56, 426.9],
         "text": "The end of each axle shows at the wheel's centre as a carved pug's face in a jade ring. It is the same boss that chains hang from elsewhere in the temple.",
         "draw": [["circle", x, y, 0.5] for x, y in _GEARS]},
    ],
    "foreground": [],
    "explains": [
        ["A cog", "A stone block pinned into the wheel's rim", "The wheel, and the post its axle goes into"],
        ["The four wheels", "The temple's gear train", "Two posts on the back wall, two wheels to a post"],
        ["The greased disc", "The wheel's body, kept slick", "The grease trough, and the black runs down the posts"],
        ["Where two wheels meet", "The mesh", "The figure caught between wheels on the carved band"],
        ["The ledge you start from", "The top of the pier", "The back wall and the foot of the east post"],
    ],
    "pieces": [
        ["Gear wheel: greased disc, twelve cog sockets, running dogs on its face", "4.6 m disc, 6.2 m over the cogs", "4", "Play space", "new, this area only (the kit's temple_gear, re-made)"],
        ["Cog: pale and dry", "0.9 m by 0.55 m", "48 today", "Play space", "new, this area only"],
        ["Cog: black and greased", "0.9 m by 0.55 m", "none today; up to 32 (note 49)", "Play space", "new, this area only"],
        ["Bronze shoe for a cog's side face", "0.9 m", "none today; up to 96 (note 49)", "Play space", "new, this area only"],
        ["Pug boss in a jade ring, as a hub", "1 m", "4", "Play space", "kit: chain boss"],
        ["Post with a pug capital and two pairs of axle cheeks", "1.2 m square, 22 m tall", "2", "Background", "kit: column, stacked; axle cheeks and stone axle"],
        ["Wall bay; carved band", "4 m by 5 m; 0.8 m tall", "to fill; 3 runs", "Background", "kit: wall bay; carved frieze strip"],
        ["Grease trough with a ladle; offering niche", "1.6 m; 0.6 m", "1 each", "Background", "trough new, this area only; kit: offering niche"],
        ["Torch", "0.8 m", "3", "Background", "kit: torch in a bronze bracket"],
    ],
    "effects": [
        "Stone dust falls from each of the three meshes all the time. If the mesh bites, a few sparks fall with it.",
        "The whole train shakes and drops dust from its axles for a second before any change of direction, if Parker picks that.",
        "A drip of grease from the lowest wheel onto the ledge's west end.",
    ],
    "notes": [
        "Note 49 (Parker to pick): fewer cogs that hold, a faster turn, a mesh that bites, a train that turns back. The room is designed so each of these is a small swap: cogs change colour, the dogs show speed and direction, bronze shoes mark a mesh that bites, and the shake before a move is the temple's own rule.",
    ],
}

# ------------------------------------------------------------------ 5.5 El Salon de los Campeones
_CHAMPS = [(-360.0, 430.0), (-347.0, 431.0), (-331.5, 433.0)]   # where each climbed champion's feet are


def _still_champion(cx, y):
    """A champion of the second rank: arms down, in a tall stepped niche, far back."""
    return [_arch(cx, y, 4.2, 10.0), ["rect", cx - 1.2, y, cx + 1.2, y + 0.8, {"style": "pale"}], ["rect", cx - 0.8, y + 0.8, cx + 0.8, y + 7.0, {"style": "pale"}],
            ["circle", cx, y + 7.9, 0.85, {"style": "pale"}]]


def _pilaster(sx, y0, y1):
    """A great pilaster with a stepped corbel head, under a champion's plinth."""
    return [["rect", sx - 1.3, y0, sx + 1.3, y1], ["rect", sx - 1.6, y1 - 0.6, sx + 1.6, y1], ["rect", sx - 1.9, y1 - 0.3, sx + 1.9, y1]]


EL_SALON = {
    "id": "5.5", "slug": "5_5_el_salon_de_los_campeones", "title": "El Salón de los Campeones", "kind": "challenge",
    "window": [-367.5, 425.5, -324.5, 452.5], "screen": [-351.5, 437.5], "cut_y": 437.2, "climber": [-363.5, 430.0],
    "place": ("The great hall is where the temple kept its champions: everyone who ever finished the climb, carved 9 m tall, standing in two "
              "ranks down the length of the hall. The far rank stands in niches in the far wall with its arms down. The near rank, the three "
              "you climb, stands out in the hall on great pilasters, each with both arms raised in victory and one fist gilded. The hall "
              "has no floor you can use. Its floor is a polished black ramp that falls away to the east, so each champion's pilaster is "
              "taller than the last: the second stands 4.5 m above the ramp and the third 16 m. The ramp is the hall's way back down. It "
              "ends at the drain."),
    "keep": [
        "The three champions: where each stands, its pose, and every part of it you can hold.",
        "The two flings, fist to raised arm: 7 m, then 9.5 m.",
        "The east forearm of each champion can't be held today, and the gilded fist hangs free at its end. See the question below.",
        "A miss lands on the ramp and slides to the drain. Nothing stands in front of any of it.",
    ],
    "background": [
        {"name": "The hall's far wall", "z": [-10.0, -9.0], "tag": [-345.5, 451.0], "top": True,
         "text": "Wall bays from the ramp to the roof, 9 m back and brown with shadow. The carved band crosses it at three heights. The middle band, near the height of the fists, shows small figures swinging from fist to arm down a line of statues.",
         "draw": [["rect", -366.0, 425.5, -324.5, 450.0], ["rect", -366.0, 450.0, -352.0, 452.5], _frieze(-366.0, -324.5, 435.8), _frieze(-366.0, -324.5, 441.6), _frieze(-366.0, -324.5, 447.4)]},
        {"name": "The far rank", "z": [-9.0, -7.5], "style": "dark", "tag": [-353.5, 433.6],
         "text": "Two more champions, the same size and the same stone, in tall stepped niches in the far wall. Their arms are down. That is the temple's rule: a statue with its arms down is scenery, and a statue with an arm raised is climbed. They are 8 m back and browner, so they are never taken for the near rank.",
         "draw": _still_champion(-353.5, 431.5) + _still_champion(-339.5, 432.0)},
        {"name": "Two great pilasters", "z": [-2.6, -1.3], "style": "pale", "tag": [-347.0, 427.4], "top": True,
         "text": "The second and third champions each stand on a plinth, and each plinth is the top of a great pilaster that rises from the ramp behind you, with a stepped head that reaches forward to carry the plinth. The third pilaster is 16 m tall and goes out of the bottom of the frame. The first champion stands on the balcony and needs none.",
         "draw": _pilaster(-347.0, 425.5, 429.8) + _pilaster(-331.5, 425.5, 431.8)},
        {"name": "Banners", "z": [-9.0, -8.9], "style": "pale", "tag": [-339.5, 448.2],
         "text": "One over each niche, whole and bright, hung high on the far wall. None hangs near a fist or an arm, and none hangs in the hall's open air.",
         "draw": [_banner(-353.5, 449.8), _banner(-339.5, 449.8)]},
        {"name": "Torches", "z": [-9.0, -8.7], "style": "light", "tag": [-336.6, 438.7],
         "text": "One either side of each niche and one on the balcony. They sit low, below the line of the flings, so a climber in the air is seen against plain wall.",
         "draw": _torches([(-356.4, 436.0), (-350.6, 436.0), (-342.4, 436.4), (-336.6, 436.4), (-364.4, 432.0)])},
    ],
    "play": [
        {"name": "A black bracer on each launch arm", "z": [-1.2, 1.2], "style": "line", "tag": [-343.3, 438.0],
         "text": "Each champion's east forearm, from the elbow to the fist, can't be held. Today it looks like the rest of the arm. Here it wears a bracer of polished black stone, the temple's look for what you can't hold, so the arm reads as it plays: climb to the elbow, then take the fist.",
         "draw": [["line", sx + 2.6, fy + 7.0, sx + 3.7, fy + 7.95] for sx, fy in _CHAMPS]},
        {"name": "The gilded fist", "z": [-1.2, 1.2], "style": "line", "tag": [-355.2, 439.4],
         "text": "Gold, with a jade band at the wrist. It is the only gold on each statue, and it is where you fling from.",
         "draw": [["circle", sx + 4.02, fy + 8.19, 0.65] for sx, fy in _CHAMPS]},
        {"name": "The catching arm", "z": [-1.2, 1.2], "style": "mark", "tag": [-350.9, 439.7],
         "text": "The raised west arm of each champion is carved deep and pale along its whole length, with a belt of small pug faces wound round it. It is 3 m of forearm and a fist: the biggest pale thing in front of you as you fly.",
         "draw": [["line", sx - 1.0, fy + 5.9, sx - 3.2, fy + 7.6] for sx, fy in _CHAMPS]},
        {"name": "The ramp's polish", "z": [-1.2, 1.2], "style": "mark", "tag": [-350.6, 426.4],
         "text": "Polished black, with long pale scrapes running down it where others have slid.",
         "draw": [["line", -353.0, 428.7, -347.6, 425.5]]},
    ],
    "foreground": [],
    "explains": [
        ["A champion's legs, trunk, shoulders and head", "A statue of someone who finished the climb", "The pilaster that carries it, and the far rank of the same statues"],
        ["The gilded fist", "The victory fist: the launch", "The black bracer below it, which you can't hold"],
        ["The raised west arm", "The other arm of the same salute: the catch", "The carved band, where small figures swing from fist to arm"],
        ["The plinths", "The tops of two great pilasters", "The pilasters, rising out of the ramp behind you"],
        ["The ramp", "The hall's floor, and its way back down", "The far wall's bays running down beside it to the drain"],
        ["The balcony", "The hall's west gallery, where the gear room lets out", "The far wall and the first torch"],
    ],
    "pieces": [
        ["Champion, arms raised: gilded fist, black bracer, carved catching arm", "9 m tall", "3", "Play space", "kit: champion statue (statue_champion_reach); the bracer is new"],
        ["Champion, arms down", "9 m tall", "2", "Background", "kit: champion statue, arms down"],
        ["Tall stepped niche", "4.2 m wide, 10 m tall", "2", "Background", "kit: stepped arch doorway, made taller"],
        ["Great pilaster with a stepped corbel head", "2.6 m wide; 4.5 m and 16 m tall", "2", "Background", "kit: great pilaster (added below)"],
        ["Wall bay; carved band", "4 m by 5 m; 0.8 m tall", "to fill; 3 runs", "Background", "kit: wall bay; carved frieze strip"],
        ["Banner", "1.2 m by 3 m", "2", "Background", "kit: banner of cut paper"],
        ["Torch", "0.8 m", "5", "Background", "kit: torch in a bronze bracket"],
    ],
    "effects": [
        "Torchlight from the gallery above falls through the two slots in the roof as two thin bars of gold on the far wall.",
        "Dust hangs in the hall's air. It is thicker low down, over the ramp.",
        "A scrape and a long fading hiss when anything slides the ramp.",
    ],
    "notes": [
        "Note 51: the far wall runs the whole hall and on behind the east balcony.",
        "The statues were re-made to the shapes you climb after the playtest. This design adds one thing to them: the black bracer.",
    ],
    "ask": [
        "Each champion's east forearm looks like stone you could hold, and it can't be held. Should it wear a polished black bracer, as drawn here, or should the forearm be made holdable instead?",
    ],
}

# ------------------------------------------------------------------ 5.6 Incensarios
INCENSARIOS = {
    "id": "5.6", "slug": "5_6_incensarios", "title": "Incensarios", "kind": "challenge",
    "window": [-336.5, 404.0, -305.5, 458.5], "screen": [-321.0, 442.0], "cut_y": 443.2, "climber": [-331.5, 440.95],
    "place": ("The east end of the great hall, over the drain. This is where the temple burned its incense: one great censer hangs on a "
              "bronze chain from a carved pug in the roof and swings out over the place where the ramp ends and the hall drops 38 m to the "
              "entry floor. Across the gap is the keeper's balcony, a small ledge on the well's wall where the censer was filled, with a "
              "doorway behind it and a chain up to the gallery. The censer still swings and still smokes. Nobody fills it."),
    "keep": [
        "After note 50 there is one censer, the middle one: where it hangs, its 7.8 m chain, its swing of 1.6 m either side, once every 5 seconds.",
        "The fling from the last champion's fist to the censer, and from the censer to the balcony.",
        "The drain under it, the keeper's balcony, and the chain up to the gallery.",
        "Nothing hangs near the censer, in front of it or behind it.",
    ],
    "background": [
        {"name": "The hall's far wall, carried on to the well's wall", "z": [-10.0, -9.0], "tag": [-323.0, 452.0], "top": True,
         "text": "The same bays as the rest of the hall. They carry on east behind the balcony and up behind the chain, to the well's wall, so there is no dark band there (note 51). Behind the censer's swing the wall is left plain, with no carved band, so the gold bowl and its smoke show against bare stone.",
         "draw": [["rect", -336.5, 404.0, -309.0, 458.5], _frieze(-336.5, -330.0, 441.6), _frieze(-336.5, -309.0, 435.8), _frieze(-336.5, -326.0, 447.4), _frieze(-314.0, -309.0, 447.4)]},
        {"name": "The last pilaster", "z": [-2.6, -1.3], "style": "pale", "tag": [-331.5, 424.0],
         "text": "The third champion's pilaster, 16 m of it, rising from the ramp. It is the last solid thing before the drain.",
         "draw": _pilaster(-331.5, 414.0, 431.8)},
        {"name": "The fall strip", "z": [-9.0, -8.6], "style": "line", "tag": [-315.5, 420.0],
         "text": "The carved strip of falling figures starts here, at the height of the censer, and runs down the far wall behind the drain's mouth and on down. It is the same strip you walked past at the door. A stone pug's face looks down the drain from beside it.",
         "draw": [["line", -318.0, 436.0, -318.0, 407.4], ["line", -313.0, 436.0, -313.0, 404.0], ["line", -318.0, 436.0, -313.0, 436.0], ["line", -316.5, 436.0, -316.5, 404.0, {"style": "mark"}], ["line", -314.5, 436.0, -314.5, 404.0, {"style": "mark"}],
                  ["circle", -321.0, 413.0, 1.6, {"style": "line"}]]},
        {"name": "The keeper's doorway", "z": [-3.0, -1.3], "style": "dark", "tag": [-310.6, 447.3],
         "text": "A stepped arch doorway behind the balcony, dark inside, with two incense jars and a long ladle beside it. The chain you climb hangs in front of it.",
         "draw": [_arch(-310.6, 443.6, 2.6, 4.2), ["circle", -312.4, 443.95, 0.3, {"style": "pale"}], ["circle", -312.3, 444.55, 0.22, {"style": "pale"}]]},
        {"name": "The chain's boss", "z": [-2.0, -1.3], "style": "pale", "tag": [-309.9, 455.6],
         "text": "A carved pug with a bronze ring in its mouth, set under the stone above the shaft. The chain to the gallery hangs from it.",
         "draw": [["circle", -311.0, 456.5, 0.45]]},
        {"name": "The gallery's columns", "z": [-3.0, -2.4], "style": "pale", "tag": [-325.3, 455.6],
         "text": "Above the roof: the gallery you will walk west along, with its square columns and its back wall.",
         "draw": _column(-325.3, 453.0, 457.5) + _column(-317.0, 453.0, 458.3)},
        {"name": "Torches", "z": [-9.0, -8.7], "style": "light", "tag": [-325.4, 446.0],
         "text": "One beside the last champion, one either side of the censer's swing and well clear of it, one in the chain's shaft, and one low down beside the drain so the drop is lit.",
         "draw": _torches([(-334.6, 437.2), (-325.4, 444.4), (-314.4, 444.8), (-309.8, 450.6), (-320.5, 408.6)])},
    ],
    "play": [
        {"name": "The one censer", "z": [-1.2, 1.2], "style": "line", "tag": [-318.6, 441.4],
         "text": "A pierced bronze bowl with a gold lid, coals glowing inside, and a jade band round it because it moves. Its chain is thick bronze, link by link, and can be held along its whole length. The chain hangs from a pug boss carved on the roof's underside.",
         "draw": [["circle", -320.0, 442.0, 0.85], ["circle", -320.0, 449.55, 0.45, {"style": "pale"}]]},
        {"name": "The two that go", "z": [-1.2, 1.2], "style": "mark", "tag": [-326.0, 441.6],
         "text": "The first and third censers are in the course today and are crossed out here. They go, with their chains and their bosses (note 50). The banner that hangs beside the first chain today goes too.",
         "draw": [["line", -325.4, 439.3, -323.6, 441.1], ["line", -325.4, 441.1, -323.6, 439.3], ["line", -316.4, 442.9, -314.6, 444.7], ["line", -316.4, 444.7, -314.6, 442.9]]},
        {"name": "The balcony's edge", "z": [-1.2, 1.2], "style": "mark", "tag": [-313.6, 442.4],
         "text": "The west edge of the keeper's balcony is carved deep and pale. It is what you fling for.",
         "draw": [["line", -312.8, 442.7, -312.8, 443.6]]},
        {"name": "The ramp's foot", "z": [-1.2, 1.2], "style": "mark", "tag": [-321.4, 410.8],
         "text": "The ramp ends in a lip of polished black, worn into a shallow spout.",
         "draw": [["line", -323.0, 410.6, -318.0, 407.5]]},
    ],
    "foreground": [],
    "explains": [
        ["The censer's bowl", "The temple's incense burner", "Bare wall behind its swing, and the smoke it leaves"],
        ["The censer's chain", "Thick bronze links", "The pug boss in the roof it hangs from"],
        ["The balcony", "Where the keeper stood to fill the censer", "The keeper's doorway, jars and ladle"],
        ["The chain up to the gallery", "The keeper's way up", "Its own pug boss, and the lit wall of the shaft"],
        ["The ramp's foot and the drain", "The end of the hall's way back down", "The fall strip, and the pug that looks down it"],
    ],
    "pieces": [
        ["Censer: pierced bowl, gold lid, jade band", "0.9 m bowl; 1.6 m with its lid and ring", "1", "Play space", "kit: censer"],
        ["Bronze chain, to hold", "7.8 m; 12.4 m", "2", "Play space", "kit: censer, its chain"],
        ["Chain boss", "0.9 m", "2", "Play space (on the roof), background", "kit: chain boss"],
        ["Stepped arch doorway", "2.6 m wide, 4.2 m tall", "1", "Background", "kit: stepped arch doorway"],
        ["Incense jars and a ladle", "0.6 m jars; 2 m ladle", "2 jars, 1 ladle", "Background", "new, this area only"],
        ["Great pilaster", "2.6 m wide, 16 m tall", "1", "Background", "kit: great pilaster (added below)"],
        ["Fall strip", "5 m wide, 32 m of it here", "1", "Background", "kit: fall strip (added below)"],
        ["Stone pug plaque, large", "3.2 m", "1", "Background", "kit: pug mask plaque, made larger"],
        ["Wall bay; carved band", "4 m by 5 m; 0.8 m tall", "to fill; 3 runs", "Background", "kit: wall bay; carved frieze strip"],
        ["Column", "1.2 m square, 4.5 m", "2", "Background", "kit: column"],
        ["Torch", "0.8 m", "5", "Background", "kit: torch in a bronze bracket"],
    ],
    "effects": [
        "The censer trails smoke. The trail hangs for a few seconds, so the path of its swing is drawn in the air.",
        "Embers drift up from the bowl at each end of the swing.",
        "A drip in the chain's shaft.",
    ],
    "notes": [
        "Note 50 (not built): only the middle censer stays. The design is drawn with one.",
        "Note 51 (done): the far wall carries on behind the balcony and the chain.",
        "Note 50 says the first fling, 7.3 m to a moving chain, still has to be tried. If the censer is moved half a metre, its boss moves with it and nothing else here changes.",
    ],
}

# ------------------------------------------------------------------ 5.7 El Contrapeso (and the gallery)
_GCOLS = [-349.0, -343.0, -332.3, -325.3]

EL_CONTRAPESO = {
    "id": "5.7", "slug": "5_7_el_contrapeso", "title": "El Contrapeso", "kind": "challenge",
    "window": [-369.5, 446.0, -324.5, 462.5], "screen": [-357.0, 454.5], "cut_y": 452.8, "climber": [-350.5, 453.0],
    "place": ("From the keeper's balcony a chain takes you up to the gallery: a walk 40 m long on the roof of the great hall, between a row "
              "of square columns, with two slots in the floor that look down on the champions. The gallery ends at the hall's open west "
              "end, and there the temple weighs you. On the back wall is a stone scale: one beam on an axle, and a stone pan hanging from "
              "each end. Step on the near pan and it sinks 3 m while the far pan rises 3 m. The way on is from the low pan to the high "
              "one, and then to a ledge on the west wall, before the scale settles back."),
    "keep": [
        "The two slabs: where each is, how far and how fast the first sinks, and that the second does the opposite.",
        "The fling from the sunk slab to the risen one, and the ledge that can only be reached while the second is still up.",
        "The gallery's two slots, lined so their insides can't be held (note 52). The floor's top can be held right up to each edge.",
        "The open drop to the west balcony, 23 m down.",
    ],
    "background": [
        {"name": "The back wall", "z": [-3.2, -2.6], "tag": [-366.9, 447.0], "top": True,
         "text": "Wall bays behind the gallery and behind the open west end, without a break. Under the gallery's floor it is the great hall's far wall, further back.",
         "draw": [["rect", -366.0, 446.0, -324.5, 462.5]]},
        {"name": "The scale", "z": [-2.2, -1.3], "style": "pale", "tag": [-357.8, 457.4], "top": True,
         "text": "A stone beam 6 m long on an axle between two carved cheeks, with a pug boss on the axle's end. It is drawn as it rests: east end up, west end down. When you stand on the east pan the beam tips the other way. It is thick stone, set against the wall, and it is browner than the pans.",
         "draw": [["poly", [[-354.8, 457.2], [-354.8, 457.8], [-360.75, 454.8], [-360.75, 454.2]]], ["rect", -358.55, 454.8, -358.1, 457.0], ["rect", -357.45, 454.8, -357.0, 457.0],
                  ["circle", -357.78, 456.0, 0.4, {"style": "dark"}]]},
        {"name": "Two hanger slots", "z": [-2.0, -1.2], "style": "dark", "tag": [-361.7, 453.2],
         "text": "Each pan hangs from its end of the beam by a stone hanger that runs in a slot in the back wall. The slot is as long as the pan's travel, so the empty part of each slot shows how far that pan will go. Today each slab has a thin chain that goes straight up through the serpent's back. Those go.",
         "draw": [["rect", -355.05, 450.8, -354.55, 457.9], ["rect", -361.0, 450.8, -360.5, 457.9]]},
        {"name": "The carved panel", "z": [-3.2, -2.6], "style": "pale", "tag": [-357.8, 449.0],
         "text": "Under the scale: a small figure standing on the low pan and another leaping for the high one.",
         "draw": [["rect", -359.2, 449.6, -356.4, 451.2]]},
        {"name": "The serpent's bed", "z": [-2.2, -1.3], "style": "pale", "tag": [-347.2, 458.2],
         "text": "Overhead: the long carved beam the serpent's back rises out of (see La Serpiente). Its east end stands on the gallery's first column.",
         "draw": [["rect", -362.9, 457.6, -344.8, 458.8]]},
        {"name": "The gallery's columns", "z": [-3.0, -2.4], "style": "pale", "tag": [-343.0, 456.8],
         "text": "Square carved columns with pug capitals along the back of the gallery. Each has a base to match it in front of the floor (item 13), so you walk between a column and a column's base.",
         "draw": _column(-349.0, 453.0, 457.6) + _column(-343.0, 453.0, 457.5) + _column(-332.3, 453.0, 457.5) + _column(-325.3, 453.0, 457.5)},
        {"name": "Three doorways and a plaque", "z": [-3.2, -2.6], "style": "dark", "tag": [-339.9, 454.4],
         "text": "Stepped arch doorways between the columns, dark inside, and one stone pug plaque. The temple goes on behind the gallery.",
         "draw": [_arch(-346.0, 453.0, 3.0, 4.0), _arch(-339.9, 453.0, 3.0, 4.0), _arch(-328.8, 453.0, 3.0, 4.0), ["circle", -335.0, 455.4, 0.75, {"style": "line"}]]},
        {"name": "Torches", "z": [-2.6, -2.3], "style": "light", "tag": [-364.8, 458.6],
         "text": "One on each column, and one on the west wall over the ledge. The pans and the ledge are the brightest things at the west end.",
         "draw": _torches([(-349.0, 455.0), (-343.0, 455.0), (-332.3, 455.0), (-325.3, 455.0), (-364.8, 457.0)])},
        {"name": "The side shrine's doorway", "z": [-2.4, -1.2], "style": "dark", "over": True, "tag": [-367.4, 456.2],
         "text": "A small stepped doorway in the west wall at the ledge. It is the frog's room: see its own page.",
         "draw": [["poly", [[-366.0, 455.0], [-368.8, 455.0], [-368.8, 457.0], [-368.3, 457.0], [-368.3, 457.8], [-366.5, 457.8], [-366.5, 457.0], [-366.0, 457.0]]]]},
    ],
    "play": [
        {"name": "A jade band and bronze shoes on each pan", "z": [-1.2, 1.2], "style": "pale", "tag": [-352.9, 454.9],
         "text": "Both slabs move, so both wear the jade band along the top edge and bronze at their ends. Each is carved underneath with a shallow dish, so it reads as a pan of the scale.",
         "draw": [["rect", -356.0, 454.35, -353.6, 454.6], ["rect", -362.0, 451.35, -359.5, 451.6]]},
        {"name": "The slots' black lining", "z": [-1.2, 1.2], "style": "dark", "tag": [-337.3, 451.2],
         "text": "The inside faces of the two slots in the gallery floor are polished black from just under the lip to the bottom (note 52). The floor's top is pale and carved right up to the edge.",
         "draw": [["rect", -338.0, 450.0, -337.75, 452.9], ["rect", -336.85, 450.0, -336.6, 452.9], ["rect", -328.0, 450.0, -327.75, 452.9], ["rect", -326.85, 450.0, -326.6, 452.9]]},
        {"name": "The gallery's last edge", "z": [-1.2, 1.2], "style": "mark", "tag": [-351.4, 451.9],
         "text": "The west end of the gallery floor is carved deep and pale on its end face. It is the last sure hold before the scale.",
         "draw": [["line", -352.0, 452.5, -352.0, 453.0]]},
    ],
    "foreground": [
        {"name": "Column bases", "z": [1.3, 1.9], "tag": [-332.3, 451.6], "top": True,
         "text": "The base of a column, 1.5 m wide, in front of the gallery floor opposite each column behind. Their tops are level with the floor, so they cover no part of you. None stands in front of a slot.",
         "draw": [["rect", x - 0.75, 451.5, x + 0.75, 452.95] for x in _GCOLS]},
    ],
    "explains": [
        ["The first slab", "The near pan of a stone scale", "The beam's east end, and the hanger slot the pan runs down"],
        ["The second slab", "The far pan", "The beam's west end, and its slot, with empty slot above it"],
        ["The exit ledge", "A ledge on the hall's west wall", "The torch over it, and the frog's doorway"],
        ["The gallery floor", "The roof of the great hall", "Columns, doorways, and the column bases in front"],
        ["The two slots", "Light slots, to look down on the champions", "Their black lining, and the hall's far wall seen through them"],
    ],
    "pieces": [
        ["Scale beam with a pug boss", "6 m long, 0.6 m thick", "1", "Background", "new, this area only"],
        ["Axle cheeks and axle", "1.4 m", "1", "Background", "kit: axle cheeks and stone axle"],
        ["Hanger slot with bronze lining", "0.5 m wide, 7 m tall", "2", "Background", "kit: slot and bronze-shod sliding block"],
        ["Pan: slab with a jade band and bronze ends", "2.4 m by 0.8 m", "2", "Play space", "kit: slot and bronze-shod sliding block"],
        ["Carved panel: the two figures", "2.8 m by 1.6 m", "1", "Background", "kit: carved frieze strip, as a panel"],
        ["Column", "1.2 m square, 4.5 m", "4", "Background", "kit: column"],
        ["Column base", "1.5 m wide, 1.45 m tall", "4", "Foreground", "kit: column base"],
        ["Stepped arch doorway", "3 m wide, 4 m tall", "3", "Background", "kit: stepped arch doorway"],
        ["Stone pug plaque", "1.5 m", "1", "Background", "kit: pug mask plaque"],
        ["Slot lining, polished black", "0.08 m thick, 2.9 m tall", "4", "Play space", "the game draws it today (note 52)"],
        ["Torch", "0.8 m", "5", "Background", "kit: torch in a bronze bracket"],
    ],
    "effects": [
        "The beam groans as it tips, and dust falls from its axle.",
        "Light comes up through the two slots from the hall's torches.",
        "The first pan shakes once as your weight comes on, before it sinks.",
    ],
    "notes": [
        "Note 52 (done): the insides of the two slots can't be held. They are item 11 here.",
        "Note 51: the back wall is unbroken behind the open west end.",
    ],
}

# ------------------------------------------------------------------ 5.0 The frog's room
_shrine = [["poly", [[-366.0, 455.0], [-368.8, 455.0], [-368.8, 457.0], [-368.3, 457.0], [-368.3, 457.8], [-366.5, 457.8], [-366.5, 457.0], [-366.0, 457.0]]]]

FROG_ROOM = {
    "id": "5.0", "slug": "5_0_the_frogs_room", "title": "The frog's room", "kind": "rest",
    "window": [-374.5, 449.5, -356.5, 462.5], "cut_y": 456.0, "climber": [-364.4, 455.0],
    "place": ("A small side shrine, cut into the west wall at the ledge you reach after El Contrapeso, at the foot of the serpent's tail. "
              "Every hall of the temple had shrines like it, where a climber left a small carved pug before a test. This one is 2.8 m "
              "deep and 2.8 m tall inside, with a stepped doorway 2 m tall. Its walls are shelves of carved pugs the size of a hand, "
              "dozens of them. On the offering table at the back, in the place of honour where the biggest pug should sit, sits the frog. "
              "The room is cut away at the front: you see its floor, its back wall and its roof."),
    "keep": [
        "The ledge and the tail chain stay as they are. The room adds 2.8 m of level floor west of the ledge and nothing else.",
        "Nothing in the room can be held or stood on except its floor. The table and the shelves are behind you.",
        "Finding the frog is never needed to climb on (note 60).",
    ],
    "background": [
        {"name": "The west wall, behind the ledge", "z": [-3.2, -2.6], "tag": [-358.6, 461.0],
         "text": "The same back wall as the scale's. The torch over the ledge is the one light outside the room.",
         "draw": [["rect", -366.0, 449.5, -356.5, 462.5]] + _torches([(-364.8, 457.0)])},
        {"name": "The shrine", "z": [-2.4, -1.2], "over": True, "tag": [-366.9, 457.4], "top": True,
         "text": "The room, cut into rock that is solid today. Fitted pale blocks, a stepped roof, and a back wall 2.4 m behind you. The wall here is 3 m thick today, so the rock behind the room has to be made a metre thicker when this is built.",
         "draw": _shrine},
        {"name": "Shelves of small carved pugs", "z": [-2.4, -2.0], "style": "pale", "over": True, "tag": [-366.7, 456.5],
         "text": "Two stone shelves round the back wall, crowded with carved pugs a hand tall, each a little different, some with a jade bead or a scrap of cut paper. They are the offerings of everyone who came this far.",
         "draw": [["line", -368.7, 456.5, -366.3, 456.5], ["line", -368.2, 457.15, -366.6, 457.15]]},
        {"name": "The offering table, and the frog", "z": [-2.2, -1.4], "style": "pale", "over": True, "tag": [-367.9, 454.5], "top": True,
         "text": "A stone table 1.2 m wide against the back wall, under an empty stepped niche where the shrine's own carved pug should be. The frog, 0.3 m, sits on the table in front of the niche, facing out. It breathes, blinks and watches you. Two small lamps burn either side of it.",
         "draw": [_arch(-367.9, 455.8, 1.0, 1.0), ["rect", -368.5, 455.0, -367.3, 455.8], ["circle", -367.9, 455.98, 0.18, {"style": "light"}],
                  ["circle", -368.38, 455.9, 0.09, {"style": "light"}], ["circle", -367.42, 455.9, 0.09, {"style": "light"}], ["text", -369.9, 454.6, "the frog"]]},
        {"name": "The scale's west pan and the serpent's bed", "z": [-2.2, -1.3], "style": "pale", "tag": [-359.6, 458.2],
         "text": "What else is on this wall, for placing the room: the west hanger slot of the scale, and the bed of the serpent overhead with the tail's boss.",
         "draw": [["rect", -362.9, 457.6, -356.5, 458.8], ["rect", -361.0, 450.8, -360.5, 457.6, {"style": "dark"}], ["circle", -363.5, 460.1, 0.4]]},
    ],
    "play": [
        {"name": "A line of jade paw prints", "z": [-1.2, 1.2], "style": "line", "tag": [-364.9, 454.4],
         "text": "Four small paw prints of jade, inlaid in the top of the ledge, lead to the doorway. They are the only sign from outside, with the frog's croak.",
         "draw": [["line", -365.9, 455.0, -364.2, 455.0]]},
        {"name": "The doorway", "z": [-1.2, 1.2], "style": "mark", "tag": [-365.4, 457.6],
         "text": "A stepped opening in the wall's face, 2 m tall at the ledge and 2.8 m inside. Its frame is carved pale. The wall above and below it stays polished black.",
         "draw": [["line", -366.0, 455.0, -366.0, 457.0], ["line", -366.0, 457.0, -366.5, 457.0]]},
    ],
    "foreground": [],
    "explains": [
        ["The ledge", "The landing after the scale, and the shrine's doorstep", "The west wall, its torch, and the doorway"],
        ["The room's floor", "The floor of a side shrine", "The table, the shelves of pugs, and the frog"],
    ],
    "pieces": [
        ["Shrine room: floor, back wall, stepped roof, no front wall", "2.8 m deep, 2.8 m tall", "1", "Background, cut away at the front", "kit: the frog's room"],
        ["The frog", "0.3 m", "1", "Background", "kit: the frog"],
        ["Offering table", "1.2 m wide, 0.8 m tall", "1", "Background", "kit: altar, made small"],
        ["Empty stepped niche", "1 m", "1", "Background", "kit: offering niche, made larger"],
        ["Small carved pug", "0.15 m, six shapes", "about 40", "Background", "new, this area only"],
        ["Small lamp", "0.2 m", "2", "Background", "new, this area only"],
        ["Jade paw print", "0.2 m", "4", "Play space (drawn on)", "kit: paw ring (added below), four prints of it"],
        ["Torch", "0.8 m", "1", "Background", "kit: torch in a bronze bracket"],
    ],
    "effects": [
        "The frog croaks when you are within a screen of it (note 60).",
        "The two lamps flicker, so the doorway glows a little on the dark wall.",
    ],
    "notes": [
        "Note 60: one frog in every biome, friendly, off the main way, found by its croak.",
        "Rule 10 of the mountain: a room you can enter is cut away at the front.",
    ],
    "ask": [
        "The frog's shrine is in the west wall at the ledge after El Contrapeso, where the serpent's tail hangs. Is that the right place for it?",
    ],
}

# ------------------------------------------------------------------ 5.8 La Serpiente
_SERP = [-362.0 + 2.0 * i for i in range(9)]   # the nine vertebrae, by their middles
_FANGS = [-360.0, -354.0, -348.0]
_head = ["poly", [[-344.2, 461.7], [-341.4, 461.7], [-341.2, 463.2], [-342.4, 464.2], [-344.4, 463.6]]]

LA_SERPIENTE = {
    "id": "5.8", "slug": "5_8_la_serpiente", "title": "La Serpiente", "kind": "challenge",
    "window": [-369.5, 451.5, -337.5, 469.5], "screen": [-354.0, 461.5], "cut_y": 461.4, "climber": [-365.0, 460.2],
    "place": ("Over the scale, under the roof, a stone serpent 20 m long lies along the back wall. Its tail is a bronze chain that hangs down "
              "to the ledge. Its head rests on a ledge at the far end. Its body is a long carved bed fixed to the wall, and its spine is "
              "nine stone blocks that stand out of the bed toward you, each on its own ram, each in its own slot. The rams rise and fall "
              "3 m, one after another, so a wave runs along the spine from tail to head. Three smaller serpents look down out of the wall "
              "above, mouths open, and each has one long black fang that hangs into your way."),
    "keep": [
        "The nine vertebrae: where each is, its 3 m rise and fall on a 4 second beat, each half a second behind the one before.",
        "The three fangs, where they hang, and that they can't be held.",
        "The tail chain up from the ledge, and the head's ledge at the east end.",
        "Open air under the serpent, down to the scale and the gallery.",
    ],
    "background": [
        {"name": "The back wall", "z": [-3.2, -2.6], "tag": [-366.9, 452.4], "top": True,
         "text": "Wall bays from below the scale up to the roof. Behind the serpent the blocks are carved in shallow relief with its coils and scales, browner than the spine.",
         "draw": [["rect", -366.0, 451.5, -337.5, 469.5]]},
        {"name": "The serpent's bed", "z": [-2.2, -1.3], "style": "pale", "tag": [-345.6, 458.2], "top": True,
         "text": "A carved stone beam 19 m long and 1.2 m tall, fixed to the back wall just under the spine. It is the serpent's body. The nine rams rise out of its top. At its west end a roller's axle turns in two carved cheeks: that is what works the rams. A row of small figures is carved along its face, walking the spine and ducking under each fang.",
         "draw": [["rect", -362.9, 457.6, -344.0, 458.8], ["rect", -363.6, 457.3, -362.9, 459.1], ["circle", -363.25, 458.2, 0.3, {"style": "dark"}],
                  ["line", -362.4, 458.2, -344.6, 458.2, {"style": "mark"}]]},
        {"name": "Nine slots", "z": [-2.4, -1.3], "style": "dark", "tag": [-350.0, 462.6],
         "text": "Behind each vertebra, a slot up the back wall, lined with bronze, as tall as that vertebra's rise. The ram runs in it. The empty slot above a vertebra shows how high it will come, so you can see whether there is room under a fang before you step.",
         "draw": [["rect", cx - 0.3, 458.8, cx + 0.3, 463.5] for cx in _SERP]},
        {"name": "Three small serpent heads", "z": [-2.6, -1.3], "style": "pale", "tag": [-352.3, 465.5],
         "text": "One over each fang, 2.6 m wide, looking down out of the wall under the roof with its mouth open. Each fang is that head's one great tooth. They are the same carving as the serpent's own head, smaller.",
         "draw": [["poly", [[fx - 1.3, 464.9], [fx + 1.3, 464.9], [fx + 1.0, 466.5], [fx - 1.0, 466.5]]] for fx in _FANGS]},
        {"name": "The serpent's head", "z": [-2.6, -1.3], "style": "pale", "tag": [-342.8, 465.0], "top": True,
         "text": "On the ledge at the east end, against the back wall, 3 m long, looking back down its own spine with jade eyes. You step off the last vertebra and walk past it.",
         "draw": [_head, ["circle", -343.4, 463.2, 0.15, {"style": "light"}]]},
        {"name": "The tail's boss", "z": [-2.0, -1.3], "style": "pale", "tag": [-364.6, 461.6],
         "text": "A carved pug with a bronze ring, on the back wall at the spine's west end. The tail chain hangs from it.",
         "draw": [["circle", -363.5, 460.1, 0.4]]},
        {"name": "The scale, below", "z": [-2.2, -1.3], "style": "line", "tag": [-357.8, 454.6],
         "text": "The beam of El Contrapeso's scale is on the same wall, just under the bed. Its hangers stop below the bed. Nothing of it crosses the spine.",
         "draw": [["line", -354.8, 457.5, -360.75, 454.5], ["circle", -357.78, 456.0, 0.4]]},
        {"name": "Torches", "z": [-2.6, -2.3], "style": "light", "tag": [-351.0, 466.4],
         "text": "Three under the roof, between the small heads, so each fang is lit from both sides and its black shows against the lit wall.",
         "draw": _torches([(-357.0, 464.5), (-351.0, 464.5), (-345.4, 464.5)])},
    ],
    "play": [
        {"name": "A jade band on every vertebra", "z": [-1.2, 1.2], "style": "pale", "tag": [-352.0, 459.3],
         "text": "Each vertebra is pale stone carved with scales on its top, with a jade band along its top edge and a bronze shoe underneath where it meets its ram.",
         "draw": [["rect", cx - 0.95, 459.95, cx + 0.95, 460.2] for cx in _SERP]},
        {"name": "The fangs", "z": [-1.2, 1.2], "style": "mark", "tag": [-356.0, 463.6],
         "text": "Polished black, wet, with a pale run down each. They are the only black things hanging in the room.",
         "draw": [["line", fx, 466.3, fx, 463.8] for fx in _FANGS]},
        {"name": "The tail", "z": [-1.2, 1.2], "style": "line", "tag": [-362.5, 456.6],
         "text": "The chain you climb is the serpent's tail: thick bronze links, getting smaller toward the bottom, ending in a carved stone tip.",
         "draw": [["circle", -363.5, 455.6, 0.3]]},
    ],
    "foreground": [],
    "explains": [
        ["A vertebra", "A block of the serpent's spine, on a ram", "The slot its ram runs in, and the bed it rises from"],
        ["The wave", "The roller in the bed lifting each ram in turn", "The roller's axle turning in its cheeks at the bed's west end"],
        ["A fang", "The one tooth of a small serpent head", "That head, looking down from under the roof"],
        ["The tail chain", "The serpent's tail", "The pug boss it hangs from"],
        ["The head's ledge", "Where the serpent rests its head", "The head itself, against the wall"],
    ],
    "pieces": [
        ["Bed: carved beam with nine ram sockets", "19 m long, 1.2 m tall", "1", "Background", "new, this area only"],
        ["Axle cheeks and axle", "1.4 m", "1", "Background", "kit: axle cheeks and stone axle"],
        ["Ram slot with bronze lining", "0.6 m wide, 4.7 m tall", "9", "Background", "kit: slot and bronze-shod sliding block"],
        ["Vertebra: scales on top, jade band, bronze shoe", "1.9 m by 1.2 m", "9", "Play space", "kit: slot and bronze-shod sliding block (serpent_segment, re-made)"],
        ["Serpent head", "3 m", "1", "Background", "kit: serpent head"],
        ["Serpent head, small, mouth open downward", "2.6 m", "3", "Background", "kit: serpent head, made smaller"],
        ["Fang: polished black", "1.6 m wide, 3.1 m long", "3", "Play space", "new, this area only"],
        ["Tail chain with a stone tip", "4.5 m", "1", "Play space", "kit: censer, its chain; the tip is new"],
        ["Chain boss", "0.9 m", "1", "Background", "kit: chain boss"],
        ["Wall bay with shallow coil carving", "4 m by 5 m", "to fill", "Background", "kit: wall bay, a second face"],
        ["Torch", "0.8 m", "3", "Background", "kit: torch in a bronze bracket"],
    ],
    "effects": [
        "A grind from the bed each time a ram starts up, so the wave can be heard coming.",
        "A drip off each fang's tip.",
        "Dust falls from a slot when its ram reaches the top.",
    ],
    "notes": [
        "No playtest note is about this place. It follows the mountain's rules: the moving thing shows its machine, and the danger shows where it comes from.",
        "Today a 3 m pug mask hangs on the back wall behind the vertebrae, and a banner hangs behind the last one. Both go: nothing pale hangs behind the spine.",
    ],
}

# ------------------------------------------------------------------ 5.9 Bloques Fantasma
_BLOCKS = [(-340.0 + 1.7 * (k - 1), 461.7 + 1.2 * k) for k in range(1, 6)]   # each block's west edge when out, and its top
_PAWS = [4, 1, 2, 3, 4]                                                       # the count each block is gone on

_counts = []
for (_l, _t), _n in zip(_BLOCKS, _PAWS):
    _counts.append(["rect", _l - 0.1, _t + 2.3, _l + 1.5, _t + 3.1])
    _counts += [["circle", _l + 0.16 + 0.36 * _i, _t + 2.7, 0.11, {"style": "dark"}] for _i in range(_n)]

BLOQUES_FANTASMA = {
    "id": "5.9", "slug": "5_9_bloques_fantasma", "title": "Bloques Fantasma", "kind": "challenge",
    "window": [-348.5, 454.5, -320.5, 476.5], "screen": [-336.0, 465.5], "cut_y": 464.7, "climber": [-342.5, 461.7],
    "place": ("The stair to the altar. It was built as a ramp of polished black stone, 10 m long, that nobody could walk up. Five blocks "
              "slide out of the ramp's face to make steps, and slide back in, to the beat of a drum. The drum stands on a shelf over the "
              "serpent's head, and a stone mallet on an axle beats it: four counts to the bar. Each block is out for three counts and gone "
              "for one. The temple wrote the answer on the wall: over each block is a small carved panel with paw prints on it, one to "
              "four, for the count that block is gone on. At the top of the stair is the altar's threshold."),
    "keep": [
        "The five blocks: where each comes out, its size, and the count it is gone on. Four counts of two beats, 96 beats a minute.",
        "The ramp under them can't be held. A block that goes while you are on it leaves you on the ramp.",
        "The serpent's head ledge at the foot and the threshold at the top.",
    ],
    "background": [
        {"name": "The stair hall's back wall", "z": [-3.2, -2.6], "tag": [-346.8, 455.4], "top": True,
         "text": "Wall bays behind the ledge, the stair and the threshold, and below them the gallery's back wall. Unbroken.",
         "draw": [["rect", -348.5, 454.5, -320.5, 476.5]]},
        {"name": "The count panels", "z": [-3.2, -2.6], "style": "pale", "tag": [-338.2, 467.3],
         "text": "One over each block, 2.3 m above its top: a carved panel 1.6 m wide with paw prints in it. Four paws over the first block, then one, two, three, and four again over the fifth. A block is gone on the count its panel shows. This is the stair's carved band.",
         "draw": _counts},
        {"name": "The drum and its mallet", "z": [-2.6, -1.3], "style": "pale", "tag": [-344.6, 464.9], "top": True,
         "text": "The temple drum, 1.6 m across, on a stone shelf on the back wall above the serpent's head. A stone arm with a bone mallet swings on an axle between two cheeks and strikes it on every count, hardest on the first. You see the mallet lift before each stroke. Today the drum hangs in the air in front of the serpent's head. It moves up onto the shelf.",
         "draw": [["rect", -343.6, 463.9, -341.4, 464.2], ["rect", -343.3, 464.2, -341.7, 465.7], ["line", -341.1, 466.0, -341.9, 465.2], ["circle", -341.1, 466.0, 0.28, {"style": "dark"}]]},
        {"name": "The serpent's head", "z": [-2.6, -1.3], "style": "pale", "tag": [-343.9, 462.4],
         "text": "On the ledge where you start, against the back wall, under the drum (see La Serpiente).",
         "draw": [_head]},
        {"name": "The altar's apse and two columns", "z": [-2.8, -1.3], "style": "pale", "tag": [-327.5, 471.8],
         "text": "At the head of the stair: two square columns, and between them the stepped niche with the altar in it (see El Altar). It is what you are climbing toward, and it is lit.",
         "draw": [_arch(-327.5, 468.9, 4.4, 3.9), ["rect", -329.0, 468.9, -326.0, 470.4]] + _column(-331.0, 468.9, 473.0) + _column(-324.2, 468.9, 473.0)},
        {"name": "Torches", "z": [-2.6, -2.3], "style": "light", "tag": [-346.0, 464.6],
         "text": "One by the drum, one over the middle of the stair above the panels, one at the threshold.",
         "draw": _torches([(-346.0, 462.8), (-336.4, 470.4), (-322.4, 470.4)])},
    ],
    "play": [
        {"name": "Five sockets in the ramp's face", "z": [1.15, 1.2], "style": "line", "tag": [-331.6, 465.9],
         "text": "Each block lives in a socket cut into the ramp: a carved pale frame round a dark mouth, drawn on the ramp's face the same way as the piston sockets. When a block is out you see 1.9 m of empty socket behind it. When it is in, its end sits just inside the frame and can't be held.",
         "draw": [["rect", l + 1.7, t - 1.2, l + 4.1, t] for l, t in _BLOCKS]},
        {"name": "Where each block stands when it is out", "z": [-1.2, 1.2], "style": "mark", "tag": [-339.3, 461.0],
         "text": "The course draws the blocks drawn in. The dashed boxes are the steps as you climb them. Each block has a jade band along its top edge and a bronze shoe on its outer end, and it shakes before it goes.",
         "draw": [["rect", l, t - 1.2, l + 2.2, t] for l, t in _BLOCKS]},
        {"name": "The ramp's polish", "z": [1.15, 1.2], "style": "mark", "tag": [-334.2, 462.6],
         "text": "Polished black, with pale scrapes down it. The big face of stone under the stair is the same black, in fitted blocks with tight joints.",
         "draw": [["line", -339.4, 461.4, -331.2, 467.2]]},
    ],
    "foreground": [],
    "explains": [
        ["A block", "A step that the ramp puts out and takes back", "Its socket in the ramp's face, with empty socket behind it"],
        ["The beat", "The temple drum, beaten by a stone mallet", "The drum on its shelf, and the mallet lifting before each stroke"],
        ["Which block goes when", "The count", "The panel of paw prints over each block"],
        ["The ramp", "A stair with its steps taken away", "The serpent's head at its foot, where a slide ends"],
        ["The threshold", "The floor before the altar", "Two columns and the altar's apse"],
    ],
    "pieces": [
        ["Block: jade band, bronze shoe", "2.2 m by 1.2 m", "5", "Play space", "kit: slot and bronze-shod sliding block"],
        ["Socket frame on the ramp's face", "2.4 m by 1.2 m", "5", "Play space (drawn on)", "kit: slot and bronze-shod sliding block"],
        ["Count panel: one to four paw prints", "1.6 m by 0.8 m", "5", "Background", "kit: carved frieze strip, as a panel"],
        ["Temple drum", "1.6 m across, 1.5 m tall", "1", "Background", "kit: temple drum on a stand"],
        ["Stone shelf", "2.2 m", "1", "Background", "kit: stepped corbel (added below)"],
        ["Mallet arm on an axle", "1.2 m arm", "1", "Background", "new, this area only; kit: axle cheeks and stone axle"],
        ["Serpent head", "3 m", "1", "Background", "kit: serpent head (the same one as La Serpiente's)"],
        ["Column; stepped niche; altar", "1.2 m square, 4.1 m; 4.4 m wide; 3 m", "2; 1; 1", "Background", "kit: column; stepped arch doorway; altar"],
        ["Torch", "0.8 m", "3", "Background", "kit: torch in a bronze bracket"],
    ],
    "effects": [
        "The drum skin shakes and throws a little dust on each stroke.",
        "A block's jade band catches the light as it slides out.",
        "Each socket breathes out a puff of dust as its block goes in.",
    ],
    "notes": [
        "No playtest note is about this place. The sockets follow note 48's answer for the pistons: show where each moving block lives.",
    ],
    "ask": [
        "A panel of paw prints over each block tells you the count it is gone on. Do you want the answer carved on the wall like that, or should the stair keep its secret?",
    ],
}

# ------------------------------------------------------------------ 5.10 El Altar
_BX = [-323.5 + (9.1 / 6.0) * k for k in range(7)]   # the joints of the beam's six pieces
_SOUND = [469.4, 470.8, 472.2]
_CRACKED = [473.6, 474.9, 476.2, 477.5, 478.8]

EL_ALTAR = {
    "id": "5.10", "slug": "5_10_el_altar", "title": "El Altar", "kind": "challenge",
    "window": [-333.5, 462.0, -304.5, 487.0], "screen": [-319.0, 474.5], "cut_y": 468.6, "climber": [-327.5, 468.9],
    "place": ("The altar's chamber is the temple's highest room and its holiest. The altar stands in a stepped niche at the top of the stair, "
              "with room in front of it to stand. Past it the floor stops. The chamber is a pit 11 m wide, 16 m deep to the gallery, crossed "
              "by one thin bridge of six stone slabs laid on brackets, and every slab is cracked through. Over the bridge a stone cross "
              "10 m across turns on an axle in front of a great carved sun stone. On the far side a column of stone pegs goes up the "
              "east wall to the well's sill. The top five pegs are cracked. Three climbers got that far. They hung from the sill, hand to "
              "ankle, to reach past the bad pegs, and they are still there."),
    "keep": [
        "The beam's six pieces, each breaking 3.5 seconds after it is touched, and the cross turning at 6.4 turns a minute (note 53).",
        "The cross's arms pass half a metre over the beam and brush the east wall. Its outer 2 m knocks you out.",
        "The three sound pegs, the five cracked ones, and the three frozen climbers, each exactly where it is.",
        "The altar stays behind you, on the threshold, with clear floor in front of it (note 54).",
    ],
    "background": [
        {"name": "The chamber's back wall", "z": [-4.0, -3.4], "tag": [-306.0, 486.0], "top": True,
         "text": "Wall bays from the bottom of the pit to the roof, 3.4 m back. It carries on down the pit, so the drop is a lit wall going down and not a black hole (note 51).",
         "draw": [["rect", -333.5, 462.0, -304.5, 487.0]]},
        {"name": "The sun stone", "z": [-3.4, -2.6], "style": "line", "tag": [-321.6, 478.0],
         "text": "A carved disc 9.4 m across on the back wall, right behind the cross: rings of small pugs, belts and bones round a centre. The carving is shallow and brown. The cross is the near end of its axle.",
         "draw": [["circle", -318.0, 474.4, 4.7], ["circle", -318.0, 474.4, 3.3, {"style": "mark"}], ["circle", -318.0, 474.4, 1.9, {"style": "mark"}]]},
        {"name": "The cross's cheeks", "z": [-2.6, -1.3], "style": "pale", "tag": [-316.2, 476.2], "top": True,
         "text": "Two carved cheeks stand out of the sun stone's centre, one either side of the hub, and the stone axle runs between them. You see them between the turning arms.",
         "draw": [["rect", -319.5, 473.0, -318.8, 475.8], ["rect", -317.2, 473.0, -316.5, 475.8]]},
        {"name": "The altar in its niche", "z": [-2.8, -1.3], "style": "pale", "tag": [-327.5, 471.9], "top": True,
         "text": "A stepped niche 4.4 m wide in the back wall, and in it the altar: 3 m wide, with the First Top Dog's face on its front and a bronze bowl of coals on top. It is 1.3 m behind you. Two square columns stand either side.",
         "draw": [_arch(-327.5, 468.9, 4.4, 3.9), ["rect", -329.0, 468.9, -326.0, 470.4], ["circle", -327.5, 470.62, 0.2, {"style": "light"}]]
                 + _column(-331.0, 468.9, 473.0) + _column(-324.2, 468.9, 473.0)},
        {"name": "Seven brackets", "z": [-2.4, -1.3], "style": "pale", "tag": [-320.5, 467.2],
         "text": "A stepped stone bracket sticks out of the back wall under each joint of the bridge. The six slabs lie on them, which is why the bridge is in six pieces. When a slab falls its brackets stay, out of reach behind you, and the slab comes back onto them.",
         "draw": [["rect", bx - 0.25, 467.9, bx + 0.25, 468.4] for bx in _BX]},
        {"name": "The carved band", "z": [-4.0, -3.4], "style": "pale", "tag": [-316.0, 483.6],
         "text": "High on the back wall, level with the sill: a line of small figures hanging one from another, hand to ankle, down a wall. The three who tried were following the carving.",
         "draw": [_frieze(-319.5, -309.2, 483.0)]},
        {"name": "A banner", "z": [-3.4, -3.3], "style": "pale", "tag": [-322.4, 482.6],
         "text": "One, whole and bright, high in the west corner, as far from the pegs as the chamber allows.",
         "draw": [_banner(-322.4, 483.6)]},
        {"name": "Torches", "z": [-3.4, -3.1], "style": "light", "tag": [-313.9, 472.6],
         "text": "Two on the back wall beside the pegs, one by each column, and one far down the pit so you see how deep it is.",
         "draw": _torches([(-313.9, 470.4), (-313.9, 476.6), (-332.4, 470.4), (-322.7, 469.6), (-318.0, 463.0)])},
    ],
    "play": [
        {"name": "Six cracked slabs", "z": [-1.2, 1.2], "style": "mark", "tag": [-316.7, 467.2],
         "text": "Each piece of the bridge is pale stone cracked right through, with a corner gone: the game's one look for a thing that will break (note 53). The joints between pieces are plain to see.",
         "draw": [["line", bx, 468.4, bx, 468.9] for bx in _BX[1:-1]]},
        {"name": "Dark bronze on the cross", "z": [-1.2, 1.2], "style": "line", "tag": [-316.9, 472.6],
         "text": "The outer 2 m of each arm is edged in dark bronze, the temple's mark for what hurts. That is the part that knocks you out. The inner arms are plain stone. The hub wears a jade ring and a pug boss.",
         "draw": [["line", -323.0, 474.4, -321.0, 474.4], ["line", -315.0, 474.4, -313.0, 474.4], ["line", -318.0, 479.4, -318.0, 477.4], ["line", -318.0, 469.4, -318.0, 471.4],
                  ["circle", -318.0, 474.4, 0.9]]},
        {"name": "Eight pegs", "z": [-1.2, 1.2], "style": "line", "tag": [-311.4, 470.8],
         "text": "Each peg is a carved pug's nose on a stone stem set into the wall. The lower three are sound: pale and whole. The upper five are cracked through with a corner gone. The wall between them is polished black.",
         "draw": [["circle", -312.72, y, 0.42] for y in _SOUND]},
        {"name": "The three who tried", "z": [-1.2, 1.2], "style": "mark", "tag": [-311.4, 476.6],
         "text": "Three frozen climbers hang down the wall beside the cracked pegs. The first holds the sill's edge with both hands. The second holds the first one's ankles and the third holds the second's. They are bone pale and dusty, in the pose they died in, and you climb them like carved stone. Their chain stops 4.6 m short of the bridge.",
         "draw": [["line", -313.3, 480.0, -313.3, 473.55]]},
        {"name": "The place to stand", "z": [-1.2, 1.2], "style": "line", "tag": [-327.5, 468.1],
         "text": "A ring of jade paw prints 1.6 m across, inlaid in the threshold right in front of the altar. It marks where a climber stands to pay respects (note 54). The figure in the sketch is standing on it.",
         "draw": [["line", -328.3, 468.9, -326.7, 468.9]]},
    ],
    "foreground": [],
    "explains": [
        ["The bridge's six pieces", "Cracked slabs laid across the pit", "The seven brackets they lie on"],
        ["The cross", "A great turning wheel of four arms", "Its axle and cheeks, and the sun stone it turns in front of"],
        ["The three sound pegs", "The foot of a peg ladder up to the sill", "The lit back wall, and the carved band far above"],
        ["The five cracked pegs", "The top of the same ladder, gone bad", "The three climbers who would not trust them"],
        ["The three frozen climbers", "A ladder made of people", "The carved band of hanging figures they copied"],
        ["The threshold", "The floor before the altar", "The altar in its niche, and the paw ring in front of it"],
    ],
    "pieces": [
        ["Altar with a bowl of coals", "3 m wide, 1.5 m tall", "1", "Background", "kit: altar"],
        ["Stepped niche", "4.4 m wide, 3.9 m tall", "1", "Background", "kit: stepped arch doorway, made wider"],
        ["Column", "1.2 m square, 4.1 m", "2", "Background", "kit: column"],
        ["Paw ring", "1.6 m across", "1", "Play space (drawn on)", "kit: paw ring (added below)"],
        ["Sun stone", "9.4 m across", "1", "Background", "new, this area only"],
        ["Cross: four arms, bronze-edged outer ends, jade ring, pug boss", "10 m across", "1", "Play space", "new, this area only (altar_cross, re-made); kit: chain boss as its hub"],
        ["Axle cheeks and axle", "1.4 m, made to 2.8 m", "1", "Background", "kit: axle cheeks and stone axle"],
        ["Bridge slab: cracked, corner gone", "1.52 m by 0.5 m", "6", "Play space", "new, this area only"],
        ["Bracket", "0.5 m", "7", "Background", "kit: stepped corbel (added below)"],
        ["Peg: sound; cracked", "0.5 m", "3; 5", "Play space", "new, this area only"],
        ["Frozen climber, hanging", "1.8 m", "3", "Play space", "in the game today (the course's statues)"],
        ["Wall bay; carved band; banner", "4 m by 5 m; 0.8 m tall; 1.2 m by 3 m", "to fill; 1 run; 1", "Background", "kit: wall bay; carved frieze strip; banner"],
        ["Torch", "0.8 m", "5", "Background", "kit: torch in a bronze bracket"],
    ],
    "effects": [
        "The altar's bowl gives a small puff of smoke when respects are paid (note 54).",
        "Each slab cracks further and sheds grit for its 3.5 seconds before it drops.",
        "A low rush of air each time an arm of the cross goes by.",
    ],
    "notes": [
        "Note 53 (done): the whole beam is six breaking pieces and the cross turns four times as fast. Both are drawn as built.",
        "Note 53 also says the climb up the east wall has not been tried at the new speed. If pegs have to move, they stay a column of pug noses, sound below and cracked above.",
        "Note 54 (not built): 'Pay Your Respects'. The altar gets a marked place to stand in front of it, and the bowl answers. The second altar is on the sill above: see El Sacrificio.",
        "Note 52: nothing in the pit can be held.",
    ],
}

# ------------------------------------------------------------------ 5.11 El Sacrificio, and the join into the chimney
EL_SACRIFICIO = {
    "id": "5.11", "slug": "5_11_el_sacrificio", "title": "El Sacrificio", "kind": "challenge", "also": ["a6"],
    "window": [-315.5, 469.5, -275.5, 499.0], "screen": [-300.0, 484.5], "cut_y": 479.7, "climber": [-310.5, 480.0],
    "place": ("The top of the Pozo del Diablo. The temple roofed the well's mouth with a stepped vault and hung two great censers in it, and "
              "from the sill on the west side it gave things to the well: the stone on the sill is the sacrifice stone. This is the third "
              "crossing and the last. You go from the temple's sill to the first censer's tassel, from censer to censer in the middle, "
              "and off the second onto the east lip, with the whole well under you. The east side is not the temple any more. It is the "
              "foot of the chimney, where the temple's smiths had their forge: the same fitted blocks and the same stepped doorway, grey "
              "with soot, then iron, and red light coming up through the first grate in the floor."),
    "keep": [
        "The two censers: where they hang, their 9.8 m chains, their swings of 5 and 6 seconds, and the tassel under each.",
        "The 14 m between the temple's sill and the forge's lip, and the heights of both.",
        "The well is open under the whole crossing and lit, so you see the drop.",
        "On the east side: the lip, the doorway, the floor and the first grate, as the chimney's course has them.",
    ],
    "background": [
        {"name": "The well's far wall", "z": [-8.0, -6.0], "tag": [-300.0, 486.6], "top": True,
         "text": "The round back of the well, 6 m behind you. Down to the level of the sills it is the temple's fitted blocks. Below that it is the well's own rough rock, stepping back into the dark, with a few glints of wet far down (note 51). The dashed line is the far rim, which is dark and far back and does not read as a floor.",
         "draw": [["rect", -306.0, 469.5, -294.0, 494.0], ["poly", [[-305.0, 478.4], [-295.0, 478.4], [-296.4, 469.5], [-303.6, 469.5]], {"style": "dark"}],
                  ["line", -306.0, 479.9, -294.0, 479.9, {"style": "mark"}], ["circle", -301.2, 472.0, 0.08, {"style": "light"}], ["circle", -298.3, 470.6, 0.08, {"style": "light"}]]},
        {"name": "The stepped vault and its keystone", "z": [-6.0, -1.3], "style": "pale", "tag": [-300.0, 489.0],
         "text": "The roof over the well steps in from both sides to a flat cap. In the middle of the back wall, under the cap, is a stone pug's face 3.4 m across. It is between the two chains and well above the bowls.",
         "draw": [["rect", -306.0, 489.6, -305.0, 494.0], ["rect", -305.0, 491.8, -304.2, 494.0], ["rect", -295.0, 489.6, -294.0, 494.0], ["rect", -295.8, 491.8, -295.0, 494.0],
                  ["circle", -300.0, 491.2, 1.7, {"style": "line"}]]},
        {"name": "Two chain bosses", "z": [-1.6, -1.2], "style": "pale", "tag": [-303.0, 492.2],
         "text": "A carved pug with a bronze ring under the cap for each censer. The same boss as every other chain in the temple, at twice the size.",
         "draw": [["circle", -303.0, 493.4, 0.5], ["circle", -297.075, 493.4, 0.5]]},
        {"name": "The temple's side", "z": [-4.0, -1.3], "tag": [-314.0, 483.0],
         "text": "The altar chamber's back wall, and the side of the doorway through the well's wall: pale blocks, a carved band, and the last torch of the temple.",
         "draw": [["rect", -315.5, 469.5, -306.0, 484.0], ["rect", -309.0, 480.0, -306.0, 484.0, {"style": "pale"}], _frieze(-315.5, -309.2, 483.0)] + _torches([(-312.7, 481.2)])},
        {"name": "The sacrifice stone", "z": [-2.7, -1.3], "style": "pale", "tag": [-310.5, 482.5], "top": True,
         "text": "The second altar: a low stone 2.2 m wide in a stepped niche on the sill, with a bronze bowl on it. It is 1.3 m behind you and you can stand in front of it. Whether it counts for 'Pay Your Respects' is the question note 54 already asks.",
         "draw": [_arch(-310.5, 480.0, 3.0, 3.4), ["rect", -311.6, 480.0, -309.4, 481.1], ["circle", -310.5, 481.3, 0.18, {"style": "light"}]]},
        {"name": "The forge's side", "z": [-3.2, -1.3], "tag": [-277.4, 497.6], "top": True,
         "text": "East of the well the wall is the same fitted blocks in the same bays, but dull grey with soot, with the carving worn nearly flat. The doorway through the well's east wall is the same stepped shape as the temple's. There is no torch on this side. The light is red and comes from below.",
         "draw": [["rect", -294.0, 469.5, -275.5, 499.0]]},
        {"name": "A furnace mouth under a hood", "z": [-3.2, -1.3], "style": "dark", "tag": [-287.5, 484.8],
         "text": "The first of the forge's furnaces: a stepped arch in the back wall with fire inside it, and a ribbed iron hood over it. The small anvil that stands in the course today is in front of it.",
         "draw": [_arch(-287.5, 479.9, 3.0, 3.4), ["circle", -287.5, 480.7, 0.5, {"style": "light"}],
                  ["poly", [[-289.6, 483.5], [-285.4, 483.5], [-286.3, 485.7], [-288.7, 485.7]], {"style": "pale"}]]},
        {"name": "The vent pipe", "z": [-1.9, -1.3], "style": "pale", "tag": [-284.4, 481.0],
         "text": "A ribbed iron pipe, 0.6 m across, runs along the foot of the wall from the furnace and turns down into the floor beside the grate. It is what feeds the grate.",
         "draw": [["rect", -285.9, 479.75, -282.9, 480.35]]},
        {"name": "An iron pug", "z": [-3.2, -3.0], "style": "line", "tag": [-289.8, 488.6],
         "text": "Over the forge's doorway, on the back wall: the pug's face again, 1.5 m, in black iron this time.",
         "draw": [["circle", -289.8, 487.2, 0.75]]},
    ],
    "play": [
        {"name": "The two great censers", "z": [-1.2, 1.2], "style": "line", "tag": [-300.0, 483.2],
         "text": "The same censer as the hall's, half as big again: a pierced bronze bowl with a gold lid, a jade band and coals inside, on a chain of thick bronze links that can be held all the way up.",
         "draw": [["circle", -303.0, 483.0, 1.05], ["circle", -297.075, 483.0, 1.05]]},
        {"name": "The tassels", "z": [-1.2, 1.2], "style": "line", "tag": [-300.0, 481.2],
         "text": "Under each bowl hangs a tassel 1.5 m long: a string of five bronze bells with a jade bead at the end. The bead is what you reach for from the sill, and what brings you down onto the far lip. It is the lowest bright thing over the well.",
         "draw": [["circle", -303.0, 481.4, 0.3], ["circle", -297.075, 481.4, 0.3]]},
        {"name": "The temple's sill", "z": [-1.2, 1.2], "style": "line", "tag": [-306.6, 479.2],
         "text": "Pale carved stone with a worn notch at its very end, where the first tassel comes to hand. In front of the sacrifice stone the same ring of jade paw prints as at the altar marks the place to stand.",
         "draw": [["line", -311.3, 480.0, -309.7, 480.0], ["line", -305.6, 479.2, -305.6, 480.0]]},
        {"name": "The forge's lip", "z": [-1.2, 1.2], "style": "mark", "tag": [-293.6, 478.4],
         "text": "The east lip is the same blocks, dry and matte, grey with soot and rubbed pale along its edge and top by hands and feet. It has to read as stone you can hold. The wall above it and below it is wet black, which you can't.",
         "draw": [["line", -295.5, 480.0, -291.0, 480.0]]},
        {"name": "The first grate", "z": [-1.2, 1.2], "style": "line", "tag": [-281.5, 478.2],
         "text": "An iron grate of square bars set in the floor, 3 m long, rust orange where feet have worn it, with red light and a wisp of steam coming up through it. It is the chimney's first challenge and is designed on its own page.",
         "draw": [["rect", -283.0, 479.0, -280.0, 479.5]]},
    ],
    "foreground": [
        {"name": "A column base, west", "z": [1.3, 1.9], "tag": [-311.0, 470.4], "top": True,
         "text": "At the bottom edge of the frame on the temple's side, in front of solid rock.",
         "draw": [["rect", -311.9, 469.5, -310.1, 471.3]]},
        {"name": "A quenching trough's rim, east", "z": [1.3, 1.9], "style": "dark", "tag": [-287.0, 478.5], "top": True,
         "text": "On the forge's side, low in front of the floor's thickness: the iron rim of a trough. Its top is below the floor you walk on. The two sides of the well get two different front pieces, stone and iron.",
         "draw": [["rect", -288.6, 478.1, -285.4, 479.0]]},
    ],
    "explains": [
        ["The temple's sill", "The ledge the temple gave to the well from", "The sacrifice stone in its niche, and the last torch"],
        ["A tassel", "A string of bronze bells under a censer", "The bowl above it"],
        ["A bowl and its chain", "A great censer", "Its pug boss under the cap, and the vault stepping in"],
        ["The forge's lip", "The sill of the forge's door, grey with soot", "The same stepped doorway, and red light inside it"],
        ["The first grate", "A vent in the forge's floor", "The pipe that feeds it, from the furnace mouth"],
    ],
    "pieces": [
        ["Great censer: bowl, gold lid, jade band, chain, tassel of bells", "1.4 m bowl, 9.8 m chain, 1.5 m tassel", "2", "Play space", "kit: censer, made larger; the tassel is new"],
        ["Chain boss, large", "1 m", "2", "Background", "kit: chain boss"],
        ["Stepped vault: four corbel steps", "1 m and 0.8 m steps", "1 set", "Background", "kit: stepped corbel (added below)"],
        ["Stone pug plaque, large", "3.4 m", "1", "Background", "kit: pug mask plaque, made larger"],
        ["Well wall: fitted blocks above, rough rock stepping back below", "12 m wide", "1", "Background", "blocks from kit: wall bay; the rock is the well's own"],
        ["Sacrifice stone with a bowl; its stepped niche", "2.2 m wide; 3 m wide", "1 each", "Background", "kit: altar, made small; stepped arch doorway"],
        ["Paw ring", "1.6 m across", "1", "Play space (drawn on)", "kit: paw ring (added below)"],
        ["Forge wall bay, soot grey", "4 m wide, 5 m tall", "about 12", "Background", "the chimney's kit: forge wall bay"],
        ["Furnace mouth; forge hood", "3 m wide; 4 m", "1 each", "Background", "the chimney's kit: forge wall bay with a furnace mouth; forge hood"],
        ["Vent pipe", "0.6 m across, 3 m long", "1", "Background", "the chimney's kit: vent pipe"],
        ["Iron pug mask", "1.5 m", "1", "Background", "the chimney's kit: iron pug mask"],
        ["Steam grate", "3 m", "1", "Play space", "the chimney's kit: steam grate"],
        ["Column base", "1.8 m wide", "1", "Foreground", "kit: column base"],
        ["Quenching trough", "3.2 m long", "1", "Foreground", "the chimney's kit: quenching trough"],
        ["Torch", "0.8 m", "1", "Background", "kit: torch in a bronze bracket"],
    ],
    "effects": [
        "Both censers trail smoke, so their two swings are drawn in the air and you can see them coming together.",
        "Embers rise from the well room and drift east, toward the forge.",
        "The light changes across the well: torch gold on the west sill, red from below on the east lip.",
        "A wisp of steam and a gurgle at the grate before it blows.",
    ],
    "notes": [
        "Note 54: the second altar. It has a place to stand, like the first. Whether it counts is Parker's to say, and note 54 asks it.",
        "Note 51 (done): the well steps back into depth with far glints and is not a black hole.",
        "The join follows the two sheets: the temple leaves by the censers over the well's mouth, and the chimney begins on soot-grey temple stone beside the first grate, where the torches stop.",
    ],
}

AREAS = [LA_PUERTA, LA_MASCARA, LOS_PISTONES, ENGRANAJES, EL_SALON, INCENSARIOS, EL_CONTRAPESO, FROG_ROOM, LA_SERPIENTE, BLOQUES_FANTASMA, EL_ALTAR, EL_SACRIFICIO]

# Pieces that more than one of these areas uses and the sheet's kit does not have. The builder adds them to the sheet.
KIT_MORE = [
    ["Great pilaster with a stepped corbel head", "2.6 m wide, 4.5 to 16 m tall", "carries a champion's plinth out from the far wall", "Background", "new"],
    ["Stepped corbel", "0.5 to 2.2 m", "the bridge's brackets, the drum's shelf, the vault over the well, the foot of a post", "Background", "new"],
    ["Fall strip: a carved panel of falling figures", "5 m wide, to suit", "behind the great drain, at its top and at its foot", "Background", "new"],
    ["Paw ring: jade paw prints inlaid in a floor", "1.6 m across; single prints 0.2 m", "the place to stand before an altar (note 54); the way to the frog's door", "Play space (drawn on)", "new"],
]
