class_name Audio

const MASTER_VOLUME_SCALE_SETTING: StringName = "quack/audio/volume/master_volume"

static func play(stream: AudioStreamWAV, volume: float = 0.0, _max_vol: float = 0.0, pitch_scale: float = 1.0) -> void:
	var player := AudioStreamPlayer.new()
	
	set_general_vars(player, stream, volume, pitch_scale)
	
	add_child(player)
	
	player.play()
	queue_free_on_finished(player)

static func set_general_vars(player: AudioStreamPlayer, stream: AudioStreamWAV, volume: float, pitch_scale: float) -> void:
	player.bus = "Master"
	player.stream = stream
	player.volume_db = volume
	player.pitch_scale = pitch_scale

static func set_3D_vars(player: AudioStreamPlayer3D, transform: Transform3D, stream: AudioStreamWAV, volume: float, pitch_scale: float) -> void:
	player.bus = "Master"
	player.stream = stream
	player.unit_db = volume
	player.pitch_scale = pitch_scale
	player.transform = transform

static func queue_free_on_finished(player: AudioStreamPlayer) -> void:
	player.finished.connect(player.queue_free)

static func queue_free_on_3D_finished(player: AudioStreamPlayer3D) -> void:
	player.finished.connect(player.queue_free)

static func add_child(player: Node) -> void:
	Quack.root.add_child(player)

static func play3D(stream: AudioStreamWAV, transform := Transform3D(), volume: float = 0.0, _max_vol: float = 0.0, pitch_scale: float = 1.0) -> void:
	var player := AudioStreamPlayer3D.new()
	add_child(player)
	set_3D_vars(player, transform, stream, volume, pitch_scale)
	queue_free_on_3D_finished(player)
	player.play()

## Changes the volume, in decibles of the master audio bus
static func set_master_volume(db: float) -> void:
	AudioServer.set_bus_volume_db(0,db)

## Changes the scale of the audio played on the master audio bus, and saves the
## change in project settings.
static func change_master_volume(scale: float) -> void:
	set_master_volume(convert_audio_scale_to_db(scale))
	ProjectSettings.set_setting(MASTER_VOLUME_SCALE_SETTING,scale)

## Converts the inputted scale to a decibel value compatible with Godot audio
## buses. Godot supports audio from -80db to 6db. This function clamps scale to
## 0 and 1, and then adds scale*80 to -80 to return its final result
static func convert_audio_scale_to_db(scale: float) -> float:
	clampf(scale,0.0,1.0)
	return -80.0 + scale*80.0

static func get_master_volume() -> float:
																#  but why tho
	return ProjectSettings.get_setting(MASTER_VOLUME_SCALE_SETTING,1.0)

static func initialize_settings() -> void:
	change_master_volume(get_master_volume())
