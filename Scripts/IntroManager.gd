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
	print("OnButtonPressed > Displaying next.")
	next_dialogue()

func start() -> void:
	await get_tree().create_timer(1).timeout
	
	DialogueManager.set_transform(Vector2.ZERO,Vector2(1280,720),[50,50,50,50])
	DialogueManager.on_dialogue_close().connect(_on_button_pressed)
	
	next_dialogue()
	visible = true

static func remove() -> void:
	instance.queue_free()

func next_dialogue() -> void:
	index += 1
	
	if index < intro_dialogue_them.size():
		
		
		DialogueManager.display_dialogue_box(intro_dialogue_them[index],intro_dialogue_you[index],"",null,false, true if index == intro_dialogue_them.size() - 1 else false)
		#
		#$DialoguePC/MarginContainer/VBoxContainer/HBoxContainer/DialogueLabel.text = intro_dialogue_them[index]
		#$DialoguePC/MarginContainer/VBoxContainer/DialogueButton.text = intro_dialogue_you[index]
		return
	else:
		DialogueManager.set_transform(Vector2(20,21),Vector2(680,640),[50,50,50,50])
	
	
	MusicPlayer.fade_in(3)
	GLOBALS.start_game()
	queue_free()
