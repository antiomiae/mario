extends Node2D

func x_input():
    return Input.get_action_strength('ui_right') - Input.get_action_strength('ui_left')

func _physics_process(delta: float) -> void:
    $piston1.extend(x_input()*0.5)