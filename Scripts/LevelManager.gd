class_name LevelManager extends Node2D
const DEBUG_NAME = "[b][LevelManager][/b] "
static var instance : LevelManager = null

@onready var collectable_holder : Node2D = $CollectableHolder

@export var rotate_level : bool = true

@export_category("READ ONLY")

@export var stations : Array[Station] = []
static var target_prosperity : int = 0
static var current_prosperity : float = 0

var _stations_with_orders : int = 0

signal _on_prosperity_updated(percentage)
static func on_prosperity_updated() -> Signal: return instance._on_prosperity_updated

signal _on_level_ready
static func on_level_ready() -> Signal: return instance._on_level_ready

func _enter_tree() -> void:
	instance = self
	target_prosperity = 0
	current_prosperity = 0
	if rotate_level: rotation = GLOBALS.random_rotation(180)
	

func activate_stations_over_time() -> void:
	
	var _elapsed_time : float = 4
	while stations.size() > 0:
		while _elapsed_time < 5 + (30 * _stations_with_orders):
			_elapsed_time += 1
			await get_tree().create_timer(1,false).timeout
		
		print(DEBUG_NAME,"ActivateStationsOverTime > Activating next station...")
		stations.front().make_order()
		stations.append(stations.pop_front())
		_stations_with_orders += 1
		_elapsed_time = 0 
	
	print(DEBUG_NAME,"ActivateStationsOverTime > No more stations! You should win now :)")
	#await get_tree().create_timer(10,false).timeout
	#var _first : bool = false
	#for _station:Station in get_tree().get_nodes_in_group("Stations"):
		#if !_first: _station.make_order()
		#else: _station.cooldown()
		#
		#await get_tree().create_timer(20,false).timeout



#func cooldown() -> void:
	##update_text()
	#for i in prosperity+1:
		#await get_tree().create_timer(randf_range(cooldown_duration.x,cooldown_duration.y),false).timeout
	#print_rich(DEBUG_NAME,"Cooldown > Cooldown finished! Making a new order...")
	#make_order()

func _ready() -> void:
	for _station:Station in get_tree().get_nodes_in_group("Stations"):
		print_rich(DEBUG_NAME,"Ready > Adding station '"+_station.name+"'")
		stations.append(_station)
		target_prosperity += _station.prosperity_target
		_station.on_complete_order.connect(increase_prosperity)
		_station.on_complete_order.connect(func(ref):_stations_with_orders -= 1)
		_station.on_become_prosperous.connect(station_became_prosperous)
		_station.on_become_prosperous.connect(func(ref):stations.remove_at(stations.find(_station)))
	
	stations.shuffle()
	#activate_stations_over_time()
	
	_on_prosperity_updated.emit(current_prosperity as float / target_prosperity as float)
	
	_on_level_ready.emit()

func increase_prosperity(_station:Station) -> void:
	print_rich(DEBUG_NAME,"IncreaseProsperity > Adding 1 and updating prosperity")
	current_prosperity += 1
	_on_prosperity_updated.emit(current_prosperity as float / target_prosperity as float)


func station_became_prosperous(_station:Station) -> void:
	print_rich("StationBecameProsperous > Adding a bunch of bounty!")
	
	BountyManager.add_to_bounty(5000)
