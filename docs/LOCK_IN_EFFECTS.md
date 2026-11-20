# Lock-in effect implementation standard

User-approved standing requirements (2026-11-11). Apply to every future lock-in effect added to TopDog unless the user explicitly changes these requirements.

- Each activation must visibly vary while preserving the effect's intended launch, motion, timing and character. Use a fresh local RandomNumberGenerator per burst so cosmetic randomness does not disturb gameplay RNG.
- Use bounded randomness within overlapping directional bands and height layers. Do not use unconstrained random directions that can leave large empty regions or a visible lull while everything goes offscreen. Include lower and higher trajectories so coverage overlaps throughout the active burst; normal ending/cleanup is still expected.
- Balance object types, mesh variants and sizes across left, center and right. Reserve quotas per direction before jittering. Larger pieces, streamers or whole roses must not all end up on one side. Keep size jitter modest or stratified; randomness must not undo the quotas.
- Keep particle budgets bounded. Cache and reuse meshes/materials; use the game's color atlas and visual style. Choose variation at spawn time rather than generating geometry or allocating resources every frame. Extra emitters have overhead: measure if materially increasing their number or complexity.
- Preserve the approved Bills effect unless the user asks to alter it. It already has randomized motion and continuous stratified coverage; it was intentionally excluded from the later confetti/rose shape-balancing adjustment.
- Integrate through the existing customization and lock-in dispatch paths, and verify an actual match lock-in uses the selected effect.
- **Lock-ins burst from the climber, in the world** (Parker 2026-11-14: "the confetti explosion should stay where the character locked in, not change with the camera, so it should be worldspace not screen space"; 11-19: "my lock in confetti is not coming out of me"). Build the burst under the camera as before (its layout reads the screen), but move every piece in the burst root's own frame and read nothing from the camera while it flies: `lock_effect_preparation.into_world()` then hands a match lock-in's root to the world, scaled about the camera so the first frame looks as built, centred on the climber (`Game.lock_effect_at`, 0.8 m toward the camera). The wardrobe preview and the winner's confetti stay on the camera.
- Validate several activations: distinct burst profiles, fixed totals, balanced type/size quotas by direction, proper cleanup, and no large mid-burst empty patches. Inspect actual rendered motion; numeric quotas alone do not prove visible coverage. Use game-rendered previews when requested.

## Current examples

- `ui3d/confetti_effect.gd`, via `lucha_ui.confetti()`: 90 normal / 300 winner pieces; each screen third receives identical quotas of curved paper, discs, stars, S-streamers and spiral ribbons. Fifteen overlapping lanes and six height layers, stratified sizes, cached two-sided atlas meshes, local burst RNG and tumbling/flutter motion. Existing Confetti selection and winner dispatch are preserved.
- `ui3d/rose_petals.gd`, `burst()`: six bands with all six petal variants, two of each per band (72 petals); 18 whole roses distributed across six lanes and three height layers, with a balanced mesh/size mix.
- `ui3d/peso_bills.gd`, `burst()`: 72 bills in twelve lanes and six height layers, retaining 36 curled, 30 folded and six crumpled forms. Leave its approved behavior intact.
- `tests/lock_effect_gif.gd`: capture/check harness for the current balanced confetti and roses. Extend/adapt checks for a new effect rather than assuming the harness already covers it.

These are implementation patterns, not a requirement to copy the same particle counts or exact silhouette for every new effect. Preserve each new effect's identity while meeting variation, coverage, balance and performance requirements.

- Underwear: 84 atlas garments, seven styles including thong, eight colors. Each screen third gets four of each style and three of each bra cup size B/C/D/DD. Twelve lanes, seven height layers, local burst RNG, cached models, tumbling motion and three-second cleanup.

- Bullets: 72 atlas cartridges, 12 variants. Each screen third receives two of every variant and eight of each size class. Twelve overlapping lanes, six height layers, fresh local RNG, bounded trajectory and spin variation, cached models and three-second cleanup. Verified through saved customization and actual match lock-in dispatch.

- Pan: 72 atlas pastries from 15 models. Each screen third contains one of each original pastry and four of each of the three dense rainbow-sprinkle cookies (36 cookies total). Twelve lanes, six height layers, three balanced size classes, local burst RNG, cached models and three-second cleanup.

