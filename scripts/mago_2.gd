extends "res://scripts/dialogue/dialogue_area.gd"

## Quest-specific integration for the reusable dialogue system.
## The Area3D/proximity behavior comes from DialogueArea; this script only
## decides which conversation to play and what quest action happens afterward.

@export_category("Quest")
@export var quest_to_assign: QuestData
@export var reward_potion_id: StringName = &"powerA"

@export_category("Quest Dialogues")
@export var dialogue_not_started: DialogueData
@export var dialogue_in_progress: DialogueData
@export var dialogue_completed: DialogueData

const ACTION_NONE: StringName = &""
const ACTION_START_QUEST: StringName = &"start_quest"
const ACTION_IN_PROGRESS: StringName = &"in_progress"
const ACTION_COMPLETED: StringName = &"completed"

var _pending_action: StringName = ACTION_NONE


func get_dialogue() -> DialogueData:
	_pending_action = ACTION_NONE

	if quest_to_assign == null:
		push_warning("QuestGiverArea: no se asignó ninguna misión en el Inspector.")
		return dialogue

	var quest_id := quest_to_assign.id

	if QuestManager.is_quest_completed(quest_id):
		_pending_action = ACTION_COMPLETED
		return _fallback_dialogue(dialogue_completed)

	if QuestManager.is_quest_in_progress(quest_id):
		_pending_action = ACTION_IN_PROGRESS
		return _fallback_dialogue(dialogue_in_progress)

	_pending_action = ACTION_START_QUEST
	return _fallback_dialogue(dialogue_not_started)


func dialogue_ended(_finished_dialogue: DialogueData, was_cancelled: bool) -> void:
	if was_cancelled:
		_pending_action = ACTION_NONE
		return

	match _pending_action:
		ACTION_START_QUEST:
			if quest_to_assign != null:
				if QuestManager.start_quest(quest_to_assign):
					print("[NPC]: ¡Te asigno la misión: %s!" % quest_to_assign.title)

		ACTION_IN_PROGRESS:
			print("[NPC]: La misión continúa activa.")

		ACTION_COMPLETED:
			print("[NPC]: Misión completada.")
			if reward_potion_id != &"":
				PowersManager.unlock_potion(String(reward_potion_id))

	_pending_action = ACTION_NONE


func _fallback_dialogue(preferred: DialogueData) -> DialogueData:
	if preferred != null:
		return preferred
	return dialogue
