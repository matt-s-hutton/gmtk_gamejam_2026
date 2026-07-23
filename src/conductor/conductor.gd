extends Node

# Song selection will be more upgraded later
@export var current_song: AudioStream

func _ready() -> void:
	if (current_song):
		Conductor.set_song(current_song, 120, 4)
		Conductor.volume_db = -14
		Conductor.play()