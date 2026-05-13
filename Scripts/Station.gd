class_name Station extends Area2D
var DEBUG_NAME : String :
	get: return "[b][Station("+name+")][/b] "
static var instance : Station = null

@export var cooldown_duration : Vector2 = Vector2(5.0,20.0)


@export_category("READ ONLY")

@export var has_order : bool = false
@export var order_type : InventoryManager.ItemType = InventoryManager.ItemType.Rock
@export var order_number : int = -1

@onready var _label : Label = $Label


func _ready() -> void:
	make_order()

func make_order() -> void:
	if has_order: return
	
	order_type = (randi() % 3) as InventoryManager.ItemType
	order_number = 1 + (randi() % 6)
	has_order = true
	update_text()

func update_text() -> void:
	if has_order:
		_label.text = "We need " + str(order_number) + " " + str(InventoryManager.ItemType.keys()[order_type])
		_label.visible = true
	else:
		_label.text = ""
		_label.visible = false

func collect(collectable: Collectable) -> void:
	collectable.collected = true
	print_rich(DEBUG_NAME,"Collect > Item matches, taking it for myself <|:)")
	
	if collectable.type == order_type:
		order_number -= 1
		if check_order(): complete_order()
		update_text()
	
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
	cooldown()

func cooldown() -> void:
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
