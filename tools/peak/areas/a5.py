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
import a5_dress  # the temple's scenery (the modelling run's): decos only

A = Area("a5", "temple")
GOLD = "#FFC060"


def torch(x, y, rng=10.0, energy=1.6):
    # (its torch is a5_dress's now, out of the play space; the light it gives stays where it is: page 5.1)
    A.light(x, y + 0.6, color=GOLD, rng=rng, energy=energy, flicker=True)


# ================================================================ the shell
# The AIR's outline. Edge i runs pts[i] -> pts[i+1].
# (Note 60, page 5.0: the frog's room, 2.8 m deep and 2.8 m tall, cut into the west wall at the
# exit ledge, its floor level with the ledge (y 455): the outline is a5_dress's SHELL_ROOM, the
# same with the room's eight points. Only its floor can be stood on.)
SHELL = a5_dress.SHELL_ROOM
A.cave(SHELL, {0: "stone",   # the entry floor: every great fall inside the temple ends here
               7: "stone",   # the frog's room's floor
               20: None,     # the exit door, onto the well's mouth
               22: None},    # the entry door, onto the well
       default="wet", thick=3.0, skins=a5_dress.SHELL_SKINS_ROOM)
A.opening(-309, 362, -305, 382)   # ENTRY, from the Pozo (a4's mushroom throws you at it)
A.opening(-309, 474, -305, 488)   # EXIT, the well's mouth

# ---- the entry door: sill, beam, the two banner chains a4's throw is caught on
A.solid([(-309.1, 362), (-304, 362), (-304, 366), (-309.1, 366)], "stone", skin="templo_door_sill")      # the grip sill, top y 366
A.solid([(-310, 379.7), (-300.9, 379.7), (-300.9, 380.3), (-310, 380.3)], "stone", skin="templo_banner_beam")  # the banner beam, out into the well (2.6 m longer: both chains hang from it; page 4.10)
A.solid([(-310, 380.3), (-309, 380.3), (-309, 384.2), (-310, 384.2)], "stone", skin="templo_banner_beam")  # its corbel, up into the hood
A.rope("banner_chain_1", (-303.0, 380.0), 12.0, kind="chain")
A.rope("banner_chain_2", (-301.5, 380.0), 12.0, kind="chain")
A.deco("temple_banner", -303.0, 374.0, z=-1.3, size=(1.1, 11.0, 0.05), tone="accent")  # (just behind the play space: page 4.10)
A.deco("temple_banner", -301.5, 374.0, z=-1.5, size=(1.1, 11.0, 0.05), tone="gold")
# The hood over the door: keeps what comes down the drain from bouncing out into the well.
A.solid([(-313, 384), (-309, 384), (-309, 414), (-313, 408)], "wet", skin="templo_hood")
# ---- the exit door: lintel (to the structure's wall at y 488) and the sill block
A.solid([(-309.1, 484), (-306, 484), (-306, 488.2), (-309.1, 488.2)], "wet", skin="templo_exit_door")
A.solid([(-309.1, 474), (-306, 474), (-306, 479.3), (-309.1, 479.3)], "wet", skin="templo_exit_door")

# ================================================================ the great masses
# The great hall's floor: a slick ramp (32 degrees) that is also the lower hall's roof.
# Its foot stops 5 m short of the hood: that gap is THE DRAIN, 38 m straight down to the
# entry floor. Every miss in 5.5 and 5.6 goes this way (cost A).
RAMP0, RAMP1 = (-353.0, 429.0), (-318.0, 407.2)
A.solid([(-357.2, 429.0), RAMP0, RAMP1, (-318, 404.0), (-357.2, 425.8)], "wet", skin="templo_hall_ramp")


def ramp_y(x):
    return RAMP0[1] + (x - RAMP0[0]) * (RAMP1[1] - RAMP0[1]) / (RAMP1[0] - RAMP0[0])


