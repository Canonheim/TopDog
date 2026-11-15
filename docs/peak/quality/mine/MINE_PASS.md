# La Mina Vieja to a 9: the mine's quality pass

The plan for biome 1, the test and example biome of `docs/peak/QUALITY_TO_9_PLAN.md` (the standard in
its part 3, the method in part 4, the mine's bullet in phase 2). **A plan only: nothing in it is
started, and nothing starts until Parker says** (QUALITY_TO_9_PLAN part 7, items 6 and 8).

Read from: the two ratings (`docs/peak/rating/LOOKS_RATING.html`: the mine 4.5, its challenges 3.5 to
6; `docs/peak/rating/THINGS_RATING.html`: 130 mine things, mean 3.8, best `crate_ore` 8, worst
`mine_throat_west` 1.5); the playtest notes 1 to 15, 40, 51, 71, 103, 104, 106 to 111, 138 and 146
(`docs/peak/playtest/PLAYTEST_NOTES.html`); note 146's design draft
(`docs/peak/playtest/design/rearrange_146/make_rearrange.py`, still being drawn); the course and dress
(`tools/peak/areas/a1.py`, `a1_dress.py`), the model list (`docs/peak/models/a1_models.md`), the sheet
and pages (`docs/peak/playtest/design/data/a1_biome.py`, `a1_areas.py`); the frames
(`docs/peak/rating/frames/c1_*`, `docs/peak/frames/a1_mine_*`); the standard pieces in
`C:\Users\Parke\OneDrive\Desktop\Clod Things\Top Dog Kit\previews\check\` and `frog_stop_review.png`.

**Coordinates.** Every position here is TODAY's (the course as built). Note 146 moves the mine; the
draft's numbers today are: every point (x, y) goes to (x − 59, y − 17), and a further 6 m west where
x < −246 (the west wall, the frog's cave, the throat's west side: the widened falls area), see `mv()`
in `make_rearrange.py`. The briefs in part E give both. If the draft's numbers change, only the
offsets change: no model in this plan is shaped by the offset.

**Words used below.** *Skin*: a model that is the look of a course solid (`skin=` in a1.py); it fills
the solid, z −1.2 .. 1.2. *Set*: the painted set, the near back wall and its depth (2 to 10 m back).
*Backdrop*: the far painted scene (12 m and more back). *Light pass*: a piece already at 8; it goes to
the reviewer as it is first, and only to a maker if the reviewer marks it under 8.5 in the mine's light.

---

## The idea in one paragraph

The mine already has good bones: its timber language, a handful of 8s (the ore crate, the tipped
cart, the counterweight, the bucket, the minecart, the signs), the wheel and the story. What pulls it
to 4.5 is three things, and the pass is aimed at them in this order. (1) **Every frame sits on the
same banded purple-brown slab** with nothing painted behind: the walls and masses are 1.5 to 2.5
cards. So: one painted backdrop for the cavern and a real painted set for every stretch, walls that
recede with old workings, galleries and lantern-lit depth. (2) **The middle (1.3 to 1.8) is empty and
what is there floats** (the "bowls" are the wall outcrops, the "floating squares" the painted sockets,
the "floating bench" the fallen walk's bearers, the "post in mid-air" a foreground length). So: a hero
piece per challenge and working mine furniture on every ledge, and every small thing put on something
or folded into the thing it belongs to. (3) **What you touch is a collision box with a pattern**: the
timber you climb wears the mountain's shared fitted modules and thin drawn decals. So: the mine's held
timber gets its own skins, each one connected thing from the play space back into the set (the beam
end and its post, the plank and its bearer in its socket, the beam piece and its hanger). Fewer
things, better made: 58 stems leave the mine, folded into the thing they belong to or painted into a
set, and every model left goes through one maker session and the reviewer to 8.5.

---

## A. The mine as a diorama, place by place

For each place: the painted backdrop (far), the painted set (near), the hero, the real things in
frame (at least three), the climb as real objects, and how it connects through the depths. Stems in
`code` are part B's rows. New stems are `mina_`.

**One backdrop for the cavern.** The far painted scene is only seen where the cavern is open behind
the play plane: the open middle from El Diente west to the falls, from the Sump to the roof (1.6's
left edge, 1.7, 1.8, 1.9, the Sump, the frog cave's door, the view west out of the gallery's mouth).
Everywhere else the near wall is close behind the climb (the walk runs along the cavern's wall, the
gallery and shafts are bored in rock), so there the **set** carries the depth: its old workings,
galleries and lantern pools are what you see. So the mine has one backdrop
(`mina_backdrop_cavern`, 15 m back) and eleven sets.

### 1.1 La Galería (x −176 .. −148, y −12.6 .. −7.5)

- **Backdrop:** none inside the gallery. At its east end the cart tunnel (biome 0's 0.3 pass); at its
  west mouth the cavern (`mina_backdrop_cavern`'s lower galleries and the falls' far glow, left).
- **Set:** `mine_lining_gallery`: two storeys of plank lining in bays between real sets; over the pit
  the lining has burst outward and black mud comes through (painted, with a few real split plank
  ends); high by the door the ore chute's hole; low near the pit a mud splash line.
- **Hero:** the burst: `mine_mud_tongue` slumping out of the wall into the pit with the tipped cart
  half sunk in it (`ore_cart_wreck`) and the rails bent down over both brinks (`mine_rail_bent_end`).
- **Things:** the ore chute coming out of its hole on two brackets to a hopper over the rails
  (`mine_ore_chute`); the first skull-pug at the brink (`sign_pug_skull`); a lantern over each brink
  on a strap from the roof timber (`lantern_hang`, `mine_lantern_bracket`); a wheelbarrow left at the
  brink (`mina_wheelbarrow`); mushrooms on the posts (`mine_mushrooms_pale`); the rails at the door
  (`rail_straight`); the door's timber set (`mine_frame`).
- **The climb:** the five hung beams are the caps of the broken sets, seen end-on, each hanging from
  its upper post by an iron strap (`mina_gallery_beam_end`: today's 0.36 m pegs, note 104); the four
  sunk posts stand in the mud with split heads and the tongue the beam sat on, black to a tide line
  (`mina_gallery_post_sunk`: today's stakes, note 104); the floors either side (fitted rock caps).
- **Through the depths:** each broken set is ONE thing: beam end in the play plane, upper post behind
  at z −1.45, roof timber over it, lining behind that; the sunk posts go down into the mud tongue; the
  foreground rubble lip (`mine_rubble_lip`) stands only below the floor line.
- **Notes:** 104 (invisible geometry at the pegs and stakes), 107 (the tally marks, next place).

### 1.1b The frozen climber's camp (x −176 .. −165.5)

- **Backdrop:** through the mouth (x −176), the cavern: `mina_backdrop_cavern`.
- **Set:** `mine_lining_gallery` (its west half), with the waiting room and the winch's cut as real
  openings, and **the tally marks scratched into the planks beside him** (note 107: groups of four
  strokes and a slash, pale raw-wood lines in the board, no card).
- **Hero:** the frozen climber (the game's statue, kept) sitting against the post by the miners'
  waiting room (`mine_waiting_room`: the bench cut in the wall, a peg rail with two miners' coats and a
  helmet, a faded pug-luchador safety poster), his bedroll on the bench.
- **Things:** a small cold cook stove in the waiting room with a coffee pot, its pipe up through the
  roof timber (`mina_cook_stove`); the miners' tag board at the ladder's foot, rows of hooks and a few
  brass tags left (`mina_tag_board`); a tool rack (`mina_tool_rack`); his cold lantern, pickaxe, rope
  coil and bedroll (`cold_lantern`, `pickaxe`, `rope_coil`, `camp_bedroll`); the hand winch in its cut
  at the head of the incline (`mine_hand_winch`); the town's bunting, torn, fixed at both ends
  (`mine_bunting_torn`).
- **The climb:** the gallery floor (fitted rock cap); the ladder's foot.
- **Through the depths:** the winch's drum lines up with the incline's back rail running down to the
  Sump (`mine_rail_single`); the tag board, the stove and his marks tell one story at three depths.

### 1.2 Escalera Rota (the ladder shaft, x −172 .. −168, y −7.6 .. 5.8)

- **Backdrop:** none (a lined shaft); at its head the cavern opens west.
- **Set:** `mine_lining_escalera`: lining on frames every 1.3 m, black-wet planks green at the seams,
  two bays gone to rock, and behind each of the three gaps the rotted landing that fell and tore the
  ladder's joint out, its bent rung still in it (all one set).
- **Hero:** the iron ladder (`mina_iron_ladder`): rusted rails and bracket rungs, some sagging, three
  gaps with the rails torn and curled.
- **Things:** a standing lantern on the top landing (`lantern_mine`); the head frame (timber family)
  with a pickaxe leaning on its post; the way-on sign west (`sign_pug_arrow_west`, kept); a bucket and
  a rope coil on the head ledge.
- **The climb:** the rungs (the ladder's own rungs over the iron rung solids); the head ledge.
- **Through the depths:** the foreground front posts of the shaft's sets in broken lengths, each
  standing on a sill or the rubble (`mine_post_broken*`), in front of rock only.
- **The east set beyond the head:** `mina_set_stopes_east`: the cavern's east end above the ladder
  head and the slope, old stopes with their timber and a high gallery (in place of a1.py's flat card
  at z −4 and the orange `station_scaffold`).

### 1.3 Los Tablones (the plank walk, x −192.8 .. −176, y 6)

- **Backdrop:** none behind the walk (the wall is 1.7 m back); at the frame's left edge, past the
  pillar, the cavern.
- **Set:** `mine_cavern_wall_mid`: the hand-cut wall, receding in planes to 5 m back where old workings
  open: dry above the planks, dark with wet below; the sockets of the lower walk that fell painted as
  a row along its old line, with its one surviving length still in two of them (part of the wall, not
  a floating bench); one old stope framed by a real set; outcrop ledges built into the wall carrying
  ferns; painted far lantern glows.
- **Hero:** the side drift the walk was built to reach (`mina_drift_portal`): a timbered portal in the
  wall, its door boarded with an X and a skull-pug plate, a gangway from the walk, a small cart left on
  a stub of rail, crates and a sack, a lantern on its cap.
- **Things:** two wall lanterns (`lantern_hang`, `mine_wall_bracket`); the town's papel picado nailed
  along the wall (`papel_tatters`); mushrooms on the bearers; crates at the portal (`crate_ore`).
- **The climb:** the five sound lengths (`mina_walk_length`: nailed planks on their bearer, the bearer
  let into a socket in the wall, a strut under it) and the four loose grey boards resting on their
  neighbours (`plank`, remade).
- **Through the depths:** every bearer runs from its socket in the set (z −2.9) forward under the walk
  (play): the walk and the wall are one structure. The portal's gangway meets the walk's back edge.

### 1.4 La Cuerda del Minero (the gap, x −197.9 .. −192.8, y 6 .. 14)

- **Backdrop:** as 1.3.
- **Set:** `mine_cavern_wall_mid` (west end): three empty sockets and a snapped bearer painted in its
  face; El Diente's shoulder.
- **Hero:** the miners' swing (`mina_hoist_arm`): the lift's arm out over the gap, its twin behind, the
  brace from the pillar, the greased iron rod with its swivel hook, and the rope.
- **Things:** a tool rack on the pillar's shoulder landing (`mina_tool_rack`); a standing lantern on
  the arm's twin (`lantern_mine`); the skull-pug where the walk stops (`sign_pug_skull`).
- **The climb:** the rope (the game's rope, a real twisted rope; note 138's lock); the shoulder landing
  (today a plain rock ledge: it becomes part of El Diente's skin, part C).
- **Through the depths:** the arm's tip is in the play space, its twin and brace go back into the
  pillar: one thing.

### 1.5 El Cubo (the lift, x −202 .. −186, y 6 .. 27)

- **Backdrop:** none behind the lift (the wall); left of the pillar, the cavern.
- **Set:** `mine_cavern_wall_high`: the hand-cut wall with the two old workings along the seams.
- **Hero:** the hoist headframe (`mina_hoist_headframe`): a dark gallows on the station deck, its head
  beam carrying the big sheave (`pulley`, turning with the weight), broad guide boards the
  counterweight and the bucket run in front of, broken ragged at the foot, a cast pug medallion;
  with the `counterweight` and the `ore_bucket`.
- **Things:** on the station deck: three ore crates with a lantern on top (`crate_ore`,
  `lantern_mine`), sacks (`ore_sacks`), the spare bucket on its side (an `ore_bucket` deco, in place of
  `mine_bucket_side`); the arm's lantern; the front post's broken lengths standing on things.
- **The climb:** the seven iron staples up the pillar (`iron_staple`, driven into its east face); the arm
  (`mina_hoist_arm`); the counterweight (mover); the station deck (`mina_station_deck`: planks on
  bearers carried back to the wall, the hatch's trimmer).
- **Through the depths:** the headframe stands on the deck and its back-stay meets the pillar's rock;
  the deck runs back to the wall on its bearers. Note 4 holds: no thin hanging line near the climb.

### 1.6 Vetas de Lodo (El Diente's east face, y 26 .. 40)

- **Backdrop:** at the left edge, past the pillar, the cavern's upper galleries.
- **Set:** `mine_cavern_wall_high`: the two old workings at the seams' heights (32.15 and 37.3,
  rising east at 0.179 a metre), each a real stope 1.5 to 2.5 m back, propped with short timbers,
  painted dark at the back, lit from the side by a wall lantern; the eight faint seams across.
- **Hero:** El Diente's east face (`mine_el_diente`): the black clay washed out between eight pale ore
  seams, each seam running back across the pillar from its rib.
- **Things:** in the lower working the powder store, dynamite crates with a skull-pug stencil and a
  plunger box (`mina_powder_box`); a barrow of ore in the upper one (`mina_wheelbarrow`); a pick and
  hand steels on its floor; the wall lantern; ferns.
- **The climb:** the eight ribs (`mine_rib_short`, `mine_rib`, `mine_rib_wide`), each the broken end of
  a seam; the pillar's top (the track bed).
- **Through the depths:** the seams run from the ribs (play) as bands across the pillar (skin) and are
  the same seams the miners worked in the far wall (set), at the same heights.

### 1.7 El Carrito Loco (the cart room, x −234 .. −200, y 26 .. 50)

- **Backdrop:** `mina_backdrop_cavern`: the cavern behind the great falls, the falls' glow the
  brightest thing in the background, a ladder way going up beside them, the upper works' distant
  headframe and winding wheel high up, mist bands.
- **Set:** `mine_chain_rib`: the rib slanting up from the falls to under the beams, the three ring pins
  in its face, one band of gold-ochre ore under them, an overhang with a painted shadow; behind it the
  wall carried on back in slanted planes; at its foot the bench the incline's bents stand on.
- **Hero:** the incline (`mine_cart_road`: rails on two stringers, its bents standing on the bench and
  coming forward under the rails, the struts, the broken stop at the lip) with the `minecart`.
- **Things:** the second cart tipped against the wall on the siding (`ore_cart_wreck`); two lamp posts
  with lanterns at the back of the track (`mine_lamp_post`); the skull-pug before the cart; the back
  rail on the siding (`mine_rail_single`); the chock (`mine_chock`); ferns on the rib.
- **The climb:** the cart road (honey timber and rail), the chain (the game's chain, real links,
  rusty red), the three rings on their pins (`iron_ring_pin_long`), the stub's deck.
- **Through the depths:** the road and its bents are ONE model from the bench behind to the rails in
  the play space; the ring pins root in the rib.

### 1.8 Las Vigas (under the roof, x −232 .. −214, y 50 .. 55)

- **Backdrop:** the cavern behind the falls (as 1.7, its upper half).
- **Set:** `mine_chain_rib` (upper part) and the roof's underside (`mine_chamber_roof`).
- **Hero:** the broken roof beam: four pieces each hanging on its own post, sagging to different
  heights (`mina_viga_first`, `mina_viga_wet` ×3), with the whole back beam on its four hangers behind
  showing the line it had, its three iron rollers (`mine_beam_roof`).
- **Things:** lanterns on the first and third hangers (`mine_lantern_bracket`, `lantern_hang`);
  stalactites east of the first piece only (`stalactite_a`); the falls themselves in front of you.
- **The climb:** the dry first piece (held underneath, a rust stirrup) and three wet pieces with black
  undersides (painted sheen, matte) and splintered ends.
- **Through the depths:** each piece's iron stirrup reaches back to its hanger post, the post bolts
  into the roof: one thing from the play space to the roof.

### 1.9 La Polea Grande (the wheel, hub at −234.2, 57.4)

- **Backdrop:** the cavern behind the falls; the falls themselves just west.
- **Set:** `mine_upper_works_body`: the upper gallery's timbered back wall with a boarded tunnel.
- **Hero:** the wheel house: the `winding_wheel` and the `water_wheel` on the same axle 1.5 m behind,
  turned by a trough off the falls, on their frame (`mina_wheel_frame`), under the slanted plank roof
  black with spray (`mina_wheel_awning`).
- **Things:** an ore crate on the gallery floor (`crate_ore`); the upper gallery's mouth set
  (`mine_frame_open`) with its side lantern; a tool rack (`mina_tool_rack`); a skull-pug.
- **The climb:** the staging (`mina_staging`, on its two hanging posts and the bearer), the wheel's
  rim, the porch, the gallery floor.
- **Through the depths:** the axle runs from the winding wheel's hub back to the water wheel and the
  frame's bearing; the trough runs from the falls' edge to the water wheel's top.

### 1.10 El Derrumbe (the cave-in shaft, x −222.1 .. −218.5, y 57.4 .. 77)

- **Backdrop:** none (inside the rock); up, the chimney's dark.
- **Set:** `mine_lining_derrumbe`: lining on its twelve set heights, two bays gone to rock, the
  rocks' two pale scars; the ladder way behind with its half landings and short ladders, two snapped
  (all one set).
- **Hero:** the chimney (`mine_chimney_mouth`, one piece across all three depths): its dark throat up
  into the roof, snapped roof timbers and torn planking round its mouth, and a broken board hanging
  across the mouth in the FOREGROUND so the rocks are born out of sight (note 108).
- **Things:** the bent hoist wheel (`mine_hoist_wheel_bent`); the hand winch at the top drift's edge,
  handle in the air (`mine_hand_winch`); a lantern left on a landing; the skull-pug at the foot; at the
  foot the rubble with the crushed hoist bucket and its cable (`mina_derrumbe_foot`); the boarded
  tunnel (`mine_boarded_tunnel`); the powder box's second placement in the drift.
- **The climb:** the eight broken stubs (`mine_stub`, `mine_stub_short`: a cross-beam snapped off,
  its sawn back end in its socket), the rubble slope and fallen cap beam (`mina_derrumbe_foot`), the
  top drift's floor.
- **Through the depths:** each stub is the near end of a beam whose socket shows in the wall; the
  front posts stand either side in front of rock, never in front of the shaft.

### 1.11 La Cortina (the throat, x −248 .. −230, y 72 .. 90)

- **Backdrop:** none behind the staples (the throat's wall); up through the roof slot, the great falls
  coming down from above (note 146: from under the forge, one column).
- **Set:** `mine_cortina_wall`: the throat's back wall, black-wet rock painted (matte, sheen
  painted), drips of one even width, a rust stain painted round each staple's feet, ferns on outcrops
  in the spray; 6 m wider at its west after the move.
- **Hero:** the great falls (code: 3D falling water at its full 6 m, note 111) right beside the staple
  ladder in the spray.
- **Things:** the empty camp in the top drift, nobody there (`camp_bedroll`, `cold_lantern`,
  `pickaxe`); the way-on sign (`sign_pug_arrow`); papel picado across the drift; the last amber lantern
  on the wall; the life ring on its block at the foot of the wet slab (`float_lifesaver`); the rope's
  bracket strapped to the last set; at the top the last timber set with the works' arch (the join).
- **The climb:** 28 staples (`iron_staple`, `iron_staple_bent`, and `mine_staple_bound` with its drip
  board), the rope (code), the balcony, the lip.
- **Through the depths:** each staple's legs run back into the throat wall (today the staple is drawn
  1.6 m behind its hold and meets it only straight ahead: part C, item C7).

### The waterfall cavern and the Sump (1.0, 1.0b; x −248 .. −187, y −33 .. −17)

- **Backdrop:** the foot of `mina_backdrop_cavern`: the falls' plunge and mist, the drowned level's far
  end, cold light on the water.
- **Set:** `mine_cavern_wall_low` behind the landing stage and the incline (hand-cut, black-wet below,
  the lower walk's sockets far overhead); El Diente's foot with the arch tunnel and its drowned sets
  (part of `mine_el_diente`); the west wall (`mine_throat_west`).
- **Hero:** the great falls landing (code: churn and mist) and, behind the drowned staging, the old
  pump that kept this level dry, half sunk (`mina_pump`: a beam pump on an A-frame, a pug-faced iron
  pump barrel, its rod into the water). At the widened foot (note 146), wet boulders and a broken
  staging the falls batter (`mina_falls_foot`).
- **Things:** the drowned sets to their caps (timber family); carts on the bottom (`minecart` ×2,
  `ore_cart_wreck`); a barrel wedged against a cap (`barrel_side`); the boarded tunnel; the flat boat
  sunk at its mooring (`mine_flat_boat`); the lamp post at the landing (`mine_lamp_post`); the way-on
  signs (`sign_pug_arrow_east`, kept); the incline's back rail with the grey cart stopped a third of
  the way up (`mine_rail_single`, `minecart`); the mooring ring (`eye_bolt_plate`).
- **The climb:** the four staging piles (`mina_sump_pile`), the landing stage, the six sleepers of the
  walk of shame (`mina_incline_sleeper`), the frog cave's doorstep.
- **Through the depths:** each held pile's twin stands behind it with the stub of the deck beam that
  joined them (one model); the sets stand under the water to their caps.

### The frog cave (x −253.4 .. −248, y −27.5 .. −24.8)

- **Backdrop:** none (a room).
- **Set:** `mine_frog_cave`: the room cut in the west wall's rock, front cut away, dry and warm-lit,
  made as ONE piece with the rock round it so nothing shares a plane (note 109); the watchman's water
  marks scratched up the door post.
- **Hero:** the frog on its upturned bucket by the stove (`frog_sit` kept, `mine_bucket_upturned`,
  `mine_frog_stove` with the `tea_kettle`).
- **Things:** the shelf of lost boots and masks (`mine_frog_shelf`); the towel on its peg
  (`mine_towel_peg`); the lantern (the only warm light at the bottom); a short papel picado string over
  the shelf.
- **The climb:** the doorstep and the floor (today two unskinned cut solids, note 109: they take the
  throat's skin or the room's floor).
- **Notes:** 71, 109, 110 (the zoom must work in here).

### The lip, and La Esclusa (note 146)

Today La Cortina's top leaves by the dry shaft onto 2.1's lip ledge. After the move the dry shaft
comes up into La Esclusa's lip room under the flume's lip (the draft: `LIP_ROOM`, the mine's roof at
y 73 moved), and the draft numbers its two challenges **1.12 Los Barriles** and **1.13 La Esclusa**.
This pass makes the join's pieces once La Esclusa's page fixes where the shaft comes out (the last
timber set, the works' first arch, the pier post: part B, "the join"). La Esclusa's own things (the
flume, the barrels' tunnel mouth, the lock, its gate wheel, gauge board and keeper frog) are the black
waters' pass in QUALITY_TO_9_PLAN phase 2, unless Parker puts them in the mine (see part D's last
paragraph).

---

## B. The model list

One row per model (one maker session each). Families made by one script at several sizes are one row.
**Layer:** bg far (backdrop), bg (background), play, fg (foreground), cross (crosses depths).
**Skin:** *S* = a skin whose shape depends on the course (wait for part C); *F* = a skin whose shape is
fixed (can start now); *no* = not a skin. **Start:** *now* = can start before the course changes;
otherwise the part C item it waits for. Sizes are metres (w x h x d), approximate where new.

### B1. The painted backdrop

| # | Stem | What it is | Layer | Size | Where | Now | Verdict | Skin | Start |
|---|---|---|---|---|---|---|---|---|---|
| 1 | `mina_backdrop_cavern` | The cavern's far side, one flat painted facade: galleries in tiers, timber and ladders in depth, lantern pools, an ore chute, the distant headframe and wheel, the great falls' glow and mist, the drowned level | bg far | 90 x 150 x 0.5, z −15 | behind the open cavern (moved: x −333 .. −243, y −67 .. 83) | – | NEW | no | now |

### B2. The painted sets

| # | Stem | What it is | Layer | Size | Where | Now | Verdict | Skin | Start |
|---|---|---|---|---|---|---|---|---|---|
| 2 | `mine_lining_gallery` | The gallery's back wall: lining in bays, the burst, the chute's hole, two real openings, the tally marks (note 107) | bg | 24.0 x 5.1 x 0.8 | 1.1, 1.1b | 2.5 | REMAKE | no | now |
| 3 | `mine_waiting_room` | The miners' bench room cut in the gallery wall: bench, peg rail, coats, helmet, poster | bg | 2.15 x 2.1 x 1.2 | 1.1b | 3 | REMAKE | no | now |
| 4 | `mine_lining_escalera` | The ladder shaft's back wall with its three rotted landings and torn rungs | bg | 4.0 x 13.4 x 1.3 | 1.2 | 2 | REMAKE | no | now |
| 5 | `mina_set_stopes_east` | The cavern's east end over the ladder head: old stopes, a high gallery, a ladder way | bg | 24 x 26 x 5 | x −174 .. −150, y 4 .. 30 | – | NEW | no | now |
| 6 | `mine_cavern_wall_low` | The hand-cut wall behind the landing stage and incline | bg | 25.9 x 27 x 4 | 1.0b | 2.5 | REMAKE | no | now |
| 7 | `mine_cavern_wall_mid` | The wall behind the walk: receding workings, the fallen walk's sockets and one length, outcrop ledges, the portal's opening | bg | 30.9 x 24 x 5 | 1.3, 1.4 | 2.5 | REMAKE | no | now |
| 8 | `mine_cavern_wall_high` | The wall behind the lift and the ribs: the two workings as real stopes with their props | bg | 17.9 x 26 x 5 | 1.5, 1.6 | 2.5 | REMAKE | no | now |
| 9 | `mine_chain_rib` | The rib and the wall behind it from the incline's bench to the roof (absorbs its body and the bench) | bg | 24 x 34 x 5 | 1.7, 1.8 | 2 | REMAKE | no | now |
| 10 | `mine_upper_works_body` | The upper gallery's and top drift's back wall, timbered, a boarded tunnel | bg | 15.5 x 35 x 2 | 1.9, 1.10, the drift | 2 | REMAKE | no | now |
| 11 | `mine_lining_derrumbe` | El Derrumbe's back wall with the ladder way (half landings, ladders, snapped ones) | bg | 3.6 x 15.3 x 1.2 | 1.10 | 2 | REMAKE | no | now |
| 12 | `mine_cortina_wall` | The throat's back wall, black-wet rock painted, the staples' rust painted on | bg | 24 x 26 x 0.6 (after the widening) | 1.11 | 2.5 | REMAKE | no | C1, C7c |
| 13 | `mine_lining_dry_shaft` | The dry shaft's lining at the top of La Cortina | bg | 4 x 4 x 0.3 | the lip | 2.5 | REMAKE | no | La Esclusa's page |
| 14 | `mine_frog_cave` | The frog's room cut in its rock, as one piece with the rock round it; the water marks on the door post | bg | 8 x 18 x 2.5 (room 5.4 x 2.7 x 2.35) | the frog cave | 3 | REMAKE | no | C1, C3 |
| 15 | `mine_mud_tongue` | The black mud slumping out of the burst into the pit, a sleeper in it | bg | 10 x 4.5 x 1.7 | 1.1 | 2.5 | REMAKE | no | now |

### B3. The rock (skins)

| # | Stem | What it is | Layer | Size | Where | Now | Verdict | Skin | Start |
|---|---|---|---|---|---|---|---|---|---|
| 16 | `mine_el_diente` | The pillar, with its body behind (z to −3.2) and the arch tunnel and drowned sets at its foot | cross | 11 x 65.5 x 4.4 | 1.4 to 1.7, the Sump | 2 | REMAKE | S | C1 (re-freeze) |
| 17 | `mine_east_mass` | The east mass, the shaft's east wall as plainly rock (note 106) | play | 44 x 58.3 x 2.4 | 1.1, 1.2, 1.5 | 2 | REMAKE | S | C1 |
| 18 | `mine_chamber_roof` | The cavern's roof over Las Vigas, darker underneath | play | 66.5 x 37.7 x 2.4 | 1.6 to 1.8 | 2 | REMAKE | S | C1 |
| 19 | `mine_upper_works_mass` | The rock of the upper works, its gold band and drill holes | play | 23.5 x 35 x 2.4 | 1.9 to 1.11 | 2 | REMAKE | S | C1 |
| 20 | `mine_throat_west` | The west wall from the Sump to the throat's roof, the frog's doorway | play | 14 x 127 x 2.4 (after the widening) | the Sump, the throat | 1.5 | REMAKE | S | C1, C3 |
| 21 | `mine_rib_short`, `mine_rib`, `mine_rib_wide` | Vetas de Lodo's ribs, the seams' broken ends (one family) | play | 0.9 / 1.2 / 1.5 x 0.42 x 2.4 | 1.6 | 2.5 / 2.5 / 3 | REMAKE | F | now |

### B4. The climb as things (the play space)

| # | Stem | What it is | Layer | Size | Where | Now | Verdict | Skin | Start |
|---|---|---|---|---|---|---|---|---|---|
| 22 | `mina_gallery_beam_end` | A broken set's cap end-on, hung on its upper post by a strap (the pegs) | cross | 0.36 x 0.36 front; post 0.35 x 3.2 behind | 1.1 (5) | – | NEW | S | C4 |
| 23 | `mina_gallery_post_sunk` | A sunk post's split head, its tongue, mud to a tide line (the stakes) | play | 0.45 x 4.6 | 1.1 (4) | – | NEW | S | C4 |
| 24 | `mina_iron_ladder` | The rusted iron ladder: rails, bracket rungs, torn and curled ends at the gaps | play | 0.9 x 2.25 / 4.5 a run | 1.2 (4 runs) | – | NEW | F | C6 (a ladder that wears a model) |
| 25 | `mina_walk_length` | A sound length: nailed planks on a bearer let into its wall socket, a strut | cross | 2.0 to 2.6 x 0.22; bearer to z −2.9 | 1.3 (5) | – | NEW | F | now |
| 26 | `plank` | The loose grey board (breakable), and the board the rocks leave by | play | 1.2 x 0.22 x 2.4 | 1.3 (4), 1.10; shared with 7 | 3.5 | REMAKE | F | C6 (breakable look) |
| 27 | `mina_hoist_arm` | The lift's arm, its twin, the brace, the greased rod and swivel hook | cross | 8.9 x 4.7 x 2.4 | 1.4, 1.5 | – | NEW | F | now |
| 28 | `mina_station_deck` | El Cubo's deck, carried back to the wall on its bearers, the hatch's trimmer | cross | 7.9 x 0.3 x 4.1 | 1.5 | – | NEW | F | now |
| 29 | `iron_staple` | A long-legged staple: the U at the hold, its legs back to the wall (El Cubo's 7 rungs: the same staple driven into the pillar's east face, legs short; the same script) | cross | 0.4 x 0.12 x 1.4 | 1.11 (18), 1.5 (7) | 4 | REMAKE | S | C7a, C7c |
| 30 | `iron_staple_bent` | The same, bent | cross | 0.4 x 0.12 x 1.4 | 1.11 (5) | 4.5 | REMAKE | S | C7a, C7c |
| 31 | `mine_staple_bound` | The dry rest: the staple bound in pale cord, with its drip board over it | cross | 0.85 x 0.7 x 1.4 | 1.11 (5) | 5.5 | REMAKE | S | C7a, C7c |
| 32 | `mine_cart_road` | The incline: road, rails, the three bents and struts, the broken stop at the lip | cross | 10.1 x 14.5 x 4.3 | 1.7 | 4 | REMAKE | F | now |
| 33 | `iron_ring_pin_long` | A ring on a pin out of the rib | cross | 0.5 x 0.55 x 1.65 | 1.7 (3); shared with 6, 11 | 6 | REMAKE (start from it) | F | now |
| 34 | `mina_viga_first` | Las Vigas's dry first piece, its rust stirrup up to the hanger | cross | 4.4 x 0.4 + stirrup | 1.8 | – | NEW | F | now |
| 35 | `mina_viga_wet` | A wet piece, black underside painted, splintered ends, its stirrup | cross | 2.0 x 0.4 + stirrup | 1.8 (3) | – | NEW | F | now |
| 36 | `mine_beam_roof` | The whole back beam on its four hangers to the roof, rollers, bolt plates | bg | 18.5 x 4.7 x 0.4 | 1.7, 1.8 | 2 | REMAKE | no | now |
| 37 | `mina_staging` | La Polea's staging on its two hanging posts, the bearer, strut and porch | cross | 8 x 5 x 2.4 | 1.9 | – | NEW | F | now |
| 38 | `mina_wheel_awning` | The slick roof over the wheel as a plank roof black with spray | play | 8.5 x 0.7 x 2.4 | 1.9 | – | NEW | S | C7b |
| 39 | `mine_stub`, `mine_stub_short` | El Derrumbe's broken cross-beams with their sawn back ends in sockets (one family) | cross | 0.95 / 0.8 x 0.3 x 2.4 | 1.10 (6, 2) | 3 / 3 | REMAKE | F | now |
| 40 | `mina_derrumbe_foot` | The rubble slope and fallen cap beam, the heap behind, the crushed bucket and cable | cross | 5 x 4.3 x 4.5 | 1.10 | – | NEW | F | now |
| 41 | `mina_sump_pile` | A staging pile with its twin behind and the stub of the beam that joined them | cross | 1.2 x 5.8 x 2.6 | the Sump (4) | – | NEW | F | now |
| 42 | `mina_incline_sleeper` | A sleeper of the walk of shame with its spike plates and rail stubs | play | 1.1 x 0.3 x 2.4 | 1.0b (6) | – | NEW | F | now |
| 43 | `float_lifesaver` | The life ring at the foot of the wet slab | play | 1.45 (scaled) | 1.11 | 7 | REMAKE (start from it) | no (bounce look) | now |
| 44 | the fitted modules (`fit_wood_cap_a..c`, `fit_wood_cap_thin_a/b`, `fit_rotten_cap_a/b`, `fit_wood_bar`, `fit_wood_pole_a/b`, `fit_iron_bar`, `fit_rock_cap_a..c`, `fit_rock_panel_a..d`) | What the rest of the held timber and rock wears (the siding deck, the stub deck, the drift and its balcony, the landing stage, the floors) | play | nominal | the whole mountain | not rated | RE-RATE in the mine's light (phase 0); a remake is mountain-wide | – | now |

### B5. The heroes and the machines

| # | Stem | What it is | Layer | Size | Where | Now | Verdict | Skin | Start |
|---|---|---|---|---|---|---|---|---|---|
| 45 | `mina_hoist_headframe` | The lift's dark gallows, head beam, sheave bearing, guide boards, pug medallion | bg | 7.0 x 20.4 x 1.5 | 1.5 | – | NEW | no | now |
| 46 | `counterweight` | The lift's weight (mover) | play | 1.6 x 1.2 | 1.5 | 8 | REMAKE (light pass) | no | now |
| 47 | `ore_bucket` | The lift's bucket (mover); also the spare on the deck | play | 1.2 x 1.04 | 1.5 | 8 | REMAKE (light pass) | no | now |
| 48 | `pulley` | The sheave (turns with the weight) | bg | 0.8 | 1.5 | 6.5 | REMAKE (start from it) | no | now |
| 49 | `winding_wheel` | The winding wheel (mover) | play | 3.2 across, scaled to 6 | 1.9 | 7.5 | REMAKE (start from it) | no (matches the wheel solid) | now |
| 50 | `water_wheel` | The water wheel on the same axle (turns with it) | bg | 8 x 8 x 1.6, scaled 0.625 | 1.9 | 6.5 | REMAKE (start from it) | no | now |
| 51 | `mina_wheel_frame` | The wheel house frame: bearers, axle block, posts, the trough off the falls | bg | 9 x 13 x 2 | 1.9 | – | NEW | no | now |
| 52 | `minecart` | The cart (mover) and the carts on the bottom; shared with biome 0 | play | 2.4 x 1.1 x 1.3 | 1.7, the Sump, 1.0b | 8 | REMAKE (light pass) | no | now |
| 53 | `mine_chock` | The chock under the cart's wheel (thread C's) | play | 0.45 x 0.32 x 0.3 | 1.7 | not rated | RE-RATE | no | now |
| 54 | `mina_drift_portal` | The side drift's timbered portal, gangway, cart on a rail stub, crates | bg | 4.2 x 3.8 x 2.1 | 1.3 | – | NEW | no | now |
| 55 | `mine_boarded_tunnel` | A boarded side tunnel's timber mouth | bg | 1.8 x 2.9 x 0.6 | the Sump, 1.10 | 5 | REMAKE | no | now |
| 56 | `mine_chimney_mouth` | The chimney as one piece: dark throat, mouth, torn planks, and a broken board across it in front (note 108) | cross | 3.6 x 6.2 x 4.4 (z −2.5 .. +1.9) | 1.10 | 5 | REMAKE | no | now (C5 only moves the rocks) |
| 57 | `mine_hoist_wheel_bent` | The hoist wheel knocked crooked, no cable | bg | 1.4 | 1.10 | 6 | REMAKE (start from it) | no | now |
| 58 | `mina_pump` | The drowned level's beam pump, half sunk, a pug-faced pump barrel | bg | 4 x 6 x 2 | the Sump | – | NEW | no | now |
| 59 | `mina_falls_foot` | Wet boulders and a broken staging at the falls' widened foot | bg | 8 x 5 x 3 | the Sump's west (note 146) | – | NEW | no | C1 |
| 60 | `mine_frame` | A doorway timber set (the door, the gallery's mouth, the drift's mouth) | bg | 0.6 x 5 x 2.6 | 1.1, 1.1b, 1.10 | 5 | REMAKE | no | now |
| 61 | `mine_frame_open` | The upper gallery's mouth set, front post gone | bg | 0.6 x 4.5 x 3.2 | 1.9 | 3 | REMAKE | no | now |
| 62 | the timber stock family: `mine_post_stub` 0.9, `mine_post_short` 1.4, `mine_post_mid` 2.0, `mine_post` 3.0, `mine_post_tall` 4.75, `mine_post_long` 6.5, `mine_timber_long` 8.5, `mine_beam` 4.0 | The mine's scenery timber, 0.35 square, laid at any angle (one script, one session) | bg | 0.35 x L x 0.35 | everywhere, about 80 placements | 3, –, 3, 5.5, 2.5, 2.5, 2, 4.5 | REMAKE | no | now |

### B6. Working furniture and props

| # | Stem | What it is | Layer | Size | Where | Now | Verdict | Skin | Start |
|---|---|---|---|---|---|---|---|---|---|
| 63 | `mina_tool_rack` | A timber rack of picks, shovels, sledge, hand steels, fuse, a helmet, a lucha mask | bg | 1.8 x 1.9 x 0.5 | 1.4 shoulder, 1.1b, the upper gallery | – | NEW | no | now |
| 64 | `mina_powder_box` | Dynamite crates with a skull-pug stencil and a plunger box | bg | 1.4 x 1.1 x 0.8 | 1.6's working, 1.10's drift | – | NEW | no | now |
| 65 | `mina_cook_stove` | The waiting room's cold cast-iron stove, pug oven door, coffee pot, pipe | bg | 0.9 x 2.6 x 0.7 | 1.1b | – | NEW | no | now |
| 66 | `mina_tag_board` | The miners' tag board: hooks, a few brass tags, a pug safety poster | bg | 1.2 x 0.9 x 0.1 | 1.1b, the ladder's foot | – | NEW | no | now |
| 67 | `mina_wheelbarrow` | An iron-tyred ore barrow | bg | 1.5 x 0.7 x 0.6 | 1.1, 1.6, the upper gallery | – | NEW | no | now |
| 68 | `ore_sacks` | Tied ore sacks (the station's, new to the mine) | bg | 1.2 x 0.6 | 1.5 deck, 1.3 portal | 7 | REMAKE (start from it) | no | now |
| 69 | `crate_ore` | Dog-face ore crate | bg | 1.2 x 1.1 | 1.5, 1.3, 1.9 | 8 | REMAKE (light pass) | no | now |
| 70 | `ore_cart_wreck` | The tipped cart | bg | 2.48 x 1.72 | 1.1, 1.7, the Sump | 8 | REMAKE (light pass) | no | now |
| 71 | `barrel_side` | A barrel on its side; shared | bg | 1.1 x 0.9 | the Sump | 8 | REMAKE (light pass) | no | now |
| 72 | `mine_ore_chute` | The ore chute out of its hole to a hopper over the rails | bg | 3 x 2 x 1 | 1.1 | 3 | REMAKE | no | now |
| 73 | `mine_hand_winch` | The hand winch on its frame | bg | 1.6 x 1.4 x 0.8 | 1.1b, the top drift | 5.5 | REMAKE | no | now |
| 74 | `mine_rail_bent_end` | A rail pair bent down over a brink | bg | 2 x 0.9 x 1.2 | 1.1 (3) | 5 | BASE ON OLD (`rail_broken`, 6.5) | no | now |
| 75 | `mine_rail_single` | One rail length on its sleepers | bg | 2.0 | 1.0b (10), 1.7 (4) | 4.5 | REMAKE | no | now |
| 76 | `rail_straight` | The station's rail, used at the door and the siding; shared | play/bg | 4.0 | 1.1, 1.7 | 5.5 | REMAKE (with the station's pass) | no | now |
| 77 | `mine_flat_boat` | The miners' flat boat sunk at its mooring | bg | 3.5 x 0.8 x 1 | 1.0b | 3 | REMAKE | no | now |
| 78 | `mine_lamp_post` | A timber lamp post with its iron crook | bg | 0.55 x 3.5 | 1.0b, 1.7 (2) | 3 | REMAKE | no | now |
| 79 | `lantern_hang` | The hanging lamp; shared (x35 on the mountain) | bg | 0.3 x 0.5 | everywhere | 7.5 | REMAKE (light pass) | no | now |
| 80 | `lantern_mine` | The standing lamp | bg | 0.3 x 0.5 | 1.2, 1.4, 1.5, 1.10 | 7.5 | REMAKE (light pass) | no | now |
| 81 | `cold_lantern` | The cold lamp with the cracked glass | bg | 0.28 x 0.48 | the two camps | 7 | REMAKE (start from it) | no | now |
| 82 | `mine_lantern_bracket` | The iron strap bracket; shared | bg | 0.48 x 0.15 | 1.1, 1.8, 1.9 | 4 | REMAKE | no | now |
| 83 | `mine_wall_bracket` | The iron wall arm | bg | 0.1 x 0.3 x 0.25 | 1.3, 1.6, 1.11 | 4 | REMAKE | no | now |
| 84 | `pickaxe` | The pick | bg | 0.9 x 0.6 | the camps, 1.2 | 7 | REMAKE (start from it) | no | now |
| 85 | `rope_coil` | A coil of rope; shared | bg | 0.5 x 0.2 | the camp | 7 | REMAKE (start from it) | no | now |
| 86 | `camp_bedroll` | The bedroll with the pug print; shared | bg | 1.6 x 0.25 | the two camps | 7.5 | REMAKE (light pass) | no | now |
| 87 | `mine_bunting_torn` | The town's bunting, torn, fixed at both ends | bg | 3.5 x 0.8 | 1.1b | 6 | BASE ON OLD (`papel_line`, 7.5) | no | now |
| 88 | `papel_tatters` | Torn papel picado on a cord; shared | bg | 8 x 1 | 1.3, the top drift | 5.5 | BASE ON OLD (`papel_line`, 7.5) | no | now |
| 89 | `sign_pug_skull` | The skull-pug warning; shared | bg | 0.95 x 2.16 | 1.1, 1.4, 1.7, 1.10 | 8 | REMAKE (light pass) | no | now |
| 90 | `sign_pug_arrow` | The pug arrow post | bg | 0.76 x 2.18 | the top drift | 8 | REMAKE (light pass) | no | now |
| 91 | `sign_pug_arrow_east` | Pug arrow sign east | bg | 1.24 x 1.66 | the Sump | 8.5 | KEEP | no | – |
| 92 | `sign_pug_arrow_west` | Pug arrow sign west | bg | 1.24 x 1.66 | 1.2's head | 8.5 | KEEP | no | – |
| 93 | `eye_bolt_plate` | The pug plate holding the mooring ring | bg | 0.35 | 1.0b | 6.5 | REMAKE (start from it) | no | now |
| 94 | `mine_fern_pale` | The mine's fern (flat card) | bg | 0.6 x 0.5 | by the falls and drips | 6.5 | REMAKE (start from it) | no | now |
| 95 | `mine_mushrooms_pale` | Pale mushrooms on old timber (flat card) | bg | 0.35 x 0.22 | on the sets | 6 | REMAKE (start from it) | no | now |
| 96 | `stalactite_a`, `stalactite_b` | Stalactites (one family), never over a hold | bg | 0.8 x 3; 1.5 x 6 | roofs | 5.5 / 5.5 | REMAKE | no | now |
| 97 | `tea_kettle` | The frog's kettle; shared | bg | 0.31 x 0.27 | the frog cave | 6.5 | REMAKE (light pass) | no | now |

### B7. The frog cave

| # | Stem | What it is | Layer | Size | Where | Now | Verdict | Skin | Start |
|---|---|---|---|---|---|---|---|---|---|
| 98 | `frog_sit` | The mine's frog | bg | 0.26 x 0.26 x 0.27 | the frog cave | 8.5 | KEEP | no | – |
| 99 | `mine_frog_shelf` | The shelf of lost boots and masks | bg | 2.2 x 0.45 x 0.3 | the frog cave | 7 | REMAKE (start from it) | no | now |
| 100 | `mine_frog_stove` | The frog's little stove; shared with 10, 11 | bg | 0.6 x 0.7 x 0.5 | the frog cave | 6 | REMAKE (start from it) | no | now |
| 101 | `mine_towel_peg` | A striped towel on a peg | bg | 0.4 x 0.6 | the frog cave | 6 | REMAKE (start from it) | no | now |
| 102 | `mine_bucket_upturned` | The frog's seat; shared | bg | 0.6 x 0.45 | the frog cave | 5 | REMAKE | no | now |

### B8. The foreground (sparse)

| # | Stem | What it is | Layer | Size | Where | Now | Verdict | Skin | Start |
|---|---|---|---|---|---|---|---|---|---|
| 103 | `mine_post_broken_short`, `mine_post_broken`, `mine_post_broken_long` | Front posts of sets in broken lengths (one family); each placed so it visibly stands on a sill or the rubble | fg | 0.3 x 1.6 / 2.6 / 3.8 | every shaft's sides | 3.5 / 3.5 / 3 | REMAKE | no | now |
| 104 | `mine_rubble_lip` | The low lip of rubble along a frame's foot | fg | 10 x 1 x 0.7 | 1.1, 1.1b, 1.10 | 3.5 | REMAKE | no | now |

### B9. The join (held for La Esclusa's page; answered in part F, F-B7)

| # | Stem | What it is | Layer | Size | Where | Now | Verdict | Skin | Start |
|---|---|---|---|---|---|---|---|---|---|
| 105 | `timber_set` | The mine's last set at the dry shaft's mouth, in scenery grey | bg | 3.6 x 4 x 0.36 | the lip | 7 | REMAKE (start from it) | no | La Esclusa's page |
| 106 | `works_arch_low` | The works' first arch standing on the last set, cast pug | bg | 3.9 x 1.95 x 0.4 | the lip | 4 | REMAKE | no | La Esclusa's page |
| 107 | `works_brick_pier_post` | Foreground: timber below, brick above, in front of the pier | fg | 0.55 x 2 x 0.35 | the lip | 3 | REMAKE | no | La Esclusa's page |

### B10. Removed: folded into another model, painted into a set, or not needed

Each of these leaves the mine; its job is done by the model named.

| # | Stem | Now | Where its job goes | Verdict |
|---|---|---|---|---|
| 108 | `mine_cavern_far_wall` | 2.5 | `mina_backdrop_cavern` | REMOVE |
| 109 | `mine_chain_rib_body` | 2 | `mine_chain_rib` | REMOVE |
| 110 | `mine_incline_bench` | 2 | `mine_chain_rib` | REMOVE |
| 111 | `mine_el_diente_body` | 1.5 | `mine_el_diente` | REMOVE |
| 112 | `mine_tunnel_back` | 1.5 | `mine_el_diente` (the arch tunnel at its foot) | REMOVE |
| 113 | `mine_cave_rock` | 2 | `mine_frog_cave` | REMOVE |
| 114 | `mine_winch_cut` | 2 | `mine_lining_gallery` (a real opening) | REMOVE |
| 115 | `mine_dark_hole` | 2 | `mine_chimney_mouth` | REMOVE |
| 116 | `mine_landing_rotted` | 3 | `mine_lining_escalera` | REMOVE |
| 117 | `mine_half_landing` | 2.5 | `mine_lining_derrumbe` | REMOVE |
| 118 | `mine_ladder` | 4.5 | `mine_lining_derrumbe` | REMOVE |
| 119 | `mine_ladder_snapped` | 5 | `mine_lining_derrumbe` | REMOVE |
| 120 | `mine_prop_short` | 3 | `mine_cavern_wall_high` (the workings' props) | REMOVE |
| 121 | `mine_rubble_heap_big` | 4.5 | `mina_derrumbe_foot` | REMOVE |
| 122 | `mine_bucket_crushed` | 3.5 | `mina_derrumbe_foot` | REMOVE |
| 123 | `rubble_pile` (in the mine) | 5 | `mina_derrumbe_foot` | REMOVE |
| 124 | `mine_deck_back` | 2 | `mina_station_deck` | REMOVE |
| 125 | `mine_trimmer_end` | 5 | `mina_station_deck` | REMOVE |
| 126 | `mine_walk_bearer` | 3 | `mina_walk_length`, `mina_station_deck` | REMOVE |
| 127 | `mine_bearer_snapped` | 2.5 | painted in `mine_cavern_wall_mid` | REMOVE |
| 128 | `mine_gangway_stub` | 3 | `mina_drift_portal` | REMOVE |
| 129 | `mine_incline_bent_tall` | 2.5 | `mine_cart_road` | REMOVE |
| 130 | `mine_incline_bent` | 3 | `mine_cart_road` | REMOVE |
| 131 | `mine_incline_bent_low` | 3 | `mine_cart_road` | REMOVE |
| 132 | `mine_water_trough` | 2.5 | `mina_wheel_frame` | REMOVE |
| 133 | `mine_sleeper` | 2 | `mine_mud_tongue` | REMOVE |
| 134 | `mine_bucket_side` | 3 | an `ore_bucket` deco on its side | REMOVE |
| 135 | `mine_iron_eye` | 3.5 | `mina_hoist_arm` | REMOVE |
| 136 | `mine_iron_strap` | 3 | the sets and `mina_gallery_beam_end` carry their straps | REMOVE |
| 137 | `mine_stirrup` | 3.5 | `mina_viga_first` | REMOVE |
| 138 | `mine_stirrup_wet` | 3 | `mina_viga_wet` | REMOVE |
| 139 | `mine_bolt_plate` | 3 | `mine_beam_roof` | REMOVE |
| 140 | `mine_spike_plate` | 3 | `mina_incline_sleeper` | REMOVE |
| 141 | `mine_nail_row` | 2 | `mina_walk_length`, `mina_staging` | REMOVE |
| 142 | `mine_rail_end_torn` | 2 | `mina_iron_ladder` | REMOVE |
| 143 | `fit_ladder_rung_bent` (in the mine) | 5 | `mine_lining_escalera` | REMOVE |
| 144 | `mine_socket_empty` | 3 | painted in the sets; real in the skins that sit in them | REMOVE |
| 145 | `mine_socket_scarred` | 3.5 | painted in `mine_cavern_wall_mid` | REMOVE |
| 146 | `mine_socket_stump` | 4 | painted in `mine_cavern_wall_mid` | REMOVE |
| 147 | `mine_end_splintered` | 6 | `mina_gallery_beam_end` | REMOVE |
| 148 | `mine_side_splintered` | 3 | the skins' own ends (stubs, vigas, walk) | REMOVE |
| 149 | `mine_post_tongue` | 4 | `mina_gallery_post_sunk` | REMOVE |
| 150 | `mine_mud_tideline` | 3 | `mina_gallery_post_sunk` | REMOVE |
| 151 | `mine_pile_band` | 3.5 | `mina_sump_pile` | REMOVE |
| 152 | `mine_pile_twin` | 2.5 | `mina_sump_pile` | REMOVE |
| 153 | `sawn_end` (in the mine) | 5.5 | `mine_stub` family | REMOVE |
| 154 | `mine_worn_path` | 1.5 | not needed (a hairline) | REMOVE |
| 155 | `mine_rust_lines` | 1.5 | `mina_incline_sleeper` (the rail stubs) | REMOVE |
| 156 | `mine_rust_stain` | 3 | painted in `mine_cortina_wall` | REMOVE |
| 157 | `mine_drip_board` | 2.5 | `mine_staple_bound` | REMOVE |
| 158 | `mine_water_marks` | 3.5 | painted in `mine_frog_cave` | REMOVE |
| 159 | `tally_marks` | 4.5 | scratched into `mine_lining_gallery`'s planks (note 107) | REMOVE |
| 160 | `mine_moss` | 4 | painted on the sets' outcrop ledges | REMOVE |
| 161 | `mine_outcrop` | 3 | built into the sets (they read as floating bowls) | REMOVE |
| 162 | `mine_outcrop_small` | 3 | built into the sets | REMOVE |
| 163 | `station_scaffold` (in the mine) | 7 | `mina_set_stopes_east` (orange station timber reads as climbable here) | REMOVE |
| 164 | `works_coping_face` | 3 | painted on the join's ledge (La Esclusa's page) | REMOVE |
| 165 | `works_brick_courses_face` | 5 | painted on the join's ledge (La Esclusa's page) | REMOVE |

### Counts

| Verdict | Rows (maker sessions) |
|---|---|
| KEEP | 3 |
| BASE ON OLD | 3 |
| REMAKE | 74 (of them 12 light passes that go to the reviewer first) |
| NEW | 25 |
| RE-RATE | 2 (the fitted modules, the chock) |
| REMOVE | 58 |

So the mine needs at most 102 maker sessions (74 remakes, 25 new, 3 based on old; fewer if the
reviewer passes some of the 12 light passes as they are), and it ends with 107 models in place of
today's 130 mine stems plus the shared ones. Of the 102 sessions, 26 are skins (11 whose shape waits
on the course, 15 fixed) and 76 are not; 82 can start before any course change, 20 wait for one
(part C).

---

## C. Course changes for the fix thread

In the order they must happen. Each says which models wait for it.

- **C1. Note 146: the move** (first; Parker's order in QUALITY_TO_9_PLAN). Design pages first
  (`rearrange_146`, being drawn), then the build: a1.py and a1_dress.py shifted by the draft's
  (−59, −17) and −6 more west of x −246; the falls cavern and the Sump widened at the foot; the cart
  ride (0.3) lengthened to the moved door; La Esclusa built under the black waters; st.py's
  `BODY_WINDOWS`, the backstop card (a1.py line 575), the cameras and the lights move with it; the
  play re-checked (notes 1, 3, 6, 8, 9 to 11, 13 to 15, 103 must still hold). *Waiting on it:* the
  rock skins (16 to 20, re-frozen from the moved area file), `mine_cortina_wall`, `mine_frog_cave`,
  `mina_falls_foot`. Everything else is made relative to its own origin and does not care.
- **C2. Note 111: the great falls** at its full 6 m as a 3D falling body (the water code, not a
  model; a1.py line 133's `width=0.25`), joined to the falls above (one column from under the forge
  to the Sump after 146). *Waiting:* nothing; the backdrop and the throat wall are made to sit behind
  a 6 m sheet, and their frames wait for it.
- **C3. Note 109 and the z-fight sweep** (phase 0): the frog cave's two unskinned cut solids (a1.py
  lines 143 and 144) take the throat's skin or the room's floor; the room's floor goes a hair under
  the play floor; the sweep over the whole mine. *Waiting:* `mine_frog_cave`, `mine_throat_west`.
- **C4. Note 104 and the drawn-against-solid sweep:** measure the five pegs (a1.py 155 to 157) and
  the four stakes (158 to 160) drawn against solid, then make each peg the hung beam's end (box kept,
  `skin="mina_gallery_beam_end"`) and each stake its post head (`skin="mina_gallery_post_sunk"`); the
  dress stops drawing `mine_end_splintered`, `mine_post_tongue`, `mine_mud_tideline` and the strap
  there. *Waiting:* 22, 23.
- **C5. Note 108:** the two rock sources (a1.py 418, 419) up inside the chimney to about y 80.5;
  the foreground board is part of `mine_chimney_mouth` (z +1.25 and nearer, over the chimney only,
  above y 77, where nobody can be behind it); the written rhythm shifts as a whole (about 0.4 s), the
  warning with it. *Waiting:* the chimney's frame (the model can be made now).
- **C6. Skins for the climb.** `skin=` on: the ladder's runs (a ladder that wears a model in place of
  the code's drawn rails: a small code change in `A.ladder` / peak_things), the walk's five lengths and
  four boards (and a check that a breakable keeps its skin's look while it cracks), the arm and the
  rod, El Cubo's seven rungs, the station deck, Las Vigas's four pieces, the staging and porch, the
  piles, the sleepers, the rubble slope and fallen beam, and the pillar's shoulder landing (a1.py
  199: El Diente's skin). The rest of the held timber keeps the fitted modules. *Waiting:* 24, 26 (the
  others can be made now and hooked up when they land).
- **C7. Solids reshaped into the real objects** (Parker: "100% freedom"):
  - **a.** La Cortina's 28 holds from hexagons (r 0.24) to the staple's bar (about 0.4 x 0.12): the
    same reach; play checked. El Cubo's seven rungs already are bars.
  - **b.** The awning over the wheel (a1.py 382) from a 0.55 slab to a plank roof with an eave lip,
    same slope, same slide off its tip into the falls.
  - **c.** The throat's back wall face from z −1.6 to −1.3 (a1_dress `THROAT_Z`), so a staple's legs
    are 1.3 m and it meets its hold from every angle (today it is drawn 1.6 m behind its hold).
  - **d.** (Optional.) El Diente's outline leaning and notched (the walls rule), if it makes a better
    pillar; the east face's play unchanged.
  *Waiting:* 29 to 31 (a, c), 38 (b), 16 (d, only if done).
- **C8. Code-drawn looks taken out as the models land:** the two hoistway cards (a1.py 236 to 240)
  when `mina_hoist_headframe` lands; the picture cards (531 to 537: z −14, −10, −4, −3, and the two in
  front at z +3 and +4, checked against note 40's keep list) when the backdrop and sets land; the
  `station_scaffold` and its lantern (538 to 540); the backstop (575) moved behind the backdrop
  (about z −18).
- **C9. The dress (a1_dress.py):** place the merged models and take out the stems of B10; the rules:
  no lone scenery stick (every timber part of a set or meeting another at a joint you can see); every
  foreground length stands on a sill or the rubble; nothing small on a wall unless it is on a ledge,
  hook or shelf; every frame of part A has its three things; the 21 lanterns' lights follow them.
- **C10. Code notes the pass must see working** (no models): 110 (the zoom pulls back everywhere:
  check in the frog cave and El Derrumbe), 138 (the mine's three ropes and the chain lock while
  held), 125 (the controller's bind on the tip).
- **C11. The winding wheel's size:** keep its contract (made at 3.2, a1.py's `model_scale` 6/3.2), or
  land it at 6.0 and set `model_scale` to 1 (one line). Decide before its maker starts.

---

## D. The order

### The first ten (none waits for a course change)

Chosen for the biggest lift (the backdrop and the sets of the main stretches, the heroes of the
emptiest frames, the most-used pieces) and for being free of part C.

1. **`mina_backdrop_cavern`**: the far scene behind every open frame (1.7, 1.8, the Sump, 1.9, the
   gallery's mouth); the rating's first complaint is "no painted depth".
2. **`mine_cavern_wall_mid`**: the set behind 1.3 and 1.4, two of the three worst frames (4, 4).
3. **`mine_cavern_wall_high`**: the set behind 1.5 (3.5, the worst frame) and 1.6 (4.5).
4. **`mine_chain_rib`**: the set behind 1.7 (5) and 1.8 (4.5): its "yellow stripe" and plain slabs.
5. **`mina_hoist_headframe`**: 1.5's hero, in place of two flat cards (note 4's "real look").
6. **`mina_drift_portal`**: 1.3's hero; the walk finally goes somewhere.
7. **`mine_lining_gallery`**: the first frame after the station's 9.5, with note 107's tally marks.
8. **`winding_wheel`**: the mine's biggest machine, seen from 1.8 and 1.9.
9. **The timber stock family**: about 80 placements; every frame's timber at once.
10. **`mina_tool_rack`**: working furniture in three frames, the first of the props.

### Then, grouped (one model per session, many sessions in flight)

- **Group 2, the rest of the sets and the fixed skins (can start now):** `mina_set_stopes_east`,
  `mine_lining_escalera`, `mine_cavern_wall_low`, `mine_upper_works_body`, `mine_lining_derrumbe`,
  `mine_mud_tongue`, `mine_waiting_room`; `mine_cart_road`, `mina_walk_length`, `plank`,
  `mina_hoist_arm`, `mina_station_deck`, `mina_viga_first`, `mina_viga_wet`, `mine_beam_roof`,
  `mina_staging`, the stub family, the rib family, `iron_ring_pin_long`, `mina_derrumbe_foot`,
  `mina_sump_pile`, `mina_incline_sleeper`, `mina_iron_ladder`.
- **Group 3, the heroes and machines (can start now):** `mine_chimney_mouth` (note 108),
  `water_wheel`, `mina_wheel_frame`, `pulley`, `mina_pump`, `mine_hoist_wheel_bent`, `mine_ore_chute`,
  `mine_hand_winch`, `mine_boarded_tunnel`, `mine_frame`, `mine_frame_open`; the light passes
  `counterweight`, `ore_bucket`, `minecart`.
- **Group 4, after C1 (the move) and C3:** the rock skins `mine_el_diente`, `mine_east_mass` (note 106),
  `mine_chamber_roof`, `mine_upper_works_mass`, `mine_throat_west`; `mine_cortina_wall`,
  `mine_frog_cave`, `mina_falls_foot`.
- **Group 5, after C4 and C7:** `mina_gallery_beam_end`, `mina_gallery_post_sunk`, the three staples,
  `mina_wheel_awning`.
- **Group 6, the props (can start now; the light passes go to the reviewer first):**
  `mina_powder_box`, `mina_cook_stove`, `mina_tag_board`, `mina_wheelbarrow`, the lanterns and
  brackets, `pickaxe`, `rope_coil`, `camp_bedroll`, the two signs, `ore_sacks`, `crate_ore`,
  `ore_cart_wreck`, `barrel_side`, `mine_flat_boat`, `mine_lamp_post`, the rails, `eye_bolt_plate`, the
  plants, the stalactites, the frog cave's four, the two papel picado, `tea_kettle`, `float_lifesaver`.
- **Group 7, the foreground** (last, so it is placed against finished sets): the front post family,
  `mine_rubble_lip`.
- **Held:** the join (`timber_set`, `works_arch_low`, `works_brick_pier_post`,
  `mine_lining_dry_shaft`) until La Esclusa's page (answered in part F, F-B7: all four leave).
- **Phase 0, before any of it:** the reviewer rates the fitted modules in the mine's light (B4 row 44)
  and the chock.

Then, per QUALITY_TO_9_PLAN part 4: each lands at 8.5 on its sheet, is synced, and is checked again in
a game frame of its place; the scenes are scored as frames against the 9; Parker sees one sheet for
the mine before the next biome.

**The Director's question, settled: see part F.** Los Barriles and La Esclusa (1.12 and 1.13) belong to the
mine's pass, as their numbers say (note 146, Parker 11-14 15:30; built into a1.py 11-15). Their plan, and the
join's, is part F.

---

## E. The maker briefs for the first ten

Every brief shares these rules, so they are said once:

- **One model, this one only.** Its sheet goes to the reviewer; round after round until 8.5.
- **The house's look:** low poly, one colour per face, the one shared atlas, the cel shader and ink;
  **matte only** (no metallic or polished colour anywhere, gold and brass included: paint the shine as
  a flush lighter region; A2's zebra fix: polished colours stripe in the game; check
  `build\land\<stem>_atlas_report.json`, every row MATTE); **no emissive** (a lantern's glow or a lit
  pool is painted); no text (leave `*_face` panels).
- **A 9 is:** a real silhouette that reads at 13.7 m from the game's camera; three levels of detail
  (the form, the secondary parts, the trim and wear); the house's character (pug faces, lucha masks,
  papel picado, honest wear); consistent with the plaza houses
  (`Top Dog Kit\previews\check\plaza_house_*`), `stn_house` and the frogs (`frog_*`,
  `previews\frog_stop_review.png`); right from the game's angled camera, not only from the front.
- **The mine's colours** (a1_biome.py "looks"): what you hold is honey timber `#C9903F`, pale chalky
  rock, rust-orange iron `#B5532A`; what you can't is black-wet (painted sheen, matte); scenery timber
  is greyer, darker and cooler, never honey (thread C's shade tones `sc_tim` `#B8925C` and darker,
  `sc_rust` `#A8674C`, in `Top Dog Kit\source\stn_c_lib.py`); far rock cold grey-violet; the falls the
  one cool bright thing. **The game's light:** the mine's measured light is (0.73, 0.60, 0.57) per
  channel (thread A's hand-over); the game's colour change is `screen = M * file + o` (Top Dog Kit
  `docs\PARTS.md`, P-C2): mid-values brighten, darks go darker, file colours above about
  (213, 196, 200) go white; a band needs a light step 20 to 35 levels over its base to survive.
- **The mine's ONE scenery timber (set by the reviewer in the game, 11-14):** faces `#66655E`, adze facets `#6F7372`, worn chamfers `#727777` (the timber family's round 3, solved through the game's colour curve so that even a metre from a lantern it lands mid grey-brown, below the honey of what you hold). The older `#8E7E6A` family goes pale under a lantern: never use it. Bench every scenery piece lit as the game lights it by a lantern, not only in the mine's average light.
- **Readability:** nothing pale and nothing red behind the climber at climbing heights; the bone-white
  climber reads against mid-dark; nothing thin hangs near the climb (note 4); nothing stands in front
  of a place a climber can be (note 40).
- **Coordinates:** today's, then "moved" = the note 146 draft ((x − 59, y − 17), and −6 more where
  x < −246). Model in the file's own axes (X right, Y up, +Z toward the camera); the origin as given;
  a deco's size is the size it is made at (the game rescales one more than a quarter off).
- **The sheet:** front; three-quarter; **the game's camera at 13.7 m, a little above and to one side,
  at true size and enlarged** (as `frog_stop_review.png`), with stand-ins for the course and a
  bone-white 1.75 m climber; where it is a skin, beside its solid's outline; where it crosses depths,
  a high and a low view so its parts are seen to join. Then the z-fight check at 0 and `land.sh`.
- **Methods** (in `C:\Users\Parke\OneDrive\Desktop\Clod Things\Top Dog Kit\`): the kit's road and
  taste, `docs\HOW_WE_MAKE_KIT_PIECES.md`; **painted walls** (thread A): `source\stn_a_paint.py`
  (`piece()`, `bands`, `card`), `source\stn_a_lib.py` `painted_model()` with `faces3d` for real 3D
  reveals, the mine's modules `source\stn_a_mine_design.py`, `stn_a_mine_walls.py`,
  `stn_a_mine_small.py`, bench `source\stn_a_mine_views.py` with `MINE_LIGHT=1`, and the hand-over
  `C:\Users\Parke\AppData\Local\Claude-Data\claude_pzs8sxrjxfjjc\side-session-notes\local_09c303a1-9f02-44c4-8751-dc3d5fae36c3\thread_A_handover_1114.md`
  (and `thread_A2_`, `thread_A3_handover_1114.md`); **far backdrops**: HOW_WE_MAKE section 7 "Far
  backgrounds are flat facades", worked example `source\stn_far_hills_design.py`,
  `source\stn_b_ground.py`; **props** (thread B): `source\stn_b_lib.py`, bench `tools\stn_b_views.py`,
  `source\stn_b_crop.py`, notes `station-props-thread-b.md` in the same notes folder; **timber and
  iron** (thread C): `source\stn_c_lib.py` (PAL), `source\peak_c_mine.py`, `peak_c_mine2.py`, benches
  `source\peak_c_mine_bench.py`, `source\stn_c_scene.py`, `stn_c_crop.py`, notes
  `station-thread-C-tones-and-bench.md`.
- **Each piece's current look** is in `TopDog-luchador\docs\peak\rating\things\<stem>.jpg`; its frames in
  `docs\peak\rating\frames\c1_*.jpg`.

### E1. `mina_backdrop_cavern` (NEW): the cavern's far side

**What and where.** The one painted backdrop of the mine: the far side of the great cavern, seen
wherever the cavern is open behind the climb (1.6's left edge, 1.7, 1.8, 1.9, the Sump, out of the
gallery's mouth). Made for the moved cavern: x −333 .. −243, y −67 .. 83, at z −15 (today's
equivalent x −268 .. −184 with the widening, y −50 .. 100). It must run past every edge the camera can
see, at the close view and pulled back (note 110: twice the close view), or the backstop shows (note
51). Size about 90 x 150 x 0.5 (a card, its cut edge kraft-stripe-kraft, its braces behind inside its
outline). Origin: the middle of its foot, (−288, −67) moved, z −15.

**Layer and how it connects.** Background far only. What is painted lines up with the real things in
front: the great falls' painted glow and mist stand straight behind the real falls' column (moved
x −303 .. −297, today −244 .. −238), running its full height (note 146: one fall from top to bottom),
so the 3D falls (note 111) stands in front of its own light; the painted gallery tiers continue the
lines of the real walk (y 6) and of the roof (y 55); the upper works' painted winding wheel and
headframe, high on the far side, echo the real wheel at 1.9; at the foot, the drowned level's sets and
the water line catching the falls' light continue the real drowned sets (z −3.75).

**What makes it a 9.** Three rows, as `stn_far_hills`: a far row of the cavern's far wall in cold
grey-violet, hazed, with galleries in tiers, their timber sets as rows of small posts and caps,
ladder ways between tiers, an ore chute down from a high stope, two or three painted lantern pools
(warm, painted, no emissive); a middle row of the roof's stalactite fringe and buttresses of rock; a
near row of dark wet rock framing the falls, a drift of mist along the foot. Three levels: the big
forms (the tiers, the buttresses, the falls' glow), the parts (timber rows, ladders, the chute, the
far wheel), the trim (a faded papel picado string on one gallery, a tiny skull-pug board, drips of one
even width). Three or four close values, the falls the brightest thing, nothing pale anywhere else at
climbing heights; long wavy bands broken by things, never stripes.

**Standard:** `stn_far_hills` (Parker: "the correct way to do far backgrounds"), the station's mesas
and clouds (9.5), the plaza houses for finish. **Old:** `mine_cavern_far_wall` (2.5) shows what not
to do ("striped purple-black card; flat bands, no painted depth"). **Notes:** 51, 110, 111, 146;
LOOKS_RATING "every challenge sits on the same muddy purple-brown wall of diagonal bands, with no
painted depth". **Method:** far facade (HOW_WE_MAKE section 7) with thread A's paint
(`stn_a_paint.py` card and flush regions), bench with `MINE_LIGHT=1`.

**The sheet:** front; three-quarter; the game's camera at 13.7 m at true size and enlarged from four
places (the Sump looking at the falls' foot, 1.7's start, the chain, 1.8) with grey stand-ins for
El Diente, the chain rib and the falls' column in front so its depth reads; one pulled-back view
(twice the close view) showing no edge; high and low views.

### E2. `mine_cavern_wall_mid` (REMAKE): the set behind Los Tablones and La Cuerda

**What and where.** The hand-cut wall of the cavern 1.7 m behind the plank walk: x −201.9 .. −171,
y −6 .. 18 (moved x −260.9 .. −230, y −23 .. 1). Size 30.9 x 24 x 5: its face at z −2.9 (the bearers'
sockets), receding to about z −8 where old workings open back. Origin: the middle of its foot,
(−186.45, −6.0), moved (−245.45, −23.0); depth measured from the face.

**Layer and how it connects.** Background, near. The walk's bearers (`mina_walk_length`) enter its
face: leave a socket at each bearer, x −177.95, −179.85, −181.35, −184.55, −186.05, −187.95, −189.85,
−190.45, −192.55, their tops at y 5.78 .. 5.73. Leave a real opening 2.2 x 3.2 at x −186.4 .. −184.2,
y 5.6 .. 8.8 for the side drift's portal (`mina_drift_portal`) to stand in. It meets
`mine_cavern_wall_low` along y −6 and `mine_cavern_wall_high` along y 18 with the same bands, and
El Diente's body at its west end.

**What makes it a 9.** A place, not a slab: the face in long wavy flat bands of pick-marked rock, dry
above the walk, dark with wet below (painted, matte); the lower walk that fell, 6 m down, as a row of
sockets with pale broken rims along its old line, with its one surviving length still resting in two
of them (part of the wall: today's "floating bench"); one old stope cut back 2 m at about
x −196 .. −192, y 8 .. 12, framed by a real timber set (posts, cap, a wedge), its back painted dark
with a far lantern glow; three snapped bearer stubs and one socket with a stump across the gap at
y 5.2 (1.4); three or four outcrop ledges built into the face (flat tops, not bowls) for the pale ferns
and moss; a line of nail heads where the town's papel picado is nailed (the string is its own model).
Three levels: the planes and the openings; the set, sockets, ledges and stubs; pick marks, drips of
one width, damp at the foot. Mid-dark behind the walk's heights (y 6 to 8): the climber reads.

**Standard:** the plaza houses (depth makes a facade: openings recessed with a reveal, frames proud),
`stn_yard_wall` (9). **Old:** today's (2.5) only for its footprint. **Notes:** LOOKS_RATING 1.3 (4)
"a bowl floats in mid-air below the bridge; row of tiny floating squares; nothing behind", 1.4 (4)
"empty wall, floating squares, a plank bench floating low right"; note 40. **Method:** painted walls
(thread A: `stn_a_mine_walls.py`, `painted_model()` with `faces3d` for the stope's reveal),
`MINE_LIGHT=1`.

**The sheet:** front; three-quarter; the game's camera at 13.7 m, true size and enlarged, at 1.3's
start (−174.5, 6.0) and at 1.4 (−191.5, 6.0), with stand-ins for the walk, its bearers, the portal and
a climber; high and low views (it recedes 5 m).

### E3. `mine_cavern_wall_high` (REMAKE): the set behind El Cubo and Vetas de Lodo

**What and where.** The same wall above: x −201.9 .. −184, y 18 .. 44 (moved x −260.9 .. −243,
y 1 .. 27). Size 17.9 x 26 x 5, face at z −2.9. Origin: the middle of its foot, (−192.95, 18.0),
moved (−251.95, 1.0).

**Layer and how it connects.** Background, near. In front of it stand the hoist headframe
(z −1.3 .. −2.8, x −193.3 .. −186.3, y 12.4 .. 32.8) and the station deck's back half, which runs back
on its bearers into sockets in this face at y 25.9 (x −198.8, −193.0). It meets `mine_cavern_wall_mid`
along y 18 and the roof (`mine_chamber_roof`) at its top.

**What makes it a 9.** The two old workings along the same seams as El Diente's ribs, at 32.15 and
37.3, rising east at 0.179 a metre (x −197 .. −192 and −198.5 .. −193.5): each a real stope cut back
1.5 to 2.5 m with side walls that recede, its back painted dark, propped by three short timber props
with cap pieces (absorbing `mine_prop_short`), a flat floor where things will stand (the powder box in
the lower one, a barrow in the upper one), a bracket for the wall lantern at (−194.4, 35.0); the eight
seams across the face at the pillar's slant, greyer than the rock so none reads as a ledge; an outcrop
ledge with moss at (−189.0, 22.0); the roof's stalactite fringe painted where it meets the roof.
Mid-dark behind the ribs (the climber at x ≈ −201) and behind the counterweight's run.

**Standard:** as E2. **Old:** today's (2.5) for its footprint and seams. **Notes:** LOOKS_RATING 1.5
(3.5) "a lone plank ledge ... a blank wall ... emptiest frame of the mine", 1.6 (4.5) "floating bowl
right; big plain slab block right". **Method:** as E2.

**The sheet:** front; three-quarter; the game's camera at 13.7 m, true size and enlarged, at 1.5's
start (−200.0, 6.0), on the counterweight at its top (−190.2, 27.0) and at 1.6 (−201.0, 33.0), with
stand-ins for the headframe, deck, ribs and a climber; high and low.


**Carried from E6 (the headframe maker, round 2):** six `mine_prop_short` placed by a1_dress.py in the old workings above El Cubo float in the air; this wall must give them something to stand on (a ledge, a working face, a drift floor), or they go.

### E4. `mine_chain_rib` (REMAKE, absorbing `mine_chain_rib_body` and `mine_incline_bench`): the set of the cart room and Las Vigas

**What and where.** The back wall west of El Diente, from the bench under the incline up to the roof:
x −233 .. −209, y 21.5 .. 55 (moved x −292 .. −268, y 4.5 .. 38). Size about 24 x 34 x 5: the rib's
face at z −1.6, the wall behind receding to about z −6.6. Origin: the middle of its foot, (−221.0,
21.5), moved (−280.0, 4.5).

**Layer and how it connects.** Background, near. The three rings' pins root in the rib's face at
(−230.6, 44.42), (−226.2, 46.42), (−221.8, 48.42), z −1.6 (moved x − 59, y − 17): a drilled boss of
rock round each. The incline's three bents stand on the bench: leave flat pads on its uneven top
(y 25.5 .. 26.4) at x −216.7, −220.5, −222.7. Las Vigas's back beam and its hangers stand in front
(z −1.45 .. −1.7) against the upper wall; El Diente's body meets its east edge; the great falls pass its
west end.

**What makes it a 9.** One rib of three close grey-violet beds slanting up from the falls to under
the beams, an overhang along its lower edge with a painted shadow under it, one ore band 0.4 thick of
gold-ochre under the rings (not the pale hold colour, so it never reads as a ledge: today's "pale
diagonal streak"); behind it the wall in two or three slanted planes, duller and cooler, with one old
drift opening framed by a real timber set and painted dark; its west end darker and wet with spray,
ferns on one outcrop under the middle ring; the bench a darker, wetter shelf of the same rock with
rubble at its edge. Three levels: rib, planes, bench; the drift, the pads, the bosses; beds, drips of
one width, ferns. The chain (rusty red, x −230.6, y 35.2 .. 44.2) and the climber on it must read
against it: no red or rust tones behind the chain.

**Standard:** the cliffs' painted rock (approved by Parker), the plaza houses for finish. **Old:**
today's three pieces (2, 2, 2) for their outlines. **Notes:** 103; LOOKS_RATING 1.7 (5) "dark plain
slabs, a pale diagonal streak", 1.8 (4.5) "plain slab wall with a yellow diagonal stripe, empty below".
**Method:** painted walls (thread A), `faces3d` for the overhang and the drift's reveal,
`MINE_LIGHT=1`.

**The sheet:** front; three-quarter; the game's camera at 13.7 m, true size and enlarged, at 1.7's
start (−203.6, 40.0), on the chain (−230.6, 40.0) and at 1.8 (−216.5, 50.5), with stand-ins for the
rings, the chain, the road and its bents, the beams and a climber; high and low (it recedes 5 m and
the pins cross into the play space).

### E5. `mine_lining_gallery` (REMAKE, absorbing `mine_winch_cut` and `tally_marks`): the gallery's back wall

**What and where.** The back wall of La Galería and the camp, door to mouth: x −176 .. −152,
y −12.6 .. −7.5 (moved x −235 .. −211, y −29.6 .. −24.5). Size 24.0 x 5.1 x 0.8: its face at z −1.65,
bays set back to about z −2.45. Origin: the middle of its foot, (−164.0, −12.6), moved
(−223.0, −29.6).

**Layer and how it connects.** Background, near. The gallery's real posts and roof timbers stand in
front of it (z −1.45: the timber family); the five hung beam ends are in the play plane in front of
those. Two real openings with timber reveals: the waiting room (x −170.1 .. −167.95, its own model
fits in) and the winch's cut (x −175.7 .. −173.9, floored with timber, the winch stands in it). The
ore chute (`mine_ore_chute`) comes out of the chute's painted hole high by the door; the mud tongue
(`mine_mud_tongue`) meets the burst at its foot.

**What makes it a 9.** Planks as long flat bands of colour in bays between the sets (no repeated
panel), in two storeys with the tie timber at y −10.78; over the pit (x −164 .. −156) the lining burst
outward, a few real split plank ends standing proud around black mud painted flat (no dark recess);
the chute's hole with its timber frame; a mud splash line low near the pit; green damp at the seams
near the shaft; **the tally marks of note 107** at x −166.9, y −11.8 (beside the frozen climber at
x −167.0): groups of four strokes and a slash, pale raw-wood lines cut into the board, a few uneven
groups, flush on the plank face, no card, no glow, no background shape. Three levels: bays and
openings; reveals, frames, the burst, the hole; grain, nail heads, damp, the marks. Mid values behind
the beam ends (y −10.78) and a standing climber.

**Standard:** the plaza houses (recessed openings with reveals), `stn_house` (9), `stn_yard_wall` (9).
**Old:** today's (2.5) for the footprint. **Notes:** 107, 104 (the beam ends in front), LOOKS_RATING 1.1
(6) "plain grey stepped slabs; black void below the deck". **Method:** painted walls (thread A: plank
lining as flat bands, `stn_a_mine_walls.py`), `MINE_LIGHT=1`.

**The sheet:** front; three-quarter; the game's camera at 13.7 m and at the gallery's own close camera
(its camera zone is the tightest in the mine), true size and enlarged, at 1.1's start (−154.0, −12.6)
and at the camp (−167.0, −12.6) with stand-ins for the posts, beams, the statue and a climber; the
tally marks enlarged on their own.


**Carried from E10 (the tool rack, placed in the game):** the camp's tool rack now stands in the winch's cut in this lining (x -174.8), in place of the hand winch, because anything standing behind the lining (z -1.65) cannot be seen. Give the winch a new place in this remake (its own cut, or the incline's head), and keep the rack's bay open.

### E6. `mina_hoist_headframe` (NEW): El Cubo's hero

**What and where.** The bucket lift's gallows and guides, in place of the two flat hoistway cards
(a1.py lines 236 to 240): on the station deck (top y 26.2) and down the lift's run, x −193.3 .. −186.3,
y 12.4 .. 32.8 (moved x −252.3 .. −245.3, y −4.6 .. 15.8), z −1.3 .. −2.8 (between the movers at
z ±0.6 and the wall's face at −2.9). Size 7.0 x 20.4 x 1.5. Origin: the foot of its main post on the
deck, (−193.0, 26.2), moved (−252.0, 9.2), z −2.05.

**Layer and how it connects.** Background, standing on the play space's deck. A main post on the
deck's east end; a head beam at y 32.2 .. 32.8 over both runs, with the bearing for the sheave (the
real `pulley` turns with the weight at (−188.95, 31.4), z −2.2: model its axle block, not the wheel);
a raking back-stay to El Diente's rock and a solid gusset in the corner; under the deck, two broad
guide boards hung from the head beam that the counterweight (x −190.2, 1.6 wide, y 14.7 .. 27.9) and
the bucket (x −187.7, 1.2 wide) run in front of, broken off ragged at the foot (about y 12.4), with
iron guide straps. One structure joining the deck, the pillar and the run.

**What makes it a 9.** It is the lift's machine, plainly: the head beam and sheave read at 13.7 m;
a cast pug medallion on the head beam; a small pictogram plate (a pug in a miner's helmet, no words);
joinery you can see (tenons, wedges, rivets on the straps), chipped edges, a rotten corner on a guide
board, grease streaks under the bearing. **Note 4 is the rule:** it must not read as something to
climb: dark grey scenery timber (thread C's shade tones a step darker), broad and flat, no rungs, no
lattice, no thin line hanging; nothing honey. The counterweight (8) and bucket (8) must read in front.

**Standard:** `counterweight` (8), `hand_crane` (8), `stn_house` (9), the old gondola's carriage (9).
**Old:** none (the thrown-out scaffold tower and the cards of note 4 are what not to do). **Notes:** 4
("the mine gets its real look when that area is built to its design"), LOOKS_RATING 1.5 (3.5).
**Method:** timber and iron (thread C: `stn_c_lib.py` PAL, bench `peak_c_mine_bench.py` or
`stn_c_scene.py`).

**The sheet:** front; three-quarter; the game's camera at 13.7 m, true size and enlarged, with the
counterweight at its bottom (y 14.7) and at its top (y 26.7), with stand-ins for the counterweight,
the bucket, the deck, El Diente and a climber on the weight; high and low views (it crosses from the
deck back to the wall).

### E7. `mina_drift_portal` (NEW): Los Tablones's hero

**What and where.** The side drift the plank walk was built to reach, in the cavern wall behind 1.3:
at x −185.3, its foot y 5.65 (the walk's top is 5.75 .. 5.8 there), from z −1.3 (the walk's back
edge) to z −3.4 (into the wall's opening). Moved (−244.3, −11.35). Size 4.2 x 3.8 x 2.1. Origin: the
middle of its foot, z −2.35. Replaces `mine_boarded_tunnel` here and `mine_gangway_stub`.

**Layer and how it connects.** Background. Its gangway, on two bearers, meets the walk's back edge
(the play space, z −1.2); its frame stands in `mine_cavern_wall_mid`'s opening (x −186.4 .. −184.2,
y 5.6 .. 8.8). The wall lantern at (−185.3, 9.57) moves onto its cap.

**What makes it a 9.** A timbered portal (two posts, a cap, lagging boards round it), the town's pug
plaque nailed on the cap (the miners carved nothing), its door boarded with an X of planks and a
skull-pug warning plate; on the gangway a stub of rail coming out under the boards with a small ore
cart left on it, two crates and a tied sack; the town's papel picado faded over the door (its own
string model may hang there). Honest wear: rot at the posts' feet, a cracked cap held by an iron
strap, one gangway board gone. Scenery grey timber, no honey; the door and cart mid-dark at y 5.8 to
7.6 where the climber walks in front; the plaque above head height (y 8.4 and up); no red there.

**Standard:** `stn_house` (9), the plaza houses (recessed door with a 12 cm reveal, frame proud),
`minecart` (8), `crate_ore` (8), `dsc_shrine` (8). **Old:** start from `mine_boarded_passage` (7,
biome 0's arched boarded door: `source\build_mine_boarded_passage.py`) for the door. **Notes:**
LOOKS_RATING 1.3 (4) "nothing behind", 1.4 (4) "a free-standing door frame" (today's boarded tunnel).
**Method:** props (thread B: `stn_b_lib.py`) with thread C's timber tones (`stn_c_lib.py`).

**The sheet:** front; three-quarter; the game's camera at 13.7 m, true size and enlarged, at 1.3's
start and with a climber standing in front of it on the walk; high and low (the gangway crosses back
from the walk).

### E8. `winding_wheel` (REMAKE, start from it): La Polea Grande's hero

**What and where.** The mine's biggest machine: the winding wheel at the throat's foot, hub at
(−234.2, 57.4) (moved (−293.2, 40.4)), turning clockwise, a turn every 20 s; you take its rim at the
bottom and it carries you over the top. Its solid (a1.py line 376): radius 3.0, rim 0.18, six spokes
0.28 wide, hub 0.5. The contract today: made 3.2 across, origin the hub, scaled by the code
(`model_scale` 6/3.2); keep it, or make it at 6.0 if the fix thread drops the scale (part C, C11:
decide first).

**Layer and how it connects.** Play (a mover; its rim is held), with its axle running back from the
hub to z −2.1, where the `water_wheel` (on the same axle 1.5 m behind, turned by the falls) and the
frame's bearing (`mina_wheel_frame`, later) meet it: one machine through the depths.

**What makes it a 9.** A winding drum, plainly: the rim in timber segments joined by bolted iron fish
plates, a rope groove round it with a frayed cable end still wound on, iron rim bands, the six
spokes let into an iron hub, the pug face on the hub kept and made bolder; honey timber and
rust-orange iron (it is held), the paint chipped at the plates, worn bright where the cable ran. The
drawn rim and spokes are exactly the solid's (no drawing bigger or smaller than its solid: plan part
2, cause 6).

**Standard:** the old gondola (9: chips, medallion, grooved carriage), `counterweight` (8). **Old:**
start from `winding_wheel` itself (7.5: "spoked winding wheel with rust rim plates and a pug hub;
handsome"), `source\build_winding_wheel.py`. **Notes:** LOOKS_RATING 1.9 (6) "dark empty walls
around, the water is white squiggles on black" (the walls and the falls are other models and C2).
**Method:** timber and iron (thread C: `stn_c_lib.py`, bench `peak_c_mine_bench.py`).

**The sheet:** front; three-quarter; the game's camera at 13.7 m, true size and enlarged, with a
climber on the rim at the bottom and at the top and the staging's stand-in; the rim against its
solid's outline; high and low views (the axle joins the water wheel behind).

### E9. The timber stock family (REMAKE, one script, one session)

**What and where.** The mine's scenery timber at its stock lengths, laid at any angle by a1_dress.py's
`timber()` and stretched up to a quarter (about 80 placements: the gallery's posts and roof timbers,
the drowned sets, the shaft heads, the hangers, braces and struts): `mine_post_stub` 0.9,
`mine_post_short` 1.4, `mine_post_mid` 2.0, `mine_post` 3.0, `mine_post_tall` 4.75, `mine_post_long`
6.5, `mine_timber_long` 8.5 (posts: 0.35 x L x 0.35, origin the middle of the foot) and `mine_beam`
4.0 (0.35 square, origin the middle of its underside). Keep the contract (`_POSTS`, `_BEAMS` in
a1_dress.py).

**Layer and how it connects.** Background (and the front posts' family is separate, B8). Every piece
is part of a set: the dress rule that comes with it (part C, C9) is that no stick stands alone.

**What makes it a 9.** Square-set timber you believe: chamfered edges (one plane change), adze facets
on the faces in two close tones, a few long checks painted as lines, iron strap bands within 0.4 of
each end (scenery rust), sawn ends with growth rings and a chamfer, a darker wet band at a post's foot
in steps (not a gradient); `mine_post` keeps one pug plaque as the old one had, the others none (they
repeat). Grey scenery tones, never honey. Stretch-proof: every detail sits near the ends, nothing
round along the length, so 0.75 to 1.25 of a stretch distorts nothing.

**Standard:** `timber_set` (7), `hand_crane` (8), the plaza houses' joinery. **Old:** start from
`mine_post` (5.5, the Carpenter's 11-12 post: `source\build_mine_post.py`), recoloured to scenery grey;
today's stocks (`source\peak_c_mine2.py`, `build_mine_post_tall.py`) for their contract. **Notes:**
THINGS_RATING "a long plain grey stick" (x24, x13); LOOKS_RATING 1.7 "planks hang from nothing".
**Method:** timber and iron (thread C: `stn_c_lib.py`, `peak_c_mine2.py`); lengths are one parameter.

**The sheet:** the eight lengths in a row, front and three-quarter; the game's camera at 13.7 m, true
size and enlarged, as a gallery set (two posts and a cap) and as a hanger post in front of a mid-dark
wall; one stretched by 1.25 and one by 0.75.

### E10. `mina_tool_rack` (NEW): the miners' tool rack

**What and where.** Working furniture in three places: (a) the pillar's shoulder landing at 1.4/1.5,
(−199.4, 6.0), z −1.9 (moved (−258.4, −11.0)); (b) the camp by the waiting room, (−172.8, −12.6),
z −2.0; (c) the upper gallery, (−227.4, 57.4), z −2.0. Size 1.8 x 1.9 x 0.5. Origin: the middle of its
base at the foot, its back face at the wall.

**Layer and how it connects.** Background, standing on the floor behind the play space (nothing past
z −1.25), its back against the rock or lining.

**What makes it a 9.** Two uprights and a top rail of the mine's square timber, a peg row and a
trough at the foot; hung on it: two picks, a long shovel, a short shovel with its handle broken and
tied with cord, a sledge, three hand steels standing in the trough, a coil of fuse on a peg, a miner's
helmet with its cold lamp, and a lucha mask on the last peg (a climber's, left behind) in rosa
mexicano or turquoise; a pug-face tin plaque on the top rail; one peg missing. Scenery grey timber,
iron heads rust and dark iron, matte; small parts big enough to read at 13.7 m (or left out). Its top
under 1.9 m and its values mid, so the climber landing beside it at 1.4 reads.

**Standard:** `hand_crane` (8), `crate_ore` (8), `tea_tins_shelf` (7.5), the frogs (character).
**Old:** none; `pickaxe` (7, `source\build_pickaxe.py`) for the picks' heads. **Notes:** QUALITY_TO_9_PLAN
phase 2 ("working mine furniture on every ledge and wall ... a tool rack"); LOOKS_RATING 1.4 (4)
"empty wall". **Method:** props (thread B: `stn_b_lib.py`, bench `tools\stn_b_views.py`,
`stn_b_crop.py`).

**The sheet:** front; three-quarter; the game's camera at 13.7 m, true size and enlarged, on the
shoulder landing with a climber standing beside it.

---

## Where the plan above could be wrong (for the Director)

1. **The climb in the mine is mostly the shared fitted modules**, and THINGS_RATING did not rate them
   (it rates stems placed by the course; the fitted kit dresses solids by kind). Part of "the climb as
   things" depends on them. Rate them in phase 0 (B4 row 44); a remake there is mountain-wide.
2. **Note 146's draft moves the mine 17 m down as well as 59 m west**, and widens everything west of
   x −246 at every height (the throat too), not only the foot. Parker drew "slightly widening the falls
   area at the bottom". Worth confirming on the page; the Sump's floor goes to y −50, 10 m above the
   bug net.
3. **La Esclusa's ownership** (part D's question): settled, the mine's (part F).
4. **The house doc says gold is satin metal**; the quality standard and A2's zebra fix say no metallic.
   The briefs say matte for everything; HOW_WE_MAKE section 7 should be brought in line.
5. **The biome sheet's "glossy" black for what can't be held** predates the matte rule: it must be a
   painted sheen. The sheet's "no dark recess in a face" and the new standard's "painted openings"
   agree only if openings are painted or framed by real timber, as the briefs ask.
6. **Code-drawn things are in every frame and in neither rating:** the waterfall (note 111), the
   rope and chain looks, the falling rocks, the frozen climber, the hoistway cards, a1.py's picture
   cards. The reviewer should score them in the frames.

---

## F. La Esclusa and the cart ride's new incline, as a diorama

Note 146 is built (11-15; `docs/peak/playtest/WORK_LOG.md`, "The fix run of 11-15"). The mine moved 59 m
west and 17 m down. The cart ride (0.3) runs on down a 20 degree incline to the mine's moved door. La
Esclusa stands between the mine's roof and the black waters: **1.12 Los Barriles** (the keepers' ladder
beside the great falls, the flume, the barrels running west to the kicker) and **1.13 La Esclusa** (the
lock). All of it wears stand-in scenery. Part F plans its things to the standard of parts A, B, D and E.

**This settles part D's question.** Los Barriles and La Esclusa are the mine's. Parker numbered them 1.12
and 1.13 (note 146, Settled 11-14 15:30: "the black waters keep theirs"), and the fix thread wrote them into
a1.py as biome 1's (WORK_LOG 11-15, "Decided"). Part F also answers part B9, the join held for La
Esclusa's page: see F-B7.

**Coordinates.** Part F gives the GAME's numbers, as built on 11-15:
- La Esclusa's are a1.py's own (written after `A.end_shift()`, line 582, so they are not moved);
- the mine's are parts A to E's numbers (the course before the move) moved by (−59, −17) only (the extra
  6 m west of x −246 in this plan's header was dropped: Parker, 11-14 15:30, "do not actually widen the
  mine");
- 0.3's are a0.py's own.

Each place names the camera and the frame in `docs/peak/playtest/after/` it is seen from.

**What is there today** (`146_new_section.jpg`, `146_before_after.jpg` and the frames one by one):
- La Esclusa's back wall is one plain card (a1.py line 740) with two black cards for the chute and the
  tunnel.
- Its rock is the default dark cracked slab. The flume's bed and the lock's floor show pale through the
  water.
- The kicker is a red-orange bar. The ladder is drawn red, rails and rungs alike.
- The join's honey timber set and grey arch stand behind the alcove, and its foreground post stands over
  the climber at the ladder's foot.
- Seven lights stand in front of the play space and glare white on the roof's front face and the lock's
  gate.
- 0.3's new stretch is a bright tan cobbled bed and roof (unskinned rock) on a flat card that reads
  khaki-brown.

### The idea in one paragraph

La Esclusa is the company's lower works, a generation newer than the timber mine: cut stone, brick vaults,
riveted iron, the black waters' cold light, and the roar of the falls at its west end. The join is where
the mine's last timber set carries the works' first brick arch. Two sets carry its depth: the arcade
behind the flume, and the quay and the lock behind 1.13. Each paints its own view going back. The view
down the falls is the mine's cavern backdrop, already being made. Two heroes say what the place was for:
the broken barrel crane at the head of the falls, and the old frog who still keeps the lock (his haul on
his lever is the lock's warning). What you hold is the works' pale copings, the ladder's rungs and the
honey barrels. Everything else is dark-wet stone, slate brick and verdigris iron, so the barrels and the
water read first. The incline is the mine's: its lagging, its square sets, a winding house at the brow,
and a bed that is no longer bright tan. Fewer things, better made: 24 rows, 23 maker sessions, seven
stems out, and every 8.5 piece that fits reused.

### F-A. The places

For each place: what it is, the four layers, the things, what crosses the depths, and how the play
reads. Stems in `code` are F-B's rows, or part B's where a row number is given.

#### F-A1. The new incline, its foot and the door (0.3, x −148 .. −211)

- **Seen from:** the ride's camera (a0.py line 130: one zone over the whole tunnel, half height 4.6,
  following the cart): `146_0_3_incline_after.jpg` (the incline) and `146_0_3_end_after.jpg` (the end of
  the line: the cart at the buffer, the climber at the mine's door).
- **What it is:** the old haulage incline. From today's end of the line (x −148.4, road y −11.55) over the
  brow (x −158), 32 m of track at 20 degrees (to x −188, road y −24.7), easing out to the level end (x −200
  .. −211), the buffer (−209.3, −28.6) and the mine's door (x −211, the gallery's floor −29.6). The cart
  rides the incline in 3.5 s. You stand still only at the end, so the end of the line is the frame that
  must be a 9. It is now the mine's first frame after the station's 9.5.
- **Backdrop:** none at 12 m (a bored tunnel). Its far layer is inside the set: two side galleries painted
  going back through openings in the lining, sets in rows getting smaller, a lantern speck at the end (at
  the brow, x −159.0 .. −162.2; at the foot, x −194.0 .. −197.2).
- **Set:** `mina_ride_lining`: the mine's lagging in bays between the sets, stepping down with the road;
  smashed in the run-in (x −148 .. −158) with rock behind; the winding house's recess at the brow. At the
  door it meets `mine_lining_gallery` (8.5) with the same boards.
- **Hero:** the winding house at the brow (`mina_winding_house`): the haulage drum 2.6 m across on its
  timber frame, in a recess of the lining, with its brake band, its long brake lever, the brakeman's seat
  and the rope's frayed end still wound on. It says why the track is steep and why the cart runs free.
- **Things:**
  - the mine's square sets every 2.6 m (the timber stock family, 8.5: posts plumb, caps stepping down);
  - the skull-pug at the brow (`sign_pug_skull`, row 89);
  - a lantern at the brow and one at the foot (`lantern_hang` on `mine_lantern_bracket`, rows 79, 82);
  - at the end of the line, the buffer (`dsc_buffer_stop`, remade);
  - in the same frame, the mine's own: the door set (`mine_frame`, row 60), the ore chute's hopper over
    the rails just inside the door (`mine_ore_chute`, row 72), the first skull-pug, the gallery's lining.
- **The climb as things:** the rail bed and the roof (`mina_ride_bed`); the rails (`rail_straight`, as
  built); the buffer. The bed carries:
  - ballast between the sleepers, on dark rock;
  - the snapped haulage rope, lying flat between the rails from the brow sheave down to the foot;
  - the runaway catch, sprung open beside the far rail at the brow;
  - a little spilled ore at the foot.
- **Through the depths:**
  - The buffer is one thing: its baulk across the track (play) and its two braces raking back to the floor
    behind.
  - The sets stand at z −1.45 with their caps under the roof, and their bays are the lining's.
  - The rope's torn end lies at the brow sheave (play) and its other end is wound on the drum (background):
    one rope, snapped between, so nothing has to line up in the air.
- **Readability:**
  - Nothing here is held but the bed you walk on if you fall out: its top a step lighter than the walls,
    never today's bright tan; the rock under it and the roof dark.
  - The timber is the mine's one scenery grey. Today the door set reads honey orange beside the climber,
    so its remake (row 60) must be the scenery grey.
  - Nothing pale or red at the rider's height.
- **Today:** a bright tan cobbled bed and roof (the cave's slabs west of x −152.5 are unskinned, a0.py
  line 105) on a flat card (line 117, `#33291F`) that reads khaki-brown under the end-of-line glow. No
  sets, no lights.

#### F-A2. The keepers' ladder beside the falls (1.12's start, x −297 .. −290.5, y 73 .. 79.4)

- **Seen from:** the ladder's camera (a1.py line 733, x −297.5 .. −290, y 72.5 .. 80.5, half height 5.5):
  `146_cam_1_12.jpg`.
- **What it is:** La Cortina lets out at the top of its dry shaft (x −295 .. −291) into the low room under
  the platform (the lip room, x −295 .. −288, y 73 .. 75.2). Off the top row west onto the pier's coping
  (x −297 .. −295, y 73): 1.12 starts. Then up the keepers' iron ladder (x −295.4, 6.4 m, two rungs gone)
  in the falls' spray, onto the crane's platform (x −295 .. −290.5, y 79.4).
- **Backdrop:** behind the falls' column (x −303 .. −297) the shaft is open. There you see the top of
  `mina_backdrop_cavern` (E1, in flight): the falls dropping away past the mine's lit curtain into mist,
  the mine's lanterns warm dots far below, and at its top the falls coming out of the black waters' broken
  floor. The stand-in cards in front of it go (F-C6).
- **Set:** the west end of `esclusa_wall_flume`:
  - behind the ladder's strip (x −297 .. −295), black-wet rock, its edge returning back as the shaft's east
    side, ferns on one outcrop;
  - the lip room's back wall, with the works' first arch standing straight on the mine's last cap (the
    join, F-B7).
- **Hero:** the broken crane on the platform overhead (`esclusa_crane`), its snapped jib over the strip.
- **Things:**
  - the mine's last set at the dry shaft's top (the top frame of `mine_cortina_wall`, row 12, F-B7), with
    the mine's last amber lantern on its west post and La Cortina's rope strapped to its east post;
  - a works lantern on the crane's post, lighting the ladder (`aguas_works_lantern`);
  - the great falls themselves (code: note 111's 3D falls).
- **The climb as things:** the pier's coping (`esclusa_coping`), the ladder (`mina_iron_ladder`, row 24:
  one more run), the platform's coping.
- **Through the depths:**
  - The ladder's brackets run back from its rails into the platform's west face.
  - The crane's foot is bolted to the platform's coping behind the walk, and its back-stay goes into the
    arcade.
  - The last set is the throat wall's top frame, its posts sunk into the wall either side of the dry
    shaft; its cap carries the arch.
- **Readability:**
  - The rungs are rust-orange (held). The rails are a step darker (drawn, not held).
  - The two copings are pale. The pier's body, the platform's west face and the rock behind the strip are
    dark-wet.
  - The climber on the ladder has dark rock behind him, never the falls' glow. The falls are the one cool
    bright thing.
  - Nothing stands in front of the ladder, the falls or the pier's top. Today the join's foreground post
    stands over the climber at the ladder's foot; it goes (F-C4).
- **Today:** the ladder drawn red-orange, rails and rungs alike; the join's honey timber set with a red pug
  sign under a grey arch; a grey foreground post over the climber; brown cracked stand-in rock; a pale
  spray ball on the platform's block.

#### F-A3. The flume and the barrels' tunnel mouth (1.12, x −290.5 .. −258.5, y 75.7 .. 79.4)

- **Seen from:** the flume's camera (a1.py line 734, x −290 .. −258, y 75 .. 82.8, half height 6.0):
  `146_la_esclusa_after.jpg`, and tiles 0:07 and 0:13 of `146_new_section.jpg`.
- **What it is:** the company's barrel flume: 32 m of water (bed 75.7, surface 77.2) running west at 1 m/s.
  Eight barrels are born in the tunnel at the flume's head (x −261.8) and float west to the kicker (x
  −288.6). You cross east, barrel to barrel against them, onto the east landing (x −260.4 .. −258.5, y 79.4)
  and the quay.
