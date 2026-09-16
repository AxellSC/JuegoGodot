extends Node

signal quest_started(quest: QuestData)
signal quest_updated(quest: QuestData)
signal quest_completed(quest: QuestData)

var active_quest: QuestData = null
var completed_quest_ids: Dictionary = {} # Guarda IDs como llave y true como valor

# Asignar una nueva misión (duplicando el recurso para que el progreso sea único por instancia)
# En QuestManager.gd

func start_quest(quest_resource: QuestData) -> bool:
	if active_quest != null and active_quest.state == QuestData.QuestState.IN_PROGRESS:
		push_warning("Ya hay una misión activa.")
		return false
	
	active_quest = quest_resource.duplicate(true)
	active_quest.state = QuestData.QuestState.IN_PROGRESS

	# --- Sincronización Retroactiva Inicial ---
	_evaluate_initial_progress(active_quest)

	quest_started.emit(active_quest)

	# Si todas las tareas ya estaban cumplidas de antemano
	if active_quest.check_completion():
		completed_quest_ids[active_quest.id] = true
		quest_completed.emit(active_quest)

	return true

func _evaluate_initial_progress(quest: QuestData) -> void:
	var inventory := _get_player_inventory()

	for task in quest.tasks:
		match task.type:
			TaskData.TaskType.COLLECT:
				if inventory != null:
					# target_name contiene el StringName del item (ej: "apple")
					var item_id := StringName(task.target_name)
					var existing_count: int = inventory.get_total_amount(item_id)
					
					if existing_count > 0:
						task.add_progress(existing_count)

			TaskData.TaskType.LOCATION:
				# Opcional: si tienes un gestor de zonas descubiertas,
				# podrías verificar aquí si la zona ya fue visitada previamente.
				pass

			TaskData.TaskType.ELIMINATE:
				# Las eliminaciones usualmente sí cuentan a partir de que te dan la orden,
				# salvo que el enemigo sea un jefe único ya derrotado.
				pass

# Notificar avances desde cualquier parte del juego
func update_task_progress(task_type: TaskData.TaskType, target_name: String, amount: int = 1) -> void:
	if active_quest == null or active_quest.state != QuestData.QuestState.IN_PROGRESS:
		return

	var updated: bool = false
	for task in active_quest.tasks:
		if task.type == task_type and task.target_name == target_name and not task.is_completed:
			if task.add_progress(amount):
				updated = true

	if updated:
		quest_updated.emit(active_quest)
		if active_quest.check_completion():
			completed_quest_ids[active_quest.id] = true
			quest_completed.emit(active_quest)

# Métodos para consulta de los NPCs
func is_quest_completed(quest_id: String) -> bool:
	return completed_quest_ids.has(quest_id)

func is_quest_in_progress(quest_id: String) -> bool:
	return active_quest != null and active_quest.id == quest_id and active_quest.state == QuestData.QuestState.IN_PROGRESS


# Notificar reducción de progreso (ej. soltar ítems o venderlos)
func remove_task_progress(task_type: TaskData.TaskType, target_name: String, amount: int = 1) -> void:
	# Si no hay misión o ya se completó definitivamente, no restamos
	if active_quest == null or active_quest.state != QuestData.QuestState.IN_PROGRESS:
		return

	var updated: bool = false
	for task in active_quest.tasks:
		if task.type == task_type and task.target_name == target_name:
			if task.remove_progress(amount):
				updated = true

	if updated:
		# Si alguna tarea dejó de estar completa, la misión se asegura en IN_PROGRESS
		active_quest.state = QuestData.QuestState.IN_PROGRESS
		quest_updated.emit(active_quest)

#Funcion para obtener el inventario del jugador
func _get_player_inventory() -> Inventory:
	var player_node := get_tree().get_first_node_in_group("player")
	if player_node != null:
		return player_node.get_node_or_null("Inventory") as Inventory
	return null
