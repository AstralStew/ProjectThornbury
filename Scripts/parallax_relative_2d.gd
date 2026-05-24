extends Parallax2D
class_name ParallaxRelative2D

@export var adjust_screen_offset: bool = true

func _ready():
	if adjust_screen_offset:
		var camera2d = get_viewport().get_camera_2d()
		var vp_size = get_viewport().get_visible_rect().size
		var pos = camera2d.global_position + (vp_size * 0.5)
		
		scroll_offset += (pos - self.global_position) * (Vector2.ONE - scroll_scale)
