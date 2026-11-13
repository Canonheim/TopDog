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
"""

DECK = 2.2  # the dock's top
WALL_Z = -3.6  # the yard wall's front face
HOUSE_X, HOUSE_Z = -10.4, -1.5  # the station house: the middle of its front wall's foot


def dress(A):
    # ------------------------------------------------------------ the town side: the yard wall and the gate
    A.deco("stn_yard_wall", 7.25, 0.0, z=WALL_Z, size=(12.5, 4.2, 0.5), tone="back")
    # the town behind the wall: two real houses of the plaza, far enough back to be scenery
    A.deco("plaza_house_c", 3.6, 0.0, z=-13.0, size=(7.0, 8.5, 7.0), tone="back2")
    A.deco("plaza_house_a", 13.0, 0.0, z=-16.0, size=(8.0, 9.5, 7.0), tone="back2")
    # the Missing posters on the wall (Parker 11-13): two fresh, one old
    A.deco("missing_poster_a", 4.55, 1.5, z=WALL_Z + 0.012, size=(0.5, 0.7, 0.02), tone="accent")
    A.deco("missing_poster_b", 5.2, 1.46, z=WALL_Z + 0.012, rot=-3.0, size=(0.5, 0.7, 0.02), tone="accent")
    A.deco("missing_poster_a_old", 2.45, 1.42, z=WALL_Z + 0.012, rot=4.0, size=(0.5, 0.7, 0.02), tone="back")
    A.deco("sign_pug_arrow", 1.5, 0.0, z=-1.5, size=(1.0, 2.2, 0.1), tone="wood")
    A.deco("bunting_pole", 1.05, 0.0, z=-3.3, size=(0.12, 3.2, 0.12), tone="wood2")

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

    # ------------------------------------------------------------ the bunting, high and well back
    A.deco("papel_tatters", 5.6, 3.55, z=-3.2, rot=5.5, size=(9.4, 1.0, 0.05), tone="accent")  # gate to the pole
    A.deco("papel_tatters", -2.2, 4.2, z=-2.9, rot=-14.0, size=(6.8, 1.0, 0.05), tone="accent")  # the pole to the crane's head
    A.deco("bunting_pole", -14.3, DECK, z=-3.6, size=(0.12, 3.2, 0.12), tone="wood2")
    A.deco("bunting_pole", -22.3, DECK, z=-3.6, size=(0.12, 3.2, 0.12), tone="wood2")
    A.deco("bunting_pole", -30.3, DECK, z=-3.6, size=(0.12, 3.2, 0.12), tone="wood2")
    A.deco("papel_tatters", -18.3, DECK + 2.85, z=-3.5, size=(8.0, 1.0, 0.05), tone="accent")
    A.deco("papel_tatters", -26.3, DECK + 2.85, z=-3.5, size=(8.0, 1.0, 0.05), tone="accent")

    # ------------------------------------------------------------ on the deck's own face: its cross-beams' sawn ends
    x = -5.6
    while x > -36.0:
        A.deco("sawn_end", x, DECK - 0.225, z=1.2, size=(0.2, 0.2, 0.05), tone="wood")
        x -= 2.0

    # ------------------------------------------------------------ the foreground: sparse, at the frame's edges
    A.deco("fence_post_bunting", 12.6, 0.0, z=1.9, size=(0.18, 1.4, 0.18), tone="wood2")
    A.deco("agave_clump", 10.4, 0.0, z=2.6, size=(1.7, 1.3, 1.3), tone="back2")
