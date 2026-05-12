class_name Ship extends CharacterBody2D
static var instance : Ship = null

@export_category("Ast Controls")

@export var rotation_speed : float = 0.25
@export var rotation_acc : float = 0.1

@export_category("TD Controls")

@export var change_rate : float = 1.0

@export var left_speed : float = 1.0
@export var right_speed : float = 1.0
@export var up_speed : float = 1.0
@export var down_speed : float = 1.0

@export_category("READ ONLY")

@export var speed : Vector2 = Vector2.ZERO
@export var proportional_speed : Vector2 = Vector2.ZERO :
	get:
		return Vector2(
			1 if Input.is_action_pressed("MoveLeft") else -1 if Input.is_action_pressed("MoveRight") else 0,
			1 if (Input.is_action_pressed("MoveUp") && speed.y > -50) else -1 if (Input.is_action_pressed("MoveDown") && speed.y < 0) else 0,
		)
		#return Vector2(
			#speed.x / left_speed if speed.x < 0 else speed.x / right_speed,
			#speed.y / down_speed if speed.y < 0 else speed.y / up_speed
		#)

func _enter_tree() -> void:
	instance = self

func _physics_process(delta: float) -> void:
	
	get_input()
	rotation = speed.x
	velocity = speed.y * transform.y
	
	move_and_slide()


func get_input() -> void:
	var _new_rotation : float
	var _new_speed : float
	
	if Input.is_action_pressed("MoveLeft"):
		_new_rotation = rotate_toward(speed.x,speed.x-(rotation_speed * 0.1),rotation_acc)
	elif Input.is_action_pressed("MoveRight"):
		_new_rotation = rotate_toward(speed.x,speed.x+(rotation_speed * 0.1),rotation_acc)
	else:
		_new_rotation = speed.x
	
	if Input.is_action_pressed("MoveDown"):
		_new_speed = min(0,move_toward(speed.y, down_speed * 50, change_rate * 0.5))
	elif Input.is_action_pressed("MoveUp"):
		_new_speed = min(0,move_toward(speed.y, -up_speed * 50, change_rate * 0.2))
	else:
		_new_speed = speed.y # move_toward(speed.y,0, change_rate * 2)
	
	speed = Vector2(_new_rotation,_new_speed)
	
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
	
