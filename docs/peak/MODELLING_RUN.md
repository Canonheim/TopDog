# The Peak's modelling run

Started the night of 2026-11-13, on Parker's word ("Docs, models and fixes"). The whole
mountain is designed (`docs/peak/playtest/design/`: twelve biome sheets, an area page for
every place). This run builds it, biome by biome from the bottom, the way the station
(challenges 0.1 and 0.2) was built: Parker's verdict on that test was "Yes, build on".

Kept up to date by the Second Director (background director). If you are picking this up
cold, read this file, then `docs/peak/playtest/design/BRIEF.md` (its sections "Far
backgrounds", "Open ground" and "Walls and masses" are the three look methods he has
approved), then the sheet and pages of the biome you are on.

## The method: the contract first

1. **The dress file is the contract.** For each biome one file,
   `tools/peak/areas/aN_dress.py`, with one function `dress(A)`. It places every piece of
   scenery the biome's area pages call for, as `A.deco(model, x, y, z=..., size=(w, h, d),
   tone=...)`, at real coordinates, with the model's stem and the size it will be MADE at.
   Until a model lands the game draws a plain stand-in of that size, so the place can be
   looked at in the game at once. The worked example is `tools/peak/areas/a0_station.py`.
2. **The model list falls out of the dress file:** every stem in it that is not yet in
   `kit/models/` is a model to make, at exactly that size, with its origin where the dress
   file needs it.
3. **The makers build to the list** in `Top Dog Kit\` (source scripts, review sheets,
   `land.sh`), then `python tools/sync_kit.py`, a gated `--headless --import`, and game
   frames (`tests/peak_watch.tscn`). The frames go back to the maker with what is wrong.
   Repeat until the screen looks finished.
4. **Walls and masses** are models too: one painted piece made for its place (the method in
   BRIEF.md; reference `Top Dog Kit\previews\ex_riscos_tower_top_game.png`). A solid takes
   one as its look by `skin="stem"` on the solid and `skin=True` on the deco that places it.

## Rules of a dress file

- Scenery only: `A.deco` and `A.card`. Nothing in it can be stood on or held. The course's
  solids, movers, ropes and zones are the area file's (`aN.py`), which the fix thread owns.
  If a design needs a solid moved, a deco taken out of `aN.py`, or a solid given a
  `skin`, write it in a list at the top of the dress file under `FOR THE AREA FILE:` and
  do not edit `aN.py`.
- A deco's origin is the middle of its base (x and z), at its foot (y). Thin wall-mounted
  things: the middle of the foot line on the wall. Say so in a comment where it differs.
- **A deco's `size` must be the size the model is made at.** The game rescales a landed
  model that is more than about a quarter off.
- Depth: the play space is z -1.2 to +1.2. Background stands behind -1.25, foreground in
  front of +1.25. Parker: "If it is in the play space you should generally be able to hold
  it", so no scenery in the play space.
- The camera sits at about the climber's chest height, about 13.7 m in front of the play
  plane when close. Anything standing in FRONT of where a climber can be covers the climber
  up to its own height: foreground is under 0.3 m tall, or stands where nobody can be
  behind it.
- One atlas material, no glowing materials, applied transforms: the makers' business, but
  do not ask for a lamp that glows; ask for colour.
- Far backgrounds are one flat painted card; open ground is one painted slab with real
  things on it; a wall is painted. Size each by the brief.
- Reuse stems across the mountain. Before naming a new one, look in `kit/models/` and in
  the other dress files.

## Who does what

| Who | What |
|---|---|
| Second Director (this session) | the plan, the dress files (by helper agents), sync, import, game frames, critique, the report to Parker |
| Thread A, "Station test A: the buildings" | buildings, walls and rock masses (painted), far cards, ground slabs |
| Thread B, "Station test B: the props" | props, plants, signs, frogs, small dressing, far layers' details |
| Thread C, "Station test C: timber and iron" | timber structures, iron fittings, machines, rails, rings, ropes' hardware |
| The fix thread | the game's code and the area files `aN.py`; it adds the `aN_dress` call and does the `FOR THE AREA FILE` lists |
| The Top Dog session | main, merges, the climber's own code |

A new climber model is coming ("we are getting a new climber model very soon"): nothing
bespoke is modelled for the frozen climbers or the ending's climber until it is here.

## Status

| Biome | Sheet and pages | Dress file | Models | In-game frames |
|---|---|---|---|---|
| 0 La Estación | done; 0.1-0.2 built | `a0_station.py` (0.1-0.2); `a0_dress.py` (the ride, the join): written, not yet called | station set landed; 46 new on the list (`models/a0_models.md`): A 15, B 10, C 21, all sent | station: yes |
| 1 La Mina Vieja | done; cart room redone (note 103) | `a1_dress.py` being written | the cart room's incline with thread C | |
| 2 Las Aguas Negras | done | | | |
| 3 La Gruta de Cristal | done | | | |
| 4 El Jardín de Hongos | done | | | |
| 5 El Templo | done | | | |
| 6 La Chimenea | done | | | |
| 7 Los Riscos del Viento | done | | walls example landed | |
| 8 El Teleférico | done; revised (real roofs, hangers held) | | | |
| 9 El Glaciar | done; revised (three wall arrow signs) | | | |
| 10 La Cresta de la Tormenta | done | | | |
| 11 La Cumbre | done; revised (the secret the right way round; the ring) | | ring ropes landed (thread C), not yet in the game | |

Mountain-wide small pieces (wave 0, no placement needed): frogs, signs, tea things
(thread B, in progress); iron rings, staples, pegs, the summit's ring ropes (thread C: all
thirteen landed in the kit, not yet synced into the game).
