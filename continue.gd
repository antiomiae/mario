extends Node2D

signal choose_continue()

func _ready():
    var viewport = get_viewport_rect()
    $ColorRect.rect_position = Vector2(0, 0)
    $ColorRect.rect_size = viewport.size

func _input(event):
    if event.is_pressed():
        set_process_input(false)
        call_deferred("signal_continue")

func signal_continue():
    emit_signal("choose_continue")
