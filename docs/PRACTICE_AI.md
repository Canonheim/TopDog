# Practice NPC behavior

NPCs use the same limb driver and physics as human players. There is no trained neural model, extra force, teleport-to-grip, automatic hit, or relaxed lock-in rule.

## Practice lifecycle

The selected AI mode lasts for the practice session. Stationary and unfinished climbers remain present between rounds. A locked NPC becomes a permanent tower piece with a unique climber ID, and the next round gets a new NPC of the selected difficulty. No NPC disables future spawns without deleting already-built tower pieces. Ending practice clears all NPCs and their tower pieces.

## Difficulty profiles

- Easy chooses a varied route offset and, on subsequent attempts, a random approach side. It takes the first legal lock-in rather than holding out for a tactical pose.
- Hard evaluates real upward-facing surfaces for launch shelves, favors its own approach side, and avoids repeating the last placement when practical. At a legal finish it can spend up to 1.2 seconds extending a free foot toward its own side and an arm over the opposing approach. It keeps real support and abandons posing when moving too fast or in danger. Useful geometry is an attempt, not a guarantee that every pose is harder for a human opponent.
- Hard prioritizes recovery over short, local combat opportunities, aims chair swings at the head, and limits both attack and escape attempts so it can return to climbing.
- Both profiles remember unsuccessful reaches. Hard changes its driving limb and replans stalled routes sooner; Easy does so more slowly.

## Repeatable calibration

Run `res://tests/battery.tscn` with `--no-steam --aicalibration`. Optional filters are `--ai-base=barrel|bell|cactus|donkey`, `--ai-mode=tower|delmar`, `--ai-seed=47`, and `--ai-level=easy|hard`. `--ai-baseline` disables adaptive stall recovery and uses the earlier conservative pose-speed limit for comparison. Calibration reports measurements rather than treating every failed climb as a broken rule.

Default trials use seeds 11 and 29, both difficulties, two successive rounds, and a maximum 4,800 physics ticks per attempt. Each trial starts in a cleared arena. The second attempt retains the first locked NPC as real tower geometry. The opponent is passive; these results are not a measurement against an experienced human.

Rule regressions are `--practiceairounds`, `--practiceairules`, and `--practiceaicombat`. The pause-menu and spawn regressions run in `res://tests/practice_ai_menu_probe.tscn`.

## Calibration results — 2026-11-11, build 0.3.86

64 controlled comparison attempts (32 baseline, 32 tuned), plus 8 validation attempts with a fresh seed. Each profile had 16 tower attempts per policy across the four bases and two successive rounds.

| Profile | Baseline completed | Tuned completed |
| --- | --- | --- |
| Easy | 11/16 | 13/16 |
| Hard | 9/16 | 14/16 |

These are fixed-budget completion counts, not win rates. Some attempts still stalled; the fresh-seed tests completed 3/4 barrel attempts and 2/4 Del Mar attempts. Earlier exploratory runs with leftover arena colliders were excluded. Complete measured outcomes, including failures and attempted placement tactics, are in `practice-ai-calibration-2026-11-11.json`.

## Del Mar correction — build 0.3.87

Progress and grip scores now follow Del Mar's diagonal finish direction. Reachable transfers are evaluated before fallback swing pumping. When progress stalls, the AI cycles pinned anchors instead of lifting the same regripping hand indefinitely; live-player grips are distinguished from solid wall grips so the release motion does not pull backward unnecessarily.

The original seed-47 two-round replay improved from 2/4 to 4/4 completed climbs. The wider Del Mar matrix completed 27/32 within the original 4,800-tick budget; five difficult cactus or stacked-body cases still stalled. Full outcomes are saved in `delmar-ai-regression-2026-11-11.json`.

To enforce the repaired replay as a regression, run the battery with `--no-steam --aicalibration --ai-mode=delmar --ai-seed=47 --ai-require-success`. `--ai-trace` records periodic grip positions, the measured score, target line and current intent. The engine's `--fixed-fps 120` option accelerates headless runs without changing the physics step; compare outcomes and tick budgets, not their wall-clock timing.
