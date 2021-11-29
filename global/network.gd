extends Node

const DEFAULT_PORT = 28700
const MAX_CLIENTS = 5

var server = null
var client = null

var ip_address = "127.0.0.1"

func _ready():
	
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("network_peer_connected", self, "_player_joined")
	get_tree().connect("connection_failed", self, "_connection_failed")

	
func create_server():
	print("Starting server")
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	get_tree().set_network_peer(server)
	
func join_server():
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, DEFAULT_PORT)
	get_tree().set_network_peer(client)
	
func _connected_to_server():
	print("connected to server!")	
	
func _server_disconnected():
	print("disconnected from server")

func _player_joined(id):
	print("player  " +str(id) + "  connected")
	
func _connection_failed():
	print("failed connection")
	
