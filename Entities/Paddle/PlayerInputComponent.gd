extends Node

class_name PlayerInputComponent

# Declare member variables here.
var paddle: Paddle

enum Side {
	LEFT,
	RIGHT,
}

var up_action
var down_action


# Called when the node enters the scene tree for the first time.
func _ready():
	paddle = get_parent()


func set_side(side):
	if side == Side.LEFT:
		up_action = "game_left_up"
		down_action = "game_left_down"
	else:
		up_action = "game_right_up"
		down_action = "game_right_down"


func _unhandled_key_input(_event):
	if not "direction" in paddle:
		return

	if Input.is_action_just_pressed(up_action):
		paddle.direction = Vector2.UP
		get_tree().set_input_as_handled()
	if Input.is_action_just_pressed(down_action):
		paddle.direction = Vector2.DOWN
		get_tree().set_input_as_handled()

	if Input.is_action_just_released(up_action) or Input.is_action_just_released(down_action):
		paddle.direction = Vector2()
		get_tree().set_input_as_handled()
