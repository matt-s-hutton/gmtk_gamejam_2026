extends Node3D

const _ARROW_SCENE: PackedScene = preload("res://src/rhythm_controller/rhythm_arrow.tscn")
const _TEXT_SCENE: PackedScene = preload("res://src/rhythm_controller/rhythm_text.tscn")
const HIT_WINDOW_BEATS: float = 0.3 # ±0.5 beats; tune to taste
const LEAD_BEATS: float = 2.0 # arrow visible for 2 beats before its hit
var controler_damage: int = -10
var heal_value: int = 10
@export var player: Player

class ArrowSettings:
	var angle: float
	var direction: Vector3
	var color: Color
	
	func _init(_angle: float = 0.0, _direction: Vector3 = Vector3.ZERO, _color: Color = Color.WHITE):
		angle = _angle
		direction = _direction
		color = _color

var arrow_setup: Dictionary[String, ArrowSettings] = {
	"UP": ArrowSettings.new(0.0, Vector3.FORWARD, Color.RED),
	"LEFT": ArrowSettings.new(90.0, Vector3.LEFT, Color.BLUE),
	"DOWN": ArrowSettings.new(180.0, Vector3.BACK, Color.GREEN),
	"RIGHT": ArrowSettings.new(270.0, Vector3.RIGHT, Color.ORANGE),
}

class InputGrade:
	var text: String
	var points: int
	var color_array: Array[Color]
	
	func _init(_text: String = "", _points: int = 0, _color_array: Array[Color] = []):
		text = _text
		points = _points
		color_array = _color_array

var input_grading: Dictionary[float, InputGrade] = {
	0.05: InputGrade.new("Perfect!", 100, [Color.VIOLET, Color.CYAN, Color.LIGHT_BLUE, Color.GREEN_YELLOW, Color.ORANGE_RED, Color.INDIAN_RED]),
	0.1: InputGrade.new("Great!", 30, [Color.DARK_BLUE, Color.LIGHT_CYAN]),
	0.2: InputGrade.new("Good", 30, [Color.GREEN_YELLOW]),
	0.3: InputGrade.new("Okay", 30, [Color.DARK_ORANGE]),
}

var all_arrows: Array[RhythmArrow] = []

func _ready() -> void:
	Conductor.beat.connect(_on_beat)

func _show_message(direction: Vector3, message: String, color_array: Array[Color]) -> void:
	var new_text: RhythmText = _TEXT_SCENE.instantiate()
	add_child(new_text)
	new_text.setup(direction, message, color_array)

func _on_arrow_hit(direction: Vector3, signed_delta: float) -> void:
	player.hp_controller(heal_value)

	for threshold in input_grading.keys():
		if abs(signed_delta) < threshold:
			_show_message(direction, input_grading[threshold].text, input_grading[threshold].color_array)
			break

func _on_arrow_missed(direction: Vector3, signed_delta: float):
	player.hp_controller(controler_damage)
	
	if signed_delta > 0:
		_show_message(direction, "Late!", [Color.DARK_RED])
	elif signed_delta < 0:
		_show_message(direction, "Early!", [Color.DARK_RED])
	else:
		_show_message(direction, "Missed!", [Color.DARK_RED])

var _all_current_directions: Array[String] = []
func _on_beat(current_beat: int) -> void:
	var arrow_directions = PlayerDataService.current_song.get_next_beat()
	_all_current_directions.clear()
	
	for direction in arrow_directions:
		if direction in _all_current_directions: continue # skip duplicates
		_all_current_directions.append(direction)
		
		var arrow_data = arrow_setup[direction]
		
		var new_arrow: RhythmArrow = _ARROW_SCENE.instantiate()
		add_child(new_arrow)
		new_arrow.missed.connect(_on_arrow_missed)
		
		# hardcoded for now; later this comes from chart data
		var target_beat := float(current_beat) + LEAD_BEATS

		new_arrow.setup(arrow_data.angle, arrow_data.direction, arrow_data.color,
			target_beat, LEAD_BEATS)
		
		all_arrows.append(new_arrow)
		new_arrow.tree_exiting.connect(func(): all_arrows.erase(new_arrow))

func _try_hit_arrow(direction: Vector3) -> void:
	var best_arrow: RhythmArrow = null
	var min_delta: float = INF

	# closest matching-direction arrow to the current beat
	for arrow in all_arrows:
		if is_instance_valid(arrow) and not arrow.is_queued_for_deletion() and arrow.direction == direction:
			var d := absf(Conductor.current_beat - arrow.target_beat)
			if d < min_delta:
				min_delta = d
				best_arrow = arrow
	

	if best_arrow != null and min_delta <= HIT_WINDOW_BEATS: # Sucessful Hit
		var signed_delta := Conductor.current_beat - best_arrow.target_beat
		best_arrow.queue_free()
		_on_arrow_hit(best_arrow.direction, signed_delta)
	elif best_arrow != null: # Early (late is handled within the arrow)
		var signed_delta := Conductor.current_beat - best_arrow.target_beat
		_on_arrow_missed(best_arrow.direction, signed_delta)
	else: # No arrows found
		_on_arrow_missed(Vector3.ZERO, 0)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("arrow_up"):
		_try_hit_arrow(Vector3.FORWARD)
	elif event.is_action_pressed("arrow_down"):
		_try_hit_arrow(Vector3.BACK)
	elif event.is_action_pressed("arrow_left"):
		_try_hit_arrow(Vector3.LEFT)
	elif event.is_action_pressed("arrow_right"):
		_try_hit_arrow(Vector3.RIGHT)
