extends Node3D
## Transient highest-surface cosmetic; no gameplay bodies, lights or forces.
const Layout = preload("res://climber/body_layout.gd")
const MARKER := "lightning_lock_played"
const STAGGER := .32
const FLASH_SECONDS := .22
const TOTAL_SECONDS := 1.65
const FORM_SECONDS := .28
const STRIKE_START := .38
const CLOUD_HEIGHT := 1.0
const RAIN_COUNT := 24
const STRIKE_COUNT := 3
const CLOUD_COUNT := 5
const PREPARATION_UNITS := 41
const CLOUD_PUFFS := [[Vector3(0,-.04,0),Vector3(.53,.19,.28)],[Vector3(-.43,.03,0),Vector3(.22,.21,.24)],[Vector3(-.25,.16,.01),Vector3(.27,.29,.25)],[Vector3(.03,.24,-.01),Vector3(.30,.34,.27)],[Vector3(.31,.13,0),Vector3(.25,.27,.24)],[Vector3(.49,.01,.02),Vector3(.18,.18,.21)],[Vector3(-.25,.01,.19),Vector3(.23,.20,.21)],[Vector3(.04,.09,.22),Vector3(.24,.24,.22)],[Vector3(.29,-.01,.18),Vector3(.23,.18,.19)]]
static var cloud_mesh: ArrayMesh
static var rain_mesh: ArrayMesh
const CLOUD_POSITIONS := [Vector3(-.35,.97,.03),Vector3(0,1.13,0),Vector3(.35,1.00,.02),Vector3(-.72,1.10,-.25),Vector3(.70,1.18,-.28)]
const CLOUD_SIZES := [.42*1.60,.62*1.60,.34*1.60,.58,.46]
const CLOUD_OPACITY := .85
const CLOUD_DRIFT := [Vector3(-.30,.10,.02),Vector3(.10,.16,0),Vector3(.32,.04,-.02),Vector3(-.35,.12,-.04),Vector3(.34,.10,-.05)]
const weather_material: ShaderMaterial = preload("res://ui3d/lightning_weather.tres")
var clouds: Array[MeshInstance3D] = []
var rain: MultiMeshInstance3D
var cloud_sources: Array[Vector3] = []
var rain_offsets: Array[Vector3] = []
var tracked_skin: Array[MeshInstance3D] = []
var target_records := {}
var owner_ref: WeakRef
var target_mesh: MeshInstance3D
var target_local := Vector3.ZERO
const VARIANTS := 6
static var meshes: Array[ArrayMesh] = []
static var vertex_cache := {}
static var pending_meshes := {}
static var preparation_errors := {}
const material: ShaderMaterial = preload("res://ui3d/lightning_material.tres")
var bolts: Array[MeshInstance3D] = []
var age := 0.0
var impact := Vector3.ZERO
var strikes_started := 0
var launched := [false,false,false]

# One shared palette/material job, six mesh jobs, then one skin part per job.
static func prepare_unit(index: int) -> bool:
	if index == 39 or index == 40:
		var path := "res://kit/effects/prepared/lightning_cloud.res" if index==39 else "res://kit/effects/prepared/lightning_rain.res"
		if not ResourceLoader.exists(path):
			preparation_errors[path] = "Missing weather mesh bake"
			return true
		if index==39 and cloud_mesh==null: cloud_mesh = load(path)
		if index==40 and rain_mesh==null: rain_mesh = load(path)
		return true
	if index == 0:
		# Both shared materials/textures are preloaded with this script. Atlas
		# UVs are already baked: no unused CelPass material or swatch search.
		return true
	if index <= VARIANTS:
		return prepare_mesh_unit(index-1)
	var part_index := index-VARIANTS-1
	var scene: PackedScene = Wardrobe.PUG if part_index<Layout.ORDER.size() else Wardrobe.SPIRAL
	var name: String = Layout.PIECES[Layout.ORDER[part_index%Layout.ORDER.size()]].mesh
	var state := scene.get_state()
	var path := "res://kit/effects/lightning_vertices/part_%02d.bin" % part_index
	var saved: Dictionary = {}
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path,FileAccess.READ)
		saved = file.get_var()
	else:
		preparation_errors[path] = "Missing skin vertex bake"
		push_warning("Missing Lightning vertex bake: "+path)
	# Read shared imported mesh resources without constructing a whole skin tree.
	for node_index in state.get_node_count():
		var node_path := str(state.get_node_path(node_index))
		if not name in node_path.split("/"): continue
		for property_index in state.get_node_property_count(node_index):
			if state.get_node_property_name(node_index,property_index)=="mesh":
				var mesh = state.get_node_property_value(node_index,property_index)
				if mesh is Mesh:
					if saved.has(node_path): vertex_cache[mesh] = saved[node_path]
					else: vertices(mesh)

	return true

