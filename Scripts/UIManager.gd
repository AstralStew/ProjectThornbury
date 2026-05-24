class_name UIManager extends CanvasLayer
const DEBUG_NAME = "[b][UIManager][/b] "
static var instance : UIManager = null

@onready var ui_holder : Control = $UIHolder
@onready var border : Control = $UIHolder/Border
@onready var msg_bg_overlay : Control = $UIHolder/MessageBgOverlay
@onready var prosperity_bar : ProgressBar =  $UIHolder/MC_ScreenHolders/HB_ScreenHolders/LeftScreen/PanelContainer/ProsperityBar #$UIHolder/MC_ScreenHolders/HB_ScreenHolders/LeftScreen/PanelContainer/TopBar/ProsperityBar

@export var progress_colour : Gradient

static var is_time_stopped : bool = false

static var has_taken_damage : bool = false # don't reset this on restart!

signal _on_restart_game
static func on_restart_game() -> Signal: return instance._on_restart_game

#static var _first_run : bool = true
static var seen_opening_tutorial : bool = false



func _enter_tree() -> void:
	instance = self
	
	on_restart_game().connect(GLOBALS.restart_game)

func _ready() -> void:
	GLOBALS.on_health_changed().connect(took_damage)
	LevelManager.on_prosperity_updated().connect(update_prosperity)
	
	Ship.on_took_damage().connect(jolt)
	
	
	$UIHolder/DialogueBox.visible = true
	await get_tree().process_frame
	$UIHolder/DialogueBox.visible = false
	await get_tree().process_frame
	$UIHolder/DialogueBox.modulate = Color.WHITE
	
	if GLOBALS.skip_everything:
		IntroManager.remove()
		msg_bg_overlay.visible = false
		msg_bg_overlay.modulate = Color(1,1,1,0)
		_start_time()
		return
	
	_stop_time()
	
	#if _first_run: first_run()
	
	if !GLOBALS.game_started:
		opening()
	else:
		IntroManager.remove()
		msg_bg_overlay.visible = false
		msg_bg_overlay.modulate = Color(1,1,1,0)
		_start_time()
		
	
#
#func first_run() -> void:
	#_first_run = false
	#await get_tree().create_timer(0.5).timeout
	#_on_restart_game.emit()
	#get_tree().reload_current_scene()

func opening() -> void:
	#_stop_time()
	await GLOBALS.on_game_started()
	_start_time(2)
	
	if !seen_opening_tutorial: opening_tutorial()



func update_prosperity(value:float) -> void:
	
	print_rich(DEBUG_NAME,"Ready > Updating prosperity to " + str(value * 100))
	prosperity_bar.value = value * 100
	prosperity_bar.modulate = progress_colour.sample(value)
	
	if value >= 1:
		await get_tree().create_timer(1.0,false,false,false).timeout
		win()



static func start_time(fade:=0.0,affect_bg:bool=true) -> void:
	await instance._start_time(fade)

func _start_time(fade:=0.0,affect_bg:bool=true) -> void:
	get_tree().paused = false
	if fade:
		if affect_bg: msg_bg_overlay.visible = true
		#msg_bg_overlay.modulate = Color(1,1,1,0.3)
		Engine.time_scale = 0.0
		var _tween:Tween = create_tween().set_ignore_time_scale().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		_tween.tween_property(Engine,"time_scale",1,fade)
		if affect_bg: _tween.tween_property(msg_bg_overlay,"modulate", Color(1,1,1,0),fade)
		await get_tree().create_timer(fade,true,false,true).timeout
		await get_tree().process_frame
		Engine.time_scale = 1.0
	if affect_bg: msg_bg_overlay.visible = false
	is_time_stopped = false


static func stop_time(fade:=0.0,affect_bg:bool=true) -> void:
	await instance._stop_time(fade)

func _stop_time(fade:=0.0,affect_bg:bool=true) -> void:
	msg_bg_overlay.visible = true
	if fade:
		#msg_bg_overlay.modulate = Color(1,1,1,0)
		Engine.time_scale = 1.0
		var _tween:Tween = create_tween().set_ignore_time_scale().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		_tween.tween_property(Engine,"time_scale",0,fade)
		if affect_bg: _tween.tween_property(msg_bg_overlay,"modulate", Color(1,1,1,0.3),fade)
		await get_tree().create_timer(fade,true,false,true).timeout
		await get_tree().process_frame
		Engine.time_scale = 1.0
		if affect_bg: msg_bg_overlay.modulate = Color(1,1,1,0.3)
	get_tree().paused = true
	is_time_stopped = true


#region Events

#[wave amp=50.0 freq=5.0 connected=1]someone[/wave]
#[tornado radius=5.0 freq=1.0 connected=1]You must be bad at video games.[/tornado]



