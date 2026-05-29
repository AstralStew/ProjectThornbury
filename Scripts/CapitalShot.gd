class_name CapitalShot extends Sprite2D
const DEBUG_NAME = "[b][CapitalShot][/b] "
static var instance : CapitalShot = null

@onready var circles: Node2D = $Circles
@onready var warning: Sprite2D = $Warning
@onready var explosion: Sprite2D = $Explosion
@onready var dot: Sprite2D = $Dot

@onready var explosion_audio_player: AudioStreamPlayer = $ExplosionAudioPlayer
@onready var warning_audio_player: AudioStreamPlayer = $WarningAudioPlayer





@onready var duration: float = 7

func _enter_tree() -> void:
	instance = self

var firing : bool = false

var tween_lerp : float = 0
var _tween : Tween


static func fire() -> void:
	instance._fire()
func _fire() -> void:
	if firing: return
	firing = true
	
	visible = true
	var _target = $"../ShipGfx"
	
	global_position = _target.global_position + GLOBALS.random_vector2_normalised(300)
	var start_pos = global_position
	_tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	_tween.tween_property(circles,"modulate",Color(Color.WHITE,0.45),duration)
	_tween.tween_property(self,"modulate",Color(Color.WHITE),duration)
	_tween.tween_property(self,"tween_lerp",1,duration)
	_tween.tween_callback(explosion_audio_player.play).set_delay(2.45) #1.8
	#_tween.tween_callback(warning.set.bind("visible",false)).set_delay(5) 
	#_tween.tween_callback(dot.set.bind("visible",false)).set_delay(5) 
	#_tween.tween_callback(circles.set.bind("visible",false)).set_delay(5) 
	#_tween.tween_property(self,"global_position",Vector2(360,320),duration)
	
	flashing()
	while (_tween.is_running()):
		global_position = start_pos.lerp(_target.global_position,tween_lerp)
		await get_tree().process_frame
	firing = false
	await get_tree().process_frame
	circles.visible = false
	warning.visible = false
	dot.visible = false
	
	await get_tree().create_timer(0.25,false).timeout
	
	#Ship.on_took_damage().emit()
	
	explosion.scale = Vector2.ONE * 0.45
	if _tween: _tween.kill()
	_tween = create_tween().set_parallel()
	_tween.tween_property(explosion,"scale",Vector2(0.01,0.01),1.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_tween.tween_property(OutsideManager.instance.get_child(0),"modulate",Color(2.0, 1.916, 1.435, 1.0),0.15).set_delay(0.85).set_ease(Tween.EASE_IN)
	_tween.tween_property(InventoryManager.instance.get_child(0),"modulate",Color(2.0, 1.916, 1.435, 1.0),0.15).set_delay(0.85).set_ease(Tween.EASE_IN)
	_tween.tween_property(OutsideManager.instance.get_child(0),"modulate",Color(1,1,1,1),0.15).set_delay(1.0).set_ease(Tween.EASE_OUT)
	_tween.tween_property(InventoryManager.instance.get_child(0),"modulate",Color(1,1,1,1),0.15).set_delay(1.0).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(0.7,false).timeout
	Ship.on_took_damage().emit()
	await get_tree().create_timer(0.45,false).timeout
	circles.visible = false
	
	
	if _tween: _tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT).set_parallel()
	_tween.tween_property(explosion,"scale",Vector2(20,20),2.5)
	_tween.tween_property(explosion,"rotation",560,3)
	_tween.tween_property(explosion.get_child(1),"modulate",Color(Color.WHITE,0),1.5)
	_tween.tween_property(OutsideManager.instance.get_child(0),"modulate",Color(10,10,10,1),3)
	_tween.tween_property(InventoryManager.instance.get_child(0),"modulate",Color(10,10,10,1),3)
	_tween.tween_callback(fired).set_delay(3.5)
	
	while (_tween.is_running()):
		Ship.on_took_damage().emit()
		await get_tree().create_timer(0.2,false).timeout
	


func flashing() -> void:
	var _time = duration/14
	var _volume_db = -30
	while (firing):
		warning.visible = !warning.visible
		if warning.visible:
			warning_audio_player.volume_db = _volume_db
			warning_audio_player.play()
		else:
			warning.scale = warning.scale.lerp(Vector2.ONE * 1.3,0.2)
			warning_audio_player.stop()
			_volume_db *= 0.95
		await get_tree().create_timer(_time,false).timeout
		_time *= 0.95

	

func fired() -> void:
	UIManager.instance.lose()
