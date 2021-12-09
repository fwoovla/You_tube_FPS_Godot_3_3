extends Spatial

var damage = 0
var velocity = Vector3.ZERO
var speed = 40
var dec = -.3
var bullet_owner = ""
var real = false

onready var splash = $Bloop_splash

var setup_tick = false
var hit = false

func _ready():
	randomize()
	pass
	
func _physics_process(delta):
	if !setup_tick:
		velocity = -transform.basis.z * speed
		setup_tick = true
	
	if !hit:	
		velocity += (Vector3.DOWN * 50) * delta

		transform.origin += velocity * delta
		velocity -= transform.basis.z * dec

func _on_Timer_timeout():
	Globals.emit_signal("remove_bullet", self.name)
	#queue_free()

func _on_Area_body_entered(body):
	#if real:
	if body.name != bullet_owner:
		damage = int(rand_range(10,20))
		if body.has_method("take_damage") and body.name != bullet_owner and real:
			body.take_damage(damage, bullet_owner)
			if bullet_owner == str(get_tree().get_network_unique_id()):
				Globals.emit_signal("bullet_hit", damage, bullet_owner)
		bloop()
	#print("hit " + body.name + " by player " + str(bullet_owner))

func bloop():
	print("hit")
	hit = true
	$MeshInstance.hide()
	velocity = Vector3.ZERO
	$Bloop_splash/Particles.emitting = true
	$Bloop_splash/AnimationPlayer.play("bloop")

	$AnimationPlayer.play("bloop")

func _on_AnimationPlayer_animation_finished(anim_name):
	$Area.queue_free()
