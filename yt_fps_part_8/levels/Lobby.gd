extends Spatial

var player = preload("res://mobs/Player.tscn") 
var bullet_num = 0

signal new_player
signal good_connection

func _ready():
	print("signals connected")
	connect("good_connection", $Lobby_ui, "join_lobby")
	connect("new_player", $Lobby_ui, "player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("network_peer_connected", self, "_player_joined")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	
func _player_joined(id):
	print(str(get_tree().get_network_connected_peers()) + "  is in the lobby")
	emit_signal("new_player", id)

func _connected_to_server():
	emit_signal("good_connection")

func _player_disconnected(id):
	pass

