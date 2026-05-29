class_name Road extends Line2D

@onready var hoverscanner_prefab : PackedScene = preload("res://Scenes/OutsidePrefabs/hoverscanner.tscn")


@export var number_of_followers : int = 2
@export var follower_speed : float = 50
@export var loop_path : bool = true

var road_path : Path2D = null

var followers : Array[PathFollow2D]
var hoverscanners : Array[Hoverscanner]

var _path_reversed : bool = false

func _ready() -> void:
	
	road_path = $RoadPath
	
	var new_curve = Curve2D.new()
	
	for i in get_point_count():
		new_curve.add_point(get_point_position(i))
	
	road_path.curve = new_curve
	_path_reversed = randi() % 2
	
	
	var _new_follower : PathFollow2D
	var _new_hoverscanner : Hoverscanner
	for i in number_of_followers:
		_new_follower = PathFollow2D.new()
		road_path.add_child(_new_follower)
		followers.append(_new_follower)	
		
		_new_hoverscanner = hoverscanner_prefab.instantiate()
		_new_follower.add_child(_new_hoverscanner)
		hoverscanners.append(_new_hoverscanner)
		
		_new_follower.loop = false
		_new_follower.progress_ratio = i * (1 / (number_of_followers as float))
		
		(_new_hoverscanner.get_child(0) as Sprite2D).flip_v = _path_reversed
			



func _physics_process(delta: float) -> void:
	
	#if !loop_path && number_of_followers == 1:
		#if (!_path_reversed && followers[0].progress_ratio == 1.0) || (_path_reversed && followers[0].progress_ratio == 0.0):
			#_path_reversed = !_path_reversed
	
	for i in number_of_followers:
		
		if (!_path_reversed && followers[i].progress_ratio == 1.0) || (_path_reversed && followers[i].progress_ratio == 0.0):
			if loop_path && !hoverscanners[i].is_scanning:
				#followers[i].visible = false
				followers[i].progress_ratio = abs(followers[i].progress_ratio - 1)
				#followers[i].set_deferred("visible",true)
				followers[i].reset_physics_interpolation()
				
			if !loop_path && number_of_followers == 1:
				_path_reversed = !_path_reversed
				(followers[i].get_child(0).get_child(0) as Sprite2D).flip_v = _path_reversed
		
		followers[i].progress += follower_speed * delta * (-1 if _path_reversed else 1)
