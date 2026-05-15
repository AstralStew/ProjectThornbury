class_name LevelManager extends Node2D
const DEBUG_NAME = "[b][LevelManager][/b] "
static var instance : LevelManager = null

@onready var collectable_holder : Node2D = $CollectableHolder

@export_category("READ ONLY")

@export var stations : Array[Station] = []
static var target_prosperity : int = 0
static var current_prosperity : float = 0

signal _on_prosperity_updated(percentage)
static func on_prosperity_updated() -> Signal: return instance._on_prosperity_updated

func _enter_tree() -> void:
	instance = self
	target_prosperity = 0
	current_prosperity = 0

func _ready() -> void:
	for _station:Station in get_tree().get_nodes_in_group("Stations"):
		print_rich(DEBUG_NAME,"Ready > Adding station '"+_station.name+"'")
		stations.append(_station)
		target_prosperity += _station.prosperity_target
		_station.on_complete_order.connect(increase_prosperity)
		_station.on_become_prosperous.connect(station_became_prosperous)
	_on_prosperity_updated.emit(current_prosperity as float / target_prosperity as float)

func increase_prosperity(_station:Station) -> void:
	print_rich(DEBUG_NAME,"IncreaseProsperity > Adding 1 and updating prosperity")
	current_prosperity += 1
	_on_prosperity_updated.emit(current_prosperity as float / target_prosperity as float)


func station_became_prosperous(_station:Station) -> void:
	print_rich("StationBecameProsperous > [i]does nothing right now lol[/i]")
