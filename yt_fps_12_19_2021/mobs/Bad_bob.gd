extends KinematicBody

#export(NodePath) onready var turret = get_node(turret) as Spatial
const IDLE = 0
const ATTACK = 1
const DEFEND = 2
const FLEE = 3

var state = 0


var velocity = Vector3.ZERO
var speed = 14.0
var rotation_speed = 5
var ground_acc = 15.0
var air_acc = 2
var jump_power = 20
var health = 100
var max_health = 125
var current_gun = null
var bullet_num = 0
var is_master = false

var targets = []
var current_target = null

var health_locations = [] 
var pack_target = WeakRef

var puppet_position = Vector3()
var puppet_velocity = Vector3()
var puppet_rotation = Vector3()

func _ready():
	current_gun = Globals.sparkle_gun.instance()
	$Turret.add_child(current_gun)
	Globals.connect("bullet_hit", self, "_bullet_hit")


func initialize(id, _master):
	if get_tree().has_network_peer() or Globals.single_player:
		name = str(id)
		if get_tree().has_network_peer() and _master:
			set_network_master(1)
		$network_timer.start()
		is_master = _master
		print("enemy " + str(id) + " created with master of " + str(get_network_master()))
		
func _process(delta):
	state = get_state()


func _physics_process(delta):
	if is_master or Globals.single_player:	
		var movement = _get_movement(delta)
		var _acc = 0

		if is_on_floor():
			_acc = ground_acc
		else:
			_acc = air_acc
#
		if current_target:
			velocity.x = lerp(velocity.x, movement.x * speed, _acc * delta)
			velocity.z = lerp(velocity.z, movement.z * speed, _acc * delta)
			velocity.y += Globals.gravity * delta
#
	else:
		global_transform.origin = puppet_position
		velocity.x = puppet_velocity.x
		velocity.z = puppet_velocity.z
		rotation.y = puppet_rotation.y
		$Turret.rotation.x = puppet_rotation.x

	if !$Tween.is_active():	
		velocity = move_and_slide(velocity, Vector3.UP)
		
func _get_movement(delta):
	var dir = Vector3.DOWN
	
	if state == IDLE:
		#print(state)
		dir = do_idle_state()

	if state == ATTACK:
		#print(state)
		global_transform = rotate_to_target(current_target, delta)
		dir = do_attack_state()

	if state == DEFEND:
		#print(state)
		global_transform = rotate_to_target(current_target, delta)
		dir = do_defend_state()
		
	if state == FLEE:
		#print(state)
		global_transform = rotate_to_target(current_target, delta)
		dir = do_flee_state()

	return dir.normalized()

func rotate_to_target(target, delta):
	var global_pos = global_transform.origin
	var wtransform = global_transform.looking_at(Vector3(target.global_transform.origin.x, global_transform.origin.y, target.global_transform.origin.z),Vector3(0,1,0))
	var wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), rotation_speed * delta)
	return Transform(Basis(wrotation), global_transform.origin)
		
func rotate_away_from_target(target, delta):
	var global_pos = global_transform.origin
	var wtransform = global_transform.looking_at(Vector3(target.global_transform.origin.x, global_transform.origin.y, target.global_transform.origin.z),Vector3(0,1,0))
	var wrotation = Quat(global_transform.basis).slerp(Quat(wtransform.basis), -rotation_speed * delta)
	return Transform(Basis(wrotation), global_transform.origin)	

func take_damage(dmg, bullet_owner):
	#print("bullet owner " + bullet_owner)
	if get_tree().has_network_peer():
		rpc("_take_damage_remote", dmg, bullet_owner)
	health -= dmg
	if health <=0:
		health = 100
		if Globals.single_player:
			Players.player_list[int(bullet_owner)]["points"] += 1
			Globals.emit_signal("new_score", bullet_owner, Players.player_list[int(bullet_owner)]["points"])
#			if get_tree().has_network_peer():
#				for p in Players.player_list:
#					if p != int(name):
#						rpc_id(p, "update_score", bullet_owner, Players.player_list[int(bullet_owner)]["points"])
			if NetNodes.enemies.has_node(name):
				Globals.emit_signal("remove_enemy", name)

