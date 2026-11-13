# Biome 0: La Estación. Format: see ../build.py.

BIOME = {
    "name": "La Estación",
    "line": "The trailhead at the edge of town, and the cart ride into the mountain. The only biome in the open air until the cliffs.",
    "story": [
        "This is where the mine's ore used to come out and where the town ends. A loading platform, a siding with one cart on it, a "
        "tunnel mouth, and the Peak standing over all of it. The mine shut long ago. The station is kept up now by nobody in particular, "
        "for the luchadores who come to climb: somebody still hangs bunting, somebody still oils the cart's brake.",
        "It is the last place that looks like the town: plaster, tiles, paint and noon sun. From the tunnel mouth inward, everything is the mine's.",
        "The ride is the way in: 115 m of track, a dip, a banked drop, a broken rail the cart jumps, one look at the waterfall cavern through a gap, and the buffer that tips you out.",
    ],
    "built": [
        "Town building: thick plastered walls in cream, terracotta roof tiles, painted woodwork, all in the plaza's own painted-cardboard look.",
        "Station gear in honey timber and red paint: the loading platform on posts, ore crates, barrels, a hand crane, the cart, its red brake lever.",
        "The tunnel mouth is the first timber set of the mine: the same posts and cap as every set inside, here whitewashed, with a painted pug over the cap.",
        "Down the tunnel the same sets go from whitewashed, to bare, to grey and wet. That is the whole of the change from town to mine, and it happens while you ride.",
    ],
    "light": "Noon sun, the brightest place in the game: cream walls, a blue sky, short hard shadows. In the tunnel the daylight shrinks to a "
             "dot behind you and the lanterns take over, one every twenty metres, each a little dimmer and more amber than the last.",
    "looks": [
        ["You can hold it", "Honey timber, crates, barrels, pale dry rock, the cart's wooden sides, rope."],
        ["You can't", "Almost nothing here: one streak of black mud in the tunnel, so the first slick thing you ever see is seen from a moving cart."],
        ["It moves", "The cart. Red brake lever, red painted band. Red means: this does something."],
        ["It is scenery", "The town and the mountain: far, flat and sun-bleached. Near scenery (the station house, the fence) is plaster and tile, which nothing you climb is made of."],
    ],
    "layers": [
        ["Background", "Near: the station house, the crane, stacked ore sacks, the back posts of the platform. Far: the Peak filling the west half of the sky, with the tiny bell at the top, and the town's roofs to the east. In the tunnel: the back wall's timber sets, side passages bricked or boarded, and once, the waterfall cavern."],
        ["Play space", "The crates and barrel, the platform, the cart and its track."],
        ["Foreground", "Outside: one fence post with a tail of bunting at the right edge of the first screen, a clump of agave at the bottom edge. In the tunnel: the front post of every fourth set, sweeping past the cart."],
    ],
    "kit": [
        ["Station house front: plaster wall, door, tiled roof, a bell on a bracket", "6 m wide, 4 m tall", "behind the platform", "Background", "new"],
        ["Loading platform back posts and rail", "posts 0.3 m, 2.2 m tall", "behind the platform you climb", "Background", "new, from the mine's timber set"],
        ["Ore crate; barrel; ore sacks", "0.8 m; 0.9 m; 0.6 m", "the steps, and stacked behind them", "Play space, background", "crate in the kit (crate_ore); barrel and sacks new"],
        ["Hand crane", "3 m tall", "at the platform's back edge, its hook wound right up", "Background", "new"],
        ["The cart, its siding, the brake lever", "cart 1.6 m", "the ride", "Play space", "in the kit: minecart, rail_straight, brake_lever"],
        ["Tunnel mouth: whitewashed timber set with a painted pug", "3.2 m wide, 3.4 m tall", "the way in", "Background and foreground post", "in the kit: mine_frame; the paint is new"],
        ["Pug arrow sign", "1 m", "pointing at the tunnel", "Background", "in the kit: sign_pug_arrow"],
        ["Bunting, torn", "4 to 8 m", "from the station house to the tunnel mouth, high", "Background", "in the kit: papel_tatters"],
        ["The board of the ones who tried", "1.6 m by 1.2 m", "on the station wall: rows of small painted masks, most crossed out", "Background", "new"],
        ["Fence post with a tail of bunting; agave clump", "post 1.4 m; agave 1 m", "the only foreground outside", "Foreground", "new"],
        ["The Peak, and the town, as far cut-outs", "the whole sky", "behind everything outside", "Background, far", "the plaza's cut-outs, reused"],
        ["Tunnel timber set: whitewashed, bare, grey and wet", "as the mine's", "the tunnel, one every 2.6 m", "Background, foreground", "in the kit: mine_post, mine_beam"],
        ["Tunnel lantern", "0.4 m", "one every 20 m", "Background", "in the kit: lantern_mine"],
        ["The gap: a broken-out stretch of tunnel wall", "8 m wide", "the one look at the waterfall cavern", "Background", "new"],
        ["Buffer stop", "1.2 m tall", "the end of the line", "Play space", "new"],
        ["The frog, on a windowsill", "0.3 m", "the station house window", "Background", "new (note 60)"],
    ],
    "arrive": "You start here, standing in the sun at the edge of town, facing the mountain.",
    "leave": "The cart's tunnel is the join with the mine. The timber sets go from whitewashed to rotten as you ride, the lanterns go from bright to amber, the bunting stops, and the gap shows you the waterfall cavern before you are in it. It is designed as its own page: the join from the station to the mine.",
    "motifs": [
        "The Peak itself, seen whole for the only time until the ending.",
        "The town follows you up: the bunting starts here, torn.",
        "The pug: painted over the tunnel mouth, and on the arrow sign.",
        "The ones who tried: the board of crossed-out masks on the station wall.",
        "The frog: on the station house windowsill, in plain sight. It teaches you to look for the others.",
    ],
    "notes": [
        "No note from the playtest was about the station itself.",
        "Note 60: a frog in every biome. Here it is not hidden.",
    ],
    "ask": [
        "The board of crossed-out masks on the station wall: do you want it? It is the first telling of 'the mountain is full of the ones who tried'.",
        "Should the frog at the station sit in plain sight, to teach the player to look for the hidden ones?",
    ],
}
