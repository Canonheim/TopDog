class_name Stage
extends RefCounted
## THE STAGE: the dock, the sea and the barrel. Builds the 2D collision (what you
## touch) and, when there's a 3D root, the dressing (what you see). The 2D outline
## of every solid is its 3D shape cut at the play plane (z = 0).

const DONKEY_MODEL := preload("res://kit/models/donkey_base.glb")
## THE BELL BASE (Parker 11-10, the Building Maker's design): a stone pedestal, a wooden
## frame, a church bell. Collision from its non-deco_ meshes; only bell_body rings.
const BELL_MODEL_PATH := "res://kit/models/bell_base.glb"
const BELL_PULSE := 1.06  # the ring's pulse: 6% (the Building Maker's limit), back in 0.25 s
var bell_node: Node3D = null  # the model's `bell` node (pulses on a ring), when dressed

const CACTUS_MODEL := preload("res://kit/models/potted_saguaro.glb")

const BARREL_MODEL := preload("res://models/barrel.glb")

## Stage rows: deck half-width, barrel scale, spawn x, bounds.
const STAGES := {
	"dock": {"name": "The Dock", "deck_half": 9.0, "barrel_scale": 2.1, "spawn_x": 5.5, "kill_y": -4.0, "side_x": 16.0},
	# THE PLAZA RING (Parker's picture): the same flat 18 m deck and barrel, dressed as
	# a wrestling ring on a raised stage in a sunny plaza. Fall off the apron and you
	# drop to the plaza stones (out, respawn), like falling in the sea.
	# side_x 60 (Parker 11-10: "the ground outside the ring is not solid in places"): the
	# plaza floor ran to 16 m and climbers thrown past it fell through the stones; it now
	# runs to 60 m, and anywhere on it is a RING OUT.
	"plaza": {"name": "The Plaza Ring", "deck_half": 9.0, "barrel_scale": 2.1, "spawn_x": 5.5, "kill_y": -4.0, "side_x": 60.0, "dress": "plaza"},
}
## The plaza's ground level (the ring's canvas is y = 0, its stage stands on this).
const PLAZA_GROUND := -0.9  # the kit ring's apron drops 0.9 m to the plaza
const CANVAS := Color("#ADA28E")  # the ring canvas: mid warm grey, so pale climbers read on it

## The barrel's profile at the plane: (half-width, height) pairs, bottom to top,
## at scale 1.0 (staves bulge 0.44 at the middle, 0.40 at the rims; 0.96 tall).
const BARREL_PROFILE := [
	Vector2(0.39, 0.0), Vector2(0.43, 0.24), Vector2(0.445, 0.48), Vector2(0.43, 0.72), Vector2(0.39, 0.96),
]

var donkey_head := Vector3.ZERO
var base_id := "barrel"
var base_root: Node3D
var base_bodies: Array = []
var base_dressed := true

var row: Dictionary
var barrel_top := 0.0
var ring_kit: Node3D = null  # the kit ring, once dressed (its ropes animate)
## THE FIRST LINE: the line before anyone is in the tower sits this far above the
## barrel's top, out of a standing climber's reach (Parker 11-07: "I can reach
## straight up at spawn and touch it").
const FIRST_LINE_ABOVE := 0.75  # Parker 11-10: first "the first starting line should always be .5 meters above whatever the height of the starting climb object is", then ".75 above instead of .5" (was 0.8 before that)
var first_line := 0.0
var barrel_half := 0.0
var bodies: Array = []

# ================================================================ DEL MAR (Parker 11-10)
## The pier mode (docs/DEL_MAR.md; numbers from the Environment Maker's district plan,
## Top Dog Kit/docs/del_mar/DEL_MAR_DISTRICT_PLAN.md). The plaza stays built; Del Mar
## adds the pier, the sea, the mast, the rope and the buoy to the right of it, and
## frees them again when the match ends.
const PIER_ROOT := 74.0
const PIER_END := 104.0
const DECK_Y := 0.0
const DECK_DEPTH := 0.36  # the pier's slab under the deck top (one seamless body)
const WATER_Y := -1.8
const MAST_X := 100.75
const MAST_Z := -1.35  # the mast stands behind the play area (Parker: background dressing)
const MAST_EYE_Z := -1.15  # the Carpenter's head: the rope's eye, a touch forward of the mast's axis
const MAST_COLLAR := 4.0  # the fixed lower mast's collar (pier_mast_base)
const MAST_SECTION := 2.0  # each section that slots in under the head as it rises
const WINCH_AT := Vector3(93.75, 0.0, -1.15)
const DELMAR_FIRST_GAP := 0.75  # the rope starts this far beyond the base's furthest point
const BUOY_R := 0.5  # the buoy's solid dome, half on the water
const SPAWN_BACK := [3.86, 6.86]  # spawns: this far back from the pier end (3 m apart)
var delmar := false
var delmar_root: Node3D = null
var buoy_body: StaticBody3D = null
var _rope: MeshInstance3D = null
var _mast_pole: MeshInstance3D = null
var floaties: DelMarFloaties = null
var scenery: DelMarScenery = null
var sea: DelMarSea = null  # Golemheim's living water on the scenery's sea, and the splashes  # the Environment Maker's: the sea, the beach town, the pier's look, ships, clouds
var _mast_head_node: Node3D = null  # the Carpenter's pier_mast_head (origin = the rope's eye)
var _mast_sections: Array = []
var _winch: Node3D = null
var _backstay: MeshInstance3D = null
var _last_eye_y := 0.0
var _rope_root: Node3D = null  # the UI creator's rope segments and streamers
var _rope_segs: Array = []
var _streamers: Array = []
var _buoy_model: Node3D = null  # the buoy's look, rocking on its (still) collider
var _mast_parts_found := false
var _winch_drum: Node3D = null
var _stay_foot: Node3D = null
var _stay_top: Node3D = null
var _buoy_t := 0.0
var _buoy_lean := 0.0  # rad, leaning back as it glides out
var _buoy_lean_v := 0.0
var _wake_wait := 0.0
var _rope_wob := 0.0  # the rope's sideways swing (m at its middle), a damped spring
var _rope_wob_v := 0.0
var _last_eye := Vector3.INF
var _rope_a := Vector3.INF
var _rope_b := Vector3.INF
var _rope_along := Vector3.ZERO
var _rope_across := Vector3.ZERO
var _rope_sag := 0.0
var _rope_twang := 0.0
const ROPE_SAG := 0.035  # the rope's sag, x its length, at its middle
const ROPE_POINTS := 12  # the curve the segments follow
## The rope ties to the gold ring at the top of the UI creator's classic buoy (11-10:
## "make the buoy taller and have the rope attach to it at the top"). The buoy rides
## along the line so this eye sits ON it: the rope from here to the mast is the line.
const BUOY_EYE := Vector3(0.0, 2.07, 0.0)
## THE BUOY STANDS BACK (Parker 11-11: "The buoy should actually be further back so it is
## not in their way, so they can float around more freely and not clip through it"): it
## floats 2 m behind the play plane, like the mast, out of the climbers' and the floaties'
## way. Its x is the line's as ever (the line's maths is x and y only).
const BUOY_Z := -2.0
const SHORE_Y := -0.92  # the land's top behind the pier (the plaza's ground, DelMarScenery.GROUND_Y)
const STREAMER_STEP := 0.5  # one every 0.5 m, counted from the buoy end (they don't slide)
const STREAMER_TINTS := [Color("#E0287A"), Color("#1FB8AE"), Color("#F28A1E"), Color("#7CC83A"), Color("#8A3FC0"), Color("#FFC928")]
const FLOAT_X := Vector2(104.5, 135.0)  # the open water the floaties drift in (the plan's box)


