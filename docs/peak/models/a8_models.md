# El Teleférico: the models to make

The model list for biome 8, from its dress file `tools/peak/areas/a8_dress.py` (347 decos, 31 of
them skins). Every stem in the tables is NEW: not in `kit/models/` nor in `Top Dog Kit\models\`, nor
on the a0 to a7 lists: 70 placed by the dress file and 1 more made for a8.py's movers (section 4).
Then the re-makes of existing models (section 5). Make each at exactly its size (metres, w x h x d;
+z faces the camera). The game rescales a landed model that is more than a quarter off.

Reused (not listed): `pennant_line` (12: five lines tiled, at 0.82 to 1.31 along the cord),
`streamer_pole` (3, at 0.75: 3 m, streaming east: pylon 1's top, the fang's horn, pylon 3's head),
`wind_sock` (2, flipped so it points east) on `bunting_pole` (2, at 0.5: 1.6 m posts: line 2's west
tower, the long span's arm on pylon 2), `lantern_cold` (4: the chair shed, the maintenance deck, the
fang's top, the high house) with `mine_lantern_bracket` (2, on the two walls), `lantern_station` (1:
the frog's lit lantern, the only lit lamp on the cableway), `frog_ticket` (1: the last passenger on
the parked car's bench), `pug_crest_peeling` (3: the shed's gable at 0.75, pylon 3 and the middle
tower at 0.875), `station_sign_pug` (2: on both houses' walls), `ticket_booth` (1, against the low
house's wall), `toolbox_open` (2: the maintenance deck's, and as the linesman's box on the fang's
top), `oil_can` (2: pylon 1's head, pylon 2's landing). The movers keep `cable_sheave` (made to its
collider). a8.py keeps `glove_frozen` in the play space.

Makers: **A** rock, buildings, roofs as skins, far cards and the far line (here: the face's four
skins and its two bodies, El Colmillo, its chalk block and its far horn, the shoulder's three cards,
the far line, the three roofs, the high house, the chair shed, the ice in the high station's docks).
**B** props, signs, flags, pennants, frogs, small dressing (here: the frozen pennants, the frog's
suitcase and timetable card, the oily rag, the grease pot, the snow lip). **C** steel towers, cars,
chairs, cables' hardware, wheels, wind engines, rails, iron (here: the lattice bays and the end frame,
the girders and arms, every cable and belt, the wheels, drums and pulleys, the engines and masts, the
decks', landings' and gratings' skins, the parked car and its siding, the zip buffer, the posts, and
the express car for a8.py).

The cableway's look (the sheet `docs/peak/playtest/design/data/a8_biome.py`): riveted steel, angle
iron in lattice with a plate at every joint and the pug stamped on the plate, all painted the
cableway's red, sun-faded and peeling in flakes to rust orange. **What you can hold** (in the play
space): sun-faded red with a CREAM BAND along the edge you take (a car's roof, floor, step, rack and
hanger; a chair's seat front; the zip handle; a counterweight; a rail post's top), rust-orange iron
where the paint has worn through, honey planks, open iron grating rust orange and dry, the station
roofs' striped red and cream tin with a cream band along their edges, and white chalk on the fang;
all dry and matte. **What you can't**: black and glossy: every cable (greased, behind you), pylon 2's
tarred roof and its two greased legs, the dark polished rock, the blue-black ice. **Scenery** is what
carries, never what is carried: cables and carriages, towers, crossarms, chair poles, bull and guide
wheels, wind engines, the houses; flat cut-outs 2 m or more back in a GREYED BRICK RED, and **cream is
never painted on scenery**. Floors are few and small; one rail post on each. The station houses are
board houses, the greyed red below bare grey boards, dark windows, no cream, standing 2.5 m back under
a roof that comes forward over the deck. Never here: timber framing (the stations' boards and roof
timbers are the only sawn wood), rope, brick, carved stone, anything green, a lit lantern outside the
frog's car, icicles, a cable or a tower you can hold. Light: late-afternoon gold, every thing with a
warm lit side and a long blue-violet shadow side (paint them), the sky apricot to pale gold; at the
high station the mountain's blue shadow and the first snow. No glowing materials (the game adds the
frog's light).

**THE WALLS RULE** (BRIEF.md "Walls and masses"; the reference is `ex_riscos_tower_top`,
`docs\peak\playtest\design\walls_example_after.png` and `Top Dog Kit\previews\ex_riscos_tower_top_game.png`;
the library is `source\stn_a_paint.py` and `stn_a_lib.painted_model()`). The rock here (El Colmillo,
the mountain's face, their bodies) is made that way: a few large gently slanted planes of dark brown
polished to a gloss (folds under 25 degrees, so no ink inside a face); the beds long wandering wavy
lines and bands of flat colour in three or four browns running the length of the face; NO RAIN
STREAKS, nothing painted that narrows to a point, no wedge, no band that thins away; no dark slot cut
into a face; only a few big breaks are real shape; the outline designed (away from holds and tops it
moves up to 0.8 m, leans, is notched, no long ruled edge); no tiling. On the fang the only white is
its holds, each a plain block or band with square ends, the end of one of the rock's beds. A body
behind is ONE big form in two or three slanted planes, duller and cooler, its beds thin darker lines
carrying on the face's, an uneven skyline. The face's scree carries nothing pale: it holds nothing.

"Origin: foot" means the middle of its base (x and z) at its lowest point; for long pieces, the
middle of its x span, the bottom of its box, the middle of its depth. "Hub" means the centre of a
wheel's, pulley's, drum's or engine's axle. "Middle" (cables, belts) means the middle of its length
on its centre line: it is made running +x and the dress file lays it by `rot`. "Wall" means the
middle of its foot line, its back on the wall. "Skin" means the model is the look of course solids
(`skin=` in a8.py, its FOR THE AREA FILE item 5): it fills them (z -1.2 .. 1.2 unless the row says
it carries a floor or a roof further back), its outline is theirs where they are held or stood on,
its size is theirs (never rescaled). A tower's bays are placed alternately flipped so the braces
zigzag: make each bay so its flip lines up with the next.

## 1. Walls, masses, roofs, buildings and far cards (maker A)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `tele_face_a` .. `tele_face_d` | 13.3 x 22.16 / 14.65 x 25.33 / 14.89 x 27.21 / 18.2 x 35.83, each x 2.4 | skin (a: x -264.3 .. -251, 681.84 .. 704; b: -271.25 .. -256.6, 701.67 .. 727; c: -278.49 .. -263.6, 724.79 .. 752; d: -289 .. -270.8, 749.57 .. 785.4) | Every page west of the lines (8.1, 8.10, 8.11): the mountain's face between the stations, a8.py's slick scree (A.wall, line 97, one piece per edge, each with its 8 m slab of rock to the west; d also takes the plug behind the high deck's west end, line 379). Dark brown scree rock in a few large slanted planes, glossy, the beds long wavy lines and bands in three or four browns running up the face's length (they carry on from piece to piece and from the cliffs' `riscos_west_face` below); a few big real breaks, one each: a brow with its shadow painted under it (b, about 715), one ledge (c, about 740), a notch in the outline where a block has gone (d, about 765); nothing cut into a face; NOTHING pale or dry (nothing on it is a hold). The faces where they meet the air are the course's; deep in the rock the edges are free. **a is cut round a7's skins**: below 684.02 its slab's corner is a7's `riscos_west_face`, and a7's chalk plug (x -253 .. -250, 686 .. 688) is a7's `riscos_chalk_plug` (a8_dress item 7h). The face's foot at the low deck is "slick scree with nothing on it" (page 7 to 8) | 1 each | A |
| `tele_face_body_a`, `tele_face_body_b` | 49.5 x 48.0 x 1.75; 44.2 x 48.0 x 1.75 | foot (x -275.25, y 690; x -287.9, y 738), z -3 .. -1.25 | 8.1 to 8.11: the face's body behind it, the cliffs' `riscos_face_body` carried on up from 690 where that one ends: the same rock a step duller and cooler, ONE big form in two or three slanted planes, the beds thin darker lines carrying on the face's, a metre proud of the face line: outline (-250.5, 690), (-254.5, 700), (-255.6, 704), (-262.6, 727), (-265.8, 738) for a; (-265.8, 738), (-269.8, 752), (-277.8, 777) for b, and from 777 to 786 b's edge runs 0.3 m INSIDE the face line (the dock ice stands in front there). West of the face's slabs (x -300 / -310 to the slab's back) it is the mountain's rock showing; no plants | 1 each | A |
| `tele_colmillo` | 18.0 x 41.0 x 2.4 | skin (x -176 .. -158, 684 .. 725), made in place | 8.5, 8.6, 8.7: EL COLMILLO, the rock fang (a8.py line 220, with its foot ledge 236 and rib 237): the cliffs' own chalk standing alone in the air, one painted piece made for its place. Its west side the 11 degree overhang from (-172.4, 696) to the nose (-176, 715), then the 38 degree slab back to the top (-165.6, 725); dark brown, polished by rain and wind, a few large slanted planes; the beds painted as long, a little wavy lines and bands in three or four browns, near level, falling 0.1 m in 2 m, running from each hold east across the whole face (through every hold on the overhang and every other on the slab, and two more under the overhang at 700.1 and 704.6: a8_areas._BEDS). Three real breaks only: the overhang with its own shadow painted a band darker under the nose; the foot ledge (x -174.8 .. -173.5, top 702.9) and the rib above it (on the face, 703.2 .. 706.6), both white chalk, dry and matte, as plain bands with square ends (the lip of one bed and its broken end turned up); and the NOTCH in the east side. The east side's designed outline (a8_dress item 6a): (-158.5, 697), (-159.2, 701.5), (-159.7, 705.4), (-160.6, 705.6), (-160.6, 707.3), (-161.6, 710.4), (-161.5, 714.6), (-163.3, 718), (-163.2, 721.8), (-164.3, 724.4), a notch 0.9 deep at 705.6 .. 707.3. No white anywhere else on it, no drip lines (taken out by the walls rule) | 1 | A |
| `tele_chalk_block` | 0.4 x 0.4 x 2.4 | skin (each A.hold of line 243: its middle at the hold's x, its foot 0.2 under the hold's centre) | 8.6: one of the fang's thirteen chalk holds, modelled at the size of its grip (notes 76, 77): a plain white block with square ends standing 0.1 m proud of the face, dry and matte, the end of one of the rock's beds where it meets the face (so its bed's painted line runs on east from it on `tele_colmillo`). Level, not tilted with the face. The same block thirteen times | 13 | A |
| `tele_fang_horn` | 18.7 x 43.6 x 2.5 | foot (x -166.35, y 684), z -4.0 .. -1.5 | 8.6, 8.7: the fang's far horn, its own body carrying on behind the slice you climb: one big form in two or three slanted planes, the same rock a step duller, greyer and cooler, its beds thin wavy lines carrying on from the face's; an uneven skyline rising 1.5 to 3 m above the slab and up to 2 m wider on the east; outline (-171.7, 684), (-172.1, 696), (-175.7, 715), (-175.2, 716.6), (-174.0, 719.6), (-171.0, 722.6), (-168.0, 725.4), (-166.2, 727.4), (-164.6, 727.6), (-163.0, 725.4), (-161.2, 720.0), (-159.6, 711.0), (-157.9, 697.0), (-157.0, 684): its west edge 0.3 m INSIDE the overhang's face, so it never shows west of the overhang and the overhang keeps a clean edge against the sky. A shelf at 725.4 carried forward to z -1.25 behind the anchor plate (x -166.6 .. -163.6) where the linesman's box and a cold lantern stand; the chair line's anchor arm bolts into its west edge at (-174.3, 707.3); the back stay's eye bolt at (-162.2, 724.6); the streamer on its tip at (-166.0, 727.4) | 1 | A |
| `tele_shoulder_a` .. `_c` | 62.74 / 49.83 / 39.46 x 34.0 x 0.5 | foot (x -278.63, y 702; -285.085, 736; -290.27, 770), z -13.25 .. -12.75 | 8.10, 8.11 and behind the low station: the mountain's shoulder, the cliffs' flat cut-out card (`riscos_shoulder_a` .. `_d`, which stop at 702) carried on up, made the same way (BRIEF.md "Far backgrounds", the kit's `stn_far_hills`: a thick card whose cut edge shows kraft, a dark stripe, kraft, braces behind), hazed to a mid blue-grey (mid values: the light lifts it). Here chalk gives way to DARK SCREE WITH SNOW LYING IN ITS GULLIES, more snow each section up, and on c the glacier's blue edge hangs over its top. Its east edge cut in steps of 4 m that lean back with the face (x -245.9 at 702 meeting the cliffs' card, -254.5 at 720, -259.2 at 736, -263.8 at 752, -269.5 at 770, -275.9 at 790, -280.3 at 804), each step 0.5 east or 0.4 west of that line by turns, a snow gully at each step. West to x -310 so its end never shows. East of its edge nothing of ours | 1 each | A |
| `tele_far_line` | 90.7 x 129.0 x 0.5 | foot (x -195.75, y 620), z -20.5 .. -20.0 | 8.1, 8.0, 8.2, 8.3, 8.6, 8.7, 8.8: THE FAR LINE, the cableway's dead second line, ONE flat cut-out card 20 m back made the way the far cards are (the kit's `stn_far_hills`), hazed toward the apricot sky in mid values. Three lattice towers 4 m wide (tops at (-238.5, 708), (-212, 732), (-153, 746)), two legs and zigzag braces each, a crossarm 5.2 m on each top; two slack spans of cable between them sagging 2.5 m and 6 m; one stopped chair hanging on the first span at x -231 (pole 3.1, a plank seat 1.2); two stopped gondolas at x -222 and -178 (2.6 m, hangers 1.5); on the middle tower's top its wind engine with its cups gone (three bare arms). The legs fade into a band of painted haze below 640 so its foot never shows from any camera (at 20 m back it slides to 0.4 of the camera's offset: a8_dress item 7e). Cut-out shapes thick enough that the ink line does not swallow them (a leg 0.35 m at least). The given valley, ranges and cloud banks stand behind it; nothing of ours east of the shoulder but this | 1 | A |
| `tele_roof_low` | 13.4 x 1.8 x 6.7 | skin (x -251 .. -237.6, 692.5 .. 694.3), z -5.5 .. +1.2 | 8.1 (note 77, THE ROOF IS REAL: a8.py line 107): the low station's roof, striped tin nailed on timber boards in the cableway's red and cream, the stripes running eave to ridge, a CREAM BAND along all its edges; rust at the nail heads. In the play space (z -1.2 .. 1.2) its top is exactly the solid's, 692.8, 0.3 thick, level; its eave edge at z +1.2; behind it the same tin rises to its ridge (top 694.3 at z -5.5, over the house's back wall): 6.7 m from eave to ridge. No post of it in the play space. Its underside timber boards in blue shade | 1 | A |
| `tele_roof_high` | 13.4 x 1.8 x 6.7 | skin (x -281.4 .. -268, 790.5 .. 792.3), z -5.5 .. +1.2 | 8.11 (lines 388, 389): the same roof at the high station, frosted: its top 790.8 in the play space; on x -271.5 .. -269.6 the GLAZE OF BLACK ICE (0.15 thick, top 790.95: meltwater off the glacier's lip frozen on the tin, glossy, not held); west of -271.5 the glacier's lip (biome 9's) lies on it, so paint that length under a skin of white; the open east 1.6 m (x -269.6 .. -268) clean striped tin with its cream band, the only place on it to stand; its back half to the ridge (792.3) frosted, the frozen engine's mast standing on its east end | 1 | A |
| `tele_tar_roof` | 10.4 x 4.0 x 3.05 | skin (x -197.8 .. -187.4, 715.75 .. 719.75), z -1.85 .. +1.2 | 8.4, 8.5, 8.7: pylon 2's tarred roof (a8.py lines 193, 194): BLACK TARRED TIN, glossy, the blackest thing on the tower, two slopes from the ridge (-193, 719.45) to (-197.6, 716.2) (5.6 m) and to (-187.6, 715.9) (6.5 m), 0.3 thick; it cannot be held. It reaches back only to z -1.85 (the chair line's cable and guide wheel pass behind its back edge: a8_dress item 7f); the maintenance deck stands on its ridge | 1 | A |
| `tele_station_house_high` | 12.0 x 6.0 x 3.1 | foot (x -276, y 786), z -5.55 .. -2.45 | 8.11: the high station's house, the same board house as the low station's re-made one (section 5): board walls in the greyed red below bare grey boards, NO CREAM, dark windows, a dark ticket window (x -275.6 .. -274.4, 787.2 .. 788.4), no roof of its own (6 m at its back wall, its front wall 4.9 m, under the roof's slope); half buried: snow drifted against its west half up to the roof (from (-282, 786) up to (-280.2, 790.5), down to (-274.6, 786)). The pug sign and the cold lantern are placed on it | 1 | A |
| `tele_chair_shed` | 4.4 x 4.7 x 0.4 | foot (x -192.8, y 714.5), z -2.3 .. -1.9 | 8.4, 8.5, 8.7: the chair shed on pylon 2's head, where the chair line was boarded and wound: a board wall in the greyed red below bare grey boards, no cream (its face at z -2.2), 2.8 m tall, with its own tarred gable to 719.2 (black, under the tar roof); a bench against it (x -194.4 .. -192.9, top 715.1) and the hand winch that wound the chair line (its drum 1.1 across at (-191.4, 715.4), a crank), forward to z -1.9. The cold lantern's bracket and the pug crest are placed on it | 1 | A |
| `tele_dock_ice` | 20.8 x 8.4 x 4.7 | foot (x -278.6, y 777), z -6.0 .. -1.3 | 8.11: the swallowed docks: blue-black glacier ice, glossy, made the way the glacier's body is, filling the two lower docks under the deck from the face out to the deck's east end: outline (-289, 777), (-274, 777), (-271, 779.2), (-269.2, 781.4), (-268.2, 783.4), (-268.2, 785.4), (-289, 785.4); two FROST-RIMMED HOLES the lower cables have sawn for themselves at (-273.0, 777.9) and (-270.2, 781.7), each 1 m across; old dock planks and a buffer showing dark inside the ice. The black ice under the deck's east end in the play space is its near edge | 1 | A |

## 2. Props, pennants and small dressing (maker B)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `tele_pennant_line_frozen` | 6.0 x 0.68 x 0.02 | as `pennant_line` (the middle of its base; its cord's ends at x +-3, y 0.68) | 8.11: the last pennants, FROZEN STIFF: the kit's pennant line white with frost, the town's colours showing through pale, rime on the cord, each pennant still standing out east and not moving. Tiled twice at 0.84 | 2 | B |
| `tele_suitcase` | 0.35 x 0.3 x 0.15 | foot | 8.0: the frog's small suitcase on the bench beside it, brown leather, a strap, a pug sticker | 1 | B |
| `tele_timetable_card` | 0.3 x 0.4 x 0.01 | wall (the car's back wall) | 8.0: the timetable card pinned to the parked car's back wall behind the frog, bleached blank by the sun, a ruled border and a pin at each top corner | 1 | B |
| `tele_oily_rag` | 0.3 x 0.12 x 0.2 | foot | 8.0: a greaser's rag, dark with oil, crumpled beside the oil can on pylon 1's joint | 1 | B |
| `tele_grease_pot` | 0.4 x 0.3 x 0.3 | foot | 8.4: a grease pot at the back of pylon 2's landing, black inside, a paddle in it, a wire handle | 1 | B |
| `tele_snow_lip` | 10.5 x 0.85 x 0.45 | foot (x -276.75, y 785.4), z 1.25 .. 1.7 | FOREGROUND 8.11: a lip of drifted snow along the high deck's front edge, x -282 .. -271.5, on the planks' fascia (785.4 .. 786, the plank ends showing) and rising under 0.3 m above the deck's top (to 786.25), soft-topped, blue in the shade; it stops 3.5 m short of the deck's east end, where you come off the car | 1 | B |

## 3. Steel, iron, cables, wheels and engines (maker C)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `tele_lattice_bay` | 3.0 x 4.0 x 0.3 | foot | Every page: one bay of a lattice tower as a flat cut-out: two legs of riveted angle iron 3 m apart (0.3 wide), a strut across its foot, ONE brace from bottom east to top west, a plate with the pug stamped on it at each of the four joints; greyed brick red, sun-faded and peeling to rust, NO CREAM. Stacked into the towers (placed alternately flipped so the braces zigzag): the middle tower (25, on the low roof's back half from 693.3), pylon 1 (11, to 708), line 2's west tower (11, to 708), its east tower (12, to 712), pylon 2 (14, to 719.4), the counterweight frame (10, to 754.6), the express tower (17, on the link girder from 709) | 100 | C |
| `tele_lattice_bay_narrow` | 2.6 x 4.0 x 0.3 | foot | 8.8, 8.9: the same bay 2.6 m wide, for pylon 3 (24 bays, to 758.4) | 24 | C |
| `tele_end_frame` | 3.8 x 21.2 x 0.3 | foot (x -234.4, y 682.6), z -2.8 .. -2.5, made in place | 8.1: the low station's end frame, a lattice frame on the station's east end standing on the scaffold's top ledger (682.6): legs at x -235.9 and -232.9, five bays and its cap (3.8 wide, 703.5 .. 703.8) that carries the wind engine's mast, a bracket for the haul cable's pulley at its foot (-233.0, 688.6); the greyed red, pug plates | 1 | C |
| `tele_link_girder` | 15.0 x 1.0 x 0.3 | foot (x -222.4, y 708), z -2.75 .. -2.45 | 8.0, 8.2: the link girder, a lattice bay laid level between the tops of pylon 1 and line 2's west tower (x -229.9 .. -214.9, 708 .. 709): top and bottom chords, zigzag web; a shaft along it on bearings with a pulley at each end (where the belt from line 1's turn comes up and the crossed belt to line 2 goes down: the one shaft is why the loops never drift); the express tower stands on its top | 1 | C |
| `tele_long_girder` | 23.1 x 1.7 x 1.0 | foot (x -207.15, y 754.1), z -2.9 .. -1.9 | 8.8, 8.9, 8.10: the long girder, 1.2 m deep (754.6 .. 755.8), from the express tower across pylon 3 to the counterweight frame (x -218.7 .. -195.6); under it the shuttle's rail at z -2.0 (754.25 .. 754.55, where the dead car's carriage runs) between two buffers (x -218.6 .. -218.3 and -202.6 .. -202.3, 754.1 .. 754.6); the shaft inside it to the winding drum | 1 | C |
| `tele_span_arm` | 5.5 x 2.1 x 0.3 | foot (the middle of its base: its brace's foot) | 8.3, 8.4: a crossarm 5.5 m out from a tower's top with a brace under it from the tower's leg (arm 0.3 deep at the top of the box, the brace from the box's tower-end foot to 4.2 m along the arm), a pug plate at the root; where the long span came in (pylon 2, x -199.5 .. -194, top 715.3) and left (line 2's east tower, flipped, x -212.4 .. -206.9, top 712.3). A snapped end hangs from each tip, a sock on pylon 2's | 2 | C |
| `tele_cable_snapped` | 0.9 x 3.4 x 0.15 | its top (where it hangs from the arm) | 8.3, 8.4 (note 79): the long span's snapped cable end: 3 m of black greased cable 0.15 thick hanging from an arm's tip with its strands frayed open at the bottom (a brush 0.4 long) and blown a little east; thick and stiff (it does not swing like a rope); 4 m and more from any hand | 2 | C |
| `tele_cable` | 10.0 x 0.15 x 0.15 | middle (made running +x) | Every page: CABLE, black, greased, glossy, 0.15 thick and taut (thick and black, so it is not taken for a rope), 2 m behind the climb: one 10 m length, laid end to end and scaled along its run (0.82 to 1.17) for the express lines, the zip line, the chair line, the counterweights' columns and the haul cable up the end frame. Its ends cut square so lengths butt cleanly | 36 | C |
| `tele_cable_short` | 2.0 x 0.15 x 0.15 | middle | The same cable in 2 m lengths for runs under 7 m: the two loops (lines 1 and 2), the zip line's level stretch, the chair line's run into the shed, line 4's bend onto the high bull wheel | 28 | C |
| `tele_belt` | 10.0 x 0.4 x 0.06 | middle | 8.1, 8.0, 8.4, 8.8: a drive belt from a wind engine or a shaft to a wheel: two flat straps of dark leather 0.4 m apart, a little slack; laid and scaled along its run (the low engine to line 1's bull wheel, line 1's turn up to the link girder, pylon 2's engine down to the shaft, the shaft to the lower sheave) | 5 | C |
| `tele_belt_short` | 4.0 x 0.4 x 0.06 | middle | The same belt in 4 m: pylon 3's engine down to the long girder's shaft | 1 | C |
| `tele_belt_crossed` | 6.0 x 0.4 x 0.06 | middle | 8.2, 8.4: a CROSSED belt (why the second wheel turns the other way): the two straps crossing once in its middle, made 6 m and scaled to its run: the link girder's shaft down to line 2's bull wheel (at 1.75), pylon 2's shaft to the upper sheave (at 0.52) | 2 | C |
| `tele_guide_wheel` | 1.0 x 1.0 x 0.15 | hub | Every line: a guide wheel where a cable only bends, as scenery: greyed, NO CREAM, a grooved rim and five spokes; at the four corners of each loop, under the chair shed's eave and on the fang's anchor arm, on the express tower's four arms, and at 0.8 as the haul cable's pulley at the end frame's foot and the middle tower's four saddle wheels. The loops' and the express lines' wheels turn with their cars (a8_dress item 8) | 19 | C |
| `tele_bull_wheel_grey` | 4.4 x 4.4 x 0.3 | hub | 8.1, 8.2 (note 76): a bull wheel AS SCENERY: flat, greyed red, NO CREAM, a heavy grooved rim and six spokes, a plain hub (no pug: the pug on a hub is the ridden wheel's), so it is never taken for the cliffs' wheel you ride; inside line 1's loop on the end frame and inside line 2's west end, 2 m back, turning with the cars | 2 | C |
| `tele_bull_wheel_frosted` | 4.4 x 4.4 x 0.3 | hub | 8.11: the same wheel at the high station, on the front of the house at its east end under the roof, greyed and frosted white along its top, a little snow on its spokes; it turns one way and then the other as the fourth car comes and goes | 1 | C |
| `tele_wind_engine` | 5.0 x 5.0 x 0.4 | hub | 8.1, 8.4, 8.7, 8.8: a WIND ENGINE, the smaller sister of the kit's anemometer: a cup wheel 5 m across, three arms with a cup 0.85 across on each end, a hub with a bevel box behind it; greyed red, NO CREAM (the kit's anemometer has cream cups: not this). It turns in the wind off the glacier; one on the low station's end frame, one on pylon 2, one on pylon 3 | 3 | C |
| `tele_wind_engine_frozen` | 5.0 x 5.0 x 0.4 | hub | 8.11: the same engine at the high station, STOPPED, white with frost, snow packed in its cups, rime along its arms (no icicles: they are the glacier's to teach) | 1 | C |
| `tele_engine_mast` | 0.3 x 4.0 x 0.3 | foot | 8.1, 8.8, 8.11: an engine's mast, riveted iron 0.3 square, greyed red, a bearing at its top for the engine's hub; placed at 0.6 (the end frame's, 2.4 m), 0.8 (pylon 3's, 3.2 m) and 1.2 (the high station's, 4.8 m, on the roof's east end) | 3 | C |
| `tele_engine_mast_tall` | 0.3 x 10.6 x 0.3 | foot (x -192.5, y 719.4), z -3.35 .. -3.05 | 8.4, 8.7: pylon 2's engine's mast, the same make 10.6 m tall from the tower's top over the roof, two stays | 1 | C |
| `tele_shaft_pulley` | 0.8 x 0.8 x 0.2 | hub | 8.4: the short shaft with its pulley on pylon 2's centre line at 713 m that the engine's belt comes down to and the two sheaves' belts leave from | 1 | C |
| `tele_axle_bracket` | 0.4 x 0.4 x 1.25 | foot (under the axle), z -2.5 .. -1.25 | 8.4: a sheave's axle bracket, an iron box arm from the tower's front (z -2.5) forward to z -1.25 carrying the axle (seen from the front, hidden behind the hub but for its edges) | 2 | C |
| `tele_bracket_broken` | 1.9 x 1.6 x 0.2 | foot | 8.2: a broken bracket arm of the fallen change landing, bolted to a tower's leg at 694 m: a riveted arm 1.7 m long reaching out level, a raking strut under it, both torn off short with bent ends; greyed. One on pylon 1's east leg, the other (flipped) on line 2's west leg, reaching toward each other; nothing hangs from them | 2 | C |
| `tele_express_arm` | 1.8 x 0.6 x 0.3 | foot | 8.9, 8.10: an arm out east from the express tower at each line's east end (x -218.7 .. -216.9, its top 0.45 under the line's stop), a buffer block on its end where the car stops, a pug plate | 4 | C |
| `tele_middle_arm` | 4.6 x 0.3 x 0.3 | foot | 8.10: one of the middle tower's four arms, 4.6 m across the tower at a cable's height (764.2, 769.3, 774.4, 779.5), carrying a saddle wheel; a pug plate at its middle | 4 | C |
| `tele_winding_drum` | 1.8 x 1.8 x 0.4 | hub | 8.9, 8.10: the winding drum on the long girder's end at the express tower (-220.2, 755.2), greyed, its turns of cable showing; it turns back and forth with the express cars | 1 | C |
| `tele_top_wheel` | 3.4 x 3.4 x 0.3 | hub | 8.8: the counterweights' top wheel on the long girder over the frame, greyed, 3.2 m across (exactly as wide as the two columns are apart), WITH THE CABLE'S ARC over its top half (from x -200.3 to -197.1) in the same model; it turns one way, stops and turns back | 1 | C |
| `tele_level_plate` | 1.0 x 0.3 x 0.05 | foot | 8.8: a level plate on the counterweight frame's west leg (in the gap between the columns) at each height where two block tops stand level and at the foot and top of the ride (720.5, 727.5, 734.5, 741.5, 748.5): a riveted plate painted the scaffold's yellow ochre with a black line across its middle at the level | 5 | C |
| `tele_carriage_stub` | 0.6 x 1.0 x 0.3 | foot | 8.9: the shuttle's west carriage still on the long girder's rail, its wheels on the rail, and under it the sheared stub of the arm that broke (0.7 m, bent, a bright torn end); greyed, out of reach | 1 | C |
| `tele_anchor_arm` | 1.7 x 1.0 x 0.3 | foot | 8.5, 8.6: the chair line's anchor on the fang: an iron arm 1.6 m bolted into the fang's body 2 m back, through a pug plate (x -174.6 .. -174.2, 707 .. 708), the cable made fast at its tip over the guide wheel | 1 | C |
| `tele_back_stay` | 0.12 x 4.06 x 0.12 | its lower end (the eye bolt), made standing +y | 8.6: the zip post's back stay, a thick iron rod from an eye bolt in the horn (-162.2, 724.6) up to the post's top (laid at rot 30.4) | 1 | C |
| `tele_zip_buffer` | 0.7 x 3.15 x 0.3 | foot (x -193.35, y 720) | 8.7 (note 82): the zip line's sprung buffer, a post 2.7 m tall at the back of the maintenance deck (x -193.7 .. -193.45) with a coil spring on its top pointing up the line to (-193.0, 723.0), where the trolley stops; greyed iron, the spring rust | 1 | C |
| `tele_siding` | 5.1 x 2.5 x 0.2 | foot (x -228.85, y 705.1) | 8.0: the siding on pylon 1's head, a short rail 5 m long (705.5 .. 705.7) hung from the tower's top on two hangers (up to 707.6), a buffer on its east end (x -226.6 .. -226.3, 705.1 .. 706.0): cars were taken off the line here to be mended | 1 | C |
| `tele_gondola_parked` | 2.6 x 3.86 x 1.05 | foot (x -228.4, y 701.84), z -2.3 .. -1.25 | 8.0: THE FROG'S GONDOLA, the same car as the ones you ride (the kit's `gondola`, made 1.05 deep), standing still on the siding: its back wall, roof, floor (top 702.0, level with the perch) and low end walls, open toward you; a bench along the back wall (x -229.5 .. -228.2, top 702.6, front edge z -1.9); a peeling pug crest 0.7 across on the back wall (at (-227.6, 703.3)); its trolley up to the rail (705.7); its STEP AND RACK UNBOLTED AND GONE (nothing sticks out that looks like a hold). The lit lantern's AMBER painted on its walls and bench (the light as colour). The frog, the suitcase, the card and the lantern are placed in it | 1 | C |
| `tele_gangway` | 4.0 x 1.9 x 2.4 | skin (x -240 .. -236, 688 .. 689.9) | 8.1 (lines 100, 101): the boarding gangway, 3.3 m of honey planks 0.7 m above the deck on a steel frame, its east lip and edge with the cableway's CREAM BAND (the first mark for a hold), its one rail post (x -239.92 .. -239.78, to 689.9) red with a cream band round its top 0.5 m; and, painted flat on a7.py's deck east of it (x -236.7 .. -236.0, 2 cm), the slanted yellow and black WARNING STRIPES (note 78: the pinch under a car's step) | 1 | C |
| `tele_perch` | 2.4 x 1.3 x 2.4 | skin (x -229.6 .. -227.2, 701.7 .. 703) | 8.0 (lines 134, 135): pylon 1's perch, open iron grating, rust orange and dry (you see the cars come up through it), its one rail post on the west end red with a cream band round its top. No rung under it | 1 | C |
| `tele_pylon2_leg` | 0.3 x 32.8 x 0.3 | skin (x -194.15 .. -193.85 and -191.15 .. -190.85, 670 .. 702.8) | 8.3, 8.4 (lines 177, 178): one of pylon 2's two near legs, BLACK GREASED STEEL, glossy, 0.3 square, riveted, grease dripped thick; the only steel in the play space you cannot hold | 2 | C |
| `tele_landing` | 5.4 x 0.3 x 3.0 | skin (x -196 .. -190.6, 702.7 .. 703), z -1.8 .. +1.2 | 8.3, 8.4 (line 179): pylon 2's landing, open iron grating rust orange and dry, its WEST END'S LIP ROLLED AND WORN BRIGHT (the palest thing on the pylon: the whole target of the long fling, seen from the car); carried back to z -1.8 where the oil can and the grease pot stand | 1 | C |
| `tele_head_deck` | 4.0 x 0.3 x 3.8 | skin (x -194.8 .. -190.8, 714.2 .. 714.5), z -2.6 .. +1.2 | 8.4, 8.5 (line 183): pylon 2's head, honey planks on steel, the floor of the chair shed, carried back to the shed's wall | 1 | C |
| `tele_maint_deck` | 6.0 x 0.4 x 3.5 | skin (x -196 .. -190, 719.6 .. 720), z -2.3 .. +1.2 | 8.7, 8.8 (line 269): the maintenance deck on the roof's ridge, honey planks on steel, 2 m of them under the buffer (x -194 .. -192) WORN PALE by boots (where you let go); carried back under the buffer, the toolbox and the lantern | 1 | C |
| `tele_head_p3` | 4.1 x 1.6 x 3.0 | skin (x -205.6 .. -201.5, 748.6 .. 750.2), z -1.8 .. +1.2 | 8.8, 8.9 (lines 294, 295): pylon 3's head, honey planks on steel, its rail post on the west end; the post and the head's last 0.6 m (x -205.6 .. -205.0) in the slanted yellow and black WARNING STRIPES (note 78: the dead car's corner can swing in); carried back to where the frozen climber sits and the streamer stands | 1 | C |
| `tele_grate` | 1.6 x 0.25 x 3.7 | skin (x -221 .. -219.4, 746.25 .. 746.5), z -2.5 .. +1.2 | 8.9, 8.10 (line 363): the express tower's landing, open iron grating, carried back to the tower and bolted to it | 1 | C |
| `tele_fang_anchor` | 2.6 x 3.1 x 2.4 | skin (x -166.6 .. -164, 725 .. 728.1) | 8.6, 8.7 (lines 244, 245): the zip line's anchor on the fang's top, an iron plate 2.6 m (725 .. 725.4) bolted to the rock and the post 2.7 m on its east end (x -164.35 .. -164.15), rust-orange iron, dry, both held | 1 | C |
| `tele_high_deck_back` | 14.0 x 0.5 x 1.2 | foot (x -275, y 785.5), z -2.45 .. -1.25 | 8.11: the high deck's planks carried back to the house: honey planks laid across, the ice tongue's three sheets carried on as painted pale blue ice with a white frost edge, snow drifted at the house's foot on its west half | 1 | C |
| `tele_deck_bracket` | 9.5 x 7.5 x 0.3 | foot (x -275.15, y 777.8), made in place | 8.11: the high deck's two lattice brackets from under the deck back to the face, half sunk in the dock ice: (-270.4, 785.3) to (-279.4, 777.8) and (-274.9, 785.3) to (-279.9, 781.1), a lattice bay cut, greyed, frosted | 1 | C |
| `tele_platform_post` | 0.3 x 11.6 x 0.3 | foot (x -281.4, y 779), z 1.3 .. 1.6 | FOREGROUND 8.11: a square station post in the cableway's red, 0.3 m, in front of the high deck's west end where the planks meet the rock, from below the deck to the eave (790.6), carrying the roof's west corner; it matches the cliffs' front post at the low deck. Plain, so it covers only a strip | 1 | C |

## 4. Made for a8.py, not placed by the dress file (its FOR THE AREA FILE items 6d, 8)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `tele_gondola_express` | about 6.4 x 4.12 x 1.74 with its carriage (the car 2.6 x 2.2) | the grip on the cable (as `gondola`) | 8.10, 8.11: the express car, the re-made `gondola` (section 5) with a SHORT STEP 0.6 m out of its west end (cream band on its top and a cream lip underneath, where a raised hand meets it: the whole transfer) and the freight rack 2.4 m out of its east end, each at floor level (the solids: a8.py car_shapes(wr=0.6, eb=2.4), y -3.7 under the grip, 0.1 thick), rust-orange iron, a cream knuckle on each tip; the hanger, the cranked head and the carriage on the cable 2 m back as `gondola`'s | 4 (by a8.py) | C |

## 5. Re-makes of existing models

- **`gondola`** (C; note 77, a8_dress item 8): the car for lines 1 and 2 (four movers) with every
  solid part really modelled exactly along a8.py's `car_shapes(wr=0.9, eb=2.4)`: the BOARDING STEP
  0.9 m out of its west end and the FREIGHT RACK 2.4 m out of its east end at floor level (y -3.7,
  0.1 thick), rust-orange iron with a cream band along the top and a cream knuckle on each tip (so the
  two tips of 8.2's jump show level across the gap); the roof's edges and the floor's edge with the
  cream band; the HANGER (0.12 x 1.5 on the roof's middle) the cableway's red with a cream band round
  its top 0.5 m; above it the hanger's CRANKED HEAD going back to a CARRIAGE on the cable at z -2.0
  (greyed, no cream: scenery). Nothing else solid-looking outside the solids. Then a8.py drops
  `drawn=` in gondola(). Its parked sister for 8.0 is the new `tele_gondola_parked`.
- **`gondola_dead`** (C; 8.9): every solid part of a8.py's `_dead` at its true size, with the rest
  tilt built in as now: the roof in two pieces with the hatch between, the floor, the two end walls,
  the one arm (1.5 x 0.12, held) and the RACK 1.6 m exactly along its solid on the low west end; cream
  bands on the roof's edges, the hatch's rim, the floor's edge, the rack and the arm's top 0.5 m; the
  back door on the back wall (1.2 m behind) hanging open by its top hinge with the peeling pug crest;
  the arm's cranked head and its carriage on the long girder's rail at z -2.0, greyed.
- **`chair`** (C; note 80, "chairs become benches"): a plain plank bench 1.2 x 0.25 at y -3.2 under
  the pivot (the collider), honey planks with a CREAM FRONT EDGE, no back, no arms; its pole fixed to
  the seat's back edge and CRANKED BACK out of the play space (from z -0.15 to z -2.0 in the first
  0.4 m) and up 3.2 m to a clamp on the chair cable at z -2.0, greyed red: the pole is scenery, only
  the seat is held. Today's has the hanger straight down the middle in the plane.
- **`zip_trolley`** (C; 8.7, note 77): the cream handle bar 0.7 m on its stem 0.9 m in the plane (the
  two held parts), the stem cranking back at its top to the trolley's wheels on the zip line at z -2.0
  (greyed, scenery); a8.py takes the trolley's body box out of the mover (item 6b).
- **`counterweight_hung`** (C; 8.8): if it is not so already, re-painted CREAM with two red bands and
  the pug on its face (the whole block is held, so all of it is cream-banded), the iron lifting eye
  0.5 m on top, and a short arm cranked back from the block's back to the column's cable at z -2.0
  (greyed). Its size stays 1.6 x 1.71 (the block 1.6 x 1.2 under the point).
- **`cable_station_low`** (A; 8.1, note 77, a8_dress item 7a): re-made as the station HOUSE without a
  roof: 12.0 m wide (x -250 .. -238 when a7_dress centres it at -244.0), 6.0 m tall at its back wall,
  its front wall lower (4.9 m, clearing the roof's underside) under the real roof's slope, 3.12 deep; board walls in the greyed red
  below bare grey boards, NO CREAM, dark windows, a dark door (about x -244.7 .. -243.5); the striped
  roof and the cream are taken off it (the roof is `tele_roof_low`, a skin). a7_dress's line changes
  to that size and x.
- **`riscos_haul_cable`** (C; a7's, a8_dress item 7b): its top end re-cut so both runs end on the
  pulley at the end frame's foot (-233.0, 688.6) instead of on a wheel at (-237.2, 697); this file
  places the pulley and the run up the frame to the engine.
