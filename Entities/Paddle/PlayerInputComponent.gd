extends Node

class_name PlayerInputComponent

# Declare member variables here.
var player

enum Side {
	LEFT,
	RIGHT,
}

var up_action
var down_action


# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent()
	player.connect("update", self, "handle_input")


func set_side(side):
	if side == Side.LEFT:
		up_action = "game_left_up"
		down_action = "game_left_down"
	else:
		up_action = "game_right_up"
		down_action = "game_right_down"


func handle_input():
	if not "direction" in player:
		return

	player.direction = Vector2()

	if Input.is_action_pressed(up_action):
		player.direction.y -= 1
	if Input.is_action_pressed(down_action):
		player.direction.y += 1
