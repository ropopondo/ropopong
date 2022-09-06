extends KinematicBody2D

signal update

# Declare member variables here.
export var move_speed = 250
var direction = Vector2()

func _process(_delta):
	emit_signal("update")

func _physics_process(delta):
	direction = direction.normalized() * move_speed
	
	if direction.length() > 0:
		var _collision = move_and_collide(direction * delta)
