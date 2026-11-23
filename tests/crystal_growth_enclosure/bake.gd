extends Node
func _ready() -> void:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var colors: Array=["e2eeee","b9d5df","ffffff","d0e2e7","f0f3ed","aec8d4"]
 for side in 6:
  var a:=TAU*side/6.;var b:=TAU*(side+1)/6.
  var p:=Vector3(cos(a),0,sin(a));var q:=Vector3(cos(b),0,sin(b))
  var r:=Vector3(cos(a)*.88,.72+sin(a)*.07,sin(a)*.88)
  var s:=Vector3(cos(b)*.88,.72+sin(b)*.07,sin(b)*.88)
  var tip:=Vector3(.12,1.0,-.08)
  var uv: Vector2=AtlasPalette.swatch(Color(colors[side])).uv
  for tri in [[[p,r,s],[Vector2(0,0),Vector2(0,.72),Vector2(1,.72)]],[[p,s,q],[Vector2(0,0),Vector2(1,.72),Vector2(1,0)]],[[r,tip,s],[Vector2(0,.72),Vector2(.5,1),Vector2(1,.72)]],[[Vector3.ZERO,p,q],[Vector2(.5,.5),Vector2(0,0),Vector2(1,0)]]]:
   for i in 3:st.set_uv(uv);st.set_uv2(tri[1][i]);st.add_vertex(tri[0][i])
 st.generate_normals();ResourceSaver.save(st.commit(),"res://tests/crystal_growth_enclosure/shard.res")
 var mat:=ShaderMaterial.new();mat.shader=load("res://tests/crystal_growth_enclosure/crystal.gdshader");mat.set_shader_parameter("atlas",CelPass.ATLAS)
 ResourceSaver.save(mat,"res://tests/crystal_growth_enclosure/crystal.tres")
 var film:=CelPass.one().duplicate();film.shader=load("res://tests/crystal_growth_enclosure/film.gdshader");film.set_shader_parameter("stone_light",AtlasPalette.swatch(Color("e2eeee")).uv)
 film.set_shader_parameter("cool_body",AtlasPalette.swatch(Color("8da9b3")).uv)
 ResourceSaver.save(film,"res://tests/crystal_growth_enclosure/film.tres")
 var aura:=ShaderMaterial.new();aura.shader=load("res://tests/crystal_growth_enclosure/aura.gdshader");aura.set_shader_parameter("atlas",CelPass.ATLAS);aura.set_shader_parameter("swatch",AtlasPalette.swatch(Color("e2eeee")).uv)
 ResourceSaver.save(aura,"res://tests/crystal_growth_enclosure/aura.tres")
 var shades:=Resource.new();var uvs: Array=[]
 for color in ["ffffff","7cbce7","d94d5b","d58ed4","e7b47d","9dcc9a","a68bd3","ffffff"]:uvs.append(AtlasPalette.swatch(Color(color)).uv)
 shades.set_meta("uvs",uvs);ResourceSaver.save(shades,"res://tests/crystal_growth_enclosure/shades.res")
 for entry in [[mat,"crystal"],[film,"film"],[aura,"aura"]]:
  entry[0].set_shader_parameter("spectrum",PackedVector2Array(uvs.slice(0,7)))
  ResourceSaver.save(entry[0],"res://tests/crystal_growth_enclosure/"+entry[1]+".tres")
 bake_shell()
 bake_roots()
 print("CRYSTAL_BAKED 24 triangles");get_tree().quit()


func closest(p: Vector3,a: Vector3,b: Vector3,c: Vector3) -> Vector3:
 var ab:=b-a;var ac:=c-a;var ap:=p-a;var d1:=ab.dot(ap);var d2:=ac.dot(ap)
 if d1<=0 and d2<=0:return a
 var bp:=p-b;var d3:=ab.dot(bp);var d4:=ac.dot(bp)
 if d3>=0 and d4<=d3:return b
 var vc:=d1*d4-d3*d2
 if vc<=0 and d1>=0 and d3<=0:return a+ab*(d1/(d1-d3))
 var cp:=p-c;var d5:=ab.dot(cp);var d6:=ac.dot(cp)
 if d6>=0 and d5<=d6:return c
 var vb:=d5*d2-d1*d6
 if vb<=0 and d2>=0 and d6<=0:return a+ac*(d2/(d2-d6))
 var va:=d3*d6-d5*d4
 if va<=0 and d4-d3>=0 and d5-d6>=0:return b+(c-b)*((d4-d3)/((d4-d3)+(d5-d6)))
 var den:=va+vb+vc
 if absf(den)<1e-20:return a
 return a+ab*(vb/den)+ac*(vc/den)
