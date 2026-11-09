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
- **The look:** the house style is in (see below), but the dock is still built from primitives, and the Metal Knight's player-colour wash reads dark.
- **Quitting exits with a crash code (139).** That's the known Godot 4.7.2 shutdown crash with the ink compositor (the house style kit records the same). The game itself is fine.
- **The music** needs Parker's ear.
- **No GitHub remote yet.** `gh` isn't installed here, so the Canonheim repo needs creating, and nothing is pushed.

## Pads in the menus and the house look (Parker, 2026-11-07, build 0.1.1)

Parker: "I can't seem to control the main menu with my controller... make it work". Then: "give it the same art style as golemheim, with the outlines and shaders".

**Pads in the menus (`ui/pad_nav.gd`):**
- Every connected pad is read directly, and its presses become `ui_up`/`down`/`left`/`right`/`accept`/`cancel` events. The stock pad events are stripped from those actions, so nothing counts twice.
- Holding the D-pad or stick repeats.
- A pad press always lands the focus: the first press with nothing focused only focuses.
- B (or Escape) goes back one screen.
- Every menu shows a pad legend.
- The Controls screen shows a live readout of the connected pads and the last pad input the game saw. If a pad ever goes deaf, that readout says whether the game is getting anything at all.
- `tests/pad_probe.tscn` drives the real menu with raw pad state (windowed): it moves, presses A, and goes back with B.

**Steam starts late.** Steam now starts when the Online screen opens, not at boot. It also starts on `+connect_lobby`, or at boot with `--steam`. The suspicion is that on the shared dev app (480), Steam's controller layer can apply Spacewar's controller setup and take the pads from the game. That was **not proven**: synthetic presses worked with and without Steam, and only Parker's hands can test the real case. Our own app ID ends the question, because its Steam Input settings will be ours.

**The house look:**
- Copied from `Desktop\House Style 3D Kit`: `shaders/cel/`, `palette/`, `scripts/cel_pass.gd`, `scripts/atlas_map.gd`, plus the five shader globals and `rendering/house_ink/profile="stabilized"` in `project.godot`.
- Rendering is FXAA with no MSAA.
- **The knight and barrel** are on the shared atlas, with their uris pointing at `../palette/house_atlas.png`. They're celified when built.
- **Code-built dressing** uses `CelPass.cel_material`.
- **The ink** is `CelPass.add_outline_pass(Main)`.
- **The player colour** is a per-climber copy of the cel material, with its `color` set to the wash.

## 0.1.2 (Parker, 2026-11-07): quit, pads again, limb glyphs, new music

Parker: "quit is not working, and also the controller is still not working, also the glyphs for each hand and foot should be on the part like in MYF... Also the music is terrible, try again... Make it Fun and jazzy and smooth."

