extends Node
const P = preload("res://core/player_progression.gd")
const X = preload("res://game/match_xp.gd")
var fails := 0
func check(ok: bool, message: String) -> void:
	if not ok:
		fails+=1
		push_error(message)
func _ready() -> void:
	var sum := 0
	for level in range(1,100):
		check(P.snapshot(sum).level==level,"level boundary")
		check(P.snapshot(sum+P.required_xp(level)-1).level==level,"below boundary")
		sum+=P.required_xp(level)
	check(sum==P.MAX_TOTAL and P.snapshot(sum).level==100,"cap")
	check(P.snapshot(-1).xp==0 and P.snapshot(sum+1000).fraction==1.0,"clamps")
	var x=X.new()
	x.begin([{"pid":0},{"pid":1}],true)
	x.elapsed=25
	for i in 51: x.sample(0,1,Vector2(0,i*.1),.1,true)
	check(float(x.stats[0].air)>4.9,"upward airtime")
	var air: float=x.stats[0].air
	x.sample(0,1,Vector2(0,4.9),.1,true)
	x.sample(0,1,Vector2(0,5),.1,false)
	x.sample(0,2,Vector2(0,50),.1,true)
	x.sample(0,2,Vector2(0,500),.1,true)
	check(is_equal_approx(float(x.stats[0].air),air),"falling, grounded, respawn and teleport excluded")
	x.lock_in(0,1); x.lock_in(0,1)
	check(x.stats[0].locks==1,"lock dedup")
	for i in 10: x.knockout(0,1)
	x.knockout(0,0)
	check(x.stats[0].knockouts==1,"self/repeated victim cap")
	var reward: Dictionary=x.payouts(0)[0]
	check(reward.total==2500+4000+1500+200+200+int(floor(air))*25,"payout arithmetic")
	check(x.payouts(0)[1].total==0,"idle player")
	x.elapsed=19
	check(x.payouts(0)[0].total==0,"short match")
	x.begin([{"pid":0},{"pid":1}],false)
	check(x.payouts(0)[0].total==0,"practice disabled")
	var path := OS.get_environment("TEMP").path_join("topdog-xp-test-"+str(OS.get_process_id())+".cfg")
	var cfg:=ConfigFile.new()
	cfg.set_value("progression","total_xp",700)
	check(cfg.save(path)==OK,"legacy fixture")
	check(P.read_save(path).total==14000,"legacy migration retains level and fraction")
	var receipt:=P.grant("match-one",10000,path)
	check(receipt.ok and receipt.total==24000 and receipt.awarded==10000,"atomic grant")
	check(P.grant("match-one",10000,path).awarded==0,"duplicate grant")
	check(P.grant("match-two",2000,path).total==26000,"second match persists")
	cfg.clear(); cfg.set_value("progression","version",2); cfg.set_value("progression","total_xp",P.MAX_TOTAL-50); cfg.save(path)
	check(P.grant("cap",1000,path).awarded==50,"cap grant")
	cfg.clear(); cfg.set_value("progression","total_xp","bad"); cfg.save(path)
	check(not P.grant("bad",1000,path).ok,"corrupt save preserved")
	DirAccess.remove_absolute(path)
	print("MATCH XP UNIT fails=",fails)
	get_tree().quit(fails)
