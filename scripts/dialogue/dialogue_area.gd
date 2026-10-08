class_name DialogueArea
extends Area3D

## Generic 3D interaction area capable of starting any DialogueData.
## It can be used directly for NPCs, signs, objects or world events,
## and can also be extended by more specialized scripts such as quest givers.

@export_category("Dialogue")
@export var dialogue: DialogueData
@export var prompt_text: String = "F: Interactuar"
@export var interaction_action: StringName = &"interact"
@export var cancel_on_exit: bool = true

var player_near: bool = false
var player_ref: Node3D = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	DialogueManager.dialogue_finished.connect(_on_manager_dialogue_finished)
	DialogueManager.dialogue_cancelled.connect(_on_manager_dialogue_cancelled)


func _exit_tree() -> void:
	if DialogueManager.is_dialogue_from(self):
		DialogueManager.cancel_dialogue()
	DialogueManager.hide_prompt(self)


func _unhandled_input(event: InputEvent) -> void:
	if not player_near:
		return

	if DialogueManager.is_dialogue_active():
		return

	if event.is_action_pressed(interaction_action):
		_start_dialogue()
		get_viewport().set_input_as_handled()


## Override this method when the dialogue depends on game state.
func get_dialogue() -> DialogueData:
	return dialogue


## Override this method in specialized interactors to react after a dialogue.
func dialogue_ended(_finished_dialogue: DialogueData, _was_cancelled: bool) -> void:
	pass


func _start_dialogue() -> void:
	var selected_dialogue := get_dialogue()
	if selected_dialogue == null:
		push_warning("DialogueArea: no hay DialogueData asignado en %s." % name)
		return

	DialogueManager.start_dialogue(selected_dialogue, self)


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	player_near = true
	player_ref = body

	if not DialogueManager.is_dialogue_active():
		DialogueManager.show_prompt(self, prompt_text)


func _on_body_exited(body: Node3D) -> void:
	if body != player_ref:
		return

	player_near = false
	player_ref = null
	DialogueManager.hide_prompt(self)

	if cancel_on_exit and DialogueManager.is_dialogue_from(self):
		DialogueManager.cancel_dialogue()


func _on_manager_dialogue_finished(
	finished_dialogue: DialogueData,
	source: Node
) -> void:
	if source != self:
		if player_near and not DialogueManager.is_dialogue_active():
			DialogueManager.show_prompt(self, prompt_text)
		return

	dialogue_ended(finished_dialogue, false)

	if player_near:
		DialogueManager.show_prompt(self, prompt_text)


func _on_manager_dialogue_cancelled(
	cancelled_dialogue: DialogueData,
	source: Node
) -> void:
	if source != self:
		return

	dialogue_ended(cancelled_dialogue, true)

	if player_near:
		DialogueManager.show_prompt(self, prompt_text)
