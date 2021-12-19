extends Spatial

var players
var bullets
var enemies


func _ready():
	players = Spatial.new()
	bullets = Spatial.new()
	enemies = Spatial.new()
	add_child(players)
	add_child(bullets)
	add_child(enemies)
	pass
