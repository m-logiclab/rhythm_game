extends Node3D

@onready var leg_left = $"character/root/leg-left"
@onready var leg_right = $"character/root/leg-right"
@onready var torso = $character/root/torso
@onready var antenna = $character/root/torso/antenna
@onready var arm_left = $"character/root/torso/arm-left"
@onready var arm_right = $"character/root/torso/arm-right"

@onready var animation_tree = $AnimationTree
@onready var state_machine  = animation_tree["parameters/playback"]

# ノードが初めてシーンツリーに入るときに呼び出される。
func _ready():
	pass


# フレームごとに呼び出される。delta' は前のフレームからの経過時間。
func _process(delta):
	# 時間とともにy座標を目標値に近づける補間
	position.y = lerp(position.y, 0.0, delta * 10.0)
	# y座標の絶対値が小さい値以下であれば、歩くアニメーション
	if abs(position.y) < 0.1:
		state_machine.travel("walk")


func jump():
	position.y = 2.0
	state_machine.travel("jump")


func set_color(resource:Resource):
	#色変更したいマテリアル番号を指定する
	leg_left.set_surface_override_material(0,resource)
	leg_right.set_surface_override_material(0,resource)
	torso.set_surface_override_material(1,resource)
	antenna.set_surface_override_material(1,resource)
	arm_left.set_surface_override_material(1,resource)
	arm_right.set_surface_override_material(1,resource)
