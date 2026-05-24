class_name Notification extends Area2D

@onready var notification_audio_player: AudioStreamPlayer = $NotificationAudioPlayer


@export var screen_edge : Vector2 = Vector2(310,260)

@export var minimum_alpha_distance : float = 6000
@export var maximum_alpha_distance : float = 4000
@export var minimum_scale_distance : float = 3000
@export var maximum_scale_distance : float = 200
@export var disappear_start_distance : float = 400
@export var disappear_end_distance : float = 200


@export_category("READ ONLY")

@export var target_position : Vector2 = Vector2(460,460)
@export var is_tracking : bool = false
@export var is_hovered : bool = false

var station : Station = null

var portait : Texture2D = null
var audio_median_pitch : float = 0.85

var dialogue_message : String = ""

var rewards : Array

var awaiting_reward : bool = false

#func _ready() -> void:
	#tracking(get_tree().get_first_node_in_group("Stations"))


func tracking(_node:Node2D) -> void:
	var _minimum_alpha_sqr_distance : float = minimum_alpha_distance * minimum_alpha_distance
	var _maximum_alpha_sqr_distance : float = maximum_alpha_distance * maximum_alpha_distance
	var _minimum_scale_sqr_distance : float = minimum_scale_distance * minimum_scale_distance
	var _maximum_scale_sqr_distance : float = maximum_scale_distance * maximum_scale_distance
	var _disappear_start_sqr_distance : float = disappear_start_distance * disappear_start_distance
	var _disappear_end_sqr_distance : float = disappear_end_distance * disappear_end_distance
	
	target_position = _node.global_position # LevelManager.instance.to_local(get_tree().get_first_node_in_group("Stations").global_position)
	
	var _camera : Camera2D = $"../../Ship/Camera2D"
	var _camera_pos : Vector2
	var _distance : float
	
	is_tracking = true
	visible = true
	while(is_tracking):
		_camera_pos = _camera.get_screen_center_position()
		
		$Arrow.look_at(target_position)
		
		#if is_hovered:
			##$SpriteIcon.modulate = Color(1,1,1,1)
			##scale = Vector2(1.312,1.312)
			#if _distance < _disappear_start_sqr_distance:
				#global_position = target_position
			#else:
				#global_position = target_position.clamp(_camera_pos-screen_edge + (scale * 40), _camera_pos+screen_edge - (scale * 40))
		#
		#else:
		_distance = _camera_pos.distance_squared_to(target_position)
		
		if _distance < _disappear_start_sqr_distance:
			$Arrow.visible = false
			$SpriteIcon.modulate = Color(1,1,1,0.9) if !is_hovered else Color(1,1,1,1)
			scale = Vector2.ONE * (1.1 if is_hovered else 1.0)
			global_position = target_position
		else:
			$Arrow.visible = true
			if _distance > _minimum_alpha_sqr_distance:
				$SpriteIcon.modulate = Color(1,1,1,0.25) if !is_hovered else Color(1,1,1,1)
			else:
				$SpriteIcon.modulate = Color(1,1,1,clamp(remap(_distance,_minimum_alpha_sqr_distance,_maximum_alpha_sqr_distance,0.25,0.9),0.25,0.9)) if !is_hovered else Color(1,1,1,1)
			
			if _distance > _minimum_scale_sqr_distance:
				scale = Vector2(0.69,0.69) * (1.1 if is_hovered else 1.0)
			else:
				scale = Vector2.ONE * clamp(remap(_distance,_maximum_scale_sqr_distance,_minimum_scale_sqr_distance,1.2,0.69),0.69,1.2) * (1.1 if is_hovered else 1.0)
			
			var clamped : Vector2 = (_camera_pos + (target_position - _camera_pos)) #  .direction_to(target_position) * 500)
			clamped = Vector2(clamp(clamped.x,_camera_pos.x - screen_edge.x + (scale.x * 40),_camera_pos.x + screen_edge.x - (scale.x * 40)),clamp(clamped.y,_camera_pos.y - screen_edge.y + (scale.x * 40),_camera_pos.y + screen_edge.y - (scale.y * 40)))
			
			global_position = clamped # (_camera_pos + _camera_pos.direction_to(target_position) * 400) #.clamp(_camera_pos-screen_edge + (scale * 40), _camera_pos+screen_edge - (scale * 40))  # target_position.clamp(_camera_pos-screen_edge + (scale * 40), _camera_pos+screen_edge - (scale * 40))
		
		
		await get_tree().physics_frame
		
		if !is_inside_tree(): break


func define_rewards(_node:Node2D) -> void:
	
	rewards = NotificationManager.RewardType.values()
	rewards.remove_at(randi() % rewards.size())


func stop() -> void:
	is_tracking = false
	visible = false


