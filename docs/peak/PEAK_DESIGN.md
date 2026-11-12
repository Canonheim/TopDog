# THE PEAK OF DEGAYO: the solo climb

Top Dog's solo mode. One climber, one mountain, 1,000 m, no checkpoints.
Parker's brief (2026-11-11) is quoted at the bottom. This file is the design bible:
the world, the rules, the areas, the falls, the look, the sound. The 111 challenges are
in `CHALLENGES.md`. How course data is written is in `AUTHORING.md`. What the makers
build is in `PARTS.md`.

## 1. The idea in one paragraph

Every luchador in town says they'll climb the Peak of DeGayo. The mountain is full of
the ones who tried. You ride a minecart into its roots, climb the old mine, the flooded
works, a crystal grotto, a mushroom garden and a buried temple of the First Top Dog, get
blown out of a steam chimney onto the cliffs, cross a broken cableway to a rock fang,
climb a glacier and a storm ridge, and ring the Champion's Bell at 1,000 m. The whole
mountain is ONE cross-section. Caves sit under cliffs, a bottomless well runs up through
the middle, and everything that falls ends in the same black river. Nothing is a
separate level, so a fall takes you somewhere real, and you can see where.

## 2. What the climber can do (measured, `tests/peak_probe.tscn`)

| Measure | Value |
|---|---|
| Height standing | 1.80 m |
| Standing reach, hand straight up | 2.13 m |
| Arm length (shoulder to hand) | 0.69 m; leg 0.85 m |
| Gravity on a climber | 2.79 m/s² (a 100 m fall takes 8.5 s and lands at 24 m/s) |
| A pumped one-hand swing, 2 s | about 3.5 m/s: 4-5 m out |
| ... 3 s (the body goes right round the grip) | 8 m/s: 23 m out, or 11 m straight up |
| ... 4.5 s | 14 m/s: 57 m out, or 33 m up |

- **Hands and feet stick by themselves to anything grippable**, on contact, at any
  speed. A press picks a limb up, the stick aims it, letting go plants it.
- **A fling is a swing about ONE grip, then letting go.** Spin-up has no ceiling but
  time and nerve, so distance is never the real limit. The limits are the release
  angle, what you hit on the way, and what you can catch.
- **A catch is automatic** if a free hand or foot touches a grippable surface. So a
  target's SIZE and what surrounds it set the difficulty.
- A surface with the meta `no_weld` can't be gripped and doesn't count as ground.
  That one flag is the whole "slick" rule.

**The fling tiers the course is laid out on** (same height / straight up):

| Tier | Gap | Rise | Used |
|---|---|---|---|
| F1 | up to 4 m | 2 m | the mine, teaching |
| F2 | up to 8 m | 4 m | from the river on |
| F3 | up to 13 m | 7 m | from the crystal grotto on |
| F4 | up to 20 m | 10 m | the cableway and above |
| F5 | up to 28 m | 13 m | three or four times in the whole game |

## 3. The laws of the mountain

1. **Dark and wet means no.** Anything you can't grip is dark, glossy and wet: black
   mud, wet stone, slime, glass-smooth crystal, grease, blue-black ice. Anything you
   can grip is dry, pale, matte and textured: timber, rope, chalky rock, iron rungs,
   carved stone. No exceptions, ever: the player reads the wall by its colour.
2. **No checkpoints.** The game saves where you are, all the time. Quitting keeps your
   place. Falling keeps your place too: the place you fell to.
3. **Every fall is physical.** No kill planes, no respawns. You tumble down the real
   mountain and land somewhere lower. (One safety net exists for bugs only: leave the
   world's bounds and you're put back at your last firm hold.)
4. **Nowhere is quite safe.** Every rest ledge has something: a drip that slicks the
   lip, a gust, a plank that creaks. Never enough to kill a resting player, always
   enough that they don't relax.
5. **You always see what a miss costs before you jump.** The camera pulls back at
   every big fling, and the drop under it is lit.
