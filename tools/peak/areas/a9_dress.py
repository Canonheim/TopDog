"""
EL GLACIAR, DRESSED: the scenery of all of biome 9, the glacier on the mountain's east face (y 784 to
888), from the twelve area pages (the join "8 to 9" under the lip, the challenges 9.1 to 9.10 and the
frog's snow hole 9.0) in docs/peak/playtest/design/data/a9_areas.py and the biome's sheet a9_biome.py
(its `built`, `looks`, `layers` and `kit`, and KIT_MORE). The join "8 to 9" is shared with the
cableway: a8_dress.py places the high deck, its roof (the skin under the glacier's lip), the house,
the swallowed docks, the frozen engine and the last pennant line (frozen, tied to the engine's mast);
this file places what the glacier adds there: the lip and its fringe, the icicle row under the roof's
eave, the alcove's and the tunnel's back wall, the first cane and the tunnel's lantern, the tongue's
flank lying on the house's roof. The join to biome 10 is page 9.10 (El Rimaye) and the storm ridge's
page "9 to 10" (in a10_areas.py): this file places the glacier's side of the gap (the horn at the last
climber's back, the last cane and its lantern, the slab hole, the glaze on the ledge's nose); the
ridge's slate across the gap, the exit ledge's own look, the prayer pole, the cabin and its frog are
the storm ridge's.

Parker, 11-13 (third round, ANSWERS.md 9 and 10): the three look rules stand (warm holds for good,
pale blue for 2 seconds, dark blue never); the way out is the palest place in each room; the frozen
climbers are frost grey with warm boots, belt and mittens, and NOTHING CLIMBER-SHAPED IS MODELLED
until the new climber model lands (so the seven you hold stay the game's statues; their grips stay
the course's bone holds, unskinned; the four deep in the ice are the kit's `frozen_climber_deep`,
placed as the pages move them). The lower crevasse redesign: "Yes, that"; the camera stays close
there, and "a background arrow sign sticking out the wall or ceiling indicating which way to go":
three such signs (`glaciar_arrow_sign`) stick 1 m out of the crack's far wall on canes, behind the
climb, at the three turns the pages give. The walls rule (BRIEF.md "Walls and masses",
`walls_example_after.png`) for ice: a few big flat planes meeting at hard angles, blue-black and
glossy; the ice's bands, white crack lines and stones as flat colour in three or four blues, long
uneven wavy lines and bands tilted ten degrees down to the east; nothing painted narrows to a point;
no dark recess cut into a face; a few big real breaks (a brow, the shelf's broken end, an opened
crack, a fallen block); designed outlines (up to 0.8 m off the course away from holds and tops); each
wall one piece made for its place. The sheet names no plants and says the ice is flush ("nothing
sticks out of it that is not a hold"): so NO outcrops and no plants here. Holds are plain blocks of
the seam's own pale blue with square ends; stones grey-brown and dry; firm snow white and matte with
a square front edge. Light is shown by colour: each room's way out is painted palest; the only warm
light is the lanterns'. Every dark wet crack an icicle grows from, every ring of splinters under one,
every line of boot prints, every blue hollow and wind ridge is PAINT on the skin it lies on (named
in each skin's row of the model list), never a deco in the play space.

Scenery only: decos. Nothing here can be stood on or held. The course (every solid, the serac, the
spawners, the ropes, the kicker board, the winds, the statues and their grips) is a9.py's. The
model list this file makes is docs/peak/models/a9_models.md.

Depth: the play space is z -1.2 .. 1.2. Everything here stands behind -1.25 or in front of 1.25,
except SKINS (skin=True), each the LOOK of course solids. A skin of a wall or a mass fills its solid
(z -1.2 .. 1.2); a skin of a floor, a roof or the west wall carries on back to the far wall's face
at z -2.4 (z -2.4 .. 1.2), so no slot of air shows between a room's floor or roof and its back wall
(the tower's skin carries its body back to -2.4 too, but for its two niches); a small hold's skin is
the depth the game draws it (a nub, a knuckle, a stone: z -0.3 .. 0.3; a plate: -0.2 .. 0.2); an
icicle's, a tusk's and the stone tooth's skin is round, 0.5 to 0.6 deep, about z 0 (their collision
keeps its full depth); a snow bridge's and a wedged stone's run back to the far wall (z -2.4 .. 1.2:
"wedged from the far wall to the near one"). From the back: the glacier's far side, ONE flat painted
card 45 m back (z -45.5 .. -45.0) (EAST OF IT NOTHING ELSE OF OURS STANDS: the painted valley with
the town, the two ranges and the cloud banks are given and already in the game; a9.py's far peak
cards, its tiny town and its clouds are not put back); the slab hollow -5.4 .. -2.4; inside, every
room's back wall (the glacier's body carried on behind: mid blue, duller and cooler) z -4.0 .. -2.4,
its nearest plane at -2.4, deeper planes to -4.0; the frozen climbers deep in the ice, the tally
marks, the arrow signs' and lanterns' feet on those walls' faces (-2.4 .. -2.38); the arrow signs'
boards and the lanterns 1.0 m out from the wall (-1.4); outside, the tongue's flanks (its body behind
the outer skin) -3.0 .. -1.5, the backs of the roofed chute and the two upper niches -3.0 .. -2.4, the
slab mouth -3.45 .. -1.25; the ice at each frozen climber's back -2.4 .. -1.25; the snow hole
-3.6 .. -1.25; the window's reveal -2.4 .. -1.25; the fallen blocks, the heap, the pit's jam, the
tower's twin, the canes, and what the climbers left (axes, coils, glove) between -1.25 and -3.3. In
front: only the snow fringes on the lip, on the brow and on the tower's top (z 1.25 .. 1.5, each in
front of solid ice and under 0.3 m proud of the ice's own face) and the kit's snow cornice on the
tower's top (in front of solid ice, wholly above any hand: 9.9 note). No icicle, no sheet of ice and
no cloud stands in front of the climb (notes 87 and 92).

A deco's origin is the middle of its base (x and z) at its foot (y), unless its comment says
otherwise: wall-mounted things (an arrow sign, a lantern's hook, the tally marks) the middle of
their foot on the wall; `lantern_hang` its hook; `icicle_row` the middle of its top; a turned piece
(a knuckle, a plate, a tusk's or a horn's) the middle of its base AS TURNED, so the game's turn about
its origin lays it exactly on its solid. For the long pieces (walls, skins, bodies, cards): the
middle of the x span, the bottom of its box, the middle of its depth. A deco's size is the size its
model is MADE at (the game rescales a landed model more than a quarter off; skins are never
rescaled); where one model is used at several sizes, `scale` does it and the size is the model's
own (the stones and nubs are made at r 0.24 and scaled to each hold's r; the plates at 0.72 m). `rot`
is in degrees, counter-clockwise as the camera sees it (a positive rot tips a thing's top to the
west).

Shared pieces are placed once, in the first section that names them: the floor of the tunnel and the
crack (8 to 9, 9.1), the cave floor's slab (8 to 9, 9.0, 9.4), the west wall (every inside page), the
corner ledge and the pug arrow sign (9.1, 9.2), the three arrow signs (9.1, 9.2, 9.3), the one who fell
(9.1, 9.3), the crack's roof with the door's lintel (9.2, 9.3, 9.4), the door's lantern (9.1, 9.3, 9.4),
the cave's back wall (9.4, 9.0, 9.6), the fallen block and the glove (9.4, 9.0), the one in the wall by
the rope (9.0, 9.6), the ice over the upper level and the chute (9.5, 9.6, 9.8), the pillar's snow (9.5,
9.6), the window's sill, reveal, paper and lantern (9.6, 9.7), the R7 niche (9.7, 9.8), the R8 niche and
its cane (9.8, 9.9), the tower (9.9, 9.10), the R9 niche and its cane (9.9, 9.10), the slab hole and the
hollow (9.8, 9.9, 9.10).

FOR THE AREA FILE (tools/peak/areas/a9.py; the fix thread's). Line numbers are a9.py's as of
2026-11-14 (the version with the fallers seen coming, the serac's shatter at 108 degrees and the
chute's kicker board).
  1. Call it: `import a9_dress` beside the other imports (line 19), and `a9_dress.dress(A)` after the
     effects (line 446), before `if __name__ == "__main__":` (line 448), so before A.save().
  2. Lights. The sheet's only warm light: one lantern at each door on the side you go through, the
     frog's, and the last climber's. Add six, each "#FFB860", range 3.5, energy 0.9, flicker, at
     a9_dress.LANTERN_LIGHTS (x, y, z: the tunnel's mouth, the cave's door, the chimney's foot, the
     window's outer side, the frog's snow hole, the last cane). The last climber's lantern takes the
     place of line 438 (the light on the reaching arm). KEEP the cold sky lamps (431-435), the glint
     at 436, the light under the cornice (437) and the blue shadow (439).
  3. Decos to take out (this file places what the pages keep, out of the play space): lines 416-423
     (the four deep climbers at their old places, the axe and the coil on the brink at z -0.5, the
     glove at -0.6, the dead lantern on the door's lintel, the tally marks at -0.9, the paper at the
     window at -0.9) and 425-429 (the icicle row under the lip at -0.4: it moves 1.3 m back under
     the roof's eave; the cave's icicle row: it goes, page 9.4 "no fringe where an icicle falls"; the
     snow cornice at +0.8: it moves to the foreground; the ice block at -1.4: back to -2.3; the tiny
     town: the town is given). KEEP line 424, the prayer pole: it is the storm ridge's (its page "9
     to 10" moves it 1.4 m east, to the cabin's west corner; a10's dress places it).
  4. Cards to take out: 393-395 (the ice behind every hollow), 396 (the lower crevasse), 397-398 (the
     cave and the upper level), 402 (the pale band behind 9.1's holds: "it goes", note 84), 404-406
     (the six ribs: the ribs are painted on the back walls where the pages move them), 408, 409, 410
     (the three snow strips: the fringes here, moved as pages 8 to 9, 9.7 and 9.9 ask), 412-413 (the
     far peaks and the haze: the glacier's far side and what is given). The cards of ice in the play
     space at each frozen climber (encased(), line 36, called by climber() for the six; and line 383,
     the horn at the last one's back): take them out (pass card=False, and drop line 383): the ice at
     their backs is placed here from z -1.25 back (note 87). KEEP lines 399-400 (the gap's rock in
     shadow) until the storm ridge's dress places the ridge's flank there, BUT cut a hole in it round
     the slab hollow (x -292.6 .. -287.6, y 864.2 .. 869.3): the card stands at z -2.4 and the hollow
     goes back from -2.4 to -5.4, so today the card hides it (and every slab the kicker throws to z -4
     passes behind the card). Effects: take out the clouds (line 446: "Never a sheet of ice, an
     icicle or a cloud in front of the climb", and the cloud banks are given). KEEP the snow, the two
     mists, the drips and the spindrift (441-445).
  5. Skins. Each named solid takes `skin=` its stem; this file places every skin deco.
     - The bed (line 52): "glaciar_bed". The west wall (53): "glaciar_west_wall".
     - The crevasse floor (54): "glaciar_floor_crack".
     - The lower tongue and the lip (58): "glaciar_tongue_low".
     - The cave's floor slab (62): "glaciar_cave_slab"; its snow (63): "glaciar_floor_cave".
     - The crack's roof (65) and the door's lintel (66): both "glaciar_crack_roof" (one piece).
     - The balcony's snow (67): "glaciar_balcony_snow".
     - The block under R4 (70): "glaciar_serac_block"; R4's snow (71): "glaciar_brink_snow"; the pit's
       west funnel (72): "glaciar_pit_funnel".
     - The toboggan's mass (80): "glaciar_tobogan"; T's snow (81): "glaciar_pillar_snow".
     - The ice over the upper level, the cave and the chute (87): "glaciar_upper_mass".
     - The brow and the face of 9.7 (90): "glaciar_brow".
     - The glaze on the ledge's nose (97): "glaciar_verglas_nose". (The exit ledge, 94, and the ridge's
       rock behind it, 95, are the storm ridge's to skin.)
     - The tower (105): "glaciar_tower". The three niches' snow: R8 (107) and R7 (109)
       "glaciar_niche_snow" (one each), R9 (108) "glaciar_niche_snow_short".
     - 9.1: the twelve knuckles (127, each A.box): "glaciar_knuckle"; the three stones (125, each
       A.hold): "glaciar_stone". R1 (128): "glaciar_corner_snow".
     - 9.2: the shelf (138): "glaciar_shelf"; R2 (139): "glaciar_shelf_snow"; the five icicles (143):
       "glaciar_icicle_ringed_a" (the first and the third, 2.6 m), "_b" (the second), "_c" (the
       fourth, at -321.3), "_d" (the fifth, at -320.0); the rock tooth (144): "glaciar_stone_tooth";
       the stone on the nose (145): "glaciar_stone".
     - 9.3: the nine bridge pieces (166): "glaciar_snow_bridge" (each its own skin deco, so each goes
       and comes back with its piece); the two wedged stones (170, 172): "glaciar_wedged_stone_a",
       "glaciar_wedged_stone_b".
     - 9.4: the four knuckles (189, 190, 192, 195): "glaciar_knuckle_short"; the stone (193):
       "glaciar_stone". The six climbers' grips (bone) stay unskinned until the new climber model.
     - 9.6: the flake (260): "glaciar_kicker"; R6 (265): "glaciar_window_sill".
     - 9.7: the fang under the brow (274): "glaciar_tusk"; the five ice holds (278): "glaciar_nub", the
       stone (278, i == 2): "glaciar_stone"; the three plates (280): "glaciar_plate".
     - 9.8: each island's two solids (304, 305): "glaciar_long_stone" (one piece for both, one for
       each island); the fang (321): "glaciar_tusk_short"; the three nubs (330): "glaciar_nub"; the
       eight plates (333): "glaciar_plate"; the rope's horn (337): "glaciar_stone".
     - 9.9: the fang (354): "glaciar_tusk_short"; the six nubs (358): "glaciar_nub".
     - 9.10: the fang (375): "glaciar_tusk_short"; the two nubs (376, 377): "glaciar_nub".
  6. Course changes the pages ask for (not scenery):
     a. 9.8 (notes 91, 93): the page's kicker is a flake with a face 1.8 m long at x -290.8 .. -289.05
        (a9_areas._KICKER: (-290.8, 863.21), (-289.05, 863.45), (-289.05, 862.12)), 2.4 m uphill of
        the rope; the course's board (line 344) is 1.03 m long at x -288.5 .. -287.6. Either way its
        look is `glaciar_kicker_chute`, made to the board as it stands (item 8): if the board grows,
        the model is re-cut to it.
     b. 9.8 (note 93): "the slabs start at the wall, 1.3 m west of where they start today": the slab
        spawner (line 339, x -301.2) to the ice wall at x -302.5. The mouth's model is placed here at
        the game's drawn mouth (item 8); it moves with the spawner.
     c. 9.8 (note 91): the thrown slab should land in the hollow (x -292.6 .. -287.6, z -2.4 .. -5.4)
        and burst there. Today the board throws it east (vx +0.6) from x -288, toward the hollow's
        east edge, and to z -4.0 behind the gap's card (item 4). Check where it lands once the hole is
        cut.
     d. 9.8 (note 91; the sheet: "slab 1 m", "A block of white snow 1 m across, exactly the size that
        is solid"): the game's slab is r x 6 = 3.0 m long, 0.8 thick, 1.92 deep (peak_things.gd,
        _spawn_faller), and its drawn mouth 3.8 x 2.2. The model list makes both to the game as it
        is; the page asks for 1 m. The fix thread's call.
     e. 9.2 (note 86): the falling icicle is drawn with the kit's `icicle_big` (2.5 m, made as a
        HOLDING icicle) over a capsule 0.24 x 0.9 m: drawn nearly three times what is touched, and
        with the rings the sheet keeps for the ones that hold. `glaciar_icicle_falling` (item 8) is
        made to the capsule; the game's two kit_model("icicle_big") calls take it for icicles.
     f. Note 90: the game blunts sharp tips (peak.gd blunt(), BLUNT_W 0.08 m); the pages ask for a flat
        end "about 0.2 m across" (to be set by play). The skins of the icicles, the tusks and the tooth
        are drawn to the full sharp point either way.
     g. 9.1 to 9.3 (Parker: "Keep the close camera as normal"; page 9.1: "it is not pulled back for
        this room"): line 178's camera over 9.3 asks half_h 9.5. To check that it is the close camera.
     h. The frozen climbers: nothing climber-shaped is modelled until the new climber model lands
        (MODELLING_RUN). The seven stay the game's statues on their bone grips; no deco here stands in
        for them. Each one's ice is placed (item 4).
  7. Found while dressing, not on a page:
     a. st.json (the shared structure) places eight white clouds in this biome's sky (cloud_d
        (-158.9, 793.5, z -70.4), cloud_e (-197.7, 804.9, -27.2), cloud_a (-261.6, 816.7, -29.2),
        cloud_b (-250.9, 830.3, -47.1), cloud_c (-232.4, 843.8, -55.7), cloud_d (-192.5, 865.2, -41.0),
        cloud_e (-192.8, 874.6, -77.7), cloud_a (-267.9, 886.8, -38.6)): cloud_a at 816.7 and cloud_b
        stand right behind the glacier's outside, in front of its far side (45 m back). As a7 7b and
        a8 7c ask: whoever owns st.json takes them out, or rules them part of the given far view.
     b. The far side stands 45 m back, so it slides to about a quarter of the camera's offset: its
        east edge (x -250, leaning towers to -246) is set for the outside cameras of 9.7 to 9.10 (it
        shows 4 to 10 m east of the skin you climb from cameras about x -280 .. -290). Its foot (812)
        fades into painted haze; from the high deck's camera (page 8 to 9: "East of the lip's tip ...
        nothing of this biome") its top rows may show over the lip. Judge it in the frames: if they
        do, its foot goes up.
     c. The high station's house (a8's `tele_station_house_high`): page 8 to 9 adds "the glacier lies on
        its roof, has pushed in its west end, and fills its west window with blue ice". Here the
        tongue's flank lies on the roof's back half; the house's own west end and window are a8's
        model (a9_models.md, section 5, asks for them).
     d. The window (9.6, 9.7) is seen edge-on, so the daylight in it is painted: the reveal
        (`glaciar_window`) stands behind the gap between the sill and the brow, pale with a frost rim,
        and the window's lantern hangs on the flank just east of it (the page's spot, x -282.2, has
        nothing behind it to hang from at z -1.4).
     e. The papel tatters line unit is 8 m; the window's paper is 3 m and the frog's string 1.5 m, and
        the game would squash the kit's to fit. `glaciar_paper_tatters` is a 3 m unit of the same torn
        paper (item list, maker B).
  8. Movers', fallers' and breakables' looks (the area file's and the game's; models in
     a9_models.md section 4):
     - the serac (line 220): keeps the kit's `serac` (matched to the course's snow side). The pages
       add the one that grows: `glaciar_serac_bare` (the same tower with no snow, bare and dark: the
       game shows it while it grows, then the serac when it is full height and can be held) and its
       stump `glaciar_serac_stump` (0.6 m, left at the pivot while the tower is gone).
     - the falling icicles (spawners, lines 149, 150, 174, 204): `glaciar_icicle_falling` (item 6e),
       its growing stages the game's scaling of it.
     - the snow slabs (line 339): `glaciar_snow_slab` (as the game makes it, item 6d); the dark mouth
       they come out of is `glaciar_slab_mouth`, placed here as scenery at the game's drawn mouth
       (x -301.2, y 880.55, z -1.8: peak_things.gd _tick_coming); when it lands, the game's drawn disc
       goes.
     - the kicker board (line 344, model=""): model="glaciar_kicker_chute" (item 6a).
     - every shatter (the icicles, the serac, the slabs, a fallen bridge piece): `glaciar_ice_shard`
       in place of the game's boxes, scaled from 0.2 to 1 m.
     - the snow bridges and the five big icicles go and come back with their skins (item 5).
  9. Effects (the pages'; a9.py's snow, mists, drips and winds draw some): one slow drip from the
     fringe onto each patch of ice on the deck (8 to 9); snow sifting from the bridges all the time,
     more from the one you are on (9.1, 9.3); frost dust falling through the lit gap (9.2); a big
     icicle creaking and snapping clean at its collar, a new one growing from the collar (9.2); each
     lantern's flicker and its amber on one climber (9.4); a cold draught west along the balcony
     (9.4); steam rising straight from the frog's kettle, a few flakes the whole height of the cave
     (9.0); snow sliding off the serac's cap as it tips, a white crack opening along its foot, ice
     dust out of the pit, the bent layers creeping as the next grows (9.5); the draught's wavy lines
     across the bowl and snow smoking east off the kicker's lip, frost off the rope (9.6); snow
     smoking off the brow and the niche's edge the way the wind goes, the canes' flags dropping slack
     and lifting the new way before each gust (9.7); after each burst, snow dust pouring down the
     roofed chute past you and out of its mouth (9.8); frost falling from a nub as it lets go, fine
     snow off the cornice's lip (9.9); the last cane's flag and the prayer pole's paper streaming the
     same way (9.10).
"""
import math

