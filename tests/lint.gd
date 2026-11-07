extends Node
## --lint: load every script in the project and report the ones that don't compile.
func _ready() -> void:
	var bad := 0
	var n := 0
	for path in _scripts("res://"):
		n += 1
		var s = load(path)
		if s == null or not (s as Script).can_instantiate():
			print("LINT FAIL ", path)
			bad += 1
	print("LINT %d scripts, %d failed" % [n, bad])
	get_tree().quit(bad)

func _scripts(dir: String) -> Array:
	var out: Array = []
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".gd"):
			out.append(dir.path_join(f))
	for d in DirAccess.get_directories_at(dir):
		if d.begins_with(".") or d == "addons":
			continue
		out.append_array(_scripts(dir.path_join(d)))
	return out
