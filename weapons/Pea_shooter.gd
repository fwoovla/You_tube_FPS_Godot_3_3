extends Spatial

func shoot(_parent_name):
	Globals.emit_signal("player_shot", _parent_name, $Muzzle.global_transform)

