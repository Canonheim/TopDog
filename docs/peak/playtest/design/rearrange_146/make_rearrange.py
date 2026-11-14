"""Design pages for note 146: the bottom of the mountain rearranged so the great falls run to the bottom.

    python docs/peak/playtest/design/rearrange_146/make_rearrange.py            # the pages, the PNGs, the checks
    python docs/peak/playtest/design/rearrange_146/make_rearrange.py --png DIR  # also a rough PNG of every side sketch into DIR

DESIGN ONLY. Nothing here changes the game. This script reads the course files and the design
system (../build.py, loaded as a module: its main() is never run) and writes ONLY into this folder.

The layout in one place (every number a first guess unless it says "as today"):
    the mine moves by (DX, DY) = (-59, -17); everything west of x -246 (its west wall, the frog's cave)
    a further 6 m west, which widens the falls' cavern and the Sump (Parker's drawing, note 146);
    the cart ride is 59 m longer and ends 17 m lower, at the mine's moved door;
    the great falls are one column, x -303 to -297, centred on the well's own middle line (x -300),
    from the well's foot down through the Charco, the black waters' floor, the new section and the mine;
    the new section, La Esclusa, fills x -303 to -226, y 73 to 90, under the black waters' east end.
"""
import copy, importlib.util, io, json, math, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
DESIGN = os.path.dirname(HERE)
_spec = importlib.util.spec_from_file_location("peak_design_build", os.path.join(DESIGN, "build.py"))
B = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(B)          # definitions only; build.main() is not called, so nothing is written

ROOT = B.ROOT
META = B.META


def course(aid):
    return json.load(open(os.path.join(B.COURSE, aid + ".json"), encoding="utf-8"))


OLD = {a: course(a) for a in ("st", "a0", "a1", "a2")}
PAL = {a: META["palettes"].get(OLD[a].get("palette", ""), {}) for a in OLD}

# ================================================================== the moves
DX, DY = -59.0, -17.0            # the mine: 59 m west (its slot centred under the well's middle, x -300), 17 m down
WIDEN, WIDEN_X = -6.0, -246.0    # and everything west of x -246 (today's coordinates) a further 6 m west


def mv(x, y):
    return (round(x + DX + (WIDEN if x < WIDEN_X else 0.0), 3), round(y + DY, 3))


def mvx(x):
    return mv(x, 0.0)[0]


def moved_course(c, drop_decos=True):
    """A copy of a course with every position moved by mv()."""
    n = copy.deepcopy(c)
    for s in n.get("solids", []):
        s["pts"] = [list(mv(*q)) for q in s["pts"]]
    for z in n.get("zones", []):
        if "rect" in z:
            a, b = mv(z["rect"][0], z["rect"][1]), mv(z["rect"][2], z["rect"][3])
            z["rect"] = [a[0], a[1], b[0], b[1]]
            if "surface" in z:
                z["surface"] = round(z["surface"] + DY, 3)
        for k in ("a", "b", "at"):
            if k in z:
                z[k] = list(mv(*z[k]))
    for m in n.get("movers", []) + n.get("bodies", []):
        m["at"] = list(mv(*m["at"]))
        mo = m.get("motion", {})
        if mo.get("pts"):
            mo["pts"] = [list(mv(*p)) for p in mo["pts"]]
    for r in n.get("ropes", []):
        r["at"] = list(mv(*r["at"]))
        if "to" in r:
            r["to"] = list(mv(*r["to"]))
    for k in ("spawners", "statues", "decos", "lights"):
        for o in n.get(k, []):
            if "at" in o:
                o["at"] = list(mv(o["at"][0], o["at"][1])) + list(o["at"][2:])
    for ch in n.get("challenges", []):
        ch["anchor"] = list(mv(*ch["anchor"]))
    if drop_decos:
        n["decos"] = []
    return n


NEW_A1 = moved_course(OLD["a1"])

# ================================================================== the cart ride, 59 m longer
RIDE_OLD = [(-9.0, 2.65), (-34.0, 2.65), (-46.0, 1.2), (-62.0, -3.0), (-78.0, -4.2), (-90.0, -2.2),
            (-104.0, -6.5), (-120.0, -9.6), (-136.0, -11.2), (-148.4, -11.55)]
_INC = math.tan(math.radians(20.0))
RIDE_NEW = RIDE_OLD[:-1] + [(-148.4, -11.55), (-152.0, -11.85), (-155.0, -12.6), (-158.0, -13.75),
                            (-188.0, round(-13.75 - 30.0 * _INC, 2)), (-191.0, -25.75), (-194.0, -26.75),
                            (-197.0, -27.6), (-200.0, -28.2), (-203.5, -28.45), (-207.4, -28.55)]
DOOR_X, DOOR_FLOOR = -211.0, -29.0      # the mine's door, moved (today -152, -12.0)
BUFFER = (-209.3, -28.6)                # (today -150.3, -11.6)


def path_len(pts):
    return sum(math.dist(a, b) for a, b in zip(pts, pts[1:]))


def tunnel(ride, door_x, door_floor, x_from=None):
    """The tunnel as a0.py writes it: the bed 0.45 under the cart's road, the roof 5 m over the bed, 3 m of rock round it."""
    floor = [(p[0], round(p[1] - 0.45, 3)) for p in ride[1:]]
    floor[0] = (-36.0, 2.2)
    floor[-1] = (door_x, door_floor)
    sol = []
    for (x0, y0), (x1, y1) in zip(floor, floor[1:]):
        if x_from is not None and max(x0, x1) > x_from + 1e-6:
            continue
        sol.append({"pts": [[x0, y0], [x0, y0 - 3.0], [x1, y1 - 3.0], [x1, y1]], "kind": "rock"})
        sol.append({"pts": [[x0, y0 + 5.0], [x1, y1 + 5.0], [x1, y1 + 8.0], [x0, y0 + 8.0]], "kind": "rock2"})
    return floor, sol


FLOOR_NEW, _tun = tunnel(RIDE_NEW, DOOR_X, DOOR_FLOOR, x_from=-136.0)
NEW_A0 = {"solids": _tun + [{"pts": [[BUFFER[0] - 0.3, BUFFER[1] - 0.4], [BUFFER[0] + 0.3, BUFFER[1] - 0.4],
                                     [BUFFER[0] + 0.3, BUFFER[1] + 0.4], [BUFFER[0] - 0.3, BUFFER[1] + 0.4]], "kind": "iron"}],
          "movers": [{"at": [-207.4, -28.55], "shapes": [{"pts": [[-1.2, -0.1], [1.2, -0.1], [1.2, 0.1], [-1.2, 0.1]], "kind": "plank"},
                                                         {"pts": [[-1.2, -0.1], [-1.04, -0.1], [-1.04, 0.8], [-1.2, 0.8]], "kind": "iron"},
                                                         {"pts": [[1.04, -0.1], [1.2, -0.1], [1.2, 0.8], [1.04, 0.8]], "kind": "iron"}],
                      "motion": {"type": "path", "pts": [list(p) for p in RIDE_NEW[8:]]}}]}
# the part of today's a0 that does not change (east of x -136), drawn at full strength
A0_KEEP = copy.deepcopy(OLD["a0"])
A0_KEEP["solids"] = [s for s in A0_KEEP["solids"] if min(q[0] for q in s["pts"]) > -136.1 and s.get("skin") != "dsc_buffer_stop"]
A0_KEEP["decos"] = [d for d in A0_KEEP["decos"] if d["at"][0] > -136.0]
A0_KEEP["movers"] = []

# ================================================================== the new section: La Esclusa
FALLS = (-303.0, -297.0)        # the great falls' column (6 m, the mine's slot moved; middle x -300 = the well's middle)
MINE_TOP = 73.0                 # the mine's roof, moved (today 90): the lip room's floor
LIP_ROOM = (-297.0, 73.0, -284.5, 75.2)
BED_LO, BED = 75.2, 75.7        # the flume's bed slab over the lip room; the water's bottom
S = 77.2                        # the flume's surface
FLUME = (-297.0, -264.5)        # its water, the lip at the west end
RACE = (-297.0, -295.0)         # its last 2 m, where it quickens
FLOW, RACE_FLOW = -1.0, -2.4    # m/s, west (today's pool ran 1.0 east)
CEIL_W, CEIL_E = 83.0, 86.0     # the black waters' rock starts here: west and east of x -292
LANDING = 79.4                  # the two hanging landings' tops (today's Q6 117.4 over a 115 pool: 2.4 above the water, less 0.2)
LANDING_T = 0.7
WEST_LANDING = (-297.6, -292.0)
EAST_LANDING = (-271.0, -264.5)
QUAY = (-264.5, -251.0)
GATE = (-251.0, -250.0)         # the lock's lower gate (its wicket 79.4 to 81.9)
LOCK = (-250.0, -228.0)         # the chamber
LOCK_FLOOR, LOCK_CEIL = 75.7, 86.0
LOCK_LOW, LOCK_HIGH = 77.2, 88.5
RISE, HOLD, DRAIN = 6.0, 3.0, 5.0   # the pitch's 14 s
LOW_HOLD, WARN_T = 4.0, 1.0         # added: a pause at the bottom (the wicket is open then), and the keeper's lever 1 s before each fill
CYCLE = RISE + HOLD + DRAIN + LOW_HOLD
SLOT = (-244.0, -238.0)         # the black waters' slot (as today): the river pours in here
PIER = (-238.0, -236.0)         # its foot hangs to 84 (as today's air polygon has it)
DRY = (-236.0, -232.0)          # the old dry shaft (as today), up to the lip ledge
LIP_LEDGE = (-232.0, -226.0, 90.0)   # 2.1's start, as today
L0 = (-250.0, -248.6, 79.4)
L1 = (-246.6, -245.0, 82.4)
L2 = (-229.6, -228.0, 81.0)
PIER_RUNGS = [(-235.75, 84.6), (-235.75, 85.5)]
DRY_RUNGS = [(-232.25, 86.8), (-232.25, 87.6)]
# the barrels: speed, spacing, road length and count exactly as today (a2.py), mirrored to run west
BARREL_SPEED = 0.55
BARREL_GAPS = [3.0, 3.4, 2.9, 5.8, 3.1, 3.5, 2.9, 6.2]
WATER_EDGE = FLUME[0]                       # -297: the lip
LIP_X = round(WATER_EDGE - 2.2, 2)          # the end of the barrels' line (today 2.2 m past the water's end)
LOOSE_X = round(WATER_EDGE - 0.85, 2)       # let loose here (today 0.85 m past it)
ROAD = 26.8                                 # as today: cove to lip
COVE_X = round(LIP_X + ROAD, 2)             # -272.4: born here, 7 m deep in the tunnel
BARREL_Y = round(S + 0.3, 2)                # as today: 0.3 over the surface
EMERGE = 2.4
ARCH = (-275.5, -270.0)
CHAIN = (-297.6, round(LANDING - LANDING_T, 2), 4.4)   # the lip chain: x, top, length (its tail at 74.3)

# 2.7, El Salto de la Cascada (the Charco, x -320.5 to -284, y 113 to 128, as today)
CH_FLOOR, CH_S, CH_ROOF = 113.0, 115.0, 128.0
WEST_POOL = (-320.5, -303.0)
EAST_BASIN = (-297.0, -288.0)
POOL_FLOW, POOL_LIP_FLOW = 1.0, 1.6
Q6 = (-296.6, -284.0, 117.4)    # today -291 to -284: 5.6 m longer, to the falls' edge
Q7 = (-320.5, -314.0, 117.2)    # as today
DAVIT_CHAIN = (-296.9, 121.6, 2.2)
C1 = (-306.8, 121.8, 6.2)
C2 = (-310.6, 121.8, 6.2)
Q7_RUNGS = [(-314.2, 115.45), (-314.2, 116.25)]

BARREL = [(-0.9, -0.3), (-0.6, -0.55), (0.6, -0.55), (0.9, -0.3), (0.9, 0.3), (0.6, 0.55), (-0.6, 0.55), (-0.9, 0.3)]


def box(x0, y0, x1, y1, kind):
    return {"pts": [[x0, y0], [x1, y0], [x1, y1], [x0, y1]], "kind": kind}


def hanging(x0, x1, y, kind="stone", t=LANDING_T):
    """A2's slab(): a slick body with a pale grip coping on top."""
    return [box(x0, y - t, x1, y - 0.2, "wet"), box(x0, y - 0.3, x1, y, kind)]


def section_air():
    from shapely.geometry import box as sbox
    from shapely.ops import unary_union
    parts = [sbox(FALLS[0], MINE_TOP, FALLS[1], CEIL_W),
             sbox(*LIP_ROOM),
             sbox(FLUME[0], BED, FLUME[1], CEIL_W),
             sbox(EAST_LANDING[1], LANDING, GATE[0], CEIL_E),
             sbox(GATE[1], LOCK_FLOOR, LOCK[1], LOCK_CEIL),
             sbox(GATE[0], LANDING, GATE[1], LANDING + 2.5),          # the wicket
             sbox(SLOT[0], 84.0, SLOT[1], 89.4), sbox(DRY[0], 84.0, DRY[1], 89.4)]
    return unary_union(parts)


def section_shell():
    from shapely.geometry import Polygon
    return Polygon([(-307.0, MINE_TOP), (-222.0, MINE_TOP), (-222.0, 89.4), (-252.0, 89.4), (-252.0, CEIL_E),
                    (-292.0, CEIL_E), (-292.0, CEIL_W), (-307.0, CEIL_W)])


def _poly_solids(geom, kind):
    out = []
    for g in getattr(geom, "geoms", [geom]):
        if g.geom_type != "Polygon" or g.area < 0.05:
            continue
        if len(g.interiors):
            from shapely.geometry import box as sbox
            x0, y0, x1, y1 = g.bounds
            cx = g.interiors[0].centroid.x
            out += _poly_solids(g.intersection(sbox(x0 - 1, y0 - 1, cx, y1 + 1)), kind)
            out += _poly_solids(g.intersection(sbox(cx, y0 - 1, x1 + 1, y1 + 1)), kind)
            continue
        out.append({"pts": [[round(x, 3), round(y, 3)] for x, y in list(g.exterior.coords)[:-1]], "kind": kind})
    return out


def build_section():
    rock = section_shell().difference(section_air())
    sol = _poly_solids(rock, "wet")
    # the pier between the slot and the dry shaft, from its foot at 84 (it was the mine's roof below 89.4)
    sol.append(box(PIER[0], 84.0, PIER[1], 89.4, "wet"))
    # the lip room's floor: the pier's top given a pale coping (it is the mine's slick roof today), and the old lip's grip
    sol.append(box(-297.0, MINE_TOP - 0.3, -295.0, MINE_TOP, "stone"))
    # the landings, the quay, the lock's ledges and rungs
    sol += hanging(WEST_LANDING[0], WEST_LANDING[1], LANDING)
    sol += hanging(EAST_LANDING[0], EAST_LANDING[1], LANDING)
    sol.append(box(QUAY[0], LANDING - 0.3, QUAY[1], LANDING, "stone"))
    sol.append(box(GATE[0], LANDING - 0.3, L0[1], LANDING, "stone"))          # the wicket's sill, into the lock (L0)
    sol.append(box(GATE[0], LANDING + 2.5, GATE[1], LOCK_CEIL, "grease"))    # the lower gate above the wicket
    sol.append(box(GATE[0], LOCK_FLOOR, GATE[1], LANDING - 0.3, "grease"))   # and below it
    for x0, x1, y in (L1, L2):
        sol += [box(x0, y - 0.55, x1, y - 0.25, "wet"), box(x0, y - 0.3, x1, y, "stone")]
    for x, y in PIER_RUNGS + DRY_RUNGS:
        sol.append(box(x - 0.25, y - 0.07, x + 0.25, y + 0.07, "iron"))
    sol.append(box(SLOT[0], 85.4, SLOT[1], 86.0, "iron"))                    # the upstream flap gate, shut (it swings down to open)
    zones = [{"type": "water", "rect": [FLUME[0], BED, FLUME[1], S], "surface": S},
             {"type": "water", "rect": [LOCK[0] - 0.0, LOCK_FLOOR, LOCK[1], LOCK_LOW], "surface": LOCK_LOW}]
    movers = [{"at": [COVE_X, BARREL_Y], "shapes": [], "motion": {"type": "path", "pts": [[COVE_X, BARREL_Y], [LIP_X, BARREL_Y]]}}]
    x = -276.5                                          # a moment in the rhythm: the barrels where they would be
    for g in [0.0] + BARREL_GAPS[:6]:
        x -= g
        if x < WATER_EDGE + 0.9:
            break
        movers.append({"at": [round(x, 2), BARREL_Y], "shapes": [{"pts": [list(p) for p in BARREL], "kind": "wood"}], "motion": {}})
    ropes = [{"at": [CHAIN[0], CHAIN[1]], "len": CHAIN[2]}]
    return {"solids": sol, "zones": zones, "movers": movers, "ropes": ropes}


NEW_SEC = build_section()


def build_charco():
    """2.7 remade: what is drawn new in the Charco (the hall itself, its roof and flanks stay as today)."""
    sol = []
    sol += hanging(Q6[0], Q6[1], Q6[2])
    sol += hanging(Q7[0], Q7[1], Q7[2])
    sol.append(box(-303.4, CH_FLOOR, -303.0, CH_S - 0.3, "stone"))           # the pool's lip sill
    sol.append(box(-297.0, CH_FLOOR, -296.6, CH_S - 0.3, "stone"))           # the east basin's sill, on the falls' edge
    for x, y in Q7_RUNGS:
        sol.append(box(x - 0.25, y - 0.07, x + 0.25, y + 0.07, "iron"))
    zones = [{"type": "water", "rect": [WEST_POOL[0], CH_FLOOR, WEST_POOL[1], CH_S], "surface": CH_S},
             {"type": "water", "rect": [EAST_BASIN[0], CH_FLOOR, EAST_BASIN[1], CH_S], "surface": CH_S}]
    ropes = [{"at": [DAVIT_CHAIN[0], DAVIT_CHAIN[1]], "len": DAVIT_CHAIN[2]},
             {"at": [C1[0], C1[1]], "len": C1[2]}, {"at": [C2[0], C2[1]], "len": C2[2]}]
    return {"solids": sol, "zones": zones, "ropes": ropes, "movers": []}


NEW_CHARCO = build_charco()


