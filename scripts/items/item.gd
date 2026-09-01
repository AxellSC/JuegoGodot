## Base class for every item in the game.
## Items are saved as resources and get registered automatically by ItemDatabase.

class_name Item
extends Resource

## Unique identifier for the item.
@export var id: StringName = &""

## Name shown to the player (inventory UI, tooltips, etc.).
@export var item_name: String = "Unnamed Item"

## Longer description shown in the inventory UI.
@export_multiline var description: String = ""

## Icon used to represent the item in inventory slots.
@export var icon: Texture2D

## Optional full scene used to represent this item in the world
## instead of just swapping the mesh on [ItemPickup]. Not yet read by
## any script — reserved for items that need custom visuals/behavior
## when dropped (materials, animation, particles, etc.).
@export var world_scene: PackedScene

## Mesh assigned to [ItemPickup]'s MeshInstance3D when this item is
## placed or dropped in the world. If left empty, the pickup keeps
## whatever placeholder mesh is set on its own scene.
@export var generic_mesh: Mesh

## Whether the item can stack (multiple units sharing one slot). If
## false, each unit should occupy its own slot regardless of
## [member max_amount_per_slot].
@export var stackable: bool = true

## Fixed number of units of this item type that fit in a single
## inventory slot. Defined per item type, not by the inventory itself.
@export_range(1, 999, 1) var max_amount_per_slot: int = 1

## Free-text category used for filtering/logic (e.g. "ingredient",
## "catalyst").
@export var category: String = ""

## Called when the player uses/consumes this item from the inventory
## Override in child classes with the item's actual effect. Should
## return [code]true[/code] if the item was consumed and one unit
## should be removed from the inventory.
func use(_user: Node) -> bool:
	return false

## Returns [member item_name] and [member description] combined,
## for quick display in tooltips/logs.
func get_description_text() -> String:
	return "%s\n%s" % [item_name, description]

## Returns [code]true[/code] if [param other] represents the same
## item type as this one (compared by [member id]). Used by
## [Inventory] to decide whether two stacks can be merged.
func is_same_item(other: Item) -> bool:
	if other == null:
		return false
	return id != &"" and id == other.id
