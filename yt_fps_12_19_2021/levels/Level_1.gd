extends Spatial

var bullet_num = 0

func _ready():
	
	Players.set_ids()
	instance_players()
	
	print(Players.id_list)
	print("Level")
	Globals.connect("player_shot", self, "_player_shot")
	Globals.connect("remove_bullet", self, "_remove_bullet")
	Globals.connect("respawn_player", self, "_respawn_player")
	
func instance_players():
	for id in Players.player_list:
		instance_player(id)
	#instance_player(Players.net_id)
	
func instance_player(id):
	print("creating player  " +str(id))
	var p = Globals.player.instance()
	NetNodes.players.add_child(p)
	p.initialize(id)
	p.global_transform.origin = get_node("Spawns/" + str(Players.player_list[id]["team"]) + "/point").global_transform.origin

func _respawn_player(player):
	print("you have died")
	var p = NetNodes.players.get_node(player)
	p.hide()
	print(Players.player_list)
	p.global_transform.origin = get_node("Spawns/" + str(Players.player_list[int(player)]["team"]) + "/point").global_transform.origin
	yield(get_tree().create_timer(1),"timeout")
	p.show()
	
func _respawn_remote(player):
	#print("you have died")
	var p = NetNodes.players.get_node(player)
	p.hide()
	print(Players.player_list)
	p.global_transform.origin = get_node("Spawns/" + str(Players.player_list[int(player)]["team"]) + "/point").global_transform.origin
	yield(get_tree().create_timer(1),"timeout")
	p.show()
	
func _remove_bullet(bullet):
	#rpc("_remove_bullet_remote", bullet)
	if NetNodes.bullets.has_node(bullet):
		NetNodes.bullets.get_node(bullet).queue_free()
		print(bullet +" removed")

remote func _remove_bullet_remote(bullet):
	if NetNodes.bullets.has_node(bullet):
		NetNodes.bullets.get_node(bullet).queue_free()
		print(bullet +" removed")	


