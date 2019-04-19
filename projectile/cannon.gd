extends Node2D

export(PackedScene) var bullet_scene
export(Vector2) var emitter_position
export(float, 1, 1000) var bullet_speed
export(int) var bullet_collision_mask := 0

var _excluded_bodies = []
var _active_bullets = []

class_name Cannon

func exclude_body(body):
    _excluded_bodies.push_back(body)


func clear_excluded_bodies():
    _excluded_bodies.clear()


func _physics_process(delta):
    for bullet in _active_bullets:
        bullet.advance(delta, _excluded_bodies)


func shoot():
    var new_bullet = bullet_scene.instance()
    new_bullet.position = to_global(emitter_position)
    new_bullet.velocity = global_transform.basis_xform(Vector2(1, 0))*bullet_speed
    new_bullet.collision_mask = bullet_collision_mask
    new_bullet.connect("collided", self, "_on_bullet_collided")
    _active_bullets.push_back(new_bullet)
    get_tree().current_scene.add_child(new_bullet)


func _on_bullet_collided(collision):
    var bullet = collision['bullet']
    bullet.queue_free()
    _active_bullets.erase(bullet)