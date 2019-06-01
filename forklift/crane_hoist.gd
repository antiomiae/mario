extends KinematicBody2D

func _physics_process(delta):
    if !Input.is_key_pressed(KEY_SHIFT):
        var x_input = Input.get_action_strength('ui_right') - Input.get_action_strength('ui_left')

        if x_input != 0:
            position.x += x_input

    if Input.is_action_pressed('ui_up'):
        $winch.rotation -= 0.25 * PI / 180
    if Input.is_action_pressed('ui_down'):
        $winch.rotation += 1 * PI / 180

    get_parent().get_node('Label').text = "%f" % $winch.rotation
#
#    if abs($winch.rotation_degrees) > 45:
#        $winch.rotation *= -1

func _process(delta):
#    var spin = delta*velocity.x / 2.5
#    $crane_hoist_wheel.rotation += spin
#    $crane_hoist_wheel2.rotation += spin
    pass
