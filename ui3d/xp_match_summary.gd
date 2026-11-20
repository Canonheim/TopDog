extends Node3D
## The championship belt tallies one earned category at a time on the finish screen.
## Saving happens before this opens; leaving early only completes the presentation.
const Progression=preload("res://core/player_progression.gd")
var belt: Node3D
var row_name: Label3D
var row_amount: Label3D
var total_label: Label3D
const XP_TICK := preload("res://audio/sfx/xp_counter_tick.wav")
const XP_FINISH := preload("res://audio/sfx/xp_counter_complete.wav")
const XP_GAIN := 1.3
var _xp_departures := 0
var _xp_category_filling := false
var _xp_cluster_finished := false
var _xp_voices: Array[AudioStreamPlayer] = []
var _tally: Tween
var _final_total:=0
var _earned:=0
var _fed:=0
var _key:=""
var _saved:=true
var _eligible:=true
var tally_complete:=false
var _feed_stars: Array[Node3D]=[]
const STAR_FALL_SECONDS := .425 # Same flight duration as the original two passes per .85s reward.
var _falling_stars: Array[Dictionary] = []
signal category_started(title: String)
signal tally_finished

func _ready() -> void:
	name="MatchXP"
	belt=preload("res://ui3d/xp_results_compact.gd").new()
	add_child(belt)
	# On the kit panel the window's face is at z .118 (Dan's stood out at .24).
	var face_z := .122 if belt.kit != null else .24
	row_name=belt.label("MATCH XP",.155,LuchaKit.RED,Vector3(0,1.00,face_z))
	row_amount=belt.label("",.20,LuchaKit.INK,Vector3(0,.73,face_z))
	total_label=belt.label("",.12,LuchaKit.CREAM,Vector3(0,-1.42,.24))
	total_label.visible=false # The belt and category counter already show the tally.
	# Transparent atlas materials bypass the depth-based ink outline on these tiny drops.
	var rain_materials: Array[StandardMaterial3D] = []
	for color in [LuchaKit.TURQUOISE, LuchaKit.GOLD]:
		var material := StandardMaterial3D.new()
		material.albedo_texture = CelPass.ATLAS
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		var swatch := AtlasPalette.matte_uv(color)
		material.uv1_scale = Vector3.ZERO
		material.uv1_offset = Vector3(swatch.x, swatch.y, 0)
		rain_materials.append(material)
	for i in 24:
		var spark:=LuchaKit.star_mesh(.035,LuchaKit.TURQUOISE if i%2==0 else LuchaKit.GOLD)
		spark.material_override=rain_materials[i%2]
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
	_stop_xp_audio()
	_xp_cluster_finished = false
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
	total_label.text="0 / %s XP\nTALLIED" % Progression.number(_earned)
	_fit_text()
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
	_xp_departures = 0
	_xp_category_filling = filling
	_xp_cluster_finished = false
	row_name.text="STUCK THE\nLANDING" if title=="STUCK THE LANDING" else title
	row_amount.text="+%s XP" % Progression.number(amount)
	belt.stars(filling)
	_fit_text()
	category_started.emit(title)

func _feed(fraction: float, before: int, after: int, amount: int) -> void:
	# Each visible launch, including the recycled second pass, starts a tick.
	if after > before and is_visible_in_tree():
		while _xp_departures < 16 and fraction >= float(_xp_departures) / 16.0:
			_play_xp_cue(false)
			_launch_feed_star(_xp_departures, (fraction - float(_xp_departures)/16.0) * .85)
			_xp_departures += 1
	var total:=roundi(lerpf(float(before),float(after),fraction))
	var prior:=int(Progression.snapshot(int(belt._shown_total)).level)
	var state:=Progression.snapshot(total)
	for level in range(prior+1,int(state.level)+1): belt.celebrate(level)
	belt._shown_total=total
	belt._target_total=total
	belt.set_progress(state)
	var transferred:=roundi(amount*fraction)
	row_amount.text="+%s XP" % Progression.number(amount-transferred)
	_fit_text()
	total_label.text="%s / %s XP\nTALLIED" % [Progression.number(_fed+transferred),Progression.number(_earned)]

## Flight time is independent of the reward tween: an ended category stops launches,
## but its existing drops keep falling through the next category and final summary.
func _launch_feed_star(departure: int, age: float) -> void:
	var spark: Node3D = null
	# Separate pools preserve alternating colors without reusing an airborne star.
	for i in range(departure % 2, _feed_stars.size(), 2):
		if not _feed_stars[i].visible:
			spark = _feed_stars[i]
			break
	if spark == null: return # Bounded even when dev rewards are requested rapidly.
	var lane := fposmod(float(departure % 8) * .618 + float(departure / 8) * .37, 1.0)
	spark.position.x = belt.meter_left + belt.meter_width * (.08 + .84 * lane)
	spark.visible = true
	var drop := {"node":spark, "age":maxf(age,0.0), "spin":float(departure % 8)}
	_falling_stars.append(drop)
	_draw_feed_star(drop)

