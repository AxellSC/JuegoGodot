## A single inventory slot.
## Holds a reference to one [Item] type plus how many units of it are
## stored. Each slot can only ever contain one item type at a time.

class_name InventorySlot
extends RefCounted

## The item type currently stored in this slot, or [code]null[/code]
## if the slot is empty.
var item: Item = null

## How many units of [member item] are currently stored here.
var amount: int = 0

## Returns [code]true[/code] if the slot has no item or a
## non-positive amount.
func is_empty() -> bool:
	return item == null or amount <=0

## Returns [code]true[/code] if the slot is holding as many units as
## [member item]'s [member Item.max_amount_per_slot] allows.
func is_full() -> bool:
	if is_empty():
		return false
	return amount >= item.max_amount_per_slot

## Returns how many more units of [member item] could still be added
## to this slot before it's full. Returns 0 if the slot is empty.
func available_space() -> int:
	if item == null:
		return 0
	return max(item.max_amount_per_slot - amount, 0)

## Empties the slot, discarding the item reference and resetting
## [member amount] to 0.
func clear() -> void:
	item = null
	amount = 0
	
