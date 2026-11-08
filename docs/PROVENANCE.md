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
| `palette/` (the atlas, its two masks, the map, their imports) | `Desktop\House Style 3D Kit\godot\demo_project\palette\` (the atlas is byte-identical to Golemheim's) | As is |
| `shaders/cel/` (the cel shader, ramp, includes, the ink host and its six compute passes) | `Desktop\House Style 3D Kit\godot\demo_project\shaders\cel\` (Golemheim's, generalized; its LICENSE beside it) | As is |
| `scripts/cel_pass.gd`, `scripts/atlas_map.gd` | the same kit, `scripts\` | As is |
| `ui/pad_nav.gd` | Golemheim `scripts/ui_pad.gd` (ensure focus, focus first, the legend idea) | Rewritten: reads every pad directly |
| `audio/sfx/` grunts, hurt, thud, land, clap, UI, victory, defeat, bell, tick, yells | Golemheim `audio/sfx/` (its procedural set) | Two renamed (`lock_bell`, `clock_tick`) |
| `audio/sfx/slap_1-4.wav`, `grip.wav` | New, synthesized here | |
| `audio/music/top_your_pals_theme.ogg` | New, `tools/music/theme.py` | Made with the house method |
| `tools/music/sf_kit.py` | Golemheim `tools/music/sf_kit.py` | As is |
| `tools/bin/fluidsynth/`, `tools/soundfonts/` | Golemheim `tools/` (FluidSynth; GeneralUser GS, its license beside it) | Local only: gitignored |
| `tools/steam/upload_build.bat` | Golemheim `tools/steam/upload_build.bat` | App and depot IDs as settings; refuses until set |
| Body measurements in `climber/body_layout.gd` | Golemheim `scripts/segmented_body.gd` joint constants and the Metal Knight's piece bounds | Re-expressed as a planar ragdoll |
| Two-bone solve in `climber/climber.gd` | The idea of Golemheim's `_solve_chain` | Rewritten in 2D |

## Downloaded

| Ours | Source | Licence | Date |
|---|---|---|---|
| `fonts/luckiest_guy/LuckiestGuy-Regular.ttf` | Luckiest Guy by Astigmatic (Brian J. Bonislawsky), Google Fonts' own repository: https://github.com/google/fonts/tree/main/apache/luckiestguy (fonts.google.com/specimen/Luckiest+Guy) | Apache License 2.0 (`fonts/luckiest_guy/LICENSE.txt`; Google Fonts lists it as APACHE2, not OFL) | 2026-11-07, Parker's OK |
| `models/skeleton_knight.glb` | Parker's artist: Skeleton Knight on the 16-piece Defaultio contract (Parker 2026-11-07); its embedded Golemheim atlas swapped for the uri `../palette/house_atlas.png` (all 12 colours it uses are pixel-identical), sampler set nearest | Parker's own asset | 2026-11-07 |
