extends Node3D
## Persistent pose-bound cosmetic. No bodies, collision, forces or pose edits.
const Layout = preload("res://climber/body_layout.gd")
const DURATION := 3.2
const SIDES := 6
const STEPS := 40
const VARIANTS := 3
static var cache := {}
static var authoring := false
static var preparation_max_ms := 0.0
static var pending := {}
static var preparation_samples := []
static var material: ShaderMaterial
static var connector: ArrayMesh
static var surfaces: Dictionary={}
static var activation_serial:=0
static var bridge_clearance_failures:=0
var wraps: Array[GeometryInstance3D] = []
var age := 0.0
var owner_ref: WeakRef
static func skin_parts(climber: Climber) -> Dictionary:
	var result := {}
	for key in Layout.ORDER:
		if key.begins_with("hand") or key.begins_with("foot") or key=="head": continue
		var body: Node = climber.bodies.get(key)
		if body==null: continue
		var skin: Node = body.find_child(Layout.PIECES[key].mesh,true,false)
		if skin is MeshInstance3D: result[key]=skin
		elif skin!=null:
			var children := skin.find_children("*","MeshInstance3D",true,false)
			if not children.is_empty(): result[key]=children[0]
	return result
static func prepare(parts: Dictionary) -> bool:
	var ready := true
	for key in parts:
		if not prepare_part(parts[key],key): ready=false
	return ready
static func prepare_part(skin: MeshInstance3D,key: String) -> bool:
	for variant in VARIANTS:
		if not prepare_variant(skin,key,variant): return false
	return true
## The preparer clears this while its loads in flight are at their cap; live
## callers keep it true. drain() stops new requests for good (quit).
static var request_allowed := true
static var draining := false
static func may_request() -> bool:
	return request_allowed and not draining
## Quit: stop new requests and block until every request in flight is collected.
static func drain() -> void:
	draining = true
	for path in pending.keys():
		if ResourceLoader.load_threaded_get_status(path)!=ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			ResourceLoader.load_threaded_get(path)
	pending.clear()
static func prepare_variant(skin: MeshInstance3D,key: String,variant: int) -> bool:
	var begin := Time.get_ticks_usec()
	if material==null:
		var shader_path := "res://ui3d/vines/vines.gdshader"
		if not pending.has(shader_path):
			if not may_request() and not authoring: return false
			ResourceLoader.load_threaded_request(shader_path,"Shader");pending[shader_path]=true
		if ResourceLoader.load_threaded_get_status(shader_path)!=ResourceLoader.THREAD_LOAD_LOADED and not authoring: return false
		material=CelPass.one().duplicate()
		material.shader=ResourceLoader.load_threaded_get(shader_path)
		pending.erase(shader_path)
	if connector==null:
		var path := "res://ui3d/vines/baked/joint_stem.res"
		if authoring:
			var surface:=SurfaceTool.new();surface.begin(Mesh.PRIMITIVE_TRIANGLES)
			var points: Array[Vector3]=[];var growth: Array[float]=[]
			for i in 2:
				points.append(Vector3(0,float(i),0));growth.append(float(i)/10)
			tube(surface,points,1.0,growth,1.0,8,true);connector=surface.commit();ResourceSaver.save(connector,path)
		else:
			if not pending.has(path):
				if not may_request(): return false
				ResourceLoader.load_threaded_request(path,"ArrayMesh");pending[path]=true
			if ResourceLoader.load_threaded_get_status(path)!=ResourceLoader.THREAD_LOAD_LOADED:return false
			connector=ResourceLoader.load_threaded_get(path);pending.erase(path)
	var source_mesh: Mesh=skin.get_meta("dress_src",skin.mesh) if skin!=null else null
	var cache_key: String=key+str(variant)
	if cache.has(cache_key): return true
	var file_key := ("character_cufinalt_v1_"+key+str(variant)).sha256_text().left(20)
	var path := "res://ui3d/vines/baked/"+file_key+".res"
	if authoring:
		cache[cache_key]=make_wrap(source_mesh,key,variant)
		ResourceSaver.save(cache[cache_key],path)
	elif ResourceLoader.exists(path):
		if not pending.has(path):
			if not may_request(): return false
			ResourceLoader.load_threaded_request(path,"ArrayMesh")
			pending[path]=true
		if ResourceLoader.load_threaded_get_status(path)==ResourceLoader.THREAD_LOAD_LOADED:
			cache[cache_key]=ResourceLoader.load_threaded_get(path);pending.erase(path)
			surfaces[key]=cache[cache_key].get_meta("fit_surface")
	else: push_error("Vines requires prepared skin bake: "+path)
	preparation_max_ms=maxf(preparation_max_ms,(Time.get_ticks_usec()-begin)/1000.0)
	preparation_samples.append({"key":key,"ms":(Time.get_ticks_usec()-begin)/1000.0,"ready":cache.has(cache_key)})
	return cache.has(cache_key)
