class_name Item
extends Resource

@export var id: StringName = &""
@export var item_name: String = "Unnamed Item"
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var world_scene = PackedScene
@export var generic_mesh: Mesh
@export var stackable: bool = true
@export_range(1, 999, 1) var max_amount_per_slot: int = 1
@export var category: String = ""

func use(_user: Node) -> bool:
	return false

func get_description_text() -> String:
	return "%s\n%s" % [item_name, description]

func is_same_item(other: Item) -> bool:
	if other == null:
		return false
	return id != &"" and id == other.id
