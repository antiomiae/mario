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
    body.on_detected()


func detach_from_anchor():
    if current_attachment:
        current_attachment.body.on_lost()
    current_attachment = null


func is_attached():
    return current_attachment != null


func is_tether_path_clear(body):
    # do some kind of raycast, i dunno
    pass


# system callbacks
func _process(delta):
    update()


func _draw():
    if current_attachment:
        draw_line(emitter_position, to_local(current_attachment.get_attachment_point()), Color(1, 1, 1), 1.0)


# detection area signals
func _on_detection_area_body_entered(body):
    var parent = body.get_node("..")
    var is_anchor = parent is TetherAnchorNode
    if is_anchor:
        anchor_nodes.push_back(parent)


func _on_detection_area_body_exited(body):
    var parent = body.get_node("..")
    var is_anchor = parent is TetherAnchorNode
    if is_anchor:
        anchor_nodes.erase(parent)


func tether_vector() -> Vector2:
    return to_global(emitter_position) - current_attachment.get_attachment_point()


class Attachment:
    var local_position : Vector2
    var body

    func _init(local_pos, body):
        self.local_position = local_pos
        self.body = body

    # Returns world position of attachment point on body
    func get_attachment_point() -> Vector2:
        return self.body.to_global(self.local_position)
