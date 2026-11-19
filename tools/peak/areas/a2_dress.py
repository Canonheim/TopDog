"""
LAS AGUAS NEGRAS, DRESSED: the scenery of all of biome 2, the flooded works (y 86 to 176), from
the thirteen area pages and the join "2 to 3" in docs/peak/playtest/design/data/a2_areas.py and
the biome's sheet a2_biome.py (its `built`, `looks`, `layers` and `kit`, with its walls lines).
The join "1 to 2" is biome 1's: a1_dress.py placed the mine's last timber set in the dry
shaft, the works' first arch on its cap, the coping and brick courses drawn on the lip ledge's
face and the brick-and-timber post in front of the pier, and left the rest of the lip to this
file: the works' brick wall in bays (`aguas_borde_back_wall`), the weir's sill
(`aguas_weir_coping`, `aguas_weir_lip_back`), the works' greenish lantern over the ledge and
the pier (`aguas_borde_pier`). They are placed in "2.1 El Borde" below, behind and round a1's
pieces (its lining in the dry shaft is at z -1.95 .. -1.65; this file's wall is behind it at
-2.6, and the main's scenery run goes down behind that lining).

Scenery only: decos. Nothing here can be stood on or held. The course (the main, the chain,
the wheel, the pier tops, the rings, the filler pipe, the rams, the chains, the barrels, the
grating, the hot and cool joints, the cold runs, the treads, the rope, the catwalk, the lifts,
the rungs) is a2.py's. The water, its falls, spray, mist, drips and steam are the game's own
drawing (the water overhaul, note 22) and nothing is placed for them. The model list this
file makes is docs/peak/models/a2_models.md.

Depth: the play space is z -1.2 .. 1.2. Everything here stands behind -1.25 or in front of
1.25, except two kinds of thing, each said where it is placed:
  - SKINS (skin=True): the painted brick and rock masses, the pier, the four trough stumps,
    the brick bodies of the hanging landings, and the new solids the pages ask for (the weir's
    coping, the pool's sill, the dam's shaft wall); each is the LOOK of a course solid
    (MODELLING_RUN rule 4) and fills it, z -1.2 .. 1.2;
  - things DRAWN ON a solid's front face (z 1.2: the main's flanges, the spout, the cold runs'
    straps, the crest's cracks, the crust on the top rungs, the cast pug on the dam), thin.
From the back, the works stand at: the far wall z -10; the throat of the well -8 .. -2; the
dam hall's back wall -7 .. -6; the pool hall's flanks -6.5 .. -5.5; the boiler house's back
wall -6 .. -5.2; the lake's vault -5 .. -4; the wash house's back wall -5 .. -4.4; the chain
chamber's back wall -4.2 .. -3.6; the weir hall's -3.6 .. -2.6; the tunnel's -3.2 .. -2.6;
the gate hall's -3 .. -2.4; the boiler house's piers' faces, the flume's and the catwalk's
back walls -2.2; the mill's back wall -1.95 with its arcade piers standing proud to -1.3. A
works lantern hangs 0.5 m out from its wall on a cast arm. Scenery pipes lie on the walls.

Walls and masses (BRIEF.md "Walls and masses"; the sheet's `built`): every wall, pier and mass
is ONE painted piece made for its place. Brick and dressed stone are painted, not built of
blocks: a few large planes, the courses long slightly wavy lines of flat colour in three or
four slate tones, water stains level bands where the black water has stood, green growth a
band along the waterline, nothing that narrows to a point. The real breaks are few: an arch's
ring standing proud, a hole where a handful of bricks have gone, a coping that overhangs with
its shadow painted under it, a buttress with a corner gone; the outline leans and is notched
away from the holds and tops. An arch that the pages open (a culvert, the wheel's arch, the
barred windows) is open and has something behind it; no dark recess is cut into a face. The
works' walls carry a few small outcrops of loose brick, each with one of the biome's flat
painted plants (`aguas_fern_wet`, `aguas_weed_tuft`), near the water and the spray.

A deco's origin is the middle of its base (x and z) at its foot (y), unless its comment says
otherwise. For the long pieces (walls, masses, pipes laid on walls) that means: the middle of
its x span, the bottom of its box, the middle of its depth. A deco's size is the size its model
is MADE at (the game rescales a landed model more than a quarter off); where an existing kit
model is used at another size, `scale` does it and the size is the kit's own.

Shared pieces are placed once, in the first section that names them, and the other page is
named in a comment (the mill's back wall for 2.2 and 2.3, the frog's door for 2.7 and 2.0, the
head of the lift shaft for 2.11 and the join...).

FOR THE AREA FILE (tools/peak/areas/a2.py; the fix thread's). Line numbers are a2.py's as of
2026-11-14 01:05 (with note 25's lift and note 52's pits in); each item names what it means.
  1. Call it: `import a2_dress` beside the other imports, and `a2_dress.dress(A)` after the
     course is built (before A.save()).
  2. Lanterns (note 17: nothing in this biome's light pulses): lamp() (line 48) stops placing
     `lantern_hang` (this file places every lantern, on the walls, out of the play space), and
     the lamp loop (lines 375-380) becomes one steady light per entry of
     `a2_dress.LANTERN_LIGHTS` (x, y, z of each flame's light, 0.2 in front of it: 11-19), TEAL, range 10, energy 1.5,
     flicker False. The well's daylight (line 381) stays. The join asks for two more lights,
     steady: a soft violet one down the exit shaft at (-452.5, 175.0) and a white one at the
     bright crystal over the crest, (-442.0, 172.6).
  3. Decos to take out, because this file now places them out of the play space, or the page
     removes them:
     - line 112: the twelve `hanger_chain` on the aqueduct's rings (note 18: the chains go);
     - lines 215-217: the cove's `brick_arch` (z -1.35, it reached z -1.0) and its dark card
       (`aguas_barrel_cove` takes their place);
     - line 231: the three `flume_pillar` (z -1.3: they stood in the play space; placed here
       at z -1.8, on the bed). The eddies' water stays;
     - lines 252-254: the `pipe_verdigris` between the Tuberia's joints (z -0.5: Parker 11-13,
       a pipe in the play space can be held; the lagged steam pipe is placed here at z -1.95);
     - line 360: `water_wheel_frame` (z -1.0; placed here at z -1.7);
     - line 361: the `iron_bracket` under the landing (z -0.6; the three beam ends replace it);
     - line 371: the `pug_stamp` in the dam (z -0.9; placed here on the dam's face);
     - line 373: the `boiler` (its front was at z -0.7; `aguas_boiler_end` replaces it);
     - line 374: the `papel_tatters` over the gallery (z -1.0; the biome's one string of
       bunting is the boiler house's, placed here).
     Keep line 372, the `valve_wheel` on the first cool joint (the hold's look), and add the
     same on the last cool joint, (-377.6, 136.6), z -0.4 (2.9: "valve wheels ... on the first
     joint and the last").
  4. Cards to take out: line 353 (the far wall at z -6 stood in front of the dam hall's back
     wall and the well's throat; `aguas_far_wall` at z -10 replaces it), lines 354-355 (the
     tunnel's brick strips; `aguas_borde_back_wall`), lines 356-359 (the aqueduct's pier cards
     and their `brick_arch` decos at z -1.2; `aguas_mill_back_wall` with its arcade, and the
     four trough stumps), lines 362-363 (El Desague's card at z -1.5 hid the whole chain
     chamber; its back wall, the hopper's back half and the pipe's mouth replace it), lines
     365-367 (the well's dark slot and dot; `aguas_throat` and `aguas_well_back`), lines
     368-369 (the pool hall's `brick_arch` decos; the two flanks), line 370 (the dam's flank
     card at z -1.0; the dam's skin).
  5. Skins. build_rock() cuts the rock by `SKIN_REGIONS`, in order (a part already taken by an
     earlier region is not taken again), splits each part as it does today, and gives every
     slab of a part `skin=` that region's stem; the regions cover the whole shell, so every
     slab gets one. Also: the pier's peaked top (line 62) takes "aguas_borde_pier"; the four
     aqueduct crowns (line 104), west to east, "aguas_trough_stump_1" .. "_4"; the brick slabs'
     wet bodies (slab(), line 44): the landing P1 (line 83) "aguas_borde_landing", Q6 (line
     177) "aguas_charco_landing_east", Q7 (line 178) "aguas_charco_landing_west", Q8 (line
     224) "aguas_flume_landing", Q10 (line 260) "aguas_cascada_landing"; the shaft's east wall
     (line 328, A.box(... "wet")) "aguas_shaft_wall"; and the new solids of item 6 (b, c).
     This file places each of those skin decos. The iron slabs' bodies
     (the grating Q9, the catwalk's four plates) keep today's look. The join's shaft rim
     (`aguas_shaft_rim`, placed here) is the look of a3.py's kerb (a3.py line 163,
     A.box(-448.7, 176.3, 0.5, 0.6, "crystal")): that solid's skin is a3.py's to give.
     The seam with a1: a2's shell (y 86 .. 90) overlaps a1's roof slab (x -248 .. -230, y 86 ..
     90) under the bed's east end, the pier and the lip ledge; there the two areas' skins meet.
  6. Course changes on the pages, for the fix thread (not scenery):
     a. Copings (every page: "a pale stone coping, like every place you stand in the works"):
        the caps Q1 (line 93), Q2, Q3 (126-127), Q4, Q5 (158-159) and the ledges of the brick
        slabs P1, Q6, Q7, Q8, Q10 change kind "brick" -> "stone". The lip ledge, the apron
        and the crest are stone already.
     b. 2.1: the weir's lip: a stone solid x -244.45 .. -244.0, y 90.7 .. 91.0 (the pale coping
        the river goes over at the slot), skin "aguas_weir_coping". RULED 11-14: NOT BUILT (a hold at the lip of a fall stops the fall). If it upsets the swim,
        leave it out and take its deco out of this file with it.
     c. 2.7: the pool's lip: a stone sill x -288.25 .. -287.85, y 113.0 .. 115.0 (its top is
        the worn sill a barrel tips on), skin "aguas_pool_sill". RULED 11-14: NOT BUILT, as 6b; the same proviso (the
        barrels' `loose` point is -287.15, east of it).
     d. 2.0, the frog's room (Parker 11-13: settled): cut the room as air in brick that is
        solid today, x -284 .. -281, y 117.4 .. 120 with a round vault (the page's
        arch(-284, -281, 117.4, 118.5)), and give it a floor that holds level with the ledge:
        a "stone" cap x -284.2 .. -281.0 at 117.4 (the ledge's coping running on as a worn
        sill). This file places the room's back, vault, door, valve, bucket, frog and lantern;
        the rock round the cut wears "aguas_cadenas_foot", made with the room cut in it.
     e. 2.3 (note 18): the chains go (item 3). No ring moves.
     f. 2.4: three drowned rungs under the two held ones, x -246.6 .. -246.3 at y 109.5,
        109.1 and 108.7, green and bent, under the water: rungs are the area file's (they
        stand in the play space); `rung_iron_rusted` at z 0, held or not as the fix thread
        rules.
     g. 2.5 (note 19): each rising gate becomes a piston: a fixed iron housing on its step
        where the block rests today (2.05 wide, black with oil, slick), and a ram as wide as
        the head that fills the space between the housing and the head as it rises. The
        movers' model becomes `aguas_ram_head`, the housings `aguas_ram_housing` (model list,
        section 4). The sluice gates behind are placed here; each gate's leaf rides with its
        ram (item 8).
     h. 2.10b (note 52): done (the line_pit calls, lines 428-430).
     i. 2.11 (note 25): done (lines 315-336). What is left is looks: the shaft wall's skin
        (item 5) and the cage's model, `aguas_winch_cage` for winch_lift "jaula" (line 335;
        section 4). The dam's skin "aguas_presa_dam" is made with the gallery (to 154.8) and
        the shaft cut in it; the shaft's back wall is placed here at z -1.5, with the rails
        and rack in front of it.
  7. Holds' and movers' looks (the area file's; models in a2_models.md, section 4): the six
     aqueduct rings each wear `aguas_ring_eyebolt` (the ring facing the camera on an eye bolt
     that runs straight back to the plate at z -1.25), its bolt's root on the pad this file
     places; the seven wet holds of 2.10 wear `aguas_tread_end` (the squared end of a stone
     tread; its root runs back into the wall here); the three Cadenas chains, the flume's
     chain and El Borde's chain each end at the top in `aguas_chain_shackle`; the eight
     barrels wear `aguas_barrel` (two hoops, the pug branded on its end) in place of
     `barrel_float`.
  8. Things that would move: the second water wheel (`aguas_mill_wheel_grey`, 4 m behind the
     wheel you ride on the same axle) turns with "rueda"; each gate's leaf (`aguas_gate_leaf`)
     rises and slams with its ram (compuerta1..3's cycle). Here they are still decos; give
     each a mover.
"""
import math

