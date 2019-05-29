extends RigidBody2D

var max_spring_length = 34
var min_spring_length = 1

func close_claw(dir = 1, amount = 1):
    $pincer_spring.rest_length = clamp($pincer_spring.rest_length + dir*amount, min_spring_length, max_spring_length)


func _physics_process(delta: float) -> void:
    var x_input = Input.get_action_strength('ui_right') - Input.get_action_strength('ui_left')
    close_claw(sign(x_input), abs(x_input))