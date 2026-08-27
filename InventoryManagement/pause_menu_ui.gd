extends CanvasLayer

@onready var inventory_list: VBoxContainer = $MenuPanel/MarginContainer/VBoxContainer/ScrollContainer/InventoryList
@onready var close_button: Button = $MenuPanel/MarginContainer/VBoxContainer/CloseButton

@export var click_sound: AudioStream

var inventory_font = load("res://InventoryManagement/InventoryArt/neatpixels-standard.ttf")

@export var bag_closed_sound: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_button.pressed.connect(toggle_menu)
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		toggle_menu()
	
	if close_button.button_pressed:
		var audio_player = AudioStreamPlayer2D.new()
		audio_player.stream = click_sound
		audio_player.bus = "SFX"
		get_parent().add_child(audio_player)
		audio_player.play()
		audio_player.finished.connect(audio_player.queue_free)
		
func toggle_menu() -> void:
	
	if DialogueUI and DialogueUI.dialogue_panel.visible:
		return
	if visible:
		play_bag_closed_sound()
		hide()
		get_tree().paused = false
			
	else:
		show()
		get_tree().paused = true
		populate_inventory_view()
			
func populate_inventory_view() -> void:
	for child in inventory_list.get_children():
		child.queue_free()
		
	var active_inv = GlobalGameManager.inventory
	
	if active_inv.is_empty():
		var empty_label = Label.new()
		empty_label.text = "Your pack is completely empty..."
		empty_label.add_theme_font_override("font", inventory_font)
		empty_label.add_theme_font_size_override("font_size", 8)
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		empty_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		empty_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		inventory_list.add_child(empty_label)
		return
	
	for item: ItemData in active_inv.keys():
		var quantity = active_inv[item]
		
		var item_btn = Button.new()
		item_btn.alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT
		item_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var row = HBoxContainer.new()
		
		if item.texture:
			var icon = TextureRect.new()
			icon.texture = item.texture
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.custom_minimum_size = Vector2(16, 16)
			row.add_child(icon)
			
		var item_label = Label.new()
		item_label.text = item.item_name + " x" + str(quantity)
		item_label.add_theme_font_override("font", inventory_font)
		item_label.add_theme_font_size_override("font_size", 8)
		row.add_child(item_label)
		
		item_btn.add_child(row)
		inventory_list.add_child(item_btn)
		
		item_btn.pressed.connect(func():
			if DialogueUI and DialogueUI.dialogue_panel.visible:
				return
			if item.item_name == "Potion":	
				
				if GlobalGameManager.player_current_hp >= GlobalGameManager.player_max_hp:
				
					if DialogueUI:
						DialogueUI.start_dialogue(["Your health is already full!"] as Array[String])
						item_btn.release_focus()
					return
			
				var success_text = "Hero drinks the " + item.item_name + "! Restored " + str(item.hp_restoration) + " HP"
			
				GlobalGameManager.heal_player(item.hp_restoration)
				GlobalGameManager.remove_item(item, 1)
			
				if DialogueUI:
					DialogueUI.start_dialogue([success_text] as Array[String])
					item_btn.release_focus()
				populate_inventory_view()
				return
			
			if item.item_name == "Ether":	
				
				if GlobalGameManager.player_current_mp >= GlobalGameManager.player_max_mp:
				
					if DialogueUI:
						DialogueUI.start_dialogue(["Your mana is already full!"] as Array[String])
						item_btn.release_focus()
					return
			
				var success_text = "Hero drinks the " + item.item_name + "! Restored " + str(item.mp_restoration) + " MP"
			
				GlobalGameManager.heal_player(item.mp_restoration)
				GlobalGameManager.remove_item(item, 1)
			
				if DialogueUI:
					DialogueUI.start_dialogue([success_text] as Array[String])
					item_btn.release_focus()
				populate_inventory_view()
		)
			
		item_btn.mouse_entered.connect(func():
			item_btn.modulate = Color(1.5, 1.5, 1.5, 1)
		)
		
		item_btn.mouse_exited.connect(func():
			item_btn.modulate = Color(1, 1, 1, 1)
		)
func play_bag_closed_sound() -> void:
	if not bag_closed_sound:
		return
	
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = bag_closed_sound
	audio_player.bus = "SFX"
	get_parent().add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(audio_player.queue_free)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
