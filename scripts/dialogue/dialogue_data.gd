class_name DialogueData
extends Resource

## Unique identifier for this conversation.
@export var id: StringName = &""

## Ordered lines shown by DialogueManager.
@export var lines: Array[DialogueLine] = []

## Input Map action used to advance this dialogue.
@export var advance_action: StringName = &"interact"

## Text displayed in the dialogue UI while waiting for the next line.
@export var continue_hint: String = "[F] Continuar"
