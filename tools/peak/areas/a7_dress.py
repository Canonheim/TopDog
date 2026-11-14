"""
LOS RISCOS DEL VIENTO, DRESSED: the scenery of all of biome 7, the wind cliffs on the mountain's east
face (y 570 to 690), from the twelve area pages (the eleven challenges 7.1 to 7.10 with the tea cave
7.0, and the join "7 to 8", the low cableway station) in docs/peak/playtest/design/data/a7_areas.py
and the biome's sheet a7_biome.py (its `built`, `looks`, `layers` and `kit`, and KIT_MORE). The join
"6 to 7" is the chimney's page 6.9 (a6_dress.py places the crack's back wall, the chalk sill, the
basalt fins and the chalk overhang over the opening): this file starts at the door's face, x -230,
with El Balcon, its back wall and the trail post on the lip beside the door. The join "7 to 8" is
this file's to x -227 on the deck: the deck, what carries it, the house, the sock, the pennants and
the haul cable; biome 8 places the gangway, the cars, the wheel over the dock, the booth, the pug
sign and the wind engine.

Parker, 11-13: THE WALLS RULE WAS INVENTED HERE. The worked example is this biome's own tower top
(7.9 and 7.10), the kit's `ex_riscos_tower_top` ("I like the painted look", "just the painted lines
look lovely", "it does not need these random triangles"), placed here as the real piece. Every
other mass is made the same way: chalk in level beds painted as long wavy lines and bands in three or
four browns on a few big slanted planes; no rain streaks; nothing painted tapers to a point; no dark
slot or recess cut into a face; white where it is held (ledge tops, crack lips, knobs, bands: plain
blocks with square ends standing proud); a few big real breaks; a designed outline (up to 0.8 m off
the course's away from holds and tops); and a few small outcrops, each carrying the cliffs' own flat
painted plants (`riscos_grass_tuft`, `riscos_shrub_flat`: dry grass and a dry shrub with silver
dead-wood stubs, straw and grey-olive, NOTHING GREEN; the shapes of `plants()` in the tower top's
design step). Behind every mass you climb, its body 1.5 to 3 m back: grey-tan, cooler and duller,
its beds as thin darker lines carrying on the wall's, an uneven skyline (the tower top's `body`).
Note 89 and 70: wind is drawn loudly (the course's wind zones draw the wavy lines) and every flag,
sock and rag streams; note 76: what is drawn is what can be touched (the bull wheel drawn 7.6 m
across); note 68: both frogs (the tea cave, the vulture's nest).

Scenery only: decos. Nothing here can be stood on or held. The course (the shelf, the tower and its
floors, the face, the slab, the tree and its stubs and branches, the fin, the bridge's stubs and
ropes, the cornice, its knobs and pegs, the arch's two masses, the rails, the pockets, the burros'
ledges, the horn and the snag, the chimney's bands, the planks, the wheel, the brace, the deck and
the plug) is a7.py's. The model list this file makes is docs/peak/models/a7_models.md.

Depth: the play space is z -1.2 .. 1.2. Everything here stands behind -1.25 or in front of 1.25,
except SKINS (skin=True), each the LOOK of course solids (MODELLING_RUN rule 4), filling them,
z -1.2 .. 1.2 (the tower top's reaches back to -3.6: its body is in the same model). From the back:
the mountain's shoulder, four flat painted cards at z -13, west of its stepped edge only (EAST OF THE
CLIFF NOTHING OF OURS STANDS: the painted valley, the two ranges and the cloud banks are given and
already in the game); the station house -5.6 .. -2.4; El Balcon's back wall -5 .. -4.2 (its floor
carried back from -1.25, a buttress forward to -2.7 where the frozen climber sits); the bodies
-3 .. -1.5 (their floors and shelves carried forward to -1.25 where things stand on them: the
alcove, the windows, the balcony, the burros' ledges, the gully's head); the needles' tops
-3.3 .. -1.3; the tea cave's room -3.4 .. -1.25; the scaffold -2.8 .. -1.25 (its decks carried
back), its backboard -2.8 .. -2.6, the drum -2.3 .. -1.7, the haul cable at -2.0; the flags, the
sock, the sign, the anchors and everything on a ledge's back between -1.25 and -2.4. In front:
three chalk lips with a grass tuft at bottom west corners, each in front of solid rock (1.3 .. 2.2);
the trail post beside the door (the only thing on the cliffs you pass behind, for one step); the two
bridge post stumps (0.3 m tall); the tea cave's cut edge (below the floor); three small outcrops on
the west face's front (over rock); the scaffold's front post (7.10) and the post under the deck
(7 to 8), each in front of air nobody climbs through.

A deco's origin is the middle of its base (x and z) at its foot (y), unless its comment says
otherwise: wall-mounted things (the shelf of tins, the pegs, the saddle, the lantern bracket) the
middle of their foot on the wall; things that turn (the drum) their axle; a strut its iron shoe; a
bough its butt; the wind sock its base (its eye 0.45 east, 1.44 up: it streams west unless
flipped). For the long pieces (walls, bodies, floors carried back): the middle of its x span, the
bottom of its box, the middle of its depth. A deco's size is the size its model is MADE at (the game
rescales a landed model more than a quarter off); where one model is used at several sizes, `scale`
does it and the size is the model's own. `rot` is in degrees, counter-clockwise as the camera sees it
(a positive rot tips a thing's top to the west).

Shared pieces are placed once, in the first section that names them: the tower's body (7.1 to 7.9),
the far nest and its frog (7.2, 7.3), the first flag of La Cornisa (7.4, 7.5), the fin's body (7.3,
7.4), the arch's body (7.6, 7.0, 7.7), the rubble pile (7.6, 7.7), the window's nest and flag and the
porch's sock (7.8, 7.9), the scaffold and its legs (7.7, 7.10), the shoulder (every page).

FOR THE AREA FILE (tools/peak/areas/a7.py; the fix thread's). Line numbers are a7.py's as of
2026-11-14 01:21 (the version with the tail wind to x -172.2 and the wheel at model_scale 1.52).
  1. Call it: `import a7_dress` beside the other imports, and `a7_dress.dress(A)` after the course
     is built, after the pit linings (line 413) and before `if __name__ == "__main__":` (line 416),
     so before A.save().
  2. Lights (a7.py has none: the cliffs are in daylight). Add the tea cave's two (note 68, the only
     warm light on the cliffs): `a7_dress.TEA_LIGHTS[0]` the lantern, "#FFB860", range 4, energy
     0.9, flicker; `TEA_LIGHTS[1]` the brazier, "#FF8A40", range 3, energy 0.8, flicker (their light
     falls out of the door onto the pocket's floor, as page 7.0 asks). The join's gold (page 7 to 8,
     "gold light on the house's west wall"): `a7_dress.STATION_LIGHT`, "#FFD08A", range 12, energy
     0.6, no flicker.
  3. Decos to take out (this file places what the pages keep, out of the play space): the seven
     `streamer_pole` decos at z -0.6 (lines 121, 122, 211, 212 and the loop 328-329: the pages move
     every flag back; the porch's flag becomes the wind sock; the one at (-210.6, 590) stood on
     nothing), the two nests (148, 149), the crown (174), and lines 399-408 (the fence frame, the
     scaffold, the pylon head, the station house, the pennant line, the pug arrow, the lantern, the
     rubble pile, the bone pile: each is placed here, moved back as its page asks). KEEP line 58 (the
     dry shrub on the lip: it is the hold's own look, in the play space by design).
  4. Cards to take out: all seven, lines 392-398 (the tower, the arch, the fin's root, the horn's
     stalk, the two needles, the face at z -2.5): the bodies here replace them. Effects: take out
     the clouds (line 390): the sheet, "Never here: ... any cloud of our own" (the given far layers
     carry the cloud banks). KEEP the gully's dust (line 271).
  5. Skins. Each named solid takes `skin=` its stem; this file places every skin deco.
     - El Balcon, lines 52, 53, 54: "riscos_balcon".
     - The tower, cut() (line 29) and its call (96): cut() wants a skin for each piece it writes,
       by the piece's bottom: below 624 "riscos_tower_low" (solid x -210 .. -204, 578 .. 623.8),
       624 .. 656 "riscos_tower_mid" (626.2 .. 639.4 and 641.6 .. 653.8), above 656
       "ex_riscos_tower_top" (the three pieces from 658). Also: the tooth (97) and the east fin's
       peak (98) "ex_riscos_tower_top"; the floors R1 (100) and R4 (101) "riscos_tower_low"; R5's
       three steps (102-104), R7 and its balcony (105) and the corbel (106) "riscos_tower_mid";
       the porch (108), its corbel (109) and R9 (110) "ex_riscos_tower_top"; the crack's three
       lips (the patches, 119) "riscos_tower_low"; the chimney's five bands (342, 344)
       "ex_riscos_tower_top".
     - The face, A.wall (line 75): wall() wants a `skins` like cave()'s: edges 1 and 3
       "riscos_face_slab", edges 4 to 11 "riscos_west_face". The lintel and slab (76)
       "riscos_face_slab"; the mountain behind the skin (78) "riscos_west_face".
     - The tree's three beams (164-166) "riscos_dead_tree".
     - The fin under the keyhole (182) and R3 (183) "riscos_keyhole_fin"; the two stubs of deck
       (184, 185) "riscos_deck_stub" (placed twice, the east one flipped).
     - The cornice (203) "riscos_cornice"; the nose knob (204) "riscos_flint_nose".
     - The gully's west mass (234), the two pockets' floors and steps (262, 263) and the tea cave's
       new floor and jambs (item 6a) "riscos_gully"; the east mass (235) "riscos_counter_slope";
       R6's roof (238) "riscos_gully_roof".
     - The two needle ledges and their supports (298-299): the first pair "riscos_needle_top_a",
       the second "riscos_needle_top_b".
     - The horn (318) and its top (319) "riscos_horn"; the snag's stub (320), knot (321) and
       bough (323) "riscos_snag".
     - The long brace: its foot length (371) "riscos_brace_foot", its head length (373)
       "riscos_brace_head" (the rotten length is item 8's).
     - The plug at the deck's west end (378) "riscos_chalk_plug".
     - The planks (107, 357, 358, 362, 374-375, 377) keep the plank kind's own look; the pits'
       slick linings (411-413) none.
  6. Course changes on the pages, for the fix thread (not scenery):
     a. 7.0 (note 68, not built): the tea cave. Cut the room as air, x -245.4 .. -240.34,
        y 641.37 .. 643.77 (2.4 m tall), out of the gully's west mass (234), the face's slab
        behind it (edge 7 of FACE), R6's block (edge 8: "the course gives the ledge a block of
        holdable rock 8 m deep ... the room is cut through both") and the mountain behind (78);
        a doorway 2.2 m tall through the upper pocket's back wall (x -240.5 .. -240.34, 641.37 ..
        643.57, its jambs dry white chalk); 5 m of new floor, x -245.4 .. -240.34, top 641.37,
        0.2 thick, "rock" (grip), level with the pocket's floor. Only the floor and the doorway are
        new to touch. The frog croaks when you are within a screen of the door (note 60). This
        file places the room's back, its roof's look, the furniture and the cut edge in front.
     b. 7.4 (note 66): what you hold on each hanging half becomes the whole half, 0.3 m wide as
        the camera sees it, where today it is one rope; that brings the two halves 0.3 m nearer
        each other. The board on each end stays the same 1.2 m board. The swing is judged again
        once ropes swing properly (note 20).
     c. 7.7 (note 76): the kit's burro is 1.8 m long and its solid 1.3 m: make them agree, either
        way. If the head and neck become solid that is 0.5 m more burro on its west side. The
        burros face WEST (mover model_flip=True: the kit's faces +x).
     d. 7.10 (note 76): when the re-made `bull_wheel` (7.6 m across) lands, drop model_scale=1.52
        from the wheel (line 361).
     e. 7.1: the frozen climber sitting (page 7.1, "The one who stopped to look"): the climber's
        own model in the "sit" pose, his back against the back wall's buttress, knees up, facing
        the valley and the town: pelvis about (-223.3, 578.3), z -2.1, facing +x (nothing bespoke
        is modelled for him until the new climber model lands: MODELLING_RUN). A.statue() is solid
        at the play plane; he stands 1.6 m behind the walk, so he wants a scenery statue (a z, not
        solid). Until then leave him out; nothing here stands in for him.
     f. 7.2: the frog in the far nest croaks when you land on the nest ledge (note 60).
  7. Found while dressing, not on a page:
     a. `ex_riscos_tower_top` was made from y 656, but the upper window R7 (line 91: 653.8 .. 658)
        is open to 658: its fin and east wall stand 2 m down into the window's air (x -210.7 ..
        -208.2 and -206 .. -203.3). As the game piece its walls start at the window's roof (658);
        its body behind may stay down to 656. That is its one cut (a7_models.md, section 1).
     b. st.json (the shared structure) places ten white clouds over the cliffs (cloud_a .. cloud_e,
        y 563 to 691, z -29 to -72, e.g. cloud_d at (-223.2, 652.5, -29.2), right behind the
        burros): clouds of our own, which the sheet says never. Whoever owns st.json takes them out,
        or rules that they are the given far view's.
     c. a6.py's back card (line 282, z -6, x -297 .. -228, up to 592) reaches out past the door, so
        from El Balcon it stands in front of the shoulder and the sky west of x -228 (a6_dress.py
        may take it out: check). El Balcon's back wall here starts at the face (x -230) so a6's
        sky cards behind the door (z -5) stay seen.
     d. The kit's `rock_fence_frame` (placed as page 7.6 asks) has nine posts, wire mesh and two
        rails of its own; the page draws four leaning posts and torn rope netting. If its rails read
        as holds beside the course's three, it is re-made (a7_models.md, section 4).
     e. The kit's `scaffold_frame` has crossed iron in most bays and five legs; page 7.10 wants four
        posts and NO brace behind the wheel or the long brace: it is replaced by `riscos_scaffold`.
     f. The pylon head stands on the west fin's body (page 7.10) at z -2.2 .. -1.3: its east end
        meets the tower top's body (about z -2.0 to -2.4 there); the makers fit the two.
     g. The scaffold's four legs (STRUTS) answer the ask on page 7.7 ("May its four legs come down
        behind this challenge ...? Yes, or keep the sky here clear"): if Parker says keep the sky
        clear, take the four `riscos_scaffold_strut` decos out and hang the scaffold off the face.
  8. Movers', ropes' and holds' looks (the area file's; models in a7_models.md section 4, or a kit
     model to be re-made):
     - holds: the cornice's first knob (205) and six roof knobs (207), the two lips' noses (264)
       and the nine tread knobs (266) wear `forja_flint_knob` (the chimney's knob, a6's: a flint in
       its white rind, two fists, 0.4 out); the six pegs (209) wear the kit's `iron_peg` (rust
       orange, a square hammered head; its plate on the cornice's front face, a ring of white chalk
       dust round it); the eight stubs on the scar (168) wear `riscos_tree_stub` (a broken branch's
       root, bleached white, a ring of pale splintered wood at its end); the crack's lips and the
       bands are the skins' (item 5).
     - the two breaking branches (169 rotten, 170 brittle): `riscos_branch_break_a` (2.9 m) and
       `riscos_branch_break_b` (2.3 m): real branches of the tree, bleached, tapering, with twigs,
       split along the grain at the join with a strip of bark hanging (note 65); they go in
       splinters and grow back from the join after 8 s.
     - the long brace's rotten length (372): `riscos_brace_rotten` (2.6 m: the red paint gone, grey
       wood split along the grain, a corner missing).
     - the two hanging halves (ropes 187, 188): `riscos_bridge_half` (5.3 m, two side ropes 0.3 m
       apart edge-on with a ladder of honey boards, three gone) as each rope's look, and
       `riscos_bridge_board` (1.2 m, hanging by one end) as each bob's model.
     - the vultures (lines 139-145, 317, model "vulture"): the kit's is perched; re-made flying,
       legs hanging straight down, pale and bare, exactly the held box (0.28 x 0.5 under its
       origin), body and wings dark (page 7.2, note 76).
     - the burros (296, model "burro"): item 6c.
     - the bull wheel (361): `bull_wheel` re-made at 7.6 m across (item 6d): red rim, six cream
       spokes, the pug on the hub, origin the hub.
     - things that would move: the drum turns with the wheel:
       `A.follow("riscos_wheel_drum", (-220.2, 675.0), "bullwheel", "spin")` after the dress call.
       The haul cable (it should run), the warning sign (it should swing and creak in the
       crosswind, its ring at 1.2 m out: note 67), the flags and the two socks (the streamer and the
       sock should fill and stream with each gust, and hang between; the station's sock stays full,
       east) and the frayed rope ends stand still until the engine has a follow for them.
  9. Effects (the pages'; a7.py's winds, lines 120, 210, 327, draw the lines): white dust out of
     the door behind you, the back wall's tufts leaning west in the gust (7.1); a vulture's shadow
     across the slab before the bird crosses the ledge, a feather turning in the still air (7.2);
     a branch's creak and dip and a puff of grey dust as it goes (7.3); the frayed ends swaying,
     never streaming (7.4); chalk dust and one dead leaf out and down with each crosswind (7.5); the
     pile shaking and a puff before each wave (7.6); steam from the pot, the brazier's thread of
     smoke up the crack and out on the top tread between two knobs (7.0, 7.7); a burro flicking an
     ear and stamping within 3 m, the kick's puff of dust and straw (7.7); feathers and chalk dust
     carried west in the tail gust (7.8); a thin run of water and a drip from each band (7.9); the
     scaffold's creaks (7.10); the sock and the pennants pointing east without a break, no wavy
     lines (7 to 8).
"""
import math

