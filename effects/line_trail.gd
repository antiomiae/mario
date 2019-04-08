extends Node2D

class_name LineTrail

export var line_width : float = 1.0
export var line_color : Color = Color(0, 0, 0)
export var smoothed : bool = false
export var max_lines : int = 10
# seconds for line to fade from opaque to completely clear
export var fade_rate : float = 1

var _lines = []

func _process(delta):
    _fade_lines(delta)
    update()

func _draw():
    for line in _lines:
        draw_line(to_local(line.p0), to_local(line.p1), line.color, line_width, smoothed)


func _fade_lines(delta):
    var lines_to_remove = []
    for line in _lines:
        line.color.a -= delta / fade_rate
        if line.color.a <= 0:
            lines_to_remove.push_back(line)

    for line in lines_to_remove:
        _lines.erase(line)

func add_line(start, end):
    _lines.push_back(Line.new(start, end, line_color))

    if (max_lines > 0) and (_lines.size() > max_lines):
        _lines.pop_front()

    update()

func clear():
    _lines.clear()
    update()

class Line:
    var p0 : Vector2
    var p1 : Vector2
    var color : Color

    func _init(start : Vector2, end : Vector2, _color = Color(1, 1, 1)):
        p0 = start
        p1 = end
        color = _color