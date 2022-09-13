extends Node

class_name AiInputComponent

var paddle


# Called when the node enters the scene tree for the first time.
func _ready():
	paddle = get_parent()
	paddle.connect("update", self, "calculate_velocity")


func get_closest_ball() -> Ball:
	var all_balls: Array = (get_node("/root/Game/Balls") as Node).get_children()
	if all_balls.empty():
		return null

	var closest_ball = all_balls.front()
	var distance_to_closest_ball = closest_ball.position.distance_to(paddle.position)

	for ball in all_balls:
		var distance_to_ball = ball.position.distance_to(paddle.position)
		if distance_to_ball < distance_to_closest_ball:
			closest_ball = ball
			distance_to_closest_ball = distance_to_ball

	return closest_ball


func calculate_velocity():
	if not "direction" in paddle:
		return

	paddle.direction = Vector2(0, get_ball_direction())


func get_ball_direction():
	var ball = get_closest_ball()
	if ball and abs(paddle.position.y - ball.position.y) > 20:
		if paddle.position.y < ball.position.y:
			return paddle.move_speed
		else:
			return -paddle.move_speed
	else:
		return 0
