## Player inventory: a fixed set of [constant MAX_SLOTS] slots.
##
## Each [InventorySlot] holds one item type and up to
## [member Item.max_amount_per_slot] units of it — that limit is
## defined per item, not by the inventory. Typically added as a child
## [Node] of the player named "Inventory" (referenced by [ItemPickup]
## via [code]get_node_or_null("Inventory")[/code]).
class_name Inventory
extends Node 

## Maximum number of slots this inventory has. Fixed by design.
const MAX_SLOTS := 8

## Scene instantiated in the world whenever an item is dropped via
## [method drop_item]. See [method _spawn_item_in_world].
const PICKUP_SCENE := preload("res://scenes/world/item_pickup.tscn")

## Emitted whenever the contents of the inventory change (item added
## or removed). Currently used to auto-print the inventory state via
## [method print_inventory].
signal inventory_updated

## Emitted when [param amount] units of [param item] were
## successfully added to the inventory.
signal item_added(item:Item, amount: int)

## Emitted when [param amount] units of [param item] were removed
## from the inventory.
signal item_removed(item:Item, amount: int)

## Emitted when [param item] couldn't be fully added because the
## inventory ran out of space; [param leftover_amount] is how many
## units didn't fit. NOTE: not currently emitted anywhere in
## [method add_item] — reserved for when that case needs to be
## surfaced (e.g. to show a "inventory full" UI message).
signal item_not_added(item:Item, leftover_amount:int)

## The 8 slots that make up this inventory, in display order.
var slots: Array[InventorySlot] = []

func _ready() -> void:
	for i in MAX_SLOTS:
		slots.append(InventorySlot.new())
	inventory_updated.connect(print_inventory)

## Prints the full inventory to the console: for each slot, which
## item is in it and how many units, or "(empty)" otherwise. Runs
## automatically on every [signal inventory_updated].
func print_inventory() -> void: 
	print("---- INVENTORY ----")
	for i in slots.size():
		var slot:= slots[i]
		if slot.is_empty():
			print("Slot %d: (empty)" % i)
		else:
			print("Slot %d: %s x%d  [id: %s]" % [i, slot.item.item_name, slot.amount, slot.item.id])
	print("-------------------")	
		
## Tries to add [param amount] units of [param item] to the
## inventory. Existing slots of the same item are filled first (up to
## their [member Item.max_amount_per_slot]); only the leftover uses
## empty slots. Returns how many units could [b]not[/b] be added
## (0 means everything fit).
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
	
## Removes up to [param amount] units from the slot at
## [param slot_index]. Returns how many units were actually removed
## (may be less than requested if the slot didn't have enough).	
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

## Removes up to [param amount] units of the item with [param id],
## searching across all slots (not a specific one). Useful for
## consuming an item regardless of which slot it ended up in, e.g.
## delivering an NPC request. Returns how many units were removed.
func remove_item_by_id(id: StringName, amount: int = 1) -> int:
	var remaining := amount
	for i in slots.size():
		if remaining <= 0:
			break
		var slot := slots[i]
		if not slot.is_empty() and slot.item.id == id:
			remaining -= remove_item(i, remaining)
	return amount - remaining

## Removes [param amount] units from the slot at [param slot_index]
## and spawns them as a physical [ItemPickup] in the world at
## [param position]. No-op if the slot is empty.
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
	

## Instantiates [constant PICKUP_SCENE], places it at [param position]
## and configures it via [method ItemPickup.setup] to represent
## [param amount] units of [param item].	
func _spawn_item_in_world(item: Item, amount: int, position: Vector3) -> void:
	var instance: ItemPickup = PICKUP_SCENE.instantiate()
	get_tree().current_scene.add_child(instance)
	instance.global_position = position
	instance.setup(item, amount)

## Returns the total number of units of the item with [param id]
## across all slots combined.
func get_total_amount(id: StringName) -> int:
	var total := 0
	for slot in slots:
		if not slot.is_empty() and slot.item.id == id:
			total += slot.amount
	return total
	
## Returns [code]true[/code] if there is enough combined space
## (empty slots + partially-filled matching slots) to fit
## [param amount] more units of [param item].
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

## Returns [code]true[/code] only if every slot is both occupied and
## at its maximum capacity — i.e. there's no room left at all, not
## even inside a partially-filled stack.
func is_full() -> bool:
	for slot in slots:
		if slot.is_empty():
			return false
	for slot in slots:
		if not slot.is_full():
			return false
	return true
