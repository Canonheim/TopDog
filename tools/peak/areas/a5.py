"""
A5 EL TEMPLO DEL PRIMER PERRO: the buried temple of the First Top Dog.
  python tools/peak/areas/a5.py

The plan (x negative = west, into the mountain):
  LOWER HALL  y 366..400   the door (5.1 stairs west), the mask (5.2), the brow walk
  THE WORKS   y 396..430   the piston shaft (5.3) and the gear room (5.4), far west
  GREAT HALL  y 430..450   the champions (5.5) and the censers (5.6), heading back east
                           over a slick ramp that pours down a drain to the entry floor
  GALLERY     y 453        the walk west along the hall's roof (the breath)
  UPPER WORKS y 453..473   the counterweight (5.7), the serpent (5.8), the phantom
                           blocks (5.9), heading east again
  THE ALTAR   y 469..480   the turning cross (5.10), then the well room (5.11)
In a side view nothing can stand on a slope without damming it, so the stairs, the mask
and the champions are carried by the back wall (cards): they float clear of the chutes.

Clock notes (what this file assumes of the engine; AUTHORING.md's table):
  cycle `phase` p: the mover begins going out p seconds after the clock's zero.
  swing: angle = amp x sin(2 pi (t / period + phase)), + is toward +x (east).
"""
import math, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from peaklib import Area, box_pts, ngon

A = Area("a5", "temple")
GOLD = "#FFC060"


def torch(x, y, rng=10.0, energy=1.6):
    A.deco("torch_wall", x, y, z=-0.9, size=(0.4, 1.2, 0.4), tone="gold")
    A.light(x, y + 0.6, color=GOLD, rng=rng, energy=energy, flicker=True)


def mask(x, y, w, h, z=-2.0, tone="accent"):
    """A carved luchador-dog mask of the First Top Dog (scenery)."""
    A.deco("pug_mask", x, y, z=z, size=(w, h, 0.4), tone=tone)


# ================================================================ the shell
# The AIR's outline. Edge i runs pts[i] -> pts[i+1].
SHELL = [(-309, 366), (-342, 366), (-372, 385.5), (-372, 411), (-374.5, 414.5), (-374.5, 434),
         (-366, 434), (-366, 466.5), (-341, 466.5), (-341, 473), (-323.5, 473), (-323.5, 484),
         (-309, 484), (-309, 479), (-309, 382)]
A.cave(SHELL, {0: "stone",   # the entry floor: every great fall inside the temple ends here
               12: None,     # the exit door, onto the well's mouth
               14: None},    # the entry door, onto the well
       default="wet", thick=3.0)
A.opening(-309, 362, -305, 382)   # ENTRY, from the Pozo (a4's mushroom throws you at it)
A.opening(-309, 474, -305, 488)   # EXIT, the well's mouth

# ---- the entry door: sill, beam, the two banner chains a4's throw is caught on
A.solid([(-309.1, 362), (-304, 362), (-304, 366), (-309.1, 366)], "stone")      # the grip sill, top y 366
A.solid([(-310, 379.7), (-303.5, 379.7), (-303.5, 380.3), (-310, 380.3)], "stone")  # the banner beam, out into the well
A.solid([(-310, 380.3), (-309, 380.3), (-309, 384.2), (-310, 384.2)], "stone")  # its corbel, up into the hood
A.rope("banner_chain_1", (-303.0, 380.0), 12.0, kind="chain")
A.rope("banner_chain_2", (-301.5, 380.0), 12.0, kind="chain")
A.deco("temple_banner", -303.0, 374.0, z=-0.4, size=(1.1, 11.0, 0.05), tone="accent")
A.deco("temple_banner", -301.5, 374.0, z=-0.5, size=(1.1, 11.0, 0.05), tone="gold")
# The hood over the door: keeps what comes down the drain from bouncing out into the well.
A.solid([(-313, 384), (-309, 384), (-309, 414), (-313, 408)], "wet")
# ---- the exit door: lintel (to the structure's wall at y 488) and the sill block
A.solid([(-309.1, 484), (-306, 484), (-306, 488.2), (-309.1, 488.2)], "wet")
A.solid([(-309.1, 474), (-306, 474), (-306, 479.3), (-309.1, 479.3)], "wet")

# ================================================================ the great masses
# The great hall's floor: a slick ramp (32 degrees) that is also the lower hall's roof.
# Its foot stops 5 m short of the hood: that gap is THE DRAIN, 38 m straight down to the
# entry floor. Every miss in 5.5 and 5.6 goes this way (cost A).
RAMP0, RAMP1 = (-353.0, 429.0), (-318.0, 407.2)
A.solid([(-357.2, 429.0), RAMP0, RAMP1, (-318, 404.0), (-357.2, 425.8)], "wet")


def ramp_y(x):
    return RAMP0[1] + (x - RAMP0[0]) * (RAMP1[1] - RAMP0[1]) / (RAMP1[0] - RAMP0[0])


