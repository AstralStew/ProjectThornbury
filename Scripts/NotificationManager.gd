class_name NotificationManager extends Node

@onready var notification_prefab : PackedScene = preload("res://Scenes/OutsidePrefabs/notification.tscn")



func _ready() -> void:
	for _station:Station in get_tree().get_nodes_in_group("Stations"):
		
		var _new_notification = create_notification()
		#_new_notification.tracking(_station)
		_new_notification.name = "Notification{"+_station.name+"}"
		
		_station.on_make_order.connect(_new_notification.tracking)
		_station.on_complete_order.connect(_new_notification.stop)


func create_notification() -> Notification:
	var _new_notification = notification_prefab.instantiate() as Notification
	add_child(_new_notification)
	_new_notification.name = "Notification"
	return _new_notification
