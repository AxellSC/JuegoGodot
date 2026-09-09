
extends Area3D

@export var quest_to_assign: QuestData

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	# Aseguramos que solo reaccione al jugador
	if not body.is_in_group("player"):
		return
	
	if quest_to_assign == null:
		push_warning("QuestGiverArea: No se asignó ninguna misión en el Inspector.")
		return
		
	var quest_id: String = quest_to_assign.id
	
	# Verificamos los 3 estados
	if QuestManager.is_quest_completed(quest_id):
		print("[NPC]: Ya has completado esta misión, ¡buen trabajo!")
	elif QuestManager.is_quest_in_progress(quest_id):
		print("[NPC]: Aún tienes la misión en progreso, sigue buscando.")
	else:
		print("[NPC]: ¡Te asigno la misión: %s!" % quest_to_assign.title)
		QuestManager.start_quest(quest_to_assign)
