extends CharacterBody2D

var SPEED = 300.0
const JUMP_VELOCITY = -400.0
const KNOCKBACK_FORCE = 500.0
const KNOCKBACK_UP_FORCE = -500.0
var allow_animation = false
var leaved_floor = false
var had_jump = false
var double_jump = false
var count_jumps: int = 0
var max_jumps: int = 2
var ray_cast_dimesion = 23.5
var direction
var stuck_on_wall = false
const dashSpeed = 900
var hearts_list : Array[TextureRect]
var health = 4
var alive = true
var idleCollision
var bendCollsion
var down
var idlePosition
var bendPosition
var bend = false
var attack
var is_attacking = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_invulnerable = false
var is_dashing = false
var dash
var can_dash = true
var get_damage = false
var cfh = true
var is_stunned = false
var is_spike = false
var can_play_walk_1 = true
var can_play_walk_2 = false
var can_play_attack_1 = true
var can_play_attack_2 = false
var can_play_bend_attack = true
var can_play_jump_1 = true
var can_play_jump_2 = true
var can_play_hit = true
var can_play_death = true
var can_play_dash = true
var exited = false
var can_dialogue = true
var escena
var attackZone_position

func _ready():
	$attackZone/CollisionShape2D.disabled = true
	idlePosition = $IdleCollision.position
	bendPosition = $BendCollision.position
	idleCollision = $IdleCollision.shape
	bendCollsion = $BendCollision.shape
	$BendCollision.set_deferred("disabled", "true")
	$animations.play("appear")
	$rayCast_walljump.target_position.x = ray_cast_dimesion
	var hearts_parent = $CanvasLayer/HBoxContainer
	for child in hearts_parent.get_children():
		hearts_list.append(child)
	attackZone_position = $attackZone/CollisionShape2D.position.x

func update_heart_display():
	for i in range (hearts_list.size()):
		hearts_list[i].visible = i < health
		
func _physics_process(delta):
	if $rayCast_walljump.get_collider():
		if $rayCast_walljump.get_collider().is_in_group("spike_group") && is_invulnerable == false:
			health -= 1
			update_heart_display()
			if can_play_hit == true:
				can_play_hit = false
				$audioHit.play()
			is_invulnerable = true
			$invulnerability_timer.start()
			if health <= 0:
				_die()
				return
		
	if not alive:
		velocity.y += gravity * delta
		move_and_slide()
		if is_on_floor():
			velocity = Vector2.ZERO
			set_physics_process(false)
		return
		
	if is_stunned && is_spike == false:
		if can_play_hit == true:
			can_play_hit = false
			$audioHit.play()
		velocity.x = KNOCKBACK_FORCE * -direction
		velocity.y = KNOCKBACK_UP_FORCE
		$animations.play("hit")
		allow_animation = false
		move_and_slide()
		return
		
	if is_on_floor():
		leaved_floor = false
		had_jump = false
		count_jumps = 0

	if not is_on_floor(): #COYOTE TIMER
		if not leaved_floor:
			$Coyote_timer.start()
			leaved_floor = true
		velocity.y += gravity * delta
		
	if Input.is_action_just_pressed("ui_interact") && exited == false:
		DialogueManager.show_dialogue_balloon(load("res://Scenes/Dialogs/Fire_Witch.dialogue"))
		
		
	down = Input.get_action_strength("ui_down") #AGACHARSE
	if down:
		$IdleCollision.shape = bendCollsion
		$IdleCollision.position = bendPosition
		$damage_detection/CollisionShape2D.shape = bendCollsion
		$damage_detection/CollisionShape2D.position = bendPosition
		bend = true
	else:
		$IdleCollision.shape = idleCollision
		$IdleCollision.position = idlePosition
		$damage_detection/CollisionShape2D.shape = idleCollision
		$damage_detection/CollisionShape2D.position = idlePosition
		bend = false
		
	if Input.is_action_just_pressed("ui_dash") and can_dash and direction: #DASH
		is_dashing = true
		can_dash = false
		if is_dashing == true && can_play_dash == true:
			$audioDash.play()
			can_play_dash = false
		$dash_timer.start()
		$can_dash_timer.start()
		velocity.x = direction * dashSpeed
		velocity.y = 0
		$animations.play("dash")
		allow_animation = false
	
	if is_dashing:
		move_and_slide()
		return
	
	attack = Input.is_action_just_pressed("attack") #ATACAR
	if attack:
		is_attacking = true
		if is_attacking:
			$attackZone/CollisionShape2D.disabled = false
		
	if Input.is_action_just_pressed("ui_accept") and right_to_jump(): #SALTAR Y DOBLE SALTO
		if count_jumps == 1:
			double_jump = true
		count_jumps += 1
		if double_jump == false && can_play_jump_1 == true:
			$audioJump.play()
			can_play_jump_1 = false
		velocity.y = JUMP_VELOCITY

	direction = Input.get_axis("ui_left", "ui_right") #MOVERSE HACIA LOS LADOS
	if direction:
		if bend == true:
			velocity.x = direction * (SPEED - 100)
		else:
			velocity.x = direction * SPEED
		if is_on_floor() && can_play_walk_1 == true:
			$audioWalk.play()
			can_play_walk_1 = false
		elif is_on_floor() && can_play_walk_2 == true:
			$audioWalk2.play()
			can_play_walk_2 = false
	else:
		velocity.x = move_toward(velocity.x,0,SPEED)
		
	if $rayCast_Spike.get_collider():
		if $rayCast_Spike.get_collider().is_in_group("void"):
			health -= 4
			update_heart_display()
			if health <= 0:
				_die()
				return
		
	if $rayCast_Spike.get_collider():
		if $rayCast_Spike.get_collider().is_in_group("spike_group") && is_invulnerable == false:
			health -= 1
			update_heart_display()
			$animations.play("hit")
			if can_play_hit == true:
				can_play_hit = false
				$audioHit.play()
			allow_animation = false
			velocity.y = JUMP_VELOCITY
			is_invulnerable = true
			$invulnerability_timer.start()
			if health <= 0:
				_die()
				return
		elif $rayCast_Spike.get_collider().is_in_group("spike_group") && is_invulnerable == true:
			velocity.y = JUMP_VELOCITY 
	move_and_slide()
	if not is_dashing:
		decide_animation()
	
