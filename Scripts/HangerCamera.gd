class_name HangerCamera extends Camera2D

@export var tilt_strength := 30


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	rotation = lerp_angle(rotation,-Ship.instance.speed.x * .001, 0.5 * delta)
	$Noise.flip_h = randi() % 2
	$Noise.flip_v = randi() % 2