A.solid([(-366.5, 400), (-357.2, 400), (-357.2, 429.0), (-360.2, 429.0), (-360.2, 411.2), (-366.5, 411.2)], "wet")  # the pier + the gear room's east wall
A.ledge(-368.2, -360.2, 412.0, "stone", t=0.9)    # R3: the pier's top and its cornice (the shaft's last step)
A.ledge(-365.0, -353.0, 430.0, "stone", t=1.0)    # the hall's west balcony
# The hall's roof / the gallery's floor, with two light slots you step over (a look down at the champions).
for x0, x1 in ((-352.0, -338.0), (-336.6, -328.0), (-326.6, -312.8)):
    A.solid([(x0, 450.0), (x1, 450.0), (x1, 452.5), (x0, 452.5)], "wet")
    A.ledge(x0, x1, 453.0, "stone", t=0.5)
# The upper works' spine: the serpent's head ledge, the phantom ramp, the altar's threshold.
A.solid([(-344, 457.5), (-323.5, 457.5), (-323.5, 467.7), (-331.5, 467.7), (-340, 461.7), (-340, 461.1), (-344, 461.1)], "wet")
A.ledge(-344.0, -340.0, 461.7, "stone", t=0.6)    # HL: the serpent's head
A.ledge(-331.5, -323.5, 468.9, "stone", t=1.2)    # TL: the altar's threshold
# The altar's east wall, the exit ledge and the well sill (top y 480).
A.solid([(-312.5, 457), (-309, 457), (-309, 479.3), (-312.5, 479.3)], "wet")
A.ledge(-312.5, -305.6, 480.0, "stone", t=0.8)

# ================================================================ 5.1 La Puerta
# Six giant steps, 2.5 m each, carried by the back wall. Each is a slab 1 m thick: climb the
# next one's front face. Steps 2, 4 and 5 slide back under the step above when you board
# them (1.3 m/s: half gone in a second) and scrape you off against its face. Under the
# stairs runs the drain slope: a miss slides you back to the foot (S).
STEP_X = -332.0
for k in range(1, 6):
    x1 = STEP_X - 3.0 * (k - 1)
    top = 366.0 + 2.5 * k
    if k in (2, 4, 5):
        at = (x1 - 1.5, top - 0.5)
        A.mover("step%d" % k, at, [(box_pts(0, 0, 3.0, 1.0), "stone")],
                {"type": "path", "pts": [list(at), [at[0] - 2.6, at[1]]], "speed": 1.3, "mode": "once",
                 "trigger": "board", "reset": 4.0}, model="temple_step")
    else:
        A.ledge(x1 - 3.0, x1, top, "stone", t=1.0)
A.ledge(-354.0, -347.0, 381.0, "stone", t=1.0)    # the sixth step and the landing before the mask
A.patch((-347.8, 381.0), (-347.0, 381.0), "wet", t=0.12)  # unease: the landing's lip weeps
m51 = []
for k in range(0, 6):
    x1 = STEP_X - 3.0 * k          # the next step's front face
    y = 366.0 + 2.5 * k
    m51 += [["reach", [x1 + 0.3, y], [x1, y + 1.6]], ["reach", [x1, y + 1.6], [x1 - 0.3, y + 2.5]]]
A.challenge("5.1", "La Puerta", (-312.0, 366.0), 2, "S", moves=m51)

# ================================================================ 5.2 La Mascara
# The First Top Dog's mask, 17 m of it (the face is a card; its features are the holds).
# The jaw is a lift: board it at the landing's level, ride it 4.5 m up, and take a tooth
# when it shuts (2.1 m of room is left: it does not bite). Then lip, nostril, cheek, eye,
# brow. Falls outside the jaw go down the gullet: the drain slope under it, back to the
# foot of the stairs (B).
JAW = (-358.15, 380.6)
jaw_shapes = [(box_pts(0, 0, 4.7, 0.8), "stone")]
for dx in (-1.9, 1.9):
    jaw_shapes.append((box_pts(dx, 0.6, 0.5, 0.4), "bone"))       # the two lower fangs
A.mover("jaw", JAW, jaw_shapes, {"type": "cycle", "to": [0, 4.5], "t_out": 3.0, "hold_out": 1.4,
                                 "t_in": 2.2, "hold_in": 2.4, "phase": 0.0}, model="mask_jaw")
A.solid([(-359.7, 388.6), (-356.7, 388.6), (-356.7, 389.3), (-359.7, 389.3)], "stone")   # the upper lip
for tx in (-359.3, -358.2, -357.1):
    A.solid([(tx - 0.25, 388.65), (tx, 387.6), (tx + 0.25, 388.65)], "bone")              # the upper teeth
