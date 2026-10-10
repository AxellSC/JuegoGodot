extends Node

signal dialogue_started(dialogue: DialogueData, source: Node)
signal line_changed(dialogue: DialogueData, line: DialogueLine, index: int, source: Node)
signal dialogue_event(event_id: StringName, dialogue: DialogueData, index: int, source: Node)
signal dialogue_finished(dialogue: DialogueData, source: Node)
signal dialogue_cancelled(dialogue: DialogueData, source: Node)

const DIALOGUE_UI_SCENE: PackedScene = preload("res://scenes/ui/dialogue_ui.tscn")

var active_dialogue: DialogueData = null
var dialogue_source: Node = null
var current_index: int = -1

var _ui: DialogueUI
var _prompt_owner: Node = null


func _ready() -> void:
	_ui = DIALOGUE_UI_SCENE.instantiate() as DialogueUI
	add_child(_ui)


func _unhandled_input(event: InputEvent) -> void:
	if active_dialogue == null:
		return

	var action := active_dialogue.advance_action
	if action == &"":
		action = &"interact"

	if event.is_action_pressed(action):
		advance_dialogue()
		get_viewport().set_input_as_handled()


func start_dialogue(dialogue: DialogueData, source: Node = null) -> bool:
	if dialogue == null:
		push_warning("DialogueManager: se intentó iniciar un diálogo nulo.")
		return false

	if dialogue.lines.is_empty():
		push_warning("DialogueManager: el diálogo '%s' no tiene líneas." % dialogue.id)
		return false

	if active_dialogue != null:
		return false

	active_dialogue = dialogue
	dialogue_source = source
	current_index = 0

	_prompt_owner = null
	_ui.hide_prompt()

	dialogue_started.emit(active_dialogue, dialogue_source)
	_show_current_line()
	return true


func advance_dialogue() -> void:
	if active_dialogue == null:
		return

	current_index += 1

	if current_index >= active_dialogue.lines.size():
		finish_dialogue()
		return

	_show_current_line()


func finish_dialogue() -> void:
	if active_dialogue == null:
		return

	var finished_dialogue := active_dialogue
	var finished_source := dialogue_source

	_clear_active_dialogue()
	dialogue_finished.emit(finished_dialogue, finished_source)


func cancel_dialogue() -> void:
	if active_dialogue == null:
		return

	var cancelled_dialogue := active_dialogue
	var cancelled_source := dialogue_source

	_clear_active_dialogue()
	dialogue_cancelled.emit(cancelled_dialogue, cancelled_source)


func is_dialogue_active() -> bool:
	return active_dialogue != null


func is_dialogue_from(source: Node) -> bool:
	return active_dialogue != null and dialogue_source == source


@warning_ignore("shadowed_variable_base_class")
func show_prompt(owner: Node, text: String) -> void:
	if owner == null or is_dialogue_active():
		return

	_prompt_owner = owner
	_ui.show_prompt(text)


@warning_ignore("shadowed_variable_base_class")
func hide_prompt(owner: Node) -> void:
	if owner != _prompt_owner:
		return

	_prompt_owner = null
	_ui.hide_prompt()


func _show_current_line() -> void:
	if active_dialogue == null:
		return

	if current_index < 0 or current_index >= active_dialogue.lines.size():
		return

	var line := active_dialogue.lines[current_index]
	if line == null:
		push_warning(
			"DialogueManager: línea nula en '%s' (índice %d)."
			% [active_dialogue.id, current_index]
		)
		advance_dialogue()
		return

	_ui.show_line(line, active_dialogue.continue_hint)
	line_changed.emit(active_dialogue, line, current_index, dialogue_source)

	if line.event_id != &"":
		dialogue_event.emit(
			line.event_id,
			active_dialogue,
			current_index,
			dialogue_source
		)


func _clear_active_dialogue() -> void:
	_ui.hide_dialogue()
	active_dialogue = null
	dialogue_source = null
	current_index = -1
