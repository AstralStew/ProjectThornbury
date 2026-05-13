class_name Boot extends Area2D
const DEBUG_NAME = "[b][Boot][/b] "
static var instance : Boot = null

@export var ship_force : Vector2 = Vector2(1,1)

@export var random_force : float = 1.0

@export var jolt_force : float = 200.0
@export var jolt_reduction : float = 1000.0

@export_category("READ ONLY")

@export var ship_direction : Vector2 = Vector2.ZERO

var _direction : Vector2 = Vector2.ZERO
@export var direction : Vector2 = Vector2.ZERO:
	get: return _direction
	set(value): _direction = value.normalized()

@export_range(0,1000,1.0,"or_greater") var force : float = 0.0

var _random_direction : Vector2 = Vector2.ZERO

var _jolt_force : float = 0


func _enter_tree() -> void:
	instance = self

func _physics_process(delta: float) -> void:
	_get_ship_speed()
	_add_random()
	if _jolt_force > 0: _jolt_force = move_toward(_jolt_force, 0, jolt_reduction * delta)
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
		gravity_direction = ship_direction + (_random_direction * random_force * _jolt_force)
	else:		
		gravity_direction = _direction + (_random_direction * random_force * _jolt_force)
	
	if _jolt_force > 0:
		gravity_direction += GLOBALS.random_vector2_normalised() * _jolt_force
	
	
	gravity = force



func jolt() -> void:
	_jolt_force = jolt_force
