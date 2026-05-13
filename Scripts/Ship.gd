class_name Ship extends CharacterBody2D
static var instance : Ship = null

@export_category("Turning Controls")

@export var rotation_speed : float = 0.25
@export var rotation_change_rate : float = 50.0
@export var boost_rotation_change_rate : float = 100.0


@export var rotation_acc : float = 0.1

@export_category("Speed Controls")

@export var up_change_rate : float = 1.0
@export var down_change_rate : float = 1.0
@export var neutral_change_rate : float = 1.0
@export var up_speed : float = 1.0
@export var down_speed : float = 1.0

@export var boost_speed : float = 100.0
@export var boost_change_rate : float = 100.0

@export_category("READ ONLY")

@export var previous_speed : Vector2 = Vector2.ZERO
@export var speed : Vector2 = Vector2.ZERO

@export var acceleration: Vector2 = Vector2.ZERO :
	get:
		#print("acceleration" + str(previous_speed - speed))
		return previous_speed - speed

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

var trails : Array[ShipTrail] = []

func _enter_tree() -> void:
	instance = self
#
#func _ready() -> void:
	#for _child:ShipTrail in find_children("","ShipTrail"):

func _physics_process(delta: float) -> void:
	previous_speed = speed
	
	if has_control:
		get_input(delta)
		rotation = lerp_angle(rotation, rotation + deg_to_rad(speed.x), rotation_acc)
	else:
		speed = Vector2(0,move_toward(speed.y,-down_speed, neutral_change_rate * delta))
	velocity = speed.y * transform.y
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		speed.x = 0
		speed.y = speed.y /2 
		
		#rotation = lerp_angle(rotation, collision.get + GLOBALS.random_rotation(15), rotation_acc)
		#look_at(velocity)
		rotation = collision.get_normal().angle() + deg_to_rad(90) + GLOBALS.random_rotation(30)
		lose_control()
		#if collision.get_collider().has_method("hit"):
			#collision.get_collider().hit()

	
	#move_and_slide()

var has_control := true
func lose_control() -> void:
	has_control = false
	modulate = Color.RED
	$ShipsSheet/Trails.visible = false
	await get_tree().create_timer(0.25).timeout
	$ShipsSheet/Trails.visible = true
	modulate = Color.WHITE
	has_control = true

func get_input(delta: float) -> void:
	var _target_rotation : float
	var _new_speed : float
	
	if Input.is_action_pressed("Boost"):
		_target_rotation = move_toward(speed.x, 0, boost_rotation_change_rate * delta)
		_new_speed = move_toward(speed.y, -boost_speed, boost_change_rate  * delta)
	else:
		if Input.is_action_pressed("MoveLeft"):
			_target_rotation = move_toward(speed.x, -rotation_speed, rotation_change_rate * delta)
		elif Input.is_action_pressed("MoveRight"):
			_target_rotation = move_toward(speed.x, rotation_speed, rotation_change_rate * delta)
		else:
			_target_rotation = move_toward(speed.x, 0, rotation_change_rate * delta)
		
		if Input.is_action_pressed("MoveDown"):
			_new_speed = move_toward(speed.y, -down_speed, down_change_rate * delta)
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
	
