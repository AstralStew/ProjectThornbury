class_name InventoryManager extends MarginContainer
const DEBUG_NAME = "[b][InventoryManager][/b] "
static var instance : InventoryManager = null

@onready var debug_line : Line2D = $DebugLine

@export var move_force : float = 0.5

func _enter_tree() -> void:
	instance = self

func dragging(_object:RigidBody2D,_click_pos:Vector2) -> void:
	print_rich(DEBUG_NAME,"Dragging > Object '"+_object.name+"' initialised dragging! Waiting for mouse release...")
	var _drag_start_pos = get_viewport().get_mouse_position()
	debug_line.visible = true
	debug_line.global_position = _drag_start_pos
	
	while Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		debug_line.set_point_position(1,debug_line.get_local_mouse_position())
		await get_tree().physics_frame
	
	var _move_vector = get_viewport().get_mouse_position() - _drag_start_pos # _drag_start_pos.direction_to(get_viewport().get_mouse_position())  
	_object.apply_central_impulse(_move_vector * move_force)#, _object.global_position)
	debug_line.visible = false
	print_rich(DEBUG_NAME,"Dragging > Mouse released! Moving '"+_object.name+"' with force of "+str(_move_vector)+" * "+str(move_force))
	
