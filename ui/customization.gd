extends Control
## The wardrobe shares the ring, lighting, atlas and Menu3D controls.
var main: Node
var menu: Menu3D
var stage: Node3D
var preview: Node3D
var hidden_base: Node3D
var base_was_visible := true
var active := false
var turn: Tween
var status: Node3D
var confirmation: Menu3D
var confirming := false

func _init(owner_main: Node) -> void:
	main = owner_main
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func on_screen(id: String) -> void:
	if id != "customize":
		confirming = false
		if confirmation != null:
			confirmation.close()
		if active:
			active = false
			stage.visible = false
			if is_instance_valid(hidden_base):
				hidden_base.visible = base_was_visible
		return
	if menu == null:
		_build()
	var entering := not active
	active = true
	stage.visible = true
	if is_instance_valid(main.game.stage.base_root):
		hidden_base = main.game.stage.base_root
		if entering:
			base_was_visible = hidden_base.visible
		hidden_base.hide()
	_refresh()
	menu.open()
	main._tick_camera(0.0)

func _build() -> void:
	menu = main.lucha._menu()
	main.lucha.menus.customize = menu
	menu.scale = Vector3.ONE * 0.43
	# The column where every column menu stands, the banner where every name goes (the
	# UI pass, 1f): this menu is drawn at 0.43, so the shared numbers are scaled to it.
	var k := LuchaUI.UI_SCALE / 0.43
	menu.column_x = Menu3D.MENU_COLUMN_X * k
	menu.top_y = Menu3D.MENU_TOP_Y * k
	menu.item_spacing = 0.84
	var banner := LuchaKit.banner("CREATE YOUR CLIMBERS", 1.1 * k)
	menu.set_header(banner, Vector3(0, 3.2 * k, 0))
	menu.add_choice("CLIMBER", _climber_names(), Wardrobe.selected, _select_climber)
	menu.add_choice("HEAD", ["PUG", "SPIRAL"], 0, func(i): _set_choice("head", i))
	menu.add_choice("SKIN", Wardrobe.SKIN_NAMES, 0, func(i): _set_choice("skin", i))
	menu.add_choice("SPEEDO", Wardrobe.SUIT_NAMES, 0, func(i): _set_choice("speedo", i))
	menu.add_choice("EFFECT", Wardrobe.EFFECT_NAMES, 0, func(i): _set_choice("effect", Wardrobe.EFFECTS[i]))
	for i in [1, 2, 3, 4]:
		menu.items[i].value_only = true  # the value alone: the climber beside them shows what each changes
	menu.add_button("NEW CLIMBER", _add_climber)
	menu.add_button("DELETE", _ask_delete)
	menu.add_button("BACK", func(): main.show_screen("title"))
	stage = Node3D.new()
	stage.name = "CustomizationDisplay"
	main.world.add_child(stage)
	var platform := LuchaKit.kit_model("customization_platform")
	platform.name = "DisplayPlatform"
	platform.scale = Vector3(1.4, 1.0, 1.2)
	stage.add_child(platform)

func _climber_names() -> Array:
	var names: Array = []
	for i in Wardrobe.profiles.size():
		# A selector label only; no counter floats above the character.
		names.append(str(i+1))
	return names

func _select_climber(index: int) -> void:
	var direction := 1 if index > Wardrobe.selected else -1
	Wardrobe.selected = index
	Wardrobe.save()
	_refresh(direction)

func _cycle(direction: int) -> void:
	_select_climber(posmod(Wardrobe.selected + direction, Wardrobe.profiles.size()))

func _set_choice(field: String, value: Variant) -> void:
	Wardrobe.profiles[Wardrobe.selected][field] = value
	Wardrobe.save()
	_refresh()
	if field == "effect":
		main.lucha.play_lock_effect(str(value))

func _add_climber() -> void:
	if Wardrobe.profiles.size() >= 100:
		return
	Wardrobe.profiles.append(Wardrobe.clean({}))
	Wardrobe.selected = Wardrobe.profiles.size()-1
	Wardrobe.save()
	_refresh(1)

