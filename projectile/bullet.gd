extends Node2D

export var velocity : Vector2 = Vector2(30*1.717, -30*1.717)
export var draw_length : float = 4
var collision_mask = 0xFFFFFFFF

var _collision = null
var spawn_point = Vector2(0, 0)

var Explosion = preload("res://projectile/effects/explosion.tscn")

signal collided(collision)

func _ready():
    spawn_point = position

func respawn():
    position = spawn_point

#func _physics_process(delta):
#    #advance(delta)

func half_round(v : Vector2):
    return (v - Vector2(0.5, 0.5)).round() + Vector2(0.5, 0.5)


func advance(delta, exceptions := []):
    update()

    var next_position = position + velocity * delta

    var state = get_world_2d().direct_space_state
    _collision = state.intersect_ray(position, next_position, exceptions, collision_mask)

    if _collision:
        _collision['bullet'] = self
        next_position = _collision['position']
        handle_collision()

    position = next_position

func handle_collision():
    var collider = _collision['collider']
    if collider.has_method("on_bullet_hit"):
        var pc = ProjectileCollision.new()
        pc.projectile = self
        pc.position = _collision['position']
        pc.normal = _collision['normal']
        pc.velocity = velocity
        pc.collider = collider
        pc.shape = _collision['shape']
        collider.on_bullet_hit(pc)

    var explosion = Explosion.instance()
    collider.add_child(explosion)
    explosion.position = collider.to_local(_collision['position'])
    explosion.rotation = _collision['normal'].angle() - collider.rotation
    explosion.play()

    emit_signal("collided", _collision)

func _draw():
    var n = velocity.normalized()
    var start = to_local(position)
    var stop = to_local(position - draw_length * n)
    draw_line(start, stop, Color(1, 1, 1), 0.5, false)


func get_collision():
    return _collision