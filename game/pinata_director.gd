extends Node
## Host-authoritative collection; each participating player receives an independent pull.
signal reward_unlocked(reward: Dictionary)
const Rewards = preload("res://core/pinata_rewards.gd")
var reward_store: RefCounted
var reward_rules := {}
var reward_jobs: Array = []
var reward_thread: Thread
const Pickup = preload("res://game/cosmetic_pinata.gd")
const SPAWN_CHANCE := 0.10
const WEIGHTS := [[0,100,0,0,0],[0,100,0,0,0],[0,80,20,0,0],[0,65,25,10,0],[0,55,25,15,5]]
var game: Node
var rng := RandomNumberGenerator.new()
var round_index := 0
var tier_spacing := 7.0
var generation := 0
var received_generation := 0
var collected_generation := -1
var current: Area3D
var practice_dev_enabled := false
var practice_spawn_queued := false
var practice_reward_owned := {}
var phase_ticket:=0
var snapshot_max_slice_us:=0
var placement_max_slice_us:=0

func _ready() -> void:
 game = get_parent()
 rng.randomize()
 reward_rules = Rewards.table()
 game.phase_changed.connect(_phase)

func reset() -> void:
 practice_dev_enabled = false
 practice_spawn_queued = false
 practice_reward_owned.clear()
 _clear()
 round_index = 0
 tier_spacing = 7.0
 # The numbering starts again with every match (the code review, 11-23: it never reset, so a
 # machine that had seen more pinatas under another host dropped the new host's first ones).
 generation = 0
 received_generation = 0
 collected_generation = -1

func _clear() -> void:
 if is_instance_valid(current) and not current.taken:
  current.set_deferred("monitoring",false)
  current.queue_free()
 current = null

func _phase(value: String) -> void:
 phase_ticket+=1
 _clear()
 if value not in ["turn","round"]: return
 var forced_practice: bool = game.practice and practice_spawn_queued and game.is_host()
 if game.practice: practice_spawn_queued = false
 if game.peak_on or (not forced_practice and (game.practice or game.roster.size()<2)): return
 if round_index == 0:
  # Match format, not survivors: disconnects cannot reduce rarity thresholds.
  var builders := 2 if game.mode.live == "turns" or game.mode.get("round_robin",false) else maxi(2,game.roster.size())
  builders = maxi(2,int(game.mode.get("climbers_per_round",builders)))
  tier_spacing = spacing_for_players(builders)
 round_index += 1
 if not game.is_host(): return
 if not forced_practice and rng.randf() >= SPAWN_CHANCE: return
 _spawn_after_snapshot(forced_practice,phase_ticket)

func _spawn_after_snapshot(forced_practice: bool,ticket: int) -> void:
 var snapshot: Dictionary=await tower_snapshot_async()
 if ticket!=phase_ticket or game.phase not in ["turn","round"]:return
 var point: Vector3=await choose_position_async(snapshot)
 if ticket!=phase_ticket or game.phase not in ["turn","round"]:return
 if not point.is_finite(): return
 generation += 1
 _spawn.rpc(generation, point, rarity_for_roll(snapshot.distance,rng.randf()*100.0,tier_spacing),forced_practice)

static func spacing_for_players(builders: int) -> float:
 return 7.0 * maxi(2,builders) / 2.0

static func tier_for_distance(distance: float,spacing := 7.0) -> int:
 return clampi(int(floor(maxf(0.0,distance)/maxf(spacing,.001))),0,4)

static func rarity_for_roll(distance: float, roll: float,spacing := 7.0) -> int:
 var tier := tier_for_distance(distance,spacing)
 var bounded_roll := clampf(roll,0.0,99.999999)
 var total := 0.0
 for i in 5:
  total += WEIGHTS[tier][i]
  if bounded_roll < total: return i
 return 4

