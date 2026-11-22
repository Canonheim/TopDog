extends Node3D
const Lod=preload("res://ui3d/lock_effect_lod.gd")
const LOD_GROUP=Lod.LEGENDARY_GROUP
var lod_clock:=0.0
var lod_elapsed:=0.0
var lod_interval:=0.0
const Fit=preload("res://ui3d/vines/vines.gd")
const DURATION=5.0
const WEB_GROUP=&"lock_in_web_surface"
const WEB_CLEARANCE=.008
static var thread_mesh: ArrayMesh
static var spider_meshes: Array[ArrayMesh]=[]
var age:=0.0
var webs: Array=[]
var spiders: Array=[]
var signature: Array=[]
var rejected:=0
var triangles: Array=[]
var cells: Dictionary={}
var owner_ref: WeakRef
var tower_cache: Dictionary={}
var tower_queries:=0
var tower_webs:=0
var blocked_webs:=0
var tower_enabled:=true
var depth_min:=-.3
var depth_max:=.3
var space: PhysicsDirectSpaceState3D
var rng:=RandomNumberGenerator.new()
static func prepare() -> void:
	for index in 13:prepare_unit(index)
static func prepare_unit(index: int) -> bool:
	if index==0:
		if thread_mesh!=null:return true
		var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var uv: Vector2=AtlasPalette.swatch(Color("e2ded2")).uv
		for p in [Vector3(-.5,0,0),Vector3(.5,1,0),Vector3(.5,0,0),Vector3(-.5,0,0),Vector3(-.5,1,0),Vector3(.5,1,0)]:
			st.set_normal(Vector3.BACK);st.set_uv(uv);st.add_vertex(p)
		thread_mesh=st.commit()
		return true
	var gait:=index-1
	if spider_meshes.size()>gait:return true
	var st: SurfaceTool
	st=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES);st.set_uv2(Vector2.ZERO)
	var dark: Vector2=AtlasPalette.swatch(Color("261d1a")).uv
	for body in [Vector3(0,-.2,.16),Vector3(0,.23,.13)]:
		var sphere:=SphereMesh.new();sphere.radius=.24 if body.y<0 else .15;sphere.height=sphere.radius*1.7;sphere.radial_segments=8;sphere.rings=3
		var arr:=sphere.get_mesh_arrays();var vv: PackedVector3Array=arr[Mesh.ARRAY_VERTEX];var nn: PackedVector3Array=arr[Mesh.ARRAY_NORMAL]
		for idx in arr[Mesh.ARRAY_INDEX]:
			var point:=vv[idx];var normal:=nn[idx]
			if body.y<0:
				# Extend the larger rear section toward the front; keep its rear edge fixed.
				point.y=point.y*1.45+.092
				normal=Vector3(normal.x,normal.y/1.45,normal.z).normalized()
			st.set_normal(normal);st.set_uv(dark);st.add_vertex(point+body)
	for side in [-1,1]:
		for leg in 4:
			var bend:=.035*sin(TAU*gait/12.0+PI*(leg%2)+(.0 if side<0 else PI))
			var a:=Vector3(side*.10,.2-leg*.12,.12)
			var b:=Vector3(side*.40,.48-leg*.28+bend,.15)
			var c:=Vector3(side*.65,.60-leg*.36+bend,.015)
			b=a+(b-a)*.9;c=a+(c-a)*.9
			Fit.tube(st,[a,b,c],.026,[0.0,0.5,1.0],1,4,true)
	var mesh:=st.commit();mesh.set_meta("leg_count",8);mesh.set_meta("leg_length_scale",.9)
	spider_meshes.append(mesh)
	return true
static func preview(model: Node3D, _camera: Camera3D) -> Node:
	return attach_owner(model,true,false)
static func attach(actor: Climber, _camera: Camera3D=null, animate:=true) -> Node:
	if not is_instance_valid(actor) or actor.removed or actor.state!=Climber.State.FROZEN:return null
	return attach_owner(actor,animate,true)
static func attach_owner(owner_node: Node, animate: bool, use_tower: bool) -> Node:
	var existing:=owner_node.get_node_or_null("Spiders")
	if existing!=null:return existing
	var effect:=new();effect.name="Spiders";effect.tower_enabled=use_tower
	effect.set_meta("persistent_lock_effect",true);effect.set_meta("ready",false)
	owner_node.add_child(effect);effect.set_process(false)
	effect.start(owner_node,animate)
	return effect
