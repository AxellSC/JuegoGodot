class_name DialogueLine
extends Resource

## One line inside a dialogue sequence.
@export var speaker: String = ""
@export_multiline var text: String = ""

## Optional event emitted by DialogueManager when this line becomes active.
## Useful later for animations, sounds, rewards, camera changes, etc.
@export var event_id: StringName = &""
