class_name Scan extends Area2D
var DEBUG_NAME : String :
	get: return "[b][Scan][/b] "


var _tracking_bodies : bool = false
var _material : ShaderMaterial = null
var _mat_changed : bool = false

signal on_scan_end(number_of_hits)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_material = $Panel/TextureRect.material
	#scanning()


func _physics_process(delta: float) -> void:
	if Engine.time_scale != 1.0 || get_tree().paused:
		_material.set_shader_parameter("speed",0.0)
	else:
		_material.set_shader_parameter("speed",0.5)
		#
		#if get_tree().paused:
			#_material.set_shader_parameter("direction",Vector2.ZERO)
		#else:
			#_material.set_shader_parameter("direction",Vector2.ONE * Engine.time_scale)
			#_material.set_shader_parameter("speed",Engine.time_scale)

var _tween : Tween
func scanning() -> void:
	
	var _size = Vector2(5,5) + Vector2(randf(),randf()).normalized() * 155
	$Panel.size = _size
	$Panel.position = -_size/2
	$CollisionShape2D.scale = _size
	
	position = Vector2(randf() * 540,100 + (randf() * 540)).clamp((_size/2) + (Vector2.ONE * 60),Vector2(540,640) - (_size/2) - (Vector2.ONE * 60))
	
	print("size = "+str(_size)+" position = "+str(position))
	
	#rotation = GLOBALS.random_rotation()
	
	
	#await get_tree().create_timer(3,false).timeout
	
	visible = true
	
	if _tween: _tween.kill()
	
	_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(self,"modulate",Color(1,1,0,1),1)
	
	await get_tree().create_timer(1.5,false).timeout
	
	for _item:Item in  get_overlapping_bodies():
		_item.set_outline_glow(Color(20,20,0,1))
	
	_tracking_bodies = true
	var scan_time = 0.015
	var _number_of_scan_attempts = 20
	while (_number_of_scan_attempts > 0):
		_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		_tween.tween_property(self,"modulate",Color(1,1,0,0),scan_time * _number_of_scan_attempts * 0.5)
		await get_tree().create_timer(scan_time * _number_of_scan_attempts * 0.5,false).timeout
		_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		_tween.tween_property(self,"modulate",Color(1,1,0,1),scan_time * _number_of_scan_attempts * 0.5)
		await get_tree().create_timer(scan_time * _number_of_scan_attempts,false).timeout
		_number_of_scan_attempts -= 1
	
	await get_tree().create_timer(0.5,false).timeout
	
	
	_tracking_bodies = false
	
	var _items:Array[Item] = []
	if has_overlapping_bodies():
			for _item:Item in get_overlapping_bodies():
				_items.append(_item)
				_item.set_outline_glow(Color(20,0,0,1))				
			_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
			_tween.tween_property(self,"modulate",Color(1,0,0,1),scan_time)
			for _body:Item in get_overlapping_bodies():
				print_rich(DEBUG_NAME,"[color=red]Scanning > GOT ONE BAWS")
			#on_scan_end.emit(_items)
	else:
		_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		_tween.tween_property(self,"modulate",Color(0,1,0,1),scan_time)
	
	on_scan_end.emit(_items)
	
	await get_tree().create_timer(1,false).timeout
	
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(self,"modulate",Color(0,0,0,0),2)
	
	for _item:Item in  get_overlapping_bodies():
		_item.set_outline_glow(Color(0.0, 0.0, 0.0, 0.404))
	
	await get_tree().create_timer(2,false).timeout
	
	visible = false
	


func _on_body_entered(body: Node2D) -> void:
	if _tracking_bodies && body is Item:
		body.set_outline_glow(Color(20,20,0,1))

func _on_body_exited(body: Node2D) -> void:
	if body is Item:
		body.set_outline_glow(Color(0.0, 0.0, 0.0, 0.404))