func start(owner_node: Node,animate: bool) -> void:
	await setup(owner_node)
	if owner_node is Climber:
		var center:=Vector3.ZERO
		for body in owner_node.bodies.values():center+=body.global_position
		center/=maxi(1,owner_node.bodies.size())
		Lod.register(self,LOD_GROUP,center,owner_node)
	lod_clock=rng.randf()*.25
	age=0.0 if animate else 6.6;tick(age)
	set_meta("ready",true);set_process(true)
func skin_hit(p: Vector2) -> float:
	var z:=-INF
	for t in cells.get(Vector2i(floori(p.x/.04),floori(p.y/.04)),[]):
		if not t[3].has_point(p):continue
		var a: Vector2=t[0];var b: Vector2=t[1];var c: Vector2=t[2]
		var den: float=(b-a).cross(c-a)
		if absf(den)<.0000001:continue
		var u: float=(p-a).cross(c-a)/den;var v: float=(b-a).cross(p-a)/den
		if u>=0 and v>=0 and u+v<=1:z=maxf(z,t[4]*(1-u-v)+t[5]*u+t[6]*v)
	return z
func tower_contact(p: Vector2) -> Dictionary:
	if not tower_enabled:return {}
	var cell:=Vector2i((p/.012).round())
	if tower_cache.has(cell):return tower_cache[cell]
	var q:=Vector2(cell)*.012
	var ray:=PhysicsRayQueryParameters3D.create(to_global(Vector3(q.x,q.y,depth_max)),to_global(Vector3(q.x,q.y,depth_min)),1)
	var result:=space.intersect_ray(ray);tower_queries+=1
	if not result.is_empty():
		if not result.collider is StaticBody3D:result={}
		else:result={"point":to_local(result.position),"collider":weakref(result.collider)}
	tower_cache[cell]=result
	return result
func hit(p: Vector2) -> float:
	var z:=skin_hit(p);var contact:=tower_contact(p)
	if not contact.is_empty():z=maxf(z,contact.point.z)
	return z
func add_spider(path: Array, offset: float, weaving:=false) -> void:
	if path.size()<2:return
	var spider:=MeshInstance3D.new();spider.mesh=spider_meshes[0];spider.material_override=CelPass.one();spider.scale=Vector3.ONE*.045
	spider.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(spider)
	var distances:=PackedFloat32Array([0.0])
	for i in range(1,path.size()):distances.append(distances[-1]+path[i-1].distance_to(path[i]))
	spiders.append({"node":spider,"path":path,"offset":offset,"weaving":weaving,"distances":distances})
