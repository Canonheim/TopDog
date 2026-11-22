# The VS card (Parker, 2026-11-22)

Parker: "Each round, I want a 'VS' title card to come in from left and right of screen, connecting
at the middle. It will have the name of each of the climbers, and their steam name under it in
smaller font. The thing will be a 3d UI VS screen in our Top Dog style before each round that shows
the generated names of the fighters about to fight. The 2 halves will come in from the sides, slam
together, sit there for 2 seconds, then split and fly away into the background, and the round
starts. Design this and make it look good."

## The idea

A lucha fight poster torn down the middle. Each fighter owns one half; the two halves slam
together and the gold VS medallion at the join is only whole once they meet.

## The look

- **Two halves, one diagonal join.** Each half is a thick poster board about 5.6 wide and 3.0 tall
  (UI units; the 16:9 screen is 14.5 by 7.6). The inner edge of each is cut on the same slant
  (about 14 degrees off vertical, top leaning right), so the join reads as a lightning-bolt split,
  never a plain seam. Outer ends finish in the kit's banner swallowtail.
- **Corner colours.** Left half hot pink over red (the red corner), right half cyan over blue (the
  blue corner): the kit's two loudest pairs, as on the title logo's burst. A sunburst of slightly
  darker rays fans out from the join on each half, so both point at the middle.
- **Gold rope trim and star studs** round the rim, as on the belts and the results board. Satin
  gold, never polished (polished stripes in the game), and nothing emissive.
- **The name plaque.** On each half a cream plaque, 4.0 by 0.95, tilted 3 degrees toward the join,
  carries the fighter's generated name in the title font, ink letters. Under it an ink strip,
  3.2 by 0.42, carries the Steam name in cream, about half the size. Offline the strip is hidden
  (there is no Steam name), so it must be its own piece.
- **The VS medallion.** A gold starburst, 2.3 across, with a red disc and "VS" in fat cream
  letters with an ink edge. It is cut along the join: the V rides the left half, the S the right.
  Slammed shut it overhangs both halves top and bottom, like the level medallion on the XP belt.
- **A corner tab** on each half's top outer corner: a small cream tab for the round number
  ("ROUND 3"), the same tab the HUD uses (`bind_col_tab`'s look).

## The pieces (kit names)

| Piece | What | Origin |
|---|---|---|
| `vs_half_l` | the left board with its half medallion (the V), plaque and Steam strip | the middle of its inner (join) edge |
| `vs_half_r` | the right board (the S) | the middle of its inner edge |
| `vs_spark` | optional: a four-point spark for the slam (else `xp_burst_star` stands in) | its centre |

Inside each half, named nodes the game finds by name: `plaque` (the name's face), `steam_strip`
(hidden offline), `round_tab`, `medallion`. The game writes the words; the model carries none
except "V" and "S". +Z faces the camera; faces the game writes on are flat and proud by 0.02.

## The move

| Beat | Time | What |
|---|---|---|
| In | 0.35 s | Both halves fly in from off screen, speeding up (ease in), each tilted 6 degrees as if thrown. |
| Slam | 0.15 s | They meet: squash 6% along x and spring back, the tilt snaps flat, a ring of sparks from the medallion, the ring bell, and a short camera kick. |
| Hold | 2.0 s | Still. No sway. The medallion pulses once at the slam and rests. |
| Out | 1.3 s | The halves jump apart, then are LAUNCHED over the horizon (Parker: "launched over the horizon, not just shoot straight back"): thrown up and away in a high arc, tumbling end over end, coming down far off behind the skyline. The round starts as they go. |

Total 3.8 s. The match clock does not run and nobody can move until the card is gone.

## The rules

- Shown before every round in the round modes. With two fighters each half has one name.
  With more, the fighters are split between the halves in spawn order, full names stacked (up to three a
  side; the plaque's text shrinks to fit).
- Turn modes (one climber at a time) have no opponent: no card.
- Practice: no card.
- Every machine plays the card from one message from the host, so both players see the slam together.

## Stand-in

Until the kit pieces land the game builds the halves from kit boxes in the same colours, with the
same named faces, so the flow can be played and timed. The kit models drop in by name.
