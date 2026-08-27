extends Resource
class_name ItemData

@export var item_name: String = "Potion"
@export_multiline var description: String = "Restores 50 HP."
@export var texture: Texture2D

enum ItemType { CONSUMABLE, EQUIPMENT, KEY_ITEM }
@export var type: ItemType = ItemType.CONSUMABLE

@export var hp_restoration: int = 50
@export var mp_restoration: int = 0

func use(target: Fighter) -> bool:
	if type == ItemType.CONSUMABLE:
		if target.current_hp >= target.max_hp:
			return false
		
		target.current_hp = min(target.max_hp, target.current_hp + hp_restoration)
		return true
	return false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