**Quit.** The exported release build crashes (exit 139) about two seconds into its own shutdown, with Steam or without it (`--no-steam` proved it isn't Steam); the editor binary exits clean. A crashing teardown can leave a frozen window or a crash dialog. `quit_game()` now leaves the session, shuts Steam down (`Net.shutdown()`), pulls the ink pass off the world, waits two frames, and then an exported build **ends its own process** (`OS.kill`) instead of walking into the crash. Options and binds save the moment they change, so nothing is lost. The window's X button goes through the same path (`auto_accept_quit = false`). Measured: the exported game is gone in under two seconds after quit, exit code 0. `--slow-quit` runs the normal teardown for anyone hunting the crash.

**Pads, second pass.** The menus now take pad input by **two paths**: polling every connected pad each frame (as 0.1.1 did) AND the joypad events arriving in `_input`. Both feed one held-state table, so a press seen by both fires once. Steam starts at boot again, as Golemheim's does. **The on-screen pad readout** is the new tool: the bottom line of every menu shows the pads the game sees and the last pad input it received. If Parker's pad is listed there but the line never changes while he presses, nothing is reaching the game at all (then it's Steam Input's desktop layout or another app holding the pad; the Controls screen says so). If the line changes but the menu doesn't move, the fault is in PadNav and the readout says which button arrived. `tests/pad_probe.tscn` drives the real menu with raw pad state and passes; it can't stand in for Parker's hands.

**Limb glyphs** (`Climber.set_glyphs`, `core/glyphs.gd`): each hand and foot wears its bind's picture (Kenney prompts: LB/RB/LT/RT on a pad, mouse buttons and keys on the keyboard), billboarded, drawn over everything. Dim when loose, bright while held, green when stuck. Hidden on a frozen body. Only the local player's climbers wear them. Feet glyphs step outward so they don't overlap.

**Music, take two** (`tools/music/theme.py`): a swinging jazz loop in Bb at 126 bpm, 32 bars AABA, 61 s, seamless. Walking acoustic bass, brush kit, tine electric piano comping Charleston figures on rootless voicings, soft jazz guitar on all four, vibraphone on the tune, muted trumpet taking the second chorus, flute on the bridge. Triplet swing. Needs Parker's ear.

## 0.1.3 (Parker, 2026-11-07): the reference game's limb rule, its controls, device swapping, a pause that works

Parker: "quit to menu still doesn't work and the controller still doesn't work at all. Also the controls are not the same as MYF and for some reason you cannot control a limb unless it is attached. Look at how MYF does it. You should be able to control a limb as long as any limb is attached to something. It unattached and cannot stick once you are holding it down. I am mostly trying the practice mode." Then: "make the game detect your input so you can swap between keyboard and mouse and controller whenever you want and the glyphs change correctly too."

**THE LIMB RULE, the reference game's way** (`Climber._tick_limb`). I had it backwards (hold to stick). Now:
- A hand or foot that is **not held sticks to whatever it touches, by itself**, and stays stuck. You spawn standing because your feet stick to the deck.
- **Pressing** a limb's button **picks it up**: it unsticks, and while held it aims where the stick or mouse says and cannot stick.
- **Letting go plants it**: if it's on something it sticks right there; if not, it sticks on its next touch.
- A held limb **drives only while something else of yours is stuck** (or a pal holds you). Pick up your last stuck limb and you fall, limp, until an unheld limb catches something.
- So climbing is: reach a free limb to a hold, let go, move the next one. The body moves by the reaction of the limb motors against your stuck limbs. No limb "pulls" while stuck.

**The controls, the reference game's layout:** a face button per limb, laid out like the body (X left hand, Y right hand, A left foot, B right foot), either stick aims, **Start locks in**, Back pauses. The keyboard mirrors the diamond on A W S D, the mouse aims, and the mouse buttons double as the hands. Space or Enter locks in, Esc pauses. All rebindable. The source for "face button per limb, stick aims" is a review of the game; which button is which limb is my reading of the diamond onto the body, and Parker can rebind or tell me.

**Device swapping** (`Players.ANY`): Practice, the demo and a lone local player online use the ANY slot: whatever device spoke last drives (keyboard and mouse, or any pad), `Players.last_device` tracks it from raw input events, and `device_changed` makes the Game re-set the climber's glyphs, so the hands and feet show X Y A B or A W S D as you switch. Play together (this PC) still gives each joined device its own player. **This is also why the controller did nothing in Practice before:** Practice hard-wired the player to the keyboard.

**Quit to menu, fixed.** `get_tree().paused = true` paused the pause menu too: the menu's buttons took no clicks and the pause button couldn't unpause (Players was paused). THE PAUSE LAW: Main, its menus, Players, PadNav and Net run always; only the World and the Game pause.

**Batteries** rewritten for the new rule: `--grab` (stand, pick up, can't stick while held, plant on release), `--spike limp` (picking up the last stuck limb drops you), `--spike fling` (the anchor hand is never held; the other three swing), `--climb` (stand by the barrel, hand to the edge, let go, both feet up the side: COM rises with three limbs stuck). `--pullup` is gone: a stuck limb can't be driven any more.

**Three physics fixes the new rule forced out:**
- **THE HINGE ERROR IS NEVER WRAPPED.** A limited hinge isn't a circle. The drive's error used `wrapf`, so a hanging arm at +100° aimed at -84° drove the "short" way through 180° and pinned itself on the +170° limit. Plain difference now. (This is why a reaching hand swung the wrong way.)
- **THE STANCE.** A planted foot's ankle is a servo sized by the body's inertia about it (`ieff_other`); a stuck hand's wrist stays a free pivot. Free ankles let the body topple and rock on its pins at every arm move.
- **STIFF, POSED BODIES.** Joints you're not moving hold their angle with real torque (Feel `hold_strength`, 1.2 body-weights at reach; 0.8 let a reaching arm's push bend the standing legs, 1.5 loaded the grab joints in the chain test past 12 cm), as the reference game's climbers do. Loose limbs (`limp_friction`, 5 N·m) made the legs buckle the moment a reaching hand pushed on the barrel. A falling climber now falls holding its pose.
- Also: the limb drive is a steady reach (6 rad/s cap, `drive_freq` 8), not a whip; the stick check reads the end pieces' contacts (`contact_monitor`) instead of a shape query each tick; the grab's collision exception is explicit and removed on release (the joint's own flag outlived the freed joint on Jolt, so a released foot never touched the deck again).

**Still unknown: the pad in the menus.** Parker hasn't reported the readout line yet. `builds\TopYourPals (no Steam).bat` launches with Steam off for the one experiment that tells Steam apart from the game.

## 0.1.4 (Parker, 2026-11-07): bendy limbs steered by the hand, Steam out of the pad's way

Parker: "the legs and arms are like not bending. They should be bending left and right like in MYF. It is not anatomically correct but it's what we want." Then: "when you hold a button you are more or less controlling the hand, the limb is bending at the shoulder and elbow or hip and knee sideways to follow the hand you are controlling". And: "only the no steam version is working with my controller... This may be an issue with my controller drivers, so check that first." And: a GameCube controller adapter is plugged in and has upset input before.

**THE HAND IS WHAT YOU STEER** (`Climber._limb_targets`). The stick moves a hand (or foot) target like a cursor, at Feel `hand_speed` (2.6 m/s at full push); a resting stick leaves it where it is; the mouse puts it on its point. The target is kept inside the limb's reach. The two-bone solve bends shoulder and elbow (hip and knee) to follow it, **whichever way the elbow already bends** (left or right; nearly straight, it takes the layout's side). Before, a full stick meant "point the limb that way at full reach", which kept limbs straight.

**Elbows and knees bend both ways** (knees were one-way; hips swing wider too):
- Steered: elbows and knees drive to the solve at Feel `bend_strength` 0.6 body-weights at reach. **0.7 broke the barrel reach** (the stronger elbow shoved the body off the barrel), so the number is sensitive.
- Not steered, free: floppy, Feel `bend_hold` 0.05 (a free knee falls 30-60° under its own weight).
- Not steered, planted (the limb's end is stuck): braced at 0.8 × `hold_strength`. Floppy planted knees squatted the standing climber 0.4 m so it couldn't reach anything.
- `--bend` proves it: a steered elbow folds to 132°, a steered knee to 147°, a free knee flops, and a pushed stick moves the hand that way and a resting stick holds it.

**The pad and Steam, settled.** Drivers checked first, as Parker asked: the Xbox controller (USB 045E:0B12) is on Microsoft's own driver 10.0.26100.9444 (2026-09-02), no remappers or virtual-pad drivers installed (only G HUB, as a virtual keyboard); the GameCube adapter (WUP-028, 057E:0337) is on a WinUSB driver (Dolphin's setup), which Windows doesn't treat as a gamepad, though Steam has its own GameCube adapter support. Parker's own test settled it: the pad works only with Steam off. On the shared dev app (480) Steam applies Spacewar's controller settings, which hand the game nothing. **Steam now starts only when the Online screen opens** (and for `+connect_lobby`, or at boot with `--steam`). Practice and Play together never start it. Online play with a pad on app 480 will still lose the pad; our own app ID, with its Steam Input set to pass the gamepad through, ends it. (0.1.1's late start looked like a failure only because Practice was hard-wired to the keyboard then.)

**Test gotcha:** Godot's `Vector2.UP` is (0, -1), screen-style. Our world is y-up: a test stick "up" is `Vector2(0, 1)`. Real pads are flipped in `Players.stick`.

## 0.1.5 (Parker, 2026-11-07): THE DRAG, read off the reference game by playing it

