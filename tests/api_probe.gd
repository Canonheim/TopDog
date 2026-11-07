extends SceneTree
func _init():
	for c in ["PinJoint2D", "RigidBody2D"]:
		var props = ClassDB.class_get_property_list(c, true).map(func(p): return p.name)
		print(c, " props: ", props)
	var ms = ClassDB.class_get_method_list("PhysicsServer2D", true).map(func(m): return m.name).filter(func(n): return n.begins_with("pin_") or n.begins_with("joint") or n.contains("torque"))
	print("PS2D: ", ms)
	print("consts: ", Array(ClassDB.class_get_integer_constant_list("PhysicsServer2D", true)).filter(func(n): return n.begins_with("PIN_")))
	print("Steam: ", ClassDB.class_exists("Steam"), " peer: ", ClassDB.class_exists("SteamMultiplayerPeer"))
	quit()
