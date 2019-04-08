extends Node2D

class_name GrapplingHook
# An object that can shoot a virtual tether that attaches to
# bodies or "anchors", allowing the parent to swing around
# the attachment point.

var anchor_nodes = []

export var emitter_position : Vector2 = Vector2(0, 0)

onready var line_trail = $LineTrail

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
func _physics_process(delta):
    update()
    if current_attachment:
        $LineTrail.add_line(to_global(emitter_position), current_attachment.get_attachment_point())


# detection area signals
func _on_detection_area_body_entered(body):
    match body:
        TetherAnchorNode:
            anchor_nodes.push_back(body)


func _on_detection_area_body_exited(body):
    anchor_nodes.erase(body)


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
