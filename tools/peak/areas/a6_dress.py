"""
LA CHIMENEA, DRESSED: the scenery of all of biome 6, the chimney and the forge (y 476 to 590), from
the ten area pages (the smith's hut 6.0 and the nine challenges, with the crack to daylight 6.9,
the way out to the cliffs) in docs/peak/playtest/design/data/a6_areas.py and the biome's sheet
a6_biome.py (its `built`, `light`, `looks`, `layers` and `kit`, and the pages' KIT_MORE pieces).
The join "5 to 6" is biome 5's 5.11 on the temple's side; a5_dress.py left the forge's side of it
to this file: the soot-black back wall east of the door, the forge door seen from inside with its
small iron pug and the last torch beside it, the anvil, tongs rack and trough, the great iron mask
and its breath pipe, the strip of grating, the landing slab's look, and the black floor kerb in
front. The join "6 to 7" is this file's 6.9: the crack, its chalk and the sill out through the
door. The cliffs themselves are biome 7's; through the opening you see the Peak's real far layers
(the painted valley with the town on it: stages/peak/peak_backdrop.gd), so nothing is painted in
the door (FOR THE AREA FILE 4).

Parker, 11-13: the forge is where the First Top Dog's belt was made, and THE LIGHT RUNS FROM FURNACE
RED TO DAYLIGHT, WITH NO TORCHES ABOVE THE FORGE FLOOR: two torches in the whole biome, the door's
(the last of the temple's) and the smith's hut's lamp (the last on the climb). The smith's hut
(note 59) is black stone and iron sheet, no timber, and ONLY THE FROG LIVES IN IT; the frozen
climber in his dog mask stays where the course has him and the hut is built round him. Yes to the
open box of dynamite behind the rungs (note 58). The great iron mask is remade taller, 8 x 11, so
that the ring is in its nose and the tongue is the ledge you land on.

Scenery only: decos (and one card). Nothing here can be stood on or held. The course (the shell,
the landing, the grates and their vents, the ring and the chains, the tongue, the hot and cool
holds, the charging step, the hopper's plates, the loft's lip, the stepping bellows, the deck, the
rungs and the dynamite, the shore, the pan and its slag, the rafts, the crusts, the landings, the
anvils, the hammers, the hood, the baffle, the rings, the ledges, the pillar, the steps, the
chockstone, the nubs and the sill) is a6.py's. The model list this file makes is
docs/peak/models/a6_models.md.

Depth: the play space is z -1.2 .. 1.2. Everything here stands behind -1.25 or in front of 1.25,
except SKINS (skin=True), each the LOOK of course solids (MODELLING_RUN rule 4), filling them,
z -1.2 .. 1.2: the shell's slabs (SHELL_SKINS), the landing, the grates, the tongue, the charging
step, the hopper's front, the loft's lip, the bellows' deck, the shore, the slag pan, the two dead
crusts, the pier's landing and head, the three anvils, the hood, the baffle, the basalt shelf, the
doorstep, the pillar, the crack's steps and the chalk sill.
From the back, the forge stands at: the hall's back wall and the flue's far wall, one plane with
its face at z -3.6 (-4.6 .. -3.6), soot-black temple blocks to the pier's head and basalt above,
the daylight painted on it and the slit of sky open in it at the top (the sky cards behind at -5);
on it the chain stubs and the stair doors (-3.6 .. -3.2), the tongs rack, the banked furnace
mouths' hoods; the hammer pier against it -3.6 .. -1.7 (the steps' face -2.4, the three slotted
towers forward to -1.7); the furnace -3.2 .. -1.45 (its foot set back to -2.5 under the mouth);
the bellows' shelf, frame and the great bellows -3.6 .. -1.3; the tapping floor -3.6 .. -1.25,
the smelter -3.2 .. -1.45; the pan's back half -3.0 .. -1.25 and its cradles and chains; the
cam wheels -3.6 .. -1.6; the hut -2.65 .. -1.25 and its things -2.4 .. -1.3; the mask -1.9 .. -1.3;
the pipes and the wheels -3.6 .. -1.3; the rods, jibs, flap and grille bars -2.4 .. -1.3; the
crack's back wall -1.8 .. -1.25 (page 6.9: the only back wall within reach). In front: the floor's
kerb all along the bottom (its top 1.6 m below the floor's), the hut's front sill, the heavy
chain's last links in the shaft's top corner in front of the east wall, a basalt fin in front of
the pillar's foot at 6.8 and at 6.9, the chalk overhang over the opening. Nothing in front of a vent.

Walls and masses (BRIEF.md "Walls and masses"; the sheet's `built`): stone is PAINT. Every wall,
roof, floor and mass is ONE painted piece made for its place, a few big planes with a designed
outline. Low down: the temple's own soot-black blocks, the courses flat colour in three or four
near-black tones, long and a little uneven, the joints thin lines; the temple's carved band worn
nearly flat (a painted band at 484.0 .. 484.6 and 490.0 .. 490.6 by the door, 484.3 .. 484.9 by the
hut, 505.0 .. 505.6 behind the twins); the soot in long uneven bands, darkest at the floor. Above
the pier's head: basalt, grey-brown in a few big leaning planes, its grain and its heat cracks long
wavy painted lines that run the length of the face, dull red in the lowest cracks of the shaft,
paler and drier the higher it goes, a dry pale grey by the doorstep and pale chalk in the crack's
last few metres. NOTHING PAINTED NARROWS TO A POINT; no dark recess cut into a face; never a
repeated square panel; never a course or a bed of rock built as its own block. The few real
breaks: the furnace mouths (the great furnace's and the two banked in the back wall by the hut),
the furnace's overhanging first tier, the forge hood's slab, the pier's steps, one leaning slab of
basalt in the flue's far wall, the slit of sky, the split in the crack's roof. Behind each mass
the same rock carries on, duller and cooler. No brick, no timber but tool handles and the bellows'
boards, no crystal, NOTHING GREEN. Plants: none near the forge; the first dry tufts near the top
(three small basalt outcrops on the far wall at 6.8, each with the kit's flat `grass_tuft_dry`).
THE LIGHT CHANGES WITH HEIGHT: furnace red from below at the floor, orange in the loft, the slag's
bright orange from underneath at the pan, gold at the hammers, pale gold in the shaft, blue-white
daylight from above at the crack. In tonight's dark frames painted bands vanished wherever their
values sat close together: EVERY WALL MUST BE JUDGED IN THE BIOME'S OWN LIGHT AT ITS OWN HEIGHT,
its bands stepped well apart in value (the near-blacks low down most of all). Scenery is black iron
and black stone, never rust orange; rust orange is what you can hold.

A deco's origin is the middle of its base (x and z) at its foot (y), unless its comment says
otherwise: things that hang (the chain's last links) and the flap (its hinge) have theirs at the
middle of their top; wall-mounted things (torches, racks, chain stubs, rings on pins) the middle
of their foot on the wall, or for a ring on a pin where the pin meets the wall; wheels their hub;
a jib the foot of its post (its arm reaching +x; flipped, -x); rods and grille bars their middle
(rods are made upright and stretched along their length, FOR THE AREA FILE 6e); chains their
middle (stretched). For the long pieces (walls, floors carried back, pipes made to their route):
the middle of its x span, the bottom of its box, the middle of its depth. A deco's size is the
size its model is MADE at (the game rescales a landed model more than a quarter off); where one
model is used at several sizes, `scale` does it and the size is the model's own. `rot` is in
degrees, counter-clockwise as the camera sees it (a positive rot tips a thing's top to the west).

Shared pieces are placed once, in the first section that names them, and the other page is named in
a comment (the hall's walls and the kerb for every floor page, the furnace for 6.1 to 6.3, the cam
wheels and rods for 6.3 and 6.4, the jibs and stair doors for 6.3 to 6.7, the hammer pier for 6.0,
6.5, 6.6 and 6.7, the hood and its pipe for 6.6 to 6.8, the flue's far wall for 6.7 and 6.8).

FOR THE AREA FILE (tools/peak/areas/a6.py; the fix thread's). Line numbers are a6.py's as of
2026-11-14 03:25 (the version with the dynamite rung, the grates' lanterns and the four rings).
  1. Call it: `import a6_dress` beside the other imports, and `a6_dress.dress(A)` after the course
     is built (before A.save(), line 344).
  2. Lights. Keep the loop (lines 322-329) and the two grates' lanterns (333-334): they are the
     biome's red-to-daylight. Its (-289.0, 484.0) is the door's torch (now `TORCHES[0]`, 1.2 m off:
     move it there if it reads wrong). Add, all flickering but the last: `HUT_LAMP`, the hut's lamp
     and the last torch on the climb, "#FFC27A", range 4, energy 0.9; `HEARTH`, the hut's coals,
     "#FF9A40", range 3, energy 0.7; one per `MOUTHS` (the two banked furnace mouths by the hut and
     the great furnace's mouth, red from below), "#FF3A14", range 6, energy 1.3 (the loop's
     (-246.0, 481.5) can become MOUTHS[1]); and steady, `DAYLIGHT_COLUMN`, the first daylight down
     the gap into the shaft's top (6.7), "#E6E8F0", range 6, energy 0.7.
  3. Decos to take out: ALL of lines 301-318 (this file places each out of the play space, or as a
     skin, at the kit model's made size): 301 (pug_mask_iron at z -1.2, its face 0.9 m behind you:
     the page's remade 8 x 11 mask is `forja_great_mask`, set back to -1.9 .. -1.3); 302-306 (the
     five steam_grate decos: placed here as the grates' skins, item 5); 307 (the standpipe, its
     front 0.3 m behind you: placed 1 m further back); 308 (bellows_great, its front 0.25 m IN
     FRONT of you: placed back under the deck, -3.8 .. -1.3); 309-310 (the two anvils at -1.0:
     placed at -1.6); 311-312 (the great anvils: placed here as the anvils' skins); 313
     (slag_pan_chains, its chains 1 m behind you: the pan's skin, its back half, two cradles and
     four chains); 314 (forge_hood_ribs at 537 and z -0.6: its maker says the deco's y is 530.75;
     placed there at z -1.5); 315 (tongs_rack sideways on the west wall: `forja_tongs_rack` faces
     the camera, on the back wall); 316 (papel_tatters 1.6 m behind you: 5 m, against the far
     wall); 317-318 (the two torches: the door's and the hut's lamp, placed here). KEEP the two
     statues (319-320).
  4. Cards. Take out: 283-285 (the three far walls at -4.6 .. -4.4: the hall's walls and the flue's
     far wall), 286-287 (the furnace face: `forja_furnace`), 288 (the slag's glow: the pan's back
     half is painted live), 289 (the slag's drip, a bright strip 1.5 m from the chain that could be
     taken for a second chain: item 9 makes it drops), 290-291 (the three hammer guides: the pier's
     slotted towers), 296-297 (the shaft of daylight: painted on the flue's far wall), 298 (the
     soot under the hall's roof: on the roof's skin and the wall's top), 299 (the floor's front lip
     at z 3: the kerb). KEEP 82 (the burnt strip at -1.35, in front of the furnace's face at -1.45:
     note 56, kept by the page), 293-294 (the slit of sky, behind the far wall's slit). RESHAPE so
     the opening shows the real far layers: line 282 (the dark at -6) becomes
     (-297, 470), (-228, 470), (-228, 579.4), (-234, 579.4), (-234, 586), (-228, 586), (-228, 592),
     (-297, 592); line 295 (the sky at -5) stops at the door: (-240.4, 579.0), (-238.0, 579.0),
     (-234.0, 579.4), (-234.0, 586.0), (-237.0, 586.0).
  5. Skins. Each named solid takes `skin=` its stem; this file places every skin deco.
     a. The shell (line 35): pass `skins=a6_dress.SHELL_SKINS` to A.cave.
     b. By line: the landing slab and the grip ledge (41-42) "forja_landing"; the five grates (55,
        100, 244, 247, 250) "steam_grate" (the kit's, placed at 1.2, 0.8, 0.64, 0.48, 0.48 of its
        2.5 m, its top level with each grate's); the tongue L1 (61) "forja_mask_tongue"; the
        charging step L2 (74) "forja_charging_step"; the hopper's two plates (103-104)
        "forja_hopper_front"; the loft's lip L3 (108) "forja_loft_lip"; the deck L4 (123)
        "forja_bellows_deck"; the shore (132) "forja_shore"; the pan (152) "forja_slag_pan"; the two
        dead crusts (161) "forja_dead_crust"; the pier's landing L5 (164) "forja_pier_landing"; the
        three anvils' faces and waists (180-181) "anvil_great" (the kit's, re-made: item 8); the
        pier's head L6 (188) "forja_pier_head"; the hood (200) "forja_hood"; the baffle (213-214)
        "forja_baffle"; L7 (226) "forja_basalt_shelf"; L8 (253) "forja_doorstep"; the pillar (264)
        "forja_pillar"; steps 1 and 2 (265-266) "forja_crack_steps"; the rock under the sill (267)
        "forja_crack_east" (with shell edges 3 and 4); the sill (268) "forja_chalk_sill". The bucket
        (item 6a) "mine_bucket_upturned"; the chockstone (269) "forja_chockstone" (item 8).
  6. Course changes on the pages, for the fix thread (not scenery):
     a. 6.0 (note 59): an upturned iron bucket under the sitting climber (line 319), a NEW solid
        in the play space, kind "iron" (it can be held and stood on, its rim rust orange): x
        -238.9 .. -238.3, y 479.08 .. 479.53 (the page's 0.7 x 0.42, set to the kit's
        `mine_bucket_upturned`, 0.6 x 0.45, so the kit's bucket is its skin, unscaled: its top
        then meets his seat at 479.55).
     b. 6.9 (note 64): the chockstone (line 269) becomes a cracked block of chalk, the same size and
        wedge shape (`forja_chockstone`, item 8): it shifts and trickles grit when first touched,
        breaks into rough chunks that drop down the gap with white dust, and comes back as a fresh
        block dropping out of the roof's split (`forja_roof_split`, placed here, over it) with a
        thud and a puff of dust, wedging where the last was. Its 1.2 s and 8 s do not change.
     c. Done already, nothing more: note 58 (the dynamite rung, line 131), note 61 (four rings,
        lines 217-225), note 62 (the grates' lanterns, 330-334), note 63 (every vent x 1.1).
     d. The crunch knock-out (notes 49, 78): two places to check with it now built. Hammer 3 at the
        top of its lift brings its peak to 0.98 m under the hood (539.8 at x -245.1; hammers 1 and 2
        stop 3.1 and 2.0 m under it): a body lying on its greased top could be pinned. And the
        rafts stop 0.3 m short of the dead crusts (raft 1 at -275.7 against crust 1 at -275.4;
        raft 2 at -274.3 against its east side): only a hand or foot fits, so no crunch, but worth
        one try. The hammers onto the anvils are already a knock-out (ko=True).
     e. `forja_drive_rod` (the crank rod, the coupling rod, the long rod, the three rake handles)
        is made upright 1 m long and placed at each rod's length (1.75 to 13.41 m): add it to
        peak.gd's STRETCH (line 27) beside the chains, AND let STRETCH models skip the size rescale
        (lines 837-845): today that rescale multiplies a stretched piece's width by its length's
        ratio before the stretch sets its length, so a 13.4 m rod would be drawn 1.9 m thick (and
        a5's 2.2 m gullet chain 0.06 wide; the pan's four chains here, the kit's
        `counterweight_chain` at 16.1 and 16.9 m, 0.43 wide: near the page's 0.5, but by luck).
  7. Found while dressing, not on a page:
     a. The forge's west wall above the door: st.json solid 40 (the well's east wall, x -294 ..
        -290, y 488 .. 498) and a6's slab for shell edge 13 (x -294 .. -291, from 488) are two faces
        in one place, and st's reaches 1 m into the forge's air (x -291 .. -290), where the door's
        lintel, its pug and the last torch stand. As a4 and a5 found on their sides: suggest the
        shared structure's owner trims its wall to x -291 there.
     b. st.json's well cards at z -3.2 and -4.1 (x to -288, y to 498) stand IN FRONT of the forge's
        back wall (-3.6) by the door, over x -291 .. -288: cut 476 .. 498 east of x -291 out of
        them when `forja_hall_wall_low` lands.
     c. a7.py line 398's card (z -2.5, x -262 .. -232, from y 570 up) covers the top of the flue:
        the far wall's slit of sky, the dry tufts and the daylight painted on it at 6.8 (x -262 ..
        -250.5, 570 .. 577), and the sky cards behind the crack. a6's crack wall (-1.8 .. -1.25) is
        in front of it from x -250.5 east. Suggest a7 starts it at y 590 (above the crack's roof).
     d. forge_hood_ribs (line 314) was 6.25 m too high and in the play space; placed at its maker's
        530.75, z -1.5, under the hood's skin.
     e. The shaft's two wall rings (line 222, x -236.3) hang 0.3 m off the east wall's SIDE face:
        there is no wall behind them for the kit's pin to go into. They want a ring on a pin driven
        sideways into the east wall (`forja_ring_side_pin`, new, item 8). The two empty sockets of
        the rings that went (note 61) are painted on the east wall's skin at its edge beside them.
     f. The kit's `anvil` stands on a timber stump; the sheet allows no timber but tool handles and
        the bellows' boards: its re-make (item 8) puts it on a stone footing with the iron pug.
     g. The flue's slit of sky (cards 293-295) shows in the far wall's slit only up to 568: above
        that the crack's back wall (page 6.9, -1.8 .. -1.25) is in front of it. From the floor the
        sky reads as the opening itself and the pale daylight painted down the far wall.
     h. 6.4: the stepping bellows' mover lifts its plank AND its greased body together (lines
        118-121), so its base rises 1.8 m with it. The page (note 57) keeps the base still on its
        brackets and stretches the pleats: an engine change. Until then the brackets placed here
        stand under the folded base.
  8. Movers', ropes' and holds' looks (the area file's; models in a6_models.md section 4, or a
     kit model re-made):
     - the rings: the nose ring (line 59) wears `iron_ring_pin_long` rooted in the mask's nose
       (origin (-281.5, 491.823), z -1.583: its ring's centre then lies on the hold at z 0); the
       two hoists' rings (106, 162) `iron_ring_pin_long` rooted in the end of each jib's arm (z
       -1.583); the shaft's two wall rings (222) `forja_ring_side_pin`; the two across its head
       (223) `iron_ring_pin_long` rooted on the grille bar; 6.8's (246, 249) `iron_ring_pin_long`
       on the riser's clamp and on the capped stub, and the last (252) on its spike, rooted in the
       crack's back wall. Every ring 0.5 across, rust orange, worn bright inside.
     - the rungs (124-125): `forja_staple_long` (an iron staple whose legs run 1.3 m back into the
       rung pier, the bar 0.8 wide at z 0, rust orange). The dynamite rung (131):
       `forja_dynamite_stick` (a fat red stick with paper bands and a fuse curling off its east end:
       what lights, blows and comes back) lying in `forja_rung_stubs` (the two bent stubs of the
       snapped rung, back into the pier: they stay when the stick goes);
     - the hot holds (line 73, kind "hot"): the fitted kit's `fit_hot_hold` as now (a through-stone's
       square end with a glowing joint); the three cool holds (kind "rock", r 0.3):
       `forja_cool_boss` (a small pug's head in plain cold grey stone, the one boss left whole on
       each of the furnace's three worn bands);
     - the three flint nubs (270-271): `forja_flint_knob` (a knob of flint in its white rind, the
       size of two fists, 0.4 out); eight more sit flush in the band, placed here;
     - the chockstone (269): `forja_chockstone` (item 6b);
     - the stepping bellows (121, model "bellows"): re-made (note 57): a pale dry timber top board
       with a pug's face on its front edge, black greased leather pleats that open as it swells and
       close as it folds, a fixed iron base (item 7h);
     - the rafts (158, "slag_raft"): re-made: a thick iron plate with a turned-up edge, rust
       orange on top, black and crusted on its sides, an eye at its west end where the rake's
       handle hooks on;
     - the hammers (186, "drop_hammer"): re-made: black greased iron with a peaked top, THE PUG'S
       FACE cast on its front, its striking face a band of bright worn steel (the only pale thing
       on it), the lug rust orange;
     - things that would move: the three lifting wheels (each a full turn per hammer cycle, the peg
       coming round to the bottom as its hammer starts up), the three cam wheels and the coupling
       rod (with the stepping bellows, each a third of a turn behind the last), the steam wheel,
       its crank rod and the great bellows (shutting with each gust, lifting through the quiet:
       note 57, the bellows re-made in parts), the rake wheel and the three rake handles (each
       handle from its crank to its raft's eye), the flap (rattling 0.9 s before the gust, flung
       open in it), the upper chain stub (lying west in the gust). All stand still until the
       engine can drive them.
  9. Effects (the pages'; a6.py's A.effect, lines 335-341, stay): the red in the two banked mouths
     swelling and sinking like breathing, a thread of smoke from the hearth's pipe, a spark each
     time the frog taps the anvil, the frog's croak within a screen (6.0, note 60); wisps from the
     mask's nostrils and a brighter red in the grate for the 1.2 s before each blast, the door's
     flame leaning into the hall, embers rising (6.1); the fire in the mouth and the red line in the
     crack brightening together, heat shimmer, sparks out of the crown, a wisp at each cool boss
     (6.2); THE FALLING SLAG as separate bright drops, set 3 m back (x -264.0 .. -263.2, y 501 ..
     522.2, z -3.2), a bigger gob 1 s before the second vent blows, the hopper's rim glowing where a
     drop lands, the first grate's steam leaning east (6.3); the bellows' jet of steam and sparks
     along the wind for its 1.4 s, the nozzle's pug puffing its cheeks, soot off the frame, a puff
     at the steam wheel's nozzle, the fuse's hiss and spark (6.4); the slag pouring from the spout
     in a slow bright rope, sparks where it throws, thick embers over the pan, a puff at the rake
     wheel's nozzle (6.5); white-gold sparks and dust at each blow, a puff at each wheel's nozzle
     before its hammer rises, each chain swinging when its hammer lands (6.6); steam and soot up the
     shaft and out of the window in the gust, the flap's rattle and bang, dust in the pale column
     (6.7); steam seeping from grates 2 and 3, each blast lit paler than the one below, dust in the
     daylight (6.8); white dust blowing in at the opening, grit from under the chockstone, the
     climber's long shadow, the forge's rumble fading into wind (6.9).
"""

