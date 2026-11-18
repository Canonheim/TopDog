# Player XP — 100 levels

Match earning is enabled in source. Cosmetic unlocks are still Coming soon; no existing cosmetic is removed or gated. Piñata spawning is unchanged.

## Level curve
Start at level 1. The cost to advance is 10,000 + 1,000 × (current level − 1) XP. Examples: level 1 costs 10,000; level 10 costs 19,000; level 25 costs 34,000; level 50 costs 59,000; level 99 costs 108,000. Level 100 is the cap, at 5,841,000 cumulative XP. The belt formats large numbers with commas and retains its fill/stars/fireworks animations. Old version-1 totals are multiplied by 20, preserving level and progress through that level. F4's temporary test steps are now 2,000 XP and never write saves.

## End-of-match payout
| Category | XP | Limit per match |
|---|---:|---|
| Finish a qualifying match | 2,500 | Once |
| Win | 4,000 | Once |
| Confirmed knockout | 1,500 each | Once per player for the entire match |
| Successful lock-in / timeout attachment above line | 200 each | No match cap; once per player per round |
| First lock-in of the round | +200 | First successful player each round |
| Stuck the landing (special trick) | 2,000, then 1,000, 500, 250... | Each repeat halves this trick’s award within the match |
| Rising while airborne | 25 per accumulated whole second | No match cap |

No fixed match payout ceiling: lock-ins and upward airtime continue earning throughout the match, subject only to the level-100 progression cap. Example: finishing and winning with one KO, four lock-ins, two first-of-round bonuses, ten rising-airborne seconds and two clean-flip tricks earns 12,450 XP. The first lock-in in a round totals 400 XP (200 regular + 200 bonus); subsequent players receive 200 XP. Each trick's repeat count resets next match. Halving rounds down to whole XP (2,000 / 1,000 / 500 / 250 / 125 / 62 / 31 / 15 / 7 / 3 / 1 / 0...). Match completion and victory remain once each. Active movement is used only for eligibility, not an XP award. Rates are initial balance values to tune from real matches.

## Attribution and eligibility
- Completed Classic/Tower/Del Mar multiplayer or local matches, at least two roster players, at least 20 active round/turn seconds. Practice, Peak, lobby, bot-driver matches and abandoned matches do not pay.
- Each player needs at least 3 seconds of movement, a successful lock-in, a credited knockout, or a clean-flip trick. Eliminated players who stay through results can earn participation and their accumulated bonuses.
- The host samples centre-of-mass movement at 10 Hz. Movement over 0.15 m/s counts as active. Airtime requires rising over 0.25 m/s and no attachment to solid support (including through another player); falling and standing/climbing attached do not count. Fractional seconds accumulate across jumps. Respawns, grow-in and displacement spikes over 30 m/s are excluded.
- Guest poses include their owner's airborne flag, matching the existing owner-simulated physics model. The host calculates awards, sends a reliable results payload, and clients never submit XP totals.
- Current game KOs are chair head impacts. Credit goes to the chair holder/thrower only after the victim owner confirms a new knockout. Self hits, environmental falls and repeat packets do not earn KO XP. Host hit evidence expires after 2 seconds. A future non-chair KO mechanic must add a confirmed attacker event to the same tracker.
- One saved progression profile per installation, matching existing save conventions. In couch multiplayer the first owned slot earns that profile's payout; guests' XP is not pooled into it. Online each machine earns its own first owned slot's payout. Steam account scoping and tamper-resistant backend validation remain future work; this is not a server-backed economy.

## Persistence and presentation
`core/player_progression.gd` saves version, total XP and the most recent 256 claimed match IDs together using a temporary file and rename. The host generates a fresh random ID for each match/rematch. Repeat results are ignored in Game and repeated grants are ignored by the save ledger. Malformed saves are not overwritten. Failed writes are reported on the results panel. At the level cap only remaining XP is banked; the breakdown still shows earned XP.

The finish screen uses the championship XP belt. Positive bonus categories appear one at a time above it; each counter drains into the filling bar with a small stream of atlas-colored stars. Level crossings trigger the existing three-color fireworks. A running tally ends at the exact saved total. XP is saved before the presentation starts; Back or Rematch safely settles and cancels the animation. Returning to the title displays the settled total without replaying the same gain. Zero-value rows are skipped, the level cap is respected, and a failed save displays an error without feeding unbanked XP. tests/xp_tally_probe.tscn covers sequential categories, crossings, exact totals, duplicate display, early exit, failed saves, and level cap.

## Cosmetic tiers (planned, not enforced)
Level 1 starter bundle. Levels 2–99 repeat categories by final digit: 1 skin color, 2 speedo color/pattern, 3 adjective pool expansion, 4 head/accessory, 5 lock-in effect, 6 skin variant, 7 speedo variant, 8 adjective pool expansion, 9 adjective-linked aura, 0 milestone bundle. Level 100 capstone bundle/title. Each level needs a unique authored reward ID before unlock enforcement ships. Dusty can unlock dust motes; aura eligibility follows its adjective. No gameplay stat bonuses. Preserve currently owned cosmetics.

