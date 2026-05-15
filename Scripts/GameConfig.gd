class_name GameConfig extends Resource

@export_category("PLAYER SHIP")

@export_group("STATS")
## How many hits the ship can take before its game over (pinky default = 10)
@export var SHIP_MAX_HEALTH : int = 10
## The minimum velocity the player is travelling before taking damage from hitting an obstacles (pinky default = 65)
@export var SHIP_MINIMUM_BOUNCE_SPEED : float = 65

@export_group("TURNING CONTROLS")

## The maximum rotation speed the ship can take at (pinky default = 30)
@export var SHIP_ROTATION_SPEED : float = 30.0
## How quickly the target rotation changes as you hold the left/right button down (pinky default = 50)
@export var SHIP_ROTATION_CHANGE_RATE : float = 50.0
## How quickly the target rotation changes while boosting as you hold the left/right button down (pinky default = 50)
@export var SHIP_BOOST_ROTATION_CHANGE_RATE : float = 100.0
## How quickly the ship rotates towards the target rotation (pinky default = 0.05)
@export var SHIP_ROTATION_ACCELERATION : float = 0.05

@export_group("SPEED CONTROLS")

## The maximum speed the ship moves when holding Up (pinky default = 100)
@export var SHIP_FORWARD_SPEED : float = 100.0
## How quickly the speed transitions to the max speed as you hold Forward (pinky default = 100)
@export var SHIP_FORWARD_CHANGE_RATE : float = 100.0
## The minimum speed the ship moves when holding Back (pinky default = 10)
@export var SHIP_BACK_SPEED : float = 10.0
## How quickly the speed transitions to the min speed as you hold Back (pinky default = 100)
@export var SHIP_BACK_CHANGE_RATE : float = 100.0
## How quickly the target speed transitions to min speed when holding nothing (pinky default = 30)
@export var SHIP_NEUTRAL_CHANGE_RATE : float = 30.0
## The speed the ship moves when holding Boost (pinky default = 200)
@export var SHIP_BOOST_SPEED : float = 200.0
## How quickly the target speed transitions as you hold Boost (pinky default = 100)
@export var SHIP_BOOST_CHANGE_RATE : float = 100.0
