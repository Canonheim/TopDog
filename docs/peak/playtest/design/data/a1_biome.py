# Biome 1: La Mina Vieja. The sheet every area in the mine is drawn from. Format: see ../build.py.

BIOME = {
    "name": "La Mina Vieja",
    "line": "The old mine, 30 m under the trailhead to 90 m above it. Timber, rails and mud, round the great waterfall.",
    "story": [
        "The town's grandparents cut this mine by hand for gold. It is one big cavern with a 113 m waterfall down its middle, and the "
        "workings climb round the fall: galleries, ladder ways, plank catwalks, a bucket lift, a cart track on a ledge, roof beams, the "
        "winding wheel, a hoist shaft. Then the water got in and the roof started to fall, and the miners walked out and left everything where it stood.",
        "Since then the only people through here are the ones who came to climb the Peak. They left lanterns, bunting from town, and "
        "one of themselves, sitting by a cold lantern with tally marks scratched on the wall beside him.",
        "So every place in the mine is two things at once: a piece of a working mine that made sense on the day it was left, and the same "
        "place eighty years on, wet, rotted and half fallen. What you climb is what is still standing.",
    ],
    "built": [
        "Square-set timbering. Posts 0.35 m square, a cap across the top, a sill at the foot, a set every 1.3 m in a shaft and every 2.6 m in a gallery. The same posts and caps everywhere: this is the mine's one way of building.",
        "Plank lining between the sets, nailed on. Where the lining is gone, wet rock shows.",
        "Iron only where the miners needed it: rails on sleepers, strap brackets, chain, bolts, the rims of wheels. All of it rust orange.",
        "Rock cut by hand: flat pick-marked faces, old drill holes, and slanting seams of gold ore.",
        "Hoisting gear: the winding wheel, buckets, a hand winch, pulleys. Every one stands on a timber frame of the same posts.",
        "Nothing is painted, nothing is carved, nothing is brick. Paint and brick belong to the works above; carving belongs to the temple.",
    ],
    "light": "Almost dark. Warm amber pools round the lanterns, and between them you see little. The one cool thing in the room is the waterfall: "
             "pale blue-white, always somewhere in the picture, and brighter than anything else in the background. Far rock is a cold grey-violet, so the warm timber of the climb stands out in front of it.",
    "looks": [
        ["You can hold it", "Honey-coloured timber, pale chalky rock, rust-orange iron, rope. Dry and matte."],
        ["You can't", "Black wet mud and wet rock, glossy, with pale drips running down it."],
        ["It will break", "Grey rotten wood, already cracked, with a corner gone. It creaks and sheds dust before it goes."],
        ["It moves", "Iron and timber like the rest, but it always hangs from or runs on something you can see: a cable over a wheel, a chain, a rail."],
        ["It is scenery", "The same timbering, but greyer, darker and cooler than the timber you climb, and never honey-coloured. Nothing thin hangs in it near the climb."],
        ["It will hurt you", "It comes out of a dark hole you can see, and dust falls from the hole first."],
    ],
    "layers": [
        ["Background", "The rest of the working, carried on behind you: the back wall with its timber sets, ladder ways, boarded side tunnels, ore chutes, and further back the far wall of the cavern and the waterfall."],
        ["Play space", "The beams, planks, rungs, rails and rock that are still standing. Each one is the near end of something that runs back into the background."],
        ["Foreground", "The front post of a timber set, in broken lengths, and a low lip of rubble along the bottom of the frame. Only in front of rock, never in front of the open space you climb through."],
    ],
    "kit": [
        ["Timber set: post, cap, sill", "post 0.35 m square, 2.6 to 4 m tall; cap to suit", "every gallery and shaft; the front posts of the foreground", "Background, foreground", "in the kit: mine_post, mine_beam, mine_frame"],
        ["Plank lining panel: whole, planks missing, smashed", "one set wide, 1.3 m tall", "back walls of shafts and galleries", "Background", "new, three looks"],
        ["Half landing, left and right", "1.6 m by 1 m", "ladder ways behind shafts", "Background", "new"],
        ["Ladder: whole, snapped, hanging by one rail", "0.5 m wide, 1.3 to 2.6 m", "ladder ways; behind the rungs you climb", "Background", "new (bent rung in the kit: fit_ladder_rung_bent)"],
        ["Sawn beam end; splintered end; empty socket", "0.3 m", "where a beam meets rock, where one broke, where one is gone", "Play space, drawn on or added", "new"],
        ["Ore seam and drill holes", "a slanting band 0.4 m thick; holes 5 cm", "the face of any big blank rock", "Play space, drawn on", "new"],
        ["Rail track: straight, broken", "0.9 m gauge, 2 m lengths", "galleries, the ledge track, the trestle", "Play space, background", "in the kit: rail_straight, rail_broken"],
        ["Trestle bent", "3 m wide, to suit", "under any track that crosses air", "Background, play space", "in the kit: trestle_bent"],
        ["Minecart; ore bucket; ore crate", "cart 1.6 m; bucket 0.9 m; crate 0.8 m", "left where they stood", "Background", "in the kit: minecart, crate_ore; bucket new"],
        ["Hoist wheel on a frame; hand winch; pulley", "wheel 1.1 m; winch 1.6 m; pulley 0.5 m", "wherever something is lifted", "Background", "pulley in the kit; wheel and winch new"],
        ["Ore chute", "1 m wide, 3 m long, on legs", "from an upper level down to a track", "Background", "new"],
        ["Boarded side tunnel", "1.8 m by 2.9 m", "back walls, to say the mine goes on", "Background", "new"],
        ["Rubble heap: small, big", "1.5 m; 5 m by 2.5 m", "foot of falls; the foreground's low lip", "Background, foreground", "in the kit: rubble_pile (small)"],
        ["Dark hole: for falling rock, for a cove", "2 m across", "wherever something comes out of the rock", "Background", "new (note 12)"],
        ["Lantern: standing, hanging", "0.4 m", "the light of every area", "Background", "in the kit: lantern_mine, lantern_hang"],
        ["Skull-pug sign; pug arrow sign", "1 m", "danger; the way on", "Background", "in the kit: sign_pug_skull, sign_pug_arrow"],
        ["Miners' bunting", "3 to 6 m", "strung across galleries, high", "Background", "in the kit: papel_tatters"],
        ["Stalactites", "0.5 to 2 m", "roofs, never over a hold", "Background", "in the kit: stalactite_a, stalactite_b"],
        ["Climber's camp: bedroll, cold lantern, tally marks, pickaxe, rope coil", "small", "the frozen climber; one more camp, empty", "Background", "in the kit"],
        ["Waterfall pieces: the sheet, the mist at its foot, a wet shine on rock beside it", "to suit", "the room's spine", "Background", "the water overhaul (note 22)"],
        ["The frog, and its cave room", "frog 0.3 m; room 3 m by 2.5 m", "the west end of the Sump", "Background", "new (notes 60, 71)"],
    ],
    "arrive": "On the cart, down the tunnel from the station. The tunnel's timber sets have gone from whitewashed to grey and wet by the time the buffer tips you out, and you have already seen the waterfall cavern once, through a gap, on the way down.",
    "leave": "Up beside the top of the waterfall to its lip. The fall turns out to be the works' river going over a brick weir: the last timber set of the mine stands against the first brick arch of the works, and the amber lantern light gives way to cold teal.",
    "motifs": [
        "The waterfall is in the back of nearly every area, seen from a different height each time. It tells you how far up you are.",
        "The ones who tried: one frozen climber by a cold lantern, with tally marks.",
        "The town follows you up: the miners' bunting, torn.",
        "The pug: on the danger signs and the way signs, as a skull and as an arrow.",
        "The frog: in a little cave room at the west end of the Sump, the lowest place in the game.",
    ],
    "notes": [
        "Note 4: nothing in the scenery may look like a rope. The lift's two hanging lines became a dark hoistway.",
        "Note 6: a track that ends in air gets boards across the rails, and the falling cart is a real falling thing.",
        "Notes 9 to 12: the falling rocks come out of a dark hole, and leave by a broken board.",
        "Note 13: La Cortina's holds stay wet in turn, with a slow drip you can watch coming.",
        "Note 14: a rope hangs from the top of La Cortina to half way down. Note 15: a lifesaver at the foot of the wet slide.",
        "Note 40: pieces in front of the screen that hide the climber are gone. The foreground rule above comes from it.",
        "Note 71: the frog's cave at the west end of the Sump.",
    ],
    "ask": [
        "Is the scenery rule right for the mine: background timber greyer and cooler, so honey-coloured wood always means you can hold it?",
        "Should the waterfall really be in the back of nearly every area of the mine, or only where the route is close to it?",
    ],
}
