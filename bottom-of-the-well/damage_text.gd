extends Label

func display(amount: int) -> void:
	text = str(amount)
	var random_x = randf_range(-15.0, 15.0)
	position += Vector2(random_x, -20.0)
	var tween = create_tween().set_parallel(true)
	var target_y = position.y -40.0
	tween.tween_property(self, "position:y", target_y, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.6).set_delay(0.2)
	tween.chain().tween_callback(queue_free)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
