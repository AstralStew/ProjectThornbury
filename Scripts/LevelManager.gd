class_name LevelManager extends Node2D
const DEBUG_NAME = "[b][LevelManager][/b] "
static var instance : LevelManager = null

@onready var collectable_holder : Node2D = $CollectableHolder


@export_category("READ ONLY")

@export var stations : Array[Station] = []
static var target_prosperity : int = -1
static var current_prosperity : float = -1 

func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	for _station:Station in get_tree().get_nodes_in_group("Stations"):
		stations.append(_station)
		target_prosperity += _station.prosperity_target
	