func finish(_node:Node2D) -> void:
	stop()
	notification_audio_player.play()
	
	var _current_message = "Thank you comrade! Please let us help you with something in turn..." # dialogue_message % ("[color=7dcfff]" + str(station.order_number) + " " + str(InventoryManager.ItemType.keys()[station.order_type]) + ("s" if station.order_number > 1 else "") + "[/color]")
	
	var _button_1_text : String
	match rewards[0]:
		NotificationManager.RewardType.REPAIR:
			_button_1_text = "Repair your ship"
		NotificationManager.RewardType.DELAY:
			_button_1_text = "run interference"
		NotificationManager.RewardType.RESOURCE:
			_button_1_text = "Restock supplies"
	var _button_2_text : String
	match rewards[1]:
		NotificationManager.RewardType.REPAIR:
			_button_2_text = "Repair your ship"
		NotificationManager.RewardType.DELAY:
			_button_2_text = "run interference"
		NotificationManager.RewardType.RESOURCE:
			_button_2_text = "Restock supplies"
	
	awaiting_reward = true
	
	DialogueManager.display_dialogue_box(_current_message,_button_1_text,_button_2_text,portait,true,true,30,audio_median_pitch)
	DialogueManager.on_dialogue_choice().connect(on_choose_reward,CONNECT_ONE_SHOT)
	
	#match station.order_type:
		#InventoryManager.ItemType.Rock:
			#_possible_rewards.remove_at(_possible_rewards.find(NotificationManager.RewardType.ROCKS))
		#InventoryManager.ItemType.Crate:
			#_possible_rewards.remove_at(_possible_rewards.find(NotificationManager.RewardType.CRATES))
		#InventoryManager.ItemType.Pipe:
			#_possible_rewards.remove_at(_possible_rewards.find(NotificationManager.RewardType.PIPES))
	#
	#_new_notification.rewards = []

func on_choose_reward(reward_index:int) -> void:
	
	match rewards[reward_index]:
		NotificationManager.RewardType.REPAIR:
			for i in station.prosperity:
				GLOBALS.health += 3
		
		NotificationManager.RewardType.DELAY:
			for i in station.prosperity:
				CountdownManager.adjust_countdown(-45)
		
		NotificationManager.RewardType.RESOURCE:
			match station.order_type:
				InventoryManager.ItemType.Rock:
					for i in station.prosperity:
						if randi() % 2:
							#InventoryManager.add_item(InventoryManager.ItemType.Crate)
							InventoryManager.add_item(InventoryManager.ItemType.Crate)
						else:
							#InventoryManager.add_item(InventoryManager.ItemType.Pipe)
							InventoryManager.add_item(InventoryManager.ItemType.Pipe)
							InventoryManager.add_item(InventoryManager.ItemType.Pipe)
				InventoryManager.ItemType.Crate:
					for i in station.prosperity:
						if randi() % 2:
							#InventoryManager.add_item(InventoryManager.ItemType.Rock)
							InventoryManager.add_item(InventoryManager.ItemType.Rock)
							InventoryManager.add_item(InventoryManager.ItemType.Rock)
							InventoryManager.add_item(InventoryManager.ItemType.Rock)
						else:
							#InventoryManager.add_item(InventoryManager.ItemType.Pipe)
							InventoryManager.add_item(InventoryManager.ItemType.Pipe)
							InventoryManager.add_item(InventoryManager.ItemType.Pipe)
				InventoryManager.ItemType.Pipe:
					for i in station.prosperity:
						if randi() % 2:
							#InventoryManager.add_item(InventoryManager.ItemType.Rock)
							InventoryManager.add_item(InventoryManager.ItemType.Rock)
							InventoryManager.add_item(InventoryManager.ItemType.Rock)
							InventoryManager.add_item(InventoryManager.ItemType.Rock)
						else:
							#InventoryManager.add_item(InventoryManager.ItemType.Crate)
							InventoryManager.add_item(InventoryManager.ItemType.Crate)



func _on_mouse_entered() -> void:
	is_hovered = true


func _on_mouse_exited() -> void:
	is_hovered = false


func create_dialogue_message(_node:Node2D) -> void:
	if randi() % 2:
		dialogue_message = NotificationManager.pop_random_flavour_option() + " " + NotificationManager.pop_random_order_option()
	else:
		dialogue_message = NotificationManager.pop_random_order_option() + " " + NotificationManager.pop_random_flavour_option()


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton && Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		
		notification_audio_player.play()
		
		var _current_message = dialogue_message % ("[color=7dcfff]" + str(station.order_number) + " " + str(InventoryManager.ItemType.keys()[station.order_type]) + ("s" if station.order_number > 1 else "") + "[/color]")
		
		DialogueManager.display_dialogue_box(_current_message,NotificationManager.random_button_option(),"",portait,true,true,30,audio_median_pitch)
