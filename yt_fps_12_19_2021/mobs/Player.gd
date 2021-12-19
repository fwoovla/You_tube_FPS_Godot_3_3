extends KinematicBody

export(NodePath) onready var turret = get_node(turret) as Spatial

var velocity = Vector3.ZERO
var speed = 20.0
var ground_acc = 15.0
var air_acc = 2
var jump_power = 20
var health = 100
var max_health = 125
var guns = []
var gun_index = 0
var current_gun = null
var bullet_num = 0
var is_master = false

var puppet_position = Vector3()
var puppet_velocity = Vector3()
var puppet_rotation = Vector3()

func _ready():
		
	guns.append(Globals.pea_shooter.instance())
	guns.append(Globals.blooper.instance())
	guns.append(Globals.sparkle_gun.instance())
	current_gun = guns[gun_index]
	$Turret.add_child(current_gun)
	Globals.connect("bullet_hit", self, "_bullet_hit")
	#Globals.connect("new_score", self, "_on_new_score")

func initialize(id):
	if get_tree().has_network_peer() or Globals.single_player:
		name = str(id)
		if get_tree().has_network_peer():
			set_network_master(id)
		if id == Players.net_id:
			is_master = true
		if is_master or Globals.single_player: #is_network_master():
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			$Turret/Camera.current = is_master# is_network_master()
			$network_timer.start()
			$health.show()
			$crosshair.show()
			#$"love-shield".show()
			$hit_label.show()
			$ammo.show()
			
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$Turret/Camera.current = true
		$network_timer.stop()
		
func _process(delta):
	if is_master or Globals.single_player:	
		$health.text = " "
		$health.text = str(health)
		$team.text = str(Players.team)
		$ammo.text = str(current_gun.ammo_count)
		
func _physics_process(delta):
	if is_master or Globals.single_player:	
		var movement = _get_movement()
		var _acc = 0
		
		if is_on_floor():
			_acc = ground_acc
		else:
			_acc = air_acc
			
		velocity.x = lerp(velocity.x, movement.x * speed, _acc * delta)
		velocity.z = lerp(velocity.z, movement.z * speed, _acc * delta)
		velocity.y += Globals.gravity * delta
		
	else:
		global_transform.origin = puppet_position
		velocity.x = puppet_velocity.x
		velocity.z = puppet_velocity.z
		rotation.y = puppet_rotation.y
		$Turret.rotation.x = puppet_rotation.x

	if !$Tween.is_active():	
		velocity = move_and_slide(velocity, Vector3.UP)
		
func _unhandled_input(event):
	#print(event.as_text())
	if is_master or Globals.single_player:	
		if event is InputEventMouseMotion:
			_handle_camera_rotation(event)
		
func _handle_camera_rotation(event):
	if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		rotate_y(deg2rad(-event.relative.x) * Globals.camera_sensitivity)
		$Turret.rotate_x(deg2rad(-event.relative.y) * Globals.camera_sensitivity)
		$Turret.rotation.x = clamp($Turret.rotation.x, deg2rad(Globals.MIN_CAMERA_ANGLE), deg2rad(Globals.MAX_CAMERA_ANGLE))

func _get_movement():
	var dir = Vector3.DOWN
	
	if Input.is_action_pressed("forward"):
		dir -= transform.basis.z
	if Input.is_action_pressed("backward"):
		dir += transform.basis.z
	if Input.is_action_pressed("left"):
		dir -= transform.basis.x
	if Input.is_action_pressed("right"):
		dir += transform.basis.x		

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_power
		
	if Input.is_action_just_pressed("shoot") or Input.is_action_pressed("shoot"):
		current_gun.shoot(name)
	
	if Input.is_action_just_pressed("right_mouse"):
		$Tween.interpolate_property($Turret/Camera, "fov", 70, 30, .1)
		$Tween.start()
	if Input.is_action_just_released("right_mouse"):
		$Tween.interpolate_property($Turret/Camera, "fov", $Turret/Camera.fov, 70, .1)
		$Tween.start()
	
	if Input.is_action_just_pressed("tab"):
		$Score_list.show()
	if Input.is_action_just_released("tab"):
		$Score_list.hide()
		
	if Input.is_action_just_pressed("next_item") or Input.is_action_just_pressed("wheel_up"):
		print("wheel")
		next_gun()
		
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	return dir.normalized()