static func mesh_path(index: int) -> String:
	return "res://kit/effects/prepared/lightning_%02d.res" % index

## The preparer clears this while its loads in flight are at their cap; live
## callers keep it true. A slow load is still pending, never a failure.
static var request_allowed := true
static var draining := false

static func prepare_mesh_unit(index: int) -> bool:
	if meshes.is_empty(): meshes.resize(VARIANTS)
	var path := mesh_path(index)
	if pending_meshes.has(index):
		# Collect our own ticket even if a live burst already loaded this mesh.
		var status := ResourceLoader.load_threaded_get_status(path)
		if status==ResourceLoader.THREAD_LOAD_IN_PROGRESS: return false
		pending_meshes.erase(index)
		if status==ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			if meshes[index]==null: preparation_errors[path] = "Mesh load failed"
			return true
		var loaded = ResourceLoader.load_threaded_get(path)
		if meshes[index]==null:
			if loaded is ArrayMesh: meshes[index] = loaded
			else: preparation_errors[path] = "Mesh load failed"
		return true
	if meshes[index] != null: return true
	if not ResourceLoader.exists(path):
		preparation_errors[path] = "Missing bolt mesh bake"
		return true
	if draining or not request_allowed: return false
	if ResourceLoader.load_threaded_request(path,"ArrayMesh")!=OK:
		preparation_errors[path] = "Mesh request failed"
		return true
	pending_meshes[index] = Time.get_ticks_msec()
	return false

## Quit: stop new requests and block until every request in flight is collected.
static func drain() -> void:
	draining = true
	for index in pending_meshes.keys():
		var path := mesh_path(index)
		if ResourceLoader.load_threaded_get_status(path)!=ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			ResourceLoader.load_threaded_get(path)
	pending_meshes.clear()

static func prepare_variant(index: int) -> void:
	if meshes.is_empty(): meshes.resize(VARIANTS)
	if meshes[index] != null: return
	var path := mesh_path(index)
	meshes[index] = load(path) if ResourceLoader.exists(path) else _bolt_mesh(index)

static func _tri(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3,uv: Vector2) -> void:
	var normal := (b-a).cross(c-a).normalized()
	for point in [a,c,b]:
		st.set_normal(normal)
		st.set_uv(uv)
		st.add_vertex(point)

static func _quad(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3,d: Vector3,uv: Vector2) -> void:
	_tri(st,a,b,c,uv)
	_tri(st,a,c,d,uv)

static func _ribbon(st: SurfaceTool,points: Array[Vector2],width: float,depth: float,uv: Vector2,taper := false) -> void:
	# Thin double-sided sheets: no solid slab walls or expensive transparent glow.
	for i in range(points.size()-1):
		var p := points[i]
		var q := points[i+1]
		var w0 := width*(1.0-float(i)/(points.size()-1)*.9) if taper else width
		var w1 := width*(1.0-float(i+1)/(points.size()-1)*.9) if taper else width
		if not taper and i == 0: w0 = 0.0
		if taper and i == points.size()-2: w1 = 0.0
		var a := Vector3(p.x-w0,p.y,depth)
		var b := Vector3(p.x+w0,p.y,depth)
		var c := Vector3(q.x+w1,q.y,depth)
		var d := Vector3(q.x-w1,q.y,depth)
		if not taper and i == 0:
			a.z = 0.0
			b.z = 0.0
		var corners := [a,b,c,d]
		for index in [0,2,1,0,3,2]:
			st.set_normal(Vector3.BACK)
			st.set_uv(uv)
			st.set_uv2(Vector2(-1.0 if index in [0,3] else 1.0,0.0))
			st.add_vertex(corners[index])

