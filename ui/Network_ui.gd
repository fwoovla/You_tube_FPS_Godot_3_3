extends Control


func ready():
	$LineEdit.text = "127.0.0.1"

func _on_Create_button_pressed():
	Network.create_server()
	hide()
	Globals.emit_signal("instance_player", get_tree().get_network_unique_id())
	print(str(get_tree().get_network_unique_id()) + " started server")

func _on_Join_button_pressed():
	Network.join_server()
	hide()
	Globals.emit_signal("instance_player", get_tree().get_network_unique_id())
	print(str(get_tree().get_network_unique_id()) + " joined server")


func _on_Quit_button_pressed():
	get_tree().quit()


func _on_LineEdit_text_changed(new_text):
	Network.ip_address = new_text