A.hold(-358.9, 391.1, 0.25, "stone")    # nostrils
A.hold(-357.5, 391.1, 0.25, "stone")
A.hold(-356.1, 392.3, 0.25, "stone")    # cheekbones
A.hold(-360.3, 392.3, 0.25, "stone")
A.ledge(-355.4, -353.0, 393.6, "stone", t=0.5)    # the right eye's rim
A.ledge(-363.4, -361.0, 393.6, "stone", t=0.5)    # the left eye's rim
A.ledge(-366.5, -354.2, 396.4, "stone", t=1.2)    # the brow, and the walk west to the pistons
A.patch((-355.0, 396.4), (-354.2, 396.4), "wet", t=0.12)  # unease: its east end is wet
A.challenge("5.2", "La Máscara", (-349.5, 381.0), 3, "B", moves=[
    ["reach", [-354.0, 381.0], [-355.8, 381.0]],       # landing to jaw (it waits low 2.4 s)
    ["reach", [-357.1, 387.6], [-356.7, 389.3]],       # tooth to lip
    ["reach", [-357.5, 389.3], [-357.5, 391.1]],       # lip to nostril
    ["reach", [-357.5, 391.1], [-356.1, 392.3]],       # nostril to cheek
    ["reach", [-356.1, 392.3], [-355.4, 393.6]],       # cheek to eye
    ["reach", [-354.2, 393.6], [-354.2, 395.4]]])      # eye to the brow's end

# ================================================================ 5.3 Los Pistones
# The shaft x -372..-366.5 over the top of the drain slope. A plunger in the brow's end
# lifts you 3.6 m to where the walls begin; then nine pistons, 1.2 m apart in height,
# alternate walls and fire in a wave going up, 2 s apart (period 10 s). Each is out 4 s.
# The piston 2.4 m above yours on the same wall comes out at chest height 3 s after yours
# is fully out: that is the shove. Keep one step ahead of it. A fall goes down the 3.2 m
# slot west of the plunger onto the drain slope and out to the stair foot (B); the
# plunger and the brow catch the lucky (S).
PL = (-367.65, 394.4)
A.mover("plunger", PL, [(box_pts(0, 0, 2.3, 4.0), "stone")],
        {"type": "cycle", "to": [0, 3.6], "t_out": 2.4, "hold_out": 2.5, "t_in": 2.4, "hold_in": 2.7, "phase": 0.0}, model="temple_plunger")
PIST = []   # (id, wall, top y, phase)
for i in range(9):
    PIST.append(("piston%d" % (i + 1), "W" if i % 2 == 0 else "E", 401.2 + 1.2 * i, (1.9 + 2.0 * i) % 10.0))
for pid, wall, top, ph in PIST:
    if wall == "W":
        at, to = (-373.7, top - 0.45), [3.2, 0]     # hidden in the west wall; tip reaches x -368.8
    else:
        at, to = (-364.8, top - 0.45), [-3.2, 0]    # hidden in the pier; tip reaches x -369.7
    A.mover(pid, at, [(box_pts(0, 0, 3.4, 0.9), "stone")],
            {"type": "cycle", "to": to, "t_out": 1.0, "hold_out": 4.0, "t_in": 1.0, "hold_in": 4.0, "phase": ph},
            model="temple_piston", model_flip=(wall == "E"))
m53 = [["reach", [-368.8, 400.0], [-368.8, 401.2]]]
for i in range(8):
    xa = -368.8 if i % 2 == 0 else -369.7
    xb = -369.7 if i % 2 == 0 else -368.8
    m53.append(["reach", [xa, 401.2 + 1.2 * i], [xb, 402.4 + 1.2 * i]])
m53.append(["reach", [-368.8, 410.8], [-368.2, 412.0]])
A.challenge("5.3", "Los Pistones", (-365.0, 396.4), 4, "B", moves=m53)

# ================================================================ 5.4 Engranajes
# Four meshing gears zigzag up the gear room. The disc is greased; only the twelve teeth
# hold. G1 turns counter-clockwise (its east side rises), G2 clockwise, and so on: ride a
# tooth three-quarters round, and change gears BEFORE the mesh, where the teeth close.
# G4's top carries you east onto the hall's balcony. Under G2 and G4 is the piston shaft (B).


def gear(gid, cx, cy, rpm, phase):
    shapes = [(ngon(0, 0, 2.3, 14), "grease")]
    for k in range(12):
        a = k * 30.0
        shapes.append((box_pts(math.cos(math.radians(a)) * 2.65, math.sin(math.radians(a)) * 2.65, 0.9, 0.55, a), "stone"))
    A.mover(gid, (cx, cy), shapes, {"type": "spin", "rpm": rpm, "phase": phase}, model="temple_gear")


GEARS = [("gear1", -364.6, 416.4, 2.5, 0.0), ("gear2", -368.56, 420.36, -2.5, 15.0),
         ("gear3", -364.6, 424.32, 2.5, 0.0), ("gear4", -368.56, 428.28, -2.5, 15.0)]
for g in GEARS:
    gear(*g)
