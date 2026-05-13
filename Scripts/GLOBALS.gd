class_name GLOBALS


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