func base_anchor() -> Vector2:
 # Fixed ground-level footprint centers; never read the selected base transform.
 return Vector2(Stage.PIER_END - .445 * float(game.stage.row.barrel_scale),Stage.DECK_Y) if game.stage.delmar else Vector2.ZERO

func tower_snapshot() -> Dictionary:
 var anchor := base_anchor()
 var farthest := anchor
 var distance := 0.0
 var points: Array[Vector2] = []
 var left := anchor.x
 var right := anchor.x
 var top := anchor.y
 for cid in game.tower:
  if not game.climbers.has(cid): continue
  var climber: Climber = game.climbers[cid]
  if climber.state != Climber.State.FROZEN: continue
  for body in climber.bodies.values():
   if not is_instance_valid(body):continue
   for collision: CollisionShape3D in body.find_children("*","CollisionShape3D",true,false):
    if collision.shape == null: continue
    # CPU collision-shape samples: no debug mesh construction/GPU readback during play.
    for vertex: Vector3 in collision_samples(collision.shape):
     var world_point: Vector3=collision.global_transform*vertex
     var point:=Vector2(world_point.x,world_point.y)
     points.append(point)
     left=minf(left,point.x);right=maxf(right,point.x);top=maxf(top,point.y)
     var reach:=anchor.distance_to(point)
     if reach>distance:distance=reach;farthest=point
 # Before any body has locked, use an upright frame at the anchor and Tier 1.
 var direction := (farthest-anchor).normalized() if distance>.001 else Vector2(0,1)
 var normal := Vector2(-direction.y,direction.x)
 if normal.y<0: normal=-normal
 return {"anchor":anchor,"farthest":farthest,"distance":distance,"direction":direction,"normal":normal,"points":points,"left":left,"right":right,"top":top}

func choose_position(snapshot: Dictionary = {}) -> Vector3:
 if snapshot.is_empty(): snapshot=tower_snapshot()
 var height := 1.995 * Feel.get_k("body_scale")
 var radius: float = Pickup.PICKUP_RADIUS
 var sphere := SphereShape3D.new()
 sphere.radius = radius+.15
 var query := PhysicsShapeQueryParameters3D.new()
 query.shape = sphere
 query.collision_mask = Climber.LAYER_WORLD | Climber.LAYER_LIVE | Climber.LAYER_FROZEN | Climber.LAYER_PROP
 for attempt in 64:
  var candidate: Vector2
  if game.stage.delmar:
   # Invisible anchor-to-tip frame, never the arena's progress-line angle.
   var along := maxf(5.0+radius+.01,float(snapshot.distance)+rng.randf_range(-.5,2.5)*height)
   var across := rng.randf_range(-3.5+radius,5.0-radius)
   candidate = snapshot.anchor+snapshot.direction*along+snapshot.normal*across
   # Entire sphere must be off the dock and five units above its deck.
   if candidate.x-radius <= Stage.PIER_END or candidate.y-radius < Stage.DECK_Y+5.0: continue
  else:
   var side := 1.0 if rng.randf()<.5 else -1.0
   var gap := rng.randf_range(2.5,3.5) if rng.randf()<.2 else rng.randf_range(1.5,2.5)
   candidate.x = (float(snapshot.right) if side>0 else float(snapshot.left))+side*height*gap
   candidate.y = maxf(5.0+radius+.01,float(snapshot.top)+height*rng.randf_range(-.4,1.5))
  var too_close := false
  for point: Vector2 in snapshot.points:
   if point.distance_squared_to(candidate)<pow(1.25*height+radius,2):
    too_close=true
    break
  if too_close: continue
  var position := Vector3(candidate.x,candidate.y,0)
  query.transform.origin=position
  if game.world.get_world_3d().direct_space_state.intersect_shape(query,1).is_empty(): return position
 return Vector3(INF,INF,INF)