static func prepare_unit(index: int) -> bool:
	var keys: Array=[]
	for key in Layout.ORDER:
		if key!="head" and not key.begins_with("hand") and not key.begins_with("foot"): keys.append(key)
	return prepare_variant(null,keys[index/VARIANTS],index%VARIANTS)
static func preview(model: Node3D, _camera: Camera3D) -> Node:
	var parts: Dictionary={}
	for key in Layout.ORDER:
		if key=="head" or key.begins_with("hand") or key.begins_with("foot"): continue
		var skin: Node=model.find_child(Layout.PIECES[key].mesh,true,false)
		if skin is MeshInstance3D: parts[key]=skin
		elif skin!=null:
			var children:=skin.find_children("*","MeshInstance3D",true,false)
			if not children.is_empty(): parts[key]=children[0]
	return attach_parts(model,parts,1.0,true)
static func attach(climber: Climber, _camera: Camera3D=null, animate := true) -> Node:
	if not is_instance_valid(climber) or climber.removed or climber.state!=Climber.State.FROZEN: return null
	return attach_parts(climber,skin_parts(climber),climber.body_scale,animate)
static func wait_for_parts(owner_node: Node, parts: Dictionary, body_size: float, animate: bool) -> void:
	var tree:=owner_node.get_tree()
	var deadline:=Time.get_ticks_msec()+5000
	while is_instance_valid(owner_node) and owner_node.is_inside_tree():
		if Time.get_ticks_msec()>deadline:
			owner_node.remove_meta("vines_pending")
			push_warning("Vines preparation timed out")
			return
		if prepare(parts):
			owner_node.remove_meta("vines_pending")
			if not owner_node is Climber or (not owner_node.removed and owner_node.state==Climber.State.FROZEN): attach_parts(owner_node,parts,body_size,animate)
			return
		await tree.process_frame
