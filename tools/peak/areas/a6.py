"""
A6 LA CHIMENEA: the steam chimney. An old forge inside the mountain: heat, then the sky.
  python tools/peak/areas/a6.py

The room is one tall furnace hall (x -291 .. -236, y 478 .. 541) under a flue that narrows
to the crack and the door to daylight at (-234, 580). Everything hangs in the open hall, so
a miss falls to the floor by the well mouth (cost A). The upper flue sheds its fallers down
the forge hood (a slick 35 degree slab) and off its spout into the same fall line.
"""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from peaklib import Area, box_pts

A = Area("a6", "chimney")
SKY = "#58A8F0"

# ---------------------------------------------------------------- the shell (the AIR's outline)
AIR = [
    (-291.0, 480.0),  # 0 floor, at the door: the high end, so a faller rolls EAST, away from the well
    (-262.0, 478.0),  # 1 floor's low point, mid hall
    (-236.0, 479.2),  # 2 east wall, foot
    (-236.0, 566.0),  # 3 east wall
    (-234.0, 574.0),  # 4 the wall leans to the face
    (-234.0, 579.4),  # 5 under the exit sill           edge 5 = the EXIT DOOR
    (-234.0, 586.0),  # 6 the door's lintel
    (-234.0, 587.0),  # 7 the crack's roof, at the face
    (-239.0, 582.5),  # 8 crack roof
    (-244.0, 578.5),  # 9 crack roof
    (-252.0, 577.0),  # 10 the flue's crown
    (-257.0, 566.0),  # 11 flue, west wall (it leans in over the climb)
    (-262.0, 541.0),  # 12 the hall's roof meets the flue
    (-291.0, 541.0),  # 13 hall roof, west
    (-291.0, 488.0),  # 14 west wall, top of the entry door   edge 14 = the ENTRY DOOR
]
A.cave(AIR, {0: "rock", 1: "rock", 5: None, 14: None}, default="wet", thick=3.0)
A.opening(-295, 474, -291, 488)  # the well mouth (from A5)
A.opening(-235, 580, -230, 586)  # daylight (to A7's Balcon)

# The entry landing: my 3 m slab under the door (flush with the well at x -294), and the
# grip ledge the censer drops you on, lipping 1.5 m out over the well.
A.solid([(-294.0, 474.0), (-291.0, 474.0), (-291.0, 479.4), (-294.0, 479.4)], "wet")
A.solid([(-295.5, 479.55), (-294.0, 479.0), (-290.9, 479.0), (-290.9, 480.0), (-295.5, 480.0)], "rock")
A.hold(-294.6, 480.1, 0.2, "wet")  # the unease: a wet knuckle on the lip


def ring(x, y, r=0.25):
    """An iron ring on a wall or in the air: a hold."""
    return A.hold(x, y, r, "iron", n=8)


# ---------------------------------------------------------------- 6.1 Primer Vapor
# A grate in the floor under the iron pug mask. Column 3.5 m, then a throw of 4.5 m
# (speed = sqrt(2 x 2.79 x 4.5) = 5.01): 8 m in all, to the chain that hangs from the mask's
# nose ring and the mask's tongue (L1, top 486) beside it.
A.ledge(-283.0, -280.0, 479.5, "iron", t=0.5)  # the grate
A.geyser(-281.5, 479.5, 2.0, 3.5, 5.01, period=5.0, on=2.0, phase=0.0, warn=1.2)
ring(-281.5, 491.6, 0.3)  # the nose ring
A.rope("c61", (-281.5, 491.3), 4.6, kind="chain")  # hangs to y 486.7, in the column's top
A.ledge(-280.3, -276.4, 486.0, "iron", t=0.5)  # L1, the tongue
A.hold(-280.25, 486.02, 0.16, "grease")  # a bead of grease on its lip
A.challenge("6.1", "Primer Vapor", (-281.5, 479.5), 2, "S",
            moves=[["reach", [-281.5, 487.0], [-280.3, 486.0]]])
