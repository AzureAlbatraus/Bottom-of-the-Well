extends Node

var player_overworld_position: Vector2 = Vector2.ZERO
var player_last_direction: Vector2 = Vector2.ZERO
var player_current_hp: int = 100
var player_max_hp: int = 100
var player_speed: int = 15

var coming_from_battle: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
