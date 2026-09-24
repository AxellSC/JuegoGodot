extends Node3D

@export var grow_duration: float = 2.0
@export var grow_height: float = 2.0

@onready var spell_zone: Area3D = $SpellZone
@onready var plant_pivot: Node3D = $PlantPivot
@onready var climb_zone: Area3D = $PlantPivot/ClimbZone # starts body_entered into area3d

var has_grown: bool = false

func _ready() -> void:
	# Changed 0.0 to 0.01 so the physics engine doesn't ignore it!
	plant_pivot.scale = Vector3(1.0, 0, 1.0) 
	spell_zone.body_entered.connect(_on_body_entered)
	climb_zone.body_entered.connect(_on_climb_zone_body_entered)
	climb_zone.body_exited.connect(_on_climb_zone_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not has_grown:
		grow_plant()

func grow_plant() -> void:
	has_grown = true
	var tween = create_tween()
	tween.tween_property(plant_pivot, "scale:y", grow_height, grow_duration) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

# 3. Added these two functions to handle the climbing
func _on_climb_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.can_climb = true

func _on_climb_zone_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.can_climb = false
