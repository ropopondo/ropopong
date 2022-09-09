extends Control

signal play
signal end


func _on_PlayButton_pressed():
	emit_signal("play")


func _on_ExitButton_pressed():
	emit_signal("end")
