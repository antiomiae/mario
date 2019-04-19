extends Area2D

func _on_body_entered(body: PhysicsBody2D) -> void:
    var player = body as Player
    if player:
        var dir = transform.basis_xform(Vector2(-1, 0))
        var tangent = dir.tangent().project(player.velocity)
        var normal_speed = abs(dir.dot(player.velocity))
        player.velocity = dir*max(4, normal_speed)