- **Backdrop:** none at 12 m. Through the arcade's arches you see the vaults going back, painted inside
  `esclusa_wall_flume` (its far plane at about z −10): rows of brick vaults with the water running away
  under them, catching a lantern, each row darker and smaller.
- **Set:** `esclusa_wall_flume`: brick piers 1 m wide about every 6.5 m with round arches, cut stone in
  long courses below the springing, a level water band at 77.2 with a green band of growth, iron mooring
  rings at the waterline, seep lines down from the vaults' cracked crowns.
- **Hero:** the barrels' tunnel (`esclusa_barrel_tunnel`): the brick arch at the waterline (x −264.55 ..
  −259.05), its sluice gate jammed half raised so the barrels pass under it, black inside. It is where the
  barrels come from, and none is ever seen appearing (note 114). The section's two big heroes, the crane
  and the keeper, stand at either end of this run.
- **Things:** works lanterns on two piers and over the east landing (`aguas_works_lantern`); the crane at
  the frame's west edge; the roof's brick vaults overhead (`esclusa_vault`).
- **The climb as things:** the barrels (`aguas_barrel`, remade); the east landing (a member of
  `esclusa_coping`: a slab on two beam ends); the platform's coping at the west end.
- **Through the depths:**
  - Each barrel comes out of the tunnel's dark (z −3) into the play plane over 2.4 m: the tunnel's water
    channel runs from its back to the flume.
  - The landing's beam ends run back into sockets in the arcade.
  - The vaults spring from the piers' lines, so pier and vault are one arcade.
