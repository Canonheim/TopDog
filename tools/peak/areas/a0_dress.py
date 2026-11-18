"""
THE RIDE, DRESSED: the scenery of the rest of biome 0, La Estacion, after the first screen.
The cart ride into the mountain (challenge 0.3, El Descenso, in its three stretches: 0.3a the
mouth, 0.3b the dip, 0.3c the gap) and the join to the mine (0 to 1, the end of the line).
The first screen (0.1 and 0.2) is a0_station.py's and is not repeated here; this file meets
it at the dock's west end (its back deck runs to x -36.6, its back posts end at x -34).

Scenery only: decos. Nothing here can be stood on or held. The designs are
docs/peak/playtest/design/data/a0_areas.py (0.3a, 0.3b, 0.3c, "0 to 1") and the biome's
sheet data/a0_biome.py; the model list that falls out of this file is
docs/peak/models/a0_models.md.

Depth: the play space is z -1.2 .. 1.2. Everything here stands behind -1.25 or in front of
+1.25, except what is flush on a course solid: the tunnel's bed and roof (skins of the cave's
slabs), the three rail pieces on the drop, the two timber sills and the buffer stop (a skin).
In the tunnel, from the back: the rock behind the planks to z -3.5, the back wall's face at
-1.9, the sets' back posts -1.9 .. -1.6, the trough -1.6 .. -1.4, the lanterns and the sign
about -1.4, then the play space, then the front posts at +1.3 .. +1.6. Each set's cap runs
across the top of the play space, flat under the roof, 4.7 m above the bed: out of reach
(the design's note: "the one piece that crosses it").

Walls and masses (BRIEF.md): every wall and rock mass here is ONE painted piece made for its
place, never a repeated panel. The plank lining's level planks are long painted bands; the
missing planks, the wet rock, the bricked passage, the hard rib and the black seep are flush
paint on the wall's face. No dark slot or recess is cut into any face: the shrine stands
proud of the wall, the boarded passage is boarded right over. The few real breaks are the
gap (the wall broken out for 8 m) and the hill's two small outcrops, which carry flat painted
dry-country plants.

A deco's origin is the middle of its base (x and z) at its foot (y), unless its comment says
otherwise. For the long pieces (walls, bed, roof) that means: the middle of its x span, the
bottom of its box, the middle of its depth. A deco's size is the size its model is MADE at.

FOR THE AREA FILE (tools/peak/areas/a0.py; the fix thread's):
 1. Call this file: `import a0_dress` beside `import a0_station`, and `a0_dress.dress(A)`
    on the line after `a0_station.dress(A)`.
 2. Take out the tunnel's back-wall card (A.card at z -3.0, x -152 .. -36, tone #33241A).
    dsc_back_wall_a .. d stand from z -1.9 back to -3.5 in its place; the card would cut
    through them. (Their stand-ins cover the same ground until they land.)
 3. Take out the mine_frame deco at the mouth (x -36, z 0): its posts stand inside the play
    space. The mouth is now set 0, whitewashed (dsc_set_white and dsc_front_post_white,
    placed here), with the pug's board over it.
 4. Take out the seven lantern_mine decos in the lantern loop. They are placed here as
    lantern_hang under a set's cap, 0.4 m further back (the designs' note), snapped to the
    nearest set: x -46.4, -62.0, -77.6, -90.0 (on a spike in the rib), -103.6, -119.2,
    -134.8. Keep the A.light calls; to sit each light in its lantern, move it to (that x,
    the hook's y - 0.27); the hooks' y are in LANTERNS below.
 5. In the rail loop, leave out the three pieces on the drop centred at x -91.75, -98.75 and
    -102.25 (rot 17.074). dsc_rail_torn, dsc_rail_landing and dsc_rail_banked take their
    places exactly (placed here). The piece at -95.25 stays as it is.
 6. Give the cave's slabs their skins (A.cave builds them; set s["skin"] on each after the
    call, by where it lies). Their decos (skin=True) are placed here.
      bed (grip rock): x -36 .. -46 and -46 .. -62, and the corner filler at x -62:
        "dsc_bed_a"; x -62 .. -78, -78 .. -90, -90 .. -104 and the filler at -104:
        "dsc_bed_b"; x -104 .. -120 and -120 .. -136: "dsc_bed_c"; x -136 .. -152:
        "dsc_bed_d".
      roof (rock2): x -36 .. -46, -46 .. -62 and the fillers at -46 and -62: "dsc_roof_a";
        x -62 .. -78, -78 .. -90, -90 .. -104 and the fillers at -90 and -104: "dsc_roof_b";
        x -104 .. -120, -120 .. -136 and the filler at -120: "dsc_roof_c"; x -136 .. -152:
        "dsc_roof_d".
    Add these skins in the same change as this file: a skin deco whose model has landed is
    drawn whether or not its solid names it.
 7. The buffer, A.box(-150.3, -11.6, 0.6, 0.8, "iron"): add skin="dsc_buffer_stop". Its
    size stays (the design: "It keeps its size").
 8. Not scenery, already in the designs' notes for the fix thread: the cart's hop over the
    torn rail (note 73: the path through (-90, -2.2), (-91.9, -2.11), (-93.8, -2.46),
    (-95.7, -3.27), (-97.6, -4.54)), its landing dust and shake, and the effects (cold light
    and mist at the gap, drips past the wet wall, water over the door's sill).
 9. For a1.py, not this file: the door set at x -152 (a1's mine_frame, which the mine shares)
    has its front post broken in two in the join's design. Swap that deco's model for
    mine_frame_broken (in the model list), same place and size.
"""
import math

