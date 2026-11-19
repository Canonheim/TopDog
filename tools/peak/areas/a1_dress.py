"""
LA MINA VIEJA, DRESSED: the scenery of all of biome 1, the old mine (y -37 to 92), from the
fifteen area pages and the join "1 to 2" in docs/peak/playtest/design/data/a1_areas.py and the
biome's sheet a1_biome.py (its `built`, `looks`, `layers` and `kit`). The cart room (1.7) and
Las Vigas (1.8) follow their note-103 pages. The join "0 to 1" is biome 0's.

Scenery only: decos. Nothing here can be stood on or held. The course (the rock, the beams,
the ladder, the rungs, the ropes, the chain, the rings, the staples, the wheel, the cart) is
a1.py's. The model list this file makes is docs/peak/models/a1_models.md.

Depth: the play space is z -1.2 .. 1.2. Everything here stands behind -1.25 or in front of
1.25, except three kinds of thing, each said where it is placed:
  - SKINS (skin=True): the painted rock masses and the ribs, cart road and stubs that are the
    LOOK of a course solid (MODELLING_RUN rule 4); they fill the solid they dress;
  - things DRAWN ON a solid's front face (z 1.2: sawn ends, sockets, splintered ends, nail
    rows, iron straps, stirrups, bolt plates, spike plates), thin, as the station's sawn ends;
  - the torn rail ends of the iron ladder (on its drawn rails, z -0.2), the gallery's worn
    path (painted on the floor you walk on), and `mine_frame_open`, the upper gallery's
    doorway set in place of today's `mine_frame` (its back post behind the play space, its cap
    across it under the roof, out of reach, at a doorway you only walk through).
The waterfall (its sheet, white water, mist) is a1.py's effect (the water overhaul, note 22)
and is not placed here.

A deco's size is the size its model is MADE at (the game rescales a landed model more than a
quarter off). The mine's timbers are one family, 0.35 m square, made at a few stock lengths;
a timber of another length is the nearest stock stretched by `scale` (always within a
quarter), as a1.py does today (`timber()` below picks it). A post laid on its side is a beam.
Scenery timber is grey (looks: "It is scenery"); the stand-in tone is "back".

Shared pieces are placed once, in the first section that names them, and the other page is
named in a comment (the gallery wall for 1.1 and 1.1b, the upper level for 1.10 and 1.11...).

FOR THE AREA FILE (tools/peak/areas/a1.py; the fix thread's):
  1. Call it: `import a1_dress` beside the other imports, and `a1_dress.dress(A)` after the
     course is built (before A.save()).
  2. Lanterns: the LANTERNS loop stops placing `lantern_hang` (this file places every
     lantern); move its lights to `a1_dress.LANTERN_LIGHTS` (x, y of each lit lantern's
     flame, 21 of them; colour, range and flicker as today).
  3. Decos to take out, because this file now places them (moved out of the play space, as
     the pages ask) or the page removes them:
     - line 145: the `mine_post` over each of La Galería's five beams (z -0.6);
     - lines 165-168: the camp's cold `lantern_mine`, `tally_marks`, `camp_bedroll`, `rope_coil`;
     - line 183: the six `mine_beam` braces under Los Tablones;
     - line 217: the `pulley` (z -0.5);
     - lines 235-236: the arm's and the deck's `mine_beam` braces (z -0.8);
     - line 283: `sign_pug_skull` at x -202.6 (z -1.0);
     - line 286: `rail_broken` at the stub's end (the road runs on; its broken stop is now at
       the lip, painted into `mine_cart_road`);
     - line 287: `trestle_bent` (its feet were in the air; the struts replace it);
     - line 296: the `mine_post` on each of Las Vigas's beams (z -0.6);
     - line 319: the staging's `mine_beam` brace; line 320: `crate_ore` at x -227.6;
     - line 475: the `stalactite_b` at x -224.0 (it hangs in the air the flings cross);
     - lines 478-479: the `papel_tatters` at x -170.5 and x -184.5;
     - line 483: the `mine_frame` at the upper gallery's mouth (x -230, y 57.4): its front
       post's middle length goes (1.9); this file places `mine_frame_open` and the two lengths;
     - line 487: the `minecart` in the pit; line 488: the `pickaxe`; line 489: `sign_pug_arrow`.
  4. Cards to take out: line 462 (the room's back wall, z -6: replaced by
     `mine_cavern_far_wall`), line 466 (the pillar's root, z -2: replaced by
     `mine_el_diente_body` and `mine_tunnel_back`), line 468 (the upper works, z -3: replaced
     by `mine_upper_works_body`). The two hoistway cards stay, as the pages ask.
  5. Skins: every slab `carve()` makes whose middle falls inside one of `SKIN_REGIONS` (the
     pillar, the east mass, the roof, the upper works, the west wall) takes `skin=` that stem.
     Also: the eight rib solids of 1.6 take `mine_rib_short` (proud 0.6), `mine_rib`
     (proud 0.9) or `mine_rib_wide` (proud 1.2); the eight stub solids of 1.10 take
     `mine_stub` (0.75 long) or `mine_stub_short` (0.6 long); the cart's new road (item 7)
     takes `mine_cart_road`. This file places each of those skin decos.
  6. Course changes on the pages, for the fix thread (not scenery): 1.0, the frog's cave
     (note 71): carve the room as air (_CAVE in a1_areas.py: x -253.4 .. -248, y -27.5 ..
     -24.8, the doorway x -249.2 .. -248 up to -25.4), a rock doorstep x -248.0 .. -247.2,
     y -28.3 .. -27.5 ("rock"), and the cave's floor (grip) at y -27.5; this file places the
     room's back, roof and things behind. 1.10: carve the chimney as air above the shaft
     (x -221.3 .. -219.3 at y 77, -221.0 .. -219.5 at 81.2: nobody can reach it).
  7. Note 103 (1.7, 1.8): the two chains on the first beam go (cadena_a, cadena_b); the new
     road from (-213.2, 40.0) to the lip (-223.0, 29.45), 0.4 m of timber under the rail; one
     chain 9.0 m from the ring at (-230.6, 44.2), in rusty red; three rings at (-230.6, 44.2),
     (-226.2, 46.2), (-221.8, 48.2), each wearing `iron_ring_pin_long` (a ring 0.5 across on a
     pin that comes 1.6 m out of the rib at z -1.6: new, see the model list); the lowest 0.1 m
     of the 2nd, 3rd and 4th beams and of the staging (x -237.2 .. -232.2) slick. The chock
     under the cart's west wheel (`mine_chock`, 0.45 x 0.32 x 0.3, new) belongs on the cart
     mover, so it can jump out when the cart starts.
  8. Holds' looks (the area file's): La Cortina's 28 holds wear `iron_staple` (18),
     `iron_staple_bent` (5) and, for the five always-dry ones, `mine_staple_bound` (new: the
     staple bound in pale cord), their feet on the throat's back wall, whose face this file
     puts at z -1.3 (THROAT_Z; -1.6 till 11-18). El Cubo's seven pillar rungs are "the same staples" (1.5 explains):
     they could wear `rung_iron`. The lift's weight could wear `lift_counterweight` (it has
     the lifting eye the page asks for).
  9. Things that would move: the water wheel behind La Polea Grande turns with the winding
     wheel (1.9), and the pulley over the hoistway turns, stops and turns back (1.5). Here
     they are still decos; give each a mover to make them turn.
"""
import math
import sweeps as _sw  # (model_bounds: what has landed in kit/models)

