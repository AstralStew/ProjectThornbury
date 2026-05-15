class_name HangerCamera extends Camera2D

#@export var tilt_strength := 30

func _ready() -> void:
	GLOBALS.on_health_changed().connect(jolt)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	offset = lerp(offset,Vector2(-Ship.instance.speed.x * GLOBALS.INVENTORY_CAMERA_PAN_STRENGTH.x,Ship.instance.acceleration.y * GLOBALS.INVENTORY_CAMERA_PAN_STRENGTH.y),GLOBALS.INVENTORY_CAMERA_PAN_SPEED * delta) 
	rotation = lerp_angle(rotation,-Ship.instance.acceleration.x * 0.01 * GLOBALS.INVENTORY_CAMERA_TILT_STRENGTH, GLOBALS.INVENTORY_CAMERA_TILT_SPEED * delta)
	$Noise.flip_h = randi() % 2
	$Noise.flip_v = randi() % 2


var _tween:Tween = null
func jolt() -> void:
	$Noise.modulate = Color(1.0, 1.0, 1.0, 0.42)
	await get_tree().create_timer(0.5,true,false,true).timeout
	$Noise.modulate = Color.WHITE.lerp(Color.TRANSPARENT,remap(GLOBALS.proportional_health,0,1,0.69,1))
	