# ---------------------------------------------------------------- the lines things stand on
DECK = 2.2  # the dock's top
RAIL_Z = -3.7  # the dock's back rail (as a0_station.py)
POLE_Z = -3.55  # the bunting poles, lashed to the front of the back rail
WALL = -1.9  # the tunnel's back wall: its face
WALL_ZC = -2.7  # ... and the middle of its depth (it is 1.6 m deep, back to -3.5)
BACK_Z = -1.75  # a set's back post (its middle; 0.3 deep, its back on the wall)
FRONT_Z = 1.45  # a front post (its middle)
TROUGH_Z = -1.5  # the water trough, on the posts' fronts
LAMP_Z = -1.4  # a lantern's hook, under its cap
TROUGH_UP = 0.45  # the trough's underside above the bed

# The rail bed (the tunnel's floor) as a0.py makes it; the roof is 5 m above it all the way.
BED = [(-36.0, 2.2), (-46.0, 0.75), (-62.0, -3.45), (-78.0, -4.65), (-90.0, -2.65),
       (-104.0, -6.95), (-120.0, -10.05), (-136.0, -11.65), (-152.0, -12.0)]

# The timber sets: one every 2.6 m from the mouth (set 0, x -36) to set 43 (x -147.8), then
# the wide bay with the buffer, then the door set at x -152 (a1's).
def _set_x(k):
    return round(-36.0 - 2.6 * k, 1)


def fy(x):
    """The bed's height at x."""
    for (xa, ya), (xb, yb) in zip(BED, BED[1:]):
        if xb <= x <= xa:
            return round(ya + (yb - ya) * (x - xa) / (xb - xa), 3)
    return BED[0][1] if x > BED[0][0] else BED[-1][1]


# The sets each stretch keeps, and how they look (the designs' "timber sets" items).
SETS_WHITE = range(0, 11)  # 0.3a: whitewashed, the mouth is set 0
SETS_BARE = [11, 12, 13, 14, 18, 19, 20, 23, 24, 25, 26]  # 0.3b: bare. 21 and 22 are left out: the rib holds itself up
SETS_STAINED = [15, 16, 17]  # 0.3b: the low point, the posts' feet stained dark to knee height
SETS_GREY = [27, 28, 29, 30, 31, 32, 33, 34, 35, 37, 39, 40, 42, 43]  # 0.3c and the join. 36 went with the wall
SETS_CRACKED = [38, 41]  # a cracked cap held by an extra prop, 0.5 m west of the post
LEAN = {29: 2.0, 34: -2.5, 42: 1.5}  # "some leaning a little"
FRONTS = [(0, "dsc_front_post_white"), (4, "dsc_front_post_white"), (8, "dsc_front_post_white"),
          (12, "dsc_front_post_bare"), (16, "dsc_front_post_bare"), (20, "dsc_front_post_bare"),
          (25, "dsc_front_post_bare"),  # moved one set down the hill: nothing crosses the cart as it lands
          (28, "dsc_front_post_grey"), (32, "dsc_front_post_grey"), (40, "dsc_front_post_grey")]

