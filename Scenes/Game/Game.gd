extends Node2D


var ball_scene = preload("res://Entities/Ball/Ball.tscn")
var paddle_scene = preload("res://Entities/Paddle/Paddle.tscn")
var powerup_scene = preload("res://Entities/Powerup/Powerup.tscn")
var wall_scene = preload("res://Entities/Wall/Wall.tscn")

export (String) var main_menu_scene_path

var score_left = 0
var score_right = 0

export var max_score = 3

var paddle_left: Paddle
var paddle_right: Paddle

var last_hit_paddle: Paddle

onready var hud: Control = get_node("HUD")
var ball: Ball
onready var paddles: Node = get_node("Paddles")

var additional_balls: Array


func _ready():
	ball = get_node("Balls/Ball")
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
		# Default to hard AI for testing purposes.
		right_input = AiHardInputComponent.new()
	paddle_right.add_child(right_input)
	paddles.call_deferred("add_child", paddle_left)
	paddles.call_deferred("add_child", paddle_right)


func remove_paddles():
	if paddle_left:
		paddles.call_deferred("remove_child", paddle_left)
	if paddle_right:
		paddles.call_deferred("remove_child", paddle_right)
	last_hit_paddle = null


func new_game():
	score_left = 0
	score_right = 0
	update_score()
	reset()


func _process(_delta):
	hud.get_node("CountDownContainer/CenterContainer/CountDown").set_text(str(ceil($StartTimer.time_left)))


func reset():
	ball.reset()
	$StartTimer.start()
	hud.get_node("CountDownContainer").set_visible(true)
	$FinalScreen.set_visible(false)
	remove_paddles()
	add_paddles()
	
	for powerup in get_tree().get_nodes_in_group("powerups"):
		powerup.queue_free()
	
	for additional_ball in additional_balls:
		additional_ball.queue_free()
	additional_balls.clear()


func update_score():
	hud.get_node("Points/PointsLeft").set_text(str(score_left))
	hud.get_node("Points/PointsRight").set_text(str(score_right))


func end_game(message):
	$FinalScreen.get_node("PanelContainer/VBoxContainer/EndMessage").set_text(message)
	$FinalScreen.set_visible(true)


func _on_Field_goal_left():
	score_right += 1
	update_score()
	reset()
	if score_right >= max_score:
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
	ball.start()


func _on_FinalScreen_end():
	var _error = get_tree().change_scene(main_menu_scene_path)


func _on_FinalScreen_play():
	new_game()


func _on_PowerupTimer_timeout():
	var powerup: Powerup = powerup_scene.instance()
	powerup.position = Vector2(rand_range(100, 1024 - 100), rand_range(88 + 50, 600 - 50))
	var _error := powerup.connect("powerup_collected", self, "_on_powerup_collected")
	self.add_child(powerup)


func _on_powerup_collected(powerup: Powerup):
	if powerup.type == powerup.Type.BlockUntilHit:
		create_wall()
	elif powerup.type == powerup.Type.AddBalls:
		add_balls()
	
	powerup.collect(last_hit_paddle)


func _on_Ball_collided_with_paddle(paddle: Paddle):
	last_hit_paddle = paddle


func create_wall() -> void:
	var wall := wall_scene.instance() as Wall
	var x: int
	if last_hit_paddle == paddle_left:
		x = 0
	else:
		var wall_width: int = (wall.get_node("CollisionShape2D") as CollisionShape2D).shape.extents.x * 2
		x = 1024 - wall_width
	wall.position = Vector2(x, 88)
	call_deferred("add_child", wall)


func add_balls() -> void:
	for i in range(1, 4):
		var new_ball: Ball = ball_scene.instance()
		new_ball.position = ball.position
		new_ball.position -= ball.direction.normalized() * 20 * i
		new_ball.hit_counter = ball.hit_counter
		var rotation := deg2rad(i * 10)
		if i % 2 == 0:
			rotation *= -1
		new_ball.direction = ball.direction.rotated(rotation)
		var _error := new_ball.connect("collided_with_paddle", self, "_on_Ball_collided_with_paddle")
		
		additional_balls.push_back(new_ball)
		
		call_deferred("add_child_below_node", $Balls, new_ball)
