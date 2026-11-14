# La Cresta de la Tormenta: the models to make

The model list for biome 10, from its dress file `tools/peak/areas/a10_dress.py` (128 decos, 48 of them
skins). Every stem in sections 1 to 3 is NEW: not in `kit/models/` nor in `Top Dog Kit\models\`, nor on
the a0 to a9 lists: 69 placed by the dress file, and 2 more made for a10.py and the game (section 4).
Then five re-makes of kit models, each landing as a new stem (section 5). Make each at exactly its size
(metres, w x h x d; +z faces the camera). The game rescales a landed model that is more than a quarter
off; a skin is never rescaled, so a skin is made to its box exactly.

Reused (not listed): `prayer_pole` (the cabin's west corner, moved 1.4 m east), `frog_rain_hat` (the
cabin's frog, page 10.0), `tea_kettle` and `tea_cup` (the keeper's kettle, the same as the cliffs' and the
glacier's; the frog's cup), `mine_frog_stove` (the cabin's stove), `lantern_hang` (the cabin's one lamp,
the only lit lamp on the ridge), `sign_pug_bolt` (wave 0, note 95: on the hut's wall), `rain_gauge`,
`lantern_cold` (the station's dead lantern on the eave), `vane_mast` (under the hub, on its shoe),
`prayer_flag` (4: the torn ends on the pole and the three posts, 1.3 m back), `timber_brace` (at 0.72:
the line pole's back brace), `tele_cable` (a8's black greased cable, at 0.951: the balloon's cable),
and a9's `glaciar_verglas_nose` keeps the porch's glazed first metre. Not used: `streamer_pole` (the
pages give every band a sock, a torn end or paper instead), `insulator` (the seven porcelain stacks are
part of `tormenta_mast_timber`), `balloon_tether` (replaced by the cable), `rung_stub` (cut down to two
nubs painted on the face), `sign_pug_arrow` (its board is on `tormenta_guide_post`), `mine_hand_winch`
(0.8 deep: it would stand in the summit's pillar; the page asks 0.45). NOTHING CLIMBER-SHAPED is on this
list: the one who waited on the station's deck stays the game's statue until the new climber model lands
(MODELLING_RUN; Parker 11-13). The tea shop with a frog (note 97) is on the exit ledge's top, the
summit's (biome 11's) to dress.

Makers: **A** rock walls and masses as painted pieces, every skin of slate, the far card, the cloud
(collars, banks, La Nube's bank, top and rib), the cabin's building, the hut (section 5). **B** small
dressing: the snow lip, the cabin's table, bunk and coat, the wind slate; the sandbag; the grey sock and
the kite (section 5). **C** timber and iron: the line pole and posts, the station's deck, the mast's
timber and steel, the headwall's rungs, the winch and its guide post, the vane's shoe and head, the reels,
stubs, arms, braces, the cradle, the stove pipe, the yards; the rung that hangs; the vane and the balloon
(section 5).

The ridge's look (the sheet `docs/peak/playtest/design/data/a10_biome.py`, notes 92, 94 to 96): **slate
is cut, its face is paint.** Wet slate (the face, El Alero, every tower's shaft and pointed foot, the
buttress's cap, the ridge's mass) is blue-black and glossy, a few big leaning planes; its cleavage is flat
colour in three or four blue-black tones, long wavy lines and bands that run the way the face leans (71
degrees, to the west); no ink inside a face; **nothing painted narrows to a point**; **no dark recess cut
into a face**; **no rain painted on rock** (the rain is the game's effect). Dry slate (pale warm grey,
matte, broken in small square steps, a crisp edge round each scar) is only on the flat tops and on the
scars. Quartz knobs are plain white blocks, dry, matte, a hand's width of dry slate round each. Designed
outlines: away from the tops, scars and knobs a tower's edge may lean and be notched up to 0.8 m (never a
ruled upright, never a repeated square panel, never a slab built as its own block); NOTHING on the face
may catch a falling body, so the face's line stays exactly the course's. No plants anywhere ("anything
green" is never here). **Bodies and the flank** (scenery 1 to 3 m back) are the same slate duller,
greyer and cooler, the cleavage thin lines carrying on from the tower's. **Cloud** is flat cut-out banks
with round heads and a scalloped underside, dark below and paler on top, mid greys and slate blues,
NOTHING NEAR WHITE, no straight edge anywhere, no top you could stand on, never glossy. **Timber** is the
cableway's honey, square posts and thick planks, pegged, bolted through iron plates with the pug's face,
split plank ends, every burnt edge black. **Bare steel** (only on the mast, what the lightning takes) is
pale blue-grey, cold, matte, thin and round, rivet heads, scorched black at its joints; **greased steel**
(the line pole, the cable, the vane's arms) black and glossy. Where bare steel meets timber: white ribbed
porcelain. **Light is colour, never glow**: the cabin is amber inside as colour on its planks; nothing
glows (the game adds the cabin's two lights).

A skin's origin is the middle of its box's x span at its foot, the middle of its depth (as the dress file
places it). "Skin (lines)" are a10.py's line numbers (a9.py's where it says); z ranges are where the
piece stands.

## 1. Walls, masses, skins, the far card and the cloud (maker A)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `tormenta_far_towers` | 80.0 x 90.0 x 0.2 | foot (x -305, y 884), z -14.2 .. -14.0 | Every page: THE RIDGE'S FAR TOWERS, one flat painted card made the way the far cards are (the kit's `stn_far_hills`: a thick card whose cut edge shows kraft, a dark stripe, kraft, braces behind): a row of blades and needles going away along the crest, the same leaning slate shapes as the near towers (from El Filo they read as the nearest of many), their feet in painted cloud, the back ones hazed to the storm's grey, a few torn lines painted between them (one between two blades east of the pole, one in the Gendarmes gap); mid greys and slate blues, NOTHING NEAR WHITE; its foot a scalloped painted cloud underside, so the valley's last strip shows under it from the porch (a10_dress item 7h). 80 m wide: the cameras pulled back over Veleta and Gendarmes must not reach its east edge | 1 | A |
| `tormenta_face_low` | 21.06 x 41.62 x 4.6 | skin (line 51, the wall split at 923: its slab from (-307, 884) to (-320.5, 923), 8 m thick to the west), z -3.4 .. +1.2 | THE FACE, lower half: the edge of a mountain, wet slate in a few big leaning planes, blue-black and glossy, cleavage as long wavy bands leaning with the face; the fall line (everything that touches it slides to El Alero): its edge exactly the course's, smooth, nothing that could catch; carried back to the nook's wall (-3.4). At its foot the MOUTH OF THE FROGS' SLIDE'S TUNNEL (y 886.2 .. 888.7: the passage a10.py cuts, item 7c), its roof and floor inside the rock carried back to the tunnel's back wall (-2.4), the mouth's edges plain slate; west of the mouth the face meets the cabin's west wall and the prayer pole (behind) | 1 | A |
| `tormenta_face_high` | 21.06 x 41.62 x 4.6 | skin (line 51: the slab from (-320.5, 923) to (-334, 962)), z -3.4 .. +1.2 | THE FACE, upper half, the same slate (behind Veleta, Gendarmes, La Nube and the headwall); painted up the ladder's line (page 10.9): a pair of dark bolt holes 0.1 across at each of the six places a rung is gone (956.4, 957.6, 958.77, 959.33, 960.5, 961.65, 0.22 m west of the face's edge), each with a long rust streak running down the slate 0.8 m, a band of even width with a square end (never a taper); in the long gap two of the pairs each keep a black iron nub no longer than a thumb (the old stub cut down, a10_dress item 3); wet to the very top, water lines are the game's | 1 | A |
| `tormenta_ridge_mass` | 50.0 x 82.0 x 3.6 | skin (lines 283, 284 and a9.py line 95: x -362 .. -312, 880 .. 962), z -2.4 .. +1.2 | The ridge's mass: the face's own body carried west, the same wet slate a step darker and plainer, a few long bands; its top strip (284, 959.4 .. 962) dry pale slate in square steps under the summit's wall; THE FROGS' SLIDE'S TUNNEL runs through its foot (886.2 .. 888.7, x -362 .. the face), its roof and floor carried back to -2.4; it also covers st.py's tube slabs inside it (item 7b) | 1 | A |
| `tormenta_slide_tunnel_back` | 53.82 x 2.5 x 0.2 | foot (x -335.09, y 886.2), z -2.6 .. -2.4 | The back wall of the frogs' slide's tunnel through the ridge's foot (a10_dress item 7c): the ridge's rock inside, dark, dull blue-grey, a few long bands, from the region's west edge to the face (x -308.04) | 1 | A |
| `tormenta_alero` | 18.0 x 12.4 x 4.6 | skin (line 53: x -318 .. -300, 891.7 .. 904.1), z -3.4 .. +1.2 | 9 to 10, 10.0, 10.1: EL ALERO, the prow over the porch: wet slate, its cap 40 degrees, glossy and slick to its brink at (-300, 892) (the brink that throws every fall out over the glacier); its underside the cabin's roof, dry under the prow, dull, carried back to the nook's wall; let into the underside at (-302.05 .. -301.65, 892.15 .. 892.5) the torn line's square honey SPAR, its end flush in the rock, 0.35 m square, an iron pug plate on it, the spar running back 3.4 m along the underside to the nook's wall | 1 | A |
| `tormenta_porch` | 10.0 x 1.4 x 4.6 | skin (a9.py line 94: x -312 .. -302, 884.6 .. 886), z -3.4 .. +1.2 | 9 to 10, 10.0: THE PORCH: firm snow, white and matte, 0.3 thick with a square front edge on dry rock, combed by the wind into low ridges that all run east, a path one boot wide trodden flat from the cabin's east post (-303.1) to the ledge's end; carried back under the cabin to the nook's wall (the cabin stands on it); its west end goes under the face. The glazed first metre east of x -302.9 is a9's `glaciar_verglas_nose` | 1 | A |
| `tormenta_nook_wall` | 12.4 x 11.2 x 0.6 | foot (x -306.8, y 884.2), z -4.0 .. -3.4, made in place | 9 to 10, 10.0: THE NOOK'S BACK WALL: the ridge's flank under the prow, leaning ribs of wet slate running with water (painted, flush), the darkest thing in the picture so the cabin's amber sits in the middle of it; its top follows El Alero's underside and it carries on east to under the prow's tip (outline (-313, 884.2), (-301.5, 884.2), (-301.1, 886.8), (-300.6, 889.6), (-300.8, 891.9), (-313, 895.4)) | 1 | A |
| `tormenta_gap_wall` | 16.0 x 23.1 x 0.2 | foot (x -294.5, y 861.5), z -2.6 .. -2.4, made in place | 9 to 10 (in place of a9.py's card 399-400): THE GAP'S FAR WALL: the ridge's flank bared where the ice pulled away, wet slate in leaning slabs, dull blue-grey and in shadow, long pale scrapes low down where the ice dragged across it (bands of even width, square-ended); made to a9's outline ((-302.5, 878.7), (-296, 866.5), (-288, 861.5), (-286.5, 866.95), (-286.5, 871.8), (-295.9, 871.8), (-295.9, 881), (-302, 884.6)), with a HOLE round the slab hollow (x -292.6 .. -287.6, 864.2 .. 869.3) and one round the slab mouth's block (x -303.5 .. -298.9, 879.05 .. 882.05) | 1 | A |
| `tormenta_flank_a` | 13.6 x 20.5 x 0.6 | foot (x -312.8, y 897), z -3.6 .. -3.0, made in place | 10.2, 10.3: THE RIDGE'S FLANK, the first piece: the face's body 3 m behind the open air east of the face, dull blue-grey slate in two or three big leaning ribs with one or two real gullies, its cleavage thin lines; from 1 m inside the face to a stepped east edge about 5 m out (a10_areas._flank: steps every 3.5 m, 0.5 m in and out), its foot tucked behind El Alero's cap (at 897 its east edge meets the cap's edge); the station's body stands in front of its east part | 1 | A |
| `tormenta_flank_b` | 12.21 x 16.5 x 0.6 | foot (x -319.21, y 917.5), z -3.6 .. -3.0, made in place | 10.3, 10.4: the flank's second piece, the same, 917.5 .. 934 | 1 | A |
| `tormenta_flank_c` | 9.13 x 7.6 x 0.6 | foot (x -323.38, y 934), z -3.6 .. -3.0, made in place | 10.6: the last piece, under the buttress (it ends inside La Nube's cloud, 941.6) | 1 | A |
| `tormenta_filo` | 2.8 x 17.4 x 3.4 | skin (lines 76, 80, 86: x -297.6 .. -294.8, 885.2 .. 902.6), z -2.2 .. +1.2 | 10.1: EL FILO, one slab of slate on end, its cut edge 1 m thick: blue-black, glossy, undercut to a slick point at 885.2 (the shaft z -1.2 .. 1.2, so its point hangs in front of its collar); on its west side THE LANDING SCAR (889.6 .. 892.1, 0.36 proud), pale warm grey, dry, broken in small square steps, a crisp edge all round where the flake came away; THE TOP, the slab's flat dry head 2.8 m wide in square steps, carried back to the body (-2.2: the cradle, the brace and the stub stand on its back) | 1 | A |
| `tormenta_aguja` | 1.6 x 6.5 x 2.4 | skin (tower() line 103 and the spire 104: x -306.3 .. -304.7, 900.8 .. 907.3) | 10.2: LA AGUJA, a spire of wet slate, the rope way's turning post, undercut to a slick point at 900.8, its spire to 907.3; two iron rings on square pug plates on its west face where line 1 ends (905.2) and line 2 starts (906.8), small and dark. Cannot be held | 1 | A |
| `tormenta_station_tower` | 3.5 x 7.0 x 2.4 | skin (line 125: x -311.5 .. -308, 906 .. 913) | 10.3: the station's tower, wet slate, its shaft undercut to a slick point at 906; the deck on its top | 1 | A |
| `tormenta_torre` | 6.2 x 23.0 x 3.4 | skin (lines 166-169, 191, 194: x -291.2 .. -285, 920.5 .. 943.5), z -2.2 .. +1.2 | 10.4, 10.5: LA TORRE with its needle: the block undercut to a slick point at 920.5; its SCAR on the west face (928.6 .. 932.5, 3.9 m, pale, dry, stepped); THE SHOULDER's flat dry top (3.5 m) carried back to the body; the needle on its east half, blue-black and glossy from the shoulder to the top, its SCAR (937.5 .. 940.5) and its flat dry TOP (2.5 m) carried back (the brace and the torn end stand on it); the only pale things on its west side are the two scars | 1 | A |
| `tormenta_lone_tower_east` | 1.8 x 5.7 x 3.4 | skin (tower() 217, top 218, scar 219: x -299.1 .. -297.3, 938.3 .. 944), z -2.2 .. +1.2 | 10.6: the first lone tower: a thin slick shaft on a pointed foot (a body that misses passes under and behind it), a flat dry top 1.6 m wide carried back, a pale scar 2 m tall on its east side | 1 | A |
| `tormenta_lone_tower_west` | 1.8 x 8.0 x 3.4 | skin (221-223: x -312.7 .. -310.9, 936.5 .. 944.5), z -2.2 .. +1.2 | 10.6: the second lone tower, the same, its scar 1.5 m | 1 | A |
| `tormenta_buttress` | 8.8 x 14.0 x 3.0 | skin (227, 228, 229, 270: x -334.5 .. -325.7, 941.5 .. 955.5), z -1.8 .. +1.2 | 10.6 to 10.9: EL CONTRAFUERTE, the last tower, leaning on the face: wet slate, its cap 37 degrees, glossy and slick to its brink; the scar (944.4 .. 945.9) over the 1 m foothold, pale and dry; THE TOP STEP (3.5 m, 955.0 .. 955.5) pale dry slate in square steps, carried back to the summit's pillar (-1.8) (the winch, its post and the fallen rungs stand on its back) | 1 | A |
| `tormenta_exit_slab` | 8.0 x 2.0 x 2.4 | skin (line 55: x -340 .. -332, 962 .. 964) | 10.9: the exit ledge as THE RIDGE'S LAST SLAB OF SLATE: dry, pale warm grey, in square steps, overhanging the face by 2 m, two old bolt holes with rust under them on its east end where the ladder's top bracket was. Its top's dressing (the tea shop) is the summit's; if the summit's dress wants the ledge as its own piece it takes this skin and keeps the east end | 1 | A |
| `tormenta_quartz_knob` | 0.42 x 0.48 x 0.6 | its lowest point (a hold of r 0.24: the course's hexagon, pointed top and bottom), z -0.3 .. +0.3; scaled 1.167 for La Nube's r 0.28 | 10.1, 10.5, 10.7: A QUARTZ KNOB, a knot of white quartz 0.3 m proud of the slate, dry and matte, the palest thing in its picture, a hand's width of dry slate round it (so it never reads as a wet glint), a plain block with square facets | 15 | A |
| `tormenta_body_filo` | 4.0 x 18.0 x 0.75 | foot (x -296.1, y 883.6), z -2.95 .. -2.2, made in place | 9 to 10, 10.1: EL FILO'S BODY (in place of the root card): the slab the blade is the edge of, 3.6 m wide in two leaning slabs, duller, greyer, cooler, stopping just under the blade's top, going down into its collar; on it in dull white paint THE QUARTZ VEIN, a line 0.1 wide from behind each knob across to the next (seven strokes), nothing else pale on it (outline (-298.1, 885), (-297.7, 901), (-297, 901.6), (-295.4, 901.6), (-294.7, 901.3), (-294.1, 885)) | 1 | A |
| `tormenta_body_aguja` | 4.6 x 7.9 x 0.75 | foot (x -305.4, y 897), z -2.95 .. -2.2 | 10.2: La Aguja's body, 3.6 m wide, the same duller slate, sinking into its collar (outline (-307.7, 900.2), (-307.3, 904.3), (-306.5, 904.9), (-304.5, 904.9), (-303.7, 904.5), (-303.1, 900.2), carried down to 897) | 1 | A |
| `tormenta_body_station` | 12.3 x 9.3 x 0.75 | foot (x -307.35, y 905), z -2.95 .. -2.2, made in place | 10.2, 10.3: THE STATION TOWER'S BODY, 12 m wide at the top; its top a SHOULDER of leaning slab ends, saw-toothed, wet and dark, never level for half a metre (so it is never read as a floor beside the deck), with a notch at (-303.4 .. -302.2, 913.5) for the vane's shoe (outline a10_areas._STATION_BODY); its foot in its collar | 1 | A |
| `tormenta_body_torre` | 9.0 x 26.0 x 0.75 | foot (x -288.1, y 917.3), z -2.95 .. -2.2, made in place | 10.4, 10.5: LA TORRE'S BODY, 9 m wide, the shoulder's back wall; a saw-toothed top at about 941 with one sharp spike on its west corner (943.3), so it is never taken for a way up; the needle's quartz vein painted dull white behind its two knobs; the three reels bolt to its west edge; its foot in its collar (outline a10_areas._torre_body) | 1 | A |
| `tormenta_body_lone_east` | 4.6 x 12.3 x 0.75 | foot (x -298.4, y 931), z -2.95 .. -2.2 | 10.5, 10.6: the first lone tower's body, 3.6 m wide, stopping just under its top (943.3), its foot in its collar | 1 | A |
| `tormenta_body_lone_west` | 4.6 x 14.3 x 0.75 | foot (x -312, y 929.5), z -2.95 .. -2.2 | 10.6: the second lone tower's body, the same (to 943.8) | 1 | A |
| `tormenta_cloud_collar_s` | 9.0 x 5.0 x 0.2 | foot, the lowest point of its scalloped underside | 10.2, 10.5, 10.6: A CLOUD COLLAR (note 92: in place of the flat grey cards), a flat painted bank across the lower end of a tower's body: round heads above, a scalloped underside, dark below and paler on top, mid greys; scaled 0.889 for La Aguja's (z -1.9 .. -1.7) and 1.056 for the first lone tower's | 2 | A |
| `tormenta_cloud_collar_m` | 11.0 x 5.0 x 0.2 | as `_s` | 9 to 10, 10.1, 10.6: the same at 11 m; at 1.0 for El Filo's (in place of the card that stood in front of the mitten), 0.909 for the second lone tower's | 2 | A |
| `tormenta_cloud_collar_l` | 13.5 x 5.0 x 0.2 | as `_s` | 10.2 to 10.5: the same at 13.5 m, in another rhythm of heads; 0.926 for the station's, 1.037 for La Torre's | 2 | A |
| `tormenta_bank_gap` | 15.0 x 8.6 x 0.2 | foot (x -295.5, y 884.6), z -7.2 .. -7.0 | 9 to 10, 10.0: THE CLOUD IN THE GAP, a painted bank 7 m back between the prow and El Filo, three heads, a scalloped underside, darkest at the foot, mid greys and slate blues, nothing near white; the valley's last strip shows under it | 1 | A |
| `tormenta_bank_filo` | 16.5 x 9.6 x 0.2 | foot (x -295.25, y 888.6), z -7.6 .. -7.4 | 10.1: the bank behind the blade's lower half (behind the gap's bank where they overlap), so the knobs' side is seen against plain grey | 1 | A |
| `tormenta_bank_banderas` | 12.0 x 9.4 x 0.2 | foot (x -298, y 900.2), z -7.2 .. -7.0 | 10.2: the bank behind the lower two lines, so the brightest paper on the mountain hangs against plain grey | 1 | A |
| `tormenta_bank_veleta` | 11.5 x 8.4 x 0.2 | foot (x -295.75, y 916.9), z -7.2 .. -7.0 | 10.4: the bank under the throw, between the vane and La Torre: the fall is seen against it | 1 | A |
| `tormenta_bank_torre` | 10.6 x 10.2 x 0.2 | foot (x -294.1, y 934.3), z -7.2 .. -7.0 | 10.5, 10.6: the bank in the gap between La Torre and the first lone tower, behind the west half of the kites' flight, its heads just under the first flight (944.5) | 1 | A |
| `tormenta_bank_gendarmes` | 10.8 x 7.3 x 0.2 | foot (x -305.2, y 934.3), z -7.2 .. -7.0 | 10.6: the bank in the gap between the lone towers, its heads under the second flight | 1 | A |
| `tormenta_bank_contrafuerte` | 11.6 x 6.7 x 0.2 | foot (x -319.2, y 934.3), z -7.2 .. -7.0 | 10.6: the bank in the gap before the buttress, under the third flight | 1 | A |
| `tormenta_nube_bank` | 25.0 x 10.7 x 0.1 | foot (x -324.5, y 940.5), z -1.6 .. -1.5 | 10.7, 10.8: LA NUBE'S CLOUD, one painted bank 1.5 m back filling the frame below 951 m: big soft billows in three rows, darkest at the foot, mid greys and slate blues, nothing near white, no straight edge anywhere (its ends round billows); painted on it ONE TONE DARKER, no outline, the buttress's shoulder rising behind the rib (a10_areas._NUBE_SHADOW: rock seen through cloud) | 1 | A |
| `tormenta_nube_top` | 25.0 x 4.2 x 0.02 | foot (x -324.5, y 950.4), z -1.36 .. -1.34 | 10.7 to 10.9: THE CLOUD'S TOP, a strip of round heads (tops between 953 and 954.6) a hand in front of the bank, so it stands in front of the feet of the summit's teeth (1.4 m back); above it no rain and gold light | 1 | A |
| `tormenta_nube_rib` | 4.9 x 7.9 x 0.1 | foot (x -324.55, y 944.6), z -1.35 .. -1.25, made in place | 10.7: THE RIB, a fin of dark wet slate just behind the play space, the darkest thing in the picture; painted on it in white the quartz vein, a straight line through the first three knobs, then a clean black crack across the rib, then the vein again 1.3 m west and 0.6 m up through the last two (the break points at the fourth knob); its east edge cut back 0.4 m near its top (no rock behind the balloon's rope) (outline (-327, 944.6), (-324.8, 946), (-322.4, 950.4), (-322.1, 952.5), (-324.4, 951.6), (-326.8, 948)) | 1 | A |
| `tormenta_cabin` | 4.95 x 2.74 x 2.15 | foot (x -305.28, y 886), z -3.4 .. -1.25 | 9 to 10, 10.0 (note 94): THE KEEPER'S CABIN, the cableway's way: square honey posts and thick planks, a plank floor level with the porch, a plank back wall against the nook, two end walls, NO FRONT WALL (cut away at -1.25); a roof of slate slabs on honey rafters pitched as the prow pitches (2.5 m up at the west end, 2.1 at the east, eaves out to x -307.75 and -302.8); the two front corner posts at the ledge's back edge with an iron pug plate at each foot; a hole in the roof for the stove pipe at x -303.53; inside AMBER as colour on the planks (from the stove and the lamp), never a glow; a rafter over the table at 888.1 for the lamp's hook | 1 | A |

## 2. Small dressing (maker B)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `tormenta_snow_lip` | 4.6 x 0.53 x 0.3 | foot (x -305.3, y 885.75), z 1.25 .. 1.55, made in place | FOREGROUND 9 to 10, 10.0, 10.1: A LIP OF DRIFTED SNOW along the porch's front edge, the only thing on the ridge in front of the climb: soft-topped, rising only 0.28 above the snow ((-307.6, 886.2), (-305.8, 886.28), (-304.3, 886.18), (-303.0, 886.26)), hanging 0.25 m over the front edge in soft lobes, blue in the shade on its face; it covers nothing above an ankle | 1 | B |
| `tormenta_cabin_table` | 1.0 x 0.83 x 0.6 | foot | 10.0: the keeper's plank table (top at 0.76), honey timber, pegged; the WEATHER BOOK open on its east half (0.32 x 0.07, cream pages, ink columns); room on its west end for the frog and its cup | 1 | B |
| `tormenta_cabin_bunk` | 1.95 x 1.8 x 0.9 | foot (x -306.23), z -3.25 .. -2.35 | 10.0: a plank bunk along the west end (x -307.15 .. -305.62, 0.5 tall) with a folded striped blanket on it; at its foot a short post with a peg, the keeper's OILSKIN COAT hung on it (yellow, the size of a luchador, 0.8 long, 886.98 .. 887.75; the frog's hat is the same cloth) | 1 | B |
| `tormenta_wind_slate` | 0.6 x 0.8 x 0.03 | the middle of its back's foot on the wall (x -306.5, y 887.2, z -3.28) | 10.0: THE WIND SLATE, a roofing slate hung on the back wall over the bunk, the keeper's chalk on it: nine rows of arrows one above the other, east, west, east all the way up, and in the eighth row two arrows pointing at each other (the ridge's ten winds, read off it: the meeting pair is 943 to 953 m); chalk white, no words | 1 | B |

## 3. Timber and iron (maker C)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `tormenta_line_pole` | 0.24 x 7.7 x 0.24 | skin (line 102: x -296.32 .. -296.08, 902.6 .. 910.3), z -0.12 .. +0.12 | 10.2: THE LINE POLE, black greased steel as thick as a wrist, glossy, rain beading on it; three iron rings on square pug plates on it where the lines are made fast (904.3, 908.4, 910.0). The first black greased thing on the ridge: cannot be held | 1 | C |
| `tormenta_line_post` | 0.3 x 2.5 x 0.3 | skin (lines 216, 220, 224: each post's box), z -0.15 .. +0.15 | 10.5, 10.6: A LINE POST, square honey timber 0.3 m, pegged, a split top (where you launch from), an iron pug plate on its front at its foot | 3 | C |
| `tormenta_station_deck` | 4.1 x 0.5 x 4.6 | skin (line 126: x -311.8 .. -307.7, 913 .. 913.5), z -3.4 .. +1.2 | 10.3: THE STATION'S DECK, honey planks, pegged, split ends, carried back as the hut's floor; A BLACK STAR 2 m across burnt into the planks round the mast's foot (x -310), every burnt edge black; at its east corner (-307.9, 913.6) a low iron bollard with the third line's ring on a pug plate | 1 | C |
| `tormenta_mast_timber` | 3.6 x 13.9 x 1.8 | skin (lines 129-131, 134, 142: x -311.8 .. -308.2, 913.5 .. 927.4), z -1.2 .. +0.6 | 10.3 (note 95): THE MAST'S TIMBER at the course's sizes: four SLEEVES (913.5, 917.5, 921.5, 925.5, each 1.9 tall), each a box of four honey planks 0.6 across round the spine (the steel visibly inside, the hands not on it), z -0.3 .. 0.3; three CROSSARMS (917.2 .. 917.5 east, 921.2 .. 921.5 west, the nest 925.2 .. 925.5 both sides), thick and square, each running back to -1.2 as the front of its yard; grain, pegs, split ends; SEVEN STACKS OF WHITE RIBBED PORCELAIN 0.72 wide and 0.22 tall, 0.2 to 0.6 forward, each on the timber's side of its joint (the sleeves' tops 915.18, 919.18, 923.18, 927.18; the crossarms' undersides 917.2, 921.2, 925.2): a hand on white is a hand on timber. No steel in this piece | 1 | C |
| `tormenta_mast_spine` | 0.3 x 1.8 x 0.3 | skin (line 135: one each, x -310.15 .. -309.85, 915.4 .. 917.2 / 919.4 .. 921.2 / 923.4 .. 925.2), z -0.15 .. +0.15 | 10.3: A BARE LENGTH OF THE SPINE, bare steel: pale blue-grey, cold and matte, thin and round, rivet heads, scorched black where it meets the timber; the game tints it white and crawls sparks on it (a tagged solid: one skin each) | 3 | C |
| `tormenta_mast_rung` | 1.6 x 0.16 x 0.3 | skin (line 137: one each, x -310.8 .. -309.2 at 915.5, 916.6, 919.5, 920.6, 923.5, 924.6), z -0.15 .. +0.15 | 10.3: A MAST RUNG, the same bare steel, a thin round bar through the spine, rivet heads, scorched black at the joint (today drawn 2.4 m deep: item 7d) | 6 | C |
| `tormenta_mast_tip` | 0.2 x 2.2 x 0.2 | skin (line 143: x -310.1 .. -309.9, 927.4 .. 929.6), z -0.1 .. +0.1 | 10.3: THE TIP, the rod the bolt takes: the same bare steel, thinner, a scorched black point (not sharp: a blunt knob) | 1 | C |
| `tormenta_rung` | 0.9 x 0.36 x 0.4 | the middle of the bar's x span (F(y) + 0.35), 0.18 under the bar | 10.9: A SOUND RUNG standing straight out from the face, side-on: a straight iron bar 0.9 long and 0.16 thick, rust-orange (`#B5532A`), dry, matte; at its inner end a square iron plate (0.36 tall) lying on the face's surface with two bolts; a round eye at its outer end where the rail was bolted | 2 | C |
| `tormenta_rung_rusted` | 0.9 x 0.36 x 0.4 | as `tormenta_rung` | 10.9 (the mountain's one breakable look): A RUSTED RUNG: eaten to half its thickness, pale and scabbed, cracked through beside its plate, one of the plate's two bolts missing (its hole dark), its outer end dropped a hand's width, all drawn inside the shape that is held | 2 | C |
| `tormenta_rungs_fallen` | 0.9 x 0.2 x 0.4 | foot (x -329.4, y 955.5), z -1.7 .. -1.3 | 10.9: two iron rungs lying flat at the back of the top step, the two missing from the long gap, rusted dark, one bent, dull | 1 | C |
| `tormenta_winch` | 1.15 x 0.92 x 0.45 | foot (x -330.73, y 955.5), z -1.75 .. -1.3 | 10.8, 10.9: THE BALLOON'S HAND WINCH, shallow so it stands in front of the summit's pillar: a timber frame, a crank (its handle up to 956.42, west), a full drum of black greased cable, bolted down through iron pug plates; grey and wet, a step duller than the step | 1 | C |
| `tormenta_guide_post` | 0.8 x 2.35 x 0.3 | foot (x -330.05, y 955.5), z -1.65 .. -1.35 | 10.8, 10.9: the winch's GUIDE POST, a square timber 0.2 m, 2.25 m tall, an iron block at its head (957.75) where the cable leaves; nailed to it the kit's pug arrow board (`sign_pug_arrow`'s round bone plate and fat turquoise arrow, without its own post, 0.8 wide, 956.3 .. 957.05) pointing up at the rungs; a hook under the block for the sock | 1 | C |
| `tormenta_vane_shoe` | 1.2 x 0.35 x 0.6 | foot (x -302.8, y 913.5), z -2.85 .. -2.25 | 10.2, 10.4: the timber shoe in the shoulder's notch the vane's mast stands in, bolted through iron pug plates | 1 | C |
| `tormenta_vane_head` | 1.0 x 3.7 x 1.55 | foot (x -302.8, y 925.2), z -2.8 .. -1.25 | 10.4: THE VANE'S HEAD on the mast's top (927): the AXLE (0.2 round, greased black) from z -1.25 back to the mast's head (its front 1.2 m is the vane's own, `tormenta_vane`); under the head a timber COUNTING BOX 1 m wide (925.2 .. 926.15) with a white DIAL 0.6 across on its front at z -2.2 (its hand is `tormenta_dial_hand`); a short timber staff on the head to 928.9 with a hook at its top for the head sock | 1 | C |
| `tormenta_dial_hand` | 0.06 x 0.28 x 0.02 | its pivot (the dial's centre, -302.8, 925.68) | 10.4: the dial's black hand; it goes round once with each turn of the vane (a10_dress.FOLLOWS: "spin") | 1 | C |
| `tormenta_kite_reel` | 0.8 x 0.8 x 0.35 | its centre on the body's face (z -2.2) | 10.4, 10.5: A KITE REEL, timber, 0.8 across, on an iron pug plate bolted to La Torre's body, its string wound on it (the string to the kite is the game's, item 6e); it turns a little back and forth (FOLLOWS: "roll") | 3 | C |
| `tormenta_sock_stub` | 0.16 x 1.1 x 0.16 | foot | 10.1, 10.4, 10.7 (KIT_MORE): a short square timber standing at the back of a rest, a hook at its top for a sock (at 1.0 for La Nube's foothold: 0.91) | 3 | C |
| `tormenta_sock_arm` | 0.8 x 0.2 x 0.2 | foot (x -298.24, y 895.2), z -2.5 .. -2.3 | 10.1 (KIT_MORE): a short square timber arm bolted to El Filo's body's west side, sticking out west, a hook at its end (-298.64, 895.3) for the middle wind's sock | 1 | C |
| `tormenta_back_brace` | 0.25 x 2.64 x 0.25 | its middle, laid along y, turned 18.8 degrees (its top west) | 10.6 (KIT_MORE): a square timber brace from each post's top down to its tower's top, 1.4 m back, behind the post (bolted through a pug plate at its foot); the torn end is tied at its head | 3 | C |
| `tormenta_pole_cradle` | 1.0 x 0.35 x 0.6 | foot (x -296.2, y 902.6), z -1.85 .. -1.25 | 10.1, 10.2: the line pole's timber cradle on El Filo's top, behind the pole, bolted through an iron pug plate | 1 | C |
| `tormenta_stove_pipe` | 0.3 x 3.15 x 0.3 | foot (x -303.53, y 886.7), z -2.1 | 10.0: the stove's iron pipe up through the cabin's roof, ending 1.5 m above it in a cowl (889.7 .. 889.85), sooty black; the smoke is the game's | 1 | C |
| `tormenta_yard_thermometer` | 0.5 x 1.0 x 2.4 | foot (x -308.48, y 916.5), z -3.65 .. -1.25 | 10.3: the first crossarm's YARD, a square honey timber running 2.4 m back from the play space at the crossarm's height (917.2 .. 917.5), a small LOUVRED THERMOMETER BOX of grey slats hung under its far end (916.5 .. 917.1). No steel | 1 | C |
| `tormenta_yard_storm_cone` | 0.8 x 1.3 x 2.4 | foot (x -311.7, y 920.2), z -3.65 .. -1.25 | 10.3: the second crossarm's yard (921.2 .. 921.5), a STORM CONE of black canvas, point down, hung under its far end (920.2 .. 921.1): the signal the station flew to warn the cableway of wind | 1 | C |
| `tormenta_nest_stage` | 3.2 x 0.2 x 1.2 | foot (x -310, y 925), z -2.45 .. -1.25 | 10.3, 10.4: THE NEST'S STAGE behind the nest, a plank stage 1.2 m deep with a burnt hole in it, black-edged, the keeper's top landing | 1 | C |

## 4. Made for a10.py and the game, not placed by the dress file (FOR THE AREA FILE items 6, 8)

| Stem | Size | Origin | What it is and how it looks | Placed | Maker |
|---|---|---|---|---|---|
| `tormenta_sandbag` | 0.36 x 0.42 x 0.36 | its hanging point (its top: the game hangs a bob's model by it) | 10.7, 10.8 (note 96, "to be tested"): A SMALL CANVAS BAG OF SAND tied to the end of the balloon's rope, grey canvas, a hemp tie; it swings east in a gust a moment before the rope. Only if the rope's bob is added (item 6b) | (the rope's bob) | B |
| `tormenta_rung_hanging` | 0.9 x 0.95 x 0.4 | as `tormenta_rung_rusted` (the plate's last bolt is the pivot) | 10.9 (item 6c, the designers' answer): THE RUSTED RUNG BROKEN, swung down on its last bolt and hanging flat against the wet face inside its own rust streak, dark, shedding flakes; the game shows it for 8 s and a gust knocks it back up | (the game) | C |

## 5. Re-makes of existing models (each lands as a NEW stem; the original is not touched)

- **`tormenta_hut`** (A; from `station_hut_ruin`; placed 1: foot (x -310.53, y 913.5), z -3.4 .. -1.4,
  3.85 x 2.85 x 2.0): the station's hut, the kit's ruin re-made with ITS EAST HALF ROOF BURNT AWAY (bare
  black rafter ends over the half beside the mast, every burnt edge black) and the west half still slated
  (roof to 916.35); weathered grey, a step duller than the deck; its front wall at -1.4 plain enough at
  head height (914.55 .. 915.5, x -309.5 .. -308.72) for the pug bolt sign.
- **`tormenta_wind_sock`** (B; from `wind_sock`; placed 8: El Filo's arm and top, the vane's mast twice,
  the vane's head, the shoulder, the foothold, the guide post): THE KIT'S SOCK IN PLAIN GREY CANVAS (the
  sheet: red and cream marks a hold on a moving thing here, so no sock is red, marigold or cream): the same
  shape, size (0.99 x 1.48 x 0.42), origin and eye (0.45, 1.44), a dark iron hoop, three cords. It needs
  adding to the game's streamer poles (item 6f).
- **`tormenta_vane`** (C; from `anemometer`; the vane mover, line 160): at the course's sizes, 10.8
  across: THREE arms of BLACK GREASED STEEL, glossy, 0.3 thick, to radius 4.7 at 0, 120 and 240 degrees
  (the kit's are slick brown); a hub, an iron boss 1.2 across with the pug's face, greased black; a deep
  CUP on each arm's end, 0.8 x 0.7 at radius 5.0, THE CABLEWAY'S RED WITH A CREAM BAND, dry and matte (the
  mark for a hold on a thing that moves, since the cableway); behind the hub the axle's first 1.2 m (to z
  -1.2), greased black. Origin the hub.
- **`tormenta_balloon`** (C; from `weather_balloon`; the globo mover, line 258): the skin of dark
  red-brown rubber, shining wet, 4.2 wide and 4.83 tall about (0, 3.9), two paler patches glued on and a
  seam round its middle, nothing matte on it; THE NECK of the same wet rubber, 0.5 wide, from the basket's
  top (0.6) to the skin's lowest edge (1.6) (item 6a: solid and slick); THE BASKET a crate of honey
  timber 1.6 x 0.6, pegged, an iron pug plate on its side, nothing sticking out of it; an iron ring under
  the back of the skin (z -1.2) for the cable; one eye under the basket's middle for the one rope; NO ropes
  of its own (the rope is the course's globo_rope). Origin the bottom middle of the basket (as the kit's).
- **`tormenta_kite`** (B; from `kite`; the three kite movers, line 189): a paper diamond at exactly the
  size that is held, 1.2 x 1.44 (the course's shape), cut paper in the town's colours on a split cane
  cross, the pug's face cut out of its middle (a real hole), dry and matte; NO TAILS (each tail is its
  banner rope) and nothing hanging under it; the string's eye on its back. Origin its centre. (The kit's
  is 2.5 x 4.0 with three tails: drawn twice what is held.)
