extends Node2D

class_name TetherAnchorNode

var color : Color = Color("FFFFFF")

func _process(delta):
    update()

func _draw():
    var extents = $StaticBody2D/CollisionShape2D.shape.extents
    var position = $StaticBody2D/CollisionShape2D.position
    draw_rect(Rect2(position - extents, extents*2), color)
