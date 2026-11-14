"""
LA CUMBRE, DRESSED: the scenery of all of biome 11, the summit (y 953 to 1012), from the eight area pages
(11.1 the tea shop under the prow, 11.2 La Corona, 11.3 Las Cuerdas del Campeón, 11.4 El Último Salto, 11.5
La Campana, 11.6 Top Dog, 11.6b the ceremony, 11.0 the frogs' hot spring) in
docs/peak/playtest/design/data/a11_areas.py and the biome's sheet a11_biome.py (its `built`, `looks`,
`layers` and `kit`, and KIT_MORE). The join "10 to 11" is shared with the storm ridge: a10_dress.py places
the ridge's last slate (the face, the headwall's rungs, the buttress's top step carried back to our west
pillar, the winch in front of it, the cloud's top strip at z -1.35 in front of our teeth's feet) and leaves
to us the exit ledge's top and its tea shop (note 97), the teeth, the pillars and the peak's back behind
the top of its biome, and the paper line over the ledge. Here: the tea ledge's whole floor (a10's ledge
and our slab, ONE summit rock, item 5), the shop in its back wall, the chute's mouth, then the crown, the
ring, the leap, the bell, and west of the belt the spring.

Parker, 11-13 (third round, ANSWERS.md 11 to 13; notes 97 to 102): "the summit currently does not look like
the ruin of a ring, it can be reworked a bit to look like one": the two horns are the ring's corner posts
(squared glazed shafts, three turnbuckle blocks each, painted iron bands; their skins), the west post's
timber head in honey (climbed, held), the east one and a fallen third in weathered grey behind the climb,
the six ring ropes as three matched pairs (thread C's `ring_rope_red/cream/jade`, laid on the bounces,
item 6a), the back runs (the jade one spanning the top with the paper on it, the red and cream ones hanging
snapped down the posts), the floor's last beam with the canvas apron hanging off it between the pillars,
the bell at the ringside as the timekeeper's. Rime steps (yes): the nose, the four collars and the block
are rime skins. A frog shows the rope move (yes): the game's, item 8. The bell solid (yes): item 6b. "make
this area a little tea shop with a frog" (97): the shop in the tea ledge's back wall, cut away at the
front, the frog in its apron behind the counter. THE SECRET (102): west off the belt down the west face,
over the eave, down the sink into the frogs' pool; the slide on the far left; the stair and the frost wall
to the chute and the tea shop. The belt and its ceremony (101) are the Top Dog session's: the belt deco
(a11.py line 361) is left alone; only its two bronze pegs are made, as part of the bell frame's skin.
NOTHING CLIMBER-SHAPED IS MODELLED until the new climber model lands (MODELLING_RUN): the last of the ones
who tried stays the game's statue on the perch (a11.py line 297), the ceremony's climber is the game's
climber posed; no deco stands in for either.

The walls rule (BRIEF.md "Walls and masses", walls_example_after.png) here is two materials. BLACK ICE (the
dome with its prow, the tunnel's roof, the west face and its eave, the shoulder, both posts' shafts): a few
big flat planes with a designed outline, blue-black and glossy with a hard white glint; its bands (three
blue-black tones), glints, cracks and lines of rime are flat colour on those planes as long wavy lines and
bands; nothing painted narrows to a point; no dark recess (the tunnel's two mouths, the sink, the stair's
chimney and the slide's mouth are the only holes, all the play's). TAN ROCK (the teeth, the pillars, the
splinter, the peak's back, the tea ledge's back wall, the rib): the same, its bedding long wavy lines in
three tans, outlines leaning and notched, a face the ring's builders cut square chipped along its cut.
Summit rock (warm, pale, dry, old cream) only where you stand: the tea floor, the shelf, the west post's
top, the perch, the doorstep. The few real breaks: the prow's lip, the eave, the turnbuckle blocks, the
fifth tooth's step, the rib under the perch. The sheet names the summit's plants (a cushion of moss with
small pink flowers, a silver star-flower, a tuft of gold grass): each a flat painted card on a little
outcrop that is part of the mass's own piece, never on ice, never in the play space (14 here).

Scenery only: decos. Nothing here can be stood on or held. The course (every solid, the bounces, both
ropes, the water, the ride, the finish, the statue, the bell deco that the bell rope swings) is a11.py's.
The model list this file makes is docs/peak/models/a11_models.md.

Depth: the play space is z -1.2 .. 1.2. Everything here stands behind -1.25 or in front of 1.25, except
SKINS (skin=True), each the LOOK of course solids. The dome's skin carries back to -2.2 (the tunnel's roof
to the chute's back wall); the shoulder's to -3.0 (its body behind the cave; the sink's shaft, the stair's
chimney and the slide's mouth have their own inside walls back to -1.5); the two posts' skins carry their
shafts back to -2.3, standing on the pillars' plinths (their turnbuckle blocks are 2.5 m deep, to -1.3);
the tea floor, the shelf, the perch, the bank and the rim carry back to -1.25 / -1.3 (the floor to the
back wall's foot); the doorstep to the sink's back (-1.5); the frost wall across the tunnel to its back
wall (-2.0); a gold boss's skin is the boss (z -0.26 .. 0.26) and its bronze neck back to its needle's tip
(-1.4); a rime collar or nose from 0.3 back round its needle or spur (-1.65); the iron rings are the kit's
`iron_ring_pin_long`, the pin's root inside the spur, the splinter or the chimney's wall. From the back:
our own cloud, three painted banks 22, 10 and 5 m back (z -22.2 .. -22.0, -10.2 .. -10.0, -5.2 .. -5.0);
the peak's own back -3.4 .. -3.0 (outcrops to -2.8, its plants at -2.85); the tea ledge's back wall -3.8
.. -1.3 (its face -1.3 up to the lintel's line, 966.8, set back to -2.1 above under the prow) with the
shop's room cut into it (-3.8 .. -1.3) and the shop's things -3.8 .. -1.33; the awning -2.05; the chute's
back wall -2.2 .. -2.0; the spring's cave -3.2 .. -1.25 with its frogs, lanterns, table and towels -2.9
.. -1.5; the bell frame's strut -3.0 .. -1.3, the two staffs -2.05 .. -1.3, the west staff -2.85 .. -2.1;
the lines of paper -2.05 (the one on the jade back run -1.8); the pillars -2.3 .. -1.8 (plants -1.66), the
floor beam -2.15 .. -1.75 with the apron at -1.72 hanging off its front; the garlands -1.72; the needles,
the spur and the splinter's tip -1.65 .. -1.4 (outcrops to -1.3, plants -1.36); the fifth tooth's step
carried back -2.3 .. -1.25 with the fallen post -1.7 .. -1.3 on it; the east timber head -1.7 .. -1.3;
the snapped back runs -1.6 .. -1.3; the rib under the perch -2.2 .. -1.3 with the marigolds at -1.75. In front:
ONLY the two snow caps (z 2.0 .. 2.05), each in front of solid ice and cut away from the tunnel, the sink,
the cave and the slide. No cloud, steam, paper or garland passes in front of the climb (note 40).

A deco's origin is the middle of its base (x and z) at its foot (y), unless its comment says otherwise:
wall-mounted things (the signs, the shelf of tins) the middle of their foot line on the wall;
`lantern_hang` its hook; `iron_ring_pin_long` where its pin meets the rock (its ring's centre 0.223 below
and 1.583 forward); a line of paper or a garland the middle of its lowest line in its own frame (the game
tiles them end to end, 8 m and 4 m units, peak.gd LINE_UNITS), turned by `rot`; the pieces "made in
place" (the strut, the staffs, the back run, the splinter, the rib) the middle of their box's foot. For
the long pieces (walls, skins, cards): the middle of the x span, the bottom of its box, the middle of its
depth. A deco's size is the size its model is MADE at (the game rescales a landed model more than a
quarter off; skins are never rescaled); where one model is used at two sizes `scale` does it (the
flagstaff made 6.3 m, at 0.873 for the west staff). `rot` is in degrees, counter-clockwise as the camera
sees it. `flip` mirrors in x.

Shared pieces are placed once, in the section of the page that designs them: the peak's back (every page:
in the far view); the teeth, the spur, the garlands (11.1, 11.2: in 11.2); the pillars, the floor beam and
apron, the fifth tooth's step with the fallen post (11.2, 11.3: in 11.3); the splinter, the flagstaff and
the paper over the leap (11.3, 11.4: in 11.4); the bell frame, its strut, the bell staff, the west line of
paper (11.4 to 11.6b, 11.0: in 11.5); the frog's sign on the strut (11.0, 11.6: in 11.5); the dome and its
cap (every page: in the dome's section); the chute's back wall (11.1, 11.0: in 11.1).

FOR THE AREA FILE (tools/peak/areas/a11.py; the fix thread's). Line numbers are a11.py's as of 2026-11-14
(the version with the frogs' hot spring and its drop as a ride, 4d0a921 and 1c76622).
  1. Call it: `import a11_dress` after the peaklib import (line 24), and `a11_dress.dress(A)` after the
     lights (line 379), before `if __name__ == "__main__":` (line 381), so before A.save().
  2. Lights. The two warm places of the sheet, as colour on their walls (no glowing material anywhere):
     the tea shop, a11_dress.TEA_LIGHTS (the lantern and the stove, both flicker); the spring,
     a11_dress.SPRING_LIGHTS (its three candle lanterns, flicker, and the daylight down the sink). Each is
     (x, y, z, colour, range, energy, flicker). They take the place of line 157 (the stand-in glow in the
     cave) and line 376 (the lamp light on the back wall at x -343: page 11.1 moves it 6.5 m east, into the
     shop). KEEP the gold lights 377-379. The spring's steam is an effect (item 9), not a light.
  3. Decos to take out (this file places what the pages keep, out of the play space): lines 362-364 (the
     three `ring_post`s: the west one at z 0 becomes the timber head's skin; the east one stood 0.4 m
     behind you inside the horn's ice tip, here 1.2 m east, 1.1 m back and 2 m up on the widened shaft, in
     grey; the fallen one stood upright on the shelf at -0.9, here lying on the fifth tooth's step at -1.5),
     365-368 (the four `papel_string`s at z -1.0 / -1.2, at hand height: here the awning, the line on the
     jade back run, the line over the leap and the west line, all 2 m back and 2.5 m over any hand), 369-371
     (the four garlands straight from gold to gold, 1.2 m back, read as a rope to the next hold, note 98:
     here swagged lower from the needles' backs), 372-373 (the garlands on the frame at z +0.4, in front of
     the timber: pressed flat into the frame's skin here), 374 (`marigold_pile` at -0.5 in the play space:
     here on the rib's top, 1.5 m back), 375 (`cold_lantern` on the tea floor at -0.8: the shop's lit
     lantern takes its place). KEEP 359 (the bell: the bell rope's mover look, item 8) and 361 (the belt:
     the Top Dog session's, note 101).
  4. Cards to take out: 317-318, 319-320 and 323 (the three flat cloud cards: our three painted banks
     here, at the same depths), 328-329 (the mountain's far side at z -3: the peak's own back here), 330
     (the tunnel's dark: the chute's back wall here), 351-354 (the five teeth cards at z -1.4) and 355-356
     (the two horn roots at z -1.8: the needles and the pillars here, carried down to 953 behind the storm
     ridge's cloud top, a10_dress item 7i). The snow cards 333-334 (the dome's cap) and `_snow_cut()`
     (337-348, the shoulder's) come out ONLY WHEN `cumbre_snow_cap_dome` and `cumbre_snow_cap_shoulder`
     land: the game draws no stand-in for a foreground deco (peak.gd _deco), so until then the cards are
     the only snow. Effects: line 324 (the clouds over x -392 .. -316, 952 .. 966) only if the game draws
     them behind the climb (note 40); KEEP the gold dust (325).
     And in a10.py: the exit ledge (line 55 at HEAD; line 58 in the fix thread's working copy of 11-14,
     where it already wears skin="tormenta_exit_slab") takes skin="cumbre_tea_floor" (item 5), so a10_dress.py's
     `tormenta_exit_slab` skin deco (its line 679) comes out and that stem is struck from a10_models.md (its
     row allowed for it: "if the summit's dress wants the ledge as its own piece it takes this skin").
  5. Skins. Each named solid takes `skin=` its stem; this file places every skin deco.
     - The dome block (46-47) and the eave (50): "cumbre_dome" (one piece: the prow, the tunnel's roof,
       the east cliff, the apex, the west face and its eave).
     - The shoulder (`_shoulder()`, line 125, every convex piece): "cumbre_shoulder".
     - The two doorstep ledges (129, 130): "cumbre_doorstep" (one piece, the chimney between).
     - The frost wall (133): "cumbre_frost_wall" (a crumble hold: its deco is within 3 m of its middle).
     - The three iron rings (140, 178, 271, each A.hold): "iron_ring_pin_long" (the kit's).
     - The slick lip (150) and the bank (151): "cumbre_spring_bank". The rim (156): "cumbre_slide_rim".
     - The tea slab (166), and a10.py's exit ledge (a10 line 55): "cumbre_tea_floor" (one floor, page 11.1).
     - The nose (176): "cumbre_rime_nose"; the four collars (184): "cumbre_rime_collar" (one each); the
       block (189): "cumbre_rime_block". The five gold holds (182): "cumbre_gold_boss".
     - The shelf (188) and its iced belly (192): "cumbre_shelf".
     - The west horn (246-247) and its top (268): "cumbre_post_west"; the east horn (248) and its widened
       outer half (251): "cumbre_post_east".
     - The corner post (269): "cumbre_timber_head".
     - The bell frame's post (285), beam (286) and brace (287): "cumbre_bell_frame" (with the garlands
       pressed flat on it and the belt's two bronze pegs on the post's top). The yoke (288):
       "cumbre_bell_hanger", once it is shortened (item 6b).
     - The perch (296): "cumbre_perch".
  6. Course changes the pages ask for (not scenery):
     a. 11.3 (note 98): the six ring ropes are drawn by thread C's models laid on their bounces: line 238
        (the west horn's, k = 0, 1, 2) and 242 (the east's) take model="ring_rope_red" for k 0,
        "ring_rope_cream" for k 1, "ring_rope_jade" for k 2 (each made 4.4 m along x, origin the middle
        of its axis; the bounce lines are 4.395 m), in place of the stand-in bands (peak_zones.gd
        _rope_band). They squash and spring as Del Mar's floats do.
     b. 11.5 (note 100, Parker: "the bell is solid"): the bell becomes a solid that swings with the rope
        (2.2 m across, 2.6 m tall, its mouth at 1002.2 where the rope's top is, its crown at 1004.8, on a
        pin at (-355.7, 1005.15) under the beam), held and stood on; the yoke solid (288, 1002.2 .. 1005.3,
        today inside the bell) is shortened to the hanger above the pin, x -355.95 .. -355.45, 1004.95 ..
        1005.3. The way up then goes rope, bell's flank, yoke, beam.
     c. 11.3 (note 98): while you stand on the shelf, its block or hang from the fifth boss, the camera
        leans 3 m up and 3 m west (frame about 974 .. 992 m: both red ropes, the west cream, the apron and
        the frog): a cam over (-323.5, 978.6, -319.5, 982.6), half_h 9.0, bias (-3.0, 3.0), before line 257's.
     d. 11.1 (note 89, Parker: no wind on the tea shop's doorstep): the storm ridge's top wind (a10.py; its
        band from 953 to 968 m, x -346 east) stops at 962 m, the ledge's underside. a10.py's, for its page.
     e. Both ropes' toll handles (the bobs, lines 142 and 290): model="cumbre_toll_handle" (a11_models
        section 4).
  7. Found while dressing, not on a page:
     a. a11's region is x -380 .. -320, y 962 .. 1010: the shoulder's west part (to -390.2: solid 2), the
        east post's widened half (-320.2 .. -318.6, line 251, and its tip), the east head and the cave's
        west wall stand outside it, and the teeth and pillars go down to 953. If anything (the bell's
        tick, the area's activation, the camera) is gated by the region, it wants x -391 .. -317.
     b. st.py's frogs' slide (FROG_SLIDE, tube() 2.2 m, 3 m slabs) starts at (-378.1, 963.5), INSIDE the
        shoulder's rock (to 962) for its first 1.5 m: its slabs there fight the shoulder's skin. Start it at
        962, or give those slabs skin="cumbre_shoulder" (the piece is made with the slide's mouth in it).
        Below 962 the tube wears no skin; its warm water running down is the game's (an effect).
     c. st.py's cardboard sky clouds: i 25 .. 33 (y 890 .. 1002, 20 to 130 m east of the face, z -26 ..
        -80) stand in the summit's sky in front of the given far view; the sheet: "no sky card of ours",
        only our three banks. As a7 7b, a8 7c and a9 7a ask, out above 890 too, or ruled the far view's.
     d. The bell deco (359) hangs from 1006.3, 0.6 m above the beam's top: the bell hangs through the beam
        and its mouth is 1.5 m above the rope's top (page 11.5). With `cumbre_bell` (origin its pin) it goes
        to y 1005.15; if `summit_bell` stays, to 1004.66 (its origin the ring's top, its lip 2.46 below).
     e. The stair's chimney (77, 0.9 m) cuts the doorstep in two: the frost wall is taken standing on its
        last 0.3 m (solid 11, x -366.8 .. -366.5) or from the west piece across the chimney's mouth. To try
        in play; the doorstep's skin is one piece either way.
     f. The page's three rim stones on the pool's east edge (holdable) are a slick lip in the course (line
        150, the Director's): dressed as glossy wet stones in the lip's skin, never a hold.
     g. Page 11.1 asks the awning 2 m back and the back wall 1.3 m back: the wall's face is set back to -2.1
        above the lintel's line (966.8), so the awning's flags (967.0 .. 968.0) hang clear in front of it.
     h. The pages put the garlands (-2.0 .. -2.2) inside the pillars (-1.8 .. -2.2). Here the needles are
        thin (-1.65 .. -1.4), the garlands hang just behind them (-1.72), the floor beam's front and its
        apron in front of the pillars (-1.75 / -1.72) with the beam's ends let into them, the pillars at
        -2.3 .. -1.8 (the storm ridge's buttress top and winch were set to a pillar face at -1.8).
     i. The page puts both staffs "lashed to the back of" a held timber (the west head, the bell post): a
        staff there stands in the play space beside the pad and over the belt. Here each stands from 1.3 m
        back (the bell staff and the strut on a cleat run back from the post inside the frame's skin).
  8. Movers' looks and the game's things (models in a11_models.md sections 4 and 5):
     - the bell (359): model "cumbre_bell" at (-355.7, 1005.15) (re-made: origin its pin, the iron fork that
       holds its crown, NO clapper), and the bell rope's `bell` (294) = "cumbre_bell" (the rope finds its
       bell by the deco's model). The clapper: "cumbre_bell_clapper" (origin the pin) in place of the
       stand-in rod and ball in peak_things.gd _find_bell.
     - the six ring ropes (item 6a); the toll handles (item 6e).
     - the frost wall: whole, it is "cumbre_frost_wall" (its skin); its breaking and growing back are the
       rime's effects (item 9). The rime steps likewise.
     - THE FROG THAT SHOWS THE MOVE (note 98, confirmed): the game's, the kit's `frog_sit`; at rest on the
       fallen post's end, a11_dress.ROPE_FROG_REST (x, y, z); the first time your feet are on the shelf,
       then about every 25 s while you are on the shelf, its block or the fifth boss (never in the air), it
       croaks, jumps into the west red rope and is thrown up all six (the dashed path on page 11.3), hops
       off the back of the west post and is next seen at rest again. Never solid. This file places no frog
       there, so there is never two.
  9. Effects (the pages'; the fix thread's): steam off the kettle and off the shop's spout; the cowl's
     smoke running east under the prow and out past the lip; snow smoking off the prow's lip; gold dust
     (kept); the awning, every paper and the garlands lifting a little east; the apron stirring east and
     the snapped back runs swaying; rime in its last second (it ticks, sheds frost dust, its crack opens)
     and growing back from the needle toward the west over 4 s; when the frost wall breaks its pieces
     slide down the tunnel and out of the chute's mouth onto the tea floor, melting with a breath of steam,
     and the steam over the doorstep swirls; THE STEAM COLUMN out of the sink, 3 m wide, 26 m tall, behind
     the climb (z -2.4 .. -2.2), leaning east at its top, always there; thick white steam over the pool,
     thinning to the roof; ripples where you land; a frog now and then down the slide on a tea tray; the
     cushions puffing dust when a rope throws; dust from the yoke's pin at the first toll; marigold petals
     off the frame when the bell rings; the ceremony's rays (note 101: the Top Dog session's).
"""
import math

