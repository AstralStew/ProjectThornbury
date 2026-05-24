class_name Collectable extends Area2D
var DEBUG_NAME : String :
	get: return "[b][Collectable("+name+")][/b] "

@export var type : InventoryManager.ItemType = InventoryManager.ItemType.Rock

@export var finished_spawning := false
@export var collected := false

func _ready() -> void:
	if !finished_spawning: _spawn_countdown()
	rotation = GLOBALS.random_rotation(360)

func _spawn_countdown() -> void:
	await get_tree().physics_frame
	
	z_index = 2
	
	
	var _land_time = randf_range(0.7,1.2)
	var _speed = randf_range(0.8,1) * clamp(remap(abs(Ship.instance.speed.y),10,200,35,100),35,100)
	
	var _tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel()
	_tween.tween_property(self,"global_position",global_position + (Ship.instance.global_position.direction_to(global_position + (Ship.instance.global_transform.y + GLOBALS.random_vector2().normalized())) * _speed),_land_time)
	_tween.tween_property(self,"rotation_degrees", randf_range(90,270) * (-1 if randi() % 2 else 1),_land_time)
	_tween.tween_property(self,"scale",Vector2(0.7,0.7),_land_time)
	_tween.tween_property(self,"modulate",Color.WHITE,_land_time/3).set_delay(_land_time/10)
	
	await get_tree().create_timer(_land_time,false).timeout
	
	z_index = 0
	finished_spawning = true
	

func collect() -> void:
	if collected || !finished_spawning || !InventoryManager.chute_open: return
	
	print_rich(DEBUG_NAME,"Collect > Chute is open! Telling InventoryManager what I am...")
	
	InventoryManager.add_item(type)
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Ship:
		collect()
