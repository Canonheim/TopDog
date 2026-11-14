"""
EL TELEFERICO, DRESSED: the scenery of all of biome 8, the abandoned cableway off the mountain's east
face (y 684 to 790), from the twelve area pages (the challenges 8.1 to 8.11 with the frog's gondola
8.0) in docs/peak/playtest/design/data/a8_areas.py and the biome's sheet a8_biome.py (its `built`,
`looks`, `layers` and `kit`, and KIT_MORE). The join "7 to 8" is the cliffs' page (a7_dress.py places
the deck, what carries it, the house, the sock, the pennant line along the house and the haul cable):
this file places our end of it, page 8.1's: the gangway and its rail post, the real roof over the
deck, the booth and the pug sign on the house's wall, the end frame with line 1's bull wheel and the
wind engine, the pulley the haul cable comes up to, and the middle tower rising behind the ridge. The
join "8 to 9" is page 8.11, the high station: this file places all of it to where the planks meet the
rock; the glacier's lip on the roof, its fringe and the way west are biome 9's.

Parker, 11-13 (third round, ANSWERS.md 6 to 8): THE ROOFS ARE REAL (solid, held, stood on: the fix
thread built them at db45483), so each station roof's look is a SKIN on its solid (MODELLING_RUN rule
4); the gondolas' hangers stay solid and held and are drawn as holds (a cream band round the top
0.5 m); only the four chairs' poles are not touchable; a cream band marks a hold, and cream is never
painted on scenery; wind engines drive the lines; the chairs are plain benches; no rung under pylon
1's perch. The fix thread (notes 77 to 82): El Cable gone (one fling from line 2's rack to pylon 2's
landing); the chairs' rods not solid; El Pilon's brace and rung gone; the zip line runs to the
maintenance deck; every gondola's step and rack drawn as plain iron bars until the gondola is re-made.
The look (the sheet): riveted steel lattice, angle iron with a pug plate at every joint, the
cableway's red sun-faded and peeling to rust orange; every cable black and greased, 0.15 m, 2 m
behind the climb; everything that carries (towers, cables, carriages, chair poles, bull wheels,
engines, houses) a flat cut-out in a greyed brick red, NO CREAM; everything you hold in the play
space, red with a cream band on the edge you take, or the station roofs' red and cream striped tin.
Mostly sky: late-afternoon gold, long blue-violet shadows; the only lit lamp is in the frog's car.
Rock (El Colmillo and the mountain's face) is painted by the walls rule (BRIEF.md "Walls and masses",
`docs/peak/playtest/design/walls_example_after.png`): a few big slanted planes of dark brown polished
to a gloss, the beds as long wavy lines and bands in three or four browns, no streaks, nothing that
tapers to a point, no slot cut into a face; on the fang the only white is the thirteen chalk blocks,
the foot ledge and the rib, each a plain block or band with square ends.

Scenery only: decos. Nothing here can be stood on or held. The course (the gangway, the roofs, the
perch, the landing, pylon 2's legs, the sheaves, the head and its tarred roof, the fang and its
holds, the plate and post, the maintenance deck, pylon 3's head, the grate, the high deck, and every
mover: the eight gondolas, the dead car, the chairs, the zip trolley and the counterweights) is
a8.py's. The model list this file makes is docs/peak/models/a8_models.md.

Depth: the play space is z -1.2 .. 1.2. Everything here stands behind -1.25 or in front of 1.25,
except SKINS (skin=True), each the LOOK of course solids, filling them (the two roofs' skins carry
their back halves on to the ridge, z -5.5; the decks' skins carry their floors back to where things
stand on them: the landing and pylon 3's head to -1.8, the maintenance deck to -2.3, pylon 2's head
and the grate to -2.6). From the back: the far line, ONE flat cut-out card 20 m back (z -20.5 ..
-20.0) east of the shoulder, its legs fading into haze below 640 so its foot never shows (EAST OF
THE SHOULDER NOTHING ELSE OF OURS STANDS: the painted valley, the two ranges and the cloud banks are
given and already in the game; the old stand-in cards are not put back); the mountain's shoulder,
three flat cards at z -13 continuing the cliffs' four, west of their stepped edge only; the station
houses -5.6 .. -2.4; the wind engines and their masts -3.4 .. -3.0; the towers and the end frame
-2.8 .. -2.5 (each a flat lattice in bays 4 m tall, the middle tower standing on the low roof's back
half because the house fills the depth under it, the express tower on the link girder); the girders, arms, brackets, pulleys and belts
-2.9 .. -2.15; the cables, the guide and bull wheels, the snapped ends and the carriage stub -2.3 ..
-1.9; the pennant lines -2.35 .. -2.05; the fang's far horn -4.0 .. -1.5 and the face's bodies
-3.0 .. -1.25; the parked car, its siding and the frog -2.3 .. -1.25 (the car's open side at -1.25,
its floor level with the perch); the chair shed -2.3 .. -1.9; the dock ice under the high deck -6.0 .. -1.3;
the sockets, crests, lanterns, boxes, oil can and grease pot between -1.25 and -2.7. In front: only
the high deck's platform post (0.3 m, in front of the deck's west end where nothing has to be read)
and its lip of drifted snow (under 0.3 m above the planks). No cable, pennant or cloud passes in
front of you.

A deco's origin is the middle of its base (x and z) at its foot (y), unless its comment says
otherwise: a wheel, a pulley, a drum or an engine its hub; a cable or a belt its middle, on its
centre line (it is made running +x and laid by `rot`); a snapped cable end and the zip buffer's
spring their top; wall-mounted things (the sign, the bracket, the timetable card) the middle of their
foot on the wall; a stay its lower end. For the long pieces (bodies, cards, girders, skins): the
middle of the x span, the bottom of its box, the middle of its depth. A deco's size is the size its
model is MADE at (the game rescales a landed model more than a quarter off); where one model is used
at several sizes, `scale` does it and the size is the model's own. `rot` is in degrees, counter-
clockwise as the camera sees it (a positive rot tips a thing's top to the west). A tower's bays
alternate `flip` so the braces zigzag.

Shared pieces are placed once, in the first section that names them: the far line and the middle
tower (8.1, 8.10), pylon 1 and its streamer (8.1, 8.0, 8.2), the link girder (8.0, 8.2), line 2's
towers (8.2, 8.3), pylon 2 and its span arm (8.3 to 8.8), the chair shed (8.4, 8.5, 8.7), pylon 2's
engine (8.4, 8.7, 8.8), the fang's horn (8.6, 8.7), the counterweight frame and the long girder (8.8,
8.9), pylon 3 (8.8, 8.9), the express tower (8.9, 8.10), the shoulder (8.10, 8.11).

FOR THE AREA FILE (tools/peak/areas/a8.py; the fix thread's). Line numbers are a8.py's as of
2026-11-14 04:00 (the version with the real roofs, db45483).
  1. Call it: `import a8_dress` beside the other imports (line 27), and `a8_dress.dress(A)` after the
     cameras (line 457), before `if __name__ == "__main__":` (line 459), so before A.save().
  2. Lights. Take out the five lit `lantern_station`s and their lights (lines 442-444: every lantern
     on the cableway is cold but the frog's; this file places the cold ones on walls and decks). Add
     the frog's (page 8.0, the one warm light for 100 m): `a8_dress.FROG_LIGHT`, "#FFB860", range 4,
     energy 0.9, flicker. KEEP line 445 (the fang's top in the last sun, page 8.6).
  3. Decos to take out (this file places what the pages keep, out of the play space): the four
     `bull_wheel`s at z -1.1 (lines 425-428: line 1's and line 2's station wheels move back to 2 m as
     greyed scenery, the pylon wheels become guide wheels), the two `station_sign_pug`s (429, 430:
     onto the houses' walls), the two `pug_crest_peeling`s (432, 433: the shed's gable and pylon 3),
     the toolbox (434: back to 1.3 m), the oil can (435: back to 1.3 m), the ticket booth (436:
     against the house's wall), the seven `pennant_line`s at z -0.6 (439-441: moved back and up; the
     zip line's, the cable's and the express lines' lower one go), and the lanterns (item 2). KEEP
     line 437, the frozen glove (page 8.11: "0.6 m back today and stays there", in the play space by
     design); its made size is 0.34 x 0.21 x 0.18.
  4. Cards to take out: every tower() card (lines 136, 180, 299, 406-409: each tower stands here 2.5
     m back as lattice bays), and every wire(): the dead car's crossarm (298), the high deck's strut
     (382: two lattice brackets here), the line wires and the zip wire (412-413), the express wires
     (414-415), the chair wire (416), the counterweights' wires (417-418), the frame's top beam (419),
     the bare cable (420: El Cable is gone) and the hanger's wire (421). Effects: take out the clouds
     (line 401: the sheet, "behind those there is only the far view that is given", and the cloud
     floor hides the valley and the town that should lie straight under the cars). KEEP the gold dust
     (402) and the snow (403).
  5. Skins. Each named solid takes `skin=` its stem; this file places every skin deco.
     - The gangway and its rail post, lines 100, 101: "tele_gangway" (its model also paints the
       warning stripes on a7.py's deck east of it, x -236.7 .. -236.0, page 8.1, note 78).
     - The low station's roof, line 107: "tele_roof_low"; the high station's roof and its glaze,
       lines 388, 389: "tele_roof_high".
     - Pylon 1's perch and its post, lines 134, 135: "tele_perch".
     - Pylon 2's two legs, lines 177, 178: "tele_pylon2_leg" (one skin each); its landing, 179:
       "tele_landing"; its head, 183: "tele_head_deck"; the tarred roof's two slopes, 193, 194:
       "tele_tar_roof".
     - El Colmillo, line 220, with its foot ledge (236) and rib (237): "tele_colmillo"; the thirteen
       chalk holds (243, each A.hold): "tele_chalk_block" (thirteen skins, at a8_dress.KNOBS); the
       anchor plate and the zip line's post, 244, 245: "tele_fang_anchor".
     - The maintenance deck, line 269: "tele_maint_deck".
     - Pylon 3's head and its rail post, lines 294, 295: "tele_head_p3" (it wears the warning stripes
       on its last 0.6 m and the post, page 8.9, note 78).
     - The grate, line 363: "tele_grate".
     - The face, A.wall (line 97): wall() wants a `skins` like cave()'s, by edge: edge 0 (684 to 704)
       "tele_face_a", 1 (704 to 727) "tele_face_b", 2 (727 to 752) "tele_face_c", 3 (752 to 784)
       "tele_face_d"; the plug behind the high deck's west end (379) "tele_face_d".
     - The high deck (373-375, 380, 381) keeps the course's own look: the game draws its ice and its
       black ice, and a model over the sheets would fight them. (Page 8.11 wants all three dry patches
       plank: item 6c.)
  6. Course changes the pages ask for (not scenery):
     a. 8.6 (the walls rule): the fang's east side, which holds nothing, takes the designed outline
        (a8_areas._FANG_OUTLINE: (-158.5, 697), (-159.2, 701.5), (-159.7, 705.4), (-160.6, 705.6),
        (-160.6, 707.3), (-161.6, 710.4), (-161.5, 714.6), (-163.3, 718), (-163.2, 721.8), (-164.3,
        724.4): it leans up to 0.8 m and is notched 0.9 m deep at 705.6 .. 707.3) in place of the
        three straight edges of line 220. `tele_colmillo` is made to that outline.
     b. 8.7 (note 77): only the bar and the stem of the zip trolley are solid: take the body (the
        first shape, 0.5 x 0.22, line 265) out of the mover. Its road ends at (-193.0, 722.9); the
        page has (-193.0, 723.0), the bar at 722.1: the fix thread's call (0.1 m).
     c. 8.11: "The course gives two of them the rock's colour today. All three are plank": the dry
        patches at x -277.6 .. -276.4 and -282.0 .. -280.6 (lines 373-374) become "plank".
     d. 8.2 and 8.1 (note 77): in gondola() (lines 82-90) the model follows the step: wr 0.9 (lines
        1 and 2, four cars) "gondola" re-made, wr 0.6 (the express cars, line 362)
        "tele_gondola_express"; when both land, drop `drawn=` (item 8).
     e. 8.8 and 8.9: the frozen climber sitting at the back of pylon 3's head, his back to the tower,
        looking west at the dead gondola: the climber's own model in the "sit" pose, frosted, pelvis
        about (-202.3, 749.4), z -1.5, facing -x. Nothing climber-shaped is modelled until the new
        climber model lands (MODELLING_RUN), and A.statue() is solid at the play plane, so he wants a
        scenery statue (a z, not solid). Until then leave him out; nothing here stands in for him.
     f. 8.8 (to settle): the weights take 10 s a round, the express cars 10.25 s a run; the page says
        they are one machine (the top wheel turns with the express drum), so the times should match.
     g. 8.10 (to check when the crunch rule is built): a climber on the grate has 2 cm under the
        express car's step when it stops (page 8.9); if a standing head can be caught, the grate goes
        down 0.2 m (and `tele_grate` with it).
  7. Found while dressing, not on a page:
     a. a7_dress.py places the kit's `cable_station_low` (14.1 m, with its own striped roof and cream
        on its wall) at (-243, 688, z -4). Under the real roof its top (694.06) rises through the
        roof's back half (693.2 at the house's front wall), it carries cream (never on scenery here),
        and its east end (-235.95) stands 1.65 m past the roof's east end (-237.6), into the end
        frame. Page 8.1 wants the house re-made 12 m wide without its roof (6 m at its back wall, its
        front wall lower, under the slope): a8_models.md lists it as a re-make; a7_dress then places
        it centred at -244.0 (x -250 .. -238) with size (12.0, 6.0, 3.12).
     b. a7_dress.py's `riscos_haul_cable` runs both its runs up to a wheel over the dock at (-237.2,
        697), r 2.2. Page 8.1 moves that wheel 5 m east into line 1's loop (-232.2, 696.3) and brings
        the haul cable up under the loop to a pulley at the foot of the end frame (-233.0, 688.6),
        then on up the frame to the engine. This file places the pulley and the run up the frame;
        a7's piece is re-cut so both runs end on that pulley (a7_models.md, maker C).
     c. st.json (the shared structure) places six white clouds in this biome's sky: cloud_c (-214.0,
        710.3, z -78.9), cloud_d (-165.4, 721.2, -34.2), cloud_e (-177.9, 731.4, -67.3), cloud_a
        (-222.9, 753.8, -63.5), cloud_b (-210.3, 764.8, -71.4), cloud_c (-190.9, 777.7, -29.3):
        clouds of our own, which the sheet says never. Whoever owns st.json takes them out, or rules
        them part of the given far view (a7_dress item 7b asks the same).
     d. The middle tower (page 8.10: "it stands on the low station far below", 2.5 m back) cannot
        stand 2.5 m back on the deck: the house fills z -2.44 .. -5.56 there. It stands here on the
        low roof's back half at z -2.65 (its foot plate on the tin at 693.3).
     e. The far line stands 20 m back, so from the cliffs' cameras its foot at the sheet's "below the
        frame" would show in the sky (at that depth it slides to 0.4 of the camera's offset): its
        legs run down to 620 and fade into painted haze below 640.
     f. The chair line's cable meets the tarred roof's east slope where page 8.5 puts its guide wheel
        (-189.4, 717.1) and chair 1's pivot (-188.5, 716.5): the roof's skin stops at z -1.85 so the
        cable and the wheel (z -2.0) pass behind its back edge, and the shed has its own gable.
     g. The express pennant line's two ends stood in the air (page 8.10 draws it from (-223.75, 774.5)
        to (-259.75, 791.9)). Here the same line is tied to the express tower's top (777, 5 m above
        the page's 772) and to the middle tower as it passes, and carries on west to the frozen
        engine's mast (page 8.11's frozen line).
     h. The face's first slab reaches below 684 (its corner at 681.84) and behind a7.py's chalk plug
        (x -253 .. -250, 686 .. 688): `tele_face_a` leaves both to a7's skins (`riscos_west_face` to
        684.02, `riscos_chalk_plug`), cut round them.
     i. The express tower (page 8.9 draws it from 740 up, "rising from below the frame") stands at x
        -221.7 .. -218.7: brought down below the frame it would stand 2.5 m behind the gap of 8.2's
        jump (rack tip -224.7 to step tip -218.6 at 694). Here it stands on the link girder's top
        (709), which is directly under it.
     j. Pylon 3 (x -205.0 .. -202.4, 2.5 m back) rises from below the frame as the sheet asks, so it
        stands behind 8.3's long fling (from (-206.7, 698.3) to (-196.0, 703.0)), which page 8.3 does
        not draw. Today's card (line 299) stands there too. Judge it in the frames; if it clutters the
        jump, the page decides what carries pylon 3 instead.
  8. Movers' looks (the area file's; models in a8_models.md, re-makes and section 4):
     - the four cars of lines 1 and 2 (g1a, g1b, g2a, g2b): `gondola` re-made with the boarding step
       (0.9 m) and the freight rack (2.4 m) really modelled, rust-orange iron with a cream band along
       the top and a cream knuckle on each tip, exactly along their solids; the hanger red with a cream
       band round its top 0.5 m; its cranked head and the carriage on the cable 2 m back (greyed, no
       cream) in the same model. Then drop `drawn=`.
     - the four express cars (ex1 .. ex4): `tele_gondola_express`, the same car with a 0.6 m step (a
       cream band on its top and a cream lip underneath, where a raised hand meets it) and a 2.4 m
       rack.
     - the dead car: `gondola_dead` re-made: every solid part at its true size (the roof in two
       pieces with the hatch between, the floor, the end walls, the one arm, and the 1.6 m rack exactly
       along its solid), cream bands on the roof's edges, the hatch's rim, the floor's edge, the rack
       and the arm's top 0.5 m; the back door hanging open by its top hinge with the peeling pug crest;
       the arm's cranked head and its carriage on the long girder's rail, 2 m back.
     - the chairs: `chair` re-made as a plank bench 1.2 x 0.25 with a cream front edge, no back and no
       arms, its pole fixed to the seat's back edge and cranked back out of the play space to the cable
       2 m behind (greyed red; note 80).
     - the zip trolley: `zip_trolley` re-made: the cream bar 0.7 m and its stem 0.9 m in the plane, the
       stem cranking back at its top to the trolley's wheels on the line 2 m back (item 6b).
     - the counterweights: `counterweight_hung` re-painted if it is not so: a cream block with two red
       bands and the pug on its face, an iron lifting eye 0.5 m on top, and a short arm cranked back
       from the block's back to the cable 2 m behind (greyed).
     - the sheaves keep the kit's `cable_sheave` (already made to their collider).
     - things that turn (after the dress call): the bull wheels, the guide wheels and the drums roll
       with the car on their line, the engines spin with the sheaves:
         A.follow("tele_bull_wheel_grey", (-232.2, 696.3), "g1a", "roll", r=2.2)
         A.follow("tele_bull_wheel_grey", (-214.2, 697.72), "g2a", "roll", r=2.2)
         for p in (D_LO, E_LO, E_HI, D_HI): A.follow("tele_guide_wheel", p, "g1a", "roll", r=0.5)
         for p in (W_LO, E2_LO, E2_HI, W_HI): A.follow("tele_guide_wheel", p, "g2a", "roll", r=0.5)
         for k in range(4): A.follow("tele_guide_wheel", a8_dress.EX_ARM_WHEELS[k], "ex%d" % (k + 1), "roll", r=0.5)
         for k in range(4): A.follow("tele_guide_wheel", a8_dress.SADDLES[k], "ex%d" % (k + 1), "roll", r=0.4)
         A.follow("tele_winding_drum", (-220.2, 755.2), "ex1", "roll", r=0.9)
         A.follow("tele_bull_wheel_frosted", (-269.0, 788.2), "ex4", "roll", r=2.2)
         A.follow("tele_top_wheel", (-198.7, 757.4), "cw_a1", "roll", r=1.6)
         A.follow("tele_wind_engine", (-234.4, 706.2), "g1a", "roll", r=2.5)
         A.follow("tele_wind_engine", (-192.5, 730.0), "sheave1", "spin")
         A.follow("tele_wind_engine", (-203.7, 761.6), "sheave1", "spin")
         A.follow("tele_shaft_pulley", (-192.5, 713.0), "sheave1", "spin")
       The belts, the chair line's two guide wheels (the line does not move), the high station's
       frozen engine and the pennants stand still; the pennants and the socks should stream east
       without a break once the engine has a follow for them.
  9. Effects (the pages'; a8.py's dust and snow draw some): gold dust drifting east between the
     towers and through the gaps (8.1 to 8.5); a car's long shadow sliding over the low roof; a creak
     from the step as it takes your weight and a dull boom from the tin underfoot (8.1); the frog
     blinking and turning its head to each car, the grating humming as a car turns under it (8.0);
     the two frayed ends stirring slowly, stiff, never swinging like rope (8.3); flakes of red paint
     off the lower sheave's rim when it is taken, a dry squeal from the upper once a turn (8.4); each
     seat creaking at the end of its swing (8.5); chalk dust from a hold as a hand takes it (8.6); the
     trolley's wheels singing up and down the scale, the buffer's spring giving 0.3 m with a clank
     (8.7); a soft clunk as a block reaches a level plate (8.8); the dead car groaning, its door
     swinging a beat behind, paint and rust flakes from the carriage (8.9); a rising hum on a cable
     before its car comes into frame and a clack at the middle tower's saddle (8.10); frost falling
     from the high bull wheel each time it turns back, the deck in blue shadow while the towers behind
     stay gold, the ice's shiver (8.11). No wavy wind lines anywhere here: this wind does not push.
"""
import math

