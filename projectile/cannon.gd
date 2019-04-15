tool
extends Node2D

var active_bullets = []

export(PackedScene) var bullet_scene

export(Vector2) var emitter_position

export(float, 1, 1000) var bullet_speed

export(int) var bullet_collision_mask := 0

class_name Cannon

func _physics_process(delta):
    for bullet in active_bullets:
        bullet.advance(delta)

func shoot():
    var new_bullet = bullet_scene.instance()
    new_bullet.position = to_global(emitter_position)
    new_bullet.velocity = transform.basis_xform(Vector2(1, 0))*bullet_speed
    new_bullet.collision_mask = bullet_collision_mask
    new_bullet.connect("collided", self, "_on_bullet_collided")
    active_bullets.push_back(new_bullet)
    get_tree().current_scene.add_child(new_bullet)

func _on_bullet_collided(collision):
    var bullet = collision['bullet']
    bullet.queue_free()
    active_bullets.erase(bullet)