A.solid([(-366.5, 400), (-357.2, 400), (-357.2, 429.0), (-360.2, 429.0), (-360.2, 411.2), (-366.5, 411.2)], "wet", skin="templo_pier")  # the pier + the gear room's east wall
A.ledge(-368.2, -360.2, 412.0, "stone", t=0.9, skin="templo_pier_cornice")    # R3: the pier's top and its cornice (the shaft's last step)
A.ledge(-365.0, -353.0, 430.0, "stone", t=1.0, skin="templo_balcony")    # the hall's west balcony
# The hall's roof / the gallery's floor, with two light slots you step over (a look down at the champions).
for (x0, x1), _gs in zip(((-352.0, -338.0), (-336.6, -328.0), (-326.6, -312.8)), "abc"):
    A.solid([(x0, 450.0), (x1, 450.0), (x1, 452.5), (x0, 452.5)], "wet", skin="templo_gallery_floor_" + _gs)
    A.ledge(x0, x1, 453.0, "stone", t=0.5, skin="templo_gallery_floor_" + _gs)
# THE SLOTS' INSIDES CAN'T BE HELD (Parker 11-12: "make the insides of little pitfalls like
# this not grabbable so pits are actually an issue"). The floor is holdable stone on every
# face, its ends included, so a climber who dropped into a slot stuck to its sides and
# climbed out. Each side is lined slick from the slot's foot to 7 cm under the lip: the
# floor's top, right up to the edge, still saves a hand that catches it.
for x, d, _gs in ((-338.0, 1, "a"), (-336.6, -1, "b"), (-328.0, 1, "b"), (-326.6, -1, "c")):
    A.solid([(x, 450.0), (x + 0.08 * d, 450.0), (x + 0.08 * d, 452.93), (x, 452.93)], "wet", skin="templo_gallery_floor_" + _gs)
# The upper works' spine: the serpent's head ledge, the phantom ramp, the altar's threshold.
A.solid([(-344, 457.5), (-323.5, 457.5), (-323.5, 467.7), (-331.5, 467.7), (-340, 461.7), (-340, 461.1), (-344, 461.1)], "wet",
        skin="templo_stair_ramp")
A.ledge(-344.0, -340.0, 461.7, "stone", t=0.6, skin="templo_head_ledge")    # HL: the serpent's head
A.ledge(-331.5, -323.5, 468.9, "stone", t=1.2, skin="templo_threshold")    # TL: the altar's threshold
# The altar's east wall, the exit ledge and the well sill (top y 480).
A.solid([(-312.5, 457), (-309, 457), (-309, 479.3), (-312.5, 479.3)], "wet", skin="templo_peg_wall")
A.ledge(-312.5, -305.6, 480.0, "stone", t=0.8, skin="templo_sill")

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
                 "trigger": "board", "reset": 4.0}, model="temple_step_jade")
    else:
        A.ledge(x1 - 3.0, x1, top, "stone", t=1.0, skin="templo_tier_true" if k in (1, 3) else None)
A.ledge(-354.0, -347.0, 381.0, "stone", t=1.0, skin="templo_landing")    # the sixth step and the landing before the mask
# (The small slick patches that stood on this area's rest ledges are gone, every one. Parker 11-12: "remove them all they feel like bugs".)
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
jaw_shapes.append((box_pts(0, -0.85, 4.4, 0.9), "stone"))            # its chin (the model's, drawn 0.9 m under the lip)
_jaw = A.mover("jaw", JAW, jaw_shapes, {"type": "cycle", "to": [0, 4.5], "t_out": 3.0, "hold_out": 1.4,
                                        "t_in": 2.2, "hold_in": 2.4, "phase": 0.0}, model="mask_jaw_jade")
# (Parker 11-12, riding it: "you should not be behind this part". The jaw's model reaches
# a metre toward the camera, in front of whoever stands on it. Set back, its front lip is
# at the climber's own depth and no nearer.)
_jaw["model_at"] = [0.0, 0.0, -0.6]
A.solid([(-359.7, 388.6), (-356.7, 388.6), (-356.7, 389.3), (-359.7, 389.3)], "stone", skin="templo_mask_lip")   # the upper lip
for tx in (-359.3, -358.2, -357.1):
    A.solid([(tx - 0.25, 388.65), (tx, 387.6), (tx + 0.25, 388.65)], "bone", skin="templo_mask_tooth")              # the upper teeth
