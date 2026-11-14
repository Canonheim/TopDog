# La Chimenea: the models to make

The model list for biome 6, from its dress file `tools/peak/areas/a6_dress.py` (164 decos, 35 of
them skins; one card; 2 torches). Every stem here is NEW: not in `kit/models/` nor in
`Top Dog Kit\models\`, nor on the a0 to a5 lists. Make each at exactly its size (metres, w x h x d;
+z faces the camera). The game rescales a landed model that is more than a quarter off.

Reused (not listed): `steam_grate` (6: the five grates' skins at 1.2, 0.8, 0.64, 0.48 and 0.48 of
its 2.5 m, and the strip of grating behind the first at 0.88), `vent_pipe` (4: the quench pipe at
1.0, the breath pipe and the rake wheel's feed at 0.273, the hearth's pipe at 0.24), `pug_mask_iron`
(6, small: over the door at 1.5 m, on the smelter 1.4, on the pier's three risers 1.2, over the last
door 1.1), `anvil` (2) and `anvil_great` (3, the anvils' skins), `bellows_great` (1, moved back under
the deck), `forge_hood_ribs` (1, at its maker's 530.75), `counterweight_chain` (4, the pan's chains,
stretched), `iron_ring_pin` (3, black, on the hut's wall), `papel_tatters` (1, 5 m: the scorched
bunting), `torch_wall` (2: the door's and the hut's lamp, the only two torches), `grass_tuft_dry`
(3: the first dry tufts). a6.py's holds and movers: `iron_ring_pin_long` (8 of the 10 rings),
`mine_bucket_upturned` (the frozen climber's seat, a new solid), `fit_hot_hold` (the nine hot
stones, as now), and the movers' `bellows`, `slag_raft` and `drop_hammer` (re-made, below).

Makers: **A** walls, stone and basalt masses, buildings, far pieces (here: the hall's two walls, the
flue's far wall and the crack's, every skin of the shell and of the stone and basalt ledges, the
furnace, the hammer pier with its towers, the smelter, the smith's hut, the door's head, the
bellows' shelf, the rung pier, the stair doors, the roof's split, the fins, the overhang, the kerb,
the outcrops). **B** props, plants, small dressing (here: the frog, the troughs, the coal, the rake,
the dynamite and its box, the flint knobs, the hearth, the dead crusts). **C** iron, machines,
hammers, bellows, chains' hardware (here: the great mask and its tongue, the hood, the baffle, the
pan and its cradles, the hopper, the bellows' frame, deck and brackets, the little bellows, the
shore and the tapping floor, every wheel, rod, pipe and strap, the jibs, the racks, the flap, the
grille's bars, the chain stubs and links, the hut's sill, the long staples and the side pin).

The forge's look (the sheet `docs/peak/playtest/design/data/a6_biome.py`): at the bottom the
temple's own stonework, soot-black, the same blocks and stepped arches as across the well with the
carving worn nearly away; then iron, black riveted plate, thick chain, grates of square bar, round
rings on pins, pipes with rib bands, heavy, plain and made by hand; above the forge, basalt, grey-
brown in a few big leaning planes split by heat, paler and drier the higher it goes, and pale chalk
in the crack's last few metres. **What you can hold** is rust-orange iron (rings, rungs, chain,
plate edges) and pale grey-brown basalt, dry and matte. **What you can't** is black glassy slag,
soot-wet stone, greased iron. **Hot** is rock or iron glowing orange-red (the game draws the glow:
note 56); cool holds among it plainly grey. **It will break**: cracked already, with a corner gone
(note 64). **It blows**: a grate in the floor or a nozzle. **It moves**: it hangs on chain from a
wheel you can see, or a rod drives it from a crank: every machine shows what works it. **Scenery**:
black iron and black stone, far back, lit red from below, NEVER RUST ORANGE. The big machines stand
on stone footings with the iron pug's face on each. No brick, no timber but tool handles and the
bellows' boards, no crystal, NOTHING GREEN.

Walls and masses are PAINTED (BRIEF.md "Walls and masses"; the reference is
`docs\peak\playtest\design\walls_example_after.png`): a few big planes with a designed outline; low
down the courses of the soot-black blocks flat colour in three or four near-black tones, long and a
little uneven, the joints thin lines, the soot in long uneven bands darkest at the floor; above, the
basalt's grain and its heat cracks long wavy painted lines that run the length of the face; nothing
painted narrows to a point; no dark recess cut into a face (the furnace mouths, the slit of sky and
the roof's split named here are the few real breaks); never a repeated square panel, never a course
or a bed of rock built as its own block; behind each mass the same rock carries on, duller and
cooler. **Judge every wall in the biome's own light, which changes with height**: furnace red from
below at the floor (black shadow above), orange in the loft, the slag's bright orange from
underneath at the pan, gold at the hammers, pale dusty gold in the shaft, blue-white daylight from
above in the crack. Tonight's game frames from the dark places showed painted bands vanishing
wherever their values sit close together: step the tones well apart (the near-blacks low down most
of all), and look at each wall under the light of its own height before it lands. No glowing
materials (lit things are colour: the game adds the lights).

"Origin: foot" means the middle of its base (x and z) at its lowest point; for long pieces, the
middle of its x span, the bottom of its box, the middle of its depth. "Top" means the middle of its
top (it hangs from there). "Wall" means the middle of its foot line, its back on the wall. "Hub" is a
wheel's axle. "Skin" means the model is the look of course solids (`skin=` in a6.py, its FOR THE
AREA FILE item 5): it fills them, z -1.2 .. 1.2, its outline is theirs, its size is theirs (never
rescaled); the dress file's skin box is (x0 .. x1, y0 .. y1) as named in each row. "Made in place"
means made in the course's coordinates about that origin (pipes made to their route, the tilted
pan). `rot` in the dress file is counter-clockwise as the camera sees it: make every piece upright
and level unless the row says otherwise.

## 1. Walls, masses and the big pieces (maker A)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `forja_hall_wall_low` | 55 x 32 x 1.0 | foot (x -263.5, y 476), z -4.6 .. -3.6 | The forge hall's back wall from the floor to 508 (6.0 to 6.3): the temple's soot-black blocks in bays about 4 m wide, a sloped base, the carved band worn nearly flat (painted bands at 484.0 .. 484.6 and 490.0 .. 490.6 by the door, 484.3 .. 484.9 by the hut, 505.0 .. 505.6 behind the twins), the soot darkest at the floor, lit red from below with black above; at its east end the foot of the hammer pier, with TWO BANKED FURNACE MOUTHS cut in it (stepped arches x -252.3 .. -249.7 and -247.6 .. -245.0, 478.5 .. 481.8, the banked fire painted deep red in them): the only real breaks in it | 1 | A |
| `forja_hall_wall_high` | 55 x 33 x 1.0 | foot (x -263.5, y 508), z -4.6 .. -3.6 | The same wall on up through the bellows loft and the hammer shop (6.4 to 6.6), lit orange from above and the slag's orange from below; its top 541 under the roof west of x -262, then down along the hood's line to the pier's head (535.6), and the pier's stone carried up round the last stair door and its pug to 540.2 at x -241 .. -236.5 (6.7: the last cut stone); basalt above is the flue's far wall, on the same plane | 1 | A |
| `forja_flue_far_wall` | 28 x 42.4 x 1.0 | foot (x -248, y 535.6), z -4.6 .. -3.6 | The flue's far wall (6.7, 6.8): bare basalt from where the temple stone stops, a few big leaning planes and ONE LEANING SLAB standing out of it, heat cracks as long wavy lines, a dull red still in the shaft's lowest cracks, paler and drier up to a dry pale grey at the top; THE SHAFT OF DAYLIGHT painted down it from the crack (from (-240.8, 577) to (-249, 566) to (-254, 552), 2.5 wide, blue-white at the top dying through dusty gold into the red below 552: what a6.py's two cards draw today); the SLIT OF SKY open through it from 562 up (x -246.6 .. -242.6, widening up to the crack: the sky cards behind it at -5). Its lower edge meets the hall wall's top. Nothing built on it | 1 | A |
| `forja_crack_back_wall` | 16.5 x 22 x 0.55 | foot (x -242.25, y 568), z -1.8 .. -1.25 | 6.9: the crack's back wall, only 1.25 m behind you: the flue's basalt grey-brown and dry west of a slanting line ((-243.6, 590) .. (-243.6, 579.2) .. (-240.4, 575.2) .. (-236, 570)), PALE CHALK east of it (the mountain's outside); the gap's wall under the chockstone (x -240 .. -236.5, 568 .. 575.6) black and glassy, worn smooth, nothing on it to catch; the flint band a line of knobs in white rind slanting from the second step (-241, 575.9) to the opening (-234.3, 581.6); the lowest edge of daylight painted across it from (-234, 585.6) to (-246.25, 575.05). Its outline stops at the roof's line | 1 | A |
| `forja_floor` | 55 x 5 x 2.4 | skin (-291 .. -236, 475 .. 480) | Shell edges 0 and 1: the forge floor, soot-black temple slabs worn paler on top, every fall's end; swept paler inside the hut (x -241 .. -237) with a ring of scale and soot round the anvil; dipping to 478 at x -262 | 1 | A |
| `forja_east_wall` | 3 x 86.8 x 2.4 | skin (-236 .. -233, 479.2 .. 566) | Shell edge 2: the flue's own rock, black and wet with soot; at its west edge in the shaft the TWO EMPTY RING SOCKETS (note 61: dark flat squares 0.3 across, each with a rust streak under it, plainly nothing to hold) at (-236.3, 538.6) and (-236.3, 544.3) | 1 | A |
| `forja_crack_east` | 6.2 x 13.4 x 2.4 | skin (-237.2 .. -231, 566 .. 579.4) | Shell edges 3 and 4 and the rock under the sill (a6.py line 267): black glassy basalt, the gap's wall, worn smooth by the draught | 1 | A |
| `forja_crack_roof` | 13 x 12 x 2.4 | skin (-244 .. -231, 578.5 .. 590.5) | Shell edges 6 to 8: the crack's roof and the door's lintel, basalt going to pale chalk toward the opening, THE SPLIT CUT THROUGH IT over the chockstone (x -240.1 .. -237.5, 582.5 .. 585.9) so `forja_roof_split` shows | 1 | A |
| `forja_flue_crown` | 16 x 15.5 x 2.4 | skin (-260 .. -244, 566 .. 581.5) | Shell edges 9 and 10: the flue's crown, dry pale basalt lit from above | 1 | A |
| `forja_flue_west_wall` | 8 x 25 x 2.4 | skin (-265 .. -257, 541 .. 566) | Shell edge 11: the flue's west wall leaning in over the climb, basalt grey-brown at the bottom, paler upward | 1 | A |
| `forja_hall_roof` | 29 x 3 x 2.4 | skin (-291 .. -262, 541 .. 544) | Shell edge 12: the hall's roof, soot-black blocks, the soot thickest under it (in place of a6.py's soot card) | 1 | A |
| `forja_west_wall` | 3 x 53 x 2.4 | skin (-294 .. -291, 488 .. 541) | Shell edge 13: the forge's west wall over the door, soot-black temple blocks | 1 | A |
| `forja_landing` | 4.6 x 6 x 2.4 | skin (-295.5 .. -290.9, 474 .. 480) | 6.1: the ledge the censer drops you on and the slab under the door: temple stone soot-black on its face and worn pale on top, the temple's carved band on its edge one last time | 1 | A |
| `forja_furnace` | 10.3 x 20.8 x 1.75 | foot (x -272.05, y 478.4), z -3.2 .. -1.45 | 6.2 (and 6.1's right side, 6.3's crown): the great furnace, four tiers of soot-black blocks stepping back (-277.2 .. -268 at the foot, -276.6 .. -268.4 from 490, -276.0 .. -268.8 from 493.6, -275.4 .. -269.6 from 496.1 to 499.2), a worn carved band round the top of each of the first three (490.0, 493.6, 496.1, 0.3 tall: the cool bosses sit on them); its first tier's face at -1.45 OVERHANGING a foot set back to -2.5 below 485, where THE MOUTH is (a stepped arch 3.2 wide, x -275.6 .. -272.4, 478.7 .. 482.6, the fire deep red in it) under a ribbed iron hood (483 .. 484.5) cast with it; the charging step's corbel (-268.8 .. -266.9, 493.8 .. 495.4, its face set back at -2.0 for the branch pipe to pass in front); the crown open and glowing. The burnt strip along the holds is a6.py's card at -1.35, in front: leave the face plain there | 1 | A |
| `forja_hammer_pier` | 23.1 x 45 x 1.9 | foot (x -247.55, y 490), z -3.6 .. -1.7 | 6.5 to 6.7: the stepped pier of the temple's blocks, out of the hall wall from 490, three giant steps (tops 522, 526, 530, each 4.2 wide and 4 tall: x -257.2, -251.6, -247.4, -243.2) and a head (-243.2 .. -236 at 535), the first landing (-257.2 .. -254 at 522) on a stepped corbel to -259.1; the steps' faces at -2.4, a round boss where the iron pug sits on each riser; and THE THREE SLOTTED TOWERS, 1.4 wide, standing forward to -1.7 behind each hammer (x -253.5, -249.3, -245.1) from its step to under the steam pipe (tops 533.3, 536.2, 539.2), a dark slot 0.6 wide down each one's middle where the hammer's tail runs | 1 | A |
| `forja_smelter` | 6.5 x 4.8 x 1.75 | foot (x -283.45, y 525.2), z -3.2 .. -1.45 | 6.5: a round-bellied furnace of temple stone on the tapping floor (x -286.7 .. -281.9, to 530), a boss on its front where the iron pug sits (-284.3, 527.3), a stone spout from its tap hole to the head of the pan (to -280.2, 525.35 .. 526.3), the slag bright in the spout | 1 | A |
| `forja_smith_hut` | 5.6 x 4.05 x 1.4 | foot (x -238.8, y 478.9), z -2.65 .. -1.25 | 6.0 (note 59): the smith's lean-to against the east wall, cut away at the front: a back wall of the forge's black blocks (-241 .. -237, to 482), a roof of riveted iron sheet sloping down from the east wall (from 483.0 at x -236 to 481.9 at -241.6) on two iron back posts (-241, -237); stone and iron only, NO TIMBER; the roof stops at -1.25 | 1 | A |
| `forja_door_head` | 4.8 x 9 x 1.9 | foot (x -291.6, y 480), z -3.6 .. -1.7 | 6.1 (5 to 6): the forge door seen from inside: the stepped arch's reveal through the well's wall (dark through to the well) and its stepped lintel blocks standing out of the west wall (-291 .. -289.8 at 487.2 .. 488, -291 .. -289.2 at 488 .. 488.8), soot-black, worn; the small pug and the last torch hang on its east jamb | 1 | A |
| `forja_bellows_shelf` | 7.6 x 2.3 x 2.3 | foot (x -287.2, y 510.9), z -3.6 .. -1.3 | 6.4: a shelf of temple blocks out of the west wall on stepped corbels (the corbels stepping in from -283.4 at 512.3 to -286.4 at 510.9), the great bellows standing on it | 1 | A |
| `forja_rung_pier` | 1.6 x 5.1 x 0.6 | foot (x -286, y 519.5), z -1.9 .. -1.3 | 6.4: a pier of temple blocks from the deck to the shore, the rungs' staples driven into it; SCORCHED IN A STAR round the dynamite rung's place (523.1) from the last time | 1 | A |
| `forja_stair_door` | 2 x 3 x 0.4 | foot, on the wall (z -3.6 .. -3.2) | The smiths' way up: the temple's stepped arch shut with an iron grille of three bars, set in the wall: behind the loft's lip (6.3, at 1.0) and the last behind the pier's head (6.6, at 0.933: 2.8 tall) | 2 | A |
| `forja_charging_step` | 4.7 x 0.6 x 2.4 | skin (-271.5 .. -266.8, 495.4 .. 496.0) | 6.2's top ledge: the furnace's charging step, a slab of temple stone with a worn carved edge, the first twin's grate set in it | 1 | A |
| `forja_loft_lip` | 4.1 x 0.6 x 2.4 | skin (-267.6 .. -263.5, 511.4 .. 512.0) | 6.3's top ledge: the lip of the bellows loft, a temple slab sooted on its face, worn pale on top | 1 | A |
| `forja_pier_landing` | 3 x 0.6 x 2.4 | skin (-259.2 .. -256.2, 522.4 .. 523.0) | 6.5's end ledge: the hammer pier's first landing, pale worn stone | 1 | A |
| `forja_pier_head` | 6.4 x 0.6 x 2.4 | skin (-242.4 .. -236, 535.0 .. 535.6) | 6.6's top ledge: the pier's head, the last cut stone on the climb | 1 | A |
| `forja_basalt_shelf` | 4.8 x 0.6 x 2.4 | skin (-245.8 .. -241, 548.4 .. 549.0) | 6.7's top ledge (L7): a shelf of basalt on the baffle's head, the first ledge nobody cut, grey-brown, a dull red crack in its face; vent 1's grate set in it | 1 | A |
| `forja_doorstep` | 4 x 0.6 x 2.4 | skin (-247.4 .. -243.4, 571.9 .. 572.5) | 6.8's top ledge (L8): the crack's doorstep, natural basalt, dry and pale, daylight on it | 1 | A |
| `forja_pillar` | 3.4 x 21 x 2.4 | skin (-243.4 .. -240, 554 .. 575) | 6.8 and 6.9: the pillar on the right, black soot-wet basalt (in the play space, can't be held: plainly dark and wet) | 1 | A |
| `forja_crack_steps` | 3.4 x 2 x 2.4 | skin (-243.4 .. -240, 573.5 .. 575.5) | 6.9: the two steps on the pillar (-243.4 .. -241.7 at 574.0, -241.7 .. -240 at 575.5), the last of the basalt, pale and dry | 1 | A |
| `forja_chalk_sill` | 6.2 x 0.6 x 2.4 | skin (-237.2 .. -231, 579.4 .. 580) | 6.9: the sill out through the door, the first of the chalk: white, dry, gritty, wind-blown dust on it | 1 | A |
| `forja_roof_split` | 2.6 x 3.4 x 1.2 | foot (x -238.8, y 582.5), z -2.45 .. -1.25 | 6.9 (note 64): the split in the roof right over the chockstone, packed with blocks of chalk that have not fallen yet, the next one plainly waiting at its mouth; seen through the cut in the roof's skin | 1 | A |
| `forja_basalt_fin` | 3.1 x 4.8 x 0.6 | foot, z 1.3 .. 1.9 | Foreground: a rough fin of basalt in front of the pillar's foot (6.8; at 0.9 under the steps, 6.9), its outline (-1.55, 0) .. (1.55, 0) .. (1.15, 3.4) .. (-0.25, 4.8) .. (-1.25, 2.9) about its origin, dark, covering only the pillar | 2 | A |
| `forja_chalk_overhang` | 3 x 4.1 x 0.7 | foot (x -236.1, y 584.8), z 1.3 .. 2.0 | Foreground, 6.9: a dark chalk overhang in front of the roof over the opening (outline (-1.1, 0) .. (1.5, 2.1) .. (1.5, 3.2) .. (-0.1, 4.1) .. (-1.5, 2.2)), so the opening is the brightest shape in the frame | 1 | A |
| `forja_floor_kerb` | 4 x 0.9 x 0.7 | foot, z 1.3 .. 2.0 | Foreground: a low lip of soot-black blocks along the very bottom of the frame, in 4 m lengths (the ends meet cleanly), its top 1.6 m below the floor's: the same kerb the whole length of the forge floor (x -291 .. -235) | 14 | A |
| `forja_ledge_block` | 0.9 x 0.45 x 0.4 | wall (its back on the far wall) | 6.8: a small outcrop of basalt standing proud of the far wall, a flat top for the first dry tuft (the kit's `grass_tuft_dry` stands on it) | 3 | A |

## 2. Props and small dressing (maker B)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `forja_frog_smith` | 0.3 x 0.3 x 0.3 | foot | 6.0 (notes 59, 60): the chimney's frog, sitting on the heel of the small anvil in a LEATHER APRON with a tiny hammer, looking up: friendly and nothing more. Only the frog lives in the hut | 1 | B |
| `forja_hearth` | 1.15 x 2.35 x 1.1 | foot (x -236.55, y 479.15) | 6.0: a block of temple stone against the east wall with a bed of orange coals on it (479.15 .. 480.3) and a small iron hood over it (481 .. 481.5); the kit's vent_pipe goes up out of the hood | 1 | B |
| `forja_quench_trough` | 1.6 x 0.6 x 0.7 | foot | A stone trough of black water with a pair of tongs left in it: by the hut's west post (6.0) and by the door (6.1) | 2 | B |
| `forja_coal_heap` | 1.9 x 0.95 x 1.0 | foot | A heap of coal, black with a few dull red embers low in it: between the hut's two furnace mouths (6.0), by the great furnace's mouth at 1.263 (6.2) | 2 | B |
| `forja_rake` | 0.25 x 2.4 x 0.15 | foot (placed at rot 4, leaning) | 6.2: a long iron fire rake, black, its handle worn, leaning on the furnace's foot | 1 | B |
| `forja_dynamite_box` | 0.6 x 0.45 x 0.4 | foot | 6.4 (note 58, Parker 11-13: yes): a small open box on the deck behind the rungs, the mine's skull pug stencilled on it (`uipeak_lib.skull_shapes`), three more fat red sticks with fuses showing: it tells you what the red rung is | 1 | B |
| `forja_flint_knob` | 0.4 x 0.4 x 0.4 | foot | 6.9: a knob of flint in its white rind, the size of two fists, dry, pale and matte. Eight sit flush in the band on the crack's back wall (placed here, z -1.45, mostly sunk); the three you hold are the same stem (section 4) | 8 (+3 by a6.py) | B |
| `forja_dead_crust` | 0.8 x 0.7 x 2.4 | skin (x ±0.4 round -275.0 and -269.0, from the slag 0.1 down to 0.6 up) | 6.5: a black glassy tooth of slag that spat up and froze round a cradle's hanger: shining, wet-looking, nothing about it says stand here (its outline a6.py's: (-0.4, -0.1), (0.4, -0.1), (0.05, 0.6)) | 2 | B |

## 3. Iron, machines and hardware (maker C)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `forja_great_mask` | 8 x 11 x 0.6 | foot (its chin, x -281.5, y 484.2), z -1.9 .. -1.3 | 6.1: THE GREAT IRON MASK, the forge's own copy of the temple's, remade taller (Parker 11-13): a pug's face cast in black plates and riveted, two small folded ears (494.9 .. 495.2), brow wrinkles (493.55 .. 494.15), eyes at (-283.5, 492.7) and (-279.5, 492.7), THE NOSE where the ring is (491.95 .. 492.5: the nose ring's pin roots in it), the mouth open over the chain (487.3 .. 488.7), and THE ROOT OF THE TONGUE lolling out of its east corner ((-280.9, 487.5) .. (-278.3, 486.0)) down to the plate you land on; its outline a6_areas.py `_MASK`. Black iron, set back: it can't be mistaken for a wall | 1 | C |
| `forja_mask_tongue` | 3.9 x 0.5 x 2.4 | skin (-280.3 .. -276.4, 485.5 .. 486.0) | 6.1's ledge L1: the mask's tongue flattened into a plate, riveted iron, RUST ORANGE on top, curled under at its east tip (the curl inside the ledge's outline, pointing at the furnace) | 1 | C |
| `forja_hood` | 17 x 12.5 x 2.4 | skin (-258.5 .. -241.5, 530.4 .. 542.9) | 6.6's slick slab: the forge's great hood, soot-wet riveted plate at 35 degrees from the shaft's foot down to its spout over the hall (made in place along a6.py line 200's slab); the kit's ribs show under it | 1 | C |
| `forja_baffle` | 0.5 x 8.4 x 2.4 | skin (-241.5 .. -241, 540 .. 548.4) | 6.7: the baffle, black riveted plate greased with soot, the window (543.4 .. 546) cut through it, the window's edges scraped bright | 1 | C |
| `forja_slag_pan` | 16.7 x 3.4 x 2.4 | skin (-280.3 .. -263.6, 521.2 .. 524.6), made in place | 6.5: the pan's front 2.4 m (a6.py line 152's solid, tilted 8 degrees, low end east): black riveted plate with slag frozen in runs over its rim; the slag's surface bright yellow-orange in the middle of each gap, skinned dark red at its edges (live: it lights everything from under) | 1 | C |
| `forja_pan_back` | 16.7 x 4.2 x 1.75 | foot (x -271.95, y 521.2), z -3.0 .. -1.25, made in place | 6.5: the pan's back half behind the play space, the same tilt, its back rim 0.8 above the front's ((-280.3, 525.4) .. (-263.6, 523.1)), the slag in it glowing, the spout's rope of slag spreading down it from the head, the lip at the low east end | 1 | C |
| `forja_pan_cradle` | 1 x 2.7 x 1.75 | foot (its strap's bottom), z -3.0 .. -1.25 | 6.5: an iron cradle strapped under the pan's back half with a hanger rising at its back to the eye where the two heavy chains hook on (the rake handles pass through an eye on it) | 2 | C |
| `forja_hopper_back` | 6.9 x 2.5 x 1.35 | foot (x -262.25, y 500.8), z -2.6 .. -1.25 | 6.3: the round iron hopper's back half on top of the quench pipe, lopsided like its front (short west, long east, to catch the falling slag), black, glassy with splashed slag inside | 1 | C |
| `forja_hopper_front` | 7.22 x 2.9 x 2.4 | skin (-265.86 .. -258.64, 500.6 .. 503.5) | 6.3: the two slick plates as the hopper's front edge (a6.py's beams, 40 degrees: west (-264.2, 500.8) .. (-265.7, 502.06), east (-261.8, 500.8) .. (-258.8, 503.3), 0.5 thick): black greased iron with runs of glassy slag frozen down them, the darkest and shiniest thing in the frame | 1 | C |
| `forja_bellows_frame` | 8.8 x 6.3 x 2.35 | foot (x -283.6, y 513.2), z -3.6 .. -1.25, made in place | 6.4: the great bellows' iron frame, made round the kit's bellows: posts, a strut from the shelf's corbels to the deck's east end ((-283.5, 513.3) .. (-279.7, 518.9)), a post at -283.65, and the fixed deck carried back on it to the wall (518.9 .. 519.5) | 1 | C |
| `forja_bellows_deck` | 8.8 x 0.6 x 2.4 | skin (-288 .. -279.2, 518.9 .. 519.5) | 6.4's L4: the fixed timber deck on the bellows' frame, above the moving board: pale dry boards (the bellows' boards are the one timber allowed) with iron straps | 1 | C |
| `forja_bellows_bracket` | 2.2 x 0.5 x 2.35 | foot, z -3.6 .. -1.25 | 6.4: a stepping bellows' fixed base plate (its top at the folded body's foot) on two iron brackets from the wall, a slot in it where the cam reaches up | 3 | C |
| `forja_bellows_small` | 1.4 x 0.95 x 0.7 | foot | 6.0: the little bellows on a stand beside the hearth, two boards, leather pleats and a nozzle into the hearth, worked by a foot treadle and a rod: the great bellows made small | 1 | C |
| `forja_shore` | 4.7 x 0.6 x 2.4 | skin (-285 .. -280.3, 524.6 .. 525.2) | 6.4's top ledge: the iron shore, the front edge of the tapping floor, riveted plate, rust orange on its worn edge | 1 | C |
| `forja_tapping_floor` | 10.7 x 0.6 x 2.35 | foot (x -285.65, y 524.6), z -3.6 .. -1.25 | 6.4 and 6.5: the tapping floor carried back to the wall, a riveted iron gallery the smelter stands on, black | 1 | C |
| `forja_shore_bracket` | 1.5 x 1.5 x 1.6 | foot, z -2.9 .. -1.3 | 6.4: a triangular iron bracket under the tapping floor, its upright edge west (the second placed flipped) | 2 | C |
| `forja_steam_wheel` | 3.4 x 3.4 x 1.2 | hub (-287.6, 509.0), z -2.8 .. -1.6 | 6.4: what works the great bellows: an iron paddle wheel 3 m across in stone cheeks, a steam nozzle at its west rim, A CRANK on its axle (the pin at (-288.5, 509.5)) | 1 | C |
| `forja_cam_wheel` | 2.2 x 2.2 x 2.0 | hub, z -3.6 .. -1.6 | 6.4 (and 6.3): an iron wheel 2 m across with ONE CAM on its rim that pushes a stepping bellows' board up 1.8 m, on an axle from a wall bracket, a crank pin for the coupling rod | 3 | C |
| `forja_rake_wheel` | 2.6 x 2.6 x 0.4 | hub (-280.7, 527.3), z -1.85 .. -1.45 | 6.5: the rake wheel at the pan's head, 2.4 m across, THREE CRANKS on its axle (one per rake handle), a steam nozzle at its rim on the feed pipe | 1 | C |
| `forja_lift_wheel` | 4.6 x 4.6 x 0.3 | hub (each hammer's x, its anvil + 3.7), z -1.65 .. -1.35 | 6.6: a lifting wheel 4.4 across with paddles on its rim and ONE PEG that hooks under the hammer's tail and lets it go at the top: you read the hammer's time from it | 3 | C |
| `forja_drive_rod` | 0.14 x 1.0 x 0.1 | its middle (made upright; stretched to each span, FOR THE AREA FILE 6e) | A flat iron rod with an eye at each end: the crank rod (5.6 m), the coupling rod (7.9), the long rod (11.4), the three rake handles (1.75, 7.3, 13.4) | 6 | C |
| `forja_feed_pipe` | 1.6 x 19.2 x 0.6 | foot (x -290.1, y 489), z -2.5 .. -1.9, made in place | 6.4: the steam wheel's feed, a ribbed pipe 0.6 across up the west wall from over the door to 508.2, ending in a nozzle turned east at the wheel's rim | 1 | C |
| `forja_air_pipe` | 1.0 x 4.5 x 1.6 | foot (x -274.5, y 499.0), z -3.6 .. -2.0 | 6.2 and 6.3: the air pipe from the bellows loft, ribbed, 0.6 across: out of the wall at 503 .. 503.5 through a flanged elbow and down into the furnace's crown | 1 | C |
| `forja_branch_pipe` | 4.2 x 2.0 x 0.6 | foot (x -266.2, y 493.4), z -1.9 .. -1.3, made in place | 6.3: the branch off the standpipe, west under the charging step (493.4 .. 494.0) and up an elbow (-268.3 .. -267.7) to just behind the first grate: the twins are one pipe with two mouths | 1 | C |
| `forja_hood_pipe` | 14.7 x 18.7 x 1.0 | foot (x -250.95, y 529.5), z -2.3 .. -1.3, made in place | 6.6 and 6.7: the forge's steam pipe, 0.6 across, rib bands: up under the hood 1.0 to 1.6 m below its line from (-258.3, 529.5), THREE DROP NOZZLES toward the lifting wheels (at x -255.1, -250.9, -246.7, each 0.9 long), through the hood at 540.2, up the wall (-244.2 .. -243.6) and in under L7 (547.6 .. 548.2) with an elbow forward to just behind vent 1's grate | 1 | C |
| `forja_flue_pipe` | 5.1 x 17.72 x 1.0 | foot (x -246.15, y 549.0), z -2.3 .. -1.3, made in place | 6.8 (note 62): the same pipe's three flights up the far wall: a riser (-244.2 .. -243.6, 549 .. 556.8), across under grate 2 (-246.9 .. -243.6, 556.2 .. 556.8) with an ELBOW forward to just behind it, a riser (-245.55 .. -244.95, 556.8 .. 565) with a CLAMP whose eye is the first ring (557.9), across under grate 3 (-248.7 .. -244.95, 564.4 .. 565) with its elbow, a capped stub (-247.35 .. -246.75, 565 .. 566.72) where the second ring is; plainly one machine holding the grates up | 1 | C |
| `forja_pipe_strap` | 2.6 x 0.3 x 2.3 | foot, z -3.6 .. -1.3 | 6.3: an iron band round the quench pipe with a bolted arm back to the wall | 2 | C |
| `forja_mouth_hood` | 4.4 x 1.5 x 1.3 | wall (its back on the wall) | 6.0: a ribbed iron hood over a furnace mouth in the back wall, a trapezoid narrowing upward into the wall (at 0.82 over the two banked mouths) | 2 | C |
| `forja_wall_jib` | 4.1 x 7.0 x 0.5 | the foot of its post (the arm reaching +x) | The smiths' hoist: an iron post 6.9 tall, an arm 3.9 out and a brace, a hook eye at the arm's end where the ring's pin roots (the ring is the hold): on the pier's first landing reaching west over the pan's lip (6.5, flipped), on the loft's lip at 0.5 (6.3) | 2 | C |
| `forja_tongs_rack` | 2.0 x 1.0 x 0.3 | wall | A bar on two wall brackets with five pairs of tongs hanging from it, black, facing the camera: over the anvil by the door (6.1), on the hut's back wall at 0.7 (6.0) | 2 | C |
| `forja_flap` | 0.4 x 2.5 x 0.9 | top (its hinge), placed at rot -23.5 | 6.7: the iron flap of the baffle's window, hinged at the top on the far side, hanging slack (it rattles and is flung open in the gust: still for now) | 1 | C |
| `forja_grille_bar` | 5.4 x 0.15 x 0.15 | its middle, placed at rot -22.8 | 6.7: the cap grille's one whole bar from the east wall up to the top ledge, square iron; the two rings' pins come off it and A SNAPPED PIN where the middle ring was (at 1.6 m from its west end) | 1 | C |
| `forja_grille_bar_snapped` | 1.5 x 0.15 x 0.15 | its middle | 6.7: a bar of the same grille snapped off, its broken end ragged (the second flipped) | 2 | C |
| `forja_chain_stub` | 0.35 x 0.75 x 0.4 | the pin, links standing up from it | The bare flue's only dressing: three short thick links on a pin in the far wall, black: two in the shaft (the lower standing straight up; the upper at rot 90, lying west), two at 6.8 | 4 | C |
| `forja_chain_links` | 0.7 x 2.1 x 0.35 | top | Foreground, 6.7: the last three links of a heavy chain (links 0.7) hanging into the top corner in front of the east wall, black | 1 | C |
| `forja_hut_sill` | 4.2 x 0.5 x 0.25 | foot, z 1.3 .. 1.55 | Foreground, 6.0: a low sill of iron plate on the floor's front edge with the two front posts' stumps cut off level: the hut's front was taken away | 1 | C |
| `forja_ring_bent` | 0.5 x 0.15 x 0.5 | foot | 6.0: a wall ring lying bent open on the small anvil: the job the frozen climber is waiting for | 1 | C |

## 4. Made for a6.py, not placed by the dress file (its FOR THE AREA FILE item 8)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `forja_staple_long` | 0.8 x 0.1 x 1.4 | where it meets the pier, midway between the legs, at the bar's height | 6.4: an iron staple driven into the rung pier, its two legs running 1.3 m forward out of the pier (z -1.3) so its bar, 0.8 wide and 0.09 thick, lies at z 0 on the course's rung; rust orange, worn bright on top | 3 (lines 124-125) | C |
| `forja_dynamite_stick` | 0.8 x 0.26 x 0.26 | its middle | 6.4 (note 58): a fat red stick with paper bands and a fuse curling off its east end: what lights, blows and comes back 10 s later | 1 (line 131) | B |
| `forja_rung_stubs` | 0.9 x 0.2 x 1.4 | as `forja_staple_long` | 6.4: the two bent stubs of the snapped rung, out of the scorched pier, the stick lying in them; they stay when the stick goes | 1 (line 131) | C |
| `forja_cool_boss` | 0.6 x 0.6 x 0.4 | its centre | 6.2: the one boss of each worn carved band left whole: a small pug's head in plain cold grey stone, a damp line along it | 3 (line 73, the "rock" holds) | A |
| `forja_ring_side_pin` | 0.6 x 0.55 x 0.1 | the ring's centre (the pin running +x 0.3 to the wall) | 6.7: the kit's 0.5 ring, rust orange, worn bright inside, facing the camera on a pin driven SIDEWAYS into the east wall's face (the shaft's two wall rings hang 0.3 m off its side) | 2 (line 222) | C |
| `forja_chockstone` | 2.9 x 1.5 x 2.4 | the piece's centre | 6.9 (note 64): a rough block of chalk jammed across the gap, the stand-in's wedge ((-240.05, 575.5), (-237.15, 576.2), (-237.15, 577.0), (-240.05, 577.0)), CRACKED RIGHT THROUGH WITH A CORNER GONE (the game's one breakable look); it breaks into rough chunks | 1 (line 269) | A |

**Re-made, not new stems** (FOR THE AREA FILE item 8): `anvil_great` (6.6: the face polished
bright in the middle exactly as wide as the hammer, 2.0 m, sooty at its two ends; the waist a black
glassy crust of slag; the iron pug on its foot); `anvil` (its timber stump becomes a stone footing
with the iron pug's face: no timber in the forge); `drop_hammer` (black greased iron with a peaked
top, THE PUG'S FACE cast on its front, its striking face a band of bright worn steel, the only pale
thing on it, the lug rust orange); `slag_raft` (a thick iron plate with a turned-up edge, rust
orange on top, black and crusted on its sides, an eye at its west end for the rake's handle);
`bellows` (note 57: a pale dry timber top board with a pug's face on its front edge, black greased
leather pleats that open as it swells and close as it folds, a fixed iron base); `bellows_great`
later, when the engine can turn its top board on the nozzle's hinge with the gust (note 57: in
parts, lower board, top board, pleats, nozzle box with the pug's face, a stone weight on the top
board); `steam_grate` as it is (square bars in a raised rim, rust orange where feet wear it, the
grille red from below).
