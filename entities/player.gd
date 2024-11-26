extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const CAM_SENS = 50

@onready var timer = $Timer
@onready var camera = $Camera3D

var look_dir: Vector2
var teleported = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if Input.is_action_just_pressed("Pause"):
		get_tree().quit()
	_rotate_camera(delta)
	move_and_slide()


func _input(event: InputEvent):
	if event is InputEventMouseMotion: look_dir = event.relative * 0.01


func _rotate_camera(delta: float, sens_mod: float = 1.0):
	var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	look_dir += input
	rotation.y -= look_dir.x * CAM_SENS * delta
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * CAM_SENS * sens_mod * delta, -1.5, 1.5)
	look_dir = Vector2.ZERO


func _on_timer_timeout():
	teleported = false
