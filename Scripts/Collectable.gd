class_name Collectable extends Area2D
var DEBUG_NAME : String :
	get: return "[b][Collectable("+name+")][/b] "

@export var type : InventoryManager.ItemType = InventoryManager.ItemType.ItemA

func collect() -> void:
	if !InventoryManager.chute_open: return
	
	print_rich(DEBUG_NAME,"Collect > Chute is open! Telling InventoryManager what I am...")
	
	InventoryManager.add_item(type)
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Ship:
		collect()