# ------------------------------------------------------------------ the lines things stand on
BALCON = 578.0          # El Balcon's top (7.1)
R1 = 590.0              # the alcove at the crack's top (7.1, 7.2)
R2 = 600.0              # the nest ledge (7.2, 7.3)
R4 = 624.0              # the keyhole's floor, the window's floor (7.4, 7.5)
R6 = 647.6              # the gully's head, the first burro's ledge (7.6, 7.7)
R7 = 654.0              # the upper window, its balcony, the horn's top (7.7, 7.8)
PORCH = 664.0           # the porch (7.8, 7.9)
CATWALK = 663.0         # the old catwalk (7.10)
DECK = 688.0            # the low station's deck (7 to 8)
CAVE = 641.37           # the tea cave's floor (7.0)

# The faces of the bodies: everything that hangs or stands against a body is set from these.
BODY_FACE = -1.5        # every body's face (the tower, the colony, the arch, the cornice, the horn)
BALCON_WALL = -4.2      # El Balcon's back wall (3 m behind the walk)
CAVE_BACK = -3.4        # the tea cave's back wall
HOUSE_FRONT = -2.44     # the station house's front wall

ROCK = "rock"           # stand-in tones: white chalk you hold
SLICK = "slick"         # dark brown, polished
BODY = "#B9AC90"        # grey-tan rock a step behind
SHOULDER = "#8E9AA6"    # the shoulder: hazed mid blue-grey
WOOD = "wood"
IRON = "iron"
ACCENT = "accent"
STRAW = "#C8B27A"

