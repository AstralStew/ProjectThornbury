class_name OutsideManager extends MarginContainer
const DEBUG_NAME = "[b][OutsideManager][/b] "
static var instance : OutsideManager = null

@export var collectable_A_prefab : PackedScene = null
@export var collectable_B_prefab : PackedScene = null
@export var collectable_C_prefab : PackedScene = null

var collectable_holder : Node2D = null

func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	collectable_holder = ($SubViewportContainer/SubViewport.get_child(0) as LevelManager).collectable_holder



static func add_collectable(_type:InventoryManager.ItemType) -> void:
	instance._add_collectable(_type)
func _add_collectable(_type:InventoryManager.ItemType) -> void:
	var _prefab : PackedScene = null
	var _name : String 
	match _type:
		InventoryManager.ItemType.ItemA:
			_prefab = collectable_A_prefab
			_name = "<CollectableA>"
		InventoryManager.ItemType.ItemB:
			_prefab = collectable_B_prefab
			_name = "<CollectableB>"
		InventoryManager.ItemType.ItemC:
			_prefab = collectable_C_prefab
			_name = "<CollectableC>"
	
	await get_tree().physics_frame
	var _new_scene = _prefab.instantiate() as Collectable
	collectable_holder.add_child(_new_scene)
	_new_scene.global_position = Ship.instance.global_position
	_new_scene.rotation_degrees = randf_range(-360,360)
	_new_scene.reset_physics_interpolation()
	_new_scene.name = _name
	#_new_scene.finished_spawning = false
	#_new_scene.call_deferred("_spawn_countdown")

	
