extends CharacterBody3D
class_name Player

@export var max_speed := 8.0
@export var max_hp := 100

@onready var attack_emission_point: Marker3D = %AttackEmissionPoint
@onready var player_skin: Node3D = %PlayerSkin

var can_damage: bool = true
var cooldown:float = 1.0
var hp: int
var hp_counter: float = 1.0

var dir := Vector3.ZERO
var facing_dir := Vector3.ZERO


func _ready() -> void:
	hp = max_hp
	UiService.request_update_health_label(str(hp))


func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	dir = Vector3(input.x, 0.0, input.y)
	if dir != Vector3.ZERO:
		facing_dir = dir
		player_skin.look_at(global_position + facing_dir, Vector3.UP)
	velocity.x = dir.x * max_speed
	velocity.z = dir.z * max_speed
	move_and_slide()


func hp_controller(value: int):
	hp = mini(hp + value, max_hp)
	UiService.request_update_health_label(str(hp))
	if hp <= 0:
		die()
	return


func die() -> void:
	UiService.request_game_over()


func _on_hitbox_area_entered(area: Area3D) -> void:
	if not can_damage:
		return
	if area is EnemyHurtBox:
		can_damage = false
		var damage_value = area.enemy.damage_value
		hp_controller(damage_value)

		if hp > 0:
			await get_tree().create_timer(cooldown).timeout
			can_damage = true
