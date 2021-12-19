extends Spatial

func _ready():
	$AnimationPlayer.stop(true)

func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		print("activating")
		$AnimationPlayer.play()
