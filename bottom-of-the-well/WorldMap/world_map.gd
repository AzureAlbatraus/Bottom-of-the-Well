extends Node2D

@onready var player = $Player 

# Called when the node enters the scene tree for the first time.
func _ready():
	if GlobalGameManager.coming_from_battle:
		GlobalGameManager.coming_from_battle = false
	elif SceneManager.target_spawn_position != Vector2.ZERO:
		player.global_position = SceneManager.target_spawn_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
