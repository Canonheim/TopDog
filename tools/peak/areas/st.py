"""
ST: the mountain's shared structure. The well (El Pozo), the outer slope below the
cliffs, El Colmillo's lower half, La Garganta and La Boca, El Tobogan (the slide tube to
the river), the world's edges, and the mountain's own card.
  python tools/peak/areas/st.py
"""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from peaklib import Area, box_pts, save_meta

A = Area("st", "cliffs")

# The east face: (x, y) from the trailhead to the summit, and the west face back down.
EAST = [(-34, 5.5), (-60, 60), (-90, 150), (-130, 260), (-150, 322), (-174, 400), (-180, 400), (-230, 578),
        (-251, 684), (-281, 784), (-307, 884), (-334, 962), (-350, 1000)]
WEST = [(-372, 950), (-430, 800), (-520, 550), (-620, 250), (-700, 0)]


def tube(centre, width, kind="scree"):
    """A slick pipe of air along `centre`, open at both ends."""
    left, right = [], []
    n = len(centre)
    for i, p in enumerate(centre):
        a = centre[max(0, i - 1)]
        b = centre[min(n - 1, i + 1)]
        dx, dy = b[0] - a[0], b[1] - a[1]
        L = math.hypot(dx, dy)
        nx, ny = -dy / L, dx / L
        left.append((p[0] + nx * width / 2, p[1] + ny * width / 2))
        right.append((p[0] - nx * width / 2, p[1] - ny * width / 2))
    air = left + right[::-1]
    kinds = {n - 1: None, len(air) - 1: None}  # the two ends
    A.cave(air, kinds, default=kind, thick=3.0)


# ---------------------------------------------------------------- El Pozo del Diablo
# Its walls where no area stands beside it, with the six doors left open.
for x0, x1, spans in (
    (-310.0, -306.0, [(176, 264), (278, 362), (382, 474), (488, 498)]),  # west wall
    (-294.0, -290.0, [(176, 262), (280, 364), (380, 474), (488, 498)]),  # east wall
):
    for y0, y1 in spans:
        A.solid([(x0, y0), (x1, y0), (x1, y1), (x0, y1)], "wet")
A.solid([(-310, 494), (-290, 494), (-290, 498), (-310, 498)], "wet")  # the cap over the well room
A.card([(-312, 170), (-288, 170), (-288, 500), (-312, 500)], z=-5.0, tone="#0B0A10")

# ---------------------------------------------------------------- the outer slope, slick scree
# Below La Boca's east rim: the bare slope down to the trailhead (a body flung far east ends there).
A.wall([(-150, 322), (-130, 260), (-90, 150), (-60, 60), (-34, 5.5)], default="scree", thick=5.0, rock_on="right")
# The face from El Balcon's foot down into La Garganta.
A.wall([(-230, 574), (-180, 400)], default="scree", thick=5.0, rock_on="right")
# El Colmillo's lower half: the fang standing on the slope. Its west side is the throat's other wall.
A.solid([(-174, 400), (-150, 322), (-158, 684), (-172, 684)], "scree")

# ---------------------------------------------------------------- La Boca and El Tobogan
# The mouth at the throat's foot, x -180 to -174, and the tube down to the river's roof.
tube([(-177, 399), (-177, 380), (-174, 330), (-171, 280), (-172, 252), (-262, 178), (-262, 174)], 5.0)

# ---------------------------------------------------------------- the world's edges (unseen)
A.box(-116.0, 675.0, 4.0, 690.0, "void")  # the sky's east wall, above the slope
A.box(-240.0, 1032.0, 300.0, 4.0, "void")  # the lid
A.box(-392.0, 950.0, 4.0, 200.0, "void")  # behind the summit

# ---------------------------------------------------------------- the mountain itself, as one great card
body = EAST + WEST + [(-700, -40), (-34, -40)]
A.card(body, z=-9.0, tone="#8C8273", edge=True)
A.card([(-281, 784), (-307, 884), (-334, 962), (-350, 1000), (-372, 950), (-430, 800), (-380, 770), (-330, 800)], z=-8.8, tone="#F4F7FA")

# ---------------------------------------------------------------- the sky outside: cardboard clouds, far and near
import random
_r = random.Random(7)
for i in range(34):
    y = 540 + i * 14 + _r.uniform(-5, 5)
    face_x = -230 - (y - 578) * 0.27  # roughly where the east face is at this height
    x = face_x + _r.uniform(20, 130)
    A.deco("cloud_" + "abcde"[i % 5], x, y, z=-_r.uniform(26, 80), scale=_r.uniform(1.4, 3.2), size=(8, 3, 0.2), tone="#FFFFFF")

if __name__ == "__main__":
    save_meta()
    A.save()
