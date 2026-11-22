extends Node3D
const Effect=preload("res://ui3d/spiders_effect.gd")
var errors: Array[String]=[]
func check(ok: bool,label: String) -> void:
	if not ok:errors.append(label);push_error(label)
func rect(x: float,y: float,w: float,h: float) -> Array[Vector3]:
	return [Vector3(x,y,0),Vector3(x+w,y,0),Vector3(x+w,y+h,0),Vector3(x,y+h,0)]
func _ready() -> void:
	Effect.prepare()
	var a:=Effect.new();var b:=Effect.new();add_child(a);add_child(b)
	a.set_process(false);b.set_process(false)
	check(a.build_web(Vector2(.5,.5),rect(0,0,1,1)),"First player's web reserves area")
	check(not b.build_web(Vector2(.5,.5),rect(.2,.2,.3,.3)),"Another player's contained web blocked before growth")
	check(not b.build_web(Vector2(.5,.5),rect(-.2,.4,1.4,.2)),"Crossing edges blocked without contained corners")
	check(not b.build_web(Vector2(.5,.5),rect(-.1,-.1,1.2,1.2)),"Enclosing candidate blocked")
	check(not b.build_web(Vector2(1.2,.5),rect(1.003,.2,.4,.4)),"Strand clearance margin respected")
	check(b.build_web(Vector2(1.5,.5),rect(1.2,.2,.4,.4)),"Clear alternative pocket accepted")
	check(not a.build_web(Vector2(1.5,.5),rect(1.2,.2,.4,.4)),"Same shared registry covers both owners")
	a.free()
	check(b.build_web(Vector2(.5,.5),rect(.2,.2,.3,.3)),"Owner removal releases occupied space")
	var viewport:=SubViewport.new();viewport.own_world_3d=true;add_child(viewport)
	var isolated:=Effect.new();viewport.add_child(isolated);isolated.set_process(false)
	check(isolated.build_web(Vector2(.5,.5),rect(.2,.2,.3,.3)),"Separate preview world remains independent")
	var total:=get_tree().get_nodes_in_group(Effect.WEB_GROUP).size()
	b.free();viewport.free()
	check(get_tree().get_nodes_in_group(Effect.WEB_GROUP).is_empty(),"No stale reservations after cleanup")
	var f:=FileAccess.open("C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/spider-webs/overlap-checks.json",FileAccess.WRITE)
	f.store_string(JSON.stringify({"errors":errors,"registered_before_cleanup":total,"cross_owner":true,"in_progress_reserved":true},"  "));f.close()
	print("WEB_OVERLAP ",JSON.stringify({"errors":errors,"registered_before_cleanup":total}))
	get_tree().quit(0 if errors.is_empty() else 1)