@rpc("authority","call_local","reliable")
func _spawn(id: int, point: Vector3, rarity: int, practice_test := false) -> void:
 if id<=received_generation or game.phase not in ["turn","round"] or (game.practice and not practice_test) or game.peak_on: return
 _clear()
 received_generation = id
 current = Pickup.new()
 current.rarity = clampi(rarity,0,4)
 current.contact_enabled = game.is_host()
 current.position = point
 game.world.add_child(current)
 current.collected.connect(_on_collected.bind(id))

func _on_collected(body: Node3D,id: int) -> void:
 if game.is_host() and id == received_generation and game.phase in ["turn","round"]:
  var event_id := Crypto.new().generate_random_bytes(16).hex_encode()
  var collector := Climber.climber_of(body) if is_instance_valid(body) else null
  var cid := -1
  var bounce := Vector3.ZERO
  if collector != null and collector.state != Climber.State.FROZEN and not collector.removed:
   cid = collector.climber_id
   bounce = body.global_position-current.global_position
   bounce.z = 0
   bounce = bounce.normalized()
  _collect.rpc(id,event_id,rng.randi(),cid,bounce)

@rpc("authority","call_local","reliable")
func _collect(id: int, event_id := "", reward_seed := 0, collector_id := -1, bounce := Vector3.ZERO) -> void:
 if id != received_generation or id == collected_generation or not is_instance_valid(current): return
 if game.phase not in ["turn","round"]: return
 collected_generation = id
 current.collect()
 _apply_pickup_bounce(collector_id,bounce)
 if event_id.is_empty(): return
 var recipients := []
 for player in game.roster:
  if int(player.get("peer",1)) == game.me(): recipients.append(player)
 if recipients.is_empty(): return
 if game.practice:
  var rules := reward_rules.duplicate(true)
  rules.items = rules.items.filter(func(item): return bool(item.get("test",false)))
  for player in recipients:
   var slot := str(int(player.get("slot",0)))
   var owned: Array = practice_reward_owned.get(slot,[])
   var reward := Rewards.roll(current.rarity,owned,int(hash(str(reward_seed)+":"+str(player.pid))),rules)
   if reward.is_empty(): continue
   owned.append(str(reward.id))
   practice_reward_owned[slot] = owned
   reward["player"] = str(player.get("name","")) if recipients.size()>1 else ""
   reward_unlocked.emit(reward)
  return
 if reward_store == null: reward_store = Rewards.new()
 reward_jobs.append([event_id,current.rarity,reward_seed,recipients.duplicate(true),reward_rules.duplicate(true)])





## One-shot request: key repeats cannot stack spawns, and reset clears the session.
func handle_practice_dev_key(event: InputEvent) -> String:
 if not game.practice or game.peak_on or not game.is_host(): return ""
 if not event is InputEventKey or not event.pressed or event.echo: return ""
 var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
 if key == KEY_F4:
  practice_dev_enabled = not practice_dev_enabled
  return "Piñata test ON: Numpad Enter queues next round" if practice_dev_enabled else "Piñata test OFF"
 if key == KEY_KP_ENTER and practice_dev_enabled:
  practice_spawn_queued = true
  return "Piñata queued for next round"
 return ""

## Reverse the airborne collector's whole-body trajectory at half speed.
func pickup_bounce(velocity: Vector3, _normal := Vector3.ZERO) -> Vector3:
 # Delta v: current v + (-1.5 v) = -0.5 v.
 return Vector3(velocity.x,velocity.y,0) * -1.5

func pickup_airborne(collector: Climber) -> bool:
 if collector.stuck_count() > 0: return false
 # Check the whole ragdoll, including torso landings and active limbs.
 for piece: RigidBody3D in collector.bodies.values():
  for contact in piece.get_colliding_bodies():
   if Climber.climber_of(contact) == collector: continue
   if contact is CollisionObject3D and contact.collision_layer & (Climber.SOLID_MASK | Climber.LAYER_PROP): return false
 return true

