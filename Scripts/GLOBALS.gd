class_name GLOBALS extends Node
static var instance : GLOBALS

static var game_config_manager : GameConfigManager = null


#region Level Variables

static var LEVEL_SECS_BEFORE_AUTHORITIES_ARRIVE : int = 1

#endregion

#region Ship Variables

static var SHIP_MAX_HEALTH : int = 1
static var SHIP_MINIMUM_BOUNCE_SPEED : float = 1

static var SHIP_ROTATION_SPEED : float = 1
static var SHIP_ROTATION_CHANGE_RATE : float = 1
static var SHIP_BOOST_ROTATION_CHANGE_RATE : float = 1
static var SHIP_ROTATION_ACCELERATION : float = 1

static var SHIP_FORWARD_SPEED : float = 1
static var SHIP_FORWARD_CHANGE_RATE : float = 1
static var SHIP_BACK_SPEED : float = 1
static var SHIP_BACK_CHANGE_RATE : float = 1
static var SHIP_NEUTRAL_CHANGE_RATE : float = 1
static var SHIP_BOOST_SPEED : float = 1
static var SHIP_BOOST_CHANGE_RATE : float = 1

#endregion


#region Inventory Variables

static var INVENTORY_CHANCE_TO_OPEN_ON_DAMAGE : float = 1

static var INVENTORY_MINIMUM_GRAB_DISTANCE : float = 1
static var INVENTORY_SHIP_FORCE : Vector2 = Vector2.ONE
static var INVENTORY_RANDOM_FORCE : float = 1
static var INVENTORY_JOLT_FORCE : float = 1
static var INVENTORY_JOLT_FORCE_REDUCTION : float = 1
static var INVENTORY_DRAG_FORCE : float = 1
static var INVENTORY_RELEASE_FORCE : float = 1

static var INVENTORY_CAMERA_TILT_STRENGTH : float = 1
static var INVENTORY_CAMERA_TILT_SPEED : float = 1
static var INVENTORY_CAMERA_PAN_STRENGTH : Vector2 = Vector2.ONE
static var INVENTORY_CAMERA_PAN_SPEED : float = 1

#endregion


#region Item Variables

static var INVENTORY_ITEM_MOVE_DRAG : float = 1
static var INVENTORY_ITEM_ROTATION_DRAG : float = 1

static var ROCK_MASS : float = 1
static var ROCK_FORCE_SCALE : float = 1
static var ROCK_EXTRA_MOVE_DRAG : float = 1
static var ROCK_EXTRA_ROTATION_DRAG : float = 1

static var CRATE_MASS : float = 1
static var CRATE_FORCE_SCALE : float = 1
static var CRATE_EXTRA_MOVE_DRAG : float = 1
static var CRATE_EXTRA_ROTATION_DRAG : float = 1

static var PIPE_MASS : float = 1
static var PIPE_FORCE_SCALE : float = 1
static var PIPE_EXTRA_MOVE_DRAG : float = 1
static var PIPE_EXTRA_ROTATION_DRAG : float = 1

#endregion






static var health : int = 0 : 
	set(value):
		if health != value:
			health = value
			instance._on_health_changed.emit()

static var proportional_health : float :
	get: return health as float / SHIP_MAX_HEALTH as float


signal _on_health_changed
static func on_health_changed() -> Signal: return instance._on_health_changed




func _init() -> void:
	instance = self
	game_config_manager = preload("res://Configs/GameConfigManager.tres")
	restart_game()

#func _ready() -> void:



static func restart_game() -> void:
	game_config_manager.apply_game_config()
	
	health = SHIP_MAX_HEALTH









static func random_color(randr:=Vector2(0,1),randg:=Vector2(0,1),randb:=Vector2(0,1),randa:=Vector2(1,1)) -> Color:
	return Color(randf_range(randr.x,randr.y),randf_range(randg.x,randg.y),randf_range(randb.x,randb.y),randf_range(randa.x,randa.y))

static func random_rotation(range:float=360) -> float:
	return deg_to_rad(randf_range(-range,range))
	
static func random_vector2(_length:float=1.0) -> Vector2:
	if !_length: return Vector2.ZERO
	return Vector2(remap(randf(),0,1,-1,1),remap(randf(),0,1,-1,1)) * _length

static func random_vector2_normalised(_length:float=1.0) -> Vector2:
	if !_length: return Vector2.ZERO
	return Vector2(remap(randf(),0,1,-1,1),remap(randf(),0,1,-1,1)).normalized() * _length