- Food: 90 atlas pieces, 11 types. Per screen third: two each of five dishes, lime and chips; three each red/green salsa; five each yellow/white cheese shreds. Ten of each size class, fifteen lanes and six height layers, fresh local RNG, cached meshes and three-second cleanup. Saved customization and actual match lock-in dispatch verified.

- Watermelon: 90 atlas pieces (12 small whole melons, 36 seeded slices, 42 loose black seeds), balanced by screen third, with ten of each size class per third. Fifteen lanes and six height layers, fresh local RNG, cached models and three-second cleanup. Saved customization, network appearance and match dispatch verified.

- Dog Toys: 90 atlas toys, six reference-based families including tennis balls. Every screen third receives five of each family and ten of each size class. Fifteen lanes and six overlapping height layers, cached meshes, local RNG, tumbling and 3.2-second cleanup.

- Luck: 72 atlas charms from 12 variants (rabbit feet, four-leaf clovers, horseshoes, sevens). Each screen third receives two of each variant and eight of each size class. Twelve lanes, six height layers, local burst RNG, cached models, three-second cleanup.

## Preparation and performance

Every registered effect must satisfy the explicit preparation registry and fresh-process cold/prepared audit described in docs/LOCK_IN_PERFORMANCE.md. New registrations without preparation and finite budgets fail validation. Preserve approved visuals while moving resource creation out of burst time.

- Math: 24 transparent equation/geometry cards in three staggered cohorts. Twelve cached quad variants, one shared glyph atlas/material, 48 total triangles, no shadows/physics. Eight balanced travel-direction families with spawn-only angular, speed and origin variation; twelve paired screen-space crossings spread across four quadrants. Fixed straight trajectories and invariant angles/scales; only opacity changes during flight. Explicit preparation through the registry; saved/network selection and actual match lock dispatch. Math intentionally crosses and overlaps, but never tumbles or flutters.

- Pickles: 72 atlas pieces (18 bumpy whole pickles, 36 crinkle chips, 18 spears), nine cached meshes. Each third receives six whole, twelve chips and six spears with eight pieces per size class. Twelve lanes and six height layers, local RNG, rigid tumbling and three-second cleanup. Incremental atlas initialization plus nine mesh units; saved/menu/network selection and actual match dispatch verified. 18,792 burst triangles, 73 nodes, 72 surfaces, one shared cel material, no physics/shadows. Fresh-process audit: cold 14.57 ms; prepared p95/max 1.243 ms; max preparation unit 6.821 ms; retained mesh arrays 316,908 bytes. Three-overlap cleanup and three rendered randomized bursts passed. CPU timings are not GPU-frame measurements.

- Sodas: 90 opaque atlas pieces (18 unlabelled open-neck bottles, 18 crimped caps, 54 colored droplets), five flavors, 13,428 burst triangles and 15 cached scene variants. Each third has six bottles/six caps/eighteen drops, with identical family/color/size quotas; three droplet size classes have 18 pieces each. Bottle/cap tumble retained; droplet rounded ends smoothly lead velocity, pointed tails trail, with an 8-rad/s turn cap and near-zero-speed orientation hold. No glass refraction/transparency shells, physics or shadows. Incremental scene preparation, save/network/match dispatch, cache reuse, three overlapping roots and three rendered cleanup checks verified. Raw GLB mesh arrays total 283,200 bytes; Godot serialized arrays measure 461,400 bytes, so the cache ceiling is 485,000 bytes (~5% headroom), without loosening geometry/timing limits.

- Pickles missing-face revision: corrected reversed curved-rind and end-cap winding on all three spears. Opaque single-sided material, geometry count and flight behavior unchanged. Outward-normal regression checks plus matched four-angle renders verify previously missing backs. Updated audit: cold 15.787 ms, prepared max/p95 1.146 ms, maximum preparation unit 7.312 ms; overlap and cleanup pass.

- Lipsticks: 72 opaque atlas tubes from 12 unbranded variants, equally split red/pink/nude. Each screen third receives two of each variant and eight of each size class. Slanted tips, black/gold cases, rigid tumble, bounded randomized profiles and 3.2-second cleanup. Twelve cached scenes, 20,448 burst triangles, 217 nodes; serialized retained mesh arrays 532,608 bytes within 560,000 limit. Fresh-process CPU audit: cold 15.938 ms; prepared max/p95 1.974 ms; preparation max unit 2.163 ms. No physics or shadows. Saved/network selection, actual match lock-in, three overlapping bursts, cache reuse, quotas and three rendered cleanup checks passed. Timings precede final UV-only nude-swatch correction; final rendered integration rerun passed. CPU measurements do not measure GPU frame cost or VRAM.

