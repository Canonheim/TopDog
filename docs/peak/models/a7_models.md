# Los Riscos del Viento: the models to make

The model list for biome 7, from its dress file `tools/peak/areas/a7_dress.py` (198 decos, 22 of
them skins). Every stem in the tables is NEW: not in `kit/models/` nor in `Top Dog Kit\models\`,
nor on the a0 to a5 lists: 73 placed by the dress file and 6 more made for a7.py's movers, ropes,
holds and breaking pieces (section 4). Make each at exactly its size (metres, w x h x d; +z faces the
camera). The game rescales a landed model that is more than a quarter off.

Reused (not listed): `ex_riscos_tower_top` (1, **it becomes the game piece**: section 1),
`streamer_pole` (6, the flags, at 0.4 to 0.75: 1.6 to 3 m; its streamer flies +x, flipped where it
streams west), `wind_sock` (2: the porch's, streaming west; the station's, flipped, east),
`bunting_pole` (3: the two socks' posts at 0.75 and 0.9375, the pennant line's pole), `vulture_nest`
(7, at 0.625 to 1.0: 1.0 to 1.6 m across), `bone_pile` (3), `frog_sit` (1, the frog in the far
nest), `frog_tea` (1, the frog at tea), the tea things `tea_table_low`, `tea_pot`, `tea_cup`,
`tea_cushion` (2), `tea_tins_shelf`, `tea_brazier`, `tea_kettle`, `lantern_hang` (the tea cave's lit
lantern), `lantern_cold` and `mine_lantern_bracket` (the station's cold lantern on its bracket),
`plank` (13, as boards 0.7 to 2.0 m: the stack of split planks, the fallen and spare bridge boards,
the broken treads, the driver's bench, the missing platform board), `iron_peg` (5: the bench's two,
the tea cave's three), `iron_peg_stub` (13: La Cornisa's back row, the snapped stubs up the tower to
the porch), `dead_tree_crown` (1), `dead_tree` (1, at 0.4, on the arch's body), `rock_fence_frame`
(1), `rubble_pile` (1), `boulder` (3, at 0.917: the next three on the pile), `sign_pug_arrow_east`
(1), `sign_warn_bang` (1, note 67), `pylon_head_low` (1), `cable_station_low` (1), `pennant_line` (2,
tiled, at 1.056). a7.py's holds wear `forja_flint_knob` (a6's knob, the same as the chimney's La Luz:
18 knobs) and `iron_peg` (La Cornisa's six pegs): its FOR THE AREA FILE item 8.

Makers: **A** cliff masses, rock, far cards, the scaffold's big pieces (here: every painted wall
skin of the course, every body behind, the shoulder's four cards, the chalk lips, the tea cave's
room, the outcrops and the grey flints, the dead tree's trunk, the scaffold and the wheel's
backboard). **B** props, plants, small dressing, the tea cave's things (here: the cliffs' two
painted plants, the dead wood of the boughs and the snag, the burros' loads, the saddle, the
blankets, the rug). **C** timber, iron, rope hardware, the bridge, the wheel's frame (here: the
trail's poles, posts and hoists, the bridge's anchors, bearers, stubs and halves, the hitching pegs,
the scaffold's legs and front posts, the drum and its bearing, the haul cable, the deck's back and
frame, the long brace).

The cliffs' look (the sheet `docs/peak/playtest/design/data/a7_biome.py`): chalk in level beds split
by upright joints, so it breaks into flat ledges, towers and thin fins. **What you can hold** is
white chalk, dry and matte (ledge tops, the lips of cracks, knobs, bands), bleached dead wood, honey
planks, hemp rope, rust-orange iron pegs, a vulture's pale legs, a burro. **What you can't** is dark
brown rock polished to a gloss, the black lightning scar, a vulture's dark body. **It will break**:
cracked already, with a corner gone; on wood a split along the grain at the join and a strip of bark
hanging. **Scenery** is rock a step or more behind the climb: grey-tan, cooler and duller than the
white chalk, never glossy. NOTHING HERE IS GREEN: dry grass in tufts and one dry shrub. The pack
trail is what a burro can carry: split honey planks, hemp rope, poles lashed with rope, rust-orange
iron hammered into the rock; nothing square, everything mended once. The station's scaffold is the
first sawn and painted timber since the town: square posts in yellow ochre, braces in the cableway's
red, iron plates with the pug's face at the joints. Never here: brick, carved stone, black forge
iron, crystal, a lit lantern outside the tea cave, any cloud of our own. Light: hard blue daylight,
the sun high, shadows short and hard, the undersides of the arch, the cornice and every roof in cool
blue shade (paint it); the only warm light is the tea cave's, amber, shown as colour on its walls;
by the low station the light has begun to turn gold. No glowing materials (the game adds the
lights).

**THE WALLS RULE WAS INVENTED HERE** (BRIEF.md "Walls and masses"; the reference is
`ex_riscos_tower_top`, `docs\peak\playtest\design\walls_example_after.png` and
`Top Dog Kit\previews\ex_riscos_tower_top_game.png`; the library is `source\stn_a_paint.py` and
`stn_a_lib.painted_model()`). Every rock piece below is made that way: each face a few large gently
slanted planes of dark brown (folds under 25 degrees, so no ink inside a face); the chalk's beds
long wandering wavy lines and bands of flat colour 0.3 to 0.9 m thick in three or four browns, a
paler dry bed now and then, running the length of the face; NO RAIN STREAKS, nothing painted that
narrows to a point, no stain shaped like a wedge, no band that thins away; no dark slot or recess
cut into a face; a white hold is one of the rock's own beds standing proud where it is held, a plain
block or band with square ends; only a few big breaks are real shape (an overhang with its shadow
painted under it, a ledge with something on it, a leaning slab, a broken tip); the outline is
designed (away from holds and the tops you stand on it moves up to 0.8 m: it leans, tapers, is
notched where a piece has gone, with no long ruled edge); no tiling, no square panel repeated, no
bed built as its own block. A few small outcrops carry the cliffs' own flat painted plants
(`riscos_grass_tuft`, `riscos_shrub_flat`). Each body behind is ONE big form in two or three slanted
planes, grey-tan, duller and cooler, its beds painted as thin darker lines that carry on the wall's
own bed lines, an uneven skyline.

"Origin: foot" means the middle of its base (x and z) at its lowest point; for long pieces, the
middle of its x span, the bottom of its box, the middle of its depth. "Wall" means the middle of its
foot line, its back on the wall. "Skin" means the model is the look of course solids (`skin=` in
a7.py, its FOR THE AREA FILE item 5): it fills them, z -1.2 .. 1.2, its outline is theirs where they
are held or stood on, its size is theirs (never rescaled); the dress file's skin box is (x0 .. x1,
y0 .. y1) as named in each row. `rot` in the dress file is counter-clockwise as the camera sees it:
make every piece upright and level unless the row says it is made in place.

## 1. Walls, masses and the big pieces (maker A)

**The game piece: `ex_riscos_tower_top`** (the kit's design proof, P-A5 in
`Top Dog Kit\docs\PARTS.md`; already in `kit\models\`). It is placed by the dress file as the real
piece, a skin of the tower's top (7.8, 7.9, 7.10): measured x -4.80 .. +5.12, y 0 .. 22.4, z -3.6 ..
+1.2 (9.92 x 22.4 x 4.8), origin the course's (-207.0, 656.0, 0), the foot of the chimney's middle
on the play plane. It is no longer "not a game piece, not to be synced". Two changes, then it lands
under the same stem: **(1) its walls start at 658, not 656**: the upper window R7 is open to 658
(a7.py line 91), and the fin and the lower east wall stand 2 m down into the window's air today (x
-210.7 .. -208.2 and -206 .. -203.3, y 656 .. 658); cut them at the window's roof; the body behind
may stay down to 656 (it is the window's back, and the dress file's `riscos_tower_body_high` meets
it there). **(2) The split's back wall** (page 7.9): on the body behind the chimney (x -208.2 ..
-206, 658 .. 676, its face about 1.3 to 1.6 m behind you) the joint runs up the middle as a dark
painted line and the three hard beds cross it as three pale bands that step down a metre at the
joint (west 666.8, 669.4, 671.9; east 665.75, 668.2, 670.7), every band you hold being the end of one
of them. Everything else stays exactly as it is (round four).

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `riscos_balcon` | 28.0 x 5.05 x 2.4 | skin (x -232 .. -204, y 573 .. 578.05) | 7.1: El Balcon, one hard bed of chalk standing out of the face as a shelf 22 m long (a7.py lines 52-54). Its top dry white chalk, matte, the burros' worn way trodden down its middle (a paler band from under the door to the crack's foot, x -230 .. -210.4); its front and underside dark brown and polished in long wavy beds; under the tower (x -210 .. -204, 577.4 .. 578.05) the lip stays slick and dark, the one dry shrub's root (a7.py's hold) on its east end. The underside's outline may move (a notch where a block has gone); the top is exact | 1 | A |
| `riscos_tower_low` | 6.15 x 46.0 x 2.4 | skin (x -210.15 .. -204, 578 .. 624) | 7.1, 7.2: the near tower from the shelf to the window's floor, the alcove R1 cut in it (x -210 .. -206.5, 589.8 .. 594.2). Its west face the upright joint opened by frost in three lengths (579.4 .. 581.4, 583 .. 584.6, 586.3 .. 588.2), each with lips of fresh white chalk, broken and matte, standing 0.15 proud (the course's patches, x -210.15 .. -209.85); the two lengths between them the hard beds, shut tight, dark brown and rain-polished (they run on round the body as its two bands). The alcove's floor white with 1.1 m of its lip whitewashed by the birds (x -210 .. -208.9); R4's floor white (624). The east face one clean slick drop, nothing pale on it | 1 | A |
| `riscos_tower_mid` | 12.0 x 27.8 x 2.4 | skin (x -216 .. -204, 626.2 .. 654) | 7.5 to 7.8: the tower from the window's lintel to the upper window (its pieces 626.2 .. 639.4 and 641.6 .. 653.8): the low lintel over the window's east mouth; the stair tunnel R5 cut through west to east, three white steps (637.2, 638.4, 639.6) up to the west; the east face a slick drop; R7's floor and its west balcony (to x -216) white on top, the balcony's corbel under it (to 650.5) dark; dry straw painted on the balcony's east end (x -214.1 .. -212.6) where the third burro's kick lands you | 1 | A |
| `riscos_face_slab` | 16.0 x 14.0 x 2.4 | skin (x -246 .. -230, 586 .. 600) | 7.2: the door's lintel and the 51 degree slab under the nest ledge (FACE edges 1 and 3, line 76): dark brown and glossy in long wavy beds, nothing pale on it from the ledge's lip to the bottom, so it reads as a slide (no streaks: the walls rule). The nest ledge R2's top white (x -243 .. -238 at 600), 1.5 m of its lip whitewashed (x -239.6 .. -238.1). One outcrop on its front over rock, its foot at (-243.0, 594.0, z 1.2) | 1 | A |
| `riscos_west_face` | 21.5 x 84.04 x 2.4 | skin (x -260 .. -238.5, 599.98 .. 684.02) | 7.2 to 7 to 8: the whole west face above the slab (FACE edges 4 to 11 and the mountain behind it, line 78): the nest ledge's back wall and roof, the wall under the arch's springing, the face behind the gully, the gully's head R6 (its top white, x -249.5 .. -244 at 647.6), its back wall, and the bare face up to the deck, all slick brown in long wavy beds that run on from the slab's. The faces where it meets the air are the course's; deep in the rock its edge is free. Two outcrops on its front over rock, feet at (-253.5, 637.0) and (-255.5, 668.0), z 1.2. **The tea cave's room is cut through it** (x -245.4 .. -240.34, 641.37 .. 643.77: a7_dress item 6a) | 1 | A |
| `riscos_dead_tree` | 14.96 x 19.62 x 2.4 | skin (x -243.28 .. -228.32, 599.59 .. 619.21), made in place | 7.3: the dead tree's trunk (lines 164-166), 24 m leaning 37 degrees off plumb from the back of the nest ledge (-243, 599.8) out under the arch toward the keyhole, 0.7 thick: bleached silver white, smooth, bark gone but for strips; its lower 8 m and top 4.5 m dry and pale (held); between them 11.5 m of BLACK GLASSY LIGHTNING SCAR, a forked jagged edge at both ends so it is plainly lightning, a split up its middle; three roots spreading from its first metre into the rock beside the nest. The stubs are item 8's (section 4) | 1 | A |
| `riscos_keyhole_fin` | 3.8 x 10.0 x 2.4 | skin (x -223.8 .. -220, 614 .. 624) | 7.3, 7.4: the fin hanging from the arch's crown under the keyhole (line 182), its foot tapering to a blunt point (-221.5, 614: blunt, square-ended, not a spike), dark brown in beds; the keyhole's floor and sill R3 white (line 183) | 1 | A |
| `riscos_cornice` | 9.3 x 10.95 x 2.4 | skin (x -204 .. -194.7, 626.2 .. 637.15) | 7.5: La Cornisa (line 203), one hard bed jutting 9 m east from the tower like a hat's brim: its underside a seam of dark flints in cool blue shade (the white knobs are a7.py's holds), its sloping back (40 degrees) dark brown and polished between the pegs, a ring of white chalk dust painted round each peg's root (x -196.3 .. -202.8 up the slope) | 1 | A |
| `riscos_flint_nose` | 1.8 x 2.35 x 2.4 | skin (x -196.1 .. -194.3, 627.5 .. 629.85) | 7.5: the cornice's nose (line 204): one great boss of white flint in its rind, dry and matte, 1.8 m across, how you get round from the underside to the back | 1 | A |
| `riscos_gully` | 16.0 x 21.6 x 2.4 | skin (x -244 .. -228, 626 .. 647.6) | 7.6, 7.0: the arch's west mass (line 234), its top the boulder gully: three slick treads at 35 degrees polished by the boulders, dark brown with dull grey scuffs and nothing white (the knobs are a7.py's holds); two undercut risers; under each lip a pocket whose floor and step are dry white chalk (lines 262, 263), roofs and backs dark; the arch's underside (626 to 628.9) in blue shade. The tea cave's doorway (2.2 m, white chalk jambs) through the upper pocket's back and the room's new floor (dry white chalk worn smooth, x -245.4 .. -240.34 at 641.37) are part of it (item 6a) | 1 | A |
| `riscos_counter_slope` | 14.0 x 11.6 x 2.4 | skin (x -224 .. -210, 628 .. 639.6) | 7.6: the arch's east mass (line 235): a slick 33 degree counter-slope falling from the tower's stair tunnel into El Ojo, dark and polished; under it the keyhole's roof in blue shade | 1 | A |
| `riscos_gully_roof` | 9.4 x 5.8 x 2.4 | skin (x -253 .. -243.6, 653 .. 658.8) | 7.6, 7.7: R6's roof (line 238), the boulders' road: its sloping back dark with grey scuffs where they roll, its underside in shade over the first burro | 1 | A |
| `riscos_needle_top_a`, `riscos_needle_top_b` | 3.4 x 3.5 x 2.4 each | skin (x -236 .. -232.6, 646.5 .. 650; x -226 .. -222.6, 648.7 .. 652.2) | 7.7: the two burro ledges and the wedges under them (lines 298-299): each the flat top of a needle, white chalk, dry straw painted on its west end (x -235.7 .. -234.2; -225.7 .. -224.2) where a kick lands you; the wedge under it dark, its foot blunt. Made separately (two pieces, not one repeated) | 1 each | A |
| `riscos_horn` | 3.4 x 12.0 x 2.4 | skin (x -185.2 .. -181.8, 642 .. 654) | 7.8: El Cuerno, the lone horn of chalk (lines 318, 319): its 3 m of flat top white, its sides slick brown, its foot blunt | 1 | A |
| `riscos_chalk_plug` | 3.0 x 2.0 x 2.4 | skin (x -253 .. -250, 686 .. 688) | 7 to 8: the cliffs' last white chalk, the plug at the deck's west end (line 378): dry, matte; the deck's first plank cut to fit against it | 1 | A |
| `riscos_balcon_back` | 18.4 x 22.5 x 3.75 | foot (x -220.8, y 573), z -5 .. -1.25 | 7.1: the shelf carried on 3 m behind the walk as floor (top 578, from z -1.25) to a back wall of grey-tan cliff (face z -4.2) that is tall by the door and comes down in steps of one bed each to a low kerb: outline (-230, 573) up to 595.5 at x -230 .. -231, steps down at x -229 (to 590, then 586.3), -226.6 (583.0), -224.2 (581.4), -222.2 (579.3), the kerb on to -211.6. The step tops are the same two hard beds that close the crack (follow them across the picture). A buttress forward to z -2.7 at x -224.6 .. -222.0 (top 581.4), where the frozen climber sits. Grass tufts stand on four step tops (placed). It starts at the face (x -230): the chimney's door is west of it | 1 | A |
| `riscos_tower_body_low` | 9.0 x 38.0 x 1.75 | foot (x -207.1, y 573), z -3 .. -1.25 | 7.1, 7.2: the tower's body, the near tower being the near edge of a bigger tower of grey-tan chalk 1.5 m behind it, a metre proud on both sides (face z -1.5). The two hard beds run round it as two darker bands that stand out as small ledges (581.4 .. 583, 584.6 .. 586.3), a nest's white streak under the upper one (a band, not a wedge), a long white streak down it from the alcove. The alcove R1 carried back to z -2.6 (its floor at 590 and its roof: the near nest and the larder sit there). One outcrop foot at (-210.9, 603.5, z -1.5). Replaces today's flat tan card | 1 | A |
| `riscos_tower_body_high` | 14.3 x 45.0 x 1.75 | foot (x -209.05, y 611), z -3 .. -1.25 | 7.3 to 7.8: the same body on up to 656, where it meets the tower top's body exactly (outline x -211.8 .. -201.9, face about z -1.6 to -2.0 there). The window R4 carried back to z -2.2 (the spare boards and the saddle against it); the stair tunnel's back closed; the upper window R7 carried back to -2.2 (the nest, the bone pile, the flag); R7's west balcony and its corbel carried back to z -3 out to x -216.2 (the standing hoist on it). Its east face at x -202.6 at the sign's height (622.9: the bracket is fixed to it). One outcrop foot at (-211.0, 646.6, z -1.5) | 1 | A |
| `riscos_colony_cliff` | 17.4 x 24.5 x 1.75 | foot (x -237.3, y 586.5), z -3 .. -1.25 | 7.2: the face's body behind the slab, grey-tan, showing 1.5 m proud of it all the way down: outline (-246, 586.5), (-228.6, 586.5), (-228.6, 590.4), (-236.6, 600.4), (-236.6, 605.2), (-237.4, 606.6), (-237, 611), (-246, 611). It carries the nest ledge on behind you as a deeper shelf (top 600 from z -1.25: the far nest, the frog and a bone pile on it). On its proud strip three small ledges (at (-234.65, 596.9), (-231.55, 593.0), (-236.4, 599.1)) for three nests, each with a white streak painted under it (bands) | 1 | A |
| `riscos_face_body` | 24.5 x 79.0 x 1.75 | foot (x -249.75, y 611), z -3 .. -1.25 | 7.3 to 7 to 8: the body behind the west face, a metre proud of the face line: outline from x -262 to (-238, 611), (-237.5, 626), (-243, 647.6), (-248.5, 653), (-249.2, 660), (-250, 684), (-250.5, 690). R6's ledge carried back to z -2.6 (top 647.6: the paint tins and a hitching peg on it); R6's roof carried back as a level shelf (top 657.8, x -250.2 .. -247.1) where the rubble pile sits. The tea cave's room is cut out of it. Replaces today's face card (z -2.5) | 1 | A |
| `riscos_arch_body` | 32.4 x 24.2 x 1.75 | foot (x -227.8, y 626), z -3 .. -1.25 | 7.6, 7.0, 7.7: the gully's far wall, the arch's body: behind you it stands higher than the gully's bed all along (15 m at El Ojo, 3 m at the head), its top stepping up to the west (645.6 at x -212, 646.6 at -222, 648.8 at -232, 649.6 at -240, 650.2 at -244, an uneven skyline), so the gully is a trough and El Ojo reads as a well, not a window; its underside the arch's (626 to 629.4) in blue shade. A PALER GREY BAND rubbed along it 0.8 m above each tread (the boulders' line). The lower pocket carried back to z -1.9 (floor 635.03 and roof: the driver's bench); the upper pocket opens into the tea cave (its room is cut out of this body). Two outcrop feet at (-216.0, 642.8) and (-237.0, 645.5), z -1.5. It meets the tower's body at x -211.6. Replaces today's arch card | 1 | A |
| `riscos_fin_body` | 4.2 x 17.0 x 1.5 | foot (x -221.5, y 613), z -3 .. -1.5 | 7.3, 7.4: the hanging fin's body, a thicker fin of grey-tan chalk behind the one you see; it closes the back of the keyhole so it reads as a doorway into rock; a small ledge on its west side at about 616.4 where a fallen board lies | 1 | A |
| `riscos_cornice_body` | 8.4 x 15.3 x 1.5 | foot (x -198.4, y 625.7), z -3 .. -1.5 | 7.5: the cornice's body, the near edge of a thicker bed: outline (-202.6, 625.9), (-195.4, 627.1), (-194.3, 628.2), (-194.2, 630.6), (-197.3, 634.6), (-200.6, 638.2), (-202.6, 640.2); behind you its underside hangs 0.5 m lower than the roof you hold (the grey flints along it, placed), above the sloping back it stands 2 m higher as a step (the back row of peg stubs and two broken treads on its face). Meets the tower's body at x -202.6. Nothing else of ours stands east | 1 | A |
| `riscos_needle_body_a`, `riscos_needle_body_b` | 4.8 x 5.0 x 2.0; 5.0 x 6.8 x 2.0 | foot (x -234.4, y 645; x -224.3, y 645.4), z -3.3 .. -1.3 | 7.6, 7.7: the two needles: stalks of grey-tan chalk 4 m wide standing on the arch's body, each burro ledge the near edge of its flat top, the top going back 2 m behind the ledge (dull tan, straw; the loads and pegs stand on it); the scaffold's struts meet their sides under the ledges. Replace today's two flat cards | 1 each | A |
| `riscos_horn_stalk` | 9.0 x 94.0 x 1.5 | foot (x -184, y 560), z -3 .. -1.5 | 7.8: the horn's stalk coming up out of the throat, wider at the bottom (4.4 m under the top, 9 m at its foot), grey-tan; the horn's top carried back to z -2.6 (the round's other nest and a flag on it), a white streak (a band) down the stalk under the nest. The one thing of ours east of the tower | 1 | A |
| `riscos_shoulder_a` .. `_d` | 58.37 / 53.0 / 46.7 / 39.67 x 34.0 x 0.5 | foot (x -250.815, y 566; -253.5, 600; -256.65, 634; -260.165, 668), z -13.25 .. -12.75 | Every page: the mountain's shoulder, ONE flat cut-out card of the same cliff made the way the far cards are (BRIEF.md "Far backgrounds", the kit's `stn_far_hills`: a thick card whose cut edge shows kraft, a dark stripe, kraft, braces behind), hazed to a mid blue-grey (mid values: the light lifts it), its ledges and beds painted in flush regions, paler toward the top. Its east edge is cut in steps of 4 m that lean back with the face: x -222 at 570, -223 at 585, -226.5 at 600, -229 at 615, -231.5 at 630, -235 at 645, -238.5 at 660, -241 at 675, -243.5 at 690, -245.5 at 700, each step 0.5 east or 0.4 west of that line by turns, a ledge cut at each step; one small dead tree cut into the edge on each section (a trunk 0.3 across, readable at this distance). The four sections stack (566 / 600 / 634 / 668 / 702) and run west to x -280 so their end never shows past the near rock. East of its edge nothing of ours | 1 each | A |
| `riscos_chalk_lip_balcon` | 6.9 x 8.8 x 0.9 | foot (x -232.05, y 570.5), z 1.3 .. 2.2 | FOREGROUND 7.1: a chalk lip at the bottom west corner in front of solid rock and below the walk, its top under the door's sill: outline (-235.5, 570.5), (-235.5, 579.2), (-233, 579.3), (-231.4, 577), (-229.6, 575.4), (-229.2, 572.8), (-228.6, 570.5); white chalk top, dark beds on its front; a grass tuft on it (placed) | 1 | A |
| `riscos_chalk_lip_nidos` | 12.5 x 4.1 x 0.9 | foot (x -239.75, y 586.5), z 1.3 .. 2.2 | FOREGROUND 7.2: the same, in front of the rock under the slab: (-246, 586.5), (-246, 590.2), (-242.5, 590.6), (-239, 589.8), (-235.5, 588.6), (-233.5, 586.5) | 1 | A |
| `riscos_chalk_lip_gully` | 7.7 x 4.2 x 0.9 | foot (x -248.65, y 628.5), z 1.3 .. 2.2 | FOREGROUND 7.6: the same, in front of the face: (-252.5, 628.5), (-252.5, 632.2), (-249, 632.7), (-246.3, 631.3), (-244.8, 628.5) | 1 | A |
| `riscos_tea_cave` | 5.4 x 2.8 x 2.15 | foot (x -242.9, y 641.17), z -3.4 .. -1.25 | 7.0 (note 68): the drivers' shelter dug out of the rock under the first burro's ledge, cut away at the front like a doll's house: its floor's back half (top 641.37), its back wall 2.2 m behind the line you walk (z -3.4), its two side walls (x -245.4 and -240.34 inside) and its roof (2.4 m over the floor), pale chalk with the pick marks still on them, PAINTED AMBER (the lantern's and brazier's light as colour), the roof black with smoke over the brazier (x -241.55) with the crack the smoke goes up. The play space part (the floor and the doorway) is the course's | 1 | A |
| `riscos_tea_cut_edge` | 5.4 x 0.4 x 0.3 | foot (x -242.9, y 640.75), z 1.25 .. 1.55 | FOREGROUND 7.0: a low lip of rock along the room's front edge, its top 0.2 under the floor, to show the room's front was taken away; it covers nothing | 1 | A |
| `riscos_ledge_block` | 0.9 x 0.45 x 0.3 | foot | Every wall: a small outcrop of chalk standing proud of a face, a dull white top with a crisp front edge, two painted beds on its front, its back sunk 0.03 into the face; one of the cliffs' plants stands on it. On bodies (z -1.5) and on the west face's and slab's fronts (z 1.2, over rock) | 7 | A |
| `riscos_flint_grey` | 0.3 x 0.3 x 0.3 | foot | 7.5: a grey flint knob in a dull rind (not white: it is not held), the rest of the cornice's seam along its body's underside, hanging | 8 | A |
| `riscos_scaffold` | 29.2 x 25.8 x 1.55 | foot (x -222.8, y 662.2), z -2.8 .. -1.25, made in place | 7.10, 7 to 8: the low station's scaffold, moved back out of the play space (replaces the kit's `scaffold_frame` here: that one has crossed iron in most bays). Four square posts 0.35 m in yellow ochre at x -237, -229.2, -220.7, -213 from the catwalk (663) to the deck (688); a ledger under every plank you stand on (662.35 .. 662.65 the whole width; 676.35 .. 676.65 x -237.2 .. -220.5 under the stage; 671.35 .. 671.65 x -220.9 .. -208.4 under the platform; 682.3 .. 682.6; 687.35 .. 687.65 under the deck); braces in the cableway's red crossed in the bays x -237 .. -229.2 (663 .. 676.3), -229.2 .. -220.7 and -220.7 .. -213 (663 .. 671), -229.2 .. -213 (682.6 .. 687.3); **NO BRACE behind the wheel (x -224 .. -216.4, 671 .. 679) or behind the long brace (x -236 .. -229, 677 .. 687.5)**; an iron plate with the pug's face at every joint; each plank deck the near edge of a floor going back 1.4 m onto its ledger (z -1.25 .. -2.6). Its legs below the catwalk are separate (`riscos_scaffold_strut`) | 1 | A |
| `riscos_wheel_backboard` | 10.0 x 9.2 x 0.2 | foot (x -220.2, y 670.4), z -2.8 .. -2.6 | 7.10: the wheel's bay closed at the back with plain ochre boards, flat and quiet, so the red rim reads against one colour; nailed to the scaffold's posts | 1 | A |

## 2. Props, plants and small dressing (maker B)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `riscos_grass_tuft` | 0.75 x 0.6 x 0.01 | foot | The cliffs' own dry grass: ONE flat painted card (flush colours on one plane, only its outline inked): eleven fat blunt blades fanned from one foot, the whole tuft leaning east with the wind, bleached straw in three tones, NOTHING GREEN. Its shape is the `tuft` of `plants()` in `Top Dog Kit\source\ex_riscos_tower_top_design.py` (the tower top's own plants, round four) | 15 | B |
| `riscos_shrub_flat` | 1.0 x 0.7 x 0.01 | foot | The cliffs' dry shrub, one flat painted card: a low dome of dry leaf lobes in grey-olive and straw over three fat blunt stubs of silver dead wood sticking out of it (`plants()`'s `shrub`) | 3 | B |
| `riscos_far_bough` | 0.3 x 2.2 x 0.3 | its butt (where it leaves the trunk), pointing +y | 7.3: a long dead bough off the far side of the trunk behind each stub, cut from the kit's `dead_tree`: grey-white, duller than the stubs, smooth, one short fork, a blunt broken end. Placed at 0.7 to 1.3 (1.5 to 2.9 m) | 8 | B |
| `riscos_snag` | 2.67 x 5.87 x 2.4 | skin (x -184.92 .. -182.25, 653.98 .. 659.85), made in place | 7.8: the snag's near parts (lines 320, 321, 323): the stub (from (-182.4, 654) to (-182.7, 656.7), 0.3 thick, bleached silver, a strip of bark); the knot, a branch stub pointing at the camera, a round of pale end grain 0.4 across at (-183.6, 658.2); the bough coming forward from it and ending at the camera, its end a bigger round 0.5 across worn smooth at (-184.7, 659.6). Drawn exactly as held (note 76) | 1 | B |
| `riscos_snag_trunk` | 2.0 x 6.4 x 0.4 | foot (x -182.55, y 654), z -2.05 .. -1.65 | 7.8: the snag's trunk above the stub, leaning back away from you out of the play space and on up to 6.4 m (660.4), leaning west to x -184 at its top, grey-white, the knot's and the bough's roots on it | 1 | B |
| `riscos_paint_tins` | 0.9 x 0.45 x 0.45 | foot | 7.7: the first burro's load, four paint tins, two in the cableway's red and two in its yellow ochre, rusted lids, one dented, a drip down one | 1 | B |
| `riscos_post_bundle` | 1.8 x 0.4 x 0.5 | foot | 7.7: the second burro's load, a bundle of sawn posts painted yellow ochre, roped twice | 1 | B |
| `riscos_cable_coil` | 0.9 x 0.9 x 0.3 | foot | 7.7: the third burro's load, a coil of grey haul cable 0.15 thick standing on its edge, two lashings | 1 | B |
| `riscos_post_stack` | 2.8 x 0.45 x 0.6 | foot | 7.10: a stack of ochre posts carried up and never used, against the catwalk's handrail | 1 | B |
| `riscos_tea_rug` | 2.6 x 0.03 x 1.2 | foot | 7.0: a woven rug in the town's colours (rosa, turquoise, marigold and cream stripes, a zigzag border), fringed ends, on the back half of the floor | 1 | B |
| `riscos_pack_saddle` | 0.6 x 0.5 x 0.4 | wall (its back on the wall) | 7.4, 7.0: a burro's pack saddle, two padded boards on a wooden frame with a girth strap hanging, on a peg; the same piece in the tower's window and in the tea cave | 2 | B |
| `riscos_blanket_folded` | 0.5 x 0.6 x 0.2 | wall | 7.0: the burro's striped blanket folded over a peg | 1 | B |
| `riscos_door_blanket` | 0.35 x 1.6 x 0.2 | foot | 7.0: a striped burro blanket hung as a door curtain from a short rod and tied back with a cord to a peg on the doorway's far side, gathered: from the gully the one patch of bright colour in the rock | 1 | B |

## 3. Timber, iron, rope and the wheel's frame (maker C)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `riscos_trail_post` | 1.0 x 3.0 x 0.2 | the pole's foot (the rag reaches 0.9 west) | FOREGROUND 7.1: one trail post on the lip beside the door, a lashed pole 0.2 thick and 3 m tall, two rope lashings, a rag of the town's bunting tied under its top, streaming west. The only thing on the cliffs you pass behind (one step) | 1 | C |
| `riscos_hoist_fallen` | 5.8 x 0.9 x 0.8 | foot | 7.1: the trail's hoist lying at the tower's foot: two poles 5.5 m long still lashed together at the head (east), the pulley block on the lashing, NO ROPE; honey wood gone grey at the ends | 1 | C |
| `riscos_hoist_standing` | 2.8 x 4.1 x 0.6 | the middle of its two feet (the box reaches 2.4 m west of it) | 7.7: the same hoist standing on the back of the tower's balcony: two lashed poles 4.3 m leaning out west over the gap toward the second needle, the pulley block at the head, no rope, its feet lashed to an iron peg | 1 | C |
| `riscos_bridge_post` | 0.9 x 1.6 x 0.25 | the post's foot (the tassel reaches 0.6 east) | 7.4: an anchor's back post, honey timber 0.25 thick and 1.6 tall, the back hand rope still knotted round its top and frayed off after 0.6 m like a tassel. The east one is flipped | 2 | C |
| `riscos_bearer_strut` | 1.5 x 1.42 x 0.2 | the strut's foot on the rock (the pole runs +x out of the rock at the top) | 7.4, 7.8: a bearer pole out of the rock with a raking strut under it, lashed; under each stub of deck (the east one flipped) and, at 0.75, under the perch plank | 3 | C |
| `riscos_post_stump` | 0.25 x 0.3 x 0.25 | foot | FOREGROUND 7.4: an anchor's front post snapped off 0.3 m above the floor when the bridge went, a splintered top | 2 | C |
| `riscos_deck_stub` | 1.5 x 0.55 x 1.0 | skin: the middle of its x span at the deck's underside (623.75); the boards 0.25 up from it, the frayed ends 0.3 below | 7.4: a stub of the bridge's deck (lines 184, 185): three honey boards on two bearers, the last snapped across with splinters, frayed rope ends hanging 0.3 under it. The east one is the same piece flipped | 2 | C |
| `riscos_hitch_peg` | 0.15 x 0.7 x 0.15 | foot | 7.7: an iron hitching peg driven into a ledge's back, rust orange, a ring near its top with a frayed end of halter knotted on | 3 | C |
| `riscos_scaffold_strut` | 0.3 x 13.8 x 0.3 | its iron shoe (the strut rises +y) | 7.7: a scaffold leg, a raking strut 0.3 square in yellow ochre from a catwalk post down to an iron shoe bolted into the rock, a pug plate at its head. Placed at 0.95 to 1.0, rot -6.6 to 11.3. **Pending Parker's answer to page 7.7's ask** (a7_dress item 7g) | 3 | C |
| `riscos_scaffold_strut_short` | 0.3 x 9.2 x 0.3 | its iron shoe | 7.7: the fourth leg, onto the back of the tower's balcony (the same make) | 1 | C |
| `riscos_wheel_drum` | 5.0 x 5.0 x 0.6 | its axle | 7.10: a plain grey drum 5 m across on the bull wheel's axle, 2 m behind the wheel, a groove round its rim where the haul cable runs (the cable is separate): why the wheel turns. It follows the wheel (a7_dress item 8) | 1 | C |
| `riscos_axle_bearing` | 1.0 x 1.0 x 0.3 | foot | 7.10: the axle's iron bearing block bolted to the scaffold's third post, a pug plate above it | 1 | C |
| `riscos_haul_cable` | 28.6 x 26.4 x 0.15 | foot (x -224.7, y 672.35), z -2.075 .. -1.925, made in place | 7.10, 7 to 8: the haul cable, one piece: black, greased, 0.15 thick and taut (not to be taken for a rope), 2 m behind you. Its road: from biome 8's wheel over the dock (r 2.2 at (-237.2, 697); leaves it at (-236.4, 698.6) and (-238.9, 695.7)) down to the pylon head's first sheave top (-213.4, 677.5), across to the drum's top (-220, 677.5), round the drum to its bottom (-220, 672.5), to the second sheave (-211.4, 676.5 .. -211.0, 677.5) and back up. Both long runs at least 6 m over the stage and the brace, the short ones 2.5 m over the platform | 1 | C |
| `riscos_trail_rail` | 23.2 x 1.15 x 0.15 | foot | 7.10: the pack trail's handrail along the back of the old catwalk: lashed poles 1.1 m high on posts at x -236.4, -232.8, -225.2, -217.0, -213.6, unpainted grey-honey, rope lashings, one rag of bunting | 1 | C |
| `riscos_front_post` | 0.3 x 24.4 x 0.3 | foot | FOREGROUND 7.10: the scaffold's front west post, 0.3 square, yellow ochre, a pug plate at each ledger's height (662.5, 676.5, 682.45, 687.5), from the catwalk to the deck's underside | 1 | C |
| `riscos_front_post_short` | 0.3 x 8.4 x 0.3 | foot | FOREGROUND 7 to 8: the same post in front of the deck's west end, from below the frame to just under the deck's top | 1 | C |
| `riscos_deck_back` | 14.0 x 0.5 x 1.19 | foot (x -243, y 687.5), z -2.44 .. -1.25 | 7 to 8: the deck's planks carried back to the station house's door: honey planks laid across, 0.3 wide, two rows of nail heads, sawn square and nailed (the old catwalk's planks, but new) | 1 | C |
| `riscos_deck_frame` | 14.8 x 7.85 x 0.35 | foot (x -243.4, y 679.5), z -1.8 .. -1.45, made in place | 7 to 8: what carries the deck's west half: a ledger under its planks (x -250 .. -236 at 687.05 .. 687.35) and two raking struts in yellow ochre from the ledger down to iron shoes in the face ((-244, 687.05) to (-250.8, 681.4); (-239, 687.05) to (-247.6, 679.5)), a pug plate at each strut's head | 1 | C |
| `riscos_brace_foot` | 2.59 x 3.65 x 2.4 | skin (x -231.47 .. -228.88, 677.22 .. 680.87) | 7.10: the long brace's foot length (line 371, 4.2 m from the stage): one of the scaffold's own braces, 0.3 thick, in the cableway's red, matte, worn to bare honey wood along its top where hands have gone, bolted at its foot through a pug plate | 1 | C |
| `riscos_brace_head` | 3.25 x 4.62 x 2.4 | skin (x -235.92 .. -232.67, 682.86 .. 687.48) | 7.10, 7 to 8: its head length (line 373, 5.4 m) up to the deck's end beam, bolted through an iron plate with the pug's face (the last of the scaffold) | 1 | C |

## 4. Made for a7.py, not placed by the dress file (its FOR THE AREA FILE item 8)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `riscos_tree_stub` | 0.44 x 0.44 x 2.4 | the stub's centre | 7.3: one of the eight stubs crossing the scar (line 168): the broken root of a branch, bleached white, a ring of pale splintered wood at its end facing the camera | 8 (by a7.py) | B |
| `riscos_branch_break_a` | 2.9 x 0.22 x 2.4, made in place | its middle (along (-228.6, 619.0) to (-226.5, 621.0)) | 7.3 (note 65): the first breaking branch (line 169, rotten): a real bough of the tree, bleached, tapering but blunt-ended, with twigs, SPLIT ALONG THE GRAIN AT THE JOIN with a strip of bark hanging; it creaks and dips, goes in splinters and grows back from the join after 8 s | 1 (by a7.py) | B |
| `riscos_branch_break_b` | 2.3 x 0.2 x 2.4, made in place | its middle (along (-226.2, 621.3) to (-224.7, 623.0)) | 7.3: the second (line 170, brittle), the same make; the keyhole's sill is 1.35 m from its tip | 1 (by a7.py) | B |
| `riscos_brace_rotten` | 2.6 x 0.3 x 2.4, made in place | its middle (along the brace from 4.2 to 6.8 m up it) | 7.10: the long brace's rotten length (line 372): the red paint gone, the wood grey and split along the grain, a corner missing; creaks and dips before it goes in splinters | 1 (by a7.py) | C |
| `riscos_bridge_half` | 1.0 x 5.3 x 0.3 | its top (where it hangs from the stub's end) | 7.4 (note 66): one hanging half of the broken rope bridge as the rope's look (ropes 187, 188): two hemp side ropes 0.3 m apart as the camera sees it (nearly edge-on), a ladder of honey boards between, three gone; all of it holdable (item 6b) | 2 (by a7.py) | C |
| `riscos_bridge_board` | 1.2 x 0.14 x 0.9 | its hanging point (one end) | 7.4: the lowest board of each half, hanging by one end, the board you catch (each rope's bob model) | 2 (by a7.py) | C |

**Re-made, not new stems** (a7_dress items 6 and 8): `bull_wheel` (note 76, Parker 11-13: "Draw it
at 7.6 m": red rim, six cream spokes, the pug on the hub, origin the hub, made 7.6 m across so the
rim that is drawn is the rim you hold; then a7.py drops model_scale 1.52; C); `vulture` (page 7.2:
the kit's is perched; re-made flying, wings spread, legs hanging straight down, pale and bare,
exactly the held box 0.28 x 0.5 under its origin, the body and wings dark; B); `burro` (note 76: if
the course keeps the 1.3 m solid, the model is made to agree; if the head and neck become solid, it
stays; it faces west by the mover's flip; B); `rock_fence_frame` (only if, in the frames, its own two
rails read as holds beside the course's three: page 7.6 draws four leaning posts, rope lashings and
torn rope netting in two pieces under the first rail and a heap at its foot; C).
