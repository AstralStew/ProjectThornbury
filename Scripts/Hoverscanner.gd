class_name Hoverscanner extends AnimatableBody2D # Area2D

@export var shadow_distance : float = 5

@export_category("SCANNING")

@export var cooldown_duration : float = 1.0
@export var sight_radius : float = 3.25
@export var cancel_distance_adjust : float = 1.75

@export_category("READ ONLY")
@export var is_scanning : bool = false
@export var is_cancelling : bool = false
@export var is_cooling : bool = false

@onready var _scan_area: Area2D = $ScanArea
@onready var _sight_line: Line2D = $SightLine
@onready var _sight_radius: Panel = $SightRadius
@onready var _collision_shape: CollisionShape2D = $ScanArea/CollisionShape2D
@onready var _hoverscanner_gfx: Sprite2D = $HoverscannerGfx
@onready var _shadow: Sprite2D = $Shadow

var _path_follow : PathFollow2D = null

var _current_scan : Scan = null

func _ready() -> void: 
	
	_path_follow = $".."
	
	_sight_radius.scale = Vector2.ONE * sight_radius
	_collision_shape.scale = Vector2.ONE * sight_radius
	

func _physics_process(delta: float) -> void:
	_shadow.global_position = _hoverscanner_gfx.global_position + Vector2(shadow_distance,shadow_distance)


var _tween : Tween
func start_scan() -> void:
	is_scanning = true
	await get_tree().physics_frame
	_current_scan = InventoryManager.create_new_scan()
	
	_current_scan.on_scan_end.connect(scan_end)
	_current_scan.scanning()
	
	_sight_radius.visible = false
	_sight_line.width = 69
	_sight_line.modulate = Color(1.0, 1.0, 0.5, 0.0)
	_sight_line.self_modulate = Color(1.0, 1.0, 1.0, 0.0)
	_sight_line.visible = true
	
	if _tween: _tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_parallel()
	_tween.tween_property(_sight_line,"self_modulate",Color(1.0, 1.0, 1.0, 1.0),8)
	_tween.tween_property(_sight_line,"width",3,10)
	
	while (is_scanning):
		_sight_line.set_point_position(2,_sight_line.to_local(Ship.instance.global_position))
		_sight_line.set_point_position(1,_sight_line.to_local(lerp(Ship.instance.global_position,global_position,0.5)))
		
		_sight_line.modulate = _current_scan.modulate
		
		if Ship.instance.global_position.distance_squared_to(global_position) > ((sight_radius + cancel_distance_adjust) * 100) * ((sight_radius + cancel_distance_adjust) * 100):
			scan_cancel()
		
		await get_tree().physics_frame


func scan_cancel() -> void:
	is_cancelling = true
	is_scanning = false
	_current_scan.cancelling()
	
	await get_tree().physics_frame
	if _tween: _tween.kill()
	_tween = create_tween().set_parallel()
	_tween.tween_property(_current_scan,"modulate",Color(modulate,0),1)
	_tween.tween_property(_current_scan.audio_stream_player,"volume_db",-60,1)
	_tween.tween_property(_current_scan.audio_stream_player,'pitch_scale',0.5,1)
	_tween.tween_property(_sight_line,"modulate",Color(1.0, 1.0, 0.5, 0.0),1)
	_tween.tween_property(_sight_line,"self_modulate",Color(1.0, 1.0, 1.0, 0),1)
	_tween.tween_property(_sight_line,"width",0,1)
	
	await get_tree().create_timer(1).timeout
	
	_current_scan.queue_free()
	_current_scan = null
	cooldown()
	is_cancelling = false


func scan_end(_found_items:Array[Item]) -> void:
	if _found_items.size() > 0:
		_sight_line.modulate = Color(1.0, 0.0, 0.0, 1.0)
		BountyManager.add_from_scanned_items(_found_items)
		CountdownManager.adjust_from_items(_found_items)
	else: _sight_line.modulate = Color(0.0, 1.0, 0.0, 1.0)
	
	#await get_tree().create_timer(1,false).timeout
	
	_tween = create_tween()
	_tween.tween_property(_sight_line,"modulate", Color(_sight_line.modulate,0),1.5)
	
	await get_tree().create_timer(1.5,false).timeout
	
	_sight_line.visible = false
	
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
	for _body in _scan_area.get_overlapping_bodies():
		_on_body_entered(_body)

func _on_body_entered(body: Node2D) -> void:
	if !is_scanning && !is_cancelling && !is_cooling && body is Ship:
		start_scan()
