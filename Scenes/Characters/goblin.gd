extends CharacterBody2D

var speed = 200
var player_chase = false
var player = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var alive = true

func _ready():
	$damage_zone/CollisionShape2D.disabled

func _physics_process(delta):
	if alive == false:
		$damage_zone/CollisionShape2D.disabled = true
	
	velocity.y += gravity * delta
	if alive == false:
		return
		
	if player_chase:
		velocity.x = sign(player.global_position.x - global_position.x) * speed
		if velocity.x < 0:
			$animations.play("run")
			$animations.flip_h = true
		elif velocity.x > 0:
			$animations.play("run")
			$animations.flip_h = false
	else:
		$animations.play("idle")
		velocity.x = 0.0
	move_and_slide()

func _on_detection_zone_area_entered(body):
	player = body
	player_chase = true

func _on_detection_zone_area_exited(body):
	player = null
	player_chase = false

func _on_hit_zone_area_entered(area: Area2D):
	if alive:
		die()
		
func die():
	alive = false
	collision_layer = 0
	collision_mask = 0
	$animations.play("death")
	$death_timer.start()

func _on_death_timer_timeout() -> void:
	queue_free()
