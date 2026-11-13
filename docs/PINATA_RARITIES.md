# Cosmetic pinata rarity previews

Five standalone variants: `game/cosmetic_pinata_white.tscn`, `_green.tscn`, `_blue.tscn`, `_purple.tscn`, `_red.tscn`. The base scene defaults to White. Set `rarity` before adding a scripted instance to the tree.

Order is White (common), Green, Blue, Purple, Red (rarest). All use the house atlas and a local additive rear-star glow. Green adds a gold inset; Blue adds tip jewels; Purple adds additional floating jewels; Red adds gold rays, paired leaf ornaments, and a second star contour. The front star remains orange. Opposed pulses and independent star rotation speeds remain unchanged.

These are preview collectibles only: no spawn policy, rewards, or rarity odds. Collection still occurs on player/prop overlap and plays the existing colored scraps and matching spark trails.

Run `tests/pinata_rarity_preview.tscn` for the five-variant ring comparison. This capture harness writes frames to the local Top dog 2 workspace. `tests/pinata_probe.tscn` checks collision, single trigger, matching tracer colors, and cleanup.
