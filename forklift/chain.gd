extends Node2D
tool

export var node_a : NodePath
export var node_b : NodePath

export var offset = 5
export var length := 10 setget set_length, get_length

var _links = []
var _joints = []

func set_length(l):
    length = l
    update()

func get_length():
    return length

func build_with_springs():
    for i in range(1, length):
        var new_link = $link.duplicate()
        new_link.position.x = i * offset
        #new_link.position.x = offset
        _links.push_back(new_link)
        #_links[i-1].add_child(new_link)
        add_child(new_link)

        #var joint = PinJoint2D.new()
        var joint = DampedSpringJoint2D.new()
        joint.length = 2
        joint.stiffness = 20
        joint.damping = 0.2
        _joints.push_back(joint)
        _links[i - 1].add_child(joint)
        #add_child(joint)
        joint.position.x = offset - 1
        joint.rotation_degrees = -90
        joint.node_a = _links[i - 1].get_path()
        joint.node_b = new_link.get_path()
        #joint.bias = 0.01


func build_with_pins():
    for i in range(1, length):
        var new_link = $link.duplicate()
        new_link.position.x = i * offset
        #new_link.position.x = offset
        _links.push_back(new_link)
        #_links[i-1].add_child(new_link)
        add_child(new_link)

        #var joint = PinJoint2D.new()
        var joint = PinJoint2D.new()

        _joints.push_back(joint)
        _links[i - 1].add_child(joint)
        #add_child(joint)
        joint.position.x = offset
        joint.softness = 1
        #joint.rotation_degrees = -90
        joint.node_a = _links[i - 1].get_path()
        joint.node_b = new_link.get_path()
        #joint.bias = 0.01


func _ready():
    _links.push_back($link.duplicate())
    add_child(_links[0])

    build_with_pins()

    $link.queue_free()

    if !Engine.is_editor_hint():
        var a = get_node(node_a)
        var b = get_node(node_b)

        if a:
            var a_joint = PinJoint2D.new()
            a_joint.softness = 1
            #_links[0].add_child(a_joint)
            #get_parent().add_child(a_joint)
            a.add_child(a_joint)
            a_joint.global_position = _links[0].global_position
            a_joint.node_b = _links[0].get_path()
            a_joint.node_a = a.get_path()

        if b:
            var b_joint = PinJoint2D.new()
            b_joint.softness = 1
            b_joint.position.x = offset
            _links[_links.size()-1].add_child(b_joint)
            b_joint.node_a = _links[_links.size()-1].get_path()
            b_joint.node_b = b.get_path()


func _draw():
    if Engine.is_editor_hint():
        draw_line(Vector2(offset*length, -5), Vector2(offset*length, 5), Color(1, 1, 1, 1), 1.0)