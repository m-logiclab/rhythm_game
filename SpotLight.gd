extends SpotLight3D

func _process(delta):
	light_energy = lerp(float(light_energy), 0.0, delta * 10.0)

func flash():
	light_energy = 5.0
