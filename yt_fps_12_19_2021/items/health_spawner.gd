extends Spatial

var health_val = 20
var has_item = false

export (PackedScene) var _item

func _ready():
	if !has_item:
		var item = _item.instance() #Globals.health_pack.instance()
		add_child(item)
		item.connect("picked_up", self, "item_picked")
		has_item = true		

func _process(delta):
	pass

func item_picked():
	print("picked up")
	has_item = false
	$Timer.start(10)

func _on_Timer_timeout():
	var item = _item.instance()
	add_child(item)
	item.connect("picked_up", self, "item_picked")
	has_item = true			


#extends Spatial
#
#var health_val = 20
#var has_pack = false
#
#func _ready():
#	if !has_pack:
#		var pack = Globals.health_pack.instance()
#		add_child(pack)
#		pack.connect("picked_up", self, "pack_picked")
#		has_pack = true		
#
#func _process(delta):
#	pass
#
#func pack_picked():
#	print("picked up")
#	has_pack = false
#	$Timer.start(10)
#
#func _on_Timer_timeout():
#	var pack = Globals.health_pack.instance()
#	add_child(pack)
#	pack.connect("picked_up", self, "pack_picked")
#	has_pack = true			