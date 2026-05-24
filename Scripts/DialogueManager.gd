class_name DialogueManager extends MarginContainer
const DEBUG_NAME = "[b][DialogueManager][/b] "
static var instance : DialogueManager = null


@onready var portrait_box : TextureRect = $DialoguePC/MarginContainer/VBoxContainer/HBoxContainer/Portrait
@onready var dialogue_label : RichTextLabel = $DialoguePC/MarginContainer/VBoxContainer/HBoxContainer/DialogueLabel
@onready var dialogue_button_1: Button = $DialoguePC/MarginContainer/VBoxContainer/HBButtons/DialogueButton1
@onready var dialogue_button_2: Button = $DialoguePC/MarginContainer/VBoxContainer/HBButtons/DialogueButton2
@onready var dialogue_audio: AudioStreamPlayer = $DialogueAudio


@export var default_text_speed : int = 1

@export var is_scrolling_text : bool = false
@export var waiting_for_button : bool = false

signal _on_dialogue_close
static func on_dialogue_close() -> Signal: return instance._on_dialogue_close

signal _on_dialogue_choice(choice_index)
static func on_dialogue_choice() -> Signal: return instance._on_dialogue_choice


func _enter_tree() -> void:
	instance = self


static func set_transform(new_position : Vector2, new_size : Vector2, margins : Array[int] = [0,0,0,0]) -> void:
	instance.position = new_position
	instance.size = new_size
	instance.add_theme_constant_override("theme_override_constants/margin_left",margins[0])
	instance.add_theme_constant_override("theme_override_constants/margin_top",margins[0])
	instance.add_theme_constant_override("theme_override_constants/margin_right",margins[0])
	instance.add_theme_constant_override("theme_override_constants/margin_bottom",margins[0])

static func display_dialogue_box(message_text:="",button_1_text:="OK", button_2_text:="", portrait:Texture2D = null, affect_time:bool = false, close_on_finish:bool = false, text_speed : int = -1,audio_median_pitch : float = 0.85) -> void:
	await instance._display_dialogue_box(message_text,button_1_text,button_2_text,portrait,affect_time,close_on_finish,text_speed if text_speed > 0 else instance.default_text_speed,audio_median_pitch)


var _tween : Tween
func _display_dialogue_box(message_text:="",button_1_text:="OK",button_2_text:="", portrait:Texture2D = null, affect_time:bool = false, close_on_finish:bool = false, text_speed : int = default_text_speed,audio_median_pitch : float = 0.85) -> void:
	
	if affect_time && !UIManager.is_time_stopped: await UIManager.stop_time(0.5)
	
	dialogue_label.text = message_text
	dialogue_button_1.text = button_1_text
	if button_2_text != "":
		dialogue_button_2.visible = true
		dialogue_button_2.text = button_2_text
	else:
		dialogue_button_2.visible = false
	print(DEBUG_NAME, "DisplayDialogueBox > Displaying text '"+message_text+"' with button '"+button_1_text+"'" + (" and button '"+button_2_text+"'" if button_2_text != "" else ""))
	
	if portrait != null:
		print(DEBUG_NAME, "DisplayDialogueBox > Setting portrait!")
		portrait_box.texture = portrait
	
	await get_tree().process_frame
	visible = true
	
	waiting_for_button = true
	if text_speed > 0:
		is_scrolling_text = true
		print(DEBUG_NAME, "DisplayDialogueBox > Scrolling the text!")
		dialogue_label.visible_characters = 0
		
		if _tween && _tween.is_running(): _tween.kill()
		_tween = create_tween()
		_tween.tween_property(dialogue_label,"visible_ratio",1.0,(dialogue_label.get_total_character_count() as float) / (text_speed as float))
		_tween.tween_callback(set.bind("is_scrolling_text",false)) # is_scrolling_text = false
		_tween.tween_callback(stop_audio) # is_scrolling_text = false
	
	#print(DEBUG_NAME, "DisplayDialogueBox > Waiting for button press...")
	
	dialogue_audio.stream = preload("res://Assets/Audio/UI/453087__lilmati__script-dialogue-03.wav")
	dialogue_audio.pitch_scale = audio_median_pitch 
	dialogue_audio.volume_db = -22 
	dialogue_audio.play()
	while (is_scrolling_text || waiting_for_button):
		#print(DEBUG_NAME, "DisplayDialogueBox > Waiting for button press...")
		if randf() < 0.5: dialogue_audio.pitch_scale = audio_median_pitch + randf_range(-0.05,0.05)
		dialogue_audio.volume_db = -22 if randf() < 0.9 else -60
		#dialogue_audio.volume_db = -18 if randi() % 8 else -60 # if randi() % 2: if randi() % 2: if randi() % 2: dialogue_audio.pitch_scale = randf_range(0.8,1.0)
		await get_tree().create_timer(0.2).timeout
	#if _tween && _tween.is_running(): _tween.kill()
	
	
	if close_on_finish:
		print(DEBUG_NAME, "DisplayDialogueBox > Closing on finish!")
		visible = false
	
	print(DEBUG_NAME, "DisplayDialogueBox > Finished!")
	
	_on_dialogue_close.emit()
	
	if affect_time && UIManager.is_time_stopped: await UIManager.start_time(0.5)


func stop_audio() -> void:
	if dialogue_audio.playing: dialogue_audio.stop()



func _on_dialogue_button_1_pressed() -> void:
	dialogue_button_pressed()
	_on_dialogue_choice.emit(0)

func _on_dialogue_button_2_pressed() -> void:
	dialogue_button_pressed()
	_on_dialogue_choice.emit(1)

func dialogue_button_pressed() -> void:
	if is_scrolling_text: skip_text_scroll()
	
	waiting_for_button = false
	dialogue_audio.volume_db = -10
	dialogue_audio.stream = preload("res://Assets/Audio/UI/591457__stavsounds__select.wav")
	await get_tree().physics_frame
	dialogue_audio.pitch_scale = 0.9
	dialogue_audio.play()

func skip_text_scroll() -> void:
	if _tween: _tween.kill()
	is_scrolling_text = false
	dialogue_label.visible_ratio = 1.0
	stop_audio()

func _on_gui_input(event: InputEvent) -> void:
	if is_scrolling_text && event is InputEventMouseButton && Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		skip_text_scroll()