A.cam((-290, 478, -272, 494), half_h=8.0, bias=(0.0, 2.5))

# ---------------------------------------------------------------- 6.2 Piedra Caliente
# The furnace's glowing face: hot nubs (1.2 s each) from L1's east end up and out over the
# open hall to L2 (top 496). Three cool rock nubs are the rests. Nothing is under it but the floor.
HOT = [(-276.2, 487.5, "hot"), (-275.3, 488.3, "hot"), (-275.6, 489.4, "hot"), (-274.6, 490.0, "rock"),
       (-273.7, 490.8, "hot"), (-274.0, 491.9, "hot"), (-273.0, 492.5, "hot"), (-272.9, 493.6, "rock"),
       (-273.7, 494.4, "hot"), (-272.8, 495.0, "hot"), (-273.0, 496.1, "rock"), (-272.2, 496.9, "hot")]
for x, y, k in HOT:
    A.hold(x, y, 0.3 if k == "rock" else 0.22, k)
A.ledge(-271.5, -266.8, 496.0, "rock", t=0.6)  # L2
A.hold(-271.4, 496.02, 0.15, "wet")  # a hiss of condensation on its lip
_route = [[-276.8, 487.6]] + [[x, y] for x, y, _ in HOT] + [[-271.5, 496.0]]
A.challenge("6.2", "Piedra Caliente", (-277.4, 486.0), 3, "A",
            moves=[["reach", _route[i], _route[i + 1]] for i in range(len(_route) - 1)])
A.cam((-279, 485, -269, 498), half_h=9.0, bias=(0.0, -3.0))

# ---------------------------------------------------------------- 6.3 Geiseres Gemelos
# Vent A is a grate in L2. Vent B is a pipe mouth 5 m east with a slick funnel round it and
# NOTHING to stand on: its throat (2.4 m) drops to the floor. A draught (1.0 m/s2 east)
# between the two is the drift. (The game: a vent is on while (clock + phase) mod period < on,
# it only pushes while it is on, and it damps sideways speed inside its column.)
#   Both periods 7.0 s. A blows t = 0.0 .. 1.5 (phase 0).  B blows t = 3.5 .. 6.7 (phase 3.5).
#   A: column 4 m at 5.0 m/s, then a throw of 4.5 m (apex y 504.4, 1.8 m east). Loose on
#   the grate at t0, the body is over B's funnel (x -264, y 503) at t0 + 3.5 with 2.9 m/s
#   of drift. B: column 9 m at 4.0 m/s, throw 2.9 m: apex y 510.9 at x -262, where the
#   chain's last 3 m hang.
#   t0 = 0.0 .. 0.9 works (B is on from 3.5 and stays on until the latest of them is out of
#   its column). Let go later than about 1 s into A's blast and it dies under you: you
#   come down short of the funnel's west plate, to the floor.
A.ledge(-269.0, -267.0, 496.05, "iron", t=0.3)  # A's grate, set in L2
A.geyser(-268.0, 496.0, 2.0, 4.0, 5.0, period=7.0, on=1.5, phase=0.0, warn=1.0)
A.wind((-269.2, 500.0, -264.2, 508.0), (1.0, 0.0), look="steam")
A.beam((-264.2, 500.8), (-265.7, 502.06), 0.5, "grease")  # B's funnel, west plate (40 degrees)
A.beam((-261.8, 500.8), (-258.8, 503.3), 0.5, "grease")  # east plate
A.geyser(-263.0, 499.0, 2.4, 9.0, 4.0, period=7.0, on=3.2, phase=3.5, warn=1.0)
ring(-262.1, 514.75, 0.28)  # the hook the chain hangs from (it hangs off the slag pan above)
A.rope("c63", (-262.1, 514.5), 7.0, kind="chain")  # to y 507.5
A.ledge(-267.6, -263.5, 512.0, "rock", t=0.6)  # L3
A.hold(-267.5, 512.02, 0.15, "wet")  # the slag pan sweats on it
A.challenge("6.3", "Géiseres Gemelos", (-270.4, 496.0), 4, "A",
            moves=[["reach", [-262.1, 511.8], [-263.5, 512.0]]])
