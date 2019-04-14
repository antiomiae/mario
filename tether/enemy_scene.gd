extends Node2D

func _physics_process(delta):
    handle_reset()

func handle_reset():
    if Input.is_action_pressed("pause"):
        get_tree().reload_current_scene()
