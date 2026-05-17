class_name AudioSequence extends Resource

@export var stream : AudioStream = null
@export var times : Array[Vector2] = []

@export var pitch_adjustment : float = 0.0
@export var volume_adjustment : float = 0.0

@export var random_pitch_semitones : float = 0.0
@export var random_volume_offset : float = 0.0

#
#
#func pick_random() -> Vector2:
	#return times.pick_random()