# ------------------------------------------------------------------ the lines things stand on
WALL_FACE = -3.6        # the hall's back wall and the flue's far wall: one plane (6.0 .. 6.8)
HUT_FACE = -2.3         # the smith's hut's back wall (6.0)
DOOR_FACE = -1.7        # the forge door's lintel, seen from inside (6.1)
PIER_FACE = -2.4        # the hammer pier's steps (6.5, 6.6)
FURNACE_FACE = -1.45    # the great furnace above its foot (6.2)
SMELTER_FACE = -1.45    # the smelter (6.5)
CRACK_FACE = -1.25      # the crack's back wall (6.9): the only one within reach
RING_ROOT = -1.583      # iron_ring_pin_long rooted here puts its ring's centre on a hold at z 0

STONE = "stone"         # stand-in tones (a6's palette "chimney")
SOOT = "back3"          # soot-black temple stone
IRON = "#2E2628"        # black iron: scenery is never rust orange
RUST = "rust"           # rust orange: what you can hold
BASALT = "#7A6E62"
CHALK = "#E6DFCF"
GOLD = "gold"

# The room's shell: the skin of each slab a6.py's A.cave makes for edge i of AIR (FOR THE AREA FILE
# item 5a). Edges 5 (the exit door) and 14 (the entry door) are open.
SHELL_SKINS = {
    0: "forja_floor", 1: "forja_floor",     # the forge floor: soot-black temple slabs, worn pale on top
    2: "forja_east_wall",                   # the flue's own rock, wet with soot (the two empty ring sockets on it)
    3: "forja_crack_east", 4: "forja_crack_east",   # the gap's black glassy wall, on under the sill (line 267)
    6: "forja_crack_roof", 7: "forja_crack_roof", 8: "forja_crack_roof",   # chalk and basalt, the split cut through it
    9: "forja_flue_crown", 10: "forja_flue_crown",  # the flue's crown, pale dry basalt lit from above
    11: "forja_flue_west_wall",             # the flue's west wall, leaning in over the climb
    12: "forja_hall_roof",                  # the hall's roof: black, the soot thickest under it
    13: "forja_west_wall",                  # the forge's west wall over the door
}

