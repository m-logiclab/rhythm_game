extends SpotLight3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	light_energy = lerp(float(light_energy), 0.0, delta * 10.0)

func flash():
	light_energy = 5.0