# ------------------------------------------------------------------ the course's own numbers (a8.py)
DECK = 688.0            # the low station's deck (a7's)
GANGWAY = 688.7         # the boarding gangway (8.1)
ROOF_LO = 692.8         # the low station's roof, where you stand on it (8.1)
PERCH = 702.0           # pylon 1's perch (8.0)
LANDING = 703.0         # pylon 2's landing (8.3, 8.4)
HEAD2 = 714.5           # pylon 2's head (8.4, 8.5)
MAINT = 720.0           # the maintenance deck on pylon 2's roof (8.7, 8.8)
GRATE = 746.5           # the grate on the express tower (8.10)
HEAD3 = 749.0           # pylon 3's head (8.8, 8.9)
HIGH_DECK = 786.0       # the high station's deck (8.11)
ROOF_HI = 790.8         # the high station's roof (8.11)

_VERT = 12.0 - math.hypot(6.0, 1.4)                      # the loops' upright runs: 5.84 m
D_LO, D_HI = (-234.4, 693.4), (-234.4, 693.4 + _VERT)    # line 1, the station end
E_LO, E_HI = (-228.4, 694.8), (-228.4, 694.8 + _VERT)    # line 1, pylon 1
W_LO, W_HI = (-216.4, 694.8), (-216.4, 694.8 + _VERT)    # line 2, its west tower
E2_HI = (-210.4, W_HI[1] + 1.4)                          # line 2, its east tower
E2_LO = (-210.4, E2_HI[1] - _VERT)
CHAIRS = [(-188.5, 716.5), (-184.6, 713.9), (-180.7, 711.3), (-176.8, 708.7)]
EX_SLOPE = 22.5 / 47.5                                   # the express lines climb west
EX_E = [(-218.5, 752.1 + 5.1 * k) for k in range(4)]     # their east stops (the cable grip)
EX_W = [(-266.0, 774.6 + 5.1 * k) for k in range(4)]     # their west stops
ZIP_POST = (-164.25, 728.1)                              # the zip line's anchor post's top
ZIP_WAIT, ZIP_END = (-166.2, 728.1), (-193.0, 723.0)     # where the trolley waits; where the line ends (note 82)
XA, XB = -197.1, -200.3                                  # the counterweights' two columns
FACE = [(-251.0, 684.0), (-256.6, 704.0), (-263.6, 727.0), (-270.8, 752.0), (-281.0, 784.0)]
# The thirteen chalk holds on the fang (a8.py FANG_HOLDS; a8_areas._KNOBS).
KNOBS = [(-174.83, 708.28), (-175.17, 710.08), (-175.51, 711.88), (-175.85, 713.68), (-176.15, 714.95), (-175.43, 716.36),
         (-174.48, 717.8), (-173.09, 718.94), (-171.7, 720.09), (-170.31, 721.23), (-168.93, 722.38), (-167.54, 723.53), (-166.23, 724.61)]
