extends Node3D
const Effect=preload("res://tests/spider_web_review/webs.gd")
const OUT="C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/spider-webs/"
func _ready() -> void:
	get_window().size=Vector2i(1100,850)
	get_viewport().msaa_3d=Viewport.MSAA_4X
	var environment:=WorldEnvironment.new();environment.environment=Environment.new()
	environment.environment.background_mode=Environment.BG_COLOR
	environment.environment.background_color=Color("737e83")
	environment.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color=Color.WHITE;environment.environment.ambient_light_energy=.65
	add_child(environment)
	var sun:=DirectionalLight3D.new();sun.rotation_degrees=Vector3(-25,-25,0);add_child(sun)
	Effect.prepare()
	var spider:=MeshInstance3D.new();spider.mesh=Effect.spider_meshes[0];spider.material_override=CelPass.one();add_child(spider)
	var camera:=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=1.25
	add_child(camera);camera.position=Vector3(0,0,3);camera.look_at(Vector3.ZERO,Vector3.UP)
	for i in 3:await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(OUT+"spider-closeup.png")
	camera.position=Vector3(.7,-1.1,2.6);camera.look_at(Vector3.ZERO,Vector3.UP)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(OUT+"spider-closeup-angle.png")
	print("SPIDER_CLOSEUP_COMPLETE")
	get_tree().quit()