func setup(actor: Node) -> void:
	owner_ref=weakref(actor);space=get_world_3d().direct_space_state;rng.randomize()
	for index in 13:
		prepare_unit(index)
		await get_tree().process_frame
	var parts: Dictionary={}
	for key in Climber.Layout.ORDER:
		var body: Node=actor.bodies.get(key) if actor is Climber else actor
		if body==null:continue
		var skin: Node=body.find_child(Climber.Layout.PIECES[key].mesh,true,false)
		if skin is MeshInstance3D:parts[key]=skin
		elif skin!=null:
			var meshes:=skin.find_children("*","MeshInstance3D",true,false)
			if not meshes.is_empty():parts[key]=meshes[0]
	# A single pose snapshot supplies front-surface tests; no physics raycasts.
	for key in parts:
		var skin: MeshInstance3D=parts[key]
		var arr:=skin.mesh.surface_get_arrays(0);var verts: PackedVector3Array=arr[Mesh.ARRAY_VERTEX];var ids: PackedInt32Array=arr[Mesh.ARRAY_INDEX]
		if ids.is_empty():for i in verts.size():ids.append(i)
		for i in range(0,ids.size(),3):
			var a:=to_local(skin.to_global(verts[ids[i]]));var b:=to_local(skin.to_global(verts[ids[i+1]]));var c:=to_local(skin.to_global(verts[ids[i+2]]))
			var aa:=Vector2(a.x,a.y);var bb:=Vector2(b.x,b.y);var cc:=Vector2(c.x,c.y)
			triangles.append([aa,bb,cc,Rect2(aa,Vector2.ZERO).expand(bb).expand(cc).grow(.00001),a.z,b.z,c.z])
		await get_tree().process_frame
	for tri in triangles:
		depth_min=minf(depth_min,minf(tri[4],minf(tri[5],tri[6]))-.12)
		depth_max=maxf(depth_max,maxf(tri[4],maxf(tri[5],tri[6]))+.12)
		var rect: Rect2=tri[3]
		for x in range(floori(rect.position.x/.04),floori(rect.end.x/.04)+1):
			for y in range(floori(rect.position.y/.04),floori(rect.end.y/.04)+1):
				var cell:=Vector2i(x,y)
				if not cells.has(cell):cells[cell]=[]
				cells[cell].append(tri)
	# Search empty space throughout the silhouette. Three-sided support is geometric,
	# not tied to anatomical names; neighboring body pieces may form the enclosure.
	var bounds:=Rect2()
	for tri in triangles:bounds=bounds.merge(tri[3])
	bounds=bounds.grow(.24)
	var occupied: Dictionary={}
	var step:=.018
	for y in range(floori(bounds.position.y/step),ceili(bounds.end.y/step)+1):
		for x in range(floori(bounds.position.x/step),ceili(bounds.end.x/step)+1):
			var point:=Vector2(x,y)*step;var z:=hit(point)
			if z!=-INF:occupied[Vector2i(x,y)]=z
		if y%8==0:await get_tree().process_frame
	var candidates: Array=[]
	for y in range(floori(bounds.position.y/step),ceili(bounds.end.y/step)+1,3):
		for x in range(floori(bounds.position.x/step),ceili(bounds.end.x/step)+1,3):
			var center:=Vector2(x,y)*step
			if occupied.has(Vector2i(x,y)):continue
			var support: Array=[];var min_radius:=INF;var max_gap:=0;var gap:=0
			for ray in 16:
				var direction:=Vector2.from_angle(TAU*ray/16);var found:=false
				for k in range(1,28):
					var cell:=Vector2i((Vector2(x,y)+direction*k).round())
					if occupied.has(cell):
						min_radius=minf(min_radius,k*step);found=true;break
				support.append(found)
			for ray in 32:
				gap=0 if support[ray%16] else gap+1;max_gap=maxi(max_gap,gap)
			if min_radius>=.055 and min_radius<.28 and support.count(true)>=10 and max_gap<=6:
				candidates.append({"center":center,"score":min_radius+support.count(true)*.003})
		if y%12==0:await get_tree().process_frame
	candidates.sort_custom(func(a,b):return a.score>b.score)
	var accepted: Array=[]
	for candidate in candidates:
		var center: Vector2=candidate.center+Vector2(rng.randf_range(-.008,.008),rng.randf_range(-.008,.008))
		var duplicate:=false
		for prev in accepted:
			if prev.center.distance_to(center)<maxf(.16,prev.radius+candidate.score*.65):duplicate=true
			if Geometry2D.is_point_in_polygon(center,prev.polygon):duplicate=true
		if duplicate or hit(center)!=-INF:continue
		var anchors: Array[Vector3]=[];var supported: Array[bool]=[]
		var tower_anchors:=0;var body_anchors:=0
		var spokes:=rng.randi_range(16,21);var phase:=rng.randf()*TAU
		for j in spokes:
			var dir:=Vector2.from_angle(phase+TAU*j/spokes+rng.randf_range(-.018,.018))
			var point:=center;var z:=0.0;var found:=false
			for k in range(1,72):
				point=center+dir*k*.007
				var surface:=hit(point)
				if surface!=-INF:
					var contact:=tower_contact(point)
					if not contact.is_empty() and contact.point.z>=skin_hit(point):
						point=Vector2(contact.point.x,contact.point.y);tower_anchors+=1
					else:body_anchors+=1
					z=surface+.008;found=true;break
			anchors.append(Vector3(point.x,point.y,z));supported.append(found)
		if supported.count(true)<spokes*.60 or body_anchors<3:continue
		# Open mouths get a tensioned frame between the last two real anchors,
		# rather than unsupported loose corners or a fan aimed off the body.
		for j in spokes:
			if supported[j]:continue
			var left:=1;var right:=1
			while not supported[posmod(j-left,spokes)]:left+=1
			while not supported[(j+right)%spokes]:right+=1
			anchors[j]=anchors[posmod(j-left,spokes)].lerp(anchors[(j+right)%spokes],float(left)/(left+right))
		var polygon:=PackedVector2Array()
		for anchor in anchors:polygon.append(Vector2(anchor.x,anchor.y))
		var overlaps:=false
		for prev in accepted:
			if outlines_overlap(polygon,prev.polygon):overlaps=true
		if overlaps:continue
		accepted.append({"center":center,"radius":candidate.score*.65,"polygon":polygon,"anchors":anchors,"tower_anchors":tower_anchors})
		await get_tree().process_frame
	set_meta("viable_pockets",accepted.size())
	for i in range(accepted.size()-1,0,-1):
		var j:=rng.randi_range(0,i);var swap=accepted[i];accepted[i]=accepted[j];accepted[j]=swap
	for candidate in accepted:
		# Recheck at placement, after all asynchronous pose work. Try another pocket
		# if a different player's effect reserved this one while we were preparing.
		if build_web(candidate.center,candidate.anchors):
			if candidate.tower_anchors>0:tower_webs+=1
		if webs.size()>=2:break
	# Closed three-dimensional routes on real skin triangles. Sampling progresses
	# in one direction around each body part; the spider never reverses or strafes.
	for key in ["chest","arm_l_lo","arm_r_up","leg_l_up","leg_r_lo","head"]:
		if not parts.has(key):continue
		var skin: MeshInstance3D=parts[key];var box:=skin.mesh.get_aabb();var faces:=skin.mesh.get_faces()
		var axis:=box.size.max_axis_index();var a:=(axis+1)%3;var b:=(axis+2)%3
		var path: Array=[];var normals: Array=[];var phase:=rng.randf()*TAU
		for i in 128:
			var angle:=phase+TAU*float(i)/128
			var core:=box.get_center();core[axis]+=box.size[axis]*.25*sin(angle*2)
			var radial:=Vector3.ZERO;radial[a]=cos(angle);radial[b]=sin(angle)
			var surface:=Fit.ray_surface(core+radial*3,box,faces,axis)
			if surface.distance_to(core)>2:continue
			var point:=skin.to_global(surface+radial*.006)
			path.append(to_local(point));normals.append((global_basis.inverse()*skin.global_basis*radial).normalized())
			if i%32==0:await get_tree().process_frame
		if path.size()<3:continue
		# Copy the seam exactly rather than sampling 2*PI again.
		path.append(path[0]);normals.append(normals[0])
		var tangents: Array[Vector3]=[]
		var count:=path.size()-1
		for i in count:
			tangents.append((path[(i+1)%count]-path[posmod(i-1,count)]).normalized())
		tangents.append(tangents[0])
		add_spider(path,rng.randf())
		spiders[-1]["normals"]=normals
		spiders[-1]["tangents"]=tangents
	set_meta("pocket_count",webs.size());set_meta("signature",signature);tick(0)
	# Pose-query data is temporary. Settled webs and crawl routes need no queries.
	triangles.clear();cells.clear();tower_cache.clear()