# Lights for a6.py (FOR THE AREA FILE item 2), filled by dress(): x, y (and z for the torches).
TORCHES = []
HUT_LAMP = (-239.2, 481.6)
HEARTH = (-236.5, 480.4)
MOUTHS = [(-251.0, 479.3), (-246.3, 479.5), (-274.0, 479.6)]
DAYLIGHT_COLUMN = (-238.2, 556.0)

# 6.4: the three stepping bellows (the top board's middle, folded: a6.py line 117).
_SMALL = [(-270.0, 512.8), (-273.4, 514.8), (-276.8, 516.8)]
# 6.6: the hammers (a6.py line 177) and the steps their anvils stand on.
_HX, _HY = (-253.5, -249.3, -245.1), (523.6, 527.6, 531.6)
# 6.5: the slag's surface (a6.py PW, PE).
_PW, _PE = (-280.3, 524.6), (-263.6, 522.3)


def floor_y(x):
    """The top of the forge floor at x (shell edges 0 and 1: 478.0 at x -262)."""
    return 480.0 - (x + 291.0) * 2.0 / 29.0 if x < -262.0 else 478.0 + (x + 262.0) * 1.2 / 26.0


def slag_y(x):
    return _PW[1] + (x - _PW[0]) * (_PE[1] - _PW[1]) / (_PE[0] - _PW[0])


