"""
LA CRESTA DE LA TORMENTA, DRESSED: the scenery of all of biome 10, the storm ridge (y 884 to 966), from
the eleven area pages (the join "9 to 10", the keeper's cabin 10.0 and the challenges 10.1 to 10.9) in
docs/peak/playtest/design/data/a10_areas.py and the biome's sheet a10_biome.py (its `built`, `looks`,
`layers` and `kit`, and KIT_MORE). The join "9 to 10" is shared with the glacier: a9_dress.py places the
glacier's side of the gap (the horn at the last climber's back, the last cane and its lantern, the slab
hole and the hollow, the glaze on the ledge's nose); this file places the ridge's side: the gap's far
wall of bared slate (in place of a9.py's "rimaye" card), the porch's look (the ledge is a9.py's solid),
the cabin and its frog, the nook, the prayer pole (moved 1.4 m east to the cabin's west corner, page
"9 to 10"), El Filo's body and collar, the cloud in the gap, the snow lip. The join "10 to 11" is page
10.9: our end is the ridge's last slate (the exit ledge as the ridge's last slab, the rungs, the bolt
holes); the summit's teeth, pillars and back that stand behind the top of this biome, the exit ledge's
top and its tea shop (note 97) and the whole bright paper line over it are the summit's.

Parker, 11-13 (notes 89, 92, 94 to 96): "storm clouds do look bad": the six flat grey cards in front of
the climb are gone (the fix thread, 228c364) and CLOUD IS PAINTED AS CLOUD, BEHIND THE CLIMB: a collar
2 m back across the lower end of each free tower's body, banks 7 m back between the towers, one bank
1.5 m back behind La Nube, and its top strip 1.3 m back; nothing made of cloud stands in front of where
a climber can be. "make it a little cabin with a frog in it" (94): the keeper's cabin on the first
ledge, cut away at the front, its frog in a yellow rain hat at the table under the lamp. Lightning (95):
steel looks like steel and timber like timber (pale blue-grey thin round steel with rivets; honey timber
thick and square; white porcelain at every joint, on the timber's side); the sparks, the drawn bolt and
the tint are the game's. "make the weather balloon only have one rope" (96): one rope from the middle
of the basket (the course has it); its look and the balloon's neck are below. Wind (89): every band has
its flag where the route crosses it (the papers on the lines, torn ends on the posts, grey canvas socks
on stubs, the cabin's smoke, the kites' tails). Designers' own answers Parker did not object to
(ANSWERS.md): the balloon's neck solid; a broken rung swings back up; torn paper ends behind Gendarmes.
NOTHING CLIMBER-SHAPED IS MODELLED until the new climber model lands (MODELLING_RUN): the one who waited
on the station's deck stays the game's statue (a10.py line 335); no deco stands in for him.

The walls rule (BRIEF.md "Walls and masses", walls_example_after.png) for slate: the face, El Alero and
every tower are wet slate in a few big leaning planes, blue-black and glossy; the cleavage is flat colour
on those planes in three or four blue-black tones, long wavy lines and bands that run the way the face
leans (71 degrees, to the west); nothing painted narrows to a point; no dark recess cut into a face; NO
RAIN PAINTED ON ANY ROCK (the rain is the effect in the air). Dry slate (pale warm grey, matte, broken in
square steps) only on the flat tops of towers and on the scars; quartz knobs plain white blocks, dry and
matte, a hand's width of dry slate round each. The few real breaks: El Filo's slab ends, the undercut
over each tower's pointed foot, the scars' crisp edges, the buttress's cap. Away from tops, scars and
knobs a tower's outline leans and is notched (up to 0.8 m off the course, never on the face: nothing on
the face may catch a falling body). The sheet names NO plants ("Never here: ... anything green"): no
outcrops and no plants on this ridge. Each wall, mass and tower is one piece made for its place.

Scenery only: decos. Nothing here can be stood on or held. The course (the face, El Alero, every tower,
scar, knob, top and post, the pole, the lines, the station's deck and mast, the vane, the kites and their
tails, the balloon and its rope, the rungs, the exit ledge, the mass, the winds, the strike) is a10.py's.
The model list this file makes is docs/peak/models/a10_models.md.

Depth: the play space is z -1.2 .. 1.2. Everything here stands behind -1.25 or in front of 1.25, except
SKINS (skin=True), each the LOOK of course solids. A skin of a tower or a mass fills its solid (z -1.2 ..
1.2); a tower whose top carries things at its back (El Filo, La Torre and its needle, the two lone
towers) carries its TOP back to its body's face at -2.2 (its shaft and pointed foot stay -1.2 .. 1.2, so
the foot hangs in front of its collar); the buttress carries its top step back to the summit's pillar
(-1.8); the face, El Alero's underside and the porch carry back to the nook's wall (-3.4); the ridge's
mass and the slide's tunnel through it to the tunnel's back wall (-2.4); the station's deck carries back
under the hut (-3.4). A small hold's skin is the depth the game draws it (a knob z -0.3 .. 0.3, a rung
-0.2 .. 0.2); the mast's steel is drawn thin and round (the game's slim-bar look) and its timber 0.6
square with each crossarm running back to -1.2 as the front of its yard; the porcelain stacks sit 0.2 to
0.6 forward on the timber (the sheet's foreground note: inside the play space, as part of the timber's
skin). From the back: the ridge's far towers, ONE flat painted card 14 m back (z -14.2 .. -14.0), east
of the face (behind it is what is given: the storm's deck, the sea of cloud, the valley's last strip);
the cloud banks between the towers -7.6 .. -6.9; the nook's back wall -4.0 .. -3.4 and the cabin -3.4 ..
-1.25 in it; the ridge's flank -3.6 .. -3.0 behind the open air east of the face (897 to 941.6); the
towers' bodies -2.95 .. -2.2; the gap's far wall and the slide tunnel's back -2.6 .. -2.4; the vane's
mast and its head -2.8 .. -1.25; the cloud collars -2.1 .. -1.75; the hut -3.4 .. -1.4 with its sign,
gauge and lantern to -1.32; the yards and the nest's stage -3.65 .. -1.25; the reels -2.2 .. -1.85; La
Nube's bank -1.6 .. -1.5, the cloud's top -1.36 .. -1.34, the rib -1.35 .. -1.25; the winch, the guide
post and the fallen rungs -1.75 .. -1.3; the cable -1.43 .. -1.28; the socks, stubs, braces, cradle and
torn ends between -1.25 and -2.6. In front: ONLY the lip of drifted snow on the porch (z 1.25 .. 1.55,
0.28 m above the snow). No cloud, mist, tower, post, line or cable passes in front of the climb.

A deco's origin is the middle of its base (x and z) at its foot (y), unless its comment says otherwise:
wall-mounted things (the wind slate, the bolt sign, a reel) the middle of their back on the wall (a reel
its centre); `lantern_hang` its hook; a sock its base as the kit's `wind_sock` (its eye 0.45 east and
1.44 up; it streams west unless flipped); a cable, a brace and the dial's hand their middle (the hand its
pivot), laid by `rot`; a headwall rung the middle of its bar's x span, 0.18 under the bar (its plate on
the face reaches 0.18 above and below it). For the long pieces (walls, skins, bodies, cards, clouds):
the middle of the x span, the bottom of its box, the middle of its depth. A deco's size is the size its
model is MADE at (the game rescales a landed model more than a quarter off; skins are never rescaled);
where one model is used at several sizes, `scale` does it and the size is the model's own (the quartz
knob is made to a hold of r 0.24 and scaled to La Nube's 0.28; the collars are made at three widths and
scaled to each tower's). `rot` is in degrees, counter-clockwise as the camera sees it.

Shared pieces are placed once, in the section of the page that designs them: the porch, the cabin, the
nook, the prayer pole (9 to 10, 10.0, 10.1: in 10.0); El Filo's body and collar (9 to 10, 10.0, 10.1: in
10.1); the pole's cradle and brace (10.1, 10.2: in 10.1); the station's body, collar and the vane's mast
(10.2, 10.3, 10.4: in 10.2); the hut (10.2, 10.3: in 10.3); the nest's stage (10.3, 10.4: in 10.3); La
Torre's body and collar, the shoulder's sock (10.4, 10.5: in 10.4); the reels, the first lone tower's
body and collar, the needle's and the first tower's torn ends (10.5, 10.6: in 10.5); La Nube's bank, rib
and the cloud's top (10.6 to 10.9: in 10.7); the winch, its post and sock, the buttress's top step (10.8,
10.9: in 10.8).

FOR THE AREA FILE (tools/peak/areas/a10.py; the fix thread's). Line numbers are a10.py's as of
2026-11-14 (the version with the frogs' slide cut through the ridge's foot, 4d0a921).
  1. Call it: `import a10_dress` after the peaklib import (line 23), and `a10_dress.dress(A)` after
     `_cut_passage()` (line 368), before `if __name__ == "__main__":` (line 371), so before A.save().
     After the call, the followers (item 8): `for st, near, mv, how, kw in a10_dress.FOLLOWS:
     A.follow(st, near, mv, how, **kw)`.
  2. Lights. The sheet's only warm light is the cabin's (stove and lamp, as colour on its walls): add
     a10_dress.CABIN_LIGHTS (x, y, z, colour, range, energy; both flicker). Take out the cold light on
     the porch (line 337, its first point (-304.5, 889.5)): the cabin's amber takes its place. KEEP the
     other cold rest lights (337-339), the mast's white flash (340), La Nube's (341) and the warm top
     (342). No lamp outside the cabin is lit (the station's `lantern_cold` is dead).
  3. Decos to take out (this file places what the pages keep, out of the play space): lines 314-316 (the
     three `papel_line`s at z -0.4: straight chords in the play space while the ropes sag; the game draws
     each banner rope's own paper, which is the hold), 317 (`papel_tatters` at -0.5: the torn line's
     paper is the rope's own, all 4.3 m of it, page 10.0), 318-320 (the three whole paper lines behind the
     flights: notes 4 and 18, "a whole prayer line is always a hold"; they become torn ends here), 321
     (the paper line over the exit ledge: the summit's page takes it down and hangs its own), 322-323
     (the four `prayer_flag`s at -0.3: here 1.3 m back as torn ends), 325 (the hut at -1.4, 0.4 m into
     the play space: here at -2.4, re-made with its burnt roof), 326 (the rain gauge at -0.9: here 0.6
     back), 327-329 (the three insulators at z 0.4: the seven porcelain stacks are the mast timber's
     skin), 330 (`vane_mast`: here 0.2 m east under the hub and 2.5 m back, on its shoe), 332
     (`balloon_tether`: the slanting black cable here), 333 (`rung_stub` at z 0: cut down to two black
     nubs, paint on the face's skin), 334 (`sign_pug_arrow` at -1.0 behind the first rung: its board is
     on the winch's guide post here). KEEP the statue (335).
     And in a9.py (the glacier's): line 424, the prayer pole at x -309, z -1.2 (placed here at the
     cabin's west corner, x -307.6, z -1.35: a9_dress item 3 left it to us).
  4. Cards to take out: 288-290 (the sky at z -30: block-out cards that stand in front of the given
     storm's deck, z -46 to -140, and hide its wall and far rows; the sky, the deck and the sea of cloud
     are given: item 7a), 294-298 (the three flat thunderheads at -20, -14, -10: the given deck's
     cut-outs drift there), 301 (the far crest at -4: the ridge's flank, the nook, the bodies and the far
     towers here; it also lay on the nook's back plane), 302-304 (the six tower root cards at -2.5: the
     bodies here, each ending in its collar), 309-311 (La Nube's three: the rib at z -1.2 on the play
     space's edge, the dark card and the grey card: the rib, the bank and the cloud's top here). KEEP 291-
     292 (the gold under-lit cloud at -24, the light above the storm) until the frames are judged. And
     in a9.py: lines 399-400 (the rimaye's rock in shadow at z -2.4): the gap's far wall is placed here,
     to the same outline, cut round the slab hollow and the slab mouth (a9_dress item 4).
     Effects: take out the clouds (line 344: "Nothing made of cloud ever stands in front of where a
     climber can be"; the cloud is painted here). KEEP the rain (343). The mist over La Nube (345) only if
     the game draws it behind the climb, between the bank (-1.5) and the rib (-1.25): "Thin wisps drift
     along the face of the bank, behind you. None of them ever crosses in front of you."
  5. Skins. Each named solid takes `skin=` its stem; this file places every skin deco.
     - The face (line 51): split the wall at (F(923), 923) (the same line, so the same slabs) and give
       it skins={0: "tormenta_face_low", 1: "tormenta_face_high"}; the passage cut (350-368) copies the
       skin onto the cut pieces.
     - The ridge's mass (283) and its top (284), and a9.py's "ridge's rock behind it" (a9 line 95):
       "tormenta_ridge_mass" (one piece for the three).
     - El Alero (53): "tormenta_alero" (with the torn line's spar let into its underside).
     - The porch, a9.py's ledge at 886 (a9 line 94): "tormenta_porch". (Its glazed nose, a9 line 97,
       keeps a9's `glaciar_verglas_nose`.)
     - The exit ledge (55): "tormenta_exit_slab".
     - El Filo: the blade (76), its scar (80) and its top (86): "tormenta_filo"; the eight knobs (84,
       89, each A.hold): "tormenta_quartz_knob".
     - The line pole (102): "tormenta_line_pole".
     - La Aguja: tower() (103) and its spire (104): "tormenta_aguja". tower() (37-40) wants a `skin=`.
     - The station's tower (125): "tormenta_station_tower"; its deck (126): "tormenta_station_deck".
     - The mast's timber, the crossarms and the nest (129-131), the four sleeves (134, 142):
       "tormenta_mast_timber" (one piece, with the seven porcelain stacks). Its steel, ONE SKIN EACH
       (the game gives a tagged solid the nearest skin deco of its stem within 3 m, one each): the three
       bare spines (135) "tormenta_mast_spine", the six rungs (137) "tormenta_mast_rung", the tip (143)
       "tormenta_mast_tip". The strike's tint (METAL_LIT) and the sparks must reach the skins (the skin
       is the piece's child: check in a frame).
     - La Torre: the block (166), its scar (167), the shoulder (168), the needle (169), the needle's scar
       (191) and its top (194): "tormenta_torre"; the needle's two knobs (192, 193):
       "tormenta_quartz_knob".
     - The three line posts (216, 220, 224): "tormenta_line_post" (one each).
     - The first lone tower (B): tower() (217), its top (218) and scar (219): "tormenta_lone_tower_east".
       The second (C): 221, 222, 223: "tormenta_lone_tower_west".
     - The buttress (227), its scar (228), its foothold (229) and the top step (270): "tormenta_buttress".
     - La Nube's five knobs (244): "tormenta_quartz_knob".
     - The headwall's rungs (273): the two "iron" "tormenta_rung", the two "rotten"
       "tormenta_rung_rusted".
  6. Course changes the pages ask for (not scenery):
     a. 10.8 (the page's ask; the designers' own answer, ANSWERS.md, not objected to): the balloon's
        NECK, a new slick solid in the globo mover (line 258): (box_pts(0, 1.1, 0.5, 1.0), "wet"), from
        the basket's top (0.6) to the skin's lowest edge (1.6). `tormenta_balloon` is made with it.
     b. 10.8 (note 96, "to be tested"): a small sandbag on the rope's end, as the rope's bob (line 262):
        bob={"w": 0.36, "h": 0.42, "kind": "rope", "model": "tormenta_sandbag"}. The work log found the
        wind does not push ropes on the branch, so it was not added: only if the swing wants it.
     c. 10.9 (the designers' own answer): a rusted rung that breaks swings down on its last bolt and
        hangs flat against the face inside its rust streak; 8 s later a gust knocks it back into its
        socket with a clank and a puff of rust, and only then can it be held. Its hanging look is
        `tormenta_rung_hanging` (item 8).
     d. 10.3 (the page's note on the bolt): the strike's bolt (line 144, at=(-312, 960)) passes 0.1 m
        from the top of the second lone tower, where a climber stands. The page: the bolt starts in the
        dark cloud far BEHIND the ridge and comes forward as it comes down, reaching the play space only
        in its last 3 m at the tip (a bolt drawn from about (-312, 960, z -20) to the tip).
     e. 10.5 (notes 4, 18): each kite's string, a dark thread no thicker than a finger, from the kite's
        back straight to its reel 2.2 m behind (the reels are placed here at a10_dress.REELS): drawn by
        the game, following its kite, never solid.
     f. The socks: `tormenta_wind_sock` is the kit's `wind_sock` re-made in plain grey canvas (red and
        cream marks a hold on a moving thing here). Add it to peak_zones.gd STREAMER_POLES as
        `wind_sock` is, or the game flies no streamer from it (item 7f).
  7. Found while dressing, not on a page:
     a. The sky cards at z -30 (288-290) stand in front of the given storm's deck (peak_backdrop.gd: its
        wall at z -140 and cut-outs at -84, -46, -22) and hide all of it but the nearest row; the sheet
        counts on the deck showing ("dark round-headed clouds drifting 22 m and more back, and a dark wall
        of cloud behind them"). Taken out in item 4: check the frames for the sky behind.
     b. st.py's frogs' slide (FROG_SLIDE, tube(), 2.2 m) runs east through the ridge's foot at y 886.3
        .. 888.5; its 3 m slabs (883.3 .. 886.3 and 888.5 .. 891.5, x -361 .. -312.6) lie INSIDE the
        ridge's mass, their fronts on the mass's front: they would fight the mass's skin. Give them
        skin="tormenta_ridge_mass" (the mass's piece is made with the tunnel in it) or draw them not.
     c. The passage cut (a10.py 350-368) opens a slot 2.5 m tall through the whole front of the ridge's
        foot, from x -362 to the face at -307.7, right beside the cabin. Behind it today stood the far
        crest card (301, item 4); here the slot has its own back wall (`tormenta_slide_tunnel_back`, z
        -2.6 .. -2.4), and the face's and the mass's skins carry the tunnel's roof and floor back to it.
        The slide lets you out at the porch's west end, under the prayer pole and beside the cabin's west
        wall (both behind the play space).
     d. The mast's six rungs (1.6 x 0.16) are drawn today as slabs the full 2.4 m deep (the slim-bar
        rule in peak.gd stops at 1.5 m long): their skins are thin round bars.
     e. The headwall's rungs stand out of the face side-on (the course's A.beam from F-0.1 to F+0.8);
        the kit's `rung_iron` faces the camera, flat on a wall, so these are new.
     f. The kit's `wind_sock` is a static model streaming one way, and the game flies its own streamer
        from each sock's top too: two flags at each sock. A sock that hangs slack between gusts and
        lifts before one (the sheet) wants the game to draw the sock, or to swing the model: the fix
        thread's call.
     g. The balloon's cable (`tele_cable`, placed for the basket at its lowest, 961.0) follows the
        balloon by "ride" at half its bob (item 8): its top is 1 m off the ring at the top of the bob.
        A follow that keeps its foot on the block and stretches to the ring would be right.
     h. The far towers card stands 14 m back: its foot is at 884 with a scalloped painted cloud
        underside, so the valley's last strip shows under it from the porch (page 9 to 10). If the frames
        show its foot, it goes up.
     i. The summit's three teeth stop square at 958 m in the air today: the pages ask the summit's
        dress to carry them down to 953, behind our cloud's top (the summit's pieces, not placed here).
  8. Movers' looks, followers and the breakables' (the area file's and the game's; models in
     a10_models.md sections 4 and 5):
     - the vane (line 160, model="anemometer"): model="tormenta_vane" (re-made at the course's sizes).
     - the kites (line 189, model="kite"): model="tormenta_kite" (re-made at 1.2 x 1.44, no tails: each
       tail is its banner rope).
     - the balloon (line 258, model="weather_balloon"): model="tormenta_balloon" (with the neck, item
       6a, and no ropes of its own: the rope is globo_rope).
     - the rope's sandbag (item 6b): "tormenta_sandbag" (origin its hanging point).
     - the rusted rungs: "tormenta_rung_hanging" while broken (item 6c).
     - FOLLOWS (item 1): the dial's hand turns with the vane; each kite's reel rolls back and forth with
       its kite; the cable rides with the balloon at half its bob (item 7g).
  9. Effects (the pages'; the fix thread's): the cabin's smoke streaming east from the cowl in a gust of
     the lowest wind and standing straight between gusts; the kettle's and the frog's cup's steam; the
     lamp swinging a little in each gust; the frog's croak when you land; rain falling off El Alero's
     brink in a thin broken line 2 m east of the porch's end (dry under the prow); snow blowing off the
     glacier's top; the leaning rain in each band (proposed) and straight rain where two winds meet; rain
     running round each knob and leaving it dry; the papers snapping and lifting 0.8 s before a gust;
     after each strike a wisp of smoke from the tip and from the burnt star, the whole picture pale for
     an instant with hard black shadows, the frozen climber's mask lit white; rain thrown off each cup
     as it comes over the top; the kites' paper rattling; the far cloud flickering pale now and then;
     above 953 m no rain, gold light from above, water running down the face in thin bright lines; rust
     flakes off the two bad rungs, flying east; the balloon's skin steaming in the sun, the drum's pawl
     clicking as the cable goes tight and slack.
"""
import math

