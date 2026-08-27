extends Interactable
class_name ItemPickup

@export var item_to_give: ItemData
@export var quantity: int = 1
@export_multiline var interaction_text: Array[String] = ["You found something!"]

@export var item_pickup_sound: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var sprite_node = get_node_or_null("Sprite2D")
	if sprite_node and item_to_give and item_to_give.texture:
		sprite_node.texture = item_to_give.texture


func interact(player_node: CharacterBody2D) -> void:
	if not item_to_give: return
	
	GlobalGameManager.add_item(item_to_give, quantity)
	
	var dynamic_string = "Found " + item_to_give.item_name + " x" + str(quantity) + "!"
	interaction_text[0] = dynamic_string
	
	play_item_pickup_sound()
	
	if DialogueUI:
		if not DialogueUI.dialogue_finished.is_connected(player_node._on_dialogue_finished):
			DialogueUI.dialogue_finished.connect(player_node._on_dialogue_finished)
		DialogueUI.start_dialogue(interaction_text)
		
	else:
		player_node.is_interacting = false
		
	queue_free()

func play_item_pickup_sound() -> void:
	if not item_pickup_sound:
		return
	
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = item_pickup_sound
	audio_player.bus = "SFX"
	get_parent().add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(audio_player.queue_free)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
