extends Interactable
class_name SignPost

@export_multiline var interaction_text: Array[String] = ["This is a blank sign."]

func interact(player_node: CharacterBody2D) -> void:
	DialogueUI.start_dialogue(interaction_text)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
