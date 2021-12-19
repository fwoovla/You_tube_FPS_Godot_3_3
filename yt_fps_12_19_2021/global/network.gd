extends Node

const DEFAULT_PORT = 28900
const MAX_CLIENTS = 5

var server = null
var client = null

var ip_address = "192.168.1.7"


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
	print("joining: " + ip_address)
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, DEFAULT_PORT)
	get_tree().set_network_peer(client)

func _connected_to_server():
	#print("connected to server!")	
	pass

func _server_disconnected():
	print("disconnected from server")

func _player_joined(id):
	#print("player  id#: " +str(id) + "  connected")
	pass
	
func _connection_failed():
	print("failed connection")


