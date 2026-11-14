"""
LA GRUTA DE CRISTAL, DRESSED: the scenery of all of biome 3, the crystal cave (y 176 to 278),
from the eleven area pages (the frog's room 3.0 and the ten challenges, with the well crossing
3.10, the join "3 to 4") in docs/peak/playtest/design/data/a3_areas.py and the biome's sheet
a3_biome.py (its `built`, `looks`, `layers` and `kit`). La Columna (3.9) and Primer Destello
(3.1) follow the course as the fix run of 11-13 built them (notes 74, 26: commit b6b8eb8).
The join "2 to 3" is biome 2's: a2_dress.py placed the crystal points grown down through the
dam's brick under this floor, the exit shaft's lining (the back half of the hole, z -1.25 ..
-2.45) and `aguas_shaft_rim`, the look of a3.py's kerb. This file leaves all of that alone and
cuts the hole's back half out of the floor it carries back (`gruta_floor_back`).

Parker, 11-13: the cave is PURELY NATURAL. Nothing here is made by anyone: no chain, no bronze,
no carved stone, no timber, no iron. What hangs, hangs on a grown thread of crystal; what turns,
turns in a socket it has worn. The only things from outside are the frozen climber (a3.py's
statue and shell) and his coil of rope.

Scenery only: decos. Nothing here can be stood on or held. The course (the floor, La Rampa,
the shafts, the mirror and its nubs, the rests, the chandeliers, the geode, the needles, the
leaves, the raft, the pendulum, the glass ceiling, the spikes, the horns, the shelves) is
a3.py's. The model list this file makes is docs/peak/models/a3_models.md.

Depth: the play space is z -1.2 .. 1.2. Everything here stands behind -1.25 or in front of
1.25, except SKINS (skin=True): the painted rock of the hall's shell and every crystal you
touch, each the LOOK of course solids (MODELLING_RUN rule 4), filling them, z -1.2 .. 1.2.
A crystal you touch is two pieces: its skin in the play space and its body carrying on behind
from z -1.25 to its root (a shaft's lower half, a root fan, a needle's cross arm, a nub's thin
point, the glass ceiling's root, the Prism's body), as the sheet says: every hold is the end
of a crystal that roots in the wall behind.
From the back, the cave stands at: the far wall z -10.25; the hall's floor and La Rampa carried
back from the play space to -9.0, the far giants standing on them at -5 .. -9.5 and the column
at -5.05 with its collars round it (-8.85 .. -1.25); the hall's back wall in five pieces, its nearest
planes at -2.9 just behind the crystals' roots, falling back in big slanted planes to -4.6
(the mirror faces lie on it there, -4.6 .. -4.5) and opening into deep bays where the giants
stand, with the roof's underside along its top carried forward to -1.25; the seep crack's rib
of rock standing out of it to -1.6; roots, fans and the bright clusters -3.0 .. -1.4; the
raft's rail -1.8 .. -1.3. In front: nothing but four dark points and one fern, low, in the
bottom corners in front of solid rock (note 40).

Walls and masses (BRIEF.md "Walls and masses"; the sheet's `built`): crystal is real shape and
rock is paint. Every wall, floor and roof is ONE painted piece made for its place: rough dark
rock as a few large slanted planes, its grain long wavy lines and bands of flat colour in three
or four dark indigo tones, none as pale as a hold, nothing painted narrowing to a point; the
few real breaks are the socket a big crystal grows from, a hollow where one has fallen out, an
overhang with its shadow painted under it; the outline uneven, never ruled, notched away from
the holds and tops. Crowded with smaller real points (clear, dim, blue). The cave's walls carry
a few small outcrops of rough rock, each with a small growth of crystal on it (the sheet: here
the plants are crystal), dim blue-violet, never pale lilac.

A deco's origin is the middle of its base (x and z) at its foot (y), unless its comment says
otherwise: things that hang (roof points, threads, the prisms' bodies) have their origin at the
middle of their top, where they leave the roof; a collar's is its centre. A deco's size is the
size its model is MADE at (the game rescales a landed model more than a quarter off); where one
model is used at several sizes, `scale` does it and the size is the model's own. `rot` is in
degrees, counter-clockwise as the camera sees it (a positive rot tips a thing's top to the west).

Shared pieces are placed once, in the first section that names them, and the other page is
named in a comment (the floor's bright cluster for 3.1 and 3.2, the bright cluster over the spar
for 3.4 and 3.5, the raft's rail for 3.5 and 3.6, the column for 3.8 and 3.9...).

FOR THE AREA FILE (tools/peak/areas/a3.py; the fix thread's). Line numbers are a3.py's as of
2026-11-14 01:01 (commit b6b8eb8, with La Columna's collars and Primer Destello's shafts in).
  1. Call it: `import a3_dress` beside the other imports, and `a3_dress.dress(A)` after the
     course is built (before A.save()).
  2. Lights. Each area is lit by one or two bright white crystals (the sheet's light), placed
     here: put one steady light at each entry of `a3_dress.BRIGHT_LIGHTS` (x, y; 10 of them):
     WHITE, range 8, energy 1.5, flicker False. Then the WHITE entries of the light loop
     (lines 529-534: (-427.0, 187.5), (-442.5, 194.5), (-415.0, 218.5), (-385.0, 226.0),
     (-360.0, 240.0), (-318.0, 245.0), (-334.0, 259.0), (-311.0, 268.5)) go; its violet and cyan
     ones, the slope's four (line 535-536), the well's mouth (537) and the chandeliers' own (262)
     stay. The join asks for one more, steady: `a3_dress.GARDEN_LIGHT`, a soft green one at the
     spore lantern through the far door (colour "#8FE07A", range 6, energy 1.0).
  3. Decos to take out (this file places all of the cave's scenery, out of the play space):
     line 489 (`crystal_column` at z -1.6: the page moves it 5 m back, down to La Rampa:
     `gruta_column` here), lines 491-494 (the eleven `mirror_facet` at z -1.9: the mirror faces
     lie on the back wall now, -4.6 .. -4.5), lines 518-521 (the six clusters), 522-523 (the five
     far chandeliers: 3.3, "nothing that looks like a rope hangs behind the climb"; young threads
     here instead), 524-525 (the five `stalactite_b`: rock, not crystal; roof points here), 526-527
     (the three `crystal_spire` at z -2.2: one stands on La Rampa here, at -6). KEEP line 251,
     `crystal_shell_clear` round the statue (the frozen climber's shell, with the statue).
  4. Cards to take out, all sixty: root() (lines 45-51) stops drawing its two cards (its calls
     can stay; every crystal's body behind is placed here), line 469 (the far card: `gruta_far_wall`),
     line 470 (the AIR card at z -6: the five back wall pieces and the floor and La Rampa carried
     back), lines 473-487 (the fourteen prism cards: the giants), lines 496-499 (the ten dark
     shard cards: the walls' own points and the roof points).
  5. Skins. Each named solid takes `skin=` its stem; this file places every skin deco.
     a. The shell: every slab A.cave (line 159) makes for edge i of AIR takes
        `a3_dress.SHELL_SKINS[i]`, and every corner filler it makes takes the skin of the edge
        after it (the filler made at the start of edge i takes edge i's). Edge 6 and its filler
        take none (item 6f). The landing's frosted face and lip (lines 380-381) take
        "gruta_landing".
     b. The crystals, by line: the five shafts (shaft(), lines 187, 189, 190: body, top, point)
        "gruta_wall_point"; the sixth (lines 211, 213) "gruta_wall_point_snapped"; the mirror
        (232) and its broken top edge (240) "gruta_mirror_slab"; the five nubs (238), the loose
        nub (242), the hold under R4 (341) and the chimney's five (394) "gruta_nub"; R2 (rest(),
        line 239: its body, ledge and patch) "gruta_rest_r2"; the three chandelier bosses (259)
        "gruta_worn_socket"; R3 (263) and its frosted face (264) "gruta_rest_r3"; the spar (281)
        "gruta_spar"; R4 (282) and the face patch under it (342) "gruta_rest_r4"; the needles
        (needle(), lines 293-296: shaft, point, frost) "gruta_needle_first", "gruta_needle" (both
        middle ones), "gruta_needle_last"; R5 (297) "gruta_rest_r5"; the eight leaves (320)
        "gruta_crazed_plate" (the skin must go with its leaf when it breaks and come back with
        it); R6 (321) "gruta_rest_r6"; the glass plate (333) "gruta_prism_face"; the pendulum's
        roof crystal (348) "gruta_pivot_crystal"; R7 (351) "gruta_rest_r7"; the stump on R7
        (352) "gruta_bonsai"; the glass fin (353) "gruta_roof_fin"; the glass ceiling (370)
        "gruta_ceiling_slab"; its tooth (372) "gruta_tooth"; its first patch (374)
        "gruta_crust_long" and the other five (379) "gruta_crust"; the slot's glass (390), R8's
        slab and ledge (391-392) "gruta_shelf_r8"; the west horn (435-436) "gruta_west_horn"; R9
        (449-450) "gruta_shelf_r9"; the step down and the door's sill (451-452) "gruta_door_sill";
        the horn (460-461) "gruta_horn"; the six roof prisms (515), west to east,
        "gruta_roof_prism_a", "_b", "_c", "_d", "_e", "_d" (the fourth and the sixth are the
        same shape).
     c. The kerb (line 163) takes "aguas_shaft_rim": a2_dress.py places it (half a ring of the
        works' pale stone, the other half already crystal). The 3.0 page asks for a short rough
        point there; the rim's crystal half is that, so nothing more is placed here.
  6. Course changes on the pages, for the fix thread (not scenery):
     a. 3.0 (note 60, Parker 11-13: the place is right): the frog's room. Cut the room as air in
        the west wall (solid glass today): the page's hollow, x -461.9 .. -459.0, y 176.0 ..
        178.8 (`_HOLLOW` in a3_areas.py), open at the wall's face 2.2 m tall (176.0 .. 178.2),
        and give it a frosted floor at 176.0, x -461.3 .. -459.0 (a "rock" ledge on the filler
        under it). The wall above stays glass. This file places the room's back, lining, frog,
        stump, mirror and light; the west wall's skin "gruta_west_wall" is made with the room
        cut in it and the geode's banded rind round the cut on its face.
     b. 3.3, look only: the three chains (A.rope, line 260, kind "chain") become grown threads
        of the same length that swing the same way (kind and look: section 7), and the three
        bosses become worn sockets (item 5b). Nothing you touch moves.
     c. 3.4 (note 29, not built yet): the geode turns half as fast again, rpm 2.0 -> 3.0 (line
        280).
     d. 3.7 (note 32): the stump on R7 (line 352) is cut to the bonsai's trunk and crown, the
        page's outline: (-349.15, 231.8), (-348.85, 231.8), (-348.8, 232.45), (-348.55, 232.7),
        (-348.7, 233.0), (-349.3, 233.0), (-349.45, 232.6), (-349.2, 232.4). Still crystal, still
        held, still a stop for what rolls along the ledge.
     e. 3.9: the column moves 5 m back and down to La Rampa: done here (item 3). The page also
        asks the camera (line 446) to see 1.5 m further west than it did: check it does.
     f. Found while dressing, not on a page: the hall's east wall is the shared well's west
        wall, which st.json already has (x -310 .. -306, y 176 .. 264 and 278 .. 362). a3's slab
        for AIR edge 6 (x -309 .. -306, y 241.5 .. 264), its corner filler (y 238.5 .. 241.5) and
        the roof slab carried on (line 162, x -309 .. -306, y 278 .. 281) lie inside it: two faces
        in one place (note 27). Suggest: make edge 6 open in A.cave's kinds (6: None) and drop
        line 162; the landing's floor slab and the roof slab of edge 8 also run 1 m into it
        (to x -308.98). That wall's look is the shared structure's; nothing is skinned for it
        here. Likewise st.json's well cards (z -5, -4.1, -3.2, x -312 .. -288, y 170 .. 500)
        draw the well's back over the stretch `gruta_well_back` (y 176 .. 290) now models: when it
        lands, those cards want the stretch 176 .. 290 cut out of them by the shared structure's owner.
  7. Movers', ropes' and holds' looks (the area file's; models in a3_models.md, section 4):
     the geode (line 280) wears `gruta_geode` in place of `geode_wheel` (a bowl with its back,
     the white vein, the rind's ribs and the knob that sits in the nest's socket); the raft (336)
     `gruta_raft` in place of `crystal_raft` (with the claw round the rail behind it); the
     pendulum (349) `gruta_quartz_pendulum` in place of `quartz_pendulum` (a clear glass thread,
     the ball at its top, the rough quartz across its end); the chandeliers' bob (261)
     `gruta_chandelier` in place of `chandelier_crystal` at 0.6 (made at 1.2 x 1.5, scale 1.0),
     and their ropes a knuckled thread of rough lilac crystal (`gruta_thread_knuckle`, one
     knuckle 0.5 long, if the rope code takes a segment model); the 24 spikes (425) each
     `gruta_collar_spike` (a rough pale point 2.3 m long, its tip the hold, running back into
     its collar).
  8. Effects (the pages'; a3.py's A.effect): the cave's breath (glitter drifting east in slow
     pushes, three seconds on and three off, through the whole hall and out of the door: it
     swings the pendulum and sends the raft home); the rainbow fan on the wall behind the leaves
     (3.6: red lowest, violet highest, from the Prism's upper end at (-376.4, 220.4) up to the
     leaves, dim, still, the only colours in the cave that are not violet or white); the run of
     water down the nest's west side behind the geode's rim, white on the rind's ribs, and its
     drip from the nest's bottom lip at (-420.4, 206.5) (3.4); a drip from the crack onto the
     floor now and then (3.1); a drop down each chandelier's thread about every ten seconds
     (3.3); motes of glitter in the frog's room (3.0); green spores drifting west across the well
     and mist lit violet on the west side and green on the east (3.10).
"""
import math

