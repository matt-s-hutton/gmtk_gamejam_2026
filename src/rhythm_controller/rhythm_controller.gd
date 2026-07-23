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
	for i in range(all_arrows.size() - 1, -1, -1):
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

	var spawn_frame = Engine.get_process_frames()
	var peak_frame = spawn_frame + 60 # it's hardcode, but later i will replace it from lvl data
	arrow.setup(arrow_data["angle"], arrow_data["direction"], arrow_data["color"],
	arrow_speed, spawn_frame, peak_frame)
	
	all_arrows.append(arrow)
	arrow.tree_exiting.connect(func(): all_arrows.erase(arrow)) # Cleanly deregister upon free
	
	update_arrows()


func _try_hit_arrow(direction: Vector3) -> RhythmArrow:
	var current_frame := Engine.get_process_frames()
	var best_arrow: RhythmArrow = null
	var min_frame_delta: int = INF 

	# find arrow closest to ring with the same dir
	for arrow in all_arrows:
		if is_instance_valid(arrow) and not arrow.is_queued_for_deletion() and arrow._direction == direction:
			var frame_delta := absi(current_frame - arrow.peak_frame)	
			if frame_delta < min_frame_delta:
				min_frame_delta = frame_delta
				best_arrow = arrow

	if best_arrow != null:
		if min_frame_delta <= 10:
			best_arrow.queue_free()
			print('succes')
			return # here should be logic to success click
		else:
			print('fail')
			return # here should be logic to failed click		
		
	print('fail') # here should be logic to failed click
	return 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("arrow_up"):
		_try_hit_arrow(Vector3.FORWARD)
	elif event.is_action_pressed("arrow_down"):
		_try_hit_arrow(Vector3.BACK)
	elif event.is_action_pressed("arrow_left"):
		_try_hit_arrow(Vector3.LEFT)
	elif event.is_action_pressed("arrow_right"):
		_try_hit_arrow(Vector3.RIGHT)
		
	

func _ready() -> void:
	Conductor.beat.connect(_on_beat)
