extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var script = load("res://ui/pinata_reward_notice.gd")
	var last := 0
	for tier in 5:
		var card: Control = script.make_card("Sample Reward", tier)
		root.add_child(card)
		assert(card.get_meta("glow_radius") > last)
		last = card.get_meta("glow_radius")
		var label: Label = card.get_node("RewardName")
		assert(label.get_theme_color("font_color") == (Color("a8a8a8") if tier == 0 else Color.WHITE))
		assert(card.get_child_count() == 5)
		card.queue_free()
	print("REWARD NOTICE: five rarity styles, progressive glow, white/grey text PASS")
	quit()