# ------------------------------------------------------------------ the course's own numbers (a11.py)
LIP = (-330.0, 968.6)           # the prow's lip
D1 = (-340.0, 976.6)
JEWELS = [(-325.6, 970.4), (-332.6, 976.6), (-339.6, 981.8), (-328.6, 979.8), (-321.6, 981.8)]   # the five gold bosses
RING0 = (-329.8, 965.9)         # the ring under the prow's lip (r 0.26)
RING4 = (-335.7, 998.2)         # the ring of the last leap (note 99)
RING_S = (-367.25, 977.3)       # the frogs' stair's ring, in its own chimney
FLOOR = 964.0                   # the tea ledge (a10's ledge; our slab rises to 965 at x -349)
SHELF = 979.2
WTOP = 995.2                    # the west post's top
PAD = 998.2                     # the west timber head's top (its red pad)
ROPE_X = -355.7                 # the bell rope
POST_X = -360.3                 # the bell frame's post
BEAM = (1005.3, 1005.7)
PIN = (-355.7, 1005.15)         # the bell's pin (page 11.5)
# where the paper is tied (a11_areas)
HORN_STAFF = (-332.0, 1001.5)
BELL_STAFF = (-360.3, 1011.2)
WEST_STAFF = (-382.0, 1002.65)
EAST_HEAD_TOP = (-319.4, 1001.5)