func _apply_pickup_bounce(cid: int, normal: Vector3) -> void:
 var collector: Climber = game.climbers.get(cid)
 if collector == null or collector.removed or collector.state != Climber.State.LIVE or collector.owner_peer != game.me(): return
 if not pickup_airborne(collector): return
 # Use the owner's actual ragdoll velocity, not a delayed remote pose estimate.
 var velocity := Vector3.ZERO
 var mass_sum := 0.0
 for piece: RigidBody3D in collector.bodies.values():
  velocity += piece.linear_velocity * piece.mass
  mass_sum += piece.mass
 if mass_sum <= 0.0: return
 var boost := pickup_bounce(velocity/mass_sum,normal)
 # Equal velocity change preserves relative limb movement and spin.
 for piece: RigidBody3D in collector.bodies.values():
  piece.apply_central_impulse(boost * piece.mass)


# Serialized background saves preserve receipt ordering and duplicate protection.
# Only main-thread polling emits UI signals, and only after the atomic save succeeds.
func _process(_dt: float) -> void:
 if reward_thread != null:
  if reward_thread.is_alive(): return
  var grants: Array = reward_thread.wait_to_finish()
  reward_thread = null
  for reward in grants: reward_unlocked.emit(reward)
  if not reward_store.error.is_empty(): push_error(reward_store.error)
 if reward_jobs.is_empty(): return
 var job: Array = reward_jobs.pop_front()
 reward_thread = Thread.new()
 var err := reward_thread.start(reward_store.collect.bind(job[0],job[1],job[2],job[3],job[4]))
 if err != OK:
  reward_thread = null
  reward_jobs.push_front(job)
  push_error("Could not start piñata reward save worker; reward remains queued.")

func _exit_tree() -> void:
 # Leaving the match must not discard an earned reward or abandon a live thread.
 if reward_thread != null:
  reward_thread.wait_to_finish()
  reward_thread = null
 for job in reward_jobs:
  reward_store.collect(job[0],job[1],job[2],job[3],job[4])
 reward_jobs.clear()

static var shape_samples: Dictionary={}
static func collision_samples(shape: Shape3D) -> PackedVector3Array:
 if shape is ConvexPolygonShape3D:return shape.points
 var key: String=shape.get_class()
 if shape is BoxShape3D:key+=str(shape.size)
 elif shape is SphereShape3D:key+=str(shape.radius)
 elif shape is CapsuleShape3D:key+=str(shape.radius)+":"+str(shape.height)
 if shape_samples.has(key):return shape_samples[key]
 var points:=PackedVector3Array()
 if shape is BoxShape3D:
  for x in [-.5,.5]:
   for y in [-.5,.5]:
    for z in [-.5,.5]:points.append(shape.size*Vector3(x,y,z))
 elif shape is SphereShape3D or shape is CapsuleShape3D:
  var radius: float=shape.radius
  var half:=maxf(0.,shape.height*.5-radius) if shape is CapsuleShape3D else 0.
  for side in 16:
   var angle:=TAU*side/16.
   var y:=cos(angle)*radius
   points.append(Vector3(sin(angle)*radius,y+(half if y>=0 else -half),0))
 elif shape is ConvexPolygonShape3D:points=shape.points
 shape_samples[key]=points
 return points


