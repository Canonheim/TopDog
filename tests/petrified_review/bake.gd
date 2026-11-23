extends Node
func _ready() -> void:
 var material:=CelPass.one().duplicate();material.shader=load("res://tests/petrified_review/stone.gdshader")
 for entry in [["stone_dark","484d4a"],["stone_base","91958e"],["stone_light","b5b8ad"],["moss_dark","334b28"],["moss_green","6d8240"]]:material.set_shader_parameter(entry[0],AtlasPalette.swatch(Color(entry[1])).uv)
 ResourceSaver.save(material,"res://tests/petrified_review/stone.tres")
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var green: Vector2=AtlasPalette.swatch(Color("537c32")).uv
 var yellow: Vector2=AtlasPalette.swatch(Color("edca34")).uv
 var gold: Vector2=AtlasPalette.swatch(Color("c59d22")).uv
 for band in 12:
  var y0:=band*.0045;var y1:=(band+1)*.0045
  for side in 6:
   var a:=TAU*side/6;var b:=TAU*(side+1)/6
   var p:=Vector3(cos(a)*.0016,y0,sin(a)*.0016);var q:=Vector3(cos(b)*.0016,y0,sin(b)*.0016)
   for v in [p,q,q+Vector3.UP*.0045,p,q+Vector3.UP*.0045,p+Vector3.UP*.0045]:st.set_uv(green);st.add_vertex(v)
 for ring in 3:
  for petal in 20:
   var angle:=TAU*petal/20+ring*.24
   var radius:=.006+ring*.004
   var middle:=Vector3(cos(angle)*radius,.060-ring*.0015,sin(angle)*radius)
   var side:=Vector3(-sin(angle),0,cos(angle))*.0018
   var tip:=middle+Vector3(cos(angle)*.005,.003,sin(angle)*.005)
   for v in [Vector3(0,.054,0),middle-side,tip,Vector3(0,.054,0),tip,middle+side]:st.set_uv(yellow if petal%3 else gold);st.add_vertex(v)
 st.generate_normals();ResourceSaver.save(st.commit(),"res://tests/petrified_review/dandelion.res")
 var flower_material:=ShaderMaterial.new();flower_material.shader=load("res://tests/petrified_review/flower.gdshader");flower_material.set_shader_parameter("atlas",CelPass.ATLAS);ResourceSaver.save(flower_material,"res://tests/petrified_review/flower.tres")
 var rock:=PrismMesh.new();rock.size=Vector3(.026,.035,.022);ResourceSaver.save(rock,"res://tests/petrified_review/rock.res")
 var rm:=ShaderMaterial.new();rm.shader=load("res://tests/petrified_review/rock.gdshader");rm.set_shader_parameter("atlas",CelPass.ATLAS);rm.set_shader_parameter("swatch",AtlasPalette.swatch(Color("91958e")).uv);ResourceSaver.save(rm,"res://tests/petrified_review/rock.tres")
 var dm:=ShaderMaterial.new();dm.shader=load("res://tests/petrified_review/dust.gdshader");dm.set_shader_parameter("atlas",CelPass.ATLAS);dm.set_shader_parameter("swatch",AtlasPalette.swatch(Color("91958e")).uv);ResourceSaver.save(dm,"res://tests/petrified_review/dust.tres")
 var grass:=SurfaceTool.new();grass.begin(Mesh.PRIMITIVE_TRIANGLES)
 var greens: Array=[AtlasPalette.swatch(Color("537c32")).uv,AtlasPalette.swatch(Color("6d8240")).uv]
 for blade in 6:
  var angle:=blade*2.39996
  var side:=Vector3(cos(angle),0,sin(angle))
  var length: float=[.055,.080,.065,.090,.060,.073][blade]
  var lean:=Vector3(-sin(angle),0,cos(angle))*.025
  for segment in 4:
   var t0:=segment/4.;var t1:=(segment+1)/4.
   var c0:=Vector3.UP*length*t0+lean*t0*t0
   var c1:=Vector3.UP*length*t1+lean*t1*t1
   var w0:=.0038*(1-t0);var w1:=.0038*(1-t1)
   for sign in [-1.,1.]:
    var a: Vector3=c0+side*w0*sign;var b: Vector3=c1+side*w1*sign
    var ridge0:=c0+Vector3(0,0,.0014)*(1-t0);var ridge1:=c1+Vector3(0,0,.0014)*(1-t1)
    for v in [a,b,ridge1,a,ridge1,ridge0]:grass.set_uv(greens[0 if sign<0 else 1]);grass.add_vertex(v)
 grass.generate_normals();ResourceSaver.save(grass.commit(),"res://tests/petrified_review/grass.res")
 var gm:=ShaderMaterial.new();gm.shader=load("res://tests/petrified_review/grass.gdshader");gm.set_shader_parameter("atlas",CelPass.ATLAS);ResourceSaver.save(gm,"res://tests/petrified_review/grass.tres")
 print("PETRIFIED_MATERIAL_SAVED");get_tree().quit()