A.cam((-272, 494, -256, 516), half_h=11.0, bias=(0.0, -2.0))

# ---------------------------------------------------------------- 6.4 El Fuelle
# Three bellows going west from L3, each a step that swells 1.8 m and folds (cycle 4.2 s:
# 1.6 up, 0.8 full, 1.0 down, 0.8 flat; each 1.4 s behind the last). The great bellows on
# the west wall blows EAST through them, back the way you came: 1.4 s on, 2.6 s off.
for i, (bx, by) in enumerate(((-270.0, 512.8), (-273.4, 514.8), (-276.8, 516.8))):
    A.mover("fuelle%d" % (i + 1), (bx, by),
            [(box_pts(0, -0.175, 2.2, 0.35), "plank"), (box_pts(0, -0.95, 1.8, 1.2), "grease")],
            {"type": "cycle", "to": [0.0, 1.8], "t_out": 1.6, "hold_out": 0.8, "t_in": 1.0, "hold_in": 0.8,
             "phase": 1.4 * i}, model="bellows")
A.wind((-284.0, 513.0, -268.0, 520.5), (4.0, 0.0), gust={"on": 1.4, "off": 2.6, "phase": 0.0, "warn": 0.8}, look="steam")
A.ledge(-288.0, -279.2, 519.5, "plank", t=0.6)  # L4, the great bellows' top board
A.hold(-279.3, 519.52, 0.15, "grease")
for y in (520.9, 522.0, 523.1, 524.2):
    A.beam((-286.4, y), (-285.6, y), 0.22, "iron")  # rungs up to the slag pan's shore
A.ledge(-285.0, -280.3, 525.2, "iron", t=0.6)  # the shore
A.challenge("6.4", "El Fuelle", (-266.2, 512.0), 3, "A",
            moves=[["reach", [-267.6, 512.0], [-268.9, 512.8]], ["reach", [-271.1, 514.6], [-272.3, 514.8]],
                   ["reach", [-274.5, 516.6], [-275.7, 516.8]], ["reach", [-277.9, 518.6], [-279.2, 519.5]],
                   ["reach", [-286.0, 524.2], [-285.0, 525.2]]])
A.cam((-290, 510, -262, 524.5), half_h=8.0, bias=(0.0, -2.0))


# ---------------------------------------------------------------- 6.5 Escoria
# A run of slag in a tilted iron pan (8 degrees, low end east). Its surface is a bounce line
# that throws whatever touches it (5 m/s, knocked out) up and a little EAST each time, so a
# body is walked down the run and off its east lip, into the hall's fall line and the floor.
# Three iron rafts ride it back and forth (grip). The two black crusts between them are dead.
PW, PE = (-280.3, 524.6), (-263.6, 522.3)


def slag_y(x):
    return PW[1] + (x - PW[0]) * (PE[1] - PW[1]) / (PE[0] - PW[0])


A.solid([PW, PE, (PE[0], PE[1] - 1.1), (PW[0], PW[1] - 1.1)], "slag")  # the pan and its slag
A.bounce(PW, PE, 5.0, look="lava", min_in=0.0, ko=True)
for i, (xa, xb, sp, wt, ph) in enumerate(((-278.8, -276.8, 0.7, 0.8, 0.0), (-273.2, -270.8, 1.0, 0.6, 1.3),
                                          (-267.2, -265.0, 0.8, 0.7, 2.9))):
    pa, pb = [xa, slag_y(xa) + 0.5], [xb, slag_y(xb) + 0.5]  # raft 0.5 thick: its top rides 0.75 over the slag
    A.mover("balsa%d" % (i + 1), pa, [(box_pts(0, 0, 2.2, 0.5), "iron")],
            {"type": "path", "pts": [pa, pb], "speed": sp, "mode": "pingpong", "wait": wt, "phase": ph})
