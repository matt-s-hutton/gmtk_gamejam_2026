extends Node3D

@export var spawn_count: int = 500
@export var spawn_radius: float = 35.0
@export var spawn_interval: float = 0.5

@export var player: Player
@export var song: Song

var _timer := Timer.new()
var song_length := 0.0
var song_finished := false
var song_loop: int = 0

func get_song_length(song) -> float:
	var length := 0.0

	var streams: Array[AudioStream] = [
		song.metronone,
		song.bass,
		song.drums,
		song.keys,
		song.lead,
		song.strings,
	]

	for stream in streams:
		if stream != null:
			length = maxf(length, stream.get_length())

	return length

func _ready() -> void:
	song_loop = 0
	song_length = get_song_length(song)
	Conductor.update.connect(_on_conductor_update)

	PlayerDataService.load_song(song)
	GlobalValues.score = 0

	for i in spawn_count:
		EnemyService.request_spawn_enemy()

	for instrument in GlobalValues.unlock:
		PlayerDataService.unlock_instrument(instrument)

	add_child(_timer)
	_timer.wait_time = spawn_interval
	_timer.timeout.connect(_on_spawn_tick)
	_timer.start()

func _on_conductor_update(
	_delta: float,
	position: float,
	_measure
) -> void:
	if song_finished:
		return

	if position >= song_length * 1.99:
    song_finished = true
		print('almost_victory')
		UiService.request_game_end()
		


func _on_spawn_tick() -> void:
	var angle := randf() * TAU
	var offset := Vector3(cos(angle), 0.0, sin(angle)) * spawn_radius
	EnemyService.request_activate_enemy(player.global_position + offset)
