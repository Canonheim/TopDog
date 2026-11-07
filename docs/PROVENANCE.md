# Provenance: what came from where

| In this repo | From | Changes |
|---|---|---|
| `addons/godotsteam/` (gdextension, license, win64 and linux64 libraries) | Golemheim `addons/godotsteam/` (GodotSteam GDExtension Community Edition, MIT) | Other platforms and the editor plugin left out |
| `net/lobby_logic.gd` | Golemheim `scripts/lobby_logic.gd` | Trimmed; tag `topyourpals`; our modes |
| `net/net.gd` (Steam init, lobby create/join/browse, invites, `+connect_lobby`, version gate, ghost-lobby and crossed-join guards, the Steam exit cut) | Golemheim `scripts/net.gd` | Rewritten small around those pieces; app 480 |
| `core/save_paths.gd` | Golemheim `scripts/save_paths.gd` | As is |
| `textures/input_prompts/` | Golemheim (Kenney Input Prompts, CC0) | As is |
| `models/metal_knight.glb` | Golemheim `models/Metal_Knight.glb` | Texture path pointed at `../palette/house_atlas.png` |
| `models/barrel.glb` | `Armory Second Look\Armory_Remake\models\atlas\barrel.glb` (Parker's REMAKE pick) | Texture path pointed at `../palette/house_atlas.png` |
| `models/palette/house_atlas.png` | `Desktop\House Style 3D Kit\atlas\house_atlas.png` (byte-identical to Golemheim's atlas) | As is |
| `audio/sfx/` grunts, hurt, thud, land, clap, UI, victory, defeat, bell, tick, yells | Golemheim `audio/sfx/` (its procedural set) | Two renamed (`lock_bell`, `clock_tick`) |
| `audio/sfx/slap_1-4.wav`, `grip.wav` | New, synthesized here | |
| `audio/music/top_your_pals_theme.ogg` | New, `tools/music/theme.py` | Made with the house method |
| `tools/music/sf_kit.py` | Golemheim `tools/music/sf_kit.py` | As is |
| `tools/bin/fluidsynth/`, `tools/soundfonts/` | Golemheim `tools/` (FluidSynth; GeneralUser GS, its license beside it) | Local only: gitignored |
| `tools/steam/upload_build.bat` | Golemheim `tools/steam/upload_build.bat` | App and depot IDs as settings; refuses until set |
| Body measurements in `climber/body_layout.gd` | Golemheim `scripts/segmented_body.gd` joint constants and the Metal Knight's piece bounds | Re-expressed as a planar ragdoll |
| Two-bone solve in `climber/climber.gd` | The idea of Golemheim's `_solve_chain` | Rewritten in 2D |
