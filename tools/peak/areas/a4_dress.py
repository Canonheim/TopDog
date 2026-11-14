"""
EL JARDIN DE HONGOS, DRESSED: the scenery of all of biome 4, the mushroom garden (y 264 to 381),
from the eleven area pages (the frog's hut 4.0 and the ten challenges, with the well crossing
4.10, the join "4 to 5") in docs/peak/playtest/design/data/a4_areas.py and the biome's sheet
a4_biome.py (its `built`, `looks`, `layers` and `kit`, and its KIT_MORE pieces).
The join "3 to 4" is biome 3's: a3_dress.py placed, at this file's entry door, the great root
running back along the top of the door (`gruta_root_great`), the three thick roots down the back
of the door (`gruta_root_thick`: they are also 4.1's "great root down the door"), the first small
bell mushroom, a spore lantern, glow moss, one dull crystal cluster and the first fern clump. This
file leaves all of that alone. The join "4 to 5" is this file's 4.10 on the garden's side; the
temple's side of it (the door's stepped side, the first hall, the corbels, the chain bosses, the
banners, and the moss and sprouts drawn on the doorstep's stone) is the temple's (a5's) to place.

Parker, 11-13: the scenery mushroom is a SECOND KIND, the bell mushroom (tall, thin, a small pale
blue-green bell of a cap, in stands), and NOTHING ORANGE IS SCENERY: an orange cap always means
bounce. Every orange mushroom a4.py stands behind the climb today goes. The frog's hut has a SOLID
roof you can land on (a new solid: FOR THE AREA FILE 6a). Everything here is alive and grown:
the only made thing is the frog's hut and what is in it.

Scenery only: decos. Nothing here can be stood on or held. The course (the shell, the root beam
and its ropes, the stump, the caps and every throw, the rest shelves, the slime island and its
terrace, the vines, the column of spores, the wall cap and its bracket, the snails, the root arm,
the giant's cap, gills, strand, knob, brim, crown and warts, the two slime masses, the bridge
and its gusts, the root shelf, the knots, the puffballs, the sill, the post, the diving board
and the great cap) is a4.py's. The model list this file makes is docs/peak/models/a4_models.md.

Depth: the play space is z -1.2 .. 1.2. Everything here stands behind -1.25 or in front of 1.25,
except SKINS (skin=True): the painted earth and rock of the room's shell, the slime island and its
terrace, the two slime masses of 4.7, the giant's cap, the rest saucers, the stump, the mossy
mound, the root arm, the diving board and the hut's roof; each is the LOOK of course solids
(MODELLING_RUN rule 4) and fills them, z -1.2 .. 1.2.
From the back, the garden stands at: the far wall z -11.0 (one flat painted piece, the room's
whole outline); the floors, the ramp's bed, the east garden and the island's top carried back to
-10.75, the roof's underside carried back over the east half to -10.75; the bell mushroom stands
at -10 .. -6 (in the pocket of 4.4, in front of its back wall, -5.7 .. -3); the far ledge of young
bells -10 .. -8; the well's back half -7 .. -1.25; the pocket's back wall -6.5 .. -1.25 (its face
about 6 m back); the cove behind the snails -6 .. -1.5; the garden's last wall at the west door
-6 .. -1.25; the giant's cap carried back -6.8 .. -1.25 and its stalk -4.55 .. -1.25; the slot's
back wall of 4.7 -3.4 .. -2.6; the brow of 4.9 -3.4 .. -1.25; the curtain of 4.8 -3.0 .. -1.25;
stalks, roots, collars, pods and shelf fungi -3.5 .. -1.25. In front: nothing but four low fern
clumps and two small dark bell cards, each at a bottom corner below a floor's top, and the tuft
under the west door's sill (note 40).

Walls and masses (BRIEF.md "Walls and masses"; the sheet's `built`): rock and earth are PAINT.
Every wall, floor, roof and mass is ONE painted piece made for its place: damp earth and
root-bound rock in a few big planes with soft, leaning edges; its layers of dark earth and paler
rock, its roots, its moss and its seep stains are flat colour on those planes in three or four
tones, long wavy lines and bands running the length of the face; nothing painted narrows to a
point; no dark recess cut into a face. The few real breaks: a thick root standing out of a wall,
a ledge with shelf fungus on it, one hollow under an overhang with its shadow painted, a fallen
boulder. Slime is black and glossy and runs down in sheets (bands, never wedges). Behind each wall
and mass its own body carries on, darker, duller and cooler, never pale. The garden's walls carry
a few small mossy outcrops, each with the biome's own flat painted plant on it (a tuft of bell
sprouts and one fern frond: blue-green and cream, never orange). THIS BIOME IS DARK: every wall
must be judged in the garden's own green glow, where bands whose values sit close together vanish.

A deco's origin is the middle of its base (x and z) at its foot (y), unless its comment says
otherwise: things that hang (stalactites, the creeper mass, collars, the root knots, the hanging
roots, the hook lantern) have theirs at the middle of their top; a shelf fungus's is the middle
of its wall edge at its base (it grows toward +x, flipped toward -x); a bent stalk's is the middle
of its foot where it leaves the wall; a pod lamp's is the middle of its back where it grows out of
its stalk or root. For the long pieces (walls, floors carried back, the island's body) that means:
the middle of its x span, the bottom of its box, the middle of its depth. A deco's size is the
size its model is MADE at (the game rescales a landed model more than a quarter off); where one
model is used at several sizes, `scale` does it and the size is the model's own. `rot` is in
degrees, counter-clockwise as the camera sees it (a positive rot tips a thing's top to the west).

Shared pieces are placed once, in the first section that names them, and the other page is named
in a comment (the first shelf's stalk for 4.1 and 4.2, the pocket's back wall for 4.3 and 4.4, the
snail wall's lower shelves for 4.4 and 4.5, the frog garden's first stand and the root arm's knee
for 4.5 and 4.0, the bridge's anchor boulder for 4.7 and 4.8, the far ledge for 4.8 and 4.9, the
garden's last wall and its glow moss for 4.9 and 4.10...).

FOR THE AREA FILE (tools/peak/areas/a4.py; the fix thread's). Line numbers are a4.py's as of
2026-11-14 (the version with note 45's dark at 0.42 and the great cap's skin in).
  1. Call it: `import a4_dress` beside the other imports, and `a4_dress.dress(A)` after the
     course is built (before A.save()).
  2. Lights. The light loop (lines 501-512), the two doors' lights (514-515) and the puffballs'
     own (line 353) stay: they are the room's glow. Two of the loop's ORANGE entries lit orange
     things that are gone: (-194.0, 323.0) (the orange scenery mushroom on the east garden) and
     (-221.5, 338.6) (the giant, rust now, not orange): make both GREEN. Then add, all steady:
     one light per entry of `a4_dress.LAMP_LIGHTS` (x, y; the spore lantern pods, the pod bed and
     the pod nest): "#B8F08A", range 5, energy 0.9; `a4_dress.HUT_LIGHT`, the lantern by the hut's
     door, the one warm light on that floor: "#FFC27A", range 6, energy 1.2; `a4_dress.EGG_LIGHT`,
     the snail eggs in the cove: "#9CF07A", range 4, energy 0.8; one per `a4_dress.WEB_LIGHTS`
     (the web's three knots in 4.7's slot): "#A6FF9A", range 3.5, energy 0.7.
  3. Decos to take out: the whole props loop (lines 467-497: the giant, the eight orange
     `mushroom_cap_*`, the snail, glow moss, spore pods, the four `vine_leaf` at z -0.9 and the
     five `shelf_fungus` at z -1.0 and four `spore_lantern` at z -1.2, all of those last in the
     play space, and the five stalactites). This file places what the pages keep, out of the play
     space and at the kit models' made sizes. KEEP line 404, the great cap's skin deco
     (`shroom_great_cap`: this file does not place it again).
  4. Cards to take out, all of them: line 444 (the room's back wall at z -6: `jardin_far_wall`
     at -11 and the pieces carried back replace it), 445 (the card at -14), 447-453 (the fourteen
     orange-capped far and near trees: the bell mushroom stands), 455-458 (the nine stalk cards:
     each stalk is a model now; the one under L8, -264.5, goes: the page hangs L8 from a loop of
     root), 459 (the wall cap's bracket card: `jardin_bent_stalk`), 461 (the giant's stalk card:
     `jardin_giant_stalk`), 463 (the tree at z -3.2) and 464 (the card at the hall's foot).
  5. Skins. Each named solid takes `skin=` its stem; this file places every skin deco.
     a. The shell: every slab A.cave (line 90) makes for edge i of SHELL takes
        `a4_dress.SHELL_SKINS[i]`, and every corner filler it makes takes the skin of the edge
        after it (the filler made at the start of edge i takes edge i's). Edge 17 and its fillers
        take none (item 7a).
     b. The rest, by line: the root knee and the stump (lines 112-113) "jardin_root_stump"; the
        soft old cap under the frozen climber (line 124) "jardin_moss_mound"; L1 (line 121)
        "jardin_saucer_6"; L2 (144) "jardin_saucer_4"; L3 (163) "jardin_saucer_5"; the slime
        island (134-135) "jardin_island"; the terrace (136) "jardin_terrace"; the vine's knot
        (187) "jardin_root_knot"; the wall cap's bracket (192) "jardin_wall_cap_elbow"; the root
        arm's post and arm (229-230) "jardin_root_arm"; the giant's cap (243-244), its brim (248),
        its six gills and the last gill's slick top (250-256), the strand (257) and the knob (258)
        all "jardin_giant_cap"; the crown (247) "jardin_giant_crown"; the two warts that stay
        (item 6c) "jardin_shoulder_mushroom"; the east mass of 4.7 (284) "jardin_stalactite_mass";
        the west mass and L7 on it (285-286) "jardin_spur"; the exit's sill, the post and the
        diving board (391-393) "jardin_diving_board"; the hut's roof (item 6a) "jardin_hut_roof".
        L4 (193), the east garden's lip (228), the root beam and the sill at the entry (97, 100),
        the three root ends of 4.7 (288-289), L8 (311), the four knots (336-338) and the caps keep
        the fitted kit's look (fit_root_*, fit_gill_*, fit_shroom_cap_*).
  6. Course changes on the pages, for the fix thread (not scenery):
     a. 4.0 (note 41; Parker 11-13: "its roof is solid"): the hut's roof, a NEW solid in the play
        space, kind "rock" (moss: it grips, it does not throw), the page's dome (`_ROOF` in
        a4_areas.py): (-207.9, 320.1), (-207.7, 321.0), (-206.94, 321.68), (-205.5, 321.9),
        (-204.06, 321.68), (-203.3, 321.0), (-203.1, 320.1), (-204.0, 320.6), (-207.0, 320.6),
        skin "jardin_hut_roof". Hollow underneath: the room has 2.6 m of headroom (318 .. 320.6);
        its eaves 2.1 m above the floor, reachable from outside the door.
     b. 4.1, look only (Parker 11-13): the soft old cap under the frozen climber (line 124) is
        kind "cap", which paints it orange: make it kind "rock" (moss, green, no throw). Shape
        and place do not change. With the statue (line 125), place the moss blanket over his legs
        and one arm (`jardin_moss_blanket`, a4_models.md section 4) the way a3.py keeps the
        crystal shell with its statue.
     c. 4.6 (note 44): two little mushrooms on the shoulder, not five: WARTS[0], WARTS[2] and
        WARTS[4] go (lines 260-262); WARTS[1] and WARTS[3] stay, each skinned
        "jardin_shoulder_mushroom". The challenge's moves (lines 267-268) then run brim ->
        WARTS[1] -> WARTS[3] -> crown (gaps 2.8, 3.0, 2.8). And the crown (line 247) is kind
        "cap", which paints it orange: make it a dry cream kind ("gill"), shape unchanged.
     d. 4.8, look only: the bridge (line 308) keeps its line, sag and fifteen planks; its planks
        become shelf-fungus treads on two mycelium cords (item 8).
     e. 4.10, for the temple's file (a5.py), not this one: the stone beam is made 2.6 m longer,
        x -303.5 -> -300.9, same height, held like the rest; the two banners move from 0.4 m
        behind the chains to just behind the play space (z -1.3 .. -1.5).
  7. Found while dressing, not on a page:
     a. The room's west wall is the shared well's east wall, which st.json already has
        (x -294 .. -290, y 176 .. 262, 280 .. 364 and 380 .. 474). a4's slab for SHELL edge 17
        (x -294 .. -291, y 280 .. 364) lies inside it: two faces in one place, as a3 found on its
        side (its item 6f). And st's wall reaches x -290, so it stands 1 m into the hall's air
        (x -291 .. -290) from y 280 to 364. Suggest: edge 17 opens in A.cave's kinds (17: None),
        and whoever owns the shared structure trims its wall to x -291, or the shell's x moves
        to -290. The exit's sill (line 391, y 363.2 .. 364) also runs 0.8 m down into the top of
        st's wall at x -294 .. -290, and above the exit door a4's roof slab stops at x -291 while
        st's wall begins at y 380: the notch x -294 .. -291, y 378 .. 380 is open (a4 says its
        door is 364 .. 378, the well's gap is 364 .. 380). That wall's look is the shared
        structure's; nothing is skinned for it here.
     b. st.json's well cards (z -5, -4.1, -3.2, x -312 .. -288, y 170 .. 500) draw the well's back
        over the stretch `jardin_well_back` models (y 290 .. 390), and its -3.2 card stands at
        x -296.5 .. -288, in front of the great cap's stalk and this door's back wall: when they
        land, the shared structure's owner cuts the stretch 290 .. 390 out of those cards.
     c. 4.7: caps 2 and 4 (CHAIN, lines 293-298) reach x -242.99, 0.19 m into the west mass
        (x -249 .. -242.8); cap 1 sits 0.6 m down into the giant's slime shoulder. The page says
        cap 1 grows out of the shoulder and the wall caps out of the wall, so both may be meant;
        check they throw as worked.
     d. The kit sizes: a4.py's props were placed at sizes their landed models are not made at
        (glow_moss 3 x 0.3 x 1, made 1.0 x 0.18 x 0.9; spore_pod 0.8 x 1 x 0.8, made 0.36 x 0.5 x
        0.36; vine_leaf 1.2 x 0.8 x 0.2, made 0.6 x 1.6 x 0.16): the game was rescaling them.
        Here each is placed at its made size and sized by `scale`.
  8. Movers', ropes', zones' and holds' looks (the area file's; models in a4_models.md section 4,
     or a kit model to be re-made):
     - every cap that throws (the fitted kit's `fit_shroom_cap_a`, `_b`, `_thick`): note 37
       re-makes them orange with PALE SPOTS, no checks, the throwing face flat, the roundness in a
       rim that rolls down all round, cream gills underneath; the wall caps (4.4's, and 4.7's 2
       to 5) want the sideways cap, its rim rolling further on the low side. Note 36 (squash and
       spring, the stalk rocking) wants each bounce (A.bounce, line 59) to name the cap's model
       so it can squash it. `shroom_great_cap` is re-made too (note 46: spotted, a fat rolled
       rim drooping over the well, cream gills; the three faces' angles exact);
     - the vines (kind "vine": lines 99, 143, 162, 188, 335, 339-344) hang `vine_leaf` and grow
       from a knot with two leaves at the top (`jardin_vine_knot`), so no vine ends at a bare
       line on the rock; the last metre of each of the three lift vines (line 162) is furred gold
       with spores (`jardin_vine_end_gold`);
     - the bridge (line 308): its planks `jardin_bridge_tread` (a small flat cream shelf fungus),
       its rope two white mycelium cords (`jardin_mycelium_cord`, one segment 0.5 long);
     - the puffballs (line 352): the kit's `puffball` re-made with one small dark pore on its
       face like a pupil (note 45: each lights a pool round itself, the light out when it bursts);
     - the snails keep `snail_wall` (line 216).
  9. Effects (the pages'; a4.py's A.effect, lines 517-526, stay): a puff of spores from under a
     cap's rim each time it throws (the great cap the biggest, 4.10); the column of the lift
     dense and fast below 285 and thin and slow above, soft-edged, pale GOLD not orange, small
     leaves going round and up in it, and a soft rushing sound in it (4.3, note 38); each of the
     pod bed's five pods swelling a moment before it puffs, in turn (4.3); the bridge's two gusts
     as bursts of gold spores from the pod nest, a small puff 0.8 s before each, the curtain
     bellying the way the gust will blow, the treads lifting in the west one (4.8, note 38);
     slow drips of slime from the island's belly between the vines and a few leaves let go by
     the creeper, turning as they fall (4.2); drips down the snail wall and off each snail's
     foot (4.5); slime off the giant's rim, and a wet sheen moving a little on its cap (4.6); the
     web's three knots pulsing slowly from the bottom up (4.7); each puffball's pore turning
     slowly to face you, a burst a cloud of pale spores, a few spores lit as they pass a
     puffball (4.9); a croak now and then and a thin thread of smoke from the hut's chimney at
     (-203.9, 322.75) (4.0); spores drifting out of the west door over the well and stopping
     half way, drips down the well lit as they pass each door (4.10); drifting spores close to
     the camera (the sheet's foreground).
"""

