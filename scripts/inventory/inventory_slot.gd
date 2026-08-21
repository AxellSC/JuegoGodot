class_name InventorySlot
extends RefCounted

var item: Item = null
var amount: int = 0

func is_empty() -> bool:
	return item == null or amount <=0
	
func is_full() -> bool:
	if is_empty():
		return false
	return amount >= item.max_amount_per_slot
	
func available_space() -> int:
	if item == null:
		return 0
	return max(item.max_amount_per_slot - amount, 0)
	
func clear() -> void:
	item = null
	amount = 0
	
