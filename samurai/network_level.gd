extends Node2D

var debug = true

onready var players_list = $gui_layer/container/vbox/players_list

var _items = {}

enum { WAITING, FIGHTING, AFTER_MATCH }

var state = WAITING

var my_player

var player_name = 'player1'

const END_SOUND = preload('res://sounds/asian_riff.wav')

func _physics_process(delta):
    if state == FIGHTING:
        var fighters = get_tree().get_nodes_in_group('fighters')

        var alive_count = 0

        for fighter in fighters:
            if !fighter.dead:
                alive_count += 1

        get_node(player_name).process_hits()

        if alive_count < 2 and get_tree().is_network_server():
            #NetworkLobby.rpc('network_reset')
            rpc('end_match')



func _ready():
    $player1.player_number = 1
    $player2.player_number = 1

    player_name = NetworkLobby.my_info['player_name']
    assert(player_name != null)
    my_player = get_node(player_name)

    update_player_info()

    NetworkLobby.connect('player_connected', self, '_player_connected')
    NetworkLobby.connect('player_disconnected', self, '_player_disconnected')
    NetworkLobby.connect('network_ready', self, '_network_ready')
    NetworkLobby.connect('player_start', self, '_start_match')
    NetworkLobby.connect('player_reset', self, '_restart_match')

    NetworkLobby.required_players = 2

    get_tree().paused = true

    _network_ready()

func setup_players():
    for id in NetworkLobby.player_info:
        var info = NetworkLobby.player_info[id]
        var player_character = get_node(info['player_name'])
        assert(player_character != null)
        player_character.set_network_master(NetworkLobby.player_info[name])


func _process(delta):
    update_death_counters()
    _build_player_tree()

func _network_ready():
    NetworkLobby.signal_player_ready()

func _start_match():
    get_tree().paused = false
    setup_players()
    state = FIGHTING
    print('start')

func _restart_match():
    get_tree().reload_current_scene()

func _player_connected(id, info):
    _build_player_tree()

func _player_disconnected(id):
    _build_player_tree()

func _build_player_tree():
    var s = ''
    for player_id in NetworkLobby.player_info:
        s += "player %d\n" % player_id

    players_list.text = s

remote func sync_player_info(info, player_name):
    print('sync_player_info')
    PlayerInfo.player_stats[player_name] = info

remotesync func end_match():
    print('end_match')
    if state != AFTER_MATCH:
        state = AFTER_MATCH
        play_end_sound(1.5)
        if get_tree().is_network_server():
            rpc('update_player_info')
            yield(get_tree().create_timer(5), 'timeout')
            NetworkLobby.rpc('network_reset')

func play_end_sound(delay = 0.0):
    if delay > 0:
        yield(get_tree().create_timer(delay), 'timeout')
    $AudioStreamPlayer.stream = END_SOUND
    #$AudioStreamPlayer.play()

remotesync func update_player_info():
    print('update_player_info')
    var stats = PlayerInfo.player_stats

    if not stats.has(player_name):
        stats[player_name] = {}
        stats[player_name]['deaths'] = 0

    if get_node(player_name):
        stats[player_name]['deaths'] += 1

    rpc('sync_player_info', stats[player_name], player_name)


func update_death_counters():
    var labels = {}
    for label in get_tree().get_nodes_in_group('death_counters'):
        labels[label.name] = label

    for player in PlayerInfo.player_stats:
        var n = '{0}_deaths'.format([player])
        var label = labels.get(n)
        if label:
            label.text = String(PlayerInfo.player_stats[player]['deaths'])
