extends Node3D
const Lod=preload("res://ui3d/lock_effect_lod.gd")
const LOD_GROUP=Lod.LEGENDARY_GROUP
var lod_clock:=0.0
var lod_interval:=1.0/15.0
const DURATION:=3.5
const SHINE_DURATION:=0.25
const MIN_ICICLES:=4
const MAX_ICICLES:=8
const MIST_GROUP=&"deep_freeze_mist_owner"
const PUFF_COUNT:=6
static var ice_mesh: ArrayMesh
static var frost_material: ShaderMaterial
static var mist_material: ShaderMaterial
static var mist_mesh: QuadMesh
var age:=0.0
var skins: Array=[]
var icicles: Array=[]
var mist: MultiMeshInstance3D
var mist_sites: Array=[]
var puff_sites: Array=[]
var puff_cycles: Array[int]=[]
var frost_bottom:=0.0
var frost_span:=1.0
var mist_clock:=0.0
var owner_ref: WeakRef
var rng:=RandomNumberGenerator.new()
var mist_active:=false
var settled:=false
static func prepare() -> void:
	if ice_mesh!=null:return
	frost_material=CelPass.one().duplicate();frost_material.shader=preload("res://ui3d/absolute_zero/frost.gdshader")
	mist_material=ShaderMaterial.new();mist_material.shader=preload("res://ui3d/absolute_zero/mist.gdshader")
	mist_mesh=QuadMesh.new();mist_mesh.size=Vector2.ONE
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var palette: Array[Vector2]=[]
	for color in ["d7f4fa","9bcbdc","effbff","78b7cf"]:palette.append(AtlasPalette.swatch(Color(color)).uv)
	for band in 3:
		var y0:=-float(band)/3;var y1:=-float(band+1)/3
		var r0: float=[.11,.083,.045][band];var r1: float=[.083,.045,.001][band]
		for side in 7:
			var angle:=TAU*side/7;var next:=TAU*(side+1)/7
			var a:=Vector3(cos(angle)*r0,y0,sin(angle)*r0);var b:=Vector3(cos(next)*r0,y0,sin(next)*r0)
			var c:=Vector3(cos(next)*r1+.012,y1,sin(next)*r1);var d:=Vector3(cos(angle)*r1+.012,y1,sin(angle)*r1)
			var n: Vector3=(c-a).cross(b-a).normalized()
			for p in [a,c,b,a,d,c]:st.set_normal(n);st.set_uv(palette[side%4]);st.add_vertex(p)
	ice_mesh=st.commit()
func fitted_icicle(point: Vector3, length: float, faces: Array) -> ArrayMesh:
	# Fit a wider root ring to the actual underside once, without extra render nodes.
	var root: Array[Vector3]=[]
	var turn:=rng.randf()*TAU
	for attempt in 4:
		root.clear()
		var radius:=length*.18*pow(.75,attempt)
		for side in 7:
			var angle:=turn+TAU*side/7
			var offset:=Vector3(cos(angle)*radius,0,sin(angle)*radius)
			var origin:=point+offset+Vector3.DOWN*length*.4
			var closest:=INF;var hit:=Vector3.ZERO
			for face in faces:
				var contact=Geometry3D.ray_intersects_triangle(origin,Vector3.UP,face[0],face[1],face[2])
				if contact!=null:
					var distance: float=origin.distance_to(contact)
					if distance<length*.8 and distance<closest:closest=distance;hit=contact
			if closest==INF:break
			root.append((hit+Vector3.UP*.001-point)/length)
		if root.size()==7:break
	if root.size()!=7:return null
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var palette: Array[Vector2]=[]
	for color in ["d7f4fa","9bcbdc","effbff","78b7cf"]:palette.append(AtlasPalette.swatch(Color(color)).uv)
	var rings: Array=[root]
	for band in 3:
		var ring: Array[Vector3]=[]
		for side in 7:
			var angle:=turn+TAU*side/7
			var radius: float=[.083,.045,.001][band]
			ring.append(Vector3(cos(angle)*radius+.012,-float(band+1)/3,sin(angle)*radius))
		rings.append(ring)
	for band in 3:
		for side in 7:
			var next: int=(side+1)%7
			var a: Vector3=rings[band][side];var b: Vector3=rings[band][next]
			var c: Vector3=rings[band+1][next];var d: Vector3=rings[band+1][side]
			var normal: Vector3=(c-a).cross(b-a).normalized()
			for vertex in [a,c,b,a,d,c]:st.set_normal(normal);st.set_uv(palette[side%4]);st.add_vertex(vertex)
	return st.commit()
