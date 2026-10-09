class_name DialogueUI
extends CanvasLayer

@onready var prompt_panel: PanelContainer = $Root/PromptPanel
@onready var prompt_label: Label = $Root/PromptPanel/PromptLabel

@onready var dialogue_panel: PanelContainer = $Root/DialoguePanel
@onready var speaker_label: Label = $Root/DialoguePanel/Margin/VBox/SpeakerLabel
@onready var dialogue_label: Label = $Root/DialoguePanel/Margin/VBox/DialogueLabel
@onready var continue_label: Label = $Root/DialoguePanel/Margin/VBox/ContinueLabel


func _ready() -> void:
	hide_prompt()
	hide_dialogue()


func show_prompt(text: String) -> void:
	prompt_label.text = text
	prompt_panel.visible = true


func hide_prompt() -> void:
	prompt_panel.visible = false


func show_line(line: DialogueLine, continue_hint: String) -> void:
	speaker_label.text = line.speaker
	speaker_label.visible = not line.speaker.is_empty()
	dialogue_label.text = line.text
	continue_label.text = continue_hint
	dialogue_panel.visible = true


func hide_dialogue() -> void:
	dialogue_panel.visible = false
