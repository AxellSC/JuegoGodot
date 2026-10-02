extends Node3D

@onready var capture_area: Area3D = $CaptureArea

@export var group_name: String
@export var speed: float = 1.0
@export var arrival_distance: float = 0.5
@export var wobble_height: float = 0.01
@export var wobble_speed: float = 5.0


var player_near: bool = false
var player_ref: Node3D = null

var positions: Array
var temp_positions: Array
var current_position: Marker3D
var time_passed: float = 0.0


# UI
var prompt_panel: PanelContainer
var prompt_label: Label


func _ready() -> void:
	positions = get_tree().get_nodes_in_group(group_name)

	_get_positions()
	_get_next_position()

	capture_area.body_entered.connect(
		_on_capture_area_body_entered
	)

	capture_area.body_exited.connect(
		_on_capture_area_body_exited
	)

	_create_capture_ui()


func _process(delta: float) -> void:
	if (
		current_position
		and global_position.distance_to(
			current_position.global_position
		) < arrival_distance
	):
		_get_next_position()

	if current_position:
		var target = current_position.global_position

		global_position = global_position.move_toward(
			target,
			speed * delta
		)

		time_passed += delta * wobble_speed

		global_position.y += (
			sin(time_passed) * wobble_height
		)

		var look_target = Vector3(
			target.x,
			global_position.y,
			target.z
		)

		look_at(
			look_target,
			Vector3.UP
		)


# --------------------------------------------------
# WAYPOINTS
# --------------------------------------------------

func _get_positions() -> void:
	temp_positions = positions.duplicate()
	temp_positions.shuffle()


func _get_next_position() -> void:
	if temp_positions.is_empty():
		_get_positions()

	if temp_positions.is_empty():
		push_warning(
			"No se encontraron waypoints para el grupo: "
			+ group_name
		)

		current_position = null
		return

	current_position = temp_positions.pop_front()


# --------------------------------------------------
# DETECCIÓN DEL JUGADOR
# --------------------------------------------------

func _on_capture_area_body_entered(
	body: Node3D
) -> void:

	if not body.is_in_group("player"):
		return

	player_near = true
	player_ref = body

	_show_prompt()


func _on_capture_area_body_exited(
	body: Node3D
) -> void:

	if body != player_ref:
		return

	player_near = false
	player_ref = null

	_hide_prompt()


# --------------------------------------------------
# INPUT
# --------------------------------------------------

func _unhandled_input(
	event: InputEvent
) -> void:

	if not player_near:
		return

	if player_ref == null:
		return

	if not is_instance_valid(player_ref):
		return

	if event.is_action_pressed("take"):
		collect(player_ref)

		get_viewport().set_input_as_handled()


# --------------------------------------------------
# CAPTURA DE LA LUCIÉRNAGA
# --------------------------------------------------

func collect(player: Node3D) -> void:
	var firefly: Item = (
		ItemDatabase.get_item("firefly")
	)

	if firefly == null:
		push_warning(
			"No se encontró firefly en ItemDatabase"
		)
		return

	var leftover: int = (
		player.inventory.add_item(
			firefly,
			1
		)
	)

	if leftover > 0:
		print(
			"No hay espacio en el inventario "
			+ "para la luciérnaga."
		)
		return

	_hide_prompt()

	QuestManager.update_task_progress(
		TaskData.TaskType.COLLECT,
		"firefly",
		1
	)

	print("Luciérnaga recolectada.")

	queue_free()


# --------------------------------------------------
# MENSAJE DE CAPTURA
# --------------------------------------------------

func _show_prompt() -> void:
	prompt_label.text = "E: Atrapar luciérnaga"
	prompt_panel.visible = true


func _hide_prompt() -> void:
	prompt_panel.visible = false


# --------------------------------------------------
# CREACIÓN DE LA INTERFAZ
# --------------------------------------------------

func _create_capture_ui() -> void:
	var canvas := CanvasLayer.new()

	canvas.name = "CaptureUI"
	canvas.layer = 20

	add_child(canvas)


	var root := Control.new()

	root.name = "CaptureRoot"
	root.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	canvas.add_child(root)

	root.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)


	# Panel del mensaje
	prompt_panel = PanelContainer.new()

	prompt_panel.name = "CapturePrompt"

	prompt_panel.anchor_left = 0.5
	prompt_panel.anchor_right = 0.5

	prompt_panel.anchor_top = 1.0
	prompt_panel.anchor_bottom = 1.0

	prompt_panel.offset_left = -170
	prompt_panel.offset_right = 170

	prompt_panel.offset_top = -100
	prompt_panel.offset_bottom = -55

	prompt_panel.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	root.add_child(prompt_panel)


	# Texto
	prompt_label = Label.new()

	prompt_label.text = (
		"E: Atrapar luciérnaga"
	)

	prompt_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	prompt_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	prompt_label.add_theme_font_size_override(
		"font_size",
		18
	)

	prompt_panel.add_child(prompt_label)


	# Oculto inicialmente
	prompt_panel.visible = false
