# The Peak's sound effects

Written by `tools/peak/make_peak_sfx.py` (run it to rebuild every file and this page;
edit the script, not this page). 140 files in `audio/sfx/peak/`, mono, 16-bit, 44.1 kHz,
all synthesised in numpy: nothing sampled, nothing downloaded. **Nobody has listened to
these yet.** They were built and checked by measurement and by reading spectrograms, so
treat the weak list below as where to start listening, not as the whole truth.

Levels: one-shots peak at -3 dBFS; loops and beds sit at -16 dBFS RMS (peaks held
under -1 dBFS by a soft ceiling). The game sets the mix. The **A dB** column is the
A-weighted RMS: a rough guide to how loud each file will seem beside the others at the
same gain (a thump and a squeak with the same peak are far apart). Use it for a first
pass at the gains.

Three more files in the folder are another worker's and are not listed here:
`peak_fall_wah.wav`, `peak_summit_fanfare.wav`, `peak_milestone.wav`.

## Checks

All passed on the last run: every one-shot reaches 1% of its peak within 5 ms (the
swells start at a low floor, not from silence) and its last samples are below -60 dBFS;
every loop's seam sits inside the file's own range. One-shots are trimmed where they
fall 70 dB under their peak, so some are shorter than the sound they describe.

**How the loops loop.** Each is built periodic over its own length (FFT-shaped noise,
whole numbers of cycles, events added modulo the length, circular echo and reverb), so
the last sample runs into the first with no crossfade, and each is rotated to start at
a gentle zero crossing. They only loop cleanly over the WHOLE file: see the warning at
the end of this section. The seam columns are measured from the written file, in
full-scale units (1.0 = 0 dBFS):

- **jump**: |first sample - last sample|, and the share of all sample-to-sample steps in
  the file that are no bigger. Under 100% means the seam's step is an ordinary one.
- **slope**: the change of slope across the seam (second difference), ranked the same way.
- **level**: RMS of the first 50 ms against the last 50 ms, ranked against the same
  measure taken all through the file.
- **wrap**: the same jump and slope ranks at the place where the generator's own period
  wraps. That place is inside the file now (the rotation moved it), so this is the test
  of the claim that the loops were built periodic. Ranks spread anywhere from 0 to 100%
  are what a point with nothing special about it gives. A click would be the largest step
  in the whole file: 100.0% on both.

With 24 loops, one or two wrap ranks above 95% are expected by chance. `amb_a6` drew the
highest (99.3%, 99.8%): about 3,700 steps and 1,000 changes of slope elsewhere in that
file are bigger, so it is not a click, but it is the one to listen to if any is. The proof
that the method is sound is the self-test below: each building block made 200 times, and
the step across its wrap ranked among its other steps. A wrap that is just another place
in the signal averages 50%, with about 1 in 100 above 99%. The control is noise filtered
without wrapping: what a loop that clicks looks like.

| Building block | Mean rank of the wrap step | Above 99% |
|---|---|---|
| shaped noise | 51.4% | 0.5% |
| noise under a slow curve | 50.0% | 0.5% |
| moving band (wind) | 50.1% | 0.0% |
| clicks through resonators | 47.2% | 1.5% |
| placed events, echo, reverb | 51.1% | 0.5% |
| fire | 49.9% | 3.0% |
| cloth | 48.8% | 1.0% |
| after the loop finisher | 50.9% | 0.0% |
| CONTROL: not periodic | 55.7% | 3.0% |

**The beds repeat every 12 s.** Their one-off events (the bird, the far cry, the thunder
roll, the groans) are kept quiet for that reason. If a bed's repeat is noticed, lower
the bed and let the game fire the matching one-shots at random instead.

**WARNING, the loop length in the game (found 2026-11-12 by reading, not by running).**
`PeakAudio._looped()` in `stages/peak/peak_audio.gd` sets
`loop_end = w.data.size() / (bytes * channels)`, which is the frame count only for
uncompressed PCM. The `.wav.import` files beside these sounds say `compress/mode=2` (QOA),
and the imported samples are about 0.4 bytes a frame (`amb_a0`: 214,555 bytes for 529,200
frames). So as written every bed and loop would restart about 40% of the way in (a 12 s
bed at about 4.9 s, `fall_wind_loop` at about 1.2 s), at a place that is not a seam: a
click each time round, and most of each bed never heard. Any one of these fixes it:
`w.loop_end = int(round(w.get_length() * w.mix_rate))` in `_looped()`; or
`edit/loop_mode=2` in the loops' import settings and no override in code; or
`compress/mode=0` for the loops. I did not change the code or the import files (not mine).

## What is probably weak (replace these first)

In the order I would replace them. This is judgement from how each was made and how it
measures, not from hearing it.