# The lanterns: (x, the hook's y). Each hangs under a set's cap at a bend in the grade; the
# crest's hangs from its own spike in the rib, where there is no cap.
LANTERNS = [(_set_x(k), round(fy(_set_x(k)) + 4.7, 3)) for k in (4, 10, 16)] + [(-90.0, round(fy(-90.0) + 4.45, 3))] \
    + [(_set_x(k), round(fy(_set_x(k)) + 4.7, 3)) for k in (26, 32, 38)]

# The trough along the wall's foot: from the pump in the dip to the door, broken by the gap.
TROUGH_RUNS = [(-79.4, -123.8), (-132.4, -151.8)]


def _chain(x_east, x_west, unit):
    """Pieces of about `unit` metres laid along the bed from x_east to x_west:
    (middle x, middle y on the bed, rot, scale)."""
    xs = [x_east] + [p[0] for p in BED if x_west < p[0] < x_east] + [x_west]
    out = []
    for xa, xb in zip(xs, xs[1:]):
        ya, yb = fy(xa), fy(xb)
        L = ((xa - xb) ** 2 + (ya - yb) ** 2) ** 0.5
        n = max(1, round(L / unit))
        ang = math.degrees(math.atan2(yb - ya, xb - xa))
        if abs(ang) > 90:
            ang -= 180.0 if ang > 0 else -180.0
        for i in range(n):
            f = (i + 0.5) / n
            out.append((round(xa + (xb - xa) * f, 3), round(ya + (yb - ya) * f, 3), round(ang, 3), round(L / n / unit, 3)))
    return out