for cx in (-275.0, -269.0):
    y = slag_y(cx)
    A.solid([(cx - 0.4, y - 0.1), (cx + 0.4, y - 0.1), (cx + 0.05, y + 0.6)], "slag")  # dead crust: a slick tooth, nothing to stand on
ring(-262.3, 529.25, 0.28)
A.rope("c65", (-262.3, 529.0), 5.6, kind="chain")  # the way off the last raft (and one last chance for a faller)
A.ledge(-259.2, -256.2, 523.0, "rock", t=0.6)  # L5
A.hold(-259.1, 523.02, 0.15, "wet")
A.challenge("6.5", "Escoria", (-282.6, 525.2), 4, "A",
            moves=[["reach", [-280.3, 525.2], [-279.9, 525.14]], ["reach", [-275.7, 524.9], [-274.3, 524.6]],
                   ["reach", [-269.7, 524.0], [-268.3, 523.7]], ["reach", [-263.9, 523.25], [-262.3, 523.9]],
                   ["fling", [-262.3, 524.0], [-259.2, 523.0], "F1"]])
A.cam((-286, 521, -255, 533), half_h=9.0, bias=(0.0, -3.0))

# ---------------------------------------------------------------- 6.6 La Fragua
# Three drop hammers over three anvils, a stair going east. Each hammer hangs a chain off
# its east lug: the chain is the only way from one anvil up to the next (4 m), and it is
# only up there while the hammer is. Cycle 7.15 s: 3.2 rising, 2.6 up, 0.35 falling (12 m/s,
# it knocks you out), 1.0 down, 0.8 m over the anvil. Hammer 1 starts up at t = 0, hammer 2
# at 4.75, hammer 3 at 9.5 (phases 0, 2.4, 4.8). To cross an anvil you walk under its hammer.
HX, HY = (-253.5, -249.3, -245.1), (523.6, 527.6, 531.6)
for i in range(3):
    X, Y = HX[i], HY[i]
    A.ledge(X - 1.5, X + 1.0, Y, "iron", t=0.5)  # the anvil's face
    A.solid([(X - 0.8, Y - 0.5), (X + 0.7, Y - 0.5), (X + 0.3, Y - 1.5), (X - 0.4, Y - 1.5)], "slag")  # its waist
    A.mover("martillo%d" % (i + 1), (X, Y + 0.8),
            [(box_pts(0, 0.75, 2.0, 1.5), "grease"), ([(-1.0, 1.5), (1.0, 1.5), (0.0, 2.2)], "grease"),
             (box_pts(1.25, 0.15, 0.5, 0.2), "iron")],
            {"type": "cycle", "to": [0.0, 4.2], "t_out": 3.2, "hold_out": 2.6, "t_in": 0.35, "hold_in": 1.0,
             "phase": 2.4 * i}, ko=True, model="drop_hammer")
    A.rope("c66_%d" % (i + 1), (X + 1.5, Y + 0.85), 4.5, kind="chain", anchor="martillo%d" % (i + 1))
A.ledge(-242.4, -236.0, 535.6, "rock", t=0.6)  # L6
A.challenge("6.6", "La Fragua", (-257.6, 523.0), 4, "A",
            moves=[["reach", [-256.2, 523.0], [-255.0, 523.6]], ["reach", [-252.5, 523.6], [-252.0, 524.4]],
                   ["reach", [-252.0, 527.8], [-250.8, 527.6]], ["reach", [-248.3, 527.6], [-247.8, 528.4]],
                   ["reach", [-247.8, 531.8], [-246.6, 531.6]], ["reach", [-244.1, 531.6], [-243.6, 532.4]],
                   ["reach", [-243.6, 535.8], [-242.4, 535.6]]])
A.cam((-260, 521, -236, 540), half_h=9.0, bias=(0.0, -2.0))

