extends Area2D

class_name Powerup

signal powerup_collected(powerup, ball)

var paddle_growth := 5

enum Type {
	GrowPaddle,
	AddBalls,
	TemporarySpeedup,
	BlockUntilHit,
}

var type


func _init():
	var type_roll := randi() % 4

	if type_roll == 0:
		type = Type.GrowPaddle
	elif type_roll == 1:
		type = Type.AddBalls
	elif type_roll == 2:
		type = Type.TemporarySpeedup
	elif type_roll == 3:
		type = Type.BlockUntilHit
	else:
		printerr("Rolled unknown powerup type.")


func _ready():
	if type == Type.GrowPaddle:
		set_label("G")
	elif type == Type.AddBalls:
		set_label("B")
	elif type == Type.TemporarySpeedup:
		set_label("S")
	elif type == Type.BlockUntilHit:
		set_label("W")
	else:
		printerr("Rolled unknown powerup type.")


func set_label(label: String) -> void:
	$Label.text = label


func collect(paddle: Paddle):
	if type == Type.GrowPaddle and paddle:
		paddle.increase_height(paddle_growth)

	queue_free()


func _on_Powerup_body_entered(body):
	if body is Ball:
		emit_signal("powerup_collected", self, body)
		
		if type == Type.TemporarySpeedup:
			body.boost(3)
