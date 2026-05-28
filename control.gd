extends Control
	
func _on_quit_pressed():
		get_tree().quit()

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/Screens/PrimeraPantalla.tscn")

func _on_controls_pressed():
	get_tree().change_scene_to_file("res://Scenes/Screens/OpcionsMenu.tscn")
