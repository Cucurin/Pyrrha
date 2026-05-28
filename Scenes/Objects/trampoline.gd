extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	pass


func _on_activation_area_body_entered(body):
	$AnimatedSprite2D.play("launch")
	body.velocity.y = -900
	print(body)