# ------------------------------------------------------------------ the course's own numbers (a9.py)
FLOOR = 786.0           # the tunnel's snow floor, the alcove, La Pasarela Helada and its west landing (8 to 9, 9.0, 9.1)
POOL_BED, POOL_S = 781.4, 784.0  # the meltwater pool in the lower crack: its bed and its surface (note 147; a9.py)
R1 = 798.5              # the corner ledge (9.1, 9.2)
SH_Y = 802.6            # the shelf's underside (9.2)
R2 = 804.0              # the shelf's top, the bridges, the door's sill, the cave's floor (9.2, 9.3, 9.4, 9.0)
BALCONY = 812.0         # the balcony (9.4)
R4 = 832.0              # the brink (9.5)
T_TOP = 834.5           # the pillar (9.5, 9.6)
SILL = 830.2            # the window's sill (9.6, 9.7)
R7 = 846.0              # the niche under the chute's mouth (9.7, 9.8)
R8 = 867.8              # the niche in the stem (9.8, 9.9)
R9 = 873.3              # the niche under the tip (9.9, 9.10)
ROOF_Y = 871.8          # the cornice's underside (9.9)

# Depths.
WALL = -2.4             # every room's back wall: its nearest plane (the far wall's face)
WALL_FAR = -4.0         # and its deepest
ON_WALL = -2.38         # flat things lying on a back wall's face
FLANK = -1.5            # the tongue's flank outside: its face
FLANK_FAR = -3.0
BACK = -1.25            # the near edge of the background