A.patch((-364.4, 412.0), (-363.6, 412.0), "grease", t=0.12)   # unease: grease drips on R3 from the first gear
A.challenge("5.4", "Engranajes", (-360.9, 412.0), 3, "B", moves=[
    ["reach", [-363.0, 412.0], [-363.0, 413.3]],          # R3 up to G1's lowest tooth
    ["reach", [-366.0, 419.2], [-366.4, 418.2]],          # G1's top-west to G2's east teeth
    ["reach", [-367.2, 423.2], [-366.8, 422.1]],          # G2's top-east to G3's west teeth
    ["reach", [-366.0, 427.1], [-366.4, 426.1]],          # G3's top-west to G4's east teeth
    ["reach", [-366.4, 430.5], [-365.0, 430.0]]])         # G4's top-east onto the balcony

# ================================================================ 5.5 El Salon de los Campeones
# Three champions, 9 m tall, arms raised. Each stands clear of the ramp (the back wall
# carries them). Climb one, go out along the east arm to the elbow, take the gilded fist
# (the forearm itself is a card behind the plane, so the fist hangs free: the only thing
# inside its 2.3 m circle is the elbow's tip, 1.85 m away, which the reach needs) and
# fling to the next champion's raised west arm (3 m of forearm and a fist). A miss lands on
# the ramp, slides to its foot and falls 38 m down the drain to the entry floor (A).


def champion(sx, fy, plinth=True):
    # Every solid of the statue names the skin "statue_champion_reach": a model made to
    # exactly these shapes (origin between the feet at (sx, fy), the west arm the catch,
    # the east fist the launch). Until it lands the shapes are drawn as carved stone.
    # (The first models, statue_champion_a/b/c, were made to another pose: their flat
    # climbing shapes stood in front of them. Parker 11-12: "fix the statues".)
    SK = "statue_champion_reach"
    if plinth:
        A.box(sx, fy - 0.6, 2.6, 1.2, "stone")
    A.box(sx, fy + 2.9, 1.8, 5.8, "stone", skin=SK)                       # legs and trunk
    A.box(sx, fy + 5.8, 2.4, 0.8, "stone", skin=SK)                       # shoulders
    A.solid(ngon(sx, fy + 7.0, 0.95, 8, rot=22.5), "stone", skin=SK)      # the masked head
    A.beam((sx - 1.0, fy + 5.9), (sx - 3.2, fy + 7.6), 0.6, "stone", skin=SK)   # the west arm: the catch
    A.solid(ngon(sx - 3.4, fy + 7.75, 0.5, 8), "stone", skin=SK)
    A.beam((sx + 1.0, fy + 5.9), (sx + 2.6, fy + 7.0), 0.5, "stone", skin=SK)   # the east upper arm, to the elbow
    fist = (sx + 4.02, fy + 8.19)
    A.solid(ngon(fist[0], fist[1], 0.45, 8), "gold", skin=SK)             # the fist: the launch hold
    A.solid([(sx + 2.5, fy + 6.75), (sx + 2.7, fy + 7.25), (fist[0] + 0.1, fist[1] + 0.3), (fist[0] + 0.3, fist[1] - 0.2)],
            "stone", ghost=True, skin=SK)                                 # the forearm: drawn, not held
    A.deco(SK, sx, fy, z=0.0, skin=True)
    return fist


F1 = champion(-360.0, 430.0, plinth=False)    # on the balcony
F2 = champion(-347.0, 431.0)
F3 = champion(-331.5, 433.0)
A.challenge("5.5", "El Salón de los Campeones", (-363.5, 430.0), 4, "A", moves=[
    ["reach", [-357.4, 437.0], list(F1)],
    ["fling", list(F1), [-349.0, 437.7], "F2"],            # 7.0 m across, level
    ["reach", [-344.4, 438.0], list(F2)],
    ["fling", list(F2), [-333.5, 439.7], "F3"]])           # 9.5 m across, 0.5 up
A.cam((-366, 404, -309, 450), half_h=13.0, bias=(3.0, -3.0))

# ================================================================ 5.6 Incensarios
# Three censers stepping up to the east balcony, 4.5 m apart, each swinging 1.6 m either
# side, with periods 4, 5 and 6 s so they drift in and out of step. Their chains (rods)
# hold: climb one and reach for the next bob when the two swing together. Under them is
# the ramp's foot and the drain (A).
A.pendulum("censer1", (-324.5, 449.8), 9.6, 9.6, 4.0, phase=0.0, bob=(0.9, 0.8), kind="gold", rod_kind="iron", model="censer_l96")
A.pendulum("censer2", (-320.0, 449.8), 7.8, 11.8, 5.0, phase=0.3, bob=(0.9, 0.8), kind="gold", rod_kind="iron", model="censer_l78")
A.pendulum("censer3", (-315.5, 449.8), 6.0, 15.5, 6.0, phase=0.6, bob=(0.9, 0.8), kind="gold", rod_kind="iron", model="censer_l60")
A.ledge(-312.8, -309.0, 443.6, "stone", t=0.9)               # EB: the east balcony
A.patch((-312.8, 443.6), (-311.9, 443.6), "wet", t=0.12)    # unease: its lip is wet
A.challenge("5.6", "Incensarios", (-331.5, 440.9), 4, "A", moves=[
    ["reach", [-328.9, 440.0], list(F3)],
    ["fling", list(F3), [-326.1, 440.7], "F1"],            # drop onto censer 1 at its west end
    ["reach", [-323.3, 442.5], [-322.05, 442.2]],          # censer 1's chain to censer 2's bob
    ["reach", [-318.9, 444.2], [-317.55, 444.0]],          # censer 2's chain to censer 3's bob
    ["reach", [-313.45, 444.2], [-312.8, 443.6]]])         # censer 3 to the balcony

