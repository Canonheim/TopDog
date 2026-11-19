"""
A0 LA ESTACION: the trailhead and the cart ride. Also the worked example for area authors.
  python tools/peak/areas/a0.py
"""
import os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from peaklib import Area, box_pts, ngon, save_meta
import a0_station  # the station's scenery (the 11-13 diorama test): decos and cards only
import a0_dress  # the tunnel's scenery past the first screen (the modelling run's): decos and cards only

A = Area("a0", "town")

# ---------------------------------------------------------------- the ground at the edge of town
A.solid([(16, -3), (16, 0), (-36, 0), (-36, -3)], "rock")  # the road (grip: you stand on it)
A.box(15.0, 30.0, 2.0, 66.0, "void")  # the world's east edge, unseen: the town is that way

# ---------------------------------------------------------------- 0.1 El Primer Paso: crates up to the platform
# The three steps are plain boxes to the body. Their looks are kit models once those land
# (skins: until then the game draws the boxes as before).
A.box(-2.6, 0.55, 1.2, 1.1, "wood", skin="barrel_step")  # the first step: a standing barrel
A.box(-3.9, 0.55, 1.4, 1.1, "wood", skin="crate_pug_14")  # two crates stacked
A.box(-3.9, 1.65, 1.3, 1.1, "wood", skin="crate_pug_13")
A.deco("barrel_step", -2.6, 0.0, z=0.0, size=(1.2, 1.1, 1.2), skin=True)
A.deco("crate_pug_14", -3.9, 0.0, z=0.0, size=(1.4, 1.1, 1.2), skin=True)
A.deco("crate_pug_13", -3.9, 1.1, z=0.0, size=(1.3, 1.1, 1.2), skin=True)
A.ledge(-36.0, -4.6, 2.2, "plank", t=0.45)  # the loading platform; the rails run along it
for x in (-6.0, -14.0, -22.0, -30.0):
    A.box(x, 0.87, 0.35, 1.75, "wood")  # its legs
A.challenge("0.1", "El Primer Paso", (4.0, 0.0), 1, "S",
            moves=[["reach", [-2.6, 1.1], [-3.9, 2.2]]])

# ---------------------------------------------------------------- 0.2 Subete / 0.3 El Descenso: the cart
# The cart's origin is the middle of its floor. Its path is that point's road.
import math
# THE LONGER RIDE (note 146; Parker 11-14: "make the initial mine cart ride longer"): the mine moved 59 m west
# and 17 m down, so the road runs on past today's end (-148.4, -11.55), down a 20 degree incline (x -158 to
# -188; Parker: "good"), to the mine's moved door (x -211, floor -29.6): 203 m of road (today 141).
# (design/rearrange_146/make_rearrange.py RIDE_NEW)
_INC = math.tan(math.radians(20.0))
RIDE = [(-9.0, 2.65), (-34.0, 2.65), (-46.0, 1.2), (-62.0, -3.0), (-78.0, -4.2), (-90.0, -2.2),
        (-104.0, -6.5), (-120.0, -9.6), (-136.0, -11.2), (-148.4, -11.55), (-152.0, -11.85), (-155.0, -12.6),
        (-158.0, -13.75), (-188.0, round(-13.75 - 30.0 * _INC, 2)), (-191.0, -25.75), (-194.0, -26.75), (-197.0, -27.6),
        (-200.0, -28.2), (-203.5, -28.45), (-207.4, -28.55)]
MOVE = (-59.0, -17.0)  # the mine's move: the end of the line's pieces move with it
cart_shapes = [
    (box_pts(0.0, 0.0, 2.4, 0.2), "plank"),  # floor
    (box_pts(-1.12, 0.35, 0.16, 0.9), "iron"),  # the two ends
    (box_pts(1.12, 0.35, 0.16, 0.9), "iron"),
]
A.mover("cart0", RIDE[0], cart_shapes,
        {"type": "path", "pts": [list(p) for p in RIDE], "speed": 9.0, "mode": "once", "trigger": "lever",
         "reset": 25.0, "tilt": True, "accel": 3.0,
         # THE HOP (note 73, Parker 11-13: "real hop and make dust come off the wheels when it
         # lands"): it leaves the rails at the crest (x -90) at its own speed and flies the
         # broken stretch, as the design page's real throw (g 8.9: 0.9 s, about 0.9 m clear,
         # down near x -98). A first guess, to tune by riding it.
         "hop": {"x": -90.0, "g": 8.9},
         # THE SLAM (Parker 11-19: "make it so when the minecart hits the end there, it slams into it
         # and launches you out, with dust coming off where it slams and a small amount of camera
         # shake"): it stops dead against the buffer, dust off its nose and wheels, a small jolt of
         # the view, and the rider is thrown on at 0.65 of its speed and 3 m/s up, over the buffer
         # into the mine's door (peak_things.gd _slam). First guesses, to tune by riding it.
         "slam": {"v": 0.65, "up": 3.0, "kick": 0.2}},
        model="minecart")
