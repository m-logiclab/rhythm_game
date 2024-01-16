extends Node3D

var speed :float = 2.0

func _process(delta):
	position.y += delta * speed
	if position.y > 1:
		queue_free()
