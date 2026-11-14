"""
EL TEMPLO DEL PRIMER PERRO, DRESSED: the scenery of all of biome 5, the temple of the First Top Dog
(y 364 to 494), from the twelve area pages (the frog's room 5.0 and the eleven challenges, with the
well crossing 5.11, the join "5 to 6") in docs/peak/playtest/design/data/a5_areas.py and the biome's
sheet a5_biome.py (its `built`, `looks`, `layers` and `kit`, and the pages' KIT_MORE pieces).
The join "4 to 5" is biome 4's 4.10 on the garden's side; a4_dress.py left the temple's side of it
to this file: the door's stepped side and the root in its joints, the first hall, the beam's corbel,
the chain bosses, and the moss and sprouts on the doorstep (drawn on the sill's skin). a4's item 6e
(the beam 2.6 m longer, the two chain banners moved back to z -1.3 / -1.5) is already in a5.py
(lines 53, 57-58). The join "5 to 6" is this file's 5.11 on the temple's side: the well room (the
well's back from 390 up, the stepped vault, the keystone pug, the two great chain bosses), the
temple's sill, the sacrifice stone in its niche, the last torch on the sill, and the column base in
front. The forge's side of it (the soot-black back wall east of x -294, the lip's look, the forge
door with its small iron pug and the last torch beside it, the anvil, tongs rack and trough, the
great iron mask and its breath pipe, the first grate, the black floor kerb in front) is the
chimney's (a6's) to place: its page 6.1 designs all of it.

Parker, 11-13: a jade band round EVERYTHING THAT MOVES (the false tiers, the jaw, the plunger, the
pistons, the gears' rims, the censers, the pans, the vertebrae, the phantom blocks, the cross's hub);
NO CARVING SHOWS HOW A CHALLENGE IS DONE (the carved band is pug faces, belts and bones only, the
fall strip is bones, there is no panel under the scale and no paw-print count on the stair); in
the hall of statues the far forearm has broken off and only its gilded hand is left, and the second
statue has lost both arms and has only its two hands to hold (note 75: a re-make of the kit's
statue_champion_reach, two stems here, nothing climber-shaped is modelled new). Note 54: both altars
give "Pay Your Respects" (peak.gd _tick_respects finds decos whose model is "altar"): so the two
altars here are the kit's `altar` and NOTHING ELSE is; the frog's offering table is its own stem.

Scenery only: decos. Nothing here can be stood on or held. The course (the shell, the sill, the
beam and the chains, the tiers, the mask's holds and jaw, the plunger and pistons, the gears, the
champions, the censers, the gallery floor and its slots' linings, the pans, the serpent's tail and
vertebrae, the fangs, the phantom blocks, the threshold, the bridge, the cross, the pegs, the three
who tried, the great censers) is a5.py's. The model list this file makes is
docs/peak/models/a5_models.md.

Depth: the play space is z -1.2 .. 1.2. Everything here stands behind -1.25 or in front of 1.25,
except SKINS (skin=True), each the LOOK of course solids (MODELLING_RUN rule 4), filling them,
z -1.2 .. 1.2: the shell's slabs (SHELL_SKINS), the doorstep, the beam, the hood, the exit's sill
block and lintel, the great hall's ramp, the pier and its cornice, the balcony, the gallery's three
floors, the spine of the upper works, the head's ledge, the threshold, the sill and the peg wall,
the tiers and the landing, the mask's holds, the three champions and their two plinths, the
keeper's balcony, the exit and tail ledges, the three fangs, the three sound pegs.
From the back, the temple stands at: the great hall's far wall z -10 .. -9 (its two niches and their
still champions -9 .. -7.5, the fall strip's upper run on it); the ramp carried back -9 .. -1.25
and the gallery floor carried back -9 .. -1.25 (the slots cut through all the way); the well's back
-7 .. -1.25 and its vault -6 .. -1.25; the entry hall's back wall -7 .. -6 (its two doorways
-6 .. -5, the fall strip's lower run on it), the entry floor and the chute carried back -6 .. -1.25,
the platform -5.5 .. -1.3, the great mask -5.5 .. -1.3 (its gullet, slots and eyes set into it);
the altar chamber's back wall -4 .. -3.4, the sun stone -3.4 .. -2.6, the altar's niche -3.4 .. -1.3;
the gear room's back wall -3.4 .. -2.8; the upper works' back wall -3.2 .. -2.6; the keeper's alcove
-3 .. -1.25; the piston shaft's back wall -2.7 .. -2.2; columns -3.3 .. -1.4; posts, pilasters,
belts, tracks, slots, cheeks, beams, bosses, the serpent's bed and heads, the drum, the brackets
-2.6 .. -1.25. In front: nothing but the low balustrade along the entry floor's front edge (its top
0.3 m below the floor), four column bases in front of the gallery floor (their tops level with it)
and one in front of the rock under the temple's sill.

Walls and masses (BRIEF.md "Walls and masses"; the sheet's `built`): stone is PAINT. Every wall, pier,
ramp, roof and floor body is ONE painted piece made for its place: dressed pale stone in a few big
planes; its courses are long, a little uneven, wavy painted bands in three or four tones with the
joints as thin lines (never a course built as a block, never a repeated square panel); the carved
band of pug faces, belts and bones is a painted band 0.8 m tall at the temple's heights (371.8,
377.6, 383.4 in the entry hall; 417.8, 423.6, 429.4 in the gear room; 435.8, 441.6, 447.4 in the
great hall; 472.4 over the stair; 483.0 at the altar and the sill), cut deep and real only where it
is held; nothing painted narrows to a point; no dark recess cut into a face (the stepped doorways,
the slots and the offering niches are the pages' few real breaks); a few big real breaks: a fallen
block, a step, a cornice with its shadow painted. Where you can hold it the stone is pale, dry and
carved; where you can't it is polished black, wet with soot and damp, with pale runs (bands, never
wedges). Behind each mass the hall's wall carries its courses on as thin lines, browner and darker.
A few small blocks stand proud of the back walls, each with the temple's own flat painted plant: a
dry offering sprig (marigold heads and a jade paper streamer). THE TEMPLE IS LIT BY TORCHES AND
FALLS AWAY INTO BROWN: in tonight's dark frames painted bands vanished wherever their values sat
close together. Every wall must be judged in the temple's own torchlight, its bands stepped well
apart in value.

A deco's origin is the middle of its base (x and z) at its foot (y), unless its comment says
otherwise: things that hang from a ceiling (chain bosses) have theirs at the middle of their top;
wall-mounted things (torches, plaques, niches, shelves, sprigs) the middle of their foot on the
wall; things that turn (the scale's beam, the mallet) their axle; a champion's skin between its feet;
a belt the foot of its back pillar. For the long pieces (walls, floors carried back): the middle of
its x span, the bottom of its box, the middle of its depth. A deco's size is the size its model is
MADE at (the game rescales a landed model more than a quarter off); where one model is used at
several sizes, `scale` does it and the size is the model's own. `rot` is in degrees,
counter-clockwise as the camera sees it (a positive rot tips a thing's top to the west).

Shared pieces are placed once, in the first section that names them, and the other page is named in
a comment (the entry hall's back wall for 5.1 and 5.2, the fall strip for 5.1 and 5.6, the great
hall's far wall and the last pilaster for 5.5 and 5.6, the upper works' back wall for 5.7, 5.0, 5.8
and 5.9, the serpent's head for 5.8 and 5.9, the altar's niche and columns for 5.9 and 5.10, the
altar chamber's back wall for 5.10 and 5.11).

FOR THE AREA FILE (tools/peak/areas/a5.py; the fix thread's). Line numbers are a5.py's as of
2026-11-14 03:08 (the version with the beam at -300.9 and the chain banners at z -1.3 / -1.5).
  1. Call it: `import a5_dress` beside the other imports, and `a5_dress.dress(A)` after the course
     is built and before the phase loop at line 507 (so before A.save()).
  2. Lights. Keep every torch light where it is (page 5.1: "The light each one gives stays where it
     is"; torch(), line 31, and its 24 calls, lines 474-482), the jade eyes (483-484), the well's
     throat and the arrival (488-489). Change: the "altar's fire" (line 485) sits on the cross's hub,
     not the altar: move it to `a5_dress.ALTAR_LIGHTS[0]` (the first altar's bowl) and add one at
     `ALTAR_LIGHTS[1]` (the sacrifice stone's bowl), both "#FF9040", range 5, energy 1.0, flicker.
     The censers' coals (line 486): with the first and third censers gone (item 6a), drop entries 1
     and 3 ((-324.5, 440.2), (-315.5, 443.8)). Add the frog's two small lamps, one per
     `a5_dress.FROG_LAMPS`: "#FFB860", range 3, energy 0.6, flicker. `a5_dress.TORCHES` lists every
     torch this file hangs (x, y, z), if a light is ever moved onto its new torch.
  3. Decos to take out (this file places what the pages keep, out of the play space):
     line 30 (torch()'s deco at z -0.9, in the play space: torch() keeps only its light), lines
     34-36 (mask()) and its calls 457-463 (the seven pug masks: only the plaques the pages name stay,
     placed here), 265 (the champion's skin deco: this file places the three new skins), 311-312 (the
     two counterweight chains in the play space: page 5.7, they go), 361 (the drum in the air in front
     of the serpent's head), 456 (mask_first_dog at z -2.9: its face reached 0.8 m behind you; placed
     here at z -3.4, its face 1.3 m behind, the same size), 464 (the serpent's head at z -0.9), 465-466
     (the two altars at z -1.2: placed here in their niches, still the kit's `altar`), 468-470 (the
     eleven banners at z -1.4: the pages hang five, high on far walls), 471-472 (the two strings of
     cut paper). KEEP 57-58 (the two banners on the chains).
  4. Cards to take out, all but the piston sockets: line 441 (the back of the room at z -6: the
     hall walls replace it), 442 (the far pyramid at -12, behind the entry hall's back wall), 443 (the
     great hall's far wall: `templo_hall_far_wall`), 445 (the wall that carries the stairs:
     `templo_platform`), 446-447 (the champions' pillars: the two great pilasters), 448 (the broken
     arch at z -3: on no page), 449-450 (the gallery's colonnade: the columns). KEEP 198-200 (the
     nine sockets on the walls' faces: page 5.3 item "Nine sockets").
  5. Skins. Each named solid takes `skin=` its stem; this file places every skin deco.
     a. The shell (line 44): pass `skins=a5_dress.SHELL_SKINS` to A.cave (peaklib's `skins`: each
        edge's slab and the filler at its start wear it). If the frog's room is cut (item 6c), the
        outline is `a5_dress.SHELL_ROOM` and the skins `a5_dress.SHELL_SKINS_ROOM`.
     b. By line: the grip sill (52) "templo_door_sill"; the beam and its corbel (53-54)
        "templo_banner_beam"; the hood (60) "templo_hood"; the exit's lintel and sill block (62-63)
        "templo_exit_door"; the ramp (70) "templo_hall_ramp"; the pier (77) "templo_pier"; R3 (78)
        "templo_pier_cornice"; the balcony (79) "templo_balcony"; the gallery floor (81-83: the body
        and the top of each run) and the slots' linings (89-90), by run: x -352 .. -338 and the
        lining at -338 "templo_gallery_floor_a", x -336.6 .. -328 and the linings at -336.6 and -328
        "templo_gallery_floor_b", x -326.6 .. -312.8 and the lining at -326.6 "templo_gallery_floor_c";
        the spine (92) "templo_stair_ramp"; HL (93) "templo_head_ledge"; TL (94) "templo_threshold";
        the altar's east wall (96) "templo_peg_wall"; the sill (97) "templo_sill"; the first and third
        tiers (114, k = 1 and 3) "templo_tier_true"; the landing (115) "templo_landing"; the lip (141)
        "templo_mask_lip"; the three teeth (143) "templo_mask_tooth"; the nostrils (144-145)
        "templo_mask_ring"; the cheekbones (146-147) "templo_mask_stud"; the eye rims (148-149)
        "templo_mask_lid"; the brow (150) "templo_mask_brow"; the plinths (254)
        "templo_plinth"; the champions (lines 252-264): SK becomes "templo_champion_broken" for the
        first and third, "templo_champion_handless" for the second (item 6b); EB (287)
        "templo_keeper_balcony"; XL (310) "templo_exit_ledge"; SL (325) "templo_tail_ledge"; the
        three fangs (332) "templo_fang"; the three sound pegs (388) "templo_peg". The rock behind the
        west sockets (183) takes "templo_shaft_wall_west" with edge 2's slab.
  6. Course changes on the pages, for the fix thread (not scenery):
     a. 5.6 (note 50, not built): one censer, the middle one. Take out censer1 and censer3 (lines
        284, 286) and their lights (item 2). The moves (288-293) become: F3's fist -> censer 2
        (a 7.3 m fling to a moving chain, still to be tried) -> the balcony EB. If censer 2 moves half
        a metre, its boss (`templo_chain_boss` at x -320) moves with it.
     b. 5.5 (Parker 11-13): the forearm drawn between each east elbow and its hand comes off all
        three statues: delete the ghost forearm (lines 263-264; it was never held). The second
        champion loses the outer 1.6 m of its WEST arm: its beam (line 258) ends at (-348.95,
        437.63), a 1.2 m stump; the fist (259) stays where it is as a stone hand 1 m across gripping
        the belt, with no arm behind it. The 7 m fling to that hand and the 1.85 m reach from it to
        the stump are to be tried; the stump's length is the one number. champion() wants a flag for
        it (and the skin names of item 5b).
     c. 5.0 (note 60, not built): the frog's room, 2.8 m deep and 2.8 m tall, cut into the west wall
        at the exit ledge, its floor level with the ledge (y 455): SHELL becomes `a5_dress.SHELL_ROOM`
        (the same outline with the room's eight points between (-366, 434) and (-366, 466.5)), kinds
        {0: "stone", 7: "stone" (the room's floor), 20: None, 22: None}; the slabs behind it make the
        wall a metre thicker by themselves (thick 3.0). Only the floor can be stood on. The frog
        croaks when you are within a screen of it (note 60).
     d. 5.7: nothing you touch changes; the two counterweight chains were decos (item 3).
     e. 5.2 (note 47, second half): the holds stay until the mask's features are measured; this
        file's mask is the same mask at the same size, so they still line up.
  7. Found while dressing, not on a page:
     a. The east wall: a5's slab for SHELL edge 13 (x -309 .. -306, y 382 .. 479) and the shared
        structure's well wall (st.json solid 35, x -310 .. -306, y 382 .. 474) are two faces in one
        place, and st's reaches 1 m into the temple's air (x -310 .. -309) from 382 to 474: the
        hood (line 60, x -313 .. -309) stands against it and the keeper's balcony EB ends at -309 in
        it. Suggest whoever owns the shared structure trims its wall to x -309 there (the temple's
        face of that wall is this file's `templo_east_wall` skin). The same at the exit: st's wall
        ends at 474 and a5's sill block (line 63) starts at -309.1.
     b. st.json's well cards (z -5, -4.1, -3.2, x -312 .. -288, y 170 .. 500) draw the well's back
        over the stretch `templo_well_back` models (y 390 .. 494): when it lands, the shared
        structure's owner cuts 390 .. 494 out of them (as a4's item 7b asks for 290 .. 390).
     c. mask_first_dog is made 9 x 10 x 2 and drawn at 21 m (scale 2.1), so it is 18.9 m wide where
        the page's face is 16: kept as it looks today (the page says so). Its mouth must be open
        through to the gullet (`templo_gullet` sits in it) and its jaw slots and eye sockets take the
        pieces set into them; if the kit mask's mouth is closed stone, that is the one change to it.
     d. _tick_respects measures an altar by its deco's `size`, not its `scale`: the sacrifice stone
        (scale 0.733) counts from 4.0 m of its middle, not 3.6. Harmless.
     e. The scale's beam (on the back wall, 457.8 at its east end) and the serpent's bed (from 457.6)
        overlap 0.2 m in height at x -354.8: the beam stands behind the bed (z -2.6 .. -2.2, the bed
        -2.2 .. -1.3), and the hanger slots stop at 457.5, under the bed (page 5.8: "its hangers stop
        below the bed").
  8. Movers', ropes' and holds' looks (the area file's; models in a5_models.md section 4, or a kit
     model to be re-made):
     - jade bands (Parker 11-13), each a re-make if the landed model lacks it: `temple_step` (a jade
       stripe down its front face, bronze along its bottom edge), `mask_jaw` (jade along its lip
       between the fangs, bronze shoes at its two ends), `temple_plunger` (jade round its top),
       `temple_piston` (its end dark bronze: the face that shoves; its top pale with a jade band),
       `temple_slab` (both pans: jade along the top edge, bronze ends, a shallow dish carved
       underneath), `temple_block` (jade along the top edge, a bronze shoe on its outer end),
       `serpent_segment` (re-made to 1.9 x 1.2: scales carved on top, a jade band along its top edge,
       a bronze shoe underneath where its ram meets it), `censer_l78` and `censer` (a jade band round
       the bowl, a gold lid; `censer`'s tassel five bronze bells with a jade bead at the end, 1.5 m);
     - `temple_gear` re-made (page 5.4): a greased dark disc 4.6 across with a jade rim band, a ring
       of small carved running dogs nose to tail round its face, a dark greased pug's face at the
       hub, and twelve HAMMER COGS each its own block in a socket with a bronze pin, pale dry stone on
       its front and outer end (the hold) and dark bronze on its two side faces (the bite);
     - `altar_cross` re-made (page 5.10): the outer 2 m of each arm edged in dark bronze, the inner
       arms plain stone, a jade ring round the hub and a pug boss on it;
     - the six bridge pieces (line 384, crumbling): `templo_bridge_slab` (pale stone cracked right
       through, a corner gone), named on each crumbling ledge as its look; the five cracked pegs (line
       390, brittle): `templo_peg_cracked`;
     - the serpent's tail (line 326): bronze links getting smaller toward the bottom and a carved
       stone tip on its last link, `templo_tail_tip`;
     - things that would move: the two pan hangers ride their pans:
       `A.follow("templo_pan_hanger", (-354.8, 454.6), "cw_a", "ride")` and
       `A.follow("templo_pan_hanger", (-360.75, 451.6), "cw_b", "ride")` after the dress call. The
       scale's beam (drawn at rest, east end up), the gullet's counterweight (it should go down as
       the jaw comes up) and the drum's mallet (it should lift before each count, hardest on the
       first: `a5_dress.MALLET`) stand still until the engine has a follow for them.
  9. Effects (the pages'; a5.py's A.effect, lines 491-496, stay): a false tier shaking and dropping a
     line of dust from its slot before it goes, a puff of dust on the worn dish when anything lands
     from the drain, a few of the garden's spores drifting in at the door and dying by the first
     torch (5.1); a slow drip from the upper teeth into the gullet, the jade eyes dimming and
     brightening slowly, dust from the jaw's slots before it starts up (5.2); a grind and a puff at a
     socket half a second before its piston goes back (note 48), dust from a track's stop when its
     piston hits it, grit trickling down the throat (5.3); a clank and a few sparks each time two
     bronze faces close at all three meshes, dust onto the bronze jaws, a drip of grease from the
     lowest wheel (5.4); two thin bars of gold torchlight through the gallery's slots onto the far
     wall, grit from the second champion's shoulders, a scrape and a long hiss down the ramp (5.5);
     the censer's smoke trail hanging for a few seconds so its swing is drawn in the air, embers at
     each end of the swing, a drip in the chain's shaft (5.6); the beam groaning and dust from its
     axle as it tips, light up through the slots, the first pan shaking once (5.7); the frog's croak,
     the two lamps flickering (5.0); a grind from the bed as each ram starts, a drip off each fang,
     dust from a slot when its ram tops out (5.8); the drum skin throwing dust on each stroke, a puff
     from each socket as its block goes in (5.9); the altar's bowl puffing when respects are paid
     (note 54: done, peak.gd), each slab shedding grit for its 3.5 s, a rush of air as an arm goes by
     (5.10); both great censers' smoke trails, embers drifting east, torch gold on the west sill and
     red from below on the east lip (5.11).
"""
import math

