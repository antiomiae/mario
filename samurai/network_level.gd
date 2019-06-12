extends Node2D

const SERVER_PORT = 60000
var server_ip = '127.0.0.1'
var debug = true

func _ready():
    pass

func connect_as_server():
    var peer = NetworkedMultiplayerENet.new()
    peer.create_server(SERVER_PORT, 1)
    get_tree().set_network_peer(peer)

func connect_as_client():
    var peer = NetworkedMultiplayerENet.new()
    peer.create_client(server_ip, SERVER_PORT)
    get_tree().set_network_peer(peer)