extends KinematicBody2D

signal life_lost(lives_left)

class MovementParameters:
    var jump_speed : float
    var fall_speed : float
    var walk_speed : float
    var walk_acceleration : float
    var friction : float
    var gravity : float

    func _init(_jump_speed, _fall_speed, _walk_speed, _walk_acceleration, _friction, _gravity):
        jump_speed = _jump_speed
        fall_speed = _fall_speed
        walk_speed = _walk_speed
        walk_acceleration = _walk_acceleration
        friction = _friction
        gravity = _gravity


var MOVEMENT_PARAMETERS = {
    'ground': MovementParameters.new(5, 5, 2, 0.15, 0.3, 0.2),
    'air': MovementParameters.new(5, 2, 2, 0.05, 0.005, 0.2)
}

var velocity := Vector2.ZERO
var last_velocity := Vector2.ZERO
export var total_lives : int = 3
var lives_left : int = total_lives

var _current_movement_parameters = MOVEMENT_PARAMETERS['ground']
var _invulnerable = false
var _facing := 1

var ground_controller = GroundController.new(self)
var air_controller = AirController.new(self)
var dead_controller = DeadController.new(self)
var state_controller = ground_controller
onready var input_controller = $DuckController

var idle_frames := 0

var alive = true

func update_sprite():
    $Sprite.flip_h = _facing == -1

func _ready():
    _init_lives()
    stand()
    #set_animation(animation)

func _physics_process(delta):
    last_velocity = velocity
    state_controller.process(delta)
    if input_controller.walk != 0:
        _facing = sign(input_controller.walk)
    update_sprite()
    idle_timer()

func _init_lives():
    assert(total_lives > 0)
    lives_left = total_lives

func idle_timer():
    if state_controller == ground_controller && velocity == Vector2.ZERO:
        idle_frames += 1
    else:
        idle_frames = 0

func jump_input():
    return input_controller.jump && !input_controller.last_jump


func set_animation(anim_name):
    $AnimationPlayer.play(anim_name)


func set_controller(controller : StateController):
    if state_controller != controller:
        state_controller.exit()
        controller.enter()
        state_controller = controller

func idle():
    set_animation('idle')

func walk():
    _current_movement_parameters = MOVEMENT_PARAMETERS['ground']
    set_animation('walk')
    set_controller(ground_controller)

func stand():
    _current_movement_parameters = MOVEMENT_PARAMETERS['ground']
    set_animation('stand')
    set_controller(ground_controller)

func fall():
    _current_movement_parameters = MOVEMENT_PARAMETERS['air']
    set_animation('fall')
    set_controller(air_controller)

func jump():
    _current_movement_parameters = MOVEMENT_PARAMETERS['air']
    set_animation('fall')
    set_controller(air_controller)

func land():
    _current_movement_parameters = MOVEMENT_PARAMETERS['ground']
    set_animation('stand')
    set_controller(ground_controller)

func die():
    alive = false
    set_animation('dead')
    set_controller(dead_controller)

func make_invulnerable(should = true):
    _invulnerable = should
    set_collision_layer_bit(LayerNames.physics_layer('enemy'), !should)

func basic_damage():
    if _invulnerable:
        return

    $sprite_effects.play('damage_blink')
    make_invulnerable(true)
    lose_life()

    if lives_left < 1:
        die()

    velocity = Vector2(-2*_facing, -3)
    yield(get_tree().create_timer(2, false), "timeout")
    $sprite_effects.play('reset')
    make_invulnerable(false)

func lose_life():
    if lives_left > 0:
        lives_left -= 1
    emit_signal('life_lost', lives_left)


func on_spike_hit(spikes):
    state_controller.on_spike_hit(spikes)





class StateController:
    var parent

    func _init(_parent):
        parent = _parent

    func process(delta):
        pass

    func enter():
        pass

    func exit():
        pass

    func on_spike_hit(spikes):
        if parent.alive:
            parent.basic_damage()

    func just_jumped():
        return parent.input_controller.jump && !parent.input_controller.last_jump

    func movement_parameters() -> MovementParameters:
        return parent._current_movement_parameters

    func walk():
        var walk_input = parent.input_controller.walk
        var change_direction = sign(walk_input) != sign(parent.velocity.x) && parent.velocity.x != 0
        # stop
        if change_direction:
            parent.velocity.x = 0
        else:
            var walk_speed = movement_parameters().walk_speed
            if abs(walk_input) > 0.5:
                if abs(parent.velocity.x) < walk_speed:
                    parent.velocity.x += sign(walk_input)*movement_parameters().walk_acceleration
            else:
                var vx = sign(walk_input)*movement_parameters().walk_acceleration + parent.velocity.x
                parent.velocity.x = clamp(vx, -abs(walk_input)*walk_speed, abs(walk_input)*walk_speed)

    func skid():
        var friction = movement_parameters().friction
        if friction != 0 and parent.velocity.x != 0:
            parent.velocity.x = sign(parent.velocity.x)*max((abs(parent.velocity.x)-friction), 0)


class AirController extends StateController:
    var jump_count := 0
    const max_jumps = 1

    func _init(_parent).(_parent):
        parent = _parent

    func _enter():
        jump_count = 0

    func process(delta):
        update_velocity()
        handle_jump()
        parent.velocity = parent.move_and_slide(parent.velocity*60, Vector2(0, -1))*(1.0/60.0)

        if parent.is_on_floor():
            jump_count = 0
            parent.land()

    func handle_jump():
        if just_jumped() && jump_count < max_jumps:
            parent.velocity.y = -movement_parameters().jump_speed
            jump_count += 1

    func update_velocity():
        var walk_input = parent.input_controller.walk
        if walk_input != 0:
            walk()
        else:
            skid()
        parent.velocity.y = min(movement_parameters().gravity + parent.velocity.y, movement_parameters().fall_speed)


class GroundController extends StateController:
    func _init(_parent).(_parent):
        parent = _parent

    func process(delta):
        update_velocity()
        parent.velocity = parent.move_and_slide_with_snap(
            parent.velocity*60,
            Vector2(0, 2),
            Vector2(0, -1),
            true
        )*(1.0/60.0)

        var action = null

        if parent.velocity.x != 0:
            action = 'walk'
        else:
            action = 'stand'

        if !parent.is_on_floor():
            action = 'fall'
        elif just_jumped():
            parent.velocity.y = -movement_parameters().jump_speed
            action = 'jump'
        else:
            if parent.idle_frames >= 120:
                action = 'idle'
        if action:
            parent.call(action)

    func update_velocity():
        var walk_input = parent.input_controller.walk
        if walk_input != 0:
            walk()
        else:
            skid()
        parent.velocity.y += movement_parameters().gravity


class DeadController extends StateController:
    func _init(parent).(parent):
        pass

    func enter():
        parent.alive = false
        self.parent._current_movement_parameters = parent.MOVEMENT_PARAMETERS['air']
        self.parent.set_collision_mask_bit(LayerNames.physics_layer('enemy'), false)

    func process(delta):
        parent.velocity.y += movement_parameters().gravity
        parent.velocity = parent.move_and_slide(parent.velocity*60, Vector2(0, -1))*(1.0/60.0)
        if parent.is_on_floor():
            parent.velocity = Vector2.ZERO
