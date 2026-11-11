# DEL MAR: the second mode (design, 2026-11-10)

Parker, 11-10: "we are making a second mode called Del Mar where the goal is to extend
outwards over the sea." This file is the one spec. The makers' briefs point here, and
the game code follows it. Parker's words are quoted where they set a rule.

## 1. The idea in one breath

Classic's 1v1 rotation, but the tower grows **sideways** out over the sea, a
climber bridge off the end of a pier, instead of up. The line is a **diagonal rope**
at 45°, from a buoy in the water up to a mast on the pier. To lock in you have to get
beyond it. Every lock moves the rope (and its buoy) further out. Fall in the sea and
you're out.

## 2. Getting there: the pan, and nothing loads until it's picked

- The plaza, title, lobby and every menu look exactly as now. **Nothing of Del Mar shows
  from them** (Parker: "You will not see any of this from the main screen or the lobby
  screens").
- When a Del Mar match starts, the camera **pans quickly to the right**, over to a
  beach town with a pier out into the sea. That's where the match is played. At the
  end of the match the camera pans back.
- **Loading** (Parker: "make sure to do that in a way that it is well optimized"):
  - Everything Del Mar sits in one scene, `res://stages/delmar/delmar.tscn`, built from
    its own kit parts: the beach town, the pier, the sea, the ships, the islands and the
    floaties.
  - It loads in the background (`ResourceLoader.load_threaded_request`) the moment Del
    Mar is picked as the mode, in Play Together or the lobby. It's instanced when the
    match starts and freed when the match ends or the mode changes. The plaza never
    pays for it.
  - The beach district's far end is built for one camera only, the one looking out to
    sea from the pier. No backs or sides that never show, and no mountains behind the
    sea (Parker: "It won't have the mountains in the background of the sea, but will
    need clouds floating around back there").

## 3. Where it is

- The Del Mar stage stands to the **right of the plaza**, along the same play plane
  (z = 0), at `DELMAR_X`. The Environment Maker proposes the exact offset. Far enough
  that the plaza's terraces and the beach town don't overlap, and near enough that the
  pan is a quick swoop, about 1 s (around 80 to 120 m).
- **The right side of the town shifts into a beach town.** The Environment Maker plans
  how the plaza's right-hand terraces give way to sand, palms, a boardwalk, huts and
  cabanas, so the pan reads as one place, not a cut.
- The sea fills the right of the frame, out to the horizon: ships, tiny islands and
  clouds. No mountains.

## 4. The pieces on the play plane (what climbers touch)

| Piece | What | Rules |
|---|---|---|
| **The pier** | A wooden pier from the beach out over the water. Its deck is the floor of play. | Solid. Its end is `PIER_END` (x). Deck top at `DECK_Y`, about 1.5 to 2 m above the water. |
| **The starting base** | One of the starting climbing objects (barrel, cactus, donkey, bell: the BASE setting), standing at the end of the pier. | Its rightmost point sits on the pier end ("At the end of the pier is one of the starting climbing objects, and the rope is to the right of that thing"). |
| **The mast** | A pole at the pier's back edge, left of the base, with the rope tied to its top. | Background dressing, behind the play area like the ring's back ropes (Parker 11-10: "the mast is dressing in the background, like the ring ropes behind the main area"). Never touched, and never in front of a climber. It GROWS as the game plays ("The mast gets taller as the game plays, line stays 45"): its top rises to wherever the rope must meet it (§5). The rope runs from the buoy back to it; the line's maths uses x and y only. |
| **The rope (the line)** | From the buoy up to the mast at 45°, hung with little dangling streamers (papel picado ribbons). | It IS the line. It's drawn, not solid: climbers pass through it. |
| **The buoy** | A buoy floating on the water where the rope meets it. | Solid, but **not weldable** ("You cannot weld to the buoy"). It sticks up a bit, so climbers near the water must get past it to lock in. It moves with the line and pushes floaties ahead of it (§7). |
| **The sea** | Golemheim's water (§8). | **Out** if you fall in ("your counted as Out if you fall off the tower into the water"). |
| **Floaties** | Beach balls, big rubber duckies, life savers and inner tubes bobbing on the water. | Bounce you **up and a little left** (back toward the tower) when you fall on them, like the ring ropes (§7). |

## 5. The line: a 45° rope that moves outward

- **Shape:** the rope runs up-left at 45° from the buoy (on the water, to the right)
  to the mast (on the pier, to the left). As a line on the play plane, its points
  satisfy `x + y = C`. The far side, `x + y > C`, is "over the line".
- **Where it starts:** "The rope starts .75 meters to the right of the end of the pier."
  `C` starts so that the rope passes 0.75 m right of the starting base's rightmost
  point at that point's height: `C0 = max over the base (x + y) + 0.75`.
- **How it moves:** "the line always being .25 meters to the right of the right most
  point of the climber tower". After each lock,
  `C = max over the whole tower, base included (x + y) + 0.25`. That's 0.25 m beyond
  the tower's furthest point along the rope's normal, measured horizontally. It never
  moves back.
- **The buoy** sits where the rope meets the water: `x = C - WATER_Y`. It glides out
  to its new place after each lock.
- **The mast grows:** its top, where the rope ties, rises to `y = C - MAST_X`, so the
  rope stays at 45° however far out it goes ("The mast gets taller as the game plays,
  line stays 45"). It extends in sections, a telescoping or stacking pole, with no
  height limit.
- **Lock in:** "You can lock in as long as you are anywhere over the 45 degree line."
  A climber locks in if any part of them is over the line (`x + y > C + LOCK_MARGIN`)
  while touching the tower, the pier or the base, the same touch rule as now (welds
  count). The buoy never counts as a support.

## 6. The round

- **"the same turn rotation as classic"**: Classic's 1v1 round robin. Both players in
  a round climb at once. A round ends when both have locked in or the clock runs out.
  Whoever ends it under the line, or in the sea, is out. The last one in wins.
- **Spawns:** "People will spawn standing next to each other towards the end of the
  pier, 3 meters apart": both climbers stand on the deck, 3 m apart, the nearer one
  about 2 m short of the starting base.
- **The chair:** "The Chair bubble will float to the right of the right most point
  instead of above the highest point." It floats about 1.5 m beyond the line, at the
  height of the tower's furthest point, bobbing as now.
- **The camera** follows as in Classic. It frames the tower's furthest point and the
  line, so as the bridge grows outward the view slides out to sea, widening to keep
  the pier's end in shot for a while.

## 7. Floaties

- **What:** beach balls, large rubber duckies, life savers and inner tubes (Parker's
  list), 5 to 8 in the water at once, drifting about at random on the play plane.
- **Bounce:** "bounce you up if you fall on them like the ring ropes, but they send you
  up and slightly left (back towards the growing climber tower bridge)". The same idea
  as the rope throw: a fall turns into a throw up at the ring rope's strength, plus a
  small push left (toward the tower), about 1.5 m/s. It only ever adds lift. Each
  floatie bobs, squashes a little and gives a rubbery squeak or boing when hit.
- **The buoy pushes them:** "The buoy passes through them as it moves, making them go
  to the left of the buoy." Floaties stay left of the buoy. When the buoy glides out,
  any floatie it reaches is shoved past to its left, bobbing as it goes.
- They're props with a simple bob and drift, not rigid bodies on the water's physics,
  so they stay cheap and the same on every machine. The host drives their positions and
  sends them on the pose stream.

## 8. The water: Golemheim's

"The water we will use is the same as with golemheim as it already has nice looking
collision and interactions with outlines." Also its splashes and sounds ("golemhiem
has splashes and sounds for the water we can use").

### 8a. What to bring over (from `SwordGame\`, surveyed 11-10)

- **The water is one script:** `scripts\water.gd`, an `@tool` Area3D. Both shaders
  are strings inside it: `SURFACE_SHADER` (swell, depth tint, refraction, cartoon foam,
  shore foam, up to 12 ripple rings, a fading rim) and `BODY_SHADER`. `_rebuild()`
  makes the collision, the body and a subdivided surface plane from its `size`,
  `cylinder`, `wave_height`, foam and rim settings. Golemheim's "Ocean" node in
  `scenes\maps\golemheim.tscn` (640 x 28 x 640, cylinder, rim_fade 35, wave_height 0.1)
  is a good starting setting.
- **The ink on the water:** the surface reads the outline pass's ink texture at
  SCREEN_UV and paints it over the water. Top Dog already has the same compositor
  (`shaders/cel/outline_compositor.gd` with `ink_texture()`, and `CelPass.ink_texture()`
  for exactly this), so only the bind is needed: hand the water material the ink
  texture and the line colour once the pass exists, retrying until it's valid. That's
  Golemheim's `cel_shading.gd` `bind_water_ink()`.
- **Splashes:** `water.gd` `splash()` makes toon puffs through `scripts\smoke_fx.gd`
  with `shadersx	oon_smoke.gdshader` and `toon_smoke_outline.gdshader`. There are no
  particle scenes and no textures. `ripple()` adds a ring to the surface.
- **Sounds** (`audio\sfx\`): `splash_big.wav` for falling in, and `splash_step_1..3.wav`
  for small splashes, such as floaties bobbing or a limb dipping. There are no wave or
  swim sounds. Waves can come later as an ambience loop.
- **To change on the way in:** Golemheim's `Sound.play_sfx_at` becomes Top Dog's
  `Sound.play_at`; the water's physics layer 256 and mask `1 | 16` become Top Dog's
  layers; `water.gd` preloads `smoke_fx.gd` and `cel_shading.gd`, so either bring
  those, or point them at Top Dog's `CelPass`.
- **In Del Mar** the water is the floor of "out": a climber's piece touching the
  water's top = in the sea (the out rule, like a ring out), with a `splash()`, a
  `ripple()` and `splash_big`, heard on every machine. The floaties and the buoy bob
  at its surface height.

## 9. The background

- **The sea**, out to a horizon line. Festive **ships** at anchor or drifting slowly
  (papel picado strung through the rigging, striped sails, lanterns). **Tiny islands**
  with festive things on them: a palm and a hammock, a little lighthouse with bunting,
  a band on a raft, a piñata tree. **Clouds** drifting (the house cardboard cut-outs).
- **The beach town** behind the pier: little huts, houses and cabanas in the house
  colours, umbrellas, a lifeguard tower, a boardwalk with string lights. It continues
  the plaza town's style, shifted to the seaside.
- **No mountains** over the sea.

## 10. Who makes what

| Maker | Designs (sheet first, no .glb until Parker approves) |
|---|---|
| **TD Environment Maker** | The district plan: where the beach town starts, how the plaza's right side shifts into it, `DELMAR_X`, the pier's place and length, `DECK_Y` / `WATER_Y`, the horizon, where ships, islands and clouds sit, the camera's frames (pan start and end, the match view), and the load boundary. |
| **TD Building Maker** | Beach huts, houses and cabanas, a lifeguard tower, the beach bar and stall fronts. Also the house **clouds remade** (§11). |
| **TD Carpenter** | The pier (deck, piles, rails, the end where the base stands), the boardwalk, the **mast** with the sliding ring, and the wooden ships' hulls and rigging. |
| **TD UI creator** | The buoy, the rope with its dangling streamers, the floaties (beach ball, rubber duck, life saver, inner tube), the Del Mar mode card and name in the menus, and the island dressing. |
| **Top Dog (Windy)** | The game: the mode row, the diagonal line, the lazy loading, the pan, the water, floaties, lock rules, the chair, spawns, out-in-the-sea, the batteries. |

## 11. Also from 11-10, not Del Mar

The clouds: no dowels (done in game, `cloud_stick` dropped), and **cardboard edges**
("add cardboard looking edges to the clouds, like the zig zag brown inside"). The cut
edge of each cloud shows corrugated cardboard: a brown zigzag flute between the two
paper faces. That's a remodel for the Building Maker, who made them.

## 12. Open questions for Parker

1. ~~The mast~~: settled. It grows as the game plays, and the line stays at 45°.
2. **Lock in from the water's side:** climbers far out near the water only lock once
   past the buoy. Should a climber dangling below the pier deck, but over the line,
   also count?
3. **The pan back:** at the match's end, pan back to the plaza for the results, or show
   the results at the pier?