# ------------------------------------------------------------------ the lines things stand on
ENTRY = 366.0           # the entry floor (5.1)
BALCONY = 430.0         # the great hall's west balcony (5.5)
GALLERY = 453.0         # the gallery floor's top (5.7)
LEDGE = 455.0           # the exit ledge and the frog's floor (5.0)
THRESHOLD = 468.9       # the altar's threshold (5.9, 5.10)
SILL = 480.0            # the temple's sill over the well (5.11)

# The walls' faces (front z): each hall's back wall, the torches and sprigs hang on these.
ENTRY_FACE = -6.0       # the entry hall (5.1, 5.2)
SHAFT_FACE = -2.2       # the piston shaft (5.3)
GEAR_FACE = -2.8        # the gear room, and behind the west balcony (5.4, 5.5)
HALL_FACE = -9.0        # the great hall (5.5, 5.6)
ALCOVE_FACE = -3.0      # the keeper's alcove and the chain's shaft (5.6)
UPPER_FACE = -2.6       # the upper works: gallery, scale, serpent, stair (5.7, 5.0, 5.8, 5.9)
ALTAR_FACE = -3.4       # the altar chamber (5.10, 5.11)

STONE = "stone"         # stand-in tones
JADE = "#3FA88A"
BRONZE = "#8A5A2B"
GOLD = "gold"