func setup(actor: Node) -> void:
	prepare();rng.randomize();owner_ref=weakref(actor)
	var body_size: float=actor.body_scale if actor is Climber else 1.0
	var candidates: Array=[];var faces: Array=[];var bottom:=INF;var top:=-INF
	for key in Climber.Layout.ORDER:
		var body: Node=actor.bodies.get(key) if actor is Climber else actor
		if body==null:continue
		var node: Node=body.find_child(Climber.Layout.PIECES[key].mesh,true,false)
		var meshes: Array=[]
		if node is MeshInstance3D:meshes=[node]
		elif node!=null:meshes=node.find_children("*","MeshInstance3D",true,false)
		for skin: MeshInstance3D in meshes:
			var normal_basis:=skin.global_basis.inverse().transposed()
			var surface_sites: Array=[]
			var seen:=0
			for surface in skin.mesh.get_surface_count():
				var arr:=skin.mesh.surface_get_arrays(surface);var verts: PackedVector3Array=arr[Mesh.ARRAY_VERTEX];var normals: PackedVector3Array=arr[Mesh.ARRAY_NORMAL];var ids: PackedInt32Array=arr[Mesh.ARRAY_INDEX]
				if ids.is_empty():for i in verts.size():ids.append(i)
				for i in range(0,ids.size(),3):
					var a:=skin.to_global(verts[ids[i]]);var b:=skin.to_global(verts[ids[i+1]]);var c:=skin.to_global(verts[ids[i+2]])
					faces.append([a,b,c]);bottom=minf(bottom,minf(a.y,minf(b.y,c.y)));top=maxf(top,maxf(a.y,maxf(b.y,c.y)))
					var n: Vector3=(normal_basis*(normals[ids[i]]+normals[ids[i+1]]+normals[ids[i+2]])).normalized()
					var center: Vector3=(a+b+c)/3
					seen+=1
					var site={"point":center+n*.015,"normal":n,"part":key}
					if surface_sites.size()<24:surface_sites.append(site)
					else:
						var slot:=rng.randi_range(0,seen-1)
						if slot<24:surface_sites[slot]=site
					if n.y<-.48 and n.z>-.4 and center.z>=skin.global_position.z-.03:
						candidates.append({"point":center,"normal":n,"part":key})
			skins.append({"node":skin,"original":skin.material_override})
			mist_sites.append_array(surface_sites)
		await get_tree().process_frame
		if not is_instance_valid(self) or not is_instance_valid(actor):return
	frost_bottom=bottom;frost_span=maxf(.1,top-bottom)
	var frost_seed:=rng.randf()*20
	for entry in skins:
		entry.node.material_override=frost_material
		entry.node.set_instance_shader_parameter("frost_floor",bottom)
		entry.node.set_instance_shader_parameter("frost_height",maxf(.1,top-bottom))
		entry.node.set_instance_shader_parameter("frost_seed",frost_seed)
		entry.node.set_instance_shader_parameter("frost_progress",0.0)
		entry.node.set_instance_shader_parameter("frost_shine",-.2)
	for i in range(candidates.size()-1,0,-1):
		var j:=rng.randi_range(0,i);var swap=candidates[i];candidates[i]=candidates[j];candidates[j]=swap
	var selected: Array[Vector3]=[];var part_count: Dictionary={}
	var target_count:=rng.randi_range(MIN_ICICLES,MAX_ICICLES)
	for candidate in candidates:
		if part_count.get(candidate.part,0)>=2:continue
		var point: Vector3=candidate.point+candidate.normal*.002
		var length:=rng.randf_range(.12,.25)*body_size
		var crowded:=false
		for p in selected:
			if p.distance_to(point)<.12*body_size:crowded=true
		if crowded:continue
		var blocked:=false
		for face in faces:
			var contact=Geometry3D.ray_intersects_triangle(point+Vector3.DOWN*.006,Vector3.DOWN,face[0],face[1],face[2])
			if contact!=null and point.distance_to(contact)<length+.02:blocked=true;break
		if blocked:continue
		var query:=PhysicsRayQueryParameters3D.create(point,point+Vector3.DOWN*(length+.02),1)
		if not get_world_3d().direct_space_state.intersect_ray(query).is_empty():continue
		var fitted:=fitted_icicle(point,length,faces)
		if fitted==null:continue
		var icicle:=MeshInstance3D.new();icicle.mesh=fitted;icicle.material_override=CelPass.one();icicle.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(icicle);icicle.global_position=point
		icicle.set_meta("length",length);icicle.set_meta("start",rng.randf_range(.25,.65));icicle.set_meta("normal",candidate.normal)
		icicles.append(icicle);selected.append(point);part_count[candidate.part]=int(part_count.get(candidate.part,0))+1
		if icicles.size()>=target_count:break
		await get_tree().process_frame
		if not is_instance_valid(self) or not is_instance_valid(actor):return
	# Six reused quads per player; all players retain access, with no permanent
	# first-four-owner exclusion. Sample surface points once, never every frame.
	add_to_group(MIST_GROUP);mist_active=true
	mist=MultiMeshInstance3D.new();var mm:=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.use_custom_data=true;mm.mesh=mist_mesh;mm.instance_count=PUFF_COUNT
	mist.multimesh=mm;mist.material_override=mist_material;mist.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(mist)
	for i in PUFF_COUNT:puff_sites.append({});puff_cycles.append(-1)
	if actor is Climber:Lod.register(self,LOD_GROUP,Vector3(actor.bodies.values()[0].global_position.x,(bottom+top)*.5,actor.bodies.values()[0].global_position.z),actor)
	lod_clock=rng.randf()*.25
	tick(0);set_meta("ready",true)
