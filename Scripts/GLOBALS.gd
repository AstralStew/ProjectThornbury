class_name GLOBALS

static func random_vector2(_length:float=1.0) -> Vector2:
	if !_length: return Vector2.ZERO
	return Vector2(remap(randf(),0,1,-1,1),remap(randf(),0,1,-1,1)) * _length

static func random_vector2_normalised(_length:float=1.0) -> Vector2:
	if !_length: return Vector2.ZERO
	return Vector2(remap(randf(),0,1,-1,1),remap(randf(),0,1,-1,1)).normalized() * _length
