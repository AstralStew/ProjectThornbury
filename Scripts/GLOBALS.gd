class_name GLOBALS extends Node
static var instance : GLOBALS

static var MAX_HEALTH : int = 6





static var health : int = 0 : 
	set(value):
		if health != value:
			health = value
			instance._on_health_changed.emit()

static var proportional_health : float :
	get: return health as float / MAX_HEALTH as float

signal _on_health_changed
static func on_health_changed() -> Signal:
	return instance._on_health_changed

func _init() -> void:
	instance = self
	restart_game()

func _ready() -> void:
	UIManager.on_restart_game().connect(restart_game)

func restart_game() -> void:
	health = MAX_HEALTH








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
