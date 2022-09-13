extends Node2D

export(String) var main_menu_scene_path
export var game_time := 60

var ball_scene = preload("res://Entities/Ball/Ball.tscn")
var paddle_scene = preload("res://Entities/Paddle/Paddle.tscn")
var powerup_scene = preload("res://Entities/Powerup/Powerup.tscn")
var wall_scene = preload("res://Entities/Wall/Wall.tscn")

var score_left = 0
var score_right = 0

var paddle_left: Paddle
var paddle_right: Paddle

var last_hit_paddle: Paddle

var ball: Ball

var game_ended: bool = false

onready var hud: Control = get_node("HUD")
onready var paddles: Node = get_node("Paddles")


func _ready():
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


func add_ball():
	ball = ball_scene.instance()
	var _error := ball.connect("collided_with_paddle", self, "_on_Ball_collided_with_paddle")
	get_node("/root/Game/Balls").call_deferred("add_child", ball)


func remove_paddles():
	if paddle_left:
		paddles.call_deferred("remove_child", paddle_left)
		paddle_left = null
	if paddle_right:
		paddles.call_deferred("remove_child", paddle_right)
		paddle_right = null
	last_hit_paddle = null


func remove_balls():
	var all_balls: Array = (get_node("/root/Game/Balls") as Node).get_children()
	for old_ball in all_balls:
		old_ball.queue_free()
	ball = null


func new_game():
	score_left = 0
	score_right = 0
	update_score()
	reset_game_timer()
	reset()
	get_tree().paused = false


func _process(_delta):
	hud.get_node("CountDownContainer/CenterContainer/CountDown").set_text(
		str(ceil($StartTimer.time_left))
	)
	hud.get_node("MarginContainer/Top/Timer").set_text(str(ceil($GameTimer.time_left)))

	remove_balls_out_of_bounds()
	maybe_reset()

	if $GameTimer.time_left == 0 and score_left != score_right and not game_ended:
		game_ended = true
		if score_left > score_right:
			end_game("Left wins!")
		else:
			end_game("Right wins!")


func maybe_reset() -> void:
	var all_balls: Array = (get_node("/root/Game/Balls") as Node).get_children()
	if all_balls.empty():
		reset()


func reset():
	game_ended = false
	remove_balls()
	add_ball()
	ball.reset()
	$StartTimer.start()
	hud.get_node("CountDownContainer").set_visible(true)
	$FinalScreen.set_visible(false)
	remove_paddles()
	add_paddles()

	for powerup in get_tree().get_nodes_in_group("powerups"):
		powerup.queue_free()


func update_score():
	hud.get_node("MarginContainer/Top/PointsLeft").set_text(str(score_left))
	hud.get_node("MarginContainer/Top/PointsRight").set_text(str(score_right))


func remove_balls_out_of_bounds():
	var all_balls: Array = (get_node("/root/Game/Balls") as Node).get_children()
	for old_ball in all_balls:
		if old_ball.position.x < -10 or old_ball.position.x > 1034:
			old_ball.queue_free()


func reset_game_timer() -> void:
	$GameTimer.start(game_time)


func end_game(message):
	remove_paddles()
	remove_balls()
	get_tree().paused = true
	$FinalScreen.get_node("PanelContainer/VBoxContainer/VBoxContainer/EndMessage").set_text(message)
	$FinalScreen.set_visible(true)


func _unhandled_key_input(_event):
	if Input.is_action_just_pressed("game_pause"):
		get_tree().paused = true
		get_tree().set_input_as_handled()
		$Pause.visible = true


func _on_Field_goal_left():
	score_right += 1
	update_score()


func _on_Field_goal_right():
	score_left += 1
	update_score()


func _on_StartTimer_timeout():
	hud.get_node("CountDownContainer").set_visible(false)
	ball.start()


func _on_FinalScreen_end():
	get_tree().paused = false
	var _error = get_tree().change_scene(main_menu_scene_path)


func _on_FinalScreen_play():
	new_game()

func _on_Pause_play():
	$Pause.visible = false
	get_tree().paused = false

func _on_Pause_end():
	get_tree().paused = false
	var _error = get_tree().change_scene(main_menu_scene_path)

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
		var wall_width: int = (
			(wall.get_node("CollisionShape2D") as CollisionShape2D).shape.extents.x
			* 2
		)
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
		var _error := new_ball.connect(
			"collided_with_paddle", self, "_on_Ball_collided_with_paddle"
		)

		get_node("/root/Game/Balls").call_deferred("add_child", new_ball)