# The fang's far horn (a8_areas._HORN), its west edge carried down 0.3 m inside the overhang's face so it never shows west of it.
_HORN = [(-171.7, 684.0), (-172.1, 696.0), (-175.7, 715.0), (-175.2, 716.6), (-174.0, 719.6), (-171.0, 722.6), (-168.0, 725.4),
         (-166.2, 727.4), (-164.6, 727.6), (-163.0, 725.4), (-161.2, 720.0), (-159.6, 711.0), (-157.9, 697.0), (-157.0, 684.0)]
# The far line: the dead second line, 20 m back (a8_areas._FAR_T, _FAR_SAG, _FAR_HUNG).
FAR_T = [(-238.5, 708.0), (-212.0, 732.0), (-153.0, 746.0)]
FAR_FOOT = 620.0
# The level plates on the counterweight frame (8.8).
LEVELS = [720.5, 727.5, 734.5, 741.5, 748.5]

# Depths.
TOWER_Z = -2.65         # every lattice tower and frame: a flat cut-out, z -2.5 .. -2.8
ARM_Z = -2.45           # arms, brackets and plates bolted on the towers' fronts
CABLE_Z = -2.0          # every cable, 0.15 thick: z -2.075 .. -1.925
WHEEL_Z = -2.15         # the greyed bull wheels and the top wheel (0.3 deep)
BELT_Z = -2.4
ENGINE_Z = -3.2         # the wind engines and their masts
PENNANT_Z = -2.3
HOUSE_FRONT = -2.44     # the station houses' front walls

