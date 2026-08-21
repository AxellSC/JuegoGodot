extends CharacterBody3D

#Variables de referencia
@onready var camera_3d: Camera3D = $camera_mount/SpringArm3D/Camera3D
@onready var spring_arm: SpringArm3D = $camera_mount/SpringArm3D
@onready var character_male_b_2: Node3D = $"character-male-b2"
@onready var camera_mount: Node3D = $camera_mount
@onready var animation_player: AnimationPlayer = $"character-male-b2/AnimationPlayer"
@onready var inventory: Inventory = $Inventory

#Camara
@export var sens_horizontal = 0.2
@export var sens_vertical = 0.15
var MaxHorizontalA = -30.0
var MaxHorizontalB = -10.0
var velocidad_giro = 10.0


#Variables de accion
const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED #Ocultar el puntero
	camera_mount.set_as_top_level(true)
	add_to_group("player") #So ItemPickup can detect a player

func _input(event):
	#Mover la camara respecto al mouse
	if event is InputEventMouseMotion:
# Rotamos la cámara
		camera_mount.rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		spring_arm.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))
		# Limitar el ángulo vertical
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, deg_to_rad(MaxHorizontalA), deg_to_rad(MaxHorizontalB))
		
	if event.is_action_pressed("drop"):
		_drop_first_item()

func _drop_first_item() -> void:
	for i in inventory.slots.size():
		if not inventory.slots[i].is_empty():
			var front_position := global_position + (-global_transform.basis.z) * 1.2
			front_position.y += 0.5
			inventory.drop_item(i, 1, front_position)
			return
			


func _physics_process(delta: float) -> void:
	
	#Camara sigue al jugador
	camera_mount.global_position = global_position	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		if animation_player: animation_player.play("jump")
		velocity.y = JUMP_VELOCITY
	var input_dir := Input.get_vector("left", "right", "up", "down")

	var direction := (camera_mount.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		if animation_player: animation_player.play("sprint")
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		var rotacion_objetivo = atan2(velocity.x, velocity.z)
		rotacion_objetivo += PI
		rotation.y = lerp_angle(rotation.y, rotacion_objetivo, velocidad_giro * delta)
	else:
		if animation_player: animation_player.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
