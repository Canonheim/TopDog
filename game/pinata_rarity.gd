extends RefCounted
## Rarity ornamentation. The requested glow is local to this collectible.
const COLORS := [Color("ffffff"),Color("36dc70"),Color("398aff"),Color("ba54ff"),Color("ff3046")]
const GOLD := Color("ffdc80")
static var glow_shader: Shader
static var glow_materials := {}

static func decorate(star: MeshInstance3D, tier: int) -> void:
	CelPass.paint(star,COLORS[tier])
	var aura := MeshInstance3D.new()
	aura.name = "RarityGlow"
	var quad := QuadMesh.new()
	quad.size = Vector2(3.15,3.15)
	aura.mesh = quad
	aura.position.z = -.035
	aura.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	aura.material_override = _glow(tier)
	star.add_child(aura)
	if tier == 0: return
	# Fine inset contour retains the original five-point silhouette.
	var edge: Array[Vector2] = []
	for i in 10:
		var a := PI*.5+TAU*i/10
		edge.append(Vector2(cos(a),sin(a))*(.94 if i%2==0 else .423))
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 10:
		var j := (i+1)%10
		_quad(st,edge[i],edge[j],edge[j]*.955,edge[i]*.955)
	_add(st,star,GOLD,.008,"StarInlay")
	if tier == 1: return
	# Each blue tier point receives an independent faceted jewel.
	st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 5:
		var a := PI*.5+TAU*i/5
		var direction := Vector2(cos(a),sin(a))
		_diamond(st,direction*1.12,direction,.13,.065)
	_add(st,star,COLORS[tier].lightened(.52),.012,"TipJewels")
	if tier == 2: return
	# Purple gains five pairs of floating jewel accents.
	st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 10:
		var a := PI*.5+TAU*(i+.5)/10
		var direction := Vector2(cos(a),sin(a))
		_diamond(st,direction*1.29,direction,.07,.032)
	_add(st,star,COLORS[tier].lightened(.55),.015,"HaloJewels")
	if tier == 3: return
	# Red has a fivefold royal corona, a second star contour and paired leaves.
	st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 10:
		var j := (i+1)%10
		_quad(st,edge[i]*1.07,edge[j]*1.07,edge[j]*1.035,edge[i]*1.035)
	for i in 5:
		var a := PI*.5+TAU*i/5
		var direction := Vector2(cos(a),sin(a))
		_diamond(st,direction*1.44,direction,.19,.055)
		for side in [-1.0,1.0]:
			var tangent: Vector2 = Vector2(-direction.y,direction.x)*side
			var center: Vector2 = direction*1.13+tangent*.20
			_diamond(st,center,(direction*.6+tangent*.8).normalized(),.14,.048)
	_add(st,star,GOLD,.02,"RoyalCorona")

static func _triangle(st: SurfaceTool, a: Vector2,b: Vector2,c: Vector2) -> void:
	# Both sides keep slim jewelry readable throughout the turn.
	for point in [a,b,c,c,b,a]:
		st.set_normal(Vector3.BACK)
		st.add_vertex(Vector3(point.x,point.y,0))

static func _quad(st: SurfaceTool,a: Vector2,b: Vector2,c: Vector2,d: Vector2) -> void:
	_triangle(st,a,b,c)
	_triangle(st,a,c,d)

static func _diamond(st: SurfaceTool,at: Vector2,axis: Vector2,length: float,width: float) -> void:
	var cross_axis := Vector2(-axis.y,axis.x)
	_quad(st,at+axis*length,at+cross_axis*width,at-axis*length,at-cross_axis*width)

static func _add(st: SurfaceTool,parent: Node3D,color: Color,z: float,label: String) -> void:
	var piece := MeshInstance3D.new()
	piece.name = label
	piece.mesh = st.commit()
	piece.position.z = z
	piece.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(piece)
	CelPass.paint(piece,color)

static func _glow(tier: int) -> ShaderMaterial:
	if glow_materials.has(tier): return glow_materials[tier]
	if glow_shader == null:
		glow_shader = Shader.new()
		glow_shader.code = """shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, shadows_disabled;
uniform sampler2D atlas : source_color, filter_nearest;
uniform vec2 swatch;
uniform float strength;
void fragment(){
 vec2 p=(UV-vec2(0.5))*2.0;
 float angle=atan(p.y,p.x)-1.5707963;
 float ray=pow(0.5+0.5*cos(angle*5.0),5.0);
 float edge=0.35+0.32*ray;
 float outside=max(length(p)-edge,0.0);
 float haze=exp(-outside*7.0)*(1.0-smoothstep(0.68,1.0,length(p)));
 ALBEDO=texture(atlas,swatch).rgb;
 ALPHA=haze*strength;
}
"""
	var material := ShaderMaterial.new()
	material.shader = glow_shader
	material.set_shader_parameter("atlas",CelPass.ATLAS)
	material.set_shader_parameter("swatch",AtlasPalette.matte_uv(COLORS[tier]))
	material.set_shader_parameter("strength",.65+tier*.07)
	glow_materials[tier] = material
	return material
