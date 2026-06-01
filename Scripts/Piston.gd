class_name Piston extends Line2D

@export var remote_node : Node2D = null

@onready var piston_path: Path2D = $PistonPath
@onready var follower: PathFollow2D = $PistonPath/PathFollow2D
@onready var remote_transform: RemoteTransform2D = $PistonPath/PathFollow2D/RemoteTransform2D

@export var shadow_distance : float = 5
@export var fetch_speed : float = 10
@export_range(0,1) var fetch_target : float = 0
@export var fetch_ease : Tween.EaseType = Tween.EaseType.EASE_IN_OUT
@export var fetch_trans : Tween.TransitionType = Tween.TransitionType.TRANS_SINE
@export var return_speed : float = 15
@export_range(0,1) var return_target : float = 0.9
@export var return_ease : Tween.EaseType = Tween.EaseType.EASE_IN_OUT
@export var return_trans : Tween.TransitionType = Tween.TransitionType.TRANS_QUAD
@onready var _animatable_body_2d: AnimatableBody2D = $AnimatableBody2D
@onready var _shadow: Sprite2D = $AnimatableBody2D/Shadow
@onready var _holder_pos: Marker2D = $AnimatableBody2D/HolderPos


@export_category("READ ONLY")
@export var crate : Collectable = null

var _path_reversed : bool = false

func _ready() -> void:
	
	var new_curve = Curve2D.new()
	
	#set_point_position(1,Vector2(randi_range(-440,-140),0))
	
	for i in get_point_count():
		new_curve.add_point(get_point_position(i))
	
	#obstacle_end_cap.position = get_point_position(get_point_count()-1)
	
	#var _dir : Vector2 = obstacle_end_cap.global_position.direction_to(to_global(get_point_position(0)))
#	
	#obstacle_end_cap.global_position += _dir * -50
	#obstacle_end_cap.global_rotation = _dir.angle()
	
	piston_path.curve = new_curve
	_path_reversed = randi() % 2
	
	#obstacle_end_cap.visible = true
	
	remote_transform.remote_path = remote_transform.get_path_to(remote_node)
	remote_node.global_rotation_degrees = remote_transform.global_rotation_degrees
	
	moving()



func _physics_process(delta: float) -> void:
	_shadow.global_position = _animatable_body_2d.global_position + Vector2(shadow_distance,shadow_distance)

func moving() -> void:
	#var _speed = 12
		
	await get_tree().create_timer(randf() * 8).timeout
	
	var _tween : Tween = null
	while (true):
		
		if _tween: _tween.kill()
		_tween = create_tween().set_ease(return_ease).set_trans(return_trans)
		_tween.tween_property(follower,"progress_ratio",return_target,1 / (return_speed * get_physics_process_delta_time()))
		while _tween.is_running():
			remote_node.global_rotation_degrees = remote_transform.global_rotation_degrees
			await get_tree().physics_frame
		#await _tween.finished
		
		if _holder_pos.get_child_count() == 0:
			OutsideManager.add_collectable(InventoryManager.ItemType.Crate,_holder_pos)
		
		
		#remote_node.global_rotation_degrees = remote_transform.global_rotation_degrees + 180
		if _tween: _tween.kill()
		_tween = create_tween().set_ease(fetch_ease).set_trans(fetch_trans)
		_tween.tween_property(follower,"progress_ratio",fetch_target,1 / (fetch_speed * get_physics_process_delta_time()))
		while _tween.is_running():
			remote_node.global_rotation_degrees = remote_transform.global_rotation_degrees + 180
			await get_tree().physics_frame
		#await _tween.finished
		#remote_node.global_rotation_degrees = remote_transform.global_rotation_degrees
		
		if _holder_pos.get_child_count() != 0:
			_holder_pos.get_child(0).queue_free()
