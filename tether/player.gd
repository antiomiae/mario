extends KinematicBody2D

class_name Player

signal died(body)

enum { NORMAL, GRAPPLING }

enum { CW, CCW }

enum { RIGHT, LEFT }

enum { FALLING, JUMPING, ON_GROUND, DEAD }

var crouching = false

export(float) var speed = 67
onready var grappling_hook = $GrapplingHook

export(int, 1, 2) var player_number = 1

var debug_movement = false
var movement_state = GRAPPLING
var air_state = ON_GROUND
var swing_direction = CCW
var facing_state = RIGHT

var grappling_speed = 4
var jump_speed = -3
var max_fall_speed = 3

var max_run_speed = 2

var gravity = 0.15

var velocity = Vector2(0, 0)

var _corpse = null
var _current_anchor = null

const H_ACC = {
    ON_GROUND: 0.1,
    FALLING: 0.05,
    JUMPING: 0.08
}

const brake_acc = 0.25
const slide_acc = 0.04

var StiffBody = preload("res://stiff_body.tscn")

func _ready():
    $Cannon.bullet_collision_mask = LayerNames.physics_layer('map')|LayerNames.physics_layer('player')
    $Cannon.exclude_body(self)


func _physics_process(delta):
    if debug_movement:
        _debug_movement(delta)
    else:
        if movement_state != DEAD:
            $standing_hitbox.disabled = crouching
            $crouching_hitbox.disabled = !crouching
            movement(delta)
        else:
            position = _corpse.position
            rotation = _corpse.rotation


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


func input(action):
    return PlayerInput.get_player_action(action, player_number)


func movement(delta):
    if movement_state != DEAD:
        update_facing_state()

    match movement_state:
        NORMAL:
            _normal_movement(delta)
        GRAPPLING:
            _grappling_movement(delta)

    if Input.is_action_just_pressed(input("shoot")):
        $Cannon.shoot()

    update_sprite()


func update_facing_state():
    var x_input = x_input_strenth()
    if x_input > 0:
        facing_state = RIGHT
    elif x_input < 0:
        facing_state = LEFT


func update_sprite():
    update_animation()
    var new_scale = 1 if is_facing_right() else -1
    $Sprite.scale.x = new_scale
    $Cannon.scale.x = new_scale


func x_input_strenth():
    return Input.get_action_strength(input("walk_right")) - Input.get_action_strength(input("walk_left"))


func _normal_movement(delta):
    var x_input = x_input_strenth()

    crouching = Input.is_action_pressed(input("down"))

    if x_input != 0 and not crouching:
        apply_horizontal_input(x_input)
    elif velocity.x != 0:
        apply_horizontal_drag()

    if Input.is_action_just_pressed(input("jump")) and air_state == ON_GROUND:
        jump()

    if Input.is_action_just_released(input("jump")) and air_state == JUMPING:
        velocity.y = max(velocity.y, jump_speed*0.2)

    apply_gravity()

    var snap = Vector2(0, 3) if air_state == ON_GROUND else Vector2(0, 0)

    var new_v = move_and_slide_with_snap(velocity * 60, snap, Vector2(0, -1), false, 4, 0.785398, false)*(1/60.0)

    if air_state == ON_GROUND and new_v.y != 0:
        air_state = FALLING

    if is_on_floor() or (new_v.y == 0 and velocity.y > 0):
        air_state = ON_GROUND

    velocity = new_v

    _update_current_anchor()
    if Input.is_action_pressed(input("grapple")) and air_state != ON_GROUND:
        grapple_to_anchor()


func update_animation():
    if air_state == ON_GROUND and movement_state != DEAD:
        if crouching:
            if velocity.x == 0:
                $AnimationPlayer.play("crouch")
            else:
                $AnimationPlayer.play("slide")
        elif velocity.x != 0:
            $AnimationPlayer.play("run")
        else:
            $AnimationPlayer.play("stand")
    elif movement_state == FALLING:
        if crouching:
            $AnimationPlayer.play("crouch")
        else:
            $AnimationPlayer.play("stand")
    elif movement_state == GRAPPLING or movement_state == DEAD:
        $AnimationPlayer.play("stand")