# ------------------------------------------------------------------ the lines things stand on
FLOOR = 176.0          # the hall's frosted floor (and the frog's room's)
NEAR = -2.9            # the back wall's nearest planes, just behind the crystals' roots
MIRROR_Z = -4.55       # the mirror faces, on the back wall's deeper planes (-4.6 .. -4.5)
BACK = -9.0            # how far the floor, La Rampa and the walls carry back
ROOT_Z = -2.125        # a crystal's body behind the play space: z -3.0 .. -1.25 (made 1.75 deep)
FAN_Z = -2.2           # a root fan or a bright cluster on the wall: z -3.0 .. -1.4
GIANT_Z = -6.5         # the far giants, standing on the floor or La Rampa


def slide_y(x):
    """La Rampa's top face (a3.py's slide_y); the same at every depth."""
    return 176.0 + 0.70 * (x + 410.3)


def roof_w(x):
    """The roof over the start hall (a3.py's roof_w): the chandeliers hang from it."""
    return 210.2 + 0.5333 * (x + 443.8)


def under(x):
    """The glass ceiling's underside (a3.py's under)."""
    return 245.2 + 0.625 * (x + 324.3)


# The hall's shell: the skin of each slab a3.py's A.cave makes for edge i of AIR (FOR THE AREA
# FILE item 5a). Edges 1 (the hole) and 7 (the door) are open. A corner filler takes the skin
# of the edge after it.
SHELL_SKINS = {
    0: "gruta_floor_west",     # the short floor west of the hole (and the frog's room's floor)
    2: "gruta_floor",          # the hall's floor
    3: "gruta_rampa",          # La Rampa
    4: "gruta_landing",        # the wall under the landing
    5: "gruta_landing",        # the landing's floor
    # 6: none. The wall between the landing and the door is the shared well's west wall (st,
    #    x -310 .. -306): FOR THE AREA FILE item 6f.
    8: "gruta_roof_east", 9: "gruta_roof_east",
    10: "gruta_roof_pendulo", 11: "gruta_roof_pendulo", 12: "gruta_roof_pendulo",
    13: "gruta_roof_agujas", 14: "gruta_roof_agujas", 15: "gruta_roof_agujas", 16: "gruta_roof_agujas",
    17: "gruta_roof_west",     # the roof over the start hall
    18: "gruta_west_wall",     # the west wall, with the frog's room cut in it
}

