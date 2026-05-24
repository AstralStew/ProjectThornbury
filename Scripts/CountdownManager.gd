class_name CountdownManager extends Control
const DEBUG_NAME = "[b][CountdownManager][/b] "
static var instance : CountdownManager = null

@onready var countdown_remaining_label : RichTextLabel = $CountdownRemaining
@onready var countdown_change_label : RichTextLabel = $CountdownChangeLabel


@export_category("READ ONLY")
@export var countdown_remaining : int = -1


var _minutes : int 
var _seconds : int 
var _result : String
func convert_seconds_to_text(seconds:int) -> String:
	_minutes = floori(seconds / 60.0)
	_seconds = seconds - (_minutes * 60) 
	return "%02d : %02d" % [_minutes, _seconds]

func _enter_tree() -> void:
	instance = self


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	countdown_remaining = GLOBALS.COUNTDOWN_BEFORE_AUTHORITIES_ARRIVE
	
	ticking_countdown()


func ticking_countdown() -> void:
	
	var _timer = (countdown_remaining_label.get_child(0) as Timer)
	
	countdown_remaining_label.text = convert_seconds_to_text(countdown_remaining)
	while (countdown_remaining > 0):
		countdown_remaining_label.text = convert_seconds_to_text(countdown_remaining)
		await _timer.timeout
		countdown_remaining -= 1
	
	
	CapitalShot.fire()
	
	while (true):
		countdown_remaining_label.text = "[color=red]00 : 00"
		await get_tree().create_timer(1,false).timeout
		countdown_remaining_label.text = " "
		await get_tree().create_timer(1,false).timeout
		
	
	#UIManager.instance.lose()



static func adjust_from_items(items:Array[Item]) -> void:
	instance._adjust_from_items(items)
func _adjust_from_items(items:Array[Item]) -> void:
	var _amount : int = 0
	for _item in items:
		match _item.type:
			InventoryManager.ItemType.Rock:
				_amount += GLOBALS.COUNTDOWN_ROCK_REDUCTION
			InventoryManager.ItemType.Crate:
				_amount += GLOBALS.COUNTDOWN_CRATE_REDUCTION
			InventoryManager.ItemType.Pipe:
				_amount += GLOBALS.COUNTDOWN_PIPE_REDUCTION
		
	adjust_countdown(_amount)


var _tween : Tween
static func adjust_countdown(amount_of_seconds:float) -> void:
	instance._adjust_countdown(amount_of_seconds)
func _adjust_countdown(amount_of_seconds:int) -> void:
	
	countdown_remaining = max(0,countdown_remaining - amount_of_seconds)
	
	countdown_remaining_label.text = convert_seconds_to_text(countdown_remaining)
	if amount_of_seconds < 0:
		countdown_change_label.text = "[color=green]+[i][b]" + convert_seconds_to_text(abs(amount_of_seconds))
	else:
		countdown_change_label.text = "[color=red]-[i][b]" + convert_seconds_to_text(abs(amount_of_seconds))
	countdown_change_label.visible = true
	countdown_change_label.modulate = Color.WHITE
		
	if _tween: _tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(countdown_change_label,"modulate", Color(Color.WHITE,0.0),4.0)
	_tween.tween_property(countdown_change_label,"visible",false,0.0).set_delay(4.0)