# THE STATION'S LEVER (Parker 11-13, note 72: "make it so you have to pull the lever to start
# the cart, regardless of if you are in the cart. If you pull the lever it goes"). Its foot
# is on the deck just east of the cart; at rest it leans west with its handle at about
# (-7.95, 3.86), over the cart's east end, in reach from the cart and from the deck. Drawn
# east 0.7 m at the handle it drops into its second notch and the cart goes. It comes back
# to its first notch when the cart comes home.
# It stands just in front of the near rail (z +0.65), so the whole shaft shows across the
# cart's end and its chock shows under the cart's near wheel. The arm's notches are 11.9
# degrees either side of upright.
A.lever("palanca", (-7.6, 2.2), "cart0", length=1.7, rest=11.9, pull=-11.9, grip=0.4, z=0.65)
# The rails (the Carpenter's rail_straight, 4 m a piece): their base 0.55 under the cart's road.
# West of x -197 (the run-out after the incline) they are laid in three even pieces along the road
# to the buffer stop's face (x -209.0, 1.6 m past the road's end), not one piece a segment: the
# segments there are 3 m and less, and a piece shrunk to fit them is thinner (11-18).
import math
BUFFER_FACE = -209.0
_TAIL = [p for p in RIDE if p[0] <= -197.0] + [(BUFFER_FACE, RIDE[-1][1])]
for (x0, y0), (x1, y1) in zip([(-4.6, 2.65)] + RIDE[1:-1], RIDE[1:]):
    if x1 < _TAIL[0][0]:
        break  # (the tail, below)
    L = math.hypot(x1 - x0, y1 - y0)
    n = max(1, round(L / 4.0))
    ang = math.degrees(math.atan2(y1 - y0, x1 - x0))
    if abs(ang) > 90:
        ang -= math.copysign(180, ang)
    for i in range(n):
        f = (i + 0.5) / n
        rx = x0 + (x1 - x0) * f
        if any(abs(rx - c) < 0.2 for c in (-91.75, -98.75, -102.25)):
            continue  # (note 73's torn stretch: dsc_rail_torn, dsc_rail_landing, dsc_rail_banked take these places, in a0_dress)
        A.deco("rail_straight", rx, y0 + (y1 - y0) * f - 0.55, z=0.0, rot=ang, scale=L / n / 4.0, size=(4.0, 0.25, 1.2), tone="iron")


def _along(pts, t):
    """The point t metres along a line of points."""
    for (ax, ay), (bx, by) in zip(pts, pts[1:]):
        L = math.hypot(bx - ax, by - ay)
        if t <= L or (bx, by) == pts[-1]:
            f = min(1.0, t / L)
            return (ax + (bx - ax) * f, ay + (by - ay) * f)
        t -= L


_len = sum(math.hypot(b[0] - a[0], b[1] - a[1]) for a, b in zip(_TAIL, _TAIL[1:]))
_n = max(1, round(_len / 4.0))
for i in range(_n):
    (x0, y0), (x1, y1) = _along(_TAIL, _len * i / _n), _along(_TAIL, _len * (i + 1) / _n)
    L = math.hypot(x1 - x0, y1 - y0)
    ang = math.degrees(math.atan2(y1 - y0, x1 - x0))
    if abs(ang) > 90:
        ang -= math.copysign(180, ang)
    A.deco("rail_straight", round((x0 + x1) / 2, 3), round((y0 + y1) / 2 - 0.55, 3), z=0.0, rot=round(ang, 3), scale=round(L / 4.0, 3),
           size=(4.0, 0.25, 1.2), tone="iron")
A.challenge("0.2", "Súbete", (-6.2, 2.2), 1, "S")
A.challenge("0.3", "El Descenso", (-9.0, 2.9), 1, "S")

