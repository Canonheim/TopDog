# Top Dog: the overview

Everything about the game in one place, for a new collaborator or an LLM working on it. For the full
history of every decision, read `docs/BOOK.md` (newest sections at the bottom, before "Record"). For
how the 3D models and the look work, read `docs/HOUSE_ATLAS_AND_3D_MODELS.md`.

## What it is

A **physics climbing party game**: grab, fling, freeze, and top your pals. Each player controls a ragdoll
climber (the Skeleton Knight for now) **one limb per button**. You start at a barrel in a wrestling ring in a sunny Mexican
plaza and climb. When your turn ends, your body **freezes where it is and becomes part of the tower**, so
the next climber goes up over you. Lock in above the line before the clock runs out, or you're out.
The first line sits 0.45 m above the barrel's top (`Stage.FIRST_LINE_ABOVE`), out of a standing climber's
reach.

It's Parker's spiritual successor to a classic limb-per-button climbing party game. **Never name that game
in files, commits or the build.** Call it "the reference game". Copy its mechanics only: never its art,
names, characters, music, sounds, text or levels.

- **Engine:** Godot **4.7.2**, Forward+ renderer.
- **Physics:** **Jolt**, with every piece locked to the z = 0 plane, so it plays exactly flat but looks fully 3D.
- **Online:** GodotSteam, Steam lobbies, on Valve's test app **480 (Spacewar)** until Top Dog has its own app ID.
- **Repo:** github.com/Canonheim/TopDog. `main` is the game, and `luchador-ui` is the 3D UI branch.
  Parker's code partner Dan also pushes to `main`.
- **Version:** `GAME_VERSION` in `net/net.gd`, shown as "BUILD x.y.z" in the title screen's bottom-right corner.
  It's bumped on every build, because RPC tables change between builds and the lobby refuses mismatched
  versions. Two people playing together need the same build.

## How it plays

### The limb rule

- A hand or foot you're **not** holding **sticks by itself** to whatever it touches, and stays stuck.
- **Hold a limb's button** to pick it up: it unsticks and follows your aim. A held limb can't stick.
- **Let go** to plant it: if it's touching something, it sticks right there.
- You can only move a held limb while you're **attached** by something else: another stuck hand or foot, or
  another climber holding you. Pick up your last stuck limb and you fall.
- **Live climbers can grab each other.** A grabbed climber can still drive their limbs.
- Limbs turn a **full 360°** with no joint limits and pass through each other. The climber's own pieces never
  collide with each other. Only the spine and neck have limits.

### The drag

Holding a limb **pulls its hand or foot toward the target** with a strong, capped elastic force, and the body
follows through stiff, bendy joints.

- **One budget:** the cap (`drag_strength`, 3.5 body-weights at full gravity) is **shared among the held
  limbs**, so holding more limbs never pulls harder. One held limb gets all of it and can drag the whole body.
- **Out of reach = full power:** a target past the limb's reach from its shoulder or hip pulls at the full cap.
- **Power, not speed:** a held hand or foot is never pushed faster than `drag_max_speed` (12.5 m/s). The trim
  looks one physics tick ahead, because the hand is light.
- **Lower gravity:** `gravity_scale` 0.75. The pull is measured at full gravity, so lowering gravity never
  weakens it.

- **Mouse:** the target is the mouse point.
- **Pad:** the **left stick points the limb instantly**. The target sits out from the shoulder or hip in the
  stick's direction, at the stick's push times `stick_reach` limb lengths (half a push reaches halfway out).
  A resting stick leaves the target where it was. The right stick does nothing.
- **Joints have friction**, so poses hold, and knees buckle sideways under a pull.
- **Grabs are welds:** a hinge locked at 0. A planted foot's ankle is stiff.

### Controls (the reference game's layout, all rebindable)

| Action | Pad | Keyboard + mouse |
|---|---|---|
| Left hand | X | A |
| Right hand | A | D |
| Left foot | Y | W |
| Right foot | B | S |
| Steer the held limb | left stick | mouse |
| Lock in | Start | Space / Enter |
| Pause | Back | Esc |

