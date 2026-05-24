class_name ShipTrail extends Line2D

@export var number_of_points : int = 20
@export var min_time_step : float = 0.1
@export var min_dist : float = 1.0

@export var trail_pivot : Node2D = null

var _last_point : Vector2 = Vector2.ZERO

func _ready() -> void:
	activate()

var _timer : float
func _physics_process(delta: float) -> void:
	if !visible: return
	
	modulate = Color.GOLD.lerp(Color.WHITE, ease(remap(Ship.instance.speed.y,0,-200,0,1),0.25))
	
	
	var _new_point = trail_pivot.global_position
	_timer += delta
	
	if _timer >= min_time_step:
		#if Ship.instance.to_global(get_point_position(0)).distance_to(trail_pivot.global_position) > min_dist:
		if _last_point.distance_to(_new_point) > min_dist:
			add_point(_new_point)
			_last_point = _new_point
		if points.size() > number_of_points:
			remove_point(0)
		_timer = 0
	elif points.size() > 0:
		set_point_position(points.size()-1,_new_point)


func activate() -> void:
	add_point(trail_pivot.global_position)
	visible = true

func deactivate() -> void:
	clear_points()
	visible = false
