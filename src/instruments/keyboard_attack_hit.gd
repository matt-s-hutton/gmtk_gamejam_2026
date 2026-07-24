extends Node3D

@export var knockback := 6.5
@export var damage: int = 6

@onready var hit_area: Area3D = %Area3D

var _audio_playing := true
var _animation_playing := true


func _ready() -> void:
	await get_tree().physics_frame
	for area in hit_area.get_overlapping_areas():
		_on_area_3d_area_entered(area)


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	_animation_playing = false
	if not _audio_playing:
		queue_free()


func _on_explosion_stream_player_finished() -> void:
	_audio_playing = false
	if not _animation_playing:
		queue_free()


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area is EnemyHurtBox:
		var enemy: Enemy = area.enemy
		enemy.hit(damage, global_position.direction_to(enemy.global_position), knockback)


func _on_explosion_a_damage_end() -> void:
	hit_area.monitoring = false
