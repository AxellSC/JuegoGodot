## Physical representation of an item in the 3D world.
##
## Used both for hand-placed collectibles in a level, and for items
## the player drops from their [Inventory] (see
## [method Inventory._spawn_item_in_world], which calls
## [method setup] on a freshly instantiated copy of this scene).
class_name ItemPickup
extends Area3D

## Id of the [Item] this pickup represents. Looked up in
## [ItemDatabase] on [method _ready] / [method setup].
@export var item_id: StringName = &""

## How many units of the item this pickup gives when collected.
@export_range(1, 999, 1) var amount: int = 1

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_update_visual()
	
## Configures this pickup to represent [param new_amount] units of
## [param item]. Called by [Inventory] when spawning a dropped item;
## can also be called manually when placing pickups by code.
func setup(item: Item, new_amount: int) -> void:
	item_id = item.id
	amount = new_amount
	_update_visual()
	
## Looks up [member item_id] in [ItemDatabase] and, if the item
## defines a [member Item.generic_mesh], swaps it onto
## [member mesh_instance]. No-op if the id is empty or unresolved.
func _update_visual() -> void:
	if item_id == &"" or mesh_instance == null:
		return
	var item: Item = ItemDatabase.get_item(item_id)
	if item == null:
		return
	if item.generic_mesh:
		mesh_instance.mesh = item.generic_mesh

## Called when any physics body enters this pickup's area. If it's
## the player and it has an "Inventory" child node, tries to add this
## pickup's item to it. Destroys itself if everything was collected;
## otherwise keeps whatever didn't fit (see [member Inventory]
## [method add_item] leftover behavior).
func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	var item: Item = ItemDatabase.get_item(item_id)
	if item == null:
		return

	var inventory: Inventory = body.get_node_or_null("Inventory")
	if inventory == null:
		return

	var leftover := inventory.add_item(item, amount)
	if leftover <= 0:
		queue_free()
	else:
		amount = leftover