# ------------------------------------------------------------------ the lines things stand on
FACE = 1.2             # a course solid's front face: things drawn on it
RIV_B, RIV_S = 90.0, 91.0   # the lower river: bed, surface
T0C = 96.0             # the river tunnel's roof (the race's bed)
RB = 96.8              # the race's bed (the mill's lowest floor)
L1C = 107.4            # the mill's first ceiling
MB = 108.4             # the wash channel's bed
L2C = 115.6            # the wash house's roof
WINC = 128.6           # the gate hall's and the chain chamber's roof
CS = 115.0             # the pool under the well
FS = 116.0             # the flume and the tail pool
PS = 136.0             # the weir's pool
US = 151.0             # the upper reach

# Each place's back wall face (z). A wall piece's depth runs back from here.
TUNNEL_WALL = -2.6     # 2.1, the river tunnel
MILL_WALL = -1.95      # 2.2, 2.3: the wheel pit and the standing arcade
BRAZO_WALL = -4.4      # 2.4, the wash house
GATE_WALL = -2.4       # 2.5, the gate hall
CADENAS_WALL = -3.6    # 2.6, the catch chamber
GALLERY_WALL = -2.8    # the fitters' gallery (2.6, 2.0)
FLANK = -5.5           # 2.7, the pool hall's two flanks
FLUME_WALL = -2.2      # 2.8
BOILER_WALL = -5.2     # 2.9, the boiler house
PIER_FACE = -2.2       # 2.9, the three piers' faces (the lagged steam pipe on them)
WEIR_WALL = -2.6       # 2.10, the weir hall
REACH_WALL = -2.2      # 2.10b, the upper reach
DAM_WALL = -6.0        # 2.11, the dam hall
SHAFT_WALL = -1.5      # 2.11, the lift shaft's back wall (the rails in front of it)
VAULT_FACE = -4.0      # the join, the lake's vault

