extends CanvasLayer

@onready var dialogue_panel: PanelContainer = $DialoguePanel
@onready var dialogue_text_label: RichTextLabel = $DialoguePanel/MarginContainer/DialogueTextLabel

@export var type_speed: float = 0.025

var current_dialogue_lines: Array[String] = []
var current_line_index: int = 0
var is_typing: bool = false
var text_tween: Tween

var just_opened: bool = false

signal dialogue_finished

func _ready() -> void:
	dialogue_panel.hide()
	
func start_dialogue(lines: Array[String]) -> void:
	current_dialogue_lines = lines
	current_line_index = 0
	dialogue_panel.show()
	
	just_opened = true
	show_current_line()
	
	await get_tree().process_frame
	just_opened = false
	
func show_current_line() -> void:
	if current_line_index >= current_dialogue_lines.size():
		close_dialogue()
		return
	
	var text_to_display = current_dialogue_lines[current_line_index]
	dialogue_text_label.text = text_to_display
	dialogue_text_label.visible_characters = 0
	is_typing = true
	
	if text_tween: text_tween.kill()
	text_tween = create_tween()
	var total_chars = text_to_display.length()
	
	text_tween.tween_property(dialogue_text_label, "visible_characters", total_chars, total_chars * type_speed)
	text_tween.finished.connect(func(): is_typing = false)
	
func _unhandled_input(event: InputEvent) -> void:
	if not dialogue_panel.visible or just_opened: 
		return
	
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		
		if is_typing:
			if text_tween: text_tween.kill()
			dialogue_text_label.visible_characters = dialogue_text_label.text.length()
			is_typing = false
		else:
			current_line_index += 1
			show_current_line()
			
func close_dialogue() -> void:
	dialogue_panel.hide()
	dialogue_finished.emit()
