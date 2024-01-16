##
## AudioStreamPlayer with ADSR + Linked by あるる（きのもと 結衣） @arlez80
##
## MIT License
##

class_name AudioStreamPlayerADSR

extends AudioStreamPlayer

## 先頭空白秒数
const gap_second:float = 1024.0 / 44100.0

## ADSR制御プレイヤー
@onready var adsr_player:AnimationPlayer = $AnimationPlayer

## 発音チャンネル
var channel_number:int = -1
## 発音キーナンバー
var key_number:int = -1
## Hold 1
var hold:bool = false
## リリース中？
var releasing:bool = false
## リリース要求
var request_release:bool = false
## リリース開始ズラし
var request_release_second:float = 0.0
## 楽器情報
var instrument:Bank.Instrument = null

## ベロシティ
var velocity:int = 0
## ピッチベンド
var pitch_bend:float = 0.0
## ピッチベンド幅
var pitch_bend_sensitivity:float = 12.0
## モジュレーション
var modulation:float = 0.0
## モジュレーション幅
var modulation_sensitivity:float = 0.5
## ベースピッチ
var base_pitch:float = 0.0

## 使用時間
var using_timer:float = 0.0
## リンク先の音色
@onready var linked:AudioStreamPlayer = $Linked
## リンク先ベースピッチ
var linked_base_pitch:float = 0.0

## 同時発音数
var polyphony_count:float = 1.0

## 現在のADSRボリューム
var current_volume_db:float = 0.0 : set = set_current_volume_db

## LinkedSampleを使用中
var is_check_using_linked:bool

## 準備
func _ready( ) -> void:
	self.stop( )

## Linkedサウンドを使用しているか？
## @return	使用している場合true
func _check_using_linked( ) -> bool:
	return self.instrument != null and 2 <= len( self.instrument.array_stream )

## 楽器を変更
## @param	_instrument	楽器
func set_instrument( _instrument:Bank.Instrument ) -> void:
	if self.instrument == _instrument:
		return

	self.instrument = _instrument
	self.base_pitch = _instrument.array_base_pitch[0]
	self.stream = _instrument.array_stream[0]

	self.adsr_player.remove_animation_library( "" )
	self.adsr_player.add_animation_library( "", _instrument.adsr_states )

	self.is_check_using_linked = self._check_using_linked( )
	if self.is_check_using_linked:
		self.linked_base_pitch = _instrument.array_base_pitch[1]
		self.linked.stream = _instrument.array_stream[1]

## 再生
## @param	from_position	再生位置
func note_play( from_position:float = 0.0 ) -> void:
	self.releasing = false
	self.request_release = false
	self.using_timer = 0.0
	self.linked.bus = self.bus
	self.pitch_scale = 1.0
	self.linked.pitch_scale = 1.0
	self.volume_db = self.instrument.first_volume_db

	self.adsr_player.play( "ADS" )

	var from_position_skip_silence:float = from_position + Bank.head_silent_second
	var mix_delay:float = clampf( self.gap_second - AudioServer.get_time_to_next_mix( ), 0.0, self.gap_second )
	var own_from_position:float = from_position_skip_silence - mix_delay * pow( 2.0, self.base_pitch )

	if self.is_check_using_linked:
		var linked_from_position:float = from_position_skip_silence - mix_delay * pow( 2.0, self.linked_base_pitch )
		super.play( maxf( 0.0, own_from_position ) )
		self.linked.play( maxf( 0.0, linked_from_position ) )
	else:
		super.play( maxf( 0.0, own_from_position ) )

## 停止
func note_stop( ) -> void:
	super.stop( )
	if self.linked != null:
		self.linked.stop( )
	self.adsr_player.stop( )
	self.hold = false

## リリース開始
func start_release( ) -> void:
	self.request_release_second = self.gap_second - AudioServer.get_time_to_next_mix( )
	self.request_release = true

## ADSR制御
## @param	delta	前回からの差分秒数 sec
func _process( delta:float ) -> void:
	if not self.playing:
		return

	self.using_timer += delta

	var synthed_pitch_bend:float = self.pitch_bend * self.pitch_bend_sensitivity / 12.0
	var synthed_modulation:float = sin( self.using_timer * 32.0 ) * ( self.modulation * self.modulation_sensitivity / 12.0 )
	self.pitch_scale = pow( 2.0, self.base_pitch + synthed_modulation + synthed_pitch_bend )
	self.linked.pitch_scale = pow( 2.0, self.linked_base_pitch + synthed_modulation + synthed_pitch_bend )

	if self.hold:
		pass
	else:
		if self.request_release and not self.releasing:
			self.request_release_second -= delta
			if self.request_release_second <= 0.0:
				self.adsr_player.stop( )
				self.adsr_player.play( "R" )
				self.releasing = true

## 音量を更新
func set_current_volume_db( _current_volume_db:float ) -> void:
	current_volume_db = _current_volume_db

	var v:float = current_volume_db + linear_to_db( float( self.velocity ) / 127.0 )# + self.instrument.volume_db
	if self.is_check_using_linked:
		v = maxf( -80.0, linear_to_db( db_to_linear( v ) / self.polyphony_count / 2.0 ) )
		self.volume_db = v
		self.linked.volume_db = v
	else:
		v = maxf( -80.0, linear_to_db( db_to_linear( v ) / self.polyphony_count ) )
		self.volume_db = v

