extends KinematicBody2D

enum TrackingMode { DUMB, SMART }
enum ControlMode { INERT, LAUNCHING, FLYING }

var velocity := Vector2()
export var cruising_speed := 2.0
export var launch_speed := 0.25
export var angular_velocity = PI/2
export var power := 200.0

export var mass := 1.0
export var inertia := 1.0

export(TrackingMode) var tracking_mode := TrackingMode.DUMB
export(ControlMode) var control_mode := ControlMode.FLYING
export(NodePath) var target
export(float) var control_delay = 1.0

var control_delay_timer_ = Timer.new()

const Explosion = preload("res://projectile/effects/rocket_explosion.tscn")

func _ready():
    add_child(control_delay_timer_)
    control_delay_timer_.one_shot = true
    control_delay_timer_.process_mode = Timer.TIMER_PROCESS_PHYSICS

func _physics_process(delta):
    match(control_mode):
        ControlMode.FLYING:
            _flying_movement(delta)
        ControlMode.LAUNCHING:
            _launching_movement(delta)

func _flying_movement(delta):
    _update_velocity(delta)
    var collision = move_and_collide(velocity, false, true, true)
    var travel = velocity
    if collision:
        travel = collision.travel
        var body = collision.collider
        if body.has_method('on_bullet_hit'):
            var pc = ProjectileCollision.new()
            pc.projectile = self
            pc.position = collision.position
            pc.velocity = velocity.normalized()*power
            pc.normal = collision.normal
            body.on_bullet_hit(pc)

        var explosion = Explosion.instance()
        get_node('..').add_child(explosion)
        explosion.position = position
        explosion.rotation = stepify(rotation, PI/2.0)
        explosion.play()
        velocity = Vector2.ZERO
        self.queue_free()

    position += travel

func normalize_radians(r):
    while r < -PI:
        r += 2*PI
    while r > PI:
        r -= 2*PI
    return r

func _inertial_update(delta):
    if target:
        rotation = normalize_radians(rotation)
        var _target = get_node(target)
        var angle = (_target.position - position).angle()
        var error_angle = angle - rotation

        var max_correction = (2*PI)/inertia
        var correction = clamp(normalize_radians(error_angle), -max_correction, max_correction)
        rotation += correction

    var force = Vector2.RIGHT.rotated(rotation)*cruising_speed/mass
    velocity += force
    velocity = min(velocity.length(), cruising_speed)*velocity.normalized()
    #velocity = cruising_speed*Vector2.RIGHT.rotated(angle)
    #rotation = angle

func _update_velocity(delta):
    if tracking_mode == TrackingMode.SMART and inertia != 0:
        _inertial_update(delta)
    else:
        velocity = cruising_speed*Vector2.RIGHT.rotated(rotation)


func _launching_movement(delta):
    # start flying
    if control_delay_timer_.is_stopped():
        control_mode = ControlMode.FLYING
        velocity = Vector2.ZERO

    position += velocity
    rotation += angular_velocity*delta

func launch():
    if control_delay_timer_.is_stopped():
        control_mode = ControlMode.LAUNCHING
        control_delay_timer_.start(control_delay)
        velocity = launch_speed*Vector2.RIGHT.rotated(rotation)