def dome_y(x):
    """The dome's surface at x (a11.py dome_y)."""
    return LIP[1] + 0.8 * (LIP[0] - x) if x >= D1[0] else D1[1] + 0.7 * (D1[0] - x)


# Depths.
BACK = -1.25            # the near edge of the background
PEAK_FACE = -3.0        # the peak's own back
TEA_WALL = -1.3         # the tea ledge's back wall (its face below the lintel's line)
TEA_WALL_HIGH = -2.1    # and above it, under the prow
TEA_ROOM_BACK = -3.8
PAPER_Z = -2.05         # the long lines of paper
NEEDLE = (-1.65, -1.4)  # a tooth's needle, the spur, the splinter's tip
GARLAND_Z = -1.72
PILLAR = (-2.3, -1.8)
CAVE_BACK = -3.0        # the spring's cave's back wall's face
CHUTE = (-2.2, -2.0)    # the chute's back wall

# Stand-in tones.
ICE = "blackice"
TAN = "#B48A5E"         # the summit's tan rock, one layer back
TAN_FAR = "#A88A6A"     # the peak's own back, duller
CREAM = "#E9DDBE"       # summit rock where you stand
RIME = "#E4E8EC"
GOLD = "gold"
WOOD = "wood"
GREY_WOOD = "#9A958C"   # timber you can't reach
IRON = "iron"
ACCENT = "accent"
AMBER = "#C8925A"       # the tea shop, amber inside
WARM = "#C99A62"        # the spring's warm rock
CLOUD = "#FFFFFF"
SNOW = "snow"
PLANT = "#C9A0B4"