## Checks
`tests/match_xp_probe.tscn`: all level boundaries, caps, arithmetic, excluded motion, repeat victims, duplicate locks, idle/short/practice exclusion, migration, atomic replacement, deduplication, corrupted-save preservation.
`tests/match_xp_network.tscn`: two ENet peers within one Godot process; guest airborne flags, actual remote chair knockout/confirmation, attacker credit, duplicate KO/result suppression, synchronized match ID and payout.
`tests/xp_gain_probe.tscn`, `tests/xp_dev_probe.tscn`: updated scaled XP display/animation and temporary developer controls. `tests/match_xp_preview.tscn` renders the belt and payout panel without writing player XP.


## Special tricks and live notices (2026-11-17)
Special tricks use diminishing returns per player, per trick, per match: each repeat is worth half as much, rounded down. Apply this rule to future special tricks too. Knockout XP is awarded only once per player in the entire match; lock-ins and upward airtime have no match cap. Active-minute XP has been removed. Every granted increment emits a host-routed achievement notice only to the owning machine; match completion and victory appear when results arrive. The live notices describe pending bonuses, not an early save; match eligibility still applies at payout.

Stuck the landing: initially 2,000 XP, halved each repeat, for a full net clockwise or counterclockwise torso revolution (not accumulated back-and-forth rocking) during at least .35 seconds airborne, then a feet-only landing. Both feet must settle for .30 seconds, the torso must be within 40 degrees upright and vertical speed below 1 m/s. One foot may arrive first, but both must settle within one second. Contact/grips with hands, head, other body parts or live opponents invalidate the attempt. Respawns, knockouts, water, grow-in and implausible angle jumps reset it. One multi-flip jump is still one landing. Existing physics contact records and weld information are read; no collision queries/raycasts or physics changes are introduced. Standing grounded climbers take a fast path. Remote owners report sequence-numbered accomplishments; host checks owner, phase, live character, cooldown and diminishing reward count under the same trusted-owner physics model as other movement.

Loot and XP share the original top-left notification area, newest first. Recurring upward-airtime XP coalesces while visible and moves to the top. Trick awards remain separate so the diminished value is visible. At most three active cards (fewer in short windows); a new notice pushes out the oldest, which fades away over 0.25 seconds and never returns. Only one outgoing fade exists at a time. This dismisses the notice, not the unlocked loot. XP cards are text only and use the menu font; they do not allocate the loot glow viewports. Existing loot rarity styles are preserved.

Validation: landing_xp_probe covers forward/backward/double/partial rotations, rocking, hand catches, faceplants, staggered feet, single-foot rejection, spawn rejection, diminishing rewards and round-first bonuses, live thresholds, stack ordering/coalescing/overflow/cleanup. landing_physics_probe uses actual body transforms and floor contacts/welds; local measured detector CPU median 32 us, p95 72 us, maximum 110 us during 180 airborne checks (a bounded test, not a promise of zero whole-game frame spikes). match_xp_network covers owner reporting, live notification delivery, duplicate packets and forged ownership. landing_notice_preview renders mixed notices and the seven-row results breakdown without granting saved XP.


## Compact finish-screen variant and preserved backup (2026-11-17)
The active finish tally is a narrow gold/red championship plaque connected to the leaderboard's right edge. It shares the board's hanging motion, with the level medallion, turquoise stars, XP meter and category countdown retained. Fireworks are localized. The camera centers the podium/tower within the remaining clear area to the right.

The approved full-size version is preserved byte-for-byte in `ui3d/xp_match_summary_full_backup.gd`. Set `LuchaUI.COMPACT_RESULTS_XP` to `false` to restore that layout, its original position/scale, and its original results-camera framing. The title XP belt remains unchanged. The previous visual preview is retained at `C:/Users/growi/Documents/ChatGPT/Top Dog/previews/finish-screen-xp-tally.gif`.


### Practice development controls
F4 toggles a global red DEV MODE indicator at the bottom center on every screen.
While enabled in offline Practice, Numpad Enter toggles a paused preview of the
results board and XP tally. Back, Escape, Rematch, or disabling dev mode resumes
the same Practice session. This replaces the former Numpad Enter pinata test.
Numpad + grants and saves three separately tallied 1,500 XP rewards (4,500 total),
including while the preview is open; held-key
repeats are ignored. The title belt remains a saved-progress display.
The global F4 toggle also arms/disarms the existing Peak bracket warp controls.
Validation: tests/practice_xp_dev.tscn uses a temporary progression file and checks
that the real save is unchanged. Pass -- --no-steam --no-capture to skip GIF frames.
