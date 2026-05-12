class_name Collectable extends Area2D

@export var type : InventoryManager.ItemType = InventoryManager.ItemType.ItemA

func collect() -> void:
	InventoryManager.add_item(type)
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Ship:
		collect()