# Stand-in tones.
ICE = "#26344A"         # the glacier's body: blue-black, glossy (the course's blackice)
PALE = "#9FDDF2"        # pale blue ice you hold for 2 s
SNOW = "snow"
STONE = "#8C7B6C"       # grey-brown stones, dry
BACKWALL = "#4A7096"    # a room's back wall: mid blue, dull
FLANKC = "#3A4E68"      # the tongue's flank: dark ice a step duller
FAR = "#7E8EA4"         # the far side: mid blues and greys, hazed
WOOD = "wood"
ACCENT = "accent"
IRON = "iron"

# Lights for a9.py (FOR THE AREA FILE item 2): x, y, z of each lit lantern's flame.
LANTERN_LIGHTS = [(-286.1, 789.7, -1.4),     # the tunnel's mouth (8 to 9)
                  (-301.3, 807.7, -1.4),     # the cave's door, beside the first climber (9.3, 9.4)
                  (-328.6, 814.6, -1.4),     # the chimney's foot, beside the third (9.4)
                  (-280.4, 833.73, -1.4),    # the window's outer side (9.6, 9.7)
                  (-286.0, 805.35, -2.0),    # the frog's snow hole (9.0)
                  (-294.3, 881.9, -1.43)]    # the last cane, beside the last climber (9.10)

# 9.1: the fifteen holds of Hielo Azul, exactly as a9.py lays them (lines 115-127).
_P1A, _P1B = (-308.0, 787.8), (-327.5, 798.5)
_K91 = ["ice", "ice", "rock", "ice", "ice", "ice", "rock", "ice", "ice", "ice", "ice", "rock", "ice", "ice", "ice"]
H91 = []
for _i in range(15):
    _f = _i / 14.4
    _zig = 0.33 if _i % 2 else -0.33
    H91.append((_P1A[0] + (_P1B[0] - _P1A[0]) * _f + _zig * 0.48, _P1A[1] + (_P1B[1] - _P1A[1]) * _f + _zig * 0.88,
                _K91[_i], 18.0 if _i % 2 else -14.0))
# 9.2: the five big icicles (x, tip y) and the four that fall (a9.py 140, 148).
ICI = [(-326.9, 800.0), (-325.5, 800.2), (-324.1, 800.0), (-321.3, 800.8), (-320.0, 801.5)]
ICI_STEM = ["glaciar_icicle_ringed_a", "glaciar_icicle_ringed_b", "glaciar_icicle_ringed_a", "glaciar_icicle_ringed_c", "glaciar_icicle_ringed_d"]
# 9.3: the nine bridge pieces (a9.py bridge(): their west ends; each 1.06 long, 0.45 thick, the middle one 0.15 lower).
BRIDGES = []
for _x0 in (-317.78, -313.28, -308.78):
    for _k in range(3):
        BRIDGES.append((_x0 + _k * 1.14, 803.55 - (0.15 if _k == 1 else 0.0)))
# 9.4: the six frozen climbers you hold (their pelvises: a9.py 186-196) and the chimney's four knuckles.
C94 = [(-302.4, 806.9), (-302.4, 809.8), (-329.9, 814.4), (-328.7, 820.2), (-329.9, 826.0), (-328.2, 830.6)]
K94 = [(-328.7, 816.9, 10.0), (-329.9, 818.2, -12.0), (-329.9, 822.6, 12.0), (-328.8, 828.4, -10.0)]
# 9.6: the slide's flake (a9.py 76-79, 258-260).
_RAMP = [(-310.46, 834.15)]
for _ang, _len in ((82, 5.93), (72, 0.9), (62, 0.9), (52, 0.9), (42, 0.9), (32, 0.8), (22, 0.8), (12, 0.8), (2, 0.7), (-10, 0.6)):
    _RAMP.append((_RAMP[-1][0] + math.cos(math.radians(_ang)) * _len, _RAMP[-1][1] - math.sin(math.radians(_ang)) * _len))
_FX, _FY = _RAMP[-1][0] + 1.1, _RAMP[-1][1] - 0.25
_LIP = (_FX + 1.8 * math.cos(math.radians(32)), _FY + 1.8 * math.sin(math.radians(32)))
FLAKE = [(_FX, _FY), _LIP, (_LIP[0], _LIP[1] - 0.8), (_FX + 0.5, _FY - 1.55), (_FX, _FY - 1.55)]
TOBOGAN = [(-318.8, 817), (_RAMP[-1][0], 817)] + _RAMP[::-1] + [(-312.96, 834.15), (-312.96, 828.5), (-318.8, 824.5)]
# 9.7: the six holds up the wall and the three plates on the brow (a9.py 275-280).
H97 = [(-282.25, 837.8), (-282.25, 839.3), (-282.25, 840.8), (-282.25, 842.3), (-282.25, 843.8), (-282.25, 845.2)]
PLATES97 = [(-279.9, 835.1), (-281.2, 835.99), (-282.2, 836.67)]
# 9.8: the chute (a9.py 84-85, 295-333).
NOSE = (-278.8, 850.5)
_CU = (-math.cos(math.radians(50)), math.sin(math.radians(50)))
_CN = (math.sin(math.radians(50)), math.cos(math.radians(50)))