# ================================================================ the chain and the gallery (the breath)
# From the east balcony a chain hangs in the 3.8 m shaft beside the well wall. Climb it
# 9 m to the gallery, the hall's roof, and walk west 40 m over the champions' heads. Two
# light slots in the floor are a step wide; what they cost is the whole temple.
A.rope("gallery_chain", (-311.0, 457.0), 12.4, kind="chain")

# ================================================================ 5.7 El Contrapeso
# Two slabs on one chain, over the open west end of the great hall (a miss lands on the
# west balcony, 23 m down: back to the champions, B). Slab A sinks 3 m under you (1 m/s)
# while slab B rises 3 m. Fling from A's west lip, low, to B, high; B then sinks back at
# 0.35 m/s, and the exit ledge can only be reached from it while it is still up.
A.mover("cw_a", (-354.8, 454.2), [(box_pts(0, 0, 2.4, 0.8), "stone")],
        {"type": "sink", "to": [0, -3.0], "speed": 1.0, "back": 0.35}, model="temple_slab")
A.mover("cw_b", (-360.75, 451.2), [(box_pts(0, 0, 2.5, 0.8), "stone")],
        {"type": "link", "to": "cw_a", "scale": -1.0}, model="temple_slab")
A.ledge(-366.0, -362.3, 455.0, "stone", t=0.8)               # XL: the exit ledge
A.patch((-363.2, 455.0), (-362.3, 455.0), "wet", t=0.12)
A.deco("counterweight_chain", -354.8, 461.0, z=-0.6, size=(0.15, 12.0, 0.15), tone="iron")
A.deco("counterweight_chain", -360.75, 459.5, z=-0.6, size=(0.15, 14.0, 0.15), tone="iron")
A.challenge("5.7", "El Contrapeso", (-350.5, 453.0), 3, "B", moves=[
    ["reach", [-352.0, 453.0], [-353.6, 453.8]],           # gallery edge to slab A (at rest)
    ["fling", [-356.0, 451.6], [-360.4, 454.6], "F3"],     # A sunk to B risen: 4.4 across, 3.0 up
    ["reach", [-362.0, 454.6], [-362.3, 455.0]]])
A.cam((-366, 428, -350, 458), half_h=13.0, bias=(0.0, -6.0))

# ================================================================ 5.8 La Serpiente
# Up the serpent's tail (a chain) to its tail ledge, then 20 m along its back: nine
# vertebrae, each rising and falling 3 m on a 4 s beat, half a second behind the one
# before, so a wave runs along it. Three slick fangs hang from the roof: under a fang
# there is room only when the vertebra below is in its trough. Below is the 5.7 shaft
# and the gallery (7 m): back to the counterweight (B).
A.ledge(-366.0, -364.0, 460.2, "stone", t=0.6)               # SL: the tail ledge
A.rope("serpent_tail", (-363.5, 459.9), 4.5, kind="chain")
SERP = [-362.0 + 2.0 * i for i in range(9)]
for i, cx in enumerate(SERP):
    A.mover("vertebra%d" % (i + 1), (cx, 459.6), [(box_pts(0, 0, 1.9, 1.2), "stone")],
            {"type": "cycle", "to": [0, 3.0], "t_out": 2.0, "hold_out": 0.0, "t_in": 2.0, "hold_in": 0.0, "phase": 0.5 * i}, model="serpent_segment")
for fx in (-360.0, -354.0, -348.0):
    A.solid([(fx - 0.8, 466.6), (fx + 0.8, 466.6), (fx, 463.5)], "wet")   # a fang
A.challenge("5.8", "La Serpiente", (-365.0, 460.2), 3, "B", moves=[
    ["reach", [-364.0, 460.2], [-362.95, 460.2]],
    ["reach", [-345.05, 461.7], [-344.0, 461.7]]])
A.cam((-366, 452, -340, 467), half_h=8.0, bias=(0.0, -2.0))

