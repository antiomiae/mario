extends Node

var _physics_layer_names = {}

func _ready():
    for i in range(1, 20):
        var val = ProjectSettings.get_setting("layer_names/2d_physics/layer_%d" % i)
        _physics_layer_names[val] = 1 << (i-1)

func physics_layer(name):
    if _physics_layer_names.has(name):
        return _physics_layer_names[name]

    assert("Invalid physics layer name: %s" % name)
