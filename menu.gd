extends Node

@export var start_mouse_captured = true
var mouse_captured: bool = true

func _ready() -> void:
	if start_mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_captured = true

func _unhandled_input(_event: InputEvent) -> void:
	if (Input.is_action_just_pressed("pause")):
		get_tree().paused = !get_tree().paused

	if (Input.is_action_just_pressed("quit")):
		get_tree().quit()
		
	if (Input.is_action_just_pressed("mouse_unlock")):
		if mouse_captured:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			mouse_captured = false
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED #this doesn't re-hide the mouse
			mouse_captured = true