# ================================================================ 5.9 Bloques Fantasma
# A slick ramp (35 degrees) from the serpent's head to the altar's threshold. Five blocks
# slide out of it as steps (1.7 m treads, 1.2 m risers) and back in, on the drum: the bar
# is FOUR COUNTS OF TWO BEATS (96 bpm, a beat is 0.625 s, a count 1.25 s, the bar 5 s).
# Each block is gone for one count in four, and the gone count walks up the stair: block 1
# on count 4, block 2 on count 1, block 3 on 2, block 4 on 3, block 5 on 4 again. A block
# that goes while you stand on it leaves you on the ramp: you slide to the serpent's head
# (S) or past it to the gallery (B). (At one beat a count the stair would need a 1.2 m
# step every 0.6 s; two beats a count is the same drum figure at a climbable speed.)
COUNT = 1.25
for k in range(1, 6):
    left = -340.0 + 1.7 * (k - 1)
    top = 461.7 + 1.2 * k
    A.mover("phantom%d" % k, (left + 1.1 + 1.9, top - 0.6), [(box_pts(0, 0, 2.2, 1.2), "stone")],
            {"type": "cycle", "to": [-1.9, 0], "t_out": 0.3, "hold_out": 3.45, "t_in": 0.3, "hold_in": 0.95,
             "phase": (COUNT * (k - 1)) % 5.0}, model="temple_block")
m59 = [["reach", [-340.0, 461.7], [-340.0, 462.9]]]
for k in range(1, 5):
    xk = -340.0 + 1.7 * k
    m59.append(["reach", [xk - 0.3, 461.7 + 1.2 * k], [xk, 461.7 + 1.2 * (k + 1)]])
m59.append(["reach", [-331.8, 467.7], [-331.5, 468.9]])
A.challenge("5.9", "Bloques Fantasma", (-342.0, 461.7), 4, "B", moves=m59)
A.cam((-344, 452, -323.5, 473), half_h=8.5, bias=(0.0, -2.0))
A.deco("drum_temple", -342.5, 462.6, z=-1.2, size=(1.6, 1.8, 1.6), tone="accent")

# ================================================================ 5.10 El Altar
# The altar's chamber has no floor: a stone beam crosses it, and under that is the
# gallery, 16 m down (B: back to the counterweight). A stone cross 10 m across turns in it
# counter-clockwise at 1.6 rpm, an arm every 9.4 s; a hard hit from it knocks you out.
# Its arms sweep 0.5 m over the beam's middle (they catch a standing head between x -321.4
# and -314.6) and brush the east wall between y 473.4 and 475.4. Go WITH it: an arm passes
# the bottom heading east, follow it across the beam, and it leads you up the east wall.
# The wall's holds are three stone knobs, then the three who tried: frozen hand to ankle
# off the exit ledge, a ladder that stops 4.6 m short of the beam. Brittle knobs sit in
# the wall behind them.
A.ledge(-323.5, -314.4, 468.9, "stone", t=0.5)
A.wheel("altar_cross", (-318.0, 474.4), 5.0, 1.6, spokes=4, kind="stone", spoke_t=0.5, hub=0.9, phase=45.0, ko=True, model="altar_cross")
WALL_X = -312.72
for y in (469.4, 470.8, 472.2):
    A.hold(WALL_X, y, 0.25, "stone")
for y in (473.6, 474.9, 476.2, 477.5, 478.8):
    A.hold(WALL_X, y, 0.22, "brittle")
for py in (478.7, 476.55, 474.4):           # pelvis heights: hands at +1.3, ankles at -0.85
    A.statue(-312.85, py, "hang")
m510 = [["reach", [-314.4, 468.9], [WALL_X, 469.4]]]
ys = [469.4, 470.8, 472.2, 473.6, 474.9, 476.2, 477.5, 478.8]
for a, b in zip(ys, ys[1:]):
    m510.append(["reach", [WALL_X, a], [WALL_X, b]])
m510.append(["reach", [WALL_X, 478.8], [-312.5, 480.0]])
A.challenge("5.10", "El Altar", (-326.0, 468.9), 4, "B", moves=m510)
A.cam((-331.5, 452, -309.5, 484), half_h=9.5, bias=(0.0, -3.0))

# ================================================================ 5.11 El Sacrificio
# The third crossing, over the well's own mouth: 14 m from this sill to a6's ledge
# (top y 480, from x -295.5), on two giant censers hung from the cap (pivots y 493,
# chains 9.8 m, so the bowls pass at y 483; a 1.5 m tassel hangs under each, its end at
# y 481.5 at the ends of the swing: a standing reach from the sill).
#   Censer 1: pivot x -303.0, swings 2.18 m either side (12.8 degrees), period 5 s.
#     Its tassel's end reaches x -305.6, over the sill's end, once every 5 s.
#   Censer 2: pivot x -297.075, the same swing, period 6 s. Its tassel's end reaches
#     x -294.45, a metre in over a6's ledge, once every 6 s.
#   Mid-well the bowls come within 0.2 m of touching (their centres 1.6 m apart) when
#   censer 1 is at its east end AND censer 2 at its west end. A hand can cross while the
#   centres are within about 2.6 m. 5 s against 6 s: the two ends meet exactly every
#   30 s (first at t = 1.25 s; phase 0.5417 sets that). Worked out at 0.01 s steps:
#     t = 0.65 .. 1.85 s    the good window, 1.2 s, bowls nearly touching
#     t = 6.3 .. 7.0 s      a lesser one, 0.7 s, the bowls never closer than 0.9 m
#     t = 25.5 .. 26.2 s    the same, on the swing before the next good one
#   and then it repeats. On the other three swings of the six there is no window at all.
#   So: one good chance in 30 s, two desperate ones, and a wrong guess leaves you riding
#   censer 1 back out over 300 m of well. A miss is the Pozo (P).


