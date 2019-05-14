extends Node2D

export var raise_height := 40
export var raised := false
export var speed := 0.5

var _start_position := Vector2()
var _stop_position := Vector2()

func _ready():
    _start_position = position
    _stop_position = _start_position + Vector2(0, -raise_height)
    if raised:
        position = _stop_position

func _physics_process(delta):
    if raised:
        seek_stop()
    else:
        seek_start()

func seek_stop():
    var height = position.y
    var start_height = _start_position.y
    var stop_height = _stop_position.y

    if height != _stop_position.y:
        height += speed*sign(stop_height - height)

    height = clamp(height, min(start_height, stop_height), max(start_height, stop_height))
    position.y = height

func seek_start():
    var height = position.y
    var start_height = _start_position.y
    var stop_height = _stop_position.y

    if height != start_height:
        height += speed*sign(start_height - stop_height)

    height = clamp(height, min(start_height, stop_height), max(start_height, stop_height))
    position.y = height

func set_raised(raised):
    self.raised = raised