func decide_animation():	
	if direction < 0: #DIRECCIÓN DE LAS ANIMACIONES
		$animations.flip_h = true
		$rayCast_walljump.target_position.x = -ray_cast_dimesion
		$attackZone/CollisionShape2D.position.x = -attackZone_position
	elif direction > 0:
		$animations.flip_h = false
		$rayCast_walljump.target_position.x = ray_cast_dimesion
		$attackZone/CollisionShape2D.position.x = attackZone_position
	
	if $rayCast_walljump.get_collider(): #WALLJUMP
		if $rayCast_walljump.get_collider().is_in_group("wall_jump"):
			if velocity.y >= 0:
				count_jumps = 0
				velocity.y = 0
				stuck_on_wall = true
		else: 
			stuck_on_wall = false
	else:
		stuck_on_wall = false
	
	if bend == true && is_on_floor(): #AGACHARSE ANIMATION
		if attack && is_attacking == true:
			$animations.play("bend_attack")
			allow_animation = false
			if is_attacking == true && can_play_bend_attack == true:
				$bendAttack.play()
				can_play_bend_attack = false
		if velocity.x == 0 && is_attacking == false:
			$animations.play("bend")
			allow_animation = false
		elif velocity.x < 0 || velocity.x > 0:
			if attack && is_attacking == true && is_on_floor():
				$animations.play("bend_attack")
				allow_animation = false
				SPEED = 0.0
				$IdleCollision.shape = bendCollsion
				$IdleCollision.position = bendPosition
				$damage_detection/CollisionShape2D.shape = bendCollsion
				$damage_detection/CollisionShape2D.position = bendPosition
				if is_attacking == true && can_play_bend_attack == true:
					$bendAttack.play()
					can_play_bend_attack = false
			if is_attacking == false:
				$animations.play("bend_walk")
				$IdleCollision.shape = bendCollsion
				$IdleCollision.position = bendPosition
				$damage_detection/CollisionShape2D.shape = bendCollsion
				$damage_detection/CollisionShape2D.position = bendPosition
				allow_animation = false
	else:
		allow_animation = true
	
	if double_jump: #DOBLE SALTO ANIMATION
		double_jump = false
		$animations.play("double_jump")
		allow_animation = false
		if can_play_jump_2 == true:
			$audioJump2.play()
			can_play_attack_2 = false

	if not allow_animation: return
	
	#EJE X
	if stuck_on_wall: #WALLJUMP ANIMATION
		$animations.play("wall_jump")
		if $rayCast_walljump.target_position.x == ray_cast_dimesion:
			$animations.flip_h = true
		else:
			$animations.flip_h = false
	else: 
		if velocity.x == 0:
			#idle
			if attack && is_attacking == true: #ATTACk AND IDLE ANIMATION
				$animations.play("attack")
				allow_animation = false
				if can_play_attack_1 == true && is_attacking == true:
					$audioAttack.play()
					can_play_attack_1 = false
				if can_play_attack_2 == true && is_attacking == true:
					$audioAttack2.play()
					can_play_attack_2 = false
				
			if is_attacking == false:
				$animations.play("idle")
				allow_animation = true
				
		elif velocity.x < 0 || velocity.x > 0: #RUN ANIMATION
			allow_animation = true
			if attack && is_attacking == true && is_on_floor():
				$animations.play("attack_movement")
				allow_animation = false
				SPEED = 0.0
				if can_play_attack_1 == true && is_attacking == true:
					$audioAttack.play()
					can_play_attack_1 = false
				if can_play_attack_2 == true && is_attacking == true:
					$audioAttack2.play()
					can_play_attack_2 = false
				
			if is_attacking == false:
				$animations.play("run")
		#EJE Y
		if velocity.y > 0: #IN AIR ANIMATIONS
			allow_animation = true
			if attack && is_attacking == true && not is_on_floor():
				allow_animation = true
				$animations.play("jump_attack")
				allow_animation = false
				if can_play_attack_1 == true && is_attacking == true:
					can_play_attack_1 = false
			if is_attacking == false:
				$animations.play("jump_down")
				allow_animation = false
		elif velocity.y < 0:
			allow_animation = true
			if attack && is_attacking == true && not is_on_floor():
				$animations.play("jump_attack")
				allow_animation = false
				if can_play_attack_1 == true && is_attacking == true:
					can_play_attack_1 = false
			if is_attacking == false:
				$animations.play("jump_up")
				allow_animation = false
	
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

