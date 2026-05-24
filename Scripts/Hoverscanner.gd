class_name Hoverscanner extends Area2D

@export var cooldown_duration : float = 1.0
@export var sight_radius : float = 3.25

@export_category("READ ONLY")
@export var is_scanning : bool = false
@export var is_cooling : bool = false

var _line : Line2D = null
var _path_follow : PathFollow2D = null
var _sight_radius : Panel = null
var _collision_shape : CollisionShape2D = null

func _ready() -> void: 
	
	_line = $SightLine
	_path_follow = $".."
	_sight_radius = $SightRadius
	_collision_shape = $CollisionShape2D
	
	_sight_radius.scale = Vector2.ONE * sight_radius
	_collision_shape.scale = Vector2.ONE * sight_radius
	


var _tween : Tween
func start_scan() -> void:
	is_scanning = true
	await get_tree().physics_frame
	var _new_scan : Scan = InventoryManager.create_new_scan()
	
	_new_scan.on_scan_end.connect(scan_end)
	_new_scan.scanning()
	
	_sight_radius.visible = false
	_line.width = 69
	_line.modulate = Color(1.0, 1.0, 0.5, 0.0)
	_line.self_modulate = Color(1.0, 1.0, 1.0, 0.0)
	_line.visible = true
	
	if _tween: _tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_parallel()
	_tween.tween_property(_line,"self_modulate",Color(1.0, 1.0, 1.0, 1.0),8)
	_tween.tween_property(_line,"width",3,10)
	
	while (is_scanning):
		_line.set_point_position(2,_line.to_local(Ship.instance.global_position))
		_line.set_point_position(1,_line.to_local(lerp(Ship.instance.global_position,global_position,0.5)))
		
		_line.modulate = _new_scan.modulate
		
		await get_tree().physics_frame

func scan_end(_found_items:Array[Item]) -> void:
	if _found_items.size() > 0:
		_line.modulate = Color(1.0, 0.0, 0.0, 1.0)
		BountyManager.add_from_scanned_items(_found_items)
		CountdownManager.adjust_from_items(_found_items)
	else: _line.modulate = Color(0.0, 1.0, 0.0, 1.0)
	
	#await get_tree().create_timer(1,false).timeout
	
	_tween = create_tween()
	_tween.tween_property(_line,"modulate", Color(_line.modulate,0),1.5)
	
	await get_tree().create_timer(1.5,false).timeout
	
	_line.visible = false
	
	cooldown()
	is_scanning = false

func cooldown() -> void:
	is_cooling = true
	_sight_radius.scale = Vector2.ZERO
	_sight_radius.visible = true
	
	if _tween: _tween.kill()
	_tween = create_tween()
	_tween.tween_property(_sight_radius,"scale", Vector2.ONE * sight_radius,cooldown_duration)
	await get_tree().create_timer(cooldown_duration,false).timeout
	
	is_cooling = false
	for _body in get_overlapping_bodies():
		_on_body_entered(_body)

func _on_body_entered(body: Node2D) -> void:
	if !is_scanning && !is_cooling && body is Ship:
		start_scan()