func opening_tutorial() -> void:
	seen_opening_tutorial = true
	await get_tree().create_timer(0.35,true,false,true).timeout
	await _stop_time(1)
	await display_message_box(
		"""wasd to fly
hold spacebar to take/drop items you pass over

click the [color=cyan]station icons[/color] to find out what they need
click + drag items in cargo bay to move them around

drop the right items on stations to raise community
you have 10 mins until the capital ships arrive""",
	"Let's get to work!",
	4
	)
	#await get_tree().create_timer(0.25,true,false,true).timeout
	await _start_time(1)




func took_damage() -> void:
	if !has_taken_damage:
		took_damage_first_time()
	elif GLOBALS.proportional_health <= 0:
		dead()

func took_damage_first_time() -> void:
	has_taken_damage = true
	if GLOBALS.skip_everything: return
	
	await get_tree().create_timer(0.35,true,false,true).timeout
	await _stop_time(1)
	await display_message_box(
		"""You just took a hit of [shake rate=20.0 level=5 connected=1][color=red] Damage [/color][/shake] for the first time!
		
		Whether you take damage depends on how fast you are moving. You can take a total of  [color=cyan]%s hits[/color]  before your ship is destroyed.\nPay attention to how your hangar bay is looking.

Good luck & fly safe!""" % GLOBALS.SHIP_MAX_HEALTH,
	NotificationManager.random_button_option(),
	4
	)
	#await get_tree().create_timer(0.25,true,false,true).timeout
	await _start_time(1)


func was_scanned_first_time() -> void:
	if GLOBALS.skip_everything: return
	
	await get_tree().create_timer(0.35,true,false,true).timeout
	await _stop_time(1)
	await display_message_box(
		"""You just got [wave amp=50.0 freq=5.0 connected=1][color=yellow] Scanned [/color][/wave] for the first time!
		
		Haulers will scan your cargo when you get close.\nMove all items out of the zone to quietly [color=green]pass[/color] the scan.\n If any of your cargo is [color=red]found[/color], your bounty will increase and the Capital ship will arrive sooner.

Keep it secret! Keep it safe!""",
	NotificationManager.random_button_option(),
	4
	)
	#await get_tree().create_timer(0.25,true,false,true).timeout
	await _start_time(1)




func dead() -> void:
	await _stop_time(1,false)
	
	var _tween:Tween = create_tween().set_ignore_time_scale().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(msg_bg_overlay,"modulate", Color(1,1,1,1),4)
	
	await display_message_box(
		"[tornado radius=3.0 freq=1.0 connected=1]Although the skimmer was destroyed, the people hold your sacrifice in their memories.[/tornado]\n\nYour final bounty on this planet was [color=yellow]%s credits![/color]" % BountyManager.current_bounty,
	"We can do better!",
	4
	)
	await _start_time(1,false)
	_on_restart_game.emit()
	get_tree().reload_current_scene()
	


func win() -> void:
	
	await _stop_time(1,false)
	
	var _tween:Tween = create_tween().set_ignore_time_scale().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(msg_bg_overlay,"modulate", Color(1,1,1,1),4)
	
	await display_message_box(
		"[font_size=50][rainbow freq=0.1 sat=0.69 val=1 speed=0.5]C o n g r a t u l a t i o n s ![/rainbow][/font_size]\n\nYour community pulled together against all odds to\nthrow off the yoke of those Capital ships once and for all!\n\nYour final bounty at time of freedom was [color=yellow]%s credits![/color]" % BountyManager.current_bounty,
	"Can you beat your score?",
	4
	)
	await _start_time(1,false)
	_on_restart_game.emit()
	get_tree().reload_current_scene()


func lose() -> void:
	await _stop_time(0.5,false)
	
	var _tween:Tween = create_tween().set_ignore_time_scale().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(msg_bg_overlay,"modulate", Color(1,1,1,1),3)
	
	await display_message_box( 
		"[shake rate=10.0 level=3 connected=1]The capital ship arrived to obliterate your skimmer and your community from the safety of orbit.[/shake]\n\nYour final bounty on this planet was [color=yellow]%s credits![/color]" % BountyManager.current_bounty,
	"They can't keep getting away with this!",
	2
	)
	await _start_time(1,false)
	_on_restart_game.emit()
	get_tree().reload_current_scene()
	


#endregion


func display_message_box(message_text:="",button_text:="OK",min_time:=0.0,box_size:Vector2=Vector2(700,300)) -> void:
	$UIHolder/MessageBox.visible = true
	
	$UIHolder/MessageBox.custom_minimum_size = box_size
	$UIHolder/MessageBox/VBoxContainer/RTL_Message.text = message_text
	$UIHolder/MessageBox/VBoxContainer/RTL_Button.text = button_text
	
	#$UIHolder/MessageBox/VBoxContainer/RTL_Button.visible = false
	$UIHolder/MessageBox/VBoxContainer/RTL_Button.self_modulate = Color(Color.WHITE,0)
	
	await get_tree().create_timer(min_time,true,false,true).timeout
	
	#$UIHolder/MessageBox/VBoxContainer/RTL_Button.visible = true
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
