extends Spatial

var velocity = Vector3.ZERO
var speed = .5
var bullet_owner = ""
var damage = 0
var real = false

func _ready():
	randomize()
	
func _physics_process(delta):
	velocity += global_transform.basis.z * speed * delta
	global_transform.origin -= velocity

func _on_Timer_timeout():
	Globals.emit_signal("remove_bullet", name)

func _on_Area_body_entered(body):
	if real:
		if body.name != bullet_owner:
			damage = int(rand_range(10,20))
			if body.has_method("take_damage") and body.name != bullet_owner and bullet_owner:
				body.take_damage(damage)
				if bullet_owner == str(get_tree().get_network_unique_id()):
					Globals.emit_signal("bullet_hit", damage)
			hit()
		
func hit():
	$MeshInstance.hide()
	_on_Timer_timeout()
