class_name RandomAudioPlayer extends AudioStreamPlayer

var config : AudioSequence

var pitch_adjustment : float
var volume_adjustment : float


func _init(_config:AudioSequence,_pitch_adjustment := 0.0, _volume_adjustment := 0.0) -> void:
	config = _config
	pitch_adjustment = _pitch_adjustment
	volume_adjustment = _volume_adjustment

func _ready() -> void:
	
	var _sound = config.times.pick_random()
	
	if config.random_pitch_semitones != 0.0 || config.random_volume_offset != 0.0:
		var _randomizer = AudioStreamRandomizer.new()
		_randomizer.add_stream(0,config.stream,1.0)
		if config.random_pitch_semitones != 0.0:
			_randomizer.random_pitch_semitones = config.random_pitch_semitones
		if config.random_volume_offset != 0.0:
			_randomizer.random_volume_offset = config.random_volume_offset
		stream = _randomizer
	else:
		stream = config.stream
	
	pitch_scale = pitch_adjustment * config.pitch_adjustment
	volume_db += volume_adjustment + config.volume_adjustment
	
	play(_sound.x)
	await get_tree().process_frame
	while get_playback_position() + AudioServer.get_time_since_last_mix() < _sound.y:
		await get_tree().process_frame
	stop()
	
	queue_free()
#
#func _process(delta: float) -> void:
	#if playing && get_playback_position() + AudioServer.get_time_since_last_mix() > sound_y
	#await get_tree().create_timer(_sound.y - _sound.x,).timeout
	#
