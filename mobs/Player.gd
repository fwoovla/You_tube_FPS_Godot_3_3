extends KinematicBody

export(NodePath) onready var turret = get_node(turret) as Spatial

var velocity = Vector3.ZERO
var speed = 20.0
var ground_acc = 5.0
var air_acc = 0

var jump_power = 30

var health = 100
var guns = []
var current_gun = null
var bullet_num = 0

var puppet_position = Vector3()
var puppet_velocity = Vector3()
var puppet_rotation = Vector3()


func _ready():
	if is_network_master():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

		$Turret/Camera.current = is_network_master()

		guns.append(Globals.pea_shooter.instance())
		current_gun = guns[0]
		$Turret.add_child(current_gun)
		Globals.connect("bullet_hit", self, "_bullet_hit")


func _process(delta):
	if is_network_master():
		$health.text = " "
		$health.text = str(health)
		

func _physics_process(delta):
	if is_network_master():	
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
	if is_network_master():
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
		
	if Input.is_action_just_pressed("shoot"):
		current_gun.shoot(name)
	
	if Input.is_action_just_pressed("right_mouse"):
		$Tween.interpolate_property($Turret/Camera, "fov", 70, 30, .1)
		$Tween.start()
	if Input.is_action_just_released("right_mouse"):
		$Tween.interpolate_property($Turret/Camera, "fov", $Turret/Camera.fov, 70, .1)
		$Tween.start()
		
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	return dir.normalized()

func take_damage(dmg):
	rpc("_take_damage_remote", dmg)
	health -= dmg
	print(health)
	
remote func _take_damage_remote(dmg):
	health -= dmg
	print(health)
	
func _bullet_hit(damage):
	if is_network_master():
		$hit_label.modulate = Color.white
		$hit_label.text = str(damage)
		$hit_label.show()
		$hit_label/Tween.interpolate_property($hit_label, "modulate", $hit_label.modulate, Color.transparent, .5)
		$hit_label/Tween.start()	


puppet func update_state(p_pos, p_vel, p_rot):
	puppet_position = p_pos
	puppet_velocity = p_vel
	puppet_rotation = p_rot
	$Tween.interpolate_property(self, "global_transform", global_transform, Transform(global_transform.basis,p_pos), .1)
	$Tween.start()


func _on_network_timer_timeout():
	if is_network_master() and name == str(get_tree().get_network_unique_id()):
		rpc_unreliable("update_state", global_transform.origin, velocity, Vector2($Turret.rotation.x, rotation.y))