A.hold(-358.9, 391.1, 0.25, "stone", skin="templo_mask_ring")    # nostrils
A.hold(-357.5, 391.1, 0.25, "stone", skin="templo_mask_ring")
A.hold(-356.1, 392.3, 0.25, "stone", skin="templo_mask_stud")    # cheekbones
A.hold(-360.3, 392.3, 0.25, "stone", skin="templo_mask_stud")
A.ledge(-355.4, -353.0, 393.6, "stone", t=0.5, skin="templo_mask_lid")    # the right eye's rim
A.ledge(-363.4, -361.0, 393.6, "stone", t=0.5, skin="templo_mask_lid")    # the left eye's rim
A.ledge(-366.5, -354.2, 396.4, "stone", t=1.2, skin="templo_mask_brow")    # the brow, and the walk west to the pistons
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
        {"type": "cycle", "to": [0, 3.6], "t_out": 2.4, "hold_out": 2.5, "t_in": 2.4, "hold_in": 2.7, "phase": 0.0}, model="temple_plunger_jade")
PIST = []   # (id, wall, top y, phase)
for i in range(9):
    PIST.append(("piston%d" % (i + 1), "W" if i % 2 == 0 else "E", 401.2 + 1.2 * i, (1.9 + 2.0 * i) % 10.0))
# EACH PISTON LIVES IN A SOCKET, A THIRD OF A METRE PAST THE WALL'S FACE (Parker 11-12:
# "these things are z fighting the walls and this area should not let you climb the walls,
# you should only be able to grab the platforms that are moving back and forth"). In, a
# piston's end used to sit exactly flush with the wall: its end and the wall's face were
# drawn in the same place (the flicker), and a hand on the wall there took hold of the
# piston's end: a holdable patch every 2.4 m up each slick wall, a ladder. Now nothing is
# flush. The tips reach where they did (x -368.8 from the west, -369.7 from the pier).
# A hand on a piston going in is let go at the wall's face (the game's rule for any sliding
# piece), and the socket grinds and puffs dust half a second before it starts back.
SOCK = 0.33
A.solid([(-377.3, 399.6), (-374.9, 399.6), (-374.9, 411.4), (-377.3, 411.4)], "wet", skin="templo_shaft_wall_west")  # rock behind the west sockets
for pid, wall, top, ph in PIST:
    if wall == "W":
        at, to = (-373.7 - SOCK, top - 0.45), [3.2 + SOCK, 0]
        face, into = -372.0, -1.0
    else:
        at, to = (-364.8 + SOCK, top - 0.45), [-(3.2 + SOCK), 0]
        face, into = -366.5, 1.0
    _p = A.mover(pid, at, [(box_pts(0, 0, 3.4, 0.9), "stone")],
                 {"type": "cycle", "to": to, "t_out": 1.0, "hold_out": 4.0, "t_in": 1.0, "hold_in": 4.0, "phase": ph},
                 model="temple_piston_jade")  # (the same from both ends: no flip for the east pier's)
    _p["socket"] = [face, top - 0.45]
    # The socket you can see: a carved frame on the wall's cut face and the dark of the
    # channel in it. (In front of the plane, but over the wall's own rock and nothing else.)
    xa, xb = sorted((face, face + into * 1.25))
    A.card([(xa - 0.12 * (into < 0), top - 1.04), (xb + 0.12 * (into > 0), top - 1.04),
            (xb + 0.12 * (into > 0), top + 0.14), (xa - 0.12 * (into < 0), top + 0.14)], z=1.27, tone="stone")
    A.card([(xa, top - 0.94), (xb, top - 0.94), (xb, top + 0.04), (xa, top + 0.04)], z=1.3, tone="#1A1418")
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
    A.mover(gid, (cx, cy), shapes, {"type": "spin", "rpm": rpm, "phase": phase}, model="temple_gear_jade")


# (Note 49, Parker 11-13: "Make them knock you out if you get crunched by them and also move 2x
# as fast": 5 rpm, a turn in 12 s. The crunch is the mountain's rule, peak_things.gd.)
GEARS = [("gear1", -364.6, 416.4, 5.0, 0.0), ("gear2", -368.56, 420.36, -5.0, 15.0),
         ("gear3", -364.6, 424.32, 5.0, 0.0), ("gear4", -368.56, 428.28, -5.0, 15.0)]