func _on_damage_detection_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int):
	if is_invulnerable or not alive:
		return
		
	health -= 1
	update_heart_display()
	
	if health <= 0:
		_die()
		return
		
	is_stunned = true
	$stun_timer.start()
	
	is_invulnerable = true
	$invulnerability_timer.start()

func _die():
	alive = false
	$animations.play("death")
	if can_play_death == true:
		$audioDeath.play()
		can_play_death = false
		$deadTimer.start()

func _on_invulnerability_timer_timeout():
	is_invulnerable = false

func _on_dash_timer_timeout():
	is_dashing = false

func _on_can_dash_timer_timeout():
	can_dash = true

func _on_stun_timer_timeout():
	is_stunned = false

func _on_audio_walk_finished():
	can_play_walk_2 = true

func _on_audio_walk_2_finished():
	can_play_walk_1 = true

func _on_audio_attack_finished():
	can_play_attack_2 = true
	
func _on_audio_attack_2_finished():
	can_play_attack_1 = true
	
func _on_animations_animation_finished():
	if is_attacking:
		$attackZone/CollisionShape2D.disabled = true
	is_attacking = false
	SPEED = 300.0
	
func _on_bend_attack_finished():
	can_play_bend_attack = true

func _on_audio_jump_finished():
	can_play_jump_1 = true

func _on_audio_jump_2_finished():
	can_play_jump_2 = true
	
func _on_audio_hit_finished():
	can_play_hit = true

func _on_audio_death_finished():
	can_play_death = true

func _on_audio_dash_finished():
	can_play_dash = true
	
func _on_dialog_detection_area_entered(area: Area2D):
	exited = false

func _on_dialog_detection_area_exited(area: Area2D):
	exited = true

func _on_next_map_area_entered(area: Area2D):
	get_tree().change_scene_to_file("res://Scenes/Screens/SegundaPantalla.tscn")

func _on_dead_timer_timeout():
	get_tree().reload_current_scene()

func _on_next_map_2_area_entered(area: Area2D):
	get_tree().change_scene_to_file("res://Scenes/Screens/TerceraPantalla.tscn")
	
func _on_next_map_3_area_entered(area: Area2D):
	get_tree().change_scene_to_file("res://Scenes/Screens/UltimaPantalla.tscn")

func _on_next_map_4_area_entered(area: Area2D):
	get_tree().change_scene_to_file("res://Scenes/Screens/Final.tscn")
