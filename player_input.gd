extends Node

func get_player_action(action, player=1):
    var player_specific_action = _action_name_for_player(action, player)
    if InputMap.has_action(player_specific_action):
        return player_specific_action
    return action

func _action_name_for_player(action, player):
    return "%s_player_%d" % [action, player]