static func _bolt_mesh(variant: int) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var colors: Array[Vector2] = [AtlasPalette.swatch(Color("7aabef")).uv,AtlasPalette.swatch(Color("c5e4ff")).uv,AtlasPalette.swatch(Color("ffffff")).uv]
	var rng := RandomNumberGenerator.new()
	rng.seed = 91037+variant*2039
	# Broad bends plus small-scale kinks, not a regular sawtooth outline.
	var bends: Array[float] = [0.0]
	for i in 8: bends.append(rng.randf_range(-.34,.34))
	var points: Array[Vector2] = [Vector2.ZERO]
	var y := 0.0
	for i in range(1,41):
		var section := float(i)/5.0
		var lower := mini(int(section),7)
		var drift := lerpf(bends[lower],bends[lower+1],section-lower)
		y += rng.randf_range(.65,1.35)
		points.append(Vector2(drift+rng.randf_range(-.028,.028),y))
	for i in range(1,points.size()): points[i].y /= y
	# Both ends are exact anchors: local origin hits the body, (0,1,0)
	# lies inside the cloud. Broad bends remain between those endpoints.
	var end_drift: float = points[-1].x
	for i in points.size(): points[i].x -= end_drift*points[i].y
	for layer in 3:
		_ribbon(st,points,[.070,.030,.009][layer],.001+layer*.001,colors[layer])
	for branch in 6:
		var source: Vector2 = points[8+branch*5]
		var fork: Array[Vector2] = [source]
		var sign_x := -1.0 if (branch+variant)%2 == 0 else 1.0
		var current := source
		for step in 9:
			current += Vector2(sign_x*rng.randf_range(.025,.065)+rng.randf_range(-.025,.025),-rng.randf_range(.008,.023))
			fork.append(current)
		_ribbon(st,fork,.025,.001,colors[0],true)
		_ribbon(st,fork,.006,.003,colors[2],true)
		if branch%2 == 0:
			var twig: Array[Vector2] = [fork[4]]
			current = fork[4]
			for step in 4:
				current += Vector2(-sign_x*rng.randf_range(.015,.04),-rng.randf_range(.01,.024))
				twig.append(current)
			_ribbon(st,twig,.014,.001,colors[0],true)
			_ribbon(st,twig,.004,.003,colors[1],true)
	var mesh := st.commit()
	mesh.surface_set_material(0,material)
	return mesh

static func vertices(mesh: Mesh) -> PackedVector3Array:
	if vertex_cache.has(mesh): return vertex_cache[mesh]
	var points := PackedVector3Array()
	for surface in mesh.get_surface_count():
		var arrays := mesh.surface_get_arrays(surface)
		if not arrays.is_empty(): points.append_array(arrays[Mesh.ARRAY_VERTEX])
	vertex_cache[mesh] = points
	return points

