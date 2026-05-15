class_name Ship extends CharacterBody2D
const DEBUG_NAME = "[b][Ship][/b] "
static var instance : Ship = null




static var SHIP_ROTATION_SPEED : float = 30.0
static var SHIP_ROTATION_CHANGE_RATE : float = 50.0
static var SHIP_BOOST_ROTATION_CHANGE_RATE : float = 100.0
static var SHIP_ROTATION_ACC : float = 0.05

#@EXPORT_CATEGORY("SPEED CONTROLS")

static var SHIP_FORWARD_SPEED : float = 100.0
static var SHIP_FORWARD_CHANGE_RATE : float = 100.0
static var SHIP_BACK_SPEED : float = 10.0
static var SHIP_BACK_CHANGE_RATE : float = 100.0
static var SHIP_NEUTRAL_CHANGE_RATE : float = 30.0
static var SHIP_BOOST_SPEED : float = 200.0
static var SHIP_BOOST_CHANGE_RATE : float = 100.0










@export_category("READ ONLY")

@export var previous_speed : Vector2 = Vector2.ZERO
@export var speed : Vector2 = Vector2.ZERO

@export var acceleration: Vector2 = Vector2.ZERO :
	get:
		return previous_speed - speed

@export var proportional_speed : Vector2 = Vector2.ZERO :
	get:
		return Vector2(
			1 if Input.is_action_pressed("MoveLeft") else -1 if Input.is_action_pressed("MoveRight") else 0,
			1 if (Input.is_action_pressed("MoveUp")) else -1 if (Input.is_action_pressed("MoveDown")) else 0,
		)

var trails : Array[ShipTrail] = []

func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	for _child:ShipTrail in find_children("","ShipTrail"):
		trails.append(_child)

func _physics_process(delta: float) -> void:
	previous_speed = speed
	
	if has_control:
		get_input(delta)
		rotation = lerp_angle(rotation, rotation + deg_to_rad(speed.x), GLOBALS.SHIP_ROTATION_ACCELERATION)
	else:
		speed = Vector2(0,move_toward(speed.y,-GLOBALS.SHIP_BACK_SPEED, GLOBALS.SHIP_BACK_CHANGE_RATE * 0.5 * delta))
	velocity = speed.y * transform.y
	
	
	var collision = move_and_collide(velocity * delta)
	if collision && has_control && speed.y < -GLOBALS.SHIP_MINIMUM_BOUNCE_SPEED:
		velocity = velocity.bounce(collision.get_normal())
		speed.x = 0
		speed.y = speed.y * 0.69
		
		rotation = collision.get_normal().angle() + deg_to_rad(90) + GLOBALS.random_rotation(30)
		take_damage()



func take_damage() -> void:
	print_rich(DEBUG_NAME,"TakeDamage > Reducing health and losing control!")
	GLOBALS.health -= 1
	lose_control()

var has_control := true
var _tween:Tween = null
func lose_control() -> void:
	has_control = false
	modulate = Color.RED
	for _trail in trails: _trail.deactivate()
	if _tween: _tween.kill()
	_tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	_tween.tween_property(self,"rotation",rotation + GLOBALS.random_rotation(50),0.25)
	_tween.tween_property($ShipsSheet,"rotation_degrees",$ShipsSheet.rotation_degrees+360,0.25)
	
	if UIManager.instance != null: UIManager.instance.jolt()
	if Boot.instance != null: Boot.instance.jolt()
	
	await get_tree().create_timer(0.25).timeout
	$ShipsSheet.rotation_degrees = 180
	for _trail in trails: _trail.activate()
	modulate = Color.WHITE
	has_control = true

func get_input(delta: float) -> void:
	var _target_rotation : float
	var _new_speed : float
	
	if Input.is_action_pressed("Boost"):
		_target_rotation = move_toward(speed.x, 0, GLOBALS.SHIP_BOOST_ROTATION_CHANGE_RATE * delta)
		_new_speed = move_toward(speed.y, -GLOBALS.SHIP_BOOST_SPEED, GLOBALS.SHIP_BOOST_CHANGE_RATE  * delta)
	else:
		if Input.is_action_pressed("MoveLeft"):
			_target_rotation = move_toward(speed.x, -GLOBALS.SHIP_ROTATION_SPEED, GLOBALS.SHIP_ROTATION_CHANGE_RATE * delta)
		elif Input.is_action_pressed("MoveRight"):
			_target_rotation = move_toward(speed.x, GLOBALS.SHIP_ROTATION_SPEED, GLOBALS.SHIP_ROTATION_CHANGE_RATE * delta)
		else:
			_target_rotation = move_toward(speed.x, 0, GLOBALS.SHIP_ROTATION_CHANGE_RATE * delta)
		
		if Input.is_action_pressed("MoveDown"):
			_new_speed = move_toward(speed.y, -GLOBALS.SHIP_BACK_SPEED, GLOBALS.SHIP_BACK_CHANGE_RATE * delta)
		elif Input.is_action_pressed("MoveUp"):
			_new_speed = move_toward(speed.y, -GLOBALS.SHIP_FORWARD_SPEED, GLOBALS.SHIP_FORWARD_CHANGE_RATE * delta)
		else:
			_new_speed = move_toward(speed.y,-GLOBALS.SHIP_BACK_SPEED, GLOBALS.SHIP_NEUTRAL_CHANGE_RATE * delta)
	
	speed = Vector2(_target_rotation,_new_speed)
	
