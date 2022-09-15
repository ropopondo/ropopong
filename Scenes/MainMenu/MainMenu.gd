extends Control

export(String) var tutorial_scene


func _ready():
	$MarginContainer/VBoxContainer/VBoxContainer/MarginContainer/VersusPlayerButton.grab_focus()


func _on_VersusPlayerButton_pressed():
	Global.game_mode = Global.GameMode.VersusPlayer
	var _error = get_tree().change_scene(tutorial_scene)


func _on_VersusAiButton_pressed():
	Global.game_mode = Global.GameMode.VersusEasyAi
	var _error = get_tree().change_scene(tutorial_scene)


func _on_VersusHardAiButton_pressed():
	Global.game_mode = Global.GameMode.VersusHardAi
	var _error = get_tree().change_scene(tutorial_scene)


func _on_ExitButton_pressed():
	get_tree().quit()


func _on_VersusPlayerButton_focus_entered():
	$AudioStreamPlayer.play()
