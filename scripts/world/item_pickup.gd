class_name ItemPickup
extends Area3D

@export var item_id: StringName = &""
@export_range(1, 999, 1) var amount: int = 1

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_update_visual()
	
func setup(item: Item, new_amount: int) -> void:
	item_id = item.id
	amount = new_amount
	_update_visual()
	
func _update_visual() -> void:
	if item_id == &"" or mesh_instance == null:
		return
	var item: Item = ItemDatabase.get_item(item_id)
	if item == null:
		return
	if item.generic_mesh:
		mesh_instance.mesh = item.generic_mesh

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