static func attach_parts(owner_node: Node, parts: Dictionary, body_size: float, animate: bool) -> Node:
	var existing:=owner_node.get_node_or_null("Vines")
	if existing!=null: return existing
	if parts.size()!=11: return null
	if not prepare(parts):
		if not owner_node.has_meta("vines_pending"):
			owner_node.set_meta("vines_pending",true)
			wait_for_parts(owner_node,parts,body_size,animate)
		return null
	var effect := new()
	effect.name="Vines"
	var rng:=RandomNumberGenerator.new();rng.randomize();activation_serial+=1;rng.seed=rng.seed^(activation_serial*7919)
	var profile:=[]
	effect.owner_ref=weakref(owner_node)
	effect.set_meta("persistent_lock_effect",true)
	owner_node.add_child(effect)
	if owner_node is Climber:
		preload("res://ui3d/lock_effect_lod.gd").register(effect,&"legendary_locked_lod",effect.global_position,owner_node)
	for key in parts:
		var skin: MeshInstance3D=parts[key]
		var wrap := MeshInstance3D.new()
		wrap.name="VineWrap_"+key
		var variant:=rng.randi_range(0,VARIANTS-1)
		profile.append(variant)
		wrap.mesh=cache[key+str(variant)]
		wrap.material_override=material
		wrap.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var timing := Vector2(.78,.93) if key.begins_with("arm") and key.ends_with("up") else Vector2(.87,1.0)
		if key.begins_with("leg"):timing=Vector2(0,.28) if key.ends_with("lo") else Vector2(.22,.48)
		if key=="pelvis":timing=Vector2(.43,.57)
		if key=="navel":timing=Vector2(.52,.66)
		if key=="chest":timing=Vector2(.61,.85)
		wrap.set_meta("growth_start",timing.x);wrap.set_meta("growth_end",timing.y)
		skin.add_child(wrap)
		var box := skin.mesh.get_aabb()
		var axis := box.size.max_axis_index() if key.begins_with("arm") or key.begins_with("leg") else 1
		var low := box.get_center();var high := low
		low[axis]-=box.size[axis]*.5;high[axis]+=box.size[axis]*.5
		var reverse := skin.to_global(low).y>skin.to_global(high).y
		if key.begins_with("arm"):
			var chest: MeshInstance3D=parts.chest
			var chest_center := chest.to_global(chest.mesh.get_aabb().get_center())
			reverse=skin.to_global(high).distance_to(chest_center)<skin.to_global(low).distance_to(chest_center)
		wrap.set_instance_shader_parameter("vine_reverse",reverse)
		wrap.set_meta("reverse",reverse);wrap.set_meta("part",key)
		effect.wraps.append(wrap)
	var route_frames: Array=[]
	for part_key in parts:
		var skin: MeshInstance3D=parts[part_key]
		var to_effect:=effect.global_transform.affine_inverse()*skin.global_transform
		var box: AABB=to_effect*skin.mesh.get_aabb()
		route_frames.append([to_effect.affine_inverse(),to_effect,surfaces[part_key],box.grow(.035*body_size)])
	var branches := [["leg_l_lo","leg_l_up",.18,.24],["leg_r_lo","leg_r_up",.18,.24],["leg_l_up","pelvis",.39,.45],["leg_r_up","pelvis",.39,.45],["pelvis","navel",.50,.54],["navel","chest",.58,.63],["chest","arm_l_up",.73,.80],["chest","arm_r_up",.73,.80],["arm_l_up","arm_l_lo",.84,.88],["arm_r_up","arm_r_lo",.84,.88]]
	for pair in branches:
		var source: MeshInstance3D
		var target: MeshInstance3D
		for wrap in effect.wraps:
			if wrap.get_meta("part","")==pair[0]:source=wrap
			if wrap.get_meta("part","")==pair[1]:target=wrap
		if source==null or target==null:continue
		var from_ends: Array=source.mesh.get_meta("stem_ends")
		var to_ends: Array=target.mesh.get_meta("stem_ends")
		var start: Vector3=effect.to_local(source.to_global(from_ends[0 if source.get_meta("reverse") else 1]))
		var finish: Vector3=effect.to_local(target.to_global(to_ends[1 if target.get_meta("reverse") else 0]))
		var route: Array[Vector3]=[]
		var width:=.010*body_size
		for step in 9:
			var point:=start.lerp(finish,float(step)/8)
			for iteration in 2:
				for frame in route_frames:
					if not frame[3].has_point(point):continue
					point=frame[1]*grid_project(frame[0]*point,frame[2],.026)
			route.append(point)
		var multimesh:=MultiMesh.new();multimesh.transform_format=MultiMesh.TRANSFORM_3D;multimesh.use_custom_data=true
		multimesh.mesh=connector;multimesh.instance_count=route.size()-1
		var transforms: Array[Transform3D]=[]
		var bridge:=MultiMeshInstance3D.new();bridge.name="JointStem";bridge.set_meta("pair",str(pair));bridge.multimesh=multimesh;bridge.material_override=material
		bridge.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;effect.add_child(bridge)
		bridge.set_meta("growth_start",pair[2]);bridge.set_meta("growth_end",pair[3]);effect.wraps.append(bridge)
		for step in route.size()-1:
			var y:=route[step+1]-route[step]
			if y.length()<.0001:continue
			var direction:=y.normalized();var x:=direction.cross(Vector3.FORWARD).normalized()
			if x.length_squared()<.1:x=direction.cross(Vector3.RIGHT).normalized()
			var z:=x.cross(direction).normalized()
			var transform:=Transform3D(Basis(x*width,y,z*width),route[step])
			transforms.append(transform);multimesh.set_instance_transform(step,transform)
			multimesh.set_instance_custom_data(step,Color(float(step)/(route.size()-1),float(step+1)/(route.size()-1),0,0))
		bridge.set_meta("authored_transforms",transforms)
	effect.set_meta("profile",profile)
	effect.age=0.0 if animate else DURATION
	effect.update_growth()
	return effect