# ---------------------------------------------------------------- the forge hood (the upper flue's floor)
# A slick slab at 35 degrees from the updraft shaft's window down to a spout at (-258.5, 531).
# Whatever falls in the flue above lands on it, slides west and is thrown off the spout
# into the hall: over the slag run or past the last-chance chain, and so to the floor.
A.solid([(-241.5, 542.9), (-258.5, 531.0), (-258.5, 530.4), (-241.5, 542.3)], "wet")

# ---------------------------------------------------------------- 6.7 Tiro de Chimenea
# The updraft shaft, x -241 .. -236 from L6 to L7 (13.4 m), between the hall's east wall and
# a black baffle. The draught is steady, 3.6 m/s2 up (gravity 2.79): let go and you rise at
# 0.81 m/s2. Half way up there is a window in the baffle (y 543 .. 546) and a cross-gust
# that sucks WEST through it: 6 m/s2 for 1.5 s in every 5.0 (it blows t = 0 .. 1.5, the
# whistle 0.9 s before). Loose in that band when it blows and you go out of the window, down
# the hood, to the floor. The iron rings on the east wall are the anchors:
#   staging ring (y 541.6) to the ring in the band (544.3): 2.6 s adrift, the last 0.7 s in the band.
#   that ring to the one above the band (547.3): 2.7 s. The lull is 3.5 s, so each leg must
#   start within 0.8 s of the gust dying. (A flyer from L6 with the timing right goes straight through.)
# Then three rings across the shaft's head, weightless in the draught, to L7's lip.
A.solid([(-241.5, 540.0), (-241.0, 540.0), (-241.0, 543.4), (-241.5, 542.9)], "wet")  # baffle, under the window
A.solid([(-241.5, 546.0), (-241.0, 546.0), (-241.0, 548.4), (-241.5, 548.4)], "wet")  # baffle, over it
A.wind((-241.0, 536.0, -236.0, 548.6), (0.0, 3.6), look="steam")
A.wind((-241.5, 542.9, -236.0, 546.1), (-6.0, 0.0), gust={"on": 1.5, "off": 3.5, "phase": 0.0, "warn": 0.9})
E_RINGS = [(-236.3, 538.6), (-236.3, 541.6), (-236.3, 544.3), (-236.3, 547.3)]
T_RINGS = [(-237.6, 548.2), (-238.9, 548.8), (-240.1, 549.3)]
for x, y in E_RINGS + T_RINGS:
    ring(x, y)
A.ledge(-245.8, -241.0, 549.0, "rock", t=0.6)  # L7
_r = [E_RINGS[3]] + T_RINGS + [(-241.0, 549.0)]
A.challenge("6.7", "Tiro de Chimenea", (-241.9, 535.6), 3, "A",
            moves=[["reach", [-237.0, 537.6], [-236.3, 538.6]]] +
                  [["reach", list(_r[i]), list(_r[i + 1])] for i in range(4)])
A.cam((-246, 534, -234, 552), half_h=8.5, bias=(-1.5, 0.0))

