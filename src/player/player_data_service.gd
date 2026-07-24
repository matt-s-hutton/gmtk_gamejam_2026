extends Node

var current_song: Song
var level: int = 0
var insturments: Array = []
const _valid_instruments := ["bass", "drums", "keys", "lead", "strings"]

signal song_loaded()
signal insturment_unlocked(instrument: String)

func _ready() -> void:
	pass

func load_song(song: Song) -> void:
	current_song = song
	song._reset_state()
	song_loaded.emit()

func unlock_instrument(instrument: String) -> void:
	if instrument in _valid_instruments and instrument not in insturments:
		insturments.append(instrument)
		insturment_unlocked.emit(instrument)

func get_all_insturments() -> Array:
	return insturments