# ------------------------------------------------------------------ the lines things stand on
FLOOR = 264.0          # 4.1's moss floor (the foot of the west hall)
GARDEN = 318.0         # the east garden's floor, where the frog lives
TERRACE = 333.6        # the island's mossy top
BACK = -10.75          # how far the floors, the ramp's bed, the island and the roof carry back
FAR_Z = -11.0          # the far wall
POD_Z = -1.55          # a pod lamp on the front of its stalk or root (front at -1.33)
BELL_TONE = "#6FA89A"  # the bell mushrooms' stand-in: mid blue-green, never pale
STALK_TONE = "#A89C7E"
ROOT_TONE = "root"


def ramp(x):
    """The slime ramp's top (a4.py's SLOPE_FOOT and its 0.70 rise); the same at every depth."""
    return round(264.0 + (x + 255.1) * 0.70, 2)


# The room's shell: the skin of each slab a4.py's A.cave makes for edge i of SHELL (FOR THE AREA
# FILE item 5a). Edges 16 (the exit door) and 18 (the entry door) are open. A corner filler takes
# the skin of the edge after it.
SHELL_SKINS = {
    0: "jardin_floor_hall",     # 4.1's moss floor
    1: "jardin_ramp",           # the slime ramp under 4.2 to 4.4
    2: "jardin_pocket_wall",    # 4.4's far wall: the wall cap's web drawn on it
    3: "jardin_floor_garden",   # the east garden's floor: the hut's rug and the stepping stones drawn on it
    4: "jardin_east_wall",      # the room's east wall
    5: "jardin_roof_east", 6: "jardin_roof_east",                     # the roof climbing west
    7: "jardin_roof_bridge",                                           # the roof over 4.7 and 4.8
    8: "jardin_roof_ojos", 9: "jardin_roof_ojos", 10: "jardin_roof_ojos", 11: "jardin_roof_ojos",
    12: "jardin_roof_ojos", 13: "jardin_roof_ojos", 14: "jardin_roof_ojos",   # 4.9's low ceiling and its dome
    15: "jardin_roof_west",     # the high roof over the west door
    # 17: none. The west wall is the shared well's east wall (st, x -294 .. -290): item 7a.
}

