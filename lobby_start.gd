extends Node2D

export(PackedScene) var launch_scene

var ip_address_text

enum { SERVER, CLIENT }
var connection_type = null

var _changing_scene = false

var controls = []
var selected_control = 'connection_type' setget set_selected_control, get_selected_control

func _ready():
    controls = get_tree().get_nodes_in_group('controls')
    set_selected_control(selected_control)

    NetworkLobby.connect('client_connection_failed', self, '_client_connection_failed')
    NetworkLobby.connect('network_ready', self, '_network_ready')

func _network_ready():
    get_tree().change_scene_to(launch_scene)

func _client_connection_failed():
    reset()

func _on_ip_address_text_entered(new_text) -> void:
    ip_address_text = new_text
    connection_type = CLIENT
    setup_lobby()

func _on_connection_type_server_pressed() -> void:
    self.selected_control = 'server_dialog'
    connection_type = SERVER
    setup_lobby()

func _on_connection_type_client_pressed_pressed() -> void:
    self.selected_control = 'server_address'

func setup_lobby():
    if connection_type == SERVER:
        NetworkLobby.server_ip = '127.0.0.1'
        var error = NetworkLobby.connect_as_server({'player_name': 'player1'})
        if error != OK:
            print('error connecting as server')
        else:
            self.selected_control = 'server_waiting'
            var addresses = IP.get_local_addresses()
            var ipv4s = PoolStringArray()
            for a in addresses:
                if a != '127.0.0.1' and a.find(':') == -1:
                    ipv4s.append(a)
            $CanvasLayer/MarginContainer/server_waiting.text = ipv4s.join(', ')
    elif connection_type == CLIENT:
        if ip_address_text:
            NetworkLobby.server_ip = ip_address_text
            var error = NetworkLobby.connect_as_client({'player_name': 'player2'})
            if error != OK:
                print('error connecting as client')
            else:
                self.selected_control = 'connecting'

    if !get_tree().has_network_peer():
        reset()


func reset():
    ip_address_text = null
    connection_type = null
    self.selected_control = 'connection_type'

func set_selected_control(_c):
    selected_control = _c
    for control in controls:
        control.visible = control.name == selected_control
        if control.name == selected_control:
            (control as Control).propagate_call('grab_focus')

func get_selected_control():
    return selected_control