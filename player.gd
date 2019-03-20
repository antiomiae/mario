extends KinematicBody2D
	
enum MotionState {WALKING, JUMPING}

const SKID_ACCELERATION = 10 * 60
const WALK_SPEED = 5 * 60
const WALK_ACCELERATION = 8 * 60
const JUMP_SPEED = 10 * 60

const GRAVITY = 20 * 60

const UP = Vector2(0, -1)

var velocity : Vector2 = Vector2(0, 0)

func _ready():
	print("_ready()")
	
	var n = get_parent().get_node("TileMap")
	print(n)

var motion_state = MotionState.WALKING

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

func movement_walking(delta):	
	var input_dir = 0
	if is_walk_pressed():
		if Input.is_action_pressed("walk_left"):
			input_dir -= 1
		if Input.is_action_pressed("walk_right"):
			input_dir += 1
	
	if input_dir != 0:
		if abs(velocity.x) < WALK_SPEED:
			velocity.x += sign(input_dir) * WALK_ACCELERATION * delta				
	else:
		# apply drag to slowdown character to a stop
		if abs(velocity.x) > 0:
			if abs(velocity.x) * delta < 1:
				velocity.x = 0
			else:
				velocity.x -= sign(velocity.x) * SKID_ACCELERATION * delta
	
	velocity.x = clamp(velocity.x, -WALK_SPEED, WALK_SPEED)
	velocity.y = 1
	
	var new_velocity = move_and_slide(velocity, UP)
	velocity.y = new_velocity.y
	
	var colls = []
	for i in range(get_slide_count()):
		colls.push_back(get_slide_collision(i))
	
	var state = {
		"ceiling": is_on_ceiling(),
		"floor": is_on_floor(),
		"wall": is_on_wall()	
	}
	
	if !is_on_floor():
		motion_state = MotionState.JUMPING;
	if is_on_wall():
		velocity.x = 0
			
	
func is_walk_pressed() -> bool:
	return Input.is_action_pressed("walk_left") || Input.is_action_pressed("walk_right")



func movement_jumping(delta):
	if is_on_floor() and Input.is_action_pressed("jump"):
		velocity.y = -JUMP_SPEED
	else:
		velocity.y += GRAVITY * delta
	
	var new_velocity = move_and_slide(velocity, UP)
	
	if is_on_floor():
		velocity.y = 0
		motion_state = MotionState.WALKING


	