def a2_edited():
    """Today's black waters with note 146's cuts: the falls' shaft through the Charco's bed, the pool split,
    the barrels, the cove and the old Q6/Q7 taken out (NEW_CHARCO draws their replacements)."""
    from shapely.geometry import Polygon, box as sbox
    n = copy.deepcopy(OLD["a2"])
    cut = sbox(FALLS[0], 83.0, FALLS[1], CH_FLOOR + 0.01)
    sols = []
    for s in n["solids"]:
        xs, ys = [q[0] for q in s["pts"]], [q[1] for q in s["pts"]]
        bb = (min(xs), min(ys), max(xs), max(ys))
        if bb[0] >= -321.0 and bb[2] <= -283.9 and 116.0 < bb[3] < 118.0:     # today's Q6 and Q7 (redrawn)
            continue
        p = Polygon(s["pts"])
        if p.is_valid and p.intersects(cut) and p.intersection(cut).area > 0.01:
            for g in _poly_solids(p.difference(cut), s["kind"]):
                g["skin"] = s.get("skin")
                sols.append(g)
            continue
        sols.append(s)
    n["solids"] = sols
    n["movers"] = [m for m in n["movers"] if not m["id"].startswith("barril")]
    n["zones"] = [z for z in n["zones"] if not (z.get("type") == "water" and z.get("rect", [0])[0] == -320.5 and z.get("surface") == 115.0)]
    n["decos"] = []
    return n


NEW_A2 = a2_edited()

# ================================================================== where every challenge now starts
STARTS = []   # (id, name, (x, y) today or None, (x, y) after, note)


def _starts():
    for a in ("a0",):
        for ch in OLD[a]["challenges"]:
            STARTS.append((ch["id"], ch["name"], tuple(ch["anchor"]), tuple(ch["anchor"]), "unchanged" if ch["id"] != "0.3" else
                           "same start; the ride is %.0f m longer and stops at the mine's moved door" % (path_len(RIDE_NEW) - path_len(RIDE_OLD))))
    for ch in OLD["a1"]["challenges"]:
        STARTS.append((ch["id"], ch["name"], tuple(ch["anchor"]), mv(*ch["anchor"]), "moved with the mine"))
    STARTS.append(("1.12", "Los Barriles (working number)", None, (-296.0, MINE_TOP), "new: on the pier's top under the flume's lip"))
    STARTS.append(("1.13", "La Esclusa (working number)", None, (-249.3, LANDING), "new: on the wicket's sill inside the lock's lower gate"))
    for ch in OLD["a2"]["challenges"]:
        if ch["id"] == "2.7":
            STARTS.append(("2.7", "El Salto de la Cascada (was El Charco del Pozo)", tuple(ch["anchor"]), tuple(ch["anchor"]),
                           "same start on Q6; the launch is Q6's new west end, x -296.6"))
        else:
            STARTS.append((ch["id"], ch["name"], tuple(ch["anchor"]), tuple(ch["anchor"]), "unchanged"))


_starts()

# ================================================================== the checks (printed, and listed on the index page)
CHECKS = []


def _union(solids, kinds=None, grip_only=False):
    from shapely.geometry import Polygon
    from shapely.ops import unary_union
    ps = []
    for s in solids:
        if kinds and s["kind"] not in kinds:
            continue
        if grip_only and not META["kinds"].get(s["kind"], {}).get("grip", True):
            continue
        p = Polygon(s["pts"])
        if not p.is_valid:
            p = p.buffer(0)
        if p.area > 1e-6:
            ps.append(p)
    return unary_union(ps)


def water_at(t):
    """The lock's water level t seconds into its cycle (0: the flap drops)."""
    t = t % CYCLE
    span = LOCK_HIGH - LOCK_LOW
    if t < RISE:
        return LOCK_LOW + span * t / RISE
    if t < RISE + HOLD:
        return LOCK_HIGH
    if t < RISE + HOLD + DRAIN:
        return LOCK_HIGH - span * (t - RISE - HOLD) / DRAIN
    return LOCK_LOW


def reach_window(level=88.0 - 0.1):
    return sum(0.01 for k in range(int(CYCLE * 100)) if water_at(k / 100.0) >= level)


def run_checks():
    from shapely.geometry import box as sbox, Polygon
    out = []
    mine = _union(NEW_A1["solids"])
    a2 = _union(OLD["a2"]["solids"])
    a2n = _union(NEW_A2["solids"])
    st = _union(OLD["st"]["solids"])
    sec = _union(NEW_SEC["solids"])
    air = section_air()
    mb = mine.bounds
    out.append(("The moved mine's outline", "x %.1f to %.1f, y %.1f to %.1f (today x -257.4 to -148.0, y -37.0 to 90.0)." % (mb[0], mb[2], mb[1], mb[3])))
    out.append(("The mine against the black waters", "it overlaps their solids by %.2f square metres; its top (y %.1f) is %.1f m under their lowest rock (y 83)."
                % (mine.intersection(a2).area, mb[3], 83.0 - mb[3])))
    out.append(("The mine against the well and the mountain's shared rock", "overlap %.2f square metres (the well's lowest solid is at y 176)." % mine.intersection(st).area))
    # without the drop: the mine moved only west
    only_x = _union(copy.deepcopy([dict(s, pts=[[q[0] + DX + (WIDEN if q[0] < WIDEN_X else 0), q[1]] for q in s["pts"]]) for s in OLD["a1"]["solids"]]))
    out.append(("If the mine moved only west (no drop)", "it would overlap the black waters' rock by %.1f square metres (its throat's roof, y 86 to 90, "
                "against their rock that starts at y 83 west of x -292), and there would be no room above it for the flume and the lock. "
                "So it drops 17 m, as in Parker's drawing." % only_x.intersection(a2).area))
    out.append(("Out of the world", "the Sump's floor goes from y -33 to %.0f, its rock to %.0f; the game's bug net is at y -60 (stages/peak/peak.gd out_of_world). "
                "Any drop deeper than about 26 m would put the Sump outside it." % (-33.0 + DY, mb[1])))
    # the new section
    out.append(("The new section against the black waters", "its solids overlap theirs by %.2f square metres; its air overlaps their solids by %.2f "
                "(that is the falls' column, where their rock is cut on purpose)." % (sec.intersection(a2n).area, air.intersection(a2n).area)))
    out.append(("The new section against the moved mine", "overlap %.2f square metres, all of it the pier's new coping laid into the top of the mine's roof "
                "(a rebate, as the old lip had): the section sits on the mine's roof at y %.1f." % (sec.intersection(mine).area, MINE_TOP)))
    # the cart tunnel
    tun = _union(NEW_A0["solids"])
    old_seam = _union(OLD["a0"]["solids"]).intersection(_union(OLD["a1"]["solids"])).area
    out.append(("The longer tunnel against the moved mine", "overlap %.1f square metres, the tunnel's last 4 m lying in the mine's door frame: the same seam as today "
                "(%.1f square metres). Its west end meets the mine's door at x %.0f, floor y %.1f." % (tun.intersection(mine).area, old_seam, DOOR_X, DOOR_FLOOR)))
    out.append(("The longer tunnel against the new section", "%.0f m of rock between the tunnel's roof (y %.1f at its west end) and the section's floor (y %.0f)."
                % (MINE_TOP - (DOOR_FLOOR + 5.0), DOOR_FLOOR + 5.0, MINE_TOP)))
    # the falls' line against every grip surface
    col = sbox(FALLS[0], -45.0, FALLS[1], 176.0)
    hits = []
    for name, sols in (("the mine", NEW_A1["solids"]), ("the black waters", NEW_A2["solids"]), ("the new section", NEW_SEC["solids"]),
                       ("the Charco's new pieces", NEW_CHARCO["solids"]), ("the mountain's rock", OLD["st"]["solids"])):
        for s in sols:
            if not META["kinds"].get(s["kind"], {}).get("grip", True):
                continue
            p = Polygon(s["pts"]).buffer(0)
            if p.intersects(col) and p.intersection(col).area > 1e-4:
                b = p.bounds
                hits.append("%s: %s at x %.1f to %.1f, y %.1f" % (name, s["kind"], b[0], b[2], b[3]))
    out.append(("The great falls' column (x -303 to -297, y -45 to 176) against every surface you can hold",
                ("%d crossing: " % len(hits) + "; ".join(hits) + ". It is meant: the crane's platform overhangs the lip by 0.6 m so its chain "
                 "hangs beside the falls. Nothing else you can hold is in the falls' way.") if hits else "it touches none."))
    near = []
    for name, sols in (("the mine", NEW_A1["solids"]), ("the new section", NEW_SEC["solids"]), ("the Charco's new pieces", NEW_CHARCO["solids"])):
        for s in sols:
            if not META["kinds"].get(s["kind"], {}).get("grip", True):
                continue
            p = Polygon(s["pts"]).buffer(0)
            d = p.distance(col)
            if 0 <= d < 0.75 and not p.intersects(col):
                b = p.bounds
                near.append("%s: %s at x %.1f to %.1f, y %.1f (%.2f m off)" % (name, s["kind"], b[0], b[2], b[3], d))
    out.append(("Holds within 0.75 m of the falls (meant to be beside them)", "; ".join(near) if near else "none"))
    ropes_in = []
    for name, rs in (("the mine", NEW_A1["ropes"]), ("the new section", NEW_SEC["ropes"]), ("the Charco", NEW_CHARCO["ropes"])):
        for r in rs:
            x = r["at"][0]
            dist = 0.0 if FALLS[0] <= x <= FALLS[1] else min(abs(x - FALLS[0]), abs(x - FALLS[1]))
            if dist < 1.0:
                ropes_in.append("%s: rope at x %.2f, y %.1f to %.1f (%.2f m from the column)" % (name, x, r["at"][1] - r["len"], r["at"][1], dist))
    out.append(("Ropes and chains beside the falls", "; ".join(ropes_in) if ropes_in else "none"))
    # reach checks
    out.append(("Reach: the curtain's top hold to the pier's top", "%.2f m (the climber reaches 2.13)" % math.dist((mvx(-235.6 + 0.11 * 13), 89.55 + DY), (-295.0, MINE_TOP))))
    out.append(("Reach: the pier's top to the lip chain's tail", "%.2f m up, %.2f m out" % (CHAIN[1] - CHAIN[2] - MINE_TOP, FALLS[1] - CHAIN[0])))
    out.append(("Clearance: a barrel under the landings", "%.2f m (a barrel's top at %.2f, the landings' undersides at %.2f; today 0.85)"
                % (LANDING - LANDING_T - (BARREL_Y + 0.55), BARREL_Y + 0.55, LANDING - LANDING_T)))
    out.append(("Headroom: the lip room", "%.1f m (the climber is 1.8 m)" % (BED_LO - MINE_TOP)))
    out.append(("Headroom: on a barrel, and on the west landing", "%.2f m and %.2f m under the ceiling at y %.0f" % (CEIL_W - (BARREL_Y + 0.55), CEIL_W - LANDING, CEIL_W)))
    out.append(("Reach: the lock's highest water to the lip ledge", "%.1f m (the lip ledge's top at 90; floating at %.1f). The top rung is %.1f m under it, out of reach."
                % (90.0 - LOCK_HIGH, LOCK_HIGH, 90.0 - DRY_RUNGS[-1][1])))
    out.append(("The lock's lift", "%.1f m in %.0f s (%.2f m a second), held %.0f s, down in %.0f s (%.2f m a second), then %.0f s at the bottom (added): an %.0f s "
                "cycle. The chamber is %.1f m from its floor to the dry shaft's top. The lip ledge is in reach (2.1 m) while the water is over %.1f: %.1f s of each cycle."
                % (LOCK_HIGH - LOCK_LOW, RISE, (LOCK_HIGH - LOCK_LOW) / RISE, HOLD, DRAIN, (LOCK_HIGH - LOCK_LOW) / DRAIN, LOW_HOLD, CYCLE, 89.4 - LOCK_FLOOR,
                   90.0 - 2.1, reach_window())))
    loop = sum(BARREL_GAPS)
    out.append(("The barrels", "8 barrels, %.2f m a second, a %.1f m loop, %.1f m of road from the tunnel to the lip, %.1f s unseen each loop: all as today. "
                "Water between them: %s m." % (BARREL_SPEED, loop, ROAD, (loop - ROAD) / BARREL_SPEED, ", ".join("%.1f" % (g - 1.8) for g in BARREL_GAPS))))
    out.append(("The cart ride", "%.1f m of road today, %.1f m after (%.1f m longer); its end goes from (-148.4, -11.55) to (-207.4, -28.55). "
                "The new incline is 20 degrees; the steepest stretch today is 17 (after the hop)." % (path_len(RIDE_OLD), path_len(RIDE_NEW), path_len(RIDE_NEW) - path_len(RIDE_OLD))))
    out.append(("2.7's jump", "from the davit chain (x %.1f) over the falls (x -297 to -303) to the pool beyond: %.1f m to the pool's lip, %.1f to %.1f m to the "
                "landing water, %.1f m down. An F2 fling (up to 8 m level, more with a drop)." % (DAVIT_CHAIN[0], DAVIT_CHAIN[0] - WEST_POOL[1], DAVIT_CHAIN[0] + 303.6,
                                                                                               DAVIT_CHAIN[0] + 306.0, DAVIT_CHAIN[1] - DAVIT_CHAIN[2] - CH_S)))
    for k, v in out:
        CHECKS.append((k, v))
    return out


# ================================================================== drawing helpers (the design pages' own primitives)
def R(x0, y0, x1, y1, st=None):
    return ["rect", x0, y0, x1, y1] + ([{"style": st}] if st else [])


def L(x0, y0, x1, y1, st=None):
    return ["line", x0, y0, x1, y1] + ([{"style": st}] if st else [])


def C(x, y, r, st=None):
    return ["circle", x, y, r] + ([{"style": st}] if st else [])


def P(pts, st=None):
    return ["poly", [list(p) for p in pts]] + ([{"style": st}] if st else [])


def T(x, y, t):
    return ["text", x, y, t]


def LAD(x, y0, y1):
    return ["ladder", x, y0, y1]


def arch(x0, x1, y0, ys, st=None, n=8):
    r, cx = (x1 - x0) / 2.0, (x0 + x1) / 2.0
    pts = [[x0, y0], [x0, ys]]
    pts += [[round(cx - r * math.cos(math.pi * i / n), 2), round(ys + r * math.sin(math.pi * i / n), 2)] for i in range(1, n)]
    pts += [[x1, ys], [x1, y0]]
    return P(pts, st)


# ================================================================== the overview map (matplotlib, the course's own metres)
def _mpl():
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    from matplotlib.patches import Polygon as MPoly, Rectangle
    return plt, MPoly, Rectangle


def _draw_solids(ax, MPoly, solids, pal, alpha=1.0, faint=False, z=2):
    for s in solids:
        if faint:
            ax.add_patch(MPoly(s["pts"], closed=True, facecolor="#8a8178", edgecolor="#b9b0a4", lw=0.4, alpha=0.16, zorder=z))
        else:
            ax.add_patch(MPoly(s["pts"], closed=True, facecolor=B.kind_fill(pal, s["kind"]), edgecolor="#0f0b08", lw=0.35, alpha=alpha, zorder=z))


def _draw_water(ax, Rectangle, zones, alpha=0.5, z=3):
    for zz in zones:
        if zz.get("type") == "water":
            r = zz["rect"]
            top = zz.get("surface", r[3])
            ax.add_patch(Rectangle((r[0], r[1]), r[2] - r[0], top - r[1], facecolor="#2b6cb0", edgecolor="none", alpha=alpha, zorder=z))


def _draw_movers(ax, MPoly, c, pal, z=4):
    for m in c.get("movers", []):
        ax_, ay = m["at"]
        for sh in m.get("shapes", []):
            ax.add_patch(MPoly([(ax_ + q[0], ay + q[1]) for q in sh["pts"]], closed=True, facecolor=B.kind_fill(pal, sh["kind"]),
                               edgecolor="#5fe0e0", lw=0.5, zorder=z))
        mo = m.get("motion", {})
        if mo.get("type") == "path" and len(mo.get("pts", [])) > 1:
            xs, ys = zip(*mo["pts"])
            ax.plot(xs, ys, color="#5fe0e0", lw=0.6, ls=(0, (2, 3)), zorder=z)
    for r in c.get("ropes", []):
        x, y = r["at"]
        bx, by = r.get("to", [x, y - r["len"]])
        ax.plot([x, bx], [y, by], color="#e8c27a", lw=1.2, zorder=z)


