extends Spatial

var wave_num = 1
var nun_enemies = 1
var difficulty = 1

func start_wave():
	randomize()
	yield(get_tree().create_timer(.1),"timeout")
	print("starting wave")
	if get_tree().has_network_peer() or Globals.single_player:
		for e in range(nun_enemies):
			instance_enemy(1000 + e)
		
func instance_enemy(id):
	if get_tree().has_network_peer():
		for p in Players.player_list:
			if p != 1:
				rpc_id(p, "instance_enemy_remote", id)
	print("creating enemy  " +str(id))
	var e = Globals.bad_bob.instance()
	NetNodes.enemies.add_child(e)
	e.initialize(id, true)
	e.global_transform.origin.x = rand_range(-20,20)
	e.global_transform.origin.z = rand_range(-20,20)
	
remote func instance_enemy_remote(id):
	#rpc("instance_enemy_remote", id)
	print("creating enemy  " +str(id))
	var e = Globals.bad_bob.instance()
	NetNodes.enemies.add_child(e)
	e.initialize(id, false)
