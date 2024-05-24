extends Area2D

@export var speed : int   #in...frames?
@export var duration : float #in seconds



# Called when the node enters the scene tree for the first time.
func _ready():
	var enemy_node = get_node('../../Enemy') #FIXME: this is a HORRIBLE way of doing this, but I don't understand connecting signals
	enemy_node.enemy_projectile_parameters.connect(spawn_lock_on, 4)
	$DurationTimer.start(duration)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#transform is a 2d version of basis, which is...complicated
	#basically I rotate the projectile in spawn_lock_on, and then tell the it to move forward in whatever direction it's facing
	position += transform.x * speed * delta






func spawn_lock_on(spawn_pos : Vector2, target_pos: Vector2):
	position = spawn_pos
	look_at(target_pos)

func _on_body_entered(body):
	if body.get_collision_layer() == 2: #if hit player
		print('hit player')
		_on_duration_timer_timeout()
	else: #only other collision are walls. Ideally I'd play a animation here, but that's too much work right now
		print('hit wall')
		_on_duration_timer_timeout()

func _on_duration_timer_timeout():
	queue_free()
