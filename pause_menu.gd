extends CanvasLayer

signal pause_closed

func _enter_tree():
    call_deferred('default_focus')

func _ready():
    get_tree().paused = true

func _exit_tree():
    get_tree().paused = false

func default_focus():
    $MarginContainer/VBoxContainer/resume.grab_focus()

func _on_restart_pressed():
    queue_free()
    Director.reset()

func _on_level_select_pressed():
    queue_free()
    get_tree().change_scene('res://level_select.tscn')

func _on_quit_pressed() -> void:
    get_tree().quit()

func _on_resume_pressed() -> void:
    queue_free()
