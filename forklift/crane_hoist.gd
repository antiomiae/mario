extends RigidBody2D

func slide(dir):
     position.x += dir

func turn_winch(dir):
    $winch.delta_rotation += 2 * dir * PI / 180

func _process(delta):
    var spin = delta*linear_velocity.x / 2.5
    $crane_hoist_wheel.rotation += spin
    $crane_hoist_wheel2.rotation += spin
