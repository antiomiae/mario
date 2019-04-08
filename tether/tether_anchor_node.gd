extends StaticBody2D

class_name TetherAnchorNode

var color : Color = Color("FFFFFF")

func _process(delta):
    update()

func _draw():
    var extents = $CollisionShape2D.shape.extents
    var position = $CollisionShape2D.position
    draw_rect(Rect2(position - extents, extents*2), color)

func on_detected():
    color = Color(0, 0.846161, 0.910156)

func on_lost():
    color = Color("FFFFFF")

