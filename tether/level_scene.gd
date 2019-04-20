extends Node2D

const CONTINUE = preload("res://continue.tscn")

onready var camera = $player/Camera2D

func _physics_process(delta):
    if $player.global_position.y > camera.limit_bottom:
        show_continue()

func _on_player_died(body):
    if body.player_number == 1:
        yield(get_tree().create_timer(3.0), "timeout")
        show_continue()

func show_continue():
    var c = CONTINUE.instance()
    add_child(c)
    yield(c, "choose_continue")
    Director.reset()