# the great hall's ramp (a5.py's RAMP0, RAMP1)
_R0, _R1 = (-353.0, 429.0), (-318.0, 407.2)


def ramp_y(x):
    return _R0[1] + (x - _R0[0]) * (_R1[1] - _R0[1]) / (_R1[0] - _R0[0])


# The room's shell: the skin of each slab a5.py's A.cave makes for edge i of SHELL (FOR THE AREA
# FILE item 5a). Edges 12 (the exit door) and 14 (the entry door) are open.
SHELL_SKINS = {
    0: "templo_entry_floor",        # the entry floor: fitted paving, the worn dish under the drain
    1: "templo_chute",              # the chute under the platform: polished black, pale runs
    2: "templo_shaft_wall_west",    # the west wall from the chute to the head of the piston shaft
    3: "templo_gear_wall_west", 4: "templo_gear_wall_west",          # the gear room's west wall
    5: "templo_gear_roof",          # the gear room's roof
    6: "templo_west_wall",          # the great hall's west wall, on up past the scale and the serpent
    7: "templo_serpent_roof",       # the roof over the serpent
    8: "templo_stair_roof", 9: "templo_stair_roof",                  # the stair hall's roof
    10: "templo_altar_roof", 11: "templo_altar_roof",                # the altar chamber's roof
    13: "templo_east_wall",         # the temple's face of the well's west wall (item 7a)
}
# The same shell with the frog's room cut into the west wall (FOR THE AREA FILE item 6c).
SHELL_ROOM = [(-309, 366), (-342, 366), (-372, 385.5), (-372, 411), (-374.5, 414.5), (-374.5, 434),
              (-366, 434), (-366, 455), (-368.8, 455), (-368.8, 457), (-368.3, 457), (-368.3, 457.8),
              (-366.5, 457.8), (-366.5, 457), (-366, 457), (-366, 466.5), (-341, 466.5), (-341, 473),
              (-323.5, 473), (-323.5, 484), (-309, 484), (-309, 479), (-309, 382)]
