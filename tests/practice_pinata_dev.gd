extends Node
func key(code: int, echo := false) -> InputEventKey:
 var event := InputEventKey.new()
 event.physical_keycode = code
 event.pressed = true
 event.echo = echo
 return event
func _ready() -> void:
 var rules = load("res://core/pinata_rewards.gd").table()
 var found := {}
 for seed_value in 1000:
  var reward = load("res://core/pinata_rewards.gd").roll(4,[],seed_value,rules)
  assert(reward.name == "Test")
  found[int(reward.rarity)] = true
 assert(found.size() == 4 and not found.has(0))
 for item in rules.items:
  var owned := []
  for other in rules.items:
   if other.id != item.id: owned.append(other.id)
  assert(load("res://core/pinata_rewards.gd").roll(4,owned,1,rules).rarity == item.rarity)
 var world := Node3D.new()
 add_child(world)
 var game := Game.new()
 game.world = world
 game.dress = false
 add_child(game)
 game.host_start({"mode":"practice","practice_mode":"scramble","timer":60.0,"stage":"plaza","base":"barrel"},[{"pid":0,"name":"Test","peer":1,"slot":0,"tint":Color.WHITE}])
 while game.phase == "between": await get_tree().physics_frame
 game.set_physics_process(false)
 var d = game.pinata_director
 assert(not is_instance_valid(d.current))
 assert(d.handle_practice_dev_key(key(KEY_KP_ENTER)).is_empty())
 assert(not d.handle_practice_dev_key(key(KEY_F4)).is_empty())
 assert(d.handle_practice_dev_key(key(KEY_ENTER)).is_empty())
 assert(d.handle_practice_dev_key(key(KEY_KP_ENTER,true)).is_empty())
 assert(not d.handle_practice_dev_key(key(KEY_KP_ENTER)).is_empty())
 assert(d.practice_spawn_queued and not is_instance_valid(d.current))
 game._rpc_phase("between",0,game.line,1,-1)
 assert(d.practice_spawn_queued)
 game._rpc_phase("round",60,game.line,2,-1)
 assert(not d.practice_spawn_queued)
 assert(is_instance_valid(d.current))
 assert(d.current.rarity == 1)
 assert(d.current.position.y - d.Pickup.PICKUP_RADIUS >= 4.999)
 var rewards := []
 d.reward_unlocked.connect(func(reward): rewards.append(reward))
 d._on_collected(null,d.received_generation)
 assert(d.current.taken and rewards.size() == 1 and d.reward_store == null)
 assert(rewards[0].name == "Test" and rewards[0].rarity == 1)
 d._on_collected(null,d.received_generation)
 assert(rewards.size() == 1)
 game._rpc_phase("between",0,game.line,2,-1)
 game._rpc_phase("round",60,game.line,3,-1)
 assert(not is_instance_valid(d.current))
 d.handle_practice_dev_key(key(KEY_KP_ENTER))
 d.reset()
 assert(not d.practice_spawn_queued and not d.practice_dev_enabled and d.practice_reward_owned.is_empty())
 game.practice = false
 assert(d.handle_practice_dev_key(key(KEY_F4)).is_empty())
 game.end_match()
 print("PRACTICE PINATA PASS: arming, keypad-only, no key-repeat, next-round timing, normal rarity/clearance, one-shot, reset, no permanent test rewards")
 get_tree().quit()