# ------------------------------------------------------------------ the lines things stand on
XF = -201.9            # El Diente's east face (the lift, the banded wall)
SUMP_FLOOR = -33.0     # the Sump's floor, under the water
SUMP_Y = -28.0         # the water's surface
GAL_Y = -12.6          # the gallery's floor (1.1, 1.1b)
GAL_ROOF = -7.5        # its roof
GAL_WALL_Z = -1.65     # the gallery's lining face (posts stand in front of it, to -1.25)
CAVE_WALL_Z = -2.9     # the cavern's hand-cut wall face (behind 1.0b, 1.3, 1.4, 1.5, 1.6)
WALK_Y = 6.0           # the plank walk (1.3) and the ladder's head
DECK_Y = 26.2          # El Cubo's station deck
TRACK_Y = 40.0         # the pillar's top: the cart's siding
ROOF_Y = 55.0          # the chamber's roof, under which Las Vigas hang
RIB_Z = -1.6           # the chain rib's face (1.7, 1.8)
UPPER_Y = 57.4         # the upper gallery's floor (1.9, 1.10)
UPPER_WALL_Z = -2.5    # the upper works' face behind the upper gallery and the top drift
DRIFT_Y = 72.0         # the top drift's floor (1.10, 1.11)
THROAT_Z = -1.3        # the throat's back wall face (1.11, the lip). (-1.6 till 11-18: MINE_PASS C7c, so a staple's legs are 1.3 m
                       # and it meets its hold from every angle; it was drawn 1.6 m behind its hold.)
FRONT_Z = 1.41         # the foreground's broken front posts (0.3 deep: z 1.26 .. 1.56)
LIP_Z = 1.65           # the low lips of rubble along the bottom of a frame
FACE = 1.2             # a course solid's front face: things drawn on it

# The course's own solids that wear one painted piece (FOR THE AREA FILE, item 5): every slab
# carve() makes whose middle is inside the polygon takes skin=stem. The pieces' own sizes are
# placed in dress() below.
SKIN_REGIONS = {
    "mine_el_diente": [(-208.9, -25.5), (-197.9, -25.5), (-197.9, 5.7), (-201.9, 5.7), (-201.9, 39.7), (-208.9, 39.7)],
    "mine_east_mass": [(-196.0, -38.0), (-147.0, -38.0), (-147.0, 21.3), (-196.0, 21.3)],
    "mine_chamber_roof": [(-152.5, 21.3), (-147.0, 21.3), (-147.0, 61.0), (-214.5, 61.0), (-214.5, 54.5), (-196.0, 54.5), (-152.5, 29.5)],
    "mine_upper_works_mass": [(-238.2, 85.8), (-230.2, 85.8), (-230.2, 54.5), (-214.5, 54.5), (-214.5, 81.0), (-226.0, 90.5), (-238.2, 90.5)],
    "mine_throat_west": [(-256.0, -38.0), (-244.0, -38.0), (-244.0, 91.0), (-256.0, 91.0)],
}

# Every lit lantern's flame (x, y), for a1.py's lights (FOR THE AREA FILE, item 2). Filled by dress().
LANTERN_LIGHTS = []

# The mine's timber, 0.35 m square, at its stock lengths. Posts stand on their foot; a beam's
# origin is the middle of its underside. Either can be laid at any angle.
_POSTS = (("mine_post_stub", 0.9), ("mine_post_short", 1.4), ("mine_post_mid", 2.0), ("mine_post", 3.0),
          ("mine_post_tall", 4.75), ("mine_post_long", 6.5), ("mine_timber_long", 8.5))
_BEAMS = (("mine_beam", 4.0),)
# The foreground's front posts, 0.3 m square, splintered at both ends.
_BROKEN = (("mine_post_broken_short", 1.6), ("mine_post_broken", 2.6), ("mine_post_broken_long", 3.8))

# La Cortina's 28 holds, as a1.py has them (row 0..13, side 0 west / 1 east), and its dry five.
_STAPLE = lambda r, s: (round(-235.6 + 0.11 * r + 1.3 * s, 2), round(73.3 + 1.25 * r, 2))
_DRY = [(1, 0), (4, 1), (7, 0), (10, 1), (13, 0)]
# Las Vigas's four beam pieces (x west, x east, top; 0.4 thick) and the hanger over each.
_VIGAS = [(-218.3, -213.9, 50.5), (-222.8, -220.8, 52.0), (-227.3, -225.3, 50.8), (-231.8, -229.8, 52.3)]
_HANGERS = [(-216.1, 50.5), (-221.8, 52.0), (-226.3, 50.8), (-230.8, 52.3)]


