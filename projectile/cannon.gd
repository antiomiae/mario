extends Node2D

export(PackedScene) var bullet_scene
export(Vector2) var emitter_position
export(float, 1, 1000) var bullet_speed
export(int) var bullet_collision_mask := 0

var _excluded_bodies = []
var _active_bullets = []

class_name Cannon


func point_by(a : Vector2):
    var t := transform.orthonormalized()
    #t = t.rotated(-t.get_rotation())
    var angle = t.get_rotation()
    var b = t.basis_xform(a)
    var new_rot = t.basis_xform(Vector2.RIGHT).angle_to(b)
    rotation = new_rot


func exclude_body(body):
    _excluded_bodies.push_back(body)


func clear_excluded_bodies():
    _excluded_bodies.clear()


func _physics_process(delta):
    for bullet in _active_bullets:
        bullet.advance(delta, _excluded_bodies)

func half_round(v : Vector2):
    return (v - Vector2(0.5, 0.5)).round() + Vector2(0.5, 0.5)

func shoot():
    var new_bullet = bullet_scene.instance()
    var e = emitter_position
    var my_pos = global_position
    var new_pos = to_global(emitter_position).round() + global_transform.basis_xform(Vector2(0, 0.25))
    #new_pos = half_round(new_pos)
    new_bullet.position = new_pos
    new_bullet.velocity = global_transform.basis_xform(Vector2.RIGHT*bullet_speed)
    new_bullet.collision_mask = bullet_collision_mask
    new_bullet.connect("collided", self, "_on_bullet_collided")
    _active_bullets.push_back(new_bullet)
    get_tree().current_scene.add_child(new_bullet)


func _on_bullet_collided(collision):
    var bullet = collision['bullet']
    bullet.queue_free()
    _active_bullets.erase(bullet)