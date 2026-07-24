extends Node
class_name MusicManager

var instrument_stream_players: Dictionary = {}

func _on_song_loaded() -> void:
	var insturments = PlayerDataService.get_all_insturments()

	if PlayerDataService.current_song:
		# Setup Metronone
		Conductor.set_song(PlayerDataService.current_song.metronone, PlayerDataService.current_song.bpm, 4)
		Conductor.volume_db = -100
		Conductor.play()
		
		# Play all tracks
		for instrument in insturments:
			var stream_player = AudioStreamPlayer.new()
			add_child(stream_player)
			
			stream_player.stream = PlayerDataService.current_song[instrument]
			stream_player.volume_db = -14
			stream_player.play()
			
			instrument_stream_players[instrument] = stream_player

func _on_insturment_unlocked(instrument: String) -> void:
	if PlayerDataService.current_song:
		var stream_player = AudioStreamPlayer.new()
		add_child(stream_player)
		
		stream_player.stream = PlayerDataService.current_song[instrument]
		stream_player.volume_db = -14
		stream_player.play()
		
		instrument_stream_players[instrument] = stream_player

func _ready() -> void:
	PlayerDataService.song_loaded.connect(_on_song_loaded)
	PlayerDataService.insturment_unlocked.connect(_on_insturment_unlocked)
