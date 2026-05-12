class_name InventoryObject extends RigidBody2D
var DEBUG_NAME : String :
	get: return "[b][InventoryObject("+name+")][/b] "

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print_rich(DEBUG_NAME,"OnInputEvent > Got here")
	if event is InputEventMouseButton && Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		print_rich(DEBUG_NAME,"OnInputEvent > Clicked! Telling Inventory to start drag force...")
		Inventory.instance.dragging(self,get_viewport().get_mouse_position())
		
