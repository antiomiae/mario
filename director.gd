extends Node2D

const CONTINUE = preload("res://continue.tscn")

var scene_stack = []

var _doing_continue = false

func _ready():
    self.pause_mode = Node.PAUSE_MODE_PROCESS

func _process(delta):
    handle_reset()
    handle_pause()


func pop_scene():
    var current_scene = get_tree().current_scene

    if current_scene:
        root().remove_child(current_scene)
        current_scene.queue_free()

    current_scene = scene_stack.pop_back()

    if current_scene:
        root().add_child(current_scene)
        get_tree().set_current_scene(current_scene)


func root():
    return get_tree().get_root()


func push_scene(scene):
    var current_scene = get_tree().current_scene

    if current_scene != null:
        root().remove_child(current_scene)
        scene_stack.push_back(current_scene)

    root().add_child(scene)
    get_tree().set_current_scene(scene)


func handle_pause():
    if Input.is_action_just_pressed("pause"):
        get_tree().paused = !get_tree().paused


func handle_reset():
    if Input.is_action_just_pressed("reset"):
        get_tree().reload_current_scene()


func do_continue():
    if _doing_continue:
        return
    _doing_continue = true
    var dialog = CONTINUE.instance()
    dialog.connect("choose_continue", self, "_continue_chosen")
    Director.push_scene(dialog)


func _continue_chosen():
    _doing_continue = false
    Director.pop_scene()
    get_tree().reload_current_scene()