static func outlines_overlap(a: PackedVector2Array,b: PackedVector2Array) -> bool:
	if a.size()<3 or b.size()<3:return false
	# Full polygon intersection catches crossing edges as well as containment.
	for padded in Geometry2D.offset_polygon(a,WEB_CLEARANCE):
		if not Geometry2D.intersect_polygons(padded,b).is_empty():return true
	return false
func world_outline(anchors: Array[Vector3]) -> PackedVector2Array:
	var result:=PackedVector2Array()
	for anchor in anchors:
		var point:=to_global(anchor);result.append(Vector2(point.x,point.y))
	return result
func overlaps_existing(anchors: Array[Vector3]) -> bool:
	var candidate:=world_outline(anchors)
	for node in get_tree().get_nodes_in_group(WEB_GROUP):
		if not is_instance_valid(node) or node.is_queued_for_deletion() or not node is Node3D:continue
		if node.get_world_3d()!=get_world_3d():continue
		var outline:=PackedVector2Array()
		for vertex in node.get_meta("web_outline",PackedVector3Array()):
			var point: Vector3=node.to_global(vertex);outline.append(Vector2(point.x,point.y))
		if outlines_overlap(candidate,outline):return true
	return false
func build_web(center: Vector2,anchors: Array[Vector3]) -> bool:
	if overlaps_existing(anchors):blocked_webs+=1;return false
	var hub:=Vector3(center.x,center.y,0)
	for p in anchors:hub.z+=p.z/anchors.size()
	var segments: Array=[];var path: Array=[]
	# Frame and radial lines precede a gently uneven capture spiral.
	for j in anchors.size():segments.append([anchors[j],anchors[(j+1)%anchors.size()]])
	for j in anchors.size():segments.append([anchors[j],hub])
	var rings:=rng.randi_range(7,10)
	for ring in range(1,rings+1):
		for j in anchors.size():
			var t:=(ring+rng.randf_range(-.10,.10))/(rings+1.0)
			var u:=(ring+rng.randf_range(-.10,.10))/(rings+1.0)
			var a:=hub.lerp(anchors[j],t);var b:=hub.lerp(anchors[(j+1)%anchors.size()],u)
			var mid:=(a+b)*.5;mid+=(hub-mid)*.025
			segments.append([a,mid]);segments.append([mid,b])
	var mm:=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.mesh=thread_mesh;mm.instance_count=segments.size()
	for i in segments.size():
		var a: Vector3=segments[i][0];var b: Vector3=segments[i][1];var delta:=b-a
		var side:=delta.cross(Vector3.BACK).normalized()*.0025
		mm.set_instance_transform(i,Transform3D(Basis(side,delta,Vector3.BACK),a))
		path.append(a);path.append(b)
	var node:=MultiMeshInstance3D.new();node.multimesh=mm;node.material_override=CelPass.one();node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(node)
	# Reserve the entire eventual web immediately, including while still weaving.
	# Other web cosmetics can use this group and a node-local web_outline too.
	node.set_meta("web_outline",PackedVector3Array(anchors));node.add_to_group(WEB_GROUP)
	webs.append(mm);signature.append([center,anchors.size(),rings]);add_spider(path,0,true)
	return true
