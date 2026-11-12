"""
A0 LA ESTACION: the trailhead and the cart ride. Also the worked example for area authors.
  python tools/peak/areas/a0.py
"""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from peaklib import Area, box_pts, ngon, save_meta

A = Area("a0", "town")

# ---------------------------------------------------------------- the ground at the edge of town
A.solid([(16, -3), (16, 0), (-36, 0), (-36, -3)], "rock")  # the road (grip: you stand on it)
A.box(15.0, 30.0, 2.0, 66.0, "void")  # the world's east edge, unseen: the town is that way

# ---------------------------------------------------------------- 0.1 El Primer Paso: crates up to the platform
A.box(-2.6, 0.55, 1.2, 1.1, "wood")  # one crate
A.box(-3.9, 0.55, 1.4, 1.1, "wood")  # two crates stacked
A.box(-3.9, 1.65, 1.3, 1.1, "wood")
A.ledge(-36.0, -4.6, 2.2, "plank", t=0.45)  # the loading platform; the rails run along it
for x in (-6.0, -14.0, -22.0, -30.0):
    A.box(x, 0.87, 0.35, 1.75, "wood")  # its legs
A.challenge("0.1", "El Primer Paso", (4.0, 0.0), 1, "S",
            moves=[["reach", [-2.6, 1.1], [-3.9, 2.2]]])

# ---------------------------------------------------------------- 0.2 Subete / 0.3 El Descenso: the cart
# The cart's origin is the middle of its floor. Its path is that point's road.
RIDE = [(-9.0, 2.65), (-34.0, 2.65), (-46.0, 1.2), (-62.0, -3.0), (-78.0, -4.2), (-90.0, -2.2),
        (-104.0, -6.5), (-120.0, -9.6), (-136.0, -11.2), (-148.4, -11.55)]
cart_shapes = [
    (box_pts(0.0, 0.0, 2.4, 0.2), "plank"),  # floor
    (box_pts(-1.12, 0.35, 0.16, 0.9), "iron"),  # the two ends
    (box_pts(1.12, 0.35, 0.16, 0.9), "iron"),
]
A.mover("cart0", RIDE[0], cart_shapes,
        {"type": "path", "pts": [list(p) for p in RIDE], "speed": 9.0, "mode": "once", "trigger": "board",
         "reset": 25.0, "tilt": True, "accel": 3.0},
        model="minecart")
A.challenge("0.2", "Súbete", (-6.2, 2.2), 1, "S")
A.challenge("0.3", "El Descenso", (-9.0, 2.9), 1, "S")

# The tunnel: its air, from the mouth (x -36) to the door into the mine (x -152).
# cave() takes the AIR's outline; every edge gets rock behind it. Edge i runs pts[i] -> pts[i+1].
floor = [(p[0], p[1] - 0.45) for p in RIDE[1:]]  # the rail bed, under the cart's road
floor[0] = (-36.0, 2.2)
floor[-1] = (-152.0, -12.0)
roof = [(x, y + 5.0) for x, y in reversed(floor)]
air = floor + roof
kinds = {i: "rock" for i in range(len(floor) - 1)}  # the rail bed grips: fall out and you can walk
kinds[len(floor) - 1] = None  # the west end: the door into the mine
for i in range(len(floor), len(air) - 1):
    kinds[i] = "rock2"  # the roof
kinds[len(air) - 1] = None  # the east end: the mouth
A.cave(air, kinds, default="wet", thick=3.0)
A.opening(-153, -13, -151, -6)  # the door to A1
A.opening(-37, 2, -35, 8)  # the mouth
A.box(-150.3, -11.6, 0.6, 0.8, "iron")  # the buffer the cart stops against
A.dark((-152, -16, -40, 9), level=0.8)  # inside the mountain: the light goes

# ---------------------------------------------------------------- the picture
A.card([(-152, -17), (-36, -17), (-36, 9), (-152, 9)], z=-3.0, tone="#33241A")  # the tunnel's back wall
A.deco("sign_pug_arrow", 1.5, 0.0, z=-1.0, size=(1.0, 2.2, 0.1), tone="wood")
A.deco("papel_tatters", -2.0, 4.2, z=-1.6, size=(8.0, 1.0, 0.05), tone="accent")
A.deco("mine_frame", -36.0, 2.2, z=0.0, size=(0.6, 5.0, 2.6), tone="wood")  # the mouth's timber frame
A.deco("brake_lever", -7.6, 2.2, z=-0.9, size=(0.15, 1.0, 0.15), tone="accent")
for i, (x, y) in enumerate(RIDE[2:-1]):
    A.deco("lantern_mine", x, y + 3.6, z=-1.0, size=(0.3, 0.5, 0.3), tone="gold")
    A.light(x, y + 3.2, color="#FFB860", rng=10.0, energy=1.5, flicker=True)
A.cam((-152, -16, -30, 9), half_h=4.6)

if __name__ == "__main__":
    save_meta()
    A.save()
