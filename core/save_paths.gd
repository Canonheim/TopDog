extends Object
## Where settings/save jsons live (Parker's rule 2026-07-04): NEXT TO THE
## EXE for exported builds, so a build folder is fully self-contained and
## portable — copy the folder, keep your binds/skins. Editor runs keep
## Godot's user:// (the "exe" there would be the editor binary's folder).
## Any future save file should route through here too.


static func settings(file: String) -> String:
	if OS.has_feature("editor"):
		return "user://" + file
	return OS.get_executable_path().get_base_dir().path_join(file)


## The local mods folder (mod support 2026-08-30): same next-to-the-exe
## law as the saves — a build folder carries its own mods/. Editor runs
## keep user://mods. Workshop-subscribed items live where Steam puts
## them and are handed to the loader separately; this dir is the
## drop-a-pck-in road (the Mod Kit's output target).
static func mods_dir() -> String:
	if OS.has_feature("editor"):
		return "user://mods"
	return OS.get_executable_path().get_base_dir().path_join("mods")