# ---------------------------------------------------------------- 6.8 El Ultimo Aliento
# Three vents, each 8.2 m over the last and 1.8 m west: a 4.5 m column at 4.54 m/s (1.05 s)
# and a throw of 3.7 m, to an iron ring at the top of the throw and the next vent's grate
# (1.2 m of iron) beside it. 24.6 m in three breaths. All periods 6.0 s.
#   Vent 1 blows t = 0.0 .. 2.0   (phase 0):   0.95 s to be loose in the column.
#   Vent 2 blows t = 4.0 .. 5.6   (phase 2.0): 0.55 s.
#   Vent 3 blows t = 8.0 .. 9.35  (phase 4.0): 0.30 s.
#   One clean run: off vent 1 at t = 0, on ring 1 at 2.7, across to grate 2 by 4.0, ring 2 at
#   6.7, grate 3 by 8.0, the last ring and L8 at 10.7. Miss a blast and the next is 6 s away,
#   standing on 1.2 m of iron over the hood.
A.ledge(-245.6, -244.0, 549.05, "iron", t=0.3)  # vent 1's grate, set in L7
A.geyser(-244.8, 549.0, 1.6, 4.5, 4.54, period=6.0, on=2.0, phase=0.0, warn=1.0)
ring(-245.25, 557.9)
A.ledge(-247.2, -246.0, 557.2, "iron", t=0.4)  # grate 2
A.geyser(-246.6, 557.2, 1.4, 4.5, 4.54, period=6.0, on=1.6, phase=2.0, warn=0.9)
ring(-247.05, 566.1)
A.ledge(-249.0, -247.8, 565.4, "iron", t=0.4)  # grate 3
A.geyser(-248.4, 565.4, 1.4, 4.5, 4.54, period=6.0, on=1.35, phase=4.0, warn=0.8)
ring(-247.95, 573.5)
A.ledge(-247.4, -243.4, 572.5, "rock", t=0.6)  # L8, the crack's doorstep
A.hold(-247.3, 572.52, 0.15, "wet")
A.challenge("6.8", "El Último Aliento", (-242.2, 549.0), 5, "A",
            moves=[["reach", [-245.25, 557.9], [-246.0, 557.2]], ["reach", [-247.05, 566.1], [-247.8, 565.4]],
                   ["reach", [-247.95, 573.5], [-247.4, 572.5]]])
A.cam((-252, 547, -241.6, 575), half_h=12.0, bias=(0.0, -4.0))

# ---------------------------------------------------------------- 6.9 La Luz
# The crack to daylight: two cool rock steps, the chockstone over a slick pipe, the sill.
# The chockstone is rotten: 1.2 s and it goes (back in 8 s). Three nubs over the pipe are
# the way when it is gone. The pipe drops into the top of the updraft shaft: the draught
# sets you down on L6, two challenges back.
A.solid([(-243.4, 554.0), (-240.0, 554.0), (-240.0, 575.0), (-241.7, 575.0), (-241.7, 573.5), (-243.4, 573.5)], "wet")
A.ledge(-243.4, -241.7, 574.0, "rock", t=0.5)  # step 1
A.ledge(-241.7, -240.0, 575.5, "rock", t=0.5)  # step 2
A.solid([(-237.2, 571.0), (-236.0, 566.0), (-234.0, 574.0), (-234.0, 579.4), (-237.2, 579.4)], "wet")  # under the sill
A.solid([(-237.2, 579.4), (-231.0, 579.4), (-231.0, 580.0), (-237.2, 580.0)], "rock")  # the sill, out through the door
A.solid([(-240.05, 575.5), (-237.15, 576.2), (-237.15, 577.0), (-240.05, 577.0)], "rotten")  # the chockstone
for x, y in ((-239.5, 577.15), (-238.4, 578.1), (-237.45, 578.9)):
    A.hold(x, y, 0.2, "rock")
A.challenge("6.9", "La Luz", (-245.2, 572.5), 2, "B",
            moves=[["reach", [-243.4, 572.5], [-243.4, 574.0]], ["reach", [-241.7, 574.0], [-241.7, 575.5]],
                   ["reach", [-240.0, 575.5], [-239.5, 577.15]], ["reach", [-239.5, 577.15], [-238.4, 578.1]],
                   ["reach", [-238.4, 578.1], [-237.45, 578.9]], ["reach", [-237.45, 578.9], [-237.2, 580.0]]])
A.cam((-249, 571, -230, 588), half_h=6.5, bias=(2.0, 1.0))
A.cam((-296, 476, -236, 484), half_h=6.0, bias=(0.0, 2.0))