def dress(A):
    LANTERN_LIGHTS.clear()

    # ------------------------------------------------------------ helpers
    def timber(p0, p1, z, tone="back"):
        """One grey timber from p0 to p1 (its centre line), the nearest stock stretched."""
        L = math.dist(p0, p1)
        a = math.degrees(math.atan2(p1[1] - p0[1], p1[0] - p0[0]))
        stem, made = min(_POSTS + _BEAMS, key=lambda s: abs(math.log(L / s[1])))
        s = round(L / made, 3)
        if stem.startswith("mine_beam"):
            r = a - 180.0 if a > 90.0 else (a + 180.0 if a <= -90.0 else a)
            mx, my = (p0[0] + p1[0]) / 2, (p0[1] + p1[1]) / 2
            sr, cr = math.sin(math.radians(r)), math.cos(math.radians(r))
            A.deco(stem, round(mx + 0.175 * sr, 3), round(my - 0.175 * cr, 3), z=z, rot=round(r, 2), scale=s,
                   size=(made, 0.35, 0.35), tone=tone)
        else:
            A.deco(stem, p0[0], p0[1], z=z, rot=round(a - 90.0, 2), scale=s, size=(0.35, made, 0.35), tone=tone)

    def post(x, y0, y1, z, tone="back"):
        timber((x, y0), (x, y1), z, tone)

    def hbeam(x0, x1, y_under, z, tone="back"):
        timber((x0, y_under + 0.175), (x1, y_under + 0.175), z, tone)

    def front_post(x, y0, y1):
        """A front post's broken length in the foreground, in front of rock only."""
        L = y1 - y0
        stem, made = min(_BROKEN, key=lambda s: abs(math.log(L / s[1])))
        s = round(L / made, 3)
        A.deco(stem, x, y0, z=round(FRONT_Z + max(0.0, s - 1.0) * 0.15, 3), scale=s, size=(0.3, made, 0.3), tone="back")  # stretched, it is deeper: kept clear of 1.25

    def hang(x, y_hook, z, lit=True):
        """A hanging lantern (origin: its hook). Its flame is 0.27 under the hook."""
        A.deco("lantern_hang", x, y_hook, z=z, size=(0.3, 0.5, 0.3), tone="gold")
        if lit:
            LANTERN_LIGHTS.append((x, round(y_hook - 0.27, 2)))

    def stand(x, y_foot, z, lit=True):
        """A standing lantern. Its flame is 0.21 over its foot."""
        A.deco("lantern_mine", x, y_foot, z=z, size=(0.3, 0.5, 0.3), tone="gold")
        if lit:
            LANTERN_LIGHTS.append((x, round(y_foot + 0.21, 2)))

    def wall_lantern(x, y, wall_z):
        """A lantern on an iron bracket out of a wall face: the hook is 0.2 out, at the bracket's height."""
        A.deco("mine_wall_bracket", x, y, z=wall_z, size=(0.1, 0.3, 0.25), tone="iron")
        hang(x, y, wall_z + 0.2)

    def side_lantern(x, y, z, flip=False):
        """A lantern on an iron bracket out of a post's side, in the wall's plane. Origin: the
        bracket's fixed end; its hook is 0.42 along it (west if flip) and 0.03 down."""
        A.deco("mine_lantern_bracket", x, y, z=z, flip=flip, size=(0.48, 0.15, 0.06), tone="iron")
        hang(round(x - 0.42 if flip else x + 0.42, 3), round(y - 0.03, 3), z)

    def outcrop(x, y, wall_z, plant=None, small=False):
        """A small knob of the wall's rock with one of the mine's flat painted plants on it.
        Origin: the middle of its back edge's foot, on the wall face (it stands out toward +z)."""
        w, h, d = (0.6, 0.35, 0.3) if small else (1.0, 0.5, 0.45)
        A.deco("mine_outcrop_small" if small else "mine_outcrop", x, y, z=wall_z, size=(w, h, d), tone="back2")
        if plant == "fern":
            A.deco("mine_fern_pale", x, y + h, z=round(wall_z + d / 2, 3), size=(0.6, 0.5, 0.04), tone="bone")
        elif plant == "moss":
            A.deco("mine_moss", x, y + h, z=round(wall_z + d / 2, 3), size=(0.9, 0.18, 0.3), tone="accent")

    def mushrooms(x, y, z):
        """A clump of the mine's pale mushrooms on old timber (one flat painted card; origin: the
        middle of its back's foot, on the timber's face)."""
        A.deco("mine_mushrooms_pale", x, y, z=z, size=(0.35, 0.22, 0.05), tone="bone")

    def drawn(stem, x, y, size, tone="iron", rot=0.0, scale=1.0, z=FACE):
        """A thin thing drawn on a course solid's front face (origin: the middle of its foot line)."""
        A.deco(stem, x, y, z=z, rot=rot, scale=scale, size=size, tone=tone)

    # ============================================================ the room: the far wall and the masses
    # The cavern's far side, painted (quality run E1, reviewer 8.5, 11-17): galleries in tiers with
    # their ladders, chutes and hoist frames, eight warm lantern pools on cold grey-violet, the far
    # wheel and headframe small and hazed, the falls' glow the brightest thing, pale mist bands.
    # Four flush cards; origin on the far card's face, the middle of its foot.
    A.deco("mina_backdrop_cavern", -229.0, -50.0, z=-15.0, size=(124.35, 150.34, 2.80), tone="back2")
    # The course's rock, each mass one painted piece made for its place (skins: they fill the
    # solids they dress, z -1.2 .. 1.2). Origin: the middle of each one's foot.
    # El Diente (quality run, reviewer 8.5, 11-18): the pillar, its body carried back, El Tio over the
    # shoulder, the ore lenses of 1.6 in black clay, the hand-cut arch and its drowned sets in the Sump.
    A.deco("mine_el_diente", -203.4, -25.5, z=0.0, size=(12.6, 74.2, 4.36), tone="rock2", skin=True)
    A.deco("mine_east_mass", -170.0, -37.0, z=0.0, size=(44.0, 58.3, 2.4), tone="rock2", skin=True)
    A.deco("mine_chamber_roof", -181.25, 21.3, z=0.0, size=(66.5, 37.7, 2.4), tone="rock2", skin=True)
    A.deco("mine_upper_works_mass", -226.25, 55.0, z=0.0, size=(23.5, 35.0, 2.4), tone="rock2", skin=True)
    A.deco("mine_throat_west", -248.0, -37.0, z=0.0, size=(8.0, 127.0, 2.4), tone="rock2", skin=True)
    # Their bodies carried on behind (in place of today's flat cards). (El Diente's is part of it now;
    # its flat top at y 40 is still the ground the second cart and the back rail stand on, 1.7.)
    A.deco("mine_upper_works_body", -222.25, 55.0, z=-3.0, size=(15.5, 35.0, 1.0), tone="back")
    # The cavern's own hand-cut wall, 1.7 m behind the walk (1.3, 1.4, 1.5, 1.6, 1.0b): three
    # pieces made to meet, low (the landing), middle (the walk) and high (the lift and the ribs).
    A.deco("mine_cavern_wall_low", -184.95, SUMP_FLOOR, z=CAVE_WALL_Z, size=(25.9, 27.0, 4.18), tone="back")  # (quality run, reviewer 8.5) origin on its face
    A.deco("mine_cavern_wall_mid", -186.45, -6.0, z=CAVE_WALL_Z, size=(30.9, 24.0, 6.36), tone="back")  # (quality run, E2) origin on its face
    A.deco("mine_cavern_wall_high", -186.45, 18.0, z=-2.9, size=(30.9, 38.2, 3.25), tone="back")  # (quality run, E3) origin on its face
    # The cavern's east end over the ladder head (quality run, reviewer 8.5, 11-17): old stopes cut
    # along their beds, the lagged raise to the high gallery (sets, rails, a cart, papel, a lit drift),
    # flush with E2 and E3 at x -171; its lantern hangs on the mid stope's iron seat.
    A.deco("mina_set_stopes_east", -160.5, 4.0, z=CAVE_WALL_Z, size=(21.0, 36.7, 5.3), tone="back")
    wall_lantern(-159.4, 17.95, -3.11)

    # ============================================================ 1.0 The Sump and the frog's cave
    # The rock the cave is cut in, carried on west and back (black, running with spray), with
    # the room's mouth open in it, and the room itself: back wall and roof, its front cut away
    # (its floor is the course's: FOR THE AREA FILE, item 6).
    A.deco("mine_cave_rock", -252.0, SUMP_FLOOR, z=-2.775, size=(8.0, 18.0, 2.45), tone="back")
    A.deco("mine_frog_cave", -250.7, -27.5, z=-2.425, size=(5.4, 2.7, 2.35), tone="back2")
    outcrop(-254.2, -22.0, -1.55, "fern", small=True)  # kept green by the fall's spray
    A.deco("mine_frog_stove", -252.8, -27.5, z=-3.0, size=(0.6, 0.7, 0.5), tone="iron")
    A.deco("tea_kettle", -252.8, -26.8, z=-3.0, size=(0.31, 0.27, 0.24), tone="iron")
    A.deco("mine_bucket_upturned", -251.6, -27.5, z=-2.6, size=(0.6, 0.45, 0.6), tone="iron")
    A.deco("frog_sit", -251.6, -27.05, z=-2.6, size=(0.26, 0.26, 0.27), tone="accent")  # the mine's frog
    # (the shelf and the towel: origin the middle of the back's foot, on the room's back wall)
    A.deco("mine_frog_shelf", -251.2, -25.75, z=-3.5, size=(2.2, 0.45, 0.3), tone="wood2")
    A.deco("mine_towel_peg", -249.9, -26.9, z=-3.5, size=(0.4, 0.6, 0.1), tone="accent")
    hang(-249.7, -25.03, -2.4)  # the only warm light at the bottom of the mine
    A.deco("mine_water_marks", -248.95, -27.4, z=-1.3, size=(0.3, 0.9, 0.02), tone="bone")  # the watchman's marks, on the door post
    # The drowned level, 3 to 4 m behind: six sets under water to their caps, a boarded
    # tunnel seen through the water, a barrel wedged against a cap.
    for x in (-236.6, -234.0, -231.4, -226.2, -223.6, -221.0):
        post(x, SUMP_FLOOR, -27.75, -3.75)
    hbeam(-237.0, -231.0, -27.75, -3.75)
    hbeam(-226.6, -220.6, -27.75, -3.75)
    A.deco("mine_boarded_tunnel", -215.7, SUMP_FLOOR, z=-3.8, size=(1.8, 2.9, 0.4), tone="back")
    A.deco("barrel_side", -224.8, -27.45, z=-3.75, size=(1.1, 0.9, 0.9), tone="back")
    # Carts on the bottom, seen through the water: two upright, one on its side (a minecart's
    # origin is its floor's top, 0.34 over its wheels' foot).
    A.deco("minecart", -237.0, SUMP_FLOOR + 0.34, z=-2.2, size=(2.4, 1.1, 1.3), tone="back")
    A.deco("minecart", -232.8, SUMP_FLOOR + 0.34, z=-2.2, size=(2.4, 1.1, 1.3), tone="back")
    A.deco("ore_cart_wreck", -234.9, SUMP_FLOOR + 0.88, z=-2.2, rot=70.0, size=(2.48, 1.72, 1.22), tone="back")
    # The staging's back row: each held pile's twin, with the stub of the deck beam that joined them.
    for x in (-228.5, -219.0):
        A.deco("mine_pile_twin", x + 0.75, SUMP_FLOOR, z=-2.3, size=(0.95, 5.7, 0.4), tone="back")  # origin: the post's foot
    A.deco("sign_pug_arrow_east", -218.25, -27.9, z=-2.05, size=(1.24, 1.66, 0.16), tone="bone")  # the way out, east along the piles
    # Drawn on the four piles you hold: a dark stain to the old high water and a rusted band at the head.
    for x in (-228.5, -219.0, -211.0, -194.5):
        drawn("mine_pile_band", x, SUMP_Y, (0.42, 0.8, 0.02))

    # ============================================================ 1.0b The landing stage and the incline
    # (Its two moss knobs are out: the refuge niche and the high working stand there in mine_cavern_wall_low now.)
    # (The tunnel through the pillar's foot, its back wall and its drowned sets, are El Diente's now.)
    mushrooms(-199.95, -26.6, -1.5)
    # The back rail, still spiked down from the water to the gallery's mouth (ten 2 m lengths),
    # and the grey cart a third of the way up, where the winch let it stop.
    a = math.atan2(-12.7 + 28.62, -176.2 + 188.6)
    for k in range(10):
        A.deco("mine_rail_single", round(-188.6 + (k + 0.5) * 2.02 * math.cos(a), 3), round(-28.62 + (k + 0.5) * 2.02 * math.sin(a), 3),
               z=-1.5, rot=round(math.degrees(a), 2), scale=1.01, size=(2.0, 0.15, 0.15), tone="iron")
    A.deco("minecart", -184.6, -22.75, z=-2.0, rot=round(math.degrees(a), 2), size=(2.4, 1.1, 1.3), tone="back")
    # The drowned level carried on east of the pillar.
    for x in (-196.4, -193.2, -190.6):
        post(x, SUMP_FLOOR, -27.75, -2.45)
    hbeam(-196.8, -190.2, -27.75, -2.45)
    # The lamp post and the arrow at the back of the landing stage (the post's crook puts its
    # lantern 0.35 east of it, 3.45 over its foot).
    A.deco("mine_lamp_post", -188.95, -27.7, z=-1.45, size=(0.55, 3.5, 0.2), tone="back")
    hang(-188.6, -24.25, -1.45)
    A.deco("sign_pug_arrow_east", -187.9, -27.7, z=-1.5, size=(1.24, 1.66, 0.16), tone="bone")  # up the incline
    A.deco("mine_flat_boat", -192.45, -28.6, z=-1.9, rot=8.0, size=(3.5, 0.8, 1.0), tone="back")  # sunk at its mooring
    # The landing stage's two short piles, behind its deck.
    for x in (-190.0, -187.4):
        post(x, SUMP_FLOOR, -28.0, -1.45)
    drawn("eye_bolt_plate", -190.2, -27.85, (0.35, 0.35, 0.21))  # its mooring ring (origin: the plate's middle)
    # Drawn on the six sleepers (a1.py line 128): two spike plates each; and two faint rust
    # lines up the slope between them.
    for y in (-14.8, -17.0, -19.2, -21.4, -23.6, -25.8):
        x = -176.0 - (-12.9 - y) / 1.2833
        for dx in (-0.3, 0.3):
            drawn("mine_spike_plate", round(x + dx, 3), round(y + 0.32, 3), (0.3, 0.12, 0.02))
    drawn("mine_rust_lines", -182.6, -21.25, (20.5, 0.12, 0.02), rot=round(math.degrees(math.atan(1.2838)), 2))

    # ============================================================ 1.1 La Galería (and the gallery wall of 1.1b)
    # The gallery's back wall, door to mouth: plank lining in bays, painted as long bands. Over
    # the pit it has burst outward (painted: a black burst, no recess), and high by the door the
    # ore chute's dark hole is painted on it. Two openings are real: the miners' waiting room
    # and the winch's cut (1.1b).
    A.deco("mine_lining_gallery", -164.0, GAL_Y, z=-1.65, size=(24.0, 5.32, 1.59), tone="back")  # (quality run E5, 8.5 PASS: the tally marks, the winch's cut and the rack's bay are in it)
    PZ = -1.45  # the back posts and the long timbers, between the lining and the play space
    # (The pegs' posts and straps are mina_gallery_beam_end's own once it lands, C4, 11-19: the brink posts, the three
    # broken upper halves, the straps and the drawn torn ends go then.)
    _beams = _sw.model_bounds("mina_gallery_beam_end") is not None
    if not _beams:
        for x in (-155.4, -165.9):  # (the door's own post is mine_frame's back post, 11-18)
            post(x, GAL_Y, -7.85, PZ)  # full height
        for x in (-156.7, -158.0, -164.6):
            A.deco("mine_post_broken", x, -10.42, z=PZ, scale=0.988, size=(0.3, 2.6, 0.3), tone="back")  # upper halves: each beam hangs from one
    for x in (-159.3, -163.2):
        post(x, -8.7, -7.85, PZ)  # the two stubs left of the four sets that went down
    for k in range(6):
        hbeam(-176.0 + 4.0 * k, -172.0 + 4.0 * k, -7.85, PZ)  # the roof timber, door to mouth
    hbeam(-158.2, -152.0, -10.78, PZ - 0.03)  # the tie timber at the height of the beams you hold
    hbeam(-166.6, -164.4, -10.78, PZ - 0.03)  # (3 cm back: the pegs' straps share the old front plane, z -1.26, 11-19)
    if not _beams:
        for x in (-155.4, -156.7, -158.0, -164.6, -165.9):
            A.deco("mine_iron_strap", x, -10.75, z=-1.28, size=(0.4, 0.3, 0.05), tone="iron")  # where each beam is let into its post
    mushrooms(-152.0, -12.25, -1.25)
    # The slump: a tongue of black mud out of the burst wall, the cart half sunk in it, and the
    # rails' ends bent down over both brinks.
    A.deco("mine_mud_tongue", -160.5, -17.2, z=-2.15, size=(10.0, 4.5, 1.7), tone="slick")
    A.deco("ore_cart_wreck", -161.0, -15.3, z=-2.2, size=(2.48, 1.72, 1.22), tone="back")
    A.deco("mine_rail_bent_end", -156.3, -13.6, z=-1.95, size=(2.0, 0.9, 1.2), tone="iron")  # origin: the middle of its foot
    A.deco("mine_rail_bent_end", -164.85, -13.4, z=-1.95, flip=True, size=(2.0, 0.9, 1.2), tone="iron")
    A.deco("mine_sleeper", -161.0, -16.9, z=-1.4, size=(1.1, 0.2, 0.25), tone="back")  # on the pit's floor, half in the mud
    # The ore chute on its two wall brackets, coming down out of its hole to fill the carts.
    A.deco("mine_ore_chute", -153.75, -9.75, z=-1.5, rot=33.0, size=(2.5, 0.45, 0.22), tone="back")
    A.deco("sign_pug_skull", -153.6, GAL_Y, z=-1.32, size=(0.95, 2.16, 0.13), tone="bone")  # the first skull-pug you meet
    # One lantern over each brink, on an iron strap hung from the roof timber (the west one is
    # also the camp's lit lantern, 1.1b).
    for x in (-154.0, -166.3):
        A.deco("mine_lantern_bracket", x, -7.85, z=-1.42, rot=-90.0, size=(0.48, 0.15, 0.06), tone="iron")
        hang(x - 0.03, -8.27, -1.42)
    # Drawn on the course's faces: each beam's torn end (end-on), each sunk post's cut tongue
    # and its mud up to a tide line.
    if not _beams:
        for x in (-155.4, -156.7, -158.0, -164.6, -165.9):
            drawn("mine_end_splintered", x, -10.78, (0.36, 0.36, 0.02), tone="wood")
    for x, yb, yt in ((-158.9, -16.6, -12.0), (-160.3, -17.3, -12.2), (-161.9, -17.3, -12.0), (-163.5, -16.0, -12.2)):
        drawn("mine_post_tongue", x, yt - 0.15, (0.45, 0.15, 0.02), tone="wood")
        drawn("mine_mud_tideline", x, yb, (0.45, 1.5, 0.02), tone="slick")
    # Foreground: the low lip of mud-caked rubble, in two heaps under the floor, with a bent rail.
    A.deco("mine_rubble_lip", -164.5, -16.6, z=LIP_Z, scale=0.42, size=(10.0, 1.0, 0.7), tone="back2")
    A.deco("mine_rubble_lip", -151.85, -16.5, z=LIP_Z, scale=1.07, size=(10.0, 1.0, 0.7), tone="back2")
    A.deco("mine_rail_bent_end", -150.0, -15.75, z=1.9, size=(2.0, 0.9, 1.2), tone="iron")

    # ============================================================ 1.1b The frozen climber's camp
    # (The lining, the roof timber, the post at x -165.9 and the lit lantern are 1.1's, above.)
    for x in (-167.75, -170.3, -173.6):  # (the mouth's own post is mine_frame_mouth's back post, 11-18)
        post(x, GAL_Y, -7.85, PZ)
    mushrooms(-170.3, -12.0, -1.3)
    # The miners' waiting room cut in the back wall: its plank bench and its peg rail are part
    # of it. His bedroll on the bench; one miner's lamp left on a peg, cold.
    A.deco("mine_waiting_room", -169.025, GAL_Y, z=-2.25, size=(2.15, 2.1, 1.2), tone="back2")
    A.deco("camp_bedroll", -169.15, -12.1, z=-2.1, size=(1.6, 0.25, 0.6), tone="wood2")
    hang(-169.5, -10.85, -2.5, lit=False)
    # His things against the wall beside him, back off the floor you walk on.
    A.deco("cold_lantern", -166.2, GAL_Y, z=-1.39, size=(0.28, 0.48, 0.28), tone="iron")
    A.deco("rope_coil", -166.65, GAL_Y, z=-1.42, scale=0.6, size=(0.5, 0.2, 0.5), tone="wood2")
    A.deco("pickaxe", -167.45, GAL_Y, z=-1.36, rot=68.0, size=(0.9, 0.6, 0.2), tone="iron")  # leaning on the post
    # The miners' bunting, shortened to 3.5 m so no line crosses behind the ladder's rungs.
    # Fixed at both ends (origin: its west hook).
    A.deco("mine_bunting_torn", -175.8, -8.1, z=-1.45, size=(3.5, 0.8, 0.1), tone="accent")
    # The winch at the head of the incline, in its own cut by the mouth (also 1.0b's).
    A.deco("mine_hand_winch", -172.6, GAL_Y, z=-2.05, size=(1.6, 1.4, 0.8), tone="back")  # (in its own cut in the lining, quality run E5)
    # (quality run, E10, reviewer in the game: the camp's tool rack stands in the open left bay against the
    # lining, in place of the hand winch, where it can be seen; the winch goes with the lining's remake, E5.)
    A.deco("mina_tool_rack", -174.8, GAL_Y, z=-2.05, size=(1.80, 1.87, 0.49), tone="back")
    # Painted on the floor you walk on: the worn track from where he sits to the ladder's foot.
    A.deco("mine_worn_path", -169.2, GAL_Y, z=0.0, size=(3.4, 0.01, 0.35), tone="rock")
    A.deco("mine_rubble_lip", -170.85, -15.3, z=LIP_Z, size=(10.0, 1.0, 0.7), tone="back2")

    # ============================================================ 1.2 Escalera Rota
    # The shaft's back wall: plank lining on a frame every 1.3 m (the frames real, the planks
    # painted), black with wet and green at the seams, two bays painted as the rock behind.
    A.deco("mine_lining_escalera", -170.0, -7.6, z=-2.55, size=(4.0, 13.4, 0.3), tone="back")
    # Three rotted landings behind the three gaps (origin: the middle of its width, at the
    # deck's top; the west half hangs 0.62 under it), each with the bent rung it tore out.
    for y in (-8.6, -4.66, -0.45):
        A.deco("mine_landing_rotted", -169.25, y, z=-1.85, size=(2.5, 0.76, 1.1), tone="back")
        A.deco("fit_ladder_rung_bent", -168.8, y, z=-1.6, rot=-30.0, size=(0.9, 0.5, 0.45), tone="iron")
    stand(-169.0, -0.45, -1.6)  # on the top landing, so the longest gap is the best lit
    # The frame round the head of the shaft, and what stands on the ledge.
    post(-172.2, WALK_Y, 8.4, -1.5)
    post(-167.8, 5.95, 8.4, -1.5)
    hbeam(-172.5, -167.5, 8.4, -1.5)
    # (The pickaxe that leaned on the west post is out: its bright orange head read as a pickup by the sign, and a
    # deco's tone does not colour a landed model: the reviewer's q41, 11-19.)
    A.deco("sign_pug_arrow_west", -173.9, WALK_Y, z=-1.35, size=(1.24, 1.66, 0.16), tone="bone")  # along the catwalk
    # (The rails' torn ends at the gaps are mina_iron_ladder_1_2's own now: MINE_PASS row 142, 11-18.)
    # In the west wall's face beside the two upper gaps: the landings' empty sockets.
    for y in (-4.66, -0.45):
        drawn("mine_socket_empty", -172.17, y - 0.45, (0.3, 0.3, 0.02), tone="back3")
    # (The shaft's two front posts, each in three broken lengths, are out: the broken posts' honey, close to the camera,
    # read as sharpened honey stakes at 1.1 and a bright broken post at 1.2 (the reviewer's q41, 11-19); a deco's tone
    # does not colour a landed model, so they wait on the broken post family in the one scenery timber.)

    # ============================================================ 1.3 Los Tablones
    # (The wall is mine_cavern_wall_mid, E2: the portal's ragged cut, the stope at 1.4 with its
    # gallery and cart, the old working under 1.3, the walk's sockets (empty ones with pale
    # scars), the fallen lower walk's sockets and its surviving length, the outcrops grown out
    # of the face, the boarded hole and stull up high, the wet streaks under the walk.)
    # (The ferns on its three outcrops are out: in the black, fern on outcrop read as a planter hung on the wall, the
    # reviewer's q41, 11-19. The outcrops are the wall model's own.)
    # The bearers: a square timber out of a socket in the wall under each end of each nailed
    # length, with its strut under it (origin: the middle of the bearer's top; it runs from
    # the wall to the walk's back edge).
    for x, top in ((-177.95, 6.0), (-181.35, 5.9), (-179.85, 5.9), (-186.05, 5.8), (-184.55, 5.8),
                   (-189.85, 5.95), (-187.95, 5.95), (-192.55, 6.0), (-190.45, 6.0)):
        A.deco("mine_walk_bearer", x, round(top - 0.22, 2), z=-2.075, size=(0.4, 1.3, 1.65), tone="back")
    # THE DRIFT PORTAL (quality run, E7: reviewer 8.5 PASS, 11-14): the side drift the walk was built to reach,
    # timbered, boarded, its gangway on the walk's own bearers (x -186.05 and -184.55), a cart left on its rail stub.
    # In place of the old boarded tunnel and gangway stub. Origin: the middle of its foot.
    A.deco("mina_drift_portal", -185.3, 5.65, z=-2.35, size=(4.09, 3.93, 2.10), tone="back")
    # (The lower walk that fell, 6 m down, its sockets and surviving length: in E2.)
    mushrooms(-189.6, 0.216, -2.2)  # on its surviving length
    # Two lanterns on iron brackets in the wall, 3 m over the planks.
    wall_lantern(-174.6, 9.47, CAVE_WALL_Z)
    hang(-183.85, 8.70, -2.30)  # (on the drift portal's own bracket, quality run E7)
    A.deco("papel_tatters", -184.5, 10.6, z=-2.85, size=(8.0, 1.0, 0.05), tone="accent")  # nailed along the wall
    # Drawn on the five nailed lengths' front faces: two rows of nail heads each. (The four
    # grey boards show none; their crack and lost corner are the game's breakable look.)
    for x0, x1, top in ((-178.2, -176.0, 6.0), (-181.6, -179.6, 5.9), (-186.3, -184.3, 5.8), (-190.1, -187.7, 5.95), (-192.8, -190.2, 6.0)):
        for x in (x0 + 0.3, x1 - 0.3):
            drawn("mine_nail_row", round(x, 2), round(top - 0.15, 2), (0.08, 0.08, 0.01))

    # ============================================================ 1.4 La Cuerda del Minero
    # (Across the gap at the walk's height, the sockets, the three snapped bearers and the stump: in E2.)
    # The arm's back half: its twin straight behind it, the slanting brace that carries the
    # pair from the pillar, and the cross timber that ties them to the rock (also 1.5's).
    timber((-200.4, 14.0), (-191.5, 14.0), -1.6)
    timber((-201.9, 9.3), (-197.6, 13.8), -1.6)
    timber((-201.9, 13.625), (-200.2, 13.625), -1.6)
    wall_lantern(-200.3, 9.67, CAVE_WALL_Z)  # over the pillar's shoulder
    stand(-196.5, 14.2, -1.6)  # standing on the arm's twin (also 1.5's)
    A.deco("sign_pug_skull", -191.4, WALK_Y, z=-1.35, size=(0.95, 2.16, 0.13), tone="bone")  # where the walk stops
    # Drawn: the rod's eye at its foot and the strap round the arm; the walk's last plank's
    # splintered end.
    drawn("mine_iron_eye", -194.1, 11.25, (0.3, 0.3, 0.02))
    drawn("mine_iron_strap", -194.1, 13.7, (0.4, 0.3, 0.05), scale=1.0)
    drawn("mine_side_splintered", -192.95, 5.78, (0.3, 0.36, 0.02), tone="wood", scale=0.611)

    # ============================================================ 1.5 El Cubo
    # The pulley set back against the hoistway, grey.
    A.deco("pulley", -188.95, 31.4, z=-2.2, size=(0.8, 0.8, 0.2), tone="back")
    # THE HEADFRAME (quality run, E6: reviewer 8.5 PASS, 11-14): the lift's gallows, guide rails and back-stay to
    # El Diente in one piece, in place of a1.py's two hoistway cards. Origin: its main post's foot on the deck.
    A.deco("mina_hoist_headframe", -193.0, 26.2, z=-2.05, size=(16.27, 24.92, 1.23), tone="back")
    # The miners' tool rack (quality run, E10: 8.5 PASS) on the shoulder landing; origin: its back face's foot.
    A.deco("mina_tool_rack", -198.8, 6.0, z=-1.9, size=(1.80, 1.87, 0.49), tone="back")  # (east end: beside 1.5's start, not behind the climber)
    # The station's back half: the deck carried on to the wall on two bearers, the brace from
    # the pillar, three ore crates and a spare bucket on its side.
    A.deco("mine_deck_back", -195.85, DECK_Y - 0.3, z=-2.075, size=(7.9, 0.3, 1.65), tone="back")
    for x in (-198.8, -193.0):
        A.deco("mine_walk_bearer", x, DECK_Y - 0.3, z=-2.075, size=(0.4, 1.3, 1.65), tone="back")
    timber((-201.9, 21.9), (-197.9, 25.9), -1.6)
    for x, y in ((-197.3, DECK_Y), (-196.4, DECK_Y), (-196.85, DECK_Y + 0.73)):
        A.deco("crate_ore", x, y, z=-2.0, scale=0.667, size=(1.2, 1.1, 1.2), tone="back")
    A.deco("mine_bucket_side", -194.6, DECK_Y, z=-2.0, size=(1.0, 0.9, 0.9), tone="back")
    stand(-196.85, DECK_Y + 1.46, -2.0)  # on the top crate
    drawn("mine_trimmer_end", -199.7, DECK_Y - 0.3, (0.25, 0.3, 0.02), tone="wood")  # the hatch's finished edge
    # (Foreground: the lift frame's four broken front lengths are out (the reviewer, q8, 11-17:
    # jagged at both ends, they floated in the air); MINE_PASS group 7 places the foreground
    # against the finished sets, each length standing on something.)

    # ============================================================ 1.6 Vetas de Lodo
    # (The seams, the two old workings as real stopes with their six short props, the moss
    # ledge, the boarded drift at 1.5's foot and the nicho are all in mine_cavern_wall_high (E3);
    # the seams across the pillar and the black mud between the ribs are painted on mine_el_diente.)
    # Waiting for their models (group 6): the powder box at (-195.3, 32.98), z -3.85, and the
    # barrow at (-196.05, 38.02), z -4.0, each tilted 10.1 deg to the stopes' rising floors.
    wall_lantern(-194.4, 35.0, CAVE_WALL_Z)  # in the lower working, on the iron seat of its middle prop
    # The ribs you climb, each a bed of the pillar in the pale hold colour with square ends
    # (skins of the rib solids; the two wide ones carry a row of old drill holes).
    for top, proud in ((27.0, 0.6), (28.6, 0.9), (30.2, 0.6), (32.15, 1.2), (33.75, 0.6), (35.35, 0.9), (37.3, 1.2), (38.8, 0.6)):
        stem = {0.6: "mine_rib_short", 0.9: "mine_rib", 1.2: "mine_rib_wide"}[proud]
        A.deco(stem, round(XF + (proud - 0.3) / 2, 3), round(top - 0.42, 2), z=0.0, size=(proud + 0.3, 0.42, 0.9), tone="rock", skin=True)  # (0.9 m deep, as the solids: quality run 11-18)

    # ============================================================ 1.7 El Carrito Loco (note 103)
    # The chain rib (quality run, E4): one piece from the bench under the incline to the roof,
    # the rib's beds, the overhang, the ore vein under the rings, the drilled bosses round the
    # pins, the wall stepping back behind, the stope behind Las Vigas, the heading at 1.8, the
    # lantern niche by the chain, the fallen-in mouth behind the siding, the lit drift, the fern
    # ledge, the wet west end and the bench with flat pads for the bents. Origin on the rib's face.
    A.deco("mine_chain_rib", -221.0, 21.5, z=RIB_Z, size=(24.4, 35.0, 4.59), tone="back")
    hang(-229.2, 28.48, -4.5)  # the drift's lantern, on its hook
    # The incline's timber on the bench: three bents, each a post at the back whose cap comes
    # forward under the rails to the play space's edge (origin: the post's foot, the middle of
    # the bent's depth), a tie and a brace between the first two, and the landing's two stumps.
    A.deco("mine_incline_bent_tall", -216.7, 25.88, z=-2.025, size=(0.35, 7.8, 1.55), tone="back")
    A.deco("mine_incline_bent_low", -220.5, 25.68, z=-2.025, size=(0.35, 1.9, 1.55), tone="back")
    A.deco("mine_incline_bent", -222.7, 25.88, z=-2.025, size=(0.35, 2.95, 1.55), tone="back")
    hbeam(-220.5, -216.7, 26.9, -2.6)
    timber((-220.4, 27.2), (-216.8, 31.8), -2.6)
    for x, y0, y1 in ((-225.6, 25.9, 27.3), (-227.4, 25.5, 26.7)):
        A.deco("mine_post_broken_short", x, y0, z=-2.6, scale=round((y1 - y0) / 1.6, 3), size=(0.3, 1.6, 0.3), tone="back")
    # (The three slanting struts from the pillar's west face are out: from 1.7's angled camera
    # they read as long pale rods across El Diente (the reviewer, q9, 11-17). The road's own
    # trestle under mine_cart_road carries it.)
    # The beam under the roof (Las Vigas's back beam, whole, 18.5 m, with the three iron
    # rollers the haul chain ran over) and its four hanger posts, one behind each piece (also 1.8's).
    A.deco("mine_beam_roof", -222.75, 54.25, z=-1.7, size=(18.5, 0.35, 0.35), tone="back")
    for x, top in _HANGERS:
        post(x, top, ROOF_Y, -1.45)
    # A second cart, tipped against the wall behind the siding, and the back rail, whole.
    A.deco("ore_cart_wreck", -204.2, TRACK_Y + 0.88, z=-2.4, size=(2.48, 1.72, 1.22), tone="back")
    for k in range(4):
        A.deco("mine_rail_single", -208.025 + 1.75 * k, TRACK_Y, z=-1.45, scale=0.875, size=(2.0, 0.15, 0.15), tone="iron")
    # Four lanterns: two on thin lamp posts at the back of the track, one under the cap at the
    # lip, one on a bracket on the rib so the chain is lit.
    for x in (-203.8, -210.8):
        A.deco("mine_lamp_post", x - 0.35, TRACK_Y - 0.03, z=-1.45, size=(0.55, 3.5, 0.2), tone="back")  # foot sunk 3 cm into El Diente's top (sweeps)
        hang(x, TRACK_Y + 3.45, -1.45)
    hang(-222.7, 28.8, -1.6)
    wall_lantern(-228.6, 47.17, RIB_Z)
    A.deco("sign_pug_skull", -202.6, TRACK_Y, z=-1.4, size=(0.95, 2.16, 0.13), tone="bone")  # moved back 0.4, before the cart
    # The cart's new road: rails on two stringers with sleepers, made to its curve, from the
    # stub's end over the crest, down the drop, round the dip and up to the lip, with the
    # snapped boards and bent rail ends of its broken stop at the lip (a skin of the road solid).
    A.deco("mine_cart_road", -218.1, 27.6, z=0.0, size=(10.1, 12.4, 1.3), tone="wood", skin=True)
    # (Foreground: the front strut's two floating lengths are out, as at 1.5; group 7.)

    # ============================================================ 1.8 Las Vigas (note 103)
    # (The chain rib, the back beam and the hanger posts are 1.7's, above.)
    side_lantern(-215.925, 53.5, -1.45)  # on the first piece's hanger
    side_lantern(-226.125, 53.9, -1.45)  # on the third piece's hanger
    # The roof's stalactites, east of the first beam only (nothing hangs in the air you fling through).
    A.deco("stalactite_a", -212.0, ROOF_Y, z=-1.7, size=(0.8, 3.0, 0.8), tone="back")
    A.deco("stalactite_a", -210.8, ROOF_Y, z=-1.7, scale=0.533, size=(0.8, 3.0, 0.8), tone="back")
    # Drawn on the beams' front faces: a splintered end at every end that faces a gap; a
    # stirrup where each hanger takes its piece (rust on the dry first, black on the three wet);
    # on the roof's face over each hanger, its bolt plate. (The black undersides are the slick
    # strips of FOR THE AREA FILE item 7: the game draws them.)
    for x, top, east in ((-218.3, 50.5, False), (-220.8, 52.0, True), (-222.8, 52.0, False),
                         (-225.3, 50.8, True), (-227.3, 50.8, False), (-229.8, 52.3, True)):
        drawn("mine_side_splintered", round(x - 0.15 if east else x + 0.15, 2), top - 0.4, (0.3, 0.36, 0.02), tone="wood", scale=1.111)
    for i, (x, top) in enumerate(_HANGERS):
        drawn("mine_stirrup" if i == 0 else "mine_stirrup_wet", x, round(top - 0.45, 2), (0.5, 0.5, 0.03))
        drawn("mine_bolt_plate", x, ROOF_Y, (0.7, 0.18, 0.02))

    # ============================================================ 1.9 La Polea Grande
    # The water wheel on the same axle, 1.5 m behind the wheel you ride, running with water
    # (the kit's water wheel at 5 m: FOR THE AREA FILE item 9, to make it turn).
    A.deco("water_wheel", -234.2, 57.4, z=-2.1, scale=0.625, size=(8.0, 8.0, 1.6), tone="back")  # origin: the hub
    A.deco("mina_tool_rack", -227.4, 57.4, z=-2.0, size=(1.80, 1.87, 0.49), tone="back")  # (quality run, E10) the upper gallery
    # The trough from the edge of the fall to just past the water wheel's top (cut from the ore chute).
    A.deco("mine_water_trough", -236.1, 61.23, z=-2.0, rot=-8.0, size=(5.0, 0.5, 0.5), tone="back")
    # The frame: a bearer out of the rock under the axle on its slanting strut, the staging
    # hung under it on two posts (the porch is the bearers' near end); and the roof's two posts.
    hbeam(-237.8, -230.0, 56.95, -1.5)
    timber((-230.0, 54.3), (-233.7, 56.95), -1.56)  # 6 cm behind the post it crosses (sweeps: z-fight)
    for x in (-236.9, -232.5):
        post(x, 52.45, 56.95, -1.5)
    # (the roof's posts to the plank roof's underside, 0.15 under its top (MINE_PASS C7b, 11-18: they stood under the
    # old 0.55 slab), at z -1.45, their fronts 6 cm clear of the throat's wall face at THROAT_Z: sweeps)
    post(-236.9, 57.3, 62.75, -1.45)
    post(-233.0, 57.3, 65.70, -1.45)
    # The upper gallery's mouth: its timber set keeps its back post and its cap (the front
    # post's two outer lengths are foreground, below). The lantern on its back post.
    A.deco("mine_frame_open", -230.0, UPPER_Y, z=0.0, size=(0.72, 4.965, 3.46), tone="back")  # (remade, reviewer 8.5, 11-18)
    side_lantern(-229.7, 60.85, -1.425)
    # The ore crate that stood like a step on the gallery floor, back against the wall.
    A.deco("crate_ore", -230.9, UPPER_Y, z=-1.9, scale=0.917, size=(1.2, 1.1, 1.2), tone="back")  # (west of the post: the tool rack shows)
    # Drawn on the staging's face: two rows of nail heads where the hanging posts take it.
    for x in (-236.9, -232.5):
        drawn("mine_nail_row", x, 52.3, (0.08, 0.08, 0.01))
    # (Foreground: the mouth's broken front post lengths are out (the reviewer, q32, 11-18: broken at both ends, they
    # floated as loose sticks beside the balcony and the staples). MINE_PASS group 7 places the foreground against the
    # finished sets, each length standing on something.)

    # ============================================================ 1.10 El Derrumbe
    # The chimney the rocks fall out of: torn planking and snapped roof timbers hanging round
    # its mouth (origin: the middle under its lowest timber), black inside.
    A.deco("mine_chimney_mouth", -220.3, 75.0, z=-1.9, size=(3.6, 2.0, 1.3), tone="back")
    A.deco("mine_dark_hole", -220.3, 77.0, z=-2.5, size=(2.0, 4.2, 0.1), tone="back3")
    A.deco("mine_hoist_wheel_bent", -219.35, 76.0, z=-2.0, size=(1.4, 1.4, 0.3), tone="back")  # origin: the hub; knocked crooked, no cable
    # The shaft's back wall: plank lining with a frame every 1.3 m, two bays gone to rock, and
    # two pale scars down its middle where the rocks scrape.
    A.deco("mine_lining_derrumbe", -220.3, 61.7, z=-2.55, size=(3.6, 15.3, 0.3), tone="back")
    # The ladder way: a half landing behind every stub, and the short ladders between.
    for side, top in (("E", 63.0), ("E", 64.3), ("W", 65.2), ("W", 66.5), ("W", 67.8), ("E", 68.7), ("E", 70.0), ("W", 70.9)):
        A.deco("mine_half_landing", -219.3 if side == "E" else -221.3, round(top - 0.34, 2), z=-1.85,
               flip=side == "W", size=(1.6, 0.14, 1.0), tone="back")
    A.deco("mine_ladder", -219.0, 62.2, z=-2.1, scale=0.9, size=(0.5, 2.0, 0.08), tone="back")
    A.deco("mine_ladder", -221.6, 65.1, z=-2.1, scale=1.2, size=(0.5, 2.0, 0.08), tone="back")
    A.deco("mine_ladder_snapped", -219.0, 68.5, z=-2.1, scale=0.8, size=(0.5, 1.0, 0.08), tone="back")
    A.deco("mine_ladder_snapped", -221.6, 70.8, z=-2.1, scale=1.1, size=(0.5, 1.0, 0.08), tone="back")
    stand(-221.75, 67.6, -1.75)  # left on a landing: it lights the back wall, so a falling rock shows dark
    # The foot of the fall: the big rubble heap carried on back behind the slope, the hoist's
    # crushed bucket and its cable in a heap half buried in it.
    if _sw.model_bounds("mina_derrumbe_foot") is None:  # (both are mina_derrumbe_foot's own once it lands, 11-19)
        A.deco("mine_rubble_heap_big", -222.5, UPPER_Y, z=-2.45, size=(5.0, 2.5, 2.4), tone="back")
        A.deco("mine_bucket_crushed", -222.9, 57.9, z=-2.0, size=(1.0, 0.7, 1.0), tone="back")
    A.deco("rope_coil", -224.6, UPPER_Y, z=-1.6, scale=1.2, size=(0.5, 0.2, 0.5), tone="iron")
    # The lower level's back wall (also La Polea Grande's upper gallery): timber frames along
    # the gallery and a side tunnel boarded shut, on the upper works' face.
    for x in (-229.0, -226.9, -224.4):
        post(x, UPPER_Y, 61.7, -1.6)
    hbeam(-230.0, -222.1, 61.55, -1.6)
    A.deco("mine_boarded_tunnel", -225.7, UPPER_Y, z=-2.3, size=(1.8, 2.9, 0.4), tone="back")
    mushrooms(-224.4, 58.0, -1.47)
    A.deco("sign_pug_skull", -223.45, UPPER_Y, z=-1.4, size=(0.95, 2.16, 0.13), tone="bone")  # falling rock
    # The upper level (also La Cortina's top drift): its frames, and the hand winch that worked
    # the hoist, at the shaft's edge with its handle in the air.
    for x in (-229.0, -226.6):
        post(x, DRIFT_Y, 75.8, -1.6)
    hbeam(-230.0, -222.1, 75.65, -1.6)
    A.deco("mine_hand_winch", -223.5, DRIFT_Y, z=-2.0, size=(1.6, 1.4, 0.8), tone="back")
    # Drawn on the rock's face: each stub's square sawn end beside it, and three more up the
    # east wall; each stub's splintered tip; an empty socket in both walls at each lunge. (The
    # ore seam and the drill holes on the rock between the levels are painted on
    # mine_upper_works_mass.) The stubs themselves wear their own skin.
    stubs = (("E", 63.0, 0.75), ("E", 64.3, 0.75), ("W", 65.2, 0.75), ("W", 66.5, 0.6), ("W", 67.8, 0.75),
             ("E", 68.7, 0.75), ("E", 70.0, 0.6), ("W", 70.9, 0.75))
    for side, top, length in stubs:
        A.deco("sawn_end", -222.7 if side == "W" else -217.95, top - 0.15, z=FACE, scale=1.25, size=(0.2, 0.2, 0.05), tone="wood")
        tip = -218.5 - length if side == "E" else -222.1 + length
        drawn("mine_side_splintered", round(tip + 0.1 if side == "E" else tip - 0.1, 2), top - 0.3, (0.3, 0.36, 0.02), tone="wood",
              scale=0.833)
        A.deco("mine_stub" if length == 0.75 else "mine_stub_short", round((-218.3 + tip) / 2 if side == "E" else (-222.3 + tip) / 2, 3),
               top - 0.3, z=0.0, flip=side == "W", size=(length + 0.2, 0.3, 2.4), tone="wood", skin=True)
    for y in (72.2, 73.5, 74.8):
        A.deco("sawn_end", -217.95, y - 0.15, z=FACE, scale=1.25, size=(0.2, 0.2, 0.05), tone="wood")
    for y in (65.05, 68.55, 70.75):
        drawn("mine_socket_empty", -222.4, y - 0.15, (0.3, 0.3, 0.02), tone="back3")
        drawn("mine_socket_empty", -218.2, y - 0.15, (0.3, 0.3, 0.02), tone="back3")
    # Foreground: the shaft's two front posts in broken lengths, in front of the rock either
    # side, never in front of the shaft; and the low lip of rubble along the frame's foot.
    # (The west one's broken lengths are out, q32, as the mouth's above: group 7 re-places it.)
    for y0, y1 in ((61.9, 63.4), (65.0, 68.0), (70.6, 74.2), (75.2, 77.0)):
        front_post(-218.33, y0, y1)
    A.deco("mine_rubble_lip", -226.9, 54.4, z=LIP_Z, size=(10.0, 1.0, 0.7), tone="back2")
    A.deco("mine_rubble_lip", -216.6, 54.4, z=LIP_Z, size=(10.0, 1.0, 0.7), tone="back2")

    # ============================================================ 1.11 La Cortina
    # The throat's back wall (quality run, MINE_PASS row 12, reviewer 8.5, 11-18): the black-wet bedded shaft behind the
    # 28 staples, its face flat at THROAT_Z so every staple's legs meet it, the rust hand-set at each staple's feet, its
    # seeps and sheen kept clear of the staple column, ferns rooted in the cracks of broken bosses; at its top the dry
    # shaft's plank lining on its frames and the mine's last square set, the works' first arch on its cap. (It takes the
    # jobs of mine_lining_dry_shaft, the outcrops, the 28 rust stains and the stand-in set at the shaft's mouth.)
    A.deco("mine_cortina_wall", -239.0, 60.0, z=round(THROAT_Z - 0.03, 3), size=(18.0, 30.21, 2.01), tone="slick")  # (3 cm back: at THROAT_Z its top lining met esclusa_wall_flume's arch foot in one plane at z -1.70, and 1.2 cm back its lower face met the water trough's at -1.81: sweeps)
    # (The drip boards over four of the five dry staples are part of `mine_staple_bound` now: the iron staple family,
    # 11-18.)
    A.deco("sign_pug_arrow", -224.6, DRIFT_Y, z=-1.4, flip=True, size=(0.76, 2.18, 0.15), tone="bone")  # moved back 0.4, in the drift
    # The empty camp against the drift's back wall: a bedroll, a cold lantern and a pickaxe, and nobody.
    A.deco("camp_bedroll", -227.75, DRIFT_Y, z=-2.0, size=(1.6, 0.25, 0.6), tone="wood2")
    A.deco("cold_lantern", -226.2, DRIFT_Y, z=-1.9, size=(0.28, 0.48, 0.28), tone="iron")
    A.deco("pickaxe", -228.7, DRIFT_Y, z=-2.2, rot=80.0, size=(0.9, 0.6, 0.2), tone="iron")
    wall_lantern(-230.5, 79.87, THROAT_Z)  # moved east and back out of the play space: the last amber light
    A.deco("mine_iron_strap", -232.25, 89.25, z=-1.3, size=(0.4, 0.3, 0.05), tone="iron")  # the rope's bracket, strapped to the last set
    # (The east wall's broken front post lengths are out, q32, as at 1.9's mouth: group 7 re-places them.)

    # ============================================================ 1 to 2: the lip
    # (The works' brick wall in bays over the roof, the weir's sill and the river, the works'
    # greenish lantern and the pier are biome 2's: El Borde's page draws the same wall.)
    # The mine's last timber set in the mouth of the dry shaft (the kit's set: origin its
    # middle), and the works' first arch standing straight on its cap, low, in flat courses of
    # colour, with a cast iron pug in its middle: the one object that is the join.
    # (11-18: the kit's honey timber_set, its red sign read as a hold behind the climber at 1.12 (MINE_PASS F-B7 row
    # 105), is the mine's own square set now, in its one scenery timber (the passed stock family): two posts either
    # side of the dry shaft's mouth and a cap with its top at 89.95 (72.95 moved), the works' first arch on it, until
    # mine_cortina_wall carries the set as its top frame.)
    # (The stand-in set is gone: the set is mine_cortina_wall's top frame now, 11-18.)
    # (The works' first arch on its cap is esclusa_wall_flume's now, with its cast pug in the keystone.)
    side_lantern(-235.8, 89.0, round(THROAT_Z - 0.03, 3))  # the mine's last amber, on the set's west post's front (mine_cortina_wall's, 3 cm back with it)
    # (The two faces drawn on the lip ledge's front, the works' coping and five courses of pale brick, are out: the alcove's
    # floor wears esclusa_coping_alcove, MINE_PASS F7, 11-18.)
    # Foreground: one post, timber below and brick above, in front of the pier's rock.
    post(-237.025, 86.2, 89.3, 1.45)  # (0.36 deep: z 1.27 .. 1.63)
    A.deco("works_brick_pier_post", -237.025, 89.3, z=1.45, size=(0.55, 2.0, 0.35), tone="brick")
