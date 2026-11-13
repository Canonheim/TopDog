Saved before the deliberate-pry grappling change on 2026-11-12 (base build 0.3.100).
Original files are retained as .txt snapshots. No second executable was created.
To roll back ONLY this change from the repository root:
  git apply --reverse --check docs/regressions/grappling-before-deliberate-pry-2026-11-12/deliberate-pry.patch
  git apply --reverse docs/regressions/grappling-before-deliberate-pry-2026-11-12/deliberate-pry.patch
If the check fails after later edits, merge the patch manually; do not overwrite newer work with whole snapshots.
Bump the network version and rebuild the existing builds/TopDog.exe after rollback.
Tests: battery --prying --wrestling --grapple_stability. All passed before export.
New behavior: deliberate active-limb pressure on an incoming gripping arm/leg; 0.65 real seconds at full pressure, 0.5 progress decay/second, 1 real second same-limb/same-defender regrab block. Terrain/tower footing release unchanged.
