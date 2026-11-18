extends Node
const D=preload("res://game/landing_tracker.gd")
const X=preload("res://game/match_xp.gd")
var fails:=0
func check(value: bool, message: String) -> void:
	if not value:
		fails+=1
		push_error(message)
func jump(turns: float=1.0):
	var d=D.new()
	d.step(0,3,false,false,true,.01)
	for i in range(1,121): d.step(wrapf(TAU*turns*i/120.0,-PI,PI),0,false,true,false,.01)
	return d
func land(d, angle:=0.0, feet:=3, bad:=false) -> int:
	var awards:=0
	for i in 60:
		if d.step(angle,feet,bad,false,true,.01): awards+=1
	return awards
func _ready() -> void:
	check(land(jump())==1,"one forward revolution, stable feet")
	check(land(jump(-1))==1,"backflip")
	check(land(jump(2))==1,"double flip is one landing")
	check(land(jump(.5),PI)==0,"half revolution rejected")
	check(land(jump(),0,1)==0,"one-foot-only rejected")
	check(land(jump(),0,3,true)==0,"non-foot contact rejected")
	var d=jump()
	d.step(0,1,false,false,true,.01)
	check(land(d)==1,"one foot first then both")
	d=jump()
	for i in 10: d.step(0,3,false,false,true,.01)
	d.step(0,3,true,false,true,.01)
	check(land(d)==0,"faceplant before stable landing")
	d=jump()
	d.step(0,0,true,false,true,.01)
	check(land(d)==0,"hand catch invalidates")
	d=D.new()
	for i in range(1,121): d.step(wrapf(TAU*i/120.0,-PI,PI),0,false,true,false,.01)
	check(land(d)==0,"spawn in air rejected")
	d=D.new();d.step(0,3,false,false,true,.01)
	for cycle in 4:
		for i in range(1,61): d.step(PI*.75*sin(PI*i/60.0),0,false,true,false,.01)
	check(land(d)==0,"rocking does not add absolute rotation")
	var x=X.new()
	x.begin([{"pid":0},{"pid":1}],true);x.elapsed=30
	var events: Array=[]
	x.achievement.connect(func(_pid,title,amount): events.append([title,amount]))
	for i in 9:x.stuck_landing(0)
	check(x.stats[0].landings==9 and events.size()==9 and events[0][1]==2000 and events[1][1]==1000 and events[2][1]==500,"diminishing trick XP and one notice per award")
	check(x.payouts(1)[0].rows["STUCK THE LANDING"]==3990,"landing breakdown")
	x.begin([{"pid":0},{"pid":1}],true);events.clear()
	x.stats[0].active=59.95;x.stats[0].air=.95
	x.sample(0,1,Vector2.ZERO,.1,true);x.sample(0,1,Vector2(0,.1),.1,true)
	check(events.size()==1 and events.has(["Upward airtime",25]),"threshold notices")
	x.begin([{"pid":0},{"pid":1}],true);events.clear();x.elapsed=30
	for round_number in 20:
		x.lock_in(0,round_number);x.lock_in(0,round_number);x.lock_in(1,round_number)
	check(x.stats[0].locks==20 and x.stats[1].locks==20,"lock-ins uncapped and deduplicated")
	check(x.stats[0].first_locks==20 and x.stats[1].first_locks==0,"first lock-in bonus once each round")
	check(x.payouts(0)[0].rows["FIRST LOCK-IN"]==4000 and x.payouts(0)[1].rows["FIRST LOCK-IN"]==0,"first lock-in 200 XP per round")
	x.stats[0].air=59.95
	x.sample(0,1,Vector2.ZERO,.1,true);x.sample(0,1,Vector2(0,.1),.1,true)
	check(x.stats[0].air>60.0 and x.payouts(0)[0].rows["UPWARD AIRTIME"]==1500,"airtime uncapped at 25 XP per second")
	check(not x.payouts(0)[0].rows.has("ACTIVE PLAY"),"active minute reward removed")
	# Simultaneous loot and XP share chronological order; repeats coalesce.
	var notice=load("res://ui/pinata_reward_notice.gd").new()
	add_child(notice)
	notice.enqueue("Pug",0)
	notice.enqueue_xp("Stuck the landing",2000)
	notice.enqueue("Roses",2)
	notice._process(.1)
	check(notice.active[0].name=="Roses" and notice.active[1].name=="Stuck the landing" and notice.active[2].name=="Pug","mixed newest-first order")
	check(notice.active[0].card.position.y<notice.active[1].card.position.y,"newest visually highest")
	notice.enqueue_xp("Stuck the landing",1000)
	check(notice.active.size()==3 and notice.active[0].amount==1000,"repeat tricks show their diminished award separately")
	notice.enqueue_xp("Upward airtime",25)
	notice.enqueue_xp("Upward airtime",25)
	check(notice.active.size()==3 and notice.active[0].amount==50,"airtime coalesces at the top")
	check(notice.outgoing.has("card"),"displaced old notice begins fading")
	notice._process(.10)
	check(notice.outgoing.card.modulate.a<float(notice.outgoing.alpha),"fourth notice fades")
	notice._process(.20)
	check(notice.outgoing.is_empty(),"displaced notice removed after fade")
	for i in 10:notice.enqueue_xp("Bonus "+str(i),100)
	notice._process(.01)
	check(notice.active.size()==3 and notice.active[0].name=="Bonus 9","burst retains newest three")
	notice._process(6.0)
	check(not notice.showing,"expired notices never return")
	var ko=X.new();ko.begin([{"pid":0},{"pid":1},{"pid":2}],true)
	ko.knockout(0,1);ko.knockout(0,2)
	check(ko.stats[0].knockouts==1,"KO limited across different opponents")
	ko.begin([{"pid":0},{"pid":1}],true);ko.knockout(0,1)
	check(ko.stats[0].knockouts==1,"KO reward resets for the next match")
	notice.queue_free()
	print("LANDING / NOTICE UNIT fails=",fails)
	await get_tree().process_frame
	get_tree().quit(fails)