# The tunnel: its air, from the mouth (x -36) to the door into the mine (x -211: note 146).
# cave() takes the AIR's outline; every edge gets rock behind it. Edge i runs pts[i] -> pts[i+1].
floor = [(p[0], p[1] - 0.45) for p in RIDE[1:]]  # the rail bed, under the cart's road
floor[0] = (-36.0, 2.2)
floor[-1] = (-211.0, -29.0)
roof = [(x, y + 5.0) for x, y in reversed(floor)]
air = floor + roof
kinds = {i: "rock" for i in range(len(floor) - 1)}  # the rail bed grips: fall out and you can walk
kinds[len(floor) - 1] = None  # the west end: the door into the mine
for i in range(len(floor), len(air) - 1):
    kinds[i] = "rock2"  # the roof
kinds[len(air) - 1] = None  # the east end: the mouth
n_before = len(A.solids)
A.cave(air, kinds, default="wet", thick=3.0)
# THE BROW'S ONE LINE (the reviewer's q17, the Director 11-18): the station ends and the mine begins at x -148.4, the
# bed's line, in the bed, the back wall, the roof and a set. The roof's line waits on the ride bed's maker:
# mina_ride_roof_brow is being carried east to meet dsc_roof_d's planes there. Once the landed model reaches the seam,
# roof slab 37 (x -148.4 .. -152.3, all of it west of the line) wears it and dsc_roof_d is cut at -148.4; till then
# dsc_roof_d draws slab 37 whole, as before (a cut with nothing past it would leave the roof open).
import sweeps as _sweeps
_rb = _sweeps.model_bounds("mina_ride_roof_brow")
ROOF_BROW_AT_SEAM = _rb is not None and -155.576 + _rb[1][0] >= -148.45  # (its origin x in a0_dress, plus its east end)
SEAM_X = -148.4
# The cave's slabs wear the dress's skins (a0_dress FOR THE AREA FILE, item 6), by where
# each lies; the corner fillers go with the stretch the dress names for them.
for s in A.solids[n_before:]:
    cx = sum(p[0] for p in s["pts"]) / len(s["pts"])
    if cx < -148.5:  # the new stretch (note 146; MINE_PASS F-C10): the mina_ride_bed family by place (quality run, reviewer 8.5, 11-18)
        if s["kind"] == "rock":  # the bed: slabs 18 .. 27, fillers 48 .. 50
            s["skin"] = "mina_ride_bed_brow" if cx > -158.0 else "mina_ride_bed_incline" if cx > -188.0 else "mina_ride_bed_foot"
        elif s["kind"] == "rock2":  # the roof: slab 37 under dsc_roof_d till the roof brow reaches the seam (above)
            s["skin"] = ("mina_ride_roof_brow" if ROOF_BROW_AT_SEAM else "dsc_roof_d") if cx > -152.5 else "mina_ride_roof_brow" if cx > -158.0 else "mina_ride_roof_incline" if cx > -188.0 else "mina_ride_roof_foot"
        continue
    if s["kind"] == "rock":  # the bed
        s["skin"] = "dsc_bed_a" if cx > -62.3 else "dsc_bed_b" if cx > -104.5 else "dsc_bed_c" if cx > -136.0 else "dsc_bed_d"
    elif s["kind"] == "rock2":  # the roof
        s["skin"] = "dsc_roof_a" if cx > -62.5 else "dsc_roof_b" if cx > -105.0 else "dsc_roof_c" if cx > -137.0 else "dsc_roof_d"
A.opening(-212, -30, -210, -23)  # the door to A1 (moved: note 146)
A.opening(-37, 2, -35, 8)  # the mouth
A.box(-150.3 + MOVE[0], -11.6 + MOVE[1], 0.6, 0.8, "iron", skin="dsc_buffer_stop")  # the buffer the cart stops against (moved with the end of the line)
A.dark((-212, -34, -40, 9), level=0.8)  # inside the mountain: the light goes
# (The new stretch's plain dark back-wall card is gone: its back wall is mina_ride_lining, placed below.)

