extends Control


func ready():
	$LineEdit.text = "127.0.0.1"

func _on_Create_button_pressed():
	Network.create_server()
	hide()
	Globals.emit_signal("instance_player", get_tree().get_network_unique_id(), (Globals.team_index % 2) +1)
	print(str(get_tree().get_network_unique_id()) + " started server")

func _on_Join_button_pressed():
	Network.join_server()
	yield(get_tree().create_timer(1),"timeout")
	rpc_id(1, "team_info_request")
	yield(get_tree().create_timer(1),"timeout")
	hide()
	Globals.emit_signal("instance_player", get_tree().get_network_unique_id(), (Globals.team_index % 2) +1)
	print(str(get_tree().get_network_unique_id()) + " joined server")

func _on_Quit_button_pressed():
	get_tree().quit()

func _on_LineEdit_text_changed(new_text):
	Network.ip_address = new_text

remote func team_info_request():
	Globals.team_index +=1
	var id = get_tree().get_rpc_sender_id()
	print("request from", id, "sending " +str(Globals.team_index))
	rpc_id(id, "set_team", Globals.team_index)

remote func set_team(team):
	print(" team_index set to " + str(Globals.team_index))
	Globals.team_index = team
