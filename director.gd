extends Node2D

const CONTINUE = preload("res://continue.tscn")
const PAUSE = preload('res://pause_menu.tscn')

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

func reset():
    get_tree().reload_current_scene()

var _pause_menu = null

func handle_pause():
    if Input.is_action_just_pressed('pause'):
        if get_tree().paused:
            if _pause_menu:
                _pause_menu.queue_free()
                _pause_menu = null
            else:
                get_tree().paused = false
        else:
            if !_pause_menu:
                _pause_menu = PAUSE.instance()
                root().add_child(_pause_menu)
                yield(_pause_menu, "tree_exited")
                _pause_menu = null

func _on_pause_menu_closed():
    _pause_menu = null

func handle_reset():
    if Input.is_action_just_pressed("reset"):
        reset()


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
