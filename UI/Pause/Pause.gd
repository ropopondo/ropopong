extends Control

signal play
signal end


func _on_PlayButton_pressed():
	emit_signal("play")


func _on_ExitButton_pressed():
	emit_signal("end")


func _on_Pause_visibility_changed():
	if visible:
		$PanelContainer/VBoxContainer/HBoxContainer/MarginContainer/PlayButton.grab_focus()
