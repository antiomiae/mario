extends Node2D

export var chain : NodePath
export var hoist : NodePath
export var grabber : NodePath

func x_input():
    return Input.get_action_strength('ui_right') - Input.get_action_strength('ui_left')

func y_input():
    return Input.get_action_strength('ui_down') - Input.get_action_strength('ui_up')

func _physics_process(delta):
    if Input.is_key_pressed(KEY_SHIFT):
        get_node(grabber).close(x_input())
    else:
        get_node(hoist).slide(x_input())

    get_node(hoist).turn_winch(y_input())


#close_claw(sign(x_input), abs(x_input))