Parker: "Still not right. Make it control like MYF. Make it feel like MYF to play. feel free to boot both games and control both to compare." And: "importantly limbs and body do not collide with each other" (already so: a climber's pieces have collision exceptions between all of them).

**How it was studied.** The reference game was launched from its install and driven with AutoHotkey (keys and mouse) while its window was captured, on 2026-11-07. Its own controls card says: "Hold [Y B X A] to drag appendage. Use [L] to control appendage. [Y B X A] sticks to surfaces automatically." Its save file (`MountSave.sav`) and the glyphs drawn on its climbers give the layout:

| Limb (screen side) | Pad | Keyboard |
|---|---|---|
| Left hand | X | A |
| Right hand | A | D |
| Left foot | Y | W |
| Right foot | B | S |
| End turn (our Lock in) | Start | Space |

That is now our default (`Players.DEFAULT_PAD` / `DEFAULT_KBM`, `BINDS_VERSION` 3 drops older saved binds).

**What it does, watched frame by frame:**
- Holding a limb **pulls its hand or foot to the cursor**, hard: the hand lands on the cursor tip, the arm straightens toward it, and the whole body leans after it while the feet stay stuck.
- Out of reach, a red line runs from the hand to the cursor; the body leans hard but the feet hold. The pull is capped.
- Let go and the limb **keeps its pose**: the joints have friction.
- Under a pull the knees buckle **sideways**, either way; the body sags bow-legged over time.
- A foot does the same: it lifts, follows the cursor, the body stands on the other foot, and a free hand that brushes the ground sticks.
- Its build lists "Weld" and "Revolute" joints and "Setting friction joints": grabs are welds, limbs are revolute joints with friction.

**THE DRAG, built that way** (`Climber._tick_joints`, `drag_target`):
- No motors aim the limbs any more. A held hand or foot is pulled toward its target by an elastic force (Feel `drag_stiffness` 140 N/m per kg of body, `drag_damping` 12), capped at `drag_strength` 1.15 body-weights, applied only while attached. The mouse puts the target on its point; a pad's stick moves it like a cursor (`hand_speed`), kept within 1.25 reaches of the limb's root.
- **Every joint has friction** (a Jolt hinge motor holding still with a capped torque): shoulders and hips `joint_friction` 0.5, elbows and knees `bend_friction` 0.28 (0.36 stopped the knees buckling; 0.22 still held the body up), the pulled limb's own joints `held_friction` 0.06 so it follows the pull, wrists and ankles `wrist_friction` 0.1, and **a planted foot's ankle as stiff as a hip** so the body stands over a welded foot. A stuck hand's wrist stays loose so you swing from it. The spine and neck stay soft springs.
- **Grabs are welds:** a hinge on z locked at its current angle (a free pin let the body topple over its feet at the first lean).
- `--feel` battery, one check per watched behaviour: spawn standing on stuck feet; a held hand reaches a reachable cursor within 12 cm in 0.6 s; the feet stay stuck; out of reach the body leans 10 cm or more and the feet still hold; the body is still up afterwards; let go and the arm holds its pose; a held foot lifts and follows; the other foot stays; the standing knee buckles sideways; loose in the air a held limb isn't pulled.
- `--demo-drag=DIR` replays the same moves inside the game and saves a frame every 0.5 s (no keys go through Windows).

**THE KEY-GUARD LAW (an incident).** The first try at driving our own game with AutoHotkey sent a keypress into Parker's browser (a Reddit comment box got a stray "a"; nothing was submitted; he was told). The driver had sent keys even when the game window never came forward. `drive.ahk` now checks the target window is the ACTIVE window before every input and aborts, releasing held keys, if not. Our own game is driven from inside (`--demo-drag`) instead.

## 0.2.1 (Parker, 2026-11-07): the first playtest build, controls + UI merged

Parker: "get the new controls version and the UI updates all together however we have them so far, I need a playable build I can send to my partner so I can play test." And: "make the game default to 40% master volume."

- **Merged** the `luchador-ui` branch (worktree `TopDog-luchador`, commit ad0f725: the 3D luchador front end, the plaza, the luchador theme, the rename to **Top Dog**) into main on top of 0.1.5's drag controls. One conflict, `net.gd`'s tag and version: resolved to tag `topdog` (matching `lobby_logic.gd`) and `GAME_VERSION` 0.2.1.
- **The Top Dog Kit's models** (title logo, belt button, five clouds) come in by `tools/sync_kit.py`, copied from the uncommitted file in that worktree; it rewrites their atlas uri for `res://kit/models/`. The belt button is the re-landed one (crest backing moved off the plate, golds on SATIN).
- **The crest crowns the focused belt only** (`Menu3D._process`); on every belt the crests overlapped the labels above.
- **Master volume defaults to 40%** (`Sound.volumes`). The rename gives the game a new user-data folder, so saved options and binds start fresh.
- **Export:** `builds/TopDog.exe`; the no-Steam launcher and the upload script follow the new name. The playtest zip is `builds/TopDog_playtest_0.2.1.zip` (exe, the two Steam DLLs, `HOW TO PLAY.txt`, the no-Steam launcher); the how-to is kept as `docs/PLAYTEST_HOW_TO_PLAY.txt`.
- **Checked:** lint (31 scripts), every battery, the pad driving the 3D menus (D-pad, stick, A, B, keyboard), the exported build's title and match screens, and a clean exit.

## 0.2.2 (Parker, 2026-11-07): the controller online, through Steam

Parker: "my controller is not working online". His global "Steam Input for Xbox controllers" switch was already off, so the dev app (480, Valve's own Steam Input sample game) forces Steam Input on for itself, and its layout binds nothing a normal game reads. Parker: "we are using steam. Make it work through steam."

**`core/steam_input.gd`:** when Steam starts, the game writes its OWN Steam Input layout to `user://steam_input/` (an action manifest plus a config per controller type: Xbox One, Xbox 360, generic, PS4, PS5, Switch Pro, Steam Controller, Steam Deck), passes it to `SetInputActionManifestFilePath` before `Steam.inputInit`, and reads the actions back each frame. Action set "Game": X left hand, A right hand, Y left foot, B right foot, Start lock in, Back pause, either stick steers (`joystick_move`), the d-pad moves menus, A selects, B goes back. Steam controllers are Players devices 3000+ (the ANY slot reads them too), and PadNav drives the menus from them, ignoring the raw pads while Steam has any (never twice). The menu readout line shows "Steam Input: N controllers [type], last: action".

**Proved live on Parker's machine (Steam running, app 480):** the manifest was accepted, his Xbox One controller showed up with our action set current, every action reported `active: true`, and `arm_l`'s origin was 116 (XBoxOne_X). Button presses themselves can only be tested by hand. The controller list is read twice a second (GodotSteam logs every `getConnectedControllers` call).

## 0.3.0 (Parker, 2026-11-07): the Second Director's look merged, pushed to GitHub

Parker: "combine what second director has been working on with the new updated working game and push all to Github" (github.com/canonheim/TopDog).

- Merged `luchador-ui` at aebe719 into main (clean): the plaza ring stage, confetti on lock-ins and wins, the kit's player cards, mask emblem, clock buckle, results podium and papel picado, and the re-landed logo and belt. With 0.2.2's Steam Input controller fix.
- `GAME_VERSION` 0.3.0. The kit's newer `palm.glb` was left out: not yet tested in the game by its owner.
- Checked: lint (32 scripts), every battery, the pad check, the exported build's title, match and a Steam-on boot (manifest accepted, "Steam Input: 1 controller [Xbox One]").
- Playtest zip `builds/TopDog_playtest_0.3.0.zip`.

## 0.3.1 (Parker, 2026-11-07): left stick only, free limbs, Join a friend, the pad on the Online page

Parker: "the right stick should not control it, it should be the left stick", "the UI is not working with controller in the online page ... make sure controller works everywhere", "Make a Join Friends button", and limbs "should be able to just move 360 degrees with no limits and go through each other completely".

- **The left stick only.** `Players.stick` reads the left stick; the Steam layout no longer binds the right stick (`core/steam_input.gd`).
- **Free limbs.** Shoulders, elbows, wrists, hips, knees and ankles have no hinge limits; only the two spine joints and the neck keep theirs. Limbs already passed through each other (a climber's pieces don't collide). The limit checks in `--spike limits` and `--spike fling` now cover the spine and neck only.
- **Join a friend.** `Net.friends_in_game()` lists Steam friends running the game; the Online page's "Join a friend" button lists them with Join buttons. A joined lobby whose `game` tag isn't ours is refused ("That friend is in a different game."): on app 480 friends may be in other games.
- **The pad on the Online page.** `tests/online_pad_probe.tscn` drives the page with a stand-in Steam controller (d-pad, left stick, B back): every control is reached and B returns to the title. It passes, so if Parker's pad still fails there, the readout line ("Steam Input: N controllers, last: ...") says which side is deaf.
- **The 3D Online and Lobby screens** were handed to the Second Director and the UI creator (in progress on `luchador-ui`).
- **Jolt position steps 8 → 16.** With the wrist free, the whole body hung off one hand stretched that wrist 2.4 cm (0.8 cm when it was limited); 16 steps hold it to 0.3 cm (`--spike --part=hang`, which now also prints the settled stretch).
- `GAME_VERSION` 0.3.1.

## 0.3.2 (Parker, 2026-11-07): small glyphs on white when stuck, a stronger pull, an instant stick, less gravity

Parker: "make the hand and feet glyphs half as big, and when they are attached, make them have a white background", "Hands and feet need more force and to move faster when controlled, and gravity is too strong", and "Aren't sticks instant on contact?"

- **Glyphs** are half size. A stuck limb's glyph sits on a white disc with a dark rim (one baked image: two see-through sprites wouldn't sort). The key prompts cut their letter out as a hole, which vanished on white, so the holes are inked dark in both looks.
- **The stick points the limb, at once** (`Climber.drag_target`): the target sits out from the shoulder or hip in the stick's direction, at the stick's push times Feel `stick_reach` (1.15 limb lengths). A resting stick leaves it. Feel `hand_speed` (the old cursor) is gone. My study of the reference used keys and mouse only; the cursor was my guess, Parker corrected it.
- **Stronger pull:** `drag_strength` 1.15 → 1.5, `drag_stiffness` 140 → 190. The cap is now in body-weights at FULL gravity, so lowering gravity never weakens the hands.
- **Gravity** `gravity_scale` 1.0 → 0.75.
- Merged the Second Director's 17d2690 (the kit's Online parts wired in).
- Checked: lint, every battery, pad_probe, online_pad_probe, online3d_probe.

