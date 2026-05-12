class_name Collectable extends Area2D

@export var inventory_prefab : PackedScene = null

func collect() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Ship:
		collect()