1. **`vulture_cry_01/02` and the bird in `amb_a7`.** A voice is the hardest thing to fake. The vulture is a sawtooth through three formants with a rasp, and will likely read as a kazoo or a goose; the far bird of prey is one falling tone. A recorded or performed cry would beat both.
2. **The far fiesta in `amb_a0`.** Seven pulse-train voices through formants, low-passed and put in a room. It measures as a murmur (about 5 dB under the breeze) but may come across as a muffled buzz, not people. The bird in the same bed is plain sine chirps.
3. **Every creak: `plank_creak`, `rope_creak`, `vine_creak`, `wheel_creak_loop`, and the creaks inside `amb_a1` and `amb_a8`.** They are stick-slip click trains through resonators. The spectrograms show the ticks running together into a groan, as intended, but this method can read as a ratchet or a purr. `plank_creak` matters most: it is the warning before a plank snaps.
4. **`thunder_01/02/03` and the roll in `amb_a10`.** Filtered noise under a run of bumps. Fine far away; the near one (01) has no real crack or depth. `thunder_03` is nearly all under 200 Hz and will vanish on small speakers.
5. **The water: `waterfall_loop`, `river_loop`, `water_paddle`, `amb_a2`.** Shaped noise with sine bubbles on top. Noise water tends to read as hiss without the fine detail of the real thing. `waterfall_loop` has to carry a 113 m fall and is the one to replace first.
6. **`cart_brake` and `pulley_squeak_01/02`.** Nearly pure squeal tones around 1 to 1.5 kHz. They are cartoonish on purpose, but they are also the loudest files by the A column (the pulley is about 10 dB hotter than most one-shots at the same gain): turn them down, and replace them if they grate.
7. **The deep hits: `stone_drum_01/02`, `stone_slam`, `gate_slam`, `land_thud_big`, `summit_bell`.** At -3 dBFS peak they are mostly below 200 Hz, so there is no headroom left to make them heard on small speakers. I added skin, slap and upper partials to each, but check them on laptop speakers. `stone_drum` is the worst case (A about -33 dB).
8. **`stone_grind_loop`, `boulder_roll_loop`, `avalanche_loop`.** Noise through low resonators with thumps. They measure as steady rumble with little of the grit and weight of the real thing.
9. **`lightning_zap`, `lightning_hum`, `zip_whirr`.** Harmonic buzzes and a moving noise band. They will sound synthesised. That may suit the cartoon; it will not sound like a recording.
10. **`crystal_shatter` and `ice_shatter`.** A burst and a scatter of pings. May read as wind chimes falling over, not as something breaking.
11. **`flag_flutter_loop`, `kite_whip`, the cloth in `amb_a11`.** Flaps made of short noise bursts. Plausible on the spectrogram; cloth is easy to get wrong.
12. **The beds repeat every 12 s.** Each has a few one-off events (drips, pings, a cry, a roll, two groans). They are kept low, but an hour in one place will show the pattern. `amb_a5`'s far thump every 6 s is not in time with the music (96 bpm): if it fights the drums of the A5 loop, cut it from the bed.

## What should be sound

- The pitched and struck sounds, where synthesis is at home: `crystal_chime_01..08` (the rising scale), `new_best_chime`, `summit_bell`, `mushroom_boing`, `drip`, `knock_out_bonk`, `hammer_clang`, `cable_twang`, `bounce_rope`, `chain_rattle`, `cart_clack`, `lever_clunk`.
- The wind family: `wind_gust`, `wind_warn`, `fall_wind_loop` and the wind in beds A7 to A11. Resonant noise with a moving centre is how wind is usually made.
- The hisses and fires: `steam_loop`, `steam_hiss`, `sizzle`, `torch_loop`, `dust_trickle`, `spore_puff`, `geyser_warn`.

## Tuning

- The climb's music is in D. Pitched effects were tuned to sit in it: `crystal_chime` is the asked-for scale (D5 E5 F#5 A5 B5 D6 E6 F#6); `new_best_chime` is A5 to D6; `summit_bell` is on D3 with a major-third tierce (F#, where a church bell has a minor third) so it agrees with the summit's D major; `stone_drum` is D2 and A1; `cable_twang` D2 and A1; `bounce_rope` E2 and A2; `mushroom_boing` G2, D3, A3; the pings in `amb_a3` are A6 D7 F#6 B6 E6 over a faint D/A drone.
- `amb_a8`'s electrical hum is 55 Hz and its harmonics (an A), not 50 or 60 Hz, so it does not beat against the music. `gondola_hum_loop` is on 73.3 Hz (a D, two cents flat, so a whole number of cycles fits the loop).
- `fall_wind_loop` has no pitch and no events, so the game can pitch it with fall speed.

## Ambience beds

