extends RefCounted
## Host-observed match statistics, bounded independently of presentation.
signal achievement(pid: int, title: String, amount: int)
var stats := {}
var samples := {}
var locks := {}
var round_first := {}
var elapsed := 0.0
var eligible := false

func begin(roster: Array, enabled: bool) -> void:
	stats.clear(); samples.clear(); locks.clear(); round_first.clear()
	elapsed=0.0
	eligible=enabled and roster.size()>=2
	for r in roster:
		stats[int(r.pid)]={"active":0.0,"air":0.0,"knockouts":0,"locks":0,"landings":0,"landing_xp":0,"first_locks":0}

func sample(pid: int, cid: int, pos: Vector2, dt: float, airborne: bool) -> void:
	if not eligible or not stats.has(pid) or dt<=0: return
	var previous: Dictionary = samples.get(pid,{})
	samples[pid]={"cid":cid,"pos":pos}
	if previous.is_empty() or int(previous.cid)!=cid: return
	var speed: Vector2 = (pos-Vector2(previous.pos))/dt
	# Ignore respawn/teleport jumps and physics spikes.
	if speed.length()>30.0: return
	var old_air := int(float(stats[pid].air))
	if speed.length()>.15:
		stats[pid].active=minf(300.0,float(stats[pid].active)+dt)
	if airborne and speed.y>.25:
		stats[pid].air=float(stats[pid].air)+dt
	var air_gain := (int(float(stats[pid].air))-old_air)*25
	if air_gain>0: achievement.emit(pid,"Upward airtime",air_gain)

func lock_in(pid: int, round_number: int) -> void:
	var key := "%d:%d" % [pid,round_number]
	if not eligible or not stats.has(pid) or locks.has(key): return
	locks[key]=true
	stats[pid].locks+=1
	achievement.emit(pid,"Lock-in",200)
	if not round_first.has(round_number):
		round_first[round_number]=pid
		stats[pid].first_locks+=1
		achievement.emit(pid,"First lock-in",200)

func knockout(attacker: int, victim: int) -> void:
	if not eligible or attacker==victim or not stats.has(attacker) or not stats.has(victim): return
	if int(stats[attacker].knockouts)>=1: return
	stats[attacker].knockouts+=1
	achievement.emit(attacker,"Knockout",1500)

func stuck_landing(pid: int) -> void:
	if not eligible or not stats.has(pid): return
	# Halve this trick's award each time in this match, rounded down to whole XP.
	var amount := 2000 >> mini(int(stats[pid].landings),31)
	stats[pid].landings+=1
	stats[pid].landing_xp+=amount
	if amount>0: achievement.emit(pid,"Stuck the landing",amount)

func payouts(winner: int) -> Dictionary:
	var out := {}
	for pid in stats:
		var s: Dictionary = stats[pid]
		var qualified := eligible and elapsed>=20.0 and (float(s.active)>=3.0 or int(s.locks)>0 or int(s.knockouts)>0 or int(s.landings)>0)
		var rows := {"MATCH COMPLETE":2500,"VICTORY":4000 if pid==winner else 0,
			"KNOCKOUTS":1500*int(s.knockouts),"LOCK-INS":200*int(s.locks),"FIRST LOCK-IN":200*int(s.first_locks),
			"STUCK THE LANDING":int(s.landing_xp),"UPWARD AIRTIME":25*int(floor(float(s.air)))}
		var total := 0
		for key in rows:
			if not qualified: rows[key]=0
			total+=int(rows[key])
		out[pid]={"total":total,"rows":rows,"stats":s.duplicate(),"eligible":qualified}
	return out