for g in GEARS:
    gear(*g)
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


def champion(sx, fy, plinth=True, stump=False):
    # Every solid of the statue names its skin (a5_dress places it): "templo_champion_broken" for
    # the first and third, "templo_champion_handless" for the second. Until it lands the shapes
    # are drawn as carved stone.
    # (Parker 11-13, page 5.5: the forearm drawn between each east elbow and its hand comes off
    # all three. The second loses the outer 1.6 m of its WEST arm: a 1.2 m stump, and its stone
    # hand 1 m across gripping the belt, with no arm behind it. The stump's length is the one number.)
    SK = "templo_champion_handless" if stump else "templo_champion_broken"
    if plinth:
        A.box(sx, fy - 0.6, 2.6, 1.2, "stone", skin="templo_plinth")
    A.box(sx, fy + 2.9, 1.8, 5.8, "stone", skin=SK)                       # legs and trunk
    A.box(sx, fy + 5.8, 2.4, 0.8, "stone", skin=SK)                       # shoulders
    A.solid(ngon(sx, fy + 7.0, 0.95, 8, rot=22.5), "stone", skin=SK)      # the masked head
    if stump:
        A.beam((sx - 1.0, fy + 5.9), (sx - 1.95, fy + 6.63), 0.6, "stone", skin=SK)   # the west arm's stump, 1.2 m
    else:
        A.beam((sx - 1.0, fy + 5.9), (sx - 3.2, fy + 7.6), 0.6, "stone", skin=SK)   # the west arm: the catch
    A.solid(ngon(sx - 3.4, fy + 7.75, 0.5, 8), "stone", skin=SK)
    A.beam((sx + 1.0, fy + 5.9), (sx + 2.6, fy + 7.0), 0.5, "stone", skin=SK)   # the east upper arm, to the elbow
    fist = (sx + 4.02, fy + 8.19)
    A.solid(ngon(fist[0], fist[1], 0.45, 8), "gold", skin=SK)             # the fist: the launch hold
    return fist


F1 = champion(-360.0, 430.0, plinth=False)    # on the balcony
F2 = champion(-347.0, 431.0, stump=True)
F3 = champion(-331.5, 433.0)
A.challenge("5.5", "El Salón de los Campeones", (-363.5, 430.0), 4, "A", moves=[
    ["reach", [-357.4, 437.0], list(F1)],
    ["fling", list(F1), [-350.4, 438.75], "F2"],           # to the second's stone hand (to be tried)
    ["reach", [-350.4, 438.75], [-348.95, 437.63]],        # the hand to the stump's end, 1.83 m (to be tried)
    ["reach", [-348.95, 437.63], [-348.2, 437.2]],         # onto the shoulders
    ["reach", [-344.4, 438.0], list(F2)],
    ["fling", list(F2), [-333.5, 439.7], "F3"]])           # 9.5 m across, 0.5 up
A.cam((-366, 404, -309, 450), half_h=13.0, bias=(3.0, -3.0))

# ================================================================ 5.6 Incensarios
# Three censers stepping up to the east balcony, 4.5 m apart, each swinging 1.6 m either
# side, with periods 4, 5 and 6 s so they drift in and out of step. Their chains (rods)
# hold: climb one and reach for the next bob when the two swing together. Under them is
# the ramp's foot and the drain (A).
# (Note 50, page 5.6: one censer, the middle one. The first and the third are gone.)
A.pendulum("censer2", (-320.0, 449.8), 7.8, 11.8, 5.0, phase=0.3, bob=(0.9, 0.8), kind="gold", rod_kind="iron", model="censer_l78_jade")
A.ledge(-312.8, -309.0, 443.6, "stone", t=0.9, skin="templo_keeper_balcony")               # EB: the east balcony
A.challenge("5.6", "Incensarios", (-331.5, 440.9), 4, "A", moves=[
    ["reach", [-328.9, 440.0], list(F3)],
    ["fling", list(F3), [-322.05, 442.2], "F3"],           # F3's fist to censer 2 at its west end: 7.3 m to a moving chain (to be tried)
    ["fling", [-318.0, 442.2], [-312.8, 443.6], "F2"]])    # censer 2 at its east end to the balcony (to be tried)

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
        {"type": "sink", "to": [0, -3.0], "speed": 1.0, "back": 0.35}, model="temple_slab_jade")
