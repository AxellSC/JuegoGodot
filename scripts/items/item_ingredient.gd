class_name ItemIngredient
extends Item

@export var ingredient_type: String = ""
@export var relate_request: StringName = &""

func _init() -> void:
	category = "ingredient"
	stackable = true
	
func use(_user: Node) -> bool:
	return false
	
