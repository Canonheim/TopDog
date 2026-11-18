extends Node3D
## The championship belt tallies one earned category at a time on the finish screen.
## Saving happens before this opens; leaving early only completes the presentation.
const Progression=preload("res://core/player_progression.gd")
var belt: Node3D
var row_name: Label3D
var row_amount: Label3D
var total_label: Label3D
var _tally: Tween
var _final_total:=0
var _earned:=0
var _fed:=0
var _key:=""
var _saved:=true
var _eligible:=true
var tally_complete:=false
var _feed_stars: Array[Node3D]=[]
signal category_started(title: String)
signal tally_finished

func _ready() -> void:
	name="MatchXP"
	belt=preload("res://ui3d/xp_championship.gd").new()
	add_child(belt)
	var rim:=LuchaKit._plate(4.55,.72,LuchaKit.GOLD)
	rim.position=Vector3(0,1.58,.1)
	add_child(rim)
	var face:=LuchaKit._plate(4.32,.53,LuchaKit.CREAM)
	face.position=Vector3(0,1.58,.14)
	add_child(face)
	row_name=belt.label("MATCH XP",.21,LuchaKit.RED,Vector3(0,1.72,.2))
	row_amount=belt.label("",.22,LuchaKit.INK,Vector3(0,1.44,.2))
	total_label=belt.label("",.17,LuchaKit.CREAM,Vector3(0,-1.1,.2))
	total_label.outline_size=8
	total_label.outline_modulate=LuchaKit.INK
	for i in 4:
		var spark:=LuchaKit.star_mesh(.055,LuchaKit.TURQUOISE if i%2==0 else LuchaKit.GOLD)
		spark.visible=false
		add_child(spark)
		_feed_stars.append(spark)

func show_payout(payout: Dictionary) -> void:
	visible=not payout.is_empty()
	if not visible: return
	var key:=str(payout.get("match_id",hash(payout)))
	if key==_key: return
	_key=key
	if _tally!=null: _tally.kill()
	_clear_fireworks()
	_saved=bool(payout.get("saved",true))
	_eligible=bool(payout.get("eligible",false))
	_earned=int(payout.get("total",0))
	var awarded:=int(payout.get("awarded",_earned)) if _saved else 0
	var before:=clampi(int(payout.get("before_total",0)),0,Progression.MAX_TOTAL)
	_final_total=clampi(int(payout.get("after_total",before+awarded)),0,Progression.MAX_TOTAL)
	_fed=0
	tally_complete=false
	belt.settle_total(before)
	row_name.text="MATCH XP"
	row_amount.text="+%s XP" % Progression.number(_earned)
	total_label.text="0 / %s XP TALLIED" % Progression.number(_earned)
	if not _saved or not _eligible or _earned<=0:
		_finish()
		return
	_tally=create_tween()
	_tally.tween_interval(.55)
	var running:=before
	for title in payout.get("rows",{}):
		var amount:=int(payout.rows[title])
		if amount<=0: continue
		var target:=mini(_final_total,running+amount)
		_tally.tween_callback(_begin_category.bind(str(title),amount,target>running))
		_tally.tween_interval(.35)
		_tally.tween_method(_feed.bind(running,target,amount),0.0,1.0,.85)
		_tally.tween_callback(_end_category.bind(amount))
		_tally.tween_interval(.22)
		running=target
	_tally.tween_callback(_finish)

func _begin_category(title: String, amount: int, filling: bool) -> void:
	row_name.text=title
	row_amount.text="+%s XP" % Progression.number(amount)
	belt.stars(filling)
	for spark in _feed_stars: spark.visible=filling
	category_started.emit(title)

func _feed(fraction: float, before: int, after: int, amount: int) -> void:
	var total:=roundi(lerpf(float(before),float(after),fraction))
	var prior:=int(Progression.snapshot(int(belt._shown_total)).level)
	var state:=Progression.snapshot(total)
	for level in range(prior+1,int(state.level)+1): belt.celebrate(level)
	belt._shown_total=total
	belt._target_total=total
	belt.set_progress(state)
	for i in _feed_stars.size():
		var t:=fposmod(fraction*2.0-float(i)/4.0,1.0)
		var from:=Vector3(1.8,1.25,.35)
		var via:=Vector3(2.8,.55,.35)
		var to:=Vector3(belt.fill.position.x,belt.fill.position.y,.35)
		_feed_stars[i].position=from.lerp(via,t).lerp(via.lerp(to,t),t)
		_feed_stars[i].rotation.z=t*TAU
	var transferred:=roundi(amount*fraction)
	row_amount.text="+%s XP" % Progression.number(amount-transferred)
	total_label.text="%s / %s XP TALLIED" % [Progression.number(_fed+transferred),Progression.number(_earned)]

func _end_category(amount: int) -> void:
	_fed+=amount
	belt.stars(false)
	for spark in _feed_stars: spark.visible=false

func _finish() -> void:
	for spark in _feed_stars: spark.visible=false
	belt.settle_total(_final_total)
	row_name.text="MATCH XP EARNED" if _saved else "XP SAVE FAILED"
	row_amount.text="+%s XP" % Progression.number(_earned) if _eligible else "NO QUALIFYING MATCH XP"
	total_label.text="LEVEL 100 - MAX XP" if _final_total>=Progression.MAX_TOTAL else "TALLY COMPLETE"
	if not _saved:
		row_amount.text="CHECK STORAGE"
		total_label.text="XP NOT SAVED"
	elif not _eligible: total_label.text=""
	tally_complete=true
	tally_finished.emit()

func _clear_fireworks() -> void:
	if belt==null: return
	for child in belt.get_children():
		if child.has_meta("xp_sparks"): child.queue_free()

func _notification(what: int) -> void:
	if what==NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree() and belt!=null:
		if _tally!=null: _tally.kill()
		if not _key.is_empty() and not tally_complete: _finish()
		_clear_fireworks()
