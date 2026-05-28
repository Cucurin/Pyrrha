extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var allow_animation = false
var leaved_floor = false
var had_jump = false
var double_jump = false
var count_jumps: int = 0
var max_jumps: int = 2
var ray_cast_dimesion = 23.5
var direction
var stuck_on_wall = false
var health = 100
var timer = Timer
const dashSpeed = 900
const dashLength = .1

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$animations.play("appear")
	$rayCast_walljump.target_position.x = ray_cast_dimesion
	
func _physics_process(delta):
	
	if is_on_floor():
		leaved_floor = false
		had_jump = false
		count_jumps = 0

	if not is_on_floor():
		if not leaved_floor:
			$Coyote_timer.start()
			leaved_floor = true
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("ui_accept") and right_to_jump():
		if count_jumps == 1:
			double_jump = true
		count_jumps += 1
		velocity.y = JUMP_VELOCITY

	direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x,0,SPEED)

	move_and_slide()
	decide_animation()
	
func decide_animation():
	if direction < 0:
		$animations.flip_h = true
		$rayCast_walljump.target_position.x = -ray_cast_dimesion
	elif direction > 0:
		$animations.flip_h = false
		$rayCast_walljump.target_position.x = ray_cast_dimesion
	
	if $rayCast_walljump.get_collider():
		if $rayCast_walljump.get_collider().is_in_group("wall_jump"):
			if velocity.y > 0:
				count_jumps = 0
				velocity.y = 0
				stuck_on_wall = true
		else:
			stuck_on_wall = false
	else: stuck_on_wall = false

	if double_jump:
		double_jump = false
		allow_animation = false
		$animations.play("double_jump")
		
	if not allow_animation: return
	#EJE X
	if stuck_on_wall:
		$animations.play("wall_jump")
		if $animations.flip_h == true:
			$animations.flip_h = false
		else:
			$animations.flip_h = true
	else:
		if velocity.x == 0:
			#idle
			$animations.play("idle")
		elif velocity.x < 0:
			#izquierda
			$animations.play("run")
		elif velocity.x > 0:
			#derecha
			$animations.play("run")
			
		#EJE Y
		if velocity.y > 0:
			$animations.play("jump_down")
		elif velocity.y < 0:
			$animations.play("jump_up")

func right_to_jump():
	if had_jump:
		if count_jumps < max_jumps: 
			return true
		else: return false
	if (is_on_floor() || stuck_on_wall):
		had_jump = true
		return true
	elif not $Coyote_timer.is_stopped(): 
		had_jump = true
		return true

func _on_animations_animation_finished():
		allow_animation = true


func _on_damage_detection_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
	health -= 10
	print(health)