- Space: 72 atlas pieces: exactly ONE red spaceship, 63 gold/ice/rose stars at 50% of their original linear size and EIGHT unique planets, each design appearing exactly once per activation. Exactly ONE ringed Saturn-style planet; ocean, ringed, violet, copper, ice, lava, jade and crater moon. Planet distribution 3/3/2 rotates randomly across screen thirds, with bounded size variation. Continuous latitude bands and coherent warped patches replace grid/modulo paint; the moon uses localized round crater geometry. Fourteen immutable cached meshes; atlas setup plus fourteen incremental mesh jobs. Twelve overlapping lanes, six height layers, local RNG, rigid tumbling and three-second cleanup. Maximum 4,076 burst triangles, 73 nodes, 72 surfaces, one shared opaque cel material; no physics/shadows. Revised cold audit 16.331 ms, prepared p95/max 1.064 ms, maximum preparation unit 6.605 ms; retained arrays 395,624 bytes. Exact uniqueness/composition, saved/menu/network selection, actual match dispatch, RNG isolation, prepared cache reuse and three-overlap cleanup passed. Front/side/back gallery reviewed for missing faces and checker patterns. CPU audit does not measure GPU frame time.

- Lipsticks case revision: the same twelve models now contain four black, four gold and four silver lower cases, preserving gold collars and all lipstick shades. Each shade family contains all three case colors; runtime emits 24 of each case color. Atlas UV-only changes preserve topology, cache, surfaces and materials. Updated quota, save/network, actual-match and three rendered cleanup checks passed; no runtime errors. Import emitted three generic get_multiple_md5 file-access errors but completed and all models loaded. Before/after previews retained in the chat workspace.

- Railroad Spikes: Rare tier, available for testing; key railroad_spikes. Four 88-triangle octagonal-head atlas pins fly from freshly randomized safe local-camera positions (.095s flight, .08s stagger). At each actual delayed launch, refresh camera-safe origin and raycast actual hand/foot skin triangles; embed tip 6mm along that incoming ray. Incoming shaft direction remains the settled direction, with axial drill roll only and no final front-facing slerp. Pins remain skin-local and stop processing after all settle. Per-view angles are cosmetic and may differ across peers; no gameplay/RPC changes. Same-owner reconstruction reuses four stored local presentation transforms. Fresh snapshot restoration without that local presentation uses deterministic front-surface poses without replay; exact cross-peer final angles are not promised. 72 real-skin contacts and 6,822 flight-axis samples pass across both skins, three scales and angled views. Camera movement/clearance, timing, randomization, owner cleanup and ENet loopback checks pass; actual-match captures pass on both skins. Cold spawn3.147ms; prepared max .177ms on the lightweight audit fixture; real-skin spawn max .537ms and flight-update max .106ms. Mesh/cache unchanged:352 triangles,5 nodes,1 shared mesh/material,13,808 retained mesh-array bytes. CPU only, no GPU timing.

- Lipsticks metallic revision: coherent atlas reflection bands on existing cylinder faces, warm dark gold/cream highlights, neutral steel/white silver, polished black strips. Original lipstick shade UVs and balanced case counts preserved. Still 284 triangles/model and 20,448/burst, same shared material/cache. Rendered quota, selection/network, actual match and three cleanup checks passed without runtime errors. Editor import completed with generic get_multiple_md5 file-access diagnostics, as before; every model loaded. No new lights, probes, physics or reflection shaders.

- Salt: six short shakers at .78-.92 scale and 180 small salt granules, evenly divided into two shakers/60 granules per screen third. No classic/tall shakers emitted. Fresh random profiles and varied angles retained. Direct instances of two cached meshes reduce burst nodes to 373; 186 pieces, 3,264 triangles, one shared active material, no shadows/physics. Saved/menu/network appearance, actual-match dispatch, quotas, three overlapping bursts and zero remaining burst nodes pass. Prepared max/p95 2.881 ms, prep unit max 2.119 ms, retained arrays 48832 bytes (51,000 ceiling). Cold fallback 28.607 ms can hitch. Probe passes but reports two ObjectDB/one-resource shutdown warnings. Actual-match GIF rendered; no export.