- **Readability:**
  - The barrels are honey with rust hoops, on mid-dark slate brick and dark water: warm on cool, so they
    read first.
  - The water's surface is a white line and its bed is dark under it. Today the bed's top face shows pale
    through the water, like a floor.
  - The brick is never pale. The mooring rings are dark iron, never rust-orange (they are not holds).
  - The vault is dark. Today the lights in front of the play space glare white on the roof's front face
    (F-C7).
- **Today:** a plain card with two black cards (the chute, the arch); cracked brown rock above and below;
  orange barrels that already read well.

#### F-A4. The kicker (x −291.4 .. −286.4, y 77.05 .. 82.2)

- **Seen from:** the flume's camera at its west end: `146_1_12_kicker_final.jpg`.
- **What it is:** the barrel men's tipping ramp. A loose barrel runs up it and is thrown up and back into
  the waste chute's mouth in the back wall (x −291.4 .. −286.4, y 78.6 .. 82.2), never into the falls. It
  is gone at y 79.6, 3 m back (a1.py line 693). You step down off the platform's east edge onto a barrel as
  it comes up to the ramp.
- **Backdrop:** none: the chute's inside is black.
- **Set:** the waste chute's mouth in `esclusa_wall_flume`: a brick-lined mouth, and a timber chute (the
  mine's leftovers) going back and down into the dark.
