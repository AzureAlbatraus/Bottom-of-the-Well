extends Area2D

@export_file("*.tscn") var world_map_path: String 

@export var target_marker_name: String

func _on_body_entered(body):
	if body.is_in_group("Player"):
		var current_facing = Vector2.DOWN
		
		if "facing_direction" in body:
			current_facing = body.facing_direction
		elif body.velocity != Vector2.ZERO:
			current_facing = body.velocity.normalized()
			
		SceneManager.change_scene_by_marker(world_map_path, target_marker_name, current_facing)
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
