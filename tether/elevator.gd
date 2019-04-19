tool
extends KinematicBody2D

var _riders = []
var p0 : Vector2 = Vector2(0, 0)
var p1 : Vector2 = Vector2(0, 0)
export var travel_time : float = 4
export var trigger_delay := 1.0

export(Vector2) var endpoint setget set_endpoint, get_endpoint

enum STATE { UP, DOWN, MOVING_UP, MOVING_DOWN }

var state = null

onready var timer = $Timer

var _target_point = p0

func set_endpoint(e):
    endpoint = e
    $Position2D.position = e

func get_endpoint():
    return endpoint

func _ready():
    p0 = position
    p1 = to_global(endpoint)

    if Engine.is_editor_hint():
        set_physics_process(false)


func go_to(stop, delay=0):
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
    if _riders.empty() and timer.is_stopped():
        if state != STATE.DOWN and state != STATE.MOVING_DOWN:
            go_to(p0, trigger_delay)
            state = STATE.MOVING_DOWN
    elif timer.is_stopped():
        if state != STATE.UP and state != STATE.MOVING_UP:
            go_to(p1, trigger_delay)
            state = STATE.MOVING_UP
    #_update_position(delta)
    call_deferred("_update_position", delta)


func _on_trigger_area_body_entered(body: PhysicsBody2D) -> void:
    if body != self:
        _riders.push_back(body)


func _on_trigger_area_body_exited(body: PhysicsBody2D) -> void:
    _riders.erase(body)
