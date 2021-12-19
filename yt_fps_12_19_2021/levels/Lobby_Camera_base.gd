extends Spatial

var speed = .3

func _process(delta):
	rotate_y(speed * delta)
