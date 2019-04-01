extends Node2D

class_name GrapplingHook
# An object that can shoot a virtual tether that attaches to
# bodies or "anchors", allowing the parent to swing around
# the attachment point.

var anchor_nodes = []

export var emitter_position : Vector2 = Vector2(0, 0)

var current_attachment : Attachment = null

func attach_to_anchor(body, local_pos = Vector2(0, 0)):
    current_attachment = Attachment.new(local_pos, body)

func detach_from_anchor():
    current_attachment = null

func is_anchor_path_clear(body):
    # do some kind of raycast, i dunno
    pass

func _on_detection_area_body_entered(body):
    var is_anchor = body.get_node("..") is TetherAnchorNode
    if is_anchor:
        anchor_nodes.push_back(body)

func _on_detection_area_body_exited(body):
    anchor_nodes.erase(body)


func _draw():
    if current_attachment:
        draw_line(emitter_position, to_local(current_attachment.get_attachment_point()), Color(1, 1, 1), 1.0)

func _process(delta):
    update()


class Attachment:
    var local_position : Vector2
    var body

    func _init(local_pos, body):
        self.local_position = local_pos
        self.body = body

    # Returns world position of attachment point on body
    func get_attachment_point() -> Vector2:
        return self.body.to_global(self.local_position)
