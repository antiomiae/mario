extends KinematicBody2D

export var velocity := Vector2()
export var power := 200.0

const Explosion = preload("res://projectile/effects/explosion.tscn")

func _physics_process(delta):
    var collision = move_and_collide(velocity, false, true, true)

    if collision:
        var body = collision.collider
        if body.has_method('on_bullet_hit'):
            var pc = ProjectileCollision.new()
            pc.projectile = self
            pc.position = collision.position
            pc.velocity = velocity.normalized()*power
            pc.normal = collision.normal
            body.on_bullet_hit(pc)

            var explosion = Explosion.instance()
            get_tree().current_scene.add_child(explosion)
            explosion.position = pc.position
            explosion.rotation = pc.normal.angle()
            explosion.play()

        self.queue_free()


    position += velocity