- Lightning (current): three different cached branching bolts strike at 0/.12/.24 seconds from left/above/right, converging on the same highest visible skin vertex. Each holds for .30 real seconds and fades through .50s after its own onset; cleanup .85s. One shared atlas additive shader uses smooth transverse alpha falloff for blue-white glow; no real lights or global bloom changes. Three mesh nodes plus controller, 1,512 triangles, six cached variants. Pose/endpoint/slow-motion checks pass for 18 cases; actual-match simultaneous visibility, save/selection and dedup checks pass. Fresh cold spawn 3.252ms, prepared max .900ms, prep-unit max 4.734ms; cache/budget/overlap cleanup audits pass. Revised source and baked meshes installed; executable not rebuilt.

- Grass: 90 opaque atlas pieces (54 narrow clippings, 30 curved long blades, six seed-head stalks), twelve cached models. Each third has 18/10/2 family counts and ten pieces per size class; local RNG, gentle sinusoidal drift/sway and tumble, 3.2-second root cleanup. 10,032 burst triangles, 271 nodes, retained mesh arrays 376,608 bytes. Fresh-process cold 16.05 ms; prepared p95/max 2.705 ms; maximum preparation unit 2.249 ms (CPU only). Cache reuse, three overlapping bursts, quotas, save/network selection, actual match dispatch and three rendered cleanup checks passed. The shared render also logged unrelated missing salt_classic.glb and Space preparation 24.147 ms; these are not Grass audit errors.

- Grass seed-head correction: replaced symmetrical chunky pairs with fine staggered branches and smaller tapered spikelets; clippings and long blades unchanged. Revised burst 6,936 triangles, cached arrays 215,616 bytes (limits reduced to 7,300 triangles/230,000 bytes). Cold 14.5 ms; prepared max/p95 2.309 ms; maximum preparation step 2.411 ms. All quota/cache/overlap/save/network/actual-match/three-render-cleanup checks passed. Shared render still warned on Space preparation; no Grass errors.

Salt shaker visibility revision: six short shakers now start at y=-.2, launch upward at 1.55-1.95 with reduced sideways speed and gravity 1.35 (1.1 for large bursts). Granule trajectories unchanged. Full transformed mesh bounds checked over 24 randomized normal/large activations and 23,231 shaker frames at 34-degree vertical FOV, 16:10 aspect: zero exits from the inner 95% viewport before fade starts. Counts, geometry, material, timer cleanup and preparation budgets unchanged. Rendered revision capture completed (180 frames); inspected at 1.0 and 2.17 seconds with all six shakers still in view. Known native renderer shutdown crash occurred after capture. No export.


- Pan/Sweets flicker fix: pastel_rosa had sixteen coincident icing/bread side-wall pairs plus inward-facing icing walls. Rebuilt as a single outward-facing exterior meeting at z=.058, removing its hidden bread top (14 fewer triangles). Oreja had four coplanar differently colored cap overlaps; lifted pale trim from z=.034 to .043, clearing the dough. All other thirteen models byte-identical. Polygon-plane intersection regression now reports zero different-color coplanar overlaps across all fifteen recipes, and cake wall normals point outward. Matched full rotations rendered in house shading before/after without errors. Pan remains key pan/display Pan; shared materials and runtime behavior unchanged. Existing 72-piece burst now 115,623 triangles, 217 nodes, 15 cached meshes/2,655,228 serialized bytes. Cold CPU 22.263 ms; prepared maximum/p95 1.698 ms; maximum preparation step 2.214 ms; overlap cleanup passed. CPU audit is not GPU-frame/VRAM measurement; existing shadows and dense sprinkle aliasing were not changed.

- Trash: one dented can and one handled lid per burst (both enlarged 50%; all smaller scraps reduced to 50% of their previous linear size), plus 54 smaller scraps (6 cartons, 9 crushed tins, 12 crumpled paper wads, 9 banana peels, 9 apple cores, 9 fishbones). Exactly 18 scraps per screen third; can and lid choose distinct random thirds. Eight revised atlas meshes, shallow varied trajectories, 56 pieces, 113 nodes, 11,367 triangles, no physics/shadows. Two horizontal can handles, irregular folded paper, curled peel sections, stripe-free green apple core. Menu key trash/display Trash. Saved/menu/network appearance, actual-match dispatch, local RNG isolation, exact quotas, cache reuse and three-overlap cleanup passed. Cold 11.138 ms; prepared max/p95 .941 ms; max preparation unit 2.154 ms; retained mesh arrays 310,924 bytes within 325,000. CPU metrics do not measure GPU frame time. Actual-match GIF recorded; no export.


