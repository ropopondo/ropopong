extends KinematicBody2D

class_name Ball

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

export var paddle_rotation_max_deg: float = 40

var hit_counter: int = 0
var direction: Vector2 = Vector2()

var initial_position := Vector2(512, 344)

signal collided_with_paddle(paddle)


func _ready():
	randomize()


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
	var deg_angle = rad2deg(direction.angle())

	if collision:
		direction = direction.bounce(collision.normal)

		if collision.collider.is_in_group("paddles"):
			hit_counter += 1
			boost_multiplier = 1.0
			$CollidePaddle.play()

			var paddle: Paddle = collision.collider
			# 1 is left side, -1 is right side.
			var paddle_side: int = 1
			if paddle.position.x > 512:
				paddle_side = -1

			# Add an angle when hitting the ball with a moving paddle.
			var moving_rotation = (
				paddle_rotation_max_deg
				* (paddle.direction.y / paddle.move_speed)
				* 0.4
				* paddle_side
			)
			# Within limits so ball doesn't freak along the paddle.
			if deg_angle > 0 and deg_angle <= 90:
				moving_rotation = min(moving_rotation, 75 - deg_angle)
			elif deg_angle < 0 and deg_angle >= -90:
				moving_rotation = max(moving_rotation, -75 - deg_angle)
			elif deg_angle > 90 and deg_angle < 180:
				moving_rotation = min(moving_rotation, 105 - deg_angle)
			elif deg_angle < -90 and deg_angle > -180:
				moving_rotation = max(moving_rotation, -105 - deg_angle)
			direction = direction.rotated(deg2rad(moving_rotation))

			# Give a speed boost when hitting the ball further out.
			# Interpolate linearly from center to edge.
			var diff_to_center: float = position.y - paddle.position.y
			var multiplier: float = abs(diff_to_center) / (paddle.height / 2)
			paddle_multiplier = (
				paddle_multiplier_min
				+ (paddle_multiplier_max - paddle_multiplier_min) * multiplier
			)

			# Add an angle when hitting the ball further out.
			# The check makes sure we are not on an upper or lower edge of the paddle.
			# It ensures that the ball direction is away from the paddle, as we
			# already applied the bounce.
			if (paddle_side > 0 and direction.x > 0) or (paddle_side < 0 and direction.x < 0):
				deg_angle = rad2deg(direction.angle())
				var rotation = (
					paddle_rotation_max_deg
					* (diff_to_center / (paddle.height / 2))
					* paddle_side
				)
				# Within limits so ball doesn't freak along the paddle.
				if deg_angle > 0 and deg_angle <= 90:
					rotation = min(rotation, 75 - deg_angle)
				elif deg_angle < 0 and deg_angle >= -90:
					rotation = max(rotation, -75 - deg_angle)
				elif deg_angle > 90 and deg_angle < 180:
					rotation = min(rotation, 105 - deg_angle)
				elif deg_angle < -90 and deg_angle > -180:
					rotation = max(rotation, -105 - deg_angle)

				direction = direction.rotated(deg2rad(rotation))

			emit_signal("collided_with_paddle", paddle)
		elif collision.collider.is_in_group("walls"):
			# Delete wall once the ball hits it.
			collision.collider.queue_free()
		else:
			$CollideWall.play()

	# Direction must have a minimal horizontal movement to keep the game fun.
	deg_angle = rad2deg(direction.angle())
	if deg_angle > 75 and deg_angle <= 90:
		direction = direction.rotated(-direction.angle() + deg2rad(75))
	elif deg_angle < -75 and deg_angle >= -90:
		direction = direction.rotated(-(direction.angle() + deg2rad(75)))
	elif deg_angle > 90 and deg_angle < 105:
		direction = direction.rotated(-direction.angle() + deg2rad(105))
	elif deg_angle < -90 and deg_angle > -105:
		direction = direction.rotated(-direction.angle() - deg2rad(105))

	direction = direction.normalized() * get_speed() * paddle_multiplier