6. **One new idea at a time.** Each area teaches its mechanic on a small safe drop,
   tests it over a real drop, then twists it with an old mechanic.
7. **Mercy is designed, not accidental.** Long drops have slick walls so you can't
   claw your way out of the consequence. But each of the great falls has ONE last
   chance (a chain at the waterfall's lip, a shrub on the Balcón's edge), small enough
   to be a story when it works.

## 4. The mountain (local coordinates, metres)

Local (0, 0) is the trailhead at the edge of town. **x is negative into the mountain
(left), y is altitude.** World position = local + `PEAK_ORIGIN` (-110, -0.9).

```
 y
1000 ........................ A11 LA CUMBRE (the bell)         x -350
 960 ..................... A10 LA CRESTA DE LA TORMENTA
 884 .................. A9 EL GLACIAR
 784 ............... A8 EL TELEFERICO ======cable====== EL COLMILLO (rock fang)
 684 ............ A7 LOS RISCOS DEL VIENTO (east face)        |  |
 580 ......... [El Balcon]--------.                            |  |
 478   A5 TEMPLO  | P |  A6 LA CHIMENEA \   <- La Garganta ->  |  |
 372   (west)     | O |  A4 JARDIN        \  (the throat)      /  \
 270   A3 GRUTA   | Z |  DE HONGOS (east)  \________   _______/
 176   (west)     | O |                             \ /
  86   A2 LAS AGUAS NEGRAS  <--- river flows east   <--- El Tobogan (slide tube
 -30   A1 LA MINA VIEJA  [waterfall] [the Sump]          from La Boca, the throat's foot)
   0                                   cart tunnel <----- A0 LA ESTACION ... town ->
```

| Area | Name | Region x | Region y | Enters at | Leaves at |
|---|---|---|---|---|---|
| A0 | La Estación (trailhead, the cart ride) | -150 .. 12 | -14 .. 10 | spawn (6, 0) | cart terminus (-150, -12) |
| A1 | La Mina Vieja | -292 .. -146 | -36 .. 90 | (-150, -12) | lip ledge (-232, 90) |
| A2 | Las Aguas Negras | -462 .. -226 | 86 .. 176 | (-232, 90) | dam top (-452, 176) |
| A3 | La Gruta de Cristal | -462 .. -306 | 176 .. 276 | (-452, 178) | Pozo west rim (-306, 270) |
| A4 | El Jardín de Hongos | -294 .. -182 | 264 .. 376 | Pozo east rim (-294, 270) | Pozo east rim (-294, 370) |
| A5 | El Templo del Primer Perro | -440 .. -306 | 364 .. 484 | Pozo west rim (-306, 372) | well mouth, west (-306, 480) |
| A6 | La Chimenea | -294 .. -214 | 476 .. 588 | well mouth, east (-294, 480) | east face (-232, 582) |
| A7 | Los Riscos del Viento | -262 .. -160 | 570 .. 690 | El Balcón (-228, 580) | low station (-244, 688) |
| A8 | El Teleférico | -285 .. -140 | 684 .. 790 | (-244, 688) | high station (-272, 786) |
| A9 | El Glaciar | -335 .. -250 | 784 .. 888 | (-274, 788) | (-306, 886) |
| A10 | La Cresta de la Tormenta | -360 .. -285 | 884 .. 966 | (-306, 888) | (-336, 964) |
| A11 | La Cumbre | -380 .. -320 | 962 .. 1010 | (-336, 966) | the bell (-350, 1000) |

**The shared structure** (`tools/peak/areas/structure.py`):
- **El Pozo del Diablo:** a slick shaft, x -306 .. -294 (12 m wide), from y 176 to the
  temple's well mouth at y 480. You look up it from the river, then cross it three
  times: at 270 (grotto to garden), 370 (garden to temple) and 480 (temple to chimney).
- **The east face:** the outside of the mountain, from the trailhead up to El Balcón at
  (-230, 578). Slick scree.
