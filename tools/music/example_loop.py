"""A first loop, to prove the road (docs/music/MAKING_MUSIC.md, section 4).

Eight bars of 4/4 at 105 bpm (44100*60/105 = 25200, sample-exact): a lead, a
strummed rhythm guitar, a root-and-fifth bass and a kick-clap pulse. The last bar
(G) leads back to bar 1 (Dm), so the seam is a musical event.

    python tools/music/example_loop.py                 -> example_loop.wav (here)
    python tools/music/example_loop.py some/path.wav   -> that path

It prints the seam line: "... -> OK" means the loop wraps cleanly.
"""
import sys

from sf_kit import Song, chord

out = sys.argv[1] if len(sys.argv) > 1 else "example_loop.wav"
s = Song(tempo=105)
lead = s.track("Accordion")
rhythm = s.track("Nylon Guitar")
bass = s.track("Acoustic Bass")
kit = s.drums()
Dm, C, G = chord(50, "min"), chord(48, "maj"), chord(43, "maj")
for bar, (ch, root) in enumerate([(Dm, 38), (C, 36), (Dm, 38), (G, 43)] * 2):
    b = bar * 4
    rhythm.at(b).note(ch[0], 0.45, 70).chord(ch[1:], 0.4, 58, strum=0.02)
    rhythm.at(b + 2).note(ch[0], 0.45, 70).chord(ch[1:], 0.4, 58, strum=0.02)
    bass.at(b).note(root, 1.0, 92).rest(1).note(root + 7, 1.0, 84).rest(1)
    kit.hit("Kick", b)
    kit.hit("Hand Clap", b + 1)
    kit.hit("Kick", b + 2)
    kit.hit("Hand Clap", b + 3)
lead.at(0).notes([(69, .75), (69, .25), (74, 1), (72, .75), (69, .25), (67, 1)] * 4 + [(62, 3), (69, .5), (72, .5)] * 2, vel=90)
s.render_loop(out, loop_beats=32)