def overview(path, win=(-470.0, -62.0, 25.0, 190.0), size=(26.0, 13.6), dpi=110, close=False):
    plt, MPoly, Rectangle = _mpl()
    x0, y0, x1, y1 = win
    fig = plt.figure(figsize=size, dpi=dpi, facecolor="#17120f")
    ax = fig.add_axes([0.04, 0.05, 0.95, 0.87])
    ax.set_facecolor("#17120f")
    ax.set_xlim(x0, x1)
    ax.set_ylim(y0, y1)
    ax.set_aspect("equal")
    for sp in ax.spines.values():
        sp.set_color("#6b625a")
    ax.tick_params(colors="#b9b0a4", labelsize=9 if not close else 10)
    step = 50 if not close else 10
    ax.set_xticks([v for v in range(int(math.ceil(x0 / step) * step), int(x1) + 1, step)])
    ax.set_yticks([v for v in range(int(math.ceil(y0 / step) * step), int(y1) + 1, step)])
    ax.grid(color="#2c2622", lw=0.5, zorder=0)
    ax.set_xlabel("x, metres (negative is into the mountain)", color="#b9b0a4", fontsize=10)
    ax.set_ylabel("y, metres (height)", color="#b9b0a4", fontsize=10)
    # ---- today, faint: what moves or goes
    _draw_solids(ax, MPoly, OLD["a1"]["solids"], PAL["a1"], faint=True, z=1)
    _draw_solids(ax, MPoly, [s for s in OLD["a0"]["solids"] if min(q[0] for q in s["pts"]) < -136.1], PAL["a0"], faint=True, z=1)
    _draw_water(ax, Rectangle, OLD["a1"]["zones"], alpha=0.12, z=1)
    old_mine = _union(OLD["a1"]["solids"])
    for g in getattr(old_mine, "geoms", [old_mine]):
        xs, ys = g.exterior.xy
        ax.plot(xs, ys, color="#b9b0a4", lw=0.8, ls=(0, (4, 3)), alpha=0.55, zorder=1)
    # ---- after: the mountain's rock, the station and the longer tunnel, the moved mine, the black waters, the new section
    _draw_solids(ax, MPoly, OLD["st"]["solids"], PAL["st"], alpha=0.9)
    _draw_solids(ax, MPoly, A0_KEEP["solids"] + NEW_A0["solids"], PAL["a0"])
    _draw_solids(ax, MPoly, NEW_A1["solids"], PAL["a1"])
    _draw_water(ax, Rectangle, NEW_A1["zones"])
    _draw_solids(ax, MPoly, NEW_A2["solids"], PAL["a2"])
    _draw_water(ax, Rectangle, NEW_A2["zones"])
    _draw_solids(ax, MPoly, NEW_SEC["solids"], PAL["a2"], z=3)
    _draw_water(ax, Rectangle, NEW_SEC["zones"], z=3)
    _draw_solids(ax, MPoly, NEW_CHARCO["solids"], PAL["a2"], z=3)
    _draw_water(ax, Rectangle, NEW_CHARCO["zones"], z=3)
    _draw_movers(ax, MPoly, NEW_A1, PAL["a1"])
    _draw_movers(ax, MPoly, NEW_SEC, PAL["a2"])
    _draw_movers(ax, MPoly, NEW_CHARCO, PAL["a2"])
    _draw_movers(ax, MPoly, {"movers": list(NEW_A2["movers"]), "ropes": NEW_A2["ropes"]}, PAL["a2"])
    _draw_movers(ax, MPoly, NEW_A0, PAL["a0"])
    # the lock's highest water: up the dry shaft to 88.5
    ax.add_patch(Rectangle((DRY[0], LOCK_CEIL), DRY[1] - DRY[0], LOCK_HIGH - LOCK_CEIL, facecolor="#2b6cb0", edgecolor="#7fb4ea", lw=0.7,
                           ls=(0, (3, 2)), alpha=0.25, zorder=5))
    ax.add_patch(Rectangle((LOCK[0], LOCK_LOW), LOCK[1] - LOCK[0], LOCK_CEIL - LOCK_LOW, facecolor="#2b6cb0", edgecolor="#7fb4ea", lw=0.7,
                           ls=(0, (3, 2)), alpha=0.18, zorder=5))
    # ---- the great falls: one column on the well's middle line
    ax.add_patch(Rectangle((FALLS[0], -45.0), FALLS[1] - FALLS[0], y1 + 45.0, facecolor="#cfe6ff", edgecolor="#ffffff", lw=0.6, alpha=0.30, zorder=6))
    for k, xx in enumerate((-302.2, -300.9, -299.4, -298.0)):
        ax.plot([xx, xx], [-45.0, y1], color="#ffffff", lw=0.5, alpha=0.5, ls=(0, (6 + k, 5)), zorder=6)
    # the widened falls area at the mine's west wall
    ax.add_patch(Rectangle((mvx(-248.0), -50.0), 6.0, 69.0 + 50.0, facecolor="none", edgecolor="#9be24a", lw=1.0, hatch="///", alpha=0.7, zorder=6))
    # the new section's outline
    xs, ys = section_shell().exterior.xy
    ax.plot(xs, ys, color="#ffd36a", lw=1.6, ls=(0, (6, 3)), zorder=7)
    # ---- challenge starts
    fs = 7.5 if not close else 10
    for cid, name, old_at, new_at, note in STARTS:
        if old_at and old_at != new_at and x0 <= old_at[0] <= x1 and y0 <= old_at[1] <= y1:
            ax.plot(*old_at, marker="o", ms=3, color="#8a8178", zorder=8)
            ax.annotate(cid, old_at, xytext=(2, 3), textcoords="offset points", color="#8a8178", fontsize=fs - 1, zorder=8)
        if not (x0 <= new_at[0] <= x1 and y0 <= new_at[1] <= y1):
            continue
        new = old_at is None or cid == "2.7"
        ax.plot(*new_at, marker="o", ms=6 if new else 4.5, color="#ffd36a" if new else "#ef6b63", mec="#1a1310", mew=0.6, zorder=9)
        lab = cid if not new else "%s %s" % (cid, name.replace(" (working number)", "").replace(" (was El Charco del Pozo)", ""))
        ax.annotate(lab, new_at, xytext=(4, 4), textcoords="offset points", color="#ffd36a" if new else "#f1eadf", fontsize=fs + (1 if new else 0),
                    fontweight="bold" if new else "normal", zorder=9)

    def say(x, y, t, c="#f1eadf", s=10, w="normal", ha="left"):
        if x0 <= x <= x1 and y0 <= y <= y1:
            ax.text(x, y, t, color=c, fontsize=s, fontweight=w, ha=ha, va="center", zorder=10,
                    bbox=dict(facecolor="#17120f", edgecolor="none", alpha=0.65, pad=1.5))
    if not close:
        say(-60, 20, "0 La Estación", "#e0b040", 13, "bold")
        say(-130, -24, "0.3 El Descenso: the tunnel runs on 59 m past today's end,\ndown a 20 degree incline, to the mine's moved door (x -211, y -29)", "#e0b040", 9.5)
        say(-206, -47, "1 La Mina Vieja: moved 59 m west and 17 m down,\nits west wall a further 6 m west", "#c98a35", 11, "bold")
        say(-200, 32, "today's mine (dashed, faint)", "#b9b0a4", 9)
        say(-338, -36, "the falls' cavern\nwidened 6 m", "#9be24a", 9, ha="right")
        say(-222, 80, "La Esclusa (new): Los Barriles and the lock", "#ffd36a", 11, "bold")
        say(-460, 100, "2 Las Aguas Negras", "#7fb4ea", 13, "bold")
        say(-292, 172, "the great falls: one column, x -303 to -297,\nfrom under the forge to the Sump", "#cfe6ff", 9.5)
        ax.annotate("", xy=(-240, 20), xytext=(-185, 37), arrowprops=dict(arrowstyle="->", color="#b9b0a4", lw=1.2), zorder=10)
    else:
        say(-290, 81.4, "Los Barriles: the flume", "#ffd36a", 10, "bold")
        say(-262, 84.6, "the quay", "#f1eadf", 9)
        say(-243, 83.6, "the lock", "#ffd36a", 10, "bold")
        say(-224.5, 91.5, "2.1's lip ledge", "#f1eadf", 9)
        say(-318, 71.0, "the mine's roof (moved)", "#c98a35", 9)
        say(-287, 66.5, "La Cortina's top: the dry shaft", "#f1eadf", 9)
        say(-300, 100, "the falls' shaft through\nthe black waters' floor", "#cfe6ff", 9, ha="center")
        say(-268, 93.0, "the lower river (2.1)", "#7fb4ea", 9)
    ttl = ("Note 146, the bottom of the mountain rearranged (design only): bold is after, faint and dashed is today" if not close else
           "Note 146, close up: the new section La Esclusa, the falls' shaft and 2.7 (design only)")
    fig.text(0.04, 0.965, ttl, color="#f1eadf", fontsize=14, fontweight="bold")
    fig.text(0.04, 0.94, "Red dots: challenge starts after the change (grey: where the moved ones start today). Yellow: the new and remade ones. "
             "Pale band: the great falls. Yellow dashes: the new section. Blue: water. Green hatch: the widening at the mine's west wall.",
             color="#b9b0a4", fontsize=9.5)
    fig.savefig(path, facecolor=fig.get_facecolor())
    plt.close(fig)
    return path


# ================================================================== the pages: sketches in the design system's own look
EXTRA_CSS = r'''
  .falls { fill:#cfe6ff; opacity:.24; } .fallsl { stroke:#ffffff; stroke-width:1; stroke-dasharray:8 6; opacity:.45; fill:none; }
  .hiw { fill:#2b6cb0; opacity:.14; stroke:#7fb4ea; stroke-width:1.2; stroke-dasharray:5 4; } .hiwl { stroke:#7fb4ea; stroke-width:1.5; stroke-dasharray:6 4; fill:none; }
  .newl { fill:none; stroke:#ffd36a; stroke-width:1.6; stroke-dasharray:7 4; } .oldl { fill:none; stroke:#b9b0a4; stroke-width:1; stroke-dasharray:4 3; opacity:.7; }
  .wid { fill:#9be24a; opacity:.16; stroke:#9be24a; stroke-width:1.2; } .push { fill:none; stroke:#cfe6ff; stroke-width:1; stroke-dasharray:1 6; }
  .note { fill:#ffd36a; font:bold 12px "Segoe UI", sans-serif; } .notep { fill:#cfe6ff; font:11px "Segoe UI", sans-serif; }
  .noteo { fill:#b9b0a4; font:11px "Segoe UI", sans-serif; }
  .lay { font-size:12px; letter-spacing:.06em; text-transform:uppercase; color:var(--soft); margin:20px 0 2px; }
  img.map { width:100%; height:auto; border:1px solid var(--line); border-radius:6px; display:block; }
  .chart { width:100%; height:auto; border:1px solid var(--line); border-radius:6px; display:block; background:#17120f; }
  .two { display:grid; grid-template-columns: minmax(0, 1fr) minmax(0, 1fr); gap:18px; } @media (max-width: 860px) { .two { grid-template-columns: 1fr; } }
  .fg { color:var(--gold); font-weight:600; }
'''
KEY2 = ('<div class="key"><div><span style="background:#cfe6ff;opacity:.6"></span>The great falls</div>'
        '<div><span style="border:2px dashed #7fb4ea"></span>The lock\'s highest water</div>'
        '<div><span style="background:#8a8178;opacity:.5"></span>Today, faint: what moves or goes</div>'
        '<div><span style="border:2px dashed #ffd36a"></span>The new section\'s outline</div></div>')
LAYERS = [("backdrop", "1. The painted backdrop", "far, 12 m and more behind: one painted scene, never a flat colour"),
          ("set", "2. The painted set", "the near back wall and its depth, 2 to 10 m behind"),
          ("things", "3. Real things", "the hero piece and the things round the climb"),
          ("climb", "4. The climb as things", "every ledge, hold, rope and mover a real object, its drawing the shape of its solid"),
          ("fore", "Foreground (sparse)", "framing only, where nobody climbs behind it")]
FAINT = '<g opacity="0.24">'


def sk_layer(it):
    z = it["z"]
    if max(z) <= -1.2 + 1e-6:
        return "background"
    if min(z) >= 1.2 - 1e-6:
        return "foreground"
    return "play"


def number(items):
    out, n = [], 0
    for lay, _, _ in LAYERS:
        for it in items:
            if it["layer"] == lay:
                n += 1
                out.append((n, it))
    return out


def falls_marks(y0, y1, push_below=None):
    m = [("poly", [(FALLS[0], y0), (FALLS[1], y0), (FALLS[1], y1), (FALLS[0], y1)], "falls")]
    for xx in (-302.2, -300.9, -299.4, -298.0):
        m.append(("line", [(xx, y0), (xx, y1)], "fallsl"))
    return m


def side(fig, numbered, png=None):
    """One side sketch: background items, today faint, the design's courses bold, marks, play and foreground items, tags."""
    sk = B.Sketch(fig["win"], maxw=fig.get("maxw", 760.0))
    draw = [(n, it) for n, it in numbered if fig.get("items", True) and (not fig.get("only") or n in fig["only"])]
    for n, it in draw:
        if sk_layer(it) == "background" and not it.get("over"):
            B.draw_item(sk, "background", it)
    if fig.get("faint"):
        sk.out.append(FAINT)
        for c, pal in fig["faint"]:
            B.draw_course(sk, c, pal)
        sk.out.append("</g>")
    for c, pal in fig.get("bold", []):
        B.draw_course(sk, c, pal)
    for t, pts, cls in fig.get("marks", []):
        if t == "poly":
            sk.poly(pts, cls)
        elif t == "line":
            sk.line(pts[0][0], pts[0][1], pts[1][0], pts[1][1], cls)
        elif t == "text":
            sk.text(pts[0][0], pts[0][1], pts[1], cls)
    for n, it in draw:
        if sk_layer(it) == "background" and it.get("over"):
            B.draw_item(sk, "background", it)
    for lay in ("play", "foreground"):
        for n, it in draw:
            if sk_layer(it) == lay:
                B.draw_item(sk, lay, it)
    if fig.get("screen"):
        cx, cy = fig["screen"]
        sk.out.append('<rect x="%s" y="%s" width="%.1f" height="%.1f" class="frame"/>' % (sk.X(cx - 9.75), sk.Y(cy + 5.5), 19.5 * sk.s, 11.0 * sk.s))
    for cl in fig.get("climbers", []):
        sk.man(cl[0], cl[1])
    for n, it in draw:
        bb = B.prim_bbox(it.get("draw", []))
        if it.get("tag"):
            sk.tag(n, it["tag"][0], it["tag"][1])
        elif bb:
            sk.tag(n, (bb[0] + bb[2]) / 2, (bb[1] + bb[3]) / 2)
    if png:
        B.render_png(sk, png)
    return sk.svg(fig.get("label", "side view, to scale"))


def tbl(head, rows):
    return B.table(head, rows)      # (build.page wraps every table for narrow screens)


def ul(xs):
    return "<ul>%s</ul>" % "".join("<li>%s</li>" % B.esc(x) for x in xs)


WARN = []


def page_html(P, png_dir=None):
    numbered = number(P["items"])
    for n, it in numbered:
        lay = sk_layer(it)
        if it["layer"] in ("backdrop", "set") and lay != "background":
            WARN.append("%s: '%s' is in layer %s but sits at z %s" % (P["slug"], it["name"], it["layer"], it["z"]))
        if it["layer"] == "fore" and lay != "foreground":
            WARN.append("%s: foreground '%s' at z %s" % (P["slug"], it["name"], it["z"]))
        if not B.prim_bbox(it.get("draw", [])):
            WARN.append("%s: '%s' draws nothing" % (P["slug"], it["name"]))
    b = ['<p class="sub"><a href="index.html">Note 146: the bottom of the mountain rearranged</a> &middot; '
         '<a href="../../PLAYTEST_NOTES.html#n146">Note 146 in the playtest notes</a></p>']
    b.append("<h1>%s</h1>" % B.esc(P["h1"]))
    b.append('<p class="sub">Design only. Nothing here is built. Numbers marked <span class="fg">first guess</span> are to be tuned by playing it.</p>')
    b.append("<h2>The place, in one paragraph</h2><p>%s</p>" % B.esc(P["place"]))
    for head, html_ in P.get("before", []):
        b.append("<h2>%s</h2>%s" % (B.esc(head), html_))
    if P.get("keep"):
        b.append("<h2>What must not change about the play</h2>" + ul(P["keep"]))
    if P.get("moves"):
        b.append("<h2>The moves, with their numbers</h2>" + (("<p>%s</p>" % B.esc(P["moves_intro"])) if P.get("moves_intro") else "")
                 + tbl(["Move", "From", "To", "How far", "How"], P["moves"]))
    for head, html_ in P.get("after_moves", []):
        b.append("<h2>%s</h2>%s" % (B.esc(head), html_))
    b.append("<h2>The sketches</h2><p>To scale, in the course's own metres (x is negative into the mountain, y is height). Today's course is drawn "
             "faint; the design is drawn in the course's own colours. The numbers on the sketch match the lists below.</p>" + B.KEY + KEY2)
    for k, fig in enumerate(P["figures"]):
        png = os.path.join(png_dir, "%s_%d.png" % (P["slug"], k)) if png_dir else None
        b.append("<figure>%s<figcaption>%s</figcaption></figure>" % (side(fig, numbered, png), B.esc(fig.get("caption", ""))))
    for head, html_ in P.get("charts", []):
        b.append("<h3>%s</h3>%s" % (B.esc(head), html_))
    b.append("<h2>The four layers</h2>")
    for lay, head, sub in LAYERS:
        rows = [(n, it) for n, it in numbered if it["layer"] == lay]
        b.append('<h3>%s</h3><p class="sub">%s</p>' % (B.esc(head), B.esc(sub)))
        if not rows:
            b.append('<p class="sub">Nothing.</p>')
            continue
        b.append('<ul style="list-style:none;padding-left:0">')
        for n, it in rows:
            z = it["z"]
            lo, hi = min(z), max(z)
            where = (" (%.1f to %.1f m behind you)" % (-hi, -lo)) if hi <= -1.2 else ((" (%.1f to %.1f m in front)" % (lo, hi)) if lo >= 1.2 else " (in the play space)")
            b.append('<li><span class="num">%d</span><b>%s.</b> %s<span class="sub">%s</span></li>' % (n, B.esc(it["name"]).rstrip("."), B.esc(it["text"]), where))
        b.append("</ul>")
    if P.get("explains"):
        b.append("<h2>How the background explains the play space</h2>" + tbl(["What you touch", "What it is, in the scene", "What stands behind it"], P["explains"]))
    if P.get("pieces"):
        b.append("<h2>Pieces</h2>" + tbl(["Piece", "Size", "How many", "Layer", "Kit, old model, or new"], P["pieces"]))
    if P.get("effects"):
        b.append("<h3>Small effects, no models</h3>" + ul(P["effects"]))
    if P.get("first"):
        b.append('<h2>First guesses</h2><p class="sub">Every one of these is a starting number, to be set by playing it.</p>' + ul(P["first"]))
    if P.get("notes"):
        b.append("<h2>Notes folded in</h2>" + ul(P["notes"]))
    if P.get("ask"):
        b.append('<div class="ask"><p><b>For Parker:</b></p><ul>%s</ul></div>' % "".join("<li>%s</li>" % B.esc(x) for x in P["ask"]))
    html_ = B.page(P["h1"], "\n".join(b)).replace("</style>", EXTRA_CSS + "</style>", 1)
    return html_


def it(layer, name, z, text, draw, **kw):
    d = {"layer": layer, "name": name, "z": z, "text": text, "draw": draw}
    d.update(kw)
    return d


def fy(x):
    """The new tunnel's floor (the rail bed's top) at x."""
    pts = sorted(FLOOR_NEW)
    for (xa, ya), (xb, yb) in zip(pts, pts[1:]):
        if xa <= x <= xb:
            return ya + (yb - ya) * (x - xa) / (xb - xa)
    return pts[0][1] if x < pts[0][0] else pts[-1][1]


