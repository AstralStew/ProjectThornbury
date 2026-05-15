class_name InventoryManager extends MarginContainer
const DEBUG_NAME = "[b][InventoryManager][/b] "
static var instance : InventoryManager = null

enum ItemType {Rock,Crate,Pipe}

@export var item_rock_prefab : PackedScene = null
@export var item_crate_prefab : PackedScene = null
@export var item_pipe_prefab : PackedScene = null

@onready var debug_line : Line2D = $DebugLine
@onready var item_holder : Node2D = $SubViewportContainer/SubViewport/ItemHolder

#@export var drag_force : float = 2.5
#@export var release_force : float = 0.5
#@export_range(0,1) var chance_to_open_chute_on_damage : float = 0.5

@export_category("READ ONLY")
@export var _is_dragging : bool = false
static var is_dragging : bool :
	get: return instance._is_dragging
	set(value):
		instance._is_dragging = value

var _active_debug_line : Line2D = null

static var chute_open : bool = false

func _enter_tree() -> void:
	instance = self
	chute_open = false
	
	GLOBALS.on_health_changed().connect(cancel_dragging)
	GLOBALS.on_health_changed().connect(maybe_open_chute)


func maybe_open_chute() -> void:
	if randf() < GLOBALS.INVENTORY_CHANCE_TO_OPEN_ON_DAMAGE: chute_open = true


func _physics_process(delta: float) -> void:
	if Ship.instance.has_control:
		chute_open = Input.is_action_pressed("OpenChute")

static func add_item(_type:ItemType) -> void:
	instance._add_item(_type)
func _add_item(_type:ItemType) -> void:
	var _prefab : PackedScene = null
	var _name : String 
	match _type:
		ItemType.Rock:
			_prefab = item_rock_prefab
			_name = "<ItemRock>"
		ItemType.Crate:
			_prefab = item_crate_prefab
			_name = "<ItemCrate>"
		ItemType.Pipe:
			_prefab = item_pipe_prefab
			_name = "<ItemPipe>"
	
	await get_tree().physics_frame
	var _new_scene = _prefab.instantiate() as Item
	item_holder.add_child(_new_scene)
	_new_scene.global_position = Chute.instance.entrance_point.global_position + Vector2(remap(randf(),0,1,-30,30),remap(randf(),0,1,0,15))
	_new_scene.reset_physics_interpolation()
	_new_scene.name = _name
	_new_scene.set_deferred("linear_velocity", Vector2(remap(randf(),0,1,-1,1), remap(randf(),0,1,1,3)).normalized() * 800)


func cancel_dragging() -> void:
	if _active_debug_line != null:
		_active_debug_line.queue_free()


static func dragging(_object:Item,_click_pos:Vector2) -> void:
	instance._dragging(_object,_click_pos)
func _dragging(_object:Item,_click_pos:Vector2) -> void:
	if is_dragging:
		print_rich(DEBUG_NAME,"[color=orange]Dragging > Already dragging an object, ignoring.")
		return
	
	
	print_rich(DEBUG_NAME,"Dragging > Object '"+_object.name+"' initialised dragging! Waiting for mouse release...")
	
	is_dragging = true
	_object.is_dragged = true
	
	_active_debug_line = debug_line.duplicate()
	_object.add_child(_active_debug_line) #.reparent(_object)
	_active_debug_line.position = _click_pos
	_active_debug_line.visible = true
	
	var _move_vector : Vector2
	var _old_damp = _object.linear_damp
	_object.linear_damp = 2.5
	_object.linear_damp_mode = RigidBody2D.DAMP_MODE_REPLACE
	
	while Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_active_debug_line.set_point_position(1,_active_debug_line.get_local_mouse_position())
		_move_vector = _active_debug_line.to_global(_active_debug_line.get_point_position(1)) - _active_debug_line.to_global(_active_debug_line.get_point_position(0)) 
		_object.apply_central_force(_move_vector * GLOBALS.INVENTORY_DRAG_FORCE)
		await get_tree().physics_frame
		if !is_instance_valid(_object) || _active_debug_line == null || _active_debug_line.is_queued_for_deletion(): break
	
	if is_instance_valid(_object): 
		_object.is_dragged = false
		if _active_debug_line != null: _active_debug_line.queue_free()
		_object.linear_damp_mode = RigidBody2D.DAMP_MODE_COMBINE
		_object.linear_damp = _old_damp
		_object.apply_central_impulse(_move_vector * GLOBALS.INVENTORY_RELEASE_FORCE)
		print_rich(DEBUG_NAME,"Dragging > Mouse released! Releasing '"+_object.name+"' with force of "+str(_move_vector)+" * "+str(GLOBALS.INVENTORY_RELEASE_FORCE))
	print_rich(DEBUG_NAME,"Dragging > Oops, objects been freed! Cancelling.")
	is_dragging = false
