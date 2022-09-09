extends KinematicBody2D

class_name Paddle

signal update

# Declare member variables here.
export var move_speed := 250
export var max_height := 400
var direction := Vector2()
var height: float

var top_border := 88
var viewport_height := 600


func _ready():
	call_deferred("create_unique_shape")


func create_unique_shape() -> void:
	# Create each their own shape so that they can grow independently
	var shape := RectangleShape2D.new()
	shape.extents = $CollisionShape2D.get_shape().extents
	$CollisionShape2D.set_shape(shape)

	height = shape.extents.y * 2


func _process(_delta):
	emit_signal("update")


func _physics_process(delta):
	direction = direction.normalized() * move_speed

	if direction.length() > 0:
		var _collision = move_and_collide(direction * delta)


func increase_height(amount: int) -> void:
	if $ColorRect.rect_size.y >= max_height:
		return

	$ColorRect.rect_position.y -= amount
	$ColorRect.rect_size.y += 2 * amount

	var collision_shape = $CollisionShape2D.get_shape()
	collision_shape.extents.y += amount

	# Move paddle inside field if grown outside.
	move_paddle_within_bounds()


func move_paddle_within_bounds() -> void:
	var extents: Vector2 = $CollisionShape2D.get_shape().extents

	var distance_from_top: float = position.y - extents.y - top_border
	if distance_from_top < 0:
		position.y -= distance_from_top

	var distance_from_bottom: float = viewport_height - (position.y + extents.y)
	if distance_from_bottom < 0:
		position.y += distance_from_bottom
