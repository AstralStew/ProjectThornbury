class_name Boot extends Area2D
const DEBUG_NAME = "[b][Boot][/b] "
static var instance : Boot = null


#@export var minimum_grab_distance : float = 100
#
#@export var ship_force : Vector2 = Vector2(1.5,1.5)
#
#@export var random_force : float = 0.25
#
#@export var jolt_force : float = 200.0
#@export var jolt_reduction : float = 1000.0

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

func _ready() -> void:
	ProjectSettings.set_setting("physics/2d/default_linear_damp", GLOBALS.INVENTORY_ITEM_MOVE_DRAG)
	ProjectSettings.set_setting("physics/2d/default_angular_damp", GLOBALS.INVENTORY_ITEM_ROTATION_DRAG)

func _physics_process(delta: float) -> void:
	_get_ship_speed()
	_add_random()
	if _jolt_force > 0: _jolt_force = move_toward(_jolt_force, 0, GLOBALS.INVENTORY_JOLT_FORCE_REDUCTION * delta)
	_apply_forces()

func _get_ship_speed() -> void:
	
	ship_direction = Vector2(
		(Ship.instance.acceleration.x * (GLOBALS.INVENTORY_SHIP_FORCE.x/2)) + (Ship.instance.proportional_speed.x * GLOBALS.INVENTORY_SHIP_FORCE.x),
		#(Ship.instance.acceleration.y + abs(Ship.instance.proportional_speed.x)) * ship_force.y
		(Ship.instance.acceleration.y + Ship.instance.proportional_speed.y) * GLOBALS.INVENTORY_SHIP_FORCE.y
	) 
	
	#ship_direction = Vector2(
		#-Ship.instance.proportional_speed.x * ship_force.x,
		#Ship.instance.proportional_speed.y * ship_force.y
	#)

func _add_random() -> void:
	_random_direction = (_random_direction + GLOBALS.random_vector2()).normalized() # Vector2(remap(randf(),0,1,-1,1),remap(randf(),0,1,-1,1))).normalized()

func _apply_forces() -> void:
	
	if ship_direction:
		gravity_direction = ship_direction + (_random_direction * GLOBALS.INVENTORY_RANDOM_FORCE * _jolt_force)
	else:		
		gravity_direction = _direction + (_random_direction * GLOBALS.INVENTORY_RANDOM_FORCE * _jolt_force)
	
	if _jolt_force > 0:
		gravity_direction += GLOBALS.random_vector2_normalised() * _jolt_force
	
	
	gravity = force



func jolt() -> void:
	_jolt_force = GLOBALS.INVENTORY_JOLT_FORCE



func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	#print_rich(DEBUG_NAME,"OnInputEvent > Clicked!")
	
	if has_overlapping_bodies() && event is InputEventMouseButton && Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		print_rich(DEBUG_NAME,"OnInputEvent > Clicked! Telling InventoryManager to start drag force on nearest object...")
		
		var _closest : RigidBody2D = null
		var _dist : float = GLOBALS.INVENTORY_MINIMUM_GRAB_DISTANCE * GLOBALS.INVENTORY_MINIMUM_GRAB_DISTANCE
		var _mouse_pos = viewport.get_mouse_position()
		for _object in get_overlapping_bodies():
			var _new_dist = _mouse_pos.distance_squared_to(_object.global_position)
			if _new_dist < _dist:
				_dist = _new_dist
				_closest = _object
		
		if _closest != null: 
			InventoryManager.dragging(_closest,Vector2.ZERO)
		
