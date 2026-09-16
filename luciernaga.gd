extends Node3D

@export var group_name: String # waypoints
@export var speed: float = 1.0
@export var arrival_distance: float = 0.5 # proximity to the waypoints
@export var wobble_height: float = 0.01 
@export var wobble_speed: float = 5.0   

var positions: Array
var temp_positions: Array
var current_position: Marker3D
var time_passed: float = 0.0

# reads the nodes and puts them in a list
func _ready() -> void:
	positions = get_tree().get_nodes_in_group(group_name)
	_get_positions()
	_get_next_position()

func _process(delta: float) -> void:
	if current_position and global_position.distance_to(current_position.global_position) < arrival_distance:
		_get_next_position()

	if current_position:
		var target = current_position.global_position
		
		global_position = global_position.move_toward(target, speed * delta)
		
		time_passed += delta * wobble_speed
		global_position.y += sin(time_passed) * wobble_height
		
		var look_target = Vector3(target.x, global_position.y, target.z)
		look_at(look_target, Vector3.UP)

func _get_positions() -> void:
	temp_positions = positions.duplicate()
	temp_positions.shuffle()

func _get_next_position() -> void:
	if temp_positions.is_empty():
		_get_positions()
	current_position = temp_positions.pop_front()