# Lights for a7.py (FOR THE AREA FILE item 2): x, y.
TEA_LIGHTS = [(-242.9, 643.45), (-241.55, 641.8)]
STATION_LIGHT = (-247.0, 692.0)

# The mountain's shoulder: its east edge at height y (a7_areas.py _SHOULDER_EDGE); the card is cut
# in steps of 4 m about it (+0.5 / -0.4 by turns).
_SHOULDER_EDGE = [(570.0, -222.0), (585.0, -223.0), (600.0, -226.5), (615.0, -229.0), (630.0, -231.5),
                  (645.0, -235.0), (660.0, -238.5), (675.0, -241.0), (690.0, -243.5), (700.0, -245.5)]
SHOULDER_WEST = -280.0  # far enough west that its end never shows past the near rock
SHOULDER_SECTIONS = [(566.0, 600.0), (600.0, 634.0), (634.0, 668.0), (668.0, 702.0)]

# The tree (a7.py TR, TD): a point s m up the trunk, off m to its upper side.
_TR, _TD = (-243.0, 599.8), (0.6, 0.8)
# 7.5: the cornice's pegs (a7.py PEGS).
_PEGS = [(x, 629.7 + 0.839 * (-195.0 - x)) for x in (-196.3, -197.6, -198.9, -200.2, -201.5, -202.8)]
# 7.7 / 7.10: the scaffold's four legs: (post x at the catwalk, foot x, foot y).
STRUTS = [(-237.0, -236.5, 649.2), (-229.2, -226.5, 649.5), (-220.7, -222.2, 650.0), (-213.0, -211.3, 654.0)]


def _sx(y):
    e = _SHOULDER_EDGE
    for (ya, xa), (yb, xb) in zip(e, e[1:]):
        if ya <= y <= yb:
            return xa + (xb - xa) * (y - ya) / (yb - ya)
    return e[0][1] if y < e[0][0] else e[-1][1]


def _tp(s, off=0.0):
    return (_TR[0] + _TD[0] * s - _TD[1] * off, _TR[1] + _TD[1] * s + _TD[0] * off)


def _roof_y(x):
    """The underside of La Cornisa at x (a7.py roof_y)."""
    return 626.2 + 0.1628 * (x + 204.0)