func next_gun():
	if get_tree().has_network_peer():
		rpc("next_gun_remote")
	$Turret.remove_child(current_gun)
	gun_index +=1
	if gun_index > guns.size() -1:
		gun_index = 0
	current_gun = guns[gun_index]
	$Turret.add_child(current_gun)

remote func next_gun_remote():
	$Turret.remove_child(current_gun)
	gun_index +=1
	if gun_index > guns.size() -1:
		gun_index = 0
	current_gun = guns[gun_index]
	$Turret.add_child(current_gun)
	
func take_damage(dmg, bullet_owner):
	#print("bullet owner " + bullet_owner)
	if get_tree().has_network_peer():
		rpc("_take_damage_remote", dmg, bullet_owner)
	health -= dmg
	if health <=0:
		health = 100
#		print(Players.player_list)
#		Players.player_list[int(bullet_owner)]["points"] += 1
#		Globals.emit_signal("new_score", bullet_owner, Players.player_list[int(bullet_owner)]["points"])
		
remote func _take_damage_remote(dmg, bullet_owner):
	#print("remote bullet owner " + bullet_owner)
	$damage/AnimationPlayer.stop(true)
	$damage/AnimationPlayer.play("damage")
	$"health/love-shield/AnimationPlayer".play("New Anim")
	health -= dmg
	if health <=0:
		health = 100
		Globals.emit_signal("respawn_player", name)
		Players.player_list[int(bullet_owner)]["points"] += 1
		Globals.emit_signal("new_score", bullet_owner, Players.player_list[int(bullet_owner)]["points"])
		if get_tree().has_network_peer():
			for p in Players.player_list:
				if p != int(name):
					rpc_id(p, "update_score", bullet_owner, Players.player_list[int(bullet_owner)]["points"])
	
func _bullet_hit(damage, bullet_owner):

	if is_master or Globals.single_player and bullet_owner:
		$hit_label.modulate = Color.white
		$hit_label.text = str(damage)
		$hit_label.show()
		$hit_label/Tween.interpolate_property($hit_label, "modulate", $hit_label.modulate, Color.transparent, .5)
		$hit_label/Tween.start()	

func get_health(health_val):
	if is_master or Globals.single_player:
		$health_effect/AnimationPlayer.play("pick_up")
	health +=health_val
	if health > max_health:
		health = max_health

func get_item(item):
	if is_master or Globals.single_player:
		$pickup_effect/AnimationPlayer.play("pick_up")
	var gun = item.instance()
	#print("new gun name" + gun.name)
	var has_item = false 
	for g in guns:
		if g.name == gun.name:
			has_item = true
			g.ammo_count += gun.ammo_count
			if g.ammo_count > g.max_ammo:
				g.ammo_count = g.max_ammo
	if !has_item:
		guns.append(gun)
	#print(guns.size())


puppet func update_state(p_pos, p_vel, p_rot):
	puppet_position = p_pos
	puppet_velocity = p_vel
	puppet_rotation = p_rot
	$Tween.interpolate_property(self, "global_transform", global_transform, Transform(global_transform.basis,p_pos), .1)
	$Tween.start()

remote func update_score(player, score):
	Players.player_list[int(player)]["points"] = score
	Globals.emit_signal("new_score", player, Players.player_list[int(player)]["points"])
	#print(Players.player_list)

func _on_network_timer_timeout():
	if get_tree().has_network_peer() and is_master:
	#if is_network_master():# and name == str(get_tree().get_network_unique_id()):
		rpc_unreliable("update_state", global_transform.origin, velocity, Vector2($Turret.rotation.x, rotation.y))

