# Top Your Pals: build plan

A physics climbing party game: 3D to look at, played on one plane. Climbers race or take turns up a tower made of the climbers who went before them, starting from a barrel.

It's a spiritual successor to a 2013 tower-climbing party game Parker owns on Steam, called "the reference game" in this repo. It's built on Golemheim's code and art kit, in Godot 4.7.2, with GodotSteam on its own Steam app.

**State (2026-11-07):** BUILT, P0-P7, in one session. Parker answered every call in section 8. The 2D-physics call failed its gate and the game runs on Jolt locked to the plane: see docs/BOOK.md, which is the record from here on.

---

## 1. What we take from the reference game, and what we don't

The reference game was read from its install: the text in its executable, its body and prop definition files, and its Steam page.

- It's an XNA game on Farseer, a 2D physics engine descended from Box2D.
- Each climber is about 15 rectangles joined by revolute joints, with friction joints for stiffness.
- A hand or foot sticks to what it touches with a weld joint.

**The mechanics we copy (mechanics only):**

| Mechanic | How it works there |
|---|---|
| One button per limb | Left hand, right hand, left foot and right foot each have a button, plus an end-turn button. |
| Hold to drive | While a limb's button is held, the stick or mouse drags that limb's end. Its help text: "Hold [button] to drag appendage". |
| Hold to stick | A held limb "sticks to surfaces automatically" on touch. Releasing the button lets go. An unheld limb hangs limp. |
| Only attached limbs move | You can drive your limbs only while you're attached to something. Fling off and you're a limp body until you catch on. |
| Climbing comes from anchored limbs | Drive a stuck hand and the body swings around it. Flinging is swinging and then letting go. There's no jump button. |
| The climber faces the camera | Limbs swing in the screen plane, like jumping jacks. |
| The base | The first climber climbs a goat (ours is **a barrel**). Every later climber climbs the frozen tower on top of it. |
| The turn | A timer of 40 s, 1 min or 1 min 30. When it runs out you **freeze in place**, even mid-fling, and become part of the tower. You must end above the previous top, or you're out, but your body stays in the tower. |
| Spawns | Alternating sides, one side, or random. |
| Online | A Steam P2P lobby: public or private, invites, kick, ready / not ready, preset chat lines. The host sets the level, timer and spawn. |

**What we don't take:** any of its art, names, characters, music, sounds, text, word lists, level layouts or look. Ours are Golemheim's knights, our barrel, our stages, a new music track, our own sounds and our own name generator. No reference-game names go in this repo's files or commits.

**What's new in ours:**
- 3D bodies and stages.
- **Three torso segments that flex left and right.**
- The barrel base.
- **Many live climbers at once** (section 4a), and a new mode built on that, Scramble.

---

## 2. What Golemheim gives us (read from the repo, 2026-11-07)

**Lift nearly as-is:**
- `addons/godotsteam/`: GodotSteam GDExtension, MIT.
- `scripts/lobby_logic.gd` and `lobby_test.gd`: the pure lobby-list logic, already tested.
- The Steam parts of `scripts/net.gd`:
  - `_init_steam`, `host_steam` and `_on_lobby_created`, `join_steam` and `_on_lobby_joined`
  - `request_lobby_list`, `invite_friends`, `_on_join_requested`, and `+connect_lobby` with `_boot_join`
  - `_sender_owns`, `_rate_ok`, the sequence numbers, `GAME_VERSION`
  - push routing (`push_item`, the impulse cap)
