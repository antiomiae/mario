extends Node2D

var _cooldown_timer = Timer.new()
export(float, 0, 60) var cooldown_time = 1

export var laser_color := Color(1, 0, 0)

func _ready():
    add_child(_cooldown_timer)
    _cooldown_timer.one_shot = true
    _cooldown_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
    $Cannon.bullet_collision_mask = LayerNames.physics_layer('player')

func _physics_process(delta):
    update()
    if $RayCast2D.is_colliding():
        var stopped = _cooldown_timer.is_stopped()
        if stopped:
            var collider = $RayCast2D.get_collider()
            if (collider.collision_layer & LayerNames.physics_layer('player')) > 0:
                $Cannon.shoot()
                _cooldown_timer.start(cooldown_time)

func _draw():
    var ray = $RayCast2D
    var p0 = ray.position
    var p1 = to_local(ray.get_collision_point()) if ray.is_colliding() else to_local(ray.to_global(ray.cast_to))
    draw_line(p0.floor(), p1.floor(), laser_color, 1)