A.mover("cw_b", (-360.75, 451.2), [(box_pts(0, 0, 2.5, 0.8), "stone")],
        {"type": "link", "to": "cw_a", "scale": -1.0}, model="temple_slab_jade")
A.ledge(-366.0, -362.3, 455.0, "stone", t=0.8, skin="templo_exit_ledge")               # XL: the exit ledge
# (the two counterweight chains in the play space are gone: page 5.7; the pans hang from the dress's hangers)
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
A.ledge(-366.0, -364.0, 460.2, "stone", t=0.6, skin="templo_tail_ledge")               # SL: the tail ledge
A.rope("serpent_tail", (-363.5, 459.9), 4.5, kind="chain")
SERP = [-362.0 + 2.0 * i for i in range(9)]
for i, cx in enumerate(SERP):
    A.mover("vertebra%d" % (i + 1), (cx, 459.6), [(box_pts(0, 0, 1.9, 1.2), "stone")],
            {"type": "cycle", "to": [0, 3.0], "t_out": 2.0, "hold_out": 0.0, "t_in": 2.0, "hold_in": 0.0, "phase": 0.5 * i}, model="serpent_segment_jade")
for fx in (-360.0, -354.0, -348.0):
    A.solid([(fx - 0.8, 466.6), (fx + 0.8, 466.6), (fx, 463.5)], "wet", skin="templo_fang")   # a fang
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
             "phase": (COUNT * (k - 1)) % 5.0}, model="temple_block_jade")
m59 = [["reach", [-340.0, 461.7], [-340.0, 462.9]]]
for k in range(1, 5):
    xk = -340.0 + 1.7 * k
    m59.append(["reach", [xk - 0.3, 461.7 + 1.2 * k], [xk, 461.7 + 1.2 * (k + 1)]])
m59.append(["reach", [-331.8, 467.7], [-331.5, 468.9]])
A.challenge("5.9", "Bloques Fantasma", (-342.0, 461.7), 4, "B", moves=m59)
A.cam((-344, 452, -323.5, 473), half_h=8.5, bias=(0.0, -2.0))
# (the drum is a5_dress's, out of the play space)

# ================================================================ 5.10 El Altar
# The altar's chamber has no floor: a stone beam crosses it, and under that is the
# gallery, 16 m down (B: back to the counterweight). A stone cross 10 m across turns in it
# counter-clockwise at 6.4 rpm (it was 1.6), an arm every 2.3 s; a hard hit from it knocks you out.
# Its arms sweep 0.5 m over the beam's middle (they catch a standing head between x -321.4
# and -314.6) and brush the east wall between y 473.4 and 475.4. Go WITH it: an arm passes
# the bottom heading east, follow it across the beam, and it leads you up the east wall.
# The wall's holds are three stone knobs, then the three who tried: frozen hand to ankle
# off the exit ledge, a ladder that stops 4.6 m short of the beam. Brittle knobs sit in
# the wall behind them.
# THE WHOLE BEAM BREAKS, AND THE CROSS TURNS FOUR TIMES AS FAST (Parker 11-12: "make this
# whole platform break", "make the thing spin 4x as fast"). The beam is six pieces of
# cracked stone, 1.52 m each. A piece gives way BEAM_T after the first hand or foot is on it
# and comes back 8 s later, so the beam falls away behind you. BEAM_T is from a
# measurement: kept low (a crawl), a climber makes 0.6 to 0.9 m/s and is 1.6 m long, so it
# is wholly off a 1.52 m piece in about 3.5 s at the better pace. The cross turns once in
# 9.4 s now (6.4 rpm): an arm over the beam every 2.3 s, its outer 2 m fast enough to
# knock you out (the game's own rule: 2 m/s where it touches you). Cross low; keep moving.
BEAM_T = 3.5
_bx = [-323.5 + (9.1 / 6.0) * k for k in range(7)]
for k in range(6):
    A.ledge(_bx[k], _bx[k + 1], 468.9, "brittle", t=0.5, hold={"type": "crumble", "t": BEAM_T, "respawn": 8.0},
            skin="templo_bridge_slab")
    # (its look: pale stone cracked right through, a corner gone; worn as the piece's own, so it breaks with it)
    A.deco("templo_bridge_slab", round((_bx[k] + _bx[k + 1]) / 2, 3), 468.65, z=0.0, size=(1.52, 0.5, 2.4), tone="stone", skin=True)