func bake_roots() -> void:
 var body=load("res://ui3d/spider_body_geometry.res")
 var surfaces: Dictionary=body.get_meta("surfaces");var result: Dictionary={};var rng:=RandomNumberGenerator.new();rng.seed=981271
 for source in surfaces:
  var geo: Dictionary=surfaces[source];var vv: PackedVector3Array=geo.vertices;var ids: PackedInt32Array=geo.indices
  var sites: Array=[]
  for attempt in 128:
   var i:=rng.randi_range(0,ids.size()/3-1)*3
   var a:=vv[ids[i]];var b:=vv[ids[i+1]];var c:=vv[ids[i+2]]
   var n: Vector3=(geo.normals[ids[i]]+geo.normals[ids[i+1]]+geo.normals[ids[i+2]]).normalized()
   if n.length_squared()<.5:continue
   var u:=sqrt(rng.randf());var v:=rng.randf();var point:=a*(1-u)+b*u*(1-v)+c*u*v
   var exit_dist:=INF
   for j in range(0,ids.size(),3):
    var hit=Geometry3D.ray_intersects_triangle(point-n*.0001,-n,vv[ids[j]],vv[ids[j+1]],vv[ids[j+2]])
    if hit!=null:
     var d: float=point.distance_to(hit)
     if d>.0005:exit_dist=minf(exit_dist,d)
   if is_inf(exit_dist):continue
   var depth:=exit_dist*rng.randf_range(.18,.35)
   var origin:=point-n*depth
   var safe_sq:=INF
   var crossings:=0
   var ray:=Vector3(.8123,.3179,.4891).normalized()
   for j in range(0,ids.size(),3):
    a=vv[ids[j]];b=vv[ids[j+1]];c=vv[ids[j+2]]
    safe_sq=minf(safe_sq,origin.distance_squared_to(closest(origin,a,b,c)))
    if Geometry3D.ray_intersects_triangle(origin,ray,a,b,c)!=null:crossings+=1
   if crossings%2==0:continue
   var clearance:=sqrt(safe_sq)*.90
   if clearance<.001:continue
   sites.append({"origin":origin,"surface":point,"normal":n,"clearance":clearance,"depth":depth})
  result[source]=sites
  print("CRYSTAL_SITES ",source," count ",sites.size())
 var resource:=Resource.new();resource.set_meta("sites",result)
 ResourceSaver.save(resource,"res://tests/crystal_growth_enclosure/roots.res")

func bake_shell() -> void:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var rings: Array=[]
 for ring in [[-.5,.37],[-.27,.57],[.22,.57],[.46,.37]]:
  var points: Array=[]
  for i in 8:
   var angle:=TAU*i/8+PI/8+sin(float(ring[0])*8.0)*.10
   points.append(Vector3(cos(angle)*ring[1],ring[0],sin(angle)*ring[1]))
  rings.append(points)
 var triangles: Array=[]
 for row in 3:
  for i in 8:
   var j: int=(i+1)%8
   triangles.append([rings[row][i],rings[row+1][i],rings[row+1][j]])
   triangles.append([rings[row][i],rings[row+1][j],rings[row][j]])
 for i in 8:
  var j: int=(i+1)%8
  triangles.append([rings[3][i],Vector3(.08,.63,-.04),rings[3][j]])
  triangles.append([rings[0][j],Vector3(-.05,-.62,.03),rings[0][i]])
 var rng:=RandomNumberGenerator.new();rng.seed=9124
 for triangle in triangles:
  var shade:=rng.randf_range(.12,1.)
  for i in 3:
   st.set_color(Color(shade,shade,shade,1));st.set_uv2([Vector2.ZERO,Vector2.RIGHT,Vector2.UP][i]);st.add_vertex(triangle[i])
 st.generate_normals();ResourceSaver.save(st.commit(),"res://tests/crystal_growth_enclosure/shell.res")
 var material:=ShaderMaterial.new();material.shader=load("res://tests/crystal_growth_enclosure/shell.gdshader");material.set_shader_parameter("atlas",CelPass.ATLAS);material.set_shader_parameter("pale",AtlasPalette.swatch(Color("c9e2ef")).uv)
 ResourceSaver.save(material,"res://tests/crystal_growth_enclosure/shell.tres")