# ------------------------------------------------------------------ the course's own numbers (a10.py)
def F(y):
    """The ridge face's x at height y (a10.py F)."""
    return -307.0 - 27.0 * (y - 884.0) / 78.0


FACE_THICK = 8.0        # the face's slab (a10.py line 51)
FACE_SPLIT = 923.0      # where the wall is split for its two skins (item 5)
PORCH = 886.0           # the first ledge (a9.py's), the cabin's floor
SLIDE_Y0, SLIDE_Y1 = 886.2, 888.7   # the frogs' slide's passage through the ridge's foot (a10.py _cut_passage)
FILO_TOP = 902.6
DECK = 913.5            # the station's deck
MX = -310.0             # the mast's spine
P = [913.5, 917.5, 921.5, 925.5]    # the mast's timber: deck, crossarm 1, crossarm 2, the nest
HUB = (-302.8, 927.0)   # the vane's hub
SHOULDER = 932.5        # La Torre's shoulder
NEEDLE_TOP = 943.5
STEP = 955.5            # the buttress's top step
KITES = [(-291.9, 936.6), (-291.9, 939.2), (-291.7, 941.8)]   # the middles of the kites' figures of eight
FILO_KNOBS = [(-296.85, 892.0)] + [(-295.55 if i % 2 == 0 else -296.85, y) for i, y in
                                   enumerate((893.2, 894.4, 895.6, 896.8, 898.0, 899.2, 900.4))] + [(-296.9, 901.55)]
