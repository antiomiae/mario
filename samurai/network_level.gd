extends Node2D

var debug = true

onready var players_list = $gui_layer/container/vbox/players_list

var _items = {}

func _ready():
    NetworkLobby.connect('player_connected', self, '_player_connected')
    NetworkLobby.connect('player_disconnected', self, '_player_disconnected')

    var error = NetworkLobby.connect_as_server({})
    if error != OK:
        error = NetworkLobby.connect_as_client({})
        if error != OK:
            get_tree().quit()


func _player_connected(id, info):
    _build_player_tree()

func _player_disconnected(id):
    _build_player_tree()

func _build_player_tree():
    var s = ''
    for player_id in NetworkLobby.player_info:
        s += "player %d\n" % player_id

    players_list.text = s