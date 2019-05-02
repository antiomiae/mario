extends KinematicBody2D

var dead := false
export var facing := -1
export(float, 0, 2) var walk_speed = 0.02

var velocity = Vector2.ZERO

onready var head_hitbox = $head_hitbox
onready var body_hitbox = $body_hitbox

export var knock_back_distance := 2.0
export var freeze_time := 1.0
var _knock_back_timer = Timer.new()

func _ready():
    add_child(_knock_back_timer)
    _knock_back_timer.one_shot = true
    _knock_back_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
    $AnimationPlayer.play('standing')
    $head.add_collision_exception_with(self)
    update_sprite()
    enable_head_body(false)

func _physics_process(delta):
    if dead:
       return

    if _knock_back_timer.is_stopped():
        velocity.x = walk_speed*facing*60
    _move()
    if get_slide_count() > 0:
        _handle_collisions()

    if is_on_wall() and is_on_floor():
        facing = -facing

    update_sprite()

func update_sprite():
    if facing != 0:
        $sprite.flip_h = (facing == 1)
        $head_hitbox.position.x = facing*abs($head_hitbox.position.x)
        $head.position.x = facing*abs($head.position.x)
        $head/sprite.flip_h = (facing == 1)

func enable_head_body(enable = true):
    $head.mode = RigidBody2D.MODE_RIGID if enable else RigidBody2D.MODE_KINEMATIC
    $head/CollisionShape2D.disabled = !enable

func _move():
    velocity.y += 1

    var new_v = move_and_slide_with_snap(
        velocity,
        Vector2(0, 2),
        Vector2(0, -1))
    velocity = new_v

func _died():
    $AnimationPlayer.play('dead')
    $body_hitbox.disabled = true
    $head_hitbox.disabled = true
    dead = true

func _knock_back(dir):
    if _knock_back_timer.is_stopped():
        _knock_back_timer.start(freeze_time)
    velocity.x = dir*2*60
    _move()
    velocity.x = 0

func _handle_collisions():
    for i in range(get_slide_count()):
        var collision = get_slide_collision(i)
        var collider = collision.collider
        if (collider.collision_layer | LayerNames.physics_layer('player')) && collider.has_method('on_enemy_hit'):
            collider.on_enemy_hit(self)

func on_bullet_hit(pc : ProjectileCollision):
    var owner = shape_owner_get_owner(shape_find_owner(pc.shape))
    match owner:
        head_hitbox:
            _died()
            enable_head_body()
            $head.inertia = 25
            var impact_dir = pc.projectile.velocity.normalized()
            $head.apply_impulse($head.to_local(pc.position), impact_dir*50)
        body_hitbox:
            _knock_back(sign(-pc.normal.x))