def P(s, n=0.0):
    """A point on the chute: s m up it from its mouth, n m off its floor (a9.py P)."""
    return (NOSE[0] + _CU[0] * s + _CN[0] * n, NOSE[1] + _CU[1] * s + _CN[1] * n)


def _gz(s0, s):
    if s0 is None or s >= s0 + 3.7:
        return 0.1
    return 0.14 + (s0 + 3.7 - s) * (0.92 / 3.68)


def _island(s0):
    """Both solids of a long stone and its glaze (a9.py island())."""
    return ([P(s0 + 3.4, -0.1), P(s0, -0.1), P(s0, 0.55), P(s0 - 0.6, 0.68), P(s0 - 0.6, 0.9), P(s0, 0.9)] +
            [P(s0 + 3.7, 0.0), P(s0 + 3.7, 0.12), P(s0 + 0.02, 1.04), P(s0 - 0.78, 1.04), P(s0 - 0.78, 0.64)])


NUBS98 = [(-280.7, 849.85), (-279.6, 849.95), (-278.62, 850.42)]
PLATES98 = [(s0, sv) for s0, ss in ((None, (1.3, 2.5)), (3.6, (4.4, 5.8, 7.2)), (8.4, (9.2, 10.6, 12.0))) for sv in ss]
# 9.9 and 9.10: the nubs.
NUBS99 = [(-288.5, 871.5), (-290.2, 871.5), (-291.9, 871.5), (-293.6, 871.5), (-295.2, 871.5), (-296.2, 872.6)]
NUBS910 = [(-296.2, 878.6), (-296.2, 879.9)]
# The tower (a9.py 103-106) and the top of its sloping roof at x.
TOWER = [(-280, 859.2), (-280, 870.53), (-295.7, 881.0), (-295.9, 880.7), (-295.9, 877.3), (-293.2, 877.3), (-293.2, 873.0),
         (-295.9, 873.0), (-295.9, ROOF_Y), (-283.5, ROOF_Y), (-283.5, 867.5), (-286.5, 867.5), (-286.5, 866.95)]


def _tower_top(x):
    return 870.53 + (-280.0 - x) * (10.47 / 15.7)


# The made sizes of the pieces placed at several sizes.
NUB_R = 0.24            # glaciar_nub and glaciar_stone are made to a hold of r 0.24: 0.42 x 0.48 (the hexagon), 0.6 deep
PLATE_L = 0.72          # glaciar_plate: 0.72 x 0.22 x 0.4


def _box(pts):
    xs, ys = [p[0] for p in pts], [p[1] for p in pts]
    return min(xs), max(xs), min(ys), max(ys)


