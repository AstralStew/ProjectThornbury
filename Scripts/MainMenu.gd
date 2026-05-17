class_name MainMenu extends CanvasLayer

@export var game_scene : PackedScene = null



func _on_start_button_pressed() -> void:
	
	var _tween : Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR).set_parallel()
	_tween.tween_property($Overlay,"modulate",Color.WHITE,3)
	#_tween.tween_property(MusicPlayer,"volume_linear",0,3)
	_tween.tween_callback(change_scene).set_delay(3)
	
	MusicPlayer.fade_out(3)


func change_scene() -> void:
	get_tree().change_scene_to_packed(game_scene)
