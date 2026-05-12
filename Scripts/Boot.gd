class_name Boot extends Area2D


@export var ship_force : Vector2 = Vector2(1,1)

@export var random_force : float = 1.0

@export_category("READ ONLY")

@export var ship_direction : Vector2 = Vector2.ZERO

var _direction : Vector2 = Vector2.ZERO
@export var direction : Vector2 = Vector2.ZERO:
	get: return _direction
	set(value): _direction = value.normalized()

@export_range(0,1000,1.0,"or_greater") var force : float = 0.0


var _random_direction : Vector2 = Vector2.ZERO


func _physics_process(delta: float) -> void:
	_get_ship_speed()
	_add_random()
	_apply_forces()

func _get_ship_speed() -> void:
	
	ship_direction = Vector2(
		(Ship.instance.acceleration.x * (ship_force.x/3)) + (Ship.instance.proportional_speed.x * ship_force.x),
		(Ship.instance.acceleration.y + abs(Ship.instance.proportional_speed.x)) * ship_force.y
	) 
	
	#ship_direction = Vector2(
		#-Ship.instance.proportional_speed.x * ship_force.x,
		#Ship.instance.proportional_speed.y * ship_force.y
	#)

func _add_random() -> void:
	_random_direction = (_random_direction + GLOBALS.random_vector2()).normalized() # Vector2(remap(randf(),0,1,-1,1),remap(randf(),0,1,-1,1))).normalized()

func _apply_forces() -> void:
	
	if ship_direction:
		gravity_direction = ship_direction + (_random_direction * random_force)
	else:		
		gravity_direction = _direction + (_random_direction * random_force)
	
	gravity = force
