extends KinematicBody2D
	
enum MotionState {WALKING, JUMPING}

const WALK_FRICTION = 15 * 60
const WALK_SPEED = 3.5 * 60
const WALK_ACCELERATION = 6 * 60
const JUMP_SPEED = 6 * 60
const AIR_WALK_SPEED = 4 * 60
const AIR_WALK_ACCELERATION = 3 * 60
const AIR_WALK_FRICTION = 4 * 60

const GRAVITY = 15 * 60
const UP = Vector2(0, -1)

var motion_state = MotionState.WALKING
var velocity : Vector2 = Vector2(0, 0)
var has_jumped : bool = false

onready var camera = get_parent().get_node("camera")
onready var tilemap = get_parent().get_node("TileMap")

func _ready():
	pass
	

func _physics_process(delta):
	
	var state = {
		"ceiling": is_on_ceiling(),
		"floor": is_on_floor(),
		"wall": is_on_wall()	
	}
	
	match motion_state:
		MotionState.WALKING:
			movement_walking(delta)
		MotionState.JUMPING:
			movement_jumping(delta)

	camera.offset = position - Vector2(320,240)/2
	#camera.align()

func movement_walking(delta):	
	horizontal_input(WALK_SPEED, WALK_ACCELERATION, WALK_FRICTION, delta)
	velocity.x = clamp(velocity.x, -WALK_SPEED, WALK_SPEED)
	velocity.y = GRAVITY * delta
	
	velocity = move_and_slide(velocity, UP)

	var state = {
		"ceiling": is_on_ceiling(),
		"floor": is_on_floor(),
		"wall": is_on_wall()	
	}
	
	if !is_on_floor():
		motion_state = MotionState.JUMPING
		has_jumped = true
	else:
		if Input.is_action_just_pressed("jump"):
			motion_state = MotionState.JUMPING
			has_jumped = false


func movement_jumping(delta):
	if !has_jumped:
		velocity.y = -JUMP_SPEED
		has_jumped = true
	elif Input.is_action_just_released("jump"):
		velocity.y = max(-JUMP_SPEED/3.0, velocity.y)
	else:
		velocity.y += GRAVITY * delta
	
	horizontal_input(AIR_WALK_SPEED, AIR_WALK_ACCELERATION, AIR_WALK_FRICTION, delta)
	velocity = move_and_slide(velocity, UP)
	
	if is_on_floor():
		has_jumped = false
		velocity.y = 0
		motion_state = MotionState.WALKING

func horizontal_input(speed, acceleration, friction, delta):
	var input_dir = 0
	
	if is_walk_pressed():
		if Input.is_action_pressed("walk_left"):
			input_dir -= 1
		if Input.is_action_pressed("walk_right"):
			input_dir += 1
	
	if input_dir != 0:
		if abs(velocity.x) < speed:
			velocity.x += sign(input_dir) * acceleration * delta
	else:
		# apply drag to slowdown character to a stop
		if abs(velocity.x) > 0:
			if abs(velocity.x) * delta < 1:
				velocity.x = 0
			else:
				velocity.x -= sign(velocity.x) * friction * delta

func is_walk_pressed() -> bool:
	return Input.is_action_pressed("walk_left") || Input.is_action_pressed("walk_right")
