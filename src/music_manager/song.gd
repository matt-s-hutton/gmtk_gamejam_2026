extends Resource
class_name Song

@export var metronone: AudioStream
@export var bpm: int = 120
@export var bass: AudioStream
@export var drums: AudioStream
@export var keys: AudioStream
@export var lead: AudioStream
@export var strings: AudioStream

@export var beatmap: JSON
var _beatmap_data: Variant = []
var _valid_beatmap: bool = false
const _valid_directions := ["UP", "DOWN", "LEFT", "RIGHT"]

var scrub_position: int = 0 # Position of the beat

func _ready() -> void:
	if beatmap:
		_beatmap_data = beatmap.data

		# Check if data is Array shaped
		if beatmap.data is not Array:
			_beatmap_data = []
			_valid_beatmap = false
			return

		# Validate beatmap data
		_valid_beatmap = true
		for line in _beatmap_data:
			# Check if each line is Array shaped
			if line is not Array:
				_valid_beatmap = false
				break

			# Check if each direction is valid
			for beat in line:
				if not beat in _valid_directions:
					_valid_beatmap = false
					break

func _reset_state() -> void:
	scrub_position = 0

func get_next_beat() -> Array[String]:
	if _valid_beatmap:
		return _beatmap_data[scrub_position]
	else:
		var roll = randf()
		if roll < 0.45:
			return [_valid_directions.pick_random()]
		else:
			return [_valid_directions.pick_random(), _valid_directions.pick_random()]
