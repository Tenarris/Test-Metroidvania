extends Area2D

@export var speed : int = 2000   #in...frames?
@export var duration : float = 0.5 #in seconds

# Called when the node enters the scene tree for the first time.
func _ready():
	var player_node = get_node('../../Player') #FIXME: I'm pretty sure this is a bad use for signals, but I don't understand them enough to fix it yet
	player_node.projectile_parameters.connect(projectile_direction, 4)
	$DurationTimer.start(duration)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#projectile speed in given direction
	if $Sprite2D.flip_h == false:
		position.x += speed * delta
	elif $Sprite2D.flip_h == true:
		position.x -= speed * delta

func projectile_direction(pos, char_direction):
	#Determines which direction sprite faces on instance spawn, from player signal
	position = pos
	if char_direction == false:
		$Sprite2D.flip_h = false
	elif char_direction == true:
		$Sprite2D.flip_h = true






func _on_body_entered(body):
	if body.get_collision_layer() == 4: #get_collision_layer output is binaryaa. Output 4 is the enemy layer
		print('Collision Detected')
		body.hit()
		_on_timer_timeout()
	else: #only other collision would be walls. Ideally I'd play a animation here, but that's too much work right now
		print('hit wall')
		_on_timer_timeout()#FIXME: I think it's moving too fast for this to work. And I'm moving the projectile with position, not velocity becuase it's an Area2D

func _on_timer_timeout():
	#deletes projectile after x time
	queue_free()