## Del Mar on or off. Built when a Del Mar match starts, freed when one ends: the
## plaza never pays for it.
## Every kit piece Del Mar builds (the scenery, the pier and mast, the rope, the buoy,
## the floaties). Nothing of Del Mar loads until it's picked (Parker 11-10).
const DELMAR_MODELS := [
	"beach_bar", "beach_chair_a", "beach_chair_b", "beach_house_a", "beach_house_b", "beach_hut_a", "beach_hut_b", "beach_hut_c",
	"beach_umbrella_a", "beach_umbrella_b", "beach_umbrella_c", "beach_umbrella_d", "beach_umbrella_e", "boardwalk", "cabana_a", "cabana_b",
	"delmar_buoy", "delmar_rope_seg", "delmar_streamer_a", "delmar_streamer_b", "delmar_streamer_c", "festoon_bulb", "festoon_wire_seg",
	"float_beachball", "float_duck", "float_innertube", "float_lifesaver", "isle_band_raft", "isle_lighthouse", "isle_palm_hammock",
	"isle_pinata_tree", "life_ring", "lifeguard_tower", "light_post", "lighthouse_spit", "pier", "pier_mast_base", "pier_mast_head",
	"pier_mast_section", "pier_mast_winch", "ship_brigantine", "ship_party_boat", "ship_sloop", "stall_coco", "stall_paletas", "surf_rack",
	"el_faro", "plant_pot_a", "plant_pot_b", "plant_pot_c",
]
static var _warming: Array = []
static var _warm: Dictionary = {}  # path -> PackedScene: held, so the cache keeps them


## DEL MAR LOADS WHEN PICKED: the moment MODE reads DEL MAR (in the lobby, on every
## machine), its pieces start loading on background threads, so the match's start
## doesn't hitch. Safe to call again: a path already asked for is skipped.
static func warm_delmar() -> void:
	for stem in DELMAR_MODELS:
		var p: String = LuchaKit.KIT_DIR + stem + ".glb"
		if p in _warming or _warm.has(p) or ResourceLoader.has_cached(p) or not ResourceLoader.exists(p):
			continue
		if ResourceLoader.load_threaded_request(p, "PackedScene", true) == OK:
			_warming.append(p)


## Collect what warm_delmar fetched (waits for any still loading), so the build reads
## them from the cache.
static func _collect_warm() -> void:
	for p in _warming:
		var res := ResourceLoader.load_threaded_get(p)
		if res != null:
			_warm[p] = res
	_warming.clear()


func set_delmar(world: Node3D, on: bool, seed_value := 1) -> void:
	if on == delmar and (not on or is_instance_valid(delmar_root)):
		if on:
			_reset_delmar(seed_value)  # a rematch: the same pier, everything back to its start
		return
	if is_instance_valid(delmar_root):
		for b in delmar_root.find_children("*", "StaticBody3D", true, false):
			bodies.erase(b)
		delmar_root.free()
	delmar_root = null
	buoy_body = null
	_rope = null
	_mast_pole = null
	floaties = null
	scenery = null
	sea = null
	_mast_head_node = null
	_mast_sections.clear()
	_winch = null
	_backstay = null
	_rope_root = null
	_rope_segs.clear()
	_buoy_model = null
	_mast_parts_found = false
	_winch_drum = null
	_stay_foot = null
	_stay_top = null
	_last_eye = Vector3.INF
	_rope_wob = 0.0
	_rope_wob_v = 0.0
	_streamers.clear()
	delmar = on
	if not on:
		return
	_collect_warm()
	delmar_root = Node3D.new()
	delmar_root.name = "DelMar"
	world.add_child(delmar_root)
	# The pier: one seamless slab, its top the deck (the Carpenter's pier_deck).
	_static_poly(delmar_root, PackedVector2Array([Vector2(PIER_ROOT, DECK_Y), Vector2(PIER_END, DECK_Y), Vector2(PIER_END, DECK_Y - DECK_DEPTH), Vector2(PIER_ROOT, DECK_Y - DECK_DEPTH)]), 1.0, 1.6)
	# The buoy: behind the play plane now (BUOY_Z), so nobody meets it; still never held
	# and never a support (meta no_weld), and not in `bodies`, so a lock-in never counts it.
	var dome := PackedVector2Array()
	# The classic buoy's float (1.0 across, to y 0.5) and its tapered cage to the top.
	for q in [Vector2(0.5, 0.0), Vector2(0.47, 0.25), Vector2(0.34, 0.5), Vector2(0.13, 1.56), Vector2(0.06, 2.1),
			Vector2(-0.06, 2.1), Vector2(-0.13, 1.56), Vector2(-0.34, 0.5), Vector2(-0.47, 0.25), Vector2(-0.5, 0.0)]:
		dome.append(q)
	buoy_body = _static_poly(delmar_root, dome, 0.6, 0.5)
	buoy_body.set_meta("no_weld", true)
	bodies.erase(buoy_body)
	# The shore behind the pier's root: the plaza's floor ends at x 60 and the pier
	# begins at 74. Without this a climber who walked or was thrown back off the root
	# fell through the steps and the sand and was called "in the sea".
	_static_poly(delmar_root, PackedVector2Array([Vector2(56.0, SHORE_Y), Vector2(PIER_ROOT, SHORE_Y), Vector2(PIER_ROOT, SHORE_Y - 1.2), Vector2(56.0, SHORE_Y - 1.2)]), 1.0, 1.6)
	_make_floaties(seed_value)
	if base_dressed:
		_dress_delmar()


func _make_floaties(seed_value: int) -> void:
	if is_instance_valid(floaties):
		floaties.free()
	floaties = DelMarFloaties.new()
	floaties.name = "Floaties"
	delmar_root.add_child(floaties)
	floaties.setup(seed_value, WATER_Y, FLOAT_X.x, FLOAT_X.y)


