"""
THE LAB: one of each mechanic on a flat floor, for the batteries (tests/battery.gd --peak).
Not part of the mountain. Writes tests/peak_lab/.
  python tools/peak/areas/lab.py
"""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from peaklib import Area, ROOT, box_pts, ngon, save_meta

A = Area("lab", "mine")
A.solid([(-80, -2), (80, -2), (80, 0), (-80, 0)], "rock")  # the floor

# a rope, 8 m, hung at (-70, 12)
A.rope("rope", (-70, 12), 8.0, "rope")
# a bridge of planks
A.rope("bridge", (-62, 4), 8.2, "rope", to=(-54, 4), planks=1, slack=1.04)
A.ledge(-64, -62, 4, "wood")
A.ledge(-54, -52, 4, "wood")
# still water and flowing water (no banks: the zones are what's tested)
A.water((-48, 0.2, -36, 6), 5.0, (0.0, 0.0))
A.water((-34, 0.2, -4, 6), 5.0, (1.5, 0.0))
# a platform that goes back and forth
A.mover("plat", (2, 3), [(box_pts(0, 0, 3.0, 0.4), "wood")],
        {"type": "path", "pts": [[2, 3], [10, 3]], "speed": 2.0, "mode": "pingpong", "wait": 0.5})
# a hold that crumbles, a hold that lets go
A.ledge(13, 15, 4, "rotten")
A.ledge(17, 19, 4, "ice")
# a cap that throws
A.ledge(22, 26, 1.0, "cap", t=1.0)
A.bounce((22, 1.0), (26, 1.0), 8.0)
# a geyser, a wind box
A.geyser(30, 0, 2.0, 8.0, 7.0, period=4.0, on=2.0, phase=0.0, warn=0.5)
A.wind((34, 0, 40, 8), (4.0, 0.0))
# a slick slope pouring onto the floor, and a flat of slick (the softlock net's test)
A.solid([(44, 0), (52, 0), (52, 6)], "wet")
A.ledge(56, 62, 0.4, "wet", t=0.4)
# a wheel, a pendulum, a piston
A.wheel("wheel", (66, 5), 3.0, 4.0, spokes=4)
A.pendulum("pend", (72, 10), 6.0, 30.0, 5.0)
A.mover("piston", (76, 2), [(box_pts(0, 0, 2.0, 1.0), "stone")],
        {"type": "cycle", "to": [0, 3], "t_out": 0.5, "hold_out": 1.0, "t_in": 0.5, "hold_in": 1.0})
# a burro (kick), a puffball, a free crank
A.mover("burro", (-76, 1), [(box_pts(0, 0, 1.6, 1.0), "bone")], {"type": "still"}, hold={"type": "kick", "v": [-3.0, 7.0]})
A.puff(-78, 8, 0.6, 7.0)
A.body("crank", (78, 12), [(ngon(0, 0, 0.8, 8), "wood"), (box_pts(0.7, 0, 0.3, 0.3), "iron")], mass=8.0, hinge=(78, 12))
A.statue(-20, 9.0, "hang")
A.challenge("0.1", "Lab", (0, 0), 1, "S")

if __name__ == "__main__":
    folder = os.path.join(ROOT, "tests", "peak_lab")
    save_meta(folder, order=["lab"])
    A.save(folder)