def cycle_chart():
    """The lock's water over one cycle, with its ledges and the reach to the lip ledge."""
    W, H, l, r, t, bt = 760.0, 340.0, 40.0, 14.0, 50.0, 30.0
    y0, y1 = 75.5, 90.5
    X = lambda s: l + (W - l - r) * s / CYCLE
    Y = lambda y: t + (H - t - bt) * (y1 - y) / (y1 - y0)
    o = ['<rect x="0" y="0" width="%.0f" height="%.0f" fill="#17120f"/>' % (W, H)]
    for s in range(0, int(CYCLE) + 1, 2):
        o.append('<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="#2c2622"/>' % (X(s), t, X(s), H - bt))
        o.append('<text x="%.1f" y="%.1f" class="lbl2" text-anchor="middle">%d s</text>' % (X(s), H - bt + 16, s))
    # level lines: labels in the low-water stretch at the right (left side for the two that sit under the rising water)
    for y, name, col, side in ((LOCK_LOW, "lowest water 77.2", "#7fb4ea", "R"), (L0[2], "the wicket's sill 79.4", "#ffe08a", "R"),
                               (L2[2], "L2, east wall 81.0", "#ffe08a", "R"), (L1[2], "L1, west wall 82.4", "#ffe08a", "R"),
                               (LOCK_CEIL, "the chamber's roof 86 (only the dry shaft goes on up)", "#b9b0a4", "R"),
                               (DRY_RUNGS[-1][1], "top rung 87.6", "#ffe08a", "L"), (90.0 - 2.1, "lip ledge in reach above 87.9", "#ef6b63", "R"),
                               (90.0, "the lip ledge, 90", "#ef6b63", "R")):
        o.append('<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="%s" stroke-dasharray="4 4" stroke-width="1"/>' % (l, Y(y), W - r, Y(y), col))
        if side == "R":
            o.append('<text x="%.1f" y="%.1f" class="lbl2" fill="%s" text-anchor="end">%s</text>' % (W - r - 4, Y(y) - 3, col, B.esc(name)))
        else:
            o.append('<text x="%.1f" y="%.1f" class="lbl2" fill="%s">%s</text>' % (l + 4, Y(y) + 12, col, B.esc(name)))
    pts = " ".join("%.1f,%.1f" % (X(k / 10.0), Y(water_at(k / 10.0))) for k in range(int(CYCLE * 10) + 1))
    o.append('<polygon points="%.1f,%.1f %s %.1f,%.1f" fill="#2b6cb0" opacity=".35"/>' % (l, Y(y0), pts, X(CYCLE), Y(y0)))
    o.append('<polyline points="%s" fill="none" stroke="#7fb4ea" stroke-width="2.2"/>' % pts)
    # events: ticks, labelled in two rows above the plot
    for k, (s, txt) in enumerate(((0.0, "0 s: the flap drops, the river pours in"), (RISE, "held"), (RISE + HOLD, "the sluices open: it drains"),
                                  (RISE + HOLD + DRAIN, "at the bottom: the wicket opens"), (CYCLE - WARN_T, "the keeper's lever"))):
        o.append('<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="#ffd36a" stroke-width="1"/>' % (X(s), t - (8 if k % 2 == 0 else 24), X(s), H - bt))
        anchor = "start" if s < CYCLE * 0.7 else "end"
        o.append('<text x="%.1f" y="%.1f" class="lbl2" fill="#ffd36a" text-anchor="%s">%s</text>'
                 % (X(s) + (3 if anchor == "start" else -3), t - (11 if k % 2 == 0 else 27), anchor, B.esc(txt)))
    for k in range(int(y0) + 1, int(y1) + 1, 2):
        o.append('<text x="%.1f" y="%.1f" class="lbl2" text-anchor="end">%d</text>' % (l - 6, Y(k) + 4, k))
    return '<svg viewBox="0 0 %.0f %.0f" class="chart" role="img" aria-label="The lock\'s water level over one cycle">%s</svg>' % (W, H, "".join(o))


def rhythm_strip():
    """The barrels' written spacing, as it would look on the flume at one moment (as today, running west)."""
    W, H = 760.0, 92.0
    s = (W - 40) / (sum(BARREL_GAPS) + 2)
    o = ['<rect x="0" y="0" width="%.0f" height="%.0f" fill="#17120f"/>' % (W, H)]
    x = W - 20
    o.append('<text x="%.1f" y="16" class="lbl2" text-anchor="end">east: out of the tunnel</text>' % (W - 20))
    o.append('<text x="20" y="16" class="lbl2">west: to the lip and the falls</text>')
    o.append('<line x1="20" y1="58" x2="%.1f" y2="58" stroke="#2b6cb0" stroke-width="10" opacity=".5"/>' % (W - 20))
    for k, g in enumerate(BARREL_GAPS):
        bx = x - 0.9 * s
        o.append('<rect x="%.1f" y="46" width="%.1f" height="20" rx="6" fill="#e39a3c" stroke="#5fe0e0"/>' % (bx, 1.8 * s))
        x2 = x - g * s
        water = g - 1.8
        col = "#ffd36a" if water < 1.4 else ("#ef6b63" if water > 3 else "#e0a84a")
        o.append('<text x="%.1f" y="84" class="lbl2" text-anchor="middle" fill="%s">%.1f m%s</text>' % ((x - 0.9 * s + x2 + 0.9 * s) / 2, col, water, " swim" if water > 3 else (" lunge" if water > 1.4 else "")))
        x = x2
    return '<svg viewBox="0 0 %.0f %.0f" class="chart" role="img" aria-label="The barrels\' spacing">%s</svg>' % (W, H, "".join(o))


# ------------------------------------------------------------------ the pages
def nodecos(c):
    n = dict(c)
    n["decos"] = []
    return n


def faint_today(*ids):
    return [(nodecos(OLD[a]), PAL[a]) for a in (ids or ("a1", "a2"))]


def page_barriles():
    win = [-305.5, 70.0, -262.0, 85.0]
    marks = falls_marks(70.0, 85.0) + [("text", [(-304.8, 84.1), "the great falls"], "notep"),
                                       ("text", [(-262.4, 84.1), "the quay and the lock: east"], "noteo")]
    items = [
        it("backdrop", "The view down the great falls", [-16.0, -12.0],
           "A painted card 12 m behind the falls, the height of the whole drop: the falls' column going down past the mine's lit curtain into mist "
           "and dark, the mine's lanterns as warm dots far below on its east side, and at the top the falls coming out of the black waters' floor. "
           "The one place where you see the whole of the great falls at once. The same card carries on down behind the mine's throat.",
           [R(-305.3, 70.2, -297.3, 82.8, "dark"), L(-304.5, 82.6, -304.5, 70.4, "mark"), L(-302.8, 82.6, -302.8, 70.4, "mark"),
            L(-301.1, 82.6, -301.1, 70.4, "mark"), L(-299.4, 82.6, -299.4, 70.4, "mark")], tag=[-305.0, 76.0]),
        it("backdrop", "The vaults going back", [-16.0, -12.0],
           "Seen through the arcade's arches: rows of brick vaults going back into the dark, the flume's water running away under them as a channel "
           "that catches the lanterns, each row darker and smaller, and a lantern speck at the far end. A flat painted card, the house style.",
           [arch(-291.2, -287.6, 77.2, 79.6, "line"), arch(-284.7, -281.1, 77.2, 79.6, "line"), arch(-278.2, -275.8, 77.2, 79.0, "line"),
            arch(-268.6, -265.2, 77.2, 79.6, "line"), C(-283.0, 78.4, 0.08, "light")], tag=[-283.0, 80.6]),
        it("set", "The flume's arcade", [-2.6, -2.2],
           "The flume's back wall is a brick arcade: piers 1 m wide every 6.5 m, round arches between them, cut stone in long courses below the "
           "springing, iron mooring rings let into the piers at the waterline, and the brick vault of the roof overhead, cracked along its crown with "
           "a dark seep line. So the wall is a place with depth, not a slab.",
           [R(-293.5, 77.2, -292.5, 83.0, "pale"), R(-287.0, 77.2, -286.0, 83.0, "pale"), R(-280.5, 77.2, -279.5, 83.0, "pale"),
            R(-266.4, 77.2, -265.4, 83.0, "pale"), L(-297.0, 82.4, -264.5, 82.4, "line")], tag=[-286.5, 81.6]),
        it("set", "The barrels' tunnel", [-7.0, -1.3],
           "A brick arch at the waterline in the back wall, 5.5 m wide, a sluice gate jammed half raised in its mouth, black inside. Behind it a tunnel "
           "runs back and up into the rock to the bypass that brings the river down past the lock. Each barrel is born 7 m back in it, where no light "
           "reaches, and drifts forward out of the dark into your plane over its first 2.4 m. You never see one appear (note 114).",
           [arch(-275.5, -270.0, 75.7, 78.8, "dark"), R(-275.1, 79.5, -270.4, 81.0, "pale")], tag=[-272.7, 77.9]),
        it("things", "The broken crane", [-3.4, -2.4],
           "The hero piece. The company's barrel crane, still standing on its platform at the head of the falls: a riveted iron post, its jib snapped "
           "and hanging out over the falls at a slant with the pulley still on it, its hook long gone down the falls. Behind the climb, so it covers "
           "nothing, and lit by the lantern on its post. It says what this place was for: barrels came along the flume and were swung down to the mine.",
           [R(-296.1, 79.4, -295.5, 82.6, "pale"), P([[-295.8, 82.4], [-302.6, 79.7], [-302.7, 80.05], [-295.8, 82.8]], "pale"), C(-302.4, 79.55, 0.32, "line")],
           tag=[-299.2, 81.7]),
        it("things", "Lanterns", [-2.3, -2.1],
           "Works lanterns on brackets: one on the crane's post so the lip and its chain are lit, one on each of two piers, one over the east landing. "
           "Teal and steady (note 17: nothing in this biome's light pulses).",
           [C(-295.0, 82.0, 0.17, "light"), C(-286.5, 81.5, 0.17, "light"), C(-280.0, 81.5, 0.17, "light"), C(-268.0, 81.9, 0.17, "light")], tag=[-280.0, 82.3]),
        it("things", "The barrel men's things", [-2.4, -1.6],
           "On the east landing's back wall: a rack of boat hooks for fishing barrels out, a chalk tally board of barrels counted (the last column never "
           "finished), and a coil of rope on a peg. Small, dry and pale, so the landing reads as the place people stood.",
           [R(-269.4, 79.4, -268.7, 81.8, "pale"), R(-268.3, 80.3, -267.2, 81.4, "pale"), C(-266.4, 80.4, 0.3, "line")], tag=[-268.0, 82.5]),
        it("climb", "The curtain's top and the pier's coping", [-1.2, 1.2],
           "La Cortina lets out at the top of its dry shaft, as today. Off the top row there are now two ways: east onto the old lip's grip (a rest "
           "under the flume, x -291 to -284.5), or 1.9 m west onto the top of the pier between the dry shaft and the falls' slot, which gets a pale "
           "stone coping (it is the mine's slick roof today). Los Barriles starts on the pier.",
           [R(-297.0, 72.7, -295.0, 73.0, "pale"), R(-291.0, 72.4, -284.5, 72.7, "pale")], tag=[-296.0, 71.9]),
        it("climb", "The lip chain", [-0.3, 0.3],
           "The crane's hoist chain, still shackled to an iron bracket under the platform's west edge: 4.4 m of real chain, its tail 1.3 m over the "
           "pier's top and 0.6 m out over the falls. It is the way up from the mine, and it is the great falls' one last chance for anyone the water "
           "takes over the lip (law 7). Barrels go past it: climb it after one has gone over.",
           [R(-297.9, 78.5, -297.3, 78.75, "pale")], tag=[-298.6, 76.4]),
        it("climb", "The west landing: the crane's platform", [-1.2, 1.2],
           "A cut stone slab on two iron beams out of the arcade's pier, 5.6 m long, top 2.2 m over the water, its west end 0.6 m out over the lip. "
           "The pale coping is the part you stand on, as everywhere in the works. The barrels pass under it with 0.65 m to spare.",
           [R(-296.4, 78.45, -296.1, 78.7, "pale"), R(-293.2, 78.45, -292.9, 78.7, "pale")], tag=[-294.6, 80.2]),
        it("climb", "The lip and the race", [-1.2, 1.2],
           "A worn stone sill at the flume's west end with white water breaking on it. Over its last 2 m the flume quickens (2.4 m a second, first "
           "guess) and is painted as white water, so a barrel leaves the lip moving and arcs out into the falls instead of sliding down the face, and "
           "anyone in the water can see where it is taking them.",
           [R(-297.4, 75.2, -297.0, 75.75, "pale"), L(-297.0, 77.12, -295.0, 77.12, "mark")], tag=[-296.0, 76.5]),
        it("climb", "The barrels", [-0.9, 0.9],
           "As today: eight, each with two iron hoops and the company's pug branded on its ends, drawn on. Same speed, same spacing, now running west. "
           "At the lip each tips over and goes down the great falls, tumbling past La Cortina into the Sump, where it sinks.",
           [R(-283.4, 77.0, -283.2, 77.95, "pale"), R(-282.4, 77.0, -282.2, 77.95, "pale")], tag=[-282.8, 76.7]),
        it("climb", "The east landing", [-1.2, 1.2],
           "The same slab on beams over the flume's head, 6.5 m long, 1.4 m east of where the barrels come into your plane, as today's west ledge "
           "was. It runs on east as the quay.",
           [R(-270.5, 78.45, -270.2, 78.7, "pale"), R(-265.3, 78.45, -265.0, 78.7, "pale")], tag=[-267.8, 80.4]),
        it("fore", "A low lip of wet rock", [1.6, 2.6],
           "Along the very bottom of the frame, below the lowest floor: a dark ragged lip of the rock the flume is cut in, with a few wet ferns. "
           "Nothing in front of the open water or the falls.",
           [P([[-305.5, 70.0], [-305.5, 70.8], [-298.0, 71.3], [-288.0, 70.9], [-276.0, 71.4], [-262.0, 71.0], [-262.0, 70.0]], "dark")], tag=[-280.0, 70.6]),
    ]
    moves = [
        ["Off La Cortina's top", "the top row's west staple, x -293.2, y 72.55", "the pier's coping, x -295.0, y 73.0", "1.9 m", "reach"],
        ["To the lip chain", "the pier's top", "the chain's tail, x -297.6, y 74.3", "1.3 m up, 0.6 m out over the falls", "reach"],
        ["Up the chain", "y 74.3", "its bracket, y 78.7", "4.4 m, about 3 to 4 s", "climb, after a barrel has gone over: one tips past the chain's top 2.5 m every 5 to 11 s"],
        ["Onto the west landing", "the chain's top", "the landing's coping, y 79.4", "0.7 m up", "reach"],
        ["Down onto a barrel", "the landing's east end, x -292.0", "a barrel's top, y 78.05", "1.35 m down", "step, as from today's east ledge"],
        ["Barrel to barrel, east", "the first barrel", "the last", "water between them 1.2, 1.6, 1.1, 4.0, 1.3, 1.7, 1.1 and 4.4 m",
         "four stretches, two lunges, two swims against 1.0 m a second: as today"],
        ["Off the last barrel", "a barrel just come into your plane, x -274.8 or west of it", "the east landing, x -271.0, y 79.4",
         "2.9 m across, 1.35 m up", "lunge or a short fling (F1): today's last move onto the west ledge, mirrored"],
        ["Fall in", "the water", "the lip, x -297", "carried 1.0 m a second, 2.4 in the last 2 m",
         "the lip chain is the last chance; past it you ride the great falls 121 m down to the Sump (a ride, never a fall card: note 147)"],
    ]
    return {
        "slug": "los_barriles", "h1": "Challenge 1.12 (working number): Los Barriles",
        "place": ("The company's barrel flume. A stone channel 32 m long under the black waters' east end, built to carry barrels west from the lock "
                  "to a crane at the head of the great falls, which swung them down to the mine. The crane broke and was never mended. The barrels "
                  "still come: they drift out of the dark tunnel at the flume's east end, float west along it, and at the lip go over into the great "
                  "falls one after another. You come up out of the mine beside that lip, climb the crane's old chain to its platform, and cross the "
                  "flume east, barrel to barrel, against them. The water runs west into the falls; fall in and it takes you over the lip and down "
                  "the falls to the Sump."),
        "before": [("What did not fit, and what changed", "<p>%s</p>" % B.esc(
            "The pitch had the mine let out along a short passage east into the new section. That cannot reach the flume's west end. La Cortina's "
            "dry shaft is 2 m east of the falls' slot (as in the mine today), so it comes up under the flume's last metres, below its water. A passage "
            "east from there runs under the flume, and every way up from below to the flume's west end crosses the flume's water or the line the "
            "barrels fall down. So the mine lets out where it always did, at the top of its dry shaft, into a low room under the flume's lip, and the "
            "way on is up the crane's chain beside the lip, between barrels. The chain is also the great falls' one last chance, as law 7 wants. If a "
            "climb timed against the barrels is wrong for the start, the other way is for the barrels to sink back into the dark at the lip instead "
            "of tipping over, which goes against note 21 and note 146: see the questions."))],
        "keep": [
            "The barrels exactly as today: eight, 0.55 m a second, the written gaps 3.0, 3.4, 2.9, 5.8, 3.1, 3.5, 2.9 and 6.2 m round a 30.8 m loop, "
            "26.8 m of it on the water, 7.3 s unseen each loop. Only their direction changes: east to west (note 146).",
            "Two of the eight gaps are swum, as today.",
            "Their birth hidden deep in a dark tunnel (note 114), and their end: they go over the lip and fall. They never vanish on screen (note 21).",
            "The current: 1.0 m a second, as today's pool, now running west.",
            "A hanging landing at each end, 2.2 m over the water, as today's two ledges; the barrels pass under the west one as they passed under the old east one.",
            "Fall in and you go over the lip, down the great falls, to the Sump.",
        ],
        "moves": moves,
        "after_moves": [("The barrels' spacing, as written today", rhythm_strip() + "<p class=\"sub\">%s</p>" % B.esc(
            "The water between each barrel and the next, round the loop. Yellow: a plain stretch (about 1.3 m of water is a stretch: the "
            "work log's measurement). Orange: a lunge. Red: a swim against the current. A barrel takes 49 s to float the flume, so from the pier "
            "you can watch several coming and pick your moment."))],
        "figures": [{"win": win, "faint": faint_today(), "bold": [(NEW_A1, PAL["a1"]), (NEW_A2, PAL["a2"]), (NEW_SEC, PAL["a2"])], "marks": marks,
                     "screen": [-285.5, 78.5], "climbers": [(-296.0, 73.0)],
                     "caption": "From the side. The dashed box is one screen of the close camera. The climber stands on the pier where Los Barriles starts; "
                                "the chain hangs beside the falls above him. Faint underneath: today's mine, whose throat and lip were here."}],
        "items": items,
        "explains": [
            ["The pier's coping", "The top of the pier between the falls' slot and the curtain's dry shaft", "The crane's platform over it, the falls beside it"],
            ["The lip chain", "The crane's hoist chain, shackled to the platform's edge", "The broken crane on the platform, its jib hanging over the falls"],
            ["The west landing", "The crane's platform", "The crane's post, the beam ends under the slab"],
            ["The barrels", "The company's barrels, coming down from the river by the bypass", "The tunnel they come out of; the falls they go over"],
            ["The water", "The flume: a stone channel that took barrels to the crane", "The arcade, and the painted vaults going back"],
            ["The east landing", "The quay's end, where the barrel men stood", "The boat hooks, the tally board, the rope"],
        ],
        "pieces": [
            ["Broken crane: post, snapped jib, pulley", "post 0.6 by 3.2 m, jib 7.5 m", "1", "Background (hero)", "new"],
            ["Arcade pier with its arch, mooring ring and course lines", "1 m wide, 5.8 m tall, 6.5 m bays", "4", "Background (set)", "new; the black waters' brick arch for the arches"],
            ["Barrel tunnel: arch, sluice gate half raised, deep black tunnel behind", "5.5 m wide, 7 m deep", "1", "Background (set)",
             "note 114's re-make of aguas_barrel_cove, moved here"],
            ["Painted vaults going back", "far card 30 m by 8 m", "1", "Backdrop", "new"],
            ["The view down the great falls", "far card 8 m wide here, 120 m tall down the mine", "1", "Backdrop", "new"],
            ["Hanging landing: cut stone slab on two beam ends", "5.6 m and 6.5 m", "2", "Play space", "kit: aguas_charco_landing_east and _west, lengthened"],
            ["Barrel", "1.8 by 1.1 m", "8", "Play space", "aguas_barrel, as today"],
            ["Chain with edge bracket and shackle", "4.4 m", "1", "Play space", "kit: the works' chain and aguas_chain_shackle"],
            ["Lip sill with white water", "0.4 m", "1", "Play space", "new, small"],
            ["Pier coping", "2 m", "1", "Play space", "kit: the works' stone coping"],
            ["Works lantern, teal", "0.3 m", "4", "Background", "kit"],
            ["Boat hook rack, tally board, rope coil", "small", "1 each", "Background", "rope coil from the kit; rack and board new"],
        ],
        "effects": ["The spill over the lip as 3D falling water (note 111), joining the great falls' sheet with spray.",
                    "The race's white water over the last 2 m.", "Mist rising out of the falls' column past the landing.",
                    "A hollow knock and a splash as each barrel tips over the lip, so you hear the rhythm too."],
        "first": ["The race: 2.4 m a second over the flume's last 2 m.", "Each barrel let loose with the race's speed, so it arcs out past the chain.",
                  "The flume's surface at y 77.2, its bed at 75.7; the lip room under it 2.2 m tall.",
                  "The lip chain: 4.4 m, at x -297.6, its tail at y 74.3.", "The landings' tops at y 79.4 (2.2 m over the water)."],
        "notes": ["Note 146: the barrels move here, running right to left (east to west), and the great falls run through.",
                  "Note 147 (settled): a fall into the great falls anywhere rides them all the way to the Sump, a ride and never a fall card.",
                  "Note 114: the barrels come out of the dark, their birth hidden: the tunnel.",
                  "Note 21 and the work log: they fall, they never vanish; the written gaps; two swims.",
                  "Note 111: the falls and the spill drawn as 3D water, the great falls at full width.",
                  "Law 7 of the mountain: the great falls' one last chance is the lip chain."],
        "ask": ["The way up from the mine is the crane's chain beside the lip, timed between barrels (a passage east cannot reach the flume's west end). "
                "Is a timed climb right for the start of the crossing? If not, the barrels could sink back into the dark at the lip instead of going over.",
                "Numbers: call the two new challenges 1.12 and 1.13 (the mine's, so nothing is renumbered), or make them the black waters' 2.1 and 2.2 "
                "and renumber El Borde onward?"],
    }


