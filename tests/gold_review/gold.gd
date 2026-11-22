extends Node3D
const Lod=preload("res://ui3d/lock_effect_lod.gd")
static var gold_material: ShaderMaterial
static var star_material: ShaderMaterial
static var star_mesh: ArrayMesh
var skins: Array=[]
var sites: Array[Vector3]=[]
var stars: Array=[]
var owner_ref: WeakRef
var age:=0.0
var rng:=RandomNumberGenerator.new()
var clock:=0.0
var lod_clock:=0.0
var interval:=0.0
static func prepare() -> void:
 if gold_material!=null:return
 gold_material=CelPass.one().duplicate();gold_material.shader=load("res://tests/gold_review/gold.gdshader")
 for entry in [["gold_dark","70400c"],["gold_base","d99b16"],["gold_light","ffd65a"],["gold_glint","fff4c4"]]:
  gold_material.set_shader_parameter(entry[0],AtlasPalette.swatch(Color(entry[1])).uv)
 star_material=ShaderMaterial.new();star_material.shader=load("res://tests/gold_review/star.gdshader")
 star_material.set_shader_parameter("base_texture",CelPass.one().get_shader_parameter("base_texture"))
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var uv: Vector2=AtlasPalette.swatch(Color("fff4c4")).uv
 for i in 8:
  var angle:=TAU*i/8;var next:=TAU*(i+1)/8
  var a:=Vector3(cos(angle),sin(angle),0)*(1.0 if i%2==0 else .15)
  var b:=Vector3(cos(next),sin(next),0)*(1.0 if (i+1)%2==0 else .15)
  for p in [Vector3.ZERO,a,b]:st.set_normal(Vector3.BACK);st.set_uv(uv);st.add_vertex(p)
 star_mesh=st.commit()
func setup(actor: Climber) -> void:
 prepare();rng.randomize();owner_ref=weakref(actor)
 var center:=Vector3.ZERO
 for key in Climber.Layout.ORDER:
  var body: Node=actor.bodies.get(key)
  if body==null:continue
  var skin: Node=body.find_child(Climber.Layout.PIECES[key].mesh,true,false)
  var meshes: Array=[]
  if skin is MeshInstance3D:meshes=[skin]
  elif skin!=null:meshes=skin.find_children("*","MeshInstance3D",true,false)
  for mesh: MeshInstance3D in meshes:
   skins.append({"node":mesh,"original":mesh.material_override});center+=mesh.global_position
   var faces:=mesh.mesh.get_faces()
   for i in 12:
    var at:=rng.randi_range(0,faces.size()/3-1)*3
    var point:=mesh.to_global((faces[at]+faces[at+1]+faces[at+2])/3)
    point.z=maxf(point.z,mesh.global_position.z+mesh.mesh.get_aabb().size.z*.5)+.045
    sites.append(to_local(point))
 # One atomic material swap; there is no traveling gold fill or fade.
 for entry in skins:entry.node.material_override=gold_material
 center/=maxi(1,skins.size());Lod.register(self,Lod.LEGENDARY_GROUP,center,actor)
 for i in 3:
  var star:=MeshInstance3D.new();star.mesh=star_mesh;star.material_override=star_material;star.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(star)
  stars.append({"node":star,"next":.18+i*.55,"start":-10.0,"duration":.6,"size":.04})
 tick(0)
func tick(t: float) -> void:
 age=t
 var camera:=get_viewport().get_camera_3d()
 for data in stars:
  if age>=data.next:
   data.start=age;data.duration=rng.randf_range(.45,.75);data.next=age+data.duration+rng.randf_range(.9,1.8)
   data.node.position=sites[rng.randi_range(0,sites.size()-1)];data.size=rng.randf_range(.025,.050)
  var phase:=clampf((age-data.start)/data.duration,0,1)
  var scale_value: float=sin(phase*PI)*data.size
  data.node.visible=scale_value>.001
  if camera!=null:data.node.global_basis=camera.global_basis.scaled(Vector3.ONE*maxf(.0001,scale_value))
func _process(dt: float) -> void:
 var actor=owner_ref.get_ref() if owner_ref!=null else null
 if not is_instance_valid(actor) or actor.removed:queue_free();return
 age+=dt;clock+=dt;lod_clock+=dt
 if lod_clock>=.25:lod_clock=0;interval=Lod.interval(self,Lod.LEGENDARY_GROUP,0)
 if clock>=interval:clock=0;tick(age)
func _exit_tree() -> void:
 for entry in skins:
  if is_instance_valid(entry.node) and entry.node.material_override==gold_material:entry.node.material_override=entry.original