# Stand-in tones.
STEEL = "#9A5A4C"       # the greyed brick red of everything that carries (no cream)
CABLE = "#1E1A18"       # black greased cable
RED = "#B8352A"         # the cableway's red (the roofs, the held things' skins)
WOOD = "wood"
IRON = "iron"
ACCENT = "accent"
SLICK = "slick"
ROCK = "rock"
BODY = "#7A5E4C"        # the fang's horn and the face's bodies: the same rock a step duller and cooler
SHOULDER = "#7E8C9A"    # the shoulder: hazed mid blue-grey, scree and snow
HAZE = "#C9A98E"        # the far line, hazed toward the apricot sky
ICE = "#3A4A62"         # blue-black glacier ice
SNOW = "snow"

# Lights for a8.py (FOR THE AREA FILE item 2): x, y. The frog's lit lantern, at its flame.
FROG_LIGHT = (-228.95, 703.77)

# Wheels that follow movers (item 8).
EX_ARM_WHEELS = [(-217.5, round(g[1] - 0.47, 2)) for g in EX_E]
SADDLES = [(-244.0, round(g[1] + 25.5 * EX_SLOPE, 2)) for g in EX_E]

# The mountain's shoulder carried on from the cliffs' (a7_dress `riscos_shoulder_a`..`_d`, which end at 702 with their edge at
# -245.9): its east edge at height y, 7 m east of the face by 720 (a8_areas._shoulder), cut in steps of 4 m (+0.5 / -0.4 by turns).
_SHOULDER_EDGE = [(702.0, -245.9), (720.0, -254.5), (736.0, -259.2), (752.0, -263.8), (770.0, -269.5), (790.0, -275.9), (804.0, -280.3)]
SHOULDER_WEST = -310.0  # far enough west that its end never shows past the face and its slab at any camera
SHOULDER_SECTIONS = [(702.0, 736.0), (736.0, 770.0), (770.0, 804.0)]


def _sx(y):
    e = _SHOULDER_EDGE
    for (ya, xa), (yb, xb) in zip(e, e[1:]):
        if ya <= y <= yb:
            return xa + (xb - xa) * (y - ya) / (yb - ya)
    return e[0][1] if y < e[0][0] else e[-1][1]


def _face_slab_box(i, thick=8.0):
    """The bounding box of the face's slab on edge i (a8.py A.wall: 8 m of rock to the west of the line)."""
    (xa, ya), (xb, yb) = FACE[i], FACE[i + 1]
    L = math.hypot(xb - xa, yb - ya)
    nx, ny = -(yb - ya) / L, (xb - xa) / L          # the left of travel, up the face: west
    pts = [(xa, ya), (xb, yb), (xb + nx * thick, yb + ny * thick), (xa + nx * thick, ya + ny * thick)]
    return min(p[0] for p in pts), max(p[0] for p in pts), min(p[1] for p in pts), max(p[1] for p in pts)


