class_name UIManager extends CanvasLayer
const DEBUG_NAME = "[b][UIManager][/b] "
static var instance : UIManager = null

@onready var ui_holder : Control = $UIHolder
@onready var border : Control = $UIHolder/Border

static var has_taken_damage : bool = false # don't reset this on restart!

signal _on_restart_game
static func on_restart_game() -> Signal: return instance._on_restart_game

func _enter_tree() -> void:
	instance = self
	
	on_restart_game().connect(GLOBALS.restart_game)

func _ready() -> void:
	GLOBALS.on_health_changed().connect(took_damage)

func start_time(fade:=0.0) -> void:
	get_tree().paused = false
	
	if fade:
		Engine.time_scale = 0.0
		var _tween:Tween = create_tween().set_ignore_time_scale().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		_tween.tween_property(Engine,"time_scale",1,fade).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		await get_tree().create_timer(fade,true,false,true).timeout
		await get_tree().process_frame
		Engine.time_scale = 1.0

	

func stop_time(fade:=0.0) -> void:
	if fade:
		Engine.time_scale = 1.0
		var _tween:Tween = create_tween().set_ignore_time_scale().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		_tween.tween_property(Engine,"time_scale",0,fade).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		await get_tree().create_timer(fade,true,false,true).timeout
		await get_tree().process_frame
		Engine.time_scale = 1.0
	
	get_tree().paused = true


#region Events

func took_damage() -> void:
	if !has_taken_damage:
		took_damage_first_time()
	elif GLOBALS.proportional_health <= 0:
		dead()

func took_damage_first_time() -> void:
	has_taken_damage = true
	await get_tree().create_timer(0.5,true,false,true).timeout
	await stop_time(1)
	await display_message_box(
		"""Well well, looks like [wave amp=50.0 freq=5.0 connected=1]someone[/wave] took some [shake rate=20.0 level=5 connected=1]damage[/shake] for the first time!

[tornado radius=5.0 freq=1.0 connected=1]You must be bad at video games.[/tornado]

Good luck out there, baka desu.""",
	"wow okay :(",
	1
	)
	await get_tree().create_timer(0.25,true,false,true).timeout
	await start_time(1)

func dead() -> void:
	has_taken_damage = true
	await stop_time(1)
	await display_message_box(
		"Dead hours
washed gang gang
no health? :/",
	"damn, guess I'll try again",
	1
	)
	await start_time(1)
	_on_restart_game.emit()
	get_tree().reload_current_scene()
	


#endregion


func display_message_box(message_text:="",button_text:="OK",min_time:=0.0,box_size:Vector2=Vector2(400,100)) -> void:
	$UIHolder/MessageBox.visible = true
	
	$UIHolder/MessageBox.custom_minimum_size = box_size
	$UIHolder/MessageBox/VBoxContainer/RTL_Message.text = message_text
	$UIHolder/MessageBox/VBoxContainer/RTL_Button.text = button_text
	
	await get_tree().create_timer(min_time,true,false,true).timeout
	await $UIHolder/MessageBox/VBoxContainer/RTL_Button.pressed
	$UIHolder/MessageBox.visible = false

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
