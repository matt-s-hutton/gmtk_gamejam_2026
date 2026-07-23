extends CharacterBody3D
class_name Player

@export var max_speed := 8.0
@export var max_hp := 100.0
var can_damage: bool = true
var cooldown:float = 1.0
var hp: float
var hp_counter: float = 1.0
@export var damage_value = -20

func _process(delta: float) -> void:
	print(hp)

func _ready() -> void:
	hp = max_hp

func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var dir := Vector3(input.x, 0.0, input.y)
	velocity.x = dir.x * max_speed
	velocity.z = dir.z * max_speed
	move_and_slide()

func hp_controller(value):
	hp += value
	if hp > max_hp:
		hp = max_hp
	if hp <= 0:
		die()
	return 


func die() -> void:
	$game_over.show()
	$game_over/CanvasLayer.show()
	get_tree().paused = true

func _on_hitbox_area_entered(area: Area3D) -> void:
	if not can_damage:
		return
	if area is EnemyHurtBox:
		can_damage = false
		hp_controller(damage_value)

		if hp > 0:
			await get_tree().create_timer(cooldown).timeout
			can_damage = true