remote func _take_damage_remote(dmg, bullet_owner):
	health -= dmg
	if health <=0:
		health = 100
		#Globals.emit_signal("respawn_player", name)
		Players.player_list[int(bullet_owner)]["points"] += 1
		Globals.emit_signal("new_score", bullet_owner, Players.player_list[int(bullet_owner)]["points"])
		if get_tree().has_network_peer():
			for p in Players.player_list:
				if p != int(name):
					rpc_id(p, "update_score", bullet_owner, Players.player_list[int(bullet_owner)]["points"])
				if NetNodes.enemies.has_node(name):
					Globals.emit_signal("remove_enemy", name)	
	
func _bullet_hit(damage, bullet_owner):
	pass

func get_health(health_val):
	health +=health_val
	if health > max_health:
		health = max_health
		
	if targets.size() > 0:
		current_target = targets[0]

puppet func update_positions(p_pos, p_vel, p_rot):
	puppet_position = p_pos
	puppet_velocity = p_vel
	puppet_rotation = p_rot
	$Tween.interpolate_property(self, "global_transform", global_transform, Transform(global_transform.basis,p_pos), .1)
	$Tween.start()

remote func update_score(player, score):
	Players.player_list[int(player)]["points"] = score
	Globals.emit_signal("new_score", player, Players.player_list[int(player)]["points"])

func _on_network_timer_timeout():
	if get_tree().has_network_peer() and is_master:
		rpc_unreliable("update_positions", global_transform.origin, velocity, Vector2(0, rotation.y))

func _on_Area_body_entered(body):
	#print("where ARE you?")
	if body.is_in_group("Player"):		
		targets.append(body)

func _on_Area_body_exited(body):
	#print("i've lost you")
	targets.erase(body)
	if body == current_target:
		current_target = null


func _on_scan_timer_timeout():
	if is_master or Globals.single_player:
		#print(targets.size())
		if state != FLEE:
			if targets.size() > 0:
				#print("looking")
				for t in range(targets.size() ):
					$Sightline.look_at(targets[t].global_transform.origin, Vector3.UP)
					$Sightline.force_raycast_update()
					if $Sightline.is_colliding():
						#print("is it you?")
						if $Sightline.get_collider().is_in_group("Player"):
							if !current_target:
								current_target = $Sightline.get_collider()
								#print("i found you!")
						else:
							current_target = null

func get_state():
	var state = 0
	if !current_target:
		#print("idle")
		state = IDLE
	if current_target:
		if global_transform.origin.distance_to(current_target.global_transform.origin) < 15 and health > 20:
			#print("defending")
			state = DEFEND
		if global_transform.origin.distance_to(current_target.global_transform.origin) > 15 and health > 20:
			#print("attacking")
			state = ATTACK
		if health <= 20:
			#print("run away")
			state = FLEE
	return state
	
func do_idle_state():
	#print("idle state")
	var dir = Vector3.DOWN
	return dir.normalized()

func do_attack_state():
	#print("attack state")
	var dir = Vector3.DOWN
	dir -= transform.basis.z
	return dir.normalized()
	
func do_defend_state():
	#print("defend state")
	var dir = Vector3.DOWN
	dir += transform.basis.z
	return dir.normalized()

func do_flee_state():
	#print("flee state")
	var dir = Vector3.DOWN

	if pack_target.get_ref():
		current_target = pack_target.get_ref()
		
	dir -= transform.basis.z
	return dir.normalized()


func _on_next_action_timeout():
	pass


func _on_Area_area_entered(area):
	print("area detected")
	
	var dupl = false
	if area.is_in_group("Healthpack"):
		print("pack located")
		
		var p = weakref(area)
		
		for h in health_locations:
			if h.get_ref():
				if h == p:
					dupl = true
			if !h.get_ref():
				health_locations.erase(h)
					
		if !dupl:
			print("new healthpack at " + str(p.get_ref().global_transform.origin) + " added")
			health_locations.append(p)
			print(health_locations)
			
	var closest_dist = 5000
	var closest_pack = null
	
	for h in health_locations:
		if !h.get_ref():
			health_locations.erase(h)
		else:
			var dist = global_transform.origin.distance_to(h.get_ref().global_transform.origin)
			if dist < closest_dist:
				closest_dist = dist
				closest_pack = h
				print("new closest is " + str(closest_pack.get_ref().global_transform.origin))

		pack_target = closest_pack

