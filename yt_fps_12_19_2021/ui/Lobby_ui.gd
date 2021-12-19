extends Control

var selected_level = null

func ready():
	if get_tree().has_network_peer():
		print("still connected to players")
		$Game_settings.hide()
		for p in Players.player_list:
			$Players_panel/ItemList.add_item(Players.player_list[p]["username"])
		$Players_panel.show()
		$Start_button.disabled = true
		$Game_panel/Join_server_button.disabled = true
	pass

func _on_Quit_button_pressed():
	get_tree().quit()

func _on_LineEdit_text_changed(new_text):
	Network.ip_address = new_text

func join_lobby():
	$Welcome_label.text = "Welcome to the game!  Waiting for players..."
	$Welcome_label.show()
	rpc_id(1, "send_player_info", Players.player_info)
	yield(get_tree().create_timer(.1),"timeout")
	#print("welcome to the lobby")
	
func player_connected(id):
	$Welcome_label.text = "Found " + str(get_tree().get_network_connected_peers().size()) + " other players."
	$Welcome_label.show()	
	print("player  id#: " + str(id) + "  found")
	
	if get_tree().get_network_connected_peers().size() <= Network.MAX_CLIENTS and get_tree().is_network_server():
		$Start_button.show()

func _on_Create_server_button_pressed():
	if $Settings_panel/Username_edit.text != "":
		Players.set_info()
		Players.player_list[1]["team"] = 1
		Network.create_server()
		$Game_panel/Create_server_button.disabled = true
		$Game_panel/Join_server_button.disabled = true
		$Welcome_label.text = "Server started.  Looking for players..."
		$Welcome_label.show()
		for p in Players.player_list:
			$Players_panel/ItemList.add_item(Players.player_list[p]["username"])
		$Game_settings.hide()
		$Players_panel.show()

func _on_Join_server_button_pressed():
	if $Settings_panel/Username_edit.text != "":
		Players.set_info()
		Network.join_server()
		$Game_panel/Create_server_button.disabled = true
		$Game_panel/Join_server_button.disabled = true
		$Game_settings.hide()

func _on_Start_button_pressed():
	rpc("start_game")
	start_game()

remote func start_game():
	get_tree().change_scene(selected_level)	

func _on_Username_edit_text_changed(new_text):
	Players.username = new_text

remote func send_player_info(info):
	Players.player_count += 1
	info["team"] = Players.player_count
	Players.player_list[get_tree().get_rpc_sender_id()] = info
	$Players_panel/ItemList.add_item(Players.player_list[get_tree().get_rpc_sender_id()]["username"])
	for p in Players.player_list:
		if p != 1:
			rpc_id(p, "recieve_player_info", Players.player_list, Globals.score_limit, selected_level)
	#print(Players.player_list)
	
remote func recieve_player_info(player_list, score_limit, level):
	selected_level = level
	Globals.score_limit = score_limit
	Players.player_list = player_list
	Players.team = player_list[get_tree().get_network_unique_id()]["team"]
	for p in Players.player_list:
		$Players_panel/ItemList.add_item(Players.player_list[p]["username"])
	$Players_panel.show()
	#print(Players.player_list)


func _on_Single_player_button_pressed():
	Globals.single_player = true
	Players.set_info()
	Players.player_list[1]["team"] = 1
	start_game()

func _on_SpinBox_value_changed(value):
	Globals.score_limit = value


func _on_level_1_button_pressed():
	selected_level = "res://levels/Level_2.tscn"
	$Game_settings/level_label.text = " Level 1"


func _on_level_2_button_pressed():
	selected_level = "res://levels/Level_3.tscn"
	$Game_settings/level_label.text = "Level 2"


func _on_level_3_button_pressed():
	selected_level = "res://levels/Level_4.tscn"
	$Game_settings/level_label.text = "Level 3"


func _on_level_3_button2_pressed():
	selected_level = "res://levels/Level_5.tscn"
	$Game_settings/level_label.text = "Level 4"
