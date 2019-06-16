extends '../lib/godot-flippable-physics/FlippablePhysics2D.gd'.FlippableKinematicBody2D

enum Posture { IDLE_DISARMED, ARMING, IDLE_ARMED, WALKING_ARMED, SWINGING, DEAD }

remote var _current_state = Posture.IDLE_DISARMED

export var player_number = 1
export var player_controlled := false

export var facing = 1 setget set_facing, get_facing

var sword_hit_list = []
var body_hit_list = []

remote var dead = false

onready var animation_player = $container/AnimationPlayer
onready var sword_area = $container/sword_area

const clang_ogg = preload('res://sounds/sword_clang_sound.ogg')
const bell_ogg = preload('res://sounds/bell_chime.ogg')

func _ready():
    self.facing = facing

    rset_config('position', MultiplayerAPI.RPC_MODE_PUPPET)
    rset_config('facing', MultiplayerAPI.RPC_MODE_PUPPET)

    _update_animation()

    $container/sword_area.connect('area_entered', self, 'sword_area_entered')
    $container/sword_area.connect('area_exited', self, 'sword_area_exited')
    $container/sword_area.connect('body_entered', self, 'sword_body_entered')
    $container/sword_area.connect('body_exited', self, 'sword_body_exited')


func _physics_process(delta):
    if get_tree().has_network_peer() and not is_network_master():
        return
    if dead:
        return

    var x_input = Input.get_action_strength(input('walk_right')) - Input.get_action_strength(input('walk_left'))

    if _current_state == Posture.IDLE_DISARMED:
        if x_input != 0:
            draw_sword()
    elif _current_state != Posture.ARMING:
        if _current_state != Posture.SWINGING:
            if x_input != 0:
                _current_state = Posture.WALKING_ARMED
                move_and_slide(Vector2(x_input*60, 0.25), Vector2(0, -1))
                facing = 1 if x_input > 0 else -1
                set_flip_h(facing != 1)
            else:
                _current_state = Posture.IDLE_ARMED

            if Input.is_action_just_pressed(input('sword_attack_1')):
                _current_state = Posture.SWINGING
                animation_player.play('downward_swing')
                var name = yield(animation_player, 'animation_finished')
                if name == 'downward_swing':
                    _current_state = Posture.IDLE_ARMED

    rset('position', position)
    rset('_current_state', _current_state)
    rset('facing', facing)
    rset('dead', dead)
    _update_animation()
    rpc('_sync_animation', $container/AnimationPlayer.assigned_animation, $container/AnimationPlayer.current_animation_position, !$container/AnimationPlayer.is_playing())

puppet func _sync_animation(name, seek, stop):
    set_facing(facing)
    if name:
        if name != $container/AnimationPlayer.assigned_animation:
            $container/AnimationPlayer.play(name)
            $container/AnimationPlayer.seek(0, true)
            $container/AnimationPlayer.seek(seek)
    if stop:
        $container/AnimationPlayer.stop()


func _update_animation():
    set_facing(facing)
    match _current_state:
        Posture.IDLE_DISARMED:
            animation_player.play('stand')
        Posture.IDLE_ARMED:
            animation_player.play('stand_sword')
        Posture.WALKING_ARMED:
            animation_player.play('walk')

func input(action):
    if player_controlled:
        return PlayerInput.get_player_action(action, player_number)
    else:
        return ''

func set_facing(_facing):
    if _facing == 1 or _facing == -1:
        facing = _facing
        $container.set_scale(Vector2(facing, 1))

func get_facing():
    return facing

func draw_sword():
    _current_state = Posture.ARMING
    animation_player.play('draw_sword')
    var name = yield(animation_player, 'animation_finished')
    if name == 'draw_sword':
        _current_state = Posture.IDLE_ARMED
        animation_player.play('stand_sword')

func sword_area_entered(area):
    sword_hit_list.append(area)

func sword_area_exited(area):
    sword_hit_list.erase(area)

func sword_body_entered(body):
    if body != self:
        sword_hit_list.append(body)
        body.register_hit(sword_area)

func sword_body_exited(body):
    sword_hit_list.erase(body)
    body.register_hit_stop(sword_area)

func register_hit(ob):
    if not ob in body_hit_list:
        body_hit_list.append(ob)

func register_hit_stop(ob):
    body_hit_list.erase(ob)

func process_hits():
    var successful_hits = []
    var blocked_hits = []
    # oh no, we've been hit
    if body_hit_list.size() > 0:

        for melee_object in body_hit_list:
            # did our sword hit the thing that hit us as well?
            var also_hit_sword = melee_object in sword_hit_list

            if also_hit_sword:
                blocked_hits.append(melee_object)
                var p = melee_object.get_parent().get_parent()
                p.registered_blocked_hit(melee_object)
            else:
                successful_hits.append(melee_object)

    if blocked_hits.size() > 0:
        if _current_state == Posture.SWINGING:
            _current_state = Posture.IDLE_ARMED
        $clang_sound.stream = clang_ogg
        $clang_sound.play()
        $container/sword_area/CollisionShape2D.disabled = true

    if successful_hits.size() > 0:
        $clang_sound.stream = bell_ogg
        $clang_sound.play()
        die()

    for ob in blocked_hits:
        body_hit_list.erase(ob)
        sword_hit_list.erase(ob)

func registered_blocked_hit(melee_object):
    if melee_object == sword_area && _current_state == Posture.SWINGING:
        _current_state = Posture.IDLE_ARMED

func die():
    dead = true
    _current_state = Posture.DEAD
    animation_player.play('fall_dead')







