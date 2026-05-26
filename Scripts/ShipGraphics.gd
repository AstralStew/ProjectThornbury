class_name ShipGraphics extends Node2D


@export var skim_scale = Vector2(0.8,0.8)
@export var boost_scale_adjustment = Vector2(-0.02,0.02)

#var trails : Array[ShipTrail] = []

@onready var ship_shadow: Sprite2D = Ship.instance.get_child(0)
@onready var ship_gfx: Sprite2D = $ShipGfx

var shadow_margin : Vector2

@onready var camera : Camera2D = Ship.instance.find_child("Camera2D")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Ship.on_took_damage().connect(lose_control)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	
	var _camera_pos = camera.get_screen_center_position()
	position = Vector2(360,340) + Ship.instance.global_position - _camera_pos
	#global_position =  ($"../SubViewportContainer" as SubViewportContainer).get_global_transform().affine_inverse() * Ship.instance.global_position
	
	global_rotation = Ship.instance.global_rotation
	var _speed = 0.03 * clamp(remap(abs(Ship.instance.speed.y),10,100,50,100),50,100)
	
	
	
	if Input.is_action_pressed("OpenChute") && Ship.instance.has_control:
		ship_gfx.modulate = ship_gfx.modulate.lerp(Color(1,1,1,0.8),_speed * delta)
		ship_shadow.modulate = ship_shadow.modulate.lerp(Color(0,0,0,0.2),_speed * delta)
		shadow_margin = shadow_margin.lerp(Vector2(1,1.25),_speed * delta)
		ship_shadow.global_position = Ship.instance.global_position + shadow_margin # ship_shadow.global_position.lerp(Ship.instance.global_position + Vector2(1,1.25), 2 * _speed * delta)
		if Input.is_action_pressed("Boost"):
			scale = scale.lerp(skim_scale + boost_scale_adjustment, _speed * delta)
			ship_shadow.scale = ship_shadow.scale.lerp(skim_scale + boost_scale_adjustment, _speed * delta)
		else:
			scale = scale.lerp(skim_scale, _speed * delta)
			ship_shadow.scale = ship_shadow.scale.lerp(skim_scale, _speed * delta)
	else:
		ship_gfx.modulate = ship_gfx.modulate.lerp(Color(1,1,1,1),_speed * delta)
		ship_shadow.modulate = ship_shadow.modulate.lerp(Color(0,0,0,0.1),_speed * delta)
		shadow_margin = shadow_margin.lerp(Vector2(10,14),_speed * delta)
		ship_shadow.global_position = Ship.instance.global_position + shadow_margin #ship_shadow.global_position.lerp(Ship.instance.global_position + Vector2(16,20), 2 * _speed * delta)
		if Input.is_action_pressed("Boost"):
			scale = scale.lerp(Vector2.ONE + boost_scale_adjustment, _speed * delta)
			ship_shadow.scale = ship_shadow.scale.lerp(Vector2.ONE + boost_scale_adjustment, _speed * delta)
		else:
			scale = scale.lerp(Vector2.ONE, _speed * delta)
			ship_shadow.scale = ship_shadow.scale.lerp(Vector2.ONE, _speed * delta)
		
		
	
	if Input.is_action_pressed("Boost") && Ship.instance.has_control:
		ship_gfx.scale = ship_gfx.scale.lerp(Vector2(0.9,1.1), delta * clamp(remap(abs(Ship.instance.speed.y),100,200,0,1),0,1))
	else:
		ship_gfx.scale = ship_gfx.scale.lerp(Vector2.ONE,3 * delta)

var _tween:Tween = null
func lose_control() -> void:
	
	modulate = Color.RED 
	#for _trail in trails: _trail.deactivate()
	
	if _tween: _tween.kill()
	_tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	#_tween.tween_property(self,"rotation",rotation + GLOBALS.random_rotation(50),0.25)
	_tween.tween_property(ship_gfx,"rotation_degrees",ship_gfx.rotation_degrees+360,0.25)
	
	await get_tree().create_timer(0.25).timeout
	ship_gfx.rotation_degrees = 180
	
	#for _trail in trails: _trail.activate()	
	modulate = Color.WHITE
