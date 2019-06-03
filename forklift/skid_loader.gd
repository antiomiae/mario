extends RigidBody2D


func y_input():
    return Input.get_action_strength('up') - Input.get_action_strength('down')

func x_input():
    return Input.get_action_strength('walk_right') - Input.get_action_strength('walk_left')

func accelerate_to_value(target, current, acc):
    if current > target:
        if (current - target) > acc:
            current -= acc
        else:
            current = target

    if current <= target:
        if (target - current) > acc:
            current += acc
        else:
            current = target

    return current

func _physics_process(delta):
    $piston.extend(y_input()*0.5)

    var brake = Input.get_action_strength('brake')

    var body_torque = Input.get_action_strength('right_shoulder') - Input.get_action_strength('left_shoulder')

    applied_torque = body_torque*2000

    if x_input() != 0 || brake != 0:
        var target_speed = 0 if brake != 0 else x_input()*50
        var acc = 0.5*brake if brake != 0 else 0.15
        var average = ($front_wheel.angular_velocity + $rear_wheel.angular_velocity)/2.0
        var new_speed = accelerate_to_value(target_speed, average, acc)
        $front_wheel.angular_velocity = accelerate_to_value(target_speed, $front_wheel.angular_velocity, acc)
        $rear_wheel.angular_velocity = accelerate_to_value(target_speed, $rear_wheel.angular_velocity, acc)
