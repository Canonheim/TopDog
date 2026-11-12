@tool
extends Node3D
## Default for new maps (2026-09-12): scenes/effects/flame_metaball_3d.tscn.
## This controller also supports the older particle candidates. The 3D fire
## uses the accepted rotating, independently breathing three-lobe volume.
## FIRE (Parker 2026-07-11): a drag-and-drop flame — particles for the
## dancing fire, a few rising sparks, and a warm FLICKERING light. Drop
## scenes/effects/fire.tscn anywhere (a map, a menu room, on top of a
## stick) and it burns. Scale the node to size the whole fire. The light
## deliberately casts NO shadows — shadowless warm lights are cheap, so
## twenty fires cost almost nothing; the flicker is what sells it.
## TOON PASS (Parker 2026-07-14, the cartoon-sea art reference): the flame
## gradient runs CONSTANT interpolation now — three solid bands (pale
## core / orange / deep ember) that POP out instead of fading — on ten
## big alpha-blended shapes instead of 26 small additive wisps, with the
## turbulence calmed to a hand-drawn wobble. The ground pool banding
## comes free from the cel materials; this light never changed.
## ANY-COLOR FIRE (Parker 2026-07-24, on fire_old: "make any color fire
## and have it glow that color"): the Fire Color picker below recolors
## the WHOLE flame — every gradient stop keeps its role (pale core, body,
## dark ember edge, fade-out) but plays it in the chosen hue, and the
## glow light follows. Left at the stock orange = the classic flame,
## untouched. @tool so the color shows live in the editor viewport.
## Per-INSTANCE: materials and ramps duplicate before recoloring, so two
## fires on one map burn two different colors happily. THE LAW that makes
## that true (learned the hard way 2026-07-26, see _own_flame_materials):
## a recolor may only ever write through a NODE-level slot — process_material,
## a duplicated draw-pass mesh, a surface override, material_override. A .tscn
## sub-resource is SHARED by every instance of that scene, so writing one
## repaints every fire on the map. Battery: `--fire`.

# The stock flame's base — leaving the picker here keeps the original
# look bit-for-bit (no recolor runs at all)
const STOCK_COLOR := Color(1.0, 0.6, 0.16)

@export var fire_color := STOCK_COLOR:
	set(v):
		fire_color = v
		if is_inside_tree():
			_apply_color()
@export var light_energy := 1.6   # the glow's resting brightness
@export var flicker := 0.25       # how far the flame wanders off it (0..1)
# THE FAR FIRE (Parker 2026-09-19, "at a little distance, fire doesn't
# draw in front of the ocean"): the 3D flame fades out over the last
# fifth of this reach and is culled at it (flame_metaball_3d: ALPHA *=
# 1 - smoothstep(0.8 * d, d, camera_distance); visibility_range_end =
# d) -- at the old 80 m the beach fire went out from the hilltop while
# its stone ring stayed, and the sea behind it took the blame. 200 m
# spans the hub island; a far flame is a few pixels of raymarch, cheap.
@export_range(20.0, 600.0, 1.0) var draw_distance := 200.0 # scaled landmark flames may stay visible farther away
@export var glow_range := 6.0     # m the light pool reaches
# THE UPRIGHT FLAME (Parker 2026-10-30: "metaball fires attached to props are not pointing up as the item flips
# around and flies and stuff ... It should stay pointing up as well as it can in general, more natural looking"): a
# flame riding a prop (fighter.attach_world_fire's world brazier, _tool_flame's torch and carried brazier) keeps its
# anchor on the item but its up on the sky, leaning back a little from its own motion as a real flame trails. Off
# by default: a fire stood in a map keeps the pose it was authored in.
@export var stay_upright := false
const UPRIGHT_LEAN_PER_MPS := 0.06   # rad the flame trails per m/s of sideways speed
const UPRIGHT_LEAN_MAX := 0.55       # rad (~32 deg): the most it ever leans
const UPRIGHT_LEAN_RATE := 10.0      # 1/s: how fast the lean catches up with the motion
var _upright_last := Vector3.INF
var _upright_lean := Vector3.ZERO    # the lean as axis * angle, smoothed

@onready var glow: OmniLight3D = $Glow

# Three unsynced sine waves stack into a natural-looking wander — cheap,
# deterministic-free (each fire starts at a random phase so a row of
# torches never pulses in unison).
var _t := randf() * 100.0


func _ready() -> void:
	# THE GLIM (THE HAUL Run 5, §11.0's shared systems): a lit fire joins the light registry the creatures read
	# (THE RAT TIDE parts around it and burns in it); runtime only (@tool). An unlit one (THE SCONCES, Run 9:
	# meta glim_dark) waits for its ledger's `lit` (haul_kit._on_light_gate)
	if not Engine.is_editor_hint() and not bool(get_meta("glim_dark", false)):
		add_to_group("haul_fire")
	glow.light_energy = light_energy
	glow.omni_range = glow_range
	_apply_color()
	var volume := get_node_or_null("Flames") as MeshInstance3D
	if volume != null and volume.material_override is ShaderMaterial:
		volume.material_override = volume.material_override.duplicate()
		(volume.material_override as ShaderMaterial).set_shader_parameter("draw_distance", draw_distance)
		volume.visibility_range_end = draw_distance


