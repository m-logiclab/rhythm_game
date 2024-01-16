extends Node3D

@export var expected_time: float
@onready var mesh = $Mesh

var speed :float = 35.0
var state := ""

func _ready():
	pass # Replace with function body.


func _process(delta):
	if state == "hit":
		queue_free()
		return

	global_position.z += delta * speed
	
	if state == "miss":
		if global_position.z < 0.0:
			queue_free()

#色変更
func set_color(resource:Resource):
	mesh.set_surface_override_material(0,resource)

#予定された時間の±0.2秒以内ならヒット
func is_hit(time:float) -> bool:
	if abs(expected_time - time) < 0.2:
		return true
	return false

#予定された時間の±0.2秒以上経過ならミス
func is_miss(time:float) -> bool:
	if time > expected_time + 0.2:
		return true
	return false

func hit(position_to_freeze:Vector3) -> void:
	state = "hit"
	global_position = position_to_freeze
	
func miss() -> void:
	state = "miss"
