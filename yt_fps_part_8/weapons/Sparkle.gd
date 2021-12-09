extends Spatial

var velocity = Vector3.ZERO
var speed = 7
var bullet_owner = ""
var damage = 0
var real = false
var did_hit = false
var one_tick = false

func _ready():
	randomize()
	
func _physics_process(delta):
	if !one_tick:
		one_tick = true
		$RayCast.force_raycast_update()
		if $RayCast.is_colliding():
			var p = $RayCast.get_collision_point()
			var dist = $RayCast.global_transform.origin.distance_to(p)
			print(dist)
			$MeshInstance.transform.origin.z = $RayCast.transform.origin.z - (dist/2)
			$MeshInstance.mesh.size.z = dist 
			$hit_particles.global_transform.origin = p
			$hit_particles.emitting = true

func _on_Timer_timeout():
	Globals.emit_signal("remove_bullet", name)

func _on_AnimationPlayer_animation_finished(anim_name):
	_on_Timer_timeout()
