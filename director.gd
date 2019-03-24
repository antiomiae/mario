extends Node

var scene_stack = []

func _ready():
    pass


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