- **Things:** the tipping ramp (`esclusa_tipping_ramp`); the crane's post beside it.
- **The climb as things:** none. The ramp is not a step (F-C2 makes it slick).
- **Through the depths:** the ramp is one thing, from the water (play) up and back to the chute's lip (z
  −2.3). Its iron-shod face is exactly the board's line, and its trough carries on back into the chute.
- **Readability:** the ramp is black-wet with white water running down it, never pale and never
  rust-orange. A kicked barrel vanishes into black (the chute's inside all round it at y 79.6, z −3).
- **Today:** a red-orange bar (the board's own look: `model=""`, kind `iron`), right where you step down.
  It reads as a held step.

#### F-A5. The whirlpool and the pipe's alcove (x −291 .. −285.4, y 72.7 .. 77.5)

- **Seen from:** the flume's camera at its west end (the whirlpool) and the ladder's camera over the lip
  room (the alcove): `146_1_12_alcove_final.jpg`.
- **What it is:** fall into the flume and the current carries you west into a whirlpool 1 m east of the
  kicker (x −287.6 .. −285.4). A body under the water there goes down the pipe and out of its mouth in the
  alcove's east wall (x −288, y 73.1 .. 74.2), onto the alcove's floor (the old lip's grip, x −291 .. −288,
  y 72.7), 4 m from the ladder, to try again (a1.py lines 694 to 698).
- **Backdrop:** none (a room under the platform).
- **Set:** the lip room's back wall (`esclusa_wall_flume`'s west end), with the arch on the mine's last cap.
- **Things:**
  - the drain (`esclusa_drain`): the whirlpool's funnel of dark water with white foam at its rim, the
    grating in the bed under it, and the cast-iron pipe through the rock to its flared, riveted mouth in
    the alcove's wall;
  - the mine's last amber lantern, on the set.
- **The climb as things:** the alcove's floor (`esclusa_coping`'s alcove member, which takes the two drawn
  faces' job); the pipe's mouth, at the play space's edge.
- **Through the depths:** the drain is one run. The funnel is on the surface, the grating in the bed (z 0),
  the pipe goes down and west through the rock (seen where it crosses the alcove's back wall, so you know
  where it goes), and the mouth is in the alcove.
- **Readability:**
  - The whirlpool's eye is dark and its rim white: it reads as "down here".
  - The alcove's floor is pale (held). The pipe's mouth is dark iron.
  - The set is grey (today it is honey orange behind the climber).
  - No spray balls (F-C11).
- **Today:** the pipe is a white-edged channel cut through brown rock, and the old lip's pale grip runs on
  east under the rock (F-C5).

#### F-A6. The lock chamber and its gate, wicket and drain (1.13, x −245 .. −228, y 75.7 .. 89.4)

- **Seen from:** the lock's camera (a1.py line 735, x −258 .. −226, y 75 .. 89.6, half height 7.5):
  `146_cam_1_13.jpg`, `146_1_13_risen_final.jpg` (the water high), `146_1_13_high_final.jpg` (a rider
  near the top).
- **What it is:** a stone chamber 16 m long (x −244 .. −228, floor 75.7, roof 89) behind its lower gate (x
  −245 .. −244). Every 14 s:
  - the flap across the slot's foot slides open (the `compuerta` mover, at the roof, x −244 .. −238);
  - the river comes down the back wall, and the water rises from 77.2 to 88.5 in 6 s;
  - it holds 3 s, then drains through the gate's foot sluices in 5 s.

  You go in through the wicket (the `portillo` mover, open while the water is under its sill) and catch the
  rise on the sill (L0, x −244 .. −242.6, y 79.4). Then you swim across as it lifts you, or rest on L1 (x
  −239.6 .. −238.2, y 83.0), on L2 (x −229.6 .. −228.0, y 81.0) or on the east wall's three rungs. At the
  top you reach out of the old dry shaft onto El Borde's lip ledge (x −232, y 90).
- **Backdrop:** none at 12 m. Through the barred opening high in the back wall (x −241.5 .. −239.0, y 85.5
  .. 87.3) you see the river's culverts painted going back, lit teal far off (inside `esclusa_wall_lock`).
- **Set:** `esclusa_wall_lock`, the chamber's back wall: cut stone stained teal up to the highest water and
  green-black below the lowest, a scum line at 88.5, rust tracks down from the corbels' brackets, the
  slot's iron frame, the river's track down the wall.
- **Hero:** the frog keeper at his lever, in his booth on the quay (F-A7). His haul is the warning.
- **Things:**
  - the gauge board and its float (`esclusa_gauge_board`, on the back wall at x −231.4 .. −230.2): the
    float rides the water;
  - the flap (`esclusa_flap`);
  - works lanterns by L1 and over L2;
  - the river's white sheet down the back wall (the game's effect, a1.py line 730).
