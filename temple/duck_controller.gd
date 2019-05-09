extends Node

class_name DuckController

onready var duck = get_node('..')

export(int, 1, 4) var player_number = 1

var walk := 0.0
var last_walk := 0.0
var jump := false
var last_jump := false

func _physics_process(delta):
    last_walk = walk
    walk = get_walk_input()
    last_jump = jump
    jump = get_jump_input()

func input(action):
    return PlayerInput.get_player_action(action, player_number)

func get_walk_input():
    return Input.get_action_strength(input("walk_right")) - Input.get_action_strength(input("walk_left"))

func get_jump_input():
    return Input.is_action_pressed(input('jump'))


