extends RigidBody2D

var delta_rotation = 0
var _position := Vector2()
var _rotation = 0

func _ready():
    _position = position

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
    #state.position = position
    #position = _position
    _rotation += delta_rotation
    delta_rotation = 0

#    if _rotation > PI:
#        _rotation -= 2*PI
#    elif _rotation < -PI:
#        _rotation += 2*PI
#
    applied_force = Vector2()
    applied_torque = 0

    var error_angle = _rotation - rotation

    while error_angle > PI:
        error_angle -= 2*PI

    while error_angle < -PI:
        error_angle += 2*PI

    angular_velocity = (error_angle)*60

    state.linear_velocity = Vector2()




#func _physics_process(delta):
#    #call_deferred('set_rotation', rotation + delta_rotation)
#    rotation += delta_rotation
#    delta_rotation = 0