def dress(A):
    # ================================================================ 0.3a: the dock's west end, the mouth, the first drop
    # ------------------------------------------------------------ the mountain's foot, behind the dock's last 6 m
    # Pale dry rock coming down to the road, painted (BRIEF: walls and masses). Its face leans
    # forward as it rises: behind z -4.9 at the road (behind the chute), behind the hopper
    # (-3.9) at the deck, and at -1.9 where it meets the mouth's set above y 5.5. Its outline
    # is the design's: (-29.5, 0), (-31.2, 2.8), (-34, 5.5), (-36, 9.7). Two small outcrops
    # stand out of its face, each carrying a flat painted plant (their tops are where the
    # plants stand, below).
    A.deco("dsc_hill_foot", -32.75, 0.0, z=-3.95, size=(6.5, 9.7, 4.1), tone="rock2")
    A.deco("dsc_ledge_agave", -35.4, 7.9, z=-2.1, size=(0.6, 0.45, 0.05), tone="back2")
    A.deco("dsc_ledge_grass", -34.4, 6.2, z=-2.4, size=(0.5, 0.4, 0.05), tone="back2")

    # ------------------------------------------------------------ the dock's back half: the rail carries on from the station
    # (a0_station.py's back rail ends at x -22.2 and its back posts at -26 and -34 already
    # stand here; these four lengths take the rail on to x -30.2, its posts still every metre)
    for rx in (-23.2, -25.2, -27.2, -29.2):
        A.deco("dock_back_rail", rx, DECK, z=RAIL_Z, size=(2.0, 1.0, 0.1), tone="wood2")
    # The ore hopper on its legs against the hill, where carts were tipped, and its chute down
    # behind the dock to where the wagons stood. The chute's high end is WEST, tucked under the
    # hopper's back spout at (-31.1, 3.0); its low end rests on the road at x -27.4.
    A.deco("dsc_ore_hopper", -32.4, DECK, z=-2.85, size=(2.8, 2.4, 2.0), tone="wood2")
    A.deco("ore_chute", -29.4, 0.0, z=-4.3, size=(4.0, 3.2, 1.0), tone="wood2")
    A.deco("dsc_mule_trough", -26.7, DECK, z=-2.6, size=(1.4, 0.4, 0.4), tone="wood2")  # for the mules that hauled the full carts up

    # ------------------------------------------------------------ the bunting's end: the town comes 10 m into the mountain
    # Two more poles on the back rail, 7.3 m apart (the station page's own pole is at x -15).
    # A pole's lashing, where strings tie, is 2.91 up: y 5.11.
    A.deco("bunting_pole", -22.1, DECK, z=POLE_Z, size=(0.17, 3.2, 0.17), tone="wood2")
    A.deco("bunting_pole", -29.4, DECK, z=POLE_Z, size=(0.17, 3.2, 0.17), tone="wood2")
    # pole to pole, flat at one depth: the kit's torn string. It is a line unit (8 m): the game
    # fits it to the span given, so its cord's ends (0.98 over its lowest point) meet the two
    # lashings exactly. Origin: the middle of its lowest point.
    A.deco("papel_tatters", -25.75, 5.11 - 0.98, z=POLE_Z, size=(7.3, 0.97, 0.03), tone="accent")
    # from the second pole through the air to the pug board's bracket, in real depth. Origin:
    # its EAST fixing (the pole's lashing); the far fixing is at x -4.9, y +2.14, z +2.1.
    A.deco("dsc_bunting_to_mouth", -29.4, 5.11, z=POLE_Z, size=(4.9, 2.8, 2.1), tone="accent")
    # inside: from the mouth's cap to the cap of set 4, by the first lantern, and no further.
    # Origin: its EAST fixing, on the mouth cap's west face; the far fixing is at x -10.0,
    # y -1.5 (set 4's cap), the same depth. Its lowest flag is 5.1 up at x -41, well over the cart.
    A.deco("dsc_bunting_in", -36.22, 6.9, z=-1.45, size=(10.0, 1.8, 0.1), tone="accent")

    # ------------------------------------------------------------ the pug over the mouth, the fifth poster
    # A round painted board, 1.2 m across, on an iron bracket out of the rock above the cap,
    # turned to face the camera like a shop sign. Origin: the bracket's foot on the rock face
    # (its west end, at its underside); the board's middle is at x +0.8, y +0.7 from it.
    A.deco("dsc_mouth_pug_board", -34.9, 7.25, z=-1.45, size=(1.4, 1.35, 0.15), tone="accent")
    # A plank board nailed to the mouth's back post on its east side, turned to face you, and
    # on it an old copy of the fangs, sun-bleached, its lower third torn away. Origins: the
    # middle of each one's BACK face (the posters' own rule).
    A.deco("dsc_poster_board", -35.5, 3.75, z=-1.62, size=(0.7, 0.9, 0.04), tone="wood2")
    A.deco("missing_poster_b_old", -35.5, 3.867, z=-1.58, size=(0.5, 0.47, 0.02), tone="back")

    # ------------------------------------------------------------ on the bed, flush: the sill where the dock meets the rock
    # A timber sill shod with iron, worn hollow in the middle by wheels, across the track.
    A.deco("dsc_mouth_sill", -36.1, 1.75, z=0.0, size=(0.4, 0.45, 2.4), tone="wood")

    # ================================================================ the tunnel: its rock, its back wall, its sets
    # ------------------------------------------------------------ the back wall, one painted piece per stretch
    # Each is the plank lining (level planks: long painted bands, laid level while the floor
    # falls, so the wall shows the grade) and the rock's own body behind it (to z -3.5), seen
    # where the planks are gone and at the gap's broken edges. Bounded by the bed and the
    # roof (it tucks 0.4 under the bed and over the roof).
    # 0.3a: limewashed white as far as the second lantern; the bricked-up side passage (x -56.4
    # .. -54.6, 0.15 over the bed, 1.8 by 2.9) is whitewashed brick painted flush on it.
    A.deco("dsc_back_wall_a", -49.0, -3.85, z=WALL_ZC, size=(26.0, 11.45, 1.6), tone="back")
    # 0.3b: bare lining, pale with old dust behind the landing. Over the crest the lining stops
    # for the hard rib: a slanting band of bluer rock 3 m wide from (-94.6 .. -91.8) at the bed
    # to (-90 .. -87.2) at the roof, its old drill holes painted dots. Down the drop two patches
    # of planks are gone and wet rock shows (x -102.3 and -104.6, 1.3 to 2.6 over the bed):
    # flush paint, the first wet on the ride.
    A.deco("dsc_back_wall_b", -83.5, -7.54, z=WALL_ZC, size=(43.0, 10.29, 1.6), tone="back")
    # 0.3c: grey lining, planks missing, wet rock behind; the black seep between sets 29 and 30
    # (an even band of glossy black mud 1.6 m wide from the roof to the bed, wavy-edged, pale
    # drips on it as short round-ended lines; nothing on it tapers). Its west end is the gap's
    # ragged east edge (x -124.0 at the bed, -124.3 higher up).
    A.deco("dsc_back_wall_c", -114.65, -10.88, z=WALL_ZC, size=(19.3, 9.14, 1.6), tone="back")
    # the join: the lining smashed, wet rock behind; its east end is the gap's ragged west edge
    # (x -132.3); its west end meets the mine's own back wall at the door (x -152).
    A.deco("dsc_back_wall_d", -142.15, -12.4, z=WALL_ZC, size=(19.7, 6.52, 1.6), tone="back")

    # ------------------------------------------------------------ the bed and the roof: skins of the cave's slabs (FOR THE AREA FILE 6)
    # A few large painted planes each, the rock's grain as long wavy lines; 4 m deep, so the
    # back wall's foot and the front posts stand on rock. The bed stays dry, pale and matte
    # everywhere (it grips). dsc_roof_a carries the limewash on its first 10 m, fading out.
    for model, mx, y0, w, h in (("dsc_bed_a", -48.78, -6.42, 26.47, 8.62), ("dsc_bed_b", -83.12, -9.91, 42.73, 7.27),
                                ("dsc_bed_c", -119.72, -14.64, 32.61, 7.69), ("dsc_bed_d", -143.97, -15.0, 16.11, 3.35),
                                ("dsc_roof_a", -49.38, 1.54, 26.8, 8.63), ("dsc_roof_b", -83.44, -1.96, 42.92, 7.27),
                                ("dsc_roof_c", -120.15, -6.65, 32.34, 7.65), ("dsc_roof_d", -144.03, -7.0, 16.11, 3.35)):
        A.deco(model, mx, y0, z=0.0, size=(w, h, 4.0), tone="rock", skin=True)
    # The new stretch's bed and roof (quality run, MINE_PASS F14, reviewer 8.5, 11-18), in the game's numbers (not moved):
    # dark mine rock in beds and hand-cut facets, ballast in clumps between the sleepers with the odd sawn tie end, broken
    # ore bands, the snapped haulage rope from the brow sheave to the foot, the sprung runaway catch, spilled ore at the
    # foot; the roofs the mine's dark rock with the sets' cap sockets. The brow carries on east over the slabs past
    # dsc_bed_d's cut, flush with its planes. (Skins of the cave's slabs by place: a0.py.)
    for model, mx, y0, w, h, d in (("mina_ride_bed_brow", -153.066, -17.01, 10.22, 5.6, 3.94),
                                   ("mina_ride_bed_incline", -172.475, -27.941, 31.07, 13.8, 3.94),
                                   ("mina_ride_bed_foot", -198.999, -32.0, 24.05, 6.97, 4.05),
                                   ("mina_ride_roof_brow", -155.576, -9.2, 10.65, 5.15, 3.89),
                                   ("mina_ride_roof_incline", -173.511, -20.12, 31.02, 13.73, 3.88),
                                   ("mina_ride_roof_foot", -199.53, -24.52, 23.06, 7.22, 3.9)):
        A.deco(model, mx, y0, z=0.0, size=(w, h, d), tone="rock2", skin=True)
    # The new stretch's hero in the lining's recess at the brow (quality run, MINE_PASS F17, reviewer 8.5, 11-18): the
    # hand-braked haulage drum on its A-trestles, the rope in fat coils with its run off the drum's bottom ending frayed by
    # the bed's torn end, the brake band to its long lever, the brakeman's seat, the pug in the gear. In the game's numbers.
    A.deco("mina_winding_house", -154.655, -13.0, z=-2.12, size=(4.11, 3.384, 1.603), tone="back")

    # ------------------------------------------------------------ the timber sets
    # A set's back piece is the back post (0.3 square, 4.7 tall, against the wall) and its cap
    # (0.44 wide, 0.3 thick), which runs from the wall forward over the play space to z +1.6,
    # flat under the roof. Origin: the back post's foot (so the cap runs 3.35 m forward of it).
    for k in SETS_WHITE:
        A.deco("dsc_set_white", _set_x(k), fy(_set_x(k)), z=BACK_Z, size=(0.44, 5.0, 3.5), tone="bone")
    for k in SETS_BARE:
        A.deco("dsc_set_bare", _set_x(k), fy(_set_x(k)), z=BACK_Z, size=(0.44, 5.0, 3.5), tone="wood2")
    for k in SETS_STAINED:
        A.deco("dsc_set_bare_stained", _set_x(k), fy(_set_x(k)), z=BACK_Z, size=(0.44, 5.0, 3.5), tone="wood2")
    for k in SETS_GREY:
        A.deco("dsc_set_grey", _set_x(k), fy(_set_x(k)), z=BACK_Z, rot=LEAN.get(k, 0.0), size=(0.44, 5.0, 3.5), tone="back2")
    # the cracked cap and its extra prop (x -0.5 from the post); origin still the post's foot
    for k in SETS_CRACKED:
        A.deco("dsc_set_grey_cracked", _set_x(k), fy(_set_x(k)), z=BACK_Z, size=(0.94, 5.0, 3.5), tone="back2")

    # ------------------------------------------------------------ the lanterns (the light is a0.py's)
    # lantern_hang's origin is its hook; its spike runs back 0.17. The crest's is driven into
    # the rib, so its hook stands nearer the wall.
    for x, hy in LANTERNS:
        A.deco("lantern_hang", x, hy, z=-1.72 if x == -90.0 else LAMP_Z, size=(0.28, 0.52, 0.31), tone="gold")

    # ------------------------------------------------------------ the water trough along the wall's foot, in 2 m lengths
    # On the posts' fronts, 0.45 over the bed, from the pump in the dip to the door; the gap
    # broke it. The last length ends in a spout at the door: its water runs over the sill
    # towards the gallery's mud pit (the water is the area file's effect).
    runs = [_chain(xe, xw, 2.0) for xe, xw in TROUGH_RUNS]
    for r, pieces in enumerate(runs):
        for i, (x, y, rot, sc) in enumerate(pieces):
            last = r == len(runs) - 1 and i == len(pieces) - 1
            A.deco("dsc_trough_spout" if last else "dsc_trough", x, y + TROUGH_UP, z=TROUGH_Z, rot=rot, scale=sc,
                   size=(2.0, 0.25, 0.2) if last else (2.0, 0.2, 0.2), tone="wood2")

    # ================================================================ 0.3b: the dip, the crest, the banked drop
    # The shrine, at the bottom of the dip: a small whitewashed arch standing proud of the
    # wall (not cut into it), its shallow niche painted warm, candle stubs on its sill, a
    # scrap of papel picado over it. The last thing in the town's paint. It hangs on the wall,
    # its foot 0.7 over the bed.
    A.deco("dsc_shrine", -73.7, -3.6, z=-1.95, size=(1.6, 2.1, 0.3), tone="bone")
    # The hand pump at the low point, handle up. Origin: its column's foot; the handle reaches
    # 0.9 m west. The trough starts at its spout.
    A.deco("dsc_hand_pump", -79.1, fy(-79.1), z=-1.65, size=(1.0, 1.7, 0.4), tone="iron")
    # The mine's danger sign, half way up the climb to the crest: the warning before the hop.
    A.deco("sign_pug_skull", -84.2, fy(-84.2), z=-1.32, size=(0.95, 2.16, 0.13), tone="bone")

    # ------------------------------------------------------------ on the bed: the drop's three rail pieces (FOR THE AREA FILE 5)
    # Each lies exactly where a0.py's rail loop put a rail_straight (its base 0.55 under the
    # cart's road, rot 17.074), each made at the 3.66 m the loop gives a piece on this stretch.
    # From the crest (x -90) to -93.5: both rails gone, bare sleepers; the near rail's stub
    # bent up at the crest like the lip of a ramp (0.45 high); the far rail lying loose
    # beside the sleepers.
    A.deco("dsc_rail_torn", -91.75, -3.2875, z=0.0, rot=17.074, size=(3.66, 0.45, 1.2), tone="iron")
    # x -97 .. -100.5: where the cart comes down. Rails scraped bright, sleepers doubled side
    # by side, pale dust thick between them.
    A.deco("dsc_rail_landing", -98.75, -5.4375, z=0.0, rot=17.074, size=(3.66, 0.25, 1.2), tone="iron")
    # x -100.5 .. -104: laid banked, the far rail 0.2 higher, so the sleepers' tops show.
    A.deco("dsc_rail_banked", -102.25, -6.5125, z=0.0, rot=17.074, size=(3.66, 0.45, 1.2), tone="iron")

    # ================================================================ 0.3c: the wet tunnel and the gap
    # A boarded side passage: boards nailed right across it, flush, no dark opening.
    A.deco("mine_boarded_passage", -115.3, fy(-115.3), z=-1.95, size=(1.8, 2.9, 0.3), tone="wood2")
    # The gap's low sill of rubble, along the bed where the wall fell out (x -124 .. -132.3),
    # 0.35 to 0.9 over the bed; laid on the bed's slope.
    A.deco("dsc_gap_sill", -128.15, fy(-128.15), z=-2.5, rot=5.711, size=(8.4, 1.0, 1.2), tone="rock2")
    # The waterfall cavern through the gap: ONE flat painted card (BRIEF: far backgrounds).
    # The cold grey-violet far wall, the fall as one pale line from above the frame to below it,
    # mist at its foot, five lantern specks on the workings beside it. Wide enough for every
    # view through the gap while it is on screen. Origin: the middle of its foot, the painted
    # face at z 0 facing the camera.
    A.deco("dsc_cavern_far", -128.4, -16.0, z=-16.0, size=(40.0, 14.0, 1.0), tone="back3")

    # ================================================================ the join: the end of the line
    # The miners' pegs: a board of six pegs, five empty, a hat on one. Origin: the middle of its
    # foot line (the hat's lowest point), on the wall's face; the board's top is 0.6 up.
    A.deco("dsc_peg_board", -146.5, -10.75, z=WALL, size=(1.8, 0.6, 0.3), tone="wood2")
    A.deco("lantern_cold", -145.9, -10.85, z=-1.75, size=(0.28, 0.48, 0.28), tone="iron")  # the dead lamp, hung by its bail on the last peg
    # The buffer stop (FOR THE AREA FILE 7): a timber baulk laid right across the track, its near
    # end the course's iron block, faced with a dented iron plate; its far end held by two
    # braces raking back to the floor against the back wall. Origin: the middle of the
    # baulk's foot (x -150.3); the braces reach 1.3 m west of it, behind the play space.
    A.deco("dsc_buffer_stop", -150.3, -12.0, z=0.0, size=(1.7, 0.8, 3.4), tone="wood", skin=True)
    # (The worn timber sill at the door is gone, MINE_PASS F-C10: the mine's door set carries its own.)

    # ================================================================ the foreground: the front post of every fourth set
    # Posts 0.3 square, 4.7 tall to the cap's underside. One sweeps past about every 1.2 s.
    for k, model in FRONTS:
        A.deco(model, _set_x(k), fy(_set_x(k)), z=FRONT_Z, size=(0.3, 4.7, 0.3), tone="bone" if "white" in model else "wood2")
    # the one that would stand in front of the gap went with the wall: a stump
    A.deco("dsc_front_post_stump", _set_x(36), fy(_set_x(36)), z=FRONT_Z, size=(0.3, 0.5, 0.3), tone="back2")