# Lights for a11.py (item 2): x, y, z, colour, range, energy, flicker.
TEA_LIGHTS = [(-338.55, 966.28, -1.45, "#FFB860", 4.5, 1.0, True),      # the shop's lantern under the lintel
              (-334.1, 964.4, -2.5, "#FF9A50", 2.5, 0.6, True)]         # the stove's door
SPRING_LIGHTS = [(-377.0, 974.2, -2.6, "#FFB860", 3.5, 0.8, True),      # the three candle lanterns
                 (-373.8, 973.95, -2.6, "#FFB860", 3.5, 0.8, True),
                 (-365.6, 973.65, -2.6, "#FFB860", 3.5, 0.8, True),
                 (-369.9, 975.5, -0.6, "#FFE6C0", 5.0, 0.6, False)]     # daylight down the sink
# The frog that shows the move, at rest on the fallen post's end (item 8: the game's, not placed here).
ROPE_FROG_REST = (-319.2, 979.6, -1.5)

# Made sizes of the pieces placed by helpers.
PAPEL = (8.0, 0.98)     # papel_string: an 8 m unit, its cord ends 0.98 above its origin (the lowest point)
GARLAND = (4.0, 0.62)   # marigold_garland: a 4 m unit, its loops 0.62 above its origin
RING_PIN = (0.5, 0.55, 1.65)   # iron_ring_pin_long: its ring's centre 0.223 below and 1.583 forward of the pin's root
PLANTS = {"moss": ("cumbre_moss_pink", (0.5, 0.3, 0.01)),
          "star": ("cumbre_star_flower", (0.3, 0.45, 0.01)),
          "grass": ("cumbre_grass_gold", (0.6, 0.5, 0.01))}