- `scripts/keybinds.gd`, `rebind_menu.gd`, `input_glyphs.gd` (Kenney prompts, CC0), `ui_pad.gd`.
- `scripts/sound.gd`, `options.gd`, `save_paths.gd`, `achievements.gd`, `chat.gd`.
- `tools/steam/upload_build.bat` and the `app_build` vdf, with the IDs swapped. Keep the file-list staging law: every DLL goes on the list, or Steam ships without it silently.
- `Desktop\House Style 3D Kit\`: the atlas, cel shader, ink outline and Blender build contract.
- The music method: `Desktop\Making Game Music with GeneralUser GS.md` and the `sf_kit` toolkit, for the new track.

**Lift the art:**
- **The climber is the Metal Knight**, the default knight, on the 16-piece `Defaultio` contract:
  - Head, Chest, Navel, Pelvis;
  - Shoulder, Wrist and Hand, ×2;
  - Thigh, Shin and Foot, ×2.

  Parker's artist is making new skins for this game. Any skin that keeps the 16 Defaultio piece names drops in piece by piece (Golemheim's `skin_data.gd` model-skin way).
- The barrel: `Armory Second Look\Armory_Remake\models\atlas\barrel.glb` (Parker's REMAKE pick), plus `build_barrel.py`.
- Stage dressing from the hub, Training Grounds and props kits: docks, planks, crates, rocks.
- Sounds from `audio/sfx/`: grunts, hurt, thud, land, clap, UI. There's no slap, so we make one in `Clod Things\SFX Lab`.

**Rewrite, keeping the patterns:**
- **The body.** The living Golemheim body is posed by script, and the only physical version, the corpse ragdoll, is pins on Jolt that `loose_chain.gd` records tearing apart. The climber is new in any case, and it's 2D physics (section 3).
- **Snapshots and puppets.** `puppet.gd` extends the 19,397-line `fighter.gd`, so we write a small body stream on the lifted transport.
- **Keybinds defaults and per-device players.** Golemheim has one logical player, and any pad drives it. Players per device are new work.
- **Menus and ready-up.** Plain screen menus, since Golemheim's world-space UI law is Golemheim's. Golemheim has no generic ready-up, so we write one.

**Not a fork.** The Golemheim repo is 4.4 GiB and 17k files. The new repo starts empty, and files are copied in with a note of where each came from (`docs/PROVENANCE.md`). The third-party licenses come along with their files.

**Fix on the way in:** the two input gaps found while writing the coworker doc.
- The triggers are leg buttons here, so both get one shared threshold.
- Every stick read goes through the player's own device, never device 0.

---

## 3. The climber, as designed

### Physics: 2D under 3D (Parker's call)

The bodies are simulated by **Godot's built-in 2D physics**, which needs no download. The 3D meshes follow the 2D bodies, so it plays exactly flat and looks fully 3D.

- **The 2D world is a hidden physics layer.**
  - Scale: 100 px = 1 m, with y flipped.
  - Each 3D piece takes its 2D body's position and angle every frame, interpolated between physics ticks.
- **Physics runs at 120 Hz.**
- **Stages get 2D collision.** Every stage, prop and barrel has a 2D collision outline, sliced from its 3D mesh at the play plane by a small tool (`tools/slice_collision`). So what you see at the plane is what you touch.
- **Freezing is cheap.** A frozen climber becomes plain 2D static shapes.
- **The fallback.** If Godot's 2D joints are too soft or wobbly in the P1 test, the candidate is Rapier 2D (the `godot-rapier` GDExtension). That's a download, so it's Parker's yes first.

### Body
16 rigid pieces, one per Defaultio piece, with the hands and feet as the grab ends.

| Joint | Start range (tuned in play) |
|---|---|
| Chest to Navel, Navel to Pelvis | ±12° each |
| Neck | ±30° |
| Shoulders | ±170° |
| Elbows | 0–150° |
| Hips | ±150° |
| Knees | 0–150° |
| Wrists and ankles | ±40° |

**Torso flex (Parker's call): a passive spring only.**
- The two spine joints give about ±24° in all, with a soft spring back to straight.
- There's no input for it. It bends because a limb driving left or right pushes against the torso piece it hangs from.
- So reaching hard to one side curls the spine that way, and a hang or a swing bends it too.
- The spring's stiffness and damping are feel knobs.

### Driving a limb
- **When you can drive.** You can drive your limbs only while you're **attached**: at least one of your hands or feet is stuck to something, **or another climber is holding you** (Parker's call). A grabbed climber can still move every limb, even with nothing of its own stuck. When you're fully loose, mid-fling or falling, the motors are off and you're limp until a held limb catches.
- **A held limb aims at a target:**
  - On a pad, the target is the shoulder or hip plus `stick × reach`.
  - With a mouse, it's the mouse's point on the plane, clamped to reach.
  - A two-bone solve turns the target into joint angles (Golemheim's `_solve_chain` math, in 2D).
  - Joint motors drive toward those angles with a **capped torque**. The cap makes it a struggle: an arm lifts the body slowly, it doesn't snap.
- **An anchored hand:** the same motors swing the body around the hand. That's climbing and flinging, with no extra code.
- **An unheld limb:** motors off, and joint friction makes it hang heavy and loose.
- **Every held limb follows the one stick.** Holding two limbs moves both, which is the fun, awkward part.

### Grab
- A held hand or foot that touches a body sticks to it, with a joint made at the contact point. That body can be the world, the barrel, a frozen climber, or **another live climber**.
- Releasing the button removes the joint.
- There's one grab per limb end and a short regrip delay.
- A climber can't grab itself.
- There's no break force at first. Whether a big yank should tear a grab is a tuning call.

### Lock in and freeze
- **Lock In** is the old end-turn button. You can press it once you're above the line, and you freeze where you are.
- **Running out of time also freezes you** where you are, even mid-fling.
- **A frozen body stays in the tower forever,** whether it beat the line or not (Parker's call). Its motors and grabs are removed, it becomes static, and no one owns it.
- **Height** is the highest point of any piece, measured from the frozen pose.
- If a climber freezes while someone holds it, that grab moves to the frozen piece at the same spot, so the holder doesn't drop.

### One climber scene for every case
The climber takes a **driver**: local input on any device, a remote stream (a puppet), or a script (for batteries and bots). Nothing in it assumes it's the only live body.

### Feel knobs
All in one data table (`data/feel.gd`), with a live dev panel so Parker can tune in play. "Test" means a starting guess, not a measurement.

| Knob | Start |
|---|---|
| Physics rate | 120 Hz, solver iterations 16 (test) |
| Gravity | 1.0 × 9.8 m/s² |
| Masses | Golemheim's ragdoll ratios, with the torso's 8 split 3.5 / 2 / 2.5, neighbouring pieces within 1:4 |
| Motor torque cap | per limb; the main "struggle" dial |
| Joint friction (limp) | angular damping, test |
| Friction | hands and feet 1.2, body 0.6 |
| Bounce | 0 |
| Spine spring | stiffness and damping |
| Grab | reach radius and regrip delay |
| Hands and feet | continuous collision on |

---

## 4a. Modes are data, and many climbers can be live

There's no "the current climber" anywhere in the code. A mode is a row in `data/modes.gd` plus small hooks in `game/mode.gd`, and it answers these questions:

| | **Tower** (turns) | **Scramble** (all at once) |
|---|---|---|
| Who's live | One climber at a time, in turn | Everyone still in, at once |
| Clock | Each turn has the timer (40 s, 1 min or 1 min 30) | Each round has the same timer |
| The line | The tower's top before your turn | Starts the round at the previous round's max height (the barrel top in round 1). **Every lock-in above the line raises it** to that climber's height, so it's a race to the easy lock-ins. |
| Lock in | Once you're above the line | Once you're above the line as it stands when you press |
| Round end | Your lock-in, or time out | **When everyone still in has locked in above the line**, or time out |
| Who's out | Frozen under the line | Anyone not locked in above the line at time out. They freeze where they are and stay in the tower. |
| Who wins | The last one left | The last one left |

Each new Scramble round respawns everyone still in, at the spawn sides.

**Assumptions to confirm on the first play** (they're mode-table values, so they're cheap to change):
- The raised line is the locker's highest point.
- If two climbers lock in during the same tick, the host takes the first one that arrives.

The camera frames every live climber, the tower top and the line, zooming out to fit. There's no split screen.

**Later modes** are new rows: teams, relays, brackets, 1v1, gravity and wind stages, collect modes, a sandbox, a speed climb.

---

## 4. Build phases

Each phase ends with something that runs and a check that proves it. Godot work follows Golemheim's laws:
- One Godot at a time, killed as a whole process tree.
- Headless batteries with timeouts.
- `--import` first in a fresh checkout.
- Anything long or data-writing is Parker's to trigger.

### P0: repo and skeleton
- **Repo:**
  - `Clod Things\TopYourPals`, `git init`, and a private GitHub repo `Canonheim/TopYourPals`.
  - It's created on Parker's start word, and pushed only when he asks.
- **Project:** Godot 4.7.2, Forward+, 2D physics at 120 Hz, physics interpolation on.
- **Copy-ins** from section 2, recorded in `docs/PROVENANCE.md`.
- **Every Golemheim ID renamed:**
  - app `5196400` in `steam_appid.txt` and the code, and depot `5196401`;
  - the tags `LOBBY_TAG` and `GAME_TAG` (`"golemheim"` becomes `"topyourpals"`);
  - `GAME_VERSION`, the user-facing "Golemheim" strings, and the export names.
- **Steam app 480 (Spacewar)** with our own lobby tag, until Parker makes our own app at P7.
- `README.md`, `CLAUDE.md` (these laws), and `docs/BOOK.md` (decisions and calls).
- **Done when:** the project imports and opens to an empty stage, and `--lint` is clean.

### P1: the physics spike
One 2D climber with the Metal Knight following, and a headless battery `--spike` with these tests:

| Test | Pass |
|---|---|
| hang | One hand stuck to a bar for 30 s. Joints separate under 2 cm. |
| fling | A full-torque swing and release, 50 times. No joint opens past 5 cm, and nothing explodes. |
| limp | Fully loose, the motors are off. They come back the tick a held hand sticks. |
| tower | 20 frozen climbers stacked plus one live, frame time noted. |
| eight live | Eight live climbers tangled and grabbing each other. Joints hold, and the tick stays under 4 ms at 120 Hz on this PC. |
| chain | A hangs from B, B hangs from C, C is stuck to the barrel. C freezes. The grabs move to the frozen pieces with no drop. |

If Godot 2D fails these, we ask Parker about Rapier 2D. **Done when** the battery passes, and the choice is written in the book.

### P2: one climber that feels right
- Hold, drive, stick and release; the attached-only rule; torso flex.
- Keyboard and mouse, plus pad.
- The feel table and dev panel.
- A test stage: the barrel on a dock plank, with a few frozen dummies.
- **Batteries:**
  - `--grab`: stick, hold and release on each surface.
  - `--climb`: a scripted input stream climbs the barrel.
  - `--frozen`: the freeze is exact, and the height is read from the pose.
- **Parker's feel walk.** This is the gate for the rest; we tune until he says it's fun.

### P3: the mode framework, Tower and Scramble
- The mode table and hooks from 4a.
- Both modes in full, plus solo Practice (climb a fixed tower for best height).
- **Spawn sides:** alternating, one side, or random.
- **The camera** frames all the live climbers.
- **Out of bounds:**
  - A fall to the ground isn't a loss; you climb again while time lasts.
  - Leaving the stage sides respawns you.
- **Results screen.**
- **Batteries:**
  - `--tower`: a scripted 3-climber match plays to a winner.
  - `--scramble`: 4 scripted climbers play rounds. The line rises on each lock-in, a round ends when all have locked in, time-outs knock climbers out, and the next round starts at the max height.

### P4: local multiplayer
- **Players per device:** each pad is a player, plus one keyboard-and-mouse player, joined from a "press A to join" screen.
  - **Scramble** needs a device per player.
  - **Tower** lets up to 8 players share 4 pads.
- **Steam Remote Play Together** then gives friends online couch play for free.
- **Battery:** four simulated devices drive four live climbers, with no crosstalk.

### P5: online over Steam
- **Lobby:** the lifted Steam code.
  - Host, browse, join a friend, invites.
  - A lobby screen with the player list.
  - Ready / not ready, preset chat lines plus typed chat.
  - The host sets mode, timer, spawn and stage, and can kick.
  - Up to 8 players.
- **Authority:**
  - The host owns the match: who's live, the clocks, the line, lock-ins, who's out, and results.
  - **Each live climber is simulated on the machine its player sits at,** so your own body never waits on the network.
  - Machines with several local players own all of them.
  - Each streams its 16 piece transforms at 30 Hz with sequence numbers, plus its grab list. The stream is unreliable, and never `unreliable_ordered` lanes, which Steam turns reliable.
  - Puppets are interpolated and **solid**: something you can bump and grab.
- **Live climbers touching across machines:**
  - **Grabbing a rival:**
    1. Your machine joins your hand to their puppet, so you ride along at once.
    2. It sends "grabbed at piece P, point X", and then your pull force at 30 Hz, to their machine.
    3. Their machine applies the pull to their real body, capped.
    4. They feel your weight about a ping later. Being grabbed also counts as attached on their machine, so they can still drive.
  - **Bumping:** a contact sends a capped impulse to the other body's owner, so pushes go both ways.
  - **Releases and freezes** go reliably. A grab on a body that freezes moves to the frozen piece everywhere.
  - **Fallback if it feels bad:** a mode can switch to the host simulating everyone, with clients sending input at 60 Hz. Contact becomes exact, but your own climber lags by your ping. The driver design makes this a setting, and P5 tests both.
- **Lock-ins, the freeze and the tower:**
  1. A lock-in or a time-out reaches the host.
  2. The host sends "freeze", reliably.
  3. The owner sends its final pose, reliably.
  4. The host checks the pose, then broadcasts it with the new line.
  5. Every peer builds the same static body from the same numbers.

  So **the tower is identical everywhere.** In Scramble, the host orders lock-ins by arrival, so everyone sees the same line.
- **Edges:**
  - A live climber who disconnects freezes as they last were, and is out.
  - If the host leaves, the match ends with "Host left".
  - A late joiner spectates and gets the tower list.
  - A version mismatch is refused.
- **Tests:**
  - A host and a client over ENet loopback, **in one process** (one Godot at a time). Checks the stream, the freeze and identical towers.
  - Scramble over loopback with added lag and loss. Grabbing a rival on the other "machine" works both ways, two lock-ins land in the same tick, and the towers match after a freeze mid-grab.
  - Then a real Steam session on two accounts and two machines, with Parker and a friend.

### P6: look, sound and menus
- **Look:** house style (atlas, cel, ink), the Metal Knight with colour tints until the artist's skins land, a dock stage in Golemheim's style, and the barrel up close.
- **Sounds:** grunts, slaps and thuds; strain sounds on effort; a grab sound.
- **A new music track** for this game, made by the house music method. It goes to Parker to hear before it's in.
- **The rest:** our own name generator with our own word lists; main menu, options, rebinding with glyphs, and pause, all as screen UI.

### P7: playtest build
- Parker makes the Steamworks app, which means the Steam Direct fee, and then we switch from 480 to our own app ID and depot.
- A Windows export, `upload_build.bat` with its file list, and a playtest branch.
- **The finish line, "online-testing-ready":**
  - Tower and Scramble for 2–8 players online, local pads mixed with online, and Practice.
  - Lobby, invites, rebinding and options.
  - Every battery passing.
  - One real online session played.

---

## 5. Netcode in one picture

```
pad/mouse -> Keybinds (per device) -> the owning machine simulates each of ITS live climbers
   -> 30 Hz piece stream + grab list (unreliable, seq) -> Steam -> solid puppets everywhere else
