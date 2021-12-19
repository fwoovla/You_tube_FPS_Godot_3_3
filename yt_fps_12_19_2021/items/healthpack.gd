extends Spatial

var power = 25

signal picked_up

func _on_Area_body_entered(body):
	if body.is_in_group("Player") or body.is_in_group("Enemy"):
		body.get_health(power)
		emit_signal("picked_up")
		queue_free()