def page_lock():
    win = [-265.0, 74.0, -222.0, 92.5]
    marks = [("poly", [(LOCK[0], LOCK_LOW), (LOCK[1], LOCK_LOW), (LOCK[1], LOCK_CEIL), (DRY[1], LOCK_CEIL), (DRY[1], LOCK_HIGH), (DRY[0], LOCK_HIGH),
                       (DRY[0], LOCK_CEIL), (PIER[1], LOCK_CEIL), (PIER[1], 84.0), (PIER[0], 84.0), (PIER[0], LOCK_HIGH), (SLOT[0], LOCK_HIGH),
                       (SLOT[0], LOCK_CEIL), (LOCK[0], LOCK_CEIL)], "hiw")]
    for xx in (-243.0, -241.5, -240.0, -238.6):
        marks.append(("line", [(xx, 85.3), (xx, 78.4)], "push"))
    marks += [("text", [(-231.6, 88.9), "highest water 88.5"], "notep"), ("text", [(-249.6, 76.3), "lowest 77.2"], "notep"),
              ("text", [(-243.8, 87.3), "the river pours in"], "notep"), ("text", [(-264.6, 90.9), "the quay"], "noteo"),
              ("text", [(-231.6, 91.0), "El Borde starts here"], "note")]
    items = [
        it("backdrop", "The river's culverts, through a grating", [-16.0, -12.0],
           "High in the chamber's back wall, a barred opening onto the culverts the river runs through behind the lock: painted going back in rows, "
           "lit teal from far off, with the sound of the water. The one look out of the chamber.",
           [R(-249.4, 83.8, -246.9, 85.6, "dark"), L(-248.8, 83.8, -248.8, 85.6, "line"), L(-248.1, 83.8, -248.1, 85.6, "line"),
            L(-247.5, 83.8, -247.5, 85.6, "line")], tag=[-248.2, 86.4]),
        it("set", "The chamber's back wall", [-2.2, -1.9],
           "Cut stone in long courses, stained teal up to the highest water and green-black below the lowest, with a pale scum line painted where "
           "the water stands at the top of each fill. Rust tracks run down from the ledges' brackets. The two ends of the chamber are the lower gate "
           "(west) and plain wet rock (east).",
           [R(-250.0, 75.7, -228.0, 86.0, "solid"), L(-250.0, 80.2, -228.0, 80.2, "mark"), L(-250.0, 84.0, -228.0, 84.0, "mark")], tag=[-233.0, 79.0]),
        it("set", "The quay's back wall and the keeper's booth", [-2.6, -1.3],
           "Brick, with the keeper's booth set into it beside the lower gate: a little stone room with a round-headed opening, a lamp, a stool and a "
           "window onto the chamber. Cut away at the front, so you see in.",
           [R(-264.5, 79.4, -251.0, 86.0, "solid"), arch(-259.2, -254.0, 79.4, 81.8, "dark")], tag=[-262.0, 82.2]),
        it("set", "The slot's foot and the flap gate", [-2.0, -1.2],
           "Where the black waters' slot comes down through the roof: an iron frame round its foot and a heavy flap gate on a hinge, shut across it. "
           "When it drops, the river comes through as a white column into the chamber. When it is shut, the river slides off it into the bypass "
           "culvert's mouth at the back of the slot, which takes it down to the flume (and the barrels with it).",
           [L(-244.0, 84.0, -244.0, 86.2, "line"), L(-238.0, 84.0, -238.0, 86.2, "line"), C(-243.7, 85.7, 0.18, "pale"), R(-243.6, 86.4, -238.4, 88.0, "dark")],
           tag=[-241.0, 87.4]),
        it("things", "The frog keeper and his lever", [-1.9, -1.4],
           "The hero piece. A frog in an oilskin cap in the booth, one hand on a tall lever with a brass knob. One second before each fill he hauls "
           "it over: that is the warning, as every danger on the mountain warns before it acts. He sits in the house frogs' style, matte, and never "
           "leaves his booth.",
           [C(-256.6, 80.6, 0.42, "pale"), R(-257.0, 79.4, -256.2, 80.25, "pale"), L(-255.3, 79.4, -254.7, 81.3, "line"), C(-254.7, 81.3, 0.12, "pale")],
           tag=[-256.6, 82.4]),
        it("things", "The gate wheel", [-1.9, -1.5],
           "A big iron hand wheel on the quay's wall over the booth, its hub a pug's face. It spins as the flap gate drops and spins back as it shuts, "
           "worked by shafts in the wall: the machine you can see (rule 6).",
           [C(-252.9, 84.2, 0.8, "line"), C(-252.9, 84.2, 0.22, "pale")], tag=[-252.9, 85.6]),
        it("things", "The gauge board", [-1.7, -1.5],
           "A tall painted board on the back wall, from the floor to the dry shaft's top, marked every metre with a pug at the top, and a float on a "
           "guide that rides the water. Watching it tells you where the water is in its cycle.",
           [R(-235.6, 76.0, -234.4, 89.4, "pale"), C(-235.0, 77.5, 0.28, "light")], tag=[-235.0, 82.6]),
        it("things", "Lanterns", [-2.1, -1.9],
           "Three works lanterns, teal and steady: one in the booth, one on the chamber's west wall over L1, one on the east wall over L2.",
           [C(-257.6, 81.2, 0.15, "light"), C(-247.2, 83.4, 0.17, "light"), C(-229.0, 83.6, 0.17, "light")], tag=[-229.0, 84.6]),
        it("climb", "The wicket and its sill", [-1.2, 1.2],
           "A small iron door in the foot of the lower gate, 2.5 m tall. It is open while the water is at the bottom, and shuts with a clang when the "
           "keeper pulls his lever. Its stone sill runs into the chamber as the lowest ledge.",
           [R(-251.15, 79.4, -250.95, 81.9, "pale"), R(-251.15, 81.9, -249.9, 82.1, "pale")], tag=[-249.6, 80.4]),
        it("climb", "The lower gate", [-1.2, 1.2],
           "The chamber's west end: a riveted iron gate from the floor to the roof, black with water and slick. At the top of a fill it holds the "
           "whole chamber back from the quay; the drain's sluices are at its foot, under the quay, and let the water out into the flume's head.",
           [L(-250.5, 82.6, -250.5, 85.7, "mark"), L(-250.5, 76.0, -250.5, 78.8, "mark")], tag=[-250.5, 84.4]),
        it("climb", "The two ledges", [-1.2, 1.2],
           "Stone corbels with pale copings on iron brackets: L1 on the west wall (x -246.6 to -245.0, top 82.4), L2 on the east wall (x -229.6 to "
           "-228.0, top 81.0). Each is too high to reach from the water at the bottom: you take it as the water brings you level.",
           [L(-246.4, 81.85, -245.5, 81.0, "line"), L(-229.4, 80.45, -228.5, 79.6, "line")], tag=[-229.0, 82.0]),
        it("climb", "The rungs", [-0.3, 0.3],
           "Iron staples: two on the pier's foot (y 84.6 and 85.5) and two in the dry shaft's east wall (86.8 and 87.6). Holds to wait on near the top. "
           "The top one is 2.4 m under the lip ledge: out of reach, so only the highest water gets you out.",
           [R(-235.95, 84.3, -235.6, 85.8, "pale"), R(-232.4, 86.5, -232.0, 87.9, "pale")], tag=[-233.6, 86.6]),
        it("climb", "The top of the dry shaft", [-1.2, 1.2],
           "The old dry shaft, as today: the mine's last timber set against the works' first brick, now the top of the lock. From the water at its "
           "highest you reach the lip ledge's edge, 1.5 m up, and climb out. El Borde starts there.",
           [R(-236.25, 86.0, -235.95, 89.8, "pale"), R(-232.05, 86.0, -231.75, 89.8, "pale")], tag=[-231.0, 89.0]),
        it("fore", "The gate's front post", [1.3, 1.6],
           "One thin timber post in front of the lower gate's edge, over solid gate, so it frames the way in and covers nothing you need (the "
           "doorway exception to the foreground rule).",
           [R(-251.5, 79.4, -251.2, 86.0)], tag=[-251.35, 86.6]),
    ]
    moves = [
        ["In through the wicket", "the quay, y 79.4", "the wicket's sill, x -249.3", "level", "walk; only at the bottom of the cycle (it shuts during each fill)"],
        ["Across at the bottom", "the sill", "the east side, x -236 to -228", "up to 13 m of still water 1.5 m deep", "swim, before the fill: while it fills, the river "
         "pours down the middle (x -244 to -238) and pushes down whoever is under it"],
        ["Float up", "the water, y 77.2", "y 88.5, in the dry shaft", "11.3 m in 6 s", "ride the water. East of x -232 or west of x -244 the chamber's roof (y 86) stops you"],
        ["Rest on a ledge", "the water", "L2, east wall, y 81.0 (or L1, west wall, y 82.4)", "take it as it comes level", "reach; it keeps you up through the drain"],
        ["Wait near the top", "the water", "the pier's rungs (84.6, 85.5) or the dry shaft's (86.8, 87.6)", "", "reach, then hold"],
        ["Out", "the water at its highest, y 88.5, in the dry shaft", "the lip ledge's edge, x -232, y 90", "1.5 m up", "reach, in the %.1f s the water is high enough "
         "(over 87.9); from the top rung it is 2.4 m, out of reach" % reach_window()],
        ["Miss it", "the top", "y 77.2", "down 11.3 m in 5 s", "the drain takes down everyone not on a ledge or a rung; wait %.0f s for the next fill" % CYCLE],
    ]
    return {
        "slug": "la_esclusa_the_lock", "h1": "Challenge 1.13 (working number): La Esclusa, the lock",
        "place": ("The lock that let the barrels down from the river to the flume. It is a stone chamber 22 m long and 13 m deep under the end of the "
                  "black waters' river, where the river used to pour into the mine. The black waters' slot still brings it down, now onto a flap gate "
                  "at the chamber's top. The old frog keeper still works it from his booth on the quay: he hauls his lever, the flap drops, the river "
                  "comes through as a white column, and the chamber fills 11 m in six seconds. Then it holds, the sluices in the lower gate open, and "
                  "it drains away. You go in through the wicket at the bottom, cross while it is low, ride the water up, and at the very top of a fill "
                  "reach out of the old dry shaft onto the lip ledge where El Borde starts."),
        "keep": ["El Borde exactly as today: its lip ledge (x -232 to -226, y 90), the slot, the pier with its peaked top, the dry shaft, the river, its "
                 "one chain.", "The way into El Borde is still up the old dry shaft onto the lip ledge, as from the mine today."],
        "moves": moves,
        "after_moves": [("The cycle", cycle_chart() + "<p>%s</p>" % B.esc(
            "The pitch's cycle is 14 s: 6 s rising, 3 s held, 5 s draining. That leaves no time at the bottom, so the wicket would never be open and "
            "nobody could cross before the fill. I added 4 s at the bottom (first guess), so the cycle is 18 s. The keeper hauls his lever 1 s before "
            "each fill. The lip ledge is in reach for %.1f s of each cycle: the last moment of the rise and the 3 s hold." % reach_window()))],
        "figures": [{"win": win, "faint": faint_today(), "bold": [(NEW_A2, PAL["a2"]), (NEW_SEC, PAL["a2"])], "marks": marks,
                     "screen": [-240.0, 82.5], "climbers": [(-249.4, 79.4)],
                     "caption": "From the side. Water at its lowest, drawn solid; its highest, dashed blue. The dotted column under the slot is where the river "
                                "pours in while it fills. The climber stands on the wicket's sill. Faint underneath: today's mine, whose throat was here."}],
        "items": items,
        "explains": [
            ["The wicket's sill", "The lock-keeper's door through the lower gate", "The booth beside it, the gate's riveted face"],
            ["The water that lifts you", "The lock filling from the river", "The flap gate and the white column under the slot; the gauge board"],
            ["L1 and L2", "Corbels the keepers stood on to work the chamber", "Their brackets and rust tracks on the back wall"],
            ["The rungs", "The keepers' iron staples up the pier and the dry shaft", "The pier's foot, the dry shaft's timber set"],
            ["The lip ledge", "El Borde's lip ledge, as today", "The brick tunnel of the river above"],
        ],
        "pieces": [
            ["Frog keeper in an oilskin cap, at a lever", "frog 0.8 m; lever 1.9 m", "1", "Background (hero)", "new pose in the house frogs' style"],
            ["Keeper's booth: recess, lamp, stool, window", "4.6 m wide, 2.4 m tall", "1", "Background (set)", "new"],
            ["Gate wheel with a pug hub", "1.6 m across", "1", "Background (turns)", "new"],
            ["Gauge board with float", "1.2 by 13.4 m", "1", "Background", "new"],
            ["Lower gate: riveted iron leaf with a wicket door and foot sluices", "1 by 10.3 m", "1", "Play space (slick)", "new; the wicket shuts and opens"],
            ["Flap gate in an iron frame", "6 m", "1", "Play space (moves)", "new"],
            ["Corbel ledge with coping and bracket", "1.4 to 1.6 m", "2", "Play space", "kit: the works' coping on a new bracket"],
            ["Iron staple", "0.5 m", "4", "Play space", "kit: iron_staple"],
            ["Chamber back wall with water-line bands", "22 by 10.3 m", "1", "Background (set)", "new, painted"],
            ["Barred opening onto the culverts, painted behind", "2.5 by 1.8 m", "1", "Backdrop", "new"],
            ["Works lantern, teal", "0.3 m", "3", "Background", "kit"],
        ],
        "effects": ["The white column of the river through the slot while it fills, foam where it hits, spray.", "Bubbles and a swirl as the sluices drain it.",
                    "The clang of the wicket and the flap, the wheel's rattle.", "Drips from the roof all the time (every rest has its unease)."],
        "first": ["Low 77.2, high 88.5; 6 s up, 3 s held, 5 s down, and the added 4 s at the bottom.", "The keeper's warning 1 s before each fill.",
                  "The inflow's push while it fills: 4 m a second each second downward under the slot.",
                  "The two ledges' places and heights, the four rungs.", "The chamber: x -250 to -228, floor 75.7, roof 86."],
        "notes": ["Note 146: at least one more challenge in the new section; the lock, as pitched and liked.",
                  "Rule 6 and rule 7 of the mountain: the gate wheel and the flap show the machine; the keeper's lever warns before each fill."],
        "ask": ["The pitched 14 s cycle has no pause at the bottom, so I added 4 s (18 s in all) for the wicket and the crossing. All right?",
                "The river pours in across the middle of the chamber (the slot is fixed by El Borde), so you cross while it is low. Keep that?",
                "A fall from El Borde used to go down the slot into the mine and on to the Sump. Now it lands in this lock: a much gentler fall. Keep that, "
                "or send it on down?"],
    }


