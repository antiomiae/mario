extends Node2D

enum { NORMAL, GRAPPLING }

enum { CW, CCW }

enum { RIGHT, LEFT }

export(float) var speed = 67
onready var grappling_hook = $GrapplingHook
var debug_movement = false
var movement_state = GRAPPLING
var swing_direction = CCW
var facing_state = RIGHT
var grappling_speed = 1 * 60


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
    if movement_state == NORMAL:
        if Input.is_action_just_pressed("grapple"):
            grapple_to_anchor()
    match movement_state:
        NORMAL:
            _normal_movement(delta)
        GRAPPLING:
            _grappling_movement(delta)

    $Sprite.flip_h = is_facing_left()


func _normal_movement(delta):
    _debug_movement(delta)


func _grappling_movement(delta):
    if !Input.is_action_pressed("grapple"):
        grappling_hook.detach_from_anchor()

    if grappling_hook.is_attached():
        var d = _swing(delta)
        position += d
        if should_detach(d):
            grappling_hook.detach_from_anchor()
            movement_state = NORMAL
    else:
        movement_state = NORMAL


func _swing(delta):
    var tether_vec = grappling_hook.tether_vector()
    var tether_length = tether_vec.length()
    var angular_displacement = grappling_speed * delta / tether_length
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