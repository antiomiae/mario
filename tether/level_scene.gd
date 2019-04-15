extends Node2D

onready var camera = $player/Camera2D

func _physics_process(delta):
    if $player.global_position.y > camera.limit_bottom:
        Director.call_deferred("do_continue")

func _on_player_died(body):
    yield(get_tree().create_timer(3.0), "timeout")
    Director.do_continue()
