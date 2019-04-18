extends "res://tether/level_scene.gd"

func _ready():
    var viewport = get_viewport()

    viewport.size = Vector2(480, 270)
    #get_tree().get_root().set_size_override(true, Vector2(480, 270))