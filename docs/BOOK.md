# THE BOOK: Top Your Pals

Decisions, rules and the record. Read this before any work. The plan is
`../PLAN.md`; this book is what actually happened and what holds now.

## Parker's calls (2026-11-07)

1. **Physics: 2D from the start.** Built that way first; it failed the gate and was reversed (next section).
2. **Failed climbers stay frozen in the tower.**
3. **Torso flex is a passive spring only.** Reaching left or right bends it, because the limb motors push on the torso.
4. **The climber is the Metal Knight** for now. His artist is making skins on the 16-piece Defaultio contract.
5. **Steam: test on app 480 first.** Parker makes the real app.
6. **GitHub: the Canonheim account.**
7. **A new music track.**
8. **New game, new rules:** plain screen menus.
9. **Scramble:**
   - Same timer as Tower, with everyone at once.
   - Every lock-in above the line raises it, so it's a race to the easy spots.
   - The round ends when everyone still in has locked in above the line.
   - The next round starts at the previous round's max height.
10. **Live climbers can grab each other.** A grabbed climber can still drive its limbs even with nothing of its own stuck.

From the reference game, as Parker described it: **you can only move limbs while attached.**

## The physics call (2026-11-07): Godot 2D failed, Jolt on a plane passed

The spike ran on Godot's built-in 2D physics first, as Parker asked. It failed in three ways.

- **The pin joints' angle limits don't hold at all.** A pushed piece spins straight through them (`tests/limit_probe.gd`). Script-side limits (springs, then spin corrections) were tried and only partly worked.
- **The joints stretch.** A 16-piece body hanging by one hand opened 4 cm. Full-strength swings opened them **1.4 m**, with limits **170° past** their stops.
- **The same stress test on Jolt failed far less.** In `tests/engine_probe.gd`, 8 links under big alternating torques:

  | Engine | Worst joint gap | Limits |
  |---|---|---|
  | Godot 2D pins | 0.33 m | none |
  | Jolt hinges, locked to a plane | 0.03 m | real limits, 23° over under absurd torque |
  | Plane drift on Jolt | 0.0000 m | |

**So the climber runs on Jolt.** Every piece is locked to z = 0: linear z, angular x and angular y are all locked. It plays exactly flat, which is what the 2D call was for. The 2D climber is kept for the record in `docs/spike/climber_2d_godotphysics.gd.txt`.

**Jolt settings:** 120 Hz, `velocity_steps=20`, `position_steps=8`.

**Limb control is Jolt's hinge motor:** a velocity motor with a torque cap, solved inside the engine, so it's stable at any stiffness.
- **A driven joint** chases its two-bone aim at up to 14 rad/s, capped at `strength × body weight × reach`.
- **A loose joint's motor** holds still with a small torque: the joint friction, Feel `limp_friction`.
- **The spine, neck, wrists and ankles** are motors pulling home.

**Two laws found on the way:**
- **THE LATE TRANSFORM LAW.** A physics body's new transform reaches the server only at the frame flush. A joint made right after a move anchors to where the body was: 2D pins built that way tore 2 m apart. Call `Climber.sync_server(body)` after moving a body.
- **The hinge signs are pinned by a test.** Jolt's motor velocity and hinge angle both run clockwise about +z, so `MOTOR_SIGN = -1` and `LIMIT_FLIP = true`. `--spike --part=signs` proves it.

## The P1 spike, final numbers (Jolt)

| Test | Result |
|---|---|
| signs | motor and limits as pinned: PASS |
| limits | shoved at 2× an arm's weight, 2.6° overshoot: PASS |
| hang, 30 s by one hand | joints 0.9 cm; settles; never leaves the plane: PASS |
| fling, 20 full-torque swings and releases | joints 2.9 cm, limits 11° over, top speed 12.9 m/s, 20/20 fling: PASS (limit threshold set at 15°) |
| limp | loose means no drive; drives the tick a held hand sticks: PASS |
| tower, 20 frozen + 1 live | physics frame 0.9 ms average: PASS |
| eight live, tangled in grab loops for 20 s | 1.85 ms average. **Joints up to 7.7 cm in the worst moment.** PASS at a 10 cm threshold: random 8-body grab loops are the hardest case for any solver |
| chain: A on B on C, C freezes | nobody drops; B's hand slips 6.5 mm; joints 5.8 cm with two climbers on one wrist: PASS at 8 cm |

**Climbing proof:**
- `--pullup`: one arm lifts the hanging body 0.50 m.
- `--climb`: a scripted climber grabs the barrel's top edge and pulls its head 0.14 m above it, which is lock-in height.

A full scripted climb onto the barrel top isn't written. The feel is Parker's walk.

## The game rules (game/game.gd)

- **Modes are rows** in `data/modes.gd`: who's live, the line rule, the round end, who's out, and the win.
- **The host decides** the clocks, the line, lock-ins (ordered by arrival), who's out and the results. Offline, the machine is the host.
- **Lock In** works once your highest point clears the line by 2 cm.
- **Tower:**
  - The line is the tower's top at the start of the turn.
  - Time out above the line means you made it; under it, you're out.
- **Scramble:**
  - The line starts at the last round's max (the barrel top in round 1).
  - A lock-in raises it to the locker's top.
  - Not locked in at time out means you're out.
  - If everyone left fails in the same round, the highest of them wins.
- **The barrel** is 2.02 m tall (scale 2.1), just over a standing knight's head (1.77 m). A climber can't lock in from the deck, but can reach the top edge.
- **Out of bounds** (into the sea, or off the sides) respawns you with the clock still running.

## Netcode (as built)

- **The stream:** each live climber is simulated by its own player's machine and streams 16 piece poses at 30 Hz, unreliable, with sequence numbers.
- **Puppets** are kinematic, play back 0.1 s behind, and are solid, so you can bump and grab them.
- **The freeze:**
  1. The host sends "freeze".
  2. The owner freezes and sends its final pose.
  3. The host broadcasts the pose.
  4. Every machine builds the same static body from it, so **towers are identical everywhere** (tested to 0.000000).
- **Grabbing a rival on another machine:**
  - The grabber rides the puppet at once and tells the owner, which counts it as "attached".
  - It sends its estimated pull at 30 Hz: `m(a − g)`, shared over its attachments and capped by Feel `pull_cap`.
- **Leaving:** a peer that leaves freezes as last seen and is out. If the host leaves, the match ends.
- **Joining:** a version mismatch is refused, and so is a join mid-match.

## Known gaps (as of the first build)

- **Nobody has played it yet.** The feel numbers are first guesses, tunable live on F1.
- **Steam has never been run on Steam.** The lobby code is lifted from Golemheim's working code and compiles, but needs two accounts on two machines.
- **The network test has no added lag or packet loss.** It runs over real ENet loopback.
- **Bumping across machines is one-way.** Your body is pushed by a rival's puppet, but the push isn't sent to the rival's machine. Only grabs send force.
- **No spectating mid-match.** Late joiners are refused.
- **Real pads are untested.** Pad joining and rebinding were tested with fake devices only.
- **The look is first-pass:** plain StandardMaterial knights with a colour wash (no house cel/ink shader yet), and a simple dock built from primitives.
- **The music** needs Parker's ear.
- **No GitHub remote yet.** `gh` isn't installed here, so the Canonheim repo needs creating, and nothing is pushed.

## Record

- **2026-11-07:** plan, then P0–P7 in one session.
  - The 2D spike failed; the game moved to Jolt on a plane.
  - All batteries pass.
  - A release export boots.