# ---------------------------------------------------------------- the picture
# (The tunnel's back-wall card, the mouth's mine_frame and the seven lantern_mine decos are
# gone: a0_dress places the back wall's pieces, the whitewashed mouth set and the lanterns.)
a0_station.dress(A)  # the yard wall, the station house, the posters, the frog, the bunting, the foreground
a0_dress.dress(A)  # the tunnel: its sets, back wall, lanterns, torn rail, trough, the mouth
# (note 146: the end of the line moves with the mine: the buffer stop, by MOVE. The door's sill is gone, F-C10:
# its top lay on mina_ride_bed_foot's shoulder in another colour; the mine's door set carries its own sill.)
for d in A.decos:
    if d["model"] == "dsc_buffer_stop":
        d["at"] = [round(d["at"][0] + MOVE[0], 3), round(d["at"][1] + MOVE[1], 3)] + d["at"][2:]
    # dsc_bed_d was made level to the old end of the line (x -152); the moved line drops away from x -148.4,
    # so its last 3.6 m stood 0.3 m over the bed with nothing under it: it ends there now (11-18).
    if d["model"] == "dsc_bed_d":
        d["cut_west"] = SEAM_X
    # The brow's one line: the station's tan back wall ends there (mina_ride_lining, behind it at z -2.12, runs east
    # to -147.7, so the mine's lagging shows from the line west), and its roof once the roof brow meets it.
    if d["model"] == "dsc_back_wall_d" or (d["model"] == "dsc_roof_d" and ROOF_BROW_AT_SEAM):
        d["cut_west"] = SEAM_X
    # The threshold's portal: the station's last grey set (k 43, x -147.8) moved onto the line, its cap out over the
    # play space under the roof: the station's timber frames the mine's start. (No other station set stood between
    # -152.6 and the line.)
    if d["model"] == "dsc_set_grey" and abs(d["at"][0] - (-147.8)) < 0.05:
        d["at"] = [SEAM_X, a0_dress.fy(SEAM_X)] + d["at"][2:]
# The trough ends at the line too: its last length and its spout (x -147.85 .. -151.8) hung over the mine's lining;
# the length before them takes the spout, its mouth at -147.85, by the portal's post.
_tr = [d for d in A.decos if d["model"] in ("dsc_trough", "dsc_trough_spout") and d["at"][0] < -140.0]
_tr.sort(key=lambda d: -d["at"][0])
for d in _tr:
    if d["at"][0] - 1.0 < SEAM_X:  # (a 2 m length's west end past the line)
        A.decos.remove(d)
_keep = [d for d in _tr if d in A.decos]
if _keep:
    _keep[-1]["model"] = "dsc_trough_spout"
    _keep[-1]["size"] = [2.0, 0.25, 0.2]
# Under the station's bed east of the line (x -148.4 .. -136): rock, down from the bed's foot (dsc_bed_d stops at
# y -14.7). There the mountain's flat body showed through below the bed, beside the mine's dark rock under the brow.
A.solid([(SEAM_X, -14.7), (-136.0, -14.7), (-136.0, -18.0), (SEAM_X, -18.0)], "rock")
# The new stretch's back wall (quality run, MINE_PASS F-E3, reviewer 8.5, 11-18), in the game's numbers (not moved):
# the mine's lagging in bays stepping down the 20 deg road, the two side galleries going back in the dark, the
# winding house's recess, the burst at the run-in, the refuge with its pail, the check board at the end of the line.
A.deco("mina_ride_lining", -211.0, -29.6, z=-2.12, size=(64.5, 23.21, 8.6), tone="back")  # 12 cm back: clear of the station tunnel's back wall's relief where they overlap at the join (sweeps)
# THE NEW STRETCH'S SETS (MINE_PASS F-B6 / F-C10, 11-18): the mine's square sets every 2.6 m in its one scenery timber
# (the mine_timber stock family, 0.35 m square, the nearest stock length stretched, as a1_dress lays it), posts plumb at
# z -1.45 on the bed, each bay's cap level with its top at the roof's underside over the bay's west post, running from
# the east post's face 0.4 m past the west post into the roof's socket: the caps step down the incline. Every socket
# from mina_ride_bed_family.json (Top Dog Kit\source: k, the post's x, its foot and top, the cap's east and west ends
# and its underside). Set 2 is left out (the brow sheave stands there). Every other set mirrored, so the stock's faces
# don't read as a repeat.
RIDE_SETS = [
    (3, -156.2, -13.51, -8.86, -153.775, -156.6, -8.86),
    (4, -158.8, -14.491, -9.841, -156.375, -159.2, -9.841),
    (5, -161.4, -15.438, -10.788, -158.975, -161.8, -10.788),
    (6, -164.0, -16.384, -11.734, -161.575, -164.4, -11.734),
    (7, -166.6, -17.33, -12.68, -164.175, -167.0, -12.68),
    (8, -169.2, -18.277, -13.627, -166.775, -169.6, -13.627),
    (9, -171.8, -19.223, -14.573, -169.375, -172.2, -14.573),
    (10, -174.4, -20.17, -15.52, -171.975, -174.8, -15.52),
    (11, -177.0, -21.116, -16.466, -174.575, -177.4, -16.466),
    (12, -179.6, -22.062, -17.412, -177.175, -180.0, -17.412),
    (13, -182.2, -23.009, -18.359, -179.775, -182.6, -18.359),
    (14, -184.8, -23.955, -19.305, -182.375, -185.2, -19.305),
    (15, -187.4, -24.902, -20.252, -184.975, -187.8, -20.252),
    (16, -190.0, -25.84, -21.19, -187.575, -190.4, -21.19),
    (17, -192.6, -26.733, -22.083, -190.175, -193.0, -22.083),
    (18, -195.2, -27.54, -22.89, -192.775, -195.6, -22.89),
    (19, -197.8, -28.21, -23.56, -195.375, -198.2, -23.56),
    (20, -200.4, -28.679, -24.029, -197.975, -200.8, -24.029),
    (21, -203.0, -28.864, -24.214, -200.575, -203.4, -24.214),
]
_STOCK = (("mine_post_stub", 0.9), ("mine_post_short", 1.4), ("mine_post_mid", 2.0), ("mine_post", 3.0),
          ("mine_post_tall", 4.75), ("mine_post_long", 6.5), ("mine_timber_long", 8.5), ("mine_beam", 4.0))


