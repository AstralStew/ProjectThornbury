class_name Chute extends Area2D



@export_category("READ ONLY")

@export var is_open : bool = false :
	get: return Input.is_action_pressed("OpenChute")


func _on_body_entered(body: Node2D) -> void:
	if is_open:
		body.queue_free()
