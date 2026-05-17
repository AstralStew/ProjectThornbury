class_name IntroManager extends Control
const DEBUG_NAME = "[b][IntroManager][/b] "
static var instance : IntroManager = null

@export var intro_dialogue_them : Array[String] = []
@export var intro_dialogue_you : Array[String] = []

@export_category("READ ONLY")

@export var index = -1

func _enter_tree() -> void:
	instance = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start()

func _on_button_pressed() -> void:
	print("got here")
	next_dialogue()

func start() -> void:
	await get_tree().create_timer(1).timeout
	next_dialogue()
	visible = true

static func remove() -> void:
	instance.queue_free()

func next_dialogue() -> void:
	index += 1
	
	if index < intro_dialogue_them.size():
		$DialoguePC/MarginContainer/VBoxContainer/HBoxContainer/DialogueLabel.text = intro_dialogue_them[index]
		$DialoguePC/MarginContainer/VBoxContainer/DialogueButton.text = intro_dialogue_you[index]
		return
	
	MusicPlayer.fade_in(3)
	GLOBALS.start_game()
	queue_free()
