extends CanvasLayer

@onready var quest_container: Control = $QuestContainer
@onready var title_label: Label = $QuestContainer/VBoxContainer/TitleLabel
@onready var task_list_container: VBoxContainer = $QuestContainer/VBoxContainer/TaskListContainer

func _ready() -> void:
	QuestManager.quest_started.connect(_on_quest_started)
	QuestManager.quest_updated.connect(_update_ui)
	QuestManager.quest_completed.connect(_on_quest_completed)
	
	if QuestManager.active_quest != null:
		_on_quest_started(QuestManager.active_quest)
	else:
		quest_container.visible = false

func _on_quest_started(quest: QuestData) -> void:
	quest_container.visible = true
	_update_ui(quest)

func _update_ui(quest: QuestData) -> void:
	title_label.text = quest.title
	
	# Limpiar labels de tareas anteriores
	for child in task_list_container.get_children():
		child.queue_free()
	
	# Crear un label por cada tarea activa
	for task in quest.tasks:
		var task_label: Label = Label.new()
		task_label.text = "- " + task.get_formatted_text()
		if task.is_completed:
			task_label.modulate = Color.DARK_GRAY
		task_list_container.add_child(task_label)

func _on_quest_completed(quest: QuestData) -> void:
	_update_ui(quest)
	title_label.text = "[COMPLETADA] " + quest.title