func tower_snapshot_async() -> Dictionary:
 var slice_start:=Time.get_ticks_usec()
 var anchor := base_anchor()
 var farthest := anchor
 var distance := 0.0
 var points: Array[Vector2] = []
 var left := anchor.x
 var right := anchor.x
 var top := anchor.y
 for cid in game.tower:
  if not game.climbers.has(cid): continue
  var climber: Climber = game.climbers[cid]
  if climber.state != Climber.State.FROZEN: continue
  for body in climber.bodies.values():
   if not is_instance_valid(body):continue
   for collision: CollisionShape3D in body.find_children("*","CollisionShape3D",true,false):
    if Time.get_ticks_usec()-slice_start>=1200:
     snapshot_max_slice_us=maxi(snapshot_max_slice_us,Time.get_ticks_usec()-slice_start)
     await get_tree().process_frame
     slice_start=Time.get_ticks_usec()
     if not is_instance_valid(climber) or not is_instance_valid(collision):continue
    if collision.shape == null: continue
    # CPU collision-shape samples: no debug mesh construction/GPU readback during play.
    for vertex: Vector3 in collision_samples(collision.shape):
     var world_point: Vector3=collision.global_transform*vertex
     var point:=Vector2(world_point.x,world_point.y)
     points.append(point)
     left=minf(left,point.x);right=maxf(right,point.x);top=maxf(top,point.y)
     var reach:=anchor.distance_to(point)
     if reach>distance:distance=reach;farthest=point
 snapshot_max_slice_us=maxi(snapshot_max_slice_us,Time.get_ticks_usec()-slice_start)
 # Before any body has locked, use an upright frame at the anchor and Tier 1.
 var direction := (farthest-anchor).normalized() if distance>.001 else Vector2(0,1)
 var normal := Vector2(-direction.y,direction.x)
 if normal.y<0: normal=-normal
 return {"anchor":anchor,"farthest":farthest,"distance":distance,"direction":direction,"normal":normal,"points":points,"left":left,"right":right,"top":top}

func choose_position_async(snapshot: Dictionary = {}) -> Vector3:
 var slice_start:=Time.get_ticks_usec()
 if snapshot.is_empty(): snapshot=await tower_snapshot_async()
 var height := 1.995 * Feel.get_k("body_scale")
 var radius: float = Pickup.PICKUP_RADIUS
 var sphere := SphereShape3D.new()
 sphere.radius = radius+.15
 var query := PhysicsShapeQueryParameters3D.new()
 query.shape = sphere
 query.collision_mask = Climber.LAYER_WORLD | Climber.LAYER_LIVE | Climber.LAYER_FROZEN | Climber.LAYER_PROP
 for attempt in 64:
  var candidate: Vector2
  if game.stage.delmar:
   # Invisible anchor-to-tip frame, never the arena's progress-line angle.
   var along := maxf(5.0+radius+.01,float(snapshot.distance)+rng.randf_range(-.5,2.5)*height)
   var across := rng.randf_range(-3.5+radius,5.0-radius)
   candidate = snapshot.anchor+snapshot.direction*along+snapshot.normal*across
   # Entire sphere must be off the dock and five units above its deck.
   if candidate.x-radius <= Stage.PIER_END or candidate.y-radius < Stage.DECK_Y+5.0: continue
  else:
   var side := 1.0 if rng.randf()<.5 else -1.0
   var gap := rng.randf_range(2.5,3.5) if rng.randf()<.2 else rng.randf_range(1.5,2.5)
   candidate.x = (float(snapshot.right) if side>0 else float(snapshot.left))+side*height*gap
   candidate.y = maxf(5.0+radius+.01,float(snapshot.top)+height*rng.randf_range(-.4,1.5))
  var too_close := false
  for point: Vector2 in snapshot.points:
   if Time.get_ticks_usec()-slice_start>=1200:
    placement_max_slice_us=maxi(placement_max_slice_us,Time.get_ticks_usec()-slice_start)
    await get_tree().process_frame
    slice_start=Time.get_ticks_usec()
   if point.distance_squared_to(candidate)<pow(1.25*height+radius,2):
    too_close=true
    break
  if too_close: continue
  var position := Vector3(candidate.x,candidate.y,0)
  query.transform.origin=position
  placement_max_slice_us=maxi(placement_max_slice_us,Time.get_ticks_usec()-slice_start)
  if game.world.get_world_3d().direct_space_state.intersect_shape(query,1).is_empty(): return position
 return Vector3(INF,INF,INF)
