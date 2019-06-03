extends DampedSpringJoint2D

var _node_b_position : Vector2
export var displacement = 30
var _min_rest_length

var _shaft_start_y

func _ready():
    rest_length = length
    _min_rest_length = rest_length
    _shaft_start_y = $piston_shaft.position.y

    get_node(node_a).add_child(self)
    var b = get_node(node_b)
    _node_b_position = b.to_local(to_global(Vector2(0, rest_length)))

func extend(dir):
    rest_length = clamp(rest_length + dir*0.5, _min_rest_length, _min_rest_length + displacement)
    $piston_shaft.position.y = _shaft_start_y + (rest_length - _min_rest_length)

    var b = get_node(node_b)
    global_rotation = (b.to_global(_node_b_position) - global_position).angle() - PI / 2
