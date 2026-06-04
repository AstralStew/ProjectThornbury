class_name Obstacle extends Node2D

@export var top_layer : Node2D = null
@export var shadow_layer : Node2D = null

@export var shadow_distance : float = 10
@export var parallax_distance : float = 1.5

#@export var parallax_distance_x : float = 1.5
#@export var parallax_distance_y : float = 1.5

var _camera : Camera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_camera = Ship.instance.find_child("Camera2D")
	
	LevelManager.on_level_ready().connect(on_level_ready)
	

func on_level_ready() -> void:
	await get_tree().process_frame
	shadow_layer.global_position = global_position + (Vector2.ONE * shadow_distance)
	

var top_x : float = 0
var top_y : float = 0
func _physics_process(delta: float) -> void:
	if parallax_distance != 0:
		top_x = ((_camera.get_target_position().x - global_position.x) * parallax_distance * -0.01)
		top_y = ((_camera.get_target_position().y - global_position.y) * parallax_distance * -0.01)
		top_layer.global_position = global_position + Vector2(top_x,top_y) # ((_camera.get_target_position() - global_position) * parallax_distance * -0.01)
