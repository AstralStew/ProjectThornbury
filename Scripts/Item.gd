class_name Item extends RigidBody2D
var DEBUG_NAME : String :
	get: return "[b][Item("+name+")][/b] "

@export var type : InventoryManager.ItemType = InventoryManager.ItemType.Rock

@export var is_dragged : bool = false
@export var finished_spawning : bool = false

## How heavy the item is in kilograms
@export var ROCK_MASS : float = 1.0
## How much the item is affected by the forces (1.0 = 100%)
@export var ROCK_FORCE_SCALE : float = 1.0
## How much more the item's movement is reduced over time to bring it to a stop (on top of the 0.5 that all items have by default)
@export var ROCK_EXTRA_MOVE_DRAG : float = 0.0
## How much more the item's rotation is reduced over time to bring it to a stop (on top of the 1.0 that all items have by default)
@export var ROCK_EXTRA_ROTATION_DRAG : float = 0.0

var final_child_scale : Vector2 

func _ready() -> void:
	final_child_scale = get_child(0).scale
	
	match type:
		InventoryManager.ItemType.Rock:
			mass = GLOBALS.ROCK_MASS
			gravity_scale = GLOBALS.ROCK_FORCE_SCALE
			linear_damp = GLOBALS.ROCK_EXTRA_MOVE_DRAG
			angular_damp = GLOBALS.ROCK_EXTRA_ROTATION_DRAG
		InventoryManager.ItemType.Crate:
			mass = GLOBALS.CRATE_MASS
			gravity_scale = GLOBALS.CRATE_FORCE_SCALE
			linear_damp = GLOBALS.CRATE_EXTRA_MOVE_DRAG
			angular_damp = GLOBALS.CRATE_EXTRA_ROTATION_DRAG
		InventoryManager.ItemType.Pipe:
			mass = GLOBALS.PIPE_MASS
			gravity_scale = GLOBALS.PIPE_FORCE_SCALE
			linear_damp = GLOBALS.PIPE_EXTRA_MOVE_DRAG
			angular_damp = GLOBALS.PIPE_EXTRA_ROTATION_DRAG
	
	if !finished_spawning: _spawn_countdown()
	_spawn_countdown()

func _spawn_countdown() -> void:
	
	
	modulate = Color.TRANSPARENT
	#global_position = Chute.instance.global_position
	
	get_child(0).scale = Vector2(0.25,0.25)
	
	#get_child(1).visible = false
	
	var _tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(self,"modulate",Color.WHITE,0.33)
	#_tween.tween_property(self,"global_position",Chute.instance.global_position + Vector2(remap(randf(),0,1,-30,30),remap(randf(),0,1,-30,30)),0.75)
	_tween.tween_property(get_child(0),"scale",final_child_scale,0.66)
	#await get_tree().create_timer(0.75).timeout
		
	await get_tree().create_timer(0.5,false).timeout
	
	#get_child(1).visible = true
	
	await get_tree().create_timer(0.33,false).timeout
	
	finished_spawning = true


func jettison() -> void:
	freeze = true      
	
	for child in get_children():
		if child is Line2D:
			child.visible = false
	
	OutsideManager.add_collectable(type)
	
	#get_child(1).visible = false
	
	var _tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(self,"modulate",Color(0,0,0,0),0.6)
	_tween.tween_property(self,"global_position",Chute.instance.exit_point.global_position + Vector2(remap(randf(),0,1,-30,30),remap(randf(),0,1,-5,5)),0.66)
	_tween.tween_property(self,"scale",Vector2(0.25,0.25),0.66)
	await get_tree().create_timer(0.66,false).timeout
	
	queue_free()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	
	if !InventoryManager.is_dragging && event is InputEventMouseButton && Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		print_rich(DEBUG_NAME,"OnInputEvent > Clicked! Telling InventoryManager to start drag force...")
		InventoryManager.dragging(self,get_local_mouse_position())
		


func set_outline_glow(_color:Color) -> void:
	get_child(0).get_child(0).modulate = _color
