# Pinata startup prewarm comparison

Measured 2026-11-22 using Godot 4.7.2, Vulkan Forward+, RTX 2080, approximately 60 FPS presentation (120 FPS cap). Six separate rendered processes, alternating startup prewarm on/off, three per condition. No other game process was running. Shader disk caches were retained. This is an isolated effect benchmark, not a full multiplayer match or a clean-driver-cache test.

Harness: tests/pinata_prewarm_performance.tscn; pass -- --no-steam --boot-warm for startup preparation, omit --boot-warm for spawn-time preparation. Both variants use the current optimized burst. Each waits 40 rendered frames after spawn and measures 150 frames after collection, including cleanup. Whole-frame wall time includes rendering/presentation; it is not GPU-only timing.

| Measurement | Prepare at first spawn | Prepare at startup |
|---|---:|---:|
| First-spawn construction | 114.7–115.3 ms | 1.19–1.27 ms |
| Worst frame around first spawn | 131.4–132.0 ms | 18.0–18.4 ms |
| Collection callback | 0.161–0.171 ms | 0.197–0.219 ms |
| Worst collection/effect frame | 18.48–18.72 ms | 18.46–18.64 ms |
| Collection 95th-percentile frame | 16.80–16.83 ms | 16.81–16.83 ms |
| New scene nodes during collection | 0 | 0 |

All three non-prewarmed runs had one spawn frame exceeding 25 ms; none of the prewarmed spawn frames or either variant's collection frames exceeded 25 ms. Startup preparation itself took 104–106 ms synchronously. Including script/resource loading, the worst startup frame was 295–300 ms with preparation versus 191–193 ms without. The work moves into startup; it is not eliminated. This benchmark does not establish that startup loading is visually masked in the full main scene.

Conclusion: startup prewarming removes the reproducible first-spawn hitch. It does not materially improve collection relative to the already-optimized spawn-prewarmed effect. Collection remains close to the normal 16.7 ms frame interval in both variants. No gameplay code changed for this measurement. Raw results: tests/pinata_prewarm_results.json.
