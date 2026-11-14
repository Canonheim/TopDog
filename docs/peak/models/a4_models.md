# El Jardín de Hongos: the models to make

The model list for biome 4, from its dress file `tools/peak/areas/a4_dress.py` (217 decos, 27 of
them skins; 11 lantern pods lit). Every stem here is NEW: not in `kit/models/` nor in
`Top Dog Kit\models\`, nor on the a0 to a3 lists. Make each at exactly its size (metres,
w x h x d; +z faces the camera). The game rescales a landed model that is more than a quarter
off. Reused (not listed): `glow_moss` (6, at scale 1.5 to 3.0), `spore_pod` (1, at 1.2),
`spore_lantern` (1), `frog_sit` (1), a3's `gruta_fern_clump` (1, the tuft under the west door);
a4.py keeps `shroom_great_cap` (the great cap's skin) and `snail_wall` (the five snails).

Makers: **A** buildings, walls and rock masses, far cards, ground slabs (here: the room's earth
and rock, the slime island and the two slime masses, the giant mushroom's big parts, the frog's
hut, boulders and outcrops). **B** props, plants, mushrooms, signs, small dressing (here: the
bell mushrooms, the stalks and saucers, roots, shelf fungus, pods, snails, mycelium, the frog's
things, the foreground cards). **C** timber, iron, machines: one piece, the frog's clay stove.
Nothing else in the garden is made by anyone.

The garden's look (the sheet `docs/peak/playtest/design/data/a4_biome.py`): everything is alive.
Mushrooms are the garden's trees: stalk, skirt-ring part way up, cap, gills under the cap. **The
mushroom that throws you** is orange with pale spots (the fitted kit's caps: see "Re-made"
below). **The scenery mushroom is a second kind, the bell mushroom** (Parker, 11-13): tall and
thin, a small pale blue-green cap like a bell, in stands; it never grows in the play space.
**NOTHING ORANGE IS SCENERY**: an orange cap always means bounce, so no piece on this list has
orange on it (the kit's `shelf_fungus` has a tangerine top, which is why this biome has its own
cream one). What you can hold: cream gills, tan roots and vines, pale mossy rock, a snail's
shell, shelf fungus, dry and matte. What you can't: black slime, glossy and running, and wet
stalks. Light is a green glow from moss and spore lanterns, from below and the sides, with the
caps' orange the one warm colour (COLOUR, never a glowing material; a4.py adds the lights). Rock
and earth are PAINTED (BRIEF.md "Walls and masses"): damp earth and root-bound rock in a few big
planes with soft leaning edges, its layers of dark earth and paler rock, roots, moss and seep
stains flat colour in three or four tones, long wavy lines and bands running the length of the
face, nothing painted narrowing to a point, no dark recess cut into a face; the few real breaks
are a thick root standing out, a ledge with shelf fungus, one hollow under an overhang with its
shadow painted, one fallen boulder. Slime is black and glossy, in running sheets (bands, never
wedges). Behind each wall its body carries on, darker, duller and cooler, never pale.
**Judge every wall in the garden's own light**: it is dark and green in here, and the game's
frames from the dark places showed painted bands vanishing wherever their values sit close
together. Step the tones well apart, and look at each wall under green light before it lands.

"Origin: foot" means the middle of its base (x and z) at its lowest point; for long pieces, the
middle of its x span, the bottom of its box, the middle of its depth. "Top" means the middle of
its top (it hangs down from there). "Wall edge" (shelf fungus, bent stalks) means the middle of
the edge that meets the wall, at its base; it grows toward +x (the dress file flips it to grow
west). "Skin" means the model is the look of course solids (`skin=` in a4.py, its FOR THE AREA
FILE item 5): it fills them, z -1.2 .. 1.2, its outline is theirs, and its size is theirs (never
rescaled). `rot` in the dress file is counter-clockwise as the camera sees it: make every piece
upright and level unless the row says it is made in place.

## 1. Walls, masses and the big pieces (maker A)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `jardin_far_wall` | 108.0 x 126.0 x 0.3 | foot (x -240, y 258), z -11.0 | The far wall of the whole room (it has no sky): one flat painted piece cut to the room's outline (x -294 .. -186, y 258 .. 384). Damp earth and root-bound rock in long wavy bands; on its lower half the forest going on, bell stand behind bell stand painted as silhouettes, fading to blue-green upward and away. Mid values: the green glow lifts lit faces | 1 | A |
| `jardin_floor_back` | 35.9 x 3.0 x 9.5 | foot (x -273.05, y 261), z -10.75 .. -1.25 | 4.1: the hall's moss floor carried back to the far wall, thick green moss on top in soft patches (a low mist lies on it: the game's), dark earth with roots below; the bell stands and boulders stand on it | 1 | A |
| `jardin_ramp_back` | 39.9 x 30.93 x 9.5 | foot (x -235.15, y 261), z -10.75 .. -1.25 | 4.2 to 4.4, made in place: the slime ramp's earth bed carried back at its 35 degrees from (-255.1, 264) to (-215.2, 291.93), black slime running down it in broad sheets; west of x -244 it reaches the far wall (two bell stands and a sleeping snail on it), east of that only to the pocket's back wall at z -6.5. A hollow in it under the column (x -240.3 .. -235.7) where the pod bed sits | 1 | A |
| `jardin_garden_back` | 25.2 x 3.0 x 9.5 | foot (x -202.6, y 315), z -10.75 .. -1.25 | 4.0: the east garden's moss floor carried back, quiet and soft, the hut's three bell stands, boulders and the snail on it | 1 | A |
| `jardin_roof_back_east` | 75.0 x 27.0 x 9.5 | foot (x -224.5, y 346), z -10.75 .. -1.25 | The roof's underside carried back to the far wall over the east half of the room, made in place: its front edge follows the roof (346 at the east wall, climbing west to 358 at x -205, 370 at -228, level to -262), wet earth and roots painted along it, the root holes the stalactites hang from | 1 | A |
| `jardin_island_back` | 41.0 x 45.6 x 9.5 | foot (x -245.5, y 288), z -10.75 .. -1.25 | The slime island's body carried back, made in place: the island is a spur of the mountain out of the far wall. Its belly level at 288 for 6 m back over 4.2 (to z -6.5, the creeper hangs from there), then rising back to the far wall; over 4.3 its underside at 301.5 meets the pocket's back wall at -6.5; its west face black slime in sheets; its top the terrace's moss carried back to the far wall, darker and duller, the young bells and boulders standing on it | 1 | A |
| `jardin_pocket_back_wall` | 28.8 x 46.23 x 5.25 | foot (x -229.6, y 271.77), z -6.5 .. -1.25 | 4.3 and 4.4: rounded damp rock closing the pocket about 6 m back, from the ramp (its foot follows the ramp) up to the island's underside (301.5) west of x -229.5 and to 318 east of it; its top the island's belly carried forward to -1.25, its east end turning forward into the pocket's east wall. Painted on its face: the spore stain, pale GOLD (not orange), a stripe exactly as wide as the column (x -240.3 .. -235.7) from the ramp up to 299.3, spreading where it meets the roof (x -242.8 .. -233.2); slime running down its east part; boulders where it meets the ramp are separate | 1 | A |
| `jardin_cove` | 8.7 x 27.1 x 4.5 | foot (x -225.15, y 306.5), z -6.0 .. -1.5 | 4.5: the island's east face curving round east behind the snails and joining the back wall, made in place: slick black slime all the way up in running sheets, its top the same mossy lip (4 m of it) hanging over; one hollow in it at (-223.5, 321.5) for the eggs, with its shadow painted | 1 | A |
| `jardin_slot_back` | 6.8 x 23.0 x 0.8 | foot (x -239.4, y 344.5), z -3.4 .. -2.6 | 4.7: rounded wet rock joining the stalactite to the spur 3 m behind you (its foot slants with the giant's shoulder, 344.5 at the west, 346.6 at the east), so no black gap shows behind the caps. Spread flat on it, painted: the white mycelium web, its thick cords running cap to cap in the zigzag (-235.9, 345.6) -> (-241.9, 347.6) -> (-237.1, 351.6) -> (-241.9, 355.1) -> (-237.1, 358.6) -> (-242.8, 361.0), thinner strands between, three knots green at (-239.5, 349.6), (-239.5, 353.4), (-239.5, 356.9) (lit) | 1 | A |
| `jardin_brow` | 21.2 x 15.8 x 2.15 | foot (x -272.6, y 356.2), z -3.4 .. -1.25 | 4.9: the brow: rounded dark rock hanging under the low roof to about 357 with a ragged lower edge, carrying on up into the dome (x -275 .. -268.9, to 372); the low roof's underside runs forward from it to -1.25. In its face seven round hollows 1.9 across (one behind each puffball: (-267.9, 359.5), (-278.8, 359.5), (-276.4, 361.5), (-270.8, 369.6), (-271.6, 363.2), (-281.6, 361.8), (-264.6, 364.3)), each a real shallow bowl with its shadow painted and a puffball's short pale neck coming out of its middle toward you. The dimmest place in the garden (dim, not black): judge it in its own light | 1 | A |
| `jardin_far_ledge` | 42.0 x 3.6 x 2.0 | foot (x -267, y 350.5), z -10.0 .. -8.0 | 4.8 and 4.9, made in place: one long shelf of mossy rock on the far wall, its east part (x -266 .. -246) at 350.5 .. 352, stepping up 2 m to the west part (x -288 .. -262) at 353 .. 354.1; the wall dropping away under it. Young bell stands stand on it, seen from above | 1 | A |
| `jardin_door_back_wall` | 14.1 x 17.0 x 4.75 | foot (x -286.95, y 364), z -6.0 .. -1.25 | 4.10 and 4.9's way out: rounded mossy rock behind the garden's last door (a cave mouth, nothing cut), the mouth's floor carried back from the sill, the high roof's underside (378) forward to -1.25; green glow on it | 1 | A |
| `jardin_well_back` | 12.0 x 100.0 x 5.75 | foot (x -300, y 290), z -7.0 .. -1.25 | The well beside the garden (290 .. 390; `gruta_well_back` is below it): the back half of the round shaft curving from rim to rim, 7 m back at the middle, slick black rock with thin pale runs, no ledges; lit green on its east side and torch gold on its west (colour) so it shows (note 46). (st.json draws the well today with cards: the dress file's item 7b) | 1 | A |
| `jardin_floor_hall` | 35.94 x 3.0 x 2.4 | skin | 4.1's moss floor (SHELL edge 0): thick green moss on top that catches every fall in the west hall, dark earth with roots below | 1 | A |
| `jardin_ramp` | 41.66 x 30.94 x 2.4 | skin | The slime ramp (edge 1 and its filler), made in place: black glossy slime running down the 35 degree face in broad sheets over its earth bed; the bed painted below | 1 | A |
| `jardin_pocket_wall` | 3.0 x 28.55 x 2.4 | skin | 4.4's far wall (edge 2 and its filler): wet earth and rock; on its face round the wall cap's elbow a flat white mycelium web 1.3 x 6 m (x -215.2 .. -213.9, y 295.4 .. 302.2), the pale patch that shows from across the pit where the wall cap is | 1 | A |
| `jardin_floor_garden` | 25.24 x 3.0 x 2.4 | skin | The east garden's floor (edge 3): moss over earth; drawn flat on its top, the hut's round rug of woven mycelium (x -206.8 .. -204.2) and five flat pebbles set in the moss (x -213.0, -211.8, -210.6, -209.4, -208.2, each 0.6) | 1 | A |
| `jardin_east_wall` | 3.0 x 31.02 x 2.4 | skin | The room's east wall (edge 4 and its filler): damp earth and root-bound rock, wet | 1 | A |
| `jardin_roof_east`, `jardin_roof_bridge`, `jardin_roof_ojos`, `jardin_roof_west` | 41.02 x 26.68; 35.41 x 3.0; 17.94 x 13.04; 14.12 x 3.0 (x 2.4) | skin | The roof's slabs (SHELL_SKINS 5-6, 7, 8-14, 15), each made in place to its run: wet earth and rock, roots in it. `_ojos` is 4.9's low dark ceiling and its dome, with a root's line drawn on it running back from each of the four knots; `_bridge` carries the root holes of the four short stalactites | 1 each | A |
| `jardin_island` | 41.0 x 45.0 x 2.4 | skin | The slime island (a4.py lines 134-135), its outline the solid's: black glossy slime in running sheets. Drawn on: four seep cracks in its belly rising 2.4 m from each vine (x -263.3, -258.3, -253.3, -248.3), a line of moss in each and slime running from it; the gold fur of settled spores over the column (x -241 .. -235, the last 1.2 m under 301.5); on the snail wall, a stripe of fresh glossier slime along each snail's crawl (4 m each, starting 1.2, 5.7, 10.2, 14.7, 19.2 m up the wall) and above the first four a small flat patch of glow moss 0.4 across (flat: nothing sticks out) | 1 | A |
| `jardin_terrace` | 41.4 x 0.9 x 2.4 | skin | The terrace on the island (line 136): thick moss on top; at its east end the mossy lip hanging over the snail wall's top edge (x -226 .. -224.6, down to 332.7), the dry edge you pull up onto | 1 | A |
| `jardin_stalactite_mass` | 6.0 x 20.0 x 2.4 | skin | 4.7's east mass (line 284): a broad stalactite of rock black with slime, glossy sheets with pale runs and slow drips, a wet ring round each wall cap's foot, a crack drawn along its foot (y 350.5) where the three root ends come out | 1 | A |
| `jardin_spur` | 6.2 x 16.5 x 2.4 | skin | 4.7's west mass and L7 on it (lines 285-286): a spur of rock out of the back wall, the same black slime on its faces, its top a mossy ledge (L7, 360.4 .. 361) | 1 | A |
| `jardin_giant_cap` | 20.22 x 10.7 x 2.4 | skin | 4.6 (note 42): the giant's cap, a real mushroom made to today's outline (the cap solid, the brim, the six gills, the strand and the knob all wear it). Rounded; the same kind as the caps that throw but old: under its slime the orange gone to dark rust, nearly black where the slime is thick, a wet green-yellow sheen, faint ghosts of spots, drips from the rim; nothing about it says bounce. Only the raised dry CREAM things hold: the six gills hanging under the east half (the front ends of its gill plates, 1.4 apart, the last cream only at its foot), the brim (the east rim rolled up dry, x -224.1 .. -222.5) and the knob (a dried cream knob as big as two fists on the end of the veil's wet dark shred) | 1 | A |
| `jardin_giant_cap_back` | 19.0 x 8.0 x 5.55 | foot (x -232, y 338.2), z -6.8 .. -1.25 | 4.6: the cap carried back (oval, 19 across, 8 front to back): its dome falling away behind the crown, the same rust and slime; its underside the gill plates running 5 m back to the stalk, cream and dry under the east half (a pleated ceiling lit from below), slimed black and stuck together in sheets under the west half | 1 | A |
| `jardin_giant_stalk` | 5.2 x 7.4 x 3.3 | foot (x -232, y 333.6), z -4.57 .. -1.27 | 4.6: the giant's stalk, 5 m thick at the foot, 3 at the top, wet and dark green with runs of slime (nobody reaches for it); its skirt 4 m up, a torn frill (the rest of the veil). The terrace stays open in front of it | 1 | A |
| `jardin_frog_hut` | 3.2 x 2.8 x 1.5 | foot (x -205.5, y 318), z -2.75 .. -1.25 | 4.0 (note 41): the back half of a fat hollow stalk, 3 m wide and 2.6 tall inside, cream, cut away at the front like a doll's house: a round window in it (centre x -205.05, y 319.75, 0.76 across), a round door of bark standing open against it at the west end. The only made thing in the garden | 1 | A |
| `jardin_hut_roof` | 4.8 x 1.8 x 2.4 | skin | 4.0: the hut's roof, a NEW solid (FOR THE AREA FILE 6a): the old stalk's own cap under a quilt of moss, a low dome from its eaves (320.1) to its top (321.9), nearly flat across the middle, eaves hanging 0.9 past each end of the room, hollow underneath (2.6 m headroom). ALL green moss, shaggy at the eaves, nothing orange | 1 | A |
| `jardin_hut_roof_back` | 4.8 x 2.7 x 2.0 | foot (x -205.5, y 320.1), z -3.27 .. -1.27 | 4.0: the roof's back half carrying on 2 m back over the hut's back wall, the same moss; a crooked chimney of hollow root out of it (x -204.5 .. -203.95, to 322.75) | 1 | A |
| `jardin_mossy_boulder` | 2.0 x 1.5 x 1.8 | foot | A rounded mossy boulder, moss over its top, never cut. Placed at 0.75 to 1.5 along the far wall's foot (4.1, 4.0), the terrace's back (4.6), where the pocket wall meets the ramp (4.4), and under two sleeping snails | 24 | A |
| `jardin_bridge_anchor` | 2.3 x 1.7 x 1.5 | foot (x -247.75, y 361), z -2.8 .. -1.3 | 4.7 and 4.8: a mossy boulder at the back of L7, the bridge's two white mycelium cords wound round it and running forward to the play space; a spore lantern stands on it (the kit's) | 1 | A |
| `jardin_moss_stalactite` | 1.3 x 2.4 x 1.3 | top | A short thick stalactite of rock furred with moss. Placed at 0.83 to 1.17: four along the roof over the bridge (the curtain is draped from them), two under the spur (4.7), one at the way out (4.9), two over the east garden | 9 | A |
| `jardin_outcrop` | 0.9 x 0.45 x 0.4 | foot, its back on the wall | A small mossy knob of rock standing out of a wall toward the camera, a flat top for a plant (BRIEF "little outcrops"): the pocket's back wall, the cove, the brow, the garden's last wall | 6 | A |

## 2. Mushrooms, plants, roots, pods and small dressing (maker B)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `jardin_bell_mushroom` | 2.2 x 10.0 x 2.2 | foot | The scenery kind (Parker, 11-13): a tall thin pale stalk and a small pale blue-green cap like a bell (2.2 across), no skirt to speak of, never orange, mid values. Placed in stands of three to five at 0.6 to 1.4 (6 to 14 m), 6 to 10 m back | 32 | B |
| `jardin_bell_young` | 1.3 x 4.0 x 1.3 | foot | A young bell mushroom: the same, shorter and with a bigger cap for its height (1.3). Placed at 0.4 to 1.25 (1.6 to 5 m): the terrace (4.6) and the far ledge (4.8, 4.9) | 18 | B |
| `jardin_stalk_stub`, `jardin_stalk_4`, `jardin_stalk_10`, `jardin_stalk_15` | 1.6 x 1.0 x 2.0; 1.8 x 4.5 x 2.0; 2.0 x 10.0 x 2.0; 2.0 x 15.4 x 2.0 | foot (at the back of its box) | The stalk behind a cap or a saucer in the play space: cream, a skirt-ring part way up (about two thirds), its top spreading into a ring of gills under the cap. Made LEANING: rooted at the back of its box, its top 0.6 east of its foot and 1.7 nearer the camera, so the cap hangs over the path and the floor under it stays clear; wet and matte, never as pale as a hold. stub at 0.75 (cap A); `_4` at 0.91, 0.97 (cap B, L2); `_10` at 0.76, 0.98, 1.14 (cap C, 4.4's cap 1, L1: the thickest); `_15` at 1.0 (L3) | 1, 2, 3, 1 | B |
| `jardin_saucer_6`, `jardin_saucer_5`, `jardin_saucer_4` | 6.0 x 0.6; 5.0 x 0.6; 4.0 x 0.6 (x 2.4) | skin | The rest shelves L1, L3, L2 (KIT_MORE): an old cap turned up like a saucer, cream and dry, its gills on top as fine lines running out from its middle, no orange left; the rim rolled up. `_4` has the last half metre of its east lip gold with spores (the step into the lift) | 1 each | B |
| `jardin_moss_mound` | 3.6 x 1.4 x 2.4 | skin | 4.1: the soft old cap under the frozen climber, gone to a low mound of green moss, a little grey-brown rot at its edges, no orange, no spots; three pale bell sprouts come up beside him (FOR THE AREA FILE 6b) | 1 | B |
| `jardin_root_stump` | 4.2 x 3.2 x 2.4 | skin | 4.1: the knee and the stump you step off (lines 112-113): the broken near end of the great root, barrel-thick, bark and a ragged broken top | 1 | B |
| `jardin_great_root_lying` | 21.4 x 1.8 x 1.6 | foot (x -274.7, y 264), z -3.0 .. -1.4 | 4.1: the great root lying along the floor 2 m behind the path, barrel-thick, half under moss, humping up and down (its top 265 .. 265.8); the stalks root on it; glow moss on it | 1 | B |
| `jardin_leaf_collar` | 1.8 x 1.0 x 1.0 | top | 4.2: where a crack opens in the island's belly behind a vine, a clump of creeper leaves 1.8 wide with an arm-thick root running back along the crack: each vine is seen to grow out of one | 4 | B |
| `jardin_creeper_mass` | 20.0 x 2.4 x 2.0 | top (x -256, y 288), z -6.0 .. -4.0 | 4.2: the rest of the creeper, one thick dim mass of leaves and strands hanging from the belly's far part, a ragged lower edge (285.6 .. 286.9); solid enough that nobody takes it for a fifth vine | 1 | B |
| `jardin_snail_asleep` | 2.4 x 1.9 x 1.2 | foot | A giant snail asleep, drawn into its shell (1.8 across), the foot tucked, a dull shell (not a hold's pale), side-on. Placed at 0.78 to 1.0: on a boulder at 4.1's door, on the ramp (4.2, laid along its 35 degrees), two on the cove wall (4.5), the frog's snail (4.0), on a terrace boulder (4.6) | 6 | B |
| `jardin_pod_bed` | 4.6 x 4.3 x 1.3 | foot (x -238, y 274.36), z -2.6 .. -1.3 | 4.3 (note 38): five barrel-fat spore pods in a row (1.1 each) in a hollow of the ramp, made in place on its 35 degrees under the whole width of the column, pale green ribs, a warm gold glow in their mouths (colour); they puff in turn | 1 | B |
| `jardin_pod_nest` | 2.6 x 2.0 x 0.9 | foot (x -256.05, y 356.7), z -2.25 .. -1.35 | 4.8: in a pouch of the curtain under the bridge's middle, two fat pods (1.2; the east one pointing east, the west one up and west) and three small ones: where the gusts come from | 1 | B |
| `jardin_pod_lamp` | 0.5 x 0.6 x 0.45 | the middle of its back on its stalk | A spore lantern pod growing out of the side of a stalk or root on a short neck (the kit's `spore_lantern` grown sideways): pale green ribs, a cream collar and tip (lit). On the stalks of caps C, L1, L3, 4.4's cap 1, the giant; the root arch; the mother root | 7 | B |
| `jardin_root_knot_roof` | 2.3 x 2.3 x 1.0 | top | A knot of root as big as a cart wheel in a roof, the hanging roots grown out of it: 4.9's dome (at 1.0) and, in the gold fur over the column, 4.3's (at 0.52, its fur gold) | 2 | B |
| `jardin_root_arch` | 6.15 x 5.0 x 1.2 | foot (x -218.28, y 308.35), z -2.46 .. -1.26 | 4.4: the root from the frog's garden, body-thick where it leaves the east wall under the garden's lip (-215.2, 313), arching 6 m out over the pit a little behind you, its tip turning forward toward the knot (the knot is a skin) | 1 | B |
| `jardin_root_knot` | 0.8 x 0.3 x 2.4 | skin | 4.4: the root's tip, a fist of wood with the vine grown out of it (line 187) | 1 | B |
| `jardin_bent_stalk` | 1.3 x 1.3 x 0.7 | wall edge | A short thick cream stalk out of a wall below a sideways cap, bending up to it, its foot in the web. 4.7's four at 1.0; 4.4's wall cap's at 1.7 (flipped) | 5 | B |
| `jardin_wall_cap_elbow` | 1.0 x 3.2 x 2.4 | skin | 4.4: the wall cap's bracket (line 192) as the bent stalk's elbow coming out of the wet wall | 1 | B |
| `jardin_shelf_fungus` | 1.8 x 0.45 x 1.2 | wall edge | A shelf fungus out of a wall: CREAM and tan (never the kit's tangerine), growth bands on top, a rounded growing edge, gills under. Placed at 0.55 to 1.06 in steps: under L4 (4.4, 4.5), up the east wall (4.0), up the hall's west wall | 9 | B |
| `jardin_shelf_steps` | 2.4 x 2.8 x 1.2 | the middle of its back's foot, on the wall | 4.10: three shelf fungi in steps growing out of a back wall toward the camera (1.4, 1.6, 1.2 wide), cream and tan | 1 | B |
| `jardin_snail_eggs` | 1.1 x 0.8 x 0.7 | foot | 4.5: a clutch of five snail eggs the size of footballs in the cove's hollow, glowing faintly green (colour; lit) | 1 | B |
| `jardin_root_knee` | 2.0 x 2.5 x 1.3 | foot (x -213.95, y 318), z -2.55 .. -1.25 | 4.5 and 4.0: the knee of root on the garden's lip the root arm grows up from, the root running on back into the moss | 1 | B |
| `jardin_root_arm` | 4.45 x 3.8 x 2.4 | skin | 4.0 (KIT_MORE): the root arm's post and arm (lines 229-230): an upright root that bends flat at its top out over the gap, tan and dry | 1 | B |
| `jardin_sprout_row` | 3.2 x 0.45 x 0.6 | foot | 4.0: six knee-high bell sprouts in a straight row on a strip of turned moss, pale blue-green: the only tidy thing in the garden | 1 | B |
| `jardin_toadstool_stool` | 0.5 x 0.5 x 0.4 | foot | 4.0: the frog's stool, a squat cream toadstool (not orange) | 1 | B |
| `jardin_jar_shelf` | 0.8 x 0.4 x 0.3 | the middle of its foot line on the wall | 4.0: a little shelf of bark on the hut's back wall with three jars | 1 | B |
| `jardin_hook_lantern` | 0.45 x 0.7 x 0.4 | top (the hook) | 4.0: a spore pod hanging from a hook of root at the west end of the hut's back wall, glowing warm (colour; the one warm light on the floor) | 1 | B |
| `jardin_giant_crown` | 4.0 x 0.3 x 2.4 | skin | 4.6: the giant's crown (line 247), where the slime has run off and the skin has dried and cracked into pale cream scales, the same cream as the gills and the brim (FOR THE AREA FILE 6c) | 1 | B |
| `jardin_shoulder_mushroom` | 0.47 x 0.54 x 2.4 | skin | 4.6 (note 44): a small cream mushroom, dry, standing on the giant's slick shoulder (the two warts that stay) | 2 | B |
| `jardin_curtain` | 14.0 x 13.5 x 1.75 | foot (x -255.5, y 356.5), z -3.0 .. -1.25 | 4.8: a net of mycelium with holes a hand wide hanging from the four stalactites to the bridge, leaning back (3 m behind you at the top, touching the bridge's line at the bottom, its lowest point 356.5 under the middle); dim grey-green, plainly a sheet, not a line | 1 | B |
| `jardin_root_loop` | 0.9 x 4.0 x 1.0 | foot (x -263.45, y 361), z -2.3 .. -1.3 | 4.8: the leg-thick loop of root down out of the low roof whose bottom is L8 (not a shelf on a stalk) | 1 | B |
| `jardin_root_down_face` | 0.8 x 17.0 x 0.5 | top (x -229.6, y 367.5) | 4.7: a leg-thick root down the stalactite's east face from the roof, going in under its foot | 1 | B |
| `jardin_root_flat` | 0.7 x 8.5 x 0.4 | top | 4.9: a thick root running down the brow's face between the sockets, flat on the rock | 1 | B |
| `jardin_root_hang` | 0.8 x 14.0 x 0.8 | top | 4.9: a thick root hanging down the far wall under the high roof, tan, hairy, mossy, too thick to take | 1 | B |
| `jardin_root_band` | 12.0 x 2.7 x 2.0 | foot (x -300, y 362), z -7.0 .. -5.0 | 4.10: a band of thick roots made in place along a crack round the back of the well, from the garden's rim to the temple's doorstep, three small pale bell mushrooms growing on it: how the garden got across | 1 | B |
| `jardin_great_cap_stalk` | 2.9 x 5.2 x 2.2 | foot (x -295.45, y 359.2), z -3.45 .. -1.25 | 4.10 (note 46): the great cap's stalk, short and very thick (1.8), out of a crack in the well's wall 4 m below the rim, leaning out and forward to hold the cap over the drop; its skirt, and gills fanning out under the cap's west lip | 1 | B |
| `jardin_mother_root` | 1.2 x 14.0 x 1.1 | top (x -289.65, y 378) | 4.10: the diving board's mother root, barrel-thick, down from the roof at the back of the cave mouth and spreading into the sill | 1 | B |
| `jardin_diving_board` | 10.8 x 7.3 x 2.4 | skin | 4.10: the sill, the post and the diving board (lines 391-393) as one branch of the mother root turned toward the well: root, tan and dry | 1 | B |
| `jardin_outcrop_plant` | 0.6 x 0.5 x 0.04 | foot | The garden's wall plant (BRIEF "little outcrops"): ONE flat painted card, a tuft of three tiny bell sprouts and one fern frond, blue-green and cream, flush colours, only its outline inked | 6 | B |
| `jardin_fern_low` | 4.0 x 1.7 x 0.05 | foot | The garden's foreground (note 40): ONE flat painted card, a low clump of dark fern fronds, flush colours; each stands at a bottom corner below a floor's top | 4 | B |
| `jardin_bell_card_dark` | 0.8 x 1.6 x 0.05 | foot | Foreground: one small bell mushroom as a dark flat painted card, beside a fern (4.1, 4.6) | 2 | B |

## 3. Timber, iron, machines (maker C)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `jardin_clay_stove` | 0.5 x 2.6 x 0.5 | foot | 4.0: the frog's small clay stove (0.85 tall, fire as colour in its door), its crooked pipe going up through the hut's ceiling (to 320.6) into the chimney | 1 | C |

## 4. Made for a4.py, not placed by the dress file (its FOR THE AREA FILE items 6 and 8)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `jardin_moss_blanket` | 2.0 x 0.5 x 0.8 | with the statue (a4.py line 125) | 4.1: green moss grown on over the frozen climber's legs and one arm like a blanket (his body is the climber's own model: nothing bespoke for it until the new climber lands; the blanket is laid over the statue's pose) | 1 (by a4.py) | B |
| `jardin_vine_knot` | 0.5 x 0.5 x 0.3 | its top (the rope's anchor) | The top of every vine: a knot with two leaves on it where it comes out of its crack or root, so no vine ends at a bare line on the rock | every vine-kind rope, 18 (by a4.py) | B |
| `jardin_vine_end_gold` | 0.6 x 1.0 x 0.2 | its top | 4.3: the last metre of each of the three lift vines furred pale gold with spores | 3 (by a4.py) | B |
| `jardin_bridge_tread` | 0.8 x 0.12 x 0.6 | the plank's centre | 4.8: a tread of the grown bridge: a small flat cream shelf fungus along the two cords, dry | 15 (by a4.py) | B |
| `jardin_mycelium_cord` | 0.5 x 0.06 x 0.06 | its start | 4.8: one segment of the bridge's two cords, white stringy mycelium as thick as a wrist | 1 rope (by a4.py) | B |

**Re-made, not new stems** (FOR THE AREA FILE item 8): the fitted kit's `fit_shroom_cap_a`, `_b`
and `_thick` (note 37: orange with PALE SPOTS, no checks, the throwing face flat, the roundness
in a rim rolling down all round, cream gills under; the wall caps want the sideways cap, its rim
rolling further on the low side); `shroom_great_cap` (note 46: the brightest spotted cap in the
garden, a fat rolled rim drooping over the well, cream gills, 6 m front to back, the three faces'
angles exact); `puffball` (one small dark pore on its face like a pupil).
