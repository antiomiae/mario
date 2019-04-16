extends KinematicBody2D

var _riders = []
var p0 : Vector2 = Vector2(0, 0)
export var p1 : Vector2 = Vector2(0, 0)
export var travel_time : float = 4
export var trigger_delay = 1

enum STATE { UP, DOWN, MOVING_UP, MOVING_DOWN }

var state = null

onready var timer = $Timer

var _target_point = p0

func _ready():
    p0 = position


func go_to(stop, delay=0):
#    var total_distance = (p0 - p1).abs().length()
#    var current_distance = (position - stop).abs().length()
#    tween.remove_all()
#    tween.interpolate_property(self, "position", position, stop, travel_time*(current_distance/total_distance), Tween.TRANS_LINEAR, Tween.EASE_IN, delay)
#    tween.start()
    if delay == 0:
        timer.stop()
    else:
        timer.start(delay)
    _target_point = stop

func _update_position(delta):
    if timer.is_stopped():
        var speed = (p0 - p1).length()/travel_time
        if (position - _target_point).length() >= speed*delta:
            position += (_target_point - position).normalized()*speed*delta
        else:
            position = _target_point

func _physics_process(delta):
    _riders.erase(null)

    # no riders
    if _riders.empty():
        if state != STATE.DOWN and state != STATE.MOVING_DOWN:
            go_to(p0, trigger_delay)
            state = STATE.MOVING_DOWN
    else:
        if state != STATE.UP and state != STATE.MOVING_UP:
            go_to(p1)
            state = STATE.MOVING_UP

    call_deferred("_update_position", delta)


func _on_trigger_area_body_entered(body: PhysicsBody2D) -> void:
    if body != self:
        _riders.push_back(body)


func _on_trigger_area_body_exited(body: PhysicsBody2D) -> void:
    _riders.erase(body)


func _on_tween_completed(object: Object, key: NodePath) -> void:
    match state:
        STATE.MOVING_DOWN:
            state = STATE.DOWN
        STATE.MOVING_UP:
            state = STATE.MOVING_UP