def great_censer(cid, px, period, phase):
    L = 9.8
    shapes = [(box_pts(0, -L / 2, 0.14, L), "iron"),            # the chain
              (box_pts(0, -L, 1.4, 1.0), "gold"),               # the bowl
              (box_pts(0, -L - 1.25, 0.25, 1.5), "iron")]       # the tassel
    A.mover(cid, (px, 493.0), shapes, {"type": "swing", "amp": 12.8, "period": period, "phase": phase}, model="censer")


great_censer("sacrifice1", -303.0, 5.0, 0.0)
great_censer("sacrifice2", -297.075, 6.0, 0.5417)
A.patch((-309.4, 480.0), (-308.6, 480.0), "wet", t=0.12)    # unease: blood-dark wet on the sill
A.challenge("5.11", "El Sacrificio", (-307.0, 480.0), 5, "P", moves=[
    ["reach", [-305.6, 480.0], [-305.61, 481.5]],          # the sill's end to tassel 1 (at its west end)
    ["reach", [-300.39, 481.5], [-299.69, 481.5]],         # tassel to tassel, mid-well
    ["reach", [-294.45, 481.5], [-295.5, 480.0]]])         # tassel 2 down to a6's ledge
A.cam((-312.5, 474, -290, 496), half_h=14.0, bias=(2.0, -8.0))
A.cam((-312, 356, -296, 384), half_h=11.0, bias=(2.0, -3.0))   # the arrival: the chains and the well under them

# ================================================================ the picture
# ---- cards: the back of the room, the far pyramid, the great mask's face, the pillars
A.card([(-378, 360), (-305, 360), (-305, 490), (-378, 490)], z=-6.0, tone="back2")
A.card([(-376, 366), (-330, 366), (-336, 384), (-344, 384), (-350, 402), (-358, 402), (-364, 420), (-376, 420)], z=-12.0, tone="back3")
A.card([(-366, 430), (-312, 404), (-312, 450), (-366, 450)], z=-10.0, tone="back3")          # the great hall's far wall
A.card([(-365.5, 381), (-351, 381), (-350, 392), (-352, 399), (-358.2, 401.5), (-364.5, 399), (-366.5, 392)], z=-1.5, tone="accent")  # the mask's face
A.card([(-366.5, 396), (-369.5, 403), (-364, 399.5)], z=-1.6, tone="accent")                 # its ears
A.card([(-350, 396), (-347, 403), (-352.5, 399.5)], z=-1.6, tone="accent")
A.card([(-335, 366), (-354, 381), (-354, 373.8), (-342, 366)], z=-2.0, tone="back")          # the wall that carries the stairs
for sx, fy in ((-347.0, 431.0), (-331.5, 433.0)):                                              # the champions' pillars
    A.card([(sx - 1.0, fy - 1.2), (sx + 1.0, fy - 1.2), (sx + 1.0, ramp_y(sx + 1.0) - 1.0), (sx - 1.0, ramp_y(sx - 1.0) - 1.0)], z=-2.0, tone="back")
A.card([(-345, 398), (-330, 398), (-328, 404), (-343, 407)], z=3.0, tone="back3")            # a broken arch, in front, clear of every route
for x in (-349.0, -335.0, -320.0):                                                             # the gallery's colonnade, behind
    A.card([(x - 0.6, 453), (x + 0.6, 453), (x + 0.6, 457.5), (x - 0.6, 457.5)], z=-2.5, tone="back")
