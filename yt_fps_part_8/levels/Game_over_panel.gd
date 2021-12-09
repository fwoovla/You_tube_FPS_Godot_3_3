extends Panel

func _ready():
	Globals.connect("new_score", self, "_on_new_score")
	
func _on_new_score(player, score):
	if score >= Globals.score_limit:
		$Label.text = str(player) + " Won the game!!"
		Globals.emit_signal("game_over", player)
		show()
		

func _on_Button_pressed():
	rpc("reset_game")
	reset_game()
	
remote func reset_game():
	for p in Players.player_list:
		Globals.emit_signal("respawn_player", str(p))
		
#	rpc("back_to_lobby")
#	back_to_lobby()
#
#remote func back_to_lobby():
#	clear_data()
#	get_tree().change_scene("res://levels/Lobby.tscn")

func clear_data():
	for p in NetNodes.players.get_children():
		p.queue_free()
	for b in NetNodes.bullets.get_children():
		b.queue_free()
	Players.player_list.clear()
