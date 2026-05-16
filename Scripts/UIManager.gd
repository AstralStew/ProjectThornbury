class_name UIManager extends CanvasLayer
const DEBUG_NAME = "[b][UIManager][/b] "
static var instance : UIManager = null

@onready var ui_holder : Control = $UIHolder
@onready var border : Control = $UIHolder/Border
@onready var msg_bg_overlay : Control = $UIHolder/MessageBgOverlay
@onready var prosperity_bar : ProgressBar = $UIHolder/MC_ScreenHolders/HB_ScreenHolders/LeftScreen/PanelContainer/TopBar/ProsperityBar
@onready var time_remaining_label : RichTextLabel = $UIHolder/MC_ScreenHolders/HB_ScreenHolders/LeftScreen/BottomBar/TimeRemaining

@export var progress_colour : Gradient

@export_category("READ ONLY")
@export var time_remaining : int = -1

static var has_taken_damage : bool = false # don't reset this on restart!

signal _on_restart_game
static func on_restart_game() -> Signal: return instance._on_restart_game

static var _first_run : bool = true

func _enter_tree() -> void:
	instance = self
	
	on_restart_game().connect(GLOBALS.restart_game)

func _ready() -> void:
	GLOBALS.on_health_changed().connect(took_damage)
	LevelManager.on_prosperity_updated().connect(update_prosperity)
	time_remaining = GLOBALS.LEVEL_SECS_BEFORE_AUTHORITIES_ARRIVE
	
	if _first_run: first_run()
	
	ticking_time()

func first_run() -> void:
	_first_run = false
	await get_tree().create_timer(0.5).timeout
	_on_restart_game.emit()
	get_tree().reload_current_scene()

func ticking_time() -> void:
	
	var _timer = (time_remaining_label.get_child(0) as Timer)
	var _minutes : int = floori(time_remaining / 60.0)
	var _seconds : int = time_remaining - (_minutes * 60) 
	time_remaining_label.text = "%02d : %02d" % [_minutes, _seconds]
	while (time_remaining > 0):	
		_minutes = floor(time_remaining / 60.0)
		_seconds = time_remaining - (_minutes * 60) 
		time_remaining_label.text = "%02d : %02d" % [_minutes, _seconds]
		await _timer.timeout
		time_remaining -= 1
	lose()


func update_prosperity(value:float) -> void:
	
	print_rich(DEBUG_NAME,"Ready > Updating prosperity to " + str(value * 100))
	prosperity_bar.value = value * 100
	prosperity_bar.modulate = progress_colour.sample(value)
	
	if value >= 1:
		await get_tree().create_timer(0.5,true,false,true).timeout
		win()

func start_time(fade:=0.0) -> void:
	get_tree().paused = false
	if fade:
		msg_bg_overlay.visible = true
		msg_bg_overlay.modulate = Color(1,1,1,0.25)
		Engine.time_scale = 0.0
		var _tween:Tween = create_tween().set_ignore_time_scale().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		_tween.tween_property(Engine,"time_scale",1,fade)
		_tween.tween_property(msg_bg_overlay,"modulate", Color(1,1,1,0),fade)
		await get_tree().create_timer(fade,true,false,true).timeout
		await get_tree().process_frame
		Engine.time_scale = 1.0
	msg_bg_overlay.visible = false

	

func stop_time(fade:=0.0) -> void:
	msg_bg_overlay.visible = true
	if fade:
		msg_bg_overlay.modulate = Color(1,1,1,0)
		Engine.time_scale = 1.0
		var _tween:Tween = create_tween().set_ignore_time_scale().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		_tween.tween_property(Engine,"time_scale",0,fade)
		_tween.tween_property(msg_bg_overlay,"modulate", Color(1,1,1,0.25),fade)
		await get_tree().create_timer(fade,true,false,true).timeout
		await get_tree().process_frame
		Engine.time_scale = 1.0
	msg_bg_overlay.modulate = Color(1,1,1,0.25)
	get_tree().paused = true


#region Events

func took_damage() -> void:
	if !has_taken_damage:
		took_damage_first_time()
	elif GLOBALS.proportional_health <= 0:
		dead()

func took_damage_first_time() -> void:
	has_taken_damage = true
	await get_tree().create_timer(0.35,true,false,true).timeout
	await stop_time(1)
	await display_message_box(
		"""Well well, looks like [wave amp=50.0 freq=5.0 connected=1]someone[/wave] took some [shake rate=20.0 level=5 connected=1]damage[/shake] for the first time!

[tornado radius=5.0 freq=1.0 connected=1]You must be bad at video games.[/tornado]

Good luck out there, baka desu.""",
	"wow okay :(",
	2
	)
	#await get_tree().create_timer(0.25,true,false,true).timeout
	await start_time(1)

func dead() -> void:
	await stop_time(1)
	await display_message_box(
		"Dead hours
washed gang gang
no health? :/",
	"damn, guess I'll try again",
	2
	)
	await start_time(1)
	_on_restart_game.emit()
	get_tree().reload_current_scene()
	


func win() -> void:
	await stop_time(1)
	await display_message_box(
		"A winner is you!
Take this into your life
no gods, no masters",
	"please sir, may I have another?",
	2
	)
	await start_time(1)
	_on_restart_game.emit()
	get_tree().reload_current_scene()


func lose() -> void:
	await stop_time(1)
	await display_message_box(
		"You ran out of time like a dingus! Authorities blasted you away from orbit.",
	"scoop me up and try again",
	2
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
	$UIHolder/MessageBox/VBoxContainer/RTL_Button.self_modulate = Color.WHITE
	await $UIHolder/MessageBox/VBoxContainer/RTL_Button.pressed
	$UIHolder/MessageBox/VBoxContainer/RTL_Button.self_modulate = Color.TRANSPARENT
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
