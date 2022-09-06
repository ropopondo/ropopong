extends KinematicBody2D

var initial_position
var initial_speed = 300
var speed_increase = 40
var speed = initial_speed

var hit_counter
var direction

signal collided_with_paddle(paddle)

func _ready():
	randomize()
	initial_position = position
	reset()

func reset():
	position = initial_position
	hit_counter = 0
	direction = Vector2()
	
func start():
	var random_x = 0
	if randi()%10 < 5:
		random_x = -1
	else:
		random_x = 1
	
	direction = Vector2(random_x, rand_range(-1, 1)).normalized() * speed

func _physics_process(delta):
	var collision = move_and_collide(direction * delta)
	
	if collision:
		direction = direction.bounce(collision.normal)
		
		if collision.collider.is_in_group("paddles"):
			hit_counter += 1
			$CollidePadel.play()
			
			# Make the padel direction influence the bounce direction.
			var y = direction.y / 2 + collision.collider_velocity.y
			direction = Vector2(direction.x, y).normalized() * (speed + hit_counter * speed_increase)
			
			emit_signal("collided_with_paddle", collision.collider)
		else:
			$CollideWall.play()
