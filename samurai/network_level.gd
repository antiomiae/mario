extends Node2D

var debug = true

onready var players_list = $gui_layer/container/vbox/players_list

var _items = {}

func _physics_process(delta):
    var fighters = get_tree().get_nodes_in_group('fighters')

    var alive_count = 0

    for fighter in fighters:
        if !fighter.dead:
            alive_count += 1
            fighter.process_hits()

    if alive_count < 2 and get_tree().is_network_server():
        NetworkLobby.rpc('network_reset')

func _ready():
    NetworkLobby.connect('player_connected', self, '_player_connected')
    NetworkLobby.connect('player_disconnected', self, '_player_disconnected')
    NetworkLobby.connect('network_ready', self, '_network_ready')
    NetworkLobby.connect('player_start', self, '_start_match')
    NetworkLobby.connect('player_reset', self, '_restart_match')

    NetworkLobby.required_players = 2

    get_tree().paused = true

    _network_ready()

func _start_match():
    get_tree().paused = false
    print('start')

func _restart_match():
    get_tree().reload_current_scene()

func _network_ready():
    # set up network owners of players
    $player1.set_network_master(1)
    $player1.player_number = 1
    $player2.player_number = 1

    if get_tree().is_network_server():
        var peer_id = get_tree().get_network_connected_peers()[0]
        assert(peer_id > 1)
        $player2.set_network_master(peer_id)
    else:
        $player2.set_network_master(get_tree().get_network_unique_id())

    NetworkLobby.signal_player_ready()


func _player_connected(id, info):
    _build_player_tree()

func _player_disconnected(id):
    _build_player_tree()

func _build_player_tree():
    var s = ''
    for player_id in NetworkLobby.player_info:
        s += "player %d\n" % player_id

    players_list.text = s