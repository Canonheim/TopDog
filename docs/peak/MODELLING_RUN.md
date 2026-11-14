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
- **No polished or metallic finish on a wall, mass or skin** (learned 11-14 on the wind cliffs: the
  atlas files such a colour as polished and the game mirrors the sky or a lamp into some painted
  beds and not others, so a face reads as black-and-white stripes; the makers' bench never shows
  it). A slick surface paints its shine as a pale band.
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
| 0 La Estación | done; 0.1-0.2 built | `a0_station.py`; `a0_dress.py` WIRED (df43021) | all 46 landed and synced (A 15, B 10, C 21) | yes: `docs/peak/frames/a0_ride_*`; the gap's far cavern fixed (625c171) |
| 1 La Mina Vieja | done; cart room redone (note 103) | `a1_dress.py` WIRED (4c1c86f), cart room built | all 94 landed and synced (A 30, B 24, C 40) | yes: `docs/peak/frames/a1_mine_*` (taken before the walls were redone) |
| 2 Las Aguas Negras | done | `a2_dress.py` WIRED (5de53c7) | all 102 landed and synced (A 56, B 7, C 39) | yes: `docs/peak/frames/a2_aguas_*` |
| 3 La Gruta de Cristal | done | `a3_dress.py` WIRED (63d1254) | all landed and synced (A 45 incl. the real 3D crystals, B 28) | yes: `docs/peak/frames/a3_gruta_*` (st's grey-tan body card shows through behind the giants and the column: with the fix thread) |
| 4 El Jardín de Hongos | done | `a4_dress.py` WIRED (08a6185) | all landed and synced (A 33, B 46, C 1) | yes: `docs/peak/frames/a4_jardin_*` (st's body card shows as flat olive where nothing stands behind: with the fix thread) |
| 5 El Templo | done | `a5_dress.py` WIRED (f12c640) | all landed and synced (A 87, B 11, C 12) | yes: `docs/peak/frames/a5_templo_*` (the back walls are as bright as the holds in places: a darker, cooler pass due) |
| 6 La Chimenea | done | `a6_dress.py` WIRED (8788f09) | all landed and synced (A 37, B 9, C 40) | yes: `docs/peak/frames/a6_forja_*` |
| 7 Los Riscos del Viento | done | `a7_dress.py` WIRED (8451f10) | C 23 and A 40 landed (re-landed matte after the polished finish striped them); B with thread B; the 7.6 m wheel landed; the tower top cut at 658 | yes: `docs/peak/frames/a7_riscos_*` |
| 8 El Teleférico | done; revised (real roofs, hangers held) | `a8_dress.py` WIRED (faa373e) | 71 new: all landed and synced (A 13, B 6, C 46; re-makes); seven re-makes (gondola, dead gondola, chair as a bench, zip trolley, counterweight, low station, haul cable) with C | yes: `docs/peak/frames/a8_tele_*` (the sky shows now; the fang's polished rock reads flat black: being re-made matte) |
| 9 El Glaciar | done; revised (three wall arrow signs) | `a9_dress.py` WIRED (9b64b15) | B 6 and C 8 landed; A 54 with the cliffs' wall maker | |
| 10 La Cresta de la Tormenta | done | `a10_dress.py` WIRED (fefc451) | all landed and synced (A 40, B 5, C 25) | yes: `docs/peak/frames/a10_tormenta_*` (the wet slate's polished finish stripes the faces: being re-made matte) |
| 11 La Cumbre | done; revised (the secret the right way round; the ring) | `a11_dress.py` WIRED (2848c76) | ring ropes landed (thread C); B 11 and C 14 landed; A 32 with thread C | |

Mountain-wide small pieces (wave 0, no placement needed): frogs, signs, tea things
(thread B, in progress); iron rings, staples, pegs, the summit's ring ropes (thread C: all
thirteen landed in the kit, not yet synced into the game).

**Pace (night of 11-13):** the makers are the bottleneck. Biomes 0 to 2 are fully modelled (242 models). Thread A stopped on 11-14 (its handover note is in the side-session notes folder); its walls and masses for biomes 3 to 6 went to a maker agent and to threads B and C, who finished their own rows for biomes 0 to 5. The unwired effects the fix thread could not build yet are listed in its `WORK_LOG.md`.
