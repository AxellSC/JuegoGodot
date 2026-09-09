class_name QuestData
extends Resource

enum QuestState { NOT_STARTED, IN_PROGRESS, COMPLETED }

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
@export var tasks: Array[TaskData] = []

var state: QuestState = QuestState.NOT_STARTED

func check_completion() -> bool:
	for task in tasks:
		if not task.is_completed:
			return false
	state = QuestState.COMPLETED
	return true
