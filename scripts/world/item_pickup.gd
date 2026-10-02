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
@onready var agarrar_e: Label3D = $AgarrarE

var _player_in_range: Node3D = null

# Reference to save the instantiated scene node
var _spawned_visual_node: Node3D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	#body_exited.connect(_on_body_exited)
	_update_visual()
	agarrar_e.visible = false

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
	if item.world_scene:
		# Ocultar la malla base/placeholder si existe
		if mesh_instance:
			mesh_instance.visible = false

		var instance: Node3D = item.world_scene.instantiate() as Node3D
		if instance:
			add_child(instance)
			_spawned_visual_node = instance

## Called when the player enters the area. Only marks proximity and
## shows the "press key" hint; the pickup itself happens on input.
func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_range = body
	agarrar_e.visible = true

## Called when the player leaves the area. Clears the reference.
func _on_body_exited(body: Node3D) -> void:
	if body != _player_in_range:
		return
	_player_in_range = null
	agarrar_e.visible = false

## Waits for the "take" action and tries to pick up the item.
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("take"):
		return
	if _player_in_range == null:
		return
	_try_pickup()

## Actually moves the item into the player's inventory, updates quests,
## and frees the pickup (or keeps leftover).
func _try_pickup() -> void:
	var item: Item = ItemDatabase.get_item(item_id)
	if item == null:
		return

	var inventory: Inventory = _player_in_range.get_node_or_null("Inventory")
	if inventory == null:
		return

	var leftover: int = inventory.add_item(item, amount)
	var collected_amount: int = amount - leftover

	
	if collected_amount > 0:
		QuestManager.update_task_progress(
			TaskData.TaskType.COLLECT,
			String(item_id),
			collected_amount
		)

	if leftover <= 0:
		queue_free()
	else:
		amount = leftover
