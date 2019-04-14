extends StaticBody2D

var _riders = []
var p0 : Vector2 = Vector2(0, 0)
export var p1 : Vector2 = Vector2(0, 0)
export var travel_time : float = 4

enum STATE { UP, DOWN, MOVING_UP, MOVING_DOWN }

var state = null

onready var tween = $Tween

func _ready():
    p0 = position


func go_to(stop, delay=0):
    var total_distance = (p0 - p1).abs().length()
    var current_distance = (position - stop).abs().length()
    tween.remove_all()
    tween.interpolate_property(self, "position", position, stop, travel_time*(current_distance/total_distance), Tween.TRANS_LINEAR, Tween.EASE_IN, delay)
    tween.start()


func _physics_process(delta):
    _riders.erase(null)

    # no riders
    if _riders.empty():
        if state != STATE.DOWN and state != STATE.MOVING_DOWN:
            go_to(p0, 0.25)
            state = STATE.MOVING_DOWN
    else:
        if state != STATE.UP and state != STATE.MOVING_UP:
            go_to(p1)
            state = STATE.MOVING_UP


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
