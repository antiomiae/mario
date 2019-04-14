extends Node

func _ready():
    var gamepads = Input.get_connected_joypads()
    var count = max(1, gamepads.size())

    for i in range(count):
        var walk_left = InputMap.get_action_list("walk_left")
        var walk_right = InputMap.get_action_list("walk_right")
        print(walk_right)


