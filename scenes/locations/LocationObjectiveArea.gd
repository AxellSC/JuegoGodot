class_name LocationObjectiveArea
extends Area3D

## Debe coincidir exactamente con el target_name de la TaskData
@export var zone_id: String = ""

## Si es true, el área se destruye o desactiva tras ser descubierta
@export var one_shot: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	# Validar que sea el jugador
	if not body.is_in_group("player"):
		return
	
	if zone_id.is_empty():
		push_warning("LocationObjectiveArea: zone_id no está configurado.")
		return

	# Notificar avance al gestor global
	QuestManager.update_task_progress(TaskData.TaskType.LOCATION, zone_id, 1)

	# Si es de un solo uso, desactivar monitoreo para ahorrar recursos
	if one_shot:
		set_deferred("monitoring", false)
