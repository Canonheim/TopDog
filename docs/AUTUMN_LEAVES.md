# Autumn Leaves effect

Effect ID: `autumn_leaves`; menu name: **Leaves**.

## Art and runtime

- 72 low-poly atlas leaves: maple, oak, oval and serrated silhouettes.
- 18 of each silhouette. Colors per screen third: 6 gold, 6 orange, 4 rusty red, 3 burgundy, 3 brown, 2 muted green.
- Three size classes, eight each per third. Twelve overlapping direction lanes, six height layers, bounded local RNG. Gameplay RNG remains untouched.
- Gently curled geometry, stems and two-sided veins; flutter/drift after launch. Resource-free per-frame transforms, no physics bodies, no shadows; cleanup by 3.15 seconds.
- 24 cached ArrayMeshes (four shapes by six colors), one surface each, one shared `CelPass.one()` material. Each activation uses 72 MeshInstance3D nodes/72 surfaces.
- Triangle counts including backfaces, veins and stems: maple 56, oak 64, oval 36, serrated 60. Total normal burst: **3,888 triangles**. Max per leaf: **64**.

## Preparation contract

`preload("res://ui3d/autumn_leaves.gd").prewarm()` builds the immutable mesh/material cache without creating scene nodes, emitting a hidden burst or changing RNG. Idempotent. `burst(camera)` also retains a defensive preparation fallback. The shared `lock_effect_preparation.gd` registry now includes Autumn's `prewarm` adapter; startup/early-request coordination belongs to that registry.

## Measurements and checks

RTX 2080 host, Godot 4.7.2; timings are CPU preparation/spawn wall time, not GPU frame time.

- Dedicated headless cold spawn: 15.155 ms, including 14.195 ms cache preparation.
- Dedicated headless prepared spawns: 0.906 / 0.947 / 1.113 ms.
- Real-game prepared spawns: 1.077 / 1.099 ms.
- Real-game early cold fallback: 9.120 ms, then 8.799 ms in final capture.
- `tests/autumn_leaves_probe.tscn`: PASS. Tests shape/color/size/lane/height quotas, <=100 triangles per leaf and <=10k burst triangles, one material, no physics/shadows, cache reuse, distinct profiles, global RNG isolation, cleanup, menu, saved/network selection, and actual successful match dispatch.
- Three actual game-rendered activations checked; final one repeated after a vein-facing correction (same geometry count and behavior).
- Headless shutdown reported two ObjectDB instances/one retained resource; final rendered capture also observed concurrent registry diagnostics for pending Math registration and an over-budget Bills prep step. These are recorded rather than treated as clean shutdowns.
- Remaining integration audit: early requests before background registry preparation finishes still take the defensive cold path. Registry owner/captain should review ordering/priority and prep-step budget before exporting.

## Review artifacts

- GIF: `C:/Users/growi/Documents/ChatGPT/Top dog 2/autumn-leaves-in-game.gif`
- Model gallery: `C:/Users/growi/Documents/ChatGPT/Top dog 2/autumn-preview/autumn-items.png`
- In-game contact sheet: `C:/Users/growi/Documents/ChatGPT/Top dog 2/autumn-preview/in-game-contact.png`
- Probe log: `C:/Users/growi/Documents/ChatGPT/Top dog 2/autumn-test.log`

No build/export, version bump, commit or push was performed for this effect.
