## Ingredient item type.
class_name ItemIngredient
extends Item

## Narrative sub-type of the ingredient (e.g. "root", "feather",
## "mushroom"). Purely descriptive/flavor data for now.
@export var ingredient_type: String = ""
@export var relate_request: StringName = &""

func _init() -> void:
	category = "ingredient"
	stackable = true
	
func use(_user: Node) -> bool:
	return false
	
