extends KinematicBody2D
	
enum MotionState {WALKING, JUMPING}

const SLOW_WALK_SPEED = 1.5625
const SLOW_WALK_ACCELERATION = 0.037109375

#const WALK_FRICTION = 0.05078125
const WALK_FRICTION = 0.1015625
const WALK_SPEED = 3.5
const WALK_ACCELERATION = 0.0556640625
#const WALK_ACCELERATION = 0.89
const JUMP_SPEED = 5
const MAX_FALL_SPEED = 4.5
const CLAMP_FALL_SPEED = 4.0
const AIR_WALK_SPEED = 3.5
const AIR_WALK_ACCELERATION = 0.0556640625
const AIR_WALK_FRICTION = 0

const GRAVITY = 0.15625 # 0.1
const HIGH_GRAVITY = 0.5625
const UP = Vector2(0, -1)

var motion_state = MotionState.WALKING
var velocity : Vector2 = Vector2(0, 0)
var has_jumped : bool = false

onready var camera = get_parent().get_node("camera")

func _ready():
	pass
	

func _physics_process(delta):
	match motion_state:
		MotionState.WALKING:
			movement_walking(delta)
		MotionState.JUMPING:
			movement_jumping(delta)

	camera.offset = position - Vector2(320,240)/2

func movement_walking(delta):	
	horizontal_input(WALK_SPEED, WALK_ACCELERATION, WALK_FRICTION, delta)
	velocity.x = clamp(velocity.x, -WALK_SPEED, WALK_SPEED)
	velocity.y = GRAVITY
	
	velocity = move_and_slide(velocity/delta, UP)*delta

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
	elif !Input.is_action_pressed("jump"):
		velocity.y += HIGH_GRAVITY		
	else:
		velocity.y += GRAVITY
		
	if velocity.y > MAX_FALL_SPEED:
		velocity.y = CLAMP_FALL_SPEED
	
	horizontal_input(AIR_WALK_SPEED, AIR_WALK_ACCELERATION, 0, delta)
	velocity = move_and_slide(velocity/delta, UP)*delta
	
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
			velocity.x += sign(input_dir) * acceleration
	elif abs(velocity.x) > 0 and friction != 0:
		# apply drag to slowdown character to a stop
		if abs(velocity.x) <= friction:
			velocity.x = 0
		else:
			velocity.x -= sign(velocity.x) * friction

func is_walk_pressed() -> bool:
	return Input.is_action_pressed("walk_left") || Input.is_action_pressed("walk_right")