def page_place():
    win = [-306.5, 69.5, -222.0, 92.5]
    marks = falls_marks(69.5, 92.5) + [
        ("poly", [(DRY[0], LOCK_CEIL), (DRY[1], LOCK_CEIL), (DRY[1], LOCK_HIGH), (DRY[0], LOCK_HIGH)], "hiw"),
        ("poly", [(LOCK[0], LOCK_LOW), (LOCK[1], LOCK_LOW), (LOCK[1], LOCK_CEIL), (LOCK[0], LOCK_CEIL)], "hiw"),
        ("poly", [(x, y) for x, y in list(section_shell().exterior.coords)[:-1]], "newl"),
        ("text", [(-305.9, 91.6), "the great falls"], "notep"), ("text", [(-291.0, 81.6), "Los Barriles"], "note"),
        ("text", [(-262.8, 84.8), "the quay"], "noteo"), ("text", [(-247.6, 77.9), "La Esclusa"], "note"),
        ("text", [(-229.5, 91.6), "El Borde"], "note"), ("text", [(-305.9, 70.3), "the mine's roof"], "noteo"),
        ("text", [(-288.0, 91.3), "the black waters' lower river"], "notep")]
    items = [
        it("backdrop", "The view down the great falls", [-16.0, -12.0],
           "Behind the falls' column: one tall painted card of the whole drop, from the black waters' floor down past the mine to the Sump's mist, "
           "the mine's lanterns warm and tiny far below.",
           [R(-306.3, 69.7, -297.3, 82.8, "dark"), L(-304.5, 82.6, -304.5, 70.0, "mark"), L(-301.6, 82.6, -301.6, 70.0, "mark")], tag=[-305.2, 76.0]),
        it("backdrop", "The vaults going back", [-16.0, -12.0],
           "Through the flume's arcade: rows of brick vaults going back into the dark with the water running away under them.",
           [arch(-291.2, -287.6, 77.2, 79.6, "line"), arch(-284.7, -281.1, 77.2, 79.6, "line"), arch(-278.2, -275.8, 77.2, 79.0, "line")], tag=[-283.0, 80.4]),
        it("backdrop", "The river's culverts", [-16.0, -12.0],
           "Through a barred opening high in the lock's back wall: the culverts behind the lock, painted going back, lit teal far off.",
           [R(-249.4, 83.8, -246.9, 85.6, "dark")], tag=[-248.2, 84.7]),
        it("set", "The flume's arcade and its cracked vault", [-2.6, -2.2],
           "Brick piers every 6.5 m with round arches, mooring rings at the waterline, a cracked brick vault overhead.",
           [R(-293.5, 77.2, -292.5, 83.0, "pale"), R(-287.0, 77.2, -286.0, 83.0, "pale"), R(-280.5, 77.2, -279.5, 83.0, "pale"), R(-266.4, 77.2, -265.4, 83.0, "pale")],
           tag=[-279.9, 81.8]),
        it("set", "The barrels' tunnel", [-7.0, -1.3], "A brick arch at the waterline, a sluice gate half raised, black inside: where the barrels come from.",
           [arch(-275.5, -270.0, 75.7, 78.8, "dark")], tag=[-272.7, 77.9]),
        it("set", "The quay's wall and the keeper's booth", [-2.6, -1.3], "Brick, with the lock-keeper's booth set into it beside the lower gate.",
           [R(-264.5, 79.4, -251.0, 86.0, "solid"), arch(-259.2, -254.0, 79.4, 81.8, "dark")], tag=[-261.6, 82.5]),
        it("set", "The lock chamber's wall", [-2.2, -1.9], "Cut stone stained teal to the highest water, the scum line painted at the top.",
           [R(-250.0, 75.7, -228.0, 86.0, "solid")], tag=[-232.0, 80.0]),
        it("things", "The broken crane", [-3.4, -2.4], "Los Barriles' hero: the barrel crane at the head of the falls, its jib snapped over the drop.",
           [R(-296.1, 79.4, -295.5, 82.6, "pale"), P([[-295.8, 82.4], [-302.6, 79.7], [-302.7, 80.05], [-295.8, 82.8]], "pale")], tag=[-299.6, 81.7]),
        it("things", "The frog keeper at his lever", [-1.9, -1.4], "La Esclusa's hero: the old keeper in his booth, who hauls the lever before every fill.",
           [C(-256.6, 80.6, 0.42, "pale"), R(-257.0, 79.4, -256.2, 80.25, "pale"), L(-255.3, 79.4, -254.7, 81.3, "line")], tag=[-256.6, 82.5]),
        it("things", "The gate wheel and the gauge board", [-1.9, -1.5], "The machine you can see: the wheel spins as the flap drops; the board's float rides the water.",
           [C(-252.9, 84.2, 0.8, "line"), R(-235.6, 76.0, -234.4, 89.4, "pale")], tag=[-252.9, 85.6]),
        it("climb", "The crane's chain and platform", [-1.2, 1.2], "From the pier's top up the chain beside the lip, onto the crane's platform: the start of the crossing.",
           [R(-297.0, 72.7, -295.0, 73.0, "pale"), R(-297.9, 78.5, -297.3, 78.75, "pale")], tag=[-298.4, 75.8]),
        it("climb", "The barrels and the east landing", [-0.9, 0.9], "Barrel to barrel east against the current, onto the landing over the flume's head.",
           [R(-283.4, 77.0, -283.2, 77.95, "pale")], tag=[-283.3, 76.4]),
        it("climb", "The wicket, the ledges, the rungs, the lip ledge", [-1.2, 1.2], "Into the lock at the bottom, up with the water, out onto El Borde's lip ledge at the top of a fill.",
           [R(-251.15, 79.4, -250.95, 81.9, "pale"), L(-246.4, 81.85, -245.5, 81.0, "line"), L(-229.4, 80.45, -228.5, 79.6, "line")], tag=[-244.0, 80.6]),
        it("fore", "A low lip of wet rock", [1.6, 2.6], "Along the bottom of the frame only, below the lowest floor.",
           [P([[-306.5, 69.5], [-306.5, 70.4], [-288.0, 70.9], [-262.0, 70.6], [-240.0, 71.0], [-222.0, 70.5], [-222.0, 69.5]], "dark")], tag=[-262.0, 70.2]),
    ]
    fits = [["y 69 to 73", "the mine's roof slab (moved 17 m down): the falls' slot and La Cortina's dry shaft go through it"],
            ["y 73.0", "the lip room's floor: the pier's top and the old lip, where La Cortina lets out"],
            ["y 73.0 to 75.2", "the lip room, 2.2 m tall, under the flume's last metres"],
            ["y 75.2 to 75.7", "the flume's stone bed"], ["y 75.7 to 77.2", "the flume's water, 1.5 m deep"],
            ["y 77.2 to 78.05", "the barrels, as today 0.3 m over the surface"], ["y 79.4", "the two landings and the quay"],
            ["y 83 (west of x -292) and 86 (east)", "the new section's roof: the black waters' rock starts here, as today"],
            ["y 75.7 to 86, and up the dry shaft to 88.5", "the lock's chamber and its water at the highest"],
            ["y 90", "El Borde's lip ledge, as today; the black waters' lower river runs from y 90 to 91 over the new section's west part"]]
    route = ["La Cortina, as today, up its dry shaft to the top of the mine.", "Off the top row west onto the pier's coping (1.9 m).",
             "Up the crane's chain beside the lip, after a barrel has gone over, onto the crane's platform (Los Barriles starts).",
             "East along the flume, barrel to barrel, against the current and the barrels coming at you, onto the east landing.",
             "East along the quay past the keeper's booth (a rest, 13.5 m).", "In through the lock's wicket at the bottom of its cycle (La Esclusa starts).",
             "Cross while it is low, float up as it fills, take a ledge or a rung, and at the top of a fill reach out of the dry shaft onto the lip ledge.",
             "El Borde (2.1), exactly as today."]
    water = ("The black waters' lower river still runs east along its tunnel to the slot at x -244 and pours down it, as today. It no longer falls "
             "into the mine: it falls onto the lock's flap gate. When the flap drops, the river fills the lock. When it is shut, the river slides "
             "off it into a bypass culvert behind the quay, which brings it down to the flume's head, and it comes out of the barrels' tunnel with the "
             "barrels. The lock drains through sluices in its lower gate into the flume's head too. The flume runs west and goes over its lip into "
             "the great falls, which come down from the well, through the Charco (2.7) and a shaft through the black waters' floor, past the lip, "
             "into the mine's throat and on to the Sump. All of the new section's water ends in the great falls.")
    changed = ["The mine drops 17 m as well as moving 59 m west (as Parker's drawing shows). Moved only west, its throat's roof would sit in the black "
               "waters' rock (110 square metres of overlap) and there would be no room for a flume and a 12 m lock between its top and El Borde. "
               "With the drop there are 17 m, which fit the lock exactly.",
               "No passage east from the mine's top: it comes out under the flume and cannot reach the flume's west end. The mine lets out beside the "
               "lip instead and you climb the crane's chain (see Los Barriles).",
               "The lock is under the black waters' slot and the old dry shaft, because those are where El Borde's water and its lip ledge are. That "
               "puts it 27 m east of the flume's head, so a short quay joins them.",
               "The lock's cycle gets a 4 s pause at the bottom (18 s in all), for the wicket and the crossing.",
               "The strip of rock from x -252 to -223 between y 86 and 89.4, which was the mine's roof, is now the new section's (the lock's roof and "
               "the support under the lip ledge)."]
    return {
        "slug": "la_esclusa_the_place", "h1": "La Esclusa: the new section under the black waters",
        "place": ("The company's lower works, between the mine and the black waters. When the mine was worked, barrels came down the black waters' "
                  "river, down a lock 12 m deep at its end, and along a stone flume 32 m long to a crane at the head of the great falls, which swung "
                  "them down into the mine. The crane broke, the mine was abandoned, and nobody turned the water off. The great falls pour down "
                  "through the west end. The barrels still drift out of the dark and float to the lip and over it, one after another. An old frog "
                  "still keeps the lock, hauling his lever and filling and emptying the chamber every eighteen seconds for nobody. It is cut stone, "
                  "brick vaults and riveted iron, the black waters' teal light and their dark water, and the roar of the falls at one end."),
        "before": [("How it fits, from the bottom up", tbl(["Height", "What is there"], fits)),
                   ("The route through it", "<ol>%s</ol>" % "".join("<li>%s</li>" % B.esc(x) for x in route)),
                   ("Where the water comes from and goes", "<p>%s</p>" % B.esc(water)),
                   ("What did not fit, and what changed", ul(changed))],
        "keep": ["La Cortina and every challenge of the mine exactly as today (moved); El Borde and every challenge of the black waters exactly as today.",
                 "The barrels' speed, spacing, count and hidden birth exactly as today; only their direction changes (note 146).",
                 "The great falls in one line, the well's middle, x -300, from under the forge to the Sump (notes 142, 143, 146)."],
        "figures": [{"win": win, "faint": faint_today(), "bold": [(NEW_A1, PAL["a1"]), (NEW_A2, PAL["a2"]), (NEW_SEC, PAL["a2"])], "marks": marks,
                     "climbers": [(-296.0, 73.0), (-249.4, 79.4)], "maxw": 900.0,
                     "caption": "The whole new section from the side, x -306.5 to -222, to scale. Yellow dashes: its outline. Faint underneath: today's mine, whose "
                                "throat was here. Each challenge has its own page with a closer sketch."}],
        "items": items,
        "explains": [["The pier's top and the chain", "The foot of the crane's platform at the head of the falls", "The crane, broken; the falls"],
                     ["The barrels and the landings", "The flume and its two landing stages", "The arcade, the tunnel, the vaults going back"],
                     ["The quay", "Where the barrel men worked", "The booth, the gate wheel, the boat hooks"],
                     ["The lock", "The lock that let barrels down from the river", "The flap gate, the gauge board, the culverts through the grating"]],
        "pieces": [["See Los Barriles and La Esclusa for each piece", "", "", "", ""]],
        "first": ["Every height in the table above except the mine's roof (which follows from the drop) and El Borde's (as today).",
                  "The flume's length (32 m of water, 26.8 m of it the barrels' road, as today) and the quay's (13.5 m)."],
        "notes": ["Note 146, the brief: the mine moved under the falls, the longer ride, the barrels moved here running east to west, one more challenge, the old pool a jump.",
                  "Notes 142 and 143: the great falls all the way down; the frogs' slide pours into them.",
                  "Note 111: the falls drawn as 3D water.", "Note 114: the barrels' hidden birth.",
                  "docs/peak/QUALITY_TO_9_PLAN.md: the four layers in every frame; one hero per challenge (the crane, the keeper)."],
        "ask": ["Is the story right: the company's lower works, a broken crane at the head of the falls, an old frog still keeping the lock?",
                "The two challenges are numbered 1.12 and 1.13 here for now. Keep them as the mine's, or make them the black waters' first two and renumber?"],
    }


def page_salto():
    win = [-323.5, 108.0, -281.5, 131.0]
    marks = falls_marks(108.0, 131.0) + [("text", [(-302.8, 108.7), "on down 160 m to the Sump"], "notep"),
                                         ("text", [(-322.8, 130.0), "the hall, as today"], "noteo")]
    items = [
        it("backdrop", "The view down through the floor", [-16.0, -12.0],
           "Under the hall's broken floor: a painted card of the falls dropping away into the dark, mist rising, and far below the warm dots of the "
           "mine's lanterns. What a miss costs, shown before you jump (law 5).",
           [R(-303.0, 108.3, -297.0, 113.0, "dark"), L(-301.5, 112.8, -301.5, 108.5, "mark"), L(-298.6, 112.8, -298.6, 108.5, "mark")], tag=[-300.0, 110.0]),
        it("backdrop", "The look up the well", [-8.0, -2.0],
           "As today: five rings of black rock cut out of card, each smaller, further back and higher, and the dot of daylight at the top. Now the "
           "great falls come down out of it, pale against the rings.",
           [C(-300.0, 122.0, 6.0, "line"), C(-300.0, 123.2, 4.2, "line"), C(-300.0, 124.2, 2.8, "line"), C(-300.0, 125.5, 0.9, "line")], tag=[-300.0, 126.9]),
        it("set", "The hall's two brick flanks", [-6.5, -5.5],
           "As today: brick, 15 m tall, west and east of the well, each ending in a brick pier against the rock, with the bricked-up arch in the east one.",
           [R(-320.5, 113.0, -306.5, 128.0), R(-293.5, 113.0, -284.0, 128.0), R(-307.1, 113.0, -306.5, 128.0, "pale"), R(-293.5, 113.0, -292.9, 128.0, "pale")],
           tag=[-316.0, 126.0]),
        it("set", "The broken floor", [-6.0, -1.3],
           "Where the falls hit, the reservoir's floor has broken through: a 6 m hole with the brick lining hanging in ragged edges over the drop, the "
           "pool's west half pouring over a worn sill into it and the east basin's edge cracked. The falls go through, down a shaft cut in the black "
           "waters' floor, to the new section and the mine.",
           [P([[-303.6, 113.0], [-303.0, 112.0], [-303.5, 110.6], [-303.0, 109.4]], "line"), P([[-296.4, 113.0], [-297.0, 111.8], [-296.6, 110.2], [-297.0, 109.0]], "line")],
           tag=[-304.6, 111.2]),
        it("set", "The gantry", [-1.8, -1.4],
           "An iron beam across the pool's west half, 2.6 m behind you, hung from the roof on two flat iron straps: what the barrel store's men slung "
           "their hoists from. Its two chains hang forward into your plane.",
           [R(-315.6, 121.65, -305.6, 121.95, "pale"), R(-314.15, 121.95, -313.85, 128.0, "pale"), R(-307.35, 121.95, -307.05, 128.0, "pale")], tag=[-311.0, 122.8]),
        it("set", "The davit", [-1.5, -1.3],
           "An iron davit on Q6's west end, its arm out over the falls' edge: where the barrel men stood to hook barrels off the old lip. Its chain is "
           "the launch.",
           [R(-296.35, 117.4, -296.05, 122.0, "pale"), R(-297.15, 121.75, -296.05, 122.0, "pale")], tag=[-295.4, 120.6]),
        it("things", "The great falls", [-1.2, 1.2],
           "The hero piece: the falls themselves, drawn as 3D water at full width (note 111), coming out of the well and through the hall and its "
           "floor, spray and mist filling the gap you leap. They do not push you sideways here (first guess): the leap decides. Whoever goes into "
           "them rides them all the way down to the Sump (note 147, settled).",
           [L(-303.0, 128.0, -303.0, 113.0, "line"), L(-297.0, 128.0, -297.0, 113.0, "line")], tag=[-300.0, 118.4]),
        it("things", "The lantern on the far bank", [-1.6, -1.3],
           "A works lantern on a short post at Q7's east end, the brightest thing on the far side: the light to aim at.",
           [R(-315.55, 117.2, -315.25, 119.6, "pale"), C(-315.4, 119.85, 0.2, "light")], tag=[-316.6, 120.4]),
        it("things", "What has fallen", [-5.0, -3.4],
           "As today, moved to a shelf at the back of the pool's west half: a broken crystal point, a rotted mushroom cap, a carved pug block, a coil "
           "of rope. One thing from each place above where the well is crossed.",
           [P([[-319.0, 115.0], [-318.4, 115.5], [-309.0, 115.6], [-308.4, 115.0]], "solid"), R(-316.0, 115.6, -315.0, 116.4)], tag=[-312.0, 116.1]),
        it("climb", "Q6, longer", [-1.2, 1.2],
           "Today's east ledge, carried on 5.6 m west to the falls' edge (x -296.6) on more iron beams out of the east flank. Its west end is the "
           "launch. Under it, the east basin still runs to the old cascade and the lower river.",
           [R(-295.8, 116.45, -295.5, 116.7, "pale"), R(-291.0, 116.45, -290.7, 116.7, "pale"), R(-286.0, 116.45, -285.7, 116.7, "pale")], tag=[-293.0, 118.3]),
        it("climb", "The davit's chain", [-0.3, 0.3],
           "2.2 m of chain from the davit's arm, its tail at y 119.4: take it from Q6, swing, and let go west over the falls.",
           [R(-297.15, 121.45, -296.65, 121.65, "pale")], tag=[-297.9, 120.4]),
        it("climb", "The pool's lip", [-1.2, 1.2],
           "A worn stone sill where the pool's west half pours over into the falls, white water breaking on it. The current quickens to 1.6 m a "
           "second over its last 2 m.",
           [R(-303.4, 114.7, -303.0, 115.0, "pale"), L(-305.0, 114.95, -303.0, 114.95, "mark")], tag=[-304.4, 114.2]),
        it("climb", "C1 and C2", [-0.3, 0.3],
           "Two chains from the gantry, their tails 0.6 m over the water: C1 at x -306.8, 3.8 m from the lip (the first grab after the leap, and "
           "the last chance for anyone the current takes back toward the falls: law 7); C2 at x -310.6.",
           [R(-307.05, 121.6, -306.55, 121.8, "pale"), R(-310.85, 121.6, -310.35, 121.8, "pale")], tag=[-308.7, 118.0]),
        it("climb", "Q7's ladder", [-1.2, 1.2],
           "Two iron rungs down Q7's east end into the water: the way out, as every way out of moving water in the works is a chain or a ladder.",
           [L(-314.45, 115.2, -314.45, 117.2, "line"), L(-313.95, 115.2, -313.95, 117.2, "line")], tag=[-313.2, 116.0]),
    ]
    moves = [
        ["Down to Q6", "2.6's gallery, y 121.0", "Q6, y 117.4", "3.6 m down", "as today"],
        ["To the launch", "x -287", "Q6's new west end, x -296.6", "9.6 m", "walk"],
        ["The leap", "the davit's chain, x -296.9, tail y 119.4", "the pool beyond the falls, x -303.6 to -306", "6.7 to 9.1 m across, 4.4 m down",
         "F2 fling: swing on the chain and let go. The falls are 6 m across."],
        ["Swim at once", "where you land", "C1, x -306.8, its tail 0.6 m over the water", "0 to 3 m, against 1.0 m a second (1.6 near the lip)",
         "swim; miss C1 and the current takes you back over the lip"],
        ["C1 to C2", "x -306.8", "x -310.6", "3.8 m against 1.0 m a second", "swim, like today's two swims (4.0 and 4.4 m)"],
        ["C2 to Q7", "x -310.6", "Q7's ladder, x -314.2", "3.6 m", "swim, up two rungs onto Q7 (y 117.2); 2.8 starts at its west end, as today"],
        ["Miss", "the falls", "the Sump, y -45", "160 m, about 11 s", "a ride down the great falls (note 147), through the new section, past the flume's lip and La Cortina"],
    ]
    return {
        "slug": "2_7_el_salto_de_la_cascada", "h1": "Challenge 2.7: El Salto de la Cascada (was El Charco del Pozo)",
        "place": ("The foot of El Pozo del Diablo, the brick hall round the old reservoir, as today: but the great falls now come down the well and "
                  "straight through the hall. Where they hit, the reservoir's floor has broken, and they pour on down through the hole. The pool "
                  "is cut in two. Its west half, fed by the flume from 2.8, runs east and pours over a sill into the falls. Its east half is a basin "
                  "under the ledge you start from. From the ledge's west end you swing out on the barrel men's old davit chain and let go, over "
                  "the falling water, into the west half, and the moment you land you have to swim, because it is taking you back to the falls. "
                  "Behind the spray, the well goes up out of sight; under you, the falls go down out of sight."),
        "keep": ["The start on Q6 (the east ledge), the frog's door at its east end, and the step down from 2.6's gallery.",
                 "Q7 (the west ledge) and 2.8's start beyond it; the flume from 2.8 spilling into the pool's west end.",
                 "The well's mouth in the roof, x -306 to -294, and the camera's lean upward.",
                 "The pool's current, 1.0 m a second, and two swims of about 4 m against it.",
                 "The old cascade and the black waters' lower river, now fed from the east basin.",
                 "A miss costs what it cost before: down to the Sump (today by the lip, the cascade, the river and the mine; now by the falls)."],
        "moves": moves,
        "figures": [{"win": win, "faint": faint_today("a2"), "bold": [(NEW_A2, PAL["a2"]), (NEW_CHARCO, PAL["a2"])], "marks": marks,
                     "screen": [-302.5, 119.0], "climbers": [(-295.8, 117.4)],
                     "caption": "From the side. The climber is at Q6's new west end, under the davit. Faint underneath: today's pool and barrels."}],
        "items": items,
        "explains": [["Q6", "The barrel men's landing over the old lip", "The davit; the beam ends under it"],
                     ["The davit's chain", "The chain off the davit's arm", "The davit on Q6's end"],
                     ["The pool", "The reservoir's west half, running into the falls", "The broken floor, the falls, the view down"],
                     ["C1 and C2", "The store's hoist chains", "The gantry beam and its straps"],
                     ["Q7 and its rungs", "The barrel store's landing", "The lantern on its post"]],
        "pieces": [["The great falls, 3D, through the hall", "6 m wide, 15 m tall here", "1", "Play space (hero)", "the 3D falling water of note 111"],
                   ["Broken floor edges with hanging brick lining", "6 m hole", "1", "Background (set)", "new"],
                   ["The view down through the floor", "far card", "1", "Backdrop", "part of the great falls' card"],
                   ["Davit with its chain", "post 4.6 m, arm 1.1 m, chain 2.2 m", "1", "Background and play", "new davit; kit chain and shackle"],
                   ["Gantry beam with two straps and two chains", "10 m beam, chains 6.2 m", "1", "Background and play", "new beam; kit chains"],
                   ["Q6, lengthened", "12.6 m", "1", "Play space", "kit: aguas_charco_landing_east, lengthened"],
                   ["Pool sill with white water", "0.4 m", "1", "Play space", "new, small"],
                   ["Q7's ladder", "two rungs", "1", "Play space", "kit: iron rungs"],
                   ["Lantern on a post", "2.6 m", "1", "Background", "kit lantern, new post"]],
        "effects": ["Spray and mist in the gap, thickest at the pool's height, so the leap is through cloud with the far lantern showing.",
                    "The roar of the falls, loudest here.", "White water on the pool's sill and where the falls hit the broken floor."],
        "first": ["No push from the falls in the hall; going into them is the ride (note 147). The mine's falls keep their push.",
                  "The pool's current 1.0, quickening to 1.6 m a second over its last 2 m.",
                  "The davit chain's place and length; C1 and C2's places.", "Q6 lengthened to x -296.6."],
        "notes": ["Note 146: a big jump to a pool on the other side that feeds the falls, so you swim the moment you land.",
                  "Note 142: the great falls from the top of the well to the black waters; now on through.", "Note 111: 3D falling water.",
                  "Note 147 (settled): a fall into the great falls anywhere rides them all the way to the Sump.",
                  "Note 143: riders of the frogs' slide come down the falls through here, on to the Sump.",
                  "Note 114 and the barrels: they leave 2.7 for Los Barriles."],
        "ask": ["Note 147 settles that a fall into the great falls rides them to the Sump. The well is 12 m wide and the falls 6 m, so a fall down the "
                "well beside the falls lands in this pool's west half (and must swim, or is taken over its lip) or in the east basin (and goes by the "
                "old cascade and El Borde's river into the lock). Keep that, or should the whole width of the well ride down?",
                "The jump is a fling from a chain at the ledge's end, because the climber cannot run and jump 6 m. All right?"],
    }


