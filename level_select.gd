extends Node

var scenes = [
    'tether/tether_scene.tscn',
    'tether/mega_scene.tscn',
    'temple/temple.tscn',
    'temple/temple_2.tscn',
    'forklift/forklift_v2_test.tscn',
    'forklift/skid_loader_test.tscn',
    'samurai/samurai_level.tscn'
]

var buttons = []

func _ready():
    for button in $MarginContainer/VBoxContainer.get_children():
        buttons.push_back(button)

    for i in range(min(scenes.size(), buttons.size())):
        buttons[i].connect('pressed', self, '_on_button_pressed', [scenes[i]])

func _enter_tree():
    call_deferred('default_focus')
    Director.disable_pause()

func _exit_tree():
    Director.enable_pause()

func default_focus():
    if buttons[0]:
        buttons[0].grab_focus()

func _on_button_pressed(scene_name):
    if scene_name:
        load_scene(scene_name)

func load_scene(scene_name):
    get_tree().change_scene(scene_name)


func _on_quit_pressed():
    get_tree().quit()
