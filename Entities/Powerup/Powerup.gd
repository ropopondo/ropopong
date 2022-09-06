extends Area2D


signal powerup_collected(powerup)


func collect(paddle):
	if paddle:
		paddle.increase_height(20)
	
	queue_free()


func _on_Powerup_body_entered(_body):
	emit_signal("powerup_collected", self)
