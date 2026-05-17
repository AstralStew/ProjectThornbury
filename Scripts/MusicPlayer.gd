extends AudioStreamPlayer



func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	autoplay = true
	volume_linear = 0.5
	stream = preload("res://Assets/Audio/Music/845153__glorytothemachine__unkown_entity-113bpm-melodic_data_stream-seamless-loop-glorytothemachine.mp3")

var _tween : Tween
func fade(target:float,duration:float = 3.0)-> void:
	if _tween: _tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR).set_parallel()
	_tween.tween_property(self,"volume_linear",target,duration)


func fade_in(duration:float = 3.0) -> void:
	fade(0.5,duration)

func fade_out(duration:float = 3.0) -> void:
	fade(0,duration)
