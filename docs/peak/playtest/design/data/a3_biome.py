# Biome 3: La Gruta de Cristal. Format: see ../build.py.
# Parker, 11-13: the cave is purely natural (no temple work); pale rough lilac holds and
# indigo glass doesn't; keep the Prism's rainbow; the column's rings are collars round it;
# the first steps are truly slanted pointed shafts; the needles hold at the point only.

BIOME = {
    "name": "La Gruta de Cristal",
    "line": "The crystal cave, 176 to 276 m. Glass and light. The first place on the climb that nobody built.",
    "story": [
        "Above the dam the mountain is hollow and full of crystal: points the size of houses, growing out of the walls, the roof and the floor. Water did this, over more time than the town has existed. The mine company never got up here, and nobody else ever built anything here either.",
        "So nothing in the cave is made. What moves here moves by itself: a geode that turns because water runs through it, a great quartz that swings because the mountain breathes, collars of crystal that have grown round a column, with spikes that slide out and in. The cave is strange the way a living thing is strange, and nothing in it explains itself with a bolt or a chain.",
        "The only signs of people are the ones who tried: one frozen climber, and a coil of old rope.",
    ],
    "built": [
        "Crystal grows in points. Six-sided in section, ending in a point, always leaning the way it grew. Crystals jut out of the back wall towards you (note 26), out of the floor and down from the roof. Nothing in the cave is a flat-topped block or a plain hexagon post.",
        "Crystals come in clusters: one big point with smaller ones round its root, on a collar of rough dark rock.",
        "Two kinds of crystal. Rough crystal is pale lilac, frosted, and looks like rock: you can hold it (note 30). Clear crystal is deep indigo glass, mirror-smooth: you can't.",
        "What hangs, hangs on crystal: a thread of crystal as thick as an arm, grown down from the roof like a stalactite and still joined at both ends. What turns, turns in a socket of crystal worn round and smooth. No chain, no bronze, no carved stone.",
        "No timber, no brick, no iron, nothing carved. One coil of old rope and one frozen climber are the only things here that came from outside.",
    ],
    "light": "Violet and ice-white. The light comes from inside the crystals: big far ones glow dimly, and each area has one or two bright "
             "white ones that light it. No lanterns, no torches. The background is deep indigo, and the things you hold are the palest things on screen. "
             "One place has other colours: behind El Prisma's shelves a faint fan of rainbow lies on the wall.",
    "looks": [
        ["You can hold it", "Rough pale lilac crystal that looks like rock, frosted and matte; a crystal's tip."],
        ["You can't", "Clear indigo glass faces, mirror-smooth, with a hard white glint. They show your reflection."],
        ["It will break", "Pale crystal crazed with white cracks, a corner gone. It rings, sheds glitter, and goes (note 31)."],
        ["It moves", "It is crystal on crystal: a thick grown thread it hangs by, or a worn round socket it turns in. You can see where it rubs: the crystal there is polished and bright."],
        ["It comes and goes", "The spikes on the column's collars, which are the collars' only holds: white and rough, they tremble, slide in, and snap back out with a click and a little glitter (note 34). A spike can go in under your hand."],
        ["It is scenery", "Crystal further back: bigger, bluer and dimmer, with its points turned away from the climb. Never pale lilac, and never in the play space."],
    ],
    "layers": [
        ["Background", "Near: the wall the crystals you climb grow out of, rough dark rock crowded with smaller points. Far: crystals bigger than houses, dim and blue, and mirror faces that show a small moving reflection of you."],
        ["Play space", "The points, tips, shelves and nubs you hold, each one the end of a crystal that roots in the wall behind."],
        ["Foreground", "Almost nothing (note 40). At most two dark crystal points rising from a bottom corner of the frame, below the lowest floor. Never a crystal across the climb."],
    ],
    "kit": [
        ["Wall point: a slanted, pointed crystal shaft jutting from the back wall, in rough lilac and in clear indigo", "0.8 to 1.6 m across, 2 to 4 m long", "the steps of Primer Destello, truly slanted (note 26), and every crystal ledge", "Play space, rooted in the background", "new, two looks, three sizes"],
        ["Needle spire: indigo glass shaft with a rough lilac point", "1 m across at the tip, 6 to 12 m tall", "Agujas: only the point holds (note 30)", "Play space", "in the kit: crystal_spire, to be re-made"],
        ["Cluster on a rock collar", "1.5 to 4 m", "the root of every big crystal; dressing", "Background", "in the kit: crystal_cluster_a, b, c"],
        ["Roof points, rough lilac, hanging", "0.6 to 2 m", "roofs; the ceiling's grips (note 33)", "Play space, background", "in the kit as stalactite_b; a crystal one is new"],
        ["Mirror face", "2 to 6 m", "big clear faces that show you", "Background, play space", "in the kit: mirror_facet"],
        ["Giant far crystal", "10 to 30 m", "the far background", "Background, far", "in the kit: crystal_column, crystal_shell_clear"],
        ["Crazed plate", "1.2 m by 0.3 m", "El Prisma's breaking shelves", "Play space", "the game draws the cracks today; a model is on the request list"],
        ["Grown thread: a thick strand of crystal joined to the roof", "0.25 m thick, to suit", "what the chandeliers and the pendulum hang by. Rough and lilac where you hold it; the pendulum's is clear glass you can't hold", "Play space where you hold it, background above", "new"],
        ["The cave's breath", "an effect, no model", "a slow draught you see as drifting glitter: it swings the pendulum, sends El Prisma's raft home, and goes out by the door to the well", "All", "new, an effect"],
        ["Worn socket: a round hollow of polished crystal", "1.4 m", "what the geode turns in; where the pendulum's thread meets the roof", "Background", "new"],
        ["Crystal chandelier: a hanging cluster, grown", "2 m", "Candelabros", "Play space", "in the kit: chandelier_crystal, to lose its chain and fittings"],
        ["Collar: a flat ring of crystal grown right round a column, hanging askew", "about 7.6 m across", "La Columna: three, in a zigzag up the column. The collars themselves stay behind the play space", "Background", "new"],
        ["Collar spike, sliding: the collars' holds", "about 2.3 m long", "La Columna (note 34): pairs of spikes that slide out, cross the front of the column, and slide back in", "Play space", "new"],
        ["Crystal bonsai tree", "0.6 m wide, 1.2 m tall", "the rest ledge after the pendulum: you can hold it, and it stops what rolls along the ledge (note 32)", "Play space", "new"],
        ["Rainbow fan", "6 m wide", "the wall behind El Prisma, only there", "Background", "an effect, no model"],
        ["The frog, and its room: the inside of a split geode", "frog 0.3 m; room 3 m across", "one hidden room", "Background", "new (note 60)"],
    ],
    "arrive": "From the dam's crest. Crystals have grown down through the top of the brickwork and split it. Two steps up, the brick is gone and the floor is crystal. Teal light turns violet.",
    "leave": "By the first crossing of the well, east from a crystal horn on the west rim. On the far rim the garden has already started: roots hang into the shaft and there is moss in the cracks. You leave pale violet and land in green.",
    "motifs": [
        "Your own reflection, small, in the mirror faces behind you.",
        "Nobody built this: after two biomes of timber and brick, there is not one made thing.",
        "The ones who tried: one frozen climber.",
        "The well: the first of the three crossings.",
        "The frog: inside a split geode, sitting among the crystals.",
    ],
    "notes": [
        "Note 26: the hexagon steps become truly slanted pointed crystals jutting out of the back wall, and the six flings are re-laid to suit.",
        "Note 30: the needles you grab are pale purple crystals that look like actual rock. Only the point holds.",
        "Note 31: the breaking shelves look breakable, and play their scale in order.",
        "Note 32: the little white block becomes a tiny crystal bonsai tree.",
        "Note 33: the flat ceiling crystals become the same purple.",
        "Note 34: the spikes on the column's collars pop in and out, and a spike can go in under you.",
        "Note 29: the geode turns half as fast again.",
        "Note 40: the big crystals in front of the screen are gone.",
        "Note 27: the floor's flicker is fixed; no two faces may sit in the same place.",
        "Parker, 11-13: the column's three rings become collars that wrap right round the column. That changes how La Columna plays, and it needs its own plan.",
    ],
}
