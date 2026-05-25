class_name Station extends Area2D
var DEBUG_NAME : String :
	get: return "[b][Station("+name+")][/b] "
#static var instance : Station = null
# 1420    1619   1312   1161





@onready var info_overlay: MarginContainer = $InfoOverlay
@onready var station_header: RichTextLabel = $InfoOverlay/VBoxContainer2/DialoguePC/StationHeader
@onready var population_label: RichTextLabel = $InfoOverlay/VBoxContainer2/PopulationLabel


@export_category("UI")

@export var fade_duration : float = 2.0

@export_category("CONTROLS")


@export var cooldown_duration : Vector2 = Vector2(10.0,30.0)

@export var prosperity_target : int = 3

@export_category("READ ONLY")

@export var station_name : String = ""
@export var population : String = ""
@export var is_displaying_info : bool = false

@export var prosperity : int = 0 :
	set(value):
		prosperity = value
		get_child(0).modulate = Color.WHITE.lerp(Color(0.65, 0.599, 0.396, 1.0), 1 - (prosperity as float / prosperity_target as float))

@export var is_prosperous : bool = false :
	get: return prosperity >= prosperity_target

@export var has_order : bool = false
@export var order_type : InventoryManager.ItemType = InventoryManager.ItemType.Rock
@export var order_number : int = -1


#@onready var _label : Label = $PanelContainer/Label

signal on_make_order(station_ref)
signal on_complete_order(station_ref)
signal on_become_prosperous(station_ref)

var _expansions : Array[Node2D]

var _order_items : Array[InventoryManager.ItemType]

func _ready() -> void:
	
	for _child:Node2D in get_child(0).get_children():
		if "Expansion" in _child.name:
			_expansions.append(_child)
			_child.rotation = GLOBALS.random_rotation(180)
			(_child.get_child(0) as Node2D).global_position = _child.global_position + Vector2(8,10)
	
	_expansions.pick_random().visible = true
	
	station_name = NotificationManager.pop_random_station_name()
	station_header.text = station_name
	
	population = NotificationManager.pop_random_population()
	population_label.text = "Population: " + population
	
	
	prosperity = 0
	#cooldown()

func make_order() -> void:
	if has_order || is_prosperous: return
	
	order_type = (randi() % 3) as InventoryManager.ItemType
	match order_type:
		InventoryManager.ItemType.Rock:
			order_number = 4 + (prosperity * 4) # randi_range(4,7)		2	4
		InventoryManager.ItemType.Crate:
			order_number = 2 + (prosperity * 1)  # randi_range(2,3)		1	2
		InventoryManager.ItemType.Pipe:
			order_number = 3 + (prosperity * 2)  	#randi_range(3,5)		2	3
	
	for i in order_number:
		_order_items.append(order_type)
	
	has_order = true
	#update_text()
	on_make_order.emit(self)

#func update_text() -> void:
	#if has_order:
		##_label.text = "We need " + str(order_number) + " " + str(InventoryManager.ItemType.keys()[order_type])
		##_label.visible = true
	#elif is_prosperous:
		#_label.text = "COMPLETE"
		#_label.visible = true
	#else:
		#_label.text = ""
		#_label.visible = false

func collect(collectable: Collectable) -> void:
	collectable.collected = true
	print_rich(DEBUG_NAME,"Collect > Item matches, taking it for myself <|:)")
	
	BountyManager.add_from_items([collectable.type],3)
	
	if collectable.type == order_type:
		order_number -= 1
		if check_order(): complete_order()
		#else: update_text()
	
	var _tween : Tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(collectable,"modulate",Color(0,0,0,0),0.75)
	_tween.tween_property(collectable,"global_position",global_position + Vector2(remap(randf(),0,1,-30,30),remap(randf(),0,1,-30,30)),0.75)
	_tween.tween_property(collectable,"scale",Vector2(0.25,0.25),0.75)
	await get_tree().create_timer(0.75,false).timeout
	

func check_order() -> bool:
	if !has_order: return false
	if order_number > 0: return false
	return true

func complete_order() -> void:
	print_rich(DEBUG_NAME,"CheckOrder > Order complete! Starting cooldown and returning true...")
	has_order = false
	
	#CountdownManager.adjust_countdown(-randf_range(30,60))
	
	prosperity += 1
	
	if _expansions.size() > 0:
		_expansions.shuffle()
		_expansions.pop_back().visible = true
	
	on_complete_order.emit(self)
	if !is_prosperous: cooldown()
	else: on_become_prosperous.emit(self)

func cooldown() -> void:
	#update_text()
	for i in prosperity+1:
		await get_tree().create_timer(randf_range(cooldown_duration.x,cooldown_duration.y),false).timeout
	print_rich(DEBUG_NAME,"Cooldown > Cooldown finished! Making a new order...")
	make_order()


func _physics_process(delta: float) -> void:
	if !has_overlapping_areas() &&  !has_overlapping_bodies():
		if is_displaying_info: hide_info()
		return
	
	for _area:Area2D in get_overlapping_areas():
		if _area is Collectable:
			if _area.finished_spawning && !_area.collected:
				collect(_area)
	for _body:PhysicsBody2D in get_overlapping_bodies():
		if _body is Ship:
				if !is_displaying_info:
					display_info()

var _tween:Tween

func display_info() -> void:
	is_displaying_info = true
	#info_overlay.visible = true
	if _tween: _tween.kill()
	_tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BOUNCE)
	_tween.tween_property(info_overlay,"modulate",Color.WHITE,fade_duration)
	await get_tree().create_timer(fade_duration).timeout
	#_tween.tween_property(info_overlay,"modulate",1,3)


func hide_info() -> void:
	if _tween: _tween.kill()
	_tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BOUNCE)
	_tween.tween_property(info_overlay,"modulate",Color(Color.WHITE,0),fade_duration)
	await get_tree().create_timer(fade_duration).timeout
	#info_overlay.visible = false
	is_displaying_info = false

#func _on_area_entered(area: Area2D) -> void:
	#if !has_order: return
	#
	#if area is Collectable:
		#if area.type == order_type:
			#collect(area)
