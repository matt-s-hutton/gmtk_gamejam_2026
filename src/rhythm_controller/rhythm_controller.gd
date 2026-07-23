extends Node3D

const _ARROW_SCENE: PackedScene = preload("res://src/rhythm_controller/rhythm_arrow.tscn")
const HIT_WINDOW_BEATS: float = 0.3 # ±0.2 beats; tune to taste
const LEAD_BEATS: float = 2.0 # arrow visible for 2 beats before its hit
var controler_damage: float = -10
var heal_value: float = 10
@export var player: Player

var arrow_setup: Dictionary = {
	"UP": {"angle": 0.0, "direction": Vector3.FORWARD, "color": Color.RED},
	"LEFT": {"angle": 90.0, "direction": Vector3.LEFT, "color": Color.BLUE},
	"DOWN": {"angle": 180.0, "direction": Vector3.BACK, "color": Color.GREEN},
	"RIGHT": {"angle": 270.0, "direction": Vector3.RIGHT, "color": Color.ORANGE},
}

var input_grading: Dictionary = {
	10: {"text": "Perfect!", "points": 100},
	50: {"text": "Okay", "points": 30},
	100: {"text": "Missed!", "points": 0},
}

var all_arrows: Array[RhythmArrow] = []

func _ready() -> void:
	Conductor.beat.connect(_on_beat)

func _on_beat(current_beat: int) -> void:
	var arrow_direction = arrow_setup.keys().pick_random()
	var arrow_data = arrow_setup[arrow_direction]

	var arrow: RhythmArrow = _ARROW_SCENE.instantiate()
	add_child(arrow)
	arrow.missed.connect(_on_arrow_missed)


	# hardcoded for now; later this comes from chart data
	var target_beat := float(current_beat) + LEAD_BEATS

	arrow.setup(arrow_data["angle"], arrow_data["direction"], arrow_data["color"],
		target_beat, LEAD_BEATS)

	all_arrows.append(arrow)
	arrow.tree_exiting.connect(func(): all_arrows.erase(arrow))

func _try_hit_arrow(direction: Vector3) -> void:
	var now := float(Conductor.current_beat)
	var best_arrow: RhythmArrow = null
	var min_delta: float = INF

	# closest matching-direction arrow to the current beat
	for arrow in all_arrows:
		if is_instance_valid(arrow) and not arrow.is_queued_for_deletion() and arrow._direction == direction:
			var d := absf(now - arrow.target_beat)
			if d < min_delta:
				min_delta = d
				best_arrow = arrow

	if best_arrow != null and min_delta <= HIT_WINDOW_BEATS:
		var signed_delta := now - best_arrow.target_beat # <0 early, >0 late
		best_arrow.queue_free()
		player.hp_controller(heal_value)
		print("success (%.3f beats off)" % signed_delta)
		# scoring/grading logic goes here
	else:
		player.hp_controller(controler_damage)
		print("fail")
		# wrong-direction or mistimed press logic goes here

func _on_arrow_missed():
	player.hp_controller(controler_damage)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("arrow_up"):
		_try_hit_arrow(Vector3.FORWARD)
	elif event.is_action_pressed("arrow_down"):
		_try_hit_arrow(Vector3.BACK)
	elif event.is_action_pressed("arrow_left"):
		_try_hit_arrow(Vector3.LEFT)
	elif event.is_action_pressed("arrow_right"):
		_try_hit_arrow(Vector3.RIGHT)
