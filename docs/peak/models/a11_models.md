# La Cumbre: the models to make

The model list for biome 11, the summit, from its dress file `tools/peak/areas/a11_dress.py` (149 decos,
28 of them skins). Every stem in sections 1 to 3 is NEW: not in `kit/models/` nor in `Top Dog Kit\models\`,
nor on the a0 to a10 lists: 55 placed by the dress file; 2 more made for a11.py and the game (section 4);
then five re-makes of kit models, each landing as a new stem (section 5; four of them placed by the dress
file). Make each at exactly its size (metres, w x h x d; +z faces the camera). The game rescales a landed
model that is more than a quarter off; a skin is never rescaled, so a skin is made to its box exactly.

Reused (not listed): `frog_apron` (the tea frog behind the counter, notes 60 and 97), `frog_sit` (7),
`frog_soak` (7), `frog_soak_b` (8), `frog_asleep` (2), `frog_blanket` (2), `frog_tea` (2), `frog_ticket`
(1): the spring's twenty-nine frogs (wave 0's; "all the same little frog as every biome's"); `tea_cup` (9),
`tea_pot` (2), `tea_kettle`, `tea_table_low`, `tea_tins_shelf` (2): the tea cave's things, as the pages ask
("the same pot, cups and kettle as the tea cave on the wind cliffs"); `mine_frog_stove` (the shop's stove,
as the storm ridge's cabin has it); `lantern_hang` (4: the shop's lit lantern in place of the cold one, and
the spring's three candle lanterns); `papel_string` (4: the awning, the line on the jade back run, the 30 m
line over the leap, the 23 m west line; the game tiles it in 8 m units); `marigold_garland` (9: the four
crown swags, each two runs meeting at its low point, and the wreath across the slide's mouth);
`marigold_pile` (on the rib's top, beside the one who sits); `iron_ring_pin_long` (3 skins: the three
rings, each on its long pin from the spur, the splinter and the chimney's wall). For the course (a11.py,
not placed here): thread C's `ring_rope_red`, `ring_rope_cream`, `ring_rope_jade` on the six bounces; the
kit's `frog_sit` for the frog that shows the move (the game's); `champion_belt` (the Top Dog session's,
left alone). Not used: `cold_lantern` (the shop's lit lantern takes its place), `ring_post`, `bell_frame`
and `summit_bell` (re-made, section 5), `ring_corner_pad` (the red pads are part of the timber heads),
`summit_shrine`, `tea_brazier` (the shop has a stove), the kit's crates (1.1 m and more: the frog's crate is
0.8), `mine_towel_peg` (the spring's towels are a folded pile). NOTHING CLIMBER-SHAPED is on this list:
the last of the ones who tried stays the game's statue on the perch, and the ceremony's climber is the
game's climber posed, until the new climber model lands (MODELLING_RUN; Parker 11-13). The ceremony's
rays and orchestra (note 101) are the Top Dog session's, and effects.

Makers: **A** rock walls and masses as painted pieces and every skin of ice and rock (the dome, the
shoulder, the floors and tops, the rime, the frost wall), the far cards (our three cloud banks, the peak's
own back), the teeth, the pillars, the splinter, the rib, the ring's canvas apron with its beam, the two
snow caps, the tea shop's room, its back wall and the chute's back wall, the spring's cave with the pool's
back half, its bank and its rim. **B** the summit's plants, the three painted boards, the tea shop's
counter, crate, stools and spout, the towels. **C** the ring's two corner posts with their turnbuckle
blocks, the gold bosses, the bell's hanger, strut and staff, the flagstaff, the back runs of the ring
ropes, the tea shop's tin pipe and cowl; the clapper and the toll handle (section 4); the timber heads,
the bell frame and the bell (section 5).

The summit's look (the sheet `docs/peak/playtest/design/data/a11_biome.py`, Parker's third-round answers
11 to 13, notes 97 to 102): **the ruin of a ring at the top of the mountain**, under one low gold sun from
the east (east faces warm, west faces and undersides in long blue-violet shadow). **Black ice** (the dome,
its prow, the tunnel's roof, the west face and its eave, the shoulder, the posts' shafts): blue-black and
glossy with a hard white glint, a few big flat planes with a designed outline; its bands in three
blue-black tones, its glints, cracks and lines of rime are flat colour, long wavy lines and bands; **nothing
painted narrows to a point; no dark recess** (the tunnel's two mouths, the sink, the stair's chimney and the
slide's mouth are the only holes, all the play's). **Tan rock** (teeth, pillars, splinter, the peak's back,
the tea ledge's back wall, the rib): the same rule, its bedding long wavy lines in three tans, leaning
notched outlines, duller and cooler the further back; where the ring's builders cut a face square, the cut
edge is chipped. **Summit rock** (warm, pale, dry, old cream) only where you stand: the tea floor, the
shelf, the west post's top, the perch, the doorstep. **Rime**: hard grey-white frost feathers, pale and
matte, cracked across with a corner gone, grown toward the west. **The ring**: dark squared rock, honey
timber where you can reach it, weathered grey timber where you can't, hemp, rust-orange iron, sun-faded red
pads; the live ring ropes glossy (thread C's), the back runs faded, matte, thinner. **The town's things**
whole and bright: paper, marigolds. **Warm places** (the tea shop, the spring): amber as colour on their
surfaces, never a glow. The summit's plants: a cushion of moss with small pink flowers, a silver
star-flower on short stems, a tuft of gold grass, each ONE FLAT PAINTED CARD (its parts flush colours on one
plane, only its outline inked, the station's foreground plants' style), standing on a little outcrop that
is part of its mass's own piece; never on ice, never in the play space.

A skin's origin is the middle of its box's x span at its foot, the middle of its depth (as the dress file
places it). "Skin (lines)" are a11.py's line numbers (a10.py's where it says); z ranges are where the
piece stands.

## 1. Walls, masses, skins, far cards and the big pieces (maker A)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `cumbre_cloud_bank_far` | 130.0 x 26.0 x 0.2 | foot (x -355, y 940), z -22.2 .. -22.0 | The sheet's layers, every page: OUR OWN CLOUD, the furthest of three low banks (in place of a11.py's flat card at -22): plain white, a few big calm round heads with their tops between 961 and 966 m, a nearly flat underside, the form inside as colour only (pale `#D6DCEA` shadow shapes low in the body), matching the far sea's calmer banks (the kit's `peak_cloud_bank_a/b`); cloud-coloured edges, no ink inside; so the summit stands in cloud to its ankles | 1 | A |
| `cumbre_cloud_bank_mid` | 130.0 x 23.0 x 0.2 | foot (x -355, y 940), z -10.2 .. -10.0 | The middle bank, the same, its heads to 958 .. 963 m in another rhythm | 1 | A |
| `cumbre_cloud_bank_near` | 130.0 x 21.0 x 0.2 | foot (x -355, y 940), z -5.2 .. -5.0 | The nearest bank, the same, its heads to 957 .. 961 m; still behind the climb (note 40) | 1 | A |
| `cumbre_peak_back` | 75.0 x 48.0 x 0.6 | foot (x -354.5, y 953), z -3.4 .. -2.8 (its face -3.0) | Every page: THE PEAK'S OWN BACK (in place of the card at z -3): warm tan rock, one painted piece in big slanted planes, its bedding long wavy lines of three tans, duller than any rock you stand on; an uneven skyline standing 4 to 5 m over the dome's white back (card outline (-318, 966), (-324, 973), (-336, 980), (-347, 987), (-357, 992.5)), coming to a BLUNT HEAD at 1000.8 m behind the bell post's foot (x -358 .. -362.6), dipping to 991 over the notch (-366) and rising west to 1001 at x -392; its east edge a BROKEN BUTTRESS (never a straight cut at -318); its foot meeting the storm ridge's slate in a line at 962 and, east of the slate, going down to 953 with the teeth; a few little outcrops proud to -2.8 (at (-343.5, 981.4), (-338, 978), (-352, 987.6), (-376.6, 995.4)) whose tops carry the plants; the west staff stands on its skyline at x -382 | 1 | A |
| `cumbre_dome` | 39.6 x 32.4 x 3.4 | skin (lines 46-47 and 50: x -369.6 .. -330, 968.2 .. 1000.6), z -2.2 .. +1.2 | Every page: THE SUMMIT'S BODY in black ice, one painted piece: the PROW (a real break, its lip at (-330, 968.6), its underside flat planes with a hard white glint and its painted shadow, NO ICICLES, the shop's amber as colour on its facets over x -339 .. -333) carried back to the tea wall's top and the chute's back wall (-2.2); the dome's back pouring east at 38.7 and 35 degrees; the TUNNEL'S ROOF (from (-349, 970.4) to (-366.5, 982.6)) carried back to -2.2; the east cliff; the APEX the bell post is footed in (999.6 .. 1000.6); the west face down to THE EAVE (the last 4.4 m turned out 3.1 m west, 42 degrees, its lip at (-369.6, 983) over the sink), roofing the doorstep and the frost wall. Bands in three blue-black tones, glints, cracks, lines of rime as long wavy lines; nothing that could catch: its lines exactly the course's | 1 | A |
| `cumbre_shoulder` | 41.2 x 34.0 x 4.2 | skin (every convex piece of line 125: x -390.2 .. -349, 962 .. 996), z -3.0 .. +1.2 | 11.0, 11.1: THE WEST SHOULDER, black ice in a few big planes, wavy blue-black bands; the TUNNEL'S FLOOR (from (-349, 966) to (-372, 982)) carried back to the chute's back wall; where it is cut away to the camera (the cave x -379.6 .. -364, 969.8 .. 974.9; THE SINK, a round hole 4.5 m across at (-372.9, 982.7) .. (-366.5, 978.3) and its shaft 3 m wide (x -371.4 .. -368.4) down to the cave's roof; the stair's chimney (x -367.7 .. -366.8, 973.7 .. 978.6); the slide's mouth at the cave's west end, down through the floor at 962, x -379.6 .. -377) the ice is a skin over WARM ROCK, a band about 1 m thick round each cut: ochre and cream, crusted with pale mineral, long wavy bands, no frost; the sink's shaft smooth wet warm rock, the chimney and the slide's mouth dark and wet, their inside walls back to -1.5; behind the cave its body carried to -3.0 (the cave's inside is `cumbre_spring_cave`); 0.7 m of rock between the sink and the chimney | 1 | A |
| `cumbre_snow_cap_dome` | 31.8 x 29.9 x 0.05 | foot (x -349.4, y 969.9), z 2.0 .. 2.05, made in place | FOREGROUND, every page: THE DOME'S SNOW CAP (to the card's outline, a11.py 333-334: (-333.5, 969.9), (-340, 975.4), (-358.9, 988.6), (-359.6, 999.2), (-360.3, 999.8), (-361, 999), (-365.3, 984.6), (-349, 972), (-341, 969.9)): white, matte, soft-edged, set about 1 m in from the line a body slides on and 1.5 m up from the prow's underside, so the ice shows below it as a dark wet rim; in front of solid ice only. The cards come out only when it lands | 1 | A |
| `cumbre_snow_cap_shoulder` | 14.3 x 31.2 x 0.05 | foot (x -382.35, y 963), z 2.0 .. 2.05, made in place | FOREGROUND 11.0: THE SHOULDER'S CAP, CUT BACK (page 11.0): the same snow, set 1.3 m back from the slope ((-389.5, 994.2) to (-375.2, 983.2)), its east edge x -375.2 down to 976.4, then x -380.6 down to 963 (outline (-389.5, 963), (-380.6, 963), (-380.6, 976.4), (-375.2, 976.4), (-375.2, 983.2), (-389.5, 994.2)): it never covers the cave, the sink, the stair or the slide | 1 | A |
| `cumbre_tea_floor` | 17.0 x 3.0 x 2.5 | skin (line 166 and a10.py line 55: x -349 .. -332, 962 .. 965), z -1.3 .. +1.2 | 11.1: THE TEA LEDGE'S FLOOR, ONE SUMMIT ROCK (in place of a10's slate skin `tormenta_exit_slab`): warm cream, rounded and dry, the slab's gentle rise to the west (964 at x -340 to 965 at -349), a few scrape marks; its underside a line at 962 where the storm ridge's slate ends below it; on its east end's front two old bolt holes with rust under them where the ladder's top bracket was; THE TEA FROG'S WOVEN DOORMAT painted flush on its top in front of the chute's mouth (x -348.9 .. -346.9: stripes of turquoise, marigold and rosa, fringed); carried back to the back wall's foot | 1 | A |
| `cumbre_tea_back_wall` | 17.7 x 6.4 x 2.5 | foot (x -340.15, y 964), z -3.8 .. -1.3, made in place | 11.1: THE LEDGE'S BACK WALL, the summit's tan rock a step duller than the floor, one painted piece, bedding long wavy lines of three tans, no blocks; from the floor to the prow's underside (outline (-349, 965), (-340, 964), (-331.9, 964), (-331.3, 968.22), (-341, 968.4), (-349, 970.4)); its FACE AT -1.3 up to the lintel's line (966.8), there a dry shelf, and above it the face set back to -2.1 under the prow, where TWO IRON EYES for the awning are let in at (-340.5, 968.0) and (-331.5, 968.0); the prow's black ice comes down onto its top in a glazed edge; the shop's room cut into it (x -339.5 .. -333.5, 964 .. 966.6); one little outcrop at its foot by the tunnel (x -347.6, top 965.6, proud to -1.27) for the moss; its west end against the chute's mouth (x -349) | 1 | A |
| `cumbre_tea_room` | 6.0 x 2.6 x 2.5 | foot (x -336.5, y 964), z -3.8 .. -1.3 | 11.1 (note 97): THE TEA SHOP'S ROOM cut into the back wall, front open so you look straight in: a plank floor, plank walls and ceiling, a plank lintel, honey; WARM AMBER on every surface to its back (from the lantern and the stove: colour, never a glow), so it is a lit room and never a dark slot; a hole in its ceiling over the stove (x -334.1) for the tin pipe | 1 | A |
| `cumbre_chute_back` | 16.6 x 15.97 x 0.2 | foot (x -357.3, y 966), z -2.2 .. -2.0, made in place | 11.1, 11.0: THE TEAHOUSE CHUTE'S BACK WALL (in place of the tunnel's dark card): dark blue-violet ice in long painted bands running down the tunnel, from the frost wall's east face to the mouth (outline (-365.6, 977.55), (-349, 966), (-349, 970.4), (-365.6, 981.97)); the darkest part of the picture with the prow's underside, never flat black | 1 | A |
| `cumbre_tooth_a` | 2.8 x 17.25 x 0.35 | foot (x -325.6, y 953), z -1.65 .. -1.3 | 11.2: THE FIRST TOOTH OF THE CROWN, a needle of the summit's tan rock one layer back (face -1.4), one painted piece in two or three slanted planes, long wavy bedding, a leaning notched outline, 2.5 m wide at 958 narrowing to a BLUNT TIP just under its gold (970.25; the boss's neck comes forward from it); carried down to 953 into the storm ridge's cloud top; one little outcrop (top (-325.9, 964.6), proud to -1.3) for a tuft of gold grass | 1 | A |
| `cumbre_tooth_b` | 2.5 x 6.77 x 0.35 | foot (x -332.6, y 969.68), z -1.65 .. -1.3 | 11.2: the second tooth, standing up from behind the dome (its foot 1 m under the dome's surface), the same, its tip at 976.45; outcrop top (-332.9, 972.6) for a star-flower | 1 | A |
| `cumbre_tooth_c` | 2.5 x 6.37 x 0.35 | foot (x -339.6, y 975.28), z -1.65 .. -1.3 | 11.2: the third tooth, the same, from behind the dome, its tip at 981.65; outcrop top (-339.9, 977.8) for gold grass | 1 | A |
| `cumbre_tooth_d` | 3.1 x 26.65 x 0.35 | foot (x -328.75, y 953), z -1.65 .. -1.3 | 11.1, 11.2: the fourth tooth, the same (2.5 m wide at 958, tip 979.65), with THE SPUR on its west flank 14 m under its gold: a knuckle of rock (outline (-329.5, 963.6), (-330.3, 965), (-330.05, 965.75), (-329.55, 965.75), (-329.4, 965.2)) with an iron eye bolt in its tip at 965.75 (the first ring's pin goes into it); outcrop top (-328.2, 971.5) for a star-flower | 1 | A |
| `cumbre_tooth_e` | 4.2 x 28.65 x 1.05 | foot (x -321.5, y 953), z -2.3 .. -1.25 | 11.2, 11.3: THE FIFTH TOOTH, stouter (3.4 m wide at 958), its needle's face at -1.4; at 979.2 its body makes THE STEP, 4.2 m wide (x -323.6 .. -319.4), whose front edge is the shelf, carried on 1 m further back (its top from -1.25 to -2.3: a real break, the fallen post lies on it); above the step the needle to a blunt tip at 981.65; outcrop top (-322, 972) for gold grass | 1 | A |
| `cumbre_pillar_west` | 8.6 x 31.4 x 0.5 | foot (x -330.1, y 953), z -2.3 .. -1.8 | 11.2, 11.3: THE PILLAR UNDER THE WEST POST (in place of the root card), tan rock, one painted piece in two or three slanted planes, wavy bedding, a leaning notched outline ((-334, 961.5) .. (-326.2, 961.5) up to (-332.6, 984.4) .. (-327.2, 984.4), carried down to 953); its TOP 2 M CUT SQUARE AS A PLINTH for its post, the cut edge chipped; the floor beam's west end let into it at 983.6 .. 984; two little outcrops sticking out of its flanks (tops (-333.6, 978.6), (-326.3, 977.4)) for moss and gold grass; the storm ridge's buttress top meets its face (a10_dress) | 1 | A |
| `cumbre_pillar_east` | 7.2 x 43.5 x 0.5 | foot (x -321.8, y 953), z -2.3 .. -1.8 | 11.2, 11.3: the pillar under the east post, the same ((-325, 961.5) .. (-318.6, 961.5) up to (-323.5, 985.8) .. (-319.8, 985.8)), its plinth; behind the east post it carries on up as a THIN BACK BLADE 2 m wide (x -321 .. -318.9, to 996.5); one outcrop (top (-318.8, 984.2)) for moss | 1 | A |
| `cumbre_splinter` | 3.23 x 21.55 x 0.5 | foot (x -334.34, y 976.5), z -1.9 .. -1.4, made in place | 11.3, 11.4: THE SPLINTER that carries the ring of the last leap: a splinter of the west pillar, split off its flank at 976.5 (its foot let into the pillar, back to -1.9) and standing 21 m, leaning 3 m west into the wind (outline (-333.08, 976.5), (-332.72, 982.5), (-335.45, 998.05), (-335.95, 998.05)), to a point too narrow to stand on 0.15 under the ring; tan rock, bedding along its length; an iron eye bolt in its point (the ring's long pin goes into it, -1.58) | 1 | A |
| `cumbre_ring_apron` | 6.8 x 2.75 x 0.45 | foot (x -326, y 981.6), z -2.15 .. -1.7 | 11.3: THE RING'S LAST FLOOR BEAM AND ITS APRON (in place of the canvas strip): one beam of WEATHERED GREY timber 0.4 square at 983.6 .. 984.0 (x -329.4 .. -322.6), its ends let into the two pillars, the broken stubs of five joists standing up off it between the posts (to 984.35); the CREAM CANVAS folded over it and hanging down its front 1.7 m as a TORN APRON (x -328.6 .. -323.2, ragged hem 981.6 .. 982.3), A FADED PUG'S FACE on it (0.85 across, at (-325.9, 982.75)); matte; from the shelf the first thing that says this was a ring | 1 | A |
| `cumbre_shelf` | 2.6 x 2.3 x 2.45 | skin (lines 188, 192: x -322.9 .. -320.3, 976.9 .. 979.2), z -1.25 .. +1.2 | 11.2, 11.3: THE SHELF: its top warm dry summit rock 2.6 m wide (978.6 .. 979.2); its ICED BELLY glazed black ice (976.9 .. 978.7), no pale mark on it; the front edge of the fifth tooth's step | 1 | A |
| `cumbre_perch` | 2.1 x 0.8 x 2.45 | skin (line 296: x -359.1 .. -357, 997.9 .. 998.7), z -1.25 .. +1.2 | 11.5: THE PERCH, the timekeeper's seat: warm dry summit rock 2.1 m wide, the top of the rib behind it; the last place you stand on stone (the one who sits is the game's statue) | 1 | A |
| `cumbre_perch_rib` | 2.9 x 10.7 x 0.9 | foot (x -358.15, y 988), z -2.2 .. -1.3, made in place | 11.5 (KIT_MORE "rock step"): THE RIB under the perch, warm tan rock coming forward out of the peak's back (outline (-359.6, 988), (-357.6, 988), (-356.7, 998.2), (-356.7, 998.7), (-359.6, 998.7)), wavy bedding; its top carried on 1 m behind the perch at 998.7, where his marigolds lie | 1 | A |
| `cumbre_doorstep` | 1.9 x 0.4 x 2.7 | skin (lines 129, 130: x -368.4 .. -366.5, 977.9 .. 978.3), z -1.5 .. +1.2 | 11.0: THE DOORSTEP, warm dry summit rock cut level into the slope at 978.3 under the eave, in two parts with the stair's chimney mouth between (x -367.7 .. -366.8), two frog prints worn into it; carried back to the sink's back | 1 | A |
| `cumbre_frost_wall` | 0.9 x 5.05 x 3.2 | skin (line 133: x -366.5 .. -365.6, 977.55 .. 982.6), z -2.0 .. +1.2 | 11.0 (note 102), the mountain's breakable door: HOARFROST across the tunnel's top under the dome's west corner, 0.9 thick, the rime's look (grey-white feathers, matte, cracked across), a corner gone at its foot (the tea frog's own door, (-366.5, 978.3) .. (-366.15, 978.06) .. (-366.5, 978.75)); across the tunnel to its back wall (-2.0). Whole only: it is the crumble hold's own piece (it goes with it and comes back with it); breaking and growing back are effects | 1 | A |
| `cumbre_rime_nose` | 0.8 x 0.45 x 1.95 | skin (line 176: x -331.5 .. -330.7, 965.175 .. 965.625), z -1.65 .. +0.3 | 11.1, 11.2: THE RIME NOSE, frost the west wind built on the spur: grey-white frost feathers, pale and matte, cracked across, its east corner gone, grown west toward the ledge, exactly the size that holds, running back to the spur's face | 1 | A |
| `cumbre_rime_collar` | 1.6 x 0.5 x 1.95 | skin (line 184: each collar x jx ± 0.8, jy - 2.3 .. jy - 1.8), z -1.65 .. +0.3 | 11.2: A RIME COLLAR under a gold boss, the same frost, wrapping its needle (round its back to -1.65) and coming forward to you, cracked across, the east corner gone (`a11_areas._rime`); one each, so each goes and comes back with its own step | 4 | A |
| `cumbre_rime_block` | 1.0 x 0.8 x 0.8 | skin (line 189: x -322.1 .. -321.1, 979.2 .. 980.0), z -0.4 .. +0.4 | 11.2, 11.3: THE RIME BLOCK on the shelf, frost built on the windward side of the fifth needle, the same look | 1 | A |
| `cumbre_spring_bank` | 4.2 x 1.2 x 2.45 | skin (lines 150, 151: x -368.2 .. -364, 969.8 .. 971), z -1.25 .. +1.2 | 11.0: THE BANK, 2.8 m of dry pale mineral crust (x -366.8 .. -364, top 971), matte, the place to climb out and sit; west of it THE SLICK LIP, glossy wet crust falling from the bank into the pool (a slope: whatever lands on it slides back in), three rounded glossy wet stones on it (the page's rim stones: never a hold, a11_dress 7f) | 1 | A |
| `cumbre_slide_rim` | 0.4 x 1.1 x 2.45 | skin (line 156: x -377.4 .. -377, 969.8 .. 970.9), z -1.25 .. +1.2 | 11.0: THE SLIDE'S RIM, a low rim of rounded warm stone standing 0.3 out of the water at the pool's far west end, crusted with mineral, dry on top (it can be stood on) | 1 | A |
| `cumbre_spring_cave` | 15.6 x 5.2 x 1.95 | foot (x -371.8, y 969.8), z -3.2 .. -1.25 (its back wall's face -3.0), made in place | 11.0: THE FROGS' HOT SPRING, the cave inside the shoulder, cut away at the front: ochre and cream rock crusted with pale mineral, painted in long wavy bands, no ice; dark and wet above the steam; the roof's underside carried back (974.0 east, falling to 974.9 at the west wall, `a11_areas._CAVE`); along the back wall A LEDGE 6 m long for frogs (x -376 .. -370, top 972.6, out to -2.6); a crack low in the east wall where a rill leaves (x -364 .. -363.6, 971 .. 971.4); THE POOL'S BACK HALF (x -377 .. -368.2): milky blue-green water, its surface flush at 970.6 from -1.25 back to the wall (the front half is the game's water), its basin's back rim of rounded stones; the bank's back half (the table and towels stand on it at 971) | 1 | A |

## 2. Plants, signs and the tea shop's things (maker B)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `cumbre_moss_pink` | 0.5 x 0.3 x 0.01 | foot | THE SUMMIT'S PLANT: a low cushion of moss with small pink flowers, one flat painted card (its parts flush colours on one plane, only its outline inked), on a little outcrop: the tea wall by the tunnel (z -1.29), the peak's back twice (z -2.85), the west pillar and the east pillar (z -1.66) | 5 | B |
| `cumbre_star_flower` | 0.3 x 0.45 x 0.01 | foot | THE SUMMIT'S PLANT: silver star-flowers on short stems, one flat painted card; on the second and fourth teeth (z -1.36) and the peak's back | 3 | B |
| `cumbre_grass_gold` | 0.6 x 0.5 x 0.01 | foot | THE SUMMIT'S PLANT: a tuft of gold grass, one flat painted card; on the first, third and fifth teeth (z -1.36), the west pillar, the peak's back twice | 6 | B |
| `cumbre_sign_cup` | 0.8 x 0.6 x 0.06 | foot (x -336.6, y 966.8), z -1.39 .. -1.33 | 11.1: THE TEA SHOP'S SIGN, a board standing on the shelf over the lintel: a painted cup with a curl of steam, no words, in the town's colours on bone | 1 | B |
| `cumbre_sign_frog_pool` | 0.7 x 0.7 x 0.06 | the middle of its foot line, on the wall or the strut | 11.1, 11.0, 11.6: THE FROG'S SIGN FOR THE SPRING: a painted board, a frog in a pool under a curl of steam, no words (the tea sign's fellow); beside the chute's mouth on the back wall (-348.05, 965.95, z -1.33) and on the bell frame's strut under the beam's west end (-361.6, 1001.65, z -2.28) | 2 | B |
| `cumbre_sign_frog_slide` | 0.7 x 0.7 x 0.06 | the middle of its foot line, on the cave's back wall (-378.8, 972.9, z -2.97) | 11.0: the second board, over the slide's mouth: a frog on a slide, no words | 1 | B |
| `cumbre_tea_counter` | 2.4 x 0.9 x 0.6 | foot (x -336.4, y 964), z -2.4 .. -1.8 | 11.1: THE COUNTER, honey planks under a STRIPED CLOTH (rosa, marigold, turquoise, cream) hanging down its front, its top at 964.9 (the cups and the pot stand on it) | 1 | B |
| `cumbre_tea_crate` | 0.45 x 0.8 x 0.4 | foot (x -336.4, y 964), z -2.85 .. -2.45 | 11.1: the frog's upturned crate behind the counter (the frog stands on it at 964.8, its head and hands over the counter's top), honey slats, mostly hidden | 1 | B |
| `cumbre_tea_stool` | 0.4 x 0.5 x 0.4 | foot | 11.1: a plank stool at each end of the counter, just inside the recess, honey, three legs | 2 | B |
| `cumbre_tea_spout` | 0.9 x 1.3 x 0.8 | foot (x -338.95, y 964), z -3.8 .. -3.0 | 11.1: THE WARM SPOUT in the room's west corner: a stone basin on the floor (0.8 x 0.45), a stone spout in the wall above it at 965.2, a thread of warm water between them (a thin glossy strip, milky blue-green), mineral crust on the basin's lip; the steam is the game's | 1 | B |
| `cumbre_towels` | 0.6 x 0.45 x 0.45 | foot (x -364.55, y 971), z -1.98 .. -1.53 | 11.0: a pile of folded towels at the back of the bank, cream with rosa and turquoise stripes, the top one a little askew | 1 | B |

## 3. The ring, iron and timber (maker C)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `cumbre_post_west` | 4.7 x 11.12 x 3.5 | skin (lines 246-247 and 268: x -332.2 .. -327.5, 984.085 .. 995.2), z -2.3 .. +1.2 | 11.3 (Parker: "does not look like the ruin of a ring"): THE RING'S WEST CORNER POST, the horn cut square: a shaft of dark rock glazed with black ice 2.2 m thick, its THREE TURNBUCKLE BLOCKS standing out of its inner face one above the other (each 3.6 m tall and 2.5 m deep, to -1.3, its face sloping EXACTLY along its rope's line 0.2 behind it: `a11_areas._HORN_W`), long wavy bands of blue-black in three tones, white glints, AN IRON BAND PAINTED round the shaft at each rope's eye (987.8, 991.4, at the blocks' tops); nothing pale on it but its top: 2.6 m of warm dry summit rock (994.7 .. 995.2); its outer foot loses a corner 0.6 m a side; the shaft carried back to -2.3 standing on the pillar's plinth. Cannot be held | 1 | C |
| `cumbre_post_east` | 4.7 x 14.31 x 3.5 | skin (lines 248 and 251: x -323.3 .. -318.6, 985.585 .. 999.9), z -2.3 .. +1.2 | 11.3: the east corner post, the same (the shaft as thick as the west's now that its outer face moved east), its blocks facing west (`_HORN_E`), its top cut LEVEL at 998.5 (chipped along the cut) and carried back to carry the grey timber head at -1.5, its glazed ICE TIP at the inner corner to 999.9 | 1 | C |
| `cumbre_gold_boss` | 0.52 x 0.52 x 1.66 | its lowest point (a hold of r 0.26, eight-sided), z -1.4 .. +0.26 | 11.2: A GOLD BOSS OF THE CROWN, eight-sided, 0.52 across, BRUSHED MATTE GOLD, the pug's face struck faintly on it, pinned to the tip of its tooth by a short BRONZE NECK running back from the boss (z -0.26) to the needle's tip (-1.4) | 5 | C |
| `cumbre_bell_hanger` | 0.5 x 0.35 x 0.8 | skin (line 288, shortened: x -355.95 .. -355.45, 1004.95 .. 1005.3), z -0.4 .. +0.4 | 11.5: THE BELL'S HANGER, rust-orange iron: a strap from the beam's underside and the pin the bell swings on (you can see it turn; the fork that holds the bell's crown is `cumbre_bell`'s). Held | 1 | C |
| `cumbre_bell_strut` | 2.4 x 3.35 x 1.7 | foot (x -361.35, y 1000.8), z -3.0 .. -1.3, made in place | 11.5, 11.6, 11.0 (KIT_MORE): THE FRAME'S BACK STRUT, a square honey timber 0.3 thick from the cleat at the post's back ((-360.3, 1004.0), z -1.3) down to the head of the peak's back ((-362.4, 1000.8), z -3.0), bolted at each end through an iron plate; so a frame with one post is seen to be held | 1 | C |
| `cumbre_bell_staff` | 0.2 x 8.2 x 0.75 | foot (x -360.3, y 1003), z -2.05 .. -1.3, made in place | 11.4 to 11.6b (KIT_MORE): THE BELL STAFF, a thin honey flagstaff 8.2 m lashed to the cleat at the post's back and raked back (foot z -1.3, top -2.05 at 1011.2), its top 4.8 m over the post's top; hidden by the post from the side until it rises above the belt; a ring at its top where the two long lines are tied | 1 | C |
| `cumbre_flagstaff` | 0.2 x 6.3 x 0.75 | foot (x -332, y 995.2), z -2.05 .. -1.3, made in place | 11.3, 11.4: THE FLAGSTAFF at the back of the west post's top, behind the timber head (a11_dress 7i), raked back, its top 3.3 m over the pad (1001.5) and 2 m back, carrying the jade back run's west end and the paper over the leap; thin honey, a ring at its top. Also the west staff on the peak's back at 0.873 (5.5 m, foot (-381.95, 997.15), z -2.85 .. -2.2) | 2 | C |
| `cumbre_back_rope_jade` | 12.6 x 0.75 x 0.6 | foot (x -325.7, y 1000.9), z -2.05 .. -1.45, made in place | 11.3: THE BACK RUN OF THE JADE TOP ROPE, still spanning the top of the ring from the flagstaff's top ((-332, 1001.5), z -2.0) to the east head's top ((-319.4, 1001.5), z -1.5), sagging 0.3: 0.3 thick, FADED jade, matte, frayed in places, thinner-looking than the live ropes (never glossy); the town's paper hangs on it (`papel_string`) | 1 | C |
| `cumbre_back_rope_end_red` | 0.4 x 1.8 x 0.3 | foot (its frayed end; it hangs from the eye at its top), z -1.6 .. -1.3 | 11.3: A SNAPPED BACK RUN of the red bottom rope, 1.8 m, faded red, matte, frayed at its end, hanging down the back of a post from the iron eye at the red rope's top (west (-330.05, 987.8); east (-320.75, 989.3), flipped); a slight curl | 2 | C |
| `cumbre_back_rope_end_cream` | 0.4 x 1.8 x 0.3 | as the red | 11.3: the same of the cream middle rope (west (-330, 991.4); east (-320.75, 992.9), flipped) | 2 | C |
| `cumbre_tea_pipe` | 0.16 x 1.85 x 0.16 | foot (x -334.1, y 964.75: the stove's top), z -2.8 | 11.1: the stove's TIN PIPE, dull grey tin with two seams, from the stove's top up through the room's ceiling (966.6) | 1 | C |
| `cumbre_tea_cowl` | 0.6 x 0.45 x 0.2 | foot (x -334.1, y 967.2), z -2.1 .. -1.9 | 11.1: the pipe's COWL where it comes out of the set-back wall 3.4 m above the floor: a short stub of tin pipe and a little hat-shaped cowl, sooty at its mouth (the smoke runs east under the prow: the game's) | 1 | C |

## 4. Made for a11.py and the game, not placed by the dress file (FOR THE AREA FILE items 6, 8)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `cumbre_bell_clapper` | 0.34 x 3.35 x 0.34 | THE PIN (the bell's hanging point, (-355.7, 1005.15)) | 11.5 (note 100): THE CLAPPER, an iron rod from the pin down through the bell to a round iron ball 0.34 across a hand's breadth under the lip (to 1001.8); dark iron; it swings on its own quicker spring and strikes the bell's side (peak_things.gd _find_bell: in place of the stand-in rod and ball) | (the game) | C |
| `cumbre_toll_handle` | 0.5 x 0.3 x 0.3 | its hanging point (its top: the game hangs a bob's model by it) | 11.0, 11.5: THE WOODEN TOLL HANDLE on the end of the bell rope and of the frogs' stair: a turned honey bar 0.5 wide with the rope through its middle and a knot under it, dry and matte (both ropes' `bob`, a11.py lines 142 and 290) | (2 bobs) | C |

## 5. Re-makes of existing models (each lands as a NEW stem; the original is not touched)

- **`cumbre_timber_head`** (C; from `ring_post`; placed 1: skin of the corner post, line 269, at (-332,
  995.2), z -0.2 .. 0.2, 0.4 x 3.0 x 0.4): THE WEST POST'S TIMBER HEAD at the course's box: square HONEY
  timber 0.4 thick, 3 m tall, adzed, pegged; its THREE IRON TURNBUCKLE EYES up its east face 0.9 m apart
  like rungs (at 996.0, 996.9, 997.8, standing 0.12 out of the face: the kit's turnbuckles toward +x), rust
  orange; on its top A RED PAD 0.3 thick (997.9 .. 998.2: the kit's `ring_corner_pad`'s sun-faded red, its
  top bleached, no tear: it is stood on). The only timber in the ring you can hold; climbed like a
  turnbuckle and jumped from (note 99).
- **`cumbre_timber_head_grey`** (C; from `ring_post`; placed 1: the east post's head at (-319.4, 998.5), z
  -1.7 .. -1.3, flipped so its eyes face west into the ring): the same head in WEATHERED GREY timber (the
  sheet: "timber you can't reach is grey"), its pad faded to a dull pink with a slanted tear and the cream
  stuffing showing (the kit pad's tear), its eyes rust-dark.
- **`cumbre_timber_head_fallen`** (C; from `ring_post`; placed 1: lying on the fifth tooth's step at
  (-319.9, 979.2), z -1.7 .. -1.3, 2.2 x 0.4 x 0.4): the third corner post's head BROKEN OFF AT 2.2 M and
  lying on its side, weathered grey, its broken west end splintered pale, its red pad (faded, torn) at its
  east end out over the drop (x -319.05 .. -318.8); room on that end for the frog that shows the move to sit
  (the game's `frog_sit`, a11_dress.ROPE_FROG_REST).
- **`cumbre_bell_frame`** (C; from `bell_frame`; placed 1: skin of the post, beam and brace, lines 285-287,
  6.8 x 7.1 x 1.55, z -1.3 .. +0.25): THE BELL FRAME AT THE COURSE'S SIZES (the kit's is 5 x 6 and grey):
  HONEY timber squared with an adze, the post 0.5 thick (x -360.55 .. -360.05, 999.8 .. 1006.4) footed in the
  apex, the beam 6.8 m (x -361.6 .. -354.8, 1005.3 .. 1005.7), the brace 0.25 from (-360.3, 1002.4) to
  (-357.6, 1005.3), pegged; THE MARIGOLD GARLAND PRESSED FLAT wound up the post's face (four turns, 1000.3 ..
  1005.1) and laid along the beam's front face, part of the timber; THE BELT'S TWO BRONZE PEGS 0.5 m tall on
  the post's top at x -360.5 and -360.1 (1006.4 .. 1006.9; the belt itself is `champion_belt`, the Top Dog
  session's); a square cleat run back from the post's back at 1003 .. 1004.2 to z -1.3 (the strut and the
  bell staff are lashed to it), hidden behind the post.
- **`cumbre_bell`** (C; from `summit_bell`; not placed here: the bell rope's mover look, a11.py line 359,
  at (-355.7, 1005.15)): THE BELL RE-MADE TO SWING: bronze, matte, 2.2 m across and 2.6 m tall (its crown at
  1004.8, its mouth at 1002.2, where the rope's top is), the First Top Dog's face cast on the side toward the
  camera (the kit bell's mask); ORIGIN THE PIN, 0.35 above its crown, with the rust-orange iron FORK that
  holds the crown hung from it (the part of the yoke that swings); NO CLAPPER (`cumbre_bell_clapper`, section
  4) and its mouth open so the clapper shows under the lip when it tips. Solid in the course (item 6b): drawn
  exactly to the shape that is held.