def dress(A):
    # ------------------------------------------------------------ helpers
    def skin(stem, x0, x1, y0, y1, tone=ICE, z_front=1.2, z_back=-1.2, flip=False):
        """The look of course solids: their box, from z_front back to z_back (a floor or a roof carried
        back to the far wall: z_back -2.4)."""
        A.deco(stem, round((x0 + x1) / 2, 3), round(y0, 3), z=round((z_front + z_back) / 2, 3),
               size=(round(x1 - x0, 2), round(y1 - y0, 2), round(z_front - z_back, 2)), tone=tone, skin=True, flip=flip)

    def turned(stem, cx, cy, w, h, d, rot=0.0, tone=PALE, scale=1.0, z=0.0, is_skin=True):
        """A piece turned rot degrees about its own middle (cx, cy), placed by the middle of its base as
        turned (w, h, d its made size; scale the size it is used at)."""
        a = math.radians(rot)
        hh = h * scale / 2
        A.deco(stem, round(cx + hh * math.sin(a), 3), round(cy - hh * math.cos(a), 3), z=z, rot=round(rot, 2),
               scale=round(scale, 3), size=(w, h, d), tone=tone, skin=is_skin)

    def nub(x, y, r, stone=False):
        """A hold of the course (A.hold, a hexagon r): a nub of pale blue ice, or a grey-brown stone."""
        turned("glaciar_stone" if stone else "glaciar_nub", x, y, 0.42, 0.48, 0.6, tone=STONE if stone else PALE, scale=r / NUB_R)

    def plate(p0, p1, t):
        """A plate of pale blue ice lying on a face (A.patch from p0 to p1, t thick)."""
        L = math.dist(p0, p1)
        rot = math.degrees(math.atan2(p1[1] - p0[1], p1[0] - p0[0]))
        rot = rot - 180.0 if rot > 90.0 else (rot + 180.0 if rot < -90.0 else rot)
        turned("glaciar_plate", (p0[0] + p1[0]) / 2, (p0[1] + p1[1]) / 2, PLATE_L, 0.22, 0.4, rot=rot, scale=L / PLATE_L)

    def hanging(stem, pts, d, tone=PALE, made_h=None):
        """A point of ice hanging from a roof (an icicle, a tusk, the tooth): the skin of its solid,
        round, d deep about z 0, drawn to the full sharp point. made_h: one model made that long and
        scaled to each solid (the short tusks, made 0.5 x 2.4)."""
        x0, x1, y0, y1 = _box(pts)
        w, h, sc = round(x1 - x0, 2), round(y1 - y0, 2), 1.0
        if made_h:
            sc, h = round((y1 - y0) / made_h, 3), made_h
        A.deco(stem, round((x0 + x1) / 2, 3), round(y0, 3), z=0.0, scale=sc, size=(w, h, d), tone=tone, skin=True)

    def back(stem, x0, x1, y0, y1, z_near, z_far, tone=BACKWALL):
        """A piece behind the play space, from z_near back to z_far (origin: the middle of its foot)."""
        A.deco(stem, round((x0 + x1) / 2, 3), round(y0, 3), z=round((z_near + z_far) / 2, 3),
               size=(round(x1 - x0, 2), round(y1 - y0, 2), round(z_near - z_far, 2)), tone=tone)

    def front(stem, x0, x1, y0, y1, z_near, z_far, tone=SNOW):
        """A piece in front of the play space (z_near the side toward the play space)."""
        A.deco(stem, round((x0 + x1) / 2, 3), round(y0, 3), z=round((z_near + z_far) / 2, 3),
               size=(round(x1 - x0, 2), round(y1 - y0, 2), round(z_far - z_near, 2)), tone=tone)

    def cane(x, y, z, east=True):
        """A route cane with its paper flag in the town's colours: the kit's streamer_pole at 0.75 (3 m);
        it streams east unless east=False."""
        A.deco("streamer_pole", x, y, z=z, scale=0.75, size=(0.2, 4.0, 0.2), tone=ACCENT, flip=not east)

    def arrow(cx, cy, ang):
        """An arrow sign sticking 1 m out of a back wall on two canes, behind the climb (Parker 11-13).
        Made pointing east; turned by ang about the middle of its board. Origin: the middle of the
        board (x, y), the middle of its depth (the canes' feet on the wall at -2.4, the board at -1.4)."""
        A.deco("glaciar_arrow_sign", cx, cy, z=round(WALL + 0.525, 3), rot=ang, size=(1.6, 0.7, 1.05), tone=ACCENT)

    def lantern_hook(x, flame_y, wall=WALL):
        """A candle lantern hanging from a hook cut from an axe shaft, the shaft driven level into the
        ice and standing 1.0 m out of it (made 0.3 x 0.75 x 1.05; origin the middle of its foot on the
        wall: the lantern's bottom, 0.3 under its flame; the lantern itself 1.0 m out)."""
        A.deco("glaciar_lantern_hook", x, round(flame_y - 0.3, 3), z=round(wall + 0.525, 3), size=(0.3, 0.75, 1.05), tone="gold")

    def deep(x, y, rot):
        """One of the ones who tried, deep in the ice: the kit's frozen_climber_deep, flat on a back
        wall's face, any way up (origin his feet: the page's figure is centred at (x, y))."""
        a = math.radians(rot)
        A.deco("frozen_climber_deep", round(x + 0.95 * math.sin(a), 3), round(y - 0.95 * math.cos(a), 3), z=ON_WALL, rot=rot,
               size=(0.93, 2.0, 0.07), tone="#8FBFE0")

    def climber_back(x, y):
        """The slab of dull mid-blue ice at a frozen climber's back (KIT_MORE; note 87): 1.7 x 3.0, from
        the play space's back edge to the far wall. (x, y) is his belt."""
        back("glaciar_climber_back", x - 0.85, x + 0.85, y - 1.35, y + 1.65, BACK, WALL, tone="#6E93B6")

    # ============================================================ the far side
    # The glacier's far side (9.7, 9.8, 9.9, and from the window): ONE flat painted card 45 m back made the way
    # the far cards are (BRIEF.md "Far backgrounds": a thick card whose cut edge shows kraft, a dark stripe, kraft,
    # braces behind): the rest of the glacier going away along the face, three rows of broken ice, the back row
    # hazed to the sky, snow in drifts along each row's foot, four or five big leaning towers cut into its east
    # edge; mid blues and greys, nothing near white (so the wind's white lines show against it); its foot fading
    # into painted haze (item 7b). Nothing else of ours stands east of the skin: the rest is given.
    back("glaciar_far_side", -340.0, -250.0, 812.0, 912.0, -45.0, -45.5, tone=FAR)

    # ============================================================ 8 to 9: under the lip
    # The bed under the floors (skin, line 52): blue-black ice glazed over rock, its front painted in long
    # bands; its east end (x -282 .. -281) meets the deck's planks broken off under the snow's edge.
    # (NOTE 147, 11-19: the bed and the floor are cut for the meltwater pool and the falls' head; their two skins,
    # glaciar_bed and glaciar_floor_crack, were made whole, so they are out until re-made to the new shape, and the
    # solids are drawn in their kinds. Below: the pool, the falls' head and La Pasarela Helada.)
    # The floor of the tunnel and the crack (skin, line 54): firm snow 0.7 m thick, white and matte with a square
    # front edge and the ice plain under it, carried back to the far wall; painted on it: a line of old boot
    # prints going west from the deck to the first knuckle, a blue hollow every few metres, low ridges the
    # draught has combed, and a ring of ice splinters 1 m across under each of the four falling icicles (x -326.2,
    # -324.8, -322.0, -320.65). Never 4 m blank.
    # The lower tongue and THE LIP (skin, line 58): one piece made for its place. Outside, the slide's last
    # ramps (52 then 34 degrees) to the tip that throws a body clear of the deck, dark, glossy, polished by
    # everything that has come down it, a few big planes, the bands long wavy lines; its underside the alcove's
    # roof, 4.8 m over the deck, lying on the roof (a8's skin) and frozen round the last pennant line's end.
    # Inside (its west face, x -284.5, 804 .. 829.9) the ice cave's east wall, darker toward the frog's hole.
    skin("glaciar_tongue_low", -284.5, -271.5, 790.8, 829.9)
    # The cave's floor slab (skin, line 62): the tunnel's roof, scooped by the old water, carried back to the far
    # wall; its west face (x -305.5, 790.8 .. 803.4) the crack's east wall under the door, paler toward the door.
    skin("glaciar_cave_slab", -305.5, -284.5, 790.8, 803.4, z_back=WALL)
    # The back wall of the alcove and the tunnel: ONE painted piece, mid blue and dull, bands tilting down to the
    # east, scooped by the old water into shallow dishes a metre across, four stones standing out of the bands
    # (paint: (-301.2, 788.2), (-297.6, 789.4), (-293.1, 787.6), (-289.4, 788.9)), the same mid blue end to end;
    # at its east end it comes down over the house's west end like a poured thing that set (the house, a8's,
    # stands from x -282 at z -2.45 .. -5.55: this piece laps over its west corner, its face 0.05 in front of the
    # house's wall, and stops at x -279.0).
    back("glaciar_tunnel_back_wall", -305.5, -279.0, 785.9, 790.9, -2.35, WALL_FAR)
    # The tongue's flank (8 to 9, and outside the cave up to the window): the glacier's own body behind the
    # outer skin, dark ice a step duller in two or three slanted planes, its bands thin lines carrying on the
    # skin's, an uneven edge 2 to 3 m east of the skin (never east of x -273.5), one small sloping snow shelf;
    # its foot lying on the station roof's back half (a8's tele_roof_high, 791.1 .. 791.4 at these depths); above
    # the cave's top (829.9) only east of x -281, beside the window.
    back("glaciar_tongue_flank_low", -284.5, -273.5, 791.0, 834.7, FLANK, FLANK_FAR, tone=FLANKC)
    # The icicle fringe (page 8 to 9: 1.3 m back, from the real roof's eave, behind its held front edge): the
    # kit's icicle_row (origin the middle of its top), from the roof's underside (790.5), over the deck's ice.
    A.deco("icicle_row", -275.4, 790.5, z=-1.55, size=(12.0, 1.14, 0.39), tone=PALE)
    # The first cane, at the back of the alcove on the floor's snow, its flag almost slack, leaning west.
    cane(-283.4, FLOOR, -1.6, east=False)
    # The tunnel's lantern, 1.5 m inside its mouth, above head height, on the side you go through: the first
    # lit lamp since the frog's car (light: item 2).
    lantern_hook(-286.1, 789.7)

    # ============================================================ 9.0 the falls' head, the pool, La Pasarela Helada (note 147)
    # A stylized first pass: kit models already landed, no new ones.
    # The pool's far wall under the crack's (from its bed to the crack's wall's foot at 786): the kit's tunnel back
    # wall again, the old water's scooped dishes in banded mid blue, here at the pool's back.
    back("glaciar_tunnel_back_wall", -330.25, -303.75, 780.9, 785.9, -2.35, WALL_FAR)  # (its own size: 26.5 x 5)
    # And again just behind the play space over the falls' head and the pool's east end (its face 2 cm behind the
    # solids' backs): the cableway's face body (a8_dress tele_face_body_b, x -310 .. -266 up to 786, z -1.25) stands
    # there, and with the bed cut it showed tan between the water and the bridge.
    back("glaciar_tunnel_back_wall", -312.15, -285.65, 781.05, 786.05, -1.22, -2.87)  # (clear of the fallen shelf, x -312.4; to just over the floor: the face body's top showed over it)
    # The meltwater cave, where the ice blocks come out: a dark arch in the far wall at the pool's west end, from under
    # the water to 1.9 m over it (the blocks come forward out of it, from z -3.4).
    A.card([(-329.9, POOL_S - 0.4), (-327.3, POOL_S - 0.4), (-327.3, POOL_S + 0.9), (-327.7, POOL_S + 1.45),
            (-328.6, POOL_S + 1.8), (-329.5, POOL_S + 1.45), (-329.9, POOL_S + 0.9)], z=-2.3, tone="#0E1626", edge=False)
    # The shelf's other half (9.1's page): its two blocks lie in the pool now, under the shelf's broken end, behind
    # where you swim, their tops out of the water.
    back("glaciar_shelf_fallen", -317.7, -312.4, POOL_S - 1.4, POOL_S + 0.5, -1.43, -2.45)  # (into the far wall)
    # The bridge's posts, one at each end on the side away from you, their brackets reaching over the boards.
    A.deco("riscos_bridge_post", -296.75, FLOOR, z=-1.45, size=(0.89, 1.6, 0.24), tone=WOOD, flip=True)
    A.deco("riscos_bridge_post", -305.55, FLOOR, z=-1.45, size=(0.89, 1.6, 0.24), tone=WOOD)
    # Its broken railing, behind the boards: a bent length off the east post, a straight stub off the west one.
    A.deco("aguas_hand_rail_bent", -298.6, FLOOR + 0.85, z=-1.55, size=(2.6, 0.7, 0.44), tone=IRON)
    A.deco("aguas_hand_rail", -304.6, FLOOR + 1.05, z=-1.55, size=(2.0, 0.3, 0.44), tone=IRON)
    # Icicles under the boards' back edge, hanging into the falls (never in front of the climb).
    A.deco("icicle_row", -300.9, FLOOR - 0.5, z=-1.45, scale=0.55, size=(6.6, 0.63, 0.22), tone=PALE)  # (under every board)
    # The warning sign on the tunnel's back wall before the bridge, and a frozen coil of the bridge's lashing rope
    # left on the west landing.
    A.deco("sign_warn_bang", -295.9, FLOOR + 1.9, z=-2.3, size=(1.62, 1.58, 0.14), tone=ACCENT)
    A.deco("rope_coil_frozen", -307.8, FLOOR, z=-2.11, size=(0.65, 0.25, 0.58), tone=WOOD)  # (against the far wall)
    # Foreground: the snow fringe along the lip's top edge, 0.5 m in from today's strip, in front of the lip's own
    # ice only (not over the ramp a sliding body comes down), along its two slopes (made in place:
    # (-280.5, 799.9), (-276.5, 794.7), (-271.6, 791.35), 0.35 deep: under 0.3 m above the ice's face).
    front("glaciar_lip_fringe", -280.9, -271.6, 791.05, 799.9, 1.25, 1.6)

    # ============================================================ 9.1 Hielo Azul
    # The west wall (skin, line 53, every inside page): blue-black ice glazed over rock, 106 m tall, the west wall
    # of the crack, the balcony, the chimney and the upper level, one piece made for its place, carried back to
    # the far wall; its closed corners (the foot under the corner ledge, the top over the shelf) the deepest blue.
    skin("glaciar_west_wall", -341.0, -331.0, 780.0, 886.0, z_back=WALL)
    # The crack's far wall: ONE painted piece in three big slanted planes, mid blue and dull, from the floor to
    # the roof (x -331 .. -305.5, 786 .. 809.5), bands as long wavy lines tilted ten degrees down to the east;
    # painted on it: the blue seam (0.5 m wide, pale, frosted: (-307.2, 787.4) to (-327.6, 798.6), then up the
    # corner (-327.5, 798.5) to the shelf's underside at 802.6), the three layers of stones through the three
    # stones you hold (24 stones of paint, a9_areas._dirt_layers), two blue ribs (1.4 m: x -330.6 .. -328.7 from
    # the floor to 797.6; x -308.2 .. -306.3, 793.2 .. 802.4), the pale slot where the tunnel opens (x -309 ..
    # -305.5), the light down the gap (1.2 m, x -319 .. -317.6, 802.6 .. 809.5, the same width all the way, frost
    # on the shelf's broken edge), the scar at the shelf's height east of its end (x -319 .. -313, three stones
    # in it), the thin white frost line at 804 where the old lid met the wall (flush), and round the door a broad
    # block two steps paler than anywhere else ((-305.5, 804) .. (-312.6, 809.5)) with a white frost rim 0.3 m
    # round the doorway. Its closed corners the deepest blue.
    back("glaciar_crack_back_wall", -331.0, -305.5, 786.0, 809.5, WALL, WALL_FAR)
    # The twelve knuckles (skins, line 127): plain blocks of the seam's pale blue, frosted and matte, white frost
    # along the top edge, square ends, each the near end of a block of the seam; the three stones (line 125)
    # grey-brown and dry, no frost.
    for x, y, k, rot in H91:
        if k == "rock":
            nub(x, y, 0.24, stone=True)
        else:
            turned("glaciar_knuckle", x, y, 0.66, 0.34, 0.6, rot=rot)
    # The corner ledge (skin, line 128): firm snow on the seam where it turns upward, carried back.
    skin("glaciar_corner_snow", -331.0, -327.5, 797.9, R1, tone=SNOW, z_back=WALL)
    # The pug arrow sign on its post at the back of the corner ledge, pointing east along the row (note 85): the
    # kit's sign_pug_arrow_east.
    A.deco("sign_pug_arrow_east", -330.3, R1, z=-1.5, size=(1.24, 1.66, 0.16), tone=ACCENT)
    # The first arrow sign, at the foot of the seam, 1.7 m inside the tunnel's mouth, pointing up the seam to the
    # west (on screen the moment you step out of the tunnel).
    arrow(-307.2, 789.9, 151.0)
    # The shelf's other half: two blocks of ice on the floor under its broken end, behind where you walk (made as
    # one piece: (-317.7 .. -314.6, to 787.9) and (-314.2 .. -312.4, to 786.9)), frosted on their broken faces.
    # One who fell: deep in the far wall, head down, under the middle bridge, 5 m from any hold.
    deep(-312.5, 798.6, 160.0)

    # ============================================================ 9.2 Carambanos
    # The shelf (skin, line 138): a plate of hard ice 12 m long and 1.4 m thick out of the west wall, dark and
    # glossy, carried back to the far wall; its east end broken off short, a rough broken face frosted white (the
    # one real break here, 1.4 m tall); along its underside the pale seam from collar to collar (paint), and five
    # dark wet cracks 0.8 m long that the falling icicles grow from (paint, flush: under x -326.2, -324.8, -322.0,
    # -320.65, and the one over the corner ledge, -329.4), each wet dark and never a slot.
    skin("glaciar_shelf", -331.0, -319.0, SH_Y, 803.5, z_back=WALL)
    # The shelf's top (skin, line 139): firm snow with boot prints going east, a ring of splinters under the roof's
    # one falling icicle (x -324.5).
    skin("glaciar_shelf_snow", -331.0, -319.0, 803.5, R2, tone=SNOW, z_back=WALL)
    # The five that hold (skins, line 143): thick, ringed like a stack of cups, pale blue and matte, a white frost
    # collar where each joins the shelf; drawn to a sharp point (the solid ends blunt: note 90).
    for (x, tip), stem in zip(ICI, ICI_STEM):
        hanging(stem, [(x - 0.3, SH_Y + 0.05), (x + 0.3, SH_Y + 0.05), (x, tip)], 0.6)
    # The stone tooth (skin, line 144): a grey-brown stone point, dry, drawn sharp; and the stone on the shelf's
    # nose (line 145), the last hold of this leg.
    hanging("glaciar_stone_tooth", [(-323.0, SH_Y + 0.05), (-322.4, SH_Y + 0.05), (-322.7, 800.3)], 0.6, tone=STONE)
    nub(-318.85, 803.1, 0.22, stone=True)
    # The second and third arrow signs: under the row of big icicles, 4.3 m east of the corner ledge at chest
    # height, pointing east; and right under the shelf's broken end, pointing straight up through the lit gap.
    arrow(-323.2, 799.0, 0.0)
    arrow(-318.4, 801.0, 90.0)

    # ============================================================ 9.3 Puente de Nieve
    # The nine bridge pieces (skins, line 166): snow lid, thinner than firm snow, cracked across with a corner
    # gone (the mountain's breakable look), open air under each; each runs back to the far wall.
    for x0, y0 in BRIDGES:
        skin("glaciar_snow_bridge", x0, x0 + 1.06, y0, y0 + 0.45, tone=SNOW, z_back=WALL)
    # The two wedged stones (skins, lines 170, 172): grey-brown and dry, each wedged from the far wall to the near.
    skin("glaciar_wedged_stone_a", -314.5, -313.3, 802.9, R2, tone=STONE, z_back=WALL)
    skin("glaciar_wedged_stone_b", -310.0, -308.8, 802.8, R2, tone=STONE, z_back=WALL)
    # The crack's roof and the door's lintel (skin, lines 65 and 66): dark, glossy and unbroken from wall to
    # wall, carried back to the far wall; one dark wet crack in it (paint, x -324.9 .. -324.1) for its one
    # falling icicle; the lintel's edges frosted white (the door's frost rim).
    skin("glaciar_crack_roof", -331.0, -303.0, 808.5, 811.4, z_back=WALL)
    # The lantern inside the door, on the cave's side, beside the first of the ones who tried, lighting him.
    lantern_hook(-301.3, 807.7)

    # ============================================================ 9.4 La Cueva de Hielo
    # The cave's back wall: ONE painted piece, banded ice deeper blue than the crack's (x -305.5 .. -284.5, 804 ..
    # 834.7: the cave, the door's passage, the whole flight), never stopping inside the frame; painted on it: the
    # door seen from inside, pale with frost round it (x -305.5 .. -303, 804 .. 808.5); a paler patch above the two
    # at the door where the balcony begins ((-303.6, 811.3) .. (-299.8, 815.2)); two blue ribs as tall as the cave
    # (x -299.6 .. -295.4 and -293.6 .. -291.3, leaning, from the floor to the roof); one dark wet crack in the
    # roof's line at x -293 for its one icicle; darker toward the east wall, paler toward the window. Its east end
    # turns forward to z -1.25 along the cave's east wall (x -284.5), so no slot shows at the corner.
    back("glaciar_cave_back_wall", -305.5, -284.5, R2, 834.7, WALL, WALL_FAR)
    # The cave's floor (skin, line 63): firm snow from the door to the east wall, carried back; painted on it:
    # two lines of boot prints (the door to the first climber; each landing dent back west to him), a third very
    # small with webbed toes from the frog's hole to the nearer dent and back, two shallow body-sized dents half
    # snowed over ((-296.9 .. -295.5) and (-291.5 .. -290.1)), blue hollows, and a ring of splinters under the cave's
    # icicle (x -293).
    skin("glaciar_floor_cave", -305.5, -284.5, 803.4, R2, tone=SNOW, z_back=WALL)
    # The balcony (skin, line 67): 28 m of firm snow, boot prints going west, blue hollows, a pocked patch under the
    # pit's slot (x -321.4 .. -318.8), carried back.
    skin("glaciar_balcony_snow", -331.0, -303.0, 811.4, BALCONY, tone=SNOW, z_back=WALL)
    # The back wall of the balcony and the chimney: ONE painted piece, banded ice (x -331 .. -303 from the balcony's
    # roof down to 811.4; above 817 only the chimney, x -331 .. -327.5, to 832): the chimney's far wall fluted in
    # upright grooves (paint, three at x -330.55, -329.3, -328.05), paler in its upper half where the ice is thin.
    back("glaciar_balcony_back_wall", -331.0, -303.0, 811.4, R4, WALL, WALL_FAR)
    # The ice at the six climbers' backs (note 87): each frozen to its front and standing whole out of it.
    for x, y in C94:
        climber_back(x, y)
    # The chimney's four knuckles (skins, lines 189-195) and its stone (193).
    for x, y, rot in K94:
        turned("glaciar_knuckle_short", x, y, 0.6, 0.34, 0.6, rot=rot)
    nub(-328.8, 823.9, 0.23, stone=True)
    # The chimney's lantern, beside the first climber at its foot.
    lantern_hook(-328.6, 814.6)
    # The heap under the pit's slot: old broken ice against the far wall (4 m wide, 1.9 m tall).
    back("glaciar_ice_heap", -322.2, -318.2, BALCONY, 813.9, -1.3, -2.38)
    # One lying in the wall, half way along the balcony.
    deep(-312.0, 814.6, 80.0)
    # The tally marks scratched in the chimney's far wall at its foot (the kit's tally_marks_ice, on the wall).
    A.deco("tally_marks_ice", -330.5, 813.1, z=ON_WALL, size=(0.8, 0.5, 0.03), tone="#D8F0FA")
    # On the cave's floor, behind where you walk: a block of ice 2 m across off the roof, against the far wall (the
    # kit's ice_block), and a frozen glove beside it 1.3 m back (the kit's glove_frozen).
    A.deco("ice_block", -298.9, R2, z=-2.3, size=(2.0, 2.0, 2.0), tone=PALE)
    A.deco("glove_frozen", -300.3, R2, z=-1.45, size=(0.34, 0.21, 0.18), tone=ACCENT)

    # ============================================================ 9.0 The frog's snow hole
    # The snow bank against the east wall and the round hole dug in it (3 m wide, 2 m high, a smooth domed roof, a
    # step of packed snow at its mouth), cut away at the front, its mouth at the play space's back edge.
    back("glaciar_snow_hole", -289.8, -284.5, R2, 806.7, BACK, -3.6, tone=SNOW)
    # In the hole: the frog wrapped in its striped blanket (the kit's frog_blanket) on a folded bedroll (the kit's
    # camp_bedroll at 0.68: 1 m), a kettle steaming on a tiny stove (the cliffs' tea things: tea_brazier and
    # tea_kettle), a candle lantern hanging from an ice axe driven up into the roof (ice_axe turned head down,
    # lantern_hang on its head; light: item 2), and a short string of the town's paper pinned along the back
    # (glaciar_paper_tatters at 0.5: 1.5 m, its cord's ends at 0.485 above its origin).
    A.deco("camp_bedroll", -286.9, R2, z=-2.7, scale=0.68, size=(1.46, 0.42, 0.42), tone=ACCENT)
    A.deco("frog_blanket", -286.55, round(R2 + 0.17, 2), z=-2.65, size=(0.34, 0.26, 0.33), tone=ACCENT)
    A.deco("tea_brazier", -287.8, R2, z=-2.25, size=(0.4, 0.35, 0.4), tone=IRON)
    A.deco("tea_kettle", -287.8, round(R2 + 0.35, 2), z=-2.25, size=(0.31, 0.27, 0.24), tone=IRON)
    A.deco("ice_axe", -286.0, 806.32, z=-2.0, rot=180.0, size=(0.25, 0.7, 0.08), tone=IRON)       # origin its spike, in the roof
    A.deco("lantern_hang", -286.0, 805.62, z=-2.0, size=(0.28, 0.52, 0.31), tone="gold")         # origin its hook, on the axe's head
    A.deco("glaciar_paper_tatters", -287.0, 805.42, z=-3.4, scale=0.5, size=(3.0, 0.97, 0.03), tone=ACCENT)
    # One in the wall, 8 m up, leaning, level with the end of the rope (also 9.6).
    deep(-296.0, 812.5, -20.0)

    # ============================================================ 9.5 El Serac
    # The upper level's far wall: ONE painted piece (x -331 .. -300, 817 .. 842; its outline leaves out the
    # chimney, x -331 .. -327.5 below 832, which is the balcony's piece; east of x -305.5 it is only the wedge
    # under the sloped roof, above the cave's back wall (834.7) up to the roof's slant (-311, 842) .. (-300, 834.7),
    # so nothing shows through there; its top follows the roof: 842 to x -311, down to 834.7 at -300), banded ice 2.4 m back from the pit's floor to the roof; painted on it: the white crack beside the
    # tower's twin, two slabs of bluer ice leaning east in the pit's far wall ((-321.2 .. -317.7, 825.3 .. 842) and
    # (-316.6 .. -314.0, 827 .. 842)), behind the pillar a broad block two steps paler (the window's daylight coming
    # back along the roof), the water's two long grooves beside the slide (flush, following its curve down the face
    # and round into the bowl, 0.9 and 1.8 m off it).
    back("glaciar_upper_back_wall", -331.0, -300.0, 817.0, 842.0, WALL, WALL_FAR)
    # The ice over the upper level, the cave and the chute (skin, line 87, also 9.6 and 9.8): the glacier's body,
    # one piece made for its place: the upper level's roof and the cave's (dark, glossy, unbroken from wall to wall),
    # the R7 niche's west wall, the chute's floor (polished, glazed, its blue seam of plates showing through as
    # paint), the ice wall at the top of the chute (x -302.5); undersides carried back to the far wall.
    xs, ys = (-331.0, -278.8), (834.7, 884.6)
    skin("glaciar_upper_mass", xs[0], xs[1], ys[0], ys[1], z_back=WALL)
    # The block under the brink (skin, line 70): the chimney's east wall, and on its front under the tower's foot the
    # ice's bands painted bent upward into a hump with a white crack along the foot itself (the push that raises the
    # next one: x -326.9 .. -322.9, 827.9 .. 831.6).
    skin("glaciar_serac_block", -327.5, -322.8, 817.0, 831.5)
    # The brink (skin, line 71): firm snow, carried back to the far wall where the axe and the coil stand.
    skin("glaciar_brink_snow", -327.5, -322.8, 831.5, R4, tone=SNOW, z_back=WALL)
    # The pit's west funnel (skin, line 72).
    skin("glaciar_pit_funnel", -322.8, -321.4, 817.0, 825.5)
    # The tower's twin, still standing in the far wall, real shape 0.8 m proud (1.9 m wide, 10 m tall).
    back("glaciar_serac_twin", -325.6, -323.3, R4, 842.0, -1.6, WALL, tone="#7FB4D8")
    # Old towers in pieces, jammed in the back of the pit's funnel, snow still on some (behind the slot: a body still
    # falls through).
    back("glaciar_pit_jam", -322.4, -318.5, 824.3, 827.0, -1.4, -3.0, tone=ICE)
    # What the party in the chimney left at the back of the brink's snow (0.8 m back from today): an ice axe stuck in
    # upright, leaning east, and a coil of rope frozen flat (the kit's).
    A.deco("ice_axe", -327.0, R4, z=-1.5, rot=-19.7, size=(0.25, 0.7, 0.08), tone=IRON)
    A.deco("rope_coil_frozen", -326.2, R4, z=-1.6, size=(0.65, 0.26, 0.58), tone=WOOD)
    # The pillar (skin, line 81, also 9.6): firm snow with old boot prints, all pointing east.
    skin("glaciar_pillar_snow", -312.96, -310.46, 834.1, T_TOP, tone=SNOW, z_back=WALL)

    # ============================================================ 9.6 Tobogan Helado
    # The slide (skin, line 80): the glacier's old drain, the slickest thing on the mountain, polished by years of
    # melt water: the sheer face, the bend, the bowl and the crack's west edge; carried back to the far wall.
    tx0, tx1, ty0, ty1 = _box(TOBOGAN)
    skin("glaciar_tobogan", tx0, tx1, ty0, ty1, z_back=WALL)
    # The kicker (skin, line 260): a flake of the glacier's dark ice wedged in the crack's mouth, glossy and slick,
    # a white chipped edge along its lip.
    fx0, fx1, fy0, fy1 = _box(FLAKE)
    skin("glaciar_kicker", fx0, fx1, fy0, fy1)
    # The window's sill (skin, line 265): firm snow, boot prints going out through the window, carried back.
    skin("glaciar_window_sill", -286.6, -281.0, 829.4, SILL, tone=SNOW, z_back=WALL)
    # The window, seen edge-on (item 7d): its reveal behind the gap between the sill and the brow, the ice of its
    # jambs and lintel receding, pale with white daylight, a white frost rim 0.3 m round its outline.
    back("glaciar_window", -285.5, -281.0, SILL, 834.7, BACK, WALL, tone="#DCEFF8")
    # The town's torn paper along the window's top, 0.6 m back from today (3 m; its cord at 834.3), blowing out.
    A.deco("glaciar_paper_tatters", -283.0, 833.33, z=-1.5, size=(3.0, 0.97, 0.03), tone=ACCENT)
    # The lit lantern on the window's outer side, on the flank under the brow (the kit's lantern_hang, origin its
    # hook, its spike in the flank's face; light: item 2).
    A.deco("lantern_hang", -280.4, 834.0, z=-1.4, size=(0.28, 0.52, 0.31), tone="gold")
    # The rope's anchor at the back of the sill: an ice axe driven in to its head, and two turns of spare rope
    # frozen flat (the kit's).
    A.deco("ice_axe", -285.9, SILL, z=-1.5, rot=-20.6, size=(0.25, 0.7, 0.08), tone=IRON)
    A.deco("rope_coil_frozen", -285.1, SILL, z=-1.6, size=(0.65, 0.26, 0.58), tone=WOOD)
    # The second one in the wall under the flight, arms out, 2 m west of today (away from the rope's line).
    deep(-290.6, 818.4, 35.0)

    # ============================================================ 9.7 Ventisca
    # The brow and the wall (skin, line 90): the skin jutting over the window like an eyebrow, a painted shadow
    # under its nose (a real break), its underside frosted (the window's rim), the wall above dark and smooth.
    skin("glaciar_brow", -285.5, -279.5, 834.5, 845.7)
    # The flank of the tongue: the glacier's own side 1.5 to 3 m behind the climb, three big slanted planes of dark
    # ice, bands as thin lines, an uneven east edge reaching 2 to 3 m past the wall (to x -278.8); one of its bands
    # carries stones at the height of the one stone you hold (paint: (-281.3, 840.63), (-280.5, 840.49)); two small
    # sloping snow shelves cut into it (838.3, x -281.5 .. -280.0; 843.2, x -281.3 .. -280.0), each running back from
    # its face to z -2.1 where a cane stands; and the R7 niche's back (x -285.5 .. -282.5, 846 .. 850) set back to the
    # far wall's -2.4.
    back("glaciar_tongue_flank", -285.5, -278.8, 834.7, 850.2, FLANK, FLANK_FAR, tone=FLANKC)
    # Three canes with paper flags, the wind's flags (note 89): one on each shelf, one at the back of the niche.
    cane(-280.9, 838.3, -1.8)
    cane(-280.6, 843.2, -1.8)
    cane(-285.0, R7, -1.8)
    # The niche under the chute's mouth (skin, line 109): snow carried back to the niche's back.
    skin("glaciar_niche_snow", -285.5, -282.5, 845.6, R7, tone=SNOW, z_back=WALL)
    # The tusk under the brow (skin, line 274): a stout hanging point of blue ice, frosted, no rings, no collar.
    hanging("glaciar_tusk", [(-280.9, 834.68), (-280.3, 834.6), (-280.6, 831.6)], 0.6)
    # The three plates on the brow (skins, line 280) and the six holds up the wall (278): five nubs, one stone.
    for x, y in PLATES97:
        plate((x + 0.3, y - 0.285), (x - 0.3, y + 0.125), 0.2)
    for i, (x, y) in enumerate(H97):
        nub(x, y, 0.24, stone=(i == 2))
    # Foreground: the snow fringe on the brow, 0.4 m below today's, in front of the brow's own ice and no hold
    # (made in place: (-282.45, 836.7) .. (-279.6, 834.55), 0.4 wide).
    front("glaciar_brow_fringe", -282.45, -279.6, 834.55, 836.7, 1.25, 1.45)

    # ============================================================ 9.8 La Avalancha
    # The back of the roofed chute: banded ice, dark (the tower's foot is over it), so the pale plates show; a
    # scatter of smaller stones in it behind the two long ones (paint: (-282.0, 856.2), (-283.3, 857.6), (-284.4,
    # 860.0), (-285.5, 860.7)) (made to its place: (-278.8, 850.5), (-288.0, 861.46), (-286.5, 866.95), (-280, 859.2)).
    back("glaciar_chute_back", -288.0, -278.8, 850.2, 866.95, WALL, FLANK_FAR, tone=FLANKC)
    # The two long stones (skins, lines 304, 305, one for each island): the two biggest stones the glacier carries,
    # frozen into the drain's floor, grey-brown and dry, glazed over their backs with clear dark ice (glossy) and
    # bare only on the lee face and under the little roof of their downhill ends: the two rests.
    for s0 in (3.6, 8.4):
        ix0, ix1, iy0, iy1 = _box(_island(s0))
        skin("glaciar_long_stone", ix0, ix1, iy0, iy1, tone=STONE)
    # The tusk under the chute's mouth (skin, line 321), the three nubs round the nose (330), the eight plates up the
    # floor (333), the stone horn the old rope is tied to (337).
    hanging("glaciar_tusk_short", [(-282.35, 850.1), (-281.85, 850.12), (-282.1, 847.7)], 0.5, made_h=2.4)
    for x, y in NUBS98:
        nub(x, y, 0.22)
    for s0, sv in PLATES98:
        plate(P(sv - 0.36, _gz(s0, sv - 0.36)), P(sv + 0.36, _gz(s0, sv + 0.36)), 0.22)
    nub(-286.62, 867.0, 0.2, stone=True)
    # The niche in the stem (skin, line 107), its back (3 x 4, banded ice, dark), its cane with a slack flag, and
    # what whoever left the rope left there: a coil of the same hemp frozen flat and an ice axe (the kit's).
    skin("glaciar_niche_snow", -286.5, -283.5, 867.4, R8, tone=SNOW, z_back=WALL)
    back("glaciar_niche_back", -286.5, -283.5, R8, 871.8, WALL, FLANK_FAR, tone=FLANKC)
    cane(-284.3, R8, -1.8)
    A.deco("rope_coil_frozen", -285.4, R8, z=-1.55, size=(0.65, 0.26, 0.58), tone=WOOD)
    A.deco("ice_axe", -285.95, R8, z=-1.5, rot=-18.4, size=(0.25, 0.7, 0.08), tone=IRON)
    # The hollow the slabs are thrown into (note 91): 4 m wide and 3 m back in the ridge's slate beside the rope's
    # foot, where a slab of the slate has fallen out; a heap of broken snow in its floor, its back white with burst
    # snow (made to its place: (-292.6, 865.6), (-292.2, 868.2), (-290.6, 869.3), (-288.6, 868.6), (-287.6, 866.6),
    # (-288.2, 864.3), (-290.4, 864.2)). Item 4: the gap's card must be cut round it.
    back("glaciar_slab_hollow", -292.6, -287.6, 864.2, 869.3, WALL, -5.4, tone="#56636F")
    # The slab hole (note 93), at the game's drawn mouth (item 8): a dark mouth in the ice behind the top of the
    # chute, under the ridge's ledge, with a lip of packed snow; the hole 3.8 x 2.2 (the game's: a slab 3 m long
    # comes out of it toward you), 2 m deep and dark inside; its face at z -1.25, set in a piece of the glacier's
    # body 4.6 x 3.0 that rests against the ice wall at x -302.5. It moves with the spawner (item 6b).
    back("glaciar_slab_mouth", -303.5, -298.9, 879.05, 882.05, BACK, -3.45, tone=ICE)

    # ============================================================ 9.9 Cornisa de Hielo
    # The tower (skin, line 105): the glacier's top, a mushroom of dark ice, a stem on the east and the cornice
    # curling west over the gap; its flat roof underside dark and unbroken but for five pale bands of the healed
    # seams painted up its front from the roof to 873.0 / 875.4 (x -288.5, -290.2, -291.9, -293.6, -295.2, each 0.5
    # wide: you count the holds by the bands); its sloping top with snow; its body carried back to the far wall's
    # -2.4 (the last cane stands on its top at -1.6), but for the two niches, open to their backs.
    tx0, tx1, ty0, ty1 = _box(TOWER)
    skin("glaciar_tower", tx0, tx1, ty0, ty1, z_back=WALL)
    # The tusk at the stem niche's mouth (skin, line 354) and the six nubs (358).
    hanging("glaciar_tusk_short", [(-287.15, ROOF_Y + 0.05), (-286.65, ROOF_Y + 0.05), (-286.9, 869.5)], 0.5, made_h=2.4)
    for x, y in NUBS99:
        nub(x, y, 0.25)
    # The niche under the tip (skin, line 108), its back (2.7 x 4), and its cane (the one you crossed the cornice
    # to), its flag streaming west.
    skin("glaciar_niche_snow_short", -295.9, -293.2, 872.9, R9, tone=SNOW, z_back=WALL)
    back("glaciar_niche_back_short", -295.9, -293.2, R9, 877.3, WALL, FLANK_FAR, tone=FLANKC)
    cane(-293.6, R9, -1.8, east=False)
    # Foreground: the snow on the tower's top, cut back to end 4 m short of the tip and in front of the tower's own
    # ice only (notes 87, 92): the fringe along the top's edge (made in place: (-291.5, 877.7 .. 878.2) to
    # (-280.3, 870.2 .. 870.73), 0.25 deep), and the kit's snow cornice hanging in front of the ice face under the
    # top edge, its top at the edge (x -290 .. -285), moved from 0.8 into the play space to wholly in front of it.
    front("glaciar_tower_fringe", -291.5, -280.3, 870.2, 878.2, 1.25, 1.5)
    a = math.radians(-33.7)
    xt = -287.5
    A.deco("snow_cornice", round(xt + 2.0 * math.sin(a), 3), round(_tower_top(xt) - 2.0 * math.cos(a), 3), z=3.05, rot=-33.7,
           size=(6.0, 2.0, 3.0), tone=SNOW)

    # ============================================================ 9.10 El Rimaye
    # The tusk at the second niche's mouth (skin, line 375) and the two nubs above it (376, 377): the last blue ice.
    hanging("glaciar_tusk_short", [(-296.0, 877.35), (-295.5, 877.35), (-295.75, 874.95)], 0.5, made_h=2.4)
    for x, y in NUBS910:
        nub(x, y, 0.23)
    # The horn at the last climber's back (note 87): a horn of the cornice, dull mid blue, leaning out over the gap at
    # the angle he leans (45 degrees), from the play space's back edge to the far wall (1.5 x 2.2 x 1.15).
    turned("glaciar_climber_horn", -296.2, 881.5, 1.5, 2.2, 1.15, rot=45.0, tone="#6E93B6", z=round((BACK + WALL) / 2, 3), is_skin=False)
    # The last cane of the route on the tower's top behind him, its flag streaming west, and a lit candle lantern
    # hung on it at head height (the kit's lantern_hang, its spike in the cane; light: item 2).
    cane(-294.3, round(_tower_top(-294.3), 2), -1.6, east=False)
    A.deco("lantern_hang", -294.3, 882.17, z=-1.43, size=(0.28, 0.52, 0.31), tone="gold")
    # The glazed nose of the ledge (skin, line 97): a lump of clear ice over the ridge's rock, dark and glossy with
    # a white glint: the last of the glacier's ice.
    skin("glaciar_verglas_nose", -302.9, -301.75, 884.6, 886.75)
