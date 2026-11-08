# Top Dog

A physics climbing party game. Grab, fling and freeze: each climber climbs the tower of everyone who went
before them, starting from a barrel in a wrestling ring in a sunny plaza. 3D to look at, played on one
plane. Godot 4.7.2, Jolt physics, GodotSteam.

## Start here

- **[docs/TOP_DOG_OVERVIEW.md](docs/TOP_DOG_OVERVIEW.md)**: everything about the game. How it plays, the
  controls and modes, the code layout, physics, netcode, controllers, testing and building.
- **[docs/HOUSE_ATLAS_AND_3D_MODELS.md](docs/HOUSE_ATLAS_AND_3D_MODELS.md)**: the shared colour atlas, how
  3D models are made and brought into the game, and the cel-shaded, inked look.
- **[docs/BOOK.md](docs/BOOK.md)**: every decision and the full record, newest at the bottom.
- **[CLAUDE.md](CLAUDE.md)**: the working rules for LLM sessions.

## Quick start

Open the folder in Godot 4.7.2 (Forward+) and press Play. Or export with
`godot --headless --path . --export-release "Windows Desktop" builds/TopDog.exe`.

| Action | Pad | Keyboard + mouse |
|---|---|---|
| Left hand | X | A |
| Right hand | A | D |
| Left foot | Y | W |
| Right foot | B | S |
| Steer the held limb | left stick | mouse |
| Lock in | Start | Space / Enter |
| Pause | Back | Esc |

Hold a limb's button to pick that hand or foot up and drag it. Let go, and it sticks to whatever it touches.
You can only move a limb while another one is stuck. F1 opens the live feel table.
