extends Node3D
## Three configurable fireworks: hot cores, colored halos, radial trails expanding from fixed burst centers.
## One shared quad and three atlas materials; instanced trails avoid hundreds of nodes.
const COLORS := [Color("ff3295"),Color("28e4ff"),Color("ffd34a")]
const RAYS := 48
const TRAIL := 4
var simultaneous := false
var elapsed := 0.0
var bursts: Array = []
var rng := RandomNumberGenerator.new()
static var spark_shader: Shader
func _ready() -> void:
	set_meta("xp_sparks",true)
	position = Vector3(0,-.1,-.18)
	rng.randomize()
	if spark_shader == null:
		spark_shader = Shader.new()
		spark_shader.code = """shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled;
uniform sampler2D atlas : source_color, filter_nearest;
uniform vec2 swatch;
void fragment() {
 vec2 p = UV * 2.0 - 1.0;
 float r = length(p);
 float halo = pow(max(0.0,1.0-r),1.35);
 float core = pow(max(0.0,1.0-r*3.5),2.0);
 vec3 color = texture(atlas,swatch).rgb;
 ALBEDO = (color*2.0 + vec3(core)*3.0) * COLOR.rgb;
 ALPHA = min(1.0, halo * 1.65) * COLOR.a;
}
"""
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE
	for i in 3:
		var material := ShaderMaterial.new()
		material.shader = spark_shader
		material.set_shader_parameter("atlas",CelPass.ATLAS)
		material.set_shader_parameter("swatch",AtlasPalette.matte_uv(COLORS[i]))
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.use_colors = true
		mm.mesh = quad
		mm.instance_count = RAYS*TRAIL+10
		var draw := MultiMeshInstance3D.new()
		draw.multimesh = mm
		draw.material_override = material
		draw.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(draw)
		for j in mm.instance_count: mm.set_instance_color(j,Color(0,0,0,0))
		var rays: Array = []
		for j in RAYS:
			var angle := TAU*(j+rng.randf_range(-.3,.3))/RAYS
			var speed := rng.randf_range(2.8,4.7)*(1.0 if j%3 else .55)
			rays.append({"velocity":Vector2(cos(angle),sin(angle))*speed,"life":rng.randf_range(1.2,1.7),"phase":rng.randf()*TAU})
		bursts.append({"mesh":mm,"rays":rays,"delay":rng.randf_range(0.0, 0.4) if simultaneous else i*.22,  # (Parker 11-19: "stagger the shots a little so they don't all go off at once")
			"target":Vector2([-1.4,0.0,1.4][i],[1.3,2.0,1.3][i])})

func point(mm: MultiMesh, index: int, at: Vector2, size: Vector2, light: float) -> void:
	mm.set_instance_transform(index,Transform3D(Basis().scaled(Vector3(size.x*1.65,size.y*1.65,1)),Vector3(at.x,at.y,0)))
	mm.set_instance_color(index,Color(1,1,1,clampf(light,0,1)))

func trajectory(v: Vector2, t: float) -> Vector2:
	# Decelerate along the original ray; neither rim adds vertical drift after the pop.
	return v*(1.0-exp(-1.4*t))/1.4

func _process(delta: float) -> void:
	elapsed += delta
	for burst in bursts:
		var age: float = elapsed-burst.delay
		if age<0: continue
		var mm: MultiMesh = burst.mesh
		var target: Vector2 = burst.target
		var t := age-.38
		# Rocket head and tapering ascent trail, then a brief central flash.
		for j in 10:
			if t<0:
				var travel := clampf((age-j*.012)/.38,0,1)
				point(mm,RAYS*TRAIL+j,target*travel,Vector2.ONE*(.10-j*.007),1-j*.085)
			else:
				point(mm,RAYS*TRAIL+j,target,Vector2.ONE*(.15+t*2.5),maxf(0,1-t/.16) if j==0 else 0)
		if t<0: continue
		for j in RAYS:
			var ray: Dictionary = burst.rays[j]
			var v: Vector2 = ray.velocity
			for tail in TRAIL:
				var sample_t := maxf(0,t-tail*.035)
				var pos := target+trajectory(v,sample_t)
				var fade := pow(maxf(0,1-t/float(ray.life)), .7)
				var twinkle := .75+.25*sin(t*24+float(ray.phase))
				var size := (.12 if tail==0 else .085)*(.45+.55*fade)
				point(mm,j*TRAIL+tail,pos,Vector2.ONE*size,fade*twinkle*(1-tail*.19))
	if elapsed>2.7: queue_free()
