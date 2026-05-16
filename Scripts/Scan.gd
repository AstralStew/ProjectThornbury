class_name Scan extends Area2D
var DEBUG_NAME : String :
	get: return "[b][Scan][/b] "

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	scanning()
	

var _tween : Tween
func scanning() -> void:
	
	var scan_time = 0.5
	
	var _size = Vector2(randf(),randf()).normalized() * 400
	print("size = "+str(_size))
	$Panel.size = _size
	$Panel.position = -_size/2
	$CollisionShape2D.scale = _size
	rotation = GLOBALS.random_rotation()
	
	
	await get_tree().create_timer(3,false).timeout
	
	if _tween: _tween.kill()
	
	_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(self,"modulate",Color(1,1,0,0),scan_time)
	
	await get_tree().create_timer(1,false).timeout
	_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(self,"modulate",Color(1,1,0,1),scan_time)
	
	await get_tree().create_timer(1,false).timeout
	_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(self,"modulate",Color(1,1,0,0),scan_time)
	
	await get_tree().create_timer(1,false).timeout
	_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(self,"modulate",Color(1,1,0,1),scan_time)
	
	await get_tree().create_timer(1,false).timeout
	_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(self,"modulate",Color(1,1,0,0),scan_time)
	
	await get_tree().create_timer(1,false).timeout
	_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(self,"modulate",Color(1,1,0,1),scan_time)
	
	await get_tree().create_timer(1,false).timeout
	
	
	
	if has_overlapping_bodies():
			_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
			_tween.tween_property(self,"modulate",Color(1,0,0,1),scan_time)
			for _body:Item in get_overlapping_bodies():
				print_rich(DEBUG_NAME,"[color=red]Scanning > GOT ONE BAWS")
	else:
		_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		_tween.tween_property(self,"modulate",Color(0,1,0,1),scan_time)
	
	await get_tree().create_timer(1,false).timeout
	
	_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(self,"modulate",Color(0,0,0,0),scan_time)
	
	await get_tree().create_timer(1,false).timeout
	
	scanning()
	
