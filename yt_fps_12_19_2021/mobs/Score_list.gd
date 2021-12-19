extends ItemList


func _ready():
	Globals.connect("new_score", self, "_on_new_score")
	
	for p in Players.player_list:
		add_item(Players.player_list[p]["username"] + " : " + str(Players.player_list[p]["points"]))
	
	
func _on_new_score(player, score):
	clear()
	for p in Players.player_list:
		add_item(Players.player_list[p]["username"] + " : " + str(Players.player_list[p]["points"]))
