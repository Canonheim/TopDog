extends Node3D
const FX=preload("res://ui3d/petrified/effect.gd")
const AUDIO=preload("res://ui3d/petrified/audio.gd")
var fails:=0
func check(label: String, ok: bool) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok:fails+=1
func model() -> Node3D:
 var actor:=Node3D.new();add_child(actor)
 var mesh:=MeshInstance3D.new();mesh.name=Climber.Layout.PIECES[Climber.Layout.ORDER[0]].mesh;mesh.mesh=BoxMesh.new();actor.add_child(mesh)
 return actor
func _ready() -> void:
 check("all approved clips available",AUDIO.ENCASING.size()==3 and AUDIO.CRUMBLE.size()==10)
 for clip in AUDIO.ENCASING:check("encasing playback matches 2.2 seconds",absf(clip.get_length()/1.15-2.2)<.001)
 var actor:=model();var fx:=FX.new();actor.add_child(fx);fx.setup(actor,true);fx.set_process(false)
 var voice:=fx.get_node_or_null("StoneEncasingSound") as AudioStreamPlayer3D
 check("encasing starts with animation",voice!=null and voice.playing and is_equal_approx(voice.pitch_scale,1.15) and voice.bus=="Effects")
 fx.debris=FX.DEBRIS.new();fx.add_child(fx.debris)
 check("no crumble while stone is forming",not fx.on_grab(Vector3.ZERO) and fx.get_node_or_null("StoneCrumbleSound")==null)
 fx.tick(FX.DURATION)
 check("accepted grab starts crumble",fx.on_grab(Vector3.ZERO))
 var crumble:=fx.get_node_or_null("StoneCrumbleSound") as AudioStreamPlayer3D
 check("approved crumble plays at original speed",crumble!=null and crumble.playing and AUDIO.CRUMBLE.has(crumble.stream) and crumble.pitch_scale==1.0)
 check("active burst rejects extra sounds",not fx.on_grab(Vector3.ZERO))
 var restored:=model();var silent:=FX.new();restored.add_child(silent);silent.setup(restored,false);silent.set_process(false)
 check("restored stone is silent",silent.get_node_or_null("StoneEncasingSound")==null)
 await get_tree().create_timer(2.5).timeout
 check("finished voices cleaned up",not is_instance_valid(voice) and not is_instance_valid(crumble))
 print("RESULT fails=",fails);get_tree().quit(fails)