# ---------------------------------------------------------------- the picture
# Back to front: the mountain's dark (z -6), the far forge (z -4.5), the glow of fires (z -3),
# the sky and its shaft of light (z -5 .. -2.5), and soot curtains in front (z 3).
A.card([(-297, 470), (-228, 470), (-228, 592), (-297, 592)], z=-6.0, tone="back2", edge=False)
A.card([(-291, 478), (-236, 478), (-236, 500), (-262, 508), (-291, 498)], z=-4.6, tone="back3")  # the forge floor's far wall
A.card([(-291, 506), (-268, 512), (-262, 541), (-291, 541)], z=-4.5, tone="back")  # the bellows loft
A.card([(-262, 541), (-236, 520), (-236, 566), (-257, 566)], z=-4.4, tone="back3")  # the flue's throat
A.card([(-279.5, 485.0), (-270.0, 485.5), (-268.5, 499.0), (-278.0, 498.5)], z=-3.0, tone="#8A2E14")  # the furnace face (6.2)
A.card([(-277.5, 487.0), (-271.5, 487.5), (-270.5, 497.0), (-276.5, 496.5)], z=-2.8, tone="#C4481A")
A.card([(-282.0, 521.0), (-262.0, 519.0), (-262.0, 523.0), (-282.0, 525.5)], z=-2.6, tone="#E8641C")  # the slag's glow
A.card([(-263.6, 522.3), (-262.9, 522.3), (-262.6, 499.5), (-263.4, 499.5)], z=-2.4, tone="accent")  # the slag's drip off the lip, into vent B
for x in (-253.5, -249.3, -245.1):
    A.card([(x - 0.25, 541.0), (x + 0.25, 541.0), (x + 0.25, 524.0), (x - 0.25, 524.0)], z=-2.0, tone="back3", edge=False)  # hammer guides
# La Luz: a slit of sky that widens up the last 20 m, and the light it throws down the flue.
A.card([(-246.6, 566.0), (-246.3, 566.0), (-242.6, 573.0), (-243.6, 573.0)], z=-5.0, tone=SKY, edge=False)
A.card([(-243.6, 573.0), (-242.6, 573.0), (-238.0, 579.0), (-240.4, 579.0)], z=-5.0, tone=SKY, edge=False)
A.card([(-240.4, 579.0), (-238.0, 579.0), (-229.0, 579.6), (-229.0, 588.5), (-237.0, 586.0)], z=-5.0, tone=SKY, edge=False)
A.card([(-234.0, 580.0), (-234.0, 586.0), (-249.0, 566.0), (-250.5, 562.0)], z=-4.0, tone="#E9D9B8", edge=False)  # the light shaft
A.card([(-250.5, 562.0), (-249.0, 566.0), (-254.0, 552.0), (-254.6, 550.0)], z=-4.0, tone="#B88A68", edge=False)  # ... dying into the red
A.card([(-291, 536), (-262, 536), (-262, 541), (-291, 541)], z=3.0, tone="slick")  # soot under the hall's roof
A.card([(-291, 470), (-236, 470), (-236, 477.6), (-291, 477.6)], z=3.0, tone="back3")  # the floor's front lip

A.deco("pug_mask_iron", -281.5, 483.6, z=-1.2, size=(8.0, 9.0, 0.6), tone="iron")  # cast over the first vent: the chain is its nose ring
A.deco("steam_grate", -281.5, 479.5, z=0.0, size=(2.5, 0.3, 1.5), tone="iron")
A.deco("steam_grate", -268.0, 496.05, z=0.0, size=(2.0, 0.3, 1.5), tone="iron")
A.deco("steam_grate", -244.8, 549.05, z=0.0, size=(1.6, 0.3, 1.5), tone="iron")
A.deco("steam_grate", -246.6, 557.2, z=0.0, size=(1.2, 0.3, 1.5), tone="iron")
A.deco("steam_grate", -248.4, 565.4, z=0.0, size=(1.2, 0.3, 1.5), tone="iron")
A.deco("vent_pipe", -263.0, 478.1, z=-1.4, size=(2.2, 21.0, 2.2), tone="iron")  # vent B's standpipe, floor to mouth
A.deco("bellows_great", -287.5, 513.2, z=-1.0, size=(7.0, 6.0, 2.5), tone="wood")  # its nozzle points east
A.deco("anvil", -286.5, 479.7, z=-1.0, size=(1.2, 0.9, 0.6), tone="iron")
A.deco("anvil", -240.0, 479.1, z=-1.0, size=(1.2, 0.9, 0.6), tone="iron")
for x, y in ((-253.5, 523.6), (-249.3, 527.6), (-245.1, 531.6)):
    A.deco("anvil_great", x - 0.25, y - 1.6, z=-0.2, size=(2.6, 1.6, 1.2), tone="iron")
