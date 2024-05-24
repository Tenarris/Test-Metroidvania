extends CharacterBody2D

@export var HP : int
@export var iframes : float #currently multiplied by 6, until I figure out a better way
@export var speed : float
@export var projectile_cooldown : float #cooldown timer for firing projectiles in seconds

@onready var tex_patrol = load("res://Assets/enemy_patrol.png")
@onready var tex_detect = load("res://Assets/enemy_detect.png")
@onready var move_timer = get_node("MovementTimer")

signal enemy_projectile_spawn()
signal enemy_projectile_parameters(spawn_pos : Vector2, target_pos: Vector2)

var player_target = null
var detection_state = 0
	# 0: no detection
	# 1: player detected
	# 2: start initial movement
	#-1: ready to return once player leaves detection range
	#-2: start return movement
var return_coords = Vector2.ZERO
var spawn_coords = Vector2.ZERO
var patrol_move_left := false


func _ready():
	$Sprite2D.set_texture(tex_patrol)
	spawn_coords = position

func _process(delta):
	if player_target and move_timer.is_stopped():
		if detection_state > 0: #initial detection movement
			initial_y_movement()
		elif detection_state < 0: #regular movement after detection
			detection_movement()
	
	 #returns to detection position. detection_state == 2 is error handling
	elif (detection_state < 0 or detection_state == 2) and move_timer.is_stopped():
		return_to_patrol()
	elif move_timer.is_stopped(): #normal movement
		patrol_movement(delta)
		
	move_and_slide()





#movement functions
func initial_y_movement():
	if detection_state == 1:
		move_timer.start(0.85)
		velocity = Vector2.ZERO
		if return_coords == Vector2.ZERO: #so return_coords doesn't get overwritten before it's made it back
			return_coords = position
		$Sprite2D.set_texture(tex_detect) #changes sprite to detection sprite
		detection_state = 2
		
	elif detection_state == 2:
		#moves angled up or down towards player
		#moves to a point 120px above player. Stops 150px +/- player x position
		if (position.x < player_target.position.x - 150) or (position.x > player_target.position.x + 150):
			velocity = position.direction_to(player_target.position - Vector2(0, 120)) * (speed * 5)
		else:
			move_timer.start(0.5)
			velocity = Vector2.ZERO
			detection_state = -1

func detection_movement():
	#if enemy x position is left of point 150px left of player's x position, goes right towards player x position
	if position.x < player_target.position.x - 150:
		velocity.x = speed
	#if enemy x position is right of point 150px right of player's x position, goes left towards player x position
	elif position.x > player_target.position.x + 150:
		velocity.x = -speed
	else: #otherwise stop x velocity within given range
		velocity.x = 0
	
	if $EnemyProjectileTimer.is_stopped():
		fire_at_player() #this is the state that the enemy should be attacking

func return_to_patrol():
	if detection_state == -1 or detection_state == 2: #when player exits detection range and ready to return
		move_timer.start(0.5)
		velocity = Vector2.ZERO
		detection_state = -2
		$Sprite2D.set_texture(tex_patrol) #changes sprite back to patrol
		
	elif detection_state == -2:
		#returns to 10px box around previous position
		if not (position >= return_coords - Vector2(10, 10)) or not (position <= return_coords + Vector2(10, 10)):
			velocity = position.direction_to(return_coords) * speed
		else: #finished return movement
			return_coords = Vector2.ZERO
			detection_state = 0

func patrol_movement(delta):
	var gravity = 60.0
	
	#x velocity
	if position.x > spawn_coords.x + 300:
		patrol_move_left = true
	elif position.x < spawn_coords.x - 300:
		patrol_move_left = false
	
	if patrol_move_left:
		velocity.x -= speed * delta
		if velocity.x < -speed:
			velocity.x = -speed
	else:
		velocity.x += speed * delta
		if velocity.x > speed:
			velocity.x = speed
	
	
	#y velocity moves in a wave
	if position.y > spawn_coords.y + (gravity / 3):
		velocity.y -= gravity * delta
	else:
		velocity.y += gravity * delta

func _on_detection_range_body_entered(body):
	detection_state = 1 #collision layers are set so the area2D DetectionRange can only see players
	player_target = body

func _on_detection_range_body_exited(_body):
	player_target = null






#combat functions
#FIXME: random spawns
func fire_at_player():	
	#Need both signals, otherwise projectile spawns after signal is finished emitting and misses attached parameters
	enemy_projectile_spawn.emit()
	$EnemyProjectileTimer.start(projectile_cooldown) #starts cooldown with said amount of time
	enemy_projectile_parameters.emit(global_position, player_target.position)

func hit(): #FIXME: figure out a way to code a knockback effect on the enemy when hit? Transfer momentum of projectile to enemy velocity?
	if HP > 1 and not $CollisionShape2D.is_disabled(): #FIXME: not sure this is a good way to process hits
		HP -= 1
		print('Enemy Hit! HP left: ', HP)
		on_hit_iframes(iframes)
	elif HP <= 1 and not $CollisionShape2D.is_disabled():
		print('Enemy killed!')
		queue_free()

func on_hit_iframes(seconds):    #FIXME: there has to be a better, more elegant way to do iframes than this
	$CollisionShape2D.set_deferred("Disabled", true)#FIXME: it doesn't like using '.set_disabled" and tells me to do this,
	$Sprite2D.visible = false                            #  but '.set_deferred' doesn't work
	await get_tree().create_timer(seconds).timeout
	$Sprite2D.visible = true
	await get_tree().create_timer(seconds).timeout
	$Sprite2D.visible = false
	await get_tree().create_timer(seconds).timeout
	$Sprite2D.visible = true
	await get_tree().create_timer(seconds).timeout
	$Sprite2D.visible = false
	await get_tree().create_timer(seconds).timeout
	$Sprite2D.visible = true
	$CollisionShape2D.set_deferred("Disabled", false)
