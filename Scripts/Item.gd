class_name Item extends RigidBody2D
var DEBUG_NAME : String :
	get: return "[b][Item("+name+")][/b] "

@export var type : InventoryManager.ItemType = InventoryManager.ItemType.Rock

@export var is_dragged : bool = false
@export var finished_spawning : bool = false

func _ready() -> void:
	if !finished_spawning: _spawn_countdown()
	_spawn_countdown()

func _spawn_countdown() -> void:
	
	
	modulate = Color.TRANSPARENT
	#global_position = Chute.instance.global_position
	get_child(0).scale = Vector2(0.25,0.25)
	
	var _tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(self,"modulate",Color.WHITE,0.33)
	#_tween.tween_property(self,"global_position",Chute.instance.global_position + Vector2(remap(randf(),0,1,-30,30),remap(randf(),0,1,-30,30)),0.75)
	_tween.tween_property(get_child(0),"scale",Vector2(1,1),0.66)
	#await get_tree().create_timer(0.75).timeout
	
	
	await get_tree().create_timer(1.0).timeout
	finished_spawning = true


func jettison() -> void:
	freeze = true      
	
	for child in get_children():
		if child is Line2D:
			child.visible = false
	
	OutsideManager.add_collectable(type)
	
	var _tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(self,"modulate",Color(0,0,0,0),0.6)
	_tween.tween_property(self,"global_position",Chute.instance.exit_point.global_position + Vector2(remap(randf(),0,1,-30,30),remap(randf(),0,1,-5,5)),0.66)
	_tween.tween_property(self,"scale",Vector2(0.25,0.25),0.66)
	await get_tree().create_timer(0.66).timeout
	
	queue_free()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	
	if event is InputEventMouseButton && Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		print_rich(DEBUG_NAME,"OnInputEvent > Clicked! Telling InventoryManager to start drag force...")
		InventoryManager.dragging(self,get_local_mouse_position())
		
