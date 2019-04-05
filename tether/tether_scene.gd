extends Node2D

const CONTINUE = preload("res://continue.tscn")

onready var camera = $player/Camera2D

func _ready():
    #get_tree().paused = true
    pass

func _process(delta):
    if Input.is_action_just_pressed("pause"):
        get_tree().paused = !get_tree().paused

    if $player.global_position.y > camera.limit_bottom:
        call_deferred("do_continue")

func do_continue():
    var dialog = CONTINUE.instance()
    dialog.connect("choose_continue", self, "continue_chosen")
    Director.push_scene(dialog)

func continue_chosen():
    Director.pop_scene()
    get_tree().reload_current_scene()