def dress(A):
    import math
    TORCHES.clear()

    # ------------------------------------------------------------ helpers
    def skin(stem, x0, x1, y0, y1, tone=STONE):
        """The look of course solids, filling them (z -1.2 .. 1.2)."""
        A.deco(stem, round((x0 + x1) / 2, 3), y0, z=0.0, size=(round(x1 - x0, 2), round(y1 - y0, 2), 2.4), tone=tone, skin=True)

    def back(stem, x0, x1, y0, y1, z_near, z_far, tone="back2"):
        """A piece behind the play space, from z_near back to z_far (origin: the middle of its foot)."""
        A.deco(stem, round((x0 + x1) / 2, 3), y0, z=round((z_near + z_far) / 2, 3), size=(round(x1 - x0, 2), round(y1 - y0, 2), round(z_near - z_far, 2)), tone=tone)

    def front(stem, x0, x1, y0, y1, z_near, z_far, tone=SOOT, scale=1.0):
        """A piece in front of the play space (z_near the side toward the play space)."""
        A.deco(stem, round((x0 + x1) / 2, 3), y0, z=round((z_near + z_far) / 2, 3), scale=scale, size=(round(x1 - x0, 2), round(y1 - y0, 2), round(z_far - z_near, 2)), tone=tone)

    def grate(x, top, w):
        """The kit's steam grate (made 2.5 x 0.3 x 1.53: square bars in a raised rim, rust orange where
        feet have worn it), the skin of a grate w metres wide, its top level with the grate's."""
        s = round(w / 2.5, 3)
        A.deco("steam_grate", x, round(top - 0.3 * s, 3), z=0.0, scale=s, size=(2.5, 0.3, 1.53), tone=RUST, skin=True)

    def torch(x, y, face):
        """The kit's torch in a bracket (made 0.4 x 1.4 x 0.4) on a face at z `face` (origin: the
        middle of its foot, its back on the face). The game lights its fire."""
        z = round(face + 0.2, 3)
        A.deco("torch_wall", x, y, z=z, size=(0.4, 1.4, 0.4), tone=GOLD)
        TORCHES.append((x, y, z))

    def pug(x, y, w, face):
        """The kit's iron pug mask (made 8 x 9 x 0.6), w metres across, on a face: on every machine's
        footing, over the door, on the pier's risers."""
        s = round(w / 8.0, 4)
        A.deco("pug_mask_iron", x, y, z=round(face + 0.3 * s, 3), scale=s, size=(8.0, 9.0, 0.6), tone=IRON)

    def rod(p0, p1, z=-1.45):
        """A flat iron drive rod with an eye at each end, made upright 1 m long and stretched to its
        span (FOR THE AREA FILE 6e). Origin: its middle."""
        dx, dy = p1[0] - p0[0], p1[1] - p0[1]
        A.deco("forja_drive_rod", round((p0[0] + p1[0]) / 2, 3), round((p0[1] + p1[1]) / 2, 3), z=z,
               rot=round(math.degrees(math.atan2(dy, dx)) - 90.0, 1), size=(0.14, round(math.hypot(dx, dy), 2), 0.1), tone=IRON)

    def chain(x, y0, y1, z):
        """The temple's heavy chain (the kit's counterweight_chain, links as thick as an arm),
        stretched from y0 to y1. Origin: its middle."""
        A.deco("counterweight_chain", x, round((y0 + y1) / 2, 3), z=z, size=(0.32, round(y1 - y0, 2), 0.32), tone=IRON)

    def stub(x, y, rot=0.0):
        """An old chain stub: three short thick links on a pin in the far wall (origin: the pin, the
        links standing up from it; rot 90 lays them over to the west)."""
        A.deco("forja_chain_stub", x, y, z=round(WALL_FACE + 0.2, 3), rot=rot, size=(0.35, 0.75, 0.4), tone=IRON)

    def tuft(x, y, face=WALL_FACE):
        """A small outcrop of basalt standing proud of the far wall, and on it the first dry tuft (the
        kit's flat grass_tuft_dry): the only plants in the biome, near the top."""
        A.deco("forja_ledge_block", x, y, z=round(face + 0.2, 3), size=(0.9, 0.45, 0.4), tone=BASALT)
        A.deco("grass_tuft_dry", x, round(y + 0.45, 2), z=round(face + 0.25, 3), size=(0.7, 0.55, 0.008), tone="weak")

    def jib(x, y, flip=False, s=1.0):
        """A wall jib, the smiths' hoist: an iron post, an arm and a brace, a hook ring at the arm's end
        (made post 6.9, arm 3.9: 4.1 x 7.0 x 0.5; origin the foot of its post, the arm reaching +x)."""
        A.deco("forja_wall_jib", x, y, z=-1.55, scale=s, flip=flip, size=(4.1, 7.0, 0.5), tone=IRON)

    # ============================================================ the shell (the hall's and the flue's skin)
    # Each piece painted for its place (FOR THE AREA FILE item 5a).
    skin("forja_floor", -291.0, -236.0, 475.0, 480.0, tone=SOOT)        # swept paler inside the hut, a ring of scale round its anvil
    skin("forja_east_wall", -236.0, -233.0, 479.2, 566.0, tone="slick")  # the two empty ring sockets and rust streaks at (-236.3, 538.6), (-236.3, 544.3)
    skin("forja_crack_east", -237.2, -231.0, 566.0, 579.4, tone="slick")  # with the rock under the sill (line 267)
    skin("forja_crack_roof", -244.0, -231.0, 578.5, 590.5, tone=CHALK)   # the split over the chockstone cut through it
    skin("forja_flue_crown", -260.0, -244.0, 566.0, 581.5, tone=BASALT)
    skin("forja_flue_west_wall", -265.0, -257.0, 541.0, 566.0, tone=BASALT)
    skin("forja_hall_roof", -291.0, -262.0, 541.0, 544.0, tone=SOOT)
    skin("forja_west_wall", -294.0, -291.0, 488.0, 541.0, tone=SOOT)

    # ============================================================ the hall (every floor page)
    # The hall's back wall, low (6.0, 6.1, 6.2, 6.3): the temple's soot-black blocks in bays, a sloped
    # base, the worn carved band at the temple's heights, the soot darkest at the floor; at its east
    # end the foot of the hammer pier (6.0), with the two banked furnace mouths cut in it (x -252.3 ..
    # -249.7 and -247.6 .. -245.0, 478.5 .. 481.8: real breaks, the fire painted in them).
    back("forja_hall_wall_low", -291.0, -236.0, 476.0, 508.0, WALL_FACE, -4.6, tone=SOOT)
    # The hall's back wall, high: the bellows loft and the hammer shop (6.4, 6.5, 6.6), lit orange
    # from above; its top 541 under the roof west of x -262, then down along the hood's line to the
    # pier's head (535.6), and the pier's stone carried up round the last stair door and its pug to
    # 540.2 at x -241 .. -236.5 (6.7: the last cut stone).
    back("forja_hall_wall_high", -291.0, -236.0, 508.0, 541.0, WALL_FACE, -4.6, tone=SOOT)
    # The flue's far wall (6.7, 6.8, 6.9's foot): basalt from where the temple stone stops, in a few
    # big leaning planes, one leaning slab standing out of it, dull red in the shaft's lowest cracks,
    # paler and drier up to a dry pale grey; the shaft of daylight painted down it from the crack
    # (what cards 296-297 draw today, gold dying into the red below 552); the slit of sky open through
    # it from 562 up (x -246.6 .. -242.6 widening: the sky cards behind at -5).
    back("forja_flue_far_wall", -262.0, -234.0, 535.6, 578.0, WALL_FACE, -4.6, tone=BASALT)
    # Foreground: the floor's kerb, a low lip of soot-black blocks along the very bottom of the frame
    # in 4 m lengths, its top 1.6 m below the floor's (it covers nothing you can stand on).
    for k in range(14):
        x = -289.0 + 4.0 * k
        A.deco("forja_floor_kerb", x, round(floor_y(x) - 2.5, 2), z=1.65, size=(4.0, 0.9, 0.7), tone=SOOT)

    # ============================================================ 6.0 The smith's hut
    # The two banked furnace mouths (in the low wall), each under a ribbed iron hood.
    for x, y in ((-251.0, 482.0), (-246.3, 482.2)):
        A.deco("forja_mouth_hood", x, y, z=round(WALL_FACE + 0.65 * 0.82, 3), scale=0.82, size=(4.4, 1.5, 1.3), tone=IRON)
    # The hut: a lean-to of riveted iron sheet sloping down from the east wall on two iron posts, its
    # back wall of the forge's black blocks (4 x 3), cut away at the front; the roof stops 1.25 m
    # behind the play plane so a faller passes in front of it.
    A.deco("forja_smith_hut", -238.8, 478.9, z=-1.95, size=(5.6, 4.05, 1.4), tone=SOOT)
    # On its back wall: a rack of tongs, and three wall rings on pegs, black, finished and half
    # finished (the kit's ring on a pin; origin where the pin meets the wall).
    A.deco("forja_tongs_rack", -240.1, 480.4, z=round(HUT_FACE + 0.105, 3), scale=0.7, size=(2.0, 1.0, 0.3), tone=IRON)
    for x in (-238.5, -237.9, -237.4):
        A.deco("iron_ring_pin", x, 481.52, z=HUT_FACE, size=(0.5, 0.55, 0.37), tone=IRON)
    # The hearth against the east wall: a block of temple stone, a bed of coals, a small iron hood; its
    # ribbed pipe (the kit's vent_pipe at 0.24: 0.53 across) up the wall and out through the roof.
    A.deco("forja_hearth", -236.55, 479.15, z=-1.85, size=(1.15, 2.35, 1.1), tone=SOOT)
    A.deco("vent_pipe", -236.3, 481.5, z=-1.85, scale=0.24, size=(2.2, 21.0, 2.2), tone=IRON)
    # The little bellows on its stand beside the hearth, worked by a treadle and a rod.
    A.deco("forja_bellows_small", -237.8, 479.17, z=-1.85, size=(1.4, 0.95, 0.7), tone=IRON)
    # The small anvil (the kit's, re-made on a stone footing with the iron pug: item 8), 0.6 m further
    # back than today; a wall ring lying bent open on it; the frog on its heel in a leather apron with
    # a tiny hammer (the chimney's frog, note 60: only the frog lives here).
    A.deco("anvil_forja", -240.0, 479.02, z=-1.6, size=(1.2, 0.9, 0.6), tone=IRON)
    A.deco("forja_ring_bent", -240.2, 479.92, z=-1.6, size=(0.5, 0.15, 0.5), tone=IRON)
    A.deco("forja_frog_smith", -239.75, 479.92, z=-1.6, size=(0.3, 0.3, 0.3), tone="accent")
    # The lamp: the east wall's torch comes down under the roof onto the back wall (the last torch).
    torch(-239.2, 480.3, HUT_FACE)
    # Outside the west post: the quenching trough (black water, a pair of tongs in it); between the
    # two furnace mouths a heap of coal.
    A.deco("forja_quench_trough", -243.25, round(floor_y(-243.25), 2), z=-1.85, size=(1.6, 0.6, 0.7), tone=SOOT)
    A.deco("forja_coal_heap", -248.65, round(floor_y(-248.65), 2), z=-1.9, size=(1.9, 0.95, 1.0), tone="back3")
    # Foreground: the hut's front sill, iron plate on the floor's front edge with the two front posts'
    # stumps cut off level, below the floor's top (it shows the front was taken away).
    front("forja_hut_sill", -241.1, -236.9, 478.2, 478.7, 1.3, 1.55, tone=IRON)
    # (The bucket under the frozen climber is a course change: FOR THE AREA FILE 6a.)

    # ============================================================ 6.1 Primer Vapor (5 to 6, the forge's side)
    # The landing slab and its grip ledge (skin): temple stone soot-black on its face, worn pale on
    # top, the temple's carved band on its edge one last time.
    skin("forja_landing", -295.5, -290.9, 474.0, 480.0, tone=SOOT)
    # The door seen from inside: the stepped arch's reveal through the well's wall and its stepped
    # lintel blocks (-291 .. -289.2 at 487.2 .. 488.8); a small iron pug over it; the last torch.
    back("forja_door_head", -294.0, -289.2, 480.0, 489.0, DOOR_FACE, WALL_FACE, tone=SOOT)
    pug(-290.0, 488.95, 1.5, DOOR_FACE)
    torch(-290.0, 485.0, DOOR_FACE)
    # The great iron mask, remade 8 x 11 (Parker 11-13): cast plates riveted, on a pier of the back
    # wall, chin 4.2 m over the floor, two small folded ears, brow wrinkles; the ring's place in its
    # nose (491.6), its mouth over the chain, its tongue lolling out of the east corner of its mouth
    # and flattening into the plate you land on (the tongue's root on the mask, its plate the skin).
    A.deco("forja_great_mask", -281.5, 484.2, z=-1.6, size=(8.0, 11.0, 0.6), tone=IRON)
    skin("forja_mask_tongue", -280.3, -276.4, 485.5, 486.0, tone=RUST)
    # The breath pipe: the kit's ribbed vent_pipe at 0.273 (0.6 across) up out of the floor behind the
    # grate and into the mask's chin.
    A.deco("vent_pipe", -281.5, 479.0, z=-2.3, scale=0.273, size=(2.2, 21.0, 2.2), tone=IRON)   # at the strip's back end, its top behind the chin
    # The strip of grating behind the grate, flush in the floor, the fire's red coming up through it
    # (the kit's steam_grate at 0.88: 2.2 wide).
    A.deco("steam_grate", -281.5, 479.08, z=-1.95, scale=0.88, size=(2.5, 0.3, 1.53), tone=IRON)
    grate(-281.5, 479.5, 3.0)       # the grate you stand on (skin)
    # The work place by the door: the small anvil (back from -1.0), the tongs rack down from 3 m up
    # the west wall to where a smith could reach it, the stone trough.
    A.deco("anvil_forja", -286.5, round(floor_y(-286.5), 2), z=-1.6, size=(1.2, 0.9, 0.6), tone=IRON)
    A.deco("forja_tongs_rack", -288.7, 481.2, z=round(WALL_FACE + 0.15, 3), size=(2.0, 1.0, 0.3), tone=IRON)
    A.deco("forja_quench_trough", -288.75, round(floor_y(-288.75), 2), z=-1.9, size=(1.6, 0.6, 0.7), tone=SOOT)

    # ============================================================ 6.2 Piedra Caliente
    # The great furnace (also 6.1's right side and 6.3's crown): four tiers of the temple's blocks
    # stepping back (-277.2 .. -268 at the foot to -275.4 .. -269.6 at the crown, 499.2), a worn carved
    # band round the top of each of the first three (490.0, 493.6, 496.1: the cool bosses on them are
    # holds); its first tier's face at -1.45 overhanging a foot set back to -2.5 below 485, where the
    # mouth is (a stepped arch 3.2 wide, 478.7 .. 482.6, the fire in it) under a ribbed iron hood
    # (483 .. 484.5) cast with it; the charging step's corbel (-268.8 .. -266.9, 493.8 .. 495.4, its
    # face at -2.0 so the branch pipe passes in front); the crown open and glowing. The burnt strip
    # along the holds is a6.py's card (line 82) just in front of the face.
    back("forja_furnace", -277.2, -266.9, 478.4, 499.2, FURNACE_FACE, -3.2, tone=SOOT)
    # The air pipe from the bellows loft: out of the wall at 503 and down into the crown.
    back("forja_air_pipe", -275.0, -274.0, 499.0, 503.5, -2.0, WALL_FACE, tone=IRON)
    # On the floor by the mouth: a heap of coal and a long iron rake leaning on the furnace's foot.
    A.deco("forja_coal_heap", -270.8, round(floor_y(-270.8), 2), z=-1.9, scale=1.263, size=(1.9, 0.95, 1.0), tone="back3")
    A.deco("forja_rake", -269.24, 478.6, z=-1.6, rot=4.0, size=(0.25, 2.4, 0.15), tone=IRON)
    # (The nine hot stones and three cool bosses are holds: FOR THE AREA FILE 8.)
    skin("forja_charging_step", -271.5, -266.8, 495.4, 496.0)

    # ============================================================ 6.3 Geiseres Gemelos
    # The quench pipe: the kit's standpipe (2.2 across, 21 m), its front moved back to 1.3 m behind
    # you, strapped to the wall at two heights.
    A.deco("vent_pipe", -263.0, 478.1, z=-2.4, size=(2.2, 21.0, 2.2), tone=IRON)
    for y in (486.0, 494.0):
        A.deco("forja_pipe_strap", -263.0, y, z=-2.45, size=(2.6, 0.3, 2.3), tone=IRON)
    # The hopper on top: its back half behind (lopsided, short west, long east, black and glassy with
    # splashed slag inside); its front edge is the two slick plates (skin, one piece for both).
    back("forja_hopper_back", -265.7, -258.8, 500.8, 503.3, -1.25, -2.6, tone=IRON)
    skin("forja_hopper_front", -265.86, -258.64, 500.6, 503.5, tone="slick")
    # The branch pipe: off the standpipe, west under the charging step, its elbow up to just behind the
    # first grate (one pipe, two mouths: why they take turns).
    back("forja_branch_pipe", -268.3, -264.1, 493.4, 495.4, -1.3, -1.9, tone=IRON)
    grate(-268.0, 496.05, 2.0)      # the first grate, in the charging step (skin)
    # The smiths' hoist on the east end of the loft's lip (at 0.5: post 3.45, arm 1.95): the ring is the
    # eye at its arm's end. The grilled stair door in the wall behind the lip.
    jib(-263.9, 512.0, s=0.5)
    A.deco("forja_stair_door", -266.0, 512.0, z=round(WALL_FACE + 0.2, 3), size=(2.0, 3.0, 0.4), tone=SOOT)
    skin("forja_loft_lip", -267.6, -263.5, 511.4, 512.0)
    # (The falling slag is an effect, FOR THE AREA FILE 9; the stepping bellows' cam wheels are 6.4's.)

    # ============================================================ 6.4 El Fuelle
    # The stone shelf on stepped corbels out of the west wall; the great bellows on it (the kit's,
    # moved back under the deck, nozzle east); its iron frame (posts, a strut) and the deck carried
    # back to the wall; the deck's front edge (skin).
    back("forja_bellows_shelf", -291.0, -283.4, 510.9, 513.2, -1.3, WALL_FACE, tone=SOOT)
    A.deco("bellows_great", -287.0, 513.2, z=-2.55, size=(7.0, 5.71, 2.5), tone="wood")
    back("forja_bellows_frame", -288.0, -279.2, 513.2, 519.5, -1.25, WALL_FACE, tone=IRON)
    skin("forja_bellows_deck", -288.0, -279.2, 518.9, 519.5, tone="wood")
    # What works it: the steam wheel under the shelf in stone cheeks (origin its hub), the feed pipe up
    # the west wall from over the door to its nozzle, and the crank rod up through the shelf to the
    # free end of the top board.
    A.deco("forja_steam_wheel", -287.6, 509.0, z=-2.2, size=(3.4, 3.4, 1.2), tone=IRON)
    back("forja_feed_pipe", -290.9, -289.3, 489.0, 508.2, -1.9, -2.5, tone=IRON)
    rod((-288.5, 509.5), (-290.3, 514.8), z=-1.5)
    # The three stepping bellows: each on its iron bracket plate from the wall (the cam reaching up
    # through a slot in the plate), its cam wheel under it on an axle from the wall (origin its hub),
    # one coupling rod joining the three, a long rod from the third to the steam wheel (also 6.3's).
    for bx, by in _SMALL:
        A.deco("forja_bellows_bracket", bx, round(by - 2.05, 2), z=-2.425, size=(2.2, 0.5, 2.35), tone=IRON)
        A.deco("forja_cam_wheel", bx, round(by - 3.0, 2), z=-2.6, size=(2.2, 2.2, 2.0), tone=IRON)
    rod((-269.5, 510.3), (-276.3, 514.3))
    rod((-276.3, 514.3), (-286.7, 509.6))
    # The rung pier of the temple's blocks, from the deck to the shore, scorched in a star round the
    # dynamite rung from the last time; the rungs and the stick are holds (FOR THE AREA FILE 8).
    back("forja_rung_pier", -286.8, -285.2, 519.5, 524.6, -1.3, -1.9, tone=SOOT)
    # The open box of dynamite on the deck behind the rungs: the mine's skull pug stencilled on it,
    # three more red sticks showing (note 58, Parker 11-13: yes).
    A.deco("forja_dynamite_box", -284.3, 519.5, z=-1.6, size=(0.6, 0.45, 0.4), tone="hot")
    # The iron shore (skin) and the tapping floor carrying on back to the wall, on two brackets.
    skin("forja_shore", -285.0, -280.3, 524.6, 525.2, tone=RUST)
    back("forja_tapping_floor", -291.0, -280.3, 524.6, 525.2, -1.25, WALL_FACE, tone=IRON)
    A.deco("forja_shore_bracket", -284.25, 523.1, z=-2.1, size=(1.5, 1.5, 1.6), tone=IRON)
    A.deco("forja_shore_bracket", -281.25, 523.1, z=-2.1, flip=True, size=(1.5, 1.5, 1.6), tone=IRON)

    # ============================================================ 6.5 Escoria
    # The smelter on the tapping floor: a round-bellied furnace of temple stone, the iron pug on its
    # front, a stone spout from its tap hole to the head of the pan.
    back("forja_smelter", -286.7, -280.2, 525.2, 530.0, SMELTER_FACE, -3.2, tone=SOOT)
    pug(-284.3, 526.6, 1.4, SMELTER_FACE)
    # The pan (skin: black riveted plate, slag frozen in runs over its rim, the slag bright yellow-orange
    # in the middle of each gap and skinned dark red at its edges); its back half behind, made in
    # place with the tilt; two iron cradles under it, each hung from the hall's roof on a pair of heavy
    # chains well back (the chains in front of you today go).
    skin("forja_slag_pan", -280.3, -263.6, 521.2, 524.6, tone=IRON)
    back("forja_pan_back", -280.3, -263.6, 521.2, 525.4, -1.25, -3.0, tone=IRON)
    for cx, foot, top in ((-275.0, 522.2, 524.9), (-269.0, 521.35, 524.1)):
        A.deco("forja_pan_cradle", cx, foot, z=-2.125, size=(1.0, 2.7, 1.75), tone=IRON)
        for dx in (-0.3, 0.3):
            chain(round(cx + dx, 2), top, 541.0, -2.6)
    # What moves the rafts: one rake wheel at the pan's head kicked round by a steam nozzle (origin its
    # hub), its feed pipe (vent_pipe at 0.273) up behind the tapping floor, and three rake handles from
    # its cranks to the rafts' eyes, through eyes on the cradles' hangers.
    A.deco("forja_rake_wheel", -280.7, 527.3, z=-1.65, size=(2.6, 2.6, 0.4), tone=IRON)
    A.deco("vent_pipe", -280.9, 519.5, z=-3.25, scale=0.273, size=(2.2, 21.0, 2.2), tone=IRON)
    rod((-280.3, 526.5), (-278.8, 525.6), z=-1.35)
    rod((-280.3, 526.7), (-273.2, 524.85), z=-1.35)
    rod((-280.3, 526.9), (-267.2, 524.05), z=-1.35)
    # The two dead crusts (skins): black glassy teeth of slag frozen round the hangers.
    for cx in (-275.0, -269.0):
        y = slag_y(cx)
        skin("forja_dead_crust", cx - 0.4, cx + 0.4, round(y - 0.1, 2), round(y + 0.6, 2), tone="slick")
    # The second hoist on the pier's first landing, its arm reaching back west over the lip.
    jib(-258.8, 523.0, flip=True)
    # The hammer pier (also 6.0's back wall's foot, 6.6, 6.7): soot-black temple blocks in three giant
    # steps (522, 526, 530, each 4.2 wide) and a head (535), the first landing (522) on a corbel to
    # -259.1, the iron pug on each riser; behind each hammer a slotted tower from its step to under the
    # steam pipe (tops 533.3, 536.2, 539.2), the slot down its middle, standing forward to -1.7.
    back("forja_hammer_pier", -259.1, -236.0, 490.0, 535.0, -1.7, WALL_FACE, tone=SOOT)
    for x, y in ((-255.8, 519.725), (-250.4, 523.725), (-246.2, 527.725)):
        pug(x, y, 1.2, PIER_FACE)
    skin("forja_pier_landing", -259.2, -256.2, 522.4, 523.0)

    # ============================================================ 6.6 La Fragua
    # The three great anvils (skins: the kit's, re-made: item 8): their bright faces, their glassy
    # waists. The three lifting wheels on the towers' axles, paddles and one peg (origin the hub).
    for X, Y in zip(_HX, _HY):
        A.deco("anvil_great_forja", round(X - 0.25, 2), round(Y - 1.6, 2), z=0.0, size=(2.55, 1.6, 1.2), tone=IRON, skin=True)
        A.deco("forja_lift_wheel", X, round(Y + 3.7, 2), z=-1.5, size=(4.6, 4.6, 0.3), tone=IRON)
    # The forge's great hood (skin: soot-wet riveted plate), its iron ribs underneath (the kit's, where
    # its maker put it), and the steam pipe up under it with a drop nozzle toward each wheel, on
    # through the hood, up the wall and in under L7 to the first vent of 6.8 (made to its route).
    skin("forja_hood", -258.5, -241.5, 530.4, 542.9, tone="slick")
    A.deco("forge_hood_ribs", -250.0, 530.75, z=-1.5, size=(17.5, 12.5, 0.48), tone=IRON)
    back("forja_hood_pipe", -258.3, -243.6, 529.5, 548.2, -1.3, -2.3, tone=IRON)
    # The scorched bunting: one string of the town's cut paper, three flags left, high in the corner
    # where the roof meets the flue, against the far wall (the kit's papel_tatters, 5 m).
    A.deco("papel_tatters", -259.6, 540.0, z=-3.5, rot=-7.1, size=(5.0, 1.0, 0.05), tone="accent")
    # The last grilled stair door behind the pier's head (2.8 tall) and over it the last iron pug.
    A.deco("forja_stair_door", -238.8, 535.6, z=round(WALL_FACE + 0.2 * 0.933, 3), scale=0.933, size=(2.0, 3.0, 0.4), tone=SOOT)
    pug(-238.8, 538.68, 1.1, WALL_FACE)
    skin("forja_pier_head", -242.4, -236.0, 535.0, 535.6)

    # ============================================================ 6.7 Tiro de Chimenea
    # The baffle (skin: black riveted plate greased with soot, the window's edges scraped bright).
    skin("forja_baffle", -241.5, -241.0, 540.0, 548.4, tone="slick")
    # The flap: an iron plate hinged at the top on the far side of the window, hanging slack (origin
    # its hinge).
    A.deco("forja_flap", -241.5, 546.0, z=-1.75, rot=-23.5, size=(0.4, 2.5, 0.9), tone=IRON)
    # Two chain stubs on the far wall: the lower standing straight up in the draught, the upper (in
    # the gust band) lying over to the west.
    stub(-240.2, 541.15)
    stub(-239.2, 545.0, rot=90.0)
    # The cap grille's last bars: one whole from the east wall up to the top ledge (the rings are eyes
    # on short pins from it; one snapped pin where the middle ring was), two snapped behind it.
    A.deco("forja_grille_bar", -238.5, 548.55, z=-1.85, rot=-22.8, size=(5.4, 0.15, 0.15), tone=IRON)
    A.deco("forja_grille_bar_snapped", -236.75, 548.825, z=-2.05, rot=-23.4, size=(1.5, 0.15, 0.15), tone=IRON)
    A.deco("forja_grille_bar_snapped", -240.45, 550.825, z=-2.05, rot=-22.2, flip=True, size=(1.5, 0.15, 0.15), tone=IRON)
    # The pale daylight down the gap from under the chockstone into the shaft's head: a dusty column
    # in front of the far wall, ending before the window (the first daylight on the climb).
    A.card([(-239.85, 550.4), (-236.4, 549.2), (-236.4, 566.0), (-240.0, 566.0)], z=-3.1, tone="#CFC6B4", edge=False)
    # Foreground: a heavy chain's last three links in the top corner, in front of the solid east wall
    # (origin: the middle of its top).
    A.deco("forja_chain_links", -234.6, 552.65, z=1.45, size=(0.7, 2.1, 0.35), tone=IRON)
    skin("forja_basalt_shelf", -245.8, -241.0, 548.4, 549.0, tone=BASALT)   # L7: the first ledge nobody cut
    grate(-244.8, 549.05, 1.6)      # vent 1's grate, in L7 (skin)

    # ============================================================ 6.8 El Ultimo Aliento
    # The steam pipe in three flights up the far wall from L7: up, across, up, across, a capped stub;
    # an elbow forward to just behind each high grate (note 62: plainly held up, one machine); the
    # clamp on the second riser whose eye is the first ring (made to its route).
    back("forja_flue_pipe", -248.7, -243.6, 549.0, 566.72, -1.3, -2.3, tone=IRON)
    grate(-246.6, 557.2, 1.2)       # grate 2 (skin): the same rim and red grille
    grate(-248.4, 565.4, 1.2)       # grate 3 (skin), in the daylight
    # Two old chain stubs, both below the second grate; above it no iron but the pipe.
    stub(-251.5, 549.85)
    stub(-255.0, 555.45)
    # The first dry tufts, on three small outcrops of the far wall near the top.
    tuft(-249.0, 561.5)
    tuft(-254.5, 566.5)
    tuft(-251.5, 571.5)
    # Foreground: a rough fin of basalt in front of the pillar's foot (it covers only the pillar).
    A.deco("forja_basalt_fin", -241.75, 554.0, z=1.6, size=(3.1, 4.8, 0.6), tone=BASALT)
    skin("forja_pillar", -243.4, -240.0, 554.0, 575.0, tone="slick")
    skin("forja_doorstep", -247.4, -243.4, 571.9, 572.5, tone=BASALT)

    # ============================================================ 6.9 La Luz (6 to 7)
    # The crack's back wall, 1.25 m behind you: the flue's basalt west of a slanting line, pale chalk
    # east of it for the last few metres; the gap's black glassy wall under the chockstone (-240 ..
    # -236.5, 568 .. 575.6), worn smooth; the flint band slanting from the second step to the opening;
    # the edge of daylight painted across it to the climber's raised hand.
    back("forja_crack_back_wall", -250.5, -234.0, 568.0, 590.0, CRACK_FACE, -1.8, tone=CHALK)
    # Eight knobs of the flint band sitting flush in the chalk, either side of the three you hold.
    for x in (-241.0, -240.3, -238.95, -237.9, -236.0, -235.4, -234.9, -234.4):
        A.deco("forja_flint_knob", x, round(575.87 + (x + 241.0) * 5.73 / 6.7 - 0.2, 2), z=-1.45, size=(0.4, 0.4, 0.4), tone="bone")
    # The split in the roof over the chockstone, packed with chalk blocks waiting to fall (the roof's
    # skin is cut through over it).
    back("forja_roof_split", -240.1, -237.5, 582.5, 585.9, CRACK_FACE, -2.45, tone="back")
    skin("forja_crack_steps", -243.4, -240.0, 573.5, 575.5, tone=BASALT)
    skin("forja_chalk_sill", -237.2, -231.0, 579.4, 580.0, tone=CHALK)
    # Foreground: the same basalt fin (at 0.9) in front of the pillar under the steps; a dark chalk
    # overhang in front of the roof over the opening, so the opening is the brightest shape.
    A.deco("forja_basalt_fin", -241.75, 568.0, z=1.6, scale=0.9, size=(3.1, 4.8, 0.6), tone=BASALT)
    A.deco("forja_chalk_overhang", -236.1, 584.8, z=1.65, size=(3.0, 4.1, 0.7), tone="back2")
    # (Through the opening: the Peak's own far layers. The chockstone, the nubs and the climber are
    # a6.py's.)
