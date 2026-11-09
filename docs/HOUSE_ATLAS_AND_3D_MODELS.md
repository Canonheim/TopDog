# The house colour atlas and 3D model system

How every 3D model in Top Dog is made, coloured and drawn. Written for a person or an LLM making new
models or touching the look. Read it all once before making a model; the rules are short but strict.

## The look in one breath

Low-poly, flat-shaded, **one colour per face** taken from **one shared colour atlas**. No textures, no
vertex colours, and **one material per model, named `PALETTE`**. A **cel shader** bands the light into
hard steps, and a **screen-space ink outline** draws every edge. The finish is matte: no bloom, no fog,
and (for Top Dog, by Parker's call) **no emissive colours at all**.

## Where everything lives

| What | Where | In this repo? |
|---|---|---|
| The atlas (the one colour texture), its two masks, and the colour map | `palette/house_atlas.png`, `house_atlas_emit.png`, `house_atlas_surface.png`, `house_atlas_map.json` | yes |
| The cel shader and the ink outline (compositor + 6 compute passes) | `shaders/cel/` | yes |
| The pass that applies the look to loaded models | `scripts/cel_pass.gd` (class `CelPass`) | yes |
| Named-colour lookup in GDScript | `scripts/atlas_map.gd` | yes |
| The game's copies of the UI/plaza models | `kit/models/*.glb` | yes |
| The climber (Defaultio, Skeleton Knight and Metal Knight) and the barrel | `models/defaultio.glb`, `models/skeleton_knight.glb`, `models/metal_knight.glb`, `models/barrel.glb` | yes |
| The **Top Dog Kit**: one build script per model, previews, the parts list | Parker's machine, `Desktop\Clod Things\Top Dog Kit\` | **no** |
| The **House Style 3D Kit**: the atlas tools, gates, checker, the full style guide and recipe book | Parker's machine, `Desktop\House Style 3D Kit\` | **no** |

The two kits are not in the repo. If you need their tools (the converter, the gates, the checker), ask
Parker for a copy. Everything below tells you what they do, so you can work without them if you must.

## The atlas

One image, **2048 x 2048 px**, pure colour. Every face's UVs collapse to **a single point** on the colour
that face wears. "Metal" and "glow" are *where on the sheet* a face points, not material settings.

Why: one texture in memory for the whole game, one material per model, recolouring is sliding a UV point,
and a colour fix is a one-pixel edit every model picks up.

### Layout

Six **surface sections**, each a full colour picker, stacked top to bottom:

| y (px) | Section | Meaning |
|---|---|---|
| 0 to 160 | **MATTE** | plain matte colour. **Almost everything in Top Dog uses this.** |
| 176 to 336 | **SATIN** | metal with a soft glint (iron, worn brass, the belt golds) |
| 352 to 512 | **POLISHED** | metal with a broad white glint and a white rim (chrome, mirror edges) |
| 528 to 688 | GLOW SOFT | emissive. **Banned in Top Dog** |
| 704 to 864 | GLOW NORMAL | emissive. **Banned in Top Dog** |
| 880 to 1040 | GLOW HOT | emissive. **Banned in Top Dog** |
| rows 33 to 38 (y 1056 to 1248) | **the named colours**: 364 matte cells of 32 px (`brass`, `oak`, `black_iron`...) | matte |
| rows 39 to 63 | free cells (mid grey) for colours added later | never point at these |

Inside each section: a 96-px picker block (64 hue columns of 32 px; saturation falls left to right,
brightness falls top to bottom), then four 16-px ramps (greys, warm neutrals, skin tones, metals). A 16-px
dark separator sits between sections; never use it. **The same spot in another section is the same colour on
another surface.**

The masks tell the shader what a texel is:
- `house_atlas_surface.png`: R = metallic (255), G = gloss (128 satin, 255 polished).
- `house_atlas_emit.png`: the glow colour and strength. Unused in Top Dog: `CelPass.NO_EMISSION = true`
  ignores it, along with any glTF emission.

`palette/house_atlas_map.json` lists every named cell: `col`, `row`, `uv` (centre), `srgb`, `rgb_linear`,
`family`, and the section layout. All tools and the GDScript helper read it.

### The laws

1. **One atlas, pixel for pixel.** Approved pixels never move or change. The size stays 2048, because UVs are
   fractions of the sheet. New colours go only into free cells.
2. **One material per model**, named `PALETTE`, with the atlas as its base-colour image (by relative uri).
   No other textures, no vertex colours, no emissive factors.
3. **One colour per face.** All of a face's UVs sit on one point, at least **3 px** inside a section or on a
   named cell's centre, never on a separator or a free cell.
4. **Named colours are coordinates.** `brass` is the `brass` cell every time. For a custom shade, use a spot
   in a section's picker block.
5. **No glow in Top Dog.** Never point a face at the GLOW sections.
6. **Sampling: nearest, no mipmaps, lossless.** The atlas imports lossless with mipmaps off (the committed
   `.import` files already do this). VRAM compression smears the cells and quietly breaks the look.
7. **Names carry the meaning.** The game finds parts by **object name** (`belt_face`, `letters_*`,
   `friend_join`...), never by material.

### The UV convention (where everyone trips)

The map's `uv` field is **bottom-up** (`u = x/2048`, `v = 1 - y/2048`), as Blender and Maya show it.
**glTF and Godot are top-down:** `v = y/2048`. A pixel's centre in a glTF file is
`u = (x + 0.5) / 2048`, `v = (y + 0.5) / 2048`. Hand-written UVs must do this flip.

## How a model is made (the house road)

**Models are programs, not hand-modelled files.** Each model is one Blender Python script,
`build_<stem>.py`, that builds it from an empty scene and exports the GLB. It can be re-run, diffed,
fixed in one line and rebuilt, and must be deterministic (two runs give identical bytes).

### The build contract

1. **One script per model**, headless:
   `blender -b --factory-startup --python-exit-code 1 --python build_<stem>.py -- OUT.glb`.
   It starts from `bpy.ops.wm.read_factory_settings(use_empty=True)`. It may import one shared helper
   module (the Top Dog Kit's is `tdk.py`).
2. **Geometry in code**: vertex lists, lofts, turned rings, boxes, built with `from_pydata`. **Flat
   shading** on every polygon. No subdivision, no live modifiers, no sculpting.
   - Facets: 8 sides for shafts and grips; 12 for small round forms; 16 for bigger circles.
   - Big round forms that get inked: keep each turn under 15 degrees (32-sided balls, 28-sided cones),
     or the ink draws every facet.
   - **Chamfers, not fillets.** One plane change catches a light step; a rounded fillet smears it.
3. **One colour per face**, by material index from a palette dict of linear RGB, with flat Principled
   materials and no images:
   - matte: metallic 0, roughness 0.5;
   - SATIN metal: metallic 1, roughness 0.5;
   - POLISHED metal: metallic 1, roughness under 0.25;
   - **no Emission** (the Top Dog Kit's helper fails the build if a colour asks for a glow).
4. **Exact object names**, as the parts list says. Nothing else in the file: no cameras, lights or stray empties.
5. **The frame:**
   - Metres; Y up in Godot. In Blender, author in file axes and map with `blender_xyz = (x, -z, y)`.
   - Export with `export_yup=True, export_apply=True`, so every node ends up identity.
   - **UI parts face +Z**: the front looks at the camera, and the origin sits where the parts list says
     (usually the part's centre, back at z 0).
6. **Under budget.** Props under 2,500 triangles, most under 1,200. The script asserts its own count.
7. **Export GLB** with no texcoords (the converter writes them), and no cameras, lights, animation or extras.

### Rounds, then the close

- **Rounds:**
  1. build;
  2. render review views (Workbench, flat colour, eight angles);
  3. score them against the bar below;
  4. fix the script;
  5. rebuild.

  Judge at a **3 m** read, not up close.
- **The review bar** scores six rows from 1 to 10:
  1. reads as the item from the silhouette;
  2. reads as its theme;
  3. a new silhouette, not a sibling's copy;
  4. reference quality;
  5. nothing floats or is buried;
  6. good colour use: broad masses, one hue per surface with a light and a dark step.

  A pass is every row at 7 or more and an average of 8. A fresh reviewer (a new LLM instance) scores each
  round.
- **The close** runs once, after a pass (`land.sh <stem>` in the Top Dog Kit):
  1. two fresh builds, byte-identical;
  2. the **applied-transforms gate** (`gate_transforms.py`: every node identity);
  3. **convert onto the atlas** (`to_atlas.py`): each flat material goes to its named cell if one matches
     within 2 sRGB levels, otherwise the nearest pixel of the right section (it fails over delta E 4.5).
     Every face collapses to that point, the primitives merge into one `PALETTE` material, and the uri is
     set to `../palette/house_atlas.png`;
  4. the **atlas gate** (`atlas_gate.py`: every UV obeys law 3);
  5. the **house checker** (`check_model.py`: budget, names, renders).

**Authoring straight onto the atlas** is also allowed: a script sets each face's `TEXCOORD_0` to a cell
centre from `house_atlas_map.json` (remember the v flip). The gates are the same either way.

### Colour craft

- **One hue per surface, in two steps:** a base, a light and a dark (for example oak, oak_light, oak_dark).
- **Broad masses first.** A mosaic of small colour faces reads as noise at 3 m.
- **Words and flat colour regions** on a single plate draw no ink between colours. Separate plates side by
  side do get ink between them.
- **Top Dog's look is lucha libre, cartoon and festive:**
  - colours: navy, red, gold (satin), turquoise, magenta, cream;
  - motifs: the pug mascot mask (`mask_lib.py` is the one shared mask), stars, papel picado, belts;
  - the plaza: swirl cartoon clouds, terracotta roofs, palms.

## Getting a model into the game

1. The finished `.glb` lands in the Top Dog Kit's `models\` folder, with its atlas uri set to `../palette/house_atlas.png`.
2. `python tools/sync_kit.py` (run from the repo root) copies every kit model into `res://kit/models/` and
   rewrites the uri to `../../palette/house_atlas.png`, so it resolves to the game's one atlas. Without the kit
   folder on your machine, put the GLB in `kit/models/` yourself with that uri.
3. Godot imports it. The game loads parts **by file name**: `LuchaKit.kit_model("friend_row")` loads
   `res://kit/models/friend_row.glb`, runs `CelPass.celify` on it, and falls back to a built stand-in if the
   file is missing.

### What `CelPass` does at run time

- `CelPass.celify(node)` swaps every opaque material for its cel-shaded twin. A `PALETTE` material is bound to
  the one shared atlas and its masks (a hundred models cost one texture). Emission is ignored
  (`NO_EMISSION`).
- `CelPass.add_outline_pass(root)` adds the ink: a compositor effect on the WorldEnvironment that reads the
  depth and normal buffers. It needs Forward+; headless runs and the Compatibility renderer get no ink.
- `CelPass.cel_material(color)` gives a cel material for meshes built in code.

### The words skip the ink (Parker, 11-07)

The ink reads only opaque depth and normals, so anything drawn in the transparent pass is never outlined:
- **UI words** are flat `Label3D` in the title font (`fonts/luckiest_guy/`), unshaded and alpha, with a
  drop-shadow copy behind (`LuchaKit.text3d` / `poster_text`). Extruded `TextMesh` isn't used: the font's
  overlapping outlines fill wrong ("ONLINE" read "ONUNE").
- **Letters modelled into a kit part** are objects named `letters_*`. `LuchaKit.letters_skip_ink` gives them an
  unshaded alpha material on the atlas, which takes them out of the ink.
- **Exception:** the **TOP DOG title logo keeps its ink**, letters included.

### The engine settings that make the look

- WorldEnvironment:
  - **glow off, fog off**;
  - **Linear tonemapping** (Golemheim's AgX drained the poster reds and golds);
  - a bright cartoon-blue procedural sky.
- Shader globals in `project.godot`: `diffuse_curve` (the banding ramp), `outline_width` 3.5 px at 1080
  lines, and `outline_color` black.
- **The cache trap:** after editing a shader include (`shaders/cel/includes/*`), change the rev comment in
  `cel-shader-base.gdshader`, or Godot's import cache keeps the old code.

## The climber's model (skins)

The default climber is **Defaultio**, `models/defaultio.glb` (`Game.KNIGHT`), with a plain white material. The Skeleton Knight and Metal Knight,
`models/skeleton_knight.glb` and `models/metal_knight.glb`, are kept. All three are split into **16 pieces with fixed mesh names** (the "Defaultio"
contract):

`Head`, `Chest`, `Navel`, `Pelvis`, `Shoulder`, `Wrist`, `Hand`, `L_Shoulder`, `L_Wrist`, `L_Hand`, `Thigh`,
`Shin`, `Foot`, `L_Thigh`, `L_Shin`, `L_Foot`.

- Each piece is one physics body (`climber/body_layout.gd` lists each with its shape and mass).
- Any skin built on those 16 names drops in piece by piece.
- **No colour wash:** every climber wears the model's own colours. Players will pick skins later; the player
  colour is only on name tags and cards.
- **A skin that embeds its own atlas** (the Skeleton Knight came with Golemheim's) can point at the shared one
  instead, if every colour it uses is pixel-identical there: set its image to the uri
  `../palette/house_atlas.png` and its sampler to nearest.
- The arm pieces render `shoulder_flare` further out and `shoulder_drop` lower than modelled
  (`Layout.shift()`). Model to the contract; the game applies the offset.

## Checklist for a new model

- [ ] One `build_<stem>.py`, deterministic, flat-shaded, named objects, under budget.
- [ ] Matte, satin or polished colours only. No glow.
- [ ] Metres, Y up, transforms applied, front +Z for UI parts, origin as specified.
- [ ] Reviewed in rounds at a 3 m read until it passes the six-row bar.
- [ ] Converted onto the atlas: one `PALETTE` material, UVs on texel centres 3 px inside, uri to the atlas.
- [ ] In `kit/models/`, loaded by file name, checked in a game frame (the cel shading and ink change how
      it reads).
