# Windows packaged-build checks

Run after exporting the single main executable:

```powershell
./tools/check_windows_build.ps1
./tools/check_windows_build.ps1 -Scene match -Seconds 12
```

The check launches the real renderer without Steam, captures the title or a local
demo session, and exits through Main.quit_game using the existing --shot hook.
It requires exit code 0, no runtime error messages, a fresh PNG, and the capture
completion marker. Each run keeps independent logs and screenshots under TEMP.
It refuses to run if TopDog is already open and only terminates its own process
on timeout. It does not grant XP or delete saves. The capture hook skips the
intro/press-any-button sequence; this is not a controller or online-session test.

Do not use --quit-after to judge exported Windows startup. It bypasses the game
shutdown routine and reproduces the documented Godot 4.7.2 release teardown
access violation (0xC0000005), after successful rendering. See BOOK.md, section
0.1.2. On 2026-11-18 the unchanged 0.3.132 executable rendered its title and
returned 0 through normal Quit, confirming earlier automated reports had
misclassified the engine shutdown failure as a launch failure.

Build 0.3.133 passed both packaged title and local demo checks with exit code 0,
valid screenshots, and no runtime error messages. This verifies rendering and
normal shutdown; it does not replace a full gameplay or multiplayer test.
