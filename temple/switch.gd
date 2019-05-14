extends Node2D

signal triggered(state)

export var inverted := false

var trigger_count := 0

var triggered := false
export var stay_triggered := false

func _update():
    if trigger_count > 0:
        if !triggered:
            triggered = true
            _signal_triggered()
    else:
        if triggered && !stay_triggered:
            triggered = false
            _signal_triggered()

    _update_animation()

func _update_animation():
    var name = 'triggered' if triggered else 'not_triggered'
    $AnimationPlayer.play(name)

func _signal_triggered():
    emit_signal('triggered', !triggered if inverted else triggered)

func _on_trigger_area_body_entered(body) -> void:
    if body:
        trigger_count += 1
        call_deferred('_update')

func _on_trigger_area_body_exited(body: PhysicsBody2D) -> void:
    if body:
        trigger_count -= 1
        call_deferred('_update')