SHELL_SKINS_ROOM = {0: "templo_entry_floor", 1: "templo_chute", 2: "templo_shaft_wall_west",
                    3: "templo_gear_wall_west", 4: "templo_gear_wall_west", 5: "templo_gear_roof",
                    15: "templo_serpent_roof", 16: "templo_stair_roof", 17: "templo_stair_roof",
                    18: "templo_altar_roof", 19: "templo_altar_roof", 21: "templo_east_wall"}
SHELL_SKINS_ROOM.update({e: "templo_west_wall" for e in range(6, 15)})   # the room cut in its skin

# Lights for a5.py (FOR THE AREA FILE item 2), filled by dress(): x, y (and z for the torches).
TORCHES = []
ALTAR_LIGHTS = [(-327.5, 470.62), (-310.5, 481.3)]
FROG_LAMPS = [(-368.38, 455.95), (-367.42, 455.95)]
MALLET = (-341.1, 466.0)        # the drum's mallet, its axle (item 8)

# 5.1: each tier's east edge and its top (a5_areas.py _TIERS); the three that slide.
_FALSE = [(-335.0, 371.0), (-341.0, 376.0), (-344.0, 378.5)]
# 5.3: the tops of the west wall's pistons and the east wall's.
_PW = [401.2, 403.6, 406.0, 408.4, 410.8]
_PE = [402.4, 404.8, 407.2, 409.6]
# 5.4: the heights of the three meshes (all at x -366.58).
_MESH = [418.38, 422.34, 426.3]
# 5.5: where each climbed champion's feet are.
_CHAMPS = [(-360.0, 430.0), (-347.0, 431.0), (-331.5, 433.0)]
# 5.8: the vertebrae's middles and the fangs.
_SERP = [-362.0 + 2.0 * i for i in range(9)]
_FANGS = [-360.0, -354.0, -348.0]
# 5.10: the joints of the bridge's six pieces.
_BX = [-323.5 + (9.1 / 6.0) * k for k in range(7)]


