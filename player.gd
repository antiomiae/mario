extends KinematicBody2D

enum MotionState {WALKING, JUMPING}

const SLOW_WALK_SPEED = 1.5625
const SLOW_WALK_ACCELERATION = 0.037109375

#const WALK_FRICTION = 0.05078125
const WALK_FRICTION = 0.1015625
const WALK_SKID = WALK_FRICTION
const WALK_SPEED = 3.5314159
const WALK_ACCELERATION = 0.0556640625
#const WALK_ACCELERATION = 0.89
const JUMP_SPEED = 5
const MAX_FALL_SPEED = 4.51414
const CLAMP_FALL_SPEED = 4.0141414
const AIR_WALK_SPEED = 3.5
const AIR_WALK_ACCELERATION = 0.0556640625
const AIR_WALK_FRICTION = 0

const GRAVITY = 0.15625 # 0.1
const HIGH_GRAVITY = 0.5625
const UP = Vector2(0, -1)

var motion_state = MotionState.WALKING
var velocity : Vector2 = Vector2(0, 0)
var last_velocity = velocity
var has_jumped : bool = false
var was_on_floor = is_on_floor()

onready var camera = get_parent().get_node("camera")

func _ready():
    pass


func _physics_process(delta):
    if Input.is_key_pressed(KEY_P):
        print("pause")
    was_on_floor = is_on_floor()
    match motion_state:
        MotionState.WALKING:
            movement_walking(delta)
        MotionState.JUMPING:
            movement_jumping(delta)

    last_velocity = velocity


func get_collisions():
    var collisions = []
    for i in range(get_slide_count()):
        collisions.push_back(get_slide_collision(i))

    return collisions



func movement_walking(delta):
    horizontal_input(WALK_SPEED, WALK_ACCELERATION, WALK_FRICTION, WALK_SKID, delta)
    velocity.x = clamp(velocity.x, -WALK_SPEED, WALK_SPEED)
    velocity.y = GRAVITY

    last_velocity = velocity
    velocity = move_and_slide_with_snap(velocity*60, Vector2(0, 1), UP)*delta

    handle_tile_ledge()

    if was_on_floor and Input.is_action_just_pressed("jump"):
        motion_state = MotionState.JUMPING
        has_jumped = false
    elif !is_on_floor():
        motion_state = MotionState.JUMPING
        has_jumped = true


# snap player above ledge if just missed
func handle_tile_ledge():
    if velocity.y < 0 or is_on_ceiling():
        return

    var collisions = get_collisions()
    var front_colliding_tiles = []

    if collisions.size() > 0:
        for c in collisions:
            if c.normal.x != 0:
                front_colliding_tiles.push_back(c)

    if (front_colliding_tiles.size() > 0 and
        last_velocity.x != 0):

        front_colliding_tiles.sort_custom(CollisionSortByY, "sort")
        var c = front_colliding_tiles.front()
        var pos = c.position

        var tile_index = $"../TileMap".world_to_map(Vector2(pos.x - c.normal.x, pos.y))
        var cell = $"../TileMap".get_cell(tile_index.x, tile_index.y)
        # bail if there's no tile to collide with
        if cell < 0:
            return

        var tile_y = tile_index.y
        var cell_height = $"../TileMap".cell_size.y

        var foot_y = to_global(Vector2(0, 15)).y

        if tile_y * cell_height + 5 > foot_y:
            var d = tile_y * cell_height - foot_y - 0.125
            var old_y = position.y

            var test_xform = transform.translated(Vector2(0, d))

            var will_collide = test_move(test_xform, Vector2(last_velocity.x, 0))

            if !will_collide:
                move_local_y(d)
                velocity.x = last_velocity.x
                velocity.y = 0


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

    horizontal_input(AIR_WALK_SPEED, AIR_WALK_ACCELERATION, 0, 0, delta)
    last_velocity = velocity
    velocity = move_and_slide(velocity*60, UP)*delta

    handle_tile_ledge()

    if was_on_floor and Input.is_action_just_pressed("jump"):
        motion_state = MotionState.JUMPING
        has_jumped = false
    elif is_on_floor():
        has_jumped = false
        velocity.y = 0
        if Input.is_action_just_pressed("jump"):
            motion_state = MotionState.JUMPING
        else:
            motion_state = MotionState.WALKING

func horizontal_input(speed, acceleration, friction, brake, delta):
    var input_dir = 0

    if is_walk_pressed():
        if Input.is_action_pressed("walk_left"):
            input_dir -= 1
        if Input.is_action_pressed("walk_right"):
            input_dir += 1

    if input_dir != 0:
        if abs(velocity.x) < speed:
            velocity.x += sign(input_dir) * acceleration
        if sign(velocity.x) != input_dir:
            velocity.x += sign(input_dir) * max(acceleration, brake)
    elif abs(velocity.x) > 0 and friction != 0:
        # apply drag to slowdown character to a stop
        if abs(velocity.x) <= friction:
            velocity.x = 0
        else:
            velocity.x -= sign(velocity.x) * friction

func is_walk_pressed() -> bool:
    return Input.is_action_pressed("walk_left") || Input.is_action_pressed("walk_right")

# for sorting collisions by y position with Array#sort_custom. Collisions with smaller y position
# come before larger ones, a.k.a. highest first
class CollisionSortByY:
    static func sort(a, b):
        if a.position.y < b.position.y:
            return true
        return false