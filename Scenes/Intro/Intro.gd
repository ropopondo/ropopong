extends Control

export (String) var main_menu_scene


func _process(_delta):
	var intensity = $IntroTimer.time_left / $IntroTimer.wait_time
	$PanelContainer/RopopondoLabel.set_modulate(Color(intensity, intensity, intensity, 1))
 

func _on_IntroTimer_timeout():
	var _error = get_tree().change_scene(main_menu_scene)
