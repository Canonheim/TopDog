# The Peak's fitted kit: real things in place of blocks

Parker, 11-12, playing the climb: "see how these things are still just cuboids? They need
to be some kind of model. Like this could be a couple of wooden round poles sticking up
like a broken wooden bridge. The ground needs to look like a ground and the walls should
look like walls. This ladder should look like an actual broken rusted ish ladder with
rungs missing and some at angles, and instead of flat wooden posts, make it a metal ladder
with rungs that stick outwards like a bracket kind of shape. This brickwork should look
like an actual modeled brick platform. Have the building maker make these things as actual
stuff instead of just decorated blockouts." And of the mine's plank walkway: "like what
even is this? make this something instead of a bunch of blocks."

## How it works

The course is about 1,100 plain solids: boxes and polygons of a `kind` (wood, rock, brick
...). Until now the game drew each as a flat-coloured block with painted lines. Now the
game DRESSES each box in models from a small kit of modules, by its kind and its shape,
and scales and repeats them to the box (`stages/peak/peak_fit.gd`). The collision never
changes: the box in the course file is still what you hold and stand on.

So nobody models 1,100 things. The kit is a few modules per material, each made to a
NOMINAL size. A module that has not landed yet leaves its boxes drawn the old way; the
moment `kit/models/<name>.glb` exists, every box of that kind and shape wears it.

| Module | Nominal box in the play plane (x, y) | Depth (z) | Worn by |
|---|---|---|---|
| `cap` | 2.0 wide x 0.5 tall | -1.2 .. +1.2 | A thin horizontal piece you stand on: a ledge, a deck, a plank walk, a step. Repeated end to end along its length; stretched 0.67 to 1.33 along it and 0.5 to 2 in height. Also laid along the top of a thick floor |
| `cap_end` (optional) | 0.5 wide x 0.5 tall | -1.2 .. +1.2 | The RIGHT-hand end of a run of caps, where it ends in the open (the game turns it round for the left end) |
| `panel` | 2.0 x 2.0 | -1.2 .. +1.2 | A thick mass: a wall, a floor's body, a block. Repeated in a grid, both ways |
| `pole` | 0.4 wide x 2.5 tall | as wide as it is (round) | A thin upright: a post, a pier, a pillar, a stalagmite. Stretched in height, repeated if over 4 m |
| `bar` | 1.0 long x 0.12 thick | round, 0.12 | A thin bar under 0.3 thick: a peg, a rung, a rail, a rod. Lying along x |
| `hold` | fits a hexagon 0.25 in radius | -0.3 .. +0.3 | A single hold: a knob, a jug, a ring |

File names: `fit_<material>_<module>.glb`, with `_a`, `_b`, `_c` after it for variants
(the game picks among whichever exist, so a run of ledges is not one piece repeated).
Example: `fit_wood_cap_a.glb`, `fit_rock_panel_b.glb`, `fit_iron_bar.glb`.

## Rules for a module

1. **Origin at the middle of its nominal box**, x, y and z. Its outline in the play plane
   IS the nominal box: the top of a `cap` is the surface a climber stands on, at y +0.25,
   flat enough to stand on (bumps under 0.03). Dressing may pass the box by up to 0.08 at
   the sides and below, and NOT above the top face in front of z 0 (it would hide feet).
   Behind z -0.5 a cap may carry low dressing above its top (a tuft, a pebble, a nail).
2. **The front is +z** (the camera looks at it). The front face is the one that matters:
   model it, don't paint it. Bricks are bricks with mortar set back; planks are planks
   with gaps; a pole is round; rock has facets and ledges. The top face of a cap is seen
   too (the camera is often above it). Backs and undersides can be plain.
3. **Caps and panels butt.** Their left and right ends are flat at x -1.0 and +1.0 (a panel's
   top and bottom at y -1.0 and +1.0 too), and the pattern carries across the joint (a
   brick bond continues, a strata line meets). Variants must butt with each other.
4. **One mesh object and the one PALETTE material per file.** The game draws these by the
   hundred as instances: no child objects, no second material.