def dress(A):
    # ------------------------------------------------------------ helpers
    def skin(stem, x0, x1, y0, y1, tone=RED, z_front=1.2, z_back=-1.2, flip=False):
        """The look of course solids, filling them (z -1.2 .. 1.2), or carrying a floor or a roof back
        behind them to z_back."""
        A.deco(stem, round((x0 + x1) / 2, 3), round(y0, 3), z=round((z_front + z_back) / 2, 3),
               size=(round(x1 - x0, 2), round(y1 - y0, 2), round(z_front - z_back, 2)), tone=tone, skin=True, flip=flip)

    def back(stem, x0, x1, y0, y1, z_near, z_far, tone=BODY):
        """A piece behind the play space, from z_near back to z_far (origin: the middle of its foot)."""
        A.deco(stem, round((x0 + x1) / 2, 3), round(y0, 3), z=round((z_near + z_far) / 2, 3),
               size=(round(x1 - x0, 2), round(y1 - y0, 2), round(z_near - z_far, 2)), tone=tone)

    def bays(xc, n, foot=None, top=None, narrow=False):
        """A lattice tower as a flat cut-out: n bays 4 m tall stacked from `foot` up (or down from `top`),
        the braces zigzagging (every other bay flipped). The bay (made 3.0 x 4.0 x 0.3; the narrow one for
        pylon 3, 2.6 wide): two legs of riveted angle iron, a strut across its foot, one brace corner to
        corner, a pug plate at each joint; greyed brick red, peeling, no cream."""
        if foot is None:
            foot = top - 4.0 * n
        stem, w = ("tele_lattice_bay_narrow", 2.6) if narrow else ("tele_lattice_bay", 3.0)
        for k in range(n):
            A.deco(stem, xc, round(foot + 4.0 * k, 2), z=TOWER_Z, size=(w, 4.0, 0.3), tone=STEEL, flip=(k % 2 == 1))

    def run(stem, unit, p0, p1, z, thick, tone, long_unit=None, long_stem=None, switch=7.0):
        """A straight run laid as equal lengths of one made piece (origin its middle, running +x), turned
        by rot and scaled along its length (a cable or a belt is black: its joints do not show)."""
        L = math.dist(p0, p1)
        if long_unit and L >= switch:
            stem, unit = long_stem, long_unit
        n = max(1, round(L / unit))
        s = L / (n * unit)
        rot = math.degrees(math.atan2(p1[1] - p0[1], p1[0] - p0[0]))
        for i in range(n):
            t = (i + 0.5) / n
            A.deco(stem, round(p0[0] + (p1[0] - p0[0]) * t, 3), round(p0[1] + (p1[1] - p0[1]) * t, 3), z=z, rot=round(rot, 2),
                   scale=round(s, 3), size=(unit, thick, thick if thick < 0.3 else 0.06), tone=tone)

    def cable(p0, p1, z=CABLE_Z):
        """A run of black greased cable, 0.15 m thick and taut, 2 m behind you (made in lengths of 10 m,
        `tele_cable`, or of 2 m, `tele_cable_short`, for runs under 7 m)."""
        run("tele_cable_short", 2.0, p0, p1, z, 0.15, CABLE, long_unit=10.0, long_stem="tele_cable")

    def belt(p0, p1, z=BELT_Z, crossed=False):
        """A drive belt: two flat straps 0.4 m apart, dark leather (made 10 m, `tele_belt`, or 4 m,
        `tele_belt_short`); a crossed belt is ONE piece made 6 m long, its straps crossing once in the
        middle (`tele_belt_crossed`), scaled to its length."""
        if crossed:
            L = math.dist(p0, p1)
            rot = math.degrees(math.atan2(p1[1] - p0[1], p1[0] - p0[0]))
            A.deco("tele_belt_crossed", round((p0[0] + p1[0]) / 2, 3), round((p0[1] + p1[1]) / 2, 3), z=z, rot=round(rot, 2),
                   scale=round(L / 6.0, 3), size=(6.0, 0.4, 0.06), tone=CABLE)
        else:
            run("tele_belt_short", 4.0, p0, p1, z, 0.4, CABLE, long_unit=10.0, long_stem="tele_belt", switch=6.0)

    def guide(p, z=CABLE_Z, scale=1.0):
        """A guide wheel where a cable only bends: greyed, no cream, 1 m across (origin its hub)."""
        A.deco("tele_guide_wheel", p[0], round(p[1], 3), z=z, scale=scale, size=(1.0, 1.0, 0.15), tone=STEEL)

    def pennants(p0, p1, z=PENNANT_Z, stem="pennant_line"):
        """A pennant line between two fixings, the kit's 6 m unit (made 6.0 x 0.68 x 0.02, its cord's ends
        at x +-3, y 0.68 above its origin) tiled and scaled along the cord; every pennant points east."""
        rot = math.atan2(p1[1] - p0[1], p1[0] - p0[0])
        L = math.dist(p0, p1)
        n = max(1, round(L / 6.0))
        s = L / (6.0 * n)
        for i in range(n):
            t = (i + 0.5) / n
            mx, my = p0[0] + (p1[0] - p0[0]) * t, p0[1] + (p1[1] - p0[1]) * t
            ox, oy = mx + math.sin(rot) * 0.68 * s, my - math.cos(rot) * 0.68 * s
            A.deco(stem, round(ox, 3), round(oy, 3), z=z, rot=round(math.degrees(rot), 2), scale=round(s, 3), size=(6.0, 0.68, 0.02), tone=ACCENT)

    def streamer(x, y, z):
        """The kit's streamer_pole at 0.75 (3 m), its streamer flying east."""
        A.deco("streamer_pole", x, y, z=z, scale=0.75, size=(0.2, 4.0, 0.2), tone=ACCENT)

    def sock(x, y, z, h=1.6):
        """A wind sock pointing east on a post h tall: the kit's bunting_pole (made 3.2) as the post and its
        wind_sock (its eye 0.45 east and 1.44 up of its origin; it streams west unless flipped) hung from the
        post's top, flipped."""
        A.deco("bunting_pole", x, y, z=z, scale=round(h / 3.2, 4), size=(0.17, 3.2, 0.17), tone=WOOD)
        A.deco("wind_sock", round(x + 0.45, 3), round(y + h - 1.44, 3), z=z, size=(0.99, 1.48, 0.42), tone=ACCENT, flip=True)

    def engine(x, y, mast_foot, frozen=False):
        """A wind engine: a cup wheel 5 m across, three arms with a cup on each (made 5.0 x 5.0 x 0.4, origin
        its hub; greyed red, no cream), on an iron mast (made 4.0 tall, `tele_engine_mast`, 0.3 square)."""
        h = round(y - mast_foot, 2)
        A.deco("tele_engine_mast", x, mast_foot, z=ENGINE_Z, scale=round(h / 4.0, 3), size=(0.3, 4.0, 0.3), tone=STEEL)
        A.deco("tele_wind_engine_frozen" if frozen else "tele_wind_engine", x, y, z=ENGINE_Z, size=(5.0, 5.0, 0.4), tone=SNOW if frozen else STEEL)

    def crest(x, y, z, w):
        """The kit's pug_crest_peeling (made 1.6 across) at w metres; origin the middle of its foot."""
        A.deco("pug_crest_peeling", x, y, z=z, scale=round(w / 1.6, 4), size=(1.6, 1.6, 0.05), tone=ACCENT)

    def cold_lantern_on_wall(xw, yw, zw):
        """The station's cold lantern on a bracket (the kit's mine_lantern_bracket, origin its plate on the
        wall, the hook 0.42 along +x; lantern_cold hanging from the hook, 0.48 tall), as the cliffs hang
        theirs."""
        A.deco("mine_lantern_bracket", xw, yw, z=round(zw + 0.03, 2), size=(0.48, 0.15, 0.06), tone=IRON)
        A.deco("lantern_cold", round(xw + 0.42, 3), round(yw - 0.48, 3), z=round(zw + 0.14, 2), size=(0.28, 0.48, 0.28), tone="gold")

    # ============================================================ the far side: the far line and the shoulder
    # The far line (8.1, 8.0, 8.2, 8.3, 8.6, 8.7, 8.8): the cableway's dead second line, ONE flat cut-out card
    # 20 m back made the way the far cards are (BRIEF.md "Far backgrounds", the kit's `stn_far_hills`: a thick
    # card whose cut edge shows kraft, a dark stripe, kraft, braces behind), hazed toward the apricot sky.
    # Three lattice towers 4 m wide (tops at (-238.5, 708), (-212, 732), (-153, 746)), each with a crossarm
    # 5.2 m; two slack spans sagging 2.5 m and 6 m; one stopped chair (on the first span at x -231), two
    # stopped cars (at -222 and -178); on the middle tower's top its wind engine with the cups gone. Mid
    # values, the legs fading into painted haze below 640 so its foot never shows (item 7e). Nothing else of
    # ours stands east of the shoulder: the valley, the town, the ranges and the cloud banks are given.
    A.deco("tele_far_line", -195.75, FAR_FOOT, z=-20.25, size=(90.7, 129.0, 0.5), tone=HAZE)
    # The mountain's shoulder (8.10, 8.11, and behind the low station): the cliffs' flat cut-out card
    # carried on up, 12 m and more back: chalk gives way to dark scree with snow lying in its gullies, and
    # the glacier's blue edge hangs over its top section. Its east edge cut in steps of 4 m that lean back
    # with the face, a snow gully at each step. West of its edge only.
    for k, (y0, y1) in enumerate(SHOULDER_SECTIONS):
        y, east, i = y0, -1e9, 0
        while y < y1 - 0.01:
            yn = min(y + 4.0, y1)
            east = max(east, _sx((y + yn) / 2) + (0.5 if i % 2 else -0.4))
            y, i = yn, i + 1
        back("tele_shoulder_" + "abc"[k], SHOULDER_WEST, round(east, 2), y0, y1, -12.75, -13.25, tone=SHOULDER)

    # ============================================================ the mountain's face (every page west of the lines)
    # The face between the stations (skins, the course's slick scree, a8.py line 97 by edge, and the plug at
    # the high deck): dark brown in a few large slanted planes polished to a gloss, the beds painted as long
    # wavy lines and bands in three or four browns running the length of the face, a few big breaks (a brow
    # with its shadow painted under it at about 715, one ledge at about 740, a notch in the outline at about
    # 765 where a block has gone); nothing on it is a hold, so nothing on it is pale or dry. Four pieces, one
    # for each edge (20 to 33 m tall), the faces where they meet the air exactly the course's.
    for i in range(4):
        x0, x1, y0, y1 = _face_slab_box(i)
        if i == 3:
            x0, y1 = min(x0, -289.0), max(y1, 785.4)     # and the plug behind the high deck's west end (line 379)
        skin("tele_face_" + "abcd"[i], round(x0, 2), round(x1, 2), round(y0, 2), round(y1, 2), tone=SLICK)
    # The face's body behind it (the cliffs' `riscos_face_body` carried on up, from 690 where that one ends):
    # the same rock a step duller and cooler, ONE big form in two or three slanted planes, its beds as thin
    # darker lines carrying on the face's, a metre proud of the face line (outline (-250.5, 690), (-254.5,
    # 700), (-255.6, 704), (-262.6, 727), (-265.8, 738); then (-269.8, 752), (-277.8, 777); from 777 to 786
    # its edge runs 0.3 inside the face, where the swallowed docks' ice stands in front).
    back("tele_face_body_a", -300.0, -250.5, 690.0, 738.0, -1.25, -3.0)
    back("tele_face_body_b", -310.0, -265.8, 738.0, 786.0, -1.25, -3.0)

    # ============================================================ 8.1 Abordar (and the join from the cliffs)
    # The gangway (skin): 3.3 m of honey planks 0.7 m above the deck on a steel frame, its east lip and its
    # edge painted with the cableway's cream band (the first mark for a hold: page "7 to 8"), its one rail
    # post red with a cream band round its top; and painted on a7.py's deck east of it (x -236.7 .. -236.0,
    # 2 cm on the deck's top) the slanted yellow and black warning stripes (note 78).
    skin("tele_gangway", -240.0, -236.0, DECK, 689.9, tone=WOOD)
    # The low station's roof (skin, note 77: real): striped red and cream tin nailed on timber boards, 13.4 m
    # long, a cream band along its edges; in the play space its top exactly the solid's (692.8, 0.3 thick);
    # behind it rises on to its ridge over the house's back wall (694.3 at z -5.5): 6.7 m eave to ridge.
    skin("tele_roof_low", -251.0, -237.6, 692.5, 694.3, z_back=-5.5)
    # On the house's wall (the house is the cliffs': item 7a): the ticket booth against it, west of the door,
    # clear of the sock's post; the pug sign over the door.
    A.deco("ticket_booth", -246.9, DECK, z=-1.85, size=(2.2, 3.0, 1.2), tone=WOOD)
    A.deco("station_sign_pug", -244.4, 690.6, z=round(HOUSE_FRONT + 0.05, 2), size=(2.4, 1.4, 0.1), tone=ACCENT)   # origin: the middle of its foot, on the wall
    # The station's end frame: a lattice frame on the station's east end standing on the scaffold's top
    # ledger (682.6), 3 m wide, five bays and its cap (703.5 .. 703.8) that carries the engine's mast; a
    # pulley bracket at its foot (made in place: x -235.9 .. -232.9, legs to the cap 3.8 wide).
    A.deco("tele_end_frame", -234.4, 682.6, z=TOWER_Z, size=(3.8, 21.2, 0.3), tone=STEEL)
    # Line 1's bull wheel, greyed, no cream, 4.4 m across, inside the loop's station end, 2 m back (note 76).
    A.deco("tele_bull_wheel_grey", -232.2, 696.3, z=WHEEL_Z, size=(4.4, 4.4, 0.3), tone=STEEL)     # origin: its hub
    # Line 1's loop of cable and its four guide wheels (the whole road of both cars on screen).
    loop1 = [D_LO, E_LO, E_HI, D_HI]
    for i in range(4):
        cable(loop1[i], loop1[(i + 1) % 4])
    for p in loop1:
        guide(p)
    # The station's wind engine on the end frame, 3 m back, and its belt down to the bull wheel.
    engine(-234.4, 706.2, 703.8)
    belt((-234.4, 706.2), (-232.2, 696.3), z=-2.6)
    # The cliffs' haul cable comes up under the loop to a pulley at the foot of the end frame (the guide
    # wheel at 0.8) and on up the frame to the engine (item 7b).
    guide((-233.0, 688.6), z=-2.3, scale=0.8)
    cable((-233.2, 688.9), (-234.3, 703.6), z=-2.3)
    # The express lines' middle tower (also 8.10): it rises from behind the station's ridge, standing on the
    # roof's back half (item 7d), 25 bays to 793.3.
    bays(-244.0, 25, foot=693.3)
    # The pennant line from the middle tower to the end frame, high over every hand, pointing east.
    pennants((-242.5, 704.6), (-235.9, 703.8))

    # ============================================================ pylon 1 (8.1, 8.0, 8.2)
    # The first tower: two legs 3 m apart, zigzag braces, a pug plate at every joint, 2.5 m back, from below
    # the frame to its top at 708 (where the link girder sits). Its perch (skin): open iron grating, rust
    # orange and dry, 2.4 m, the one rail post on its west end red with a cream band round its top.
    bays(-228.4, 11, top=708.0)
    skin("tele_perch", -229.6, -227.2, 701.7, 703.0, tone=IRON)
    # The streamer on the tower's top (on the girder), 3 m, the town's bunting colours, streaming east.
    streamer(-229.9, 709.0, -2.6)
    # An oil can and a rag on the joint's strut beside the upper guide wheel.
    A.deco("oil_can", -227.3, 700.0, z=-2.62, size=(0.36, 0.42, 0.26), tone=IRON)
    A.deco("tele_oily_rag", -226.95, 700.0, z=-2.62, size=(0.3, 0.12, 0.2), tone="#8A7A62")

    # ============================================================ 8.0 The frog's gondola
    # The parked gondola (made in place, the same car as the ones you ride): back wall, roof, floor, end walls
    # and a bench along the back wall, open toward you, its floor level with the perch (top 702.0), its step
    # and rack unbolted and gone (nothing sticks out of it that looks like a hold); a peeling pug crest on the
    # back wall; its trolley up to the siding's rail (705.7). The lit lantern's amber painted on its walls.
    A.deco("tele_gondola_parked", -228.4, 701.84, z=-1.775, size=(2.6, 3.86, 1.05), tone=RED)
    # The siding: a short rail 5 m long hung from the tower's top on two hangers between the cable and you,
    # a buffer on its east end (x -231.4 .. -226.3).
    A.deco("tele_siding", -228.85, 705.1, z=-1.8, size=(5.1, 2.5, 0.2), tone=STEEL)
    # The frog, the last passenger, on the bench holding its paper ticket (the kit's frog_ticket: origin the
    # middle of its seat at the bench's front edge, the bench top 702.6); its small suitcase with a pug
    # sticker beside it; the timetable card pinned to the back wall, bleached blank by the sun.
    A.deco("frog_ticket", -228.95, 702.6, z=-1.9, size=(0.26, 0.33, 0.29), tone=ACCENT)
    A.deco("tele_suitcase", -228.42, 702.6, z=-2.05, size=(0.35, 0.3, 0.15), tone="#A0522D")
    A.deco("tele_timetable_card", -229.25, 702.95, z=-2.28, size=(0.3, 0.4, 0.01), tone="bone")   # origin: the middle of its foot, on the back wall
    # The lit lantern hanging from the car's roof: the only lit lamp on the cableway (light: item 2). The
    # kit's lantern_station, its hood's ball at the roof's underside.
    A.deco("lantern_station", -228.95, 703.54, z=-1.75, size=(0.35, 0.56, 0.35), tone="gold")
    # The link girder (also 8.2): a lattice girder laid level between the tops of pylon 1 and line 2's west
    # tower, 15 m long, 1 m deep, its shaft along it with a pulley at each end; the belt up from line 1's turn
    # at pylon 1, and the pennants under it, 3.2 m and more above the highest hand.
    A.deco("tele_link_girder", -222.4, 708.0, z=-2.6, size=(15.0, 1.0, 0.3), tone=STEEL)
    belt((-227.9, 700.9), (-227.6, 708.0))
    pennants((-229.9, 708.0), (-214.9, 708.0), z=-2.35)

    # ============================================================ 8.2 De Gondola a Gondola
    # Line 2's two towers (also 8.3): the west one to 708 (the girder), the east one to 712 (its arm).
    bays(-216.4, 11, top=708.0)
    bays(-210.4, 12, top=712.0)
    # Line 2's loop and its guide wheels, and its bull wheel, greyed, inside its driven (west) end; the crossed
    # belt down from the girder's shaft, which is why line 2 turns the other way.
    loop2 = [W_LO, E2_LO, E2_HI, W_HI]
    for i in range(4):
        cable(loop2[i], loop2[(i + 1) % 4])
    for p in loop2:
        guide(p)
    A.deco("tele_bull_wheel_grey", -214.2, 697.72, z=WHEEL_Z, size=(4.4, 4.4, 0.3), tone=STEEL)   # origin: its hub
    belt((-216.3, 708.0), (-214.2, 697.72), crossed=True)
    # The fallen change landing: two broken bracket arms, one on each tower at 694 m, each 1.7 m long and
    # torn off short, reaching toward each other (the east one flipped). They mark the jump's height and width.
    A.deco("tele_bracket_broken", -225.95, 692.3, z=ARM_Z, size=(1.9, 1.6, 0.2), tone=STEEL)
    A.deco("tele_bracket_broken", -218.85, 692.3, z=ARM_Z, size=(1.9, 1.6, 0.2), tone=STEEL, flip=True)
    # A wind sock on line 2's west tower's top, on the girder, pointing east.
    sock(-214.9, 709.0, ARM_Z)

    # ============================================================ 8.3 El Cable (the long span, gone)
    # The arm on line 2's east tower where the long span left it (the span arm, flipped: x -212.4 .. -206.9, its
    # top at 712.3), and the snapped end hanging 3 m from its tip, frayed open and blown a little east (made
    # 0.9 x 3.4 x 0.15, origin its top where it hangs), 6 m above any hand.
    A.deco("tele_span_arm", -209.65, 710.2, z=ARM_Z, size=(5.5, 2.1, 0.3), tone=STEEL, flip=True)
    A.deco("tele_cable_snapped", -207.4, 712.0, z=-2.075, size=(0.9, 3.4, 0.15), tone=CABLE)
    # Pylon 2 (also 8.4 to 8.8): its far legs and all its braces, a flat cut-out 2.5 m back, from below the
    # frame to 719.4 under the roof's ridge. Its two near legs (skins): black greased steel, glossy, 0.3 m, the
    # only steel in the play space that cannot be held.
    bays(-192.5, 14, top=719.4)
    skin("tele_pylon2_leg", -194.15, -193.85, 670.0, 702.8, tone=SLICK, z_front=0.15, z_back=-0.15)
    skin("tele_pylon2_leg", -191.15, -190.85, 670.0, 702.8, tone=SLICK, z_front=0.15, z_back=-0.15)
    # The landing (skin): open iron grating, rust orange and dry, 5.4 m; its west end's lip rolled and worn
    # bright, the palest thing on the pylon (the whole target, seen from the car); the grating carried back
    # 0.6 m behind the play space, where the oil can and the grease pot stand.
    skin("tele_landing", -196.0, -190.6, 702.7, LANDING, tone=IRON, z_back=-1.8)
    A.deco("oil_can", -191.6, LANDING, z=-1.42, size=(0.36, 0.42, 0.26), tone=IRON)
    A.deco("tele_grease_pot", -192.2, LANDING, z=-1.5, size=(0.4, 0.3, 0.3), tone=IRON)
    # The long span's arm on pylon 2: a crossarm 5.5 m out west at 715 m with a brace under it from the
    # tower's leg, 2.5 m back; the cable's other frayed end hanging 3 m from its tip, 4 m and more from any
    # hand; the wind sock on the tip pointing east, toward the tower (the wind is with the jump).
    A.deco("tele_span_arm", -196.75, 713.2, z=ARM_Z, size=(5.5, 2.1, 0.3), tone=STEEL)
    A.deco("tele_cable_snapped", -199.3, 715.0, z=-2.3, size=(0.9, 3.4, 0.15), tone=CABLE)
    sock(-199.5, 715.3, ARM_Z)

    # ============================================================ 8.4 El Pilon
    # The shaft with its pulley on the tower's centre line at 713 m, the engine's belt straight down the
    # inside of the tower to it, a belt down to the lower sheave and a crossed belt to the upper (why they
    # turn opposite ways); every belt inside the tower's width, over the lattice.
    A.deco("tele_shaft_pulley", -192.5, 713.0, z=-2.4, size=(0.8, 0.8, 0.2), tone=STEEL)         # origin: its hub
    belt((-192.5, 730.0), (-192.5, 713.4), z=ARM_Z)
    belt((-192.5, 713.0), (-194.6, 705.8))
    belt((-192.5, 713.0), (-190.9, 710.3), crossed=True)
    # Each sheave's axle runs back to a bracket on the tower (the bracket from z -1.25 back, hidden behind
    # the hub; origin the middle of its foot under the axle).
    A.deco("tele_axle_bracket", -194.6, 705.6, z=-1.875, size=(0.4, 0.4, 1.25), tone=STEEL)
    A.deco("tele_axle_bracket", -190.9, 710.1, z=-1.875, size=(0.4, 0.4, 1.25), tone=STEEL)
    # The head (skin): honey planks on steel, 4 m, carried back to the shed's wall (z -2.6).
    skin("tele_head_deck", -194.8, -190.8, 714.2, HEAD2, tone=WOOD, z_back=-2.6)
    # The tarred roof (skin): black tarred tin, glossy, two slopes (5.6 m and 6.5 m) from the ridge at
    # (-193, 719.45), the blackest thing on the tower; it reaches back only to z -1.85 so the chair line's
    # cable and guide wheel pass behind its back edge (item 7f).
    skin("tele_tar_roof", -197.8, -187.4, 715.75, 719.75, tone=SLICK, z_back=-1.85)
    # The chair shed under it, 2.5 m back (also 8.5, 8.7): a board wall in the greyed red below bare grey
    # boards, no cream, its own tarred gable to 719.2; a bench against it and the hand winch that wound the
    # chair line (x -195.0 .. -190.6; the wall's face at z -2.2, the bench and the winch forward to -1.9).
    A.deco("tele_chair_shed", -192.8, HEAD2, z=-2.1, size=(4.4, 4.7, 0.4), tone=STEEL)
    # On the shed: the cold lantern on its bracket (lit today, 0.8 m back: it goes to the wall and goes cold)
    # and the peeling pug crest on the gable (0.9 m back today).
    cold_lantern_on_wall(-194.42, 716.84, -2.2)
    crest(-193.0, 717.6, -2.17, 1.2)
    # Pylon 2's wind engine on a mast over the roof, 3 m back (also 8.7, 8.8): the mast 10.6 m from the
    # tower's top (made at that height, `tele_engine_mast_tall`).
    A.deco("tele_engine_mast_tall", -192.5, 719.4, z=ENGINE_Z, size=(0.3, 10.6, 0.3), tone=STEEL)
    A.deco("tele_wind_engine", -192.5, 730.0, z=ENGINE_Z, size=(5.0, 5.0, 0.4), tone=STEEL)

    # ============================================================ 8.5 Sillas Voladoras
    # The chair line's cable, from a greyed guide wheel under the shed's eave down to another on the fang,
    # through the four chairs' pivots; from the eave it runs back into the shed to the hand winch. It does not
    # move. The anchor arm on the fang: an iron arm bolted into the fang's body, 2 m back, a pug plate on it.
    cable((-189.4, 717.1), (-175.3, 707.7))
    cable((-189.4, 717.1), (-191.4, 715.4))
    guide((-189.4, 717.1))
    guide((-175.3, 707.7))
    A.deco("tele_anchor_arm", -175.05, 707.0, z=-2.1, size=(1.7, 1.0, 0.3), tone=STEEL)
    # The 12 m pennant line on the chair cable, hanging 0.7 m, clear of a hand raised from a seat.
    pennants((-188.0, 716.17), (-177.0, 708.83), z=-2.1)

    # ============================================================ 8.6 El Colmillo
    # The fang (skin, made in place: line 220 with the foot ledge 236 and the rib 237): the cliffs' own rock as
    # one painted piece: a few large slanted planes of dark brown polished to a gloss, the beds painted as long
    # wavy lines and bands in three or four browns running from each hold east across the whole face, near
    # level (a8_areas._BEDS), no ink inside a face, no streaks; three real breaks: the overhang with its shadow
    # painted a band darker under the nose, the foot ledge, the notch in the east side (item 6a); the foot
    # ledge and the rib white chalk as plain bands with square ends; nothing else white.
    skin("tele_colmillo", -176.0, -158.0, 684.0, 725.0, tone=SLICK)
    # The thirteen chalk holds (skins of the A.holds, line 243): plain white blocks with square ends, 0.4 m
    # across, dry and matte, each the end of one of the rock's beds where it meets the face.
    for hx, hy in KNOBS:
        skin("tele_chalk_block", round(hx - 0.2, 3), round(hx + 0.2, 3), round(hy - 0.2, 3), round(hy + 0.2, 3), tone=ROCK)
    # The anchor plate and the zip line's post (skin): rust-orange iron, dry, both held.
    skin("tele_fang_anchor", -166.6, -164.0, 725.0, 728.1, tone=IRON)
    # The fang's far horn (also 8.7): its own body carrying on behind the slice you climb, one big form in two
    # or three slanted planes 1.5 to 4 m back, the same rock a step duller, greyer and cooler, its beds thin
    # wavy lines carrying on the face's; an uneven skyline rising 1.5 to 3 m above the slab; never west of the
    # overhang (its west edge 0.3 inside the face); a shelf at 725.4 carried forward to z -1.25 behind the plate,
    # where the linesman's box and the cold lantern stand (outline: a8_dress._HORN).
    hx0, hx1 = min(p[0] for p in _HORN), max(p[0] for p in _HORN)
    back("tele_fang_horn", hx0, hx1, 684.0, max(p[1] for p in _HORN), -1.5, -4.0)
    # The top's fittings: the post's back stay, a thick iron rod down to an eye bolt in the horn (made 4.06 m,
    # standing +y; origin its lower end at the eye bolt); the linesman's box (the kit's open toolbox) and a
    # cold lantern on the shelf; a streamer pole on the horn's tip, pointing east.
    A.deco("tele_back_stay", -162.2, 724.6, z=-1.4, rot=round(math.degrees(math.atan2(-(ZIP_POST[0] + 162.2), ZIP_POST[1] - 724.6)), 2),
           size=(0.12, 4.06, 0.12), tone=IRON)
    A.deco("toolbox_open", -165.0, 725.4, z=-1.5, size=(0.8, 0.52, 0.45), tone=ACCENT)
    A.deco("lantern_cold", -165.75, 725.4, z=-1.45, size=(0.28, 0.48, 0.28), tone="gold")
    streamer(-166.0, 727.4, -2.5)

    # ============================================================ 8.7 Tirolesa
    # The zip line: black greased cable, 2 m back, level from the back of the post to where the trolley
    # waits, then 26.8 m west and 5.1 m down to the buffer over the deck (note 82: it runs all the way).
    cable(ZIP_POST, ZIP_WAIT)
    cable(ZIP_WAIT, ZIP_END)
    # The sprung buffer: a post 2.7 m tall at the back of the deck with a coil spring on its top pointing up the
    # line (x -193.7 .. -193.0, to 723.15); the trolley stops against it.
    A.deco("tele_zip_buffer", -193.35, MAINT, z=-2.1, size=(0.7, 3.15, 0.3), tone=STEEL)
    # The maintenance deck (skin): honey planks on steel, 6 m, its 2 m under the buffer worn pale by boots
    # (where you let go); carried back to z -2.3 under the buffer.
    skin("tele_maint_deck", -196.0, -190.0, 719.6, MAINT, tone=WOOD, z_back=-2.3)
    # At the back of its east end: the open toolbox (0.7 m back today: to 1.3) and a cold lantern.
    A.deco("toolbox_open", -191.0, MAINT, z=-1.5, size=(0.8, 0.52, 0.45), tone=ACCENT)
    A.deco("lantern_cold", -190.3, MAINT, z=-1.45, size=(0.28, 0.48, 0.28), tone="gold")

    # ============================================================ 8.8 Contrapesos
    # The counterweight frame: a lattice frame standing on pylon 2's roof, its west leg on the span arm, ten
    # bays to 754.6 (also 8.9).
    bays(XA, 10, top=754.6)
    # The long girder (also 8.9, 8.10): a lattice girder 23.1 m long, 1.2 m deep, from the express tower
    # across pylon 3 to the frame's top; under it the shuttle's rail (at z -2.0, the dead car's carriage runs
    # on it) between a buffer at each end (x -218.6 and -202.6); a shaft inside it (x -218.7 .. -195.6).
    A.deco("tele_long_girder", -207.15, 754.1, z=-2.4, size=(23.1, 1.7, 1.0), tone=STEEL)
    # The top wheel on the girder over the frame, greyed, 3.2 m across (exactly the columns' spacing), the
    # cable's arc over its top half in the same model; the two cables down the columns.
    A.deco("tele_top_wheel", -198.7, 757.4, z=WHEEL_Z, size=(3.4, 3.4, 0.3), tone=STEEL)            # origin: its hub
    cable((XA, 721.0), (XA, 757.4))
    cable((XB, 728.0), (XB, 757.4))
    # The level plates on the frame's west leg (in the gap between the columns): one at each height where two
    # tops stand level, and at the foot and top of the ride (made 1.0 x 0.3 x 0.05, origin its foot).
    for y in LEVELS:
        A.deco("tele_level_plate", -198.7, round(y - 0.15, 2), z=ARM_Z, size=(1.0, 0.3, 0.05), tone="#C8962E")
    # Pylon 3 (also 8.9): 2.6 m wide, from below the frame to 758.4 (it carries the head, the girder and the
    # engine), the peeling pug crest on it over the head.
    bays(-203.7, 24, top=758.4, narrow=True)
    crest(-203.7, 751.7, ARM_Z, 1.4)
    # Pylon 3's head (skin): honey planks on steel, 4.1 m, the rail post you lean out from on its west end;
    # the post and the head's last 0.6 m in the slanted yellow and black stripes (8.9, note 78); carried back
    # to z -1.8 (the frozen climber's place, item 6e, and the streamer).
    skin("tele_head_p3", -205.6, -201.5, 748.6, 750.2, tone=WOOD, z_back=-1.8)
    streamer(-205.2, HEAD3, -1.6)
    # Pylon 3's wind engine on its top, 3 m back, its belt down to the girder's shaft.
    engine(-203.7, 761.6, 758.4)
    belt((-203.7, 761.6), (-203.7, 755.8), z=-2.6)

    # ============================================================ 8.9 La Gondola Rota
    # The express tower (also 8.10): new; it stands under the grate, on the link girder's top (709: item 7i),
    # 17 bays to 777 (the page draws it to 772: the pennant line is tied to its top, item 7g). At each line's
    # east end an arm with a buffer (made 1.8 x 0.6 x 0.3, x -218.7 .. -216.9) and a greyed guide wheel where
    # the cable turns down.
    bays(-220.2, 17, foot=709.0)
    for (gx, gy), w in zip(EX_E, EX_ARM_WHEELS):
        A.deco("tele_express_arm", -217.8, round(gy - 0.65, 2), z=ARM_Z, size=(1.8, 0.6, 0.3), tone=STEEL)
        guide(w)
    # The winding drum on the girder's end at the express tower (1.8 m across, origin its axle).
    A.deco("tele_winding_drum", -220.2, 755.2, z=-2.2, size=(1.8, 1.8, 0.4), tone=STEEL)
    # The west carriage, still on the rail, with the sheared stub of the arm that broke (0.7 m), greyed.
    A.deco("tele_carriage_stub", -211.2, 753.55, z=CABLE_Z, size=(0.6, 1.0, 0.3), tone=STEEL)
    # The grate (skin): open iron grating, 1.6 m, on the express tower's side, carried back to the tower.
    skin("tele_grate", -221.0, -219.4, 746.25, GRATE, tone=IRON, z_back=-2.5)
    # The four express cables (also 8.10, 8.11), from the express tower's arms up west through every car's
    # grip to the high station: lines 1 and 2 into the ice that fills the lower docks (through frost-rimmed
    # holes), line 3 under the bull wheel, line 4 over it.
    for k, (gx, gy) in enumerate(EX_E):
        y_at = lambda x: gy + (gx - x) * EX_SLOPE
        start = (-217.5, round(y_at(-217.5), 3))
        end_x = (-273.0, -270.2, -269.0, -266.0)[k]
        cable(start, (end_x, round(y_at(end_x), 3)))
    cable((-266.0, round(EX_E[3][1] + 47.5 * EX_SLOPE, 3)), (-269.0, 790.4))

    # ============================================================ 8.10 Via Rapida
    # The middle tower's four arms (4.6 m) at the cables' heights, each with a saddle wheel (the guide wheel at
    # 0.8), and its pug crest, exactly behind the place where the cars pass.
    for sx, sy in SADDLES:
        A.deco("tele_middle_arm", -244.0, round(sy - 0.15, 2), z=ARM_Z, size=(4.6, 0.3, 0.3), tone=STEEL)
        guide((sx, sy), scale=0.8)
    crest(-244.0, 758.7, ARM_Z, 1.4)
    # The one line of pennants above the top cable (the lower one goes), streaming east down the lines: tied to
    # the express tower's top and to the middle tower as it passes, and on west (item 7g).
    pennants((-221.7, 773.5), (-242.5, 783.56), z=-2.1)
    pennants((-245.5, 785.0), (-259.75, 791.9), z=-2.1)

    # ============================================================ 8.11 La Estacion Alta (the join to the glacier)
    # The high station's roof (skin, note 77: real): the same striped tin on timber as below, 13.4 m, its top
    # 4.8 m over the deck; the glaze of black ice on x -271.5 .. -269.6 (line 389, glossy, not held); its back
    # half rising to the ridge (792.3 at z -5.5), frosted, the glacier's lip lying on it west of -271.5 (biome 9).
    skin("tele_roof_high", -281.4, -268.0, 790.5, 792.3, z_back=-5.5)
    # The station house, half buried: the same house as at the low station (12 m wide, 6 m at its back wall,
    # no roof of its own), board walls in the greyed red below bare grey boards, no cream, dark windows, a
    # ticket window; snow drifted against its west half up to the roof.
    A.deco("tele_station_house_high", -276.0, HIGH_DECK, z=-4.0, size=(12.0, 6.0, 3.1), tone=STEEL)
    # The deck's planks carried back to the house (z -1.25 .. -2.45), the ice tongue and its frost edge painted
    # on carrying the three sheets back.
    back("tele_high_deck_back", -282.0, -268.0, 785.5, HIGH_DECK, -1.25, -2.45, tone=WOOD)
    # On the house's wall: the pug sign, and the cold lantern by the ticket window.
    A.deco("station_sign_pug", -277.3, 788.6, z=round(HOUSE_FRONT + 0.05, 2), size=(2.4, 1.4, 0.1), tone=ACCENT)
    cold_lantern_on_wall(-274.32, 789.08, HOUSE_FRONT)
    # The swallowed docks: blue-black glacier ice, glossy, filling the two lower docks from the face out to the
    # deck's east end, 1.3 m and more back, two frost-rimmed holes where lines 1 and 2 run in ((-273.0, 777.9),
    # (-270.2, 781.7)); the black ice under the deck's east end in the play space is its near edge.
    back("tele_dock_ice", -289.0, -268.2, 777.0, 785.4, -1.3, -6.0, tone=ICE)
    # The deck's two lattice brackets from under the deck back to the face, half sunk in the ice (made in
    # place: (-270.4, 785.3) to (-279.4, 777.8) and (-274.9, 785.3) to (-279.9, 781.1)).
    A.deco("tele_deck_bracket", -275.15, 777.8, z=TOWER_Z, size=(9.5, 7.5, 0.3), tone=STEEL)
    # The upper pair's bull wheel on the front of the house at its east end, under the roof, greyed and frosted.
    A.deco("tele_bull_wheel_frosted", -269.0, 788.2, z=WHEEL_Z, size=(4.4, 4.4, 0.3), tone=STEEL)  # origin: its hub
    # The frozen wind engine on the roof's open east end, white with frost, snow in its cups, stopped.
    engine(-269.5, 796.3, 791.5, frozen=True)
    # The last pennants, frozen stiff and white with frost, still pointing east, to the frozen engine's mast.
    pennants((-259.75, 791.9), (-269.5, 794.6), z=-2.1, stem="tele_pennant_line_frozen")
    # Foreground: one square station post in the cableway's red in front of the deck's west end, carrying the
    # eave's west corner (it matches the cliffs' post in front of the low deck); a lip of drifted snow along
    # the deck's front edge on the planks' fascia, under 0.3 m above the planks, stopping 3.5 m short of the
    # east end where you come off the car.
    A.deco("tele_platform_post", -281.4, 779.0, z=1.45, size=(0.3, 11.6, 0.3), tone=RED)
    A.deco("tele_snow_lip", -276.75, 785.4, z=1.475, size=(10.5, 0.85, 0.45), tone=SNOW)
