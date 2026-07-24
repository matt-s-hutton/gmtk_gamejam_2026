extends Node
class_name MusicManager

@export var current_song: Song

var instrument_stream_players: Dictionary = {}

func _ready() -> void:
	var insturments = PlayerDataService.get_all_insturments()
	
	if current_song:
		# Setup Metronone
		Conductor.set_song(current_song.metronone, 150, 4)
		Conductor.volume_db = -100
		Conductor.play()
		
		# Play all tracks
		for instrument in insturments:
			var stream_player = AudioStreamPlayer.new()
			add_child(stream_player)
			
			stream_player.stream = current_song[instrument]
			stream_player.volume_db = -14
			stream_player.play()
			
			instrument_stream_players[instrument] = stream_player
