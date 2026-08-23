extends CharacterBody2D

@export var tilemap_layer: TileMapLayer
@export var battle_scene_path: String = "res://BattleSystem/BattleScene.tscn"
@export var encounter_chance: float = 0.15 

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D

var facing_direction: Vector2:
	get:
		return last_direction
	set(value):
		last_direction = value

var last_direction : Vector2 = Vector2.DOWN
var is_moving: bool = false

var input_queue: Array[String] = []

const inputs = {
	"move_down": Vector2.DOWN,
	"move_up": Vector2.UP,
	"move_left": Vector2.LEFT,
	"move_right": Vector2.RIGHT
}

var grid_size = 16
@export var walk_speed: float = 4.0
@export var terrain_speed_multiplier: float = 0.5
	
func _ready() -> void:
	
	if GlobalGameManager.coming_from_battle:
		input_queue.clear()
		is_moving = false
		last_direction = GlobalGameManager.player_last_direction
		global_position = GlobalGameManager.player_overworld_position
		force_update_transform()
	else:
		position = position.snapped(Vector2(grid_size, grid_size))
		
	if has_node("Camera2D"):
		$Camera2D.reset_smoothing()

func _physics_process(_delta: float) -> void:
	if is_moving:
		return
		
	var active_action = get_active_input()
	
	if active_action != "":
		move(active_action)
	else:
		play_idle_animation(last_direction)

func _unhandled_input(event: InputEvent) -> void:

	for action in inputs.keys():
		if event.is_action_pressed(action):
			if not input_queue.has(action):
				input_queue.push_back(action)
		elif event.is_action_released(action):
			input_queue.erase(action)
			
func get_active_input() -> String:
	while input_queue.size() > 0:
		var action = input_queue.back()
		if Input.is_action_pressed(action):
			return action
		else:
			input_queue.pop_back()
	return ""
			
func move(action: String) -> void:
	var move_dir = inputs[action]
	last_direction = move_dir
	
	var destination = move_dir * grid_size
	ray_cast_2d.target_position = destination
	ray_cast_2d.force_raycast_update()
	
	if not ray_cast_2d.is_colliding():
		is_moving = true
		
		play_walk_animation(move_dir)
		
		var target_position = position + destination
		
		var step_duration = 1.0 / walk_speed
		
		if tilemap_layer:
			var target_local = tilemap_layer.to_local(global_position + destination)
			var target_map_coord = tilemap_layer.local_to_map(target_local)
			var next_tile_data = tilemap_layer.get_cell_tile_data(target_map_coord)
			
			if next_tile_data:
				var is_next_tile_terrain = next_tile_data.get_custom_data("is_terrain")
				if is_next_tile_terrain:
					step_duration = 1.0 / (walk_speed * terrain_speed_multiplier)
		
		var tween = create_tween()
		
		tween.tween_property(self, "position", target_position, step_duration).set_trans(Tween.TRANS_LINEAR)
		
		tween.finished.connect(func(): 
			is_moving = false
			check_for_encounter()
		)
	else:
		play_idle_animation(last_direction)
		
func play_walk_animation(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		animation_player.play("Walking_right" if dir.x > 0 else "Walking_left")
	else:
		animation_player.play("Walking_down" if dir.y >0 else "Walking_up")

func play_idle_animation(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		animation_player.play("Idle_right" if dir.x > 0 else "Idle_left")
	else:
		animation_player.play("Idle_down" if dir.y > 0 else "Idle_up")
		
func set_facing_direction(dir: Vector2):
	last_direction = dir
	position = position.snapped(Vector2(grid_size, grid_size))
	play_idle_animation(last_direction)

func check_for_encounter() -> void:
	if not tilemap_layer: 
		return

	var local_pos = tilemap_layer.to_local(global_position)
	var map_coord = tilemap_layer.local_to_map(local_pos)
	
	var cell_source_id = tilemap_layer.get_cell_source_id(map_coord)
	if cell_source_id == -1:
		return

	var tile_data = tilemap_layer.get_cell_tile_data(map_coord)
	if tile_data:
		var stands_in_forest = tile_data.get_custom_data("is_forest")
		
		if stands_in_forest:
			var roll = randf()
			if roll < encounter_chance:
				trigger_battle()
				
func trigger_battle() -> void:
	print("Entering Combat!")
	
	GlobalGameManager.player_last_direction = last_direction
	GlobalGameManager.player_overworld_position = global_position
	GlobalGameManager.coming_from_battle = true
	
	get_tree().change_scene_to_file("res://BattleSystem/Battle.tscn")
			
			
			
			
