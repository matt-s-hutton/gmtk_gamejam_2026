extends Control
class_name UI

@onready var _health_label: Label = %Health
@onready var _game_over_background: Control = %GameOver/ColorRect
@onready var _game_over_label: Control = %GameOver/VBoxContainer/Label
@onready var _game_over_restart_buton: Control = %GameOver/VBoxContainer/RestartButton
@onready var _game_over_stream_player: AudioStreamPlayer = %GameOverStreamPlayer

func _ready() -> void:
	UiService.update_health_label.connect(_on_update_health_label)
	UiService.game_over.connect(_on_game_over)


func _on_update_health_label(text: String) -> void:
	_health_label.text = text


func _on_game_over() -> void:
	get_tree().paused = true
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_game_over_background, "modulate:a", 1.0, 0.5)
	tween.tween_callback(_game_over_stream_player.play)
	tween.tween_property(_game_over_label, "modulate:a", 1.0, 1.5)
	tween.parallel().tween_property(_game_over_restart_buton, "modulate:a", 1.0, 1.5)


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	Conductor.stop()
	Conductor.reset_tracking()
	get_tree().reload_current_scene()
	Conductor.play()
