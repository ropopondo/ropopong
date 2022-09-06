extends Node2D


var paddle_scene = preload("res://Entities/Paddle/Paddle.tscn")

export (String) var main_menu_scene_path

var score_left = 0
var score_right = 0

export var max_score = 3

var paddle_left
var paddle_right
var initial_position_padel_left
var initial_position_padel_right

onready var hud = get_node("HUD")


func _ready():
	add_paddles()
	initial_position_padel_left = paddle_left.position
	initial_position_padel_right = paddle_right.position
	new_game()


func add_paddles():
	paddle_left = paddle_scene.instance()
	paddle_right = paddle_scene.instance()
	
	paddle_left.position = Vector2(40, 344)
	paddle_right.position = Vector2(984, 344)
	
	var left_input = PlayerInputComponent.new()
	left_input.set_side(PlayerInputComponent.Side.LEFT)
	paddle_left.add_child(left_input)
	
	var right_input
	if Global.game_mode == Global.GameMode.VersusEasyAi:
		right_input = AiInputComponent.new()
	elif Global.game_mode == Global.GameMode.VersusHardAi:
		right_input = AiHardInputComponent.new()
	elif Global.game_mode == Global.GameMode.VersusPlayer:
		right_input = PlayerInputComponent.new()
		right_input.set_side(PlayerInputComponent.Side.RIGHT)
	else:
		printerr("INVALID GAME MODE")
	paddle_right.add_child(right_input)
	
	self.add_child(paddle_left)
	self.add_child(paddle_right)


func new_game():
	score_left = 0
	score_right = 0
	update_score()
	reset()


func _process(_delta):
	hud.get_node("CountDownContainer/CenterContainer/CountDown").set_text(str(ceil($StartTimer.time_left)))


func reset():
	$Ball.reset()
	paddle_left.position = initial_position_padel_left
	paddle_right.position = initial_position_padel_right
	$StartTimer.start()
	hud.get_node("CountDownContainer").set_visible(true)
	$FinalScreen.set_visible(false)


func update_score():
	hud.get_node("Points/PointsLeft").set_text(str(score_left))
	hud.get_node("Points/PointsRight").set_text(str(score_right))


func end_game(message):
	$FinalScreen.get_node("PanelContainer/VBoxContainer/EndMessage").set_text(message)
	$FinalScreen.set_visible(true)


func _on_Field_goal_left():
	score_right += 1
	update_score()
	if score_right < max_score:
		reset()
	else:
		end_game("Right wins")


func _on_Field_goal_right():
	score_left += 1
	update_score()
	if score_left < max_score:
		reset()
	else:
		end_game("Left wins")


func _on_StartTimer_timeout():
	hud.get_node("CountDownContainer").set_visible(false)
	$Ball.start()


func _on_FinalScreen_end():
	var _error = get_tree().change_scene(main_menu_scene_path)


func _on_FinalScreen_play():
	new_game()