func _process(delta: float) -> void:
	_t += delta
	var wander := sin(_t * 9.0) * 0.5 + sin(_t * 23.0 + 1.7) * 0.35 \
			+ sin(_t * 41.0 + 4.2) * 0.15
	glow.light_energy = light_energy * (1.0 + flicker * wander)
	# the glow's heart sways a whisker — walls breathe with the flame
	glow.position.x = 0.03 * sin(_t * 13.0)
	glow.position.z = 0.03 * sin(_t * 17.0 + 2.0)
	if stay_upright and not Engine.is_editor_hint():
		_hold_upright(delta)


## THE UPRIGHT FLAME's frame: the world basis rebuilt from the sky's up (the scale kept), tilted by the smoothed lean
## away from the flame's sideways motion; the origin stays where the prop carries it.
func _hold_upright(delta: float) -> void:
	var at := global_position
	var want := Vector3.ZERO
	if _upright_last != Vector3.INF and delta > 0.0:
		var v := (at - _upright_last) / delta
		var side := Vector3(v.x, 0.0, v.z)
		if side.length() > 0.05:
			want = Vector3.UP.cross(-side.normalized()).normalized() 					* minf(side.length() * UPRIGHT_LEAN_PER_MPS, UPRIGHT_LEAN_MAX)
	_upright_last = at
	_upright_lean = _upright_lean.lerp(want, 1.0 - exp(-UPRIGHT_LEAN_RATE * delta))
	var sc := global_basis.get_scale()
	var k := (absf(sc.x) + absf(sc.y) + absf(sc.z)) / 3.0
	var tilt := Basis(_upright_lean.normalized(), _upright_lean.length()) if _upright_lean.length() > 0.0001 else Basis()
	global_basis = tilt.scaled(Vector3.ONE * k)


## Recolor flames + sparks + glow to fire_color. Each existing gradient
## stop is read as a TEMPLATE — how bright it is (value) and how pale it
## is (whiteness) — and rebuilt in the chosen hue, so fire_old's smooth
## ramp and fire's toon bands each keep their own character. Stock color
## = no-op: the authored scene ramps render exactly as saved.
func _apply_color() -> void:
	if glow == null:
		return
	var stock := fire_color.is_equal_approx(STOCK_COLOR)
	# THE AUTHORED GLOW (2026-09-11, the metaball braziers join the
	# family): a stock fire keeps whatever light colour its scene
	# authored — fire.tscn's (1, 0.58, 0.22), the brazier's deeper
	# (1, 0.39, 0.1) — cached on first touch so a recolour can return
	if not glow.has_meta("stock_light"):
		glow.set_meta("stock_light", glow.light_color)
	glow.light_color = glow.get_meta("stock_light") if stock else fire_color
	_color_shader_flames()
	for pname in ["Flames", "Sparks"]:
		var part := get_node_or_null(pname) as GPUParticles3D
		if part == null or not part.process_material is ParticleProcessMaterial:
			continue
		# THE PRISTINE TEMPLATE (review catch, 2026-07-24): the scene's
		# authored material is cached on first touch and every recolor
		# cooks FROM IT — recoloring from the current (already-recolored)
		# ramp compounded per picker tick and degraded the flame, and
		# stock could never truly return. Stock now restores it whole.
		if not part.has_meta("stock_pm"):
			part.set_meta("stock_pm", part.process_material)
		var stock_pm := part.get_meta("stock_pm") as ParticleProcessMaterial
		if stock:
			part.process_material = stock_pm
			continue
		if stock_pm.color_ramp == null \
				or not stock_pm.color_ramp is GradientTexture1D:
			continue
		var src: Gradient = (stock_pm.color_ramp as GradientTexture1D).gradient
		if src == null:
			continue
		# per-instance copies — a shared subresource would repaint every
		# fire on the map at once
		var pm := stock_pm.duplicate() as ParticleProcessMaterial
		var tex: GradientTexture1D = stock_pm.color_ramp.duplicate()
		var g: Gradient = src.duplicate()
		for i in g.get_point_count():
			var c := g.get_color(i)
			var v := maxf(c.r, maxf(c.g, c.b))          # template brightness
			var w := (minf(c.r, minf(c.g, c.b)) / v) if v > 0.0 else 0.0  # paleness
			var out := fire_color.lerp(Color.WHITE, w * 0.85).darkened(1.0 - v)
			out.a = c.a  # the fade-out belongs to the template
			g.set_color(i, out)
		tex.gradient = g
		pm.color_ramp = tex
		part.process_material = pm


