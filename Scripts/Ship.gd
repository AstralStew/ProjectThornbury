class_name Ship extends CharacterBody2D
static var instance : Ship = null

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
			speed.x / left_speed if speed.x < 0 else speed.x / right_speed,
			speed.y / down_speed if speed.y < 0 else speed.y / up_speed
		)

func _enter_tree() -> void:
	instance = self

func _physics_process(delta: float) -> void:
	
	var _new_x_speed : float
	var _new_y_speed : float
	
	if Input.is_action_pressed("MoveLeft"):
		_new_x_speed = move_toward(speed.x,-left_speed, change_rate)
	elif Input.is_action_pressed("MoveRight"):
		_new_x_speed = move_toward(speed.x,right_speed, change_rate)
	else:
		_new_x_speed = move_toward(speed.x,0, change_rate * 2)
	
	if Input.is_action_pressed("MoveUp"):
		_new_y_speed = move_toward(speed.y, down_speed, change_rate)
	elif Input.is_action_pressed("MoveDown"):
		_new_y_speed = move_toward(speed.y, -up_speed, change_rate)
	else:
		_new_y_speed = move_toward(speed.y,0, change_rate * 2)
	
	speed = Vector2(_new_x_speed,_new_y_speed)
	
	velocity = speed
	
	move_and_slide()
