class_name HangerCamera extends Camera2D

@export var tilt_strength := 30

func _ready() -> void:
	GLOBALS.on_health_changed().connect(jolt)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	offset = lerp(offset,Vector2(-Ship.instance.speed.x * 0.25,Ship.instance.acceleration.y * 5),delta) 
	rotation = lerp_angle(rotation,-Ship.instance.acceleration.x * 0.025, 0.5 * delta)
	$Noise.flip_h = randi() % 2
	$Noise.flip_v = randi() % 2


var _tween:Tween = null
func jolt() -> void:
	#if _tween: _tween.kill()
	#_tween = create_tween().set_trans(Tween.TRANS_SPRING)
	#_tween.tween_property($Noise, "modulate", Color(1.0, 1.0, 1.0, 0.42), 0.5)
	$Noise.modulate = Color(1.0, 1.0, 1.0, 0.42)
	await get_tree().create_timer(0.5,true,false,true).timeout
	#$Noise.modulate = Color(1.0, 1.0, 1.0, 0.125)
	$Noise.modulate = Color.WHITE.lerp(Color.TRANSPARENT,remap(GLOBALS.proportional_health,0,1,0.69,1))
	
