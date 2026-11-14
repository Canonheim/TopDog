# The Peak's water: cheap fluid methods, and the one proposed

For playtest note 22. Parker, 2026-11-13, on the first overhaul: "Still not water". What is
wrong: "Looks like a glass block", "Falls are wrong", and: "Lets look up some good cheap
fluid simulations we can use for it. It only has to be visual, the physics and feel were
working well already, but it can be both if you can make it nice. Research it and figure
out a good implementation".

This is a proposal. Nothing is built in the game. A moving demo of the method is beside
this file: `water_demo.html` (serve the folder, or the `peak-water` preview, port 8772).

## What exists, cheapest first

| Method | What it gives | Cost | Fit here |
|---|---|---|---|
| **A row of springs** for a pool's surface: one spring per column, each pulled to its rest height and tugging its neighbours | Real waves: a splash where a body goes in, a wake, sloshing that dies away | A few hundred numbers per pool, a few passes a frame. Nothing | The standard for side-view games. The water stays exactly where the swim rules are. Cannot pour |
| **Loose droplets drawn as one shape** ("metaballs"): each droplet is a soft dot in an off-screen picture; one cut through that picture makes touching dots melt into a single clean shape, and the cut's edge is the ink line | Water that pours, runs along things, drips off edges, splashes and rejoins. A cartoon look for free | A few hundred to a couple of thousand points falling under gravity and sliding on solids; one extra low-resolution picture a frame | Good for everything that is NOT a pool: falls, spills, splashes, drips |
| **A true particle fluid** (SPH or position-based, on the graphics card) | Water that really sloshes, fills and drains | Tens of thousands of particles, a compute pass; an MIT Godot 4.6 add-on does 3D SPH this way and claims 32,000 particles on a mid-range card | The water would go where the simulation takes it, not where the swim rules are: 14 pools would have to hold their levels, not leak, and match the rules box for box. Heavy to tune, and a 2D one would have to be written |
| **A grid fluid** (stable fluids, or shallow water in columns with "virtual pipes") | Smoke-like flow, or water finding its level over terrain | A grid solve every frame | Made for top-down terrain or smoke. Not a side view |

## Proposed: springs for the pools, droplets for everything that moves

The two cheap ones together; it is the long-standing recipe for 2D water (the Tuts+ article
below builds exactly this pair and fuses the droplets with the surface). The rules stay as
they are: currents, buoyancy, the swim. Only what is drawn changes.

**1. The pool is a solid cartoon body, not glass.**
- Drawn opaque behind the play plane, in two or three flat tones (a bright band under the
  surface, the body, the deep), tinted per cave as decided. A thin wash of the same colour
  in front of the play plane (about 40 to 50%) is what makes the climber read as IN the
  water. Today the whole body is see-through (0.42 to 0.74), which is the glass block.
- Its top edge is the row of springs, one every 0.15 to 0.25 m, inked. No ruled line.
- The springs are pushed by: a body going in or coming out (size by its speed), limbs
  moving under the surface, barrels and planks riding it, the foot of a fall (a constant
  churn), the mill wheel's paddles. The current leans the ripples downstream.
- At a lip the springs' rest height drops toward the edge, so the surface visibly bends
  over into the fall.
- In the game: per body a small array stepped each physics tick (only for bodies near the
  camera), handed to the body's shader as a one-row texture; the mesh's top row is moved in
  the vertex shader, so no mesh is rebuilt. `_body_vis` in `stages/peak/peak_zones.gd`
  already makes one body per connected stretch; this replaces its front and its surface.

**2. Everything that pours is droplets.**
- Each fall sends droplets over its lip at the pool's own speed, across the pool's depth.
  They fall under the drawn gravity the falls already use (`FALL_G`), land on the course's
  solids, slide along them and leave at their edges: water that pours off things.
- Reaching a pool, a droplet is gone and its push goes into that pool's springs, with a
  few small droplets thrown back up.
- The same droplets serve splashes (a climber or a rock going in), the climber dripping on
  the way out, the wheel shedding, a channel overflowing.
- Drawn: all droplets as soft dots into one off-screen picture at about half resolution,
  with the pools' tops drawn into the same picture so loose water melts into the pool. A
  single flat card at the play plane cuts it: under the line nothing, at the line ink,
  above it water, white where it is thick. One atlas-free shader, no emissive.
- In the game: a few hundred live droplets per fall on screen, stepped in script against
  the area's own solids (`peak.things._rock` rows near the fall); a MultiMesh draws them
  into a SubViewport. If script stepping costs too much, `GPUParticles3D` with box
  colliders made from the same solids is the fall-back (this project renders Forward+,
  which supports particle collision), at the price that droplets can no longer push the
  springs one by one: the fall's foot would churn by the clock instead.

**3. "It can be both if you can make it nice."** A later step, after the look is right:
floating things take their height and tilt from the springs under them (the demo's barrel
does), and a big wave can give a small shove. The currents and the swim stay rule boxes.

## Order of work, when Parker says build

1. One pool and one fall, the two in his note 22 pictures (the flume and the cascade at
   118 m), with before and after frames and a short clip.
2. On his yes: the other 13 stretches and 5 falls, the wheel, the dam's leak, the drips.

## Unknowns

- How the inked edge of the droplet card sits with the game's own outline pass (the sea at
  Del Mar replays the ink onto its surface; the pools use the same surface today).
- Script cost of stepping droplets when two falls are on screen at the pulled-back camera.
- Whether an opaque body hides anything a challenge needs seen under water (the barrels'
  cove, the two swims).

## Sources

- Tuts+, "Make a Splash With Dynamic 2D Water Effects" (springs for the surface, droplets
  fused by an alpha cut): https://code.tutsplus.com/make-a-splash-with-dynamic-2d-water-effects--gamedev-236t
- John Wigg, "A simple Method for creating 2D Metaballs" (Godot; soft dots into a viewport,
  a cut and a small colour ramp): https://john-wigg.dev/2DMetaballs/
- prime31, "Modeling 2D Water with Springs": https://prime31.github.io/water2d-part1
- Godot asset library, "3D SPH Fluid Simulation" (MIT, compute shaders, Godot 4.6):
  https://www.godotengine.org/asset-library/asset/5116
- Godot asset library, "Fluid-water physics 2D simulator for Godot 4+" (physics bodies, a
  work in progress): https://godotengine.org/asset-library/asset/2951
- Godot docs, 3D particle collisions: https://docs.godotengine.org/en/4.3/tutorials/3d/particles/collision.html
- Dagenais et al., "Extended virtual pipes for the stable and real-time simulation of
  small-scale shallow water": https://profs.etsmtl.ca/epaquette/Research/Papers/Dagenais.2018.cg/
