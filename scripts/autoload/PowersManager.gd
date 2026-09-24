extends Node

# Señales para notificar al resto del juego 
signal potion_unlocked(potion_id: String)
signal potion_availability_changed(potion_id: String, is_available: bool)
signal potion_used(potion_id: String)
signal potion_use_failed(potion_id: String, reason: String)

# Diccionario base con los datos
var potions: Dictionary = {
	"powerA": {"unlocked": false, "available": false},
	"powerC": {"unlocked": false, "available": false},
	"powerD": {"unlocked": false, "available": false},
}

## Desbloquea una poción / receta
func unlock_potion(potion_id: String) -> void:
	if not potions.has(potion_id):
		return
	
	if not potions[potion_id]["unlocked"]:
		potions[potion_id]["unlocked"] = true
		potion_unlocked.emit(potion_id)
		print("Haz desbloqueado la posion ", potion_id)


## Actualiza si hay ingredientes suficientes para prepararla/usarla
func set_potion_available(potion_id: String, available: bool) -> void:
	if not potions.has(potion_id):
		return
	
	if potions[potion_id]["available"] != available:
		potions[potion_id]["available"] = available
		potion_availability_changed.emit(potion_id, available)


## Comprueba si se puede usar
func can_use_potion(potion_id: String) -> bool:
	var p: Dictionary = potions.get(potion_id, {})
	return not p.is_empty() and p.get("unlocked", false) and p.get("available", false)


## Intento de uso de poción / hechizo
func try_use_potion(potion_id: String) -> bool:
	if not potions.has(potion_id):
		potion_use_failed.emit(potion_id, "La poción no existe.")
		return false
	
	var p: Dictionary = potions[potion_id]
	
	if not p["unlocked"]:
		potion_use_failed.emit(potion_id, "Poción bloqueada.")
		return false
		
	if not p["available"]:
		potion_use_failed.emit(potion_id, "Ingredientes  insuficientes.")
		return false

	# Si cumple ambas condiciones:
	potion_used.emit(potion_id)
	return true
	
## Comprueba si la poción está desbloqueada
func is_potion_unlocked(potion_id: String) -> bool:
	if not potions.has(potion_id):
		print("ERROR: La poción '", potion_id, "' no existe en el diccionario.")
		return false
	return potions[potion_id].get("unlocked", false)
