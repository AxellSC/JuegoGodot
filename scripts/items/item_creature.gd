class_name ItemCreature
extends Item

@export var creature_type: String = ""
@export var relate_request: StringName = &""

func _init() -> void:
	category = "creature"
	stackable = true

func use(_user: Node) -> bool:
	return false
