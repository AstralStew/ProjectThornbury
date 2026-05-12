extends Line2D

@export var number_of_points : int = 20
@export var min_time_step : float = 0.1
@export var min_dist : float = 1.0

func _ready() -> void:
	add_point(get_parent().global_position)

var _timer : float
func _process(delta):
	
	modulate = Color.GOLD.lerp(Color.WHITE, ease(remap(Ship.instance.speed.y,0,-200,0,1),0.25))
	
	_timer += delta
	if _timer >= min_time_step:
		if to_global(get_point_position(0)).distance_to(get_parent().global_position) > min_dist:
			add_point(get_parent().global_position)
		if points.size() > number_of_points:
			remove_point(0)
		_timer = 0
	else:
		set_point_position(points.size()-1,get_parent().global_position)
