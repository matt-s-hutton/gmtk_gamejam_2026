extends Node

var level: int = 0
var insturments: Array = []
const _valid_instruments: Array = ["bass", "drums", "keys", "lead", "strings"]

func _ready() -> void:
	pass

func unlock_instrument(instrument: String) -> void:
	if instrument in _valid_instruments and instrument not in insturments:
		insturments.append(instrument)

func get_all_insturments() -> Array:
	return insturments