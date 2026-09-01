extends CharacterBody3D

# Variables de referencia
@onready var camera_3d: Camera3D = $camera_mount/Camera3D
@onready var character_male_b_2: Node3D = $"character-male-b2"
@onready var camera_mount: Node3D = $camera_mount
@onready var animation_player: AnimationPlayer = $"character-male-b2/AnimationPlayer"
@onready var inventory: Inventory = $Inventory
@onready var coyote_timer: Timer = $coyoteTimer
@onready var jump_buffer_timer: Timer = $jumpBufferTimer

# Cámara
@export var sens_vertical = 0.0005       
@export var min_pitch_deg = -25.0       # Límite inferior de inclinación (mirar abajo)
@export var max_pitch_deg = -10.0        # Límite superior de inclinación (mirar arriba)
@export var camera_follow_speed = 3.0   # Velocidad al seguir el jugador
@export var camera_rotation_speed = 5.0 # Velocidad del suavizado de rotación

# Ángulos actuales y altura
var current_pitch = 0.0
var target_pitch = 0.0
var target_camera_y = 0.0 

# Variables de acción
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var was_on_floor: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera_mount.set_as_top_level(true)
	add_to_group("player")
	

	current_pitch = camera_mount.rotation.x
	target_pitch = current_pitch
	target_camera_y = global_position.y

func _input(event):
	if event is InputEventMouseMotion:
		# Actualizar ángulos objetivo según el movimiento del mouse
		target_pitch -= event.relative.y * sens_vertical
		
		# Limitar los ángulos
		target_pitch = clamp(target_pitch, deg_to_rad(min_pitch_deg), deg_to_rad(max_pitch_deg))
		
	if event.is_action_pressed("drop"):
		_drop_first_item()

func _drop_first_item() -> void:
	for i in inventory.slots.size():
		if not inventory.slots[i].is_empty():
			var front_position := global_position + (-global_transform.basis.z) * 1.2
			front_position.y += 0.5
			inventory.drop_item(i, 1, front_position)
			return

func _jump() -> void:
	if animation_player:
		animation_player.play("jump")
	velocity.y = JUMP_VELOCITY
	coyote_timer.stop()
	jump_buffer_timer.stop()

func _physics_process(delta: float) -> void:

	
	# Solo actualizamos la altura objetivo si el personaje está tocando el suelo
	if is_on_floor():
		target_camera_y = global_position.y
		

	var target_pos = Vector3(global_position.x, target_camera_y, global_position.z)
	
	var follow_factor = 1.0 - exp(-camera_follow_speed * delta)
	camera_mount.global_position = camera_mount.global_position.lerp(target_pos, follow_factor)
	
	var rot_factor = 1.0 - exp(-camera_rotation_speed * delta)
	current_pitch = lerp(current_pitch, target_pitch, rot_factor)
	camera_mount.rotation.x = current_pitch

	
	if not is_on_floor():
		velocity += get_gravity() * delta

	var just_left_ledge: bool = was_on_floor and not is_on_floor() and velocity.y <= 0.0
	if just_left_ledge:
		coyote_timer.start()

	was_on_floor = is_on_floor()
	var can_coyote_jump: bool = not coyote_timer.is_stopped()
	var did_jump = false

	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor() or can_coyote_jump:
			_jump()
			did_jump = true
		else:
			jump_buffer_timer.start()

	if not did_jump and is_on_floor() and not jump_buffer_timer.is_stopped():
		_jump()
		did_jump = true

	
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (camera_mount.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		var rotacion_objetivo = atan2(velocity.x, velocity.z) + PI
		rotation.y = lerp_angle(rotation.y, rotacion_objetivo, 10.0 * delta)

		if is_on_floor() and not did_jump:
			if animation_player:
				animation_player.play("sprint")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		# Proteger la animación de salto comprobando que estemos en el suelo
		if is_on_floor() and not did_jump:
			if animation_player:
				animation_player.play("idle")

	move_and_slide()
