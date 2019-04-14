extends Node2D

export var velocity : Vector2 = Vector2(30*1.717, -30*1.717)
export var draw_length : float = 4
var collision_layer = 0xFFFFFFFF

var _collision = null
var spawn_point = Vector2(0, 0)

var Explosion = preload("res://projectile/effects/explosion.tscn")

signal collided(collision)

func _ready():
    spawn_point = position

func respawn():
    position = spawn_point

func _physics_process(delta):
    advance(delta)

func advance(delta):
    update()

    var next_position = position + velocity * delta

    var state = get_world_2d().direct_space_state
    _collision = state.intersect_ray(position, next_position, [], collision_layer)

    if _collision:
        _collision['bullet'] = self
        next_position = _collision['position']
        handle_collision()

    position = next_position

func handle_collision():
    var collider = _collision['collider']
    if collider.has_method("on_bullet_hit"):
        collider.call("on_bullet_hit", _collision)

    var explosion = Explosion.instance()
    explosion.position = _collision['position']
    explosion.rotation = _collision['normal'].angle()
    get_tree().current_scene.add_child(explosion)

    emit_signal("collided", _collision)

func _draw():
    var n = velocity.normalized()
    draw_line(to_local(position)-Vector2(0, 1), to_local(position - draw_length * n)-Vector2(0, 1), Color(1, 1, 1), 1, false)


func get_collision():
    return _collision