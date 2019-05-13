extends Node

var scene_name

func _ready():
    $VBoxContainer2/Button.grab_focus()

func _enter_tree():
    call_deferred('default_focus')

func default_focus():
    $VBoxContainer2/Button.grab_focus()

func _on_button_pressed(title) -> void:
    match title:
        'tether 1':
            scene_name = 'tether/tether_scene.tscn'
        'tether 2':
            scene_name = 'tether/mega_scene.tscn'
        'temple':
            scene_name = 'temple/temple.tscn'
    if scene_name:
        load_scene()

func load_scene():
    get_tree().change_scene(scene_name)
