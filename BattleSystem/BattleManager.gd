extends Node

@onready var target_menu_panel: PanelContainer = $BattleUI/MarginContainer/CommandConsolePanel/TargetMenuPanel
@onready var target_list: VBoxContainer = $BattleUI/MarginContainer/CommandConsolePanel/TargetMenuPanel/TargetList

@onready var screen_flash_overlay: ColorRect = $BattleUI/ScreenFlashOverlay

@onready var text_window_panel: PanelContainer = $BattleUI/TextWindowPanel
@onready var battle_text_label: RichTextLabel = $BattleUI/TextWindowPanel/MarginContainer/BattleTextLabel

@export var text_speed: float = 0.03

@onready var party_stats_panel: PanelContainer = $BattleUI/MarginContainer/CommandConsolePanel/HBoxContainer/PartyStatsPanel
@onready var action_menu_panel: PanelContainer = $BattleUI/MarginContainer/CommandConsolePanel/HBoxContainer/ActionMenuPanel
@onready var attack_button: Button = $BattleUI/MarginContainer/CommandConsolePanel/HBoxContainer/ActionMenuPanel/VBoxContainer/AttackButton
@onready var defend_button: Button = $BattleUI/MarginContainer/CommandConsolePanel/HBoxContainer/ActionMenuPanel/VBoxContainer/DefendButton
@onready var run_button: Button = $BattleUI/MarginContainer/CommandConsolePanel/HBoxContainer/ActionMenuPanel/VBoxContainer/RunButton
@onready var hp_bar: ProgressBar = $BattleUI/MarginContainer/CommandConsolePanel/HBoxContainer/PartyStatsPanel/StatsList/HBoxContainer/HPBar

@export var click_sound: AudioStream

enum BattleState { START, PLAYER_TURN, ENEMY_TURN, WIN, LOSE }
var current_state: BattleState = BattleState.START

var party: Array[Fighter] = []
var enemies: Array[Fighter] = []
var turn_queue: Array[Fighter] = []
var current_fighter: Fighter

var default_font = load("res://BattleSystem/BattleSystemArt/UI/neatpixels-standard2.ttf")

var new_stylebox := StyleBoxTexture.new()
var pressed_stylebox: StyleBoxTexture
var hover_stylebox: StyleBoxTexture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	attack_button.pressed.connect(_on_attack_button_pressed)
	defend_button.pressed.connect(_on_defend_button_pressed)
	run_button.pressed.connect(_on_run_button_pressed)
	
	new_stylebox.texture = preload("res://BattleSystem/BattleSystemArt/UI/Menu Buttons 18.png")
	
	new_stylebox.texture_margin_left = 8.0
	new_stylebox.texture_margin_right = 8.0
	new_stylebox.texture_margin_top = 9.0
	new_stylebox.texture_margin_bottom = 8.0
	
	pressed_stylebox = new_stylebox.duplicate()
	pressed_stylebox.modulate_color = Color(1, 1, 1, 0.5)
	
	hover_stylebox = new_stylebox.duplicate()
	hover_stylebox.modulate_color = Color(1, 1, 1, 0.25)
	
	gather_fighters()
	create_turn_queue()
	advance_turn()
	
func gather_fighters() -> void:
	for child in get_children():
		if child is Fighter:
			if child.is_in_group("Party"):
				party.append(child)
				child.current_hp = GlobalGameManager.player_current_hp
				child.max_hp = GlobalGameManager.player_max_hp
				child.speed = GlobalGameManager.player_speed
			elif child.is_in_group("Enemies"):
				enemies.append(child)
	
	if enemies.size() > 0 and has_node("EnemySpawnPoint"):
		var first_enemy = enemies[0]
		if is_instance_valid(first_enemy):
			first_enemy.global_position = $EnemySpawnPoint.global_position
			
	
func create_turn_queue() -> void:
	turn_queue.clear()
	
	var all_fighters: Array[Fighter] = []
	all_fighters.append_array(party)
	all_fighters.append_array(enemies)
	
	all_fighters.sort_custom(func(a: Fighter, b: Fighter):
		return a.speed > b.speed)
		
	turn_queue = all_fighters
	
func advance_turn() -> void:
	clean_dead_fighters_from_queue()
	
	if enemies.is_empty():
		end_battle(BattleState.WIN)
		return
	if party.is_empty():
		end_battle(BattleState.LOSE)
		return
	
	if turn_queue.is_empty():
		create_turn_queue()
	
	current_fighter = turn_queue.pop_front()
	
	if is_instance_valid(current_fighter):
		current_fighter.is_defending = false
	
	if current_fighter in party:
		current_state = BattleState.PLAYER_TURN
		await display_message("It is " + current_fighter.fighter_name + "'s turn!")
		show_player_ui()
	else:
		current_state = BattleState.ENEMY_TURN
		await display_message("It is " +current_fighter.fighter_name + "'s turn!")
		execute_enemy_ai()
		