5. **Triangles:** cap and panel up to 400, pole 300, hold 150, bar 120.
6. **Colour.** Timber and iron are painted in their own atlas colours, pale and matte,
   because they are grip (wood near #C9903F with #B07A32 shade; iron near #B5532A; rotten
   wood pale and grey, #A99C86). **Rock, stone, brick, snow, ice and crystal are painted
   NEUTRAL**: pale greys only, #B8B8B8 to #FFFFFF, base #E6E6E6, no hue. The game multiplies
   them by each area's own colour, so one rock kit is brown in the mine, green-grey in the
   river and white on the glacier. Paint the depth with the greys: mortar and cracks
   darker, lit edges lighter.
7. **Nothing slick in a fit module.** When a box is slick the game draws the whole module
   in its own wet material (mud brown, indigo glass or black ice). So the rock kit is also
   every wet wall, and the crystal kit is the slick glass.
8. Applied transforms, the z-fight check, `land.sh`, as for every kit piece.

## Tier 1 (the mine, the temple, the ladder: what Parker pointed at)

| File | What it is |
|---|---|
| `fit_wood_cap_a`, `_b`, `_c` | A length of plank walkway seen from the side: boards laid across a side beam, their ends showing, a gap or a nail here and there. Each variant a different run of boards |
| `fit_rotten_cap_a`, `_b` | The same walkway's rotten boards: grey-pale, cracked through, sagging, a corner gone. These are the pieces that break under you, so they must read as "this will not hold long" |
| `fit_wood_pole_a`, `_b` | A round timber pole, bark off, a split down it, an iron band; `_b` has a snapped, splintered top (a broken bridge's pier) |
| `fit_wood_bar` | A round wooden peg or rung, slightly crooked |
| `fit_rock_cap_a`, `_b`, `_c` | GROUND: the top half metre of a floor or ledge. A trodden top (packed earth, a few flat stones set in it, pebbles toward the back), a broken stony lip along the front edge, the rock under it in rough courses |
| `fit_rock_cap_end` | The broken end of a rock ledge: it thins and crumbles off to the right |
| `fit_rock_panel_a`, `_b`, `_c` | WALL: a rock face. Big faceted blocks and slabs, a ledge line or two, a crack, strata that meet across the joints. Not a flat sheet with lines |
| `fit_rock_pole_a`, `_b` | A rock pillar or stalagmite-like column, lumpy, wider at its foot |
| `fit_rock_hold_a`, `_b` | A rock knob you would grab: a jug with an in-cut top |
| `fit_brick_cap_a`, `_b` | A brick platform: real bricks in a running bond, mortar set back, a soldier course or a stone lip along the top front, one or two bricks chipped or missing |
| `fit_stone_cap_a`, `_b` | A carved temple slab: big dressed blocks, a moulded lip along the top front, a carved band (steps, a paw, a mask's eye) on the face |
| `fit_stone_panel_a`, `_b` | A temple wall: coursed big blocks, tight joints, one carved block in `_b` |
| `fit_stone_pole` | A stone pier: drum sections, a square cap and base |
| `fit_iron_cap_a`, `_b` | A riveted iron deck: a plate on an I-girder, rivet rows, a rust streak |
| `fit_iron_pole` | An iron pipe or column with a flange |
| `fit_iron_bar` | A round iron rod with a collar at each end |
| `fit_iron_hold` | A ring bolt: a forged ring through an eye plate |
| `fit_ladder_rung` | A BRACKET RUNG, the ladder Parker asked for: a round iron bar 0.9 long and 0.09 thick, standing out toward the camera on two short arms that turn back to the rails (a staple, seen from above). The bar is the hold: origin at the middle of the bar, the bar along x at z +0.22, the arms running back to z -0.2. Rust on it |
| `fit_ladder_rung_bent` | The same rung broken: one arm torn free, hanging down at about 60 degrees from the other. Dressing only (nothing holds it), a little darker |
| `fit_ladder_rail` | An iron ladder rail, 2.0 tall, 0.07 across, round tube, a bolted joint collar in it, rust. Stands at z -0.2 (behind the rungs' bar). Repeats upward |

## Tier 2 (after tier 1 is seen in the game)

| File | What it is |
|---|---|
| `fit_crystal_cap_a`, `_b`; `fit_crystal_pole_a`, `_b`; `fit_crystal_bar`; `fit_crystal_hold` | Crystal: hexagonal columns lying and standing, frosted faces (neutral: the game tints) |
| `fit_snow_cap_a`, `_b` | A snow ledge: a soft rounded top, a curled lip, icicles under it at the back |
| `fit_ice_cap`, `fit_ice_panel_a`, `_b`, `fit_ice_hold` | Glacier ice: fractured blocks |
| `fit_bone_hold`, `fit_bone_bar` | A knuckle of bone; a rib |
| `fit_root_cap`, `fit_root_hold` | A thick root lying across; a burl |
| `fit_gill_cap` | A shelf fungus's top |
