extends CharacterBody3D
class_name FirstPersonMovement

@onready var pitch: Node3D = %Pitch
@onready var camera: Camera3D = %Camera3D

@export var speed: float = 1
@export var sprint_speed_mult: float = 2

const sens: int = 150

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
	var input: Vector3
	if (Input.is_action_pressed("up")):
		input.z -= 1
	if (Input.is_action_pressed("down")):
		input.z += 1
	if (Input.is_action_pressed("right")):
		input.x += 1
	if (Input.is_action_pressed("left")):
		input.x -= 1
	
	var sprinting: float = 1
	if (Input.is_action_pressed("sprint")):
		sprinting = sprint_speed_mult
		
	velocity = global_basis * input * speed * sprinting
	if (!is_on_floor()):
		velocity += Vector3.DOWN * 2
		
	move_and_slide()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_motion = event.screen_relative
		rotate_y(deg_to_rad(-mouse_motion.x / sens * PI))
		%Pitch.rotate_x(deg_to_rad(-mouse_motion.y / sens * PI))
		%Pitch.rotation.x = clamp(%Pitch.rotation.x, deg_to_rad(-90), deg_to_rad(90))