## THE SHADER FLAMES (2026-07-26): the cel candidates in
## scenes/effects/flame_*.tscn draw their flame procedurally in a
## ShaderMaterial instead of tinting quads through a ParticleProcessMaterial
## ramp, so the gradient recolor above cannot reach them — each exposes ONE
## `flame_color` uniform and derives its own core/body/ember/ink from it.
## Walked generically (any mesh under this Fire, particle draw pass or
## plain MeshInstance3D — flame_bands draws its whole flame as one mesh),
## so a new candidate works the day it is dropped in with no edit here.
func _color_shader_flames() -> void:
	# STOCK FIRES STAY PRISTINE (2026-07-29 sweep): a stock-colored fire
	# used to localize (duplicate) every candidate's mesh + material in
	# _ready anyway — per-torch private copies for zero visual change,
	# and (this is a @tool) the duplicated sub-resources could bake into
	# a map save. Only a fire actually recolored owns its materials; a
	# fire RETURNING to stock still repaints its owned copies below.
	if fire_color.is_equal_approx(STOCK_COLOR) and not _any_flames_owned():
		return
	for child in get_children():
		for mat in _own_flame_materials(child):
			var m := mat as ShaderMaterial
			var a: float = float(m.get_shader_parameter("flame_color").a) \
					if m.get_shader_parameter("flame_color") != null else 1.0
			m.set_shader_parameter("flame_color",
					Color(fire_color.r, fire_color.g, fire_color.b, a))


## Every flame ShaderMaterial under `child` that THIS Fire owns outright,
## localizing them on the first call.
##
## THE SHARED SUB-RESOURCE TRAP (Parker 2026-07-26: "When I changed the new
## Flame Ember to green, all my fires turned green. Not the glow... but the
## old fire I could make the particles green and the glow green and it would
## not affect the other fires at all"). A .tscn's sub-resources — here the
## draw-pass QuadMesh and the ShaderMaterial inside it — are SHARED by every
## instance of that scene unless the resource is flagged local-to-scene. The
## first cut duplicated the material but then handed it back through
## `mesh.surface_set_material()`, i.e. wrote it onto the shared mesh: fire A
## replaced the material every other ember fire reads, so B found A's copy,
## saw it already flagged, and painted into it. One material, one colour, the
## last write winning. The glow stayed per-fire because `light_color` is a
## NODE property — and that is exactly why fire_old never showed the bug: its
## recolor assigns `process_material`, also a node property.
##
## THE LAW: recolor only ever writes through a NODE-level slot. A duplicated
## draw-pass mesh (`draw_pass_N` is a node property), a surface override, or
## `material_override` — never back into a resource the scene file owns.
func _any_flames_owned() -> bool:
	for child in get_children():
		if child.has_meta("flame_own"):
			return true
	return false


func _own_flame_materials(child: Node) -> Array:
	var out: Array = []
	var owned: bool = child.has_meta("flame_own")
	if child is GPUParticles3D:
		var gp := child as GPUParticles3D
		for i in gp.draw_passes:
			var mesh := gp.get_draw_pass_mesh(i)
			if mesh == null or mesh.get_surface_count() == 0:
				continue
			var mat = mesh.surface_get_material(0)
			if not _is_flame_material(mat):
				continue
			if not owned:
				# the MESH is the shared thing, so it is duplicated too and
				# parked on this node's own draw-pass slot
				var my_mesh := mesh.duplicate() as Mesh
				mat = (mat as ShaderMaterial).duplicate()
				my_mesh.surface_set_material(0, mat)
				gp.set_draw_pass_mesh(i, my_mesh)
			out.append(mat)
	elif child is MeshInstance3D:
		var mi := child as MeshInstance3D
		# material_override WINS over surface overrides, so a flame wearing
		# one has to be re-seated there or the recolor would go nowhere
		if _is_flame_material(mi.material_override):
			var mo := mi.material_override as ShaderMaterial
			if not owned:
				mo = mo.duplicate() as ShaderMaterial
				mi.material_override = mo
			out.append(mo)
		else:
			var src = mi.get_surface_override_material(0)
			if not _is_flame_material(src):
				src = mi.mesh.surface_get_material(0) if mi.mesh != null \
						and mi.mesh.get_surface_count() > 0 else null
			if _is_flame_material(src):
				if not owned:
					src = (src as ShaderMaterial).duplicate()
					mi.set_surface_override_material(0, src)
				out.append(src)
	if not out.is_empty():
		child.set_meta("flame_own", true)
	return out


## Does this material actually take a flame_color? (a candidate that names
## it something else is simply left alone rather than silently ignored)
func _is_flame_material(mat) -> bool:
	if not (mat is ShaderMaterial) or (mat as ShaderMaterial).shader == null:
		return false
	for p in (mat as ShaderMaterial).shader.get_shader_uniform_list():
		if str(p.get("name", "")) == "flame_color":
			return true
	return false
