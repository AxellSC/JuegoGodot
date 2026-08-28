class_name Inventory
extends Node 

const MAX_SLOTS := 8

const PICKUP_SCENE := preload("res://scenes/world/item_pickup.tscn")

signal inventory_updated
signal item_added(item:Item, amount: int)
signal item_removed(item:Item, amount: int)
signal item_not_added(item:Item, leftover_amount:int)

var slots: Array[InventorySlot] = []

func _ready() -> void:
	for i in MAX_SLOTS:
		slots.append(InventorySlot.new())
	inventory_updated.connect(print_inventory)

func print_inventory() -> void: 
	print("---- INVENTORY ----")
	for i in slots.size():
		var slot:= slots[i]
		if slot.is_empty():
			print("Slot %d: (empty)" % i)
		else:
			print("Slot %d: %s x%d  [id: %s]" % [i, slot.item.item_name, slot.amount, slot.item.id])
	print("-------------------")	
		
func add_item(item: Item, amount: int = 1) -> int:
	if item == null or amount <= 0:
		return amount
	var remaining : = amount
	
	if item.stackable:
		for slot in slots:
			if remaining <= 0:
				break
			if not slot.is_empty() and slot.item.is_same_item(item) and not slot.is_full():
				var space := slot.available_space()
				var to_add: int = min(space, remaining)
				slot.amount += to_add
				remaining -= to_add
				
	for slot in slots:
		if remaining <= 0:
			break
		if slot.is_empty():
			slot.item = item
			var to_add: int = min(item.max_amount_per_slot, remaining)
			slot.amount = to_add
			remaining -= to_add
	
	var added := amount - remaining
	
	if added > 0:
		item_added.emit(item, added)
		inventory_updated.emit()
	return remaining
		
func remove_item(slot_index: int, amount: int = 1) -> int:
	if slot_index < 0 or slot_index >= slots.size():
		return 0

	var slot := slots[slot_index]
	if slot.is_empty() or amount <= 0:
		return 0

	var item := slot.item
	var to_remove: int = min(amount, slot.amount)
	slot.amount -= to_remove
	if slot.amount <= 0:
		slot.clear()

	item_removed.emit(item, to_remove)
	inventory_updated.emit()
	return to_remove

func remove_item_by_id(id: StringName, amount: int = 1) -> int:
	var remaining := amount
	for i in slots.size():
		if remaining <= 0:
			break
		var slot := slots[i]
		if not slot.is_empty() and slot.item.id == id:
			remaining -= remove_item(i, remaining)
	return amount - remaining

func drop_item(slot_index: int, amount: int, position: Vector3) -> void:
	if slot_index < 0 or slot_index >= slots.size():
		return
	var slot := slots[slot_index]
	if slot.is_empty():
		return

	var item := slot.item
	var dropped := remove_item(slot_index, amount)
	if dropped > 0:
		_spawn_item_in_world(item, dropped, position)
		
func _spawn_item_in_world(item: Item, amount: int, position: Vector3) -> void:
	var instance: ItemPickup = PICKUP_SCENE.instantiate()
	get_tree().current_scene.add_child(instance)
	instance.global_position = position
	instance.setup(item, amount)
	
func get_total_amount(id: StringName) -> int:
	var total := 0
	for slot in slots:
		if not slot.is_empty() and slot.item.id == id:
			total += slot.amount
	return total
	
func has_space_for(item: Item, amount: int = 1) -> bool:
	var total_space := 0
	for slot in slots:
		if slot.is_empty():
			total_space += item.max_amount_per_slot
		elif slot.item.is_same_item(item):
			total_space += slot.available_space()
		if total_space >= amount:
			return true
	return false


func is_full() -> bool:
	for slot in slots:
		if slot.is_empty():
			return false
	for slot in slots:
		if not slot.is_full():
			return false
	return true
