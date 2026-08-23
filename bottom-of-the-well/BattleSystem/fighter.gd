extends Node2D
class_name Fighter 

@export var fighter_name: String = "Hero"
@export var max_hp: int = 100
@export var current_hp: int = 100
@export var speed: int = 10

@export var hit_sound: AudioStream

var is_defending: bool = false

const DAMAGE_TEXT_SCENE = preload("res://BattleSystem/damage_text.tscn")

func take_damage(amount: int) -> void:
	if is_defending:
		amount = clampi(amount / 2, 1, amount)
	current_hp = max(0, current_hp - amount)	
	spawn_damage_text(amount)
	play_hit_sound()
	
	if current_hp == 0:
		die()
		
func play_hit_sound() -> void:
	if not hit_sound:
		return
	
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = hit_sound
	audio_player.bus = "SFX"
	get_parent().add_child(audio_player)
	audio_player.global_position = global_position
	audio_player.play()
	audio_player.finished.connect(audio_player.queue_free)
		
func spawn_damage_text(amount: int) -> void:
	var text_instance = DAMAGE_TEXT_SCENE.instantiate()
	get_parent().add_child(text_instance)
	text_instance.global_position = global_position
	text_instance.display(amount)

func die() -> void:
	remove_from_group("Enemies")
	remove_from_group("Party")
	queue_free()
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
