extends KinematicBody2D


class_name Ball


var initial_speed := 300
var speed_increase := 40
var base_speed := initial_speed
var speed setget ,get_speed

var boost_timer: Timer
var boost_multiplier: float = 1.0

var hit_counter: int = 0
var direction: Vector2 = Vector2()

onready var initial_position := position

signal collided_with_paddle(paddle)


func _ready():
	randomize()


func reset():
	position = initial_position
	hit_counter = 0
	direction = Vector2()
	boost_multiplier = 1.0
	if boost_timer:
		boost_timer.queue_free()
		boost_timer = null


func start():
	var random_x := 0
	if randi()%10 < 5:
		random_x = -1
	else:
		random_x = 1
	
	direction = Vector2(random_x, rand_range(-1, 1)).normalized() * base_speed


func get_speed():
	return (base_speed + hit_counter * speed_increase) * boost_multiplier


func boost(multiplier: float, time_in_seconds: float) -> void:
	boost_multiplier = multiplier

	boost_timer = Timer.new()
	boost_timer.one_shot = true
	var _error := boost_timer.connect("timeout", self, "_on_boost_timer_ended")
	
	add_child(boost_timer)
	boost_timer.start(time_in_seconds)


func _physics_process(delta):
	var collision = move_and_collide(direction * delta)
	var y: float = direction.y
	
	if collision:
		direction = direction.bounce(collision.normal)
		y = direction.y
		
		if collision.collider.is_in_group("paddles"):
			hit_counter += 1
			$CollidePaddle.play()
			
			# Make the padel direction influence the bounce direction.
			y = direction.y / 2 + collision.collider_velocity.y
			
			emit_signal("collided_with_paddle", collision.collider)
		elif collision.collider.is_in_group("walls"):
			# Delete wall once the ball hits it.
			collision.collider.queue_free()
		else:
			$CollideWall.play()
	
	direction = Vector2(direction.x, y).normalized() * get_speed()


func _on_boost_timer_ended() -> void:
	boost_timer.queue_free()
	boost_timer = null
	boost_multiplier = 1.0
