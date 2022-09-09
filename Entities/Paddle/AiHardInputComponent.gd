extends Node

class_name AiHardInputComponent

# Declare member variables here.
onready var ball = get_node("/root/Game/Balls/Ball")

var paddle

# The border above the playing field on screen.
var top_border = 88
onready var viewport_width = get_viewport().size.x
onready var viewport_height = get_viewport().size.y


# Called when the node enters the scene tree for the first time.
func _ready():
	paddle = get_parent()
	paddle.connect("update", self, "calculate_velocity")


func calculate_velocity():
	if not "direction" in paddle:
		return

	if is_ball_moving_away():
		move_towards_center()
	else:
		move_towards_predicted_ball()


func is_ball_moving_away():
	if ball.direction.x < 0:
		return true

	return false


func move_towards_center():
	var direction
	if paddle.position.y > 344 + 2:
		direction = -1
	elif paddle.position.y < 344 - 2:
		direction = 1
	else:
		direction = 0

	paddle.direction = Vector2(0, direction)


func move_towards_predicted_ball():
	var target_y = predict_ball_at_paddle()
	var direction
	if paddle.position.y > target_y + 2:
		direction = -1
	elif paddle.position.y < target_y - 2:
		direction = 1
	else:
		direction = 0

	paddle.direction = Vector2(0, direction)


# Simple trigonometrical prediction.
func predict_ball_at_paddle():
	if ball.direction.y == 0:
		return top_border + (viewport_height - top_border) / 2

	var horizontal_distance = viewport_width - ball.position.x
	var movement_angle = acos(Vector2(1, 0).dot(ball.direction.normalized()))
	var expected_vertical_movement = horizontal_distance * tan(movement_angle)
	var expected_vertical_position = expected_vertical_movement + ball.position.y

	if expected_vertical_position < top_border:
		expected_vertical_position = top_border + (top_border - expected_vertical_position)
	elif expected_vertical_position > viewport_height:
		expected_vertical_position = (
			viewport_height
			- (expected_vertical_position - viewport_height)
		)

	return expected_vertical_position
