extends KinematicBody2D

enum { NORMAL, GRAPPLING }

enum { CW, CCW }

enum { RIGHT, LEFT }

enum { FALLING, JUMPING, ON_GROUND }

export(float) var speed = 67
onready var grappling_hook = $GrapplingHook
var debug_movement = false
var movement_state = GRAPPLING
var air_state = ON_GROUND
var swing_direction = CCW
var facing_state = RIGHT

var grappling_speed = 4.5
var jump_speed = -4
var max_fall_speed = 4

var max_run_speed = 2

var gravity = 0.3

var velocity = Vector2(0, 0)

const H_ACC = {
    ON_GROUND: 0.1,
    FALLING: 0.05,
    JUMPING: 0.08
}


func _physics_process(delta):
    if debug_movement:
        _debug_movement(delta)
    else:
        movement(delta)


func _debug_movement(delta):
    var v = Vector2(0, 0)
    if Input.is_action_pressed("ui_left"):
        v.x -= 1
    if Input.is_action_pressed("ui_right"):
        v.x += 1
    if Input.is_action_pressed("ui_up"):
        v.y -= 1
    if Input.is_action_pressed("ui_down"):
        v.y += 1

    position += v * speed * delta

    if v.x > 0:
        facing_state = RIGHT
    elif v.x < 0:
        facing_state = LEFT

    if v.x != 0:
        $AnimationPlayer.play("run")
    else:
        $AnimationPlayer.play("stand")


func movement(delta):
    update_facing_state()

    match movement_state:
        NORMAL:
            _normal_movement(delta)
        GRAPPLING:
            _grappling_movement(delta)

    update_sprite()


func update_facing_state():
    var x_input = x_input_strenth()
    if x_input > 0:
        facing_state = RIGHT
    elif x_input < 0:
        facing_state = LEFT


func update_sprite():
    $Sprite.flip_h = is_facing_left()


func x_input_strenth():
    return Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")


func _normal_movement(delta):
    var x_input = x_input_strenth()

    if x_input != 0:
        apply_horizontal_input(x_input)
    elif velocity.x != 0:
        apply_horizontal_drag()

    if Input.is_action_just_pressed("jump") and air_state == ON_GROUND:
        jump()

    apply_gravity()

    var new_v = move_and_slide(velocity * 60.0, Vector2(0, -1.0)) * (1.0/60)

    if air_state == ON_GROUND and new_v.y != 0:
        air_state = FALLING

    if is_on_floor() or (new_v.y == 0 and velocity.y > 0):
        air_state = ON_GROUND


    velocity = new_v

    if air_state != ON_GROUND and Input.is_action_pressed("grapple"):
        grapple_to_anchor()

    update_animation()


func update_animation():
    if air_state == ON_GROUND:
        if velocity.x != 0:
            $AnimationPlayer.play("run")
        else:
            $AnimationPlayer.play("stand")
    else:
        $AnimationPlayer.play("stand")


func apply_horizontal_drag():
    if air_state == ON_GROUND:
        if abs(velocity.x) <= H_ACC[ON_GROUND]:
            velocity.x = 0
        else:
            velocity.x -= H_ACC[ON_GROUND] * sign(velocity.x)


func apply_horizontal_input(x_input):
    velocity.x += x_input * H_ACC[air_state]
    velocity.x = clamp(velocity.x, -max_run_speed * abs(x_input), max_run_speed * abs(x_input))


func apply_gravity():
    velocity.y += gravity

    velocity.y = min(velocity.y, max_fall_speed)


func jump():
    velocity.y = jump_speed
    air_state = JUMPING


func _grappling_movement(delta):
    if grappling_hook.is_attached():
        velocity = _swing(delta)

        var new_v = move_and_slide(velocity * 60, Vector2(0, -1))*(1.0/60)

        if has_collided() or should_detach(velocity) or !Input.is_action_pressed("grapple"):
            grappling_hook.detach_from_anchor()
            movement_state = NORMAL

            air_state = ON_GROUND if new_v.y == 0 else FALLING

            Input.action_release("grapple")

        velocity = new_v
    else:
        movement_state = NORMAL


func has_collided():
    return get_slide_count() > 0


func _swing(delta):
    var tether_vec = grappling_hook.tether_vector()
    var tether_length = tether_vec.length()
    var angular_displacement = grappling_speed / tether_length
    if swing_direction == CCW:
        angular_displacement = -angular_displacement
    var displacement = tether_vec.rotated(angular_displacement) - tether_vec

    return displacement


func should_detach(delta_pos):
    # points from anchor to emitter of grappling hook
    var tether_vec = grappling_hook.tether_vector()
    var angle = tether_vec.angle()

    # swinging upward
    if delta_pos.y < 0:
        # close to horizontal
        if tether_vec.x > 0 and angle <= 0:
            return true
        elif tether_vec.x < 0 and (angle == PI or angle < 0):
            return true

    return false


func grapple_to_anchor():
    var possible_anchors = grappling_hook.anchor_nodes
    var anchor = null
    var emitter_pos = grappling_hook.to_global(grappling_hook.emitter_position)

    if possible_anchors.size() > 0:
        for a in possible_anchors:
            if a.position.y <= emitter_pos.y:
                if a.position.x > emitter_pos.x && is_facing_right() or a.position.x < emitter_pos.x && is_facing_left():
                    if anchor == null or (a.position.x < anchor.position.x && is_facing_right()) or (a.position.x > anchor.position.x && is_facing_left()):
                        anchor = a

        if anchor != null:
            grappling_hook.attach_to_anchor(anchor)
            movement_state = GRAPPLING

            if is_facing_right():
                swing_direction = CCW
            else:
                swing_direction = CW


func is_facing_right():
    return facing_state == RIGHT


func is_facing_left():
    return facing_state == LEFT

