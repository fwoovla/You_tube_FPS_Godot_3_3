extends Spatial

var player = preload("res://mobs/Player.tscn") 
var bullet_num = 0


func _ready():
	print("signals connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("network_peer_connected", self, "_player_joined")
	Globals.connect("instance_player", self, "_instance_player")
	Globals.connect("player_shot", self, "_player_shot")
	Globals.connect("remove_bullet", self, "_remove_bullet")
	
func _player_joined(id):
	print(str(id) + "  connected")
	print(str(get_tree().get_network_connected_peers()) + "  are in the game")
	_instance_player(id)
		
func _player_disconnected(id):
	if has_node(str(id)):
		get_node(str(id)).queue_free()

func _instance_player(id):
	print("creating player  " +str(id))
	var p = player.instance()
	p.set_network_master(id)
	p.name = str(id)
	NetNodes.players.add_child(p)
	p.transform.origin.y += 10

func _player_shot(id, position):
	rpc("_player_shot_remote", id, position)
	var b = Globals.pea.instance()
	NetNodes.bullets.add_child(b)
	b.real = true
	b.global_transform = position
	b.bullet_owner = str(id)
	b.name = NetNodes.players.get_node(str(id)).name + str(NetNodes.players.get_node(str(id)).bullet_num)
	NetNodes.players.get_node(str(id)).bullet_num +=1
	print(b.name)

remote func _player_shot_remote(id, position):
	var b = Globals.pea.instance()
	NetNodes.bullets.add_child(b)
	b.real = false
	b.global_transform = position
	b.bullet_owner = str(id)
	b.name = NetNodes.players.get_node(str(id)).name + str(NetNodes.players.get_node(str(id)).bullet_num)
	NetNodes.players.get_node(str(id)).bullet_num +=1
	print(b.name)

func _remove_bullet(bullet):
	rpc("_remove_bullet_remote", bullet)
	if NetNodes.bullets.has_node(bullet):
		NetNodes.bullets.get_node(bullet).queue_free()
		print(bullet +" removed")

remote func _remove_bullet_remote(bullet):
	if NetNodes.bullets.has_node(bullet):
		NetNodes.bullets.get_node(bullet).queue_free()
		print(bullet +" removed")	
