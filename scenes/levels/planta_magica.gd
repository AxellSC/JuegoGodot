# position, rotation, scale in 3d space
extends Node3D

# speed of growth & how high does the block jump
@export var grow_duration: float = 1.5
@export var grow_height: float = 1.5

# references to our nodes
@onready var spell_zone: Area3D = $SpellZone
@onready var plant_cube: MeshInstance3D = $PlantCube

# has the plant grown already?
var has_grown: bool = false

func _ready() -> void: # runs one time
	plant_cube.scale = Vector3.ZERO # zero initially
	# plant_cube.position.y = -grow_height
	
	# when in the spell zone, call the _on_body_entered function
	spell_zone.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not has_grown:
		grow_plant()

func grow_plant() -> void:
	has_grown = true
	
	# tween animates movements
	var tween = create_tween()
	tween.set_parallel(true) # run the animations at the same time
	
	# from (0,0,0) to (1,1,1)
	tween.tween_property(plant_cube, "scale", Vector3.ONE, grow_duration) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		
	# Animate Position: from underground (-grow_height) to ground level (0.0)
	tween.tween_property(plant_cube, "position:y", 0.0, grow_duration) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
