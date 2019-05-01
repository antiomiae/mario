extends KinematicBody2D

var dead := false
export var facing := -1
export(float, 0, 2) var walk_speed = 0.02

var velocity = Vector2.ZERO

func _ready():
    $AnimationPlayer.play('standing')
    $head.add_collision_exception_with(self)
    update_sprite()


func update_sprite():
    $sprite.flip_h = (facing == 1)


func _physics_process(delta):
    if dead:
       return

    velocity.x = walk_speed*facing*60
    velocity.y += 1

    var new_v = move_and_slide_with_snap(
        velocity,
        Vector2(0, 2),
        Vector2(0, -1)
    )

    velocity.y = new_v.y

    if is_on_wall() and is_on_floor():
        facing = -facing


func _died():
    $AnimationPlayer.play('dead')
    $body_hitbox.disabled = true
    $head_hitbox.disabled = true
    dead = true


func on_bullet_hit(pc : ProjectileCollision):
    var owner = shape_owner_get_owner(shape_find_owner(pc.shape))
    if owner == $head_hitbox:
        _died()
        $head.mode = RigidBody2D.MODE_RIGID
        $head.inertia = 25
        var impact_dir = pc.projectile.velocity.normalized()
        $head.apply_impulse($head.to_local(pc.position), impact_dir*50)




