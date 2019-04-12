extends Node2D

func _physics_process(delta: float) -> void:
    $Bullet.advance(delta)

    var collision = $Bullet.get_collision()
    if collision:
        print(collision)