func execute_enemy_ai() -> void:
	if enemies.is_empty() or not is_instance_valid(current_fighter):
		return
		
	if party.is_empty(): 
		return
	
	var target = party[0]
	
	await display_message(current_fighter.fighter_name + " lunges forward and attacks " + target.fighter_name + "!")
	trigger_screen_flash()
	target.take_damage(15)
	
	await get_tree().create_timer(1.0).timeout
	advance_turn()
	
func trigger_screen_flash() -> void:
	if not screen_flash_overlay:
		return
	var flash_tween = create_tween()
	screen_flash_overlay.modulate.a = 0.6
	flash_tween.tween_property(screen_flash_overlay, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
func clean_dead_fighters_from_queue() -> void:
	turn_queue = turn_queue.filter(func(f): return is_instance_valid(f))	
	party = party.filter(func(f): return is_instance_valid(f))
	enemies = enemies.filter(func(f): return is_instance_valid(f))
	
func show_player_ui() -> void:
	target_menu_panel.hide()
	action_menu_panel.show()
	if is_instance_valid(current_fighter):
		hp_bar.value = current_fighter.current_hp
		hp_bar.max_value = current_fighter.max_hp
		party_stats_panel.show()
	
func hide_player_ui() -> void:
	action_menu_panel.hide()
	party_stats_panel.hide()
	
func end_battle(result: BattleState) -> void:
	if result == BattleState.WIN:
		await display_message("Victory!")
		if party.size() > 0 and is_instance_valid(party[0]):
			GlobalGameManager.player_current_hp = party[0].current_hp
			
			get_tree().change_scene_to_file("res://WorldMap/WorldMap.tscn")
	else:
		await display_message("Defeat...")
		get_tree().change_scene_to_file("res://MainMenu/MainMenu.tscn")

func initialize_battle() -> void:
	current_state = BattleState.PLAYER_TURN
		
func _on_attack_button_pressed() -> void:
	if current_state != BattleState.PLAYER_TURN:
		return
	
	play_click_sound()
	
	action_menu_panel.hide()
	party_stats_panel.hide()
	populate_target_menu()

	if enemies.is_empty(): return
	var target = enemies[0]

func _on_defend_button_pressed() -> void:
	if current_state != BattleState.PLAYER_TURN:
		return
	
	play_click_sound()
	
	hide_player_ui()
	current_fighter.is_defending = true
	
	await display_message(current_fighter.fighter_name + " braces themselves against the attack!")
	advance_turn()
	
func _on_run_button_pressed() -> void:
	if current_state != BattleState.PLAYER_TURN:
		return
	
	play_click_sound()
	
	hide_player_ui()
	await display_message(current_fighter.fighter_name + " tries to escape...")
	if randf() < 0.50:
		await display_message("Escaped safely!")
		if party.size() > 0 and is_instance_valid(party[0]):
			GlobalGameManager.player_current_hp = party[0].current_hp
		get_tree().change_scene_to_file("res://WorldMap/WorldMap.tscn")
	else:
		await display_message("Can't escape!")
		advance_turn()
	
func populate_target_menu() -> void:
	for child in target_list.get_children():
		child.queue_free()
	
	target_menu_panel.show()
	
	for enemy in enemies:
		if is_instance_valid(enemy):
			var btn = Button.new()
			btn.text = enemy.fighter_name
			btn.add_theme_stylebox_override("normal", new_stylebox)
			btn.add_theme_font_override("font", default_font)
			btn.add_theme_stylebox_override("pressed", pressed_stylebox)
			btn.add_theme_stylebox_override("hover", hover_stylebox)
			btn.pressed.connect(func(): _on_target_selected(enemy))
			
			target_list.add_child(btn)
			
	var back_btn = Button.new()
	back_btn.text = "< Cancel"
	back_btn.add_theme_stylebox_override("normal", new_stylebox)
	back_btn.add_theme_font_override("font", default_font)
	back_btn.add_theme_stylebox_override("pressed", pressed_stylebox)
	back_btn.add_theme_stylebox_override("hover", hover_stylebox)
	back_btn.pressed.connect(cancel_target_selection)
	target_list.add_child(back_btn)
	
func _on_target_selected(target: Fighter) -> void:
	play_click_sound()
	target_menu_panel.hide()
	
	await display_message(current_fighter.fighter_name + " attacks " + target.fighter_name + "!")
	
	target.take_damage(25)
	
	await get_tree().process_frame
	
	advance_turn()
	
func cancel_target_selection() -> void:
	play_click_sound()
	target_menu_panel.hide()
	action_menu_panel.show()
	party_stats_panel.show()
	
	
func display_message(text: String) -> void:
	text_window_panel.show()
	battle_text_label.text = text
	
	battle_text_label.visible_characters = 0
	
	var tween = 	create_tween()
	var total_chars = text.length()
	var duration = total_chars * text_speed
	
	tween.tween_property(
		battle_text_label,
		"visible_characters",
		total_chars,
		duration
	)

	await tween.finished
	
	await get_tree().create_timer(1.0).timeout
	text_window_panel.hide()

func play_click_sound() -> void:
	if not click_sound:
		return
	
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = click_sound
	audio_player.bus = "SFX"
	get_parent().add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(audio_player.queue_free)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
