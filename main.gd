extends Node

@onready var noteInfo := {
	60: {
		"color": preload("res://variation_aqua.tres"),
		"key": "KEY_D",
		"node": get_node("robot_D"),
		"queue": []
	},
	61: {
		"color": preload("res://variation_yellow.tres"),
		"key": "KEY_F",
		"node": get_node("robot_F"),
		"queue": []
	},
	62: {
		"color": preload("res://variation_pink.tres"),
		"key": "KEY_J",
		"node": get_node("robot_J"),
		"queue": []
	},
	63: {
		"color": preload("res://variation_green.tres"),
		"key": "KEY_K",
		"node": get_node("robot_K"),
		"queue": []
	}
}
var delta_sum_ := 0.0	#deltaの合計
var offset_time = 1.0	#ノートが到着するまでの時間
var music_played = false
var note_scene = preload("res://note.tscn")
var hit_scene = preload("res://HIT.tscn")
var fast_scene = preload("res://FAST.tscn")
var miss_scene = preload("res://MISS.tscn")
var line_scene = preload("res://line_measure.tscn")

func _ready():
	#ロボットの色を変更
	for robot in noteInfo.values():
		robot.node.set_color(robot.color)


# フレームごとに呼び出される。deltaは前のフレームからの経過時間。
func _process(delta):
	delta_sum_ += delta
	for robot in noteInfo.values():
		if Input.is_action_just_pressed(robot.key):
			robot.node.jump()
			#キューにノートが入っているか
			if not robot.queue.is_empty():
				#front（配列の最初の要素）に入っているノートをチェック
				if robot.queue.front().is_hit(delta_sum_):
					#pop_front（配列の最初の要素を削除）ノートのhitを呼ぶ
					robot.queue.pop_front().hit(robot.node.global_position)
					print("hit")
					#ヒットの文字をロボの位置に生成
					var new_text = hit_scene.instantiate()
					add_child(new_text)
					new_text.global_position.x = robot.node.global_position.x
				else:
					print("TOO EARLY")
					#ファストの文字をロボの位置に生成
					var new_text = fast_scene.instantiate()
					add_child(new_text)
					new_text.global_position.x = robot.node.global_position.x
		#キューにノートが入っているのにキーを押していない場合
		if not robot.queue.is_empty():
			if robot.queue.front().is_miss(delta_sum_):
				#pop_front（配列の最初の要素を削除）ノートのmissを呼ぶ
				robot.queue.pop_front().miss()
				print("miss")
				var new_text = miss_scene.instantiate()
				add_child(new_text)
				new_text.global_position.x = robot.node.global_position.x
	#ノート到着予定時刻に再生する
	if delta_sum_ >= offset_time and not $AudioStreamPlayer.playing and not music_played:
		$AudioStreamPlayer.play()
		music_played = true


func _on_midi_player_midi_event(channel, event):
	if channel.track_name == "animation":
		var note = noteInfo.get(event.note) 	#ノート番号に対応した辞書データを入れる
		if note and event.type == 144:			#対応した番号がある・イベントタイプが144なら
			var new_note = note_scene.instantiate()	#ノートシーンを生成
			add_child(new_note)						#シーンに追加する
			new_note.expected_time     = delta_sum_ + offset_time		#ノートが到達する予定の時間
			new_note.global_position.z = -35.0							#ノートの Z 座標出現位置
			new_note.global_position.x = note.node.global_position.x	#ノートの X 座標出現位置
			new_note.set_color(note.color)	#ノートの色を変更
			note.queue.push_back(new_note)	#新しく作成したノートをキューに追加
		
		if event.type == 144:
			#36番のノートならライトを点灯
			if event.note == 36:
				get_tree().call_group("light36", "flash")
			#38番のノートならラインを生成
			if event.note == 38:
				var new_line = line_scene.instantiate()
				add_child(new_line)
				new_line.global_position.z = -35.0	#ノートの Z 座標出現位置
