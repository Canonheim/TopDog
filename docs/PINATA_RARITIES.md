# Cosmetic pinata collectibles

The five scenes are `game/cosmetic_pinata_white.tscn`, `_green.tscn`, `_blue.tscn`, `_purple.tscn`, and `_red.tscn`. The base scene defaults to White. All use the house atlas, a local rear-star glow, tip decorations, camera-facing centering, and opposite star pulses. No surrounding ring lines.

`game/pinata_director.gd` performs one host-controlled 10% roll per active turn (Tower) or round (Classic/Del Mar). Practice, Peak, and solo rosters are excluded. Uncollected items despawn at round end. Collection triggers the shared burst and an individual reward pull for every roster player (see Individual reward pulls below). Reliable generation-tagged RPCs synchronize spawn and collection, and client-side contacts cannot collect independently.

## Rarity distance

At round start, snapshot the farthest collision-surface point belonging to a frozen tower climber in the XY gameplay plane. Ignore live bodies and props. Measure straight-line distance from a fixed ground-level anchor: plaza `(0,0)`; Del Mar `(Stage.PIER_END - .445 * barrel_scale, Stage.DECK_Y)` = `(103.0655,0)`. These anchors never depend on the selected base mesh or transform.

Tier spacing is `7 * max(2, configured climbers per round) / 2`, fixed at match start. Current turns and round-robin formats use the two-player baseline. Future simultaneous modes default to their starting roster count and can declare `climbers_per_round` in their mode row. Eliminations and disconnects do not reduce spacing.

For current modes, distances below 7, 7–under 14, 14–under 21, 21–under 28, and 28+ select tiers 1–5. As of 2026-11-22, white spawn odds are folded into green. Color percentages, ordered White/Green/Blue/Purple/Red, are `[0,100,0,0,0]`, `[0,100,0,0,0]`, `[0,80,20,0,0]`, `[0,65,25,10,0]`, `[0,55,25,15,5]`. Thus below 14 units is always green; higher-color odds and thresholds are unchanged. White/common reward drops and the separate reward table are unchanged. Round count no longer selects rarity. No additional new-growth gating has been added.

## Spawn geometry

Vertical maps place the entire pickup sphere at least 5 units above ground, around the upper tower, with moderate side gaps and occasional farther sling targets.

Del Mar uses the invisible vector from the fixed anchor to the farthest frozen point, not the map's diagonal progress line. Candidate positions follow the tower's outer reach. The full hitbox must remain between 3.5 units below and 5 units above that vector, measured perpendicular to it, with the perpendicular oriented upward. Additionally, the entire hitbox must lie beyond the pier end (x > 104) and at least 5 units above deck level. Dock-side lock-ins must clear the fixed initial world-space launch boundary, regardless of camera projection; failed bodies behind it are removed as supports. Before any frozen body exists, use an upright frame at the anchor and Tier 1. No reference line is rendered. Reachability is not guaranteed: some placements deliberately demand difficult throws or player chains.

Both modes reject positions too near frozen tower geometry or overlapping terrain/players/props. Skip spawning when no valid candidate exists.

Validation: `tests/pinata_integration.tscn`, `tests/pinata_geometry.tscn` (800 samples/four angles/all bases), `tests/pinata_network.tscn` (two ENet processes), and `tests/pinata_probe.tscn`.


## Individual reward pulls (2026-11-14)
Collection now broadcasts a host-created receipt and random seed. Every roster player on each owning machine gets a separate, deterministic pull, including locked-in players. Local guest slots have separate inventories; Steam accounts use separate save files. Replayed collection receipts cannot issue extra pulls.

`data/pinata_rewards.json` owns the reward weights separately from spawn weights. It reuses the previously approved five percentage rows; the earlier Models chat documented those rows as spawn odds, not a separate loot table. The `items` array is intentionally empty until Parker assigns unlockables. Author each item as `{ "id": "effect:roses", "name": "Roses", "rarity": 2 }` (example only, NOT an assignment). Rarity is 0 white/common through 4 red/legendary. No existing cosmetic is gated or reclassified.

Owned item IDs are excluded before rolling. Empty/exhausted rarity pools are excluded and remaining eligible weights are normalized. If all eligible pools are empty, the pull is saved for later instead of awarding a duplicate or consuming it. Pending pulls are reconsidered on a subsequent collection after the catalog is populated. Saves use account-scoped SavePaths files, local slot inventories, and an atomic temporary-file replacement.

Award notices queue at bottom right. Common text is grey with a white aura; other rewards use white text and their own rarity color, with progressively larger/brighter glow through legendary red. Pending pulls do not claim that an item has been unlocked.
