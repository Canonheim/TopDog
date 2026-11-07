# Top Your Pals

A physics climbing party game. Grab, fling and freeze: each climber climbs the
tower of everyone who went before them, starting from a barrel. 3D to look at,
played on one plane. Godot 4.7.2, Jolt physics, GodotSteam.

## Run it

- **Play:** open the project in Godot 4.7.2 and press Play, or run
  `builds\TopYourPals.exe` after an export.
- **Controls (rebindable in Controls):**

  | Action | Keyboard + mouse | Pad |
  |---|---|---|
  | Left hand | Left mouse (or Q) | LB |
  | Right hand | Right mouse (or E) | RB |
  | Left foot | A (or Z) | LT |
  | Right foot | D (or C) | RT |
  | Steer the held limbs | mouse | either stick |
  | Lock in | Space | A |
  | Pause | Esc | Start |

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
Godot_v4.7.2-stable_win64_console.exe --headless --path . res://tests/battery.tscn -- --no-steam --spike --grab --frozen --climb --pullup --tower --scramble --devices --net
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