A.wheel("altar_cross", (-318.0, 474.4), 5.0, 6.4, spokes=4, kind="stone", spoke_t=0.5, hub=0.9, phase=45.0, ko=True, model="altar_cross_jade")
WALL_X = -312.72
for y in (469.4, 470.8, 472.2):
    A.hold(WALL_X, y, 0.25, "stone", skin="templo_peg")
for y in (473.6, 474.9, 476.2, 477.5, 478.8):
    A.hold(WALL_X, y, 0.22, "brittle", skin="templo_peg_cracked")
    A.deco("templo_peg_cracked", WALL_X, y, z=0.0, size=(0.38, 0.44, 2.4), tone="stone", skin=True)
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
    A.mover(cid, (px, 493.0), shapes, {"type": "swing", "amp": 12.8, "period": period, "phase": phase}, model="censer_jade")


great_censer("sacrifice1", -303.0, 5.0, 0.0)
great_censer("sacrifice2", -297.075, 6.0, 0.5417)
A.challenge("5.11", "El Sacrificio", (-307.0, 480.0), 5, "P", moves=[
    ["reach", [-305.6, 480.0], [-305.61, 481.5]],          # the sill's end to tassel 1 (at its west end)
    ["reach", [-300.39, 481.5], [-299.69, 481.5]],         # tassel to tassel, mid-well
    ["reach", [-294.45, 481.5], [-295.5, 480.0]]])         # tassel 2 down to a6's ledge
A.cam((-312.5, 474, -290, 496), half_h=14.0, bias=(2.0, -8.0))
A.cam((-312, 356, -296, 384), half_h=11.0, bias=(2.0, -3.0))   # the arrival: the chains and the well under them

# ================================================================ the picture
# ---- cards: the back of the room, the far pyramid, the great mask's face, the pillars
# (The room's back, the far pyramid, the great hall's far wall, the stairs' wall, the champions'
# pillars, the broken arch and the colonnade are gone: a5_dress's hall walls, platform,
# pilasters and columns take their places. The pistons' sockets, above, stay.)
# ---- the First Top Dog, everywhere
# (Parker 11-12: "you should not be behind this part". The mask is modelled 10 m tall and
# 2 m deep and is drawn at 21 m, so it is 4.2 m deep: at z -1.2 its face stood 0.9 m in
# FRONT of the climb and the climber was inside the stone. At z -2.9 its face is 0.8 m
# behind you. Its holds are separate pieces in the play plane and stay where they were.)
# (The great mask, the seven pug masks, the serpent's head, both altars, the eleven banners and
# the two strings of paper are a5_dress's now, out of the play space: the mask set 0.5 m further
# back, the altars in their niches, five banners high on far walls.)
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
# (the altar's fire sits in the altar's bowl now, and the sacrifice stone's bowl burns too: placed
# with the dress below)
for x, y in ((-320.0, 442.0), (-303.0, 483.2), (-297.1, 483.2)):
    A.light(x, y, color="#FF7A30", rng=6.0, energy=1.2, flicker=True)                   # the censers' coals (one censer in the hall now: note 50)