def page_ride():
    win = [-215.0, -34.5, -128.0, -1.0]
    marks = [("text", [(-150.3, -15.6), "today's buffer"], "noteo"), ("text", [(-174.0, -14.0), "the incline, 20 degrees"], "note"),
             ("text", [(-214.6, -33.6), "the mine's door, moved"], "notep"), ("line", [(-150.3, -15.0), (-150.3, -12.1)], "oldl")]
    sets = [x for x in [-138.6 - 2.6 * k for k in range(28)] if x > -209.0 and not (-158.5 < x < -150.0)]
    items = [
        it("backdrop", "Side galleries going back", [-14.0, -10.0],
           "Two openings in the back wall at the incline's head and foot, with the old side workings painted going back into the dark behind them: "
           "timber sets in rows getting smaller, a lantern speck at the far end of each. The painted tunnel receding, as the quality plan asks.",
           [arch(-146.4, -143.4, fy(-146.4), fy(-146.4) + 2.2, "dark"), arch(-198.6, -195.4, fy(-195.4), fy(-195.4) + 2.2, "dark"),
            C(-144.9, fy(-144.9) + 1.4, 0.09, "light"), C(-197.0, fy(-197.0) + 1.4, 0.09, "light")], tag=[-197.0, fy(-197.0) + 3.6]),
        it("set", "The back wall", [-2.0, -1.7],
           "Plank lining on rock, as today's tunnel: grey and wet, planks missing, smashed in the last 16 m, the same back wall the mine's galleries have.",
           [P([(x, y) for x, y in FLOOR_NEW if x <= -136.0] + [(x, y + 5.0) for x, y in reversed(FLOOR_NEW) if x <= -136.0])], tag=[-140.0, -8.5]),
        it("set", "The timber sets", [-1.7, -1.3],
           "One every 2.6 m, as in today's tunnel, grey and rotten, standing plumb on the incline so their caps step down it. One cap cracked and propped.",
           [R(x - 0.15, fy(x), x + 0.15, fy(x) + 4.6, "pale") for x in sets], tag=[-177.0, fy(-177.0) + 4.0]),
        it("things", "The winding house", [-3.6, -2.2],
           "The hero piece. At the incline's head, a chamber cut into the rock over and behind the track: a big iron winding drum 2.6 m across on a "
           "timber frame, its brake band and long brake lever, a seat for the brakeman, and the haulage rope's snapped end hanging off the drum. "
           "Carts used to be let down the incline on that rope. Now they free-run, and you are in one.",
           [R(-158.5, -12.6, -149.6, -4.4, "dark"), C(-154.0, -7.6, 1.3, "line"), C(-154.0, -7.6, 0.3, "pale"),
            P([[-156.6, -12.4], [-154.0, -7.6], [-151.4, -12.4]], "line"), L(-151.8, -11.9, -150.9, -9.4, "line")], tag=[-154.0, -5.2], over=True),
        it("things", "The haulage rope, lying", [-0.4, 0.4],
           "The rope that ran down the incline, snapped, lying along the sleepers between the rails all the way down. Lying, never hanging (rule 4).",
           [L(-158.0, fy(-158.0) + 0.12, -186.0, fy(-186.0) + 0.12, "mark")], tag=[-172.0, fy(-172.0) - 0.8]),
        it("things", "The runaway catch", [-1.0, -0.8],
           "An iron catch hinged beside the far rail near the top, meant to throw a runaway cart off the track. It is sprung open and rusted that way. "
           "A warning board on the back wall above it: the mine's skull-pug diamond.",
           [R(-163.6, fy(-163.6), -162.6, fy(-163.6) + 0.5, "pale"), P([[-161.8, fy(-161.8) + 2.6], [-161.3, fy(-161.8) + 3.1], [-160.8, fy(-161.8) + 2.6],
                                                                        [-161.3, fy(-161.8) + 2.1]], "pale")], tag=[-161.3, fy(-161.3) + 3.8]),
        it("things", "The ore bins", [-3.0, -1.8],
           "At the incline's foot, timber ore bins built against the back wall with their chutes over the track, where carts were loaded on the way "
           "up. One chute's door hangs open; a little ore has spilled on the sleepers.",
           [R(-203.2, fy(-203.2) + 1.6, -198.8, fy(-203.2) + 4.0, "pale"), P([[-202.6, fy(-202.6) + 1.6], [-201.4, fy(-202.6) + 0.9], [-201.0, fy(-202.6) + 1.6]], "pale")],
           tag=[-201.0, fy(-201.0) + 3.0]),
        it("things", "The end of the line", [-1.75, -1.3],
           "Today's end of the line, moved with it: the board of miners' pegs with one hat and a dead lamp, the trough's end, the buffer's two braces "
           "raking back to the floor.",
           [R(-205.9, -24.5, -204.3, -24.1, "pale"), L(-209.5, -28.25, -210.6, -29.0, "line"), L(-209.5, -28.6, -210.2, -29.0, "line")], tag=[-205.1, -23.4]),
        it("climb", "The rail bed and the rails", [-1.2, 1.2],
           "The bed grips (dry, pale, matte) all the way down, the incline too: fall out of the cart anywhere and you can walk on. The kit's rails "
           "and sleepers, as today.",
           [L(x, fy(x) + 0.02, x, fy(x) + 0.22, "mark") for x in range(-160, -188, -4)], tag=[-184.0, fy(-184.0) - 0.9]),
        it("climb", "The buffer", [-1.2, 1.2], "The timber baulk across the track at the end, as today (0.6 by 0.8 m), 1.7 m short of the mine's door.",
           [R(BUFFER[0] - 0.3, BUFFER[1] - 0.4, BUFFER[0] + 0.3, BUFFER[1] + 0.4, "pale")], tag=[-209.3, -27.0]),
        it("fore", "Two broken front posts", [1.3, 1.6],
           "A front post of a set at the incline's head and one at its foot, broken off short, standing over the rock below the bed so they cover "
           "nothing you need.",
           [R(-157.9, fy(-157.9) - 3.0, -157.6, fy(-157.9) - 0.3), R(-191.6, fy(-191.6) - 3.0, -191.3, fy(-191.6) - 0.3)], tag=[-191.4, fy(-191.4) - 1.6]),
    ]
    stretch = [["The run-in", "x -136 to -152", "Today's end of the line, passed now: the lining smashed, the old door's timber set left standing as a set. "
                "The pegs, the trough's end and the buffer move on to the new end."],
               ["The incline's head", "x -152 to -158", "The winding house over the track, the warning board, the runaway catch: the track goes over the brow."],
               ["The incline", "x -158 to -188", "20 degrees down, 32 m of track; sets every 2.6 m stepping down; the snapped rope along the sleepers."],
               ["The incline's foot", "x -188 to -200", "It eases out; the ore bins and their chutes; a side gallery painted going back."],
               ["The end of the line", "x -200 to -211", "Level for its last 7 m; the buffer, the pegs, the trough's end; the door into the mine, moved."]]
    return {
        "slug": "0_3_the_longer_ride", "h1": "Challenge 0.3: El Descenso, the longer ride",
        "place": ("The cart ride goes on past where it stops today. The tunnel runs on 59 m further west and drops 17 m more to meet the mine at its "
                  "new place. The extra length is the old haulage incline: a straight run down at 20 degrees, the steepest of the ride and the last, "
                  "with the winding house at its head that used to let the carts down on a rope. The rope is snapped and lying on the sleepers, the "
                  "runaway catch is rusted open, and the cart goes over the brow and down it on its own. At the foot are the ore bins, then the end "
                  "of the line as you know it, the buffer and the door into the mine."),
        "before": [("What fills the extra 59 m", tbl(["Stretch", "Where", "What it is"], stretch)),
                   ("The mouth, and the station's standard", "<p>%s</p>" % B.esc(
                       "At the other end nothing changes: the tunnel's mouth (x -36) opens east onto the station's yard with the painted desert behind it "
                       "(the far hills card, 95 m back), never onto bare sky, and the ride's first stretches are as the 0.3 pages have them. The quality "
                       "plan's line for 0.3 is a painted tunnel receding, and the mouth opening onto the painted desert: the side galleries here carry "
                       "the first part into the new stretch, and the mouth is the station's own."))],
        "keep": ["0.1, 0.2 and 0.3's start, and the lever that starts the cart (note 72).",
                 "The cart's speed (9 m a second) and its whole road as today to x -136: the dock, the mouth, the dip, the hop at x -90 (note 73), the "
                 "banked drop, the wet tunnel, the gap at x -124 to -132.",
                 "The buffer (0.6 by 0.8 m), the cart stopping 0.4 m short of it, the door joining the mine's first gallery: all 59 m further west and 17 m lower."],
        "moves": [["The ride", "the dock, x -9", "the buffer, x -209.3, y -28.6", "203 m of road (today 141 m), about 7 s longer", "ride; the lever starts it, as today"],
                  ["The incline", "x -158, y -14.2", "x -188, y -25.1", "32 m at 20 degrees, 3.5 s", "ride; today's steepest stretch is 17 degrees, after the hop"],
                  ["Off at the end", "the cart, 0.4 m short of the buffer", "the mine's door, x -211, y -29.0", "level", "as today"],
                  ["Fall out", "anywhere", "the bed", "", "walk on: the bed grips all the way"]],
        "figures": [{"win": win, "faint": faint_today("a0", "a1"), "bold": [(A0_KEEP, PAL["a0"]), (NEW_A0, PAL["a0"]), (NEW_A1, PAL["a1"])], "marks": marks,
                     "climbers": [(-207.4, -28.45)], "maxw": 900.0,
                     "caption": "The new stretch from the side, x -215 to -128. Faint: today's end of the line and the mine's door and first gallery, which were here. "
                                "The cart is drawn stopped at the buffer, its road dotted."}],
        "items": items,
        "explains": [["The bed", "The haulage incline's track", "The winding house at its head, the ore bins at its foot"],
                     ["The steepness", "An incline worked by rope", "The drum, the snapped rope, the sprung catch"],
                     ["The buffer", "The end of the line", "Its braces, the pegs, the door into the mine"]],
        "pieces": [["Winding house: drum on a timber frame, brake band and lever, brakeman's seat, the rope's snapped end", "4 by 4 m in a 9 by 8 m chamber", "1",
                    "Background (hero)", "new"],
                   ["Haulage rope, lying", "30 m", "1", "Play space (flat on the bed)", "new, flat"],
                   ["Runaway catch, sprung", "1 m", "1", "Play space edge", "new, small"],
                   ["Warning board", "1 m", "1", "Background", "kit: the mine's skull-pug diamond"],
                   ["Ore bins with chutes", "4.4 by 2.4 m", "1", "Background", "new"],
                   ["Timber set, plumb on a slope", "as today's", "about 20 more", "Background", "kit: today's tunnel sets (dsc_)"],
                   ["Side gallery opening, painted going back", "3.2 m", "2", "Backdrop", "new"],
                   ["Rails and sleepers", "4 m pieces", "about 15 more", "Play space", "kit: rail_straight"],
                   ["Bed and roof skins for the new stretch", "62 m", "a few", "Play space", "today's dsc_bed_d and dsc_roof_d carried on"]],
        "effects": ["Dust off the wheels where the cart goes over the brow.", "Drips and the lanterns' warm light, as in today's tunnel."],
        "first": ["The incline at 20 degrees from x -158 to -188, eased in and out.", "The new road's points (in make_rearrange.py, RIDE_NEW)."],
        "notes": ["Note 146: the ride lengthened by the same distance as the mine moves; it may drop a little lower.",
                  "Note 72: the lever starts the cart. Note 73: the hop. Both unchanged.",
                  "docs/peak/QUALITY_TO_9_PLAN.md: 0.3's painted tunnel receding, and the mouth onto the painted desert."],
        "ask": ["The 17 m drop is all on one 20 degree incline near the end. All right, or spread it over the whole lower tunnel (that changes 0.3c)?",
                "The winding house as the new stretch's hero piece?"],
    }


