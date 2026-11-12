"""THE PEAK OF DEGAYO: build all the music.

    python tools/music/peak/build_all.py            everything: 12 loops, 3 stingers, all checks
    python tools/music/peak/build_all.py a3 a7      only those loops (checks still run on all)
    python tools/music/peak/build_all.py --check    read the notes back and check the law; no audio
    python tools/music/peak/build_all.py --stems a6 each track of a loop alone, with its level
    python tools/music/peak/build_all.py --stingers only the three stingers

Writes audio/music/peak/peak_a0.ogg .. peak_a11.ogg, audio/sfx/peak/*.wav and
tools/music/peak/measured.json (the numbers docs/peak/MUSIC.md quotes). Needs ffmpeg on PATH.
No WAV is left in the repo: the loops are rendered in a temp folder and only the OGG comes back.
"""
import importlib
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import peak_common as pc  # noqa: E402

AREAS = ["a00_estacion", "a01_mina", "a02_aguas", "a03_gruta", "a04_jardin", "a05_templo",
         "a06_chimenea", "a07_riscos", "a08_teleferico", "a09_glaciar", "a10_tormenta", "a11_cumbre"]
MEASURED = os.path.join(HERE, "measured.json")


def main(args):
    only = {int(a[1:]) for a in args if a[:1] == "a" and a[1:].isdigit()}
    mods = [importlib.import_module(m) for m in AREAS]
    assert [m.INDEX for m in mods] == list(range(12))
    songs = [m.build() for m in mods]

    # ---- the notes, read back: the law, the bass, the motif (every loop, every run)
    print("NOTES")
    facts = []
    for m, s in zip(mods, songs):
        f = pc.analyse(s, m.MODE, m.RESOLVED)
        f["self_semitone_beats"] = round(pc.self_clash(s), 2)
        f["channels"] = [t.name for t in s.tracks]
        facts.append(f)
        print("  a%-2d %-28s %-5s pitched notes %5d  all onsets %5d  bass root in %2d/32 bars  motif %s  own semitone rub %5.1f beats"
              % (m.INDEX, m.NAME, m.MODE, f["notes"], f["onsets"], f["bars_with_bass_root"],
                 "RESOLVED" if m.RESOLVED else "hangs", f["self_semitone_beats"]))
    print("NEIGHBOURS (beats of 128 in which a note of one sounds a semitone from a note of the other)")
    pairs = []
    for i in range(11):
        chrom, new, both, worst = pc.cross_clash(songs[i], songs[i + 1])
        pairs.append({"pair": "a%d+a%d" % (i, i + 1), "chromatic_beats": chrom, "new_semitone_beats": round(new, 2),
                      "together_semitone_beats": round(both, 2), "worst_bar": worst})
        print("  a%d+a%d  chromatic (C/C#, G/G#) %.2f   new in-key rubs %.2f   any semitone in the two together %.2f"
              "  (alone: %.1f, %.1f)   busiest bar %d"
              % (i, i + 1, chrom, new, both, facts[i]["self_semitone_beats"], facts[i + 1]["self_semitone_beats"], worst))
        assert chrom == 0, "a%d and a%d clash chromatically" % (i, i + 1)
    if "--check" in args:
        return
    if "--stems" in args:
        for i in sorted(only):
            print("STEMS a%d (each track alone, gain 0.4)" % i)
            for name, db, adb, pk in pc.stem_levels(songs[i]):
                print("  %-22s rms %6.1f dB   A-weighted while playing %6.1f dB   peak %.3f" % (name, db, adb, pk))
        return

    measured = json.load(open(MEASURED)) if os.path.exists(MEASURED) else {}
    measured.setdefault("loops", {})
    target = pc.target_rms_db()
    measured["target_rms_db"] = round(target, 2)
    measured["reference_lufs"] = pc.lufs(pc.REFERENCE) if os.path.exists(pc.REFERENCE) else None
    measured["loop_samples"] = pc.LOOP_SAMPLES
    measured["tempo"] = pc.TEMPO
    measured["pairs"] = pairs

    if "--stingers" not in args:
        print("RENDER (target %.2f dB RMS, the level of audio/music/desert_snake.wav)" % target)
        for m, s, f in zip(mods, songs, facts):
            if only and m.INDEX not in only:
                continue
            r = pc.render_area(s, m.INDEX, target_db=target, **m.RENDER)
            r.update(name=m.NAME, mode=m.MODE, **f)
            measured["loops"]["a%d" % m.INDEX] = r
            print("  a%-2d %d samples  %.4f s  rms %.2f dB  %.1f LUFS  peak %.3f  wav seam %s (%.5f, local step %.5f)  "
                  "ogg seam %s (%.5f vs %.5f, local %.5f, click x%.2f)  %d kB"
                  % (m.INDEX, r["samples"], r["seconds"], r["rms_db"], r["lufs"], r["peak"],
                     "OK" if r["wav_seam_ok"] else "AUDIBLE", r["wav_seam"], r["wav_local"],
                     "OK" if r["ogg_seam_ok"] else "AUDIBLE",
                     r["ogg_seam"], r["ogg_delta"], r["ogg_local"], r["ogg_click"], r["ogg_kb"]))
    if not only:
        import stingers
        print("STINGERS")
        measured["stingers"] = stingers.build()
        for st in measured["stingers"]:
            print("  %(file)s  %(seconds).3f s  rms %(rms_db).2f dB  peak %(peak).3f  %(kb).0f kB" % st)

    # ---- the shipped files, decoded again: one length, one loudness, and the neighbours mixed
    files = [os.path.join(pc.OUT_MUSIC, "peak_a%d.ogg" % i) for i in range(12)]
    if all(os.path.exists(p) for p in files):
        print("SHIPPED FILES")
        prev, counts, mixes = None, [], []
        for i, p in enumerate(files):
            d = pc.decode(p)
            counts.append(len(d))
            db = pc.rms_db(d)
            assert abs(db - target) <= 1.0, "a%d is %.2f dB, more than 1 dB from %.2f" % (i, db, target)
            assert abs(d).max() < 0.999, "a%d clips" % i
            if prev is not None and len(prev) == len(d):
                mix = 0.5 * prev + 0.5 * d
                mixes.append({"pair": "a%d+a%d" % (i - 1, i), "rms_db": round(pc.rms_db(mix), 2),
                              "peak": round(float(abs(mix).max()), 3)})
            prev = d
        assert len(set(counts)) == 1 and counts[0] == pc.LOOP_SAMPLES, "sample counts differ: %s" % counts
        measured["mixes"] = mixes
        print("  all twelve decode to %d samples (%.4f s), all within 1 dB of %.2f dB, none clip"
              % (counts[0], counts[0] / pc.SR, target))
        print("  half-and-half neighbour mixes: " + ", ".join("%s %.1f dB pk %.2f" % (x["pair"], x["rms_db"], x["peak"]) for x in mixes))
        total = sum(os.path.getsize(p) for p in files) / 1048576.0
        measured["total_ogg_mb"] = round(total, 2)
        print("  twelve OGGs: %.2f MB" % total)
        bad = [k for k, v in measured["loops"].items() if not (v["wav_seam_ok"] and v["ogg_seam_ok"])]
        print("  seams: " + ("all OK" if not bad else "AUDIBLE in " + ", ".join(bad)))
    json.dump(measured, open(MEASURED, "w"), indent=1)
    print("wrote", MEASURED)


if __name__ == "__main__":
    main(sys.argv[1:])
