# Top Your Pals

A physics climbing party game. Grab, fling and freeze: each climber climbs the
tower of everyone who went before them, starting from a barrel. 3D to look at,
played on one plane. Godot 4.7.2, Jolt physics, GodotSteam.

## Run it

- **Play:** open the project in Godot 4.7.2 and press Play, or run
  `builds\TopYourPals.exe` after an export.
- **How it plays:** hands and feet stick to whatever they touch, by themselves.
  Hold a limb's button to pick it up and steer its hand (or foot) with the stick
  or the mouse; the elbow and shoulder (knee and hip) bend either way to follow.
  Let go to plant it.
- **Steam starts when you open Play online**, not before. On Valve's test app
  (until we have our own) Steam takes the controller, so local play stays clear
  of it. You can only move a limb while another is stuck (or a pal
  is holding you). Pick up your last stuck limb and you fall.
- **Controls (rebindable in Controls), the reference game's layout:** holding a
  limb's button pulls its hand or foot to the cursor (mouse) or the stick's
  target; the body follows through stiff, bendy joints.

  | Action | Pad | Keyboard + mouse |
  |---|---|---|
  | Left hand | X | A |
  | Right hand | A | D |
  | Left foot | Y | W |
  | Right foot | B | S |
  | Steer the held limb | either stick | mouse |
  | Lock in | Start | Space / Enter |
  | Pause | Back | Esc |

- **Swap devices any time.** In Practice and online, the one local player is
  "any device": whatever you touch last drives, and the glyphs on the hands and
  feet switch with it. Play together (this PC) gives each joined device its own
  player.
- Each hand and foot wears its button (the reference game's idea): dim when
  loose, bright while held, green when stuck.
- The bottom line of every menu shows which pads the game sees and the last
  pad input it received. If a pad is listed but that line never changes while
  you press, something outside the game has the pad.
- **F1** opens the feel table: every physics and control knob, live.

## Modes

- **Tower:** take turns; lock in above the top before the clock runs out.
- **Scramble:** everyone at once; every lock-in raises the line; the round ends
  when everyone still in has locked in; the next round starts at the max height.
- **Practice:** climb alone.

Online play is through Steam lobbies (host, browse, invites) or LAN. Up to 8
climbers; more than one can play from the same PC.

## Batteries (headless tests)

```
Godot_v4.7.2-stable_win64_console.exe --headless --path . res://tests/battery.tscn -- --no-steam --spike --grab --frozen --climb --tower --scramble --devices --net
Godot_v4.7.2-stable_win64_console.exe --headless --path . res://tests/lint.tscn -- --no-steam
```

Always run them with a timeout, one Godot at a time. The menu's pad check runs
windowed: `... --path . res://tests/pad_probe.tscn -- --no-steam`.

Steam starts when you open Online play (or at boot with `-- --steam`).

## Layout

| Folder | What |
|---|---|
| `climber/` | the physical knight (`climber.gd`), its body layout, the drivers |
| `game/` | the match (`game.gd`, host-decided rules and netcode), the app (`main.gd`) |
| `net/` | Steam/LAN sessions and the lobby (`net.gd`), the lobby-list logic |
| `core/` | per-device players and binds, sound |
| `data/` | the feel table, the modes, names |
| `stages/` | the dock and the barrel |
| `models/` | the Metal Knight, the barrel, the house atlas |
| `audio/` | effects and the theme (`tools/music/theme.py` renders it) |
| `tools/steam/` | the depot upload (needs our own Steam app ID) |
| `docs/` | `BOOK.md` (decisions and the record), `PROVENANCE.md` (what came from where) |
