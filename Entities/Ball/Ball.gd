extends KinematicBody2D

class_name Ball

var explosion_scene = preload("res://Entities/Explosion/Explosion.tscn")

var initial_speed := 300
var speed_increase := 40
var base_speed := initial_speed
var speed setget , get_speed
export var max_speed := 2500

var boost_timer: Timer
var boost_multiplier: float = 1.0

var paddle_multiplier: float = 1.0
var paddle_multiplier_min: float = 1.0
export var paddle_multiplier_max: float = 1.5

var hit_counter: int = 0
var direction: Vector2 = Vector2()

var initial_position := Vector2(512, 344)

signal collided_with_paddle(paddle)


func _ready():
	randomize()


func explode():
	var explosion = explosion_scene.instance()
	explosion.position = position
	explosion.position.x = max(explosion.position.x, 0)
	explosion.position.x = min(explosion.position.x, 1024)
	get_node("/root/Game/Explosions").add_child(explosion)

	queue_free()


func reset():
	position = initial_position
	direction = Vector2()

	hit_counter = 0
	paddle_multiplier = paddle_multiplier_min
	boost_multiplier = 1.0
	if boost_timer:
		boost_timer.queue_free()
		boost_timer = null


func start():
	var random_x := 0
	if randi() % 10 < 5:
		random_x = -1
	else:
		random_x = 1

	direction = Vector2(random_x, rand_range(-1, 1)).normalized() * base_speed


func get_speed():
	var calc_speed = (base_speed + hit_counter * speed_increase) * boost_multiplier
	return min(calc_speed, max_speed)


func boost(multiplier: float) -> void:
	boost_multiplier = multiplier


func _physics_process(delta):
	var collision = move_and_collide(direction * delta)

	if collision:
		direction = direction.bounce(collision.normal)

		if collision.collider.is_in_group("paddles"):
			var paddle: Paddle = collision.collider

			hit_counter += 1
			boost_multiplier = 1.0
			$CollidePaddle.play()

			direction = rotate_direction_based_on_paddle(paddle)
			direction = keep_direction_horizontal(direction)

			emit_signal("collided_with_paddle", paddle)
		elif collision.collider.is_in_group("walls"):
			# Delete wall once the ball hits it.
			collision.collider.queue_free()
		else:
			$CollideWall.play()

	direction = direction.normalized() * get_speed() * paddle_multiplier


func rotate_direction_based_on_paddle(paddle: Paddle) -> Vector2:
	# 1. Add/subtract y-movement based on how far out the ball hits.
	var position_diff: float = position.y - paddle.position.y
	direction.y += position_diff * 5

	# 2. Add/subtract y-movement based on the paddle's movement.
	direction.y += paddle.direction.y

	return direction


func keep_direction_horizontal(original_direction: Vector2) -> Vector2:
	# Direction must have a minimal horizontal movement to keep the game fun.
	var deg_angle = rad2deg(original_direction.angle())
	if deg_angle > 75 and deg_angle <= 90:
		original_direction = original_direction.rotated(-original_direction.angle() + deg2rad(75))
	elif deg_angle < -75 and deg_angle >= -90:
		original_direction = original_direction.rotated(-original_direction.angle() - deg2rad(75))
	elif deg_angle > 90 and deg_angle < 105:
		original_direction = original_direction.rotated(-original_direction.angle() + deg2rad(105))
	elif deg_angle < -90 and deg_angle > -105:
		original_direction = original_direction.rotated(-original_direction.angle() - deg2rad(105))

	return original_direction
