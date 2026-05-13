class_name LodController extends Node2D
#
#@export var min_distance : float = 10.0
#@export var max_distance : float = 10.0
#
#@export var time_step_curve : Curve = null
#
#@export_category("READ ONLY")
#
#@export var state : bool = false
#
#var sqr_min_distance : float :
	#get: return distance * distance
#
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta: float) -> void:
	#if state && global_position.distance_squared_to(Ship.instance.global_position) <= sqr_distance:
		#toggle_children(true)
	#
#
#func checking_distance() -> void:
	#var _sqr_distance : float
	#while(true):
		#_sqr_distance = global_position.distance_squared_to(Ship.instance.global_position)
		#if state && _sqr_distance <= sqr_min_distance:
			#pass
		#elif !state && _sqr_distance > sqr_min_distance:
			#pass
		#get_tree().create_timer().timeout
#
#
#func toggle_children(_state:bool) -> void:
	#pass
