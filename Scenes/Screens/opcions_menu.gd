extends Control

func _on_controller_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Screens/OpcionsMenuController.tscn")

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Screens/MainMenu.tscn")

func _on_keyboard_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Screens/OpcionsMenu.tscn")

func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Screens/MainMenu.tscn")
