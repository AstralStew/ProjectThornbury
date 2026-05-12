class_name InventoryManager extends MarginContainer
const DEBUG_NAME = "[b][InventoryManager][/b] "
static var instance : InventoryManager = null

enum ItemType {ItemA,ItemB,ItemC}

@export var item_A_prefab : PackedScene = null
@export var item_B_prefab : PackedScene = null
@export var item_C_prefab : PackedScene = null

@onready var debug_line : Line2D = $DebugLine
@onready var item_holder : Node2D = $SubViewportContainer/SubViewport/ItemHolder

@export var move_force : float = 0.5

static var chute_open : bool = false

func _enter_tree() -> void:
	instance = self


func _physics_process(delta: float) -> void:
	chute_open = Input.is_action_pressed("OpenChute")

static func add_item(_type:ItemType) -> void:
	instance._add_item(_type)
func _add_item(_type:ItemType) -> void:
	var _prefab : PackedScene = null
	var _name : String 
	match _type:
		ItemType.ItemA:
			_prefab = item_A_prefab
			_name = "<ItemA>"
		ItemType.ItemB:
			_prefab = item_B_prefab
			_name = "<ItemB>"
		ItemType.ItemC:
			_prefab = item_C_prefab
			_name = "<ItemC>"
	
	await get_tree().physics_frame
	var _new_scene = _prefab.instantiate() as Item
	item_holder.add_child(_new_scene)
	_new_scene.global_position = Chute.instance.global_position
	_new_scene.reset_physics_interpolation()
	_new_scene.name = _name
	_new_scene.set_deferred("linear_velocity", Vector2(remap(randf(),0,1,-1,1), remap(randf(),0,1,1,3)).normalized() * 800)



static func dragging(_object:RigidBody2D,_click_pos:Vector2) -> void:
	instance._dragging(_object,_click_pos)
func _dragging(_object:RigidBody2D,_click_pos:Vector2) -> void:
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
	
