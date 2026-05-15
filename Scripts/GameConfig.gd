class_name GameConfig extends Resource

@export_category("LEFT SCREEN")

@export_group("LEVEL OPTIONS")
## How many seconds before the authorities arrive (i.e. game over via time)
@export var LEVEL_SECS_BEFORE_AUTHORITIES_ARRIVE : int = 600

@export_group("SHIP STATS")
## How many hits the ship can take before its game over 
@export var SHIP_MAX_HEALTH : int = 10
## The minimum velocity the player is travelling before taking damage from hitting an obstacles 
@export var SHIP_MINIMUM_BOUNCE_SPEED : float = 65

@export_group("SHIP TURNING CONTROLS")

## The maximum rotation speed the ship can take at 
@export var SHIP_ROTATION_SPEED : float = 30.0
## How quickly the target rotation changes as you hold the left/right button down 
@export var SHIP_ROTATION_CHANGE_RATE : float = 50.0
## How quickly the target rotation changes while boosting as you hold the left/right button down
@export var SHIP_BOOST_ROTATION_CHANGE_RATE : float = 100.0
## How quickly the ship rotates towards the target rotation 
@export var SHIP_ROTATION_ACCELERATION : float = 0.05

@export_group("SHIP SPEED CONTROLS")

## The maximum speed the ship moves when holding Up
@export var SHIP_FORWARD_SPEED : float = 100.0
## How quickly the speed transitions to the max speed as you hold Forward 
@export var SHIP_FORWARD_CHANGE_RATE : float = 100.0
## The minimum speed the ship moves when holding Back
@export var SHIP_BACK_SPEED : float = 10.0
## How quickly the speed transitions to the min speed as you hold Back
@export var SHIP_BACK_CHANGE_RATE : float = 100.0
## How quickly the target speed transitions to min speed when holding nothing
@export var SHIP_NEUTRAL_CHANGE_RATE : float = 30.0
## The speed the ship moves when holding Boost 
@export var SHIP_BOOST_SPEED : float = 200.0
## How quickly the target speed transitions as you hold Boost 
@export var SHIP_BOOST_CHANGE_RATE : float = 100.0





@export_category("RIGHT SCREEN")

@export_group("CHUTE")

## Chance (0.0 > 1.0) to open the chute when the ship takes damage
@export var INVENTORY_CHANCE_TO_OPEN_ON_DAMAGE : float = 0.5

@export_group("ALL ITEMS")
## How far an item can be from where you clicked and still get grabbed
@export var INVENTORY_MINIMUM_GRAB_DISTANCE : float = 100
## Amount of force the ship movement exerts on items
@export var INVENTORY_SHIP_FORCE : Vector2  = Vector2(1.5,1.5)
## Amount of force exerted on items in small random directions at all times
@export var INVENTORY_RANDOM_FORCE : float = 0.25
## Amount of force exerted on items when the ship is jolted by hitting something
@export var INVENTORY_JOLT_FORCE : float  = 200.0
## How quickly the jolt force aubsides after hitting something
@export var INVENTORY_JOLT_FORCE_REDUCTION : float  = 1000.0
## Amount of force exerted on items in direction of mouse when being dragged
@export var INVENTORY_DRAG_FORCE : float  = 2.5
## Amount of force exerted on items in direction of mouse when released
@export var INVENTORY_RELEASE_FORCE : float  = 0.5

@export_group("ROCK ITEM")
## How heavy the item is in kilograms
@export var ROCK_MASS : float = 1.0
## How much the item is affected by the forces (1.0 = 100%)
@export var ROCK_FORCE_SCALE : float = 1.0
## How much more the item's movement is reduced over time to bring it to a stop (on top of the 0.5 that all items have by default)
@export var ROCK_EXTRA_MOVE_DRAG : float = 0.0
## How much more the item's rotation is reduced over time to bring it to a stop (on top of the 1.0 that all items have by default)
@export var ROCK_EXTRA_ROTATION_DRAG : float = 0.0

@export_group("CRATE ITEM")
## How heavy the item is in kilograms
@export var CRATE_MASS : float = 2.0
## How much the item is affected by the forces (1.0 = 100%)
@export var CRATE_FORCE_SCALE : float = 0.69
## How much more the item's movement is reduced over time to bring it to a stop (on top of the 0.5 that all items have by default)
@export var CRATE_EXTRA_MOVE_DRAG : float = 0.05
## How much more the item's rotation is reduced over time to bring it to a stop (on top of the 1.0 that all items have by default)
@export var CRATE_EXTRA_ROTATION_DRAG : float = 0.0

@export_group("PIPE ITEM")
## How heavy the item is in kilograms
@export var PIPE_MASS : float = 0.5
## How much the item is affected by the forces (1.0 = 100%)
@export var PIPE_FORCE_SCALE : float = 1.0
## How much more the item's movement is reduced over time to bring it to a stop (on top of the 0.5 that all items have by default)
@export var PIPE_EXTRA_MOVE_DRAG : float = 0.05
## How much more the item's rotation is reduced over time to bring it to a stop (on top of the 1.0 that all items have by default)
@export var PIPE_EXTRA_ROTATION_DRAG : float = 0.0

@export_group("CAMERA SETTINGS")
## How much the inventory camera rotates in the direction the ship is flying
@export var INVENTORY_CAMERA_TILT_STRENGTH : float = 25.0
## How quickly the inventory camera rotates in the direction the ship is flying
@export var INVENTORY_CAMERA_TILT_SPEED : float = 0.5
## How much the inventory camera moves in the direction the ship is flying
@export var INVENTORY_CAMERA_PAN_STRENGTH : Vector2 = Vector2(0.25,5)
## How quickly the inventory camera moves in the direction the ship is flying
@export var INVENTORY_CAMERA_PAN_SPEED : float = 1.0