static func skin_meshes(owner_node: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	var seen := {}
	for key in Layout.ORDER:
		var name: String = Layout.PIECES[key].mesh
		var root: Node = null
		if owner_node is Climber:
			var body: Node = owner_node.bodies.get(key)
			if is_instance_valid(body): root = body.find_child(name,true,false)
		else: root = owner_node.find_child(name,true,false)
		if not is_instance_valid(root): continue
		var candidates := root.find_children("*","MeshInstance3D",true,false)
		if root is MeshInstance3D: candidates.append(root)
		for item: MeshInstance3D in candidates:
			if item.mesh != null and item.is_visible_in_tree() and not seen.has(item):
				seen[item] = true
				result.append(item)
	return result

static func highest_surface(owner_node: Node) -> Dictionary:
	var highest := Vector3(0,-INF,0)
	var winner: MeshInstance3D = null
	var local_point := Vector3.ZERO
	for item in skin_meshes(owner_node):
		var transform := item.global_transform
		var up_row := Vector3(transform.basis.x.y,transform.basis.y.y,transform.basis.z.y)
		for point in vertices(item.mesh):
			var y: float = up_row.dot(point)+transform.origin.y
			if y > highest.y:
				highest = transform*point
				local_point = point
				winner = item
	return {} if winner == null else {"world":highest,"mesh":winner,"local":local_point}

static func preview(model: Node3D,camera: Camera3D) -> Node:
	# Preview may be replayed after its previous animation has finished.
	return strike(model,camera,true,false)

static func attach(climber: Climber,camera: Camera3D,animate := true) -> Node:
	if not is_instance_valid(climber) or climber.removed or climber.state != Climber.State.FROZEN: return null
	if not animate: return null # Snapshot restore must never replay transient strikes.
	var effect = strike(climber,camera,true,true)
	if is_instance_valid(effect): preload("res://ui3d/lightning_foreground.gd").ensure(camera).include_effect(effect)
	return effect

static func strike(owner_node: Node,camera: Camera3D,animate := true,once := true) -> Node:
	if not animate or not is_instance_valid(camera) or not owner_node.is_inside_tree(): return null
	if once and owner_node.has_meta(MARKER): return null
	if owner_node.has_node("LightningStrike"): return owner_node.get_node("LightningStrike")
	if cloud_mesh==null: prepare_unit(39)
	if rain_mesh==null: prepare_unit(40)
	if cloud_mesh==null or rain_mesh==null: return null
	var skin := skin_meshes(owner_node)
	if skin.is_empty(): return null
	var effect := new()
	effect.name = "LightningStrike"
	owner_node.add_child(effect)
	if owner_node is Climber:
		preload("res://ui3d/lock_effect_lod.gd").register(effect,&"legendary_locked_lod",effect.global_position,owner_node)
	effect.top_level = true
	effect.owner_ref = weakref(owner_node)
	effect.tracked_skin = skin
	if not effect._refresh_target():
		effect.free()
		return null
	if once: owner_node.set_meta(MARKER,true)
	var right := camera.global_basis.x
	right.y = 0
	right = right.normalized() if right.length_squared()>.001 else Vector3.RIGHT
	var weather_scale: float = owner_node.body_scale if owner_node is Climber else owner_node.global_basis.get_scale().length()/sqrt(3.0)
	weather_scale = clampf(weather_scale,.55,1.35)
	effect.global_basis = Basis(right,Vector3.UP,right.cross(Vector3.UP)).scaled(Vector3.ONE*weather_scale)
	for i in CLOUD_COUNT:
		var cloud := MeshInstance3D.new()
		cloud.name = "StormCloud%d" % (i+1)
		cloud.mesh = cloud_mesh
		cloud.material_override = weather_material
		cloud.set_instance_shader_parameter("cloud_top_fill",.8)
		cloud.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		effect.add_child(cloud)
		effect.clouds.append(cloud)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var start := rng.randi_range(0,VARIANTS-1)
	for i in STRIKE_COUNT:
		# Conservative central volume is inside the actual baked shell, not
		# merely an analytic puff that the low-poly surface approximates.
		var offset := Vector3(rng.randf_range(-.18,.18),rng.randf_range(-.04,.06),rng.randf_range(-.05,.05))
		var source: Vector3 = CLOUD_POSITIONS[i]+offset*CLOUD_SIZES[i]
		effect.cloud_sources.append(source)
		var variant := (start+i*2)%VARIANTS
		prepare_variant(variant)
		var bolt := MeshInstance3D.new()
		bolt.name = "Bolt%d" % (i+1)
		bolt.mesh = meshes[variant]
		bolt.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		# Root +Z faces the camera. Keep the upper bolt behind the cloud
		# shell while its projected origin remains inside that cloud.
		var behind_source: Vector3 = source-Vector3.BACK*(.36*CLOUD_SIZES[i])
		bolt.basis = Basis(Vector3(rng.randf_range(.45,.60),0,0),behind_source,Vector3.BACK)
		bolt.hide()
		effect.add_child(bolt)
		effect.bolts.append(bolt)
	effect.rain = MultiMeshInstance3D.new()
	effect.rain.name = "Rain"
	effect.rain.multimesh = MultiMesh.new()
	effect.rain.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	effect.rain.multimesh.mesh = rain_mesh
	effect.rain.multimesh.instance_count = RAIN_COUNT
	effect.rain.material_override = weather_material
	effect.rain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	effect.add_child(effect.rain)
	for i in RAIN_COUNT:
		var c := i%STRIKE_COUNT
		effect.rain_offsets.append(Vector3(CLOUD_POSITIONS[c].x+rng.randf_range(-.45,.45)*CLOUD_SIZES[c],rng.randf(),rng.randf_range(-.14,.14)*CLOUD_SIZES[c]))
	effect._update_visibility()
	return effect

func _refresh_target() -> bool:
	var highest := -INF
	for item in tracked_skin:
		if not is_instance_valid(item) or not item.is_visible_in_tree(): continue
		var transform := item.global_transform
		var record: Dictionary = target_records.get(item,{})
		if record.is_empty() or record.basis != transform.basis:
			var row := Vector3(transform.basis.x.y,transform.basis.y.y,transform.basis.z.y)
			var maximum := -INF
			var local := Vector3.ZERO
			for point in vertices(item.mesh):
				var height: float = row.dot(point)
				if height>maximum:
					maximum = height
					local = point
			record = {"basis":transform.basis,"local":local}
			target_records[item] = record
		var world: Vector3 = transform*record.local
		if world.y>highest:
			highest = world.y
			impact = world
			target_mesh = item
			target_local = record.local
	if highest == -INF: return false
	global_position = impact
	return true

func _process(delta: float) -> void:
	var owner_node: Node = owner_ref.get_ref() if owner_ref else null
	if not is_instance_valid(owner_node) or (owner_node is Climber and (owner_node.removed or owner_node.state != Climber.State.FROZEN)):
		queue_free()
		return
	if not _refresh_target():
		queue_free()
		return
	age += delta/maxf(Engine.time_scale,.001)
	_update_visibility()
	if age>=TOTAL_SECONDS: queue_free()

static func _strike_brightness(elapsed: float) -> float:
	if elapsed<0.0 or elapsed>=FLASH_SECONDS: return 0.0
	return 1.0-smoothstep(.10,FLASH_SECONDS,elapsed)

func _update_visibility() -> void:
	var fade := 1.0-smoothstep(1.25,TOTAL_SECONDS,age)
	var formation := smoothstep(0.0,FORM_SECONDS,age)
	var shrink := 1.0-smoothstep(1.35,TOTAL_SECONDS,age)
	# Reuse the bolt envelope; zero illumination throughout both dark gaps.
	var light_strength := 0.0
	var light_source := Vector3.ZERO
	for strike in STRIKE_COUNT:
		var elapsed := age-STRIKE_START-strike*STAGGER
		var strength := _strike_brightness(elapsed)*smoothstep(0.0,.012,elapsed)
		if strength>light_strength:
			light_strength = strength
			light_source = cloud_sources[strike]
	for i in CLOUD_COUNT:
		clouds[i].scale = Vector3.ONE*maxf(formation*shrink*CLOUD_SIZES[i],.001)
		clouds[i].position = CLOUD_POSITIONS[i]+CLOUD_DRIFT[i]*(1.0-formation)
		clouds[i].set_instance_shader_parameter("storm_opacity",CLOUD_OPACITY*formation*fade)
		var local_light := (light_source-clouds[i].position)/maxf(clouds[i].scale.x,.001)
		clouds[i].set_instance_shader_parameter("cloud_strike",Vector4(local_light.x,local_light.y,local_light.z,light_strength))
		clouds[i].visible = age<TOTAL_SECONDS
	for i in STRIKE_COUNT:
		var elapsed := age-STRIKE_START-i*STAGGER
		bolts[i].visible = elapsed>=0 and elapsed<FLASH_SECONDS
		bolts[i].set_instance_shader_parameter("brightness",_strike_brightness(elapsed))
		if bolts[i].visible and not launched[i]:
			launched[i] = true
			strikes_started += 1
	rain.visible = age>=FORM_SECONDS and age<TOTAL_SECONDS
	rain.set_instance_shader_parameter("storm_opacity",fade)
	rain.multimesh.visible_instance_count = clampi(roundi(RAIN_COUNT*fade),0,RAIN_COUNT)
	for i in RAIN_COUNT:
		var offset: Vector3 = rain_offsets[i]
		var drop_y: float = CLOUD_POSITIONS[i%STRIKE_COUNT].y-.14*CLOUD_SIZES[i%STRIKE_COUNT]-fposmod(maxf(0,age-FORM_SECONDS)*1.7+offset.y*.95,.95)
		var size := maxf(.001,fade)*(.8+float(i%3)*.15)
		rain.multimesh.set_instance_transform(i,Transform3D(Basis.IDENTITY.scaled(Vector3.ONE*size),Vector3(offset.x,drop_y,offset.z)))

static func _storm_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var sphere := SphereMesh.new()
	sphere.radius = 1.0
	sphere.height = 2.0
	sphere.radial_segments = 40
	sphere.rings = 18
	var arrays := sphere.surface_get_arrays(0)
	var points: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var uv: Vector2 = AtlasPalette.swatch(Color("ffffff")).uv
	# Bake a single closed outer shell of the puff cluster. Internal sphere
	# surfaces would layer incorrectly during real alpha blending.
	var shell := PackedVector3Array()
	var normals := PackedVector3Array()
	for point in points:
		var direction := point.normalized()
		var distance := 0.0
		var normal := direction
		for puff in CLOUD_PUFFS:
			var centre: Vector3 = puff[0]
			var radii: Vector3 = puff[1]
			var d := direction/radii
			var c := centre/radii
			var a := d.dot(d)
			var b := -2.0*d.dot(c)
			var discriminant := b*b-4.0*a*(c.dot(c)-1.0)
			if discriminant<0: continue
			var hit := (-b+sqrt(discriminant))/(2.0*a)
			if hit>distance:
				distance = hit
				normal = ((direction*hit-centre)/(radii*radii)).normalized()
		shell.append(direction*distance)
		normals.append(normal)
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	for t in range(0,indices.size(),3):
		var a := shell[indices[t]]
		var b := shell[indices[t+1]]
		var c := shell[indices[t+2]]
		# Primitive spheres contain collapsed triangles at both poles.
		if (b-a).cross(c-a).length_squared()<1e-16: continue
		for i in 3:
			var index := indices[t+i]
			st.set_normal(normals[index])
			var height := smoothstep(-.20,.52,shell[index].y)
			var facing := clampf(normals[index].y*.5+.5,0.0,1.0)
			var shade := lerpf(.32,1.0,smoothstep(.08,.72,height*.78+facing*.22))
			st.set_color(Color(shade,shade,shade,1.0))
			st.set_uv(uv)
			st.add_vertex(shell[index])
	return st.commit()

static func _rain_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var uv: Vector2 = AtlasPalette.swatch(Color("9fc4df")).uv
	var ring := [Vector3(.004,-.045,0),Vector3(0,-.045,.002),Vector3(-.004,-.045,0),Vector3(0,-.045,-.002)]
	for i in 4:
		_tri(st,Vector3.ZERO,ring[i],ring[(i+1)%4],uv)
		_tri(st,Vector3(0,-.09,0),ring[(i+1)%4],ring[i],uv)
	return st.commit()