func _ask_delete() -> void:
	if confirmation == null:
		confirmation = main.lucha._menu()
		main.lucha.menus.customize_delete = confirmation
		confirmation.column_x = -2.0
		confirmation.top_y = 0.4
		confirmation.add_button("YES, DELETE", _confirm_delete)
		confirmation.add_button("CANCEL", _cancel_delete)
	var question := "DELETE CLIMBER %d?\nARE YOU SURE?" % (Wardrobe.selected+1)
	if Wardrobe.profiles.size() == 1:
		question += "\nA NEW DEFAULT CLIMBER WILL REPLACE IT."
	confirmation.set_header(LuchaKit.poster_text(question, 0.25, LuchaKit.GOLD, LuchaKit.RED), Vector3(-1.0, 1.8, 0))
	AtlasPalette.theme_tree(confirmation)
	confirming = true
	menu.close()
	confirmation.open()
	confirmation.focus = 1

func _cancel_delete() -> void:
	confirming = false
	confirmation.close()
	menu.open()
	menu.focus = 6  # DELETE CLIMBER

func _confirm_delete() -> void:
	if not confirming:
		return
	Wardrobe.profiles.remove_at(Wardrobe.selected)
	if Wardrobe.profiles.is_empty():
		Wardrobe.profiles.append(Wardrobe.clean({}))
	Wardrobe.selected = mini(Wardrobe.selected, Wardrobe.profiles.size()-1)
	Wardrobe.save()
	_cancel_delete()
	_refresh()

func _refresh(direction := 0) -> void:
	var p: Dictionary = Wardrobe.profiles[Wardrobe.selected]
	menu.items[0].options = _climber_names()
	menu.items[0].index = Wardrobe.selected
	menu.items[1].index = p.head
	menu.items[2].index = p.skin
	menu.items[3].index = p.speedo
	menu.items[4].index = Wardrobe.EFFECTS.find(p.effect)
	for i in 5:
		menu._relabel(i)
	menu.set_label(5, "NEW CLIMBER" if Wardrobe.profiles.size() < 100 else "CLIMBER LIMIT REACHED")
	menu.refresh()
	if status != null:
		status.free()
	var message := "" if Wardrobe.save_error.is_empty() else Wardrobe.save_error.to_upper()
	status = LuchaKit.poster_text(message, 0.15, LuchaKit.CREAM, LuchaKit.INK)
	status.position = Vector3(0, -3.25, 0)
	menu.add_child(status)
	AtlasPalette.theme_tree(menu)
	_rebuild_preview(direction)

func _rebuild_preview(direction: int) -> void:
	if turn != null:
		turn.kill()
	if preview != null:
		preview.free()
	var p: Dictionary = Wardrobe.profiles[Wardrobe.selected]
	preview = Wardrobe.model(p).instantiate()
	preview.name = "EditedClimber"
	preview.rotation.y = PI
	preview.scale = Vector3.ONE * Feel.get_k("body_scale")
	preview.position.y = 0.5
	# The same relaxed hands-on-hips display pose as the podium finishers.
	for side in [1, -1]:
		var pivot := Vector3(side * 0.225, 1.582, 0)
		var rotation := Basis(Vector3.BACK, side * deg_to_rad(-42.0))
		var shoulder := Transform3D(rotation, pivot - rotation * pivot)
		var elbow := Vector3(side * 0.625, pivot.y, 0)
		var fold := Basis(Vector3.BACK, side * deg_to_rad(-138.0))
		var forearm := Transform3D(fold, shoulder * elbow - fold * elbow)
		for limb_name in ["Shoulder", "Wrist", "Hand"]:
			var limb := preview.find_child(("" if side == 1 else "L_") + limb_name, true, false) as Node3D
			if limb != null:
				limb.transform = (shoulder if limb_name == "Shoulder" else forearm) * limb.transform
	stage.add_child(preview)
	CelPass.celify(preview)
	Wardrobe.apply(preview, p)
	if direction != 0:
		preview.rotation.y += direction * 0.35
		turn = create_tween()
		turn.tween_property(preview, "rotation:y", PI, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _exit_tree() -> void:
	if is_instance_valid(stage):
		stage.queue_free()
	if is_instance_valid(menu):
		menu.queue_free()
