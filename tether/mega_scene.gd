extends "res://tether/level_scene.gd"

func _ready():
    var viewport = get_viewport()
    #viewport.connect("size_changed", self, "set_screen_size")
    _update_death_counter()
    $rocket1.launch()


func _update_death_counter():
    $gui_layer/death_counter.text = "%04d" % PlayerInfo.player_deaths


func set_screen_size(viewport):
    viewport.set_size_override(true, Vector2(480, 270))
    viewport.set_size_override_stretch(true)


func _on_player_died(body):
    PlayerInfo.player_deaths += 1
    _update_death_counter()
    ._on_player_died(body)
