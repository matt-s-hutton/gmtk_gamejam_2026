extends Control
class_name UI

@onready var health_label: Label = %Health
@onready var game_over_ui: Control = %GameOver
@export var fanfar: AudioStreamPlayer
@onready var _game_over_background: Control = %GameOver/ColorRect
@onready var _game_over_label: Control = %GameOver/VBoxContainer/Label
@onready var _game_over_restart_buton: Control = %GameOver/VBoxContainer/RestartButton
@onready var _game_over_stream_player: AudioStreamPlayer = %GameOverStreamPlayer
@onready var _time_left_label: Label = %TimeLeft

@onready var _tutorial_ui: Control = %TutorialUI
@onready var _hud: Control = %HUD


var _game_over := false
var _latest_time_left_string = ""


func _ready() -> void:
	get_tree().paused = true
	UiService.update_health_label.connect(_on_update_health_label)
	UiService.game_ended.connect(_on_game_ended)
	UiService.game_over.connect(_on_game_over)


func _process(_delta: float) -> void:
	if not _game_over:
		var seconds = max(Conductor.get_time_left(), 0.0)
		@warning_ignore("integer_division")
		var m = int(seconds) / 60
		var s = int(seconds) % 60
		var next_time_left_string = "%d:%02d" % [m, s]
		if _latest_time_left_string != next_time_left_string:
			_latest_time_left_string = next_time_left_string
			_time_left_label.text = _latest_time_left_string


func _on_update_health_label(text: String) -> void:
	health_label.text = text


func _on_game_over() -> void:
	_game_over = true
	get_tree().paused = true
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_game_over_background, "modulate:a", 1.0, 0.5)
	tween.tween_callback(_game_over_stream_player.play)
	tween.tween_property(_game_over_label, "modulate:a", 1.0, 1.5)
	tween.parallel().tween_property(
		_game_over_restart_buton,
		"modulate:a",
		1.0,
		1.5
	)


func _on_game_ended() -> void:
	_game_over = true
	print("VICTORY")
	$Victory.show()
	get_tree().paused = true
	fanfar.play()


func _on_restart_button_pressed() -> void:
	_game_over = false
	get_tree().paused = false
	Conductor.stop()
	Conductor.reset_tracking()
	get_tree().reload_current_scene()


func _on_next_button_pressed() -> void:
	_game_over = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/level/level.tscn")


func _on_bass_button_pressed() -> void:
	# logic to add the bass to the player scene goes here
	_start_game_after_tutorial()


func _on_keyboard_button_pressed() -> void:
	# logic to add the keyboard to the player scene goes here
	_start_game_after_tutorial()


func _start_game_after_tutorial() -> void:
	get_tree().paused = false
	_tutorial_ui.hide()
	_hud.show()
	UiService.request_game_start()
