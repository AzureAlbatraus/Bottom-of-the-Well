extends Node

@onready var target_menu_panel: PanelContainer = $BattleUI/MarginContainer/HBoxContainer/TargetMenuPanel
@onready var target_list: VBoxContainer = $BattleUI/MarginContainer/HBoxContainer/TargetMenuPanel/TargetList

@onready var text_window_panel: PanelContainer = $BattleUI/TextWindowPanel
@onready var battle_text_label: RichTextLabel = $BattleUI/TextWindowPanel/MarginContainer/BattleTextLabel

@export var text_speed: float = 0.03

@onready var action_menu_panel: PanelContainer = $BattleUI/MarginContainer/HBoxContainer/ActionMenuPanel
@onready var attack_button: Button = $BattleUI/MarginContainer/HBoxContainer/ActionMenuPanel/VBoxContainer/AttackButton
@onready var defend_button: Button = $BattleUI/MarginContainer/HBoxContainer/ActionMenuPanel/VBoxContainer/DefendButton
@onready var run_button: Button = $BattleUI/MarginContainer/HBoxContainer/ActionMenuPanel/VBoxContainer/RunButton
@onready var hp_bar: ProgressBar = $BattleUI/MarginContainer/HBoxContainer/PartyStatsPanel/StatsList/HBoxContainer/HPBar

enum BattleState { START, PLAYER_TURN, ENEMY_TURN, WIN, LOSE }
var current_state: BattleState = BattleState.START

var party: Array[Fighter] = []
var enemies: Array[Fighter] = []
var turn_queue: Array[Fighter] = []
var current_fighter: Fighter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	attack_button.pressed.connect(_on_attack_button_pressed)
	defend_button.pressed.connect(_on_defend_button_pressed)
	run_button.pressed.connect(_on_run_button_pressed)
	
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
	target.take_damage(15)
	
	await get_tree().create_timer(1.0).timeout
	advance_turn()
	
func clean_dead_fighters_from_queue() -> void:
	turn_queue = turn_queue.filter(func(f): return is_instance_valid(f))	
	party = party.filter(func(f): return is_instance_valid(f))
	enemies = enemies.filter(func(f): return is_instance_valid(f))
	
func show_player_ui() -> void:
	target_menu_panel.hide()
	action_menu_panel.show()
	hp_bar.value = current_fighter.current_hp
	hp_bar.max_value = current_fighter.max_hp
	
func hide_player_ui() -> void:
	action_menu_panel.hide()
	
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

	action_menu_panel.hide()
	populate_target_menu()

	if enemies.is_empty(): return
	var target = enemies[0]

func _on_defend_button_pressed() -> void:
	if current_state != BattleState.PLAYER_TURN:
		return
	
	hide_player_ui()
	current_fighter.is_defending = true
	
	await display_message(current_fighter.fighter_name + " braces themselves against the attack!")
	advance_turn()
	
func _on_run_button_pressed() -> void:
	if current_state != BattleState.PLAYER_TURN:
		return
	
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
			
			btn.pressed.connect(func(): _on_target_selected(enemy))
			
			target_list.add_child(btn)
			
	var back_btn = Button.new()
	back_btn.text = "< Cancel"
	back_btn.pressed.connect(cancel_target_selection)
	target_list.add_child(back_btn)
	
func _on_target_selected(target: Fighter) -> void:
	target_menu_panel.hide()
	
	await display_message(current_fighter.fighter_name + " attacks " + target.fighter_name + "!")
	
	target.take_damage(25)
	
	await get_tree().process_frame
	
	advance_turn()
	
func cancel_target_selection() -> void:
	target_menu_panel.hide()
	action_menu_panel.show()
	
	
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
