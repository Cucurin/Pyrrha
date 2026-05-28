extends Control

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("new_animation")
	
func pause():
	get_tree().paused = true
	$AnimationPlayer.play("new_animation")
	
func testEsc():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused:
		resume()

func _on_resume_pressed():
	if get_tree().paused:
		resume()

func _on_restart_pressed():
	if get_tree().paused:
		resume()
		get_tree().reload_current_scene()

func _on_main_menu_pressed():
	if get_tree().paused:
		resume()
		get_tree().change_scene_to_file("res://Scenes/Screens/MainMenu.tscn")
	
func _process(delta):
	testEsc()