func update_growth() -> void:
	for wrap in wraps:
		if is_instance_valid(wrap):
			var start: float=wrap.get_meta("growth_start")
			var end: float=wrap.get_meta("growth_end")
			wrap.set_instance_shader_parameter("vine_growth",clampf((age/DURATION-start)/(end-start),0.0,1.0))
	if age>=DURATION: set_process(false)
func _process(dt: float) -> void:
	var owner_node: Node=owner_ref.get_ref()
	if not is_instance_valid(owner_node) or (owner_node is Climber and owner_node.removed):
		queue_free(); return
	age+=dt
	update_growth()
func _exit_tree() -> void:
	for wrap in wraps:
		if is_instance_valid(wrap): wrap.queue_free()
static func vertex(st: SurfaceTool,p: Vector3,n: Vector3,uv: Vector2,growth: float) -> void:
	st.set_normal(n);st.set_uv(uv);st.set_uv2(Vector2(growth,0));st.add_vertex(p)
static func triangle(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3,uv: Vector2,growth: float) -> void:
	if (c-a).cross(b-a).length_squared()<1e-16:return
	var n := (c-a).cross(b-a).normalized()
	for p in [a,b,c]: vertex(st,p,n,uv,growth)
static func tube(st: SurfaceTool,points: Array[Vector3],radius: float,growth: Array[float],seed_value: float,sides := 8,woody := true) -> void:
	var palette := ["493b24","786039","566331","8d7547","36482b"] if woody else ["3b692c","64863c","78924b"]
	var uvs: Array[Vector2]=[]
	for color in palette:uvs.append(AtlasPalette.swatch(Color(color)).uv)
	for i in points.size()-1:
		var tangent := (points[mini(i+1,points.size()-1)]-points[maxi(0,i-1)]).normalized()
		var u := tangent.cross(Vector3.FORWARD).normalized()
		if u.length_squared()<.1:u=tangent.cross(Vector3.RIGHT).normalized()
		var v := tangent.cross(u).normalized()
		var t := float(i)/(points.size()-1)
		var thick := radius*(.78+.14*sin(i*.53+seed_value)+.08*cos(i*.91))
		thick*=lerpf(1.0,.55,t) if woody else lerpf(1.0,.08,t)
		for side in sides:
			var angle := TAU*side/sides+float(i)*.13
			var n0 := u*cos(angle)+v*sin(angle)
			var n1 := u*cos(angle+TAU/sides)+v*sin(angle+TAU/sides)
			var r0 := thick*(1.0 if side%2==0 else .84)
			var r1 := thick*(1.0 if (side+1)%2==0 else .84)
			var corners := [points[i]+n0*r0,points[i]+n1*r1,points[i+1]+n1*r1,points[i+1]+n0*r0]
			for index in [0,2,1,0,3,2]:
				vertex(st,corners[index],n0 if index in [0,3] else n1,uvs[posmod(side+int(seed_value),uvs.size())],growth[i+(1 if index>=2 else 0)])
