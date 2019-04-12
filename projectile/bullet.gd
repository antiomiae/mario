extends Node2D

export var velocity : Vector2 = Vector2(60*3, 0)

var _last_position : Vector2 = position

var collision_layer = 0xFFFFFFFF

var _collision = null

export var draw_length : float = 4

func advance(delta):
    update()
    # save current position
    _last_position = position

    var next_position = position + velocity * delta

    var state = get_world_2d().direct_space_state
    _collision = state.intersect_ray(position, next_position, [], collision_layer)

    if _collision:
        next_position = _collision['position']

    position = next_position

func _draw():
    var n = velocity.normalized()
    draw_line(to_local(position), to_local(position - draw_length * n), Color(1, 1, 1))

func get_collision():
    return _collision