| File | Length s | Peak dBFS | RMS dBFS | A dB | Seam jump | Seam slope | Seam level dB | Wrap jump, slope | How it was made |
|---|---|---|---|---|---|---|---|---|---|
| `amb_a0.wav` | 12.00 | -2.0 | -16.0 | -18.2 | 0.00635 (14%) | 0.01520 (29%) | -0.0 (1%) | 72.1%, 78.3% | wind band over a low body; a far crowd (pulse-train voices through formants, low-passed, in a room); one bird, two short phrases |
| `amb_a1.wav` | 12.00 | -3.1 | -16.0 | -26.4 | 0.00012 (1%) | 0.00098 (9%) | +0.3 (10%) | 16.5%, 65.5% | narrow noise bands at 58 to 311 Hz for the hollow drone; five drips with a 0.31 s echo; two stick-slip timber creaks; long room |
| `amb_a2.wav` | 12.00 | -2.9 | -16.0 | -20.5 | 0.00830 (19%) | 0.00781 (16%) | -0.1 (5%) | 50.1%, 76.4% | pink roar 90 Hz to 5 kHz, a wandering mid band, 80 bubbles, four drips, cave room |
| `amb_a3.wav` | 12.00 | -2.4 | -16.0 | -19.5 | 0.00397 (13%) | 0.00241 (14%) | -0.1 (12%) | 74.1%, 32.5% | 26 faint high sines twinkling on whole-cycle envelopes, a soft D/A glass drone, five glass pings (A6 D7 F#6 B6 E6) in a long room |
| `amb_a4.wav` | 12.00 | -2.5 | -16.0 | -22.1 | 0.00284 (15%) | 0.00446 (36%) | +0.1 (8%) | 38.4%, 86.8% | Poisson clicks through 2.6 to 4.8 kHz resonators (fizz), six rising-sine plops, three pulsed insect chirrs, low room tone |
| `amb_a5.wav` | 12.00 | -2.0 | -16.0 | -27.0 | 0.00064 (7%) | 0.00037 (6%) | +0.2 (8%) | 60.6%, 58.9% | low noise with bands at 62, 98 and 163 Hz, a torch (flutter and crackle), a soft far thump every 6 s in a 3 s room |
| `amb_a6.wav` | 12.00 | -3.0 | -16.0 | -20.3 | 0.00891 (13%) | 0.01675 (18%) | +0.5 (22%) | 99.3%, 99.8% | hiss 1.4 to 6 kHz, rumble, a boiling sputter, about 14 metal ticks (short modal pings) at uneven gaps |
| `amb_a7.wav` | 12.00 | -1.1 | -16.0 | -18.9 | 0.00079 (2%) | 0.00446 (11%) | +0.4 (34%) | 85.3%, 70.6% | gusting wind band 250 to 700 Hz with a higher whistle on the gusts; one falling bird-of-prey cry with an echo |
| `amb_a8.wav` | 12.00 | -1.8 | -16.0 | -21.8 | 0.00107 (4%) | 0.00571 (18%) | -0.1 (8%) | 12.2%, 60.2% | wind, a 55 Hz hum with harmonics (an A under the climb's D), a faint cable whistle, two metal stick-slip creaks |
| `amb_a9.wav` | 12.00 | -1.2 | -16.0 | -16.7 | 0.01630 (35%) | 0.00830 (17%) | -0.0 (5%) | 83.1%, 84.2% | thin wind band 800 to 1700 Hz with spindrift hiss, two slow stick-slip ice groans over a low sine, four small cracks with echo |
| `amb_a10.wav` | 12.00 | -2.2 | -16.0 | -19.7 | 0.00259 (5%) | 0.00616 (9%) | -0.1 (8%) | 64.8%, 43.0% | hard gusting wind with a howl, rain (hiss plus Poisson drops), one far thunder roll that swells in |
| `amb_a11.wav` | 12.00 | -2.7 | -16.0 | -17.0 | 0.00281 (6%) | 0.00836 (17%) | +0.1 (10%) | 5.9%, 64.9% | gentle high wind band 600 to 1300 Hz, cloth flaps that follow the gusts |

## Loops

| File | Length s | Peak dBFS | RMS dBFS | A dB | Seam jump | Seam slope | Seam level dB | Wrap jump, slope | How it was made |
|---|---|---|---|---|---|---|---|---|---|
| `cart_roll_loop.wav` | 3.00 | -2.4 | -16.0 | -22.9 | 0.00171 (9%) | 0.00223 (24%) | +0.5 (22%) | 97.1%, 93.1% | low rumble, noise through iron resonators, grit, a wheel flat ticking five to the second |
| `waterfall_loop.wav` | 4.00 | -3.5 | -16.0 | -18.5 | 0.01233 (15%) | 0.01703 (17%) | +0.1 (9%) | 39.0%, 26.4% | pink noise 60 Hz to 6.5 kHz with a sub layer, a churning mid band and spray |
| `river_loop.wav` | 4.00 | -2.9 | -16.0 | -17.6 | 0.01068 (16%) | 0.00497 (7%) | -0.3 (26%) | 19.5%, 55.7% | band noise with a wandering resonance and 110 bubbles |
| `wheel_creak_loop.wav` | 4.00 | -2.8 | -16.0 | -23.1 | 0.00174 (22%) | 0.00024 (24%) | -0.9 (48%) | 24.1%, 33.2% | axle rumble, two long stick-slip creaks through wood resonators, four wooden knocks, one a second |
| `gondola_hum_loop.wav` | 3.00 | -5.2 | -16.0 | -24.7 | 0.00052 (5%) | 0.00180 (57%) | +0.1 (15%) | 58.7%, 87.6% | harmonics of 73.3 Hz (a D), sheave noise pulsing at 7 Hz with a tick on each |
| `fall_wind_loop.wav` | 3.00 | -3.8 | -16.0 | -17.9 | 0.00061 (1%) | 0.00775 (12%) | -0.1 (9%) | 80.6%, 95.5% | plain band noise 180 Hz to 2.6 kHz with a light buffet: no events, made to be pitched |
| `steam_loop.wav` | 3.00 | -2.7 | -16.0 | -16.6 | 0.00470 (4%) | 0.02091 (13%) | -0.3 (38%) | 32.8%, 73.6% | hiss 1.2 to 6 kHz, a low sputter, a little sub |
| `torch_loop.wav` | 3.00 | -1.5 | -16.0 | -20.7 | 0.00064 (2%) | 0.00430 (19%) | +1.0 (23%) | 32.3%, 54.7% | low flutter, a soft roar, sparse crackles |
| `stone_grind_loop.wav` | 3.00 | -3.1 | -16.0 | -18.3 | 0.00180 (9%) | 0.00278 (36%) | +0.3 (20%) | 97.3%, 89.6% | dense Poisson clicks through low stone resonators, with rumble and grit |
| `flag_flutter_loop.wav` | 2.50 | -3.0 | -16.0 | -18.9 | 0.00699 (20%) | 0.00958 (27%) | -0.4 (7%) | 11.8%, 26.4% | soft flaps (noise and a short low thump) at about 9 a second, with a ripple |
| `boulder_roll_loop.wav` | 3.00 | -2.8 | -16.0 | -27.2 | 0.00244 (40%) | 0.00027 (38%) | -0.7 (22%) | 53.5%, 63.1% | rumble, seven uneven thumps, gravel crunch after each |
| `avalanche_loop.wav` | 4.00 | -3.5 | -16.0 | -22.6 | 0.00543 (18%) | 0.00531 (17%) | -0.2 (13%) | 11.3%, 85.1% | deep rumble, a snow wash, a moving low band, nine low thumps |

## One-shots

| File | Length s | Peak dBFS | RMS dBFS | A dB | Starts ms | How it was made |
|---|---|---|---|---|---|---|
| `cart_start.wav` | 1.50 | -3.0 | -20.1 | -27.3 | 0.1 | a clunk, a short wood creak, then rumble and wheel ticks picking up |
| `cart_clack_01.wav` | 0.20 | -3.0 | -25.7 | -26.9 | 0.0 | two iron impacts a few hundredths apart: thump, click, three ringing modes |
| `cart_clack_02.wav` | 0.22 | -3.0 | -24.8 | -26.6 | 0.0 | two iron impacts a few hundredths apart: thump, click, three ringing modes |
| `cart_clack_03.wav` | 0.19 | -3.0 | -24.0 | -25.2 | 0.0 | two iron impacts a few hundredths apart: thump, click, three ringing modes |
| `cart_brake.wav` | 1.40 | -3.0 | -21.6 | -22.8 | 0.3 | a falling squeal (1450 to 680 Hz, rough-edged) over scrape noise |
| `cart_crash.wav` | 1.70 | -3.0 | -24.1 | -30.9 | 0.0 | a big impact with iron modes, nine timber cracks, fourteen falling bits, short room |
| `lever_clunk.wav` | 0.26 | -3.0 | -22.1 | -28.9 | 0.1 | a click, a low iron thunk, and the latch 85 ms later |
| `plank_creak_01.wav` | 0.60 | -3.0 | -17.2 | -18.7 | 0.1 | stick-slip ticks that speed up into a rising groan (the strain) through wood resonators |
| `plank_creak_02.wav` | 0.85 | -3.0 | -17.8 | -19.9 | 0.1 | stick-slip ticks that speed up into a rising groan (the strain) through wood resonators |
| `plank_creak_03.wav` | 0.70 | -3.0 | -17.3 | -18.4 | 0.4 | stick-slip ticks that speed up into a rising groan (the strain) through wood resonators |
| `plank_snap_01.wav` | 0.29 | -3.0 | -24.8 | -30.5 | 0.0 | a crack, a low thump, wood modes, then splinters and a clatter |
| `plank_snap_02.wav` | 0.32 | -3.0 | -24.5 | -30.6 | 0.1 | a crack, a low thump, wood modes, then splinters and a clatter |
| `plank_snap_03.wav` | 0.29 | -3.0 | -23.9 | -28.6 | 0.0 | a crack, a low thump, wood modes, then splinters and a clatter |
| `rock_crumble_01.wav` | 0.95 | -3.0 | -20.9 | -28.2 | 0.1 | a first hit, then 45 to 100 small rock grains thinning out, over a rumble |
| `rock_crumble_02.wav` | 1.25 | -3.0 | -23.8 | -30.4 | 0.1 | a first hit, then 45 to 100 small rock grains thinning out, over a rumble |
| `rock_crumble_03.wav` | 1.55 | -3.0 | -23.1 | -29.8 | 0.0 | a first hit, then 45 to 100 small rock grains thinning out, over a rumble |
| `rock_hit_01.wav` | 0.35 | -3.0 | -22.4 | -29.2 | 0.0 | a low thump, a band of noise, three short modes: a tock |
| `rock_hit_02.wav` | 0.27 | -3.0 | -23.1 | -28.1 | 0.0 | a low thump, a band of noise, three short modes: a tock |
| `rock_hit_03.wav` | 0.42 | -3.0 | -22.5 | -30.2 | 0.0 | a low thump, a band of noise, three short modes: a tock |
| `dust_trickle_01.wav` | 1.30 | -3.0 | -23.5 | -22.7 | 0.1 | dense Poisson clicks from 1.5 to 5 kHz (sand) with a few pebble ticks |
| `dust_trickle_02.wav` | 1.70 | -3.0 | -25.0 | -24.3 | 0.1 | dense Poisson clicks from 1.5 to 5 kHz (sand) with a few pebble ticks |
| `rope_creak_01.wav` | 0.70 | -3.0 | -22.9 | -23.3 | 0.2 | stick-slip train through fibre resonators (560 Hz to 2.6 kHz) |
| `rope_creak_02.wav` | 0.90 | -3.0 | -23.5 | -24.1 | 0.3 | stick-slip train through fibre resonators (560 Hz to 2.6 kHz) |
| `rope_creak_03.wav` | 0.55 | -3.0 | -23.1 | -23.1 | 0.2 | stick-slip train through fibre resonators (560 Hz to 2.6 kHz) |
| `chain_rattle_01.wav` | 0.42 | -3.0 | -21.9 | -20.9 | 0.0 | 8 to 16 clinks, each four inharmonic modes and a click, thinning out |
| `chain_rattle_02.wav` | 0.72 | -3.0 | -23.3 | -22.7 | 0.0 | 8 to 16 clinks, each four inharmonic modes and a click, thinning out |
| `chain_rattle_03.wav` | 0.43 | -3.0 | -23.3 | -22.3 | 0.0 | 8 to 16 clinks, each four inharmonic modes and a click, thinning out |
| `gate_slam_01.wav` | 1.10 | -3.0 | -18.7 | -28.3 | 0.1 | a deep thump, wood and iron noise, a few rattles, tunnel room |
| `gate_slam_02.wav` | 1.25 | -3.0 | -18.6 | -29.3 | 0.0 | a deep thump, wood and iron noise, a few rattles, tunnel room |
| `water_paddle_01.wav` | 0.55 | -3.0 | -17.8 | -18.5 | 0.1 | a swoosh of moving band noise, an entry plip, 11 to 20 bubbles |
| `water_paddle_02.wav` | 0.70 | -3.0 | -18.4 | -19.5 | 0.1 | a swoosh of moving band noise, an entry plip, 11 to 20 bubbles |
| `water_paddle_03.wav` | 0.50 | -3.0 | -19.0 | -19.2 | 0.2 | a swoosh of moving band noise, an entry plip, 11 to 20 bubbles |
| `drip_01.wav` | 0.32 | -3.0 | -19.1 | -18.4 | 0.1 | a sine that jumps up in pitch, with two small echoes |
| `drip_02.wav` | 0.38 | -3.0 | -19.0 | -18.9 | 0.1 | a sine that jumps up in pitch, with two small echoes |
| `drip_03.wav` | 0.28 | -3.0 | -19.7 | -18.7 | 0.1 | a sine that jumps up in pitch, with two small echoes |
| `crystal_chime_01.wav` | 1.35 | -3.0 | -20.8 | -22.9 | 0.1 | glass-bar partials (1, 2.76, 5.40), a faint octave and a detuned twin: D5 E5 F#5 A5 B5 D6 E6 F#6 |
| `crystal_chime_02.wav` | 1.35 | -3.0 | -21.0 | -22.5 | 0.1 | glass-bar partials (1, 2.76, 5.40), a faint octave and a detuned twin: D5 E5 F#5 A5 B5 D6 E6 F#6 |
| `crystal_chime_03.wav` | 1.35 | -3.0 | -21.3 | -22.3 | 0.1 | glass-bar partials (1, 2.76, 5.40), a faint octave and a detuned twin: D5 E5 F#5 A5 B5 D6 E6 F#6 |
| `crystal_chime_04.wav` | 1.35 | -3.0 | -21.4 | -21.8 | 0.1 | glass-bar partials (1, 2.76, 5.40), a faint octave and a detuned twin: D5 E5 F#5 A5 B5 D6 E6 F#6 |
| `crystal_chime_05.wav` | 1.35 | -3.0 | -20.9 | -20.9 | 0.1 | glass-bar partials (1, 2.76, 5.40), a faint octave and a detuned twin: D5 E5 F#5 A5 B5 D6 E6 F#6 |
| `crystal_chime_06.wav` | 1.35 | -3.0 | -21.4 | -21.0 | 0.1 | glass-bar partials (1, 2.76, 5.40), a faint octave and a detuned twin: D5 E5 F#5 A5 B5 D6 E6 F#6 |
| `crystal_chime_07.wav` | 1.35 | -3.0 | -21.8 | -21.1 | 0.1 | glass-bar partials (1, 2.76, 5.40), a faint octave and a detuned twin: D5 E5 F#5 A5 B5 D6 E6 F#6 |
| `crystal_chime_08.wav` | 1.35 | -3.0 | -21.7 | -20.8 | 0.1 | glass-bar partials (1, 2.76, 5.40), a faint octave and a detuned twin: D5 E5 F#5 A5 B5 D6 E6 F#6 |
| `crystal_shatter_01.wav` | 0.70 | -3.0 | -21.7 | -20.7 | 0.1 | a bright burst and a crunch, then 24 to 40 glass pings thinning out |
| `crystal_shatter_02.wav` | 0.86 | -3.0 | -20.4 | -19.4 | 0.1 | a bright burst and a crunch, then 24 to 40 glass pings thinning out |
| `crystal_shatter_03.wav` | 0.73 | -3.0 | -21.8 | -20.8 | 0.1 | a bright burst and a crunch, then 24 to 40 glass pings thinning out |
| `mushroom_boing_01.wav` | 0.60 | -3.0 | -12.8 | -25.8 | 0.1 | a three-harmonic tone that drops onto its note, wobbles and rises (G2, D3, A3), over a soft thump |
| `mushroom_boing_02.wav` | 0.52 | -3.0 | -12.8 | -22.1 | 0.1 | a three-harmonic tone that drops onto its note, wobbles and rises (G2, D3, A3), over a soft thump |
| `mushroom_boing_03.wav` | 0.45 | -3.0 | -12.9 | -19.2 | 0.1 | a three-harmonic tone that drops onto its note, wobbles and rises (G2, D3, A3), over a soft thump |
| `spore_puff_01.wav` | 0.50 | -3.0 | -22.6 | -23.0 | 0.2 | band noise falling from 2.4 kHz to 500 Hz, a soft low pf, a little fizz |
| `spore_puff_02.wav` | 0.68 | -3.0 | -23.2 | -23.7 | 0.4 | band noise falling from 2.4 kHz to 500 Hz, a soft low pf, a little fizz |
| `puffball_pop_01.wav` | 0.26 | -3.0 | -18.0 | -21.3 | 0.1 | a fast falling sine (the pop) and a breath of noise after |
| `puffball_pop_02.wav` | 0.30 | -3.0 | -19.6 | -21.9 | 0.1 | a fast falling sine (the pop) and a breath of noise after |
| `vine_creak_01.wav` | 0.80 | -3.0 | -19.5 | -21.7 | 0.1 | slow stick-slip through low green resonators with a faint wet squeak |
| `vine_creak_02.wav` | 0.60 | -3.0 | -18.2 | -19.8 | 0.1 | slow stick-slip through low green resonators with a faint wet squeak |
| `stone_slam_01.wav` | 1.30 | -3.0 | -19.2 | -27.9 | 0.1 | a 55 Hz thump, a crack, grit through stone resonators, temple room |
| `stone_slam_02.wav` | 1.50 | -3.0 | -20.3 | -28.0 | 0.1 | a 55 Hz thump, a crack, grit through stone resonators, temple room |
| `stone_drum_01.wav` | 1.60 | -3.0 | -18.0 | -32.5 | 0.1 | seven drum-head modes with a pitch drop at the strike (D2, A1), a beater thud, a room |
| `stone_drum_02.wav` | 1.67 | -3.0 | -20.5 | -34.9 | 0.1 | seven drum-head modes with a pitch drop at the strike (D2, A1), a beater thud, a room |
| `steam_hiss_01.wav` | 0.80 | -3.0 | -21.4 | -21.2 | 0.3 | hiss 1.2 to 6 kHz with a fast attack and a falling whistle band |
| `steam_hiss_02.wav` | 1.30 | -3.0 | -20.4 | -20.2 | 0.1 | hiss 1.2 to 6 kHz with a fast attack and a falling whistle band |
| `geyser_warn.wav` | 1.00 | -3.0 | -17.8 | -22.1 | 0.1 | bubbles coming faster and higher (140 to 660 Hz) over a growing rumble |
| `geyser_burst_01.wav` | 1.60 | -3.0 | -22.0 | -22.8 | 0.3 | a low thump, a roar of band noise that opens then falls, spray, patter |
| `geyser_burst_02.wav` | 2.00 | -3.0 | -21.5 | -22.4 | 0.3 | a low thump, a roar of band noise that opens then falls, spray, patter |
| `sizzle_01.wav` | 0.70 | -3.0 | -23.2 | -22.7 | 0.5 | high noise under a crackle envelope, dying |
| `sizzle_02.wav` | 1.00 | -3.0 | -27.8 | -27.2 | 0.5 | high noise under a crackle envelope, dying |
| `hammer_clang_01.wav` | 0.94 | -3.0 | -22.9 | -24.0 | 0.2 | six inharmonic anvil modes in beating pairs, a click and a thump |
| `hammer_clang_02.wav` | 1.15 | -3.0 | -23.2 | -25.7 | 0.2 | six inharmonic anvil modes in beating pairs, a click and a thump |
| `bellows_whoosh_01.wav` | 0.90 | -3.0 | -18.8 | -20.2 | 0.0 | a breath of band noise that opens and closes, with a little leather creak |
| `bellows_whoosh_02.wav` | 1.15 | -3.0 | -18.3 | -20.3 | 0.1 | a breath of band noise that opens and closes, with a little leather creak |
| `wind_gust_01.wav` | 2.00 | -3.0 | -20.1 | -22.7 | 0.1 | wind band whose centre and level swell and fall over 2 s |
| `wind_gust_02.wav` | 2.00 | -3.0 | -19.0 | -20.8 | 0.1 | wind band whose centre and level swell and fall over 2 s |
| `wind_gust_03.wav` | 2.00 | -3.0 | -18.2 | -21.4 | 0.1 | wind band whose centre and level swell and fall over 2 s |
| `wind_warn.wav` | 0.80 | -3.0 | -17.8 | -17.9 | 0.2 | a narrow band of noise over a sine core, rising 480 to 1350 Hz and growing |
| `vulture_cry_01.wav` | 0.70 | -3.0 | -16.9 | -17.0 | 0.1 | a falling sawtooth voice through formants with a 68 Hz rasp |
| `vulture_cry_02.wav` | 0.95 | -3.0 | -17.8 | -17.9 | 0.1 | a falling sawtooth voice through formants with a 68 Hz rasp |
| `kick_thwack.wav` | 0.30 | -3.0 | -17.8 | -24.7 | 0.1 | a low thump, a slap of noise, a quick falling chirp |
| `branch_snap_01.wav` | 0.17 | -3.0 | -22.6 | -24.7 | 0.0 | a dry crack with three short wood modes and a second small crack |
| `branch_snap_02.wav` | 0.16 | -3.0 | -24.9 | -26.2 | 0.0 | a dry crack with three short wood modes and a second small crack |
| `cable_twang_01.wav` | 1.48 | -3.0 | -26.3 | -26.9 | 0.0 | Karplus-Strong string (D2, A1) losing its top, with a falling chirp at the front, as a struck wire has |
| `cable_twang_02.wav` | 1.78 | -3.0 | -25.7 | -26.2 | 0.0 | Karplus-Strong string (D2, A1) losing its top, with a falling chirp at the front, as a struck wire has |
| `pulley_squeak_01.wav` | 0.48 | -3.0 | -14.0 | -13.3 | 0.7 | a rough squeal tone: two rising chirps, or one that wobbles |
| `pulley_squeak_02.wav` | 0.60 | -3.0 | -14.0 | -13.4 | 0.9 | a rough squeal tone: two rising chirps, or one that wobbles |
| `gondola_clunk_01.wav` | 0.44 | -3.0 | -24.3 | -34.0 | 0.1 | a low thump, four hollow box modes, a latch click |
| `gondola_clunk_02.wav` | 0.44 | -3.0 | -23.8 | -34.5 | 0.1 | a low thump, four hollow box modes, a latch click |
| `zip_whirr.wav` | 2.00 | -3.0 | -15.9 | -16.3 | 0.2 | a narrow noise band and a buzz that climb for half a second then fall away |
| `ice_tick_01.wav` | 0.05 | -3.0 | -22.2 | -20.9 | 0.0 | a tiny click and a 2 to 3 kHz ping, 30 ms long (the third is a double) |
| `ice_tick_02.wav` | 0.05 | -3.0 | -21.0 | -19.8 | 0.0 | a tiny click and a 2 to 3 kHz ping, 30 ms long (the third is a double) |
| `ice_tick_03.wav` | 0.10 | -3.0 | -23.2 | -22.0 | 0.0 | a tiny click and a 2 to 3 kHz ping, 30 ms long (the third is a double) |
| `ice_crack_01.wav` | 0.42 | -3.0 | -26.2 | -30.8 | 0.0 | a crack that runs on with a short echo, a low thump, a little falling zing |
| `ice_crack_02.wav` | 0.42 | -3.0 | -24.1 | -29.4 | 0.0 | a crack that runs on with a short echo, a low thump, a little falling zing |
| `ice_crack_03.wav` | 0.40 | -3.0 | -23.7 | -27.8 | 0.0 | a crack that runs on with a short echo, a low thump, a little falling zing |
| `ice_shatter_01.wav` | 0.76 | -3.0 | -25.4 | -26.5 | 0.0 | a crunch, then 26 to 36 short dull pings |
| `ice_shatter_02.wav` | 0.92 | -3.0 | -24.2 | -25.1 | 0.0 | a crunch, then 26 to 36 short dull pings |
| `snow_whump_01.wav` | 0.70 | -3.0 | -21.3 | -28.3 | 0.4 | a soft low thump and a muffled puff of low noise |
| `snow_whump_02.wav` | 0.85 | -3.0 | -22.6 | -29.6 | 0.2 | a soft low thump and a muffled puff of low noise |
| `icicle_drop_01.wav` | 0.34 | -3.0 | -24.5 | -24.5 | 0.0 | a glass tick, a small crunch, 7 to 10 shards |
| `icicle_drop_02.wav` | 0.42 | -3.0 | -28.0 | -28.1 | 0.0 | a glass tick, a small crunch, 7 to 10 shards |
| `thunder_01.wav` | 3.30 | -3.0 | -21.6 | -27.9 | 0.1 | low noise under a run of bumps: 01 near with a crack, 02 rolling, 03 far |
| `thunder_02.wav` | 4.20 | -3.0 | -20.3 | -28.9 | 0.2 | low noise under a run of bumps: 01 near with a crack, 02 rolling, 03 far |
| `thunder_03.wav` | 4.98 | -3.0 | -24.5 | -34.3 | 0.6 | low noise under a run of bumps: 01 near with a crack, 02 rolling, 03 far |
| `lightning_hum.wav` | 1.50 | -3.0 | -15.2 | -21.3 | 0.1 | a buzz of 16 harmonics rising 70 to 210 Hz and brightening, with growing crackle |
| `lightning_zap_01.wav` | 0.50 | -3.0 | -23.8 | -23.4 | 0.0 | a bright burst, a stuttering 100 Hz buzz, dying crackle |
| `lightning_zap_02.wav` | 0.62 | -3.0 | -23.8 | -23.5 | 0.0 | a bright burst, a stuttering 100 Hz buzz, dying crackle |
| `kite_whip_01.wav` | 0.35 | -3.0 | -20.0 | -20.4 | 0.1 | a rising whoosh into a snap, then three small flaps |
| `kite_whip_02.wav` | 0.42 | -3.0 | -20.3 | -20.6 | 0.1 | a rising whoosh into a snap, then three small flaps |
| `summit_bell_01.wav` | 5.46 | -3.0 | -23.2 | -31.9 | 0.2 | eleven bronze-bell partials in beating pairs on D3 with a major-third tierce; 02 struck harder, 03 softer |
| `summit_bell_02.wav` | 5.47 | -3.0 | -24.7 | -31.9 | 0.1 | eleven bronze-bell partials in beating pairs on D3 with a major-third tierce; 02 struck harder, 03 softer |
| `summit_bell_03.wav` | 5.41 | -3.0 | -24.1 | -35.0 | 0.2 | eleven bronze-bell partials in beating pairs on D3 with a major-third tierce; 02 struck harder, 03 softer |
| `bounce_rope_01.wav` | 0.77 | -3.0 | -24.3 | -26.2 | 0.0 | Karplus-Strong string (E2, A2), dulled, bent down onto its note with a wobble, over a thwap |
| `bounce_rope_02.wav` | 0.88 | -3.0 | -25.8 | -29.3 | 0.1 | Karplus-Strong string (E2, A2), dulled, bent down onto its note with a wobble, over a thwap |
| `knock_out_bonk_01.wav` | 0.40 | -3.0 | -20.8 | -25.0 | 0.1 | a short sine that drops onto its note, a hollow two-mode click, a low thump |
| `knock_out_bonk_02.wav` | 0.46 | -3.0 | -20.7 | -26.4 | 0.1 | a short sine that drops onto its note, a hollow two-mode click, a low thump |
| `land_thud_big_01.wav` | 0.70 | -3.0 | -17.0 | -26.1 | 0.1 | a 58 Hz thump, a slap of low noise, a breath of dust |
| `land_thud_big_02.wav` | 0.82 | -3.0 | -16.6 | -27.0 | 0.1 | a 58 Hz thump, a slap of low noise, a breath of dust |
| `new_best_chime.wav` | 0.60 | -3.0 | -15.5 | -15.1 | 0.1 | two FM bell notes, A5 then D6, the index falling so each starts bright |
