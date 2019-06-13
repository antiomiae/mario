extends Node

signal player_connected(id, info)
signal player_disconnected(id)


const SERVER_PORT = 60000
var server_ip = '127.0.0.1'

# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = {}

func _ready():
    get_tree().connect('network_peer_connected', self, '_player_connected')
    get_tree().connect('network_peer_disconnected', self, '_player_disconnected')
    get_tree().connect('connected_to_server', self, '_connected_ok')
    get_tree().connect('connection_failed', self, '_connected_fail')
    get_tree().connect('server_disconnected', self, '_server_disconnected')
    get_tree().connect('connection_succeeded', self, '_connection_succeeded')

func connect_as_server(info):
    my_info = info
    var peer = NetworkedMultiplayerENet.new()
    var error = peer.create_server(SERVER_PORT, 1)
    if error == OK:
        print('connected as server')
        get_tree().set_network_peer(peer)
        player_info[1] = my_info
        emit_signal('player_connected', 1, info)
    return error

func connect_as_client(info):
    my_info = info
    var peer = NetworkedMultiplayerENet.new()
    var error = peer.create_client(server_ip, SERVER_PORT)
    if error == OK:
        print('connected as client')
        get_tree().set_network_peer(peer)
    return error

func _player_connected(id):
    print(id)

func _player_disconnected(id):
    player_info.erase(id) # Erase player from info.
    emit_signal('player_disconnected', id)

func _connection_succeeded():
    print('connection succeeded')

func _connected_ok():
    # Only called on clients, not server. Send my ID and info to all the other peers.
    rpc('register_player', get_tree().get_network_unique_id(), my_info)

func _server_disconnected():
    pass # Server kicked us; show error and abort.

func _connected_fail():
    pass # Could not even connect to server; abort.

remote func register_player(id, info):
    # Store the info
    player_info[id] = info
    # If I'm the server, let the new -g-u-y- person know about existing players.
    if get_tree().is_network_server():
        # Send my info to new player
        rpc_id(id, 'register_player', 1, my_info)
        # Send the info of existing players
        for peer_id in player_info:
            rpc_id(id, 'register_player', peer_id, player_info[peer_id])

    emit_signal('player_connected', id, info)


func _exit_tree():
    get_tree().network_peer.close_connection()