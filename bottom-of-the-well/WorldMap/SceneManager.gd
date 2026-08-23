extends Node

var target_spawn_position: Vector2 = Vector2.ZERO
var last_facing_direction: Vector2 = Vector2.DOWN

func change_scene_by_marker(scene_path: String, marker_name: String, current_facing: Vector2):
	
	last_facing_direction = current_facing
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	var color_rect = ColorRect.new()
	color_rect.color = Color.BLACK
	color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	color_rect.modulate.a = 0.0
	
	canvas_layer.add_child(color_rect)
	get_tree().root.add_child(canvas_layer)
	
	var tween_in = create_tween()
	tween_in.tween_property(color_rect, "modulate:a", 1.0, 0.4)
	await tween_in.finished
	
	get_tree().change_scene_to_file(scene_path)
	
	await get_tree().tree_changed
	
	var current_scene = get_tree().current_scene
	if current_scene == null:
		current_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
		
	var marker = current_scene.find_child(marker_name, true, false)
	
	if marker is Marker2D:
		target_spawn_position = marker.global_position
		var player = current_scene.find_child("Player", true, false)
		if player:
			player.global_position = target_spawn_position
			if player.has_method("set_facing_direction"):
				player.set_facing_direction(last_facing_direction)
			else:
				print("Warning: Player script missing 'set_facing_direction!")
		else:
			print("Warning: Player node not found in the new scene tree!")
	else:
		print("Warning: Marker 2D named '", marker_name, "' not found!")
	
	
	var tween_out = create_tween()
	tween_out.tween_property(color_rect, "modulate:a", 0.0, 0.4)
	await tween_out.finished
	
	canvas_layer.queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
