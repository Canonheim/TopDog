extends RefCounted
## Account-wide local progression. Version 2 scales the original curve by 20.
const SavePaths = preload("res://core/save_paths.gd")
const MAX_LEVEL := 100
const MAX_TOTAL := 5841000

static func required_xp(level: int) -> int:
	return 0 if level >= MAX_LEVEL else 10000 + 1000 * (maxi(level, 1) - 1)

static func snapshot(total_xp: int) -> Dictionary:
	var remaining := clampi(total_xp, 0, MAX_TOTAL)
	var level := 1
	while level < MAX_LEVEL and remaining >= required_xp(level):
		remaining -= required_xp(level)
		level += 1
	var needed := required_xp(level)
	return {"level":level,"xp":remaining if level < MAX_LEVEL else 0,
		"needed":needed,"fraction":float(remaining)/needed if needed > 0 else 1.0}

static func number(value: int) -> String:
	var s := str(maxi(value,0))
	var i := s.length()-3
	while i>0:
		s=s.insert(i,",")
		i-=3
	return s

static func read_save(path: String) -> Dictionary:
	var cfg := ConfigFile.new()
	var err := cfg.load(path)
	if err != OK and err != ERR_FILE_NOT_FOUND:
		return {"ok":false,"total":0,"claims":[]}
	var value: Variant = cfg.get_value("progression","total_xp",0)
	if not value is int or value<0:
		return {"ok":false,"total":0,"claims":[]}
	var total: int = mini(value,MAX_TOTAL)
	if int(cfg.get_value("progression","version",1)) < 2:
		total=mini(value,292050)*20
	var claims: Variant = cfg.get_value("progression","claims",[])
	if not claims is Array: return {"ok":false,"total":0,"claims":[]}
	return {"ok":true,"total":total,"claims":claims}

static func load_snapshot() -> Dictionary:
	return snapshot(int(read_save(SavePaths.settings("progression.cfg")).total))

static func grant(match_id: String, amount: int, path: String = "") -> Dictionary:
	if path.is_empty(): path=SavePaths.settings("progression.cfg")
	var saved := read_save(path)
	if not saved.ok: return {"ok":false,"awarded":0}
	if match_id.is_empty() or amount<=0 or match_id in saved.claims:
		return {"ok":true,"awarded":0,"total":saved.total}
	var total := mini(MAX_TOTAL,int(saved.total)+mini(amount,MAX_TOTAL))
	var claims: Array = saved.claims.duplicate()
	claims.append(match_id)
	if claims.size()>256: claims.pop_front()
	var cfg := ConfigFile.new()
	cfg.set_value("progression","version",2)
	cfg.set_value("progression","total_xp",total)
	cfg.set_value("progression","claims",claims)
	var err := cfg.save(path+".tmp")
	if err==OK:
		err=DirAccess.rename_absolute(ProjectSettings.globalize_path(path+".tmp"),ProjectSettings.globalize_path(path))
	return {"ok":err==OK,"awarded":total-int(saved.total) if err==OK else 0,"total":total if err==OK else saved.total}