NUBE_KNOBS = [(-325.6, 947.0), (-324.6, 948.0), (-323.6, 949.0), (-323.9, 950.6), (-322.9, 951.6)]
POSTS = [(-287.35, 943.5, 946.0, -286.5), (-298.95, 944.0, 946.5, -298.1), (-312.55, 944.5, 947.0, -311.7)]  # x, foot, top, brace foot x
CIELO = [(957.0, "iron"), (958.2, "rotten"), (959.9, "iron"), (961.1, "rotten")]   # the headwall's rungs

# Depths.
NOOK = -3.4             # the nook's back wall's face (the cabin's back)
BODY_NEAR, BODY_FAR = -2.2, -2.95   # the towers' bodies
FLANK_NEAR, FLANK_FAR = -3.0, -3.6  # the ridge's flank
TOP_BACK = -2.2         # a tower's top carried back to its body
BANK_Z = -7.0           # the banks' face
COLLAR_Z = -2.0         # a collar's middle
MAST_Z = -2.55          # the vane's mast
BACK = -1.25            # the near edge of the background

# Stand-in tones.
SLATE = "#262C38"       # wet slate, blue-black, glossy
DRY = "#B9AF9F"         # dry slate, pale warm grey
QUARTZ = "#EEEDE6"
BODYC = "#555C68"       # a tower's body: duller, greyer, cooler
FLANKC = "#4A525E"      # the ridge's flank
CLOUD = "#6B7380"       # painted cloud, mid grey
CLOUD_DARK = "#565E6B"
FAR = "#79818E"         # the far towers, hazed
SNOW = "snow"
WOOD = "wood"
IRON = "iron"
STEEL = "#A9B5C2"       # bare steel, pale blue-grey
GREASE = "#15171B"      # black greased steel
ACCENT = "accent"
AMBER = "#B9874E"       # the cabin, amber inside
CANVAS = "#8E9196"      # the socks' grey canvas