func _draw_feed_star(drop: Dictionary) -> void:
	var spark: Node3D = drop.node
	var t := clampf(float(drop.age) / STAR_FALL_SECONDS, 0.0, 1.0)
	spark.position.y = lerpf(belt.feed_top, belt.meter_y, t * t)
	spark.position.z = .35
	spark.rotation.z = t * TAU * .5 + float(drop.spin)
	spark.scale = Vector3.ONE * minf(1.0, minf(t * 10.0, (1.0-t) * 8.0))

func _process(delta: float) -> void:
	for i in range(_falling_stars.size()-1, -1, -1):
		var drop: Dictionary = _falling_stars[i]
		drop.age = float(drop.age) + delta
		_draw_feed_star(drop)
		if float(drop.age) >= STAR_FALL_SECONDS:
			(drop.node as Node3D).visible = false
			_falling_stars.remove_at(i)

func _clear_feed_stars() -> void:
	_falling_stars.clear()
	for spark in _feed_stars: spark.visible = false

func _end_category(amount: int) -> void:
	if _xp_category_filling and not _xp_cluster_finished and is_visible_in_tree():
		_play_xp_cue(true)
	_xp_cluster_finished = true
	_fed+=amount
	belt.stars(false)

func _finish() -> void:
	belt.settle_total(_final_total)
	row_name.text="MATCH XP EARNED" if _saved else "XP SAVE FAILED"
	row_amount.text="+%s XP" % Progression.number(_earned) if _eligible else "NO MATCH XP"
	total_label.text="LEVEL 100\nMAX XP" if _final_total>=Progression.MAX_TOTAL else "TALLY COMPLETE"
	if not _saved:
		row_amount.text="CHECK STORAGE"
		total_label.text="XP NOT SAVED"
	elif not _eligible: total_label.text=""
	_fit_text()
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
		_clear_feed_stars()
		_stop_xp_audio()

## Reserve padding on all four sides, including multiline achievement names.
func _fit_text() -> void:
	var kit_look: bool = belt.kit != null
	_fit_label(row_name, .15 if kit_look else .145, belt.window_width, .30 if kit_look else .27)
	_fit_label(row_amount, .21 if kit_look else .20, belt.window_width, .23 if kit_look else .21)
	# Match the visible ink margins inside the recessed cream window.
	var top_gap: float = belt.window_top - (row_name.position.y + _ink_edges(row_name).y)
	row_amount.position.y = belt.window_bottom + top_gap - _ink_edges(row_amount).x


func _fit_label(node: Label3D, max_size: float, width: float, height: float) -> void:
	var font: Font = node.font if node.font != null else ThemeDB.fallback_font
	var bounds := font.get_multiline_string_size(node.text, HORIZONTAL_ALIGNMENT_CENTER, -1, node.font_size)
	node.pixel_size = minf(max_size / node.font_size, minf(width / maxf(bounds.x, 1), height / maxf(bounds.y, 1)))
	LuchaKit.center_digits(node)


func _play_xp_cue(final: bool) -> void:
	var voice := AudioStreamPlayer.new()
	voice.bus = "Effects"
	voice.stream = XP_FINISH if final else XP_TICK
	voice.volume_db = linear_to_db(XP_GAIN)
	add_child(voice)
	_xp_voices.append(voice)
	voice.finished.connect(func():
		_xp_voices.erase(voice)
		voice.queue_free())
	voice.play()


func _stop_xp_audio() -> void:
	for voice in _xp_voices:
		if is_instance_valid(voice):
			voice.stop()
			voice.queue_free()
	_xp_voices.clear()

func _ink_edges(node: Label3D) -> Vector2:
	var font: Font = node.font if node.font != null else ThemeDB.fallback_font
	var ts := TextServerManager.get_primary_interface()
	var rid := font.get_rids()[0]
	var size := node.font_size
	var lines := node.text.split("\n")
	var low := INF
	var high := -INF
	for line in lines.size():
		var baseline := (font.get_descent(size)-font.get_ascent(size))*.5 + (float(lines.size()-1)*.5-line)*(font.get_height(size)+node.line_spacing)
		for ch in lines[line].length():
			var glyph := ts.font_get_glyph_index(rid,size,lines[line].unicode_at(ch),0)
			var offset := ts.font_get_glyph_offset(rid,Vector2i(size,0),glyph)
			var extent := ts.font_get_glyph_size(rid,Vector2i(size,0),glyph)
			if extent.y <= 0: continue
			var top := baseline - offset.y + node.offset.y
			high = maxf(high, top)
			low = minf(low, top-extent.y)
	return Vector2.ZERO if low == INF else Vector2(low,high)*node.pixel_size
