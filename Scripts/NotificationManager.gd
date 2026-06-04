class_name NotificationManager extends Node
const DEBUG_NAME = "[b][NotificationManager][/b] "
static var instance : NotificationManager = null

@onready var notification_prefab : PackedScene = preload("res://Scenes/OutsidePrefabs/notification.tscn")



enum RewardType {REPAIR,DELAY,RESOURCE}


@export var order_flavour_options : Array[String] = [
	"The old planet is dying; a new one struggles to be born.",
	"We stand for the pink, white, and blue around these parts.",
	"Those who bring us tools of our own - that is true aid.",
	"From each to their ability; to each an even bounty!",
	"Community or barbarism - there is no other choice.",
	"They say to 'get ahead'... of whom? Our neighbours?",
	"People of the stars unite! We lose nothing but our chains!",
	"Let us throw our bodies upon the gears of this machine!",
]

@export var order_options : Array[String] = [
	"Whoever recieves this, we urgently require %s for repairs.",
	"Mutual aid request: %s to fix our water filtration system.",
	"In such times, we humbly request a delivery of %s!",
	"Even %s would help get us back in the green.",
	"%s would let us take the fight upwards!",
	"We will need %s before the Capital ship arrives.",
	"Just %s and we can finally get back on track.",
	"Can someone spare %s for our hydroponic facility?",
]

@export var complete_options : Array[String] = [
	"Thank you comrade! Please let us help you with something in turn...",
	"We won't forget this. Here's a token of our gratitude...",
	"Haha, we won't be outdone! Here's a gift of your own...",
	"You don't know the impact you've made. Is there anything you need...?",
	"This is too much friend! Give us a moment to find a fair trade...",
	"Our people are too proud for charity, but perhaps an exchange...?",
	"Just what we needed, and not a moment too soon. Here, in return...",
	"Ah, a fellow traveller. Please, take what you need from our stores...",
]

@export var button_options : Array[String] = [
	"Alrighty",
	"Cool beans",
	"No worries",
	"Can do",
	"Yea sick",
	"Sure thing",
	"Affirmative",
	"Nah yeah",
	"Of course",
	"As you wish",
	"Should work",
	"On my way",
	"Say no more",
	"I got you",
	"Let's gooo",
	"Heard chef",
]

@export var station_names : Array[String] = [
	"Sankara Prime",
	"Goldman Prospekt",
	"GramSci Hub",
	"Bogdanov Arkade",
	"Gue'Vara Colony",
	"Laomao 2X-V2",
]

@export var populations : Array[String] = [
	"1312",
	"6090",
	"4200",
	"1610",
]


var local_order_flavour_options : Array[String] = []
var local_order_options : Array[String] = []
var local_complete_options : Array[String] = []

var local_station_names : Array[String] = []
var local_populations : Array[String] = []


var current_notifications : Dictionary[Notification,float] = {}

func _enter_tree() -> void:
	instance = self



static func pop_random_flavour_option() -> String:
	if instance.local_order_flavour_options.size() == 0:
		instance.local_order_flavour_options = instance.order_flavour_options.duplicate()
	return instance.local_order_flavour_options.pop_at(randi() % instance.local_order_flavour_options.size())

static func pop_random_order_option() -> String:
	if instance.local_order_options.size() == 0:
		instance.local_order_options = instance.order_options.duplicate()
	return instance.local_order_options.pop_at(randi() % instance.local_order_options.size())

static func pop_random_complete_option() -> String:
	if instance.local_complete_options.size() == 0:
		instance.local_complete_options = instance.complete_options.duplicate()
	return instance.local_complete_options.pop_at(randi() % instance.local_complete_options.size())

static func random_button_option() -> String:
	return instance.button_options.pick_random()

static func pop_random_station_name() -> String:
	if instance.local_station_names.size() == 0:
		instance.local_station_names = instance.station_names.duplicate()
	return instance.local_station_names.pop_at(randi() % instance.local_station_names.size())

static func pop_random_population() -> String:
	if instance.local_populations.size() == 0:
		instance.local_populations = instance.populations.duplicate()
	return instance.local_populations.pop_at(randi() % instance.local_populations.size())



static func register_station_notification(_station:Station) -> void:
	instance._register_station_notification(_station)
func _register_station_notification(_station:Station) -> void:
	
	var _new_notification = create_notification()
	_new_notification.visible = false
	_new_notification.name = "Notification{"+_station.name+"}"
	_new_notification.global_position = _station.global_position
	_new_notification.reset_physics_interpolation()
	
	_new_notification.begin(_station)
	
	_station.on_complete_order.connect(_new_notification.finish)




func create_notification() -> Notification:
	var _new_notification = notification_prefab.instantiate() as Notification
	add_child(_new_notification)
	return _new_notification
