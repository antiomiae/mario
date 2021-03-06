extends RigidBody2D

export var fork_raise_height = 40
var _fork_lowered_y = 8
export var player_controllable = true

func x_input():
    return Input.get_action_strength('walk_right') - Input.get_action_strength('walk_left')

func y_input():
    return Input.get_action_strength("down") - Input.get_action_strength('up')

func engine_torque(rotation_speed):
    rotation_speed = abs(rotation_speed)
    var torque = 500*(1 - pow((rotation_speed/12), 3))
    return max(torque, 0)

func brake(wheel):
    var wheel_speed = wheel.angular_velocity
    if wheel_speed != 0:
        wheel.applied_torque = 500 * -sign(wheel_speed) * pow(clamp(abs(wheel_speed)/0.1, 0, 1), 2)

func _physics_process(delta):
    if player_controllable:
        var input = x_input()
        #if input != 0:
        if input == 0:
            if Input.is_action_pressed('brake'):
                brake($front_wheel)
                brake($rear_wheel)
            else:
                $front_wheel.applied_torque = 0
                $rear_wheel.applied_torque = 0
        else:
            var wheel_speed = $front_wheel.angular_velocity
            if abs(wheel_speed) > 0.5 and sign(wheel_speed) != sign(input):
                brake($front_wheel)
                brake($rear_wheel)
            else:
                $front_wheel.set_applied_torque(input*engine_torque(wheel_speed))
                $rear_wheel.set_applied_torque(input*engine_torque($rear_wheel.angular_velocity))

        control_fork()

func control_fork():
    var fork_height = y_input() + $fork.position.y
    $fork.position.y = clamp(fork_height, _fork_lowered_y - fork_raise_height, _fork_lowered_y)