- **The climb as things:**
  - the lower gate and its wicket (`esclusa_lower_gate`: a riveted leaf from floor to roof, slick, with its
    foot sluices);
  - the sill, L1 and L2 (`esclusa_coping`'s three corbels, on iron brackets);
  - the three rungs (`iron_staple`, row 29, turned into the east wall);
  - the water;
  - the lip ledge (El Borde's, as built).
- **Through the depths:**
  - Each corbel's bracket runs from its coping (play) back into a socket in the wall, with a rust track
    under it.
  - The staples' legs go into the east wall.
  - The gate is one leaf, with a quay face and a chamber face; the wicket is a door in it.
  - The flap's runners go into the rock it slides into (a dark housing in `esclusa_vault`).
- **Readability:**
  - The water level reads at a glance: the surface's white line, the float on the gauge, the wall dark
    below the water.
  - The gate is black-wet. Today it reads pale cream, lit by the light in front of it.
  - The floor is dark. Today its top shows pale through the water.
  - The sill, L1 and L2 are pale copings on dark bodies. The rungs are rust-orange.
  - The gauge is mid: its marks mid, its float ochre. Nothing pale and nothing red behind a swimmer. The
    grating's teal glow is mid.
- **Today:** dark teal water in a plain box, two small dark ledges, the cream gate, a plain card behind, a
  pale floor.

#### F-A7. The keeper's booth and the quay (x −258.5 .. −245, y 79.4 .. 83)

- **Seen from:** the lock's camera at 1.13's start, the climber at (−249.3, 79.4): `146_cam_1_13.jpg`.
- **What it is:** the quay between the flume's head and the lock (13.5 m, a rest), where the barrel men
  worked, with the lock-keeper's booth set into its back wall.
- **Backdrop:** none. The booth's window looks onto the chamber.
- **Set:** the west part of `esclusa_wall_lock`: brick, the booth's recess (x −255.5 .. −251.5), the gate
  wheel's housing.
- **Hero:** the old frog keeper on his lever (`esclusa_keeper_lever`: frog and lever, one model) in his
  booth (`esclusa_keeper_booth`). The booth is a little stone room cut away at the front: a round-headed
  opening, a stool, a window onto the chamber, a spare oilskin on a peg, a kettle on a shelf, a works
  lantern and its painted glow. One second before each fill the keeper throws his weight back on the lever
  (F-C1). That is the warning, as every danger on the mountain warns before it acts.
- **Things:** the gate wheel (`esclusa_gate_wheel`, centre (−246.6, 82.1), above head height), which spins
  as the flap opens and back as it shuts; the booth's lantern.
- **The climb as things:** the quay's coping (`esclusa_coping`), the wicket.
- **Through the depths:** the wheel's shaft goes into its housing and on along the wall to the gate (bolted
  bearings, painted); the lever's rod goes down through the booth's floor to the gate's works.
- **Readability:**
  - The keeper is green against the booth's warm painted glow, in mid values.
  - He stands west of 1.13's start, so the climber waiting at the wicket never covers him.
  - The lever's knob is matte brass.
  - The wheel's pug is verdigris, above the climber's head (81.15), never bone-white behind him.
  - The quay's coping is pale.
- **Today:** a plain card; no keeper, no wheel; the quay's coping pale, with the fitted modules' pattern.

#### F-A8. 2.7's launch ledge and the west pool (x −320.5 .. −284, y 113 .. 117.4)

- **Seen from:** the Charco's camera (a2.py line 351, x −321 .. −284, y 113 .. 128, half height 8.5):
  `146_cam_2_7.jpg`.
- **What it is:** the great falls pour down through the black waters' pool hall (x −303 .. −297). From the
  launch ledge, Q6's west end flush with the falls (x −297, y 117.4), you swing out by your hands and let go
  across the falling water into the west pool (x −320.5 .. −303.4). The pool runs east over its sill into
  the falls (1.6 m/s at the sill), so you swim west at once.
- **Whose it is:** 2.7 is the black waters' challenge. Part F plans only what the falls broke: Q6's carried
  ledge and the two lips. Q6 has been plain since note 146 (WORK_LOG 11-15: its old 7 m skin went with the
  barrels). The hall, the gantry and its chains, Q7 and the frog's room stay with the black waters' pass.
- **Backdrop and set:** the black waters' (the well's far daylight on the pool).
- **Things:** the reservoir's floor, broken into the shaft (both lips in `aguas_launch_ledge`):
  - the west pool's sill, a worn stone lip with the white tongue pouring over it;
  - the east basin's, a cracked brick edge with a snapped beam end.
