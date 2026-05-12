extends Line2D

func _process(delta):
	add_point(get_parent().global_position)
	if points.size() > 60:
		remove_point(0)
