# The Peak's music

Twelve loops that are one piece, one for each area of the mountain, and three stingers.
Composed in Python with `tools/music/sf_kit.py`, rendered through FluidSynth with the
GeneralUser GS soundfont (the house method, `docs/music/MAKING_MUSIC.md`).

**Nobody has listened to any of this yet.** It was written and checked by reading the
notes back and by measuring the rendered files. Every number on this page comes from the
last build (`tools/music/peak/measured.json`). The last section says what an ear should
check first.

```
python tools/music/peak/build_all.py            # everything (about 70 s)
python tools/music/peak/build_all.py a3 a7      # only those loops
python tools/music/peak/build_all.py --check    # read the notes back, no audio
python tools/music/peak/build_all.py --stems a6 # each track of a loop alone, with its level
python tools/music/peak/build_all.py --stingers # only the stingers
```

| File | What |
|---|---|
| `tools/music/peak/peak_common.py` | the shared score: tempo, chord plan, colours, the law, the tune, the motif, the renderer, the checks |
| `tools/music/peak/a00_estacion.py` .. `a11_cumbre.py` | one script for each area |
| `tools/music/peak/stingers.py` | the three stingers |
| `tools/music/peak/build_all.py` | builds and measures everything |
| `audio/music/peak/peak_a0.ogg` .. `peak_a11.ogg` | the loops (OGG Vorbis, quality 5, 15.8 MB in all) |
| `audio/sfx/peak/peak_fall_wah.wav`, `peak_summit_fanfare.wav`, `peak_milestone.wav` | the stingers (44.1 kHz, 16-bit, stereo) |

No WAV of a loop is left in the repo. The loops are rendered in a temp folder and only
the OGG comes back. Two builds give byte-identical files.

## 1. What all twelve share

