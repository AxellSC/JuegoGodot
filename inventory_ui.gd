extends Control
var is_open: bool = false

func _unhandled_input(event: InputEvent) -> void:
	# check if the toggle_inventoryt action was just pressed
	if event.is_action_pressed("toggle_inventory"):
		is_open = not is_open # true to false, or false to true
		visible = is_open     # hides or shows the UI
		
		# cursor
		if is_open:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
