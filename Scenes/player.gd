extends CharacterBody2D

signal projectile_spawn()
signal projectile_parameters(pos, char_direction)
signal char_facing_left(dir : bool)

const SPEED = 500.0
const JUMP_VELOCITY = -400.0

@export var projectile_cooldown : float #cooldown timer for firing projectiles in seconds
@export var max_air_jumps : int #double jumps, or more if desired
var air_jumps_left = max_air_jumps #var that actually gets used by processes

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	elif is_on_floor() and air_jumps_left != max_air_jumps: #replenish double jump when on ground
		air_jumps_left = max_air_jumps
	

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("Jump") and air_jumps_left != 0: #double jump or more
		velocity.y = JUMP_VELOCITY
		air_jumps_left -= 1

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

func _input(_event):
	#Fire projectile on enter key if cooldown timer is NOT active
	if Input.is_action_just_pressed("Fire") and ($ProjectileCooldownTimer.is_stopped()):
		#Need both signals, otherwise projectile spawns after signal is finished emitting and misses attached parameters
		projectile_spawn.emit()
		projectile_parameters.emit($ProjectileStartPos.global_position, $Sprite2D.flip_h)
		$ProjectileCooldownTimer.start(projectile_cooldown) #starts cooldown with said amount of time
	
	#sends signal for which direction character is facing
	if Input.is_action_just_pressed("Right"):
		char_facing_left.emit(false) #FIXME: I'm still not sure if it's better to make signals or directely run functions if it's within the same script
	elif Input.is_action_just_pressed("Left"):
		char_facing_left.emit(true)

func _on_char_facing_left(face_left): #flips nodes to face proper direction when receives input
	if face_left == false:
		$Sprite2D.flip_h = false
		$CollisionPolygon2D.scale.x = 1
		if $ProjectileStartPos.position.x < 0: #FIXME: is there an easier way to do this?
			$ProjectileStartPos.position.x *= -1
	elif face_left == true:
		$Sprite2D.flip_h = true
		$CollisionPolygon2D.scale.x = -1
		if $ProjectileStartPos.position.x > 0: #FIXME: is there an easier way to do this?
			$ProjectileStartPos.position.x *= -1






#FIXME: player HP and hit event
