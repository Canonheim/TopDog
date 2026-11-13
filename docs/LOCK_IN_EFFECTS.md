# Lock-in effect implementation standard

User-approved standing requirements (2026-11-11). Apply to every future lock-in effect added to TopDog unless the user explicitly changes these requirements.

- Each activation must visibly vary while preserving the effect's intended launch, motion, timing and character. Use a fresh local RandomNumberGenerator per burst so cosmetic randomness does not disturb gameplay RNG.
- Use bounded randomness within overlapping directional bands and height layers. Do not use unconstrained random directions that can leave large empty regions or a visible lull while everything goes offscreen. Include lower and higher trajectories so coverage overlaps throughout the active burst; normal ending/cleanup is still expected.
- Balance object types, mesh variants and sizes across left, center and right. Reserve quotas per direction before jittering. Larger pieces, streamers or whole roses must not all end up on one side. Keep size jitter modest or stratified; randomness must not undo the quotas.
- Keep particle budgets bounded. Cache and reuse meshes/materials; use the game's color atlas and visual style. Choose variation at spawn time rather than generating geometry or allocating resources every frame. Extra emitters have overhead: measure if materially increasing their number or complexity.
- Preserve the approved Bills effect unless the user asks to alter it. It already has randomized motion and continuous stratified coverage; it was intentionally excluded from the later confetti/rose shape-balancing adjustment.
- Integrate through the existing customization and lock-in dispatch paths, and verify an actual match lock-in uses the selected effect.
- Validate several activations: distinct burst profiles, fixed totals, balanced type/size quotas by direction, proper cleanup, and no large mid-burst empty patches. Inspect actual rendered motion; numeric quotas alone do not prove visible coverage. Use game-rendered previews when requested.

## Current examples

- `ui3d/confetti_effect.gd`, via `lucha_ui.confetti()`: 90 normal / 300 winner pieces; each screen third receives identical quotas of curved paper, discs, stars, S-streamers and spiral ribbons. Fifteen overlapping lanes and six height layers, stratified sizes, cached two-sided atlas meshes, local burst RNG and tumbling/flutter motion. Existing Confetti selection and winner dispatch are preserved.
- `ui3d/rose_petals.gd`, `burst()`: six bands with all six petal variants, two of each per band (72 petals); 18 whole roses distributed across six lanes and three height layers, with a balanced mesh/size mix.
- `ui3d/peso_bills.gd`, `burst()`: 72 bills in twelve lanes and six height layers, retaining 36 curled, 30 folded and six crumpled forms. Leave its approved behavior intact.
- `tests/lock_effect_gif.gd`: capture/check harness for the current balanced confetti and roses. Extend/adapt checks for a new effect rather than assuming the harness already covers it.

These are implementation patterns, not a requirement to copy the same particle counts or exact silhouette for every new effect. Preserve each new effect's identity while meeting variation, coverage, balance and performance requirements.