- **The climb as things:** Q6 (`aguas_launch_ledge`): the quay's stone coping carried 6 m west on two
  riveted iron beams to the falls' edge, its pale coping running right to x −297 where you hang. And the
  west pool.
- **Through the depths:** Q6's beams run from under its coping back into the hall's wall (z about −2.5);
  the broken floor's edges run back from the two lips.
- **Readability:** the launch ledge's coping is pale to its very west edge, and its beams are dark iron
  below. The lips are white water on dark stone. (One question for Parker, F-C11: the two sills are grip,
  `stone`, 0.3 m under the pool's surface.)
- **Today:** Q6 plain, 13 m long: the fitted modules' pale coping on a dark truss.

### F-B. The model list

One row per maker session, as part B (a family made by one script is one row). **Layer:** as part B; *S*
is a skin whose shape is the course's, *F* a skin whose shape is fixed. **Waits for:** the F-C item, or –
(it can start now). **When:** its place in F-D. Sizes are metres (w x h x d), approximate where new.

#### F-B1. The painted sets

| # | Stem | What it is | Layer | Size | Where; seen from | Now | Verdict | Waits for | When |
|---|---|---|---|---|---|---|---|---|---|
| F1 | `mina_ride_lining` | 0.3's new back wall: the mine's lagging in bays stepping down 17 m with the road, smashed in the run-in, the winding house's recess, two side galleries painted going back | bg | 63 x 23.6 x 2 (galleries to z −10) | x −148 .. −211; the ride's camera | new (a card) | NEW | – | 3 |
| F2 | `esclusa_wall_flume` | The arcade behind 1.12: piers, arches, courses, rings, seeps; the vaults painted going back; the waste chute's mouth and chute; the tunnel's opening; the rock behind the ladder's strip and the shaft's east side; the lip room's wall with the join's arch (absorbs `works_arch_low`) | bg | 38.5 x 13 x 8 | x −297 .. −258.5, y 73 .. 86; the ladder's and flume's cameras | new (a card) | NEW | – | 1 |
| F3 | `esclusa_wall_lock` | The quay's brick wall with the booth's recess and the wheel's housing; the lock chamber's wall: teal stain, scum line, rust tracks, the slot's frame, the grating on the culverts | bg | 36.5 x 16.4 x 8 | x −258.5 .. −222, y 73 .. 89.4; the lock's camera | new (a card) | NEW | – | 2 |

#### F-B2. The rock (skins)

| # | Stem | What it is | Layer | Size | Where; seen from | Now | Verdict | Waits for | When |
|---|---|---|---|---|---|---|---|---|---|
| F4 | `esclusa_mass_west` | The falls' two banks: the shaft's west side, the pier, the platform's block and its west face (where the ladder is bolted), the lip room's roof, the alcove's walls round the pipe's mouth | play, S | 20.6 x 10 x 2.4 | x −307 .. −286.4, y 73 .. 83; the ladder's camera | new (stand-in rock) | NEW | – (frozen from a1.json as built) | 19 |
| F5 | `esclusa_mass_low` | Under the floors: the flume's bed and channel (dark under the water), the quay's block, the lock's floor and its east wall up to the lip ledge's support | play, S | 68.5 x 16.4 x 2.4 | x −290.5 .. −222, y 73 .. 89.4; the flume's and lock's cameras | new | NEW | – (frozen as built) | 8 |
| F6 | `esclusa_vault` | The roof: transverse brick vaults over the flume and the quay springing from the arcade's piers, cracked at their crowns, seeping; the lock's lid; the flap's housing; the slot's and dry shaft's mouths | play, S | 64 x 6.4 x 2.4 | x −292 .. −228, y 83 .. 89.4; all three cameras | new | NEW | F-C3 | 23 |

#### F-B3. The climb as things

| # | Stem | What it is | Layer | Size | Where; seen from | Now | Verdict | Waits for | When |
|---|---|---|---|---|---|---|---|---|---|
| F7 | `esclusa_coping` (family) | The works' dressed stone you stand on, pale, with drafted edges and iron cramps, each on its dark body: the pier's top 2.0, the platform 4.5, the alcove's floor 3.0 (the old lip's grip), the east landing 1.9 on two beam ends, the quay 13.5, the sill 1.4, and L1 1.4 and L2 1.6 as corbels on iron brackets | play, F | lengths x 0.3 (bodies to 0.7) x 2.4 | all three cameras | new (the fitted modules; takes the jobs of `works_coping_face` 3 and `works_brick_courses_face` 5) | NEW | – | 18 |
| F8 | `mina_iron_ladder` (the keepers' run) | One more run of the mine's ladder (part B row 24): 6.4 m, rungs every 0.75 m with two torn gaps (76.05, 78.3), brackets bolted to the platform's face | play, F | 0.9 x 6.4 | x −295.4, y 73 .. 79.4; the ladder's camera | new (drawn red) | REUSE (row 24's session) | C6 | with row 24 |
| F9 | `aguas_barrel` | The company's barrel (mover x8): honey staves worn lighter on top where you stand, dark and wet below, crisp hoops, a bung, the company's pug branded on both sides (the camera never sees its ends) | play | 1.81 x 1.17 x 1.15 (contract kept) | the flume; the flume's camera | 7 | REMAKE (start from `barrel_float`, 7.5) | – | 7 |
| F10 | `esclusa_lower_gate` | The lock's lower gate: a riveted iron leaf from floor to roof, black-wet, slick, white drips, its foot sluices; and its wicket door (a second file: the `portillo` mover) | play, F | 1.0 x 13.3 x 2.4; door 0.9 x 2.5 | x −245 .. −244, y 75.7 .. 89; the lock's camera | new (reads pale cream) | NEW | – | 14 |
| F11 | `esclusa_flap` | The flap across the slot's foot (the `compuerta` mover): riveted plate black with water, iron runners, a cast pug boss | play | 6.0 x 0.35 x 2.4 | x −244 .. −238, y 89.0 .. 89.35; the lock's camera | new | NEW | – | 15 |
| F12 | `esclusa_tipping_ramp` | The kicker: a worn stone ramp, iron-shod, white water running down it, exactly on the board's line, its trough rising back to the chute's lip | cross | 3.1 x 1.6 x 3.5 (z +1.2 .. −2.3) | (−287.6, 77.05) .. (−290.4, 78.25); the flume's camera | new (a red bar) | NEW | F-C2 before it lands | 16 |
| F13 | `esclusa_drain` | The flume's drain: the whirlpool's funnel (white rim, dark eye), the grating in the bed, the cast-iron pipe through the rock to its flared, riveted mouth in the alcove's wall | cross | 3.2 x 4.6 x 2.4 | x −288.6 .. −285.4, y 72.9 .. 77.5; the flume's and ladder's cameras | new | NEW | – | 17 |
| F14 | `mina_ride_bed` (family) | 0.3's new bed and roof slabs: ballast between sleepers on dark rock, the snapped haulage rope lying flat from the brow sheave to the foot, the sprung runaway catch, spilled ore at the foot; the roof the mine's dark rock with the sets' cap sockets | play, S | per slab, x −148 .. −211 | the ride's camera | new (unskinned: bright tan) | NEW | – (frozen from a0.json) | 6 |
| F15 | `dsc_buffer_stop` | The end of the line: a timber baulk across the track, an iron-shod face, a pug plate, two braces raking back to the floor (a skin of the buffer's box) | cross | 1.7 x 0.8 x 3.4 | (−209.3, −28.6); the end-of-line frame | 4 | REMAKE | – | 20 |
| F16 | `aguas_launch_ledge` | 2.7's Q6 and the falls' two lips, one model drawn over three solids: the quay's coping carried 6 m west on two riveted iron beams to the falls' edge (x −297), the beams back into the hall's wall; the west pool's worn lip under its white tongue; the east basin's cracked brick edge and a snapped beam end | play, F | 19.4 x 4.4 x 2.4 (beams to z −2.5) | x −303.4 .. −284, y 113 .. 117.4; the Charco's camera | new (Q6 plain) | NEW | – | 22 |

#### F-B4. The heroes and the machines

| # | Stem | What it is | Layer | Size | Where; seen from | Now | Verdict | Waits for | When |
|---|---|---|---|---|---|---|---|---|---|
| F17 | `mina_winding_house` | 0.3's hero: the haulage drum 2.6 m across on its timber frame, its brake band and long lever, the brakeman's seat, the rope's frayed end wound on | bg | 5 x 4.4 x 1.8 | x −151.5 .. −156.5, foot y −13.0, z −2.0 .. −3.8; the ride's camera at the brow | new | NEW | – | 11 |
| F18 | `esclusa_crane` | 1.12's hero: the barrel crane: riveted iron post, foot plate with the pug, a hand winch, the jib snapped and wedged slanting west over the ladder's strip, the pulley on its tip | bg | 5 x 3.4 x 1.0 | post's foot (−292.5, 79.4), z −1.8; the ladder's camera | new | NEW | – | 5 |
| F19 | `esclusa_barrel_tunnel` | The barrels' tunnel at the flume's head: a brick arch at the waterline, the sluice gate jammed half raised, the walls and water channel running back into black | cross | 5.5 x 3.8 x 7 (z −2.2 .. −9) | x −264.55 .. −259.05, y 77.1 .. 80.6; the flume's camera | 4.5 | REMAKE (start from `aguas_barrel_cove`) | – | 9 |
| F20 | `esclusa_keeper_lever` | 1.13's hero: the old frog keeper in an oilskin sou'wester, on his lever's foot plate with both hands on its grip: frog and lever one model, turned 25 degrees about the pivot on the lock's clock | bg (moves) | 0.9 x 1.4 x 0.6 (frog 0.6, lever 1.3) | pivot (−253.2, 79.4), z −1.9; the lock's camera at 1.13's start | new | NEW (start from `frog_rain_hat` 9, `frog_stop`) | F-C1 for its frame | 4 |
| F21 | `esclusa_keeper_booth` | The keeper's booth in the quay wall's recess: round-headed opening, stool, window onto the chamber, oilskin on a peg, kettle on a shelf, the lever's quadrant in the floor, the lantern's painted glow | bg | 4.0 x 2.6 x 1.25 | x −255.5 .. −251.5, y 79.4 .. 82.0, z −1.35 .. −2.6; the lock's camera | new | NEW | – | 10 |
| F22 | `esclusa_gate_wheel` | The gate wheel: an iron hand wheel 1.4 across, a verdigris pug hub, its shaft into a housing; it spins with the flap | bg (turns) | 1.4 x 1.6 x 0.5 | centre (−246.6, 82.1), z −1.6; the lock's camera | 6.5 | REMAKE (start from `aguas_sluice_wheel_crusted`, the crust off) | F-C1 for its frame | 13 |
| F23 | `esclusa_gauge_board` | The gauge board, floor to roof: a pug at the top, a pug-head notch every metre (no numbers), two guide rails, and the float that rides the water (a second file) | bg (+ a float that moves) | 1.2 x 13.3 x 0.3 | x −231.4 .. −230.2, y 75.7 .. 89.0, z −1.75; the lock's camera | 6 | REMAKE (start from `aguas_depth_gauge`) | F-C1 for its frame | 12 |

#### F-B5. The light

| # | Stem | What it is | Layer | Size | Where; seen from | Now | Verdict | Waits for | When |
|---|---|---|---|---|---|---|---|---|---|
| F24 | `aguas_works_lantern` | The works' teal lantern (also 23 placements in the black waters): on the crane's post, two piers, over the east landing, in the booth, by L1, over L2 | bg | 0.28 x 0.48 x 0.28 | all of La Esclusa | 7 | REMAKE (light pass: the reviewer first) | – | 21 |

#### F-B6. Reused as they are (no maker session)

- **The timber stock family** (8.5 in the game): the new stretch's sets (about 23 of them, plumb, caps
  stepping down).
- **`mina_backdrop_cavern`** (E1, in flight): behind the falls' strip. Its top edge must run to y 84 there,
  with the falls coming down out of the black waters' broken floor at its top. Its brief's y 83 only just
  reaches: check on its sheet.
- **`iron_staple`** (row 29, as remade): the lock's three rungs, turned into the east wall.
- **The incline's furniture:** `sign_pug_skull` (row 89) at the brow; `lantern_hang` and
  `mine_lantern_bracket` (rows 79, 82) at the brow and the foot; two of the front post family (row 103) on
  the rock below the bed.
- **`rail_straight`** (5.5, the station's pass): the new stretch's rails, as built.
- **At the door:** `mine_frame` and `mine_ore_chute` (rows 60, 72), as the mine's pass makes them (the door
  set in the one scenery timber).

#### F-B7. The join: part B9's answer, and what leaves

The join is now the lip room: the mine's last timber set at the top of La Cortina's dry shaft, carrying
the arcade's first brick arch. Part B's rows held for La Esclusa's page are answered here, and one stem
of biome 0's that moved with the end of the line goes too:

| B row | Stem | Now | Where its job goes | Verdict |
|---|---|---|---|---|
| 105 | `timber_set` | 7 | The top frame of `mine_cortina_wall` (row 12): two posts sunk into the wall either side of the dry shaft (x −294.8, −291.2) and a cap with its top at y 72.95, in the one scenery timber. A free-standing set at z −1.45 would sit inside the wall once part C's C7c brings its face to z −1.3. Today its honey ochre and red sign read as held, behind the climber | REMOVE |
| 106 | `works_arch_low` | 4 | `esclusa_wall_flume`'s first arch, standing on that cap | REMOVE |
| 107 | `works_brick_pier_post` (and the timber post under it) | 3 | Not needed: moved to x −296.0 it stands in front of 1.12's start (note 40; `146_cam_1_12.jpg`) | REMOVE |
| 13 | `mine_lining_dry_shaft` | 2.5 | `mine_cortina_wall` (row 12) runs 4 m higher, to y 73 (26 to 30 m tall); its top 4 m are the dry shaft's plank lining on its frames, the last of them the mine's last set | REMOVE |
| 164 | `works_coping_face` | 3 | `esclusa_coping`'s alcove member | REMOVE (as part B10) |
| 165 | `works_brick_courses_face` | 5 | `esclusa_coping`'s alcove member | REMOVE (as part B10) |
| – | `dsc_door_sill` (biome 0's) | 2 | `mine_frame` carries its own sill | REMOVE |

So nothing in part D's "Held" group waits any more.

#### F-B8. Counts

| Verdict | Rows |
|---|---|
| NEW | 17 |
| REMAKE | 6 (one a light pass, to the reviewer first) |
| REUSE | 1 row (F8, inside row 24's session), plus F-B6's six groups |
| REMOVE | 7 (F-B7) |

So part F needs 23 maker sessions: 17 new and 6 remakes. Eight are skins: four whose shape is the
course's (F4, F5, F6, F14) and four fixed. All but `esclusa_vault` (F-C3) can start now. Part B's four
join rows (13, 105, 106, 107) leave, so the mine's whole pass needs at most 121 sessions (part B's 102,
less those four, plus part F's 23).

### F-C. Course changes for the fix thread

In order. Each says which models wait for it. Solids are free to change shape; the play is checked after.

- **F-C1. The keeper's warning, and the machines that show the lock working** (WORK_LOG 11-15, "Not done:
  the keeper's lever 1 s before each fill"). The warning comes from the frog and his lever.
  `esclusa_keeper_lever` is one model, frog and lever. The game turns it about its pivot:
  - 25 degrees back in 0.4 s, one second before each fill (at 13.0 s of the 14 s cycle);
  - held there through the rise;
  - forward again in 0.4 s as the flap shuts (5.6 to 6.0 s).

  With it go a clank of the lever's catch and the keeper's croak at the haul. Code: a deco turned on a
  clock (as the water wheel follows the winding wheel, a1.py line 566, but on the lock's cycle with a 1 s
  lead), or a small mover whose path is an angle. Two more follows go with it:
  - the gate wheel spins as the flap opens and back as it shuts (a follow of `compuerta`, "roll", as the
    pulley follows the counterweight, line 567);
  - the gauge's float rides the lock's water (a follow of the water's `lock` level).

  *Waiting:* the frames of F20, F22 and F23 (the models are made now).
- **F-C2. The kicker can't be stood on** (a1.py line 693). Its board's kind goes from `iron` (a held step,
  drawn as a red-orange bar where you step down onto the barrels) to `grease`, with
  `model="esclusa_tipping_ramp"`. The kick is unchanged: re-watch it with the `esclusa` probe (5 barrels
  kicked in 34 s, none into the falls). Optional: `gone` from 79.6 to about 78.4, so a kicked barrel drops
  behind the chute's lip instead of vanishing in its black mouth (judge it in the frame first). *Waiting:*
  F12.
- **F-C3. The roof becomes the cracked brick vault.** Over the flume and the quay, the roof's flat
  underside (y 83, and 86 over the quay) becomes a row of transverse brick vaults, one per arcade bay. They
  spring at the piers' lines at the old underside and crown about 1.2 m higher, cut into the roof's slab
  (`_section_rock`'s air, a1.py lines 646 to 650). Over the flume the piers' lines are about x −290.5,
  −284.4, −277.9, −271.4, −265.1 and −258.5. Nothing reaches the roof (the highest stand is a barrel's top,
  78.05), so the play does not change; check the lint and the cameras. The vault's front face then shows
  each arch's brick ring. *Waiting:* F6.
- **F-C4. The join's dress** (a1_dress.py, in the mine's shifted numbers).
  - Out: `mine_lining_dry_shaft` (line 682), `timber_set` (713), `works_arch_low` (714), the two drawn
    faces (718, 719), and the foreground post with `works_brick_pier_post` (721, 722: moved to x −296.0
    they stand over the climber at 1.12's start, `146_cam_1_12.jpg`).
  - Nothing new placed: `mine_cortina_wall` (row 12) carries the dry shaft's lining and the last set as its
    top 4 m. The side lantern (715) moves onto the wall's face (`THROAT_Z`) at the set's west post; the
    rope's strap (702) stays on its east post.

  *Waiting:* nothing; do it when row 12 and F2 land together, so the arch always has a cap to stand on.
- **F-C5. The old lip's grip** (a1.py line 493; moved, x −291 .. −284.5, top 72.7). Its east 3.5 m run on
  under La Esclusa's rock (which starts at y 73) in a 0.3 m slot, and show pale in
  `146_1_12_alcove_final.jpg`. Check the slot, then trim the ledge to the alcove (x −291 .. −288).
  *Waiting:* F7's alcove member.
- **F-C6. The cards out, and the falls' strip opened** (a1.py lines 740 to 745). The section's back-wall
  card and the chute's and tunnel's black cards go as F2 and F3 land. Behind the falls (x −303 .. −297, y
  73 .. 83) nothing may stand between the column and `mina_backdrop_cavern` (z −15). So the backstop card
  at z −11.6 (line 745) moves behind it, to about z −18, as the mine's does (part C, C8). *Waiting:* the
  frames of F2 and F3, and of F-A2.
- **F-C7. The lights onto their lanterns** (a1.py lines 736 to 739). The seven lights stand at z +1.6 and
  +1.8, in front of the play space, and glare white on the roof's front face and on the gate
  (`146_1_12_kicker_final.jpg`, `146_1_13_risen_final.jpg`). Each moves under its lantern, at about z −1.9:
  - the flume's four: the crane's post (−292.5, 81.5), two piers (−277.9, 81.5) and (−265.1, 81.5), over
    the east landing (−259.5, 81.9);
  - the lock's three: the booth (−253.5, 81.3), by L1 (−240.0, 84.7), over L2 (−228.8, 83.5).

  Colours and energies stay as they are, steady (note 17). *Waiting:* every La Esclusa frame.
- **F-C8. The life ring's block out of the falls** (a1.py lines 509, 510; moved, x −297.35 .. −296.75, y
  45.0 .. 46.05). It stands 0.35 m into the falls' column (x −303 .. −297), as it did in the old fall line.
  Before note 111's 3D falls (part C, C2), move the block and the ring 0.4 m east, and re-count note 15's
  drops (the throw is the same; it lands 0.4 m further east on the balcony). *Waiting:* the frame of
  `float_lifesaver` (row 43), and the 3D falls.
- **F-C9. Note 114, watched** (a1.py line 689). Each barrel is born 3 m back (`emerge` depth −3 over 2.4
  m), only 0.7 m behind the arcade's face, not 7 m as the page drew it. F19 is black from z −2.6 back.
  Watch in the game that none is seen appearing. If one is, the birth goes deeper (depth −6), with the road
  and the gaps as they are. *Waiting:* F19's frame.
- **F-C10. 0.3's new stretch dressed** (a0.py).
  - The slabs west of x −152.5 (line 105) wear `mina_ride_bed_*` and `mina_ride_roof_*` by place, as the
    old stretch wears `dsc_bed_a..d`.
  - The plain card (lines 116, 117) goes when F1 lands.
  - Placed: the stock family's sets every 2.6 m from x −148.4 to −207 (posts plumb at z −1.45, caps under
    the roof); `mina_winding_house` in its recess; `sign_pug_skull` at the brow; two lanterns (at the brow
    and the foot) with their lights in a0_dress's LANTERNS; two broken front posts on the rock below the
    bed (z about +1.4) at x −157 and −190, never in front of the cart.
  - `dsc_door_sill` goes.

  *Waiting:* the frames of F1, F14, F15 and F17.
- **F-C11. The rest, hooked up as they land.**
  - The keepers' run wears `mina_iron_ladder` (a1.py line 677; part C, C6).
  - The barrels wear the remade `aguas_barrel` (line 689).
  - Q6 (a2.py line 203) gets `skin="aguas_launch_ledge"`, and the same model is drawn on the two sills
    (lines 199, 200).
  - The flume's water draws the whirlpool as a turning foam ring and a dark eye over F13's funnel (the
    water's look, code). The mist there (a1.py line 698) goes: it shows as pale balls, which are phase 0's
    "floating spray balls".
  - **Ask Parker:** 2.7's two sills are grip (`stone`) 0.3 m under the pool's surface. Are they a last
    catch on purpose? If not, they go slick, and F16 paints them as wet stone under white water.

### F-D. The order

After the mine's first ten (part D: done or in flight). Chosen for the biggest lift first, heroes before
props, and for being free of F-C. La Esclusa's frames are stand-in cards and boxes today, about a 2 to 3.
The end of the line is the mine's first frame after the station's 9.5.

1. **`esclusa_wall_flume`**: the set behind both of 1.12's frames, and the join's arch.
2. **`esclusa_wall_lock`**: the set behind 1.13 and the quay.
3. **`mina_ride_lining`**: the end of the line, the mine's first frame after the station.
4. **`esclusa_keeper_lever`**: 1.13's hero and its warning (F-C1 runs beside it).
5. **`esclusa_crane`**: 1.12's hero.

Then, one model per session with many in flight, beside the mine's group 2:

6. `mina_ride_bed` (the bright tan bed and roof at the door);
7. `aguas_barrel`;
8. `esclusa_mass_low` (the flume's bed and the lock's floor reading pale through the water);
9. `esclusa_barrel_tunnel`;
10. `esclusa_keeper_booth`;
11. `mina_winding_house`;
12. `esclusa_gauge_board`;
13. `esclusa_gate_wheel`;
14. `esclusa_lower_gate`;
15. `esclusa_flap`;
16. `esclusa_tipping_ramp` (F-C2 before it lands);
17. `esclusa_drain`;
18. `esclusa_coping`;
19. `esclusa_mass_west`;
20. `dsc_buffer_stop`;
21. `aguas_works_lantern` (the light pass: the reviewer first);
22. `aguas_launch_ledge`;
23. after F-C3, `esclusa_vault`.

With the mine's group 2: the keepers' run (`mina_iron_ladder`, row 24's session).

Then as part D: each lands at 8.5 on its sheet, is synced, and is checked in a game frame of its place.
1.12, 1.13 and 0.3's end are scored as frames against the 9 with the rest of the mine, and Parker sees them
on the mine's one sheet.

### F-E. The maker briefs for the first five

Part E's shared rules hold for every brief here: one model; the house's look (matte, no emissive, no
text); what a 9 is; the mine's colours, the game's light and the one scenery timber; readability;
coordinates; the sheet; the methods. For La Esclusa, add:

- **The works' colours** (`docs\peak\playtest\design\data\a2_biome.py`, "built" and "looks"):
  - What you hold: pale stone copings, dry pale brick, rust-orange iron (the mine's `#B5532A`).
  - What you can't: black-wet brick and rock (the sheen painted, matte), greased iron.
  - Scenery brick: slate blue-grey, three or four close tones in long wavy courses, a step darker than any
    coping, never pale. Scenery iron: verdigris or dark iron, never rust-orange.
  - Water: black where it is deep, white where it breaks.
  - The company's pug is cast in the iron. There are no timber sets in the works: the mine's timber stops
    at the join (the barrels and the chute are its leftovers).
- **The light:** La Esclusa is in the mine's area, so the mine's measured light and the game's colour curve
  (part E) hold. Its lanterns are cold: blue-white `#9FD0FF` along the flume, teal `#6FE0D0` in the lock
  (a1.py lines 736 to 739, moving to the lanterns: F-C7). Bench in the mine's light and a metre from a teal
  lantern.
- **Coordinates:** the game's, as said at part F's top. There is no "today" pair: La Esclusa was never
  anywhere else.
- **The cameras:** La Esclusa's zones (a1.py lines 733 to 735: half heights 5.5 for the ladder, 6.0 for
  the flume, 7.5 for the lock) sit further back than the 13.7 m bench camera, so every sheet adds the
  zone's own view.

#### F-E1. `esclusa_wall_flume` (NEW, absorbing `works_arch_low`): the set behind Los Barriles

**What and where.** The back wall of 1.12, from the falls' shaft to the flume's head: x −297 .. −258.5, y
73 .. 86 (the roof is at 83 over the platform and the flume, at 86 over the quay's end). Its face, the
piers' fronts, is at z −2.2; the arches' backs at −2.6. Through the arches the vaults go back to a painted
far plane at about z −10. At its west end:
- behind the ladder's strip (x −297 .. −295) the face is black-wet rock at z −2.2, and its edge at x −297
  returns back to z −6 as the falls' shaft's east side (behind the falls themselves the shaft stays open);
- the lip room's back wall (x −295 .. −288, y 73 .. 75.2) steps forward to z −1.7, so the join's arch
  stands against it.

Size about 38.5 x 13 x 8. Origin: the middle of its foot, (−277.75, 73.0), z −2.2 (its face). It replaces
a1.py's stand-in back wall here and the chute's and tunnel's black cards (lines 740 to 744).

**Layer and how it connects.** Background, near.
- **The waste chute's mouth** (x −291.4 .. −286.4, y 78.6 .. 82.2): a brick-lined mouth with a timber chute
  going back and down into black. A kicked barrel is gone at y 79.6, z −3: it must vanish into black, with
  the chute's floor below it and the arch's soffit above.
- **The barrels' tunnel** (x −264.55 .. −259.05, from the water at 77.1 to its crown at 80.6): leave its
  opening, 4 cm clear round the arch's ring, for `esclusa_barrel_tunnel`.
- **The piers** stand at about x −284.4, −277.9, −271.4 and −265.1 (the tunnel's west jamb), with the head
  wall at −258.5. The roof's vaults (F-C3, `esclusa_vault`) spring from the same lines, so pier and vault
  are one arcade.
- **The east landing's two beam ends** go into sockets in its face at about x −260.0 and −258.9, y 78.6.
- **The crane** stands in front of it on the platform (z −1.5 .. −2.1), its back-stay into the face.
- **The join:** the works' first arch stands straight on the mine's last cap: the top frame of
  `mine_cortina_wall` (row 12), posts at x −294.8 and −291.2, cap top y 72.95, its face at the throat
  wall's face (z −1.3 once part C's C7c is done). The arch is x −294.95 .. −291.05, its face flush with the
  cap's and 0.4 deep, its crown under the lip room's ceiling at 75.2.

**What makes it a 9.** A place, not a slab: the company's brick arcade.
- **The form:** brick in long wavy courses of slate blue-grey; round arches whose rings stand proud (real);
  cut stone in long courses below the springing, with a level water band at 77.2, a green band of growth
  along it, black-wet below.
- **Through each arch:** the vaults going back, each row darker and smaller, the flume's water running away
  under them as a channel that catches a lantern, a lantern speck at the far end (painted, no emissive).
- **The west end:** the falls' shaft's east side, black-wet rock receding into spray, ferns on one outcrop;
  the lip room's wall with the join: timber below, brick above, a cast iron pug in the arch's keystone.
- **Three levels:** piers, arches, openings and the shaft's side; the rings, courses, the chute and its
  timber, the far vaults; seeps down from the vaults' cracked crowns, a hole where a handful of bricks have
  fallen out, a pier with a corner gone, rust runs under the mooring rings, ferns, the growth band.
- **Readability:** the barrels (honey) and the climber (bone) read in front: the brick mid-dark, no pale
  course, no red; the mooring rings dark iron (not holds); the chute's and tunnel's insides black; dark
  rock, never the falls' glow, behind the climber on the ladder.

**Standard:** the plaza houses (recessed openings with a reveal, the ring proud), `stn_yard_wall` (9),
`mine_lining_gallery` (8.5, the mine's passed wall). **Old:** `works_arch_low` (4, "grey brick arch with a
dark keystone; soft and washed out") for the join's arch; `aguas_barrel_cove` (4.5, "the opening is pure
void") for what an opening must not be. **Notes:** 146 (the pitch's "cut stone, iron rings, a cracked
brick vault"), 114, 21, 40; the frames `146_cam_1_12`, `146_la_esclusa_after`, `146_1_12_kicker_final`,
`146_1_12_alcove_final` (a plain card). **Method:** painted walls (thread A: `stn_a_paint.py`,
`stn_a_lib.py` `painted_model()` with `faces3d` for the rings, the reveals and the chute), the black
waters' wall method (`a2_biome.py` "built": courses as long wavy lines, level water bands, a few real
breaks); bench in the mine's light and by a blue-white lantern.

**The sheet:** front; three-quarter; the game's camera at 13.7 m and the section's own zones (the ladder's
at 1.12's start, the flume's at the kicker and at the east landing), true size and enlarged. Stand-ins for
the platform, the crane, the ladder, the falls' column, the flume's water, two barrels, the tipping ramp,
and a climber on a barrel and one on the ladder. A barrel caught at the chute's mouth at z −3, y 79.6: it
must sit in black. High and low views (the arches recede 8 m).

#### F-E2. `esclusa_wall_lock` (NEW): the set behind the quay and La Esclusa

**What and where.** The quay's back wall and the lock chamber's: x −258.5 .. −222, y 73 .. 89.4.
- **The quay's wall** (x −258.5 .. −245, y 79.4 .. 86, and to 89.4 east of x −252): brick, its face at z
  −2.2, with the booth's recess (x −255.5 .. −251.5, y 79.4 .. 82.0, back to z −2.6) and the gate wheel's
  housing (x −247.3 .. −245.9, y 81.2 .. 83.0).
- **The chamber's back wall** (x −244 .. −228, y 75.7 .. 89.4): cut stone, its face at z −1.9, behind the
  corbels' brackets.

Size about 36.5 x 16.4 x 8 (the culverts painted back to z −10). Origin: the middle of its foot,
(−240.25, 73.0), z −1.9. It replaces a1.py's stand-in back wall here (line 740).

**Layer and how it connects.** Background, near.
- The booth (`esclusa_keeper_booth`) fits its recess.
- The gate wheel's shaft runs into its housing, and on along the wall to the gate as a line of bolted
  bearings (painted).
- L1's and L2's iron brackets go into sockets at about (−238.9, 82.3) and (−228.8, 80.3), with rust
  tracks running down from them.
- The flap's iron frame sits at the slot's foot (x −244 .. −238, y 88.6 .. 89.4); `esclusa_flap` slides in
  front of it, west into its housing in the roof.
- The river's white sheet (the game's effect, x −244 .. −242.2, z −1.9) pours down this face under the
  slot: paint the wall wetter and greener there.
- The gauge board stands on its face at x −231.4 .. −230.2, on stand-offs (z −1.75).

**What makes it a 9.**
- **The quay's wall:** brick in long courses; the booth's round-headed opening with a stone surround and a
  worn step; a bracket for the booth's lantern; the wheel's housing a cast iron box with the pug.
- **The chamber:** cut stone in long wavy courses, stained teal up to the highest water (88.5) with a crisp
  scum line a step lighter than the stain (never pale), green-black below the lowest (77.2), and level
  bands between, where the water stands.
- **The barred opening** high in the wall (x −241.5 .. −239.0, y 85.5 .. 87.3): iron bars in a stone
  surround. Behind it the river's culverts are painted going back in rows, lit teal far off.
- **The slot's foot:** the iron frame and the flap's runners, and the river's track down the wall,
  white-streaked.
- **Three levels:** the planes (quay wall, chamber wall, opening); the stain bands, the booth's surround,
  the grating, the frame; courses, rust tracks, drips, the scum's crust, moss in the joints.
- **Readability:** mid values behind a swimmer at every height; the culverts' teal glow mid; nothing pale
  and no red; the water level reads against it (dark below the water, the stain above).

**Standard:** the plaza houses, `stn_yard_wall` (9), `mine_lining_gallery` (8.5). **Old:** none (a
stand-in card). **Notes:** 146 ("teal stone, ... a gauge board of the water level"), rule 6 (the machine
you can see); the frames `146_cam_1_13`, `146_1_13_risen_final`, `146_1_13_high_final`. **Method:** painted
walls (thread A), `faces3d` for the booth's recess, the grating's surround and the slot's frame; bench in
the mine's light and by a teal lantern.

**The sheet:** front; three-quarter; the game's camera at 13.7 m and the lock's zone, true size and
enlarged, with the water at its lowest (77.2) and its highest (88.5). Stand-ins for the gate, the corbels,
the rungs, the gauge and the booth, and a climber on the sill, one on L1 and one swimming at the top. High
and low views.

#### F-E3. `mina_ride_lining` (NEW): the back wall of the cart ride's new stretch

**What and where.** The new stretch's back wall, from today's end of the line to the mine's door. It is a
band 6.2 m tall (from 0.6 under the bed to 0.6 over the roof) that follows the rail bed from (−148, −12.0)
down the 20 degree incline (x −158 .. −188) to (−211, −29.6). Its face is at z −2.0, in place of a0.py's
plain card (line 117, z −2.7, `#33291F`). Size about 63 x 23.6 x 2; its recesses go deeper (the winding
house's to z −3.8, the two side galleries' painted depth to about z −10). Origin: the foot of its west end,
at the door (−211.0, −29.6), z −2.0.

**Layer and how it connects.** Background, near.
- In front of it, at z −1.45, stand the mine's square sets every 2.6 m (the timber stock family, 8.5:
  posts plumb, caps stepping down the incline). Its bays fit between them: leave a post's width at each set
  (every 2.6 m from x −148.4).
- Its recess at the brow (x −151.5 .. −156.5, a level floor at y −13.0, back to z −3.8) takes
  `mina_winding_house`.
- Two side gallery openings 3.2 m wide: at the brow (x −159.0 .. −162.2) and at the foot (x −194.0 ..
  −197.2), each timbered and painted going back.
- At its west end it meets the mine's door set (`mine_frame`, x −211) and `mine_lining_gallery` behind the
  door, with the same boards, so the ride runs into the mine without a seam. At its east end it meets the
  station tunnel's back wall (a0_dress, x −148).

**What makes it a 9.** The mine's lagging, as the gallery's.
- **The boards:** long flat bands in bays between the sets, following the slope, in the gallery's six close
  tones (`mine_lining_gallery`'s `#5E574E` family), grey and wet, green at the seams.
- **The run-in** (x −148 .. −158) smashed: boards burst and missing, rock showing behind, the old door's
  set left standing.
- **The two side galleries:** a timbered mouth (posts, cap, lagging), and inside, painted, sets in rows
  getting smaller into the dark with a lantern speck at the end (the stretch's far layer).
- **By the brow:** a chalk arrow and a worn skull-pug stencil on the boards.
- **Three levels:** bays and openings; reveals, frames, the recess, the galleries' depth; grain, nail rows,
  damp, and patches nailed across seams in their neighbours' tone (not pale plaques: the gallery's lesson
  in the game).
- **Readability:** mid values; nothing pale or red at the rider's height.

**Standard:** `mine_lining_gallery` (8.5 in the game), the plaza houses (recessed openings with a reveal),
`stn_house` (9). **Old:** today's card (a0.py line 117); the station tunnel's `dsc_back_wall_a..d` (3 to
3.5, "flat banding") show what not to do. **Notes:** 146 (the ride lengthened; the page's "side galleries
going back"), QUALITY_TO_9_PLAN phase 1 ("0.3: a painted tunnel receding"); the frames
`146_0_3_incline_after`, `146_0_3_end_after`. **Method:** painted walls (thread A: `stn_a_mine_walls.py`,
plank lining as flat bands; `faces3d` for the recess and the galleries' reveals; start from the gallery's
own `mine_lining_gallery_design.py`); `MINE_LIGHT=1`, and lit a metre from a lantern.

**The sheet:** front (the whole band); three-quarter; the ride's camera (half height 4.6, following the
cart) at the brow, mid-incline, and at the end of the line with the cart at the buffer and a climber
standing beside it, true size and enlarged. Stand-ins for the sets, the bed, the rails, the cart, the
winding house and the door set. High and low views.

#### F-E4. `esclusa_keeper_lever` (NEW): La Esclusa's hero, the old keeper at his lever

**What and where.** The old frog who still keeps the lock. He stands on his lever's foot plate in his
booth, both hands on its grip. Frog and lever are ONE model, turned by the game about the foot plate's
pivot. It stands at (−253.2, 79.4), z −1.9, in the booth (x −255.5 .. −251.5), west of 1.13's start (x
−249.3), so the climber never stands in front of him. The keeper is about 0.6 m standing: the house frogs
are 0.26 to 0.44 m, and he is the oldest and biggest on the mountain, the family's shape scaled, not a new
design. The lever is 1.3 m to its knob. Size about 0.9 x 1.4 x 0.6. Origin: the pivot (the middle of the
foot plate's axle), on the booth's floor.

**Layer and how it connects.** Background, behind the play space: its front at z −1.6, nothing nearer than
−1.3. The axle sits in an iron quadrant bolted to the booth's floor; the quadrant is the booth's (it stays
still). The lever's rod runs down through a slot in the floor to the gate's works. **The motion** (F-C1):
the game turns the whole model 25 degrees back (west) about the pivot, in 0.4 s, one second before each
fill. It holds through the rise and turns forward with the flap's clank. So the frog throws his weight back
on the lever: at rest he stands upright with his hands on the grip at his chin; hauled, he leans back 25
degrees with his arms straight and his heels on the plate. Model both poses' silhouettes to read; only one
file.

**What makes it a 9.** A house frog with a job and a history.
- **The frog:** the family's round body and big eyes (`frog_sit`; `frog_stop`'s standing body and legs from
  `stn_b_frogs.py`); an oilskin sou'wester (`frog_rain_hat`'s brim, in the works' oilskin yellow-ochre,
  matte) and a short oilskin cape; a brass whistle on a cord; mittens; one eye a little narrowed (he has
  done this for years), a set mouth.
- **The lever:** an iron rod with a turned knob (matte brass, the shine a flush lighter band), a ratchet
  catch with its trigger under his fingers, a foot plate with a cast pug.
- **A silhouette that reads at the lock's camera:** the sou'wester's brim, the cape, the lever's long
  line. The haul reads as a big change of angle.
- **Three levels:** frog, lever, plate; hat, cape, mittens, catch, knob; stitching, rivets, the plate's
  pug, a patch on the cape.
- **Readability:** mid values against the booth's warm painted lamp glow; the brass knob not pale; nothing
  red.

**Standard:** the frogs (`frog_rain_hat` 9, `frog_apron` 9, `frog_stop` and its sheet
`previews\frog_stop_review.png`), `forja_frog_smith` (9, a frog at his trade). **Old:** none; start from
`source\build_frog_rain_hat.py` and `source\stn_b_frogs.py`. **Notes:** 146 ("a frog keeper in a booth with
a lever"; the page's "one second before each fill he hauls it over: that is the warning"), WORK_LOG 11-15
("Not done: the keeper's lever 1 s before each fill"). **Method:** props and frogs (thread B:
`stn_b_frogs.py`, `stn_b_lib.py`, bench `tools\stn_b_views.py`).

**The sheet:** front; three-quarter; at rest and hauled (25 degrees) side by side; the game's camera at
13.7 m and the lock's zone, true size and enlarged, in a stand-in booth with a climber on the quay at
1.13's start; his hands on the grip in both poses.

#### F-E5. `esclusa_crane` (NEW): Los Barriles' hero, the broken barrel crane

**What and where.** The company's barrel crane, still standing on the platform at the head of the falls,
its jib snapped. Its post's foot is on the platform at (−292.5, 79.4), z −1.8, behind the climb (the
platform's walk is z −1.2 .. 1.2). Its head is at y 82.6, under the roof (y 83): nothing behind the play
space may pass the roof's line, because the roof's front face hides it. The jib is snapped near its heel.
Its broken length hangs from the heel's torn plates and slants down west over the ladder's strip, its tip
and pulley wedged against the shaft's east side at about (−297.3, 81.0), z −2.4. At the ladder (x −295.4)
it is at about y 81.6, above the reach of a climber at the ladder's head. Size about 5 x 3.4 x 1.0.
Origin: the middle of the post's foot.

**Layer and how it connects.** Background, standing on the play space's platform: its foot plate is bolted
to the coping's back half (z −1.5 .. −2.1), and a back-stay goes into the arcade's face (z −2.2). Its jib
crosses behind the ladder (x −295.4, z 0) to the shaft's side. A works lantern hangs from a bracket on the
post at about y 81.8, so the ladder is lit (`aguas_works_lantern`; the flume's first light moves there,
F-C7). One thing, from the platform to the wall.

**What makes it a 9.** It says what the place was for.
- **The post:** riveted iron (plates, angle flanges, rivet rows), a cast foot plate with the company's
  pug, and a hand winch on it with its crank, its drum and the chain's last links.
- **The jib:** the snapped stub with torn plates and bent rivets; the hanging length a solid plate girder
  0.35 deep with lightening holes (not a thin line); the pulley's sheave and cheeks at its tip; no hook.
- **Note 4 holds:** nothing thin hangs near the climb, and no tie rod. It must not read as something to
  hold or climb: scenery iron, verdigris and dark iron, never rust-orange (that is held iron in the works),
  with the lantern's light catching it.
- **Three levels:** post, jib, winch; plates, the sheave, the foot, the stub's tear; rivets, torn edges,
  verdigris runs, a chalk barrel tally on the post (the barrel men's, no words).

**Standard:** `hand_crane` (8, the station's), `mina_hoist_headframe` (8.5, the mine's passed machine:
joinery you can see, broad, not thin), the old gondola (9). **Old:** `aguas_crane_beam` (2, "thin dark
girder rod; invisible as an object") shows what not to do. **Notes:** 146 (the page's broken crane: "it says
what this place was for"), 4, 40; the frame `146_cam_1_12`. **Method:** timber and iron (thread C:
`stn_c_lib.py` PAL, bench `peak_c_mine_bench.py` or `stn_c_scene.py`), in the works' scenery iron tones.

**The sheet:** front; three-quarter; the game's camera at 13.7 m and the ladder's zone, true size and
enlarged. Stand-ins for the platform, the ladder, the falls' column (6 m, white), the roof's front face at
y 83, the arcade's face, and climbers at the ladder's foot and on its top rung. High and low views (it
steps back to the wall, and its jib crosses behind the ladder to the shaft).

### Where part F could be wrong (for the Director)

1. **2.7 is the black waters' challenge** (a2.py). Part F plans only its launch ledge and the falls' two
   lips. If Parker wants 2.7 whole in the mine's pass, its gantry, chains and hall are more rows.
2. **The keeper's size and haul.** At 0.6 m he is half again the house frogs' size, and he may read as
   another family. Turning frog and lever as one rigid model about his feet is my choice; the reviewer may
   want his arms to move.
3. **No new far backdrop.** The falls' strip relies on `mina_backdrop_cavern` (in flight) reaching y 84
   behind it. The arcade's and the lock's far views are painted inside their sets (at about z −10). If the
   reviewer marks the flume's frame down for "no painted backdrop", the page's "vaults going back" card (30
   x 8 m) is one more row.
4. **The vaults reshape a solid nobody touches** (F-C3). If the fix thread finds a move that reaches the
   roof, keep the flat underside and paint the vaults.
5. **Left out to stay lean:** the ore bins at the incline's foot (the mine's ore chute stands just inside
   the door) and the barrel men's rack of boat hooks and tally board on the quay. The end of the line and
   the quay rely on their other things.
6. **The winding house is seen for about a second** at 9 m/s, and the page asked Parker whether he wants it
   as the stretch's hero. Moving frames may also want bolder shapes than a still sheet shows.
7. **The gauge's place** (the chamber's east end, x −231.4 .. −230.2) is mine; the page put it on the back
   wall without a place.
8. **The light.** La Esclusa sits in the mine's warm measured light with cold lanterns. The colours must be
   benched in both, and the game may show them differently.
9. **The masses** (F4, F5) assume La Esclusa's rock stays as built. If the fix thread reshapes it beyond
   the vaults, they wait.
