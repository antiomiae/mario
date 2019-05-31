extends Node2D
tool

export var node_a : NodePath
export var node_b : NodePath

export var offset = 5
export var length = 10

var _links = []
var _joints = []

func _ready():
    _links.push_back($link.duplicate())
    add_child(_links[0])
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

    $link.queue_free()

    var a = get_node(node_a)
    var b = get_node(node_b)

    if a:
        var a_joint = PinJoint2D.new()
        _links[0].add_child(a_joint)
        a_joint.node_a = _links[0].get_path()
        a_joint.node_b = a.get_path()

    if b:
        var b_joint = PinJoint2D.new()
        b.add_child(b_joint)
        b_joint.node_a = _links[_links.size()-1].get_path()
        b_joint.node_b = b.get_path()
