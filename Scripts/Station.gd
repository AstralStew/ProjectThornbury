class_name Station extends Area2D
var DEBUG_NAME : String :
	get: return "[b][Station("+name+")][/b] "
#static var instance : Station = null

@export var cooldown_duration : Vector2 = Vector2(10.0,30.0)

@export var prosperity_target : int = 2

@export_category("READ ONLY")

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
	
	get_child(0).get_child(0).rotation = GLOBALS.random_rotation(180)
	for _child:Node2D in get_child(0).get_children():
		if "Expansion" in _child.name:
			_expansions.append(_child)
			_child.rotation = GLOBALS.random_rotation(180)
	_expansions.pick_random().visible = true
	
	prosperity = 0
	#cooldown()

func make_order() -> void:
	if has_order || is_prosperous: return
	
	order_type = (randi() % 3) as InventoryManager.ItemType
	match order_type:
		InventoryManager.ItemType.Rock:
			order_number = randi_range(4,7)
		InventoryManager.ItemType.Crate:
			order_number = randi_range(2,3)
		InventoryManager.ItemType.Pipe:
			order_number = randi_range(3,5)
	
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
	await get_tree().create_timer(0.75).timeout
	

func check_order() -> bool:
	if !has_order: return false
	if order_number > 0: return false
	return true

func complete_order() -> void:
	print_rich(DEBUG_NAME,"CheckOrder > Order complete! Starting cooldown and returning true...")
	has_order = false
	
	CountdownManager.adjust_countdown(-randf_range(30,60))
	
	prosperity += 1
	var _chosen:Node2D=null
	while _chosen == null:
		_chosen = _expansions.pick_random()
		if _chosen.visible: _chosen=null
	_chosen.visible = true
	
	on_complete_order.emit(self)
	if !is_prosperous: cooldown()
	else: on_become_prosperous.emit(self)

func cooldown() -> void:
	#update_text()
	for i in prosperity+1:
		await get_tree().create_timer(randf_range(cooldown_duration.x,cooldown_duration.y)).timeout
	print_rich(DEBUG_NAME,"Cooldown > Cooldown finished! Making a new order...")
	make_order()


func _physics_process(delta: float) -> void:
	if !has_overlapping_areas(): return
	
	for _area:Area2D in get_overlapping_areas():
		if _area is Collectable:
			if _area.finished_spawning && !_area.collected:
				collect(_area)

#func _on_area_entered(area: Area2D) -> void:
	#if !has_order: return
	#
	#if area is Collectable:
		#if area.type == order_type:
			#collect(area)
