
extends Area3D

@export var quest_to_assign: QuestData

var player_near: bool = false
var talking: bool = false
var dialogue_index: int = 0

var dialogue_lines: Array[String] = []
var dialogue_action: String = ""

var prompt_panel: PanelContainer
var prompt_label: Label

var dialogue_panel: PanelContainer
var dialogue_label: Label

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	_create_dialogue_ui()

func _unhandled_input(event: InputEvent) -> void:
	if not player_near:
		return

	if event.is_action_pressed("interact"):
		if talking:
			_next_dialogue()
		else:
			_start_dialogue()

		get_viewport().set_input_as_handled()

# --------------------------------------------------
# DETECCIÓN DEL JUGADOR
# --------------------------------------------------

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	player_near = true

	if not talking:
		_show_prompt()


func _on_body_exited(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	player_near = false
	_hide_prompt()

	if talking:
		_close_dialogue()
	
# --------------------------------------------------
# DIÁLOGO
# --------------------------------------------------
	
func _start_dialogue() -> void:
	if quest_to_assign == null:
		push_warning(
			"QuestGiverArea: No se asignó ninguna misión en el Inspector"
		)
		return
	
	talking = true
	dialogue_index = 0
	
	_hide_prompt()
	
	var quest_id: String = quest_to_assign.id
	
	# La misión ya fue completada
	if QuestManager.is_quest_completed(quest_id):
		dialogue_lines = [
			"Mago: Has vuelto.",
			"Mago: Veo que lograste completar la tarea que te encomendé.",
			"Mago: Has demostrado ser más capaz de lo que imaginaba."
		]

		dialogue_action = "completed"

	# La misión sigue activa
	elif QuestManager.is_quest_in_progress(quest_id):
		dialogue_lines = [
			"Mago: Aún no has terminado.",
			"Mago: Sigue buscando los objetos que te pedí.",
			"Mago: Regresa cuando hayas completado tu misión."
		]

		dialogue_action = "in_progress"
		
	# Primera conversación
	else:
		dialogue_lines = [
			"Mago: Ah... por fin llegaste.",
			"Jugador: ¿Quién eres?",
			"Mago: Eso puede esperar.",
			"Mago: Primero necesito tu ayuda.",
			"Mago: Hay ciertos objetos dispersos por esta zona.",
			"Mago: Encuéntralos y tráelos conmigo."
		]

		dialogue_action = "start_quest"

	_show_dialogue_line()

func _next_dialogue() -> void:
	dialogue_index += 1

	if dialogue_index >= dialogue_lines.size():
		_finish_dialogue()
		return

	_show_dialogue_line()


func _show_dialogue_line() -> void:
	dialogue_label.text = (
		dialogue_lines[dialogue_index]
		+ "\n\n[E] Continuar"
	)

	dialogue_panel.visible = true


func _finish_dialogue() -> void:
	dialogue_panel.visible = false
	talking = false

	match dialogue_action:

		"start_quest":
			print(
				"[NPC]: ¡Te asigno la misión: %s!"
				% quest_to_assign.title
			)

			QuestManager.start_quest(quest_to_assign)

		"completed":
			print("[NPC]: Misión completada.")

			# Conservamos lo que ya tenías
			PowersManager.unlock_potion("powerA")

		"in_progress":
			print("[NPC]: La misión continúa activa.")

	dialogue_action = ""

	if player_near:
		_show_prompt()

func _close_dialogue() -> void:
	talking = false
	dialogue_index = 0
	dialogue_action = ""

	dialogue_panel.visible = false

# --------------------------------------------------
# MENSAJE "E: HABLAR CON EL MAGO"
# --------------------------------------------------

func _show_prompt() -> void:
	prompt_label.text = "E: Hablar con el mago"
	prompt_panel.visible = true


func _hide_prompt() -> void:
	prompt_panel.visible = false


# --------------------------------------------------
# CREACIÓN DE LA INTERFAZ
# --------------------------------------------------

func _create_dialogue_ui() -> void:

	# CanvasLayer para que el diálogo siempre aparezca
	# encima de la escena 3D.
	var canvas := CanvasLayer.new()
	canvas.name = "DialogueUI"
	add_child(canvas)


	# --------------------------------------------------
	# CONTENEDOR PRINCIPAL
	# --------------------------------------------------

	var root := Control.new()
	root.name = "DialogueRoot"

	root.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	canvas.add_child(root)


	# --------------------------------------------------
	# MENSAJE:
	# E: Hablar con el mago
	# --------------------------------------------------

	prompt_panel = PanelContainer.new()
	prompt_panel.name = "PromptPanel"

	prompt_panel.anchor_left = 0.5
	prompt_panel.anchor_right = 0.5

	prompt_panel.anchor_top = 1.0
	prompt_panel.anchor_bottom = 1.0

	prompt_panel.offset_left = -150
	prompt_panel.offset_right = 150

	prompt_panel.offset_top = -100
	prompt_panel.offset_bottom = -55

	root.add_child(prompt_panel)


	prompt_label = Label.new()
	prompt_label.text = "E: Hablar con el mago"

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

	prompt_panel.visible = false


	# --------------------------------------------------
	# CAJA DEL DIÁLOGO
	# --------------------------------------------------

	dialogue_panel = PanelContainer.new()
	dialogue_panel.name = "DialoguePanel"

	dialogue_panel.anchor_left = 0.15
	dialogue_panel.anchor_right = 0.85

	dialogue_panel.anchor_top = 0.72
	dialogue_panel.anchor_bottom = 0.94

	root.add_child(dialogue_panel)


	# Margen interno para que el texto no quede pegado
	var margin := MarginContainer.new()

	margin.add_theme_constant_override(
		"margin_left",
		25
	)

	margin.add_theme_constant_override(
		"margin_right",
		25
	)

	margin.add_theme_constant_override(
		"margin_top",
		20
	)

	margin.add_theme_constant_override(
		"margin_bottom",
		20
	)

	dialogue_panel.add_child(margin)


	dialogue_label = Label.new()

	dialogue_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	dialogue_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	dialogue_label.add_theme_font_size_override(
		"font_size",
		20
	)

	margin.add_child(dialogue_label)

	dialogue_panel.visible = false
