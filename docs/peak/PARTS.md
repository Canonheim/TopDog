# The Peak's parts: what the makers build

Read `PEAK_DESIGN.md` first (§7 is the look). The Peak is a **cardboard mountain**: the
plaza's painted cut-out mountains, seen from inside. Rock and walls are built in code as
painted card with a kraft edge. The makers build the THINGS: props, machines, creatures,
set pieces.

**How parts reach the game.** The course names every prop by a model name
(`A.deco("lantern_mine", ...)`, or `model="gondola"` on a moving body). The game looks
for `kit/models/<name>.glb` (synced from `Top Dog Kit\models` by `tools/sync_kit.py`)
and draws a plain stand-in box until it lands. So **a part is live the moment it is
landed under its exact name**: no code change, no waiting on anyone. Deliver in priority
order and don't wait for answers; Top Dog (the coordinating session) syncs what has
landed.

**Rules for every part**
- The house atlas, one PALETTE material, no emissive colours, transforms applied
  (the kit's usual road, critic included).
- Metres. **+Z faces the camera. The climb happens on the z = 0 plane**, 2.4 m thick
  (z -1.2 to 1.2). A prop behind the climb sits at z -0.8 or further back.
- Origin: the middle of the base (x and z centred, y = 0 at the bottom), unless the
  table says otherwise. Sizes are width x height x depth. Hit the size within 5%:
  moving parts have colliders that the model must cover.
- **The colour law:** things a climber can grip are pale, matte and dry (timber honey
  `#C9903F`, rust-red iron `#B5532A`, bone `#E9E2CE`, warm stone `#C8B79A`). Nothing
  grippable may be dark or glossy: dark and wet means "can't hold this" in the Peak.
- The pug (the First Top Dog's mask) is stamped, carved or painted on everything.
- Area authors may add props during the night. The live list of every name the course
  uses, with sizes, is `docs/peak/PROPS_USED.md` (rebuilt by `tools/peak/props.py`);
  after your priority-1 list, work from it.

## TD Carpenter: timber, rope, rail, iron

| P | Name | Size (m) | Origin and notes |
|---|---|---|---|
| 1 | `minecart` | 2.4 x 1.1 x 1.3 | Origin: the middle of its floor's top. Floor 2.4 long, 0.2 thick; the two ends rise 0.8 above the floor at x ±1.12; the sides facing the camera are LOW (0.3) so the climber inside is seen. Four iron wheels below. A pug stamped on the end |
| 1 | `mine_frame` | 0.6 x 5.0 x 2.6 | A tunnel mouth's timber set: two posts and a cap, seen end-on |
| 1 | `rail_straight` | 4.0 x 0.25 x 1.2 | Two rails on ties; tiles end to end |
| 1 | `mine_post`, `mine_beam` | 0.35 x 3.0 x 0.35; 4.0 x 0.35 x 0.35 | Shoring |
| 1 | `plank` | 2.0 x 0.12 x 0.9 | A catwalk board |
| 1 | `ladder_piece` | 0.8 x 2.0 x 0.1 | Two rails, five rungs |
| 2 | `winding_wheel` | 6.0 across, 0.5 deep | Origin: the hub. Six spokes and a rim |
| 2 | `ore_bucket`, `pulley` | 1.2 x 1.2 x 1.0; 0.8 across | |
| 2 | `water_wheel` | 8.0 across, 1.6 deep | Origin: the hub. Eight spokes, paddles at the rim |
| 2 | `sluice_gate` | 3.0 x 4.0 x 0.5 | Origin: the middle of its bottom edge. Plank gate in an iron frame |
| 2 | `crank_wheel` | 1.6 across | Origin: the hub. One handle sticking out toward the camera at the rim |
| 2 | `rail_broken`, `trestle_bent` | 4.0 x 0.4 x 1.2; 3.0 x 6.0 x 1.5 | The broken end of the track; a trestle frame |
| 2 | `station_scaffold` | 4.0 x 6.0 x 2.0 | Timber and iron lattice, stacks |
| 2 | `bull_wheel` | 5.0 across, 0.4 deep | Origin: the hub. The cableway's big horizontal-axis wheel, seen face-on |
| 2 | `pylon_top` | 4.0 x 3.0 x 2.0 | A cableway pylon's crossarm with two sheaves |
| 2 | `chair_lift` | 1.4 x 3.0 x 0.8 | Origin: the top of its hanger. A two-seat chair on a 2.2 m hanger |
| 2 | `zip_trolley` | 0.6 x 0.5 x 0.2 | Origin: the wheel on the cable. A handle below |
| 3 | `rope_bridge_plank` | 1.0 x 0.08 x 0.9 | |
| 3 | `bell_frame` | 5.0 x 6.0 x 2.0 | The summit's timber frame the bell hangs from |
| 3 | `ring_post` | 0.4 x 3.0 x 0.4 | A weathered post of the first ring, with three turnbuckles |
| 3 | `streamer_pole`, `prayer_pole` | 0.2 x 4.0 x 0.2 | A pole with a wind streamer; a pole with papel picado tied on |

## TD Building Maker: stone, steel, set pieces

| P | Name | Size (m) | Origin and notes |
|---|---|---|---|
| 1 | `gondola` | 2.6 x 2.2 x 1.6, hanging 1.5 under its origin | Origin: the grip on the cable. A hanger arm down to the roof. Open sides to the camera (the climber is seen inside). Painted steel red and cream, peeling, the pug crest on the door |
| 1 | `mask_first_dog` | 9.0 x 10.0 x 2.0 | The First Top Dog's stone mask (a luchador pug). Origin: the middle of its chin's bottom. The lower jaw is a separate object `mask_jaw` (it moves); eye sockets and nostrils are deep (they are holds) |
| 1 | `summit_bell` | 2.2 x 2.6 x 2.2 | Origin: its hanging point. Bronze, the pug mask in relief |
| 1 | `champion_belt` | 1.6 x 0.8 x 0.2 | The First Top Dog's title belt, gold and red. The last thing in the game |
| 1 | `town_far` | 40 x 12 x 2 | The town seen from 600 m up: a tiny cardboard diorama, the ring a dot of colour in its middle, the church's twin towers. Layered cards |
| 2 | `statue_champion_a`, `_b`, `_c` | about 5 x 9 x 2 | Giant stone luchadors, arms raised (a: both arms up; b: one arm out sideways; c: flexing). Origin: between the feet |
| 2 | `censer` | 1.6 x 1.8 x 1.6 | Origin: its hanging point. A pierced bronze bowl on three chains |
| 2 | `stone_gear` | 4.0 across, 0.8 deep | Origin: the hub. Twelve square teeth |
| 2 | `piston_head` | 2.5 x 1.5 x 2.0 | A carved stone ram, a pug's flat face on its end |
| 2 | `serpent_head`, `serpent_segment` | 2.5 x 2.0 x 1.5; 2.0 x 1.0 x 1.5 | A feathered pug-serpent; its back's segments ripple |
| 2 | `torch_wall`, `altar` | 0.4 x 1.2 x 0.4; 3.0 x 1.5 x 1.5 | |
| 2 | `gondola_broken` | 2.6 x 2.2 x 1.6 | The same car, wrecked: a window out, a door hanging. Origin: its one remaining hanger grip |
| 2 | `counterweight` | 1.6 x 1.2 x 1.0 | A concrete-and-iron block with a sheave on top |
| 2 | `station_roof` | 12 x 4 x 4 | The cable station's tin roof on posts |
| 2 | `bellows`, `drop_hammer`, `anvil`, `steam_grate` | 3 x 2 x 1.5; 1.8 x 3 x 1.5; 1.2 x 0.9 x 0.6; 2.5 x 0.3 x 1.5 | The forge |
| 3 | `antenna_mast` | 1.5 x 14 x 1.5 | A lattice mast with a lightning rod |
| 3 | `anemometer` | 10 across | Origin: the hub. Four arms with a cup at each end |
| 3 | `weather_balloon` | 4 x 6 x 4 | Origin: the bottom of its basket ring |
| 3 | `summit_shrine` | 3 x 3 x 2 | A small painted shrine with marigolds |

## TD Environment Maker: the living mountain

Two jobs in code, on your `env-pass` branch (Top Dog merges), then models.

1. **The Peak seen from town.** Parker: "To the left of the town there is a great
   mountain called the Peak of DeGayo." Give the plaza and the title screen that
   mountain: one great cardboard cut-out, far bigger than the ridge row, standing at
   the left of the view (the trailhead is at world x -110), snow on its head, a storm
   cloud snagged on its ridge, the cable line a thin thread across to its fang, the mine
   mouth a dark dot at its foot. It must read at a glance from the title screen. Its
   outline should match the course's cross-section (`docs/peak/preview/mountain.png`,
   `tools/peak/areas/st.py` EAST / WEST). Leave a hook for a flag on the summit that
   the game shows once the player has climbed it (`PlazaMountains.peak_flag(on)`).
2. **The Peak's backdrops**, one new file `stages/peak/peak_backdrop.gd`
   (`class_name PeakBackdrop`): `static func build(parent: Node3D, origin: Vector3) -> PeakBackdrop`
   and `func tick(delta: float, cam: Camera3D) -> void`. It draws what is far behind the
   climb, in the course's local coordinates (add `origin`): outside (y 570 and up) the
   valley with the tiny town far below, far cardboard ranges, a sea of cloud at about
   y 940 that the summit stands above, the storm's cloud deck over y 880 to 960, the
   gold sky at the top; inside, the deep dark of each cavern as two or three parallax
   card layers (the areas' own back cards stand at z -3 to -8; yours go behind, z -15 to
   -60). Cheap: cards, the one atlas material (`CelPass.paint`), nothing per-frame but
   cloud drift. The game calls build once and tick every frame; until your file lands
   it uses flat cards.

| P | Name | Size (m) | Notes |
|---|---|---|---|
| 1 | `mushroom_cap_s`, `_m`, `_l` | 2 x 1.5 x 2; 4 x 2.5 x 4; 7 x 4 x 5 | Stalk and cap. The cap's top is the bounce: tangerine with cream spots. Origin: the base |
| 1 | `crystal_cluster_a`, `_b`, `_c` | 2 x 3 x 2; 4 x 5 x 3; 1 x 1.5 x 1 | Hexagonal prisms, hard angles: amethyst faces, white frosted tips |
| 1 | `crystal_spire` | 2 x 10 x 2 | A needle |
| 1 | `stalactite_a`, `_b` | 0.8 x 3 x 0.8; 1.5 x 6 x 1.5 | Origin: the top |
| 2 | `mushroom_giant` | 16 x 22 x 8 | The giant: a slick dark stalk, cream gills under a huge cap |
| 2 | `giant_snail` | 2.4 x 1.8 x 1.2 | Origin: the middle of its foot. The shell is the hold: pale and matte; the body dark |
| 2 | `puffball` | 1.2 across | Origin: its centre |
| 2 | `chandelier_crystal` | 2 x 2.5 x 2 | Origin: its hanging point |
| 2 | `vulture`, `nest` | 2.6 wingspan; 1.8 x 0.6 x 1.8 | The vulture's origin is its feet (the hold) |
| 2 | `burro` | 1.8 x 1.5 x 0.6 | Standing side-on, ears back, ready to kick |
| 2 | `dead_tree` | 6 x 8 x 1 | Leaning out, bare |
| 2 | `shrub`, `boulder` | 1 x 0.8 x 1; 1.2 across | |
| 2 | `icicle_big`, `ice_block`, `snow_cornice` | 0.6 x 2.5 x 0.6 (origin top); 2 x 2 x 2; 6 x 2 x 3 | |
| 3 | `glow_moss`, `vine_leaf`, `spore_pod` | small | Dressing |

## TD UI creator: the solo UI's pieces, signs, small props

| P | Name | Size (m) | Notes |
|---|---|---|---|
| 1 | `peak_altimeter` | HUD piece, about the nameplate's size | The solo HUD: your height in metres on rolling drums (0000 to 1000), with a small cut-out mountain and a marker that climbs it. Objects named as on `hud_odometer` (`drum_0..3`) plus `alt_marker` (moves 0 to 1 up its slot) |
| 1 | `peak_summit_card` | board, about the results board's width | The ending: TOP DOG, with plates for TIME, FALLS and BEST. Lucha poster style |
| 1 | `sign_pug_arrow`, `sign_pug_skull` | 1.0 x 2.2 x 0.1 | Painted trail signs on a post: the pug pointing up; the pug's skull (danger). No words |
| 1 | `lantern_mine`, `lantern_hang` | 0.3 x 0.5 x 0.3 | A miner's lantern (stands); one on a hook (origin: the hook). Not emissive: the game adds the light |
| 1 | `papel_tatters`, `papel_string` | 8 x 1 x 0.05 | A torn, faded string of papel picado; a whole bright one |
| 2 | `tally_marks` | 1.2 x 0.8 card | Scratched tally marks in fives, about forty, the last group unfinished |
| 2 | `camp_bedroll`, `campfire_cold`, `rope_coil`, `pickaxe` | small | One climber's last camp |
| 2 | `crate_ore`, `ore_pile` | 1.2 x 1.1 x 1.2; 2 x 1 x 1.5 | |
| 2 | `brake_lever` | 0.15 x 1.0 x 0.15 | A red-handled lever |
| 2 | `pennant`, `flag_top_dog`, `marigold_garland` | 0.6 x 0.4; 1.5 x 1.0; 4 x 0.5 | The cableway's pennant; the summit's flag; the summit's garland |
| 2 | `kite`, `wind_sock` | 2.5 x 2.5; 0.5 x 1.5 | A papel picado kite, origin its centre |
| 3 | `temple_banner` | 1.5 x 5 x 0.05 | A long cloth banner with the pug mask |

## The Second Director: the solo mode's screens

One new file on `luchador-ui`, `ui3d/peak_hud.gd` (`class_name PeakHud extends Node3D`),
so it merges with no conflicts. Top Dog's game code calls it; until it lands a plain
label stands in. The interface:

```gdscript
static func make(lucha: LuchaUI) -> PeakHud   # hung on the camera like the match HUD (UI_ROOT group)
func set_altitude(metres: float, best: float) -> void       # every frame
func show_area(name: String, number: int) -> void            # entering an area: its name slams in, holds 3 s, leaves
func milestone(metres: int) -> void                          # every new best 100 m: a small celebration
func fell(metres: float) -> void                             # after a fall of 15 m or more: the number, briefly, and it hurts
func summit(time_s: float, falls: int, best_s: float) -> void # the ending: TOP DOG, the plates, confetti, then waits for a press
func set_paused(on: bool, time_s: float, falls: int, best_m: float) -> void
```

Use the UI creator's `peak_altimeter` and `peak_summit_card` when they land (kit names
above), the existing `hud_banner` for area names, the house confetti for the summit.
The fall readout is the one new idea: after a long fall the HUD shows, small and dry,
how far you fell. Make it funny. A probe scene that drives every call
(`tests/peak_hud_probe.tscn`) lets you frame it without the game.

## Sound (made by synthesis tonight; listed for Dan)

Music: `audio/music/peak/peak_a0..a11.ogg` and three stingers (`docs/peak/MUSIC.md`).
Effects: `audio/sfx/peak/*.wav` (`docs/peak/SFX.md` lists every file and which came out
weak). All synthesised placeholders of real quality where possible; Dan may replace any
file under the same name.