static func leaf(st: SurfaceTool,root: Vector3,outward: Vector3,axis: Vector3,length: float,growth: float) -> void:
	var along := (outward*.6+axis*.8).normalized()
	var across := along.cross(outward).normalized()
	if across.length_squared()<.1:across=Vector3.RIGHT
	var green: Vector2=AtlasPalette.swatch(Color("4b7b31")).uv
	var bright: Vector2=AtlasPalette.swatch(Color("73994a")).uv
	var ridge: Array[Vector3]=[]
	var gs: Array[float]=[]
	for j in 7:
		var t:=float(j)/6.0
		var middle:=root+along*length*t+outward*sin(t*PI)*length*.12
		ridge.append(middle);gs.append(growth)
	for j in 6:
		var t0:=float(j)/6;var t1:=float(j+1)/6
		var width0:=pow(sin(t0*PI),.8)*length*.28*(1.0 if j%2==0 else .88)
		var width1:=pow(sin(t1*PI),.8)*length*.28*(1.0 if (j+1)%2==0 else .88)
		for side in [-1,1]:
			var a:=ridge[j];var b: Vector3=ridge[j]+across*width0*side-outward*width0*.2
			var c: Vector3=ridge[j+1]+across*width1*side-outward*width1*.2;var d:=ridge[j+1]
			for indices in [[0,1,2],[0,2,3],[2,1,0],[3,2,0]]:
				var q: Array=[a,b,c,d];triangle(st,q[indices[0]],q[indices[1]],q[indices[2]],green if side<0 else bright,growth)
	tube(st,ridge,length*.016,gs,.0,4,false)
static func make_wrap(mesh: Mesh,key: String,variant: int) -> ArrayMesh:
	var box:=mesh.get_aabb();var faces:=mesh.get_faces();var center:=box.get_center()
	var axis:=box.size.max_axis_index() if key.begins_with("arm") or key.begins_with("leg") else 1
	var a:=(axis+1)%3;var b:=(axis+2)%3
	var torso:=key in ["chest","navel","pelvis"]
	var radius:=clampf(minf(box.size[a],box.size[b])*.15,.014,.032)
	var phase:=float(abs(key.hash())%100)/100.0*TAU+variant*1.41
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var ends: Array[Vector3]=[]
	var sample_count:=0;var fallback_count:=0
	for strand in (3 if torso else 2):
		var points: Array[Vector3]=[];var gs: Array[float]=[]
		var climbing:=strand==0
		var count:=40
		for i in count+1:
			var t:=float(i)/count
			var angle:=phase+strand*2.1+t*TAU*(.32 if climbing else (1.15 if torso else .95))*(1 if strand%2==0 else -1)+.40*sin(t*TAU+phase)+.12*sin(t*TAU*3+strand)
			if climbing:
				var front_angle:=PI if a==2 else -PI*.5
				angle=front_angle+(wrapf(phase-front_angle,-PI,PI)+.6*sin(t*TAU+phase))*sin(t*PI)
			var core:=center;core[axis]+=(t-.5)*box.size[axis]*.88
			var direction:=Vector3.ZERO;direction[a]=cos(angle);direction[b]=sin(angle)
			var distance:=0.0
			for face in range(0,faces.size(),3):
				var hit=Geometry3D.ray_intersects_triangle(core,direction,faces[face],faces[face+1],faces[face+2])
				if hit!=null:distance=maxf(distance,core.distance_to(hit))
			sample_count+=1
			if distance==0:
				fallback_count+=1;distance=minf(box.size[a],box.size[b])*.48
			points.append(core+direction*(distance+radius*(.95 if climbing else .70)))
			gs.append(t)
		if strand==0:ends=[points[0],points[-1]]
		tube(st,points,radius*(1.0 if climbing else .60),gs,phase+strand,10,true)
		# Thin woody companion twists along selected primary stems.
		if climbing:
			var companion: Array[Vector3]=[]
			for i in points.size():
				var d:=(points[i]-center);d[axis]=0;d=d.normalized()
				var e:=Vector3.ZERO;e[axis]=1
				companion.append(points[i]+(d*cos(i*.8)+e*sin(i*.8))*radius*.8)
			tube(st,companion,radius*.24,gs,phase,5,false)
		for at in ([12,28] if climbing else [21]):
			var root: Vector3=points[at]
			var outward:=(root-center);outward[axis]=0;outward=outward.normalized()
			var along:=Vector3.ZERO;along[axis]=1
			var tangent:=outward.cross(along).normalized()
			var tendril: Array[Vector3]=[];var tg: Array[float]=[]
			var length:=.07 if torso else .045
			for j in 17:
				var t:=float(j)/16
				tendril.append(root+along*length*t+tangent*sin(t*TAU*1.1)*length*.32+outward*(1-cos(t*TAU*1.1))*length*.23)
				tg.append(clampf(float(at)/count+t*.10,0,1))
			tube(st,tendril,radius*.23,tg,phase+at,5,false)
			leaf(st,tendril[7],outward,(along+tangent*.6).normalized(),.115 if torso else .08,float(at)/count+.05)
			if climbing and torso:leaf(st,tendril[4],outward,(along-tangent).normalized(),.075,float(at)/count+.06)
	var result:=st.commit()
	if not surfaces.has(key):surfaces[key]=make_surface(mesh,axis)
	result=fit_all_vertices(result,mesh,axis,surfaces[key])
	result.set_meta("stem_ends",ends)
	if not surfaces.has(key):surfaces[key]=make_surface(mesh,axis)
	result.set_meta("fit_surface",surfaces[key]);result.set_meta("stem_axis",axis)
	result.set_meta("surface_samples",sample_count);result.set_meta("fallback_samples",fallback_count);result.set_meta("primary_surface_offset",radius*.95)
	return result




