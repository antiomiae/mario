extends Node2D

signal choose_continue()

func _ready():
    var viewport = get_viewport_rect()
    $CanvasLayer/ColorRect.rect_position = Vector2(0, 0)
    $CanvasLayer/ColorRect.rect_size = viewport.size

func _input(event):
    if event.is_pressed():
        call_deferred("signal_continue")

func signal_continue():
    emit_signal("choose_continue")