# The bright white crystals that light each area (x, y of the light), for a3.py's lights (FOR
# THE AREA FILE item 2). Filled by dress().
BRIGHT_LIGHTS = []
GARDEN_LIGHT = (-290.6, 265.0)

# 3.1: the low end of each shaft's top face (a3.py's LO1 + k * PER), and the sixth.
_LO = [(-411.46, 176.73), (-416.45, 179.01), (-421.44, 181.28), (-426.42, 183.55), (-431.41, 185.83)]
# 3.2: the five nubs on the mirror (a3.py's NUBS) and the loose nub.
_NUBS = [(-441.55, 190.82), (-442.21, 192.39), (-442.9, 194.0), (-443.54, 195.52), (-444.24, 197.17)]
_NUB0 = (-440.5, 190.2)
# 3.3: the three chandeliers' x (their sockets hang from roof_w).
_CHAND = (-443.8, -437.8, -431.8)
# 3.6: the eight leaves (a3.py's SHELF: the middle of each top).
_LEAVES = [(round(-383.2 + 6.0 * (i + 1) / 9.0 + (0.4 if i % 2 == 0 else -0.4), 2), round(222.3 + 9.5 * (i + 1) / 9.0, 2)) for i in range(8)]
# 3.8: the five short patches' middles (the first, long one is -340.1).
_PATCH_X = [round(-337.085 + 2.64 * i, 3) for i in range(5)]
# 3.9: the middles of the three collars (the middles of the spikes' crossings), and the chimney.
_COLLARS = [(252.8, -1), (257.6, 1), (262.4, -1)]   # -1: high side to the west
_CHIM = [(-310.0, 243.2), (-311.6, 244.3), (-310.0, 245.5), (-311.6, 246.7), (-311.7, 248.2)]
# The six roof prisms (a3.py lines 512-516): skin stem, x west, x east, y bottom, y top.
_PRISMS = [("gruta_roof_prism_a", -454.8, -452.2, 199.03, 206.23), ("gruta_roof_prism_b", -427.2, -424.8, 213.49, 220.89),
           ("gruta_roof_prism_c", -394.2, -391.8, 231.97, 236.37), ("gruta_roof_prism_d", -369.6, -367.4, 245.5, 249.7),
           ("gruta_roof_prism_e", -354.5, -352.5, 245.9, 249.7), ("gruta_roof_prism_d", -319.6, -317.4, 275.0, 279.2)]


