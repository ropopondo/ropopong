extends Node2D

class_name Explosion


func _ready():
	$Particles2D.emitting = true
	$Particles2D/Particles2D.emitting = true
	$Particles2D/Particles2D2.emitting = true