A.deco("slag_pan_chains", -272.0, 524.0, z=-1.0, size=(17.0, 17.0, 0.3), tone="iron")  # the pan hangs from the roof
A.deco("forge_hood_ribs", -250.0, 537.0, z=-0.6, size=(17.5, 12.5, 0.4), tone="iron")
A.deco("tongs_rack", -290.2, 483.0, z=-1.0, size=(0.4, 3.0, 1.6), tone="iron")
A.deco("papel_tatters", -262.0, 539.6, z=-1.6, size=(10.0, 1.0, 0.05), tone="accent")  # scorched bunting: the town was here
A.deco("torch_wall", -290.4, 485.5, z=-1.0, size=(0.4, 1.2, 0.4), tone="gold")
A.deco("torch_wall", -236.6, 484.0, z=-1.0, size=(0.4, 1.2, 0.4), tone="gold")
A.statue(-238.6, 479.55, "sit", flip=True)  # one who tried: he sits by the cold anvil, facing the well
A.statue(-246.6, 573.45, "reach")  # and one who nearly had it: on the last doorstep, a hand toward the light

for x, y, col, e, r in ((-289.0, 484.0, "#FFB060", 1.6, 10.0), (-281.5, 489.0, "#FF7A30", 1.7, 10.0), (-274.0, 492.0, "#FF4A1C", 2.0, 9.0),
                        (-268.0, 499.5, "#FF9A50", 1.5, 9.0), (-262.5, 507.0, "#FF9A50", 1.4, 9.0), (-266.0, 515.5, "#FFB060", 1.5, 9.0),
                        (-277.0, 520.5, "#FFB060", 1.4, 10.0), (-272.0, 527.5, "#FF5A1C", 2.2, 13.0), (-257.6, 526.5, "#FFB060", 1.5, 9.0),
                        (-249.3, 533.0, "#FF8A40", 1.6, 11.0), (-239.0, 539.0, "#FFA050", 1.5, 9.0), (-238.5, 546.0, "#FFA050", 1.3, 8.0),
                        (-244.0, 552.5, "#FFC080", 1.4, 9.0), (-247.0, 561.0, "#FFD8A8", 1.4, 9.0), (-248.5, 569.0, "#F4E6D0", 1.6, 10.0),
                        (-241.0, 579.0, "#DCEBFF", 2.2, 12.0), (-235.0, 583.0, "#FFFFFF", 2.6, 12.0), (-262.0, 480.5, "#FF7A30", 1.3, 12.0),
                        (-246.0, 481.5, "#FF7A30", 1.2, 11.0)):
    A.light(x, y, color=col, rng=r, energy=e, flicker=y < 560)
A.effect("embers", (-291, 478, -236, 532), density=0.5)
A.effect("embers", (-281, 522, -262, 530), density=1.5)
A.effect("steam", (-283, 479.5, -280, 488))
A.effect("steam", (-264.5, 499, -261.5, 512))
A.effect("steam", (-241, 536, -236, 550), density=0.6)
A.effect("drips", (-291, 478, -288, 541), density=0.3)
A.effect("dust", (-252, 560, -234, 587), tone="#FFF2D0")  # motes in the shaft of daylight

if __name__ == "__main__":
    A.save()