def _timber(x0, y0, x1, y1, z, flip):
    """One grey timber along its centre line (x0, y0) -> (x1, y1): plumb (a post, on its foot) or level (a cap)."""
    L = math.hypot(x1 - x0, y1 - y0)
    stem, made = min(_STOCK, key=lambda st: abs(math.log(L / st[1])))
    sc = round(L / made, 3)
    if stem == "mine_beam":  # (origin the middle of its underside)
        A.deco(stem, round((x0 + x1) / 2, 3), round(min(y0, y1) - 0.175, 3), z=z, scale=sc, size=(made, 0.35, 0.35), tone="back", flip=flip)
    else:  # (origin the middle of its foot; laid level, turned a quarter)
        rot = 0.0 if abs(x1 - x0) < 1e-6 else (90.0 if x1 < x0 else -90.0)
        A.deco(stem, round(x0, 3), round(y0, 3), z=z, rot=rot, scale=sc, size=(0.35, made, 0.35), tone="back", flip=flip)


for k, px, foot, top, cx0, cx1, under in RIDE_SETS:
    _timber(px, foot, px, top, -1.45, k % 2 == 1)  # the post
    _timber(cx0, under + 0.175, cx1, under + 0.175, -1.45, k % 2 == 0)  # the cap
# WHERE THE MINE WAS, over the ride (the Director, 11-18; moved here from a1 for the reviewer's q13): the mine's dark rock
# carried east over the new stretch's roof and under its bed, a stand-in card in its back tone behind
# mina_ride_lining's galleries (to z -10.06), a backstop behind it; the mountain's body is cut away there (st.py
# BODY_WINDOWS). In a0 because a0 is drawn all the way along the ride, a1 only with the climber west of about x -150.
# MINE_PASS part F's ride pieces replace the card.
# Run west to the door (x -212), so the roof's end has rock past it too. (The mine palette's back2 and back3 by
# number: a0's own palette is the town's, whose back tones are tan. The backstop at -18.1, off a1's own at -18,
# which reaches x -201.)
A.card([(-212.0, -42.0), (-148.0, -42.0), (-148.0, 25.0), (-212.0, 25.0)], z=-10.5, tone="#3B383F", edge=False)
A.card([(-212.0, -42.0), (-148.0, -42.0), (-148.0, 25.0), (-212.0, 25.0)], z=-18.1, tone="#2A282D", edge=False)
for x, y in a0_dress.LANTERNS:  # each light sits in its lantern, under the hook
    A.light(x, round(y - 0.27, 3), color="#FFB860", rng=10.0, energy=1.5, flicker=True)
A.cam((-212, -34, -30, 9), half_h=4.6)

if __name__ == "__main__":
    save_meta()
    A.save()
