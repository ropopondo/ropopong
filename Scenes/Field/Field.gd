extends Node2D

signal goal_left
signal goal_right


func _on_GoalLeft_body_entered(body):
	if body is Ball:
		emit_signal("goal_left")
		body.explode()


func _on_GoalRight_body_entered(body):
	if body is Ball:
		emit_signal("goal_right")
		body.explode()