func tick(t: float) -> void:
	age=t;var progress:=clampf(age/DURATION,0,1)
	var sweep:=clampf((age-DURATION)/SHINE_DURATION,0,2)
	var shine_height:=lerpf(1.2,-.2,sweep) if sweep<=1.0 else lerpf(-.2,1.2,sweep-1.0)
	for entry in skins:
		if is_instance_valid(entry.node):
			entry.node.set_instance_shader_parameter("frost_progress",progress)
			entry.node.set_instance_shader_parameter("frost_shine",shine_height)
	for icicle in icicles:
		var growth:=smoothstep(float(icicle.get_meta("start")),1.0,progress)
		icicle.scale=Vector3.ONE*maxf(.0001,float(icicle.get_meta("length"))*growth)
	update_mist()
	if age>=DURATION+SHINE_DURATION*2:settled=true
func update_mist() -> void:
	if not mist_active or not is_instance_valid(mist):return
	for i in PUFF_COUNT:
		var lifetime:=age*.55+i/float(PUFF_COUNT)
		var cycle:=int(floor(lifetime));var phase:=fposmod(lifetime,1.0)
		if cycle!=puff_cycles[i]:
			puff_cycles[i]=cycle;puff_sites[i]={}
			for attempt in 64:
				var site: Dictionary=mist_sites[rng.randi_range(0,mist_sites.size()-1)]
				var height:=clampf((site.point.y-frost_bottom)/frost_span,0,1)
				# Conservative bound: the shader's entire noise range is fully frozen.
				if clampf(age/DURATION,0,1)*1.32-height*.86>=.35:
					puff_sites[i]=site;break
		var site: Dictionary=puff_sites[i]
		if site.is_empty():
			mist.multimesh.set_instance_custom_data(i,Color(0,0,0,0));continue
		var drift: Vector3=Vector3(site.normal.x*.075,-.10,site.normal.z*.075)
		var point: Vector3=to_local(site.point+drift*phase)
		var puff_size:=.10+phase*.16
		mist.multimesh.set_instance_transform(i,Transform3D(Basis.IDENTITY.scaled(Vector3.ONE*puff_size),point))
		mist.multimesh.set_instance_custom_data(i,Color(phase,0,0,sin(PI*phase)))
func _process(dt: float) -> void:
	if owner_ref!=null:
		var actor=owner_ref.get_ref()
		if not is_instance_valid(actor) or (actor is Climber and actor.removed):queue_free();return
	if not settled:tick(age+dt)
	else:
		age+=dt;mist_clock+=dt;lod_clock+=dt
		if lod_clock>=.25:
			lod_clock=0;lod_interval=Lod.interval(self,LOD_GROUP,1.0/15.0)
		if mist_clock>=lod_interval:
			mist_clock=0;update_mist()
func _exit_tree() -> void:
	for entry in skins:
		if is_instance_valid(entry.node) and entry.node.material_override==frost_material:
			entry.node.material_override=entry.original
			entry.node.set_instance_shader_parameter("frost_progress",0.0)
			entry.node.set_instance_shader_parameter("frost_shine",-.2)

static func prepare_unit(_index: int) -> bool:
	prepare();return true
static func preview(model: Node3D,_camera: Camera3D) -> Node:
	return attach_owner(model,true)
static func attach(actor: Climber,_camera: Camera3D=null,animate:=true) -> Node:
	if not is_instance_valid(actor) or actor.removed or actor.state!=Climber.State.FROZEN:return null
	return attach_owner(actor,animate)
static func attach_owner(owner_node: Node,animate: bool) -> Node:
	var existing:=owner_node.get_node_or_null("AbsoluteZero")
	if existing!=null:return existing
	var effect:=new();effect.name="AbsoluteZero";effect.set_meta("persistent_lock_effect",true);effect.set_meta("ready",false)
	owner_node.add_child(effect);effect.set_process(false);effect.start(owner_node,animate);return effect
func start(owner_node: Node,animate: bool) -> void:
	await setup(owner_node)
	if not is_instance_valid(self) or not is_instance_valid(owner_node):return
	tick(0 if animate else 5);set_meta("ready",true);set_process(true)