# The course's rock, cut into one painted piece per mass (FOR THE AREA FILE, item 5), in order:
# a part already taken by an earlier region is not taken again. Together they cover a2.py's
# whole shell. The pieces' own sizes (the rock inside each) are placed in dress() below.
SKIN_REGIONS = [
    ("aguas_borde_pier", [(-238.0, 83.0), (-236.0, 83.0), (-236.0, 92.3), (-238.0, 92.3)]),
    ("aguas_brazo_pier", [(-230.8, 107.35), (-227.8, 107.35), (-227.8, 110.05), (-230.8, 110.05)]),
    ("aguas_east_wall", [(-236.0, 83.0), (-223.0, 83.0), (-223.0, 115.6), (-232.6, 115.6), (-232.6, 96.9), (-229.0, 96.9),
                         (-229.0, 95.95), (-236.0, 95.95)]),
    ("aguas_race_bed", [(-255.4, 92.3), (-229.0, 92.3), (-229.0, 98.35), (-255.4, 98.35)]),
    ("aguas_mill_core", [(-258.2, 90.0), (-229.0, 90.0), (-229.0, 96.9), (-232.6, 96.9), (-232.6, 115.6), (-249.2, 115.6),
                         (-249.2, 121.2), (-258.2, 121.2)]),
    ("aguas_works_roof", [(-249.2, 115.6), (-223.0, 115.6), (-223.0, 176.0), (-259.5, 176.0), (-259.5, 121.2), (-249.2, 121.2)]),
    ("aguas_borde_bed", [(-284.0, 83.0), (-244.0, 83.0), (-244.0, 90.0), (-284.0, 90.0)]),
    ("aguas_cadenas_foot", [(-284.0, 90.0), (-258.2, 90.0), (-258.2, 121.0), (-284.0, 121.0)]),
    ("aguas_desague_mass", [(-294.0, 121.0), (-259.5, 121.0), (-259.5, 176.0), (-294.0, 176.0)]),
    ("aguas_charco_bed", [(-320.5, 83.0), (-284.0, 83.0), (-284.0, 113.0), (-320.5, 113.0)]),
    ("aguas_charco_roof", [(-320.5, 113.0), (-294.0, 113.0), (-294.0, 176.0), (-320.5, 176.0)]),
    ("aguas_tail_bed", [(-380.0, 83.0), (-320.5, 83.0), (-320.5, 114.5), (-380.0, 114.5)]),
    ("aguas_flume_roof", [(-346.0, 114.5), (-320.5, 114.5), (-320.5, 176.0), (-346.0, 176.0)]),
    ("aguas_tuberia_roof", [(-380.0, 114.5), (-346.0, 114.5), (-346.0, 176.0), (-380.0, 176.0)]),
    ("aguas_weir_pool_mass", [(-392.0, 83.0), (-380.0, 83.0), (-380.0, 134.5), (-392.0, 134.5)]),
    ("aguas_reach_bed", [(-425.5, 83.0), (-392.0, 83.0), (-392.0, 149.5), (-425.5, 149.5)]),
    ("aguas_reach_roof", [(-425.5, 149.5), (-380.0, 149.5), (-380.0, 176.0), (-425.5, 176.0)]),
    ("aguas_presa_dam", [(-449.0, 83.0), (-425.5, 83.0), (-425.5, 170.0), (-449.0, 170.0)]),
    ("aguas_presa_lake", [(-465.0, 83.0), (-449.0, 83.0), (-449.0, 173.0), (-465.0, 173.0)]),
    ("aguas_presa_roof", [(-465.0, 170.0), (-425.5, 170.0), (-425.5, 176.0), (-465.0, 176.0)]),
]

# Every works lantern's flame (x, y), for a2.py's lights (FOR THE AREA FILE, item 2). Filled by dress().
LANTERN_LIGHTS = []

# The aqueduct (2.3): the four pier tops (x west, x east, top) and the six rings, as a2.py has them.
_CROWN = [(-249.1, -246.1, 101.4), (-243.1, -240.1, 101.8), (-236.3, -233.6, 102.2), (-228.5, -226.0, 102.6)]
_RINGS = [(-245.75, 103.35), (-244.5, 103.7), (-239.75, 103.75), (-238.5, 104.1), (-233.25, 104.15), (-232.3, 104.5)]
# The gate hall (2.5): each gate's middle x, the floor of its step, its head's top when down.
_GATES = [(-250.28, 108.4, 111.8), (-252.4, 111.4, 114.8), (-254.52, 114.4, 117.8)]
# The flume's three pillars (2.8), as the page has them.
_PIL = (-324.6, -330.1, -335.6)
# The Tuberia (2.9): the three cold runs (x west, x east, y) and the three piers (x west, x east, top).
_RUNS = [(-359.0, -352.6, 124.6), (-369.0, -363.0, 130.1), (-377.3, -372.9, 135.4)]
_PIERS = [(-359.4, -352.2, 124.1), (-369.4, -362.6, 129.6), (-377.7, -372.5, 134.9)]
# La Cascada Chica (2.10): the seven wet holds (the treads' free ends).
_WET = [(-385.6, 139.4), (-386.7, 140.5), (-387.9, 141.5), (-388.8, 142.8), (-388.0, 150.0), (-389.2, 151.1), (-390.4, 152.2)]
# The catwalk (2.10b): brackets under the sound plates (straight), under the rusted lengths
# (bent), and at the three gaps (empty).
_BRK_SOUND = [-393.2, -391.8, -407.0, -405.6, -414.5, -413.1, -425.2, -423.9]
_BRK_BENT = [-402.95, -400.85, -398.75, -396.65, -394.55, -408.3, -410.4, -415.7, -417.6, -420.75, -422.65]
_BRK_EMPTY = [-404.6, -412.1, -419.1]
_SOUND = [(-393.5, -391.5), (-407.3, -405.3), (-414.8, -412.8), (-425.5, -423.6)]