## 0.3.3 to 0.3.8 (2026-11-07 evening): the look pass, Dan's sounds, the build tag, the stick online

- **The look pass** (the Second Director, luchador-ui 9b7e0ef):
  - a bright cartoon-blue sky, no fog, glow off, Linear tonemapping;
  - `CelPass.NO_EMISSION` (no emissive colours anywhere: Parker);
  - UI words are flat Label3D in Luckiest Guy (`fonts/luckiest_guy/`, Apache 2.0) and skip the ink, while the TOP DOG logo keeps its ink;
  - the kit's Online parts, the bell, the piñata and confetti.
- **Dan (GitHub DPisculli), Parker's collaborator, pushes to main too:**
  - da296d8: "Desert Snake" plays in matches and the theme in menus. The match music now plays on through a pause.
  - fa8ff9e: shuffled slap sounds when a released limb sticks, one rare slap at 1 in 100, and `GAME_VERSION` 0.3.6.
  - Always fetch and merge his work before pushing.
- **Docs:** `docs/TOP_DOG_OVERVIEW.md` (everything about the game) and `docs/HOUSE_ATLAS_AND_3D_MODELS.md` (the atlas and the model road), written for Dan's LLM.
- **The build tag:** "BUILD x.y.z" in the title screen's bottom-right corner, read from `GAME_VERSION` (Parker: "so we know what build we are booting").
- **0.3.8, the stick online.** Parker: "controller does not work at all in online. It just makes you twitch a little."
  - The Steam Input layout bound the stick group to `left_joystick`, which isn't a Steam source name (the left stick is `joystick`, the right `right_joystick`), so Steam dropped the binding.
  - Online the stick read zero: a press picked the limb up and the release replanted it in place (the twitch), and the left stick couldn't move the online menus.
  - Proven in a focused windowed probe: `getAnalogActionOrigins` was `[]` with "active false"; after the fix it was `[126]`, active, with full-range values while Parker swirled the stick.
  - 0.3.7 was Dan's local build, so this one is 0.3.8. Zip: `builds/TopDog_playtest_0.3.8.zip`.

## The skeleton knight (Parker, 2026-11-07)

Parker: "replace the default knight with this skeleton in game".
- `models/skeleton_knight.glb` is now the default climber (`Game.KNIGHT`, and the slot skin is `skeleton_knight`). `metal_knight.glb` is kept.
- It's on the 16-piece contract: the same mesh names, transforms applied, one `PALETTE` material, and the same joint positions as the knight. So the physics shapes (measured from the knight) still fit; the bones are just thinner.
- It embedded Golemheim's atlas. Every colour it uses is pixel-identical on the house atlas, so the game copy points at `../palette/house_atlas.png` with nearest sampling.
- **No colour wash** (Parker: "remove color washing towards colors. People can look the same it's fine. Eventually people will pick their own skins"). Every climber wears the model's own colours; `tint` still colours name tags and cards.

## The wide shoulders (Parker, 2026-11-07)

