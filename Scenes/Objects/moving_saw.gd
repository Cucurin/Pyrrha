extends CharacterBody2D

var speed = 200
const RAY_FLOOR_POSITION_X = 20
const RAY_WALL_TARGET_POSITION_X = 20
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$AnimatedSprite2D.play("idle")
	velocity.x  = speed
	$raycast_floor_detection.position.x = RAY_FLOOR_POSITION_X
	$raycast_wall_detection.target_position.x = RAY_WALL_TARGET_POSITION_X

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if not $raycast_floor_detection.is_colliding() || $raycast_wall_detection.is_colliding():
		velocity.x *= -1
		$raycast_floor_detection.position.x *= -1
		$raycast_wall_detection.target_position *= -1

	move_and_slide()