## Del Mar for a second match in a row: the mast back to its lower section, new
## floaties from the new seed, the rope and the buoy still.
func _reset_delmar(seed_value: int) -> void:
	for sec in _mast_sections:
		if is_instance_valid(sec):
			(sec as Node).queue_free()
	_mast_sections.clear()
	_last_eye = Vector3.INF
	_last_eye_y = 0.0
	_rope_wob = 0.0
	_rope_wob_v = 0.0
	_buoy_lean = 0.0
	_buoy_lean_v = 0.0
	_make_floaties(seed_value)


## Stand-ins until the kit's pieces land: an oak deck on piles, the sea, the mast, the
## rope and the buoy.
func _dress_delmar() -> void:
	# The Environment Maker's scenery: the sea, the beach town, the boardwalk, the
	# Carpenter's pier (its look; the slab above is its collision), ships, isles, clouds.
	scenery = DelMarScenery.new()
	delmar_root.add_child(scenery)
	scenery.build()
	sea = DelMarSea.new()
	sea.name = "Sea"
	delmar_root.add_child(sea)
	sea.dress(scenery.water_node(), WATER_Y)
	# The growing mast (Parker: "The mast gets taller as the game plays, line stays 45"):
	# the fixed lower mast, the head carrying the rope's eye, sections slotting in under
	# it, and the backstay's winch paying out.
	var base := LuchaKit.kit_model("pier_mast_base")
	if base != null:
		base.position = Vector3(MAST_X, DECK_Y, MAST_Z)
		delmar_root.add_child(base)
		_mast_head_node = LuchaKit.kit_model("pier_mast_head")
		delmar_root.add_child(_mast_head_node)
		_winch = LuchaKit.kit_model("pier_mast_winch")
		if _winch != null:
			_winch.position = WINCH_AT
			delmar_root.add_child(_winch)
		_backstay = MeshInstance3D.new()
		var stay := CylinderMesh.new()
		stay.top_radius = 0.02
		stay.bottom_radius = 0.02
		stay.height = 1.0
		_backstay.mesh = stay
		CelPass.paint(_backstay, Color("#5A3A22"))
		delmar_root.add_child(_backstay)
	if _mast_head_node == null:
		_mast_pole = _boxm(Vector3(0.28, 1.0, 0.28), Color("#8A5A34"), Vector3(MAST_X, 0, MAST_Z))
		delmar_root.add_child(_mast_pole)
	_rope = MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.035
	cyl.bottom_radius = 0.035
	cyl.height = 1.0
	_rope.mesh = cyl
	CelPass.paint(_rope, Color("#D8262E"))
	delmar_root.add_child(_rope)
	var buoy_model := LuchaKit.kit_model("delmar_buoy")
	if buoy_model != null:
		buoy_body.add_child(buoy_model)
		_buoy_model = buoy_model
	else:
		var buoy := MeshInstance3D.new()
		var sph := SphereMesh.new()
		sph.radius = BUOY_R
		sph.height = BUOY_R * 2.6
		buoy.mesh = sph
		CelPass.paint(buoy, Color("#E23B3B"))
		buoy_body.add_child(buoy)
	if LuchaKit.kit_model_exists("delmar_rope_seg"):
		_rope.visible = false
		_rope_root = Node3D.new()
		_rope_root.name = "Rope"
		delmar_root.add_child(_rope_root)


## Where Del Mar's line is: `c` in the line's units (x + y). The buoy floats where the
## rope meets the water, the mast's head rises to where it meets the mast (Parker:
## "The mast gets taller as the game plays, line stays 45"), and the rope joins them.
## Both halves at once (the base being placed, the batteries).
func place_delmar_line(c: float, speed := 0.0, delta := 0.0) -> void:
	move_buoy(c)
	draw_delmar_line(c, speed, delta)


## THE PHYSICS HALF, every tick: the buoy's body.
## Written only when it moved.
func move_buoy(c: float) -> void:
	if not delmar or not is_instance_valid(delmar_root):
		return
	# Placed so its eye lies on the line (x + y = c): the rope is the line exactly.
	var buoy_at := Vector3(c - WATER_Y - BUOY_EYE.y - BUOY_EYE.x, WATER_Y, BUOY_Z)
	if is_instance_valid(buoy_body) and not buoy_body.global_position.is_equal_approx(buoy_at):
		buoy_body.global_position = buoy_at


## THE DRAWN HALF, once a frame (it ran every physics tick, 120 a second: the rope's
## segments and streamers alone were some 200 transforms a tick): the buoy rocking,
## the mast, the rope.
func draw_delmar_line(c: float, speed := 0.0, delta := 0.0) -> void:
	if not delmar or not is_instance_valid(delmar_root):
		return
	var buoy_at := Vector3(c - WATER_Y - BUOY_EYE.y - BUOY_EYE.x, WATER_Y, BUOY_Z)
	_float_buoy(speed, delta, buoy_at)
	var eye := Vector3(MAST_X, c - MAST_X, MAST_EYE_Z)
	if _mast_head_node != null:
		_grow_mast(eye)
	if _mast_pole != null:
		_mast_pole.scale = Vector3(1, maxf(0.5, eye.y - DECK_Y), 1)
		_mast_pole.position = Vector3(MAST_X, DECK_Y + (eye.y - DECK_Y) * 0.5, MAST_Z)
	var a := buoy_at + BUOY_EYE
	if _buoy_model != null:
		a = Transform3D(Basis(), buoy_at) * (_buoy_model.transform * BUOY_EYE)  # the rope rides the rocking buoy
	if _rope_root != null:
		_string_rope(a, eye, delta)
	elif _rope != null:
		var mid := (a + eye) * 0.5
		var along := eye - a
		_rope.global_transform = Transform3D(Basis(Quaternion(Vector3.UP, along.normalized())).scaled_local(Vector3(1, along.length(), 1)), mid)


