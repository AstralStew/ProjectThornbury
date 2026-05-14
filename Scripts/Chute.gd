class_name Chute extends Area2D
const DEBUG_NAME = "[b][Chute][/b] "
static var instance : Chute = null

@onready var chute_gfx : ColorRect = $HangerDoorFrame/Chute

var _open := false

func _enter_tree() -> void:
	instance = self

var _tween : Tween
func open() -> void:
	#chute_gfx.color = Color(0.933, 0.525, 0.584)
	if _tween: _tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD).SET
	_tween.tween_property(chute_gfx,"scale",Vector2(1,0),0.25)

func close() -> void:
	#chute_gfx.color = Color(0.2, 0.2, 0.2)
	if _tween: _tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(chute_gfx,"scale",Vector2.ONE,0.25)

func _physics_process(delta: float) -> void:
	if InventoryManager.chute_open:
		if !_open:
			_open = true
			open()
		if has_overlapping_bodies():
			for _body:Item in get_overlapping_bodies():
				if _body.finished_spawning:
					_body.jettison()
	elif _open:
		_open = false
		close()

 
#
#func _on_body_entered(body: Node2D) -> void:
	#if is_open:
		#body.queue_free()
