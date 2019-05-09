extends KinematicBody2D

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

    func just_jumped():
        return parent.input_controller.jump && !parent.input_controller.last_jump

    func movement_parameters() -> MovementParameters:
        return parent._current_movement_parameters

    func walk():
        var walk_input = parent.walk_input()
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
                var vx = movement_parameters().walk_acceleration + parent.velocity.x
                parent.velocity.x = clamp(vx, -abs(walk_input)*walk_speed, abs(walk_input)*walk_speed)

    func skid():
        var friction = movement_parameters().friction
        if friction != 0 and parent.velocity.x != 0:
            parent.velocity.x = sign(parent.velocity.x)*max((abs(parent.velocity.x)-friction), 0)


class AirController extends StateController:
    func _init(_parent).(_parent):
        parent = _parent

    func process(delta):
        update_velocity()
        parent.velocity = parent.move_and_slide(parent.velocity*60, Vector2(0, -1))*(1.0/60.0)

        if parent.is_on_floor():
            parent.land()


    func update_velocity():
        var walk_input = parent.walk_input()
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
        parent.velocity = parent.move_and_slide_with_snap(parent.velocity*60, Vector2(0, 2), Vector2(0, -1))*(1.0/60.0)
        if parent.velocity.x != 0:
            parent.walk()
        else:
            parent.stand()

        if parent.velocity.y > 0 || !parent.is_on_floor():
            parent.fall()
        elif just_jumped():
            parent.velocity.y = -movement_parameters().jump_speed
            parent.jump()


    func update_velocity():
        var walk_input = parent.walk_input()
        if walk_input != 0:
            walk()
        else:
            skid()
        parent.velocity.y += movement_parameters().gravity


export(String, 'stand', 'idle', 'walk', 'crouch', 'fall') var animation = 'idle'

var velocity := Vector2.ZERO
var last_velocity := Vector2.ZERO

var MOVEMENT_PARAMETERS = {
    'ground': MovementParameters.new(5, 5, 3, 0.15, 0.3, 0.5),
    'air': MovementParameters.new(5, 2, 3, 0.1, 0.005, 0.25)
}

var _current_movement_parameters = MOVEMENT_PARAMETERS['ground']

var ground_controller = GroundController.new(self)
var air_controller = AirController.new(self)
var state_controller = ground_controller
onready var input_controller = $DuckController

func move_on_ground():
    update_velocity_on_ground()
    velocity = move_and_slide_with_snap(velocity*60, Vector2(0, 2), Vector2(0, -1))*(1.0/60.0)

func move_in_air():
    velocity = move_and_slide(velocity*60, Vector2(0, -1))*(1.0/60.0)

func update_velocity_on_ground():
    pass

func _ready():
    stand()
    #set_animation(animation)

func _physics_process(delta):
    last_velocity = velocity
    state_controller.process(delta)
    if walk_input() != 0:
        $Sprite.flip_h = walk_input() < 0

func walk_input():
    return input_controller.walk


func jump_input():
    return input_controller.jump && !input_controller.last_jump


func set_animation(anim_name):
    $AnimationPlayer.play(anim_name)


func set_controller(controller : StateController):
    if state_controller != controller:
        state_controller.exit()
        controller.enter()
        state_controller = controller

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
    #set_controller(air_controller)

func jump():
    _current_movement_parameters = MOVEMENT_PARAMETERS['air']
    set_animation('fall')
    set_controller(air_controller)

func land():
    _current_movement_parameters = MOVEMENT_PARAMETERS['ground']
    set_animation('stand')
    set_controller(ground_controller)