touching a rival's puppet -> "grab"/"push" sent to that climber's owner -> applied to the real body (capped)
host: who's live, clocks, line, lock-in order -> "freeze" (reliable) -> owner sends final pose (reliable)
   -> host checks + broadcasts pose and new line -> every peer builds the same static tower piece
```

Tower has one live body at a time. Scramble has up to 8, one owner each. Either way, the frozen tower is plain static data, so it costs nothing to keep in sync and is resent whole to a late joiner.

---

## 6. Repo layout (planned)

```
TopYourPals/
  project.godot  steam_appid.txt  export_presets.cfg
  addons/godotsteam/         (copied, MIT)
  core/    keybinds.gd rebind_menu.gd input_glyphs.gd sound.gd options.gd save_paths.gd
  net/     net.gd lobby_logic.gd chat.gd body_stream.gd contact_route.gd
  climber/ climber.gd body2d.gd limb.gd grab.gd freeze.gd follow3d.gd drivers/ climber.tscn
  game/    mode.gd tower.gd scramble.gd clock.gd line.gd camera.gd
  data/    feel.gd modes.gd skins.gd names.gd
  stages/  dock/ (barrel, planks, backdrop, 2D outlines)
  models/  (Defaultio, Metal Knight, barrel, copied)
  audio/   music/ (new track)  sfx/
  shaders/ textures/
  tests/   spike grab climb frozen tower scramble devices net_loopback lobby
  tools/   steam/ slice_collision/
  docs/    BOOK.md PROVENANCE.md