- **El Colmillo:** the rock fang standing on the slope off the east face, top (-165, 725).
- **La Garganta:** the slick throat between the fang and the face, a funnel 180 m deep.
- **La Boca:** the mouth at the throat's foot, (-177, 400). Whatever falls between the
  face and the fang goes down it.
- **El Tobogán:** the slide tube from La Boca, down behind the mushroom garden, to an
  outlet in the river cave's roof at x -266 .. -258, twenty metres upstream of the
  waterfall's lip.
- **The bare slope:** east of the fang, the mountain's skin runs unbroken down to the
  trailhead. A body flung that far out slides all the way to the cart.
- **The Sump:** the pool at the bottom of the mine's waterfall cavern, y -28. The
  lowest water in the world. Every great fall ends here.

## 5. The falls (the rage design)

Where a miss sends you. `S` slip (the same challenge), `B` back two or three, `A` the
area's start, `P` the Pozo, `X` everything.

| From | Lands | Cost |
|---|---|---|
| Most of the mine | the Sump, with a splash | the mine so far |
| The river, anywhere in the current | over the lip into the Sump, unless you swim out or catch the lip chain | the mine and the river so far |
| Any Pozo crossing | down the well into the Charco (the river's middle pool), then the current | to the river or the Sump: up to 450 m |
| The grotto, garden, temple (not over the Pozo) | a lower shelf of the same area | `S` to `A` |
| The chimney | its floor, by the well mouth | the chimney so far. One step further back is the well |
| The cliffs, over El Balcón | El Balcón | the cliffs so far |
| The cliffs past the Balcón's edge, the cableway mid-span, the fang | La Garganta, the slope, La Boca, El Tobogán, the river, the lip, the Sump | 700-800 m: back to the mine |
| The glacier | a crevasse (`B`), or off the tongue (`X`) | |
| The storm ridge, the summit's last jump | the glacier's slide, the tongue, the throat, the river, the Sump | everything: 1,030 m |
| Flung far out east from anywhere outside | the bare slope below La Boca, sliding to the trailhead | everything and the cart ride too |

**The shape of the punishment.** Inside each area, early mistakes cost little and late
ones cost the area. Between areas, the Pozo is the tax collector: three crossings, each
wider, each costing more. Outside, the cableway is where the game stops being kind:
its void has no floor until the river. The summit's last jump is the worst fall in the
game, on purpose, with the bell in view.

**The river is the one chance.** Everything that falls far ends in the river with 20 to
60 m of current before the lip. Pinwheel hard and you can reach a chain or a bank and
keep half the mountain. Most won't. Some will, and they'll tell people.

## 6. The mechanics (what the engine provides)

Every piece is data in the course files (see `AUTHORING.md`).

| Piece | What it is | First seen |
|---|---|---|
| Grip rock, wood, iron, stone | sticks | everywhere |
| Slick | can't be gripped: mud, wet, slime, glass, grease | A1 |
| Crumbling hold | breaks a moment after you take it; grows back later | A1 planks, A3 crystal, A9 snow |
| Wet-cycle hold | slick while the spray is on it | A1 curtain, A2 cascade |
| Timed hold | lets go of you after T seconds: hot rock (1.2 s), ice (2 s) | A2 pipes, A6, A9 |
| Physics rope | a chain of bodies you grab anywhere: rope, chain, vine, bell rope | A1 |
| Rope bridge, hanging plank | ropes carrying planks | A4, A7 |
| Mover | a body on a path: lifts, gates, pistons, gondolas, barrels, birds, snails | A1 |
| Triggered mover | starts when you grab or board it: carts, the bucket lift, ziplines | A0 |
| Wheel | a turning body: winding wheel, water wheel, gears, geode, vane | A1 |
| Pendulum | a swinging body: censers, the quartz pendulum, chairlift chairs | A3 |
| Free body | a real rigid body on a hinge: the crank, the dangling gondola, the seesaw | A2 |
| Water | buoyancy and a current. A hand moving under the surface pushes you the other way, so pinwheeling an arm swims you | A2 |
| Wind | a push in a box, steady or gusting, telegraphed by streamers and a whistle | A4 spores, A7 |
| Geyser | a timed upward blast | A6 |
| Bounce | throws you off along its face: mushroom caps, puffballs, the ring ropes | A4 |
| Kick | grabbing it launches you: the burros | A7 |
| Faller | rocks, icicles, boulders on a timer. A hit knocks you out (1.6 s, limp) | A1 |
| Strike | lightning on metal on a cycle: hold it at the wrong moment and you're out cold | A10 |
| Frozen climbers | the bodies of earlier challengers, solid and grippable | A1, A5, A9, A11 |

## 7. The look: a cardboard mountain

The plaza's mountains and clouds are painted cardboard cut-outs with kraft edges.
**The Peak is that same cardboard, seen from inside:** a papercraft diorama. Rock is a
painted card with a brown corrugated edge. Layers stand behind and in front of the
climbing plane. It is cheap to build in code, it matches the game, and it makes the
rule of law 1 easy: grip is matte pale paint, slick is glossy dark paint with white
drips.

Each area has a five-colour palette (`tools/peak/palettes.py`), its own light and its
own background card stack:

| Area | Light | Palette | The picture |
|---|---|---|---|
| A0 | noon sun | town cream, terracotta, sky | torn papel picado, a pug-skull arrow sign, the cart on its siding |
| A1 | lantern amber in the dark | umber rock, honey timber, black mud | shoring, rails, lanterns, the 113 m waterfall as the room's spine |
| A2 | cold teal | slate brick, verdigris iron, black water | arches, pipes, wheels, the Pozo's dot of light far overhead |
| A3 | violet and ice-white | amethyst, quartz white, deep indigo glass | crystals bigger than houses, chandeliers, your own reflection |
| A4 | green glow, orange caps | moss, cream gills, tangerine, slime black | mushrooms as trees, drifting spores, snails the size of carts |
| A5 | torch gold | terracotta, jade, bone, soot | luchador-dog masks three storeys tall, statues of champions |
| A6 | furnace red rising to daylight white | basalt, rust, ember orange | bellows, hammers, steam, a slit of blue sky that grows |
| A7 | hard blue daylight | chalk rock, dead-tree grey, sky | the town tiny below, vultures, burros on impossible ledges |
| A8 | late-afternoon gold | painted steel red, cream, rust | gondolas with peeling pug crests over a void |
| A9 | blue shadow, white glare | glacier blue, snow, black ice | climbers frozen in the ice, mid-reach |
| A10 | storm grey with white flashes | wet slate, flag colours | papel picado prayer lines snapping in the wind |
| A11 | gold above the clouds | summit rock, marigold, sky | the old ring's ropes, the bell, the belt |

**Storytelling without words:**
- **The ones who tried.** Frozen climbers are part of the course. One sits by a cold
  lantern in the mine with tally marks scratched beside him. A chain of three hang
  hand-to-ankle off a temple ledge: they nearly made a ladder. One is frozen in the
  glacier a hand's width below the lip. The last one sits 4 m under the bell.
- **The town follows you up.** Papel picado, tattered at the trailhead, reappears as
  the miners' bunting, the temple's banners, the cableway's pennants, the ridge's
  prayer lines, and is whole and bright at the summit.
- **The pug.** The First Top Dog's mask is carved, painted or stamped on every era of
  the mountain: mine signs, temple walls, gondola doors, the bell.
- **The well.** You see the Pozo from below before you ever cross it.
- **The town below.** From the cliffs up, a tiny cardboard town with the ring sits in
  the valley backdrop. When you ring the bell, its fireworks go off.

## 8. The sound

**Music: twelve loops that are one piece.** Every area's loop is 32 bars at 98 bpm
(78.4 s, 3,456,000 samples each), in D or a mode of it, built on one four-note motif (the DeGayo
call: D, F#, A, B, a rising reach that falls back). All twelve play in step from the
moment the climb loads. Only their volumes move, by where you are, so crossing an
area's edge is a re-orchestration, never a cut. Two more layers ride on top:
- **the height layer:** a soft high drone that thins in as the drop under you grows;
- **the fall:** the music ducks under a low-pass filter while you fall more than 12 m,
  and comes back a bar after you land.

| Area | The loop |
|---|---|
| A0 | the town's guitar and trumpet, half heard, walking away |
| A1 | guitarrón and muted pick-axe percussion, a lone harmonica |
| A2 | bowed bass, dripping marimba, low accordion swells |
| A3 | celesta and glass, music-box motif, slow harp |
| A4 | kalimba, pizzicato, a bouncing bassoon, playful |
| A5 | deep drums, clay flute, low brass on the motif |
| A6 | anvils, snare rolls, rising brass, urgent |
| A7 | whistled motif, western guitar, castanets, wide open |
| A8 | accordion and a swaying bass, a little tipsy |
| A9 | high strings, glass harmonica, almost no rhythm |
| A10 | timpani, tremolo strings, trumpet calls torn by wind |
| A11 | the whole mariachi on the motif, finally resolved |

**Ambience:** one bed per area, mixed by position the same way: drips and timber
creak, the river's roar, crystal shimmer, spore fizz, torch and stone, steam and
rumble, wind and one far bird, cable hum, ice wind, storm, thin high wind and flags.

**Events:** every mechanic has a sound that tells you its state before you look:
a plank creaks before it snaps, ice ticks before it lets go, a geyser gurgles before
it blows, a gust whistles in, lightning hums up. The list is in `PARTS.md` (sound).

**The fall:** wind that rises in pitch with your speed, the music going under water,
one yell when the fall passes 15 m, the thud, a beat of nothing, then, after a fall of
more than 60 m, one sad trumpet "wah-wah" and far away, a donkey.

**The reward:** a small rising chime at every new 100 m, your best height ever.

## 9. Camera, HUD, save

- **Camera:** follows the climber. Its frame is set by zones in the course: 4 m
  half-height on a wall, pulled back to as much as 14 m at a big fling so the target
  and the drop are both in view. It leads a little the way you're moving and pulls back
  as you fall.
- **HUD:** the altimeter (metres above the trailhead), the area's name on a banner as
  you enter it, and nothing else. Pause shows the time, the falls, the best height.
- **Save:** `user://peak.cfg`, written every two seconds while you hold on and at
  pause and quit: the pose, the clock, the falls, the best height, the summits.
- **Dev:** F4 turns on the warp keys (`[` and `]` step through the 111 challenges),
  so every challenge can be tried without climbing to it.

## 10. The ending

The bell rope swings as you climb it and the bell tolls with every lurch. At the top is
the First Top Dog's belt. Touch it: the bell rings out, the town's fireworks go off far
below, the motif finally resolves, and the banner reads **TOP DOG** with your time and
your falls. From then on the mountain behind the title screen flies your flag.

## Parker's brief (2026-11-11, verbatim)

> To the left of the town there is a great mountain called the Peak of DeGayo. The goal
> of the solo mode is to scale this massive mountain. To begin, you will come upon a
> minecart and have to get in it, and it will bring you into the mountain. Once inside,
> you will scale the inside of the mountain until you come out onto the surface. There
> will be areas you cannot cling too, all very dark, muddy looking things that are slick
> or wet looking to indicate you cannot grab it. Make multiple biomes and challenges,
> the main challenge being flinging yourself long distances. and climbing things that
> are hard to climb. Things like ropes that have physics, moving platforms, jumps from a
> gondola to another, a swim through a river where you have to pinwheel and arm fast to
> fight the current, that sort of thing. Design multiple biome like areas and tons of
> challenges, at least 100 different distinct challenges, an in depth climb to reach the
> peak. Create music for all the areas that fit the areas and that will blend from one
> area to the next. Have good sound design. Spend a lot of effort on designing
> everything out first and how the whole long climb will all fit together. It will be a
> rage game so if you fall at certain points you can lose a lot of progress. it should
> be challenging. There should be places where if you fall, you fall all the way down or
> at least a really long way. No where should feel super safe.
