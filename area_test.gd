extends Node2D


func _physics_process(delta):
    var bodies = $Area2D.get_overlapping_bodies()

    if bodies.size() > 0:
        print(bodies)
    $Area2D.move_local_x(1)
