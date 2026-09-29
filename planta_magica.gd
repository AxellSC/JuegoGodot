extends Node3D

@export var grow_duration: float = 2.0
@export var grow_height: float = 2.0

@onready var spell_zone: Area3D = $SpellZone
@onready var plant_pivot: Node3D = $PlantPivot
@onready var climb_zone: Area3D = $PlantPivot/ClimbZone
@onready var planta_canvas: CanvasLayer = $plantaCanvas


var has_grown: bool = false
var is_player_in_zone: bool = false # Rastrear si el jugador está en la zona de hechizo

func _ready() -> void:
	plant_pivot.scale = Vector3(1.0, 1.0, 1.0) 
	
	# Conectamos la entrada y salida de spell_zone
	spell_zone.body_entered.connect(_on_spell_zone_body_entered)
	spell_zone.body_exited.connect(_on_spell_zone_body_exited)
	
	# Descomentamos y conectamos la zona para escalar
	#climb_zone.body_entered.connect(_on_climb_zone_body_entered)
	#climb_zone.body_exited.connect(_on_climb_zone_body_exited)
	
	planta_canvas.visible = false

# Detectar cuando entra el jugador a la zona
func _on_spell_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not has_grown:
		is_player_in_zone = true
		if PowersManager.is_potion_unlocked("powerA"):
			planta_canvas.visible = true
		else:
			print("No tienes el hechizo requerida")

# Detectar cuando sale el jugador de la zona
func _on_spell_zone_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		is_player_in_zone = false
		planta_canvas.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if is_player_in_zone and not has_grown and event.is_action_pressed("interact"):
		if PowersManager.is_potion_unlocked("powerA"):
			planta_canvas.visible = false
			grow_plant()
		else:
			print("No puedes hacer crecer la planta")

func grow_plant() -> void:
	has_grown = true
	var tween = create_tween()
	tween.tween_property(plant_pivot, "scale:y", grow_height, grow_duration) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

# Funciones de la zona para escalar
func _on_climb_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.can_climb = true

func _on_climb_zone_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.can_climb = false
