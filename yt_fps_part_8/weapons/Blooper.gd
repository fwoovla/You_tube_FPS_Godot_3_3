extends Spatial

var b_tag = "bloop"
var can_shoot = true

func shoot(_parent_name):
	if can_shoot:
		$AnimationPlayer.play("shoot")
		can_shoot = false
		$Timer.start()
		rpc("shoot_remote", _parent_name)
		var b = Globals.bloop.instance()
		NetNodes.bullets.add_child(b)
		b.real = true
		b.global_transform = $Muzzle.global_transform
		b.bullet_owner = _parent_name
		b.name = NetNodes.players.get_node(_parent_name).name + str(NetNodes.players.get_node(_parent_name).bullet_num)
		NetNodes.players.get_node(_parent_name).bullet_num +=1
		print(b.name)

remote func shoot_remote(_parent_name):
	var b = Globals.bloop.instance()
	NetNodes.bullets.add_child(b)
	b.real = false
	b.global_transform = $Muzzle.global_transform
	b.bullet_owner = _parent_name
	b.name = NetNodes.players.get_node(_parent_name).name + str(NetNodes.players.get_node(_parent_name).bullet_num)
	NetNodes.players.get_node(_parent_name).bullet_num +=1
	print(b.name)

func _on_Timer_timeout():
	can_shoot = true
