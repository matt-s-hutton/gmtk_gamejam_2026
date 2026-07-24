extends Label3D
class_name RhythmText

const TEXT_LIFETIME: float = 0.5

@export var color_array: Array[Color] = []
var _time: float = 0.0;
var _enabled: bool;
var _opacity: float = 1.0;


func setup(_direction, _text: String, _color_array: Array[Color]):
	text = _text;
	position = _direction * 10;
	
	if _color_array and len(_color_array) > 0:
		color_array = _color_array
		modulate = color_array[0]
	
	_enabled = true

func _process(delta: float) -> void:
	var length = len(color_array)
	if length > 1:
		var modulated_time = (_time / TEXT_LIFETIME)
		var current_color_index = clamp(0, floor((modulated_time) * length), length - 1)
		var current_color = color_array[current_color_index]
		current_color.a = 0.75
		
		modulate.a = 1.0
		modulate = modulate.blend(current_color)
		modulate.a = _opacity
		outline_modulate.a = _opacity
		
	_time += delta;
	position.y += _time
	_opacity = 1.0 - (_time / TEXT_LIFETIME)
	
	if _time > TEXT_LIFETIME:
		queue_free()