# Lights for a10.py (item 2): x, y, z, colour, range, energy (both flicker).
CABIN_LIGHTS = [(-304.75, 887.73, -2.1, "#FFB860", 4.5, 1.0),    # the lamp over the table
                (-303.71, 886.35, -1.85, "#FF9A50", 2.5, 0.6)]   # the stove's door

# The reels (a kite's string runs to each: item 6e) and the followers (item 1, 8).
REELS = [(x, y, BODY_NEAR) for x, y in KITES]
FOLLOWS = [("tormenta_dial_hand", (-302.8, 925.68), "veleta", "spin", {}),
           ("tormenta_kite_reel", KITES[0], "papalote1", "roll", {"r": 1.0}),
           ("tormenta_kite_reel", KITES[1], "papalote2", "roll", {"r": 1.0}),
           ("tormenta_kite_reel", KITES[2], "papalote3", "roll", {"r": 1.0}),
           ("tele_cable", (-325.875, 960.025), "globo", "ride", {"scale": 0.5})]

# Made sizes of the pieces placed at several sizes.
KNOB_R = 0.24           # tormenta_quartz_knob: made to a hold of r 0.24, 0.42 x 0.48 (the hexagon), 0.6 deep
COLLARS = {"s": 9.0, "m": 11.0, "l": 13.5}   # tormenta_cloud_collar_s/m/l: made that wide, 5.0 tall, 0.2 deep
SOCK = (0.99, 1.48, 0.42)   # tormenta_wind_sock (the kit's wind_sock's shape), eye 0.45 east, 1.44 up
CABLE_UNIT = 10.0       # tele_cable: 10 x 0.15 x 0.15


def _face_box(y0, y1):
    """The box of the face's slab between y0 and y1 on its front line (a10.py line 51; peaklib _slab: the
    rock 8 m to the west and down, along the right-hand normal of the run from the top down)."""
    dx, dy = 27.0, -78.0
    L = math.hypot(dx, dy)
    nx, ny = dy / L * FACE_THICK, -dx / L * FACE_THICK
    pts = [(F(y0), y0), (F(y1), y1), (F(y0) + nx, y0 + ny), (F(y1) + nx, y1 + ny)]
    xs, ys = [p[0] for p in pts], [p[1] for p in pts]
    return min(xs), max(xs), min(ys), max(ys)


