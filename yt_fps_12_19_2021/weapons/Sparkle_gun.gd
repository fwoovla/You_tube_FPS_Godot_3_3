extends Spatial

var can_shoot = true
var bullet_owner = ""
var damage = 0
var ammo_count = 20
var max_ammo = 40

func shoot(_parent_name):
	if can_shoot and ammo_count > 0:
		can_shoot = false
		ammo_count -=1
		if ammo_count < 0:
			ammo_count = 0
		$Timer.start()
		if get_tree().has_network_peer():
			rpc("shoot_remote", _parent_name)
		var b = Globals.sparkle.instance()
		NetNodes.bullets.add_child(b)
		b.real = true
		b.global_transform = $Muzzle.global_transform
		b.bullet_owner = _parent_name
		bullet_owner = _parent_name
		b.name = NetNodes.players.get_node(_parent_name).name + str(NetNodes.players.get_node(_parent_name).bullet_num)
		NetNodes.players.get_node(_parent_name).bullet_num +=1
		#print(b.name)
		#print(_parent_name + " shot this sparkle")
		
		$RayCast.force_raycast_update()
		
		if $RayCast.is_colliding():
			#print($RayCast.get_collider())
			var c = $RayCast.get_collider()
			if c.has_method("take_damage") and c.name != _parent_name:
				#print(c)
				damage = int(rand_range(10, 20))
				c.take_damage(damage, bullet_owner)
				Globals.emit_signal("bullet_hit", damage, bullet_owner)

remote func shoot_remote(_parent_name):
	var b = Globals.sparkle.instance()
	NetNodes.bullets.add_child(b)
	b.real = false
	b.global_transform = $Muzzle.global_transform
	b.bullet_owner = _parent_name
	b.name = NetNodes.players.get_node(_parent_name).name + str(NetNodes.players.get_node(_parent_name).bullet_num)
	NetNodes.players.get_node(_parent_name).bullet_num +=1
	#print(b.name)


func _on_Timer_timeout():
	can_shoot = true

