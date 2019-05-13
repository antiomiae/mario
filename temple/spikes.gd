tool
extends Area2D

func _ready():
    var rect : Rect2 = $TileMap.get_used_rect()
    var upper_left = $TileMap.map_to_world(rect.position)
    var lower_right = $TileMap.map_to_world(rect.end)
    $CollisionShape2D.position.x = (lower_right.x - upper_left.x)/2.0 + upper_left.x
    $CollisionShape2D.shape.extents.x = (lower_right.x - upper_left.x)/2.0

func _physics_process(delta):
    for body in get_overlapping_bodies():
        if body.has_method('on_spike_hit'):
            body.on_spike_hit(self)
    if get_overlapping_bodies().size() == 0:
        set_physics_process(false)

func _on_spikes_body_entered(body):
    set_physics_process(true)
