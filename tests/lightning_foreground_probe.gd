extends Node
const Effect = preload("res://ui3d/lightning_effect.gd")
const Foreground = preload("res://ui3d/lightning_foreground.gd")
const Prep = preload("res://ui3d/lock_effect_preparation.gd")
var failures: Array[String] = []
func check(ok: bool,message: String) -> void:
	if not ok: failures.append(message)
func _ready() -> void:
	var original := Wardrobe.profiles.duplicate(true)
	Wardrobe.profiles[Wardrobe.selected].effect = "lightning"
	var main = load("res://game/main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame
	while not Prep.is_prepared("lightning"):
		Prep.prepare_step("lightning")
		await get_tree().process_frame
	main._start_practice()
	await get_tree().create_timer(.7).timeout
	var climber: Climber = main.game.live_climbers()[0]
	main.game._rpc_freeze(climber.climber_id,climber.pose(),"made","locked",2.0,2.0,true)
	var effect = climber.get_node_or_null("LightningStrike")
	check(effect != null,"Actual match dispatch creates effect")
	check(effect.clouds.size()==5 and effect.bolts.size()==3 and effect.cloud_sources.size()==3,"Five clouds but exactly three striking sources")
	var overlay = Foreground.ensure(main.cam)
	check(overlay.active.size()==1,"Match routed to shared foreground")
	check(overlay.layer>main.ui.layer,"Foreground above flat HUD")
	check(overlay.display.mouse_filter==Control.MOUSE_FILTER_IGNORE and overlay.view.gui_disable_input,"Overlay never captures menu/mouse input")
	check((main.cam.cull_mask & Foreground.EFFECT_LAYER)==0,"No duplicate world drawing")
	for piece in effect.get_children():
		if piece is GeometryInstance3D: check(piece.layers==Foreground.EFFECT_LAYER,"All clouds, bolts and rain routed")
	# Fixed camera and opaque HUD strip make an unambiguous occlusion regression.
	main.set_process(false)
	var focus: Vector3 = effect.impact+Vector3(0,.45,0)
	main.cam.global_position = focus+Vector3(0,0,4.2)
	main.cam.look_at(focus,Vector3.UP)
	var panel := ColorRect.new()
	panel.color = Color(.72,.08,.18,1)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main.ui.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.anchor_left = .18
	panel.anchor_right = .82
	panel.anchor_top = .16
	panel.anchor_bottom = .79
	var label := Label.new()
	label.text = "OPAQUE HUD OVERLAP TEST"
	label.position = Vector2(30,25)
	label.add_theme_font_size_override("font_size",30)
	panel.add_child(label)
	var rendered := "--render" in OS.get_cmdline_user_args()
	while effect.age<Effect.STRIKE_START+.04: await get_tree().process_frame
	check(overlay.eye.unproject_position(effect.impact).distance_to(main.cam.unproject_position(effect.impact))<.1,"Projection matches moved camera")
	check(overlay.view.size==Vector2i(get_viewport().get_visible_rect().size),"Viewport matches output dimensions")
	if rendered:
		effect.set_process(false)
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/lightning-extra-clouds/foreground-on.png")
		overlay.display.hide()
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/lightning-extra-clouds/foreground-off.png")
		overlay.display.show()
		panel.hide()
		main.lucha.set_process(false)
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/lightning-extra-clouds/preview.png")
		var cloud_screen: Vector2 = main.cam.unproject_position(effect.to_global(Vector3(0,1,0)))
		main.lucha._banner.global_position = main.cam.project_position(cloud_screen,2.0)
		main.lucha._banner.global_basis = main.cam.global_basis.scaled(Vector3.ONE*.25)
		main.lucha._banner.show()
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/lightning-extra-clouds/foreground-match.png")
		overlay.display.hide()
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("C:/Users/growi/Documents/ChatGPT/Top Dog/effect-reviews/lightning-extra-clouds/foreground-banner-off.png")
		overlay.display.show()
		effect.set_process(true)
	# Preview remains in the normal scene and never acquires foreground layers.
	var preview := Wardrobe.PUG.instantiate()
	add_child(preview)
	var preview_effect = Effect.preview(preview,main.cam)
	check(preview_effect != null,"Customization-style preview still available")
	for piece in preview_effect.get_children():
		if piece is GeometryInstance3D: check(piece.layers==1,"Preview remains normal world rendering")
	preview.queue_free()
	var viewport_id: int = overlay.view.get_instance_id()
	for i in 2:
		var other := Wardrobe.PUG.instantiate()
		add_child(other)
		var extra = Effect.strike(other,main.cam,true,true)
		Foreground.ensure(main.cam).include_effect(extra)
		other.get_tree().create_timer(.15).timeout.connect(other.queue_free)
	check(overlay.active.size()==3,"Concurrent storms share one overlay")
	check(overlay.view.get_instance_id()==viewport_id,"No viewport per storm")
	main.cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	main.cam.size = 7.0
	main.cam.h_offset = .1
	main.cam.v_offset = -.05
	main.cam.position.x += .2
	await get_tree().process_frame
	overlay._sync_camera()
	check(overlay.eye.unproject_position(effect.impact).distance_to(main.cam.unproject_position(effect.impact))<.1,"Orthographic offset projection alignment")
	var old_resolution: Vector2i = get_window().content_scale_size
	get_window().content_scale_size = Vector2i(1280,800)
	await get_tree().process_frame
	overlay._sync_camera()
	check(overlay.view.size==Vector2i(get_viewport().get_visible_rect().size),"Viewport follows resized output")
	check(overlay.eye.unproject_position(effect.impact).distance_to(main.cam.unproject_position(effect.impact))<.1,"Projection aligns after aspect resize")
	get_window().content_scale_size = old_resolution
	await get_tree().create_timer(Effect.TOTAL_SECONDS+.2).timeout
	check(overlay.active.is_empty(),"Owner cleanup empties shared overlay")
	check(overlay.view.render_target_update_mode==SubViewport.UPDATE_DISABLED,"No viewport rendering while idle")
	check(not overlay.display.visible,"No stale overlay texture after cleanup")
	check(not overlay.is_processing(),"No idle per-frame sync")
	Wardrobe.profiles = original
	main.queue_free()
	await get_tree().process_frame
	print("LIGHTNING_FOREGROUND ",JSON.stringify({"errors":failures,"rendered":rendered}))
	get_tree().quit(0 if failures.is_empty() else 1)
