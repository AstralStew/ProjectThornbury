class_name Notification extends Node2D

@export var minimum_alpha_distance : float = 6000
@export var maximum_alpha_distance : float = 4000
@export var minimum_scale_distance : float = 3000
@export var maximum_scale_distance : float = 200
@export var disappear_distance : float = 200

@export_category("READ ONLY")

@export var target_position : Vector2 = Vector2(460,460)
@export var is_tracking : bool = false
@export var is_hovered : bool = false
#
#func _ready() -> void:
	#tracking(get_tree().get_first_node_in_group("Stations"))

func stop(_node:Node2D) -> void:
	is_tracking = false
	visible = false

func tracking(_node:Node2D) -> void:
	var _minimum_alpha_sqr_distance : float = minimum_alpha_distance * minimum_alpha_distance
	var _maximum_alpha_sqr_distance : float = maximum_alpha_distance * maximum_alpha_distance
	var _minimum_scale_sqr_distance : float = minimum_scale_distance * minimum_scale_distance
	var _maximum_scale_sqr_distance : float = maximum_scale_distance * maximum_scale_distance
	var _disappear_sqr_distance : float = disappear_distance * disappear_distance
	
	target_position = _node.global_position # LevelManager.instance.to_local(get_tree().get_first_node_in_group("Stations").global_position)
	
	var _camera : Camera2D = $"../../Ship/Camera2D"
	var _camera_pos : Vector2
	var _distance : float
	
	is_tracking = true
	visible = true
	while(is_tracking):
		_camera_pos = _camera.get_screen_center_position()
		global_position = target_position.clamp(_camera_pos-Vector2(310,263), _camera_pos+Vector2(300,263))
		
		if is_hovered:
			$SpriteIcon.modulate = Color(1,1,1,1)
			scale = Vector2(1.312,1.312)
		else:
			_distance = _camera_pos.distance_squared_to(target_position)
			
			if _distance < _disappear_sqr_distance:
				visible = false
			else:
				visible = true
			
			if _distance > _minimum_alpha_sqr_distance:
				$SpriteIcon.modulate = Color(1,1,1,0.25)
			else:
				$SpriteIcon.modulate = Color(1,1,1,clamp(remap(_distance,_minimum_alpha_sqr_distance,_maximum_alpha_sqr_distance,0.1,1.0),0.25,1.0))
			
			if _distance > _minimum_scale_sqr_distance:
				scale = Vector2(0.69,0.69)
			else:
				scale = Vector2.ONE * clamp(remap(_distance,_maximum_scale_sqr_distance,_minimum_scale_sqr_distance,1.312,0.69),0.69,1.312)
		
		await get_tree().physics_frame
		
		if !is_inside_tree(): break


func _on_mouse_entered() -> void:
	is_hovered = true


func _mouse_exited() -> void:
	is_hovered = false
