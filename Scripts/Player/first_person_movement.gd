extends CharacterBody3D
class_name FirstPersonMovement

@onready var pitch: Node3D = %Pitch
@onready var camera: Camera3D = %Camera3D

@export var speed: float = 1
@export var sprint_speed_mult: float = 2

const sens: int = 150
var in_debug: bool = true
var debug_movement: float = 10

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	toggle_debug_cam()

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
	if (Input.is_action_just_pressed("EnterDebugCam")):
		toggle_debug_cam()
 
	var sprinting: float = 1
	if (Input.is_action_pressed("sprint")):
		sprinting = sprint_speed_mult
		
	velocity = global_basis * input * speed * sprinting * debug_movement
	if (!is_on_floor()):
		velocity += Vector3.DOWN * 2
		
	move_and_slide()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_motion = event.screen_relative
		rotate_y(deg_to_rad(-mouse_motion.x / sens * PI))
		%Pitch.rotate_x(deg_to_rad(-mouse_motion.y / sens * PI))
		%Pitch.rotation.x = clamp(%Pitch.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		
func toggle_debug_cam():
		if !in_debug:
			debug_movement = 10
			in_debug = true
			%Pitch.position.y = 25
			%Pitch.rotation.x = deg_to_rad(-85)
			$".".axis_lock_linear_y = true
			$CapsuleCollider.set_deferred("disabled", true)
			%Camera3D.set_projection(Camera3D.PROJECTION_ORTHOGONAL)
			%Camera3D.set_projection(Camera3D.PROJECTION_ORTHOGONAL)
			%Camera3D.size = 50
		else:
			debug_movement = 1
			in_debug = false
			%Pitch.position.y = 1
			%Pitch.rotation.x = deg_to_rad(0)
			$".".axis_lock_linear_y = false
			$CapsuleCollider.set_deferred("disabled", false)
			%Camera3D.set_projection(Camera3D.PROJECTION_PERSPECTIVE)
