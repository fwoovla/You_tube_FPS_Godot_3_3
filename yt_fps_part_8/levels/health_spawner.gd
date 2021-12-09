extends Spatial

var health_val = 20
var has_pack = false
	
func _ready():
	if !has_pack:
		var pack = Globals.health_pack.instance()
		add_child(pack)
		pack.connect("picked_up", self, "pack_picked")
		has_pack = true		

func _process(delta):
	pass

func pack_picked():
	print("picked up")
	has_pack = false
	$Timer.start(10)

func _on_Timer_timeout():
	var pack = Globals.health_pack.instance()
	add_child(pack)
	pack.connect("picked_up", self, "pack_picked")
	has_pack = true			
