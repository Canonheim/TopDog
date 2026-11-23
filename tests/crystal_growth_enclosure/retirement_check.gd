extends Node
func _ready() -> void:
 var prep=load("res://ui3d/lock_effect_preparation.gd")
 assert(not "rainbow_quartz" in Wardrobe.EFFECTS)
 assert(not "Rainbow Quartz" in Wardrobe.EFFECT_NAMES)
 assert(Wardrobe.EFFECTS.size()==Wardrobe.EFFECT_NAMES.size())
 assert(Wardrobe.clean({"effect":"rainbow_quartz"}).effect=="quartz")
 assert(prep.validation_errors().is_empty())
 for id in ["ruby","sapphire","emerald","quartz","rose_quartz","topaz","amethyst"]:
  assert(id in Wardrobe.EFFECTS)
 print("RAINBOW_REMOVAL_PASS")
 get_tree().quit()