func apply_horizontal_drag():
    if air_state == ON_GROUND:
        var friction = slide_acc if crouching else brake_acc
        if abs(velocity.x) <= friction:
            velocity.x = 0
        else:
            velocity.x -= friction * sign(velocity.x)


func apply_horizontal_input(x_input):
    if abs(velocity.x) < max_run_speed * abs(x_input) or sign(x_input) != sign(velocity.x):
        velocity.x += x_input * H_ACC[air_state]


func apply_gravity():
    # if we're moving up, don't apply gravity
    if air_state == ON_GROUND and get_floor_velocity().y < 0:
        pass
    else:
        velocity.y += gravity
    velocity.y = min(velocity.y, max_fall_speed)


func jump():
    velocity.y = jump_speed
    air_state = JUMPING


func _grappling_movement(delta):
    if grappling_hook.is_attached():
        velocity = swing(delta)

        var new_v = move_and_slide(velocity * 60, Vector2(0, -1))*(1.0/60)

        if (has_collided() and (is_on_wall() or is_on_ceiling())) or should_detach(new_v) or !Input.is_action_pressed(input("grapple")):
            grappling_hook.detach_from_anchor()
            movement_state = NORMAL

            air_state = ON_GROUND if is_on_floor() else FALLING

            Input.action_release(input("grapple"))

        velocity = new_v
    else:
        movement_state = NORMAL


func has_collided():
    return get_slide_count() > 0


func swing(delta):
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
    # FIXME: use normal of tether_vec instead of tether_vec and its angle
    # swinging upward
    if delta_pos.y < 0:
        # close to horizontal
        if tether_vec.x > 0 and angle <= 0:
            return true
        elif tether_vec.x < 0 and (angle == PI or angle < 0):
            return true

    return false


func _update_current_anchor():
    var possible_anchors = grappling_hook.anchor_nodes
    var anchor = null
    var emitter_pos = grappling_hook.to_global(grappling_hook.emitter_position)

    if possible_anchors.size() > 0:
        for a in possible_anchors:
            if a.position.y <= emitter_pos.y:
                if a.position.x > emitter_pos.x && is_facing_right() or a.position.x < emitter_pos.x && is_facing_left():
                    if anchor == null or (a.position.x < anchor.position.x && is_facing_right()) or (a.position.x > anchor.position.x && is_facing_left()) or (a.position.y > anchor.position.y):
                        anchor = a
        if anchor != null:
            if _current_anchor != anchor:
                if _current_anchor:
                    _current_anchor.on_lost()
                anchor.on_detected()
            _current_anchor = anchor
        else:
            if _current_anchor:
                _current_anchor.on_lost()
                _current_anchor = null
    elif _current_anchor != null:
        _current_anchor.on_lost()
        _current_anchor = null


func grapple_to_anchor():
    if _current_anchor != null:
        grappling_hook.attach_to_anchor(_current_anchor)
        movement_state = GRAPPLING
        crouching = false

        if is_facing_right():
            swing_direction = CCW
        else:
            swing_direction = CW


func is_facing_right():
    return facing_state == RIGHT


func is_facing_left():
    return facing_state == LEFT


func on_bullet_hit(collision_dict : ProjectileCollision):
    movement_state = DEAD

    var new_body = StiffBody.instance()
    get_tree().current_scene.add_child(new_body, true)
    new_body.position = self.position
    new_body.get_node("CollisionShape2D").shape = $standing_hitbox.shape.duplicate(true)


    #self.visible = false
    $standing_hitbox.disabled = true
    $crouching_hitbox.disabled = true

    new_body.collision_layer = collision_layer
    new_body.collision_mask = collision_mask

    var local_pos = new_body.to_local(collision_dict.position)
    var bullet = collision_dict.projectile
    var vel = collision_dict.velocity
    var impact_vel = -velocity.project(vel)*20
    new_body.inertia = 20
    new_body.apply_impulse(local_pos, vel+impact_vel)

    _corpse = new_body

    died()


func died():
    emit_signal("died", self)