# Lights for a4.py (FOR THE AREA FILE item 2), filled by dress(): x, y of each.
LAMP_LIGHTS = []
HUT_LIGHT = (-207.25, 319.75)
EGG_LIGHT = (-223.5, 321.75)
WEB_LIGHTS = [(-239.5, 349.6), (-239.5, 353.4), (-239.5, 356.9)]

# 4.6: the five warts today (a4.py's WARTS); the second and the fourth stay (note 44).
_SH = (-0.689, 0.724)
_WARTS = [(round(-224.1 + _SH[0] * s + 0.07, 3), round(340.0 + _SH[1] * s + 0.07, 3)) for s in (1.3, 2.8, 4.3, 5.8, 7.2)]
# 4.2: the four vines' x (a4.py line 142).
_VINES42 = (-263.3, -258.3, -253.3, -248.3)
# 4.9: the seven puffballs (a4.py's EYES).
_EYES = [(-267.9, 359.5), (-278.8, 359.5), (-276.4, 361.5), (-270.8, 369.6), (-271.6, 363.2), (-281.6, 361.8), (-264.6, 364.3)]


def dress(A):
    LAMP_LIGHTS.clear()

    # ------------------------------------------------------------ helpers
    def skin(stem, x0, x1, y0, y1, tone="back", flip=False):
        """The look of course solids, filling them (z -1.2 .. 1.2)."""
        A.deco(stem, round((x0 + x1) / 2, 3), y0, z=0.0, flip=flip, size=(round(x1 - x0, 2), round(y1 - y0, 2), 2.4), tone=tone, skin=True)

    def back(stem, x0, x1, y0, y1, z_near, z_far, tone="back2"):
        """A piece behind the play space, from z_near back to z_far (origin: the middle of its foot)."""
        A.deco(stem, round((x0 + x1) / 2, 3), y0, z=round((z_near + z_far) / 2, 3), size=(round(x1 - x0, 2), round(y1 - y0, 2), round(z_near - z_far, 2)), tone=tone)

    def bell(x, y, h, z):
        """A bell mushroom, the scenery kind: a thin pale stalk and a small pale blue-green bell of
        a cap. From 6 m up it is the grown one (made 10 m tall, its cap 2.2 across); under that the
        young one (made 4 m, its cap 1.3), each scaled to its height."""
        if h >= 6.0:
            A.deco("jardin_bell_mushroom", x, y, z=z, scale=round(h / 10.0, 2), size=(2.2, 10.0, 2.2), tone=BELL_TONE)
        else:
            A.deco("jardin_bell_young", x, y, z=z, scale=round(h / 4.0, 2), size=(1.3, 4.0, 1.3), tone=BELL_TONE)

    def stand(bells, zs):
        for (x, y, h), z in zip(bells, zs):
            bell(x, y, h, z)

    def boulder(x, y, s, z):
        """A rounded mossy boulder (made 2.0 across, 1.5 tall)."""
        A.deco("jardin_mossy_boulder", x, y, z=z, scale=s, size=(2.0, 1.5, 1.8), tone="back2")

    def snail(x, y, s, z, rot=0.0, flip=False):
        """A giant snail asleep, drawn into its shell (made with a shell 1.8 across)."""
        A.deco("jardin_snail_asleep", x, y, z=z, rot=rot, scale=s, flip=flip, size=(2.4, 1.9, 1.2), tone="back")

    def stalk(top_x, top_y, foot_x, foot_y):
        """The stalk of a mushroom whose cap or saucer is in the play space: cream, a skirt part
        way up, its top spreading into a ring of gills under the cap; rooted 2 m back and leaning
        forward (its top 0.6 east of its foot and 1.7 nearer the camera), so the cap hangs over
        the path and the floor under it stays clear. Made at four heights, each scaled to fit."""
        h = top_y - foot_y
        if h <= 1.5:
            stem, made = "jardin_stalk_stub", (1.6, 1.0, 2.0)
        elif h <= 6.0:
            stem, made = "jardin_stalk_4", (1.8, 4.5, 2.0)
        elif h <= 12.0:
            stem, made = "jardin_stalk_10", (2.0, 10.0, 2.0)
        else:
            stem, made = "jardin_stalk_15", (2.0, 15.4, 2.0)
        s = round(h / made[1], 2)
        A.deco(stem, foot_x, round(foot_y, 2), z=round(-1.27 - s * made[2] / 2, 3), scale=s, size=made, tone=STALK_TONE)

    def pod_lamp(x, y):
        """A spore lantern pod growing out of the side of a stalk or root on a short neck (the
        kit's spore_lantern, grown sideways): pale green ribs, a cream collar. Lit."""
        A.deco("jardin_pod_lamp", x, y, z=POD_Z, size=(0.5, 0.6, 0.45), tone="#8FE07A")
        LAMP_LIGHTS.append((x, round(y + 0.1, 2)))

    def glow(x, y, w, z):
        """The kit's patch of glow moss (made 1.0 x 0.18 x 0.9), w metres across."""
        A.deco("glow_moss", x, y, z=z, scale=round(w, 2), size=(1.0, 0.18, 0.9), tone="#6FBF5A")

    def shelf(x, y, s, z, flip=False):
        """A shelf fungus growing out of a wall: cream and tan, dry, growth bands on top, gills
        under (origin: the middle of its wall edge at its base; made 1.8 out from the wall)."""
        A.deco("jardin_shelf_fungus", x, y, z=z, scale=s, flip=flip, size=(1.8, 0.45, 1.2), tone="#B5A27A")

    def stalactite(x, y_top, length, z):
        """A short thick mossy stalactite (made 1.3 across, 2.4 long; origin: the middle of its top)."""
        A.deco("jardin_moss_stalactite", x, y_top, z=z, scale=round(length / 2.4, 2), size=(1.3, 2.4, 1.3), tone="back2")

    def outcrop(x, y, z):
        """A small mossy knob of rock standing out of a wall toward the camera (origin: the middle of
        its back's foot, on the wall at z), and on it the garden's flat painted plant."""
        A.deco("jardin_outcrop", x, y, z=round(z + 0.2, 3), size=(0.9, 0.45, 0.4), tone="back2")
        A.deco("jardin_outcrop_plant", x, round(y + 0.45, 2), z=round(z + 0.25, 3), size=(0.6, 0.5, 0.04), tone="#6FA89A")

    def fern(x, y, z=1.6):
        """Foreground: one low flat painted card of dark fern fronds, below a floor's top."""
        A.deco("jardin_fern_low", x, y, z=z, size=(4.0, 1.7, 0.05), tone="#3F6B3A")

    def bell_card(x, y, z=1.7):
        """Foreground: one small bell mushroom as a dark flat painted card."""
        A.deco("jardin_bell_card_dark", x, y, z=z, size=(0.8, 1.6, 0.05), tone="#3F5E58")

    # ============================================================ the whole biome: far wall, shell, bodies
    # The room has no sky. Its far wall: one flat painted piece the room's whole outline, damp earth
    # and root-bound rock in long wavy bands, and painted on its lower half the forest going on,
    # bell stand behind bell stand, fading to blue-green (mid values: the green glow lifts them).
    A.deco("jardin_far_wall", -240.0, 258.0, z=FAR_Z, size=(108.0, 126.0, 0.3), tone="back3")
    # The shell, each piece painted for its place (skins of SHELL_SKINS: they fill the slabs and
    # fillers they dress). Floors: moss on top, thick and green, over dark earth with roots in it;
    # the ramp black slime running down in sheets over its earth bed; the walls and roof damp earth
    # and root-bound rock in big planes, wet and dark where the seeps run.
    skin("jardin_floor_hall", -291.02, -255.08, 261.0, 264.0, tone="rock")
    skin("jardin_ramp", -255.12, -213.46, 261.0, 291.94, tone="slick")
    skin("jardin_pocket_wall", -215.2, -212.2, 289.47, 318.02)          # the wall cap's mycelium web on its face (4.4)
    skin("jardin_floor_garden", -215.22, -189.98, 315.0, 318.0, tone="rock")   # the rug and five flat pebbles drawn on its top (4.0)
    skin("jardin_east_wall", -190.0, -187.0, 315.0, 346.02)
    skin("jardin_roof_east", -228.02, -187.0, 345.99, 372.67)
    skin("jardin_roof_bridge", -262.02, -226.61, 370.0, 373.0)
    skin("jardin_roof_ojos", -279.92, -261.98, 364.98, 378.02)           # the root lines running back from each knot drawn on it (4.9)
    skin("jardin_roof_west", -291.02, -276.9, 378.0, 381.0)
    # The floors and the ramp's bed carried back to the far wall, the bell stands standing on them
    # (the ramp's bed only to the pocket's back wall east of x -244); the east garden carried back.
    back("jardin_floor_back", -291.0, -255.1, 261.0, FLOOR, -1.25, BACK, tone="rock2")
    back("jardin_ramp_back", -255.1, -215.2, 261.0, 291.93, -1.25, BACK, tone="back")
    back("jardin_garden_back", -215.2, -190.0, 315.0, GARDEN, -1.25, BACK, tone="rock2")
    # The roof's underside over the east half, carried back to the far wall (from 346 at the east
    # wall up to 373 over the bridge), wet earth and roots painted along it.
    back("jardin_roof_back_east", -262.0, -187.0, 346.0, 373.0, -1.25, BACK, tone="back3")

    # ============================================================ the slime island (4.2 to 4.6)
    # One great slick mass, a spur of the mountain out of the back wall (skin): black slime running
    # down in sheets. Drawn on it: four seep cracks in its belly, one rising 2.4 m from each vine
    # with a line of moss in it and slime running from it (4.2); the gold fur of settled spores
    # over the column, x -241 .. -235 (4.3); on the snail wall, a stripe of fresh glossy slime
    # exactly as long as each snail's crawl, and over the first four a small flat patch of glow
    # moss (4.5: drawn flat, so nothing sticks out to reach for).
    skin("jardin_island", -266.0, -225.0, 288.0, 333.0, tone="slick")
    # The terrace on its top (skin): thick moss, and at its east end the mossy lip hanging over the
    # snail wall's top edge (4.5: the dry edge you pull up onto; the water comes out from under it).
    skin("jardin_terrace", -266.0, -224.6, 332.7, 333.6, tone="rock")
    # Its body carried back: the belly level at 288 for 6 m (4.2: "the roof you hang under carries
    # on 6 m back") then rising to the far wall; its west face; its top, the terrace, carried back to
    # the far wall, where the boulders and young bells stand.
    back("jardin_island_back", -266.0, -225.0, 288.0, TERRACE, -1.25, BACK, tone="back2")

    # ============================================================ 4.1 Sombreros
    # Two stands of bell mushrooms far back on the floor (6 to 13.5 m), a snail asleep on a boulder
    # beside the door, rounded mossy boulders along the foot of the far wall.
    stand([(-284.6, FLOOR, 8.0), (-283.5, FLOOR, 13.5), (-282.4, FLOOR, 10.0)], (-7.0, -8.6, -9.4))
    stand([(-265.6, FLOOR, 7.5), (-264.5, FLOOR, 10.0), (-263.5, FLOOR, 6.0)], (-7.4, -9.0, -8.0))
    boulder(-289.5, FLOOR, 1.25, -6.5)
    snail(-289.5, 265.88, 0.94, -6.5)
    for x, s, z in ((-287.6, 1.1, -9.3), (-285.0, 0.8, -9.6), (-281.4, 1.4, -9.2), (-278.2, 0.9, -9.6),
                    (-275.0, 1.25, -9.3), (-271.2, 0.85, -9.6), (-267.8, 1.5, -9.1), (-263.4, 1.0, -9.5)):
        boulder(x, FLOOR, s, z)
    # The great root lying along the floor 2 m behind the path, half under moss, humping up and
    # down: barrel-thick. Its near end broken off is the knee and the stump you climb (skin); it
    # comes down the back of the door as a3's thick roots (the join's).
    A.deco("jardin_great_root_lying", -274.7, FLOOR, z=-2.2, size=(21.4, 1.8, 1.6), tone=ROOT_TONE)
    skin("jardin_root_stump", -289.6, -285.4, FLOOR, 267.2, tone="root")
    # The four stalks, one behind each cap and the shelf, rooted on the great root and leaning
    # forward (the shelf's is the thickest: also 4.2's).
    stalk(-284.2, 264.75, -284.2, FLOOR)       # cap A
    stalk(-279.2, 268.1, -279.7, FLOOR)        # cap B
    stalk(-274.2, 271.6, -274.8, FLOOR)        # cap C
    stalk(-267.5, 275.4, -268.2, FLOOR)        # L1 (4.2 leaves from it)
    # L1, the family's eldest: an old cap turned up like a saucer, cream and dry, its gills on top
    # as fine lines running out from its middle, no orange left (skin).
    skin("jardin_saucer_6", -270.5, -264.5, 275.4, 276.0, tone="crazed")
    # The soft mound: a cap that fell off its stalk long ago, taken by the moss: a low green
    # mound, a little grey-brown rot at its edges, no orange, no spots; three pale bell sprouts
    # come up beside the frozen climber (skin; FOR THE AREA FILE 6b).
    skin("jardin_moss_mound", -280.4, -276.8, FLOOR, 265.4, tone="rock")
    # Glow moss on the great root, and the two lantern pods low on the stalks (the one floating
    # beside the shelf today moves onto the shelf's stalk), so the caps are lit from underneath.
    glow(-282.3, 265.45, 1.5, -2.2)
    glow(-269.6, 265.6, 1.5, -2.2)
    pod_lamp(-274.8, 268.3)
    pod_lamp(-268.2, 273.9)
    # Foreground: a fern clump and one small dark bell at the bottom right corner, below the floor.
    fern(-265.8, 260.0, z=1.7)
    bell_card(-263.1, 260.0, z=1.75)

    # ============================================================ 4.2 Lianas
    # Two stands of bell mushrooms far back, one on the floor and one on the back of the ramp, their
    # tops below the vines' ends (278.5).
    stand([(-261.6, FLOOR, 9.0), (-260.5, FLOOR, 12.0), (-259.6, FLOOR, 7.0)], (-7.0, -9.2, -8.2))
    stand([(-251.3, ramp(-251.3), 8.5), (-250.2, ramp(-250.2), 9.6), (-249.2, ramp(-249.2), 6.5)], (-7.6, -9.4, -8.0))
    # The rest of the creeper, one thick dim mass hanging from the belly's far part, 5 m back: far
    # enough and solid enough that nobody takes it for a fifth vine (origin: its top).
    A.deco("jardin_creeper_mass", -256.0, 288.0, z=-5.0, size=(20.0, 2.4, 2.0), tone="back3")
    # A snail asleep far back on the slope, stuck where it stopped, lying along the ramp's 35 degrees.
    snail(-246.4, ramp(-246.4), 0.94, -6.5, rot=35.0)
    # The four leaf collars where the cracks open in the belly, just behind each vine: a clump of
    # leaves 1.8 wide with an arm-thick root running back along its crack (origin: its top).
    for x in _VINES42:
        A.deco("jardin_leaf_collar", x, 288.0, z=-1.75, size=(1.8, 1.0, 1.0), tone="#4F7A45")
    # L2's stalk, short, rooted in the ramp (L1's is 4.1's).
    stalk(-242.5, 276.9, -242.9, ramp(-242.9))
    # L2, the shelf you land on: the same old saucer, smaller; the last half metre of its east lip
    # gold with spores, the step into the lift (4.3) (skin).
    skin("jardin_saucer_4", -244.5, -240.5, 276.9, 277.5, tone="crazed")
    # Glow from below: glow moss along the back of the floor, a spore pod glowing on the ramp.
    glow(-258.6, FLOOR, 3.0, -2.9)
    A.deco("spore_pod", -245.8, ramp(-245.8), z=-2.0, scale=1.2, size=(0.36, 0.5, 0.36), tone="#8FE07A")
    LAMP_LIGHTS.append((-245.8, round(ramp(-245.8) + 0.4, 2)))
    # Foreground: one fern clump at the bottom left, in front of the floor's rock face.
    fern(-270.4, 261.5)

    # ============================================================ 4.3 El Ascensor de Esporas
    # The pocket's back wall (also 4.4's): rounded damp rock about 6 m back, from the ramp up to
    # the island's underside (301.5) west of the snail wall and to the garden's height (318) east
    # of it, its top the island's belly carried forward to -1.25, its east end turning forward into
    # the pocket's east wall. Painted on it: the stain of years of spores, pale gold, a stripe
    # exactly as wide as the column (x -240.3 .. -235.7) from the ramp to 299.3, spreading where it
    # meets the roof (x -242.8 .. -233.2 at 301.5); slime running down its east part (4.4).
    back("jardin_pocket_back_wall", -244.0, -215.2, ramp(-244.0), GARDEN, -1.25, -6.5, tone="back2")
    outcrop(-243.0, 289.5, -6.5)
    outcrop(-232.6, 285.2, -6.5)
    # One stand of three bell mushrooms on the back of the ramp, well west of the column.
    stand([(-247.9, ramp(-247.9), 11.5), (-246.9, ramp(-246.9), 14.0), (-246.0, ramp(-246.0), 9.0)], (-8.0, -9.4, -7.4))
    # The pod bed: five barrel-fat spore pods in a row in a hollow of the ramp just behind where you
    # step in, under the whole width of the column; they puff in turn (made in place on the ramp's
    # 35 degrees; origin: the middle of its x span at the ramp's height at its west end).
    A.deco("jardin_pod_bed", -238.0, ramp(-240.3), z=-1.95, size=(4.6, 4.3, 1.3), tone="#8FB46A")
    LAMP_LIGHTS.append((-238.0, 277.0))
    # The knot of root in the middle of the gold fur that the three vines hang from (origin: its top;
    # the knot is made 2.3 across for 4.9's dome: here at 1.2).
    A.deco("jardin_root_knot_roof", -237.9, 301.5, z=-1.8, scale=0.52, size=(2.3, 2.3, 1.0), tone=ROOT_TONE)
    # L3's tall thin stalk, 15 m, from the ramp well clear of the column, a lantern pod under its cap.
    stalk(-233.0, 294.4, -233.6, ramp(-233.6))
    pod_lamp(-233.5, 292.2)
    # L3, the shelf at 295 (skin), the same old saucer.
    skin("jardin_saucer_5", -235.5, -230.5, 294.4, 295.0, tone="crazed")

    # ============================================================ 4.4 Rebote Doble
    # Three bell mushrooms on the back of the ramp in front of the pocket's back wall (it closes the
    # pocket 6 m back), to one side of the vine and stopping below its end; mossy boulders where the
    # wall meets the ramp.
    stand([(-225.6, ramp(-225.6), 11.5), (-224.4, ramp(-224.4), 12.2), (-223.4, ramp(-223.4), 9.0)], (-4.5, -4.6, -4.4))
    for x, s in ((-226.6, 1.0), (-222.0, 0.9), (-219.4, 1.1), (-216.6, 0.95)):
        boulder(x, ramp(x), s, -5.4)
    # The first cap's stalk: 10 m of it from the ramp, rooted 2 m back, its skirt near the top.
    stalk(-229.0, 291.6, -229.7, ramp(-229.7))
    pod_lamp(-229.5, 290.0)
    # The root from the frog's garden: body-thick where it leaves the east wall under the garden's
    # lip, arching 6 m out over the pit a little behind you, its tip turning forward into the knot
    # (the knot's skin). Its lantern pod above the knot.
    A.deco("jardin_root_arch", -218.28, 308.35, z=-1.86, size=(6.15, 5.0, 1.2), tone=ROOT_TONE)
    skin("jardin_root_knot", -221.5, -220.7, 308.05, 308.35, tone="root")
    pod_lamp(-219.6, 311.9)
    # The wall cap's bent stalk: short and thick, out of the wall below the cap and bending up to
    # it; its elbow is the wet bracket you see today (skin).
    A.deco("jardin_bent_stalk", -215.2, 295.6, z=-1.9, scale=1.7, flip=True, size=(1.3, 1.3, 0.7), tone=STALK_TONE)
    skin("jardin_wall_cap_elbow", -216.2, -215.2, 297.0, 300.2)
    # The shelf you are thrown to (L4) is a shelf fungus on the snail wall (the fitted kit's); two
    # smaller ones grow under it in steps, further back (also 4.5's).
    shelf(-229.5, 309.45, 1.06, -1.95)
    shelf(-229.5, 308.4, 0.67, -2.3)
    # Glow moss where the ramp meets the east wall.
    glow(-216.45, ramp(-216.45), 2.3, -2.6)

    # ============================================================ 4.5 La Baba
    # The forest across the gap: a stand of three on the frog's garden (also 4.0's first stand).
    stand([(-213.2, GARDEN, 9.0), (-212.2, GARDEN, 12.0), (-211.3, GARDEN, 7.0)], (-8.4, -9.5, -7.4))
    # The cove: the island's east face does not stop at the play space; it curves round east behind
    # the snails and joins the back wall, slick wall all the way up running with the same slime, its
    # top the same mossy lip (4 m of it along the cove).
    A.deco("jardin_cove", -225.15, 306.5, z=-3.75, size=(8.7, 27.1, 4.5), tone="slick")
    # Two more of the herd asleep on the cove wall, 4 m back.
    snail(-223.0, 327.4, 0.89, -4.25, rot=70.0)
    snail(-224.6, 313.8, 0.89, -4.25, rot=-20.0, flip=True)
    # The eggs: a clutch the size of footballs in a hollow of the cove wall, glowing faintly green:
    # the wall's lamp, the shells dark and round against their light.
    A.deco("jardin_snail_eggs", -223.5, 321.2, z=-4.0, size=(1.1, 0.8, 0.7), tone="#9CF07A")
    outcrop(-222.4, 331.0, -4.6)
    # The knee of root on the lip of the frog's garden that the root arm grows up from, the root
    # running on back into the moss (also 4.0's).
    A.deco("jardin_root_knee", -213.95, GARDEN, z=-1.9, size=(2.0, 2.5, 1.3), tone=ROOT_TONE)

    # ============================================================ 4.0 La Choza de la Rana
    # The forest: two more stands, the tallest behind the hut so it sits under a little wood, mossy
    # boulders at their feet (the first stand is 4.5's).
    stand([(-202.4, GARDEN, 13.0), (-201.2, GARDEN, 14.0), (-200.0, GARDEN, 10.5), (-199.0, GARDEN, 12.5), (-197.9, GARDEN, 8.0)],
          (-8.0, -9.5, -7.0, -8.8, -7.5))
    stand([(-194.6, GARDEN, 8.0), (-193.6, GARDEN, 9.6), (-192.7, GARDEN, 6.5)], (-8.0, -9.2, -7.2))
    for x, s, z in ((-214.0, 0.9, -9.4), (-209.8, 0.75, -9.0), (-203.6, 1.2, -9.6), (-199.6, 0.85, -9.3), (-195.8, 1.0, -9.5), (-191.6, 0.8, -9.0)):
        boulder(x, GARDEN, s, z)
    # Shelf fungus up the room's east wall in three steps, 11 m up (one hangs there alone today).
    shelf(-190.0, 328.5, 0.56, -1.9, flip=True)
    shelf(-190.0, 329.6, 0.83, -1.9, flip=True)
    shelf(-190.0, 330.9, 1.0, -1.9, flip=True)
    # The frog's snail, asleep beside the hut, 4 m back (the one that stands here today).
    snail(-196.4, GARDEN, 1.0, -4.0)
    # The frog's garden row: six knee-high bell sprouts in a straight row behind the hut on a strip
    # of turned moss, the only tidy thing in the garden.
    A.deco("jardin_sprout_row", -201.35, GARDEN, z=-3.0, size=(3.2, 0.45, 0.6), tone=BELL_TONE)
    # The hut: the back half of a hollow stalk, 3 m wide and 2.6 m tall inside, cream, a round
    # window in it, a round door of bark standing open against it at the west end. Cut away at the
    # front: you walk in along the floor. Its roof, the old stalk's own cap under a quilt of moss,
    # is a solid in the play space (skin; FOR THE AREA FILE 6a); the roof's back half carries on 2 m
    # back over the back wall, green moss shaggy at the eaves, a crooked chimney of hollow root.
    A.deco("jardin_frog_hut", -205.5, GARDEN, z=-2.0, size=(3.2, 2.8, 1.5), tone="#B8A882")
    skin("jardin_hut_roof", -207.9, -203.1, 320.1, 321.9, tone="rock")
    A.deco("jardin_hut_roof_back", -205.5, 320.1, z=-2.27, size=(4.8, 2.7, 2.0), tone="rock2")
    # The frog on a toadstool stool against the back wall; a shelf with three jars; a small clay
    # stove whose pipe goes up through the ceiling into the chimney (note 41: friendly, nothing more).
    A.deco("jardin_toadstool_stool", -204.95, GARDEN, z=-1.75, size=(0.5, 0.5, 0.4), tone="#C9B48E")
    A.deco("frog_sit", -204.95, 318.5, z=-1.75, size=(0.26, 0.26, 0.27), tone="accent")
    A.deco("jardin_jar_shelf", -206.0, 319.45, z=-2.4, size=(0.8, 0.4, 0.3), tone="back")     # origin: the middle of its foot line on the wall
    A.deco("jardin_clay_stove", -204.3, GARDEN, z=-2.15, size=(0.5, 2.6, 0.5), tone="#9A6A4A")
    # The lantern by the door: a spore pod on a hook of root at the west end of the back wall,
    # glowing warm, the one warm light on this floor, seen from the snail wall (origin: the hook's top).
    A.deco("jardin_hook_lantern", -207.25, 320.25, z=-1.5, size=(0.45, 0.7, 0.4), tone="#FFC27A")
    # The root arm (skin): an upright root grown out of its knee on the lip (4.5's), bending flat at
    # its top out over the gap: the way back to the shelf under the snail wall.
    skin("jardin_root_arm", -218.6, -214.15, GARDEN, 321.8, tone="root")
    # (The rug of woven mycelium and the five stepping stones are drawn on the floor's skin.)
    # Foreground: one fern clump at the east corner, below the floor; nothing stands in front of the hut.
    fern(-190.7, 315.6)

    # ============================================================ 4.6 El Hongo Gigante
    # The terrace's far side: three young bell mushrooms, mossy boulders along the back, a snail
    # asleep on one of them. (The orange mushrooms on the terrace today are gone.)
    stand([(-244.5, TERRACE, 4.2), (-243.4, TERRACE, 5.0), (-242.4, TERRACE, 3.8)], (-8.0, -9.0, -7.2))
    for x, s, z in ((-245.0, 0.9, -9.2), (-236.2, 1.1, -9.4), (-231.0, 0.9, -9.6), (-227.0, 1.2, -9.2)):
        boulder(x, TERRACE, s, z)
    boulder(-239.3, TERRACE, 0.8, -8.0)
    snail(-239.3, 334.8, 0.78, -8.0)
    # The giant's cap (skin, made to today's outline): a real mushroom, rounded, the same kind as the
    # caps that throw but very old: under its slime the orange gone to a dark rust, nearly black
    # where the slime is thick, a wet green-yellow sheen, faint ghosts of spots, slow drips from the
    # rim; nothing about it says bounce (Parker, 11-13). Only the raised dry cream things on it can
    # be held: the six gills hanging under its east half (the front ends of its gill plates), the
    # rolled dry brim of the east rim, and the knob on the end of the veil's wet dark shred.
    skin("jardin_giant_cap", -241.5, -221.28, 335.5, 346.2)
    # The crown: the flat top where the slime has run off and the skin has dried and cracked into
    # pale cream scales, the same cream as the gills and the brim (skin; FOR THE AREA FILE 6c).
    skin("jardin_giant_crown", -234.0, -230.0, 346.2, 346.5, tone="crazed")
    # The two little mushrooms on the slick shoulder, small, cream and dry (note 44: two, not five).
    for i in (1, 3):
        wx, wy = _WARTS[i]
        skin("jardin_shoulder_mushroom", round(wx - 0.235, 3), round(wx + 0.235, 3), round(wy - 0.27, 3), round(wy + 0.27, 3), tone="crazed")
    # The cap carried back (oval, 19 across, 8 front to back): its dome falling away behind the
    # crown, and its underside, the gills as plates running 5 m back to the stalk, cream and dry
    # under the east half (a pleated ceiling, lit from below), slimed black and stuck in sheets
    # under the west half.
    A.deco("jardin_giant_cap_back", -232.0, 338.2, z=-4.025, size=(19.0, 8.0, 5.55), tone="back")
    # The stalk: real, 5 m thick at the foot and 3 at the top, standing behind the play space so the
    # terrace stays open; wet and dark green with runs of slime; its skirt 4 m up, a torn frill (the
    # rest of the veil whose shred hangs from the rim). A lantern pod low on its east side, a patch
    # of glow moss on the terrace.
    A.deco("jardin_giant_stalk", -232.0, TERRACE, z=-2.92, size=(5.2, 7.4, 3.3), tone="slick")
    pod_lamp(-229.75, 335.1)
    glow(-241.7, TERRACE, 2.6, -3.0)
    # Foreground: a fern clump and one small dark bell at the bottom left, in front of the island's
    # rock, below the terrace's floor.
    fern(-243.7, 330.0, z=1.65)
    bell_card(-240.6, 330.0)

    # ============================================================ 4.7 Trampolin en Cadena
    # Three bell mushrooms on the terrace below the spur, their caps just under it.
    stand([(-251.2, TERRACE, 9.4), (-250.1, TERRACE, 10.3), (-249.0, TERRACE, 8.4)], (-8.0, -9.2, -7.4))
    # The two slime masses (skins): on the east the broad stalactite, a crack drawn along its foot
    # where the three root ends come out; on the west the spur out of the back wall, its mossy top
    # L7. Both black, glossy sheets with pale runs and slow drips, a wet ring round the foot of each
    # cap's stalk (4.7's play: "slime sheets on both walls").
    skin("jardin_stalactite_mass", -236.0, -230.0, 350.5, 370.5, tone="slick")
    skin("jardin_spur", -249.0, -242.8, 344.5, 361.0, tone="slick")
    # The slot's back wall: rounded wet rock joining the stalactite to the spur 3 m behind you, so
    # there is no black gap behind the caps. Spread flat on it the white mycelium web the caps are
    # the fruit of: its thick cords run cap to cap in the zigzag you bounce, thin strands between,
    # three knots in it green (lit: WEB_LIGHTS).
    A.deco("jardin_slot_back", -239.4, 344.5, z=-3.0, size=(6.8, 23.0, 0.8), tone="back2")
    # The four bent stalks, each out of a wall below its cap and bending up, its foot in the web.
    A.deco("jardin_bent_stalk", -242.8, 346.0, z=-1.65, size=(1.3, 1.3, 0.7), tone=STALK_TONE)
    A.deco("jardin_bent_stalk", -242.8, 353.5, z=-1.65, size=(1.3, 1.3, 0.7), tone=STALK_TONE)
    A.deco("jardin_bent_stalk", -236.0, 350.6, z=-1.65, flip=True, size=(1.3, 1.3, 0.7), tone=STALK_TONE)
    A.deco("jardin_bent_stalk", -236.0, 357.2, z=-1.65, flip=True, size=(1.3, 1.3, 0.7), tone=STALK_TONE)
    # The root down the stalactite's east face from the roof, leg-thick, going in under its foot:
    # the three root ends you hold are where it comes out again (origin: its top).
    A.deco("jardin_root_down_face", -229.6, 367.5, z=-1.6, size=(0.8, 17.0, 0.5), tone=ROOT_TONE)
    # Two short thick mossy stalactites under the spur, over the giant's west rim.
    stalactite(-247.5, 344.5, 2.2, -2.1)
    stalactite(-244.9, 344.5, 2.8, -2.1)
    # The boulder at the back of the top ledge with a lantern pod on it, the light you bounce up
    # toward (also 4.8's: the bridge's two cords are wound round it).
    A.deco("jardin_bridge_anchor", -247.75, 361.0, z=-2.05, size=(2.3, 1.7, 1.5), tone="back2")
    A.deco("spore_lantern", -246.75, 362.3, z=-2.0, size=(0.6, 0.8, 0.57), tone="#8FE07A")
    LAMP_LIGHTS.append((-246.75, 362.6))

    # ============================================================ 4.8 Puente de Micelio
    # The far ledge, on the far wall under the bridge and the low roof (also 4.9's): one long shelf of
    # mossy rock, its east part 8 m under the bridge, stepping up 2 m to the west; young bell stands
    # on it, seen from above (it tells you how high you are). Under it the wall drops away.
    A.deco("jardin_far_ledge", -267.0, 350.5, z=-9.0, size=(42.0, 3.6, 2.0), tone="back3")
    stand([(-263.6, 351.6, 3.4), (-262.5, 351.8, 4.6), (-261.5, 351.8, 2.9), (-252.7, 351.9, 4.0), (-251.6, 351.9, 4.8), (-250.6, 351.8, 3.2)],
          (-8.9, -9.2, -8.8, -9.0, -9.3, -8.8))
    # The curtain: a net of mycelium with holes a hand wide, hanging from the roof's stalactites to
    # the bridge, leaning back (3 m behind you at the top, touching the bridge's line at the bottom),
    # dim grey-green, plainly a sheet; its bottom edge grown thick is the bridge (4.8: "nobody built
    # the bridge"). The four short mossy stalactites it is draped from (the two long ones go).
    A.deco("jardin_curtain", -255.5, 356.5, z=-2.15, size=(14.0, 13.5, 1.75), tone="#7C8F78")
    for x in (-250.6, -254.2, -257.8, -261.2):
        stalactite(x, 370.0, 2.0, -2.4)
    # The pod nest in a pouch of the curtain under the bridge's middle: two fat pods (the east one
    # points east, the west one up and west) and three small ones. The gusts come from them.
    A.deco("jardin_pod_nest", -256.05, 356.7, z=-1.8, size=(2.6, 2.0, 0.9), tone="#8FB46A")
    LAMP_LIGHTS.append((-256.05, 357.8))
    # L8 is the bottom of a loop of root that comes down out of the low roof, leg-thick (not a
    # shelf on a 27 m stalk): the loop behind it.
    A.deco("jardin_root_loop", -263.45, 361.0, z=-1.8, size=(0.9, 4.0, 1.0), tone=ROOT_TONE)

    # ============================================================ 4.9 Los Ojos
    # (The far ledge and its west stands: the ledge is 4.8's.)
    stand([(-286.6, 353.6, 3.8), (-285.5, 353.7, 5.0), (-284.5, 353.8, 3.0), (-280.0, 353.9, 1.9), (-279.0, 353.8, 2.3),
           (-278.0, 353.6, 1.7), (-268.6, 354.0, 2.1), (-267.6, 353.9, 1.6), (-266.7, 353.8, 2.4)],
          (-8.8, -9.2, -8.9, -9.1, -8.8, -9.3, -9.0, -8.8, -9.2))
    # The brow: the back wall under the low roof, rounded dark rock hanging down to about 357 with a
    # ragged lower edge, carrying on up into the dome; the low roof's underside runs forward from it
    # to -1.25. In its face seven round hollows 1.9 across, one behind each puffball (_EYES), each
    # with the puffball's short neck coming out of its middle toward you; when one bursts its neck
    # stays. It is the dimmest place in the garden (note 45: dim, not black).
    A.deco("jardin_brow", -272.6, 356.2, z=-2.325, size=(21.2, 15.8, 2.15), tone="back3")
    outcrop(-265.6, 357.8, -2.2)
    # A thick root running down the brow's face between the sockets, flat on the rock (the other,
    # hanging free as a loop, is 4.8's L8). In the dome, the knot of root as big as a cart wheel that
    # the two catching roots hang from (origin of each: its top).
    A.deco("jardin_root_flat", -270.1, 365.0, z=-2.0, size=(0.7, 8.5, 0.4), tone=ROOT_TONE)
    A.deco("jardin_root_knot_roof", -273.75, 372.0, z=-1.8, size=(2.3, 2.3, 1.0), tone=ROOT_TONE)
    # The way out: past the brow the roof goes up again; the garden's last wall far and mossy with
    # the green glow on it (4.10's piece), one mossy stalactite hanging clear of the two roots you
    # catch there, and a thick root down the far wall under the high roof.
    stalactite(-281.6, 378.0, 2.6, -4.5)
    A.deco("jardin_root_hang", -286.5, 378.0, z=-2.0, size=(0.8, 14.0, 0.8), tone=ROOT_TONE)

    # ============================================================ 4.10 El Salto del Pozo II (4 to 5)
    # The well (the mountain's shared structure, this stretch of it, 290 to 390; a3_dress.py has it
    # below): the back half of the round shaft curving from rim to rim, 7 m back at the middle, slick
    # black rock with pale runs, lit green from the east and gold from the west (colour) so it shows.
    A.deco("jardin_well_back", -300.0, 290.0, z=-4.125, size=(12.0, 100.0, 5.75), tone="back3")
    # The band of thick roots that leaves the garden's rim, follows a crack round the back of the
    # well and reaches the temple's doorstep, three small pale bell mushrooms on it: far back, below
    # the chains' ends: how the garden got across (made in place along the shaft's curve).
    A.deco("jardin_root_band", -300.0, 362.0, z=-6.0, size=(12.0, 2.7, 2.0), tone=ROOT_TONE)
    # The garden's last wall: rounded mossy rock behind the cave mouth, nothing cut; the mouth's floor
    # carried back from the sill and the high roof's underside forward to -1.25 (also 4.9's way out).
    # Shelf fungus on it in three steps, glow moss at its foot (4.9's too).
    A.deco("jardin_door_back_wall", -286.95, 364.0, z=-3.625, size=(14.1, 17.0, 4.75), tone="back2")
    A.deco("jardin_shelf_steps", -286.3, 367.0, z=-5.4, size=(2.4, 2.8, 1.2), tone="#B5A27A")   # origin: the middle of its back's foot, on the wall
    glow(-286.4, 364.0, 2.4, -3.0)
    outcrop(-282.8, 371.5, -6.0)
    outcrop(-291.4, 367.4, -6.0)
    # The great cap's stalk: short and very thick (1.8), out of a crack in the well's wall 4 m below
    # the rim, behind the play space, leaning out and forward to hold the cap over the drop; its
    # skirt, and gills fanning out under the cap's west lip (the cap is a4.py's `shroom_great_cap`).
    A.deco("jardin_great_cap_stalk", -295.45, 359.2, z=-2.35, size=(2.9, 5.2, 2.2), tone=STALK_TONE)
    # The diving board's mother root: barrel-thick, down from the roof at the back of the cave mouth
    # and spreading into the sill; the post and the board are one branch of it turned toward the well
    # (their skin). A lantern pod grows on it above the board.
    A.deco("jardin_mother_root", -289.65, 378.0, z=-1.85, size=(1.2, 14.0, 1.1), tone=ROOT_TONE)
    skin("jardin_diving_board", -294.0, -283.2, 363.2, 370.5, tone="root")
    pod_lamp(-289.65, 373.4)
    # Foreground: one tuft from a crack in front of the solid rock under the garden's sill (a3's
    # flat fern card); nothing stands in front of the well, the chains or either rim.
    A.deco("gruta_fern_clump", -291.9, 357.2, z=1.6, size=(2.4, 2.2, 0.05), tone="#3F6B3A")

    # ============================================================ the hall's walls and roof (4.1 to 4.10)
    # The west hall's west wall (the well's, item 7a; its face is st's, at x -290): shelf fungus in two sets of steps out of it,
    # up the 100 m of the hall (a4.py's three brackets, moved out of the play space).
    shelf(-290.0, 300.0, 1.0, -2.0)
    shelf(-290.0, 298.9, 0.6, -2.4)
    shelf(-290.0, 328.0, 0.9, -2.0)
    shelf(-290.0, 327.0, 0.55, -2.4)
    # Two mossy stalactites under the roof over the east garden (a4.py's, made mossy).
    stalactite(-212.0, 361.65, 2.4, -2.4)
    stalactite(-198.0, 352.4, 2.6, -2.6)