func tick(t: float) -> void:
	age=t
	var web_index:=0
	for data in spiders:
		var node: MeshInstance3D=data.node;var path: Array=data.path
		var progress:=clampf((age-.6)/6,0,1) if data.weaving else fposmod(age*.045+data.offset,1.0)
		var distances: PackedFloat32Array=data.distances
		var distance:=progress*distances[-1]
		var i:=clampi(distances.bsearch(distance)-1,0,path.size()-2)
		var at:=i+clampf((distance-distances[i])/maxf(.000001,distances[i+1]-distances[i]),0,1)
		if data.weaving:
			webs[web_index].visible_instance_count=mini(webs[web_index].instance_count,int(at/2)+1) if age>=.6 else 0
			if progress>=1:webs[web_index].visible_instance_count=-1
			web_index+=1
		node.position=path[i].lerp(path[i+1],at-i)+Vector3(0,0,.002)
		var dir: Vector3=(path[i+1]-path[i]).normalized()
		if data.has("tangents"):dir=data.tangents[i].lerp(data.tangents[i+1],at-i).normalized()
		var normal:=Vector3.BACK
		if data.has("normals"):normal=data.normals[i].lerp(data.normals[i+1],at-i).normalized()
		var right:=dir.cross(normal).normalized()
		if right.length_squared()>.1:node.basis=Basis(right,normal.cross(right).normalized(),normal).scaled(Vector3.ONE*.045)
		node.mesh=spider_meshes[0 if data.weaving and (age<.6 or progress>=1) else int(age*24+data.offset*12)%12];node.visible=age>.15
func _process(dt: float) -> void:
	if owner_ref!=null:
		var owner_node=owner_ref.get_ref()
		if not is_instance_valid(owner_node) or (owner_node is Climber and owner_node.removed):queue_free();return
	if age<6.6:tick(age+dt);return
	age+=dt;lod_elapsed+=dt;lod_clock+=dt
	if lod_clock>=.25:
		lod_clock=0;lod_interval=Lod.interval(self,LOD_GROUP,0.0)
	if lod_elapsed>=lod_interval:
		lod_elapsed=0;tick(age)
