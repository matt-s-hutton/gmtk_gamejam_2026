extends Node3D

#
# Rhythm Controller
# - Spawns RhythmArrow Objects, handles movement of those obects torwards 
#
#

const _ARROW_SCENE: PackedScene = preload("res://src/rhythm_controller/rhythm_arrow.tscn")
const _BEATS_UNTIL_END: int = 1

var arrow_setup: Dictionary = {
	"UP": {
		"angle": 0.0,
		"direction": Vector3.FORWARD,
		"color": Color.RED,
	},
	"LEFT": {
		"angle": 90.0,
		"direction": Vector3.LEFT,
		"color": Color.BLUE,
	},
	"DOWN": {
		"angle": 180.0,
		"direction": Vector3.BACK,
		"color": Color.GREEN,
	},
	"RIGHT": {
		"angle": 270.0,
		"direction": Vector3.RIGHT,
		"color": Color.ORANGE,
	},
}

var all_arrows: Array[RhythmArrow] = []

func update_arrows() -> void:
	for i in range(len(all_arrows)):
		var arrow := all_arrows[i]
		
		if arrow.total_beats >= _BEATS_UNTIL_END:
			arrow.queue_free()
		else:
			arrow.total_beats += 1
			arrow.beat_delta = 0

func _on_beat(_current_beat: int) -> void:
	var arrow_direction = arrow_setup.keys().pick_random()
	var arrow_data = arrow_setup[arrow_direction]
	
	# The arrow needs to travel around 10 units (a speed of 1 travels around 1 unit per second)
	var arrow_speed = (10.0 * Conductor.beat_per_sec) / max(_BEATS_UNTIL_END, 1)
	
	var arrow: RhythmArrow = _ARROW_SCENE.instantiate();
	add_child(arrow)
	arrow.setup(arrow_data["angle"], arrow_data["direction"], arrow_data["color"], arrow_speed)
	
	all_arrows.append(arrow)
	arrow.tree_exiting.connect(func(): all_arrows.erase(arrow)) # Cleanly deregister upon free
	
	update_arrows()

func _ready() -> void:
	Conductor.beat.connect(_on_beat)