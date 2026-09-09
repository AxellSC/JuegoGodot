class_name TaskData
extends Resource

enum TaskType { COLLECT, LOCATION, ELIMINATE }

@export var id: String = ""
@export var type: TaskType = TaskType.COLLECT
@export var description: String = ""
@export var target_name: String = "" # Nombre del ítem, zona o enemigo
@export var required_amount: int = 1 # Para ubicación suele ser 1
var current_amount: int = 0
var is_completed: bool = false

func get_formatted_text() -> String:
	match type:
		TaskData.TaskType.COLLECT:
			var display_name: String = target_name
			# Si existe en la base de datos de ítems, extrae su nombre traducido/visible
			if ItemDatabase.has_item(StringName(target_name)):
				var item: Item = ItemDatabase.get_item(StringName(target_name))
				if "name" in item and not item.name.is_empty():
					display_name = item.name
			
			return "%s %s: %d/%d" % [description, display_name, current_amount, required_amount]

		TaskData.TaskType.LOCATION:
			return "Llega hasta la zona de: %s" % [target_name]

		TaskData.TaskType.ELIMINATE:
			return "%s: %d/%d" % [description, current_amount, required_amount]

		_:
			return description


func add_progress(amount: int = 1) -> bool:
	if is_completed:
		return false
	current_amount = mini(current_amount + amount, required_amount)
	if current_amount >= required_amount:
		is_completed = true
	return true
	

func remove_progress(amount: int = 1) -> bool:
	# Si no hay progreso acumulado, no hay nada que restar
	if current_amount <= 0:
		return false
	
	current_amount = maxi(0, current_amount - amount)
	
	# Si cayó por debajo del requisito, deja de estar completada
	if current_amount < required_amount:
		is_completed = false
		
	return true
