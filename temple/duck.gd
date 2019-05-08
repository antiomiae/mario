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

export(String, 'stand', 'idle', 'walk', 'crouch', 'fall') var animation = 'idle'

var _current_movement_parameters : MovementParameters
var velocity := Vector2.ZERO

var MOVEMENT_PARAMETERS = {
    'ground': MovementParameters.new(5, 5, 3, 0.15, 0.3, 1),
    'air': MovementParameters.new(5, 5, 3, 0.1, 0.1, 2)
}

func _ready():
    set_animation(animation)

func _physics_process(delta):
    pass
    #var new_velocity = move_and_slide()

func set_animation(anim_name):
    $AnimationPlayer.play(anim_name)

func walk(delta):
    _current_movement_parameters = MOVEMENT_PARAMETERS['ground']

func stand(delta):
    _current_movement_parameters = MOVEMENT_PARAMETERS['ground']

func fall(delta):
    _current_movement_parameters = MOVEMENT_PARAMETERS['air']

func jump(delta):
    _current_movement_parameters = MOVEMENT_PARAMETERS['air']

func land(delta):
    pass