def dress(A):
    # ------------------------------------------------------------ helpers
    def skin(stem, x0, x1, y0, y1, z_front=1.2, z_back=-1.2, tone=SLATE):
        """The look of course solids: their box, from z_front back to z_back."""
        A.deco(stem, round((x0 + x1) / 2, 3), round(y0, 3), z=round((z_front + z_back) / 2, 3),
               size=(round(x1 - x0, 2), round(y1 - y0, 2), round(z_front - z_back, 2)), tone=tone, skin=True)

    def back(stem, x0, x1, y0, y1, z_near, z_far, tone=BODYC):
        """A piece behind the play space, from z_near back to z_far (origin: the middle of its foot)."""
        A.deco(stem, round((x0 + x1) / 2, 3), round(y0, 3), z=round((z_near + z_far) / 2, 3),
               size=(round(x1 - x0, 2), round(y1 - y0, 2), round(z_near - z_far, 2)), tone=tone)

    def front(stem, x0, x1, y0, y1, z_near, z_far, tone=SNOW):
        """A piece in front of the play space (z_near the side toward the play space)."""
        A.deco(stem, round((x0 + x1) / 2, 3), round(y0, 3), z=round((z_near + z_far) / 2, 3),
               size=(round(x1 - x0, 2), round(y1 - y0, 2), round(z_far - z_near, 2)), tone=tone)

    def knob(x, y, r):
        """A quartz knob on a course hold (A.hold, a hexagon r, pointed top and bottom): made at r 0.24,
        scaled to r; origin its lowest point."""
        s = r / KNOB_R
        A.deco("tormenta_quartz_knob", x, round(y - KNOB_R * s, 3), z=0.0, scale=round(s, 3), size=(0.42, 0.48, 0.6),
               tone=QUARTZ, skin=True)

    def collar(size, x0, x1, y0, z=COLLAR_Z):
        """A collar of painted cloud across the lower end of a tower's body (made at three widths, 5 m
        tall, 0.2 deep; scaled to the page's width). y0 the lowest point of its scalloped underside."""
        w = COLLARS[size]
        s = round((x1 - x0) / w, 3)
        A.deco("tormenta_cloud_collar_" + size, round((x0 + x1) / 2, 3), y0, z=z, scale=s, size=(w, 5.0, 0.2), tone=CLOUD)

    def sock(eye_x, eye_y, z, east):
        """A grey canvas wind sock hung by its eye at (eye_x, eye_y), streaming east or west (the kit's
        wind_sock's shape, re-made grey: its eye 0.45 east and 1.44 up of its origin unflipped)."""
        ox = eye_x + 0.45 if east else eye_x - 0.45
        A.deco("tormenta_wind_sock", round(ox, 3), round(eye_y - 1.44, 3), z=z, size=SOCK, tone=CANVAS, flip=east)

    def stub(x, y, z, h=1.1):
        """A sock stub: a short square timber standing at the back of a rest (made 1.1 tall)."""
        A.deco("tormenta_sock_stub", x, y, z=z, scale=round(h / 1.1, 3), size=(0.16, 1.1, 0.16), tone=WOOD)

    def torn(x, y, east, z=-1.35):
        """The torn end of a prayer line, tied at (x, y), streaming east or west: the kit's prayer_flag
        (one big papel flag on a hand of cord; it streams west unless flipped)."""
        A.deco("prayer_flag", round(x + (0.52 if east else -0.52), 3), round(y - 0.62, 3), z=z, size=(1.03, 0.69, 0.03),
               tone=ACCENT, flip=east)

    def brace(top, foot, z=-1.4):
        """A square timber back brace from a post's top down to its tower's top, behind the play space:
        `tormenta_back_brace`, made 2.64 long along y, origin its middle, turned by rot."""
        L = math.dist(top, foot)
        rot = math.degrees(math.atan2(foot[0] - top[0], top[1] - foot[1]))   # (positive: its top tipped west)
        A.deco("tormenta_back_brace", round((top[0] + foot[0]) / 2, 3), round((top[1] + foot[1]) / 2, 3), z=z, rot=round(rot, 2),
               scale=round(L / 2.64, 3), size=(0.25, 2.64, 0.25), tone=WOOD)

    # ============================================================ the far view
    # THE RIDGE'S FAR TOWERS: ONE flat painted card 14 m back, made the way the far cards are (BRIEF.md "Far
    # backgrounds": a thick card whose cut edge shows kraft, a dark stripe, kraft, braces behind): a row of blades
    # and needles going away along the crest, the same leaning slate shapes as the near towers, their feet in
    # painted cloud, the back ones hazed to the storm's grey, a few torn lines painted between them; mid greys and
    # slate blues, nothing near white (the wind's lines show against it); its foot a scalloped painted cloud
    # underside (item 7h). 80 m wide so the cameras pulled back over Gendarmes and Veleta never reach its east edge
    # (it slides at about half the camera's offset). Behind it is what is given.
    back("tormenta_far_towers", -345.0, -265.0, 884.0, 974.0, -14.0, -14.2, tone=FAR)

    # ============================================================ the face, the mass and El Alero (the fall line)
    # THE FACE (skins, line 51, split at 923, item 5): wet slate in a few big leaning planes, blue-black and glossy,
    # its cleavage flat colour in long wavy lines and bands leaning with the face, no rain painted; the edge of a
    # mountain: whatever touches it slides to El Alero. Carried back to the nook's wall (-3.4). The low piece has the
    # mouth of the frogs' slide's tunnel at its foot (886.2 .. 888.7, item 7c), its roof and floor carried back to
    # the tunnel's back wall; the high piece has, painted up the ladder's line, a pair of dark bolt holes at each of
    # the six places a rung is gone (956.4, 957.6, 958.77, 959.33, 960.5, 961.65, 0.22 m west of the face's edge),
    # each with a long rust streak running DOWN the slate (a band of even width, square-ended, never a taper), and
    # in the long gap two black iron nubs no longer than a thumb (959.05 and 959.33: the old stub cut down, item 3).
    fx0, fx1, fy0, fy1 = _face_box(884.0, FACE_SPLIT)
    skin("tormenta_face_low", fx0, fx1, fy0, fy1, z_back=NOOK)
    fx0, fx1, fy0, fy1 = _face_box(FACE_SPLIT, 962.0)
    skin("tormenta_face_high", fx0, fx1, fy0, fy1, z_back=NOOK)
    # THE RIDGE'S MASS (skin, lines 283, 284 and a9.py's line 95): the face's own body carried west, the same slate a
    # step darker and plainer, a few long bands; its top strip (284) dry pale slate in square steps under the
    # summit's wall; the frogs' slide's tunnel through its foot, its roof and floor carried back to -2.4.
    skin("tormenta_ridge_mass", -362.0, -312.0, 880.0, 962.0, z_back=-2.4)
    # The slide's tunnel's back wall (item 7c): the ridge's rock inside the tunnel, dark, dull, a few bands, from
    # the region's edge to the face.
    back("tormenta_slide_tunnel_back", -362.0, round(F(887.4), 2), SLIDE_Y0, SLIDE_Y1, -2.4, -2.6, tone=FLANKC)
    # EL ALERO (skin, line 53): the prow over the porch, wet slate, its cap 40 degrees and slick to its brink; its
    # underside the cabin's roof, dry under the prow, carried back to the nook's wall; let into the underside at
    # (-301.85, 892.15) the square honey spar of the torn line, its end flush in the rock, 0.35 m square, an iron
    # pug plate on it, the spar running back 3.4 m under the prow to the nook's wall.
    skin("tormenta_alero", -318.0, -300.0, 891.7, 904.1, z_back=NOOK)

    # ============================================================ 9 to 10: the gap
    # THE GAP'S FAR WALL (in place of a9.py's card 399-400, item 4): the ridge's flank bared where the ice pulled
    # away, wet slate in leaning slabs, dull blue-grey, in shadow, with long pale scrapes low down where the ice
    # dragged; made to a9's outline ((-302.5, 878.7), (-296, 866.5), (-288, 861.5), (-286.5, 866.95), (-286.5,
    # 871.8), (-295.9, 871.8), (-295.9, 881), (-302, 884.6)), a hole cut round the slab hollow (x -292.6 ..
    # -287.6, 864.2 .. 869.3) and round the slab mouth's block (x -303.5 .. -298.9, 879.05 .. 882.05).
    back("tormenta_gap_wall", -302.5, -286.5, 861.5, 884.6, -2.4, -2.6, tone=FLANKC)
    # The cloud in the gap: a painted bank 7 m back between the prow and El Filo, round heads, a scalloped
    # underside, dark below and paler on top; the valley's last strip shows under it.
    back("tormenta_bank_gap", -303.0, -288.0, 884.6, 893.2, BANK_Z, BANK_Z - 0.2, tone=CLOUD_DARK)
    # THE PORCH (skin, a9.py's ledge, line 94): firm snow, white and matte, 0.3 thick with a square front edge on the
    # dry rock, combed by the wind into low ridges running east, a path one boot wide trodden flat from the cabin's
    # east post to the ledge's end; carried back under the cabin to the nook's wall (its floor is the cabin's).
    skin("tormenta_porch", -312.0, -302.0, 884.6, PORCH, z_back=NOOK, tone=SNOW)
    # Foreground: the lip of drifted snow along the porch's front, 0.28 m above its snow, in front of the ledge's own
    # snow only (made in place: (-307.6, 886.2), (-305.8, 886.28), (-304.3, 886.18), (-303.0, 886.26), hanging
    # 0.25 m over the front edge).
    front("tormenta_snow_lip", -307.6, -303.0, 885.75, 886.28, 1.25, 1.55)

    # ============================================================ 10.0 The keeper's cabin
    # The nook's back wall: the ridge's flank where it passes under the prow, leaning ribs of wet slate running with
    # water, the darkest thing in the picture so the cabin's light sits in it; it follows El Alero's underside and
    # carries on east to under the prow's tip (made to the page: (-313, 884.2), (-301.5, 884.2), (-301.1, 886.8),
    # (-300.6, 889.6), (-300.8, 891.9), (-313, 895.4)).
    back("tormenta_nook_wall", -313.0, -300.6, 884.2, 895.4, NOOK, -4.0, tone=FLANKC)
    # THE CABIN (note 94): the cableway's way, square honey posts and thick planks, a plank floor level with the
    # porch, a plank back wall, two end walls, NO FRONT WALL (cut away at -1.25), a roof of slate slabs on honey
    # rafters pitched as the prow pitches (2.5 m up at the west end, 2.1 at the east), the two front corner posts at
    # the ledge's back edge with an iron pug plate at each foot; amber inside as colour on the planks.
    back("tormenta_cabin", -307.75, -302.8, PORCH, 888.74, BACK, NOOK, tone=AMBER)
    # The stove (the mine frog's iron stove), its pipe up through the roof to a cowl 1.5 m above it, the keeper's
    # kettle on it (the same kettle as in the cliffs' tea cave and the glacier's snow hole).
    A.deco("mine_frog_stove", -303.71, PORCH, z=-2.1, size=(0.6, 0.7, 0.5), tone=IRON)
    A.deco("tormenta_stove_pipe", -303.53, 886.7, z=-2.1, size=(0.3, 3.15, 0.3), tone=IRON)
    A.deco("tea_kettle", -303.86, 886.7, z=-2.1, size=(0.31, 0.27, 0.24), tone=IRON)
    # The table with the weather book open on it; the frog in its yellow rain hat on the table's west end with a cup
    # of tea beside it; the one lamp hung from a rafter over it (origin its hook; light: item 2).
    A.deco("tormenta_cabin_table", -304.75, PORCH, z=-2.1, size=(1.0, 0.83, 0.6), tone=WOOD)
    A.deco("frog_rain_hat", -305.05, 886.76, z=-2.1, size=(0.34, 0.33, 0.35), tone="#E8C23A")
    A.deco("tea_cup", -304.8, 886.76, z=-1.95, size=(0.12, 0.1, 0.11), tone=ACCENT)
    A.deco("lantern_hang", -304.75, 888.05, z=-2.1, size=(0.28, 0.52, 0.31), tone="gold")
    # The bunk along the west end with a folded blanket, the keeper's yellow oilskin coat on a peg on a post at its
    # foot (the size of a luchador; the frog's hat is cut from the same cloth).
    A.deco("tormenta_cabin_bunk", -306.225, PORCH, z=-2.8, size=(1.95, 1.8, 0.9), tone=WOOD)
    # The wind slate on the back wall over the bunk (origin the middle of its back's foot on the wall's inner face).
    A.deco("tormenta_wind_slate", -306.5, 887.2, z=-3.28, size=(0.6, 0.8, 0.03), tone="#3A3F48")
    # The prayer pole at the cabin's west corner (moved 1.4 m east, page 9 to 10; a9.py line 424 out, item 3).
    A.deco("prayer_pole", -307.6, PORCH, z=-1.35, size=(0.2, 4.0, 0.2), tone=ACCENT)

    # ============================================================ 10.1 El Filo
    # EL FILO (skin, lines 76, 80, 86): one slab of slate on end, its cut edge 1 m thick, blue-black and glossy,
    # undercut to a slick point at 885.2; on its west side the landing scar (889.6 .. 892.1), pale warm grey, dry,
    # broken in small square steps with a crisp edge all round; its flat dry head (2.8 m) carried back to its body.
    skin("tormenta_filo", -297.6, -294.8, 885.2, FILO_TOP, z_back=TOP_BACK)
    # The eight quartz knobs (skins, lines 84, 89): white quartz blocks, 0.3 m proud, dry, a hand of dry slate round.
    for x, y in FILO_KNOBS[1:]:
        knob(x, y, 0.24)
    # El Filo's body: the slab the blade is the edge of, 3.6 m wide, in two leaning slabs, duller and greyer, ending
    # just under the blade's top and going down into its collar; on it in dull white paint the quartz vein, a thin
    # line from behind each knob across to the next (made to the page: (-298.1, 885), (-297.7, 901), (-297.0,
    # 901.6), (-295.4, 901.6), (-294.7, 901.3), (-294.1, 885)).
    back("tormenta_body_filo", -298.1, -294.1, 883.6, 901.6, BODY_NEAR, BODY_FAR)
    # The collar across its lower end, 11 m wide (where the flat grey card stood in front of the mitten, note 92).
    collar("m", -302.0, -291.0, 883.4)
    # The bank behind the blade's lower half, 7 m back (behind the gap's bank where the two overlap).
    back("tormenta_bank_filo", -303.5, -287.0, 888.6, 898.2, -7.4, -7.6, tone=CLOUD_DARK)
    # The middle wind's flag (W2, west): a sock on a timber arm from the body's west side at 895.3.
    xb = -298.1 + 0.4 * (895.3 - 885.0) / 16.0           # the body's west edge there
    A.deco("tormenta_sock_arm", round(xb - 0.4, 3), 895.2, z=-2.4, size=(0.8, 0.2, 0.2), tone=WOOD)
    sock(round(xb - 0.8, 3), 895.3, -2.4, east=False)
    # The top wind's flag (W3, east): a sock on a stub at the back of the head.
    stub(-295.15, FILO_TOP, -1.6)
    sock(-295.15, FILO_TOP + 1.05, -1.6, east=True)
    # The line pole's foot: a timber cradle bolted through an iron pug plate, behind the pole on the head, and the
    # kit's timber_brace (made 6 m, origin its middle) at 0.72 raking from the pole's back down to the head's back.
    A.deco("tormenta_pole_cradle", -296.2, FILO_TOP, z=-1.55, size=(1.0, 0.35, 0.6), tone=WOOD)
    top, foot = (-296.2, 907.2), (-295.4, 902.95)
    A.deco("timber_brace", round((top[0] + foot[0]) / 2, 3), round((top[1] + foot[1]) / 2, 3), z=-1.45,
           rot=round(math.degrees(math.atan2(foot[0] - top[0], top[1] - foot[1])), 2), scale=round(math.dist(top, foot) / 6.0, 3),
           size=(0.3, 6.0, 0.3), tone=WOOD)

    # ============================================================ 10.2 Banderas
    # THE LINE POLE (skin, line 102): black greased steel, as thick as a wrist, glossy, rain beading on it; three
    # iron rings on square pug plates on it where the lines are made fast (904.3, 908.4, 910.0). Cannot be held.
    skin("tormenta_line_pole", -296.32, -296.08, FILO_TOP, 910.3, z_front=0.12, z_back=-0.12, tone=GREASE)
    # The torn end of an older line streaming west from the pole's top, 1.3 m back.
    torn(-296.2, 910.3, east=False)
    # LA AGUJA (skin, tower() line 103 and its spire 104): a spire of wet slate, the rope way's turning post, its
    # point undercut and slick; two iron rings on pug plates where line 1 ends (905.2) and line 2 starts (906.8).
    skin("tormenta_aguja", -306.3, -304.7, 900.8, 907.3)
    back("tormenta_body_aguja", -307.7, -303.1, 897.0, 904.9, BODY_NEAR, BODY_FAR)
    collar("s", -309.5, -301.5, 898.2, z=-1.8)               # in front of the station's collar where they meet
    # The station tower's body: 12 m wide at the top, its shoulder a row of leaning slab ends, saw-toothed, wet and
    # dark, never level for half a metre, with a notch for the vane's shoe (made to the page's outline, _STATION_BODY);
    # its foot in its collar.
    back("tormenta_body_station", -313.5, -301.2, 905.0, 914.3, BODY_NEAR, BODY_FAR)
    collar("l", -316.0, -303.5, 902.6)
    # THE RIDGE'S FLANK, the first piece: the face's own body 3 m behind the open air east of the face, dull
    # blue-grey slate in leaning ribs with a few real gullies, a stepped east edge about 5 m out from the face
    # (a10_areas._flank), its foot tucked behind El Alero's cap.
    back("tormenta_flank_a", round(F(917.5) - 1.0, 2), round(F(897.0) + 5.5, 2), 897.0, 917.5, FLANK_NEAR, FLANK_FAR, tone=FLANKC)
    # The bank behind the lower two lines, between El Filo and the spire.
    back("tormenta_bank_banderas", -304.0, -292.0, 900.2, 909.6, BANK_Z, BANK_Z - 0.2, tone=CLOUD_DARK)
    # The vane's mast on its shoe in the shoulder's notch: the kit's banded vane_mast, under the hub, 2.5 m back
    # (page 10.4); the timber shoe bolted through iron pug plates.
    A.deco("tormenta_vane_shoe", HUB[0], DECK, z=MAST_Z, size=(1.2, 0.35, 0.6), tone=WOOD)
    A.deco("vane_mast", HUB[0], DECK, z=MAST_Z, size=(0.5, 13.5, 0.5), tone=IRON)

    # ============================================================ 10.3 El Rayo
    # The station's tower (skin, line 125): wet slate, its shaft undercut to a slick point at 906.
    skin("tormenta_station_tower", -311.5, -308.0, 906.0, 913.0)
    # THE DECK (skin, line 126): honey planks, pegged, split ends, carried back under the hut (its floor); a black
    # star 2 m across burnt into the planks round the mast's foot; at its east corner the line's iron ring on a low
    # bollard (913.6).
    skin("tormenta_station_deck", -311.8, -307.7, 913.0, DECK, z_back=NOOK, tone=WOOD)
    # THE MAST'S TIMBER (skin, lines 129-131, 134, 142): four sleeves, each a box of four honey planks 0.6 m across
    # round the spine, the three crossarms thick and square, each running back to -1.2 as the front of its yard,
    # the nest; grain, pegs, split ends, warm in a cold picture; SEVEN stacks of white ribbed porcelain, each 0.72
    # wide and 0.22 tall, standing 0.2 to 0.6 forward on the timber's side of each joint (the tops of the four
    # sleeves at 915.18, 919.18, 923.18, 927.18; the undersides of the crossarms at 917.2, 921.2, 925.2).
    skin("tormenta_mast_timber", -311.8, -308.2, DECK, 927.4, z_front=0.6, z_back=-1.2, tone=WOOD)
    # THE MAST'S STEEL (skins, one each: lines 135, 137, 143): bare steel, pale blue-grey, cold and matte, thin and
    # round (half the timber's thickness), rivet heads, scorched black at every joint.
    for i in range(3):
        skin("tormenta_mast_spine", MX - 0.15, MX + 0.15, P[i] + 1.9, P[i + 1] - 0.3, z_front=0.15, z_back=-0.15, tone=STEEL)
        for dy in (2.0, 3.1):
            skin("tormenta_mast_rung", MX - 0.8, MX + 0.8, P[i] + dy - 0.08, P[i] + dy + 0.08, z_front=0.15, z_back=-0.15, tone=STEEL)
    skin("tormenta_mast_tip", MX - 0.1, MX + 0.1, 927.4, 929.6, z_front=0.1, z_back=-0.1, tone=STEEL)
    # The hut (re-made: the kit's station_hut_ruin with its east half roof burnt away, bare black rafter ends, the
    # west half still slated; weathered grey, a step duller than the deck), on the deck behind the play space.
    back("tormenta_hut", -312.45, -308.6, DECK, 916.35, -1.4, NOOK, tone=WOOD)
    # The pug sign with the bolt on the hut's front wall at head height, facing you (origin the middle of its back).
    A.deco("sign_pug_bolt", -309.11, 915.03, z=-1.4, size=(1.01, 1.01, 0.08), tone=ACCENT)
    # The rain gauge against the hut's east corner, 0.6 m back from today; a dead storm lantern on the eave.
    A.deco("rain_gauge", -308.35, DECK, z=-1.5, size=(0.4, 0.9, 0.4), tone=IRON)
    A.deco("lantern_cold", -308.75, 915.6, z=-1.55, size=(0.28, 0.48, 0.28), tone=IRON)
    # What the crossarms carried: each crossarm's timber yard runs on 2.4 m back from the play space, an instrument
    # under its far end: the louvred thermometer box (grey slats); the storm cone of black canvas, point down; the
    # nest's plank stage, 1.2 m deep, a burnt hole in it. None of it steel.
    A.deco("tormenta_yard_thermometer", -308.48, 916.5, z=-2.45, size=(0.5, 1.0, 2.4), tone=WOOD)
    A.deco("tormenta_yard_storm_cone", -311.7, 920.2, z=-2.45, size=(0.8, 1.3, 2.4), tone=WOOD)
    A.deco("tormenta_nest_stage", MX, 925.0, z=-1.85, size=(3.2, 0.2, 1.2), tone=WOOD)
    # The mast's wind's flags (W5, east): two socks on the vane's mast at 916 and 919, below the vane's sweep.
    sock(-302.55, 916.65, MAST_Z, east=True)
    sock(-302.55, 919.85, MAST_Z, east=True)
    # THE RIDGE'S FLANK, the second piece.
    back("tormenta_flank_b", round(F(934.0) - 1.0, 2), round(F(917.5) + 5.5, 2), 917.5, 934.0, FLANK_NEAR, FLANK_FAR, tone=FLANKC)

    # ============================================================ 10.4 Veleta
    # The vane's head (scenery from z -1.25 back): the axle from behind the hub back to the mast's head (the axle's
    # front 1.2 m is the vane's own, item 8), under the head a timber counting box 1 m wide with a white dial 0.6
    # across on its front at z -2.2, and a short staff on the head for the sock (to 928.9).
    A.deco("tormenta_vane_head", HUB[0], 925.2, z=-2.025, size=(1.0, 3.7, 1.55), tone=WOOD)
    # The dial's hand (origin its pivot, the dial's centre; it turns with the vane, FOLLOWS).
    A.deco("tormenta_dial_hand", HUB[0], 925.68, z=-2.19, size=(0.06, 0.28, 0.02), tone=IRON)
    # The head sock (W6, west), at the place you leave from.
    sock(HUB[0], 928.9, MAST_Z, east=False)
    # LA TORRE (skin, lines 166-169, 191, 194): the block undercut to a slick point at 920.5, its scar (928.6 ..
    # 932.5, pale, dry, stepped), the shoulder's flat dry top (3.5 m) carried back to the body, the needle on the
    # east half, blue-black and glossy, its scar (937.5 .. 940.5) and its flat dry top (2.5 m) carried back.
    skin("tormenta_torre", -291.2, -285.0, 920.5, NEEDLE_TOP, z_back=TOP_BACK)
    # La Torre's body: 9 m wide, the shoulder's back wall, a saw-toothed top at about 941 with one sharp spike on its
    # west corner, nothing pale on it but the needle's quartz vein in dull white (made to the page's outline).
    back("tormenta_body_torre", -292.6, -283.6, 917.3, 943.3, BODY_NEAR, BODY_FAR)
    collar("l", -296.0, -282.0, 918.2)
    # The bank under the throw, between the vane and La Torre.
    back("tormenta_bank_veleta", -301.5, -290.0, 916.9, 925.3, BANK_Z, BANK_Z - 0.2, tone=CLOUD_DARK)
    # The shoulder's flag (W6, west): a sock on a stub at the back of the shoulder.
    stub(-288.1, SHOULDER, -1.5)
    sock(-288.1, SHOULDER + 1.05, -1.5, east=False)

    # ============================================================ 10.5 El Papalote
    # The needle's two knobs (skins, lines 192, 193).
    knob(-287.65, 941.6, 0.24)
    knob(-287.65, 942.7, 0.24)
    # The three kite reels, bolted to the body's west edge on iron pug plates, each behind the middle of its kite's
    # figure of eight (origin the reel's centre on the body's face; each rolls with its kite, FOLLOWS).
    for x, y, z in REELS:
        A.deco("tormenta_kite_reel", x, y, z=z + 0.175, size=(0.8, 0.8, 0.35), tone=WOOD)
    # The first lone tower's body and its collar (also 10.6).
    back("tormenta_body_lone_east", -300.7, -296.1, 931.0, 943.3, BODY_NEAR, BODY_FAR)
    collar("s", -303.0, -293.5, 935.6)
    # The torn ends on the needle's post and the first lone tower's post, streaming west, 1.3 m back (tied to the
    # heads of their braces, 10.6).
    torn(POSTS[0][0], POSTS[0][2], east=False)
    torn(POSTS[1][0], POSTS[1][2], east=False)
    # The bank in the gap between La Torre and the first lone tower, behind the west half of the kites' flight, its
    # heads just under the first flight.
    back("tormenta_bank_torre", -299.4, -288.8, 934.3, 944.5, BANK_Z, BANK_Z - 0.2, tone=CLOUD_DARK)

    # ============================================================ 10.6 Gendarmes
    # The three line posts (skins, lines 216, 220, 224): square honey timber 0.3 m, pegged, a split top, an iron pug
    # plate at the foot on its front.
    for x, y0, y1, _bf in POSTS:
        skin("tormenta_line_post", x - 0.15, x + 0.15, y0, y1, z_front=0.15, z_back=-0.15, tone=WOOD)
    # The lone towers (skins, 217-219 and 221-223): thin slick shafts on pointed feet, a flat dry top 1.6 m wide
    # carried back, a pale scar on the east side (2 m on the first, 1.5 m on the second).
    skin("tormenta_lone_tower_east", -299.1, -297.3, 938.3, 944.0, z_back=TOP_BACK)
    skin("tormenta_lone_tower_west", -312.7, -310.9, 936.5, 944.5, z_back=TOP_BACK)
    back("tormenta_body_lone_west", -314.3, -309.7, 929.5, 943.8, BODY_NEAR, BODY_FAR)
    collar("m", -317.0, -307.0, 934.1)
    # The second lone tower's torn end streams east: the two on the lone towers point at each other where the winds meet.
    torn(POSTS[2][0], POSTS[2][2], east=True)
    # The braces: each post held by a square timber brace from its top down to the tower's top, behind it.
    for x, _y0, y1, bf in POSTS:
        foot_y = {-286.5: NEEDLE_TOP, -298.1: 944.0, -311.7: 944.5}[bf]
        brace((x, y1), (bf, foot_y))
    # The banks in the other two gaps.
    back("tormenta_bank_gendarmes", -310.6, -299.8, 934.3, 941.6, BANK_Z, BANK_Z - 0.2, tone=CLOUD_DARK)
    back("tormenta_bank_contrafuerte", -325.0, -313.4, 934.3, 941.0, BANK_Z, BANK_Z - 0.2, tone=CLOUD_DARK)
    # THE RIDGE'S FLANK, the last piece, under the buttress (it ends inside La Nube's cloud).
    back("tormenta_flank_c", round(F(941.6) - 1.0, 2), round(F(934.0) + 5.5, 2), 934.0, 941.6, FLANK_NEAR, FLANK_FAR, tone=FLANKC)
    # THE BUTTRESS (skin, lines 227-229, 270): the last tower, leaning on the face, wet slate, its cap 37 degrees and
    # slick to its brink; the scar (944.4 .. 945.9) over the 1 m foothold; the top step, pale dry slate in square
    # steps, carried back to the summit's pillar (-1.8).
    skin("tormenta_buttress", -334.5, -325.7, 941.5, STEP, z_back=-1.8)

    # ============================================================ 10.7 La Nube
    # THE CLOUD: one painted bank 25 m wide, 1.5 m back, filling the frame below 951 m, big soft billows in three
    # rows, darkest at the foot, mid greys and slate blues, nothing near white, no straight edge anywhere (its ends
    # round billows); painted on it one tone darker the buttress's shoulder rising behind the rib, no outline.
    back("tormenta_nube_bank", -337.0, -312.0, 940.5, 951.2, -1.5, -1.6, tone=CLOUD)
    # The cloud's top: a strip of round heads (tops 953 .. 954.6), 1.3 m back, in front of the summit's teeth.
    back("tormenta_nube_top", -337.0, -312.0, 950.4, 954.6, -1.34, -1.36, tone=CLOUD)
    # The rib: a fin of dark wet slate just behind the play space, the darkest thing in the picture; painted white
    # on it the quartz vein through the first three knobs, a clean black crack, the vein again 1.3 m west and 0.6 m
    # up through the last two; its east edge cut back 0.4 m near its top (made to the page's outline).
    back("tormenta_nube_rib", -327.0, -322.1, 944.6, 952.5, BACK, -1.35, tone="#1E232C")
    # The five knobs (skins, line 244).
    for x, y in NUBE_KNOBS:
        knob(x, y, 0.28)
    # The wind's flag where you start (W8b, east): a sock on a 1 m stub at the back of the foothold.
    stub(-326.05, 944.4, -1.46, h=1.0)
    sock(-326.05, 945.35, -1.46, east=True)

    # ============================================================ 10.8 El Globo
    # The winch at the back of the top step: a hand winch on a timber frame, 0.45 deep (so it stands in front of
    # the summit's pillar), a crank and a full drum of black cable, bolted down through iron pug plates; grey, wet.
    A.deco("tormenta_winch", -330.725, STEP, z=-1.525, size=(1.15, 0.92, 0.45), tone=WOOD)
    # Its guide post at its east end, 2.25 m, an iron block at its head (957.75) where the cable leaves, the kit's
    # pug arrow board (sign_pug_arrow's board without its post) nailed to it pointing up at the rungs.
    A.deco("tormenta_guide_post", -330.05, STEP, z=-1.5, size=(0.8, 2.35, 0.3), tone=WOOD)
    # The headwall's flag (W9, east) under the block.
    sock(-329.95, 957.65, -1.5, east=True)
    # The cable: black greased steel 0.15 thick from the block up to the iron ring under the back of the skin, 1.3 m
    # back (the kit-wide `tele_cable`, made 10 m, at 0.951); placed for the basket at its lowest (961.0).
    c0, c1 = (-330.05, 957.75), (-321.7, 962.3)
    A.deco("tele_cable", round((c0[0] + c1[0]) / 2, 3), round((c0[1] + c1[1]) / 2, 3), z=-1.355,
           rot=round(math.degrees(math.atan2(c1[1] - c0[1], c1[0] - c0[0])), 2), scale=round(math.dist(c0, c1) / CABLE_UNIT, 3),
           size=(CABLE_UNIT, 0.15, 0.15), tone=GREASE)

    # ============================================================ 10.9 Escalera al Cielo
    # The four rungs (skins, line 273): each standing out from the face, a bar 0.9 long and 0.16 thick, its square
    # plate with two bolts lying on the face at its inner end (0.36 tall), a round eye at its outer end. Sound:
    # rust-orange, dry, matte, straight, thick. Rusted: eaten to half, pale and scabbed, cracked through by its
    # plate, one bolt gone, its outer end dropped a hand's width, inside the shape that is held.
    for y, kind in CIELO:
        A.deco("tormenta_rung" if kind == "iron" else "tormenta_rung_rusted", round(F(y) + 0.35, 3), round(y - 0.18, 3), z=0.0,
               size=(0.9, 0.36, 0.4), tone=IRON, skin=True)
    # Two rungs that came out whole, lying at the back of the step east of the winch, rusted dark, one bent.
    A.deco("tormenta_rungs_fallen", -329.4, STEP, z=-1.5, size=(0.9, 0.2, 0.4), tone=IRON)
    # The exit ledge's slab (skin, line 55): the ridge's last slab of slate, dry, pale warm grey, in square steps,
    # overhanging the face by 2 m, two old bolt holes with rust under them on its east end where the ladder's top
    # bracket was. Its top's dressing is the summit's (the tea shop, note 97).
    skin("tormenta_exit_slab", -340.0, -332.0, 962.0, 964.0, tone=DRY)
