extends Node

var player_overworld_position: Vector2 = Vector2.ZERO
var player_last_direction: Vector2 = Vector2.ZERO
var player_current_hp: int = 100
var player_max_hp: int = 100
var player_current_mp: int = 20
var player_max_mp: int = 20
var player_speed: int = 15

var inventory: Dictionary = {}

var coming_from_battle: bool = false

func add_item(item: ItemData, amount: int = 1) -> void:
	if inventory.has(item):
		inventory[item] += amount
	else:
		inventory[item] = amount
	
func remove_item(item:ItemData, amount: int = 1) -> void:
	if inventory.has(item):
		inventory[item] -= amount
		if inventory [item] <= 0:
			inventory.erase(item)

func heal_player(hp_amount: int, _mp_amount: int = 0) -> void:
	player_current_hp = min(player_max_hp, player_current_hp + hp_amount)
	print("OVERWORLD HEAL: Current player health is now: ", player_current_hp)
	
func restore_player(mp_amount: int, _hp_amount: int = 0) -> void:
	player_current_mp = min(player_max_mp, player_current_mp + mp_amount)
	print("OVERWORLD RESTORE: Current player health is now: ", player_current_mp)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
