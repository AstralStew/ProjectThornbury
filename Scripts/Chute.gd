class_name Chute extends Area2D
const DEBUG_NAME = "[b][Chute][/b] "
static var instance : Chute = null

@onready var hanger_door_left : Sprite2D = $HangerDoorLeft
@onready var hanger_door_right : Sprite2D = $HangerDoorRight
@onready var entrance_point : Marker2D = $EntrancePoint
@onready var exit_point : Marker2D = $ExitPoint
@onready var shadow : Sprite2D = $"../Shadow"
@onready var doors_audio_player: AudioStreamPlayer = $DoorsAudioPlayer



var _open := false

func _enter_tree() -> void:
	instance = self

var _tween : Tween
func open() -> void:
	#chute_gfx.color = Color(0.933, 0.525, 0.584)
	if _tween: _tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD).set_parallel()
	_tween.tween_property(hanger_door_left,"position",Vector2(-105,0),0.25)
	_tween.tween_property(hanger_door_right,"position",Vector2(105,0),0.25)
	_tween.tween_property(shadow,"self_modulate",Color(1,1,1,0),0.25)
	_tween.tween_callback(open_audio).set_delay(0.025)

func open_audio() -> void:
	if doors_audio_player.playing: doors_audio_player.stop()
	doors_audio_player.pitch_scale = 10.0
	doors_audio_player.play()

func close() -> void:
	#chute_gfx.color = Color(0.2, 0.2, 0.2)
	if _tween: _tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD).set_parallel()
	_tween.tween_property(hanger_door_left,"position",Vector2(-33,0),0.25)
	_tween.tween_property(hanger_door_right,"position",Vector2(33,0),0.25)
	_tween.tween_property(shadow,"self_modulate",Color(1,1,1,0.75),0.25)
	
	if doors_audio_player.playing: doors_audio_player.stop()
	doors_audio_player.pitch_scale = 7
	doors_audio_player.play()

func _physics_process(delta: float) -> void:
	if InventoryManager.chute_open:
		if !_open:
			_open = true
			open()
		if has_overlapping_bodies():
			for _body:Item in get_overlapping_bodies():
				if _body.finished_spawning && !_body.is_dragged:
					_body.jettison()
					var _audio = RandomAudioPlayer.new(preload("res://Configs/Audio_Inventory_ItemOutgoing.tres"),1,0)
					add_child(_audio)
	elif _open:
		_open = false
		close()

 
#
#func _on_body_entered(body: Node2D) -> void:
	#if is_open:
		#body.queue_free()