# Offline authoring: fit the complete generated surface, including companion strands.
static func ray_surface(p: Vector3,box: AABB,faces: PackedVector3Array,axis: int) -> Vector3:
	var core:=box.get_center();core[axis]=p[axis]
	var direction:=p-core;direction[axis]=0
	if direction.length()<.00001:return p
	direction=direction.normalized();var distance:=0.0
	for i in range(0,faces.size(),3):
		var hit=Geometry3D.ray_intersects_triangle(core,direction,faces[i],faces[i+1],faces[i+2])
		if hit!=null:distance=maxf(distance,core.distance_to(hit))
	return core+direction*distance if distance>0 else p
static var fitting: Dictionary={}
static func fit_point(point: Vector3) -> Vector3:
	if fitting.projected.has(point):return fitting.projected[point]
	var sample:=point;var box: AABB=fitting.box;var axis: int=fitting.axis
	sample[axis]=clampf(sample[axis],box.position[axis]+.002,box.end[axis]-.002)
	var projected:=grid_project(sample,fitting.surface,.008)
	projected[axis]=point[axis]
	var value:=projected
	fitting.projected[point]=value
	return value
static func fit_penetration(point: Vector3) -> float:
	var hit:=ray_surface(point,fitting.box,fitting.faces,fitting.axis)
	if hit.is_equal_approx(point):return -1.0
	var core: Vector3=fitting.box.get_center();core[fitting.axis]=point[fitting.axis]
	return hit.distance_to(core)-point.distance_to(core)
static func fit_mid(a: Array,b: Array) -> Array:
	return [(a[0]+b[0])*.5,(a[1]+b[1]).normalized(),(a[2]+b[2])*.5,(a[3]+b[3])*.5]
static func fit_triangle(st: SurfaceTool,a: Array,b: Array,c: Array,depth: int) -> void:
	a=a.duplicate();b=b.duplicate();c=c.duplicate()
	a[0]=fit_point(a[0]);b[0]=fit_point(b[0]);c[0]=fit_point(c[0])
	var ab:=fit_mid(a,b);var bc:=fit_mid(b,c);var ca:=fit_mid(c,a)
	var worst:=0.0
	for point in [ab[0],bc[0],ca[0],(a[0]+b[0]+c[0])/3]:worst=maxf(worst,fit_penetration(point))
	if worst>.0005 and depth<6:
		fit_triangle(st,a,ab,ca,depth+1);fit_triangle(st,ab,b,bc,depth+1);fit_triangle(st,ca,bc,c,depth+1);fit_triangle(st,ab,bc,ca,depth+1)
		return
	fitting.tested+=7
	fitting.worst=maxf(fitting.worst,worst)
	if worst>.001:fitting.clipped+=1
	for v in [a,b,c]:st.set_normal(v[1]);st.set_uv(v[2]);st.set_uv2(v[3]);st.add_vertex(v[0])