Parker: "Golemheim has a shoulder offset to make the shoulders wider. Add that into this game so the shoulders are wider and a little lower."
- `Layout.shift(name)`: every arm piece, its mesh and its shoulder, elbow and wrist joints sit Feel `shoulder_flare` (0.09 m, Golemheim's `SHOULDER_FLARE`) further out and `shoulder_drop` (0.05 m) lower than the model. The chest stays put. Parker then said "reduce the flair": `shoulder_flare` is 0.05.
- The shift is applied wherever rest positions are read: piece centres, mesh placement, joint anchors, limb lengths, `end_point`, the joint-gap check. Both are F1 knobs and take effect on the next spawn. Every machine must use the same values, since puppets and frozen bodies rebuild from the layout.
- Checked: the full battery passes.

## 0.3.9 (Parker, 2026-11-07): a higher first line, one pull budget, power without speed

Parker: "make the first line slightly higher up. Right now I can reach straight up at spawn and touch it. Also make it so controlling more than one limb does not give you more force, and increase individual torque of a limb so it is more powerful but not faster. One controlled limb should be able to move the whole body."
- **The first line** is `Stage.first_line` = barrel top + `FIRST_LINE_ABOVE` (0.45 m): 2.47 m instead of 2.02. It's the line before the tower passes it, and `tower_top()` starts from it.
- **One budget:** `drag_strength` (now 2.4 body-weights at full gravity) is shared among the held limbs, so two held limbs get half each. `--feel` checks that the summed pull never exceeds one cap.
- **Power, not speed:** the cap went 1.5 → 2.4 and `drag_stiffness` 140 → 240. The new Feel `drag_max_speed` (12.5 m/s, today's peak was 12.6) trims the push along the hand's motion so a tick can't carry it faster. The hand is light: a full pull adds about 10 m/s per tick, so the trim looks one tick ahead.
- **One held limb moves the body:** the out-of-reach lean went from 0.41 to 0.51 m (`--feel` now asks for 0.30).
- `GAME_VERSION` 0.3.9. Full battery passes.

## The follow camera and full power out of reach (Parker, 2026-11-07)

Parker: "the camera should match what it does in MYF, where it looks at you, not at you and the whole structure. Also increase the power of one limb, I am having trouble moving myself upwards with just a limb."
- **The follow camera** (`main._tick_camera`): in play (turn and round phases, someone live) it frames only the live climbers, padded 1.0 m wide and 1.0 below / 1.2 above, at least `FOLLOW_HALF_H` 1.75 m half-height. A climber fills about half the screen. The line comes into view as you near it. With nobody live (menus, between turns) it frames the tower top and the line as before, so the 3D menus riding the camera are unchanged.
- **More power:** `drag_strength` 2.4 → 3.5 body-weights (still one budget shared among held limbs, still the 12.5 m/s speed cap). A target past the limb's reach from its root now pulls at the full cap toward it, instead of the short spring stretch the stick's 1.15-reach target gave.
- New `--feel` checks: hanging by one hand, one held hand pulls the body up (1.42 m), and one held foot lifts it (0.64 m). Both were already near those numbers before, because the limb's reach limits them. So if a climb move still fails, it's a different situation from these two (Parker to say which).
- Full battery passes.

## 0.3.32+: the press stack, the camera a step back, the pause menu on top (Parker, 2026-11-08)

- **Merged Dan's 0.3.13 to 0.3.31:** his limb pull with the swing around one grip, gravity multipliers, grounded lock-ins, arena chairs, the practice partner. Parker: "throw out my changes on the power, main's take precedence here, but keep my camera changes". So the 3.5 cap and the out-of-reach full pull are gone, and the follow camera stays.
- **THE PRESS STACK** (`Climber._select_active_limb`). Parker: "Only one limb can be active at once, the most recent limb held ... hold A and then press X, X will be the one in control, then let go of X, A still being held, A should now be in control."
  - The active limb is the most recent press still held. Releasing it hands control back to the next-newest held button, which picks its limb up again.
  - Same-tick presses: the first limb in controller order ends on top.
  - Dan's rule (an older held button had to be pressed again) is replaced; its `limp` check was updated, and `--grab` checks the A, X, release X sequence.
- **The camera a step back:** `FOLLOW_HALF_H` 1.75 → 2.05, padding 1.2 wide and 1.15 / 1.35.
- **The pause menu in front of everything:** it rides `LuchaUI.PAUSE_DIST` (1.2 m) from the lens instead of 6 m, scaled to the same size on screen. While paused, the overlays that draw over everything on purpose are hidden: the limb glyphs (`Climber.set_glyphs_visible`), name tags, the LINE label and the match HUD with its turn banner.
- **Open:** two `--bend` checks fail on Dan's merged limb control (a steered knee folds only to 17 degrees; a pushed stick moved the hand 1.5 m). They're his tuning, for him to look at. `pad_probe` failed 7 once right after a battery and passed on three runs since.

## The town light pass (Parker, 2026-11-08)

Parker: "have the EM make the town look nicer and the building maker make the buildings nicer. Move the hanging flags slightly back and give them poles to hang on. For this pass, don't spend toooo much effort on it." Two new makers, Top Dog only from now on: the Environment Maker (local_d4a0612b) and the Building Maker (local_a1eb062d), both reporting to Top Dog's Windy.
- **The Environment Maker, `env-pass` d00f76d** (only `ui3d/lucha_ui.gd` `_build_plaza` and its helpers):
  - the papel picado moved back from z -9 to -11.5, on 4 wooden poles with crossbars, gold balls and stone feet; the piñata stays on the right-hand string;
  - the plaza row is a table of kit houses, staggered in depth with no gaps;
  - a bell tower at x -6.5, off-centre so the climber keeps sky behind;
  - a four-terrace hill town to about 18 m;
  - land to the horizon with hazy ridges, so the "sea" under the town is gone;
  - a new frame probe, `tests/env_shot_probe.tscn -- --no-steam --out=DIR`.
- **The Building Maker** re-made `plaza_house_a/b/c` as drop-ins: quoins, string courses, a two-step cornice, eave tile ends, panelled shutters, window hoods, flower boxes, railed balconies, an awning, chimneys and a lantern. It also built `bell_tower` (18.2 m, with an open belfry, a clock and a striped dome; its bell is the object `tower_bell`, pivot y 13.4). Synced with `tools/sync_kit.py`.
- **The full plan for a bigger pass** is in `Top Dog Kit\docs\ENVIRONMENT_PLAN.md` (options A, B and C, with questions for Parker), parked.
- **Second pass, env-pass 1cd18c5:**
  - the canvas is overridden to warm grey `Stage.CANVAS` #ADA28E, so the skeleton's legs read;
  - the flags hang at z -12.6, one span each side plus strings up to the church towers, and none crosses the climbing column at x 0;
  - the piñata hangs mid-span at x 12;
  - house heights are staggered too (scale 0.92 to 1.08);
  - the twin-tower church stands at the centre back.
- **The Building Maker's `plaza_church`** (22 m, twin towers with bells `bell_l` / `bell_r`, a talavera dome) is synced and replaces the code stand-in by name.
- **Open:** the white middle rope still crosses the pelvis. The back ropes are one mesh, so recolouring it means the UI creator re-lands `ring`.
- **Checked:** lint 39, battery `--tower --climb --net`, and the frames in `Top Dog Kit\previews\env_pass\merged\`.

## The clouds, version 2 (Parker, 2026-11-08)

Parker, with a reference picture (`Top Dog Kit\docs\cloud_reference_parker.png`): "make some more rounded clouds with a gray outline that flows into the swirls".
- The UI creator re-made `cloud_a`..`e` (10 review rounds against the reference): rounded overlapping lobes, a soft grey line (#9CA8BA) that rolls into the swirls, and a two-step blue-grey shade along the base. The widths changed: 8.6, 8.6, 5.1, 7.9, 8.6 (`LuchaKit.CLOUDS`).
- **The clouds skip the house ink** (`LuchaKit.skip_ink`: an unshaded, alpha atlas material, drawn after the ink pass). Their grey line is their outline; a black ink edge fought it.
- The Building Maker's re-landed `plaza_church` came in with the same sync, placed by its measured front.

## Grabbing climbers, put back (Parker, 2026-11-08)

Parker: "Dan took out grabbing people. Put it back in ... the practice partner is where I noticed it. You should be able to grab him."
- Dan's 0.3.30 (84a41ba) made only the arena and the frozen stack grippable. It also removed `grabbed_by` / `remote_grabbed`, the network pulls, `grab_lost`, `pull_cap` and the grab tests.
- All restored from that commit, with his chairs and partner kept:
  - `_try_grab` takes live climbers again (solid ground and the tower still win);
  - `attach` counts the grab on a live climber;
  - `is_attached` counts being held (Parker's call 10);
  - `game.gd`'s "grabbing across machines" section (`_on_grab_made`, `_rpc_grabbed`, `_tick_pulls_out`, `_rpc_pull`) is back;
  - Feel `pull_cap` is back.
- The practice partner is a live climber, so he can be grabbed. His own limbs still never stick (`practice_partner._try_grab`). `_remove_partner` releases anyone holding him before he respawns.
- **Tests:** the eight-live blob ("they grabbed each other", 189), the chain, the live-rival and partner grabs in `--grab`, and the network grab in `--net` all pass. The eight-live frame time was 7.4 ms during one full run under load, and 2.7 to 3.1 ms alone. The two `--bend` failures on Dan's limb control are still open.

## Held grabs, no flying, new names, soft folds, hands on hips, hung flags (Parker, 2026-11-08)

- **Grabbing a climber takes a held limb** (Parker: "should work like how it works with the chair, you have to be holding the limb to grab").
  - `_try_grab_climber`: the active limb's hand or foot takes hold of a live climber it touches, and lets go when the limb is let go or another limb takes over.
  - Loose limbs stick only to the arena and the frozen tower.
  - `attach()` still allows any climber (tests, netcode).
- **THE GROUNDED GROUP** (Parker: "you cannot exert force unless at least one connected person is touching something solid like the ground or tower").
  - `is_attached()` walks the chain of grabs: me, whoever I hold, whoever holds me (`held_by`), and on through.
  - Someone in it must be stuck to, or touching with an unheld end, the arena or the frozen tower. The practice partner counts by standing.
  - Online, a rival counts while their pull arrives, and `_tick_pulls_out` only sends it while the holder is grounded on its own machine (`grounded_locally`), so two airborne players can't fly.
- **A new name for every climber:** players with a random name (the slot's `random` flag, carried through the rosters) get a fresh `NameGen` name each new character, i.e. first spawn or after a freeze. A respawn after a fall keeps it, and Steam names stay. The host picks and sends it with `_rpc_spawn`, which also announces "X's turn", so banners and tags match.
- **Elbows and knees turn 360 again, with THE SOFT FOLD** (Parker: "make it so limbs can rotate 360 degrees again but with the resistance").
  - Dan's ±150 degree stops on the `mid` joints are gone, and so is his hand/foot vs upper-segment collision. A climber's pieces never collide with each other again.
  - From `FOLD_START_DEG` (150, the old stop) to 180 the joint pushes back, and past 180 it helps through.
  - Feel `fold_resistance` 3.0 applies to limbs you aren't moving (it keeps a loaded knee up like the old stop). Feel `fold_resistance_held` 0.8 is the lighter hump on the limb you're moving.
  - The steering still keeps its target out of the folded reach (`FOLD_REACH_DEG` 150), so a straight pull back to the shoulder is resisted and swinging the limb around comes easier.
- **Hands on hips at spawn** (`_hands_on_hips`, a two-bone solve, elbows out); it replaces `_arms_down`.
- **The flags hang along their strings** (`LuchaKit.bunting`: each flag is turned about the vertical to the string's run).
- **Arms in front of the torso:** tried, then reverted on Parker's word.
- **Everyone hears everything** (Parker: "All people should hear all noises like farts and slaps and stuff"). Audit: slaps, farts and grunts were already broadcast (`_rpc_slap`, `_rpc_fart`, `_rpc_exertion`), as were the chair sounds and the lock-in, out and short verdicts (`_rpc_freeze`). The freeze thud plays on every machine. Only "fell off" was raised on the host alone, and it now goes out through `_rpc_note`. Private notes ("climb higher", "touch the stage") stay with their player.
- **The slap on every catch** (Parker: "anytime a hand connects, it should make the noise"): any new stick, whether held or loose (a flung limb landing, a held one grabbing someone), emits `release_contact` and plays the slap, broadcast online. The first `SLAP_QUIET_S` (0.6 s) after a spawn is silent, while the feet settle. `--grab` checks a dropped climber slaps.
- **Tests:**
  - New and passing: held grabs, no flying, the elbow turning through 180 under a hand-pull twist, and the press stack.
  - `--feel`'s three lean checks now fail ("one held limb moves the body" 0.29 vs 0.30, "arm holds its pose", "body still up after the big lean"). They pass with the old arms-down spawn, so the hands-on-hips start changes that scripted lean. That's for Parker's feel, not a rigged test.
  - Dan's `--bend` failure stays; the eight-live frame time is slow only under a full run.

## The ropes, RING OUT, and the new ring (Parker, 2026-11-08)

- **The ropes bounce** (Parker: "the ropes on the side of the ring to bounce you if you run into them, with more force than you hit them with").
  - `Climber._tick_ropes`: when any piece of a live climber enters the band at the side ropes (`Climber.rope_x` = the ring's half-width, from y 0.15 to 1.55, within 0.3 m of the rope line) moving outward, the whole climber is thrown back inward at Feel `rope_bounce` (1.5) times its speed, relative motion kept, with a 0.25 s cooldown.
  - The ropes have no colliders, so they can't be grabbed.
- **RING OUT** (Parker: "if you hit the ground outside the ring, it says RING OUT! and you are respawned back in the ring after 3 seconds").
  - The plaza floor outside the ring is solid now (`Stage`, at `PLAZA_GROUND`).
  - The host sees a climber's lowest piece on it (`Stage.ring_out`), sends "RING OUT!" to every machine (`_rpc_note`), and respawns them `Game.RING_OUT_S` (3 s) later. The name is kept: it's the same character. The practice partner rings out the same way.
  - `--ring` checks it: in at 4 m/s, back at 5.8; RING OUT at 0.76 s; back 3.01 s later, inside the ring.
- **The new ring** (Building Maker; Parker asked him directly for "more mexican colors"): rosa mexicano, turquoise, marigold, purple and lime with gold.
  - The back ropes are split into `ring_rope_back_low/mid/high` (pink, turquoise, gold), so the middle one reads against the skeleton.
  - Also new: a padded bumper, a scalloped valance, skirt panels with the pug medallion, taped ropes, octagonal turnbuckles, gold post caps, and `ring_steps` outside the right end (visual only).
  - `ring_canvas` is the canvas alone now, still repainted grey in code.

## The rope spring and boing, and a clean HUD bottom (Parker, 2026-11-08)

- **The ropes spring** (Parker: "the ropes need to have a bouncing animation when they bounce you and put a place holder noise in").
  - `Climber.rope_bounced` goes to every machine (`_rpc_rope`). Each plays the boing at the rope and calls `Stage.bounce_rope`: that side's rope (`ring_ropes_left/right` on the kit ring) is knocked out by up to 0.4 m with the hit, then springs back on an elastic tween.
  - The sound is a PLACEHOLDER, `audio/sfx/rope_boing.wav` (Sound "rope"), synthesized for Dan to replace.
  - `--ring` checks it (a dressed game now): the rope goes out 0.23 m on a 4 m/s hit and settles.
- **The bottom text is gone** (Parker: "The tooltips and dev stuff? Get rid of it"). The controls hint label is removed, and the flat "Above the line! Lock in" prompt is hidden.
- **Ordered:** a HUD nameplate for the current climber's name, sized for the longest name ("Winifred the Drawbridge-Scrambler", 33 characters), and an odometer height counter with rolling drum wheels (references in `Top Dog Kit\docs\`). The UI creator makes the parts and the Second Director wires them, with the lock-in prompt in 3D.

## The cardboard sky, the paved plaza, the HUD bottom (Parker, 2026-11-08)

- **Cardboard mountains** (Parker: "large cardboard cut outs of mountains instead of just blank shapes"). The Building Maker's `mountain_cutout_a/b/c` have hand-cut cards, a corrugated kraft edge, painted haze-blue faces with snow and tree lines, and braces and sandbags behind. The Environment Maker scales them to the old ridge slots, leaned and yawed a little. m5 has smaller snow caps.
- **Cardboard clouds** (Parker: "make the clouds look like cardboard cut outs ... complete redesign as BM sees fit"). The Building Maker redesigned `cloud_a..e` as puffy cards with a kraft edge, a pale stacked back card and a dowel stick. They're back on the normal house ink and cel shading (`skip_ink` dropped).
- **The paved plaza** (Parker to the Environment Maker: "a paved street in front of the houses ... flat so ink doesnt hit it ... raised geometry for like a curb"): `LuchaUI._pave` lays flat setts and slabs in four sandstone tones over a grout bed (one MultiMesh per tone), with a raised kerb at z -9.75.
- **The HUD bottom** (the Second Director wired the UI creator's parts):
  - the climber's name on `hud_nameplate` (long names shrink to fit);
  - your height on `hud_odometer`, with rolling drums 00.00-99.99 m;
  - `hud_lockin_tab` and the end gems turn lime above the line;
  - `tests/hud_probe.tscn` checks it.
- **Balcony French doors** on plaza houses b and c, and the ring's top rope is lime green (Parker).
- **The toaster LOCK IN** (Parker to the UI creator: "make the part that says lock in a toaster pop up that comes out of the main name plate"). The tab waits in the nameplate's slot and pops up above the line (0.15 s, ease-out-back, a high "ding" of the lock bell), then drops back below it.
- **The odometer past 100 m** (Parker: "the '.' drop[s] and the meter counter keep[s] going at 100"). `drum_values` reads whole metres from 100 m (0100-9999) and `odo_point`, the kit's decimal point split out, hides. The UI creator evened the drum gaps so four digits read evenly. `hud_probe` checks 150 m and 1234 m.
- **Mountains m6:** deeper blue-grey on the far pair (the sun washed them near-white) and b's dotted ink line gone.

## The line as flags on growing poles, ropes that bend, the kit banner (Parker, 2026-11-08)

- **The line is a string of flags** (Parker: "get rid of the big red and yellow line height indicator. Make the line a string of flags"). `LuchaUI._restyle_line` drops the red bar's mesh and hides the LINE label, then hangs papel picado across ±12 m at the line's height, just behind the play plane (`LINE_Z`), waving with the plaza flags.
- **The line poles** (Parker: "long decorative poles on either side of the ring holding up the line and those poles constantly grow as the line moves up"). `_tick_line_poles`: a wooden pole at each end of the string on the plaza, its shaft stretched every frame to the line, with a gold band for each whole metre and a gold cap.
- **The first line starts higher** (Parker: "start just a little higher so the flags clear the barrel"): `Stage.FIRST_LINE_ABOVE` 0.45 → 0.8 m, so the line is at 2.82 m.
- **The ropes bend** (Parker: "the middle needs to flex but the sides connected to the posts should stay connected to the posts"). `Stage.bounce_rope` rebuilds the side rope's mesh each frame of the spring, bent on a sine along its length (zero at both posts); the rest mesh comes back after. `--ring` checks a 0.22 m bow and the return.
- **The kit banner** (the UI creator's `hud_banner` / `hud_banner_note`, wired by the Second Director): it slams in at the top centre, and the clock and bell wait above the frame until it leaves (Parker's call). No name tags over heads.

## Outdated checks removed (Parker, 2026-11-08)

Parker: "just get rid of the old stuff, no new checks at this time". Removed five checks written for rules that have since changed:
- `--bend` "a steered knee folds to follow the foot": it steered a hand and a foot at once, which the press stack (one active limb) no longer allows;
- `--bend` "a pushed stick moves the hand that way": a single-grip climber, where Dan's swing about one grip now redirects the push;
- `--feel` "one held limb moves the whole body", "let go, and the arm holds its new pose" and "after the big lean the body is still up": they were written for the arms-down spawn, and the hands-on-hips start changes that scripted lean.

The full battery is green except the eight-live frame time, which runs over 6 ms only under a full run's load and passes alone.

## The town in the round (Parker, 2026-11-08)

Parker: "I want the town arranged in more of a semi circle around the ring. So the church is more visible and the ring feel like it might be more in the town and the town isn't just a grid ... The ground and streets will def need a re work." The Environment Maker, env-pass 9d3a64d (`ui3d/lucha_ui.gd`, `stages/stage.gd` visual slab only, `tests/env_shot_probe.gd`):
- **The arc:** everything is laid on arcs about (0, -2.5), just behind the ring. The first ring of kit houses faces the centre from 24° to 94° each side, so the wings come forward round the ring, with a street opening between houses on each side at 62°.
- **The church:** the centrepiece in the arc's back gap, scaled 1.25, on a raised slabbed forecourt with steps down to the square. It's clear at every play height and shows through the ropes at ground level.
- **The hill town:** four concentric terraces behind, houses facing the centre, an amphitheatre.
- **The ground, reworked:** a round plaza of concentric sett courses (a paler band every seventh), a raised kerbed pavement along the house fronts, sett streets out to steps up the first terrace, and a slabbed forecourt. It's all flat-coloured (flat quads over a grout bed); only the kerbs and steps stand proud.
- **The papel picado poles** stand on a circle round the plaza, and the strings run along the arc and up to the church towers.
- **Unchanged:** gameplay (the ring, deck, plaza floor collider, RING OUT, the line poles; the round plaza covers the whole floor collider) and all the kit models. The church needed no work.
- **Checks:** lint, and `--ring --tower --climb --scramble`.
- **Then** (Parker: "fix the very bottom of the church, it looks like a big brown slab. Also have it build one more house"):
  - the Building Maker's church plinth (a footing course, three courses of rusticated blocks in two stone tones, a moulded cap; the portal steps narrowed to the nave);
  - `plaza_house_d`: narrow, tall, sage green, with a scrolled parapet and a loggia.
  - **The church at street level** (Parker to the Environment Maker: "make the church not on a raised pedistal but on street level with the other houses"; env-pass 560f7e1). The forecourt block and its steps are gone; the church stands on the plaza with flush slabs in its gap, keeping its own steps and plinth.
  - The Environment Maker mixes house_d through the arc and terraces (env-pass a33e39b). The town builds from every delivered house style by name, so a future house_e mixes in with no code change.

## The hill town round the square: half a football (Parker, 2026-11-08)

Parker: "make the ground by the church and the street blend better ... the layout of the town not a perfect half circle, but more of like half a football ... make it look like a town with like stairs and bricks and stuff instead of just blank terraces, and make sure the sides of the church look nice ... some vegetation"; "make sure no 2 buildings right next to each other are the same"; to the Building Maker: arches and pot spots on the church front, poinsettia pots from the UI creator.

- **Layout:** one lens shape, 30 m to its points and 20.5 m deep, flat behind the church. The square, the house row and four terraces are the same lens grown outward (env-pass 2baaa55, 8bfcde9).
- **Ground:** the square's setts run straight up to the church steps, led by one pale course; the courses follow the lens. The grout beds sit 4-5 mm under the stones (a 15 mm step inked at grazing angles).
- **A town:** brick retaining walls on every terrace (flat quads on mortar), parapets, paved lanes with lamp posts, benches and flower boxes, stair flights between levels, and a street through the house row each side up to the stairs. The church has a raised garden each side and a stairway behind, so no blank walls show.
- **No two neighbours alike:** every row and terrace picks a style other than the last placed, across gaps too. The styles are a, b, c, d, and `d_tan` (house d in tan with turquoise shutters, Parker to the Building Maker). The rule compares families, the name before "_", so d and d_tan never stand side by side (env-pass 7818f71).
- **Palms:** each palm gets its own heading, lean and size, chosen from `palm`, `palm_b` (tall, curved) and `palm_c` (a fan palm) so neighbours differ (Parker: "not all face exactly the same way").
- **The church:** blind arches with pot ledges on each tower, `pot_spot_1..4`, carrying the UI creator's `pot_poinsettia_a/b/c`. k2 adds gold ring knockers and fixes the plinth's block courses and pilaster bottoms.

## Fewer green houses, a new blue one, no look-alikes behind, plants by the UI creator (Parker, 2026-11-08)

- **Fewer green and tan houses** (Parker: "there's too many of those green and tan houses"): picks are by building family with weights (`HOUSE_WEIGHT`), and the flat-roofed d family comes up at half weight (env-pass 93347a3).
- **plaza_house_e** (the Building Maker): a pitched tile roof with its gable to the square, sky blue, red shutters, a full-width wooden balcony. It's picked at full weight.
- **No look-alike behind** (Parker: "a yellow house with a yellow house behind it? We dont want that"): each house is logged with its on-screen angle from the play camera, and a terrace house avoids the families of the houses in the two rows in front that it overlaps. Look-alike colours count as the same: tan clashes with cream and ochre (de93dc0).
- **No modelled plants on buildings** (Parker: "tell the BM not to model plants onto his houses ... have UI guy build them"). Every house is re-landed with empty planters and `plant_box_N` / `plant_pot_N` / `plant_vine_N` markers. The UI creator's `plant_box_a/b/c`, `plant_pot_a/b/c` and `plant_vine_a/b` go on them through `_plant_markers()` (3d6f206). They're at default sizes for now; the UI creator re-lands them at the Building Maker's spot sizes under the same names, a plain sync.
- **The pots belong to the plant maker** (Parker: "building maker should not have the pots, the pots belong to the one making the plants"). `plant_pot_a/b/c` carry their pot (pot_body + pot_plant, origin at the base), and the houses carry no loose pots, only markers on the slab and parapet tops. Window boxes stay on the houses, with the UI creator's geraniums in them.
- **Flat paving like vector art** (Parker: "the same height as the grout under them too, should all be flat, so it looks more like vector art and no ink hits the tiles"). Every paved surface (the square, the church front, the streets, the terrace lanes) is now ONE flat surface: stones and joints are coloured areas in a single plane, sharing their edges. Before, each stone floated 4-5 mm over the grout and got its own outline; now the ink draws only the paving's outer edge (env-pass 769e84b).

## Record

- **2026-11-07:** plan, then P0–P7 in one session.
  - The 2D spike failed; the game moved to Jolt on a plane.
  - All batteries pass.
  - A release export boots.
- **2026-11-07, 0.1.1:** pads drive the menus, Steam starts late, the house cel and ink look is in.
  - The random crowd and tower tests are now seeded, so runs repeat. An unseeded run once reached 11.4 cm in the crowd test.
