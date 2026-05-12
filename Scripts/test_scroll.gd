extends Node2D

@export var ship_acceleration : float = 1.0

@export var speed : float = 300

@export var min_ship_speed : float = 0.5
@export var max_ship_speed : float = 1.0


var ship_speed : float = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if position.y > 4000:
		position.y = -1300
	
	ship_speed = move_toward(ship_speed,Ship.instance.proportional_speed.y,ship_acceleration * delta)
	
	position.y += remap(ship_speed,-1,1,min_ship_speed,max_ship_speed) * speed * delta
