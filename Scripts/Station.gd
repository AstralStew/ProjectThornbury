class_name Station extends Area2D
var DEBUG_NAME : String :
	get: return "[b][Station("+name+")][/b] "


@onready var info_overlay: MarginContainer = $InfoOverlay
@onready var station_header: RichTextLabel = $InfoOverlay/VBoxContainer2/DialoguePC/StationHeader
@onready var population_label: RichTextLabel = $InfoOverlay/VBoxContainer2/PopulationLabel


@export_category("UI")

@export var portrait : Texture2D = null
@export var voice_pitch : float = 1.03

@export_category("STATION UI")
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
		change_visuals_based_on_prosperity()
		#get_child(0).modulate = Color.WHITE.lerp(Color(0.65, 0.599, 0.396, 1.0), 1 - (prosperity as float / prosperity_target as float))
		#get_child(1).modulate = Color.WHITE.lerp(Color(0.65, 0.599, 0.396, 1.0), 1 - (prosperity as float / prosperity_target as float))


@export var is_prosperous : bool = false :
	get: return prosperity >= prosperity_target

@export var has_order : bool = false
@export var order_type : InventoryManager.ItemType = InventoryManager.ItemType.Rock
@export var order_number : int = -1



signal on_make_order(station_ref)
signal on_complete_order(station_ref)
signal on_become_prosperous(station_ref)

var _expansions : Array[Node2D]

var _order_items : Array[InventoryManager.ItemType]

func _ready() -> void:
	
	station_name = NotificationManager.pop_random_station_name()
	station_header.text = station_name
	
	population = NotificationManager.pop_random_population()
	population_label.text = "Population: " + population
	
	
	LevelManager.on_level_ready().connect(on_level_ready)

func on_level_ready() -> void:
	global_rotation_degrees = 0
	
	for _child:Node2D in get_child(0).get_children():
		if "Expansion" in _child.name:
			_expansions.append(_child)
			_child.rotation = GLOBALS.random_rotation(180)
			(_child.get_child(0) as Node2D).global_position = _child.global_position + Vector2(4,4)
	
	prosperity = 0
	
	#_expansions.shuffle()
	#_expansions.pop_back().visible = true


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
	on_make_order.emit(self)
	
	NotificationManager.register_station_notification(self)


func collect(collectable: Collectable) -> void:
	collectable.collected = true
	print_rich(DEBUG_NAME,"Collect > Item matches, taking it for myself <|:)")
	
	BountyManager.add_from_items([collectable.type],3)
	
	if collectable.type == order_type:
		order_number -= 1
		if check_order(): complete_order()
	
	var _collect_tween : Tween = create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_collect_tween.tween_property(collectable,"modulate",Color(0,0,0,0),0.75)
	_collect_tween.tween_property(collectable,"global_position",global_position + Vector2(remap(randf(),0,1,-30,30),remap(randf(),0,1,-30,30)),0.75)
	_collect_tween.tween_property(collectable,"scale",Vector2(0.25,0.25),0.75)
	_collect_tween.tween_callback(collectable.queue_free).set_delay(0.75)
	await get_tree().create_timer(0.75,false).timeout
	
	

func check_order() -> bool:
	if !has_order: return false
	if order_number > 0: return false
	return true

func complete_order() -> void:
	print_rich(DEBUG_NAME,"CheckOrder > Order complete! Starting cooldown and returning true...")
	has_order = false
		
	prosperity += 1
	
	on_complete_order.emit(self)
	
	change_visuals_based_on_prosperity()
	
	if is_prosperous: on_become_prosperous.emit(self)
	
	#if !is_prosperous: cooldown()
	#else: on_become_prosperous.emit(self)

#func cooldown() -> void:
	##update_text()
	#for i in prosperity+1:
		#await get_tree().create_timer(randf_range(cooldown_duration.x,cooldown_duration.y),false).timeout
	#print_rich(DEBUG_NAME,"Cooldown > Cooldown finished! Making a new order...")
	#make_order()


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


var prosperity_visual_tween:Tween
func change_visuals_based_on_prosperity() -> void:
	if prosperity_visual_tween: prosperity_visual_tween.kill()
	
	var _duration := 4.0
	var _delay := 0.5
	prosperity_visual_tween = create_tween().set_parallel()
	prosperity_visual_tween.tween_property(get_child(0),"modulate",Color.WHITE.lerp(Color(0.65, 0.599, 0.396, 1.0), 1 - (prosperity as float / prosperity_target as float)),_duration).set_delay(_delay)
	prosperity_visual_tween.tween_property(get_child(1),"modulate",Color.WHITE.lerp(Color(0.65, 0.599, 0.396, 1.0), 1 - (prosperity as float / prosperity_target as float)),_duration).set_delay(_delay)
	if _expansions.size() > 0:
		_expansions.shuffle()
		prosperity_visual_tween.tween_property(_expansions.pop_back(),"visible",true,_duration).set_delay(_delay)
	
	while prosperity_visual_tween.is_running():
		await get_tree().physics_frame
	#get_child(1).set_deferred("modulate", Color.WHITE.lerp(Color(0.65, 0.599, 0.396, 1.0), 1 - (prosperity as float / prosperity_target as float)))
		


var _tween:Tween

func display_info() -> void:
	is_displaying_info = true
	#info_overlay.visible = true
	if _tween: _tween.kill()
	_tween = get_tree().create_tween().set_parallel().set_trans(Tween.TRANS_BOUNCE)
	_tween.tween_property(info_overlay,"modulate",Color.WHITE,fade_duration).from(Color(Color.WHITE,0))
	_tween.tween_property(info_overlay,"scale",Vector2.ONE,fade_duration).from(Vector2(0.9,0.9))
	await get_tree().create_timer(fade_duration,false).timeout
	#_tween.tween_property(info_overlay,"modulate",1,3)


func hide_info() -> void:
	is_displaying_info = false
	
	if _tween: _tween.kill()
	_tween = get_tree().create_tween().set_parallel().set_trans(Tween.TRANS_BOUNCE)
	_tween.tween_property(info_overlay,"modulate",Color(Color.WHITE,0),fade_duration/2).from(Color.WHITE)
	_tween.tween_property(info_overlay,"scale",Vector2(0.9,0.9),fade_duration/2).from(Vector2.ONE).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(fade_duration/2,false).timeout
	#info_overlay.visible = false
