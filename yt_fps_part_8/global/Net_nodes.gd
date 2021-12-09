extends Spatial

var players
var bullets


func _ready():
	players = Spatial.new()
	bullets = Spatial.new()
	add_child(players)
	add_child(bullets)
	pass