static func fit_all_vertices(input: ArrayMesh,skin: Mesh,axis: int,surface: Dictionary) -> ArrayMesh:
	var arrays:=input.surface_get_arrays(0);var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
	fitting={"box":skin.get_aabb(),"faces":skin.get_faces(),"axis":axis,"surface":surface,"projected":{},"tested":0,"worst":0.0,"clipped":0}
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(0,vertices.size(),3):
		var vs: Array=[]
		for j in 3:vs.append([vertices[i+j],arrays[Mesh.ARRAY_NORMAL][i+j],arrays[Mesh.ARRAY_TEX_UV][i+j],arrays[Mesh.ARRAY_TEX_UV2][i+j]])
		fit_triangle(st,vs[0],vs[1],vs[2],0)
	var output:=st.commit()
	output.set_meta("clearance_samples",fitting.tested);output.set_meta("clipped_samples",fitting.clipped);output.set_meta("worst_penetration",fitting.worst)
	fitting.clear()
	return output
static func make_surface(mesh: Mesh,axis: int) -> Dictionary:
	var box:=mesh.get_aabb();var faces:=mesh.get_faces();var radii:=PackedFloat32Array();var a:=(axis+1)%3;var b:=(axis+2)%3
	for h in 49:
		for angle in 64:
			var core:=box.get_center();core[axis]=box.position[axis]+box.size[axis]*float(h)/48
			var d:=Vector3.ZERO;d[a]=cos(TAU*angle/64);d[b]=sin(TAU*angle/64)
			var hit:=ray_surface(core+d*2,box,faces,axis)
			radii.append(0.0 if hit.is_equal_approx(core+d*2) else hit.distance_to(core))
	var conservative:=radii.duplicate()
	for hi in 49:
		for ai in 64:
			var maximum:=0.0
			for dh in [-1,0,1]:
				for da in [-1,0,1]:maximum=maxf(maximum,radii[clampi(hi+dh,0,48)*64+posmod(ai+da,64)])
			conservative[hi*64+ai]=maximum
	return {"box":box,"axis":axis,"radii":conservative}
static func grid_project(p: Vector3,surface: Dictionary,margin: float) -> Vector3:
	var box: AABB=surface.box;var axis: int=surface.axis;var a: int=(axis+1)%3;var b: int=(axis+2)%3
	var h: float=(p[axis]-box.position[axis])/box.size[axis]*48
	if h<0 or h>48:return p
	var core:=box.get_center();core[axis]=p[axis];var d:=p-core
	var theta:=fposmod(atan2(d[b],d[a]),TAU)/TAU*64
	var radius:=0.0
	for hi in [int(floor(h)),mini(48,int(ceil(h)))]:
		for ai in [int(floor(theta))%64,int(ceil(theta))%64]:radius=maxf(radius,surface.radii[hi*64+ai])
	if radius<=0:return p
	return core+d.normalized()*(radius+margin) if d.length()<radius+margin else p


static func outside_arc(start: Vector3,finish: Vector3,center: Vector3,t: float) -> Vector3:
	var a:=start-center;var b:=finish-center
	if a.normalized().dot(b.normalized())<-.98:
		var axis:=a.normalized().cross(Vector3.RIGHT).normalized()
		if axis.length()<.1:axis=Vector3.UP
		return center+Basis(axis,PI*t)*a.normalized()*lerpf(a.length(),b.length(),t)
	return center+a.slerp(b,t)
