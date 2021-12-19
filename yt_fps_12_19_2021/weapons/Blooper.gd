extends Spatial

var b_tag = "bloop"
var can_shoot = true
var ammo_count = 15
var max_ammo = 15

func shoot(_parent_name):
	if can_shoot and ammo_count > 0:
		$AnimationPlayer.play("shoot")
		can_shoot = false
		ammo_count -=1
		$Timer.start()
		if get_tree().has_network_peer():
			rpc("shoot_remote", _parent_name)
		var b = Globals.bloop.instance()
		NetNodes.bullets.add_child(b)
		b.real = true
		b.global_transform = $Muzzle.global_transform
		b.bullet_owner = _parent_name
		b.name = NetNodes.players.get_node(_parent_name).name + str(NetNodes.players.get_node(_parent_name).bullet_num)
		NetNodes.players.get_node(_parent_name).bullet_num +=1
		#print(b.name)

remote func shoot_remote(_parent_name):
	var b = Globals.bloop.instance()
	NetNodes.bullets.add_child(b)
	b.real = false
	b.global_transform = $Muzzle.global_transform
	b.bullet_owner = _parent_name
	b.name = NetNodes.players.get_node(_parent_name).name + str(NetNodes.players.get_node(_parent_name).bullet_num)
	NetNodes.players.get_node(_parent_name).bullet_num +=1
	#print(b.name)

func _on_Timer_timeout():
	can_shoot = true