```

---

## 7. Risks

| Risk | What we do |
|---|---|
| Godot's 2D joints are soft or wobbly under flings and crowds | The P1 gate, with Rapier 2D as the fallback on Parker's yes. |
| The 3D look and the 2D collision disagree | Collision is sliced from the meshes at the play plane, and a debug view draws the outlines over the 3D. |
| The feel isn't fun | Every knob is in one table with a live panel. Parker's walk is the P2 gate. |
| Towers differ between machines | Built from one broadcast pose, never re-simulated. |
| Grabbing a rival online feels soft or laggy, because two owners touch | Forces go to the owner, capped, tested with added lag. Host-simulates-all is the per-mode fallback. |
| A Scramble lock-in race is unfair across ping | The host orders lock-ins by arrival, and everyone sees the same result. If it plays badly, this is a tuning call for Parker. |
| 8 live bodies plus a tall tower cost too much | Measured in P1. Frozen bodies are static shapes. |
| Steam needs two accounts and a real app | Test on 480 with our own tag first. The real app is Parker's to make at P7. |

---

## 8. Calls, answered by Parker (2026-11-07)

1. **Physics:** 2D physics from the start.
2. **Failed climbers** stay frozen in the tower.
3. **Torso flex** is a passive spring only. It's steered by reaching left or right, since the limbs push on the torso.
4. **Climber:** the default knight (the Metal Knight) for now. His artist is making skins for this game.
5. **Steam:** test on 480 first. Parker makes the real app.
6. **GitHub:** the Canonheim account.
7. **Music:** a new track for this game.
8. **UI:** new game, new rules: screen menus.
9. **Scramble:**
   - Same time limit as normal, with everyone at once.
   - A lock-in above the line raises the line mid-round.
   - The round ends when everyone has locked in above the line.
   - The next round starts at the previous round's max height.
10. **Live climbers can grab each other.** A grabbed climber can still move its limbs even when nothing of its own is attached.
