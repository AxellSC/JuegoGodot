class_name ItemCatalyst
extends Item

@export var modified_spell_id: StringName = &""
@export_multiline var effect: String = ""


func _init() -> void:
	category = "catalyst"
	stackable = true
	max_amount_per_slot = 1
	
