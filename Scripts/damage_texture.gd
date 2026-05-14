extends TextureRect


func _ready() -> void:
	GLOBALS.on_health_changed().connect(check_damage)

func check_damage() -> void:
	print("proportional health = "+str(GLOBALS.proportional_health))
	self_modulate = Color.WHITE.lerp(Color.TRANSPARENT,GLOBALS.proportional_health)
