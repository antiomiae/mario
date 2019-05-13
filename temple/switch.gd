extends Node2D

signal triggered(state)

export var inverted := false

var trigger_count := 0

var triggered := false

func _update():
    if trigger_count > 0:
        if !triggered:
            triggered = true
            _signal_triggered()
    else:
        if triggered:
            triggered = false
            _signal_triggered()

func _signal_triggered():
    emit_signal('triggered', !triggered if inverted else triggered)

func _on_trigger_area_body_entered(body: PhysicsBody2D) -> void:
    trigger_count += 1
    call_deferred('_update')

func _on_trigger_area_body_exited(body: PhysicsBody2D) -> void:
    trigger_count -= 1
    call_deferred('_update')