A.light(-300.0, 476.0, color="#FFB050", rng=14.0, energy=1.0, z=2.5, flicker=True)     # the well's throat, lit: see the drop
A.light(-302.0, 372.0, color="#FFB050", rng=12.0, energy=1.0, z=2.5, flicker=True)     # the arrival
# ---- air
A.effect("dust", (-366, 404, -309, 450), density=0.35)
A.effect("embers", (-328, 438, -312, 450), density=0.5)
A.effect("embers", (-306, 478, -294, 494), density=0.7)
A.effect("drips", (-349, 381, -347, 396), density=0.4)
A.effect("drips", (-313, 444, -311.8, 450), density=0.4)
A.effect("steam", (-318, 366, -313, 372), density=0.2)      # dust kicked up where the drain lands
# (a5_dress item 9, the ones the effect kinds can show)
A.effect("spores", (-312.0, 366.0, -305.0, 372.0), density=0.4, speed=0.5, tone="#E6EFC4")  # the garden's spores drifting in at the door (5.1)
A.effect("drips", (-359.4, 381.5, -357.0, 387.6), density=0.5)                            # a slow drip from the upper teeth into the gullet (5.2)
A.effect("dust", (-372.0, 396.0, -366.5, 412.0), density=0.3, speed=0.5)                  # grit trickling down the throat (5.3)
A.effect("drips", (-365.0, 412.5, -364.2, 414.0), density=0.8, tone="#2A2420")            # grease off the lowest wheel (5.4)
for _fx in (-360.0, -354.0, -348.0):
    A.effect("drips", (_fx - 0.15, 459.6, _fx + 0.15, 463.5), density=0.6)                # a drip off each fang (5.8)
# ---- cameras for the rest (the flings have their own above)
A.cam((-356, 363, -313, 386), half_h=6.5)                    # the door and the stairs
A.cam((-366.5, 376, -350, 400), half_h=8.5, bias=(0.0, 1.0)) # the mask, whole
A.cam((-374.5, 396, -366.5, 412), half_h=6.5)                # the pistons
A.cam((-374.5, 412, -360, 434), half_h=7.5)                  # the gears
A.cam((-352, 452, -312.8, 457.5), half_h=5.0)                # the gallery
A.cam((-312.8, 443, -309, 457), half_h=7.0, bias=(-2.0, 0.0))  # the chain

# ================================================================ the dress (the modelling run's)
a5_dress.dress(A)
for x, y in a5_dress.ALTAR_LIGHTS:  # the altar's bowl and the sacrifice stone's bowl
    A.light(x, y, color="#FF9040", rng=5.0, energy=1.0, flicker=True)
for x, y in a5_dress.FROG_LAMPS:  # the frog's two small lamps
    A.light(x, y, color="#FFB860", rng=3.0, energy=0.6, flicker=True)
# (a5_dress item 8: the two pan hangers ride their pans)
A.follow("templo_pan_hanger", (-354.8, 454.6), "cw_a", "ride")
A.follow("templo_pan_hanger", (-360.75, 451.6), "cw_b", "ride")
# The scale's beam tips with its pans (east end 3 m up at rest, 5.95 m between the pans), the
# gullet's counterweight goes down as the jaw comes up (its chain stretching), and the drum's
# mallet lifts before each count of the blocks' bar and strikes on it, hardest on the first.
A.follow("templo_scale_beam", (-357.78, 456.0), "cw_a", "tip", rise=3.0, span=5.95)
A.follow("counterweight_hung", (-358.15, 386.4), "jaw", "ride", scale=-1.0)
A.follow("counterweight_chain", (-358.15, 387.5), "jaw", "hang", scale=-1.0, len=2.2)
A.follow("templo_mallet_arm", a5_dress.MALLET, None, "mallet", period=5.0, count=COUNT, lift=0.8)

# The engine's `cycle` clock reads t + phase (a phase ADVANCES a mover). This file was
# written with phase meaning "starts p seconds late", so turn each one round here.
for _m in A.movers:
    _mo = _m["motion"]
    if _mo["type"] == "cycle" and _mo.get("phase", 0.0):
        _total = _mo.get("t_out", 0.5) + _mo.get("hold_out", 1.0) + _mo.get("t_in", 0.5) + _mo.get("hold_in", 1.0)
        _mo["phase"] = round((_total - _mo["phase"]) % _total, 3)

# THE INSIDE'S OWN DARK (the Director, 11-14): the mountain's body card is cut away over this biome
# (st.py BODY_WINDOWS); behind the far wall a backstop in this biome's darkest tone, so no gap shows
# the body's grey-tan, or the sky.
A.card([(-386, 356), (-305, 356), (-305, 494), (-386, 494)], z=-11.6, tone="back3", edge=False)

if __name__ == "__main__":
    A.save()