# ---- the First Top Dog, everywhere
A.deco("mask_first_dog", -358.15, 380.2, z=-1.2, size=(16.0, 21.0, 2.0), tone="accent")     # 5.2: the mask itself
mask(-321.0, 376.0, 6.0, 6.5, z=-3.0)        # over the entry floor, watching the door
mask(-318.5, 428.0, 5.0, 5.5, z=-4.0)        # in the hall, over the drain
mask(-339.0, 444.0, 4.0, 4.4, z=-4.0)
mask(-333.0, 455.3, 2.6, 2.8, z=-3.0)        # the gallery
mask(-357.5, 463.0, 3.0, 3.3, z=-3.5)        # over the serpent
mask(-318.0, 474.4, 3.2, 3.5, z=-3.0)        # the altar's boss, behind the cross
mask(-300.0, 489.5, 3.4, 3.7, z=-3.0)        # the well room's keystone
A.deco("serpent_head", -342.2, 461.7, z=-0.9, size=(2.5, 2.0, 1.5), tone="accent")
A.deco("altar", -327.5, 468.9, z=-1.2, size=(3.0, 1.5, 1.5), tone="stone")
A.deco("altar", -310.5, 480.0, z=-1.2, size=(2.2, 1.1, 1.5), tone="stone")                   # the sacrifice stone, by the well
# ---- banners: the town's papel picado, grown solemn
for x, y in ((-316.0, 381.0), (-326.0, 381.0), (-340.0, 446.5), (-323.0, 446.5), (-352.0, 446.5), (-346.5, 457.0),
             (-329.0, 457.0), (-321.0, 482.5), (-315.0, 482.5), (-306.5, 492.0), (-293.5, 492.0)):
    A.deco("temple_banner", x, y, z=-1.4, size=(1.5, 5.0, 0.05), tone="accent")
A.deco("papel_string", -320.0, 371.5, z=-1.8, size=(8.0, 1.0, 0.05), tone="accent")
A.deco("papel_string", -300.0, 492.6, z=-1.8, size=(10.0, 1.0, 0.05), tone="accent")
# ---- torches: about one per 12 m of route, and one wherever a drop wants showing
for x, y in ((-311.5, 369.3), (-322.0, 369.3), (-338.0, 373.5), (-350.5, 384.0),      # the door, the stairs
             (-360.0, 399.2), (-369.3, 398.5), (-369.3, 406.5),                        # the brow, the shaft
             (-372.8, 418.0), (-362.2, 426.5),                                         # the gears
             (-362.5, 433.5), (-353.5, 441.0), (-339.5, 441.0), (-311.0, 446.8),       # the hall
             (-320.0, 455.4), (-334.0, 455.4), (-347.0, 455.4),                        # the gallery
             (-364.8, 457.6), (-356.0, 465.2), (-345.5, 465.2),                        # counterweight, serpent
             (-335.5, 471.0), (-327.0, 471.5), (-311.0, 482.4),                        # blocks, altar, exit
             (-316.0, 372.0), (-315.5, 400.0)):                                        # the drain's foot and throat
    torch(x, y)
A.light(-362.2, 394.6, color="#7CF0C8", rng=5.0, energy=1.4, flicker=False)             # the mask's jade eyes
A.light(-354.2, 394.6, color="#7CF0C8", rng=5.0, energy=1.4, flicker=False)
A.light(-318.0, 474.4, color="#FF9040", rng=9.0, energy=1.3, flicker=True)              # the altar's fire
for x, y in ((-324.5, 440.2), (-320.0, 442.0), (-315.5, 443.8), (-303.0, 483.2), (-297.1, 483.2)):
    A.light(x, y, color="#FF7A30", rng=6.0, energy=1.2, flicker=True)                   # the censers' coals
A.light(-300.0, 476.0, color="#FFB050", rng=14.0, energy=1.0, z=2.5, flicker=True)     # the well's throat, lit: see the drop
A.light(-302.0, 372.0, color="#FFB050", rng=12.0, energy=1.0, z=2.5, flicker=True)     # the arrival
# ---- air
A.effect("dust", (-366, 404, -309, 450), density=0.35)
A.effect("embers", (-328, 438, -312, 450), density=0.5)
A.effect("embers", (-306, 478, -294, 494), density=0.7)
A.effect("drips", (-349, 381, -347, 396), density=0.4)
A.effect("drips", (-313, 444, -311.8, 450), density=0.4)
A.effect("steam", (-318, 366, -313, 372), density=0.2)      # dust kicked up where the drain lands
# ---- cameras for the rest (the flings have their own above)
A.cam((-356, 363, -313, 386), half_h=6.5)                    # the door and the stairs
A.cam((-366.5, 376, -350, 400), half_h=8.5, bias=(0.0, 1.0)) # the mask, whole
A.cam((-374.5, 396, -366.5, 412), half_h=6.5)                # the pistons
A.cam((-374.5, 412, -360, 434), half_h=7.5)                  # the gears
A.cam((-352, 452, -312.8, 457.5), half_h=5.0)                # the gallery
A.cam((-312.8, 443, -309, 457), half_h=7.0, bias=(-2.0, 0.0))  # the chain

# The engine's `cycle` clock reads t + phase (a phase ADVANCES a mover). This file was
# written with phase meaning "starts p seconds late", so turn each one round here.
for _m in A.movers:
    _mo = _m["motion"]
    if _mo["type"] == "cycle" and _mo.get("phase", 0.0):
        _total = _mo.get("t_out", 0.5) + _mo.get("hold_out", 1.0) + _mo.get("t_in", 0.5) + _mo.get("hold_in", 1.0)
        _mo["phase"] = round((_total - _mo["phase"]) % _total, 3)

if __name__ == "__main__":
    A.save()
