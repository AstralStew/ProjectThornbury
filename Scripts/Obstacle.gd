class_name Obstacle extends Node2D

@export var top_layer : Node2D = null
@export var shadow_layer : Node2D = null

@export var shadow_distance : float = 10
@export var parallax_distance : float = 1.5

var _camera : Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_camera = Ship.instance.find_child("Camera2D")
	
	LevelManager.on_level_ready().connect(on_level_ready)
	

func on_level_ready() -> void:
	shadow_layer.global_position = global_position + (Vector2.ONE * shadow_distance)
	

func _physics_process(delta: float) -> void:
	if parallax_distance != 0:
		top_layer.global_position = global_position + ((_camera.get_target_position() - global_position) * parallax_distance * -0.01)
