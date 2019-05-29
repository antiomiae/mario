extends "res://forklift/forklift_vehicle.gd"

func control_fork():
#    var fork_height = y_input() + $fork.position.y
#    var fork_height =
#    $fork.position.y = clamp(fork_height, _fork_lowered_y - fork_raise_height, _fork_lowered_y)
    for spring in $fork_springs.get_children():
        spring.rest_length += y_input()*0.25
        spring.rest_length = clamp(spring.rest_length, spring.length - fork_raise_height, spring.length)