def page_mine():
    w1 = [-327.0, -57.0, -145.0, 92.0]
    m1 = falls_marks(-45.0, 73.0) + [("poly", [(mvx(-248.0), -50.0), (mvx(-248.0) + 6.0, -50.0), (mvx(-248.0) + 6.0, 69.0), (mvx(-248.0), 69.0)], "wid"),
                                     ("text", [(-200.0, 84.0), "today's mine (faint)"], "noteo"), ("text", [(-326.0, 80.0), "after: 59 m west, 17 m down"], "note"),
                                     ("text", [(-326.0, -54.5), "the widening: 6 m"], "note")]
    w2 = [-323.5, -54.5, -281.5, -18.0]
    m2 = falls_marks(-45.0, -18.0) + [("poly", [(mvx(-248.0), -50.0), (mvx(-248.0) + 6.0, -50.0), (mvx(-248.0) + 6.0, -18.0), (mvx(-248.0), -18.0)], "wid"),
                                      ("text", [(-312.6, -19.2), "the 6 m added"], "note"), ("text", [(-302.6, -19.2), "the falls"], "notep")]
    items = [
        it("backdrop", "The cavern's west reaches", [-16.0, -12.0],
           "Behind the widened space west of the falls: a painted card of the cavern going on west into the dark, wet rock shelves catching the falls' "
           "light, mist hanging in it, one far lantern on an old working. The waterfall's glow the quality plan asks for, with room to show it.",
           [R(-313.0, -45.0, -303.2, -19.0, "solid"), C(-310.2, -27.0, 0.1, "light")], tag=[-310.0, -33.0]),
        it("set", "The rock shelves at the wall's foot", [-3.0, -2.0],
           "Behind the Sump's new west water, low shelves of wet rock stepping back into the dark at the foot of the west wall, catching the falls' "
           "light, so the 6 m added read as more cavern and not as a blank. (Higher up, today's dark card behind the fall moves west with the wall "
           "too: x -321 to -312.)",
           [P([[-313.0, -45.0], [-313.0, -41.0], [-309.5, -42.2], [-306.0, -43.6], [-304.0, -45.0]], "pale")], tag=[-309.0, -43.4]),
        it("set", "The west wall's face", [-1.6, -1.25],
           "The chamber's west wall, painted as the mine's walls are (long wavy bands, no blocks): 6 m further from the falls than today, so the falls "
           "stand out in open air.",
           [R(-313.6, -45.0, -313.0, -19.0, "pale")], tag=[-313.3, -30.5]),
        it("things", "The frog's cave, moved with the wall", [-2.6, -1.2],
           "Page 1.0's frog cave and its doorway, as designed, at the new west wall: its door now 10 m from the falls' foot instead of 4.",
           [arch(-317.4, -314.0, -44.5, -42.6, "dark")], tag=[-315.7, -41.4], over=True),
        it("things", "Mist and churn at the falls' foot", [-2.0, 1.0],
           "The falls hit the Sump in white churn, and the mist fills the widened space: today's mist (x -250 to -230) widened west with the wall.",
           [C(-300.0, -44.4, 0.6, "line"), C(-305.5, -40.0, 0.5, "line"), C(-309.5, -36.0, 0.45, "line")], tag=[-307.5, -38.0]),
        it("climb", "One more staging pile", [-1.2, 1.2],
           "An old staging pile standing in the Sump's new west water, like the four that are there today east of the falls: something to hold on "
           "the 9 m swim from the falls' foot to the frog's cave.",
           [R(-308.7, -50.0, -308.3, -44.2, "pale")], tag=[-308.5, -46.4]),
        it("climb", "The frog's cave floor and doorstep", [-1.2, 1.2], "As today (page 1.0), moved 65 m west and 17 m down with the wall.",
           [R(-318.4, -45.0, -313.0, -44.5, "pale"), R(-313.0, -45.3, -312.2, -44.5, "pale")], tag=[-316.0, -46.2]),
    ]
    moved = [["Everything in a1.py and a1_dress.py: solids, ledges, movers, ropes, the rock spawners and their board, zones, effects, lights, cameras, "
              "cards, every deco and skin", "", "x minus 59, y minus 17"],
             ["Everything west of x -246 (today's numbers): the chamber's west wall, the frog's cave with its floor and doorstep, the card behind the "
              "fall, the west ends of the Sump's water, floor and mist", "", "a further 6 m west: x minus 65, y minus 17"],
             ["The Sump's water", "x -248 to -187.4, surface -28", "x -313 to -246.4, surface -45"],
             ["The great falls' push (the wind zone)", "x -244 to -238, y -22 to 90", "x -303 to -297, y -39 to 73"],
             ["The falls' slot in the roof", "x -244 to -238, y 86 to 90", "x -303 to -297, y 69 to 73"],
             ["La Cortina's dry shaft out", "x -236 to -232", "x -295 to -291"],
             ["The door from the cart tunnel", "x -152, floor -12.6", "x -211, floor -29.6"],
             ["La Cortina's last move", "east onto the lip (x -232, y 89.7)", "west onto the pier's new coping (x -295, y 73.0), or east onto the old lip as a rest"],
             ["The mine's frame region (stages/peak/course/_meta.json)", "x -292 to -146, y -36 to 90", "x -357 to -205, y -53 to 73"],
             ["The body card's window (st.py BODY_WINDOWS)", "x -292 to -148, y -36 to 90, split at -220", "x -357 to -207, y -53 to 73, split at -279"],
             ["The backstop card behind the far wall", "x -298 to -142, y -42 to 96", "x -363 to -201, y -59 to 79"],
             ["The mine's design pages (design/a1/)", "today's numbers", "add the same shift to every number; nothing else on them changes"]]
    widen = ("Parker's drawing moves the chamber's whole west wall about 6 m further west than the rest of the mine, from the Sump's floor to the "
             "throat's top (measured off the drawing: 6.6 m). So: the great falls, which today have 4 m of open air on their west side before the "
             "wall, get 10 m; the Sump is 6 m longer at its west end; the frog's cave moves with the wall; the throat is 24 m wide at its top (x -313 "
             "to -289), its roof carried on west over the widened part; the mist and the painted cavern fill the space. The falls' slot in the roof "
             "stays 6 m (x -303 to -297) and the falls' push stays on it, so La Cortina, the wheel, the awning and the life ring stand to the falls "
             "exactly as today. The swim from the falls' foot to the frog's cave grows from 4 m to 9 m, so one more old staging pile stands in it.")
    return {
        "slug": "the_mine_moved", "h1": "La Mina Vieja, moved under the great falls",
        "place": ("The whole mine moves 59 m west and 17 m down, so its waterfall cavern stands straight under the well and the great falls come down "
                  "through it in one line from under the forge to the Sump. Nothing inside it changes: every challenge, every hold, every lantern "
                  "and every piece of scenery moves by the same amount. Two things change at its edges. Its west wall moves a further 6 m west, as "
                  "Parker drew it, so the falls have room. And its top no longer opens into the black waters: La Cortina lets out into the new "
                  "section's lip room, beside the flume's lip, where Los Barriles starts."),
        "before": [("What moves, and by how much", tbl(["What", "Today", "After"], moved)),
                   ("The widened falls area at its foot", "<p>%s</p>" % B.esc(widen)),
                   ("Why it drops 17 m too", "<p>%s</p>" % B.esc(
                       "Moved only west, the throat's roof (y 86 to 90) would sit inside the black waters' rock, which starts at y 83 west of x -292: "
                       "110 square metres of overlap. And there would be no room between the mine's top and El Borde (y 90) for the flume and the lock. "
                       "Dropped 17 m, as in Parker's drawing, its top is at y 73, 10 m under the black waters' lowest rock, and the 17 m to El Borde hold "
                       "the lip room, the flume and a 12 m lock exactly. The Sump's floor goes to y -50, inside the game's bug net at y -60: a drop of "
                       "more than about 26 m would not fit."))],
        "keep": ["Every challenge 1.1 to 1.11 exactly as today, relative to itself: the moves, the rhythms (the cave-in's written rocks, the curtain's drips), "
                 "the carts, the wheel, the lift.", "The falls' slot, 6 m, and their push on it; La Cortina's place beside them; the awning and the life ring.",
                 "The Sump and its swim (6 m longer at the west end, with one more pile to hold).", "The door from the cart tunnel into 1.1 La Galería."],
        "figures": [{"win": w1, "faint": faint_today("a1"), "bold": [(NEW_A1, PAL["a1"]), (NEW_SEC, PAL["a2"]), (NEW_A0, PAL["a0"])], "marks": m1, "items": False,
                     "maxw": 900.0, "caption": "The whole mine from the side: today's faint (east), after in its colours (west), the great falls through it, the "
                                               "green band the 6 m widening. At the top, the new section; at the bottom right, the longer tunnel reaching the moved door."},
                    {"win": w2, "faint": [], "bold": [(NEW_A1, PAL["a1"])], "marks": m2,
                     "caption": "The widened falls area at the mine's foot, after. The numbers match the lists below."}],
        "items": items,
        "explains": [["The Sump's west water", "The cavern's floor, flooded, wider now", "The painted west reaches; the card behind the fall"],
                     ["The new staging pile", "An old pile from the staging that stood in the Sump", "Its four fellows east of the falls"],
                     ["The frog's cave", "As page 1.0", "As page 1.0"]],
        "pieces": [["The west wall's painted skins, re-cut to the new wall", "as today's mine_throat_west and the Sump's west slabs", "a few", "Play space (slick)",
                    "today's pieces, re-made to the new outline"],
                   ["The cavern's west reaches", "far card 10 by 26 m", "1", "Backdrop", "new"],
                   ["Staging pile", "0.4 by 5.8 m", "1", "Play space", "kit: the Sump's piles"]],
        "first": ["The widening, 6 m (Parker's drawing measures 6.6).", "The new staging pile at x -308.5.",
                  "The shift, 59 m: it centres the falls' slot on the well's middle line (x -300). Parker's drawing measures 57 to 58 m."],
        "notes": ["Note 146: the mine moved under the falls, about 60 m; the falls area at its foot widened as drawn; it comes first in the quality run, then the mine's full pass.",
                  "Note 111: the great falls at full width and 3D; with 10 m of air beside them they can read as a great falls."],
        "ask": ["The drop of 17 m as well as 59 m west, as your drawing has it: agreed? It is what makes room for the new section.",
                "The falls' slot: 6 m as today, or open the roof over the whole widened throat (12 m), as your drawing hints?"],
    }


PAGES = [("the_mine_moved", page_mine, "The mine moved under the falls: what moves, the 6 m widening at its foot, why it drops 17 m."),
         ("0_3_the_longer_ride", page_ride, "0.3 El Descenso, 59 m longer: the haulage incline, the winding house, the ore bins, the end of the line moved."),
         ("la_esclusa_the_place", page_place, "La Esclusa, the new section as a place: how it fits, the route, the water, what changed."),
         ("los_barriles", page_barriles, "Los Barriles remade: the flume, the barrels running west, the crane's chain at the lip."),
         ("la_esclusa_the_lock", page_lock, "La Esclusa, the lock: the wicket, the fill, the ledges, out onto El Borde; the cycle."),
         ("2_7_el_salto_de_la_cascada", page_salto, "2.7 El Salto de la Cascada: the leap over the great falls into the pool that feeds them.")]


def index_html(built):
    b = ['<p class="sub"><a href="../../PLAYTEST_NOTES.html#n146">Note 146 in the playtest notes</a> &middot; '
         '<a href="../../PLAYTEST_NOTES.html#design">Area and background design</a></p>']
    b.append("<h1>Note 146: the bottom of the mountain rearranged</h1>")
    b.append('<p class="sub">Design pages only. Nothing in the game changes. Drawn from the course files as they are today; every number not marked '
             '"as today" is a first guess.</p>')
    b.append("<p>%s</p>" % B.esc(
        "The great falls now run to the bottom. The mine moves 59 m west and 17 m down, so its waterfall cavern stands under the well, and its west "
        "wall a further 6 m west so the falls have room. The cart ride runs 59 m further, down a steep incline, to the mine's moved door. Between the "
        "mine's top and the black waters, under their east end, a new section, La Esclusa: Los Barriles, the barrels' flume with the barrels running "
        "west into the falls, and La Esclusa, a lock that floats you up to El Borde. Where the barrels were, 2.7 becomes El Salto de la Cascada, a leap "
        "over the falling water into the pool that feeds them."))
    b.append('<h2>The map</h2><figure><a href="146_overview.png"><img class="map" src="146_overview.png" alt="Map of the bottom of the mountain after the change"></a>'
             '<figcaption>The bottom of the mountain from the station to the black waters\' top, in the course\'s own metres. Bold: after. Faint and dashed: '
             'today (what moves or goes). The pale band is the great falls.</figcaption></figure>')
    b.append('<figure><a href="146_closeup.png"><img class="map" src="146_closeup.png" alt="Close up of the new section and 2.7"></a>'
             '<figcaption>Close up: the new section, the falls\' shaft through the black waters\' floor, and 2.7.</figcaption></figure>')
    key = [["The mine's shift", "59 m west and 17 m down (the falls' slot moves from x -244 to -238 to x -303 to -297, centred on the well's middle, x -300)"],
           ["The widening", "the mine's west wall and frog's cave a further 6 m west (Parker's drawing: 6.6 m)"],
           ["The mine after", "x -322.4 to -207, y -54 to 73 (today x -257.4 to -148, y -37 to 90)"],
           ["The cart ride", "203 m of road (today 141 m); its end moves from (-148.4, -11.55) to (-207.4, -28.55); the mine's door to x -211, floor -29.6; "
                             "a 20 degree incline from x -158 to -188"],
           ["The great falls", "one column, x -303 to -297, down the well (note 147 starts them at the glacier above) through the Charco, the black "
                               "waters' floor, the new section and the mine to the Sump at y -45; a fall into them is a ride to the Sump (note 147)"],
           ["The new section, La Esclusa", "x -303 to -222, y 73 to 90: the lip room y 73 to 75.2, the flume's water x -297 to -264.5, y 75.7 to 77.2, "
                                           "landings and quay at 79.4, the lock x -250 to -228, y 75.7 to 86 and up the dry shaft to 88.5"],
           ["The barrels", "as today: eight, 0.55 m a second, the same gaps, 26.8 m of road, now from x -272.4 west to the lip at x -297"],
           ["The lock", "11.3 m in 6 s, held 3 s, drained in 5 s, 4 s at the bottom (added): 18 s"],
           ["2.7's leap", "over the falls (6 m) from a chain at x -296.9 to the pool beyond: 6.7 to 9.1 m, 4.4 m down"]]
    b.append("<h2>The layout's key numbers</h2>" + tbl(["", ""], key))
    rows = []
    for cid, name, old_at, new_at, note in STARTS:
        f = lambda p: "x %.1f, y %.2f" % p if p else "new"
        rows.append([cid, name, f(old_at), f(new_at), note])
    b.append("<h2>Where each challenge now starts</h2>" + tbl(["", "Challenge", "Today", "After", ""], rows))
    changed = ["The mine drops 17 m as well as moving west (as Parker drew it). Moved only west, its throat's roof sits in the black waters' rock "
               "(110 square metres of overlap), and nothing fits between its top and El Borde. With the drop there are 17 m: the lip room, the "
               "flume and a 12 m lock exactly.",
               "The shift is 59 m, not 60: that centres the falls' slot on the well's middle line (x -300). Parker's drawing measures 57 to 58 m.",
               "The pitch's short passage east from the mine's top cannot reach the flume's west end: La Cortina's dry shaft is 2 m east of the falls, "
               "under the flume's last metres. So the mine lets out beside the lip, and you climb the broken crane's chain onto its platform, between "
               "barrels. The chain is also the great falls' one last chance (law 7).",
               "The lock sits under the black waters' slot and the old dry shaft, where El Borde's water and lip ledge are, 27 m east of the flume's "
               "head: a 13.5 m quay joins them.",
               "The pitched 14 s lock cycle has no time at the bottom; 4 s added (18 s) so the wicket opens and you can cross before the fill.",
               "2.7's running leap is a fling from a chain (the climber cannot run and jump 6 m; a fling is this game's jump).",
               "The Charco's east half stays as a basin under Q6, so the old cascade and El Borde's river keep their water.",
               "A fall into the great falls anywhere rides them to the Sump (note 147, settled while these pages were drawn): 2.7's miss, a fall "
               "off the barrels, and a fall down the well into the falls all end in the Sump. Two softer falls are asked below: from El Borde "
               "(now into the lock) and down the well beside the falls (into 2.7's pool)."]
    b.append("<h2>What did not fit, and what changed to make it fit</h2>" + ul(changed))
    b.append("<h2>The checks</h2><p>Run by make_rearrange.py over the course files (shapely), every time it is run.</p>" + tbl(["Check", "Result"], CHECKS))
    b.append("<h2>The pages</h2><ul>%s</ul>" % "".join('<li><a href="%s.html"><b>%s</b></a>: %s</li>' % (s, B.esc(h1), B.esc(line)) for s, h1, line in built))
    builds = ["a1.py and a1_dress.py: every position moved by (-59, -17), and west of x -246 by (-65, -17); La Cortina's top (the pier's coping, "
              "its last move west); the exit no longer into a2's lip ledge.",
              "a0.py and a0_dress.py: RIDE carried on to (-207.4, -28.55), the tunnel to the door at x -211; the end of the line's pieces moved; the "
              "new stretch's pieces; the dark zone to x -211.",
              "a new area file for La Esclusa (or a part of a2): the flume, the barrels moved here and reversed, the landings, the chain, the quay, "
              "the lock as a water level that cycles, the wicket and the flap as movers, its dress.",
              "a2.py: the falls' shaft cut through the Charco's bed; the pool split; Q6 lengthened, the davit chain, C1, C2, Q7's rungs; the barrels "
              "and their cove taken out; the slot's waterfall now ending on the lock's flap; the strip x -252 to -223, y 86 to 89.4 no longer the mine's.",
              "st.py: BODY_WINDOWS for the moved mine and the new section; _meta.json's frames for a0, a1 and the new section.",
              "The great falls as one 3D waterfall (notes 111, 142), from the well's top to the Sump."]
    b.append('<h2>What the course will need, when it is built</h2><p class="sub">For the Second Director; nothing here is done.</p>' + ul(builds))
    qs = []
    for s, h1, line in built:
        for q in PAGE_DATA[s].get("ask", []):
            qs.append('<li><a href="%s.html">%s</a>: %s</li>' % (s, B.esc(h1), B.esc(q)))
    b.append('<div class="ask"><p><b>Every question for Parker, in one list:</b></p><ul>%s</ul></div>' % "".join(qs))
    return B.page("Note 146: the bottom of the mountain rearranged", "\n".join(b)).replace("</style>", EXTRA_CSS + "</style>", 1)


PAGE_DATA = {}


def main():
    argv = sys.argv[1:]
    png_dir = None
    if "--png" in argv:
        png_dir = argv[argv.index("--png") + 1]
        os.makedirs(png_dir, exist_ok=True)
    run_checks()
    for k, v in CHECKS:
        print("CHECK %s: %s" % (k, v))
    overview(os.path.join(HERE, "146_overview.png"))
    overview(os.path.join(HERE, "146_closeup.png"), win=(-326.0, 60.0, -219.0, 132.0), size=(18.0, 12.6), dpi=100, close=True)
    built = []
    for slug, fn, line in PAGES:
        P = fn()
        assert P["slug"] == slug
        PAGE_DATA[slug] = P
        io.open(os.path.join(HERE, slug + ".html"), "w", encoding="utf-8", newline="\n").write(page_html(P, png_dir))
        built.append((slug, P["h1"], line))
        print("wrote", slug + ".html")
    io.open(os.path.join(HERE, "index.html"), "w", encoding="utf-8", newline="\n").write(index_html(built))
    print("wrote index.html, 146_overview.png, 146_closeup.png")
    for w in WARN:
        print("WARN", w)
    print("warnings:", len(WARN))


if __name__ == "__main__":
    main()
