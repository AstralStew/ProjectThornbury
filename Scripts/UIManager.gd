class_name UIManager extends CanvasLayer
const DEBUG_NAME = "[b][UIManager][/b] "
static var instance : UIManager = null

@onready var ui_holder : Control = $UIHolder
@onready var border : Control = $UIHolder/Border

func _enter_tree() -> void:
	instance = self


func jolt() -> void:
	
	border.color = Color.DARK_RED
	
	var shake = 6.0
	var shake_duration = 0.025
	var _tween:Tween = null
	var _start_pos:Vector2=ui_holder.position
	while (shake>0):
		if _tween: _tween.kill()
		_tween = create_tween().set_trans(Tween.TRANS_SPRING).set_parallel()
		_tween.tween_property(ui_holder, "position", _start_pos + GLOBALS.random_vector2_normalised(shake), shake_duration)
		_tween.tween_property(OutsideManager.instance, "modulate", Color.WHITE.lerp(GLOBALS.random_color(Vector2(1,1.25),Vector2(0.9,1.1),Vector2(0.9,1.1)),shake/6), shake_duration)
		_tween.tween_property(InventoryManager.instance, "modulate", Color.WHITE.lerp(GLOBALS.random_color(Vector2(1,1.25),Vector2(0.9,1.1),Vector2(0.9,1.1)),shake/6), shake_duration)
		if Ship.instance.has_control: shake -= 1
		await get_tree().create_timer(shake_duration).timeout
	
	InventoryManager.instance.modulate = Color.WHITE
	OutsideManager.instance.modulate = Color.WHITE
	ui_holder.position = Vector2.ZERO
	border.color = Color(0.161, 0.157, 0.192)
