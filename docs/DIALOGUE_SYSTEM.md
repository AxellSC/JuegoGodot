# Sistema de diálogo

El sistema está separado en cuatro piezas para que una conversación no dependa de un NPC o de una misión concreta.

## Estructura

- `DialogueLine`: una línea individual (`speaker`, `text`, `event_id`).
- `DialogueData`: una conversación completa formada por varias `DialogueLine`.
- `DialogueManager`: Autoload que inicia, avanza, termina y cancela conversaciones.
- `DialogueUI`: única interfaz visual para todos los diálogos del juego.
- `DialogueArea`: `Area3D` genérica para iniciar un `DialogueData` al acercarse e interactuar.
- `quest_giver_area.gd`: especialización de `DialogueArea` que selecciona un diálogo según el estado de una misión.

## Crear un diálogo nuevo

En el editor de Godot crea un recurso `DialogueData`. En `lines` agrega recursos `DialogueLine` y llena `speaker` y `text`.

También puede crearse como `.tres` dentro de `res://data/dialogues/`.

## Usarlo en un NPC u objeto sencillo

Opción rápida: instancia `res://scenes/dialogue/dialogue_trigger.tscn`, asigna el `DialogueData` en el Inspector y configura `prompt_text`.

También puedes adjuntar `res://scripts/dialogue/dialogue_area.gd` a cualquier `Area3D` que tenga su `CollisionShape3D`.

## Iniciarlo desde código

```gdscript
@export var my_dialogue: DialogueData

func some_event() -> void:
    DialogueManager.start_dialogue(my_dialogue, self)
```

Para reaccionar al final desde cualquier sistema:

```gdscript
DialogueManager.dialogue_finished.connect(_on_dialogue_finished)
```

## Eventos dentro de una línea

Cada `DialogueLine` tiene `event_id`. Si no está vacío, `DialogueManager` emite `dialogue_event` al mostrar esa línea. Esto permite conectar animaciones, sonidos, cámara, recompensas u otras acciones sin meter esa lógica en los datos del diálogo.

## Mago de misión

El mago usa tres recursos independientes:

- `mage_intro.tres`: antes de iniciar la misión.
- `mage_in_progress.tres`: mientras la misión sigue activa.
- `mage_completed.tres`: cuando la misión ya fue completada.

`quest_giver_area.gd` ya no contiene textos ni crea UI. Solo consulta `QuestManager`, elige el `DialogueData` correcto y ejecuta la acción al terminar la conversación.
