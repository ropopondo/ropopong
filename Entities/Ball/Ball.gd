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

onready var initial_position := position

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


func boost(multiplier: float, time_in_seconds: float) -> void:
	boost_multiplier = multiplier

	boost_timer = Timer.new()
	boost_timer.one_shot = true
	var _error := boost_timer.connect("timeout", self, "_on_boost_timer_ended")

	add_child(boost_timer)
	boost_timer.start(time_in_seconds)


func _physics_process(delta):
	var collision = move_and_collide(direction * delta)

	if collision:
		direction = direction.bounce(collision.normal)

		if collision.collider.is_in_group("paddles"):
			hit_counter += 1
			$CollidePaddle.play()

			var paddle: Paddle = collision.collider
			# 1 is left side, -1 is right side.
			var paddle_side: int = 1
			if paddle.position.x > 512:
				paddle_side = -1

			# Add an angle when hitting the ball with a moving paddle.
			direction = direction.rotated(
				deg2rad(paddle_rotation_max_deg * paddle.direction.y * 0.3 * paddle_side)
			)

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
				direction = direction.rotated(
					deg2rad(
						(
							paddle_rotation_max_deg
							* (diff_to_center / (paddle.height / 2))
							* paddle_side
						)
					)
				)

			emit_signal("collided_with_paddle", paddle)
		elif collision.collider.is_in_group("walls"):
			# Delete wall once the ball hits it.
			collision.collider.queue_free()
		else:
			$CollideWall.play()

	# Direction must have a minimal horizontal movement to keep the game fun.
	var deg_angle = rad2deg(direction.angle())
	if deg_angle > 75 and deg_angle <= 90:
		direction = direction.rotated(-direction.angle() + deg2rad(75))
	elif deg_angle < -75 and deg_angle >= -90:
		direction = direction.rotated(-(direction.angle() + deg2rad(75)))
	elif deg_angle > 90 and deg_angle < 105:
		direction = direction.rotated(-direction.angle() + deg2rad(105))
	elif deg_angle < -90 and deg_angle > -105:
		direction = direction.rotated(-direction.angle() - deg2rad(105))

	direction = direction.normalized() * get_speed() * paddle_multiplier


func _on_boost_timer_ended() -> void:
	boost_timer.queue_free()
	boost_timer = null
	boost_multiplier = 1.0