def dress(A):
    TORCHES.clear()

    # ------------------------------------------------------------ helpers
    def skin(stem, x0, x1, y0, y1, tone=STONE):
        """The look of course solids, filling them (z -1.2 .. 1.2)."""
        A.deco(stem, round((x0 + x1) / 2, 3), y0, z=0.0, size=(round(x1 - x0, 2), round(y1 - y0, 2), 2.4), tone=tone, skin=True)

    def back(stem, x0, x1, y0, y1, z_near, z_far, tone="back2"):
        """A piece behind the play space, from z_near back to z_far (origin: the middle of its foot)."""
        A.deco(stem, round((x0 + x1) / 2, 3), y0, z=round((z_near + z_far) / 2, 3), size=(round(x1 - x0, 2), round(y1 - y0, 2), round(z_near - z_far, 2)), tone=tone)

    def torch(x, y, face):
        """The kit's torch in a bronze bracket (made 0.4 x 1.4 x 0.4) on a wall whose face is at z
        `face` (origin: the middle of its foot, its back on the wall). The game lights its fire."""
        z = round(face + 0.2, 3)
        A.deco("torch_wall", x, y, z=z, size=(0.4, 1.4, 0.4), tone=GOLD)
        TORCHES.append((x, y, z))

    def banner(x, top, face):
        """The kit's cut-paper banner (made 1.58 x 4.96, hung from its rod) at 0.6: 0.95 by 3 m,
        whole and bright, hung high on a wall (origin: the middle of its foot)."""
        A.deco("temple_banner", x, round(top - 2.98, 2), z=round(face + 0.06, 3), scale=0.6, size=(1.58, 4.96, 0.11), tone="accent")

    def plaque(x, y, w, face):
        """The kit's stone pug plaque (made 0.9 across, 0.1 thick), w metres across, on a wall."""
        A.deco("pug_mask", x, y, z=round(face + 0.05 * w / 0.9, 3), scale=round(w / 0.9, 3), size=(0.9, 0.9, 0.1), tone=STONE)

    def arch(x, y, face, s=1.0):
        """A stepped arch doorway: two sides stepping in to a flat lintel, dark inside, its frame pale
        carved stone (made 3.0 wide, 4.5 tall, 1.0 deep; its back on the wall)."""
        A.deco("templo_arch_door", x, y, z=round(face + 0.5 * s, 3), scale=s, size=(3.0, 4.5, 1.0), tone="back3")

    def boss(x, y_top, z=-1.75, s=1.0):
        """A chain boss: a carved pug with a bronze ring in its mouth, reaching the ring forward
        (made 0.9 x 0.9 x 0.6; origin: the middle of its top, on the ceiling or beam it hangs from)."""
        A.deco("templo_chain_boss", x, y_top, z=z, scale=s, size=(0.9, 0.9, 0.6), tone=STONE)

    def cheeks(x, y, z, s=1.0):
        """Axle cheeks and a stone axle: two carved cheeks with the axle's end between (made 1.4 x
        1.4 x 0.6)."""
        A.deco("templo_axle_cheeks", x, y, z=z, scale=s, size=(1.4, 1.4, 0.6), tone=STONE)

    def column(x, y, z, s=1.0):
        """A square carved column with a pug capital (made 1.7 over the capital, 4.5 tall, 1.2 deep)."""
        A.deco("templo_column", x, y, z=z, scale=s, size=(1.7, 4.5, 1.2), tone=STONE)

    def column_base(x, y, s=1.0):
        """Foreground: a column's base, its top level with or below the floor behind it (made 1.5
        wide, 1.45 tall, 0.6 deep), its back at z 1.3."""
        A.deco("templo_column_base", x, y, z=round(1.3 + 0.3 * s, 3), scale=s, size=(1.5, 1.45, 0.6), tone=STONE)

    def forearm(x, y, z, rot=0.0):
        """A champion's broken forearm, 1.9 m of carved stone with a rough old break at each end,
        lying where it fell (made 1.9 x 0.5 x 0.6)."""
        A.deco("templo_forearm_broken", x, y, z=z, rot=rot, size=(1.9, 0.5, 0.6), tone=STONE)

    def sprig(x, y, face):
        """A small block standing proud of a back wall (a fallen corner of carving), and on it the
        temple's own flat painted plant: a dry offering sprig."""
        A.deco("templo_ledge_block", x, y, z=round(face + 0.2, 3), size=(0.9, 0.45, 0.4), tone="back2")
        A.deco("templo_offering_sprig", x, round(y + 0.45, 2), z=round(face + 0.25, 3), size=(0.5, 0.45, 0.04), tone=GOLD)

    def niche(x, y, face, s=1.0):
        """An offering niche: a small square niche holding a bone and a jade bead (made 0.6 x 0.6 x
        0.3, set into the wall, its front on the face)."""
        A.deco("templo_offering_niche", x, y, z=round(face - 0.15 * s, 3), scale=s, size=(0.6, 0.6, 0.3), tone="back3")

    # ============================================================ the shell (every hall's skin)
    # Each piece painted for its place (FOR THE AREA FILE item 5a): pale fitted stone where it is
    # held, polished black with pale runs where it is not.
    skin("templo_entry_floor", -342.02, -308.98, 363.0, 366.0)                  # the dish under the drain drawn on it (x -318 .. -313)
    skin("templo_chute", -373.65, -341.98, 363.47, 385.51, tone="slick")
    skin("templo_shaft_wall_west", -377.3, -372.0, 385.48, 411.4, tone="slick")  # with the rock behind the west sockets (line 183)
    skin("templo_gear_wall_west", -377.5, -371.99, 409.24, 434.02, tone="slick")
    skin("templo_gear_roof", -374.52, -365.98, 434.0, 437.0, tone="slick")
    skin("templo_west_wall", -369.0, -366.0, 433.98, 466.52, tone="slick")      # the frog's room cut in it (item 6c)
    skin("templo_serpent_roof", -369.0, -340.98, 466.5, 469.5, tone="slick")
    skin("templo_stair_roof", -344.0, -323.48, 466.48, 476.0, tone="slick")
    skin("templo_altar_roof", -326.5, -308.98, 472.98, 487.0, tone="slick")
    skin("templo_east_wall", -309.0, -306.0, 381.98, 479.02, tone="slick")

    # ============================================================ 5.1 La Puerta
    # The entry hall's back wall (also 5.2's hall end wall): wall bays of pale fitted blocks painted
    # in long courses, the carved band at 371.8, 377.6 and 383.4, 6 m back in brown shadow; it runs the
    # whole width and out of the top (note 51): its top follows the great hall's ramp's underside
    # ((-357.2, 425.8) down to (-318, 404)), level at 426 west of x -357.2 behind the pier, the shaft
    # and the mask; open over the drain's slot (x -318 .. -313), where the fall strip goes on up.
    back("templo_entry_back_wall", -372.0, -309.0, ENTRY, 426.0, -6.0, -7.0, tone="back3")
    # The paving carried back to the wall, the chute's polished slope carried back under the platform.
    back("templo_floor_back", -342.0, -309.0, 363.0, ENTRY, -1.25, -6.0, tone="rock2")
    back("templo_chute_back", -372.0, -342.0, 363.0, 385.5, -1.25, -6.0, tone="back")
    # Two stepped arch doorways, a stone pug plaque over each and a banner high above (the low string
    # of cut paper and the 6 m mask go).
    for x in (-327.5, -321.5):
        arch(x, ENTRY, ENTRY_FACE)
        plaque(x, 372.55, 1.5, ENTRY_FACE)
        banner(x, 382.2, ENTRY_FACE)
    # The fall strip, lower run: a carved strip 5 m wide of bones tumbling, up the back wall behind
    # the drain's landing and out of the top (the upper run is 5.6's, on the great hall's far wall).
    back("templo_fall_strip_low", -318.0, -313.0, ENTRY, 404.0, -5.6, -6.0, tone=STONE)
    # Three broken forearms at its foot, lying back against the wall (two flat, one across them).
    forearm(-316.8, ENTRY, -2.6)
    forearm(-314.4, ENTRY, -2.2, rot=-2.0)
    forearm(-316.05, 366.45, -2.4, rot=14.0)
    # The platform the mask sits on: its body right behind the tiers, each tier the front edge of a
    # terrace running 4 m back; on its face under each tier the carved band; its foot follows the
    # chute; three slots cut along its face where the slot linings sit (made in place).
    back("templo_platform", -354.0, -332.0, ENTRY, 381.0, -1.3, -5.5, tone=STONE)
    # The three slots the false tiers ride in, lined with bronze: 5.7 m long, the 3 m the tier fills
    # and 2.6 m of empty channel west of it, which shows how far it goes.
    for x, top in _FALSE:
        A.deco("templo_tier_slot", round(x - 2.85, 2), round(top - 1.1, 2), z=-1.825, size=(5.7, 1.15, 1.15), tone=BRONZE)
    # The true tiers and the landing: their fronts carved deep and pale, pug faces and belts, bonded
    # into the platform (skins); the chute's polish is on its skin.
    skin("templo_tier_true", -335.0, -332.0, 367.5, 368.5)
    skin("templo_tier_true", -341.0, -338.0, 372.5, 373.5)
    skin("templo_landing", -354.0, -347.0, 380.0, 381.0)
    # The door through the well's wall (the join, 4 to 5): the doorway's side, the same pale blocks,
    # its head stepping out to carry the beam; the doorstep (skin: moss in its joints and three pale
    # bell sprouts drawn on it, the garden's); the beam and its corbel (skin), a chain boss under it
    # at each chain; and one thick root of the garden's lying in the joints of the first blocks
    # (a4's flat root at 0.45, origin its top).
    back("templo_door_side", -309.0, -305.5, ENTRY, 382.0, -1.25, -3.0, tone=STONE)
    skin("templo_door_sill", -309.1, -304.0, 362.0, ENTRY)
    skin("templo_banner_beam", -310.0, -300.9, 379.7, 384.2)
    boss(-303.0, 379.7)
    boss(-301.5, 379.7)
    A.deco("jardin_root_flat", -305.8, 369.5, z=-1.34, rot=-50.6, scale=0.45, size=(0.7, 8.5, 0.4), tone="root")
    # The hood over the door (skin): polished black, the drain's east side.
    skin("templo_hood", -313.0, -309.0, 384.0, 414.0, tone="slick")
    # Torches: four on the back wall along the floor; the fifth on the platform's face, in a shallow
    # torch niche cut into it (its face is 1.3 m behind: page 5.1 asks for both).
    for x, y in ((-324.5, 369.0), (-311.5, 369.0), (-319.6, 371.0), (-330.0, 369.0)):
        torch(x, y, ENTRY_FACE)
    torch(-336.5, 368.0, -1.75)
    sprig(-340.0, 383.0, ENTRY_FACE)
    sprig(-311.8, 375.5, ENTRY_FACE)
    # Foreground: the low balustrade along the paving's front edge, a step down, its top below the floor.
    A.deco("templo_balustrade", -321.0, 364.9, z=1.45, size=(20.0, 0.8, 0.3), tone=STONE)

    # ============================================================ 5.2 La Mascara
    # (The hall's end wall is 5.1's back wall.) The great mask (the kit's, made 9 x 10 x 2, drawn at
    # 21 m as today): terracotta, jade and cream, the ears and crown above the brow; set back so its
    # whole face is 1.3 m behind you (FOR THE AREA FILE items 3 and 7c). Origin: its chin's bottom.
    A.deco("mask_first_dog", -358.15, 380.2, z=-3.4, scale=2.1, size=(9.0, 10.0, 2.0), tone="accent")
    # The gullet in its open mouth: black inside, a stepped throat going back and down to the chute;
    # far back in it the jaw's counterweight, a 1 m stone block on a thick bronze chain.
    A.deco("templo_gullet", -358.15, 380.2, z=-3.5, size=(4.7, 8.4, 3.0), tone="back3")
    A.deco("counterweight_hung", -358.15, 386.4, z=-4.2, scale=0.62, size=(1.6, 1.71, 1.0), tone="iron")   # origin: its hanging point
    A.deco("counterweight_chain", -358.15, 387.5, z=-4.2, size=(0.32, 2.2, 0.32), tone="iron")         # (stretched to its span; origin its middle)
    # The jaw's two slots, one either side of the mouth, lined with bronze, 6.5 m tall.
    for x in (-360.775, -355.525):
        A.deco("templo_jaw_slot", x, 379.8, z=-1.65, size=(0.45, 6.5, 0.8), tone=BRONZE)
    # The two jade eyes in the sockets, lit from inside (a5.py's jade lights).
    for x in (-362.2, -354.2):
        A.deco("templo_jade_eye", x, 394.05, z=-1.9, size=(0.7, 0.7, 0.3), tone=JADE)
    # The holds (skins): bone white with gold tips, rims and lines, each on a stem out of the face.
    skin("templo_mask_lip", -359.7, -356.7, 388.6, 389.3, tone="bone")
    for tx in (-359.3, -358.2, -357.1):
        skin("templo_mask_tooth", tx - 0.25, tx + 0.25, 387.6, 388.65, tone="bone")
    for x, y in ((-358.9, 391.1), (-357.5, 391.1)):
        skin("templo_mask_ring", x - 0.25, x + 0.25, y - 0.25, y + 0.25, tone="bone")
    for x, y in ((-356.1, 392.3), (-360.3, 392.3)):
        skin("templo_mask_stud", x - 0.25, x + 0.25, y - 0.25, y + 0.25, tone="bone")
    skin("templo_mask_lid", -355.4, -353.0, 393.1, 393.6, tone="bone")
    skin("templo_mask_lid", -363.4, -361.0, 393.1, 393.6, tone="bone")
    skin("templo_mask_brow", -366.5, -354.2, 395.2, 396.4, tone="bone")
    # Torches: two on the wall east of the mask, one west of it.
    for x, y in ((-348.0, 384.0), (-348.0, 393.0), (-368.6, 391.0)):
        torch(x, y, ENTRY_FACE)

    # ============================================================ 5.3 Los Pistones
    # The shaft's back wall: fitted blocks a shade browner than the bolts, 2.2 m behind you, dry and
    # carved, down behind the throat, east under the pier behind the walk (the carved band along its
    # top, 399.2 .. 400) and up to the gear room (note 51).
    back("templo_shaft_back_wall", -374.5, -354.0, 390.0, 412.0, -2.2, -2.7, tone="back2")
    # The brow walk carried back to it under the pier.
    back("templo_brow_back", -366.5, -354.2, 395.2, 396.4, -1.25, -2.2, tone=STONE)
    # Nine tracks: each piston's back half runs in a bronze-lined track across the back wall, ending
    # in a bronze stop exactly where that piston's tip stops (the east ones flipped).
    for t in _PW:
        A.deco("templo_piston_track", -370.4, round(t - 0.95, 2), z=-1.725, size=(3.2, 1.0, 0.95), tone=BRONZE)
    for t in _PE:
        A.deco("templo_piston_track", -368.1, round(t - 0.95, 2), z=-1.725, flip=True, size=(3.2, 1.0, 0.95), tone=BRONZE)
    # The plunger's guide: a slot 3.6 m taller than the plunger; the empty part shows its lift.
    A.deco("templo_plunger_guide", -367.65, 392.4, z=-1.725, size=(1.3, 7.7, 0.95), tone=BRONZE)
    # An offering niche beside the plunger at head height.
    niche(-365.3, 397.6, SHAFT_FACE)
    # The walls (skins: edge 2's and the pier's) are the only polished black in the shaft; the pier
    # and its cornice, the shaft's last step.
    skin("templo_pier", -366.5, -357.2, 400.0, 429.0, tone="slick")
    skin("templo_pier_cornice", -368.2, -360.2, 411.1, 412.0)
    # Torches: one over the throat, one under the pier, one at the head of the shaft; none between
    # the tracks.
    for x, y in ((-370.4, 396.8), (-359.0, 397.2), (-370.6, 412.6)):
        torch(x, y, SHAFT_FACE)

    # ============================================================ 5.4 Engranajes
    # The gear room's back wall, 2.8 m behind you, browner than the cogs, the carved band at three
    # heights; at its top right it carries on east behind the west balcony (x -366 .. -352.5, to 437,
    # its top a cornice with its shadow painted, the great hall's far wall beyond).
    back("templo_gear_back_wall", -374.5, -352.5, 408.5, 437.0, -2.8, -3.4, tone="back2")
    # The pier's top carried back, where the east post stands.
    back("templo_pier_top_back", -368.2, -360.2, 411.1, 412.0, -1.25, -2.8, tone=STONE)
    # Two square carved posts from floor to roof, pug capitals, two pairs of axle cheeks each, black
    # runs of grease down them from every axle; the west one stands on a stepped corbel over the open
    # shaft (its foot is in the model): the east post carries wheels 1 and 3, the west 2 and 4.
    A.deco("templo_gear_post", -368.56, 411.9, z=-1.95, size=(1.9, 22.1, 1.3), tone=STONE)
    A.deco("templo_gear_post", -364.6, 412.0, z=-1.95, size=(1.9, 22.1, 1.3), tone=STONE)
    # Three bronze jaws: a dark bronze plate cast as a pug's open jaws behind each mesh.
    for y in _MESH:
        A.deco("templo_bronze_jaws", -366.58, round(y - 0.9, 2), z=-1.5, size=(2.8, 1.8, 0.4), tone=BRONZE)
    # The grease shelf low in the west corner: an offering niche, and a stone trough of black grease
    # with a long ladle on a stone shelf (origin: the middle of its foot line on the wall).
    niche(-373.6, 413.4, GEAR_FACE)
    A.deco("templo_grease_trough", -372.1, 413.4, z=-2.5, size=(1.6, 1.2, 0.6), tone="back")
    for x, y in ((-373.5, 423.9), (-361.0, 419.9), (-362.5, 431.2)):
        torch(x, y, GEAR_FACE)
    sprig(-373.2, 419.0, GEAR_FACE)

    # ============================================================ 5.5 El Salon de los Campeones
    # The great hall's far wall (also 5.6's): wall bays from the ramp to the roof, 9 m back, brown
    # with shadow, the carved band at three heights; on east behind the keeper's balcony and the
    # chain to the well's wall (note 51); left plain behind the censer's swing (5.6).
    back("templo_hall_far_wall", -366.0, -309.0, 404.0, GALLERY, HALL_FACE, -10.0, tone="back3")
    # The ramp carried back to it: polished black with long pale scrapes, the lower hall's ceiling
    # painted on its underside; the gallery floor carried back over it as the hall's roof, the two
    # slots cut through all the way back (the far wall shows through them).
    back("templo_ramp_back", -357.2, -318.0, 404.0, 429.0, -1.25, HALL_FACE, tone="back")
    back("templo_gallery_back", -352.0, -312.8, 450.0, GALLERY, -1.25, HALL_FACE, tone="back2")
    # The west balcony carried back to the wall behind it.
    back("templo_balcony_back", -365.0, -353.0, 429.0, BALCONY, -1.25, GEAR_FACE, tone=STONE)
    skin("templo_balcony", -365.0, -353.0, 429.0, BALCONY)
    skin("templo_hall_ramp", -357.2, -318.0, 404.0, 429.0, tone="slick")
    # The far rank: two champions the same size and stone, arms down and whole, belts at the waist,
    # in tall stepped niches, browner; a banner over each, torches either side of each niche.
    for x, y in ((-353.5, 431.5), (-339.5, 432.0)):
        A.deco("templo_niche_tall", x, y, z=-8.25, size=(4.2, 10.0, 1.5), tone="back3")
        A.deco("templo_champion_still", x, y, z=-8.3, size=(3.2, 9.0, 1.2), tone="back")
        banner(x, 449.8, HALL_FACE)
    for x, y in ((-356.4, 436.0), (-350.6, 436.0), (-342.4, 436.4), (-336.6, 436.4)):
        torch(x, y, HALL_FACE)
    torch(-364.4, 432.0, GEAR_FACE)          # on the balcony, on the wall behind it
    # The three champions (skins, a re-make of statue_champion_reach): the first and third with the
    # east forearm gone (the whole west arm, the east stump to the elbow, the gilded hand on the
    # belt); the second with both arms gone (two shoulder stumps, a stone west hand, a gilded east
    # hand). Origin between the feet. FOR THE AREA FILE items 5b and 6b.
    A.deco("templo_champion_broken", -360.0, 430.0, z=0.0, size=(8.4, 8.7, 2.4), tone=STONE, skin=True)
    A.deco("templo_champion_handless", -347.0, 431.0, z=0.0, size=(8.4, 8.7, 2.4), tone=STONE, skin=True)
    A.deco("templo_champion_broken", -331.5, 433.0, z=0.0, size=(8.4, 8.7, 2.4), tone=STONE, skin=True)
    # The three belts, held overhead: a stone band 8.4 m long and 0.9 tall with a round bronze plate
    # in the middle, on a square pillar up the champion's back, just behind the play space; browner
    # than the statues. Origin: the foot of its pillar, between the champion's feet.
    for sx, fy in _CHAMPS:
        A.deco("templo_belt_held", sx, fy, z=-1.6, size=(8.4, 8.8, 0.6), tone="back")
    # The two great pilasters rising from the ramp behind you, stepped heads reaching forward to carry
    # the plinths (skins); their feet cut to the ramp's 32 degrees (origin: the middle of the x span
    # at the shaft's east foot on the ramp). The third's is 5.6's last solid thing before the drain.
    A.deco("templo_pilaster_short", -347.0, round(ramp_y(-345.7), 2), z=-1.95, size=(3.8, 5.4, 1.3), tone=STONE)
    A.deco("templo_pilaster_tall", -331.5, round(ramp_y(-330.2), 2), z=-1.95, size=(3.8, 17.0, 1.3), tone=STONE)
    skin("templo_plinth", -348.3, -345.7, 429.8, 431.0)
    skin("templo_plinth", -332.8, -330.2, 431.8, 433.0)
    # The first champion's forearm on the balcony behind its feet, against the wall.
    forearm(-357.65, BALCONY, -2.0)
    sprig(-362.8, 444.6, HALL_FACE)
    sprig(-345.5, 443.8, HALL_FACE)

    # ============================================================ 5.6 Incensarios
    # (The far wall and the last pilaster are 5.5's.) The fall strip's upper run: from the censer's
    # height down the far wall behind the drain's mouth (the same strip as at the door); a large stone
    # pug looking down the drain beside it.
    back("templo_fall_strip_high", -318.0, -313.0, 404.0, 436.0, -8.6, HALL_FACE, tone=STONE)
    plaque(-321.0, 411.4, 3.2, HALL_FACE)
    # The keeper's alcove: the balcony carried back to a wall 3 m behind it, a stepped doorway in it
    # with two incense jars and a long ladle beside it; and the chain's shaft above it to the stone
    # over the shaft at 457, the shaft's wall lit.
    back("templo_keeper_alcove", -312.8, -309.0, 442.7, 457.0, -1.25, ALCOVE_FACE, tone="back2")
    skin("templo_keeper_balcony", -312.8, -309.0, 442.7, 443.6)
    arch(-310.6, 443.6, ALCOVE_FACE, s=0.9)
    A.deco("templo_incense_jars", -312.4, 443.6, z=-2.6, size=(0.7, 2.0, 0.6), tone=BRONZE)
    # Two chain bosses: over the censer under the hall's roof, and under the stone above the shaft.
    boss(-320.0, 450.0)
    boss(-311.0, 457.0)
    # Torches: by the last champion, either side of the swing and well clear of it, in the shaft,
    # and low by the drain so the drop is lit.
    for x, y in ((-334.6, 437.2), (-325.4, 444.4), (-314.4, 444.8), (-320.5, 408.6)):
        torch(x, y, HALL_FACE)
    torch(-309.8, 450.6, ALCOVE_FACE)

    # ============================================================ 5.7 El Contrapeso (and the gallery)
    # The upper works' back wall (also 5.0's, 5.8's and 5.9's): wall bays behind the gallery, the
    # open west end, the serpent and the stair, without a break (note 51); its lower edge at the
    # gallery's level, over the open west end a cornice with its shadow painted (the great hall's far
    # wall below it); its top under the serpent's roof (466.5) west of x -341, 473 from there to x -332,
    # and 457.5 east of that, under the spine (the pit's wall above is the altar chamber's); behind
    # the serpent the blocks carved in shallow relief with its coils and scales, browner than the
    # spine; the carved band high over the stair (471.6 .. 472.4) and nowhere near the scale.
    back("templo_upper_back_wall", -366.0, -323.5, 450.0, 473.0, UPPER_FACE, -3.2, tone="back2")
    # The gallery floor's three runs (skins): pale and carved right up to each slot's edge, the slots'
    # inside faces polished black (note 52); the last edge west carved deep and pale on its end face.
    skin("templo_gallery_floor_a", -352.0, -337.92, 450.0, GALLERY)
    skin("templo_gallery_floor_b", -336.68, -327.92, 450.0, GALLERY)
    skin("templo_gallery_floor_c", -326.68, -312.8, 450.0, GALLERY)
    # The scale: a stone beam on an axle between two carved cheeks, a pug boss on the axle's end,
    # drawn as it rests (east end up); browner than the pans. Origin: the axle.
    A.deco("templo_scale_beam", -357.78, 456.0, z=-2.4, rot=26.8, size=(6.6, 0.6, 0.4), tone="back")
    cheeks(-357.78, 454.8, -1.75, s=1.57)
    # Two hanger slots in the back wall, bronze-lined, as long as each pan's travel; the stone hangers
    # running in them, one on each pan (they ride their pans: item 8).
    for x in (-354.8, -360.75):
        A.deco("templo_hanger_slot", x, 450.8, z=-1.65, size=(0.5, 6.7, 0.8), tone=BRONZE)
    A.deco("templo_pan_hanger", -354.8, 454.6, z=-1.6, size=(0.4, 2.6, 0.4), tone=STONE)
    A.deco("templo_pan_hanger", -360.75, 451.6, z=-1.6, size=(0.4, 2.6, 0.4), tone=STONE)
    # The gallery's columns along the back, three doorways between them and one plaque; torches on
    # the columns and one on the west wall over the ledge.
    for x in (-349.0, -343.0, -332.3, -325.3, -317.0):
        column(x, GALLERY, -2.7)
    for x in (-346.0, -339.9, -328.8):
        arch(x, GALLERY, UPPER_FACE, s=0.889)
    plaque(-335.0, 454.65, 1.5, UPPER_FACE)
    for x in (-349.0, -343.0, -332.3, -325.3):
        torch(x, 455.0, -2.1)                # on the column's front
    torch(-364.8, 457.0, UPPER_FACE)
    # Foreground: a column's base opposite each column, in front of the gallery floor, its top level
    # with the floor; none in front of a slot.
    for x in (-349.0, -343.0, -332.3, -325.3):
        column_base(x, 451.5)

    # ============================================================ 5.0 The frog's room
    # The exit ledge carried back (skin: four small jade paw prints inlaid in its top lead to the door).
    skin("templo_exit_ledge", -366.0, -362.3, 454.2, LEDGE)
    back("templo_ledge_back", -366.0, -362.3, 454.2, LEDGE, -1.25, UPPER_FACE, tone=STONE)
    # The shrine, cut into the west wall (item 6c), cut away at the front: fitted pale blocks, the
    # back wall 2.4 m behind you, the stepped roof, its two side walls with stone shelves of small
    # carved pugs running round them; the doorway's frame carved pale.
    back("templo_frog_shrine", -368.8, -366.0, LEDGE, 457.8, -1.25, -2.4, tone=STONE)
    # On the back wall: the offering table under an empty stepped niche where the shrine's own pug
    # should be, the frog on the table facing out, two small lamps either side of it; two shelves of
    # small carved pugs east of the niche (dozens, each different, some with a jade bead or a scrap of
    # cut paper: the offerings of everyone who came this far).
    A.deco("templo_offering_table", -367.9, LEDGE, z=-1.9, size=(1.2, 0.8, 0.6), tone=STONE)
    niche(-367.9, 455.8, -2.4, s=1.67)
    A.deco("frog_sit", -367.9, 455.8, z=-1.9, size=(0.26, 0.26, 0.27), tone="accent")
    for x, y in FROG_LAMPS:
        A.deco("templo_lamp_small", x, 455.8, z=-1.9, size=(0.2, 0.25, 0.2), tone=GOLD)
    A.deco("templo_pug_shelves", -366.75, 456.2, z=-2.2, size=(1.3, 1.2, 0.4), tone=STONE)   # origin: the middle of its foot line on the wall
    # (The torch over the ledge is 5.7's.)

    # ============================================================ 5.8 La Serpiente
    # The serpent's bed: a carved beam 19 m long fixed to the back wall under the spine, scales on its
    # face and a belt of small pug faces along its top edge; at its west end the roller's axle in its
    # cheeks (what works the rams).
    A.deco("templo_serpent_bed", -353.45, 457.6, z=-1.75, size=(18.9, 1.2, 0.9), tone=STONE)
    cheeks(-363.25, 457.3, -1.75)
    # Nine ram slots up the back wall behind the vertebrae, bronze-lined, each as tall as its rise.
    for cx in _SERP:
        A.deco("templo_ram_slot", cx, 458.8, z=-1.85, size=(0.6, 4.7, 1.0), tone=BRONZE)
    # Three small serpent heads looking down out of the wall under the roof, mouths open, each fang
    # its one great tooth (the fangs are skins).
    for fx in _FANGS:
        A.deco("templo_serpent_head_down", fx, 464.9, z=-1.95, size=(2.6, 1.6, 1.3), tone=STONE)
        skin("templo_fang", fx - 0.8, fx + 0.8, 463.5, 466.6, tone="slick")
    # The serpent's own head on the ledge at the east end (also 5.9's), against the back wall,
    # looking back down its spine with jade eyes (the kit's at 1.1, its top under the drum's shelf).
    A.deco("serpent_head", -342.8, 461.7, z=-2.125, scale=1.1, size=(2.5, 2.0, 1.5), tone="accent")
    skin("templo_head_ledge", -344.0, -340.0, 461.1, 461.7)
    # The tail's boss at the spine's west end, the tail chain hanging from its ring; the tail ledge.
    boss(-363.5, 460.5, s=0.9)
    skin("templo_tail_ledge", -366.0, -364.0, 459.6, 460.2)
    for x in (-357.0, -351.0, -345.4):
        torch(x, 464.5, UPPER_FACE)

    # ============================================================ 5.9 Bloques Fantasma
    # The spine of the upper works (skin): the head's ledge, the stair's ramp polished black with pale
    # scrapes and the five block sockets drawn on its face (carved pale frames round dark mouths), the
    # big face under the stair the same black in tight fitted blocks, and the threshold's body.
    skin("templo_stair_ramp", -344.0, -323.5, 457.5, 467.7, tone="slick")
    skin("templo_threshold", -331.5, -323.5, 467.7, THRESHOLD)          # the ring of jade paw prints drawn on it (note 54)
    # It carried back: the head's ledge, the stair and the threshold to the back walls.
    back("templo_spine_back", -344.0, -323.5, 457.5, THRESHOLD, -1.25, ALTAR_FACE, tone="back")
    # The temple drum on a stone shelf over the serpent's head (the kit's at 0.85: 1.36 across, 1.5
    # tall), the stone arm with the bone mallet on its axle between two cheeks (origin: the axle).
    A.deco("templo_drum_shelf", -342.5, 463.9, z=-1.95, size=(2.2, 0.3, 1.3), tone=STONE)
    A.deco("drum_temple", -342.5, 464.2, z=-1.98, scale=0.85, size=(1.6, 1.8, 1.6), tone="accent")
    A.deco("templo_mallet_arm", MALLET[0], MALLET[1], z=-1.9, rot=12.5, size=(1.0, 0.4, 0.4), tone="bone")
    cheeks(-341.1, 465.6, -2.15, s=0.6)
    torch(-346.0, 462.8, UPPER_FACE)
    torch(-336.4, 469.6, UPPER_FACE)
    sprig(-338.6, 470.0, UPPER_FACE)

    # ============================================================ 5.10 El Altar
    # The chamber's back wall (also 5.11's temple side): wall bays from the bottom of the pit (the
    # gallery) to the roof, 3.4 m back, carried down the pit so the drop is a lit wall (note 51); the
    # carved band high on it level with the sill (482.2 .. 483), plain as everywhere.
    back("templo_altar_back_wall", -333.5, -309.0, GALLERY, 484.0, ALTAR_FACE, -4.0, tone="back2")
    # The sun stone: a carved disc 9.4 m across behind the cross, rings of small pugs, belts and bones
    # round a centre, shallow and brown; the cross's two cheeks standing out of its centre.
    A.deco("templo_sun_stone", -318.0, 469.7, z=-3.0, size=(9.4, 9.4, 0.8), tone="back")
    cheeks(-318.0, 473.0, -1.9, s=2.0)
    # The altar in its stepped niche at the top of the stair (the kit's `altar`: the First Top Dog's
    # face on its front, a bronze bowl of coals on top; it counts for note 54), two columns either side.
    A.deco("templo_altar_niche", -327.5, THRESHOLD, z=-2.35, size=(4.4, 3.9, 2.1), tone="back3")
    A.deco("altar", -327.5, THRESHOLD, z=-2.05, size=(3.0, 1.5, 1.5), tone=STONE)
    for x in (-331.0, -324.2):
        column(x, THRESHOLD, -1.95, s=0.91)
    # Seven stepped brackets under the bridge's joints; the slabs lie on them (item 8).
    for bx in _BX:
        A.deco("templo_bracket", round(bx, 3), 467.9, z=-1.85, size=(0.5, 0.5, 1.1), tone=STONE)
    # The peg wall (skin): polished black between the pegs; the three sound pegs (skins: a carved
    # pug's nose on a stone stem); the five cracked are item 8's.
    skin("templo_peg_wall", -312.5, -309.0, 457.0, 479.3, tone="slick")
    for y in (469.4, 470.8, 472.2):
        skin("templo_peg", -312.94, -312.5, y - 0.25, y + 0.25)
    # One banner, whole and bright, high in the west corner, far from the pegs.
    banner(-322.4, 483.6, ALTAR_FACE)
    for x, y in ((-313.9, 470.4), (-313.9, 476.6), (-322.7, 469.6), (-318.0, 463.0)):
        torch(x, y, ALTAR_FACE)
    torch(-332.4, 470.4, UPPER_FACE)         # by the west column, on the upper works' wall
    sprig(-319.0, 480.6, ALTAR_FACE)

    # ============================================================ 5.11 El Sacrificio (5 to 6)
    # The well (the mountain's shared structure, this stretch of it, 390 to 494; a4_dress.py has it
    # below): the round back of the shaft, 7 m back at the middle; below the sills the well's own
    # rough rock stepping back into the dark with a few wet glints far down, from the sills up the
    # temple's fitted blocks; the far rim (479.9) dark and far back so it never reads as a floor.
    back("templo_well_back", -306.0, -294.0, 390.0, 494.0, -1.25, -7.0, tone="back3")
    # The stepped vault roofing the well's mouth: two corbel steps in from each side (1 m and 0.8 m)
    # to the flat cap (st's solid); the keystone pug 3.4 m across under the cap, between the chains.
    back("templo_well_vault", -306.0, -294.0, 489.6, 494.0, -1.25, -6.0, tone=STONE)
    plaque(-300.0, 489.5, 3.4, -7.0)
    # The two great chain bosses, the same boss at its large size (1 m).
    boss(-303.0, 494.0, z=-1.8, s=1.11)
    boss(-297.075, 494.0, z=-1.8, s=1.11)
    # The temple's side: the sill (skin: pale carved stone, a worn notch at its very end where the
    # first tassel comes to hand, the ring of jade paw prints before the stone), carried back; the
    # exit's sill block and lintel (skin); the doorway's side through the well's wall behind them.
    skin("templo_sill", -312.5, -305.6, 479.2, SILL)
    back("templo_sill_back", -312.5, -305.6, 479.2, SILL, -1.25, -4.0, tone=STONE)
    skin("templo_exit_door", -309.1, -306.0, 474.0, 488.2, tone="slick")
    back("templo_exit_door_side", -309.0, -305.5, SILL, 484.0, -1.25, -4.0, tone=STONE)
    # The sacrifice stone, the temple's second altar: a low stone 2.2 m wide with a bronze bowl, in a
    # stepped niche on the sill (the kit's `altar` at 0.733: it counts for note 54).
    A.deco("templo_sacrifice_niche", -310.5, SILL, z=-2.0, size=(3.0, 3.4, 1.4), tone="back3")
    A.deco("altar", -310.5, SILL, z=-1.85, scale=0.733, size=(3.0, 1.5, 1.5), tone=STONE)
    torch(-312.7, 481.2, ALTAR_FACE)
    # Foreground: a column base at the bottom edge of the frame, in front of the rock under the sill.
    column_base(-311.0, 474.5, s=1.2)
    # (East of the well, the forge's side, is a6's: page 6.1.)
