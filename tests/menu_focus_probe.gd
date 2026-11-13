extends Node
var failures := 0
func check(ok: bool, label: String) -> void:
	print(("PASS " if ok else "FAIL ") + label)
	if not ok:
		failures += 1
func point_at(menu: Menu3D, at: Vector2) -> void:
	get_viewport().warp_mouse(at)
	var event := InputEventMouseMotion.new()
	event.position = at
	event.global_position = at
	event.relative = Vector2(5, 0)
	get_viewport().push_input(event, true)
	menu._unhandled_input(event)
	menu._process(0.016)
func _ready() -> void:
	var main = load("res://game/main.tscn").instantiate()
	get_tree().root.add_child.call_deferred(main)
	await get_tree().create_timer(1.0).timeout
	main.show_screen("pause")
	await get_tree().create_timer(0.9).timeout
	Players._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
	var menu: Menu3D = main.lucha.menus.pause
	var at: Vector2 = main.cam.unproject_position(menu.items[0].node.global_position)
	point_at(menu, at)
	check(menu._pick(at) == 0 and menu.cursor.visible, "Star appears over a real menu option")
	point_at(menu, Vector2(-100, -100))
	check(not menu.cursor.visible, "Star disappears off menu options")
	var nav := InputEventAction.new()
	nav.action = "ui_down"
	nav.pressed = true
	menu._unhandled_input(nav)
	menu._process(0.016)
	check(menu.cursor.visible, "Keyboard/controller navigation keeps focus visible")
	point_at(menu, Vector2(-100, -100))
	check(not menu.cursor.visible, "Moving mouse restores hover-only star")
	point_at(menu, at)
	get_window().mouse_exited.emit()
	menu._process(0.016)
	check(not menu.cursor.visible, "Star hides when pointer leaves window")
	get_window().mouse_entered.emit()
	for screen in ["pause", "practice_ai", "options", "title"]:
		main.show_screen(screen)
		Players._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
		main._process(0.0)
		check(main._focus_notice.visible, "Actual focus loss shows alert on " + screen)
		Players._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
		main._process(0.0)
		check(not main._focus_notice.visible, "Focus recovery clears alert on " + screen)
	var notice: Label = main._focus_notice
	check(notice.text == "Click Game Window to regain controls.", "Alert uses requested wording")
	check(notice.anchor_right == 1 and notice.anchor_bottom == 1 and notice.grow_horizontal == Control.GROW_DIRECTION_BEGIN, "Alert is anchored bottom right")
	check(notice.get_theme_font("font").font_weight == 700 and notice.get_theme_color("font_color") == Color("#FF3232"), "Alert is bold red")
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--shot="):
			main.show_screen("pause")
			Players._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
			await get_tree().create_timer(0.8).timeout
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png(arg.get_slice("=", 1))
	get_tree().quit(failures)
