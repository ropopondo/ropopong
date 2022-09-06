extends Control

export (String) var game_scene


func _on_VersusPlayerButton_pressed():
	Global.game_mode = Global.GameMode.VersusPlayer
	var _error = get_tree().change_scene(game_scene)


func _on_VersusAiButton_pressed():
	Global.game_mode = Global.GameMode.VersusEasyAi
	var _error = get_tree().change_scene(game_scene)


func _on_VersusHardAiButton_pressed():
	Global.game_mode = Global.GameMode.VersusHardAi
	var _error = get_tree().change_scene(game_scene)


func _on_ExitButton_pressed():
	get_tree().quit()