Each hand and foot shows its button as a small glyph: dim when loose, bright when held, and on a **white
circle when stuck**. In Practice and online, the one local player is "any device", so whatever you touch
last drives it. F1 opens the live **feel panel**, which shows every physics number.

### Modes (`data/modes.gd`, one row each)

- **Tower:** players take turns. Lock in above the line (the first line, then the tower's top) before your clock runs out, or you're out
  (your body stays in the tower). The last one in wins.
- **Scramble:** everyone climbs at once on the same timer. Every lock-in above the line raises it, so it's a
  race to the easy spots. The round ends when everyone still in has locked in, and the next round starts at
  the previous round's max height.
- **Practice:** climb alone. Nobody is ever out, and your best height is the score.
- **Settings:** clock of 40 s, 1 min or 1 min 30; spawn side alternating, left, right or random; stage (the
  Plaza Ring).

### The camera

In play it follows the live climbers, close (a climber fills about half the screen), not the whole tower.
The line comes into view as you climb toward it. In menus and between turns it frames the tower top.

### Local and online

- **Play together (this PC):** each controller or the keyboard joins as its own player.
- **Play online (Steam):**
  - Host a game: Public, Friends or Invite only.
  - **Join a friend:** your Steam friends playing Top Dog, each with a Join button.
  - **Browse games:** the lobby list.
  - In the lobby: player cards with READY stamps, preset chat, and Invite friends. The host picks the mode
    and clock and presses FIGHT!
- **LAN:** host, join this PC, or type an IP. ENet on a port, for same-network play and tests.

## How it's built

### Repo layout

| Path | What |
|---|---|
| `game/main.gd`, `main.tscn` | the app: world, camera, screens, pause, quit, music by screen |
| `game/game.gd` | one match (offline, host or client): turns, clocks, the line, lock-ins, freezes, results |
| `climber/climber.gd` | one physical climber: 16 rigid bodies, 15 hinges, the limb rule, the drag, glyphs |
| `climber/body_layout.gd` | the 16 pieces (shape, mass, mesh name) and 15 joints, measured from the Metal Knight; `Layout.shift()` (the wide shoulders) |
| `climber/drivers.gd` | who aims a climber: a player's device, a script (tests), or a remote puppet |
| `core/players.gd` (autoload `Players`) | local player slots, devices, bindings, `stick()` (left stick only), aim |
| `core/steam_input.gd` | reads controllers through Steam Input using Top Dog's own action manifest |
| `core/glyphs.gd` | button prompt textures for the limb glyphs |
| `core/sound.gd` (autoload `Sound`) | SFX and music (the theme in menus, "Desert Snake" in matches), volume, Master at 40% by default |
| `data/feel.gd` (autoload `Feel`) | **every feel number, in one table** (the F1 panel edits the same table) |
| `data/modes.gd`, `data/names.gd` | mode rows and timers; climber names |
| `net/net.gd` (autoload `Net`) | Steam and ENet sessions, the lobby, invites, friends, chat, the version gate |
| `net/lobby_logic.gd` | pure lobby helpers (rows, joinability). Its `GAME_TAG` must equal `net.gd`'s `LOBBY_TAG` (`topdog`) |
| `stages/stage.gd` | the ring deck, the barrel and their collision; the plaza dressing |
| `ui/pad_nav.gd` | turns every pad (raw or Steam) into `ui_*` actions so every menu works on a controller |
| `ui3d/lucha_ui.gd` | the **3D luchador front end**: title, menus, HUD, results, podium, plaza, sky |
| `ui3d/lucha_online.gd` | the 3D Online, Join a Friend, Browse and Lobby screens |
| `ui3d/menu3d.gd` | 3D belt menus with focus, pad and mouse navigation |
| `ui3d/lucha_kit.gd` | builds the UI pieces from kit models (by file name), with stand-ins; `text3d`, words out of the ink |
| `kit/models/` | the UI and plaza models from the Top Dog Kit (synced by `tools/sync_kit.py`) |
| `models/` | `skeleton_knight.glb` (the default climber), `metal_knight.glb` (kept), both 16 named pieces, and `barrel.glb` |
| `palette/`, `shaders/cel/`, `scripts/cel_pass.gd` | the house look: colour atlas, cel shader, ink outline |
| `fonts/luckiest_guy/` | the title font (Apache 2.0) |
| `audio/` | music and SFX |
| `textures/input_prompts/` | Kenney input prompt glyphs (CC0) |
| `addons/godotsteam/` | the GodotSteam GDExtension |
| `tests/` | the batteries and probes (below) |
| `tools/` | `sync_kit.py`, the music generator, the Steam upload script |
| `docs/` | `BOOK.md` (decisions and record), `PROVENANCE.md` (where every outside file came from), the how-to-play, these docs |

### The physics

- **The wide shoulders** (Golemheim's shoulder flare): every arm piece, its mesh and its shoulder, elbow and wrist
  joints sit `shoulder_flare` (0.05 m) further out and `shoulder_drop` (0.05 m) lower than the model
  (`Layout.shift()`). Both are F1 knobs, applied on the next spawn. Every machine must use the same values,
  because puppets and frozen bodies rebuild from the layout.
- **Jolt at 120 Hz**, `velocity_steps=20`, `position_steps=16`. 16 was raised from 8 because a free wrist
  stretched 2.4 cm when hanging by one hand.
- Each piece is a `RigidBody3D` with linear z and angular x/y locked.
- Joints are Jolt **hinges** around z. Their **motors** (target velocity 0, capped torque) act as joint friction.
  The spine and neck have soft springs.
- **Hinge signs are pinned by a test:** `MOTOR_SIGN = -1`, `LIMIT_FLIP = true`. If Godot or Jolt changes,
  rerun `--spike --part=signs` first.
- **THE LATE TRANSFORM LAW:** after moving a physics body, call `Climber.sync_server(body)` before making a
  joint to it, or the joint anchors to the old position.
- Why not 2D physics? Godot's 2D pins failed: their angle limits don't hold, and joints stretched up to 1.4 m.
  The record is in BOOK, "The physics call".

### The netcode: the host decides, owners simulate

- The **host** owns the rules: who's live, the clocks, the line, lock-ins (ordered by arrival), outs and results.
- Each live climber is **simulated by its player's machine**, which streams its 16 piece poses at 30 Hz.
  Everyone else shows it as a puppet with a 0.1 s buffer.
- A **freeze** is decided by the host, posed by the owner, and broadcast as one pose. Every machine builds the
  same static body from it, so towers match everywhere. **Never re-simulate a frozen body.**
- **Grabbing a rival on another machine:** you ride their puppet, and your pull is sent to their machine and
  applied to their real body, capped (`pull_cap`).
- `Layout.ORDER` is the wire order for the pieces. **Never reorder it.**
- **Offline,** Godot's OfflineMultiplayerPeer makes everything run through the same code path.

### Controllers

- **Without Steam:** `ui/pad_nav.gd` polls every pad and also reads joypad events, and turns presses into `ui_*`
  actions. A readout on every menu shows which pads the game sees and the last input received.
- **With Steam running:** on app 480, Steam forces Steam Input on and its default layout binds nothing. So the
  game hands Steam **its own action manifest** (written to `user://steam_input`, passed before `inputInit`).
  Steam controllers appear as devices 3000 and up. While Steam has controllers, raw pad reads are ignored so
  nothing counts twice.
- **Steam's source names:** in the layout, the left stick is `joystick` and the right stick is `right_joystick`.
  `left_joystick` isn't a source name: Steam drops that binding silently, so the stick reads zero online
  (fixed in 0.3.8). To check a binding, call `Steam.getAnalogActionOrigins` / `getDigitalActionOrigins` from a
  **focused, windowed** run. Steam binds the layout only to the focused app-480 instance, so close other
  copies first. An empty list means unbound.
- **The pause law:** only World and Game pause. Main, Players, Net and PadNav always run.

### The look

The house style from Golemheim: cel shading on one shared colour atlas, with a screen-space ink outline. No
bloom, no fog, no emissive colours, Linear tonemapping, and a bright cartoon-blue sky. The front end is
**all 3D, in the world** (lucha libre: belts, the pug mascot mask, papel picado, swirl clouds, a ring in a plaza).
UI words are flat Label3D in Luckiest Guy and skip the ink; the TOP DOG logo keeps its ink. The full detail
is in `docs/HOUSE_ATLAS_AND_3D_MODELS.md`.

## Working on it

### Rules for everyone (and every LLM session)

- **Read `docs/BOOK.md` first**, and the repo's `CLAUDE.md`.
- **One Godot process at a time.** Headless batteries always run with a timeout. A fresh checkout needs
  `godot --headless --path . --import` first.
- **Commit by path**, and check `git status` first: never `git add -A` blindly. **Fetch before you push** and
  merge others' work; never force-push.
- **Feel numbers live only in `data/feel.gd`.**
- **Every outside file** (code, font, sound, model) gets a line in `docs/PROVENANCE.md` with its source and licence.
- No reference-game names anywhere.

### Running and testing

Use Godot 4.7.2's console exe. From the repo root:

```bash
godot --headless --path . --import
godot --headless --path . res://tests/lint.tscn
godot --headless --path . res://tests/battery.tscn -- --no-steam --feel --bend --climb --grab --spike --frozen --tower --scramble --devices --net
godot --path . res://tests/pad_probe.tscn -- --no-steam
godot --path . res://tests/online_pad_probe.tscn -- --no-steam
godot --path . res://tests/online3d_probe.tscn -- --no-steam
```

- **`lint`** parses every script.
- **The battery** prints `PASS` / `FAIL` per check and ends `RESULT fails=N`. Its flags:
  - `--feel`: the drag behaviours watched in the reference game;
  - `--bend`;
  - `--climb`: getting onto the barrel;
  - `--grab`: the limb rule;
  - `--spike`: the physics, with parts signs, limits, hang, fling, limp, tower, eight and chain;
  - `--frozen`;
  - `--tower` and `--scramble`: the rules;
  - `--devices`: input;
  - `--net`: two machines over ENet in one process.
- **The probes** drive the real menus with fake pads: windowed, because the 3D UI needs a renderer.
- `tests/shot_probe.tscn -- --open=hud|pause|results|local --shot=PATH` saves a screenshot.
- **Windowed runs exit with code 139** after their work is done. That's a Godot 4.7.2 shutdown crash with the ink
  compositor. The exported game avoids it: `quit_game` tears down and then kills its own process, and the
  window's X goes through it too.

### Building

- Export: `godot --headless --path . --export-release "Windows Desktop" builds/TopDog.exe`.
- The build folder needs `TopDog.exe`, `libgodotsteam.windows.template_release.x86_64.dll`, `steam_api64.dll`,
  `HOW TO PLAY.txt` (from `docs/PLAYTEST_HOW_TO_PLAY.txt`), and `TopDog (no Steam).bat`. That bat starts the
  game with Steam off, for when Steam grabs a controller.
- Bump `GAME_VERSION` for every build you hand out.
- If `builds\TopDog.exe` is running, the export can't replace it. Export to `builds/<version>/TopDog.exe` instead.

## Known gaps and what's next

- **Steam needs testing with two real accounts:** the friends list with real Steam friends, and avatar
  loading.
- **Bumping across machines is one-way:** only grabs send force.
- **No spectating mid-match.** Late joiners are refused.
- **The climbers:** the Skeleton Knight is the default. Muscular luchadors in animal masks are coming from another
  artist, as skins on the 16-piece contract; players will pick their own skins then. Until then everyone looks
  the same: there's no colour wash, and the player colour is only on name tags and cards.
- **A full feel pass** after playtests. Every number is on F1 and in `data/feel.gd`.
