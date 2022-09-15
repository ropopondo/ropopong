extends Node2D


export(String) var game_scene


func _unhandled_input(_event):
	var _error = get_tree().change_scene(game_scene)


func _on_TimeoutTimer_timeout():
	var _error = get_tree().change_scene(game_scene)