def dress(A):
    LANTERN_LIGHTS.clear()

    # ------------------------------------------------------------ helpers
    def lantern(x, y_mid, wall_z, flip=False):
        """A works lantern on its own bracket and plate on the wall (`aguas_works_lantern_wall`, MINE_PASS F24, reviewer
        9, 11-19: the old 0.55 m arm pointed straight at the camera and the lantern seemed to float). y_mid is the
        lantern's middle as the pages draw it; its flame stays where the old one was, 0.02 under it. The model's origin
        is on the wall, 0.414 over the flame. flip: its plate to the east."""
        flame = round(y_mid - 0.02, 2)
        A.deco("aguas_works_lantern_wall", x, round(flame + 0.414, 3), z=wall_z, flip=flip, size=(0.6, 0.74, 0.45), tone="iron")
        LANTERN_LIGHTS.append((x, flame, round(wall_z + 0.48, 3)))

    def side_lantern(x, y, z, flip=False):
        """A works lantern on the mine's strap bracket, out of a pier's side in the wall's plane
        (where the pier stands too close to the play space for an arm). Origin: the bracket's
        fixed end; its hook is 0.42 along it (west if flip) and 0.03 down."""
        A.deco("mine_lantern_bracket", x, y, z=z, flip=flip, size=(0.48, 0.15, 0.06), tone="iron")
        hx, hy = round(x - 0.42 if flip else x + 0.42, 3), round(y - 0.03, 3)
        A.deco("aguas_works_lantern", hx, hy, z=z, size=(0.34, 0.58, 0.34), tone="accent")
        LANTERN_LIGHTS.append((hx, round(hy - 0.414, 2), round(z + 0.2, 3)))

    def wall(stem, x0, x1, y0, y1, face, depth, tone="brick"):
        """A painted wall piece standing back from its face (origin: the middle of its foot)."""
        A.deco(stem, round((x0 + x1) / 2, 3), y0, z=round(face - depth / 2, 3), size=(round(x1 - x0, 2), round(y1 - y0, 2), depth), tone=tone)

    def skin(stem, x0, x1, y0, y1, tone="rock2"):
        """The painted look of course solids, filling them (z -1.2 .. 1.2)."""
        A.deco(stem, round((x0 + x1) / 2, 3), y0, z=0.0, size=(round(x1 - x0, 2), round(y1 - y0, 2), 2.4), tone=tone, skin=True)

    def outcrop(x, y, wall_z, plant=None):
        """A small knob of loose brick standing out of a wall, a flat top for one of the works'
        flat painted plants. Origin: the middle of its foot; it stands 0.35 out of the wall."""
        A.deco("aguas_outcrop_brick", x, y, z=round(wall_z + 0.175, 3), size=(0.9, 0.4, 0.35), tone="back2")
        if plant == "fern":
            A.deco("aguas_fern_wet", x, y + 0.4, z=round(wall_z + 0.2, 3), size=(0.55, 0.45, 0.04), tone="accent")
        elif plant == "weed":
            A.deco("aguas_weed_tuft", x, y + 0.4, z=round(wall_z + 0.2, 3), size=(0.7, 0.3, 0.04), tone="accent")

    def drawn(stem, x, y, size, tone="iron", rot=0.0, z=FACE):
        """A thin thing drawn on a course solid's front face (origin: the middle of its foot line)."""
        A.deco(stem, x, y, z=z, rot=rot, size=size, tone=tone)

    def beam_end(x, y, wall_z, long=False):
        """An iron beam out of the back wall under a ledge, its end showing (origin: the middle
        of its foot; it runs from the wall toward the play space)."""
        d = 4.2 if long else 0.95
        A.deco("aguas_beam_end_long" if long else "aguas_beam_end", x, y, z=round(wall_z + d / 2, 3), size=(0.3, 0.4, d), tone="iron")

    # ============================================================ the whole biome: the far wall and the rock
    # The far background, blue-black, behind everything (the sheet's light). One flat painted
    # card, as far backgrounds are, in place of a2.py's flat card at z -6.
    A.deco("aguas_far_wall", -344.0, 82.0, z=-10.25, size=(244.0, 106.0, 0.3), tone="back3")
    # The course's rock, each mass one painted piece made for its place (skins of SKIN_REGIONS:
    # they fill the slabs they dress, z -1.2 .. 1.2). Black wet brick where the works are built,
    # black wet rock where they are cut, each with its level water bands and a band of green
    # growth at its waterline.
    skin("aguas_borde_pier", -238.0, -236.0, 86.0, 92.2)         # with its peaked top (a2.py line 62)
    skin("aguas_east_wall", -232.0, -223.0, 86.0, 115.6)
    skin("aguas_brazo_pier", -230.8, -227.8, 107.4, 110.0)
    skin("aguas_race_bed", -255.4, -229.0, 96.0, 98.3)
    skin("aguas_mill_core", -258.2, -232.6, 96.0, 120.7)
    skin("aguas_works_roof", -259.5, -223.0, 115.6, 176.0)
    skin("aguas_borde_bed", -284.0, -244.0, 86.0, 90.0)
    skin("aguas_cadenas_foot", -284.0, -265.5, 96.0, 120.7)
    skin("aguas_desague_mass", -294.0, -264.5, 125.6, 176.0)
    skin("aguas_charco_bed", -320.5, -284.0, 83.0, 113.0)
    skin("aguas_charco_roof", -320.5, -306.0, 128.0, 176.0)
    skin("aguas_tail_bed", -380.0, -320.5, 83.0, 114.5)
    skin("aguas_flume_roof", -346.0, -320.5, 122.5, 176.0)
    skin("aguas_tuberia_roof", -380.0, -346.0, 142.0, 176.0)
    skin("aguas_weir_pool_mass", -392.0, -380.0, 83.0, 134.5)
    skin("aguas_reach_bed", -425.5, -392.0, 83.0, 149.5)
    skin("aguas_reach_roof", -425.5, -380.0, 158.0, 176.0)
    skin("aguas_presa_dam", -449.0, -425.5, 83.0, 166.7)
    skin("aguas_presa_lake", -465.0, -449.0, 83.0, 173.0)
    skin("aguas_presa_roof", -465.0, -425.5, 170.0, 176.0)
    # The brick bodies of the hanging landings (slab()'s wet body under each coping).
    skin("aguas_borde_landing", -257.2, -251.5, 92.5, 92.7, tone="brick")
    skin("aguas_charco_landing_east", -291.0, -284.0, 116.7, 117.2, tone="brick")
    skin("aguas_charco_landing_west", -320.5, -314.0, 116.5, 117.0, tone="brick")
    skin("aguas_flume_landing", -325.0, -320.5, 117.5, 117.8, tone="brick")
    skin("aguas_cascada_landing", -385.0, -378.0, 137.5, 137.8, tone="brick")

    # ============================================================ 2.1 El Borde (and the lip, 1 to 2)
    # The tunnel's back wall, slate-grey brick, from the bed to the roof, x -288 to the east
    # wall: a brick rib proud every 6 m (x -258.6, -252.6, -246.6, -240.6 over the weir, -232.6);
    # upstream of the weir two round culvert mouths open at the waterline (-257.3 .. -254.3 and
    # -251.3 .. -248.3, black water going back under them); on the ledge one arch bricked up
    # (-231.3 .. -228.7). Behind the slot it goes down to 86 with the weir's sheet on it.
    wall("aguas_borde_back_wall", -288.0, -226.0, 86.0, 96.0, TUNNEL_WALL, 0.6)
    # The weir carried on behind: the same pale stone lip, from the play space back to the wall.
    A.deco("aguas_weir_lip_back", -244.2, 90.55, z=-1.925, size=(0.8, 0.45, 1.35), tone="stone")
    # (No coping in the play space: a solid at the very lip would be a hold that stops the fall
    # being one, so the area file builds none (ruled 11-14). The coping shows only behind, as
    # aguas_weir_lip_back above.)
    # The main's cast brackets from the back wall under it, stopping at the play space; a bigger
    # one where the chain hangs (origin: the middle of its foot; it runs from the wall forward).
    for x in (-251.0, -248.0, -241.0, -236.0, -234.2):
        A.deco("aguas_main_bracket", x, 94.0, z=-1.925, size=(0.25, 1.3, 1.35), tone="iron")
    A.deco("aguas_main_bracket_big", -246.6, 93.8, z=-1.925, size=(0.4, 1.7, 1.35), tone="iron")
    # The main's two ends, scenery from the play space's back edge on: at the west end it turns
    # back to the wall and up through the roof to the wheel pit; at the east (the ledge) it
    # turns back to the wall, drops to 91.1, runs west along the wall and goes down the dry
    # shaft behind the mine's lining (one bent run of 0.3 pipe, made for its place).
    A.deco("aguas_main_riser_west", -253.0, 94.35, z=-1.925, size=(0.3, 1.65, 1.35), tone="accent")
    A.deco("aguas_main_far_run", -231.75, 89.5, z=-1.925, size=(4.8, 2.65, 1.35), tone="accent")
    # What the landing hangs from: three iron beams out of the wall, their ends under it.
    for x in (-256.55, -254.45, -252.35):
        beam_end(x, 92.1, TUNNEL_WALL)
    # The first works lantern, greenish and steady, over the ledge: the first cold light.
    lantern(-227.6, 93.4, TUNNEL_WALL)
    outcrop(-262.5, 93.2, TUNNEL_WALL, "fern")      # the culverts' spray
    outcrop(-243.2, 94.9, TUNNEL_WALL, "weed")      # over the weir
    # Drawn on the main: a bolted flange every 3 m, and at each end of a rusted length (on the
    # sound pipe beside it).
    for x in (-250.0, -247.0, -241.0, -236.0, -244.08, -242.42, -239.08, -237.42):
        drawn("aguas_flange_face", x, 94.28, (0.16, 0.44, 0.02), tone="iron")
    # Foreground: one riser pipe in front of the solid rock east of the ledge, and the near
    # bank's broken brick lip below the river's bed, stopping short of the weir.
    A.deco("aguas_riser", -225.35, 84.0, z=1.45, size=(0.35, 14.5, 0.35), tone="accent")
    A.deco("aguas_bank_lip_borde", -252.35, 86.1, z=1.65, size=(15.3, 1.15, 0.7), tone="back2")

    # ============================================================ 2.2 La Rueda
    # The mill's back wall, brick to the roof, from the ladder well to the east wall (also 2.3's
    # standing arcade): the wheel's round arch 5.4 m wide open in it (-254.0 .. -248.6, springing
    # 100.0), then the aqueduct's back half: its four piers standing proud to z -1.3 behind the
    # four pier tops, the three round arches still whole between them (-246.6 .. -242.6,
    # -240.6 .. -235.95, -233.95 .. -228.25), open, and plain brick above them to the roof.
    A.deco("aguas_mill_back_wall", -240.7, RB, z=-1.925, size=(29.4, 10.6, 1.25), tone="brick")
    # Through the arches, far back: the race going back under a second arcade in the dark, and
    # the dark of the wheel's arch (one painted piece, lit only by the shimmer).
    A.deco("aguas_mill_far_arcade", -240.7, RB, z=-6.25, size=(29.4, 7.0, 0.5), tone="back3")
    # The second wheel, 4 m back on the same axle, greyer and wetter (FOR THE AREA FILE item 8:
    # it turns with yours), the axle between them, and the wheel's frame standing in the race
    # with the bearing at its top (the kit's frame, origin the axle).
    A.deco("aguas_mill_wheel_grey", -251.3, 100.8, z=-4.2, size=(4.0, 3.61, 1.87), tone="back")  # origin: the hub
    A.deco("aguas_wheel_axle", -251.3, 100.8, z=-2.26, size=(0.3, 0.3, 2.0), tone="iron")      # origin: its middle, on the axle
    A.deco("water_wheel_frame", -251.3, 100.8, z=-1.7, size=(4.6, 6.0, 0.6), tone="iron")
    # The ladder well: a round brick well cut in half, the rungs let into it, a cast ring where
    # it opens at the landing.
    A.deco("aguas_well_lining", -256.3, 95.9, z=-1.625, size=(1.8, 11.5, 0.75), tone="brick")
    lantern(-253.6, 104.8, MILL_WALL)   # over the arch

    # ============================================================ 2.3 El Acueducto
    # (The standing arcade and the far arcade are 2.2's, above.) The fallen spans: heaps of
    # brick under the water at the foot of each gap, behind where you swim.
    A.deco("aguas_brick_heap", -244.6, RB, z=-1.75, scale=0.8, size=(3.0, 0.8, 0.9), tone="back")
    A.deco("aguas_brick_heap", -238.3, RB, z=-1.75, size=(3.0, 0.8, 0.9), tone="back")
    A.deco("aguas_brick_heap_big", -231.0, RB, z=-1.75, size=(4.0, 0.9, 0.9), tone="back")
    # Behind each ring (note 18): a short brick pad built out from the arcade's wall with a
    # riveted iron plate on its face, stopping at the play space (the ring's bolt meets it).
    for x, y in _RINGS:
        A.deco("aguas_ring_pad", x, round(y - 0.4, 2), z=-1.6, size=(0.8, 0.8, 0.7), tone="brick")
    # The hatch the east ladder goes through: brick-lined, with a cast iron rim.
    A.deco("aguas_hatch_lining", -226.9, L1C, z=-1.625, size=(1.8, 2.6, 0.75), tone="brick")
    lantern(-241.6, 104.9, MILL_WALL)
    lantern(-227.4, 105.0, MILL_WALL)
    # The four pier tops, each its own piece: the trough's stump with a pale stone coping along
    # its top, its broken ends showing the trough's section and the first bricks of the arch
    # that sprang from it (skins of a2.py's crowns, line 104).
    for i, (x0, x1, y) in enumerate(_CROWN):
        skin("aguas_trough_stump_%d" % (i + 1), x0, x1, round(y - 0.9, 2), y, tone="brick")

    # ============================================================ 2.4 Brazo de Molino
    # The wash house's back wall: brick with two round arches barred with iron (-243.2 ..
    # -240.6 and -239.4 .. -236.8, springing 111.6), open, the far blue-black through the bars.
    wall("aguas_brazo_back_wall", -249.2, -226.0, MB, L2C, BRAZO_WALL, 0.6)
    # The inlet culvert at the west end: a round arch at the waterline with a rack of bars,
    # its short vault running back to the wall; the channel's water slides out of it.
    A.deco("aguas_culvert_barred", -245.1, MB, z=-2.825, size=(3.0, 3.1, 3.15), tone="brick")
    # The far bank, stone-coped, just above the water, and the two settling tanks on it, each
    # with a green pipe up into the roof.
    A.deco("aguas_far_bank", -237.2, MB, z=-2.9, size=(12.8, 1.55, 2.6), tone="brick")
    for x in (-234.55, -231.9):
        A.deco("aguas_tank", x, 109.95, z=-2.9, size=(2.5, 2.2, 2.5), tone="iron")
        A.deco("aguas_tank_pipe", x, 112.15, z=-2.9, size=(0.22, 3.45, 0.22), tone="accent")
    # The filler pipe's wall end: over the landing it turns straight back into the wall through
    # a teal valve wheel; two cast hangers from the roof carry it out over the drain (they
    # stand just behind it, so from the front they hold it up).
    A.deco("aguas_filler_turn", -229.5, 112.1, z=-2.825, size=(0.4, 0.4, 3.15), tone="accent")
    A.deco("valve_wheel", -229.5, 112.0, z=-1.6, scale=0.667, size=(0.9, 0.9, 0.2), tone="accent")
    for x in (-232.1, -234.9):
        A.deco("aguas_pipe_hanger", x, 112.3, z=-1.4, size=(0.2, 3.3, 0.25), tone="iron")
    lantern(-246.0, 113.7, BRAZO_WALL)   # over the rungs you swim for
    outcrop(-238.1, 113.4, BRAZO_WALL, "fern")
    # Drawn on the filler pipe's west end: the flared spout turned down (the dribble is the game's).
    drawn("aguas_spout_face", -236.8, 112.0, (0.4, 0.5, 0.02), tone="accent")
    # Foreground: the channel's near wall cut down to one broken course, below the bed.
    A.deco("aguas_bank_lip_brazo", -239.75, 107.45, z=1.55, size=(13.7, 0.65, 0.5), tone="back2")

    # ============================================================ 2.5 Las Compuertas
    # The gate hall's back wall: brick 20 m tall, black and wet low down where the gates leak,
    # paler above.
    wall("aguas_compuertas_back_wall", -255.6, -249.2, MB, WINC, GATE_WALL, 0.6)
    # The three sluice gates in their cast-iron frames (a rack and gear, seized, in each head),
    # each behind its ram; the leaf in each (FOR THE AREA FILE item 8: it rides with its ram);
    # the pug cast in each frame's head.
    for cx, fl, top in _GATES:
        A.deco("aguas_sluice_gate", cx, fl, z=-1.85, size=(2.0, 8.0, 1.1), tone="iron")
        A.deco("aguas_gate_leaf", cx, fl, z=-1.85, size=(1.7, 4.3, 0.15), tone="back")
        A.deco("pug_stamp", round(cx - 0.35, 2), round(top + 3.6, 2), z=-1.29, scale=0.2, size=(3.0, 3.0, 0.1), tone="iron")
    # The regulator: a riveted valve chest high on the wall and a fat pipe from it down to each
    # ram, all flat on the wall (one piece made for its place).
    A.deco("aguas_regulator", -252.5, 116.6, z=-2.0, size=(4.7, 8.6, 0.8), tone="iron")
    lantern(-251.0, 121.7, GATE_WALL)
    # Foreground: the regulator's supply pipe, in front of the solid rock east of the hall.
    A.deco("aguas_riser", -248.55, 116.0, z=1.45, size=(0.35, 14.5, 0.35), tone="accent")

    # ============================================================ 2.6 Cadenas
    # The catch chamber's back wall: brick, one round arch barred with iron high on the west
    # side (-271.4 .. -268.6, springing 124.0), carried on down behind the hopper and the lower
    # pipe to the river's roof. Its outline: the chamber's, from x -272 to -255.6.
    A.deco("aguas_cadenas_back_wall", -263.8, T0C, z=-3.9, size=(16.4, 32.6, 0.6), tone="brick")
    # The hopper's back half: riveted plates, dull green-black and wet, sloping to the lower
    # pipe; two plates missing, the back wall's brick showing through.
    A.deco("aguas_hopper_back", -264.7, 114.0, z=-2.43, size=(13.0, 6.7, 2.34), tone="iron")
    # The upper pipe's mouth: the back half of a heavy bolted flange round the hole in the roof,
    # the pug cast in it, and the riveted pipe's back half going on up (a pipe 5 m across round
    # the play plane: its back half runs from the play space to z -2.9).
    A.deco("aguas_pipe_mouth", -262.0, 128.2, z=-2.075, size=(5.8, 4.4, 1.65), tone="iron")
    # The crane beam under the roof, wall to wall, and a hoist block on it over each chain (each
    # chain you hold comes down from its block; nothing else hangs in this room).
    A.deco("aguas_crane_beam", -263.8, 127.7, z=-1.5, size=(16.4, 0.4, 0.3), tone="iron")  # origin: the middle of its underside
    for x in (-258.9, -265.3, -269.3):
        A.deco("aguas_hoist_block", x, 126.8, z=-1.5, size=(0.7, 0.9, 0.35), tone="iron")
    # The fitters' gallery's back wall, and the three plates they lifted out, leaning on it.
    wall("aguas_gallery_back_wall", -284.0, -272.0, 120.7, 125.6, GALLERY_WALL, 0.6)
    for x, r in ((-275.3, -14.0), (-274.5, -12.0), (-273.7, -16.0)):
        A.deco("aguas_hopper_plate", x, 121.0, z=-2.5, rot=r, size=(0.6, 2.3, 0.6), tone="iron")
    # The lantern on the wall over the landing (it hung in the air between the chains).
    lantern(-256.7, 125.6, CADENAS_WALL)

    # ============================================================ 2.0 The frog's valve chamber
    # The room (FOR THE AREA FILE 6d): a round brick vault 3 m wide, its back wall and vault and
    # the back of its floor, dry pale brick, the only dry room in the biome; no front wall. The
    # cast ring frame of its door round its mouth, and a hook in the vault for the lantern.
    A.deco("aguas_frog_room", -282.5, 117.4, z=-1.925, size=(3.4, 2.9, 1.35), tone="brick")
    # The round iron door (also 2.7's): riveted, 1.9 across, the pug cast in its middle and a
    # hand wheel, hinged on the back jamb and standing half open, out of your way.
    A.deco("aguas_frog_door", -285.0, 117.45, z=-1.85, size=(1.9, 1.9, 1.1), tone="iron")
    # The outlet valve against the room's back wall: a fat pipe up through the floor and into
    # the east wall, a round gauge on it, and the kit's teal valve wheel at chest height.
    A.deco("aguas_outlet_pipe", -281.6, 117.4, z=-2.1, size=(0.9, 2.3, 0.6), tone="accent")
    A.deco("valve_wheel", -281.7, 118.05, z=-1.7, size=(0.9, 0.9, 0.2), tone="accent")
    # The keeper's upturned bucket and the frog on it, in its oilskin hat (note 60).
    A.deco("mine_bucket_upturned", -283.1, 117.4, z=-1.75, scale=0.83, size=(0.6, 0.45, 0.6), tone="iron")
    A.deco("frog_rain_hat", -283.1, 117.77, z=-1.75, size=(0.34, 0.33, 0.35), tone="accent")
    # The keeper's lantern, lit, on its hook in the vault: its light falls out of the door.
    A.deco("aguas_works_lantern", -282.6, 119.3, z=-1.9, size=(0.34, 0.58, 0.34), tone="accent")
    LANTERN_LIGHTS.append((-282.6, 118.89, -1.7))

    # ============================================================ 2.7 El Charco del Pozo
    # The hall's two brick flanks, 15 m tall, each ending in a brick pier against the well's
    # rock (x -307.1 .. -306.5 and -293.5 .. -292.9); a bricked-up round arch in the east flank
    # (-292.3 .. -287.1, springing 119.4).
    wall("aguas_charco_flank_west", -320.5, -306.5, 113.0, 128.0, FLANK, 1.0)
    wall("aguas_charco_flank_east", -293.5, -284.0, 113.0, 128.0, FLANK, 1.0)
    # Between them no brick: the throat, the look up the well built the way a paper diorama
    # builds a tunnel. Five rings of black rock cut out of card, each smaller, further back and
    # higher (12, 8.4, 5.6, 3.4 and 1.8 m across, z -2 back to -8), a thin pale edge on each
    # one's upper side, and behind the last the one pale dot, 365 m up. The rings stop above the
    # shelf of fallen things (117.5).
    A.deco("aguas_throat", -300.0, 117.5, z=-5.0, size=(13.0, 10.5, 6.0), tone="back3")
    # The well's own rock above the hall's roof: the back half of the round shaft, black and
    # wet, up to where the mountain's well takes over (176), and the pale stone collar the
    # company put round its mouth, the back half of a 12 m ring.
    A.deco("aguas_well_back", -300.0, 128.0, z=-3.875, size=(13.0, 48.0, 5.25), tone="back3")
    A.deco("aguas_well_collar", -300.0, 127.5, z=-4.05, size=(13.6, 0.8, 5.6), tone="stone")
    # What has fallen: on a shelf of rock at the back of the pool, under the well, far behind
    # the barrels, a broken crystal point, a rotted mushroom cap, a carved block with a pug's
    # face and a coil of rope, all grey-blue and dim (one piece made for its place).
    A.deco("aguas_fallen_shelf", -300.85, CS, z=-4.2, size=(9.3, 2.2, 1.6), tone="back2")
    # The barrels' cove (note 21): a round brick arch at the waterline in the west flank, black
    # inside, its vault running back to the flank; the barrels float forward out of it.
    A.deco("aguas_barrel_cove", -312.7, 114.4, z=-3.4, size=(3.6, 3.7, 4.2), tone="brick")
    # Each ledge sits on iron beams out of its flank: their ends under it.
    for x, y in ((-290.35, 116.3), (-285.85, 116.3), (-319.65, 116.1), (-314.85, 116.1)):
        beam_end(x, y, FLANK, long=True)
    # (The frog's door is 2.0's, above.) Two lanterns, one on each flank; none under the well.
    lantern(-317.5, 121.4, FLANK)
    lantern(-289.6, 122.6, FLANK)
    outcrop(-309.5, 124.6, FLANK, "fern")
    outcrop(-286.0, 125.2, FLANK, "weed")
    # (No sill in the play space at the pool's lip: as at the weir, a hold at the lip of a fall
    # would stop the fall (ruled 11-14). The lip is the water's own edge.)

    # ============================================================ 2.8 Contracorriente
    # The flume's back wall: brick, black and wet to a tide line 1 m over the water, three round
    # culvert mouths at the waterline, one beside each pillar (-328.0 .. -325.2, -333.5 ..
    # -330.7, -339.0 .. -336.2, springing 116.6), open.
    wall("aguas_flume_back_wall", -346.0, -320.5, 114.5, 122.5, FLUME_WALL, 0.6)
    # The three pillars on the bed, bed to vault, each with its pale band at the waterline and
    # its stone nose to the current (the kit's, made 7 m: stretched to the flume's 8), and the
    # second row far back, seen through the culverts.
    for x in _PIL:
        A.deco("flume_pillar", x, 114.5, z=-1.8, scale=1.143, size=(0.9, 7.0, 0.9), tone="brick")
    for x in (-326.6, -332.1, -337.6):
        A.deco("flume_pillar", x, 114.5, z=-6.0, size=(0.9, 7.0, 0.9), tone="back2")
    # A depth gauge painted on the middle pillar's face, the water over the company's red line.
    A.deco("aguas_depth_gauge", -330.1, 115.2, z=-1.27, size=(0.5, 3.4, 0.03), tone="bone")
    # What the ledge and the grating hang from.
    for x in (-348.45, -345.15, -323.85, -321.25):
        beam_end(x, 117.3 if x < -340 else 117.1, FLUME_WALL)
    # Two lanterns on brackets out of the first and third pillars' sides, high, over the water.
    side_lantern(-335.07, 121.15, -1.8)
    side_lantern(-324.07, 121.45, -1.8)
    outcrop(-342.6, 120.6, FLUME_WALL, "fern")
    # Foreground: the flume's near wall cut down to one course, a full 3 m below the water's bed.
    A.deco("aguas_bank_lip_flume", -333.25, 110.5, z=1.55, size=(25.5, 1.05, 0.5), tone="back2")

    # ============================================================ 2.9 Tuberia
    # The boiler house's back wall: brick 27 m tall, sooty above the boiler, wet at the west end
    # where the pool above spills down it.
    wall("aguas_tuberia_back_wall", -380.0, -346.0, 114.5, 142.0, BOILER_WALL, 0.8)
    # The three piers standing in the tail pool, each a storey taller than the last, a pale
    # stone coping on each and a round arch through each at the waterline.
    for (x0, x1, top), stem in zip(_PIERS, ("aguas_boiler_pier_low", "aguas_boiler_pier_mid", "aguas_boiler_pier_high")):
        A.deco(stem, round((x0 + x1) / 2, 2), 114.5, z=round(PIER_FACE - 1.5, 3), size=(round(x1 - x0, 2), round(top - 114.5, 2), 3.0), tone="brick")
    # The boiler, end on, on its brick setting behind the grating: its fire door orange with the
    # pug cast on it (colour, not glow), the warmest thing in the biome; and its flue up the
    # east wall.
    A.deco("aguas_boiler_end", -349.6, 114.5, z=-2.9, size=(3.4, 6.7, 3.0), tone="iron")
    A.deco("aguas_flue", -347.25, 120.6, z=-1.8, size=(0.7, 21.4, 0.7), tone="iron")
    # The steam pipe, lagged, with wire bands, half a metre and more behind the play space: from
    # the boiler's stop valve up the three flights past the piers' corners, across each pier's
    # face, to the pump engine, with a bare stub coming straight forward off it at each of the
    # eleven hot joints (one piece made to the route; FOR THE AREA FILE item 3).
    A.deco("aguas_steam_pipe", -363.65, 119.75, z=-1.95, size=(29.2, 18.5, 0.5), tone="back")
    # The pump engine on the top pier, where the steam pipe ends, stopped; the feed tank on
    # the middle pier, the cold feed pipe into its foot.
    A.deco("aguas_pump_engine", -375.2, 134.9, z=-3.4, size=(4.0, 4.6, 2.4), tone="iron")
    A.deco("aguas_tank", -367.2, 129.6, z=-3.6, size=(2.5, 2.2, 2.5), tone="iron")
    # The works' one string of the town's paper flags, rotted, flat on the back wall under the
    # roof, far from anything you hold (the kit's, 10 m).
    A.deco("papel_tatters", -357.0, 139.6, z=-5.17, rot=-6.84, scale=1.25, size=(8.0, 1.0, 0.05), tone="accent")
    # A lantern on each pier's face under its run; the cast plate beside the first hot joint
    # (a hand and a flame, note 23), strapped to the flue's side.
    lantern(-355.8, 123.3, PIER_FACE)
    lantern(-366.0, 128.8, PIER_FACE)
    lantern(-375.1, 134.1, PIER_FACE)
    A.deco("aguas_warn_plate_hot", -348.25, 121.5, z=-1.4, size=(0.6, 0.6, 0.05), tone="bone")
    # Each cold run's two arms, going straight back from its straps to the pier's coping
    # (behind the run, so from the side the run looks fixed); the straps drawn on the runs.
    for x0, x1, y in _RUNS:
        for x in (round(x0 + 0.65, 2), round(x1 - 0.65, 2)):
            A.deco("aguas_run_arm", x, round(y - 0.5, 2), z=-1.725, size=(0.15, 0.65, 0.95), tone="iron")
            drawn("aguas_run_strap_face", x, round(y - 0.2, 2), (0.3, 0.4, 0.02), tone="iron")
    # Foreground: a riser in front of the solid rock above the flume (two lengths, flanged
    # where they meet).
    A.deco("aguas_riser", -345.45, 123.0, z=1.45, size=(0.35, 14.5, 0.35), tone="accent")
    A.deco("aguas_riser", -345.45, 137.5, z=1.45, size=(0.35, 14.5, 0.35), tone="accent")

    # ============================================================ 2.10 La Cascada Chica
    # The weir hall's back wall: brick 23 m tall, black and streaming at the west end beside the
    # fall, drier to the east; a round culvert mouth at the pool (-388.6 .. -385.8, springing
    # 136.2) and a round barred eye high up (2.2 across at (-383.4, 153.6)), both open.
    wall("aguas_cascada_back_wall", -392.0, -380.0, 134.5, 158.0, WEIR_WALL, 1.0)
    # The keepers' stair on the wall behind your holds: the lower flight's stone string, the
    # dead iron ladder's two rails with a stump where every rung was, the upper flight's string.
    A.deco("aguas_stair_string_low", -387.1, 139.0, z=-2.45, size=(4.2, 4.3, 0.3), tone="stone")
    A.deco("aguas_dead_ladder", -388.425, 143.4, z=-2.45, size=(0.75, 6.1, 0.3), tone="iron")
    A.deco("aguas_stair_string_high", -389.2, 149.4, z=-2.45, size=(4.0, 3.6, 0.3), tone="stone")
    # Each tread you hold runs back into the wall: its root, from the play space to the string.
    for x, y in _WET:
        A.deco("aguas_tread_root", x, round(y - 0.2, 2), z=-1.925, size=(0.55, 0.4, 1.35), tone="stone")
    # The weir carried on behind: its stone lip, from the play space back to the wall (as 2.1's).
    A.deco("aguas_weir_lip_back", -392.0, 150.7, z=-1.925, size=(0.8, 0.45, 1.35), tone="stone")
    # The lifting beam under the roof with the ring the climber's rope is tied to.
    A.deco("aguas_lifting_beam", -386.6, 157.3, z=-1.4, size=(4.4, 0.5, 0.3), tone="iron")
    lantern(-381.0, 141.3, WEIR_WALL)
    lantern(-381.3, 156.0, WEIR_WALL)
    outcrop(-390.9, 146.4, WEIR_WALL, "fern")      # kept green by the spray
    outcrop(-383.2, 147.2, WEIR_WALL, "weed")

    # ============================================================ 2.10b The catwalk over the upper reach
    # The channel's back wall: brick, a round culvert mouth at the waterline every 6 or 7 m
    # (x -396.5, -402.3, -408.6, -415.6, -422.4, 2.8 across, springing 150.8), open.
    wall("aguas_reach_back_wall", -425.5, -392.0, 149.5, 158.0, REACH_WALL, 0.6)
    # The catwalk's cast brackets out of the wall: two under each sound plate, one bent under
    # each rusted length, one standing empty at each gap.
    for x in _BRK_SOUND + _BRK_EMPTY:
        A.deco("aguas_catwalk_bracket", x, 151.9, z=-1.725, size=(0.16, 0.75, 0.95), tone="iron")
    for x in _BRK_BENT:
        A.deco("aguas_catwalk_bracket_bent", x, 151.9, z=-1.725, size=(0.16, 0.75, 0.95), tone="iron")
    # The back hand rail, on the wall side only, 1.1 m over the deck and half a metre behind
    # the play space: whole over the four sound plates, bent over three of the rusted stretches,
    # gone over the rest (origin: the middle of its foot; its brackets run back to the wall).
    for x0, x1 in _SOUND:
        A.deco("aguas_hand_rail", round((x0 + x1) / 2, 2), 153.9, z=-1.975, size=(2.0, 0.3, 0.45), tone="iron")
    for x, y in ((-422.3, 153.5), (-402.75, 153.55), (-400.25, 153.6), (-410.25, 153.5)):
        A.deco("aguas_hand_rail_bent", x, y, z=-1.975, size=(2.6, 0.7, 0.45), tone="iron")
    # The dam's main: a fat pipe flat on the wall under the roof, from the dam to the boiler house.
    A.deco("aguas_dam_main", -408.75, 156.15, z=-1.95, size=(33.5, 0.5, 0.5), tone="accent")
    lantern(-406.3, 155.3, REACH_WALL)   # over the two rest plates: the sound places are the lit ones
    lantern(-413.8, 155.3, REACH_WALL)
    outcrop(-419.6, 155.2, REACH_WALL, "fern")
    outcrop(-398.4, 155.6, REACH_WALL, "weed")

    # ============================================================ 2.11 La Presa
    # The dam hall's back wall, far back, blue-black: the hall over the spillway. (Over the
    # lake it is the join's vault, below.)
    wall("aguas_presa_back_wall", -440.0, -425.5, 151.9, 170.0, DAM_WALL, 1.0, tone="back2")
    # The spillway carried on behind: the same steps running back for the dam's whole width,
    # a round spill arch at their head (1.4 m), the water on them the game's.
    A.deco("aguas_spillway_back", -431.45, 151.9, z=-3.7, size=(11.9, 10.9, 4.6), tone="brick")
    # The inspection gallery (FOR THE AREA FILE 6i): a round barrel vault 7.8 m long through the
    # dam's foot, its back wall streaked white where the dam seeps, floor, back and roof, no
    # front; its mouth on the apron a round arch with the pug on its keystone.
    A.deco("aguas_inspection_gallery", -433.5, 151.9, z=-1.925, size=(8.2, 3.0, 1.35), tone="brick")
    # The lift shaft (also the join's head of the shaft): brick 2.6 m wide, straight up 18 m,
    # its back wall at z -1.5, dry and pale near the top, black and wet at the foot; on it the
    # two guide rails and the toothed rack the winch's pinion climbs; at the top a buffer beam
    # across it, at the foot a spring buffer in a shallow pit.
    A.deco("aguas_lift_shaft", -438.7, 151.9, z=round(SHAFT_WALL - 0.55, 3), size=(3.0, 18.1, 1.1), tone="brick")
    A.deco("aguas_lift_rails", -438.7, 152.2, z=-1.375, size=(2.0, 17.3, 0.25), tone="iron")
    A.deco("aguas_buffer_beam", -438.7, 169.5, z=-1.375, size=(2.6, 0.3, 0.25), tone="iron")
    A.deco("aguas_spring_buffer", -438.7, 151.9, z=-1.375, size=(1.0, 0.3, 0.25), tone="iron")
    # The new wall that keeps the cage in its shaft (FOR THE AREA FILE 6i), black wet brick.
    skin("aguas_shaft_wall", -437.4, -436.8, 160.9, 170.0, tone="slick")
    # Three lanterns: over the apron, in the gallery (the pool of teal light inside the dam you
    # see first), over the crest (the last of the works' lanterns but one).
    lantern(-426.6, 156.4, DAM_WALL)
    lantern(-433.5, 154.0, -2.6)
    lantern(-446.0, 170.6, VAULT_FACE)
    # Drawn on the dam's cut face between the lake and the shaft: the First Top Dog, 3 m across,
    # cast in iron and let into the brick (the brick round it is the dam's skin, in courses).
    A.deco("pug_stamp", -444.5, 159.0, z=1.15, size=(3.0, 3.0, 0.1), tone="accent")

    # ============================================================ 2 to 3: the dam's crest
    # The lake's brick vault, in round-arched bays, two bricked up (-458.2 .. -454.6 and -453.6 ..
    # -450.0, springing 168.2); its top three courses cracked, pale light in the cracks.
    wall("aguas_lake_vault", -459.0, -440.0, 163.0, 173.0, VAULT_FACE, 1.0)
    # The exit shaft's lining: brick, a round shaft cut in half, sound at the bottom, split open
    # by crystal at the top.
    A.deco("aguas_exit_shaft_lining", -452.5, 172.9, z=-1.85, size=(7.0, 3.1, 1.2), tone="brick")
    # Crystals grown down through the brick: deep blue-violet points out of the roof and the
    # shaft's lining, each with a collar of split, shouldered-aside brick round its root; the
    # one over the crest bright white, the first of the cave's lights (origin: the middle of its
    # root, at the top; it hangs down from there).
    A.deco("aguas_crystal_point", -447.1, 174.5, z=-2.15, size=(1.2, 3.6, 1.2), tone="accent")
    A.deco("aguas_crystal_point", -456.4, 175.2, z=-2.15, rot=55.0, scale=0.8, size=(1.2, 3.6, 1.2), tone="accent")  # out of the lining, slanting into the shaft
    A.deco("aguas_crystal_point_small", -443.95, 174.0, z=-2.15, size=(0.9, 2.4, 0.9), tone="accent")
    A.deco("aguas_crystal_point_small", -456.25, 173.6, z=-2.15, size=(0.9, 2.4, 0.9), tone="accent")
    A.deco("aguas_crystal_point_bright", -442.0, 173.6, z=-2.15, size=(0.8, 1.6, 0.8), tone="bone")
    # The lake's bed through the clear water: three small crystal points glowing faintly (the
    # cave's kit, a cluster on a rock collar), behind where anyone would swim.
    for x, s in ((-457.4, 0.93), (-454.7, 1.27), (-451.65, 0.73)):
        A.deco("crystal_cluster_c", x, 163.0, z=-3.5, scale=s, size=(1.0, 1.5, 1.0), tone="accent")
    # On the crest, far back: the dam's sluice wheel on its spindle, the pug in its hub, a crust
    # of crystal on its rim; over it, the last works lantern.
    A.deco("aguas_sluice_wheel_crusted", -447.3, 167.0, z=-2.7, size=(1.0, 1.55, 0.4), tone="accent")
    lantern(-443.0, 170.4, VAULT_FACE)
    # Drawn: the crest's coping cracked in two places, a thin seam of crystal in each crack
    # (nothing sticks up); the last 2 m of the rungs crusted with rough pale lilac crystal.
    drawn("aguas_coping_crack_face", -446.45, 166.4, (0.35, 0.6, 0.02), tone="accent")
    drawn("aguas_coping_crack_face", -443.35, 166.4, (0.35, 0.6, 0.02), tone="accent")
    drawn("aguas_rung_crust_face", -449.5, 176.0, (0.5, 2.2, 0.05), tone="accent")
    # The shaft's rim on the cave's floor: half a ring of the works' pale stone, the other half
    # already crystal (the look of a3.py's kerb: FOR THE AREA FILE item 5).
    skin("aguas_shaft_rim", -448.95, -448.45, 176.0, 176.6, tone="stone")
