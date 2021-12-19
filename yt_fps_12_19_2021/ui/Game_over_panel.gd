extends Panel

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Globals.connect("new_score", self, "_on_new_score")
	
func _on_new_score(player, score):
	if score >= Globals.score_limit:
		$Label.text = str(player) + " Won the game!!"
		Globals.emit_signal("game_over", player)
		show()
		

func _on_Button_pressed():
	if get_tree().has_network_peer():
		rpc("back_to_lobby")
	back_to_lobby()
	
remote func back_to_lobby():
	clear_data()
	get_tree().change_scene("res://ui/Lobby.tscn")
		
func _on_play_again_pressed():
	rpc("reset_game")
	reset_game()
	
remote func reset_game():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	for p in Players.player_list:
		Globals.emit_signal("respawn_player", str(p))
	
func clear_data():

	for p in NetNodes.players.get_children():
		print("removing player " + p.name + " from net nodes")
		p.queue_free()
#	for b in NetNodes.bullets.get_children():
#		print("removing bullet: " + b.name + " from net nodes")
#		b.queue_free()
	#Players.player_list.clear()
	#pass
