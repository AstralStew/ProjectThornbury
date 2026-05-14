class_name GameConfig extends Resource

@export_category("SHIP STATS")

@export var SHIP_MAX_HEALTH : int = 10
@export var SHIP_MINIMUM_BOUNCE_SPEED : float = 65

@export_category("SHIP TURNING CONTROLS")

@export var SHIP_ROTATION_SPEED : float = 30.0
@export var SHIP_ROTATION_CHANGE_RATE : float = 50.0
@export var SHIP_BOOST_ROTATION_CHANGE_RATE : float = 100.0
@export var SHIP_ROTATION_ACCELERATION : float = 0.05

@export_category("SHIP SPEED CONTROLS")

@export var SHIP_FORWARD_SPEED : float = 100.0
@export var SHIP_FORWARD_CHANGE_RATE : float = 100.0
@export var SHIP_BACK_SPEED : float = 10.0
@export var SHIP_BACK_CHANGE_RATE : float = 100.0
@export var SHIP_NEUTRAL_CHANGE_RATE : float = 30.0
@export var SHIP_BOOST_SPEED : float = 200.0
@export var SHIP_BOOST_CHANGE_RATE : float = 100.0
