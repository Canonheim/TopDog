# El Templo del Primer Perro: the models to make

The model list for biome 5, from its dress file `tools/peak/areas/a5_dress.py` (257 decos, 54 of
them skins; 40 torches). Every stem here is NEW: not in `kit/models/` nor in `Top Dog Kit\models\`,
nor on the a0 to a4 lists. Make each at exactly its size (metres, w x h x d; +z faces the camera).
The game rescales a landed model that is more than a quarter off. Reused (not listed): `torch_wall`
(40), `temple_banner` (5, at 0.6: 0.95 x 3 m), `pug_mask` (5, the stone plaques, at 1.67 to 3.78),
`altar` (2: the altar, and the sacrifice stone at 0.733; **only these two are `altar`**, because
"Pay Your Respects" finds its altars by that name), `mask_first_dog` (1, at 2.1, as today, set back
0.5 m), `serpent_head` (1, at 1.1), `drum_temple` (1, at 0.85), `counterweight_hung` (1, at 0.62)
and `counterweight_chain` (1, the gullet's), `frog_sit` (1), a4's `jardin_root_flat` (1, at 0.45: the
garden's root in the door's joints). a5.py keeps every mover's model (re-makes below).

Makers: **A** buildings, walls and stone masses, far cards, big carved pieces (here: every hall's
painted wall and the floors carried back, the shell's skins and every stone skin of the course, the
platform, the great mask's holds, the champions, the niches, doorways, pilasters, columns, the sun
stone, the vault). **B** props, small dressing (here: the forearms, offering niches and sprigs, the
frog's things, the incense jars, the grease trough, the drum's shelf, the brackets, the jade eyes).
**C** bronze, machines (here: every bronze-lined slot and track, the bronze jaws, the axle cheeks,
the chain bosses, the pan hangers, the mallet, the serpent's tail tip).

The temple's look (the sheet `docs/peak/playtest/design/data/a5_biome.py`): big blocks of pale stone
fitted without mortar, joints tight; walls stepping back as they rise, a sloped base and a flat band
above it; doorways and passages stepped arches (two sides stepping in to a flat lintel). **What you
can hold** is pale dry stone, deeply carved; bone; gold; bronze chain; matte. **What you can't** is
polished black stone, wet with soot, smooth, with pale runs (the piston shaft's walls, the ramps, the
fangs). **It will break**: pale stone already cracked through, with a corner gone. **It moves**: it
wears a JADE BAND (Parker, 11-13: round everything that moves), it sits in a slot or on an axle you
can see. **Scenery**: the same stonework further back, browner and darker, its carving shallow;
statues in the scenery have their arms down. **It will hurt you**: it is edged in DARK BRONZE. Gold
caps the things that matter (the teeth, the altar, the censers' lids). **No carving ever shows how a
challenge is done** (Parker, 11-13): the carved band is pug faces, belts and bones only; the fall
strip is bones. Walls and masses are PAINTED (BRIEF.md "Walls and masses"; the reference is
`docs\peak\playtest\design\walls_example_after.png`): a few big planes; the courses of blocks long,
a little uneven, wavy painted bands in three or four tones with the joints as thin lines (never a
course built as its own block, never a repeated square panel); the carved band a painted band 0.8 m
tall at the temple's heights (371.8, 377.6, 383.4 in the entry hall; 417.8, 423.6, 429.4 in the gear
room; 435.8, 441.6, 447.4 in the great hall; 472.4 over the stair; 483.0 at the altar and the sill),
cut deep and real only where it is held; nothing painted narrows to a point; no dark recess cut into
a face (the stepped doorways, the slots and the niches named here are the few real breaks); behind
each mass the hall's wall carries its courses on as thin lines, browner and darker. Light: torch gold
in the play space, the halls behind falling away into brown with far torches as points; jade and gold
catch the light; no glowing materials (lit things are colour: the game adds the lights).
**Judge every wall in the temple's own torchlight**: tonight's game frames from the dark places
showed painted bands vanishing wherever their values sit close together. Step the tones well apart,
and look at each wall under warm torchlight falling to brown before it lands.

"Origin: foot" means the middle of its base (x and z) at its lowest point; for long pieces, the
middle of its x span, the bottom of its box, the middle of its depth. "Top" means the middle of its
top (it hangs from there). "Wall" means the middle of its foot line, its back on the wall. "Skin"
means the model is the look of course solids (`skin=` in a5.py, its FOR THE AREA FILE item 5): it
fills them, z -1.2 .. 1.2, its outline is theirs, its size is theirs (never rescaled); the dress
file's skin box is (x0 .. x1, y0 .. y1) as named in each row. `rot` in the dress file is
counter-clockwise as the camera sees it: make every piece upright and level unless the row says it
is made in place.

## 1. Walls, masses and the big pieces (maker A)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `templo_entry_back_wall` | 63.0 x 60.0 x 1.0 | foot (x -340.5, y 366), z -7 .. -6 | 5.1 and 5.2: the entry hall's back wall, made in place. Wall bays of pale fitted blocks painted as long courses, the carved band at 371.8, 377.6 and 383.4, 6 m back in brown shadow, running the whole width and out of the top (note 51). Its top follows the great hall ramp's underside ((-357.2, 425.8) down to (-318, 404)), level at 426 west of x -357.2 (behind the pier, the shaft and the mask), open over the drain (x -318 .. -313) where the fall strip goes on up. The two doorways, the plaques and the fall strip are separate | 1 | A |
| `templo_floor_back` | 33.0 x 3.0 x 4.75 | foot (x -325.5, y 363), z -6 .. -1.25 | 5.1: the entry floor's fitted paving carried back to the wall (the doorways and the forearms stand on it); the worn dish under the drain (x -318 .. -313) scuffed pale | 1 | A |
| `templo_chute_back` | 30.0 x 22.5 x 4.75 | foot (x -357, y 363), z -6 .. -1.25 | 5.1, made in place: the chute's polished black slope carried back under the platform and the mask, its top the chute's line (-342, 366) up to (-372, 385.5), pale runs down it | 1 | A |
| `templo_platform` | 22.0 x 15.0 x 4.2 | foot (x -343, y 366), z -5.5 .. -1.3 | 5.1, made in place: the body of the stepped platform the mask sits on, right behind the tiers; each tier you touch is the front edge of a terrace running 4 m back. Outline: (-332, 366), up the five tiers (3 m deep, 2.5 high each) to the landing (x -354 .. -347 at 381), its foot following the chute. On its face under each tier the carved band (pugs, belts and bones). Cut along its face: the three slots the `templo_tier_slot` linings sit in (x -340.7 .. -335 at 369.9 .. 371.05, -346.7 .. -341 at 374.9 .. 376.05, -349.7 .. -344 at 377.4 .. 378.55), and a shallow torch niche at (-336.5, 368) | 1 | A |
| `templo_door_side` | 3.5 x 16.0 x 1.75 | foot (x -307.25, y 366), z -3 .. -1.25 | 5.1, the join 4 to 5: the side of the doorway through the well's wall, the same pale blocks; at its head it steps out to carry the stone beam the two banner chains hang from (the beam is a skin). One thick root of the garden lies in its first joints (a4's `jardin_root_flat`, placed) | 1 | A |
| `templo_fall_strip_low`, `templo_fall_strip_high` | 5.0 x 38.0 x 0.4; 5.0 x 32.0 x 0.4 | foot (x -315.5, y 366), z -6 .. -5.6; foot (x -315.5, y 404), z -9 .. -8.6 | 5.1 and 5.6 (KIT_MORE): a carved strip 5 m wide of BONES TUMBLING, from the censer's height down the great hall's far wall behind the drain's mouth (`_high`) and on down the entry hall's wall behind the drain's landing (`_low`); the same strip, two depths. Shallow pale carving on a darker ground; bones only, nothing that shows a way | 1 each | A |
| `templo_shaft_back_wall` | 20.5 x 22.0 x 0.5 | foot (x -364.25, y 390), z -2.7 .. -2.2 | 5.3, made in place: fitted blocks a shade browner than the bolts, DRY AND CARVED (to show what the polished black side walls are not), 2.2 m behind you: the shaft x -372 .. -366.5 from 390 (down behind the throat) to 412; east under the pier behind the walk (x -366.5 .. -354, 390 .. 400), the carved band along its top (399.2 .. 400); the plunger's guide, the nine tracks and the niche are separate | 1 | A |
| `templo_brow_back` | 12.3 x 1.2 x 0.95 | foot (x -360.35, y 395.2), z -2.2 .. -1.25 | 5.2 and 5.3: the brow's cornice carried back to the shaft's wall under the pier, pale carved stone, its shadow painted under it | 1 | A |
| `templo_gear_back_wall` | 22.0 x 28.5 x 0.6 | foot (x -363.5, y 408.5), z -3.4 .. -2.8 | 5.4 and 5.5, made in place: the gear room's back wall, wall bays browner than the cogs, the carved band at 417.8, 423.6, 429.4 (x -374.5 .. -360.2, 408.5 .. 434); at its top right it carries on east behind the west balcony (x -366 .. -352.5, 430 .. 437), its top there a cornice with its shadow painted (the great hall's far wall beyond). Black runs of grease are on the posts, not on it | 1 | A |
| `templo_pier_top_back` | 8.0 x 0.9 x 1.55 | foot (x -364.2, y 411.1), z -2.8 .. -1.25 | 5.4: the pier's top (R3) carried back to the gear room's wall; the east post stands on it | 1 | A |
| `templo_hall_far_wall` | 57.0 x 49.0 x 1.0 | foot (x -337.5, y 404), z -10 .. -9 | 5.5 and 5.6: the great hall's far wall, 9 m back and brown with shadow, wall bays from the ramp to the gallery, the carved band at 435.8, 441.6, 447.4 (and left out behind the censer's swing, x -326 .. -314, from 436 to 447: bare stone so the gold bowl and its smoke show); on east behind the keeper's balcony and the chain to the well's wall (note 51). The two tall niches stand on it | 1 | A |
| `templo_ramp_back` | 39.2 x 25.0 x 7.75 | foot (x -337.6, y 404), z -9 .. -1.25 | 5.5, made in place: the great hall's ramp carried back to the far wall at its 32 degrees ((-353, 429) to (-318, 407.2)), polished black with long pale scrapes and three deeper gouges where the forearms went down; its underside the lower hall's ceiling (dark dressed stone), from (-357.2, 425.8) to (-318, 404) | 1 | A |
| `templo_gallery_back` | 39.2 x 3.0 x 7.75 | foot (x -332.4, y 450), z -9 .. -1.25 | 5.5 and 5.7: the gallery floor carried back as the great hall's roof (underside dark stone, a coffer line or two), its two light slots (x -337.92 .. -336.68 and -327.92 .. -326.68) cut right through all the way back, their insides polished black | 1 | A |
| `templo_balcony_back` | 12.0 x 1.0 x 1.55 | foot (x -359, y 429), z -2.8 .. -1.25 | 5.5: the west balcony carried back to the wall behind it; the first champion's broken forearm lies on it | 1 | A |
| `templo_keeper_alcove` | 3.8 x 14.3 x 1.75 | foot (x -310.9, y 442.7), z -3 .. -1.25 | 5.6: the keeper's balcony carried back to a wall 3 m behind it (the doorway, jars and ladle are separate), and above it the chain's shaft to the stone over it at 457, its walls lit warm; the shaft's sides the same pale blocks | 1 | A |
| `templo_upper_back_wall` | 42.5 x 23.0 x 0.6 | foot (x -344.75, y 450), z -3.2 .. -2.6 | 5.7, 5.0, 5.8, 5.9, made in place: wall bays behind the gallery, the open west end, the serpent and the stair, without a break (note 51). Its lower edge at the gallery's level; over the open west end (x -366 .. -352) that edge is a cornice with its shadow painted, the great hall's far wall below. Its top under the serpent's roof (466.5) west of x -341, 473 from there to -332, 457.5 east of that (under the spine). Behind the serpent (x -363 .. -344, 458 .. 466) the blocks carved in shallow relief with its coils and scales, browner than the spine; the carved band high over the stair (471.6 .. 472.4), NOTHING near the scale | 1 | A |
| `templo_ledge_back` | 3.7 x 0.8 x 1.35 | foot (x -364.15, y 454.2), z -2.6 .. -1.25 | 5.0 and 5.7: the exit ledge carried back to the wall | 1 | A |
| `templo_frog_shrine` | 2.8 x 2.8 x 1.15 | foot (x -367.4, y 455), z -2.4 .. -1.25 | 5.0 (note 60): the side shrine cut into the west wall, cut away at the front like a doll's house: fitted pale blocks, its back wall 2.4 m behind you, its stepped roof (2 m at the mouth and the back strip, 2.8 in the middle: the course's outline `SHELL_ROOM`), its two side walls each with two stone shelves crowded with small carved pugs a hand tall (six shapes, each a little different, some with a jade bead or a scrap of cut paper); the doorway's frame carved pale. Its floor is the course's | 1 | A |
| `templo_spine_back` | 20.5 x 11.4 x 2.15 | foot (x -333.75, y 457.5), z -3.4 .. -1.25 | 5.8 to 5.10, made in place: the spine of the upper works carried back: the serpent head's ledge (461.7), the stair's polished black ramp ((-340, 461.7) to (-331.5, 467.7)) and the threshold (468.9, x -331.5 .. -323.5: carried back to the altar's niche) | 1 | A |
| `templo_altar_back_wall` | 24.5 x 31.0 x 0.6 | foot (x -321.25, y 453), z -4 .. -3.4 | 5.10 and 5.11: the altar chamber's back wall, wall bays from the bottom of the pit (the gallery, 453) to the roof (484), 3.4 m back, so the drop is a lit wall going down (note 51); the carved band level with the sill (482.2 .. 483), plain; on the temple's side of the well room it is the wall behind the sacrifice stone | 1 | A |
| `templo_sun_stone` | 9.4 x 9.4 x 0.8 | foot (x -318, y 469.7), z -3.4 .. -2.6 | 5.10: a carved disc 9.4 across on the back wall behind the cross: rings of small pugs, belts and bones round a centre, the carving shallow and brown (the cross is the near end of its axle; its cheeks are separate) | 1 | A |
| `templo_well_back` | 12.0 x 104.0 x 5.75 | foot (x -300, y 390), z -7 .. -1.25 | 5.11 and the well beside the temple (390 .. 494; `jardin_well_back` is below it, made to meet it): the round back of the shaft curving from rim to rim, 7 m back at the middle. Below the sills (to 478.4) the well's own rough rock, slick black, stepping back into the dark, a few wet glints far down; the far rim at 479.9 dark and far back so it never reads as a floor; above it the temple's fitted blocks. Lit torch gold from the west, red from below on the east (colour) | 1 | A |
| `templo_well_vault` | 12.0 x 4.4 x 4.75 | foot (x -300, y 489.6), z -6 .. -1.25 | 5.11 (KIT_MORE corbel steps): the stepped vault roofing the well's mouth: from each side two corbel steps in (x -306 .. -305 from 489.6 and -305 .. -304.2 from 491.8; mirrored on the east), up to the flat cap (st's solid, 494); the middle left open for the keystone plaque | 1 | A |
| `templo_sill_back` | 6.9 x 0.8 x 2.75 | foot (x -309.05, y 479.2), z -4 .. -1.25 | 5.11: the temple's sill carried back; the sacrifice stone's niche stands on it | 1 | A |
| `templo_exit_door_side` | 3.5 x 4.0 x 2.75 | foot (x -307.25, y 480), z -4 .. -1.25 | 5.11: the side of the exit doorway through the well's wall, pale blocks, between the sill and the lintel | 1 | A |
| `templo_entry_floor` | 33.04 x 3.0 x 2.4 | skin (x -342.02 .. -308.98, 363 .. 366) | 5.1 (SHELL edge 0): the fitted paving of the temple's first hall; where the drain lands (x -318 .. -313) worn into a shallow dish 5 m across, scuffed pale | 1 | A |
| `templo_chute` | 31.67 x 22.04 x 2.4 | skin (x -373.65 .. -341.98, 363.47 .. 385.51) | 5.1 (edge 1 and its filler): the chute, polished black stone with pale runs down it (everyone who slid it) | 1 | A |
| `templo_shaft_wall_west` | 5.3 x 25.92 x 2.4 | skin (x -377.3 .. -372, 385.48 .. 411.4) | 5.2 and 5.3 (edge 2 and a5.py's rock behind the west sockets, line 183): the west wall, polished black from the plunger's top to the head of the shaft with pale runs of damp, nothing pale on it (the sockets are a5.py's cards) | 1 | A |
| `templo_gear_wall_west` | 5.51 x 24.78 x 2.4 | skin (x -377.5 .. -371.99, 409.24 .. 434.02) | 5.4 (edges 3, 4): the gear room's west wall, dark dressed stone, a black run of grease | 1 | A |
| `templo_gear_roof` | 8.54 x 3.0 x 2.4 | skin (x -374.52 .. -365.98, 434 .. 437) | 5.4 (edge 5): the gear room's roof, dark stone | 1 | A |
| `templo_west_wall` | 3.0 x 32.54 x 2.4 | skin (x -369 .. -366, 433.98 .. 466.52) | 5.5, 5.7, 5.0, 5.8 (edge 6; with the room, edges 6 .. 14 of `SHELL_ROOM`): polished black where it is not held; the frog's room and its stepped doorway cut through it (x -368.8 .. -366, 455 .. 457.8), its frame carved pale, the wall above and below black | 1 | A |
| `templo_serpent_roof`, `templo_stair_roof`, `templo_altar_roof` | 28.02 x 3.0; 20.52 x 9.52; 17.52 x 14.02 (x 2.4) | skin (x -369 .. -340.98, 466.5 .. 469.5; -344 .. -323.48, 466.48 .. 476; -326.5 .. -308.98, 472.98 .. 487) | The roofs (edges 7; 8-9; 10-11, each with its filler), made in place to their runs: dark dressed stone, dry, the underside of each painted with one course line; `_altar_roof` includes the chamber's west wall above the threshold | 1 each | A |
| `templo_east_wall` | 3.0 x 97.04 x 2.4 | skin (x -309 .. -306, 381.98 .. 479.02) | Edge 13: the temple's face of the well's west wall, up the drain, behind the keeper's balcony and the chain, to the sill: pale fitted blocks where the climb passes, polished black elsewhere (item 7a: st's wall stands in the same place) | 1 | A |
| `templo_door_sill` | 5.1 x 4.0 x 2.4 | skin (x -309.1 .. -304, 362 .. 366) | 5.1, the join: the doorstep, pale temple stone; drawn on it the garden got this far: green moss in its joints and three small pale bell sprouts | 1 | A |
| `templo_banner_beam` | 9.1 x 4.5 x 2.4 | skin (x -310 .. -300.9, 379.7 .. 384.2) | 5.1 and 4.10: the stone beam out over the well (2.6 m longer now) and its corbel up into the hood: pale carved stone, a belt of small pugs along its face | 1 | A |
| `templo_hood` | 4.0 x 30.0 x 2.4 | skin (x -313 .. -309, 384 .. 414) | 5.1: the hood over the door, the drain's east side: polished black, wet, pale runs | 1 | A |
| `templo_exit_door` | 3.1 x 14.2 x 2.4 | skin (x -309.1 .. -306, 474 .. 488.2) | 5.11: the exit's sill block (474 .. 479.3) and lintel (484 .. 488.2), one model in two pieces: polished black with soot | 1 | A |
| `templo_hall_ramp` | 39.2 x 25.0 x 2.4 | skin (x -357.2 .. -318, 404 .. 429) | 5.5 and 5.6: the great hall's ramp, polished black, long pale scrapes down it where others slid, three deeper gouges; its foot a lip worn into a shallow spout over the drain | 1 | A |
| `templo_pier` | 9.3 x 29.0 x 2.4 | skin (x -366.5 .. -357.2, 400 .. 429) | 5.3 and 5.4: the pier and the gear room's east wall (a5.py line 77), polished black (the shaft's east wall from 400 to 411.2 is the second wall you can't hold) | 1 | A |
| `templo_pier_cornice` | 8.0 x 0.9 x 2.4 | skin (x -368.2 .. -360.2, 411.1 .. 412) | 5.3 and 5.4: R3, the pier's top and its cornice, carved deep and pale | 1 | A |
| `templo_balcony` | 12.0 x 1.0 x 2.4 | skin (x -365 .. -353, 429 .. 430) | 5.5: the hall's west balcony, pale carved stone | 1 | A |
| `templo_gallery_floor_a`, `_b`, `_c` | 14.08 x 3.0; 8.76 x 3.0; 13.88 x 3.0 (x 2.4) | skin (x -352 .. -337.92; -336.68 .. -327.92; -326.68 .. -312.8; 450 .. 453) | 5.7 (note 52): the gallery's floor in three runs, pale and carved right up to each slot's edge; the slots' inside faces (the 0.08 linings) polished black from just under the lip; `_a`'s west end face carved deep and pale (the last sure hold before the scale) | 1 each | A |
| `templo_stair_ramp` | 20.5 x 10.2 x 2.4 | skin (x -344 .. -323.5, 457.5 .. 467.7) | 5.9: the spine (line 92): the ramp polished black with pale scrapes, drawn on its face the five sockets (a carved pale frame round a dark mouth, 2.4 x 1.2 each, at x -338.3 .. -335.9 / 461.7 .. 462.9 and up by 1.7 and 1.2 each), the big face under it the same black in tight fitted blocks | 1 | A |
| `templo_head_ledge`, `templo_threshold`, `templo_tail_ledge`, `templo_exit_ledge` | 4.0 x 0.6; 8.0 x 1.2; 2.0 x 0.6; 3.7 x 0.8 (x 2.4) | skin (x -344 .. -340, 461.1 .. 461.7; -331.5 .. -323.5, 467.7 .. 468.9; -366 .. -364, 459.6 .. 460.2; -366 .. -362.3, 454.2 .. 455) | Ledges, pale carved stone. The threshold has a ring of jade paw prints 1.6 m across inlaid in its top right in front of the altar (x -328.3 .. -326.7: note 54's place to stand, drawn flush); the exit ledge four small jade paw prints leading to the frog's door | 1 each | A |
| `templo_peg_wall` | 3.5 x 22.3 x 2.4 | skin (x -312.5 .. -309, 457 .. 479.3) | 5.10: the altar's east wall, polished black between the pegs (note 52) | 1 | A |
| `templo_sill` | 6.9 x 0.8 x 2.4 | skin (x -312.5 .. -305.6, 479.2 .. 480) | 5.11: the temple's sill, pale carved stone, a worn notch at its very end (x -305.6) where the first tassel comes to hand; the ring of jade paw prints before the sacrifice stone (x -311.3 .. -309.7) | 1 | A |
| `templo_tier_true`, `templo_landing` | 3.0 x 1.0; 7.0 x 1.0 (x 2.4) | skin (x -335 .. -332, 367.5 .. 368.5 and -341 .. -338, 372.5 .. 373.5; -354 .. -347, 380 .. 381) | 5.1: the first and third tiers and the landing, their fronts carved deep and pale with pug faces and belts, bonded into the platform (no joint under them) | 2; 1 | A |
| `templo_keeper_balcony` | 3.8 x 0.9 x 2.4 | skin (x -312.8 .. -309, 442.7 .. 443.6) | 5.6: the keeper's balcony; its west edge carved deep and pale (what you fling for) | 1 | A |
| `templo_plinth` | 2.6 x 1.2 x 2.4 | skin (x -348.3 .. -345.7, 429.8 .. 431; -332.8 .. -330.2, 431.8 .. 433) | 5.5: the plinth on top of each great pilaster, pale carved stone | 2 | A |
| `templo_mask_lip`, `templo_mask_tooth`, `templo_mask_ring`, `templo_mask_stud`, `templo_mask_lid`, `templo_mask_brow` | 3.0 x 0.7; 0.5 x 1.05; 0.5 x 0.5; 0.5 x 0.5; 2.4 x 0.5; 12.3 x 1.2 (x 2.4) | skin (a5.py lines 141-150: the lip x -359.7 .. -356.7 at 388.6; the teeth at x -359.3, -358.2, -357.1 from 387.6; the nostrils at (-358.9, 391.1), (-357.5, 391.1); the studs at (-356.1, 392.3), (-360.3, 392.3); the lids x -355.4 .. -353 and -363.4 .. -361 at 393.1; the brow x -366.5 .. -354.2 at 395.2) | 5.2 (note 47): the great mask's holds, the ONLY bone white and gold on the face, each standing out on a stone stem you can see back to the face at z -1.3 with a gap of shadow behind it. Teeth: gold tips. Nostril rings and cheek studs: gold rims round a black pit (the pit is the mask's). Lids and brow: a gold line along the front edge; the brow carries on west past the face as a cornice. The lip: the upper gum, its three teeth separate | 1, 3, 2, 2, 2, 1 | A |
| `templo_fang` | 1.6 x 3.1 x 2.4 | skin (one at each of x -360, -354, -348: 463.5 .. 466.6) | 5.8: the one long tooth of each small serpent head: polished black, wet, a pale run down it, its tip a drip | 3 | A |
| `templo_peg` | 0.44 x 0.5 x 2.4 | skin (x -312.94 .. -312.5, at 469.4, 470.8, 472.2) | 5.10: a sound peg, a carved pug's nose on a stone stem set into the wall, pale and whole | 3 | A |
| `templo_champion_broken` | 8.4 x 8.7 x 2.4 | skin, between the feet (-360, 430) and (-331.5, 433) | 5.5 (note 75): **a re-make of the kit's `statue_champion_reach`** to the same solids: a champion 9 m tall, masked, the WHOLE WEST ARM raised, carved deep and pale with a belt of small pug faces wound round it (the catch); the EAST arm ending at the elbow in a rough old weathered break with no cracks running back; the east hand a gilded fist hanging free 1.85 m beyond, its fingers closed round the belt behind (the only gold on the statue). Nothing between elbow and hand | 2 | A |
| `templo_champion_handless` | 8.4 x 8.7 x 2.4 | skin, between the feet (-347, 431) | 5.5 (note 75): the same re-make with BOTH arms gone: a 1.2 m stump at the west shoulder ending at (-348.95, 437.63) in an old break, a stone west hand 1 m across gripping the belt with no arm behind it (centre (-350.4, 438.75)), the east stump to the elbow and the gilded east fist (FOR THE AREA FILE 6b) | 1 | A |
| `templo_champion_still` | 3.2 x 9.0 x 1.2 | foot, z -8.9 .. -7.7 | 5.5: a champion of the far rank, the same size and stone, ARMS DOWN and whole, its belt at the waist, browner, carving shallow (scenery) | 2 | A |
| `templo_niche_tall` | 4.2 x 10.0 x 1.5 | foot, z -9 .. -7.5 | 5.5: a tall stepped niche in the far wall (the stepped arch, made taller), dark inside behind the statue | 2 | A |
| `templo_belt_held` | 8.4 x 8.8 x 0.6 | the foot of its back pillar (between the champion's feet), z -1.9 .. -1.3 | 5.5: the stone belt each champion holds overhead: a band of stone 8.4 long and 0.9 tall, bent at the middle (its west end lower: from fy+7.3 .. 8.2 at x -3.9 up to fy+7.9 .. 8.8 at the middle, level to +4.5), a round bronze plate 1 m across in the middle, on a square pillar 0.6 thick running up the champion's back from its feet; browner than the statues. The background the hands stick out of | 3 | A |
| `templo_pilaster_short`, `templo_pilaster_tall` | 3.8 x 5.4 x 1.3; 3.8 x 17.0 x 1.3 | the middle of the x span at the shaft's east foot on the ramp (y 424.45; 414.81), z -2.6 .. -1.3 | 5.5 and 5.6 (KIT_MORE): a great pilaster 2.6 wide rising out of the ramp behind you, its foot cut to the ramp's 32 degrees, a stepped corbel head (3.2 then 3.8 wide) reaching forward to carry its champion's plinth (its top at 429.8; 431.8) | 1 each | A |
| `templo_altar_niche` | 4.4 x 3.9 x 2.1 | foot (x -327.5, y 468.9), z -3.4 .. -1.3 | 5.10: the stepped niche (apse) the altar stands in at the top of the stair, its frame pale carved, dark brown inside, lit by the altar's coals | 1 | A |
| `templo_sacrifice_niche` | 3.0 x 3.4 x 1.4 | foot (x -310.5, y 480), z -2.7 .. -1.3 | 5.11: the stepped niche the sacrifice stone stands in on the sill | 1 | A |
| `templo_arch_door` | 3.0 x 4.5 x 1.0 | foot, its back on the wall | A stepped arch doorway: two sides stepping in to a flat lintel, its frame pale carved stone, dark inside with its shadow painted (the hall goes on behind). The entry hall's two (5.1), the keeper's at 0.9 (5.6), the gallery's three at 0.889 (5.7) | 6 | A |
| `templo_column` | 1.7 x 4.5 x 1.2 | foot | A square carved column 1.2 m, a pug capital 1.7 wide (engaged: its back half in the wall). The gallery's five (5.6, 5.7) at 1.0; the altar's two at 0.91 (5.9, 5.10) | 7 | A |
| `templo_column_base` | 1.5 x 1.45 x 0.6 | foot, its back at z 1.3 | Foreground: a column's base, plain stepped mouldings, pale stone, its top level with or below the floor behind it (it covers no part of you). Four before the gallery (5.7), one at 1.2 under the sill (5.11) | 5 | A |
| `templo_balustrade` | 20.0 x 0.8 x 0.3 | foot (x -321, y 364.9), z 1.3 .. 1.6 | 5.1, foreground: a low stone balustrade along the front edge of the paving, a step down so its top (365.7) is below the floor you walk on; it stops before the first tier | 1 | A |
| `templo_gear_post` | 1.9 x 22.1 x 1.3 | foot, z -2.6 .. -1.3 | 5.4: a square carved post 1.2 m from floor to roof, a pug capital 1.9 wide; its foot a stepped corbel (2.1 wide, 0.7 tall: the west post stands on it over the open shaft); two pairs of carved axle cheeks each the axle runs back into (west post at 420.36 and 428.28 above its foot's 411.9; east at 416.4 and 424.32 above 412.0); black runs of grease down it from every axle | 2 | A |
| `templo_gullet` | 4.7 x 8.4 x 3.0 | foot (x -358.15, y 380.2), z -5 .. -2 | 5.2: the open mouth, black inside, a stepped throat going back and down toward the chute; it sits in the mask's mouth (item 7c: if `mask_first_dog`'s mouth is closed, it is cut open for it) | 1 | A |
| `templo_serpent_bed` | 18.9 x 1.2 x 0.9 | foot (x -353.45, y 457.6), z -2.2 .. -1.3 | 5.7 and 5.8: the serpent's body, a carved beam fixed to the back wall under the spine, scales on its face, a belt of small pug faces along its top edge, nine ram sockets in its top; its east end stands on the gallery's first column | 1 | A |
| `templo_serpent_head_down` | 2.6 x 1.6 x 1.3 | foot, z -2.6 .. -1.3 | 5.8: a small serpent head looking down out of the wall under the roof, mouth open downward, the same carving as the kit's `serpent_head`; its one great tooth is the fang (a skin) hanging from its mouth | 3 | A |
| `templo_scale_beam` | 6.6 x 0.6 x 0.4 | its axle (the middle), placed at rot 26.8 | 5.7: the scale's beam, thick stone, a pug boss on the axle's end; browner than the pans; made level (it is drawn as it rests, east end up) | 1 | A |
| `templo_ledge_block` | 0.9 x 0.45 x 0.4 | wall | A small block standing proud of a back wall, a fallen corner of carving, a flat top for the temple's plant (BRIEF "little outcrops"): on the entry wall, the gear room, the great hall, the stair and the altar chamber | 7 | A |

## 2. Props and small dressing (maker B)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `templo_offering_sprig` | 0.5 x 0.45 x 0.04 | foot | The temple's wall plant (BRIEF "little outcrops"): ONE flat painted card, a dry offering sprig of three marigold heads and a jade paper streamer, flush colours, only its outline inked | 7 | B |
| `templo_forearm_broken` | 1.9 x 0.5 x 0.6 | foot | KIT_MORE: a champion's forearm and fist, 1.9 m of carved stone with a belt of small pugs round it and a rough old break at the elbow end, lying where it fell (three at the foot of the fall strip, 5.1, one at rot 14 across the others; one on the balcony, 5.5). Scenery: browner than a hold | 4 | B |
| `templo_offering_niche` | 0.6 x 0.6 x 0.3 | wall (set in, its front on the face) | A small square stepped niche holding a bone and a jade bead (the temple's people left one beside every machine): by the plunger (5.3), by the grease trough (5.4); and at 1.67, empty, over the frog's table (5.0: where the shrine's own pug should sit) | 3 | B |
| `templo_jade_eye` | 0.7 x 0.7 x 0.3 | foot, set in the socket | 5.2: an eye of inlaid jade, its colour bright as if lit from inside (no glow: a5.py's jade lights), set deep in each socket of the mask | 2 | B |
| `templo_incense_jars` | 0.7 x 2.0 x 0.6 | foot | 5.6: two incense jars (0.6 and 0.45, glazed jade and terracotta) and a long bronze ladle leaning on the wall, beside the keeper's doorway | 1 | B |
| `templo_grease_trough` | 1.6 x 1.2 x 0.6 | wall | 5.4: a stone trough of black grease on a stone shelf low on the wall, a long ladle standing in it (says why the discs can't be held) | 1 | B |
| `templo_drum_shelf` | 2.2 x 0.3 x 1.3 | foot (x -342.5, y 463.9) | 5.9 (KIT_MORE stepped corbel): a stone shelf for the temple drum, on two small stepped corbels into the back wall, over the serpent's head | 1 | B |
| `templo_bracket` | 0.5 x 0.5 x 1.1 | foot | 5.10 (KIT_MORE stepped corbel): a stepped stone bracket out of the back wall under each joint of the bridge; the slabs lie on them, and when a slab falls its brackets stay | 7 | B |
| `templo_offering_table` | 1.2 x 0.8 x 0.6 | foot | 5.0: the stone offering table in the frog's shrine (an altar, made small; NOT named `altar`: that name counts for note 54) | 1 | B |
| `templo_lamp_small` | 0.2 x 0.25 x 0.2 | foot | 5.0: a small clay lamp, a flame as colour (lit by a5.py: FROG_LAMPS), either side of the frog | 2 | B |
| `templo_pug_shelves` | 1.3 x 1.2 x 0.4 | wall | 5.0: two stone shelves on the shrine's back wall crowded with small carved pugs a hand tall (the six shapes of the shrine's side shelves), some with a jade bead or a scrap of cut paper | 1 | B |

## 3. Bronze and machines (maker C)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `templo_tier_slot` | 5.7 x 1.15 x 1.15 | foot, z -2.4 .. -1.25 | 5.1: the slot a false tier rides in, cut along the platform's face and lined with bronze: 5.7 long, the 3 m the tier fills (east) and 2.6 m of empty channel west of it | 3 | C |
| `templo_jaw_slot` | 0.45 x 6.5 x 0.8 | foot, z -2.05 .. -1.25 | 5.2: one of the jaw's two upright slots either side of the mouth, bronze-lined, set into the face (you see how high the jaw goes) | 2 | C |
| `templo_piston_track` | 3.2 x 1.0 x 0.95 | foot, z -2.2 .. -1.25 | 5.3: the track a piston's back half runs in across the back wall, bronze-lined, a bronze stop at its east end exactly where that piston's tip stops (the four east tracks are flipped) | 9 | C |
| `templo_plunger_guide` | 1.3 x 7.7 x 0.95 | foot (x -367.65, y 392.4) | 5.3: the plunger's guide slot up the back wall, bronze-lined, 3.6 m taller than the plunger (the empty part above it is its lift) | 1 | C |
| `templo_hanger_slot` | 0.5 x 6.7 x 0.8 | foot, z -2.05 .. -1.25 | 5.7: the slot a pan's hanger runs in, bronze-lined, as long as the pan's travel, stopping at 457.5 under the serpent's bed | 2 | C |
| `templo_ram_slot` | 0.6 x 4.7 x 1.0 | foot, z -2.35 .. -1.35 | 5.8: the slot up the back wall behind each vertebra, bronze-lined, as tall as its rise (the empty slot above shows how high it comes) | 9 | C |
| `templo_bronze_jaws` | 2.8 x 1.8 x 0.4 | foot, z -1.7 .. -1.3 | 5.4: a plate of DARK bronze cast as a pug's open jaws with its teeth showing, behind each mesh between the posts: the only three plates of it in the room | 3 | C |
| `templo_axle_cheeks` | 1.4 x 1.4 x 0.6 | foot | Two carved stone cheeks with a stone axle's end between them: the scale's at 1.57, the serpent's roller at 1.0, the cross's at 2.0 (out of the sun stone's centre), the mallet's at 0.6 | 4 | C |
| `templo_chain_boss` | 0.9 x 0.9 x 0.6 | top | A carved pug under a ceiling or beam with a bronze ring in its mouth, reaching the ring forward to the chain (the boss is scenery, the chain is held): the two under the door's beam (5.1), the censer's and the gallery chain's (5.6), the tail's at 0.9 (5.8), the two great censers' at 1.11 (5.11) | 7 | C |
| `templo_pan_hanger` | 0.4 x 2.6 x 0.4 | foot (on the pan) | 5.7: the stone hanger from a pan up to the beam's end, running in its slot; it rides its pan (FOR THE AREA FILE 8) | 2 | C |
| `templo_mallet_arm` | 1.0 x 0.4 x 0.4 | its axle (at its east end), placed at rot 12.5 | 5.9: a stone arm with a bone mallet on its west end, swinging on an axle between two cheeks; it strikes the drum's rim on every count (still until the engine can swing it) | 1 | C |

## 4. Made for a5.py, not placed by the dress file (its FOR THE AREA FILE item 8)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `templo_bridge_slab` | 1.52 x 0.5 x 2.4 | the piece's centre | 5.10 (note 53): one of the six pieces of the bridge, pale stone cracked right through with a corner gone (the game's one look for a thing that will break), the joints plain to see | 6 (by a5.py, the crumbling ledges, line 384) | A |
| `templo_peg_cracked` | 0.38 x 0.44 x 2.4 | the peg's centre | 5.10: a cracked peg, the same pug's nose on its stem cracked through with a corner gone | 5 (by a5.py, line 390) | A |
| `templo_tail_tip` | 0.4 x 0.7 x 0.4 | its top (the last link) | 5.8: the carved stone tip on the end of the serpent's tail chain (the chain's links getting smaller toward it) | 1 (by a5.py, line 326) | C |

**Re-made, not new stems** (FOR THE AREA FILE item 8): `temple_gear` (page 5.4: a greased dark disc
4.6 across with a jade rim band, a ring of small carved running dogs nose to tail, a dark greased
pug's face at the hub, and TWELVE HAMMER COGS 0.9 x 0.55, each its own block in a socket with a
bronze pin, pale dry stone on its front and outer end, DARK BRONZE on its two side faces: what holds
and what bites on every cog); `altar_cross` (page 5.10: the outer 2 m of each arm edged in dark
bronze, the inner arms plain stone, a jade ring and a pug boss at the hub); `serpent_segment` (1.9 x
1.2: scales carved on top, a jade band along its top edge, a bronze shoe underneath where its ram
meets it); and, where the landed model lacks the jade band (Parker, 11-13: everything that moves),
`temple_step` (a jade stripe down its front face, bronze along its bottom edge), `mask_jaw` (jade
along its lip between the fangs, bronze shoes at its two ends), `temple_plunger` (jade round its
top), `temple_piston` (its end shod in dark bronze, its top pale with a jade band), `temple_slab`
(jade along the top edge, bronze ends, a shallow dish carved underneath, so it reads as a pan),
`temple_block` (jade along its top edge, a bronze shoe on its outer end), `censer_l78` and `censer`
(a jade band round the pierced bronze bowl, a gold lid; `censer`'s tassel five bronze bells with a
jade bead at its end, 1.5 m). `statue_champion_reach` is re-made as the two champion skins above.
