extends CharacterBody2D

var can_interact = false

func _physics_process(delta: float):
	if Input.is_action_just_pressed("ui_interact"):
		can_interact = true

func _on_flip_left_area_entered(area: Area2D):
	$AnimatedSprite2D.flip_h = true

func _on_flip_right_area_entered(area: Area2D):
	$AnimatedSprite2D.flip_h = false
