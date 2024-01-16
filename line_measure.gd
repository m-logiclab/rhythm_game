extends Node3D

var speed :float = 35.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	global_position.z += delta * speed
	if global_position.z > 5:
		queue_free()
