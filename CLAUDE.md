# Top Your Pals: rules for sessions

- **Read `docs/BOOK.md` first.** It holds every decision Parker made and the record.
- **No reference-game names** in files or commits. The game this is a spiritual
  successor to is "the reference game". Copy its mechanics only: never its art,
  names, characters, music, sounds, text, word lists or levels.
- **One Godot at a time.** Stopping a run means killing the whole process tree.
  Headless batteries always run with a timeout. A fresh checkout needs
  `--import` first.
- **Never `git push`** unless Parker asks. Never `git add -A` blindly; check
  `git status` first. Commit by path.
- **Physics is Jolt with every piece locked to the z = 0 plane.** Godot 2D
  physics was tried first and failed (see BOOK). Hinge motors drive the limbs.
- **THE LATE TRANSFORM LAW:** after moving a physics body, call
  `Climber.sync_server(body)` before making a joint to it.
- **Hinge signs are pinned** (`Climber.MOTOR_SIGN`, `LIMIT_FLIP`) by
  `--spike --part=signs`. If Godot or Jolt changes, rerun it first.
- **The host decides; owners simulate.** Never re-simulate a frozen body: build
  it from the broadcast pose. `Layout.ORDER` is the wire order: never reorder.
- **Steam:** app 480 with lobby tag `topdog` until our own app exists; the
  tag in `net.gd` and `lobby_logic.gd` must match. Bump `GAME_VERSION` every build.
- **Skins** follow the 16 Defaultio piece names; any skin on that contract drops in.
- Feel numbers live in `data/feel.gd` only (the F1 panel edits the same table).
- Give Parker full absolute paths. Downloads need his permission.
- Windows rebuilds overwrite builds/TopDog.exe in place. Keep one main Windows build in that folder. If the executable is locked, close it before retrying the same output path.
