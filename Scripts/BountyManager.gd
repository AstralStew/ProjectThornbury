class_name BountyManager extends Control
const DEBUG_NAME = "[b][BountyManager][/b] "
static var instance : BountyManager = null


@onready var bounty_total_label : RichTextLabel = $BountyTotalLabel
@onready var bounty_change_label : RichTextLabel = $BountyChangeLabel

static var current_bounty : int = 0

func _enter_tree() -> void:
	instance = self


static func add_from_scanned_items(items:Array[Item]) -> void:
	instance._add_from_scanned_items(items)

func _add_from_scanned_items(items:Array[Item]) -> void:
	var _amount : int = 0
	for _item in items:
		match _item.type:
			InventoryManager.ItemType.Rock:
				_amount += GLOBALS.BOUNTY_ROCK_FINE_AMOUNT
			InventoryManager.ItemType.Crate:
				_amount += GLOBALS.BOUNTY_CRATE_FINE_AMOUNT
			InventoryManager.ItemType.Pipe:
				_amount += GLOBALS.BOUNTY_PIPE_FINE_AMOUNT
	
	_amount *= floor(items.size() * GLOBALS.BOUNTY_BRAZEN_FINE_MULTIPLIER)
	
	add_to_bounty(_amount)


var _bounty_tween : Tween
static func add_to_bounty(amount:int) -> void:
	instance._add_to_bounty(amount)
func _add_to_bounty(amount:int) -> void:
	
	current_bounty += amount
	bounty_total_label.text = str(current_bounty) + " [font_size=15]CREDS"
	bounty_change_label.text = "[color=green]+[i]" + str(amount)
	bounty_change_label.visible = true
	#bounty_change_label.modulate = Color(Color.WHITE,0)
	
	#if _bounty_tween: _bounty_tween.kill()
	#_bounty_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).set
	#_bounty_tween.tween_property(bounty_change_label,"modulate", Color.WHITE,1.0)
	await get_tree().create_timer(1.0,false)
	bounty_change_label.visible = false
	
	#_bounty_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	#_bounty_tween.tween_property(bounty_change_label,"modulate", Color.WHITE,1.0)
	
