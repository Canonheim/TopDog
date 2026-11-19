"""
THE STATION, DRESSED: the scenery of challenges 0.1 and 0.2 (the first screen of the solo
mode), built as the test of the diorama designs (Parker, 2026-11-13: "build section 0.1-0.2
as a test attempting for it to be completely game ready").

Scenery only: decos and cards. Nothing here can be stood on or held; the steps, the dock,
the cart and the lever are a0.py's. The design is
docs/peak/playtest/design/a0/0_1_0_2_el_primer_paso_y_subete.html, and the models' contract
is Top Dog Kit\\docs\\STATION_TEST_BRIEF.md (origins, sizes, what each may take in depth).

Depth: the play space is z -1.2 .. 1.2. Everything here stands behind -1.25 or in front of
1.25, except the sawn ends, which are drawn on the deck's own front face.

Parker's notes on the first frames (11-13): "there should be a couple more whole houses in
the background, the arch should be lines up with an alley between them. There is no poles
holding those flags so have them running from between one of the houses to the station. Add
a run down, crumbly adobe house more to the left of the town, make the entire ground area
look beter since right now it is a massive flat tan plane".

A deco's size is the size its model is MADE at: the game rescales a landed model that is
more than a quarter off the size given here, so keep the two the same.
"""

DECK = 2.2  # the dock's top
WALL_Z = -3.6  # the yard wall's front face
HOUSE_X, HOUSE_Z = -10.4, -1.5  # the station house: the middle of its front wall's foot
GATE_X = 10.5  # the middle of the town gate
ROW_Z = -9.6  # the town's first row of houses (their middles; their fronts are at about z -7)