def dress(A):
    # ------------------------------------------------------------ helpers
    def skin(stem, x0, x1, y0, y1, z_front=1.2, z_back=-1.2, tone=ICE, flip=False):
        """The look of course solids: their box, from z_front back to z_back."""
        A.deco(stem, round((x0 + x1) / 2, 3), round(y0, 3), z=round((z_front + z_back) / 2, 3),
               size=(round(x1 - x0, 2), round(y1 - y0, 2), round(z_front - z_back, 2)), tone=tone, skin=True, flip=flip)

    def back(stem, x0, x1, y0, y1, z_near, z_far, tone=TAN, flip=False):
        """A piece behind the play space, from z_near back to z_far (origin: the middle of its foot)."""
        A.deco(stem, round((x0 + x1) / 2, 3), round(y0, 3), z=round((z_near + z_far) / 2, 3),
               size=(round(x1 - x0, 2), round(y1 - y0, 2), round(z_near - z_far, 2)), tone=tone, flip=flip)

    def front(stem, x0, x1, y0, y1, z_near, z_far, tone=SNOW):
        """A piece in front of the play space (z_near the side toward the play space)."""
        A.deco(stem, round((x0 + x1) / 2, 3), round(y0, 3), z=round((z_near + z_far) / 2, 3),
               size=(round(x1 - x0, 2), round(y1 - y0, 2), round(z_far - z_near, 2)), tone=tone)

    def line(model, a, b, unit, z, size_h, size_d, tone):
        """A tiled line of flags or flowers whose cord ends are at a and b (the game tiles the unit end to
        end along the deco's own x and turns the row by rot about its origin, the middle of its lowest line)."""
        if a[0] > b[0]:
            a, b = b, a
        L = math.dist(a, b)
        r = math.atan2(b[1] - a[1], b[0] - a[0])
        mx, my = (a[0] + b[0]) / 2, (a[1] + b[1]) / 2
        ox, oy = mx + unit * math.sin(r), my - unit * math.cos(r)
        A.deco(model, round(ox, 3), round(oy, 3), z=z, rot=round(math.degrees(r), 2), size=(round(L, 2), size_h, size_d), tone=tone)

    def paper(a, b, z=PAPER_Z):
        """The town's paper, whole and bright: the kit's papel_string between two ties."""
        line("papel_string", a, b, PAPEL[1], z, PAPEL[1], 0.03, ACCENT)

    def garland(a, b, sag, z=GARLAND_Z):
        """A swag of marigolds tied at a and b, hanging `sag` lower in the middle: two runs of the kit's
        marigold_garland meeting at the low point (a straight row cannot sag more than its unit does)."""
        low = ((a[0] + b[0]) / 2, (a[1] + b[1]) / 2 - sag)
        line("marigold_garland", a, low, GARLAND[1], z, 0.68, 0.1, ACCENT)
        line("marigold_garland", low, b, GARLAND[1], z, 0.68, 0.1, ACCENT)

    def plant(kind, x, y, z):
        """One of the summit's plants, a flat painted card standing on a little outcrop (the outcrop is part
        of the mass's own piece)."""
        stem, size = PLANTS[kind]
        A.deco(stem, x, y, z=z, size=size, tone=PLANT)

    def ring(x, y):
        """An iron ring on a long pin (the kit's iron_ring_pin_long), skinning the course's ring hold at (x, y):
        the pin's root 1.583 behind and 0.223 above the ring's centre, inside the rock it is driven into."""
        A.deco("iron_ring_pin_long", x, round(y + 0.223, 3), z=-1.583, size=RING_PIN, tone=IRON, skin=True)

    def boss(x, y):
        """A gold boss: eight-sided, 0.52 across, brushed matte gold, on a short bronze neck back to its
        needle's tip (z -1.4); the skin of the course's gold hold (r 0.26); origin its lowest point."""
        A.deco("cumbre_gold_boss", x, round(y - 0.26, 3), z=-0.57, size=(0.52, 0.52, 1.66), tone=GOLD, skin=True)

    # ============================================================ the far view and behind everything
    # OUR OWN CLOUD: three low banks, plain white, in a few big calm shapes to match the far sea (the kit's
    # peak_cloud_bank_a/b: round heads, a nearly flat underside, colour only inside), their tops between 957 and
    # 966 m so the summit stands in cloud to its ankles; 130 m wide (the cards' span). All behind the climb (note 40).
    back("cumbre_cloud_bank_far", -420.0, -290.0, 940.0, 966.0, -22.0, -22.2, tone=CLOUD)
    back("cumbre_cloud_bank_mid", -420.0, -290.0, 940.0, 963.0, -10.0, -10.2, tone=CLOUD)
    back("cumbre_cloud_bank_near", -420.0, -290.0, 940.0, 961.0, -5.0, -5.2, tone=CLOUD)
    # THE PEAK'S OWN BACK: warm tan rock 3 m behind everything, one painted piece in big slanted planes, its
    # bedding long wavy lines of three tans, an uneven skyline (5 m over the dome's back, a blunt head at 1000.8
    # behind the bell post's foot, dipping to 991 over the notch, rising west to 1001); its east edge a broken
    # buttress (no straight cut at x -318); its foot meets the storm ridge's slate in a line at 962 and east of
    # the slate goes down to 953 with the teeth; it never stops inside a frame. A few little outcrops carry
    # plants (placed below), and on the west one the flagstaff (11.0).
    back("cumbre_peak_back", -392.0, -317.0, 953.0, 1001.0, -2.8, -3.4, tone=TAN_FAR)
    plant("moss", -343.5, 981.4, -2.85)
    plant("star", -338.0, 978.0, -2.85)
    plant("grass", -352.0, 987.6, -2.85)

    # ============================================================ the summit's ice
    # THE DOME (skin, lines 46-47 and 50): black ice over rock, blue-black and glossy with a hard white glint, a
    # few big flat planes; the prow's overhang with its painted shadow (a real break: no icicles, page 11.1),
    # the prow's underside carried back to the back wall's top and the chute's back wall (-2.2), the lantern's
    # amber as colour on its facets over the shop; the tunnel's roof; the east cliff the snow cap stands in
    # front of; the apex the bell post is footed in; the west face down to THE EAVE (the last 4.4 m turned out
    # 3.1 m west, 42 degrees, its lip over the sink), roofing the doorstep and the frost wall. Its bands, glints,
    # cracks and lines of rime painted as long wavy lines. None of it can be held.
    skin("cumbre_dome", -369.6, -330.0, 968.2, 1000.6, z_back=-2.2)
    # The dome's snow cap (foreground, in front of solid ice: the card's outline, a11.py 333-334): white, matte,
    # its foot set 1.5 m up from the prow's underside and about 1 m in from the line a body slides on, so the ice
    # shows below it as a dark wet rim; it covers nothing you touch.
    front("cumbre_snow_cap_dome", -365.3, -333.5, 969.9, 999.8, 2.0, 2.05)

    # ============================================================ 11.1 Sobre las Nubes: the tea shop
    # THE FLOOR (skin, line 166 and a10.py's line 55): ONE summit rock, 17 m, warm cream, rounded and dry, the
    # slab's gentle rise to the west, scrape marks; the slate ends below it in a line at 962 along the ledge's
    # underside; two old bolt holes with rust under them on its east end's front, where the ladder's top bracket
    # was; the tea frog's woven doormat (2 m, x -348.9 .. -346.9) PAINTED FLUSH in front of the chute's mouth.
    # Carried back to the back wall's foot (-1.3).
    skin("cumbre_tea_floor", -349.0, -332.0, 962.0, 965.0, z_back=TEA_WALL, tone=CREAM)
    # THE LEDGE'S BACK WALL: the summit's tan rock, a step duller than the floor, closing the alcove from the floor
    # to the prow's underside (outline (-349, 965), (-340, 964), (-331.9, 964), (-331.3, 968.22), (-341, 968.4),
    # (-349, 970.4)); one painted piece, bedding long wavy lines of three tans, no blocks. Its face 1.3 m back up
    # to the lintel's line (966.8), then a dry shelf and the face set back to -2.1 under the prow (item 7g), where
    # the awning's two iron eyes are let in; the prow's black ice comes down onto its top in a glazed edge. One
    # little outcrop at its foot by the tunnel (x -347.6), standing 0.03 proud, carries a cushion of moss. The
    # shop's room is cut into it (next).
    back("cumbre_tea_back_wall", -349.0, -331.3, 964.0, 970.4, TEA_WALL, TEA_ROOM_BACK, tone=TAN)
    plant("moss", -347.6, 965.6, -1.29)
    # THE TEA SHOP'S ROOM (note 97): cut into the back wall under the paper, 6 m wide, 2.6 m tall, 2.5 m deep, its
    # front open so you look straight in; plank floor, plank walls, a plank lintel; warm AMBER on every surface
    # from the lantern and the stove, to its back (colour, never a glow), so it is a lit room and never a dark slot.
    back("cumbre_tea_room", -339.5, -333.5, FLOOR, 966.6, TEA_WALL, TEA_ROOM_BACK, tone=AMBER)
    # The shelf of tins along its back wall (the tea cave's: origin the middle of its back's foot, on the wall).
    A.deco("tea_tins_shelf", -337.4, 965.5, z=TEA_ROOM_BACK, size=(1.0, 0.5, 0.2), tone=WOOD)
    A.deco("tea_tins_shelf", -336.4, 965.5, z=TEA_ROOM_BACK, size=(1.0, 0.5, 0.2), tone=WOOD)
    # The counter: planks under a striped cloth, 2.4 m, set 0.5 m inside the room (its front at -1.8).
    A.deco("cumbre_tea_counter", -336.4, FLOOR, z=-2.1, size=(2.4, 0.9, 0.6), tone=WOOD)
    # The frog in its apron behind it, standing on an upturned crate so its head and hands show over the top
    # (notes 60, 97: this biome's frog; the kit's frog_apron, its hands at 0.20, the counter's top at 964.9).
    A.deco("cumbre_tea_crate", -336.4, FLOOR, z=-2.65, size=(0.45, 0.8, 0.4), tone=WOOD)
    A.deco("frog_apron", -336.4, 964.8, z=-2.6, size=(0.28, 0.32, 0.29), tone=ACCENT)
    # A row of six cups along the counter, the pot, and one cup set out at its east end, for you.
    for x in (-337.45, -337.2, -336.95, -336.7, -336.45, -336.2):
        A.deco("tea_cup", x, 964.9, z=-2.2, size=(0.12, 0.1, 0.11), tone=ACCENT)
    A.deco("tea_pot", -335.85, 964.9, z=-2.15, size=(0.25, 0.2, 0.18), tone=ACCENT)
    A.deco("tea_cup", -335.49, 964.9, z=-1.95, size=(0.12, 0.1, 0.11), tone=ACCENT)
    # Two stools at the counter's ends, just inside the recess (the nearest 1.35 m behind you).
    A.deco("cumbre_tea_stool", -338.0, FLOOR, z=-1.55, size=(0.4, 0.5, 0.4), tone=WOOD)
    A.deco("cumbre_tea_stool", -334.8, FLOOR, z=-1.55, size=(0.4, 0.5, 0.4), tone=WOOD)
    # The small iron stove in the east corner (the mine frog's), the cliffs' kettle on it steaming; its tin pipe up
    # through the room's roof, and the cowl where it comes out of the wall 3.4 m above the floor (the smoke is the
    # game's: east along the prow's underside and out past the lip).
    A.deco("mine_frog_stove", -334.1, FLOOR, z=-2.8, size=(0.6, 0.7, 0.5), tone=IRON)
    A.deco("tea_kettle", -334.1, 964.7, z=-2.8, size=(0.31, 0.27, 0.24), tone=IRON)
    A.deco("cumbre_tea_pipe", -334.1, 964.75, z=-2.8, size=(0.16, 1.85, 0.16), tone=IRON)
    A.deco("cumbre_tea_cowl", -334.1, 967.2, z=-2.0, size=(0.6, 0.45, 0.2), tone=IRON)
    # The warm spout in the west corner: a stone spout in the wall over a stone basin, a thread of warm water
    # between (glossy), steam on it (the game's); the frogs' spring's water, come down through the mountain.
    A.deco("cumbre_tea_spout", -338.95, FLOOR, z=-3.4, size=(0.9, 1.3, 0.8), tone="#A89A86")
    # The lit lantern on an iron hook under the lintel (the kit's lantern_hang: origin its hook; light: item 2).
    A.deco("lantern_hang", -338.55, 966.55, z=-1.45, size=(0.28, 0.52, 0.31), tone=GOLD)
    # Over the lintel, standing on the front edge of the dry shelf above it: a board with a painted cup and a curl
    # of steam, no words (origin the middle of its foot).
    A.deco("cumbre_sign_cup", -336.6, 966.8, z=-1.36, size=(0.8, 0.6, 0.06), tone=ACCENT)
    # THE AWNING: the town's paper, whole and bright, 9 m, tied to the two iron eyes in the set-back face 2 m back,
    # its lowest flag 3 m above the floor, clear of the prow (the line that was there, moved back and down).
    paper((-340.5, 968.0), (-331.5, 968.0))
    # THE TEAHOUSE CHUTE (the tunnel under the dome): its back wall, dark blue-violet ice in long painted bands,
    # 2 m back, from the frost wall's east face to the mouth (outline (-365.6, 977.55), (-349, 966), (-349, 970.4),
    # (-365.6, 981.97)); the dome's and the shoulder's skins carry its roof and floor back to it.
    back("cumbre_chute_back", -365.6, -349.0, 966.0, 981.97, CHUTE[1], CHUTE[0], tone="#3A3550")
    # Beside its mouth, on the back wall's face: the frog's painted board, a frog in a pool under a curl of steam
    # (the spring's sign; its fellow hangs on the bell frame's strut), at the foot of the mouth's 1 m drop.
    A.deco("cumbre_sign_frog_pool", -348.05, 965.95, z=-1.33, size=(0.7, 0.7, 0.06), tone=ACCENT)

    # ============================================================ 11.2 La Corona
    # THE FIVE TEETH: needles of the summit's tan rock one layer back (z -1.65 .. -1.4), each ONE painted piece in
    # two or three slanted planes, long wavy bedding lines, a leaning notched outline, a blunt tip just under its
    # gold (the boss's bronze neck comes forward from it); each with one little outcrop below its collar (proud to
    # -1.3) carrying a tuft of gold grass or a silver star-flower. The three in the open (the first, fourth and
    # fifth) are carried down to 953, behind the storm ridge's cloud top (a10_dress 7i: "the crown stands out of
    # the storm"); the second and third stand up from behind the dome (their feet 1 m under its surface).
    back("cumbre_tooth_a", -327.0, -324.2, 953.0, 970.25, -1.3, NEEDLE[0])
    plant("grass", -325.9, 964.6, -1.36)
    back("cumbre_tooth_b", -333.85, -331.35, round(dome_y(-332.6) - 1.0, 2), 976.45, -1.3, NEEDLE[0])
    plant("star", -332.9, 972.6, -1.36)
    back("cumbre_tooth_c", -340.85, -338.35, round(dome_y(-339.6) - 1.0, 2), 981.65, -1.3, NEEDLE[0])
    plant("grass", -339.9, 977.8, -1.36)
    # The fourth, with THE SPUR on its west flank, 14 m under its gold: a knuckle of rock (to x -330.3, 963.6 ..
    # 965.75) with the ring's eye bolt in its tip (the ring: its skin below).
    back("cumbre_tooth_d", -330.3, -327.2, 953.0, 979.65, -1.3, NEEDLE[0])
    plant("star", -328.2, 971.5, -1.36)
    # (The fifth, stouter, with its step: in 11.3.)
    # The five gold bosses (skins, line 182) and the first ring (skin, line 178) hung from the spur's eye bolt.
    for jx, jy in JEWELS:
        boss(jx, jy)
    ring(*RING0)
    # RIME (skins: the nose 176, the collars 184): hard grey-white frost feathers, pale and matte, cracked across
    # with the east corner gone, grown toward the west; each exactly the size that holds; a collar wraps its
    # needle (back to -1.65) and comes forward to you; the nose grows off the spur toward the ledge.
    A.deco("cumbre_rime_nose", -331.1, 965.175, z=-0.675, size=(0.8, 0.45, 1.95), tone=RIME, skin=True)
    for jx, jy in JEWELS[:4]:
        A.deco("cumbre_rime_collar", jx, round(jy - 2.3, 3), z=-0.675, size=(1.6, 0.5, 1.95), tone=RIME, skin=True)
    # THE FOUR GARLANDS (note 98): the town's marigolds swagged tooth to tooth from the needles' backs, 3 m or more
    # under their gold, hanging lower between; none behind a boss or a collar; behind a needle where they cross.
    garland((-325.6, 967.4), (-332.6, 973.6), 1.5)
    garland((-332.6, 973.6), (-339.6, 978.8), 1.2)
    garland((-339.6, 977.0), (-328.6, 974.8), 2.2)      # 0.7 m under the second collar, behind its needle
    garland((-328.6, 976.8), (-321.6, 976.4), 1.3)      # below the shelf's belly

    # ============================================================ 11.3 Las Cuerdas del Campeón
    # THE TWO CORNER POSTS (skins: the west horn 246-247 with its top 268; the east horn 248 with its widened half
    # 251): each horn cut square, a shaft of dark rock glazed with black ice 2.2 m thick, its three TURNBUCKLE
    # BLOCKS standing out of its inner face one above the other (2.5 m deep, to -1.3), each block's face sloping
    # exactly along its rope's line 0.2 behind it; long wavy bands of blue-black in three tones, white glints, an
    # IRON BAND PAINTED round the shaft at each rope's eye (dashed on the page); nothing pale on a post, nothing
    # on it can be held. The west post's top: 2.6 m of warm dry rock (994.7 .. 995.2); its outer foot loses a
    # corner. The east post's top cut level at 998.5 (chipped where the builders cut it) with its ice tip at
    # 999.9 at the inner corner. Each shaft carried back to -2.3, standing on its pillar's plinth.
    skin("cumbre_post_west", -332.2, -327.503, 984.085, WTOP, z_back=PILLAR[0])
    skin("cumbre_post_east", -323.297, -318.6, 985.585, 999.9, z_back=PILLAR[0])
    # THE PILLARS under the posts: tan rock, each one painted piece in two or three slanted planes, wavy bedding,
    # a leaning notched outline, the top 2 m cut square as a plinth for its post (the cut edge chipped), going down
    # into the cloud (to 953). Behind the east post the east pillar carries on up as a thin back blade (x -321 ..
    # -318.9, to 996.5). Two little outcrops on the west pillar's flanks, one on the east's.
    back("cumbre_pillar_west", -334.4, -325.8, 953.0, 984.4, PILLAR[1], PILLAR[0])
    plant("moss", -333.6, 978.6, -1.66)
    plant("grass", -326.3, 977.4, -1.66)
    back("cumbre_pillar_east", -325.4, -318.2, 953.0, 996.5, PILLAR[1], PILLAR[0])
    plant("moss", -318.8, 984.2, -1.66)
    # THE RING'S LAST FLOOR BEAM AND ITS APRON: one beam of weathered grey timber (0.4 square) spanning from pillar
    # to pillar at 983.6 .. 984.0, its ends let into them, the broken stubs of five joists standing up off it
    # between the posts; the cream canvas folded over it and hanging down its front 1.7 m as a torn apron (x
    # -328.6 .. -323.2, to 981.6), with a faded pug's face. Behind the line of every fling.
    back("cumbre_ring_apron", -329.4, -322.6, 981.6, 984.35, -1.7, -2.15, tone="#D8CDB4")
    # THE FIFTH TOOTH with its step: stouter, at 979.2 its body makes a step 4.2 m wide whose front edge is the
    # shelf, carried on 1 m further back (z -1.25 .. -2.3) with the fallen post lying on it; a blunt tip under its
    # gold at 981.65; carried down to 953.
    back("cumbre_tooth_e", -323.6, -319.4, 953.0, 981.65, BACK, PILLAR[0])
    plant("grass", -322.0, 972.0, -1.36)
    # THE SHELF (skin, lines 188, 192): warm dry rock on top, 2.6 m wide; its belly glazed black ice, no pale mark.
    skin("cumbre_shelf", -322.9, -320.3, 976.9, SHELF, z_back=BACK, tone=CREAM)
    # The rime block on the shelf (skin, line 189), on the windward side of the fifth needle.
    A.deco("cumbre_rime_block", -321.6, SHELF, z=0.0, size=(1.0, 0.8, 0.8), tone=RIME, skin=True)
    # THE FALLEN POST: the ring's third corner post, broken off at 2.2 m, weathered grey, lying on the step with its
    # red pad out over the drop (east). The frog that shows the move sits on its end: the game's (item 8).
    A.deco("cumbre_timber_head_fallen", -319.9, SHELF, z=-1.5, size=(2.2, 0.4, 0.4), tone=GREY_WOOD)
    # THE EAST POST'S TIMBER HEAD: the west head's fellow, 3 m, its three iron eyes facing the ring (west) and a red
    # pad, weathered grey, standing on the back of the east shaft's level top, 1.5 m behind you.
    A.deco("cumbre_timber_head_grey", EAST_HEAD_TOP[0], 998.5, z=-1.5, size=(0.4, 3.0, 0.4), tone=GREY_WOOD, flip=True)
    # THE BACK RUNS: what is left of the ropes round the back of the ring, faded, matte, frayed, 0.3 thick. The
    # jade top rope still spans from the flagstaff's top to the east head's top, sagging 0.3 (made in place, its
    # west end 2 m back, its east end 1.5 m back), the town's paper hung on it; the red and the cream ones snapped,
    # their frayed ends hanging down the backs of the posts from the eyes at each rope's top (two each, the east
    # ones flipped), none across the gap you fly through.
    back("cumbre_back_rope_jade", HORN_STAFF[0], EAST_HEAD_TOP[0], 1000.9, 1001.65, -1.45, -2.05, tone="#6E9C8C")
    paper(HORN_STAFF, EAST_HEAD_TOP, z=-1.8)
    for x, y, stem, flip in ((-330.05, 987.8, "cumbre_back_rope_end_red", False), (-330.0, 991.4, "cumbre_back_rope_end_cream", False),
                             (-320.75, 989.3, "cumbre_back_rope_end_red", True), (-320.75, 992.9, "cumbre_back_rope_end_cream", True)):
        A.deco(stem, x, round(y - 1.8, 2), z=-1.45, size=(0.4, 1.8, 0.3), tone="#B07A70" if "red" in stem else "#CDBFA0", flip=flip)

    # ============================================================ 11.4 El Último Salto
    # THE TIMBER HEAD (skin, line 269): square honey timber 0.4 thick, 3 m tall, its three iron turnbuckle eyes
    # standing out of its east face 0.9 m apart like rungs (996.0, 996.9, 997.8, 0.12 proud), a red pad on top
    # (997.9 .. 998.2); the only timber in the ring you can hold.
    A.deco("cumbre_timber_head", -332.0, WTOP, z=0.0, size=(0.4, 3.0, 0.4), tone=WOOD, skin=True)
    # THE SPLINTER that carries the ring: a splinter of the west pillar, split off its flank at 976.5 (its foot let
    # into the pillar, -1.9) and standing 21 m, leaning 3 m west into the wind, to a point too narrow to stand on
    # 0.15 m under the ring (outline (-333.08, 976.5), (-332.72, 982.5), (-335.45, 998.05), (-335.95, 998.05));
    # tan rock, bedding lines along its length; the eye bolt in its point (made in place).
    back("cumbre_splinter", -335.95, -332.72, 976.5, 998.05, NEEDLE[1], -1.9)
    # The ring of the last leap (skin, line 271), level with the pad (note 99), on the splinter's eye bolt.
    ring(*RING4)
    # THE FLAGSTAFF: 6.3 m, standing at the back of the post's top behind the timber head (item 7i) and raked
    # back, its top 3.3 m over the pad and 2 m back (made in place: foot z -1.3, top -2.05); it carries the west
    # end of the jade back run and the paper over the leap.
    back("cumbre_flagstaff", -332.1, -331.9, WTOP, HORN_STAFF[1], -1.3, -2.05, tone=WOOD)
    # THE PAPER OVER THE LEAP: whole and bright, 30 m, from the flagstaff's top to the bell staff's top, over the
    # line of the leap: its flags 3.6 m over the ring and 2.5 m over the bell frame's beam.
    paper(HORN_STAFF, BELL_STAFF)

    # ============================================================ 11.5 La Campana (and 11.6, 11.6b)
    # THE BELL FRAME (skin, lines 285-287; the kit's bell_frame re-made at the course's sizes): honey timber
    # squared with an adze, the post 0.5 thick and 6.6 tall footed in the apex, the beam 6.8 m (1.1 m past the post
    # to the west), the brace; the marigold garland PRESSED FLAT wound up the post's face and laid along the beam's
    # front face (part of the timber, held with it); the belt's two BRONZE PEGS 0.5 m tall on the post's top (the
    # belt on them is the Top Dog session's deco); a square cleat run back from the post's back at 1003 .. 1004.2
    # to -1.3 for the strut and the bell staff (item 7i).
    skin("cumbre_bell_frame", -361.6, -354.8, 999.8, 1006.9, z_front=0.25, z_back=-1.3, tone=WOOD)
    # The iron hanger and pin under the beam's east end (skin, line 288, once shortened: item 6b); the fork that
    # holds the bell's crown is the bell's own and swings with it.
    skin("cumbre_bell_hanger", -355.95, -355.45, 1004.95, BEAM[0], z_front=0.4, z_back=-0.4, tone=IRON)
    # THE BACK STRUT: a square timber 0.3 thick from the cleat at the post's back (1004.0, -1.3) down to the head of
    # the peak's back (-362.4, 1000.8, -3.0), so a frame with one post is seen to be held (made in place).
    back("cumbre_bell_strut", -362.55, -360.15, 1000.8, 1004.15, -1.3, PEAK_FACE, tone=WOOD)
    # On it under the beam's west end, facing you as you walk the beam: the frog's sign, a frog in a pool under a
    # curl of steam (note 102: the way west is past the belt). The strut is 2.3 m back there.
    A.deco("cumbre_sign_frog_pool", -361.6, 1001.65, z=-2.28, size=(0.7, 0.7, 0.06), tone=ACCENT)
    # THE BELL STAFF: 8.2 m, lashed to the cleat at the post's back and raked back, hidden by the post from the
    # side until it rises above the belt, its top 4.8 m over the post's top and 2 m back (made in place).
    back("cumbre_bell_staff", -360.4, -360.2, 1003.0, BELL_STAFF[1], -1.3, -2.05, tone=WOOD)
    # THE WEST LINE OF PAPER: from the bell staff's top down over the notch and the steam to the staff on the
    # peak's back above the shoulder (the line that ended in the air now goes somewhere).
    paper(BELL_STAFF, WEST_STAFF)
    # THE PERCH (skin, line 296): warm dry rock, 2.1 m, the timekeeper's seat (the one who sits is the game's statue).
    skin("cumbre_perch", -359.1, -357.0, 997.9, 998.7, z_back=BACK, tone=CREAM)
    # THE RIB under it: warm rock coming forward out of the peak's back, 1.3 m behind you, the perch its top, its
    # top carried on 1 m behind the perch (outline (-359.6, 988), (-357.6, 988), (-356.7, 998.2), (-356.7, 998.7),
    # (-359.6, 998.7); made in place, z -2.2 .. -1.3); and his marigolds on its top, beside him, on the rope's side.
    back("cumbre_perch_rib", -359.6, -356.7, 988.0, 998.7, -1.3, -2.2, tone=TAN)
    A.deco("marigold_pile", -357.2, 998.7, z=-1.75, size=(0.86, 0.42, 0.36), tone=ACCENT)

    # ============================================================ 11.0 The frogs' hot spring (west of the belt)
    # THE SHOULDER (skin, every convex piece of line 125): black ice, one painted piece, a few big planes, long wavy
    # blue-black bands, white glints; where the cave, the sink, the stair's chimney and the slide's mouth are cut
    # away to the camera, the ice is a skin over WARM ROCK, a band about 1 m thick round each cut (ochre and cream,
    # crusted with pale mineral, long wavy bands); the sink's shaft (smooth wet warm rock, opening in the cave's
    # roof over the deep end), the chimney and the slide's mouth have their inside walls back to -1.5; the tunnel's
    # floor carried back to the chute's back wall; its body carried back to -3.0 behind the cave.
    skin("cumbre_shoulder", -390.2, -349.0, 962.0, 996.0, z_back=CAVE_BACK)
    # Its snow cap, CUT BACK (foreground, in front of solid ice only): set 1.3 m back from the slope, west of x
    # -375.2 above 976.4 and west of -380.6 below, so the cave, the sink and the slide are never covered.
    front("cumbre_snow_cap_shoulder", -389.5, -375.2, 963.0, 994.2, 2.0, 2.05)
    # THE DOORSTEP (skin, lines 129, 130): warm dry summit rock cut level at 978.3 under the eave, the chimney's
    # mouth between its two parts, two frog prints worn into it; carried back to the sink's back.
    skin("cumbre_doorstep", -368.4, -366.5, 977.9, 978.3, z_back=-1.5, tone=CREAM)
    # THE FROST WALL (skin, line 133): hoarfrost across the tunnel's top, 0.9 thick and 5 m tall under the dome's
    # west corner, the rime's look (grey-white, matte, cracked across), a corner gone at its foot (the tea frog's
    # door); across the tunnel to its back wall (-2.0). Whole only: its breaking and growing back are effects.
    skin("cumbre_frost_wall", -366.5, -365.6, 977.55, 982.6, z_back=CHUTE[1], tone=RIME)
    # The stair's ring (skin, line 140) in the chimney's back wall; the rope and its handle are the course's.
    ring(*RING_S)
    # THE BANK (skin, lines 150, 151): 2.8 m of dry bank, pale mineral crust, the place to climb out and sit; and
    # west of it the slick lip falling into the pool, glossy wet crust with three rounded wet stones on it (never a
    # hold: item 7f).
    skin("cumbre_spring_bank", -368.2, -364.0, 969.8, 971.0, z_back=BACK, tone=WARM)
    # THE SLIDE'S RIM (skin, line 156): a low rim of rounded stone standing 0.3 out of the water at the pool's far
    # west end; the slide's mouth behind it (in the shoulder's skin), and across the back of the mouth the town's
    # marigolds (the kit's garland, 2.6 m, just behind the play space): "wreathed in marigolds".
    skin("cumbre_slide_rim", -377.4, -377.0, 969.8, 970.9, z_back=BACK, tone=WARM)
    A.deco("marigold_garland", -378.3, 970.95, z=-1.35, size=(2.6, 0.68, 0.1), tone=ACCENT)
    # THE SPRING'S CAVE (the frogs' hot spring, maker A): the room inside the shoulder, cut away at the front, from
    # -1.25 back to its back wall at -3.0: ochre and cream rock crusted with mineral, painted in long wavy bands,
    # no ice; dark and wet above the steam; the roof's underside carried back (974.0 east, 974.9 west); along the
    # back wall 2 m over the water a ledge 6 m long for frogs (x -376 .. -370, top 972.6, out to -2.6); a crack in
    # the east wall where a rill leaves (to the tea shop's spout); THE POOL'S BACK HALF, milky blue-green, its
    # surface flush at 970.6 from -1.25 to the back wall (the front half is the game's water), its basin's back
    # rim; the bank's back half (the table and towels stand on it).
    back("cumbre_spring_cave", -379.6, -364.0, 969.8, 975.0, BACK, -3.2, tone=WARM)
    # The frog-on-a-slide board over the slide's mouth, on the back wall.
    A.deco("cumbre_sign_frog_slide", -378.8, 972.9, z=CAVE_BACK + 0.03, size=(0.7, 0.7, 0.06), tone=ACCENT)
    # About thirty frogs, all the same little frog as every biome's (the kit's wave 0 frogs), every one 1.3 m or
    # more behind you: in the water to their eyes in two rows (frog_soak faces east, frog_soak_b west with its eyes
    # shut; origin the waterline), along the back rim, on the back wall's ledge, on the back of the bank; a few
    # with what their biome's frog has (a teacup, a blanket, a ticket).
    for k, x in enumerate((-376.2, -375.2, -374.2, -373.2, -372.2, -371.2, -370.2, -369.2)):
        A.deco("frog_soak" if k % 2 == 0 else "frog_soak_b", x, 970.6, z=-1.55, size=(0.26, 0.11, 0.27), tone=ACCENT)
    for k, x in enumerate((-375.7, -374.7, -373.7, -372.7, -371.7, -370.7, -369.7)):
        A.deco("frog_soak_b" if k % 2 == 0 else "frog_soak", x, 970.6, z=-2.3, size=(0.26, 0.11, 0.27), tone=ACCENT)
    for x in (-376.4, -374.6, -372.8, -371.0, -369.2):
        A.deco("frog_sit", x, 970.6, z=-2.85, size=(0.26, 0.26, 0.27), tone=ACCENT)
    for x, stem, size in ((-375.6, "frog_sit", (0.26, 0.26, 0.27)), (-374.7, "frog_asleep", (0.3, 0.22, 0.2)),
                          (-373.8, "frog_blanket", (0.34, 0.26, 0.33)), (-372.9, "frog_tea", (0.25, 0.26, 0.29)),
                          (-372.0, "frog_sit", (0.26, 0.26, 0.27)), (-371.1, "frog_asleep", (0.3, 0.22, 0.2))):
        A.deco(stem, x, 972.6, z=-2.8, size=size, tone=ACCENT)
    A.deco("frog_ticket", -370.2, 972.6, z=-2.65, size=(0.26, 0.33, 0.29), tone=ACCENT)   # (origin: its seat at the ledge's front edge)
    for x, stem, size in ((-367.6, "frog_tea", (0.25, 0.26, 0.29)), (-366.9, "frog_blanket", (0.34, 0.26, 0.33))):
        A.deco(stem, x, 971.0, z=-1.6, size=size, tone=ACCENT)
    # At the back of the bank, 1.4 m back: a low table (the tea cave's) with its pot and two cups, one set out for
    # you, and a pile of folded towels.
    A.deco("tea_table_low", -365.9, 971.0, z=-1.75, size=(0.9, 0.35, 0.6), tone=WOOD)
    A.deco("tea_pot", -366.1, 971.35, z=-1.8, size=(0.25, 0.2, 0.18), tone=ACCENT)
    A.deco("tea_cup", -365.75, 971.35, z=-1.8, size=(0.12, 0.1, 0.11), tone=ACCENT)
    A.deco("tea_cup", -365.55, 971.35, z=-1.55, size=(0.12, 0.1, 0.11), tone=ACCENT)
    A.deco("cumbre_towels", -364.55, 971.0, z=-1.75, size=(0.6, 0.45, 0.45), tone="#EDE3CF")
    # Three candle lanterns hung from the roof at the back (the kit's lantern_hang: origin its hook; lights: item 2).
    for x, y in ((-377.0, 974.47), (-373.8, 974.22), (-365.6, 973.92)):
        A.deco("lantern_hang", x, y, z=-2.6, size=(0.28, 0.52, 0.31), tone=GOLD)
    # The peak's back above the shoulder: its little outcrop with a cushion of moss and a tuft of gold grass, and
    # the west staff on its skyline (the kit's flagstaff piece at 0.873: 5.5 m, foot at 997.15, raked back to -2.1).
    plant("moss", -376.85, 995.4, -2.85)
    plant("grass", -376.3, 995.4, -2.85)
    A.deco("cumbre_flagstaff", -381.95, 997.15, z=-2.475, scale=0.873, size=(0.2, 6.3, 0.75), tone=WOOD)