| | |
|---|---|
| Tempo | **98 bpm**. 44100 x 60 / 98 = 27,000 samples a beat, exactly |
| Length | 32 bars of 4/4 = 128 beats = **3,456,000 samples = 78.3673 s** |
| One bar | 108,000 samples = 2.449 s |
| Key | D. Every loop uses the same roots in the same bars |
| Tune | one 32-bar tune in D major pentatonic (D E F# A B) |
| Motif | the DeGayo call: D F# A B |

**98, not 96.** `PEAK_DESIGN.md` section 8 says 96 bpm and 80.0 s. The brief for this
job asked for the sample-exact tempo nearest 96 from the method's list, and that is 98.
The design page should be corrected to 98 bpm and 78.37 s. (96 is not sample-exact per
beat, though a 128-beat loop at 96 would still come to a whole 3,528,000 samples. If
exactly 80.0 s matters more than the method's list, it is a change to `TEMPO` and the
check under it, and a rebuild.)

## 2. The chord plan

One chord a bar. Every area plays these roots, in these bars. Bar 32's A leads back to
bar 1's D, so the loop's seam is a cadence.

| Bars | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| 1-8, the call and an answer that ends open | D | D | G | D | Bm | G | Em | A |
| 9-16, the call again, a higher answer, home | D | D | G | D | Bm | Em | A | D |
| 17-24, the dark middle and a long climb on A | Bm | Bm | G | D | Em | G | A | A |
| 25-32, the reach, the cadence, the turnaround | D | G | D | Bm | G | A | D | A |

The bass line is the plan's roots (D2, G2, B1, E2, A1, or octaves of them). The build
checks that in every bar of every loop the lowest note sounding on beat 1 is the root:
32 bars of 32, in all twelve.

### The four colours

Neighbouring areas differ in mode. The roots never change. What changes is the colour
note, and where it is allowed to sound.

| Colour | Key signature | What it does | Areas |
|---|---|---|---|
| `ion` | D major | plain major | a0, a4, a8, a11 |
| `mix` | D mixolydian (one step flat: G major's notes) | C natural, on D bars only. A bars have no third | a1, a5, a7 |
| `lyd` | D lydian (one step sharp: A major's notes) | G sharp, on D and Bm bars only | a3, a9 |
| `plain` | D major, thinned | no colour note, and D bars have no third (D E A) | a2, a6, a10 |

### The law (`allowed()` in `peak_common.py`)

What an area may sound in a bar, by pitch class:

- The tune's five notes (D E F# A B) anywhere, except **D over an A bar** (it would rub
  the C sharp).
- **G natural** only on G and Em bars (a chord tone) and A bars (the seventh).
- **C sharp** only on A bars, and never in a `mix` area.
- **C natural** only on D bars, only in `mix`.
- **G sharp** only on D and Bm bars, only in `lyd`.

So a C can never meet a C sharp in the same bar, nor a G a G sharp, in one loop or in
two neighbours (a `mix` area is never next to a `lyd` area). The build reads every note
of every loop back and fails if one breaks the law, including a note held over a
barline into a bar where it is not allowed. It also fails if a pitch starts on a
channel while the same pitch still sounds there (the method's rule 7).

## 3. The tune and the motif

MIDI note numbers and beats. 62 = D4, 66 = F#4, 69 = A4, 71 = B4, 74 = D5.

| Bars | The tune (`note x beats`, `-` = rest) |
|---|---|
| 1-2 (D D) | **62 66 69 71x3**, 69x2 |
| 3-8 | 71x1.5 69x.5 71 74, 69x3 -, 66 71 74x1.5 71x.5, 74x2 71x2, 71 76 74 71, 69x3 - |
| 9-10 (D D) | **62 66 69 71x3**, 69 66 |
| 11-16 | 71x1.5 69x.5 71 74, 78x2 74x1.5 69x.5, 71 74 78x1.5 74x.5, 76x2 71 76, 76 71 69x1.5 66x.5, 66x3 - |
| 17-18 (Bm Bm) | **62 66 69 71x3**, 66x2 |
| 19-24 | 74x1.5 71x.5 74 76, 69x2 66x2, 64 71 76x1.5 74x.5, 71x2 74x2, 76 78 76 71, 76x3 - |
| 25-26 (D G) | **74 78 81 83x3**, 81 76 |
| 27-32 | 78x1.5 76x.5 74 69, 71x2 74 78, 74x1.5 76x.5 74 71, 69 71 76x2, 78 74 69x2, 64x3 - |

**The motif** is the four notes in bold: D F# A B, a quarter each, and the B held three
beats. It is stated four times, at bars 1, 9, 17 (over B minor, where the same four
notes are the Bm7 chord) and 25 (an octave up, the B ringing on into G where it is the
third). Each time it reaches the B and falls back to A or F#. The tune's own cadences
do the same: the four phrases end on A, F#, E and E. No phrase ends on D.

**Only a11 resolves it** (`tune(resolved=True)`): there every call is D F# A B and then
the D above, phrase 2 ends on D, and the last phrase climbs the call once more, broad,
across the cadence (D F# over G in bar 29, A B over A in bar 30, the D held through the
whole of bar 31). The build checks this: each of a0 to a10 must contain D F# A B rising
on one channel and must never follow it with the D above; a11 must.

How each area voices the tune:

| Area | Who has the motif | How much of the tune |
|---|---|---|
| a0 | far trumpet (bars 1, 9, 25), guitar (17) | all of it, passed between the trumpet and a guitar |
| a1 | harmonica (1, 17, 25) | most of it, with rests and blue notes (C natural) |
| a2 | low bandoneon (1, 9), marimba drips (17, 25) | the second halves of phrases 2 and 4 |
| a3 | music box, all four | nearly all, an octave up |
| a4 | kalimba (1, 9, 25), pizzicato (17) | all of it |
| a5 | trombone at all four, horns with it at 9 and 25, ocarina at 1 and 25 | most of it, on the ocarina |
| a6 | trumpet over horns, all four | bars 13-16, 19-24 (horns), 27-32 |
| a7 | whistle (1, 25), guitar (9, 17) | all of it |
| a8 | accordion, all four | all of it, in thirds on phrases 2 and 4 |
| a9 | bowed glass, four times as slow (a note a bar) | only the tune's long notes |
| a10 | trumpet, torn (see a10 below) | bars 29-31 |
| a11 | trumpets and violins, resolved | all of it, resolved |

## 4. The twelve areas

Channels are MIDI channels (10 is the kit). "Onsets" is every note and drum hit in the
loop: a rough measure of how busy it is.

### a0 La Estación. D major (`ion`). 484 onsets
The town's guitar and trumpet, half heard, walking away. A slow bass-strum on a nylon
guitar (fingerpicked through bars 17-24). A far trumpet starts phrases 1, 2 and 4 and
its expression falls away over two bars each time. A second guitar finishes what it
left. Maracas on the beat in phrases 2 and 4 are the footsteps. The render is wetter
than the house setting, and the finished loop is low-passed (full under 1.5 kHz,
falling to 0.35 at 5 kHz) so it sounds like a band two streets behind you. The filter
is done on the whole loop as a circle, so the seam survives it.
Channels: 1 Nylon Guitar (rhythm), 2 Nylon Guitar (tune), 3 Trumpet, 4 Acoustic Bass,
10 Standard kit (maracas).

### a1 La Mina Vieja. D mixolydian (`mix`). 401 onsets
Guitarrón and muted pick-axe percussion, a lone harmonica. An acoustic bass in octaves
trudges root and fifth and walks D, A, C into the G of bars 3 and 11. Two picks a bar
(side stick on 2 and 4), a mute-triangle tink and wood-block chips now and then. The
harmonica plays the tune with a lone player's rests and bends through C natural on the
D bars (bars 4, 12, 20, 27). Its own echo answers off the far wall: a second harmonica,
a beat and a half late and three beats late, quieter each time.
Channels: 1 Acoustic Bass, 2 Harmonica, 3 Harmonica (echo), 10 Standard kit.

### a2 Las Aguas Negras. `plain`. 267 onsets
Bowed bass, dripping marimba, low accordion swells. No pulse but the bass re-bowing each
bar. A bowed double bass holds the roots, a low accordion breathes in two-bar swells
(D E A on the D bars), a bandoneon low in its range speaks the call, and a marimba drips
from the roof (seeded, so every build is the same water) and drips the call itself at
bars 17 and 25.
Channels: 1 Double Bass, 2 Accordion (pad), 3 Bandoneon, 4 Marimba.

### a3 La Gruta de Cristal. D lydian (`lyd`). 443 onsets
Celesta and glass, music-box motif, slow harp. A music box sings the call and the tune
an octave up. A celesta turns even eighths under it, through G sharp on the D and Bm
bars, and stops to let each call ring alone. A harp climbs four slow notes a bar from
the root. Bowed glass holds a fifth. A glockenspiel sighs G#6 to A6 three times.
Channels: 1 Celeste, 2 Music Box, 3 Orchestral Harp, 4 Bowed Glass, 5 Glockenspiel.

### a4 El Jardín de Hongos. D major (`ion`). 980 onsets
Kalimba, pizzicato, a bouncing bassoon, playful. The bassoon bounces root, octave, fifth
in staccato eighths and trips up a run every fourth bar. The kalimba plucks the tune an
octave up and taps its long notes again. Pizzicato strings sit on the backbeats, then
take the tune through bars 17-24 while the kalimba answers. Wood blocks tick-tock on the
off-beats, a cabasa keeps time, bongos trip over the phrase ends, a vibraslap laughs at
bars 16 and 32. A xylophone doubles the last phrase.
Channels: 1 Kalimba, 2 Pizzicato Strings, 3 Bassoon, 4 Xylophone, 10 Standard kit.

### a5 El Templo del Primer Perro. D mixolydian (`mix`). 648 onsets
Deep drums, clay flute, low brass on the motif. A taiko keeps a slow heavy figure (and a
fill out of each phrase) with a concert bass drum under every second bar and a rattle of
maracas. Trombone states the call low at every slot, horns join it at bars 9 and 25.
Between calls the horns hold D A C on the D bars (a hollow old seventh) and A E G on the
A bars. The clay flute is an ocarina, leaning on C natural. The tuba holds the roots.
Channels: 1 Ocarina, 2 Trombone, 3 French Horns, 4 Tuba, 5 Taiko Drum,
6 Concert Bass Drum, 10 Standard kit.

### a6 La Chimenea. `plain`. 1,332 onsets
Anvils, snare rolls, rising brass, urgent. Four kicks to the bar, a snare that gallops
(one, and-a) and rolls into every second bar, with a two-beat roll out of each phrase.
The anvils are an agogo ringing the plan's root on the backbeats, and a ride bell. Low
strings chug eighths in 3+3+2, the tuba pounds the roots. The brass section climbs
through each eight-bar phrase (the voicing moves up every two bars and the
expression opens) and stabs out of the last bar. A trumpet with horns under it throws
the call at every slot, shouts short rising calls in bars 5-8 and 21-24, and takes the
tune out of the top.
Channels: 1 Trumpet, 2 French Horns, 3 Brass Section, 4 Fast Strings, 5 Tuba, 6 Agogo,
10 Power kit.

### a7 Los Riscos del Viento. D mixolydian (`mix`). 895 onsets
Whistled motif, western guitar, castanets, wide open. A steel guitar plays boom,
chk-a-chk and turns the second D bar into D7. The bass walks through C natural. A whistle
carries the tune an octave up with a lot of room round it. A second guitar twangs the
call alone at bar 9 and takes bars 17-24 an octave down. Castanets answer on 2 and 4 and
roll out of each phrase. A high fifth of strings (A and E) opens over the second half.
The widest, wettest reverb but the glacier's.
Channels: 1 Whistle, 2 Steel Guitar (rhythm), 3 Steel Guitar (lead), 4 Acoustic Bass,
5 Castanets, 6 Slow Strings.

### a8 El Teleférico. D major (`ion`). 670 onsets
Accordion and a swaying bass, a little tipsy. The tuba sways 3+3+2 (root, fifth, root)
and stumbles up a leading tone into each new phrase. A second accordion puffs chords in
the gaps of the sway. The lead accordion plays the whole tune, each note a hair late (by
a seeded 0 to 0.08 of a beat, at most 49 ms), scoops up into its long notes from the
step below, and breathes with the bellows every bar. A clarinet hiccups at the ends of
lines. Brushes and a tambourine.
Channels: 1 Accordion (lead), 2 Accordion (thirds), 3 Italian Accordion (chords),
4 Tuba, 5 Clarinet, 10 Brush kit.

### a9 El Glaciar. D lydian (`lyd`). 181 onsets
High strings, glass harmonica, almost no rhythm. Nothing keeps time. High strings hold
the plan a bar or two at a time, with a G sharp in the top on four of the D bars. Low
strings hold the roots in octaves. Bowed glass speaks the call a note a bar (bars 1-4,
9-12, 17-20; two beats a note at 25-26) and then only the tune's long notes. A celesta
touches a note ten times in the whole loop. The biggest room on the mountain.
Channels: 1 Slow Strings (high), 2 Slow Strings (low), 3 Bowed Glass, 4 Celeste.

### a10 La Cresta de la Tormenta. `plain`. 612 onsets
Timpani, tremolo strings, trumpet calls torn by wind. As tense as the plan allows: bare
D bars (A D E), full sevenths on the A bars, a ninth on the Em bars, and a high tremolo
A that hangs over every bar and never lets go. Timpani strike the roots and roll into
every second bar, with a whole bar of roll at each phrase end. Low strings chug 3+3+2
from bar 9. A concert bass drum is the thunder, eight times, off the grid of the phrases.
The trumpet throws the call at every slot and the wind takes it. At bar 1 it is cut off
as the B sounds. At bar 9 the B never comes, and a far muted trumpet finds it a bar
late. At bars 17 and 25 it gets there, shaken, and falls back. Between slots it shouts
two-note calls that are torn the same way. "Torn" and "shaken" are expression (CC 11)
falling away or rolling twice a beat: `sf_kit` tracks carry no pitch bend. This loop has
the widest swing from bar to bar (about 8 dB, where the others move 2.5 to 6).
Channels: 1 Timpani, 2 Tremolo Strings, 3 Tremolo Strings (the high A), 4 Fast Strings,
5 French Horns, 6 Trumpet, 7 Muted Trumpet, 8 Concert Bass Drum, 10 Standard kit.

### a11 La Cumbre. D major (`ion`), resolved. 1,468 onsets
The whole mariachi on the motif, finally resolved. Two trumpets in thirds. Violins that
take the tune in phrase 2 and sing the octave above at the end. A trombone answering
and doubling low. Vihuela-style off-beat strums on a nylon guitar, a steel guitar
holding the chords, a guitarrón bass in octaves with walk-ups, a harp rolling and
running, a glockenspiel on the last phrase, maracas, guiro, tambourine. Bar 31 is one
held D chord with the violins' D on top, the guitar in tremolo and a crash. Bar 32 is
the band's turnaround (no tune: a bass walk A B C# E, a harp run, a trombone pickup),
so the loop comes round without quoting bar 1.
Channels: 1 Trumpet, 2 Trumpet 2, 3 Fast Strings, 4 Trombone, 5 Nylon Guitar,
6 Steel Guitar, 7 Orchestral Harp, 8 Acoustic Bass, 9 Glockenspiel, 10 Standard kit.

### Where the palette is a stand-in
The soundfont is General MIDI, so: the pick-axes are side stick, triangle and wood
block; the anvils are an agogo and a ride bell; the clay flute is the ocarina; the glass
harmonica and the grotto's glass are the Bowed Glass pad; the western guitar is the
steel guitar; the whistling is the Whistle preset.

## 5. The measured numbers

Target loudness: `audio/music/desert_snake.wav` measures **-23.79 dB RMS** (-22.0 LUFS).
Each loop is scaled to that RMS before it is encoded. All figures below are read from
the shipped OGG, decoded again with ffmpeg.

| Loop | Samples | Seconds | RMS dB | LUFS | Peak | Seam, WAV (step / local) | Seam, OGG (step / typical) | Click | Size kB |
|---|---|---|---|---|---|---|---|---|---|
| a0 | 3,456,000 | 78.3673 | -23.78 | -21.8 | 0.453 | 0.00043 / 0.00033 | 0.00055 / 0.00352 | x0.00 | 1262 |
| a1 | 3,456,000 | 78.3673 | -23.78 | -21.7 | 0.463 | 0.00018 / 0.00064 | 0.00070 / 0.00570 | x0.01 | 1364 |
| a2 | 3,456,000 | 78.3673 | -23.79 | -22.0 | 0.307 | 0.00171 / 0.00231 | 0.00186 / 0.00457 | x0.05 | 1224 |
| a3 | 3,456,000 | 78.3673 | -23.77 | -21.0 | 0.438 | 0.00171 / 0.00253 | 0.00164 / 0.00480 | x0.01 | 1359 |
| a4 | 3,456,000 | 78.3673 | -23.77 | -21.1 | 0.488 | 0.00043 / 0.02163 | 0.00125 / 0.00697 | x0.01 | 1338 |
| a5 | 3,456,000 | 78.3673 | -23.79 | -22.6 | 0.374 | 0.00250 / 0.00233 | 0.00652 / 0.00363 | x0.05 | 1224 |
| a6 | 3,456,000 | 78.3673 | -23.80 | -20.9 | 0.571 | 0.01239 / 0.01135 | 0.01263 / 0.00694 | x0.11 | 1274 |
| a7 | 3,456,000 | 78.3673 | -23.79 | -21.5 | 0.395 | 0.00324 / 0.00241 | 0.00277 / 0.00667 | x0.03 | 1595 |
| a8 | 3,456,000 | 78.3673 | -23.80 | -21.1 | 0.442 | 0.00104 / 0.00113 | 0.00187 / 0.00842 | x0.00 | 1352 |
| a9 | 3,456,000 | 78.3673 | -23.80 | -21.2 | 0.420 | 0.00082 / 0.00312 | 0.00029 / 0.00690 | x0.10 | 1474 |
| a10 | 3,456,000 | 78.3673 | -23.81 | -21.7 | 0.453 | 0.00647 / 0.00377 | 0.00880 / 0.00541 | x0.05 | 1269 |
| a11 | 3,456,000 | 78.3673 | -23.79 | -20.6 | 0.565 | 0.00070 / 0.00186 | 0.00130 / 0.01045 | x0.00 | 1439 |

- **Length:** all twelve decode to exactly 3,456,000 samples. Vorbis kept the count.
- **Loudness:** all twelve within 0.02 dB of the target RMS. None clips: the highest
  peak is 0.571. In LUFS they span -22.6 to -20.6, two LU, round the reference's -22.0.
- **Seam columns.** Full scale is 1.0. "Step" is the jump from the last sample to the
  first. For the WAV it is set beside a typical sample step in the 256 samples each side
  of the wrap. For the OGG it is set beside a typical step over the whole file, which is
  `sf_kit`'s yardstick: OK means under four of them. "Click" is the wrap's second
  difference against the sharpest 0.1% of moments in the same file: a click would stand
  well above x1, and the worst here is x0.11.
- **Verdict: every seam is OK**, in the WAV and in the OGG. The OGG's error against the
  WAV in the 512 samples at each end (-48 to -67 dB) is no worse than in the middle of
  the file (-44 to -55 dB): the encoder does nothing odd at the edges. OGG holds it, so
  there was no need to fall back to WAV.

### How the seam is made
`sf_kit.render_loop`'s way: the loop is rendered three times back to back and the middle
pass is kept, so it starts with the last pass's tails ringing in. One change
(`render_loop_exact` in `peak_common.py`): the last 2,048 samples (46 ms) of the kept
pass are always cross-faded into the audio that came just before the pass began, so the
last sample is the very sample that preceded the first in the long render. `sf_kit` only
blends when the step is over four typical steps. The first build of a2 sat just under
that with a step of 0.017 on a held bass note, several times the step round it. It is
0.0017 now.

### Neighbours played together
Read from the notes, in beats out of 128. "Chromatic" is a C against a C sharp or a G
against a G sharp across the two loops, and the build fails if it is not zero. "New" is
a semitone (by pitch class) between a note of one and a note of the other that neither
loop sounds by itself at that moment. "Together" is any semitone at all in the pair,
their own colours included, beside what each has alone. The last two columns are the
shipped files mixed at half volume each.

| Pair | Chromatic | New | Together (alone, alone) | Mix RMS dB | Mix peak |
|---|---|---|---|---|---|
| a0 + a1 | 0 | 1.33 | 5.08 (0.0, 3.8) | -25.45 | 0.379 |
| a1 + a2 | 0 | 3.08 | 6.83 (3.8, 0.0) | -26.61 | 0.260 |
| a2 + a3 | 0 | 0 | 5.67 (0.0, 5.7) | -27.00 | 0.280 |
| a3 + a4 | 0 | 0 | 5.67 (5.7, 0.0) | -27.00 | 0.322 |
| a4 + a5 | 0 | 0.75 | 1.92 (0.0, 1.2) | -26.78 | 0.326 |
| a5 + a6 | 0 | 0 | 1.17 (1.2, 0.0) | -26.67 | 0.293 |
| a6 + a7 | 0 | 0 | 0.00 (0.0, 0.0) | -26.87 | 0.322 |
| a7 + a8 | 0 | 0.08 | 1.92 (0.0, 1.8) | -26.84 | 0.267 |
| a8 + a9 | 0 | 1.00 | 14.83 (1.8, 12.0) | -26.86 | 0.268 |
| a9 + a10 | 0 | 0 | 24.25 (12.0, 12.2) | -26.81 | 0.264 |
| a10 + a11 | 0 | 1.50 | 15.83 (12.2, 2.1) | -26.65 | 0.322 |

What the "alone" figures are: a1 and a5's C natural against the tune's B; a3 and a9's
G sharp against A; a10's ninth on the Em bars (F# over G). They are each loop's own
colour, and a pair adds about 3 beats of new rub to them at most. This says no two neighbours
are in different keys at the same moment. It does not say the pair sounds good: that is
for an ear.

### The stingers

| File | Seconds | RMS dB | Peak | Size kB | What |
|---|---|---|---|---|---|
| `peak_fall_wah.wav` | 2.150 | -17.44 | 0.800 | 370 | muted trumpet, a trombone an octave under it |
| `peak_summit_fanfare.wav` | 9.600 | -18.18 | 0.890 | 1654 | full mariachi |
| `peak_milestone.wav` | 1.000 | -20.99 | 0.600 | 172 | glockenspiel and celesta |

- **`peak_fall_wah`**: "wah, waaah". The call's top note, B, and then the B flat it sags
  to. Each note scoops up into pitch as the hand comes off the bell, and the second
  droops and wobbles as it dies. Measured: the first note holds B, the second starts on
  B flat and has sunk about a semitone and a half by 1.7 s. Silent by 1.95 s. Two notes,
  so it is not the four-note "sad trombone" everyone knows. It needed pitch bend, so it
  is written straight to MIDI in `stingers.py`.
- **`peak_summit_fanfare`**: at 98 bpm. Bar 1 is the call on two trumpets in thirds with
  a trombone under them. Bar 2 reaches the D above over G, then two pickups over A.
  Bars 3-4 are a D major chord held 3.3 s (trumpets on F# and D, violins and a
  glockenspiel carrying D on top, a harp run, the guitar in tremolo, a timpani roll, a
  crash), swelling, and left to ring out. The chord starts at 4.9 s and is released at
  8.2 s.
- **`peak_milestone`**: D6 F#6 A6, 0.09 s apart, rung out and faded by 1.0 s.

## 6. For the game

- Load each loop with `loop = true` (`stages/peak/peak_audio.gd` already does). The loop
  point is the whole file.
- The sync is in the files: equal sample counts. It only holds if all twelve players
  start on the same mix frame and none is ever stopped, paused or sought by itself. If
  they drift, the thing to reach for is one `AudioStreamSynchronized` holding the twelve.
- A bar is 2.449 s and the loop is 78.37 s, if anything is timed to the music ("comes
  back a bar after you land").
- The loops are all one loudness, as asked. So the story's rise and fall is in how busy
  each loop is, not in its level: the glacier is as loud as the chimney. If the still
  areas should also be quieter, that is a per-area trim in the game's mixer.
- **The files changed after Godot last imported them.** The `.import` files in the
  folder are dated in the middle of this build, so it looks as if another session
  imported while the loops were still being rewritten, and at the time of writing
  `audio/music/peak/peak_a8.ogg.import` says `valid=false`. Run an import before
  judging anything in the game.

## 7. What an ear should check first

1. **The crossings where the mode changes.** a2 to a3 and a8 to a9 (a G sharp arrives
   over a neighbour's plain D chord), and a0 to a1, a4 to a5, a6 to a7 (a C natural
   arrives). The notes say these cannot clash. Whether they sound like one piece
   changing colour, or like two bands, is the whole job, and only an ear can say.
2. **a10 alone.** Is the storm tense, or just ugly? The Em bars carry F# against G, and
   the high A never stops. And do the torn trumpet calls sound like wind, or like a
   fader being pulled?
3. **a11, bars 29 to 32 and round into bar 1.** The resolution is the pay-off for the
   whole climb: does the D in bar 31 land as home, and does bar 32 lead back without a
   bump?
4. **The leads' levels.** Set from each track's level measured alone, not by ear: the
   whistle (a7, turned down 11 dB from the first draft), the ocarina (a5), the music box
   (a3), the harmonica against its echo (a1), the far trumpet (a0).
5. **a0's filter.** "Half heard" may simply be dull.
6. **a8's timing.** The accordion is up to 49 ms late on purpose. Tipsy, or sloppy?
7. **The jokes on the twentieth hearing.** The vibraslap in a4, the clarinet hiccups in
   a8, the wah.
8. **One tune for 1,000 m.** Every area voices the same 32 bars. That is the design
   (crossing an edge is a re-orchestration), but a rage game is played for hours.
   Listen to three neighbours in a row and say whether it wears.

## 8. Not sure of

- Everything about how it sounds. The checks prove the notes are lawful, the files
  are the same length, the level matches and the seams are clean. They do not prove
  the music is good.
- **Loudness by RMS.** The brief asked for RMS and that is matched. By LUFS the loops
  differ by up to 2 LU (a5 is the quietest at -22.6, a11 the loudest at -20.6).
- **The presets at these pitches.** The music box reaches F#6 and the whistle F#6. The
  trumpets sit low at the summit's last cadence (B3 to D5) so the violins can have the
  top. None of that has been heard.
- **a6's urgency.** The tempo is fixed at 98 for all twelve, so the chimney is urgent
  by its sixteenths and its rolls, not by speed.
- **Twelve OGG decoders at once** in the game: not measured here.