def dress(A):
    BRIGHT_LIGHTS.clear()

    # ------------------------------------------------------------ helpers
    def skin(stem, x0, x1, y0, y1, tone="back", flip=False):
        """The look of course solids, filling them (z -1.2 .. 1.2)."""
        A.deco(stem, round((x0 + x1) / 2, 3), y0, z=0.0, flip=flip, size=(round(x1 - x0, 2), round(y1 - y0, 2), 2.4), tone=tone, skin=True)

    def back(stem, x0, x1, y0, y1, z_near, z_far, tone="back2"):
        """A piece behind the play space, from z_near back to z_far (origin: the middle of its foot)."""
        A.deco(stem, round((x0 + x1) / 2, 3), y0, z=round((z_near + z_far) / 2, 3), size=(round(x1 - x0, 2), round(y1 - y0, 2), round(z_near - z_far, 2)), tone=tone)

    def wall(stem, x0, x1, y0, y1):
        """A piece of the hall's back wall: nearest planes at -2.9, deeper planes and bays to -9,
        the roof's underside along its top carried forward to -1.25."""
        back(stem, x0, x1, y0, y1, -1.25, BACK, tone="back2")

    def fan(x, y, s=1.0):
        """A root fan: three or four small points on a collar of rough rock, grown out of the wall
        towards the camera round a crystal's root. (x, y) is the collar's middle; made 3.0 across."""
        A.deco("gruta_root_fan", x, round(y - 1.5 * s, 3), z=FAN_Z, scale=s, size=(3.0, 3.0, 1.6), tone="back")

    def bright(x, y, z=FAN_Z, rot=0.0):
        """A bright white cluster grown out of the wall, lit (its light in BRIGHT_LIGHTS). (x, y)
        is its collar's middle; made 2.0 across. Turned over (rot 180) it points down, its foot
        above the collar."""
        A.deco("gruta_bright_cluster", x, round(y + (1.0 if rot else -1.0), 3), z=z, rot=rot, size=(2.0, 2.0, 1.4), tone="crystal")
        BRIGHT_LIGHTS.append((x, round(y + (-0.8 if rot else 0.8), 2)))

    def mirror(stem, x, y, rot, scale=1.0):
        """A clear face on the back wall's deeper planes that gives the climber back to himself."""
        size = (4.0, 7.0, 0.1) if stem == "mirror_facet" else (5.0, 5.5, 0.1)
        A.deco(stem, x, y, z=MIRROR_Z, rot=rot, scale=scale, size=size, tone="accent")

    def giant(x, y, scale=1.0, rot=0.0, z=GIANT_Z):
        """A far crystal bigger than a house, dim and blue, standing on the floor or La Rampa."""
        A.deco("gruta_giant", x, y, z=z, rot=rot, scale=scale, size=(6.0, 30.0, 4.5), tone="back")

    def nub_root(x, y):
        """The thin point a nub is the tip of, running back from the play space to a small collar."""
        A.deco("gruta_nub_root", x, round(y - 0.45, 3), z=ROOT_Z, size=(0.9, 0.9, 1.75), tone="back")

    def roof_point(x, y_top, s=1.0):
        """A short thick clear point hanging from the roof (origin: the middle of its top)."""
        A.deco("gruta_roof_point", x, y_top, z=-2.25, scale=s, size=(0.5, 1.5, 0.5), tone="back")

    def outcrop(x, y):
        """A small knob of rough rock standing out of the wall's near planes, a small growth of
        dim crystal on its top (the sheet: here the plants are crystal)."""
        A.deco("gruta_outcrop", x, y, z=round(NEAR + 0.175, 3), size=(0.9, 0.4, 0.35), tone="back2")
        A.deco("gruta_growth", x, round(y + 0.4, 2), z=round(NEAR + 0.2, 3), size=(0.5, 0.45, 0.35), tone="back")

    def dark_point(stem, x, y, rot, s=1.0, z=1.9):
        """The cave's only foreground: a dark crystal point in a bottom corner, in front of solid
        rock, its tip below the floor above it."""
        size = (1.2, 3.4, 1.2) if stem == "gruta_dark_point" else (1.4, 6.5, 1.4)
        A.deco(stem, x, y, z=z, rot=rot, scale=s, size=size, tone="back3")

    # ============================================================ the whole biome: the far wall and the shell
    # The far background, deep indigo, behind everything (the sheet's light): one flat painted
    # card, as far backgrounds are, in place of a3.py's flat cards at z -10 and -6.
    A.deco("gruta_far_wall", -383.0, 168.0, z=-10.25, size=(166.0, 116.0, 0.3), tone="back3")
    # The hall's shell, each piece painted rock made for its place (skins of SHELL_SKINS: they
    # fill the slabs and fillers they dress). The floor and the landing frosted and pale on top
    # (somewhere to stand); the walls and the roof dark rough rock; La Rampa the one clear indigo
    # face of the biggest crystal in the cave, scored with long pale scratches all running down.
    skin("gruta_floor_west", -462.0, -455.98, 173.0, 176.0, tone="rock")    # the frog's room's floor on its top
    skin("gruta_floor", -449.02, -410.28, 173.0, 176.0, tone="rock")        # with the drift of chips at its east end (3.1)
    skin("gruta_rampa", -410.32, -322.56, 173.0, 236.21)
    skin("gruta_landing", -324.45, -308.98, 233.74, 241.62, tone="rock")    # its frosted west face and lip
    skin("gruta_roof_east", -342.69, -308.98, 261.98, 281.0)
    skin("gruta_roof_pendulo", -380.46, -339.99, 239.98, 263.55)
    skin("gruta_roof_agujas", -425.71, -377.98, 220.75, 242.79)
    skin("gruta_roof_west", -460.43, -423.98, 202.08, 223.42)
    skin("gruta_west_wall", -462.0, -459.0, 175.98, 204.74)                 # the frog's room cut in it, the rind round the cut
    # The floor and La Rampa carried back from the play space to the bays, the giants standing on
    # them. The floor's back half of the hole cut out where a2's shaft lining stands (x -456 ..
    # -449, to z -2.45); La Rampa's face scored like its skin, a drift of chips along its foot.
    back("gruta_floor_back", -462.0, -410.3, 173.0, FLOOR, -1.25, BACK, tone="rock2")
    back("gruta_rampa_back", -410.3, -324.3, 173.0, 236.2, -1.25, BACK, tone="back")
    # The hall's back wall in five pieces, each made for its stretch (its outline the hall's:
    # from the floor or La Rampa up to the roof). Its nearest planes are the rock the crystals you
    # climb grow from, crowded with small clear points; its deeper planes carry the mirror faces;
    # it opens into bays where the giants stand.
    wall("gruta_salon_back_wall", -462.0, -428.5, FLOOR, 218.4)      # 3.0 to 3.3: the start hall; the frog's room's hollow cut in its west end, the drip seam along its roof
    wall("gruta_geoda_back_wall", -428.5, -404.0, FLOOR, 232.4)      # 3.4 and the west of 3.5: the nest's wall
    wall("gruta_agujas_back_wall", -404.0, -372.0, 180.4, 248.5)     # 3.5 and 3.6: the bay, so deep it is dark, the crack climbing its top
    wall("gruta_pendulo_back_wall", -372.0, -340.0, 202.8, 262.0)    # 3.7 and the west of 3.8
    wall("gruta_columna_back_wall", -340.0, -306.0, 225.2, 278.0)    # 3.8 to 3.10: open round the column, the door cut in its east end

    # ============================================================ 3.0 La Geoda de la Rana
    # The frog's room (FOR THE AREA FILE 6a): the inside of a geode 2.9 m across that sat whole in
    # the west wall, the wall's face broken away with a slice of it: floor, back and roof, no
    # front; short clear violet points all round the inside, every one pointing at the middle.
    A.deco("gruta_frog_geode", -460.45, FLOOR, z=ROOT_Z, size=(2.9, 2.8, 1.75), tone="back")
    # The frog on its crystal stump at the back of the room, looking at itself in one clear face.
    A.deco("gruta_frog_stump", -460.95, FLOOR, z=-1.9, size=(0.5, 0.36, 0.4), tone="crystal")
    A.deco("frog_sit", -460.95, 176.36, z=-1.9, size=(0.26, 0.26, 0.27), tone="accent")
    A.deco("mirror_facet", -461.5, 176.45, z=-2.3, rot=-9.0, scale=0.13, size=(4.0, 7.0, 0.1), tone="accent")   # 0.9 m tall
    # The room's light: one bright white point hanging from the top of the hollow (no lantern).
    A.deco("gruta_roof_point_bright", -460.4, 178.75, z=-2.1, size=(0.3, 0.5, 0.3), tone="crystal")   # origin: its top
    BRIGHT_LIGHTS.append((-460.4, 178.35))
    # The slice that broke off: lying hollow side up on the back edge of the short floor like a
    # dish, lined with the same points (in place of today's cluster).
    A.deco("gruta_geode_slice", -457.5, FLOOR, z=-2.1, size=(2.4, 0.8, 1.4), tone="back")
    # A mirror face on the back wall straight behind the top of the rungs: the first thing the
    # cave shows you is yourself, small, climbing out of the floor.
    mirror("mirror_facet", -452.7, 179.4, -4.0, scale=0.88)
    # A giant far back, dim and blue, on the hall floor.
    giant(-447.4, FLOOR, scale=0.75, z=-7.0)
    outcrop(-456.0, 191.5)
    # (The kerb east of the hole wears a2's `aguas_shaft_rim`: FOR THE AREA FILE 5c.)

    # ============================================================ 3.1 Primer Destello
    # The crack, and the rib of dark rock along it: rising west at the stair's own angle from La
    # Rampa's foot to the sixth shaft, tiny points fringing it all the way; every shaft roots in it.
    back("gruta_crack_stair", -442.5, -409.5, FLOOR, 191.83, -1.6, -3.0, tone="back3")
    # The five shafts (skins: top face and point rough pale lilac, the under-face clear indigo),
    # each one's lower half running back and down along its own line to its root on the rib, and
    # round each root a fan of smaller points on a collar of rock, bluer and dimmer.
    for lx, ly in _LO:
        skin("gruta_wall_point", round(lx - 2.79, 2), round(lx + 0.07, 2), round(ly - 0.95, 2), round(ly + 1.13, 2))
        A.deco("gruta_shaft_root", round(lx + 0.55, 2), round(ly - 1.9, 2), z=ROOT_Z, size=(2.2, 1.9, 1.75), tone="back")
        fan(round(lx + 1.37, 2), round(max(ly - 1.42, 176.9), 2), s=0.67)   # (the first shaft's root is at the floor: its fan sits on it)
    # The sixth, snapped: thicker, nearly level, its west end a flat glassy break; its body
    # carrying back (the shafts' lower half, laid at its 14 degrees), and its fan.
    skin("gruta_wall_point_snapped", -439.33, -435.66, 187.34, 189.65)
    A.deco("gruta_shaft_root", -434.94, 186.89, z=ROOT_Z, rot=16.0, size=(2.2, 1.9, 1.75), tone="back")
    fan(-434.0, 187.55, s=0.77)
    # The one bright cluster of this area (also 3.2's floor), 4 m and more, on the back edge of the
    # floor under the third and fourth shafts: it lights the stair from below. One small dim
    # cluster further along the floor's back edge.
    A.deco("crystal_cluster_b", -427.6, FLOOR, z=-2.8, size=(4.0, 5.0, 3.0), tone="crystal")
    BRIGHT_LIGHTS.append((-427.6, 178.0))
    A.deco("crystal_cluster_c", -438.6, FLOOR, z=-2.1, size=(1.0, 1.5, 1.0), tone="back")
    # A mirror face behind the frozen climber: it shows his back, and you, small, walking past.
    mirror("mirror_facet", -444.3, FLOOR, -7.0, scale=1.1)
    # The second giant, further back, leaning the other way, a faint light inside it.
    giant(-421.5, FLOOR, scale=0.9, rot=-10.0, z=-7.5)
    # His coil of old rope behind his feet (the only rope in the cave), the long shards of clear
    # glass round it (the mirror's sheared-off foot; also 3.2's), and the sixth shaft's broken point.
    A.deco("rope_coil", -444.7, FLOOR, z=-1.85, scale=1.2, size=(0.5, 0.2, 0.5), tone="bone")
    A.deco("gruta_glass_shard", -442.1, FLOOR, z=-1.85, rot=3.0, size=(1.8, 0.5, 0.8), tone="back")
    A.deco("gruta_glass_shard", -440.4, FLOOR, z=-1.95, rot=-5.0, scale=0.67, size=(1.8, 0.5, 0.8), tone="back")
    A.deco("gruta_glass_shard", -445.8, FLOOR, z=-2.0, rot=8.0, scale=0.56, size=(1.8, 0.5, 0.8), tone="back")
    A.deco("gruta_snapped_point", -439.3, FLOOR, z=-1.75, size=(0.9, 0.45, 0.5), tone="crystal")
    outcrop(-414.5, 184.2)
    outcrop(-437.0, 181.6)
    # Foreground: two dark points rising from the bottom left corner in front of the floor's own
    # thickness, their tips below its top, east of the hole (nobody can be behind them).
    dark_point("gruta_dark_point", -447.4, 172.0, -8.0)
    dark_point("gruta_dark_point", -445.6, 172.0, 10.0, s=0.74)

    # ============================================================ 3.2 El Espejo
    # The mirror crystal: clear, six-sided, 6 m thick and 30 m long, rooted where the back wall
    # meets the hall floor behind the stair, leaning west and out towards you as it rises: far
    # back and dim at its foot (-7 .. -4), close behind you at its top, ending in a point above the
    # top rest. Beside the slab it turns a flat broad face 2.6 m wide to the camera (-1.5 .. -1.3),
    # a mirror that climbs beside you; the five ribs carried on across its upper face to -2.6.
    A.deco("gruta_mirror_giant", -438.39, FLOOR, z=-4.15, size=(16.92, 27.6, 5.7), tone="back")
    # The slab you climb: its one face in the play space, deep indigo with a white glint, its
    # foot a fresh stepped break, its broken top edge rough (skin). The nubs: the worn ends of the
    # ribs, rough pale lilac, six-sided (skins).
    skin("gruta_mirror_slab", -445.8, -441.44, 190.01, 198.84)
    for x, y in _NUBS:
        skin("gruta_nub", round(x - 0.19, 2), round(x + 0.19, 2), round(y - 0.22, 2), round(y + 0.22, 2), tone="crystal")
    # The loose nub: the tip of one thin point with a small collar of its own.
    skin("gruta_nub", _NUB0[0] - 0.19, _NUB0[0] + 0.19, _NUB0[1] - 0.22, _NUB0[1] + 0.22, tone="crystal")
    nub_root(*_NUB0)
    # The top rest: the broken end of a fat pale shaft, its west lip glass under the drip (skin);
    # its fan on a collar it shares with the mirror crystal's point.
    skin("gruta_rest_r2", -448.0, -444.88, 196.3, 198.7, tone="crystal")
    fan(-446.5, 197.4)
    # The bright crystal that lights the face, on the wall east of the mirror's top.
    bright(-437.0, 197.6)
    # One more giant on the west side, far back and blue.
    giant(-452.3, FLOOR, scale=0.75, z=-7.5)

    # ============================================================ 3.3 Candelabros
    # The three sockets the threads hang in: knobs of clear crystal with a round cup, polished
    # bright where the top knuckle turns (skins of the bosses).
    for x in _CHAND:
        ry = roof_w(x)
        skin("gruta_worn_socket", x - 0.39, x + 0.39, round(ry - 0.35, 2), round(ry + 0.55, 2))
    # The drip seam going back along the roof: younger threads hang from it behind yours, short,
    # two with a small cluster that glows (origin: the middle of each top, in the roof).
    for x, ln, lit in ((-449.8, 1.2, False), (-440.8, 2.2, True), (-434.8, 1.6, True), (-428.6, 0.9, False)):
        if lit:
            A.deco("gruta_young_thread_lit", x, round(roof_w(x), 2), z=-4.0, scale=round(ln / 2.2, 2), size=(0.9, 2.6, 0.9), tone="crystal")
        else:
            A.deco("gruta_young_thread", x, round(roof_w(x), 2), z=-4.0, scale=round(ln / 1.2, 2), size=(0.3, 1.2, 0.3), tone="back")
    # Roof points behind the threads: short thick clear points, 0.7 to 1.5 m, none near a swing.
    for x, ln in ((-447.6, 1.3), (-445.4, 0.8), (-441.9, 1.5), (-439.6, 0.9), (-436.0, 1.2), (-433.4, 0.8), (-430.0, 1.4), (-428.9, 0.7)):
        roof_point(x, round(roof_w(x), 2), s=round(ln / 1.5, 2))
    # A mirror face below the second and third chandeliers: their lights swing in it, and you.
    mirror("gruta_mirror_wide", -435.0, 197.6, -8.0)
    # The rest you land on: R3 with its frosted west face (skin), and its fan.
    skin("gruta_rest_r3", -427.65, -423.88, 206.6, 208.8, tone="crystal")
    fan(-425.75, 207.6)
    # The point of one more giant further east, below you (the mirror crystal's is 3.2's).
    giant(-427.6, FLOOR, scale=0.75, z=-7.8)
    outcrop(-433.0, 207.6)

    # ============================================================ 3.4 La Geoda
    # The nest: a round hollow in the back wall a little bigger than the geode and straight
    # behind it, worn smooth as a bowl, a bright polished line where the two rub, and at its
    # middle the round socket the geode's knob turns in, worn mirror-bright.
    A.deco("gruta_geode_nest", -420.4, 206.35, z=-3.8, size=(7.5, 7.5, 1.6), tone="back3")
    # The spar: a thin flat shard snapped off short over the geode's crown (skin), and its fan.
    skin("gruta_spar", -419.6, -417.0, 213.7, 214.4, tone="crystal")
    fan(-418.3, 214.05, s=0.53)
    # R4 (the needles' first rest, also 3.5's): the end of a fat pale crystal, its frosted east
    # face the way back up from the raft's berth (skin), and its fan.
    skin("gruta_rest_r4", -417.0, -413.35, 213.0, 214.4, tone="crystal")
    fan(-415.5, 213.6)
    # The nub under it (3.5 and 3.6: from the raft's berth up to R4's face), the tip of a thin
    # rough crystal from the wall, just above the knot at the rail's low end.
    skin("gruta_nub", -413.49, -413.11, 212.18, 212.62, tone="crystal")
    nub_root(-413.3, 212.4)
    # The bright crystal over the way out (also 3.5's, over its first rest): the brightest place
    # in the frame while you wait for the gap.
    bright(-417.3, 216.6)
    # A mirror face low and to the east: it shows the geode's underside going round.
    mirror("gruta_mirror_wide", -415.5, 202.6, -5.0)
    outcrop(-410.8, 208.2)

    # ============================================================ 3.5 Agujas
    # The same crack higher up, climbing east under the roof, its rib the only near part of the
    # back wall here: both rests and both middle needles root in it.
    back("gruta_crack_agujas", -419.0, -380.0, 210.6, 224.1, -1.6, -3.0, tone="back3")
    # The four needles (skins): the points rough pale lilac, the shafts clear indigo glass.
    skin("gruta_needle_first", -414.85, -413.35, 214.4, 217.0)
    skin("gruta_needle", -407.65, -406.55, 214.0, 220.5)
    skin("gruta_needle", -398.65, -397.55, 216.8, 223.3)
    skin("gruta_needle_last", -387.65, -386.4, 222.3, 224.5)
    # Behind the waist of each middle needle: a second crystal as thick as the needle running
    # straight back into the rib, a small fan where it enters the rock (origin: below its middle).
    for x, y in ((-407.1, 217.25), (-398.1, 220.05)):
        A.deco("gruta_cross_arm", x, round(y - 0.8, 2), z=-2.75, size=(1.6, 1.6, 3.0), tone="back")
    # R5 (also 3.6's): the end of a fat pale crystal, the last needle grown up out of it (skin).
    skin("gruta_rest_r5", -387.7, -383.08, 220.7, 222.3, tone="crystal")
    fan(-385.5, 221.4)
    # The raft's rail (also 3.6's): one long straight clear crystal as thick as a thigh lying along
    # the back wall, 24 m west and 4 m down, polished bright along its top where the raft rides,
    # with the knot under the first rest where a second crystal crosses it. Glass, behind you.
    A.deco("gruta_rail_crystal", -398.7, 206.9, z=-1.55, size=(29.4, 5.66, 0.5), tone="back")
    # Three giants in the bay, standing on La Rampa well back, their points level with your feet
    # between the needles, leaning away.
    giant(-409.0, round(slide_y(-409.0), 2), scale=1.15, z=-7.5)
    giant(-402.5, round(slide_y(-402.5), 2), scale=1.13, z=-7.5)
    giant(-392.5, round(slide_y(-392.5), 2), scale=0.95, z=-7.5)
    # A mirror face on the bay's back wall below your second fling: you crossing, very small.
    mirror("gruta_mirror_wide", -402.3, 209.6, -7.0, scale=1.1)
    # The bright cluster over the last rest (the first's is 3.4's): the middle is the dimmest.
    bright(-383.4, 224.6)
    outcrop(-392.0, 228.6)
    outcrop(-410.4, 224.4)

    # ============================================================ 3.6 El Prisma
    # The crack climbing steeply with its rib; the eight leaves are the tips of plates grown out
    # of it edge-on in two rows, and where each snaps at the wall its broken root stays.
    back("gruta_crack_prisma", -385.4, -375.4, 221.4, 232.0, -1.6, -3.0, tone="back3")
    for i, (x, y) in enumerate(_LEAVES):
        # The leaf (skin): pale crystal, a little see-through, crazed with white cracks, a corner
        # gone, the missing corner swapping sides from leaf to leaf.
        skin("gruta_crazed_plate", round(x - 0.5, 2), round(x + 0.5, 2), round(y - 0.26, 2), y, tone="crazed", flip=(i % 2 == 1))
        A.deco("gruta_leaf_stump", x, round(y - 0.28, 2), z=-1.45, flip=(i % 2 == 1), size=(1.0, 0.3, 0.3), tone="back")
    # The Prism: one clear six-sided crystal 10 m long lying along the wall on its side at La
    # Rampa's angle, a point at its upper end, rooted along its whole back; its top face, scratched
    # west by everything that slid there, is the plate in the play space (skin).
    A.deco("gruta_prism", -379.41, 211.83, z=-2.625, size=(10.38, 8.01, 2.75), tone="back")
    skin("gruta_prism_face", -384.6, -376.2, 213.16, 219.84)
    # The bright crystal behind the Prism, low, seen through it as a blur of white: it throws the
    # colours (the rainbow fan is a3.py's effect: FOR THE AREA FILE 8).
    bright(-378.8, 212.4, z=-4.5)
    # R6 (also 3.7's): its east lip glass (skin), and its fan.
    skin("gruta_rest_r6", -377.32, -369.1, 230.2, 231.8, tone="crystal")
    fan(-373.2, 230.9)
    # A mirror face east of the leaves (you watch them break in it), and below it a giant's point.
    mirror("gruta_mirror_wide", -371.2, 221.6, -5.0)
    giant(-369.85, round(slide_y(-369.85), 2), scale=0.5)
    outcrop(-367.5, 236.0)

    # ============================================================ 3.7 Pendulo de Cuarzo
    # The swept band: on the back wall behind the swing, a band 1.2 m wide along the quartz's
    # path, its small points short and all lying over the same way, the rock between polished.
    A.deco("gruta_swept_band", -360.0, 227.8, z=-3.0, size=(17.8, 3.94, 0.4), tone="back2")
    # The roof crystal the pendulum hangs from, its tip worn into a cup where the thread's ball
    # sits, polished mirror-bright (skin), and the long glass fin east of it over R7 (skin); each
    # carrying back to the wall, wider behind than in front (origin: the middle of its top).
    skin("gruta_pivot_crystal", -360.66, -359.26, 242.5, 249.0)
    A.deco("gruta_pivot_crystal_back", -359.95, 249.0, z=ROOT_Z, size=(3.9, 5.4, 1.75), tone="back")
    skin("gruta_roof_fin", -349.3, -348.7, 236.8, 249.0)
    A.deco("gruta_roof_fin_back", -349.0, 249.0, z=ROOT_Z, size=(2.2, 10.8, 1.75), tone="back")
    # The bright cluster hanging from the roof just west of the pivot (origin: its top).
    A.deco("gruta_roof_cluster_bright", -363.4, 248.5, z=FAN_Z, size=(2.0, 2.0, 1.4), tone="crystal")
    BRIGHT_LIGHTS.append((-363.4, 247.4))
    # R7 (also 3.8's start): its fan; the little tree on it, where the white block was (note 32:
    # skin of the stump, cut to its outline, FOR THE AREA FILE 6d).
    skin("gruta_rest_r7", -350.92, -340.68, 230.2, 231.8, tone="crystal")
    fan(-345.8, 230.9)
    skin("gruta_bonsai", -349.3, -348.7, 231.8, 233.0, tone="crystal")
    # A mirror face below the swing, and one far spire standing on La Rampa under the east rest.
    mirror("gruta_mirror_wide", -359.9, 221.8, -6.0)
    A.deco("crystal_spire", -352.0, round(slide_y(-352.0), 2), z=-6.0, size=(2.0, 10.0, 2.0), tone="back")
    outcrop(-366.0, 240.2)
    outcrop(-354.0, 238.6)

    # ============================================================ 3.8 Techo de Vidrio
    # The glass ceiling (skin): clear indigo both faces, its top scored with scratches running
    # downhill; its broken tooth (skin); the six crusts of small rough lilac points (skins).
    skin("gruta_ceiling_slab", -342.5, -324.3, 233.82, 246.2)
    skin("gruta_tooth", -342.28, -341.92, 233.38, 234.18, tone="crystal")
    skin("gruta_crust_long", -340.98, -339.22, 234.7, 235.95, tone="crystal")
    for px in _PATCH_X:
        skin("gruta_crust", round(px - 0.505, 3), round(px + 0.505, 3), round(under(px) - 0.39, 2), round(under(px) + 0.39, 2), tone="crystal")
    # The slab carried straight back to the wall at the same thickness, and its root: a seam of
    # rough dark rock and small points along both faces where it enters the rock.
    A.deco("gruta_ceiling_back", -333.45, 232.43, z=ROOT_Z, size=(19.7, 15.11, 1.75), tone="back")
    # Each crust is the near end of a band of rough crystal lying across the underside back to the
    # seam (origin: the middle of its foot, under the patch; laid along the slab's 32 degrees).
    A.deco("gruta_crust_back_long", -340.1, round(under(-340.1) - 0.55, 2), z=ROOT_Z, rot=32.0, size=(2.1, 0.6, 1.75), tone="crystal")
    for px in _PATCH_X:
        A.deco("gruta_crust_back", px, round(under(px) - 0.55, 2), z=ROOT_Z, rot=32.0, size=(1.4, 0.6, 1.75), tone="crystal")
    # The bright cluster on La Rampa under the slab, well back: it throws each crust's shadow up
    # the glass, and lights the slope.
    A.deco("crystal_cluster_a", -331.0, round(slide_y(-331.0), 2), z=-4.25, size=(2.0, 3.0, 2.0), tone="crystal")
    BRIGHT_LIGHTS.append((-331.0, round(slide_y(-331.0) + 1.4, 2)))
    # A mirror face below the middle of the crossing: you hanging from the ceiling, small.
    mirror("gruta_mirror_wide", -335.8, 228.8, -6.0)
    # The landing: the hall's own rock frosted over, carried back to the wall, a few small
    # clusters on its back edge (3.8), and the bright one 3 m tall (3.9's: it lights the landing,
    # the foot of the chimney and the first collar).
    back("gruta_landing_back", -324.3, -309.0, 238.5, 241.5, -1.25, -3.0, tone="rock2")
    A.deco("crystal_cluster_c", -321.4, 241.5, z=-2.2, scale=1.2, size=(1.0, 1.5, 1.0), tone="back")
    A.deco("crystal_cluster_c", -319.9, 241.5, z=-2.4, size=(1.0, 1.5, 1.0), tone="back")
    A.deco("crystal_cluster_a", -316.0, 241.5, z=-2.4, size=(2.0, 3.0, 2.0), tone="crystal")
    BRIGHT_LIGHTS.append((-316.0, 243.2))

    # ============================================================ 3.9 La Columna
    # The column (also 3.8's): one clear six-sided crystal 2.6 m across standing on La Rampa 5 m
    # behind you and going up to the roof, a dim light running up inside it, worn into a shallow
    # waist polished mirror-bright where each collar rides (252.8, 257.6, 262.4).
    A.deco("gruta_column", -328.0, round(slide_y(-328.0), 2), z=-5.05, size=(2.6, 44.4, 2.6), tone="back")
    # The three collars: flat rings of clear indigo glass 7.6 m across with a hole 3.2 m, hanging
    # askew round the column at 32 degrees, high side west, east, west (the zigzag), each with
    # eight sheaths in its rim the spikes slide out of; the nearest edge just behind the play
    # space, at -1.25 (origin: the ring's centre, on the column's axis).
    for y, side in _COLLARS:
        A.deco("gruta_collar", -328.0, y, z=-5.05, rot=round(32.35 * side, 2), size=(7.6, 0.5, 7.6), tone="back")
    # The two shelves (skins): wide flat crystals grown out of the wall like balconies, frosted on
    # top, clear below (R8 with the glass that closes the slot under it), a fan under each.
    skin("gruta_shelf_r8", -324.3, -312.5, 245.2, 249.4, tone="crystal")
    skin("gruta_shelf_r9", -324.3, -313.4, 264.0, 266.0, tone="crystal")
    fan(-318.4, 248.6, s=0.8)
    fan(-319.0, 264.6, s=0.8)
    # The west horn (skin): the great horn's short twin, grown the other way from the same root.
    skin("gruta_west_horn", -332.0, -324.3, 265.5, 266.2, tone="crystal")
    # The chimney: the crack again, zigzagging up the corner beside the well's wall; the five
    # nubs the tips of thin rough crystals growing out of it (skins, and their thin points).
    back("gruta_crack_chimney", -312.4, -309.3, 242.6, 248.8, -1.6, -3.0, tone="back3")
    for x, y in _CHIM:
        skin("gruta_nub", round(x - 0.19, 2), round(x + 0.19, 2), round(y - 0.22, 2), round(y + 0.22, 2), tone="crystal")
        nub_root(x, y)
    # A mirror face east of the column between the shelves: in it a pair of spikes coming round
    # the back before it reaches the front.
    mirror("mirror_facet", -319.2, 252.6, -4.0, scale=1.15)
    outcrop(-313.5, 256.6)
    outcrop(-335.0, 258.0)
    # Foreground: two dark points rising from the bottom right corner, in front of the landing's
    # own rock and the well's wall, their tips below the landing's floor.
    dark_point("gruta_dark_point", -309.2, 238.0, 10.0, s=0.88)
    dark_point("gruta_dark_point", -307.4, 238.0, -5.0, s=0.65)

    # ============================================================ 3.10 El Salto del Pozo I (3 to 4)
    # The horn (skin): rough pale lilac end to end, six-sided, growth rings every few metres, a
    # clean point; and its thick end buried in a collar of dark rock and small points on the back
    # wall across the shelf (the west horn grows from the same root).
    skin("gruta_horn", -319.79, -304.6, 265.61, 271.5, tone="crystal")
    A.deco("gruta_horn_root", -320.4, 265.0, z=ROOT_Z, size=(4.6, 3.4, 1.75), tone="back")
    # The step down and the door's sill (skin): frosted to the well's edge, where it stops dead.
    skin("gruta_door_sill", -314.0, -306.0, 262.0, 264.25, tone="rock")
    # The breach carrying on behind: the door is a split a little over 2 m deep, the well's wall
    # whole again behind it; its cave-side edges crusted with small pale points, its well side
    # bare black rock.
    back("gruta_breach_back", -309.0, -306.0, 264.25, 278.0, -1.25, -3.5, tone="back3")
    # The bright crystal at the door, on the wall above the horn, pointing down: the horn a pale
    # spear against the well's black, the last white light before the garden's green.
    bright(-311.6, 273.9, rot=180.0)
    # The well (the mountain's shared structure, this stretch of it, 176 to 290; a2_dress.py has
    # it below): the back half of the round shaft, black wet rock with thin white runs of water and
    # no ledges, the darkest thing in the cave; far up it the one small pale dot of its mouth with a
    # faint grey shaft of light under it, gone before it reaches you.
    A.deco("gruta_well_back", -300.0, FLOOR, z=-3.875, size=(12.0, 114.0, 5.25), tone="back3")
    A.deco("gruta_well_dot", -300.0, 275.0, z=-6.4, size=(0.6, 10.0, 0.05), tone="bone")
    # East rim (the garden's side; the root that sticks out into the well, the three roots you
    # catch and the root sill are a4's course): the great root running back along the top of the
    # far door, and behind the roots you catch three more, each as thick as a thigh, mossy, too
    # thick to take (origin of each: its top).
    A.deco("gruta_root_great", -292.75, 278.55, z=-2.65, size=(7.5, 1.2, 2.7), tone="root")
    A.deco("gruta_root_thick", -293.52, 278.6, z=-2.0, size=(0.45, 14.6, 0.45), tone="root")
    A.deco("gruta_root_thick", -292.38, 278.6, z=-2.0, scale=0.9, size=(0.45, 14.6, 0.45), tone="root")
    A.deco("gruta_root_thick", -291.22, 278.6, z=-2.0, size=(0.45, 14.6, 0.45), tone="root")
    # The garden through the far door: the first mushroom, a small one (a bell mushroom, the
    # garden's scenery kind), a spore lantern's green light under it, glowing moss on the rock,
    # and one last small cluster of crystal, dull and grey, with roots grown round it.
    A.deco("gruta_bell_mushroom", -289.0, 264.0, z=-3.6, size=(3.6, 3.6, 3.6), tone="#C9B48E")
    A.deco("spore_lantern", -290.6, 264.0, z=-2.5, size=(0.6, 0.8, 0.6), tone="#8FE07A")
    A.deco("glow_moss", -288.3, 264.0, z=-2.0, size=(3.0, 0.3, 1.0), tone="#6FBF5A")
    A.deco("crystal_cluster_c", -292.6, 264.0, z=-2.2, scale=0.87, size=(1.0, 1.5, 1.0), tone="back2")
    outcrop(-316.0, 271.0)
    # Foreground: one dark crystal point in front of the well's west wall below the sill (solid
    # rock behind it), its tip 2.7 m under the sill; and on the east, the garden's first
    # foreground, a clump of fern in front of the garden floor's own rock, its tips below its top.
    dark_point("gruta_dark_point_tall", -308.0, 255.0, 2.0, z=2.0)
    A.deco("gruta_fern_clump", -285.5, 261.2, z=1.6, size=(2.4, 2.2, 0.05), tone="#5E9E48")

    # ============================================================ the roof prisms (3.0 to 3.10)
    # The six glass prisms hanging from the roof, out of the route's reach (the one at -426 the
    # curtain that stops a flight over the geode): clear indigo, big flat faces (skins), each
    # carrying back to the wall wider than in front (origin of the body: the middle of its top).
    for stem, x0, x1, y0, y1 in _PRISMS:
        skin(stem, x0, x1, y0, y1)
        long_ = (y1 - y0) > 6.0
        A.deco("gruta_roof_prism_back", round((x0 + x1) / 2, 2), round(y1 - 1.2, 2), z=ROOT_Z, scale=1.0 if long_ else 0.6, size=(3.0, 7.5, 1.75), tone="back")