`nTrash can finish revision: removed alternating white atlas bands from the body; consistent neutral steel body and handles, restrained rim highlight and darker bottom seam. Existing rib/dent geometry retained, no added materials or triangles. Actual Godot close-up/import exit 0. Green apples and relative item scales retained. No export.

Salt random-flight correction (2026-11-14): six independently randomized starts, launch delays, velocities, arc heights, gravity, rotation and spin replace the three paired region trajectories. Quotas remain internal only; shaker flight never derives from the grain region. Bounded spawn-only selection avoids one-sided clumps without fixed lanes. Wider vertical variation was added after the first rendered check. Final 48-activation test: 48 unique sets, 196 crossing paths, 46,512 full-mesh frame-bound checks and zero failures; all shakers remain within inner 95% viewport until fade at FOV34/16:10. Grain spray, counts, sizes, geometry, cache and timers unchanged. Cost audit before final scalar arc tuning: prepared max/p95 3.450 ms, prep unit 2.121 ms. Final actual-match capture inspected. No export.

Trash coverage correction (2026-11-14): exactly one can and one lid plus 54 scraps retained. Scrap size increases from .5 to .9 of original base size (1.8x the prior revision); enlarged can/lid remain 1.5x. Scrap trajectories now sample independent destinations across the frame, not three organized regions; big can/lid retain slower arcs. Current steel finish and green apples retained. Same-camera eight-run average width at .7s: previous Trash 40.7%, new Trash 83.0%, Pan 91.2%; at 1.0s new Trash 99.8%. These are visible-mesh bounding unions, not filled-pixel coverage. Prepared max/p95 .999 ms; prep unit 2.120 ms. Counts/geometry/material budgets and overlapping-burst cleanup pass. Actual-match capture inspected. No export.


- Onions: key onions/display Onions, 90 cached atlas pieces (18 whole bulbs, 36 crescent slices, 36 dice), twelve models. Whole bulbs have fuller shoulders and short blunt tops/root tufts. Replaced slice hairline overlays with wider low-contrast bands partitioning each cut face; no separate near-coplanar overlay, no zero-area tip triangles. Dice byte-identical to baseline. Fixed per-third family/size quotas and bounded local random variation. 15,696 burst triangles, 271 nodes, twelve cached meshes/395,328 serialized bytes. Final cold CPU 15.418 ms, prepared max/p95 2.105 ms, prep max step 2.144 ms. All three overlap/cleanup, cache reuse, quotas, save/network, actual match and three rendered cleanup checks passed. Matched all-model rotations captured before/after. No texture UV swim or duplicate colored faces found; ordinary subpixel edge aliasing is not claimed eliminated. CPU metrics do not measure GPU cost or VRAM.


## Common effects integration (2026-11-15)

Current availability note: standalone Cherry Bomb was subsequently retired. The active catalog contains 34 effects from this batch; saved and network Cherry Bomb selections migrate to Ice Cream Social. The 35-effect list and audit table below are the historical build 0.3.122 validation record, not assertions of current availability.

Added 35 approved common cosmetics through Wardrobe, the existing lock-in dispatch, and bounded per-variant preparation. Shared house atlas/material; original approved geometry and motion retained. Cancelled Dog Fur, Snow Day and Bouncy Balls and pending Bees excluded. No entitlement system or gameplay behavior introduced.

Popcorn, French Fries, Pizza Party, Sushi Roll, Breakfast Club, Pancakes, Pretzel Twist, Cheese Please, Candies, Gummy Bears, Ice Cream Social, Cherry Bomb, Strawberry Fields, Citrus Splash, Banana Bonanza, Pineapple Express, Mushroom Mix, Coffee Break, Tea Time, Nuts & Acorns, Game Night, Love Letters, Music Notes, Pencil Case, Playing Cards, Puzzle Pieces, Sewing Kit, Toolbox, Bats, Assorted Bugs, Pinecone Shower, Flower Power, Seashell Shuffle, Autumn Harvest, Birthday Bash.

All 70 fresh-process cold/prepared audits passed finite geometry, node, surface, resident-mesh and serialized-array budgets; twelve spawn samples, three overlapping bursts and real-timer cleanup per audit. Serialized-array ceilings use measured bytes plus five percent. CPU results do not measure GPU frame time or VRAM.

|Effect|Pieces|Triangles|Prepared max ms|Preparation unit max ms|Cached array bytes|
|---|---:|---:|---:|---:|---:|
|Popcorn|72|24648|1.305|2.005|478784|
|French Fries|72|4680|1.276|1.985|134176|
|Pizza Party|72|4392|1.223|1.992|134336|
|Sushi Roll|72|9792|1.278|1.993|214208|
|Breakfast Club|72|11268|1.247|1.985|221616|
|Pancakes|72|6432|1.326|1.989|155552|
|Pretzel Twist|72|29952|1.284|2.013|389856|
|Cheese Please|72|7416|1.358|2.229|127936|
|Candies|72|10176|1.348|2.145|199152|
|Gummy Bears|72|29664|1.471|2.004|386112|
|Ice Cream Social|54|9240|0.767|2.002|458736|
|Cherry Bomb|36|5844|0.591|2.024|124576|
|Strawberry Fields|36|10080|0.536|1.990|262560|
|Citrus Splash|36|3384|0.545|2.011|88464|
|Banana Bonanza|36|5022|0.623|2.225|75432|
|Pineapple Express|36|3228|0.541|1.998|73952|
|Mushroom Mix|36|8280|0.586|2.005|143840|
|Coffee Break|36|5040|0.631|2.013|117088|
|Tea Time|36|2160|0.619|2.026|42128|
|Nuts & Acorns|36|9738|0.616|2.074|169112|
|Game Night|48|5412|0.702|2.013|141352|
|Love Letters|48|8520|0.704|2.004|444320|
|Music Notes|36|4944|0.630|2.032|129024|
|Pencil Case|48|4200|0.713|2.001|109840|
|Playing Cards|60|7520|0.832|2.001|235584|
|Puzzle Pieces|60|10320|0.968|2.022|161472|
|Sewing Kit|48|11832|0.718|2.011|308272|
|Toolbox|30|6792|0.553|2.053|176992|
|Bats|42|26040|0.769|1.993|580800|
|Assorted Bugs|48|30000|0.803|2.015|585480|
|Pinecone Shower|36|13200|0.852|1.983|343680|
|Flower Power|42|16520|0.754|2.134|368640|
|Seashell Shuffle|40|31240|0.816|2.028|975328|
|Autumn Harvest|30|20440|0.604|1.996|638208|
|Birthday Bash|42|6272|1.051|2.014|140256|

All 35 also passed customization save/reload, menu labels, common metadata, network appearance sanitization and real practice freeze dispatch. Five representative actual Forward+ match captures inspected (Breakfast Club, Ice Cream Social, Toolbox, Love Letters, Seashell Shuffle). Windows build 0.3.122 exported to the single builds/TopDog.exe and passed headless packaged smoke (exit 0; existing resource-teardown warnings remain). The native renderer shutdown code 3221225477 reproduced both on the previous untouched packaged executable and the new executable after successful rendered startup; it is not treated as a successful rendered exit or as a new-effects regression. No WAN session was exercised.


## Approved common revisions and storm update (2026-11-15)

Installed 16 reviewed effects: cheese_please, pancakes, sushi_roll, pizza_party, fries, coffee_break, strawberry_fields, ice_cream_social, tea_time, flower_power, autumn_harvest, birthday_bash, seashell_shuffle, pinecone_shower, bees, lightning. Bees is a new Common selection; the other fifteen replace reviewed assets/motion. Group1 preserves distinct per-region sequences (two whole cheese wheels total). Cherry Bomb remains retired and migrates to Ice Cream Social. Unrelated assets and settings preserved.

All 32 fresh-process cold/prepared checks passed; cache ceilings tightened to measured serialized arrays plus 5%. These CPU measurements do not measure GPU time or VRAM. Lightning has three overlapping translucent storm clouds, rain, and three separate strikes, 41 preparation units and a 1.65-second transient lifetime.

|Effect|Prepared max ms|Prep max ms|Cached bytes|
|---|---:|---:|---:|
|cheese_please|1.367|1.971|156800|
|pancakes|1.684|1.977|367872|
|sushi_roll|1.347|2.129|406400|
|pizza_party|1.232|1.988|194320|
|fries|1.714|1.967|255856|
|coffee_break|0.666|1.988|117088|
|strawberry_fields|0.536|2.108|767064|
|ice_cream_social|0.798|1.980|650232|
|tea_time|0.682|2.118|108896|
|flower_power|0.764|1.963|1161600|
|autumn_harvest|0.676|1.954|1173056|
|birthday_bash|0.727|1.966|342904|
|seashell_shuffle|0.450|1.977|2086672|
|pinecone_shower|0.899|1.930|500704|
|bees|0.676|1.988|247584|
|lightning|0.680|0.591|528248|


Lightning match foreground (2026-11-15): match attachment routes the existing three clouds, three bolts and rain to reserved 3D layer20. The gameplay camera excludes that layer; one shared transparent SubViewport/Camera3D draws it once, composited by CanvasLayer3 above both the world-space Lucha HUD and flat CanvasLayer1 HUD. Original effect ownership, highest-point tracking, timing, materials, cloud-over-bolt ordering and preview path are unchanged. The pass mirrors the gameplay projection/transform and output dimensions. Three simultaneous storms share four singleton nodes; per-storm geometry remains8nodes/2088triangles. The viewport and camera-sync processing disable after the final storm exits; retained framebuffer memory and one extra screen-sized render/composite pass while active are new GPU costs, not measured here. Headless actual-match routing, concurrent storms, moving perspective/orthographic alignment, preview isolation and cleanup pass; rendered opaque flat HUD and real3D lock-banner overlap comparisons inspected. No export/version change for this revision.


## Common effect launch alignment (2026-11-15)
All four common-effect emitters use `ui3d/common_effects/launch_frame.gd` to center their camera-local launch distribution at Y=0.4, matching the normal Pickles burst. Translate the burst root, not individual velocities or trajectory targets, so spread, speed, delays, sizes and gravity remain authored. Tea and Coffee retain their gentler motion and wider vertical distribution. Future common effects must declare their authored launch center and use this helper. `tests/common_launch_height_probe.gd` checks all 35 active common effects over twelve activations with a translated/rotated camera, plus the original Pickles reference. No model or particle-count changes.


Lightning decorative clouds (2026-11-16): three additional differently sized clouds surround the original strike clouds at left/right/upper-back. Separate CLOUD_COUNT=6 and STRIKE_COUNT=3 loops retain exactly three bolt sources; original source positions, rain quota24, opacity, timing and foreground pass unchanged. All six reuse one baked cloud mesh/material, so cached arrays remain528248bytes/eight meshes. Per storm now11nodes/2472triangles (three extra mesh instances and384triangles); triangle ceiling2596. Fresh cold/prepared audits passed, preparedmax.696ms, maxprepstep7.122ms, three-overlap cleanup0. Highest-pose, actual-match three-strike and foreground/preview/resize/input regressions passed. Rendered six-cloud HUD-overlap preview captured. No export or version change.


## Reviewed revisions installed (2026-11-18, build 0.3.130)
Four Strawberry Fields fruit meshes replaced; six variants/36 pieces unchanged. Measured53,712 triangles and1,396,992 cached array bytes; specific limits56,398 triangles/1,466,842bytes. Food elote replaced only: six elotes within original90piece quota, fullburst38,082 triangles/962,932cached bytes; limits39,987triangles/1,011,079bytes. Rounded five-cloud Lightning uses original three strikes, white tops/dark bottoms, local blue-white underside illumination driven by bolt brightness;10nodes/8,904triangles/786,300cached bytes, limits9,350triangles/825,615bytes. All cold/prepared checks, cleanup, frozen-pose/foreground/match tests passed. Trash and IceCream compact launch origins retained and tested. Vines remains staged and excluded. GPU cost not measured.


Banana Bonanza approved model revision (2026-11-18): whole, peeled and slice replaced; enclosed lower peel sleeve and three attached broad folded strips. Original36-piece quota and emitter unchanged. Imported48,204 burst triangles, triangle limit50,615; cached arrays 716592bytes, limit752422bytes. Cold/prepared audits and saved selection/network/actual-match dispatch passed. Source-only install; no export/version change.
