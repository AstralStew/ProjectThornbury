class_name NotificationManager extends Node

@onready var notification_prefab : PackedScene = preload("res://Scenes/OutsidePrefabs/notification.tscn")



@export var order_flavour_options : Array[String] = [
	"The old planet is dying; a new one struggles to be born.",
	"We stand for the pink, white, and blue around these parts.",
	"Those who bring us tools of our own - that is true aid.",
	"From each to their ability; to each an even bounty!",
	"Community or barbarism - there is no other choice.",
	"They say to 'get ahead'... of whom? Our neighbours?",
	"People of the stars unite! We lose nothing but our chains!",
	"We must throw our bodies upon the gears of this machine.",
]

@export var order_options : Array[String] = [
	"Whoever recieves this, we urgently require %s for repairs.",
	"Mutual aid request: %s to fix our water filtration system.",
	"In such times, we humbly request a delivery of %s!",
	"Even %s would help get us back in the green.",
	"%s would let us take the fight upwards!",
	"We will need %s before the Capital ship arrives.",
]

@export var button_options : Array[String] = [
	"Alrighty",
	"Cool beans",
	"No worries",
	"Can do",
	"Yea sick",
	"Affirmative",
	"Nah yeah",
	"Of course",
	"As you wish",
	"Should work",
	"On my way",
	"Say no more",
	"I got you",
	"Let's go",
]



static var local_order_flavour_options : Array[String] = []

static var local_order_options : Array[String] = []

static var local_button_options : Array[String] = []

var portraits : Array[Texture2D] = []




func _ready() -> void:
	local_order_flavour_options = order_flavour_options
	local_order_options = order_options
	local_button_options = button_options
	
	portraits.append(preload("res://Assets/Images/UI/Potrait1.png"))
	portraits.append(preload("res://Assets/Images/UI/Potrait2.png"))
	portraits.append(preload("res://Assets/Images/UI/Potrait3.png"))
	portraits.append(preload("res://Assets/Images/UI/Potrait4.png"))
	
	register_notifications()

func register_notifications() -> void:
	var _station_number = -1
	for _station:Station in get_tree().get_nodes_in_group("Stations"):
		_station_number += 1
		
		var _new_notification = create_notification()
		_new_notification.visible = false
		_new_notification.name = "Notification{"+_station.name+"}"
		_new_notification.global_position = _station.global_position
		
		_new_notification.station = _station
		_new_notification.portait = portraits[_station_number]
		
		_station.on_make_order.connect(_new_notification.tracking)
		_station.on_make_order.connect(_new_notification.create_dialogue_message)
		_station.on_complete_order.connect(_new_notification.stop)
		

func create_notification() -> Notification:
	var _new_notification = notification_prefab.instantiate() as Notification
	add_child(_new_notification)
	return _new_notification