def dress(A):
    # ------------------------------------------------------------ the ground: designed dry country over the plaza's pale plane
    # (one flat slab, its origin the middle of the yard wall's foot line; it runs off every edge of the screen)
    A.deco("stn_yard_floor", -10.0, 0.0, z=WALL_Z, size=(96.0, 0.02, 122.0), tone="rock2")
    # low dry hills far behind, so the horizon is not a ruled line
    A.deco("stn_far_hills", -6.0, 0.0, z=-95.0, size=(160.0, 14.0, 0.5), tone="back2")

    # ------------------------------------------------------------ the town: the yard wall, the gate, and a street behind it
    A.deco("stn_yard_wall", 7.25, 0.0, z=WALL_Z, size=(12.5, 4.2, 0.5), tone="back")
    # The plaza's own houses, whole, in a row behind the wall. The gate looks straight down a
    # 3 m alley between two of them (their walls at x 9.0 and 12.0).
    A.deco("plaza_house_c", 2.1, 0.0, z=ROW_Z, size=(3.8, 8.6, 4.6), tone="back2")
    A.deco("plaza_house_a", 6.6, 0.0, z=ROW_Z, size=(4.8, 7.2, 5.1), tone="back2")
    A.deco("plaza_house_d", GATE_X + 4.06, 0.0, z=ROW_Z, size=(5.1, 9.1, 4.9), tone="back2")
    A.deco("plaza_house_b", 20.0, 0.0, z=ROW_Z + 0.6, size=(5.2, 6.8, 5.0), tone="back2")
    # a second row, further back: one closes the alley's far end, the others show over the roofs
    A.deco("plaza_house_e", GATE_X - 0.4, 0.0, z=-27.0, size=(5.5, 7.5, 5.3), tone="back3")
    A.deco("plaza_house_d_tan", 1.0, 0.0, z=-24.0, size=(5.1, 9.1, 4.9), tone="back3")
    A.deco("plaza_house_c", 17.5, 0.0, z=-25.0, size=(3.8, 8.6, 4.6), tone="back3")
    # the crumbling adobe house, west of the town row, behind the steps
    A.deco("adobe_ruin", -4.4, 0.0, z=ROW_Z, size=(7.0, 4.6, 5.0), tone="back")
    # the Missing posters on the wall (Parker 11-13): two fresh, one old
    A.deco("missing_poster_a", 4.55, 1.5, z=WALL_Z + 0.012, size=(0.5, 0.7, 0.02), tone="accent")
    A.deco("missing_poster_b", 5.2, 1.46, z=WALL_Z + 0.012, rot=-3.0, size=(0.5, 0.7, 0.02), tone="accent")
    A.deco("missing_poster_a_old", 2.45, 1.42, z=WALL_Z + 0.012, rot=4.0, size=(0.5, 0.7, 0.02), tone="back")
    A.deco("sign_pug_arrow_west", 1.5, 0.0, z=-1.5, size=(1.24, 1.66, 0.16), tone="wood")  # it points west, at the dock (Parker 11-13)

    # ------------------------------------------------------------ the bunting: fixed at both ends, no poles
    # (Parker 11-13: "it looks like the flag strings are still not connected to anything".
    # The kit's papel_tatters is a straight string at one depth, so its ends hung in the
    # air. These two are modelled in real depth, each with a hook at both ends.)
    # The long run: from the station house's roof (its east verge, by the front eave) through
    # the air to the front corner of the tall house beside the alley. Origin: the station end.
    A.deco("stn_bunting_run", -6.42, 5.3, z=-1.7, size=(18.6, 2.6, 5.8), tone="accent")
    # across the alley, wall to wall. Origin: its west end, on the house's side wall.
    A.deco("stn_bunting_alley", 8.7, 6.2, z=-8.6, size=(3.46, 0.9, 0.1), tone="accent")

    # ------------------------------------------------------------ the last load, behind the steps
    A.deco("barrel_side", -1.2, 0.0, z=-2.3, size=(1.1, 0.9, 0.9), tone="wood2")
    A.deco("ore_sacks", -3.3, 0.0, z=-2.5, size=(1.6, 0.75, 0.9), tone="rock2")
    A.deco("hand_crane", -5.5, DECK, z=-2.7, size=(3.3, 3.0, 0.8), tone="wood2")

    # ------------------------------------------------------------ the dock's back half
    x = -6.6
    while x > -36.0:
        A.deco("stn_dock_deck_back", x, DECK - 0.45, z=-1.2, size=(4.0, 0.45, 2.6), tone="wood2")
        x -= 4.0
    for px in (-10.0, -18.0, -26.0, -34.0):
        A.deco("dock_back_post", px, 0.0, z=-3.5, size=(0.3, 1.75, 0.3), tone="wood2")
    for rx in (-15.2, -17.2, -19.2, -21.2):
        A.deco("dock_back_rail", rx, DECK, z=-3.7, size=(2.0, 1.0, 0.1), tone="wood2")
    A.deco("minecart_blocks", -16.6, DECK, z=-3.0, size=(2.4, 1.3, 1.2), tone="wood2")

    # ------------------------------------------------------------ the station house, the frog, the third poster
    A.deco("stn_house", HOUSE_X, DECK, z=HOUSE_Z, size=(7.2, 3.9, 2.3), tone="back")
    A.deco("frog_asleep", HOUSE_X - 0.8, DECK + 1.1, z=HOUSE_Z + 0.11, size=(0.3, 0.22, 0.2), tone="accent")
    A.deco("missing_poster_c", HOUSE_X + 0.75, DECK + 1.5, z=HOUSE_Z + 0.012, rot=2.0, size=(0.5, 0.7, 0.02), tone="accent")

    # ------------------------------------------------------------ the dry country behind the dock and round the town
    # (each row: model, x, z, the size it is made at; everything on the ground, well behind the climb)
    for model, px, pz, size in (
        ("saguaro_b", -9.5, -14.0, (1.6, 5.2, 0.6)), ("saguaro_a", -19.5, -9.5, (1.4, 3.8, 0.6)),
        ("saguaro_a", -27.0, -17.0, (1.4, 3.8, 0.6)), ("saguaro_b", -33.0, -30.0, (1.6, 5.2, 0.6)),
        ("saguaro_a", -14.0, -34.0, (1.4, 3.8, 0.6)), ("saguaro_a", 24.5, -5.0, (1.4, 3.8, 0.6)),
        ("nopal_clump", -12.6, -7.2, (1.8, 1.5, 1.0)), ("nopal_clump", -24.0, -6.4, (1.8, 1.5, 1.0)),
        ("nopal_clump", -0.4, -6.2, (1.8, 1.5, 1.0)), ("nopal_clump", -30.5, -11.0, (1.8, 1.5, 1.0)),
        ("yucca", -16.5, -11.5, (1.2, 2.4, 1.2)), ("yucca", -7.6, -6.6, (1.2, 2.4, 1.2)), ("yucca", -29.0, -22.0, (1.2, 2.4, 1.2)),
        ("stone_cluster_b", -21.5, -13.0, (3.2, 0.9, 1.4)), ("stone_cluster_a", -11.0, -10.5, (1.6, 0.6, 1.0)),
        ("stone_cluster_a", -26.5, -8.2, (1.6, 0.6, 1.0)), ("stone_cluster_b", -5.0, -19.0, (3.2, 0.9, 1.4)),
        ("stone_cluster_a", -17.5, -5.6, (1.6, 0.6, 1.0)),
        ("shrub_dry", -14.6, -6.0, (0.9, 0.7, 0.6)), ("shrub_dry", -22.4, -8.8, (0.9, 0.7, 0.6)),
        ("shrub_dry", -8.8, -9.0, (0.9, 0.7, 0.6)), ("shrub_dry", -31.5, -6.8, (0.9, 0.7, 0.6)),
        ("shrub_dry", -19.0, -18.0, (0.9, 0.7, 0.6)), ("shrub_dry", -2.2, -14.5, (0.9, 0.7, 0.6)),
        ("grass_tuft_dry", -13.2, -5.0, (0.7, 0.55, 0.4)), ("grass_tuft_dry", -20.2, -5.4, (0.7, 0.55, 0.4)),
        ("grass_tuft_dry", -25.2, -10.0, (0.7, 0.55, 0.4)), ("grass_tuft_dry", -9.6, -5.6, (0.7, 0.55, 0.4)),
        ("grass_tuft_dry", -28.0, -5.2, (0.7, 0.55, 0.4)), ("grass_tuft_dry", -1.6, -5.2, (0.7, 0.55, 0.4)),
        ("grass_tuft_dry", -16.0, -8.0, (0.7, 0.55, 0.4)), ("grass_tuft_dry", -23.0, -15.5, (0.7, 0.55, 0.4)),
        ("dead_tree", -24.5, -26.0, (6.0, 8.0, 1.0)),
    ):
        A.deco(model, px, 0.0, z=pz, size=size, tone="back2")

    # ------------------------------------------------------------ on the deck's own face: its cross-beams' sawn ends
    x = -5.6
    while x > -36.0:
        A.deco("sawn_end", x, DECK - 0.225, z=1.2, size=(0.2, 0.2, 0.05), tone="wood")
        x -= 2.0

    # ------------------------------------------------------------ the foreground: sparse, and never over the climber
    # The camera sits at about the climber's chest height, so anything standing in front of
    # the road covers the climber up to its own height wherever the climber stands behind it.
    # So in front of the road only things under 0.3 m, or tufts far enough forward (z 6 and
    # more) that they sit below the feet. The tall pieces stand where nobody stands behind
    # them: in front of the dock (the climber is up on the deck there) and past the east wall.
    A.deco("agave_clump", -11.6, 0.0, z=3.0, size=(1.7, 1.3, 1.3), tone="back2")
    A.deco("stone_cluster_a", -15.2, 0.0, z=3.6, size=(1.6, 0.6, 1.0), tone="back2")
    A.deco("fence_post_bunting", 15.6, 0.0, z=1.9, size=(0.18, 1.4, 0.18), tone="wood2")  # (it stays here, Parker 11-20: the donkey is the last thing before the east edge)
    A.deco("grass_tuft_dry", 2.4, 0.0, z=6.4, size=(0.7, 0.55, 0.4), tone="back2")
    A.deco("grass_tuft_dry", 9.2, 0.0, z=7.0, size=(0.7, 0.55, 0.4), tone="back2")
    A.deco("grass_tuft_dry", -8.2, 0.0, z=6.6, size=(0.7, 0.55, 0.4), tone="back2")
