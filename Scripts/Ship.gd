class_name Ship extends CharacterBody2D
static var instance : Ship = null

@export_category("Ast Controls")

@export var rotation_speed : float = 0.25
@export var rotation_change_rate : float = 50.0
@export var rotation_acc : float = 0.1

@export_category("TD Controls")

@export var up_change_rate : float = 1.0
@export var down_change_rate : float = 1.0
@export var neutral_change_rate : float = 1.0
@export var up_speed : float = 1.0
@export var down_speed : float = 1.0

@export_category("READ ONLY")

@export var speed : Vector2 = Vector2.ZERO
@export var proportional_speed : Vector2 = Vector2.ZERO :
	get:
		return Vector2(
			1 if Input.is_action_pressed("MoveLeft") else -1 if Input.is_action_pressed("MoveRight") else 0,
			1 if (Input.is_action_pressed("MoveUp")) else -1 if (Input.is_action_pressed("MoveDown")) else 0,
		)
		#return Vector2(
			#speed.x / left_speed if speed.x < 0 else speed.x / right_speed,
			#speed.y / down_speed if speed.y < 0 else speed.y / up_speed
		#)

func _enter_tree() -> void:
	instance = self

func _physics_process(delta: float) -> void:
	
	get_input(delta)
	rotation = lerp_angle(rotation, rotation + deg_to_rad(speed.x), rotation_acc)
	velocity = speed.y * transform.y
	
	move_and_slide()


func get_input(delta: float) -> void:
	var _target_rotation : float
	var _new_speed : float
	
	if Input.is_action_pressed("MoveLeft"):
		_target_rotation = move_toward(speed.x, -rotation_speed,rotation_change_rate * delta)
	elif Input.is_action_pressed("MoveRight"):
		_target_rotation = move_toward(speed.x, rotation_speed,rotation_change_rate * delta)
	else:
		_target_rotation = move_toward(speed.x, 0, rotation_change_rate * delta)
	
	if Input.is_action_pressed("MoveDown"):
		_new_speed = move_toward(speed.y, -down_speed, down_change_rate  * delta)
	elif Input.is_action_pressed("MoveUp"):
		_new_speed = move_toward(speed.y, -up_speed, up_change_rate * delta)
	else:
		_new_speed = move_toward(speed.y,-down_speed, neutral_change_rate * delta)
	
	speed = Vector2(_target_rotation,_new_speed)
	
	#speed = Vector2(0,_new_speed)

#
#func td_input() -> void:
	#var _new_x_speed : float
	#var _new_y_speed : float
	#
	#if Input.is_action_pressed("MoveLeft"):
		#_new_x_speed = move_toward(speed.x,-left_speed, change_rate)
	#elif Input.is_action_pressed("MoveRight"):
		#_new_x_speed = move_toward(speed.x,right_speed, change_rate)
	#else:
		#_new_x_speed = move_toward(speed.x,0, change_rate * 2)
	#
	#if Input.is_action_pressed("MoveUp"):
		#_new_y_speed = move_toward(speed.y, down_speed, change_rate)
	#elif Input.is_action_pressed("MoveDown"):
		#_new_y_speed = move_toward(speed.y, -up_speed, change_rate)
	#else:
		#_new_y_speed = move_toward(speed.y,0, change_rate * 2)
	#
	#speed = Vector2(_new_x_speed,_new_y_speed)
	#
	
