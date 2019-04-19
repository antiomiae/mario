extends "res://tether/level_scene.gd"

func _ready():
    var viewport = get_viewport()
    viewport.connect("size_changed", self, "set_screen_size")
    set_screen_size()
    #viewport.update_worlds()

func set_screen_size():
    var viewport = get_viewport()
    viewport.set_size(Vector2(480, 270))
    viewport.set_size_override_stretch(true)