def dress(A):
    # ------------------------------------------------------------ helpers
    def skin(stem, x0, x1, y0, y1, tone=SLICK, flip=False):
        """The look of course solids, filling them (z -1.2 .. 1.2)."""
        A.deco(stem, round((x0 + x1) / 2, 3), y0, z=0.0, size=(round(x1 - x0, 2), round(y1 - y0, 2), 2.4), tone=tone, skin=True, flip=flip)

    def back(stem, x0, x1, y0, y1, z_near, z_far, tone=BODY):
        """A piece behind the play space, from z_near back to z_far (origin: the middle of its foot)."""
        A.deco(stem, round((x0 + x1) / 2, 3), y0, z=round((z_near + z_far) / 2, 3), size=(round(x1 - x0, 2), round(y1 - y0, 2), round(z_near - z_far, 2)), tone=tone)

    def front(stem, x0, x1, y0, y1, z_near, z_far, tone=BODY):
        """A piece in front of the play space (z_near the side toward the play space)."""
        A.deco(stem, round((x0 + x1) / 2, 3), y0, z=round((z_near + z_far) / 2, 3), size=(round(x1 - x0, 2), round(y1 - y0, 2), round(z_far - z_near, 2)), tone=tone)

    def flag(x, y, h, east, z=-1.45):
        """A flag at the back of a ledge: the kit's streamer_pole (made 4 m, its streamer a second
        object flying +x from the top) at h metres. east=False flips it to stream west."""
        A.deco("streamer_pole", x, y, z=z, scale=round(h / 4.0, 3), size=(0.2, 4.0, 0.2), flip=not east, tone=ACCENT)

    def tuft(x, y, z):
        """The cliffs' own dry grass, one flat painted card (made 0.75 x 0.6, 1 cm thick)."""
        A.deco("riscos_grass_tuft", x, y, z=z, size=(0.75, 0.6, 0.01), tone=STRAW)

    def shrub(x, y, z):
        """The cliffs' own dry shrub, one flat painted card (made 1.0 x 0.7, 1 cm thick)."""
        A.deco("riscos_shrub_flat", x, y, z=z, size=(1.0, 0.7, 0.01), tone=STRAW)

    def outcrop(x, y, face, plant="grass"):
        """A small outcrop of chalk standing proud of a face (made 0.9 x 0.45 x 0.3: a dull white
        top, painted beds on its front), and on it one of the cliffs' plants. A face behind the play
        space (a body's, z -1.5) has it standing forward; the west face's front (z 1.2) has it
        standing out in front, over rock."""
        if face < 0:
            zb, zp = round(face + 0.12, 3), round(face + 0.2, 3)
        else:
            zb, zp = round(face + 0.15, 3), round(face + 0.25, 3)
        A.deco("riscos_ledge_block", x, y, z=zb, size=(0.9, 0.45, 0.3), tone=BODY)
        (tuft if plant == "grass" else shrub)(x, round(y + 0.45, 2), zp)

    def nest(x, y, z, w):
        """The kit's vulture_nest (made 1.6 x 0.6 x 1.2) at w metres across."""
        A.deco("vulture_nest", x, y, z=z, scale=round(w / 1.6, 4), size=(1.6, 0.6, 1.2), tone="root")

    def bones(x, y, z):
        A.deco("bone_pile", x, y, z=z, size=(1.0, 0.4, 0.6), tone="bone")

    def board(x, y, z, length, rot=0.0):
        """The kit's plank (made 2.0 x 0.12 x 0.9) as a board `length` long."""
        A.deco("plank", x, y, z=z, rot=rot, scale=round(length / 2.0, 3), size=(2.0, 0.12, 0.9), tone=WOOD)

    def peg_stub(x, y, z=BODY_FACE):
        """The kit's iron_peg_stub, dull rust, snapped off short (origin where it meets the rock)."""
        A.deco("iron_peg_stub", x, y, z=z, size=(0.16, 0.16, 0.12), tone=IRON)

    def hitch_peg(x, y):
        """An iron hitching peg driven into a ledge's back, a frayed end of halter knotted on (made
        0.15 x 0.7 x 0.15)."""
        A.deco("riscos_hitch_peg", x, y, z=-1.7, size=(0.15, 0.7, 0.15), tone=IRON)

    def strut(xp, xf, yf):
        """A scaffold leg: a raking strut 0.3 m square in yellow ochre from the catwalk's post down to
        an iron shoe in the rock (made 13.8 long; origin the shoe, the strut rising +y)."""
        L = math.hypot(xp - xf, CATWALK - yf)
        rot = math.degrees(math.atan2(-(xp - xf), CATWALK - yf))
        if L > 11.0:
            A.deco("riscos_scaffold_strut", xf, yf, z=-2.0, rot=round(rot, 2), scale=round(L / 13.8, 3), size=(0.3, 13.8, 0.3), tone="#C8962E")
        else:
            A.deco("riscos_scaffold_strut_short", xf, yf, z=-2.0, rot=round(rot, 2), scale=round(L / 9.2, 3), size=(0.3, 9.2, 0.3), tone="#C8962E")

    # ============================================================ the far side: the mountain's shoulder
    # One flat cut-out card of the same cliff, 12 m and more back, hazed to a mid blue-grey, its
    # ledges painted, its east edge cut in steps of 4 m that lean back with the face, one small dead
    # tree cut into that edge on each section. WEST OF ITS EDGE ONLY: east of it there is nothing of
    # ours (sky and the far view that is given). Four sections 34 m tall from the Balcon to the
    # station; each runs west to x -280 so its end never shows past the near rock at any camera.
    for k, (y0, y1) in enumerate(SHOULDER_SECTIONS):
        y, east, i = y0, -1e9, 0
        while y < y1 - 0.01:
            yn = min(y + 4.0, y1)
            east = max(east, _sx((y + yn) / 2) + (0.5 if i % 2 else -0.4))
            y, i = yn, i + 1
        back("riscos_shoulder_" + "abcd"[k], SHOULDER_WEST, round(east, 2), y0, y1, -12.75, -13.25, tone=SHOULDER)

    # ============================================================ 7.1 El Balcon
    # The shelf (skin): one hard bed of chalk standing out of the face, dry white on top with the
    # burros' worn way trodden down its middle from under the door to the crack's foot; its front and
    # underside dark brown in wavy beds; slick and dark under the tower (x -210 .. -204).
    skin("riscos_balcon", -232.0, -204.0, 573.0, 578.05, tone=ROCK)
    # The tower's west face (skin), from the shelf to the window's floor: the upright joint opened in
    # three lengths with lips of fresh white chalk, broken and matte, and the two hard beds between
    # shut tight, dark brown and rain-polished; the alcove R1 cut in it (its floor white, the
    # vultures' whitewash on 1.1 m of its lip, x -210 .. -208.9); the east face one clean slick drop.
    skin("riscos_tower_low", -210.15, -204.0, BALCON, R4)
    # The shelf's back (also behind the walk all the way east): the floor carried back 3 m to a back
    # wall of grey-tan cliff, tall by the door and coming down in steps of one bed each to a low kerb
    # (tops 590, 586.3, 583.0, 581.4, 579.3: the same two hard beds that close the crack); a buttress
    # forward to z -2.7 at x -224.6 .. -222.0, where the frozen climber sits (item 6e). It starts at
    # the face (x -230): west of that is the chimney's (item 7c).
    back("riscos_balcon_back", -230.0, -211.6, 573.0, 595.5, -1.25, -5.0)
    # The tower's body (also 7.2 to 7.8): the near tower is the near edge of a bigger tower of
    # grey-tan chalk 1.5 m behind it, a metre proud on both sides. The two hard beds run round it as
    # darker bands that stand out as small ledges (581.4 .. 583, 584.6 .. 586.3), a nest's white
    # streak under the upper one, a long white streak down from the alcove; the alcove R1 carried back
    # to z -2.6 (floor and roof: where the near nest and the larder sit), the window R4 carried back
    # to -2.2 (the spare boards and the saddle against it), the upper window R7 carried back to -2.2
    # and its west balcony carried back to -3 under the standing hoist (7.7). Its top (656) meets the
    # tower top's body exactly.
    back("riscos_tower_body_low", -211.6, -202.6, 573.0, 611.0, -1.25, -3.0)
    back("riscos_tower_body_high", -216.2, -201.9, 611.0, 656.0, -1.25, -3.0)
    outcrop(-210.9, 603.5, BODY_FACE, "grass")
    outcrop(-211.0, 646.6, BODY_FACE, "shrub")
    # The pug arrow, pointing east along the shelf, moved back out of the play space onto its floor.
    A.deco("sign_pug_arrow_east", -226.5, BALCON, z=-1.4, size=(1.24, 1.66, 0.16), tone=WOOD)   # origin: the post's foot
    # The two flags, one at each edge of the gust, both streaming west when it blows: the first at the
    # back of the shelf 9 m along it; the second in the back corner of the alcove (moved 1.1 m east
    # from where it stands today, on nothing).
    flag(-221.0, BALCON, 3.0, east=False)
    flag(-209.5, R1, 2.2, east=False)
    # The fallen hoist at the tower's foot on the shelf's back floor: two poles 5.5 m long still
    # lashed at the head, the pulley block on the lashing, no rope; beside it a stack of split planks
    # that never went up (the kit's plank, four high).
    A.deco("riscos_hoist_fallen", -215.6, BALCON, z=-3.0, size=(5.8, 0.9, 0.8), tone=WOOD)
    for k in range(4):
        board(-216.6 + 0.04 * k, round(BALCON + 0.12 * k, 2), -2.1, 2.0, rot=0.6 * (k % 2) - 0.3)
    # Dry tufts on the back wall's steps (they lean west in the gust: item 9).
    for x, y in ((-227.8, 586.3), (-225.4, 583.0), (-219.8, 579.3), (-213.4, 579.3)):
        tuft(x, y, round(BALCON_WALL + 0.15, 2))
    # Foreground: a chalk lip at the bottom west corner, in front of solid rock and below the walk,
    # its top under the door's sill, with a grass tuft on it; the trail post on the lip beside the
    # door, 3 m, a rag of the town's bunting on it streaming west (you pass behind it for one step).
    front("riscos_chalk_lip_balcon", -235.5, -228.6, 570.5, 579.3, 1.3, 2.2, tone=ROCK)
    tuft(-233.9, 579.1, 1.75)
    A.deco("riscos_trail_post", -233.3, 579.3, z=1.35, size=(1.0, 3.0, 0.2), tone=WOOD)   # origin: the pole's foot; the rag reaches 0.9 west

    # ============================================================ 7.2 Nidos
    # The slick slab and the door's lintel (skin): dark brown, glossy, nothing pale on it from the
    # nest ledge's lip to the bottom; the nest ledge R2's top white, the whitewash on 1.5 m of its lip
    # (x -239.6 .. -238.1).
    skin("riscos_face_slab", -246.0, -230.0, 586.0, R2)
    # The colony's cliff: the face's body, grey-tan, 1.5 m proud of the slab all the way down it
    # (outline (-246, 586.5), (-228.6, 586.5), (-228.6, 590.4), (-236.6, 600.4), (-236.6, 605.2),
    # (-237.4, 606.6), (-237, 611), (-246, 611)), carrying the nest ledge on behind you as a deeper
    # shelf (top 600, from z -1.25); three small ledges on its proud strip, each with a white streak
    # painted under it. The slab you touch has none of this.
    back("riscos_colony_cliff", -246.0, -228.6, 586.5, 611.0, -1.25, -3.0)
    nest(-234.65, 596.9, -1.7, 1.1)
    nest(-231.55, 593.0, -1.7, 1.1)
    nest(-236.4, 599.1, -1.7, 1.0)
    bones(-239.3, R2, -2.4)
    tuft(-233.15, 595.0, -1.35)
    # The far nest, 1.6 m, moved to the ledge's back half, and the second of the cliffs' frogs in it
    # among the sticks, looking up as a bird goes over (notes 68, 60). Also 7.3's.
    nest(-241.6, R2, -1.8, 1.6)
    A.deco("frog_sit", -241.5, 600.3, z=-1.8, size=(0.26, 0.26, 0.27), tone=ACCENT)
    # The near nest (1.4 m) and the larder in the alcove's back part, down on its floor (today the
    # nest hangs inside the alcove's roof).
    nest(-207.3, R1, -2.0, 1.4)
    bones(-208.6, R1, -2.15)
    # An outcrop on the slab's front, over rock (foreground, below the ledge).
    outcrop(-243.0, 594.0, 1.2, "grass")
    # Foreground: a chalk lip at the bottom west corner, in front of the rock under the slab.
    front("riscos_chalk_lip_nidos", -246.0, -233.5, 586.5, 590.6, 1.3, 2.2, tone=ROCK)
    tuft(-241.0, 590.3, 1.75)

    # ============================================================ 7.3 Arbol Seco
    # The dead tree (skin, made in place: it leans 37 degrees out from the back of the nest ledge):
    # 24 m of trunk, bleached silver white, smooth, bark gone but for strips; 8 m you can hold, then
    # 11.5 m of black glassy lightning scar with a forked jagged edge at both ends and a split up its
    # middle, then 4.5 m you can hold; three roots gripping the ledge's back on its first metre. The
    # stubs and the two branches are item 8's.
    skin("riscos_dead_tree", -243.28, -228.32, 599.59, 619.21, tone="bone")
    # The crown, a fan of dead boughs, moved back 0.5 m behind the two branches (the kit's).
    tx, ty = _tp(24.0)
    A.deco("dead_tree_crown", round(tx, 2), round(ty, 2), z=-1.65, size=(4.82, 3.94, 0.14), tone="bone")
    # The far boughs: behind each stub, a longer dead bough going off from the far side of the trunk,
    # grey-white and duller than the stubs (made 2.2 m, pointing +y; origin its butt).
    for i, sc in enumerate((0.8, 1.15, 0.95, 1.3, 0.7, 1.2, 0.9, 1.05)):
        s, o = 8.8 + 1.4 * i, (0.5 if i % 2 == 0 else -0.5)
        bx, by = _tp(s, o * 0.6)
        dx, dy = _TD[0] * 0.9 - 0.8 * o * 2.9, _TD[1] * 0.9 + 0.6 * o * 2.9
        A.deco("riscos_far_bough", round(bx, 2), round(by, 2), z=-1.8, rot=round(math.degrees(math.atan2(-dx, dy)), 1),
               scale=sc, size=(0.3, 2.2, 0.3), tone="bone")
    # The fin's body (also 7.4): the hanging fin is the near edge of a thicker fin of grey-tan chalk
    # 4.2 m wide; it closes the back of the keyhole, so it reads as a doorway into rock; a small ledge
    # on its west side holds a fallen board (7.4).
    back("riscos_fin_body", -223.6, -219.4, 613.0, 630.0, BODY_FACE, -3.0)

    # ============================================================ 7.4 Puente Roto
    # The fin under the keyhole and the keyhole's floor and sill R3 (skin): dark, the floor white.
    skin("riscos_keyhole_fin", -223.8, -220.0, 614.0, R4)
    # The two stubs of deck (skins): three honey boards on their two bearers, the last snapped across
    # with splinters, frayed rope ends hanging 0.3 m under it (made 1.5 x 0.55 x 1.0).
    A.deco("riscos_deck_stub", -219.25, 623.75, z=0.0, size=(1.5, 0.55, 1.0), tone=WOOD, skin=True)
    A.deco("riscos_deck_stub", -210.75, 623.75, z=0.0, size=(1.5, 0.55, 1.0), tone=WOOD, skin=True, flip=True)
    # Each anchor's back post (1.6 m, 0.25 thick) with the back hand rope still knotted round it and
    # frayed off after 0.6 m like a tassel; under each stub its back bearer, a pole out of the rock
    # with a strut under it (made 1.5 x 1.42 x 0.2; origin the strut's foot on the rock, the pole
    # running +x: the east one flipped).
    A.deco("riscos_bridge_post", -220.325, R4, z=-1.35, size=(0.9, 1.6, 0.25), tone=WOOD)     # origin: the post's foot; the tassel reaches 0.6 east
    A.deco("riscos_bridge_post", -209.675, R4, z=-1.35, size=(0.9, 1.6, 0.25), tone=WOOD, flip=True)
    A.deco("riscos_bearer_strut", -220.0, 622.2, z=-1.35, size=(1.5, 1.42, 0.2), tone=WOOD)
    A.deco("riscos_bearer_strut", -210.0, 622.2, z=-1.35, size=(1.5, 1.42, 0.2), tone=WOOD, flip=True)
    # Two boards from the middle of the bridge caught on their way down: one in a joint of the tower's
    # body, one on a ledge of the fin's body.
    board(-210.95, 617.4, -1.55, 1.2, rot=-19.0)
    board(-223.3, 616.4, -1.55, 1.2, rot=36.0)
    # In the window's back: a stack of spare deck boards and a pack saddle on a peg (somebody meant
    # to mend the bridge).
    for k in range(3):
        board(-208.0, round(R4 + 0.108 * k, 3), -1.8, 1.8)
    A.deco("riscos_pack_saddle", -206.2, 624.9, z=-2.0, size=(0.6, 0.5, 0.4), tone=WOOD)        # origin: the middle of its foot on the wall (window back, z -2.2)
    # La Cornisa's first flag, at the back of the window's east mouth, streaming east (also 7.5).
    flag(-204.6, R4, 2.0, east=True)
    # Foreground: the two front posts, snapped off 0.3 m above the floor (too low to cover anything).
    for x in (-220.325, -209.675):
        A.deco("riscos_post_stump", x, R4, z=1.375, size=(0.25, 0.3, 0.25), tone=WOOD)

    # ============================================================ 7.5 La Cornisa
    # The cornice (skin): one hard bed jutting 9 m east like a hat's brim: its underside a dark seam
    # of flints (the knobs are item 8's), its sloping back dark brown and polished between the pegs;
    # the nose one great boss of white flint 1.8 m across (skin).
    skin("riscos_cornice", -204.0, -194.7, 626.2, 637.15)
    # The tower from the window's lintel to the upper window (skin; also 7.6, 7.7, 7.8): its east
    # face one clean slick drop, the low lintel over the window's east mouth; the stair tunnel R5 cut
    # through it with three white steps up to the west; R7's floor and its west balcony white on top,
    # the corbel under the balcony dark, straw painted on the balcony's east end where the third
    # kick lands you (x -214.1 .. -212.6).
    skin("riscos_tower_mid", -216.0, -204.0, 626.2, R7)
    skin("riscos_flint_nose", -196.1, -194.3, 627.5, 629.85, tone="bone")
    # The cornice's body: the near edge of a thicker bed; behind you its underside hangs 0.5 m lower
    # than the roof you hold; above the sloping back it stands 2 m higher as a step (outline (-202.6,
    # 625.9), (-195.4, 627.1), (-194.3, 628.2), (-194.2, 630.6), (-197.3, 634.6), (-200.6, 638.2),
    # (-202.6, 640.2)). It meets the tower's body at x -202.6.
    back("riscos_cornice_body", -202.6, -194.2, 625.7, 641.0, BODY_FACE, -3.0)
    # The rest of the seam along the body's underside: eight grey knobs behind the six white ones.
    for i in range(8):
        x = -202.3 + 0.95 * i
        A.deco("riscos_flint_grey", round(x, 2), round(_roof_y(x) - 0.5 - 0.3, 2), z=-1.6, size=(0.3, 0.3, 0.3), tone="back2")
    # The stair's back row: behind each peg its twin in the body, a stub in dull brown rust; two
    # treads still on, broken short, both behind you.
    for x, y in _PEGS:
        peg_stub(x, round(y + 0.4, 2))
    board(-198.9, round(_PEGS[2][1] + 0.5, 2), -1.37, 0.7)
    board(-201.5, round(_PEGS[4][1] + 0.5, 2), -1.37, 0.7)
    # The warning sign (note 67): the yellow diamond with a black "!" on its rust-orange bracket,
    # 1.2 m straight out from the tower's body just under the window's floor (the kit's
    # sign_warn_bang; origin the bracket's wall end on the body's east face, the bracket running +x).
    A.deco("sign_warn_bang", -202.6, 622.9, z=-1.5, size=(1.62, 1.58, 0.14), tone="gold")
    # The second flag, on the body's step above the nose (moved off the nose's own knob).
    flag(-195.6, 630.5, 2.4, east=True)
    tuft(-196.6, 633.3, -2.1)

    # ============================================================ 7.6 Desprendimiento
    # The arch's two masses (skins): west of El Ojo the gully, three slick treads polished by the
    # boulders with dull grey scuffs and nothing white, the two pockets' floors and steps dry white,
    # their roofs and backs dark; east of it the counter-slope, slick, the keyhole's roof under it.
    skin("riscos_gully", -244.0, -228.0, 626.0, R6)
    skin("riscos_counter_slope", -224.0, -210.0, 628.0, 639.6)
    # The west face (skin, the whole face from the nest ledge's back wall to the station): the nest
    # ledge's back wall and roof, the wall under the arch's springing, the gully's head R6 (white),
    # its back wall, and the bare face up to the deck, all slick brown in long wavy beds.
    skin("riscos_west_face", -260.0, -238.5, 599.98, 684.02)
    # R6's roof (skin): the boulders' road off the head of the gully.
    skin("riscos_gully_roof", -253.0, -243.6, 653.0, 658.8)
    # The face's body behind the whole face above the colony (outline x -262 to a metre proud of the
    # face line: (-238, 611), (-237.5, 626), (-243, 647.6), (-248.5, 653), (-249.2, 660), (-250, 684),
    # (-250.5, 690)); R6's ledge carried back to z -2.6 (the paint tins and a peg on it); R6's roof
    # carried back as a level shelf (top 657.8, x -250.2 .. -247.1) where the rubble pile sits. The
    # tea cave's room is cut out of it (7.0).
    back("riscos_face_body", -262.0, -237.5, 611.0, 690.0, -1.25, -3.0)
    # The gully's far wall: the arch's body, higher than the gully's bed all the way along (15 m at El
    # Ojo, 3 m at the head: its top steps up to the west, 645.6 at x -212 to 650.2 at -245), so the
    # gully is a trough and El Ojo a well; its underside the arch's (626 to 629.4); a paler grey band
    # rubbed along it 0.8 m above each tread (the boulders' line, drawn before a boulder comes); the
    # lower pocket carried back to z -1.9 (the driver's bench), the upper one into the tea cave's
    # doorway (7.0: the room is cut out of it). It meets the tower's body at x -211.6.
    back("riscos_arch_body", -244.0, -211.6, 626.0, 650.2, -1.25, -3.0)
    outcrop(-216.0, 642.8, BODY_FACE, "grass")
    outcrop(-237.0, 645.5, BODY_FACE, "shrub")
    # The rock fence's frame, moved back to stand on the counter-slope behind you, leaning down it
    # (the kit's; item 7d): its posts, the torn netting and the heap at its foot.
    A.deco("rock_fence_frame", -218.0, 634.4, z=-1.55, rot=-33.0, size=(18.94, 3.01, 0.38), tone=WOOD)
    # Where the boulders start: the rubble pile on the roof's shelf over the gully's head, moved back
    # out of the play space, and the next three boulders sitting on it (the kit's boulder at 1.1 m,
    # its origin its centre).
    A.deco("rubble_pile", -248.65, 657.8, z=-1.95, size=(3.0, 1.6, 1.0), tone="rock2")
    for x, y, z in ((-249.4, 659.3, -2.0), (-248.2, 659.4, -2.15), (-248.9, 659.95, -1.85)):
        A.deco("boulder", x, y, z=z, scale=0.917, size=(1.2, 1.2, 1.2), tone="rock2")
    # The driver's bench at the back of the lower pocket: a short plank on two iron pegs.
    for x in (-234.7, -234.1):
        A.deco("iron_peg", x, 635.3, z=-1.9, size=(0.14, 0.24, 0.4), tone=IRON)       # origin: where it meets the pocket's back
    board(-234.4, 635.4, -1.7, 1.0)
    # Two outcrops on the west face's front, well inside the rock (foreground, over rock).
    outcrop(-253.5, 637.0, 1.2, "shrub")
    outcrop(-255.5, 668.0, 1.2, "grass")
    # Foreground: a chalk lip at the bottom west corner, in front of the face's solid rock.
    front("riscos_chalk_lip_gully", -252.5, -244.8, 628.5, 632.7, 1.3, 2.2, tone=ROCK)
    tuft(-249.5, 632.4, 1.75)

    # ============================================================ 7.0 The tea cave
    # The room, dug out of the rock under the first burro's ledge, cut away at the front: its floor's
    # back half, its back wall 2.2 m behind the line you walk, its two side walls and its roof, pale
    # chalk with the pick marks still on them, painted amber (the lantern's and brazier's light as
    # colour), the roof black with smoke over the brazier with the crack the smoke goes up. Its floor
    # and doorway in the play space are the course's (item 6a), worn by the gully's skin.
    back("riscos_tea_cave", -245.6, -240.2, 641.17, 643.97, -1.25, CAVE_BACK, tone="#C9A070")
    # The woven rug in the town's colours on the back half of the floor, a cushion at each end.
    A.deco("riscos_tea_rug", -243.3, CAVE, z=-2.15, size=(2.6, 0.03, 1.2), tone=ACCENT)
    for x in (-244.2, -242.4):
        A.deco("tea_cushion", x, round(CAVE + 0.03, 2), z=-2.2, size=(0.53, 0.15, 0.53), tone=ACCENT)
    # The low table, the pot that steams and the cup set out for you at its east end, nearest the door.
    A.deco("tea_table_low", -243.3, round(CAVE + 0.03, 2), z=-2.05, size=(0.9, 0.35, 0.6), tone=WOOD)
    A.deco("tea_pot", -243.45, round(CAVE + 0.38, 2), z=-2.05, size=(0.25, 0.2, 0.18), tone=ACCENT)
    A.deco("tea_cup", -242.97, round(CAVE + 0.38, 2), z=-2.0, size=(0.12, 0.1, 0.11), tone="bone")
    # The frog on the west cushion with its own cup (notes 68, 60): it blinks, and now and then sips.
    A.deco("frog_tea", -244.2, round(CAVE + 0.18, 2), z=-2.1, size=(0.25, 0.26, 0.29), tone=ACCENT)
    # On the back wall: the shelf of tins and cups, and beside it three iron pegs with the pack saddle
    # and a folded burro blanket hanging on them (whose room it was).
    A.deco("tea_tins_shelf", -244.4, 642.9, z=CAVE_BACK, size=(1.0, 0.5, 0.2), tone=WOOD)        # origin: the middle of its back's foot, on the wall
    for x in (-242.5, -242.0, -241.5):
        A.deco("iron_peg", x, 643.0, z=CAVE_BACK, size=(0.14, 0.24, 0.4), tone=IRON)
    A.deco("riscos_pack_saddle", -242.25, 642.55, z=round(CAVE_BACK + 0.2, 2), size=(0.6, 0.5, 0.4), tone=WOOD)
    A.deco("riscos_blanket_folded", -241.5, 642.45, z=round(CAVE_BACK + 0.1, 2), size=(0.5, 0.6, 0.2), tone=ACCENT)
    # The brazier by the door on its three legs, the kettle on it, orange coals (colour) under.
    A.deco("tea_brazier", -241.55, CAVE, z=-2.1, size=(0.4, 0.35, 0.4), tone=IRON)
    A.deco("tea_kettle", -241.55, round(CAVE + 0.35, 2), z=-2.1, size=(0.31, 0.27, 0.24), tone=IRON)
    # The small lantern on a peg under the roof at the back (the kit's lantern_hang: origin its hook).
    A.deco("lantern_hang", -242.9, 643.72, z=round(CAVE_BACK + 0.17, 2), size=(0.28, 0.52, 0.31), tone="gold")
    # The striped burro blanket hung as a door curtain, tied back to a peg on the doorway's far side:
    # from the gully the one patch of bright colour in the rock (made tied back: 0.35 x 1.6 x 0.2).
    A.deco("riscos_door_blanket", -240.43, 641.9, z=-1.35, size=(0.35, 1.6, 0.2), tone=ACCENT)
    # Foreground: the cut edge, a low lip of rock along the floor's front, its top below the floor.
    front("riscos_tea_cut_edge", -245.6, -240.2, 640.75, 641.15, 1.25, 1.55, tone=BODY)

    # ============================================================ 7.7 Los Burros
    # The two needles: each burro ledge is the near edge of the flat top of a needle of grey-tan
    # chalk 4 m wide standing on the arch's body; the top goes back 2 m behind the ledge (dull tan,
    # straw scattered on its west end). Their ledges and supports (skins): the white tops, the dark
    # undersides; straw painted on each ledge's west end where a kick lands you.
    skin("riscos_needle_top_a", -236.0, -232.6, 646.5, 650.0, tone=ROCK)
    skin("riscos_needle_top_b", -226.0, -222.6, 648.7, 652.2, tone=ROCK)
    back("riscos_needle_body_a", -236.8, -232.0, 645.0, 650.0, -1.3, -3.3)
    back("riscos_needle_body_b", -226.8, -221.8, 645.4, 652.2, -1.3, -3.3)
    # The three loads, each behind its burro on the back of its ledge with an iron hitching peg and a
    # frayed end of halter: four paint tins (two in the cableway's red, two in its yellow ochre); a
    # bundle of sawn posts painted ochre; a coil of grey haul cable 0.15 m thick. The first things on
    # the climb that belong to the cableway.
    A.deco("riscos_paint_tins", -248.8, R6, z=-1.8, size=(0.9, 0.45, 0.45), tone="#B8352A")
    hitch_peg(-246.6, R6)
    A.deco("riscos_post_bundle", -234.8, 650.0, z=-2.2, size=(1.8, 0.4, 0.5), tone="#C8962E")
    hitch_peg(-232.9, 650.0)
    A.deco("riscos_cable_coil", -225.2, 652.2, z=-2.2, size=(0.9, 0.9, 0.3), tone=IRON)
    hitch_peg(-222.9, 652.2)
    tuft(-232.7, 650.0, -2.9)
    # The standing hoist on the back of the tower's balcony at its west end: the same as the one on El
    # Balcon, standing: two lashed poles 4.3 m leaning out west over the gap toward the second needle,
    # a pulley block at the head and no rope (origin the middle of its two feet; the head 2.1 m west).
    A.deco("riscos_hoist_standing", -215.3, R7, z=-2.4, size=(2.8, 4.1, 0.6), tone=WOOD)
    # The scaffold's four legs (item 7g): raking struts in yellow ochre from the catwalk's posts down
    # to iron shoes in the needles' sides and onto the balcony's back, each meeting the rock under a
    # ledge, so nothing stands on a ledge you land on (also 7.10's).
    for xp, xf, yf in STRUTS:
        strut(xp, xf, yf)
    # One short dead tree on the arch's body, behind the first kick.
    A.deco("dead_tree", -241.0, 649.7, z=-2.4, scale=0.4, size=(6.0, 8.0, 1.0), tone="bone")

    # ============================================================ 7.8 Viento a Favor
    # The horn (skin): a lone horn of chalk, its 3 m of flat top white, its sides slick; the snag on
    # it (skin): its stub with a strip of bark, the knot a round of pale end grain 0.4 across, the
    # bough's end a bigger one 0.5 across, worn smooth.
    skin("riscos_horn", -185.2, -181.8, 642.0, R7)
    skin("riscos_snag", -184.92, -182.25, 653.98, 659.85, tone="bone")
    # The horn's stalk: grey-tan chalk coming up out of the throat, wider at the bottom (4.4 m under
    # the top, 9 m at its foot); on the back of its top (carried back to z -2.6) the round's other
    # nest, a white streak down the stalk under it. The one thing of ours east of the tower.
    back("riscos_horn_stalk", -188.5, -179.5, 560.0, R7, BODY_FACE, -3.0)
    nest(-184.3, R7, -2.1, 1.2)
    # The snag's trunk, leaning back away from you out of the play space above the stub and going on
    # up to 6.4 m, grey-white (origin its foot on the horn's top, behind the stub).
    A.deco("riscos_snag_trunk", -182.55, R7, z=-1.85, size=(2.0, 6.4, 0.4), tone="bone")
    # The window's end of the round: a nest and a bone pile in the back of the upper window's east
    # mouth, 1 m further back than you can walk.
    nest(-205.0, R7, -2.0, 1.3)
    bones(-206.2, R7, -2.15)
    # The perch plank's pole bearer, out of the window's mouth under the plank (the bridge's bearer
    # at 0.75).
    A.deco("riscos_bearer_strut", -204.0, 652.535, z=-1.35, scale=0.75, size=(1.5, 1.42, 0.2), tone=WOOD)
    # Seven peg stubs up the body's east edge from the plank to the porch: the trail's way, gone.
    # (Above 656 the body is the tower top's, its face about z -1.8 there.)
    for y in (654.26, 655.46, 656.86, 658.26, 659.66, 661.06, 662.46):
        peg_stub(-203.1, y, z=(BODY_FACE if y < 656.0 else -1.8))
    # Two flags streaming west in the gust: 2.4 m at the back of the window's mouth; 1.6 m on the back
    # of the horn's top at its west end (moved 2.5 m west, clear of the snag and the bird's hover).
    flag(-203.4, R7, 2.4, east=False)
    flag(-184.8, R7, 1.6, east=False, z=-1.4)
    # The wind sock on the porch (where today's third flag is): on a post at the porch's back, red and
    # white bands, filling and pointing west into the porch in the gust (the kit's wind_sock, its eye
    # on the post's top; the kit's bunting_pole at 0.75 as the post, 2.4 m).
    A.deco("bunting_pole", -203.6, PORCH, z=-1.45, scale=0.75, size=(0.17, 3.2, 0.17), tone=WOOD)
    A.deco("wind_sock", -204.05, 664.96, z=-1.45, size=(0.99, 1.48, 0.42), tone=ACCENT)

    # ============================================================ 7.9 Chimenea de Roca
    # The tower's split top: THE WORKED EXAMPLE, the kit's ex_riscos_tower_top as the game piece
    # (skin; measured x -4.80 .. 5.12, y 0 .. 22.4, z -3.6 .. 1.2 about its origin, the course's
    # (-207.0, 656.0, 0): the foot of the chimney's middle on the play plane). The two fins and their
    # five white bands, the porch's ledge and its tooth, the west fin's standing top, the overhang
    # with its shadow painted, the small ledge with grass, the leaning slab, the broken tip, and the
    # body behind with the split's back wall (its one cut and one addition: item 7a here, and
    # a7_models.md section 1).
    A.deco("ex_riscos_tower_top", -207.0, 656.0, z=0.0, size=(9.92, 22.4, 4.8), tone=SLICK, skin=True)

    # ============================================================ 7.10 La Estacion Baja
    # The station's scaffold, moved back out of the play space (made in place): four square posts in
    # yellow ochre at x -237, -229.2, -220.7, -213 from the catwalk (663) to the deck (688); a ledger
    # under every plank you stand on (662.5 all along; 676.5 west of -220.5 under the stage; 671.5
    # from -220.9 to -208.4 under the platform; 682.45; 687.5 under the deck); red braces crossed in
    # the bays (x -237 .. -229.2 663 .. 676.3; -229.2 .. -220.7 and -220.7 .. -213 663 .. 671;
    # -229.2 .. -213 682.6 .. 687.3), NO BRACE behind the wheel or the long brace; an iron plate with
    # the pug's face at every joint; each plank deck the near edge of a floor going back 1.4 m onto
    # its ledger (z -1.25 .. -2.6). Its legs are 7.7's struts.
    back("riscos_scaffold", -237.4, -208.2, 662.2, DECK, -1.25, -2.8, tone="#C8962E")
    # The pylon head, moved back out of the play space onto the west fin's body (the kit's; item 7f).
    A.deco("pylon_head_low", -212.2, 672.0, z=-1.75, size=(8.3, 4.98, 0.89), tone="#B8352A")
    # The wheel's bay closed at the back with plain ochre boards, so the red rim reads against one
    # flat colour; in front of them on the wheel's axle, 2 m behind it, a plain grey drum 5 m across
    # with the haul cable round it (why the wheel turns: item 8, it follows the wheel); the axle in an
    # iron bearing under a pug plate on the scaffold's third post.
    back("riscos_wheel_backboard", -225.2, -215.2, 670.4, 679.6, -2.6, -2.8, tone="#C8962E")
    A.deco("riscos_wheel_drum", -220.2, 675.0, z=-2.0, size=(5.0, 5.0, 0.6), tone=IRON)      # origin: its axle
    A.deco("riscos_axle_bearing", -220.2, 674.5, z=-2.45, size=(1.0, 1.0, 0.3), tone=IRON)
    # The haul cable (one piece, made in place): black, greased, 0.15 m thick and taut, 2 m behind
    # you: from biome 8's pulley at the foot of the station's end frame (r 0.4 at (-233.0, 688.6), page
    # 8.1: from there the cable goes on up the frame to the wind engine, a8_dress's piece) down over the
    # pylon head's first sheave, round the top of the drum ... the bottom of the drum, over the second
    # sheave and back up to the pulley; the two long runs side by side, never crossing, about 5 m over
    # the brace, the short ones 2.5 m over the platform. Corners of its road: (-233.2, 688.25) -
    # (-213.4, 677.5) - (-220, 677.5) / drum / (-220, 672.5) - (-211.4, 676.5) - (-211.0, 677.5) -
    # (-232.8, 688.95) (pages 7.10, 7 to 8 and 8.1).
    back("riscos_haul_cable", -233.3, -210.4, 672.35, 689.05, -1.925, -2.075, tone="back3")
    # Along the back of the old catwalk: the trail's handrail of lashed poles, 1.1 m high, unpainted,
    # one rag of bunting; against it a stack of ochre posts carried up and never used; and the
    # platform's missing board lying on the catwalk below the gap.
    A.deco("riscos_trail_rail", -225.0, CATWALK, z=-2.45, size=(23.2, 1.15, 0.15), tone=WOOD)
    A.deco("riscos_post_stack", -227.0, CATWALK, z=-1.9, size=(2.8, 0.45, 0.6), tone="#C8962E")
    board(-213.95, CATWALK, -1.6, 1.3, rot=4.0)
    # The long brace (skins): one of the scaffold's own braces, 0.3 m, in the cableway's red, matte,
    # worn to bare honey wood along its top; its head bolted to the deck's end beam through an iron
    # plate with the pug's face (the rotten middle is item 8's).
    skin("riscos_brace_foot", -231.47, -228.88, 677.22, 680.87, tone=WOOD)
    skin("riscos_brace_head", -235.92, -232.67, 682.86, 687.48, tone=WOOD)
    # Foreground: the scaffold's front west post, 0.3 m, from the catwalk up to the deck's underside,
    # at the frame's west edge in front of air nobody climbs through, 1.4 m clear of the brace's head.
    A.deco("riscos_front_post", -237.4, CATWALK, z=1.4, size=(0.3, 24.4, 0.3), tone="#C8962E")

    # ============================================================ 7 to 8: the low station
    # The last chalk (skin): the plug at the deck's west end, dry and matte, a grass tuft on its back;
    # the deck's first plank cut to fit against it; above it the face is dark scree (biome 8's).
    skin("riscos_chalk_plug", -253.0, -250.0, 686.0, DECK, tone=ROCK)
    tuft(-251.7, DECK, -1.28)
    # The station house, moved back to stand 2.5 m behind you under biome 8's real roof (x -251 ..
    # -237.6; its skin `tele_roof_low` carries the tin back to the ridge), no roof and no post of its own
    # (note 77; page 8.1): the kit's cable_station_low RE-MADE as a board house 12 m wide (x -250 ..
    # -238), 6.0 m at its back wall and 4.9 m at its front under the roof's slope, board walls in the
    # greyed red below bare grey boards, dark windows and door, NO CREAM.
    A.deco("cable_station_low", -244.0, DECK, z=-4.0, size=(12.0, 6.0, 3.12), tone="#9A5A4C")
    # The deck's planks carried back to its door: honey planks 0.3 m wide, two rows of nail heads,
    # sawn square and nailed.
    back("riscos_deck_back", -250.0, -236.0, 687.5, DECK, -1.25, HOUSE_FRONT, tone=WOOD)
    # What carries the deck: a ledger under its planks, two raking struts in yellow ochre from the
    # ledger down to iron shoes in the face, a pug plate at each strut's head (made in place: the
    # ledger x -250 .. -236 at 687.05 .. 687.35; struts (-244, 687.05) to (-250.8, 681.4) and
    # (-239, 687.05) to (-247.6, 679.5)). The scaffold's west post is under its east end.
    back("riscos_deck_frame", -250.8, -236.0, 679.5, 687.35, -1.45, -1.8, tone="#C8962E")
    # The cold lantern, moved back to hang on a bracket beside the house's door: not lit (the last lit
    # lantern was the tea cave's). The kit's mine_lantern_bracket (origin its plate on the wall, the
    # strap +x, the hook 0.42 along) and lantern_cold hanging from its hook.
    A.deco("mine_lantern_bracket", -243.4, 689.5, z=round(HOUSE_FRONT + 0.03, 2), size=(0.48, 0.15, 0.06), tone=IRON)
    A.deco("lantern_cold", -242.98, 689.02, z=-2.3, size=(0.28, 0.48, 0.28), tone="gold")
    # The wind sock on a post 3 m tall at the deck's back west corner: the same sock as the porch's,
    # pointing east and staying there, full (flipped; the kit's bunting_pole at 0.9375 as its post).
    A.deco("bunting_pole", -249.2, DECK, z=-2.3, scale=0.9375, size=(0.17, 3.2, 0.17), tone=WOOD)
    A.deco("wind_sock", -248.75, 689.56, z=-2.3, size=(0.99, 1.48, 0.42), tone=ACCENT, flip=True)
    # The line of pennants: the town's bunting from the station's end frame (its west leg, biome 8's)
    # out to a pole on the scaffold's top ledger, 2 m back and well over every hand (two of the kit's
    # 6 m units, tiled, at about 1.01; each unit's cord ends at y 0.68 above its origin), all pointing
    # east. (It was tied to the old house's east gable, which now stops 1.6 m further west.)
    A.deco("bunting_pole", -224.0, DECK, z=-2.3, size=(0.17, 3.2, 0.17), tone=WOOD)
    p0, p1 = (-235.9, 693.6), (-224.0, 691.0)
    rot = math.atan2(p1[1] - p0[1], p1[0] - p0[0])
    s = math.dist(p0, p1) / 12.0
    for t in (0.25, 0.75):
        mx, my = p0[0] + (p1[0] - p0[0]) * t, p0[1] + (p1[1] - p0[1]) * t
        ox, oy = mx + math.sin(rot) * 0.68 * s, my - math.cos(rot) * 0.68 * s
        A.deco("pennant_line", round(ox, 3), round(oy, 3), z=-2.3, rot=round(math.degrees(rot), 2), scale=round(s, 3), size=(6.0, 0.68, 0.02), tone=ACCENT)
    # Foreground: one painted post in front of the deck's west end, from below the frame up to just
    # under the deck's top, in front of the air under the deck where nobody is (biome 8 counts on it).
    A.deco("riscos_front_post_short", -249.45, 679.5, z=1.4, size=(0.3, 8.4, 0.3), tone="#C8962E")
