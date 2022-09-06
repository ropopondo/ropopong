extends Node

class_name AiInputComponent

# Declare member variables here.
onready var ball = get_node("/root/Game/Ball")

var paddle


# Called when the node enters the scene tree for the first time.
func _ready():
	paddle = get_parent()
	paddle.connect("update", self, "calculate_velocity")

func calculate_velocity():
	if not "direction" in paddle:
		return
	
	paddle.direction = Vector2(0, get_ball_direction())

func get_ball_direction():
	if abs(paddle.position.y - ball.position.y) > 20:
		if paddle.position.y < ball.position.y:
			return 1
		else:
			return -1
	else:
		return 0
