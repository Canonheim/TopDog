extends Node
func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(960, 640))
	var backdrop := ColorRect.new()
	backdrop.color = Color("242938")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var notice = load("res://ui/pinata_reward_notice.gd")
	for tier in 5:
		var card: Control = notice.make_card(["Common Reward", "Uncommon Reward", "Rare Reward", "Epic Reward", "Legendary Reward"][tier], tier)
		add_child(card)
		card.position = Vector2(36, 36 + tier * 115)
		card.size = Vector2(584, 92)
	await get_tree().create_timer(0.5).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(OS.get_environment("TEMP").path_join("topdog-reward-notice.png"))
	get_tree().quit()
