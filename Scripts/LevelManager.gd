class_name LevelManager extends Node2D
const DEBUG_NAME = "[b][LevelManager][/b] "
static var instance : LevelManager = null

@onready var collectable_holder : Node2D = $CollectableHolder

func _enter_tree() -> void:
	instance = self
