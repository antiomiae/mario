extends Node2D

const CONTINUE = preload("res://continue.tscn")

onready var camera = $player/Camera2D
var _doing_continue = false

func _physics_process(delta):
    if $player.global_position.y > camera.limit_bottom:
        show_continue()

func _on_player_died(body):
    if body.player_number == 1:
        yield(get_tree().create_timer(3.0), "timeout")
        show_continue()

func show_continue():
    if not _doing_continue:
        _doing_continue = true
        var c = CONTINUE.instance()
        add_child(c)
        yield(c, "choose_continue")
        _doing_continue = false
        Director.reset()