## The Carpenter's mast follows the eye: the head rides at it, and a new 2 m section
## drops onto its collar under the head (0.3 m in 0.15 s, with a thunk) whenever the
## head's shaft would show too much. The winch turns and the backstay pays out.
func _grow_mast(eye: Vector3) -> void:
	_mast_head_node.global_position = eye
	var n := maxi(0, int(floor((eye.y - DECK_Y - 0.4 - MAST_COLLAR) / MAST_SECTION)))
	while _mast_sections.size() < n:
		var k := _mast_sections.size()
		var sec := LuchaKit.kit_model("pier_mast_section")
		if sec == null:
			break
		var seat := Vector3(MAST_X, DECK_Y + MAST_COLLAR + MAST_SECTION * float(k), MAST_Z)
		sec.position = seat + Vector3(0, 0.3, 0)
		delmar_root.add_child(sec)
		_mast_sections.append(sec)
		var tw := sec.create_tween()
		tw.tween_property(sec, "position", seat, 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tw.tween_callback(func() -> void: Sound.play_at("thud", seat, -6.0, delmar_root))
	if not _mast_parts_found:
		_mast_parts_found = true
		_winch_drum = _winch.find_child("deco_winch_drum", true, false) as Node3D if _winch != null else null
		_stay_foot = _winch.find_child("stay_anchor", true, false) as Node3D if _winch != null else null
		_stay_top = _mast_head_node.find_child("stay_eye", true, false) as Node3D
	if is_instance_valid(_winch_drum) and eye.y != _last_eye_y:
		_winch_drum.rotation.z -= (eye.y - _last_eye_y) * 2.0
	_last_eye_y = eye.y
	if _backstay != null:
		var top := _stay_top if is_instance_valid(_stay_top) else null
		var foot := _stay_foot if is_instance_valid(_stay_foot) else null
		if top != null and foot != null:
			var a := foot.global_position
			var b := top.global_position
			var along := b - a
			# (scaled_local: scaled() stretches in the parent's frame, and the stay drew as a
			# near-upright sliver touching neither the winch nor the mast.)
			_backstay.global_transform = Transform3D(Basis(Quaternion(Vector3.UP, along.normalized())).scaled_local(Vector3(1, along.length(), 1)), (a + b) * 0.5)


## THE BUOY IN THE WATER (Parker 11-10: "have it bounce back and forth a little in the
## water... and a wake as it moves"): its look bobs, rocks and sways on the swell (the
## collider stays put), leans back as it glides out and rights itself with a wobble,
## and while it moves it leaves rings and a little spray behind it.
func _float_buoy(speed: float, delta: float, at: Vector3) -> void:
	if delta <= 0.0:
		return
	_buoy_t += delta
	# The lean: pushed back by the glide's speed, sprung back upright, under-damped.
	var want := -clampf(speed * 0.09, -0.35, 0.35)
	_buoy_lean_v += ((want - _buoy_lean) * 28.0 - _buoy_lean_v * 4.5) * delta
	_buoy_lean += _buoy_lean_v * delta
	if _buoy_model != null:
		var t := _buoy_t
		_buoy_model.position = Vector3(sin(t * 0.9) * 0.07, sin(t * 3.1) * 0.05 + sin(t * 1.7) * 0.03, 0.0)
		_buoy_model.rotation = Vector3(sin(t * 1.3) * 0.04, 0.0, sin(t * 2.0) * 0.1 + _buoy_lean)
	# The wake: rings behind it and a little spray at its bow while it moves.
	var v := absf(speed)
	if sea != null and v > 0.12:
		_wake_wait -= delta
		if _wake_wait <= 0.0:
			_wake_wait = clampf(0.22 - v * 0.03, 0.08, 0.22)
			var behind := -signf(speed)
			sea.ripple(at + Vector3(behind * 0.45, 0.0, randf_range(-0.25, 0.25)), clampf(0.5 + v * 0.25, 0.5, 1.4))
			if v > 0.6:
				sea.spray(at + Vector3(signf(speed) * 0.45, 0.0, 0.3), clampf(v * 0.15, 0.15, 0.45))


## The rope's curve from the buoy's eye a to the mast's eye b: a slight sag, plus a
## sideways swing (in the plane, across the rope) excited by the buoy's bobbing and
## its glide, which rings down like a plucked line.
func _rope_point(a: Vector3, b: Vector3, s: float) -> Vector3:
	if a != _rope_a or b != _rope_b:
		_rope_a = a
		_rope_b = b
		_rope_along = b - a
		_rope_across = Vector3(-_rope_along.y, _rope_along.x, 0.0).normalized()  # in the plane, square to the rope
		_rope_sag = ROPE_SAG * _rope_along.length()
		_rope_twang = sin(_buoy_t * 5.3)
	var hump := 4.0 * s * (1.0 - s)
	var p := a + _rope_along * s
	p.y -= _rope_sag * hump
	p += _rope_across * (_rope_wob * sin(PI * s) + _rope_wob * 0.35 * sin(TAU * s) * _rope_twang)
	return p


func _tick_rope_wobble(a: Vector3, delta: float) -> void:
	if delta <= 0.0:
		return
	var kick := 0.0
	if _last_eye.is_finite():
		kick = ((a - _last_eye) / delta).length()  # the eye's speed shakes the line
	_last_eye = a
	_rope_wob_v += (-_rope_wob * 40.0 - _rope_wob_v * 3.0) * delta + kick * 0.6 * delta * signf(sin(_buoy_t * 6.0))
	_rope_wob = clampf(_rope_wob + _rope_wob_v * delta, -0.4, 0.4)


## The UI creator's rope: 1 m segments from the buoy's eye to the mast's eye (the last one
## cut to length), and a streamer every 0.5 m counted from the buoy end, so they never
## slide as the rope grows; new ones appear at the mast end.
func _string_rope(a: Vector3, b: Vector3, delta := 0.0) -> void:
	var along := b - a
	var length := along.length()
	if length < 0.01:
		return
	var dir := along / length
	_tick_rope_wobble(a, delta)
	# THE ROPE FLEXES (Parker 11-10: "make the rope have a little bit of flex and wobble
	# as the buoy bounces"): each 1 m segment spans its stretch of the sagging, swinging
	# curve, so the rope bends with it.
	var n := int(ceil(length))
	while _rope_segs.size() < n:
		var seg := LuchaKit.kit_model("delmar_rope_seg")
		LuchaUI.no_shadows(seg)
		_rope_root.add_child(seg)
		_rope_segs.append(seg)
	for i in _rope_segs.size():
		var seg: Node3D = _rope_segs[i]
		seg.visible = i < n
		if i < n:
			var p0 := _rope_point(a, b, float(i) / length)
			var p1 := _rope_point(a, b, minf(float(i + 1), length) / length)
			var d := p1 - p0
			var span := d.length()
			if span < 0.001:
				seg.visible = false
				continue
			var basis := Basis(Quaternion(Vector3.RIGHT, d / span))
			seg.global_transform = Transform3D(basis.scaled_local(Vector3(span, 1, 1)), p0)  # (local: the cut last segment was sheared)
	var m := int(floor(length / STREAMER_STEP))
	while _streamers.size() < m:
		var k := _streamers.size()
		var st := LuchaKit.kit_model("delmar_streamer_" + "abc"[k % 3])
		if st == null:
			break
		LuchaKit.tint_part(st, "streamer_" + "abc"[k % 3], STREAMER_TINTS[k % STREAMER_TINTS.size()])
		LuchaUI.no_shadows(st)
		_rope_root.add_child(st)
		_streamers.append(st)
	var t := Time.get_ticks_msec() / 1000.0
	for k in _streamers.size():
		var st: Node3D = _streamers[k]
		st.visible = k < m
		if k < m:
			var at := _rope_point(a, b, STREAMER_STEP * float(k + 1) / length)
			st.global_position = at
			st.rotation = Vector3(0, sin(t * 1.3 + k) * 0.17, sin(t * 2.1 + k * 0.7) * 0.31)


## The base on the canvas (the plaza), or flush on the pier's end (Del Mar: "At the end
## of the pier is one of the starting climbing objects"), and the first line from it.
func _place_base() -> void:
	if not is_instance_valid(base_root):
		return
	if not delmar:
		base_root.position = Vector3.ZERO
		first_line = barrel_top + FIRST_LINE_ABOVE
		return
	var right := -INF
	for b in base_bodies:
		for q: Vector3 in ((b.get_child(0) as CollisionShape3D).shape as ConvexPolygonShape3D).points:
			right = maxf(right, q.x)
	base_root.position = Vector3(PIER_END - right, DECK_Y, 0)
	var reach := -INF
	for b in base_bodies:
		for q: Vector3 in ((b.get_child(0) as CollisionShape3D).shape as ConvexPolygonShape3D).points:
			reach = maxf(reach, q.x + q.y + base_root.position.x + base_root.position.y)
	first_line = reach + DELMAR_FIRST_GAP


## Call after set_delmar and set_base: the base moves to (or back from) the pier and the
## line follows.
func place_base() -> void:
	_place_base()
	place_delmar_line(first_line)


## The line's direction (its maths' units): up for the plaza, diagonal for Del Mar.
func line_dir() -> Vector2:
	return Vector2(1, 1) if delmar else Vector2(0, 1)


## A Del Mar fall: any of the climber's pieces in the sea.
func in_sea(c) -> bool:
	if not delmar:
		return false
	for b in c.bodies.values():
		if (b as Node3D).global_position.y < WATER_Y:
			return true
	return false


func _init(id := "dock") -> void:
	row = STAGES.get(id, STAGES.dock)


func build(world: Node3D, dress := true) -> void:
	var half: float = row.deck_half
	# Deck: a long slab, top at y = 0.
	_static_poly(world, PackedVector2Array([Vector2(-half, 0), Vector2(half, 0), Vector2(half, -1.2), Vector2(-half, -1.2)]), 1.0, 2.0)
	# THE PLAZA FLOOR outside the ring (Parker 11-08: "if you hit the ground outside
	# the ring, it says RING OUT!"): the stones the apron drops to, solid, so a
	# climber lands there instead of falling through.
	if str(row.get("dress", "")) == "plaza":
		for sx in [-1.0, 1.0]:
			var x0: float = sx * half
			var x1: float = sx * float(row.side_x)
			var floor := _static_poly(world, PackedVector2Array([Vector2(minf(x0, x1), PLAZA_GROUND), Vector2(maxf(x0, x1), PLAZA_GROUND), Vector2(maxf(x0, x1), PLAZA_GROUND - 1.0), Vector2(minf(x0, x1), PLAZA_GROUND - 1.0)]), 1.0, 2.0)
			floor.set_meta("plaza_floor", true)
	var bs: float = row.barrel_scale
	base_dressed = dress
	set_base(world, base_id)
	if dress:
		if str(row.get("dress", "dock")) == "plaza":
			_dress_plaza(world, half, bs)
		else:
			_dress(world, half, bs)


## Swap only the starting support, leaving the ring and its scenery in place.
func set_base(world: Node3D, selected: String) -> void:
	var chosen := selected if selected in Modes.STARTING_BASES else "barrel"
	if is_instance_valid(base_root) and chosen == base_id:
		return
	for body in base_bodies:
		bodies.erase(body)
	base_bodies.clear()
	if is_instance_valid(base_root):
		base_root.free()
	base_id = chosen
	base_root = Node3D.new()
	base_root.name = "StartingBase"
	world.add_child(base_root)
	if base_id == "barrel":
		var bs: float = row.barrel_scale
		var pts := PackedVector2Array()
		for p in BARREL_PROFILE:
			pts.append(Vector2(-p.x * bs, p.y * bs))
		for i in range(BARREL_PROFILE.size() - 1, -1, -1):
			var p: Vector2 = BARREL_PROFILE[i]
			pts.append(Vector2(p.x * bs, p.y * bs))
		base_bodies.append(_static_poly(base_root, pts, 0.9, 0.6))
		barrel_top = 0.96 * bs
		barrel_half = 0.445 * bs
	elif base_id == "bell" and ResourceLoader.exists(BELL_MODEL_PATH):
		_bell_collision()
	elif base_id == "cactus":
		# The reduced pot and cactus are authored in metres, origin on the canvas.
		# Separate convex pieces preserve the gaps underneath both raised arms.
		var profiles := [
			[Vector2(-0.213,0), Vector2(0.213,0), Vector2(0.296,0.324), Vector2(0.284,0.405), Vector2(-0.284,0.405), Vector2(-0.296,0.324)],
			[Vector2(-0.186,0.315), Vector2(0.186,0.315), Vector2(0.169,1.23), Vector2(0.152,1.61), Vector2(0.125,1.72), Vector2(0.07,1.776), Vector2(0,1.796), Vector2(-0.07,1.776), Vector2(-0.125,1.72), Vector2(-0.152,1.61), Vector2(-0.169,1.23)],
			[Vector2(-0.12,0.71), Vector2(-0.32,0.71), Vector2(-0.50,0.79), Vector2(-0.62,0.96), Vector2(-0.62,1.22), Vector2(-0.60,1.38), Vector2(-0.565,1.44), Vector2(-0.51,1.46), Vector2(-0.455,1.44), Vector2(-0.42,1.38), Vector2(-0.40,1.00), Vector2(-0.32,0.95), Vector2(-0.12,0.95)],
			[Vector2(0.13,0.98), Vector2(0.33,0.98), Vector2(0.49,1.04), Vector2(0.588,1.20), Vector2(0.582,1.44), Vector2(0.56,1.57), Vector2(0.524,1.62), Vector2(0.48,1.635), Vector2(0.436,1.62), Vector2(0.40,1.57), Vector2(0.372,1.24), Vector2(0.33,1.20), Vector2(0.13,1.20)]
		]
		for i in profiles.size():
			for convex in Geometry2D.decompose_polygon_in_convex(PackedVector2Array(profiles[i])):
				base_bodies.append(_static_poly(base_root, convex, 0.9, 0.22 if i == 0 else 0.10))
		barrel_top = 1.796
		barrel_half = 0.62
	else:
		var shape_source: Node3D = DONKEY_MODEL.instantiate()
		barrel_top = 0.0
		barrel_half = 0.0
		# Project the principal mesh volumes onto the gameplay plane. Separate
		# limbs leave the space under the belly open for players to pass through.
		for mesh: MeshInstance3D in shape_source.find_children("*", "MeshInstance3D", true, false):
			var part := str(mesh.name)
			if part == "head":
				donkey_head = mesh.mesh.get_aabb().get_center()
			if part.contains("eye") or part.contains("nostril") or part.contains("inner") or part.contains("hoof_edge") or part.ends_with("_brow") or part.ends_with("_mouth") or part == "dark_mane":
				continue
			var outline := PackedVector2Array()
			for si in mesh.mesh.get_surface_count():
				var points: PackedVector3Array = mesh.mesh.surface_get_arrays(si)[Mesh.ARRAY_VERTEX]
				for point in points:
					outline.append(Vector2(point.x, point.y))
					barrel_top = maxf(barrel_top, point.y)
					barrel_half = maxf(barrel_half, absf(point.x))
			var hull := Geometry2D.convex_hull(outline)
			if hull.size() > 3:
				hull.resize(hull.size() - 1)  # the convex hull repeats its first vertex
				var body := _static_poly(base_root, hull, 0.9, 0.18)
				body.set_meta("donkey_voice", true)
				base_bodies.append(body)
		shape_source.free()
	_place_base()
	if base_dressed:
		var models := {"barrel": BARREL_MODEL, "cactus": CACTUS_MODEL, "donkey": DONKEY_MODEL}
		if base_id == "bell":
			models.bell = load(BELL_MODEL_PATH)
		var visual: Node3D = models[base_id].instantiate()
		base_root.add_child(visual)
		if base_id == "barrel":
			visual.transform = Transform3D(Basis(Vector3.RIGHT, PI * 0.5).scaled(Vector3.ONE * float(row.barrel_scale)), Vector3.ZERO)
		CelPass.celify(visual)
		bell_node = visual.find_child("bell", true, false) as Node3D if base_id == "bell" else null
		if base_id == "bell":
			LuchaKit.smooth_normals(visual.find_child("bell_body", true, false) as MeshInstance3D)  # the bell, smooth (Parker 11-10)


## THE BELL'S COLLISION: each non-deco_ mesh's outline at the plane, one convex hull
## each (as the donkey's). The bell_body hull carries meta bell_ring: a limb that sticks
## to it rings the bell (Game).
func _bell_collision() -> void:
	var src: Node3D = (load(BELL_MODEL_PATH) as PackedScene).instantiate()
	barrel_top = 0.0
	barrel_half = 0.0
	for mesh: MeshInstance3D in src.find_children("*", "MeshInstance3D", true, false):
		var part := str(mesh.name)
		if part.begins_with("deco_") or part == "bell":
			continue  # dressing, and the `bell` node's 1 cm placeholder cube inside the crown
		var xf := Transform3D.IDENTITY
		var cur: Node = mesh
		while cur != null and cur != src:
			xf = (cur as Node3D).transform * xf
			cur = cur.get_parent()
		var outline := PackedVector2Array()
		for si in mesh.mesh.get_surface_count():
			for v: Vector3 in mesh.mesh.surface_get_arrays(si)[Mesh.ARRAY_VERTEX]:
				var w := xf * v
				outline.append(Vector2(w.x, w.y))
				barrel_top = maxf(barrel_top, w.y)
				barrel_half = maxf(barrel_half, absf(w.x))
		var hull := Geometry2D.convex_hull(outline)
		if hull.size() > 3:
			hull.resize(hull.size() - 1)  # the hull repeats its first point
			var body := _static_poly(base_root, hull, 0.9, 0.3)
			if part == "bell_body":
				body.set_meta("bell_ring", true)
			base_bodies.append(body)
	src.free()


## Ring the bell: the pulse (the sound is Game's, at the contact).
func pulse_bell() -> void:
	if bell_node == null or not is_instance_valid(bell_node):
		return
	if bell_node.has_meta("tween"):
		var old: Tween = bell_node.get_meta("tween")
		if old != null and old.is_valid():
			old.kill()
	bell_node.scale = Vector3.ONE
	var tw := bell_node.create_tween()
	tw.tween_property(bell_node, "scale", Vector3.ONE * BELL_PULSE, 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(bell_node, "scale", Vector3.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	bell_node.set_meta("tween", tw)


func spawn_point(side: int) -> Vector2:
	if delmar:
		# Next to each other towards the pier's end, 3 m apart (Parker).
		return Vector2(PIER_END - float(SPAWN_BACK[0 if side > 0 else 1]), DECK_Y + 0.05)
	return Vector2(float(row.spawn_x) * (1.0 if side > 0 else -1.0), 0.05)


## THE ROPE BOUNCE (Parker 11-08: "the ropes need to have a bouncing animation when
## they bounce you"): the side's ropes are knocked outward by the hit, then spring
## back with an elastic wobble. side: -1 left, +1 right; speed: the hit (m/s).
func bounce_rope(side: float, speed: float) -> void:
	if ring_kit == null or not is_instance_valid(ring_kit):
		return
	var rope := ring_kit.find_child("ring_ropes_right" if side > 0.0 else "ring_ropes_left", true, false) as MeshInstance3D
	if rope == null or rope.mesh == null:
		return
	# THE FLEX (Parker 11-08: "the middle needs to flex but the sides connected to
	# the posts should stay connected to the posts"): the rope's own mesh bends on a
	# sine along its length, zero at both posts, most in the middle. The rest mesh
	# is kept; the bent one is rebuilt each frame of the spring only.
	if not rope.has_meta("rest_mesh"):
		rope.set_meta("rest_mesh", rope.mesh)
		var mats: Array = []
		for si in rope.mesh.get_surface_count():
			mats.append(rope.get_surface_override_material(si))
		rope.set_meta("rest_mats", mats)
	# One voice per side, owned by the rope so teardown also stops playback.
	var voice := rope.get_node_or_null("TensionSound") as AudioStreamPlayer3D
	if voice == null:
		voice = AudioStreamPlayer3D.new()
		voice.name = "TensionSound"
		voice.bus = "Effects"
		voice.unit_size = 6.0
		voice.max_db += linear_to_db(2.0)
		rope.add_child(voice)
	var choices: Array = Sound.SFX["rope"].duplicate()
	choices.erase(rope.get_meta("last_creak", ""))
	var clip: String = choices.pick_random()
	rope.set_meta("last_creak", clip)
	voice.stop()
	voice.stream = Sound._streams.get(clip)
	voice.volume_db = -80.0
	voice.position = Vector3(0.0, 0.95, 0.0)
	rope.set_meta("creak_gain", 2.0 * clampf(speed / 4.0, 0.5, 1.6))
	if voice.stream != null:
		voice.play()
	var push := clampf(speed * 0.06, 0.08, 0.4)
	rope.set_meta("peak_flex", push)
	if rope.has_meta("tween"):
		var old: Tween = rope.get_meta("tween")
		if old != null and old.is_valid():
			old.kill()
	var flex := func(a: float) -> void: _flex_rope(rope, side * a)
	var tw := rope.create_tween()
	tw.tween_method(flex, 0.0, push, 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_method(flex, push, 0.0, 0.7).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func() -> void: _rest_rope(rope))
	rope.set_meta("tween", tw)


## Bend a side rope's mesh out by `dx` at its middle (sine along local z, the
## rope's length, so its ends at the posts don't move).
func _flex_rope(rope: MeshInstance3D, dx: float) -> void:
	var voice := rope.get_node_or_null("TensionSound") as AudioStreamPlayer3D
	if voice != null:
		# Follow actual deformation, including the rebound; silence at rest.
		var stretch := clampf(absf(dx) / float(rope.get_meta("peak_flex", 0.4)), 0.0, 1.0)
		voice.volume_db = linear_to_db(maxf(0.0001, stretch * float(rope.get_meta("creak_gain", 1.0))))
	var rest: Mesh = rope.get_meta("rest_mesh")
	var bb := rest.get_aabb()
	var z0 := bb.position.z
	var span := maxf(bb.size.z, 0.001)
	var bent := ArrayMesh.new()
	for si in rest.get_surface_count():
		var arrays := rest.surface_get_arrays(si)
		var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var out := PackedVector3Array()
		out.resize(verts.size())
		for k in verts.size():
			var v := verts[k]
			v.x += dx * sin(PI * clampf((v.z - z0) / span, 0.0, 1.0))
			out[k] = v
		arrays[Mesh.ARRAY_VERTEX] = out
		bent.add_surface_from_arrays(rest.surface_get_primitive_type(si), arrays)
		bent.surface_set_material(si, rest.surface_get_material(si))
	rope.mesh = bent
	_rope_mats(rope)


func _rest_rope(rope: MeshInstance3D) -> void:
	if is_instance_valid(rope) and rope.has_meta("rest_mesh"):
		var voice := rope.get_node_or_null("TensionSound") as AudioStreamPlayer3D
		if voice != null:
			voice.stop()
		rope.mesh = rope.get_meta("rest_mesh")
		_rope_mats(rope)


func _rope_mats(rope: MeshInstance3D) -> void:
	var mats: Array = rope.get_meta("rest_mats", [])
	for si in mini(mats.size(), rope.mesh.get_surface_count()):
		if mats[si] != null:
			rope.set_surface_override_material(si, mats[si])


## The ring's half-width (the side ropes stand at +-this).
func ring_half() -> float:
	return float(row.deck_half)


## RING OUT: is this climber down on the plaza floor outside the ring? (Its lowest
## piece near the stones, beyond the apron.) Works on live bodies and puppets.
func ring_out(c) -> bool:
	if delmar:
		return false  # the sea is Del Mar's floor (in_sea)
	if str(row.get("dress", "")) != "plaza":
		return false
	for b in c.bodies.values():
		var p: Vector3 = (b as Node3D).global_position
		if absf(p.x) > float(row.deck_half) and p.y < PLAZA_GROUND + 0.25:
			return true
	return false


func out_of_bounds(p: Vector2) -> bool:
	if delmar:
		return p.y < WATER_Y - 3.0 or p.x < PIER_ROOT - 10.0 or p.x > PIER_END + 80.0
	return p.y < float(row.kill_y) or absf(p.x) > float(row.side_x)


## A solid whose outline at the play plane is `pts` (y-up metres), extruded
## through the plane by +-depth so what you see at z = 0 is what you touch.
func _static_poly(world: Node3D, pts: PackedVector2Array, friction: float, depth: float) -> StaticBody3D:
	var sb := StaticBody3D.new()
	var col := CollisionShape3D.new()
	var cv := ConvexPolygonShape3D.new()
	var p3 := PackedVector3Array()
	for p in pts:
		p3.append(Vector3(p.x, p.y, -depth))
		p3.append(Vector3(p.x, p.y, depth))
	cv.points = p3
	col.shape = cv
	sb.add_child(col)
	sb.collision_layer = 1
	sb.collision_mask = 0
	var mat := PhysicsMaterial.new()
	mat.friction = friction
	sb.physics_material_override = mat
	sb.set_meta("stage", true)
	world.add_child(sb)
	bodies.append(sb)
	return sb


# ---------------------------------------------------------------- dressing

func _dress(vis: Node3D, half: float, bs: float) -> void:
	var root := Node3D.new()
	root.name = "StageDressing"
	vis.add_child(root)
	# The barrel: the file stands it along -z; tip it upright (+90 deg about x).
	# The deck: planks across the play plane, deep enough to read as 3D.
	var wood := _mat(Color(0.47, 0.32, 0.2), 0.85)
	var wood_dark := _mat(Color(0.36, 0.24, 0.15), 0.9)
	var n := int(ceil(half * 2.0 / 0.32))
	for i in n:
		var x := -half + 0.16 + i * 0.32
		var plank := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.3, 0.12, 4.0)
		plank.mesh = bm
		plank.material_override = wood if i % 3 != 1 else wood_dark
		plank.position = Vector3(x, -0.06 - (i % 2) * 0.006, -0.6)
		root.add_child(plank)
	# Beams and posts under the deck, into the sea.
	for side in [-1.0, 1.0]:
		var beam := MeshInstance3D.new()
		var bb := BoxMesh.new()
		bb.size = Vector3(half * 2.0, 0.26, 0.26)
		beam.mesh = bb
		beam.material_override = wood_dark
		beam.position = Vector3(0, -0.25, -0.6 + side * 1.6)
		root.add_child(beam)
	for i in range(-4, 5):
		for z in [1.0, -2.2]:
			var post := MeshInstance3D.new()
			var cm := CylinderMesh.new()
			cm.top_radius = 0.16
			cm.bottom_radius = 0.18
			cm.height = 3.2
			post.mesh = cm
			post.material_override = wood_dark
			post.position = Vector3(i * half / 4.0, -1.6, z)
			root.add_child(post)
	# A few crates and a coil of rope at the back, off the play plane.
	var crate_m := _mat(Color(0.55, 0.4, 0.24), 0.8)
	for c in [[-6.8, 0.5, -1.6, 1.0], [-5.9, 0.35, -1.9, 0.7], [7.2, 0.45, -1.7, 0.9], [-6.6, 1.35, -1.7, 0.7]]:
		var crate := MeshInstance3D.new()
		var cb := BoxMesh.new()
		cb.size = Vector3.ONE * c[3]
		crate.mesh = cb
		crate.material_override = crate_m
		crate.position = Vector3(c[0], c[1], c[2])
		crate.rotation.y = c[0] * 0.3
		root.add_child(crate)
	# The sea.
	var sea := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(400, 400)
	sea.mesh = pm
	CelPass.paint(sea, Color(0.2, 0.45, 0.6))
	sea.position = Vector3(0, -1.5, 0)
	root.add_child(sea)
	# Far islands for depth.
	var rock := _mat(Color(0.42, 0.45, 0.4), 1.0)
	var grass := _mat(Color(0.33, 0.52, 0.28), 1.0)
	for isl in [[-40.0, -90.0, 14.0], [25.0, -120.0, 22.0], [70.0, -160.0, 30.0], [-95.0, -150.0, 26.0]]:
		var m := MeshInstance3D.new()
		var sp := SphereMesh.new()
		sp.radius = isl[2]
		sp.height = isl[2] * 0.9
		m.mesh = sp
		m.material_override = grass
		m.position = Vector3(isl[0], -1.5, isl[1])
		root.add_child(m)
		var b := MeshInstance3D.new()
		var cy := CylinderMesh.new()
		cy.top_radius = isl[2] * 0.95
		cy.bottom_radius = isl[2] * 1.05
		cy.height = 3.0
		b.mesh = cy
		b.material_override = rock
		b.position = Vector3(isl[0], -2.0, isl[1])
		root.add_child(b)


## Dressing built in code is born cel (the house look); the ink outlines it.
## The plaza ring: a raised stage with a star-painted apron skirt, a canvas floor,
## padded corner posts with turnbuckles, red / white / blue ropes along the back and
## the sides (none across the front, the camera's side), the barrel in the middle,
## and plaza stones all round. The kit's `ring` replaces the ring when delivered.
func _dress_plaza(vis: Node3D, half: float, bs: float) -> void:
	var root := Node3D.new()
	root.name = "PlazaRing"
	vis.add_child(root)
	var kit := LuchaKit.kit_model("ring")
	var depth := 3.4  # shallow: the front apron must stay out of the camera's lower frame
	var gy := PLAZA_GROUND
	if kit != null:
		# Built at the stage's size (18 x 3.42 m, canvas top at y 0, origin its
		# centre, apron dropping 0.9 m): it goes in at scale 1.
		root.add_child(kit)
		ring_kit = kit
		# The gold knobs on the corner posts, smooth (Parker 11-10): each post's knob is
		# the part above 2.5 m.
		for post in ["ring_post_bl", "ring_post_br", "ring_post_fl", "ring_post_fr"]:
			LuchaKit.smooth_normals(kit.find_child(post, true, false) as MeshInstance3D, func(v: Vector3) -> bool: return v.y >= 2.5)
		# The canvas in a mid warm grey: the kit's near-white read pure white in
		# the sun and swallowed the climber's pale legs (environment pass 11-08).
		var canvas := kit.find_child("ring_canvas", true, false) as MeshInstance3D
		if canvas != null:
			CelPass.paint(canvas, CANVAS)
	else:
		var w := half * 2.0
		# The stage block and its skirt panels, then the canvas and its rim.
		# The stage block stops under the canvas (its top showed as a dark strip).
		root.add_child(_boxm(Vector3(w + 0.3, -gy - 0.12, depth + 0.3), LuchaKit.INK, Vector3(0, (gy - 0.12) * 0.5, 0)))
		var skirt := [LuchaKit.BLUE, LuchaKit.RED, LuchaKit.BLUE, LuchaKit.RED, LuchaKit.BLUE, LuchaKit.RED]
		for k in skirt.size():
			var pw := w / skirt.size()
			var panel := _boxm(Vector3(pw - 0.04, -gy - 0.12, 0.06), skirt[k], Vector3(-half + pw * (k + 0.5), gy * 0.5, depth * 0.5 + 0.17))
			root.add_child(panel)
			var star := LuchaKit.star_mesh(0.28, LuchaKit.GOLD)
			star.position = Vector3(-half + pw * (k + 0.5), gy * 0.5, depth * 0.5 + 0.3)
			root.add_child(star)
		root.add_child(_boxm(Vector3(w, 0.08, depth), Color(0.74, 0.77, 0.82), Vector3(0, -0.04, 0)))  # canvas, toned down (it glared white)
		root.add_child(_boxm(Vector3(w + 0.36, 0.14, 0.18), LuchaKit.CREAM, Vector3(0, -0.02, depth * 0.5 + 0.06)))
		root.add_child(_boxm(Vector3(w + 0.36, 0.14, 0.18), LuchaKit.CREAM, Vector3(0, -0.02, -depth * 0.5 - 0.06)))
		# Corner posts, turnbuckle pads and the ropes.
		var pz := depth * 0.5 - 0.1
		var post_h := 1.75
		var corners := [Vector2(-half, -pz), Vector2(half, -pz), Vector2(-half, pz), Vector2(half, pz)]
		for c in corners:
			var post := LuchaKit.cyl(0.11, post_h, LuchaKit.SILVER, Vector3(c.x, post_h * 0.5, c.y))
			root.add_child(post)
			for k in 3:
				var pad := LuchaKit.box(Vector3(0.3, 0.22, 0.3), [LuchaKit.RED, LuchaKit.CREAM, LuchaKit.BLUE][k], Vector3(c.x, 0.5 + k * 0.45, c.y))
				root.add_child(pad)
		# Ring ropes in blue and white, thin: never red, which is the height line's colour.
		var ropes := [LuchaKit.BLUE, LuchaKit.CREAM, LuchaKit.BLUE]
		for k in 3:
			var y := 0.5 + k * 0.45
			root.add_child(LuchaKit.cyl(0.022, half * 2.0, ropes[k], Vector3(0, y, -pz), Vector3.RIGHT))
			for sx in [-1.0, 1.0]:
				root.add_child(LuchaKit.cyl(0.022, pz * 2.0, ropes[k], Vector3(sx * half, y, 0), Vector3.BACK))
		# Ring steps at one corner.
		for k in 3:
			root.add_child(_boxm(Vector3(1.2, 0.36, 0.6), Color(0.3, 0.3, 0.34), Vector3(half + 0.8, gy + 0.18 + k * 0.36, pz - 0.3 - k * 0.6)))
	# The stones under the ring's stage only: the round plaza, its pavements and
	# streets are LuchaUI's (the town in the round, 11-08), and a big slab here
	# showed as a pale rectangle past the plaza's edge.
	root.add_child(_boxm(Vector3(20.0, 0.3, 4.6), Color(0.82, 0.72, 0.56), Vector3(0, gy - 0.16, 0.0)))
	# (The paving over the stones is LuchaUI._pave: the street, the kerb and the square.)


func _boxm(size: Vector3, c: Color, at: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	CelPass.paint(mi, c)
	mi.position = at
	return mi


func _mat(c: Color, _rough: float) -> ShaderMaterial:
	return CelPass.cel_material(c)
